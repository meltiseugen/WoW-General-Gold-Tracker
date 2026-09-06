local loader = require("tests.helpers.addon_loader")

local function load_observed_drops(overrides)
    local addon = {
        db = {
            enableObservedWorldDrops = true,
            observedWorldDrops = {},
            observedSavedSessionDrops = {},
            observedSavedSessionDropsScannedAt = nil,
            observedWorldDropSessionImports = {},
            sessionHistory = {},
        },
        VALUE_SOURCE_BY_ID = {
            TSM_DBMARKET = {
                id = "TSM_DBMARKET",
                label = "Market Value",
                tsmKey = "DBMarket",
            },
            TSM_DBREGIONMARKETAVG = {
                id = "TSM_DBREGIONMARKETAVG",
                label = "Region Market Avg",
                tsmKey = "DBRegionMarketAvg",
            },
        },
        IsObservedWorldDropsEnabled = function(self)
            return self.db.enableObservedWorldDrops == true
        end,
        GetItemIDFromLink = function(_, item_link)
            return tonumber(string.match(item_link or "", "item:(%d+)"))
        end,
        GetTSMItemStringFromLink = function(self, item_link)
            local item_id = self:GetItemIDFromLink(item_link)
            return item_id and ("i:" .. tostring(item_id)) or nil
        end,
        GetTSMRawCustomValue = function(_, source)
            return ({
                DBMarket = 123456,
                DBRegionMarketAvg = 234567,
                DBRegionSaleAvg = 345678,
            })[source]
        end,
        GetValueSourceLabel = function(_, _, fallback)
            return fallback
        end,
    }

    for key, value in pairs(overrides or {}) do
        addon[key] = value
    end

    return loader.load_module("Tracking/ObservedDrops.lua", addon)
end

describe("Tracking/ObservedDrops", function()
    local item_link = "|cff1eff00|Hitem:99999::::::::|h[Observed Green]|h|r"
    local original_time

    before_each(function()
        original_time = _G.time
        _G.time = function()
            return 1710000000
        end
    end)

    after_each(function()
        _G.time = original_time
    end)

    it("records only enabled uncommon-or-better non-bound non-reagent world drops", function()
        local addon = load_observed_drops()

        assert.is_true(addon:ShouldRecordObservedWorldDrop(item_link, 2, false, false, { kind = "NPC" }))
        assert.is_true(addon:ShouldRecordObservedWorldDrop(item_link, 3, false, false, { kind = "NPC" }))
        assert.is_false(addon:ShouldRecordObservedWorldDrop(item_link, 1, false, false, { kind = "NPC" }))
        assert.is_false(addon:ShouldRecordObservedWorldDrop(item_link, 2, true, false, { kind = "NPC" }))
        assert.is_false(addon:ShouldRecordObservedWorldDrop(item_link, 2, false, true, { kind = "NPC" }))
        assert.is_false(addon:ShouldRecordObservedWorldDrop(item_link, 2, false, false, { kind = "Mining" }))
    end)

    it("does not record while the feature flag is disabled", function()
        local addon = load_observed_drops()
        addon.db.enableObservedWorldDrops = false

        assert.is_false(addon:RecordObservedWorldDrop(item_link, 1, 2, false, false, { kind = "NPC" }))
        assert.same({}, addon.db.observedWorldDrops)
    end)

    it("stores item, source, location, quantity, and TSM values", function()
        local addon = load_observed_drops()

        local recorded = addon:RecordObservedWorldDrop(
            item_link,
            3,
            2,
            false,
            false,
            { kind = "NPC", name = "Test Gnoll", text = "Test Gnoll" },
            {
                locationLabel = "Elwynn Forest 42.0,51.0",
                mapID = 37,
                mapName = "Elwynn Forest",
                expansionID = 0,
                expansionName = "Classic",
            },
            {
                selectedUnitValue = 111111,
                selectedValueSourceID = "TSM_DBMARKET",
                selectedValueSourceLabel = "Market Value",
            }
        )

        assert.is_true(recorded)
        local drop = addon.db.observedWorldDrops["i:99999"]
        assert.is_table(drop)
        assert.equals(99999, drop.itemID)
        assert.equals(item_link, drop.itemLink)
        assert.equals(2, drop.itemQuality)
        assert.equals(3, drop.totalQuantity)
        assert.equals(1, drop.seenCount)
        assert.equals(111111, drop.value)
        assert.equals(111111, drop.marketValue)
        assert.equals(234567, drop.regionMarketValue)
        assert.equals(345678, drop.averageValue)
        assert.equals("Elwynn Forest 42.0,51.0", drop.lastLocationLabel)
        assert.equals(3, drop.locations["Elwynn Forest 42.0,51.0"])
        assert.equals("Test Gnoll", drop.lastSourceText)
        assert.equals(3, drop.sources["Test Gnoll"])
    end)

    it("aggregates repeated sightings of the same item", function()
        local addon = load_observed_drops()

        addon:RecordObservedWorldDrop(
            item_link,
            1,
            2,
            false,
            false,
            { kind = "NPC", text = "First Mob" },
            { locationLabel = "Zone A" }
        )
        addon:RecordObservedWorldDrop(
            item_link,
            2,
            2,
            false,
            false,
            { kind = "NPC", text = "Second Mob" },
            { locationLabel = "Zone B" }
        )

        local drop = addon.db.observedWorldDrops["i:99999"]
        assert.equals(3, drop.totalQuantity)
        assert.equals(2, drop.seenCount)
        assert.equals(1, drop.locations["Zone A"])
        assert.equals(2, drop.locations["Zone B"])
        assert.equals(1, drop.sources["First Mob"])
        assert.equals(2, drop.sources["Second Mob"])
    end)

    it("saves eligible trash drops from saved sessions even when live collection is disabled", function()
        local addon = load_observed_drops()
        addon.db.enableObservedWorldDrops = false
        addon.db.sessionHistory = {
            {
                id = 42,
                valueSourceID = "TSM_DBMARKET",
                valueSourceLabel = "Market Value",
                expansionID = 0,
                expansionName = "Classic",
                locationLabel = "Stockades",
                itemLoots = {
                    {
                        itemLink = item_link,
                        quantity = 2,
                        unitValue = 111111,
                        itemQuality = 2,
                        isSoulbound = false,
                        isCraftingReagent = false,
                        timestamp = 1710000123,
                        lootSourceType = "NPC",
                        lootSourceName = "Prison Guard",
                        lootSourceText = "Prison Guard",
                        locationLabel = "Stormwind Stockade",
                        mapID = 225,
                        mapName = "Stormwind Stockade",
                        expansionID = 0,
                        expansionName = "Classic",
                    },
                },
            },
        }

        local result = addon:ScanSavedSessionsForObservedDrops()

        assert.equals(1, result.scannedSessions)
        assert.equals(1, result.scannedItems)
        assert.equals(1, result.eligibleItems)
        assert.equals(1, result.addedItems)
        assert.same({}, addon.db.observedWorldDrops)
        local drop = addon.db.observedSavedSessionDrops["i:99999"]
        assert.is_table(drop)
        assert.equals(2, drop.totalQuantity)
        assert.equals(1, drop.seenCount)
        assert.equals("Stormwind Stockade", drop.lastLocationLabel)
        assert.equals("Prison Guard", drop.lastSourceText)
        assert.equals("Classic", drop.lastExpansionName)
        assert.equals(111111, drop.value)
        assert.equals(1710000000, addon.db.observedSavedSessionDropsScannedAt)
    end)

    it("saves rare-quality saved trash drops and keeps their quality", function()
        local addon = load_observed_drops()
        local rare_item_link = "|cff0070dd|Hitem:22222::::::::|h[Blue Drop]|h|r"
        addon.db.sessionHistory = {
            {
                id = 43,
                itemLoots = {
                    {
                        itemLink = rare_item_link,
                        quantity = 1,
                        unitValue = 222222,
                        itemQuality = 3,
                        isSoulbound = false,
                        isCraftingReagent = false,
                        timestamp = 1710000300,
                        lootSourceType = "NPC",
                        lootSourceName = "Grom'kar Cauterizer",
                        lootSourceText = "AOE Unit: Grom'kar Cauterizer",
                        locationLabel = "Tanaan Jungle",
                        expansionName = "Warlords of Draenor",
                    },
                },
            },
        }

        local result = addon:ScanSavedSessionsForObservedDrops()

        assert.equals(1, result.eligibleItems)
        assert.equals(1, result.addedItems)
        local drop = addon.db.observedSavedSessionDrops["i:22222"]
        assert.is_table(drop)
        assert.equals(3, drop.itemQuality)
        assert.equals("AOE Unit: Grom'kar Cauterizer", drop.lastSourceText)
        assert.equals(222222, drop.value)
    end)

    it("saves epic-quality saved trash drops", function()
        local addon = load_observed_drops()
        local epic_item_link = "|cffa335ee|Hitem:33333::::::::|h[Purple Drop]|h|r"
        addon.db.sessionHistory = {
            {
                id = 44,
                itemLoots = {
                    {
                        itemLink = epic_item_link,
                        quantity = 1,
                        unitValue = 333333,
                        itemQuality = 4,
                        isSoulbound = false,
                        isCraftingReagent = false,
                        lootSourceType = "NPC",
                        lootSourceName = "Void Collector",
                        lootSourceText = "Void Collector",
                    },
                },
            },
        }

        local result = addon:ScanSavedSessionsForObservedDrops()

        assert.equals(1, result.eligibleItems)
        local drop = addon.db.observedSavedSessionDrops["i:33333"]
        assert.is_table(drop)
        assert.equals(4, drop.itemQuality)
    end)

    it("rebuilds the saved-session snapshot without duplicating entries", function()
        local addon = load_observed_drops()
        addon.db.sessionHistory = {
            {
                id = 7,
                itemLoots = {
                    {
                        itemLink = item_link,
                        quantity = 4,
                        itemQuality = 2,
                        timestamp = 1710000200,
                        lootSourceType = "AOE",
                        lootSourceIsAoe = true,
                    },
                },
            },
        }

        local first_result = addon:ScanSavedSessionsForObservedDrops()
        local second_result = addon:ScanSavedSessionsForObservedDrops()

        assert.equals(1, first_result.addedItems)
        assert.equals(1, second_result.addedItems)
        assert.equals(0, second_result.alreadyImportedItems)
        local drop = addon.db.observedSavedSessionDrops["i:99999"]
        assert.equals(4, drop.totalQuantity)
        assert.equals(1, drop.seenCount)
    end)

    it("skips saved session loot that is not trash or not eligible observed-drop loot", function()
        local addon = load_observed_drops()
        addon.db.sessionHistory = {
            {
                id = 11,
                itemLoots = {
                    {
                        itemLink = "|cff1eff00|Hitem:11111::::::::|h[Ore-Like Green]|h|r",
                        itemQuality = 2,
                        lootSourceType = "Mining",
                    },
                    {
                        itemLink = "|cffffffff|Hitem:22222::::::::|h[White Drop]|h|r",
                        itemQuality = 1,
                        lootSourceType = "NPC",
                    },
                    {
                        itemLink = "|cff1eff00|Hitem:33333::::::::|h[Bound Green]|h|r",
                        itemQuality = 2,
                        isSoulbound = true,
                        lootSourceType = "NPC",
                    },
                    {
                        itemLink = "|cff1eff00|Hitem:44444::::::::|h[Reagent Green]|h|r",
                        itemQuality = 2,
                        isCraftingReagent = true,
                        lootSourceType = "NPC",
                    },
                },
            },
        }

        local result = addon:ScanSavedSessionsForObservedDrops()

        assert.equals(4, result.scannedItems)
        assert.equals(0, result.eligibleItems)
        assert.equals(0, result.addedItems)
        assert.same({}, addon.db.observedWorldDrops)
        assert.same({}, addon.db.observedSavedSessionDrops)
    end)
end)
