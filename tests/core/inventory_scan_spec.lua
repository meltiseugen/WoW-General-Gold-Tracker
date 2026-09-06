local loader = require("tests.helpers.addon_loader")

local function build_category_options()
    local options = {
        { id = "all", label = "All" },
        { id = "armorWeapons", label = "Armor and Weapons" },
        { id = "crafting", label = "Crafting" },
        { id = "consumables", label = "Consumables" },
        { id = "transmog", label = "Transmog" },
        { id = "uncategorized", label = "Uncategorized" },
    }
    local by_id = {}
    for _, option in ipairs(options) do
        by_id[option.id] = option
    end
    return options, by_id
end

local function load_service(addon)
    local category_options, category_by_id = build_category_options()
    addon.INVENTORY_CATEGORY_ALL_ID = "all"
    addon.INVENTORY_CATEGORY_OPTIONS = category_options
    addon.INVENTORY_CATEGORY_BY_ID = category_by_id
    addon.TRACKED_ITEM_QUALITY_BY_ID = {
        [0] = { id = 0, label = "Poor" },
        [1] = { id = 1, label = "Common" },
        [2] = { id = 2, label = "Uncommon" },
    }
    addon.GetConfiguredMinimumTrackedItemQuality = addon.GetConfiguredMinimumTrackedItemQuality or function()
        return 0
    end
    return loader.load_module("Core/InventoryScan.lua", addon)
end

describe("Core/InventoryScan", function()
    it("normalizes categories and classifies common inventory item types", function()
        local addon = load_service({})

        assert.equals("all", addon:NormalizeInventoryCategoryFilter("missing"))
        assert.equals("Armor and Weapons", addon:GetInventoryCategoryOption("armorWeapons").label)
        assert.equals("crafting", addon:GetInventoryItemCategoryID({ itemClassID = 7 }))
        assert.equals("consumables", addon:GetInventoryItemCategoryID({ itemType = "Consumable" }))
        assert.equals("transmog", addon:GetInventoryItemCategoryID({ itemSubType = "Cosmetic" }))
        assert.equals("armorWeapons", addon:GetInventoryItemCategoryID({ itemType = "Armor" }))
        assert.equals("uncategorized", addon:GetInventoryItemCategoryID({ itemType = "Miscellaneous" }))
    end)

    it("builds sorted unique bag IDs including reagent containers", function()
        local addon = load_service({})

        loader.with_globals({
            BACKPACK_CONTAINER = 0,
            NUM_BAG_SLOTS = 2,
            REAGENTBAG_CONTAINER = 5,
            Enum = {
                BagIndex = {
                    ReagentBag = 5,
                },
            },
        }, function()
            assert.same({ 0, 1, 2, 5 }, addon:BuildInventoryBagIDs())
        end)
    end)

    it("invalidates scan cache by bumping the cache version", function()
        local addon = load_service({
            inventoryBuildCacheVersion = 4,
            inventoryBuildCache = {
                old = true,
            },
        })

        addon:InvalidateAuctionableInventoryScanCache()

        assert.same({}, addon.inventoryBuildCache)
        assert.equals(5, addon.inventoryBuildCacheVersion)
    end)

    it("sorts by demand with sell rate and total value tie breakers", function()
        local addon = load_service({})
        local rows = {
            { itemName = "Low", regionSoldPerDay = 5, regionSaleRate = 0.50, totalValue = 100 },
            { itemName = "High B", regionSoldPerDay = 10, regionSaleRate = 0.20, totalValue = 200 },
            { itemName = "High A", regionSoldPerDay = 10, regionSaleRate = 0.40, totalValue = 50 },
            { itemName = "High C", regionSoldPerDay = 10, regionSaleRate = 0.20, totalValue = 500 },
        }

        addon:SortInventoryItems(rows, "demand", false)

        assert.same({ "High A", "High C", "High B", "Low" }, {
            rows[1].itemName,
            rows[2].itemName,
            rows[3].itemName,
            rows[4].itemName,
        })
    end)

    it("defaults inventory sorting to stack value descending", function()
        local addon = load_service({})
        local rows = {
            { itemName = "Middle", regionSoldPerDay = 20, totalValue = 200 },
            { itemName = "Low", regionSoldPerDay = 100, totalValue = 100 },
            { itemName = "High", regionSoldPerDay = 1, totalValue = 500 },
        }

        addon:SortInventoryItems(rows, nil, false)

        assert.same({ "High", "Middle", "Low" }, {
            rows[1].itemName,
            rows[2].itemName,
            rows[3].itemName,
        })
    end)
end)
