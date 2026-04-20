local _, NS = ...
local GoldTracker = NS.GoldTracker

function GoldTracker:HandleSlashCommand(message)
    local rawMessage = self:Trim(message or "")
    local command, commandArgs = string.match(rawMessage, "^(%S*)%s*(.-)%s*$")
    command = string.lower(command or "")
    commandArgs = commandArgs or ""

    if command == "" then
        if self.mainFrame then
            self.mainFrame:Show()
            self.mainFrame:Raise()
        end
        return
    end

    if command == "start" then
        self:StartSession()
        return
    end

    if command == "new" then
        self:StartSession(true)
        return
    end

    if command == "stop" then
        self:StopSession()
        return
    end

    if command == "options" then
        self:OpenOptions()
        return
    end

    if command == "total" and self:IsTotalWindowFeatureEnabled() then
        self:ToggleTotalWindow()
        return
    end

    if command == "market" or command == "markethistory" then
        if type(self.PrintMarketHistoryDebug) == "function" then
            self:PrintMarketHistoryDebug(commandArgs)
        else
            self:Print("Market history is not loaded yet.")
        end
        return
    end

    if command == "help" then
        local commands = "Commands: /gt, /gt start, /gt new, /gt stop, /gt options, /gt market <item>"
        if self:IsTotalWindowFeatureEnabled() then
            commands = commands .. ", /gt total, /gtt"
        end
        self:Print(commands)
        return
    end

    self:Print("Unknown command. Use /gt help")
end

function GoldTracker:OnAddonLoaded(addonName)
    if addonName ~= self.ADDON_NAME then
        return
    end

    local isSupported, reason = self:IsSupportedClient()
    if not isSupported then
        self:Print("Disabled: " .. reason)
        self:UnregisterEvent("ADDON_LOADED")
        return
    end

    self:InitializeDatabase()
    self:CreateMinimapButton()
    self:CreateMainWindow()
    self:CreateOptionsPanel()
    self:UpdateMainWindow()
    self:StartAlertTicker()

    self:RegisterEvent("CHAT_MSG_LOOT")
    self:RegisterEvent("CHAT_MSG_MONEY")
    self:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
    self:RegisterEvent("LOOT_OPENED")
    self:RegisterEvent("LOOT_CLOSED")
    self:RegisterEvent("PLAYER_TARGET_CHANGED")
    self:RegisterEvent("UPDATE_MOUSEOVER_UNIT")
    self:RegisterEvent("NAME_PLATE_UNIT_ADDED")
    self:RegisterEvent("PLAYER_FOCUS_CHANGED")
    self:RegisterEvent("PLAYER_ENTERING_WORLD")
    self:RegisterEvent("BAG_UPDATE_DELAYED")
    self:RegisterEvent("PLAYER_LOGOUT")
    self:UnregisterEvent("ADDON_LOADED")

    if type(self.QueueMarketHistoryBagSnapshot) == "function" then
        self:QueueMarketHistoryBagSnapshot()
    end

    self:Print("Loaded. Use /gt to open the tracker window.")
end

function GoldTracker:ShouldAutoStartOnWorldEntry(isInitialLogin, isReloadingUI)
    if not (self.db and self.db.autoStartSessionOnEnterWorld) then
        return false
    end

    if isInitialLogin or isReloadingUI then
        return true
    end

    local inInstance = false
    if type(IsInInstance) == "function" then
        inInstance = select(1, IsInInstance()) == true
    end

    return inInstance
end

function GoldTracker:OnPlayerEnteringWorld(isInitialLogin, isReloadingUI)
    if not self.minimapButton then
        self:CreateMinimapButton()
    end

    if type(self.QueueMarketHistoryBagSnapshot) == "function" then
        self:QueueMarketHistoryBagSnapshot()
    end

    self:TryRestorePendingReloadSession()

    if self.session and self.session.active then
        self:HandleSessionLocationTransition()
        return
    end

    if self:ShouldAutoStartOnWorldEntry(isInitialLogin, isReloadingUI) then
        self:StartSession(false, {
            silentChat = true,
        })
        if isInitialLogin then
            self:Print("Session auto-started on world entry.")
        elseif isReloadingUI then
            self:Print("Session auto-started after reload.")
        else
            self:Print("Session auto-started on instance entry.")
        end
    end
end

GoldTracker:SetScript("OnEvent", function(_, event, ...)
    if type(GoldTracker.IncrementDiagnosticCounter) == "function" then
        GoldTracker:IncrementDiagnosticCounter("event_" .. tostring(event))
    end

    if event == "ADDON_LOADED" then
        GoldTracker:OnAddonLoaded(...)
    elseif event == "CHAT_MSG_LOOT" then
        GoldTracker:OnChatMsgLoot(...)
    elseif event == "CHAT_MSG_MONEY" then
        GoldTracker:OnChatMsgMoney(...)
    elseif event == "UNIT_SPELLCAST_SUCCEEDED" then
        GoldTracker:OnUnitSpellcastSucceeded(...)
    elseif event == "LOOT_OPENED" then
        GoldTracker:OnLootOpened(...)
    elseif event == "LOOT_CLOSED" then
        GoldTracker:OnLootClosed(...)
    elseif event == "PLAYER_TARGET_CHANGED" then
        GoldTracker:OnPlayerTargetChanged(...)
    elseif event == "UPDATE_MOUSEOVER_UNIT" then
        GoldTracker:OnUpdateMouseoverUnit(...)
    elseif event == "NAME_PLATE_UNIT_ADDED" then
        GoldTracker:OnNamePlateUnitAdded(...)
    elseif event == "PLAYER_FOCUS_CHANGED" then
        GoldTracker:OnPlayerFocusChanged(...)
    elseif event == "PLAYER_ENTERING_WORLD" then
        GoldTracker:OnPlayerEnteringWorld(...)
    elseif event == "BAG_UPDATE_DELAYED" then
        if type(GoldTracker.QueueMarketHistoryBagSnapshot) == "function" then
            GoldTracker:QueueMarketHistoryBagSnapshot()
        end
    elseif event == "PLAYER_LOGOUT" then
        GoldTracker:HandlePlayerLogout()
    end
end)

GoldTracker:RegisterEvent("ADDON_LOADED")

SLASH_WOWGENERALGOLDTRACKER1 = "/gt"
SlashCmdList.WOWGENERALGOLDTRACKER = function(message)
    GoldTracker:HandleSlashCommand(message)
end

if GoldTracker:IsTotalWindowFeatureEnabled() then
    SLASH_WOWGENERALGOLDTRACKERTOTAL1 = "/gtt"
    SlashCmdList.WOWGENERALGOLDTRACKERTOTAL = function()
        GoldTracker:OpenTotalWindow()
    end
end
