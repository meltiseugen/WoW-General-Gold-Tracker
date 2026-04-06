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

local function CreateEmptyDiagnosisSnapshot(startedAt, sessionStartTime)
    local normalizedStartedAt = tonumber(startedAt)
    if not normalizedStartedAt or normalizedStartedAt <= 0 then
        normalizedStartedAt = time()
    end

    local normalizedSessionStartTime = tonumber(sessionStartTime)
    if not normalizedSessionStartTime or normalizedSessionStartTime <= 0 then
        normalizedSessionStartTime = nil
    end

    return {
        startedAt = normalizedStartedAt,
        sessionStartTime = normalizedSessionStartTime,
        counters = {},
        timing = {},
    }
end

function GoldTracker:CreateDiagnosisSnapshot(startedAt, sessionStartTime)
    return CreateEmptyDiagnosisSnapshot(startedAt, sessionStartTime)
end

local function NormalizeTimingBucket(bucket)
    bucket = type(bucket) == "table" and bucket or {}

    local count = math.max(0, math.floor((tonumber(bucket.count) or 0) + 0.5))
    local total = math.max(0, tonumber(bucket.total) or 0)
    local maxValue = math.max(0, tonumber(bucket.max) or 0)
    local lastValue = math.max(0, tonumber(bucket.last) or 0)

    if count <= 0 then
        total = 0
        maxValue = 0
        lastValue = 0
    end

    return {
        count = count,
        total = total,
        max = maxValue,
        last = lastValue,
    }
end

local function MergePositiveTimestamp(a, b)
    local left = tonumber(a)
    if not left or left <= 0 then
        left = nil
    end

    local right = tonumber(b)
    if not right or right <= 0 then
        right = nil
    end

    if left and right then
        return math.min(left, right)
    end
    return left or right
end

function GoldTracker:NormalizeDiagnosisSnapshot(snapshot)
    if type(snapshot) ~= "table" then
        return nil
    end

    local normalized = CreateEmptyDiagnosisSnapshot(snapshot.startedAt, snapshot.sessionStartTime)

    if type(snapshot.counters) == "table" then
        for counterKey, value in pairs(snapshot.counters) do
            if type(counterKey) == "string" and counterKey ~= "" then
                normalized.counters[counterKey] = math.max(0, tonumber(value) or 0)
            end
        end
    end

    if type(snapshot.timing) == "table" then
        for metricKey, bucket in pairs(snapshot.timing) do
            if type(metricKey) == "string" and metricKey ~= "" then
                normalized.timing[metricKey] = NormalizeTimingBucket(bucket)
            end
        end
    end

    snapshot.startedAt = normalized.startedAt
    snapshot.sessionStartTime = normalized.sessionStartTime
    snapshot.counters = normalized.counters
    snapshot.timing = normalized.timing

    return snapshot
end

function GoldTracker:CloneDiagnosisSnapshot(snapshot)
    if type(snapshot) ~= "table" then
        return nil
    end

    local cloned = CreateEmptyDiagnosisSnapshot(snapshot.startedAt, snapshot.sessionStartTime)
    if type(snapshot.counters) == "table" then
        for counterKey, value in pairs(snapshot.counters) do
            if type(counterKey) == "string" and counterKey ~= "" then
                cloned.counters[counterKey] = math.max(0, tonumber(value) or 0)
            end
        end
    end

    if type(snapshot.timing) == "table" then
        for metricKey, bucket in pairs(snapshot.timing) do
            if type(metricKey) == "string" and metricKey ~= "" then
                cloned.timing[metricKey] = NormalizeTimingBucket(bucket)
            end
        end
    end

    return cloned
end

function GoldTracker:MergeDiagnosisSnapshots(baseSnapshot, incomingSnapshot)
    local merged = self:CloneDiagnosisSnapshot(baseSnapshot)
    local incoming = self:CloneDiagnosisSnapshot(incomingSnapshot)

    if not merged then
        return incoming
    end
    if not incoming then
        return merged
    end

    merged.startedAt = MergePositiveTimestamp(merged.startedAt, incoming.startedAt) or time()
    merged.sessionStartTime = MergePositiveTimestamp(merged.sessionStartTime, incoming.sessionStartTime)

    for counterKey, value in pairs(incoming.counters or {}) do
        merged.counters[counterKey] = (tonumber(merged.counters[counterKey]) or 0) + (tonumber(value) or 0)
    end

    for metricKey, bucket in pairs(incoming.timing or {}) do
        local targetBucket = EnsureTimingBucket(merged, metricKey)
        local normalizedIncoming = NormalizeTimingBucket(bucket)
        targetBucket.count = (tonumber(targetBucket.count) or 0) + normalizedIncoming.count
        targetBucket.total = (tonumber(targetBucket.total) or 0) + normalizedIncoming.total
        targetBucket.max = math.max(tonumber(targetBucket.max) or 0, normalizedIncoming.max)
        if normalizedIncoming.count > 0 then
            targetBucket.last = normalizedIncoming.last
        end
    end

    return merged
end

function GoldTracker:EnsureSessionDiagnosisSnapshot()
    if type(self.session) ~= "table" or self.session.active ~= true then
        return nil
    end

    if type(self.session.diagnosisSnapshot) ~= "table" then
        local sessionStartTime = tonumber(self.session.startTime)
        self.session.diagnosisSnapshot = self:CreateDiagnosisSnapshot(time(), sessionStartTime)
    end

    return self:NormalizeDiagnosisSnapshot(self.session.diagnosisSnapshot)
end

function GoldTracker:EnsureDiagnosticsState()
    if type(self.diagnosticsState) ~= "table" then
        self.diagnosticsState = CreateEmptyDiagnosisSnapshot(time(), nil)
    end

    local state = self.diagnosticsState
    return self:NormalizeDiagnosisSnapshot(state)
end

function GoldTracker:ResetDiagnosticsState()
    self.diagnosticsState = CreateEmptyDiagnosisSnapshot(time(), nil)
    if type(self.session) == "table" and self.session.active == true then
        self.session.diagnosisSnapshot = CreateEmptyDiagnosisSnapshot(time(), self.session.startTime)
    end
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

    local sessionSnapshot = self:EnsureSessionDiagnosisSnapshot()
    if sessionSnapshot then
        sessionSnapshot.counters[counterKey] = (tonumber(sessionSnapshot.counters[counterKey]) or 0) + delta
    end
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

    local sessionSnapshot = self:EnsureSessionDiagnosisSnapshot()
    if sessionSnapshot then
        local sessionBucket = EnsureTimingBucket(sessionSnapshot, metricKey)
        sessionBucket.count = (tonumber(sessionBucket.count) or 0) + 1
        sessionBucket.total = (tonumber(sessionBucket.total) or 0) + elapsed
        sessionBucket.max = math.max(tonumber(sessionBucket.max) or 0, elapsed)
        sessionBucket.last = elapsed
    end
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
