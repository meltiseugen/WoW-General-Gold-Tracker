local _, NS = ...
local GoldTracker = NS.GoldTracker

local GUID_TYPE_CREATURE = "Creature"
local GUID_TYPE_GAMEOBJECT = "GameObject"
local GUID_TYPE_PLAYER = "Player"
local GUID_TYPE_PET = "Pet"
local GUID_TYPE_VEHICLE = "Vehicle"
local LOOT_SOURCE_NAME_CACHE_TTL = 900
local RECENT_GATHER_ACTION_WINDOW_SEC = 8
local RECENT_SKINNING_ACTION_WINDOW_SEC = 4

local GATHER_ACTION_BY_SPELL_ID = {
    [2575] = "Mining",
    [2366] = "Herbalism",
    [8613] = "Skinning",
    [7620] = "Fishing",
    [131474] = "Fishing",
}

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

local function IsSecretValue(value)
    return type(issecretvalue) == "function" and issecretvalue(value)
end

local function NormalizeDisplayedSourceName(name)
    if type(name) ~= "string" then
        return nil
    end
    if IsSecretValue(name) then
        return nil
    end

    local cleaned = name
    cleaned = cleaned:gsub("|c%x%x%x%x%x%x%x%x", "")
    cleaned = cleaned:gsub("|r", "")
    cleaned = GoldTracker:Trim(cleaned)
    if cleaned == "" then
        return nil
    end

    return cleaned
end

local function NormalizeSpellName(name)
    if type(name) ~= "string" then
        return nil
    end
    if IsSecretValue(name) then
        return nil
    end
    local normalized = GoldTracker:Trim(string.lower(name))
    if normalized == "" then
        return nil
    end
    return normalized
end

local GATHER_ACTION_BY_SPELL_NAME = nil

local function BuildGatherActionSpellNameMap()
    if type(GATHER_ACTION_BY_SPELL_NAME) == "table" then
        return GATHER_ACTION_BY_SPELL_NAME
    end

    GATHER_ACTION_BY_SPELL_NAME = {}
    for spellID, action in pairs(GATHER_ACTION_BY_SPELL_ID) do
        local spellName = nil
        if C_Spell and type(C_Spell.GetSpellName) == "function" then
            spellName = C_Spell.GetSpellName(spellID)
        else
            spellName = GetSpellInfo(spellID)
        end
        local normalized = NormalizeSpellName(spellName)
        if normalized then
            GATHER_ACTION_BY_SPELL_NAME[normalized] = action
        end
    end

    return GATHER_ACTION_BY_SPELL_NAME
end

local function GetGatherActionForSpell(spellID, spellName)
    local normalizedID = tonumber(spellID)
    if normalizedID then
        local byID = GATHER_ACTION_BY_SPELL_ID[normalizedID]
        if byID then
            return byID
        end
    end

    local normalizedName = NormalizeSpellName(spellName)
    if not normalizedName then
        return nil
    end

    local byName = BuildGatherActionSpellNameMap()[normalizedName]
    if byName then
        return byName
    end

    -- Localized fallback labels available in some clients.
    local localized = {}
    local function AddLocalized(label, action)
        local key = NormalizeSpellName(label)
        if key then
            localized[key] = action
        end
    end
    AddLocalized(PROFESSIONS_MINING, "Mining")
    AddLocalized(PROFESSIONS_HERBALISM, "Herbalism")
    AddLocalized(PROFESSIONS_SKINNING, "Skinning")
    AddLocalized(PROFESSIONS_FISHING, "Fishing")
    return localized[normalizedName]
end

local function GetGUIDType(guid)
    if type(guid) ~= "string" then
        return nil
    end
    if IsSecretValue(guid) then
        return nil
    end
    return guid:match("^([^-]+)")
end

local function GetItemTypeLabelFromGuidType(guidType)
    if guidType == GUID_TYPE_CREATURE then
        return "Unit"
    end
    if guidType == GUID_TYPE_GAMEOBJECT then
        return "Object/Node"
    end
    if guidType == GUID_TYPE_PLAYER then
        return "Player"
    end
    if guidType == GUID_TYPE_PET then
        return "Pet"
    end
    if guidType == GUID_TYPE_VEHICLE then
        return "Vehicle"
    end
    return "Unknown"
end

function GoldTracker:CleanupLootSourceNameCache()
    if type(self.lootSourceNameCache) ~= "table" then
        self.lootSourceNameCache = {}
        return
    end

    local now = time()
    for guid, entry in pairs(self.lootSourceNameCache) do
        local seenAt = tonumber(entry and entry.seenAt) or 0
        if (now - seenAt) > LOOT_SOURCE_NAME_CACHE_TTL then
            self.lootSourceNameCache[guid] = nil
        end
    end
end

function GoldTracker:RememberLootSourceName(guid, name)
    if type(guid) ~= "string" or guid == "" then
        return
    end
    if IsSecretValue(guid) then
        return
    end

    local normalizedName = NormalizeDisplayedSourceName(name)
    if not normalizedName then
        return
    end

    if type(self.lootSourceNameCache) ~= "table" then
        self.lootSourceNameCache = {}
    end
    self.lootSourceNameCache[guid] = {
        name = normalizedName,
        seenAt = time(),
    }
end

function GoldTracker:GetLootSourceNameFromGUID(guid, allowUnitTokenScan)
    if type(guid) ~= "string" or guid == "" then
        return nil
    end
    if IsSecretValue(guid) then
        return nil
    end

    if type(self.lootSourceNameCache) == "table" then
        local cached = self.lootSourceNameCache[guid]
        if type(cached) == "table" then
            local cachedName = NormalizeDisplayedSourceName(cached.name)
            if cachedName then
                return cachedName
            end
        end
    end

    local guidType = GetGUIDType(guid)
    if guidType == GUID_TYPE_PLAYER and type(GetPlayerInfoByGUID) == "function" then
        local playerName = select(6, GetPlayerInfoByGUID(guid))
        if IsSecretValue(playerName) then
            playerName = nil
        end
        playerName = NormalizeDisplayedSourceName(playerName)
        if playerName then
            self:RememberLootSourceName(guid, playerName)
            return playerName
        end
    end

    if guidType ~= GUID_TYPE_CREATURE and guidType ~= GUID_TYPE_PLAYER and guidType ~= GUID_TYPE_PET and guidType ~= GUID_TYPE_VEHICLE then
        return nil
    end

    -- Expensive unit-token scans are optional. During loot-open we prefer cache-only
    -- lookups to avoid adding visible delay to autoloot/loot UI flow.
    if allowUnitTokenScan ~= true then
        return nil
    end

    local function TryUnitToken(unitID)
        if not (UnitExists and UnitGUID and UnitName) then
            return nil
        end
        local exists = UnitExists(unitID)
        if IsSecretValue(exists) or not exists then
            return nil
        end
        local unitGUID = UnitGUID(unitID)
        if IsSecretValue(unitGUID) or unitGUID ~= guid then
            return nil
        end
        local unitName = UnitName(unitID)
        if IsSecretValue(unitName) then
            unitName = nil
        end
        unitName = NormalizeDisplayedSourceName(unitName)
        if unitName then
            self:RememberLootSourceName(guid, unitName)
            return unitName
        end
        return nil
    end

    for _, unitID in ipairs({ "target", "mouseover", "focus" }) do
        local resolvedName = TryUnitToken(unitID)
        if resolvedName then
            return resolvedName
        end
    end

    return nil
end

local function BuildLootSourceDescriptor(kind, name, guid, sourceCount, text, dominantSourceCount, isAoe)
    local normalizedKind = kind or "Unknown"
    local normalizedName = NormalizeDisplayedSourceName(name)
    local count = math.max(1, tonumber(sourceCount) or 1)
    local dominantCount = math.max(1, tonumber(dominantSourceCount) or count)
    local displayText = type(text) == "string" and text or normalizedKind
    if displayText == "" then
        displayText = normalizedKind
    end

    return {
        kind = normalizedKind,
        name = normalizedName,
        guid = guid,
        count = count,
        dominantSourceCount = dominantCount,
        isAoe = isAoe == true,
        text = displayText,
    }
end

function GoldTracker:GetRecentGatherAction()
    local action = self.lastGatherAction
    if type(action) ~= "table" then
        return nil
    end

    local now = (GetTimePreciseSec and GetTimePreciseSec()) or GetTime()
    local at = tonumber(action.at) or 0
    local ageSec = now - at
    if at <= 0 or ageSec > RECENT_GATHER_ACTION_WINDOW_SEC then
        return nil
    end

    return action.kind, ageSec
end

function GoldTracker:BuildLootSourceInfoForSlot(slotIndex, sourceArgsOverride)
    local sourceArgs = sourceArgsOverride
    if type(sourceArgs) ~= "table" then
        if type(GetLootSourceInfo) ~= "function" then
            return nil
        end
        sourceArgs = { GetLootSourceInfo(slotIndex) }
    end
    if #sourceArgs == 0 then
        return nil
    end

    local kindCounts = {}
    local kindWeightedCounts = {}
    local totalSources = 0
    local totalWeightedSources = 0
    local firstGuid
    local entries = {}

    for i = 1, #sourceArgs, 2 do
        local sourceGUID = sourceArgs[i]
        if type(sourceGUID) == "string" and sourceGUID ~= "" and not IsSecretValue(sourceGUID) then
            local sourceCount = math.max(1, math.floor(tonumber(sourceArgs[i + 1]) or 1))
            totalSources = totalSources + 1
            local guidType = GetGUIDType(sourceGUID)
            local kindLabel = GetItemTypeLabelFromGuidType(guidType)
            kindCounts[kindLabel] = (kindCounts[kindLabel] or 0) + 1
            kindWeightedCounts[kindLabel] = (kindWeightedCounts[kindLabel] or 0) + sourceCount
            totalWeightedSources = totalWeightedSources + sourceCount

            local sourceName = self:GetLootSourceNameFromGUID(sourceGUID, false)
            entries[#entries + 1] = {
                guid = sourceGUID,
                guidType = guidType,
                kind = kindLabel,
                quantity = sourceCount,
                name = sourceName,
            }

            if not firstGuid then
                firstGuid = sourceGUID
            end
        end
    end

    if totalSources == 0 then
        return nil
    end

    local uniqueKindCount = 0
    local dominantKind
    local dominantWeightedCount = 0
    local dominantSourceCount = 0
    for kindLabel, sourceCount in pairs(kindCounts) do
        uniqueKindCount = uniqueKindCount + 1
        local weightedCount = tonumber(kindWeightedCounts[kindLabel]) or sourceCount
        if not dominantKind
            or weightedCount > dominantWeightedCount
            or (weightedCount == dominantWeightedCount and sourceCount > dominantSourceCount)
            or (weightedCount == dominantWeightedCount and sourceCount == dominantSourceCount and tostring(kindLabel) < tostring(dominantKind)) then
            dominantKind = kindLabel
            dominantWeightedCount = weightedCount
            dominantSourceCount = sourceCount
        end
    end

    local recentGatherAction, recentGatherAgeSec = self:GetRecentGatherAction()
    local normalizedKind = dominantKind or "Unknown"
    if normalizedKind == "Object/Node" and (
        recentGatherAction == "Mining"
        or recentGatherAction == "Herbalism"
        or recentGatherAction == "Fishing") then
        normalizedKind = recentGatherAction
    elseif normalizedKind == "Unit"
        and recentGatherAction == "Skinning"
        and (tonumber(recentGatherAgeSec) or 999) <= RECENT_SKINNING_ACTION_WINDOW_SEC then
        normalizedKind = "Skinning"
    end

    local weightedNames = {}
    local namesInOrder = {}
    for _, entry in ipairs(entries) do
        if entry.kind == dominantKind then
            local normalizedName = NormalizeDisplayedSourceName(entry.name)
            if normalizedName then
                if not weightedNames[normalizedName] then
                    weightedNames[normalizedName] = 0
                    namesInOrder[#namesInOrder + 1] = normalizedName
                end
                weightedNames[normalizedName] = weightedNames[normalizedName] + (tonumber(entry.quantity) or 1)
            end
        end
    end
    table.sort(namesInOrder, function(a, b)
        local aWeight = tonumber(weightedNames[a]) or 0
        local bWeight = tonumber(weightedNames[b]) or 0
        if aWeight ~= bWeight then
            return aWeight > bWeight
        end
        return tostring(a) < tostring(b)
    end)

    local primaryName = namesInOrder[1]
    local displayText
    if normalizedKind == "Unit" then
        if primaryName and dominantSourceCount <= 1 then
            displayText = string.format("Unit: %s", primaryName)
        elseif primaryName and #namesInOrder > 1 then
            local shownNames = {}
            local maxShown = math.min(3, #namesInOrder)
            for i = 1, maxShown do
                shownNames[#shownNames + 1] = namesInOrder[i]
            end
            displayText = string.format("Units: %s", table.concat(shownNames, ", "))
            if #namesInOrder > maxShown then
                displayText = string.format("%s +%d", displayText, #namesInOrder - maxShown)
            end
        elseif primaryName and dominantSourceCount > 1 then
            displayText = string.format("Units: %s (x%d)", primaryName, dominantSourceCount)
        elseif dominantSourceCount > 1 then
            displayText = string.format("Units (x%d)", dominantSourceCount)
        else
            displayText = "Unit"
        end
    elseif normalizedKind == "Skinning" then
        if primaryName and dominantSourceCount <= 1 then
            displayText = string.format("Skinning: %s", primaryName)
        elseif primaryName and #namesInOrder > 1 then
            local shownNames = {}
            local maxShown = math.min(3, #namesInOrder)
            for i = 1, maxShown do
                shownNames[#shownNames + 1] = namesInOrder[i]
            end
            displayText = string.format("Skinning: %s", table.concat(shownNames, ", "))
            if #namesInOrder > maxShown then
                displayText = string.format("%s +%d", displayText, #namesInOrder - maxShown)
            end
        elseif primaryName and dominantSourceCount > 1 then
            displayText = string.format("Skinning: %s (x%d)", primaryName, dominantSourceCount)
        else
            displayText = "Skinning"
        end
    else
        if primaryName and dominantSourceCount <= 1 then
            displayText = string.format("%s: %s", normalizedKind, primaryName)
        elseif dominantSourceCount > 1 then
            displayText = string.format("%s (x%d)", normalizedKind, dominantSourceCount)
        else
            displayText = normalizedKind
        end
    end

    local isAoe = totalSources > 1 or dominantSourceCount > 1
    local returnedKind = normalizedKind
    if uniqueKindCount > 1 then
        local dominanceRatio = 0
        if totalWeightedSources > 0 then
            dominanceRatio = dominantWeightedCount / totalWeightedSources
        end
        if dominanceRatio >= 0.60 then
            displayText = string.format("%s [mixed]", displayText)
        else
            returnedKind = "Mixed"
            displayText = string.format("Mixed: %s", displayText)
        end
        isAoe = true
    end

    if isAoe then
        displayText = string.format("AOE %s", displayText)
    end

    return BuildLootSourceDescriptor(returnedKind, primaryName, firstGuid, totalSources, displayText, dominantSourceCount, isAoe)
end

function GoldTracker:BuildPendingLootSourceEntries()
    self.pendingLootSourceEntries = {}
    self.pendingLootFallbackSourceInfo = nil

    if type(GetNumLootItems) ~= "function" or type(GetLootSlotLink) ~= "function" or type(GetLootSlotInfo) ~= "function" then
        return
    end

    local numLootItems = tonumber(GetNumLootItems()) or 0
    local hasAoeSources = false
    local fallbackSourceText = nil
    local uniqueSourceGuids = {}
    local uniqueSourceGuidCount = 0

    for slotIndex = 1, numLootItems do
        local sourceArgs = nil
        if type(GetLootSourceInfo) == "function" then
            sourceArgs = { GetLootSourceInfo(slotIndex) }
            for i = 1, #sourceArgs, 2 do
                local sourceGUID = sourceArgs[i]
                if type(sourceGUID) == "string"
                    and sourceGUID ~= ""
                    and not IsSecretValue(sourceGUID)
                    and not uniqueSourceGuids[sourceGUID] then
                    uniqueSourceGuids[sourceGUID] = true
                    uniqueSourceGuidCount = uniqueSourceGuidCount + 1
                end
            end
        end

        local itemLink = GetLootSlotLink(slotIndex)
        if type(itemLink) == "string" and itemLink ~= "" and not IsSecretValue(itemLink) then
            local _, _, quantity = GetLootSlotInfo(slotIndex)
            local sourceInfo = self:BuildLootSourceInfoForSlot(slotIndex, sourceArgs)
            local normalizedQuantity = math.max(1, math.floor(tonumber(quantity) or 1))
            if sourceInfo and sourceInfo.isAoe == true then
                hasAoeSources = true
                fallbackSourceText = sourceInfo.text or fallbackSourceText
            end
            self.pendingLootSourceEntries[#self.pendingLootSourceEntries + 1] = {
                itemLink = itemLink,
                itemID = self:GetItemIDFromLink(itemLink),
                quantity = normalizedQuantity,
                sourceInfo = sourceInfo,
            }
        end
    end

    if uniqueSourceGuidCount > 1 then
        hasAoeSources = true

        if type(fallbackSourceText) == "string"
            and fallbackSourceText ~= ""
            and not string.match(fallbackSourceText, "^AOE%s") then
            fallbackSourceText = string.format("AOE %s", fallbackSourceText)
        end

        for _, entry in ipairs(self.pendingLootSourceEntries) do
            local sourceInfo = entry and entry.sourceInfo
            if sourceInfo then
                sourceInfo.isAoe = true
                if type(sourceInfo.text) ~= "string" or sourceInfo.text == "" then
                    sourceInfo.text = "AOE loot"
                elseif not string.match(sourceInfo.text, "^AOE%s") then
                    sourceInfo.text = string.format("AOE %s", sourceInfo.text)
                end
            end
        end
    end

    if hasAoeSources then
        self.pendingLootFallbackSourceInfo = {
            kind = "AOE",
            name = nil,
            guid = nil,
            count = 0,
            dominantSourceCount = 0,
            isAoe = true,
            text = (type(fallbackSourceText) == "string" and fallbackSourceText ~= "") and fallbackSourceText or "AOE loot",
        }
    end
end

function GoldTracker:ConsumePendingLootSourceForItem(itemLink, quantity)
    local pending = self.pendingLootSourceEntries
    if type(pending) ~= "table" or #pending == 0 then
        return nil
    end

    local normalizedQuantity = math.max(1, math.floor(tonumber(quantity) or 1))
    local itemID = self:GetItemIDFromLink(itemLink)
    local matchIndex

    for index, entry in ipairs(pending) do
        local sameItem = false
        if itemID and entry.itemID then
            sameItem = itemID == entry.itemID
        else
            sameItem = entry.itemLink == itemLink
        end

        if sameItem and (tonumber(entry.quantity) or 1) == normalizedQuantity then
            matchIndex = index
            break
        end
    end

    if not matchIndex then
        for index, entry in ipairs(pending) do
            local sameItem = false
            if itemID and entry.itemID then
                sameItem = itemID == entry.itemID
            else
                sameItem = entry.itemLink == itemLink
            end

            if sameItem then
                matchIndex = index
                break
            end
        end
    end

    if not matchIndex then
        return self.pendingLootFallbackSourceInfo
    end

    local matched = pending[matchIndex]
    if not matched then
        return self.pendingLootFallbackSourceInfo
    end

    local remaining = math.max(0, tonumber(matched.quantity) or 0)
    remaining = remaining - normalizedQuantity
    if remaining <= 0 then
        table.remove(pending, matchIndex)
    else
        matched.quantity = remaining
    end

    local sourceInfo = matched.sourceInfo
    if sourceInfo then
        return sourceInfo
    end

    return self.pendingLootFallbackSourceInfo
end

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

        local lootSourceInfo = self:ConsumePendingLootSourceForItem(itemLink, quantity)
        self:TrackLootItem(itemLink, quantity, lootSourceInfo)
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

function GoldTracker:OnUnitSpellcastSucceeded(unitTarget, _, spellID)
    if IsSecretValue(unitTarget) then
        return
    end
    if unitTarget ~= "player" then
        return
    end

    local normalizedSpellID = tonumber(spellID)
    local spellName = nil
    if normalizedSpellID then
        if C_Spell and type(C_Spell.GetSpellName) == "function" then
            spellName = C_Spell.GetSpellName(normalizedSpellID)
        else
            spellName = GetSpellInfo(normalizedSpellID)
        end
    end

    local action = GetGatherActionForSpell(normalizedSpellID, spellName)
    if not action then
        return
    end

    self.lastGatherAction = {
        kind = action,
        spellID = normalizedSpellID,
        spellName = spellName,
        at = (GetTimePreciseSec and GetTimePreciseSec()) or GetTime(),
    }
end

function GoldTracker:OnLootOpened()
    self:BuildPendingLootSourceEntries()
    local now = time()
    local nextCleanupAt = tonumber(self.lootSourceNameCacheNextCleanupAt) or 0
    if now >= nextCleanupAt then
        self:CleanupLootSourceNameCache()
        self.lootSourceNameCacheNextCleanupAt = now + 60
    end
end

function GoldTracker:OnLootClosed()
    self.pendingLootSourceEntries = {}
    self.pendingLootFallbackSourceInfo = nil
end

function GoldTracker:CaptureLootSourceNameFromUnit(unitToken)
    if IsSecretValue(unitToken) then
        return
    end
    if type(unitToken) ~= "string" or unitToken == "" then
        return
    end
    if not (UnitExists and UnitGUID and UnitName) then
        return
    end

    local exists = UnitExists(unitToken)
    if IsSecretValue(exists) or not exists then
        return
    end

    local unitGUID = UnitGUID(unitToken)
    if IsSecretValue(unitGUID) or type(unitGUID) ~= "string" or unitGUID == "" then
        return
    end

    local unitName = UnitName(unitToken)
    if IsSecretValue(unitName) then
        unitName = nil
    end
    unitName = NormalizeDisplayedSourceName(unitName)
    if not unitName then
        return
    end

    self:RememberLootSourceName(unitGUID, unitName)
end

function GoldTracker:OnPlayerTargetChanged()
    self:CaptureLootSourceNameFromUnit("target")
end

function GoldTracker:OnUpdateMouseoverUnit()
    self:CaptureLootSourceNameFromUnit("mouseover")
end

function GoldTracker:OnNamePlateUnitAdded(unitToken)
    self:CaptureLootSourceNameFromUnit(unitToken)
end

function GoldTracker:OnPlayerFocusChanged()
    self:CaptureLootSourceNameFromUnit("focus")
end

function GoldTracker:OnCombatLogEventUnfiltered()
    -- No longer registered. Kept as a no-op for compatibility with existing references.
    local now = time()
    local nextCleanupAt = tonumber(self.lootSourceNameCacheNextCleanupAt) or 0
    if now >= nextCleanupAt then
        self:CleanupLootSourceNameCache()
        self.lootSourceNameCacheNextCleanupAt = now + 60
    end
end
