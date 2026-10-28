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

function HistoryDataService:BuildHistoryDetailsSummary(session, selectedLocationKey, selectedStyleID)
    selectedLocationKey = selectedLocationKey or self.allLocationKey
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
    local styleID = self.addon and self.addon.NormalizeSessionStyleFilter
        and self.addon:NormalizeSessionStyleFilter(selectedStyleID)
        or "all"
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
            if styleID == "all" and model:EntryMatchesLocation(money, selectedLocationKey, session) then
                summary.rawGold = summary.rawGold + (tonumber(money and money.amount) or 0)
                ConsiderTimestamp(money and money.timestamp)
            end
        end
    elseif styleID == "all" and (selectedLocationKey == self.allLocationKey or selectedLocationKey == fallbackSessionLocationKey) then
        summary.rawGold = tonumber(session and session.rawGold) or 0
    end

    local hasItemDetails = type(session and session.itemLoots) == "table" and #session.itemLoots > 0
    if hasItemDetails then
        for _, loot in ipairs(session.itemLoots) do
            if model:EntryMatchesLocation(loot, selectedLocationKey, session) then
                local matchesStyle = styleID == "all"
                    or (
                        self.addon
                        and type(self.addon.LootItemMatchesSessionStyle) == "function"
                        and self.addon:LootItemMatchesSessionStyle(loot, styleID)
                    )
                if matchesStyle then
                    summary.itemsValue = summary.itemsValue + (tonumber(loot and loot.totalValue) or 0)
                    summary.itemsRawGold = summary.itemsRawGold + (tonumber(loot and loot.vendorTotalValue) or 0)
                    ConsiderTimestamp(loot and loot.timestamp)
                end
            end
        end
    elseif styleID == "all" and (selectedLocationKey == self.allLocationKey or selectedLocationKey == fallbackSessionLocationKey) then
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

    summary.timingLabel = model:GetTimingLabel(session)
    if selectedLocationKey ~= self.allLocationKey then
        local intervals = {}
        for _, visit in ipairs(session.locationVisits or {}) do
            if selectedLocationKey == "loc:" .. tostring(visit.locationKey) then intervals[#intervals + 1] = visit end
        end
        if #intervals > 0 then
            summary.duration = model:SumIntervals(intervals)
            summary.timingLabel = "Recorded visits"
        else
            summary.timingLabel = "Loot activity span (legacy)"
        end
        summary.rateDuration = summary.duration
        summary.rateBasis = summary.timingLabel
        if self.addon.IsActiveTimeForGoldPerHourEnabled and self.addon:IsActiveTimeForGoldPerHourEnabled() then
            local timestamps = {}
            for _, loot in ipairs(session.itemLoots or {}) do
                if model:EntryMatchesLocation(loot, selectedLocationKey, session)
                    and (tonumber(loot.timestamp) or 0) > 0 then timestamps[#timestamps + 1] = loot.timestamp end
            end
            for _, money in ipairs(session.moneyLoots or {}) do
                if model:EntryMatchesLocation(money, selectedLocationKey, session) and (tonumber(money.timestamp) or 0) > 0 then timestamps[#timestamps + 1] = money.timestamp end
            end
            table.sort(timestamps)
            local active = 0
            if #intervals == 0 then
                for index = 2, #timestamps do active = active + math.min(90, timestamps[index] - timestamps[index - 1]) end
            else
                for _, visit in ipairs(intervals) do
                    local previous = tonumber(visit.startTime) or 0
                    for _, timestamp in ipairs(timestamps) do
                        if timestamp >= previous and timestamp <= (tonumber(visit.stopTime) or previous) then
                            active = active + math.min(90, timestamp - previous)
                            previous = timestamp
                        end
                    end
                end
            end
            summary.rateDuration = math.min(summary.duration, active)
            summary.rateBasis = "Estimated active loot time"
        end
    else
        summary.rateDuration, summary.rateBasis = model:GetRateDuration(session)
    end

    return summary
end

function HistoryDataService:BuildVisibleHistoryItems(session, selectedLocationKey, selectedStyleID, itemFilter)
    local byLink = {}
    local model = self:NewSessionModel(session)
    local styleID = self.addon and self.addon.NormalizeSessionStyleFilter
        and self.addon:NormalizeSessionStyleFilter(selectedStyleID)
        or "all"
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
                and (itemFilter == "all"
                    or (itemFilter == "bound" and entry.isSoulbound == true)
                    or (itemFilter == "vendor" and entry.ahTracked ~= true and entry.isSoulbound ~= true)
                    or ((itemFilter == nil or itemFilter == "auction") and entry.ahTracked == true and entry.isSoulbound ~= true))
                and (styleID == "all" or (
                    self.addon
                    and type(self.addon.LootItemMatchesSessionStyle) == "function"
                    and self.addon:LootItemMatchesSessionStyle(entry, styleID)
                ))
                and (itemFilter ~= nil or PassesQualityFilter(entry.itemQuality, entry.itemLink)) then
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
                if itemFilter then
                    key = key .. "\001" .. (entry.isSoulbound and "bound" or (entry.ahTracked and "auction" or "vendor"))
                end
                if includeSourceLabel then
                    key = string.format("%s\001%s", key, sourceLabel)
                end
                if lootSourceText and itemFilter == nil then
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
                        vendorTotalValue = 0,
                        isSoulbound = entry.isSoulbound == true,
                        ahTracked = entry.ahTracked == true and entry.isSoulbound ~= true,
                        sources = {},
                        sourcesSeen = {},
                    }
                    byLink[key] = item
                end

                item.quantity = item.quantity + (tonumber(entry.quantity) or 0)
                item.totalValue = item.totalValue + (tonumber(entry.totalValue) or 0)
                item.vendorTotalValue = item.vendorTotalValue + (tonumber(entry.vendorTotalValue) or 0)
                if lootSourceText and not item.sourcesSeen[lootSourceText] then
                    item.sourcesSeen[lootSourceText] = true
                    item.sources[#item.sources + 1] = lootSourceText
                end
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
            if itemFilter then
                item.lootSourceText = #item.sources > 1 and (#item.sources .. " sources") or item.sources[1]
            end
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
    if styleID ~= "all" then
        return {}, includeSourceLabel
    end
    if itemFilter == "vendor" or itemFilter == "bound" then return {}, includeSourceLabel end

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
