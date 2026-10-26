local ROOT = "Data/General-Gold-Tracker_Materials/"
local MODULE = "MaterialFarmingSpots/Warlords/BaseMaterialMaps.lua"
local function copy(value)
    if type(value) ~= "table" then return value end
    local result = {}
    for key, entry in pairs(value) do result[key] = copy(entry) end
    return result
end
local function load_maps()
    local ns = {}
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

describe("Draenor base Materials map research", function()
    it("covers the base list without changing any composed record or another expansion", function()
        local ns, before, catalog = load_maps()
        assert.same(catalog, ns.FarmingItems)
        local expected, actual = {}, 0
        for _, row in ipairs(catalog.items) do
            if row.expansion == "warlords" and (type(row.components) ~= "table" or #row.components == 0) then
                expected[row.itemID] = true
            end
        end
        for id, coverage in pairs(ns.DraenorBaseMaterialMapAudit.items) do
            actual = actual + 1
            assert.is_true(expected[id])
            assert.is_true(coverage.mapOptionCount > 0)
        end
        assert.equals(90, actual)
        for id, record in pairs(before) do
            if not expected[id] then assert.same(record, ns.MaterialFarmingSpots.items[id], "out-of-scope item " .. id) end
        end
        local first = copy(ns.MaterialFarmingSpots)
        assert(loadfile(ROOT .. MODULE))("GGT", ns)
        assert.same(first, ns.MaterialFarmingSpots)
    end)

    it("provides distinct, sourced map choices with valid geometry or explicit area navigation", function()
        local ns = load_maps()
        local allowed = {[525]=true,[534]=true,[535]=true,[539]=true,[542]=true,[543]=true,[550]=true,[582]=true,[588]=true,[590]=true}
        for id in pairs(ns.DraenorBaseMaterialMapAudit.items) do
            local seen = {}
            for _, spot in ipairs(ns.MaterialFarmingSpots.items[id].spots) do
                assert.is_nil(seen[spot.id], "duplicate map choice for " .. id .. ": " .. tostring(spot.id))
                seen[spot.id] = true
                assert.is_true(allowed[spot.mapID] == true)
                assert.is_true(#spot.sourceUrls > 0)
                assert.is_true(#spot.tips > 0)
                assert.is_true(spot.mapOnly == true or #spot.coords > 0)
                if spot.mapOnly then assert.equals(0, #spot.coords) end
                for _, coord in ipairs(spot.coords) do
                    assert.is_true(coord.x >= 0 and coord.x <= 1)
                    assert.is_true(coord.y >= 0 and coord.y <= 1)
                end
            end
        end
        assert.equals(3, #ns.DraenorBaseMaterialMapAudit.rejectedSpots)
    end)

    it("keeps exact fish species and sizes on the same correct source zones without duplicate pond choices", function()
        local ns = load_maps()
        local items = ns.MaterialFarmingSpots.items
        for _, id in ipairs({109142,111658,111665,111672,110292}) do
            local coast, ponds = {}, 0
            for _, spot in ipairs(items[id].spots) do
                if spot.mapOnly then ponds = ponds + 1 else coast[spot.mapID] = true end
            end
            assert.equals(2, ponds)
            assert.is_true(coast[550] and coast[525] and coast[542])
            assert.equals(5, #items[id].spots)
        end
        for _, id in ipairs({127991,128229}) do
            for _, spot in ipairs(items[id].spots) do assert.equals(534, spot.mapID) end
        end
        for _, id in ipairs({111650,111669,111676,110274}) do
            local ponds = 0
            for _, spot in ipairs(items[id].spots) do
                if spot.mapOnly then ponds = ponds + 1 else assert.equals(543, spot.mapID) end
            end
            assert.equals(2, ponds)
        end
    end)

    it("distinguishes indirect processing from direct drops without adding recipes", function()
        local ns = load_maps()
        for _, id in ipairs({114931,113261,113262,113263,113264,115504,113588}) do
            local item = ns.MaterialFarmingSpots.items[id]
            assert.is_nil(item.components)
            assert.is_true(#item.mapInputItemIDs > 0)
            for _, spot in ipairs(item.spots) do
                assert.is_string(spot.farmAction)
                assert.is_false(spot.isRoute)
                if spot.sourceItemID then assert.equals("processing-input-source",spot.routeType) end
            end
        end
        for _, spot in ipairs(ns.MaterialFarmingSpots.items[114931].spots) do
            assert.is_truthy(spot.farmAction:find("mill",1,true))
        end
    end)

    it("names rotating digsites and gated sources without inventing permanent pins", function()
        local ns = load_maps()
        local counts = {[109585]=9,[108439]=25,[109584]=15,[128313]=2,[128314]=2,[251766]=5,[109133]=2}
        for id, count in pairs(counts) do
            local item = ns.MaterialFarmingSpots.items[id]
            assert.equals(count, #item.spots)
            for _, spot in ipairs(item.spots) do
                assert.is_true(spot.mapOnly)
                assert.equals(0, #spot.coords)
                assert.is_string(spot.farmAction)
            end
        end
    end)
end)
