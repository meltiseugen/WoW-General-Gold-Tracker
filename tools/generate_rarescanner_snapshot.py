#!/usr/bin/env python3
from __future__ import annotations

import re
from datetime import date
from pathlib import Path
from typing import Any


REPO_ROOT = Path(__file__).resolve().parent.parent
ADDONS_ROOT = REPO_ROOT.parent
RARESCANNER_ROOT = ADDONS_ROOT / "RareScanner"
OUTPUT_PATH = REPO_ROOT / "Data" / "RareDrops.lua"


def read_text(path: Path) -> str:
    return path.read_text(encoding="utf-8-sig", errors="replace")


def lua_string(value: str) -> str:
    chunks: list[str] = ['"']
    for byte in value.encode("utf-8"):
        char = chr(byte)
        if char == "\\":
            chunks.append("\\\\")
        elif char == '"':
            chunks.append('\\"')
        elif 32 <= byte <= 126:
            chunks.append(char)
        else:
            chunks.append(f"\\{byte:03d}")
    chunks.append('"')
    return "".join(chunks)


def parse_rarescanner_version() -> str:
    toc_path = RARESCANNER_ROOT / "RareScanner.toc"
    for line in read_text(toc_path).splitlines():
        match = re.match(r"^##\s*Version:\s*(.+?)\s*$", line)
        if match:
            return match.group(1)
    return "unknown"


def parse_loot_table() -> dict[int, dict[str, Any]]:
    loot_path = RARESCANNER_ROOT / "Tables" / "NpcLootTables.lua"
    rares: dict[int, dict[str, Any]] = {}
    pattern = re.compile(r"^\s*\[(\d+)\]\s*=\s*\{([^}]*)\};\s*--(.*)$")

    for line in read_text(loot_path).splitlines():
        match = pattern.match(line)
        if not match:
            continue

        npc_id = int(match.group(1))
        item_ids = [int(value) for value in re.findall(r"\d+", match.group(2))]
        if not item_ids:
            continue

        rares[npc_id] = {
            "name": match.group(3).strip(),
            "loot": item_ids,
            "locations": [],
        }

    return rares


def parse_info_locations() -> dict[int, list[dict[str, int]]]:
    info_path = RARESCANNER_ROOT / "Tables" / "NpcInfoTables.lua"
    locations_by_npc: dict[int, list[dict[str, int]]] = {}
    current_id: int | None = None
    current_lines: list[str] = []

    def add_location(npc_id: int, map_id: int | None, body: str) -> None:
        if not map_id or map_id <= 0:
            return

        location: dict[str, int] = {"mapID": map_id}
        x_match = re.search(r"\bx\s*=\s*(\d+)", body)
        y_match = re.search(r"\by\s*=\s*(\d+)", body)
        if x_match and y_match:
            location["x"] = int(x_match.group(1))
            location["y"] = int(y_match.group(1))

        existing = locations_by_npc.setdefault(npc_id, [])
        if location not in existing:
            existing.append(location)

    def flush_entry() -> None:
        if current_id is None or not current_lines:
            return

        body = "\n".join(current_lines)
        if re.search(r"\bzoneID\s*=\s*\{", body):
            for line in current_lines:
                sub_match = re.search(r"\[(\d+)\]\s*=\s*\{(.*)\};", line)
                if sub_match:
                    add_location(current_id, int(sub_match.group(1)), sub_match.group(2))
        else:
            zone_match = re.search(r"\bzoneID\s*=\s*(\d+)", body)
            if zone_match:
                add_location(current_id, int(zone_match.group(1)), body)

    for line in read_text(info_path).splitlines():
        start_match = re.match(r"^\s*\[(\d+)\]\s*=\s*\{", line)
        if start_match and current_id is None:
            current_id = int(start_match.group(1))
            current_lines = [line]
            if "}; --" in line:
                flush_entry()
                current_id = None
                current_lines = []
            continue

        if current_id is not None:
            current_lines.append(line)
            if "}; --" in line:
                flush_entry()
                current_id = None
                current_lines = []

    return locations_by_npc


def parse_map_entity_locations() -> dict[int, list[dict[str, int]]]:
    map_path = RARESCANNER_ROOT / "Tables" / "MapEntitiesTables.lua"
    locations_by_npc: dict[int, list[dict[str, int]]] = {}
    current_map_id: int | None = None

    for line in read_text(map_path).splitlines():
        map_match = re.match(r"^\t\[(\d+)\]\s*=\s*\{$", line)
        if map_match:
            current_map_id = int(map_match.group(1))
            continue

        if current_map_id is None:
            continue

        npc_match = re.match(r"^\t\t\t\[1\]\s*=\s*\{([^}]*)\};", line)
        if not npc_match:
            continue

        for npc_id in [int(value) for value in re.findall(r"\d+", npc_match.group(1))]:
            location = {"mapID": current_map_id}
            existing = locations_by_npc.setdefault(npc_id, [])
            if location not in existing:
                existing.append(location)

    return locations_by_npc


def parse_expansion_filters() -> dict[str, Any]:
    zone_path = RARESCANNER_ROOT / "Tables" / "ZoneTables.lua"
    options: list[dict[str, Any]] = []
    map_to_expansion_id: dict[int, int] = {}
    current_id: int | None = None
    pattern = re.compile(r"^\s*\[(\d+)\]\s*=\s*\{(.+)\};\s*--(.+)$")

    for line in read_text(zone_path).splitlines():
        match = pattern.match(line)
        if not match:
            continue

        continent_map_id = int(match.group(1))
        body = match.group(2)
        label = match.group(3).strip()
        id_match = re.search(r"\bid\s*=\s*(\d+)", body)
        zones_match = re.search(r"\bzones\s*=\s*\{([^}]*)\}", body)
        if not id_match or not zones_match:
            continue

        expansion_id = int(id_match.group(1))
        zones = [int(value) for value in re.findall(r"\d+", zones_match.group(1))]
        if not zones:
            continue

        is_current = re.search(r"\bcurrent\s*=\s*\{", body) is not None
        if is_current and (current_id is None or expansion_id > current_id):
            current_id = expansion_id

        options.append({
            "id": expansion_id,
            "label": label,
            "continentMapID": continent_map_id,
            "zones": zones,
            "current": is_current,
        })
        map_to_expansion_id[continent_map_id] = expansion_id
        for zone_id in zones:
            map_to_expansion_id[zone_id] = expansion_id

    return {
        "currentID": current_id,
        "options": options,
        "mapToExpansionID": map_to_expansion_id,
    }


def write_snapshot() -> None:
    if not RARESCANNER_ROOT.is_dir():
        raise SystemExit(f"Could not find sibling RareScanner addon at {RARESCANNER_ROOT}.")

    version = parse_rarescanner_version()
    rares = parse_loot_table()
    info_locations = parse_info_locations()
    map_entity_locations = parse_map_entity_locations()
    expansion_filters = parse_expansion_filters()

    total_drops = 0
    for npc_id, rare in rares.items():
        locations = info_locations.get(npc_id)
        if not locations:
            locations = map_entity_locations.get(npc_id, [])
        rare["locations"] = locations
        total_drops += len(rare["loot"])

    OUTPUT_PATH.parent.mkdir(parents=True, exist_ok=True)
    with OUTPUT_PATH.open("w", encoding="utf-8", newline="\n") as handle:
        handle.write("local _, NS = ...\n\n")
        handle.write("-- Generated by tools/generate_rarescanner_snapshot.py from the installed RareScanner addon.\n")
        handle.write("-- Re-run the generator after updating RareScanner to refresh this snapshot.\n")
        handle.write("NS.RareDropsData = {\n")
        handle.write('    source = "RareScanner",\n')
        handle.write(f"    sourceVersion = {lua_string(version)},\n")
        handle.write(f"    generatedAt = {lua_string(date.today().isoformat())},\n")
        handle.write(f"    rareCount = {len(rares)},\n")
        handle.write(f"    itemDropCount = {total_drops},\n")
        handle.write("    expansions = {\n")
        current_id = expansion_filters["currentID"]
        handle.write(f"        currentID = {current_id if current_id is not None else 'nil'},\n")
        handle.write("        options = {\n")
        for expansion in sorted(expansion_filters["options"], key=lambda item: int(item["id"])):
            handle.write(
                f"            {{ id = {expansion['id']}, "
                f"label = {lua_string(str(expansion['label']))}, "
                f"continentMapID = {expansion['continentMapID']}, "
                f"current = {'true' if expansion['current'] else 'false'}, "
                "zones = {"
            )
            for zone_id in expansion["zones"]:
                handle.write(f" {zone_id},")
            handle.write(" } },\n")
        handle.write("        },\n")
        handle.write("        mapToExpansionID = {\n")
        for map_id in sorted(expansion_filters["mapToExpansionID"]):
            handle.write(f"            [{map_id}] = {expansion_filters['mapToExpansionID'][map_id]},\n")
        handle.write("        },\n")
        handle.write("    },\n")
        handle.write("    rares = {\n")

        for npc_id in sorted(rares):
            rare = rares[npc_id]
            handle.write(f"        [{npc_id}] = {{ name = {lua_string(str(rare['name']))}, ")
            handle.write("locations = {")
            for location in rare["locations"]:
                map_id = location.get("mapID")
                x = location.get("x")
                y = location.get("y")
                if x is not None and y is not None:
                    handle.write(f" {{ mapID = {map_id}, x = {x}, y = {y} }},")
                else:
                    handle.write(f" {{ mapID = {map_id} }},")
            handle.write(" }, loot = {")
            for item_id in rare["loot"]:
                handle.write(f" {item_id},")
            handle.write(" } },\n")

        handle.write("    },\n")
        handle.write("}\n")

    print(f"Wrote {OUTPUT_PATH.relative_to(REPO_ROOT)}")
    print(f"RareScanner {version}: {len(rares)} rares, {total_drops} item drops")


if __name__ == "__main__":
    write_snapshot()
