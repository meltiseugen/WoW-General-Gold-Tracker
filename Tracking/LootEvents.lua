local _, NS = ...
local GoldTracker = NS.GoldTracker

local function EscapePattern(text)
    return (string.gsub(text, "([%(%)%.%%%+%-%*%?%[%]%^%$])", "%%%1"))
end

local function BuildLootItemPattern(template, withQuantity)
    if type(template) ~= "string" or template == "" then
        return nil
    end

    local pattern = string.gsub(template, "%%s", "(.+)")
    if withQuantity then
        pattern = string.gsub(pattern, "%%d", "(%%d+)")
    end
    return pattern
end

local function BuildLootItemPatterns()
    local singlePatterns = {}
    local multiplePatterns = {}

    local singlePattern = BuildLootItemPattern(LOOT_ITEM_SELF, false)
    if singlePattern then
        singlePatterns[#singlePatterns + 1] = singlePattern
    end

    singlePattern = BuildLootItemPattern(LOOT_ITEM_PUSHED_SELF, false)
    if singlePattern then
        singlePatterns[#singlePatterns + 1] = singlePattern
    end

    local multiplePattern = BuildLootItemPattern(LOOT_ITEM_SELF_MULTIPLE, true)
    if multiplePattern then
        multiplePatterns[#multiplePatterns + 1] = multiplePattern
    end

    multiplePattern = BuildLootItemPattern(LOOT_ITEM_PUSHED_SELF_MULTIPLE, true)
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

local function BuildMoneyLootPatterns()
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

        local pattern = EscapePattern(template)
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

local function ParseMoneyFromDigits(text)
    local digits = {}
    for numberText in string.gmatch(tostring(text), "(%d+)") do
        digits[#digits + 1] = tonumber(numberText)
    end

    if #digits >= 3 then
        return (digits[#digits - 2] * GoldTracker.COPPER_PER_GOLD) + (digits[#digits - 1] * 100) + digits[#digits]
    end
    if #digits == 2 then
        return (digits[1] * 100) + digits[2]
    end
    if #digits == 1 then
        return digits[1]
    end
    return 0
end

local function ParseLooseNumber(text)
    if type(text) ~= "string" then
        return nil
    end

    local digits = string.gsub(text, "[^%d]", "")
    if digits == "" then
        return nil
    end

    return tonumber(digits)
end

local function ParseMoneyFromFormattedUnits(text)
    local total = 0
    local found = false

    local function Add(template, multiplier)
        if type(template) ~= "string" or template == "" then
            return
        end

        local pattern = string.gsub(EscapePattern(template), "%%%%d", "([%%d%%., ]+)")
        local token = string.match(text, pattern)
        local value = ParseLooseNumber(token)
        if value and value > 0 then
            total = total + (value * multiplier)
            found = true
        end
    end

    Add(GOLD_AMOUNT, GoldTracker.COPPER_PER_GOLD)
    Add(SILVER_AMOUNT, 100)
    Add(COPPER_AMOUNT, 1)

    if found then
        return total
    end

    return 0
end

local function StripChatFormatting(text)
    if type(text) ~= "string" then
        return ""
    end

    local clean = text
    clean = string.gsub(clean, "|c%x%x%x%x%x%x%x%x", "")
    clean = string.gsub(clean, "|r", "")
    clean = string.gsub(clean, "|T.-|t", "")
    return clean
end

local SELF_LOOT_SINGLE_PATTERNS, SELF_LOOT_MULTIPLE_PATTERNS = BuildLootItemPatterns()
local SELF_LOOT_MONEY_PATTERNS = BuildMoneyLootPatterns()

function GoldTracker:IsUsableChatMessageText(message)
    if type(message) ~= "string" then
        return false
    end

    if type(issecretvalue) == "function" and issecretvalue(message) then
        return false
    end

    return true
end

function GoldTracker:ExtractLootItemFromMessage(message)
    if not self:IsUsableChatMessageText(message) then
        return nil, nil
    end

    for _, pattern in ipairs(SELF_LOOT_MULTIPLE_PATTERNS) do
        local itemLink, quantity = string.match(message, pattern)
        if itemLink then
            return itemLink, tonumber(quantity) or 1
        end
    end

    for _, pattern in ipairs(SELF_LOOT_SINGLE_PATTERNS) do
        local itemLink = string.match(message, pattern)
        if itemLink then
            return itemLink, 1
        end
    end

    return nil, nil
end

function GoldTracker:ShouldAutoStartSessionOnLoot()
    if not self.db or not self.db.autoStartSessionOnFirstLoot then
        return false
    end
    if not self.mainFrame or not self.mainFrame:IsShown() then
        return false
    end
    return true
end

function GoldTracker:EnsureSessionForTrackedLoot()
    if self.session.active then
        return true
    end

    if not self:ShouldAutoStartSessionOnLoot() then
        return false
    end

    self:StartSession()
    return self.session.active
end

function GoldTracker:OnChatMsgLoot(message, playerName, _, _, _, _, _, _, _, _, _, playerGUID)
    local hasActiveSession = self.session and self.session.active
    if not hasActiveSession and not self:ShouldAutoStartSessionOnLoot() then
        return
    end

    if not self:IsUsableChatMessageText(message) then
        return
    end

    if self.session and self.session.active then
        self:HandleSessionLocationTransition()
    end

    local itemLink, quantity = self:ExtractLootItemFromMessage(message)
    if itemLink then
        if not string.find(itemLink, "|Hitem:", 1, true) and not string.find(itemLink, "|Hbattlepet:", 1, true) then
            return
        end

        if not self:EnsureSessionForTrackedLoot() then
            return
        end

        self:TrackLootItem(itemLink, quantity)
        return
    end

    local amount = self:ExtractMoneyFromMessage(message)
    if not amount or amount <= 0 then
        return
    end

    if not self:EnsureSessionForTrackedLoot() then
        return
    end

    self:TryTrackMoneyAmount(amount)
end

function GoldTracker:ExtractMoneyFromMessage(message)
    if not self:IsUsableChatMessageText(message) then
        return 0
    end

    local cleanMessage = StripChatFormatting(message)

    local moneyText
    for _, pattern in ipairs(SELF_LOOT_MONEY_PATTERNS) do
        local captured = string.match(cleanMessage, pattern)
        if captured then
            moneyText = captured
            break
        end
    end

    if not moneyText then
        return 0
    end

    moneyText = StripChatFormatting(moneyText)
    local amount = ParseMoneyFromFormattedUnits(moneyText)
    if amount > 0 then
        return amount
    end

    return ParseMoneyFromDigits(moneyText)
end

function GoldTracker:TryTrackMoneyAmount(amount)
    if not amount or amount <= 0 then
        return false
    end

    local now = (GetTimePreciseSec and GetTimePreciseSec()) or GetTime()
    if self.lastTrackedMoneyAmount == amount
        and self.lastTrackedMoneyAt
        and (now - self.lastTrackedMoneyAt) <= 0.05 then
        return true
    end

    self.lastTrackedMoneyAmount = amount
    self.lastTrackedMoneyAt = now
    self:TrackLootMoney(amount)
    return true
end

function GoldTracker:OnChatMsgMoney(message)
    local hasActiveSession = self.session and self.session.active
    if not hasActiveSession and not self:ShouldAutoStartSessionOnLoot() then
        return
    end

    if not self:IsUsableChatMessageText(message) then
        return
    end

    if self.session and self.session.active then
        self:HandleSessionLocationTransition()
    end

    local amount = self:ExtractMoneyFromMessage(message)
    if not amount or amount <= 0 then
        return
    end

    if not self:EnsureSessionForTrackedLoot() then
        return
    end

    self:TryTrackMoneyAmount(amount)
end
