"""Offline raster preview of the actual Lua renderer against client map metadata.

Requires lupa and Pillow. Input CSVs come from Wago build 12.1.5.70529. Maps are
fully revealed as in Alts; this is not a live WoW screenshot.
Downloaded game textures stay in .local and are never included in the addon.
"""
from __future__ import annotations

import argparse
import concurrent.futures
import json
import time
import urllib.request
from pathlib import Path

from lupa.lua51 import LuaRuntime
from PIL import Image, ImageChops, ImageEnhance
from map_preview_data import ClientMaps, CONTINENT_CASES, GLOBAL_CASES
from map_mask_texture import read_texture

class TextureFetchError(RuntimeError):
    pass


def draw_depth(texture):
    layers = {"BACKGROUND": 0, "BORDER": 1, "ARTWORK": 2, "OVERLAY": 3, "HIGHLIGHT": 4}
    return layers.get(texture.layer, 2), int(texture.subLevel or 0)


def preview(root: Path, output: Path, download: bool, outland: bool = False,
            kalimdor: bool = False, renderer: Path | None = None, azeroth: bool = False,
            continent: int | None = None, focus: int | None = None, audit_only: bool = False,
            zooms: list[float] | None = None, scene: Path | None = None,
            at: tuple[float, float] = (.65, .45), standard_map: bool = False) -> dict:
    metadata = ClientMaps(root)
    root_id, zone_id = (101, 100) if outland else (13, 37)
    selected = [100, 102, 104, 105, 107, 108, 109, 111] if outland else [37, 52, 47, 49, 84]
    if kalimdor or azeroth:
        root_id, zone_id = 12, 10
        selected = [1, 7, 10, 199, 70, 65, 66, 69, 64, 63, 85, 88, 198, 76, 71, 81, 249]
    if azeroth:
        root_id, selected = 947, [12] + selected
    if continent is not None:
        root_id, zone_id, selected = continent, focus or next(z for c, z in CONTINENT_CASES if c == continent), None
    maps = metadata.fixture(root_id, selected)
    if root_id not in maps or zone_id not in maps: raise ValueError(f"Unplaceable map fixture: {root_id}/{zone_id}")
    selected = [i for i in maps if i != root_id]

    lua = LuaRuntime(unpack_returned_tuples=True)

    def lua_table(obj):
        if isinstance(obj, dict): return lua.table_from({k: lua_table(v) for k, v in obj.items()})
        if isinstance(obj, list): return lua.table_from([lua_table(v) for v in obj])
        return obj

    lua.globals().fixture = lua_table(maps)
    lua.globals().mapInfo = lua_table({i: metadata.info(i) for i in metadata.ui})
    lua.globals().rootID, lua.globals().zoneID = root_id, zone_id
    lua.globals().standardMap = standard_map
    lua.globals().children = lua_table([maps[i] for i in selected])
    lua.globals().rendererPath = str(renderer or Path("UI/Maps/MapRenderer.lua")).replace("\\", "/")
    lua.globals().scenePath = str(scene or Path("UI/Maps/MapScene.lua")).replace("\\", "/")
    lua.execute('''
        local widget = require("tests.helpers.map_ui").widget
        local root = fixture[rootID]
        C_Map = {
            GetMapInfo = function(id) return mapInfo[id] end,
            GetMapChildrenInfo = function() return children end,
            GetMapRectOnMap = function(id)
                local m = fixture[id]
                return unpack(m.rect)
            end,
            GetMapArtID = function(id) return fixture[id].artID end,
            GetMapArtLayers = function(id) return { fixture[id].layer } end,
            GetMapArtLayerTextures = function(id) return fixture[id].textures end,
            GetWorldPosFromMapPos = function(id,p)
                local m=fixture[id]; local x,y=p:GetXY()
                if not m or not m.worldID then return end
                return m.worldID, CreateVector2D(m.n0+y*(m.n1-m.n0),m.w0+x*(m.w1-m.w0))
            end,
        }
        CreateVector2D = function(x,y) return {GetXY=function() return x,y end} end
        CreateFrame = widget
        -- Rendering research explicitly opts in; production defaults to ordinary maps.
        addon = { db = { enableExperimentalMaps = not standardMap } }
        ns = { GoldTracker = addon, JanisTheme = {
            CreatePanel = function(_,parent) return widget(nil,nil,parent) end,
            CreateButton = function(_,parent) local b=widget(nil,nil,parent); b.label=b:CreateFontString();return b end,
        } }
        GeneralGoldTrackerCatalogNamespace = ns
        for _,name in ipairs({"Geometry","ArtMaskIndex","OceanIndex","CornerFillIndex","WaterHatchingIndex","MapSource","MapScene","MapRenderer","InteractiveMap"}) do
            assert(loadfile(name == "MapRenderer" and rendererPath or name == "MapScene" and scenePath or "UI/Maps/"..name..".lua"))("General-Gold-Tracker",ns)
        end
        addon.LoadCatalog=function()
            assert(loadfile("Data/General-Gold-Tracker_MapData/TerrainIndex.lua"))()
            return true
        end
        map = addon:CreateInteractiveMapCard(widget(),"Map")
        map.viewport:SetSize(1000,650)
        map:SetSubject({ key="preview", mapID=zoneID, continentMapID=rootID,x=0.43,y=0.63,
            revealAll=true, includeContinents=true, getExploration=function() error("Revealed map read character discovery") end })
    ''')
    map_view = lua.globals().map
    image_cache = {}
    texture_dir = root / "textures"
    texture_dir.mkdir(exist_ok=True)

    def fetch_texture(file_id):
        path = texture_dir / f"{int(file_id)}.blp"
        if not path.exists():
            if not download: raise FileNotFoundError(path)
            url = f"https://wago.tools/api/casc/{int(file_id)}?build=12.1.5.70529"
            for attempt in range(3):
                try:
                    request = urllib.request.Request(url + (f"&retry={time.time_ns()}" if attempt else ""),
                                                     headers={"User-Agent": "GGT-map-preview/1.0"})
                    payload = urllib.request.urlopen(request, timeout=20).read()
                    break
                except OSError as error:
                    if attempt == 2: raise TextureFetchError(f"Blizzard texture {file_id}: {error}") from error
                    time.sleep(0.5 * (attempt+1))
            temporary = path.with_suffix(".download")
            temporary.write_bytes(payload)
            temporary.replace(path)
        return path

    def texture(file_id):
        if file_id in image_cache: return image_cache[file_id]
        if isinstance(file_id, str):
            path = Path(file_id.split("General-Gold-Tracker\\", 1)[1].replace("\\", "/"))
        else:
            path = fetch_texture(file_id)
        image = read_texture(path)
        image_cache[file_id] = image
        return image

    def raster(tex, size):
        im = texture(tex.texture)
        u = tex.texCoord
        if tex.wrap == "REPEAT":
            import math
            tile = Image.new("RGBA", (im.width*math.ceil(max(u[1],u[2])), im.height*math.ceil(max(u[3],u[4]))))
            for y in range(0,tile.height,im.height):
                for x in range(0,tile.width,im.width): tile.paste(im,(x,y))
            region = tile.crop((min(u[1],u[2])*im.width,min(u[3],u[4])*im.height,
                               max(u[1],u[2])*im.width,max(u[3],u[4])*im.height))
            return region.resize(size,Image.Resampling.BICUBIC)
        region = im.crop((min(u[1], u[2]) * im.width, min(u[3], u[4]) * im.height,
                          max(u[1], u[2]) * im.width, max(u[3], u[4]) * im.height))
        if u[1] > u[2]: region = region.transpose(Image.Transpose.FLIP_LEFT_RIGHT)
        if u[3] > u[4]: region = region.transpose(Image.Transpose.FLIP_TOP_BOTTOM)
        return region.resize(size, Image.Resampling.BICUBIC)

    def mask_alpha(mask, x, y, size):
        # MaskTexture UV transforms are not a portable cropping mechanism in WoW.
        # Sample the full mask in screen space, independently of the masked quad.
        im = texture(mask.texture).getchannel("A")
        point = mask.points[1]
        sx, sy = im.width / mask.width, im.height / mask.height
        return im.transform(size, Image.Transform.AFFINE,
                            (sx, 0, (x - point[4]) * sx, 0, sy, (y + point[5]) * sy),
                            Image.Resampling.BILINEAR)

    output.mkdir(parents=True, exist_ok=True)
    views = [("continent", 1), ("transition-early", 1.8), ("transition-late", 2.6),
             ("zone", None), ("terrain-early", 12), ("terrain", 40), ("terrain-deep", 90)]
    if kalimdor:
        views = [(f"zoom-{z:05.2f}", z) for z in (1, 1.3, 1.4, 1.5, 1.6, 2, 2.6, 3.4, 4.5, 6, 8, 12, 20)]
    if azeroth:
        views = [(f"zoom-{z:05.2f}", z) for z in (1, 1.2, 1.3, 1.5, 2, 2.5, 3, 3.25, 3.5, 4, 5, 6, 8, 12, 16, 24, 40, 64)]
    if continent is not None:
        m, layer = maps[zone_id], maps[root_id]["layer"]
        base_width = layer["layerWidth"] * min(1000/layer["layerWidth"], 650/layer["layerHeight"])
        density = base_width * (m["rect"][1]-m["rect"][0]) * (1600/3) / abs(m["w1"]-m["w0"])
        context = map_view.source.Context(map_view.source, map_view.source.byID[zone_id])
        base_height = base_width * layer["layerHeight"] / layer["layerWidth"]
        context_scale = max((context.rect.r-context.rect.l)*base_width/1000,
                            (context.rect.b-context.rect.t)*base_height/650)
        views = [("continent", 1), ("detail-before", max(1, 1.4/context_scale)),
                 ("detail-middle", max(1, 1.5/context_scale)), ("detail-after", max(1, 1.6/context_scale)),
                 ("zone", None), ("terrain-middle", min(128, 115/density)), ("terrain-after", min(128, 150/density))]
    if zooms:
        views = [(f"zoom-{zoom:05.2f}", zoom) for zoom in zooms]
    report = {"mapID": root_id, "name": maps[root_id]["name"], "focusMapID": zone_id, "focusPoint": list(at),
              "displayMapID": int(map_view.source.rootID), "renderStyle": "standard" if standard_map else "seamless",
              "mappedNodes": len(maps), "stages": []}
    for name, zoom in views:
        command = "map:Reset()"
        if zoom is not None:
            command += f";addon.MapGeometry.ZoomAt(map.view,{zoom},500,325)"
        command += f";local n=map.source.byID[zoneID];map.view.x=n.rect.l+{at[0]}*(n.rect.r-n.rect.l);map.view.y=n.rect.t+{at[1]}*(n.rect.b-n.rect.t);addon.MapGeometry.Constrain(map.view);map:Render()"
        lua.execute(command)
        plan = lua.globals().addon.MapScene.Build(map_view.view, map_view.source, map_view.renderer.visible)
        weights = {}
        for _, entry in plan.zones.items():
            weights.setdefault(int(entry.state.context.mapID), set()).add(round(float(entry.alpha), 9))
        if any(len(values) != 1 for values in weights.values()): raise AssertionError("Unsynchronized zone transition")
        active = [g for _, g in sorted(map_view.renderer.groups.items()) if g.used]
        painting_layers = {}
        if standard_map:
            # Creation order in the software preview hid native draw-depth
            # collisions between the covered painting and its reveal pieces.
            art = map_view.source.root.art
            base_ids = {int(fid) for _, fid in art.textures.items()}
            pieces = map_view.source.Exploration(map_view.source, map_view.source.root)
            reveal_ids = {int(piece.fileID) for _, piece in pieces.items()}
            for role, ids in (("base", base_ids), ("revealed", reveal_ids)):
                depths = {draw_depth(g.pool[i].texture) for g in active
                          for i in range(1, int(g.used) + 1) if g.pool[i].texture.texture in ids}
                if depths: painting_layers[role] = sorted(depths)
            if (painting_layers.get("base") and painting_layers.get("revealed")
                    and min(painting_layers["revealed"]) <= max(painting_layers["base"])):
                raise AssertionError("Revealed map pieces share or fall below the covered painting's draw depth")
        passes = [(g.kind, int(g.mapID), int(g.used)) for g in active]
        base_layers = [i for i, g in enumerate(active) if g.kind == "base"]
        detail_layers = [i for i, g in enumerate(active) if g.kind == "detail"]
        terrain_layers = [i for i, g in enumerate(active) if g.kind == "terrain"]
        if base_layers and detail_layers and max(base_layers) >= min(detail_layers): raise AssertionError("Background covers detail")
        if detail_layers and terrain_layers and max(detail_layers) >= min(terrain_layers): raise AssertionError("Detail covers terrain")
        stage = {"name": name, "zoom": float(map_view.view.zoom), "regions": int(map_view.renderer.used),
                 "terrainPieces": int(map_view.renderer.terrainCount), "passes": passes,
                 "synchronizedContexts": {k: next(iter(v)) for k, v in weights.items()},
                 "budgetReached": bool(map_view.renderer.regionBudgetReached), "paintingLayers": painting_layers}
        report["stages"].append(stage)
        if stage["budgetReached"]:
            raise AssertionError(f"{root_id}/{zone_id} {name}: renderer omitted visible regions at its texture limit")
        print(f'{root_id}/{zone_id} {name}: {stage["regions"]} regions, {stage["terrainPieces"]} terrain pieces', flush=True)
        if audit_only: continue
        if download:
            wanted = set()
            for g in active:
                for i in range(1, int(g.used)+1):
                    tex = g.pool[i].texture
                    if isinstance(tex.texture, (int, float)): wanted.add(int(tex.texture))
                    for mask, enabled in tex.masks.items() if tex.masks else []:
                        if enabled and isinstance(mask.texture, (int, float)): wanted.add(int(mask.texture))
            with concurrent.futures.ThreadPoolExecutor(max_workers=8) as pool:
                list(pool.map(fetch_texture, wanted))
        image = Image.new("RGBA", (1000, 650), (51, 41, 26, 255))
        for _, group in sorted(map_view.renderer.groups.items()):
            textures = [group.pool[i].texture for i in range(1, int(group.used) + 1)]
            for tex in sorted(textures, key=draw_depth):
                if not tex.shown: continue
                point = tex.points[1]
                x, y = round(point[4]), round(-point[5])
                # Round shared edges, not widths independently, to reproduce
                # contiguous GPU quads without artificial one-pixel raster gaps.
                size = (max(1, round(point[4] + tex.width) - x), max(1, round(-point[5] + tex.height) - y))
                region = raster(tex, size)
                if tex.desaturation:
                    rgb = ImageEnhance.Color(region.convert("RGB")).enhance(1 - tex.desaturation)
                    rgb.putalpha(region.getchannel("A")); region = rgb
                if tex.vertexColor:
                    channels = list(region.split())
                    for c in range(3): channels[c] = channels[c].point(lambda value: round(value * tex.vertexColor[c + 1]))
                    region = Image.merge("RGBA", channels)
                alpha = region.getchannel("A").point(lambda v: round(v * tex.alpha))
                for mask, enabled in tex.masks.items() if tex.masks else []:
                    if enabled: alpha = ImageChops.multiply(alpha, mask_alpha(mask, x, y, size))
                region.putalpha(alpha)
                image.alpha_composite(region, (x, y))
        image.convert("RGB").save(output / f"{name}.png")
    (output / "audit.json").write_text(json.dumps(report, indent=2), encoding="utf-8")
    return report


if __name__ == "__main__":
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("--input", type=Path, default=Path(".local/interactive-map-research"))
    p.add_argument("--output", type=Path, default=Path(".local/interactive-map-preview"))
    p.add_argument("--download", action="store_true")
    p.add_argument("--outland", action="store_true", help="Check Outland/Hellfire and all adjacent zones")
    p.add_argument("--kalimdor", action="store_true", help="Check the Barrens and neighbors through thirteen zoom stages")
    p.add_argument("--azeroth", action="store_true", help="Check the full world-to-Kalimdor-to-terrain sequence")
    p.add_argument("--renderer", type=Path, help="Use a saved renderer for before/after regression previews")
    p.add_argument("--scene", type=Path, help="Use a saved scene planner for before/after transition previews")
    p.add_argument("--continent", type=int, help="Preview any supported continent using all placeable descendants")
    p.add_argument("--focus", type=int, help="Zone to zoom toward with --continent")
    p.add_argument("--zooms", type=float, nargs="+", help="Override preview stages with explicit zoom factors")
    p.add_argument("--at", type=float, nargs=2, default=(.65, .45), metavar=("X", "Y"),
                   help="Center on this normalized coordinate within the focus map")
    p.add_argument("--all-continents", action="store_true", help="Audit every supported continent and mixed-world case")
    p.add_argument("--global-cases", action="store_true", help="Audit the complete Azeroth scene toward every major continent")
    p.add_argument("--audit-only", action="store_true", help="Check rendering passes and projections without downloading/rasterizing art")
    p.add_argument("--standard-map", action="store_true", help="Preview ordinary Blizzard paintings with experimental map rendering disabled")
    p.add_argument("--resume", action="store_true", help="Reuse completed images in this output; use a fresh output after renderer changes")
    a = p.parse_args()
    if a.all_continents or a.global_cases:
        reports, failures = [], []
        for c, z in (GLOBAL_CASES if a.global_cases else CONTINENT_CASES):
            output = a.output / f"{c}-{z}"
            saved = output / "audit.json"
            expected_images = ([f"zoom-{z:05.2f}.png" for z in a.zooms] if a.zooms else
                               ["continent.png", "detail-before.png", "detail-middle.png", "detail-after.png",
                                "zone.png", "terrain-middle.png", "terrain-after.png"])
            if a.resume and saved.exists() and (a.audit_only or all((output/name).exists() for name in expected_images)):
                reports.append(json.loads(saved.read_text()))
                print(f"Reusing {c}/{z}", flush=True)
                continue
            try:
                reports.append(preview(a.input, output, a.download, renderer=a.renderer,
                                       continent=c, focus=z, audit_only=a.audit_only, zooms=a.zooms, scene=a.scene, at=a.at, standard_map=a.standard_map))
            except TextureFetchError as error:
                failures.append({"mapID": c, "focusMapID": z, "error": str(error)})
                print(str(error), flush=True)
        (a.output / "audit.json").write_text(json.dumps(reports, indent=2), encoding="utf-8")
        (a.output / "download-errors.json").write_text(json.dumps(failures, indent=2), encoding="utf-8")
        if failures: raise SystemExit(f"{len(failures)} visual cases incomplete; see download-errors.json")
    else:
        preview(a.input, a.output, a.download, a.outland, a.kalimdor, a.renderer, a.azeroth,
                a.continent, a.focus, a.audit_only, a.zooms, a.scene, a.at, a.standard_map)
