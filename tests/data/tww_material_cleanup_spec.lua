local loader = require("tests.helpers.addon_loader")
local delveIDs = {[221754]=true,[221756]=true,[221757]=true,[221758]=true,[221763]=true}
local function LoadCatalogs()
    local ns = {GoldTracker={}}
    local function load(path) assert(loadfile(path))("GGT",ns) end
    load("Data/FarmingItems.lua")
    for _,name in ipairs({"Materials","Drops","Farms"}) do
        local root = "Data/General-Gold-Tracker_" .. name .. "/"
        for line in io.lines(root .. "General-Gold-Tracker_" .. name .. ".toc") do
            line = line:gsub("\r","")
            if line:match("%.lua$") and line ~= "Namespace.lua" then load(root .. line) end
        end
    end
    load("Data/MaterialIndex.lua")
    return ns
end
local function BuildMaterials(ns)
    local file = assert(io.open("tests/ui/crafting_farming_window_spec.lua","r"))
    local source = file:read("*a")
    file:close()
    local helpers = source:match("^(.-)describe%(")
    local build,loadWindow = assert(loadstring(helpers .. "\nreturn build_addon,load_window"))()
    local addon = build({expansionID="warWithin",professionID="all"})
    addon.db.craftingFarmingCustomItems = {}
    addon.materialFarmingSpots = ns.MaterialFarmingSpots
    for _,item in ipairs(ns.FarmingItems.items) do
        local research = ns.MaterialFarmingSpots.items[item.itemID]
        local name = item.itemName or (research and research.itemName) or tostring(item.itemID)
        addon.craftingFarmingFrame.itemCache[item.itemID .. "|TSM_DBMARKET"] = {
            itemID=item.itemID,itemName=name,itemLink="item:" .. item.itemID,itemQuality=2,value=0,
        }
    end
    return loadWindow(addon,ns.FarmingItems)
end

describe("The War Within Materials cleanup",function()
    it("moves Writhing Transmutagen to the exact saleable Pets species and keeps a map without a fabricated pin",function()
        local ns = LoadCatalogs()
        for _,item in ipairs(ns.FarmingItems.items) do assert.is_true(item.itemID ~= 223487) end
        assert.is_nil(ns.MaterialFarmingSpots.items[223487])
        assert.is_nil(ns.MaterialIndex.items[223487])
        local row,count
        count = 0
        for _,pet in ipairs(ns.PetFarmData.rows) do
            if pet.petID == 4482 then row,count = pet,count + 1 end
        end
        assert.equals(1,count)
        assert.equals("warWithin",row.expansion)
        assert.equals(11,row.contentID)
        assert.equals(223487,row.acquisitionItemID)
        assert.is_truthy(row.itemLink:find("battlepet:4482:",1,true))
        local positions = ns.FarmCatalog.indexes.byPetID[4482]
        assert.equals(1,#positions)
        local farm = ns.FarmCatalog.farms[positions[1]]
        assert.equals("Drops > Pets",farm.sourcePath)
        assert.equals(row.recordID,farm.sourceRecordID)
        assert.equals(223487,farm.acquisitionItemID)
        assert.is_nil(farm.primaryItemID)
        assert.is_true(farm.cageable)
        assert.equals("item-or-cage",farm.saleMethod)
        assert.is_truthy(farm.guide.action:find("Thaumaturgy",1,true))
        assert(loadfile("UI/FarmDetailsWindow.lua"))("GGT",ns)
        ns.GoldTracker.BuildFarmValuationSnapshot = function() error("No deterministic pet yield") end
        local options = ns.GoldTracker:BuildFarmDetailsMapOptions({farm})
        assert.equals(1,#options)
        assert.equals(2274,options[1].mapID)
        assert.is_true(options[1].mapOnly)
        assert.equals(0,#options[1].pins)
        local sources,tips = false,false
        for _,line in ipairs(ns.GoldTracker:BuildFarmMapDetailLines(farm,nil,"Khaz Algar")) do
            if line.type == "source" then sources = true end
            if line.text == "Tips" then tips = true end
        end
        assert.is_true(sources and tips)
    end)

    it("groups all five delve reagents under Instance items and retains profession links and crafting inputs",function()
        local ns = LoadCatalogs()
        local addon = BuildMaterials(ns)
        local rows = addon:BuildCraftingFarmingRows({deferMetrics=true})
        local divider
        for _,row in ipairs(rows) do
            assert.is_nil(delveIDs[row.itemID])
            if row.dividerKind == "raidMaterials" then divider = row end
        end
        assert.equals("Instance items",divider.label)
        assert.is_false(divider.expanded)
        addon.craftingFarmingFrame.raidMaterialsExpanded = true
        local found,inGroup = {},false
        for _,row in ipairs(addon:BuildCraftingFarmingRows({deferMetrics=true})) do
            if row.rowType == "divider" then inGroup = row.dividerKind == "raidMaterials" end
            if delveIDs[row.itemID] then
                assert.is_true(inGroup)
                found[row.itemID] = true
                assert.is_string(row.professionLabel)
            end
            assert.is_true(row.itemID ~= 223487)
        end
        assert.same(delveIDs,found)
        local componentUses = {}
        for _,item in ipairs(ns.FarmingItems.items) do
            for _,component in ipairs(item.components or {}) do
                if delveIDs[component.itemID] then componentUses[component.itemID] = true end
            end
        end
        assert.same(delveIDs,componentUses)
        local options = addon:GetCraftingFarmingBrowseProfessionOptions("warWithin")
        assert.equals("raidItems",options[#options].id)
        assert.equals("Instance items",options[#options].label)
        for _,option in ipairs(addon:GetCraftingFarmingProfessionOptions()) do
            assert.is_true(option.id ~= "raidItems")
        end
        addon:SetCraftingFarmingProfessionFilter("raidItems")
        found = {}
        for _,row in ipairs(addon:BuildCraftingFarmingRows({deferMetrics=true})) do
            if row.itemID then found[row.itemID] = true end
        end
        for id in pairs(delveIDs) do assert.is_true(found[id]) end
    end)

    it("keeps the instance grouping synchronized between normal and expanded Materials views",function()
        local ns = LoadCatalogs()
        local addon = BuildMaterials(ns)
        addon.craftingFarmingFrame.raidMaterialsExpanded = true
        addon.FormatMoney = function(_,value) return tostring(value) end
        addon.GetCraftingFarmingWindowRow = function() return nil end
        addon.RefreshCraftingFarmingWindowLayout = function() end
        addon.UpdateCraftingFarmingSortHeaderState = function() end
        addon.craftingFarmingFrame.content = {SetHeight=function() end}
        addon.craftingFarmingExpandedFrame = {content={SetHeight=function() end},rows={},IsShown=function() return true end}
        loader.with_globals({time=os.time,date=os.date},function()
            addon:RefreshCraftingFarmingWindow(false,{synchronous=true,skipControls=true})
        end)
        assert.equals(addon.craftingFarmingFrame.materialDisplayRows,addon.craftingFarmingExpandedFrame.materialDisplayRows)
        local found = {}
        for _,row in ipairs(addon.craftingFarmingExpandedFrame.materialDisplayRows) do
            if delveIDs[row.itemID] then found[row.itemID] = true end
        end
        assert.same(delveIDs,found)
    end)
end)
