"""Build the standalone Cosmetics catalog from audited, portable source records.

Run research_cosmetic_catalog.py to refresh discovery/tooltip evidence first.
This build needs neither TODO-Planner nor network access; unverified items cannot
enter the catalog. Original collection instructions remain in the research index.
"""
import json
from pathlib import Path
import re


SOURCE = Path("docs/research/cosmetic-source-index-2026-10-23.json")
AUDIT = Path("docs/research/cosmetic-type-audit-2026-10-23.json")
OUTPUT = Path("Data/General-Gold-Tracker_Drops/Cosmetics.lua")
EXPANSIONS = {
    "Shadowlands": (9, "shadowlands", "Shadowlands"),
    "Dragonflight": (10, "dragonflight", "Dragonflight"),
    "TheWarWithin": (11, "warWithin", "The War Within"),
    "Midnight": (12, "midnight", "Midnight"),
}
SOURCE_KEYS = {
    "mawShoulders": ["transmog"],
    "enlightenedParagonCloaks": ["enlightened"],
    "enlightenedParagonWeapons": ["enlightened"],
    "stormsFury": ["stormsFury"],
    "squareHolders": ["squareHolders", "zulGurub"],
    "winterPack": ["voidInvasions", "liveRewards"],
    "etherealPack": ["voidInvasions", "liveRewards"],
    "zuronar": ["voidInvasions", "liveRewards"],
    "lostArmament": ["lostArmaments", "ritualSites", "voidAssaults"],
    "Envenomed Game Ripper": ["captainTokka"],
}
SELL_TIP = "Keep the item unused and unequipped to sell it. Learning its appearance or equipping it can consume or bind it."


def lua(value):
    if isinstance(value, str):
        # JSON string syntax is Lua-compatible for this catalog's printable text.
        assert not re.search(r"[\x00-\x1f]", value)
        return json.dumps(value, ensure_ascii=False)
    if value is True:
        return "true"
    if value is False:
        return "false"
    if isinstance(value, (int, float)):
        return str(value)
    if isinstance(value, list):
        return "{ " + ", ".join(lua(v) for v in value) + " }"
    if isinstance(value, dict):
        return "{ " + ", ".join(f"[{lua(k)}] = {lua(v)}" for k, v in value.items()) + " }"
    raise ValueError(f"Unsupported Lua value: {value!r}")


def strings(value):
    if isinstance(value, str):
        return [value]
    if isinstance(value, list):
        return value
    return []


def guide(origin, key, map_names):
    details = origin.get("details") or {}
    maps = []
    for index, waypoint in enumerate(strings(details.get("waypoints")), 1):
        match = re.fullmatch(r"/way\s+#(\d+)\s+([\d.]+)\s+([\d.]+)\s+(.+)", waypoint)
        if not match:
            raise ValueError(f"Cannot preserve waypoint: {waypoint}")
        map_id, x, y, label = match.groups()
        assert 0 <= float(x) <= 100 and 0 <= float(y) <= 100
        # All inherited points are navigation hints. Shared hubs, recipe access,
        # and vendors must never become claims of exact cosmetic drop positions.
        maps.append({"mapID": int(map_id), "mapLabel": map_names[map_id], "label": label,
                     "location": label, "mapRole": "access", "isRoute": False,
                     "pins": [{"x": float(x) / 100, "y": float(y) / 100, "label": label}],
                     "confidence": "inherited-navigation", "inGameTested": False})
    if origin["provider"] == "GGT Materials":
        map_id, region = {"TheWarWithin": (2274, "Khaz Algar"), "Midnight": (2537, "Quel'Thalas")}[origin["expansion"]]
        maps = [{"mapID": map_id, "mapLabel": region, "label": f"{region} fishing sources",
                 "location": f"{region} fishing", "mapRole": "source-area", "pins": [],
                 "mapOnly": True, "isRoute": False, "confidence": "source-area", "inGameTested": False}]
    tips = []
    for tip in strings(details.get("tips")):
        # Collection advice is not sale advice. The original wording is retained
        # verbatim in SOURCE, while the product UI explains preserving the item.
        tip = tip.replace("Use each appearance token from your bags and check collection status before buying more packs.",
                          "Check the exact item before buying more packs; the result is random.")
        tip = tip.replace("Use each appearance token from your bags as it drops, and combine", "Combine")
        tips.append(tip)
    tips.insert(0, SELL_TIP)
    urls = [url for url in strings(details.get("sourceUrls")) if "item=" not in url]
    patch_sources = origin.get("patchSources") or {}
    urls.extend(patch_sources[k] for k in SOURCE_KEYS.get(key, []) if k in patch_sources)
    extra = strings(details.get("researchNotes")) + strings(details.get("availability"))
    for field in ("cost", "costs", "requirements"):
        extra.extend(strings(details.get(field)))
    if origin["provider"] == "TODO-Planner":
        extra.append("Map points are inherited navigation or access locations from the collection guide; a hub does not identify an exact drop position.")
    else:
        extra.append("The continent map identifies the source area; no fixed fishing position or catch probability is asserted.")
    return {"label": details.get("sourceType", "Fishing appearance"),
            "source": details.get("source", f"{region} fishing" if origin["provider"] == "GGT Materials" else "Collection source"),
            "action": details.get("acquisition", details.get("summary", "")),
            "requirement": details.get("requirements", "Check the acquisition notes for source access and reward eligibility."),
            "tips": tips, "details": extra, "sourceUrls": list(dict.fromkeys(urls)), "mapOptions": maps}


def main():
    source = json.loads(SOURCE.read_text(encoding="utf-8"))
    audit = json.loads(AUDIT.read_text(encoding="utf-8"))
    groups, rows, seen = {}, [], set()
    for item in source["items"]:
        item_id = item["itemID"]
        receipt = audit["items"][str(item_id)]
        assert receipt["decision"] == "include" and receipt["cosmeticTooltipType"] and receipt["auctionable"]
        assert item_id not in seen
        seen.add(item_id)
        origin = item["origins"][0]
        entry = origin["entry"]
        key = entry.get("detailKey", entry.get("name", "fishing"))
        group_id = f"{origin['expansion']}:{origin['patch']}:{key}"
        groups.setdefault(group_id, guide(origin, key, source["mapNames"]))
        content_id, expansion, label = EXPANSIONS[origin["expansion"]]
        row = {"itemID": item_id, "itemName": receipt["itemName"], "itemQuality": receipt["quality"],
               "contentID": content_id, "expansion": expansion, "expansionLabel": label,
               "patch": origin["patch"], "patches": list(dict.fromkeys(o["patch"] for o in item["origins"])),
               "guideID": group_id, "binding": receipt["binding"], "tooltipType": "Cosmetic"}
        if entry.get("cost"):
            row["cost"] = entry["cost"]
        if entry.get("requirements"):
            row["requirements"] = entry["requirements"]
        rows.append(row)
    assert len(rows) == audit["includedCount"], "Source index and eligibility audit disagree"
    lines = ["local _, NS = ...", "", "-- Generated by tools/generate_cosmetic_catalog.py from audited Cosmetic-type items.",
             "-- TODO-Planner is a discovery source, not a runtime dependency.",
             "local catalog = assert(NS.CatalogDropsData)", "if catalog.cosmeticsCuratedLoaded then return end", "local guides = {"]
    lines.extend(f"    [{lua(key)}] = {lua(value)}," for key, value in groups.items())
    lines.append("}\nlocal rows = {")
    lines.extend(f"    {lua(row)}," for row in rows)
    lines.append('''}
for _, row in ipairs(rows) do
    local guide = guides[row.guideID]
    row.recordID = "cosmetics:" .. row.expansion .. ":" .. row.itemID
    row.farmID = "ggt:cosmetic:item:" .. row.itemID
    row.farmName, row.quantity = row.itemName, 1
    row.auctionable, row.researchedAt = true, "2026-10-23"
    row.hasMapOrFarmData = #guide.mapOptions > 0
    row.locationLabel = guide.mapOptions[1] and guide.mapOptions[1].mapLabel or guide.source
    row.summary, row.tips = guide.action, guide.tips
    row.sourceUrls = { "https://www.wowhead.com/item=" .. row.itemID }
    for _, url in ipairs(guide.sourceUrls) do row.sourceUrls[#row.sourceUrls + 1] = url end
end
local previousCount = #(catalog.categories.cosmetics or {})
catalog.categories.cosmetics = rows
catalog.categoryCounts.cosmetics = #rows
catalog.itemSourceCount = (catalog.itemSourceCount or 0) - previousCount + #rows
catalog.cosmeticsCuratedLoaded = true
NS.CosmeticDropsData = { researchedAt = "2026-10-23", rows = rows, guides = guides }
''')
    OUTPUT.write_text("\n".join(lines), encoding="utf-8")
    print(f"Generated {len(rows)} Cosmetics with {len(groups)} acquisition guides")


if __name__ == "__main__":
    main()
