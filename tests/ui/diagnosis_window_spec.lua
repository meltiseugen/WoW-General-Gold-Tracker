local loader = require("tests.helpers.addon_loader")

local function load_diagnosis(addon)
    return loader.with_globals({
        date = function(format, timestamp)
            return os.date(format, timestamp)
        end,
        time = function()
            return 2000
        end,
    }, function()
        return loader.load_module("UI/DiagnosisWindow.lua", addon, {
            JanisTheme = {},
        })
    end)
end

describe("UI/DiagnosisWindow text builders", function()
    it("builds diagnosis reports with counters and timing summaries", function()
        local addon = load_diagnosis({
            CloneDiagnosisSnapshot = function(_, snapshot)
                return snapshot
            end,
        })

        local text = addon:BuildDiagnosisReportText({
            counters = {
                event_CHAT_MSG_LOOT = 3,
                loot_chat_item_matches = 2,
            },
            timing = {
                parse_loot_chat = { count = 2, total = 0.05, max = 0.04, last = 0.01 },
            },
        }, {
            title = "Test Diagnosis",
            headerLines = { "Header: Yes" },
        })

        assert.matches("Test Diagnosis", text)
        assert.matches("Header: Yes", text)
        assert.matches("CHAT_MSG_LOOT: 3", text)
        assert.matches("Loot chat item matches: 2", text)
        assert.matches("Loot chat parse: avg 25%.00ms", text)
    end)

    it("returns disabled text for live diagnosis when diagnostics are off", function()
        local addon = load_diagnosis({
            IsDiagnosticsPanelEnabled = function()
                return false
            end,
        })

        assert.matches("Diagnosis is disabled", addon:BuildLiveDiagnosisWindowText())
    end)

    it("builds saved-session diagnosis text with split-session notes", function()
        local addon = load_diagnosis({
            CloneDiagnosisSnapshot = function(_, snapshot)
                return snapshot
            end,
            FormatDuration = function(_, seconds)
                return tostring(seconds) .. "s"
            end,
        })

        local text = loader.with_globals({
            date = function(format, timestamp)
                return os.date(format, timestamp)
            end,
            time = function()
                return 2000
            end,
        }, function()
            return addon:BuildHistoryDiagnosisWindowText({
                name = "Saved Run",
                saveReason = "split",
                savedAt = 200,
                startTime = 100,
                stopTime = 150,
                duration = 50,
                valueSourceLabel = "Market Value",
                diagnosisSnapshot = {
                    startedAt = 90,
                    counters = {
                        money_chat_seen = 1,
                    },
                    timing = {},
                },
            })
        end)

        assert.matches("Saved Session Diagnosis", text)
        assert.matches("Session: Saved Run", text)
        assert.matches("Scope: Source session snapshot", text)
        assert.matches("Diagnosis capture start", text)
        assert.matches("money chat seen", string.lower(text))
    end)
end)

local ui = require("tests.helpers.diagnosis_ui")

describe("Diagnosis workspace", function()
    it("uses a stable scope snapshot until explicitly refreshed and adds no polling", function()
        ui.with_ui(function(addon)
            local frame = addon.diagnosisFrame
            assert.is_nil(frame.scripts.OnUpdate)
            addon:IncrementDiagnosticCounter("loot_chat_seen", 5)
            ui.click(frame.tabButtons.loot)
            assert.is_nil(frame.view.counters.loot_chat_seen)
            ui.click(frame.refreshButton)
            assert.equals(5, frame.view.counters.loot_chat_seen)
            addon:IncrementDiagnosticCounter("loot_chat_seen", 3)
            frame:SetSize(640, 480)
            frame.scripts.OnSizeChanged()
            assert.equals(5, frame.view.counters.loot_chat_seen)
            ui.click(frame.sessionButton)
            assert.equals("session", frame.view.scope)
            assert.equals(8, frame.view.counters.loot_chat_seen)
            assert.is_false(frame.resetButton:IsShown())
            ui.click(frame.runtimeButton)
            assert.equals("runtime", frame.view.scope)
            assert.is_true(frame.resetButton:IsShown())
        end)
    end)

    it("resets only runtime and keeps session and saved snapshots", function()
        ui.with_ui(function(addon)
            addon:IncrementDiagnosticCounter("item_entries_tracked", 12)
            local sessionSnapshot = addon:CloneDiagnosisSnapshot(addon.session.diagnosisSnapshot)
            addon.savedSessions = { [7] = { diagnosisSnapshot = addon:CloneDiagnosisSnapshot(sessionSnapshot) } }
            ui.click(addon.diagnosisFrame.resetButton)
            assert.is_nil(addon.diagnosticsState.counters.item_entries_tracked)
            assert.same(sessionSnapshot, addon.session.diagnosisSnapshot)
            assert.same(sessionSnapshot, addon.savedSessions[7].diagnosisSnapshot)
        end)
    end)

    it("filters zero rows but copies all metrics including unfamiliar saved fields", function()
        ui.with_ui(function(addon)
            local frame = addon.diagnosisFrame
            addon:IncrementDiagnosticCounter("event_BAG_UPDATE_DELAYED", 4)
            addon:IncrementDiagnosticCounter("item_filtered_on_looted", 9)
            addon:IncrementDiagnosticCounter("future_counter", 2)
            addon:IncrementDiagnosticCounter("event_FUTURE_EVENT", 1)
            addon:RecordDiagnosticDuration("future_timing", 0.01)
            ui.click(frame.refreshButton)
            ui.click(frame.tabButtons.events)
            frame.zeroCheck:SetChecked(true)
            ui.click(frame.zeroCheck)
            assert.equals("BAG_UPDATE_DELAYED", frame.cards[1].rows[1].label:GetText())
            assert.equals("FUTURE_EVENT", frame.cards[2].rows[1].label:GetText())
            ui.click(frame.copyButton)
            assert.is_true(frame.reportPanel:IsShown())
            assert.is_true(frame.reportEditBox.highlighted)
            assert.matches("CHAT_MSG_MONEY: 0", frame.reportEditBox:GetText())
            assert.matches("Bind%-on%-loot items excluded %(quantity%): 9", frame.reportEditBox:GetText())
            assert.matches("future_counter: 2", frame.reportEditBox:GetText())
            assert.matches("future_timing: avg 10%.00ms", frame.reportEditBox:GetText())
            frame.reportEditBox.scripts.OnEscapePressed()
            assert.is_false(frame.reportPanel:IsShown())
            assert.equals("events", frame.selectedTab)
            assert.is_true(frame.hideZero)
        end)
    end)

    it("keeps saved and split snapshots readable with runtime capture disabled", function()
        ui.with_ui(function(addon)
            local frame = addon.diagnosisFrame
            addon.savedSessions = { [4] = {
                name = "Saved split", startTime = 500, stopTime = 800, activeDuration = 210, saveReason = "split",
                diagnosisSnapshot = { startedAt = 550, counters = { item_entries_tracked = 37 }, timing = {} },
            } }
            addon.db.enableDiagnosticsPanel = false
            addon:OpenHistoryDiagnosisWindow(4)
            assert.equals("history", frame.view.scope)
            assert.equals(37, frame.view.counters.item_entries_tracked)
            assert.is_false(frame.runtimeButton:IsShown())
            assert.is_false(frame.refreshButton:IsShown())
            assert.is_false(frame.resetButton:IsShown())
            assert.matches("not location%-filtered", frame.view.report)
            assert.matches("Session duration: 00:03:30", frame.view.report)
            ui.click(frame.copyButton)
            assert.matches("Items tracked %(entries%): 37", frame.reportEditBox:GetText())
            addon.savedSessions[4] = nil
            addon:UpdateDiagnosisWindow()
            assert.matches("Saved session not found", frame.view.emptyText)
            assert.is_false(frame.copyButton.enabled)
            assert.is_false(frame.reportPanel:IsShown())
            assert.is_false(frame.reportEditBox.focused)
        end)
    end)

    it("explains absent session data and restores reading positions across tabs and reopen", function()
        ui.with_ui(function(addon)
            local frame = addon.diagnosisFrame
            frame:SetSize(640, 480)
            ui.click(frame.tabButtons.loot)
            frame.scrollFrame:SetVerticalScroll(90)
            ui.click(frame.tabButtons.events)
            frame.scrollFrame:SetVerticalScroll(44)
            ui.click(frame.tabButtons.loot)
            assert.equals(90, frame.scrollFrame:GetVerticalScroll())
            frame:Hide()
            addon:OpenDiagnosisWindow()
            assert.equals("loot", frame.selectedTab)
            assert.equals(90, frame.scrollFrame:GetVerticalScroll())
            addon.savedSessions = { [8] = { startTime = 100, stopTime = 200,
                diagnosisSnapshot = addon:CloneDiagnosisSnapshot(addon.session.diagnosisSnapshot),
            } }
            addon:OpenHistoryDiagnosisWindow(8)
            frame.scrollFrame:SetVerticalScroll(150)
            addon:OpenDiagnosisWindow()
            assert.equals(90, frame.scrollFrame:GetVerticalScroll())
            addon:OpenHistoryDiagnosisWindow(8)
            assert.equals(150, frame.scrollFrame:GetVerticalScroll())
            addon:OpenDiagnosisWindow()
            addon.session.diagnosisSnapshot = nil
            ui.click(frame.sessionButton)
            assert.matches("No diagnosis data for the current session", frame.view.emptyText)
            assert.is_false(frame.copyButton.enabled)
        end)
    end)

    it("reflows all tabs across all six skins and window bounds", function()
        for _, skin in ipairs({ "midnight", "parchment", "quietBotanical", "quietArcane", "fieldLedger", "minimalVoidglass" }) do
            ui.with_ui(function(addon, ns)
                local frame = addon.diagnosisFrame
                for _, size in ipairs({ {640, 480}, {760, 650}, {1280, 960} }) do
                    frame:SetSize(unpack(size))
                    for _, tab in ipairs({ "overview", "loot", "events", "timing" }) do
                        ui.click(frame.tabButtons[tab])
                        assert.is_true(frame.scrollFrame:GetHeight() > 200)
                        local previousBottom
                        for _, card in ipairs(frame.cards) do
                            if card:IsShown() then
                                local y, h = card:Bounds("y")
                                if previousBottom then assert.is_true(y >= previousBottom + 9) end
                                previousBottom = y + h
                                assert.same(ns.JanisTheme:GetColor("textMuted"), card.body.color)
                                for _, row in ipairs(card.rows) do
                                    if row:IsShown() then
                                        local ry, rh = row:Bounds("y")
                                        assert.is_true(ry + rh <= y + h)
                                        for _, value in ipairs(row.values) do
                                            if value:IsShown() then assert.is_true(value:GetWidth() > 60) end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end, skin)
        end
    end)
end)
