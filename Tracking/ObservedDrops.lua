local _, NS = ...
local GoldTracker = NS.GoldTracker

local OBSERVED_MIN_ITEM_QUALITY = 2
local MergeObservedDropData
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
    return self:NormalizeObservedSavedSessionDrops()
end

function GoldTracker:NormalizeObservedSavedSessionDrops()
    if type(self.db) ~= "table" then
        return {}
    end
    if type(self.db.observedDropsShared) ~= "table" then
        self.db.observedDropsShared = {}
    end
    if type(self.db.observedSavedSessionDrops) ~= "table" then
        self.db.observedSavedSessionDrops = {}
    end
    if type(self.db.observedDropsShared.savedSessionDrops) ~= "table"
        or (next(self.db.observedDropsShared.savedSessionDrops) == nil and next(self.db.observedSavedSessionDrops) ~= nil) then
        self.db.observedDropsShared.savedSessionDrops = self.db.observedSavedSessionDrops
    end
    self.db.observedSavedSessionDrops = self.db.observedDropsShared.savedSessionDrops
    local shared = self.db.observedDropsShared
    local drops = shared.savedSessionDrops
    if not shared.automaticCollectionInitialized then
        -- Old aggregate rows predate per-loot import markers. Seed those
        -- markers from the previous scan time once, then use entry markers.
        local scannedAt = tonumber(shared.savedSessionDropsScannedAt or self.db.observedSavedSessionDropsScannedAt)
        for _, drop in pairs(drops) do
            drop.legacyObservedImportedThrough = scannedAt or tonumber(drop.lastSeenAt)
        end
        for key, drop in pairs(self.db.observedWorldDrops or {}) do
            if not drops[key] then
                drops[key] = drop
                drop.legacyObservedImportedThrough = tonumber(drop.lastSeenAt)
            elseif drops[key] ~= drop then
                MergeObservedDropData(drops[key], drop)
                drops[key].legacyObservedImportedThrough = math.max(
                    tonumber(drops[key].legacyObservedImportedThrough) or 0,
                    tonumber(drop.lastSeenAt) or 0
                )
            end
        end
        shared.automaticCollectionInitialized = true
    end
    -- Keep the old live-capture name as an alias of the persistent list.
    self.db.observedWorldDrops = drops
    return self.db.observedSavedSessionDrops
end

local function IsSavedSessionTrashLoot(entry)
    if type(entry) ~= "table" then
        return false
    end
    if entry.lootSourceIsAoe == true then
        return true
    end

    local sourceKind = entry.lootSourceType
    -- LootSourceService records creature loot as Unit/Units.  NPC is kept for
    -- older saved sessions and AOE covers merged multi-source loot.
    if sourceKind == "NPC" or sourceKind == "Unit" or sourceKind == "Units" or sourceKind == "AOE" then
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
        mapX = entry.mapX,
        mapY = entry.mapY,
        mapName = entry.mapName or session.mapName,
        mapPath = entry.mapPath or session.mapPath,
        continentName = entry.continentName or session.continentName,
        expansionID = tonumber(entry.expansionID) or tonumber(session.expansionID),
        expansionName = entry.expansionName or session.expansionName,
    }
end

local function AddObservedLootLocation(locations, location, sourceText)
    local mapID = tonumber(location and location.mapID)
    if not mapID or mapID <= 0 then
        return
    end
    local x, y = tonumber(location.mapX), tonumber(location.mapY)
    if not x or not y or x ~= x or y ~= y or x < 0 or x > 1 or y < 0 or y > 1 then
        x, y = nil, nil
    end
    for _, saved in ipairs(locations) do
        if saved.mapID == mapID and saved.mapX == x and saved.mapY == y then
            return
        end
    end
    locations[#locations + 1] = {
        mapID = mapID,
        mapX = x,
        mapY = y,
        mapName = location.mapName,
        locationLabel = location.locationLabel,
        sourceText = sourceText or location.sourceText,
    }
end

MergeObservedDropData = function(existing, incoming)
    for field, value in pairs(incoming) do
        if existing[field] == nil then
            existing[field] = value
        end
    end
    for _, field in ipairs({ "totalQuantity", "seenCount", "lastSeenAt" }) do
        existing[field] = math.max(tonumber(existing[field]) or 0, tonumber(incoming[field]) or 0)
    end
    for _, field in ipairs({ "locations", "sources" }) do
        existing[field] = existing[field] or {}
        for label, count in pairs(incoming[field] or {}) do
            existing[field][label] = math.max(tonumber(existing[field][label]) or 0, tonumber(count) or 0)
        end
    end
    existing.lootLocations = existing.lootLocations or {}
    if existing.lootLocations ~= incoming.lootLocations then
        for _, location in ipairs(incoming.lootLocations or {}) do
            AddObservedLootLocation(existing.lootLocations, location)
        end
    end
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
    existing.lootLocations = existing.lootLocations or {}
    AddObservedLootLocation(existing.lootLocations, locationData, lootSourceInfo and lootSourceInfo.text)
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

function GoldTracker:UpdateObservedDropLootLocation(itemLink, location, source)
    local drop = self:NormalizeObservedSavedSessionDrops()[self:GetObservedWorldDropKey(itemLink)]
    if drop then
        drop.lootLocations = drop.lootLocations or {}
        AddObservedLootLocation(drop.lootLocations, location, source and source.text)
    end
end

function GoldTracker:GetObservedDropLootLocations(drop)
    local locations = {}
    if type(drop) ~= "table" then
        return locations
    end
    for _, location in ipairs(drop.lootLocations or {}) do
        AddObservedLootLocation(locations, location)
    end

    -- Older observed lists discarded coordinates. Recover them only on Map
    -- click, from the matching loot entries rather than a session's start spot.
    local history = type(self.GetSessionHistory) == "function" and self:GetSessionHistory()
        or (self.db and self.db.sessionHistory) or {}
    for _, session in ipairs(history) do
        for _, entry in ipairs(session.itemLoots or {}) do
            if IsSavedSessionTrashLoot(entry) and self:GetObservedWorldDropKey(entry.itemLink) == drop.itemKey then
                AddObservedLootLocation(locations, BuildSavedSessionLocationData(entry, session), entry.lootSourceText)
            end
        end
    end
    AddObservedLootLocation(locations, {
        mapID = drop.lastMapID,
        mapName = drop.lastMapName,
        locationLabel = drop.lastLocationLabel,
    }, drop.lastSourceText)
    return locations
end

function GoldTracker:ShouldRecordObservedWorldDrop(itemLink, itemQuality, isSoulboundLoot, isCraftingReagent, lootSourceInfo)
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

function GoldTracker:RecordObservedWorldDrop(itemLink, quantity, itemQuality, isSoulboundLoot, isCraftingReagent, lootSourceInfo, locationData, valuationData)
    if not self:ShouldRecordObservedWorldDrop(itemLink, itemQuality, isSoulboundLoot, isCraftingReagent, lootSourceInfo) then
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
    if recorded and type(self.RefreshLiveObservedDrops) == "function" then
        self:RefreshLiveObservedDrops()
    end
    return recorded
end

function GoldTracker:ScanSavedSessionsForObservedDrops()
    local history = type(self.GetSessionHistory) == "function" and self:GetSessionHistory() or (self.db and self.db.sessionHistory) or {}
    local savedSessionDrops = self:NormalizeObservedSavedSessionDrops()
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
                        lootSourceInfo
                    ) then
                        if itemQuality and itemQuality > 4 then
                            result.skippedItems = result.skippedItems + 1
                        else
                            local itemKey = self:GetObservedWorldDropKey(itemLink)
                            local existing = savedSessionDrops[itemKey]
                            local cutoff = existing and tonumber(existing.legacyObservedImportedThrough)
                            local alreadyRecorded = existing and (entry.observedDropRecorded == true
                                or (cutoff and (tonumber(entry.timestamp) or 0) <= cutoff))
                            result.eligibleItems = result.eligibleItems + 1
                            local location = BuildSavedSessionLocationData(entry, session)
                            local recorded
                            if alreadyRecorded then
                                existing.lootLocations = existing.lootLocations or {}
                                AddObservedLootLocation(existing.lootLocations, location, lootSourceInfo.text)
                                result.alreadyImportedItems = result.alreadyImportedItems + 1
                                recorded = true
                            else
                                recorded = RecordObservedWorldDropInStore(
                                    self, savedSessionDrops, itemLink, entry.quantity, itemQuality,
                                    lootSourceInfo, location, BuildSavedSessionValuationData(self, entry, session)
                                )
                            end
                            if recorded then
                                entry.observedDropRecorded = true
                                if existing then
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

    for _, drop in pairs(savedSessionDrops) do
        drop.legacyObservedImportedThrough = nil
    end
    if type(self.db) == "table" then
        if type(self.db.observedDropsShared) ~= "table" then
            self.db.observedDropsShared = {}
        end
        local scannedAt = type(time) == "function" and time() or nil
        self.db.observedDropsShared.savedSessionDrops = savedSessionDrops
        self.db.observedDropsShared.savedSessionDropsScannedAt = scannedAt
        self.db.observedSavedSessionDrops = savedSessionDrops
        self.db.observedSavedSessionDropsScannedAt = scannedAt
    end
    if type(self.RecordDiscoveredItemMarketSnapshots) == "function" then
        local discoveredItems = {}
        for _, item in pairs(savedSessionDrops) do
            discoveredItems[#discoveredItems + 1] = item
        end
        self:RecordDiscoveredItemMarketSnapshots(discoveredItems)
    end

    return result
end
