local _, NS = ...
local GoldTracker = NS.GoldTracker

function GoldTracker:OpenOptions()
    if not self.optionsCategory then
        return
    end

    local categoryID = self.optionsCategory:GetID()
    if categoryID then
        Settings.OpenToCategory(categoryID)
    end
end

function GoldTracker:RefreshOptionsControls()
    if not self.optionsControls then
        return
    end

    local controls = self.optionsControls
    local source = self:GetCurrentValueSource()
    local alpha = self:GetConfiguredWindowAlpha()

    UIDropDownMenu_SetSelectedValue(controls.valueSourceDropdown, source.id)
    UIDropDownMenu_SetText(controls.valueSourceDropdown, source.label)
    local fallbackSource = self:GetFallbackValueSource()
    if fallbackSource then
        UIDropDownMenu_SetSelectedValue(controls.fallbackValueSourceDropdown, fallbackSource.id)
        UIDropDownMenu_SetText(controls.fallbackValueSourceDropdown, fallbackSource.label)
    else
        UIDropDownMenu_SetSelectedValue(controls.fallbackValueSourceDropdown, "")
        UIDropDownMenu_SetText(controls.fallbackValueSourceDropdown, "None")
    end
    local minimumQuality = self:GetConfiguredMinimumTrackedItemQuality()
    local minimumQualityOption = self.TRACKED_ITEM_QUALITY_BY_ID[minimumQuality]
        or self.TRACKED_ITEM_QUALITY_BY_ID[self.DEFAULTS.minimumTrackedItemQuality]
    UIDropDownMenu_SetSelectedValue(controls.minimumTrackedQualityDropdown, minimumQualityOption.id)
    UIDropDownMenu_SetText(
        controls.minimumTrackedQualityDropdown,
        self:GetColoredItemQualityLabel(minimumQualityOption.id, minimumQualityOption.label)
    )
    controls.autoStartOnLootCheckbox:SetChecked(self.db.autoStartSessionOnFirstLoot)
    controls.autoStartOnEnterWorldCheckbox:SetChecked(self.db.autoStartSessionOnEnterWorld)
    controls.resumeAfterReloadCheckbox:SetChecked(self.db.resumeSessionAfterReload)
    controls.enableHistoryCheckbox:SetChecked(self.db.enableSessionHistory)
    controls.historyRowsPerPageInput:SetText(tostring(self:GetHistoryRowsPerPage()))
    controls.historyDetailsFontSizeInput:SetText(tostring(self:GetHistoryDetailsFontSize()))
    controls.rawLootLogCheckbox:SetChecked(self.db.showRawLootedGoldInLog)
    controls.ignoreMailboxLootCheckbox:SetChecked(self:IsIgnoreMailboxLootWhenMailOpenEnabled())
    controls.mainWindowGoldPerHourCheckbox:SetChecked(self:IsMainWindowGoldPerHourEnabled())
    controls.totalWindowGoldPerHourCheckbox:SetChecked(self:IsTotalWindowGoldPerHourEnabled())
    controls.lootSourceTrackingCheckbox:SetChecked(self:IsLootSourceTrackingEnabled())
    if controls.diagnosticsPanelCheckbox then
        controls.diagnosticsPanelCheckbox:SetChecked(self:IsDiagnosticsPanelEnabled())
    end
    controls.transparencySlider:SetValue(alpha)
    controls.transparencyValueText:SetText(string.format("Current opacity: %d%%", math.floor((alpha * 100) + 0.5)))
    if controls.alertsRefresh then
        controls.alertsRefresh()
    end
    if type(self.RefreshDiagnosisButtonVisibility) == "function" then
        self:RefreshDiagnosisButtonVisibility()
    end
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

function GoldTracker:CreateOptionsPanel()
    if self.optionsPanel then
        return
    end

    local addon = self
    local panel = CreateFrame("Frame", "GoldTrackerOptionsPanel", UIParent)

    local title = panel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 16, -16)
    title:SetText("Gold Tracker")

    local subtitle = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    subtitle:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -8)
    subtitle:SetText("Session-based loot value tracking.")

    local tabOrder = { "General", "Tracking", "History", "Alerts", "Experimental" }
    local tabs = {}
    local selectedTab = "General"

    local function CreateTab(key)
        local container = CreateFrame("Frame", nil, panel)
        container:SetPoint("TOPLEFT", panel, "TOPLEFT", 20, -112)
        container:SetPoint("BOTTOMRIGHT", panel, "BOTTOMRIGHT", -42, 18)
        container:Hide()

        local scrollFrame = CreateFrame("ScrollFrame", nil, container, "UIPanelScrollFrameTemplate")
        scrollFrame:SetPoint("TOPLEFT", container, "TOPLEFT", 0, 0)
        scrollFrame:SetPoint("BOTTOMRIGHT", container, "BOTTOMRIGHT", 0, 0)
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

        local content = CreateFrame("Frame", nil, scrollFrame)
        content:SetSize(1, 1)
        scrollFrame:SetScrollChild(content)

        container:SetScript("OnSizeChanged", function(_, width)
            content:SetWidth(math.max(1, width - 32))
        end)
        content:SetWidth(math.max(1, (container:GetWidth() or 0) - 32))

        tabs[key] = {
            container = container,
            scrollFrame = scrollFrame,
            content = content,
            button = nil,
        }

        return tabs[key]
    end

    local function ApplyTabVisualState(button, isSelected)
        if not button then
            return
        end

        local buttonName = button:GetName()
        local hasPanelRegions = (button.Left or (buttonName and _G[buttonName .. "Left"]))
            and (button.Middle or (buttonName and _G[buttonName .. "Middle"]))
            and (button.Right or (buttonName and _G[buttonName .. "Right"]))

        if hasPanelRegions and PanelTemplates_SelectTab and PanelTemplates_DeselectTab then
            local ok
            if isSelected then
                ok = pcall(PanelTemplates_SelectTab, button)
            else
                ok = pcall(PanelTemplates_DeselectTab, button)
            end
            if ok then
                return
            end
        end

        button:SetEnabled(not isSelected)
    end

    local function SelectTab(tabKey)
        selectedTab = tabKey or "General"
        for _, key in ipairs(tabOrder) do
            local tab = tabs[key]
            local isSelected = key == selectedTab
            if tab and tab.container then
                if isSelected then
                    tab.container:Show()
                    if tab.scrollFrame then
                        tab.scrollFrame:SetVerticalScroll(0)
                    end
                else
                    tab.container:Hide()
                end
            end
            if tab and tab.button then
                ApplyTabVisualState(tab.button, isSelected)
            end
        end
    end

    local tabsUnderline = panel:CreateTexture(nil, "ARTWORK")
    tabsUnderline:SetColorTexture(1, 0.82, 0, 0.35)
    tabsUnderline:SetPoint("TOPLEFT", panel, "TOPLEFT", 16, -112)
    tabsUnderline:SetPoint("TOPRIGHT", panel, "TOPRIGHT", -16, -112)
    tabsUnderline:SetHeight(1)

    local previousTabButton
    for index, tabName in ipairs(tabOrder) do
        local tabKey = tabName
        local tabButtonName = "GoldTrackerOptionsTab" .. index
        local tabButton
        local okCreate, createdButton = pcall(CreateFrame, "Button", tabButtonName, panel, "PanelTopTabButtonTemplate")
        if okCreate and createdButton then
            tabButton = createdButton
        else
            okCreate, createdButton = pcall(CreateFrame, "Button", tabButtonName, panel, "PanelTabButtonTemplate")
            if okCreate and createdButton then
                tabButton = createdButton
            end
        end

        if not tabButton then
            tabButton = CreateFrame("Button", tabButtonName, panel, "UIPanelButtonTemplate")
            tabButton:SetSize(92, 22)
        end

        if not tabButton.Text then
            tabButton.Text = _G[tabButtonName .. "Text"] or tabButton:GetFontString()
            if not tabButton.Text then
                local text = tabButton:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
                text:SetPoint("CENTER", tabButton, "CENTER", 0, 0)
                tabButton:SetFontString(text)
                tabButton.Text = text
            end
        end

        tabButton:SetID(index)
        tabButton:SetText(tabKey)
        if PanelTemplates_TabResize and (tabButton.Left or _G[tabButtonName .. "Left"]) then
            pcall(PanelTemplates_TabResize, tabButton, 12, nil, 70)
        end
        tabButton:ClearAllPoints()
        if previousTabButton then
            tabButton:SetPoint("LEFT", previousTabButton, "RIGHT", 8, 0)
        else
            tabButton:SetPoint("TOPLEFT", panel, "TOPLEFT", 16, -78)
        end
        tabButton:SetScript("OnClick", function()
            SelectTab(tabKey)
        end)

        local tab = CreateTab(tabKey)
        tab.button = tabButton
        previousTabButton = tabButton
    end

    local generalContent = tabs.General.content
    local trackingContent = tabs.Tracking.content
    local historyContent = tabs.History.content
    local generalLeftColumnX = 12
    local generalSecondColumnOffsetX = 320

    local sourceLabel = generalContent:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    sourceLabel:SetPoint("TOPLEFT", generalContent, "TOPLEFT", generalLeftColumnX, -8)
    sourceLabel:SetText("Item value source")

    local dropdown = CreateFrame("Frame", "GoldTrackerValueSourceDropdown", generalContent, "UIDropDownMenuTemplate")
    dropdown:SetPoint("TOPLEFT", sourceLabel, "BOTTOMLEFT", -16, -6)
    UIDropDownMenu_SetWidth(dropdown, 240)
    UIDropDownMenu_Initialize(dropdown, function(_, level)
        for _, source in ipairs(addon.VALUE_SOURCES) do
            local info = UIDropDownMenu_CreateInfo()
            local sourceID = source.id
            info.text = source.label
            info.value = sourceID
            info.checked = addon.db.valueSource == sourceID
            info.func = function()
                addon.db.valueSource = sourceID
                if addon.db.fallbackValueSource == sourceID then
                    addon.db.fallbackValueSource = ""
                end
                addon.tsmWarningShown = false
                addon:RefreshOptionsControls()
                addon:UpdateMainWindow()
            end
            UIDropDownMenu_AddButton(info, level)
        end
    end)

    local fallbackSourceLabel = generalContent:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    fallbackSourceLabel:SetPoint("TOPLEFT", sourceLabel, "TOPLEFT", generalSecondColumnOffsetX, 0)
    fallbackSourceLabel:SetText("Fallback value source")

    local fallbackDropdown = CreateFrame("Frame", "GoldTrackerFallbackValueSourceDropdown", generalContent, "UIDropDownMenuTemplate")
    fallbackDropdown:SetPoint("TOPLEFT", fallbackSourceLabel, "BOTTOMLEFT", -16, -6)
    UIDropDownMenu_SetWidth(fallbackDropdown, 240)
    UIDropDownMenu_Initialize(fallbackDropdown, function(_, level)
        local noneInfo = UIDropDownMenu_CreateInfo()
        noneInfo.text = "None"
        noneInfo.value = ""
        noneInfo.checked = (addon.db.fallbackValueSource or "") == ""
        noneInfo.func = function()
            addon.db.fallbackValueSource = ""
            addon:RefreshOptionsControls()
            addon:UpdateMainWindow()
        end
        UIDropDownMenu_AddButton(noneInfo, level)

        for _, source in ipairs(addon.VALUE_SOURCES) do
            local info = UIDropDownMenu_CreateInfo()
            local sourceID = source.id
            info.text = source.label
            info.value = sourceID
            info.checked = addon.db.fallbackValueSource == sourceID
            info.disabled = addon.db.valueSource == sourceID
            info.func = function()
                addon.db.fallbackValueSource = sourceID
                addon:RefreshOptionsControls()
                addon:UpdateMainWindow()
            end
            UIDropDownMenu_AddButton(info, level)
        end
    end)

    local ignoreMailboxLootCheckbox = CreateFrame("CheckButton", nil, generalContent, "UICheckButtonTemplate")
    ignoreMailboxLootCheckbox:SetPoint("TOPLEFT", dropdown, "BOTTOMLEFT", 16, -22)
    ignoreMailboxLootCheckbox:SetScript("OnClick", function(button)
        addon.db.ignoreMailboxLootWhenMailOpen = button:GetChecked() and true or false
    end)

    local ignoreMailboxLootLabel = generalContent:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    ignoreMailboxLootLabel:SetPoint("LEFT", ignoreMailboxLootCheckbox, "RIGHT", 4, 1)
    ignoreMailboxLootLabel:SetText("Ignore mailbox loot while mail window is open")

    local mainWindowGoldPerHourCheckbox = CreateFrame("CheckButton", nil, generalContent, "UICheckButtonTemplate")
    mainWindowGoldPerHourCheckbox:SetPoint("TOPLEFT", ignoreMailboxLootCheckbox, "BOTTOMLEFT", 0, -8)
    mainWindowGoldPerHourCheckbox:SetScript("OnClick", function(button)
        addon.db.showMainWindowGoldPerHour = button:GetChecked() and true or false
        addon:UpdateMainWindow()
    end)

    local mainWindowGoldPerHourLabel = generalContent:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    mainWindowGoldPerHourLabel:SetPoint("LEFT", mainWindowGoldPerHourCheckbox, "RIGHT", 4, 1)
    mainWindowGoldPerHourLabel:SetText("Show gold per hour in main tracker window")

    local totalWindowGoldPerHourCheckbox = CreateFrame("CheckButton", nil, generalContent, "UICheckButtonTemplate")
    totalWindowGoldPerHourCheckbox:SetPoint("TOPLEFT", mainWindowGoldPerHourCheckbox, "BOTTOMLEFT", 0, -8)
    totalWindowGoldPerHourCheckbox:SetScript("OnClick", function(button)
        addon.db.showTotalWindowGoldPerHour = button:GetChecked() and true or false
        addon:UpdateMainWindow()
    end)

    local totalWindowGoldPerHourLabel = generalContent:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    totalWindowGoldPerHourLabel:SetPoint("LEFT", totalWindowGoldPerHourCheckbox, "RIGHT", 4, 1)
    totalWindowGoldPerHourLabel:SetText("Show gold per hour in /gtt total window")

    local minimumQualityLabel = trackingContent:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    minimumQualityLabel:SetPoint("TOPLEFT", trackingContent, "TOPLEFT", 12, -8)
    minimumQualityLabel:SetText("Min item quality for AH and loot log")

    local minimumQualityDropdown = CreateFrame("Frame", "GoldTrackerMinimumQualityDropdown", trackingContent, "UIDropDownMenuTemplate")
    minimumQualityDropdown:SetPoint("TOPLEFT", minimumQualityLabel, "BOTTOMLEFT", -16, -6)
    UIDropDownMenu_SetWidth(minimumQualityDropdown, 240)
    UIDropDownMenu_Initialize(minimumQualityDropdown, function(_, level)
        for _, qualityOption in ipairs(addon.TRACKED_ITEM_QUALITY_OPTIONS) do
            local info = UIDropDownMenu_CreateInfo()
            local qualityID = qualityOption.id
            info.text = addon:GetColoredItemQualityLabel(qualityID, qualityOption.label)
            info.value = qualityID
            info.checked = addon:GetConfiguredMinimumTrackedItemQuality() == qualityID
            info.func = function()
                addon.db.minimumTrackedItemQuality = qualityID
                addon:NormalizeMinimumTrackedItemQuality()
                addon:RefreshOptionsControls()
                addon:UpdateMainWindow()
                if addon.historyFrame and addon.historyFrame.view == "details" then
                    addon:RefreshHistoryDetailsWindow()
                end
            end
            UIDropDownMenu_AddButton(info, level)
        end
    end)

    local autoStartOnLootCheckbox = CreateFrame("CheckButton", nil, trackingContent, "UICheckButtonTemplate")
    autoStartOnLootCheckbox:SetPoint("TOPLEFT", minimumQualityDropdown, "BOTTOMLEFT", 0, -22)
    autoStartOnLootCheckbox:SetScript("OnClick", function(button)
        addon.db.autoStartSessionOnFirstLoot = button:GetChecked() and true or false
    end)

    local autoStartOnLootLabel = trackingContent:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    autoStartOnLootLabel:SetPoint("LEFT", autoStartOnLootCheckbox, "RIGHT", 4, 1)
    autoStartOnLootLabel:SetText("Auto start session on first loot")

    local autoStartOnEnterWorldCheckbox = CreateFrame("CheckButton", nil, trackingContent, "UICheckButtonTemplate")
    autoStartOnEnterWorldCheckbox:SetPoint("TOPLEFT", autoStartOnLootCheckbox, "BOTTOMLEFT", 0, -8)
    autoStartOnEnterWorldCheckbox:SetScript("OnClick", function(button)
        addon.db.autoStartSessionOnEnterWorld = button:GetChecked() and true or false
    end)

    local autoStartOnEnterWorldLabel = trackingContent:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    autoStartOnEnterWorldLabel:SetPoint("LEFT", autoStartOnEnterWorldCheckbox, "RIGHT", 4, 1)
    autoStartOnEnterWorldLabel:SetText("Auto start session on world/instance entry and reload")

    local resumeAfterReloadCheckbox = CreateFrame("CheckButton", nil, trackingContent, "UICheckButtonTemplate")
    resumeAfterReloadCheckbox:SetPoint("TOPLEFT", autoStartOnEnterWorldCheckbox, "BOTTOMLEFT", 0, -8)
    resumeAfterReloadCheckbox:SetScript("OnClick", function(button)
        addon.db.resumeSessionAfterReload = button:GetChecked() and true or false
        if not addon.db.resumeSessionAfterReload then
            addon:ClearPendingReloadSession()
        end
    end)

    local resumeAfterReloadLabel = trackingContent:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    resumeAfterReloadLabel:SetPoint("LEFT", resumeAfterReloadCheckbox, "RIGHT", 4, 1)
    resumeAfterReloadLabel:SetText("Resume active session after /reload")

    local enableHistoryCheckbox = CreateFrame("CheckButton", nil, historyContent, "UICheckButtonTemplate")
    enableHistoryCheckbox:SetPoint("TOPLEFT", historyContent, "TOPLEFT", -2, -6)
    enableHistoryCheckbox:SetScript("OnClick", function(button)
        addon.db.enableSessionHistory = button:GetChecked() and true or false
        addon:RefreshHistoryButtonVisibility()
        if addon.historyFrame and not addon.db.enableSessionHistory then
            addon.historyFrame:Hide()
        end
    end)

    local enableHistoryLabel = historyContent:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    enableHistoryLabel:SetPoint("LEFT", enableHistoryCheckbox, "RIGHT", 4, 1)
    enableHistoryLabel:SetText("Enable session history")

    local historyRowsPerPageLabel = historyContent:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    historyRowsPerPageLabel:SetPoint("TOPLEFT", enableHistoryCheckbox, "BOTTOMLEFT", 4, -14)
    historyRowsPerPageLabel:SetText("History rows per page (5-30)")

    local historyRowsPerPageInput = CreateFrame("EditBox", nil, historyContent, "InputBoxTemplate")
    historyRowsPerPageInput:SetSize(60, 24)
    historyRowsPerPageInput:SetPoint("TOPLEFT", historyRowsPerPageLabel, "BOTTOMLEFT", -4, -6)
    historyRowsPerPageInput:SetAutoFocus(false)
    historyRowsPerPageInput:SetNumeric(true)
    historyRowsPerPageInput:SetScript("OnEnterPressed", function(editBox)
        editBox:ClearFocus()
        addon:SaveHistoryRowsPerPageInput(editBox)
    end)
    historyRowsPerPageInput:SetScript("OnEditFocusLost", function(editBox)
        addon:SaveHistoryRowsPerPageInput(editBox)
    end)

    local historyDetailsFontSizeLabel = historyContent:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    historyDetailsFontSizeLabel:SetPoint("TOPLEFT", historyRowsPerPageInput, "BOTTOMLEFT", 4, -12)
    historyDetailsFontSizeLabel:SetText("History details font size (8-24)")

    local historyDetailsFontSizeInput = CreateFrame("EditBox", nil, historyContent, "InputBoxTemplate")
    historyDetailsFontSizeInput:SetSize(60, 24)
    historyDetailsFontSizeInput:SetPoint("TOPLEFT", historyDetailsFontSizeLabel, "BOTTOMLEFT", -4, -6)
    historyDetailsFontSizeInput:SetAutoFocus(false)
    historyDetailsFontSizeInput:SetNumeric(true)
    historyDetailsFontSizeInput:SetScript("OnEnterPressed", function(editBox)
        editBox:ClearFocus()
        addon:SaveHistoryDetailsFontSizeInput(editBox)
    end)
    historyDetailsFontSizeInput:SetScript("OnEditFocusLost", function(editBox)
        addon:SaveHistoryDetailsFontSizeInput(editBox)
    end)

    local rawLootLogCheckbox = CreateFrame("CheckButton", nil, trackingContent, "UICheckButtonTemplate")
    rawLootLogCheckbox:SetPoint("TOPLEFT", resumeAfterReloadCheckbox, "BOTTOMLEFT", 0, -10)
    rawLootLogCheckbox:SetScript("OnClick", function(button)
        addon.db.showRawLootedGoldInLog = button:GetChecked() and true or false
    end)

    local rawLootLogLabel = trackingContent:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    rawLootLogLabel:SetPoint("LEFT", rawLootLogCheckbox, "RIGHT", 4, 1)
    rawLootLogLabel:SetText("Show raw looted gold entries in loot log")

    local lootSourceTrackingCheckbox = CreateFrame("CheckButton", nil, trackingContent, "UICheckButtonTemplate")
    lootSourceTrackingCheckbox:SetPoint("TOPLEFT", rawLootLogCheckbox, "BOTTOMLEFT", 0, -8)
    lootSourceTrackingCheckbox:SetScript("OnClick", function(button)
        addon.db.enableLootSourceTracking = button:GetChecked() and true or false
        if not addon.db.enableLootSourceTracking then
            addon:OnLootClosed()
        end
    end)

    local lootSourceTrackingLabel = trackingContent:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    lootSourceTrackingLabel:SetPoint("LEFT", lootSourceTrackingCheckbox, "RIGHT", 4, 1)
    lootSourceTrackingLabel:SetText("Track loot source (From: unit/node/aoe)")

    local hint = trackingContent:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    hint:SetPoint("TOPLEFT", lootSourceTrackingCheckbox, "BOTTOMLEFT", 4, -10)
    hint:SetWidth(560)
    hint:SetJustifyH("LEFT")
    hint:SetText("Use /gt to open the tracker. Auto-start on loot works only while the tracker window is open.")

    local transparencyLabel = generalContent:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    transparencyLabel:SetPoint("TOPLEFT", totalWindowGoldPerHourLabel, "BOTTOMLEFT", 0, -20)
    transparencyLabel:SetText("Window background transparency")

    local transparencySlider = CreateFrame("Slider", "GoldTrackerTransparencySlider", generalContent, "OptionsSliderTemplate")
    transparencySlider:SetPoint("TOPLEFT", transparencyLabel, "BOTTOMLEFT", -10, -10)
    transparencySlider:SetWidth(240)
    transparencySlider:SetMinMaxValues(0.20, 1.00)
    transparencySlider:SetValueStep(0.05)
    if transparencySlider.SetObeyStepOnDrag then
        transparencySlider:SetObeyStepOnDrag(true)
    end

    local sliderLow = _G[transparencySlider:GetName() .. "Low"]
    local sliderHigh = _G[transparencySlider:GetName() .. "High"]
    local sliderText = _G[transparencySlider:GetName() .. "Text"]
    if sliderLow then
        sliderLow:SetText("20%")
    end
    if sliderHigh then
        sliderHigh:SetText("100%")
    end
    if sliderText then
        sliderText:SetText("")
    end

    local transparencyValueText = generalContent:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    transparencyValueText:SetPoint("TOP", transparencySlider, "BOTTOM", 0, -18)
    transparencyValueText:SetJustifyH("CENTER")
    transparencyValueText:SetText("")

    transparencySlider:SetScript("OnValueChanged", function(_, value)
        local alpha = math.floor((value * 100) + 0.5) / 100
        alpha = math.max(0.20, math.min(1.00, alpha))
        addon.db.windowAlpha = alpha
        addon:ApplyMainWindowAlpha()
        transparencyValueText:SetText(string.format("Current opacity: %d%%", math.floor((alpha * 100) + 0.5)))
    end)

    generalContent:SetHeight(420)
    trackingContent:SetHeight(560)
    historyContent:SetHeight(320)

    local alertsContent = tabs.Alerts.content

    local alertsEnabledCheckbox = CreateFrame("CheckButton", nil, alertsContent, "UICheckButtonTemplate")
    alertsEnabledCheckbox:SetPoint("TOPLEFT", alertsContent, "TOPLEFT", -2, -6)
    alertsEnabledCheckbox:SetScript("OnClick", function(button)
        addon.db.notificationsEnabled = button:GetChecked() and true or false
        addon:RefreshOptionsControls()
    end)

    local alertsEnabledLabel = alertsContent:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    alertsEnabledLabel:SetPoint("LEFT", alertsEnabledCheckbox, "RIGHT", 4, 1)
    alertsEnabledLabel:SetText("Enable alerts")

    local alertsHint = alertsContent:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    alertsHint:SetPoint("TOPLEFT", alertsEnabledCheckbox, "BOTTOMLEFT", 4, -8)
    alertsHint:SetWidth(620)
    alertsHint:SetJustifyH("LEFT")
    alertsHint:SetText("You can add multiple rules. Each rule has its own threshold, sound, and display mode.")

    local function BuildSoundDropdownText(soundID)
        local option = addon.ALERT_SOUND_BY_ID[soundID] or addon.ALERT_SOUND_OPTIONS[1]
        return option and option.label or "Unknown"
    end

    local function BuildDisplayDropdownText(displayID)
        local option = addon.ALERT_DISPLAY_BY_ID[displayID] or addon.ALERT_DISPLAY_OPTIONS[1]
        return option and option.label or "Unknown"
    end

    local function CreateAlertRuleRow(parent, listKey, refreshAlertsControls)
        local row = CreateFrame("Frame", nil, parent)
        row:SetHeight(28)

        local enabledCheckbox = CreateFrame("CheckButton", nil, row, "UICheckButtonTemplate")
        enabledCheckbox:SetPoint("TOPLEFT", row, "TOPLEFT", -4, -3)
        enabledCheckbox:SetScript("OnClick", function(button)
            addon:SetAlertRuleEnabled(listKey, row.ruleIndex, button:GetChecked() == true)
        end)
        row.enabledCheckbox = enabledCheckbox

        local thresholdInput = CreateFrame("EditBox", nil, row, "InputBoxTemplate")
        thresholdInput:SetSize(72, 22)
        thresholdInput:SetPoint("LEFT", enabledCheckbox, "RIGHT", 2, 0)
        thresholdInput:SetAutoFocus(false)
        thresholdInput:SetNumeric(false)
        thresholdInput:SetScript("OnEnterPressed", function(editBox)
            editBox:ClearFocus()
            if not addon:SetAlertRuleThresholdGold(listKey, row.ruleIndex, editBox:GetText()) then
                refreshAlertsControls()
            else
                addon:RefreshOptionsControls()
            end
        end)
        thresholdInput:SetScript("OnEditFocusLost", function(editBox)
            if not addon:SetAlertRuleThresholdGold(listKey, row.ruleIndex, editBox:GetText()) then
                refreshAlertsControls()
            else
                addon:RefreshOptionsControls()
            end
        end)
        row.thresholdInput = thresholdInput

        local thresholdUnit = row:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
        thresholdUnit:SetPoint("LEFT", thresholdInput, "RIGHT", 4, 0)
        thresholdUnit:SetText("g")
        row.thresholdUnitText = thresholdUnit

        local soundDropdown = CreateFrame("Frame", nil, row, "UIDropDownMenuTemplate")
        soundDropdown:SetPoint("LEFT", thresholdUnit, "RIGHT", -6, -1)
        UIDropDownMenu_SetWidth(soundDropdown, 145)
        UIDropDownMenu_Initialize(soundDropdown, function(_, level)
            for _, soundOption in ipairs(addon.ALERT_SOUND_OPTIONS) do
                local info = UIDropDownMenu_CreateInfo()
                info.text = soundOption.label
                info.value = soundOption.id
                local rules = addon:GetAlertRules(listKey)
                local currentRule = rules[row.ruleIndex]
                info.checked = currentRule and currentRule.soundID == soundOption.id
                info.func = function()
                    addon:SetAlertRuleSoundID(listKey, row.ruleIndex, soundOption.id)
                    addon:RefreshOptionsControls()
                end
                UIDropDownMenu_AddButton(info, level)
            end
        end)
        row.soundDropdown = soundDropdown

        local displayDropdown = CreateFrame("Frame", nil, row, "UIDropDownMenuTemplate")
        displayDropdown:SetPoint("LEFT", soundDropdown, "RIGHT", 6, 0)
        UIDropDownMenu_SetWidth(displayDropdown, 170)
        UIDropDownMenu_Initialize(displayDropdown, function(_, level)
            for _, displayOption in ipairs(addon.ALERT_DISPLAY_OPTIONS) do
                local info = UIDropDownMenu_CreateInfo()
                info.text = displayOption.label
                info.value = displayOption.id
                local rules = addon:GetAlertRules(listKey)
                local currentRule = rules[row.ruleIndex]
                info.checked = currentRule and currentRule.displayID == displayOption.id
                info.func = function()
                    addon:SetAlertRuleDisplayID(listKey, row.ruleIndex, displayOption.id)
                    addon:RefreshOptionsControls()
                end
                UIDropDownMenu_AddButton(info, level)
            end
        end)
        row.displayDropdown = displayDropdown

        local removeButton = CreateFrame("Button", nil, row, "UIPanelButtonTemplate")
        removeButton:SetSize(24, 20)
        removeButton:SetPoint("LEFT", displayDropdown, "RIGHT", 14, 0)
        removeButton:SetText("X")
        removeButton:SetScript("OnClick", function()
            addon:RemoveAlertRule(listKey, row.ruleIndex)
            addon:RefreshOptionsControls()
        end)
        row.removeButton = removeButton

        return row
    end

    local function RefreshAlertRuleSection(listKey, rowsContainer, rowPool, refreshAlertsControls)
        local rules = addon:GetAlertRules(listKey)
        local rowHeight = 28
        local rowSpacing = 4
        local contentHeight = 0

        for index = 1, #rules do
            if not rowPool[index] then
                rowPool[index] = CreateAlertRuleRow(rowsContainer, listKey, refreshAlertsControls)
            end

            local row = rowPool[index]
            row.ruleIndex = index
            row:ClearAllPoints()
            row:SetPoint("TOPLEFT", rowsContainer, "TOPLEFT", 0, -((index - 1) * (rowHeight + rowSpacing)))
            row:SetPoint("RIGHT", rowsContainer, "RIGHT", -4, 0)
            row:Show()

            local rule = rules[index]
            row.enabledCheckbox:SetChecked(rule.enabled == true)
            row.thresholdInput:SetText(string.format("%.2f", (tonumber(rule.threshold) or 0) / addon.COPPER_PER_GOLD))
            UIDropDownMenu_SetSelectedValue(row.soundDropdown, rule.soundID)
            UIDropDownMenu_SetText(row.soundDropdown, BuildSoundDropdownText(rule.soundID))
            UIDropDownMenu_SetSelectedValue(row.displayDropdown, rule.displayID)
            UIDropDownMenu_SetText(row.displayDropdown, BuildDisplayDropdownText(rule.displayID))
            row.removeButton:SetEnabled(#rules > 0)

            contentHeight = (index * rowHeight) + ((index - 1) * rowSpacing)
        end

        for index = (#rules + 1), #rowPool do
            rowPool[index]:Hide()
        end

        rowsContainer:SetHeight(math.max(1, contentHeight))
        return contentHeight
    end

    local milestonesHeader = alertsContent:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    milestonesHeader:SetPoint("TOPLEFT", alertsHint, "BOTTOMLEFT", -4, -18)
    milestonesHeader:SetText("Session total milestone alerts")

    local addMilestoneButton = CreateFrame("Button", nil, alertsContent, "UIPanelButtonTemplate")
    addMilestoneButton:SetSize(120, 22)
    addMilestoneButton:SetPoint("LEFT", milestonesHeader, "RIGHT", 12, 0)
    addMilestoneButton:SetText("Add milestone")

    local milestoneRowsContainer = CreateFrame("Frame", nil, alertsContent)
    milestoneRowsContainer:SetPoint("TOPLEFT", milestonesHeader, "BOTTOMLEFT", 0, -8)
    milestoneRowsContainer:SetPoint("RIGHT", alertsContent, "RIGHT", -4, 0)
    milestoneRowsContainer:SetHeight(1)

    local highValueHeader = alertsContent:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    highValueHeader:SetPoint("TOPLEFT", milestoneRowsContainer, "BOTTOMLEFT", 0, -18)
    highValueHeader:SetText("High-value drop alerts")

    local addHighValueButton = CreateFrame("Button", nil, alertsContent, "UIPanelButtonTemplate")
    addHighValueButton:SetSize(120, 22)
    addHighValueButton:SetPoint("LEFT", highValueHeader, "RIGHT", 12, 0)
    addHighValueButton:SetText("Add drop rule")

    local highValueRowsContainer = CreateFrame("Frame", nil, alertsContent)
    highValueRowsContainer:SetPoint("TOPLEFT", highValueHeader, "BOTTOMLEFT", 0, -8)
    highValueRowsContainer:SetPoint("RIGHT", alertsContent, "RIGHT", -4, 0)
    highValueRowsContainer:SetHeight(1)

    local noLootHeader = alertsContent:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    noLootHeader:SetPoint("TOPLEFT", highValueRowsContainer, "BOTTOMLEFT", 0, -22)
    noLootHeader:SetText("No loot alert")

    local noLootEnabledCheckbox = CreateFrame("CheckButton", nil, alertsContent, "UICheckButtonTemplate")
    noLootEnabledCheckbox:SetPoint("TOPLEFT", noLootHeader, "BOTTOMLEFT", -4, -8)
    noLootEnabledCheckbox:SetScript("OnClick", function(button)
        addon.db.noLootAlertEnabled = button:GetChecked() and true or false
    end)

    local noLootEnabledLabel = alertsContent:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    noLootEnabledLabel:SetPoint("LEFT", noLootEnabledCheckbox, "RIGHT", 4, 1)
    noLootEnabledLabel:SetText("Alert when no loot is received for")

    local noLootMinutesInput = CreateFrame("EditBox", nil, alertsContent, "InputBoxTemplate")
    noLootMinutesInput:SetSize(60, 22)
    noLootMinutesInput:SetPoint("LEFT", noLootEnabledLabel, "RIGHT", 8, 0)
    noLootMinutesInput:SetAutoFocus(false)
    noLootMinutesInput:SetNumeric(true)
    noLootMinutesInput:SetScript("OnEnterPressed", function(editBox)
        editBox:ClearFocus()
        if not addon:SetNoLootAlertMinutes(editBox:GetText()) then
            addon:RefreshOptionsControls()
        else
            addon:RefreshOptionsControls()
        end
    end)
    noLootMinutesInput:SetScript("OnEditFocusLost", function(editBox)
        if not addon:SetNoLootAlertMinutes(editBox:GetText()) then
            addon:RefreshOptionsControls()
        else
            addon:RefreshOptionsControls()
        end
    end)

    local noLootMinutesLabel = alertsContent:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    noLootMinutesLabel:SetPoint("LEFT", noLootMinutesInput, "RIGHT", 6, 0)
    noLootMinutesLabel:SetText("minutes")

    local noLootSoundLabel = alertsContent:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
    noLootSoundLabel:SetPoint("TOPLEFT", noLootEnabledCheckbox, "BOTTOMLEFT", 4, -12)
    noLootSoundLabel:SetText("Sound")

    local noLootSoundDropdown = CreateFrame("Frame", nil, alertsContent, "UIDropDownMenuTemplate")
    noLootSoundDropdown:SetPoint("TOPLEFT", noLootSoundLabel, "BOTTOMLEFT", -16, -4)
    UIDropDownMenu_SetWidth(noLootSoundDropdown, 170)
    UIDropDownMenu_Initialize(noLootSoundDropdown, function(_, level)
        for _, soundOption in ipairs(addon.ALERT_SOUND_OPTIONS) do
            local info = UIDropDownMenu_CreateInfo()
            info.text = soundOption.label
            info.value = soundOption.id
            info.checked = addon.db.noLootAlertSoundID == soundOption.id
            info.func = function()
                addon.db.noLootAlertSoundID = soundOption.id
                addon:RefreshOptionsControls()
            end
            UIDropDownMenu_AddButton(info, level)
        end
    end)

    local noLootDisplayLabel = alertsContent:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
    noLootDisplayLabel:SetPoint("TOPLEFT", noLootSoundDropdown, "TOPRIGHT", 16, 0)
    noLootDisplayLabel:SetText("Display")

    local noLootDisplayDropdown = CreateFrame("Frame", nil, alertsContent, "UIDropDownMenuTemplate")
    noLootDisplayDropdown:SetPoint("TOPLEFT", noLootDisplayLabel, "BOTTOMLEFT", -16, -4)
    UIDropDownMenu_SetWidth(noLootDisplayDropdown, 200)
    UIDropDownMenu_Initialize(noLootDisplayDropdown, function(_, level)
        for _, displayOption in ipairs(addon.ALERT_DISPLAY_OPTIONS) do
            local info = UIDropDownMenu_CreateInfo()
            info.text = displayOption.label
            info.value = displayOption.id
            info.checked = addon.db.noLootAlertDisplayID == displayOption.id
            info.func = function()
                addon.db.noLootAlertDisplayID = displayOption.id
                addon:RefreshOptionsControls()
            end
            UIDropDownMenu_AddButton(info, level)
        end
    end)

    local noLootHint = alertsContent:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    noLootHint:SetPoint("TOPLEFT", noLootSoundDropdown, "BOTTOMLEFT", 16, -6)
    noLootHint:SetWidth(620)
    noLootHint:SetJustifyH("LEFT")
    noLootHint:SetText("No-loot alert fires once until another item or money loot is tracked.")

    local milestoneRowPool = {}
    local highValueRowPool = {}
    local function RefreshAlertsControls()
        alertsEnabledCheckbox:SetChecked(addon:IsAlertsEnabled())

        local milestoneHeight = RefreshAlertRuleSection(
            addon.ALERT_RULE_LIST_KEYS.SESSION_MILESTONES,
            milestoneRowsContainer,
            milestoneRowPool,
            RefreshAlertsControls
        )
        local highValueHeight = RefreshAlertRuleSection(
            addon.ALERT_RULE_LIST_KEYS.HIGH_VALUE_DROPS,
            highValueRowsContainer,
            highValueRowPool,
            RefreshAlertsControls
        )

        noLootEnabledCheckbox:SetChecked(addon.db.noLootAlertEnabled == true)
        noLootMinutesInput:SetText(tostring(math.floor((tonumber(addon.db.noLootAlertMinutes) or 0) + 0.5)))
        UIDropDownMenu_SetSelectedValue(noLootSoundDropdown, addon.db.noLootAlertSoundID)
        UIDropDownMenu_SetText(noLootSoundDropdown, BuildSoundDropdownText(addon.db.noLootAlertSoundID))
        UIDropDownMenu_SetSelectedValue(noLootDisplayDropdown, addon.db.noLootAlertDisplayID)
        UIDropDownMenu_SetText(noLootDisplayDropdown, BuildDisplayDropdownText(addon.db.noLootAlertDisplayID))

        local baseHeight = 360
        alertsContent:SetHeight(baseHeight + milestoneHeight + highValueHeight)
    end

    addMilestoneButton:SetScript("OnClick", function()
        if not addon:AddAlertRule(addon.ALERT_RULE_LIST_KEYS.SESSION_MILESTONES) then
            addon:Print("Maximum number of milestone alerts reached.")
        end
        addon:RefreshOptionsControls()
    end)

    addHighValueButton:SetScript("OnClick", function()
        if not addon:AddAlertRule(addon.ALERT_RULE_LIST_KEYS.HIGH_VALUE_DROPS) then
            addon:Print("Maximum number of high-value drop alerts reached.")
        end
        addon:RefreshOptionsControls()
    end)

    RefreshAlertsControls()

    local experimentalContent = tabs.Experimental.content
    local diagnosticsPanelCheckbox = CreateFrame("CheckButton", nil, experimentalContent, "UICheckButtonTemplate")
    diagnosticsPanelCheckbox:SetPoint("TOPLEFT", experimentalContent, "TOPLEFT", -2, -6)
    diagnosticsPanelCheckbox:SetScript("OnClick", function(button)
        addon.db.enableDiagnosticsPanel = button:GetChecked() and true or false
        if type(addon.RefreshDiagnosisButtonVisibility) == "function" then
            addon:RefreshDiagnosisButtonVisibility()
        end
        if not addon.db.enableDiagnosticsPanel and addon.diagnosisFrame and addon.diagnosisFrame:IsShown() then
            addon.diagnosisFrame:Hide()
        end
    end)

    local diagnosticsPanelLabel = experimentalContent:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    diagnosticsPanelLabel:SetPoint("LEFT", diagnosticsPanelCheckbox, "RIGHT", 4, 1)
    diagnosticsPanelLabel:SetText("Enable diagnosis panel button and runtime diagnostics")

    local experimentalHint = experimentalContent:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    experimentalHint:SetPoint("TOPLEFT", diagnosticsPanelCheckbox, "BOTTOMLEFT", 4, -10)
    experimentalHint:SetWidth(620)
    experimentalHint:SetJustifyH("LEFT")
    experimentalHint:SetText("When enabled, a Diagnosis button appears next to History in the tracker window and shows event/timing counters for QA/debug.")
    experimentalContent:SetHeight(220)

    panel:SetScript("OnShow", function()
        addon:RefreshOptionsControls()
        SelectTab(selectedTab)
    end)

    self.optionsControls = {
        valueSourceDropdown = dropdown,
        fallbackValueSourceDropdown = fallbackDropdown,
        minimumTrackedQualityDropdown = minimumQualityDropdown,
        autoStartOnLootCheckbox = autoStartOnLootCheckbox,
        autoStartOnEnterWorldCheckbox = autoStartOnEnterWorldCheckbox,
        resumeAfterReloadCheckbox = resumeAfterReloadCheckbox,
        enableHistoryCheckbox = enableHistoryCheckbox,
        historyRowsPerPageInput = historyRowsPerPageInput,
        historyDetailsFontSizeInput = historyDetailsFontSizeInput,
        rawLootLogCheckbox = rawLootLogCheckbox,
        ignoreMailboxLootCheckbox = ignoreMailboxLootCheckbox,
        mainWindowGoldPerHourCheckbox = mainWindowGoldPerHourCheckbox,
        totalWindowGoldPerHourCheckbox = totalWindowGoldPerHourCheckbox,
        lootSourceTrackingCheckbox = lootSourceTrackingCheckbox,
        diagnosticsPanelCheckbox = diagnosticsPanelCheckbox,
        transparencySlider = transparencySlider,
        transparencyValueText = transparencyValueText,
        alertsRefresh = RefreshAlertsControls,
    }

    self.optionsPanel = panel

    local category = Settings.RegisterCanvasLayoutCategory(panel, "Gold Tracker")
    Settings.RegisterAddOnCategory(category)
    self.optionsCategory = category

    SelectTab("General")
end
