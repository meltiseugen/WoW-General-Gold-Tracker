"""Build offline map fixtures from build-pinned Blizzard CSVs, never addon data.

UiMapLink handles diagram/inset maps; UiMapAssignment handles physical maps and
their normalized placement. These fixtures cannot emulate player conditions.
"""
from __future__ import annotations

import csv
import json
import math
from collections import defaultdict
from pathlib import Path

CONTINENT_CASES = (
    (12, 10), (13, 37), (101, 100), (113, 115), (424, 376), (572, 535),
    (619, 680), (875, 862), (876, 895), (905, 830), (948, 207),
    (1550, 1533), (1978, 2022), (2274, 2248), (2274, 2214),
    (2274, 2371), (2537, 2395), (2537, 2413), (2537, 2405),
)
GLOBAL_CASES = tuple((947, zone) for zone in (10, 37, 115, 376, 680, 862, 895, 2022, 2248, 2214, 2395))


def subrect(parent, child):
    l, r, t, b = parent
    return [l + child[0] * (r-l), l + child[1] * (r-l),
            t + child[2] * (b-t), t + child[3] * (b-t)]


class ClientMaps:
    def __init__(self, directory: Path):
        def table(name):
            with (directory / f"{name}.csv").open(encoding="utf-8-sig", newline="") as handle:
                return list(csv.DictReader(handle))
        self.ui = {int(r["ID"]): r for r in table("UiMap")}
        self.arts = {int(r["UiMapID"]): int(r["UiMapArtID"]) for r in table("UiMapXMapArt") if r["PhaseID"] == "0"}
        styles = {int(r["ID"]): int(r["UiMapArtStyleID"]) for r in table("UiMapArt")}
        self.layers = {int(r["UiMapArtStyleID"]): r for r in table("UiMapArtStyleLayer") if r["LayerIndex"] == "0"}
        self.styles = styles
        self.assignments, self.tiles, self.overlays, self.parts = (defaultdict(list) for _ in range(4))
        for row in table("UiMapAssignment"): self.assignments[int(row["UiMapID"])].append(row)
        for rows in self.assignments.values(): rows.sort(key=lambda r: int(r["OrderIndex"]))
        for row in table("UiMapArtTile"):
            if row["LayerIndex"] == "0": self.tiles[int(row["UiMapArtID"])].append(row)
        for row in table("WorldMapOverlay"): self.overlays[int(row["UiMapArtID"])].append(row)
        for row in table("WorldMapOverlayTile"):
            if row["LayerIndex"] == "0": self.parts[row["WorldMapOverlayID"]].append(row)
        self.links = {}
        for row in table("UiMapLink"):
            if row["PlayerConditionID"] == "0":
                self.links.setdefault((int(row["ChildUiMapID"]), int(row["ParentUiMapID"])), row)
        self._worlds, self._rects = {}, {}
        policy = json.loads(Path(__file__).with_name('map_art_adjustments.json').read_text())
        self.outdoor_orphans = set(policy.get('outdoor_orphans', ()))

    def info(self, map_id):
        row = self.ui[map_id]
        return {"mapID": map_id, "name": row["Name_lang"], "mapType": int(row["Type"]),
                "parentMapID": int(row["ParentUiMapID"])}

    def world(self, map_id):
        if map_id in self._worlds: return self._worlds[map_id]
        rows = self.assignments[map_id]
        result = None
        if rows:
            r = rows[0]
            x0, x1, y0, y1 = (float(r[k]) for k in ("UiMin_0", "UiMax_0", "UiMin_1", "UiMax_1"))
            if x1 > x0 and y1 > y0:
                dw = (float(r["Region_1"]) - float(r["Region_4"])) / (x1-x0)
                dn = (float(r["Region_0"]) - float(r["Region_3"])) / (y1-y0)
                w0, n0 = float(r["Region_4"]) - x0*dw, float(r["Region_3"]) - y0*dn
                result = {"worldID": int(r["MapID"]), "w0": w0, "w1": w0+dw, "n0": n0, "n1": n0+dn}
        self._worlds[map_id] = result
        return result

    def rect(self, map_id, root_id, seen=None):
        if map_id == root_id: return [0, 1, 0, 1]
        key = (map_id, root_id)
        if key in self._rects: return self._rects[key]
        seen = set() if seen is None else set(seen)
        if key in seen: return None
        seen.add(key)
        link = self.links.get(key)
        if link:
            result = [float(link[k]) for k in ("UiMin_0", "UiMax_0", "UiMin_1", "UiMax_1")]
        else:
            world = self.world(map_id)
            candidates = [r for r in self.assignments[root_id] if world and int(r["MapID"]) == world["worldID"]]
            result = None
            if candidates:
                n, w = (world["n0"]+world["n1"])/2, (world["w0"]+world["w1"])/2
                r = next((r for r in candidates if float(r["Region_0"]) <= n <= float(r["Region_3"])
                          and float(r["Region_1"]) <= w <= float(r["Region_4"])), candidates[0])
                def axis(value, low, high, ui_low, ui_high):
                    return float(r[ui_low]) + (value-float(r[low]))/(float(r[high])-float(r[low])) * (float(r[ui_high])-float(r[ui_low]))
                result = [axis(world[k], low, high, ui_low, ui_high) for k, low, high, ui_low, ui_high in (
                    ("w0", "Region_4", "Region_1", "UiMin_0", "UiMax_0"), ("w1", "Region_4", "Region_1", "UiMin_0", "UiMax_0"),
                    ("n0", "Region_3", "Region_0", "UiMin_1", "UiMax_1"), ("n1", "Region_3", "Region_0", "UiMin_1", "UiMax_1"))]
            if result is None:
                parent = int(self.ui[map_id]["ParentUiMapID"])
                if parent and parent != map_id:
                    parent_rect = self.rect(parent, root_id, seen)
                    local_rect = self.rect(map_id, parent, seen)
                    if parent_rect and local_rect: result = subrect(parent_rect, local_rect)
        if result and (result[1] <= result[0] or result[3] <= result[2]): result = None
        self._rects[key] = result
        return result

    def is_outdoor(self, map_id):
        """Zone art, plus reviewed orphan art physically on its own continent."""
        row = self.ui[map_id]
        if int(row['Type']) == 3:
            return True
        parent = int(row['ParentUiMapID'])
        if map_id not in self.outdoor_orphans or int(row['Type']) != 6 or parent not in self.ui or int(self.ui[parent]['Type']) != 2:
            return False
        world, continent = self.world(map_id), self.world(parent)
        return bool(world and continent and world['worldID'] == continent['worldID'])

    def descendants(self, root_id):
        result = []
        for map_id, row in self.ui.items():
            parent, seen = int(row["ParentUiMapID"]), {map_id}
            while parent and parent not in seen and parent != root_id:
                seen.add(parent)
                parent = int(self.ui.get(parent, {}).get("ParentUiMapID", 0))
            if parent == root_id and (int(row["Type"]) == 2 or self.is_outdoor(map_id)): result.append(map_id)
        return sorted(result)

    def fixture(self, root_id, selected=None):
        result = {}
        for map_id in [root_id] + (self.descendants(root_id) if selected is None else selected):
            rect = self.rect(map_id, root_id)
            art_id = self.arts.get(map_id)
            if rect is None or art_id is None: continue
            layer = self.layers[self.styles[art_id]]
            cols = math.ceil(int(layer["LayerWidth"])/int(layer["TileWidth"]))
            textures = [int(r["FileDataID"]) for r in sorted(self.tiles[art_id], key=lambda r: int(r["RowIndex"])*cols+int(r["ColIndex"]))]
            result[map_id] = self.info(map_id) | {"artID": art_id, "rect": rect, "textures": textures,
                "layer": {k[0].lower()+k[1:]: int(layer[k]) for k in ("LayerWidth", "LayerHeight", "TileWidth", "TileHeight")}}
            result[map_id].update(self.world(map_id) or {})
        return result

    def texture_ids(self, fixture):
        ids = set()
        for m in fixture.values():
            ids.update(m["textures"])
            for overlay in self.overlays[m["artID"]]: ids.update(int(r["FileDataID"]) for r in self.parts[overlay["ID"]])
        return ids
