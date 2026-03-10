local _, NS = ...
local GoldTracker = NS.GoldTracker

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

function GoldTracker:UpdateDiagnosisWindow()
    local frame = self.diagnosisFrame
    if not frame or not frame.bodyText then
        return
    end

    if not self:IsDiagnosticsPanelEnabled() then
        frame.bodyText:SetText("Diagnosis is disabled.\n\nEnable it in Options > Experimental.")
        return
    end

    local state = self:EnsureDiagnosticsState()
    local counters = state.counters or {}
    local timing = state.timing or {}

    local function Counter(counterKey)
        return math.max(0, math.floor((tonumber(counters[counterKey]) or 0) + 0.5))
    end

    local function Timing(metricKey)
        return FormatTimingBucket(timing[metricKey])
    end

    local addonUptimeSeconds = math.max(0, time() - (tonumber(state.startedAt) or time()))
    local sessionElapsed = self:GetSessionElapsedSeconds()
    local sessionActive = self.session and self.session.active == true
    local source = self:GetCurrentValueSource()

    local lines = {
        "Gold Tracker Diagnosis (Experimental)",
        "",
        string.format("Diagnostics enabled: %s", self:IsDiagnosticsPanelEnabled() and "Yes" or "No"),
        string.format("Addon uptime: %s", self:FormatDuration(addonUptimeSeconds)),
        string.format("Session active: %s", sessionActive and "Yes" or "No"),
        string.format("Session elapsed: %s", self:FormatDuration(sessionElapsed)),
        string.format("Value source: %s", source and source.label or "Unknown"),
        "",
        "Event Counters",
        string.format("ADDON_LOADED: %d", Counter("event_ADDON_LOADED")),
        string.format("CHAT_MSG_LOOT: %d", Counter("event_CHAT_MSG_LOOT")),
        string.format("CHAT_MSG_MONEY: %d", Counter("event_CHAT_MSG_MONEY")),
        string.format("LOOT_OPENED: %d", Counter("event_LOOT_OPENED")),
        string.format("LOOT_CLOSED: %d", Counter("event_LOOT_CLOSED")),
        string.format("UNIT_SPELLCAST_SUCCEEDED: %d", Counter("event_UNIT_SPELLCAST_SUCCEEDED")),
        string.format("PLAYER_TARGET_CHANGED: %d", Counter("event_PLAYER_TARGET_CHANGED")),
        string.format("UPDATE_MOUSEOVER_UNIT: %d", Counter("event_UPDATE_MOUSEOVER_UNIT")),
        string.format("NAME_PLATE_UNIT_ADDED: %d", Counter("event_NAME_PLATE_UNIT_ADDED")),
        string.format("PLAYER_FOCUS_CHANGED: %d", Counter("event_PLAYER_FOCUS_CHANGED")),
        string.format("PLAYER_ENTERING_WORLD: %d", Counter("event_PLAYER_ENTERING_WORLD")),
        "",
        "Loot Pipeline",
        string.format("Loot chat seen: %d", Counter("loot_chat_seen")),
        string.format("Loot chat ignored: %d", Counter("loot_chat_ignored")),
        string.format("Loot chat item matches: %d", Counter("loot_chat_item_matches")),
        string.format("Loot chat money matches: %d", Counter("loot_chat_money_matches")),
        string.format("Money chat seen: %d", Counter("money_chat_seen")),
        string.format("Money chat ignored: %d", Counter("money_chat_ignored")),
        string.format("Money chat amount matches: %d", Counter("money_chat_amount_matches")),
        string.format("Session ensure failed: %d", Counter("session_ensure_failed")),
        string.format("Items tracked (entries): %d", Counter("item_entries_tracked")),
        string.format("Items tracked (quantity): %d", Counter("item_quantity_tracked")),
        string.format("Money tracked (entries): %d", Counter("money_entries_tracked")),
        string.format("Money tracked (copper): %d", Counter("money_copper_tracked")),
        string.format("AH filtered by quality: %d", Counter("item_filtered_quality")),
        string.format("AH filtered soulbound: %d", Counter("item_filtered_soulbound")),
        string.format("Loot source attached: %d", Counter("loot_source_attached")),
        "",
        "Timing",
        string.format("Loot chat parse: %s", Timing("parse_loot_chat")),
        string.format("Money chat parse: %s", Timing("parse_money_chat")),
        string.format("Pending source build: %s", Timing("loot_source_build_pending")),
        string.format("Item value resolve: %s", Timing("item_value_resolve")),
        string.format("TrackLootItem total: %s", Timing("track_loot_item_total")),
        string.format("TrackLootMoney total: %s", Timing("track_loot_money_total")),
    }

    frame.bodyText:SetText(table.concat(lines, "\n"))

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

    if frame.TitleText then
        frame.TitleText:SetText("Gold Tracker - Diagnosis")
    end
    if frame.CloseButton then
        frame.CloseButton:SetScript("OnClick", function()
            frame:Hide()
        end)
    end

    local resetButton = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    resetButton:SetSize(110, 22)
    resetButton:SetPoint("TOPLEFT", frame, "TOPLEFT", 16, -34)
    resetButton:SetText("Reset Stats")
    resetButton:SetScript("OnClick", function()
        addon:ResetDiagnosticsState()
    end)
    frame.resetButton = resetButton

    local refreshButton = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    refreshButton:SetSize(110, 22)
    refreshButton:SetPoint("LEFT", resetButton, "RIGHT", 8, 0)
    refreshButton:SetText("Refresh")
    refreshButton:SetScript("OnClick", function()
        addon:UpdateDiagnosisWindow()
    end)
    frame.refreshButton = refreshButton

    local scrollFrame = CreateFrame("ScrollFrame", nil, frame, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", resetButton, "BOTTOMLEFT", -2, -10)
    scrollFrame:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -30, 16)
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
    bodyText:SetText("")
    frame.bodyText = bodyText

    frame:SetScript("OnSizeChanged", function(_, width, height)
        local innerWidth = math.max(1, math.floor((tonumber(width) or 620) - 58))
        local innerHeight = math.max(1, math.floor((tonumber(height) or 500) - 90))
        scrollContent:SetWidth(innerWidth)
        scrollContent:SetHeight(innerHeight)
        addon:UpdateDiagnosisWindow()
    end)

    local elapsedAccumulator = 0
    frame:SetScript("OnUpdate", function(_, elapsed)
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

function GoldTracker:ToggleDiagnosisWindow()
    if not self:IsDiagnosticsPanelEnabled() then
        self:Print("Diagnosis is disabled. Enable it in Options > Experimental.")
        return
    end

    self:CreateDiagnosisWindow()
    if not self.diagnosisFrame then
        return
    end

    if self.diagnosisFrame:IsShown() then
        self.diagnosisFrame:Hide()
    else
        self.diagnosisFrame:Show()
        self.diagnosisFrame:Raise()
        self:UpdateDiagnosisWindow()
    end
end

