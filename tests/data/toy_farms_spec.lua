local function load_toy_farms(catalog)
    local ns = {
        FarmCatalog = catalog or {
            farms = {},
            byID = {},
            indexes = {},
            sourceCounts = {},
            uniqueItemCount = 0,
        },
    }

    local dropsChunk, dropsError = loadfile("Data/WITDrops.lua")
    assert(dropsChunk, dropsError)
    dropsChunk("General-Gold-Tracker", ns)

    local toysChunk, toysError = loadfile("Data/ToyFarms.lua")
    assert(toysChunk, toysError)
    toysChunk("General-Gold-Tracker", ns)
    return ns
end

local function get_farm_for_item(ns, itemID)
    local positions = ns.FarmCatalog.indexes.byItemID[itemID]
    assert.is_table(positions, "missing item index for " .. tostring(itemID))
    assert.equals(1, #positions, "duplicate item index for " .. tostring(itemID))
    return ns.FarmCatalog.farms[positions[1]]
end

describe("Data/ToyFarms", function()
    it("maps every Drops Toys row to exact research with at least one valid pin", function()
        local ns = load_toy_farms()
        local rows = ns.WITDropsData.categories.toys

        assert.equals(7, #rows)
        assert.equals(#rows, ns.ToyFarmData.sourceRowCount)
        assert.equals(#rows, #ns.ToyFarmData.farms)
        assert.equals("2026-10-03", ns.ToyFarmData.researchedAt)
        assert.equals(#rows, ns.FarmCatalog.sourceCounts.curatedToys)

        local optionCount = 0
        local pinCount = 0
        for _, row in ipairs(rows) do
            local recordPositions = ns.FarmCatalog.indexes.byRecordID[row.recordID]
            assert.is_table(recordPositions, "missing record index for " .. tostring(row.recordID))
            assert.equals(1, #recordPositions, "duplicate record index for " .. tostring(row.recordID))

            local itemPositions = ns.FarmCatalog.indexes.byItemID[row.itemID]
            assert.is_table(itemPositions, "missing item index for " .. tostring(row.itemID))
            assert.equals(1, #itemPositions, "duplicate item index for " .. tostring(row.itemID))
            assert.equals(recordPositions[1], itemPositions[1])

            local farm = ns.FarmCatalog.farms[recordPositions[1]]
            assert.equals(row.recordID, farm.sourceRecordID)
            assert.equals(row.itemID, farm.primaryItemID)
            assert.equals("GGTToyFarmData", farm.sourceDataset)
            assert.equals("toys", farm.sourceCategory)
            assert.equals("Drops > Toys", farm.sourcePath)
            assert.equals("toy", farm.activity)
            assert.is_true(#farm.sourceUrls >= 2)
            assert.is_true(#farm.guide.tips >= 3)
            assert.equals(farm.routeCount, #farm.mapOptions)
            assert.is_true(#farm.mapOptions >= 1, "no map option for " .. tostring(row.recordID))

            for _, option in ipairs(farm.mapOptions) do
                optionCount = optionCount + 1
                assert.is_number(option.mapID)
                assert.is_true(#option.pins >= 1)
                for _, pin in ipairs(option.pins) do
                    pinCount = pinCount + 1
                    assert.is_true(pin.x >= 0 and pin.x <= 1)
                    assert.is_true(pin.y >= 0 and pin.y <= 1)
                    assert.is_string(pin.label)
                end
            end
        end

        assert.equals(7, optionCount)
        assert.equals(15, pinCount)
    end)

    it("keeps every researched source and coordinate attached to the right toy", function()
        local ns = load_toy_farms()
        local worn = get_farm_for_item(ns, 36862)
        local decahedral = get_farm_for_item(ns, 36863)
        local loaded = get_farm_for_item(ns, 63269)
        local roller = get_farm_for_item(ns, 108631)
        local cannon = get_farm_for_item(ns, 108633)
        local mortar = get_farm_for_item(ns, 108634)
        local raygun = get_farm_for_item(ns, 142265)

        assert.equals(117, worn.mapOptions[1].mapID)
        assert.equals(4, #worn.mapOptions[1].pins)
        assert.equals(115, decahedral.mapOptions[1].mapID)
        assert.equals(4, #decahedral.mapOptions[1].pins)
        assert.equals(249, loaded.mapOptions[1].mapID)
        assert.equals(0.336, loaded.mapOptions[1].pins[1].x)
        assert.equals(0.270, loaded.mapOptions[1].pins[1].y)

        assert.equals(534, roller.mapOptions[1].mapID)
        assert.equals(0.839, roller.mapOptions[1].pins[1].x)
        assert.equals(0.432, roller.mapOptions[1].pins[1].y)
        assert.equals(0.807, cannon.mapOptions[1].pins[1].x)
        assert.equals(0.561, cannon.mapOptions[1].pins[1].y)
        assert.equals(0.875, mortar.mapOptions[1].pins[1].x)
        assert.equals(0.561, mortar.mapOptions[1].pins[1].y)

        assert.equals(70, raygun.mapOptions[1].mapID)
        assert.equals(0.778, raygun.mapOptions[1].pins[1].x)
        assert.equals(0.174, raygun.mapOptions[1].pins[1].y)
    end)

    it("does not duplicate catalog records when loaded again", function()
        local ns = load_toy_farms()
        local initialFarmCount = #ns.FarmCatalog.farms
        local initialItemCount = ns.FarmCatalog.uniqueItemCount

        local toysChunk, toysError = loadfile("Data/ToyFarms.lua")
        assert(toysChunk, toysError)
        toysChunk("General-Gold-Tracker", ns)

        assert.equals(initialFarmCount, #ns.FarmCatalog.farms)
        assert.equals(initialItemCount, ns.FarmCatalog.uniqueItemCount)
        assert.equals(7, ns.FarmCatalog.sourceCounts.curatedToys)
        for _, row in ipairs(ns.WITDropsData.categories.toys) do
            assert.equals(1, #ns.FarmCatalog.indexes.byRecordID[row.recordID])
            assert.equals(1, #ns.FarmCatalog.indexes.byItemID[row.itemID])
        end
    end)
end)
