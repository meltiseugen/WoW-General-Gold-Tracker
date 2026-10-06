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
    local chunk, err = loadfile("Data/MountFarms.lua")
    assert(chunk, err)
    chunk("General-Gold-Tracker", ns)
    return ns
end

describe("Data/MountFarms", function()
    it("indexes researched guides for every Drops Mounts item", function()
        local ns = load_mount_farms()
        local expectedItemIDs = { 67151, 116794, 163573, 163575, 163576, 163574, 163131 }

        assert.equals(7, #ns.MountFarmData.farms)
        assert.equals("2026-10-03", ns.MountFarmData.researchedAt)
        assert.equals(7, ns.FarmCatalog.farmCount)
        assert.equals(7, ns.FarmCatalog.uniqueItemCount)
        assert.equals(7, ns.FarmCatalog.sourceCounts.curatedMounts)

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

        assert.equals(7, #second.FarmCatalog.farms)
        assert.equals(7, second.FarmCatalog.uniqueItemCount)
        assert.equals(1, #second.FarmCatalog.indexes.byItemID[67151])
    end)
end)
