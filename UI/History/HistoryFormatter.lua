local _, NS = ...

local HistoryFormatter = {}
HistoryFormatter.__index = HistoryFormatter

function HistoryFormatter:New(addon)
    local instance = {
        addon = addon,
    }
    return setmetatable(instance, HistoryFormatter)
end

function HistoryFormatter:Trim(value)
    if type(self.addon) == "table" and type(self.addon.Trim) == "function" then
        return self.addon:Trim(value)
    end
    if type(value) ~= "string" then
        return ""
    end
    return (value:gsub("^%s+", ""):gsub("%s+$", ""))
end

function HistoryFormatter:FormatMoney(value)
    if type(self.addon) == "table" and type(self.addon.FormatMoney) == "function" then
        return self.addon:FormatMoney(value)
    end
    return tostring(math.max(0, math.floor((tonumber(value) or 0) + 0.5)))
end

function HistoryFormatter:FormatSessionSummary(session)
    local highlightCount = tonumber(session and session.highlightItemCount)
    if not highlightCount then
        highlightCount = (tonumber(session and session.lowHighlightItemCount) or 0) + (tonumber(session and session.highHighlightItemCount) or 0)
    end
    return tostring(math.max(0, math.floor((highlightCount or 0) + 0.5)))
end

function HistoryFormatter:FormatSessionTotal(session)
    local text = self:FormatMoney(tonumber(session and session.totalValue) or 0)
    return text:gsub("^[%s\194\160]+", "")
end

function HistoryFormatter:FormatSessionTotalRaw(session)
    local rawGold = tonumber(session and session.rawGold) or 0
    local itemsRawGold = tonumber(session and session.itemsRawGold) or 0
    local text = self:FormatMoney(rawGold + itemsRawGold)
    return text:gsub("^[%s\194\160]+", "")
end

function HistoryFormatter:FormatHistoryTimeFrame(startTime, stopTime)
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

function HistoryFormatter:TruncateSessionNameKeepingDate(fullName, nameFontString)
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
        prefix, datetimeSuffix = fullName:match("^(.*)( %- %d%d%d%d%-%d%d%-%d%d %d%d:%d%d %-%> %d%d%d%d%-%d%d%-%d%d %d%d:%d%d)$")
    end
    if not prefix or not datetimeSuffix then
        prefix, datetimeSuffix = fullName:match("^(.*)( %- %d%d%d%d%-%d%d%-%d%d %d%d:%d%d:%d%d)$")
    end
    if not prefix or not datetimeSuffix then
        prefix, datetimeSuffix = fullName:match("^(.*)( %- %d%d%d%d%-%d%d%-%d%d %d%d:%d%d)$")
    end

    local ellipsis = "..."
    if prefix and datetimeSuffix then
        local trimmedPrefix = self:Trim(prefix)
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

NS.HistoryFormatter = HistoryFormatter
