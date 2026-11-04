local _, NS = ...

local HistoryConstants = NS.HistoryConstants

local HistorySessionModel = {}
HistorySessionModel.__index = HistorySessionModel

function HistorySessionModel:New(addon, session, allLocationKey)
    local instance = {
        addon = addon,
        session = session,
        allLocationKey = allLocationKey or HistoryConstants.DETAILS_LOCATION_FILTER_ALL,
    }
    return setmetatable(instance, HistorySessionModel)
end

function HistorySessionModel:GetSession(session)
    local resolved = session or self.session
    if type(resolved) ~= "table" then
        return nil
    end
    return resolved
end

function HistorySessionModel:Trim(value)
    if type(self.addon) == "table" and type(self.addon.Trim) == "function" then
        return self.addon:Trim(value)
    end
    if type(value) ~= "string" then
        return ""
    end
    return (value:gsub("^%s+", ""):gsub("%s+$", ""))
end

function HistorySessionModel:NormalizeDisplayedMapPath(mapPath)
    if type(mapPath) ~= "string" then
        return nil
    end

    local trimmedPath = self:Trim(mapPath)
    if trimmedPath == "" then
        return nil
    end

    local segments = {}
    for rawSegment in trimmedPath:gmatch("[^>]+") do
        local segment = self:Trim(rawSegment)
        if segment ~= "" then
            segments[#segments + 1] = segment
        end
    end

    if #segments == 0 then
        return nil
    end

    if string.lower(segments[1]) == "cosmic" then
        table.remove(segments, 1)
    end

    if #segments == 0 then
        return nil
    end

    return table.concat(segments, " > ")
end

function HistorySessionModel:BuildLocationDetailsText(session)
    local resolvedSession = self:GetSession(session)
    if not resolvedSession then
        return ""
    end

    local parts = {}
    local displayPath = self:NormalizeDisplayedMapPath(resolvedSession.mapPath)

    if type(displayPath) == "string" and displayPath ~= "" then
        parts[#parts + 1] = string.format("Location: %s", displayPath)
    elseif type(resolvedSession.mapName) == "string" and resolvedSession.mapName ~= "" then
        parts[#parts + 1] = string.format("Location: %s", resolvedSession.mapName)
    end

    if type(resolvedSession.expansionName) == "string" and resolvedSession.expansionName ~= "" then
        parts[#parts + 1] = string.format("Expansion: %s", resolvedSession.expansionName)
    end

    if #parts == 0 then
        return ""
    end

    return table.concat(parts, "   ")
end

function HistorySessionModel:ResolveHistoryLocationKey(entry, fallbackSession)
    if type(entry) == "table" and type(entry.locationKey) == "string" and entry.locationKey ~= "" then
        return entry.locationKey
    end

    local source = entry
    if type(source) ~= "table" then
        source = fallbackSession or self.session
    end
    if type(source) ~= "table" then
        return "unknown"
    end

    local isInstanced = source.isInstanced == true
    if isInstanced then
        return string.format("instance:%s:%s", tostring(source.instanceMapID or source.mapID or 0), tostring(source.instanceName or ""))
    end
    return string.format("zone:%s:%s", tostring(source.zoneName or source.mapName or ""), tostring(source.mapID or 0))
end

function HistorySessionModel:ResolveHistoryLocationLabel(entry, fallbackSession)
    local source = type(entry) == "table" and entry or fallbackSession or self.session or {}
    if self.addon.GetLocationGroupLabel then return self.addon:GetLocationGroupLabel(source) end
    return (source.isInstanced and source.instanceName) or source.mapName or source.zoneName or source.locationLabel or "Unknown location"
end

function HistorySessionModel:GetMapPathLeaf(mapPath)
    local normalizedPath = self:NormalizeDisplayedMapPath(mapPath)
    if type(normalizedPath) ~= "string" or normalizedPath == "" then
        return nil
    end

    local leaf = normalizedPath:match("([^>]+)$")
    leaf = self:Trim(leaf)
    if leaf == "" then
        return nil
    end

    return leaf
end

function HistorySessionModel:ResolveHistoryLocationIdentity(entry, fallbackSession)
    local source = type(entry) == "table" and entry or fallbackSession or self.session or {}
    if self.addon.GetLocationGroupKey then return self.addon:GetLocationGroupKey(source) or "unknown" end
    local key = source.locationKey or ""
    if source.isInstanced == true or key:match("^instance:") then
        local id = source.instanceMapID or key:match("^instance:(%d+)")
        return "instance:" .. tostring(id or string.lower(source.instanceName or source.zoneName or "unknown"))
    end
    local id = source.mapID or key:match(":(%d+)$")
    if id and tonumber(id) and tonumber(id) > 0 then return "zone:" .. id end
    return "zone:" .. string.lower(source.zoneName or source.mapName or key or "unknown")
end

function HistorySessionModel:EntryMatchesLocation(entry, selectedLocationKey, fallbackSession)
    if type(selectedLocationKey) ~= "string" or selectedLocationKey == "" or selectedLocationKey == self.allLocationKey then
        return true
    end

    if string.sub(selectedLocationKey, 1, 4) == "loc:" then
        return selectedLocationKey == ("loc:" .. self:ResolveHistoryLocationIdentity(entry, fallbackSession))
    end

    return self:ResolveHistoryLocationKey(entry, fallbackSession) == selectedLocationKey
end

function HistorySessionModel:ResolveHistoryLocationPath(entry, fallbackSession)
    local source = entry
    if type(source) ~= "table" then
        source = fallbackSession or self.session
    end
    if type(source) ~= "table" then
        return "Unknown"
    end

    local displayPath = self:NormalizeDisplayedMapPath(source.mapPath)
    if type(displayPath) == "string" and displayPath ~= "" then
        local pathLeaf = self:GetMapPathLeaf(displayPath)
        local specificLeaf
        if source.isInstanced == true then
            specificLeaf = source.instanceName or source.zoneName or source.mapName
        else
            specificLeaf = source.zoneName or source.mapName
        end
        specificLeaf = self:Trim(specificLeaf)
        if specificLeaf ~= "" then
            local normalizedPathLeaf = string.lower(self:Trim(pathLeaf))
            local normalizedSpecificLeaf = string.lower(specificLeaf)
            if normalizedPathLeaf == "" or normalizedPathLeaf ~= normalizedSpecificLeaf then
                return string.format("%s > %s", displayPath, specificLeaf)
            end
        end
        return displayPath
    end
    if type(source.mapName) == "string" and source.mapName ~= "" then
        return source.mapName
    end

    return self:ResolveHistoryLocationLabel(source, fallbackSession)
end

function HistorySessionModel:BuildHistoryLocationOptions(session)
    local resolvedSession = self:GetSession(session)
    if not resolvedSession then
        return {
            { key = self.allLocationKey, label = "All locations", firstTimestamp = 0 },
        }
    end

    local options = {
        { key = self.allLocationKey, label = "All locations", firstTimestamp = 0 },
    }
    local byKey = {}

    local function AddLocation(entry, fallbackTimestamp)
        local key = "loc:" .. self:ResolveHistoryLocationIdentity(entry, resolvedSession)
        local label = self:ResolveHistoryLocationLabel(entry, resolvedSession)
        local timestamp = tonumber(entry and entry.timestamp) or tonumber(fallbackTimestamp) or 0
        local existing = byKey[key]
        if existing then
            if timestamp > 0 and (existing.firstTimestamp <= 0 or timestamp < existing.firstTimestamp) then
                existing.firstTimestamp = timestamp
            end
            return
        end

        local option = {
            key = key,
            label = label,
            firstTimestamp = timestamp,
        }
        byKey[key] = option
        options[#options + 1] = option
    end

    for _, entry in ipairs(resolvedSession.itemLoots or {}) do
        AddLocation(entry, resolvedSession.startTime)
    end
    for _, entry in ipairs(resolvedSession.moneyLoots or {}) do
        AddLocation(entry, resolvedSession.startTime)
    end

    for _, visit in ipairs(resolvedSession.locationVisits or {}) do AddLocation(visit, visit.startTime) end
    if #options == 1 then
        AddLocation(resolvedSession, resolvedSession.startTime)
    end

    table.sort(options, function(a, b)
        local aAll = a.key == self.allLocationKey
        local bAll = b.key == self.allLocationKey
        if aAll ~= bAll then
            return aAll
        end

        local aTs = tonumber(a.firstTimestamp) or 0
        local bTs = tonumber(b.firstTimestamp) or 0
        if aTs > 0 and bTs > 0 and aTs ~= bTs then
            return aTs < bTs
        end
        return tostring(a.label) < tostring(b.label)
    end)

    return options
end

function HistorySessionModel:GetEventTimeBounds(session)
    local resolvedSession = self:GetSession(session)
    if not resolvedSession then
        return 0, 0, 0, 0
    end

    local firstEventTimestamp = 0
    local lastEventTimestamp = 0

    local function ConsiderTimestamp(timestamp)
        local normalized = tonumber(timestamp) or 0
        if normalized <= 0 then
            return
        end

        if firstEventTimestamp <= 0 or normalized < firstEventTimestamp then
            firstEventTimestamp = normalized
        end
        if normalized > lastEventTimestamp then
            lastEventTimestamp = normalized
        end
    end

    for _, loot in ipairs(resolvedSession.itemLoots or {}) do
        ConsiderTimestamp(loot and loot.timestamp)
    end
    for _, money in ipairs(resolvedSession.moneyLoots or {}) do
        ConsiderTimestamp(money and money.timestamp)
    end

    local startTimestamp = tonumber(resolvedSession.startTime) or 0
    local stopTimestamp = tonumber(resolvedSession.stopTime or resolvedSession.savedAt) or 0

    if firstEventTimestamp > 0 and (startTimestamp <= 0 or firstEventTimestamp < startTimestamp) then
        startTimestamp = firstEventTimestamp
    end
    if stopTimestamp <= 0 then
        stopTimestamp = lastEventTimestamp
    elseif lastEventTimestamp > 0 and lastEventTimestamp > stopTimestamp then
        stopTimestamp = lastEventTimestamp
    end
    if startTimestamp <= 0 then
        startTimestamp = stopTimestamp
    end
    if stopTimestamp <= 0 then
        stopTimestamp = startTimestamp
    end
    if stopTimestamp > 0 and startTimestamp > 0 and stopTimestamp < startTimestamp then
        stopTimestamp = startTimestamp
    end

    return startTimestamp, stopTimestamp, firstEventTimestamp, lastEventTimestamp
end

function HistorySessionModel:GetReferenceTimestamp(session)
    local startTimestamp = self:GetEventTimeBounds(session)
    return tonumber(startTimestamp) or 0
end

function HistorySessionModel:SumIntervals(intervals)
    if self.addon.GetSessionIntervalDuration then return self.addon:GetSessionIntervalDuration(intervals) end
    local ordered = {}
    for _, v in ipairs(intervals or {}) do
        if tonumber(v.startTime) and tonumber(v.stopTime) and v.stopTime >= v.startTime then
            ordered[#ordered + 1] = { v.startTime, v.stopTime }
        end
    end
    table.sort(ordered, function(a,b) return a[1] < b[1] end)
    local total, first, last = 0
    for _, v in ipairs(ordered) do
        if last and v[1] <= last then last = math.max(last,v[2])
        else
            if last then total = total + last - first end
            first,last = v[1],v[2]
        end
    end
    return total + (last and last-first or 0)
end

function HistorySessionModel:GetTimingLabel(session)
    local source = self:GetSession(session) or {}
    if type(source.recordingPeriods) ~= "table" or #source.recordingPeriods == 0 then return "Elapsed span (legacy)" end
    for _, period in ipairs(source.recordingPeriods) do if period.estimated then return "Recorded time + legacy span" end end
    return "Recorded time"
end

function HistorySessionModel:GetRateDuration(session)
    local source = self:GetSession(session) or {}
    if self.addon.IsActiveTimeForGoldPerHourEnabled and self.addon:IsActiveTimeForGoldPerHourEnabled() then
        if tonumber(source.activeDuration) and source.activeDuration > 0 then return source.activeDuration, "Estimated active loot time" end
    end
    return self:GetDurationSeconds(source), self:GetTimingLabel(source)
end

function HistorySessionModel:GetDurationSeconds(session)
    local resolvedSession = self:GetSession(session)
    if not resolvedSession then
        return 0
    end

    if type(resolvedSession.recordingPeriods) == "table" and #resolvedSession.recordingPeriods > 0 then
        return self:SumIntervals(resolvedSession.recordingPeriods)
    end
    local explicitDuration = math.max(0, math.floor((tonumber(resolvedSession.duration) or 0) + 0.5))
    local startTimestamp, stopTimestamp, firstEventTimestamp, lastEventTimestamp = self:GetEventTimeBounds(resolvedSession)
    local boundedDuration = 0
    if startTimestamp > 0 and stopTimestamp >= startTimestamp then
        boundedDuration = stopTimestamp - startTimestamp
    end

    local eventDuration = 0
    if firstEventTimestamp > 0 and lastEventTimestamp >= firstEventTimestamp then
        eventDuration = lastEventTimestamp - firstEventTimestamp
    end

    return math.max(explicitDuration, boundedDuration, eventDuration)
end

function HistorySessionModel:FormatDurationMinutesLabel(durationSeconds)
    local seconds = math.max(0, math.floor((tonumber(durationSeconds) or 0) + 0.5))
    if seconds < 60 then
        return "<1m"
    end

    local totalMinutes = math.floor(seconds / 60)
    local hours = math.floor(totalMinutes / 60)
    local minutes = totalMinutes % 60

    if hours > 0 then
        return string.format("%dh %02dm", hours, minutes)
    end

    return string.format("%dm", totalMinutes)
end

function HistorySessionModel:BuildLocationDetailsRowsForSelection(selectedLocationKey, session, selectedStyleID)
    local source = self:GetSession(session)
    if not source then return {} end
    local buckets, ordered = {}, {}
    local style = selectedStyleID or "all"
    local function bucket(entry)
        if not self:EntryMatchesLocation(entry, selectedLocationKey, source) then return nil end
        local key = "loc:" .. self:ResolveHistoryLocationIdentity(entry, source)
        if not buckets[key] then
            local row = { key = key, location = self:ResolveHistoryLocationLabel(entry, source),
                path = self:ResolveHistoryLocationPath(entry, source), highlights = 0,
                totalValue = 0, quantity = 0, intervals = {}, visitCount = 0, timestamps = {} }
            buckets[key] = row; ordered[#ordered + 1] = row
        end
        return buckets[key]
    end
    local function timestamp(row, ts)
        ts = tonumber(ts)
        if ts and ts > 0 then
            row.firstTimestamp = math.min(row.firstTimestamp or ts, ts)
            row.lastTimestamp = math.max(row.lastTimestamp or ts, ts)
            row.timestamps[#row.timestamps + 1] = ts
        end
    end
    for _, entry in ipairs(source.itemLoots or {}) do
        if style == "all" or (self.addon.LootItemMatchesSessionStyle and self.addon:LootItemMatchesSessionStyle(entry,style)) then
            local row = bucket(entry)
            if row then
                row.totalValue = row.totalValue + (tonumber(entry.totalValue) or 0)
                row.quantity = row.quantity + (tonumber(entry.quantity) or 0)
                row.highlights = row.highlights + (entry.isHighlighted and 1 or 0)
                timestamp(row,entry.timestamp)
            end
        end
    end
    if style == "all" then
        for _, entry in ipairs(source.moneyLoots or {}) do
            local row = bucket(entry)
            if row then row.totalValue = row.totalValue + (tonumber(entry.amount) or 0); timestamp(row,entry.timestamp) end
        end
    end
    for _, visit in ipairs(source.locationVisits or {}) do
        local key = "loc:" .. tostring(visit.locationKey)
        if selectedLocationKey == self.allLocationKey or selectedLocationKey == key then
            local row = buckets[key]
            if not row then
                row = { key=key, location=visit.locationLabel or "Unknown location", path=visit.locationLabel,
                    highlights=0,totalValue=0,quantity=0,intervals={},visitCount=0,timestamps={} }
                buckets[key]=row; ordered[#ordered+1]=row
            end
            row.intervals[#row.intervals+1]=visit
            row.visitCount=row.visitCount+1
            timestamp(row,visit.startTime); timestamp(row,visit.stopTime)
        end
    end
    if #ordered == 0 then
        local row = bucket(source)
        if row then
            row.totalValue = tonumber(source.totalValue) or 0
            timestamp(row,source.startTime); timestamp(row,source.stopTime or source.savedAt)
        end
    end
    for _, row in ipairs(ordered) do
        local known = #row.intervals > 0
        row.durationSeconds = known and self:SumIntervals(row.intervals) or nil
        row.duration = known and self:FormatDurationMinutesLabel(row.durationSeconds) or "Unknown"
        row.spanSeconds = math.max(0,(row.lastTimestamp or 0)-(row.firstTimestamp or 0))
        row.timingLabel = known and "Recorded visits" or "Loot activity span; visits not recorded"
        row.visits = known and row.visitCount or nil
        row.timeFrameStart = row.firstTimestamp and date("%m-%d %H:%M",row.firstTimestamp) or "Unknown"
        row.timeFrameEnd = row.lastTimestamp and date("%m-%d %H:%M",row.lastTimestamp) or "Unknown"
        row.timeFrame = row.timeFrameStart .. " - " .. row.timeFrameEnd
    end
    table.sort(ordered,function(a,b) return (a.firstTimestamp or 0) < (b.firstTimestamp or 0) end)
    return ordered
end

function HistorySessionModel:BuildLocationDetailsTextForSelection(selectedLocationKey, session)
    local rows = self:BuildLocationDetailsRowsForSelection(selectedLocationKey, session)
    if #rows == 0 then
        return self:BuildLocationDetailsText(session)
    end

    local lines = {}
    for index, row in ipairs(rows) do
        local compactTimeFrameText = row.timeFrameStart or "Unknown"
        if type(row.timeFrameEnd) == "string" and row.timeFrameEnd ~= "" and row.timeFrameEnd ~= row.timeFrameStart then
            compactTimeFrameText = string.format("%s -> %s", row.timeFrameStart, row.timeFrameEnd)
        end
        if index == 1 then
            lines[#lines + 1] = string.format("Location: %s", row.location or "Unknown")
            lines[#lines + 1] = string.format("    Time frame: %s", compactTimeFrameText)
        else
            lines[#lines + 1] = string.format("    Also: %s", row.location or "Unknown")
            lines[#lines + 1] = string.format("        Time frame: %s", compactTimeFrameText)
        end
    end
    return table.concat(lines, "\n")
end

function HistorySessionModel:BuildRowTitleAndSubtitle(session)
    local resolvedSession = self:GetSession(session)
    if not resolvedSession then
        return "Session", nil
    end

    if resolvedSession.recordType == "farm" or resolvedSession.isFarm == true then
        local startedAt = tonumber(resolvedSession.startTime or resolvedSession.savedAt) or 0
        local startText = startedAt > 0 and date("%Y-%m-%d %H:%M", startedAt) or "Unknown start"
        local farmName = resolvedSession.farmName or "Custom farm"
        local completed = math.max(0, tonumber(resolvedSession.farmCompletedSteps) or 0)
        local total = math.max(0, tonumber(resolvedSession.farmTotalSteps) or 0)
        local reason = resolvedSession.farmCloseReason or "stopped"
        reason = reason:sub(1, 1):upper() .. reason:sub(2)
        return string.format("[Farm] %s - %s", farmName, startText),
            string.format("%d/%d locations completed | %s", completed, total, reason)
    end


    local locations = self:BuildLocationDetailsRowsForSelection(self.allLocationKey,resolvedSession)
    local primary
    for _, row in ipairs(locations) do
        if not primary or row.totalValue > primary.totalValue or (row.totalValue == primary.totalValue and row.quantity > primary.quantity) then primary=row end
    end
    local savedName = resolvedSession.name
    local automatic = resolvedSession.customName ~= true and (type(savedName) ~= "string" or savedName == "" or savedName:match(" %- %d%d%d%d%-%d%d%-%d%d "))
    local title = automatic and (primary and primary.location or self:ResolveHistoryLocationLabel(resolvedSession)) or savedName
    local started = self:GetReferenceTimestamp(resolvedSession)
    local parts = { started > 0 and date("%Y-%m-%d %H:%M",started) or "Unknown start", resolvedSession.savedBy or "Unknown character" }
    parts[#parts+1] = string.format("%d location%s",#locations,#locations == 1 and "" or "s")
    local highlights = tonumber(resolvedSession.highlightItemCount) or 0
    if highlights > 0 then parts[#parts+1] = highlights .. " highlights" end
    if resolvedSession.resumedFromHistory then parts[#parts+1] = "Resumed" end
    return title or "Session", table.concat(parts,"  |  ")

end

NS.HistorySessionModel = HistorySessionModel
