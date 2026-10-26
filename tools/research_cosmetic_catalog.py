"""Inventory TODO-Planner cosmetics and verify exact Retail tooltip type/binding.

TODO-Planner's broad appearance collection is discovery evidence only. A row is
eligible only when its current tooltip explicitly labels it Cosmetic and it is
not bound on pickup, account/Warband bound, or otherwise prohibited by policy.
Raw public responses are cached locally; the report stores hashes and decisions.
"""
import argparse
from concurrent.futures import ThreadPoolExecutor, as_completed
from datetime import datetime, timezone
import hashlib
import html
import json
from pathlib import Path
import re
import time
import urllib.request

from lupa.lua51 import LuaRuntime
from catalog_exclusions import excluded_product


def convert(value):
    if hasattr(value, "items"):
        keys = list(value.keys())
        if keys and all(isinstance(k, int) for k in keys) and sorted(keys) == list(range(1, len(keys) + 1)):
            return [convert(value[k]) for k in sorted(keys)]
        return {str(k): convert(v) for k, v in value.items()}
    return value


def inventory(source_root):
    lua = LuaRuntime(unpack_returned_tuples=True)
    ns = lua.table()
    load = lua.eval('function(path,ns) assert(loadfile(path))("GGT-Cosmetics-Audit",ns) end')
    load((source_root / "Data/Catalog/Registry.lua").as_posix(), ns)
    paths = sorted((source_root / "Data/Expansions").glob("*/*/Cosmetics.lua"))
    candidates, missing = {}, []
    for path in paths:
        patch_file = path.with_name("Patch.lua")
        load(patch_file.as_posix(), ns)
        load(path.as_posix(), ns)
        patch_key = path.parent.name
        patch = ns.PatchCatalog.patches[patch_key]
        details = ns.PatchCatalog.cosmeticDetails[patch_key]
        for _, entry in patch.cosmetics.items():
            row = convert(entry)
            item_id = row.get("itemId")
            if not item_id:
                missing.append({"patch": patch_key, "sourceFile": path.as_posix(), "entry": row})
                continue
            detail = details and details[entry.name]
            if not detail and patch.cosmeticDetailGroups and entry.detailKey:
                detail = patch.cosmeticDetailGroups[entry.detailKey]
            source = {"provider": "TODO-Planner", "expansion": path.parent.parent.name,
                      "patch": patch_key, "sourceFile": path.as_posix(),
                      "sourceSha256": hashlib.sha256(path.read_bytes()).hexdigest(),
                      "entry": row, "details": convert(detail),
                      "patchSources": convert(patch.sourceUrls)}
            candidate = candidates.setdefault(int(item_id), {"itemID": int(item_id), "itemName": row.get("name"), "origins": []})
            candidate["origins"].append(source)

    materials = lua.table()
    load("Data/FarmingItems.lua", materials)
    root = Path("Data/General-Gold-Tracker_Materials")
    for line in (root / "General-Gold-Tracker_Materials.toc").read_text(encoding="utf-8").splitlines():
        if line.endswith(".lua") and line != "Namespace.lua":
            load((root / line).as_posix(), materials)
    # Keep the migrated rows discoverable after they leave the Materials catalog.
    primary_path = Path("tools/cosmetic_primary_sources.json")
    primary = json.loads(primary_path.read_text(encoding="utf-8")) if primary_path.exists() else []
    moved = []
    for row in primary:
        item_id = row["itemID"]
        if item_id in candidates:
            candidates[item_id]["origins"] = row["origins"] + candidates[item_id]["origins"]
        else:
            candidates[item_id] = row
        moved.append(item_id)
    for _, item in materials.FarmingItems["items"].items():
        if (item.expansion == "warWithin" and item.tag == "Fishing Appearance"
                or item.expansion == "midnight" and item.tag == "Fishing Specialty"):
            item_id = int(item.itemID)
            research = materials.MaterialFarmingSpots["items"][item_id]
            expansion, patch = ("TheWarWithin", "11.0") if item.expansion == "warWithin" else ("Midnight", "12.0")
            origin = {"provider": "GGT Materials", "expansion": expansion, "patch": patch,
                      "entry": convert(item), "details": convert(research)}
            candidate = candidates.setdefault(item_id, {"itemID": item_id, "itemName": item.itemName, "origins": []})
            if item_id not in moved:
                candidate["origins"].insert(0, origin)
                if item.tag == "Fishing Appearance":
                    moved.append(item_id)
    return {"scope": "Auctionable items with the exact Cosmetic tooltip type", "todoPlannerFiles": len(paths),
            "items": [candidates[key] for key in sorted(candidates)], "withoutItemID": missing,
            "fishingAppearanceItemIDs": moved}


def classify(payload):
    tooltip = payload.get("tooltip", "")
    text = html.unescape(re.sub("<[^>]+>", " ", tooltip))
    text = re.sub(r"\s+", " ", text).strip()
    labels = re.findall(r'<span[^>]*class=["\'][^"\']*whtt-transmogrified-to[^"\']*["\'][^>]*>(.*?)</span>', tooltip, re.I | re.S)
    is_cosmetic = any(html.unescape(re.sub("<[^>]+>", "", label)).strip() == "Cosmetic" for label in labels)
    bound = re.search(r"Binds when picked up|Binds to (?:Warband|account|Battle\.net account|Blizzard account)|Soulbound|Quest Item", text, re.I)
    if bound:
        binding = bound.group(0)
    elif "Binds when equipped" in text:
        binding = "Binds when equipped"
    elif "Binds when used" in text:
        binding = "Binds when used"
    else:
        binding = "No binding restriction in tooltip"
    return {"cosmeticTooltipType": is_cosmetic, "binding": binding,
            "auctionable": not bool(bound), "quality": payload.get("quality"),
            "decision": "include" if is_cosmetic and not bound else "exclude-bound" if bound else "exclude-not-cosmetic"}


def fetch_all(data, cache, workers):
    cache.mkdir(parents=True, exist_ok=True)

    def fetch(row):
        item_id = row["itemID"]
        path = cache / f"item-{item_id}.json"
        url = f"https://nether.wowhead.com/tooltip/item/{item_id}?dataEnv=1&locale=0"
        error = None
        for attempt in range(3):
            try:
                if path.exists():
                    raw = path.read_bytes()
                else:
                    request = urllib.request.Request(url, headers={"User-Agent": "GGT-Public-Cosmetic-Research/1.0"})
                    with urllib.request.urlopen(request, timeout=25) as response:
                        raw = response.read()
                    payload = json.loads(raw)
                    if not payload.get("name") or not payload.get("tooltip"):
                        raise ValueError("No item name/tooltip returned")
                    path.write_bytes(raw)
                payload = json.loads(raw)
                result = {"itemID": item_id, "itemName": payload["name"], "status": "retrieved",
                          "retrievalUrl": url, "sourceUrl": f"https://www.wowhead.com/item={item_id}",
                          "retrievedAt": datetime.fromtimestamp(path.stat().st_mtime, timezone.utc).isoformat(),
                          "sha256": hashlib.sha256(raw).hexdigest(), **classify(payload)}
                if excluded_product({"item_id": item_id, "name": payload["name"]}):
                    result["decision"] = "exclude-policy"
                return result
            except (OSError, ValueError, KeyError) as exc:
                error = str(exc)
                if attempt < 2:
                    time.sleep(1 + attempt)
        return {"itemID": item_id, "status": "failed", "retrievalUrl": url,
                "decision": "unverified-excluded", "error": error}

    receipts = {}
    with ThreadPoolExecutor(max_workers=workers) as pool:
        futures = [pool.submit(fetch, row) for row in data["items"]]
        for count, future in enumerate(as_completed(futures), 1):
            receipt = future.result()
            receipts[str(receipt["itemID"])] = receipt
            if count % 100 == 0 or count == len(futures):
                print(f"Checked {count}/{len(futures)}; eligible {sum(r['decision'] == 'include' for r in receipts.values())}; failures {sum(r['status'] == 'failed' for r in receipts.values())}", flush=True)
    return receipts


def write_source_index(data, receipts, source_root, output):
    """Freeze eligible provenance so generating GGT never requires the sibling."""
    selected = []
    for item in data["items"]:
        if receipts[str(item["itemID"])]["decision"] != "include":
            continue
        item = json.loads(json.dumps(item))
        for origin in item["origins"]:
            if origin.get("sourceFile"):
                origin["sourceFile"] = Path(origin["sourceFile"]).relative_to(source_root).as_posix()
        selected.append(item)
    map_text = (source_root / "Data/Catalog/MapNames.lua").read_text(encoding="utf-8")
    names = dict(re.findall(r'\[(\d+)\] = "([^"]+)"', map_text))
    # Also recorded in GGT's RareDrops expansion metadata.
    names["2274"] = "Khaz Algar"
    names["2537"] = "Quel'Thalas"
    used_maps = {"2274", "2537"}
    for item in selected:
        for origin in item["origins"]:
            for waypoint in (origin.get("details") or {}).get("waypoints", []):
                match = re.match(r"/way\s+#(\d+)\s", waypoint)
                if match:
                    used_maps.add(match.group(1))
    names = {key: value for key, value in names.items() if key in used_maps}
    output.parent.mkdir(parents=True, exist_ok=True)
    result = {"researchedAt": "2026-10-23", "scope": data["scope"], "mapNames": names,
              "fishingAppearanceItemIDs": data["fishingAppearanceItemIDs"], "items": selected}
    output.write_text(json.dumps(result, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--source-root", type=Path, default=Path("../TODO-Planner"))
    parser.add_argument("--inventory", type=Path, default=Path(".local/cosmetic-inventory.json"))
    parser.add_argument("--fetch", action="store_true")
    parser.add_argument("--cache", type=Path, default=Path(".local/cosmetic-sources"))
    parser.add_argument("--output", type=Path, default=Path("docs/research/cosmetic-type-audit-2026-10-23.json"))
    parser.add_argument("--source-index", type=Path, default=Path("docs/research/cosmetic-source-index-2026-10-23.json"))
    parser.add_argument("--workers", type=int, default=8)
    args = parser.parse_args()
    data = inventory(args.source_root)
    args.inventory.parent.mkdir(parents=True, exist_ok=True)
    args.inventory.write_text(json.dumps(data, indent=2) + "\n", encoding="utf-8")
    print(f"Inventory: {len(data['items'])} distinct items from {data['todoPlannerFiles']} TODO-Planner files and {len(data['fishingAppearanceItemIDs'])} existing fishing appearances; {len(data['withoutItemID'])} entries lack item IDs.", flush=True)
    if args.fetch:
        receipts = fetch_all(data, args.cache, args.workers)
        args.output.parent.mkdir(parents=True, exist_ok=True)
        result = {"checkedAt": datetime.now(timezone.utc).isoformat(), "scope": data["scope"],
                  "itemCount": len(receipts), "includedCount": sum(r["decision"] == "include" for r in receipts.values()),
                  "failedCount": sum(r["status"] == "failed" for r in receipts.values()), "items": receipts}
        args.output.write_text(json.dumps(result, indent=2) + "\n", encoding="utf-8")
        write_source_index(data, receipts, args.source_root, args.source_index)
        print(f"Wrote {args.output}", flush=True)


if __name__ == "__main__":
    main()
