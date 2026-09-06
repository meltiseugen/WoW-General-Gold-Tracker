local _, NS = ...
local GoldTracker = NS.GoldTracker
local Theme = NS.JanisTheme

local EXPLORER_WINDOW_WIDTH = 1180
local EXPLORER_WINDOW_HEIGHT = 660
local EXPLORER_WINDOW_MIN_WIDTH = 900
local EXPLORER_WINDOW_MIN_HEIGHT = 520
local EXPLORER_WINDOW_MAX_WIDTH = 1440
local EXPLORER_WINDOW_MAX_HEIGHT = 920

local EXPLORER_TABS = {
    { id = "favorites", label = "Favorites" },
    { id = "priceAlerts", label = "Alerts" },
    { id = "rares", label = "Rares" },
    { id = "instances", label = "Instances" },
    { id = "drops", label = "Drops" },
    { id = "materials", label = "Materials" },
    { id = "inventory", label = "Bags" },
}

local EXPLORER_TAB_LOOKUP = {}
for _, tab in ipairs(EXPLORER_TABS) do
    EXPLORER_TAB_LOOKUP[tab.id] = tab
end

local function NormalizeExplorerTab(tabID)
    if EXPLORER_TAB_LOOKUP[tabID] then
        return tabID
    end
    return "rares"
end

local function CreateExplorerButton(parent, width, height, text, paletteKey)
    return Theme:CreateButton(parent, width, height, text, paletteKey)
end

local function HideFramePart(part)
    if part and type(part.Hide) == "function" then
        part:Hide()
    end
end

local function SetFrameShown(frame, isShown)
    if not frame then
        return
    end
    if type(frame.SetShown) == "function" then
        frame:SetShown(isShown == true)
    elseif isShown and type(frame.Show) == "function" then
        frame:Show()
    elseif not isShown and type(frame.Hide) == "function" then
        frame:Hide()
    end
end

local function AnchorExplorerSubTab(button, relativeTo)
    if not button or type(button.ClearAllPoints) ~= "function" or type(button.SetPoint) ~= "function" then
        return
    end

    button:ClearAllPoints()
    if relativeTo then
        button:SetPoint("LEFT", relativeTo, "RIGHT", 8, 0)
    elseif type(button.GetParent) == "function" and button:GetParent() and button:GetParent().chrome then
        button:SetPoint("TOPLEFT", button:GetParent().chrome, "TOPLEFT", 12, -54)
    end
end

local function DisableEmbeddedWindowChrome(frame)
    if not frame then
        return
    end

    HideFramePart(frame.headerBar)
    HideFramePart(frame.headerAccent)
    HideFramePart(frame.headerTitleText)
    HideFramePart(frame.closeButton)
    HideFramePart(frame.resizeButton)
    HideFramePart(frame.CloseButton)
    HideFramePart(frame.TitleText)
end

local function SetExplorerFrameLevel(frame, referenceFrame, offset)
    if not frame or not referenceFrame or type(frame.SetFrameLevel) ~= "function" or type(referenceFrame.GetFrameLevel) ~= "function" then
        return
    end

    frame:SetFrameLevel((referenceFrame:GetFrameLevel() or 0) + (offset or 1))
end

local function IsExplorerEmbeddedChildFrame(frame)
    return frame
        and GoldTracker.explorerFrame
        and GoldTracker.explorerFrame.contentFrame
        and type(frame.GetParent) == "function"
        and frame:GetParent() == GoldTracker.explorerFrame.contentFrame
end

local function GetEmbeddedVerticalScrollBar(frame)
    local scrollFrame = frame and frame.scrollFrame
    if not scrollFrame then
        return frame and frame.verticalScrollBar or nil
    end

    if frame.verticalScrollBar then
        return frame.verticalScrollBar
    end
    if scrollFrame.ScrollBar then
        return scrollFrame.ScrollBar
    end
    if scrollFrame.Scrollbar then
        return scrollFrame.Scrollbar
    end
    if type(scrollFrame.GetName) == "function" then
        local scrollFrameName = scrollFrame:GetName()
        if scrollFrameName then
            return _G[scrollFrameName .. "ScrollBar"]
        end
    end
    return nil
end

local function RaiseEmbeddedWindowParts(frame)
    if not frame then
        return
    end

    local chrome = frame.chrome or frame
    if chrome ~= frame then
        SetExplorerFrameLevel(chrome, frame, 1)
    end

    for _, panelKey in ipairs({ "bodyPanel", "libraryPanel", "controlsPanel", "listPanel", "summaryPanel", "logPanel" }) do
        SetExplorerFrameLevel(frame[panelKey], chrome, 1)
    end

    for _, buttonKey in ipairs({
        "librarySavedTabButton",
        "libraryFavoritesTabButton",
        "libraryNewScanButton",
        "savedTabButton",
        "favoritesTabButton",
        "newScanTabButton",
        "libraryUpdateFavoritesButton",
    }) do
        SetExplorerFrameLevel(frame[buttonKey], chrome, 2)
    end

    SetExplorerFrameLevel(frame.libraryFavoritesHeaderFrame, frame.libraryPanel, 2)
    SetExplorerFrameLevel(frame.libraryScrollFrame, frame.libraryPanel, 2)
    SetExplorerFrameLevel(frame.libraryContent, frame.libraryScrollFrame, 1)
    SetExplorerFrameLevel(frame.scrollFrame, frame.listPanel or frame.bodyPanel, 2)
    SetExplorerFrameLevel(frame.content, frame.scrollFrame, 1)
    SetExplorerFrameLevel(GetEmbeddedVerticalScrollBar(frame), frame.listPanel or frame.bodyPanel, 3)
    SetExplorerFrameLevel(frame.horizontalScrollBar, frame.listPanel or frame.bodyPanel, 3)
end

local function GetActiveExplorerChildFrame(addon)
    if not addon or not addon.explorerFrame then
        return nil
    end

    for _, childFrame in ipairs({
        addon.rareFarmingFrame,
        addon.instanceFarmingFrame,
        addon.craftingFarmingFrame,
        addon.observedDropsFrame,
        addon.inventoryFrame,
        addon.priceIncreaseAlertsFrame,
    }) do
        if IsExplorerEmbeddedChildFrame(childFrame)
            and type(childFrame.IsShown) == "function"
            and childFrame:IsShown() then
            return childFrame
        end
    end

    return nil
end

local function RefreshActiveExplorerChildStack(addon)
    local explorerFrame = addon and addon.explorerFrame
    local contentFrame = explorerFrame and explorerFrame.contentFrame
    local childFrame = GetActiveExplorerChildFrame(addon)
    if not explorerFrame or not contentFrame or not childFrame then
        return
    end

    if type(contentFrame.SetFrameStrata) == "function" and type(explorerFrame.GetFrameStrata) == "function" then
        contentFrame:SetFrameStrata(explorerFrame:GetFrameStrata() or "DIALOG")
    end
    SetExplorerFrameLevel(contentFrame, explorerFrame.chrome or explorerFrame, 2)
    if type(childFrame.SetFrameStrata) == "function" and type(contentFrame.GetFrameStrata) == "function" then
        childFrame:SetFrameStrata(contentFrame:GetFrameStrata() or "DIALOG")
    end
    if type(childFrame.SetToplevel) == "function" then
        childFrame:SetToplevel(false)
    end
    SetExplorerFrameLevel(childFrame, contentFrame, 1)
    RaiseEmbeddedWindowParts(childFrame)
end

local function AssignEmbeddedWindowFocusOwner(childFrame, explorerFrame)
    if not childFrame or not explorerFrame then
        return
    end

    childFrame.goldTrackerManagedWindow = explorerFrame
end

local function EmbedChildFrame(frame, parent)
    if not frame or not parent then
        return
    end

    AssignEmbeddedWindowFocusOwner(frame, GoldTracker.explorerFrame)
    if frame.SetParent then
        frame:SetParent(parent)
    end
    if frame.SetFrameStrata then
        local parentStrata = type(parent.GetFrameStrata) == "function" and parent:GetFrameStrata() or "DIALOG"
        frame:SetFrameStrata(parentStrata or "DIALOG")
    end
    if frame.SetIgnoreParentAlpha then
        frame:SetIgnoreParentAlpha(false)
    end
    if frame.SetIgnoreParentScale then
        frame:SetIgnoreParentScale(false)
    end
    if frame.SetToplevel then
        frame:SetToplevel(false)
    end
    SetExplorerFrameLevel(frame, parent, 1)
    if frame.SetMovable then
        frame:SetMovable(false)
    end
    if frame.SetResizable then
        frame:SetResizable(false)
    end
    if frame.SetClampedToScreen then
        frame:SetClampedToScreen(false)
    end
    frame:ClearAllPoints()
    frame:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, 0)
    frame:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", 0, 0)
    DisableEmbeddedWindowChrome(frame)
    RaiseEmbeddedWindowParts(frame)
end

local function HideExplorerChildFrame(frame)
    if not frame then
        return
    end
    if type(frame.ClearAllPoints) == "function"
        and type(frame.GetParent) == "function"
        and frame:GetParent() == (GoldTracker.explorerFrame and GoldTracker.explorerFrame.contentFrame) then
        frame:ClearAllPoints()
    end
    frame.suppressInstanceFarmingHideMessage = true
    frame:Hide()
    frame.suppressInstanceFarmingHideMessage = nil
end

local function HideTransientExplorerUI()
    if GameTooltip and type(GameTooltip.Hide) == "function" then
        GameTooltip:Hide()
    end
    if type(CloseDropDownMenus) == "function" then
        CloseDropDownMenus()
    end
end

local function HideExplorerChildFrames(addon, activeFrame)
    local function hideIfInactive(frame)
        if frame and frame ~= activeFrame then
            HideExplorerChildFrame(frame)
        end
    end

    hideIfInactive(addon.rareFarmingFrame)
    hideIfInactive(addon.instanceFarmingFrame)
    hideIfInactive(addon.craftingFarmingFrame)
    hideIfInactive(addon.observedDropsFrame)
    hideIfInactive(addon.inventoryFrame)
    hideIfInactive(addon.priceIncreaseAlertsFrame)
end

local function ShowEmbeddedFrame(addon, frame)
    if not addon.explorerFrame or not frame then
        return
    end

    HideExplorerChildFrames(addon, frame)
    EmbedChildFrame(frame, addon.explorerFrame.contentFrame)
    frame.suppressExplorerOnShow = true
    frame:Show()
    frame.suppressExplorerOnShow = nil
    if frame.Raise then
        frame:Raise()
    end
    RaiseEmbeddedWindowParts(frame)
    RefreshActiveExplorerChildStack(addon)
end

local function ConfigureRareExplorerTabs(addon, masterTabID)
    local frame = addon.rareFarmingFrame
    if not frame then
        return
    end

    local showFavoritesOnly = masterTabID == "favorites"
    SetFrameShown(frame.librarySavedTabButton, not showFavoritesOnly)
    SetFrameShown(frame.libraryFavoritesTabButton, false)
    SetFrameShown(frame.libraryNewScanButton, not showFavoritesOnly)
    if not showFavoritesOnly then
        AnchorExplorerSubTab(frame.librarySavedTabButton)
        AnchorExplorerSubTab(frame.libraryNewScanButton, frame.librarySavedTabButton)
    end
end

local function ConfigureInstanceExplorerTabs(addon)
    local frame = addon.instanceFarmingFrame
    if not frame then
        return
    end

    SetFrameShown(frame.savedTabButton, true)
    SetFrameShown(frame.favoritesTabButton, false)
    SetFrameShown(frame.newScanTabButton, true)
    AnchorExplorerSubTab(frame.savedTabButton)
    AnchorExplorerSubTab(frame.newScanTabButton, frame.savedTabButton)
end

function GoldTracker:GetExplorerTabDefinitions()
    return EXPLORER_TABS
end

function GoldTracker:RefreshExplorerTabs()
    local frame = self.explorerFrame
    if not frame or type(frame.tabButtons) ~= "table" then
        return
    end

    local activeTabID = frame.activeTabID and NormalizeExplorerTab(frame.activeTabID) or nil
    for tabID, button in pairs(frame.tabButtons) do
        if button.SetSelected then
            button:SetSelected(tabID == activeTabID)
        end
    end
end

function GoldTracker:SetExplorerTab(tabID)
    local frame = self.explorerFrame
    if not frame then
        return
    end

    HideTransientExplorerUI()

    local normalizedTabID = NormalizeExplorerTab(tabID)
    frame.activeTabID = normalizedTabID
    if self.db then
        self.db.explorerTab = normalizedTabID
    end
    self:RefreshExplorerTabs()

    if normalizedTabID == "instances" then
        self:CreateInstanceFarmingWindow()
        ShowEmbeddedFrame(self, self.instanceFarmingFrame)
        if self.instanceFarmingFrame then
            if self.instanceFarmingFrame.scanState then
                self:SetInstanceFarmingWindowView("scan")
            else
                self.instanceFarmingFrame.instanceFarmingLibraryTab = "saved"
                self.instanceFarmingFrame.instanceFarmingNavigationTab = "saved"
                self:SetInstanceFarmingWindowView("library")
            end
            ConfigureInstanceExplorerTabs(self)
        end
        return
    end

    if normalizedTabID == "materials" then
        self:CreateCraftingFarmingWindow()
        ShowEmbeddedFrame(self, self.craftingFarmingFrame)
        self:RefreshCraftingFarmingWindow(true)
        return
    end

    if normalizedTabID == "drops" then
        self:CreateObservedDropsWindow()
        ShowEmbeddedFrame(self, self.observedDropsFrame)
        if self.observedDropsFrame then
            if type(self.SetObservedDropsWindowView) == "function" then
                self:SetObservedDropsWindowView("library")
                self:RefreshObservedDropsSavedScansWindow()
            elseif type(self.RefreshObservedDropsWindow) == "function" then
                self:RefreshObservedDropsWindow(true)
            end
        end
        return
    end

    if normalizedTabID == "inventory" then
        self:CreateInventoryWindow()
        ShowEmbeddedFrame(self, self.inventoryFrame)
        self:RefreshInventoryWindow(true)
        return
    end

    if normalizedTabID == "priceAlerts" then
        self:CreatePriceIncreaseAlertsWindow()
        ShowEmbeddedFrame(self, self.priceIncreaseAlertsFrame)
        self:RefreshPriceIncreaseAlertsWindow(true)
        return
    end

    self:CreateRareFarmingWindow()
    ShowEmbeddedFrame(self, self.rareFarmingFrame)
    if not self.rareFarmingFrame then
        return
    end

    if normalizedTabID == "favorites" then
        self.rareFarmingFrame.rareFarmingLibraryTab = "favorites"
        self.rareFarmingFrame.rareFarmingNavigationTab = "favorites"
        self:SetRareFarmingWindowView("library")
        self:RefreshRareFarmingLibraryWindow()
        ConfigureRareExplorerTabs(self, normalizedTabID)
    elseif self.rareFarmingFrame.scanState then
        self:SetRareFarmingWindowView("scan")
        ConfigureRareExplorerTabs(self, normalizedTabID)
    else
        self.rareFarmingFrame.rareFarmingLibraryTab = "saved"
        self.rareFarmingFrame.rareFarmingNavigationTab = "saved"
        self:SetRareFarmingWindowView("library")
        ConfigureRareExplorerTabs(self, normalizedTabID)
    end
end

function GoldTracker:CreateExplorerWindow()
    if self.explorerFrame then
        return
    end

    local addon = self
    local frame = CreateFrame("Frame", "GoldTrackerExplorerFrame", UIParent, "BasicFrameTemplateWithInset")
    frame:SetSize(EXPLORER_WINDOW_WIDTH, EXPLORER_WINDOW_HEIGHT)
    frame:SetPoint("CENTER", UIParent, "CENTER", 0, 30)
    frame:SetFrameStrata("DIALOG")
    if frame.SetToplevel then
        frame:SetToplevel(true)
    end
    frame:SetMovable(true)
    frame:SetResizable(true)
    if frame.SetResizeBounds then
        frame:SetResizeBounds(
            EXPLORER_WINDOW_MIN_WIDTH,
            EXPLORER_WINDOW_MIN_HEIGHT,
            EXPLORER_WINDOW_MAX_WIDTH,
            EXPLORER_WINDOW_MAX_HEIGHT
        )
    end
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnMouseDown", function(self)
        self:Raise()
        RefreshActiveExplorerChildStack(addon)
    end)
    frame:SetScript("OnDragStart", function(self)
        self:Raise()
        RefreshActiveExplorerChildStack(addon)
        self:StartMoving()
    end)
    frame:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        RefreshActiveExplorerChildStack(addon)
    end)
    frame:SetClampedToScreen(true)
    frame:Hide()

    local chrome = Theme:ApplyWindowChrome(frame, "Explorer")
    Theme:RegisterSpecialFrame("GoldTrackerExplorerFrame")

    frame.tabButtons = {}
    local previousButton = nil
    for _, tab in ipairs(EXPLORER_TABS) do
        local button = CreateExplorerButton(frame, 104, 24, tab.label, "neutral")
        if previousButton then
            button:SetPoint("LEFT", previousButton, "RIGHT", 8, 0)
        else
            button:SetPoint("TOPLEFT", chrome, "TOPLEFT", 12, -54)
        end
        button:SetScript("OnClick", function()
            addon:SetExplorerTab(tab.id)
        end)
        frame.tabButtons[tab.id] = button
        previousButton = button
    end

    local contentFrame = CreateFrame("Frame", nil, frame)
    SetExplorerFrameLevel(contentFrame, chrome, 2)
    contentFrame:SetPoint("TOPLEFT", chrome, "TOPLEFT", 12, -86)
    contentFrame:SetPoint("BOTTOMRIGHT", chrome, "BOTTOMRIGHT", -12, 38)
    frame.contentFrame = contentFrame

    for _, button in pairs(frame.tabButtons) do
        SetExplorerFrameLevel(button, chrome, 3)
    end

    Theme:CreateResizeButton(frame, {
        minWidth = EXPLORER_WINDOW_MIN_WIDTH,
        minHeight = EXPLORER_WINDOW_MIN_HEIGHT,
        maxWidth = EXPLORER_WINDOW_MAX_WIDTH,
        maxHeight = EXPLORER_WINDOW_MAX_HEIGHT,
        onResizeStop = function()
            RefreshActiveExplorerChildStack(addon)
            if addon.rareFarmingFrame and addon.rareFarmingFrame:IsShown() then
                addon:RefreshRareFarmingWindow(false)
                addon:RefreshRareFarmingLibraryWindow()
            end
            if addon.instanceFarmingFrame and addon.instanceFarmingFrame:IsShown() then
                addon:RefreshInstanceFarmingWindow(false)
                addon:RefreshInstanceFarmingLibraryWindow()
            end
            if addon.craftingFarmingFrame and addon.craftingFarmingFrame:IsShown() then
                addon:RefreshCraftingFarmingWindowLayout()
                addon:RefreshCraftingFarmingWindow(false)
            end
            if addon.observedDropsFrame and addon.observedDropsFrame:IsShown() then
                addon:RefreshObservedDropsWindowLayout()
                addon:RefreshObservedDropsWindow(false)
            end
            if addon.inventoryFrame and addon.inventoryFrame:IsShown() then
                addon:RefreshInventoryWindowLayout()
                addon:RefreshInventoryWindow(false)
            end
            if addon.priceIncreaseAlertsFrame and addon.priceIncreaseAlertsFrame:IsShown() then
                addon:RefreshPriceIncreaseAlertsWindowLayout()
                addon:RefreshPriceIncreaseAlertsWindow(false)
            end
        end,
    })

    frame:SetScript("OnShow", function()
        if frame.suppressExplorerOnShow then
            return
        end
        addon:SetExplorerTab("favorites")
    end)
    frame:SetScript("OnHide", function()
        HideExplorerChildFrames(addon)
        HideTransientExplorerUI()
    end)

    self.explorerFrame = frame
    self:RefreshExplorerTabs()
end

function GoldTracker:OpenExplorerWindow(tabID)
    self:CreateExplorerWindow()
    if not self.explorerFrame then
        return
    end

    self.explorerFrame.suppressExplorerOnShow = true
    self.explorerFrame:Show()
    self.explorerFrame.suppressExplorerOnShow = nil
    self.explorerFrame:Raise()
    RefreshActiveExplorerChildStack(self)
    if tabID then
        self:SetExplorerTab(tabID)
    else
        self:SetExplorerTab("favorites")
    end
end

function GoldTracker:ToggleExplorerWindow(tabID)
    self:CreateExplorerWindow()
    if not self.explorerFrame then
        return
    end

    if self.explorerFrame:IsShown() and not tabID then
        self.explorerFrame:Hide()
    else
        self:OpenExplorerWindow(tabID)
    end
end
