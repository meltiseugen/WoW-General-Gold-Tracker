local _, NS = ...
local GoldTracker = NS.GoldTracker

local RENAME_DIALOG_KEY = "GOLDTRACKER_RENAME_HISTORY_SESSION"
local SPLIT_DIALOG_KEY = "GOLDTRACKER_SPLIT_HISTORY_SESSION"
local ROW_HEIGHT = 40
local ROW_SPACING = 44
local DETAILS_LOCATION_FILTER_ALL = "__all__"
local HISTORY_DATE_FILTER_ALL = "__all_time__"
local HISTORY_DATE_FILTER_TODAY = "__today__"
local HISTORY_DATE_FILTER_YESTERDAY = "__yesterday__"
local HISTORY_DATE_FILTER_LAST_7_DAYS = "__last_7_days__"
local HISTORY_DATE_FILTER_THIS_MONTH = "__this_month__"
local HISTORY_DATE_FILTER_OPTIONS = {
    { key = HISTORY_DATE_FILTER_ALL, label = "All time" },
    { key = HISTORY_DATE_FILTER_TODAY, label = "Today" },
    { key = HISTORY_DATE_FILTER_YESTERDAY, label = "Yesterday" },
    { key = HISTORY_DATE_FILTER_LAST_7_DAYS, label = "Last 7 days" },
    { key = HISTORY_DATE_FILTER_THIS_MONTH, label = "This month" },
}

local function GetSessionEventTimeBounds(session)
    if type(session) ~= "table" then
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

    for _, loot in ipairs(session.itemLoots or {}) do
        ConsiderTimestamp(loot and loot.timestamp)
    end
    for _, money in ipairs(session.moneyLoots or {}) do
        ConsiderTimestamp(money and money.timestamp)
    end

    local startTimestamp = tonumber(session.startTime) or 0
    local stopTimestamp = tonumber(session.stopTime or session.savedAt) or 0

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

local function GetSessionReferenceTimestamp(session)
    local startTimestamp = GetSessionEventTimeBounds(session)
    return tonumber(startTimestamp) or 0
end

local function GetSessionDurationSeconds(session)
    if type(session) ~= "table" then
        return 0
    end

    local explicitDuration = math.max(0, math.floor((tonumber(session.duration) or 0) + 0.5))
    local startTimestamp, stopTimestamp, firstEventTimestamp, lastEventTimestamp = GetSessionEventTimeBounds(session)
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

local function FormatDurationMinutesLabel(durationSeconds)
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

local function GetDayStartWithOffset(referenceTimestamp, dayOffset)
    local parts = date("*t", tonumber(referenceTimestamp) or time())
    if type(parts) ~= "table" then
        return 0
    end

    parts.day = (parts.day or 1) + (tonumber(dayOffset) or 0)
    parts.hour = 0
    parts.min = 0
    parts.sec = 0

    return tonumber(time(parts)) or 0
end

local function SessionMatchesDateFilter(session, filterKey)
    if filterKey == nil or filterKey == "" or filterKey == HISTORY_DATE_FILTER_ALL then
        return true
    end

    local sessionTimestamp = GetSessionReferenceTimestamp(session)
    if sessionTimestamp <= 0 then
        return false
    end

    local now = time()
    local todayStart = GetDayStartWithOffset(now, 0)
    local tomorrowStart = GetDayStartWithOffset(now, 1)

    if filterKey == HISTORY_DATE_FILTER_TODAY then
        return sessionTimestamp >= todayStart and sessionTimestamp < tomorrowStart
    end

    if filterKey == HISTORY_DATE_FILTER_YESTERDAY then
        local yesterdayStart = GetDayStartWithOffset(now, -1)
        return sessionTimestamp >= yesterdayStart and sessionTimestamp < todayStart
    end

    if filterKey == HISTORY_DATE_FILTER_LAST_7_DAYS then
        local sevenDaysStart = GetDayStartWithOffset(now, -6)
        return sessionTimestamp >= sevenDaysStart and sessionTimestamp < tomorrowStart
    end

    if filterKey == HISTORY_DATE_FILTER_THIS_MONTH then
        local nowParts = date("*t", now)
        local sessionParts = date("*t", sessionTimestamp)
        if type(nowParts) ~= "table" or type(sessionParts) ~= "table" then
            return false
        end
        return (nowParts.year == sessionParts.year) and (nowParts.month == sessionParts.month)
    end

    return true
end

local function GetDialogEditBox(dialog)
    if not dialog then
        return nil
    end
    if dialog.GetEditBox and type(dialog.GetEditBox) == "function" then
        return dialog:GetEditBox()
    end
    return dialog.editBox or dialog.EditBox
end

local function EnsureRenameDialogRegistered()
    if StaticPopupDialogs[RENAME_DIALOG_KEY] then
        return
    end

    StaticPopupDialogs[RENAME_DIALOG_KEY] = {
        text = "Rename session",
        button1 = ACCEPT,
        button2 = CANCEL,
        hasEditBox = true,
        maxLetters = 120,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
        preferredIndex = 3,
        OnShow = function(dialog)
            local editBox = GetDialogEditBox(dialog)
            if not editBox then
                return
            end
            local session = GoldTracker:GetHistorySessionByID(dialog.data)
            if session then
                editBox:SetText(session.name or "")
                editBox:HighlightText()
            else
                editBox:SetText("")
            end
        end,
        OnAccept = function(dialog)
            local editBox = GetDialogEditBox(dialog)
            if not editBox then
                return
            end
            GoldTracker:RenameHistorySession(dialog.data, editBox:GetText())
        end,
        EditBoxOnEnterPressed = function(editBox)
            local dialog = editBox:GetParent()
            if dialog and dialog.button1 then
                dialog.button1:Click()
            end
        end,
        EditBoxOnEscapePressed = function(editBox)
            editBox:GetParent():Hide()
        end,
    }
end

local function FormatSessionSummary(addon, session)
    local highlightCount = tonumber(session.highlightItemCount)
    if not highlightCount then
        highlightCount = (tonumber(session.lowHighlightItemCount) or 0) + (tonumber(session.highHighlightItemCount) or 0)
    end
    return tostring(math.max(0, math.floor((highlightCount or 0) + 0.5)))
end

local function FormatSessionTotal(addon, session)
    local text = addon:FormatMoney(tonumber(session.totalValue) or 0)
    text = text:gsub("^[%s\194\160]+", "")
    return text
end

local function FormatSessionTotalRaw(addon, session)
    local rawGold = tonumber(session.rawGold) or 0
    local itemsRawGold = tonumber(session.itemsRawGold) or 0
    local text = addon:FormatMoney(rawGold + itemsRawGold)
    text = text:gsub("^[%s\194\160]+", "")
    return text
end

local function NormalizeDisplayedMapPath(addon, mapPath)
    if type(mapPath) ~= "string" then
        return nil
    end

    local trimmedPath = addon:Trim(mapPath)
    if trimmedPath == "" then
        return nil
    end

    local segments = {}
    for rawSegment in trimmedPath:gmatch("[^>]+") do
        local segment = addon:Trim(rawSegment)
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

local function BuildLocationDetailsText(session)
    local parts = {}
    local displayPath = NormalizeDisplayedMapPath(GoldTracker, session.mapPath)

    if type(displayPath) == "string" and displayPath ~= "" then
        parts[#parts + 1] = string.format("Location: %s", displayPath)
    elseif type(session.mapName) == "string" and session.mapName ~= "" then
        parts[#parts + 1] = string.format("Location: %s", session.mapName)
    end

    if type(session.expansionName) == "string" and session.expansionName ~= "" then
        parts[#parts + 1] = string.format("Expansion: %s", session.expansionName)
    end

    if #parts == 0 then
        return ""
    end

    return table.concat(parts, "   ")
end

local function FormatHistoryTimeFrame(startTime, stopTime)
    local normalizedStart = tonumber(startTime) or 0
    local normalizedStop = tonumber(stopTime) or 0

    if normalizedStart <= 0 and normalizedStop <= 0 then
        return ""
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

    if normalizedStart == normalizedStop then
        return date("%Y-%m-%d %H:%M:%S", normalizedStart)
    end

    return string.format(
        "%s -> %s",
        date("%Y-%m-%d %H:%M:%S", normalizedStart),
        date("%Y-%m-%d %H:%M:%S", normalizedStop)
    )
end

local function TruncateSessionNameKeepingDate(addon, fullName, nameFontString)
    if type(fullName) ~= "string" or fullName == "" then
        return "Session"
    end
    if not nameFontString or type(nameFontString.GetStringWidth) ~= "function" then
        return fullName
    end

    local maxWidth = tonumber(nameFontString:GetWidth()) or 0
    if maxWidth <= 0 then
        return fullName
    end

    nameFontString:SetText(fullName)
    if (nameFontString:GetStringWidth() or 0) <= maxWidth then
        return fullName
    end

    local prefix, datetimeSuffix = fullName:match("^(.*)( %- %d%d%d%d%-%d%d%-%d%d %d%d:%d%d:%d%d %- .+)$")
    if not prefix or not datetimeSuffix then
        prefix, datetimeSuffix = fullName:match("^(.*)( %- %d%d%d%d%-%d%d%-%d%d %d%d:%d%d:%d%d %-%> %d%d%d%d%-%d%d%-%d%d %d%d:%d%d:%d%d)$")
    end
    if not prefix or not datetimeSuffix then
        prefix, datetimeSuffix = fullName:match("^(.*)( %- %d%d%d%d%-%d%d%-%d%d %d%d:%d%d:%d%d)$")
    end
    local ellipsis = "..."

    if prefix and datetimeSuffix then
        local trimmedPrefix = addon:Trim(prefix)
        while #trimmedPrefix > 0 do
            local candidate = string.format("%s%s%s", trimmedPrefix, ellipsis, datetimeSuffix)
            nameFontString:SetText(candidate)
            if (nameFontString:GetStringWidth() or 0) <= maxWidth then
                return candidate
            end
            trimmedPrefix = trimmedPrefix:sub(1, #trimmedPrefix - 1)
        end

        local compactCandidate = ellipsis .. datetimeSuffix
        nameFontString:SetText(compactCandidate)
        if (nameFontString:GetStringWidth() or 0) <= maxWidth then
            return compactCandidate
        end
    end

    local trimmed = fullName
    while #trimmed > 0 do
        local candidate = trimmed .. ellipsis
        nameFontString:SetText(candidate)
        if (nameFontString:GetStringWidth() or 0) <= maxWidth then
            return candidate
        end
        trimmed = trimmed:sub(1, #trimmed - 1)
    end

    return fullName
end

local function SessionHasMultipleValueSources(session)
    local labelsSeen = {}
    local count = 0

    local function Add(label)
        if type(label) ~= "string" or label == "" or labelsSeen[label] then
            return
        end
        labelsSeen[label] = true
        count = count + 1
    end

    for _, label in ipairs(session.valueSourceLabels or {}) do
        Add(label)
        if count > 1 then
            return true
        end
    end

    if type(session.itemLoots) == "table" then
        for _, entry in ipairs(session.itemLoots) do
            Add(entry and entry.valueSourceLabel)
            if count > 1 then
                return true
            end
        end
    end

    Add(session.valueSourceLabel)
    return count > 1
end

local function EnsureSplitDialogRegistered()
    if StaticPopupDialogs[SPLIT_DIALOG_KEY] then
        return
    end

    StaticPopupDialogs[SPLIT_DIALOG_KEY] = {
        text = "Split this session into separate rows per location?\nThis action cannot be undone.",
        button1 = ACCEPT,
        button2 = CANCEL,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
        preferredIndex = 3,
        OnAccept = function(dialog)
            local splitEntries, reason = GoldTracker:SplitHistorySessionByLocation(dialog.data)
            if splitEntries and #splitEntries > 0 then
                GoldTracker:Print(string.format("Split session into %d location rows.", #splitEntries))
            elseif reason == "single-location" then
                GoldTracker:Print("Session has only one location; nothing to split.")
            else
                GoldTracker:Print("Unable to split this session.")
            end
        end,
    }
end

local function ResolveHistoryLocationKey(entry, fallbackSession)
    if type(entry) == "table" and type(entry.locationKey) == "string" and entry.locationKey ~= "" then
        return entry.locationKey
    end

    local source = entry
    if type(source) ~= "table" then
        source = fallbackSession
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

local function ResolveHistoryLocationLabel(entry, fallbackSession)
    if type(entry) == "table" and type(entry.locationLabel) == "string" and entry.locationLabel ~= "" then
        return entry.locationLabel
    end

    local source = entry
    if type(source) ~= "table" then
        source = fallbackSession
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

local function EntryMatchesHistoryLocation(entry, selectedLocationKey, fallbackSession)
    if type(selectedLocationKey) ~= "string" or selectedLocationKey == "" or selectedLocationKey == DETAILS_LOCATION_FILTER_ALL then
        return true
    end

    return ResolveHistoryLocationKey(entry, fallbackSession) == selectedLocationKey
end

local function BuildHistoryLocationOptions(session)
    local options = {
        { key = DETAILS_LOCATION_FILTER_ALL, label = "All", firstTimestamp = 0 },
    }
    local byKey = {}

    local function AddLocation(entry, fallbackTimestamp)
        local key = ResolveHistoryLocationKey(entry, session)
        local label = ResolveHistoryLocationLabel(entry, session)
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

    if type(session.itemLoots) == "table" then
        for _, entry in ipairs(session.itemLoots) do
            AddLocation(entry, session.startTime)
        end
    end
    if type(session.moneyLoots) == "table" then
        for _, entry in ipairs(session.moneyLoots) do
            AddLocation(entry, session.startTime)
        end
    end

    if #options == 1 then
        AddLocation(session, session.startTime)
    end

    table.sort(options, function(a, b)
        local aAll = a.key == DETAILS_LOCATION_FILTER_ALL
        local bAll = b.key == DETAILS_LOCATION_FILTER_ALL
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

local function ResolveHistoryLocationPath(entry, fallbackSession)
    local source = entry
    if type(source) ~= "table" then
        source = fallbackSession
    end
    if type(source) ~= "table" then
        return "Unknown"
    end

    local displayPath = NormalizeDisplayedMapPath(GoldTracker, source.mapPath)
    if type(displayPath) == "string" and displayPath ~= "" then
        return displayPath
    end
    if type(source.mapName) == "string" and source.mapName ~= "" then
        return source.mapName
    end

    return ResolveHistoryLocationLabel(source, fallbackSession)
end

local function BuildLocationDetailsTextForSelection(session, selectedLocationKey)
    local selectedKey = selectedLocationKey or DETAILS_LOCATION_FILTER_ALL
    local locations = {}
    local byKey = {}

    local function Add(entry, fallbackTimestamp)
        if not EntryMatchesHistoryLocation(entry, selectedKey, session) then
            return
        end

        local key = ResolveHistoryLocationKey(entry, session)
        local existing = byKey[key]
        local timestamp = tonumber(entry and entry.timestamp) or tonumber(fallbackTimestamp) or 0
        if existing then
            if timestamp > 0 and (existing.firstTimestamp <= 0 or timestamp < existing.firstTimestamp) then
                existing.firstTimestamp = timestamp
            end
            return
        end

        local location = {
            key = key,
            path = ResolveHistoryLocationPath(entry, session),
            firstTimestamp = timestamp,
        }
        byKey[key] = location
        locations[#locations + 1] = location
    end

    for _, loot in ipairs(session.itemLoots or {}) do
        Add(loot, session.startTime)
    end
    for _, money in ipairs(session.moneyLoots or {}) do
        Add(money, session.startTime)
    end
    if selectedKey == DETAILS_LOCATION_FILTER_ALL then
        Add(session, session.startTime)
    elseif #locations == 0 then
        Add(session, session.startTime)
    end

    table.sort(locations, function(a, b)
        local aTs = tonumber(a and a.firstTimestamp) or 0
        local bTs = tonumber(b and b.firstTimestamp) or 0
        if aTs > 0 and bTs > 0 and aTs ~= bTs then
            return aTs < bTs
        end
        return tostring(a and a.path or "") < tostring(b and b.path or "")
    end)

    if selectedKey == DETAILS_LOCATION_FILTER_ALL and #locations > 1 then
        local sessionPrimaryKey = ResolveHistoryLocationKey(session, session)
        local sessionPrimary = byKey[sessionPrimaryKey]
        if sessionPrimary then
            local ordered = { sessionPrimary }
            for _, location in ipairs(locations) do
                if location.key ~= sessionPrimaryKey then
                    ordered[#ordered + 1] = location
                end
            end
            locations = ordered
        end
    end

    if #locations == 0 then
        return BuildLocationDetailsText(session)
    end

    local primary = locations[1].path or "Unknown"
    local detailsText = string.format("Location: %s", primary)
    if #locations > 1 then
        local others = {}
        for index = 2, #locations do
            others[#others + 1] = locations[index].path or "Unknown"
        end
        detailsText = string.format("%s   Also: %s", detailsText, table.concat(others, " | "))
    end

    return detailsText
end

local function BuildHistoryRowTitleAndSubtitle(session)
    local locationOptions = BuildHistoryLocationOptions(session)
    local locationLabels = {}
    local labelsByKey = {}
    for _, option in ipairs(locationOptions) do
        if option.key ~= DETAILS_LOCATION_FILTER_ALL then
            locationLabels[#locationLabels + 1] = option
            labelsByKey[option.key] = option.label
        end
    end

    local primaryKey = ResolveHistoryLocationKey(session, session)
    local primaryLocation = labelsByKey[primaryKey] or ResolveHistoryLocationLabel(session, session)
    if (type(primaryLocation) ~= "string" or primaryLocation == "") and locationLabels[1] then
        primaryLocation = locationLabels[1].label
    end
    if type(primaryLocation) ~= "string" or primaryLocation == "" then
        primaryLocation = "Session"
    end

    local startTimestamp = GetSessionReferenceTimestamp(session)
    local startText = (startTimestamp > 0) and date("%Y-%m-%d %H:%M:%S", startTimestamp) or "Unknown start"
    local durationText = FormatDurationMinutesLabel(GetSessionDurationSeconds(session))
    local titleText = string.format("%s - %s - %s", primaryLocation, startText, durationText)

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

local function BuildHistoryDetailsSummary(session, selectedLocationKey)
    local summary = {
        rawGold = 0,
        itemsValue = 0,
        itemsRawGold = 0,
        totalValue = 0,
        duration = 0,
        startTime = 0,
        stopTime = 0,
    }

    local firstTimestamp
    local lastTimestamp
    local fallbackSessionLocationKey = ResolveHistoryLocationKey(session, session)
    local function ConsiderTimestamp(timestamp)
        local normalized = tonumber(timestamp)
        if not normalized or normalized <= 0 then
            return
        end
        if not firstTimestamp or normalized < firstTimestamp then
            firstTimestamp = normalized
        end
        if not lastTimestamp or normalized > lastTimestamp then
            lastTimestamp = normalized
        end
    end

    local hasMoneyDetails = type(session.moneyLoots) == "table" and #session.moneyLoots > 0
    if hasMoneyDetails then
        for _, money in ipairs(session.moneyLoots) do
            if EntryMatchesHistoryLocation(money, selectedLocationKey, session) then
                summary.rawGold = summary.rawGold + (tonumber(money.amount) or 0)
                ConsiderTimestamp(money.timestamp)
            end
        end
    elseif selectedLocationKey == DETAILS_LOCATION_FILTER_ALL or selectedLocationKey == fallbackSessionLocationKey then
        summary.rawGold = tonumber(session.rawGold) or 0
    end

    local hasItemDetails = type(session.itemLoots) == "table" and #session.itemLoots > 0
    if hasItemDetails then
        for _, loot in ipairs(session.itemLoots) do
            if EntryMatchesHistoryLocation(loot, selectedLocationKey, session) then
                summary.itemsValue = summary.itemsValue + (tonumber(loot.totalValue) or 0)
                summary.itemsRawGold = summary.itemsRawGold + (tonumber(loot.vendorTotalValue) or 0)
                ConsiderTimestamp(loot.timestamp)
            end
        end
    elseif selectedLocationKey == DETAILS_LOCATION_FILTER_ALL or selectedLocationKey == fallbackSessionLocationKey then
        summary.itemsValue = tonumber(session.itemsValue) or 0
        summary.itemsRawGold = tonumber(session.itemsRawGold) or 0
    end

    summary.totalValue = summary.rawGold + summary.itemsValue
    if selectedLocationKey == DETAILS_LOCATION_FILTER_ALL or (not hasItemDetails and not hasMoneyDetails and selectedLocationKey == fallbackSessionLocationKey) then
        local sessionStart, sessionStop = GetSessionEventTimeBounds(session)
        summary.startTime = sessionStart
        summary.stopTime = sessionStop
        summary.duration = GetSessionDurationSeconds(session)
    elseif firstTimestamp and lastTimestamp then
        summary.duration = math.max(0, lastTimestamp - firstTimestamp)
        summary.startTime = firstTimestamp
        summary.stopTime = lastTimestamp
    else
        local fallbackTs = GetSessionReferenceTimestamp(session)
        summary.startTime = fallbackTs
        summary.stopTime = fallbackTs
        summary.duration = 0
    end

    if summary.stopTime > 0 and summary.startTime > 0 and summary.stopTime < summary.startTime then
        summary.stopTime = summary.startTime
    end

    return summary
end

local function BuildVisibleHistoryItems(session, selectedLocationKey)
    local byLink = {}
    local hasDetailedLoot = type(session.itemLoots) == "table" and #session.itemLoots > 0
    local includeSourceLabel = SessionHasMultipleValueSources(session)
    local fallbackSourceLabel = session.valueSourceLabel or "Unknown"
    local minimumTrackedQuality = GoldTracker:GetConfiguredMinimumTrackedItemQuality()

    local function PassesQualityFilter(itemQuality, itemLink)
        local quality = tonumber(itemQuality)
        if quality then
            quality = math.floor(quality + 0.5)
        else
            quality = GoldTracker:GetItemQualityFromLink(itemLink)
        end

        if type(quality) ~= "number" then
            return true
        end

        return quality >= minimumTrackedQuality
    end

    if hasDetailedLoot then
        for _, entry in ipairs(session.itemLoots) do
            if entry
                and EntryMatchesHistoryLocation(entry, selectedLocationKey, session)
                and entry.ahTracked == true
                and entry.isSoulbound ~= true
                and PassesQualityFilter(entry.itemQuality, entry.itemLink) then
                local sourceLabel = entry.valueSourceLabel or fallbackSourceLabel
                local lootSourceText = nil
                if type(entry.lootSourceText) == "string" and entry.lootSourceText ~= "" then
                    lootSourceText = entry.lootSourceText
                elseif entry.lootSourceType == "AOE" or entry.lootSourceIsAoe == true then
                    lootSourceText = "AOE loot"
                end
                local key = entry.itemLink or "unknown"
                if includeSourceLabel then
                    key = string.format("%s\001%s", key, sourceLabel)
                end
                if lootSourceText then
                    key = string.format("%s\001%s", key, lootSourceText)
                end
                local item = byLink[key]
                if not item then
                    item = {
                        itemLink = entry.itemLink,
                        quantity = 0,
                        totalValue = 0,
                        valueSourceLabel = sourceLabel,
                        itemQuality = tonumber(entry.itemQuality),
                        lootSourceText = lootSourceText,
                    }
                    byLink[key] = item
                end

                item.quantity = item.quantity + (tonumber(entry.quantity) or 0)
                item.totalValue = item.totalValue + (tonumber(entry.totalValue) or 0)
                if item.itemQuality == nil then
                    item.itemQuality = tonumber(entry.itemQuality)
                end
                if not item.lootSourceText and lootSourceText then
                    item.lootSourceText = lootSourceText
                end
            end
        end

        local items = {}
        for _, item in pairs(byLink) do
            items[#items + 1] = item
        end

        table.sort(items, function(a, b)
            return (a.totalValue or 0) > (b.totalValue or 0)
        end)

        return items, includeSourceLabel
    end

    local fallbackSessionLocationKey = ResolveHistoryLocationKey(session, session)
    if selectedLocationKey ~= DETAILS_LOCATION_FILTER_ALL and selectedLocationKey ~= fallbackSessionLocationKey then
        return {}, includeSourceLabel
    end

    local fallbackItems = {}
    for _, item in ipairs(session.items or {}) do
        if item and item.isSoulbound ~= true and PassesQualityFilter(item.itemQuality, item.itemLink) then
            fallbackItems[#fallbackItems + 1] = {
                itemLink = item.itemLink,
                quantity = tonumber(item.quantity) or 0,
                totalValue = tonumber(item.totalValue) or 0,
                valueSourceLabel = fallbackSourceLabel,
                itemQuality = tonumber(item.itemQuality),
            }
        end
    end

    table.sort(fallbackItems, function(a, b)
        return (a.totalValue or 0) > (b.totalValue or 0)
    end)

    return fallbackItems, includeSourceLabel
end

local function CompareHistorySessionsByRecency(a, b)
    local aSaved = tonumber(a and (a.savedAt or a.stopTime)) or 0
    local bSaved = tonumber(b and (b.savedAt or b.stopTime)) or 0
    if aSaved ~= bSaved then
        return aSaved > bSaved
    end
    return (tonumber(a and a.id) or 0) > (tonumber(b and b.id) or 0)
end

local function GetHistorySortValue(session, sortKey)
    if sortKey == "sessionTotal" then
        return tonumber(session and session.totalValue) or 0
    end
    if sortKey == "sessionTotalRaw" then
        local rawGold = tonumber(session and session.rawGold) or 0
        local itemsRawGold = tonumber(session and session.itemsRawGold) or 0
        return rawGold + itemsRawGold
    end
    return tonumber(session and (session.savedAt or session.stopTime)) or 0
end

function GoldTracker:PromptRenameHistorySession(sessionID)
    EnsureRenameDialogRegistered()
    StaticPopup_Show(RENAME_DIALOG_KEY, nil, nil, sessionID)
end

function GoldTracker:PromptSplitHistorySession(sessionID)
    local session = self:GetHistorySessionByID(sessionID)
    if not session then
        return
    end

    local locationOptions = BuildHistoryLocationOptions(session)
    if #locationOptions <= 2 then
        self:Print("Session has only one location; nothing to split.")
        return
    end

    EnsureSplitDialogRegistered()
    StaticPopup_Show(SPLIT_DIALOG_KEY, nil, nil, sessionID)
end

function GoldTracker:HandleHistoryPageMouseWheel(delta)
    if not self.historyFrame or self.historyFrame.view ~= "list" then
        return
    end

    local currentPage = self.historyFrame.currentPage or 1
    if delta > 0 then
        self:SetHistoryPage(currentPage - 1)
    elseif delta < 0 then
        self:SetHistoryPage(currentPage + 1)
    end
end

function GoldTracker:CreateHistoryWindow()
    if self.historyFrame then
        return
    end

    local addon = self
    local frame = CreateFrame("Frame", "GoldTrackerHistoryFrame", UIParent, "BasicFrameTemplateWithInset")
    frame:SetSize(900, 500)
    frame:SetPoint("CENTER")
    frame:SetFrameStrata("DIALOG")
    if frame.SetToplevel then
        frame:SetToplevel(true)
    end
    frame:SetMovable(true)
    frame:SetClampedToScreen(true)
    frame:EnableMouse(true)
    frame:EnableMouseWheel(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnMouseDown", function(self)
        self:Raise()
    end)
    frame:SetScript("OnDragStart", function(self)
        self:Raise()
        self:StartMoving()
    end)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
    frame:SetScript("OnMouseWheel", function(_, delta)
        if frame.view == "list" then
            addon:HandleHistoryPageMouseWheel(delta)
        end
    end)
    frame:Hide()

    if frame.TitleText then
        frame.TitleText:SetText("Gold Tracker - Session History")
    end
    if frame.CloseButton then
        frame.CloseButton:SetFrameLevel(frame:GetFrameLevel() + 20)
        frame.CloseButton:SetScript("OnClick", function()
            frame:Hide()
        end)
    end
    if type(UISpecialFrames) == "table" then
        local alreadyRegistered = false
        for _, frameName in ipairs(UISpecialFrames) do
            if frameName == "GoldTrackerHistoryFrame" then
                alreadyRegistered = true
                break
            end
        end
        if not alreadyRegistered then
            table.insert(UISpecialFrames, "GoldTrackerHistoryFrame")
        end
    end

    local backButton = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    backButton:SetSize(80, 22)
    backButton:SetPoint("TOPLEFT", frame, "TOPLEFT", 18, -34)
    backButton:SetText("Back")
    backButton:SetScript("OnClick", function()
        addon:ShowHistoryListView()
    end)
    backButton:Hide()
    frame.backButton = backButton

    local listContainer = CreateFrame("Frame", nil, frame)
    listContainer:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, -24)
    listContainer:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 0, 0)
    listContainer:EnableMouseWheel(true)
    listContainer:SetScript("OnMouseWheel", function(_, delta)
        addon:HandleHistoryPageMouseWheel(delta)
    end)
    frame.listContainer = listContainer
    frame.selectedSessionIDs = {}
    frame.currentPage = 1
    frame.sortKey = frame.sortKey or nil
    frame.sortAscending = frame.sortAscending == true
    frame.historyDateFilterKey = frame.historyDateFilterKey or HISTORY_DATE_FILTER_ALL

    local mergeButton = CreateFrame("Button", nil, listContainer, "UIPanelButtonTemplate")
    mergeButton:SetSize(120, 22)
    mergeButton:SetPoint("TOPRIGHT", listContainer, "TOPRIGHT", -154, -8)
    mergeButton:SetText("Merge")
    mergeButton:SetScript("OnClick", function()
        local selectedIDs = addon:GetSelectedHistorySessionIDsInOrder()
        if #selectedIDs < 2 then
            return
        end

        local merged = addon:MergeHistorySessions(selectedIDs)
        if merged then
            addon:ClearHistorySelection()
            addon:RefreshHistoryWindow()
            addon:Print(string.format("Merged %d sessions into \"%s\".", #selectedIDs, merged.name or "Session"))
        end
    end)
    mergeButton:Hide()
    frame.mergeButton = mergeButton

    local bulkDeleteButton = CreateFrame("Button", nil, listContainer, "UIPanelButtonTemplate")
    bulkDeleteButton:SetSize(120, 22)
    bulkDeleteButton:SetPoint("LEFT", mergeButton, "RIGHT", 8, 0)
    bulkDeleteButton:SetText("Bulk Delete")
    bulkDeleteButton:SetScript("OnClick", function()
        local selectedIDs = addon:GetSelectedHistorySessionIDsInOrder()
        if #selectedIDs == 0 then
            return
        end

        local removedCount = addon:DeleteHistorySessions(selectedIDs)
        if removedCount > 0 then
            addon:ClearHistorySelection()
            addon:RefreshHistoryWindow()
            addon:Print(string.format("Deleted %d history sessions.", removedCount))
        end
    end)
    bulkDeleteButton:Hide()
    frame.bulkDeleteButton = bulkDeleteButton

    local historyDateFilterLabel = listContainer:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    historyDateFilterLabel:SetPoint("TOPLEFT", listContainer, "TOPLEFT", 24, -14)
    historyDateFilterLabel:SetText("Filter")
    frame.historyDateFilterLabelText = historyDateFilterLabel

    local historyDateFilterDropdown = CreateFrame("Frame", "GoldTrackerHistoryDateFilterDropdown", listContainer, "UIDropDownMenuTemplate")
    historyDateFilterDropdown:SetPoint("LEFT", historyDateFilterLabel, "RIGHT", -6, -2)
    UIDropDownMenu_SetWidth(historyDateFilterDropdown, 150)
    UIDropDownMenu_Initialize(historyDateFilterDropdown, function(_, level)
        for _, option in ipairs(HISTORY_DATE_FILTER_OPTIONS) do
            local info = UIDropDownMenu_CreateInfo()
            local optionKey = option.key
            info.text = option.label
            info.value = optionKey
            info.checked = (frame.historyDateFilterKey or HISTORY_DATE_FILTER_ALL) == optionKey
            info.func = function()
                frame.historyDateFilterKey = optionKey
                frame.currentPage = 1
                addon:ClearHistorySelection()
                addon:RefreshHistoryWindow()
            end
            UIDropDownMenu_AddButton(info, level)
        end
    end)
    frame.historyDateFilterDropdown = historyDateFilterDropdown

    local hint = listContainer:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    hint:SetPoint("TOPLEFT", listContainer, "TOPLEFT", 20, -44)
    hint:SetText("Click a row for details. Use checkboxes for Merge/Bulk Delete, Pin to keep sessions on top, and Filter to limit by date.")
    frame.listHintText = hint

    local header = listContainer:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    header:SetPoint("TOPLEFT", listContainer, "TOPLEFT", 24, -56)
    header:SetText("Session name")
    frame.listHeaderText = header

    local summaryHeader = listContainer:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    summaryHeader:SetPoint("TOPLEFT", listContainer, "TOPLEFT", 340, -56)
    summaryHeader:SetText("Highlights")
    frame.listSummaryHeaderText = summaryHeader

    local totalHeaderButton = CreateFrame("Button", nil, listContainer)
    totalHeaderButton:SetSize(110, 18)
    totalHeaderButton:SetPoint("TOPLEFT", listContainer, "TOPLEFT", 420, -56)
    totalHeaderButton:SetScript("OnClick", function()
        addon:ToggleHistorySort("sessionTotal")
    end)
    local totalHeaderText = totalHeaderButton:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    totalHeaderText:SetPoint("TOPLEFT", totalHeaderButton, "TOPLEFT", 0, 0)
    totalHeaderText:SetWidth(110)
    totalHeaderText:SetJustifyH("LEFT")
    totalHeaderText:SetText("Session Total")
    totalHeaderButton.text = totalHeaderText
    frame.totalHeaderButton = totalHeaderButton

    local totalRawHeaderButton = CreateFrame("Button", nil, listContainer)
    totalRawHeaderButton:SetSize(128, 18)
    totalRawHeaderButton:SetPoint("TOPLEFT", listContainer, "TOPLEFT", 536, -56)
    totalRawHeaderButton:SetScript("OnClick", function()
        addon:ToggleHistorySort("sessionTotalRaw")
    end)
    local totalRawHeaderText = totalRawHeaderButton:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    totalRawHeaderText:SetPoint("TOPLEFT", totalRawHeaderButton, "TOPLEFT", 0, 0)
    totalRawHeaderText:SetWidth(128)
    totalRawHeaderText:SetJustifyH("LEFT")
    totalRawHeaderText:SetText("Raw Session Total")
    totalRawHeaderButton.text = totalRawHeaderText
    frame.totalRawHeaderButton = totalRawHeaderButton

    local dividerColorR, dividerColorG, dividerColorB, dividerColorA = 1, 0.82, 0, 0.60
    local function CreateHeaderDivider(x)
        local divider = listContainer:CreateTexture(nil, "ARTWORK")
        divider:SetColorTexture(dividerColorR, dividerColorG, dividerColorB, dividerColorA)
        divider:SetSize(1, 18)
        divider:SetPoint("TOPLEFT", listContainer, "TOPLEFT", x, -55)
        return divider
    end

    frame.headerDividerNameSummary = CreateHeaderDivider(332)
    frame.headerDividerSummaryTotal = CreateHeaderDivider(414)
    frame.headerDividerTotalRaw = CreateHeaderDivider(530)

    local headerUnderline = listContainer:CreateTexture(nil, "ARTWORK")
    headerUnderline:SetColorTexture(1, 0.82, 0, 0.35)
    headerUnderline:SetPoint("TOPLEFT", listContainer, "TOPLEFT", 24, -72)
    headerUnderline:SetPoint("TOPRIGHT", listContainer, "TOPRIGHT", -42, -72)
    headerUnderline:SetHeight(1)
    frame.headerUnderline = headerUnderline

    local scrollFrame = CreateFrame("ScrollFrame", "GoldTrackerHistoryScrollFrame", listContainer, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", listContainer, "TOPLEFT", 0, -72)
    scrollFrame:SetPoint("BOTTOMRIGHT", listContainer, "BOTTOMRIGHT", -30, 50)
    scrollFrame:EnableMouseWheel(true)
    scrollFrame:SetScript("OnMouseWheel", function(_, delta)
        addon:HandleHistoryPageMouseWheel(delta)
    end)
    frame.scrollFrame = scrollFrame

    local content = CreateFrame("Frame", nil, scrollFrame)
    content:SetSize(1, 1)
    scrollFrame:SetScrollChild(content)
    content:EnableMouseWheel(true)
    content:SetScript("OnMouseWheel", function(_, delta)
        addon:HandleHistoryPageMouseWheel(delta)
    end)
    frame.content = content
    frame.rows = {}

    local emptyText = content:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    emptyText:SetPoint("TOPLEFT", content, "TOPLEFT", 8, -8)
    emptyText:SetText("No saved sessions.")
    frame.emptyText = emptyText

    local pinnedDivider = content:CreateTexture(nil, "ARTWORK")
    pinnedDivider:SetColorTexture(1, 0.82, 0, 0.35)
    pinnedDivider:SetHeight(1)
    pinnedDivider:Hide()
    frame.pinnedDivider = pinnedDivider

    local prevPageButton = CreateFrame("Button", nil, listContainer, "UIPanelButtonTemplate")
    prevPageButton:SetSize(34, 20)
    prevPageButton:SetPoint("BOTTOMLEFT", listContainer, "BOTTOMLEFT", 20, 20)
    prevPageButton:SetText("<")
    prevPageButton:SetScript("OnClick", function()
        addon:SetHistoryPage((frame.currentPage or 1) - 1)
    end)
    frame.prevPageButton = prevPageButton

    local nextPageButton = CreateFrame("Button", nil, listContainer, "UIPanelButtonTemplate")
    nextPageButton:SetSize(34, 20)
    nextPageButton:SetPoint("LEFT", prevPageButton, "RIGHT", 6, 0)
    nextPageButton:SetText(">")
    nextPageButton:SetScript("OnClick", function()
        addon:SetHistoryPage((frame.currentPage or 1) + 1)
    end)
    frame.nextPageButton = nextPageButton

    local pageText = listContainer:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    pageText:SetPoint("LEFT", nextPageButton, "RIGHT", 10, 0)
    pageText:SetJustifyH("LEFT")
    pageText:SetText("Page 1 / 1")
    frame.pageText = pageText

    local detailsContainer = CreateFrame("Frame", nil, frame)
    detailsContainer:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, -24)
    detailsContainer:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 0, 0)
    detailsContainer:Hide()
    frame.detailsContainer = detailsContainer

    local sessionName = detailsContainer:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    sessionName:SetPoint("TOPLEFT", detailsContainer, "TOPLEFT", 20, -62)
    sessionName:SetWidth(850)
    sessionName:SetJustifyH("LEFT")
    frame.sessionNameText = sessionName

    local location = detailsContainer:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    location:SetPoint("TOPLEFT", sessionName, "BOTTOMLEFT", 0, -6)
    location:SetWidth(850)
    location:SetJustifyH("LEFT")
    location:SetText("")
    location:Hide()
    frame.locationText = location

    local timeFrame = detailsContainer:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    timeFrame:SetPoint("TOPLEFT", location, "BOTTOMLEFT", 0, -4)
    timeFrame:SetWidth(850)
    timeFrame:SetJustifyH("LEFT")
    timeFrame:SetText("")
    timeFrame:Hide()
    frame.timeFrameText = timeFrame

    local summary = detailsContainer:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    summary:SetPoint("TOPLEFT", timeFrame, "BOTTOMLEFT", 0, -10)
    summary:SetWidth(850)
    summary:SetJustifyH("LEFT")
    frame.summaryText = summary

    local source = detailsContainer:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    source:SetPoint("TOPLEFT", summary, "BOTTOMLEFT", 0, -6)
    source:SetWidth(850)
    source:SetJustifyH("LEFT")
    frame.sourceText = source

    local locationFilterLabel = detailsContainer:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    locationFilterLabel:SetPoint("TOPLEFT", source, "BOTTOMLEFT", 0, -10)
    locationFilterLabel:SetText("Location")
    frame.locationFilterLabelText = locationFilterLabel

    local locationFilterDropdown = CreateFrame("Frame", "GoldTrackerHistoryLocationFilterDropdown", detailsContainer, "UIDropDownMenuTemplate")
    locationFilterDropdown:SetPoint("TOPLEFT", locationFilterLabel, "BOTTOMLEFT", -16, -2)
    UIDropDownMenu_SetWidth(locationFilterDropdown, 280)
    UIDropDownMenu_Initialize(locationFilterDropdown, function(_, level)
        for _, option in ipairs(frame.detailsLocationOptions or {}) do
            local info = UIDropDownMenu_CreateInfo()
            local optionKey = option.key
            info.text = option.label
            info.value = optionKey
            info.checked = (frame.detailsLocationFilterKey or DETAILS_LOCATION_FILTER_ALL) == optionKey
            info.func = function()
                frame.detailsLocationFilterKey = optionKey
                addon:RefreshHistoryDetailsWindow()
            end
            UIDropDownMenu_AddButton(info, level)
        end
    end)
    frame.locationFilterDropdown = locationFilterDropdown
    frame.detailsLocationOptions = {
        { key = DETAILS_LOCATION_FILTER_ALL, label = "All" },
    }
    frame.detailsLocationFilterKey = DETAILS_LOCATION_FILTER_ALL

    local splitButton = CreateFrame("Button", nil, detailsContainer, "UIPanelButtonTemplate")
    splitButton:SetSize(130, 22)
    splitButton:SetPoint("LEFT", locationFilterDropdown, "RIGHT", 12, 2)
    splitButton:SetText("Split by Location")
    splitButton:SetScript("OnClick", function()
        if frame.selectedSessionID then
            addon:PromptSplitHistorySession(frame.selectedSessionID)
        end
    end)
    splitButton:Hide()
    frame.splitButton = splitButton

    local itemsHeader = detailsContainer:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    itemsHeader:SetPoint("TOPLEFT", locationFilterDropdown, "BOTTOMLEFT", 16, -8)
    itemsHeader:SetText("Items")
    frame.itemsHeaderText = itemsHeader

    local log = CreateFrame("ScrollingMessageFrame", nil, detailsContainer)
    log:SetPoint("TOPLEFT", itemsHeader, "BOTTOMLEFT", 0, -8)
    log:SetPoint("BOTTOMRIGHT", detailsContainer, "BOTTOMRIGHT", -20, 20)
    log:SetFontObject(GameFontHighlightSmall)
    log:SetJustifyH("LEFT")
    log:SetFading(false)
    log:SetMaxLines(5000)
    log:SetIndentedWordWrap(true)
    log:SetHyperlinksEnabled(true)
    log:EnableMouseWheel(true)
    log:SetScript("OnMouseWheel", function(self, delta)
        if delta > 0 then
            self:ScrollUp()
        else
            self:ScrollDown()
        end
    end)
    log:SetScript("OnHyperlinkEnter", function(_, _, link)
        GameTooltip:SetOwner(frame, "ANCHOR_CURSOR")
        GameTooltip:SetHyperlink(link)
        GameTooltip:Show()
    end)
    log:SetScript("OnHyperlinkLeave", function()
        GameTooltip:Hide()
    end)
    frame.detailsLog = log

    frame:SetScript("OnShow", function()
        if frame.view == "details" then
            addon:RefreshHistoryDetailsWindow()
        else
            addon:RefreshHistoryWindow()
        end
    end)

    self.historyFrame = frame
    self:ShowHistoryListView()
end

function GoldTracker:GetHistoryRow(index)
    local frame = self.historyFrame
    local row = frame.rows[index]
    if row then
        return row
    end

    row = CreateFrame("Button", nil, frame.content)
    row:SetHeight(ROW_HEIGHT)
    row:SetPoint("TOPLEFT", frame.content, "TOPLEFT", 0, -((index - 1) * ROW_SPACING))
    row:SetNormalFontObject(GameFontHighlight)
    row:EnableMouseWheel(true)
    row:SetScript("OnMouseWheel", function(_, delta)
        self:HandleHistoryPageMouseWheel(delta)
    end)

    local bg = row:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints(true)
    bg:SetColorTexture(0, 0, 0, 0.18)
    row.bg = bg

    local hl = row:CreateTexture(nil, "HIGHLIGHT")
    hl:SetAllPoints(true)
    hl:SetColorTexture(1, 1, 1, 0.08)

    local selectCheckbox = CreateFrame("CheckButton", nil, row, "UICheckButtonTemplate")
    selectCheckbox:SetSize(22, 22)
    selectCheckbox:SetPoint("LEFT", row, "LEFT", 10, 0)
    row.selectCheckbox = selectCheckbox

    local nameText = row:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    nameText:SetPoint("TOPLEFT", selectCheckbox, "TOPRIGHT", 0, -2)
    nameText:SetWidth(300)
    nameText:SetJustifyH("LEFT")
    row.nameText = nameText

    local subtitleText = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    subtitleText:SetPoint("TOPLEFT", nameText, "BOTTOMLEFT", 0, -2)
    subtitleText:SetWidth(300)
    subtitleText:SetJustifyH("LEFT")
    subtitleText:SetTextColor(0.78, 0.78, 0.78)
    subtitleText:SetText("")
    subtitleText:Hide()
    row.subtitleText = subtitleText

    local pinButton = CreateFrame("Button", nil, row, "UIPanelButtonTemplate")
    pinButton:SetSize(52, 20)
    pinButton:SetPoint("RIGHT", row, "RIGHT", -126, 0)
    pinButton:SetText("Pin")
    row.pinButton = pinButton

    local renameButton = CreateFrame("Button", nil, row, "UIPanelButtonTemplate")
    renameButton:SetSize(62, 20)
    renameButton:SetPoint("RIGHT", row, "RIGHT", -64, 0)
    renameButton:SetText("Rename")
    row.renameButton = renameButton

    local deleteButton = CreateFrame("Button", nil, row, "UIPanelButtonTemplate")
    deleteButton:SetSize(56, 20)
    deleteButton:SetPoint("RIGHT", row, "RIGHT", -4, 0)
    deleteButton:SetText("Delete")
    row.deleteButton = deleteButton

    local summaryText = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    summaryText:SetPoint("LEFT", row, "LEFT", 340, 0)
    summaryText:SetWidth(74)
    summaryText:SetJustifyH("LEFT")
    row.summaryText = summaryText

    local totalText = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    totalText:SetPoint("LEFT", row, "LEFT", 415, 0)
    totalText:SetPoint("RIGHT", row, "LEFT", 529, 0)
    totalText:SetJustifyH("LEFT")
    row.totalText = totalText

    local totalRawText = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    totalRawText:SetPoint("LEFT", row, "LEFT", 531, 0)
    totalRawText:SetPoint("RIGHT", pinButton, "LEFT", -8, 0)
    totalRawText:SetJustifyH("LEFT")
    row.totalRawText = totalRawText

    frame.rows[index] = row
    return row
end

function GoldTracker:GetHistoryTotalsRow()
    local frame = self.historyFrame
    if not frame then
        return nil
    end

    local row = frame.totalsRow
    if row then
        return row
    end

    row = CreateFrame("Frame", nil, frame.content)
    row:SetHeight(ROW_HEIGHT)
    row:EnableMouse(false)

    local bg = row:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints(true)
    bg:SetColorTexture(0.25, 0.20, 0.02, 0.38)
    row.bg = bg

    local label = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    label:SetPoint("LEFT", row, "LEFT", 36, 0)
    label:SetPoint("RIGHT", row, "RIGHT", -10, 0)
    label:SetJustifyH("LEFT")
    label:SetTextColor(1, 0.90, 0.30)
    label:SetText("")
    row.text = label

    row:Hide()
    frame.totalsRow = row
    return row
end

function GoldTracker:GetSelectedHistorySessionIDsInOrder()
    local frame = self.historyFrame
    if not frame then
        return {}
    end

    local selectedMap = frame.selectedSessionIDs or {}
    local orderedSessions = self:GetDisplaySortedSessionHistory()
    local selectedIDs = {}
    for _, session in ipairs(orderedSessions) do
        if selectedMap[session.id] then
            selectedIDs[#selectedIDs + 1] = session.id
        end
    end
    return selectedIDs
end

function GoldTracker:ClearHistorySelection()
    if not self.historyFrame then
        return
    end

    self.historyFrame.selectedSessionIDs = {}
    if self.UpdateHistoryActionButtons then
        self:UpdateHistoryActionButtons()
    end
end

function GoldTracker:UpdateHistoryActionButtons()
    local frame = self.historyFrame
    if not frame then
        return
    end

    local selectedCount = 0
    for _ in pairs(frame.selectedSessionIDs or {}) do
        selectedCount = selectedCount + 1
    end

    local isListView = frame.view == "list"

    if frame.bulkDeleteButton then
        if isListView and selectedCount > 0 then
            frame.bulkDeleteButton:SetText(selectedCount > 1 and string.format("Bulk Delete (%d)", selectedCount) or "Bulk Delete")
            frame.bulkDeleteButton:Show()
        else
            frame.bulkDeleteButton:Hide()
        end
    end

    if frame.mergeButton then
        if isListView and selectedCount > 1 then
            frame.mergeButton:SetText(string.format("Merge (%d)", selectedCount))
            frame.mergeButton:Show()
        else
            frame.mergeButton:Hide()
        end
    end
end

function GoldTracker:GetDisplaySortedSessionHistory()
    local ordered = {}

    local frame = self.historyFrame
    local filterKey = frame and frame.historyDateFilterKey or HISTORY_DATE_FILTER_ALL
    for _, session in ipairs(self:GetSessionHistory()) do
        if SessionMatchesDateFilter(session, filterKey) then
            ordered[#ordered + 1] = session
        end
    end

    local sortKey = frame and frame.sortKey or nil
    local sortAscending = frame and frame.sortAscending == true

    table.sort(ordered, function(a, b)
        local aPinned = a and a.pinned == true
        local bPinned = b and b.pinned == true
        if aPinned ~= bPinned then
            return aPinned and not bPinned
        end

        if sortKey == "sessionTotal" or sortKey == "sessionTotalRaw" then
            local aValue = GetHistorySortValue(a, sortKey)
            local bValue = GetHistorySortValue(b, sortKey)
            if aValue ~= bValue then
                if sortAscending then
                    return aValue < bValue
                end
                return aValue > bValue
            end
        end

        return CompareHistorySessionsByRecency(a, b)
    end)

    return ordered
end

function GoldTracker:UpdateHistorySortHeaderState()
    if not self.historyFrame then
        return
    end

    local frame = self.historyFrame
    local sortKey = frame.sortKey
    local totalLabel = "Session Total"
    local totalRawLabel = "Raw Session Total"

    if sortKey == "sessionTotal" then
        totalLabel = frame.sortAscending and "Session Total \226\150\178" or "Session Total \226\150\188"
    elseif sortKey == "sessionTotalRaw" then
        totalRawLabel = frame.sortAscending and "Raw Session Total \226\150\178" or "Raw Session Total \226\150\188"
    end

    if frame.totalHeaderButton and frame.totalHeaderButton.text then
        frame.totalHeaderButton.text:SetText(totalLabel)
        if sortKey == "sessionTotal" then
            frame.totalHeaderButton.text:SetTextColor(1, 1, 1)
        else
            frame.totalHeaderButton.text:SetTextColor(1, 0.82, 0)
        end
    end
    if frame.totalRawHeaderButton and frame.totalRawHeaderButton.text then
        frame.totalRawHeaderButton.text:SetText(totalRawLabel)
        if sortKey == "sessionTotalRaw" then
            frame.totalRawHeaderButton.text:SetTextColor(1, 1, 1)
        else
            frame.totalRawHeaderButton.text:SetTextColor(1, 0.82, 0)
        end
    end
end

function GoldTracker:ToggleHistorySort(sortKey)
    if not self.historyFrame then
        return
    end

    local frame = self.historyFrame
    if sortKey ~= "sessionTotal" and sortKey ~= "sessionTotalRaw" then
        return
    end

    if frame.sortKey ~= sortKey then
        frame.sortKey = sortKey
        frame.sortAscending = false
    elseif frame.sortAscending ~= true then
        frame.sortAscending = true
    else
        frame.sortKey = nil
        frame.sortAscending = false
    end

    frame.currentPage = 1
    self:RefreshHistoryWindow()
end

function GoldTracker:GetHistoryPageCount(sessionCount)
    local rowsPerPage = self:GetHistoryRowsPerPage()
    local totalSessions = math.max(0, tonumber(sessionCount) or 0)
    return math.max(1, math.ceil(totalSessions / rowsPerPage))
end

function GoldTracker:SetHistoryPage(page)
    if not self.historyFrame then
        return
    end

    local frame = self.historyFrame
    local totalPages = self:GetHistoryPageCount(#self:GetDisplaySortedSessionHistory())
    local clampedPage = math.max(1, math.min(totalPages, math.floor(tonumber(page) or 1)))
    if frame.currentPage == clampedPage then
        return
    end

    frame.currentPage = clampedPage
    self:RefreshHistoryWindow()
end

function GoldTracker:ShowHistoryListView()
    if not self.historyFrame then
        return
    end

    local frame = self.historyFrame
    frame.view = "list"
    frame.selectedSessionID = nil
    frame.selectedSessionIDs = {}
    if not frame.currentPage then
        frame.currentPage = 1
    end

    if frame.TitleText then
        frame.TitleText:SetText("Gold Tracker - Session History")
    end

    if frame.listContainer then
        frame.listContainer:Show()
    end
    if frame.detailsContainer then
        frame.detailsContainer:Hide()
    end
    if frame.splitButton then
        frame.splitButton:Hide()
    end
    if frame.backButton then
        frame.backButton:Hide()
    end

    self:UpdateHistoryActionButtons()

    self:RefreshHistoryWindow()
end

function GoldTracker:ShowHistoryDetailsView(sessionID)
    if not self.historyFrame then
        return
    end

    local frame = self.historyFrame
    frame.view = "details"
    frame.selectedSessionID = sessionID
    frame.detailsLocationFilterKey = DETAILS_LOCATION_FILTER_ALL

    if frame.TitleText then
        frame.TitleText:SetText("Gold Tracker - Session Details")
    end

    if frame.listContainer then
        frame.listContainer:Hide()
    end
    if frame.detailsContainer then
        frame.detailsContainer:Show()
    end
    if frame.backButton then
        frame.backButton:Show()
    end

    self:UpdateHistoryActionButtons()

    self:RefreshHistoryDetailsWindow()
end

function GoldTracker:RefreshHistoryWindow()
    if not self.historyFrame then
        return
    end

    local frame = self.historyFrame
    local selectedFilterKey = frame.historyDateFilterKey or HISTORY_DATE_FILTER_ALL
    local selectedFilterLabel = nil
    for _, option in ipairs(HISTORY_DATE_FILTER_OPTIONS) do
        if option.key == selectedFilterKey then
            selectedFilterLabel = option.label
            break
        end
    end
    if not selectedFilterLabel then
        selectedFilterKey = HISTORY_DATE_FILTER_ALL
        selectedFilterLabel = "All time"
        frame.historyDateFilterKey = selectedFilterKey
    end
    if frame.historyDateFilterDropdown then
        UIDropDownMenu_SetSelectedValue(frame.historyDateFilterDropdown, selectedFilterKey)
        UIDropDownMenu_SetText(frame.historyDateFilterDropdown, selectedFilterLabel)
    end

    local history = self:GetDisplaySortedSessionHistory()
    local rowsPerPage = self:GetHistoryRowsPerPage()
    local totalPages = self:GetHistoryPageCount(#history)
    frame.currentPage = math.max(1, math.min(frame.currentPage or 1, totalPages))
    local startIndex = ((frame.currentPage - 1) * rowsPerPage) + 1
    local endIndex = math.min(#history, startIndex + rowsPerPage - 1)
    local width = math.max(760, (frame.scrollFrame:GetWidth() or 650) - 24)
    frame.content:SetWidth(width)

    local selectedMap = frame.selectedSessionIDs or {}
    local validIDs = {}
    for _, session in ipairs(history) do
        validIDs[session.id] = true
    end
    for selectedID in pairs(selectedMap) do
        if not validIDs[selectedID] then
            selectedMap[selectedID] = nil
        end
    end
    frame.selectedSessionIDs = selectedMap

    local renderedRows = 0
    local dividerAfterRow = nil
    local previousWasPinned = nil
    for historyIndex = startIndex, endIndex do
        local session = history[historyIndex]
        renderedRows = renderedRows + 1
        local currentIsPinned = session.pinned == true
        if dividerAfterRow == nil and renderedRows > 1 and previousWasPinned and not currentIsPinned then
            dividerAfterRow = renderedRows - 1
        end
        previousWasPinned = currentIsPinned
        local sessionID = session.id
        local row = self:GetHistoryRow(renderedRows)
        row:SetWidth(width)
        if row.bg then
            if selectedMap[sessionID] then
                row.bg:SetColorTexture(0.22, 0.22, 0, 0.25)
            else
                row.bg:SetColorTexture(0, 0, 0, 0.18)
            end
        end
        local rowTitleText, rowSubtitleText = BuildHistoryRowTitleAndSubtitle(session)
        row.nameText:SetText(TruncateSessionNameKeepingDate(self, rowTitleText, row.nameText))
        if row.subtitleText then
            if type(rowSubtitleText) == "string" and rowSubtitleText ~= "" then
                row.subtitleText:SetText(rowSubtitleText)
                row.subtitleText:Show()
            else
                row.subtitleText:SetText("")
                row.subtitleText:Hide()
            end
        end
        row.summaryText:SetText(FormatSessionSummary(self, session))
        row.totalText:SetText(FormatSessionTotal(self, session))
        row.totalRawText:SetText(FormatSessionTotalRaw(self, session))

        row.selectCheckbox:SetChecked(selectedMap[sessionID] == true)
        row.selectCheckbox:SetScript("OnClick", function(button)
            if button:GetChecked() then
                selectedMap[sessionID] = true
            else
                selectedMap[sessionID] = nil
            end
            if row.bg then
                if selectedMap[sessionID] then
                    row.bg:SetColorTexture(0.22, 0.22, 0, 0.25)
                else
                    row.bg:SetColorTexture(0, 0, 0, 0.18)
                end
            end
            self:UpdateHistoryActionButtons()
        end)

        row.pinButton:SetText(session.pinned and "Unpin" or "Pin")
        row.pinButton:SetScript("OnClick", function()
            self:ToggleHistorySessionPinned(sessionID)
        end)

        row:SetScript("OnClick", function()
            self:OpenHistorySessionDetails(sessionID)
        end)
        row.renameButton:SetScript("OnClick", function()
            self:PromptRenameHistorySession(sessionID)
        end)
        row.deleteButton:SetScript("OnClick", function()
            self:DeleteHistorySession(sessionID)
        end)
        row:Show()
    end

    for i = renderedRows + 1, #frame.rows do
        frame.rows[i]:Hide()
    end

    local showTotalsRow = selectedFilterKey ~= HISTORY_DATE_FILTER_ALL
    local renderedRowsWithTotals = renderedRows
    if showTotalsRow then
        local totalRawGold = 0
        local totalItemsValue = 0
        local totalValue = 0
        local totalHighlights = 0
        for _, session in ipairs(history) do
            totalRawGold = totalRawGold + (tonumber(session and session.rawGold) or 0)
            totalItemsValue = totalItemsValue + (tonumber(session and session.itemsValue) or 0)
            totalValue = totalValue + (tonumber(session and session.totalValue) or 0)
            totalHighlights = totalHighlights + (tonumber(session and session.highlightItemCount) or 0)
        end

        local totalsRow = self:GetHistoryTotalsRow()
        if totalsRow then
            totalsRow:SetWidth(width)
            totalsRow:ClearAllPoints()
            totalsRow:SetPoint("TOPLEFT", frame.content, "TOPLEFT", 0, -(renderedRows * ROW_SPACING))
            totalsRow.text:SetText(string.format(
                "Totals (%s): Sessions %d   Highlights %d   Raw %s   Items %s   Total %s",
                selectedFilterLabel,
                #history,
                totalHighlights,
                self:FormatMoney(totalRawGold),
                self:FormatMoney(totalItemsValue),
                self:FormatMoney(totalValue)
            ))
            totalsRow:Show()
            renderedRowsWithTotals = renderedRows + 1
        end
    elseif frame.totalsRow then
        frame.totalsRow:Hide()
    end

    local contentHeight = math.max(1, renderedRowsWithTotals * ROW_SPACING)
    frame.content:SetHeight(contentHeight)
    if frame.pinnedDivider then
        if dividerAfterRow and dividerAfterRow > 0 then
            local dividerY = -((dividerAfterRow * ROW_SPACING) - 2)
            frame.pinnedDivider:ClearAllPoints()
            frame.pinnedDivider:SetPoint("TOPLEFT", frame.content, "TOPLEFT", 24, dividerY)
            frame.pinnedDivider:SetPoint("TOPRIGHT", frame.content, "TOPRIGHT", -42, dividerY)
            frame.pinnedDivider:Show()
        else
            frame.pinnedDivider:Hide()
        end
    end
    frame.scrollFrame:SetVerticalScroll(0)
    if frame.emptyText then
        if #history == 0 and selectedFilterKey ~= HISTORY_DATE_FILTER_ALL then
            frame.emptyText:SetText("")
        else
            frame.emptyText:SetText("No saved sessions.")
        end
        frame.emptyText:SetShown(#history == 0 and not showTotalsRow)
    end
    if frame.prevPageButton then
        frame.prevPageButton:SetEnabled(frame.currentPage > 1)
    end
    if frame.nextPageButton then
        frame.nextPageButton:SetEnabled(frame.currentPage < totalPages)
    end
    if frame.pageText then
        local shownFrom = #history == 0 and 0 or startIndex
        local shownTo = #history == 0 and 0 or endIndex
        local pageLine = string.format("Page %d / %d   Showing %d-%d of %d", frame.currentPage, totalPages, shownFrom, shownTo, #history)
        if selectedFilterKey ~= HISTORY_DATE_FILTER_ALL then
            pageLine = string.format("%s   Filter: %s", pageLine, selectedFilterLabel)
        end
        frame.pageText:SetText(pageLine)
    end
    self:UpdateHistorySortHeaderState()
    self:UpdateHistoryActionButtons()
end

function GoldTracker:OpenHistoryWindow()
    if not self:IsSessionHistoryEnabled() then
        self:Print("Session history is disabled. Enable it in options first.")
        return
    end

    self:CreateHistoryWindow()
    self:ShowHistoryListView()
    self.historyFrame:Show()
    self.historyFrame:Raise()
end

function GoldTracker:RefreshHistoryDetailsWindow()
    local frame = self.historyFrame
    if not frame or frame.view ~= "details" then
        return
    end

    local session = self:GetHistorySessionByID(frame.selectedSessionID)
    if not session then
        self:ShowHistoryListView()
        return
    end

    local locationOptions = BuildHistoryLocationOptions(session)
    frame.detailsLocationOptions = locationOptions
    local selectedLocationKey = frame.detailsLocationFilterKey or DETAILS_LOCATION_FILTER_ALL
    local selectedLocationLabel = "All"
    local selectedLocationIsValid = false
    for _, option in ipairs(locationOptions) do
        if option.key == selectedLocationKey then
            selectedLocationLabel = option.label
            selectedLocationIsValid = true
            break
        end
    end
    if not selectedLocationIsValid then
        selectedLocationKey = DETAILS_LOCATION_FILTER_ALL
        frame.detailsLocationFilterKey = selectedLocationKey
        selectedLocationLabel = "All"
    end
    if frame.locationFilterDropdown then
        UIDropDownMenu_SetSelectedValue(frame.locationFilterDropdown, selectedLocationKey)
        UIDropDownMenu_SetText(frame.locationFilterDropdown, selectedLocationLabel)
    end
    if frame.splitButton then
        frame.splitButton:SetShown(#locationOptions > 2)
    end

    local filteredSummary = BuildHistoryDetailsSummary(session, selectedLocationKey)
    local summaryPrefix = ""
    if selectedLocationKey ~= DETAILS_LOCATION_FILTER_ALL then
        summaryPrefix = string.format("[%s] ", selectedLocationLabel)
    end

    frame.sessionNameText:SetText(session.name or "Session")
    frame.summaryText:SetText(
        string.format(
            "%sRaw gold: %s   Vendor items gold: %s   Items value: %s   Total: %s\nRaw session total: %s   Duration: %s",
            summaryPrefix,
            self:FormatMoney(filteredSummary.rawGold or 0),
            self:FormatMoney(filteredSummary.itemsRawGold or 0),
            self:FormatMoney(filteredSummary.itemsValue or 0),
            self:FormatMoney(filteredSummary.totalValue or 0),
            self:FormatMoney((tonumber(filteredSummary.rawGold) or 0) + (tonumber(filteredSummary.itemsRawGold) or 0)),
            self:FormatDuration(filteredSummary.duration or 0)
        )
    )
    frame.sourceText:SetText(string.format("Value source: %s", session.valueSourceLabel or "Unknown"))

    local locationDetailsText = BuildLocationDetailsTextForSelection(session, selectedLocationKey)
    if selectedLocationKey ~= DETAILS_LOCATION_FILTER_ALL then
        if locationDetailsText ~= "" then
            locationDetailsText = string.format("Selected: %s   %s", selectedLocationLabel, locationDetailsText)
        else
            locationDetailsText = string.format("Selected: %s", selectedLocationLabel)
        end
    end
    local timeFrameText = FormatHistoryTimeFrame(filteredSummary.startTime, filteredSummary.stopTime)
    local displayTimeFrameText = (timeFrameText ~= "") and string.format("Time frame: %s", timeFrameText) or ""

    local hasLocationLine = type(locationDetailsText) == "string" and locationDetailsText ~= ""
    local hasTimeFrameLine = displayTimeFrameText ~= ""

    if frame.locationText then
        if hasLocationLine then
            frame.locationText:SetText(locationDetailsText)
            frame.locationText:Show()
        else
            frame.locationText:SetText("")
            frame.locationText:Hide()
        end
    end
    if frame.timeFrameText then
        if hasTimeFrameLine then
            frame.timeFrameText:SetText(displayTimeFrameText)
            frame.timeFrameText:Show()
        else
            frame.timeFrameText:SetText("")
            frame.timeFrameText:Hide()
        end
    end
    if frame.summaryText then
        frame.summaryText:ClearAllPoints()
        if hasLocationLine and hasTimeFrameLine and frame.timeFrameText then
            frame.summaryText:SetPoint("TOPLEFT", frame.timeFrameText, "BOTTOMLEFT", 0, -10)
        elseif hasLocationLine and frame.locationText then
            frame.summaryText:SetPoint("TOPLEFT", frame.locationText, "BOTTOMLEFT", 0, -10)
        elseif hasTimeFrameLine and frame.timeFrameText then
            frame.summaryText:SetPoint("TOPLEFT", frame.timeFrameText, "BOTTOMLEFT", 0, -10)
        else
            frame.summaryText:SetPoint("TOPLEFT", frame.sessionNameText, "BOTTOMLEFT", 0, -8)
        end
    end

    frame.detailsLog:Clear()
    local items, includeSourceLabel = BuildVisibleHistoryItems(session, selectedLocationKey)
    if #items == 0 then
        frame.detailsLog:AddMessage("No non-soulbound items matched the current quality filter.", 1, 0.35, 0.35)
    else
        for _, item in ipairs(items) do
            local itemText = item.itemLink or "Unknown item"
            local quantity = tonumber(item.quantity) or 0
            local totalValue = tonumber(item.totalValue) or 0
            local lineText = string.format("%s x%d  (%s)", itemText, quantity, self:FormatMoney(totalValue))
            if includeSourceLabel then
                lineText = string.format("%s  [%s]", lineText, item.valueSourceLabel or "Unknown")
            end
            if type(item.lootSourceText) == "string" and item.lootSourceText ~= "" then
                lineText = string.format("%s  [From: %s]", lineText, item.lootSourceText)
            end
            frame.detailsLog:AddMessage(lineText, 0.9, 0.9, 1)
        end
    end
end

function GoldTracker:OpenHistorySessionDetails(sessionID)
    local session = self:GetHistorySessionByID(sessionID)
    if not session then
        return
    end

    self:CreateHistoryWindow()
    self:ShowHistoryDetailsView(sessionID)
    self.historyFrame:Show()
end
