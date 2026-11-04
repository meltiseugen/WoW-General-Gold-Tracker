local loader = require("tests.helpers.addon_loader")

local function load_namespace(saved_db, ns_overrides)
    saved_db = saved_db or {}
    local addon
    loader.with_globals({
        WOW_PROJECT_MAINLINE = 1,
        WOW_PROJECT_ID = 1,
        WoWGeneralGoldTrackerDB = saved_db,
        CreateFrame = function()
            return {}
        end,
        GetMoneyString = function(value)
            return tostring(value)
        end,
        ITEM_QUALITY0_DESC = "Poor",
        ITEM_QUALITY1_DESC = "Common",
        ITEM_QUALITY2_DESC = "Uncommon",
        ITEM_QUALITY3_DESC = "Rare",
        ITEM_QUALITY4_DESC = "Epic",
        ITEM_QUALITY5_DESC = "Legendary",
        ITEM_QUALITY_COLORS = {
            [2] = { hex = "ff1eff00" },
            [3] = { hex = "|cff0070dd" },
        },
    }, function()
        addon = loader.load_module("Core/Namespace.lua", {}, ns_overrides)
    end)
    addon.db = saved_db
    return addon
end

local function with_loaded_namespace(saved_db, callback, ns_overrides)
    saved_db = saved_db or {}
    return loader.with_globals({
        WOW_PROJECT_MAINLINE = 1,
        WOW_PROJECT_ID = 1,
        WoWGeneralGoldTrackerDB = saved_db or {},
        CreateFrame = function()
            return {}
        end,
        GetMoneyString = function(value)
            return tostring(value)
        end,
        ITEM_QUALITY0_DESC = "Poor",
        ITEM_QUALITY1_DESC = "Common",
        ITEM_QUALITY2_DESC = "Uncommon",
        ITEM_QUALITY3_DESC = "Rare",
        ITEM_QUALITY4_DESC = "Epic",
        ITEM_QUALITY5_DESC = "Legendary",
        ITEM_QUALITY_COLORS = {
            [2] = { hex = "ff1eff00" },
            [3] = { hex = "|cff0070dd" },
        },
    }, function()
        local addon = loader.load_module("Core/Namespace.lua", {}, ns_overrides)
        addon.db = saved_db
        return callback(addon, saved_db)
    end)
end

describe("Core/Namespace custom normalization", function()
    it("defaults session boundaries to continuous and preserves explicit split preferences", function()
        with_loaded_namespace({}, function(addon, db)
            addon:InitializeDatabase(); assert.equals("continuous", db.sessionSplitMode)
        end)
        with_loaded_namespace({ autoStartSessionOnLocationChange = true }, function(addon, db)
            addon:InitializeDatabase(); assert.equals("location", db.sessionSplitMode)
        end)
        with_loaded_namespace({ autoStartSessionOnLocationChange = true, sessionSplitMode = "instance" }, function(addon, db)
            addon:InitializeDatabase(); assert.equals("instance", db.sessionSplitMode)
        end)
    end)
    it("defaults experimental maps off while preserving an explicit opt-in", function()
        with_loaded_namespace({}, function(addon, db)
            addon:InitializeDatabase()
            assert.is_false(db.enableExperimentalMaps)
            db.enableExperimentalMaps = true
            addon:InitializeDatabase()
            assert.is_true(db.enableExperimentalMaps)
            db.enableExperimentalMaps = "true"
            addon:InitializeDatabase()
            assert.is_false(db.enableExperimentalMaps)
        end)
    end)

    it("refreshes existing map styles only when the experimental preference changes", function()
        local addon = load_namespace({ enableExperimentalMaps = false })
        local calls = 0
        addon.RefreshInteractiveMapStyles = function() calls = calls + 1 end
        addon:SetExperimentalMapsEnabled(true)
        assert.is_true(addon.db.enableExperimentalMaps)
        addon:SetExperimentalMapsEnabled(true)
        assert.equals(1, calls)
        addon:SetExperimentalMapsEnabled(false)
        assert.is_false(addon.db.enableExperimentalMaps)
        assert.equals(2, calls)
    end)

    it("invalidates Materials caches when the shared price fallback order changes", function()
        local addon = load_namespace({})
        addon.craftingFarmingFrame = { itemCache = { old = true }, materialDisplayRows = { {} } }
        addon.craftingFarmingExpandedFrame = { materialDisplayRows = { {} } }
        addon:SetValueSourceFallbackOrder({ "TSM_DBREGIONMARKETAVG", "TSM_DBMARKET" })
        assert.same({}, addon.craftingFarmingFrame.itemCache)
        assert.is_nil(addon.craftingFarmingFrame.materialDisplayRows)
        assert.is_nil(addon.craftingFarmingExpandedFrame.materialDisplayRows)
    end)

    it("enables standard observed-drop capture for new and previously disabled profiles", function()
        for _, saved in ipairs({ {}, { enableObservedWorldDrops = false } }) do
            with_loaded_namespace(saved, function(addon)
                addon:InitializeDatabase()
                assert.is_true(addon.DEFAULTS.enableObservedWorldDrops)
                assert.is_true(addon.db.enableObservedWorldDrops)
                assert.is_true(addon:IsObservedWorldDropsEnabled())
            end)
        end
    end)

    it("normalizes inventory category order by removing invalid and duplicate categories", function()
        local addon = load_namespace({
            inventoryCategoryOrder = { "transmog", "invalid", "crafting", "transmog" },
        })

        assert.same({
            "transmog",
            "crafting",
            "consumables",
            "armorWeapons",
            "uncategorized",
        }, addon:NormalizeInventoryCategoryOrder())
    end)

    it("normalizes and reorders the shared value-source fallback chain", function()
        local addon = load_namespace({
            valueSourceFallbackOrder = {
                "TSM_DBREGIONMARKETAVG",
                "invalid",
                "TSM_DBMARKET",
                "TSM_DBREGIONMARKETAVG",
            },
        })

        assert.same({
            "TSM_DBREGIONMARKETAVG",
            "TSM_DBMARKET",
            "TSM_DBRECENT",
            "TSM_DBHISTORICAL",
            "TSM_DBREGIONHISTORICAL",
            "TSM_DBREGIONSALEAVG",
            "TSM_DBMINBUYOUT",
        }, addon:NormalizeValueSourceFallbackOrder())

        addon:MoveValueSourceFallback("TSM_DBMINBUYOUT", 1)

        assert.equals("TSM_DBMINBUYOUT", addon:GetValueSourceFallbackOrder()[1])
        assert.same({
            "TSM_DBMARKET",
            "TSM_DBMINBUYOUT",
            "TSM_DBREGIONMARKETAVG",
            "TSM_DBRECENT",
            "TSM_DBHISTORICAL",
            "TSM_DBREGIONHISTORICAL",
            "TSM_DBREGIONSALEAVG",
        }, addon:GetValueSourceResolutionOrder("TSM_DBMARKET"))
    end)

    it("deduplicates and repairs custom farming materials", function()
        local addon = load_namespace({
            craftingFarmingCustomItems = {
                { itemID = "123.7", expansion = "classic", professions = { "mining", "mining", "" }, tag = "" },
                { itemID = 124, expansion = 3, professions = {}, tag = "Rare Cloth" },
                { itemID = 124, expansion = "warWithin", professions = { "tailoring" }, tag = "Duplicate" },
                { itemID = -1, expansion = "classic", professions = { "mining" }, tag = "Bad" },
            },
        })

        assert.same({
            {
                itemID = 124,
                expansion = "classic",
                professions = { "mining" },
                tag = "Custom",
                custom = true,
            },
        }, addon:NormalizeCraftingFarmingCustomItems())
    end)

    it("moves an existing custom material to the end when it is re-added", function()
        local addon = load_namespace({
            craftingFarmingCustomItems = {
                { itemID = 101, expansion = "classic", professions = { "mining" }, tag = "Ore" },
                { itemID = 202, expansion = "classic", professions = { "herbalism" }, tag = "Herb" },
            },
        })

        local added = addon:AddCraftingFarmingCustomItem(101, "warWithin", "tailoring", "Cloth")

        assert.equals(101, added.itemID)
        assert.equals(2, #addon.db.craftingFarmingCustomItems)
        assert.equals(202, addon.db.craftingFarmingCustomItems[1].itemID)
        assert.same({
            itemID = 101,
            expansion = "warWithin",
            professions = { "tailoring" },
            tag = "Cloth",
            custom = true,
        }, addon.db.craftingFarmingCustomItems[2])
    end)

    it("preserves learned material provenance and stores manual profession overrides", function()
        local addon = load_namespace({
            craftingFarmingCustomItems = {
                {
                    itemID = 101,
                    expansion = "classic",
                    professions = { "mining" },
                    tag = "Session",
                    learnedAt = 1234,
                },
            },
            craftingFarmingItemOverrides = {},
        })

        local custom = addon:SetCraftingFarmingItemProfession(101, "herbalism")
        local curated = addon:SetCraftingFarmingItemProfession(202, "skinning")

        assert.same({ "herbalism" }, custom.professions)
        assert.is_true(custom.learnedFromSession)
        assert.equals("session", custom.importSource)
        assert.equals(202, curated.itemID)
        assert.same({
            itemID = 202,
            professions = { "skinning" },
            source = "manual",
        }, addon.db.craftingFarmingItemOverrides["202"])
    end)

    it("drops stale session-learned custom materials that now exist in curated data", function()
        local addon = load_namespace({
            craftingFarmingCustomItems = {
                {
                    itemID = 221758,
                    expansion = "burningCrusade",
                    professions = { "skinning" },
                    tag = "Session",
                    learnedFromSession = true,
                    importSource = "session",
                },
                {
                    itemID = 900001,
                    expansion = "burningCrusade",
                    professions = { "skinning" },
                    tag = "Session",
                    learnedFromSession = true,
                    importSource = "session",
                },
            },
        }, {
            FarmingItems = {
                items = {
                    { itemID = 221758, expansion = "warWithin", professions = { "blacksmithing" }, tag = "Reagent" },
                },
            },
        })

        assert.same({
            {
                itemID = 900001,
                expansion = "all",
                professions = { "all" },
                tag = "Session",
                custom = true,
                learnedFromSession = true,
                importSource = "session",
            },
        }, addon:NormalizeCraftingFarmingCustomItems())
    end)

    it("normalizes legacy crafting farming profession selections to one saved value", function()
        local saved_db = {
            craftingFarmingProfessionID = "mining",
            craftingFarmingProfessionIDs = { "herbalism", "mining", "herbalism", "" },
        }

        with_loaded_namespace(saved_db, function(addon)
            addon:InitializeDatabase()

            assert.same({ "mining" }, addon.db.craftingFarmingProfessionIDs)
            assert.equals("mining", addon.db.craftingFarmingProfessionID)
        end)
    end)

    it("migrates a supported legacy fallback source to the front of the ordered chain", function()
        local saved_db = {
            valueSource = "TSM_DBMARKET",
            fallbackValueSource = "TSM_DBREGIONMARKETAVG",
            pricingDefaultsVersion = 2,
        }

        with_loaded_namespace(saved_db, function(addon)
            addon:InitializeDatabase()

            assert.equals("TSM_DBREGIONMARKETAVG", addon.db.valueSourceFallbackOrder[1])
            assert.equals(7, #addon.db.valueSourceFallbackOrder)
        end)
    end)

    it("defaults price alerts to a 30 gold minimum value", function()
        with_loaded_namespace({}, function(addon)
            addon:InitializeDatabase()

            assert.equals(300000, addon.db.priceIncreaseAlertMinimumValue)
        end)
    end)

    it("seeds committed learned materials, category overrides, and drop rates into saved variables", function()
        local saved_db = {}

        with_loaded_namespace(saved_db, function(addon)
            addon:InitializeDatabase()

            assert.equals(990001, addon.db.craftingFarmingCustomItems[1].itemID)
            assert.same({ "herbalism" }, addon.db.craftingFarmingCustomItems[1].professions)
            assert.is_true(addon.db.craftingFarmingCustomItems[1].learnedFromSession)
            assert.same({ "alchemy" }, addon.db.craftingFarmingItemOverrides["22574"].professions)
            assert.equals("bundled", addon.db.craftingFarmingItemOverrides["22574"].source)
            assert.equals(8, addon.db.craftingFarmingDropRates.items["990001"].dropPerHour)
            assert.equals(1234, addon.db.craftingFarmingDropRates.updatedAt)
        end, {
            CraftingFarmingLearnedData = {
                customItems = {
                    {
                        itemID = 990001,
                        expansion = "warWithin",
                        professions = { "herbalism" },
                        tag = "Session",
                        learnedFromSession = true,
                        importSource = "session",
                        learnedProfessionSource = "lootSourceType",
                    },
                },
                itemOverrides = {
                    ["22574"] = {
                        itemID = 22574,
                        professions = { "alchemy" },
                        source = "manual",
                        updatedAt = 1200,
                    },
                },
                dropRates = {
                    updatedAt = 1234,
                    items = {
                        ["990001"] = {
                            itemID = 990001,
                            quantity = 4,
                            durationSeconds = 1800,
                            sessionCount = 1,
                            dropPerHour = 8,
                        },
                    },
                },
            },
        })
    end)

    it("keeps a local manual material category over a bundled default", function()
        local saved_db = {
            craftingFarmingItemOverrides = {
                ["22574"] = {
                    itemID = 22574,
                    professions = { "mining" },
                    source = "manual",
                },
            },
        }

        with_loaded_namespace(saved_db, function(addon)
            addon:InitializeDatabase()

            assert.same({ "mining" }, addon.db.craftingFarmingItemOverrides["22574"].professions)
            assert.equals("manual", addon.db.craftingFarmingItemOverrides["22574"].source)
        end, {
            CraftingFarmingLearnedData = {
                itemOverrides = {
                    ["22574"] = {
                        itemID = 22574,
                        professions = { "alchemy" },
                    },
                },
            },
        })
    end)

    it("refreshes and removes stale bundled material categories", function()
        local saved_db = {
            craftingFarmingItemOverrides = {
                ["22574"] = {
                    itemID = 22574,
                    professions = { "mining" },
                    source = "bundled",
                },
                ["22575"] = {
                    itemID = 22575,
                    professions = { "mining" },
                    source = "bundled",
                },
            },
        }

        with_loaded_namespace(saved_db, function(addon)
            addon:InitializeDatabase()

            assert.same({ "alchemy" }, addon.db.craftingFarmingItemOverrides["22574"].professions)
            assert.is_nil(addon.db.craftingFarmingItemOverrides["22575"])
        end, {
            CraftingFarmingLearnedData = {
                itemOverrides = {
                    ["22574"] = {
                        itemID = 22574,
                        professions = { "alchemy" },
                    },
                },
            },
        })
    end)
end)

describe("Core/Namespace farming favorite migration", function()
    it("merges rare and instance favorites into a single account-wide item store", function()
        local rare_favorite = {
            itemID = 30001,
            itemName = "Rare Drop",
            rareName = "A Rare",
            value = 100,
        }
        local instance_favorite = {
            itemID = 30001,
            instanceName = "A Raid",
            bossName = "Trash Mobs",
            marketValue = 200,
        }
        local saved_db = {
            rareFarmingFavorites = {
                oldRareKey = rare_favorite,
            },
            instanceFarmingFavorites = {
                oldInstanceKey = instance_favorite,
            },
        }

        with_loaded_namespace(saved_db, function(addon)
            addon:InitializeDatabase()

            local favorites = addon:GetFarmingFavoriteStore()
            assert.is_table(favorites["item:30001"])
            assert.equals("Rare Drop", favorites["item:30001"].itemName)
            assert.equals("A Raid", favorites["item:30001"].instanceName)
            assert.equals("rare", favorites["item:30001"].farmingSourceType)
            assert.equals("item:30001", favorites["item:30001"].favoriteKey)
            assert.is_true(addon.db.rareFarmingFavorites == favorites)
            assert.is_true(addon.db.instanceFarmingFavorites == favorites)
            assert.is_true(addon.db.rareFarmingShared.favorites == favorites)
            assert.is_true(addon.db.instanceFarmingShared.favorites == favorites)
        end)
    end)

    it("uses item IDs as shared favorite keys regardless of source row shape", function()
        local addon = load_namespace({})

        local rare_key = addon:GetFarmingFavoriteKey({ npcID = 123, itemID = 987.6 })
        local instance_key = addon:GetFarmingFavoriteKey({ instanceName = "Raid", itemID = 988 })

        assert.equals("item:988", rare_key)
        assert.equals("item:988", instance_key)
    end)
end)

describe("Core/Namespace account-wide scan migration", function()
    it("migrates rare, instance, and drop scan data into shared stores", function()
        local rare_scan = { results = { { itemID = 101 } } }
        local instance_scan = { results = { { itemID = 202 } } }
        local drop_scan = { results = { { itemID = 303 } }, dropSourceID = "att-zones" }
        local session_drop = { itemID = 404, seenCount = 2 }
        local saved_db = {
            rareFarmingScanCache = { rareKey = rare_scan },
            instanceFarmingScanCache = { instanceKey = instance_scan },
            observedDropsScanCache = { dropKey = drop_scan },
            observedSavedSessionDrops = { ["i:404"] = session_drop },
            observedSavedSessionDropsScannedAt = 1710000000,
        }

        with_loaded_namespace(saved_db, function(addon)
            addon:InitializeDatabase()

            assert.equals(rare_scan, addon.db.rareFarmingShared.scanCache.rareKey)
            assert.equals(instance_scan, addon.db.instanceFarmingShared.scanCache.instanceKey)
            assert.equals(drop_scan, addon.db.observedDropsShared.scanCache.dropKey)
            assert.equals(session_drop, addon.db.observedDropsShared.savedSessionDrops["i:404"])
            assert.equals(1710000000, addon.db.observedDropsShared.savedSessionDropsScannedAt)
            assert.is_true(addon.db.rareFarmingScanCache == addon.db.rareFarmingShared.scanCache)
            assert.is_true(addon.db.instanceFarmingScanCache == addon.db.instanceFarmingShared.scanCache)
            assert.is_true(addon.db.observedDropsScanCache == addon.db.observedDropsShared.scanCache)
            assert.is_true(addon.db.observedSavedSessionDrops == addon.db.observedDropsShared.savedSessionDrops)
        end)
    end)

    it("keeps a newer empty shared saved-session scan authoritative", function()
        local saved_db = {
            observedDropsShared = {
                scanCache = {},
                savedSessionDrops = {},
                savedSessionDropsScannedAt = 200,
            },
            observedSavedSessionDrops = {
                ["i:505"] = { itemID = 505 },
            },
            observedSavedSessionDropsScannedAt = 100,
        }

        with_loaded_namespace(saved_db, function(addon)
            addon:InitializeDatabase()

            assert.same({}, addon.db.observedSavedSessionDrops)
            assert.equals(200, addon.db.observedSavedSessionDropsScannedAt)
        end)
    end)
end)

describe("Core/Namespace utility edges", function()
    it("clamps world map projection pin scale for saved options", function()
        local addon = load_namespace({})

        assert.near(0.6, addon:NormalizeWorldMapProjectionPinScale("0.2"), 0.0001)
        assert.near(2.0, addon:NormalizeWorldMapProjectionPinScale("3.7"), 0.0001)
        assert.near(1.3, addon:NormalizeWorldMapProjectionPinScale("1.26"), 0.0001)

        addon.db.worldMapProjectionPinScale = 1.74
        assert.near(1.7, addon:GetWorldMapProjectionPinScale(), 0.0001)
    end)

    it("normalizes the farming map pin icon and exposes its texture", function()
        local addon = load_namespace({ mapPinIcon = "ore" })

        assert.equals("ore", addon:NormalizeMapPinIcon("ore"))
        assert.equals("loot", addon:NormalizeMapPinIcon("not-an-icon"))
        assert.equals("ore", addon:GetMapPinIconOption().id)
        assert.equals("Interface\\Icons\\INV_Ore_Copper_01", addon:GetMapPinIconOption().texture)
    end)

    it("normalizes comma-separated value source labels with aliases and deduplication", function()
        local addon = load_namespace({})

        assert.equals(
            "Market Value, Region Market Avg, Auctioning Normal",
            addon:NormalizeValueSourceLabel("DBMarket, tsm region market value, auctioningopnormal, DBMarket")
        )
    end)

    it("extracts TSM item strings from item and battle pet links", function()
        local addon = load_namespace({})

        assert.equals("i:12345", addon:GetTSMItemStringFromLink("|Hitem:12345::::::::|h[Test]|h"))
        assert.equals("p:777", addon:GetTSMItemStringFromLink("|Hbattlepet:777:25:3:1:2:3:4|h[Pet]|h"))
    end)

    it("handles modified item clicks for item links and item IDs", function()
        local addon = load_namespace({})
        local clicked = {}

        loader.with_globals({
            IsShiftKeyDown = function()
                return false
            end,
            IsControlKeyDown = function()
                return true
            end,
            IsAltKeyDown = function()
                return false
            end,
            HandleModifiedItemClick = function(item_link)
                clicked[#clicked + 1] = item_link
                return true
            end,
        }, function()
            assert.is_true(addon:HandleModifiedItemClickIfModified("|Hitem:12345::::::::|h[Test]|h"))
            assert.is_true(addon:HandleModifiedItemClickIfModified({ itemID = 67890 }))
        end)

        assert.same({
            "|Hitem:12345::::::::|h[Test]|h",
            "item:67890",
        }, clicked)
    end)

    it("does not handle item clicks when no modifier key is held", function()
        local addon = load_namespace({})
        local click_count = 0

        loader.with_globals({
            IsShiftKeyDown = function()
                return false
            end,
            IsControlKeyDown = function()
                return false
            end,
            IsAltKeyDown = function()
                return false
            end,
            HandleModifiedItemClick = function()
                click_count = click_count + 1
                return true
            end,
        }, function()
            assert.is_false(addon:HandleModifiedItemClickIfModified("|Hitem:12345::::::::|h[Test]|h"))
        end)

        assert.equals(0, click_count)
    end)
end)

describe("Core/Namespace session style filtering", function()
    it("classifies loot entries into crafting, armour/weapons, and other styles", function()
        local addon = load_namespace({})

        assert.equals("crafting", addon:GetLootItemSessionStyle({ isCraftingReagent = true }))
        assert.equals("armorWeapons", addon:GetLootItemSessionStyle({ itemClassID = 2 }))
        assert.equals("armorWeapons", addon:GetLootItemSessionStyle({ itemType = "Armor" }))
        assert.equals("other", addon:GetLootItemSessionStyle({ itemClassID = 15 }))
    end)

    it("builds filtered session summaries without changing all-loot totals", function()
        local addon = load_namespace({})
        addon.GetHighlightThreshold = function()
            return 500
        end
        local session = {
            goldLooted = 250,
            itemValue = 1800,
            itemVendorValue = 180,
            highlightItemCount = 3,
            itemLoots = {
                {
                    itemClassID = 7,
                    isCraftingReagent = true,
                    quantity = 2,
                    totalValue = 1000,
                    vendorTotalValue = 20,
                    isHighlighted = true,
                },
                {
                    itemClassID = 2,
                    quantity = 1,
                    totalValue = 500,
                    vendorTotalValue = 100,
                    isHighlighted = true,
                },
                { itemClassID = 15, quantity = 1, totalValue = 300, vendorTotalValue = 60 },
            },
        }

        local all = addon:BuildSessionViewSummary(session, "all")
        local crafting = addon:BuildSessionViewSummary(session, "crafting")
        local armor = addon:BuildSessionViewSummary(session, "armorWeapons")
        local other = addon:BuildSessionViewSummary(session, "other")

        assert.equals(2050, all.totalValue)
        assert.equals(430, all.rawTotal)
        assert.equals(3, all.highlightItemCount)
        assert.equals(1000, crafting.totalValue)
        assert.equals(20, crafting.rawTotal)
        assert.equals(1, crafting.highlightItemCount)
        assert.equals(500, armor.totalValue)
        assert.equals(100, armor.rawTotal)
        assert.equals(300, other.totalValue)
        assert.equals(60, other.rawTotal)
    end)
end)

describe("Market history capture settings", function()
    it("defaults to hourly observations without evicting other item histories", function()
        with_loaded_namespace({}, function(addon)
            addon:InitializeDatabase()
            assert.equals(60, addon.db.marketHistorySnapshotIntervalMinutes)
            assert.equals(0, addon.db.marketHistoryMaxItems)
        end)
    end)

    it("clamps capture intervals while preserving an explicit unlimited item setting", function()
        with_loaded_namespace({ marketHistorySnapshotIntervalMinutes = 0, marketHistoryMaxItems = 0 }, function(addon)
            addon:InitializeDatabase()
            assert.equals(1, addon.db.marketHistorySnapshotIntervalMinutes)
            assert.equals(0, addon.db.marketHistoryMaxItems)
            addon.db.marketHistorySnapshotIntervalMinutes = 9999
            addon:InitializeDatabase()
            assert.equals(1440, addon.db.marketHistorySnapshotIntervalMinutes)
        end)
    end)
end)
