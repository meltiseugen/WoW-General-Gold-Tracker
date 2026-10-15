local _, NS = ...
local GoldTracker = NS.GoldTracker

local LOOT_COORDINATE_CACHE_MAX_AGE_SECONDS = 5
local LOOT_COORDINATE_RETRY_DELAYS = { 0.1, 0.5, 1.0 }

local function BuildLocationLabel(session)
    if type(session) ~= "table" then
        return "Unknown"
    end

    local baseName
    if session.isInstanced == true then
        baseName = session.instanceName or session.zoneName or session.mapName
    else
        baseName = session.zoneName or session.mapName
    end
    if type(baseName) ~= "string" or baseName == "" then
        baseName = "Unknown"
    end

    local expansionName = session.expansionName
    if type(expansionName) == "string" and expansionName ~= "" then
        return string.format("%s (%s)", baseName, expansionName)
    end

    return baseName
end

local function NormalizeMapCoordinate(value)
    local ok, coordinate = pcall(function()
        local normalized = tonumber(value)
        if not normalized then
            return nil
        end
        if normalized > 1 then
            normalized = normalized / 100
        end
        if normalized < 0 or normalized > 1 then
            return nil
        end
        return normalized
    end)
    if not ok then
        return nil
    end
    return coordinate
end

local function ReadMapPositionXY(position)
    if position == nil then
        return nil, nil
    end

    local methodOK, getXY = pcall(function()
        return position.GetXY
    end)
    if methodOK and type(getXY) == "function" then
        local ok, x, y = pcall(getXY, position)
        if ok then
            return NormalizeMapCoordinate(x), NormalizeMapCoordinate(y)
        end
    end

    local okX, x = pcall(function()
        return position.x or position[1]
    end)
    local okY, y = pcall(function()
        return position.y or position[2]
    end)
    return okX and NormalizeMapCoordinate(x) or nil, okY and NormalizeMapCoordinate(y) or nil
end

local function GetCoordinateClock()
    if type(GetTimePreciseSec) == "function" then
        return GetTimePreciseSec()
    end
    if type(GetTime) == "function" then
        return GetTime()
    end
    return type(time) == "function" and time() or 0
end

local function GetCurrentPlayerMapCoordinates(mapID)
    local normalizedMapID = tonumber(mapID)
    if not normalizedMapID or not C_Map or type(C_Map.GetPlayerMapPosition) ~= "function" then
        return nil, nil
    end

    local ok, position = pcall(C_Map.GetPlayerMapPosition, normalizedMapID, "player")
    if not ok then
        return nil, nil
    end

    return ReadMapPositionXY(position)
end

local function AddMapCandidate(candidates, seen, mapID)
    local normalizedMapID = tonumber(mapID)
    if not normalizedMapID or normalizedMapID <= 0 then
        return
    end
    normalizedMapID = math.floor(normalizedMapID + 0.5)
    if seen[normalizedMapID] then
        return
    end
    seen[normalizedMapID] = true
    candidates[#candidates + 1] = normalizedMapID
end

local function GetCurrentBestMapID()
    if type(C_Map) ~= "table" or type(C_Map.GetBestMapForUnit) ~= "function" then
        return nil
    end
    local ok, mapID = pcall(C_Map.GetBestMapForUnit, "player")
    if not ok then
        return nil
    end
    return tonumber(mapID)
end

local function GetCoordinateCapturedAt()
    return type(time) == "function" and time() or nil
end

local function ApplyResolvedMapDetails(addon, location, mapID, session)
    location.mapID = mapID
    if tonumber(session.mapID) == tonumber(mapID) then
        return
    end
    if type(addon.GetMapLocationDetails) ~= "function" then
        return
    end

    local details = addon:GetMapLocationDetails(mapID)
    if type(details) ~= "table" then
        return
    end
    location.mapName = details.mapName or location.mapName
    location.mapPath = details.mapPath or location.mapPath
    location.continentName = details.continentName or location.continentName
    location.expansionID = details.expansionID or location.expansionID
    location.expansionName = details.expansionName or location.expansionName
end

function GoldTracker:GetCurrentSessionLootLocationData(options)
    options = type(options) == "table" and options or {}
    local session = self.session or {}
    local candidates = {}
    local seenCandidates = {}
    AddMapCandidate(candidates, seenCandidates, GetCurrentBestMapID())
    AddMapCandidate(candidates, seenCandidates, session.mapID)

    local resolvedMapID
    local mapX
    local mapY
    local coordinateSource = "unavailable"
    for _, candidateMapID in ipairs(candidates) do
        mapX, mapY = GetCurrentPlayerMapCoordinates(candidateMapID)
        if mapX ~= nil and mapY ~= nil then
            resolvedMapID = candidateMapID
            coordinateSource = "live"
            self.lastLootMapPosition = {
                mapID = candidateMapID,
                mapX = mapX,
                mapY = mapY,
                capturedAt = GetCoordinateClock(),
                coordinateCapturedAt = GetCoordinateCapturedAt(),
            }
            break
        end
    end

    if not resolvedMapID and options.ignoreCache ~= true then
        local cached = self.lastLootMapPosition
        local cacheAge = GetCoordinateClock() - (tonumber(cached and cached.capturedAt) or 0)
        if type(cached) == "table"
            and seenCandidates[tonumber(cached.mapID)] == true
            and cacheAge >= 0
            and cacheAge <= LOOT_COORDINATE_CACHE_MAX_AGE_SECONDS then
            resolvedMapID = tonumber(cached.mapID)
            mapX = NormalizeMapCoordinate(cached.mapX)
            mapY = NormalizeMapCoordinate(cached.mapY)
            if mapX ~= nil and mapY ~= nil then
                coordinateSource = "cached"
            else
                resolvedMapID = nil
            end
        end
    end

    local location = {
        locationKey = session.locationKey,
        locationLabel = BuildLocationLabel(session),
        isInstanced = session.isInstanced == true,
        instanceName = session.instanceName,
        zoneName = session.zoneName,
        mapID = resolvedMapID or candidates[1] or session.mapID,
        mapX = mapX,
        mapY = mapY,
        mapName = session.mapName,
        mapPath = session.mapPath,
        continentName = session.continentName,
        expansionID = session.expansionID,
        expansionName = session.expansionName,
        coordinateSource = coordinateSource,
        coordinateCapturedAt = coordinateSource == "cached"
            and tonumber(self.lastLootMapPosition and self.lastLootMapPosition.coordinateCapturedAt)
            or (coordinateSource == "live" and GetCoordinateCapturedAt() or nil),
    }
    ApplyResolvedMapDetails(self, location, location.mapID, session)
    return location
end

local function ApplyLootCoordinateLocation(target, location)
    if type(target) ~= "table" or type(location) ~= "table" then
        return false
    end
    local mapX = NormalizeMapCoordinate(location.mapX)
    local mapY = NormalizeMapCoordinate(location.mapY)
    if mapX == nil or mapY == nil then
        return false
    end

    target.locationKey = location.locationKey or target.locationKey
    target.locationLabel = location.locationLabel or target.locationLabel
    target.isInstanced = location.isInstanced == true
    target.instanceName = location.instanceName or target.instanceName
    target.zoneName = location.zoneName or target.zoneName
    target.mapID = tonumber(location.mapID) or target.mapID
    target.mapX = mapX
    target.mapY = mapY
    target.mapName = location.mapName or target.mapName
    target.mapPath = location.mapPath or target.mapPath
    target.continentName = location.continentName or target.continentName
    target.expansionID = tonumber(location.expansionID) or target.expansionID
    target.expansionName = location.expansionName or target.expansionName
    target.coordinateCapturedAt = tonumber(location.coordinateCapturedAt) or target.coordinateCapturedAt
    return true
end

local function IncrementCoordinateDiagnostic(addon, key)
    if type(addon.IncrementDiagnosticCounter) == "function" then
        addon:IncrementDiagnosticCounter(key)
    end
end

function GoldTracker:ScheduleLootCoordinateRecovery(lootEntry, onFinished)
    if type(lootEntry) ~= "table" or (lootEntry.mapX ~= nil and lootEntry.mapY ~= nil) then
        return false
    end

    local timerAfter = type(C_Timer) == "table" and C_Timer.After or nil
    if type(timerAfter) ~= "function" then
        lootEntry.coordinateSource = "unavailable"
        lootEntry.coordinateRetryCount = 0
        IncrementCoordinateDiagnostic(self, "loot_coordinates_unavailable")
        if type(onFinished) == "function" then
            onFinished(lootEntry, false)
        end
        return false
    end

    lootEntry.coordinateSource = "pending"
    lootEntry.coordinateRetryCount = 0
    IncrementCoordinateDiagnostic(self, "loot_coordinates_pending")

    local retryIndex = 0
    local function RetryCoordinateCapture()
        retryIndex = retryIndex + 1
        local location = self:GetCurrentSessionLootLocationData({ ignoreCache = false })
        if ApplyLootCoordinateLocation(lootEntry, location) then
            lootEntry.coordinateSource = location.coordinateSource == "live" and "retry" or "cached"
            lootEntry.coordinateRetryCount = retryIndex
            IncrementCoordinateDiagnostic(self, "loot_coordinates_recovered")
            if type(onFinished) == "function" then
                onFinished(lootEntry, true)
            end
            return
        end

        if retryIndex < #LOOT_COORDINATE_RETRY_DELAYS then
            timerAfter(LOOT_COORDINATE_RETRY_DELAYS[retryIndex + 1], RetryCoordinateCapture)
            return
        end

        lootEntry.coordinateSource = "unavailable"
        lootEntry.coordinateRetryCount = retryIndex
        IncrementCoordinateDiagnostic(self, "loot_coordinates_unavailable")
        if type(onFinished) == "function" then
            onFinished(lootEntry, false)
        end
    end

    timerAfter(LOOT_COORDINATE_RETRY_DELAYS[1], RetryCoordinateCapture)
    return true
end

function GoldTracker:GetVendorItemValue(itemLink)
    local getItemInfo = C_Item and C_Item.GetItemInfo
    if type(getItemInfo) ~= "function" then
        getItemInfo = GetItemInfo
    end
    if type(getItemInfo) ~= "function" then
        return 0
    end

    local _, _, _, _, _, _, _, _, _, _, vendorPrice = getItemInfo(itemLink)
    if type(vendorPrice) == "number" and vendorPrice > 0 then
        return vendorPrice
    end
    return 0
end

function GoldTracker:GetTSMItemValue(priceSource, itemLink)
    if type(TSM_API) ~= "table" or type(TSM_API.GetCustomPriceValue) ~= "function" then
        if not self.tsmWarningShown then
            self.tsmWarningShown = true
            self:Print("TSM source selected but TradeSkillMaster API is unavailable. Returning 0 for item values.")
        end
        return 0
    end

    local itemString
    if type(TSM_API.ToItemString) == "function" then
        local ok, resolvedItemString = pcall(TSM_API.ToItemString, itemLink)
        if ok and type(resolvedItemString) == "string" and resolvedItemString ~= "" then
            itemString = resolvedItemString
        end
    end
    if not itemString then
        itemString = self:GetTSMItemStringFromLink(itemLink)
    end
    if not itemString then
        return 0
    end

    local ok, value = pcall(TSM_API.GetCustomPriceValue, priceSource, itemString)
    if ok and type(value) == "number" and value > 0 then
        self.tsmWarningShown = false
        return math.floor(value + 0.5)
    end

    local fallbackItemString = self:GetTSMItemStringFromLink(itemLink)
    if fallbackItemString and fallbackItemString ~= itemString then
        ok, value = pcall(TSM_API.GetCustomPriceValue, priceSource, fallbackItemString)
        if ok and type(value) == "number" and value > 0 then
            self.tsmWarningShown = false
            return math.floor(value + 0.5)
        end
    end

    return 0
end

function GoldTracker:GetTSMItemValueFromItemString(priceSource, itemString, suppressWarning)
    if type(TSM_API) ~= "table" or type(TSM_API.GetCustomPriceValue) ~= "function" then
        if not suppressWarning and not self.tsmWarningShown then
            self.tsmWarningShown = true
            self:Print("TSM source selected but TradeSkillMaster API is unavailable. Returning 0 for item values.")
        end
        return 0
    end
    if type(itemString) ~= "string" or itemString == "" then
        return 0
    end

    local ok, value = pcall(TSM_API.GetCustomPriceValue, priceSource, itemString)
    if ok and type(value) == "number" and value > 0 then
        self.tsmWarningShown = false
        return math.floor(value + 0.5)
    end

    return 0
end

function GoldTracker:GetTSMItemValueForItemID(priceSource, itemID, suppressWarning)
    local normalizedItemID = tonumber(itemID)
    if not normalizedItemID then
        return 0
    end

    return self:GetTSMItemValueFromItemString(
        priceSource,
        string.format("i:%d", math.floor(normalizedItemID + 0.5)),
        suppressWarning
    )
end

function GoldTracker:GetTSMRawCustomValue(priceSource, itemLink)
    if type(TSM_API) ~= "table" or type(TSM_API.GetCustomPriceValue) ~= "function" then
        return nil
    end

    local itemString
    if type(TSM_API.ToItemString) == "function" then
        local ok, resolvedItemString = pcall(TSM_API.ToItemString, itemLink)
        if ok then
            itemString = resolvedItemString
        end
    end
    if not itemString then
        itemString = self:GetTSMItemStringFromLink(itemLink)
    end
    if not itemString then
        return nil
    end

    local ok, value = pcall(TSM_API.GetCustomPriceValue, priceSource, itemString)
    if ok and type(value) == "number" and value > 0 then
        return value
    end

    return nil
end

function GoldTracker:GetItemUnitValueFromSource(sourceID, itemLink)
    local source = self.VALUE_SOURCE_BY_ID[sourceID] or self:GetCurrentValueSource()
    if not source then
        return 0, nil, "Unknown"
    end

    local value = 0
    if source.id == "VENDOR" then
        value = self:GetVendorItemValue(itemLink)
    elseif source.tsmKey then
        value = self:GetTSMItemValue(source.tsmKey, itemLink)
    end

    return value, source.id, source.label
end

function GoldTracker:ResolveItemUnitValue(preferredSourceID, itemLink, itemID, suppressWarning)
    local preferredSource = self.VALUE_SOURCE_BY_ID[preferredSourceID] or self:GetCurrentValueSource()
    if not preferredSource then
        return 0, nil, "Unknown", false
    end

    local resolutionOrder
    if type(self.GetValueSourceResolutionOrder) == "function" then
        resolutionOrder = self:GetValueSourceResolutionOrder(preferredSource.id)
    else
        resolutionOrder = { preferredSource.id }
        local legacyFallback = type(self.GetFallbackValueSource) == "function" and self:GetFallbackValueSource() or nil
        if legacyFallback and legacyFallback.id ~= preferredSource.id then
            resolutionOrder[#resolutionOrder + 1] = legacyFallback.id
        end
    end

    for _, sourceID in ipairs(resolutionOrder) do
        local source = self.VALUE_SOURCE_BY_ID[sourceID]
        local value = 0
        if source then
            if type(itemLink) == "string" and itemLink ~= "" then
                value = tonumber((self:GetItemUnitValueFromSource(sourceID, itemLink))) or 0
            elseif tonumber(itemID) and source.tsmKey and type(self.GetTSMItemValueForItemID) == "function" then
                value = tonumber(self:GetTSMItemValueForItemID(source.tsmKey, itemID, suppressWarning)) or 0
            end
        end
        if value > 0 then
            return value, source.id, source.label, source.id ~= preferredSource.id
        end
    end

    return 0, preferredSource.id, preferredSource.label, false
end

function GoldTracker:GetItemUnitValue(itemLink)
    local primarySource = self:GetCurrentValueSource()
    return self:ResolveItemUnitValue(primarySource and primarySource.id, itemLink)
end

function GoldTracker:NotifyHighValueItem(itemLink, quantity, totalValue)
    if type(self.ProcessHighValueDropAlerts) == "function" then
        self:ProcessHighValueDropAlerts(itemLink, quantity, totalValue)
        return
    end
end

function GoldTracker:TrackLootMoney(amount)
    if amount <= 0 then
        return
    end

    local trackMoneyStart = self:BeginDiagnosticTimer()
    local previousSessionTotal = self:GetSessionTotalValue()
    local lootTimestamp = time()

    self:UpdateSessionLocationContext()
    if type(self.session.moneyLoots) ~= "table" then
        self.session.moneyLoots = {}
    end
    local locationData = self:GetCurrentSessionLootLocationData()
    self.session.moneyLoots[#self.session.moneyLoots + 1] = {
        amount = amount,
        timestamp = lootTimestamp,
        locationKey = locationData.locationKey,
        locationLabel = locationData.locationLabel,
        isInstanced = locationData.isInstanced,
        instanceName = locationData.instanceName,
        zoneName = locationData.zoneName,
        mapID = locationData.mapID,
        mapX = locationData.mapX,
        mapY = locationData.mapY,
        mapName = locationData.mapName,
        mapPath = locationData.mapPath,
        continentName = locationData.continentName,
        expansionID = locationData.expansionID,
        expansionName = locationData.expansionName,
    }
    self.session.goldLooted = self.session.goldLooted + amount
    self:IncrementDiagnosticCounter("money_entries_tracked")
    self:IncrementDiagnosticCounter("money_copper_tracked", amount)
    if type(self.MarkSessionLootActivity) == "function" then
        self:MarkSessionLootActivity(lootTimestamp)
    end
    if type(self.ProcessSessionMilestoneAlerts) == "function" then
        self:ProcessSessionMilestoneAlerts(previousSessionTotal, self:GetSessionTotalValue())
    end
    if self.db
        and self.db.showRawLootedGoldInLog
        and self:GetSessionStyleFilter() == self.SESSION_STYLE_ALL_ID
        and type(self.AddLootMoneyLogEntry) == "function" then
        self:AddLootMoneyLogEntry(amount)
    end
    self:UpdateMainWindow()
    self:EndDiagnosticTimer("track_loot_money_total", trackMoneyStart)
end

function GoldTracker:TrackLootItem(itemLink, quantity, lootSourceInfo)
    if not itemLink then
        return
    end

    quantity = math.max(1, math.floor(tonumber(quantity) or 1))
    if type(self.IsOnLootedItem) == "function" and self:IsOnLootedItem(itemLink) then
        self:IncrementDiagnosticCounter("item_filtered_on_looted", quantity)
        return
    end

    local trackItemStart = self:BeginDiagnosticTimer()
    local previousSessionTotal = self:GetSessionTotalValue()
    local lootTimestamp = time()

    local resolveStart = self:BeginDiagnosticTimer()
    local selectedUnitValue, selectedValueSourceID, selectedValueSourceLabel = self:GetItemUnitValue(itemLink)
    self:EndDiagnosticTimer("item_value_resolve", resolveStart)
    local vendorUnitValue = self:GetVendorItemValue(itemLink)
    local itemMetadata = self:GetLootItemMetadata(itemLink)
    local itemQuality = self:GetItemQualityFromLink(itemLink) or itemMetadata.itemQuality
    local isCraftingReagent = itemMetadata.isCraftingReagent == true or self:IsCraftingReagentItem(itemLink)
    local shouldTrackForAH = isCraftingReagent or self:ShouldTrackItemForAH(itemQuality)
    local isSoulboundLoot = false
    local shouldCheckLootBinding = shouldTrackForAH
        or (
            type(self.IsObservedWorldDropsEnabled) == "function"
            and self:IsObservedWorldDropsEnabled()
            and tonumber(itemQuality) == 2
        )
    if shouldCheckLootBinding then
        isSoulboundLoot = self:IsSoulboundLootItem(itemLink)
    end
    local trackLootSource = self:IsLootSourceTrackingEnabled()
    local lootSourceKind = nil
    local lootSourceName = nil
    local lootSourceIsAoe = false
    local lootSourceText = nil
    if trackLootSource then
        lootSourceKind = lootSourceInfo and lootSourceInfo.kind or nil
        lootSourceName = lootSourceInfo and lootSourceInfo.name or nil
        lootSourceIsAoe = lootSourceInfo and lootSourceInfo.isAoe == true
        lootSourceText = lootSourceInfo and lootSourceInfo.text or nil
        if (type(lootSourceText) ~= "string" or lootSourceText == "")
            and (lootSourceIsAoe or lootSourceKind == "AOE") then
            lootSourceText = "AOE loot"
        end
    end
    local observedUnitValue = selectedUnitValue
    if isSoulboundLoot or not shouldTrackForAH then
        selectedUnitValue = 0
    end
    local selectedTotalValue = math.max(0, math.floor((selectedUnitValue * quantity) + 0.5))
    local vendorTotalValue = math.max(0, math.floor((vendorUnitValue * quantity) + 0.5))
    local highlightThreshold = self:GetHighlightThreshold()

    self:UpdateSessionLocationContext()
    local locationData = self:GetCurrentSessionLootLocationData()
    if type(self.RecordObservedWorldDrop) == "function" then
        self:RecordObservedWorldDrop(
            itemLink,
            quantity,
            itemQuality,
            isSoulboundLoot,
            isCraftingReagent,
            lootSourceInfo,
            locationData,
            {
                selectedUnitValue = observedUnitValue,
                selectedValueSourceID = selectedValueSourceID,
                selectedValueSourceLabel = selectedValueSourceLabel,
            }
        )
    end
    self.session.itemValue = (self.session.itemValue or 0) + selectedTotalValue
    self.session.itemVendorValue = (self.session.itemVendorValue or 0) + vendorTotalValue
    self:IncrementDiagnosticCounter("item_entries_tracked")
    self:IncrementDiagnosticCounter("item_quantity_tracked", quantity)
    if not shouldTrackForAH then
        self:IncrementDiagnosticCounter("item_filtered_quality", quantity)
    elseif isSoulboundLoot then
        self:IncrementDiagnosticCounter("item_filtered_soulbound", quantity)
    else
        self:IncrementDiagnosticCounter("item_ah_tracked", quantity)
    end
    if trackLootSource and type(lootSourceText) == "string" and lootSourceText ~= "" then
        self:IncrementDiagnosticCounter("loot_source_attached")
    end
    local isHighlightedLoot = selectedTotalValue > 0 and selectedTotalValue >= highlightThreshold
    if isHighlightedLoot then
        self.session.highlightItemCount = (self.session.highlightItemCount or 0) + 1
    end
    -- Keep legacy counters synchronized for compatibility with previously saved sessions.
    self.session.lowHighlightItemCount = 0
    self.session.highHighlightItemCount = self.session.highlightItemCount or 0

    if type(self.session.itemLoots) ~= "table" then
        self.session.itemLoots = {}
    end
    local sessionLootEntry = {
        itemLink = itemLink,
        itemID = itemMetadata.itemID,
        itemClassID = itemMetadata.itemClassID,
        itemSubclassID = itemMetadata.itemSubclassID,
        itemType = itemMetadata.itemType,
        itemSubType = itemMetadata.itemSubType,
        itemEquipLoc = itemMetadata.itemEquipLoc,
        quantity = quantity,
        unitValue = selectedUnitValue,
        totalValue = selectedTotalValue,
        vendorUnitValue = vendorUnitValue,
        vendorTotalValue = vendorTotalValue,
        isHighlighted = isHighlightedLoot,
        highlightThreshold = isHighlightedLoot and highlightThreshold or nil,
        itemQuality = itemQuality,
        isSoulbound = isSoulboundLoot,
        timestamp = lootTimestamp,
        valueSourceID = selectedValueSourceID,
        valueSourceLabel = selectedValueSourceLabel,
        locationKey = locationData.locationKey,
        locationLabel = locationData.locationLabel,
        isInstanced = locationData.isInstanced,
        instanceName = locationData.instanceName,
        zoneName = locationData.zoneName,
        mapID = locationData.mapID,
        mapX = locationData.mapX,
        mapY = locationData.mapY,
        mapName = locationData.mapName,
        mapPath = locationData.mapPath,
        continentName = locationData.continentName,
        expansionID = locationData.expansionID,
        expansionName = locationData.expansionName,
        coordinateSource = locationData.coordinateSource,
        coordinateCapturedAt = locationData.coordinateCapturedAt,
        coordinateRetryCount = 0,
        ahTracked = shouldTrackForAH == true,
        lootSourceType = lootSourceKind,
        lootSourceName = lootSourceName,
        lootSourceIsAoe = lootSourceIsAoe,
        lootSourceText = lootSourceText,
        isCraftingReagent = isCraftingReagent == true,
    }
    self.session.itemLoots[#self.session.itemLoots + 1] = sessionLootEntry

    local function RecordMaterialLocation(finalLocation)
        if type(self.RecordUserMaterialFarmingPinForLoot) == "function" then
            self:RecordUserMaterialFarmingPinForLoot(
                itemLink,
                quantity,
                itemMetadata,
                isCraftingReagent,
                lootSourceInfo,
                finalLocation
            )
        end
    end
    if sessionLootEntry.mapX ~= nil and sessionLootEntry.mapY ~= nil then
        IncrementCoordinateDiagnostic(
            self,
            sessionLootEntry.coordinateSource == "cached" and "loot_coordinates_cached" or "loot_coordinates_live"
        )
        RecordMaterialLocation(sessionLootEntry)
    else
        self:ScheduleLootCoordinateRecovery(sessionLootEntry, function(finalLocation)
            RecordMaterialLocation(finalLocation)
        end)
    end

    if type(self.RecordDiscoveredItemMarketSnapshots) == "function" then
        self:RecordDiscoveredItemMarketSnapshots(sessionLootEntry)
    elseif type(self.RecordInventoryMarketSnapshots) == "function" then
        self:RecordInventoryMarketSnapshots({ sessionLootEntry })
    end

    if type(self.MarkSessionLootActivity) == "function" then
        self:MarkSessionLootActivity(lootTimestamp)
    end
    if type(self.ProcessSessionMilestoneAlerts) == "function" then
        self:ProcessSessionMilestoneAlerts(previousSessionTotal, self:GetSessionTotalValue())
    end

    local displayedSourceText = nil
    if trackLootSource
        and type(lootSourceText) == "string"
        and lootSourceText ~= "" then
        displayedSourceText = lootSourceText
    elseif trackLootSource and lootSourceIsAoe then
        displayedSourceText = "AOE loot"
    end

    if type(self.AddLootItemLogEntry) == "function" then
        local logValue = selectedTotalValue
        local logSourceParts = {}
        local isAuctionTracked = shouldTrackForAH and not isSoulboundLoot
        if displayedSourceText then
            logSourceParts[#logSourceParts + 1] = displayedSourceText
        end
        if not shouldTrackForAH then
            logValue = vendorTotalValue
            logSourceParts[#logSourceParts + 1] = "Below min quality"
            if vendorTotalValue > 0 then
                logSourceParts[#logSourceParts + 1] = "Vendor only"
            end
        elseif isSoulboundLoot then
            logValue = vendorTotalValue
            logSourceParts[#logSourceParts + 1] = "Soulbound"
            if vendorTotalValue > 0 then
                logSourceParts[#logSourceParts + 1] = "Vendor only"
            end
        end

        self:AddLootItemLogEntry(
            itemLink,
            quantity,
            logValue,
            table.concat(logSourceParts, " | "),
            {
                lootEntry = sessionLootEntry,
                tracked = isAuctionTracked,
                r = isAuctionTracked and 0.9 or 0.82,
                g = isAuctionTracked and 0.9 or 0.84,
                b = isAuctionTracked and 1 or 0.72,
            }
        )
    end

    self:NotifyHighValueItem(itemLink, quantity, selectedTotalValue)
    self:UpdateMainWindow()
    self:EndDiagnosticTimer("track_loot_item_total", trackItemStart)
end
