local loader = require("tests.helpers.addon_loader")

local function load_rare(addon)
    return loader.with_globals({
        LE_ITEM_BIND_ON_ACQUIRE = 1,
        LE_ITEM_BIND_QUEST = 4,
    }, function()
        return loader.load_module("UI/RareFarmingWindow.lua", addon, {
            RareDropsData = {
                sourceVersion = "test",
                expansions = {
                    currentID = 1,
                    options = {
                        { id = 1, label = "Classic", current = true },
                    },
                },
                rares = {},
            },
        })
    end)
end

local function load_instance(addon)
    return loader.with_globals({
        LE_ITEM_BIND_ON_ACQUIRE = 1,
        LE_ITEM_BIND_ON_EQUIP = 2,
        LE_ITEM_BIND_ON_USE = 3,
        LE_ITEM_BIND_QUEST = 4,
    }, function()
        return loader.load_module("UI/InstanceFarmingWindow.lua", addon, {
            InstanceDropsData = {
                sourceVersion = "test",
                expansions = {
                    currentID = 1,
                    options = {
                        { id = 1, label = "Classic", current = true },
                    },
                },
                instances = {},
            },
        })
    end)
end

describe("UI farming scan caches", function()
    it("saves, loads, and deletes rare farming scan caches", function()
        local status_text = {}
        local addon = load_rare({
            db = {
                rareFarmingScanCache = {},
                rareFarmingValueSource = "TSM_DBMARKET",
                rareFarmingExpansionFilter = "1",
                rareFarmingMinimumValue = 1000,
                rareFarmingScanMode = "background",
            },
            DEFAULTS = {
                rareFarmingValueSource = "TSM_DBMARKET",
                rareFarmingExpansionFilter = "current",
                rareFarmingMinimumValue = 0,
                rareFarmingScanMode = "background",
            },
            VALUE_SOURCE_BY_ID = {
                TSM_DBMARKET = { id = "TSM_DBMARKET", label = "Market Value", tsmKey = "DBMarket" },
            },
            RecordRareFarmingMarketSnapshots = function() end,
        })
        addon.RefreshRareFarmingWindowControls = function() end
        addon.RefreshRareFarmingLibraryWindow = function() end
        addon.SetRareFarmingWindowView = function(_, view_id)
            addon.rareFarmingFrame.rareFarmingViewID = view_id
        end
        addon.rareFarmingFrame = {
            valueSourceID = "TSM_DBMARKET",
            expansionFilterID = "1",
            minimumValueCopper = 1000,
            lastResults = {},
            statusText = {
                SetText = function(_, text)
                    status_text[#status_text + 1] = text
                end,
            },
            progressBar = {
                SetMinMaxValues = function() end,
                SetValue = function() end,
            },
        }

        local entry, key = loader.with_globals({
            time = function()
                return 1000
            end,
            date = function()
                return "2026-08-27 12:00"
            end,
        }, function()
            return addon:SaveRareFarmingScanCache({
                valueSourceID = "TSM_DBMARKET",
                valueSourceLabel = "Market Value",
                expansionFilterID = "1",
                expansionFilterLabel = "Classic",
                minimumValueCopper = 1000,
                totalDrops = 5,
                results = {
                    { npcID = 1, rareName = "Rare", itemID = 10, itemName = "Item", value = 2000 },
                },
            })
        end)

        assert.is_table(entry)
        assert.equals(1, entry.resultCount)
        assert.equals(entry, addon.db.rareFarmingScanCache[key])

        addon:OpenRareFarmingSavedScan(key)
        assert.equals(key, addon.rareFarmingFrame.loadedRareFarmingCacheKey)
        assert.equals(1, #addon.rareFarmingFrame.lastResults)
        assert.matches("Loaded saved scan", status_text[#status_text])

        addon:DeleteRareFarmingSavedScan(key)
        assert.is_nil(addon.db.rareFarmingScanCache[key])
        assert.is_nil(addon.rareFarmingFrame.loadedRareFarmingCacheKey)
    end)

    it("updates rare saved-scan prices using the selected dropdown source", function()
        local addon = load_rare({
            db = {
                rareFarmingScanCache = {},
                rareFarmingValueSource = "TSM_DBMARKET",
                rareFarmingExpansionFilter = "1",
                rareFarmingMinimumValue = 1000,
                rareFarmingScanMode = "background",
            },
            DEFAULTS = {
                rareFarmingValueSource = "TSM_DBMARKET",
                rareFarmingExpansionFilter = "current",
                rareFarmingMinimumValue = 0,
                rareFarmingScanMode = "background",
            },
            VALUE_SOURCE_BY_ID = {
                TSM_DBMARKET = { id = "TSM_DBMARKET", label = "Market Value", tsmKey = "DBMarket" },
                TSM_DBREGIONMARKETAVG = {
                    id = "TSM_DBREGIONMARKETAVG",
                    label = "Region Market Avg",
                    tsmKey = "DBRegionMarketAvg",
                },
            },
            GetTSMItemValueForItemID = function(_, source)
                return ({
                    DBMarket = 1111,
                    DBRegionMarketAvg = 4444,
                    DBRegionSaleAvg = 2222,
                })[source] or 0
            end,
            RecordRareFarmingMarketSnapshots = function() end,
        })
        addon.RefreshRareFarmingWindowControls = function() end
        addon.RefreshRareFarmingLibraryWindow = function() end
        addon.RefreshRareFarmingWindow = function() end
        addon.SetRareFarmingWindowView = function(_, view_id)
            addon.rareFarmingFrame.rareFarmingViewID = view_id
        end
        addon.rareFarmingFrame = {
            valueSourceID = "TSM_DBMARKET",
            expansionFilterID = "1",
            minimumValueCopper = 1000,
            lastResults = {},
            statusText = { SetText = function(self, text) self.text = text end },
        }

        local entry, old_key = loader.with_globals({
            time = function()
                return 1000
            end,
            date = function()
                return "2026-08-27 12:00"
            end,
        }, function()
            return addon:SaveRareFarmingScanCache({
                valueSourceID = "TSM_DBMARKET",
                valueSourceLabel = "Market Value",
                expansionFilterID = "1",
                expansionFilterLabel = "Classic",
                minimumValueCopper = 1000,
                results = {
                    { npcID = 1, rareName = "Rare", itemID = 10, itemName = "Item", value = 1111 },
                },
            })
        end)

        assert.is_table(entry)
        addon:OpenRareFarmingSavedScan(old_key)
        addon:SetRareFarmingValueSource("TSM_DBREGIONMARKETAVG")
        assert.equals(1, #addon.rareFarmingFrame.lastResults)
        addon:UpdateCurrentRareFarmingScanPrices()

        local new_key = addon.rareFarmingFrame.loadedRareFarmingCacheKey
        assert.is_nil(addon.db.rareFarmingScanCache[old_key])
        assert.is_table(addon.db.rareFarmingScanCache[new_key])
        assert.equals("TSM_DBREGIONMARKETAVG", addon.db.rareFarmingScanCache[new_key].valueSourceID)
        assert.equals(4444, addon.rareFarmingFrame.lastResults[1].value)
        assert.equals("Region Market Avg", addon.rareFarmingFrame.lastResults[1].valueSourceLabel)
    end)

    it("saves instance farming scan caches and replaces existing keys", function()
        local addon = load_instance({
            db = {
                instanceFarmingScanCache = {},
                instanceFarmingValueSource = "TSM_DBMARKET",
                instanceFarmingExpansionFilter = "1",
                instanceFarmingContentTypeFilter = "raid",
                instanceFarmingMinimumValue = 1000,
                instanceFarmingScanMode = "background",
            },
            DEFAULTS = {
                instanceFarmingValueSource = "TSM_DBMARKET",
                instanceFarmingExpansionFilter = "current",
                instanceFarmingContentTypeFilter = "all",
                instanceFarmingMinimumValue = 0,
                instanceFarmingScanMode = "background",
            },
            VALUE_SOURCE_BY_ID = {
                TSM_DBMARKET = { id = "TSM_DBMARKET", label = "Market Value", tsmKey = "DBMarket" },
            },
        })

        local first, first_key = loader.with_globals({
            time = function()
                return 1000
            end,
            date = function()
                return "2026-08-27 12:00"
            end,
        }, function()
            return addon:SaveInstanceFarmingScanCache({
                expansionFilterID = "1",
                expansionFilterLabel = "Classic",
                contentTypeFilterID = "raid",
                contentTypeFilterLabel = "Raids",
                minimumValueCopper = 1000,
                valueSourceID = "TSM_DBMARKET",
                valueSourceLabel = "Market Value",
                results = {
                    { itemID = 20, itemName = "Drop", instanceName = "Raid", bossName = "Boss", value = 3000 },
                },
            })
        end)

        local second, second_key = loader.with_globals({
            time = function()
                return 2000
            end,
            date = function()
                return "2026-08-27 13:00"
            end,
        }, function()
            return addon:SaveInstanceFarmingScanCache({
                expansionFilterID = "1",
                contentTypeFilterID = "dungeon",
                minimumValueCopper = 2000,
                valueSourceID = "TSM_DBMARKET",
                valueSourceLabel = "Market Value",
                results = {
                    { itemID = 21, itemName = "Drop 2", instanceName = "Dungeon", bossName = "Boss", value = 4000 },
                },
            }, first_key)
        end)

        assert.equals(first_key, second_key)
        assert.is_true(first ~= second)
        assert.equals("dungeon", addon.db.instanceFarmingScanCache[first_key].contentTypeFilterID)
        assert.equals(1, addon.db.instanceFarmingScanCache[first_key].resultCount)
    end)

    it("updates instance saved-scan prices using the selected dropdown source", function()
        local addon = load_instance({
            db = {
                instanceFarmingScanCache = {},
                instanceFarmingValueSource = "TSM_DBMARKET",
                instanceFarmingExpansionFilter = "1",
                instanceFarmingContentTypeFilter = "raid",
                instanceFarmingMinimumValue = 1000,
                instanceFarmingScanMode = "background",
            },
            DEFAULTS = {
                instanceFarmingValueSource = "TSM_DBMARKET",
                instanceFarmingExpansionFilter = "current",
                instanceFarmingContentTypeFilter = "all",
                instanceFarmingMinimumValue = 0,
                instanceFarmingScanMode = "background",
            },
            VALUE_SOURCE_BY_ID = {
                TSM_DBMARKET = { id = "TSM_DBMARKET", label = "Market Value", tsmKey = "DBMarket" },
                TSM_DBREGIONMARKETAVG = {
                    id = "TSM_DBREGIONMARKETAVG",
                    label = "Region Market Avg",
                    tsmKey = "DBRegionMarketAvg",
                },
            },
            GetTSMItemValueForItemID = function(_, source)
                return ({
                    DBMarket = 1111,
                    DBRegionMarketAvg = 4444,
                    DBRegionSaleAvg = 2222,
                })[source] or 0
            end,
            RecordInstanceFarmingMarketSnapshots = function() end,
        })
        addon.RefreshInstanceFarmingWindowControls = function() end
        addon.RefreshInstanceFarmingLibraryWindow = function() end
        addon.RefreshInstanceFarmingWindow = function() end
        addon.SetInstanceFarmingWindowView = function(_, view_id)
            addon.instanceFarmingFrame.instanceFarmingViewID = view_id
        end
        addon.instanceFarmingFrame = {
            valueSourceID = "TSM_DBMARKET",
            expansionFilterID = "1",
            contentTypeFilterID = "raid",
            minimumValueCopper = 1000,
            lastResults = {},
            statusText = { SetText = function(self, text) self.text = text end },
        }

        local entry, key = loader.with_globals({
            time = function()
                return 1000
            end,
            date = function()
                return "2026-08-27 12:00"
            end,
        }, function()
            return addon:SaveInstanceFarmingScanCache({
                expansionFilterID = "1",
                expansionFilterLabel = "Classic",
                contentTypeFilterID = "raid",
                contentTypeFilterLabel = "Raids",
                minimumValueCopper = 1000,
                valueSourceID = "TSM_DBMARKET",
                valueSourceLabel = "Market Value",
                results = {
                    { itemID = 20, itemName = "Drop", instanceName = "Raid", bossName = "Boss", value = 1111 },
                },
            })
        end)

        assert.is_table(entry)
        addon:OpenInstanceFarmingSavedScan(key)
        addon:SetInstanceFarmingValueSource("TSM_DBREGIONMARKETAVG")
        assert.equals(1, #addon.instanceFarmingFrame.lastResults)
        loader.with_globals({
            time = function()
                return 2000
            end,
            date = function()
                return "2026-08-27 13:00"
            end,
        }, function()
            addon:UpdateCurrentInstanceFarmingScanPrices()
        end)

        assert.equals("TSM_DBREGIONMARKETAVG", addon.db.instanceFarmingScanCache[key].valueSourceID)
        assert.equals(4444, addon.instanceFarmingFrame.lastResults[1].value)
        assert.equals("Region Market Avg", addon.instanceFarmingFrame.lastResults[1].valueSourceLabel)
    end)
end)
