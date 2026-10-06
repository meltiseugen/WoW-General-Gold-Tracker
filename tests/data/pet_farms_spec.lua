local function load_pet_farms(catalog)
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

    local petsChunk, petsError = loadfile("Data/PetFarms.lua")
    assert(petsChunk, petsError)
    petsChunk("General-Gold-Tracker", ns)
    return ns
end

describe("Data/PetFarms", function()
    it("maps every Drops Pets row to exact research with at least one valid pin", function()
        local ns = load_pet_farms()
        local rows = ns.WITDropsData.categories.pets

        assert.equals(179, #rows)
        assert.equals(#rows, ns.PetFarmData.sourceRowCount)
        assert.equals(#rows, #ns.PetFarmData.farms)
        assert.equals("2026-10-03", ns.PetFarmData.researchedAt)
        assert.equals(#rows, ns.FarmCatalog.sourceCounts.curatedPets)

        local petRows = 0
        local collateralRows = 0
        local optionCount = 0
        local pinCount = 0
        for _, row in ipairs(rows) do
            local positions = ns.FarmCatalog.indexes.byRecordID[row.recordID]
            assert.is_table(positions, "missing record index for " .. tostring(row.recordID))
            assert.equals(1, #positions, "duplicate record index for " .. tostring(row.recordID))

            local farm = ns.FarmCatalog.farms[positions[1]]
            assert.equals(row.recordID, farm.sourceRecordID)
            assert.equals("GGTPetFarmData", farm.sourceDataset)
            assert.equals("pets", farm.sourceCategory)
            assert.equals("Drops > Pets", farm.sourcePath)
            assert.is_true(#farm.sourceUrls >= 2)
            assert.is_true(#farm.guide.tips >= 3)
            assert.equals(farm.routeCount, #farm.mapOptions)
            assert.is_true(#farm.mapOptions >= 1, "no map option for " .. tostring(row.recordID))

            if row.petID then
                petRows = petRows + 1
                assert.equals(row.petID, farm.primaryPetID)
                assert.is_nil(farm.primaryItemID)
                local petPositions = ns.FarmCatalog.indexes.byPetID[row.petID]
                assert.is_table(petPositions)
                assert.equals(1, #petPositions)
                assert.equals(positions[1], petPositions[1])
            else
                collateralRows = collateralRows + 1
                assert.equals(row.itemID, farm.primaryItemID)
            end

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

        assert.equals(138, petRows)
        assert.equals(41, collateralRows)
        assert.is_true(optionCount >= 179)
        assert.is_true(pinCount >= 179)
        assert.is_nil(ns.FarmCatalog.indexes.byItemID[82800], "shared pet cage item must never drive pet lookup")
    end)

    it("keeps pet identity exact when WIT farm IDs or cage item IDs collide", function()
        local ns = load_pet_farms()
        local oozeling = ns.FarmCatalog.farms[ns.FarmCatalog.indexes.byPetID[114][1]]
        local razormaw = ns.FarmCatalog.farms[ns.FarmCatalog.indexes.byPetID[238][1]]
        local nyalotha = ns.FarmCatalog.farms[ns.FarmCatalog.indexes.byPetID[2832][1]]

        assert.equals(51, oozeling.mapOptions[1].mapID)
        assert.equals(56, razormaw.mapOptions[1].mapID)
        assert.not_equals(oozeling.sourceRecordID, razormaw.sourceRecordID)
        assert.equals(2, #nyalotha.mapOptions)
        assert.equals(1527, nyalotha.mapOptions[1].mapID)
        assert.equals(1530, nyalotha.mapOptions[2].mapID)
    end)

    it("does not duplicate farms or indexes if the module is loaded twice", function()
        local first = load_pet_farms()
        local second = load_pet_farms(first.FarmCatalog)
        local firstRecordID = second.WITDropsData.categories.pets[1].recordID

        assert.equals(179, #second.FarmCatalog.farms)
        assert.equals(1, #second.FarmCatalog.indexes.byPetID[59])
        assert.equals(1, #second.FarmCatalog.indexes.byRecordID[firstRecordID])
    end)
end)
