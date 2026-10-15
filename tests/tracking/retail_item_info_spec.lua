local loader = require("tests.helpers.addon_loader")

local ITEM_LINK = "|cnIQ3:|Hitem:263462::::::::90:254:::::::::|h[Thalassian Herbalist's Notes]|h|r"

local function item_info(price, class_id, bind_type, reagent)
    return function(link)
        assert.equals(ITEM_LINK, link)
        return "Thalassian Herbalist's Notes", link, 3, 1, 1, "Miscellaneous", "Other",
            1, "", 123, price, class_id, 0, bind_type, 11, nil, reagent
    end
end

local function with_item_api(api, callback)
    return loader.with_globals({
        C_Item = api or {},
        -- with_globals cannot represent nil values; clear this inside the callback
        -- while keeping its key present so the helper restores it afterwards.
        GetItemInfo = false,
        GetItemInfoInstant = false,
        C_TooltipInfo = {},
        C_Map = {},
        C_Timer = {},
        LE_ITEM_BIND_ON_ACQUIRE = 1,
        LE_ITEM_BIND_QUEST = 4,
        ITEM_SOULBOUND = "Soulbound",
        LOOT_ITEM_SELF = "You receive loot: %s.",
        LOOT_ITEM_SELF_MULTIPLE = "You receive loot: %sx%d.",
        time = function() return 1791984317 end,
    }, function()
        _G.GetItemInfo = nil
        local addon, ns = loader.load_module("Core/Namespace.lua", {
            db = { valueSource = "VENDOR", minimumTrackedItemQuality = 2 },
            session = { active = true, itemValue = 0, itemVendorValue = 0, itemLoots = {} },
        })
        loader.load_module("Core/ItemBinding.lua", addon, ns)
        loader.load_module("Tracking/Valuation.lua", addon, ns)
        return callback(addon, ns)
    end)
end

describe("Retail item information without legacy globals", function()
    it("reads vendor prices from C_Item even when the legacy global is absent", function()
        with_item_api({ GetItemInfo = item_info(125, 15, 1, false) }, function(addon)
            assert.is_nil(GetItemInfo)
            assert.equals(125, addon:GetVendorItemValue(ITEM_LINK))
        end)
    end)

    it("prefers C_Item over an available legacy API", function()
        with_item_api({ GetItemInfo = item_info(125, 15, 1, false) }, function(addon)
            _G.GetItemInfo = function() error("Legacy API must not be called") end
            assert.equals(125, addon:GetVendorItemValue(ITEM_LINK))
            assert.equals(3, addon:GetItemQualityFromLink(ITEM_LINK))
            assert.is_false(addon:IsCraftingReagentItem(ITEM_LINK))
            assert.is_true(addon:IsLootItemBindingRestricted(ITEM_LINK))
        end)
    end)

    it("retains the legacy fallback when C_Item.GetItemInfo is unavailable", function()
        with_item_api({}, function(addon)
            _G.GetItemInfo = item_info(250, 7, 1, true)
            assert.equals(250, addon:GetVendorItemValue(ITEM_LINK))
            assert.equals(3, addon:GetItemQualityFromLink(ITEM_LINK))
            assert.is_true(addon:IsCraftingReagentItem(ITEM_LINK))
            assert.is_true(addon:IsLootItemBindingRestricted(ITEM_LINK))
            assert.is_true(addon:GetLootItemMetadata(ITEM_LINK).isCraftingReagent)
        end)
    end)

    it("handles uncached item information with no return values", function()
        with_item_api({ GetItemInfo = function() end }, function(addon)
            assert.equals(0, addon:GetVendorItemValue(ITEM_LINK))
            assert.is_nil(addon:GetItemQualityFromLink(ITEM_LINK))
            assert.is_false(addon:IsCraftingReagentItem(ITEM_LINK))
            assert.is_false(addon:IsLootItemBindingRestricted(ITEM_LINK))
            assert.is_nil(addon.lootItemBindingRestrictionCache[263462])

            C_Item.GetItemInfo = item_info(125, 7, 1, true)
            assert.equals(125, addon:GetVendorItemValue(ITEM_LINK))
            assert.is_true(addon:IsLootItemBindingRestricted(ITEM_LINK))
        end)
    end)

    it("handles missing item APIs and still checks tooltip binding", function()
        with_item_api({}, function(addon)
            assert.equals(0, addon:GetVendorItemValue(ITEM_LINK))
            assert.is_nil(addon:GetItemQualityFromLink(ITEM_LINK))
            assert.is_false(addon:IsCraftingReagentItem(ITEM_LINK))
            C_TooltipInfo.GetHyperlink = function()
                return { lines = { { leftText = "Soulbound" } } }
            end
            assert.is_true(addon:IsLootItemBindingRestricted(ITEM_LINK))
        end)
    end)

    it("treats missing, zero and negative vendor prices as zero", function()
        with_item_api({}, function(addon)
            for _, price in ipairs({ false, 0, -1 }) do
                C_Item.GetItemInfo = item_info(price or nil, 15, 1, false)
                assert.equals(0, addon:GetVendorItemValue(ITEM_LINK))
            end
        end)
    end)

    it("reads the seventeenth reagent field and preserves explicit false", function()
        with_item_api({}, function(addon)
            for _, reagent in ipairs({ true, false }) do
                C_Item.GetItemInfo = item_info(125, 7, 0, reagent)
                assert.equals(reagent, addon:IsCraftingReagentItem(ITEM_LINK))
                assert.equals(reagent, addon:GetLootItemMetadata(ITEM_LINK).isCraftingReagent)
            end
            C_Item.GetItemInfo = item_info(125, 7, 0, nil)
            assert.is_true(addon:IsCraftingReagentItem(ITEM_LINK))
            C_Item.GetItemInfo = item_info(125, 15, 0, nil)
            assert.is_false(addon:IsCraftingReagentItem(ITEM_LINK))
        end)
    end)

    it("records loot chat, vendor totals and binding using only the Retail API", function()
        with_item_api({ GetItemInfo = item_info(125, 15, 1, false) }, function(addon, ns)
            for _, path in ipairs({
                "Tracking/Loot/LootChatParser.lua",
                "Tracking/Loot/LootSourceService.lua",
                "Tracking/LootEvents.lua",
            }) do
                addon, ns = loader.load_module(path, addon, ns)
            end
            addon.BeginDiagnosticTimer = function() return 0 end
            addon.EndDiagnosticTimer = function() end
            addon.IncrementDiagnosticCounter = function() end
            addon.UpdateSessionLocationContext = function() end
            addon.HandleSessionLocationTransition = function() end
            addon.UpdateMainWindow = function() end

            addon:OnChatMsgLoot("You receive loot: " .. ITEM_LINK .. "x2.")

            assert.equals(1, #addon.session.itemLoots)
            local loot = addon.session.itemLoots[1]
            assert.equals(263462, loot.itemID)
            assert.equals(2, loot.quantity)
            assert.equals(3, loot.itemQuality)
            assert.equals(125, loot.vendorUnitValue)
            assert.equals(250, loot.vendorTotalValue)
            assert.equals(250, addon.session.itemVendorValue)
            assert.is_true(loot.isSoulbound)
            assert.is_false(loot.isCraftingReagent)
            assert.equals(0, loot.totalValue)
            assert.equals(0, addon.session.itemValue)
        end)
    end)
end)
