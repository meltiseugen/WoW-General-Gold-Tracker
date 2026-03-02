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
    controls.highlightThresholdInput:SetText(string.format("%.2f", self:GetHighlightThreshold() / self.COPPER_PER_GOLD))
    controls.notificationsCheckbox:SetChecked(self.db.notificationsEnabled)
    controls.autoStartOnLootCheckbox:SetChecked(self.db.autoStartSessionOnFirstLoot)
    controls.autoStartOnEnterWorldCheckbox:SetChecked(self.db.autoStartSessionOnEnterWorld)
    controls.enableHistoryCheckbox:SetChecked(self.db.enableSessionHistory)
    controls.historyRowsPerPageInput:SetText(tostring(self:GetHistoryRowsPerPage()))
    controls.rawLootLogCheckbox:SetChecked(self.db.showRawLootedGoldInLog)
    controls.transparencySlider:SetValue(alpha)
    controls.transparencyValueText:SetText(string.format("Current opacity: %d%%", math.floor((alpha * 100) + 0.5)))
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

    local tabOrder = { "General", "Alerts", "Session" }
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
    tabsUnderline:SetPoint("TOPLEFT", panel, "TOPLEFT", 16, -102)
    tabsUnderline:SetPoint("TOPRIGHT", panel, "TOPRIGHT", -16, -102)
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
            tabButton:SetPoint("LEFT", previousTabButton, "RIGHT", -6, 0)
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

    local sourceLabel = generalContent:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    sourceLabel:SetPoint("TOPLEFT", generalContent, "TOPLEFT", 0, -8)
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
    fallbackSourceLabel:SetPoint("TOPLEFT", dropdown, "BOTTOMLEFT", 16, -14)
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

    local highlightThresholdLabel = generalContent:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    highlightThresholdLabel:SetPoint("TOPLEFT", fallbackDropdown, "BOTTOMLEFT", 16, -24)
    highlightThresholdLabel:SetText("Highlight threshold (gold)")

    local highlightThresholdInput = CreateFrame("EditBox", nil, generalContent, "InputBoxTemplate")
    highlightThresholdInput:SetSize(120, 24)
    highlightThresholdInput:SetPoint("TOPLEFT", highlightThresholdLabel, "BOTTOMLEFT", 0, -8)
    highlightThresholdInput:SetAutoFocus(false)
    highlightThresholdInput:SetScript("OnEnterPressed", function(editBox)
        editBox:ClearFocus()
        addon:SaveHighlightThresholdInput(editBox, "highlightThreshold")
    end)
    highlightThresholdInput:SetScript("OnEditFocusLost", function(editBox)
        addon:SaveHighlightThresholdInput(editBox, "highlightThreshold")
    end)

    local notificationsCheckbox = CreateFrame("CheckButton", nil, generalContent, "UICheckButtonTemplate")
    notificationsCheckbox:SetPoint("TOPLEFT", highlightThresholdInput, "BOTTOMLEFT", -4, -16)
    notificationsCheckbox:SetScript("OnClick", function(button)
        addon.db.notificationsEnabled = button:GetChecked() and true or false
    end)

    local notificationsLabel = generalContent:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    notificationsLabel:SetPoint("LEFT", notificationsCheckbox, "RIGHT", 4, 1)
    notificationsLabel:SetText("Enable highlight notifications")

    local autoStartOnLootCheckbox = CreateFrame("CheckButton", nil, generalContent, "UICheckButtonTemplate")
    autoStartOnLootCheckbox:SetPoint("TOPLEFT", notificationsCheckbox, "BOTTOMLEFT", 0, -8)
    autoStartOnLootCheckbox:SetScript("OnClick", function(button)
        addon.db.autoStartSessionOnFirstLoot = button:GetChecked() and true or false
    end)

    local autoStartOnLootLabel = generalContent:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    autoStartOnLootLabel:SetPoint("LEFT", autoStartOnLootCheckbox, "RIGHT", 4, 1)
    autoStartOnLootLabel:SetText("Auto start session on first loot")

    local autoStartOnEnterWorldCheckbox = CreateFrame("CheckButton", nil, generalContent, "UICheckButtonTemplate")
    autoStartOnEnterWorldCheckbox:SetPoint("TOPLEFT", autoStartOnLootCheckbox, "BOTTOMLEFT", 0, -8)
    autoStartOnEnterWorldCheckbox:SetScript("OnClick", function(button)
        addon.db.autoStartSessionOnEnterWorld = button:GetChecked() and true or false
    end)

    local autoStartOnEnterWorldLabel = generalContent:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    autoStartOnEnterWorldLabel:SetPoint("LEFT", autoStartOnEnterWorldCheckbox, "RIGHT", 4, 1)
    autoStartOnEnterWorldLabel:SetText("Auto start session on world/instance entry and reload")

    local enableHistoryCheckbox = CreateFrame("CheckButton", nil, generalContent, "UICheckButtonTemplate")
    enableHistoryCheckbox:SetPoint("TOPLEFT", autoStartOnEnterWorldCheckbox, "BOTTOMLEFT", 0, -8)
    enableHistoryCheckbox:SetScript("OnClick", function(button)
        addon.db.enableSessionHistory = button:GetChecked() and true or false
        addon:RefreshHistoryButtonVisibility()
        if addon.historyFrame and not addon.db.enableSessionHistory then
            addon.historyFrame:Hide()
        end
    end)

    local enableHistoryLabel = generalContent:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    enableHistoryLabel:SetPoint("LEFT", enableHistoryCheckbox, "RIGHT", 4, 1)
    enableHistoryLabel:SetText("Enable session history")

    local historyRowsPerPageLabel = generalContent:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    historyRowsPerPageLabel:SetPoint("TOPLEFT", enableHistoryCheckbox, "BOTTOMLEFT", 4, -14)
    historyRowsPerPageLabel:SetText("History rows per page (5-30)")

    local historyRowsPerPageInput = CreateFrame("EditBox", nil, generalContent, "InputBoxTemplate")
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

    local rawLootLogCheckbox = CreateFrame("CheckButton", nil, generalContent, "UICheckButtonTemplate")
    rawLootLogCheckbox:SetPoint("TOPLEFT", historyRowsPerPageInput, "BOTTOMLEFT", -4, -10)
    rawLootLogCheckbox:SetScript("OnClick", function(button)
        addon.db.showRawLootedGoldInLog = button:GetChecked() and true or false
    end)

    local rawLootLogLabel = generalContent:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    rawLootLogLabel:SetPoint("LEFT", rawLootLogCheckbox, "RIGHT", 4, 1)
    rawLootLogLabel:SetText("Show raw looted gold entries in loot log")

    local hint = generalContent:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    hint:SetPoint("TOPLEFT", rawLootLogCheckbox, "BOTTOMLEFT", 4, -10)
    hint:SetWidth(560)
    hint:SetJustifyH("LEFT")
    hint:SetText("Use /gt to open the tracker. Auto-start on loot works only while the tracker window is open.")

    local transparencyLabel = generalContent:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    transparencyLabel:SetPoint("TOPLEFT", hint, "BOTTOMLEFT", -4, -18)
    transparencyLabel:SetText("Window transparency")

    local transparencySlider = CreateFrame("Slider", "GoldTrackerTransparencySlider", generalContent, "OptionsSliderTemplate")
    transparencySlider:SetPoint("TOPLEFT", transparencyLabel, "BOTTOMLEFT", 6, -10)
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
    transparencyValueText:SetPoint("TOPLEFT", transparencySlider, "BOTTOMLEFT", 14, -2)
    transparencyValueText:SetText("")

    transparencySlider:SetScript("OnValueChanged", function(_, value)
        local alpha = math.floor((value * 100) + 0.5) / 100
        alpha = math.max(0.20, math.min(1.00, alpha))
        addon.db.windowAlpha = alpha
        addon:ApplyMainWindowAlpha()
        transparencyValueText:SetText(string.format("Current opacity: %d%%", math.floor((alpha * 100) + 0.5)))
    end)

    generalContent:SetHeight(760)

    local alertsContent = tabs.Alerts.content
    local alertsPlaceholder = alertsContent:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    alertsPlaceholder:SetPoint("TOPLEFT", alertsContent, "TOPLEFT", 0, -8)
    alertsPlaceholder:SetText("No options yet.")
    alertsContent:SetHeight(220)

    local sessionContent = tabs.Session.content
    local sessionPlaceholder = sessionContent:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    sessionPlaceholder:SetPoint("TOPLEFT", sessionContent, "TOPLEFT", 0, -8)
    sessionPlaceholder:SetText("No options yet.")
    sessionContent:SetHeight(220)

    panel:SetScript("OnShow", function()
        addon:RefreshOptionsControls()
        SelectTab(selectedTab)
    end)

    self.optionsControls = {
        valueSourceDropdown = dropdown,
        fallbackValueSourceDropdown = fallbackDropdown,
        highlightThresholdInput = highlightThresholdInput,
        notificationsCheckbox = notificationsCheckbox,
        autoStartOnLootCheckbox = autoStartOnLootCheckbox,
        autoStartOnEnterWorldCheckbox = autoStartOnEnterWorldCheckbox,
        enableHistoryCheckbox = enableHistoryCheckbox,
        historyRowsPerPageInput = historyRowsPerPageInput,
        rawLootLogCheckbox = rawLootLogCheckbox,
        transparencySlider = transparencySlider,
        transparencyValueText = transparencyValueText,
    }

    self.optionsPanel = panel

    local category = Settings.RegisterCanvasLayoutCategory(panel, "Gold Tracker")
    Settings.RegisterAddOnCategory(category)
    self.optionsCategory = category

    SelectTab("General")
end
