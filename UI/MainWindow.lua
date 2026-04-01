local _, NS = ...
local GoldTracker = NS.GoldTracker

local MAIN_WINDOW_BACKDROP = {
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
local MAIN_LOOT_LOG_MAX_ENTRIES = 1200
local MAIN_LOOT_LOG_ROW_SPACING = 2
local MAIN_LOOT_LOG_TIME_WIDTH = 56
local MAIN_LOOT_LOG_ICON_SIZE = 14
local MAIN_LOOT_LOG_VALUE_WIDTH = 108
local MAIN_LOOT_LOG_SOURCE_WIDTH = 176
local MAIN_SUMMARY_PANEL_MIN_WIDTH = 228
local MAIN_SUMMARY_PANEL_MAX_WIDTH = 288
local BUTTON_PALETTES = {
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

local function ApplyFlatBackdrop(frame, bg, border)
    if not frame or type(frame.SetBackdrop) ~= "function" then
        return
    end

    frame:SetBackdrop(MAIN_WINDOW_BACKDROP)
    if type(bg) == "table" then
        frame:SetBackdropColor(bg[1] or 0, bg[2] or 0, bg[3] or 0, bg[4] or 1)
    end
    if type(border) == "table" then
        frame:SetBackdropBorderColor(border[1] or 1, border[2] or 1, border[3] or 1, border[4] or 1)
    end
end

local function CreatePanel(parent, bg, border)
    local panel = CreateFrame("Frame", nil, parent, "BackdropTemplate")
    ApplyFlatBackdrop(panel, bg, border)
    return panel
end

local function UpdateModernButtonVisual(button)
    if not button or type(button.SetBackdropColor) ~= "function" then
        return
    end

    local palette = button.palette or BUTTON_PALETTES.neutral
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

local function CreateModernButton(parent, width, height, text, paletteKey)
    local button = CreateFrame("Button", nil, parent, "BackdropTemplate")
    button:SetSize(width, height)
    button.palette = BUTTON_PALETTES[paletteKey] or BUTTON_PALETTES.neutral
    button:SetBackdrop(MAIN_WINDOW_BACKDROP)

    local label = button:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    label:SetPoint("CENTER", button, "CENTER", 0, 0)
    label:SetJustifyH("CENTER")
    button.label = label

    function button:SetText(value)
        self.label:SetText(type(value) == "string" and value or "")
    end

    function button:SetPalette(key)
        self.palette = BUTTON_PALETTES[key] or BUTTON_PALETTES.neutral
        UpdateModernButtonVisual(self)
    end

    button:SetText(text)
    button:SetScript("OnEnter", function(self)
        self.isHovered = true
        UpdateModernButtonVisual(self)
    end)
    button:SetScript("OnLeave", function(self)
        self.isHovered = false
        self.isPressed = false
        UpdateModernButtonVisual(self)
    end)
    button:SetScript("OnMouseDown", function(self, mouseButton)
        if mouseButton == "LeftButton" then
            self.isPressed = true
            UpdateModernButtonVisual(self)
        end
    end)
    button:SetScript("OnMouseUp", function(self)
        self.isPressed = false
        UpdateModernButtonVisual(self)
    end)
    UpdateModernButtonVisual(button)

    return button
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

function GoldTracker:RefreshMainWindowLayout()
    local frame = self.mainFrame
    if not frame or not frame.summaryPanel or not frame.logPanel then
        return
    end

    local contentWidth = math.max(1, math.floor((frame.chrome and frame.chrome:GetWidth()) or frame:GetWidth() or 1))
    local summaryWidth = math.max(MAIN_SUMMARY_PANEL_MIN_WIDTH, math.min(MAIN_SUMMARY_PANEL_MAX_WIDTH, math.floor(contentWidth * 0.34)))
    frame.summaryPanel:SetWidth(summaryWidth)

    local actionButtons = {}
    if frame.optionsButton then
        actionButtons[#actionButtons + 1] = frame.optionsButton
    end
    if frame.historyButton and self.db and self.db.enableSessionHistory then
        actionButtons[#actionButtons + 1] = frame.historyButton
    end
    if frame.diagnosisButton and self:IsDiagnosticsPanelEnabled() then
        actionButtons[#actionButtons + 1] = frame.diagnosisButton
    end

    if frame.utilityButtonRow then
        local gap = 8
        local rowWidth = math.max(1, math.floor(frame.utilityButtonRow:GetWidth() or 1))
        local buttonCount = #actionButtons
        local sharedWidth = buttonCount > 0 and math.max(68, math.floor((rowWidth - (gap * math.max(0, buttonCount - 1))) / buttonCount)) or rowWidth
        local previousButton = nil

        for _, button in ipairs({ frame.optionsButton, frame.historyButton, frame.diagnosisButton }) do
            if button then
                button:ClearAllPoints()
            end
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

    local logInnerWidth = math.max(1, math.floor((frame.logPanel:GetWidth() or 1) - 28))
    local valueWidth = math.max(92, math.min(MAIN_LOOT_LOG_VALUE_WIDTH, math.floor(logInnerWidth * 0.18)))
    local sourceWidth = math.max(110, math.min(MAIN_LOOT_LOG_SOURCE_WIDTH, math.floor(logInnerWidth * 0.25)))
    if frame.logValueHeaderText then
        frame.logValueHeaderText:SetWidth(valueWidth)
    end
    if frame.logSourceHeaderText then
        frame.logSourceHeaderText:SetWidth(sourceWidth)
    end
    for _, row in ipairs(frame.logRows or {}) do
        if row.valueText then
            row.valueText:SetWidth(valueWidth)
        end
        if row.sourceText then
            row.sourceText:SetWidth(sourceWidth)
        end
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
    if not self.totalFrame then
        return
    end

    local shouldShow = self:IsTotalWindowGoldPerHourEnabled()
    if self.totalFrame.sessionPerHourText then
        self.totalFrame.sessionPerHourText:SetShown(shouldShow)
    end
    if self.totalFrame.sessionRawPerHourText then
        self.totalFrame.sessionRawPerHourText:SetShown(shouldShow)
    end
    self.totalFrame:SetHeight(shouldShow and 128 or 96)
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
    sourceText:SetPoint("RIGHT", row, "RIGHT", -4, 0)
    sourceText:SetWidth(MAIN_LOOT_LOG_SOURCE_WIDTH)
    sourceText:SetJustifyH("LEFT")
    sourceText:SetWordWrap(false)
    row.sourceText = sourceText

    local valueText = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    valueText:SetPoint("RIGHT", sourceText, "LEFT", -12, 0)
    valueText:SetWidth(MAIN_LOOT_LOG_VALUE_WIDTH)
    valueText:SetJustifyH("RIGHT")
    valueText:SetWordWrap(false)
    row.valueText = valueText

    itemText:SetPoint("LEFT", icon, "RIGHT", 6, 0)
    itemText:SetPoint("RIGHT", valueText, "LEFT", -12, 0)

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

    if frame.logMetaText then
        if #entries > 0 then
            frame.logMetaText:SetText(string.format("%d tracked", #entries))
        else
            frame.logMetaText:SetText("Waiting for loot")
        end
    end
    if frame.logEmptyText then
        frame.logEmptyText:SetShown(#entries == 0)
    end

    for index, entry in ipairs(entries) do
        local row = self:GetMainLootLogRow(index)
        if row then
            local iconTexture = ResolveLogEntryIcon(entry)
            row.itemLink = entry.itemLink
            row.timeText:SetText(entry.timeText or "")
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
                row.itemText:ClearAllPoints()
                row.itemText:SetPoint("LEFT", row.itemIcon, "RIGHT", 6, 0)
            else
                row.itemIcon:Hide()
                row.itemText:ClearAllPoints()
                row.itemText:SetPoint("LEFT", row.timeText, "RIGHT", 10, 0)
            end
            row.itemText:SetPoint("RIGHT", row.valueText, "LEFT", -12, 0)

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
        local contentWidth = (frame.logScrollFrame:GetWidth() or 0) - 6
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
    frame.startStopButton:SetText(session.active and "Stop Session" or "Start Session")
    if frame.startStopButton and frame.startStopButton.SetPalette then
        frame.startStopButton:SetPalette(session.active and "danger" or "primary")
    end
    self:RefreshHistoryButtonVisibility()
    self:RefreshDiagnosisButtonVisibility()
    self:UpdateTotalWindow()
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

function GoldTracker:UpdateTotalWindow()
    if not self.totalFrame or not self.totalFrame.sessionTotalText or not self.totalFrame.sessionTotalRawText then
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
end

function GoldTracker:CreateTotalWindow()
    if self.totalFrame then
        return
    end

    local addon = self
    local frame = CreateFrame("Frame", "GoldTrackerTotalFrame", UIParent, "BasicFrameTemplateWithInset")
    frame:SetSize(300, 128)
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

    if frame.TitleText then
        frame.TitleText:SetText("Session Total")
    end
    if frame.CloseButton then
        frame.CloseButton:SetScript("OnClick", function()
            frame:Hide()
        end)
    end

    local sessionTotalText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    sessionTotalText:SetPoint("TOP", frame, "TOP", 0, -30)
    sessionTotalText:SetJustifyH("CENTER")
    sessionTotalText:SetText("ST: ---")
    frame.sessionTotalText = sessionTotalText

    local sessionTotalRawText = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    sessionTotalRawText:SetPoint("TOP", sessionTotalText, "BOTTOM", 0, -6)
    sessionTotalRawText:SetJustifyH("CENTER")
    sessionTotalRawText:SetText("Raw: ---")
    frame.sessionTotalRawText = sessionTotalRawText

    local sessionPerHourText = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    sessionPerHourText:SetPoint("TOP", sessionTotalRawText, "BOTTOM", 0, -4)
    sessionPerHourText:SetJustifyH("CENTER")
    sessionPerHourText:SetText("ST/h: ---")
    frame.sessionPerHourText = sessionPerHourText

    local sessionRawPerHourText = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    sessionRawPerHourText:SetPoint("TOP", sessionPerHourText, "BOTTOM", 0, -2)
    sessionRawPerHourText:SetJustifyH("CENTER")
    sessionRawPerHourText:SetText("Raw/h: ---")
    frame.sessionRawPerHourText = sessionRawPerHourText

    frame:SetScript("OnShow", function()
        addon:UpdateTotalWindow()
    end)

    self.totalFrame = frame
    self:ApplyTotalWindowGoldPerHourVisibility()
end

function GoldTracker:ToggleTotalWindow()
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

function GoldTracker:CreateMainWindow()
    if self.mainFrame then
        return
    end

    local addon = self
    local minWidth, minHeight = 620, 400
    local maxWidth, maxHeight = 1200, 1000
    local configuredWidth = tonumber(self.db.windowWidth) or self.DEFAULTS.windowWidth
    local configuredHeight = tonumber(self.db.windowHeight) or self.DEFAULTS.windowHeight
    local initialWidth = math.floor(math.max(minWidth, math.min(maxWidth, configuredWidth)) + 0.5)
    local initialHeight = math.floor(math.max(minHeight, math.min(maxHeight, configuredHeight)) + 0.5)
    local frame = CreateFrame("Frame", "GoldTrackerMainFrame", UIParent, "BasicFrameTemplateWithInset")
    frame:SetSize(initialWidth, initialHeight)
    frame:SetPoint("CENTER")
    frame:SetFrameStrata("DIALOG")
    if frame.SetToplevel then
        frame:SetToplevel(true)
    end
    frame:SetMovable(true)
    frame:SetResizable(true)
    if frame.SetResizeBounds then
        frame:SetResizeBounds(minWidth, minHeight, maxWidth, maxHeight)
    else
        if frame.SetMinResize then
            frame:SetMinResize(minWidth, minHeight)
        end
        if frame.SetMaxResize then
            frame:SetMaxResize(maxWidth, maxHeight)
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
    frame:SetClampedToScreen(true)

    frame:SetScript("OnSizeChanged", function(_, width, height)
        local clampedWidth = math.floor(math.max(minWidth, math.min(maxWidth, tonumber(width) or minWidth)) + 0.5)
        local clampedHeight = math.floor(math.max(minHeight, math.min(maxHeight, tonumber(height) or minHeight)) + 0.5)
        addon.db.windowWidth = clampedWidth
        addon.db.windowHeight = clampedHeight
        addon:RefreshMainWindowLayout()
    end)

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
    if frame.CloseButton then
        frame.CloseButton:Hide()
    end
    if frame.TitleText then
        frame.TitleText:Hide()
    end

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

    local sourceLabel = headerBar:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    sourceLabel:SetPoint("LEFT", headerTitle, "RIGHT", 16, 0)
    sourceLabel:SetTextColor(0.62, 0.66, 0.74)
    sourceLabel:SetText("AH Source")

    local sourceValue = headerBar:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    sourceValue:SetPoint("LEFT", sourceLabel, "RIGHT", 6, 0)
    sourceValue:SetPoint("RIGHT", headerBar, "RIGHT", -130, 0)
    sourceValue:SetJustifyH("LEFT")
    sourceValue:SetTextColor(0.92, 0.95, 1.0)
    frame.sourceValue = sourceValue

    local closeButton = CreateModernButton(headerBar, 22, 22, "X", "neutral")
    closeButton:SetPoint("RIGHT", headerBar, "RIGHT", -10, 0)
    closeButton:SetScript("OnClick", function()
        frame:Hide()
    end)

    local sessionStatusBadge = CreateFrame("Frame", nil, headerBar, "BackdropTemplate")
    sessionStatusBadge:SetSize(64, 20)
    sessionStatusBadge:SetPoint("RIGHT", closeButton, "LEFT", -10, 0)
    ApplyFlatBackdrop(sessionStatusBadge, { 0.16, 0.10, 0.10, 0.96 }, { 1.0, 0.58, 0.58, 0.16 })
    frame.sessionStatusBadge = sessionStatusBadge

    local statusValue = sessionStatusBadge:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    statusValue:SetPoint("CENTER", sessionStatusBadge, "CENTER", 0, 0)
    statusValue:SetText("IDLE")
    frame.statusValue = statusValue

    local summaryPanel = CreatePanel(frame, { 0.06, 0.07, 0.09, 0.94 }, { 1.0, 0.82, 0.18, 0.12 })
    summaryPanel:SetPoint("TOPLEFT", chrome, "TOPLEFT", 12, -54)
    summaryPanel:SetPoint("BOTTOMLEFT", chrome, "BOTTOMLEFT", 12, 12)
    summaryPanel:SetWidth(252)
    frame.summaryPanel = summaryPanel

    local summaryAccent = summaryPanel:CreateTexture(nil, "ARTWORK")
    summaryAccent:SetColorTexture(1.0, 0.82, 0.18, 0.18)
    summaryAccent:SetPoint("TOPLEFT", summaryPanel, "TOPLEFT", 1, -1)
    summaryAccent:SetPoint("TOPRIGHT", summaryPanel, "TOPRIGHT", -1, -1)
    summaryAccent:SetHeight(2)
    frame.summaryAccent = summaryAccent

    local logPanel = CreatePanel(frame, { 0.05, 0.06, 0.08, 0.94 }, { 1.0, 0.82, 0.18, 0.10 })
    logPanel:SetPoint("TOPLEFT", summaryPanel, "TOPRIGHT", 12, 0)
    logPanel:SetPoint("BOTTOMRIGHT", chrome, "BOTTOMRIGHT", -12, 12)
    frame.logPanel = logPanel

    local logAccent = logPanel:CreateTexture(nil, "ARTWORK")
    logAccent:SetColorTexture(1.0, 0.82, 0.18, 0.16)
    logAccent:SetPoint("TOPLEFT", logPanel, "TOPLEFT", 1, -1)
    logAccent:SetPoint("TOPRIGHT", logPanel, "TOPRIGHT", -1, -1)
    logAccent:SetHeight(2)
    frame.logAccent = logAccent

    local summaryEyebrow = summaryPanel:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
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

    local timeRow
    timeRow, _, frame.timeValue = CreateSummaryRow(summaryPanel, heroDivider, "Elapsed")
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

    local optionsButton = CreateModernButton(utilityButtonRow, 90, 22, "Options", "neutral")
    optionsButton:SetText("Options")
    optionsButton:SetScript("OnClick", function()
        addon:OpenOptions()
    end)
    frame.optionsButton = optionsButton

    local historyButton = CreateModernButton(utilityButtonRow, 90, 22, "History", "neutral")
    historyButton:SetText("History")
    historyButton:SetScript("OnClick", function()
        addon:OpenHistoryWindow()
    end)
    frame.historyButton = historyButton

    local diagnosisButton = CreateModernButton(utilityButtonRow, 90, 22, "Diagnosis", "neutral")
    diagnosisButton:SetText("Diagnosis")
    diagnosisButton:SetScript("OnClick", function()
        if type(addon.ToggleDiagnosisWindow) == "function" then
            addon:ToggleDiagnosisWindow()
        end
    end)
    frame.diagnosisButton = diagnosisButton

    local logLabel = logPanel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    logLabel:SetPoint("TOPLEFT", logPanel, "TOPLEFT", 16, -16)
    logLabel:SetJustifyH("LEFT")
    logLabel:SetText("Loot Stream")

    local logMetaText = logPanel:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    logMetaText:SetPoint("RIGHT", logPanel, "RIGHT", -16, -16)
    logMetaText:SetJustifyH("RIGHT")
    logMetaText:SetTextColor(0.62, 0.66, 0.74)
    logMetaText:SetText("Waiting for loot")
    frame.logMetaText = logMetaText

    local logTimeHeader = logPanel:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    logTimeHeader:SetPoint("TOPLEFT", logPanel, "TOPLEFT", 24, -42)
    logTimeHeader:SetWidth(MAIN_LOOT_LOG_TIME_WIDTH)
    logTimeHeader:SetJustifyH("LEFT")
    logTimeHeader:SetText("Time")

    local logItemHeader = logPanel:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    logItemHeader:SetPoint("LEFT", logTimeHeader, "RIGHT", MAIN_LOOT_LOG_ICON_SIZE + 12, 0)
    logItemHeader:SetText("Item")

    local logSourceHeader = logPanel:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    logSourceHeader:SetPoint("TOPRIGHT", logPanel, "TOPRIGHT", -16, -42)
    logSourceHeader:SetWidth(MAIN_LOOT_LOG_SOURCE_WIDTH)
    logSourceHeader:SetJustifyH("LEFT")
    logSourceHeader:SetText("From")
    frame.logSourceHeaderText = logSourceHeader

    local logValueHeader = logPanel:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    logValueHeader:SetPoint("RIGHT", logSourceHeader, "LEFT", -12, 0)
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
