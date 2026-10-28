local _, NS = ...
local GoldTracker, Theme = NS.GoldTracker, NS.JanisTheme
local function CreateFrame(...)
    return (NS.CreateThemedFrame or _G.CreateFrame)(...)
end

local MIN_WIDTH, MIN_HEIGHT, MAX_WIDTH, MAX_HEIGHT = 640, 480, 1280, 960
local TABS = {
    { key = "overview", label = "Overview" }, { key = "loot", label = "Loot pipeline" },
    { key = "events", label = "Events" }, { key = "timing", label = "Timings" },
}
local EVENT_COUNTERS = {}
for _, event in ipairs({
    "ADDON_LOADED", "CHAT_MSG_LOOT", "CHAT_MSG_MONEY", "LOOT_OPENED", "LOOT_CLOSED",
    "UNIT_SPELLCAST_SUCCEEDED", "PLAYER_TARGET_CHANGED", "UPDATE_MOUSEOVER_UNIT",
    "NAME_PLATE_UNIT_ADDED", "PLAYER_FOCUS_CHANGED", "PLAYER_ENTERING_WORLD",
    "ZONE_CHANGED_NEW_AREA", "ZONE_CHANGED", "ZONE_CHANGED_INDOORS", "BAG_UPDATE_DELAYED",
    "AUCTION_HOUSE_SHOW", "MAIL_SHOW", "MAIL_CLOSED", "PLAYER_LOGOUT",
}) do EVENT_COUNTERS[#EVENT_COUNTERS + 1] = { key = "event_" .. event, label = event } end
local LOOT_GROUPS = {
    { title = "Chat & parsing", description = "Messages received, ignored, and matched. Ignored messages are not necessarily errors.", rows = {
        { key = "loot_chat_seen", label = "Loot chat seen" },
        { key = "loot_chat_ignored", label = "Loot chat ignored" },
        { key = "loot_chat_item_matches", label = "Loot chat item matches" },
        { key = "loot_chat_money_matches", label = "Loot chat money matches" },
        { key = "money_chat_seen", label = "Money chat seen" },
        { key = "money_chat_ignored", label = "Money chat ignored" },
        { key = "money_chat_amount_matches", label = "Money chat amount matches" },
        { key = "session_ensure_failed", label = "Session ensure failed" },
    } },
    { title = "Recording & filters", description = "Entries count records; quantities count individual items. Filter counts are quantities.", rows = {
        { key = "item_entries_tracked", label = "Items tracked (entries)" },
        { key = "item_quantity_tracked", label = "Items tracked (quantity)" },
        { key = "money_entries_tracked", label = "Money tracked (entries)" },
        { key = "money_copper_tracked", label = "Money tracked (copper)" },
        { key = "item_ah_tracked", label = "AH-eligible items (quantity)" },
        { key = "item_filtered_quality", label = "AH filtered by quality" },
        { key = "item_filtered_soulbound", label = "AH filtered soulbound" },
        { key = "item_filtered_on_looted", label = "Bind-on-loot items excluded (quantity)" },
        { key = "loot_source_attached", label = "Loot source attached" },
    } },
    { title = "Coordinates & material locations", description = "Retries are cumulative attempts, not a live queue. Missing coordinates alone do not mean loot was lost.", rows = {
        { key = "loot_coordinates_live", label = "Loot coordinates captured live" },
        { key = "loot_coordinates_cached", label = "Loot coordinates recovered from recent cache" },
        { key = "loot_coordinates_pending", label = "Loot coordinate retries scheduled" },
        { key = "loot_coordinates_recovered", label = "Loot coordinates recovered by retry" },
        { key = "loot_coordinates_unavailable", label = "Loot coordinates unavailable after retries" },
        { key = "material_pin_recorded", label = "Material locations recorded" },
        { key = "material_pin_missing_coordinates", label = "Material locations missing coordinates" },
        { key = "material_pin_rejected", label = "Material locations rejected" },
    } },
}
local TIMING_METRICS = {
    { key = "parse_loot_chat", label = "Loot chat parse" },
    { key = "parse_money_chat", label = "Money chat parse" },
    { key = "loot_source_build_pending", label = "Pending source build" },
    { key = "item_value_resolve", label = "Item value resolve" },
    { key = "track_loot_item_total", label = "TrackLootItem total" },
    { key = "track_loot_money_total", label = "TrackLootMoney total" },
}

local function Count(value) return math.max(0, math.floor((tonumber(value) or 0) + 0.5)) end
local function TimingValues(bucket)
    local count = type(bucket) == "table" and Count(bucket.count) or 0
    if count == 0 then return { "n/a", "n/a", "n/a", "0" } end
    return {
        string.format("%.2f", math.max(0, tonumber(bucket.total) or 0) / count * 1000),
        string.format("%.2f", math.max(0, tonumber(bucket.max) or 0) * 1000),
        string.format("%.2f", math.max(0, tonumber(bucket.last) or 0) * 1000), tostring(count),
    }
end
local function FormatTimingBucket(bucket)
    local values = TimingValues(bucket)
    if values[4] == "0" then return "n/a (no samples)" end
    return string.format("avg %sms | max %sms | last %sms | n=%s", unpack(values))
end
local function FormatTimestamp(timestamp)
    local value = tonumber(timestamp)
    return value and value > 0 and date("%Y-%m-%d %H:%M:%S", value) or "Unknown"
end
-- Saved snapshots can contain metrics from another addon version.
local function ExtraSpecs(values, known, eventsOnly)
    local specs = {}
    for key in pairs(values or {}) do
        if type(key) == "string" and not known[key] and (not eventsOnly or key:match("^event_")) then
            specs[#specs + 1] = { key = key, label = eventsOnly and key:gsub("^event_", "") or key }
        end
    end
    table.sort(specs, function(a, b) return a.key < b.key end)
    return specs
end

function GoldTracker:BuildDiagnosisReportText(state, options)
    options = options or {}
    local snapshot = type(self.CloneDiagnosisSnapshot) == "function" and self:CloneDiagnosisSnapshot(state) or state
    if type(snapshot) ~= "table" then return options.emptyText or "No diagnosis data is available." end
    local counters, timing = snapshot.counters or {}, snapshot.timing or {}
    local lines, known = { options.title or "General Gold Tracker Diagnosis", "" }, {}
    for _, line in ipairs(options.headerLines or {}) do lines[#lines + 1] = line end
    local function AppendCounters(title, specs)
        if #specs == 0 then return end
        lines[#lines + 1], lines[#lines + 2] = "", title
        for _, spec in ipairs(specs) do
            known[spec.key] = true
            lines[#lines + 1] = string.format("%s: %d", spec.label, Count(counters[spec.key]))
        end
    end
    AppendCounters("Event Counters", EVENT_COUNTERS)
    AppendCounters("Other Events", ExtraSpecs(counters, known, true))
    for _, group in ipairs(LOOT_GROUPS) do AppendCounters("Loot Pipeline / " .. group.title, group.rows) end
    AppendCounters("Other Counters", ExtraSpecs(counters, known))
    lines[#lines + 1], lines[#lines + 2] = "", "Timing (milliseconds; n/a means no samples)"
    known = {}
    for _, spec in ipairs(TIMING_METRICS) do
        known[spec.key] = true
        lines[#lines + 1] = spec.label .. ": " .. FormatTimingBucket(timing[spec.key])
    end
    for _, spec in ipairs(ExtraSpecs(timing, known)) do
        lines[#lines + 1] = spec.label .. ": " .. FormatTimingBucket(timing[spec.key])
    end
    return table.concat(lines, "\n")
end

function GoldTracker:BuildDiagnosisView(mode, sessionID, scope, historySession)
    local view = { title = "Diagnosis", scope = scope or "runtime", headerLines = {}, notices = {} }
    local session, snapshot
    if mode == "history" then
        view.title, view.scope, view.scopeLabel = "Saved Diagnosis", "history", "Saved session snapshot"
        session = historySession or self:GetHistorySessionByID(sessionID)
        if type(session) ~= "table" then
            view.emptyText = "Saved session not found. It may have been deleted or merged."
        elseif type(session.diagnosisSnapshot) ~= "table" then
            view.emptyText = "No diagnosis data was saved for this session. Enable it in Options > Advanced before recording."
        else snapshot = session.diagnosisSnapshot end
    elseif view.scope == "session" then
        session = self.session
        snapshot = type(session) == "table" and session.diagnosisSnapshot or nil
        view.scopeLabel = "Current session snapshot"
        if type(snapshot) ~= "table" then
            view.emptyText = "No diagnosis data for the current session. Enable diagnostics in Options > Advanced, then record some activity."
        end
    else
        view.scopeLabel = "Runtime since capture start"
        if not self:IsDiagnosticsPanelEnabled() then
            view.emptyText = "Diagnosis is disabled. Enable it in Options > Advanced."
        else snapshot = self:EnsureDiagnosticsState() end
    end
    if type(snapshot) == "table" then view.snapshot = self:CloneDiagnosisSnapshot(snapshot) end
    view.counters, view.timing = view.snapshot and view.snapshot.counters or {}, view.snapshot and view.snapshot.timing or {}
    if view.emptyText then
        view.description, view.report = view.emptyText, view.emptyText
        return view
    end
    local headers = view.headerLines
    headers[#headers + 1] = "Scope: " .. view.scopeLabel
    headers[#headers + 1] = "Viewed at: " .. FormatTimestamp(time())
    if mode ~= "history" then headers[#headers + 1] = "Capture enabled: " .. (self:IsDiagnosticsPanelEnabled() and "Yes" or "No") end
    if view.snapshot then headers[#headers + 1] = "Diagnosis capture start: " .. FormatTimestamp(view.snapshot.startedAt) end
    if type(session) == "table" then
        headers[#headers + 1] = "Session: " .. (session.name or "Session")
        headers[#headers + 1] = "Session start: " .. FormatTimestamp(session.startTime)
        if mode == "history" then
            headers[#headers + 1] = "Saved at: " .. FormatTimestamp(session.savedAt or session.stopTime)
            headers[#headers + 1] = "Session stop: " .. FormatTimestamp(session.stopTime or session.savedAt)
            local duration = session.activeDuration or session.duration or ((tonumber(session.stopTime) or 0) - (tonumber(session.startTime) or 0))
            headers[#headers + 1] = "Session duration: " .. self:FormatDuration(Count(duration))
        else
            headers[#headers + 1] = "Session active: " .. (session.active == true and "Yes" or "No")
            headers[#headers + 1] = "Session elapsed: " .. self:FormatDuration(self:GetSessionElapsedSeconds())
        end
        headers[#headers + 1] = "Value source: " .. (session.valueSourceLabel or "Unknown")
    elseif mode ~= "history" and not view.emptyText then
        local source = self:GetCurrentValueSource()
        headers[#headers + 1] = "Value source: " .. (source and source.label or "Unknown")
    end
    if mode == "history" and session and session.saveReason == "split" then
        headers[1] = "Scope: Source session snapshot (not location-filtered)"
        view.notices[#view.notices + 1] = "This split session carries the source session's diagnosis. Counters cover the source session, not just this location."
    elseif mode ~= "history" then
        view.notices[#view.notices + 1] = self:IsDiagnosticsPanelEnabled()
            and "Capture is enabled. Reproduce the issue, then press Refresh to inspect new activity."
            or "Capture is disabled. This view contains previously collected data only. Enable capture in Options > Advanced."
    end
    view.description = view.emptyText or (view.scope == "runtime"
        and "Runtime totals cover captured activity since login, /reload, or Reset runtime."
        or "Counters cover captured activity in this session; capture may have started after the session began.")
    if mode == "history" and session and session.saveReason == "split" then
        view.description = "Source session snapshot: these counters were copied during split and are not filtered to this location."
    end
    view.report = view.emptyText or self:BuildDiagnosisReportText(view.snapshot, {
        title = mode == "history" and "Saved Session Diagnosis" or "General Gold Tracker Diagnosis", headerLines = headers,
    })
    return view
end

function GoldTracker:BuildLiveDiagnosisWindowText()
    return self:BuildDiagnosisView("runtime", nil, "runtime").report
end
function GoldTracker:BuildHistoryDiagnosisWindowText(session)
    if type(session) ~= "table" then return "Saved session not found." end
    return self:BuildDiagnosisView("history", nil, nil, session).report
end

local function Text(parent, font, color)
    local text = parent:CreateFontString(nil, "OVERLAY", font or "GameFontHighlightSmall")
    text:SetJustifyH("LEFT")
    text:SetWordWrap(true)
    text:SetTextColor(unpack(Theme:GetColor(color or "text")))
    return text
end
local function Tooltip(frame, title, body)
    frame:EnableMouse(true)
    frame:SetScript("OnEnter", function(self)
        local color = Theme:GetColor("text")
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText(title)
        GameTooltip:AddLine(body, color[1], color[2], color[3], true)
        GameTooltip:Show()
    end)
    frame:SetScript("OnLeave", function() GameTooltip:Hide() end)
end
local function Scroll(parent)
    local scroll = CreateFrame("ScrollFrame", nil, parent, "UIPanelScrollFrameTemplate")
    scroll:EnableMouseWheel(true)
    scroll:SetScript("OnMouseWheel", function(self, delta)
        self:SetVerticalScroll(math.max(0, math.min(self:GetVerticalScrollRange(), self:GetVerticalScroll() - delta * 44)))
    end)
    local content = CreateFrame("Frame", nil, scroll)
    content:SetSize(1, 1)
    scroll:SetScrollChild(content)
    return scroll, content
end
local function ScrollKey(frame)
    local scope = frame.view.scope
    if scope == "history" then scope = scope .. ":" .. tostring(frame.historySessionID) end
    return scope .. ":" .. frame.selectedTab
end

function GoldTracker:RenderDiagnosisWindow()
    local frame = self.diagnosisFrame
    if not frame or not frame.view then return end
    frame.layingOut = true
    local view = frame.view
    if frame.headerTitleText then frame.headerTitleText:SetText(view.title) end
    frame.scopeText:SetText(view.scopeLabel)
    frame.contextText:SetText(view.description)
    frame.runtimeButton:SetShown(frame.mode ~= "history")
    frame.sessionButton:SetShown(frame.mode ~= "history")
    frame.runtimeButton:SetSelected(view.scope == "runtime")
    frame.sessionButton:SetSelected(view.scope == "session")
    frame.resetButton:SetShown(frame.mode ~= "history" and view.scope == "runtime" and view.snapshot ~= nil)
    frame.refreshButton:SetShown(frame.mode ~= "history")
    frame.copyButton:SetEnabled(view.snapshot ~= nil)
    frame.copyButton:SetText(frame.showReport and "Back to diagnosis" or "Copy report")
    frame.scrollFrame:SetShown(not frame.showReport)
    frame.reportPanel:SetShown(frame.showReport)
    local contextHeight = frame.contextText:GetStringHeight()
    frame.tabsPanel:SetPoint("TOPLEFT", frame.chrome, "TOPLEFT", 16, -100 - contextHeight)
    frame.tabsPanel:SetPoint("TOPRIGHT", frame.chrome, "TOPRIGHT", -16, -100 - contextHeight)
    for _, tab in ipairs(TABS) do frame.tabButtons[tab.key]:SetSelected(frame.selectedTab == tab.key) end
    frame.zeroCheck:SetShown(frame.selectedTab == "loot" or frame.selectedTab == "events")
    frame.footerText:SetText(frame.mode == "history" and "Saved snapshot" or ("Refreshed " .. frame.refreshedAt .. "\nManual refresh"))
    local width = math.max(1, frame.scrollFrame:GetWidth() - 4)
    frame.scrollContent:SetWidth(width)
    for _, card in ipairs(frame.cards) do card:Hide() end
    local cardIndex, y = 0, 0
    local function Card(title, body, rows, timing)
        cardIndex = cardIndex + 1
        local card = frame.cards[cardIndex]
        if not card then
            card = Theme:CreatePanel(frame.scrollContent, "section", "chromeBorder")
            card.title, card.body = Text(card, "GameFontNormal", "titleText"), Text(card, nil, "textMuted")
            card.rows = {}
            frame.cards[cardIndex] = card
        end
        card:ClearAllPoints()
        card:SetPoint("TOPLEFT", frame.scrollContent, "TOPLEFT", 0, -y)
        card:SetWidth(width)
        card.title:SetPoint("TOPLEFT", card, "TOPLEFT", 14, -12)
        card.title:SetWidth(width - 28)
        card.title:SetText(title)
        card.body:SetPoint("TOPLEFT", card.title, "BOTTOMLEFT", 0, -7)
        card.body:SetWidth(width - 28)
        card.body:SetText(body or "")
        local rowY = 12 + card.title:GetStringHeight() + 7 + card.body:GetStringHeight() + 10
        for _, row in ipairs(card.rows) do row:Hide() end
        for index, spec in ipairs(rows or {}) do
            local row = card.rows[index]
            if not row then
                row = CreateFrame("Frame", nil, card)
                row.label, row.values = Text(row), {}
                for column = 1, 4 do row.values[column] = Text(row) end
                card.rows[index] = row
            end
            row:ClearAllPoints()
            row:SetPoint("TOPLEFT", card, "TOPLEFT", 14, -rowY)
            row:SetWidth(width - 28)
            local labelWidth = math.floor((width - 28) * (timing and 0.36 or 0.66))
            row.label:SetPoint("TOPLEFT", row, "TOPLEFT", 0, -5)
            row.label:SetWidth(labelWidth - 12)
            row.label:SetText(spec.label)
            local values, columns = spec.values or { tostring(Count(view.counters[spec.key])) }, timing and 4 or 1
            local valueWidth, height = (width - 28 - labelWidth) / columns, row.label:GetStringHeight()
            for column = 1, 4 do
                local text = row.values[column]
                text:SetShown(column <= columns)
                if column <= columns then
                    text:SetPoint("TOPLEFT", row, "TOPLEFT", labelWidth + (column - 1) * valueWidth, -5)
                    text:SetWidth(valueWidth - 4)
                    text:SetText(values[column])
                    height = math.max(height, text:GetStringHeight())
                end
            end
            row:SetHeight(height + 10)
            rowY = rowY + height + 10
            row:SetScript("OnEnter", nil)
            row:SetScript("OnLeave", nil)
            if spec.key then Tooltip(row, spec.label, "Metric: " .. spec.key) end
            row:Show()
        end
        card:SetHeight(rowY + 4)
        card:Show()
        y = y + card:GetHeight() + 10
    end
    if view.emptyText then
        Card("No snapshot to display", view.emptyText)
    elseif frame.selectedTab == "overview" then
        Card("Capture summary", table.concat(view.notices, "\n"), {
            { label = "Item records", values = { tostring(Count(view.counters.item_entries_tracked)) } },
            { label = "Item quantity", values = { tostring(Count(view.counters.item_quantity_tracked)) } },
            { label = "Money records", values = { tostring(Count(view.counters.money_entries_tracked)) } },
        })
        local notes = {}
        if Count(view.counters.session_ensure_failed) > 0 then notes[#notes + 1] = "Session creation failed during capture. Check the session state when reproducing missing loot." end
        if Count(view.counters.loot_coordinates_unavailable) > 0 then notes[#notes + 1] = "Some coordinate attempts ended without a position. Review Coordinates & material locations in Loot pipeline." end
        if Count(view.counters.item_filtered_quality) + Count(view.counters.item_filtered_soulbound) + Count(view.counters.item_filtered_on_looted) > 0 then
            notes[#notes + 1] = "Item filters were applied. Review Recording & filters before comparing captured loot with AH totals."
        end
        if Count(view.counters.loot_chat_seen) + Count(view.counters.money_chat_seen) == 0 then notes[#notes + 1] = "No loot or money chat was captured in this scope. Reproduce the issue with capture enabled, then refresh." end
        if #notes == 0 then notes[1] = "No session-creation failures or exhausted coordinate retries were counted. These counters do not establish that every feature is working." end
        Card("What to check", table.concat(notes, "\n\n"))
        Card("Snapshot details", table.concat(view.headerLines, "\n"))
    elseif frame.selectedTab == "timing" then
        local rows, known = { { label = "Measurement", values = { "Avg ms", "Max ms", "Last ms", "Samples" } } }, {}
        for _, spec in ipairs(TIMING_METRICS) do
            known[spec.key] = true
            rows[#rows + 1] = { key = spec.key, label = spec.label, values = TimingValues(view.timing[spec.key]) }
        end
        for _, spec in ipairs(ExtraSpecs(view.timing, known)) do rows[#rows + 1] = { key = spec.key, label = spec.label, values = TimingValues(view.timing[spec.key]) } end
        Card("Instrumented work", "Milliseconds per call. n/a means no samples. Nested timings overlap; adding them does not give total addon CPU usage. These measurements do not track addon memory.", rows, true)
    else
        local known = {}
        for _, spec in ipairs(EVENT_COUNTERS) do known[spec.key] = true end
        local eventExtras = ExtraSpecs(view.counters, known, true)
        for _, spec in ipairs(eventExtras) do known[spec.key] = true end
        local function Counters(title, description, specs)
            local rows = {}
            for _, spec in ipairs(specs) do
                known[spec.key] = true
                if not frame.hideZero or Count(view.counters[spec.key]) > 0 then rows[#rows + 1] = spec end
            end
            if #rows > 0 then Card(title, description, rows) end
        end
        if frame.selectedTab == "events" then
            Counters("Events received", "Registered WoW events received while capture was enabled. Hover a row for its metric key.", EVENT_COUNTERS)
            Counters("Other events", "Additional events retained in this snapshot.", eventExtras)
        else
            for _, group in ipairs(LOOT_GROUPS) do Counters(group.title, group.description, group.rows) end
            Counters("Other counters", "Additional counters retained in this snapshot.", ExtraSpecs(view.counters, known))
        end
        if cardIndex == 0 then Card("No nonzero counters", "All counters in this tab are zero. Clear Hide zeros to see every metric.") end
    end
    frame.scrollContent:SetHeight(math.max(1, y))
    frame.scrollFrame:UpdateScrollChildRect()
    frame.scrollFrame:SetVerticalScroll(math.min(frame.scrollPositions[ScrollKey(frame)] or 0, frame.scrollFrame:GetVerticalScrollRange()))
    frame.layingOut = false
    frame.layoutReport()
end

function GoldTracker:UpdateDiagnosisWindow()
    local frame = self.diagnosisFrame
    if not frame then return end
    frame.showReport = false
    frame.reportEditBox:ClearFocus()
    frame.view = self:BuildDiagnosisView(frame.mode, frame.historySessionID, frame.scope)
    frame.refreshedAt = date("%H:%M:%S", time())
    self:RenderDiagnosisWindow()
end

function GoldTracker:CreateDiagnosisWindow()
    if self.diagnosisFrame then return end
    local addon = self
    local frame = CreateFrame("Frame", "GoldTrackerDiagnosisFrame", UIParent)
    frame:SetSize(760, 650)
    frame:SetPoint("CENTER", UIParent, "CENTER", 0, 30)
    frame:SetFrameStrata("DIALOG")
    frame:SetToplevel(true)
    frame:SetClampedToScreen(true)
    frame:SetMovable(true)
    frame:SetResizable(true)
    if frame.SetResizeBounds then frame:SetResizeBounds(MIN_WIDTH, MIN_HEIGHT, MAX_WIDTH, MAX_HEIGHT) end
    frame:EnableMouse(true)
    frame:Hide()
    frame.mode, frame.scope, frame.selectedTab = "runtime", "runtime", "overview"
    frame.cards, frame.tabButtons, frame.scrollPositions = {}, {}, {}
    local chrome = Theme:ApplyWindowChrome(frame, "Diagnosis", { closeButtonKey = "diagnosisCloseButton" })
    frame.chrome = chrome
    Theme:RegisterSpecialFrame("GoldTrackerDiagnosisFrame")
    local drag = CreateFrame("Frame", nil, frame)
    drag:SetPoint("TOPLEFT", chrome, "TOPLEFT", 8, -4)
    drag:SetPoint("TOPRIGHT", chrome, "TOPRIGHT", -44, -4)
    drag:SetHeight(36)
    drag:EnableMouse(true)
    drag:RegisterForDrag("LeftButton")
    drag:SetScript("OnDragStart", function() frame:Raise(); frame:StartMoving() end)
    drag:SetScript("OnDragStop", function() frame:StopMovingOrSizing() end)
    frame.scopeText = Text(chrome, "GameFontNormal", "titleText")
    frame.scopeText:SetPoint("TOPLEFT", chrome, "TOPLEFT", 16, -58)
    frame.scopeText:SetWidth(270)
    frame.contextText = Text(chrome, nil, "textMuted")
    frame.contextText:SetPoint("TOPLEFT", chrome, "TOPLEFT", 16, -87)
    frame.contextText:SetPoint("TOPRIGHT", chrome, "TOPRIGHT", -16, -87)
    frame.contextText:SetText("")
    local function SaveScroll()
        if frame.view then frame.scrollPositions[ScrollKey(frame)] = frame.scrollFrame:GetVerticalScroll() end
    end
    local function ScopeButton(scope, label, right)
        local button = Theme:CreateButton(chrome, 126, 26, label, "neutral")
        button:SetPoint("TOPRIGHT", chrome, "TOPRIGHT", right, -51)
        button:SetScript("OnClick", function()
            SaveScroll()
            frame.scope, frame.showReport = scope, false
            frame.reportEditBox:ClearFocus()
            addon:UpdateDiagnosisWindow()
        end)
        return button
    end
    frame.runtimeButton, frame.sessionButton = ScopeButton("runtime", "Runtime", -150), ScopeButton("session", "Current session", -16)
    Tooltip(frame.runtimeButton, "Runtime capture", "Captured activity since login, /reload, or Reset runtime. May span multiple sessions.")
    Tooltip(frame.sessionButton, "Current session", "Uses the current session's own diagnosis snapshot. Runtime resets leave this snapshot intact.")
    frame.tabsPanel = CreateFrame("Frame", nil, chrome)
    frame.tabsPanel:SetHeight(28)
    for index, tab in ipairs(TABS) do
        local key = tab.key
        local button = Theme:CreateButton(frame.tabsPanel, index == 2 and 114 or 86, 26, tab.label, "neutral")
        button:SetPoint("LEFT", frame.tabsPanel, "LEFT", (index - 1) * 94 + (index > 2 and 28 or 0), 0)
        button:SetScript("OnClick", function()
            SaveScroll()
            frame.selectedTab, frame.showReport = key, false
            frame.reportEditBox:ClearFocus()
            addon:RenderDiagnosisWindow()
        end)
        frame.tabButtons[key] = button
    end
    local zero = CreateFrame("CheckButton", nil, frame.tabsPanel, "UICheckButtonTemplate")
    zero:SetSize(24, 24)
    zero:SetPoint("RIGHT", frame.tabsPanel, "RIGHT", -72, 0)
    zero.label = Text(zero)
    zero.label:SetPoint("LEFT", zero, "RIGHT", 2, 0)
    zero.label:SetWidth(72)
    zero.label:SetText("Hide zeros")
    zero:SetScript("OnClick", function(self)
        SaveScroll()
        frame.hideZero = self:GetChecked() == true
        addon:RenderDiagnosisWindow()
    end)
    Tooltip(zero, "Hide zero counts", "Filter this counter view. The copied report always includes every metric, including zeros.")
    frame.zeroCheck = zero
    local body = Theme:CreatePanel(chrome, "body", "chromeBorder")
    body:SetPoint("TOPLEFT", frame.tabsPanel, "BOTTOMLEFT", 0, -10)
    body:SetPoint("BOTTOMRIGHT", chrome, "BOTTOMRIGHT", -16, 58)
    frame.scrollFrame, frame.scrollContent = Scroll(body)
    frame.scrollFrame:SetPoint("TOPLEFT", body, "TOPLEFT", 10, -10)
    frame.scrollFrame:SetPoint("BOTTOMRIGHT", body, "BOTTOMRIGHT", -28, 10)
    frame.scrollFrame:HookScript("OnVerticalScroll", function(_, value)
        if frame.view and not frame.layingOut then frame.scrollPositions[ScrollKey(frame)] = value end
    end)
    frame.reportPanel = Theme:CreatePanel(body, "body", "chromeBorder")
    frame.reportPanel:SetAllPoints(body)
    frame.reportPanel:Hide()
    local hint = Text(frame.reportPanel, nil, "titleText")
    hint:SetPoint("TOPLEFT", frame.reportPanel, "TOPLEFT", 12, -12)
    hint:SetPoint("TOPRIGHT", frame.reportPanel, "TOPRIGHT", -12, -12)
    hint:SetText("Press Ctrl+A, then Ctrl+C to copy this report. Escape returns to diagnosis.")
    frame.reportScroll, frame.reportContent = Scroll(frame.reportPanel)
    frame.reportScroll:SetPoint("TOPLEFT", hint, "BOTTOMLEFT", 0, -10)
    frame.reportScroll:SetPoint("BOTTOMRIGHT", frame.reportPanel, "BOTTOMRIGHT", -28, 12)
    local edit = CreateFrame("EditBox", nil, frame.reportContent)
    edit:SetMultiLine(true)
    edit:SetAutoFocus(false)
    edit:SetFontObject(GameFontHighlightSmall)
    edit:SetTextColor(unpack(Theme:GetColor("text")))
    edit:SetPoint("TOPLEFT", frame.reportContent, "TOPLEFT", 0, 0)
    frame.reportEditBox = edit
    frame.layoutReport = function()
        local width = math.max(1, frame.reportScroll:GetWidth() - 4)
        frame.reportContent:SetWidth(width)
        edit:SetWidth(width)
        local height = math.max(frame.reportScroll:GetHeight(), edit:GetStringHeight() + 20)
        edit:SetHeight(height)
        frame.reportContent:SetHeight(height)
        frame.reportScroll:UpdateScrollChildRect()
    end
    edit:SetScript("OnTextChanged", function(self, userInput)
        if userInput then self:SetText(frame.copiedReport or "") end
        frame.layoutReport()
    end)
    edit:SetScript("OnEscapePressed", function()
        frame.showReport = false
        edit:ClearFocus()
        addon:RenderDiagnosisWindow()
    end)
    frame.copyButton = Theme:CreateButton(chrome, 132, 28, "Copy report", "primary")
    frame.copyButton:SetPoint("BOTTOMRIGHT", chrome, "BOTTOMRIGHT", -16, 16)
    frame.copyButton:SetScript("OnClick", function()
        SaveScroll()
        frame.showReport = not frame.showReport
        if frame.showReport then
            frame.copiedReport = frame.view.report
            edit:SetText(frame.copiedReport)
            frame.reportScroll:SetVerticalScroll(0)
        else edit:ClearFocus() end
        addon:RenderDiagnosisWindow()
        if frame.showReport then edit:SetFocus(); edit:HighlightText() end
    end)
    Tooltip(frame.copyButton, "Copy diagnosis report", "Select and copy the displayed scope's complete report. Includes every metric, regardless of the selected tab or Hide zeros.")
    frame.refreshButton = Theme:CreateButton(chrome, 84, 28, "Refresh", "neutral")
    frame.refreshButton:SetPoint("RIGHT", frame.copyButton, "LEFT", -8, 0)
    frame.refreshButton:SetScript("OnClick", function()
        SaveScroll()
        frame.showReport = false
        edit:ClearFocus()
        addon:UpdateDiagnosisWindow()
    end)
    Tooltip(frame.refreshButton, "Refresh snapshot", "Read the latest counters and timings. Tab changes and resizing keep the displayed snapshot stable.")
    frame.resetButton = Theme:CreateButton(chrome, 112, 28, "Reset runtime", "danger")
    frame.resetButton:SetPoint("RIGHT", frame.refreshButton, "LEFT", -8, 0)
    frame.resetButton:SetScript("OnClick", function()
        frame.showReport = false
        edit:ClearFocus()
        addon:ResetDiagnosticsState("runtime")
    end)
    Tooltip(frame.resetButton, "Reset runtime counters", "Clear runtime counters and timings and restart their capture timestamp. Current-session and saved diagnosis snapshots are preserved.")
    frame.footerText = Text(chrome, nil, "textMuted")
    frame.footerText:SetPoint("BOTTOMLEFT", chrome, "BOTTOMLEFT", 16, 17)
    frame.footerText:SetPoint("RIGHT", frame.resetButton, "LEFT", -12, 0)
    Theme:CreateResizeButton(frame, {
        maximize = true, minWidth = MIN_WIDTH, minHeight = MIN_HEIGHT, maxWidth = MAX_WIDTH, maxHeight = MAX_HEIGHT,
        onResizeStop = function() addon:RenderDiagnosisWindow() end,
    })
    frame:SetScript("OnSizeChanged", function() if not frame.isManualResizing then addon:RenderDiagnosisWindow() end end)
    frame:SetScript("OnShow", function() addon:UpdateDiagnosisWindow() end)
    frame:SetScript("OnHide", function()
        SaveScroll()
        frame.showReport = false
        edit:ClearFocus()
        frame:StopMovingOrSizing()
    end)
    self.diagnosisFrame = frame
end

function GoldTracker:OpenDiagnosisWindow()
    if not self:IsDiagnosticsPanelEnabled() then
        self:Print("Diagnosis is disabled. Enable it in Options > Advanced.", "warnings")
        return
    end
    self:CreateDiagnosisWindow()
    local frame = self.diagnosisFrame
    frame.mode, frame.historySessionID, frame.showReport = "runtime", nil, false
    frame.reportEditBox:ClearFocus()
    if frame:IsShown() then self:UpdateDiagnosisWindow() else frame:Show() end
    frame:Raise()
end
function GoldTracker:OpenHistoryDiagnosisWindow(sessionID)
    local session = self:GetHistorySessionByID(sessionID)
    if not session or type(session.diagnosisSnapshot) ~= "table" then
        self:Print("No diagnosis data was saved for that session.", "warnings")
        return
    end
    self:CreateDiagnosisWindow()
    local frame = self.diagnosisFrame
    frame.mode, frame.historySessionID, frame.showReport = "history", sessionID, false
    frame.reportEditBox:ClearFocus()
    if frame:IsShown() then self:UpdateDiagnosisWindow() else frame:Show() end
    frame:Raise()
end
function GoldTracker:ToggleDiagnosisWindow()
    if self.diagnosisFrame and self.diagnosisFrame:IsShown() and self.diagnosisFrame.mode == "runtime" then
        self.diagnosisFrame:Hide()
    else self:OpenDiagnosisWindow() end
end
