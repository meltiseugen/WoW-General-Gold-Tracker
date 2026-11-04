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

    it("records uncommon-or-better non-bound non-reagent world drops", function()
        local addon = load_observed_drops()

        assert.is_true(addon:ShouldRecordObservedWorldDrop(item_link, 2, false, false, { kind = "NPC" }))
        assert.is_true(addon:ShouldRecordObservedWorldDrop(item_link, 3, false, false, { kind = "NPC" }))
        assert.is_false(addon:ShouldRecordObservedWorldDrop(item_link, 1, false, false, { kind = "NPC" }))
        assert.is_false(addon:ShouldRecordObservedWorldDrop(item_link, 2, true, false, { kind = "NPC" }))
        assert.is_false(addon:ShouldRecordObservedWorldDrop(item_link, 2, false, true, { kind = "NPC" }))
        assert.is_false(addon:ShouldRecordObservedWorldDrop(item_link, 2, false, false, { kind = "Mining" }))
    end)

    it("automatically adds eligible loot to Session Observed even with an old disabled flag", function()
        local addon = load_observed_drops()
        addon.db.enableObservedWorldDrops = false

        assert.is_true(addon:RecordObservedWorldDrop(item_link, 1, 2, false, false, { kind = "NPC" }))
        assert.equals(1, addon.db.observedSavedSessionDrops["i:99999"].totalQuantity)
        assert.equals(addon.db.observedWorldDrops, addon.db.observedSavedSessionDrops)
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
                mapX = 0.42,
                mapY = 0.51,
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
        assert.equals(37, drop.lootLocations[1].mapID)
        assert.equals(0.42, drop.lootLocations[1].mapX)
        assert.equals(0.51, drop.lootLocations[1].mapY)
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

    it("saves eligible Unit-sourced trash drops from saved sessions even when live collection is disabled", function()
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
                        lootSourceType = "Unit",
                        lootSourceName = "Prison Guard",
                        lootSourceText = "Prison Guard",
                        locationLabel = "Stormwind Stockade",
                        mapID = 225,
                        mapName = "Stormwind Stockade",
                        mapX = 0.3,
                        mapY = 0.7,
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
        local drop = addon.db.observedSavedSessionDrops["i:99999"]
        assert.equals(drop, addon.db.observedWorldDrops["i:99999"])
        assert.is_table(drop)
        assert.equals(2, drop.totalQuantity)
        assert.equals(1, drop.seenCount)
        assert.equals("Stormwind Stockade", drop.lastLocationLabel)
        assert.equals(225, drop.lootLocations[1].mapID)
        assert.equals(0.3, drop.lootLocations[1].mapX)
        assert.equals(0.7, drop.lootLocations[1].mapY)
        assert.equals("Prison Guard", drop.lastSourceText)
        assert.equals("Classic", drop.lastExpansionName)
        assert.equals(111111, drop.value)
        assert.equals(1710000000, addon.db.observedSavedSessionDropsScannedAt)
        assert.is_true(addon.db.observedSavedSessionDrops == addon.db.observedDropsShared.savedSessionDrops)
        assert.equals(1710000000, addon.db.observedDropsShared.savedSessionDropsScannedAt)
    end)

    it("retains distinct loot spots across scans without duplicate pins or borrowed coordinates", function()
        local addon = load_observed_drops()
        local function session(mapID, x, y)
            return {
                mapID = mapID, mapX = 0.99, mapY = 0.99,
                itemLoots = { {
                    itemLink = item_link, itemQuality = 2, lootSourceType = "Unit",
                    mapID = mapID, mapX = x, mapY = y,
                } },
            }
        end
        addon.db.sessionHistory = { session(37, 0, 1), session(37, 0, 1), session(100, 0.3, 0.4) }
        addon:ScanSavedSessionsForObservedDrops()
        local drop = addon.db.observedSavedSessionDrops["i:99999"]
        assert.equals(2, #drop.lootLocations)
        addon.db.sessionHistory = { session(225) }
        addon:ScanSavedSessionsForObservedDrops()
        addon:ScanSavedSessionsForObservedDrops()
        drop = addon.db.observedSavedSessionDrops["i:99999"]
        assert.equals(3, #drop.lootLocations)
        assert.equals(225, drop.lootLocations[3].mapID)
        assert.is_nil(drop.lootLocations[3].mapX)
        assert.is_nil(drop.lootLocations[3].mapY)
        assert.equals(0, drop.lootLocations[1].mapX)
        assert.equals(1, drop.lootLocations[1].mapY)
    end)

    it("recovers legacy observed loot coordinates from matching trash loot only", function()
        local addon = load_observed_drops()
        local drop = { itemKey = "i:99999", lastMapID = 37 }
        addon.db.sessionHistory = { {
            mapID = 37, mapX = 0.99, mapY = 0.99,
            itemLoots = {
                { itemLink = item_link, lootSourceType = "Unit", mapX = 0.42, mapY = 0.51 },
                { itemLink = item_link, lootSourceType = "Unit", mapX = 0.42, mapY = 0.51 },
                { itemLink = item_link, lootSourceType = "Mining", mapX = 0.2, mapY = 0.2 },
                { itemLink = "|Hitem:11111:|h[Other]|h", lootSourceType = "Unit", mapX = 0.1, mapY = 0.1 },
                { itemLink = item_link, lootSourceType = "Unit", mapID = 100, mapX = 2, mapY = 0.4 },
            },
        } }
        local locations = addon:GetObservedDropLootLocations(drop)
        assert.equals(3, #locations)
        assert.equals(37, locations[1].mapID)
        assert.equals(0.42, locations[1].mapX)
        assert.equals(0.51, locations[1].mapY)
        assert.equals(100, locations[2].mapID)
        assert.is_nil(locations[2].mapX)
        assert.is_nil(locations[2].mapY)
        assert.is_nil(drop.lootLocations)
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

    it("updates the saved-session list without duplicating entries", function()
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
        assert.equals(0, second_result.addedItems)
        assert.equals(1, second_result.updatedItems)
        assert.equals(1, second_result.alreadyImportedItems)
        local drop = addon.db.observedSavedSessionDrops["i:99999"]
        assert.equals(4, drop.totalQuantity)
        assert.equals(1, drop.seenCount)
    end)

    it("appends new sightings of an existing item after its earlier session leaves history", function()
        local addon = load_observed_drops()
        local function session(id, quantity, source)
            return { id = id, itemLoots = { {
                itemLink = item_link, itemQuality = 2, quantity = quantity,
                lootSourceType = "NPC", lootSourceText = source,
                locationLabel = source, mapID = id, mapX = 0.2, mapY = 0.3,
            } } }
        end
        addon.db.sessionHistory = { session(7, 4, "First mob") }
        addon:ScanSavedSessionsForObservedDrops()
        local list = addon.db.observedSavedSessionDrops
        local drop = list["i:99999"]
        addon.db.sessionHistory = { session(8, 2, "Second mob") }
        addon:ScanSavedSessionsForObservedDrops()
        addon:ScanSavedSessionsForObservedDrops()
        assert.equals(list, addon.db.observedSavedSessionDrops)
        assert.equals(drop, list["i:99999"])
        assert.equals(6, drop.totalQuantity)
        assert.equals(2, drop.seenCount)
        assert.equals(4, drop.sources["First mob"])
        assert.equals(2, drop.sources["Second mob"])
        assert.equals(2, #drop.lootLocations)
    end)

    it("does not import automatically captured loot again when its session is scanned", function()
        local addon = load_observed_drops()
        local recorded = addon:RecordObservedWorldDrop(item_link, 3, 2, false, false, { kind = "Unit" })
        addon.db.sessionHistory = { { itemLoots = { {
            itemLink = item_link, itemQuality = 2, quantity = 3, lootSourceType = "Unit",
            observedDropRecorded = recorded, mapID = 37, mapX = 0.42, mapY = 0.51,
        } } } }
        local result = addon:ScanSavedSessionsForObservedDrops()
        local drop = addon.db.observedSavedSessionDrops["i:99999"]
        assert.equals(1, result.alreadyImportedItems)
        assert.equals(3, drop.totalQuantity)
        assert.equals(1, drop.seenCount)
        assert.equals(0.42, drop.lootLocations[1].mapX)
        addon:UpdateObservedDropLootLocation(item_link, { mapID = 37, mapX = 0.4, mapY = 0.5 })
        assert.equals(3, drop.totalQuantity)
        assert.equals(2, #drop.lootLocations)
    end)

    it("migrates old live captures and scanned items without double counting their historical loot", function()
        local addon = load_observed_drops()
        local existing = { itemKey = "i:99999", itemLink = item_link, totalQuantity = 4, seenCount = 1 }
        addon.db.observedSavedSessionDrops["i:99999"] = existing
        addon.db.observedSavedSessionDropsScannedAt = 100
        addon.db.observedWorldDrops["i:88888"] = {
            itemKey = "i:88888", totalQuantity = 2, seenCount = 1, lastSeenAt = 90,
        }
        addon.db.sessionHistory = { { itemLoots = {
            { itemLink = item_link, itemQuality = 2, quantity = 4, lootSourceType = "Unit", timestamp = 80 },
            { itemLink = item_link, itemQuality = 2, quantity = 3, lootSourceType = "Unit", timestamp = 110 },
        } } }
        addon:ScanSavedSessionsForObservedDrops()
        addon:ScanSavedSessionsForObservedDrops()
        assert.equals(existing, addon.db.observedSavedSessionDrops["i:99999"])
        assert.equals(7, existing.totalQuantity)
        assert.equals(2, existing.seenCount)
        assert.equals(2, addon.db.observedSavedSessionDrops["i:88888"].totalQuantity)
        assert.equals(addon.db.observedWorldDrops, addon.db.observedSavedSessionDrops)
        -- A newly imported older session must still append after migration.
        addon.db.sessionHistory = { { itemLoots = { {
            itemLink = item_link, itemQuality = 2, quantity = 2,
            lootSourceType = "Unit", timestamp = 50,
        } } } }
        addon:ScanSavedSessionsForObservedDrops()
        addon:ScanSavedSessionsForObservedDrops()
        assert.equals(9, existing.totalQuantity)
    end)

    it("keeps saved-session entries that are absent from a later history scan", function()
        local addon = load_observed_drops()
        addon.db.sessionHistory = {
            {
                id = 7,
                itemLoots = {
                    {
                        itemLink = item_link,
                        quantity = 4,
                        itemQuality = 2,
                        lootSourceType = "NPC",
                    },
                },
            },
        }
        addon:ScanSavedSessionsForObservedDrops()

        addon.db.sessionHistory = {
            {
                id = 8,
                itemLoots = {
                    {
                        itemLink = "|cff1eff00|Hitem:88888::::::::|h[Later Green]|h|r",
                        quantity = 2,
                        itemQuality = 2,
                        lootSourceType = "NPC",
                    },
                },
            },
        }
        local result = addon:ScanSavedSessionsForObservedDrops()

        assert.equals(1, result.addedItems)
        assert.is_table(addon.db.observedSavedSessionDrops["i:99999"])
        assert.is_table(addon.db.observedSavedSessionDrops["i:88888"])
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
