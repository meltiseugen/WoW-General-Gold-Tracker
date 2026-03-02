local _, NS = ...
local GoldTracker = NS.GoldTracker

function GoldTracker:GetConfiguredWindowAlpha()
    local alpha = (self.db and self.db.windowAlpha) or self.DEFAULTS.windowAlpha
    alpha = tonumber(alpha) or self.DEFAULTS.windowAlpha
    return math.max(0.20, math.min(1.00, alpha))
end

function GoldTracker:ApplyMainWindowAlpha()
    if not self.mainFrame then
        return
    end

    self.mainFrame:SetAlpha(self:GetConfiguredWindowAlpha())
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
    if self.mainFrame and self.mainFrame.log then
        self.mainFrame.log:Clear()
    end
end

function GoldTracker:AddLogMessage(text, r, g, b)
    if not self.mainFrame or not self.mainFrame.log then
        return
    end

    self.mainFrame.log:AddMessage(text, r or 1, g or 1, b or 1)
    self.mainFrame.log:ScrollToBottom()
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
    local highlightCount = tonumber(session.highlightItemCount)
    if not highlightCount then
        highlightCount = (tonumber(session.lowHighlightItemCount) or 0) + (tonumber(session.highHighlightItemCount) or 0)
    end
    frame.highlightValue:SetText(tostring(math.max(0, highlightCount or 0)))
    frame.totalValue:SetText(self:FormatMoney(self:GetSessionTotalValue()))
    frame.totalRawValue:SetText(self:FormatMoney((tonumber(session.goldLooted) or 0) + (tonumber(session.itemVendorValue) or 0)))
    frame.sourceValue:SetText(source.label)
    frame.startStopButton:SetText(session.active and "Stop Session" or "Start Session")
    self:RefreshHistoryButtonVisibility()
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

function GoldTracker:CreateMainWindow()
    if self.mainFrame then
        return
    end

    local addon = self
    local fixedWidth = self.db.windowWidth or self.DEFAULTS.windowWidth
    local frame = CreateFrame("Frame", "GoldTrackerMainFrame", UIParent, "BasicFrameTemplateWithInset")
    frame:SetSize(fixedWidth, self.db.windowHeight or self.DEFAULTS.windowHeight)
    frame:SetPoint("CENTER")
    frame:SetFrameStrata("DIALOG")
    if frame.SetToplevel then
        frame:SetToplevel(true)
    end
    frame:SetMovable(true)
    frame:SetResizable(true)
    if frame.SetResizeBounds then
        frame:SetResizeBounds(fixedWidth, 320, fixedWidth, 1000)
    else
        if frame.SetMinResize then
            frame:SetMinResize(fixedWidth, 320)
        end
        if frame.SetMaxResize then
            frame:SetMaxResize(fixedWidth, 1000)
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

    frame:SetScript("OnSizeChanged", function(_, _, height)
        addon.db.windowWidth = fixedWidth
        addon.db.windowHeight = math.floor(height + 0.5)
    end)

    if frame.TitleText then
        frame.TitleText:SetText("Gold Tracker")
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

    local goldLabel = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    goldLabel:SetPoint("TOPLEFT", frame, "TOPLEFT", leftColumnX, rowOneY + (rowStep * 2))
    goldLabel:SetText("Raw Looted Gold:")

    local goldValue = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    goldValue:SetPoint("LEFT", goldLabel, "RIGHT", 8, 0)
    frame.goldValue = goldValue

    local itemVendorValueLabel = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    itemVendorValueLabel:SetPoint("TOPLEFT", frame, "TOPLEFT", rightColumnX, rowOneY + (rowStep * 2))
    itemVendorValueLabel:SetText("Vendor items gold:")

    local itemVendorValue = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    itemVendorValue:SetPoint("LEFT", itemVendorValueLabel, "RIGHT", 8, 0)
    frame.itemVendorValue = itemVendorValue

    local highlightLabel = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    highlightLabel:SetPoint("TOPLEFT", frame, "TOPLEFT", leftColumnX, rowOneY + (rowStep * 3))
    highlightLabel:SetText("Highlights:")

    local highlightValue = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    highlightValue:SetPoint("LEFT", highlightLabel, "RIGHT", 8, 0)
    frame.highlightValue = highlightValue

    local totalValueLabel = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    totalValueLabel:SetPoint("TOPLEFT", frame, "TOPLEFT", leftColumnX, rowOneY + (rowStep * 4))
    totalValueLabel:SetText("Session Total:")

    local totalValue = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    totalValue:SetPoint("LEFT", totalValueLabel, "RIGHT", 8, 0)
    frame.totalValue = totalValue

    local totalRawValueLabel = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    totalRawValueLabel:SetPoint("TOPLEFT", frame, "TOPLEFT", rightColumnX, rowOneY + (rowStep * 4))
    totalRawValueLabel:SetText("Session Total Raw:")

    local totalRawValue = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    totalRawValue:SetPoint("LEFT", totalRawValueLabel, "RIGHT", 8, 0)
    frame.totalRawValue = totalRawValue

    local logLabel = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    logLabel:SetPoint("TOP", frame, "TOP", 0, rowOneY + (rowStep * 5))
    logLabel:SetJustifyH("CENTER")
    logLabel:SetText("Loot Log")

    local log = CreateFrame("ScrollingMessageFrame", nil, frame)
    log:SetPoint("TOPLEFT", frame, "TOPLEFT", leftColumnX, rowOneY + (rowStep * 5) - 18)
    log:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -20, 20)
    log:SetFontObject(GameFontHighlightSmall)
    log:SetJustifyH("LEFT")
    if log.SetJustifyV then
        log:SetJustifyV("TOP")
    end
    log:SetFading(false)
    log:SetMaxLines(1200)
    if log.SetInsertMode then
        log:SetInsertMode("BOTTOM")
    end
    log:SetIndentedWordWrap(true)
    log:SetHyperlinksEnabled(true)
    log:EnableMouseWheel(true)
    log:SetScript("OnMouseWheel", function(self, delta)
        if delta > 0 then
            self:ScrollUp()
        else
            self:ScrollDown()
        end
    end)
    log:SetScript("OnHyperlinkEnter", function(_, _, link)
        GameTooltip:SetOwner(frame, "ANCHOR_CURSOR")
        GameTooltip:SetHyperlink(link)
        GameTooltip:Show()
    end)
    log:SetScript("OnHyperlinkLeave", function()
        GameTooltip:Hide()
    end)
    frame.log = log

    local resizeButton = CreateFrame("Button", nil, frame)
    resizeButton:SetSize(18, 18)
    resizeButton:SetPoint("BOTTOM", frame, "BOTTOM", 0, 6)
    resizeButton:SetNormalTexture("Interface\\Buttons\\UI-ScrollBar-ScrollDownButton-Up")
    resizeButton:SetHighlightTexture("Interface\\Buttons\\UI-ScrollBar-ScrollDownButton-Highlight")
    resizeButton:SetPushedTexture("Interface\\Buttons\\UI-ScrollBar-ScrollDownButton-Down")
    resizeButton:SetScript("OnMouseDown", function(_, button)
        if button == "LeftButton" then
            frame:StartSizing("BOTTOM")
        end
    end)
    resizeButton:SetScript("OnMouseUp", function()
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
    self:RefreshHistoryButtonVisibility()
end
