local _, NS = ...
local GoldTracker = NS.GoldTracker
local Theme = NS.JanisTheme

local function CreateDiagnosisPanel(parent, bg, border)
    return Theme:CreatePanel(parent, bg, border)
end

local function CreateDiagnosisButton(parent, width, height, text, paletteKey)
    return Theme:CreateButton(parent, width, height, text, paletteKey)
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

    local chrome = Theme:ApplyWindowChrome(frame, "Diagnosis", {
        closeButtonKey = "diagnosisCloseButton",
    })
    Theme:RegisterSpecialFrame("GoldTrackerDiagnosisFrame")

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

    local function RefreshDiagnosisAfterResize()
        local innerWidth = math.max(1, math.floor((scrollFrame:GetWidth() or 1) - 6))
        local innerHeight = math.max(1, math.floor(scrollFrame:GetHeight() or 1))
        scrollContent:SetWidth(innerWidth)
        scrollContent:SetHeight(innerHeight)
        addon:UpdateDiagnosisWindow()
    end

    Theme:CreateResizeButton(frame, {
        minWidth = 520,
        minHeight = 360,
        maxWidth = 1000,
        maxHeight = 820,
        onResizeStop = function()
            RefreshDiagnosisAfterResize()
        end,
    })

    frame:SetScript("OnSizeChanged", function()
        if frame.isManualResizing then
            return
        end
        RefreshDiagnosisAfterResize()
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
