local ROOT = "Data/General-Gold-Tracker_Materials/"
local MODULE = "MaterialFarmingSpots/Mists/BaseMaterialMaps.lua"

local function copy(value)
    if type(value) ~= "table" then return value end
    local result = {}
    for key, entry in pairs(value) do result[key] = copy(entry) end
    return result
end

local function load_maps()
    local ns = {}
    assert(loadfile("Data/FarmingItems.lua"))("General-Gold-Tracker", ns)
    for line in io.lines(ROOT .. "General-Gold-Tracker_Materials.toc") do
        line = line:gsub("\r", "")
        if line:match("%.lua$") and line ~= "Namespace.lua" and line ~= MODULE then
            assert(loadfile(ROOT .. line))("General-Gold-Tracker", ns)
        end
    end
    local catalogBefore = copy(ns.FarmingItems)
    local composedBefore = {}
    for _, row in ipairs(ns.FarmingItems.items) do
        if row.expansion == "mists" and type(row.components) == "table" and #row.components > 0 then
            composedBefore[row.itemID] = copy(ns.MaterialFarmingSpots.items[row.itemID])
        end
    end
    assert(loadfile(ROOT .. MODULE))("General-Gold-Tracker", ns)
    return ns, catalogBefore, composedBefore
end

describe("Pandaria base material map research", function()
    it("covers the 131 base items while leaving composed recipes and catalog definitions unchanged", function()
        local ns, catalogBefore, composedBefore = load_maps()
        assert.same(catalogBefore, ns.FarmingItems)
        local count, perfectCount = 0, 0
        local byID = {}
        for _, row in ipairs(ns.FarmingItems.items) do byID[row.itemID] = row end
        for itemID, coverage in pairs(ns.PandariaBaseMaterialMapAudit.items) do
            count = count + 1
            local row = byID[itemID]
            assert.equals("mists", row.expansion)
            assert.is_true(type(row.components) ~= "table" or #row.components == 0)
            assert.is_true(coverage.mapOptionCount > 0)
            if row.tag == "Perfect Gem" then perfectCount = perfectCount + 1 end
        end
        assert.equals(131, count)
        assert.equals(67, perfectCount)
        for itemID, research in pairs(composedBefore) do
            assert.same(research, ns.MaterialFarmingSpots.items[itemID], "composed item changed: " .. itemID)
        end
        local before = copy(ns.MaterialFarmingSpots)
        assert(loadfile(ROOT .. MODULE))("General-Gold-Tracker", ns)
        assert.same(before, ns.MaterialFarmingSpots)
    end)

    it("maps every Perfect cut to ore inputs without inventing guaranteed output recipes", function()
        local ns = load_maps()
        local ores = { [72092] = true, [72093] = true, [72094] = true, [72103] = true }
        for _, row in ipairs(ns.FarmingItems.items) do
            if row.expansion == "mists" and row.tag == "Perfect Gem" then
                local item = ns.MaterialFarmingSpots.items[row.itemID]
                assert.is_nil(item.components)
                assert.is_nil(item.recipeSpellID)
                assert.is_true(item.randomOutput)
                assert.equals(row.sourceSpellID, item.mapProcessing.sourceSpellID)
                assert.is_true(#item.spots >= 20)
                for _, spot in ipairs(item.spots) do
                    assert.is_true(ores[spot.sourceItemID])
                    assert.is_false(spot.isRoute)
                    assert.is_truthy(spot.farmAction:find("random Perfect cut", 1, true))
                    assert.is_true(#spot.tips >= 3)
                    assert.is_true(#spot.sourceUrls >= 3)
                end
            end
        end
        assert.equals(76136, ns.MaterialFarmingSpots.items[76628].mapProcessing.rawGemID)
        assert.equals(76135, ns.MaterialFarmingSpots.items[89676].mapProcessing.rawGemID)
        assert.equals(76137, ns.MaterialFarmingSpots.items[93707].mapProcessing.rawGemID)
    end)

    it("keeps rotating digsites and legacy gear sources navigable without fabricated spawn pins", function()
        local ns = load_maps()
        for _, itemID in ipairs({ 95373, 79868, 79869, 105718 }) do
            local item = ns.MaterialFarmingSpots.items[itemID]
            assert.is_true(#item.spots >= 3)
            for _, spot in ipairs(item.spots) do
                assert.is_true(spot.mapOnly)
                assert.equals(0, #spot.coords)
                assert.is_number(spot.mapID)
                assert.is_true(#spot.tips >= 3)
                assert.is_true(#spot.sourceUrls >= 2)
            end
        end
    end)

    it("keeps exact alternatives and valid coordinates while rejecting known map mix-ups", function()
        local ns = load_maps()
        for itemID in pairs(ns.PandariaBaseMaterialMapAudit.items) do
            local seen = {}
            for _, spot in ipairs(ns.MaterialFarmingSpots.items[itemID].spots) do
                assert.is_nil(seen[spot.id], "duplicate option: " .. tostring(spot.id))
                seen[spot.id] = true
                assert.not_equals(550, spot.mapID, "Draenor map cannot be a Pandaria material source")
                assert.is_number(spot.mapID)
                assert.is_true(#spot.sourceUrls > 0)
                assert.is_true(#spot.tips > 0)
                assert.is_true(spot.mapOnly == true or #spot.coords > 0)
                for _, coord in ipairs(spot.coords) do
                    assert.is_true(coord.x >= 0 and coord.x <= 1)
                    assert.is_true(coord.y >= 0 and coord.y <= 1)
                    assert.not_equals("Timeless Isle fallback pool", coord.label)
                end
            end
        end
        assert.equals(9, #ns.PandariaBaseMaterialMapAudit.rejectedSpots)
    end)
end)
