"""Verify visible expansion Materials maps through the real Lua builders.

Run from the repository root with Python and lupa (Lua 5.1).
Native WoW widgets are stubbed; this does not verify live game rendering.
"""
import argparse
import json
from pathlib import Path

from lupa.lua51 import LuaRuntime


def convert(value):
    if hasattr(value, "items"):
        keys = list(value.keys())
        if keys and all(isinstance(k, int) for k in keys) and sorted(keys) == list(range(1, len(keys) + 1)):
            return [convert(value[k]) for k in sorted(keys)]
        return {str(k): convert(v) for k, v in value.items()}
    return value


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--output", type=Path, required=True)
    parser.add_argument("--expansion", choices=("battleForAzeroth", "shadowlands", "dragonflight", "warWithin", "midnight"), default="battleForAzeroth")
    args = parser.parse_args()
    lua = LuaRuntime(unpack_returned_tuples=True)
    ns = lua.table()
    load = lua.eval('function(path,ns) assert(loadfile(path))("GGT",ns) end')
    load("Data/FarmingItems.lua", ns)
    root = Path("Data/General-Gold-Tracker_Materials")
    for line in (root / "General-Gold-Tracker_Materials.toc").read_text(encoding="utf-8").splitlines():
        if line.endswith(".lua") and line != "Namespace.lua":
            load((root / line).as_posix(), ns)
    load("Data/MaterialIndex.lua", ns)
    lua.globals().mapsData = ns
    lua.globals().scopeExpansion = args.expansion
    audit_keys = {"battleForAzeroth": "BfaMissingMaterialMapAudit", "shadowlands": "ShadowlandsMissingMaterialMapAudit",
                  "dragonflight": "DragonflightMissingMaterialMapAudit", "warWithin": "WarWithinMissingMaterialMapAudit",
                  "midnight": "MidnightMissingMaterialMapAudit"}
    lua.globals().mapAudit = ns[audit_keys[args.expansion]]
    helpers = Path("tests/ui/crafting_farming_window_spec.lua").read_text(encoding="utf-8").split("describe(", 1)[0]
    lua.globals().helpers = helpers + "\nreturn build_addon,load_window"
    lua.execute('''
local build, loadWindow = assert(loadstring(helpers))()
local loader = require("tests.helpers.addon_loader")
local addon = build({expansionID=scopeExpansion,professionID="all",raidMaterialsExpanded=true})
addon.materialFarmingSpots = mapsData.MaterialFarmingSpots
addon.db.craftingFarmingCustomItems = {}
for _, item in ipairs(mapsData.FarmingItems.items) do
    local research = mapsData.MaterialFarmingSpots.items[item.itemID]
    local name = item.itemName or (research and research.itemName) or tostring(item.itemID)
    addon.craftingFarmingFrame.itemCache[item.itemID.."|TSM_DBMARKET"] = {
        itemID=item.itemID,itemName=name,itemLink="|Hitem:"..item.itemID.."|h["..name.."]|h",value=0,itemQuality=2,
    }
end
addon = loadWindow(addon,mapsData.FarmingItems)
loader.load_module("UI/MapAreaOverlay.lua",addon,{})
loader.load_module("UI/StandaloneMapWindow.lua",addon,{})
local opened
addon.OpenStandaloneMapWindow = function(_, options) opened = options end
local visible, raids, lattices, checks = {}, {}, {}, 0
local removed = {[160053]=true,[181468]=true,[163131]=true}
local professions = scopeExpansion == "shadowlands" and {"all","raidItems","protoformLattices"} or {"all","raidItems"}
for _, profession in ipairs(professions) do
    addon.craftingFarmingFrame.professionID = profession
    local found = 0
    for _, row in ipairs(addon:BuildCraftingFarmingRows({deferMetrics=true})) do
        if row.itemID then
            assert(not removed[row.itemID],"Removed product visible: "..row.itemID)
            assert(row.hasFarmingMap,"Map button missing: "..row.itemID)
            assert(addon:OpenMaterialFarmingMap(row.itemID),"Map cannot open: "..row.itemID)
            assert(#opened.mapOptions > 0)
            if scopeExpansion == "warWithin" or scopeExpansion == "midnight" then
                local research = mapsData.MaterialFarmingSpots.items[row.itemID]
                assert(#opened.mapOptions == #research.spots,"Unusable source option: "..row.itemID)
            end
            if profession == "all" then visible[row.itemID] = true
            elseif profession == "raidItems" then raids[row.itemID] = true
            else lattices[row.itemID] = true end
            found = found + 1
        end
    end
    assert(found > 0 or profession == "raidItems","Empty Materials list: "..profession)
    checks = checks + 1
end
if scopeExpansion == "battleForAzeroth" then assert(raids[163833],"Dungeon recipe missing from Raid items") end
if scopeExpansion == "dragonflight" then
    assert(raids[208212] and raids[204464],"Dragonflight raid reagents missing from Raid items")
end
if scopeExpansion == "warWithin" then
    for _,id in ipairs({221754,221756,221757,221758,221763,249218}) do
        assert(raids[id],"War Within reagent missing from Instance items: "..id)
    end
end
if scopeExpansion == "midnight" then
    for _,id in ipairs({237017,237018,236963,236965,251285,237015,237016}) do
        assert(raids[id],"Midnight reagent missing from Instance items: "..id)
    end
end
local newOptions, details, newItems = 0, 0, {}
for id in pairs(mapAudit.items) do
    assert(visible[id],"New map target not visible: "..id)
    assert(mapsData.MaterialIndex.items[id].hasMap,"Lightweight index lacks map: "..id)
    assert(addon:OpenMaterialFarmingMap(id))
    local item = mapsData.MaterialFarmingSpots.items[id]
    for _, option in ipairs(opened.mapOptions) do
        local lines = opened.detailLinesBuilder(option,nil,option.mapLabel)
        local sources, tips, action = false, false, false
        local expectedAction = (option.detailPins or option.pins)[1].farmAction
        for _, line in ipairs(lines) do
            if line.type == "source" then sources = true end
            if line.text == "Tips" then tips = true end
            if line.text == expectedAction then action = true end
        end
        assert(sources and tips and action,"Missing map details: "..tostring(option.id))
        if option.mapOnly then
            assert(#option.pins == 0 and option.detailPins[1].x == nil)
        else
            assert(#option.pins > 0)
            for _, pin in ipairs(option.pins) do
                assert(pin.x >= 0 and pin.x <= 1 and pin.y >= 0 and pin.y <= 1)
            end
        end
        newOptions, details = newOptions + 1, details + #lines
    end
    newItems[#newItems + 1] = {itemID=id,itemName=item.itemName,mapOptionCount=#opened.mapOptions,
        mapInputItemIDs=item.mapInputItemIDs,spots=item.spots}
    addon.craftingFarmingFrame.searchText = item.itemName
    local found = false
    for _, row in ipairs(addon:BuildCraftingFarmingRows({deferMetrics=true})) do
        if row.itemID == id then found = row.hasFarmingMap end
    end
    assert(found,"Search hides target map: "..id)
    checks = checks + 1
end
addon.craftingFarmingFrame.searchText = ""
addon.craftingFarmingFrame.professionID = "all"
-- Both rendered list modes receive the same validated display rows.
addon.FormatMoney = function(_, value) return tostring(value) end
addon.GetCraftingFarmingWindowRow = function() return nil end
addon.RefreshCraftingFarmingWindowLayout = function() end
addon.UpdateCraftingFarmingSortHeaderState = function() end
addon.craftingFarmingFrame.content = {SetHeight=function() end}
addon.craftingFarmingExpandedFrame = {content={SetHeight=function() end},rows={},IsShown=function() return true end}
loader.with_globals({time=os.time,date=os.date},function()
    addon:RefreshCraftingFarmingWindow(false,{synchronous=true,skipControls=true})
end)
assert(addon.craftingFarmingFrame.materialDisplayRows == addon.craftingFarmingExpandedFrame.materialDisplayRows)
local count, raidCount, latticeCount, composed = 0, 0, 0, 0
for _ in pairs(visible) do count = count + 1 end
for _ in pairs(raids) do raidCount = raidCount + 1 end
for _ in pairs(lattices) do latticeCount = latticeCount + 1 end
if scopeExpansion == "shadowlands" then
    assert(latticeCount == 17,"Incomplete Protoform Lattices category")
    addon:SetCraftingFarmingProfessionFilter("miscellaneous")
    for _, row in ipairs(addon:BuildCraftingFarmingRows({deferMetrics=true})) do
        assert(not lattices[row.itemID],"Lattice still in Miscellaneous")
    end
    addon:SetCraftingFarmingProfessionFilter("protoformLattices")
    addon:SetCraftingFarmingExpansionFilter("classic")
    assert(addon.craftingFarmingFrame.professionID == "all")
    addon:SetCraftingFarmingExpansionFilter("shadowlands")
end
for _, item in ipairs(mapsData.FarmingItems.items) do
    if item.expansion == scopeExpansion and item.components and #item.components > 0 then composed = composed + 1 end
end
result = {visibleNonComposedItems=count,raidItems=raidCount,protoformLattices=latticeCount,missingVisibleMaps=0,
    researchedItems=newItems,newMapOptions=newOptions,renderedDetailLines=details,
    composedEntriesExcluded=composed,filterSearchChecks=checks,normalExpandedRowsShared=true}
if mapAudit.missingItems then
    result.initialMissingMaps, result.repairedExistingMaps = 0, 0
    for _ in pairs(mapAudit.missingItems) do result.initialMissingMaps = result.initialMissingMaps + 1 end
    for _ in pairs(mapAudit.repairedItems) do result.repairedExistingMaps = result.repairedExistingMaps + 1 end
end
''')
    result = convert(lua.globals().result)
    result["scope"] = f"Missing visible {args.expansion} Materials maps, including Instance items; Composed materials excluded"
    result["researchedAt"] = "2026-10-23"
    result["liveGameTested"] = False
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(json.dumps(result, indent=2) + "\n", encoding="utf-8")
    print(json.dumps({k: v for k, v in result.items() if k != "researchedItems"}, indent=2))


if __name__ == "__main__":
    main()
