local ROOT = "Data/General-Gold-Tracker_Materials/"
local MODULE = "MaterialFarmingSpots/Shadowlands/BaseMaterialMaps.lua"
local targets = {[173056]=true,[173057]=true,[175788]=true,[177061]=true,[189148]=true,[186017]=true}
local function copy(value)
    if type(value) ~= "table" then return value end
    local result = {}
    for key, entry in pairs(value) do result[key] = copy(entry) end
    return result
end
local function load_maps()
    local ns = {GoldTracker={}}
    assert(loadfile("Data/FarmingItems.lua"))("GGT",ns)
    for line in io.lines(ROOT .. "General-Gold-Tracker_Materials.toc") do
        line = line:gsub("\r","")
        if line:match("%.lua$") and line ~= "Namespace.lua" and line ~= MODULE then
            assert(loadfile(ROOT .. line))("GGT",ns)
        end
    end
    local before, catalog = copy(ns.MaterialFarmingSpots.items),copy(ns.FarmingItems)
    assert(loadfile(ROOT .. MODULE))("GGT",ns)
    return ns,before,catalog
end
describe("Shadowlands Materials maps and Protoform category",function()
    it("changes only six missing maps and preserves existing routes, other expansions and recipes",function()
        local ns,before,catalog = load_maps()
        assert.same(catalog,ns.FarmingItems)
        local count = 0
        for id in pairs(ns.ShadowlandsMissingMaterialMapAudit.items) do
            assert.is_true(targets[id])
            assert.equals(0,#before[id].spots)
            assert.is_true(#ns.MaterialFarmingSpots.items[id].spots > 0)
            count = count + 1
        end
        assert.equals(6,count)
        for id,record in pairs(before) do
            if not targets[id] then assert.same(record,ns.MaterialFarmingSpots.items[id]) end
        end
        local first = copy(ns.MaterialFarmingSpots.items)
        assert(loadfile(ROOT .. MODULE))("GGT",ns)
        assert.same(first,ns.MaterialFarmingSpots.items)
    end)
    it("moves all seventeen lattices to the scoped browsing category and updates the lightweight index",function()
        local ns = load_maps()
        assert(loadfile("Data/MaterialIndex.lua"))("GGT",ns)
        local category,count
        count = 0
        for _,option in ipairs(ns.FarmingItems.professions) do
            if option.id == "protoformLattices" then category = option end
        end
        assert.equals("shadowlands",category.expansion)
        assert.is_true(category.browsingOnly)
        for _,item in ipairs(ns.FarmingItems.items) do
            if item.tag == "Protoform Lattice" then
                count = count + 1
                assert.equals("shadowlands",item.expansion)
                assert.same({"protoformLattices"},item.professions)
                assert.same(item.professions,ns.MaterialFarmingSpots.items[item.itemID].professions)
                assert.same(item.professions,ns.MaterialIndex.items[item.itemID].professions)
            end
        end
        assert.equals(17,count)
        for id in pairs(targets) do assert.is_true(ns.MaterialIndex.items[id].hasMap) end
    end)
    it("retains complete input routes and separates processing and mining byproducts from direct drops",function()
        local ns,before = load_maps()
        for id in pairs({[173056]=true,[173057]=true,[175788]=true,[177061]=true}) do
            local item = ns.MaterialFarmingSpots.items[id]
            local inputs = id == 177061 and {171831} or {169701,168589,168586,170554,168583,171315,187699}
            assert.same(inputs,item.mapInputItemIDs)
            local lookup,count = {},0
            for _,inputID in ipairs(inputs) do
                lookup[inputID] = {}
                for _,spot in ipairs(before[inputID].spots) do
                    lookup[inputID][spot.id] = spot
                    count = count + 1
                end
            end
            assert.equals(count,#item.spots)
            for _,spot in ipairs(item.spots) do
                local source = lookup[spot.inputItemID][spot.inputRouteID]
                for _,field in ipairs({"coords","isRoute","routeExport","routeSource","sortOrder"}) do
                    assert.same(source[field],spot[field])
                end
                assert.is_false(spot.inGameTested)
                assert.is_true(#spot.tips > 0 and #spot.sourceUrls > 1)
                if id == 177061 then
                    assert.equals(1565,spot.mapID)
                    assert.is_truthy(spot.farmAction:find("Mine Phaedrum",1,true))
                else assert.is_truthy(spot.farmAction:find("Milling",1,true)) end
            end
            assert.is_nil(item.components)
        end
    end)
    it("uses source-area navigation for dynamic nests and Korthia rewards without fabricated pins",function()
        local ns = load_maps()
        assert.equals(1,#ns.MaterialFarmingSpots.items[189148].spots)
        assert.equals(3,#ns.MaterialFarmingSpots.items[186017].spots)
        assert(loadfile("UI/CraftingFarmingWindow.lua"))("GGT",ns)
        for id,mapID in pairs({[189148]=1970,[186017]=1961}) do
            for _,spot in ipairs(ns.MaterialFarmingSpots.items[id].spots) do
                assert.is_true(spot.mapOnly)
                assert.equals(mapID,spot.mapID)
                assert.equals(0,#spot.coords)
                assert.is_false(spot.isRoute)
            end
            local options = ns.GoldTracker:BuildMaterialFarmingMapOptions(id)
            assert.equals(#ns.MaterialFarmingSpots.items[id].spots,#options)
            for _,option in ipairs(options) do
                assert.equals(0,#option.pins)
                assert.is_nil(option.detailPins[1].x)
                assert.is_true(#option.detailPins[1].tips > 0)
            end
        end
    end)
end)
