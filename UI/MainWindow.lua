local _, NS = ...
local GoldTracker = NS.GoldTracker

local MAIN_LOOT_LOG_MAX_ENTRIES = 1200
local MAIN_LOOT_LOG_ROW_SPACING = 2
local MAIN_LOOT_LOG_VALUE_WIDTH = 110
local MAIN_LOOT_LOG_SOURCE_WIDTH = 210

function GoldTracker:GetConfiguredWindowAlpha()
    local alpha = (self.db and self.db.windowAlpha) or self.DEFAULTS.windowAlpha
    alpha = tonumber(alpha) or self.DEFAULTS.windowAlpha
    return math.max(0.20, math.min(1.00, alpha))
end

function GoldTracker:ApplyMainWindowAlpha()
    if not self.mainFrame then
        return
    end

    local alpha = self:GetConfiguredWindowAlpha()

    -- Keep text and interactive widgets fully opaque.
    self.mainFrame:SetAlpha(1)

    -- Apply opacity only to template background textures.
    if self.mainFrame.Bg and self.mainFrame.Bg.SetAlpha then
        self.mainFrame.Bg:SetAlpha(alpha)
    end
    if self.mainFrame.Inset and self.mainFrame.Inset.Bg and self.mainFrame.Inset.Bg.SetAlpha then
        self.mainFrame.Inset.Bg:SetAlpha(alpha)
    end
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
    return math.max(18, math.floor(baseSize + 8))
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

    local itemText = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    itemText:SetPoint("LEFT", row, "LEFT", 4, 0)
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

    itemText:SetPoint("RIGHT", valueText, "LEFT", -12, 0)

    local divider = row:CreateTexture(nil, "ARTWORK")
    divider:SetColorTexture(1, 0.82, 0, 0.18)
    divider:SetHeight(1)
    divider:SetPoint("BOTTOMLEFT", row, "BOTTOMLEFT", 0, 0)
    divider:SetPoint("BOTTOMRIGHT", row, "BOTTOMRIGHT", 0, 0)
    row.divider = divider

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

    for index, entry in ipairs(entries) do
        local row = self:GetMainLootLogRow(index)
        if row then
            row.itemLink = entry.itemLink
            row.itemText:SetText(entry.itemText or "")
            row.valueText:SetText(entry.valueText or "")
            row.sourceText:SetText(entry.sourceText or "")

            local r = tonumber(entry.r) or 1
            local g = tonumber(entry.g) or 1
            local b = tonumber(entry.b) or 1
            row.itemText:SetTextColor(r, g, b)
            row.valueText:SetTextColor(r, g, b)
            row.sourceText:SetTextColor(r, g, b)

            row:ClearAllPoints()
            row:SetPoint("TOPLEFT", frame.logContent, "TOPLEFT", 0, -yOffset)
            row:SetPoint("TOPRIGHT", frame.logContent, "TOPRIGHT", 0, -yOffset)
            row:SetHeight(rowHeight)
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
    entries[#entries + 1] = {
        itemText = tostring(entry.itemText or ""),
        valueText = tostring(entry.valueText or ""),
        sourceText = tostring(entry.sourceText or ""),
        itemLink = entry.itemLink,
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
        itemText = string.format("%s  %s x%d", date("%H:%M:%S"), itemLink or "Unknown item", normalizedQuantity),
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
        itemText = string.format("%s  |cffffd100Raw looted gold|r", date("%H:%M:%S")),
        valueText = self:FormatMoney(amount or 0),
        sourceText = "",
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

    frame.statusValue:SetText(session.active and "|cff33ff99Started|r" or "|cffff8080Not started|r")

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
    frame.sourceValue:SetText(source.label)
    frame.startStopButton:SetText(session.active and "Stop Session" or "Start Session")
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
    local minWidth, minHeight = 480, 320
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

    frame:SetScript("OnSizeChanged", function(_, width, height)
        local clampedWidth = math.floor(math.max(minWidth, math.min(maxWidth, tonumber(width) or minWidth)) + 0.5)
        local clampedHeight = math.floor(math.max(minHeight, math.min(maxHeight, tonumber(height) or minHeight)) + 0.5)
        addon.db.windowWidth = clampedWidth
        addon.db.windowHeight = clampedHeight
        addon:RefreshMainLootLog(false)
    end)

    if frame.TitleText then
        frame.TitleText:SetText("General Gold Tracker")
    end

    if frame.CloseButton then
        frame.CloseButton:SetScript("OnClick", function()
            frame:Hide()
        end)
    end

    local startStopButton = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    startStopButton:SetSize(120, 24)
    startStopButton:SetPoint("TOPLEFT", frame, "TOPLEFT", 16, -34)
    startStopButton:SetText("Start Session")
    startStopButton:SetScript("OnClick", function()
        if addon.session.active then
            addon:StopSession()
        else
            addon:StartSession()
        end
    end)
    frame.startStopButton = startStopButton

    local optionsButton = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    optionsButton:SetSize(90, 24)
    optionsButton:SetPoint("LEFT", startStopButton, "RIGHT", 8, 0)
    optionsButton:SetText("Options")
    optionsButton:SetScript("OnClick", function()
        addon:OpenOptions()
    end)

    local historyButton = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    historyButton:SetSize(90, 24)
    historyButton:SetPoint("LEFT", optionsButton, "RIGHT", 8, 0)
    historyButton:SetText("History")
    historyButton:SetScript("OnClick", function()
        addon:OpenHistoryWindow()
    end)
    frame.historyButton = historyButton

    local diagnosisButton = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    diagnosisButton:SetSize(90, 24)
    diagnosisButton:SetPoint("LEFT", historyButton, "RIGHT", 8, 0)
    diagnosisButton:SetText("Diagnosis")
    diagnosisButton:SetScript("OnClick", function()
        if type(addon.ToggleDiagnosisWindow) == "function" then
            addon:ToggleDiagnosisWindow()
        end
    end)
    frame.diagnosisButton = diagnosisButton

    local leftColumnX = 20
    local rightColumnX = 280
    local rowOneY = -66
    local rowStep = -22

    local statusLabel = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    statusLabel:SetPoint("TOPLEFT", frame, "TOPLEFT", leftColumnX, rowOneY)
    statusLabel:SetText("Session:")

    local statusValue = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    statusValue:SetPoint("LEFT", statusLabel, "RIGHT", 8, 0)
    frame.statusValue = statusValue

    local elapsedLabel = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    elapsedLabel:SetPoint("TOPLEFT", frame, "TOPLEFT", rightColumnX, rowOneY)
    elapsedLabel:SetText("Elapsed:")

    local elapsedValue = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    elapsedValue:SetPoint("LEFT", elapsedLabel, "RIGHT", 8, 0)
    frame.timeValue = elapsedValue

    local sourceLabel = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    sourceLabel:SetPoint("TOPLEFT", frame, "TOPLEFT", leftColumnX, rowOneY + rowStep)
    sourceLabel:SetText("Value Source:")

    local sourceValue = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    sourceValue:SetPoint("LEFT", sourceLabel, "RIGHT", 8, 0)
    sourceValue:SetPoint("RIGHT", frame, "CENTER", -20, 0)
    sourceValue:SetJustifyH("LEFT")
    frame.sourceValue = sourceValue

    local itemValueLabel = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    itemValueLabel:SetPoint("TOPLEFT", frame, "TOPLEFT", rightColumnX, rowOneY + rowStep)
    itemValueLabel:SetText("AH value:")

    local itemValue = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    itemValue:SetPoint("LEFT", itemValueLabel, "RIGHT", 8, 0)
    itemValue:SetPoint("RIGHT", frame, "RIGHT", -20, 0)
    itemValue:SetJustifyH("LEFT")
    frame.itemValue = itemValue

    local sessionPerHourLabel = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    sessionPerHourLabel:SetPoint("TOPLEFT", frame, "TOPLEFT", rightColumnX, rowOneY + (rowStep * 2))
    sessionPerHourLabel:SetText("Session/h:")
    frame.sessionPerHourLabel = sessionPerHourLabel

    local sessionPerHourValue = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    sessionPerHourValue:SetPoint("LEFT", sessionPerHourLabel, "RIGHT", 8, 0)
    sessionPerHourValue:SetPoint("RIGHT", frame, "RIGHT", -20, 0)
    sessionPerHourValue:SetJustifyH("LEFT")
    frame.sessionPerHourValue = sessionPerHourValue

    local ahPerHourLabel = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    ahPerHourLabel:SetPoint("TOPLEFT", frame, "TOPLEFT", rightColumnX, rowOneY + (rowStep * 3))
    ahPerHourLabel:SetText("AH/h:")
    frame.ahPerHourLabel = ahPerHourLabel

    local ahPerHourValue = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    ahPerHourValue:SetPoint("LEFT", ahPerHourLabel, "RIGHT", 8, 0)
    ahPerHourValue:SetPoint("RIGHT", frame, "RIGHT", -20, 0)
    ahPerHourValue:SetJustifyH("LEFT")
    frame.ahPerHourValue = ahPerHourValue

    local rawPerHourLabel = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    rawPerHourLabel:SetPoint("TOPLEFT", frame, "TOPLEFT", rightColumnX, rowOneY + (rowStep * 4))
    rawPerHourLabel:SetText("Raw/h:")
    frame.rawPerHourLabel = rawPerHourLabel

    local rawPerHourValue = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    rawPerHourValue:SetPoint("LEFT", rawPerHourLabel, "RIGHT", 8, 0)
    rawPerHourValue:SetPoint("RIGHT", frame, "RIGHT", -20, 0)
    rawPerHourValue:SetJustifyH("LEFT")
    frame.rawPerHourValue = rawPerHourValue

    local goldLabel = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    goldLabel:SetPoint("TOPLEFT", frame, "TOPLEFT", leftColumnX, rowOneY + (rowStep * 2))
    goldLabel:SetText("Raw Looted Gold:")

    local goldValue = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    goldValue:SetPoint("LEFT", goldLabel, "RIGHT", 8, 0)
    frame.goldValue = goldValue

    local itemVendorValueLabel = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    itemVendorValueLabel:SetPoint("TOPLEFT", frame, "TOPLEFT", leftColumnX, rowOneY + (rowStep * 3))
    itemVendorValueLabel:SetText("Vendor items gold:")

    local itemVendorValue = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    itemVendorValue:SetPoint("LEFT", itemVendorValueLabel, "RIGHT", 8, 0)
    frame.itemVendorValue = itemVendorValue

    local highlightLabel = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    highlightLabel:SetPoint("TOPLEFT", frame, "TOPLEFT", leftColumnX, rowOneY + (rowStep * 4))
    highlightLabel:SetText("Highlights:")

    local highlightValue = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    highlightValue:SetPoint("LEFT", highlightLabel, "RIGHT", 8, 0)
    frame.highlightValue = highlightValue

    local totalValueLabel = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    totalValueLabel:SetPoint("TOPLEFT", frame, "TOPLEFT", leftColumnX, rowOneY + (rowStep * 5))
    totalValueLabel:SetText("Session Total:")

    local totalValue = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    totalValue:SetPoint("LEFT", totalValueLabel, "RIGHT", 8, 0)
    frame.totalValue = totalValue

    local totalRawValueLabel = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    totalRawValueLabel:SetPoint("TOPLEFT", frame, "TOPLEFT", leftColumnX, rowOneY + (rowStep * 6))
    totalRawValueLabel:SetText("Session Total Raw:")

    local totalRawValue = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    totalRawValue:SetPoint("LEFT", totalRawValueLabel, "RIGHT", 8, 0)
    frame.totalRawValue = totalRawValue

    local logLabel = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    logLabel:SetPoint("TOP", frame, "TOP", 0, rowOneY + (rowStep * 7))
    logLabel:SetJustifyH("CENTER")
    logLabel:SetText("Loot Log")

    local logItemHeader = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    logItemHeader:SetPoint("TOPLEFT", frame, "TOPLEFT", leftColumnX + 4, rowOneY + (rowStep * 7) - 20)
    logItemHeader:SetText("Item")
    frame.logItemHeaderText = logItemHeader

    local logSourceHeader = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    logSourceHeader:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -20, rowOneY + (rowStep * 7) - 20)
    logSourceHeader:SetWidth(MAIN_LOOT_LOG_SOURCE_WIDTH)
    logSourceHeader:SetJustifyH("LEFT")
    logSourceHeader:SetText("From")
    frame.logSourceHeaderText = logSourceHeader

    local logValueHeader = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    logValueHeader:SetPoint("RIGHT", logSourceHeader, "LEFT", -12, 0)
    logValueHeader:SetWidth(MAIN_LOOT_LOG_VALUE_WIDTH)
    logValueHeader:SetJustifyH("RIGHT")
    logValueHeader:SetText("Value")
    frame.logValueHeaderText = logValueHeader

    local logHeaderUnderline = frame:CreateTexture(nil, "ARTWORK")
    logHeaderUnderline:SetColorTexture(1, 0.82, 0, 0.35)
    logHeaderUnderline:SetPoint("TOPLEFT", frame, "TOPLEFT", leftColumnX, rowOneY + (rowStep * 7) - 36)
    logHeaderUnderline:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -20, rowOneY + (rowStep * 7) - 36)
    logHeaderUnderline:SetHeight(1)
    frame.logHeaderUnderline = logHeaderUnderline

    local logScrollFrame = CreateFrame("ScrollFrame", nil, frame, "UIPanelScrollFrameTemplate")
    logScrollFrame:SetPoint("TOPLEFT", frame, "TOPLEFT", leftColumnX, rowOneY + (rowStep * 7) - 40)
    logScrollFrame:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -30, 20)
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

    local resizeButton = CreateFrame("Button", nil, frame)
    resizeButton:SetSize(16, 16)
    resizeButton:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -6, 6)
    resizeButton:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")
    resizeButton:SetHighlightTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Highlight")
    resizeButton:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Down")
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

    self.mainFrame = frame
    self:ApplyMainWindowAlpha()
    self:ApplyMainWindowGoldPerHourVisibility()
    self:RefreshHistoryButtonVisibility()
    self:RefreshDiagnosisButtonVisibility()
    self:RefreshMainLootLog(false)
end
