#!/usr/bin/env python3
"""Generate GGT's static Gathering-route and Drops catalog snapshots.

The generator intentionally implements only the small Lua-data subset used by the
source enum, route, farm, Gathering, Transmog, Mounts, Toys, and Pets files. It
has no third-party dependencies.
"""

from __future__ import annotations

import argparse
import base64
import math
import re
from dataclasses import dataclass
from pathlib import Path
from typing import Any

from catalog_exclusions import excluded_product


GATHERING_MODULES = {
    "Mining": "Mining",
    "Herb": "Herb",
    "Fishing": "Fishing",
    "Skinning": "Skinning",
    "Cloth": "Cloth",
    "Misc": "Misc",
    "MultiFarms": "MultiFarms",
}

DROP_MODULES = {
    "transmogs": [
        ("Modules/retail/Transmog/VanillaTransmogModule.lua", "VanillaTransmog.lua"),
    ],
    "openWorldInstances": [
        ("Modules/retail/Transmog/OpenWorldTransmog.lua", "VanillaTransmog.lua"),
    ],
    "mounts": [
        ("Modules/retail/Farming/MountsModule.lua", "Mounts.lua"),
    ],
    "toys": [
        ("Modules/retail/Farming/ToysModule.lua", "Toys.lua"),
    ],
    "pets": [
        # Raid pets have their own Instances > Pets category below. Keeping the
        # raid module out of this list prevents duplicate rows and map options.
        ("Modules/retail/BattlePets/OpenWorldBattlePetModule.lua", "OpenWorldPets.lua"),
        ("Modules/retail/BattlePets/RareBattlePetModule.lua", "RareBattlePets.lua"),
    ],
    "raidPets": [
        ("Modules/retail/BattlePets/RaidBattlePetModule.lua", "BattlePets.lua"),
    ],
}

DROP_CATEGORY_ORDER = ("transmogs", "openWorldInstances", "mounts", "toys", "pets", "raidPets", "recipes", "cosmetics")

# The first Farms catalog contains repeatable gold farms. Collectibles remain
# in their dedicated static catalogs until Farms supports attempts and lockouts.
FARM_CATALOG_DROP_CATEGORIES = ("transmogs", "openWorldInstances")

FARM_CATALOG_DROP_CATEGORY_METADATA = {
    "transmogs": {
        "source_category": "instances",
        "source_path": "Instances",
    },
    "openWorldInstances": {
        "source_category": "openWorldInstances",
        "source_path": "Open World > Instances",
    },
}

FARM_CATALOG_ACTIVITIES = {
    "Mining": "mining",
    "Herb": "herbalism",
    "Fishing": "fishing",
    "Skinning": "skinning",
    "Cloth": "cloth",
    "Misc": "miscellaneous",
    "MultiFarms": "multi-farm",
    "transmogs": "transmog",
    "openWorldInstances": "transmog",
}

ACTIVITIES = {
    "core.Activity.Mining": 1,
    "core.Activity.Herbalism": 2,
    "core.Activity.Skinning": 3,
    "core.Activity.Fishing": 4,
    "core.Activity.Cloth": 5,
    "core.Activity.Misc": 7,
    "core.Activity.MultiFarms": 12,
}

CONTENTS = {
    "core.Content.Vanilla": 1,
    "core.Content.TBC": 2,
    "core.Content.WotLK": 3,
    "core.Content.Cata": 4,
    "core.Content.MoP": 5,
    "core.Content.WoD": 6,
    "core.Content.Legion": 7,
    "core.Content.BFA": 8,
    "core.Content.Shadowlands": 9,
    "core.Content.Dragonflight": 10,
    "core.Content.TheWarWithin": 11,
    "core.Content.Midnight": 12,
    # The source Toys data contains this legacy spelling.
    "core.Content.Wotlk": 3,
}

EXPANSIONS = {
    1: "classic",
    2: "burningCrusade",
    3: "wrath",
    4: "cataclysm",
    5: "mists",
    6: "warlords",
    7: "legion",
    8: "battleForAzeroth",
    9: "shadowlands",
    10: "dragonflight",
    11: "warWithin",
    12: "midnight",
}

EXPANSION_LABELS = {
    1: "Classic",
    2: "The Burning Crusade",
    3: "Wrath of the Lich King",
    4: "Cataclysm",
    5: "Mists of Pandaria",
    6: "Warlords of Draenor",
    7: "Legion",
    8: "Battle for Azeroth",
    9: "Shadowlands",
    10: "Dragonflight",
    11: "The War Within",
    12: "Midnight",
}

MODULE_PROFESSIONS = {
    "Mining": ["mining"],
    "Herb": ["herbalism"],
    "Fishing": ["fishing"],
    "Skinning": ["skinning"],
    "Cloth": ["tailoring"],
    "Misc": ["miscellaneous"],
    "MultiFarms": ["mining", "herbalism"],
}

MODULE_TAGS = {
    "Mining": "Ore",
    "Herb": "Herb",
    "Fishing": "Fish",
    "Skinning": "Skinning",
    "Cloth": "Cloth",
    "Misc": "Miscellaneous",
    "MultiFarms": "Multi-farm",
}


@dataclass(frozen=True)
class Ref:
    path: str


class LuaTable:
    def __init__(self) -> None:
        self.values: dict[Any, Any] = {}
        self.next_index = 1

    def append(self, value: Any) -> None:
        while self.next_index in self.values:
            self.next_index += 1
        self.values[self.next_index] = value
        self.next_index += 1

    def set(self, key: Any, value: Any) -> None:
        self.values[key] = value
        if isinstance(key, int) and key >= self.next_index:
            self.next_index = key + 1

    def get(self, key: Any, default: Any = None) -> Any:
        return self.values.get(key, default)

    def array(self) -> list[Any]:
        return [self.values[key] for key in sorted(k for k in self.values if isinstance(k, int))]


@dataclass
class Token:
    kind: str
    value: Any
    position: int


def lex_lua(text: str) -> list[Token]:
    tokens: list[Token] = []
    i = 0
    length = len(text)
    number_re = re.compile(r"(?:0[xX][0-9A-Fa-f]+|(?:\d+\.\d*|\.\d+|\d+)(?:[eE][+-]?\d+)?)")

    while i < length:
        char = text[i]
        if char.isspace():
            i += 1
            continue
        if text.startswith("--[[", i):
            end = text.find("]]", i + 4)
            i = length if end < 0 else end + 2
            continue
        if text.startswith("--", i):
            end = text.find("\n", i + 2)
            i = length if end < 0 else end + 1
            continue
        if char in "'\"":
            quote = char
            start = i
            i += 1
            out: list[str] = []
            while i < length:
                char = text[i]
                if char == quote:
                    i += 1
                    break
                if char != "\\":
                    out.append(char)
                    i += 1
                    continue
                i += 1
                if i >= length:
                    raise ValueError(f"unterminated escape at {start}")
                escaped = text[i]
                translations = {"n": "\n", "r": "\r", "t": "\t", "\\": "\\", "\"": "\"", "'": "'"}
                if escaped.isdigit():
                    match = re.match(r"\d{1,3}", text[i:])
                    assert match
                    out.append(chr(int(match.group(0))))
                    i += len(match.group(0))
                else:
                    out.append(translations.get(escaped, escaped))
                    i += 1
            else:
                raise ValueError(f"unterminated string at {start}")
            tokens.append(Token("string", "".join(out), start))
            continue
        match = number_re.match(text, i)
        if match:
            raw = match.group(0)
            if raw.lower().startswith("0x"):
                value: int | float = int(raw, 16)
            elif any(mark in raw for mark in ".eE"):
                value = float(raw)
            else:
                value = int(raw)
            tokens.append(Token("number", value, i))
            i = match.end()
            continue
        if char.isalpha() or char == "_":
            start = i
            i += 1
            while i < length and (text[i].isalnum() or text[i] == "_"):
                i += 1
            tokens.append(Token("ident", text[start:i], start))
            continue
        if text.startswith("...", i):
            tokens.append(Token("symbol", "...", i))
            i += 3
            continue
        if text.startswith("..", i):
            tokens.append(Token("symbol", "..", i))
            i += 2
            continue
        tokens.append(Token("symbol", char, i))
        i += 1

    return tokens


class LuaParser:
    def __init__(self, tokens: list[Token]) -> None:
        self.tokens = tokens

    def parse_value(self, index: int) -> tuple[Any, int]:
        value, index = self._parse_atom(index)
        while index < len(self.tokens) and self.tokens[index].value in {"+", "-", "*", "/", ".."}:
            operator = self.tokens[index].value
            right, next_index = self._parse_atom(index + 1)
            if isinstance(value, (int, float)) and isinstance(right, (int, float)):
                value = {"+": value + right, "-": value - right, "*": value * right, "/": value / right}.get(operator, value)
            elif operator == "..":
                value = str(value) + str(right)
            else:
                value = Ref(f"{value}{operator}{right}")
            index = next_index
        return value, index

    def _parse_atom(self, index: int) -> tuple[Any, int]:
        if index >= len(self.tokens):
            raise ValueError("unexpected end of Lua expression")
        token = self.tokens[index]
        if token.value == "-":
            value, index = self._parse_atom(index + 1)
            return -value, index
        if token.value == "(":
            value, index = self.parse_value(index + 1)
            if self.tokens[index].value != ")":
                raise ValueError(f"expected ')' near {self.tokens[index].position}")
            return value, index + 1
        if token.value == "{":
            return self._parse_table(index)
        if token.kind in {"number", "string"}:
            return token.value, index + 1
        if token.kind == "ident":
            if token.value == "true":
                return True, index + 1
            if token.value == "false":
                return False, index + 1
            if token.value == "nil":
                return None, index + 1
            parts = [token.value]
            index += 1
            while index + 1 < len(self.tokens) and self.tokens[index].value == "." and self.tokens[index + 1].kind == "ident":
                parts.append(self.tokens[index + 1].value)
                index += 2
            return Ref(".".join(parts)), index
        raise ValueError(f"unsupported Lua value {token.value!r} near {token.position}")

    def _parse_table(self, index: int) -> tuple[LuaTable, int]:
        table = LuaTable()
        index += 1
        while index < len(self.tokens):
            token = self.tokens[index]
            if token.value == "}":
                return table, index + 1
            if token.value in {",", ";"}:
                index += 1
                continue
            if token.value == "[":
                key, index = self.parse_value(index + 1)
                if self.tokens[index].value != "]" or self.tokens[index + 1].value != "=":
                    raise ValueError(f"invalid keyed table field near {token.position}")
                value, index = self.parse_value(index + 2)
                table.set(key, value)
                continue
            if token.kind == "ident" and index + 1 < len(self.tokens) and self.tokens[index + 1].value == "=":
                value, index = self.parse_value(index + 2)
                table.set(token.value, value)
                continue
            value, index = self.parse_value(index)
            table.append(value)
        raise ValueError("unterminated Lua table")


def parse_core_assignments(path: Path) -> list[tuple[str, Any]]:
    tokens = lex_lua(path.read_text(encoding="utf-8-sig"))
    parser = LuaParser(tokens)
    assignments: list[tuple[str, Any]] = []
    index = 0
    while index < len(tokens):
        if tokens[index].kind != "ident" or tokens[index].value != "core":
            index += 1
            continue
        parts = ["core"]
        cursor = index + 1
        while cursor + 1 < len(tokens) and tokens[cursor].value == "." and tokens[cursor + 1].kind == "ident":
            parts.append(tokens[cursor + 1].value)
            cursor += 2
        if cursor < len(tokens) and tokens[cursor].value == "=" and len(parts) > 1:
            value, cursor = parser.parse_value(cursor + 1)
            assignments.append((".".join(parts), value))
            index = cursor
        else:
            index += 1
    return assignments


def flatten_assignment(path: str, value: Any, environment: dict[str, Any]) -> None:
    environment[path] = value
    if isinstance(value, LuaTable):
        for key, child in value.values.items():
            if isinstance(key, str):
                flatten_assignment(f"{path}.{key}", child, environment)


def resolve(value: Any, environment: dict[str, Any]) -> Any:
    seen: set[str] = set()
    while isinstance(value, Ref) and value.path not in seen:
        seen.add(value.path)
        replacement = environment.get(value.path)
        if replacement is None:
            return value
        value = replacement
    return value


class LibSerializeReader:
    def __init__(self, payload: bytes) -> None:
        self.text = payload.decode("latin1")
        self.index = 0

    def read(self) -> Any:
        if self.text.startswith("^1", self.index):
            self.index += 2
        return self._value()

    def _until_marker(self) -> str:
        end = self.text.find("^", self.index)
        if end < 0:
            end = len(self.text)
        value = self.text[self.index:end]
        self.index = end
        return value

    def _value(self) -> Any:
        if self.index >= len(self.text) or self.text[self.index] != "^":
            raise ValueError(f"expected LibSerialize marker at {self.index}")
        marker = self.text[self.index + 1]
        self.index += 2
        if marker == "T":
            table: dict[Any, Any] = {}
            while not self.text.startswith("^t", self.index):
                key = self._value()
                table[key] = self._value()
            self.index += 2
            return table
        if marker == "S":
            return self._until_marker()
        if marker == "N":
            raw = self._until_marker()
            return int(raw) if re.fullmatch(r"-?\d+", raw) else float(raw)
        if marker == "F":
            mantissa = float(self._until_marker())
            if not self.text.startswith("^f", self.index):
                return mantissa
            self.index += 2
            exponent = int(self._until_marker())
            return math.ldexp(mantissa, exponent)
        if marker == "B":
            return True
        if marker == "b":
            return False
        if marker == "Z":
            return None
        raise ValueError(f"unsupported LibSerialize marker ^{marker} at {self.index - 2}")


def decode_import_route(encoded: str) -> dict[str, Any]:
    if ":" in encoded:
        encoded = encoded.rsplit(":", 1)[-1]
    payload = base64.b64decode(encoded)
    try:
        data = LibSerializeReader(payload).read()
    except ValueError:
        # A few v4.3.1 legacy payloads are malformed after their useful route
        # fields. Recover the complete name, zone, and route table from the
        # valid prefix instead of discarding those farms.
        decoded = payload.decode("latin1")
        route_match = re.search(r"\^Sroute\^T(.*?)\^t\^Sdb_type", decoded, re.DOTALL)
        name_match = re.search(r"\^SRouteName\^S(.*?)\^SRouteZone", decoded, re.DOTALL)
        zone_match = re.search(r"\^SRouteZone\^N(\d+)", decoded)
        if not route_match or not name_match or not zone_match:
            raise
        pairs = re.findall(r"\^N\d+\^N(\d+)", route_match.group(1))
        return {
            "name": name_match.group(1),
            "map_id": int(zone_match.group(1)),
            "points": [int(value) for value in pairs],
            "format": "catalog-import-string-recovered",
        }
    if not isinstance(data, dict):
        raise ValueError("route import did not decode to a table")
    route_data = data.get("RouteData")
    points = route_data.get("route") if isinstance(route_data, dict) else None
    return {
        "name": data.get("RouteName"),
        "map_id": data.get("RouteZone"),
        "points": numeric_table_values(points),
        "format": "catalog-import-string",
    }


def numeric_table_values(value: Any) -> list[Any]:
    if isinstance(value, LuaTable):
        return value.array()
    if isinstance(value, dict):
        return [value[key] for key in sorted(k for k in value if isinstance(k, (int, float)))]
    return []


def pretty_identifier(value: str) -> str:
    value = value.replace("_", " ").replace("~`", " ")
    value = re.sub(r"^Catalog\s*-\s*", "", value, flags=re.IGNORECASE)
    value = re.sub(r"^Route(?=[A-Z0-9])", "", value)
    value = re.sub(r"(?<=[a-z0-9])(?=[A-Z])", " ", value)
    value = re.sub(r"(?<=[A-Z])(?=[A-Z][a-z])", " ", value)
    return re.sub(r"\s+", " ", value).strip() or "Unnamed route"


def lua_quote(value: str) -> str:
    escaped = value.replace("\\", "\\\\").replace('"', '\\"')
    escaped = escaped.replace("\n", "\\n").replace("\r", "\\r").replace("\t", "\\t")
    return f'"{escaped}"'


def lua_number(value: int | float | None) -> str:
    if value is None:
        return "nil"
    if isinstance(value, int) or float(value).is_integer():
        return str(int(value))
    return format(float(value), ".12g")


def stable_slug(value: str) -> str:
    return re.sub(r"[^a-z0-9]+", "-", value.lower()).strip("-")


def unique_values(values: list[Any]) -> list[Any]:
    output: list[Any] = []
    seen: set[Any] = set()
    for value in values:
        if value in seen:
            continue
        seen.add(value)
        output.append(value)
    return output


def resolved_number(value: Any, environment: dict[str, Any], context: str, required: bool = False) -> int | float | None:
    value = resolve(value, environment)
    if value is None and not required:
        return None
    if not isinstance(value, (int, float)):
        raise ValueError(f"unresolved numeric value for {context}: {value!r}")
    return value


def route_from_static(ref: Ref, routes: dict[str, LuaTable], environment: dict[str, Any]) -> dict[str, Any]:
    route = routes.get(ref.path)
    if not route:
        raise ValueError(f"missing Catalog static route {ref.path}")
    data = route.get("Data")
    points = data.get("route") if isinstance(data, LuaTable) else None
    return {
        "name": route.get("Name") or ref.path.rsplit(".", 1)[-1],
        "map_id": resolved_number(route.get("MapId"), environment, f"{ref.path}.MapId", True),
        "points": numeric_table_values(points),
        "format": "catalog-static-table",
        "source_ref": ref.path,
    }


def route_from_embedded(route: LuaTable, environment: dict[str, Any], context: str) -> dict[str, Any]:
    data = route.get("RouteData")
    points = data.get("route") if isinstance(data, LuaTable) else None
    return {
        "name": route.get("RouteName") or context,
        "map_id": resolved_number(route.get("RouteZone"), environment, f"{context}.RouteZone", True),
        "points": numeric_table_values(points),
        "format": "catalog-embedded-table",
    }


def extract_routes(value: Any, routes: dict[str, LuaTable], environment: dict[str, Any], context: str) -> list[dict[str, Any]]:
    if isinstance(value, str):
        try:
            return [decode_import_route(value)]
        except Exception as error:
            raise ValueError(f"could not decode route import for {context}: {error}") from error
    if not isinstance(value, LuaTable):
        return []
    extracted: list[dict[str, Any]] = []
    for index, entry in enumerate(value.array(), 1):
        if isinstance(entry, Ref):
            extracted.append(route_from_static(entry, routes, environment))
        elif isinstance(entry, LuaTable):
            extracted.append(route_from_embedded(entry, environment, f"{context} route {index}"))
        elif isinstance(entry, str):
            try:
                extracted.append(decode_import_route(entry))
            except Exception as error:
                raise ValueError(f"could not decode route import for {context} entry {index}: {error}") from error
        else:
            raise ValueError(f"unsupported route entry for {context}: {entry!r}")
    return extracted


def extract_module_farm_keys(path: Path) -> list[str]:
    """Return active farm references from a module, excluding commented entries."""
    tokens = lex_lua(path.read_text(encoding="utf-8-sig"))
    prefix = ["core", ".", "Data", ".", "Results", ".", "Farms", "."]
    keys: list[str] = []
    for index in range(0, len(tokens) - len(prefix)):
        if [token.value for token in tokens[index:index + len(prefix)]] != prefix:
            continue
        key = tokens[index + len(prefix)]
        if key.kind == "ident":
            keys.append(str(key.value))
    return keys


def extract_result_rows(value: Any, environment: dict[str, Any], context: str) -> list[dict[str, Any]]:
    rows: list[dict[str, Any]] = []
    if not isinstance(value, LuaTable):
        return rows
    for result_index, result in enumerate(value.array(), 1):
        if not isinstance(result, LuaTable):
            raise ValueError(f"invalid result {result_index} in {context}")
        item_id = resolved_number(result.get("Id"), environment, f"{context}[{result_index}].Id", True)
        quantity = resolved_number(result.get("Quantity"), environment, f"{context}[{result_index}].Quantity")
        pet_id = resolved_number(result.get("PetId"), environment, f"{context}[{result_index}].PetId")
        item_link = resolve(result.get("ItemLink"), environment)
        rows.append({
            "item_id": int(item_id),
            "quantity": quantity if quantity is not None else 1,
            "pet_id": int(pet_id) if pet_id is not None else None,
            "item_link": item_link if isinstance(item_link, str) else None,
        })
    return rows


def get_location(table: LuaTable, environment: dict[str, Any], farm_key: str) -> tuple[int | None, str]:
    locations = table.get("Locations")
    if isinstance(locations, LuaTable) and locations.array():
        location = locations.array()[0]
        location_id = resolved_number(location, environment, f"{farm_key}.Locations[1]")
        if isinstance(location, Ref):
            return (int(location_id) if location_id is not None else None, pretty_identifier(location.path.rsplit(".", 1)[-1]))
        return (int(location_id) if location_id is not None else None, pretty_identifier(farm_key))

    map_id = resolved_number(table.get("MapId"), environment, f"{farm_key}.MapId")
    name_map = table.get("NameMapId")
    name_map_id = resolved_number(name_map, environment, f"{farm_key}.NameMapId")
    if map_id is None:
        map_id = name_map_id
    name = table.get("Name")
    if not isinstance(name, str) and isinstance(name_map, Ref):
        name = pretty_identifier(name_map.path.rsplit(".", 1)[-1])
    return (int(map_id) if map_id is not None else None, str(name or pretty_identifier(farm_key)))


def emit_drops_snapshot(categories: dict[str, list[dict[str, Any]]], source_version: str) -> str:
    categories = {key: [row for row in rows if not excluded_product(row)]
                  for key, rows in categories.items()}
    total = sum(len(rows) for rows in categories.values())
    lines = [
        "local _, NS = ...",
        "",
        "-- Generated by tools/generate_farm_catalog_snapshot.py. Do not hand-edit.",
        "-- Bundled GGT item-source catalog snapshot.",
        "",
        "local categories = {",
    ]
    for category in DROP_CATEGORY_ORDER:
        lines.append(f"    {category} = {{")
        for row in categories.get(category, []):
            fields = [
                f"recordID = {lua_quote(row['record_id'])}",
                f"farmID = {lua_quote(row['farm_id'])}",
                f"farmName = {lua_quote(row['farm_name'])}",
                f"itemID = {lua_number(row['item_id'])}",
                f"itemLink = {lua_quote(row['item_link']) if row.get('item_link') else 'nil'}",
                f"petID = {lua_number(row.get('pet_id'))}",
                f"quantity = {lua_number(row['quantity'])}",
                f"contentID = {lua_number(row['content_id'])}",
                f"expansion = {lua_quote(row['expansion'])}",
                f"expansionLabel = {lua_quote(row['expansion_label'])}",
                f"locationID = {lua_number(row.get('location_id'))}",
                f"locationLabel = {lua_quote(row['location_label'])}",
            ]
            lines.append("        { " + ", ".join(fields) + " },")
        lines.append("    },")
    lines.extend([
        "}",
        "",
        "NS.CatalogDropsData = {",
        "    dataVersion = 1,",
        f"    sourceVersion = {lua_quote(source_version)},",
        f"    itemSourceCount = {total},",
        "    categoryCounts = {",
    ])
    for category in DROP_CATEGORY_ORDER:
        lines.append(f"        {category} = {len(categories.get(category, []))},")
    lines.extend([
        "    },",
        "    categories = categories,",
        "}",
        "",
    ])
    return "\n".join(lines)


def read_source_version(source_root: Path) -> str:
    toc_files = sorted(source_root.glob("*.toc"))
    if not toc_files:
        raise FileNotFoundError(f"no addon TOC found under {source_root}")
    toc = toc_files[0].read_text(encoding="utf-8-sig")
    version_match = re.search(r"^##\s*Version:\s*(.+?)\s*$", toc, re.MULTILINE)
    return version_match.group(1) if version_match else "unknown"


def build_drops_snapshot(source_root: Path) -> tuple[dict[str, list[dict[str, Any]]], str]:
    source_version = read_source_version(source_root)

    environment: dict[str, Any] = {**ACTIVITIES, **CONTENTS}
    for enum_file in sorted((source_root / "Enums").rglob("*.lua")):
        for path, value in parse_core_assignments(enum_file):
            flatten_assignment(path, value, environment)

    farms_root = source_root / "Data" / "retail" / "Results" / "Farms"
    # Recipes.lua and Cosmetics.lua supply curated products after this snapshot.
    categories: dict[str, list[dict[str, Any]]] = {category: [] for category in DROP_CATEGORY_ORDER}
    missing_farm_refs: list[str] = []
    for category, sources in DROP_MODULES.items():
        for module_relative_path, farm_filename in sources:
            farm_definitions: dict[str, LuaTable] = {}
            for path, value in parse_core_assignments(farms_root / farm_filename):
                prefix = "core.Data.Results.Farms."
                if path.startswith(prefix) and isinstance(value, LuaTable):
                    farm_definitions[path[len(prefix):]] = value

            module_path = source_root / Path(module_relative_path)
            for farm_key in extract_module_farm_keys(module_path):
                table = farm_definitions.get(farm_key)
                if not table:
                    missing_farm_refs.append(f"{module_path.name}:{farm_key}")
                    continue

                content_id = resolved_number(table.get("Content"), environment, f"{farm_key}.Content") or 1
                activity_id = resolved_number(table.get("Activity"), environment, f"{farm_key}.Activity")
                seconds = resolved_number(table.get("Time"), environment, f"{farm_key}.Time")
                money = resolved_number(table.get("Money"), environment, f"{farm_key}.Money")
                farm_id = str(table.get("Id") or farm_key)
                farm_name = str(table.get("Name") or pretty_identifier(farm_key))
                location_id, location_label = get_location(table, environment, farm_key)
                if category in {"transmogs", "openWorldInstances"}:
                    instance_map_id = resolved_number(table.get("MapId"), environment, f"{farm_key}.MapId")
                    if instance_map_id is None:
                        instance_map_id = resolved_number(table.get("NameMapId"), environment, f"{farm_key}.NameMapId")
                    if instance_map_id is not None:
                        location_id = int(instance_map_id)
                        location_label = farm_name
                results_value = (
                    table.get("ItemsOfNote")
                    if category in {"transmogs", "openWorldInstances"} and table.get("ItemsOfNote")
                    else table.get("Results")
                )
                results = extract_result_rows(results_value, environment, f"{farm_key}.Results")

                if category in {"mounts", "toys"}:
                    primary_item_id = resolved_number(table.get("ItemId"), environment, f"{farm_key}.ItemId", True)
                    results = [result for result in results if result["item_id"] == int(primary_item_id)]
                elif category == "raidPets":
                    # The Raid Pets module also includes three full raid-farm result
                    # tables. Only battle-pet result rows belong in this subcategory.
                    results = [result for result in results if result.get("pet_id") is not None]

                for result_index, result in enumerate(results, 1):
                    categories[category].append({
                        "record_id": f"{category}:{farm_key}:{result_index}",
                        "provider_key": farm_key,
                        "farm_id": farm_id,
                        "farm_name": farm_name,
                        "item_id": result["item_id"],
                        "item_link": result.get("item_link"),
                        "pet_id": result.get("pet_id"),
                        "quantity": result["quantity"],
                        "content_id": int(content_id),
                        "activity_id": int(activity_id) if activity_id is not None else None,
                        "expansion": EXPANSIONS.get(int(content_id), "classic"),
                        "expansion_label": EXPANSION_LABELS.get(int(content_id), f"Expansion {int(content_id)}"),
                        "location_id": location_id,
                        "location_label": location_label,
                        "seconds": seconds,
                        "money": money,
                    })

    # GGT's curated toy additions are retained alongside the upstream snapshot.
    if not any(row["item_id"] == 108739 for row in categories["toys"]):
        categories["toys"].append({
            "record_id": "toys:PrettyDraenorPearl:1",
            "farm_id": "PrettyDraenorPearl",
            "farm_name": "Pretty Draenor Pearl",
            "item_id": 108739,
            "quantity": 1,
            "content_id": 6,
            "expansion": "warlords",
            "expansion_label": "Warlords of Draenor",
            "location_id": None,
            "location_label": "Frostfire Ridge",
        })

    if missing_farm_refs:
        print("Skipped undefined drop farm references: " + ", ".join(missing_farm_refs))
    return categories, source_version


def emit_snapshot(farms: list[dict[str, Any]], source_version: str) -> str:
    farms = [{**farm, "results": [row for row in farm["results"] if not excluded_product(row)]}
             for farm in farms if not excluded_product(farm)]
    route_count = sum(len(farm["routes"]) for farm in farms)
    point_count = sum(len(route["points"]) for farm in farms for route in farm["routes"])
    lines = [
        "local _, NS = ...",
        "",
        "-- Generated by tools/generate_farm_catalog_snapshot.py. Do not hand-edit.",
        "-- Bundled GGT gathering-route catalog snapshot.",
        "",
        "local function C(x, y, index)",
        "    return { x = x, y = y, label = \"Route point \" .. tostring(index) }",
        "end",
        "",
        "local farms = {",
    ]

    for farm in farms:
        lines.extend([
            "    {",
            f"        recordID = {lua_quote(farm['record_id'])},",
            f"        farmID = {lua_quote(farm['farm_id'])},",
            f"        category = {lua_quote(farm['category'])},",
            f"        activityID = {lua_number(farm['activity_id'])},",
            f"        contentID = {lua_number(farm['content_id'])},",
            f"        expansion = {lua_quote(farm['expansion'])},",
            f"        name = {lua_quote(farm['name'])},",
            f"        itemID = {lua_number(farm['item_id'])},",
            f"        itemIDInferred = {'true' if farm['item_inferred'] else 'false'},",
            f"        recordedSeconds = {lua_number(farm['seconds'])},",
            f"        durationInferred = {'true' if farm['seconds_inferred'] else 'false'},",
            f"        rawCopper = {lua_number(farm['money'])},",
            "        results = {",
        ])
        for result in farm["results"]:
            extra = ""
            if result.get("pet_id") is not None:
                extra += f", petID = {lua_number(result['pet_id'])}"
            if result.get("sell_to_vendor") is not None:
                extra += f", sellToVendor = {'true' if result['sell_to_vendor'] else 'false'}"
            lines.append(f"            {{ itemID = {result['item_id']}, quantity = {lua_number(result['quantity'])}{extra} }},")
        lines.append("        },")
        lines.append("        routes = {")
        for route in farm["routes"]:
            lines.extend([
                "            {",
                f"                name = {lua_quote(route['name'])},",
                f"                mapID = {route['map_id']},",
                f"                mapName = {lua_quote(route['map_name'])},",
                f"                format = {lua_quote(route['format'])},",
                "                coords = {",
            ])
            for index, packed in enumerate(route["points"], 1):
                packed = int(packed)
                x = packed // 10000 / 10000
                y = packed % 10000 / 10000
                lines.append(f"                    C({x:.4f}, {y:.4f}, {index}),")
            lines.extend(["                },", "            },"])
        lines.extend(["        },", "    },"])

    lines.extend([
        "}",
        "",
        "local farmsByRecordID = {}",
        "for _, farm in ipairs(farms) do",
        "    farmsByRecordID[farm.recordID] = farm",
        "end",
        "",
        "NS.CatalogGatheringData = {",
        f"    dataVersion = 1,",
        f"    sourceVersion = {lua_quote(source_version)},",
        f"    farmCount = {len(farms)},",
        f"    routeCount = {route_count},",
        f"    pointCount = {point_count},",
        "    farms = farms,",
        "    farmsByRecordID = farmsByRecordID,",
        "}",
        "",
        "local materialItems = NS.MaterialFarmingSpots and NS.MaterialFarmingSpots.items",
        "if type(materialItems) ~= \"table\" then",
        "    return",
        "end",
        "",
        "local farmingCatalog = NS.FarmingItems and NS.FarmingItems.items",
        "local dropsOnlyItemIDs = NS.FarmingItems and NS.FarmingItems.dropsOnlyItemIDs or {}",
        "local catalogIDs = {}",
        "for _, item in ipairs(farmingCatalog or {}) do",
        "    catalogIDs[tonumber(item and item.itemID)] = true",
        "end",
        "",
        "local professionsByCategory = {",
    ])
    for category, professions in MODULE_PROFESSIONS.items():
        values = ", ".join(lua_quote(value) for value in professions)
        lines.append(f"    [{lua_quote(category)}] = {{ {values} }},")
    lines.extend(["}", "local tagsByCategory = {"])
    for category, tag in MODULE_TAGS.items():
        lines.append(f"    [{lua_quote(category)}] = {lua_quote(tag)},")
    lines.extend([
        "}",
        "",
        "local function CopyArray(values)",
        "    local copy = {}",
        "    for _, value in ipairs(values or {}) do",
        "        copy[#copy + 1] = value",
        "    end",
        "    return copy",
        "end",
        "",
        "local function BuildLoopCoords(coords)",
        "    local copy = CopyArray(coords)",
        "    local first = copy[1]",
        "    local last = copy[#copy]",
        "    if #copy > 2 and first and last and (first.x ~= last.x or first.y ~= last.y) then",
        "        copy[#copy + 1] = { x = first.x, y = first.y, label = \"Route loop closure\" }",
        "    end",
        "    return copy",
        "end",
        "",
        "for farmIndex, farm in ipairs(farms) do",
        "    local itemID = tonumber(farm.itemID)",
        "    if itemID and not dropsOnlyItemIDs[itemID] and #farm.routes > 0 then",
        "        -- Route lines are only for Herb and Mining gathering circuits.",
        "        local isRoute = farm.category == \"Mining\" or farm.category == \"Herb\"",
        "        local professions = professionsByCategory[farm.category] or { \"miscellaneous\" }",
        "        if type(farmingCatalog) == \"table\" and not catalogIDs[itemID] then",
        "            farmingCatalog[#farmingCatalog + 1] = {",
        "                itemID = itemID,",
        "                expansion = farm.expansion,",
        "                professions = CopyArray(professions),",
        "                tag = tagsByCategory[farm.category] or \"Catalog Gathering\",",
        "            }",
        "            catalogIDs[itemID] = true",
        "        end",
        "",
        "        local material = materialItems[itemID]",
        "        if not material then",
        "            material = {",
        "                itemID = itemID,",
        "                itemName = \"Item \" .. tostring(itemID),",
        "                expansion = farm.expansion,",
        "                professions = CopyArray(professions),",
        "                category = tagsByCategory[farm.category] or \"Catalog Gathering\",",
        "                sourceUrls = {},",
        "                summary = \"Route included in GGT's bundled Gathering catalog.\",",
        "                spots = {},",
        "                researchStatus = \"researched\",",
        "            }",
        "            materialItems[itemID] = material",
        "        end",
        "        material.spots = type(material.spots) == \"table\" and material.spots or {}",
        "",
        "        for routeIndex, route in ipairs(farm.routes) do",
        "            local routeLabel = \"Catalog: \" .. route.name",
        "            material.spots[#material.spots + 1] = {",
        "                id = string.format(\"catalog-gathering-%04d-%02d\", farmIndex, routeIndex),",
        "                source = \"Catalog \" .. tostring(NS.CatalogGatheringData.sourceVersion),",
        "                sourceUrls = {},",
        "                mapID = route.mapID,",
        "                mapName = route.mapName,",
        "                location = routeLabel,",
        "                dropdownLabel = routeLabel,",
        "                routeType = \"catalog-\" .. string.lower(farm.category) .. \"-route\",",
        "                density = \"Recorded farm route\",",
        "                dropDifficulty = \"Recorded route; yield varies with competition and character setup.\",",
        "                tips = { \"Follow the numbered route points as a loop.\" },",
        "                confidence = \"source-catalog\",",
        "                coords = BuildLoopCoords(route.coords),",
        "                isRoute = isRoute,",
        "                catalogFarmRecordID = farm.recordID,",
        "            }",
        "        end",
        "    end",
        "end",
        "",
    ])
    return "\n".join(lines)


def build_snapshot(source_root: Path) -> tuple[list[dict[str, Any]], str]:
    source_version = read_source_version(source_root)

    environment: dict[str, Any] = {**ACTIVITIES, **CONTENTS}
    for enum_file in sorted((source_root / "Enums").rglob("*.lua")):
        for path, value in parse_core_assignments(enum_file):
            flatten_assignment(path, value, environment)

    routes: dict[str, LuaTable] = {}
    for route_file in sorted((source_root / "Data" / "retail" / "Routes").glob("*.lua")):
        for path, value in parse_core_assignments(route_file):
            if path.count(".") >= 4 and isinstance(value, LuaTable):
                routes[path] = value
                environment[path] = value

    farm_definitions: dict[str, LuaTable] = {}
    farms_root = source_root / "Data" / "retail" / "Results" / "Farms"
    for source_name in GATHERING_MODULES.values():
        for path, value in parse_core_assignments(farms_root / f"{source_name}.lua"):
            prefix = "core.Data.Results.Farms."
            if path.startswith(prefix) and isinstance(value, LuaTable):
                farm_definitions[path[len(prefix):]] = value

    map_names: dict[int, str] = {}
    for path, value in environment.items():
        if path.startswith("core.Maps.") and isinstance(value, (int, float)):
            map_names.setdefault(int(value), pretty_identifier(path.rsplit(".", 1)[-1]))

    output: list[dict[str, Any]] = []
    missing_farm_refs: list[str] = []
    occurrence = 0
    for category, module_name in GATHERING_MODULES.items():
        module_path = source_root / "Modules" / "retail" / "Farming" / f"{module_name}Module.lua"
        module_text = module_path.read_text(encoding="utf-8-sig")
        farm_keys = re.findall(r"core\.Data\.Results\.Farms\.([A-Za-z0-9_]+)", module_text)
        for farm_key in farm_keys:
            occurrence += 1
            table = farm_definitions.get(farm_key)
            if not table:
                missing_farm_refs.append(f"{module_path.name}:{farm_key}")
                continue

            extracted_routes = extract_routes(table.get("Routes"), routes, environment, farm_key)
            normalized_routes: list[dict[str, Any]] = []
            for route_index, route in enumerate(extracted_routes, 1):
                map_id = int(route["map_id"])
                points: list[int] = []
                for point in route["points"]:
                    if not isinstance(point, (int, float)):
                        raise ValueError(f"non-numeric route point in {farm_key} route {route_index}: {point!r}")
                    packed = int(point)
                    x = packed // 10000 / 10000
                    y = packed % 10000 / 10000
                    if not (0 <= x <= 1 and 0 <= y <= 1):
                        raise ValueError(f"invalid packed coordinate {packed} in {farm_key} route {route_index}")
                    points.append(packed)
                if not points:
                    raise ValueError(f"empty route in {farm_key} route {route_index}")
                original_name = str(route.get("name") or farm_key)
                normalized_routes.append({
                    "name": pretty_identifier(original_name),
                    "original_name": original_name,
                    "map_id": map_id,
                    "map_name": map_names.get(map_id, f"Map {map_id}"),
                    "format": route["format"],
                    "points": points,
                })

            results: list[dict[str, Any]] = []
            raw_results = table.get("Results")
            if isinstance(raw_results, LuaTable):
                for result_index, result in enumerate(raw_results.array(), 1):
                    if not isinstance(result, LuaTable):
                        raise ValueError(f"invalid result {result_index} in {farm_key}")
                    result_id = resolved_number(result.get("Id"), environment, f"{farm_key}.Results[{result_index}].Id", True)
                    quantity = resolved_number(result.get("Quantity"), environment, f"{farm_key}.Results[{result_index}].Quantity", True)
                    pet_id = resolved_number(result.get("PetId"), environment, f"{farm_key}.Results[{result_index}].PetId")
                    sell_to_vendor = resolve(result.get("SellToVendor"), environment)
                    results.append({
                        "item_id": int(result_id),
                        "quantity": quantity,
                        "pet_id": int(pet_id) if pet_id is not None else None,
                        "sell_to_vendor": sell_to_vendor if isinstance(sell_to_vendor, bool) else None,
                    })

            item_id = resolved_number(table.get("ItemId"), environment, f"{farm_key}.ItemId")
            item_inferred = item_id is None
            if item_id is None and results:
                item_id = results[0]["item_id"]
            content_id = resolved_number(table.get("Content"), environment, f"{farm_key}.Content") or 1
            activity_id = resolved_number(table.get("Activity"), environment, f"{farm_key}.Activity")
            seconds = resolved_number(table.get("Time"), environment, f"{farm_key}.Time")
            money = resolved_number(table.get("Money"), environment, f"{farm_key}.Money")
            name = table.get("Name") or pretty_identifier(farm_key)

            output.append({
                "record_id": f"{category}:{farm_key}:{occurrence}",
                "provider_key": farm_key,
                "farm_id": str(table.get("Id") or farm_key),
                "category": category,
                "activity_id": int(activity_id) if activity_id is not None else None,
                "content_id": int(content_id),
                "expansion": EXPANSIONS.get(int(content_id), "classic"),
                "name": str(name),
                "item_id": int(item_id) if item_id is not None else None,
                "item_inferred": item_inferred,
                "seconds": seconds or 3600,
                "seconds_inferred": seconds is None,
                "money": money,
                "results": results,
                "routes": normalized_routes,
            })

    if missing_farm_refs:
        print("Skipped undefined farm references: " + ", ".join(missing_farm_refs))
    return output, source_version


def build_farm_catalog(
    gathering_farms: list[dict[str, Any]],
    drop_categories: dict[str, list[dict[str, Any]]],
) -> list[dict[str, Any]]:
    """Build GGT-owned farm definitions from the extracted static snapshots.

    Stable IDs use the source definition key rather than its Id field. The source
    contains repeated and mismatched Id values, so that field is provenance,
    not identity.
    """

    catalog: list[dict[str, Any]] = []
    gathering_by_id: dict[str, dict[str, Any]] = {}

    for source in gathering_farms:
        category = source["category"]
        provider_key = source["provider_key"]
        catalog_id = f"catalog:gathering:{stable_slug(category)}:{stable_slug(provider_key)}"
        definition = {
            "id": catalog_id,
            "provider_key": provider_key,
            "provider_farm_id": source["farm_id"],
            "source_type": "gathering",
            "source_dataset": "CatalogGatheringData",
            "source_category": category,
            "source_path": f"Gathering > {category}",
            "source_record_ids": [source["record_id"]],
            "activity": FARM_CATALOG_ACTIVITIES[category],
            "name": source["name"],
            "content_id": source["content_id"],
            "expansion": source["expansion"],
            "primary_item_id": source["item_id"],
            "targets": [
                {
                    "item_id": result["item_id"],
                    "quantity": result["quantity"],
                    "pet_id": result.get("pet_id"),
                    "sell_to_vendor": result.get("sell_to_vendor"),
                }
                for result in source["results"]
            ],
            "map_ids": unique_values([route["map_id"] for route in source["routes"]]),
            "map_names": unique_values([route["map_name"] for route in source["routes"]]),
            "route_count": len(source["routes"]),
            "recorded_seconds": source["seconds"],
            "duration_inferred": source["seconds_inferred"],
            "raw_copper": source["money"],
        }

        existing = gathering_by_id.get(catalog_id)
        if existing is None:
            gathering_by_id[catalog_id] = definition
            catalog.append(definition)
            continue

        comparable_existing = {key: value for key, value in existing.items() if key != "source_record_ids"}
        comparable_definition = {key: value for key, value in definition.items() if key != "source_record_ids"}
        if comparable_existing != comparable_definition:
            raise ValueError(f"conflicting gathering definitions for stable farm ID {catalog_id}")
        existing["source_record_ids"].append(source["record_id"])

    for category in FARM_CATALOG_DROP_CATEGORIES:
        category_metadata = FARM_CATALOG_DROP_CATEGORY_METADATA[category]
        grouped: dict[str, list[dict[str, Any]]] = {}
        for row in drop_categories.get(category, []):
            grouped.setdefault(row["provider_key"], []).append(row)

        for provider_key, rows in grouped.items():
            first = rows[0]
            catalog_id = f"catalog:drops:{stable_slug(category)}:{stable_slug(provider_key)}"
            for row in rows[1:]:
                fields = (
                    "farm_id", "farm_name", "content_id", "expansion",
                    "location_id", "location_label", "seconds", "money",
                )
                for field in fields:
                    if row[field] != first[field]:
                        raise ValueError(f"inconsistent {field} for farm {provider_key}")

            catalog.append({
                "id": catalog_id,
                "provider_key": provider_key,
                "provider_farm_id": first["farm_id"],
                "source_type": "drops",
                "source_dataset": "CatalogDropsData",
                "source_category": category_metadata["source_category"],
                "source_path": category_metadata["source_path"],
                "source_record_ids": [],
                "activity": FARM_CATALOG_ACTIVITIES[category],
                "name": first["farm_name"],
                "content_id": first["content_id"],
                "expansion": first["expansion"],
                "primary_item_id": None,
                "targets": [
                    {
                        "item_id": row["item_id"],
                        "quantity": row["quantity"],
                        "pet_id": row.get("pet_id"),
                        "sell_to_vendor": None,
                    }
                    for row in rows
                ],
                "map_ids": [first["location_id"]] if first["location_id"] is not None else [],
                "map_names": [first["location_label"]],
                "route_count": 0,
                "recorded_seconds": first["seconds"] or 3600,
                "duration_inferred": first["seconds"] is None,
                "raw_copper": first["money"],
            })

    ids = [farm["id"] for farm in catalog]
    if len(ids) != len(set(ids)):
        raise ValueError("generated Farms catalog contains duplicate stable IDs")
    return catalog


def build_catalog_indexes(farms: list[dict[str, Any]]) -> dict[str, dict[Any, list[int]]]:
    indexes: dict[str, dict[Any, list[int]]] = {
        "byActivity": {},
        "byExpansion": {},
        "byMapID": {},
        "byItemID": {},
        "byProviderFarmID": {},
        "bySourceCategory": {},
        "bySourceType": {},
    }

    def add(index_name: str, key: Any, position: int) -> None:
        if key is None or key == "":
            return
        indexes[index_name].setdefault(key, []).append(position)

    for position, farm in enumerate(farms, 1):
        add("byActivity", farm["activity"], position)
        add("byExpansion", farm["expansion"], position)
        add("byProviderFarmID", farm["provider_farm_id"], position)
        add("bySourceCategory", farm["source_category"], position)
        add("bySourceType", farm["source_type"], position)
        for map_id in unique_values(farm["map_ids"]):
            add("byMapID", map_id, position)
        for item_id in unique_values([target["item_id"] for target in farm["targets"]]):
            add("byItemID", item_id, position)
    return indexes


def emit_farm_catalog(farms: list[dict[str, Any]], source_version: str) -> str:
    farms = [{**farm, "targets": [row for row in farm["targets"] if not excluded_product(row)]}
             for farm in farms if not excluded_product(farm)]
    indexes = build_catalog_indexes(farms)
    target_count = sum(len(farm["targets"]) for farm in farms)
    unique_item_count = len(indexes["byItemID"])
    gathering_count = sum(farm["source_type"] == "gathering" for farm in farms)
    drop_count = sum(farm["source_type"] == "drops" for farm in farms)

    lines = [
        "local _, NS = ...",
        "",
        "-- Generated by tools/generate_farm_catalog_snapshot.py. Do not hand-edit.",
        "-- Bundled static GGT farm catalog.",
        "",
        "local farms = {",
    ]

    for farm in farms:
        lines.extend([
            "    {",
            f"        id = {lua_quote(farm['id'])},",
            "        provider = \"catalog\",",
            f"        providerKey = {lua_quote(farm['provider_key'])},",
            f"        providerFarmID = {lua_quote(farm['provider_farm_id'])},",
            f"        sourceType = {lua_quote(farm['source_type'])},",
            f"        sourceDataset = {lua_quote(farm['source_dataset'])},",
            f"        sourceCategory = {lua_quote(farm['source_category'])},",
            f"        sourcePath = {lua_quote(farm['source_path'])},",
            f"        activity = {lua_quote(farm['activity'])},",
            f"        name = {lua_quote(farm['name'])},",
            f"        contentID = {lua_number(farm['content_id'])},",
            f"        expansion = {lua_quote(farm['expansion'])},",
            f"        primaryItemID = {lua_number(farm['primary_item_id'])},",
            f"        recordedSeconds = {lua_number(farm['recorded_seconds'])},",
            f"        durationInferred = {'true' if farm['duration_inferred'] else 'false'},",
            f"        rawCopper = {lua_number(farm['raw_copper'])},",
            f"        routeCount = {farm['route_count']},",
        ])
        source_ids = ", ".join(lua_quote(value) for value in farm["source_record_ids"])
        map_ids = ", ".join(str(value) for value in farm["map_ids"])
        map_names = ", ".join(lua_quote(value) for value in farm["map_names"])
        lines.extend([
            f"        sourceRecordIDs = {{ {source_ids} }},",
            f"        mapIDs = {{ {map_ids} }},",
            f"        mapNames = {{ {map_names} }},",
            "        targets = {",
        ])
        for target in farm["targets"]:
            fields = [
                f"itemID = {target['item_id']}",
                f"quantity = {lua_number(target['quantity'])}",
            ]
            if target.get("pet_id") is not None:
                fields.append(f"petID = {target['pet_id']}")
            if target.get("sell_to_vendor") is not None:
                fields.append(f"sellToVendor = {'true' if target['sell_to_vendor'] else 'false'}")
            lines.append("            { " + ", ".join(fields) + " },")
        lines.extend(["        },", "    },"])

    lines.extend(["}", "", "local byID = {"])
    for position, farm in enumerate(farms, 1):
        lines.append(f"    [{lua_quote(farm['id'])}] = {position},")
    lines.extend(["}", "", "local indexes = {"])
    for index_name, index in indexes.items():
        lines.append(f"    {index_name} = {{")
        keys = sorted(index, key=lambda value: (isinstance(value, str), value))
        for key in keys:
            lua_key = lua_quote(key) if isinstance(key, str) else str(key)
            positions = ", ".join(str(position) for position in index[key])
            lines.append(f"        [{lua_key}] = {{ {positions} }},")
        lines.append("    },")

    lines.extend([
        "}",
        "",
        "NS.FarmCatalog = {",
        "    dataVersion = 2,",
        f"    sourceVersion = {lua_quote(source_version)},",
        "    runtimeDependency = false,",
        f"    farmCount = {len(farms)},",
        f"    targetCount = {target_count},",
        f"    uniqueItemCount = {unique_item_count},",
        "    sourceCounts = {",
        f"        gathering = {gathering_count},",
        f"        drops = {drop_count},",
        "    },",
        "    farms = farms,",
        "    byID = byID,",
        "    indexes = indexes,",
        "}",
        "",
    ])
    return "\n".join(lines)


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--source-root", type=Path, required=True)
    parser.add_argument(
        "--output",
        type=Path,
        default=Path(__file__).resolve().parents[1] / "Data" / "General-Gold-Tracker_Materials" / "MaterialFarmingSpots" / "CatalogGathering.lua",
    )
    parser.add_argument(
        "--drops-output",
        type=Path,
        default=Path(__file__).resolve().parents[1] / "Data" / "General-Gold-Tracker_Drops" / "CatalogDrops.lua",
    )
    parser.add_argument(
        "--farms-output",
        type=Path,
        default=Path(__file__).resolve().parents[1] / "Data" / "General-Gold-Tracker_Farms" / "Farms.lua",
    )
    args = parser.parse_args()
    source_root = args.source_root.resolve()
    farms, version = build_snapshot(source_root)
    snapshot = emit_snapshot(farms, version)
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(snapshot, encoding="utf-8", newline="\n")
    drop_categories, drop_version = build_drops_snapshot(source_root)
    drops_snapshot = emit_drops_snapshot(drop_categories, drop_version)
    args.drops_output.parent.mkdir(parents=True, exist_ok=True)
    args.drops_output.write_text(drops_snapshot, encoding="utf-8", newline="\n")
    if version != drop_version:
        raise ValueError(f"Source version mismatch: Gathering={version}, Drops={drop_version}")
    catalog_farms = build_farm_catalog(farms, drop_categories)
    farm_catalog = emit_farm_catalog(catalog_farms, version)
    args.farms_output.parent.mkdir(parents=True, exist_ok=True)
    args.farms_output.write_text(farm_catalog, encoding="utf-8", newline="\n")
    routes = sum(len(farm["routes"]) for farm in farms)
    points = sum(len(route["points"]) for farm in farms for route in farm["routes"])
    routed_farms = sum(bool(farm["routes"]) for farm in farms)
    print(f"Catalog {version}: {len(farms)} Gathering rows, {routed_farms} routed rows, {routes} routes, {points} points")
    drop_counts = ", ".join(f"{name}={len(rows)}" for name, rows in drop_categories.items())
    print(f"Catalog {drop_version}: Drops item sources: {drop_counts}")
    print(f"Catalog {version}: Static Farms catalog: {len(catalog_farms)} definitions")


if __name__ == "__main__":
    main()
