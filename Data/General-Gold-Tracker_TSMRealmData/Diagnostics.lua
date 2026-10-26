local MODULE, NS = ...
local D = { detailed = false, samples = 0 }
NS.TSMRealmDiagnostics = D

local function Bucket()
    return { count = 0, totalMs = 0, maxMs = 0, measured = 0, allocated = 0, freed = 0, maxAllocated = 0 }
end
D.capture, D.query = Bucket(), Bucket()

local function Clock()
    if type(GetTimePreciseSec) == "function" then return GetTimePreciseSec() * 1000 end
    if type(debugprofilestop) == "function" then return debugprofilestop() end
    if type(GetTime) == "function" then return GetTime() * 1000 end
    return 0
end

-- Contain hook/query failures and never retry a measured function: it may have
-- already executed before an error. No global profiling CVars or GC are changed.
function D.Run(kind, func, ...)
    local bucket = D[kind]
    local start = Clock()
    local ok, result, measurement
    if D.detailed and C_AddOnProfiler and type(C_AddOnProfiler.MeasureCall) == "function" then
        local stats
        ok, stats, result = pcall(C_AddOnProfiler.MeasureCall, func, ...)
        if ok then measurement = stats else result = stats end
    else
        ok, result = pcall(func, ...)
    end
    local elapsed = math.max(0, Clock() - start)
    if type(measurement) == "table" then
        elapsed = tonumber(measurement.elapsedMilliseconds) or elapsed
        local allocated = tonumber(measurement.allocatedBytes) or 0
        bucket.measured = bucket.measured + 1
        bucket.allocated = bucket.allocated + allocated
        bucket.freed = bucket.freed + (tonumber(measurement.deallocatedBytes) or 0)
        bucket.maxAllocated = math.max(bucket.maxAllocated, allocated)
    end
    bucket.count = bucket.count + 1
    bucket.totalMs = bucket.totalMs + elapsed
    bucket.maxMs = math.max(bucket.maxMs, elapsed)
    return ok, result
end

function D.SampleMemory()
    local update = C_AddOns and C_AddOns.UpdateAddOnMemoryUsage or UpdateAddOnMemoryUsage
    local get = C_AddOns and C_AddOns.GetAddOnMemoryUsage or GetAddOnMemoryUsage
    if type(update) ~= "function" or type(get) ~= "function" then return false end
    local updated = pcall(update)
    if not updated then return false end
    local ok, kib = pcall(get, MODULE)
    if not ok or type(kib) ~= "number" then return false end
    D.memoryKiB = kib
    D.peakKiB = math.max(D.peakKiB or 0, kib)
    D.samples = D.samples + 1
    return true
end

function D.SetDetailed(enabled)
    D.detailed = enabled == true
    -- Only this preference persists. Captured payloads/metrics are never saved.
    GGTTSMRealmDataSettings = { detailed = D.detailed }
    if D.ticker then D.ticker:Cancel(); D.ticker = nil end
    if D.detailed then
        D.SampleMemory()
        if C_Timer and type(C_Timer.NewTicker) == "function" then
            D.ticker = C_Timer.NewTicker(5, D.SampleMemory)
        end
    end
end

function D.LoadSettings()
    local settings = type(GGTTSMRealmDataSettings) == "table" and GGTTSMRealmDataSettings or {}
    D.SetDetailed(settings.detailed == true)
end

function D.Reset()
    D.capture, D.query = Bucket(), Bucket()
    D.memoryKiB, D.peakKiB, D.samples = nil, nil, 0
    D.SampleMemory()
end

function D.Report()
    D.SampleMemory()
    local hasNative = C_AddOnProfiler and type(C_AddOnProfiler.MeasureCall) == "function"
    local lines = {
        "Detailed profiling=" .. (D.detailed and "ON (5-second memory sampling)" or "off (no periodic sampling)")
            .. "; native call profiler=" .. (hasNative and "available" or "unavailable; elapsed timing only"),
    }
    for _, key in ipairs({ "capture", "query" }) do
        local bucket = D[key]
        lines[#lines + 1] = string.format("%s work: calls=%d; total=%.3f ms; avg=%.3f ms; max=%.3f ms",
            key, bucket.count, bucket.totalMs, bucket.count > 0 and bucket.totalMs / bucket.count or 0, bucket.maxMs)
        if bucket.measured > 0 then
            lines[#lines + 1] = string.format("%s native measurements=%d; allocated=%.1f KiB; freed=%.1f KiB; largest allocation/call=%.1f KiB",
                key, bucket.measured, bucket.allocated / 1024, bucket.freed / 1024, bucket.maxAllocated / 1024)
        end
    end
    if D.memoryKiB then
        lines[#lines + 1] = string.format("WoW-attributed module memory=%.1f KiB; highest sample=%.1f KiB; samples=%d",
            D.memoryKiB, D.peakKiB, D.samples)
    else
        lines[#lines + 1] = "WoW-attributed module memory=unavailable"
    end
    lines[#lines + 1] = "Timing covers capture/query work only. Memory attribution can exclude strings shared with TSM; highest sample is not a true peak."
    return table.concat(lines, "\n")
end
