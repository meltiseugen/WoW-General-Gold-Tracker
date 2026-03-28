local _, NS = ...

local GUID_TYPE_CREATURE = "Creature"
local GUID_TYPE_GAMEOBJECT = "GameObject"
local GUID_TYPE_PLAYER = "Player"
local GUID_TYPE_PET = "Pet"
local GUID_TYPE_VEHICLE = "Vehicle"
local LOOT_SOURCE_NAME_CACHE_TTL = 900
local RECENT_GATHER_ACTION_WINDOW_SEC = 8
local RECENT_SKINNING_ACTION_WINDOW_SEC = 4
local PENDING_LOOT_SOURCE_CLOSE_GRACE_SEC = 2
local MAX_DISPLAYED_SOURCE_NAMES = 3
local MAX_UNIT_TOKEN_SCAN_SOURCES = 4
local NAMEPLATE_SCAN_LIMIT = 40

local GATHER_ACTION_BY_SPELL_ID = {
    [2575] = "Mining",
    [2366] = "Herbalism",
    [8613] = "Skinning",
    [7620] = "Fishing",
    [131474] = "Fishing",
}

local LootSourceService = {}
LootSourceService.__index = LootSourceService

function LootSourceService:New(addon)
    local instance = {
        addon = addon,
        lootSourceNameCache = {},
        lootSourceNameCacheNextCleanupAt = 0,
        pendingLootSourceEntries = {},
        pendingLootFallbackSourceInfo = nil,
        pendingLootCloseExpireAt = nil,
        lastGatherAction = nil,
        gatherActionBySpellName = nil,
        localizedGatherActionBySpellName = nil,
    }
    return setmetatable(instance, LootSourceService)
end

function LootSourceService:IsSecretValue(value)
    return type(issecretvalue) == "function" and issecretvalue(value)
end

function LootSourceService:NormalizeDisplayedSourceName(name)
    if type(name) ~= "string" then
        return nil
    end
    if self:IsSecretValue(name) then
        return nil
    end

    local cleaned = name
    cleaned = cleaned:gsub("|c%x%x%x%x%x%x%x%x", "")
    cleaned = cleaned:gsub("|r", "")

    if type(self.addon) == "table" and type(self.addon.Trim) == "function" then
        cleaned = self.addon:Trim(cleaned)
    else
        cleaned = (cleaned:gsub("^%s+", ""):gsub("%s+$", ""))
    end

    if cleaned == "" then
        return nil
    end

    return cleaned
end

function LootSourceService:NormalizeSpellName(name)
    if type(name) ~= "string" then
        return nil
    end
    if self:IsSecretValue(name) then
        return nil
    end

    local lowered = string.lower(name)
    local normalized
    if type(self.addon) == "table" and type(self.addon.Trim) == "function" then
        normalized = self.addon:Trim(lowered)
    else
        normalized = (lowered:gsub("^%s+", ""):gsub("%s+$", ""))
    end

    if normalized == "" then
        return nil
    end
    return normalized
end

function LootSourceService:BuildGatherActionSpellNameMap()
    if type(self.gatherActionBySpellName) == "table" then
        return self.gatherActionBySpellName
    end

    self.gatherActionBySpellName = {}
    for spellID, action in pairs(GATHER_ACTION_BY_SPELL_ID) do
        local spellName = nil
        if C_Spell and type(C_Spell.GetSpellName) == "function" then
            spellName = C_Spell.GetSpellName(spellID)
        else
            spellName = GetSpellInfo(spellID)
        end
        local normalized = self:NormalizeSpellName(spellName)
        if normalized then
            self.gatherActionBySpellName[normalized] = action
        end
    end

    return self.gatherActionBySpellName
end

function LootSourceService:BuildLocalizedGatherActionSpellNameMap()
    if type(self.localizedGatherActionBySpellName) == "table" then
        return self.localizedGatherActionBySpellName
    end

    local localized = {}
    local function Add(label, action)
        local key = self:NormalizeSpellName(label)
        if key then
            localized[key] = action
        end
    end

    Add(PROFESSIONS_MINING, "Mining")
    Add(PROFESSIONS_HERBALISM, "Herbalism")
    Add(PROFESSIONS_SKINNING, "Skinning")
    Add(PROFESSIONS_FISHING, "Fishing")
    self.localizedGatherActionBySpellName = localized
    return self.localizedGatherActionBySpellName
end

function LootSourceService:GetGatherActionForSpell(spellID, spellName)
    local normalizedID = tonumber(spellID)
    if normalizedID then
        local byID = GATHER_ACTION_BY_SPELL_ID[normalizedID]
        if byID then
            return byID
        end
    end

    local normalizedName = self:NormalizeSpellName(spellName)
    if not normalizedName then
        return nil
    end

    local byName = self:BuildGatherActionSpellNameMap()[normalizedName]
    if byName then
        return byName
    end

    return self:BuildLocalizedGatherActionSpellNameMap()[normalizedName]
end

function LootSourceService:GetGUIDType(guid)
    if type(guid) ~= "string" then
        return nil
    end
    if self:IsSecretValue(guid) then
        return nil
    end
    return guid:match("^([^-]+)")
end

function LootSourceService:GetItemTypeLabelFromGuidType(guidType)
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

function LootSourceService:GetPluralKindLabel(kindLabel)
    if kindLabel == "Unit" then
        return "Units"
    end
    if kindLabel == "Player" then
        return "Players"
    end
    if kindLabel == "Pet" then
        return "Pets"
    end
    if kindLabel == "Vehicle" then
        return "Vehicles"
    end
    if kindLabel == "Object/Node" then
        return "Objects/Nodes"
    end
    return kindLabel
end

function LootSourceService:CleanupLootSourceNameCache()
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

function LootSourceService:CleanupLootSourceNameCacheIfDue(intervalSec)
    local now = time()
    local nextCleanupAt = tonumber(self.lootSourceNameCacheNextCleanupAt) or 0
    if now < nextCleanupAt then
        return
    end

    self:CleanupLootSourceNameCache()
    local interval = math.max(1, math.floor(tonumber(intervalSec) or 60))
    self.lootSourceNameCacheNextCleanupAt = now + interval
end

function LootSourceService:RememberLootSourceName(guid, name)
    if type(guid) ~= "string" or guid == "" then
        return
    end
    if self:IsSecretValue(guid) then
        return
    end

    local normalizedName = self:NormalizeDisplayedSourceName(name)
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

function LootSourceService:GetLootSourceNameFromGUID(guid, allowUnitTokenScan)
    if type(guid) ~= "string" or guid == "" then
        return nil
    end
    if self:IsSecretValue(guid) then
        return nil
    end

    if type(self.lootSourceNameCache) == "table" then
        local cached = self.lootSourceNameCache[guid]
        if type(cached) == "table" then
            local cachedName = self:NormalizeDisplayedSourceName(cached.name)
            if cachedName then
                return cachedName
            end
        end
    end

    local guidType = self:GetGUIDType(guid)
    if guidType == GUID_TYPE_PLAYER and type(GetPlayerInfoByGUID) == "function" then
        local playerName = select(6, GetPlayerInfoByGUID(guid))
        if self:IsSecretValue(playerName) then
            playerName = nil
        end
        playerName = self:NormalizeDisplayedSourceName(playerName)
        if playerName then
            self:RememberLootSourceName(guid, playerName)
            return playerName
        end
    end

    if guidType ~= GUID_TYPE_CREATURE and guidType ~= GUID_TYPE_PLAYER and guidType ~= GUID_TYPE_PET and guidType ~= GUID_TYPE_VEHICLE then
        return nil
    end

    if allowUnitTokenScan ~= true then
        return nil
    end

    local function TryUnitToken(unitID)
        if not (UnitExists and UnitGUID and UnitName) then
            return nil
        end
        local exists = UnitExists(unitID)
        if self:IsSecretValue(exists) or not exists then
            return nil
        end
        local unitGUID = UnitGUID(unitID)
        if self:IsSecretValue(unitGUID) or unitGUID ~= guid then
            return nil
        end
        local unitName = UnitName(unitID)
        if self:IsSecretValue(unitName) then
            unitName = nil
        end
        unitName = self:NormalizeDisplayedSourceName(unitName)
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

function LootSourceService:BuildLootSourceDescriptor(kind, name, guid, sourceCount, text, dominantSourceCount, isAoe)
    local normalizedKind = kind or "Unknown"
    local normalizedName = self:NormalizeDisplayedSourceName(name)
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

function LootSourceService:BuildSourceDisplayText(kindLabel, namesInOrder, sourceCount)
    local normalizedKind = type(kindLabel) == "string" and kindLabel or "Unknown"
    local normalizedCount = math.max(1, math.floor(tonumber(sourceCount) or 1))
    local primaryName = namesInOrder and namesInOrder[1] or nil

    if normalizedCount <= 1 then
        if primaryName then
            return string.format("%s: %s", normalizedKind, primaryName)
        end
        return normalizedKind
    end

    local pluralKind = self:GetPluralKindLabel(normalizedKind)
    if type(namesInOrder) ~= "table" or #namesInOrder == 0 then
        return string.format("%s (%d)", pluralKind, normalizedCount)
    end

    local shownNames = {}
    local maxShown = math.min(MAX_DISPLAYED_SOURCE_NAMES, #namesInOrder)
    for index = 1, maxShown do
        shownNames[#shownNames + 1] = namesInOrder[index]
    end

    local displayText = string.format("%s (%d): %s", pluralKind, normalizedCount, table.concat(shownNames, ", "))
    local remainingCount = math.max(0, normalizedCount - maxShown)
    if remainingCount > 0 then
        displayText = string.format("%s +%d", displayText, remainingCount)
    end

    return displayText
end

function LootSourceService:BuildAoeSourceListText(uniqueSourceGuids, uniqueSourceGuidCount)
    if type(uniqueSourceGuids) ~= "table" then
        return nil
    end

    local sourceNames = {}
    local seenNames = {}
    for guid in pairs(uniqueSourceGuids) do
        local sourceName = self:GetLootSourceNameFromGUID(guid, false)
        sourceName = self:NormalizeDisplayedSourceName(sourceName)
        if sourceName and not seenNames[sourceName] then
            seenNames[sourceName] = true
            sourceNames[#sourceNames + 1] = sourceName
        end
    end
    table.sort(sourceNames)

    local totalCount = math.max(1, math.floor(tonumber(uniqueSourceGuidCount) or #sourceNames))
    if #sourceNames == 0 then
        return string.format("AOE sources (%d)", totalCount)
    end

    local shownNames = {}
    local maxShown = math.min(MAX_DISPLAYED_SOURCE_NAMES, #sourceNames)
    for index = 1, maxShown do
        shownNames[#shownNames + 1] = sourceNames[index]
    end

    local displayText = string.format("AOE sources (%d): %s", totalCount, table.concat(shownNames, ", "))
    local remainingCount = math.max(0, totalCount - maxShown)
    if remainingCount > 0 then
        displayText = string.format("%s +%d", displayText, remainingCount)
    end

    return displayText
end

function LootSourceService:CaptureNearbyLootSourceNames()
    self:CaptureLootSourceNameFromUnit("target")
    self:CaptureLootSourceNameFromUnit("mouseover")
    self:CaptureLootSourceNameFromUnit("focus")

    for index = 1, NAMEPLATE_SCAN_LIMIT do
        self:CaptureLootSourceNameFromUnit(string.format("nameplate%d", index))
    end
end

function LootSourceService:GetRecentGatherAction()
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

function LootSourceService:RecordGatherActionForSpell(spellID)
    local normalizedSpellID = tonumber(spellID)
    local spellName = nil
    if normalizedSpellID then
        if C_Spell and type(C_Spell.GetSpellName) == "function" then
            spellName = C_Spell.GetSpellName(normalizedSpellID)
        else
            spellName = GetSpellInfo(normalizedSpellID)
        end
    end

    local action = self:GetGatherActionForSpell(normalizedSpellID, spellName)
    if not action then
        return false
    end

    self.lastGatherAction = {
        kind = action,
        spellID = normalizedSpellID,
        spellName = spellName,
        at = (GetTimePreciseSec and GetTimePreciseSec()) or GetTime(),
    }
    return true
end

function LootSourceService:BuildLootSourceInfoForSlot(slotIndex, sourceArgsOverride)
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
        if type(sourceGUID) == "string" and sourceGUID ~= "" and not self:IsSecretValue(sourceGUID) then
            local sourceCount = math.max(1, math.floor(tonumber(sourceArgs[i + 1]) or 1))
            totalSources = totalSources + 1
            local guidType = self:GetGUIDType(sourceGUID)
            local kindLabel = self:GetItemTypeLabelFromGuidType(guidType)
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

    if totalSources <= MAX_UNIT_TOKEN_SCAN_SOURCES then
        for _, entry in ipairs(entries) do
            if not entry.name then
                entry.name = self:GetLootSourceNameFromGUID(entry.guid, true)
            end
        end
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
            local normalizedName = self:NormalizeDisplayedSourceName(entry.name)
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
    local displayText = self:BuildSourceDisplayText(normalizedKind, namesInOrder, dominantSourceCount)

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

    return self:BuildLootSourceDescriptor(returnedKind, primaryName, firstGuid, totalSources, displayText, dominantSourceCount, isAoe)
end

function LootSourceService:BuildPendingLootSourceEntries()
    self.pendingLootSourceEntries = {}
    self.pendingLootFallbackSourceInfo = nil
    self.pendingLootCloseExpireAt = nil

    if type(GetNumLootItems) ~= "function" or type(GetLootSlotLink) ~= "function" or type(GetLootSlotInfo) ~= "function" then
        return
    end

    self:CaptureNearbyLootSourceNames()

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
                    and not self:IsSecretValue(sourceGUID)
                    and not uniqueSourceGuids[sourceGUID] then
                    uniqueSourceGuids[sourceGUID] = true
                    uniqueSourceGuidCount = uniqueSourceGuidCount + 1
                end
            end
        end

        local itemLink = GetLootSlotLink(slotIndex)
        if type(itemLink) == "string" and itemLink ~= "" and not self:IsSecretValue(itemLink) then
            local _, _, quantity = GetLootSlotInfo(slotIndex)
            local sourceInfo = self:BuildLootSourceInfoForSlot(slotIndex, sourceArgs)
            local normalizedQuantity = math.max(1, math.floor(tonumber(quantity) or 1))
            if sourceInfo and sourceInfo.isAoe == true then
                hasAoeSources = true
                fallbackSourceText = sourceInfo.text or fallbackSourceText
            end
            local itemID = nil
            if type(self.addon) == "table" and type(self.addon.GetItemIDFromLink) == "function" then
                itemID = self.addon:GetItemIDFromLink(itemLink)
            end
            self.pendingLootSourceEntries[#self.pendingLootSourceEntries + 1] = {
                itemLink = itemLink,
                itemID = itemID,
                quantity = normalizedQuantity,
                sourceInfo = sourceInfo,
            }
        end
    end

    if uniqueSourceGuidCount > 1 then
        hasAoeSources = true
        fallbackSourceText = self:BuildAoeSourceListText(uniqueSourceGuids, uniqueSourceGuidCount) or fallbackSourceText

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

function LootSourceService:ExpirePendingLootSourceEntriesIfNeeded()
    local expireAt = tonumber(self.pendingLootCloseExpireAt)
    if not expireAt then
        return
    end

    local now = (GetTimePreciseSec and GetTimePreciseSec()) or GetTime()
    if now < expireAt then
        return
    end

    self:ClearPendingLootSourceEntries()
end

function LootSourceService:MarkPendingLootSourceEntriesClosed()
    local hasPendingEntries = type(self.pendingLootSourceEntries) == "table" and #self.pendingLootSourceEntries > 0
    if not hasPendingEntries and self.pendingLootFallbackSourceInfo == nil then
        self:ClearPendingLootSourceEntries()
        return
    end

    local now = (GetTimePreciseSec and GetTimePreciseSec()) or GetTime()
    self.pendingLootCloseExpireAt = now + PENDING_LOOT_SOURCE_CLOSE_GRACE_SEC
end

function LootSourceService:ConsumePendingLootSourceForItem(itemLink, quantity)
    self:ExpirePendingLootSourceEntriesIfNeeded()

    local pending = self.pendingLootSourceEntries
    if type(pending) ~= "table" or #pending == 0 then
        return self.pendingLootFallbackSourceInfo
    end

    local normalizedQuantity = math.max(1, math.floor(tonumber(quantity) or 1))
    local itemID = nil
    if type(self.addon) == "table" and type(self.addon.GetItemIDFromLink) == "function" then
        itemID = self.addon:GetItemIDFromLink(itemLink)
    end
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

function LootSourceService:ClearPendingLootSourceEntries()
    self.pendingLootSourceEntries = {}
    self.pendingLootFallbackSourceInfo = nil
    self.pendingLootCloseExpireAt = nil
end

function LootSourceService:CaptureLootSourceNameFromUnit(unitToken)
    if self:IsSecretValue(unitToken) then
        return
    end
    if type(unitToken) ~= "string" or unitToken == "" then
        return
    end
    if not (UnitExists and UnitGUID and UnitName) then
        return
    end

    local exists = UnitExists(unitToken)
    if self:IsSecretValue(exists) or not exists then
        return
    end

    local unitGUID = UnitGUID(unitToken)
    if self:IsSecretValue(unitGUID) or type(unitGUID) ~= "string" or unitGUID == "" then
        return
    end

    local unitName = UnitName(unitToken)
    if self:IsSecretValue(unitName) then
        unitName = nil
    end
    unitName = self:NormalizeDisplayedSourceName(unitName)
    if not unitName then
        return
    end

    self:RememberLootSourceName(unitGUID, unitName)
end

NS.LootSourceService = LootSourceService
