local ui = require("tests.helpers.options_ui")
local loader = require("tests.helpers.addon_loader")

describe("options sidebar and preferences", function()
    it("provides descriptions, examples, and hover help for every preference", function()
        ui.with_ui(function(addon)
            local count = 0
            for _, page in ipairs(addon.optionsPages) do
                for _, section in ipairs(page.sections) do
                    for _, row in ipairs(section.rows) do
                        assert.is_string(row.spec.help)
                        assert.is_string(row.spec.details)
                        assert.is_string(row.spec.example)
                        assert.is_truthy(#row.spec.details > #row.spec.help)
                        assert.is_table(row.helpButton.optionsHelp)
                        assert.is_function(row.helpButton.scripts.OnEnter)
                        assert.is_function(row.helpButton.scripts.OnLeave)
                        count = count + 1
                    end
                end
            end
            assert.is_true(count > 35)
        end)
    end)

    it("shows defaults, ranges, and live disabled reasons without changing values", function()
        ui.with_ui(function(addon)
            local cap = ui.row(addon, "marketHistoryMaxItems")
            local oldLimit = addon.db.marketHistoryMaxItems
            cap.helpButton.scripts.OnEnter(cap.helpButton)
            local text = table.concat(GameTooltip.lines, "\n")
            assert.matches("Default: Unlimited", text)
            assert.matches("Range: 1 items to 50000 items", text)
            assert.matches("Turn off Unlimited items", text)
            assert.equals(oldLimit, addon.db.marketHistoryMaxItems)
            cap.helpButton.scripts.OnLeave(cap.helpButton)
            assert.is_false(GameTooltip.shown)
            addon.db.marketHistoryMaxItems = 1000
            addon:RefreshOptionsControls()
            cap.helpButton.scripts.OnEnter(cap.helpButton)
            assert.is_nil(table.concat(GameTooltip.lines, "\n"):find("Unavailable:", 1, true))
            local scale = ui.row(addon, "worldMapProjectionPinScale")
            scale.helpButton.scripts.OnEnter(scale.helpButton)
            assert.matches("Default: 100%%", table.concat(GameTooltip.lines, "\n"))
            assert.matches("60%% to 200%%", table.concat(GameTooltip.lines, "\n"))
        end)
    end)

    it("cleans up help on navigation, search, and window close", function()
        ui.with_ui(function(addon)
            local row = ui.row(addon, "visualTheme")
            row.helpButton.scripts.OnEnter(row.helpButton)
            assert.is_true(GameTooltip.shown)
            addon.optionsWindow.selectPage("tracking")
            assert.is_false(GameTooltip.shown)
            row = ui.row(addon, "minimumTrackedItemQuality")
            row.helpButton.scripts.OnEnter(row.helpButton)
            addon.optionsWindow.searchInput:SetText("quality")
            assert.is_false(GameTooltip.shown)
            row.helpButton.scripts.OnEnter(row.helpButton)
            addon.optionsWindow:Hide()
            assert.is_false(GameTooltip.shown)
        end)
    end)

    it("searches examples and gives dropdown choices their own help", function()
        ui.with_ui(function(addon)
            addon.optionsWindow.searchInput:SetText("AFK")
            assert.equals("tracking", addon.optionsWindow.selectedPage)
            assert.is_true(ui.row(addon, "useActiveTimeForGoldPerHour"):IsShown())
            ui.menu = {}
            addon.optionsControls.valueSource.initialize(addon.optionsControls.valueSource, 1)
            for _, option in ipairs(ui.menu) do
                assert.is_string(option.tooltipTitle)
                assert.is_string(option.tooltipText)
                assert.is_true(option.tooltipOnButton)
            end
            local rules = ui.row(addon, "highValueDropAlerts")
            assert.is_table(rules.entries[1].threshold.optionsHelp)
            assert.is_table(rules.entries[1].test.optionsHelp)
            assert.is_table(rules.entries[1].remove.optionsHelp)
            assert.is_table(rules.addRule.optionsHelp)
        end)
    end)

    it("opens all twelve pages without loading catalogs or changing preference values", function()
        ui.with_ui(function(addon)
            local ids = {}
            for _, page in ipairs(addon.optionsPages) do
                ids[#ids + 1] = page.id
                addon.optionsWindow.selectPage(page.id)
                assert.is_true(page.scroll:IsShown())
            end
            assert.same({ "modules", "appearance", "tracking", "pricing", "bags", "alts", "maps", "history", "alerts", "logging", "advanced", "experimental" }, ids)
            assert.equals(0, addon.db.marketHistoryMaxItems)
            assert.equals("TSM_DBMINBUYOUT", addon.db.valueSource)
        end)
    end)

    it("keeps logging categories saved while muted and tests only when enabled", function()
        ui.with_ui(function(addon)
            local messages = {}
            loader.with_globals({ DEFAULT_CHAT_FRAME = { AddMessage = function(_, text) messages[#messages + 1] = text end } }, function()
                addon.optionsWindow.selectPage("logging")
                local master = addon.optionsControls.enableChatLogging
                local sessions = addon.optionsControls.chatLogSessions
                sessions:SetChecked(false); ui.click(sessions)
                master:SetChecked(false); ui.click(master)
                assert.is_false(sessions.enabled)
                assert.is_false(addon.optionsControls.testChatLogging.enabled)
                assert.is_false(addon.db.chatLogSessions)
                ui.row(addon, "chatLogSessions").helpButton.scripts.OnEnter(ui.row(addon, "chatLogSessions").helpButton)
                assert.matches("Turn on Enable chat logging", table.concat(GameTooltip.lines, "\n"))
                master:SetChecked(true); ui.click(master)
                assert.is_false(sessions:GetChecked())
                assert.is_true(sessions.enabled)
                addon.db.chatLogCommands = false
                ui.click(addon.optionsControls.testChatLogging)
                assert.equals(1, #messages)
                assert.matches("%[Test%]", messages[1])
                local history = { { name = "keep" } }
                addon.db.history = history
                addon:ResetOptionsPage("logging")
                assert.is_true(addon.db.enableChatLogging)
                for _, category in ipairs(addon.CHAT_LOG_CATEGORIES) do
                    assert.equals(addon.DEFAULTS[category.key], addon.db[category.key])
                end
                assert.equals(history, addon.db.history)
            end)
        end)
    end)

    it("fits every sidebar page at the minimum window size", function()
        ui.with_ui(function(addon)
            addon.optionsWindow:SetSize(860, 540)
            addon.optionsWindow.reflow()
            for _, page in ipairs(addon.optionsPages) do
                local button = page.button
                local top, height = button:Bounds("y")
                local parentTop, parentHeight = button:GetParent():Bounds("y")
                assert.is_true(top >= parentTop)
                assert.is_true(top + height <= parentTop + parentHeight)
                assert.is_true(height >= 24)
            end
        end, 860)
    end)

    it("offers seamless maps as an opt-in experiment and resets only its preference", function()
        ui.with_ui(function(addon)
            local refreshed = 0
            local characters = { offline = { location = { mapID = 113, x = 0.3, y = 0.4 } } }
            addon.db.altCharacters = characters
            addon.RefreshInteractiveMapStyles = function() refreshed = refreshed + 1 end
            assert.is_false(addon.db.enableExperimentalMaps)
            addon.optionsWindow.searchInput:SetText("OpenMap")
            assert.equals("experimental", addon.optionsWindow.selectedPage)
            local row = ui.row(addon, "enableExperimentalMaps")
            assert.is_true(row:IsShown())
            row.helpButton.scripts.OnEnter(row.helpButton)
            assert.matches("Default: Off", table.concat(GameTooltip.lines, "\n"))
            addon.optionsControls.enableExperimentalMaps:SetChecked(true)
            ui.click(addon.optionsControls.enableExperimentalMaps)
            assert.is_true(addon.db.enableExperimentalMaps)
            assert.equals(1, refreshed)
            addon:ResetOptionsPage("experimental")
            assert.is_false(addon.db.enableExperimentalMaps)
            assert.equals(2, refreshed)
            assert.equals(characters, addon.db.altCharacters)
        end)
    end)

    it("searches descriptions and keywords using literal text and handles no matches", function()
        ui.with_ui(function(addon)
            local search = addon.optionsWindow.searchInput
            search:SetText("TSM priority")
            assert.equals("pricing", addon.optionsWindow.selectedPage)
            assert.is_true(ui.row(addon, "valueSourceFallbackOrder"):IsShown())
            local _, pricing = ui.row(addon, "valueSource")
            assert.is_false(pricing.sections[1].frame:IsShown())
            search:SetText("%[")
            for _, page in ipairs(addon.optionsPages) do assert.is_false(page.scroll:IsShown()) end
            assert.is_false(addon.optionsWindow.resetPageButton.enabled)
            search:SetText("")
            assert.is_true(ui.row(addon, "valueSource"):IsShown())
        end)
    end)

    it("validates numeric inputs and preserves a value on Escape", function()
        ui.with_ui(function(addon)
            local input = addon.optionsControls.marketHistoryRetentionDays
            ui.input(input, "abc")
            assert.equals(120, addon.db.marketHistoryRetentionDays)
            assert.equals("120", input:GetText())
            ui.input(input, "400")
            assert.equals(120, addon.db.marketHistoryRetentionDays)
            ui.input(input, "60")
            assert.equals(60, addon.db.marketHistoryRetentionDays)
            input:SetFocus(); input:SetText("80"); input.scripts.OnEscapePressed(input)
            assert.equals(60, addon.db.marketHistoryRetentionDays)
            ui.input(addon.optionsControls.altLowLevelThreshold, "1001")
            assert.equals(20, addon.db.altLowLevelThreshold)
        end)
    end)

    it("keeps unlimited items distinct from retention and per-item samples", function()
        ui.with_ui(function(addon)
            local unlimited = addon.optionsControls.marketHistoryUnlimitedItems
            local cap = addon.optionsControls.marketHistoryMaxItems
            assert.is_false(cap.enabled)
            unlimited:SetChecked(false); ui.click(unlimited)
            assert.equals(500, addon.db.marketHistoryMaxItems)
            assert.is_true(cap.enabled)
            ui.input(cap, "1234")
            assert.equals(1234, addon.db.marketHistoryMaxItems)
            unlimited:SetChecked(true); ui.click(unlimited)
            assert.equals(0, addon.db.marketHistoryMaxItems)
            unlimited:SetChecked(false); ui.click(unlimited)
            assert.equals(1234, addon.db.marketHistoryMaxItems)
            assert.equals(120, addon.db.marketHistoryRetentionDays)
            assert.equals(240, addon.db.marketHistoryMaxSnapshotsPerItem)
        end)
    end)

    it("moves fallback and category sources with arrows without aliasing defaults", function()
        ui.with_ui(function(addon)
            local row = ui.row(addon, "valueSourceFallbackOrder")
            local first, second = addon.db.valueSourceFallbackOrder[1], addon.db.valueSourceFallbackOrder[2]
            ui.click(row.entries[2].up)
            assert.equals(second, addon.db.valueSourceFallbackOrder[1])
            assert.equals(first, addon.DEFAULTS.valueSourceFallbackOrder[1])
            ui.click(row.orderReset)
            assert.same(addon.DEFAULTS.valueSourceFallbackOrder, addon.db.valueSourceFallbackOrder)
            assert.is_false(addon.DEFAULTS.valueSourceFallbackOrder == addon.db.valueSourceFallbackOrder)
            row = ui.row(addon, "inventoryCategoryOrder")
            ui.click(row.entries[1].down)
            assert.equals("consumables", addon.db.inventoryCategoryOrder[1])
        end)
    end)

    it("preserves page scroll positions when navigating and reopening", function()
        ui.with_ui(function(addon)
            local window = addon.optionsWindow
            window.selectPage("tracking")
            local _, tracking = ui.row(addon, "minimumTrackedItemQuality")
            tracking.scroll:SetVerticalScroll(120)
            window.selectPage("pricing"); window.selectPage("tracking")
            assert.equals(120, tracking.scroll:GetVerticalScroll())
            window:Hide(); window:Show()
            assert.equals(120, tracking.scroll:GetVerticalScroll())
        end)
    end)

    it("disables dependent controls while preserving stored values", function()
        ui.with_ui(function(addon)
            addon.db.notificationsEnabled = false
            addon.db.enableSessionHistory = false
            addon:RefreshOptionsControls()
            assert.is_false(addon.optionsControls.allowResumeHistorySession.enabled)
            assert.is_false(addon.optionsControls.historyRowsPerPage.enabled)
            local rules = ui.row(addon, "sessionMilestoneAlerts")
            assert.is_false(rules.addRule.enabled)
            assert.is_false(rules.entries[1].sound.enabled)
            assert.is_false(addon.optionsControls.noLootAlertMinutes.enabled)
            assert.equals(10, addon.db.historyRowsPerPage)
            assert.equals(2, #addon.db.sessionMilestoneAlerts)
        end)
    end)

    it("edits fractional alert thresholds, tests without session mutation, and adds or removes rules", function()
        ui.with_ui(function(addon)
            local rules = ui.row(addon, "highValueDropAlerts")
            ui.input(rules.entries[1].threshold, "12.34")
            assert.equals(123400, addon.db.highValueDropAlerts[1].threshold)
            local session = { active = true, total = 123 }
            addon.session = session
            local messages = 0
            addon.DispatchConfiguredAlert = function(_, message, display, sound)
                assert.is_string(message); assert.is_string(display); assert.is_string(sound)
                messages = messages + 1
            end
            ui.click(rules.entries[1].test)
            assert.equals(1, messages)
            assert.equals(session, addon.session)
            assert.equals(123, session.total)
            ui.click(rules.addRule)
            assert.equals(2, #addon.db.highValueDropAlerts)
            ui.click(rules.entries[1].remove)
            assert.equals(1, #addon.db.highValueDropAlerts)
        end)
    end)

    it("resets only the selected page after a second click and deep copies rule defaults", function()
        ui.with_ui(function(addon)
            local saved = { { name = "Keep this" } }
            addon.db.history = saved
            addon.db.altLowLevelThreshold = 70
            addon.db.highValueDropAlerts[1].threshold = 123400
            addon.optionsWindow.selectPage("alerts")
            local reset = addon.optionsWindow.resetPageButton
            ui.click(reset)
            assert.equals(123400, addon.db.highValueDropAlerts[1].threshold)
            ui.click(reset)
            assert.same(addon.DEFAULTS.highValueDropAlerts, addon.db.highValueDropAlerts)
            assert.is_false(addon.DEFAULTS.highValueDropAlerts[1] == addon.db.highValueDropAlerts[1])
            assert.equals(70, addon.db.altLowLevelThreshold)
            assert.equals(saved, addon.db.history)
            ui.click(reset)
            addon.optionsWindow.selectPage("alts")
            ui.click(reset)
            assert.equals(70, addon.db.altLowLevelThreshold)
            ui.click(reset)
            assert.equals(20, addon.db.altLowLevelThreshold)
        end)
    end)

    it("does not apply a selected skin until reload", function()
        ui.with_ui(function(addon, ns)
            ui.choose(addon.optionsControls.visualTheme, "quietBotanical")
            assert.equals("quietBotanical", addon.db.visualTheme)
            assert.equals("midnight", ns.JanisTheme.key)
            assert.is_true(ui.row(addon, "visualTheme").reload.enabled)
        end)
    end)

    it("resets storage preferences without pruning existing market observations", function()
        ui.with_ui(function(addon)
            local observations = { items = { [123] = { samples = { 1, 2, 3 } } } }
            addon.db.marketHistory = observations
            local pruneCalls = 0
            addon.PruneMarketHistory = function() pruneCalls = pruneCalls + 1 end
            addon.db.marketHistoryRetentionDays = 365
            addon.db.marketHistoryMaxItems = 1234
            addon:ResetOptionsPage("history")
            assert.equals(0, pruneCalls)
            assert.equals(observations, addon.db.marketHistory)
            assert.equals(120, addon.db.marketHistoryRetentionDays)
            assert.equals(0, addon.db.marketHistoryMaxItems)
            assert.is_nil(addon.optionsResettingPage)
        end)
    end)

    it("commits a focused numeric edit when changing page", function()
        ui.with_ui(function(addon)
            addon.optionsWindow.selectPage("alts")
            local input = addon.optionsControls.altLowLevelThreshold
            input:SetFocus(); input:SetText("45")
            addon.optionsWindow.selectPage("appearance")
            assert.equals(45, addon.db.altLowLevelThreshold)
            assert.is_false(input:HasFocus())
        end)
    end)

    it("supports twenty rules, empty lists, and drag reordering without polling", function()
        ui.with_ui(function(addon, _, widgets)
            local rules = ui.row(addon, "sessionMilestoneAlerts")
            while #addon.db.sessionMilestoneAlerts < 20 do addon:AddAlertRule("sessionMilestoneAlerts") end
            addon:RefreshOptionsControls()
            assert.is_false(rules.addRule.enabled)
            addon.optionsWindow.selectPage("alerts")
            local _, alerts = ui.row(addon, "sessionMilestoneAlerts")
            assert.is_true(alerts.scroll:GetVerticalScrollRange() > 500)
            addon.db.sessionMilestoneAlerts = {}
            addon:RefreshOptionsControls()
            assert.is_true(rules.empty:IsShown())
            assert.is_true(rules.addRule.enabled)
            local order = ui.row(addon, "inventoryCategoryOrder")
            local first = addon.db.inventoryCategoryOrder[1]
            order.entries[1].scripts.OnDragStart()
            order.entries[3].scripts.OnEnter()
            order.entries[1].scripts.OnDragStop()
            assert.equals(first, addon.db.inventoryCategoryOrder[3])
            for _, widget in ipairs(widgets) do assert.is_nil(widget.scripts.OnUpdate) end
        end)
    end)

    it("lays out every page at the minimum and maximum widths across every skin", function()
        for _, skin in ipairs({ "midnight", "parchment", "quietBotanical", "quietArcane", "fieldLedger", "minimalVoidglass" }) do
            for _, width in ipairs({ 860, 1000, 1400 }) do
                ui.with_ui(function(addon)
                    for _, page in ipairs(addon.optionsPages) do
                        addon.optionsWindow.selectPage(page.id)
                        assert.is_true(page.scroll:GetHeight() > 200)
                        local scrollY = page.scroll:Bounds("y")
                        local bodyY = addon.optionsContentPanel:Bounds("y")
                        assert.is_true(scrollY > bodyY)
                        assert.is_true(scrollY < bodyY + 140)
                        local previousBottom = 0
                        for _, section in ipairs(page.sections) do
                            if section.frame:IsShown() then
                                local y, h = section.frame:Bounds("y")
                                assert.is_true(y >= previousBottom)
                                previousBottom = y + h
                                for _, row in ipairs(section.rows) do
                                    if row:IsShown() then
                                        local rowY, rowH = row:Bounds("y")
                                        local helpY, helpH = row.help:Bounds("y")
                                        assert.is_true(helpY + helpH <= rowY + rowH)
                                        assert.is_true(row:GetWidth() > 400)
                                        local rowX, rowW = row:Bounds("x")
                                        local helpX, helpW = row.helpButton:Bounds("x")
                                        assert.is_true(helpX >= rowX)
                                        assert.is_true(helpX + helpW <= rowX + rowW)
                                        if row.control then
                                            local x, w = row.control:Bounds("x")
                                            local rowX, rowW = row:Bounds("x")
                                            assert.is_true(x >= rowX - 16)
                                            assert.is_true(x + w <= rowX + rowW)
                                        end
                                    end
                                end
                            end
                        end
                    end
                end, width, skin)
            end
        end
    end)
end)
