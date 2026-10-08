local loader = require("tests.helpers.addon_loader")

local function load_alerts(addon)
    return loader.load_module("UI/PriceIncreaseAlertsWindow.lua", addon, {
        JanisTheme = {},
    })
end

describe("UI/PriceIncreaseAlertsWindow item tooltip", function()
    it("uses the item ID for the Blizzard tooltip when a saved link is stale", function()
        local calls = {}
        local tooltip = {
            SetOwner = function(_, owner, anchor)
                calls.owner = owner
                calls.anchor = anchor
            end,
            ClearLines = function()
                calls.cleared = true
            end,
            SetItemByID = function(_, item_id)
                calls.item_id = item_id
            end,
            SetHyperlink = function(_, item_link)
                calls.item_link = item_link
            end,
            AddLine = function() end,
            AddDoubleLine = function() end,
            Show = function()
                calls.shown = true
            end,
        }
        local target = {}

        loader.with_globals({ GameTooltip = tooltip }, function()
            local addon = load_alerts({
                FormatMoney = function(_, value)
                    return tostring(value)
                end,
            })

            assert.is_true(addon:ShowPriceIncreaseAlertItemTooltip({
                itemID = 19019,
                itemLink = "stale item link",
            }, target))
        end)

        assert.equals(target, calls.owner)
        assert.equals("ANCHOR_CURSOR", calls.anchor)
        assert.equals(19019, calls.item_id)
        assert.is_nil(calls.item_link)
        assert.is_true(calls.cleared)
        assert.is_true(calls.shown)
    end)
end)
