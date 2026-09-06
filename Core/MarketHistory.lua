local _, NS = ...
local GoldTracker = NS.GoldTracker

local SNAPSHOT_SOURCES = {
    dbMarket = "DBMarket",
    dbRecent = "DBRecent",
    dbMinBuyout = "DBMinBuyout",
    dbHistorical = "DBHistorical",
    dbRegionMarketAvg = "DBRegionMarketAvg",
    dbRegionHistorical = "DBRegionHistorical",
    dbRegionSaleAvg = "DBRegionSaleAvg",
    dbRegionSaleRate = "DBRegionSaleRate",
    dbRegionSoldPerDay = "DBRegionSoldPerDay",
    auctioningMin = "AuctioningOpMin",
    auctioningNormal = "AuctioningOpNormal",
    auctioningMax = "AuctioningOpMax",
}

local WEEKDAY_LABELS = {
    [0] = "Sunday",
    [1] = "Monday",
    [2] = "Tuesday",
    [3] = "Wednesday",
    [4] = "Thursday",
    [5] = "Friday",
    [6] = "Saturday",
}

local function FloorNumber(value)
    local numberValue = tonumber(value)
    if not numberValue then
        return nil
    end
    return math.floor(numberValue + 0.5)
end

local function GetSnapshotPrice(snapshot)
    if type(snapshot) ~= "table" then
        return nil
    end
    return tonumber(snapshot.dbMarket)
        or tonumber(snapshot.dbRecent)
        or tonumber(snapshot.dbMinBuyout)
        or tonumber(snapshot.selectedUnitValue)
        or tonumber(snapshot.dbRegionMarketAvg)
        or tonumber(snapshot.dbRegionSaleAvg)
end

local function FormatPercentChange(value)
    local change = tonumber(value)
    if not change then
        return "0%"
    end
    if change > 999 then
        return "+999%"
    end
    if change < -999 then
        return "-999%"
    end
    if change > 0 then
        return string.format("+%d%%", math.floor(change + 0.5))
    end
    return string.format("%d%%", math.ceil(change - 0.5))
end

local function FormatSnapshotDate(dateKey)
    if type(dateKey) ~= "string" then
        return "unknown date"
    end

    local year, month, day = string.match(dateKey, "^(%d%d%d%d)%-(%d%d)%-(%d%d)$")
    if not year then
        return dateKey
    end
    return string.format("%s-%s-%s", year, month, day)
end

local function FormatSnapshotHour(snapshot)
    if type(snapshot) ~= "table" then
        return "unknown hour"
    end
    if type(snapshot.hourKey) == "string" and snapshot.hourKey ~= "" then
        return snapshot.hourKey .. ":00"
    end
    return FormatSnapshotDate(snapshot.date)
end

local function GetLatestSnapshot(history)
    local snapshots = history and history.snapshots
    if type(snapshots) ~= "table" or #snapshots == 0 then
        return nil
    end
    return snapshots[#snapshots]
end

local function CountSnapshotsSince(snapshots, cutoffTimestamp)
    local count = 0
    for _, snapshot in ipairs(snapshots or {}) do
        if (tonumber(snapshot.timestamp) or 0) >= cutoffTimestamp and GetSnapshotPrice(snapshot) then
            count = count + 1
        end
    end
    return count
end

local function GetOldestSnapshotSince(snapshots, cutoffTimestamp)
    for _, snapshot in ipairs(snapshots or {}) do
        if (tonumber(snapshot.timestamp) or 0) >= cutoffTimestamp and GetSnapshotPrice(snapshot) then
            return snapshot
        end
    end
    return nil
end

local function GetTrendSummary(addon, snapshots, now)
    local latest = snapshots and snapshots[#snapshots]
    local latestPrice = GetSnapshotPrice(latest)
    if not latestPrice then
        return nil
    end

    local windows = {
        { days = 14, label = "last 2 weeks", minimumSamples = 5 },
        { days = 7, label = "last week", minimumSamples = 3 },
        { days = 3, label = "last few days", minimumSamples = 2 },
    }

    for _, window in ipairs(windows) do
        local cutoff = now - (window.days * 86400)
        if CountSnapshotsSince(snapshots, cutoff) >= window.minimumSamples then
            local oldest = GetOldestSnapshotSince(snapshots, cutoff)
            local oldestPrice = GetSnapshotPrice(oldest)
            if oldestPrice and oldestPrice > 0 then
                local change = ((latestPrice - oldestPrice) * 100) / oldestPrice
                if change <= -12 then
                    return string.format("Price is down %s over the %s.", FormatPercentChange(change), window.label)
                elseif change >= 12 then
                    return string.format("Price is up %s over the %s.", FormatPercentChange(change), window.label)
                elseif math.abs(change) <= 5 then
                    return string.format("Price is mostly stable over the %s.", window.label)
                end
            end
        end
    end

    return nil
end

local function GetWeekdaySummary(snapshots)
    local totals = {}
    local overallTotal = 0
    local overallCount = 0

    for _, snapshot in ipairs(snapshots or {}) do
        local price = GetSnapshotPrice(snapshot)
        local weekday = tonumber(snapshot.weekday)
        if price and price > 0 and weekday and WEEKDAY_LABELS[weekday] then
            totals[weekday] = totals[weekday] or { total = 0, count = 0 }
            totals[weekday].total = totals[weekday].total + price
            totals[weekday].count = totals[weekday].count + 1
            overallTotal = overallTotal + price
            overallCount = overallCount + 1
        end
    end

    if overallCount < 10 then
        return nil
    end

    local overallAverage = overallTotal / overallCount
    local bestWeekday = nil
    local bestAverage = 0
    local bestCount = 0

    for weekday, data in pairs(totals) do
        if data.count >= 2 then
            local average = data.total / data.count
            if average > bestAverage then
                bestWeekday = weekday
                bestAverage = average
                bestCount = data.count
            end
        end
    end

    if not bestWeekday or overallAverage <= 0 or bestAverage < (overallAverage * 1.10) then
        return nil
    end

    local lift = ((bestAverage - overallAverage) * 100) / overallAverage
    return string.format(
        "Your best observed day is %s (%s vs average, %d samples).",
        WEEKDAY_LABELS[bestWeekday],
        FormatPercentChange(lift),
        bestCount
    )
end

local function GetDemandSummary(snapshot)
    if type(snapshot) ~= "table" then
        return nil
    end

    local soldPerDay = tonumber(snapshot.dbRegionSoldPerDay)
    local saleRate = tonumber(snapshot.dbRegionSaleRate)
    if soldPerDay and soldPerDay >= 2 then
        return string.format("Regional demand is strong at %.2f sold/day.", soldPerDay)
    end
    if saleRate and saleRate >= 0.05 then
        return string.format("Regional sale rate is healthy at %.3f.", saleRate)
    end
    if soldPerDay and soldPerDay > 0 and soldPerDay < 0.05 then
        return string.format("Very slow regional demand at %.3f sold/day.", soldPerDay)
    end
    if saleRate and saleRate > 0 and saleRate < 0.01 then
        return string.format("Very low regional sale rate at %.3f.", saleRate)
    end
    return nil
end

local function GetBaselineSummary(addon, latest)
    local market = tonumber(latest and latest.dbMarket)
    local historical = tonumber(latest and latest.dbHistorical)
    if not market or not historical or historical <= 0 then
        return nil
    end

    local ratio = market / historical
    if ratio <= 0.70 then
        return string.format("Current market is %s below TSM historical.", FormatPercentChange((ratio - 1) * 100))
    end
    if ratio >= 1.30 then
        return string.format("Current market is %s above TSM historical.", FormatPercentChange((ratio - 1) * 100))
    end
    return nil
end

function GoldTracker:GetMarketHistoryItemKey(itemLink, itemID)
    if type(itemLink) ~= "string" or itemLink == "" then
        local normalizedItemID = tonumber(itemID or itemLink)
        if normalizedItemID then
            return string.format("i:%d", math.floor(normalizedItemID + 0.5))
        end
        return nil
    end

    if type(TSM_API) == "table" and type(TSM_API.ToItemString) == "function" then
        local ok, itemString = pcall(TSM_API.ToItemString, itemLink)
        if ok and type(itemString) == "string" and itemString ~= "" then
            return itemString
        end
    end

    return self:GetTSMItemStringFromLink(itemLink) or itemLink
end

local function GetMarketHistoryDisplayItemLink(item)
    if type(item) ~= "table" then
        return nil
    end
    if type(item.itemLink) == "string" and item.itemLink ~= "" then
        return item.itemLink
    end
    return nil
end

local function RoundPercentChange(value)
    local change = tonumber(value)
    if not change then
        return nil
    end
    if change >= 0 then
        return math.floor(change + 0.5)
    end
    return math.ceil(change - 0.5)
end

local function GetPositiveSnapshotPrice(snapshot, fieldKey)
    local value = tonumber(snapshot and snapshot[fieldKey])
    return value and value > 0 and value or nil
end

local function GetPositiveItemPrice(item, fieldKey)
    local value = tonumber(item and item[fieldKey])
    return value and value > 0 and value or nil
end

local function GetPriceIncreaseAlertCurrentPrice(item, snapshot)
    return GetPositiveSnapshotPrice(snapshot, "dbMarket")
        or GetPositiveItemPrice(item, "marketValue")
        or GetPositiveSnapshotPrice(snapshot, "dbRecent")
        or GetPositiveSnapshotPrice(snapshot, "dbMinBuyout")
        or GetPositiveSnapshotPrice(snapshot, "selectedUnitValue")
        or GetPositiveItemPrice(item, "unitValue")
        or GetPositiveItemPrice(item, "value")
end

local function CalculateRawPercentChange(currentPrice, baselinePrice)
    local current = tonumber(currentPrice)
    local baseline = tonumber(baselinePrice)
    if not current or not baseline or baseline <= 0 then
        return nil
    end
    return ((current - baseline) * 100) / baseline
end

local function GetPriceIncreaseAlertHistoryComparison(history, now, lookbackDays, minimumSamples)
    local snapshots = history and history.snapshots
    if type(snapshots) ~= "table" or #snapshots == 0 then
        return {
            sampleCount = 0,
        }
    end

    local cutoff = now - (lookbackDays * 86400)
    local oldest = nil
    local latest = nil
    local sampleCount = 0

    for _, snapshot in ipairs(snapshots) do
        local timestamp = tonumber(snapshot and snapshot.timestamp) or 0
        local price = GetSnapshotPrice(snapshot)
        if timestamp >= cutoff and timestamp <= now and price and price > 0 then
            sampleCount = sampleCount + 1
            oldest = oldest or snapshot
            latest = snapshot
        end
    end

    if sampleCount < minimumSamples or not oldest or not latest or oldest == latest then
        return {
            sampleCount = sampleCount,
            latestPrice = latest and GetSnapshotPrice(latest) or nil,
        }
    end

    local baselinePrice = GetSnapshotPrice(oldest)
    local latestPrice = GetSnapshotPrice(latest)
    local rawChange = CalculateRawPercentChange(latestPrice, baselinePrice)
    return {
        sampleCount = sampleCount,
        baselinePrice = baselinePrice,
        latestPrice = latestPrice,
        baselineTimestamp = oldest.timestamp,
        latestTimestamp = latest.timestamp,
        rawChangePercent = rawChange,
        changePercent = RoundPercentChange(rawChange),
    }
end

local function GetPriceIncreaseAlertTSMComparison(item, snapshot)
    local currentPrice = GetPriceIncreaseAlertCurrentPrice(item, snapshot)
    local baselinePrice = GetPositiveSnapshotPrice(snapshot, "dbRecent")
    local baselineLabel = "TSM recent"

    if not baselinePrice then
        baselinePrice = GetPositiveSnapshotPrice(snapshot, "dbHistorical")
        baselineLabel = "TSM historical"
    end
    if not baselinePrice then
        baselinePrice = GetPositiveSnapshotPrice(snapshot, "dbRegionHistorical")
        baselineLabel = "TSM region historical"
    end

    local rawChange = CalculateRawPercentChange(currentPrice, baselinePrice)
    if not rawChange then
        return nil
    end

    return {
        currentPrice = currentPrice,
        baselinePrice = baselinePrice,
        baselineLabel = baselineLabel,
        rawChangePercent = rawChange,
        changePercent = RoundPercentChange(rawChange),
    }
end

local function BuildPriceIncreaseCurrentSnapshot(addon, item)
    local itemLink = type(item and item.itemLink) == "string" and item.itemLink ~= "" and item.itemLink or nil
    local itemID = tonumber(item and item.itemID)
    local snapshot = addon:GetMarketHistorySourceSnapshot(itemLink, itemID)

    snapshot.selectedUnitValue = snapshot.selectedUnitValue or FloorNumber(item and (item.unitValue or item.value))
    snapshot.totalValue = snapshot.totalValue or FloorNumber(item and item.totalValue)
    snapshot.dbMarket = snapshot.dbMarket or FloorNumber(item and item.marketValue)
    snapshot.dbHistorical = snapshot.dbHistorical or FloorNumber(item and item.historicalValue)
    snapshot.dbRegionSaleRate = snapshot.dbRegionSaleRate or tonumber(item and item.regionSaleRate)
    snapshot.dbRegionSoldPerDay = snapshot.dbRegionSoldPerDay or tonumber(item and item.regionSoldPerDay)

    return snapshot
end

local function IsPriceIncreaseAlertMaterialItem(addon, item)
    if type(item) ~= "table" then
        return false
    end
    if item.isCraftingReagent == true or item.categoryID == "crafting" then
        return true
    end

    local itemID = tonumber(item.itemID)
    if not itemID then
        return false
    end
    itemID = math.floor(itemID + 0.5)
    local farmingSpots = addon and addon.materialFarmingSpots or NS.MaterialFarmingSpots
    local materialItems = type(farmingSpots) == "table" and farmingSpots.items or nil
    return type(materialItems) == "table" and materialItems[itemID] ~= nil
end

local function BuildPriceIncreaseAlertRow(addon, item, itemKey, history, config, now)
    local snapshot = BuildPriceIncreaseCurrentSnapshot(addon, item)
    local localComparison = GetPriceIncreaseAlertHistoryComparison(
        history,
        now,
        config.lookbackDays,
        config.minimumSamples
    )
    local tsmComparison = GetPriceIncreaseAlertTSMComparison(item, snapshot)
    local localRawChange = tonumber(localComparison and localComparison.rawChangePercent)
    local tsmRawChange = tonumber(tsmComparison and tsmComparison.rawChangePercent)

    local qualifyingComparison = nil
    local basis = nil
    if localRawChange and localRawChange >= config.thresholdPercent then
        qualifyingComparison = localComparison
        basis = "Local"
    elseif tsmRawChange and tsmRawChange >= config.thresholdPercent then
        qualifyingComparison = tsmComparison
        basis = tsmComparison.baselineLabel or "TSM"
    else
        return nil
    end

    local currentPrice = GetPriceIncreaseAlertCurrentPrice(item, snapshot)
        or qualifyingComparison.latestPrice
        or qualifyingComparison.currentPrice
    local quantity = math.max(1, math.floor((tonumber(item and item.quantity) or 1) + 0.5))

    return {
        itemKey = itemKey,
        itemID = item and item.itemID,
        itemLink = item and item.itemLink,
        itemName = item and item.itemName,
        itemQuality = item and item.itemQuality,
        icon = item and item.icon,
        quantity = quantity,
        unitValue = currentPrice,
        totalValue = FloorNumber(item and item.totalValue) or (currentPrice and currentPrice * quantity) or 0,
        baselinePrice = qualifyingComparison.baselinePrice,
        latestPrice = qualifyingComparison.latestPrice or qualifyingComparison.currentPrice or currentPrice,
        changePercent = qualifyingComparison.changePercent,
        rawChangePercent = qualifyingComparison.rawChangePercent,
        localChangePercent = localComparison and localComparison.changePercent,
        localRawChangePercent = localComparison and localComparison.rawChangePercent,
        tsmChangePercent = tsmComparison and tsmComparison.changePercent,
        tsmRawChangePercent = tsmComparison and tsmComparison.rawChangePercent,
        tsmBaselineLabel = tsmComparison and tsmComparison.baselineLabel,
        localSampleCount = localComparison and localComparison.sampleCount or 0,
        baselineTimestamp = localComparison and localComparison.baselineTimestamp,
        latestTimestamp = localComparison and localComparison.latestTimestamp,
        regionSoldPerDay = item and item.regionSoldPerDay,
        regionSaleRate = item and item.regionSaleRate,
        marketValue = snapshot.dbMarket or item and item.marketValue,
        historicalValue = snapshot.dbHistorical or item and item.historicalValue,
        categoryID = item and item.categoryID,
        categoryLabel = item and item.categoryLabel,
        isMaterial = IsPriceIncreaseAlertMaterialItem(addon, item),
        alertBasis = basis,
    }
end

local function GetMarketHistoryDisplayItemName(item)
    if type(item) ~= "table" then
        return nil
    end
    if type(item.itemName) == "string" and item.itemName ~= "" then
        return item.itemName
    end
    local itemID = tonumber(item.itemID)
    return itemID and ("Item " .. tostring(math.floor(itemID + 0.5))) or nil
end

local function AddUniqueCandidate(candidates, candidate)
    if type(candidate) ~= "string" or candidate == "" then
        return
    end

    for _, existing in ipairs(candidates) do
        if existing == candidate then
            return
        end
    end
    candidates[#candidates + 1] = candidate
end

local function ExtractMarketHistorySearchName(query)
    if type(query) ~= "string" then
        return ""
    end

    local linkedName = string.match(query, "%[([^%]]+)%]")
    return linkedName or query
end

local function FindMarketHistoryByQuery(addon, query)
    local marketHistory = addon:NormalizeMarketHistory()
    local items = marketHistory and marketHistory.items
    if type(items) ~= "table" then
        return nil, nil
    end

    local candidates = {}
    local itemKey = addon:GetMarketHistoryItemKey(query)
    AddUniqueCandidate(candidates, itemKey)
    AddUniqueCandidate(candidates, query)

    local itemID = type(query) == "string" and (string.match(query, "item:(%d+)") or string.match(query, "^(%d+)$"))
    if itemID then
        AddUniqueCandidate(candidates, "i:" .. itemID)
    end

    for _, candidate in ipairs(candidates) do
        if type(items[candidate]) == "table" then
            return candidate, items[candidate]
        end
    end

    local searchText = string.lower(ExtractMarketHistorySearchName(query))
    if searchText == "" then
        return nil, nil
    end

    for key, history in pairs(items) do
        local itemName = string.lower(tostring(history.itemName or ""))
        local itemLink = string.lower(tostring(history.itemLink or ""))
        local historyKey = string.lower(tostring(key or ""))
        if string.find(itemName, searchText, 1, true)
            or string.find(itemLink, searchText, 1, true)
            or string.find(historyKey, searchText, 1, true) then
            return key, history
        end
    end

    return nil, nil
end

function GoldTracker:GetMarketHistoryForItem(itemLink, itemID)
    local query = type(itemLink) == "string" and itemLink ~= "" and itemLink or itemID
    return FindMarketHistoryByQuery(self, query)
end

local function FormatMarketHistoryMoney(addon, value)
    local copper = FloorNumber(value)
    if not copper or copper <= 0 then
        return "unknown"
    end
    return addon:FormatMoney(copper)
end

local function FormatMarketHistoryDecimal(value, precision)
    local numberValue = tonumber(value)
    if not numberValue then
        return "unknown"
    end
    return string.format("%." .. tostring(precision or 2) .. "f", numberValue)
end

function GoldTracker:NormalizeMarketHistory()
    if not self.db then
        return nil
    end

    if type(self.db.marketHistory) ~= "table" then
        self.db.marketHistory = {}
    end
    if type(self.db.marketHistory.items) ~= "table" then
        self.db.marketHistory.items = {}
    end

    return self.db.marketHistory
end

function GoldTracker:GetMarketHistorySampleCount(itemLink)
    local itemKey = self:GetMarketHistoryItemKey(itemLink)
    local marketHistory = self:NormalizeMarketHistory()
    local history = marketHistory and itemKey and marketHistory.items[itemKey]
    if type(history) ~= "table" or type(history.snapshots) ~= "table" then
        return 0
    end
    return #history.snapshots
end

local function GetTSMRawCustomValueForMarketHistory(addon, priceSource, itemLink, itemID)
    if type(itemLink) == "string" and itemLink ~= "" and type(addon.GetTSMRawCustomValue) == "function" then
        local value = addon:GetTSMRawCustomValue(priceSource, itemLink)
        if value then
            return value
        end
    end

    local normalizedItemID = tonumber(itemID)
    if not normalizedItemID or type(TSM_API) ~= "table" or type(TSM_API.GetCustomPriceValue) ~= "function" then
        return nil
    end

    local itemString = string.format("i:%d", math.floor(normalizedItemID + 0.5))
    local ok, value = pcall(TSM_API.GetCustomPriceValue, priceSource, itemString)
    if ok and type(value) == "number" and value > 0 then
        return value
    end
    return nil
end

function GoldTracker:GetMarketHistorySourceSnapshot(itemLink, itemID)
    local snapshot = {}
    if type(self.GetTSMRawCustomValue) ~= "function"
        and not (type(TSM_API) == "table" and type(TSM_API.GetCustomPriceValue) == "function") then
        return snapshot
    end

    for fieldKey, sourceKey in pairs(SNAPSHOT_SOURCES) do
        local value = GetTSMRawCustomValueForMarketHistory(self, sourceKey, itemLink, itemID)
        if fieldKey == "dbRegionSaleRate" or fieldKey == "dbRegionSoldPerDay" then
            snapshot[fieldKey] = tonumber(value)
        else
            snapshot[fieldKey] = FloorNumber(value)
        end
    end

    return snapshot
end

function GoldTracker:PruneMarketHistory(now)
    local marketHistory = self:NormalizeMarketHistory()
    if not marketHistory then
        return
    end

    now = tonumber(now) or time()
    local retentionDays = tonumber(self.db and self.db.marketHistoryRetentionDays) or self.DEFAULTS.marketHistoryRetentionDays
    local maxSnapshotsPerItem = tonumber(self.db and self.db.marketHistoryMaxSnapshotsPerItem)
        or self.DEFAULTS.marketHistoryMaxSnapshotsPerItem
    local cutoff = now - (math.max(14, retentionDays) * 86400)
    local itemCount = 0
    local oldestByKey = {}

    for itemKey, history in pairs(marketHistory.items) do
        if type(history) ~= "table" or type(history.snapshots) ~= "table" then
            marketHistory.items[itemKey] = nil
        else
            local kept = {}
            for _, snapshot in ipairs(history.snapshots) do
                if (tonumber(snapshot.timestamp) or 0) >= cutoff then
                    kept[#kept + 1] = snapshot
                end
            end
            while #kept > maxSnapshotsPerItem do
                table.remove(kept, 1)
            end
            history.snapshots = kept
            if #kept == 0 then
                marketHistory.items[itemKey] = nil
            else
                history.firstSeen = kept[1].timestamp
                history.lastSeen = kept[#kept].timestamp
                itemCount = itemCount + 1
                oldestByKey[itemKey] = tonumber(history.lastSeen) or 0
            end
        end
    end

    local maxItems = tonumber(self.db and self.db.marketHistoryMaxItems) or self.DEFAULTS.marketHistoryMaxItems
    if itemCount <= maxItems then
        return
    end

    local keys = {}
    for itemKey in pairs(oldestByKey) do
        keys[#keys + 1] = itemKey
    end
    table.sort(keys, function(left, right)
        return (oldestByKey[left] or 0) < (oldestByKey[right] or 0)
    end)

    local removeCount = itemCount - maxItems
    for index = 1, removeCount do
        marketHistory.items[keys[index]] = nil
    end
end

function GoldTracker:RecordInventoryMarketSnapshots(items)
    if type(items) ~= "table" or #items == 0 then
        return
    end

    local marketHistory = self:NormalizeMarketHistory()
    if not marketHistory then
        return
    end

    local now = time()
    local dateKey = date("%Y-%m-%d", now)
    local hourKey = date("%Y-%m-%d %H", now)
    local hour = tonumber(date("%H", now)) or 0
    local weekday = tonumber(date("%w", now)) or 0
    local touched = false

    for _, item in ipairs(items) do
        local itemLink = GetMarketHistoryDisplayItemLink(item)
        local itemID = tonumber(item and item.itemID)
        local itemKey = self:GetMarketHistoryItemKey(itemLink, itemID)
        if itemKey then
            local history = marketHistory.items[itemKey]
            if type(history) ~= "table" then
                history = {
                    itemKey = itemKey,
                    itemLink = itemLink,
                    itemID = itemID and math.floor(itemID + 0.5) or nil,
                    itemName = GetMarketHistoryDisplayItemName(item),
                    itemQuality = item.itemQuality,
                    firstSeen = now,
                    snapshots = {},
                }
                marketHistory.items[itemKey] = history
            end

            history.itemLink = itemLink or history.itemLink
            history.itemID = itemID and math.floor(itemID + 0.5) or history.itemID
            history.itemName = GetMarketHistoryDisplayItemName(item) or history.itemName
            history.itemQuality = item.itemQuality or history.itemQuality
            history.lastSeen = now

            local snapshot = self:GetMarketHistorySourceSnapshot(itemLink, itemID)
            snapshot.date = dateKey
            snapshot.hourKey = hourKey
            snapshot.hour = hour
            snapshot.weekday = weekday
            snapshot.timestamp = now
            snapshot.selectedSourceID = item.valueSourceID
            snapshot.selectedUnitValue = FloorNumber(item.unitValue or item.value)
            snapshot.quantity = FloorNumber(item.quantity) or 1
            snapshot.totalValue = FloorNumber(item.totalValue or item.value)
            snapshot.dbMarket = snapshot.dbMarket or FloorNumber(item.marketValue)
            snapshot.dbHistorical = snapshot.dbHistorical or FloorNumber(item.historicalValue)
            snapshot.dbRegionMarketAvg = snapshot.dbRegionMarketAvg or FloorNumber(item.regionMarketValue)
            snapshot.dbRegionSaleAvg = snapshot.dbRegionSaleAvg or FloorNumber(item.averageValue)
            snapshot.dbRegionSaleRate = snapshot.dbRegionSaleRate or tonumber(item.regionSaleRate)
            snapshot.dbRegionSoldPerDay = snapshot.dbRegionSoldPerDay or tonumber(item.regionSoldPerDay)

            local snapshots = history.snapshots
            local lastSnapshot = snapshots[#snapshots]
            if lastSnapshot and lastSnapshot.hourKey == hourKey then
                snapshots[#snapshots] = snapshot
            else
                snapshots[#snapshots + 1] = snapshot
            end
            touched = true
        end
    end

    if touched then
        self:PruneMarketHistory(now)
    end
end

local function AddMarketHistoryCandidate(candidates, seen, item)
    if type(item) ~= "table" then
        return
    end

    local itemKey = item.marketHistoryItemKey
    if type(itemKey) ~= "string" or itemKey == "" then
        itemKey = GoldTracker:GetMarketHistoryItemKey(item.itemLink, item.itemID)
    end
    if not itemKey or seen[itemKey] then
        return
    end

    seen[itemKey] = true
    candidates[#candidates + 1] = item
end

function GoldTracker:RecordRareFarmingMarketSnapshots(rows)
    if type(rows) ~= "table" then
        return
    end

    local candidates = {}
    local seen = {}
    for _, row in ipairs(rows) do
        AddMarketHistoryCandidate(candidates, seen, row)
    end
    self:RecordInventoryMarketSnapshots(candidates)
end

function GoldTracker:RecordSavedRareFarmingMarketSnapshots()
    if type(self.db) ~= "table" then
        return
    end

    local candidates = {}
    local seen = {}
    local favorites = self.db.rareFarmingFavorites
    if type(favorites) == "table" then
        for _, favorite in pairs(favorites) do
            AddMarketHistoryCandidate(candidates, seen, favorite)
        end
    end

    local cache = self.db.rareFarmingScanCache
    if type(cache) == "table" then
        for _, entry in pairs(cache) do
            if type(entry) == "table" and type(entry.results) == "table" then
                for _, row in ipairs(entry.results) do
                    AddMarketHistoryCandidate(candidates, seen, row)
                end
            end
        end
    end

    self:RecordInventoryMarketSnapshots(candidates)
end

function GoldTracker:RecordInstanceFarmingMarketSnapshots(rows)
    if type(rows) ~= "table" then
        return
    end

    local candidates = {}
    local seen = {}
    for _, row in ipairs(rows) do
        AddMarketHistoryCandidate(candidates, seen, row)
    end
    self:RecordInventoryMarketSnapshots(candidates)
end

function GoldTracker:RecordSavedInstanceFarmingMarketSnapshots()
    if type(self.db) ~= "table" then
        return
    end

    local candidates = {}
    local seen = {}
    local favorites = self.db.instanceFarmingFavorites
    if type(favorites) == "table" then
        for _, favorite in pairs(favorites) do
            AddMarketHistoryCandidate(candidates, seen, favorite)
        end
    end

    local cache = self.db.instanceFarmingScanCache
    if type(cache) == "table" then
        for _, entry in pairs(cache) do
            if type(entry) == "table" and type(entry.results) == "table" then
                for _, row in ipairs(entry.results) do
                    AddMarketHistoryCandidate(candidates, seen, row)
                end
            end
        end
    end

    self:RecordInventoryMarketSnapshots(candidates)
end

function GoldTracker:RecordCraftingFarmingMarketSnapshots(rows)
    if type(rows) ~= "table" then
        return
    end

    local candidates = {}
    local seen = {}
    for _, row in ipairs(rows) do
        AddMarketHistoryCandidate(candidates, seen, row)
    end
    self:RecordInventoryMarketSnapshots(candidates)
end

function GoldTracker:GetPriceIncreaseAlertConfig(options)
    options = type(options) == "table" and options or {}
    local defaults = self.DEFAULTS or {}

    local thresholdPercent = tonumber(options.thresholdPercent)
        or tonumber(self.db and self.db.priceIncreaseAlertThresholdPercent)
        or tonumber(defaults.priceIncreaseAlertThresholdPercent)
        or 30
    local lookbackDays = tonumber(options.lookbackDays)
        or tonumber(self.db and self.db.priceIncreaseAlertLookbackDays)
        or tonumber(defaults.priceIncreaseAlertLookbackDays)
        or 3
    local minimumSamples = tonumber(options.minimumSamples)
        or tonumber(self.db and self.db.priceIncreaseAlertMinimumSamples)
        or tonumber(defaults.priceIncreaseAlertMinimumSamples)
        or 2

    return {
        thresholdPercent = math.max(1, math.floor(thresholdPercent + 0.5)),
        lookbackDays = math.max(1, math.floor(lookbackDays + 0.5)),
        minimumSamples = math.max(2, math.floor(minimumSamples + 0.5)),
    }
end

function GoldTracker:GetPriceIncreaseAlertForItem(item, options)
    if type(item) ~= "table" then
        return nil
    end

    local itemLink = type(item.itemLink) == "string" and item.itemLink ~= "" and item.itemLink or nil
    local itemID = tonumber(item.itemID)
    local itemKey = item.marketHistoryItemKey or self:GetMarketHistoryItemKey(itemLink, itemID)
    if not itemKey then
        return nil
    end

    local marketHistory = self:NormalizeMarketHistory()
    local history = marketHistory and marketHistory.items and marketHistory.items[itemKey]
    return BuildPriceIncreaseAlertRow(
        self,
        item,
        itemKey,
        history,
        self:GetPriceIncreaseAlertConfig(options),
        tonumber(options and options.now) or time()
    )
end

function GoldTracker:BuildPriceIncreaseAlertRows(options)
    local config = self:GetPriceIncreaseAlertConfig(options)
    local source = self.GetAuctionableInventoryValueSource and self:GetAuctionableInventoryValueSource() or nil
    local sourceID = source and source.id
    local minimumQuality = self.GetConfiguredMinimumTrackedItemQuality and self:GetConfiguredMinimumTrackedItemQuality() or 0
    local items = {}
    local totalValue = 0
    local totalQuantity = 0
    local scannedStacks = 0
    local matchedStacks = 0

    if type(self.BuildInventoryAuctionItemList) == "function" then
        items, totalValue, totalQuantity, scannedStacks, matchedStacks = self:BuildInventoryAuctionItemList(
            sourceID,
            minimumQuality,
            0,
            "itemName",
            true
        )
        items = type(items) == "table" and items or {}
    end

    if type(self.RecordInventoryMarketSnapshots) == "function" and #items > 0 then
        self:RecordInventoryMarketSnapshots(items)
    end

    local rows = {}
    local seen = {}
    for _, item in ipairs(items) do
        local itemKey = item and (item.marketHistoryItemKey or self:GetMarketHistoryItemKey(item.itemLink, item.itemID))
        if itemKey and not seen[itemKey] then
            seen[itemKey] = true
            local row = self:GetPriceIncreaseAlertForItem(item, config)
            if row then
                rows[#rows + 1] = row
            end
        end
    end

    table.sort(rows, function(left, right)
        local leftChange = tonumber(left and left.rawChangePercent) or -1000000
        local rightChange = tonumber(right and right.rawChangePercent) or -1000000
        if leftChange ~= rightChange then
            return leftChange > rightChange
        end

        local leftValue = tonumber(left and left.totalValue) or 0
        local rightValue = tonumber(right and right.totalValue) or 0
        if leftValue ~= rightValue then
            return leftValue > rightValue
        end

        return string.lower(tostring(left and (left.itemName or left.itemLink or left.itemID) or ""))
            < string.lower(tostring(right and (right.itemName or right.itemLink or right.itemID) or ""))
    end)

    return rows, {
        thresholdPercent = config.thresholdPercent,
        lookbackDays = config.lookbackDays,
        minimumSamples = config.minimumSamples,
        scannedStacks = tonumber(scannedStacks) or 0,
        matchedStacks = tonumber(matchedStacks) or 0,
        inventoryItemCount = #items,
        totalValue = tonumber(totalValue) or 0,
        totalQuantity = tonumber(totalQuantity) or 0,
    }
end

function GoldTracker:RecordCurrentBagMarketSnapshot()
    if type(self.BuildInventoryAuctionItemList) ~= "function" then
        return
    end

    local source = self:GetAuctionableInventoryValueSource()
    local minimumQuality = self:GetConfiguredMinimumTrackedItemQuality()
    local items = self:BuildInventoryAuctionItemList(
        source and source.id,
        minimumQuality,
        0,
        "itemName",
        true
    )
    self:RecordInventoryMarketSnapshots(items)
end

function GoldTracker:QueueMarketHistoryBagSnapshot()
    if self.marketHistorySnapshotQueued then
        return
    end

    local now = time()
    local lastSnapshotAt = tonumber(self.marketHistoryLastSnapshotAt) or 0
    if now - lastSnapshotAt < 300 then
        return
    end

    self.marketHistorySnapshotQueued = true
    local function RecordSnapshot()
        self.marketHistorySnapshotQueued = false
        self.marketHistoryLastSnapshotAt = time()
        self:RecordCurrentBagMarketSnapshot()
    end

    if C_Timer and type(C_Timer.After) == "function" then
        C_Timer.After(5, RecordSnapshot)
    else
        RecordSnapshot()
    end
end

function GoldTracker:GetInventoryMarketInsight(item)
    local itemLink = item and item.itemLink
    local itemKey = item and item.marketHistoryItemKey or self:GetMarketHistoryItemKey(itemLink, item and item.itemID)
    local marketHistory = self:NormalizeMarketHistory()
    local history = marketHistory and itemKey and marketHistory.items[itemKey]
    if type(history) ~= "table" or type(history.snapshots) ~= "table" or #history.snapshots == 0 then
        return {
            summary = "Collecting local market history.",
            detail = "No saved snapshots yet.",
            sampleCount = 0,
        }
    end

    local snapshots = history.snapshots
    local latest = GetLatestSnapshot(history)
    local now = time()
    local trendSummary = GetTrendSummary(self, snapshots, now)
    local weekdaySummary = GetWeekdaySummary(snapshots)
    local demandSummary = GetDemandSummary(latest)
    local baselineSummary = GetBaselineSummary(self, latest)

    local summary = trendSummary or baselineSummary or demandSummary or "Collecting local trend data."
    local detail = weekdaySummary or demandSummary or baselineSummary
    if not detail or detail == summary then
        detail = string.format("%d snapshot%s saved since %s. Latest: %s.",
            #snapshots,
            #snapshots == 1 and "" or "s",
            FormatSnapshotDate(snapshots[1] and snapshots[1].date),
            FormatSnapshotHour(latest)
        )
    end

    return {
        summary = summary,
        detail = detail,
        sampleCount = #snapshots,
        latestPrice = GetSnapshotPrice(latest),
        latestDate = latest and latest.date,
        latestHourKey = latest and latest.hourKey,
    }
end

function GoldTracker:PrintMarketHistoryDebug(query)
    query = self:Trim(query or "")
    if query == "" then
        self:Print("Usage: /gt market <item link, item name, itemID, or item string>")
        return
    end

    local itemKey, history = FindMarketHistoryByQuery(self, query)
    if type(history) ~= "table" or type(history.snapshots) ~= "table" or #history.snapshots == 0 then
        self:Print("No saved market history for " .. query .. ". Open Auctionable Inventory while the item is in your bags to record it.")
        return
    end

    local snapshots = history.snapshots
    local displayName = history.itemLink or history.itemName or itemKey or query
    local insight = self:GetInventoryMarketInsight({
        itemLink = history.itemLink,
        marketHistoryItemKey = itemKey,
    })

    self:Print(string.format(
        "Market history for %s: %d snapshot%s saved.",
        tostring(displayName),
        #snapshots,
        #snapshots == 1 and "" or "s"
    ))
    if type(insight) == "table" then
        self:Print(insight.summary or "Collecting local market history.")
        if type(insight.detail) == "string" and insight.detail ~= "" and insight.detail ~= insight.summary then
            self:Print(insight.detail)
        end
    end

    local startIndex = math.max(1, #snapshots - 4)
    for index = startIndex, #snapshots do
        local snapshot = snapshots[index]
        self:Print(string.format(
            "%s: market %s, recent %s, sold/day %s, sale rate %s",
            FormatSnapshotHour(snapshot),
            FormatMarketHistoryMoney(self, snapshot.dbMarket),
            FormatMarketHistoryMoney(self, snapshot.dbRecent),
            FormatMarketHistoryDecimal(snapshot.dbRegionSoldPerDay, 2),
            FormatMarketHistoryDecimal(snapshot.dbRegionSaleRate, 3)
        ))
    end
end
