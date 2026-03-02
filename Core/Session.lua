local _, NS = ...
local GoldTracker = NS.GoldTracker

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
    self.tsmWarningShown = false
    self:UpdateSessionLocationContext()

    if not options.keepLog then
        self:ClearLog()
    end
    if not options.silentLog then
        self:AddLogMessage(string.format("%s  Session started.", date("%H:%M:%S")), 0.35, 1, 0.35)
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
    if not options.skipContextRefresh then
        self:UpdateSessionLocationContext()
    end
    self:SaveCurrentSessionToHistory(options.saveReason or "stop")

    if not options.silentLog then
        self:AddLogMessage(string.format("%s  Session stopped.", date("%H:%M:%S")), 1, 0.82, 0)
    end
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
    if not self.session or not self.session.active then
        return
    end

    local saveReason = "logout"
    if type(IsReloadingUI) == "function" and IsReloadingUI() then
        saveReason = "reload"
    end

    self:StopSession({
        saveReason = saveReason,
        silentChat = true,
        silentLog = true,
    })
end
