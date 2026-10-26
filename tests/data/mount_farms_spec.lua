local function load_mount_farms(catalog)
    local ns = {
        FarmCatalog = catalog or {
            farms = {},
            byID = {},
            indexes = {},
            sourceCounts = {},
            uniqueItemCount = 0,
        },
    }
    for _, path in ipairs({
        "Data/General-Gold-Tracker_Drops/CatalogDrops.lua",
        "Data/General-Gold-Tracker_Farms/MountAcquisitionResearch.lua",
        "Data/General-Gold-Tracker_Farms/MountFarms.lua",
    }) do assert(loadfile(path))("General-Gold-Tracker", ns) end
    return ns
end

describe("Data/MountFarms", function()
    it("indexes researched guides for every Drops Mounts item", function()
        local ns = load_mount_farms()
        local expectedItemIDs = { 67151, 116794, 163573, 163575, 163576, 163574, 163131 }

        assert.equals(27, #ns.MountFarmData.farms)
        assert.equals("2026-10-21", ns.MountFarmData.researchedAt)
        assert.equals(27, ns.FarmCatalog.farmCount)
        assert.equals(27, ns.FarmCatalog.uniqueItemCount)
        assert.equals(27, ns.FarmCatalog.sourceCounts.curatedMounts)

        local optionCount = 0
        local pinCount = 0
        for _, itemID in ipairs(expectedItemIDs) do
            local positions = ns.FarmCatalog.indexes.byItemID[itemID]
            assert.is_table(positions)
            assert.equals(1, #positions)

            local farm = ns.FarmCatalog.farms[positions[1]]
            assert.equals(itemID, farm.primaryItemID)
            assert.equals("GGTMountFarmData", farm.sourceDataset)
            assert.equals("curated", farm.sourceType)
            assert.equals("mounts", farm.sourceCategory)
            assert.is_true(#farm.guide.tips >= 3)
            assert.is_true(#farm.sourceUrls >= 2)
            assert.equals(farm.routeCount, #farm.mapOptions)

            for _, option in ipairs(farm.mapOptions) do
                optionCount = optionCount + 1
                assert.is_number(option.mapID)
                assert.is_true(#option.pins > 0)
                for _, pin in ipairs(option.pins) do
                    pinCount = pinCount + 1
                    assert.is_true(pin.x >= 0 and pin.x <= 1)
                    assert.is_true(pin.y >= 0 and pin.y <= 1)
                    assert.is_string(pin.label)
                end
            end
        end

        assert.equals(12, optionCount)
        assert.equals(79, pinCount)
    end)

    it("does not duplicate farms or indexes if the module is loaded twice", function()
        local first = load_mount_farms()
        local second = load_mount_farms(first.FarmCatalog)

        assert.equals(27, #second.FarmCatalog.farms)
        assert.equals(27, second.FarmCatalog.uniqueItemCount)
        assert.equals(1, #second.FarmCatalog.indexes.byItemID[67151])
    end)

    it("adds only saleable mount outputs and retains source roles and prerequisites", function()
        local ns = load_mount_farms()
        assert.equals(20, #ns.MountAcquisitionResearch)
        assert.equals(27, #ns.MountFarmData.rows)
        local seen, optionIDs, optionCount, pinCount = {}, {}, 0, 0
        for index, row in ipairs(ns.MountFarmData.rows) do
            assert.is_nil(seen[row.itemID])
            seen[row.itemID] = true
            if index <= 7 then
                assert.equals(ns.CatalogDropsData.categories.mounts[index], row)
            end
        end
        for _, research in ipairs(ns.MountAcquisitionResearch) do
            local positions = ns.FarmCatalog.indexes.byItemID[research.itemID]
            assert.equals(1, #positions)
            local farm = ns.FarmCatalog.farms[positions[1]]
            assert.is_true(farm.auctionable)
            assert.equals("unlearned-item", farm.saleMethod)
            assert.equals(positions[1], ns.FarmCatalog.indexes.byRecordID[farm.sourceRecordID][1])
            assert.is_true(#farm.guide.requirement > 0 and #farm.guide.action > 0)
            assert.is_true(#farm.guide.tips >= 3 and #farm.sourceUrls >= 4)
            for _, option in ipairs(farm.mapOptions) do
                optionCount = optionCount + 1
                assert.is_nil(optionIDs[option.id])
                optionIDs[option.id] = true
                assert.is_false(option.isRoute)
                assert.is_string(option.mapRole)
                assert.is_number(option.mapID)
                assert.is_true(#option.pins > 0)
                for _, pin in ipairs(option.pins) do
                    pinCount = pinCount + 1
                    assert.is_true(pin.x > 0 and pin.x < 1 and pin.y > 0 and pin.y < 1)
                    assert.is_true(#pin.label > 0)
                end
            end
        end
        assert.equals(33, optionCount)
        assert.equals(34, pinCount)
        assert.is_nil(seen[235712]) -- Void-Crystal Panther binds to Warband.
        assert.is_nil(seen[270058]) -- Rope Lynx Harness binds on pickup.
        assert.equals("Outland Engineering (1)", ns.FarmCatalog.farms[ns.FarmCatalog.indexes.byItemID[34060][1]].useRequirement)
        local pummeler = ns.FarmCatalog.farms[ns.FarmCatalog.indexes.byItemID[221967][1]]
        assert.equals(2214, pummeler.mapOptions[1].mapID)
        assert.equals(59.76 / 100, pummeler.mapOptions[1].pins[1].x)
    end)
end)
