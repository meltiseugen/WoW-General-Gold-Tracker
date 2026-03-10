local _, NS = ...

local LootChatParser = {}
LootChatParser.__index = LootChatParser

function LootChatParser:New(addon)
    local instance = {
        addon = addon,
        selfLootSinglePatterns = {},
        selfLootMultiplePatterns = {},
        selfLootMoneyPatterns = {},
    }
    setmetatable(instance, LootChatParser)
    instance:RefreshPatterns()
    return instance
end

function LootChatParser:IsSecretValue(value)
    return type(issecretvalue) == "function" and issecretvalue(value)
end

function LootChatParser:EscapePattern(text)
    return (string.gsub(text, "([%(%)%.%%%+%-%*%?%[%]%^%$])", "%%%1"))
end

function LootChatParser:BuildLootItemPattern(template, withQuantity)
    if type(template) ~= "string" or template == "" then
        return nil
    end

    local pattern = string.gsub(template, "%%s", "(.+)")
    if withQuantity then
        pattern = string.gsub(pattern, "%%d", "(%%d+)")
    end
    return pattern
end

function LootChatParser:BuildLootItemPatterns()
    local singlePatterns = {}
    local multiplePatterns = {}

    local singlePattern = self:BuildLootItemPattern(LOOT_ITEM_SELF, false)
    if singlePattern then
        singlePatterns[#singlePatterns + 1] = singlePattern
    end

    singlePattern = self:BuildLootItemPattern(LOOT_ITEM_PUSHED_SELF, false)
    if singlePattern then
        singlePatterns[#singlePatterns + 1] = singlePattern
    end

    local multiplePattern = self:BuildLootItemPattern(LOOT_ITEM_SELF_MULTIPLE, true)
    if multiplePattern then
        multiplePatterns[#multiplePatterns + 1] = multiplePattern
    end

    multiplePattern = self:BuildLootItemPattern(LOOT_ITEM_PUSHED_SELF_MULTIPLE, true)
    if multiplePattern then
        multiplePatterns[#multiplePatterns + 1] = multiplePattern
    end

    if #singlePatterns == 0 then
        singlePatterns[#singlePatterns + 1] = "You receive loot: (.+)"
    end
    if #multiplePatterns == 0 then
        multiplePatterns[#multiplePatterns + 1] = "You receive loot: (.+)x(%d+)"
    end

    return singlePatterns, multiplePatterns
end

function LootChatParser:BuildMoneyLootPatterns()
    local patterns = {}

    local function AddPattern(pattern)
        patterns[#patterns + 1] = "^" .. pattern .. "$"

        local relaxed = string.gsub(pattern, "%s*%%[%.%!%?]%s*$", "")
        if relaxed ~= pattern then
            patterns[#patterns + 1] = "^" .. relaxed .. "[%.%!%?]?$"
        end
    end

    local function Add(template)
        if type(template) ~= "string" or template == "" then
            return
        end

        local pattern = self:EscapePattern(template)
        pattern = string.gsub(pattern, "%%%%s", "(.+)")
        pattern = string.gsub(pattern, "%%%%d", "(%%d+)")
        AddPattern(pattern)
    end

    Add(LOOT_MONEY)
    Add(YOU_LOOT_MONEY)

    if #patterns == 0 then
        patterns[#patterns + 1] = "^You loot (.+)$"
    end

    return patterns
end

function LootChatParser:RefreshPatterns()
    self.selfLootSinglePatterns, self.selfLootMultiplePatterns = self:BuildLootItemPatterns()
    self.selfLootMoneyPatterns = self:BuildMoneyLootPatterns()
end

function LootChatParser:ParseMoneyFromDigits(text)
    local digits = {}
    for numberText in string.gmatch(tostring(text), "(%d+)") do
        digits[#digits + 1] = tonumber(numberText)
    end

    local copperPerGold = tonumber(self.addon and self.addon.COPPER_PER_GOLD) or 10000
    if #digits >= 3 then
        return (digits[#digits - 2] * copperPerGold) + (digits[#digits - 1] * 100) + digits[#digits]
    end
    if #digits == 2 then
        return (digits[1] * 100) + digits[2]
    end
    if #digits == 1 then
        return digits[1]
    end
    return 0
end

function LootChatParser:ParseLooseNumber(text)
    if type(text) ~= "string" then
        return nil
    end

    local digits = string.gsub(text, "[^%d]", "")
    if digits == "" then
        return nil
    end

    return tonumber(digits)
end

function LootChatParser:ParseMoneyFromFormattedUnits(text)
    local total = 0
    local found = false

    local function Add(template, multiplier)
        if type(template) ~= "string" or template == "" then
            return
        end

        local pattern = string.gsub(self:EscapePattern(template), "%%%%d", "([%%d%%., ]+)")
        local token = string.match(text, pattern)
        local value = self:ParseLooseNumber(token)
        if value and value > 0 then
            total = total + (value * multiplier)
            found = true
        end
    end

    local copperPerGold = tonumber(self.addon and self.addon.COPPER_PER_GOLD) or 10000
    Add(GOLD_AMOUNT, copperPerGold)
    Add(SILVER_AMOUNT, 100)
    Add(COPPER_AMOUNT, 1)

    if found then
        return total
    end

    return 0
end

function LootChatParser:StripChatFormatting(text)
    if type(text) ~= "string" then
        return ""
    end

    local clean = text
    clean = string.gsub(clean, "|c%x%x%x%x%x%x%x%x", "")
    clean = string.gsub(clean, "|r", "")
    clean = string.gsub(clean, "|T.-|t", "")
    return clean
end

function LootChatParser:IsUsableChatMessageText(message)
    if type(message) ~= "string" then
        return false
    end

    if self:IsSecretValue(message) then
        return false
    end

    return true
end

function LootChatParser:ExtractLootItemFromMessage(message)
    if not self:IsUsableChatMessageText(message) then
        return nil, nil
    end

    for _, pattern in ipairs(self.selfLootMultiplePatterns or {}) do
        local itemLink, quantity = string.match(message, pattern)
        if itemLink then
            return itemLink, tonumber(quantity) or 1
        end
    end

    for _, pattern in ipairs(self.selfLootSinglePatterns or {}) do
        local itemLink = string.match(message, pattern)
        if itemLink then
            return itemLink, 1
        end
    end

    return nil, nil
end

function LootChatParser:ExtractMoneyFromMessage(message)
    if not self:IsUsableChatMessageText(message) then
        return 0
    end

    local cleanMessage = self:StripChatFormatting(message)
    local moneyText
    for _, pattern in ipairs(self.selfLootMoneyPatterns or {}) do
        local captured = string.match(cleanMessage, pattern)
        if captured then
            moneyText = captured
            break
        end
    end

    if not moneyText then
        return 0
    end

    moneyText = self:StripChatFormatting(moneyText)
    local amount = self:ParseMoneyFromFormattedUnits(moneyText)
    if amount > 0 then
        return amount
    end

    return self:ParseMoneyFromDigits(moneyText)
end

NS.LootChatParser = LootChatParser
