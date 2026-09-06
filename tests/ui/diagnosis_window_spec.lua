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
