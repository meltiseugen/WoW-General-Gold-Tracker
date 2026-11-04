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
        assert.equals(123456, history.snapshots[1].dbMarket)
    end)

    it("preserves the first observation during the snapshot interval", function()
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
        assert.equals(100000, snapshots[1].selectedUnitValue)
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

    it("shows only catalogued materials in the price alerts view", function()
        local values = { DBMarket = 100000, DBMinBuyout = 100000 }
        local addon = load_market_history(values, {
            FarmingItems = { items = { { itemID = 12345, itemName = "Test Material" } } },
        })
        local nonMaterial = { itemID = 67890, itemName = "Non-material item" }

        with_time(1710000000, function()
            addon:StartKnownPriceScan()
            addon:RecordKnownPriceCandidate(nonMaterial)
        end)
        values.DBMarket = 200000
        values.DBMinBuyout = 200000
        with_time(1710003600, function()
            addon:StartKnownPriceScan()
            addon:RecordKnownPriceCandidate(nonMaterial)
        end)

        local rows, meta = addon:BuildPriceIncreaseAlertRows({ minimumValueCopper = 0 })
        assert.equals(1, #rows)
        assert.equals("Test Material", rows[1].itemName)
        assert.equals(1, meta.knownItemCount)
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

    it("scans only the material set consumed by alerts without walking bags or other catalogs", function()
        local addon = load_market_history({}, {
            FarmingItems = { items = { { itemID = 101 } } },
            MaterialFarmingSpots = { items = { [102] = { itemID = 102 } } },
            InstanceDropsData = { instances = { { loot = { { itemID = 103 } } } } },
            CatalogDropsData = { transmogs = { { itemID = 104 } } },
            RareDropsData = { rows = { { itemID = 105 } } },
            FarmCatalog = { farms = { { primaryItemID = 999, targets = { { itemID = 999 } } } } },
        })
        addon.db.sessionHistory = { { items = { { itemID = 106 } } } }
        addon.db.farmingItemFavorites = { favorite = { itemID = 107 } }
        addon.db.marketHistory.items["i:108"] = { itemID = 108, snapshots = {} }
        addon.BuildInventoryAuctionItemList = function()
            error("The material price scan must not scan bags")
        end

        local candidates = addon:BuildKnownPriceScanCandidates()
        local keys = {}
        for _, candidate in ipairs(candidates) do
            keys[candidate.itemKey] = true
        end
        for itemID = 101, 102 do
            assert.is_true(keys["i:" .. tostring(itemID)])
        end
        for itemID = 103, 109 do
            assert.is_nil(keys["i:" .. tostring(itemID)])
        end
        assert.is_nil(keys["i:999"])
    end)

    it("does not persist unpriced or non-material candidates", function()
        local addon = load_market_history({}, {
            FarmingItems = { items = { { itemID = 101 } } },
        })
        with_time(1710000000, function()
            assert.is_false(addon:RecordKnownPriceCandidate({ itemID = 101 }))
            assert.is_false(addon:RecordKnownPriceCandidate({ itemID = 999 }))
        end)
        assert.same({}, addon.db.knownPriceHistory.items)
    end)

    it("migrates known prices to priced materials while preserving other user data", function()
        local addon = load_market_history({}, {
            MaterialIndex = { items = { [101] = { itemID = 101 }, [102] = { itemID = 102 } } },
        })
        local material = { itemID = 101, sources = { dbMarket = { latest = { value = 500 } } } }
        addon.db.knownPriceHistory = { items = {
            ["i:101"] = material,
            ["i:102"] = { itemID = 102, sources = {} },
            ["i:999"] = { itemID = 999, sources = { dbMarket = { latest = { value = 1000 } } } },
        } }
        local sessions = { { id = "saved-session" } }
        local favorites = { favorite = { itemID = 999 } }
        addon.db.sessionHistory = sessions
        addon.db.farmingItemFavorites = favorites
        local store = addon:NormalizeKnownPriceHistory()
        assert.same({ ["i:101"] = material }, store.items)
        assert.equals(material, store.items["i:101"])
        assert.equals(sessions, addon.db.sessionHistory)
        assert.equals(favorites, addon.db.farmingItemFavorites)
        local retained = store.items
        addon:NormalizeKnownPriceHistory()
        assert.equals(retained, store.items)
    end)

    it("preserves every snapshot field through compaction and a saved-variable round trip", function()
        local addon = load_market_history()
        local original = {
            timestamp = 1710000000, dbMarket = 1234, dbRecent = 0, dbRegionSaleRate = 0.42,
            hourKey = "2024-03-09 16", date = "2024-03-09", hour = 16, weekday = 6,
            selectedSourceID = "TSM_DBMARKET", selectedUnitValue = 1234,
            quantity = 2, totalValue = 2468, extensionField = "preserve-me",
        }
        addon.db.marketHistory.items["i:101"] = { snapshots = { original } }
        local snapshot = addon:NormalizeMarketHistory().items["i:101"].snapshots[1]
        for field, value in pairs(original) do assert.equals(value, snapshot[field]) end
        assert.is_nil(snapshot.dbHistorical)
        snapshot.dbHistorical = 5678
        snapshot.dbHistorical = nil
        assert.is_nil(snapshot.dbHistorical)
        assert.is_false(rawget(snapshot, 6))

        local serialized = {}
        for key, value in pairs(snapshot) do serialized[key] = value end
        addon.db.marketHistory = { items = { ["i:101"] = { snapshots = { serialized } } } }
        local restored = addon:NormalizeMarketHistory().items["i:101"].snapshots[1]
        assert.equals(serialized, restored)
        for field, value in pairs(original) do assert.equals(value, restored[field]) end
        assert.is_nil(restored.dbHistorical)
    end)

    it("prunes snapshot arrays in place and avoids a full-history pass for every loot item", function()
        local addon = load_market_history()
        addon.db.marketHistoryMaxSnapshotsPerItem = 2
        local originalPrune = addon.PruneMarketHistory
        local pruneCalls = 0
        addon.PruneMarketHistory = function(self, now)
            pruneCalls = pruneCalls + 1
            return originalPrune(self, now)
        end
        with_time(1710000000, function()
            addon:RecordInventoryMarketSnapshots({ { itemID = 12345, itemLink = item_link } })
            addon:RecordInventoryMarketSnapshots({ { itemID = 12345, itemLink = item_link } })
        end)
        assert.equals(1, pruneCalls)
        local snapshots = addon.db.marketHistory.items["i:12345"].snapshots
        with_time(1710003600, function()
            addon:RecordInventoryMarketSnapshots({ { itemID = 12345, itemLink = item_link } })
        end)
        with_time(1710007200, function()
            addon:RecordInventoryMarketSnapshots({ { itemID = 12345, itemLink = item_link } })
        end)
        assert.equals(snapshots, addon.db.marketHistory.items["i:12345"].snapshots)
        assert.equals(2, #snapshots)
        assert.equals(1710003600, snapshots[1].timestamp)
    end)

    it("uses elapsed time across clock-hour boundaries without repeating price queries", function()
        local addon = load_market_history()
        local queries = 0
        local original = addon.GetTSMRawCustomValue
        addon.GetTSMRawCustomValue = function(...)
            queries = queries + 1
            return original(...)
        end
        local row = { itemID = 12345, value = 100, valueSourceID = "TSM_DBMINBUYOUT" }
        -- 59 seconds before an hour boundary, then one minute later.
        local start = 1710003541
        with_time(start, function() addon:RecordDisplayedItemMarketSnapshots(row) end)
        local firstQueries = queries
        row.value = 200
        with_time(start + 60, function() addon:RecordDisplayedItemMarketSnapshots(row) end)
        with_time(start + 3599, function() addon:RecordDisplayedItemMarketSnapshots(row) end)
        assert.equals(firstQueries, queries)
        local history = addon.db.marketHistory.items["i:12345"]
        assert.equals(1, #history.snapshots)
        assert.equals(start, history.snapshots[1].timestamp)
        assert.equals(100, history.snapshots[1].dbMinBuyout)
        with_time(start + 3600, function() addon:RecordDisplayedItemMarketSnapshots(row) end)
        assert.equals(2, #history.snapshots)
        assert.equals(200, history.snapshots[2].dbMinBuyout)
        assert.equals(100, history.snapshots[1].dbMinBuyout)
    end)

    it("honors a configurable interval independently for each item, even with unchanged prices", function()
        local addon = load_market_history()
        addon.db.marketHistorySnapshotIntervalMinutes = 10
        local row = { itemID = 12345, value = 100 }
        with_time(1710000000, function() addon:RecordDisplayedItemMarketSnapshots(row) end)
        with_time(1710000300, function()
            addon:RecordDisplayedItemMarketSnapshots({ row, { itemID = 67890, value = 200 } })
        end)
        with_time(1710000600, function()
            addon:RecordDisplayedItemMarketSnapshots({ row, { itemID = 67890, value = 200 } })
        end)
        assert.equals(2, #addon.db.marketHistory.items["i:12345"].snapshots)
        assert.equals(1, #addon.db.marketHistory.items["i:67890"].snapshots)
    end)

    it("ignores loading rows and unpriced discoveries so a later price can be saved immediately", function()
        local addon = load_market_history({})
        with_time(1710000000, function()
            addon:RecordDisplayedItemMarketSnapshots({ { rowType = "divider" }, { itemID = 12345, value = 0 } })
            addon:RecordDiscoveredItemMarketSnapshots({ itemID = 12345 })
            assert.is_nil(addon.db.marketHistory.items["i:12345"])
            addon:RecordDisplayedItemMarketSnapshots({ itemID = 12345, value = 100 })
        end)
        assert.equals(1, #addon.db.marketHistory.items["i:12345"].snapshots)
    end)

    it("keeps saved samples independent from reused rows and compact snapshot inputs", function()
        local addon = load_market_history({})
        local row = { itemID = 12345, value = 100, marketHistorySnapshot = { dbMinBuyout = 100 } }
        with_time(1710000000, function() addon:RecordDisplayedItemMarketSnapshots(row) end)
        local first = addon.db.marketHistory.items["i:12345"].snapshots[1]
        row.marketHistorySnapshot.dbMinBuyout = 200
        with_time(1710003600, function() addon:RecordDisplayedItemMarketSnapshots(row) end)
        assert.equals(100, first.dbMinBuyout)
        local copy = addon:GetMarketHistorySourceSnapshot(nil, 12345, first)
        copy.timestamp = 0
        assert.equals(1710000000, first.timestamp)
        assert.equals(200, addon.db.marketHistory.items["i:12345"].snapshots[2].dbMinBuyout)
    end)

    it("restores saved history and continues its per-item interval after reload", function()
        local addon = load_market_history({})
        with_time(1710000000, function()
            addon:RecordDisplayedItemMarketSnapshots({ itemID = 12345, value = 100 })
        end)
        local snapshot = addon.db.marketHistory.items["i:12345"].snapshots[1]
        local serialized = {}
        for k, v in pairs(snapshot) do serialized[k] = v end
        addon = load_market_history({})
        addon.db.marketHistory.items["i:12345"] = { snapshots = { serialized } }
        with_time(1710003599, function() addon:RecordDisplayedItemMarketSnapshots({ itemID = 12345, value = 200 }) end)
        with_time(1710003600, function() addon:RecordDisplayedItemMarketSnapshots({ itemID = 12345, value = 300 }) end)
        local snapshots = addon.db.marketHistory.items["i:12345"].snapshots
        assert.equals(2, #snapshots)
        assert.equals(100, snapshots[1].selectedUnitValue)
        assert.equals(300, snapshots[2].selectedUnitValue)
    end)

    it("retires the legacy default item cap and retains more than 500 item histories", function()
        local addon = load_market_history()
        local rows = {}
        for id = 1, 650 do rows[#rows + 1] = { itemID = id, value = id } end
        with_time(1710000000, function() addon:RecordDisplayedItemMarketSnapshots(rows) end)
        assert.equals(0, addon.db.marketHistoryMaxItems)
        local count = 0
        for _ in pairs(addon.db.marketHistory.items) do count = count + 1 end
        assert.equals(650, count)
        -- A cap chosen after the migration remains effective.
        addon.db.marketHistoryMaxItems = 100
        addon:PruneMarketHistory(1710000000)
        count = 0
        for _ in pairs(addon.db.marketHistory.items) do count = count + 1 end
        assert.equals(100, count)
    end)

    it("preserves a custom item cap during migration", function()
        local addon = load_market_history()
        addon.db.marketHistoryMaxItems = 2000
        addon:NormalizeMarketHistory()
        assert.equals(2000, addon.db.marketHistoryMaxItems)
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
