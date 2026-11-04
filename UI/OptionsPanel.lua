local _, NS = ...
local function CreateFrame(...)
    return (NS.CreateThemedFrame or _G.CreateFrame)(...)
end
local GoldTracker = NS.GoldTracker

function GoldTracker:OpenOptions(pageID)
    self:CreateOptionsPanel()
    if not self.optionsWindow then
        return
    end

    self.optionsWindow:Show()
    self.optionsWindow:Raise()
    self:RefreshOptionsControls()
    if pageID and self.optionsWindow.selectPage then
        self.optionsWindow.searchInput:SetText("")
        self.optionsWindow.selectPage(pageID)
    end
end

function GoldTracker:RefreshOptionsControls()
    if self.optionsRefresh then self.optionsRefresh() end
end

function GoldTracker:SaveHighlightThresholdInput(editBox, thresholdKey)
    local currentValue = tonumber(self.db and self.db[thresholdKey]) or 0
    local inputValue = tonumber(editBox:GetText())
    if not inputValue or inputValue < 0 then
        editBox:SetText(string.format("%.2f", currentValue / self.COPPER_PER_GOLD))
        return
    end

    self.db[thresholdKey] = math.floor((inputValue * self.COPPER_PER_GOLD) + 0.5)
    self:NormalizeHighlightThresholds()
    self:RefreshOptionsControls()
    self:UpdateMainWindow()
end

function GoldTracker:SaveHistoryRowsPerPageInput(editBox)
    local currentRows = self:GetHistoryRowsPerPage()
    local inputValue = tonumber(editBox:GetText())
    if not inputValue then
        editBox:SetText(tostring(currentRows))
        return
    end

    local rows = math.floor(inputValue + 0.5)
    rows = math.max(5, math.min(30, rows))
    self.db.historyRowsPerPage = rows
    editBox:SetText(tostring(rows))

    if self.historyFrame and self.historyFrame:IsShown() and self.historyFrame.view == "list" then
        self.historyFrame.currentPage = 1
        self:RefreshHistoryWindow()
    end
end

function GoldTracker:SaveHistoryDetailsFontSizeInput(editBox)
    local currentSize = self:GetHistoryDetailsFontSize()
    local inputValue = tonumber(editBox:GetText())
    if not inputValue then
        editBox:SetText(tostring(currentSize))
        return
    end

    local size = math.floor(inputValue + 0.5)
    size = math.max(8, math.min(24, size))
    self.db.historyDetailsFontSize = size
    editBox:SetText(tostring(size))

    if self.ApplyHistoryDetailsFontSize then
        self:ApplyHistoryDetailsFontSize()
    end
    if self.historyFrame and self.historyFrame:IsShown() and self.historyFrame.view == "details" then
        self:RefreshHistoryDetailsWindow()
    end
end

function GoldTracker:SetMarketHistoryNumberOption(dbKey, value, minimumValue, maximumValue, defaultValue)
    local numberValue = tonumber(value) or defaultValue
    numberValue = math.floor((numberValue or minimumValue) + 0.5)
    numberValue = math.max(minimumValue, math.min(maximumValue, numberValue))

    if self.db then
        self.db[dbKey] = numberValue
    end
    if self.optionsResettingPage then return numberValue end
    if type(self.PruneMarketHistory) == "function" then
        self:PruneMarketHistory()
    end
    if self.inventoryFrame and self.inventoryFrame:IsShown() then
        self:RefreshInventoryWindow(false)
    end

    return numberValue
end

function GoldTracker:SaveMarketHistoryNumberInput(editBox, dbKey, minimumValue, maximumValue, defaultValue)
    local savedValue = self:SetMarketHistoryNumberOption(
        dbKey,
        editBox:GetText(),
        minimumValue,
        maximumValue,
        defaultValue
    )
    editBox:SetText(tostring(savedValue))
    self:RefreshOptionsControls()
end

function GoldTracker:SaveAltLowLevelThresholdInput(editBox)
    local value = self:SetAltLowLevelThreshold(editBox:GetText())
    editBox:SetText(tostring(value))
    self:RefreshOptionsControls()
end

function GoldTracker:CreateOptionsPanel(registerOnly)
    if self.optionsPanel and self.optionsWindow then
        return
    end

    local addon = self
    local settingsPanel = self.optionsPanel
    if not settingsPanel then
        settingsPanel = CreateFrame("Frame", "GoldTrackerOptionsPanel", UIParent)

        local settingsTitle = settingsPanel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
        settingsTitle:SetPoint("TOPLEFT", 16, -16)
        settingsTitle:SetText("General Gold Tracker")

        local settingsSubtitle = settingsPanel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
        settingsSubtitle:SetPoint("TOPLEFT", settingsTitle, "BOTTOMLEFT", 0, -8)
        settingsSubtitle:SetWidth(620)
        settingsSubtitle:SetJustifyH("LEFT")
        settingsSubtitle:SetText("Options are managed in a standalone addon window.")

        local openWindowButton = CreateFrame("Button", nil, settingsPanel, "UIPanelButtonTemplate")
        openWindowButton:SetSize(180, 24)
        openWindowButton:SetPoint("TOPLEFT", settingsSubtitle, "BOTTOMLEFT", 0, -18)
        openWindowButton:SetText("Open Options Window")
        openWindowButton:SetScript("OnClick", function()
            addon:OpenOptions()
        end)

        local settingsHint = settingsPanel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
        settingsHint:SetPoint("TOPLEFT", openWindowButton, "BOTTOMLEFT", 0, -12)
        settingsHint:SetWidth(620)
        settingsHint:SetJustifyH("LEFT")
        settingsHint:SetText("You can also open it from the tracker window or with /gt options.")

        self.optionsPanel = settingsPanel
        if Settings and Settings.RegisterCanvasLayoutCategory and Settings.RegisterAddOnCategory then
            local category = Settings.RegisterCanvasLayoutCategory(settingsPanel, "General Gold Tracker")
            Settings.RegisterAddOnCategory(category)
            self.optionsCategory = category
        end
    end
    if registerOnly then
        return
    end

    self:BuildOptionsWindow()
end

function GoldTracker:SetHistoryRowsPerPageOption(value)
    local rows = math.floor((tonumber(value) or self:GetHistoryRowsPerPage()) + 0.5)
    rows = math.max(5, math.min(30, rows))
    if self.db then
        self.db.historyRowsPerPage = rows
    end

    if self.optionsControls and self.optionsControls.historyRowsPerPageValueText then
        self.optionsControls.historyRowsPerPageValueText:SetText(string.format("%d rows", rows))
    end

    if self.historyFrame and self.historyFrame:IsShown() and self.historyFrame.view == "list" then
        self.historyFrame.currentPage = 1
        self:RefreshHistoryWindow()
    end
end

function GoldTracker:SetHistoryDetailsFontSizeOption(value)
    local size = math.floor((tonumber(value) or self:GetHistoryDetailsFontSize()) + 0.5)
    size = math.max(8, math.min(24, size))
    if self.db then
        self.db.historyDetailsFontSize = size
    end

    if self.optionsControls and self.optionsControls.historyDetailsFontSizeValueText then
        self.optionsControls.historyDetailsFontSizeValueText:SetText(string.format("%d px", size))
    end

    if self.ApplyHistoryDetailsFontSize then
        self:ApplyHistoryDetailsFontSize()
    end
    if self.historyFrame and self.historyFrame:IsShown() and self.historyFrame.view == "details" then
        self:RefreshHistoryDetailsWindow()
    end
end

function GoldTracker:SetWorldMapProjectionPinScaleOption(value)
    local scale
    if type(self.NormalizeWorldMapProjectionPinScale) == "function" then
        scale = self:NormalizeWorldMapProjectionPinScale(value)
    else
        scale = tonumber(value) or 1
        scale = math.max(0.6, math.min(2.0, scale))
    end

    if self.db then
        self.db.worldMapProjectionPinScale = scale
    end

    if self.optionsControls and self.optionsControls.worldMapProjectionPinScaleValueText then
        self.optionsControls.worldMapProjectionPinScaleValueText:SetText(string.format("%d%%", math.floor((scale * 100) + 0.5)))
    end

    if self.worldMapRouteDataProvider and type(self.worldMapRouteDataProvider.RefreshAllData) == "function" then
        self.worldMapRouteDataProvider:RefreshAllData()
    end
end

function GoldTracker:SetMapPinIconOption(iconID)
    local normalizedIconID
    if type(self.NormalizeMapPinIcon) == "function" then
        normalizedIconID = self:NormalizeMapPinIcon(iconID)
    else
        normalizedIconID = type(iconID) == "string" and iconID or "loot"
    end

    if self.db then
        self.db.mapPinIcon = normalizedIconID
    end

    if self.worldMapRouteDataProvider and type(self.worldMapRouteDataProvider.RefreshAllData) == "function" then
        self.worldMapRouteDataProvider:RefreshAllData()
    end
    if type(self.RefreshMinimapProjectionPins) == "function" then
        self:RefreshMinimapProjectionPins(true)
    end
    if self.standaloneMapFrame and type(self.RefreshStandaloneMapWindow) == "function" then
        self:RefreshStandaloneMapWindow()
    end

    return normalizedIconID
end
