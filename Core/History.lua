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
            isSoulbound = entry.isSoulbound == true,
            timestamp = tonumber(entry.timestamp) or 0,
            valueSourceID = entry.valueSourceID or fallbackSourceID,
            valueSourceLabel = entry.valueSourceLabel or fallbackSourceLabel,
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

    local fallbackSourceID = entry.valueSourceID
    local fallbackSourceLabel = GetSessionPrimarySourceLabel(entry)
    for _, loot in ipairs(entry.itemLoots) do
        if type(loot.valueSourceLabel) ~= "string" or loot.valueSourceLabel == "" then
            loot.valueSourceLabel = fallbackSourceLabel
        end
        if loot.valueSourceID == nil then
            loot.valueSourceID = fallbackSourceID
        end
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
        mapID = self.session.mapID,
        mapName = self.session.mapName,
        mapPath = self.session.mapPath,
        continentName = self.session.continentName,
        expansionID = self.session.expansionID,
        expansionName = self.session.expansionName,
        itemLoots = itemLoots,
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

        if type(session.itemLoots) == "table" and #session.itemLoots > 0 then
            local copiedLoots = CloneItemLootEntries(session.itemLoots, sessionSourceID, sessionSourceLabel)
            for _, loot in ipairs(copiedLoots) do
                mergedLoots[#mergedLoots + 1] = loot
            end
        else
            local fallbackTimestamp = tonumber(session.stopTime or session.savedAt or time()) or time()
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
                    isSoulbound = item.isSoulbound == true,
                    timestamp = fallbackTimestamp,
                    valueSourceID = sessionSourceID,
                    valueSourceLabel = sessionSourceLabel,
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
