local _, NS = ...

local JanisTheme = _G.JanisTheme
if type(JanisTheme) ~= "table" or type(JanisTheme.New) ~= "function" then
    error("General Gold Tracker requires JanisTheme-1.0. Check General-Gold-Tracker.toc load order.")
end

NS.JanisThemeClass = JanisTheme
NS.JanisTheme = NS.JanisTheme or JanisTheme:New({
    addon = NS.GoldTracker,
    assetRoot = "Interface\\AddOns\\General-Gold-Tracker\\Libs\\JanisTheme-1.0\\Assets\\",
})

local Theme = NS.JanisTheme

local ADDON_WINDOW_RESTING_STRATA = "HIGH"
local DEFAULT_ACTIVE_STRATA = "DIALOG"
local FOCUS_LEVEL_START = 100
local FOCUS_LEVEL_STEP = 10
local FOCUS_LEVEL_LIMIT = 900

local STRATA_ORDER = {
    BACKGROUND = 1,
    LOW = 2,
    MEDIUM = 3,
    HIGH = 4,
    DIALOG = 5,
    FULLSCREEN = 6,
    FULLSCREEN_DIALOG = 7,
    TOOLTIP = 8,
}

local COMMON_EXTERNAL_WINDOW_NAMES = {
    "WorldMapFrame",
    "AuctionHouseFrame",
    "CharacterFrame",
    "CollectionsJournal",
    "EncounterJournal",
    "FriendsFrame",
    "GameMenuFrame",
    "GuildFrame",
    "PVEFrame",
    "PlayerSpellsFrame",
    "ProfessionsFrame",
    "QuestLogPopupDetailFrame",
    "SettingsPanel",
    "SpellBookFrame",
    "TradeSkillFrame",
}

local BaseApplyWindowChrome = Theme.ApplyWindowChrome
local BaseCreateButton = Theme.CreateButton

local function IsFrameShown(frame)
    if not frame then
        return false
    end
    if type(frame.IsShown) == "function" then
        return frame:IsShown()
    end
    return true
end

local function GetFrameStrata(frame, fallback)
    if frame and type(frame.GetFrameStrata) == "function" then
        return frame:GetFrameStrata() or fallback
    end
    return fallback
end

local function GetFrameLevel(frame, fallback)
    if frame and type(frame.GetFrameLevel) == "function" then
        return tonumber(frame:GetFrameLevel()) or fallback
    end
    return fallback
end

local function GetFrameName(frame)
    if frame and type(frame.GetName) == "function" then
        return frame:GetName()
    end
    return nil
end

local function GetCurrentMouseFocus()
    if type(GetMouseFoci) == "function" then
        local focusValues = { GetMouseFoci() }
        local firstFocus = focusValues[1]
        if type(firstFocus) == "table" and type(firstFocus.GetParent) ~= "function" then
            return firstFocus[1]
        end
        return firstFocus
    end
    if type(GetMouseFocus) == "function" then
        return GetMouseFocus()
    end
    return nil
end

local function ResolveActiveStrata(frame, fallback)
    local originalStrata = GetFrameStrata(frame, fallback or DEFAULT_ACTIVE_STRATA)
    if (STRATA_ORDER[originalStrata] or 0) > (STRATA_ORDER[DEFAULT_ACTIVE_STRATA] or 0) then
        return originalStrata
    end
    return DEFAULT_ACTIVE_STRATA
end

function Theme:EnsureWindowFocusState()
    self.windowFocusFrames = self.windowFocusFrames or {}
    self.addonFocusFrames = self.addonFocusFrames or {}
    self.externalFocusWindowNames = self.externalFocusWindowNames or {}
    self.windowFocusLevel = tonumber(self.windowFocusLevel) or FOCUS_LEVEL_START
end

function Theme:IsKnownExternalWindow(frame)
    local frameName = GetFrameName(frame)
    if type(frameName) ~= "string" or frameName == "" then
        return false
    end

    self:EnsureWindowFocusState()
    if self.externalFocusWindowNames[frameName] then
        return true
    end

    return type(_G.UIPanelWindows) == "table" and _G.UIPanelWindows[frameName] ~= nil
end

function Theme:RegisterWindowForFocus(frame, role, options)
    if not frame then
        return nil
    end

    self:EnsureWindowFocusState()
    options = type(options) == "table" and options or {}
    role = role or "addon"

    if not frame.goldTrackerWindowFocusRegistered then
        frame.goldTrackerWindowOriginalStrata = GetFrameStrata(frame, DEFAULT_ACTIVE_STRATA)
        frame.goldTrackerWindowOriginalLevel = GetFrameLevel(frame, 0)
        frame.goldTrackerWindowFocusRegistered = true
    end

    frame.goldTrackerManagedWindow = frame
    frame.goldTrackerWindowFocusRole = role
    frame.goldTrackerWindowActiveStrata = options.activeStrata
        or ResolveActiveStrata(frame, role == "external" and DEFAULT_ACTIVE_STRATA or frame.goldTrackerWindowOriginalStrata)
    frame.goldTrackerWindowRestingStrata = options.restingStrata or ADDON_WINDOW_RESTING_STRATA

    self.windowFocusFrames[frame] = true
    if role == "addon" then
        self.addonFocusFrames[frame] = true
    end

    if type(frame.HookScript) == "function" and not frame.goldTrackerWindowFocusHooked then
        frame.goldTrackerWindowFocusHooked = true
        local theme = self
        frame:HookScript("OnMouseDown", function(clickedFrame)
            theme:BringManagedWindowToFront(clickedFrame)
        end)
        frame:HookScript("OnDragStart", function(clickedFrame)
            theme:BringManagedWindowToFront(clickedFrame)
        end)
        frame:HookScript("OnShow", function(shownFrame)
            theme:BringManagedWindowToFront(shownFrame)
        end)
        if role == "external" then
            frame:HookScript("OnHide", function(hiddenFrame)
                theme:RestoreExternalWindowFocusState(hiddenFrame)
            end)
        end
    end

    self:EnsureWindowFocusWatcher()
    return frame
end

function Theme:RegisterExternalWindowForFocus(frame)
    return self:RegisterWindowForFocus(frame, "external")
end

function Theme:RegisterExternalFocusFrames(frameNames)
    self:EnsureWindowFocusState()
    for _, frameName in ipairs(frameNames or COMMON_EXTERNAL_WINDOW_NAMES) do
        if type(frameName) == "string" and frameName ~= "" then
            self.externalFocusWindowNames[frameName] = true
        end
    end
    self:RefreshExternalFocusFrames()
end

function Theme:RefreshExternalFocusFrames()
    self:EnsureWindowFocusState()
    for frameName in pairs(self.externalFocusWindowNames) do
        local frame = _G[frameName]
        if frame then
            self:RegisterExternalWindowForFocus(frame)
        end
    end
end

function Theme:FindFocusableWindow(frame)
    local current = frame
    while current do
        if current.goldTrackerManagedWindow then
            return current.goldTrackerManagedWindow
        end
        if self:IsKnownExternalWindow(current) then
            self:RegisterExternalWindowForFocus(current)
            return current
        end
        if type(current.GetParent) ~= "function" then
            return nil
        end
        current = current:GetParent()
    end
    return nil
end

function Theme:DemoteInactiveAddonWindows(activeFrame)
    self:EnsureWindowFocusState()
    for frame in pairs(self.addonFocusFrames) do
        local managedFrame = frame.goldTrackerManagedWindow or frame
        if frame ~= activeFrame
            and managedFrame ~= activeFrame
            and IsFrameShown(frame)
            and type(frame.SetFrameStrata) == "function" then
            frame:SetFrameStrata(frame.goldTrackerWindowRestingStrata or ADDON_WINDOW_RESTING_STRATA)
        end
    end
end

function Theme:GetNextFocusFrameLevel()
    self.windowFocusLevel = (tonumber(self.windowFocusLevel) or FOCUS_LEVEL_START) + FOCUS_LEVEL_STEP
    if self.windowFocusLevel > FOCUS_LEVEL_LIMIT then
        self.windowFocusLevel = FOCUS_LEVEL_START + FOCUS_LEVEL_STEP
    end
    return self.windowFocusLevel
end

function Theme:BringManagedWindowToFront(frame)
    if not frame then
        return nil
    end

    self:EnsureWindowFocusState()
    local managedFrame = frame.goldTrackerManagedWindow
    if managedFrame and managedFrame ~= frame then
        frame = managedFrame
    end

    if not frame.goldTrackerWindowFocusRole and self:IsKnownExternalWindow(frame) then
        self:RegisterExternalWindowForFocus(frame)
    end

    self:DemoteInactiveAddonWindows(frame)

    local activeStrata = frame.goldTrackerWindowActiveStrata or ResolveActiveStrata(frame, DEFAULT_ACTIVE_STRATA)
    if type(frame.SetFrameStrata) == "function" then
        frame:SetFrameStrata(activeStrata)
    end
    if type(frame.SetToplevel) == "function" then
        frame:SetToplevel(true)
    end
    if type(frame.SetFrameLevel) == "function" then
        frame:SetFrameLevel(math.max(self:GetNextFocusFrameLevel(), GetFrameLevel(frame, 0) + FOCUS_LEVEL_STEP))
    end
    if type(frame.Raise) == "function" then
        frame:Raise()
    end

    return frame
end

function Theme:RestoreExternalWindowFocusState(frame)
    if not frame or frame.goldTrackerWindowFocusRole ~= "external" then
        return
    end
    if type(frame.SetFrameStrata) == "function" and frame.goldTrackerWindowOriginalStrata then
        frame:SetFrameStrata(frame.goldTrackerWindowOriginalStrata)
    end
    if type(frame.SetFrameLevel) == "function" and frame.goldTrackerWindowOriginalLevel then
        frame:SetFrameLevel(frame.goldTrackerWindowOriginalLevel)
    end
end

function Theme:EnsureWindowFocusWatcher()
    if self.windowFocusWatcher or type(CreateFrame) ~= "function" then
        return
    end

    local watcher = CreateFrame("Frame")
    if not watcher or type(watcher.SetScript) ~= "function" then
        return
    end

    local theme = self
    watcher:SetScript("OnUpdate", function(self)
        if type(IsMouseButtonDown) ~= "function" then
            return
        end

        local leftButtonDown = IsMouseButtonDown("LeftButton") == true
        if leftButtonDown and not self.goldTrackerLeftButtonWasDown then
            theme:RefreshExternalFocusFrames()
            local focusWindow = theme:FindFocusableWindow(GetCurrentMouseFocus())
            if focusWindow then
                theme:BringManagedWindowToFront(focusWindow)
            end
        end
        self.goldTrackerLeftButtonWasDown = leftButtonDown
    end)
    self.windowFocusWatcher = watcher
end

function Theme:ApplyWindowChrome(frame, titleText, options)
    local chrome, headerBar = BaseApplyWindowChrome(self, frame, titleText, options)
    self:RegisterWindowForFocus(frame, "addon")
    return chrome, headerBar
end

function Theme:CreateButton(parent, width, height, text, paletteKey)
    local button = BaseCreateButton(self, parent, width, height, text, paletteKey)
    if button and type(button.HookScript) == "function" then
        local theme = self
        button:HookScript("OnMouseDown", function(clickedButton)
            local focusWindow = theme:FindFocusableWindow(clickedButton)
            if focusWindow then
                theme:BringManagedWindowToFront(focusWindow)
            end
        end)
    end
    return button
end

Theme:RegisterExternalFocusFrames(COMMON_EXTERNAL_WINDOW_NAMES)

local function GetCursorPointForFrame(frame)
    if type(GetCursorPosition) ~= "function" then
        return nil, nil
    end

    local cursorX, cursorY = GetCursorPosition()
    if not cursorX or not cursorY then
        return nil, nil
    end

    local parent = frame and frame:GetParent() or UIParent
    local scale = parent and parent.GetEffectiveScale and parent:GetEffectiveScale()
    if not scale or scale == 0 then
        scale = UIParent and UIParent.GetEffectiveScale and UIParent:GetEffectiveScale() or 1
    end

    return cursorX / scale, cursorY / scale
end

local function ResolveResizeBounds(options)
    if type(options.getBounds) == "function" then
        local minWidth, minHeight, maxWidth, maxHeight = options.getBounds()
        return tonumber(minWidth), tonumber(minHeight), tonumber(maxWidth), tonumber(maxHeight)
    end

    return tonumber(options.minWidth), tonumber(options.minHeight), tonumber(options.maxWidth), tonumber(options.maxHeight)
end

local function ClampResizeValue(value, minimum, maximum)
    value = tonumber(value) or 1
    if minimum then
        value = math.max(minimum, value)
    end
    if maximum then
        value = math.min(maximum, value)
    end
    return math.floor(value + 0.5)
end

local function AnchorFrameTopLeft(frame)
    if not frame or type(frame.GetLeft) ~= "function" or type(frame.GetTop) ~= "function" then
        return
    end

    local left = frame:GetLeft()
    local top = frame:GetTop()
    if not left or not top then
        return
    end

    local parent = frame:GetParent() or UIParent
    local parentLeft = parent and parent.GetLeft and parent:GetLeft() or 0
    local parentBottom = parent and parent.GetBottom and parent:GetBottom() or 0
    frame:ClearAllPoints()
    frame:SetPoint("TOPLEFT", parent, "BOTTOMLEFT", left - parentLeft, top - parentBottom)
end

function Theme:CreateResizeButton(frame, options)
    if not frame then
        return nil
    end

    options = type(options) == "table" and options or {}

    local resizeButton = CreateFrame("Button", nil, frame)
    resizeButton:SetSize(options.size or 16, options.size or 16)
    resizeButton:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", options.offsetX or -8, options.offsetY or 8)
    resizeButton:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")
    resizeButton:SetHighlightTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Highlight")
    resizeButton:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Down")
    resizeButton:SetAlpha(options.alpha or 0.7)

    local dragState = nil

    local function StopResize()
        if not dragState then
            return
        end

        dragState = nil
        frame.isManualResizing = false
        resizeButton:SetScript("OnUpdate", nil)
        if resizeButton.UnlockHighlight then
            resizeButton:UnlockHighlight()
        end
        if frame.StopMovingOrSizing then
            frame:StopMovingOrSizing()
        end
        if type(options.onResizeStop) == "function" then
            options.onResizeStop(frame)
        end
    end

    local function UpdateResize()
        if not dragState then
            return
        end
        if type(IsMouseButtonDown) == "function" and not IsMouseButtonDown("LeftButton") then
            StopResize()
            return
        end

        local cursorX, cursorY = GetCursorPointForFrame(frame)
        if not cursorX or not cursorY then
            return
        end

        local minWidth, minHeight, maxWidth, maxHeight = ResolveResizeBounds(options)
        local width = ClampResizeValue(dragState.width + (cursorX - dragState.cursorX), minWidth, maxWidth)
        local height = ClampResizeValue(dragState.height - (cursorY - dragState.cursorY), minHeight, maxHeight)

        if width ~= dragState.lastWidth or height ~= dragState.lastHeight then
            dragState.lastWidth = width
            dragState.lastHeight = height
            frame:SetSize(width, height)
        end
    end

    resizeButton:SetScript("OnMouseDown", function(_, button)
        if button ~= "LeftButton" then
            return
        end

        local cursorX, cursorY = GetCursorPointForFrame(frame)
        if not cursorX or not cursorY then
            return
        end

        if type(Theme.BringManagedWindowToFront) == "function" then
            Theme:BringManagedWindowToFront(frame)
        elseif frame.Raise then
            frame:Raise()
        end
        if type(options.onResizeStart) == "function" then
            options.onResizeStart(frame)
        end

        local width, height = frame:GetSize()
        AnchorFrameTopLeft(frame)
        dragState = {
            cursorX = cursorX,
            cursorY = cursorY,
            width = tonumber(width) or 1,
            height = tonumber(height) or 1,
            lastWidth = tonumber(width) or 1,
            lastHeight = tonumber(height) or 1,
        }

        frame.isManualResizing = true
        if resizeButton.LockHighlight then
            resizeButton:LockHighlight()
        end
        resizeButton:SetScript("OnUpdate", UpdateResize)
    end)
    resizeButton:SetScript("OnMouseUp", StopResize)
    resizeButton:SetScript("OnHide", StopResize)

    frame.resizeButton = resizeButton
    return resizeButton
end
