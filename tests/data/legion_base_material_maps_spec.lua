local ROOT = "Data/General-Gold-Tracker_Materials/"
local MODULE = "MaterialFarmingSpots/Legion/BaseMaterialMaps.lua"
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

describe("Legion base Materials map research", function()
    it("covers every base entry while preserving composed recipes and other expansions", function()
        local ns, before, catalog = load_maps()
        assert.same(catalog, ns.FarmingItems)
        local expected, count, composed = {}, 0, 0
        for _, row in ipairs(catalog.items) do
            if row.expansion == "legion" then
                if type(row.components) == "table" and #row.components > 0 then
                    composed = composed + 1
                else expected[row.itemID] = true end
            end
        end
        for id, coverage in pairs(ns.LegionBaseMaterialMapAudit.items) do
            count = count + 1
            assert.is_true(expected[id])
            assert.is_true(coverage.mapOptionCount > 0)
        end
        assert.equals(118, count)
        assert.equals(377, composed)
        for id, record in pairs(before) do
            if not expected[id] then assert.same(record, ns.MaterialFarmingSpots.items[id], "out-of-scope record " .. id) end
        end
        local first = copy(ns.MaterialFarmingSpots)
        assert(loadfile(ROOT .. MODULE))("GGT", ns)
        assert.same(first, ns.MaterialFarmingSpots)
    end)

    it("keeps all choices distinct, actionable and sourced with valid pins or explicit area navigation", function()
        local ns = load_maps()
        for id in pairs(ns.LegionBaseMaterialMapAudit.items) do
            local seen = {}
            for _, spot in ipairs(ns.MaterialFarmingSpots.items[id].spots) do
                assert.is_nil(seen[spot.id], "duplicate choice for " .. id)
                seen[spot.id] = true
                assert.is_number(spot.mapID)
                assert.is_string(spot.farmAction)
                assert.is_true(#spot.sourceUrls > 0)
                assert.is_true(#spot.tips > 0)
                assert.is_true(spot.mapOnly == true or #spot.coords > 0)
                if spot.mapOnly then assert.equals(0, #spot.coords) end
                for _, point in ipairs(spot.coords) do
                    assert.is_true(point.x >= 0 and point.x <= 1)
                    assert.is_true(point.y >= 0 and point.y <= 1)
                end
            end
        end
        assert.is_nil(next(ns.LegionBaseMaterialMapAudit.rejectedSpots))
    end)

    it("uses Empyrium for all six Argus epic gems and preserves separate route choices", function()
        local ns = load_maps()
        for _, id in ipairs({151718,151719,151720,151721,151722,151579}) do
            local item, zones, prospecting, trader, event = ns.MaterialFarmingSpots.items[id], {}, 0, false, false
            assert.same({151564}, item.mapInputItemIDs)
            assert.is_nil(item.components)
            for _, spot in ipairs(item.spots) do
                assert.is_false(spot.isRoute)
                if spot.routeType == "input-source-guidance" then
                    zones[spot.mapID] = true
                    prospecting = prospecting + 1
                    assert.is_truthy(spot.farmAction:find("Empyrium",1,true))
                    assert.is_false(spot.mapOnly == true)
                elseif spot.routeType == "event-vendor-cache" then event = true
                else
                    trader = true
                    assert.is_true(spot.mapOnly)
                    assert.is_truthy(spot.farmAction:find("10 Primal Sargerite",1,true))
                end
            end
            assert.is_true(zones[830] and zones[882] and zones[885])
            local oreRoutes = 0
            for _, spot in ipairs(ns.MaterialFarmingSpots.items[151564].spots) do
                if not spot.mapOnly then oreRoutes = oreRoutes + 1 end
            end
            assert.equals(oreRoutes, prospecting)
            assert.is_true(trader and event)
        end
        for id = 130172,130183 do
            assert.same({123918,123919},ns.MaterialFarmingSpots.items[id].mapInputItemIDs)
        end
    end)

    it("keeps bait chains in their correct freshwater zones and labels expiring shark bait", function()
        local ns = load_maps()
        local groups = {
            {630,{133701,133702,133703,133704}}, {641,{133705,133707,133708}},
            {650,{133709,133710,133711,133712}}, {634,{133713,133714,133715,133716}},
            {680,{133717,133719,133720}},
        }
        for _, group in ipairs(groups) do
            for _, id in ipairs(group[2]) do
                for _, spot in ipairs(ns.MaterialFarmingSpots.items[id].spots) do
                    assert.equals(group[1],spot.mapID)
                end
            end
        end
        for _, spot in ipairs(ns.MaterialFarmingSpots.items[133710].spots) do
            assert.is_truthy(spot.farmAction:find("Bitestone Fishbrul",1,true))
        end
        for _, spot in ipairs(ns.MaterialFarmingSpots.items[133723].spots) do
            assert.is_truthy(table.concat(spot.tips," "):find("one minute",1,true))
        end
    end)

    it("preserves imported herb and ore route coordinates, order, tips and provenance", function()
        local ns, before, catalog = load_maps()
        for _, row in ipairs(catalog.items) do
            if row.expansion == "legion" and (row.tag == "Herb" or row.tag == "Ore" or row.itemID == 124444) then
                local after = {}
                for _, spot in ipairs(ns.MaterialFarmingSpots.items[row.itemID].spots) do after[spot.id] = spot end
                for _, spot in ipairs(before[row.itemID].spots) do
                    assert.is_truthy(after[spot.id])
                    for _, field in ipairs({"coords","tips","isRoute","routeExport","routeSource","sortOrder"}) do
                        assert.same(spot[field],after[spot.id][field],"route field " .. field .. " for " .. spot.id)
                    end
                end
            end
        end
    end)

    it("makes each covered entry discoverable through the lightweight index", function()
        local ns = load_maps()
        assert(loadfile("Data/MaterialIndex.lua"))("GGT", ns)
        for id in pairs(ns.LegionBaseMaterialMapAudit.items) do
            assert.is_true(ns.MaterialIndex.items[id].hasMap, "index lacks Map for " .. id)
        end
    end)
end)
