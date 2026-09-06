local loader = require("tests.helpers.addon_loader")

local function load_item_binding(addon)
    return loader.with_globals({
        LE_ITEM_BIND_ON_ACQUIRE = 1,
        LE_ITEM_BIND_QUEST = 4,
        ITEM_SOULBOUND = "Soulbound",
        ITEM_BIND_ON_PICKUP = "Binds when picked up",
        ITEM_BIND_QUEST = "Quest Item",
        ITEM_BIND_TO_BNETACCOUNT = "Binds to Battle.net account",
        ITEM_BNETACCOUNTBOUND = "Battle.net Account Bound",
        ITEM_BIND_TO_ACCOUNT = "Binds to account",
        ITEM_ACCOUNTBOUND = "Account Bound",
        ITEM_ACCOUNTBOUND_UNTIL_EQUIP = "Warbound until equipped",
        ITEM_BIND_TO_ACCOUNT_UNTIL_EQUIP = "Binds to account until equipped",
        GetItemInfo = function()
            return nil
        end,
    }, function()
        addon = addon or {}
        addon.GetItemIDFromLink = addon.GetItemIDFromLink or function(_, item_link)
            return tonumber(string.match(item_link or "", "item:(%d+)"))
        end
        return loader.load_module("Core/ItemBinding.lua", addon)
    end)
end

describe("Core/ItemBinding", function()
    it("does not treat Warband appearance collection text as a binding restriction", function()
        local addon = load_item_binding()

        local warband_collection_text = "Use: Add this appearance to your Warband collection."
        local collected_appearance_text = "You've collected this appearance, but not from this item"

        assert.is_false(addon:IsRestrictedBindingTooltipLine(warband_collection_text))
        assert.is_false(addon:IsRestrictedBindingTooltipLine(collected_appearance_text))
    end)

    it("treats actual Warband and Warbound binding text as restricted", function()
        local addon = load_item_binding()

        assert.is_true(addon:IsRestrictedBindingTooltipLine("Warbound until equipped"))
        assert.is_true(addon:IsRestrictedBindingTooltipLine("Binds to Warband until equipped"))
        assert.is_true(addon:IsRestrictedBindingTooltipLine("Bound to Warband"))
    end)

    it("surfaces whether tooltip text was readable separately from binding restriction", function()
        local addon = load_item_binding()

        local saw_text, is_restricted = addon:GetTooltipBindingState({
            lines = {
                { leftText = "Garr's Reinforced Girdle of Memories" },
                { leftText = "Binds when equipped" },
                { leftText = "Use: Add this appearance to your Warband collection." },
            },
        })

        assert.is_true(saw_text)
        assert.is_false(is_restricted)
    end)

    it("detects restricted binding from surfaced tooltip lines", function()
        local addon = load_item_binding()

        local saw_text, is_restricted = addon:GetTooltipBindingState({
            lines = {
                { leftText = "Some Item" },
                { leftText = "Soulbound" },
            },
        })

        assert.is_true(saw_text)
        assert.is_true(is_restricted)
    end)

    it("uses item bind type to reject bind-on-pickup loot", function()
        local addon = load_item_binding({
            GetItemIDFromLink = function()
                return 12345
            end,
        })

        local is_restricted = loader.with_globals({
            LE_ITEM_BIND_ON_ACQUIRE = 1,
            GetItemInfo = function()
                return nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, 1
            end,
        }, function()
            return addon:IsLootItemBindingRestricted("|Hitem:12345::::::::|h[Test Item]|h")
        end)

        assert.is_true(is_restricted)
    end)
end)
