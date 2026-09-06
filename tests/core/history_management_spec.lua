local loader = require("tests.helpers.addon_loader")

local function build_addon(history)
    local addon = {
        db = {
            sessionHistory = history or {},
            nextHistoryID = 100,
        },
        Trim = function(_, text)
            if type(text) ~= "string" then
                return ""
            end
            return text:gsub("^%s+", ""):gsub("%s+$", "")
        end,
        GetValueSourceLabel = function(_, _, fallback)
            return fallback or "Unknown"
        end,
        NormalizeValueSourceLabel = function(_, label)
            return label or "Unknown"
        end,
        GetItemQualityFromLink = function()
            return 2
        end,
        IsCraftingReagentItem = function()
            return false
        end,
        GetHighlightThreshold = function()
            return 100
        end,
        GetCurrentValueSource = function()
            return { id = "A", label = "Market Value" }
        end,
        BuildHistorySessionName = function(_, saved_at, data)
            return string.format("%s @ %d", data and (data.zoneName or data.instanceName) or "Session", saved_at or 0)
        end,
    }
    return loader.with_globals({
        time = function()
            return 5000
        end,
        date = function(format, timestamp)
            return os.date(format, timestamp)
        end,
    }, function()
        return loader.load_module("Core/History.lua", addon)
    end)
end

describe("Core/History management", function()
    it("sorts pinned history sessions before recent unpinned sessions", function()
        local addon = build_addon({
            { id = 1, savedAt = 100, pinned = false },
            { id = 2, savedAt = 50, pinned = true },
            { id = 3, savedAt = 200, pinned = false },
        })

        local sorted = addon:GetSortedSessionHistory()

        assert.equals(2, sorted[1].id)
        assert.equals(3, sorted[2].id)
        assert.equals(1, sorted[3].id)
    end)

    it("deletes, bulk-deletes, pins, and renames sessions while refreshing views", function()
        local refresh_count = 0
        local details_count = 0
        local list_shown = false
        local addon = build_addon({
            { id = 1, name = "One" },
            { id = 2, name = "Two" },
            { id = 3, name = "Three" },
        })
        addon.historyFrame = { view = "details", selectedSessionID = 2 }
        addon.RefreshHistoryWindow = function()
            refresh_count = refresh_count + 1
        end
        addon.RefreshHistoryDetailsWindow = function()
            details_count = details_count + 1
        end
        addon.ShowHistoryListView = function()
            list_shown = true
        end

        assert.is_true(addon:DeleteHistorySession(2))
        assert.is_true(list_shown)
        assert.equals(2, #addon.db.sessionHistory)
        assert.equals(1, refresh_count)
        assert.equals(1, details_count)

        assert.is_true(addon:ToggleHistorySessionPinned(1))
        assert.is_true(addon.db.sessionHistory[1].pinned)
        assert.is_true(addon:RenameHistorySession(1, "  Renamed  "))
        assert.equals("Renamed", addon.db.sessionHistory[1].name)

        assert.equals(1, addon:DeleteHistorySessions({ "3", "missing" }))
        assert.equals(1, #addon.db.sessionHistory)
    end)

    it("stamps newly saved sessions with the current character", function()
        local addon = build_addon()
        addon.session = {
            startTime = 100,
            stopTime = 200,
            goldLooted = 10,
            itemValue = 0,
            itemVendorValue = 0,
            highlightItemCount = 0,
            itemLoots = {},
            moneyLoots = {},
            zoneName = "Elwynn Forest",
        }

        local entry = loader.with_globals({
            date = function(format, timestamp)
                return os.date(format, timestamp)
            end,
            UnitFullName = function(unit)
                assert.equals("player", unit)
                return "Mimi", "Silvermoon"
            end,
            GetRealmName = function()
                return "Fallback"
            end,
        }, function()
            return addon:CreateSessionHistoryEntry("stop")
        end)

        assert.equals("Mimi", entry.savedByCharacterName)
        assert.equals("Silvermoon", entry.savedByRealmName)
        assert.equals("Mimi - Silvermoon", entry.savedBy)
        assert.same({ "Mimi - Silvermoon" }, entry.savedByCharacters)
    end)

    it("merges selected sessions into a single aggregate and removes sources", function()
        local addon = build_addon({
            {
                id = 1,
                name = "First",
                startTime = 100,
                stopTime = 200,
                rawGold = 10,
                itemsValue = 100,
                valueSourceID = "A",
                valueSourceLabel = "Market Value",
                savedBy = "Mimi - Silvermoon",
                savedByCharacters = { "Mimi - Silvermoon" },
                itemLoots = {
                    { itemLink = "item-a", quantity = 1, totalValue = 100, timestamp = 150, ahTracked = true },
                },
            },
            {
                id = 2,
                startTime = 250,
                stopTime = 350,
                rawGold = 20,
                itemsValue = 200,
                valueSourceID = "B",
                valueSourceLabel = "Min Buyout",
                savedBy = "Beti - Draenor",
                savedByCharacters = { "Beti - Draenor" },
                moneyLoots = {
                    { amount = 20, timestamp = 300 },
                },
                items = {
                    { itemLink = "item-b", quantity = 2, totalValue = 200 },
                },
            },
            { id = 3, startTime = 400, stopTime = 450 },
        })

        local merged = addon:MergeHistorySessions({ 1, 2 })

        assert.equals(100, merged.id)
        assert.equals("merge", merged.saveReason)
        assert.equals(30, merged.rawGold)
        assert.equals(300, merged.itemsValue)
        assert.equals(330, merged.totalValue)
        assert.equals("MERGED", merged.valueSourceID)
        assert.equals("Mimi - Silvermoon, Beti - Draenor", merged.savedBy)
        assert.same({ "Mimi - Silvermoon", "Beti - Draenor" }, merged.savedByCharacters)
        assert.equals(2, #merged.itemLoots)
        assert.equals(2, #merged.moneyLoots)
        assert.same({ 1, 2 }, merged.mergedFromSessionIDs)
        assert.equals(2, #addon.db.sessionHistory)
        assert.equals(merged, addon.db.sessionHistory[1])
        assert.equals(3, addon.db.sessionHistory[2].id)
    end)

    it("splits a detailed history session by loot location", function()
        local addon = build_addon({
            {
                id = 1,
                savedAt = 1000,
                startTime = 100,
                stopTime = 400,
                zoneName = "Fallback",
                mapID = 9,
                savedBy = "Mimi - Silvermoon",
                savedByCharacters = { "Mimi - Silvermoon" },
                valueSourceID = "A",
                valueSourceLabel = "Market Value",
                itemLoots = {
                    {
                        itemLink = "item-a",
                        quantity = 1,
                        totalValue = 150,
                        timestamp = 110,
                        locationKey = "zone:A:1",
                        locationLabel = "Zone A",
                        zoneName = "A",
                        mapID = 1,
                        ahTracked = true,
                    },
                    {
                        itemLink = "item-b",
                        quantity = 1,
                        totalValue = 20,
                        timestamp = 310,
                        locationKey = "zone:B:2",
                        locationLabel = "Zone B",
                        zoneName = "B",
                        mapID = 2,
                        ahTracked = true,
                    },
                },
                moneyLoots = {
                    { amount = 5, timestamp = 120, locationKey = "zone:A:1", locationLabel = "Zone A" },
                },
            },
        })

        local split_entries = loader.with_globals({
            time = function()
                return 5000
            end,
            date = function(format, timestamp)
                return os.date(format, timestamp)
            end,
        }, function()
            return addon:SplitHistorySessionByLocation(1)
        end)

        assert.equals(2, #split_entries)
        assert.equals("split", split_entries[1].saveReason)
        assert.equals("Zone A", split_entries[1].locationLabel)
        assert.equals("Mimi - Silvermoon", split_entries[1].savedBy)
        assert.equals(155, split_entries[1].totalValue)
        assert.equals(1, #split_entries[1].itemLoots)
        assert.equals(1, #split_entries[1].moneyLoots)
        assert.equals("Zone B", split_entries[2].locationLabel)
        assert.equals("Mimi - Silvermoon", split_entries[2].savedBy)
        assert.equals(2, #addon.db.sessionHistory)
        assert.equals(100, addon.db.sessionHistory[1].id)
        assert.equals(101, addon.db.sessionHistory[2].id)
    end)
end)
