local loader = require("tests.helpers.addon_loader")

local function load_market_history(tsm_values)
    tsm_values = tsm_values or {
        DBMarket = 150000,
        DBHistorical = 175000,
        DBRegionMarketAvg = 200000,
        DBRegionSaleAvg = 225000,
        DBRegionSaleRate = 0.42,
        DBRegionSoldPerDay = 12.5,
    }

    local addon = {
        db = {
            marketHistory = {
                items = {},
            },
            marketHistoryRetentionDays = 120,
            marketHistoryMaxItems = 500,
            marketHistoryMaxSnapshotsPerItem = 240,
            priceIncreaseAlertThresholdPercent = 30,
            priceIncreaseAlertLookbackDays = 3,
            priceIncreaseAlertMinimumSamples = 2,
        },
        DEFAULTS = {
            marketHistoryRetentionDays = 120,
            marketHistoryMaxItems = 500,
            marketHistoryMaxSnapshotsPerItem = 240,
            priceIncreaseAlertThresholdPercent = 30,
            priceIncreaseAlertLookbackDays = 3,
            priceIncreaseAlertMinimumSamples = 2,
        },
        GetTSMItemStringFromLink = function(_, item_link)
            local item_id = tonumber(string.match(item_link or "", "item:(%d+)"))
            return item_id and ("i:" .. tostring(item_id)) or nil
        end,
        GetTSMRawCustomValue = function(_, source)
            return tsm_values[source]
        end,
        GetAuctionableInventoryValueSource = function()
            return { id = "TSM_DBMARKET" }
        end,
        GetConfiguredMinimumTrackedItemQuality = function()
            return 0
        end,
        FormatMoney = function(_, value)
            return tostring(value or 0)
        end,
    }

    return loader.load_module("Core/MarketHistory.lua", addon)
end

local function with_time(timestamp, callback)
    local original_time = _G.time
    local original_date = _G.date
    _G.time = function()
        return timestamp
    end
    _G.date = function(format, value)
        return os.date(format, value)
    end

    local ok, result = pcall(callback)
    _G.time = original_time
    _G.date = original_date
    if not ok then
        error(result, 0)
    end
    return result
end

describe("Core/MarketHistory", function()
    local item_link = "|cff1eff00|Hitem:12345::::::::|h[Test Green]|h|r"

    it("creates a market history entry from a row snapshot", function()
        local addon = load_market_history()

        with_time(1710000000, function()
            addon:RecordInventoryMarketSnapshots({
                {
                    itemID = 12345,
                    itemLink = item_link,
                    itemName = "Test Green",
                    itemQuality = 2,
                    valueSourceID = "TSM_DBMARKET",
                    unitValue = 123456,
                    quantity = 2,
                    totalValue = 246912,
                },
            })
        end)

        local history = addon.db.marketHistory.items["i:12345"]
        assert.is_table(history)
        assert.equals("Test Green", history.itemName)
        assert.equals(1, #history.snapshots)
        assert.equals("TSM_DBMARKET", history.snapshots[1].selectedSourceID)
        assert.equals(123456, history.snapshots[1].selectedUnitValue)
        assert.equals(246912, history.snapshots[1].totalValue)
        assert.equals(150000, history.snapshots[1].dbMarket)
    end)

    it("replaces the current-hour snapshot instead of appending duplicates", function()
        local addon = load_market_history()

        with_time(1710000000, function()
            addon:RecordInventoryMarketSnapshots({
                {
                    itemID = 12345,
                    itemLink = item_link,
                    itemName = "Test Green",
                    valueSourceID = "TSM_DBMARKET",
                    unitValue = 100000,
                },
            })
            addon:RecordInventoryMarketSnapshots({
                {
                    itemID = 12345,
                    itemLink = item_link,
                    itemName = "Test Green",
                    valueSourceID = "TSM_DBMARKET",
                    unitValue = 222222,
                },
            })
        end)

        local snapshots = addon.db.marketHistory.items["i:12345"].snapshots
        assert.equals(1, #snapshots)
        assert.equals(222222, snapshots[1].selectedUnitValue)
    end)

    it("appends a new snapshot in a later hour", function()
        local addon = load_market_history()

        with_time(1710000000, function()
            addon:RecordInventoryMarketSnapshots({
                {
                    itemID = 12345,
                    itemLink = item_link,
                    itemName = "Test Green",
                    valueSourceID = "TSM_DBMARKET",
                    unitValue = 100000,
                },
            })
        end)
        with_time(1710003600, function()
            addon:RecordInventoryMarketSnapshots({
                {
                    itemID = 12345,
                    itemLink = item_link,
                    itemName = "Test Green",
                    valueSourceID = "TSM_DBMARKET",
                    unitValue = 200000,
                },
            })
        end)

        local snapshots = addon.db.marketHistory.items["i:12345"].snapshots
        assert.equals(2, #snapshots)
        assert.equals(100000, snapshots[1].selectedUnitValue)
        assert.equals(200000, snapshots[2].selectedUnitValue)
    end)

    it("builds a price increase alert when local bag history rises by at least 30 percent", function()
        local addon = load_market_history({
            DBMarket = 150000,
            DBRecent = 140000,
            DBHistorical = 125000,
            DBRegionSaleRate = 0.25,
            DBRegionSoldPerDay = 5,
        })
        local now = 1710200000
        addon.db.marketHistory.items["i:12345"] = {
            itemKey = "i:12345",
            itemLink = item_link,
            itemName = "Test Green",
            snapshots = {
                {
                    timestamp = now - (2 * 86400),
                    date = "2024-03-10",
                    hourKey = "2024-03-10 10",
                    dbMarket = 100000,
                },
            },
        }
        addon.BuildInventoryAuctionItemList = function()
            return {
                {
                    itemID = 12345,
                    itemLink = item_link,
                    itemName = "Test Green",
                    itemQuality = 2,
                    quantity = 3,
                    unitValue = 150000,
                    totalValue = 450000,
                    categoryID = "crafting",
                    isCraftingReagent = true,
                },
            }, 450000, 3, 1, 1
        end

        local result = with_time(now, function()
            return { addon:BuildPriceIncreaseAlertRows() }
        end)
        local rows, meta = result[1], result[2]

        assert.equals(1, #rows)
        assert.equals("Test Green", rows[1].itemName)
        assert.equals("Local", rows[1].alertBasis)
        assert.equals(50, rows[1].localChangePercent)
        assert.is_true(rows[1].isMaterial)
        assert.equals(30, meta.thresholdPercent)
    end)

    it("does not build a price increase alert below the configured threshold", function()
        local addon = load_market_history({
            DBMarket = 129000,
            DBRecent = 100000,
            DBHistorical = 100000,
        })
        local now = 1710200000
        addon.db.marketHistory.items["i:12345"] = {
            itemKey = "i:12345",
            itemLink = item_link,
            itemName = "Test Green",
            snapshots = {
                {
                    timestamp = now - 86400,
                    date = "2024-03-11",
                    hourKey = "2024-03-11 10",
                    dbMarket = 100000,
                },
            },
        }
        addon.BuildInventoryAuctionItemList = function()
            return {
                {
                    itemID = 12345,
                    itemLink = item_link,
                    itemName = "Test Green",
                    unitValue = 129000,
                    totalValue = 129000,
                },
            }, 129000, 1, 1, 1
        end

        local rows = with_time(now, function()
            return addon:BuildPriceIncreaseAlertRows()
        end)

        assert.equals(0, #rows)
    end)

    it("can use TSM recent pricing when local history has not collected enough samples", function()
        local addon = load_market_history({
            DBMarket = 160000,
            DBRecent = 100000,
            DBHistorical = 120000,
        })
        addon.BuildInventoryAuctionItemList = function()
            return {
                {
                    itemID = 12345,
                    itemLink = item_link,
                    itemName = "Test Green",
                    unitValue = 160000,
                    totalValue = 160000,
                },
            }, 160000, 1, 1, 1
        end

        local rows = with_time(1710200000, function()
            return addon:BuildPriceIncreaseAlertRows()
        end)

        assert.equals(1, #rows)
        assert.equals("TSM recent", rows[1].alertBasis)
        assert.equals(60, rows[1].tsmChangePercent)
        assert.equals(1, rows[1].localSampleCount)
    end)
end)
