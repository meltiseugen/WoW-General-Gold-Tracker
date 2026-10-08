local function load_location_data(includeWIT)
    local ns = {
        GoldTracker = {},
        JanisTheme = {},
    }
    assert(loadfile("Data/InstanceDrops.lua"))("General-Gold-Tracker", ns)
    assert(loadfile("Data/InstanceLocationOverrides.lua"))("General-Gold-Tracker", ns)
    if includeWIT then
        assert(loadfile("Data/WITDrops.lua"))("General-Gold-Tracker", ns)
        assert(loadfile("UI/InstanceFarmingWindow.lua"))("General-Gold-Tracker", ns)
    end
    return ns
end

local function count_keys(values)
    local count = 0
    for _ in pairs(values or {}) do
        count = count + 1
    end
    return count
end

local function find_instance(ns, journalInstanceID)
    for _, instance in pairs(ns.InstanceDropsData.instances or {}) do
        if tonumber(instance.encounterJournalID) == journalInstanceID then
            return instance
        end
    end
end

local function find_boss(instance, journalEncounterID)
    for _, boss in ipairs(instance and instance.bosses or {}) do
        if tonumber(boss.encounterJournalID) == journalEncounterID then
            return boss
        end
    end
end

describe("Data/InstanceLocationOverrides", function()
    it("stores researched entrance and boss pins with valid normalized coordinates", function()
        local ns = load_location_data(false)
        local research = ns.InstanceLocationResearch

        assert.equals("12.1.5.70077", research.clientBuild)
        assert.equals("2026-10-08", research.researchedAt)
        assert.equals(67, count_keys(research.entranceByJournalInstanceID))
        assert.equals(9, count_keys(research.bossByJournalEncounterID))
        assert.equals(3, count_keys(research.bossByInstanceAndName))

        for journalInstanceID, entrance in pairs(research.entranceByJournalInstanceID) do
            assert.is_number(entrance.mapID, "missing entrance map for " .. journalInstanceID)
            assert.is_true(entrance.x >= 0 and entrance.x <= 1)
            assert.is_true(entrance.y >= 0 and entrance.y <= 1)
        end

        local blackrockDepths = find_instance(ns, 228)
        assert.equals(32, blackrockDepths.entrance.mapID)
        local loregrain = find_boss(blackrockDepths, 373)
        assert.equals(243, loregrain.mapID)
        assert.equals(0.549180, loregrain.x)
        assert.equals(0.948770, loregrain.y)
    end)

    it("gives every WIT noteworthy row a static entrance and all researched sources a boss pin", function()
        local ns = load_location_data(true)
        local rows = ns.GoldTracker:BuildInstanceTransmogRows("all")
        local resolvedCount = 0
        local entranceCount = 0
        local bossPinCount = 0
        local researchedBossRow
        local trashRow
        local patternsRow

        for _, row in ipairs(rows) do
            if row.instanceEncounterJournalID then
                resolvedCount = resolvedCount + 1
            end
            if row.instanceEntrance then
                entranceCount = entranceCount + 1
            end
            if row.bossMapID and row.bossX and row.bossY then
                bossPinCount = bossPinCount + 1
            end
            if row.bossEncounterJournalID == 373 then
                researchedBossRow = row
            elseif not trashRow and row.bossName == "Trash Mobs" then
                trashRow = row
            end
            if not patternsRow and row.bossName == "Patterns/Plans" then
                patternsRow = row
            end
        end

        assert.equals(#rows, resolvedCount)
        assert.equals(#rows, entranceCount)
        assert.equals(37, bossPinCount)

        local bossOptions = ns.GoldTracker:BuildInstanceFarmingMapOptions(researchedBossRow)
        assert.equals(2, #bossOptions)
        assert.equals(32, bossOptions[1].mapID)
        assert.equals(0.275518, bossOptions[1].pins[1].x)
        assert.equals(243, bossOptions[2].mapID)
        assert.equals(0.549180, bossOptions[2].pins[1].x)

        local trashOptions = ns.GoldTracker:BuildInstanceFarmingMapOptions(trashRow)
        assert.equals(1, #trashOptions)
        assert.equals(trashRow.instanceEntrance.mapID, trashOptions[1].mapID)

        assert.is_table(patternsRow)
        local patternsOptions = ns.GoldTracker:BuildInstanceFarmingMapOptions(patternsRow)
        assert.equals(1, #patternsOptions)
        assert.equals(patternsRow.instanceEntrance.mapID, patternsOptions[1].mapID)
    end)
end)
