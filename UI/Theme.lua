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

local function IsForbiddenFrame(frame)
    return frame and type(frame.IsForbidden) == "function" and frame:IsForbidden()
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
    self.addonFocusFrames = self.addonFocusFrames or {}
    self.windowFocusLevel = tonumber(self.windowFocusLevel) or FOCUS_LEVEL_START
end

function Theme:RegisterWindowForFocus(frame, role, options)
    -- Only explicitly registered GGT windows belong to this manager. Never
    -- discover or hook Blizzard/other-addon windows through UIPanelWindows.
    if not frame or IsForbiddenFrame(frame) or (role and role ~= "addon") then
        return nil
    end

    self:EnsureWindowFocusState()
    options = type(options) == "table" and options or {}

    if not frame.goldTrackerWindowFocusRegistered then
        frame.goldTrackerWindowOriginalStrata = GetFrameStrata(frame, DEFAULT_ACTIVE_STRATA)
        frame.goldTrackerWindowFocusRegistered = true
    end

    frame.goldTrackerManagedWindow = frame
    frame.goldTrackerWindowActiveStrata = options.activeStrata
        or ResolveActiveStrata(frame, frame.goldTrackerWindowOriginalStrata)
    frame.goldTrackerWindowRestingStrata = options.restingStrata or ADDON_WINDOW_RESTING_STRATA

    self.addonFocusFrames[frame] = true

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
    end

    self:EnsureWindowFocusWatcher()
    return frame
end

function Theme:FindFocusableWindow(frame)
    local ownedFrames = self.addonFocusFrames
    if not ownedFrames then
        return nil
    end
    local current = frame
    while current do
        if IsForbiddenFrame(current) then
            return nil
        end
        if ownedFrames[current] then
            -- Explorer embeds registered GGT panels under its own window.
            local owner = current.goldTrackerManagedWindow or current
            if ownedFrames[owner] and not IsForbiddenFrame(owner) then
                return owner
            end
            return nil
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
    frame = self:FindFocusableWindow(frame)
    if not frame then
        return nil
    end

    self:EnsureWindowFocusState()
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

function Theme:EnsureWindowFocusWatcher()
    if self.windowFocusWatcher or type(CreateFrame) ~= "function" then
        return
    end

    local watcher = CreateFrame("Frame")
    if not watcher or type(watcher.SetScript) ~= "function" or type(watcher.RegisterEvent) ~= "function" then
        return
    end

    local theme = self
    watcher:RegisterEvent("GLOBAL_MOUSE_DOWN")
    watcher:SetScript("OnEvent", function(_, event, button)
        if event ~= "GLOBAL_MOUSE_DOWN" or button ~= "LeftButton" then
            return
        end
        local focusWindow = theme:FindFocusableWindow(GetCurrentMouseFocus())
        if focusWindow then
            theme:BringManagedWindowToFront(focusWindow)
        else
            -- Yield only our own windows when the player interacts elsewhere.
            theme:DemoteInactiveAddonWindows(nil)
        end
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

Theme.EXPLORER_LIST_LAYOUT = Theme.EXPLORER_LIST_LAYOUT or {
    panelInset = 14,
    fieldGap = 24,
    labelTop = -10,
    controlTop = -27,
    controlHeight = 22,
    actionGap = 8,
    actionBottom = 12,
    tabGap = 8,
    tabHeight = 24,
    widths = {
        valueSource = 210,
        wideDropdown = 210,
        expansion = 190,
        dropdown = 190,
        compactDropdown = 120,
        valueInput = 96,
        search = 280,
    },
}

function Theme:GetExplorerListLayout()
    return self.EXPLORER_LIST_LAYOUT
end

function Theme:LayoutExplorerFilterFields(panel, fields, options)
    if not panel then
        return
    end

    local layout = self:GetExplorerListLayout()
    options = type(options) == "table" and options or {}
    local left = tonumber(options.left) or layout.panelInset
    local row = math.max(1, math.floor(tonumber(options.row) or 1))
    local rowOffset = (row - 1) * (tonumber(options.rowStride) or 52)
    local gap = tonumber(options.gap) or layout.fieldGap

    for _, field in ipairs(type(fields) == "table" and fields or {}) do
        local label = field.label
        local control = field.control
        local width = math.max(
            1,
            tonumber(field.width)
                or tonumber(type(field.widthKey) == "string" and layout.widths[field.widthKey])
                or layout.widths.dropdown
        )
        if label and control then
            if type(label.ClearAllPoints) == "function" then
                label:ClearAllPoints()
            end
            label:SetPoint("TOPLEFT", panel, "TOPLEFT", left, layout.labelTop - rowOffset)

            if type(control.ClearAllPoints) == "function" then
                control:ClearAllPoints()
            end
            local isDropdown = field.kind == "dropdown"
            control:SetPoint(
                "TOPLEFT",
                panel,
                "TOPLEFT",
                left + (isDropdown and -16 or 0),
                layout.controlTop - rowOffset
            )
            if isDropdown and type(UIDropDownMenu_SetWidth) == "function" then
                UIDropDownMenu_SetWidth(control, width)
            elseif type(control.SetWidth) == "function" then
                control:SetWidth(width)
            end
            if not isDropdown and type(control.SetHeight) == "function" then
                control:SetHeight(tonumber(field.height) or layout.controlHeight)
            end
        end
        left = left + width + gap
    end
end

function Theme:LayoutExplorerActionButtons(panel, buttons, options)
    if not panel then
        return
    end

    local layout = self:GetExplorerListLayout()
    options = type(options) == "table" and options or {}
    local gap = tonumber(options.gap) or layout.actionGap
    local previousButton
    for _, button in ipairs(type(buttons) == "table" and buttons or {}) do
        if button then
            if type(button.ClearAllPoints) == "function" then
                button:ClearAllPoints()
            end
            if previousButton then
                button:SetPoint("RIGHT", previousButton, "LEFT", -gap, 0)
            elseif options.top then
                button:SetPoint(
                    "TOPRIGHT",
                    panel,
                    "TOPRIGHT",
                    tonumber(options.offsetX) or -layout.panelInset,
                    tonumber(options.offsetY) or layout.controlTop
                )
            else
                button:SetPoint(
                    "BOTTOMRIGHT",
                    panel,
                    "BOTTOMRIGHT",
                    tonumber(options.offsetX) or -layout.panelInset,
                    tonumber(options.offsetY) or layout.actionBottom
                )
            end
            previousButton = button
        end
    end
end

function Theme:LayoutExplorerTabs(chrome, buttons, options)
    if not chrome then
        return
    end

    local layout = self:GetExplorerListLayout()
    options = type(options) == "table" and options or {}
    local previousButton
    for _, button in ipairs(type(buttons) == "table" and buttons or {}) do
        if button then
            if type(button.ClearAllPoints) == "function" then
                button:ClearAllPoints()
            end
            if previousButton then
                button:SetPoint("LEFT", previousButton, "RIGHT", tonumber(options.gap) or layout.tabGap, 0)
            else
                button:SetPoint(
                    "TOPLEFT",
                    chrome,
                    "TOPLEFT",
                    tonumber(options.left) or layout.panelInset,
                    tonumber(options.top) or -54
                )
            end
            if type(button.SetHeight) == "function" then
                button:SetHeight(tonumber(options.height) or layout.tabHeight)
            end
            previousButton = button
        end
    end
end

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
    if options.maximize == true and type(self.CreateMaximizeButton) == "function" then
        self:CreateMaximizeButton(frame, {
            onToggle = options.onResizeStop,
        })
    end
    return resizeButton
end

local function CaptureFramePoints(frame)
    local points = {}
    if not frame or type(frame.GetPoint) ~= "function" then
        return points
    end

    local pointCount = type(frame.GetNumPoints) == "function" and tonumber(frame:GetNumPoints()) or 1
    pointCount = math.max(0, math.floor(pointCount or 0))
    for index = 1, pointCount do
        local point, relativeTo, relativePoint, offsetX, offsetY = frame:GetPoint(index)
        if point then
            points[#points + 1] = {
                point = point,
                relativeTo = relativeTo,
                relativePoint = relativePoint,
                offsetX = offsetX,
                offsetY = offsetY,
            }
        end
    end
    return points
end

local function RestoreFramePoints(frame, points, parent)
    frame:ClearAllPoints()
    if type(points) == "table" and #points > 0 then
        for _, savedPoint in ipairs(points) do
            frame:SetPoint(
                savedPoint.point,
                savedPoint.relativeTo,
                savedPoint.relativePoint,
                savedPoint.offsetX,
                savedPoint.offsetY
            )
        end
        return
    end
    frame:SetPoint("CENTER", parent or UIParent, "CENTER", 0, 0)
end

local function SetMaximizeButtonState(frame, isMaximized)
    local button = frame and frame.maximizeButton
    if not button then
        return
    end

    local options = frame.goldTrackerMaximizeOptions or {}
    button:SetText(isMaximized and (options.restoreText or "Restore") or (options.maximizeText or "Maximize"))
    button.tooltipText = isMaximized
        and (options.restoreTooltip or "Restore the list window to its previous size and position.")
        or (options.maximizeTooltip or "Maximize the list window.")
end

function Theme:SetWindowMaximized(frame, shouldMaximize)
    if not frame then
        return false
    end

    local options = frame.goldTrackerMaximizeOptions or {}
    local parent = options.parent or UIParent or (type(frame.GetParent) == "function" and frame:GetParent())
    local maximize = shouldMaximize == true
    if maximize == (frame.goldTrackerIsMaximized == true) then
        SetMaximizeButtonState(frame, maximize)
        return maximize
    end

    if maximize then
        local width, height = frame:GetSize()
        frame.goldTrackerRestoreState = {
            width = tonumber(width),
            height = tonumber(height),
            points = CaptureFramePoints(frame),
            movable = type(frame.IsMovable) == "function" and frame:IsMovable() or true,
            resizable = type(frame.IsResizable) == "function" and frame:IsResizable() or false,
        }
        frame.goldTrackerIsMaximized = true
        frame:ClearAllPoints()
        local padding = math.max(0, tonumber(options.padding) or 18)
        frame:SetPoint("TOPLEFT", parent, "TOPLEFT", padding, -padding)
        frame:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", -padding, padding)
        if type(frame.SetMovable) == "function" then
            frame:SetMovable(false)
        end
        if type(frame.SetResizable) == "function" then
            frame:SetResizable(false)
        end
        if frame.resizeButton and type(frame.resizeButton.Hide) == "function" then
            frame.resizeButton:Hide()
        end
    else
        local restoreState = frame.goldTrackerRestoreState or {}
        frame.goldTrackerIsMaximized = false
        frame:ClearAllPoints()
        if restoreState.width and restoreState.height and type(frame.SetSize) == "function" then
            frame:SetSize(restoreState.width, restoreState.height)
        end
        RestoreFramePoints(frame, restoreState.points, parent)
        if type(frame.SetMovable) == "function" then
            frame:SetMovable(restoreState.movable ~= false)
        end
        if type(frame.SetResizable) == "function" then
            frame:SetResizable(restoreState.resizable == true)
        end
        if restoreState.resizable == true and frame.resizeButton and type(frame.resizeButton.Show) == "function" then
            frame.resizeButton:Show()
        end
        frame.goldTrackerRestoreState = nil
    end

    SetMaximizeButtonState(frame, maximize)
    if type(options.onToggle) == "function" then
        options.onToggle(frame, maximize)
    end
    return maximize
end

function Theme:ToggleWindowMaximized(frame)
    return self:SetWindowMaximized(frame, not (frame and frame.goldTrackerIsMaximized == true))
end

function Theme:SetProgressBarProgress(frame, currentValue, maximumValue, completed)
    if not frame or not frame.progressBar then
        return false
    end

    local maximum = math.max(1, tonumber(maximumValue) or 1)
    local current = math.max(0, math.min(maximum, tonumber(currentValue) or 0))
    frame.progressBar:SetMinMaxValues(0, maximum)
    frame.progressBar:SetValue(current)

    local isComplete = completed == nil and current >= maximum or completed == true
    frame.progressComplete = isComplete
    local container = frame.progressBackdrop or frame.progressBar
    if container and type(container.SetShown) == "function" then
        container:SetShown(not isComplete)
    elseif container then
        local visibilityMethod = isComplete and container.Hide or container.Show
        if type(visibilityMethod) == "function" then
            visibilityMethod(container)
        end
    end
    return isComplete
end

function Theme:CreateMaximizeButton(frame, options)
    if not frame then
        return nil
    end
    if frame.maximizeButton then
        return frame.maximizeButton
    end

    options = type(options) == "table" and options or {}
    frame.goldTrackerMaximizeOptions = options

    local parent = options.buttonParent or frame.headerBar or frame
    local button = self:CreateButton(
        parent,
        tonumber(options.width) or 74,
        tonumber(options.height) or 22,
        options.maximizeText or "Maximize",
        options.paletteKey or "neutral"
    )
    local anchor = options.anchor or frame.closeButton
    if anchor then
        button:SetPoint("RIGHT", anchor, "LEFT", tonumber(options.offsetX) or -6, tonumber(options.offsetY) or 0)
    else
        button:SetPoint("TOPRIGHT", parent, "TOPRIGHT", -38, -10)
    end
    button:SetScript("OnClick", function()
        self:ToggleWindowMaximized(frame)
    end)
    frame.maximizeButton = button
    SetMaximizeButtonState(frame, false)

    if frame.headerTitleText and type(frame.headerTitleText.SetPoint) == "function" then
        frame.headerTitleText:SetPoint("RIGHT", button, "LEFT", -10, 0)
    end
    return button
end

function Theme:GetRequiredTextColumnWidth(rows, textKey, minimumWidth, options)
    options = type(options) == "table" and options or {}
    local requiredWidth = math.max(1, tonumber(minimumWidth) or 1)
    local padding = math.max(0, tonumber(options.padding) or 0)
    local leadingWidth = math.max(0, tonumber(options.leadingWidth) or 0)

    for _, row in ipairs(type(rows) == "table" and rows or {}) do
        local isShown = type(row.IsShown) ~= "function" or row:IsShown()
        local fontString = isShown and row[textKey] or nil
        if fontString and type(fontString.IsShown) == "function" and not fontString:IsShown() then
            fontString = nil
        end
        if fontString then
            local textWidth
            if type(fontString.GetUnboundedStringWidth) == "function" then
                local ok, measuredWidth = pcall(fontString.GetUnboundedStringWidth, fontString)
                if ok then
                    textWidth = tonumber(measuredWidth)
                end
            end

            if not textWidth and type(fontString.GetStringWidth) == "function" then
                local originalWidth = type(fontString.GetWidth) == "function" and fontString:GetWidth() or nil
                if originalWidth and type(fontString.SetWidth) == "function" then
                    fontString:SetWidth(10000)
                end
                local ok, measuredWidth = pcall(fontString.GetStringWidth, fontString)
                if originalWidth and type(fontString.SetWidth) == "function" then
                    fontString:SetWidth(originalWidth)
                end
                if ok then
                    textWidth = tonumber(measuredWidth)
                end
            end

            local rowLeadingWidth = leadingWidth
            if type(options.getLeadingWidth) == "function" then
                rowLeadingWidth = math.max(0, tonumber(options.getLeadingWidth(row)) or 0)
            end
            if textWidth then
                requiredWidth = math.max(requiredWidth, math.ceil(textWidth + padding + rowLeadingWidth))
            end
        end
    end

    return requiredWidth
end
