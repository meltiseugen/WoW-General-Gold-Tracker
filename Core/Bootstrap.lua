local _, NS = ...
local GoldTracker = NS.GoldTracker

function GoldTracker:HandleSlashCommand(message)
    local command = self:Trim((message or ""):lower())

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

    if command == "help" then
        self:Print("Commands: /gt, /gt start, /gt new, /gt stop, /gt options")
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

    self:RegisterEvent("CHAT_MSG_LOOT")
    self:RegisterEvent("CHAT_MSG_MONEY")
    self:RegisterEvent("PLAYER_ENTERING_WORLD")
    self:RegisterEvent("PLAYER_LOGOUT")
    self:UnregisterEvent("ADDON_LOADED")

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
    if event == "ADDON_LOADED" then
        GoldTracker:OnAddonLoaded(...)
    elseif event == "CHAT_MSG_LOOT" then
        GoldTracker:OnChatMsgLoot(...)
    elseif event == "CHAT_MSG_MONEY" then
        GoldTracker:OnChatMsgMoney(...)
    elseif event == "PLAYER_ENTERING_WORLD" then
        GoldTracker:OnPlayerEnteringWorld(...)
    elseif event == "PLAYER_LOGOUT" then
        GoldTracker:HandlePlayerLogout()
    end
end)

GoldTracker:RegisterEvent("ADDON_LOADED")

SLASH_WOWGENERALGOLDTRACKER1 = "/gt"
SlashCmdList.WOWGENERALGOLDTRACKER = function(message)
    GoldTracker:HandleSlashCommand(message)
end
