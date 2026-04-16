local _, NS = ...
local GoldTracker = NS.GoldTracker

local DIAGNOSIS_WINDOW_BACKDROP = {
    bgFile = "Interface\\Buttons\\WHITE8X8",
    edgeFile = "Interface\\Buttons\\WHITE8X8",
    edgeSize = 1,
    insets = {
        left = 1,
        right = 1,
        top = 1,
        bottom = 1,
    },
}
local DIAGNOSIS_BUTTON_PALETTES = {
    primary = {
        bg = { 0.18, 0.14, 0.08, 0.96 },
        border = { 0.95, 0.74, 0.18, 0.26 },
        hoverBg = { 0.24, 0.18, 0.08, 0.98 },
        hoverBorder = { 1.0, 0.82, 0.24, 0.50 },
        pressedBg = { 0.12, 0.09, 0.04, 0.98 },
        pressedBorder = { 1.0, 0.82, 0.24, 0.32 },
        text = { 1.0, 0.94, 0.72 },
    },
    neutral = {
        bg = { 0.09, 0.10, 0.14, 0.94 },
        border = { 1.0, 1.0, 1.0, 0.08 },
        hoverBg = { 0.12, 0.13, 0.18, 0.98 },
        hoverBorder = { 1.0, 1.0, 1.0, 0.16 },
        pressedBg = { 0.06, 0.07, 0.10, 0.98 },
        pressedBorder = { 1.0, 1.0, 1.0, 0.10 },
        text = { 0.90, 0.92, 0.98 },
    },
    danger = {
        bg = { 0.19, 0.09, 0.10, 0.96 },
        border = { 1.0, 0.36, 0.38, 0.22 },
        hoverBg = { 0.25, 0.10, 0.11, 0.98 },
        hoverBorder = { 1.0, 0.44, 0.46, 0.40 },
        pressedBg = { 0.12, 0.06, 0.06, 0.98 },
        pressedBorder = { 1.0, 0.44, 0.46, 0.26 },
        text = { 1.0, 0.87, 0.87 },
    },
}

local function ApplyDiagnosisBackdrop(frame, bg, border)
    if not frame or type(frame.SetBackdrop) ~= "function" then
        return
    end

    frame:SetBackdrop(DIAGNOSIS_WINDOW_BACKDROP)
    if type(bg) == "table" then
        frame:SetBackdropColor(bg[1] or 0, bg[2] or 0, bg[3] or 0, bg[4] or 1)
    end
    if type(border) == "table" then
        frame:SetBackdropBorderColor(border[1] or 1, border[2] or 1, border[3] or 1, border[4] or 1)
    end
end

local function CreateDiagnosisPanel(parent, bg, border)
    local panel = CreateFrame("Frame", nil, parent, "BackdropTemplate")
    ApplyDiagnosisBackdrop(panel, bg, border)
    return panel
end

local function UpdateDiagnosisButtonVisual(button)
    if not button or type(button.SetBackdropColor) ~= "function" then
        return
    end

    local palette = button.palette or DIAGNOSIS_BUTTON_PALETTES.neutral
    local bg = palette.bg
    local border = palette.border
    if button.isPressed then
        bg = palette.pressedBg or bg
        border = palette.pressedBorder or border
    elseif button.isHovered then
        bg = palette.hoverBg or bg
        border = palette.hoverBorder or border
    end

    button:SetBackdropColor(bg[1] or 0, bg[2] or 0, bg[3] or 0, bg[4] or 1)
    button:SetBackdropBorderColor(border[1] or 1, border[2] or 1, border[3] or 1, border[4] or 1)
    if button.label then
        local textColor = palette.text or { 1, 1, 1 }
        button.label:SetTextColor(textColor[1] or 1, textColor[2] or 1, textColor[3] or 1)
    end
end

local function CreateDiagnosisButton(parent, width, height, text, paletteKey)
    local button = CreateFrame("Button", nil, parent, "BackdropTemplate")
    button:SetSize(width, height)
    button.palette = DIAGNOSIS_BUTTON_PALETTES[paletteKey] or DIAGNOSIS_BUTTON_PALETTES.neutral
    button:SetBackdrop(DIAGNOSIS_WINDOW_BACKDROP)

    local label = button:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    label:SetPoint("CENTER", button, "CENTER", 0, 0)
    label:SetJustifyH("CENTER")
    button.label = label

    function button:SetText(value)
        self.label:SetText(type(value) == "string" and value or "")
    end

    button:SetText(text)
    button:SetScript("OnEnter", function(self)
        self.isHovered = true
        UpdateDiagnosisButtonVisual(self)
    end)
    button:SetScript("OnLeave", function(self)
        self.isHovered = false
        self.isPressed = false
        UpdateDiagnosisButtonVisual(self)
    end)
    button:SetScript("OnMouseDown", function(self, mouseButton)
        if mouseButton == "LeftButton" then
            self.isPressed = true
            UpdateDiagnosisButtonVisual(self)
        end
    end)
    button:SetScript("OnMouseUp", function(self)
        self.isPressed = false
        UpdateDiagnosisButtonVisual(self)
    end)
    UpdateDiagnosisButtonVisual(button)

    return button
end

local EVENT_COUNTERS = {
    { key = "event_ADDON_LOADED", label = "ADDON_LOADED" },
    { key = "event_CHAT_MSG_LOOT", label = "CHAT_MSG_LOOT" },
    { key = "event_CHAT_MSG_MONEY", label = "CHAT_MSG_MONEY" },
    { key = "event_LOOT_OPENED", label = "LOOT_OPENED" },
    { key = "event_LOOT_CLOSED", label = "LOOT_CLOSED" },
    { key = "event_UNIT_SPELLCAST_SUCCEEDED", label = "UNIT_SPELLCAST_SUCCEEDED" },
    { key = "event_PLAYER_TARGET_CHANGED", label = "PLAYER_TARGET_CHANGED" },
    { key = "event_UPDATE_MOUSEOVER_UNIT", label = "UPDATE_MOUSEOVER_UNIT" },
    { key = "event_NAME_PLATE_UNIT_ADDED", label = "NAME_PLATE_UNIT_ADDED" },
    { key = "event_PLAYER_FOCUS_CHANGED", label = "PLAYER_FOCUS_CHANGED" },
    { key = "event_PLAYER_ENTERING_WORLD", label = "PLAYER_ENTERING_WORLD" },
}

local LOOT_COUNTERS = {
    { key = "loot_chat_seen", label = "Loot chat seen" },
    { key = "loot_chat_ignored", label = "Loot chat ignored" },
    { key = "loot_chat_item_matches", label = "Loot chat item matches" },
    { key = "loot_chat_money_matches", label = "Loot chat money matches" },
    { key = "money_chat_seen", label = "Money chat seen" },
    { key = "money_chat_ignored", label = "Money chat ignored" },
    { key = "money_chat_amount_matches", label = "Money chat amount matches" },
    { key = "session_ensure_failed", label = "Session ensure failed" },
    { key = "item_entries_tracked", label = "Items tracked (entries)" },
    { key = "item_quantity_tracked", label = "Items tracked (quantity)" },
    { key = "money_entries_tracked", label = "Money tracked (entries)" },
    { key = "money_copper_tracked", label = "Money tracked (copper)" },
    { key = "item_filtered_quality", label = "AH filtered by quality" },
    { key = "item_filtered_soulbound", label = "AH filtered soulbound" },
    { key = "loot_source_attached", label = "Loot source attached" },
}

local TIMING_METRICS = {
    { key = "parse_loot_chat", label = "Loot chat parse" },
    { key = "parse_money_chat", label = "Money chat parse" },
    { key = "loot_source_build_pending", label = "Pending source build" },
    { key = "item_value_resolve", label = "Item value resolve" },
    { key = "track_loot_item_total", label = "TrackLootItem total" },
    { key = "track_loot_money_total", label = "TrackLootMoney total" },
}

local function FormatTimingBucket(bucket)
    if type(bucket) ~= "table" then
        return "n/a"
    end

    local count = math.max(0, math.floor((tonumber(bucket.count) or 0) + 0.5))
    if count <= 0 then
        return "n/a"
    end

    local total = math.max(0, tonumber(bucket.total) or 0)
    local maxValue = math.max(0, tonumber(bucket.max) or 0)
    local lastValue = math.max(0, tonumber(bucket.last) or 0)
    local averageMs = (total / count) * 1000
    local maxMs = maxValue * 1000
    local lastMs = lastValue * 1000

    return string.format("avg %.2fms | max %.2fms | last %.2fms | n=%d", averageMs, maxMs, lastMs, count)
end

local function FormatTimestamp(timestamp)
    local normalized = tonumber(timestamp)
    if not normalized or normalized <= 0 then
        return "Unknown"
    end
    return date("%Y-%m-%d %H:%M:%S", normalized)
end

function GoldTracker:BuildDiagnosisReportText(state, options)
    options = options or {}
    local snapshot = type(self.CloneDiagnosisSnapshot) == "function" and self:CloneDiagnosisSnapshot(state) or state
    if type(snapshot) ~= "table" then
        return options.emptyText or "No diagnosis data is available."
    end

    local counters = snapshot.counters or {}
    local timing = snapshot.timing or {}
    local headerLines = options.headerLines or {}

    local function Counter(counterKey)
        return math.max(0, math.floor((tonumber(counters[counterKey]) or 0) + 0.5))
    end

    local function Timing(metricKey)
        return FormatTimingBucket(timing[metricKey])
    end

    local lines = {
        options.title or "General Gold Tracker Diagnosis",
        "",
    }

    for _, line in ipairs(headerLines) do
        lines[#lines + 1] = line
    end
    if #headerLines > 0 then
        lines[#lines + 1] = ""
    end

    lines[#lines + 1] = "Event Counters"
    for _, spec in ipairs(EVENT_COUNTERS) do
        lines[#lines + 1] = string.format("%s: %d", spec.label, Counter(spec.key))
    end

    lines[#lines + 1] = ""
    lines[#lines + 1] = "Loot Pipeline"
    for _, spec in ipairs(LOOT_COUNTERS) do
        lines[#lines + 1] = string.format("%s: %d", spec.label, Counter(spec.key))
    end

    lines[#lines + 1] = ""
    lines[#lines + 1] = "Timing"
    for _, spec in ipairs(TIMING_METRICS) do
        lines[#lines + 1] = string.format("%s: %s", spec.label, Timing(spec.key))
    end

    return table.concat(lines, "\n")
end

function GoldTracker:BuildLiveDiagnosisWindowText()
    if not self:IsDiagnosticsPanelEnabled() then
        return "Diagnosis is disabled.\n\nEnable it in Options > Experimental."
    end

    local state = self:EnsureDiagnosticsState()
    local addonUptimeSeconds = math.max(0, time() - (tonumber(state.startedAt) or time()))
    local sessionElapsed = self:GetSessionElapsedSeconds()
    local sessionActive = self.session and self.session.active == true
    local source = self:GetCurrentValueSource()

    return self:BuildDiagnosisReportText(state, {
        title = "General Gold Tracker Diagnosis (Experimental)",
        headerLines = {
            string.format("Diagnostics enabled: %s", self:IsDiagnosticsPanelEnabled() and "Yes" or "No"),
            string.format("Addon uptime: %s", self:FormatDuration(addonUptimeSeconds)),
            string.format("Session active: %s", sessionActive and "Yes" or "No"),
            string.format("Session elapsed: %s", self:FormatDuration(sessionElapsed)),
            string.format("Value source: %s", source and source.label or "Unknown"),
        },
    })
end

function GoldTracker:BuildHistoryDiagnosisWindowText(session)
    if type(session) ~= "table" then
        return "Saved session not found."
    end

    local snapshot = type(self.CloneDiagnosisSnapshot) == "function" and self:CloneDiagnosisSnapshot(session.diagnosisSnapshot) or session.diagnosisSnapshot
    if type(snapshot) ~= "table" then
        return "No diagnosis data was saved for this session."
    end

    local savedAt = tonumber(session.savedAt or session.stopTime) or time()
    local sessionStart = tonumber(session.startTime) or savedAt
    local sessionStop = tonumber(session.stopTime or session.savedAt) or savedAt
    local sessionDuration = math.max(
        0,
        math.floor((tonumber(session.activeDuration) or tonumber(session.duration) or (sessionStop - sessionStart) or 0) + 0.5)
    )

    local scopeLine = "Scope: Whole saved session"
    if session.saveReason == "split" then
        scopeLine = "Scope: Source session snapshot (not location-filtered)"
    end

    local headerLines = {
        scopeLine,
        string.format("Session: %s", session.name or "Session"),
        string.format("Saved at: %s", FormatTimestamp(savedAt)),
        string.format("Session start: %s", FormatTimestamp(sessionStart)),
        string.format("Session stop: %s", FormatTimestamp(sessionStop)),
        string.format("Session duration: %s", self:FormatDuration(sessionDuration)),
        string.format("Value source: %s", session.valueSourceLabel or "Unknown"),
    }

    local captureStart = tonumber(snapshot.startedAt)
    if captureStart and captureStart > 0 and captureStart ~= sessionStart then
        headerLines[#headerLines + 1] = string.format("Diagnosis capture start: %s", FormatTimestamp(captureStart))
    end

    if session.saveReason == "split" then
        headerLines[#headerLines + 1] = "Note: Diagnosis is session-wide and was copied from the source session during split."
    end

    return self:BuildDiagnosisReportText(snapshot, {
        title = "Saved Session Diagnosis",
        headerLines = headerLines,
        emptyText = "No diagnosis data was saved for this session.",
    })
end

function GoldTracker:UpdateDiagnosisWindow()
    local frame = self.diagnosisFrame
    if not frame or not frame.bodyText then
        return
    end

    local bodyText = ""
    if frame.mode == "history" then
        if frame.TitleText then
            frame.TitleText:SetText("General Gold Tracker - Saved Diagnosis")
        end
        if frame.headerTitleText then
            frame.headerTitleText:SetText("Saved Diagnosis")
        end
        if frame.modeText then
            frame.modeText:SetText("Saved session snapshot")
        end
        if frame.resetButton then
            frame.resetButton:Hide()
        end
        if frame.refreshButton then
            frame.refreshButton:Hide()
        end

        local session = self:GetHistorySessionByID(frame.historySessionID)
        bodyText = self:BuildHistoryDiagnosisWindowText(session)
    else
        if frame.TitleText then
            frame.TitleText:SetText("General Gold Tracker - Diagnosis")
        end
        if frame.headerTitleText then
            frame.headerTitleText:SetText("Diagnosis")
        end
        if frame.modeText then
            frame.modeText:SetText("Runtime diagnostics")
        end
        if frame.resetButton then
            frame.resetButton:Show()
        end
        if frame.refreshButton then
            frame.refreshButton:Show()
        end

        bodyText = self:BuildLiveDiagnosisWindowText()
    end

    frame.bodyText:SetText(bodyText)

    if frame.scrollContent and frame.scrollFrame then
        local contentHeight = math.max(1, math.floor((frame.bodyText:GetStringHeight() or 0) + 20))
        local visibleHeight = math.max(1, math.floor(frame.scrollFrame:GetHeight() or 1))
        frame.scrollContent:SetHeight(math.max(contentHeight, visibleHeight))
    end
end

function GoldTracker:CreateDiagnosisWindow()
    if self.diagnosisFrame then
        return
    end

    local addon = self
    local frame = CreateFrame("Frame", "GoldTrackerDiagnosisFrame", UIParent, "BasicFrameTemplateWithInset")
    frame:SetSize(620, 500)
    frame:SetPoint("CENTER", UIParent, "CENTER", 0, 60)
    frame:SetFrameStrata("DIALOG")
    if frame.SetToplevel then
        frame:SetToplevel(true)
    end
    frame:SetMovable(true)
    frame:SetResizable(true)
    if frame.SetResizeBounds then
        frame:SetResizeBounds(520, 360, 1000, 820)
    else
        if frame.SetMinResize then
            frame:SetMinResize(520, 360)
        end
        if frame.SetMaxResize then
            frame:SetMaxResize(1000, 820)
        end
    end
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnMouseDown", function(self)
        self:Raise()
    end)
    frame:SetScript("OnDragStart", function(self)
        self:Raise()
        self:StartMoving()
    end)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
    frame:Hide()
    frame.mode = "runtime"
    frame.historySessionID = nil

    if frame.NineSlice then
        frame.NineSlice:Hide()
    end
    if frame.Bg then
        frame.Bg:Hide()
    end
    if frame.Inset then
        frame.Inset:Hide()
    end
    if frame.TitleBg then
        frame.TitleBg:Hide()
    end
    if frame.TopTileStreaks then
        frame.TopTileStreaks:Hide()
    end
    if frame.TitleText then
        frame.TitleText:Hide()
    end
    if frame.CloseButton then
        frame.CloseButton:Hide()
    end

    local chrome = CreateDiagnosisPanel(frame, { 0.03, 0.04, 0.06, 0.94 }, { 1.0, 1.0, 1.0, 0.08 })
    chrome:SetPoint("TOPLEFT", frame, "TOPLEFT", 6, -6)
    chrome:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -6, 6)
    frame.chrome = chrome

    local headerBar = CreateDiagnosisPanel(frame, { 0.06, 0.07, 0.10, 0.98 }, { 1.0, 1.0, 1.0, 0.03 })
    headerBar:SetPoint("TOPLEFT", chrome, "TOPLEFT", 0, 0)
    headerBar:SetPoint("TOPRIGHT", chrome, "TOPRIGHT", 0, 0)
    headerBar:SetHeight(42)
    frame.headerBar = headerBar

    local headerAccent = headerBar:CreateTexture(nil, "ARTWORK")
    headerAccent:SetColorTexture(1.0, 0.82, 0.18, 0.68)
    headerAccent:SetPoint("BOTTOMLEFT", headerBar, "BOTTOMLEFT", 1, 0)
    headerAccent:SetPoint("BOTTOMRIGHT", headerBar, "BOTTOMRIGHT", -1, 0)
    headerAccent:SetHeight(2)
    frame.headerAccent = headerAccent

    local headerTitle = headerBar:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    headerTitle:SetPoint("LEFT", headerBar, "LEFT", 14, 0)
    headerTitle:SetPoint("RIGHT", headerBar, "RIGHT", -52, 0)
    headerTitle:SetJustifyH("LEFT")
    headerTitle:SetText("Diagnosis")
    frame.headerTitleText = headerTitle

    local closeButton = CreateDiagnosisButton(headerBar, 22, 22, "X", "neutral")
    closeButton:SetPoint("RIGHT", headerBar, "RIGHT", -10, 0)
    closeButton:SetScript("OnClick", function()
        frame:Hide()
    end)
    frame.diagnosisCloseButton = closeButton

    local controlsPanel = CreateDiagnosisPanel(frame, { 0.05, 0.06, 0.08, 0.94 }, { 1.0, 0.82, 0.18, 0.12 })
    controlsPanel:SetPoint("TOPLEFT", chrome, "TOPLEFT", 12, -54)
    controlsPanel:SetPoint("TOPRIGHT", chrome, "TOPRIGHT", -12, -54)
    controlsPanel:SetHeight(42)
    frame.controlsPanel = controlsPanel

    local modeText = controlsPanel:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    modeText:SetPoint("LEFT", controlsPanel, "LEFT", 14, 0)
    modeText:SetTextColor(1.0, 0.82, 0.18)
    modeText:SetText("Runtime diagnostics")
    frame.modeText = modeText

    local refreshButton = CreateDiagnosisButton(controlsPanel, 92, 22, "Refresh", "neutral")
    refreshButton:SetPoint("RIGHT", controlsPanel, "RIGHT", -14, 0)
    refreshButton:SetScript("OnClick", function()
        addon:UpdateDiagnosisWindow()
    end)
    frame.refreshButton = refreshButton

    local resetButton = CreateDiagnosisButton(controlsPanel, 104, 22, "Reset Stats", "danger")
    resetButton:SetSize(110, 22)
    resetButton:SetPoint("RIGHT", refreshButton, "LEFT", -8, 0)
    resetButton:SetText("Reset Stats")
    resetButton:SetScript("OnClick", function()
        addon:ResetDiagnosticsState()
    end)
    frame.resetButton = resetButton

    local bodyPanel = CreateDiagnosisPanel(frame, { 0.04, 0.05, 0.07, 0.92 }, { 1.0, 0.82, 0.18, 0.10 })
    bodyPanel:SetPoint("TOPLEFT", controlsPanel, "BOTTOMLEFT", 0, -10)
    bodyPanel:SetPoint("BOTTOMRIGHT", chrome, "BOTTOMRIGHT", -12, 12)
    frame.bodyPanel = bodyPanel

    local scrollFrame = CreateFrame("ScrollFrame", nil, bodyPanel, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", bodyPanel, "TOPLEFT", 14, -12)
    scrollFrame:SetPoint("BOTTOMRIGHT", bodyPanel, "BOTTOMRIGHT", -26, 12)
    scrollFrame:EnableMouseWheel(true)
    scrollFrame:SetScript("OnMouseWheel", function(self, delta)
        local step = 40
        local nextScroll = self:GetVerticalScroll() - (delta * step)
        local maxScroll = self:GetVerticalScrollRange()
        if nextScroll < 0 then
            nextScroll = 0
        elseif nextScroll > maxScroll then
            nextScroll = maxScroll
        end
        self:SetVerticalScroll(nextScroll)
    end)
    frame.scrollFrame = scrollFrame

    local scrollContent = CreateFrame("Frame", nil, scrollFrame)
    scrollContent:SetSize(1, 1)
    scrollFrame:SetScrollChild(scrollContent)
    frame.scrollContent = scrollContent

    local bodyText = scrollContent:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    bodyText:SetPoint("TOPLEFT", scrollContent, "TOPLEFT", 0, 0)
    bodyText:SetPoint("TOPRIGHT", scrollContent, "TOPRIGHT", 0, 0)
    bodyText:SetJustifyH("LEFT")
    bodyText:SetJustifyV("TOP")
    bodyText:SetTextColor(0.88, 0.92, 1.0)
    bodyText:SetText("")
    frame.bodyText = bodyText

    local resizeButton = CreateFrame("Button", nil, frame)
    resizeButton:SetSize(16, 16)
    resizeButton:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -8, 8)
    resizeButton:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")
    resizeButton:SetHighlightTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Highlight")
    resizeButton:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Down")
    resizeButton:SetAlpha(0.7)
    resizeButton:SetScript("OnMouseDown", function(_, button)
        if button == "LeftButton" then
            frame:StartSizing("BOTTOMRIGHT")
        end
    end)
    resizeButton:SetScript("OnMouseUp", function()
        frame:StopMovingOrSizing()
    end)
    resizeButton:SetScript("OnHide", function()
        frame:StopMovingOrSizing()
    end)
    frame.resizeButton = resizeButton

    frame:SetScript("OnSizeChanged", function()
        local innerWidth = math.max(1, math.floor((scrollFrame:GetWidth() or 1) - 6))
        local innerHeight = math.max(1, math.floor(scrollFrame:GetHeight() or 1))
        scrollContent:SetWidth(innerWidth)
        scrollContent:SetHeight(innerHeight)
        addon:UpdateDiagnosisWindow()
    end)

    local elapsedAccumulator = 0
    frame:SetScript("OnUpdate", function(_, elapsed)
        if frame.mode ~= "runtime" then
            return
        end

        elapsedAccumulator = elapsedAccumulator + elapsed
        if elapsedAccumulator < 1 then
            return
        end
        elapsedAccumulator = 0
        addon:UpdateDiagnosisWindow()
    end)

    frame:SetScript("OnShow", function()
        addon:UpdateDiagnosisWindow()
    end)

    self.diagnosisFrame = frame
end

function GoldTracker:OpenDiagnosisWindow()
    if not self:IsDiagnosticsPanelEnabled() then
        self:Print("Diagnosis is disabled. Enable it in Options > Experimental.")
        return
    end

    self:CreateDiagnosisWindow()
    if not self.diagnosisFrame then
        return
    end

    self.diagnosisFrame.mode = "runtime"
    self.diagnosisFrame.historySessionID = nil
    self.diagnosisFrame:Show()
    self.diagnosisFrame:Raise()
    self:UpdateDiagnosisWindow()
end

function GoldTracker:OpenHistoryDiagnosisWindow(sessionID)
    local session = self:GetHistorySessionByID(sessionID)
    if not session or type(session.diagnosisSnapshot) ~= "table" then
        self:Print("No diagnosis data was saved for that session.")
        return
    end

    self:CreateDiagnosisWindow()
    if not self.diagnosisFrame then
        return
    end

    self.diagnosisFrame.mode = "history"
    self.diagnosisFrame.historySessionID = sessionID
    self.diagnosisFrame:Show()
    self.diagnosisFrame:Raise()
    self:UpdateDiagnosisWindow()
end

function GoldTracker:ToggleDiagnosisWindow()
    self:CreateDiagnosisWindow()
    if not self.diagnosisFrame then
        return
    end

    if self.diagnosisFrame:IsShown() and self.diagnosisFrame.mode == "runtime" then
        self.diagnosisFrame:Hide()
    else
        self:OpenDiagnosisWindow()
    end
end
