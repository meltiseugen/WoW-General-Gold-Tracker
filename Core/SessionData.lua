local _, NS = ...
local GoldTracker = NS.GoldTracker

-- Persist location descriptions once per recording. The public event fields
-- remain readable through __index, including for older consumers of history.
local LOCATION_FIELDS = {
    "locationKey", "locationLabel", "isInstanced", "instanceName", "instanceMapID", "instanceType",
    "zoneName", "mapID", "mapName", "mapPath", "continentName", "expansionID", "expansionName",
}

function GoldTracker:HydrateSessionLocations(session)
    if type(session) ~= "table" or type(session.locations) ~= "table" then return session end
    local metas = {}
    for _, list in ipairs({ session.itemLoots or {}, session.moneyLoots or {} }) do
        for _, entry in ipairs(list) do
            local ref = entry.locationRef
            local context = ref and session.locations[ref]
            if context and (not getmetatable(entry) or getmetatable(entry).__index ~= context) then
                metas[ref] = metas[ref] or { __index = context }
                setmetatable(entry, metas[ref])
            end
        end
    end
    return session
end

function GoldTracker:CompactSessionLocations(session)
    self:HydrateSessionLocations(session)
    local locations, bySignature, metas = {}, {}, {}
    for _, list in ipairs({ session.itemLoots or {}, session.moneyLoots or {} }) do
        for _, entry in ipairs(list) do
            local context, signature = {}, {}
            for _, field in ipairs(LOCATION_FIELDS) do
                context[field] = entry[field]
                signature[#signature + 1] = type(entry[field]) .. ":" .. tostring(entry[field])
            end
            local key = table.concat(signature, "\001")
            local ref = bySignature[key]
            if not ref then ref = #locations + 1; locations[ref] = context; bySignature[key] = ref end
            entry.locationRef = ref
            for _, field in ipairs(LOCATION_FIELDS) do entry[field] = nil end
            metas[ref] = metas[ref] or { __index = locations[ref] }
            setmetatable(entry, metas[ref])
        end
    end
    session.locations = locations
    session.storageVersion = 2
    return session
end

function GoldTracker:CopySessionIntervals(intervals)
    local result = {}
    for _, interval in ipairs(intervals or {}) do
        result[#result + 1] = {
            startTime = tonumber(interval.startTime), stopTime = tonumber(interval.stopTime),
            locationKey = interval.locationKey, locationLabel = interval.locationLabel,
            estimated = interval.estimated == true or nil,
        }
    end
    return result
end

function GoldTracker:GetSessionIntervalDuration(intervals, now)
    local ordered = {}
    for _, interval in ipairs(intervals or {}) do
        local first = tonumber(interval.startTime)
        local last = tonumber(interval.stopTime) or tonumber(now)
        if first and last and last >= first then ordered[#ordered + 1] = { first, last } end
    end
    table.sort(ordered, function(a, b) return a[1] < b[1] end)
    local total, first, last = 0
    for _, interval in ipairs(ordered) do
        if last and interval[1] <= last then last = math.max(last, interval[2])
        else
            if last then total = total + last - first end
            first, last = interval[1], interval[2]
        end
    end
    return total + (last and last - first or 0)
end

function GoldTracker:GetSessionSplitMode()
    local mode = self.db and self.db.sessionSplitMode
    if mode == "instance" or mode == "location" or mode == "continuous" then return mode end
    return self.db and self.db.autoStartSessionOnLocationChange == true and "location" or "continuous"
end

function GoldTracker:GetLocationGroupKey(location)
    location = location or {}
    if location.groupKey then return location.groupKey end
    local key = location.locationKey or ""
    if location.isInstanced == true or key:match("^instance:") then
        local instanceID = tonumber(location.instanceMapID) or tonumber(key:match("^instance:(%d+)"))
        if instanceID and instanceID > 0 then return "instance:" .. instanceID end
        local name = location.instanceName or location.zoneName
        return name and name ~= "" and "instance:" .. string.lower(name) or nil
    end
    local mapID = tonumber(location.mapID) or tonumber(key:match(":(%d+)$"))
    if mapID and mapID > 0 then
        self.sessionLocationGroupCache = self.sessionLocationGroupCache or {}
        local originalMapID = mapID
        if self.sessionLocationGroupCache[originalMapID] then return self.sessionLocationGroupCache[originalMapID] end
        -- Floors and micro maps share their enclosing zone. No polling needed.
        local current, seen = mapID, {}
        while C_Map and C_Map.GetMapInfo and current and current > 0 and not seen[current] do
            seen[current] = true
            local info = C_Map.GetMapInfo(current)
            if not info then break end
            if info.mapType == 3 then
                mapID = current
                self.sessionLocationGroupCache[originalMapID] = "zone:" .. mapID
                break
            end
            if info.mapType and info.mapType < 3 then break end
            current = tonumber(info.parentMapID)
        end
        return "zone:" .. mapID
    end
    local name = location.zoneName or location.mapName
    if not name and key ~= "" and key ~= "zone::0" then name = key end
    return name and name ~= "" and "zone:" .. string.lower(name) or nil
end

function GoldTracker:GetLocationGroupLabel(location)
    if location.isInstanced == true then return location.instanceName or location.zoneName or "Unknown instance" end
    local key = self:GetLocationGroupKey(location)
    local mapID = key and tonumber(key:match("^zone:(%d+)$"))
    local info = mapID and C_Map and C_Map.GetMapInfo and C_Map.GetMapInfo(mapID)
    return info and info.name or location.mapName or location.zoneName or location.locationLabel or "Unknown location"
end

function GoldTracker:UpdateSessionVisit(snapshot, timestamp)
    local session = self.session
    if not session or session.active ~= true then return end
    local key = self:GetLocationGroupKey(snapshot)
    if not key then return end
    local visits = session.locationVisits or {}
    session.locationVisits = visits
    local last = visits[#visits]
    local now = tonumber(timestamp) or time()
    if last and not last.stopTime and last.locationKey == key then return end
    if last and not last.stopTime then last.stopTime = now end
    visits[#visits + 1] = { locationKey = key, locationLabel = self:GetLocationGroupLabel(snapshot), startTime = now }
end

function GoldTracker:CloseSessionRecording(timestamp)
    local session = self.session
    if not session then return end
    local now = tonumber(timestamp) or time()
    for _, list in ipairs({ session.recordingPeriods or {}, session.locationVisits or {} }) do
        local last = list[#list]
        if last and not last.stopTime then last.stopTime = math.max(tonumber(last.startTime) or now, now) end
    end
end

function GoldTracker:ContinueSessionRecording(source, timestamp)
    local session = self.session
    local now = tonumber(timestamp) or time()
    session.recordingPeriods = self:CopySessionIntervals(source.recordingPeriods)
    session.locationVisits = self:CopySessionIntervals(source.locationVisits)
    if #session.recordingPeriods == 0 then
        local stop = tonumber(source.stopTime or source.savedAt) or now
        session.recordingPeriods[1] = { startTime = tonumber(source.startTime) or stop, stopTime = stop, estimated = true }
    end
    session.recordingPeriods[#session.recordingPeriods + 1] = { startTime = now }
    session.timingVersion = 2
    session.lastLootAt = now
end
