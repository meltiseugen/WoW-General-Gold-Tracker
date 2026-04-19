local _, NS = ...
local GoldTracker = NS.GoldTracker
local Theme = NS.JanisTheme

local MAIN_LOOT_LOG_MAX_ENTRIES = 1200
local MAIN_LOOT_LOG_ROW_SPACING = 2
local MAIN_LOOT_LOG_TIME_WIDTH = 56
local MAIN_LOOT_LOG_ICON_SIZE = 14
local MAIN_LOOT_LOG_VALUE_WIDTH = 108
local MAIN_LOOT_LOG_SOURCE_WIDTH = 176
local MAIN_LOOT_LOG_MIN_ITEM_WIDTH = 104
local MAIN_LOOT_LOG_MIN_VALUE_WIDTH = 78
local MAIN_LOOT_LOG_MIN_SOURCE_WIDTH = 96
local MAIN_LOOT_LOG_COLUMN_GAP = 12
local MAIN_LOOT_LOG_ROW_RIGHT_INSET = 4
local MAIN_LOOT_LOG_SCROLL_CONTENT_RIGHT_PADDING = 6
local MAIN_LOOT_LOG_HEADER_SCROLL_TOP_OFFSET = 22
local MAIN_SUMMARY_PANEL_MAX_WIDTH = 288
local MAIN_PANEL_OUTER_INSET = 12
local MAIN_PANEL_TOP_OFFSET = -54
local MAIN_PANEL_BOTTOM_INSET = 12
local MAIN_PANEL_GAP = 8
local MAIN_LOOT_STREAM_TOGGLE_WIDTH = 24
local MAIN_WINDOW_EXPANDED_MIN_WIDTH = 780
local MAIN_WINDOW_COLLAPSED_MIN_WIDTH = 356
local MAIN_WINDOW_COLLAPSED_MAX_WIDTH = 388
local MAIN_WINDOW_MAX_WIDTH = 1200
local MAIN_WINDOW_MIN_HEIGHT = 460
local MAIN_WINDOW_MAX_HEIGHT = 1000
local function CreatePanel(parent, bg, border)
    return Theme:CreatePanel(parent, bg, border)
end

local function CreateModernButton(parent, width, height, text, paletteKey)
    return Theme:CreateButton(parent, width, height, text, paletteKey)
end

local function CreateSummaryRow(parent, anchor, labelText)
    local row = CreateFrame("Frame", nil, parent)
    row:SetHeight(14)
    row:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", 0, -5)
    row:SetPoint("TOPRIGHT", parent, "TOPRIGHT", -16, 0)

    local label = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    label:SetPoint("LEFT", row, "LEFT", 0, 0)
    label:SetTextColor(0.62, 0.66, 0.74)
    label:SetText(labelText)

    local value = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    value:SetPoint("RIGHT", row, "RIGHT", 0, 0)
    value:SetJustifyH("RIGHT")
    value:SetTextColor(0.92, 0.95, 1.0)

    return row, label, value
end

local function SplitLogTimestamp(text)
    if type(text) ~= "string" then
        return "", ""
    end

    local timeText, remainder = string.match(text, "^(%d%d:%d%d:%d%d)%s+(.+)$")
    if type(timeText) == "string" and type(remainder) == "string" then
        return timeText, remainder
    end

    return "", text
end

local function ResolveLogEntryIcon(entry)
    if type(entry) ~= "table" then
        return nil
    end
    if type(entry.icon) == "string" and entry.icon ~= "" then
        return entry.icon
    end
    if type(entry.itemLink) == "string" and entry.itemLink ~= "" and type(GetItemInfoInstant) == "function" then
        local _, _, _, _, icon = GetItemInfoInstant(entry.itemLink)
        if icon then
            return icon
        end
    end
    return nil
end

local function ResolveItemLinkIcon(itemLink)
    if type(itemLink) ~= "string" or itemLink == "" or type(GetItemInfoInstant) ~= "function" then
        return nil
    end

    local _, _, _, _, icon = GetItemInfoInstant(itemLink)
    return icon
end

local function FormatLootLogTimestamp(timestamp)
    local normalized = tonumber(timestamp) or 0
    if normalized > 0 then
        return date("%H:%M:%S", normalized)
    end
    return date("%H:%M:%S")
end

local function ResolveLootLogSourceText(addon, entry)
    if type(addon) == "table"
        and type(addon.IsLootSourceTrackingEnabled) == "function"
        and addon:IsLootSourceTrackingEnabled() ~= true then
        return ""
    end

    if type(entry and entry.lootSourceText) == "string" and entry.lootSourceText ~= "" then
        return entry.lootSourceText
    end
    if entry and (entry.lootSourceType == "AOE" or entry.lootSourceIsAoe == true) then
        return "AOE loot"
    end
    return ""
end

local function CompareImportedLootLogEntries(a, b)
    local leftTimestamp = tonumber(a and a.sortTimestamp) or 0
    local rightTimestamp = tonumber(b and b.sortTimestamp) or 0
    if leftTimestamp ~= rightTimestamp then
        return leftTimestamp < rightTimestamp
    end

    return (tonumber(a and a.sortIndex) or 0) < (tonumber(b and b.sortIndex) or 0)
end

local function BuildRecentHighlightDisplay(addon, entry)
    if type(entry) ~= "table" then
        return "No highlighted loot yet", string.format("Threshold: %s", addon:FormatMoney(addon:GetHighlightThreshold())), nil
    end

    local quantity = math.max(1, math.floor(tonumber(entry.quantity) or 1))
    local itemText = type(entry.itemLink) == "string" and entry.itemLink ~= "" and entry.itemLink or "Unknown item"
    if quantity > 1 then
        itemText = string.format("%s x%d", itemText, quantity)
    end

    local details = addon:FormatMoney(tonumber(entry.totalValue) or 0)
    if type(entry.lootSourceText) == "string" and entry.lootSourceText ~= "" then
        details = string.format("%s  %s", details, entry.lootSourceText)
    end

    return itemText, details, entry.itemLink
end

local function GetMainLootLogContentWidth(frame)
    if not frame then
        return 1
    end

    local width = 0
    if frame.logScrollFrame then
        width = (tonumber(frame.logScrollFrame:GetWidth()) or 0) - MAIN_LOOT_LOG_SCROLL_CONTENT_RIGHT_PADDING
    elseif frame.logPanel then
        width = (tonumber(frame.logPanel:GetWidth()) or 0) - 42
    end

    return math.max(1, math.floor(width + 0.5))
end

local function GetMainLootLogItemLeftReserve(showTimestamps)
    if showTimestamps then
        return 8 + MAIN_LOOT_LOG_TIME_WIDTH + 6 + MAIN_LOOT_LOG_ICON_SIZE + 6
    end

    return 8 + MAIN_LOOT_LOG_ICON_SIZE + 6
end

local function BuildMainLootLogLayoutMetrics(addon, frame)
    local contentWidth = GetMainLootLogContentWidth(frame)
    local valueWidth = math.max(
        MAIN_LOOT_LOG_MIN_VALUE_WIDTH,
        math.min(MAIN_LOOT_LOG_VALUE_WIDTH, math.floor(contentWidth * 0.22))
    )
    local sourceWidth = math.max(
        MAIN_LOOT_LOG_MIN_SOURCE_WIDTH,
        math.min(MAIN_LOOT_LOG_SOURCE_WIDTH, math.floor(contentWidth * 0.24))
    )
    local allowTimestamps = addon and type(addon.IsLootLogTimestampsEnabled) == "function" and addon:IsLootLogTimestampsEnabled()
    local allowSource = addon and type(addon.IsLootSourceTrackingEnabled) == "function" and addon:IsLootSourceTrackingEnabled()

    local function CanFit(showTimestamps, showSource)
        local itemLeftReserve = GetMainLootLogItemLeftReserve(showTimestamps)
        local rightReserve = MAIN_LOOT_LOG_ROW_RIGHT_INSET + valueWidth + MAIN_LOOT_LOG_COLUMN_GAP
        if showSource then
            rightReserve = rightReserve + sourceWidth + MAIN_LOOT_LOG_COLUMN_GAP
        end

        return (contentWidth - itemLeftReserve - rightReserve) >= MAIN_LOOT_LOG_MIN_ITEM_WIDTH
    end

    local showTimestamps = allowTimestamps == true
    local showSource = allowSource == true and CanFit(showTimestamps, true)
    if showTimestamps and not CanFit(showTimestamps, showSource) then
        showTimestamps = false
        showSource = allowSource == true and CanFit(showTimestamps, true)
    end

    return {
        contentWidth = contentWidth,
        valueWidth = valueWidth,
        sourceWidth = sourceWidth,
        showTimestamps = showTimestamps,
        showSource = showSource,
    }
end

local function ApplyMainLootLogRowColumnLayout(row, layout)
    if not row or not layout then
        return
    end

    if row.sourceText then
        row.sourceText:ClearAllPoints()
        row.sourceText:SetWidth(layout.sourceWidth)
        row.sourceText:SetShown(layout.showSource)
        if layout.showSource then
            row.sourceText:SetPoint("RIGHT", row, "RIGHT", -MAIN_LOOT_LOG_ROW_RIGHT_INSET, 0)
        else
            row.sourceText:SetPoint("LEFT", row, "RIGHT", 0, 0)
        end
    end

    if row.valueText then
        row.valueText:ClearAllPoints()
        row.valueText:SetWidth(layout.valueWidth)
        row.valueText:SetJustifyH("RIGHT")
        if layout.showSource and row.sourceText then
            row.valueText:SetPoint("RIGHT", row.sourceText, "LEFT", -MAIN_LOOT_LOG_COLUMN_GAP, 0)
        else
            row.valueText:SetPoint("RIGHT", row, "RIGHT", -MAIN_LOOT_LOG_ROW_RIGHT_INSET, 0)
        end
    end

    if row.itemText and row.valueText then
        row.itemText:SetPoint("RIGHT", row.valueText, "LEFT", -MAIN_LOOT_LOG_COLUMN_GAP, 0)
    end
end

local function ClampMainWindowWidth(addon, width, isExpanded)
    local minWidth = isExpanded and MAIN_WINDOW_EXPANDED_MIN_WIDTH or MAIN_WINDOW_COLLAPSED_MIN_WIDTH
    local maxWidth = isExpanded and MAIN_WINDOW_MAX_WIDTH or MAIN_WINDOW_COLLAPSED_MAX_WIDTH
    local fallback = isExpanded and addon.DEFAULTS.windowWidth or addon.DEFAULTS.collapsedWindowWidth
    return math.floor(math.max(minWidth, math.min(maxWidth, tonumber(width) or fallback)) + 0.5)
end

local function ApplyMainWindowResizeBounds(addon, frame)
    if not frame then
        return
    end

    local isExpanded = addon:IsMainLootStreamExpanded()
    local minWidth = isExpanded and MAIN_WINDOW_EXPANDED_MIN_WIDTH or MAIN_WINDOW_COLLAPSED_MIN_WIDTH
    local maxWidth = isExpanded and MAIN_WINDOW_MAX_WIDTH or MAIN_WINDOW_COLLAPSED_MAX_WIDTH
    if frame.SetResizeBounds then
        frame:SetResizeBounds(minWidth, MAIN_WINDOW_MIN_HEIGHT, maxWidth, MAIN_WINDOW_MAX_HEIGHT)
    else
        if frame.SetMinResize then
            frame:SetMinResize(minWidth, MAIN_WINDOW_MIN_HEIGHT)
        end
        if frame.SetMaxResize then
            frame:SetMaxResize(maxWidth, MAIN_WINDOW_MAX_HEIGHT)
        end
    end
end

function GoldTracker:GetConfiguredWindowAlpha()
    local alpha = (self.db and self.db.windowAlpha) or self.DEFAULTS.windowAlpha
    alpha = tonumber(alpha) or self.DEFAULTS.windowAlpha
    return math.max(0.20, math.min(1.00, alpha))
end

function GoldTracker:ApplyMainWindowAlpha()
    if not self.mainFrame then
        return
    end

    local frame = self.mainFrame
    local alpha = self:GetConfiguredWindowAlpha()

    frame:SetAlpha(1)

    if frame.chrome then
        frame.chrome:SetBackdropColor(0.03, 0.04, 0.06, math.max(0.72, alpha * 0.94))
        frame.chrome:SetBackdropBorderColor(1.0, 1.0, 1.0, 0.08)
    end
    if frame.headerBar then
        frame.headerBar:SetBackdropColor(0.06, 0.07, 0.10, math.max(0.78, alpha))
        frame.headerBar:SetBackdropBorderColor(1.0, 1.0, 1.0, 0.03)
    end
    if frame.summaryPanel then
        frame.summaryPanel:SetBackdropColor(0.06, 0.07, 0.09, math.max(0.76, alpha * 0.96))
        frame.summaryPanel:SetBackdropBorderColor(1.0, 0.82, 0.18, 0.12)
    end
    if frame.logPanel then
        frame.logPanel:SetBackdropColor(0.05, 0.06, 0.08, math.max(0.74, alpha * 0.94))
        frame.logPanel:SetBackdropBorderColor(1.0, 0.82, 0.18, 0.10)
    end
    if frame.headerAccent then
        frame.headerAccent:SetAlpha(math.max(0.45, alpha))
    end
    if frame.summaryAccent then
        frame.summaryAccent:SetAlpha(math.max(0.35, alpha * 0.85))
    end
    if frame.logAccent then
        frame.logAccent:SetAlpha(math.max(0.35, alpha * 0.85))
    end
end

function GoldTracker:SetMainLootStreamExpanded(isExpanded)
    local shouldExpand = isExpanded == true
    local frame = self.mainFrame
    if frame and self.db then
        local currentWidth = tonumber(frame:GetWidth()) or 0
        if shouldExpand then
            self.db.collapsedWindowWidth = ClampMainWindowWidth(self, currentWidth, false)
        else
            self.db.windowWidth = ClampMainWindowWidth(self, currentWidth, true)
        end
    end

    if self.db then
        self.db.mainLootStreamExpanded = shouldExpand
    end

    if frame then
        ApplyMainWindowResizeBounds(self, frame)
        local targetWidth = ClampMainWindowWidth(
            self,
            shouldExpand and (self.db and self.db.windowWidth) or (self.db and self.db.collapsedWindowWidth),
            shouldExpand
        )
        local targetHeight = math.floor(math.max(MAIN_WINDOW_MIN_HEIGHT, math.min(MAIN_WINDOW_MAX_HEIGHT, tonumber(frame:GetHeight()) or MAIN_WINDOW_MIN_HEIGHT)) + 0.5)
        frame:SetSize(targetWidth, targetHeight)
    end

    self:RefreshMainWindowLayout()
end

function GoldTracker:ToggleMainLootStream()
    self:SetMainLootStreamExpanded(not self:IsMainLootStreamExpanded())
end

function GoldTracker:UpdateMainLastHighlight()
    local frame = self.mainFrame
    if not frame or not frame.mainLastHighlightContainer then
        return
    end

    local entry = self:GetMostRecentHighlightedLootEntry()
    local itemText, detailText, itemLink = BuildRecentHighlightDisplay(self, entry)
    frame.mainLastHighlightItemLink = itemLink

    if frame.mainLastHighlightItemText then
        frame.mainLastHighlightItemText:SetText(itemText)
    end
    if frame.mainLastHighlightDetailText then
        frame.mainLastHighlightDetailText:SetText(detailText)
    end
    if frame.mainLastHighlightIcon then
        local iconTexture = ResolveItemLinkIcon(itemLink)
        if iconTexture then
            frame.mainLastHighlightIcon:SetTexture(iconTexture)
            frame.mainLastHighlightIcon:Show()
        else
            frame.mainLastHighlightIcon:Hide()
        end
    end
end

function GoldTracker:RefreshMainWindowLayout()
    local frame = self.mainFrame
    if not frame or not frame.summaryPanel or not frame.logPanel then
        return
    end

    local summaryWidth = MAIN_SUMMARY_PANEL_MAX_WIDTH
    local isLootStreamExpanded = self:IsMainLootStreamExpanded()

    frame.summaryPanel:ClearAllPoints()
    frame.summaryPanel:SetPoint("TOPLEFT", frame.chrome, "TOPLEFT", MAIN_PANEL_OUTER_INSET, MAIN_PANEL_TOP_OFFSET)
    frame.summaryPanel:SetPoint("BOTTOMLEFT", frame.chrome, "BOTTOMLEFT", MAIN_PANEL_OUTER_INSET, MAIN_PANEL_BOTTOM_INSET)
    frame.summaryPanel:SetWidth(summaryWidth)

    if frame.lootStreamToggleButton then
        frame.lootStreamToggleButton:ClearAllPoints()
        frame.lootStreamToggleButton:SetWidth(MAIN_LOOT_STREAM_TOGGLE_WIDTH)
        frame.lootStreamToggleButton:SetPoint("TOPLEFT", frame.summaryPanel, "TOPRIGHT", MAIN_PANEL_GAP, 0)
        frame.lootStreamToggleButton:SetPoint("BOTTOMLEFT", frame.summaryPanel, "BOTTOMRIGHT", MAIN_PANEL_GAP, 0)
    end

    frame.logPanel:ClearAllPoints()
    if isLootStreamExpanded then
        if frame.lootStreamToggleButton then
            frame.lootStreamToggleButton:SetText("<")
            frame.lootStreamToggleButton.tooltipText = "Hide loot stream"
        end
        frame.logPanel:SetPoint(
            "TOPLEFT",
            frame.summaryPanel,
            "TOPRIGHT",
            (MAIN_PANEL_GAP * 2) + MAIN_LOOT_STREAM_TOGGLE_WIDTH,
            0
        )
        frame.logPanel:SetPoint("BOTTOMRIGHT", frame.chrome, "BOTTOMRIGHT", -MAIN_PANEL_OUTER_INSET, MAIN_PANEL_BOTTOM_INSET)
        frame.logPanel:Show()
    else
        if frame.lootStreamToggleButton then
            frame.lootStreamToggleButton:SetText(">")
            frame.lootStreamToggleButton.tooltipText = "Show loot stream"
        end
        frame.logPanel:Hide()
    end
    if frame.mainLastHighlightContainer then
        frame.mainLastHighlightContainer:SetShown(not isLootStreamExpanded)
    end
    self:UpdateMainLastHighlight()

    local actionButtons = {}
    if frame.optionsButton then
        actionButtons[#actionButtons + 1] = frame.optionsButton
    end
    if frame.inventoryButton then
        actionButtons[#actionButtons + 1] = frame.inventoryButton
    end
    if frame.historyButton and self.db and self.db.enableSessionHistory then
        actionButtons[#actionButtons + 1] = frame.historyButton
    end
    if frame.diagnosisButton and self:IsDiagnosticsPanelEnabled() then
        actionButtons[#actionButtons + 1] = frame.diagnosisButton
    end

    if frame.utilityButtonRow then
        local gap = #actionButtons >= 4 and 4 or 8
        local rowWidth = math.max(1, math.floor(frame.utilityButtonRow:GetWidth() or 1))
        local buttonCount = #actionButtons
        local minimumButtonWidth = buttonCount >= 4 and 44 or (buttonCount >= 3 and 56 or 68)
        local sharedWidth = buttonCount > 0 and math.max(minimumButtonWidth, math.floor((rowWidth - (gap * math.max(0, buttonCount - 1))) / buttonCount)) or rowWidth
        local previousButton = nil

        for _, button in ipairs({ frame.optionsButton, frame.inventoryButton, frame.historyButton, frame.diagnosisButton }) do
            if button then
                button:ClearAllPoints()
            end
        end

        if frame.diagnosisButton then
            frame.diagnosisButton:SetText(buttonCount >= 4 and "Diag" or "Diagnosis")
        end

        for index, button in ipairs(actionButtons) do
            button:SetHeight(22)
            if index == 1 then
                button:SetPoint("TOPLEFT", frame.utilityButtonRow, "TOPLEFT", 0, 0)
            else
                button:SetPoint("TOPLEFT", previousButton, "TOPRIGHT", gap, 0)
            end

            if index == buttonCount then
                button:SetPoint("BOTTOMRIGHT", frame.utilityButtonRow, "BOTTOMRIGHT", 0, 0)
            else
                button:SetWidth(sharedWidth)
            end
            previousButton = button
        end
    end

    local logLayout = BuildMainLootLogLayoutMetrics(self, frame)
    if frame.logValueHeaderText then
        frame.logValueHeaderText:SetWidth(logLayout.valueWidth)
    end
    if frame.logSourceHeaderText then
        frame.logSourceHeaderText:SetWidth(logLayout.sourceWidth)
        frame.logSourceHeaderText:SetShown(logLayout.showSource)
        if frame.logScrollFrame then
            frame.logSourceHeaderText:ClearAllPoints()
            frame.logSourceHeaderText:SetPoint(
                "TOPRIGHT",
                frame.logScrollFrame,
                "TOPRIGHT",
                -(MAIN_LOOT_LOG_SCROLL_CONTENT_RIGHT_PADDING + MAIN_LOOT_LOG_ROW_RIGHT_INSET),
                MAIN_LOOT_LOG_HEADER_SCROLL_TOP_OFFSET
            )
        end
    end
    if frame.logValueHeaderText and frame.logSourceHeaderText then
        frame.logValueHeaderText:ClearAllPoints()
        if logLayout.showSource then
            frame.logValueHeaderText:SetPoint("RIGHT", frame.logSourceHeaderText, "LEFT", -MAIN_LOOT_LOG_COLUMN_GAP, 0)
        elseif frame.logScrollFrame then
            frame.logValueHeaderText:SetPoint(
                "TOPRIGHT",
                frame.logScrollFrame,
                "TOPRIGHT",
                -(MAIN_LOOT_LOG_SCROLL_CONTENT_RIGHT_PADDING + MAIN_LOOT_LOG_ROW_RIGHT_INSET),
                MAIN_LOOT_LOG_HEADER_SCROLL_TOP_OFFSET
            )
        else
            frame.logValueHeaderText:SetPoint("TOPRIGHT", frame.logPanel, "TOPRIGHT", -16, -42)
        end
        frame.logValueHeaderText:SetJustifyH("RIGHT")
    end
    if frame.logTimeHeaderText then
        frame.logTimeHeaderText:SetShown(logLayout.showTimestamps)
    end
    if frame.logItemHeaderText then
        frame.logItemHeaderText:ClearAllPoints()
        if logLayout.showTimestamps and frame.logTimeHeaderText then
            frame.logItemHeaderText:SetPoint("LEFT", frame.logTimeHeaderText, "RIGHT", MAIN_LOOT_LOG_ICON_SIZE + 12, 0)
        else
            frame.logItemHeaderText:SetPoint("TOPLEFT", frame.logPanel, "TOPLEFT", 24, -42)
        end
    end
    for _, row in ipairs(frame.logRows or {}) do
        ApplyMainLootLogRowColumnLayout(row, logLayout)
    end

    self:RefreshMainLootLog(false)
end

function GoldTracker:ApplyMainWindowGoldPerHourVisibility()
    if not self.mainFrame then
        return
    end

    local shouldShow = self:IsMainWindowGoldPerHourEnabled()
    if self.mainFrame.sessionPerHourLabel then
        self.mainFrame.sessionPerHourLabel:SetShown(shouldShow)
    end
    if self.mainFrame.sessionPerHourValue then
        self.mainFrame.sessionPerHourValue:SetShown(shouldShow)
    end
    if self.mainFrame.ahPerHourLabel then
        self.mainFrame.ahPerHourLabel:SetShown(shouldShow)
    end
    if self.mainFrame.ahPerHourValue then
        self.mainFrame.ahPerHourValue:SetShown(shouldShow)
    end
    if self.mainFrame.rawPerHourLabel then
        self.mainFrame.rawPerHourLabel:SetShown(shouldShow)
    end
    if self.mainFrame.rawPerHourValue then
        self.mainFrame.rawPerHourValue:SetShown(shouldShow)
    end
end

function GoldTracker:ApplyTotalWindowGoldPerHourVisibility()
    if not self:IsTotalWindowFeatureEnabled() or not self.totalFrame then
        return
    end

    local shouldShow = self:IsTotalWindowGoldPerHourEnabled()
    if self.totalFrame.sessionPerHourText then
        self.totalFrame.sessionPerHourText:SetShown(shouldShow)
    end
    if self.totalFrame.sessionRawPerHourText then
        self.totalFrame.sessionRawPerHourText:SetShown(shouldShow)
    end
    if self.totalFrame.lastHighlightHeaderText then
        self.totalFrame.lastHighlightHeaderText:ClearAllPoints()
        if shouldShow and self.totalFrame.sessionRawPerHourText then
            self.totalFrame.lastHighlightHeaderText:SetPoint("TOPLEFT", self.totalFrame.sessionRawPerHourText, "BOTTOMLEFT", 0, -10)
            self.totalFrame.lastHighlightHeaderText:SetPoint("TOPRIGHT", self.totalFrame.sessionRawPerHourText, "BOTTOMRIGHT", 0, -10)
        elseif self.totalFrame.sessionTotalRawText then
            self.totalFrame.lastHighlightHeaderText:SetPoint("TOPLEFT", self.totalFrame.sessionTotalRawText, "BOTTOMLEFT", 0, -10)
            self.totalFrame.lastHighlightHeaderText:SetPoint("TOPRIGHT", self.totalFrame.sessionTotalRawText, "BOTTOMRIGHT", 0, -10)
        end
    end
    self.totalFrame:SetHeight(shouldShow and 176 or 144)
end

function GoldTracker:RefreshHistoryButtonVisibility()
    if not self.mainFrame or not self.mainFrame.historyButton then
        return
    end

    if self.db and self.db.enableSessionHistory then
        self.mainFrame.historyButton:Show()
    else
        self.mainFrame.historyButton:Hide()
    end
    self:RefreshMainWindowLayout()
end

function GoldTracker:ClearLog()
    self.mainLootLogEntries = {}
    self:RefreshMainLootLog(false)
end

function GoldTracker:GetMainLootLogEntries()
    if type(self.mainLootLogEntries) ~= "table" then
        self.mainLootLogEntries = {}
    end
    return self.mainLootLogEntries
end

function GoldTracker:GetMainLootLogRowHeight()
    local baseSize = 12
    if GameFontHighlightSmall and type(GameFontHighlightSmall.GetFont) == "function" then
        local _, fontSize = GameFontHighlightSmall:GetFont()
        baseSize = tonumber(fontSize) or baseSize
    end
    return math.max(20, math.floor(baseSize + 10))
end

function GoldTracker:GetMainLootLogRow(index)
    local frame = self.mainFrame
    if not frame or not frame.logContent then
        return nil
    end

    frame.logRows = frame.logRows or {}
    local row = frame.logRows[index]
    if row then
        return row
    end

    row = CreateFrame("Button", nil, frame.logContent)
    row:EnableMouse(true)
    row:SetHitRectInsets(0, 0, 0, 0)

    local background = row:CreateTexture(nil, "BACKGROUND")
    background:SetAllPoints(row)
    row.background = background

    local hover = row:CreateTexture(nil, "HIGHLIGHT")
    hover:SetAllPoints(row)
    hover:SetColorTexture(1, 0.82, 0.18, 0.06)
    row.hover = hover

    local divider = row:CreateTexture(nil, "ARTWORK")
    divider:SetColorTexture(1, 0.82, 0.18, 0.12)
    divider:SetHeight(1)
    divider:SetPoint("BOTTOMLEFT", row, "BOTTOMLEFT", 0, 0)
    divider:SetPoint("BOTTOMRIGHT", row, "BOTTOMRIGHT", 0, 0)
    row.divider = divider

    local timeText = row:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    timeText:SetPoint("LEFT", row, "LEFT", 8, 0)
    timeText:SetWidth(MAIN_LOOT_LOG_TIME_WIDTH)
    timeText:SetJustifyH("LEFT")
    timeText:SetTextColor(0.52, 0.56, 0.64)
    row.timeText = timeText

    local icon = row:CreateTexture(nil, "ARTWORK")
    icon:SetSize(MAIN_LOOT_LOG_ICON_SIZE, MAIN_LOOT_LOG_ICON_SIZE)
    icon:SetPoint("LEFT", timeText, "RIGHT", 6, 0)
    icon:Hide()
    row.itemIcon = icon

    local itemText = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    itemText:SetJustifyH("LEFT")
    itemText:SetWordWrap(false)
    row.itemText = itemText

    local sourceText = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    sourceText:SetPoint("RIGHT", row, "RIGHT", -MAIN_LOOT_LOG_ROW_RIGHT_INSET, 0)
    sourceText:SetWidth(MAIN_LOOT_LOG_SOURCE_WIDTH)
    sourceText:SetJustifyH("LEFT")
    sourceText:SetWordWrap(false)
    row.sourceText = sourceText

    local valueText = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    valueText:SetPoint("RIGHT", sourceText, "LEFT", -MAIN_LOOT_LOG_COLUMN_GAP, 0)
    valueText:SetWidth(MAIN_LOOT_LOG_VALUE_WIDTH)
    valueText:SetJustifyH("RIGHT")
    valueText:SetWordWrap(false)
    row.valueText = valueText

    itemText:SetPoint("LEFT", icon, "RIGHT", 6, 0)
    itemText:SetPoint("RIGHT", valueText, "LEFT", -MAIN_LOOT_LOG_COLUMN_GAP, 0)

    row:SetScript("OnEnter", function(self)
        if type(self.itemLink) ~= "string" or self.itemLink == "" then
            return
        end
        GameTooltip:SetOwner(self, "ANCHOR_CURSOR")
        GameTooltip:SetHyperlink(self.itemLink)
        GameTooltip:Show()
    end)
    row:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)
    row:SetScript("OnMouseUp", function(self, button)
        if button == "LeftButton" and type(self.itemLink) == "string" and self.itemLink ~= "" and HandleModifiedItemClick then
            HandleModifiedItemClick(self.itemLink)
        end
    end)

    frame.logRows[index] = row
    return row
end

function GoldTracker:RefreshMainLootLog(scrollToBottom)
    local frame = self.mainFrame
    if not frame or not frame.logContent then
        return
    end

    local entries = self:GetMainLootLogEntries()
    local rowHeight = self:GetMainLootLogRowHeight()
    local yOffset = 0
    local logLayout = BuildMainLootLogLayoutMetrics(self, frame)
    local showTimestamps = logLayout.showTimestamps

    if frame.logMetaText then
        frame.logMetaText:SetText("")
    end
    if frame.logEmptyText then
        frame.logEmptyText:SetShown(#entries == 0)
    end

    for index, entry in ipairs(entries) do
        local row = self:GetMainLootLogRow(index)
        if row then
            local iconTexture = ResolveLogEntryIcon(entry)
            row.itemLink = entry.itemLink
            row.timeText:SetShown(showTimestamps)
            row.timeText:SetText(showTimestamps and (entry.timeText or "") or "")
            row.itemText:SetText(entry.itemText or "")
            row.valueText:SetText(entry.valueText or "")
            row.sourceText:SetText(entry.sourceText or "")

            local r = tonumber(entry.r) or 1
            local g = tonumber(entry.g) or 1
            local b = tonumber(entry.b) or 1
            row.itemText:SetTextColor(r, g, b)
            row.valueText:SetTextColor(math.min(1, r + 0.10), math.min(1, g + 0.08), math.min(1, b + 0.04))
            if type(entry.sourceText) == "string" and entry.sourceText ~= "" then
                row.sourceText:SetTextColor(0.66, 0.84, 1.0)
            else
                row.sourceText:SetTextColor(0.54, 0.58, 0.64)
            end

            if iconTexture then
                row.itemIcon:SetTexture(iconTexture)
                row.itemIcon:Show()
                row.itemIcon:ClearAllPoints()
                if showTimestamps then
                    row.itemIcon:SetPoint("LEFT", row.timeText, "RIGHT", 6, 0)
                else
                    row.itemIcon:SetPoint("LEFT", row, "LEFT", 8, 0)
                end
                row.itemText:ClearAllPoints()
                row.itemText:SetPoint("LEFT", row.itemIcon, "RIGHT", 6, 0)
            else
                row.itemIcon:Hide()
                row.itemText:ClearAllPoints()
                if showTimestamps then
                    row.itemText:SetPoint("LEFT", row.timeText, "RIGHT", 10, 0)
                else
                    row.itemText:SetPoint("LEFT", row, "LEFT", 8, 0)
                end
            end
            ApplyMainLootLogRowColumnLayout(row, logLayout)

            row:ClearAllPoints()
            row:SetPoint("TOPLEFT", frame.logContent, "TOPLEFT", 0, -yOffset)
            row:SetPoint("TOPRIGHT", frame.logContent, "TOPRIGHT", 0, -yOffset)
            row:SetHeight(rowHeight)
            if row.background then
                local stripeAlpha = index % 2 == 0 and 0.05 or 0.025
                row.background:SetColorTexture(1, 1, 1, stripeAlpha)
            end
            row.divider:SetShown(index < #entries)
            row:Show()

            yOffset = yOffset + rowHeight
            if index < #entries then
                yOffset = yOffset + MAIN_LOOT_LOG_ROW_SPACING
            end
        end
    end

    for index = (#entries + 1), #(frame.logRows or {}) do
        if frame.logRows[index] then
            frame.logRows[index]:Hide()
        end
    end

    if frame.logEmptyText then
        local emptyHeight = math.floor((frame.logEmptyText:GetStringHeight() or 0) + 24)
        yOffset = math.max(yOffset, emptyHeight)
    end

    frame.logContent:SetHeight(math.max(1, yOffset))
    if frame.logScrollFrame then
        local contentWidth = (frame.logScrollFrame:GetWidth() or 0) - MAIN_LOOT_LOG_SCROLL_CONTENT_RIGHT_PADDING
        frame.logContent:SetWidth(math.max(1, contentWidth))
        if frame.logScrollFrame.UpdateScrollChildRect then
            frame.logScrollFrame:UpdateScrollChildRect()
        end
        if scrollToBottom then
            frame.logScrollFrame:SetVerticalScroll(frame.logScrollFrame:GetVerticalScrollRange() or 0)
        elseif #entries == 0 then
            frame.logScrollFrame:SetVerticalScroll(0)
        end
    end
end

function GoldTracker:AddLootLogEntry(entry)
    if type(entry) ~= "table" then
        return
    end

    local entries = self:GetMainLootLogEntries()
    local timeText = entry.timeText
    local itemText = entry.itemText
    if type(timeText) ~= "string" or timeText == "" then
        timeText, itemText = SplitLogTimestamp(itemText)
    end

    entries[#entries + 1] = {
        timeText = tostring(timeText or ""),
        itemText = tostring(itemText or ""),
        valueText = tostring(entry.valueText or ""),
        sourceText = tostring(entry.sourceText or ""),
        itemLink = entry.itemLink,
        icon = entry.icon,
        r = tonumber(entry.r) or 1,
        g = tonumber(entry.g) or 1,
        b = tonumber(entry.b) or 1,
        tracked = entry.tracked == true,
    }

    while #entries > MAIN_LOOT_LOG_MAX_ENTRIES do
        table.remove(entries, 1)
    end

    self:RefreshMainLootLog(true)
end

function GoldTracker:AddLootItemLogEntry(itemLink, quantity, totalValue, lootSourceText)
    local normalizedQuantity = math.max(1, math.floor(tonumber(quantity) or 1))
    self:AddLootLogEntry({
        timeText = date("%H:%M:%S"),
        itemText = string.format("%s x%d", itemLink or "Unknown item", normalizedQuantity),
        valueText = self:FormatMoney(totalValue or 0),
        sourceText = lootSourceText or "",
        itemLink = itemLink,
        tracked = true,
        r = 0.9,
        g = 0.9,
        b = 1,
    })
end

function GoldTracker:AddLootMoneyLogEntry(amount)
    self:AddLootLogEntry({
        timeText = date("%H:%M:%S"),
        itemText = "|cffffd100Raw looted gold|r",
        valueText = self:FormatMoney(amount or 0),
        sourceText = "",
        icon = "Interface\\MoneyFrame\\UI-GoldIcon",
        tracked = true,
        r = 1,
        g = 0.85,
        b = 0,
    })
end

function GoldTracker:AddLogMessage(text, r, g, b)
    self:AddLootLogEntry({
        itemText = text,
        valueText = "",
        sourceText = "",
        r = r or 1,
        g = g or 1,
        b = b or 1,
    })
end

function GoldTracker:ImportSessionLootsToMainLootLog(itemLoots, moneyLoots, replaceExisting)
    local entries = replaceExisting and {} or self:GetMainLootLogEntries()
    local importedEntries = {}
    local sortIndex = 0

    if self.db and self.db.showRawLootedGoldInLog and type(moneyLoots) == "table" then
        for _, money in ipairs(moneyLoots) do
            local amount = tonumber(money and money.amount) or 0
            if amount > 0 then
                sortIndex = sortIndex + 1
                importedEntries[#importedEntries + 1] = {
                    sortTimestamp = tonumber(money and money.timestamp) or 0,
                    sortIndex = sortIndex,
                    entry = {
                        timeText = FormatLootLogTimestamp(money and money.timestamp),
                        itemText = "|cffffd100Raw looted gold|r",
                        valueText = self:FormatMoney(amount),
                        sourceText = "",
                        icon = "Interface\\MoneyFrame\\UI-GoldIcon",
                        r = 1,
                        g = 0.85,
                        b = 0,
                        tracked = true,
                    },
                }
            end
        end
    end

    if type(itemLoots) == "table" then
        for _, loot in ipairs(itemLoots) do
            if loot
                and (loot.ahTracked == true or loot.ahTracked == nil)
                and loot.isSoulbound ~= true
                and type(loot.itemLink) == "string"
                and loot.itemLink ~= "" then
                local quantity = math.max(1, math.floor((tonumber(loot.quantity) or 1) + 0.5))
                sortIndex = sortIndex + 1
                importedEntries[#importedEntries + 1] = {
                    sortTimestamp = tonumber(loot.timestamp) or 0,
                    sortIndex = sortIndex,
                    entry = {
                        timeText = FormatLootLogTimestamp(loot.timestamp),
                        itemText = string.format("%s x%d", loot.itemLink, quantity),
                        valueText = self:FormatMoney(tonumber(loot.totalValue) or 0),
                        sourceText = ResolveLootLogSourceText(self, loot),
                        itemLink = loot.itemLink,
                        r = 0.9,
                        g = 0.9,
                        b = 1,
                        tracked = true,
                    },
                }
            end
        end
    end

    table.sort(importedEntries, CompareImportedLootLogEntries)
    for _, imported in ipairs(importedEntries) do
        entries[#entries + 1] = imported.entry
    end

    while #entries > MAIN_LOOT_LOG_MAX_ENTRIES do
        table.remove(entries, 1)
    end

    self.mainLootLogEntries = entries
    self:RefreshMainLootLog(true)
end

function GoldTracker:UpdateMainWindow()
    if not self.mainFrame then
        return
    end

    local frame = self.mainFrame
    local source = self:GetCurrentValueSource()
    local session = self.session

    if frame.statusValue then
        frame.statusValue:SetText(session.active and "LIVE" or "IDLE")
        frame.statusValue:SetTextColor(session.active and 0.42 or 1.0, session.active and 1.0 or 0.70, session.active and 0.72 or 0.70)
    end
    if frame.sessionStatusBadge then
        if session.active then
            frame.sessionStatusBadge:SetBackdropColor(0.10, 0.22, 0.16, 0.96)
            frame.sessionStatusBadge:SetBackdropBorderColor(0.42, 1.0, 0.72, 0.26)
        else
            frame.sessionStatusBadge:SetBackdropColor(0.16, 0.10, 0.10, 0.96)
            frame.sessionStatusBadge:SetBackdropBorderColor(1.0, 0.58, 0.58, 0.16)
        end
    end

    frame.timeValue:SetText(self:FormatDuration(self:GetSessionElapsedSeconds()))
    frame.goldValue:SetText(self:FormatMoney(session.goldLooted))
    frame.itemValue:SetText(self:FormatMoney(session.itemValue))
    frame.itemVendorValue:SetText(self:FormatMoney(session.itemVendorValue))
    local elapsedSeconds = self:GetSessionRateDurationSeconds()
    local elapsedForRate = elapsedSeconds
    if session.active and elapsedForRate > 0 then
        elapsedForRate = math.max(60, elapsedForRate)
    end
    local highlightCount = tonumber(session.highlightItemCount)
    if not highlightCount then
        highlightCount = (tonumber(session.lowHighlightItemCount) or 0) + (tonumber(session.highHighlightItemCount) or 0)
    end
    frame.highlightValue:SetText(tostring(math.max(0, highlightCount or 0)))
    local sessionTotal = self:GetSessionTotalValue()
    local sessionTotalRaw = (tonumber(session.goldLooted) or 0) + (tonumber(session.itemVendorValue) or 0)
    frame.totalValue:SetText(self:FormatMoney(sessionTotal))
    frame.totalRawValue:SetText(self:FormatMoney(sessionTotalRaw))
    local shouldShowMainWindowGoldPerHour = self:IsMainWindowGoldPerHourEnabled()
    self:ApplyMainWindowGoldPerHourVisibility()
    if shouldShowMainWindowGoldPerHour and frame.sessionPerHourValue then
        frame.sessionPerHourValue:SetText(self:FormatMoneyPerHour(sessionTotal, elapsedForRate))
    end
    if shouldShowMainWindowGoldPerHour and frame.ahPerHourValue then
        frame.ahPerHourValue:SetText(self:FormatMoneyPerHour(session.itemValue or 0, elapsedForRate))
    end
    if shouldShowMainWindowGoldPerHour and frame.rawPerHourValue then
        frame.rawPerHourValue:SetText(self:FormatMoneyPerHour(sessionTotalRaw, elapsedForRate))
    end
    if frame.sourceValue then
        frame.sourceValue:SetText(source.label)
    end
    self:UpdateMainLastHighlight()
    frame.startStopButton:SetText(session.active and "Stop Session" or "Start Session")
    if frame.startStopButton and frame.startStopButton.SetPalette then
        frame.startStopButton:SetPalette(session.active and "danger" or "primary")
    end
    self:RefreshHistoryButtonVisibility()
    self:RefreshDiagnosisButtonVisibility()
    if self:IsTotalWindowFeatureEnabled() then
        self:UpdateTotalWindow()
    end
    if type(self.UpdateDiagnosisWindow) == "function" then
        self:UpdateDiagnosisWindow()
    end
end

function GoldTracker:RefreshDiagnosisButtonVisibility()
    if not self.mainFrame or not self.mainFrame.diagnosisButton then
        return
    end

    if self:IsDiagnosticsPanelEnabled() then
        self.mainFrame.diagnosisButton:Show()
    else
        self.mainFrame.diagnosisButton:Hide()
    end
    self:RefreshMainWindowLayout()
end

function GoldTracker:ToggleMainWindow()
    if not self.mainFrame then
        return
    end

    if self.mainFrame:IsShown() then
        self.mainFrame:Hide()
    else
        self.mainFrame:Show()
        self.mainFrame:Raise()
    end
end

function GoldTracker:GetMostRecentHighlightedLootEntry()
    local session = self.session
    if type(session) ~= "table" or type(session.itemLoots) ~= "table" then
        return nil
    end

    local threshold = self:GetHighlightThreshold()
    for index = #session.itemLoots, 1, -1 do
        local entry = session.itemLoots[index]
        local totalValue = tonumber(entry and entry.totalValue) or 0
        if totalValue > 0 and totalValue >= threshold then
            return entry
        end
    end

    return nil
end

function GoldTracker:UpdateTotalWindow()
    if not self:IsTotalWindowFeatureEnabled()
        or not self.totalFrame
        or not self.totalFrame.sessionTotalText
        or not self.totalFrame.sessionTotalRawText then
        return
    end

    local shouldShowTotalWindowGoldPerHour = self:IsTotalWindowGoldPerHourEnabled()
    self:ApplyTotalWindowGoldPerHourVisibility()

    if self.session and self.session.active then
        local sessionTotal = self:GetSessionTotalValue()
        local sessionTotalRaw = (tonumber(self.session.goldLooted) or 0) + (tonumber(self.session.itemVendorValue) or 0)
        local elapsedSeconds = self:GetSessionRateDurationSeconds()
        local elapsedForRate = elapsedSeconds
        if elapsedForRate > 0 then
            elapsedForRate = math.max(60, elapsedForRate)
        end
        self.totalFrame.sessionTotalText:SetText(string.format("ST: %s", self:FormatMoney(sessionTotal)))
        self.totalFrame.sessionTotalRawText:SetText(string.format("Raw: %s", self:FormatMoney(sessionTotalRaw)))
        if shouldShowTotalWindowGoldPerHour and self.totalFrame.sessionPerHourText then
            self.totalFrame.sessionPerHourText:SetText(string.format("ST/h: %s", self:FormatMoneyPerHour(sessionTotal, elapsedForRate)))
        end
        if shouldShowTotalWindowGoldPerHour and self.totalFrame.sessionRawPerHourText then
            self.totalFrame.sessionRawPerHourText:SetText(string.format("Raw/h: %s", self:FormatMoneyPerHour(sessionTotalRaw, elapsedForRate)))
        end
    else
        self.totalFrame.sessionTotalText:SetText("ST: ---")
        self.totalFrame.sessionTotalRawText:SetText("Raw: ---")
        if shouldShowTotalWindowGoldPerHour and self.totalFrame.sessionPerHourText then
            self.totalFrame.sessionPerHourText:SetText("ST/h: ---")
        end
        if shouldShowTotalWindowGoldPerHour and self.totalFrame.sessionRawPerHourText then
            self.totalFrame.sessionRawPerHourText:SetText("Raw/h: ---")
        end
    end

    if self.totalFrame.lastHighlightValueText and self.totalFrame.lastHighlightDetailText then
        local itemText, detailText, itemLink = BuildRecentHighlightDisplay(self, self:GetMostRecentHighlightedLootEntry())
        self.totalFrame.lastHighlightValueText:SetText(itemText)
        self.totalFrame.lastHighlightDetailText:SetText(detailText)
        self.totalFrame.lastHighlightItemLink = itemLink

        if self.totalFrame.lastHighlightIcon then
            local iconTexture = ResolveItemLinkIcon(itemLink)
            if iconTexture then
                self.totalFrame.lastHighlightIcon:SetTexture(iconTexture)
                self.totalFrame.lastHighlightIcon:Show()
            else
                self.totalFrame.lastHighlightIcon:Hide()
            end
        end
    end
end

function GoldTracker:CreateTotalWindow()
    if not self:IsTotalWindowFeatureEnabled() then
        return
    end

    if self.totalFrame then
        return
    end

    local addon = self
    local frame = CreateFrame("Frame", "GoldTrackerTotalFrame", UIParent, "BasicFrameTemplateWithInset")
    frame:SetSize(340, 220)
    frame:SetPoint("CENTER", UIParent, "CENTER", 0, 180)
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

    local chrome = Theme:ApplyWindowChrome(frame, "Session Total")
    Theme:RegisterSpecialFrame("GoldTrackerTotalFrame")

    local bodyPanel = CreatePanel(frame, { 0.05, 0.06, 0.08, 0.94 }, { 1.0, 0.82, 0.18, 0.10 })
    bodyPanel:SetPoint("TOPLEFT", chrome, "TOPLEFT", 12, -54)
    bodyPanel:SetPoint("BOTTOMRIGHT", chrome, "BOTTOMRIGHT", -12, 12)
    frame.bodyPanel = bodyPanel

    local sessionTotalText = bodyPanel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    sessionTotalText:SetPoint("TOP", bodyPanel, "TOP", 0, -14)
    sessionTotalText:SetJustifyH("CENTER")
    sessionTotalText:SetText("ST: ---")
    frame.sessionTotalText = sessionTotalText

    local sessionTotalRawText = bodyPanel:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    sessionTotalRawText:SetPoint("TOP", sessionTotalText, "BOTTOM", 0, -6)
    sessionTotalRawText:SetJustifyH("CENTER")
    sessionTotalRawText:SetText("Raw: ---")
    frame.sessionTotalRawText = sessionTotalRawText

    local sessionPerHourText = bodyPanel:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    sessionPerHourText:SetPoint("TOP", sessionTotalRawText, "BOTTOM", 0, -4)
    sessionPerHourText:SetJustifyH("CENTER")
    sessionPerHourText:SetText("ST/h: ---")
    frame.sessionPerHourText = sessionPerHourText

    local sessionRawPerHourText = bodyPanel:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    sessionRawPerHourText:SetPoint("TOP", sessionPerHourText, "BOTTOM", 0, -2)
    sessionRawPerHourText:SetJustifyH("CENTER")
    sessionRawPerHourText:SetText("Raw/h: ---")
    frame.sessionRawPerHourText = sessionRawPerHourText

    local lastHighlightHeaderText = bodyPanel:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    lastHighlightHeaderText:SetPoint("TOPLEFT", sessionRawPerHourText, "BOTTOMLEFT", 0, -10)
    lastHighlightHeaderText:SetPoint("TOPRIGHT", sessionRawPerHourText, "BOTTOMRIGHT", 0, -10)
    lastHighlightHeaderText:SetJustifyH("CENTER")
    lastHighlightHeaderText:SetText("Last Highlight")
    frame.lastHighlightHeaderText = lastHighlightHeaderText

    local lastHighlightIcon = bodyPanel:CreateTexture(nil, "ARTWORK")
    lastHighlightIcon:SetSize(16, 16)
    lastHighlightIcon:SetPoint("TOPLEFT", lastHighlightHeaderText, "BOTTOMLEFT", 14, -7)
    lastHighlightIcon:Hide()
    frame.lastHighlightIcon = lastHighlightIcon

    local lastHighlightValueText = bodyPanel:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    lastHighlightValueText:SetPoint("TOPLEFT", lastHighlightHeaderText, "BOTTOMLEFT", 36, -6)
    lastHighlightValueText:SetPoint("TOPRIGHT", lastHighlightHeaderText, "BOTTOMRIGHT", -14, -6)
    lastHighlightValueText:SetJustifyH("LEFT")
    if lastHighlightValueText.SetWordWrap then
        lastHighlightValueText:SetWordWrap(false)
    end
    lastHighlightValueText:SetText("No highlighted loot yet")
    frame.lastHighlightValueText = lastHighlightValueText

    local lastHighlightDetailText = bodyPanel:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    lastHighlightDetailText:SetPoint("TOPLEFT", lastHighlightValueText, "BOTTOMLEFT", 0, -4)
    lastHighlightDetailText:SetPoint("TOPRIGHT", lastHighlightValueText, "BOTTOMRIGHT", 0, -4)
    lastHighlightDetailText:SetJustifyH("LEFT")
    if lastHighlightDetailText.SetWordWrap then
        lastHighlightDetailText:SetWordWrap(false)
    end
    lastHighlightDetailText:SetText("")
    frame.lastHighlightDetailText = lastHighlightDetailText

    local highlightButton = CreateFrame("Button", nil, bodyPanel)
    highlightButton:SetPoint("TOPLEFT", lastHighlightHeaderText, "BOTTOMLEFT", 10, -2)
    highlightButton:SetPoint("BOTTOMRIGHT", lastHighlightDetailText, "BOTTOMRIGHT", 4, -4)
    highlightButton:RegisterForClicks("LeftButtonUp")
    highlightButton:SetScript("OnEnter", function(self)
        if type(frame.lastHighlightItemLink) ~= "string" or frame.lastHighlightItemLink == "" then
            return
        end
        GameTooltip:SetOwner(self, "ANCHOR_CURSOR")
        GameTooltip:SetHyperlink(frame.lastHighlightItemLink)
        GameTooltip:Show()
    end)
    highlightButton:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)
    highlightButton:SetScript("OnClick", function()
        if type(frame.lastHighlightItemLink) == "string" and frame.lastHighlightItemLink ~= "" and HandleModifiedItemClick then
            HandleModifiedItemClick(frame.lastHighlightItemLink)
        end
    end)
    frame.lastHighlightButton = highlightButton

    frame:SetScript("OnShow", function()
        addon:UpdateTotalWindow()
    end)

    self.totalFrame = frame
    self:ApplyTotalWindowGoldPerHourVisibility()
end

function GoldTracker:ToggleTotalWindow()
    if not self:IsTotalWindowFeatureEnabled() then
        return
    end

    self:CreateTotalWindow()
    if not self.totalFrame then
        return
    end

    if self.totalFrame:IsShown() then
        self.totalFrame:Hide()
    else
        self.totalFrame:Show()
        self.totalFrame:Raise()
        self:UpdateTotalWindow()
    end
end

function GoldTracker:OpenTotalWindow()
    if not self:IsTotalWindowFeatureEnabled() then
        return
    end

    self:CreateTotalWindow()
    if not self.totalFrame then
        return
    end

    self.totalFrame:Show()
    self.totalFrame:Raise()
    self:UpdateTotalWindow()
end

function GoldTracker:CreateMainWindow()
    if self.mainFrame then
        return
    end

    local addon = self
    local configuredWidth = tonumber(self.db.windowWidth) or self.DEFAULTS.windowWidth
    local configuredCollapsedWidth = tonumber(self.db.collapsedWindowWidth) or self.DEFAULTS.collapsedWindowWidth
    local configuredHeight = tonumber(self.db.windowHeight) or self.DEFAULTS.windowHeight
    local isLootStreamExpanded = self:IsMainLootStreamExpanded()
    local initialWidth = ClampMainWindowWidth(self, isLootStreamExpanded and configuredWidth or configuredCollapsedWidth, isLootStreamExpanded)
    local initialHeight = math.floor(math.max(MAIN_WINDOW_MIN_HEIGHT, math.min(MAIN_WINDOW_MAX_HEIGHT, configuredHeight)) + 0.5)
    local frame = CreateFrame("Frame", "GoldTrackerMainFrame", UIParent, "BasicFrameTemplateWithInset")
    frame:SetSize(initialWidth, initialHeight)
    frame:SetPoint("CENTER")
    frame:SetFrameStrata("DIALOG")
    if frame.SetToplevel then
        frame:SetToplevel(true)
    end
    frame:SetMovable(true)
    frame:SetResizable(true)
    ApplyMainWindowResizeBounds(self, frame)
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
    frame:SetClampedToScreen(true)

    local function HandleMainWindowSizeChanged(_, width, height)
        local isExpanded = addon:IsMainLootStreamExpanded()
        local clampedWidth = ClampMainWindowWidth(addon, width, isExpanded)
        local clampedHeight = math.floor(math.max(MAIN_WINDOW_MIN_HEIGHT, math.min(MAIN_WINDOW_MAX_HEIGHT, tonumber(height) or MAIN_WINDOW_MIN_HEIGHT)) + 0.5)
        if isExpanded then
            addon.db.windowWidth = clampedWidth
        else
            addon.db.collapsedWindowWidth = clampedWidth
        end
        addon.db.windowHeight = clampedHeight
        if frame.isManualResizing then
            return
        end
        addon:RefreshMainWindowLayout()
    end
    frame:SetScript("OnSizeChanged", HandleMainWindowSizeChanged)

    Theme:HideNativeChrome(frame)

    local chrome = CreatePanel(frame, { 0.03, 0.04, 0.06, 0.94 }, { 1.0, 1.0, 1.0, 0.08 })
    chrome:SetPoint("TOPLEFT", frame, "TOPLEFT", 6, -6)
    chrome:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -6, 6)
    frame.chrome = chrome

    local headerBar = CreatePanel(frame, { 0.06, 0.07, 0.10, 0.98 }, { 1.0, 1.0, 1.0, 0.03 })
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
    headerTitle:SetJustifyH("LEFT")
    headerTitle:SetText("General Gold Tracker")

    local closeButton = CreateModernButton(headerBar, 22, 22, "X", "neutral")
    closeButton:SetPoint("RIGHT", headerBar, "RIGHT", -10, 0)
    closeButton:SetScript("OnClick", function()
        frame:Hide()
    end)

    local sessionStatusBadge = CreateFrame("Frame", nil, headerBar, "BackdropTemplate")
    sessionStatusBadge:SetSize(64, 20)
    sessionStatusBadge:SetPoint("RIGHT", closeButton, "LEFT", -10, 0)
    Theme:ApplyBackdrop(sessionStatusBadge, { 0.16, 0.10, 0.10, 0.96 }, { 1.0, 0.58, 0.58, 0.16 })
    frame.sessionStatusBadge = sessionStatusBadge

    local statusValue = sessionStatusBadge:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    statusValue:SetPoint("CENTER", sessionStatusBadge, "CENTER", 0, 0)
    statusValue:SetText("IDLE")
    frame.statusValue = statusValue

    local summaryPanel = CreatePanel(frame, { 0.06, 0.07, 0.09, 0.94 }, { 1.0, 0.82, 0.18, 0.12 })
    summaryPanel:SetPoint("TOPLEFT", chrome, "TOPLEFT", MAIN_PANEL_OUTER_INSET, MAIN_PANEL_TOP_OFFSET)
    summaryPanel:SetPoint("BOTTOMLEFT", chrome, "BOTTOMLEFT", MAIN_PANEL_OUTER_INSET, MAIN_PANEL_BOTTOM_INSET)
    summaryPanel:SetWidth(252)
    frame.summaryPanel = summaryPanel

    local summaryAccent = summaryPanel:CreateTexture(nil, "ARTWORK")
    summaryAccent:SetColorTexture(1.0, 0.82, 0.18, 0.18)
    summaryAccent:SetPoint("TOPLEFT", summaryPanel, "TOPLEFT", 1, -1)
    summaryAccent:SetPoint("TOPRIGHT", summaryPanel, "TOPRIGHT", -1, -1)
    summaryAccent:SetHeight(2)
    frame.summaryAccent = summaryAccent

    local logPanel = CreatePanel(frame, { 0.05, 0.06, 0.08, 0.94 }, { 1.0, 0.82, 0.18, 0.10 })
    logPanel:SetPoint("TOPLEFT", summaryPanel, "TOPRIGHT", MAIN_PANEL_GAP, 0)
    logPanel:SetPoint("BOTTOMRIGHT", chrome, "BOTTOMRIGHT", -MAIN_PANEL_OUTER_INSET, MAIN_PANEL_BOTTOM_INSET)
    frame.logPanel = logPanel

    local logAccent = logPanel:CreateTexture(nil, "ARTWORK")
    logAccent:SetColorTexture(1.0, 0.82, 0.18, 0.16)
    logAccent:SetPoint("TOPLEFT", logPanel, "TOPLEFT", 1, -1)
    logAccent:SetPoint("TOPRIGHT", logPanel, "TOPRIGHT", -1, -1)
    logAccent:SetHeight(2)
    frame.logAccent = logAccent

    local summaryEyebrow = summaryPanel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    summaryEyebrow:SetPoint("TOPLEFT", summaryPanel, "TOPLEFT", 16, -16)
    summaryEyebrow:SetTextColor(1.0, 0.82, 0.18)
    summaryEyebrow:SetText("Current Session")

    local totalValue = summaryPanel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    if SystemFont_Shadow_Huge2 then
        totalValue:SetFontObject(SystemFont_Shadow_Huge2)
    end
    totalValue:SetPoint("TOPLEFT", summaryEyebrow, "BOTTOMLEFT", 0, -6)
    totalValue:SetJustifyH("LEFT")
    totalValue:SetTextColor(1.0, 0.93, 0.58)
    totalValue:SetText("---")
    frame.totalValue = totalValue

    local totalRawLabel = summaryPanel:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    totalRawLabel:SetPoint("TOPLEFT", totalValue, "BOTTOMLEFT", 0, -2)
    totalRawLabel:SetTextColor(0.62, 0.66, 0.74)
    totalRawLabel:SetText("Raw Total")

    local totalRawValue = summaryPanel:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    totalRawValue:SetPoint("LEFT", totalRawLabel, "RIGHT", 8, 0)
    totalRawValue:SetTextColor(0.96, 0.86, 0.42)
    totalRawValue:SetText("---")
    frame.totalRawValue = totalRawValue

    local heroDivider = summaryPanel:CreateTexture(nil, "ARTWORK")
    heroDivider:SetColorTexture(1.0, 0.82, 0.18, 0.16)
    heroDivider:SetPoint("TOPLEFT", totalRawLabel, "BOTTOMLEFT", 0, -10)
    heroDivider:SetPoint("TOPRIGHT", summaryPanel, "TOPRIGHT", -16, -10)
    heroDivider:SetHeight(1)

    local sourceRow
    sourceRow, _, frame.sourceValue = CreateSummaryRow(summaryPanel, heroDivider, "AH Source")
    if frame.sourceValue.SetWordWrap then
        frame.sourceValue:SetWordWrap(false)
    end

    local timeRow
    timeRow, _, frame.timeValue = CreateSummaryRow(summaryPanel, sourceRow, "Elapsed")
    local goldRow
    goldRow, _, frame.goldValue = CreateSummaryRow(summaryPanel, timeRow, "Raw Gold")
    local ahRow
    ahRow, _, frame.itemValue = CreateSummaryRow(summaryPanel, goldRow, "AH Value")
    local vendorRow
    vendorRow, _, frame.itemVendorValue = CreateSummaryRow(summaryPanel, ahRow, "Vendor")
    local sessionPerHourRow
    sessionPerHourRow, frame.sessionPerHourLabel, frame.sessionPerHourValue = CreateSummaryRow(summaryPanel, vendorRow, "Session / h")
    local ahPerHourRow
    ahPerHourRow, frame.ahPerHourLabel, frame.ahPerHourValue = CreateSummaryRow(summaryPanel, sessionPerHourRow, "AH / h")
    local rawPerHourRow
    rawPerHourRow, frame.rawPerHourLabel, frame.rawPerHourValue = CreateSummaryRow(summaryPanel, ahPerHourRow, "Raw / h")
    local highlightRow
    highlightRow, _, frame.highlightValue = CreateSummaryRow(summaryPanel, rawPerHourRow, "Highlights")

    frame.timeValue:SetTextColor(0.92, 0.95, 1.0)
    frame.sourceValue:SetTextColor(0.92, 0.95, 1.0)
    frame.goldValue:SetTextColor(1.0, 0.84, 0.26)
    frame.itemValue:SetTextColor(0.66, 0.96, 0.72)
    frame.itemVendorValue:SetTextColor(0.96, 0.86, 0.54)
    frame.sessionPerHourValue:SetTextColor(0.68, 0.86, 1.0)
    frame.ahPerHourValue:SetTextColor(0.68, 0.86, 1.0)
    frame.rawPerHourValue:SetTextColor(0.68, 0.86, 1.0)
    frame.highlightValue:SetTextColor(1.0, 0.82, 0.40)

    local utilityButtonRow = CreateFrame("Frame", nil, summaryPanel)
    utilityButtonRow:SetPoint("BOTTOMLEFT", summaryPanel, "BOTTOMLEFT", 16, 16)
    utilityButtonRow:SetPoint("BOTTOMRIGHT", summaryPanel, "BOTTOMRIGHT", -16, 16)
    utilityButtonRow:SetHeight(22)
    frame.utilityButtonRow = utilityButtonRow

    local actionDivider = summaryPanel:CreateTexture(nil, "ARTWORK")
    actionDivider:SetColorTexture(1.0, 0.82, 0.18, 0.12)
    actionDivider:SetPoint("BOTTOMLEFT", summaryPanel, "BOTTOMLEFT", 16, 54)
    actionDivider:SetPoint("BOTTOMRIGHT", summaryPanel, "BOTTOMRIGHT", -16, 54)
    actionDivider:SetHeight(1)

    local startStopButton = CreateModernButton(summaryPanel, 120, 26, "Start Session", "primary")
    startStopButton:SetPoint("BOTTOMLEFT", utilityButtonRow, "TOPLEFT", 0, 8)
    startStopButton:SetPoint("BOTTOMRIGHT", utilityButtonRow, "TOPRIGHT", 0, 8)
    startStopButton:SetText("Start Session")
    startStopButton:SetScript("OnClick", function()
        if addon.session.active then
            addon:StopSession()
        else
            addon:StartSession()
        end
    end)
    frame.startStopButton = startStopButton

    local mainLastHighlightContainer = CreateFrame("Frame", nil, summaryPanel)
    mainLastHighlightContainer:SetPoint("BOTTOMLEFT", startStopButton, "TOPLEFT", 0, 8)
    mainLastHighlightContainer:SetPoint("BOTTOMRIGHT", startStopButton, "TOPRIGHT", 0, 8)
    mainLastHighlightContainer:SetHeight(40)
    frame.mainLastHighlightContainer = mainLastHighlightContainer

    local mainLastHighlightLabel = mainLastHighlightContainer:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    mainLastHighlightLabel:SetPoint("TOPLEFT", mainLastHighlightContainer, "TOPLEFT", 0, 0)
    mainLastHighlightLabel:SetTextColor(1.0, 0.82, 0.18)
    mainLastHighlightLabel:SetText("Last Highlight")
    frame.mainLastHighlightLabel = mainLastHighlightLabel

    local mainLastHighlightIcon = mainLastHighlightContainer:CreateTexture(nil, "ARTWORK")
    mainLastHighlightIcon:SetSize(16, 16)
    mainLastHighlightIcon:SetPoint("TOPLEFT", mainLastHighlightLabel, "BOTTOMLEFT", 0, -5)
    mainLastHighlightIcon:Hide()
    frame.mainLastHighlightIcon = mainLastHighlightIcon

    local mainLastHighlightItemText = mainLastHighlightContainer:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    mainLastHighlightItemText:SetPoint("LEFT", mainLastHighlightIcon, "RIGHT", 6, 0)
    mainLastHighlightItemText:SetPoint("RIGHT", mainLastHighlightContainer, "RIGHT", 0, 0)
    mainLastHighlightItemText:SetJustifyH("LEFT")
    if mainLastHighlightItemText.SetWordWrap then
        mainLastHighlightItemText:SetWordWrap(false)
    end
    mainLastHighlightItemText:SetText("No highlighted loot yet")
    frame.mainLastHighlightItemText = mainLastHighlightItemText

    local mainLastHighlightDetailText = mainLastHighlightContainer:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    mainLastHighlightDetailText:SetPoint("TOPLEFT", mainLastHighlightItemText, "BOTTOMLEFT", 0, -3)
    mainLastHighlightDetailText:SetPoint("TOPRIGHT", mainLastHighlightItemText, "BOTTOMRIGHT", 0, -3)
    mainLastHighlightDetailText:SetJustifyH("LEFT")
    if mainLastHighlightDetailText.SetWordWrap then
        mainLastHighlightDetailText:SetWordWrap(false)
    end
    mainLastHighlightDetailText:SetText("")
    frame.mainLastHighlightDetailText = mainLastHighlightDetailText

    local mainLastHighlightButton = CreateFrame("Button", nil, mainLastHighlightContainer)
    mainLastHighlightButton:SetAllPoints(mainLastHighlightContainer)
    mainLastHighlightButton:RegisterForClicks("LeftButtonUp")
    mainLastHighlightButton:SetScript("OnEnter", function(self)
        if type(frame.mainLastHighlightItemLink) ~= "string" or frame.mainLastHighlightItemLink == "" then
            return
        end
        GameTooltip:SetOwner(self, "ANCHOR_CURSOR")
        GameTooltip:SetHyperlink(frame.mainLastHighlightItemLink)
        GameTooltip:Show()
    end)
    mainLastHighlightButton:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)
    mainLastHighlightButton:SetScript("OnClick", function()
        if type(frame.mainLastHighlightItemLink) == "string" and frame.mainLastHighlightItemLink ~= "" and HandleModifiedItemClick then
            HandleModifiedItemClick(frame.mainLastHighlightItemLink)
        end
    end)
    frame.mainLastHighlightButton = mainLastHighlightButton

    local optionsButton = CreateModernButton(utilityButtonRow, 90, 22, "Options", "neutral")
    optionsButton:SetText("Options")
    optionsButton:SetScript("OnClick", function()
        addon:OpenOptions()
    end)
    frame.optionsButton = optionsButton

    local inventoryButton = CreateModernButton(utilityButtonRow, 90, 22, "Bags", "neutral")
    inventoryButton:SetText("Bags")
    inventoryButton.tooltipText = "Auctionable inventory"
    inventoryButton:SetScript("OnClick", function()
        if type(addon.OpenInventoryWindow) == "function" then
            addon:OpenInventoryWindow()
        end
    end)
    frame.inventoryButton = inventoryButton

    local historyButton = CreateModernButton(utilityButtonRow, 90, 22, "History", "neutral")
    historyButton:SetText("History")
    historyButton:SetScript("OnClick", function()
        addon:OpenHistoryWindow()
    end)
    frame.historyButton = historyButton

    local diagnosisButton = CreateModernButton(utilityButtonRow, 90, 22, "Diagnosis", "neutral")
    diagnosisButton:SetText("Diagnosis")
    diagnosisButton.tooltipText = "Runtime diagnosis"
    diagnosisButton:SetScript("OnClick", function()
        if type(addon.ToggleDiagnosisWindow) == "function" then
            addon:ToggleDiagnosisWindow()
        end
    end)
    frame.diagnosisButton = diagnosisButton

    local lootStreamToggleButton = CreateModernButton(frame, MAIN_LOOT_STREAM_TOGGLE_WIDTH, 120, ">", "neutral")
    lootStreamToggleButton.tooltipText = "Show loot stream"
    lootStreamToggleButton:SetScript("OnClick", function()
        addon:ToggleMainLootStream()
    end)
    frame.lootStreamToggleButton = lootStreamToggleButton

    local logLabel = logPanel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    logLabel:SetPoint("TOPLEFT", logPanel, "TOPLEFT", 16, -16)
    logLabel:SetJustifyH("LEFT")
    logLabel:SetText("Loot Stream")

    local logMetaText = logPanel:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    logMetaText:SetPoint("RIGHT", logPanel, "RIGHT", -16, -16)
    logMetaText:SetJustifyH("RIGHT")
    logMetaText:SetTextColor(0.62, 0.66, 0.74)
    logMetaText:SetText("")
    frame.logMetaText = logMetaText

    local logTimeHeader = logPanel:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    logTimeHeader:SetPoint("TOPLEFT", logPanel, "TOPLEFT", 24, -42)
    logTimeHeader:SetWidth(MAIN_LOOT_LOG_TIME_WIDTH)
    logTimeHeader:SetJustifyH("LEFT")
    logTimeHeader:SetText("Time")
    frame.logTimeHeaderText = logTimeHeader

    local logItemHeader = logPanel:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    logItemHeader:SetPoint("LEFT", logTimeHeader, "RIGHT", MAIN_LOOT_LOG_ICON_SIZE + 12, 0)
    logItemHeader:SetText("Item")
    frame.logItemHeaderText = logItemHeader

    local logSourceHeader = logPanel:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    logSourceHeader:SetPoint("TOPRIGHT", logPanel, "TOPRIGHT", -16, -42)
    logSourceHeader:SetWidth(MAIN_LOOT_LOG_SOURCE_WIDTH)
    logSourceHeader:SetJustifyH("LEFT")
    logSourceHeader:SetText("From")
    frame.logSourceHeaderText = logSourceHeader

    local logValueHeader = logPanel:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    logValueHeader:SetPoint("RIGHT", logSourceHeader, "LEFT", -MAIN_LOOT_LOG_COLUMN_GAP, 0)
    logValueHeader:SetWidth(MAIN_LOOT_LOG_VALUE_WIDTH)
    logValueHeader:SetJustifyH("RIGHT")
    logValueHeader:SetText("Value")
    frame.logValueHeaderText = logValueHeader

    local logHeaderUnderline = logPanel:CreateTexture(nil, "ARTWORK")
    logHeaderUnderline:SetColorTexture(1.0, 0.82, 0.18, 0.18)
    logHeaderUnderline:SetPoint("TOPLEFT", logPanel, "TOPLEFT", 16, -58)
    logHeaderUnderline:SetPoint("TOPRIGHT", logPanel, "TOPRIGHT", -16, -58)
    logHeaderUnderline:SetHeight(1)

    local logScrollFrame = CreateFrame("ScrollFrame", nil, logPanel, "UIPanelScrollFrameTemplate")
    logScrollFrame:SetPoint("TOPLEFT", logPanel, "TOPLEFT", 16, -64)
    logScrollFrame:SetPoint("BOTTOMRIGHT", logPanel, "BOTTOMRIGHT", -26, 16)
    logScrollFrame:EnableMouseWheel(true)
    logScrollFrame:SetScript("OnMouseWheel", function(self, delta)
        local step = math.max(18, math.floor(self:GetHeight() * 0.12))
        local nextScroll = (tonumber(self:GetVerticalScroll()) or 0) - ((tonumber(delta) or 0) * step)
        local maxScroll = tonumber(self:GetVerticalScrollRange()) or 0
        if nextScroll < 0 then
            nextScroll = 0
        elseif nextScroll > maxScroll then
            nextScroll = maxScroll
        end
        self:SetVerticalScroll(nextScroll)
    end)
    frame.logScrollFrame = logScrollFrame

    local logContent = CreateFrame("Frame", nil, logScrollFrame)
    logContent:SetSize(1, 1)
    logScrollFrame:SetScrollChild(logContent)
    frame.logContent = logContent
    frame.logRows = {}

    local logEmptyText = logContent:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    logEmptyText:SetPoint("TOPLEFT", logContent, "TOPLEFT", 10, -12)
    logEmptyText:SetPoint("TOPRIGHT", logContent, "TOPRIGHT", -10, -12)
    logEmptyText:SetJustifyH("LEFT")
    logEmptyText:SetTextColor(0.62, 0.66, 0.74)
    logEmptyText:SetText("Looted items, raw gold, alerts, and session messages will appear here.")
    frame.logEmptyText = logEmptyText

    Theme:CreateResizeButton(frame, {
        getBounds = function()
            local isExpanded = addon:IsMainLootStreamExpanded()
            local minWidth = isExpanded and MAIN_WINDOW_EXPANDED_MIN_WIDTH or MAIN_WINDOW_COLLAPSED_MIN_WIDTH
            local maxWidth = isExpanded and MAIN_WINDOW_MAX_WIDTH or MAIN_WINDOW_COLLAPSED_MAX_WIDTH
            return minWidth, MAIN_WINDOW_MIN_HEIGHT, maxWidth, MAIN_WINDOW_MAX_HEIGHT
        end,
        onResizeStart = function()
            ApplyMainWindowResizeBounds(addon, frame)
        end,
        onResizeStop = function()
            local width, height = frame:GetSize()
            HandleMainWindowSizeChanged(frame, width, height)
        end,
    })

    local elapsedAccumulator = 0
    frame:SetScript("OnUpdate", function(_, elapsed)
        elapsedAccumulator = elapsedAccumulator + elapsed
        if elapsedAccumulator < 1 then
            return
        end

        elapsedAccumulator = 0
        if addon.session.active then
            addon:UpdateMainWindow()
        end
    end)
    frame:SetScript("OnShow", function()
        addon:RefreshMainWindowLayout()
        addon:UpdateMainWindow()
    end)

    self.mainFrame = frame
    self:ApplyMainWindowAlpha()
    self:ApplyMainWindowGoldPerHourVisibility()
    self:RefreshHistoryButtonVisibility()
    self:RefreshDiagnosisButtonVisibility()
    self:RefreshMainWindowLayout()
    self:RefreshMainLootLog(false)
end
