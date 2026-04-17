local _, NS = ...
local GoldTracker = NS.GoldTracker
local Theme = NS.JanisTheme

local function CreateOptionsPanelFrame(parent, bg, border)
    return Theme:CreatePanel(parent, bg, border)
end

local function CreateOptionsButton(parent, width, height, text, paletteKey)
    return Theme:CreateButton(parent, width, height, text, paletteKey)
end

function GoldTracker:OpenOptions()
    self:CreateOptionsPanel()
    if not self.optionsWindow then
        return
    end

    self.optionsWindow:Show()
    self.optionsWindow:Raise()
    self:RefreshOptionsControls()
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
    if controls.historyRowsPerPageSlider then
        controls.historyRowsPerPageSlider:SetValue(self:GetHistoryRowsPerPage())
    end
    if controls.historyRowsPerPageValueText then
        controls.historyRowsPerPageValueText:SetText(string.format("%d rows", self:GetHistoryRowsPerPage()))
    end
    if controls.historyDetailsFontSizeSlider then
        controls.historyDetailsFontSizeSlider:SetValue(self:GetHistoryDetailsFontSize())
    end
    if controls.historyDetailsFontSizeValueText then
        controls.historyDetailsFontSizeValueText:SetText(string.format("%d px", self:GetHistoryDetailsFontSize()))
    end
    controls.rawLootLogCheckbox:SetChecked(self.db.showRawLootedGoldInLog)
    controls.ignoreMailboxLootCheckbox:SetChecked(self:IsIgnoreMailboxLootWhenMailOpenEnabled())
    controls.mainWindowGoldPerHourCheckbox:SetChecked(self:IsMainWindowGoldPerHourEnabled())
    controls.totalWindowGoldPerHourCheckbox:SetChecked(self:IsTotalWindowGoldPerHourEnabled())
    if controls.activeTimeGoldPerHourCheckbox then
        controls.activeTimeGoldPerHourCheckbox:SetChecked(self:IsActiveTimeForGoldPerHourEnabled())
    end
    if controls.resumeHistorySessionCheckbox then
        controls.resumeHistorySessionCheckbox:SetChecked(self:IsResumeHistorySessionEnabled())
    end
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
    if self.optionsPanel and self.optionsWindow then
        return
    end

    local addon = self
    local settingsPanel = CreateFrame("Frame", "GoldTrackerOptionsPanel", UIParent)

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

    local window = CreateFrame("Frame", "GoldTrackerOptionsWindow", UIParent, "BasicFrameTemplateWithInset")
    window:SetSize(860, 640)
    window:SetPoint("CENTER", UIParent, "CENTER", 0, 40)
    window:SetFrameStrata("DIALOG")
    if window.SetToplevel then
        window:SetToplevel(true)
    end
    window:SetMovable(true)
    window:SetResizable(true)
    if window.SetResizeBounds then
        window:SetResizeBounds(720, 500, 1180, 900)
    else
        if window.SetMinResize then
            window:SetMinResize(720, 500)
        end
        if window.SetMaxResize then
            window:SetMaxResize(1180, 900)
        end
    end
    window:SetClampedToScreen(true)
    window:EnableMouse(true)
    window:RegisterForDrag("LeftButton")
    window:SetScript("OnMouseDown", function(self)
        self:Raise()
    end)
    window:SetScript("OnDragStart", function(self)
        self:Raise()
        self:StartMoving()
    end)
    window:SetScript("OnDragStop", window.StopMovingOrSizing)
    window:Hide()

    local chrome = Theme:ApplyWindowChrome(window, "Options", {
        closeButtonKey = "optionsCloseButton",
    })
    Theme:RegisterSpecialFrame("GoldTrackerOptionsWindow")

    local panel = CreateOptionsPanelFrame(window, { 0.05, 0.06, 0.08, 0.94 }, { 1.0, 0.82, 0.18, 0.10 })
    panel:SetPoint("TOPLEFT", chrome, "TOPLEFT", 12, -54)
    panel:SetPoint("BOTTOMRIGHT", chrome, "BOTTOMRIGHT", -12, 12)
    window.optionsContentPanel = panel

    local title = panel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 16, -16)
    title:SetText("General Gold Tracker")

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

        if type(button.SetSelected) == "function" then
            button:SetSelected(isSelected == true)
            return
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
                    if tab.content then
                        local contentWidth = (tab.container:GetWidth() or 0) - 32
                        if contentWidth <= 1 then
                            contentWidth = (panel:GetWidth() or 0) - 74
                        end
                        tab.content:SetWidth(math.max(1, contentWidth))
                    end
                    if tab.scrollFrame then
                        tab.scrollFrame:SetVerticalScroll(0)
                        if tab.scrollFrame.UpdateScrollChildRect then
                            tab.scrollFrame:UpdateScrollChildRect()
                        end
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
        local tabButton = CreateOptionsButton(panel, 106, 24, tabKey, "neutral")
        tabButton:SetID(index)
        tabButton:SetText(tabKey)
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
    local alertsContent = tabs.Alerts.content
    local experimentalContent = tabs.Experimental.content

    local function AnchorOptionsSection(section, previousSection)
        if not section then
            return
        end

        section:ClearAllPoints()
        if previousSection then
            section:SetPoint("TOPLEFT", previousSection, "BOTTOMLEFT", 0, -12)
            section:SetPoint("TOPRIGHT", previousSection, "BOTTOMRIGHT", 0, -12)
        else
            section:SetPoint("TOPLEFT", section:GetParent(), "TOPLEFT", 4, -6)
            section:SetPoint("TOPRIGHT", section:GetParent(), "TOPRIGHT", -12, -6)
        end
    end

    local function CreateOptionsSection(parent, previousSection, titleText, descriptionText, height)
        local section = CreateOptionsPanelFrame(parent, { 0.04, 0.05, 0.07, 0.82 }, { 1.0, 0.82, 0.18, 0.10 })
        AnchorOptionsSection(section, previousSection)
        section:SetHeight(height)
        section.contentTopOffset = (type(descriptionText) == "string" and descriptionText ~= "") and -54 or -40

        local sectionTitle = section:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        sectionTitle:SetPoint("TOPLEFT", section, "TOPLEFT", 14, -12)
        sectionTitle:SetPoint("TOPRIGHT", section, "TOPRIGHT", -14, -12)
        sectionTitle:SetJustifyH("LEFT")
        sectionTitle:SetText(titleText or "")
        section.titleText = sectionTitle

        if type(descriptionText) == "string" and descriptionText ~= "" then
            local description = section:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
            description:SetPoint("TOPLEFT", sectionTitle, "BOTTOMLEFT", 0, -4)
            description:SetPoint("TOPRIGHT", section, "TOPRIGHT", -14, 0)
            description:SetJustifyH("LEFT")
            description:SetTextColor(0.62, 0.66, 0.74)
            description:SetText(descriptionText)
            section.descriptionText = description
        end

        return section
    end

    local generalPricingSection = CreateOptionsSection(generalContent, nil, "Pricing", "Choose how item values are resolved.", 126)
    local generalDisplaySection = CreateOptionsSection(generalContent, generalPricingSection, "Display", "Tune tracker totals and window presentation.", 178)
    local generalLootSection = CreateOptionsSection(generalContent, generalDisplaySection, "Loot Behavior", "Small filters that affect what the tracker accepts.", 90)

    local trackingQualitySection = CreateOptionsSection(trackingContent, nil, "Item Tracking", "Control item eligibility and valuation in loot views.", 128)
    local trackingSessionSection = CreateOptionsSection(trackingContent, trackingQualitySection, "Session Startup", "Choose when tracking sessions begin or resume automatically.", 166)
    local trackingLootSection = CreateOptionsSection(trackingContent, trackingSessionSection, "Loot Stream", "Controls for raw entries and source detection.", 148)

    local historyCoreSection = CreateOptionsSection(historyContent, nil, "Session History", "Save, reopen, and resume finished sessions.", 144)
    local historyDisplaySection = CreateOptionsSection(historyContent, historyCoreSection, "History Display", "Adjust list density and details text size.", 150)

    local alertsCoreSection = CreateOptionsSection(alertsContent, nil, "Alert System", "Enable sound and display alerts for selected loot events.", 126)
    local milestoneSection = CreateOptionsSection(alertsContent, alertsCoreSection, "Session Total Milestones", "Fire when the active session reaches a configured value.", 78)
    local highValueSection = CreateOptionsSection(alertsContent, milestoneSection, "High-Value Drops", "Fire when a single tracked drop crosses a configured value.", 78)
    local noLootSection = CreateOptionsSection(alertsContent, highValueSection, "No Loot Alert", "Fire once when no loot is tracked for the selected number of minutes.", 210)

    local experimentalDiagnosticsSection = CreateOptionsSection(experimentalContent, nil, "Diagnostics", "Runtime counters and timing data for debugging.", 140)

    local sourceLabel = generalPricingSection:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
    sourceLabel:SetPoint("TOPLEFT", generalPricingSection, "TOPLEFT", 14, generalPricingSection.contentTopOffset)
    sourceLabel:SetText("Item value source")

    local dropdown = CreateFrame("Frame", "GoldTrackerValueSourceDropdown", generalPricingSection, "UIDropDownMenuTemplate")
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

    local fallbackSourceLabel = generalPricingSection:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
    fallbackSourceLabel:SetPoint("TOPLEFT", sourceLabel, "TOPLEFT", 320, 0)
    fallbackSourceLabel:SetText("Fallback value source")

    local fallbackDropdown = CreateFrame("Frame", "GoldTrackerFallbackValueSourceDropdown", generalPricingSection, "UIDropDownMenuTemplate")
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

    local ignoreMailboxLootCheckbox = CreateFrame("CheckButton", nil, generalLootSection, "UICheckButtonTemplate")
    ignoreMailboxLootCheckbox:SetPoint("TOPLEFT", generalLootSection, "TOPLEFT", 10, generalLootSection.contentTopOffset + 4)
    ignoreMailboxLootCheckbox:SetScript("OnClick", function(button)
        addon.db.ignoreMailboxLootWhenMailOpen = button:GetChecked() and true or false
    end)

    local ignoreMailboxLootLabel = generalLootSection:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    ignoreMailboxLootLabel:SetPoint("LEFT", ignoreMailboxLootCheckbox, "RIGHT", 4, 1)
    ignoreMailboxLootLabel:SetText("Ignore mailbox loot while mail window is open")

    local mainWindowGoldPerHourCheckbox = CreateFrame("CheckButton", nil, generalDisplaySection, "UICheckButtonTemplate")
    mainWindowGoldPerHourCheckbox:SetPoint("TOPLEFT", generalDisplaySection, "TOPLEFT", 10, generalDisplaySection.contentTopOffset + 4)
    mainWindowGoldPerHourCheckbox:SetScript("OnClick", function(button)
        addon.db.showMainWindowGoldPerHour = button:GetChecked() and true or false
        addon:UpdateMainWindow()
    end)

    local mainWindowGoldPerHourLabel = generalDisplaySection:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    mainWindowGoldPerHourLabel:SetPoint("LEFT", mainWindowGoldPerHourCheckbox, "RIGHT", 4, 1)
    mainWindowGoldPerHourLabel:SetText("Show gold per hour in main tracker window")

    local totalWindowGoldPerHourCheckbox = CreateFrame("CheckButton", nil, generalDisplaySection, "UICheckButtonTemplate")
    totalWindowGoldPerHourCheckbox:SetPoint("TOPLEFT", mainWindowGoldPerHourCheckbox, "BOTTOMLEFT", 0, -8)
    totalWindowGoldPerHourCheckbox:SetScript("OnClick", function(button)
        addon.db.showTotalWindowGoldPerHour = button:GetChecked() and true or false
        addon:UpdateMainWindow()
    end)

    local totalWindowGoldPerHourLabel = generalDisplaySection:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    totalWindowGoldPerHourLabel:SetPoint("LEFT", totalWindowGoldPerHourCheckbox, "RIGHT", 4, 1)
    totalWindowGoldPerHourLabel:SetText("Show gold per hour in /gtt total window")

    local activeTimeGoldPerHourCheckbox = CreateFrame("CheckButton", nil, generalDisplaySection, "UICheckButtonTemplate")
    activeTimeGoldPerHourCheckbox:SetPoint("TOPLEFT", totalWindowGoldPerHourCheckbox, "BOTTOMLEFT", 0, -8)
    activeTimeGoldPerHourCheckbox:SetScript("OnClick", function(button)
        addon.db.useActiveTimeForGoldPerHour = button:GetChecked() and true or false
        addon:UpdateMainWindow()
    end)

    local activeTimeGoldPerHourLabel = generalDisplaySection:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    activeTimeGoldPerHourLabel:SetPoint("LEFT", activeTimeGoldPerHourCheckbox, "RIGHT", 4, 1)
    activeTimeGoldPerHourLabel:SetText("Use active loot time for gold per hour (ignores long idle gaps)")

    local resumeHistorySessionCheckbox = CreateFrame("CheckButton", nil, historyCoreSection, "UICheckButtonTemplate")
    resumeHistorySessionCheckbox:SetPoint("TOPLEFT", historyCoreSection, "TOPLEFT", 10, historyCoreSection.contentTopOffset + 34)
    resumeHistorySessionCheckbox:SetScript("OnClick", function(button)
        addon.db.allowResumeHistorySession = button:GetChecked() and true or false
        if addon.historyFrame and addon.historyFrame.view == "details" then
            addon:RefreshHistoryDetailsWindow()
        end
    end)

    local resumeHistorySessionLabel = historyCoreSection:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    resumeHistorySessionLabel:SetPoint("LEFT", resumeHistorySessionCheckbox, "RIGHT", 4, 1)
    resumeHistorySessionLabel:SetText("Allow loading saved history sessions into active tracker")

    local minimumQualityLabel = trackingQualitySection:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
    minimumQualityLabel:SetPoint("TOPLEFT", trackingQualitySection, "TOPLEFT", 14, trackingQualitySection.contentTopOffset)
    minimumQualityLabel:SetText("Min item quality for AH and loot log")

    local minimumQualityDropdown = CreateFrame("Frame", "GoldTrackerMinimumQualityDropdown", trackingQualitySection, "UIDropDownMenuTemplate")
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

    local autoStartOnLootCheckbox = CreateFrame("CheckButton", nil, trackingSessionSection, "UICheckButtonTemplate")
    autoStartOnLootCheckbox:SetPoint("TOPLEFT", trackingSessionSection, "TOPLEFT", 10, trackingSessionSection.contentTopOffset + 4)
    autoStartOnLootCheckbox:SetScript("OnClick", function(button)
        addon.db.autoStartSessionOnFirstLoot = button:GetChecked() and true or false
    end)

    local autoStartOnLootLabel = trackingSessionSection:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    autoStartOnLootLabel:SetPoint("LEFT", autoStartOnLootCheckbox, "RIGHT", 4, 1)
    autoStartOnLootLabel:SetText("Auto start session on first loot")

    local autoStartOnEnterWorldCheckbox = CreateFrame("CheckButton", nil, trackingSessionSection, "UICheckButtonTemplate")
    autoStartOnEnterWorldCheckbox:SetPoint("TOPLEFT", autoStartOnLootCheckbox, "BOTTOMLEFT", 0, -8)
    autoStartOnEnterWorldCheckbox:SetScript("OnClick", function(button)
        addon.db.autoStartSessionOnEnterWorld = button:GetChecked() and true or false
    end)

    local autoStartOnEnterWorldLabel = trackingSessionSection:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    autoStartOnEnterWorldLabel:SetPoint("LEFT", autoStartOnEnterWorldCheckbox, "RIGHT", 4, 1)
    autoStartOnEnterWorldLabel:SetText("Auto start session on world/instance entry and reload")

    local resumeAfterReloadCheckbox = CreateFrame("CheckButton", nil, trackingSessionSection, "UICheckButtonTemplate")
    resumeAfterReloadCheckbox:SetPoint("TOPLEFT", autoStartOnEnterWorldCheckbox, "BOTTOMLEFT", 0, -8)
    resumeAfterReloadCheckbox:SetScript("OnClick", function(button)
        addon.db.resumeSessionAfterReload = button:GetChecked() and true or false
        if not addon.db.resumeSessionAfterReload then
            addon:ClearPendingReloadSession()
        end
    end)

    local resumeAfterReloadLabel = trackingSessionSection:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    resumeAfterReloadLabel:SetPoint("LEFT", resumeAfterReloadCheckbox, "RIGHT", 4, 1)
    resumeAfterReloadLabel:SetText("Resume active session after /reload")

    local enableHistoryCheckbox = CreateFrame("CheckButton", nil, historyCoreSection, "UICheckButtonTemplate")
    enableHistoryCheckbox:SetPoint("TOPLEFT", historyCoreSection, "TOPLEFT", 10, historyCoreSection.contentTopOffset + 4)
    enableHistoryCheckbox:SetScript("OnClick", function(button)
        addon.db.enableSessionHistory = button:GetChecked() and true or false
        addon:RefreshHistoryButtonVisibility()
        if addon.historyFrame and not addon.db.enableSessionHistory then
            addon.historyFrame:Hide()
        end
    end)

    local enableHistoryLabel = historyCoreSection:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    enableHistoryLabel:SetPoint("LEFT", enableHistoryCheckbox, "RIGHT", 4, 1)
    enableHistoryLabel:SetText("Enable session history")

    resumeHistorySessionCheckbox:ClearAllPoints()
    resumeHistorySessionCheckbox:SetPoint("TOPLEFT", enableHistoryCheckbox, "BOTTOMLEFT", 0, -8)

    local historyRowsPerPageLabel = historyDisplaySection:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
    historyRowsPerPageLabel:SetPoint("TOPLEFT", historyDisplaySection, "TOPLEFT", 14, historyDisplaySection.contentTopOffset)
    historyRowsPerPageLabel:SetText("History rows per page (5-30)")

    local historyRowsPerPageSlider = CreateFrame("Slider", "GoldTrackerHistoryRowsPerPageSlider", historyDisplaySection, "OptionsSliderTemplate")
    historyRowsPerPageSlider:SetPoint("TOPLEFT", historyRowsPerPageLabel, "BOTTOMLEFT", 6, -10)
    historyRowsPerPageSlider:SetWidth(220)
    historyRowsPerPageSlider:SetMinMaxValues(5, 30)
    historyRowsPerPageSlider:SetValueStep(1)
    if historyRowsPerPageSlider.SetObeyStepOnDrag then
        historyRowsPerPageSlider:SetObeyStepOnDrag(true)
    end

    local rowsSliderLow = _G[historyRowsPerPageSlider:GetName() .. "Low"]
    local rowsSliderHigh = _G[historyRowsPerPageSlider:GetName() .. "High"]
    local rowsSliderText = _G[historyRowsPerPageSlider:GetName() .. "Text"]
    if rowsSliderLow then
        rowsSliderLow:SetText("5")
    end
    if rowsSliderHigh then
        rowsSliderHigh:SetText("30")
    end
    if rowsSliderText then
        rowsSliderText:SetText("")
    end

    local historyRowsPerPageValueText = historyDisplaySection:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    historyRowsPerPageValueText:SetPoint("TOP", historyRowsPerPageSlider, "BOTTOM", 0, -18)
    historyRowsPerPageValueText:SetJustifyH("CENTER")
    historyRowsPerPageValueText:SetText("10 rows")

    historyRowsPerPageSlider:SetScript("OnValueChanged", function(_, value)
        addon:SetHistoryRowsPerPageOption(value)
    end)

    local historyDetailsFontSizeLabel = historyDisplaySection:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
    historyDetailsFontSizeLabel:SetPoint("TOPLEFT", historyRowsPerPageLabel, "TOPLEFT", 300, 0)
    historyDetailsFontSizeLabel:SetText("History details font size (8-24)")

    local historyDetailsFontSizeSlider = CreateFrame("Slider", "GoldTrackerHistoryDetailsFontSizeSlider", historyDisplaySection, "OptionsSliderTemplate")
    historyDetailsFontSizeSlider:SetPoint("TOPLEFT", historyDetailsFontSizeLabel, "BOTTOMLEFT", 6, -10)
    historyDetailsFontSizeSlider:SetWidth(220)
    historyDetailsFontSizeSlider:SetMinMaxValues(8, 24)
    historyDetailsFontSizeSlider:SetValueStep(1)
    if historyDetailsFontSizeSlider.SetObeyStepOnDrag then
        historyDetailsFontSizeSlider:SetObeyStepOnDrag(true)
    end

    local detailsSliderLow = _G[historyDetailsFontSizeSlider:GetName() .. "Low"]
    local detailsSliderHigh = _G[historyDetailsFontSizeSlider:GetName() .. "High"]
    local detailsSliderText = _G[historyDetailsFontSizeSlider:GetName() .. "Text"]
    if detailsSliderLow then
        detailsSliderLow:SetText("8")
    end
    if detailsSliderHigh then
        detailsSliderHigh:SetText("24")
    end
    if detailsSliderText then
        detailsSliderText:SetText("")
    end

    local historyDetailsFontSizeValueText = historyDisplaySection:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    historyDetailsFontSizeValueText:SetPoint("TOP", historyDetailsFontSizeSlider, "BOTTOM", 0, -18)
    historyDetailsFontSizeValueText:SetJustifyH("CENTER")
    historyDetailsFontSizeValueText:SetText("14 px")

    historyDetailsFontSizeSlider:SetScript("OnValueChanged", function(_, value)
        addon:SetHistoryDetailsFontSizeOption(value)
    end)

    local rawLootLogCheckbox = CreateFrame("CheckButton", nil, trackingLootSection, "UICheckButtonTemplate")
    rawLootLogCheckbox:SetPoint("TOPLEFT", trackingLootSection, "TOPLEFT", 10, trackingLootSection.contentTopOffset + 4)
    rawLootLogCheckbox:SetScript("OnClick", function(button)
        addon.db.showRawLootedGoldInLog = button:GetChecked() and true or false
    end)

    local rawLootLogLabel = trackingLootSection:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    rawLootLogLabel:SetPoint("LEFT", rawLootLogCheckbox, "RIGHT", 4, 1)
    rawLootLogLabel:SetText("Show raw looted gold entries in loot log")

    local lootSourceTrackingCheckbox = CreateFrame("CheckButton", nil, trackingLootSection, "UICheckButtonTemplate")
    lootSourceTrackingCheckbox:SetPoint("TOPLEFT", rawLootLogCheckbox, "BOTTOMLEFT", 0, -8)
    lootSourceTrackingCheckbox:SetScript("OnClick", function(button)
        addon.db.enableLootSourceTracking = button:GetChecked() and true or false
        if not addon.db.enableLootSourceTracking then
            addon:OnLootClosed()
        end
    end)

    local lootSourceTrackingLabel = trackingLootSection:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    lootSourceTrackingLabel:SetPoint("LEFT", lootSourceTrackingCheckbox, "RIGHT", 4, 1)
    lootSourceTrackingLabel:SetText("Track loot source (From: unit/node/aoe)")

    local hint = trackingLootSection:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    hint:SetPoint("TOPLEFT", lootSourceTrackingCheckbox, "BOTTOMLEFT", 4, -10)
    hint:SetWidth(560)
    hint:SetJustifyH("LEFT")
    hint:SetText("Use /gt to open the tracker. Auto-start on loot works only while the tracker window is open.")

    local transparencyLabel = generalDisplaySection:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
    transparencyLabel:SetPoint("TOPLEFT", generalDisplaySection, "TOPLEFT", 430, generalDisplaySection.contentTopOffset)
    transparencyLabel:SetText("Window background transparency")

    local transparencySlider = CreateFrame("Slider", "GoldTrackerTransparencySlider", generalDisplaySection, "OptionsSliderTemplate")
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

    local transparencyValueText = generalDisplaySection:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
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

    generalContent:SetHeight(436)
    trackingContent:SetHeight(488)
    historyContent:SetHeight(324)

    local alertsEnabledCheckbox = CreateFrame("CheckButton", nil, alertsCoreSection, "UICheckButtonTemplate")
    alertsEnabledCheckbox:SetPoint("TOPLEFT", alertsCoreSection, "TOPLEFT", 10, alertsCoreSection.contentTopOffset + 4)
    alertsEnabledCheckbox:SetScript("OnClick", function(button)
        addon.db.notificationsEnabled = button:GetChecked() and true or false
        addon:RefreshOptionsControls()
    end)

    local alertsEnabledLabel = alertsCoreSection:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    alertsEnabledLabel:SetPoint("LEFT", alertsEnabledCheckbox, "RIGHT", 4, 1)
    alertsEnabledLabel:SetText("Enable alerts")

    local alertsHint = alertsCoreSection:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
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

        local removeButton = CreateOptionsButton(row, 24, 20, "X", "danger")
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

    local addMilestoneButton = CreateOptionsButton(milestoneSection, 120, 22, "Add milestone", "neutral")
    addMilestoneButton:SetSize(120, 22)
    addMilestoneButton:SetPoint("TOPRIGHT", milestoneSection, "TOPRIGHT", -14, -12)
    addMilestoneButton:SetText("Add milestone")

    local milestoneRowsContainer = CreateFrame("Frame", nil, milestoneSection)
    milestoneRowsContainer:SetPoint("TOPLEFT", milestoneSection, "TOPLEFT", 14, milestoneSection.contentTopOffset + 6)
    milestoneRowsContainer:SetPoint("TOPRIGHT", milestoneSection, "TOPRIGHT", -14, milestoneSection.contentTopOffset + 6)
    milestoneRowsContainer:SetHeight(1)

    local addHighValueButton = CreateOptionsButton(highValueSection, 120, 22, "Add drop rule", "neutral")
    addHighValueButton:SetSize(120, 22)
    addHighValueButton:SetPoint("TOPRIGHT", highValueSection, "TOPRIGHT", -14, -12)
    addHighValueButton:SetText("Add drop rule")

    local highValueRowsContainer = CreateFrame("Frame", nil, highValueSection)
    highValueRowsContainer:SetPoint("TOPLEFT", highValueSection, "TOPLEFT", 14, highValueSection.contentTopOffset + 6)
    highValueRowsContainer:SetPoint("TOPRIGHT", highValueSection, "TOPRIGHT", -14, highValueSection.contentTopOffset + 6)
    highValueRowsContainer:SetHeight(1)

    local noLootEnabledCheckbox = CreateFrame("CheckButton", nil, noLootSection, "UICheckButtonTemplate")
    noLootEnabledCheckbox:SetPoint("TOPLEFT", noLootSection, "TOPLEFT", 10, noLootSection.contentTopOffset + 4)
    noLootEnabledCheckbox:SetScript("OnClick", function(button)
        addon.db.noLootAlertEnabled = button:GetChecked() and true or false
    end)

    local noLootEnabledLabel = noLootSection:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    noLootEnabledLabel:SetPoint("LEFT", noLootEnabledCheckbox, "RIGHT", 4, 1)
    noLootEnabledLabel:SetText("Alert when no loot is received for")

    local noLootMinutesInput = CreateFrame("EditBox", nil, noLootSection, "InputBoxTemplate")
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

    local noLootMinutesLabel = noLootSection:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    noLootMinutesLabel:SetPoint("LEFT", noLootMinutesInput, "RIGHT", 6, 0)
    noLootMinutesLabel:SetText("minutes")

    local noLootSoundLabel = noLootSection:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
    noLootSoundLabel:SetPoint("TOPLEFT", noLootEnabledCheckbox, "BOTTOMLEFT", 4, -12)
    noLootSoundLabel:SetText("Sound")

    local noLootSoundDropdown = CreateFrame("Frame", nil, noLootSection, "UIDropDownMenuTemplate")
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

    local noLootDisplayLabel = noLootSection:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
    noLootDisplayLabel:SetPoint("TOPLEFT", noLootSoundLabel, "TOPLEFT", 220, 0)
    noLootDisplayLabel:SetText("Display")

    local noLootDisplayDropdown = CreateFrame("Frame", nil, noLootSection, "UIDropDownMenuTemplate")
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

    local noLootHint = noLootSection:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
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

        local milestoneSectionHeight = math.max(78, 64 + milestoneHeight)
        local highValueSectionHeight = math.max(78, 64 + highValueHeight)
        milestoneSection:SetHeight(milestoneSectionHeight)
        highValueSection:SetHeight(highValueSectionHeight)
        noLootSection:SetHeight(210)
        alertsContent:SetHeight(126 + 12 + milestoneSectionHeight + 12 + highValueSectionHeight + 12 + 210 + 18)
        if tabs.Alerts and tabs.Alerts.scrollFrame and tabs.Alerts.scrollFrame.UpdateScrollChildRect then
            tabs.Alerts.scrollFrame:UpdateScrollChildRect()
        end
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

    local diagnosticsPanelCheckbox = CreateFrame("CheckButton", nil, experimentalDiagnosticsSection, "UICheckButtonTemplate")
    diagnosticsPanelCheckbox:SetPoint("TOPLEFT", experimentalDiagnosticsSection, "TOPLEFT", 10, experimentalDiagnosticsSection.contentTopOffset + 4)
    diagnosticsPanelCheckbox:SetScript("OnClick", function(button)
        addon.db.enableDiagnosticsPanel = button:GetChecked() and true or false
        if addon.db.enableDiagnosticsPanel and addon.session and addon.session.active and type(addon.EnsureSessionDiagnosisSnapshot) == "function" then
            addon:EnsureSessionDiagnosisSnapshot()
        end
        if type(addon.RefreshDiagnosisButtonVisibility) == "function" then
            addon:RefreshDiagnosisButtonVisibility()
        end
        if not addon.db.enableDiagnosticsPanel
            and addon.diagnosisFrame
            and addon.diagnosisFrame:IsShown()
            and addon.diagnosisFrame.mode ~= "history" then
            addon.diagnosisFrame:Hide()
        end
    end)

    local diagnosticsPanelLabel = experimentalDiagnosticsSection:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    diagnosticsPanelLabel:SetPoint("LEFT", diagnosticsPanelCheckbox, "RIGHT", 4, 1)
    diagnosticsPanelLabel:SetText("Enable diagnosis panel button and runtime diagnostics")

    local experimentalHint = experimentalDiagnosticsSection:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    experimentalHint:SetPoint("TOPLEFT", diagnosticsPanelCheckbox, "BOTTOMLEFT", 4, -10)
    experimentalHint:SetWidth(620)
    experimentalHint:SetJustifyH("LEFT")
    experimentalHint:SetText("When enabled, a Diagnosis button appears next to History in the tracker window and shows event/timing counters for QA/debug.")
    experimentalContent:SetHeight(166)

    local resizeButton = CreateFrame("Button", nil, window)
    resizeButton:SetSize(16, 16)
    resizeButton:SetPoint("BOTTOMRIGHT", window, "BOTTOMRIGHT", -8, 8)
    resizeButton:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")
    resizeButton:SetHighlightTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Highlight")
    resizeButton:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Down")
    resizeButton:SetAlpha(0.7)
    resizeButton:SetScript("OnMouseDown", function(_, button)
        if button == "LeftButton" then
            window:StartSizing("BOTTOMRIGHT")
        end
    end)
    resizeButton:SetScript("OnMouseUp", function()
        window:StopMovingOrSizing()
    end)
    resizeButton:SetScript("OnHide", function()
        window:StopMovingOrSizing()
    end)
    window.resizeButton = resizeButton

    window:SetScript("OnShow", function()
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
        historyRowsPerPageSlider = historyRowsPerPageSlider,
        historyRowsPerPageValueText = historyRowsPerPageValueText,
        historyDetailsFontSizeSlider = historyDetailsFontSizeSlider,
        historyDetailsFontSizeValueText = historyDetailsFontSizeValueText,
        rawLootLogCheckbox = rawLootLogCheckbox,
        ignoreMailboxLootCheckbox = ignoreMailboxLootCheckbox,
        mainWindowGoldPerHourCheckbox = mainWindowGoldPerHourCheckbox,
        totalWindowGoldPerHourCheckbox = totalWindowGoldPerHourCheckbox,
        activeTimeGoldPerHourCheckbox = activeTimeGoldPerHourCheckbox,
        resumeHistorySessionCheckbox = resumeHistorySessionCheckbox,
        lootSourceTrackingCheckbox = lootSourceTrackingCheckbox,
        diagnosticsPanelCheckbox = diagnosticsPanelCheckbox,
        transparencySlider = transparencySlider,
        transparencyValueText = transparencyValueText,
        alertsRefresh = RefreshAlertsControls,
    }

    self.optionsPanel = settingsPanel
    self.optionsWindow = window
    self.optionsContentPanel = panel

    if Settings and Settings.RegisterCanvasLayoutCategory and Settings.RegisterAddOnCategory then
        local category = Settings.RegisterCanvasLayoutCategory(settingsPanel, "General Gold Tracker")
        Settings.RegisterAddOnCategory(category)
        self.optionsCategory = category
    end

    SelectTab("General")
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
