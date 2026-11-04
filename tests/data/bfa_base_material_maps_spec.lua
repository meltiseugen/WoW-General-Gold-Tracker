local ROOT = "Data/General-Gold-Tracker_Materials/"
local MODULE = "MaterialFarmingSpots/BattleForAzeroth/BaseMaterialMaps.lua"
local targets = { [153635] = true, [153636] = true, [153669] = true,
    [168662] = true, [154989] = true, [154990] = true, [163833] = true }
local function copy(value)
    if type(value) ~= "table" then return value end
    local result = {}
    for key, entry in pairs(value) do result[key] = copy(entry) end
    return result
end
local function load_maps()
    local ns = { GoldTracker = {} }
    assert(loadfile("Data/FarmingItems.lua"))("GGT", ns)
    for line in io.lines(ROOT .. "General-Gold-Tracker_Materials.toc") do
        line = line:gsub("\r", "")
        if line:match("%.lua$") and line ~= "Namespace.lua" and line ~= MODULE then
            assert(loadfile(ROOT .. line))("GGT", ns)
        end
    end
    local before, catalog = copy(ns.MaterialFarmingSpots.items), copy(ns.FarmingItems)
    assert(loadfile(ROOT .. MODULE))("GGT", ns)
    return ns, before, catalog
end

describe("BfA missing Materials maps", function()
    it("changes only the seven missing base maps and preserves all recipes and existing routes", function()
        local ns, before, catalog = load_maps()
        assert.same(catalog, ns.FarmingItems)
        local count = 0
        for id in pairs(ns.BfaMissingMaterialMapAudit.items) do
            assert.is_true(targets[id])
            assert.equals(0, #before[id].spots)
            assert.is_true(#ns.MaterialFarmingSpots.items[id].spots > 0)
            count = count + 1
        end
        assert.equals(7, count)
        for id, record in pairs(before) do
            if not targets[id] then assert.same(record, ns.MaterialFarmingSpots.items[id]) end
        end
        local first = copy(ns.MaterialFarmingSpots.items)
        assert(loadfile(ROOT .. MODULE))("GGT", ns)
        assert.same(first, ns.MaterialFarmingSpots.items)
    end)

    it("maps pigments to the correct input herbs with their complete route data and processing instructions", function()
        local ns, before = load_maps()
        for _, id in ipairs({ 153635, 153636, 153669, 168662 }) do
            local item = ns.MaterialFarmingSpots.items[id]
            local expected = id == 168662 and {168487} or {152505,152506,152507,152508,152509,152510,152511}
            assert.same(expected, item.mapInputItemIDs)
            local routes, count = {}, 0
            for _, herbID in ipairs(expected) do
                routes[herbID] = {}
                for _, spot in ipairs(before[herbID].spots) do
                    routes[herbID][spot.id] = spot
                    count = count + 1
                end
            end
            assert.equals(count, #item.spots)
            for _, spot in ipairs(item.spots) do
                local source = routes[spot.inputItemID][spot.inputRouteID]
                for _, field in ipairs({"coords","isRoute","routeExport","routeSource","sortOrder"}) do
                    assert.same(source[field], spot[field])
                end
                assert.is_truthy(spot.farmAction:find("Milling",1,true))
                assert.is_false(spot.inGameTested)
                assert.is_true(#spot.sourceUrls > 1)
                assert.is_true(#spot.tips > 0)
            end
            assert.is_nil(item.components)
        end
    end)

    it("uses navigation without fabricated pins for rotating Drust and Zandalari digsites", function()
        local ns = load_maps()
        for id, zones in pairs({ [154989] = {862,863,864}, [154990] = {896,895,942} }) do
            local item = ns.MaterialFarmingSpots.items[id]
            assert.equals(3, #item.spots)
            for index, spot in ipairs(item.spots) do
                assert.equals(zones[index], spot.mapID)
                assert.is_true(spot.mapOnly)
                assert.equals(0, #spot.coords)
                assert.is_false(spot.isRoute)
                assert.is_truthy(spot.farmAction:find("Survey",1,true))
            end
        end
    end)

    it("opens a sourced Waycrest entrance for the Raid items recipe and exposes all seven map flags", function()
        local ns = load_maps()
        assert(loadfile("Data/MaterialIndex.lua"))("GGT", ns)
        assert(loadfile("UI/CraftingFarmingWindow.lua"))("GGT", ns)
        for id in pairs(targets) do
            assert.is_true(ns.MaterialIndex.items[id].hasMap)
            local options = ns.GoldTracker:BuildMaterialFarmingMapOptions(id)
            assert.is_true(#options > 0)
            for _, option in ipairs(options) do
                local pin = (option.detailPins or option.pins)[1]
                assert.is_true(#pin.tips > 0)
                assert.is_true(#pin.sourceUrls > 0)
            end
        end
        local recipe = ns.MaterialFarmingSpots.items[163833]
        assert.equals("instance", recipe.acquisitionType)
        assert.equals("dungeon-boss-recipe", recipe.spots[1].routeType)
        assert.equals(896, recipe.spots[1].mapID)
        assert.equals(0.3389, recipe.spots[1].coords[1].x)
        assert.equals(0.1314, recipe.spots[1].coords[1].y)
        assert.is_truthy(recipe.spots[1].farmAction:find("Raal",1,true))
    end)
end)
