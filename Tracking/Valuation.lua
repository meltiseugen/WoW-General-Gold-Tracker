local _, NS = ...
local GoldTracker = NS.GoldTracker

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

function GoldTracker:GetCurrentSessionLootLocationData()
    local session = self.session or {}
    return {
        locationKey = session.locationKey,
        locationLabel = BuildLocationLabel(session),
        isInstanced = session.isInstanced == true,
        instanceName = session.instanceName,
        zoneName = session.zoneName,
        mapID = session.mapID,
        mapName = session.mapName,
        mapPath = session.mapPath,
        continentName = session.continentName,
        expansionID = session.expansionID,
        expansionName = session.expansionName,
    }
end

function GoldTracker:GetVendorItemValue(itemLink)
    local vendorPrice = select(11, GetItemInfo(itemLink))
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

function GoldTracker:GetItemUnitValue(itemLink)
    local primarySource = self:GetCurrentValueSource()
    local primaryValue = self:GetItemUnitValueFromSource(primarySource and primarySource.id, itemLink)
    if primaryValue > 0 then
        return primaryValue, primarySource.id, primarySource.label
    end

    local fallbackSource = self:GetFallbackValueSource()
    if fallbackSource then
        local fallbackValue = self:GetItemUnitValueFromSource(fallbackSource.id, itemLink)
        if fallbackValue > 0 then
            return fallbackValue, fallbackSource.id, fallbackSource.label
        end
    end

    return 0, primarySource.id, primarySource.label
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

    local trackItemStart = self:BeginDiagnosticTimer()
    local previousSessionTotal = self:GetSessionTotalValue()
    local lootTimestamp = time()

    quantity = math.max(1, math.floor(tonumber(quantity) or 1))

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
        if (type(lootSourceText) ~= "string" or lootSourceText == "") and (lootSourceIsAoe or lootSourceKind == "AOE") then
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
        mapName = locationData.mapName,
        mapPath = locationData.mapPath,
        continentName = locationData.continentName,
        expansionID = locationData.expansionID,
        expansionName = locationData.expansionName,
        ahTracked = shouldTrackForAH == true,
        lootSourceType = lootSourceKind,
        lootSourceName = lootSourceName,
        lootSourceIsAoe = lootSourceIsAoe,
        lootSourceText = lootSourceText,
        isCraftingReagent = isCraftingReagent == true,
    }
    self.session.itemLoots[#self.session.itemLoots + 1] = sessionLootEntry

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
