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

    local dropsChunk, dropsError = loadfile("Data/CatalogDrops.lua")
    assert(dropsChunk, dropsError)
    dropsChunk("General-Gold-Tracker", ns)

    local petsChunk, petsError = loadfile("Data/PetFarms.lua")
    assert(petsChunk, petsError)
    petsChunk("General-Gold-Tracker", ns)
    return ns
end

describe("Data/PetFarms", function()
    it("maps outdoor and raid pet rows to exact research with at least one valid pin", function()
        local ns = load_pet_farms()
        local outdoorRows = ns.CatalogDropsData.categories.pets
        local raidRows = ns.CatalogDropsData.categories.raidPets
        local rows = ns.PetFarmData.rows

        assert.equals(47, #outdoorRows)
        assert.equals(91, #raidRows)
        assert.equals(#outdoorRows + #raidRows, ns.PetFarmData.sourceRowCount)
        assert.equals(147, ns.PetFarmData.curatedRowCount)
        assert.equals(#rows, #ns.PetFarmData.farms)
        assert.equals("2026-10-08", ns.PetFarmData.researchedAt)
        assert.equals(#rows, ns.FarmCatalog.sourceCounts.curatedPets)

        local petRows = 0
        local optionCount = 0
        local pinCount = 0
        for _, row in ipairs(rows) do
            local positions = ns.FarmCatalog.indexes.byRecordID[row.recordID]
            assert.is_table(positions, "missing record index for " .. tostring(row.recordID))
            assert.equals(1, #positions, "duplicate record index for " .. tostring(row.recordID))

            local farm = ns.FarmCatalog.farms[positions[1]]
            assert.equals(row.recordID, farm.sourceRecordID)
            assert.equals("GGTPetFarmData", farm.sourceDataset)
            local isRaidPet = row.recordID:match("^raidPets:") ~= nil
            assert.equals(isRaidPet and "raidPets" or "pets", farm.sourceCategory)
            assert.equals(isRaidPet and "Instances > Pets" or "Drops > Pets", farm.sourcePath)
            assert.is_true(#farm.sourceUrls >= 2)
            assert.is_true(#farm.guide.tips >= 3)
            assert.equals(farm.routeCount, #farm.mapOptions)
            assert.is_true(#farm.mapOptions >= 1, "no map option for " .. tostring(row.recordID))

            assert.is_number(row.petID)
            petRows = petRows + 1
            assert.equals(row.petID, farm.primaryPetID)
            assert.is_nil(farm.primaryItemID)
            local petPositions = ns.FarmCatalog.indexes.byPetID[row.petID]
            assert.is_table(petPositions)
            local foundExactFarm = false
            for _, petPosition in ipairs(petPositions) do
                if petPosition == positions[1] then
                    foundExactFarm = true
                    break
                end
            end
            assert.is_true(foundExactFarm, "missing pet index for " .. tostring(row.recordID))

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

        assert.equals(147, petRows)
        assert.is_true(optionCount >= 147)
        assert.is_true(pinCount >= 147)
        assert.is_nil(ns.FarmCatalog.indexes.byItemID and ns.FarmCatalog.indexes.byItemID[82800],
            "shared pet cage item must never drive pet lookup")

        local blackwingPets = {}
        for _, row in ipairs(rows) do
            if row.farmID == "BlackwingLairRaid" then
                blackwingPets[row.petID] = row.bossName
            end
        end
        assert.same({
            [1151] = "Razorgore the Untamed",
            [1152] = "Chromaggus",
            [1153] = "Broodlord Lashlayer",
        }, blackwingPets)

        local raidRecordID = raidRows[1].recordID
        assert.is_table(ns.FarmCatalog.indexes.byRecordID[raidRecordID])

        local researchedBossPets = 0
        for _, raidRow in ipairs(raidRows) do
            local position = ns.FarmCatalog.indexes.byRecordID[raidRow.recordID][1]
            local farm = ns.FarmCatalog.farms[position]
            if raidRow.petID ~= 1177 then -- Living Sandling drops from Sand Elemental trash.
                researchedBossPets = researchedBossPets + 1
                assert.is_number(farm.bossEncounterJournalID, "missing encounter for " .. raidRow.recordID)
                assert.is_number(farm.bossMapID, "missing boss map for " .. raidRow.recordID)
                assert.is_number(farm.bossX, "missing boss X for " .. raidRow.recordID)
                assert.is_number(farm.bossY, "missing boss Y for " .. raidRow.recordID)
                assert.equals(farm.bossMapID, farm.mapOptions[1].mapID)
                assert.equals(farm.bossX, farm.mapOptions[1].pins[1].x)
                assert.equals(farm.bossY, farm.mapOptions[1].pins[1].y)
                assert.equals("boss", farm.mapOptions[1].mapRole)
                assert.equals("entrance", farm.mapOptions[2].mapRole)
            end
        end
        assert.equals(90, researchedBossPets)

        local function RaidFarm(petID)
            return ns.FarmCatalog.farms[ns.FarmCatalog.indexes.byPetID[petID][1]]
        end
        assert.equals("Lei Shi", RaidFarm(2584).bossName)
        assert.equals("Icehowl", RaidFarm(1952).bossName)
        assert.equals("Icehowl", RaidFarm(1953).bossName)
        assert.equals("Conclave of the Chosen", RaidFarm(2527).bossName)
        assert.equals("The Hivemind", RaidFarm(2834).bossName)

        local discardedExperimentPositions = ns.FarmCatalog.indexes.byPetID[2079]
        assert.equals(1, #discardedExperimentPositions)
        local discardedExperiment = ns.FarmCatalog.farms[discardedExperimentPositions[1]]
        assert.equals("Instances > Pets", discardedExperiment.sourcePath)
        assert.equals("raidPets:BlackwingDecentPets:1", discardedExperiment.sourceRecordID)
    end)

    it("keeps pet identity exact when Catalog farm IDs or cage item IDs collide", function()
        local ns = load_pet_farms()
        local oozeling = ns.FarmCatalog.farms[ns.FarmCatalog.indexes.byPetID[114][1]]
        local razormaw = ns.FarmCatalog.farms[ns.FarmCatalog.indexes.byPetID[238][1]]
        local nyalotha = ns.FarmCatalog.farms[ns.FarmCatalog.indexes.byPetID[2832][1]]

        assert.equals(51, oozeling.mapOptions[1].mapID)
        assert.equals(56, razormaw.mapOptions[1].mapID)
        assert.not_equals(oozeling.sourceRecordID, razormaw.sourceRecordID)
        assert.equals(3, #nyalotha.mapOptions)
        assert.equals(1581, nyalotha.mapOptions[1].mapID)
        assert.equals(1527, nyalotha.mapOptions[2].mapID)
        assert.equals(1530, nyalotha.mapOptions[3].mapID)
    end)

    it("does not duplicate farms or indexes if the module is loaded twice", function()
        local first = load_pet_farms()
        local second = load_pet_farms(first.FarmCatalog)
        local firstRecordID = second.CatalogDropsData.categories.pets[1].recordID

        assert.equals(147, #second.FarmCatalog.farms)
        assert.equals(1, #second.FarmCatalog.indexes.byPetID[59])
        assert.equals(1, #second.FarmCatalog.indexes.byRecordID[firstRecordID])
    end)
end)
