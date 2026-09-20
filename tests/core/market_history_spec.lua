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
            return { addon:BuildPriceIncreaseAlertRows({ minimumValueCopper = 0 }) }
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
                    isCraftingReagent = true,
                },
            }, 160000, 1, 1, 1
        end

        local rows = with_time(1710200000, function()
            return addon:BuildPriceIncreaseAlertRows({ minimumValueCopper = 0 })
        end)

        assert.equals(1, #rows)
        assert.equals("TSM recent", rows[1].alertBasis)
        assert.equals(60, rows[1].tsmChangePercent)
        assert.equals(1, rows[1].localSampleCount)
    end)

    it("excludes non-material bag items from price increase alerts", function()
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

        local result = with_time(1710200000, function()
            return { addon:BuildPriceIncreaseAlertRows() }
        end)
        local rows, meta = result[1], result[2]

        assert.equals(0, #rows)
        assert.equals(1, meta.inventoryItemCount)
        assert.equals(0, meta.inventoryMaterialCount)
    end)

    it("includes indexed materials when TSM market is above historical", function()
        local addon = load_market_history({}, {
            MaterialFarmingSpots = {
                items = {
                    [123918] = {
                        itemID = 123918,
                        itemName = "Leystone Ore",
                        expansion = "legion",
                        professions = { "mining" },
                        category = "Ore",
                        spots = {
                            {
                                mapName = "Val'sharah",
                                coords = {
                                    { x = 0.45, y = 0.52 },
                                },
                            },
                        },
                    },
                },
            },
        })
        addon.BuildInventoryAuctionItemList = function()
            return {}, 0, 0, 0, 0
        end

        local result = with_time(1710200000, function()
            return { loader.with_globals({
                TSM_API = {
                    GetCustomPriceValue = function(source, item_string)
                        assert.equals("i:123918", item_string)
                        return ({
                            DBMarket = 141000,
                            DBHistorical = 100000,
                        })[source]
                    end,
                },
            }, function()
                return addon:BuildPriceIncreaseAlertRows({ minimumValueCopper = 0 })
            end) }
        end)
        local rows, meta = result[1], result[2]

        assert.equals(1, #rows)
        assert.equals(123918, rows[1].itemID)
        assert.equals("Leystone Ore", rows[1].itemName)
        assert.equals("TSM historical", rows[1].alertBasis)
        assert.equals(41, rows[1].tsmChangePercent)
        assert.is_true(rows[1].isIndexedMaterial)
        assert.is_true(rows[1].hasFarmingMap)
        assert.equals(1, meta.indexedMaterialCount)
    end)

    it("marks bag alert rows as indexed materials when their item ID has farming data", function()
        local leystone_link = "|cffffffff|Hitem:123918::::::::|h[Leystone Ore]|h|r"
        local addon = load_market_history({
            DBMarket = 141000,
            DBHistorical = 100000,
        }, {
            MaterialFarmingSpots = {
                items = {
                    [123918] = {
                        itemID = 123918,
                        itemName = "Leystone Ore",
                        expansion = "legion",
                        professions = { "mining" },
                        category = "Ore",
                        spots = {
                            {
                                mapName = "Val'sharah",
                                coords = {
                                    { x = 0.45, y = 0.52 },
                                },
                            },
                        },
                    },
                },
            },
        })
        addon.BuildInventoryAuctionItemList = function()
            return {
                {
                    itemID = 123918,
                    itemLink = leystone_link,
                    itemName = "Leystone Ore",
                    unitValue = 141000,
                    totalValue = 141000,
                },
            }, 141000, 1, 1, 1
        end

        local rows = with_time(1710200000, function()
            return addon:BuildPriceIncreaseAlertRows({ minimumValueCopper = 0 })
        end)

        assert.equals(1, #rows)
        assert.is_true(rows[1].isIndexedMaterial)
        assert.is_true(rows[1].hasFarmingMap)
        assert.equals("legion", rows[1].materialExpansionLabel)
    end)

    it("requires common quality and a default unit value of at least 30 gold", function()
        local addon = load_market_history({
            DBMarket = 300000,
            DBRecent = 200000,
            DBHistorical = 200000,
        })
        local receivedMinimumQuality
        local receivedMinimumValue
        addon.BuildInventoryAuctionItemList = function(_, _, minimumQuality, minimumValue)
            receivedMinimumQuality = minimumQuality
            receivedMinimumValue = minimumValue
            return {
                {
                    itemID = 12345,
                    itemLink = item_link,
                    itemName = "Test Green",
                    itemQuality = 1,
                    unitValue = 300000,
                    totalValue = 300000,
                    isCraftingReagent = true,
                },
            }, 300000, 1, 1, 1
        end

        local result = with_time(1710200000, function()
            return { addon:BuildPriceIncreaseAlertRows() }
        end)
        local rows, meta = result[1], result[2]

        assert.equals(1, #rows)
        assert.equals(1, receivedMinimumQuality)
        assert.equals(299999, receivedMinimumValue)
        assert.equals(300000, meta.minimumValueCopper)
    end)

    it("excludes poor-quality materials before reading their prices", function()
        local priceReads = 0
        local addon = load_market_history()
        addon.GetTSMRawCustomValue = function()
            priceReads = priceReads + 1
            return 500000
        end
        addon.BuildInventoryAuctionItemList = function()
            return {
                {
                    itemID = 12345,
                    itemLink = item_link,
                    itemName = "Poor Material",
                    itemQuality = 0,
                    unitValue = 500000,
                    totalValue = 500000,
                    isCraftingReagent = true,
                },
            }, 500000, 1, 1, 1
        end

        local rows = with_time(1710200000, function()
            return addon:BuildPriceIncreaseAlertRows()
        end)

        assert.equals(0, #rows)
        assert.equals(0, priceReads)
    end)

    it("excludes poor-quality indexed materials before querying TSM", function()
        local priceReads = 0
        local addon = load_market_history({}, {
            MaterialFarmingSpots = {
                items = {
                    [123918] = {
                        itemID = 123918,
                        itemName = "Poor Ore",
                        category = "Ore",
                    },
                },
            },
        })
        addon.BuildInventoryAuctionItemList = function()
            return {}, 0, 0, 0, 0
        end

        local result = with_time(1710200000, function()
            return { loader.with_globals({
                C_Item = {
                    GetItemInfo = function()
                        return "Poor Ore", "|cff9d9d9d|Hitem:123918::::::::|h[Poor Ore]|h|r", 0
                    end,
                },
                TSM_API = {
                    GetCustomPriceValue = function()
                        priceReads = priceReads + 1
                        return 500000
                    end,
                },
            }, function()
                return addon:BuildPriceIncreaseAlertRows()
            end) }
        end)
        local rows, meta = result[1], result[2]

        assert.equals(0, #rows)
        assert.equals(0, priceReads)
        assert.equals(0, meta.indexedMaterialCount)
    end)

    it("stops indexed-material pricing after the cheap value check fails", function()
        local priceReads = 0
        local addon = load_market_history({}, {
            MaterialFarmingSpots = {
                items = {
                    [123918] = {
                        itemID = 123918,
                        itemName = "Leystone Ore",
                        category = "Ore",
                    },
                },
            },
        })
        addon.BuildInventoryAuctionItemList = function()
            return {}, 0, 0, 0, 0
        end

        local rows = with_time(1710200000, function()
            return loader.with_globals({
                TSM_API = {
                    GetCustomPriceValue = function(source, itemString)
                        priceReads = priceReads + 1
                        assert.equals("i:123918", itemString)
                        if source == "DBMarket" then
                            return 299999
                        end
                        return 200000
                    end,
                },
            }, function()
                return addon:BuildPriceIncreaseAlertRows()
            end)
        end)

        assert.equals(0, #rows)
        assert.equals(1, priceReads)
    end)
end)
