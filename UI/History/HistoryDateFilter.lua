local _, NS = ...

local HistoryConstants = NS.HistoryConstants

local HistoryDateFilter = {}
HistoryDateFilter.__index = HistoryDateFilter

function HistoryDateFilter:New(nowProvider)
    local instance = {
        nowProvider = nowProvider,
    }
    return setmetatable(instance, HistoryDateFilter)
end

function HistoryDateFilter:GetNow()
    if type(self.nowProvider) == "function" then
        local value = tonumber(self.nowProvider())
        if value and value > 0 then
            return value
        end
    end
    return time()
end

function HistoryDateFilter:GetOptions()
    return HistoryConstants.DATE_FILTER_OPTIONS
end

function HistoryDateFilter:GetDayStartWithOffset(referenceTimestamp, dayOffset)
    local parts = date("*t", tonumber(referenceTimestamp) or self:GetNow())
    if type(parts) ~= "table" then
        return 0
    end

    parts.day = (parts.day or 1) + (tonumber(dayOffset) or 0)
    parts.hour = 0
    parts.min = 0
    parts.sec = 0

    return tonumber(time(parts)) or 0
end

function HistoryDateFilter:MatchesTimestamp(sessionTimestamp, filterKey)
    if filterKey == nil or filterKey == "" or filterKey == HistoryConstants.DATE_FILTER_ALL then
        return true
    end

    local timestamp = tonumber(sessionTimestamp) or 0
    if timestamp <= 0 then
        return false
    end

    local now = self:GetNow()
    local todayStart = self:GetDayStartWithOffset(now, 0)
    local tomorrowStart = self:GetDayStartWithOffset(now, 1)

    if filterKey == HistoryConstants.DATE_FILTER_TODAY then
        return timestamp >= todayStart and timestamp < tomorrowStart
    end

    if filterKey == HistoryConstants.DATE_FILTER_YESTERDAY then
        local yesterdayStart = self:GetDayStartWithOffset(now, -1)
        return timestamp >= yesterdayStart and timestamp < todayStart
    end

    if filterKey == HistoryConstants.DATE_FILTER_LAST_7_DAYS then
        local sevenDaysStart = self:GetDayStartWithOffset(now, -6)
        return timestamp >= sevenDaysStart and timestamp < tomorrowStart
    end

    if filterKey == HistoryConstants.DATE_FILTER_THIS_MONTH then
        local nowParts = date("*t", now)
        local sessionParts = date("*t", timestamp)
        if type(nowParts) ~= "table" or type(sessionParts) ~= "table" then
            return false
        end
        return (nowParts.year == sessionParts.year) and (nowParts.month == sessionParts.month)
    end

    return true
end

NS.HistoryDateFilter = HistoryDateFilter
