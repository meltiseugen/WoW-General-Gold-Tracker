local _, NS = ...
local GoldTracker = NS.GoldTracker

local MAX_HISTORY_SESSIONS = 300

local function CloneItemLootEntries(itemLoots, fallbackSourceID, fallbackSourceLabel)
    local copied = {}
    for i, entry in ipairs(itemLoots or {}) do
        copied[i] = {
            itemLink = entry.itemLink,
            quantity = tonumber(entry.quantity) or 0,
            unitValue = tonumber(entry.unitValue) or 0,
            totalValue = tonumber(entry.totalValue) or 0,
            vendorUnitValue = tonumber(entry.vendorUnitValue) or 0,
            vendorTotalValue = tonumber(entry.vendorTotalValue) or 0,
            itemQuality = tonumber(entry.itemQuality),
            isSoulbound = entry.isSoulbound == true,
            timestamp = tonumber(entry.timestamp) or 0,
            valueSourceID = entry.valueSourceID or fallbackSourceID,
            valueSourceLabel = entry.valueSourceLabel or fallbackSourceLabel,
            locationKey = entry.locationKey,
            locationLabel = entry.locationLabel,
            isInstanced = entry.isInstanced == true,
            instanceName = entry.instanceName,
            zoneName = entry.zoneName,
            mapID = tonumber(entry.mapID),
            mapName = entry.mapName,
            mapPath = entry.mapPath,
            continentName = entry.continentName,
            expansionID = tonumber(entry.expansionID),
            expansionName = entry.expansionName,
            ahTracked = entry.ahTracked == true,
            lootSourceType = entry.lootSourceType,
            lootSourceName = entry.lootSourceName,
            lootSourceIsAoe = entry.lootSourceIsAoe == true,
            lootSourceText = entry.lootSourceText,
            isCraftingReagent = entry.isCraftingReagent == true,
        }
    end
    return copied
end

local function CloneMoneyLootEntries(moneyLoots)
    local copied = {}
    for i, entry in ipairs(moneyLoots or {}) do
        copied[i] = {
            amount = tonumber(entry.amount) or 0,
            timestamp = tonumber(entry.timestamp) or 0,
            locationKey = entry.locationKey,
            locationLabel = entry.locationLabel,
            isInstanced = entry.isInstanced == true,
            instanceName = entry.instanceName,
            zoneName = entry.zoneName,
            mapID = tonumber(entry.mapID),
            mapName = entry.mapName,
            mapPath = entry.mapPath,
            continentName = entry.continentName,
            expansionID = tonumber(entry.expansionID),
            expansionName = entry.expansionName,
        }
    end
    return copied
end

local function BuildAggregatedItems(itemLoots)
    local byLink = {}
    for _, entry in ipairs(itemLoots or {}) do
        local key = entry.itemLink or "unknown"
        local item = byLink[key]
        if not item then
            item = {
                itemLink = entry.itemLink,
                quantity = 0,
                totalValue = 0,
            }
            byLink[key] = item
        end

        item.quantity = item.quantity + (tonumber(entry.quantity) or 0)
        item.totalValue = item.totalValue + (tonumber(entry.totalValue) or 0)
        if item.itemQuality == nil then
            item.itemQuality = tonumber(entry.itemQuality)
        end
    end

    local aggregated = {}
    for _, item in pairs(byLink) do
        aggregated[#aggregated + 1] = item
    end

    table.sort(aggregated, function(a, b)
        return (a.totalValue or 0) > (b.totalValue or 0)
    end)

    return aggregated
end

local function AddUniqueText(target, seen, value)
    if type(value) ~= "string" then
        return
    end
    local trimmed = GoldTracker:Trim(value)
    if trimmed == "" or seen[trimmed] then
        return
    end
    seen[trimmed] = true
    target[#target + 1] = trimmed
end

local function CollectSessionValueSourceLabels(itemLoots, defaultLabel)
    local labels = {}
    local seen = {}
    for _, entry in ipairs(itemLoots or {}) do
        AddUniqueText(labels, seen, entry and entry.valueSourceLabel)
    end
    AddUniqueText(labels, seen, defaultLabel)
    if #labels == 0 then
        labels[1] = "Unknown"
    end
    return labels
end

local function GetSessionPrimarySourceLabel(session)
    if type(session.valueSourceLabel) == "string" and session.valueSourceLabel ~= "" then
        return session.valueSourceLabel
    end
    if type(session.valueSourceLabels) == "table" and #session.valueSourceLabels > 0 then
        return tostring(session.valueSourceLabels[1])
    end
    return "Unknown"
end

local function BuildSessionFallbackLocationKey(entry)
    if type(entry.locationKey) == "string" and entry.locationKey ~= "" then
        return entry.locationKey
    end
    if entry.isInstanced == true then
        return string.format("instance:%s:%s", tostring(entry.instanceMapID or 0), tostring(entry.instanceName or ""))
    end
    return string.format("zone:%s:%s", tostring(entry.zoneName or ""), tostring(entry.mapID or 0))
end

local function BuildSessionFallbackLocationLabel(entry)
    local label
    if entry.isInstanced == true then
        label = entry.instanceName or entry.zoneName or entry.mapName
    else
        label = entry.zoneName or entry.mapName
    end
    if type(label) ~= "string" or label == "" then
        label = "Unknown"
    end

    if type(entry.expansionName) == "string" and entry.expansionName ~= "" then
        label = string.format("%s (%s)", label, entry.expansionName)
    end

    return label
end

local function NormalizeLootLocationFields(target, fallbackKey, fallbackLabel, fallbackContext)
    if type(target) ~= "table" then
        return
    end

    if type(target.locationKey) ~= "string" or target.locationKey == "" then
        target.locationKey = fallbackKey
    end
    if type(target.locationLabel) ~= "string" or target.locationLabel == "" then
        target.locationLabel = fallbackLabel
    end

    if target.isInstanced == nil and type(fallbackContext) == "table" then
        target.isInstanced = fallbackContext.isInstanced == true
    else
        target.isInstanced = target.isInstanced == true
    end

    if type(target.instanceName) ~= "string" or target.instanceName == "" then
        target.instanceName = fallbackContext and fallbackContext.instanceName or nil
    end
    if type(target.zoneName) ~= "string" or target.zoneName == "" then
        target.zoneName = fallbackContext and fallbackContext.zoneName or nil
    end
    if target.mapID == nil then
        target.mapID = fallbackContext and fallbackContext.mapID or nil
    end
    target.mapID = tonumber(target.mapID)

    if type(target.mapName) ~= "string" or target.mapName == "" then
        target.mapName = fallbackContext and fallbackContext.mapName or nil
    end
    if type(target.mapPath) ~= "string" or target.mapPath == "" then
        target.mapPath = fallbackContext and fallbackContext.mapPath or nil
    end
    if type(target.continentName) ~= "string" or target.continentName == "" then
        target.continentName = fallbackContext and fallbackContext.continentName or nil
    end
    if target.expansionID == nil then
        target.expansionID = fallbackContext and fallbackContext.expansionID or nil
    end
    target.expansionID = tonumber(target.expansionID)
    if type(target.expansionName) ~= "string" or target.expansionName == "" then
        target.expansionName = fallbackContext and fallbackContext.expansionName or nil
    end
end

local function NormalizeHistoryEntry(entry)
    if type(entry) ~= "table" then
        return
    end

    if type(entry.pinned) ~= "boolean" then
        entry.pinned = false
    end

    if type(entry.valueSourceLabel) ~= "string" or entry.valueSourceLabel == "" then
        entry.valueSourceLabel = "Unknown"
    end

    if type(entry.valueSourceLabels) ~= "table" or #entry.valueSourceLabels == 0 then
        entry.valueSourceLabels = { entry.valueSourceLabel }
    end

    if type(entry.itemLoots) ~= "table" then
        entry.itemLoots = {}
    end
    if type(entry.moneyLoots) ~= "table" then
        entry.moneyLoots = {}
    end

    local fallbackSourceID = entry.valueSourceID
    local fallbackSourceLabel = GetSessionPrimarySourceLabel(entry)
    local fallbackLocationKey = BuildSessionFallbackLocationKey(entry)
    local fallbackLocationLabel = BuildSessionFallbackLocationLabel(entry)
    local fallbackLocationContext = {
        isInstanced = entry.isInstanced == true,
        instanceName = entry.instanceName,
        zoneName = entry.zoneName,
        mapID = entry.mapID,
        mapName = entry.mapName,
        mapPath = entry.mapPath,
        continentName = entry.continentName,
        expansionID = entry.expansionID,
        expansionName = entry.expansionName,
    }
    for _, loot in ipairs(entry.itemLoots) do
        if loot.itemQuality ~= nil then
            loot.itemQuality = tonumber(loot.itemQuality)
        end
        if loot.itemQuality == nil and loot.itemLink then
            loot.itemQuality = GoldTracker:GetItemQualityFromLink(loot.itemLink)
        end
        if loot.ahTracked == nil then
            -- Older sessions only stored AH-tracked items; treat them as tracked.
            loot.ahTracked = true
        else
            loot.ahTracked = loot.ahTracked == true
        end
        if type(loot.lootSourceType) ~= "string" or loot.lootSourceType == "" then
            loot.lootSourceType = nil
        end
        if type(loot.lootSourceName) ~= "string" or loot.lootSourceName == "" then
            loot.lootSourceName = nil
        end
        if loot.isCraftingReagent == nil and type(loot.itemLink) == "string" then
            loot.isCraftingReagent = GoldTracker:IsCraftingReagentItem(loot.itemLink)
        else
            loot.isCraftingReagent = loot.isCraftingReagent == true
        end
        loot.lootSourceIsAoe = loot.lootSourceIsAoe == true
        if type(loot.lootSourceText) ~= "string" or loot.lootSourceText == "" then
            if loot.lootSourceType == "AOE" or loot.lootSourceIsAoe == true then
                loot.lootSourceText = "AOE loot"
            else
                loot.lootSourceText = nil
            end
        end
        if type(loot.valueSourceLabel) ~= "string" or loot.valueSourceLabel == "" then
            loot.valueSourceLabel = fallbackSourceLabel
        end
        if loot.valueSourceID == nil then
            loot.valueSourceID = fallbackSourceID
        end
        NormalizeLootLocationFields(loot, fallbackLocationKey, fallbackLocationLabel, fallbackLocationContext)
    end

    for _, money in ipairs(entry.moneyLoots) do
        money.amount = tonumber(money.amount) or 0
        money.timestamp = tonumber(money.timestamp) or 0
        NormalizeLootLocationFields(money, fallbackLocationKey, fallbackLocationLabel, fallbackLocationContext)
    end

    local highlightCount = tonumber(entry.highlightItemCount)
    if not highlightCount then
        highlightCount = (tonumber(entry.lowHighlightItemCount) or 0) + (tonumber(entry.highHighlightItemCount) or 0)
    end
    entry.highlightItemCount = math.max(0, math.floor(highlightCount + 0.5))
    entry.lowHighlightItemCount = 0
    entry.highHighlightItemCount = entry.highlightItemCount

    entry.rawGold = tonumber(entry.rawGold) or 0
    entry.itemsValue = tonumber(entry.itemsValue) or 0
    entry.itemsRawGold = tonumber(entry.itemsRawGold) or 0
    entry.totalValue = entry.rawGold + entry.itemsValue

    if type(entry.items) ~= "table" or #entry.items == 0 then
        entry.items = BuildAggregatedItems(entry.itemLoots)
    else
        for _, item in ipairs(entry.items) do
            if item.itemQuality ~= nil then
                item.itemQuality = tonumber(item.itemQuality)
            end
            if item.itemQuality == nil and item.itemLink then
                item.itemQuality = GoldTracker:GetItemQualityFromLink(item.itemLink)
            end
        end
    end
end

function GoldTracker:IsSessionHistoryEnabled()
    return self.db and self.db.enableSessionHistory == true
end

function GoldTracker:GetSessionHistory()
    if not self.db then
        return {}
    end
    if type(self.db.sessionHistory) ~= "table" then
        self.db.sessionHistory = {}
    end

    for _, entry in ipairs(self.db.sessionHistory) do
        NormalizeHistoryEntry(entry)
    end

    return self.db.sessionHistory
end

function GoldTracker:GetSortedSessionHistory()
    local history = self:GetSessionHistory()
    local ordered = {}
    for i, session in ipairs(history) do
        ordered[i] = session
    end

    table.sort(ordered, function(a, b)
        local aPinned = a and a.pinned == true
        local bPinned = b and b.pinned == true
        if aPinned ~= bPinned then
            return aPinned and not bPinned
        end

        local aSaved = tonumber(a and (a.savedAt or a.stopTime)) or 0
        local bSaved = tonumber(b and (b.savedAt or b.stopTime)) or 0
        if aSaved ~= bSaved then
            return aSaved > bSaved
        end

        return (tonumber(a and a.id) or 0) > (tonumber(b and b.id) or 0)
    end)

    return ordered
end

local function ResolveExpansionName(expansionID)
    local normalizedID = tonumber(expansionID)
    if not normalizedID then
        return nil
    end

    local directName = _G["EXPANSION_NAME" .. normalizedID]
    if type(directName) == "string" and directName ~= "" then
        return directName
    end

    local plusOneName = _G["EXPANSION_NAME" .. (normalizedID + 1)]
    if type(plusOneName) == "string" and plusOneName ~= "" then
        return plusOneName
    end

    return nil
end

function GoldTracker:GetMapLocationDetails(mapID)
    local details = {
        mapID = nil,
        mapName = nil,
        mapPath = nil,
        continentName = nil,
        expansionID = nil,
        expansionName = nil,
    }

    local currentMapID = tonumber(mapID)
    if not currentMapID or currentMapID <= 0 then
        return details
    end
    if type(C_Map) ~= "table" or type(C_Map.GetMapInfo) ~= "function" then
        return details
    end

    details.mapID = currentMapID

    local hierarchy = {}
    local visited = {}
    local depth = 0
    while currentMapID and currentMapID > 0 and not visited[currentMapID] and depth < 15 do
        depth = depth + 1
        visited[currentMapID] = true

        local mapInfo = C_Map.GetMapInfo(currentMapID)
        if not mapInfo then
            break
        end

        if not details.expansionID then
            local mapExpansionID = tonumber(mapInfo.expansionID)
            if mapExpansionID then
                details.expansionID = mapExpansionID
            end
        end

        local mapName = mapInfo.name
        if type(mapName) == "string" and mapName ~= "" then
            if not details.mapName then
                details.mapName = mapName
            end
            table.insert(hierarchy, 1, mapName)
        end

        local parentMapID = tonumber(mapInfo.parentMapID) or 0
        if parentMapID <= 0 then
            break
        end
        currentMapID = parentMapID
    end

    if #hierarchy > 0 then
        details.mapPath = table.concat(hierarchy, " > ")
        details.continentName = hierarchy[1]
    end

    details.expansionName = ResolveExpansionName(details.expansionID)

    return details
end

function GoldTracker:GetCurrentLocationSnapshot()
    local snapshot = {
        isInstanced = false,
        instanceName = nil,
        instanceMapID = nil,
        instanceType = nil,
        zoneName = nil,
        locationKey = nil,
        mapID = nil,
        mapName = nil,
        mapPath = nil,
        continentName = nil,
        expansionID = nil,
        expansionName = nil,
    }

    local zoneName = GetRealZoneText()
    if type(zoneName) == "string" and zoneName ~= "" then
        snapshot.zoneName = zoneName
    end

    local playerMapID
    if type(C_Map) == "table" and type(C_Map.GetBestMapForUnit) == "function" then
        playerMapID = C_Map.GetBestMapForUnit("player")
    end

    local inInstance, instanceType = IsInInstance()
    if inInstance then
        local instanceName, currentInstanceType, _, _, _, _, _, mapID = GetInstanceInfo()
        snapshot.isInstanced = true
        snapshot.instanceType = currentInstanceType or instanceType
        if type(instanceName) == "string" and instanceName ~= "" then
            snapshot.instanceName = instanceName
        end
        if type(mapID) == "number" and mapID > 0 then
            snapshot.instanceMapID = mapID
        end

        local effectiveMapID = snapshot.instanceMapID or playerMapID
        local locationDetails = self:GetMapLocationDetails(effectiveMapID)
        snapshot.mapID = locationDetails.mapID
        snapshot.mapName = locationDetails.mapName
        snapshot.mapPath = locationDetails.mapPath
        snapshot.continentName = locationDetails.continentName
        snapshot.expansionID = locationDetails.expansionID
        snapshot.expansionName = locationDetails.expansionName
        if (type(snapshot.zoneName) ~= "string" or snapshot.zoneName == "") and type(locationDetails.mapName) == "string" then
            snapshot.zoneName = locationDetails.mapName
        end

        snapshot.locationKey = string.format(
            "instance:%s:%s",
            tostring(snapshot.instanceMapID or 0),
            tostring(snapshot.instanceName or "")
        )
    else
        local locationDetails = self:GetMapLocationDetails(playerMapID)
        snapshot.mapID = locationDetails.mapID
        snapshot.mapName = locationDetails.mapName
        snapshot.mapPath = locationDetails.mapPath
        snapshot.continentName = locationDetails.continentName
        snapshot.expansionID = locationDetails.expansionID
        snapshot.expansionName = locationDetails.expansionName
        if (type(snapshot.zoneName) ~= "string" or snapshot.zoneName == "") and type(locationDetails.mapName) == "string" then
            snapshot.zoneName = locationDetails.mapName
        end

        snapshot.locationKey = string.format(
            "zone:%s:%s",
            tostring(snapshot.zoneName or ""),
            tostring(snapshot.mapID or 0)
        )
    end

    return snapshot
end

function GoldTracker:UpdateSessionLocationContext()
    if not self.session then
        return
    end

    local snapshot = self:GetCurrentLocationSnapshot()
    self.session.isInstanced = snapshot.isInstanced == true
    self.session.instanceName = snapshot.instanceName
    self.session.instanceMapID = snapshot.instanceMapID
    self.session.instanceType = snapshot.instanceType
    self.session.zoneName = snapshot.zoneName
    self.session.locationKey = snapshot.locationKey
    self.session.mapID = snapshot.mapID
    self.session.mapName = snapshot.mapName
    self.session.mapPath = snapshot.mapPath
    self.session.continentName = snapshot.continentName
    self.session.expansionID = snapshot.expansionID
    self.session.expansionName = snapshot.expansionName

    if self.session.isInstanced then
        if type(self.session.zoneName) ~= "string" or self.session.zoneName == "" then
            self.session.zoneName = self.session.instanceName
        end
    end
end

function GoldTracker:BuildHistorySessionName(savedAt, data)
    local timestampText = date("%Y-%m-%d %H:%M:%S", savedAt)
    if data.isInstanced and data.instanceName and data.instanceName ~= "" then
        return string.format("%s - %s", data.instanceName, timestampText)
    end

    if data.zoneName and data.zoneName ~= "" then
        return string.format("%s - %s", data.zoneName, timestampText)
    end

    return string.format("Session - %s", timestampText)
end

function GoldTracker:CreateSessionHistoryEntry(saveReason)
    local stopTime = self.session.stopTime or time()
    local source = self:GetCurrentValueSource()
    local rawGold = tonumber(self.session.goldLooted) or 0
    local itemsValue = tonumber(self.session.itemValue) or 0
    local totalValue = rawGold + itemsValue
    local itemLoots = CloneItemLootEntries(self.session.itemLoots, source.id, source.label)
    local moneyLoots = CloneMoneyLootEntries(self.session.moneyLoots)
    local sourceLabels = CollectSessionValueSourceLabels(itemLoots, source.label)
    local highlightItemCount = tonumber(self.session.highlightItemCount)
    if not highlightItemCount then
        highlightItemCount = (tonumber(self.session.lowHighlightItemCount) or 0) + (tonumber(self.session.highHighlightItemCount) or 0)
    end

    local entry = {
        id = self.db.nextHistoryID,
        saveReason = saveReason or "stop",
        savedAt = stopTime,
        startTime = tonumber(self.session.startTime) or stopTime,
        stopTime = stopTime,
        duration = math.max(0, stopTime - (tonumber(self.session.startTime) or stopTime)),
        activeDuration = math.max(0, math.floor((tonumber(self.session.activeDurationSeconds) or 0) + 0.5)),
        rawGold = rawGold,
        itemsValue = itemsValue,
        itemsRawGold = tonumber(self.session.itemVendorValue) or 0,
        totalValue = totalValue,
        highlightItemCount = tonumber(highlightItemCount) or 0,
        lowHighlightItemCount = 0,
        highHighlightItemCount = tonumber(highlightItemCount) or 0,
        valueSourceID = source.id,
        valueSourceLabel = table.concat(sourceLabels, ", "),
        valueSourceLabels = sourceLabels,
        isInstanced = self.session.isInstanced == true,
        instanceName = self.session.instanceName,
        instanceMapID = self.session.instanceMapID,
        instanceType = self.session.instanceType,
        zoneName = self.session.zoneName,
        locationKey = self.session.locationKey,
        locationLabel = BuildSessionFallbackLocationLabel(self.session),
        mapID = self.session.mapID,
        mapName = self.session.mapName,
        mapPath = self.session.mapPath,
        continentName = self.session.continentName,
        expansionID = self.session.expansionID,
        expansionName = self.session.expansionName,
        itemLoots = itemLoots,
        moneyLoots = moneyLoots,
        items = BuildAggregatedItems(itemLoots),
        pinned = false,
    }

    entry.name = self:BuildHistorySessionName(stopTime, entry)
    self.db.nextHistoryID = self.db.nextHistoryID + 1

    return entry
end

function GoldTracker:SaveCurrentSessionToHistory(saveReason)
    if not self:IsSessionHistoryEnabled() then
        return false
    end

    if not self.session or not self.session.startTime then
        return false
    end

    local rawGold = tonumber(self.session.goldLooted) or 0
    local ahValue = tonumber(self.session.itemValue) or 0
    local vendorItemsValue = tonumber(self.session.itemVendorValue) or 0
    local sessionTotal = rawGold + ahValue
    local sessionTotalRaw = rawGold + vendorItemsValue
    if sessionTotal <= 0 and sessionTotalRaw <= 0 then
        return false
    end

    local history = self:GetSessionHistory()
    local entry = self:CreateSessionHistoryEntry(saveReason)
    table.insert(history, 1, entry)

    while #history > MAX_HISTORY_SESSIONS do
        table.remove(history)
    end

    if self.RefreshHistoryWindow then
        self:RefreshHistoryWindow()
    end
    if self.RefreshHistoryDetailsWindow then
        self:RefreshHistoryDetailsWindow()
    end

    return true
end

function GoldTracker:ResumeHistorySession(sessionID)
    if not self:IsResumeHistorySessionEnabled() then
        self:Print("Resuming from history is disabled in options.")
        return false
    end

    local historySession = self:GetHistorySessionByID(sessionID)
    if not historySession then
        return false
    end

    local session = self.session or {}
    self.session = session
    local wasActive = session.active == true

    local mergedItemLoots = CloneItemLootEntries(
        historySession.itemLoots,
        historySession.valueSourceID,
        historySession.valueSourceLabel
    )
    local mergedMoneyLoots = CloneMoneyLootEntries(historySession.moneyLoots)

    if not wasActive then
        session.active = true
        session.startTime = tonumber(historySession.startTime) or time()
        session.stopTime = nil
        session.goldLooted = tonumber(historySession.rawGold) or 0
        session.itemValue = tonumber(historySession.itemsValue) or 0
        session.itemVendorValue = tonumber(historySession.itemsRawGold) or 0
        session.highlightItemCount = tonumber(historySession.highlightItemCount) or 0
        session.lowHighlightItemCount = 0
        session.highHighlightItemCount = session.highlightItemCount
        session.itemLoots = mergedItemLoots
        session.moneyLoots = mergedMoneyLoots
        session.isInstanced = historySession.isInstanced == true
        session.instanceName = historySession.instanceName
        session.instanceMapID = historySession.instanceMapID
        session.instanceType = historySession.instanceType
        session.zoneName = historySession.zoneName
        session.locationKey = historySession.locationKey
        session.mapID = historySession.mapID
        session.mapName = historySession.mapName
        session.mapPath = historySession.mapPath
        session.continentName = historySession.continentName
        session.expansionID = historySession.expansionID
        session.expansionName = historySession.expansionName
        session.activeDurationSeconds = math.max(0, math.floor((tonumber(historySession.activeDuration) or tonumber(historySession.duration) or 0) + 0.5))
    else
        session.startTime = math.min(tonumber(session.startTime) or time(), tonumber(historySession.startTime) or time())
        session.stopTime = nil
        session.goldLooted = (tonumber(session.goldLooted) or 0) + (tonumber(historySession.rawGold) or 0)
        session.itemValue = (tonumber(session.itemValue) or 0) + (tonumber(historySession.itemsValue) or 0)
        session.itemVendorValue = (tonumber(session.itemVendorValue) or 0) + (tonumber(historySession.itemsRawGold) or 0)
        session.highlightItemCount = (tonumber(session.highlightItemCount) or 0) + (tonumber(historySession.highlightItemCount) or 0)
        session.lowHighlightItemCount = 0
        session.highHighlightItemCount = session.highlightItemCount

        if type(session.itemLoots) ~= "table" then
            session.itemLoots = {}
        end
        if type(session.moneyLoots) ~= "table" then
            session.moneyLoots = {}
        end
        for _, loot in ipairs(mergedItemLoots) do
            session.itemLoots[#session.itemLoots + 1] = loot
        end
        for _, money in ipairs(mergedMoneyLoots) do
            session.moneyLoots[#session.moneyLoots + 1] = money
        end
        session.activeDurationSeconds = (tonumber(session.activeDurationSeconds) or 0)
            + math.max(0, math.floor((tonumber(historySession.activeDuration) or tonumber(historySession.duration) or 0) + 0.5))
    end

    if type(self.GetMostRecentSessionLootTimestamp) == "function" then
        session.lastLootAt = self:GetMostRecentSessionLootTimestamp(session)
    else
        session.lastLootAt = time()
    end

    if type(self.EnsureAlertRuntimeState) == "function" then
        local runtime = self:EnsureAlertRuntimeState()
        runtime.sessionStartTime = tonumber(session.startTime) or 0
        runtime.milestoneTriggeredByRule = {}
        runtime.noLootTriggered = false
    end

    self.tsmWarningShown = false
    self:UpdateSessionLocationContext()
    self:AddLogMessage(
        string.format("%s  Resumed history session: %s", date("%H:%M:%S"), historySession.name or tostring(historySession.id)),
        0.35,
        1,
        0.7
    )
    self:UpdateMainWindow()

    if wasActive then
        self:Print("Merged selected history session into the active session.")
    else
        self:Print("Loaded selected history session as the active session.")
    end

    return true
end

function GoldTracker:GetHistorySessionByID(sessionID)
    for _, session in ipairs(self:GetSessionHistory()) do
        if session.id == sessionID then
            return session
        end
    end
    return nil
end

function GoldTracker:DeleteHistorySession(sessionID)
    local history = self:GetSessionHistory()
    for index, session in ipairs(history) do
        if session.id == sessionID then
            table.remove(history, index)
            if self.historyFrame
                and self.historyFrame.view == "details"
                and self.historyFrame.selectedSessionID == sessionID
                and self.ShowHistoryListView then
                self:ShowHistoryListView()
            end
            if self.RefreshHistoryWindow then
                self:RefreshHistoryWindow()
            end
            if self.RefreshHistoryDetailsWindow then
                self:RefreshHistoryDetailsWindow()
            end
            return true
        end
    end
    return false
end

function GoldTracker:DeleteHistorySessions(sessionIDs)
    if type(sessionIDs) ~= "table" or #sessionIDs == 0 then
        return 0
    end

    local remove = {}
    for _, sessionID in ipairs(sessionIDs) do
        local normalizedID = tonumber(sessionID)
        if normalizedID then
            remove[normalizedID] = true
        end
    end

    if next(remove) == nil then
        return 0
    end

    local history = self:GetSessionHistory()
    local kept = {}
    local removedCount = 0
    for _, session in ipairs(history) do
        if remove[session.id] then
            removedCount = removedCount + 1
        else
            kept[#kept + 1] = session
        end
    end

    if removedCount == 0 then
        return 0
    end

    self.db.sessionHistory = kept

    if self.historyFrame
        and self.historyFrame.view == "details"
        and remove[self.historyFrame.selectedSessionID]
        and self.ShowHistoryListView then
        self:ShowHistoryListView()
    end
    if self.RefreshHistoryWindow then
        self:RefreshHistoryWindow()
    end
    if self.RefreshHistoryDetailsWindow then
        self:RefreshHistoryDetailsWindow()
    end

    return removedCount
end

function GoldTracker:ToggleHistorySessionPinned(sessionID)
    local session = self:GetHistorySessionByID(sessionID)
    if not session then
        return nil
    end

    session.pinned = session.pinned ~= true

    if self.RefreshHistoryWindow then
        self:RefreshHistoryWindow()
    end
    if self.RefreshHistoryDetailsWindow then
        self:RefreshHistoryDetailsWindow()
    end

    return session.pinned
end

function GoldTracker:MergeHistorySessions(sessionIDs)
    if type(sessionIDs) ~= "table" or #sessionIDs < 2 then
        return nil
    end

    local sessions = {}
    local added = {}
    for _, sessionID in ipairs(sessionIDs) do
        local normalizedID = tonumber(sessionID)
        if normalizedID and not added[normalizedID] then
            local session = self:GetHistorySessionByID(normalizedID)
            if session then
                sessions[#sessions + 1] = session
                added[normalizedID] = true
            end
        end
    end

    if #sessions < 2 then
        return nil
    end

    local firstSession = sessions[1]
    local mergedLoots = {}
    local mergedMoneyLoots = {}
    local sourceLabels = {}
    local sourceSeen = {}
    local rawGold = 0
    local itemsValue = 0
    local itemsRawGold = 0
    local highlightItemCount = 0
    local startTime
    local stopTime

    for _, session in ipairs(sessions) do
        local sessionSourceID = session.valueSourceID
        local sessionSourceLabel = GetSessionPrimarySourceLabel(session)
        local fallbackTimestamp = tonumber(session.stopTime or session.savedAt or time()) or time()

        if type(session.valueSourceLabels) == "table" and #session.valueSourceLabels > 0 then
            for _, sourceLabel in ipairs(session.valueSourceLabels) do
                AddUniqueText(sourceLabels, sourceSeen, sourceLabel)
            end
        else
            AddUniqueText(sourceLabels, sourceSeen, sessionSourceLabel)
        end

        rawGold = rawGold + (tonumber(session.rawGold) or 0)
        itemsValue = itemsValue + (tonumber(session.itemsValue) or 0)
        itemsRawGold = itemsRawGold + (tonumber(session.itemsRawGold) or 0)

        local sessionHighlightCount = tonumber(session.highlightItemCount)
        if not sessionHighlightCount then
            sessionHighlightCount = (tonumber(session.lowHighlightItemCount) or 0) + (tonumber(session.highHighlightItemCount) or 0)
        end
        highlightItemCount = highlightItemCount + (tonumber(sessionHighlightCount) or 0)

        local sessionStart = tonumber(session.startTime)
        local sessionStop = tonumber(session.stopTime or session.savedAt)
        if sessionStart and (not startTime or sessionStart < startTime) then
            startTime = sessionStart
        end
        if sessionStop and (not stopTime or sessionStop > stopTime) then
            stopTime = sessionStop
        end

        if type(session.moneyLoots) == "table" and #session.moneyLoots > 0 then
            local copiedMoneyLoots = CloneMoneyLootEntries(session.moneyLoots)
            for _, money in ipairs(copiedMoneyLoots) do
                mergedMoneyLoots[#mergedMoneyLoots + 1] = money
            end
        elseif (tonumber(session.rawGold) or 0) > 0 then
            mergedMoneyLoots[#mergedMoneyLoots + 1] = {
                amount = tonumber(session.rawGold) or 0,
                timestamp = fallbackTimestamp,
                locationKey = session.locationKey,
                locationLabel = BuildSessionFallbackLocationLabel(session),
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

        if type(session.itemLoots) == "table" and #session.itemLoots > 0 then
            local copiedLoots = CloneItemLootEntries(session.itemLoots, sessionSourceID, sessionSourceLabel)
            for _, loot in ipairs(copiedLoots) do
                mergedLoots[#mergedLoots + 1] = loot
            end
        else
            for _, item in ipairs(session.items or {}) do
                local quantity = math.max(0, tonumber(item.quantity) or 0)
                local totalItemValue = math.max(0, tonumber(item.totalValue) or 0)
                local unitValue = 0
                if quantity > 0 then
                    unitValue = math.floor((totalItemValue / quantity) + 0.5)
                end
                mergedLoots[#mergedLoots + 1] = {
                    itemLink = item.itemLink,
                    quantity = quantity,
                    unitValue = unitValue,
                    totalValue = totalItemValue,
                    vendorUnitValue = 0,
                    vendorTotalValue = 0,
                    itemQuality = tonumber(item.itemQuality) or self:GetItemQualityFromLink(item.itemLink),
                    isSoulbound = item.isSoulbound == true,
                    timestamp = fallbackTimestamp,
                    valueSourceID = sessionSourceID,
                    valueSourceLabel = sessionSourceLabel,
                    locationKey = session.locationKey,
                    locationLabel = BuildSessionFallbackLocationLabel(session),
                    isInstanced = session.isInstanced == true,
                    instanceName = session.instanceName,
                    zoneName = session.zoneName,
                    mapID = session.mapID,
                    mapName = session.mapName,
                    mapPath = session.mapPath,
                    continentName = session.continentName,
                    expansionID = session.expansionID,
                    expansionName = session.expansionName,
                    ahTracked = true,
                }
            end
        end
    end

    if #sourceLabels == 0 then
        sourceLabels[1] = "Unknown"
    end

    if not stopTime then
        stopTime = time()
    end
    if not startTime then
        startTime = stopTime
    end
    if stopTime < startTime then
        stopTime = startTime
    end

    table.sort(mergedLoots, function(a, b)
        return (tonumber(a and a.timestamp) or 0) < (tonumber(b and b.timestamp) or 0)
    end)
    table.sort(mergedMoneyLoots, function(a, b)
        return (tonumber(a and a.timestamp) or 0) < (tonumber(b and b.timestamp) or 0)
    end)

    local mergedFromIDs = {}
    for _, session in ipairs(sessions) do
        mergedFromIDs[#mergedFromIDs + 1] = session.id
    end

    local mergedName = firstSession.name or self:BuildHistorySessionName(stopTime, firstSession)
    local mergedEntry = {
        id = self.db.nextHistoryID,
        saveReason = "merge",
        savedAt = stopTime,
        startTime = startTime,
        stopTime = stopTime,
        duration = math.max(0, stopTime - startTime),
        rawGold = rawGold,
        itemsValue = itemsValue,
        itemsRawGold = itemsRawGold,
        totalValue = rawGold + itemsValue,
        highlightItemCount = highlightItemCount,
        lowHighlightItemCount = 0,
        highHighlightItemCount = highlightItemCount,
        valueSourceID = (#sourceLabels == 1 and sessions[1].valueSourceID) or "MERGED",
        valueSourceLabel = table.concat(sourceLabels, ", "),
        valueSourceLabels = sourceLabels,
        isInstanced = firstSession.isInstanced == true,
        instanceName = firstSession.instanceName,
        instanceMapID = firstSession.instanceMapID,
        instanceType = firstSession.instanceType,
        zoneName = firstSession.zoneName,
        mapID = firstSession.mapID,
        mapName = firstSession.mapName,
        mapPath = firstSession.mapPath,
        continentName = firstSession.continentName,
        expansionID = firstSession.expansionID,
        expansionName = firstSession.expansionName,
        itemLoots = mergedLoots,
        moneyLoots = mergedMoneyLoots,
        items = BuildAggregatedItems(mergedLoots),
        pinned = false,
        name = mergedName,
        mergedFromSessionIDs = mergedFromIDs,
    }

    self.db.nextHistoryID = self.db.nextHistoryID + 1

    local mergedSourceIDs = {}
    for _, sourceSessionID in ipairs(mergedFromIDs) do
        mergedSourceIDs[sourceSessionID] = true
    end

    local history = self:GetSessionHistory()
    local updatedHistory = { mergedEntry }
    for _, existingEntry in ipairs(history) do
        if not mergedSourceIDs[existingEntry.id] then
            updatedHistory[#updatedHistory + 1] = existingEntry
        end
    end

    while #updatedHistory > MAX_HISTORY_SESSIONS do
        table.remove(updatedHistory)
    end
    self.db.sessionHistory = updatedHistory

    if self.RefreshHistoryWindow then
        self:RefreshHistoryWindow()
    end
    if self.RefreshHistoryDetailsWindow then
        self:RefreshHistoryDetailsWindow()
    end

    return mergedEntry
end

local function BuildLootEntryLocationKey(entry, fallbackSession)
    if type(entry) == "table" and type(entry.locationKey) == "string" and entry.locationKey ~= "" then
        return entry.locationKey
    end
    if type(fallbackSession) == "table" then
        return BuildSessionFallbackLocationKey(fallbackSession)
    end
    return "unknown"
end

local function BuildLootEntryLocationLabel(entry, fallbackSession)
    if type(entry) == "table" and type(entry.locationLabel) == "string" and entry.locationLabel ~= "" then
        return entry.locationLabel
    end
    if type(fallbackSession) == "table" then
        return BuildSessionFallbackLocationLabel(fallbackSession)
    end
    return "Unknown"
end

local function CountHighlightedLootEntries(addon, itemLoots)
    local threshold = addon:GetHighlightThreshold()
    local count = 0
    for _, entry in ipairs(itemLoots or {}) do
        local totalValue = tonumber(entry and entry.totalValue) or 0
        if totalValue > 0 and (threshold <= 0 or totalValue >= threshold) then
            count = count + 1
        end
    end
    return count
end

local function GetPrimaryValueSourceID(itemLoots, fallbackSourceID)
    for _, entry in ipairs(itemLoots or {}) do
        if entry and entry.valueSourceID ~= nil and entry.valueSourceID ~= "" then
            return entry.valueSourceID
        end
    end
    return fallbackSourceID
end

local function CloneNumberList(values)
    local copied = {}
    if type(values) ~= "table" then
        return copied
    end

    for _, value in ipairs(values) do
        local normalized = tonumber(value)
        if normalized then
            copied[#copied + 1] = normalized
        end
    end

    return copied
end

local function FormatSessionTimeFrame(startTime, stopTime)
    local normalizedStart = tonumber(startTime) or 0
    local normalizedStop = tonumber(stopTime) or 0

    if normalizedStart <= 0 and normalizedStop <= 0 then
        return "Unknown time"
    end
    if normalizedStart <= 0 then
        normalizedStart = normalizedStop
    end
    if normalizedStop <= 0 then
        normalizedStop = normalizedStart
    end
    if normalizedStop < normalizedStart then
        normalizedStop = normalizedStart
    end

    if normalizedStart == normalizedStop then
        return date("%Y-%m-%d %H:%M:%S", normalizedStart)
    end

    return string.format(
        "%s -> %s",
        date("%Y-%m-%d %H:%M:%S", normalizedStart),
        date("%Y-%m-%d %H:%M:%S", normalizedStop)
    )
end

local function BuildSplitSessionName(locationLabel, startTime, stopTime)
    local normalizedLabel = GoldTracker:Trim(type(locationLabel) == "string" and locationLabel or "")
    if normalizedLabel == "" then
        normalizedLabel = "Session"
    end

    return string.format("%s - %s", normalizedLabel, FormatSessionTimeFrame(startTime, stopTime))
end

function GoldTracker:SplitHistorySessionByLocation(sessionID)
    local session = self:GetHistorySessionByID(sessionID)
    if not session then
        return nil, "not-found"
    end

    local fallbackLocationKey = BuildSessionFallbackLocationKey(session)
    local fallbackLocationLabel = BuildSessionFallbackLocationLabel(session)
    local fallbackSourceLabel = GetSessionPrimarySourceLabel(session)
    local fallbackTimestamp = tonumber(session.stopTime or session.savedAt or time()) or time()
    local sessionSavedAt = tonumber(session.savedAt or session.stopTime or fallbackTimestamp) or fallbackTimestamp

    local bucketsByKey = {}
    local bucketOrder = {}

    local function GetOrCreateBucket(locationKey, locationLabel, sourceEntry, timestamp)
        local key = locationKey
        if type(key) ~= "string" or key == "" then
            key = fallbackLocationKey
        end

        local label = locationLabel
        if type(label) ~= "string" or label == "" then
            label = fallbackLocationLabel
        end

        local bucket = bucketsByKey[key]
        if not bucket then
            bucket = {
                locationKey = key,
                locationLabel = label,
                itemLoots = {},
                moneyLoots = {},
                firstTimestamp = 0,
                lastTimestamp = 0,
                isInstanced = (sourceEntry and sourceEntry.isInstanced == true) or session.isInstanced == true,
                instanceName = (sourceEntry and sourceEntry.instanceName) or session.instanceName,
                instanceMapID = tonumber((sourceEntry and sourceEntry.instanceMapID) or session.instanceMapID),
                instanceType = (sourceEntry and sourceEntry.instanceType) or session.instanceType,
                zoneName = (sourceEntry and sourceEntry.zoneName) or session.zoneName,
                mapID = tonumber((sourceEntry and sourceEntry.mapID) or session.mapID),
                mapName = (sourceEntry and sourceEntry.mapName) or session.mapName,
                mapPath = (sourceEntry and sourceEntry.mapPath) or session.mapPath,
                continentName = (sourceEntry and sourceEntry.continentName) or session.continentName,
                expansionID = tonumber((sourceEntry and sourceEntry.expansionID) or session.expansionID),
                expansionName = (sourceEntry and sourceEntry.expansionName) or session.expansionName,
            }
            bucketsByKey[key] = bucket
            bucketOrder[#bucketOrder + 1] = bucket
        else
            if (type(bucket.locationLabel) ~= "string" or bucket.locationLabel == "") and type(label) == "string" and label ~= "" then
                bucket.locationLabel = label
            end
            if (type(bucket.zoneName) ~= "string" or bucket.zoneName == "") and type(sourceEntry and sourceEntry.zoneName) == "string" then
                bucket.zoneName = sourceEntry.zoneName
            end
            if (type(bucket.mapName) ~= "string" or bucket.mapName == "") and type(sourceEntry and sourceEntry.mapName) == "string" then
                bucket.mapName = sourceEntry.mapName
            end
            if bucket.mapID == nil and sourceEntry and sourceEntry.mapID ~= nil then
                bucket.mapID = tonumber(sourceEntry.mapID)
            end
            if bucket.expansionID == nil and sourceEntry and sourceEntry.expansionID ~= nil then
                bucket.expansionID = tonumber(sourceEntry.expansionID)
            end
            if (type(bucket.expansionName) ~= "string" or bucket.expansionName == "") and type(sourceEntry and sourceEntry.expansionName) == "string" then
                bucket.expansionName = sourceEntry.expansionName
            end
            if (type(bucket.instanceName) ~= "string" or bucket.instanceName == "") and type(sourceEntry and sourceEntry.instanceName) == "string" then
                bucket.instanceName = sourceEntry.instanceName
            end
            if bucket.isInstanced ~= true and sourceEntry and sourceEntry.isInstanced == true then
                bucket.isInstanced = true
            end
        end

        local normalizedTimestamp = tonumber(timestamp) or 0
        if normalizedTimestamp > 0 then
            if bucket.firstTimestamp <= 0 or normalizedTimestamp < bucket.firstTimestamp then
                bucket.firstTimestamp = normalizedTimestamp
            end
            if normalizedTimestamp > bucket.lastTimestamp then
                bucket.lastTimestamp = normalizedTimestamp
            end
        end

        return bucket
    end

    local clonedMoneyLoots = CloneMoneyLootEntries(session.moneyLoots)
    for _, money in ipairs(clonedMoneyLoots) do
        local bucket = GetOrCreateBucket(
            BuildLootEntryLocationKey(money, session),
            BuildLootEntryLocationLabel(money, session),
            money,
            money.timestamp
        )
        bucket.moneyLoots[#bucket.moneyLoots + 1] = money
    end

    local clonedItemLoots = CloneItemLootEntries(session.itemLoots, session.valueSourceID, fallbackSourceLabel)
    for _, loot in ipairs(clonedItemLoots) do
        local bucket = GetOrCreateBucket(
            BuildLootEntryLocationKey(loot, session),
            BuildLootEntryLocationLabel(loot, session),
            loot,
            loot.timestamp
        )
        bucket.itemLoots[#bucket.itemLoots + 1] = loot
    end

    -- Legacy fallback: if detailed money entries are unavailable, keep raw gold on the session's fallback location.
    if #clonedMoneyLoots == 0 and (tonumber(session.rawGold) or 0) > 0 then
        local bucket = GetOrCreateBucket(fallbackLocationKey, fallbackLocationLabel, session, fallbackTimestamp)
        bucket.moneyLoots[#bucket.moneyLoots + 1] = {
            amount = tonumber(session.rawGold) or 0,
            timestamp = fallbackTimestamp,
            locationKey = fallbackLocationKey,
            locationLabel = fallbackLocationLabel,
            isInstanced = session.isInstanced == true,
            instanceName = session.instanceName,
            zoneName = session.zoneName,
            mapID = tonumber(session.mapID),
            mapName = session.mapName,
            mapPath = session.mapPath,
            continentName = session.continentName,
            expansionID = tonumber(session.expansionID),
            expansionName = session.expansionName,
        }
    end

    -- Legacy fallback: if detailed item entries are unavailable, materialize from aggregated items.
    if #clonedItemLoots == 0 and type(session.items) == "table" and #session.items > 0 then
        local bucket = GetOrCreateBucket(fallbackLocationKey, fallbackLocationLabel, session, fallbackTimestamp)
        for _, item in ipairs(session.items) do
            local quantity = math.max(0, tonumber(item and item.quantity) or 0)
            local totalItemValue = math.max(0, tonumber(item and item.totalValue) or 0)
            local unitValue = 0
            if quantity > 0 then
                unitValue = math.floor((totalItemValue / quantity) + 0.5)
            end

            bucket.itemLoots[#bucket.itemLoots + 1] = {
                itemLink = item and item.itemLink or nil,
                quantity = quantity,
                unitValue = unitValue,
                totalValue = totalItemValue,
                vendorUnitValue = 0,
                vendorTotalValue = 0,
                itemQuality = tonumber(item and item.itemQuality) or self:GetItemQualityFromLink(item and item.itemLink),
                isSoulbound = item and item.isSoulbound == true,
                timestamp = fallbackTimestamp,
                valueSourceID = session.valueSourceID,
                valueSourceLabel = fallbackSourceLabel,
                locationKey = fallbackLocationKey,
                locationLabel = fallbackLocationLabel,
                isInstanced = session.isInstanced == true,
                instanceName = session.instanceName,
                zoneName = session.zoneName,
                mapID = tonumber(session.mapID),
                mapName = session.mapName,
                mapPath = session.mapPath,
                continentName = session.continentName,
                expansionID = tonumber(session.expansionID),
                expansionName = session.expansionName,
                ahTracked = true,
            }
        end
    end

    if #bucketOrder < 2 then
        return nil, "single-location"
    end

    table.sort(bucketOrder, function(a, b)
        local aTs = tonumber(a and a.firstTimestamp) or 0
        local bTs = tonumber(b and b.firstTimestamp) or 0
        if aTs > 0 and bTs > 0 and aTs ~= bTs then
            return aTs < bTs
        end
        return tostring(a and a.locationLabel or "") < tostring(b and b.locationLabel or "")
    end)

    local mergedFromIDs = CloneNumberList(session.mergedFromSessionIDs)
    local splitEntries = {}
    for _, bucket in ipairs(bucketOrder) do
        local rawGold = 0
        for _, money in ipairs(bucket.moneyLoots) do
            rawGold = rawGold + (tonumber(money.amount) or 0)
        end

        local itemsValue = 0
        local itemsRawGold = 0
        for _, loot in ipairs(bucket.itemLoots) do
            itemsValue = itemsValue + (tonumber(loot.totalValue) or 0)
            itemsRawGold = itemsRawGold + (tonumber(loot.vendorTotalValue) or 0)
        end

        local startTime = bucket.firstTimestamp > 0 and bucket.firstTimestamp or (tonumber(session.startTime) or sessionSavedAt)
        local stopTime = bucket.lastTimestamp > 0 and bucket.lastTimestamp or (tonumber(session.stopTime) or startTime)
        if stopTime < startTime then
            stopTime = startTime
        end

        local sourceLabels = CollectSessionValueSourceLabels(bucket.itemLoots, fallbackSourceLabel)
        if #sourceLabels == 0 then
            sourceLabels[1] = "Unknown"
        end
        local valueSourceID = (#sourceLabels == 1 and GetPrimaryValueSourceID(bucket.itemLoots, session.valueSourceID)) or "MERGED"
        local highlightItemCount = CountHighlightedLootEntries(self, bucket.itemLoots)

        local splitEntry = {
            id = self.db.nextHistoryID,
            saveReason = "split",
            savedAt = sessionSavedAt,
            startTime = startTime,
            stopTime = stopTime,
            duration = math.max(0, stopTime - startTime),
            rawGold = rawGold,
            itemsValue = itemsValue,
            itemsRawGold = itemsRawGold,
            totalValue = rawGold + itemsValue,
            highlightItemCount = highlightItemCount,
            lowHighlightItemCount = 0,
            highHighlightItemCount = highlightItemCount,
            valueSourceID = valueSourceID,
            valueSourceLabel = table.concat(sourceLabels, ", "),
            valueSourceLabels = sourceLabels,
            isInstanced = bucket.isInstanced == true,
            instanceName = bucket.instanceName,
            instanceMapID = bucket.instanceMapID,
            instanceType = bucket.instanceType,
            zoneName = bucket.zoneName,
            mapID = bucket.mapID,
            mapName = bucket.mapName,
            mapPath = bucket.mapPath,
            continentName = bucket.continentName,
            expansionID = bucket.expansionID,
            expansionName = bucket.expansionName,
            locationKey = bucket.locationKey,
            locationLabel = bucket.locationLabel,
            itemLoots = bucket.itemLoots,
            moneyLoots = bucket.moneyLoots,
            items = BuildAggregatedItems(bucket.itemLoots),
            pinned = session.pinned == true,
            name = BuildSplitSessionName(bucket.locationLabel, startTime, stopTime),
        }

        if #mergedFromIDs > 0 then
            splitEntry.mergedFromSessionIDs = CloneNumberList(mergedFromIDs)
        end

        self.db.nextHistoryID = self.db.nextHistoryID + 1
        splitEntries[#splitEntries + 1] = splitEntry
    end

    local history = self:GetSessionHistory()
    local updatedHistory = {}
    local replaced = false
    for _, existingEntry in ipairs(history) do
        if existingEntry.id == session.id then
            replaced = true
            for _, splitEntry in ipairs(splitEntries) do
                updatedHistory[#updatedHistory + 1] = splitEntry
            end
        else
            updatedHistory[#updatedHistory + 1] = existingEntry
        end
    end

    if not replaced then
        return nil, "not-found"
    end

    while #updatedHistory > MAX_HISTORY_SESSIONS do
        table.remove(updatedHistory)
    end
    self.db.sessionHistory = updatedHistory

    if self.historyFrame
        and self.historyFrame.view == "details"
        and self.historyFrame.selectedSessionID == session.id
        and self.ShowHistoryListView then
        self:ShowHistoryListView()
    end
    if self.RefreshHistoryWindow then
        self:RefreshHistoryWindow()
    end
    if self.RefreshHistoryDetailsWindow then
        self:RefreshHistoryDetailsWindow()
    end

    return splitEntries
end

function GoldTracker:RenameHistorySession(sessionID, newName)
    local session = self:GetHistorySessionByID(sessionID)
    if not session then
        return false
    end

    local trimmed = self:Trim(newName or "")
    if trimmed == "" then
        return false
    end

    session.name = trimmed

    if self.RefreshHistoryWindow then
        self:RefreshHistoryWindow()
    end
    if self.RefreshHistoryDetailsWindow then
        self:RefreshHistoryDetailsWindow()
    end
    return true
end
