"""Build GGT's painting territories from native revealed/base art and metadata.

Neighbouring interiors arbitrate ownership; exploration alpha alone is not land.
Reference addon masks/code and character exploration are not inputs.
Requires Pillow, NumPy and SciPy; downloads are explicit and cached.
"""
from __future__ import annotations

import argparse
import concurrent.futures
import hashlib
import json
import random
import time
import urllib.request
from pathlib import Path

from PIL import Image, ImageChops, ImageDraw, ImageFilter, ImageStat
from map_preview_data import ClientMaps, CONTINENT_CASES
from map_mask_texture import read_texture, save_mask, save_texture
from map_art_ownership import painting_frame, polygon_mask, revealed_core, signed_distance, territory
from map_art_labels import label_masks
from map_art_backgrounds import ridge_patch, caption_patch, heal_patch

BUILD = "12.1.5.70529"
SIZE = 512


def silhouette(alpha):
    """Keep all components, including tiny islands; fill enclosed inland holes."""
    solid = alpha.point(lambda p: 255 if p >= 8 else 0)
    # Padding gives flood fill one unambiguous outside even when land touches an edge.
    outside = Image.new("L", (solid.width + 2, solid.height + 2))
    outside.paste(solid, (1, 1))
    ImageDraw.floodfill(outside, (0, 0), 128)
    return outside.crop((1, 1, solid.width + 1, solid.height + 1)).point(lambda p: 0 if p == 128 else 255)


def soften(solid, radius=5):
    # Expand before filtering: no partially transparent coastline or disappearing islet.
    padded = solid.filter(ImageFilter.MaxFilter(radius * 2 + 1))
    return ImageChops.lighter(solid, padded.filter(ImageFilter.GaussianBlur(1.5)))


def project(image, rect):
    l, r, t, b = rect
    if r <= l or b <= t:
        return Image.new("L", (SIZE, SIZE))
    return image.transform((SIZE, SIZE), Image.Transform.AFFINE,
                           (1/(r-l), 0, -l*SIZE/(r-l), 0, 1/(b-t), -t*SIZE/(b-t)),
                           Image.Resampling.BILINEAR)


def blend_landmark_masks(front, back, outline, relative, feather=2):
    """Keep a complete foreground landmark over another painting's ground.

    The foreground is opaque through the background's entire soft cut. This
    prevents the coarse continent art showing through two half-transparent masks.
    Only coverage changes; the native paintings supply all visible RGB.
    """
    solid = polygon_mask([outline])
    cut = solid.filter(ImageFilter.GaussianBlur(feather))
    support = solid.filter(ImageFilter.MaxFilter(feather * 8 + 1))
    return (ImageChops.lighter(front, support),
            ImageChops.darker(back, ImageChops.invert(project(cut, relative))))


def frame_mask():
    """Interior paintings have no exploration outline: exclude frame corners only.

    This deliberately keeps their central rectangular painting, including labels
    and rooms, instead of guessing a city's geography from its colours.
    """
    edge, cut = 10, 135
    image = Image.new("L", (SIZE, SIZE))
    # Blizzard's standard paintings decorate top-left and bottom-right. The
    # opposite corners contain city titles/land and must not be cut diagonally.
    ImageDraw.Draw(image).polygon(((cut, edge), (SIZE-edge, edge),
        (SIZE-edge, SIZE-cut), (SIZE-cut, SIZE-edge), (edge, SIZE-edge),
        (edge, cut)), fill=255)
    return image.filter(ImageFilter.GaussianBlur(2))


def sea_patch(node, land, cache):
    """Find quiet native ocean, away from land, labels and the decorative frame.

    Carry its colour into original grain, mirrored for matching tile edges.
    The colour provenance is separate from GGT's alpha-only masks.
    """
    layer = node['layer']
    w, h, tw, th = (layer[k] for k in ('layerWidth','layerHeight','tileWidth','tileHeight'))
    cols = (w+tw-1)//tw
    best = None
    for i, fid in enumerate(node['textures']):
        path = cache / f'{fid}.blp'
        if not path.exists(): continue
        with Image.open(path) as source: tile = source.convert('RGB')
        for y in range(0, min(th, h-(i//cols)*th)-63, 64):
            for x in range(0, min(tw, w-(i%cols)*tw)-63, 64):
                ax, ay = (i%cols)*tw+x, (i//cols)*th+y
                if ax < w*.08 or ay < h*.08 or ax+64 > w*.92 or ay+64 > h*.92: continue
                region = (int(ax/w*SIZE),int(ay/h*SIZE),max(int((ax+64)/w*SIZE),int(ax/w*SIZE)+1),
                          max(int((ay+64)/h*SIZE),int(ay/h*SIZE)+1))
                if ImageStat.Stat(land.crop(region)).mean[0] > 8: continue
                patch = tile.crop((x,y,x+64,y+64))
                stat = ImageStat.Stat(patch)
                r,g,b = stat.mean
                score = sum(stat.var) + max(0,r-g-12)**2*10 + max(0,g-b-30)**2*10
                if best is None or score < best[0]: best = (score,patch,fid,(x,y,x+64,y+64))
    if best is None: return None, None
    _, patch, fid, box = best
    result = paper_field(patch)
    return result, {'fileDataID':fid,'rect':box,'sha256':hashlib.sha256((cache/f'{fid}.blp').read_bytes()).hexdigest(),
                    'fill':'sampled-mean-with-seeded-grain'}


def paper_field(patch):
    # Do not repeat the source patch's ink: a quiet sample can still contain a
    # small decorative symbol. Carry only its measured colour into original grain.
    colour = [round(c) for c in ImageStat.Stat(patch).mean]
    rng = random.Random(45103)
    patch = Image.new('RGB',(64,64))
    patch.putdata([tuple(max(0,min(255,c+n)) for c in colour)
                   for n in (rng.randrange(-4,5) for _ in range(64*64))])
    result = Image.new('RGB',(128,128))
    result.paste(patch,(0,0)); result.paste(patch.transpose(Image.Transpose.FLIP_LEFT_RIGHT),(64,0))
    result.paste(result.crop((0,0,128,64)).transpose(Image.Transpose.FLIP_TOP_BOTTOM),(0,64))
    return result


def generate(directory, output, index, receipt, download=False, root_ids=None, art_ids=None):
    if art_ids and not root_ids:
        raise ValueError('An artwork-only rebuild requires --roots for its neighbour context')
    maps = ClientMaps(directory)
    adjustment_path = Path(__file__).with_name('map_art_adjustments.json')
    adjustments = json.loads(adjustment_path.read_text())
    annotations = {int(art): value for art, value in adjustments['art'].items()}
    defaults = adjustments.get('defaults', {})
    previous = {}
    if root_ids:
        previous = json.loads(receipt.read_text())
        if previous['build'] != BUILD:
            raise ValueError('A focused rebuild requires a receipt from the same client build')
    roots = sorted(set(root_ids) if root_ids else {r for r, _ in CONTINENT_CASES} | {947})
    nodes = {}
    papers = dict(previous.get('paper_sources', {}))
    papers = {int(art): record for art, record in papers.items()}
    paper_output = output.parent / 'MapPaper'
    paper_output.mkdir(parents=True,exist_ok=True)
    for root in roots:
        nodes.update(maps.fixture(root))
    # Art variants get their own silhouettes, never a default phase's guessed mask.
    import csv
    with (directory / "UiMapXMapArt.csv").open(encoding="utf-8-sig", newline="") as handle:
        arts = {(int(r["UiMapID"]), int(r["UiMapArtID"])) for r in csv.DictReader(handle)
                if int(r["UiMapID"]) in nodes}
    wanted = {int(part["FileDataID"]) for _, art in arts for overlay in maps.overlays[art]
              for part in maps.parts[overlay["ID"]] if int(part["FileDataID"]) > 0}
    for _, art in arts:
        wanted.update(int(tile['FileDataID']) for tile in maps.tiles[art])
    cache = directory / "textures"
    def fetch(fid):
        path = cache / f"{fid}.blp"
        if not path.exists():
            if not download: raise FileNotFoundError(path)
            for attempt in range(3):
                try:
                    request = urllib.request.Request(
                        f"https://wago.tools/api/casc/{fid}?build={BUILD}&mask={time.time_ns()}",
                        headers={"User-Agent": "GGT-map-mask-generator/1.0"})
                    payload = urllib.request.urlopen(request, timeout=20).read()
                    if payload[:3] != b"BLP": raise ValueError(f"Not a BLP: {fid}")
                    temp = path.with_suffix(".mask-download")
                    temp.write_bytes(payload); temp.replace(path)
                    break
                except OSError:
                    if attempt == 2: raise
        return path
    cache.mkdir(parents=True, exist_ok=True)
    with concurrent.futures.ThreadPoolExecutor(max_workers=8) as pool:
        list(pool.map(fetch, sorted(wanted)))
    inputs, solids, masks, records, cores = {}, {}, {}, {}, {}
    paintings, base_only, labels = {}, set(), {}
    backgrounds = dict(previous.get('native_backgrounds', {}))
    retouches = dict(previous.get('caption_repairs', {}))
    for map_id, art in sorted(arts):
        if not maps.overlays[art]: continue
        layer = maps.layers[maps.styles[art]]
        width, height = int(layer["LayerWidth"]), int(layer["LayerHeight"])
        tw, th = int(layer["TileWidth"]), int(layer["TileHeight"])
        base = Image.new('RGBA',(width,height))
        for tile in maps.tiles[art]:
            fid=int(tile['FileDataID']);path=cache/f'{fid}.blp'
            inputs[str(fid)]=hashlib.sha256(path.read_bytes()).hexdigest()
            base.paste(read_texture(path),(int(tile['ColIndex'])*tw,int(tile['RowIndex'])*th))
        revealed = base.copy()
        alpha = Image.new("L", (SIZE, SIZE))
        for overlay in maps.overlays[art]:
            ow, oh = int(overlay["TextureWidth"]), int(overlay["TextureHeight"])
            ox, oy = int(overlay["OffsetX"]), int(overlay["OffsetY"])
            for part in maps.parts[overlay["ID"]]:
                col, row, fid = (int(part[k]) for k in ("ColIndex", "RowIndex", "FileDataID"))
                if fid <= 0: continue
                path = cache / f"{fid}.blp"
                inputs[str(fid)] = hashlib.sha256(path.read_bytes()).hexdigest()
                tile = read_texture(path).crop((0, 0, min(tw, ow-col*tw), min(th, oh-row*th)))
                a = tile.getchannel('A')
                x, y = ox+col*tw, oy+row*th
                revealed.alpha_composite(tile,(x,y))
                l, t = round(x*SIZE/width), round(y*SIZE/height)
                r, b = round((x+a.width)*SIZE/width), round((y+a.height)*SIZE/height)
                a = a.resize((max(1,r-l), max(1,b-t)), Image.Resampling.BOX)
                piece = Image.new("L", alpha.size)
                piece.paste(a, (l,t))
                alpha = ImageChops.lighter(alpha, piece)
        # MAX preserves subpixel islands when reducing a high-resolution painting.
        if not alpha.getbbox(): base_only.add(art)
        solid = silhouette(alpha)
        solids[art] = solid
        masks[art] = soften(solid)
        records[art] = {"mapID": map_id, "kind": "overlay-silhouette"}
        if nodes[map_id]['mapType'] == 3:
            core = revealed_core(base,revealed)
            if annotations.get(art, {}).get('core'):
                core = polygon_mask(annotations[art]['core'])
                solids[art] = core
            if core.getbbox(): cores[art] = core
            if art in annotations: paintings[art] = revealed
        if art in base_only:
            # A declared exploration record may contain no visible pixels. Keep
            # the already-revealed base instead of shipping an all-black mask.
            masks[art] = frame_mask()
            records[art] = {'mapID': map_id, 'kind': 'base-painting'}
        print(f"Art {art}: {maps.ui[map_id]['Name_lang']}", flush=True)
    # Compare siblings only: different floors, nested cities, and alternative
    # phases must not punch holes in each other's geographically separate art.
    for map_id, art in sorted(arts):
        if art not in cores: continue
        parent = nodes[map_id]['parentMapID']
        fixture = maps.fixture(parent) if parent in maps.ui else {}
        node=fixture.get(map_id)
        if not node: continue
        layer=fixture[parent]['layer']
        aspect=layer['layerHeight']/layer['layerWidth']
        def physical_rect(n):
            l,r,t,b=n['rect'];return [l,r,t*aspect,b*aspect]
        rect=physical_rect(node)
        competitors, exclusions = [], []
        for other_id,other in fixture.items():
            if other_id == map_id or other['mapType'] != 3 or other['parentMapID'] != parent: continue
            if other.get('worldID') != node.get('worldID'):continue
            rival=physical_rect(other)
            if max(abs(a-b) for a,b in zip(rect,rival)) < .00001:continue
            if other['artID'] not in cores:continue
            competitors.append((rival,signed_distance(cores[other['artID']],rival[1]-rival[0],rival[3]-rival[2])))
            priority = annotations.get(other['artID'], {}).get('priority')
            if priority:
                exclusion = (rival, signed_distance(polygon_mask(priority), rival[1]-rival[0], rival[3]-rival[2]))
                rival_annotation = defaults | annotations.get(other['artID'], {})
                if rival_annotation.get('strict_frame') and not rival_annotation.get('priority_frame'):
                    exclusion += (painting_frame(SIZE, rival_annotation.get('frame_inset', .045),
                                                rival_annotation.get('frame_fade', .02)),)
                exclusions.append(exclusion)
        annotation = defaults | annotations.get(art, {}) if art in annotations else {}
        priority = polygon_mask(annotation['priority']) if annotation.get('priority') else None
        masks[art]=territory(cores[art],rect,competitors, reach=annotation.get('reach', 80), seam=annotation.get('seam', 4),
                             priority=priority, exclusions=exclusions, strict_frame=annotation.get('strict_frame', False),
                             frame_inset=annotation.get('frame_inset', .045), frame_fade=annotation.get('frame_fade', .02),
                             priority_frame=annotation.get('priority_frame', False))
        if annotation.get('cutouts'):
            cutout = polygon_mask(annotation['cutouts']).filter(ImageFilter.GaussianBlur(2))
            masks[art] = ImageChops.darker(masks[art], ImageChops.invert(cutout))
        records[art]={'mapID':map_id,'kind':'shared-painting-territory','neighbours':len(competitors)}
        if art in paintings and art not in base_only:
            original = masks[art]
            masks[art], label_mask, regions = label_masks(paintings[art], original,
                annotation.get('labels', ()), annotation.get('suppress_labels', ()))
            if label_mask.getbbox(): labels[art] = (label_mask, regions)
    for composite in adjustments.get('landmark_composites', []):
        front, back = composite['front_art'], composite['back_art']
        if front not in masks or back not in masks:
            continue
        if art_ids and ({front, back} & set(art_ids)) and not {front, back} <= set(art_ids):
            raise ValueError('A landmark composite requires both participating --arts')
        fixture = maps.fixture(composite['root_map'])
        fr = next(node['rect'] for node in fixture.values() if node['artID'] == front)
        br = next(node['rect'] for node in fixture.values() if node['artID'] == back)
        relative = [(fr[0] - br[0]) / (br[1] - br[0]), (fr[1] - br[0]) / (br[1] - br[0]),
                    (fr[2] - br[2]) / (br[3] - br[2]), (fr[3] - br[2]) / (br[3] - br[2])]
        masks[front], masks[back] = blend_landmark_masks(
            masks[front], masks[back], composite['outline'], relative, composite.get('feather', 2))
    # Geographic/diagram placement is used only where a child's complete silhouette
    # is known. Diagram maps retain their individual island/floor placement.
    for root in roots:
        if art_ids:
            continue  # Keep continent backgrounds and previous local repairs intact.
        combined = Image.new("L", (SIZE, SIZE))
        fixture = maps.fixture(root)
        for map_id, node in fixture.items():
            if map_id == root or node["mapType"] != 3: continue
            solid = solids.get(node["artID"])
            if solid:
                combined = ImageChops.lighter(combined, project(solid, node["rect"]))
        if combined.getbbox():
            art = maps.arts[root]
            masks[art] = frame_mask() if root == 947 else soften(combined.point(lambda p: 255 if p else 0), 13)
            records[art] = {"mapID": root, "kind": "world-frame" if root == 947 else "projected-zone-silhouettes"}
            if not (root_ids and art in papers):
                paper, provenance = sea_patch(fixture[root], combined, cache)
                if paper:
                    save_texture(paper,paper_output/f'{art}.blp')
                    papers[art] = provenance
        art = maps.arts[root]
        repairs = adjustments.get('background_repairs', {}).get(str(art))
        if repairs:
            background_output = output.parent / 'NativeBackgrounds'
            background_output.mkdir(parents=True, exist_ok=True)
            record = {'rootMapID':root}
            record['repairs'] = []
            for number, repair in enumerate(repairs):
                source_art = repair['source_art']
                if source_art not in paintings:
                    layer = maps.layers[maps.styles[source_art]]
                    source = Image.new('RGBA',(int(layer['LayerWidth']),int(layer['LayerHeight'])))
                    for tile in maps.tiles[source_art]:
                        fid = int(tile['FileDataID']);path=cache/f'{fid}.blp'
                        inputs[str(fid)] = hashlib.sha256(path.read_bytes()).hexdigest()
                        source.paste(read_texture(path),(int(tile['ColIndex'])*int(layer['TileWidth']),
                                                       int(tile['RowIndex'])*int(layer['TileHeight'])))
                    paintings[source_art] = source
                if 'paths' in repair:
                    image,target,uv=heal_patch(paintings[source_art],repair['paths'],repair['polygons'],repair['width'],repair.get('sample',(256,384,768,896)))
                else:
                    image, uv = ridge_patch(paintings[source_art], repair['source'],repair.get('feather',12))
                    target=repair['target']
                name = f'{art}-{repair["issue"]}' if repair.get('issue') else f'{art}-repair-{number}'
                path = background_output / f'{name}.blp'
                save_texture(image, path)
                record['repairs'].append(repair | {'file': name, 'uv': uv,'target':target,
                    'sha256': hashlib.sha256(path.read_bytes()).hexdigest()})
            current_files = {repair['file'] for repair in record['repairs']}
            for old in backgrounds.get(str(art), {}).get('repairs', []):
                path = background_output / (old['file'] + '.blp')
                if old['file'] not in current_files and path.exists() and hashlib.sha256(path.read_bytes()).hexdigest() == old['sha256']:
                    path.unlink()
            backgrounds[str(art)] = record
    for map_id, art in sorted(arts):
        if art not in masks:
            masks[art] = frame_mask()
            records[art] = {"mapID": map_id, "kind": "frame-corners-only"}
    if art_ids:
        wanted = set(art_ids)
        missing = wanted - masks.keys()
        if missing:
            raise ValueError(f'Artwork outside the supplied root context: {sorted(missing)}')
        masks = {art: alpha for art, alpha in masks.items() if art in wanted}
        labels = {art: value for art, value in labels.items() if art in wanted}
    output.mkdir(parents=True, exist_ok=True)
    generated = dict(previous.get('masks', {}))
    for art, alpha in sorted(masks.items()):
        path = output / f"{art}.blp"
        save_mask(alpha, path)
        generated[str(art)] = records[art] | {"sha256": hashlib.sha256(path.read_bytes()).hexdigest()}
    label_output = output.parent / 'ArtLabels'
    label_output.mkdir(parents=True, exist_ok=True)
    label_records = {art: record for art, record in previous.get('labels', {}).items() if int(art) not in masks}
    for art, (alpha, regions) in labels.items():
        path = label_output / f'{art}.blp'
        save_mask(alpha, path)
        label_records[str(art)] = {'regions': regions, 'sha256': hashlib.sha256(path.read_bytes()).hexdigest()}
    for art, record in previous.get('labels', {}).items():
        if int(art) in masks and art not in label_records:
            path = label_output / f'{int(art)}.blp'
            if path.exists() and hashlib.sha256(path.read_bytes()).hexdigest() == record['sha256']:
                path.unlink()
    base_only.update(art for art in previous.get('base_only', []) if art not in masks)
    repair_output = output.parent / 'CaptionRepairs'
    for art in masks:
        repairs = annotations.get(art,{}).get('caption_repairs',[])
        old_repairs = retouches.pop(str(art), [])
        current_repairs = []
        if repairs:
            repair_output.mkdir(parents=True,exist_ok=True)
        for number,repair in enumerate(repairs):
            image,rect,uv = caption_patch(paintings[art],repair['target'],repair['sample'])
            name=f'{art}-{number}'
            path=repair_output/(name+'.blp');save_texture(image,path)
            current_repairs.append(repair | {'file':name,'rect':rect,'uv':uv,
                'sha256':hashlib.sha256(path.read_bytes()).hexdigest()})
        if current_repairs:
            retouches[str(art)] = current_repairs
        current_files = {repair['file'] for repair in current_repairs}
        for old in old_repairs:
            path = repair_output / (old['file'] + '.blp')
            if old['file'] not in current_files and path.exists() and hashlib.sha256(path.read_bytes()).hexdigest() == old['sha256']:
                path.unlink()
    inputs = previous.get('texture_sha256', {}) | inputs
    all_art = sorted(int(art) for art in generated)
    # A quiet original paper field under cut-out art; never copy game RGB or
    # leave a dark viewport-shaped hole where decorative parchment was hidden.
    if not art_ids:
        rng = random.Random(45103)
        paper = Image.new("RGB", (128, 128))
        paper.putdata([(145+n, 140+n, 113+n) for n in (rng.randrange(-4, 5) for _ in range(128*128))])
        paper.save(output.parent / "MapPaper.tga")
        save_mask(frame_mask(), output.parent / "FrameCutout.blp")
        bounds = Image.new('L',(SIZE,SIZE))
        ImageDraw.Draw(bounds).rectangle((16,16,SIZE-17,SIZE-17),fill=255)
        save_mask(bounds.filter(ImageFilter.GaussianBlur(2)),output.parent/'BoundsFade.blp')
    index.write_text("-- Generated by tools/generate_map_art_masks.py; independently derived painting coverage.\n"
                     "local _, NS = ...\nNS.GoldTracker.MapArtMasks = {\n" +
                     "".join(f"    [{art}] = true,\n" for art in all_art) + "}\nNS.GoldTracker.MapArtPaper = {\n" +
                     "".join(f"    [{art}] = true,\n" for art in sorted(papers)) + "}\nNS.GoldTracker.MapArtTerritories = {\n" +
                     "".join(f"    [{art}] = true,\n" for art in all_art if generated[str(art)]['kind']=='shared-painting-territory') + "}\nNS.GoldTracker.MapArtBaseOnly = {\n" +
                     "".join(f"    [{art}] = true,\n" for art in sorted(base_only)) + "}\nNS.GoldTracker.MapArtLabels = {\n" +
                     "".join(f"    [{art}] = true,\n" for art in sorted(map(int, label_records))) + "}\nNS.GoldTracker.MapNativeBackdrops = {\n" +
                     "".join(f"    [{art}] = true,\n" for art in adjustments['native_backdrops']) + "}\nNS.GoldTracker.MapBackgroundRepairs = {\n" +
                     ''.join(f'    [{art}] = {{\n'+''.join(
                         '        { file = "'+repair['file']+'", rect = { '+', '.join(map(str,repair['target']))+
                         ' }, uv = { '+', '.join(map(str,repair['uv']))+' } },\n' for repair in record.get('repairs', []))+'    },\n'
                         for art, record in sorted(backgrounds.items(), key=lambda row:int(row[0])))+'}\nNS.GoldTracker.MapCaptionRepairs = {\n'+
                     ''.join(f'    [{art}] = {{\n'+''.join(
                         '        { file = "'+repair['file']+'", rect = { '+', '.join(map(str,repair['rect']))+
                         ' }, uv = { '+', '.join(map(str,repair['uv']))+' } },\n' for repair in records)+'    },\n'
                         for art,records in sorted(retouches.items(),key=lambda row:int(row[0])))+'}\n', encoding="utf-8")
    receipt.write_text(json.dumps({"build": BUILD, "algorithm": "native-reveal-difference-ownership-v3",
        "size": SIZE, "format": "BLP2-BC3-mipmapped", "mask_count": len(generated), "masks": generated,
        "labels": label_records, "base_only": sorted(base_only),
        "native_backgrounds": backgrounds, "caption_repairs":retouches,
        "annotations_sha256": hashlib.sha256(adjustment_path.read_bytes()).hexdigest(),
        "paper_sources": papers, "texture_sha256": inputs,
        **({'detail_backdrops': previous['detail_backdrops']} if 'detail_backdrops' in previous else {}),
        "auxiliary_sha256": {str(p.relative_to(output.parent)).replace('\\','/'): hashlib.sha256(p.read_bytes()).hexdigest()
                             for p in [output.parent/'MapPaper.tga', output.parent/'FrameCutout.blp',output.parent/'BoundsFade.blp']
                             + sorted(paper_output.glob('*.blp'))},
        "metadata_sha256": {p.name: hashlib.sha256(p.read_bytes()).hexdigest() for p in directory.glob("*.csv")
                            if p.stem in ("UiMap", "UiMapAssignment", "UiMapLink", "UiMapXMapArt", "UiMapArt",
                                          "UiMapArtStyleLayer", "WorldMapOverlay", "WorldMapOverlayTile")},
        "source": f"https://wago.tools/api/casc/{{FileDataID}}?build={BUILD}",
        "copyright": "World of Warcraft map art and local landmark derivatives are copyright Blizzard Entertainment.",
        "limitations": ["Unknown artwork retains its existing edge fade; paintings without exploration outlines use frame-corner exclusion only.",
                        "Native WoW rendering and performance remain unverified by offline asset generation.",
                        "Offline projection fixtures use default art and unconditional map links."]}, indent=2)+"\n", encoding="utf-8")
    print(f"Generated {len(masks)} independently derived art masks", flush=True)


if __name__ == "__main__":
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("--input", type=Path, default=Path(".local/interactive-map-research"))
    p.add_argument("--output", type=Path, default=Path("UI/Maps/Media/ArtMasks"))
    p.add_argument("--index", type=Path, default=Path("UI/Maps/ArtMaskIndex.lua"))
    p.add_argument("--receipt", type=Path, default=Path("docs/research/map-art-masks-2026-10-24.json"))
    p.add_argument("--download", action="store_true")
    p.add_argument("--roots", type=int, nargs="+", help="Rebuild selected roots, merging into a same-build receipt/index")
    p.add_argument("--arts", type=int, nargs="+", help="Export only these paintings; retain sibling context and skip continent/background assets")
    a = p.parse_args()
    generate(a.input, a.output, a.index, a.receipt, a.download, a.roots, a.arts)
