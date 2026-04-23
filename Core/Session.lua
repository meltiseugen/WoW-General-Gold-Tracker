local _, NS = ...
local GoldTracker = NS.GoldTracker

local function CloneReloadItemLoots(itemLoots)
    local copied = {}
    for i, entry in ipairs(itemLoots or {}) do
        copied[i] = {
            itemLink = entry.itemLink,
            quantity = tonumber(entry.quantity) or 0,
            unitValue = tonumber(entry.unitValue) or 0,
            totalValue = tonumber(entry.totalValue) or 0,
            vendorUnitValue = tonumber(entry.vendorUnitValue) or 0,
            vendorTotalValue = tonumber(entry.vendorTotalValue) or 0,
            isHighlighted = entry.isHighlighted == true,
            highlightThreshold = tonumber(entry.highlightThreshold),
            itemQuality = tonumber(entry.itemQuality),
            isSoulbound = entry.isSoulbound == true,
            timestamp = tonumber(entry.timestamp) or 0,
            valueSourceID = entry.valueSourceID,
            valueSourceLabel = GoldTracker:GetValueSourceLabel(entry.valueSourceID, entry.valueSourceLabel),
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
            -- Older snapshots predate this field; default to true to keep legacy
            -- behavior where all stored entries were AH-tracked.
            ahTracked = (entry.ahTracked == nil) and true or (entry.ahTracked == true),
            lootSourceType = entry.lootSourceType,
            lootSourceName = entry.lootSourceName,
            lootSourceIsAoe = entry.lootSourceIsAoe == true,
            lootSourceText = entry.lootSourceText,
            isCraftingReagent = entry.isCraftingReagent == true,
        }
    end
    return copied
end

local function CloneReloadMoneyLoots(moneyLoots)
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

local function BuildReloadSessionSnapshot(session)
    if type(session) ~= "table" or session.active ~= true then
        return nil
    end

    local highlightCount = tonumber(session.highlightItemCount)
    if not highlightCount then
        highlightCount = (tonumber(session.lowHighlightItemCount) or 0) + (tonumber(session.highHighlightItemCount) or 0)
    end
    highlightCount = math.max(0, math.floor((highlightCount or 0) + 0.5))

    return {
        active = true,
        startTime = tonumber(session.startTime),
        goldLooted = tonumber(session.goldLooted) or 0,
        itemValue = tonumber(session.itemValue) or 0,
        itemVendorValue = tonumber(session.itemVendorValue) or 0,
        highlightItemCount = highlightCount,
        lowHighlightItemCount = 0,
        highHighlightItemCount = highlightCount,
        itemLoots = CloneReloadItemLoots(session.itemLoots),
        moneyLoots = CloneReloadMoneyLoots(session.moneyLoots),
        diagnosisSnapshot = type(GoldTracker.CloneDiagnosisSnapshot) == "function"
            and GoldTracker:CloneDiagnosisSnapshot(session.diagnosisSnapshot)
            or nil,
        activeDurationSeconds = tonumber(session.activeDurationSeconds) or 0,
        isInstanced = session.isInstanced == true,
        instanceName = session.instanceName,
        instanceMapID = session.instanceMapID,
        instanceType = session.instanceType,
        zoneName = session.zoneName,
        locationKey = session.locationKey,
        mapID = session.mapID,
        mapName = session.mapName,
        mapPath = session.mapPath,
        continentName = session.continentName,
        expansionID = session.expansionID,
        expansionName = session.expansionName,
        wasResumed = session.wasResumed == true,
        resumeCount = math.max(0, math.floor((tonumber(session.resumeCount) or 0) + 0.5)),
        resumedAt = tonumber(session.resumedAt),
        resumedFromHistory = session.resumedFromHistory == true,
        resumedFromHistoryAt = tonumber(session.resumedFromHistoryAt),
        lastResumedFromHistoryAt = tonumber(session.lastResumedFromHistoryAt),
        resumedFromHistorySessionIDs = session.resumedFromHistorySessionIDs,
        resumedFromHistorySessionNames = session.resumedFromHistorySessionNames,
        savedAt = time(),
    }
end

function GoldTracker:ClearPendingReloadSession()
    if not self.db then
        return
    end
    self.db.pendingReloadSession = nil
end

function GoldTracker:StorePendingReloadSession()
    if not self.db then
        return false
    end

    local snapshot = BuildReloadSessionSnapshot(self.session)
    if not snapshot then
        self.db.pendingReloadSession = nil
        return false
    end

    self.db.pendingReloadSession = snapshot
    return true
end

function GoldTracker:TryRestorePendingReloadSession()
    if not self.db then
        return false
    end

    if not self:IsResumeSessionAfterReloadEnabled() then
        self.db.pendingReloadSession = nil
        return false
    end

    local snapshot = self.db.pendingReloadSession
    if type(snapshot) ~= "table" or snapshot.active ~= true then
        self.db.pendingReloadSession = nil
        return false
    end

    if type(snapshot.startTime) ~= "number" or snapshot.startTime <= 0 then
        self.db.pendingReloadSession = nil
        return false
    end

    local session = self.session or {}
    self.session = session
    session.active = true
    session.startTime = snapshot.startTime
    session.stopTime = nil
    session.goldLooted = tonumber(snapshot.goldLooted) or 0
    session.itemValue = tonumber(snapshot.itemValue) or 0
    session.itemVendorValue = tonumber(snapshot.itemVendorValue) or 0

    local highlightCount = tonumber(snapshot.highlightItemCount)
    if not highlightCount then
        highlightCount = (tonumber(snapshot.lowHighlightItemCount) or 0) + (tonumber(snapshot.highHighlightItemCount) or 0)
    end
    highlightCount = math.max(0, math.floor((highlightCount or 0) + 0.5))
    session.highlightItemCount = highlightCount
    session.lowHighlightItemCount = 0
    session.highHighlightItemCount = highlightCount

    session.itemLoots = CloneReloadItemLoots(snapshot.itemLoots)
    session.moneyLoots = CloneReloadMoneyLoots(snapshot.moneyLoots)
    if type(self.CloneDiagnosisSnapshot) == "function" then
        session.diagnosisSnapshot = self:CloneDiagnosisSnapshot(snapshot.diagnosisSnapshot)
    else
        session.diagnosisSnapshot = snapshot.diagnosisSnapshot
    end
    session.activeDurationSeconds = math.max(0, math.floor((tonumber(snapshot.activeDurationSeconds) or 0) + 0.5))
    session.isInstanced = snapshot.isInstanced == true
    session.instanceName = snapshot.instanceName
    session.instanceMapID = snapshot.instanceMapID
    session.instanceType = snapshot.instanceType
    session.zoneName = snapshot.zoneName
    session.locationKey = snapshot.locationKey
    session.mapID = snapshot.mapID
    session.mapName = snapshot.mapName
    session.mapPath = snapshot.mapPath
    session.continentName = snapshot.continentName
    session.expansionID = snapshot.expansionID
    session.expansionName = snapshot.expansionName
    session.wasResumed = snapshot.wasResumed == true
    session.resumeCount = math.max(0, math.floor((tonumber(snapshot.resumeCount) or 0) + 0.5))
    session.resumedAt = tonumber(snapshot.resumedAt)
    session.resumedFromHistory = snapshot.resumedFromHistory == true
    session.resumedFromHistoryAt = tonumber(snapshot.resumedFromHistoryAt)
    session.lastResumedFromHistoryAt = tonumber(snapshot.lastResumedFromHistoryAt)
    session.resumedFromHistorySessionIDs = snapshot.resumedFromHistorySessionIDs
    session.resumedFromHistorySessionNames = snapshot.resumedFromHistorySessionNames
    if type(self.GetMostRecentSessionLootTimestamp) == "function" then
        session.lastLootAt = self:GetMostRecentSessionLootTimestamp(session)
    else
        session.lastLootAt = tonumber(snapshot.startTime) or time()
    end
    if type(self.EnsureAlertRuntimeState) == "function" then
        local runtime = self:EnsureAlertRuntimeState()
        runtime.sessionStartTime = tonumber(session.startTime) or 0
        runtime.milestoneTriggeredByRule = {}
        runtime.noLootTriggered = false
    end

    self.db.pendingReloadSession = nil
    self.tsmWarningShown = false
    self:UpdateSessionLocationContext()
    self:AddLogMessage(string.format("%s  Session restored after reload.", date("%H:%M:%S")), 0.35, 1, 0.35)
    self:UpdateMainWindow()
    return true
end

function GoldTracker:StartSession(forceNew, options)
    options = options or {}

    if self.session.active and not forceNew then
        if not options.silentChat then
            self:Print("Session already active.")
        end
        return
    end

    self.session.active = true
    self.session.startTime = time()
    self.session.stopTime = nil
    self.session.goldLooted = 0
    self.session.itemValue = 0
    self.session.itemVendorValue = 0
    self.session.highlightItemCount = 0
    self.session.lowHighlightItemCount = 0
    self.session.highHighlightItemCount = 0
    self.session.itemLoots = {}
    self.session.moneyLoots = {}
    self.session.diagnosisSnapshot = nil
    self.session.isInstanced = false
    self.session.instanceName = nil
    self.session.instanceMapID = nil
    self.session.instanceType = nil
    self.session.zoneName = nil
    self.session.locationKey = nil
    self.session.mapID = nil
    self.session.mapName = nil
    self.session.mapPath = nil
    self.session.continentName = nil
    self.session.expansionID = nil
    self.session.expansionName = nil
    self.session.lastLootAt = self.session.startTime
    self.session.activeDurationSeconds = 0
    self.session.wasResumed = false
    self.session.resumeCount = 0
    self.session.resumedAt = nil
    self.session.resumedFromHistory = false
    self.session.resumedFromHistoryAt = nil
    self.session.lastResumedFromHistoryAt = nil
    self.session.resumedFromHistorySessionIDs = nil
    self.session.resumedFromHistorySessionNames = nil
    self.tsmWarningShown = false
    if self:IsDiagnosticsPanelEnabled() and type(self.CreateDiagnosisSnapshot) == "function" then
        self.session.diagnosisSnapshot = self:CreateDiagnosisSnapshot(self.session.startTime, self.session.startTime)
    elseif type(self.EnsureSessionDiagnosisSnapshot) == "function" and self:IsDiagnosticsPanelEnabled() then
        self:EnsureSessionDiagnosisSnapshot()
    end
    if type(self.EnsureAlertRuntimeState) == "function" then
        local runtime = self:EnsureAlertRuntimeState()
        runtime.sessionStartTime = tonumber(self.session.startTime) or 0
        runtime.milestoneTriggeredByRule = {}
        runtime.noLootTriggered = false
    end
    self:UpdateSessionLocationContext()

    if not options.keepLog then
        self:ClearLog()
    end
    self:UpdateMainWindow()
    if not options.silentChat then
        self:Print("Session started.")
    end
end

function GoldTracker:StopSession(options)
    options = options or {}

    if not self.session.active then
        if not options.silentChat then
            self:Print("No active session.")
        end
        return
    end

    self.session.active = false
    self.session.stopTime = time()
    self.session.lastLootAt = nil
    if not options.skipContextRefresh then
        self:UpdateSessionLocationContext()
    end
    self:SaveCurrentSessionToHistory(options.saveReason or "stop")

    self:UpdateMainWindow()
    if not options.silentChat then
        self:Print(string.format("Session stopped. Total value: %s", self:FormatMoney(self:GetSessionTotalValue())))
    end
end

function GoldTracker:HandleSessionLocationTransition()
    if not self.session or not self.session.active then
        return false
    end

    local previousLocationKey = self.session.locationKey
    if type(previousLocationKey) ~= "string" then
        self:UpdateSessionLocationContext()
        return false
    end

    local current = self:GetCurrentLocationSnapshot()
    if type(current.locationKey) ~= "string" or current.locationKey == previousLocationKey then
        self:UpdateSessionLocationContext()
        return false
    end

    local isInstancedNow = current.isInstanced == true
    if not isInstancedNow then
        self:UpdateSessionLocationContext()
        return false
    end

    local previousName = self.session.instanceName or self.session.zoneName or "Unknown"
    local currentName = current.instanceName or current.zoneName or "Unknown"

    self:StopSession({
        saveReason = "instance-switch",
        skipContextRefresh = true,
        silentChat = true,
        silentLog = true,
    })
    self:StartSession(true, {
        silentChat = true,
    })
    self:AddLogMessage(
        string.format("%s  Auto-started new session: %s -> %s", date("%H:%M:%S"), previousName, currentName),
        0.55,
        0.9,
        1
    )
    self:Print(string.format("Auto-started new session after instance change: %s -> %s", previousName, currentName))
    return true
end

function GoldTracker:HandlePlayerLogout()
    local isReloading = type(IsReloadingUI) == "function" and IsReloadingUI() == true
    if isReloading and self:IsResumeSessionAfterReloadEnabled() and self.session and self.session.active then
        self:StorePendingReloadSession()
        return
    end

    self:ClearPendingReloadSession()

    if not self.session or not self.session.active then
        return
    end

    local saveReason = isReloading and "reload" or "logout"
    self:StopSession({
        saveReason = saveReason,
        silentChat = true,
        silentLog = true,
    })
end
