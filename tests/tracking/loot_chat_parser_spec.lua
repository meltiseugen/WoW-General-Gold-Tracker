local loader = require("tests.helpers.addon_loader")

local function load_parser(addon)
    local parser
    loader.with_globals({
        LOOT_ITEM_SELF = "You receive loot: %s.",
        LOOT_ITEM_PUSHED_SELF = "You receive item: %s.",
        LOOT_ITEM_SELF_MULTIPLE = "You receive loot: %sx%d.",
        LOOT_ITEM_PUSHED_SELF_MULTIPLE = "You receive item: %sx%d.",
        LOOT_MONEY = "You loot %s.",
        YOU_LOOT_MONEY = "You loot %s",
        GOLD_AMOUNT = "%d Gold",
        SILVER_AMOUNT = "%d Silver",
        COPPER_AMOUNT = "%d Copper",
    }, function()
        local _, ns = loader.load_module("Tracking/Loot/LootChatParser.lua", addon or {})
        parser = ns.LootChatParser:New(addon or { COPPER_PER_GOLD = 10000 })
    end)
    return parser
end

describe("Tracking/LootChatParser", function()
    it("extracts single and stacked self loot item links", function()
        local parser = load_parser()
        local item_link = "|cff1eff00|Hitem:123::::::::|h[Test Item]|h|r"

        local single_message = "You receive loot: " .. item_link .. "."
        local single_link, single_quantity = parser:ExtractLootItemFromMessage(single_message)
        local multi_message = "You receive loot: " .. item_link .. "x12."
        local multi_link, multi_quantity = parser:ExtractLootItemFromMessage(multi_message)

        assert.equals(item_link, single_link)
        assert.equals(1, single_quantity)
        assert.equals(item_link, multi_link)
        assert.equals(12, multi_quantity)
    end)

    it("parses formatted money text after removing chat textures and colors", function()
        local parser = load_parser({ COPPER_PER_GOLD = 10000 })

        local amount = parser:ExtractMoneyFromMessage(
            "You loot |cffffffff12 Gold|r |Tcoin:0|t 34 Silver 56 Copper."
        )

        assert.equals(123456, amount)
    end)

    it("falls back to digit order when localized money unit templates do not match", function()
        local parser = load_parser({ COPPER_PER_GOLD = 10000 })

        assert.equals(987654, parser:ExtractMoneyFromMessage("You loot 98 g 76 s 54 c"))
        assert.equals(7654, parser:ExtractMoneyFromMessage("You loot 76 s 54 c"))
        assert.equals(54, parser:ExtractMoneyFromMessage("You loot 54 c"))
    end)

    it("ignores secret or non-string chat payloads", function()
        loader.with_globals({
            issecretvalue = function(value)
                return value == "secret"
            end,
            LOOT_ITEM_SELF = "You receive loot: %s.",
            LOOT_ITEM_PUSHED_SELF = nil,
            LOOT_ITEM_SELF_MULTIPLE = nil,
            LOOT_ITEM_PUSHED_SELF_MULTIPLE = nil,
            LOOT_MONEY = "You loot %s.",
            YOU_LOOT_MONEY = nil,
            GOLD_AMOUNT = "%d Gold",
            SILVER_AMOUNT = "%d Silver",
            COPPER_AMOUNT = "%d Copper",
        }, function()
            local _, ns = loader.load_module("Tracking/Loot/LootChatParser.lua", { COPPER_PER_GOLD = 10000 })
            local parser = ns.LootChatParser:New({ COPPER_PER_GOLD = 10000 })
            assert.is_false(parser:IsUsableChatMessageText("secret"))
            assert.is_false(parser:IsUsableChatMessageText({}))
            assert.equals(0, parser:ExtractMoneyFromMessage("secret"))
        end)
    end)
end)
