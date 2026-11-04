local _, NS = ...
local GoldTracker = NS.GoldTracker
local Theme = NS.JanisTheme
local function CreateFrame(...)
    return (NS.CreateThemedFrame or _G.CreateFrame)(...)
end

local function Text(parent, value, font, muted)
    local text = parent:CreateFontString(nil, "OVERLAY", font or "GameFontHighlight")
    text:SetJustifyH("LEFT")
    text:SetWordWrap(true)
    text:SetText(value or "")
    if muted then text:SetTextColor(0.62, 0.66, 0.74) end
    return text
end

local function Copy(value)
    if type(value) ~= "table" then return value end
    local result = {}
    for k, v in pairs(value) do result[k] = Copy(v) end
    return result
end

local function Choices(spec)
    return type(spec.choices) == "function" and spec.choices() or spec.choices or {}
end

local function IsAvailable(spec)
    return not spec.available or spec.available()
end

local function IsEnabled(addon, spec)
    if spec.key == "marketHistoryMaxItems" then return addon.db.marketHistoryMaxItems ~= 0 end
    return not spec.enabled or spec.enabled()
end

local function Read(addon, spec)
    if spec.get then return spec.get() end
    return addon.db[spec.key]
end

local function Write(addon, spec, value)
    if spec.set then spec.set(value) else addon.db[spec.key] = value end
end

local function Enable(widget, enabled, dropdown)
    if dropdown then
        if enabled then UIDropDownMenu_EnableDropDown(widget) else UIDropDownMenu_DisableDropDown(widget) end
    else
        widget:SetEnabled(enabled)
    end
end

local tooltipOwner
local function HideOptionsTooltip()
    if tooltipOwner and GameTooltip and GameTooltip:IsOwned(tooltipOwner) then GameTooltip:Hide() end
    tooltipOwner = nil
end

-- Preserve native hover styling and keep help usable on disabled preferences.
local function BindHelp(target, title, description, example, context)
    target.optionsHelp = { title = title, description = description, example = example }
    target:HookScript("OnEnter", function(widget)
        if not GameTooltip then return end
        HideOptionsTooltip()
        tooltipOwner = widget
        GameTooltip:SetOwner(widget, "ANCHOR_RIGHT")
        GameTooltip:SetText(title, 1, 0.82, 0.18, 1, true)
        local body = type(description) == "function" and description() or description
        if body and body ~= "" then GameTooltip:AddLine(body, 0.92, 0.94, 1, true) end
        if example and example ~= "" then
            GameTooltip:AddLine(" ")
            GameTooltip:AddLine("Example: " .. example, 0.68, 0.86, 1, true)
        end
        for _, line in ipairs(context and context() or {}) do
            GameTooltip:AddLine(line, 0.8, 0.82, 0.86, true)
        end
        GameTooltip:Show()
    end)
    local function hide(widget)
        if tooltipOwner == widget then HideOptionsTooltip() end
    end
    target:HookScript("OnLeave", hide)
    target:HookScript("OnHide", hide)
end

local function FormatValue(spec, value)
    if type(value) == "boolean" then return value and "On" or "Off" end
    if type(value) == "table" then return string.format("%d entries", #value) end
    if spec.key == "marketHistoryUnlimitedItems" then return value == 0 and "On" or "Off" end
    if spec.key == "marketHistoryMaxItems" and value == 0 then return "Unlimited" end
    for _, choice in ipairs(Choices(spec)) do if choice.id == value then return choice.label end end
    if type(value) == "number" and spec.multiplier then value = math.floor(value * spec.multiplier + 0.5) end
    return tostring(value) .. (spec.unit == "%" and "%" or spec.unit and " " .. spec.unit or "")
end

-- Reset through the same setters used by controls so visible windows and map
-- projections stay in sync. The explicit settings definitions are the allowlist.
function GoldTracker:ResetOptionsPage(pageID)
    local pages = self.optionsPages or self:GetOptionsPageDefinitions()
    for _, page in ipairs(pages) do
        if page.id == pageID then
            self.optionsResettingPage = true
            local ok, err = pcall(function()
                local reset = {}
                for _, section in ipairs(page.sections) do
                    for _, spec in ipairs(section.items) do
                        local key = spec.resetKey or spec.key
                        if spec.kind ~= "action" and not reset[key] and IsAvailable(spec) and self.DEFAULTS[key] ~= nil then
                            reset[key] = true
                            local value = Copy(self.DEFAULTS[key])
                            if spec.reset then
                                spec.reset(value)
                            elseif spec.resetKey then
                                self.db[key] = value
                            else
                                Write(self, spec, value)
                            end
                        end
                    end
                end
            end)
            self.optionsResettingPage = nil
            if not ok then error(err) end
            self:RefreshOptionsControls()
            return true
        end
    end
    return false
end

function GoldTracker:BuildOptionsWindow()
    if self.optionsWindow then return end
    local addon = self
    local window = CreateFrame("Frame", "GoldTrackerOptionsWindow", UIParent)
    window:SetSize(1000, 720)
    window:SetPoint("CENTER", UIParent, "CENTER", 0, 20)
    window:SetFrameStrata("DIALOG")
    window:SetToplevel(true)
    window:SetMovable(true)
    window:SetResizable(true)
    window:SetResizeBounds(860, 540, 1400, 1000)
    window:SetClampedToScreen(true)
    window:EnableMouse(true)
    window:Hide()
    local chrome = Theme:ApplyWindowChrome(window, "Options", { closeButtonKey = "optionsCloseButton" })
    Theme:RegisterSpecialFrame("GoldTrackerOptionsWindow")
    -- Only the header drags the window; setting controls retain mouse ownership.
    local dragHandle = CreateFrame("Frame", nil, window)
    dragHandle:SetPoint("TOPLEFT", chrome, "TOPLEFT", 8, -4)
    dragHandle:SetPoint("TOPRIGHT", chrome, "TOPRIGHT", -44, -4)
    dragHandle:SetHeight(36)
    dragHandle:EnableMouse(true)
    dragHandle:RegisterForDrag("LeftButton")
    dragHandle:SetScript("OnDragStart", function() window:Raise(); window:StartMoving() end)
    dragHandle:SetScript("OnDragStop", function() window:StopMovingOrSizing() end)
    window:SetScript("OnMouseDown", function() window:Raise() end)

    local sidebar = Theme:CreatePanel(window, { 0.05, 0.06, 0.08, 0.94 }, { 1, 0.82, 0.18, 0.10 })
    sidebar:SetPoint("TOPLEFT", chrome, "TOPLEFT", 12, -54)
    sidebar:SetPoint("BOTTOMLEFT", chrome, "BOTTOMLEFT", 12, 52)
    sidebar:SetWidth(190)
    local searchLabel = Text(sidebar, "Find a setting", "GameFontNormalSmall")
    searchLabel:SetPoint("TOPLEFT", 12, -12)
    local search = CreateFrame("EditBox", nil, sidebar, "InputBoxTemplate")
    search:SetPoint("TOPLEFT", sidebar, "TOPLEFT", 16, -36)
    search:SetPoint("TOPRIGHT", sidebar, "TOPRIGHT", -32, -36)
    search:SetHeight(24)
    search:SetAutoFocus(false)
    search:SetMaxLetters(100)
    local clearSearch = Theme:CreateButton(sidebar, 20, 24, "X", "neutral")
    clearSearch:SetPoint("LEFT", search, "RIGHT", 4, 0)
    clearSearch:SetScript("OnClick", function() search:SetText(""); search:ClearFocus() end)
    search:SetScript("OnEscapePressed", function() search:SetText(""); search:ClearFocus() end)
    BindHelp(search, "Find a setting", "Search setting names, descriptions, detailed help, and examples across every Options page. All words must match the same setting. Search does not change saved preferences.", "Search 'hourly' for market observation guidance, or 'mailbox' for mail filtering.")
    BindHelp(clearSearch, "Clear search", "Clear the search text and show every available setting again. You can also press Escape while typing in the search field.")

    local body = Theme:CreatePanel(window, { 0.04, 0.05, 0.07, 0.82 }, { 1, 0.82, 0.18, 0.10 })
    body:SetPoint("TOPLEFT", sidebar, "TOPRIGHT", 10, 0)
    body:SetPoint("BOTTOMRIGHT", chrome, "BOTTOMRIGHT", -12, 52)
    local heading = Text(body, "", "GameFontNormalLarge")
    heading:SetPoint("TOPLEFT", 18, -16)
    heading:SetPoint("TOPRIGHT", -18, -16)
    local description = Text(body, "", "GameFontHighlightSmall", true)
    description:SetPoint("TOPLEFT", heading, "BOTTOMLEFT", 0, -8)
    description:SetPoint("TOPRIGHT", heading, "BOTTOMRIGHT", 0, -8)
    local noResults = Text(body, "No matching settings. Try a different search.", "GameFontHighlight")
    noResults:SetPoint("TOPLEFT", 18, -110)
    noResults:SetPoint("TOPRIGHT", -18, -110)
    noResults:Hide()
    local saveHint = "Changes save automatically across characters. Hover ? for details and examples."
    local footer = Text(window, saveHint, "GameFontHighlightSmall", true)
    footer:SetPoint("BOTTOMLEFT", chrome, "BOTTOMLEFT", 18, 23)
    footer:SetPoint("BOTTOMRIGHT", chrome, "BOTTOMRIGHT", -190, 23)
    local resetButton = Theme:CreateButton(window, 144, 24, "Reset this page", "neutral")
    resetButton:SetPoint("BOTTOMRIGHT", chrome, "BOTTOMRIGHT", -36, 17)
    BindHelp(resetButton, "Reset this page", "Restore all preferences on the selected page, including settings hidden by search. A second click confirms the reset. Saved sessions, farms, and recorded observations are not cleared. Later market-history maintenance still applies the restored storage limits.", "Reset Maps restores the pin icon and pin size; it does not change your saved farming locations.")

    local pages = addon:GetOptionsPageDefinitions()
    addon.optionsPages = pages
    addon.optionsControls = {}
    local selected, query, refreshing, layingOut = "appearance", "", false, false
    local resetArmed, dragState
    local Reflow, SelectPage, Refresh
    local function SavedMessage(message)
        footer:SetText(message or saveHint)
    end
    local function FinishEditing()
        for _, page in ipairs(pages) do
            for _, section in ipairs(page.sections) do
                for _, row in ipairs(section.rows or {}) do
                    if row.spec.kind == "number" then row.control:ClearFocus() end
                    if row.spec.kind == "rules" then
                        for _, entry in ipairs(row.entries) do entry.threshold:ClearFocus() end
                    end
                end
            end
        end
    end
    local function Commit(spec, value)
        Write(addon, spec, value)
        resetArmed = nil
        resetButton:SetText("Reset this page")
        SavedMessage()
        Refresh()
    end

    local function Dropdown(parent, spec, get, set, width)
        local dropdown = CreateFrame("Frame", nil, parent, "UIDropDownMenuTemplate")
        UIDropDownMenu_SetWidth(dropdown, width or 210)
        UIDropDownMenu_Initialize(dropdown, function(_, level)
            for _, choice in ipairs(Choices(spec)) do
                local option = choice
                local info = UIDropDownMenu_CreateInfo()
                info.text, info.value, info.icon = option.label, option.id, option.texture
                info.tooltipTitle = option.label
                info.tooltipText = option.help or (NS.OptionsChoiceHelp or {})[option.id] or spec.details or spec.help
                info.tooltipOnButton = true
                info.checked = get() == option.id
                info.func = function() set(option.id) end
                UIDropDownMenu_AddButton(info, level)
            end
        end)
        dropdown.refresh = function(enabled)
            local value = get()
            local label = tostring(value or "")
            for _, option in ipairs(Choices(spec)) do
                if option.id == value then label = option.label; break end
            end
            UIDropDownMenu_SetSelectedValue(dropdown, value)
            UIDropDownMenu_SetText(dropdown, label)
            Enable(dropdown, enabled, true)
        end
        return dropdown
    end

    local function Numeric(parent, spec, get, set)
        local input = CreateFrame("EditBox", nil, parent, "InputBoxTemplate")
        input:SetSize(86, 24)
        input:SetAutoFocus(false)
        input:SetNumeric(false)
        input:SetMaxLetters(12)
        local function save()
            if refreshing then return end
            local value = tonumber(input:GetText())
            if not value or value ~= value or value < spec.min or value > spec.max then
                input:SetText(tostring(get()))
                SavedMessage(string.format("Enter a number from %s to %s.", spec.min, spec.max))
                return
            end
            local scale = spec.decimals and 100 or 1
            set(math.floor(value * scale + 0.5) / scale)
        end
        input:SetScript("OnEnterPressed", function() input:ClearFocus() end)
        input:SetScript("OnEditFocusLost", save)
        input:SetScript("OnEscapePressed", function()
            input:SetText(tostring(get())); input:ClearFocus(); SavedMessage()
        end)
        input.refresh = function(enabled)
            if not input:HasFocus() then input:SetText(tostring(get())) end
            input:SetEnabled(enabled)
        end
        return input
    end

    local function OrderedList(row, spec)
        row.entries = {}
        local reset = Theme:CreateButton(row, 100, 22, "Reset order", "neutral")
        row.orderReset = reset
        reset:SetScript("OnClick", function() Commit(spec, Copy(addon.DEFAULTS[spec.key])) end)
        BindHelp(reset, "Reset order", "Restore the default order of this list. Other preferences and recorded data are kept.")
        local function move(from, to)
            local order = Copy(Read(addon, spec))
            if from == to or to < 1 or to > #order then return end
            local id = table.remove(order, from)
            table.insert(order, to, id)
            Commit(spec, order)
        end
        row.refreshControl = function(enabled)
            local order, labels = Read(addon, spec), {}
            for _, choice in ipairs(Choices(spec)) do labels[choice.id] = choice.label end
            for i, id in ipairs(order) do
                local entry = row.entries[i]
                if not entry then
                    entry = CreateFrame("Button", nil, row)
                    row.entries[i] = entry
                    entry:SetHeight(30)
                    entry:EnableMouse(true)
                    entry:RegisterForDrag("LeftButton")
                    entry.background = entry:CreateTexture(nil, "BACKGROUND")
                    entry.background:SetAllPoints(entry)
                    entry.background:SetColorTexture(1, 1, 1, i % 2 == 0 and 0.045 or 0.025)
                    entry.label = Text(entry, "", "GameFontHighlightSmall")
                    entry.label:SetPoint("LEFT", 10, 0)
                    entry.label:SetPoint("RIGHT", -82, 0)
                    entry.up = Theme:CreateButton(entry, 28, 22, "^", "neutral")
                    entry.up:SetPoint("RIGHT", -42, 0)
                    entry.down = Theme:CreateButton(entry, 28, 22, "v", "neutral")
                    entry.down:SetPoint("RIGHT", -8, 0)
                    entry.up:SetScript("OnClick", function() move(entry.index, entry.index - 1) end)
                    entry.down:SetScript("OnClick", function() move(entry.index, entry.index + 1) end)
                    BindHelp(entry, "Reorder " .. spec.label, spec.details or spec.help, spec.example)
                    BindHelp(entry.up, "Move up", "Move this entry one place earlier in the list. The first entry is already at the highest position.")
                    BindHelp(entry.down, "Move down", "Move this entry one place later in the list. The last entry is already at the lowest position.")
                    entry:SetScript("OnDragStart", function()
                        dragState = { row = row, id = entry.id }
                    end)
                    entry:SetScript("OnEnter", function()
                        if not dragState or dragState.row ~= row or not enabled then return end
                        local current = Read(addon, spec)
                        for index, currentID in ipairs(current) do
                            if currentID == dragState.id then move(index, entry.index); break end
                        end
                    end)
                    local function stop() dragState = nil end
                    entry:SetScript("OnDragStop", stop)
                    entry:SetScript("OnMouseUp", stop)
                    entry:SetScript("OnHide", stop)
                end
                entry.id, entry.index = id, i
                entry.label:SetText(string.format("%d.  %s", i, labels[id] or id))
                entry.up:SetEnabled(enabled and i > 1)
                entry.down:SetEnabled(enabled and i < #order)
                entry:Show()
            end
            for i = #order + 1, #row.entries do row.entries[i]:Hide() end
            reset:SetEnabled(enabled)
            row.orderCount = #order
        end
        row.layoutControl = function(top, width)
            reset:ClearAllPoints(); reset:SetPoint("TOPRIGHT", row, "TOPRIGHT", -8, -top)
            top = top + 30
            for i = 1, row.orderCount do
                local entry = row.entries[i]
                entry:ClearAllPoints()
                entry:SetPoint("TOPLEFT", row, "TOPLEFT", 0, -top)
                entry:SetWidth(width)
                top = top + math.max(34, entry.label:GetStringHeight() + 12)
                entry:SetHeight(math.max(30, entry.label:GetStringHeight() + 8))
            end
            return top
        end
    end

    local function AlertRules(row, spec)
        row.entries = {}
        row.addRule = Theme:CreateButton(row, 110, 24, "Add rule", "neutral")
        row.addRule:SetScript("OnClick", function() addon:AddAlertRule(spec.key); Refresh() end)
        BindHelp(row.addRule, "Add rule", "Add a new enabled rule to this list, then choose its threshold, sound, and display. Each list supports up to 20 rules.", spec.example, function()
            if not IsEnabled(addon, spec) then return { spec.disabledReason } end
            return #addon:GetAlertRules(spec.key) >= 20 and { "This list already has 20 rules." } or {}
        end)
        row.empty = Text(row, "No rules. Add a rule to create an alert.", "GameFontHighlightSmall", true)
        row.refreshControl = function(enabled)
            local rules = addon:GetAlertRules(spec.key)
            for i, rule in ipairs(rules) do
                local entry = row.entries[i]
                if not entry then
                    entry = CreateFrame("Frame", nil, row)
                    row.entries[i] = entry
                    entry.index = i
                    entry.background = entry:CreateTexture(nil, "BACKGROUND")
                    entry.background:SetAllPoints(entry)
                    entry.background:SetColorTexture(1, 1, 1, 0.035)
                    entry.enabled = CreateFrame("CheckButton", nil, entry, "UICheckButtonTemplate")
                    entry.enabled:SetScript("OnClick", function(b)
                        addon:SetAlertRuleEnabled(spec.key, entry.index, b:GetChecked() == true); Refresh()
                    end)
                    entry.thresholdLabel = Text(entry, "Threshold (g)", "GameFontNormalSmall")
                    entry.threshold = Numeric(entry, { min = 0.01, max = 1000000000, decimals = true },
                        function() return addon:GetAlertRules(spec.key)[entry.index].threshold / addon.COPPER_PER_GOLD end,
                        function(v) addon:SetAlertRuleThresholdGold(spec.key, entry.index, v); Refresh() end)
                    entry.soundLabel = Text(entry, "Sound", "GameFontNormalSmall")
                    entry.sound = Dropdown(entry, { choices = addon.ALERT_SOUND_OPTIONS },
                        function() return addon:GetAlertRules(spec.key)[entry.index].soundID end,
                        function(v) addon:SetAlertRuleSoundID(spec.key, entry.index, v); Refresh() end, 150)
                    entry.displayLabel = Text(entry, "Display", "GameFontNormalSmall")
                    entry.display = Dropdown(entry, { choices = addon.ALERT_DISPLAY_OPTIONS },
                        function() return addon:GetAlertRules(spec.key)[entry.index].displayID end,
                        function(v) addon:SetAlertRuleDisplayID(spec.key, entry.index, v); Refresh() end, 170)
                    entry.test = Theme:CreateButton(entry, 54, 22, "Test", "neutral")
                    entry.test:SetScript("OnClick", function()
                        local current = addon:GetAlertRules(spec.key)[entry.index]
                        addon:DispatchConfiguredAlert(string.format("Test: %s at %.2f gold", spec.label, current.threshold / addon.COPPER_PER_GOLD), current.displayID, current.soundID)
                    end)
                    entry.remove = Theme:CreateButton(entry, 70, 22, "Remove", "danger")
                    entry.remove:SetScript("OnClick", function() addon:RemoveAlertRule(spec.key, entry.index); Refresh() end)
                    local function ruleContext()
                        return not IsEnabled(addon, spec) and { spec.disabledReason } or {}
                    end
                    BindHelp(entry.enabled, "Enable this rule", "Enable or mute this one rule while keeping its threshold, sound, and display settings.", nil, ruleContext)
                    BindHelp(entry.threshold, "Threshold in gold", "Gold value required to trigger this rule. Enter a positive amount with up to two decimal places. For drop rules, the full loot entry quantity counts.", "12.34 means 12 gold and 34 silver.", ruleContext)
                    BindHelp(entry.sound, "Rule sound", "Choose the sound for this rule. None silences the sound without removing the visual display.", "Use Test to hear the selected sound.", ruleContext)
                    BindHelp(entry.display, "Rule display", "Choose where the warning appears. No visual uses sound only; combined modes use multiple destinations. The Logging page's master switch and Alerts in chat control the chat copy.", nil, ruleContext)
                    if entry.sound.Button then BindHelp(entry.sound.Button, "Rule sound", "Choose a sound for this rule, or None for a silent alert.", nil, ruleContext) end
                    if entry.display.Button then BindHelp(entry.display.Button, "Rule display", "Choose the alert destination. The Logging page's master switch and Alerts in chat control the chat copy.", nil, ruleContext) end
                    BindHelp(entry.test, "Test this rule", "Preview this rule's sound and display immediately. This does not alter session totals or mark a milestone as reached.", nil, ruleContext)
                    BindHelp(entry.remove, "Remove this rule", "Delete this rule from the list. Other rules and saved sessions are kept. Use Add rule if you want to create a replacement.", nil, ruleContext)
                end
                entry.index = i
                entry.enabled:SetChecked(rule.enabled == true)
                entry.enabled:SetEnabled(enabled)
                entry.threshold.refresh(enabled)
                entry.sound.refresh(enabled)
                entry.display.refresh(enabled)
                entry.test:SetEnabled(enabled)
                entry.remove:SetEnabled(enabled)
                entry:Show()
            end
            for i = #rules + 1, #row.entries do row.entries[i]:Hide() end
            row.ruleCount = #rules
            row.empty:SetShown(#rules == 0)
            row.addRule:SetEnabled(enabled and #rules < 20)
        end
        row.layoutControl = function(top, width)
            row.addRule:ClearAllPoints(); row.addRule:SetPoint("TOPRIGHT", row, "TOPRIGHT", -8, -top)
            row.empty:ClearAllPoints(); row.empty:SetPoint("TOPLEFT", 0, -top - 4)
            row.empty:SetWidth(math.max(100, width - 130))
            top = top + 34
            for i = 1, row.ruleCount do
                local entry = row.entries[i]
                local wide = width >= 720
                entry:ClearAllPoints(); entry:SetPoint("TOPLEFT", 0, -top); entry:SetWidth(width)
                entry:SetHeight(wide and 74 or 124)
                entry.enabled:ClearAllPoints(); entry.enabled:SetPoint("TOPLEFT", 2, -24)
                entry.thresholdLabel:ClearAllPoints(); entry.thresholdLabel:SetPoint("TOPLEFT", 40, -10)
                entry.threshold:ClearAllPoints(); entry.threshold:SetPoint("TOPLEFT", 40, -30)
                entry.soundLabel:ClearAllPoints(); entry.soundLabel:SetPoint("TOPLEFT", 148, -10)
                entry.sound:ClearAllPoints(); entry.sound:SetPoint("TOPLEFT", 132, -26)
                entry.displayLabel:ClearAllPoints(); entry.displayLabel:SetPoint("TOPLEFT", wide and 332 or 40, wide and -10 or -70)
                entry.display:ClearAllPoints(); entry.display:SetPoint("TOPLEFT", wide and 316 or 24, wide and -26 or -86)
                entry.test:ClearAllPoints(); entry.test:SetPoint("TOPRIGHT", -88, wide and -30 or -84)
                entry.remove:ClearAllPoints(); entry.remove:SetPoint("TOPRIGHT", -10, wide and -30 or -84)
                top = top + entry:GetHeight() + 8
            end
            return top
        end
    end

    local function BuildRow(parent, spec)
        local row = CreateFrame("Frame", nil, parent)
        row.spec = spec
        row.label = Text(row, spec.label, "GameFontHighlight")
        row.help = Text(row, spec.help, "GameFontHighlightSmall", true)
        local function get() return Read(addon, spec) end
        local function set(v) Commit(spec, v) end
        if spec.kind == "check" then
            row.control = CreateFrame("CheckButton", nil, row, "UICheckButtonTemplate")
            row.control:SetSize(28, 28)
            row.control:SetScript("OnClick", function(b) set(b:GetChecked() == true) end)
            row.refreshControl = function(enabled)
                row.control:SetChecked(get() == true); row.control:SetEnabled(enabled)
            end
        elseif spec.kind == "select" or spec.kind == "theme" then
            row.control = Dropdown(row, spec, get, set)
            row.refreshControl = row.control.refresh
            if spec.kind == "theme" then
                row.preview = _G.CreateFrame("Frame", nil, row, "BackdropTemplate")
                row.previewTitle = Text(row.preview, "", "GameFontNormal")
                row.previewTitle:SetPoint("TOPLEFT", 14, -12)
                row.previewBody = Text(row.preview, "Tracker window preview", "GameFontHighlightSmall")
                row.previewBody:SetPoint("TOPLEFT", 14, -36)
                row.previewValue = Text(row.preview, "125 gold / hour", "GameFontHighlight")
                row.previewValue:SetPoint("TOPLEFT", 14, -56)
                row.themeStatus = Text(row, "", "GameFontHighlightSmall", true)
                row.reload = Theme:CreateButton(row, 100, 24, "Reload UI", "primary")
                row.reload:SetScript("OnClick", function() ReloadUI() end)
                BindHelp(row.reload, "Reload UI", "Reload the game interface to apply your saved skin selection. This button is available when the saved skin differs from the active one.", "Selecting a skin updates the preview first; Reload UI applies it to all tracker windows.")
                row.refreshControl = function(enabled)
                    row.control.refresh(enabled)
                    local pending = get() ~= Theme.key
                    row.themeStatus:SetText(pending and "Saved. Reload UI to apply this skin." or "This skin is active.")
                    row.reload:SetEnabled(pending)
                    local preview = NS.GetVisualThemePreviewSpec and NS.GetVisualThemePreviewSpec(get())
                    if preview then
                        local c = preview.colors
                        row.preview:SetBackdrop(preview.backdrops and preview.backdrops.panel or preview.backdrop)
                        row.preview:SetBackdropColor(unpack(c.panel or c.chrome))
                        row.preview:SetBackdropBorderColor(unpack(c.chromeBorder or c.accentGold))
                        row.previewTitle:SetText(preview.displayName)
                        row.previewTitle:SetTextColor(unpack(c.titleText))
                        row.previewBody:SetTextColor(unpack(c.text))
                        row.previewValue:SetTextColor(unpack(c.previewSuccess))
                    end
                end
            end
        elseif spec.kind == "number" then
            row.control = Numeric(row, spec, get, set)
            row.unit = Text(row, spec.unit or "", "GameFontHighlightSmall", true)
            row.refreshControl = row.control.refresh
        elseif spec.kind == "slider" then
            row.control = CreateFrame("Slider", nil, row, "OptionsSliderTemplate")
            row.control:SetSize(210, 18)
            row.control:SetMinMaxValues(spec.min, spec.max)
            row.control:SetValueStep(spec.step or 1)
            row.control:SetObeyStepOnDrag(true)
            row.value = Text(row, "", "GameFontHighlightSmall", true)
            row.control:SetScript("OnValueChanged", function(_, value)
                if refreshing then return end
                local step = spec.step or 1
                local rounded = math.floor(value / step + 0.5) * step
                set(math.max(spec.min, math.min(spec.max, rounded)))
            end)
            row.refreshControl = function(enabled)
                row.control:SetValue(get()); row.control:SetEnabled(enabled)
                row.value:SetText(string.format("%d%s%s", math.floor(get() * (spec.multiplier or 1) + 0.5), spec.unit == "%" and "" or " ", spec.unit or ""))
            end
        elseif spec.kind == "order" then
            OrderedList(row, spec)
        elseif spec.kind == "rules" then
            AlertRules(row, spec)
        elseif spec.kind == "action" then
            row.control = Theme:CreateButton(row, 120, 24, spec.text, "neutral")
            row.control:SetScript("OnClick", spec.action)
            row.refreshControl = function(enabled) row.control:SetEnabled(enabled) end
        end
        row.helpButton = Theme:CreateButton(row, 18, 18, "?", "neutral")
        local function helpContext()
            local lines = {}
            local default = addon.DEFAULTS[spec.resetKey or spec.key]
            if default ~= nil then lines[#lines + 1] = "Default: " .. FormatValue(spec, default) end
            if spec.min and spec.max then
                lines[#lines + 1] = "Range: " .. FormatValue(spec, spec.min) .. " to " .. FormatValue(spec, spec.max)
            end
            if spec.kind == "number" then lines[#lines + 1] = "Press Enter or leave the field to save. Escape cancels the edit." end
            if spec.kind == "slider" then lines[#lines + 1] = "Changes save as you move the slider." end
            if not IsEnabled(addon, spec) and spec.disabledReason then
                lines[#lines + 1] = "Unavailable: " .. spec.disabledReason
            end
            return lines
        end
        BindHelp(row.helpButton, spec.label, spec.details or spec.help, spec.example, helpContext)
        if row.control then
            BindHelp(row.control, spec.label, spec.details or spec.help, spec.example, helpContext)
            if row.control.Button then BindHelp(row.control.Button, spec.label, spec.details or spec.help, spec.example, helpContext) end
        end
        addon.optionsControls[spec.key] = row.control or row
        local searchParts = { spec.label, spec.help or "", spec.key, spec.keywords or "", spec.details or "", spec.example or "" }
        for _, choice in ipairs(Choices(spec)) do
            searchParts[#searchParts + 1] = choice.label .. " " .. (choice.help or (NS.OptionsChoiceHelp or {})[choice.id] or "")
        end
        row.searchText = string.lower(table.concat(searchParts, " "))
        return row
    end

    for index, page in ipairs(pages) do
        page.button = Theme:CreateButton(sidebar, 166, 30, page.label, "neutral")
        page.button:SetPoint("TOPLEFT", sidebar, "TOPLEFT", 12, -76 - (index - 1) * 36)
        if Theme.ApplySelectorArt then Theme:ApplySelectorArt(page.button, { centered = false, arrow = false }) end
        page.button:SetScript("OnClick", function() SelectPage(page.id) end)
        BindHelp(page.button, page.label, page.help)
        page.scroll = CreateFrame("ScrollFrame", nil, body, "UIPanelScrollFrameTemplate")
        page.scroll:SetPoint("TOPLEFT", description, "BOTTOMLEFT", 0, -16)
        page.scroll:SetPoint("BOTTOMRIGHT", body, "BOTTOMRIGHT", -32, 12)
        page.scroll:EnableMouseWheel(true)
        page.scroll:SetScript("OnMouseWheel", function(scroll, delta)
            scroll:SetVerticalScroll(math.max(0, math.min(scroll:GetVerticalScrollRange(), scroll:GetVerticalScroll() - delta * 44)))
        end)
        page.content = CreateFrame("Frame", nil, page.scroll)
        page.content:SetSize(1, 1)
        page.scroll:SetScrollChild(page.content)
        page.scroll:Hide()
        for _, section in ipairs(page.sections) do
            section.frame = CreateFrame("Frame", nil, page.content)
            section.heading = Text(section.frame, section.title, "GameFontNormal")
            section.description = Text(section.frame, section.help or "", "GameFontHighlightSmall", true)
            section.rows = {}
            for _, spec in ipairs(section.items) do
                section.rows[#section.rows + 1] = BuildRow(section.frame, spec)
            end
        end
    end

    local function Matches(row, page, section)
        if not IsAvailable(row.spec) then return false end
        if query == "" then return true end
        local haystack = string.lower(page.label .. " " .. section.title) .. " " .. row.searchText
        -- Treat search as plain words, never a Lua pattern.
        for word in query:gmatch("%S+") do
            if not haystack:find(word, 1, true) then return false end
        end
        return true
    end

    Reflow = function()
        if layingOut then return end
        layingOut = true
        -- Keep every page reachable at the minimum window height as well.
        local navStep = math.min(36, (sidebar:GetHeight() - 84) / #pages)
        for index, page in ipairs(pages) do
            page.button:ClearAllPoints()
            page.button:SetPoint("TOPLEFT", sidebar, "TOPLEFT", 12, -76 - (index - 1) * navStep)
            page.button:SetHeight(math.min(30, navStep - 4))
        end
        for _, page in ipairs(pages) do
            if page.id == selected then
                local width = math.max(300, body:GetWidth() - 54)
                page.content:SetWidth(width)
                local pageTop = 0
                for _, section in ipairs(page.sections) do
                    local matching = 0
                    for _, row in ipairs(section.rows) do if Matches(row, page, section) then matching = matching + 1 end end
                    section.frame:SetShown(matching > 0)
                    if matching > 0 then
                        section.frame:ClearAllPoints(); section.frame:SetPoint("TOPLEFT", 0, -pageTop); section.frame:SetWidth(width)
                        section.heading:ClearAllPoints(); section.heading:SetPoint("TOPLEFT", 0, 0); section.heading:SetWidth(width)
                        local top = section.heading:GetStringHeight() + 12
                        section.description:SetShown(section.help ~= nil)
                        if section.help then
                            section.description:ClearAllPoints(); section.description:SetPoint("TOPLEFT", 0, -top); section.description:SetWidth(width)
                            top = top + section.description:GetStringHeight() + 12
                        end
                        for _, row in ipairs(section.rows) do
                            local shown = Matches(row, page, section)
                            row:SetShown(shown)
                            if shown then
                                row:ClearAllPoints(); row:SetPoint("TOPLEFT", 0, -top); row:SetWidth(width)
                                local full = row.layoutControl ~= nil or width < 580
                                local labelWidth = full and width - 12 or width - 280
                                row.label:ClearAllPoints(); row.label:SetPoint("TOPLEFT", 0, -4); row.label:SetWidth(labelWidth - 26)
                                row.helpButton:ClearAllPoints(); row.helpButton:SetPoint("TOPLEFT", row.label, "TOPRIGHT", 6, 1)
                                local labelHeight = row.label:GetStringHeight()
                                row.help:ClearAllPoints(); row.help:SetPoint("TOPLEFT", 0, -labelHeight - 9); row.help:SetWidth(labelWidth)
                                local textHeight = labelHeight + row.help:GetStringHeight() + 18
                                local height = math.max(58, textHeight)
                                if row.layoutControl then
                                    height = row.layoutControl(textHeight + 2, width) + 8
                                elseif row.control then
                                    row.control:ClearAllPoints()
                                    local controlTop = full and textHeight + 4 or 4
                                    local x = full and 0 or width - 238
                                    if row.spec.kind == "check" then
                                        row.control:SetPoint("TOPRIGHT", -10, -2)
                                        -- Checkboxes always stay beside their labels.
                                        row.label:SetWidth(width - 80); row.help:SetWidth(width - 54)
                                        row.help:SetPoint("TOPLEFT", 0, -row.label:GetStringHeight() - 9)
                                        height = math.max(58, row.label:GetStringHeight() + row.help:GetStringHeight() + 18)
                                    elseif row.spec.kind == "select" or row.spec.kind == "theme" then
                                        row.control:SetPoint("TOPLEFT", x - 16, -controlTop)
                                        if full then height = controlTop + 42 end
                                    else
                                        row.control:SetPoint("TOPLEFT", x + 4, -controlTop)
                                        if full then height = controlTop + 38 end
                                    end
                                    if row.unit then
                                        row.unit:ClearAllPoints(); row.unit:SetPoint("LEFT", row.control, "RIGHT", 10, 0)
                                        row.unit:SetWidth(120)
                                    end
                                    if row.value then
                                        row.value:ClearAllPoints(); row.value:SetPoint("TOPLEFT", row.control, "BOTTOMLEFT", 0, -6)
                                        height = math.max(height, controlTop + 44)
                                    end
                                    if row.preview then
                                        row.preview:ClearAllPoints(); row.preview:SetPoint("TOPLEFT", 0, -height - 2)
                                        row.preview:SetWidth(width); row.preview:SetHeight(86)
                                        row.previewTitle:SetWidth(width - 28)
                                        row.previewBody:SetWidth(width - 28)
                                        row.previewValue:SetWidth(width - 28)
                                        row.themeStatus:ClearAllPoints(); row.themeStatus:SetPoint("TOPLEFT", 0, -height - 102)
                                        row.themeStatus:SetWidth(width - 132)
                                        row.reload:ClearAllPoints(); row.reload:SetPoint("TOPRIGHT", -8, -height - 96)
                                        height = height + 106 + math.max(26, row.themeStatus:GetStringHeight())
                                    end
                                end
                                row:SetHeight(height)
                                top = top + height + 8
                            end
                        end
                        section.frame:SetHeight(top)
                        pageTop = pageTop + top + 18
                    end
                end
                page.content:SetHeight(math.max(1, pageTop))
                page.scroll:UpdateScrollChildRect()
                page.scroll:SetVerticalScroll(math.min(page.scroll:GetVerticalScroll(), page.scroll:GetVerticalScrollRange()))
            end
        end
        layingOut = false
    end

    SelectPage = function(id)
        HideOptionsTooltip()
        if id ~= selected then FinishEditing() end
        dragState, resetArmed = nil, nil
        resetButton:SetText("Reset this page")
        SavedMessage()
        selected = id
        window.selectedPage = id
        for _, page in ipairs(pages) do
            local active = page.id == id
            page.scroll:SetShown(active and (page.matches or 0) > 0)
            if page.button.SetSelected then page.button:SetSelected(active) end
            if active then heading:SetText(page.label); description:SetText(page.help) end
        end
        Reflow()
    end

    Refresh = function()
        if refreshing then return end
        refreshing = true
        local first, total, selectedCount
        total = 0
        for _, page in ipairs(pages) do
            local count = 0
            for _, section in ipairs(page.sections) do
                for _, row in ipairs(section.rows) do
                    if IsAvailable(row.spec) then
                        local enabled = IsEnabled(addon, row.spec)
                        if row.refreshControl then row.refreshControl(enabled) end
                        row:SetAlpha(enabled and 1 or 0.5)
                    end
                    if Matches(row, page, section) then count = count + 1 end
                end
            end
            page.matches = count
            page.button:SetEnabled(count > 0)
            page.button:SetAlpha(count > 0 and 1 or 0.4)
            if count > 0 then first = first or page.id end
            if page.id == selected then selectedCount = count end
            total = total + count
        end
        refreshing = false
        noResults:SetShown(total == 0)
        resetButton:SetEnabled(total > 0)
        if total > 0 and (selectedCount or 0) == 0 then
            SelectPage(first)
        else
            for _, page in ipairs(pages) do page.scroll:SetShown(page.id == selected and total > 0) end
            Reflow()
        end
        if query ~= "" then
            SavedMessage(string.format("%d matching settings. Clear search to show all settings.", total))
        end
    end

    search:SetScript("OnTextChanged", function()
        HideOptionsTooltip()
        query = string.lower(search:GetText() or ""):match("^%s*(.-)%s*$")
        dragState, resetArmed = nil, nil
        resetButton:SetText("Reset this page")
        for _, page in ipairs(pages) do page.scroll:SetVerticalScroll(0) end
        Refresh()
        if query == "" then SavedMessage() end
    end)
    resetButton:SetScript("OnClick", function()
        FinishEditing()
        if resetArmed == selected then
            resetArmed = nil
            addon:ResetOptionsPage(selected)
            resetButton:SetText("Reset this page")
            SavedMessage("Page preferences restored. Saved sessions and recorded data were preserved.")
        else
            resetArmed = selected
            resetButton:SetText("Confirm reset")
            SavedMessage("Click Confirm reset to restore every preference on this page, including hidden search results.")
        end
    end)
    body:SetScript("OnSizeChanged", function() Reflow() end)
    window:SetScript("OnHide", function()
        HideOptionsTooltip()
        FinishEditing()
        dragState, resetArmed = nil, nil
        search:ClearFocus()
        window:StopMovingOrSizing()
    end)
    window:SetScript("OnShow", function() Refresh(); SelectPage(selected) end)
    Theme:CreateResizeButton(window, { minWidth = 860, minHeight = 540, maxWidth = 1400, maxHeight = 1000 })
    addon.optionsWindow = window
    addon.optionsContentPanel = body
    addon.optionsRefresh = Refresh
    window.searchInput, window.resetPageButton = search, resetButton
    window.selectPage, window.reflow = SelectPage, Reflow
    Refresh()
    SelectPage(selected)
end
