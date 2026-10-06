local loader = require("tests.helpers.addon_loader")

local function load_market_history(tsm_values, ns_overrides)
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

    return loader.load_module("Core/MarketHistory.lua", addon, ns_overrides)
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

    it("captures every graph price source as soon as an item is discovered", function()
        local addon = load_market_history({
            DBMarket = 101000,
            DBRecent = 102000,
            DBMinBuyout = 103000,
            DBHistorical = 104000,
            DBRegionMarketAvg = 105000,
            DBRegionHistorical = 106000,
            DBRegionSaleAvg = 107000,
            DBRegionSaleRate = 0.25,
            DBRegionSoldPerDay = 4.5,
            AuctioningOpMin = 108000,
            AuctioningOpNormal = 109000,
            AuctioningOpMax = 110000,
        })

        with_time(1710000000, function()
            local count = addon:RecordDiscoveredItemMarketSnapshots({
                {
                    itemID = 12345,
                    itemLink = item_link,
                    itemName = "Test Green",
                    valueSourceID = "TSM_DBMARKET",
                    unitValue = 101000,
                },
                {
                    itemID = 12345,
                    itemLink = item_link,
                    itemName = "Duplicate scan row",
                    unitValue = 999999,
                },
            })
            assert.equals(1, count)
        end)

        local snapshot = addon.db.marketHistory.items["i:12345"].snapshots[1]
        assert.equals(101000, snapshot.dbMarket)
        assert.equals(102000, snapshot.dbRecent)
        assert.equals(103000, snapshot.dbMinBuyout)
        assert.equals(104000, snapshot.dbHistorical)
        assert.equals(105000, snapshot.dbRegionMarketAvg)
        assert.equals(106000, snapshot.dbRegionHistorical)
        assert.equals(107000, snapshot.dbRegionSaleAvg)
        assert.equals(0.25, snapshot.dbRegionSaleRate)
        assert.equals(4.5, snapshot.dbRegionSoldPerDay)
        assert.equals(108000, snapshot.auctioningMin)
        assert.equals(109000, snapshot.auctioningNormal)
        assert.equals(110000, snapshot.auctioningMax)
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

    it("alerts on a Min Buyout increase even when DBMarket decreases", function()
        local values = { DBMarket = 848467, DBMinBuyout = 649900 }
        local addon = load_market_history(values, {
            FarmingItems = { items = { { itemID = 29547, itemName = "Wind Scales" } } },
        })

        with_time(1710000000, function()
            addon:StartKnownPriceScan()
        end)
        values.DBMarket = 757579
        values.DBMinBuyout = 2585700
        with_time(1710003600, function()
            addon:StartKnownPriceScan()
        end)

        local rows = addon:BuildPriceIncreaseAlertRows({ minimumValueCopper = 0 })
        assert.equals(1, #rows)
        assert.equals("Wind Scales", rows[1].itemName)
        assert.equals("Min Buyout", rows[1].alertBasis)
        assert.equals(-11, rows[1].dbMarketChangePercent)
        assert.equals(298, rows[1].dbMinBuyoutChangePercent)
    end)

    it("compares against the immediately previous scan instead of the first scan", function()
        local values = { DBMarket = 100000, DBMinBuyout = 100000 }
        local addon = load_market_history(values, {
            FarmingItems = { items = { { itemID = 12345, itemName = "Test Green" } } },
        })

        with_time(1710000000, function() addon:StartKnownPriceScan() end)
        values.DBMarket = 200000
        values.DBMinBuyout = 200000
        with_time(1710003600, function() addon:StartKnownPriceScan() end)
        values.DBMarket = 210000
        values.DBMinBuyout = 210000
        with_time(1710007200, function() addon:StartKnownPriceScan() end)

        local rows = addon:BuildPriceIncreaseAlertRows({ minimumValueCopper = 0 })
        assert.equals(0, #rows)
    end)

    it("builds a separate price decrease view from either tracked source", function()
        local values = { DBMarket = 200000, DBMinBuyout = 150000 }
        local addon = load_market_history(values, {
            FarmingItems = { items = { { itemID = 12345, itemName = "Test Green" } } },
        })

        with_time(1710000000, function() addon:StartKnownPriceScan() end)
        values.DBMarket = 100000
        values.DBMinBuyout = 145000
        with_time(1710003600, function() addon:StartKnownPriceScan() end)

        local increases = addon:BuildPriceIncreaseAlertRows({ minimumValueCopper = 0 })
        assert.equals(0, #increases)
        local rows = addon:BuildPriceDecreaseAlertRows({ minimumValueCopper = 0 })
        assert.equals(1, #rows)
        assert.equals("DBMarket", rows[1].alertBasis)
        assert.equals(-50, rows[1].changePercent)
    end)

    it("collects every known non-farm source and excludes FarmCatalog", function()
        local addon = load_market_history({}, {
            FarmingItems = { items = { { itemID = 101 } } },
            MaterialFarmingSpots = { items = { [102] = { itemID = 102 } } },
            InstanceDropsData = { instances = { { loot = { { itemID = 103 } } } } },
            WITDropsData = { transmogs = { { itemID = 104 } } },
            RareDropsData = { rows = { { itemID = 105 } } },
            FarmCatalog = { farms = { { primaryItemID = 999, targets = { { itemID = 999 } } } } },
        })
        addon.db.sessionHistory = { { items = { { itemID = 106 } } } }
        addon.db.farmingItemFavorites = { favorite = { itemID = 107 } }
        addon.db.marketHistory.items["i:108"] = { itemID = 108, snapshots = {} }
        addon.BuildInventoryAuctionItemList = function()
            return { { itemID = 109 } }
        end

        local candidates = addon:BuildKnownPriceScanCandidates()
        local keys = {}
        for _, candidate in ipairs(candidates) do
            keys[candidate.itemKey] = true
        end
        for itemID = 101, 109 do
            assert.is_true(keys["i:" .. tostring(itemID)])
        end
        assert.is_nil(keys["i:999"])
    end)

    it("keeps same-hour rescans in one snapshot slot", function()
        local values = { DBMarket = 100000, DBMinBuyout = 100000 }
        local addon = load_market_history(values, {
            FarmingItems = { items = { { itemID = 12345 } } },
        })
        with_time(1710000000, function() addon:StartKnownPriceScan() end)
        values.DBMarket = 150000
        with_time(1710000100, function() addon:StartKnownPriceScan() end)

        local sourceHistory = addon.db.knownPriceHistory.items["i:12345"].sources.dbMarket
        assert.is_nil(sourceHistory.previous)
        assert.equals(150000, sourceHistory.latest.value)
    end)
end)
