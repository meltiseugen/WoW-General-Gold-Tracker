local _, NS = ...
local GoldTracker = NS.GoldTracker

local OBSERVED_MIN_ITEM_QUALITY = 2
local MAX_OBSERVED_WORLD_DROP_ITEMS = 2000
local GATHER_SOURCE_KINDS = {
    Mining = true,
    Herbalism = true,
    Skinning = true,
    Fishing = true,
    ["Object/Node"] = true,
}

local function NormalizeCopper(value)
    local normalizedValue = tonumber(value)
    if normalizedValue and normalizedValue > 0 then
        return math.floor(normalizedValue + 0.5)
    end
    return 0
end

local function GetRawTSMValue(addon, itemLink, tsmKey, selectedValueSourceID, selectedUnitValue)
    local selectedSource = addon.VALUE_SOURCE_BY_ID and addon.VALUE_SOURCE_BY_ID[selectedValueSourceID]
    if selectedSource and selectedSource.tsmKey == tsmKey then
        return NormalizeCopper(selectedUnitValue)
    end

    if type(addon.GetTSMRawCustomValue) ~= "function" then
        return 0
    end

    return NormalizeCopper(addon:GetTSMRawCustomValue(tsmKey, itemLink))
end

function GoldTracker:NormalizeObservedWorldDrops()
    if type(self.db) ~= "table" then
        return {}
    end
    if type(self.db.observedWorldDrops) ~= "table" then
        self.db.observedWorldDrops = {}
    end
    return self.db.observedWorldDrops
end

function GoldTracker:NormalizeObservedSavedSessionDrops()
    if type(self.db) ~= "table" then
        return {}
    end
    if type(self.db.observedSavedSessionDrops) ~= "table" then
        self.db.observedSavedSessionDrops = {}
    end
    return self.db.observedSavedSessionDrops
end

local function NormalizeObservedWorldDropSessionImports(addon)
    if type(addon.db) ~= "table" then
        return {}
    end
    if type(addon.db.observedWorldDropSessionImports) ~= "table" then
        addon.db.observedWorldDropSessionImports = {}
    end
    return addon.db.observedWorldDropSessionImports
end

local function ShouldIgnoreObservedDropFeatureFlag(options)
    return type(options) == "table" and options.ignoreFeatureFlag == true
end

local function IsSavedSessionTrashLoot(entry)
    if type(entry) ~= "table" then
        return false
    end
    if entry.lootSourceIsAoe == true then
        return true
    end

    local sourceKind = entry.lootSourceType
    if sourceKind == "NPC" or sourceKind == "AOE" then
        return true
    end

    local sourceText = type(entry.lootSourceText) == "string" and string.lower(entry.lootSourceText) or ""
    return sourceText == "aoe loot"
end

local function BuildSavedSessionLootSource(entry)
    local sourceKind = entry.lootSourceType
    if entry.lootSourceIsAoe == true and (type(sourceKind) ~= "string" or sourceKind == "") then
        sourceKind = "AOE"
    end

    local sourceText = entry.lootSourceText
    if (type(sourceText) ~= "string" or sourceText == "") and (sourceKind == "AOE" or entry.lootSourceIsAoe == true) then
        sourceText = "AOE loot"
    end

    return {
        kind = sourceKind,
        name = entry.lootSourceName,
        text = sourceText,
        isAoe = entry.lootSourceIsAoe == true,
    }
end

local function BuildSavedSessionLocationData(entry, session)
    return {
        locationKey = entry.locationKey or session.locationKey,
        locationLabel = entry.locationLabel or session.locationLabel,
        isInstanced = entry.isInstanced == true or session.isInstanced == true,
        instanceName = entry.instanceName or session.instanceName,
        zoneName = entry.zoneName or session.zoneName,
        mapID = tonumber(entry.mapID) or tonumber(session.mapID),
        mapName = entry.mapName or session.mapName,
        mapPath = entry.mapPath or session.mapPath,
        continentName = entry.continentName or session.continentName,
        expansionID = tonumber(entry.expansionID) or tonumber(session.expansionID),
        expansionName = entry.expansionName or session.expansionName,
    }
end

local function BuildSavedSessionValuationData(addon, entry, session)
    local sourceID = entry.valueSourceID or session.valueSourceID
    local sourceLabel = entry.valueSourceLabel or session.valueSourceLabel
    if type(addon.GetValueSourceLabel) == "function" then
        sourceLabel = addon:GetValueSourceLabel(sourceID, sourceLabel)
    end

    local selectedUnitValue = NormalizeCopper(entry.unitValue)
    if selectedUnitValue <= 0 and type(addon.GetItemUnitValueFromSource) == "function" and sourceID then
        selectedUnitValue = NormalizeCopper(addon:GetItemUnitValueFromSource(sourceID, entry.itemLink))
    end

    return {
        selectedUnitValue = selectedUnitValue,
        selectedValueSourceID = sourceID,
        selectedValueSourceLabel = sourceLabel,
    }
end

local function RecordObservedWorldDropInStore(addon, observedDrops, itemLink, quantity, itemQuality, lootSourceInfo, locationData, valuationData)
    local itemKey = addon:GetObservedWorldDropKey(itemLink)
    if type(itemKey) ~= "string" or itemKey == "" then
        return false
    end

    local now = time()
    local itemID = addon:GetItemIDFromLink(itemLink)
    local normalizedQuantity = math.max(1, math.floor(tonumber(quantity) or 1))
    local selectedUnitValue = NormalizeCopper(valuationData and valuationData.selectedUnitValue)
    local selectedValueSourceID = valuationData and valuationData.selectedValueSourceID or nil
    local selectedValueSourceLabel = valuationData and valuationData.selectedValueSourceLabel or nil

    local existing = observedDrops[itemKey]
    if type(existing) ~= "table" then
        existing = {
            itemKey = itemKey,
            itemID = itemID,
            itemLink = itemLink,
            firstSeenAt = now,
            totalQuantity = 0,
            seenCount = 0,
            locations = {},
            sources = {},
        }
        observedDrops[itemKey] = existing
    end
    if type(existing.locations) ~= "table" then
        existing.locations = {}
    end
    if type(existing.sources) ~= "table" then
        existing.sources = {}
    end

    existing.itemID = itemID or existing.itemID
    existing.itemLink = itemLink
    existing.itemQuality = tonumber(itemQuality) or existing.itemQuality
    existing.lastSeenAt = now
    existing.totalQuantity = math.max(0, tonumber(existing.totalQuantity) or 0) + normalizedQuantity
    existing.seenCount = math.max(0, tonumber(existing.seenCount) or 0) + 1
    existing.value = selectedUnitValue
    existing.valueSourceID = selectedValueSourceID
    existing.valueSourceLabel = selectedValueSourceLabel
    existing.marketValue = GetRawTSMValue(addon, itemLink, "DBMarket", selectedValueSourceID, selectedUnitValue)
    existing.regionMarketValue = GetRawTSMValue(addon, itemLink, "DBRegionMarketAvg", selectedValueSourceID, selectedUnitValue)
    existing.averageValue = GetRawTSMValue(addon, itemLink, "DBRegionSaleAvg", selectedValueSourceID, selectedUnitValue)

    local locationLabel = locationData and locationData.locationLabel or nil
    if type(locationLabel) == "string" and locationLabel ~= "" then
        existing.lastLocationLabel = locationLabel
        existing.locations[locationLabel] = (tonumber(existing.locations[locationLabel]) or 0) + normalizedQuantity
    end
    existing.lastMapID = locationData and locationData.mapID or existing.lastMapID
    existing.lastMapName = locationData and locationData.mapName or existing.lastMapName
    existing.lastExpansionID = locationData and locationData.expansionID or existing.lastExpansionID
    existing.lastExpansionName = locationData and locationData.expansionName or existing.lastExpansionName

    local sourceText = lootSourceInfo and lootSourceInfo.text or nil
    if type(sourceText) == "string" and sourceText ~= "" then
        existing.lastSourceText = sourceText
        existing.sources[sourceText] = (tonumber(existing.sources[sourceText]) or 0) + normalizedQuantity
    end
    existing.lastSourceName = lootSourceInfo and lootSourceInfo.name or existing.lastSourceName
    existing.lastSourceType = lootSourceInfo and lootSourceInfo.kind or existing.lastSourceType

    return true
end

function GoldTracker:ShouldRecordObservedWorldDrop(itemLink, itemQuality, isSoulboundLoot, isCraftingReagent, lootSourceInfo, options)
    if not ShouldIgnoreObservedDropFeatureFlag(options) and not self:IsObservedWorldDropsEnabled() then
        return false
    end
    if type(itemLink) ~= "string" or itemLink == "" or not string.find(itemLink, "|Hitem:", 1, true) then
        return false
    end
    local normalizedQuality = tonumber(itemQuality)
    if not normalizedQuality or normalizedQuality < OBSERVED_MIN_ITEM_QUALITY then
        return false
    end
    if isSoulboundLoot == true or isCraftingReagent == true then
        return false
    end

    local sourceKind = lootSourceInfo and lootSourceInfo.kind
    if GATHER_SOURCE_KINDS[sourceKind] then
        return false
    end

    return true
end

function GoldTracker:GetObservedWorldDropKey(itemLink)
    return self:GetTSMItemStringFromLink(itemLink) or itemLink
end

function GoldTracker:PruneObservedWorldDrops()
    local observedDrops = self:NormalizeObservedWorldDrops()
    local itemCount = 0
    for _ in pairs(observedDrops) do
        itemCount = itemCount + 1
    end

    while itemCount > MAX_OBSERVED_WORLD_DROP_ITEMS do
        local oldestKey
        local oldestSeenAt
        for key, item in pairs(observedDrops) do
            local seenAt = tonumber(item and item.lastSeenAt) or 0
            if not oldestSeenAt or seenAt < oldestSeenAt then
                oldestKey = key
                oldestSeenAt = seenAt
            end
        end
        if not oldestKey then
            return
        end
        observedDrops[oldestKey] = nil
        itemCount = itemCount - 1
    end
end

function GoldTracker:RecordObservedWorldDrop(itemLink, quantity, itemQuality, isSoulboundLoot, isCraftingReagent, lootSourceInfo, locationData, valuationData, options)
    if not self:ShouldRecordObservedWorldDrop(itemLink, itemQuality, isSoulboundLoot, isCraftingReagent, lootSourceInfo, options) then
        return false
    end

    local observedDrops = self:NormalizeObservedWorldDrops()
    local recorded = RecordObservedWorldDropInStore(
        self,
        observedDrops,
        itemLink,
        quantity,
        itemQuality,
        lootSourceInfo,
        locationData,
        valuationData
    )
    if recorded then
        self:PruneObservedWorldDrops()
    end
    return recorded
end

function GoldTracker:ScanSavedSessionsForObservedDrops()
    local history = type(self.GetSessionHistory) == "function" and self:GetSessionHistory() or (self.db and self.db.sessionHistory) or {}
    NormalizeObservedWorldDropSessionImports(self)
    local savedSessionDrops = {}
    local result = {
        scannedSessions = 0,
        scannedItems = 0,
        eligibleItems = 0,
        addedItems = 0,
        updatedItems = 0,
        alreadyImportedItems = 0,
        skippedItems = 0,
    }

    for _, session in ipairs(history) do
        if type(session) == "table" and type(session.itemLoots) == "table" then
            result.scannedSessions = result.scannedSessions + 1
            for _, entry in ipairs(session.itemLoots) do
                result.scannedItems = result.scannedItems + 1
                if type(entry) == "table" and IsSavedSessionTrashLoot(entry) then
                    local itemLink = entry.itemLink
                    local itemQuality = tonumber(entry.itemQuality)
                    if not itemQuality and type(self.GetItemQualityFromLink) == "function" then
                        itemQuality = self:GetItemQualityFromLink(itemLink)
                    end

                    local lootSourceInfo = BuildSavedSessionLootSource(entry)
                    if self:ShouldRecordObservedWorldDrop(
                        itemLink,
                        itemQuality,
                        entry.isSoulbound == true,
                        entry.isCraftingReagent == true,
                        lootSourceInfo,
                        { ignoreFeatureFlag = true }
                    ) then
                        if itemQuality and itemQuality > 4 then
                            result.skippedItems = result.skippedItems + 1
                        else
                            local itemKey = self:GetObservedWorldDropKey(itemLink)
                            local existed = type(itemKey) == "string" and savedSessionDrops[itemKey] ~= nil
                            result.eligibleItems = result.eligibleItems + 1
                            local recorded = RecordObservedWorldDropInStore(
                                self,
                                savedSessionDrops,
                                itemLink,
                                entry.quantity,
                                itemQuality,
                                lootSourceInfo,
                                BuildSavedSessionLocationData(entry, session),
                                BuildSavedSessionValuationData(self, entry, session)
                            )
                            if recorded then
                                if existed then
                                    result.updatedItems = result.updatedItems + 1
                                else
                                    result.addedItems = result.addedItems + 1
                                end
                            else
                                result.skippedItems = result.skippedItems + 1
                            end
                        end
                    else
                        result.skippedItems = result.skippedItems + 1
                    end
                else
                    result.skippedItems = result.skippedItems + 1
                end
            end
        end
    end

    if type(self.db) == "table" then
        self.db.observedSavedSessionDrops = savedSessionDrops
        self.db.observedSavedSessionDropsScannedAt = type(time) == "function" and time() or nil
    end

    return result
end
