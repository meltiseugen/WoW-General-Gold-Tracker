local loader = require("tests.helpers.addon_loader")

local function load_diagnostics(addon, globals)
    return loader.with_globals(globals or {}, function()
        return loader.load_module("Core/Diagnostics.lua", addon)
    end)
end

describe("Core/Diagnostics", function()
    it("normalizes negative counters and empty timing buckets", function()
        local addon = load_diagnostics({}, {
            time = function()
                return 1000
            end,
        })

        local snapshot = loader.with_globals({
            time = function()
                return 1000
            end,
        }, function()
            return addon:NormalizeDiagnosisSnapshot({
                startedAt = -1,
                sessionStartTime = 900,
                counters = {
                    chatLootMessages = "3",
                    ignored = -2,
                    [""] = 99,
                },
                timing = {
                    scan = { count = 0, total = 5, max = 3, last = 1 },
                    loot = { count = "2.4", total = 0.3, max = 0.2, last = 0.1 },
                },
            })
        end)

        assert.equals(1000, snapshot.startedAt)
        assert.equals(900, snapshot.sessionStartTime)
        assert.equals(3, snapshot.counters.chatLootMessages)
        assert.equals(0, snapshot.counters.ignored)
        assert.is_nil(snapshot.counters[""])
        assert.same({ count = 0, total = 0, max = 0, last = 0 }, snapshot.timing.scan)
        assert.same({ count = 2, total = 0.3, max = 0.2, last = 0.1 }, snapshot.timing.loot)
    end)

    it("merges counters and timing while keeping earliest positive timestamps", function()
        local addon = load_diagnostics({}, {
            time = function()
                return 5000
            end,
        })

        local merged = addon:MergeDiagnosisSnapshots({
            startedAt = 2000,
            sessionStartTime = 2100,
            counters = { a = 1 },
            timing = { scan = { count = 1, total = 0.2, max = 0.2, last = 0.2 } },
        }, {
            startedAt = 1500,
            sessionStartTime = 0,
            counters = { a = 2, b = 3 },
            timing = { scan = { count = 2, total = 0.5, max = 0.4, last = 0.1 } },
        })

        assert.equals(1500, merged.startedAt)
        assert.equals(2100, merged.sessionStartTime)
        assert.same({ a = 3, b = 3 }, merged.counters)
        assert.equals(3, merged.timing.scan.count)
        assert.near(0.7, merged.timing.scan.total, 0.0001)
        assert.equals(0.4, merged.timing.scan.max)
        assert.equals(0.1, merged.timing.scan.last)
    end)

    it("records counters and timings into both addon and active-session snapshots", function()
        local addon = load_diagnostics({
            session = {
                active = true,
                startTime = 100,
            },
            IsDiagnosticsPanelEnabled = function()
                return true
            end,
        }, {
            time = function()
                return 120
            end,
            GetTime = function()
                return 20
            end,
            GetTimePreciseSec = function()
                return 20.5
            end,
        })

        loader.with_globals({
            time = function()
                return 120
            end,
            GetTime = function()
                return 20
            end,
            GetTimePreciseSec = function()
                return 20.5
            end,
        }, function()
            addon:IncrementDiagnosticCounter("lootEvents", 2)
            addon:RecordDiagnosticDuration("lootPipeline", 0.25)
            addon:EndDiagnosticTimer("lootPipeline", 20)
        end)

        assert.equals(2, addon.diagnosticsState.counters.lootEvents)
        assert.equals(2, addon.session.diagnosisSnapshot.counters.lootEvents)
        assert.equals(2, addon.diagnosticsState.timing.lootPipeline.count)
        assert.equals(2, addon.session.diagnosisSnapshot.timing.lootPipeline.count)
        assert.equals(0.5, addon.diagnosticsState.timing.lootPipeline.last)
    end)
end)
