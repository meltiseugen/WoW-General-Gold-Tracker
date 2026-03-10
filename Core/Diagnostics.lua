local _, NS = ...
local GoldTracker = NS.GoldTracker

local function GetNowPrecise()
    if type(GetTimePreciseSec) == "function" then
        return GetTimePreciseSec()
    end
    return GetTime()
end

local function EnsureTimingBucket(state, metricKey)
    if type(state.timing[metricKey]) ~= "table" then
        state.timing[metricKey] = {
            count = 0,
            total = 0,
            max = 0,
            last = 0,
        }
    end
    return state.timing[metricKey]
end

function GoldTracker:EnsureDiagnosticsState()
    if type(self.diagnosticsState) ~= "table" then
        self.diagnosticsState = {
            startedAt = time(),
            counters = {},
            timing = {},
        }
    end

    local state = self.diagnosticsState
    if type(state.counters) ~= "table" then
        state.counters = {}
    end
    if type(state.timing) ~= "table" then
        state.timing = {}
    end
    if type(state.startedAt) ~= "number" or state.startedAt <= 0 then
        state.startedAt = time()
    end

    return state
end

function GoldTracker:ResetDiagnosticsState()
    self.diagnosticsState = {
        startedAt = time(),
        counters = {},
        timing = {},
    }
    if type(self.UpdateDiagnosisWindow) == "function" then
        self:UpdateDiagnosisWindow()
    end
end

function GoldTracker:IncrementDiagnosticCounter(counterKey, amount)
    if not self:IsDiagnosticsPanelEnabled() then
        return
    end
    if type(counterKey) ~= "string" or counterKey == "" then
        return
    end

    local delta = tonumber(amount) or 1
    local state = self:EnsureDiagnosticsState()
    state.counters[counterKey] = (tonumber(state.counters[counterKey]) or 0) + delta
end

function GoldTracker:BeginDiagnosticTimer()
    if not self:IsDiagnosticsPanelEnabled() then
        return nil
    end
    return GetNowPrecise()
end

function GoldTracker:RecordDiagnosticDuration(metricKey, elapsedSeconds)
    if not self:IsDiagnosticsPanelEnabled() then
        return
    end
    if type(metricKey) ~= "string" or metricKey == "" then
        return
    end

    local elapsed = tonumber(elapsedSeconds)
    if not elapsed or elapsed < 0 then
        return
    end

    local state = self:EnsureDiagnosticsState()
    local bucket = EnsureTimingBucket(state, metricKey)
    bucket.count = (tonumber(bucket.count) or 0) + 1
    bucket.total = (tonumber(bucket.total) or 0) + elapsed
    bucket.max = math.max(tonumber(bucket.max) or 0, elapsed)
    bucket.last = elapsed
end

function GoldTracker:EndDiagnosticTimer(metricKey, startedAt)
    if not startedAt then
        return
    end

    local elapsed = GetNowPrecise() - startedAt
    if elapsed < 0 then
        elapsed = 0
    end
    self:RecordDiagnosticDuration(metricKey, elapsed)
end

