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
    if type(entry) == "table" and type(entry.locationLabel) == "string" and entry.locationLabel ~= "" then
        return entry.locationLabel
    end

    local source = entry
    if type(source) ~= "table" then
        source = fallbackSession or self.session
    end
    if type(source) ~= "table" then
        return "Unknown"
    end

    local base
    if source.isInstanced == true then
        base = source.instanceName or source.zoneName or source.mapName
    else
        base = source.zoneName or source.mapName
    end
    if type(base) ~= "string" or base == "" then
        base = "Unknown"
    end

    if type(source.expansionName) == "string" and source.expansionName ~= "" then
        return string.format("%s (%s)", base, source.expansionName)
    end

    return base
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
    local source = entry
    if type(source) ~= "table" then
        source = fallbackSession or self.session
    end
    if type(source) ~= "table" then
        return "unknown"
    end

    local isInstanced = source.isInstanced == true
    local base
    if isInstanced then
        base = source.instanceName or source.zoneName or source.mapName
    else
        base = source.zoneName or source.mapName
    end
    if type(base) ~= "string" or base == "" then
        base = self:GetMapPathLeaf(source.mapPath)
    end
    if type(base) ~= "string" or base == "" then
        base = self:ResolveHistoryLocationLabel(source, fallbackSession)
    end
    base = self:Trim(type(base) == "string" and base or "")
    if base == "" then
        base = "unknown"
    end

    return string.format(
        "%s:%s",
        isInstanced and "instance" or "zone",
        string.lower(base)
    )
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
            { key = self.allLocationKey, label = "All", firstTimestamp = 0 },
        }
    end

    local options = {
        { key = self.allLocationKey, label = "All", firstTimestamp = 0 },
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

function HistorySessionModel:GetDurationSeconds(session)
    local resolvedSession = self:GetSession(session)
    if not resolvedSession then
        return 0
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

function HistorySessionModel:BuildLocationDetailsRowsForSelection(selectedLocationKey, session)
    local resolvedSession = self:GetSession(session)
    if not resolvedSession then
        return {}
    end

    local selectedKey = selectedLocationKey or self.allLocationKey
    local locations = {}
    local byKey = {}
    local highlightThreshold = 0
    if type(self.addon) == "table" and type(self.addon.GetHighlightThreshold) == "function" then
        highlightThreshold = math.max(0, math.floor((tonumber(self.addon:GetHighlightThreshold()) or 0) + 0.5))
    end

    local function FormatTimeRangeParts(startTime, stopTime)
        local normalizedStart = tonumber(startTime) or 0
        local normalizedStop = tonumber(stopTime) or 0

        if normalizedStart <= 0 and normalizedStop <= 0 then
            return "Unknown", ""
        end
        if normalizedStart <= 0 then
            normalizedStart = normalizedStop
        end
        if normalizedStop <= 0 then
            normalizedStop = normalizedStart
        end
        if normalizedStop < normalizedStart then
            normalizedStop = normalizedStart
        end

        local startText = date("%Y-%m-%d %H:%M:%S", normalizedStart)
        local stopText = date("%Y-%m-%d %H:%M:%S", normalizedStop)
        if normalizedStart == normalizedStop then
            return startText, stopText
        end

        return startText, stopText
    end

    local function Add(entry, fallbackTimestamp, fallbackStopTimestamp, highlightIncrement)
        if not self:EntryMatchesLocation(entry, selectedKey, resolvedSession) then
            return
        end

        local key = "loc:" .. self:ResolveHistoryLocationIdentity(entry, resolvedSession)
        local existing = byKey[key]
        local timestamp = tonumber(entry and entry.timestamp) or tonumber(fallbackTimestamp) or 0
        local stopTimestamp = tonumber(entry and entry.timestamp) or tonumber(fallbackStopTimestamp) or timestamp
        if stopTimestamp < timestamp then
            stopTimestamp = timestamp
        end
        local path = self:ResolveHistoryLocationPath(entry, resolvedSession)
        local increment = tonumber(highlightIncrement) or 0
        if increment <= 0 then
            local entryTotalValue = tonumber(entry and entry.totalValue) or 0
            if highlightThreshold > 0 and entryTotalValue >= highlightThreshold then
                increment = 1
            end
        end
        increment = math.max(0, math.floor(increment + 0.5))
        if existing then
            if timestamp > 0 and (existing.firstTimestamp <= 0 or timestamp < existing.firstTimestamp) then
                existing.firstTimestamp = timestamp
            end
            if stopTimestamp > 0 and stopTimestamp > (existing.lastTimestamp or 0) then
                existing.lastTimestamp = stopTimestamp
            end
            existing.highlightCount = (tonumber(existing.highlightCount) or 0) + increment
            local existingSegments = 0
            local newSegments = 0
            for _ in tostring(existing.path or ""):gmatch("[^>]+") do
                existingSegments = existingSegments + 1
            end
            for _ in tostring(path or ""):gmatch("[^>]+") do
                newSegments = newSegments + 1
            end
            if newSegments > existingSegments or (newSegments == existingSegments and #(path or "") > #(existing.path or "")) then
                existing.path = path
            end
            return
        end

        local location = {
            key = key,
            path = path,
            firstTimestamp = timestamp,
            lastTimestamp = stopTimestamp,
            highlightCount = increment,
        }
        byKey[key] = location
        locations[#locations + 1] = location
    end

    local sessionStart = tonumber(resolvedSession.startTime) or 0
    local sessionStop = tonumber(resolvedSession.stopTime or resolvedSession.savedAt) or sessionStart
    for _, loot in ipairs(resolvedSession.itemLoots or {}) do
        Add(loot, sessionStart, sessionStop)
    end
    for _, money in ipairs(resolvedSession.moneyLoots or {}) do
        Add(money, sessionStart, sessionStop)
    end

    if #locations == 0 then
        Add(resolvedSession, sessionStart, sessionStop, tonumber(resolvedSession.highlightItemCount) or 0)
    end

    table.sort(locations, function(a, b)
        local aTs = tonumber(a and a.firstTimestamp) or 0
        local bTs = tonumber(b and b.firstTimestamp) or 0
        if aTs > 0 and bTs > 0 and aTs ~= bTs then
            return aTs < bTs
        end
        local aStop = tonumber(a and a.lastTimestamp) or 0
        local bStop = tonumber(b and b.lastTimestamp) or 0
        if aStop > 0 and bStop > 0 and aStop ~= bStop then
            return aStop < bStop
        end
        return tostring(a and a.path or "") < tostring(b and b.path or "")
    end)

    if #locations == 0 then
        return {}
    end

    local rows = {}
    for _, location in ipairs(locations) do
        local startTimestamp = tonumber(location.firstTimestamp) or 0
        local stopTimestamp = tonumber(location.lastTimestamp) or 0
        if startTimestamp <= 0 then
            startTimestamp = stopTimestamp
        end
        if stopTimestamp <= 0 then
            stopTimestamp = startTimestamp
        end
        if stopTimestamp < startTimestamp then
            stopTimestamp = startTimestamp
        end

        local durationSeconds = 0
        if startTimestamp > 0 and stopTimestamp >= startTimestamp then
            durationSeconds = stopTimestamp - startTimestamp
        end

        local timeFrameStartText, timeFrameEndText = FormatTimeRangeParts(startTimestamp, stopTimestamp)
        local timeFrameText = timeFrameStartText
        if timeFrameEndText and timeFrameEndText ~= "" then
            timeFrameText = string.format("%s\n%s", timeFrameStartText, timeFrameEndText)
        end

        rows[#rows + 1] = {
            key = location.key,
            location = location.path or "Unknown",
            timeFrame = timeFrameText,
            timeFrameStart = timeFrameStartText,
            timeFrameEnd = timeFrameEndText,
            highlights = math.max(0, math.floor((tonumber(location.highlightCount) or 0) + 0.5)),
            duration = self:FormatDurationMinutesLabel(durationSeconds),
            durationSeconds = durationSeconds,
            firstTimestamp = startTimestamp,
            lastTimestamp = stopTimestamp,
        }
    end

    return rows
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

    local locationOptions = self:BuildHistoryLocationOptions(resolvedSession)
    local locationLabels = {}
    local labelsByKey = {}
    for _, option in ipairs(locationOptions) do
        if option.key ~= self.allLocationKey then
            locationLabels[#locationLabels + 1] = option
            labelsByKey[option.key] = option.label
        end
    end

    local primaryKey = "loc:" .. self:ResolveHistoryLocationIdentity(resolvedSession, resolvedSession)
    local primaryLocation = labelsByKey[primaryKey] or self:ResolveHistoryLocationLabel(resolvedSession, resolvedSession)
    if (type(primaryLocation) ~= "string" or primaryLocation == "") and locationLabels[1] then
        primaryLocation = locationLabels[1].label
    end
    if type(primaryLocation) ~= "string" or primaryLocation == "" then
        primaryLocation = "Session"
    end

    local startTimestamp = tonumber(resolvedSession.startTime) or 0
    if startTimestamp <= 0 then
        local boundedStartTimestamp, _, firstEventTimestamp = self:GetEventTimeBounds(resolvedSession)
        startTimestamp = tonumber(boundedStartTimestamp) or 0
        if startTimestamp <= 0 then
            startTimestamp = tonumber(firstEventTimestamp) or 0
        end
    end
    if startTimestamp <= 0 then
        startTimestamp = tonumber(resolvedSession.savedAt or resolvedSession.stopTime) or 0
    end

    local startText = (startTimestamp > 0) and date("%Y-%m-%d %H:%M", startTimestamp) or "Unknown start"
    local titleText = string.format("%s - %s", primaryLocation, startText)

    local subtitleText = nil
    if #locationLabels > 0 then
        local others = {}
        for _, option in ipairs(locationLabels) do
            if option.key ~= primaryKey and option.label and option.label ~= "" then
                others[#others + 1] = option.label
            end
        end
        if #others > 0 then
            subtitleText = string.format("Also: %s", table.concat(others, ", "))
        end
    end

    return titleText, subtitleText
end

NS.HistorySessionModel = HistorySessionModel
