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

    it("seeds committed learned materials and drop rates into saved variables", function()
        local saved_db = {}

        with_loaded_namespace(saved_db, function(addon)
            addon:InitializeDatabase()

            assert.equals(990001, addon.db.craftingFarmingCustomItems[1].itemID)
            assert.same({ "herbalism" }, addon.db.craftingFarmingCustomItems[1].professions)
            assert.is_true(addon.db.craftingFarmingCustomItems[1].learnedFromSession)
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

describe("Core/Namespace utility edges", function()
    it("clamps world map projection pin scale for saved options", function()
        local addon = load_namespace({})

        assert.near(0.6, addon:NormalizeWorldMapProjectionPinScale("0.2"), 0.0001)
        assert.near(2.0, addon:NormalizeWorldMapProjectionPinScale("3.7"), 0.0001)
        assert.near(1.3, addon:NormalizeWorldMapProjectionPinScale("1.26"), 0.0001)

        addon.db.worldMapProjectionPinScale = 1.74
        assert.near(1.7, addon:GetWorldMapProjectionPinScale(), 0.0001)
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
