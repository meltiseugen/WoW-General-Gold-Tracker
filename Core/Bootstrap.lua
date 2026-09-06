local _, NS = ...
local GoldTracker = NS.GoldTracker

function GoldTracker:HandleSlashCommand(message)
    local rawMessage = self:Trim(message or "")
    local command, commandArgs = string.match(rawMessage, "^(%S*)%s*(.-)%s*$")
    command = string.lower(command or "")
    commandArgs = commandArgs or ""

    if command == "" then
        if type(self.OpenMainWindowFromSlash) == "function" then
            self:OpenMainWindowFromSlash()
        elseif type(self.OpenMainWindow) == "function" then
            self:OpenMainWindow()
        elseif self.mainFrame then
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

    if command == "explorer" or command == "explore" then
        if type(self.OpenExplorerWindow) == "function" then
            self:OpenExplorerWindow()
        else
            self:Print("Explorer window is not loaded yet.")
        end
        return
    end

    if command == "rares" or command == "rare" or command == "farming" then
        if type(self.OpenExplorerWindow) == "function" then
            self:OpenExplorerWindow("rares")
        elseif type(self.OpenRareFarmingWindow) == "function" then
            self:OpenRareFarmingWindow()
        else
            self:Print("Rare Farming window is not loaded yet.")
        end
        return
    end

    if command == "instances" or command == "instance" or command == "dungeons" or command == "raids" then
        if type(self.OpenExplorerWindow) == "function" then
            self:OpenExplorerWindow("instances")
        elseif type(self.OpenInstanceFarmingWindow) == "function" then
            self:OpenInstanceFarmingWindow()
        else
            self:Print("Dungeon & Raid Farming window is not loaded yet.")
        end
        return
    end

    if command == "mats" or command == "materials" or command == "crafting" or command == "consumables" then
        if type(self.OpenExplorerWindow) == "function" then
            self:OpenExplorerWindow("materials")
        elseif type(self.OpenCraftingFarmingWindow) == "function" then
            self:OpenCraftingFarmingWindow()
        else
            self:Print("Materials Farming window is not loaded yet.")
        end
        return
    end

    if command == "drops" or command == "observed" or command == "observeddrops" then
        if type(self.OpenExplorerWindow) == "function" then
            self:OpenExplorerWindow("drops")
        elseif type(self.OpenObservedDropsWindow) == "function" then
            self:OpenObservedDropsWindow()
        else
            self:Print("Observed Drops window is not loaded yet.")
        end
        return
    end

    if command == "alerts" or command == "pricealerts" or command == "prices" then
        if type(self.OpenExplorerWindow) == "function" then
            self:OpenExplorerWindow("priceAlerts")
        elseif type(self.OpenPriceIncreaseAlertsWindow) == "function" then
            self:OpenPriceIncreaseAlertsWindow()
        else
            self:Print("Price Alerts window is not loaded yet.")
        end
        return
    end

    if command == "addmat" or command == "addmaterial" then
        local itemIDText, expansionID, professionID, tag = string.match(commandArgs, "^(%d+)%s+(%S+)%s+(%S+)%s*(.-)%s*$")
        local itemID = tonumber(itemIDText)
        if not itemID then
            self:Print("Usage: /gt addmat <itemID> <expansionID> <professionID> [tag]. Example: /gt addmat 14256 classic tailoring Cloth")
            return
        end

        local customItem = self:AddCraftingFarmingCustomItem(itemID, expansionID, professionID, tag)
        if customItem then
            self:Print(string.format(
                "Added custom material item %d to %s / %s.",
                customItem.itemID,
                customItem.expansion,
                customItem.professions and customItem.professions[1] or "unknown"
            ))
        else
            self:Print("Could not add custom material item.")
        end
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

    if command == "clearmap" or command == "clearpins" or command == "mapclear" then
        if type(self.ClearWorldMapProjection) == "function" then
            self:ClearWorldMapProjection()
        else
            self:Print("World map projection is not loaded yet.")
        end
        return
    end

    if command == "maptest" then
        if type(self.OpenStandaloneMapTest) == "function" then
            self:Print("Opening farming route map...")
            self:OpenStandaloneMapTest()
        else
            self:Print("Farming route map is not loaded yet.")
        end
        return
    end

    if command == "help" then
        local commands = "Commands: /gt, /gt start, /gt new, /gt stop, /gt options, /gt explorer, /gt drops, /gt alerts, /gt addmat <itemID> <expansion> <profession> [tag], /gt market <item>, /gt maptest, /gt clearpins"
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
    self:RegisterEvent("AUCTION_HOUSE_SHOW")
    self:RegisterEvent("PLAYER_LOGOUT")
    self:UnregisterEvent("ADDON_LOADED")

    if type(self.QueueMarketHistoryBagSnapshot) == "function" then
        self:QueueMarketHistoryBagSnapshot()
    end
    if type(self.RecordSavedRareFarmingMarketSnapshots) == "function" then
        if C_Timer and type(C_Timer.After) == "function" then
            C_Timer.After(8, function()
                GoldTracker:RecordSavedRareFarmingMarketSnapshots()
            end)
        else
            self:RecordSavedRareFarmingMarketSnapshots()
        end
    end
    if type(self.RecordSavedInstanceFarmingMarketSnapshots) == "function" then
        if C_Timer and type(C_Timer.After) == "function" then
            C_Timer.After(10, function()
                GoldTracker:RecordSavedInstanceFarmingMarketSnapshots()
            end)
        else
            self:RecordSavedInstanceFarmingMarketSnapshots()
        end
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

    if type(self.InvalidateInventoryWindowCache) == "function" then
        self:InvalidateInventoryWindowCache()
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

local function IsAuctionHouseSellDisplayMode(mode)
    local displayMode = _G.AuctionHouseFrameDisplayMode
    if not displayMode or not mode then
        return false
    end

    return mode == displayMode.ItemSell or mode == displayMode.CommoditiesSell or mode == displayMode.Sell
end

function GoldTracker:IsAuctionHouseSellTabSelected()
    local auctionHouseFrame = _G.AuctionHouseFrame
    if not auctionHouseFrame or (auctionHouseFrame.IsShown and not auctionHouseFrame:IsShown()) then
        return false
    end

    return IsAuctionHouseSellDisplayMode(auctionHouseFrame.displayMode)
end

function GoldTracker:OpenAuctionableInventoryFromAuctionHouseSellTab()
    if not self:IsAutoOpenAuctionableInventoryOnAuctionHouseEnabled() then
        return
    end

    if type(self.InvalidateInventoryWindowCache) == "function" then
        self:InvalidateInventoryWindowCache()
    end
    if self.inventoryFrame and self.inventoryFrame:IsShown() then
        if self.explorerFrame and self.explorerFrame.Raise then
            self.explorerFrame:Raise()
        end
        self.inventoryFrame:Raise()
        self:RefreshInventoryWindow(false)
        return
    end

    self:OpenInventoryWindow()
end

function GoldTracker:MarkAuctionHouseTabClick()
    self.auctionHouseTabClickTime = type(GetTime) == "function" and GetTime() or 0
end

function GoldTracker:WasAuctionHouseTabClickedRecently()
    if type(GetTime) ~= "function" then
        return false
    end

    return (GetTime() - (self.auctionHouseTabClickTime or 0)) <= 0.75
end

function GoldTracker:OpenAuctionableInventoryIfAuctionHouseSellTabSelected()
    if self:IsAuctionHouseSellTabSelected() or self:IsAuctionHouseSellPaneShown() then
        self:OpenAuctionableInventoryFromAuctionHouseSellTab()
    end
end

function GoldTracker:IsAuctionHouseSellPaneShown()
    local auctionHouseFrame = _G.AuctionHouseFrame
    if not auctionHouseFrame or (auctionHouseFrame.IsShown and not auctionHouseFrame:IsShown()) then
        return false
    end

    local itemSellFrame = auctionHouseFrame.ItemSellFrame
    if itemSellFrame and itemSellFrame.IsShown and itemSellFrame:IsShown() then
        return true
    end

    local commoditiesSellFrame = auctionHouseFrame.CommoditiesSellFrame
    if commoditiesSellFrame and commoditiesSellFrame.IsShown and commoditiesSellFrame:IsShown() then
        return true
    end

    local sellFrame = auctionHouseFrame.SellFrame
    if sellFrame and sellFrame.IsShown and sellFrame:IsShown() then
        return true
    end

    local auctionatorSellingFrame = _G.AuctionatorSellingFrame
    return auctionatorSellingFrame and auctionatorSellingFrame.IsShown and auctionatorSellingFrame:IsShown()
end

function GoldTracker:StartAuctionHouseSellPaneWatcher()
    if self.auctionHouseSellPaneWatcher then
        self.auctionHouseSellPaneWatcher:Show()
        return
    end

    local watcher = CreateFrame("Frame")
    watcher.elapsed = 0
    watcher:SetScript("OnUpdate", function(frame, elapsed)
        frame.elapsed = (frame.elapsed or 0) + (elapsed or 0)
        if frame.elapsed < 0.1 then
            return
        end
        frame.elapsed = 0

        local auctionHouseFrame = _G.AuctionHouseFrame
        if not auctionHouseFrame or (auctionHouseFrame.IsShown and not auctionHouseFrame:IsShown()) then
            GoldTracker.auctionHouseSellPaneWasShown = false
            GoldTracker.auctionHouseSellPaneWatcherArmed = false
            frame:Hide()
            return
        end

        local sellPaneShown = GoldTracker:IsAuctionHouseSellPaneShown()
        if GoldTracker.auctionHouseSellPaneWatcherArmed
            and sellPaneShown
            and not GoldTracker.auctionHouseSellPaneWasShown then
            GoldTracker:OpenAuctionableInventoryFromAuctionHouseSellTab()
        end

        GoldTracker.auctionHouseSellPaneWasShown = sellPaneShown
    end)

    self.auctionHouseSellPaneWatcher = watcher
end

function GoldTracker:HookAuctionHouseTabButton(tab)
    if not tab or tab.goldTrackerSellTabClickHooked or type(tab.HookScript) ~= "function" then
        return
    end

    tab.goldTrackerSellTabClickHooked = true
    tab:HookScript("OnMouseDown", function()
        GoldTracker:MarkAuctionHouseTabClick()
    end)
    tab:HookScript("OnClick", function()
        GoldTracker:MarkAuctionHouseTabClick()
        if C_Timer and type(C_Timer.After) == "function" then
            C_Timer.After(0, function()
                GoldTracker:OpenAuctionableInventoryIfAuctionHouseSellTabSelected()
            end)
        else
            GoldTracker:OpenAuctionableInventoryIfAuctionHouseSellTabSelected()
        end
    end)
end

local function IsAuctionHouseSellButton(frame)
    if not frame or type(frame.GetText) ~= "function" then
        return false
    end

    local text = frame:GetText()
    if type(text) ~= "string" or text == "" then
        return false
    end

    return text == _G.SELL or text == "Sell" or text == "Selling" or text == _G.AUCTIONATOR_L_SELLING_TAB
end

function GoldTracker:HookAuctionHouseSellButtons(parent, depth)
    if not parent or depth > 4 or type(parent.GetChildren) ~= "function" then
        return
    end

    local children = { parent:GetChildren() }
    for _, child in ipairs(children) do
        if IsAuctionHouseSellButton(child) then
            self:HookAuctionHouseTabButton(child)
        end
        self:HookAuctionHouseSellButtons(child, depth + 1)
    end
end

function GoldTracker:OnAuctionHouseDisplayModeChanged(mode)
    if not IsAuctionHouseSellDisplayMode(mode) or not self:WasAuctionHouseTabClickedRecently() then
        return
    end

    self:OpenAuctionableInventoryFromAuctionHouseSellTab()
end

function GoldTracker:InstallAuctionHouseSellTabHooks()
    local auctionHouseFrame = _G.AuctionHouseFrame
    if not auctionHouseFrame then
        return
    end

    if not auctionHouseFrame.goldTrackerDisplayModeHooked
        and type(hooksecurefunc) == "function"
        and type(auctionHouseFrame.SetDisplayMode) == "function" then
        auctionHouseFrame.goldTrackerDisplayModeHooked = true
        hooksecurefunc(auctionHouseFrame, "SetDisplayMode", function(_, mode)
            GoldTracker:OnAuctionHouseDisplayModeChanged(mode)
        end)
    end

    if type(auctionHouseFrame.Tabs) == "table" then
        for _, tab in ipairs(auctionHouseFrame.Tabs) do
            self:HookAuctionHouseTabButton(tab)
        end
    end

    self:HookAuctionHouseTabButton(_G.AuctionatorTabs_Selling)
    self:HookAuctionHouseSellButtons(auctionHouseFrame, 1)
end

function GoldTracker:OnAuctionHouseShow()
    self.auctionHouseSellPaneWatcherArmed = false
    self.auctionHouseSellPaneWasShown = false
    self:StartAuctionHouseSellPaneWatcher()
    self:InstallAuctionHouseSellTabHooks()
    if C_Timer and type(C_Timer.After) == "function" then
        C_Timer.After(0.25, function()
            GoldTracker.auctionHouseSellPaneWasShown = GoldTracker:IsAuctionHouseSellPaneShown()
            GoldTracker.auctionHouseSellPaneWatcherArmed = true
        end)
        C_Timer.After(0.1, function() GoldTracker:InstallAuctionHouseSellTabHooks() end)
        C_Timer.After(0.5, function() GoldTracker:InstallAuctionHouseSellTabHooks() end)
        C_Timer.After(1, function() GoldTracker:InstallAuctionHouseSellTabHooks() end)
    else
        self.auctionHouseSellPaneWasShown = self:IsAuctionHouseSellPaneShown()
        self.auctionHouseSellPaneWatcherArmed = true
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
        if type(GoldTracker.InvalidateInventoryWindowCache) == "function" then
            GoldTracker:InvalidateInventoryWindowCache()
        end
        if type(GoldTracker.QueueMarketHistoryBagSnapshot) == "function" then
            GoldTracker:QueueMarketHistoryBagSnapshot()
        end
        if GoldTracker.inventoryFrame and GoldTracker.inventoryFrame:IsShown() then
            GoldTracker:RefreshInventoryWindow(false)
        end
    elseif event == "AUCTION_HOUSE_SHOW" then
        GoldTracker:OnAuctionHouseShow()
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
