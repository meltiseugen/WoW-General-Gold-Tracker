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

    local dropsChunk, dropsError = loadfile("Data/General-Gold-Tracker_Drops/CatalogDrops.lua")
    assert(dropsChunk, dropsError)
    dropsChunk("General-Gold-Tracker", ns)

    assert(loadfile("Data/General-Gold-Tracker_Farms/ToyAcquisitionResearch.lua"))("General-Gold-Tracker", ns)
    local toysChunk, toysError = loadfile("Data/General-Gold-Tracker_Farms/ToyFarms.lua")
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
        local rows = ns.CatalogDropsData.categories.toys

        assert.equals(8, #rows)
        assert.equals(36, ns.ToyFarmData.sourceRowCount)
        assert.equals(36, #ns.ToyFarmData.farms)
        assert.equals("2026-10-21", ns.ToyFarmData.researchedAt)
        assert.equals(36, ns.FarmCatalog.sourceCounts.curatedToys)

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

        assert.equals(8, optionCount)
        assert.equals(16, pinCount)
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
        local pearl = get_farm_for_item(ns, 108739)

        assert.equals(525, pearl.mapOptions[1].mapID)
        assert.equals(0.218, pearl.mapOptions[1].pins[1].x)
        assert.equals(0.097, pearl.mapOptions[1].pins[1].y)
        assert.matches("once%-per%-character", pearl.guide.tips[3])

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

        local toysChunk, toysError = loadfile("Data/General-Gold-Tracker_Farms/ToyFarms.lua")
        assert(toysChunk, toysError)
        toysChunk("General-Gold-Tracker", ns)

        assert.equals(initialFarmCount, #ns.FarmCatalog.farms)
        assert.equals(initialItemCount, ns.FarmCatalog.uniqueItemCount)
        assert.equals(36, ns.FarmCatalog.sourceCounts.curatedToys)
        for _, row in ipairs(ns.CatalogDropsData.categories.toys) do
            assert.equals(1, #ns.FarmCatalog.indexes.byRecordID[row.recordID])
            assert.equals(1, #ns.FarmCatalog.indexes.byItemID[row.itemID])
        end
    end)

    it("retains original row identity and adds saleable toy maps across every era", function()
        local ns = load_toy_farms()
        assert.equals(28, #ns.ToyAcquisitionResearch)
        assert.equals(36, #ns.ToyFarmData.rows)
        local seen, optionIDs, eras, optionCount, pinCount = {}, {}, {}, 0, 0
        for index, row in ipairs(ns.ToyFarmData.rows) do
            assert.is_nil(seen[row.itemID])
            seen[row.itemID] = true
            if index <= 8 then assert.equals(ns.CatalogDropsData.categories.toys[index], row) end
        end
        for _, research in ipairs(ns.ToyAcquisitionResearch) do
            eras[research.contentID] = true
            local farm = get_farm_for_item(ns, research.itemID)
            assert.is_true(farm.auctionable)
            assert.equals("unlearned-item", farm.saleMethod)
            assert.is_true(#farm.sourceUrls >= 4 and #farm.guide.tips >= 3)
            assert.is_true(#farm.guide.requirement > 0 and #farm.guide.action > 0)
            local seenMaps = {}
            for _, mapID in ipairs(farm.mapIDs) do
                assert.is_nil(seenMaps[mapID])
                seenMaps[mapID] = true
                local matches = 0
                for _, position in ipairs(ns.FarmCatalog.indexes.byMapID[mapID]) do
                    if ns.FarmCatalog.farms[position].id == farm.id then matches = matches + 1 end
                end
                assert.equals(1, matches)
            end
            for _, option in ipairs(farm.mapOptions) do
                optionCount = optionCount + 1
                assert.is_nil(optionIDs[option.id])
                optionIDs[option.id] = true
                assert.is_number(option.mapID)
                assert.is_string(option.mapRole)
                assert.is_false(option.isRoute)
                assert.is_true(#option.pins > 0)
                for _, pin in ipairs(option.pins) do
                    pinCount = pinCount + 1
                    assert.is_true(pin.x > 0 and pin.x < 1 and pin.y > 0 and pin.y < 1)
                    assert.is_true(#pin.label > 0)
                end
            end
        end
        for era = 1, 12 do assert.is_true(eras[era], "missing expansion era " .. era) end
        assert.equals(47, optionCount)
        assert.equals(62, pinCount)
        for _, itemID in ipairs({5507, 45854, 111820, 112384, 127668, 129055}) do
            assert.is_nil(seen[itemID]) -- Non-toys or bound outputs.
        end
        assert.equals("Cataclysm Engineering (70)", get_farm_for_item(ns, 60854).useRequirement)
        assert.equals(78, get_farm_for_item(ns, 248485).minimumUseLevel)
        assert.equals(2393, get_farm_for_item(ns, 248485).mapOptions[1].mapID)
    end)
end)
