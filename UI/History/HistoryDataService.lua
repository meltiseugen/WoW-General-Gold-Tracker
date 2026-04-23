local _, NS = ...

local HistoryConstants = NS.HistoryConstants
local HistorySessionModel = NS.HistorySessionModel

local HistoryDataService = {}
HistoryDataService.__index = HistoryDataService

function HistoryDataService:New(addon, allLocationKey)
    local instance = {
        addon = addon,
        allLocationKey = allLocationKey or HistoryConstants.DETAILS_LOCATION_FILTER_ALL,
    }
    return setmetatable(instance, HistoryDataService)
end

function HistoryDataService:NewSessionModel(session)
    return HistorySessionModel:New(self.addon, session, self.allLocationKey)
end

function HistoryDataService:SessionHasMultipleValueSources(session)
    local labelsSeen = {}
    local count = 0

    local function Add(label)
        if type(label) ~= "string" or label == "" then
            return
        end
        if type(self.addon.NormalizeValueSourceLabel) == "function" then
            label = self.addon:NormalizeValueSourceLabel(label)
        end
        if type(label) ~= "string" or label == "" or labelsSeen[label] then
            return
        end
        labelsSeen[label] = true
        count = count + 1
    end

    for _, label in ipairs(session and session.valueSourceLabels or {}) do
        Add(label)
        if count > 1 then
            return true
        end
    end

    if type(session and session.itemLoots) == "table" then
        for _, entry in ipairs(session.itemLoots) do
            Add(entry and entry.valueSourceLabel)
            if count > 1 then
                return true
            end
        end
    end

    Add(session and session.valueSourceLabel)
    return count > 1
end

function HistoryDataService:BuildHistoryDetailsSummary(session, selectedLocationKey)
    local summary = {
        rawGold = 0,
        itemsValue = 0,
        itemsRawGold = 0,
        totalValue = 0,
        duration = 0,
        startTime = 0,
        stopTime = 0,
    }

    local model = self:NewSessionModel(session)
    local firstTimestamp
    local lastTimestamp
    local fallbackSessionLocationKey = model:ResolveHistoryLocationKey(session, session)

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

    local hasMoneyDetails = type(session and session.moneyLoots) == "table" and #session.moneyLoots > 0
    if hasMoneyDetails then
        for _, money in ipairs(session.moneyLoots) do
            if model:EntryMatchesLocation(money, selectedLocationKey, session) then
                summary.rawGold = summary.rawGold + (tonumber(money and money.amount) or 0)
                ConsiderTimestamp(money and money.timestamp)
            end
        end
    elseif selectedLocationKey == self.allLocationKey or selectedLocationKey == fallbackSessionLocationKey then
        summary.rawGold = tonumber(session and session.rawGold) or 0
    end

    local hasItemDetails = type(session and session.itemLoots) == "table" and #session.itemLoots > 0
    if hasItemDetails then
        for _, loot in ipairs(session.itemLoots) do
            if model:EntryMatchesLocation(loot, selectedLocationKey, session) then
                summary.itemsValue = summary.itemsValue + (tonumber(loot and loot.totalValue) or 0)
                summary.itemsRawGold = summary.itemsRawGold + (tonumber(loot and loot.vendorTotalValue) or 0)
                ConsiderTimestamp(loot and loot.timestamp)
            end
        end
    elseif selectedLocationKey == self.allLocationKey or selectedLocationKey == fallbackSessionLocationKey then
        summary.itemsValue = tonumber(session and session.itemsValue) or 0
        summary.itemsRawGold = tonumber(session and session.itemsRawGold) or 0
    end

    summary.totalValue = summary.rawGold + summary.itemsValue
    if selectedLocationKey == self.allLocationKey
        or (not hasItemDetails and not hasMoneyDetails and selectedLocationKey == fallbackSessionLocationKey) then
        local sessionStart, sessionStop = model:GetEventTimeBounds(session)
        summary.startTime = sessionStart
        summary.stopTime = sessionStop
        summary.duration = model:GetDurationSeconds(session)
    elseif firstTimestamp and lastTimestamp then
        summary.duration = math.max(0, lastTimestamp - firstTimestamp)
        summary.startTime = firstTimestamp
        summary.stopTime = lastTimestamp
    else
        local fallbackTs = model:GetReferenceTimestamp(session)
        summary.startTime = fallbackTs
        summary.stopTime = fallbackTs
        summary.duration = 0
    end

    if summary.stopTime > 0 and summary.startTime > 0 and summary.stopTime < summary.startTime then
        summary.stopTime = summary.startTime
    end

    return summary
end

function HistoryDataService:BuildVisibleHistoryItems(session, selectedLocationKey)
    local byLink = {}
    local model = self:NewSessionModel(session)
    local hasDetailedLoot = type(session and session.itemLoots) == "table" and #session.itemLoots > 0
    local includeSourceLabel = self:SessionHasMultipleValueSources(session)
    local includeLootSourceText = not (type(self.addon) == "table"
        and type(self.addon.IsLootSourceTrackingEnabled) == "function"
        and self.addon:IsLootSourceTrackingEnabled() ~= true)
    local fallbackSourceLabel = session and session.valueSourceLabel or "Unknown"
    local minimumTrackedQuality = 0
    if type(self.addon) == "table" and type(self.addon.GetConfiguredMinimumTrackedItemQuality) == "function" then
        minimumTrackedQuality = tonumber(self.addon:GetConfiguredMinimumTrackedItemQuality()) or 0
    end

    local function PassesQualityFilter(itemQuality, itemLink)
        local quality = tonumber(itemQuality)
        if quality then
            quality = math.floor(quality + 0.5)
        elseif type(self.addon) == "table" and type(self.addon.GetItemQualityFromLink) == "function" then
            quality = self.addon:GetItemQualityFromLink(itemLink)
        end

        if type(quality) ~= "number" then
            return true
        end

        return quality >= minimumTrackedQuality
    end

    if hasDetailedLoot then
        for _, entry in ipairs(session.itemLoots) do
            if entry
                and model:EntryMatchesLocation(entry, selectedLocationKey, session)
                and entry.ahTracked == true
                and entry.isSoulbound ~= true
                and PassesQualityFilter(entry.itemQuality, entry.itemLink) then
                local sourceLabel = entry.valueSourceLabel or fallbackSourceLabel
                local lootSourceText = nil
                if includeLootSourceText then
                    if type(entry.lootSourceText) == "string" and entry.lootSourceText ~= "" then
                        lootSourceText = entry.lootSourceText
                    elseif entry.lootSourceType == "AOE" or entry.lootSourceIsAoe == true then
                        lootSourceText = "AOE loot"
                    end
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

    local fallbackSessionLocationKey = model:ResolveHistoryLocationKey(session, session)
    if selectedLocationKey ~= self.allLocationKey and selectedLocationKey ~= fallbackSessionLocationKey then
        return {}, includeSourceLabel
    end

    local fallbackItems = {}
    for _, item in ipairs(session and session.items or {}) do
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

function HistoryDataService:CompareHistorySessionsByRecency(a, b)
    local aSaved = tonumber(a and (a.savedAt or a.stopTime)) or 0
    local bSaved = tonumber(b and (b.savedAt or b.stopTime)) or 0
    if aSaved ~= bSaved then
        return aSaved > bSaved
    end
    return (tonumber(a and a.id) or 0) > (tonumber(b and b.id) or 0)
end

function HistoryDataService:GetHistorySortValue(session, sortKey)
    if sortKey == "highlights" then
        local highlightCount = tonumber(session and session.highlightItemCount)
        if not highlightCount then
            highlightCount = (tonumber(session and session.lowHighlightItemCount) or 0)
                + (tonumber(session and session.highHighlightItemCount) or 0)
        end
        return highlightCount or 0
    end
    if sortKey == "sessionTotal" then
        return tonumber(session and session.totalValue) or 0
    end
    if sortKey == "sessionTotalRaw" then
        local rawGold = tonumber(session and session.rawGold) or 0
        local itemsRawGold = tonumber(session and session.itemsRawGold) or 0
        return rawGold + itemsRawGold
    end
    if sortKey == "duration" then
        return self:NewSessionModel(session):GetDurationSeconds(session)
    end
    return tonumber(session and (session.savedAt or session.stopTime)) or 0
end

NS.HistoryDataService = HistoryDataService
