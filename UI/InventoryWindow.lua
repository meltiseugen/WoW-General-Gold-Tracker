local _, NS = ...
local GoldTracker = NS.GoldTracker
local Theme = NS.JanisTheme

local INVENTORY_WINDOW_MIN_WIDTH = 900
local INVENTORY_WINDOW_DEFAULT_WIDTH = 1160
local INVENTORY_WINDOW_DEFAULT_HEIGHT = 620
local INVENTORY_WINDOW_MIN_HEIGHT = 420
local INVENTORY_WINDOW_MAX_WIDTH = 1320
local INVENTORY_WINDOW_MAX_HEIGHT = 900
local INVENTORY_ROW_HEIGHT = 24
local INVENTORY_ROW_SPACING = 2
local INVENTORY_ICON_SIZE = 18
local INVENTORY_COLUMN_GAP = 12
local INVENTORY_HEADER_LEFT_INSET = 12
local INVENTORY_ROW_ICON_LEFT = 8
local INVENTORY_ROW_ICON_GAP = 8
local INVENTORY_ROW_RIGHT_PADDING = 6
local INVENTORY_ACTION_COLUMN_GAP = 6
local INVENTORY_TRACKED_COLUMN_WIDTH = 60
local INVENTORY_MAP_COLUMN_WIDTH = 44
local INVENTORY_TRACKED_BUTTON_WIDTH = 24
local INVENTORY_TRACKED_BUTTON_HEIGHT = 20
local INVENTORY_MAP_BUTTON_WIDTH = 40
local INVENTORY_MAP_BUTTON_HEIGHT = 20
local INVENTORY_QUANTITY_WIDTH = 56
local INVENTORY_HISTORY_WIDTH = 46
local INVENTORY_DEMAND_WIDTH = 82
local INVENTORY_SELL_RATE_WIDTH = 78
local INVENTORY_TREND_WIDTH = 64
local INVENTORY_UNIT_VALUE_WIDTH = 116
local INVENTORY_TOTAL_VALUE_WIDTH = 126
local INVENTORY_SORT_ICON_SIZE = 10
local INVENTORY_DEFAULT_SORT_KEY = "totalValue"
local INVENTORY_DEFAULT_SORT_ASCENDING = false
local INVENTORY_FALLBACK_VALUE_SOURCE_ID = "TSM_AUCTIONINGOPNORMAL"
local INVENTORY_CATEGORY_ALL_ID = GoldTracker.INVENTORY_CATEGORY_ALL_ID or "all"
local INVENTORY_SORT_KEYS = {
    demand = true,
    sellRate = true,
    historySamples = true,
    itemName = true,
    quantity = true,
    marketTrend = true,
    unitValue = true,
    totalValue = true,
}
local INVENTORY_CATEGORY_OPTIONS = GoldTracker.INVENTORY_CATEGORY_OPTIONS or {}
local INVENTORY_CATEGORY_BY_ID = GoldTracker.INVENTORY_CATEGORY_BY_ID or {}
local INVENTORY_DETAILS_WINDOW_WIDTH = 760
local INVENTORY_DETAILS_WINDOW_HEIGHT = 580
local INVENTORY_DETAILS_WINDOW_MIN_WIDTH = 640
local INVENTORY_DETAILS_WINDOW_MIN_HEIGHT = 460
local INVENTORY_DETAILS_SOURCE_DROPDOWN_WIDTH = 230
local INVENTORY_DETAILS_GRAPH_LINE_THICKNESS = 2
local INVENTORY_DETAILS_GRAPH_POINT_SIZE = 5
local INVENTORY_DETAILS_AXIS_TICK_COUNT = 5
local INVENTORY_DETAILS_AXIS_LABEL_WIDTH = 86
local INVENTORY_DETAILS_STATS_ROW_HEIGHT = 20
local INVENTORY_DETAILS_STATS_LABEL_WIDTH = 82
local INVENTORY_DETAILS_GRAPH_HOVER_SIZE = 16
local INVENTORY_DETAILS_RARE_SOURCE_ROW_HEIGHT = 22
local INVENTORY_DETAILS_RARE_SOURCE_LIST_HEIGHT = 92
local INVENTORY_DETAILS_MATERIAL_PANEL_HEIGHT = 56
local INVENTORY_DETAILS_STATS_PANEL_HEIGHT = 118
local INVENTORY_DETAILS_GRAPH_BOTTOM_OFFSET = 144
local INVENTORY_DETAILS_SOURCE_BY_VALUE_SOURCE_ID = {
    TSM_DBMARKET = "dbMarket",
    TSM_DBRECENT = "dbRecent",
    TSM_DBMINBUYOUT = "dbMinBuyout",
    TSM_DBREGIONMARKETAVG = "dbRegionMarketAvg",
    TSM_DBHISTORICAL = "dbHistorical",
    TSM_DBREGIONHISTORICAL = "dbRegionHistorical",
    TSM_DBREGIONSALEAVG = "dbRegionSaleAvg",
    TSM_AUCTIONINGOPMIN = "auctioningMin",
    TSM_AUCTIONINGOPNORMAL = "auctioningNormal",
    TSM_AUCTIONINGOPMAX = "auctioningMax",
}
local INVENTORY_DETAILS_VALUE_SOURCE_ID_BY_SOURCE_KEY = {}
for sourceID, sourceKey in pairs(INVENTORY_DETAILS_SOURCE_BY_VALUE_SOURCE_ID) do
    INVENTORY_DETAILS_VALUE_SOURCE_ID_BY_SOURCE_KEY[sourceKey] = sourceID
end
local INVENTORY_DETAILS_PRICE_SOURCES = {
    { key = "selectedUnitValue", label = "Selected Value", color = { 1.0, 0.82, 0.18 } },
    { key = "dbMarket", label = "Market Value", color = { 0.68, 0.96, 0.72 } },
    { key = "dbRecent", label = "Recent Value", color = { 0.72, 0.86, 1.0 } },
    { key = "dbMinBuyout", label = "Min Buyout", color = { 0.84, 0.95, 0.55 } },
    { key = "dbHistorical", label = "Historical Price", color = { 0.92, 0.74, 1.0 } },
    { key = "dbRegionMarketAvg", label = "Region Market Avg", color = { 0.50, 0.88, 0.92 } },
    { key = "dbRegionHistorical", label = "Region Historical Price", color = { 0.82, 0.74, 1.0 } },
    { key = "dbRegionSaleAvg", label = "Region Sale Avg", color = { 0.98, 0.70, 0.42 } },
    { key = "auctioningMin", label = "Auctioning Min", color = { 0.65, 0.95, 0.55 } },
    { key = "auctioningNormal", label = "Auctioning Normal", color = { 1.0, 0.88, 0.40 } },
    { key = "auctioningMax", label = "Auctioning Max", color = { 1.0, 0.58, 0.42 } },
}
local INVENTORY_DETAILS_PRICE_SOURCE_BY_KEY = {}
for _, source in ipairs(INVENTORY_DETAILS_PRICE_SOURCES) do
    INVENTORY_DETAILS_PRICE_SOURCE_BY_KEY[source.key] = source
end

local function CreateInventoryPanel(parent, bg, border)
    return Theme:CreatePanel(parent, bg, border)
end

local function CreateInventoryButton(parent, width, height, text, paletteKey)
    return Theme:CreateButton(parent, width, height, text, paletteKey)
end

local function CreateInventoryHeaderButton(parent, label, width, justifyH)
    local button = CreateFrame("Button", nil, parent)
    button:SetHeight(18)
    if width then
        button:SetWidth(width)
    end
    button:RegisterForClicks("LeftButtonUp")

    local text = button:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    text:SetPoint("TOPLEFT", button, "TOPLEFT", 0, 0)
    text:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -14, 0)
    text:SetJustifyH(justifyH or "LEFT")
    text:SetWordWrap(false)
    text:SetText(label)
    button.text = text

    local sortIcon = button:CreateTexture(nil, "ARTWORK")
    sortIcon:SetSize(INVENTORY_SORT_ICON_SIZE, INVENTORY_SORT_ICON_SIZE)
    sortIcon:SetPoint("RIGHT", button, "RIGHT", 0, 0)
    sortIcon:Hide()
    button.sortIcon = sortIcon

    return button
end

local function AddBagID(bagIDs, seenBagIDs, bagID)
    local normalizedBagID = tonumber(bagID)
    if not normalizedBagID or seenBagIDs[normalizedBagID] then
        return
    end

    seenBagIDs[normalizedBagID] = true
    bagIDs[#bagIDs + 1] = normalizedBagID
end

local function BuildInventoryBagIDs()
    local bagIDs = {}
    local seenBagIDs = {}
    local firstBagID = BACKPACK_CONTAINER or 0
    local lastBagID = NUM_BAG_SLOTS or 4

    for bagID = firstBagID, lastBagID do
        AddBagID(bagIDs, seenBagIDs, bagID)
    end

    if Enum and Enum.BagIndex then
        AddBagID(bagIDs, seenBagIDs, Enum.BagIndex.ReagentBag)
    end
    AddBagID(bagIDs, seenBagIDs, REAGENTBAG_CONTAINER)

    table.sort(bagIDs)
    return bagIDs
end

local function GetInventoryBuildCacheKey(addon, sourceID, minimumQuality)
    local cacheVersion = math.max(0, math.floor(tonumber(addon and addon.inventoryBuildCacheVersion) or 0))
    local normalizedQuality = math.max(0, math.floor(tonumber(minimumQuality) or 0))
    return string.format("%d|%s|%d", cacheVersion, tostring(sourceID or ""), normalizedQuality)
end

function GoldTracker:InvalidateInventoryWindowCache()
    self:InvalidateAuctionableInventoryScanCache()
end

local function GetContainerSlotCount(bagID)
    if C_Container and type(C_Container.GetContainerNumSlots) == "function" then
        return tonumber(C_Container.GetContainerNumSlots(bagID)) or 0
    end
    if type(GetContainerNumSlots) == "function" then
        return tonumber(GetContainerNumSlots(bagID)) or 0
    end
    return 0
end

local function GetContainerSlotInfo(bagID, slotIndex)
    if C_Container and type(C_Container.GetContainerItemInfo) == "function" then
        local info = C_Container.GetContainerItemInfo(bagID, slotIndex)
        if type(info) == "table" then
            return info
        end

        local iconFileID, stackCount, isLocked, quality, isReadable, hasLoot, hyperlink, isFiltered, hasNoValue, itemID, isBound =
            C_Container.GetContainerItemInfo(bagID, slotIndex)
        return {
            iconFileID = iconFileID,
            stackCount = stackCount,
            isLocked = isLocked,
            quality = quality,
            isReadable = isReadable,
            hasLoot = hasLoot,
            hyperlink = hyperlink,
            isFiltered = isFiltered,
            hasNoValue = hasNoValue,
            itemID = itemID,
            isBound = isBound,
        }
    end

    if type(GetContainerItemInfo) == "function" then
        local iconFileID, stackCount, isLocked, quality, isReadable, hasLoot, hyperlink, isFiltered, hasNoValue, itemID, isBound =
            GetContainerItemInfo(bagID, slotIndex)
        return {
            iconFileID = iconFileID,
            stackCount = stackCount,
            isLocked = isLocked,
            quality = quality,
            isReadable = isReadable,
            hasLoot = hasLoot,
            hyperlink = hyperlink,
            isFiltered = isFiltered,
            hasNoValue = hasNoValue,
            itemID = itemID,
            isBound = isBound,
        }
    end

    return nil
end

local function GetContainerSlotLink(bagID, slotIndex, slotInfo)
    if type(slotInfo) == "table" and type(slotInfo.hyperlink) == "string" and slotInfo.hyperlink ~= "" then
        return slotInfo.hyperlink
    end
    if C_Container and type(C_Container.GetContainerItemLink) == "function" then
        return C_Container.GetContainerItemLink(bagID, slotIndex)
    end
    if type(GetContainerItemLink) == "function" then
        return GetContainerItemLink(bagID, slotIndex)
    end
    return nil
end

local function GetItemDisplayData(itemLink, slotInfo)
    local itemName, itemQuality, itemIcon
    if C_Item and type(C_Item.GetItemInfo) == "function" then
        itemName, _, itemQuality, _, _, _, _, _, _, itemIcon = C_Item.GetItemInfo(itemLink)
    elseif type(GetItemInfo) == "function" then
        itemName, _, itemQuality, _, _, _, _, _, _, itemIcon = GetItemInfo(itemLink)
    end

    if not itemIcon and type(slotInfo) == "table" then
        itemIcon = slotInfo.iconFileID
    end

    if not itemIcon and type(GetItemInfoInstant) == "function" then
        itemIcon = select(5, GetItemInfoInstant(itemLink))
    end

    return itemName, itemQuality, itemIcon
end

local function GetInventoryItemMetadata(itemLink)
    local itemType, itemSubType, itemEquipLoc, itemClassID, itemSubclassID, isCraftingReagent
    if C_Item and type(C_Item.GetItemInfo) == "function" then
        _, _, _, _, _, itemType, itemSubType, _, itemEquipLoc, _, _, itemClassID, itemSubclassID, _, _, _,
            isCraftingReagent = C_Item.GetItemInfo(itemLink)
    elseif type(GetItemInfo) == "function" then
        _, _, _, _, _, itemType, itemSubType, _, itemEquipLoc, _, _, itemClassID, itemSubclassID, _, _, _,
            isCraftingReagent = GetItemInfo(itemLink)
    end

    if (not itemClassID or not itemSubclassID or not itemEquipLoc) and type(GetItemInfoInstant) == "function" then
        local _, instantItemType, instantItemSubType, instantItemEquipLoc, _, instantClassID, instantSubclassID =
            GetItemInfoInstant(itemLink)
        itemType = itemType or instantItemType
        itemSubType = itemSubType or instantItemSubType
        itemEquipLoc = itemEquipLoc or instantItemEquipLoc
        itemClassID = itemClassID or instantClassID
        itemSubclassID = itemSubclassID or instantSubclassID
    end

    return {
        itemType = itemType,
        itemSubType = itemSubType,
        itemEquipLoc = itemEquipLoc,
        itemClassID = tonumber(itemClassID),
        itemSubclassID = tonumber(itemSubclassID),
        isCraftingReagent = isCraftingReagent == true,
    }
end

local function InventoryItemClassMatches(itemClassID, enumKey, fallbackID)
    local enumValue = Enum and Enum.ItemClass and Enum.ItemClass[enumKey]
    return tonumber(itemClassID) == tonumber(enumValue or fallbackID)
end

local function NormalizeInventoryCategoryFilter(categoryID)
    if INVENTORY_CATEGORY_BY_ID[categoryID] then
        return categoryID
    end
    return INVENTORY_CATEGORY_ALL_ID
end

local function GetInventoryCategoryOption(categoryID)
    return INVENTORY_CATEGORY_BY_ID[NormalizeInventoryCategoryFilter(categoryID)]
        or INVENTORY_CATEGORY_BY_ID[INVENTORY_CATEGORY_ALL_ID]
end

local function GetInventoryMaterialFarmingSpotData(addon, itemID)
    local normalizedItemID = tonumber(itemID)
    if not normalizedItemID then
        return nil
    end

    local farmingSpots = addon and addon.materialFarmingSpots or NS.MaterialFarmingSpots
    local items = type(farmingSpots) == "table" and farmingSpots.items or nil
    return items and items[math.floor(normalizedItemID + 0.5)] or nil
end

local function GetInventoryItemCategoryID(item)
    if type(item) ~= "table" then
        return "uncategorized"
    end

    local itemType = tostring(item.itemType or "")
    local itemSubType = tostring(item.itemSubType or "")
    if item.isCraftingReagent
        or InventoryItemClassMatches(item.itemClassID, "Tradegoods", 7)
        or itemType == "Trade Goods"
        or itemType == "Tradeskill" then
        return "crafting"
    end

    if InventoryItemClassMatches(item.itemClassID, "Consumable", 0) or itemType == "Consumable" then
        return "consumables"
    end

    if itemSubType == "Cosmetic" or item.itemEquipLoc == "INVTYPE_COSMETIC" then
        return "transmog"
    end

    if InventoryItemClassMatches(item.itemClassID, "Weapon", 2)
        or InventoryItemClassMatches(item.itemClassID, "Armor", 4)
        or itemType == "Weapon"
        or itemType == "Armor" then
        return "armorWeapons"
    end

    return "uncategorized"
end

local function NormalizeMinimumQuality(addon, minimumQuality)
    local normalizedQuality = tonumber(minimumQuality)
    if normalizedQuality then
        normalizedQuality = math.floor(normalizedQuality + 0.5)
    end
    if addon.TRACKED_ITEM_QUALITY_BY_ID[normalizedQuality] then
        return normalizedQuality
    end
    return addon:GetConfiguredMinimumTrackedItemQuality()
end

local function ItemPassesMinimumQuality(itemQuality, minimumQuality)
    local normalizedQuality = tonumber(itemQuality)
    if not normalizedQuality then
        return true
    end
    return math.floor(normalizedQuality + 0.5) >= minimumQuality
end

local function ReadMinimumValueCopper(addon, editBox)
    local rawText = editBox and editBox:GetText() or ""
    rawText = tostring(rawText or ""):gsub(",", ".")
    local goldValue = tonumber(rawText)
    if not goldValue or goldValue < 0 then
        goldValue = 0
    end
    return math.max(0, math.floor((goldValue * addon.COPPER_PER_GOLD) + 0.5))
end

local function FormatGoldInput(addon, copperValue)
    local normalizedCopper = math.max(0, math.floor(tonumber(copperValue) or 0))
    if normalizedCopper % addon.COPPER_PER_GOLD == 0 then
        return tostring(normalizedCopper / addon.COPPER_PER_GOLD)
    end
    return string.format("%.2f", normalizedCopper / addon.COPPER_PER_GOLD)
end

local function ResolveInventoryWindowSource(addon, frame)
    local source = addon.VALUE_SOURCE_BY_ID[frame and frame.valueSourceID]
    if source then
        return source
    end
    return addon:GetAuctionableInventoryValueSource()
end

local function AddInventoryItem(itemsByLink, itemOrder, item)
    local existingItem = itemsByLink[item.itemLink]
    if existingItem then
        existingItem.quantity = existingItem.quantity + item.quantity
        existingItem.totalValue = existingItem.totalValue + item.totalValue
        existingItem.stackCount = existingItem.stackCount + 1
        if not existingItem.bagID and item.bagID then
            existingItem.bagID = item.bagID
            existingItem.slotIndex = item.slotIndex
        end
        existingItem.itemType = existingItem.itemType or item.itemType
        existingItem.itemSubType = existingItem.itemSubType or item.itemSubType
        existingItem.itemEquipLoc = existingItem.itemEquipLoc or item.itemEquipLoc
        existingItem.itemClassID = existingItem.itemClassID or item.itemClassID
        existingItem.itemSubclassID = existingItem.itemSubclassID or item.itemSubclassID
        existingItem.isCraftingReagent = existingItem.isCraftingReagent or item.isCraftingReagent == true
        existingItem.categoryID = existingItem.categoryID or item.categoryID
        existingItem.categoryLabel = existingItem.categoryLabel or item.categoryLabel
        return
    end

    itemsByLink[item.itemLink] = item
    itemOrder[#itemOrder + 1] = item
end

local function FormatInventoryDecimalValue(value, precision)
    local numberValue = tonumber(value)
    if not numberValue or numberValue <= 0 then
        return nil
    end
    return string.format("%." .. tostring(precision or 2) .. "f", numberValue)
end

local function GetInventoryDemandTier(regionSoldPerDay)
    local soldPerDay = tonumber(regionSoldPerDay)
    if not soldPerDay or soldPerDay <= 0 then
        return "unknown", "Unknown", 0.62, 0.66, 0.74
    end
    if soldPerDay >= 50 then
        return "hot", "Hot", 0.52, 1.00, 0.56
    end
    if soldPerDay >= 10 then
        return "fast", "Fast", 0.68, 0.96, 0.72
    end
    if soldPerDay >= 2 then
        return "steady", "Steady", 0.72, 0.86, 1.0
    end
    return "slow", "Slow", 1.0, 0.82, 0.18
end

local function FormatInventorySoldPerDay(regionSoldPerDay)
    local soldPerDay = tonumber(regionSoldPerDay)
    if not soldPerDay or soldPerDay <= 0 then
        return "--"
    end
    if soldPerDay >= 1000 then
        return "999+/d"
    end
    if soldPerDay >= 100 then
        return string.format("%d/d", math.floor(soldPerDay + 0.5))
    end
    if soldPerDay >= 10 then
        return string.format("%.1f/d", soldPerDay)
    end
    return string.format("%.2f/d", soldPerDay)
end

local function FormatInventorySaleRate(regionSaleRate)
    local saleRate = tonumber(regionSaleRate)
    if not saleRate or saleRate <= 0 then
        return "--"
    end

    local percent = saleRate * 100
    if percent >= 100 then
        return "100%"
    end
    if percent >= 10 then
        return string.format("%.0f%%", percent)
    end
    if percent >= 1 then
        return string.format("%.1f%%", percent)
    end
    return string.format("%.2f%%", percent)
end

local function GetInventorySellRateTier(regionSaleRate)
    local saleRate = tonumber(regionSaleRate)
    if not saleRate or saleRate <= 0 then
        return "--", 0.62, 0.66, 0.74
    end
    if saleRate >= 0.50 then
        return "Instant", 0.52, 1.00, 0.56
    end
    if saleRate >= 0.20 then
        return "Fast", 0.68, 0.96, 0.72
    end
    if saleRate >= 0.10 then
        return "Normal", 0.72, 0.86, 1.0
    end
    if saleRate >= 0.03 then
        return "Slow", 1.0, 0.82, 0.18
    end
    return "Very Slow", 1.00, 0.58, 0.42
end

local function FormatInventoryTrendPercent(marketTrendPercent)
    local trend = tonumber(marketTrendPercent)
    if not trend then
        return "--"
    end
    if trend > 999 then
        return "+999%"
    end
    if trend < -999 then
        return "-999%"
    end
    if trend > 0 then
        return string.format("+%d%%", trend)
    end
    return string.format("%d%%", trend)
end

local function GetInventoryTrendColor(marketTrendPercent)
    local trend = tonumber(marketTrendPercent)
    if not trend then
        return 0.62, 0.66, 0.74
    end
    if trend > 0 then
        return 0.52, 1.00, 0.56
    end
    if trend < 0 then
        return 1.00, 0.45, 0.42
    end
    return 0.92, 0.95, 1.0
end

local function FormatInventoryDetailsMoneyText(value, includeCopper)
    local copper = tonumber(value)
    if not copper or copper <= 0 then
        return "--"
    end

    copper = math.floor(copper + 0.5)
    if type(GetCoinTextureString) == "function" then
        return GetCoinTextureString(copper, includeCopper and 12 or 10)
    end
    if type(GetMoneyString) == "function" then
        return GetMoneyString(copper, true)
    end
    return tostring(copper)
end

local function FormatInventoryDetailsTimestamp(timestamp)
    local normalizedTimestamp = tonumber(timestamp)
    if not normalizedTimestamp or normalizedTimestamp <= 0 then
        return "Unknown"
    end
    return date("%Y-%m-%d %H:%M", normalizedTimestamp)
end

local function FormatInventoryDetailsShortTimestamp(timestamp)
    local normalizedTimestamp = tonumber(timestamp)
    if not normalizedTimestamp or normalizedTimestamp <= 0 then
        return "--"
    end
    return date("%m-%d %H:%M", normalizedTimestamp)
end

local function FormatInventoryDetailsWeekday(timestamp)
    local normalizedTimestamp = tonumber(timestamp)
    if not normalizedTimestamp or normalizedTimestamp <= 0 then
        return "--"
    end
    return date("%A", normalizedTimestamp)
end

local function FormatInventoryDetailsPercentChange(changePercent)
    local change = tonumber(changePercent)
    if not change then
        return "--"
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

local function GetInventoryDetailsSourceLabel(sourceKey)
    local source = INVENTORY_DETAILS_PRICE_SOURCE_BY_KEY[sourceKey]
    return source and source.label or "Selected Value"
end

local function GetInventoryDetailsSnapshotValue(snapshot, sourceKey)
    if type(snapshot) ~= "table" or type(sourceKey) ~= "string" then
        return nil
    end

    local value = tonumber(snapshot[sourceKey])
    if value and value > 0 then
        return value
    end

    local mappedSourceID = INVENTORY_DETAILS_VALUE_SOURCE_ID_BY_SOURCE_KEY[sourceKey]
    if mappedSourceID and snapshot.selectedSourceID == mappedSourceID then
        value = tonumber(snapshot.selectedUnitValue)
        if value and value > 0 then
            return value
        end
    end
    return nil
end

local function BuildInventoryDetailsSamples(history, sourceKey)
    local samples = {}
    local snapshots = history and history.snapshots
    if type(snapshots) ~= "table" then
        return samples
    end

    for _, snapshot in ipairs(snapshots) do
        local value = GetInventoryDetailsSnapshotValue(snapshot, sourceKey)
        local timestamp = tonumber(snapshot and snapshot.timestamp) or 0
        if value and timestamp > 0 then
            samples[#samples + 1] = {
                value = value,
                timestamp = timestamp,
                sourceID = snapshot.selectedSourceID,
            }
        end
    end

    table.sort(samples, function(left, right)
        return (tonumber(left and left.timestamp) or 0) < (tonumber(right and right.timestamp) or 0)
    end)

    return samples
end

local function GetInventoryDetailsPreferredSourceKey(row, history)
    local mappedSourceKey = INVENTORY_DETAILS_SOURCE_BY_VALUE_SOURCE_ID[row and row.valueSourceID]
    if mappedSourceKey and #BuildInventoryDetailsSamples(history, mappedSourceKey) > 0 then
        return mappedSourceKey
    end

    if #BuildInventoryDetailsSamples(history, "selectedUnitValue") > 0 then
        return "selectedUnitValue"
    end

    for _, source in ipairs(INVENTORY_DETAILS_PRICE_SOURCES) do
        if #BuildInventoryDetailsSamples(history, source.key) > 0 then
            return source.key
        end
    end

    return "selectedUnitValue"
end

local function BuildInventoryDetailsStats(samples)
    local stats = {
        count = #samples,
        firstValue = nil,
        lastValue = nil,
        minValue = nil,
        maxValue = nil,
        averageValue = nil,
        firstTimestamp = nil,
        lastTimestamp = nil,
        changePercent = nil,
    }
    if #samples == 0 then
        return stats
    end

    local total = 0
    for index, sample in ipairs(samples) do
        local value = tonumber(sample.value) or 0
        if index == 1 then
            stats.firstValue = value
            stats.firstTimestamp = sample.timestamp
            stats.minValue = value
            stats.maxValue = value
        end
        stats.lastValue = value
        stats.lastTimestamp = sample.timestamp
        stats.minValue = math.min(stats.minValue or value, value)
        stats.maxValue = math.max(stats.maxValue or value, value)
        total = total + value
    end

    stats.averageValue = total / #samples
    if stats.firstValue and stats.firstValue > 0 and stats.lastValue then
        stats.changePercent = ((stats.lastValue - stats.firstValue) * 100) / stats.firstValue
    end

    return stats
end

local function GetInventoryUnitValue(addon, primarySourceID, itemLink)
    local unitValue, resolvedSourceID, resolvedSourceLabel = addon:GetItemUnitValueFromSource(primarySourceID, itemLink)
    unitValue = tonumber(unitValue) or 0

    if unitValue > 0 or primarySourceID == INVENTORY_FALLBACK_VALUE_SOURCE_ID then
        return unitValue, resolvedSourceID or primarySourceID, resolvedSourceLabel
    end

    local fallbackValue, fallbackSourceID, fallbackSourceLabel =
        addon:GetItemUnitValueFromSource(INVENTORY_FALLBACK_VALUE_SOURCE_ID, itemLink)
    fallbackValue = tonumber(fallbackValue) or 0
    if fallbackValue > 0 then
        return fallbackValue, fallbackSourceID or INVENTORY_FALLBACK_VALUE_SOURCE_ID, fallbackSourceLabel
    end

    return unitValue, resolvedSourceID or primarySourceID, resolvedSourceLabel
end

local function GetInventoryRegionalDemandData(addon, itemLink, demandCache)
    if type(itemLink) ~= "string" or itemLink == "" then
        return nil
    end

    local cacheKey = itemLink
    if type(demandCache) == "table" and demandCache[cacheKey] then
        return demandCache[cacheKey]
    end

    local regionSoldPerDay
    local regionSaleRate
    local marketValue
    local historicalValue
    if type(addon.GetTSMRawCustomValue) == "function" then
        regionSoldPerDay = addon:GetTSMRawCustomValue("DBRegionSoldPerDay", itemLink)
        regionSaleRate = addon:GetTSMRawCustomValue("DBRegionSaleRate", itemLink)
        marketValue = addon:GetTSMRawCustomValue("DBMarket", itemLink)
        historicalValue = addon:GetTSMRawCustomValue("DBHistorical", itemLink)
    end

    local tierKey, tierLabel, r, g, b = GetInventoryDemandTier(regionSoldPerDay)
    local marketTrendPercent
    if marketValue and historicalValue and historicalValue > 0 then
        local rawTrend = ((marketValue - historicalValue) * 100) / historicalValue
        if rawTrend >= 0 then
            marketTrendPercent = math.floor(rawTrend + 0.5)
        else
            marketTrendPercent = math.ceil(rawTrend - 0.5)
        end
    end

    local demandData = {
        regionSoldPerDay = regionSoldPerDay,
        regionSaleRate = regionSaleRate,
        marketValue = marketValue,
        historicalValue = historicalValue,
        marketTrendPercent = marketTrendPercent,
        demandTier = tierKey,
        demandLabel = tierLabel,
        demandColorR = r,
        demandColorG = g,
        demandColorB = b,
    }
    if type(demandCache) == "table" then
        demandCache[cacheKey] = demandData
    end
    return demandData
end

local function NormalizeInventorySortKey(sortKey)
    if INVENTORY_SORT_KEYS[sortKey] then
        return sortKey
    end
    return INVENTORY_DEFAULT_SORT_KEY
end

local function GetInventoryItemNameSortValue(item)
    return string.lower(tostring(item and (item.itemName or item.itemLink) or ""))
end

local function CompareInventoryItemsByName(left, right)
    local leftName = GetInventoryItemNameSortValue(left)
    local rightName = GetInventoryItemNameSortValue(right)
    if leftName ~= rightName then
        return leftName < rightName
    end
    return tostring(left and left.itemLink or "") < tostring(right and right.itemLink or "")
end

local function GetInventorySortValue(item, sortKey)
    if sortKey == "itemName" then
        return GetInventoryItemNameSortValue(item)
    end
    if sortKey == "demand" then
        return tonumber(item and item.regionSoldPerDay) or 0
    end
    if sortKey == "sellRate" then
        return tonumber(item and item.regionSaleRate) or 0
    end
    if sortKey == "historySamples" then
        return tonumber(item and item.marketHistorySampleCount) or 0
    end
    if sortKey == "quantity" then
        return tonumber(item and item.quantity) or 0
    end
    if sortKey == "marketTrend" then
        return tonumber(item and item.marketTrendPercent) or -1000000
    end
    if sortKey == "unitValue" then
        return tonumber(item and item.unitValue) or 0
    end
    return tonumber(item and item.totalValue) or 0
end

local function SortInventoryItems(items, sortKey, sortAscending)
    local normalizedSortKey = NormalizeInventorySortKey(sortKey)
    local ascending = sortAscending == true

    table.sort(items, function(left, right)
        local leftValue = GetInventorySortValue(left, normalizedSortKey)
        local rightValue = GetInventorySortValue(right, normalizedSortKey)
        if leftValue ~= rightValue then
            if ascending then
                return leftValue < rightValue
            end
            return leftValue > rightValue
        end

        if normalizedSortKey ~= "itemName" then
            if normalizedSortKey == "demand" or normalizedSortKey == "sellRate" then
                local leftRate = tonumber(left and left.regionSaleRate) or 0
                local rightRate = tonumber(right and right.regionSaleRate) or 0
                if leftRate ~= rightRate then
                    return leftRate > rightRate
                end

                local leftDemand = tonumber(left and left.regionSoldPerDay) or 0
                local rightDemand = tonumber(right and right.regionSoldPerDay) or 0
                if leftDemand ~= rightDemand then
                    return leftDemand > rightDemand
                end

                local leftTotal = tonumber(left and left.totalValue) or 0
                local rightTotal = tonumber(right and right.totalValue) or 0
                if leftTotal ~= rightTotal then
                    return leftTotal > rightTotal
                end
            end

            return CompareInventoryItemsByName(left, right)
        end

        local leftTotal = tonumber(left and left.totalValue) or 0
        local rightTotal = tonumber(right and right.totalValue) or 0
        if leftTotal ~= rightTotal then
            return leftTotal > rightTotal
        end

        return tostring(left and left.itemLink or "") < tostring(right and right.itemLink or "")
    end)
end

local function BuildInventoryDisplayRows(items, categoryFilterID, groupByCategory)
    local normalizedCategoryID = NormalizeInventoryCategoryFilter(categoryFilterID)
    if normalizedCategoryID ~= INVENTORY_CATEGORY_ALL_ID or groupByCategory ~= true then
        return items
    end

    local itemsByCategory = {}
    for _, item in ipairs(items or {}) do
        local categoryID = GetInventoryItemCategoryID(item)
        itemsByCategory[categoryID] = itemsByCategory[categoryID] or {}
        itemsByCategory[categoryID][#itemsByCategory[categoryID] + 1] = item
    end

    local displayRows = {}
    local categoryOrder = type(GoldTracker.GetInventoryCategoryOrder) == "function"
        and GoldTracker:GetInventoryCategoryOrder()
        or GoldTracker.INVENTORY_CATEGORY_DEFAULT_ORDER
        or {}
    for _, categoryID in ipairs(categoryOrder) do
        local categoryItems = itemsByCategory[categoryID]
        if categoryItems and #categoryItems > 0 then
            local category = GetInventoryCategoryOption(categoryID)
            displayRows[#displayRows + 1] = {
                isCategoryDivider = true,
                categoryID = categoryID,
                categoryLabel = category and category.label or "Uncategorized",
                itemCount = #categoryItems,
            }
            for _, item in ipairs(categoryItems) do
                displayRows[#displayRows + 1] = item
            end
        end
    end

    return displayRows
end

local function CreateInventoryItemLocation(bagID, slotIndex)
    if not ItemLocation or type(ItemLocation.CreateFromBagAndSlot) ~= "function" then
        return nil
    end

    local ok, itemLocation = pcall(ItemLocation.CreateFromBagAndSlot, ItemLocation, bagID, slotIndex)
    if ok and itemLocation then
        return itemLocation
    end

    return nil
end

local function FindInventoryItemLocationForRow(row)
    if type(row) ~= "table" or type(row.itemLink) ~= "string" or row.itemLink == "" then
        return nil
    end

    local function MatchesRowItem(bagID, slotIndex)
        local slotInfo = GetContainerSlotInfo(bagID, slotIndex)
        local itemLink = GetContainerSlotLink(bagID, slotIndex, slotInfo)
        if itemLink ~= row.itemLink then
            return nil
        end
        if GoldTracker:IsBagItemBindingRestricted(bagID, slotIndex, itemLink, slotInfo) then
            return nil
        end

        return CreateInventoryItemLocation(bagID, slotIndex)
    end

    if row.bagID and row.slotIndex then
        local itemLocation = MatchesRowItem(row.bagID, row.slotIndex)
        if itemLocation then
            return itemLocation
        end
    end

    for _, bagID in ipairs(BuildInventoryBagIDs()) do
        local slotCount = GetContainerSlotCount(bagID)
        for slotIndex = 1, slotCount do
            local itemLocation = MatchesRowItem(bagID, slotIndex)
            if itemLocation then
                row.bagID = bagID
                row.slotIndex = slotIndex
                return itemLocation
            end
        end
    end

    return nil
end

local function GetAuctionHouseFrame()
    return _G.AuctionHouseFrame
end

local function TryAuctionHouseMethod(owner, methodName, ...)
    if not owner or type(owner[methodName]) ~= "function" then
        return false
    end

    local ok, result = pcall(owner[methodName], owner, ...)
    return ok and result ~= false
end

local function SetAuctionHouseDisplayMode(modeKey)
    local auctionHouseFrame = GetAuctionHouseFrame()
    local displayMode = _G.AuctionHouseFrameDisplayMode
    if not auctionHouseFrame or not displayMode or not displayMode[modeKey] then
        return
    end

    TryAuctionHouseMethod(auctionHouseFrame, "SetDisplayMode", displayMode[modeKey])
end

local function IsAuctionHouseCommodity(itemLocation)
    if type(C_AuctionHouse) ~= "table" or type(C_AuctionHouse.GetItemCommodityStatus) ~= "function" then
        return false
    end

    local ok, status = pcall(C_AuctionHouse.GetItemCommodityStatus, itemLocation)
    if not ok then
        return false
    end

    local commodityStatus = Enum and Enum.ItemCommodityStatus
    if commodityStatus then
        if status == commodityStatus.Commodity then
            return true
        end
        if status == commodityStatus.Item then
            return false
        end
    end

    return status == 2
end

local function TryLoadAuctionHouseSellFrame(itemLocation, preferCommodity)
    local auctionHouseFrame = GetAuctionHouseFrame()
    if not auctionHouseFrame then
        return false
    end

    if TryAuctionHouseMethod(auctionHouseFrame, "SetPostItem", itemLocation) then
        return true
    end

    if preferCommodity then
        SetAuctionHouseDisplayMode("CommoditiesSell")
        if TryAuctionHouseMethod(auctionHouseFrame.CommoditiesSellFrame, "SetItem", itemLocation) then
            return true
        end

        SetAuctionHouseDisplayMode("ItemSell")
        return TryAuctionHouseMethod(auctionHouseFrame.ItemSellFrame, "SetItem", itemLocation)
    end

    SetAuctionHouseDisplayMode("ItemSell")
    if TryAuctionHouseMethod(auctionHouseFrame.ItemSellFrame, "SetItem", itemLocation) then
        return true
    end

    SetAuctionHouseDisplayMode("CommoditiesSell")
    return TryAuctionHouseMethod(auctionHouseFrame.CommoditiesSellFrame, "SetItem", itemLocation)
end

function GoldTracker:LoadInventoryItemIntoAuctionHouse(row)
    if type(row) ~= "table" then
        return false
    end

    local auctionHouseFrame = GetAuctionHouseFrame()
    if not auctionHouseFrame or (auctionHouseFrame.IsShown and not auctionHouseFrame:IsShown()) then
        self:Print("Open the Auction House first, then right-click an auctionable inventory row.")
        return false
    end

    local itemLocation = FindInventoryItemLocationForRow(row)
    if not itemLocation then
        self:Print("Could not find that item in your bags. Refresh the auctionable inventory and try again.")
        return false
    end

    if TryLoadAuctionHouseSellFrame(itemLocation, IsAuctionHouseCommodity(itemLocation)) then
        self:Print(string.format("Loaded %s into the Auction House sell tab.", tostring(row.itemLink or "item")))
        return true
    end

    self:Print("Could not load that item into the Auction House. Try opening the Sell tab and right-clicking it again.")
    return false
end

local function HideInventoryDetailsGraphElement(element)
    if element and type(element.Hide) == "function" then
        element:Hide()
    end
end

local function GetInventoryDetailsGraphPoint(canvas, index)
    canvas.points = canvas.points or {}
    local point = canvas.points[index]
    if point then
        return point
    end

    point = canvas:CreateTexture(nil, "OVERLAY")
    point:SetSize(INVENTORY_DETAILS_GRAPH_POINT_SIZE, INVENTORY_DETAILS_GRAPH_POINT_SIZE)
    canvas.points[index] = point
    return point
end

local function ShowInventoryDetailsGraphTooltip(target)
    local data = target and target.tooltipData
    if type(data) ~= "table" then
        return
    end

    GameTooltip:SetOwner(target, "ANCHOR_CURSOR")
    GameTooltip:AddLine(FormatInventoryDetailsMoneyText(data.value, true), 0.88, 0.92, 1.0)
    GameTooltip:AddLine(FormatInventoryDetailsTimestamp(data.timestamp), 0.72, 0.86, 1.0)
    GameTooltip:Show()
end

local function GetInventoryDetailsGraphHitTarget(canvas, index)
    canvas.hitTargets = canvas.hitTargets or {}
    local target = canvas.hitTargets[index]
    if target then
        return target
    end

    target = CreateFrame("Frame", nil, canvas)
    target:SetSize(INVENTORY_DETAILS_GRAPH_HOVER_SIZE, INVENTORY_DETAILS_GRAPH_HOVER_SIZE)
    target:EnableMouse(true)
    target:SetFrameLevel((canvas:GetFrameLevel() or 0) + 10)
    target:SetScript("OnEnter", ShowInventoryDetailsGraphTooltip)
    target:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)
    canvas.hitTargets[index] = target
    return target
end

local function GetInventoryDetailsGraphLine(canvas, index)
    canvas.lines = canvas.lines or {}
    local line = canvas.lines[index]
    if line then
        return line
    end

    if type(canvas.CreateLine) ~= "function" then
        return nil
    end

    line = canvas:CreateLine(nil, "ARTWORK")
    if line and line.SetThickness then
        line:SetThickness(INVENTORY_DETAILS_GRAPH_LINE_THICKNESS)
    end
    canvas.lines[index] = line
    return line
end

local function ColorInventoryDetailsGraphElement(element, color, alpha)
    if not element then
        return
    end

    local r = color and color[1] or 1.0
    local g = color and color[2] or 0.82
    local b = color and color[3] or 0.18
    local a = alpha or 1
    if type(element.SetColorTexture) == "function" then
        element:SetColorTexture(r, g, b, a)
    elseif type(element.SetVertexColor) == "function" then
        element:SetVertexColor(r, g, b, a)
    end
end

local function RefreshInventoryDetailsGraph(addon, frame, samples, source)
    local canvas = frame and frame.graphCanvas
    if not canvas then
        return
    end

    samples = type(samples) == "table" and samples or {}
    source = type(source) == "table" and source or INVENTORY_DETAILS_PRICE_SOURCES[1]
    local width = math.max(1, math.floor(tonumber(canvas:GetWidth()) or 1))
    local height = math.max(1, math.floor(tonumber(canvas:GetHeight()) or 1))

    local minValue
    local maxValue
    for _, sample in ipairs(samples) do
        local value = tonumber(sample and sample.value)
        if value then
            minValue = minValue and math.min(minValue, value) or value
            maxValue = maxValue and math.max(maxValue, value) or value
        end
    end

    local hasSamples = #samples > 0 and minValue ~= nil and maxValue ~= nil
    if frame.graphEmptyText then
        if hasSamples then
            frame.graphEmptyText:Hide()
        else
            frame.graphEmptyText:SetText("No saved snapshots for " .. GetInventoryDetailsSourceLabel(source.key) .. ".")
            frame.graphEmptyText:Show()
        end
    end

    for index = 1, INVENTORY_DETAILS_AXIS_TICK_COUNT do
        local fraction = INVENTORY_DETAILS_AXIS_TICK_COUNT == 1 and 0 or ((index - 1) / (INVENTORY_DETAILS_AXIS_TICK_COUNT - 1))
        local y = fraction * height
        local labelY = math.max(7, math.min(height - 7, y))
        local gridLine = frame.graphGridLines and frame.graphGridLines[index]
        if gridLine then
            gridLine:ClearAllPoints()
            gridLine:SetPoint("LEFT", canvas, "BOTTOMLEFT", 0, y)
            gridLine:SetPoint("RIGHT", canvas, "BOTTOMRIGHT", 0, y)
            gridLine:Show()
        end

        local axisLabel = frame.graphAxisLabels and frame.graphAxisLabels[index]
        if axisLabel then
            local labelValue = "--"
            if hasSamples then
                labelValue = FormatInventoryDetailsMoneyText(minValue + ((maxValue - minValue) * fraction))
            end
            axisLabel:ClearAllPoints()
            axisLabel:SetPoint("RIGHT", canvas, "BOTTOMLEFT", -10, labelY)
            axisLabel:SetText(labelValue)
            axisLabel:Show()
        end
    end
    if frame.graphStartText then
        frame.graphStartText:SetText(hasSamples and FormatInventoryDetailsShortTimestamp(samples[1].timestamp) or "--")
    end
    if frame.graphStartDayText then
        frame.graphStartDayText:SetText(hasSamples and FormatInventoryDetailsWeekday(samples[1].timestamp) or "--")
    end
    if frame.graphMiddleText then
        local middleSample = hasSamples and samples[math.max(1, math.floor((#samples + 1) / 2))] or nil
        frame.graphMiddleText:SetText(middleSample and FormatInventoryDetailsShortTimestamp(middleSample.timestamp) or "--")
        if frame.graphMiddleDayText then
            frame.graphMiddleDayText:SetText(middleSample and FormatInventoryDetailsWeekday(middleSample.timestamp) or "--")
        end
    end
    if frame.graphEndText then
        frame.graphEndText:SetText(hasSamples and FormatInventoryDetailsShortTimestamp(samples[#samples].timestamp) or "--")
    end
    if frame.graphEndDayText then
        frame.graphEndDayText:SetText(hasSamples and FormatInventoryDetailsWeekday(samples[#samples].timestamp) or "--")
    end

    for _, point in ipairs(canvas.points or {}) do
        HideInventoryDetailsGraphElement(point)
    end
    for _, target in ipairs(canvas.hitTargets or {}) do
        HideInventoryDetailsGraphElement(target)
    end
    for _, line in ipairs(canvas.lines or {}) do
        HideInventoryDetailsGraphElement(line)
    end

    if not hasSamples then
        return
    end

    local range = maxValue - minValue
    if range <= 0 then
        range = 1
    end

    local plottedPoints = {}
    for index, sample in ipairs(samples) do
        local value = tonumber(sample.value) or minValue
        local x
        if #samples == 1 then
            x = width / 2
        else
            x = ((index - 1) / (#samples - 1)) * width
        end
        local y
        if maxValue == minValue then
            y = height / 2
        else
            y = ((value - minValue) / range) * height
        end
        x = math.max(0, math.min(width, x))
        y = math.max(0, math.min(height, y))
        plottedPoints[index] = { x = x, y = y }

        local point = GetInventoryDetailsGraphPoint(canvas, index)
        ColorInventoryDetailsGraphElement(point, source.color, 1)
        point:ClearAllPoints()
        point:SetPoint("CENTER", canvas, "BOTTOMLEFT", x, y)
        point:Show()

        local hitTarget = GetInventoryDetailsGraphHitTarget(canvas, index)
        hitTarget.tooltipData = {
            value = value,
            timestamp = sample.timestamp,
        }
        hitTarget:ClearAllPoints()
        hitTarget:SetPoint("CENTER", canvas, "BOTTOMLEFT", x, y)
        hitTarget:Show()
    end

    for index = 2, #plottedPoints do
        local previous = plottedPoints[index - 1]
        local current = plottedPoints[index]
        local line = GetInventoryDetailsGraphLine(canvas, index - 1)
        if line and line.SetStartPoint and line.SetEndPoint then
            ColorInventoryDetailsGraphElement(line, source.color, 0.92)
            line:SetStartPoint("BOTTOMLEFT", canvas, previous.x, previous.y)
            line:SetEndPoint("BOTTOMLEFT", canvas, current.x, current.y)
            line:Show()
        end
    end
end

local function UpdateInventoryDetailsSourceDropdown(frame)
    if not frame or not frame.sourceDropdown then
        return
    end
    local sourceKey = frame.selectedSourceKey or "selectedUnitValue"
    UIDropDownMenu_SetSelectedValue(frame.sourceDropdown, sourceKey)
    UIDropDownMenu_SetText(frame.sourceDropdown, GetInventoryDetailsSourceLabel(sourceKey))
end

local function SetInventoryDetailsStatField(frame, key, value, r, g, b)
    local field = frame and frame.statsFields and frame.statsFields[key]
    if not field or not field.valueText then
        return
    end

    field.valueText:SetText(value or "--")
    field.valueText:SetTextColor(r or 0.88, g or 0.92, b or 1.0)
end

local function UpdateInventoryDetailsStatsFields(frame, stats, sourceLabel)
    if not frame or not frame.statsFields then
        return false
    end

    stats = type(stats) == "table" and stats or {}
    local count = tonumber(stats.count) or 0
    local neutralR, neutralG, neutralB = 0.88, 0.92, 1.0
    local mutedR, mutedG, mutedB = 0.62, 0.66, 0.74
    SetInventoryDetailsStatField(frame, "source", sourceLabel or "Unknown", neutralR, neutralG, neutralB)
    SetInventoryDetailsStatField(frame, "snapshots", tostring(count), neutralR, neutralG, neutralB)

    if count <= 0 then
        for _, key in ipairs({ "firstValue", "firstSeen", "latestValue", "latestSeen", "lowest", "highest", "average", "change" }) do
            SetInventoryDetailsStatField(frame, key, "--", mutedR, mutedG, mutedB)
        end
        return true
    end

    local changeText = FormatInventoryDetailsPercentChange(stats.changePercent)
    local changeR, changeG, changeB = GetInventoryTrendColor(stats.changePercent)
    SetInventoryDetailsStatField(frame, "firstValue", FormatInventoryDetailsMoneyText(stats.firstValue, true), neutralR, neutralG, neutralB)
    SetInventoryDetailsStatField(frame, "firstSeen", FormatInventoryDetailsTimestamp(stats.firstTimestamp), neutralR, neutralG, neutralB)
    SetInventoryDetailsStatField(frame, "latestValue", FormatInventoryDetailsMoneyText(stats.lastValue, true), neutralR, neutralG, neutralB)
    SetInventoryDetailsStatField(frame, "latestSeen", FormatInventoryDetailsTimestamp(stats.lastTimestamp), neutralR, neutralG, neutralB)
    SetInventoryDetailsStatField(frame, "lowest", FormatInventoryDetailsMoneyText(stats.minValue, true), neutralR, neutralG, neutralB)
    SetInventoryDetailsStatField(frame, "highest", FormatInventoryDetailsMoneyText(stats.maxValue, true), neutralR, neutralG, neutralB)
    SetInventoryDetailsStatField(frame, "average", FormatInventoryDetailsMoneyText(stats.averageValue, true), neutralR, neutralG, neutralB)
    SetInventoryDetailsStatField(frame, "change", changeText, changeR, changeG, changeB)
    return true
end

local function BuildInventoryDetailsWowheadItemURL(itemID)
    local normalizedItemID = tonumber(itemID)
    if not normalizedItemID then
        return ""
    end
    return string.format("https://www.wowhead.com/item=%d", math.floor(normalizedItemID + 0.5))
end

local function BuildInventoryDetailsWowheadNpcURL(npcID)
    local normalizedNpcID = tonumber(npcID)
    if not normalizedNpcID then
        return ""
    end
    return string.format("https://www.wowhead.com/npc=%d", math.floor(normalizedNpcID + 0.5))
end

local function BuildInventoryDetailsWowheadSearchURL(text)
    if type(text) ~= "string" or text == "" then
        return ""
    end
    local query = string.gsub(text, "%%", "%%25")
    query = string.gsub(query, "%s+", "+")
    query = string.gsub(query, "'", "%%27")
    query = string.gsub(query, "&", "%%26")
    return "https://www.wowhead.com/search?q=" .. query
end

local function SetInventoryDetailsEditBoxText(editBox, text)
    if not editBox then
        return
    end

    editBox:SetText(text or "")
    editBox:SetCursorPosition(0)
    editBox:ClearFocus()
end

local function HasInventoryDetailsRareSources(itemData)
    return type(itemData and itemData.rareSources) == "table" and #itemData.rareSources > 0
end

local function GetInventoryDetailsMaterialProfessionID(itemData)
    local professionIDs = itemData and itemData.materialProfessionIDs
    if type(professionIDs) == "table" then
        for _, professionID in ipairs(professionIDs) do
            if type(professionID) == "string" and professionID ~= "" then
                return professionID
            end
        end
    end
    return type(itemData and itemData.materialProfessionID) == "string" and itemData.materialProfessionID or nil
end

local function GetInventoryDetailsProfessionLabel(addon, professionID)
    if type(addon.GetCraftingFarmingProfessionOptions) == "function" then
        for _, option in ipairs(addon:GetCraftingFarmingProfessionOptions() or {}) do
            if option and option.id == professionID then
                return option.label
            end
        end
    end
    return tostring(professionID or "Unknown")
end

local function UpdateInventoryDetailsMaterialProfessionDropdown(addon, frame, itemData)
    if not frame or not frame.materialProfessionDropdown then
        return
    end

    local professionID = GetInventoryDetailsMaterialProfessionID(itemData)
    UIDropDownMenu_SetSelectedValue(frame.materialProfessionDropdown, professionID)
    UIDropDownMenu_SetText(frame.materialProfessionDropdown, GetInventoryDetailsProfessionLabel(addon, professionID))
end

local function GetInventoryDetailsRareSourceCoordinateText(source)
    local locations = source and source.locations
    local location = type(locations) == "table" and locations[1] or nil
    local x = tonumber(location and location.x)
    local y = tonumber(location and location.y)
    if not x or not y then
        return "Waypoint"
    end
    if x >= 0 and x <= 1 then
        x = x * 100
    end
    if y >= 0 and y <= 1 then
        y = y * 100
    end
    return string.format("%.1f,%.1f", x, y)
end

local function GetInventoryDetailsRareSourceRow(frame, index)
    if not frame or not frame.rareSourcesContent then
        return nil
    end

    frame.rareSourceRows = frame.rareSourceRows or {}
    local row = frame.rareSourceRows[index]
    if row then
        return row
    end

    row = CreateFrame("Frame", nil, frame.rareSourcesContent)
    row:SetHeight(INVENTORY_DETAILS_RARE_SOURCE_ROW_HEIGHT)

    local background = row:CreateTexture(nil, "BACKGROUND")
    background:SetAllPoints(row)
    row.background = background

    local rareText = row:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    rareText:SetPoint("LEFT", row, "LEFT", 6, 0)
    rareText:SetWidth(190)
    rareText:SetJustifyH("LEFT")
    rareText:SetWordWrap(false)
    row.rareText = rareText

    local locationText = row:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    locationText:SetPoint("LEFT", rareText, "RIGHT", 8, 0)
    locationText:SetPoint("RIGHT", row, "RIGHT", -112, 0)
    locationText:SetJustifyH("LEFT")
    locationText:SetWordWrap(false)
    row.locationText = locationText

    local waypointButton = CreateInventoryButton(row, 96, 18, "Waypoint", "neutral")
    waypointButton:SetPoint("RIGHT", row, "RIGHT", -6, 0)
    waypointButton:SetScript("OnClick", function(self)
        local parent = self:GetParent()
        if parent and parent.sourceData and type(GoldTracker.SetRareFarmingWaypoint) == "function" then
            GoldTracker:SetRareFarmingWaypoint(parent.sourceData)
        end
    end)
    row.waypointButton = waypointButton

    frame.rareSourceRows[index] = row
    return row
end

local function RefreshInventoryDetailsRareSources(addon, frame, sources)
    if not frame or not frame.rareSourcesScrollFrame or not frame.rareSourcesContent then
        return
    end

    local rareSources = type(sources) == "table" and sources or {}
    local contentWidth = frame.rareSourcesScrollFrame and math.max(1, math.floor(frame.rareSourcesScrollFrame:GetWidth() or 1)) or 1
    frame.rareSourcesContent:SetWidth(contentWidth)
    for index, source in ipairs(rareSources) do
        local row = GetInventoryDetailsRareSourceRow(frame, index)
        if row then
            row.sourceData = source
            row:ClearAllPoints()
            row:SetPoint("TOPLEFT", frame.rareSourcesContent, "TOPLEFT", 0, -((index - 1) * INVENTORY_DETAILS_RARE_SOURCE_ROW_HEIGHT))
            row:SetPoint("TOPRIGHT", frame.rareSourcesContent, "TOPRIGHT", 0, -((index - 1) * INVENTORY_DETAILS_RARE_SOURCE_ROW_HEIGHT))
            row.rareText:SetText(source.rareName or (source.npcID and ("Rare " .. tostring(source.npcID)) or "Unknown rare"))
            row.locationText:SetText(source.locationLabel or "Unknown location")
            row.waypointButton:SetText(GetInventoryDetailsRareSourceCoordinateText(source))
            row.waypointButton:SetEnabled(type(addon.SetRareFarmingWaypoint) == "function")
            row.background:SetColorTexture(1, 1, 1, index % 2 == 0 and 0.045 or 0.022)
            row:Show()
        end
    end

    for index = #rareSources + 1, #(frame.rareSourceRows or {}) do
        frame.rareSourceRows[index]:Hide()
    end
    frame.rareSourcesContent:SetHeight(math.max(1, #rareSources * INVENTORY_DETAILS_RARE_SOURCE_ROW_HEIGHT))
end

function GoldTracker:RefreshInventoryItemDetailsWindow()
    local frame = self.inventoryItemDetailsFrame
    if not frame or not frame.itemData then
        return
    end

    local itemData = frame.itemData
    local itemLink = itemData.itemLink
    local itemID = itemData.itemID
    local npcID = itemData.npcID
    local bossName = itemData.bossName
    local instanceName = itemData.instanceName
    local itemKey, history
    if type(self.GetMarketHistoryForItem) == "function" then
        itemKey, history = self:GetMarketHistoryForItem(itemLink, itemID)
    end
    frame.marketHistoryItemKey = itemKey
    frame.marketHistory = history

    if not INVENTORY_DETAILS_PRICE_SOURCE_BY_KEY[frame.selectedSourceKey] then
        frame.selectedSourceKey = GetInventoryDetailsPreferredSourceKey(itemData, history)
    end

    local source = INVENTORY_DETAILS_PRICE_SOURCE_BY_KEY[frame.selectedSourceKey] or INVENTORY_DETAILS_PRICE_SOURCES[1]
    local samples = BuildInventoryDetailsSamples(history, source.key)
    local stats = BuildInventoryDetailsStats(samples)
    UpdateInventoryDetailsSourceDropdown(frame)

    if frame.headerTitleText then
        frame.headerTitleText:SetText("Item Market Details")
    end
    if frame.itemIcon then
        if itemData.icon then
            frame.itemIcon:SetTexture(itemData.icon)
            frame.itemIcon:Show()
        else
            frame.itemIcon:Hide()
        end
    end
    if frame.itemText then
        frame.itemText:SetText(itemLink or itemData.itemName or (itemID and ("Item " .. tostring(itemID)) or "Unknown item"))
    end
    if frame.metaText then
        local historyCount = type(history and history.snapshots) == "table" and #history.snapshots or 0
        frame.metaText:SetText(string.format(
            "%d total snapshot%s saved%s",
            historyCount,
            historyCount == 1 and "" or "s",
            itemKey and (" for " .. tostring(itemKey)) or ""
        ))
    end
    -- Every item details surface should expose a copyable Wowhead item URL when an item ID is available.
    local hasItemWowheadLink = tonumber(itemID) ~= nil
    local hasSourceWowheadLink = npcID ~= nil or type(bossName) == "string" or type(instanceName) == "string"
    local showRareSources = HasInventoryDetailsRareSources(itemData)
    local showWowheadLinks = hasItemWowheadLink or showRareSources or hasSourceWowheadLink
    if frame.wowheadPanel then
        frame.wowheadPanel:SetShown(showWowheadLinks)
        frame.wowheadPanel:SetHeight(showRareSources and 164 or 56)
    end
    if showWowheadLinks then
        if frame.wowheadTitleText then
            frame.wowheadTitleText:SetText("Wowhead links")
        end
        if frame.wowheadRareLabelText then
            frame.wowheadRareLabelText:SetText((npcID or showRareSources) and "Rare" or "Boss / Instance")
        end
        if frame.wowheadRareEditBox then
            frame.wowheadRareEditBox:SetShown(showRareSources or hasSourceWowheadLink)
        end
        if frame.wowheadRareLabelText then
            frame.wowheadRareLabelText:SetShown(showRareSources or hasSourceWowheadLink)
        end
        SetInventoryDetailsEditBoxText(frame.wowheadItemEditBox, BuildInventoryDetailsWowheadItemURL(itemID))
        if npcID or showRareSources then
            local source = showRareSources and itemData.rareSources[1] or nil
            SetInventoryDetailsEditBoxText(frame.wowheadRareEditBox, BuildInventoryDetailsWowheadNpcURL(npcID or source.npcID))
        elseif hasSourceWowheadLink then
            SetInventoryDetailsEditBoxText(frame.wowheadRareEditBox, BuildInventoryDetailsWowheadSearchURL((bossName or "") .. " " .. (instanceName or "")))
        else
            SetInventoryDetailsEditBoxText(frame.wowheadRareEditBox, "")
        end
    end
    if frame.rareSourcesTitleText then
        frame.rareSourcesTitleText:SetShown(showRareSources)
        frame.rareSourcesTitleText:SetText(showRareSources and string.format("Rare sources (%d)", #itemData.rareSources) or "")
    end
    if frame.rareSourcesScrollFrame then
        frame.rareSourcesScrollFrame:SetShown(showRareSources)
    end
    local showMaterialControls = itemData.materialContext == "craftingFarming"
        and itemData.materialExpansionID ~= nil
        and type(self.SetCraftingFarmingItemProfession) == "function"
    if frame.materialPanel then
        if frame.bodyPanel and frame.materialPanel.ClearAllPoints and frame.materialPanel.SetPoint then
            frame.materialPanel:ClearAllPoints()
            local materialTopOffset = showRareSources and -230 or -122
            frame.materialPanel:SetPoint("TOPLEFT", frame.bodyPanel, "TOPLEFT", 14, materialTopOffset)
            frame.materialPanel:SetPoint("TOPRIGHT", frame.bodyPanel, "TOPRIGHT", -14, materialTopOffset)
        end
        if frame.materialPanel.SetHeight then
            frame.materialPanel:SetHeight(INVENTORY_DETAILS_MATERIAL_PANEL_HEIGHT)
        end
        if frame.materialPanel.SetShown then
            frame.materialPanel:SetShown(showMaterialControls)
        end
    end
    if showMaterialControls then
        if frame.materialTitleText then
            local sourceText = itemData.materialLearnedFromSession and "Learned from session"
                or (itemData.materialManualProfessionOverride and "Manual override" or "Curated material")
            frame.materialTitleText:SetText(sourceText)
        end
        if frame.materialExpansionText then
            frame.materialExpansionText:SetText("Expansion: " .. tostring(itemData.materialExpansionLabel or itemData.materialExpansionID or "Unknown"))
        end
        UpdateInventoryDetailsMaterialProfessionDropdown(self, frame, itemData)
    end
    RefreshInventoryDetailsRareSources(self, frame, showRareSources and itemData.rareSources or nil)
    if frame.graphPanel and frame.bodyPanel then
        frame.graphPanel:ClearAllPoints()
        local graphTopOffset
        if showRareSources and showMaterialControls then
            graphTopOffset = -296
        elseif showRareSources then
            graphTopOffset = -232
        elseif showMaterialControls then
            graphTopOffset = -188
        else
            graphTopOffset = showWowheadLinks and -124 or -62
        end
        frame.graphPanel:SetPoint("TOPLEFT", frame.bodyPanel, "TOPLEFT", 14, graphTopOffset)
        frame.graphPanel:SetPoint("BOTTOMRIGHT", frame.bodyPanel, "BOTTOMRIGHT", -14, INVENTORY_DETAILS_GRAPH_BOTTOM_OFFSET)
    end

    local latestSourceLabel = source.label
    if source.key == "selectedUnitValue"
        and samples[#samples]
        and type(samples[#samples].sourceID) == "string"
        and self.VALUE_SOURCE_BY_ID[samples[#samples].sourceID] then
        latestSourceLabel = latestSourceLabel .. " (" .. self.VALUE_SOURCE_BY_ID[samples[#samples].sourceID].label .. ")"
    end

    if not UpdateInventoryDetailsStatsFields(frame, stats, latestSourceLabel) and frame.statsText then
        if stats.count == 0 then
            frame.statsText:SetText(string.format("Source: %s\nSnapshots: 0", latestSourceLabel))
        else
            frame.statsText:SetText(string.format(
                "Source: %s\nSnapshots: %d\nFirst: %s at %s\nLatest: %s at %s\nMin / Max: %s / %s\nAverage: %s\nChange: %s",
                latestSourceLabel,
                stats.count,
                self:FormatMoney(stats.firstValue or 0),
                FormatInventoryDetailsTimestamp(stats.firstTimestamp),
                self:FormatMoney(stats.lastValue or 0),
                FormatInventoryDetailsTimestamp(stats.lastTimestamp),
                self:FormatMoney(stats.minValue or 0),
                self:FormatMoney(stats.maxValue or 0),
                self:FormatMoney(stats.averageValue or 0),
                FormatInventoryDetailsPercentChange(stats.changePercent)
            ))
        end
    end

    RefreshInventoryDetailsGraph(self, frame, samples, source)
end

local function CreateInventoryDetailsStatField(parent, label, column, row)
    local cell = CreateFrame("Frame", nil, parent)
    local topOffset = -10 - ((row - 1) * INVENTORY_DETAILS_STATS_ROW_HEIGHT)
    if column == 1 then
        cell:SetPoint("TOPLEFT", parent, "TOPLEFT", 12, topOffset)
        cell:SetPoint("TOPRIGHT", parent, "TOP", -8, topOffset)
    else
        cell:SetPoint("TOPLEFT", parent, "TOP", 8, topOffset)
        cell:SetPoint("TOPRIGHT", parent, "TOPRIGHT", -12, topOffset)
    end
    cell:SetHeight(INVENTORY_DETAILS_STATS_ROW_HEIGHT)

    local labelText = cell:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    labelText:SetPoint("LEFT", cell, "LEFT", 0, 0)
    labelText:SetWidth(INVENTORY_DETAILS_STATS_LABEL_WIDTH)
    labelText:SetJustifyH("LEFT")
    labelText:SetTextColor(1.0, 0.82, 0.18)
    labelText:SetText(label)

    local valueText = cell:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    valueText:SetPoint("LEFT", labelText, "RIGHT", 4, 0)
    valueText:SetPoint("RIGHT", cell, "RIGHT", 0, 0)
    valueText:SetJustifyH("LEFT")
    valueText:SetWordWrap(false)
    valueText:SetTextColor(0.88, 0.92, 1.0)
    valueText:SetText("--")

    return {
        cell = cell,
        labelText = labelText,
        valueText = valueText,
    }
end

local function CreateInventoryDetailsLinkEditBox(parent, labelText, leftAnchor, width)
    local label = parent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    label:SetPoint("TOPLEFT", parent, "TOPLEFT", leftAnchor, -6)
    label:SetText(labelText)

    local editBox = CreateFrame("EditBox", nil, parent, "InputBoxTemplate")
    editBox:SetSize(width, 22)
    if editBox.SetFontObject and GameFontHighlight then
        editBox:SetFontObject(GameFontHighlight)
    end
    editBox:SetPoint("TOPLEFT", label, "BOTTOMLEFT", 0, -5)
    editBox:SetAutoFocus(false)
    editBox:SetScript("OnEscapePressed", function(self)
        self:ClearFocus()
    end)
    editBox:SetScript("OnEnterPressed", function(self)
        self:ClearFocus()
    end)
    editBox:SetScript("OnEditFocusGained", function(self)
        self:HighlightText()
    end)
    editBox:SetScript("OnMouseUp", function(self)
        self:SetFocus()
        self:HighlightText()
    end)
    editBox.labelText = label

    return editBox
end

local function ApplyInventoryDetailsDropdownFont(dropdown)
    if not dropdown or type(dropdown.GetName) ~= "function" then
        return
    end

    local dropdownText = _G[dropdown:GetName() .. "Text"]
    if dropdownText and dropdownText.SetFontObject and GameFontHighlight then
        dropdownText:SetFontObject(GameFontHighlight)
    end
end

function GoldTracker:CreateInventoryItemDetailsWindow()
    if self.inventoryItemDetailsFrame then
        return
    end

    local addon = self
    local frame = CreateFrame("Frame", "GoldTrackerInventoryDetailsFrame", UIParent, "BasicFrameTemplateWithInset")
    frame:SetSize(INVENTORY_DETAILS_WINDOW_WIDTH, INVENTORY_DETAILS_WINDOW_HEIGHT)
    frame:SetPoint("CENTER", UIParent, "CENTER", 40, 20)
    frame:SetFrameStrata("DIALOG")
    if frame.SetToplevel then
        frame:SetToplevel(true)
    end
    frame:SetMovable(true)
    frame:SetResizable(true)
    if frame.SetResizeBounds then
        frame:SetResizeBounds(INVENTORY_DETAILS_WINDOW_MIN_WIDTH, INVENTORY_DETAILS_WINDOW_MIN_HEIGHT, 1040, 820)
    else
        if frame.SetMinResize then
            frame:SetMinResize(INVENTORY_DETAILS_WINDOW_MIN_WIDTH, INVENTORY_DETAILS_WINDOW_MIN_HEIGHT)
        end
        if frame.SetMaxResize then
            frame:SetMaxResize(1040, 820)
        end
    end
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnMouseDown", function(self)
        self:Raise()
    end)
    frame:SetScript("OnDragStart", function(self)
        self:Raise()
        self:StartMoving()
    end)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
    frame:SetClampedToScreen(true)
    frame:Hide()

    local chrome = Theme:ApplyWindowChrome(frame, "Item Market Details")
    Theme:RegisterSpecialFrame("GoldTrackerInventoryDetailsFrame")

    local bodyPanel = CreateInventoryPanel(frame, { 0.04, 0.05, 0.07, 0.94 }, { 1.0, 0.82, 0.18, 0.12 })
    bodyPanel:SetPoint("TOPLEFT", chrome, "TOPLEFT", 12, -54)
    bodyPanel:SetPoint("BOTTOMRIGHT", chrome, "BOTTOMRIGHT", -12, 12)
    frame.bodyPanel = bodyPanel

    local itemIcon = bodyPanel:CreateTexture(nil, "ARTWORK")
    itemIcon:SetSize(34, 34)
    itemIcon:SetPoint("TOPLEFT", bodyPanel, "TOPLEFT", 14, -12)
    frame.itemIcon = itemIcon

    local itemText = bodyPanel:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    itemText:SetPoint("TOPLEFT", itemIcon, "TOPRIGHT", 10, -2)
    itemText:SetPoint("TOPRIGHT", bodyPanel, "TOPRIGHT", -300, -14)
    itemText:SetJustifyH("LEFT")
    itemText:SetWordWrap(false)
    itemText:SetText("")
    frame.itemText = itemText

    local metaText = bodyPanel:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    metaText:SetPoint("TOPLEFT", itemText, "BOTTOMLEFT", 0, -6)
    metaText:SetPoint("TOPRIGHT", itemText, "BOTTOMRIGHT", 0, -6)
    metaText:SetJustifyH("LEFT")
    metaText:SetTextColor(0.62, 0.66, 0.74)
    metaText:SetText("")
    frame.metaText = metaText

    local sourceLabel = bodyPanel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    sourceLabel:SetPoint("TOPRIGHT", bodyPanel, "TOPRIGHT", -238, -13)
    sourceLabel:SetText("Data source")
    frame.sourceLabel = sourceLabel

    local sourceDropdown = CreateFrame("Frame", "GoldTrackerInventoryDetailsSourceDropdown", bodyPanel, "UIDropDownMenuTemplate")
    sourceDropdown:SetPoint("TOPLEFT", sourceLabel, "BOTTOMLEFT", -18, -5)
    UIDropDownMenu_SetWidth(sourceDropdown, INVENTORY_DETAILS_SOURCE_DROPDOWN_WIDTH)
    ApplyInventoryDetailsDropdownFont(sourceDropdown)
    UIDropDownMenu_Initialize(sourceDropdown, function(_, level)
        for _, source in ipairs(INVENTORY_DETAILS_PRICE_SOURCES) do
            local sourceKey = source.key
            local info = UIDropDownMenu_CreateInfo()
            info.text = source.label
            info.value = sourceKey
            info.checked = frame.selectedSourceKey == sourceKey
            info.func = function()
                frame.selectedSourceKey = sourceKey
                addon:RefreshInventoryItemDetailsWindow()
            end
            UIDropDownMenu_AddButton(info, level)
        end
    end)
    frame.sourceDropdown = sourceDropdown

    local wowheadPanel = CreateInventoryPanel(bodyPanel, { 0.05, 0.06, 0.08, 0.86 }, { 1.0, 0.82, 0.18, 0.10 })
    wowheadPanel:SetPoint("TOPLEFT", bodyPanel, "TOPLEFT", 14, -60)
    wowheadPanel:SetPoint("TOPRIGHT", bodyPanel, "TOPRIGHT", -14, -60)
    wowheadPanel:SetHeight(56)
    wowheadPanel:Hide()
    frame.wowheadPanel = wowheadPanel

    local wowheadTitleText = wowheadPanel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    wowheadTitleText:SetPoint("TOPLEFT", wowheadPanel, "TOPLEFT", 10, -6)
    wowheadTitleText:SetWidth(130)
    wowheadTitleText:SetJustifyH("LEFT")
    wowheadTitleText:SetWordWrap(false)
    wowheadTitleText:SetText("Wowhead links")
    frame.wowheadTitleText = wowheadTitleText

    frame.wowheadItemEditBox = CreateInventoryDetailsLinkEditBox(wowheadPanel, "Item", 152, 250)
    frame.wowheadRareEditBox = CreateInventoryDetailsLinkEditBox(wowheadPanel, "Rare", 430, 250)
    frame.wowheadRareLabelText = frame.wowheadRareEditBox.labelText

    local materialPanel = CreateInventoryPanel(bodyPanel, { 0.05, 0.06, 0.08, 0.86 }, { 1.0, 0.82, 0.18, 0.10 })
    materialPanel:SetPoint("TOPLEFT", bodyPanel, "TOPLEFT", 14, -122)
    materialPanel:SetPoint("TOPRIGHT", bodyPanel, "TOPRIGHT", -14, -122)
    materialPanel:SetHeight(INVENTORY_DETAILS_MATERIAL_PANEL_HEIGHT)
    materialPanel:Hide()
    frame.materialPanel = materialPanel

    local materialTitleText = materialPanel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    materialTitleText:SetPoint("TOPLEFT", materialPanel, "TOPLEFT", 10, -8)
    materialTitleText:SetWidth(160)
    materialTitleText:SetJustifyH("LEFT")
    materialTitleText:SetWordWrap(false)
    materialTitleText:SetText("Curated material")
    frame.materialTitleText = materialTitleText

    local materialExpansionText = materialPanel:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    materialExpansionText:SetPoint("TOPLEFT", materialTitleText, "BOTTOMLEFT", 0, -5)
    materialExpansionText:SetWidth(250)
    materialExpansionText:SetJustifyH("LEFT")
    materialExpansionText:SetWordWrap(false)
    materialExpansionText:SetTextColor(0.72, 0.76, 0.84)
    materialExpansionText:SetText("")
    frame.materialExpansionText = materialExpansionText

    local materialProfessionLabel = materialPanel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    materialProfessionLabel:SetPoint("TOPLEFT", materialPanel, "TOPLEFT", 300, -8)
    materialProfessionLabel:SetText("Profession")
    frame.materialProfessionLabel = materialProfessionLabel

    local materialProfessionDropdown = CreateFrame("Frame", "GoldTrackerInventoryDetailsMaterialProfessionDropdown", materialPanel, "UIDropDownMenuTemplate")
    materialProfessionDropdown:SetPoint("TOPLEFT", materialProfessionLabel, "BOTTOMLEFT", -18, -2)
    UIDropDownMenu_SetWidth(materialProfessionDropdown, 190)
    ApplyInventoryDetailsDropdownFont(materialProfessionDropdown)
    UIDropDownMenu_Initialize(materialProfessionDropdown, function(_, level)
        local itemData = frame.itemData or {}
        local currentProfessionID = GetInventoryDetailsMaterialProfessionID(itemData)
        for _, profession in ipairs(addon:GetCraftingFarmingProfessionOptions() or {}) do
            if profession.id ~= "all" then
                local info = UIDropDownMenu_CreateInfo()
                local professionID = profession.id
                info.text = profession.label
                info.value = professionID
                info.checked = currentProfessionID == professionID
                info.func = function()
                    local changed = addon:SetCraftingFarmingItemProfession(itemData.itemID, professionID)
                    if changed then
                        itemData.materialProfessionID = professionID
                        itemData.materialProfessionIDs = { professionID }
                        itemData.materialProfessionLabel = profession.label
                        itemData.materialManualProfessionOverride = true
                    end
                    addon:RefreshInventoryItemDetailsWindow()
                end
                UIDropDownMenu_AddButton(info, level)
            end
        end
    end)
    frame.materialProfessionDropdown = materialProfessionDropdown

    local rareSourcesTitleText = wowheadPanel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    rareSourcesTitleText:SetPoint("TOPLEFT", wowheadPanel, "TOPLEFT", 10, -62)
    rareSourcesTitleText:SetText("Rare sources")
    rareSourcesTitleText:Hide()
    frame.rareSourcesTitleText = rareSourcesTitleText

    local rareSourcesScrollFrame = CreateFrame("ScrollFrame", nil, wowheadPanel, "UIPanelScrollFrameTemplate")
    rareSourcesScrollFrame:SetPoint("TOPLEFT", rareSourcesTitleText, "BOTTOMLEFT", 0, -6)
    rareSourcesScrollFrame:SetPoint("TOPRIGHT", wowheadPanel, "TOPRIGHT", -28, -82)
    rareSourcesScrollFrame:SetHeight(INVENTORY_DETAILS_RARE_SOURCE_LIST_HEIGHT)
    rareSourcesScrollFrame:Hide()
    frame.rareSourcesScrollFrame = rareSourcesScrollFrame

    local rareSourcesContent = CreateFrame("Frame", nil, rareSourcesScrollFrame)
    rareSourcesContent:SetSize(1, 1)
    rareSourcesScrollFrame:SetScrollChild(rareSourcesContent)
    frame.rareSourcesContent = rareSourcesContent
    frame.rareSourceRows = {}

    local graphPanel = CreateInventoryPanel(bodyPanel, { 0.03, 0.04, 0.06, 0.82 }, { 1.0, 0.82, 0.18, 0.10 })
    graphPanel:SetPoint("TOPLEFT", bodyPanel, "TOPLEFT", 14, -62)
    graphPanel:SetPoint("BOTTOMRIGHT", bodyPanel, "BOTTOMRIGHT", -14, INVENTORY_DETAILS_GRAPH_BOTTOM_OFFSET)
    frame.graphPanel = graphPanel

    local graphTitle = graphPanel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    graphTitle:SetPoint("TOPLEFT", graphPanel, "TOPLEFT", 12, -10)
    graphTitle:SetText("Price evolution")
    frame.graphTitle = graphTitle

    local graphCanvas = CreateFrame("Frame", nil, graphPanel)
    graphCanvas:SetPoint("TOPLEFT", graphPanel, "TOPLEFT", 92, -28)
    graphCanvas:SetPoint("BOTTOMRIGHT", graphPanel, "BOTTOMRIGHT", -18, 46)
    frame.graphCanvas = graphCanvas

    frame.graphGridLines = {}
    frame.graphAxisLabels = {}
    for index = 1, INVENTORY_DETAILS_AXIS_TICK_COUNT do
        local isEdgeTick = index == 1 or index == INVENTORY_DETAILS_AXIS_TICK_COUNT
        local gridLine = graphCanvas:CreateTexture(nil, "BACKGROUND")
        gridLine:SetColorTexture(1, 1, 1, isEdgeTick and 0.07 or 0.05)
        gridLine:SetHeight(1)
        frame.graphGridLines[index] = gridLine

        local axisLabel = graphPanel:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        axisLabel:SetWidth(INVENTORY_DETAILS_AXIS_LABEL_WIDTH)
        axisLabel:SetHeight(16)
        axisLabel:SetJustifyH("RIGHT")
        axisLabel:SetTextColor(isEdgeTick and 0.72 or 0.62, isEdgeTick and 0.86 or 0.66, isEdgeTick and 1.0 or 0.74)
        axisLabel:SetText("--")
        frame.graphAxisLabels[index] = axisLabel
    end

    local graphStartText = graphPanel:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    graphStartText:SetPoint("TOPLEFT", graphCanvas, "BOTTOMLEFT", 0, -8)
    graphStartText:SetWidth(120)
    graphStartText:SetJustifyH("LEFT")
    graphStartText:SetTextColor(0.62, 0.66, 0.74)
    frame.graphStartText = graphStartText

    local graphStartDayText = graphPanel:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    graphStartDayText:SetPoint("TOPLEFT", graphStartText, "BOTTOMLEFT", 0, -2)
    graphStartDayText:SetWidth(120)
    graphStartDayText:SetJustifyH("LEFT")
    graphStartDayText:SetTextColor(0.62, 0.66, 0.74)
    frame.graphStartDayText = graphStartDayText

    local graphMiddleText = graphPanel:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    graphMiddleText:SetPoint("TOP", graphCanvas, "BOTTOM", 0, -8)
    graphMiddleText:SetWidth(120)
    graphMiddleText:SetJustifyH("CENTER")
    graphMiddleText:SetTextColor(0.62, 0.66, 0.74)
    frame.graphMiddleText = graphMiddleText

    local graphMiddleDayText = graphPanel:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    graphMiddleDayText:SetPoint("TOP", graphMiddleText, "BOTTOM", 0, -2)
    graphMiddleDayText:SetWidth(120)
    graphMiddleDayText:SetJustifyH("CENTER")
    graphMiddleDayText:SetTextColor(0.62, 0.66, 0.74)
    frame.graphMiddleDayText = graphMiddleDayText

    local graphEndText = graphPanel:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    graphEndText:SetPoint("TOPRIGHT", graphCanvas, "BOTTOMRIGHT", 0, -8)
    graphEndText:SetWidth(120)
    graphEndText:SetJustifyH("RIGHT")
    graphEndText:SetTextColor(0.62, 0.66, 0.74)
    frame.graphEndText = graphEndText

    local graphEndDayText = graphPanel:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    graphEndDayText:SetPoint("TOPRIGHT", graphEndText, "BOTTOMRIGHT", 0, -2)
    graphEndDayText:SetWidth(120)
    graphEndDayText:SetJustifyH("RIGHT")
    graphEndDayText:SetTextColor(0.62, 0.66, 0.74)
    frame.graphEndDayText = graphEndDayText

    local graphEmptyText = graphCanvas:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    graphEmptyText:SetPoint("CENTER", graphCanvas, "CENTER", 0, 0)
    graphEmptyText:SetJustifyH("CENTER")
    graphEmptyText:SetTextColor(0.62, 0.66, 0.74)
    graphEmptyText:SetText("")
    frame.graphEmptyText = graphEmptyText

    local statsPanel = CreateInventoryPanel(bodyPanel, { 0.05, 0.06, 0.08, 0.86 }, { 1.0, 0.82, 0.18, 0.10 })
    statsPanel:SetPoint("BOTTOMLEFT", bodyPanel, "BOTTOMLEFT", 14, 14)
    statsPanel:SetPoint("BOTTOMRIGHT", bodyPanel, "BOTTOMRIGHT", -14, 14)
    statsPanel:SetHeight(INVENTORY_DETAILS_STATS_PANEL_HEIGHT)
    frame.statsPanel = statsPanel

    frame.statsFields = {
        source = CreateInventoryDetailsStatField(statsPanel, "Source", 1, 1),
        snapshots = CreateInventoryDetailsStatField(statsPanel, "Snapshots", 2, 1),
        firstValue = CreateInventoryDetailsStatField(statsPanel, "First value", 1, 2),
        firstSeen = CreateInventoryDetailsStatField(statsPanel, "First seen", 2, 2),
        latestValue = CreateInventoryDetailsStatField(statsPanel, "Latest value", 1, 3),
        latestSeen = CreateInventoryDetailsStatField(statsPanel, "Latest seen", 2, 3),
        lowest = CreateInventoryDetailsStatField(statsPanel, "Lowest", 1, 4),
        highest = CreateInventoryDetailsStatField(statsPanel, "Highest", 2, 4),
        average = CreateInventoryDetailsStatField(statsPanel, "Average", 1, 5),
        change = CreateInventoryDetailsStatField(statsPanel, "Change", 2, 5),
    }

    Theme:CreateResizeButton(frame, {
        minWidth = INVENTORY_DETAILS_WINDOW_MIN_WIDTH,
        minHeight = INVENTORY_DETAILS_WINDOW_MIN_HEIGHT,
        maxWidth = 1040,
        maxHeight = 820,
        onResizeStop = function()
            addon:RefreshInventoryItemDetailsWindow()
        end,
    })

    frame:SetScript("OnSizeChanged", function()
        if frame.isManualResizing then
            return
        end
        addon:RefreshInventoryItemDetailsWindow()
    end)
    frame:SetScript("OnShow", function()
        addon:RefreshInventoryItemDetailsWindow()
    end)
    frame:SetScript("OnHide", function()
        GameTooltip:Hide()
    end)

    self.inventoryItemDetailsFrame = frame
end

function GoldTracker:OpenInventoryItemDetailsWindow(row)
    if type(row) ~= "table" then
        return
    end

    local itemLink = type(row.itemLink) == "string" and row.itemLink ~= "" and row.itemLink or nil
    local itemID = tonumber(row.itemID)
    if not itemLink and not itemID then
        return
    end

    self:CreateInventoryItemDetailsWindow()
    local frame = self.inventoryItemDetailsFrame
    if not frame then
        return
    end

    local itemKey, history
    if type(self.GetMarketHistoryForItem) == "function" then
        itemKey, history = self:GetMarketHistoryForItem(itemLink, itemID)
    end

    local iconTexture = row.iconTexture
    if iconTexture == nil and (type(row.icon) == "number" or type(row.icon) == "string") then
        iconTexture = row.icon
    end

    frame.itemData = {
        itemID = itemID and math.floor(itemID + 0.5) or nil,
        itemLink = itemLink,
        itemName = row.itemName,
        itemQuality = row.itemQuality,
        icon = iconTexture,
        npcID = row.npcID,
        rareName = row.rareName,
        rareSources = row.rareSources,
        rareSourceCount = row.rareSourceCount,
        locationLabel = row.locationLabel,
        locations = row.locations,
        instanceName = row.instanceName,
        bossName = row.bossName,
        instanceEncounterJournalID = row.instanceEncounterJournalID,
        bossEncounterJournalID = row.bossEncounterJournalID,
        quantity = row.quantity or 1,
        unitValue = row.unitValue or row.value,
        totalValue = row.totalValue or row.value,
        valueSourceID = row.valueSourceID,
        valueSourceLabel = row.valueSourceLabel,
        materialContext = row.materialExpansionID and "craftingFarming" or nil,
        materialExpansionID = row.materialExpansionID,
        materialExpansionLabel = row.materialExpansionLabel,
        materialProfessionIDs = row.materialProfessionIDs,
        materialProfessionLabel = row.materialProfessionLabel,
        materialLearnedFromSession = row.materialLearnedFromSession == true,
        materialManualProfessionOverride = row.materialManualProfessionOverride == true,
    }
    frame.marketHistoryItemKey = itemKey
    frame.marketHistory = history
    frame.selectedSourceKey = GetInventoryDetailsPreferredSourceKey(frame.itemData, history)

    frame:Show()
    if type(Theme.BringToFront) == "function" then
        Theme:BringToFront(frame, self.inventoryFrame)
    else
        frame:Raise()
    end
    self:RefreshInventoryItemDetailsWindow()
end

function GoldTracker:BuildInventoryAuctionItemList(valueSourceID, minimumQuality, minimumValueCopper, sortKey, sortAscending, categoryFilterID)
    return self:BuildAuctionableInventoryItemList(
        valueSourceID,
        minimumQuality,
        minimumValueCopper,
        sortKey,
        sortAscending,
        categoryFilterID
    )
end

function GoldTracker:HasInventoryMaterialFarmingMap(rowOrItemID)
    local itemID = type(rowOrItemID) == "table" and rowOrItemID.itemID or rowOrItemID
    local materialData = GetInventoryMaterialFarmingSpotData(self, itemID)
    return type(materialData) == "table" and type(materialData.spots) == "table" and #materialData.spots > 0
end

function GoldTracker:OpenInventoryMaterialFarmingMap(row)
    local itemID = tonumber(row and row.itemID)
    if not itemID or not self:HasInventoryMaterialFarmingMap(itemID) then
        local frame = self.inventoryFrame
        if frame and frame.metaText then
            frame.metaText:SetText("No coordinate-backed farming map data for this bag item yet.")
        end
        return false
    end
    if type(self.OpenMaterialFarmingMap) ~= "function" then
        local frame = self.inventoryFrame
        if frame and frame.metaText then
            frame.metaText:SetText("The material farming map is not available yet.")
        end
        return false
    end
    return self:OpenMaterialFarmingMap(itemID)
end

function GoldTracker:ToggleInventoryItemFavorite(row)
    if type(row) ~= "table" then
        return false
    end

    local key = type(self.GetFarmingFavoriteKey) == "function" and self:GetFarmingFavoriteKey(row)
    local favorites = type(self.GetFarmingFavoriteStore) == "function" and self:GetFarmingFavoriteStore() or nil
    if not key or type(favorites) ~= "table" then
        return false
    end

    if favorites[key] then
        favorites[key] = nil
    else
        favorites[key] = {
            favoriteKey = key,
            itemID = row.itemID,
            itemLink = row.itemLink,
            itemName = row.itemName,
            itemQuality = row.itemQuality,
            icon = row.iconTexture or row.icon,
            quantity = row.quantity,
            stackCount = row.stackCount,
            categoryID = row.categoryID,
            categoryLabel = row.categoryLabel,
            locationLabel = "Bags",
            value = row.totalValue or row.unitValue,
            unitValue = row.unitValue,
            totalValue = row.totalValue,
            marketValue = row.marketValue,
            historicalValue = row.historicalValue,
            valueSourceID = row.valueSourceID,
            valueSourceLabel = row.valueSourceLabel,
            farmingSourceType = "inventory",
            favoritedAt = date("%Y-%m-%d %H:%M"),
            favoritedAtTime = time(),
        }
    end

    self:RefreshInventoryWindow(false)
    if type(self.RefreshRareFarmingLibraryWindow) == "function" then
        self:RefreshRareFarmingLibraryWindow()
    end
    if type(self.RefreshInstanceFarmingLibraryWindow) == "function" then
        self:RefreshInstanceFarmingLibraryWindow()
    end
    return true
end

function GoldTracker:RefreshInventoryWindowControls()
    local frame = self.inventoryFrame
    if not frame then
        return
    end

    local source = ResolveInventoryWindowSource(self, frame)
    frame.valueSourceID = source.id
    UIDropDownMenu_SetSelectedValue(frame.valueSourceDropdown, source.id)
    UIDropDownMenu_SetText(frame.valueSourceDropdown, source.label)

    frame.minimumQuality = NormalizeMinimumQuality(self, frame.minimumQuality)
    local qualityOption = self.TRACKED_ITEM_QUALITY_BY_ID[frame.minimumQuality]
    UIDropDownMenu_SetSelectedValue(frame.qualityDropdown, frame.minimumQuality)
    UIDropDownMenu_SetText(
        frame.qualityDropdown,
        self:GetColoredItemQualityLabel(frame.minimumQuality, qualityOption and qualityOption.label)
    )

    local minimumValueCopper = tonumber(frame.minimumValueCopper) or 0
    if frame.minimumValueInput and not frame.minimumValueInput:HasFocus() then
        frame.minimumValueInput:SetText(FormatGoldInput(self, minimumValueCopper))
    end

    frame.categoryFilterID = NormalizeInventoryCategoryFilter(frame.categoryFilterID)
    local category = GetInventoryCategoryOption(frame.categoryFilterID)
    if frame.categoryDropdown and category then
        UIDropDownMenu_SetSelectedValue(frame.categoryDropdown, category.id)
        UIDropDownMenu_SetText(frame.categoryDropdown, category.label)
    end
    if frame.groupByCategoryCheckbox then
        frame.groupByCategoryCheckbox:SetChecked(frame.groupByCategory == true)
    end
end

function GoldTracker:UpdateInventorySortHeaderState()
    local frame = self.inventoryFrame
    if not frame then
        return
    end

    local sortKey = NormalizeInventorySortKey(frame.inventorySortKey)
    local sortAscending = frame.inventorySortAscending == true
    local headers = {
        demand = { button = frame.demandHeaderButton, label = "Sold/day" },
        sellRate = { button = frame.sellRateHeaderButton, label = "Sale %" },
        historySamples = { button = frame.historyHeaderButton, label = "Hist" },
        itemName = { button = frame.itemHeaderButton, label = "Item" },
        quantity = { button = frame.quantityHeaderButton, label = "Qty" },
        marketTrend = { button = frame.trendHeaderButton, label = "Trend" },
        unitValue = { button = frame.unitHeaderButton, label = "Unit value" },
        totalValue = { button = frame.totalHeaderButton, label = "Stack value" },
    }

    for headerSortKey, header in pairs(headers) do
        local button = header.button
        if button and button.text then
            button.text:SetText(header.label)
            if headerSortKey == sortKey then
                button.text:SetTextColor(1, 1, 1)
                if button.sortIcon then
                    Theme:SetTexture(button.sortIcon, sortAscending and "sortAscending" or "sortDescending")
                    button.sortIcon:Show()
                end
            else
                button.text:SetTextColor(1.0, 0.82, 0.18)
                if button.sortIcon then
                    button.sortIcon:Hide()
                end
            end
        end
    end
end

function GoldTracker:ToggleInventorySort(sortKey)
    local frame = self.inventoryFrame
    if not frame or not INVENTORY_SORT_KEYS[sortKey] then
        return
    end

    if frame.inventorySortKey ~= sortKey then
        frame.inventorySortKey = sortKey
        frame.inventorySortAscending = sortKey == "itemName"
    else
        frame.inventorySortAscending = frame.inventorySortAscending ~= true
    end

    self:RefreshInventoryWindow(true)
end

local function GetInventoryTableAvailableWidth(frame)
    if not frame then
        return 0
    end

    local width = 0
    if frame.inventoryScrollFrame then
        width = tonumber(frame.inventoryScrollFrame:GetWidth()) or 0
    end
    if width <= 1 and frame.listPanel then
        width = (tonumber(frame.listPanel:GetWidth()) or 0) - 38
    end

    return math.max(1, width - 6)
end

local function SetInventoryHeaderColumn(button, listPanel, leftOffset, width)
    if not button or not listPanel then
        return
    end

    button:ClearAllPoints()
    button:SetPoint("TOPLEFT", listPanel, "TOPLEFT", leftOffset, -12)
    button:SetWidth(math.max(1, width))
end

local function SetInventoryRowColumn(fontString, row, leftOffset, width)
    if not fontString or not row then
        return
    end

    fontString:ClearAllPoints()
    fontString:SetPoint("LEFT", row, "LEFT", leftOffset, 0)
    fontString:SetWidth(math.max(1, width))
end

local function SetInventoryRowControl(control, row, leftOffset, width)
    if not control or not row then
        return
    end

    control:ClearAllPoints()
    control:SetPoint("LEFT", row, "LEFT", leftOffset, 0)
    control:SetWidth(math.max(1, width))
end

local function ApplyInventoryTableColumnLayout(frame)
    if not frame then
        return
    end

    local availableWidth = GetInventoryTableAvailableWidth(frame)
    if frame.inventoryContent then
        frame.inventoryContent:SetWidth(availableWidth)
    end

    local favoriteX = INVENTORY_ROW_ICON_LEFT
    local mapX = favoriteX + INVENTORY_TRACKED_COLUMN_WIDTH + INVENTORY_ACTION_COLUMN_GAP
    local iconX = mapX + INVENTORY_MAP_COLUMN_WIDTH + INVENTORY_ACTION_COLUMN_GAP
    local itemX = iconX + INVENTORY_ICON_SIZE + INVENTORY_ROW_ICON_GAP
    local rightEdge = availableWidth - INVENTORY_ROW_RIGHT_PADDING
    local totalX = rightEdge - INVENTORY_TOTAL_VALUE_WIDTH
    local quantityX = totalX - INVENTORY_COLUMN_GAP - INVENTORY_QUANTITY_WIDTH
    local unitX = quantityX - INVENTORY_COLUMN_GAP - INVENTORY_UNIT_VALUE_WIDTH
    local trendX = unitX - INVENTORY_COLUMN_GAP - INVENTORY_TREND_WIDTH
    local sellRateX = trendX - INVENTORY_COLUMN_GAP - INVENTORY_SELL_RATE_WIDTH
    local demandX = sellRateX - INVENTORY_COLUMN_GAP - INVENTORY_DEMAND_WIDTH
    local historyX = demandX - INVENTORY_COLUMN_GAP - INVENTORY_HISTORY_WIDTH
    local itemWidth = math.max(1, historyX - INVENTORY_COLUMN_GAP - itemX)

    if frame.listPanel then
        local headerX = INVENTORY_HEADER_LEFT_INSET
        SetInventoryHeaderColumn(frame.favoriteHeaderButton, frame.listPanel, headerX + favoriteX, INVENTORY_TRACKED_COLUMN_WIDTH)
        SetInventoryHeaderColumn(frame.mapHeaderButton, frame.listPanel, headerX + mapX, INVENTORY_MAP_COLUMN_WIDTH)
        SetInventoryHeaderColumn(frame.itemHeaderButton, frame.listPanel, headerX + itemX, itemWidth)
        SetInventoryHeaderColumn(frame.historyHeaderButton, frame.listPanel, headerX + historyX, INVENTORY_HISTORY_WIDTH)
        SetInventoryHeaderColumn(frame.demandHeaderButton, frame.listPanel, headerX + demandX, INVENTORY_DEMAND_WIDTH)
        SetInventoryHeaderColumn(frame.sellRateHeaderButton, frame.listPanel, headerX + sellRateX, INVENTORY_SELL_RATE_WIDTH)
        SetInventoryHeaderColumn(frame.trendHeaderButton, frame.listPanel, headerX + trendX, INVENTORY_TREND_WIDTH)
        SetInventoryHeaderColumn(frame.unitHeaderButton, frame.listPanel, headerX + unitX, INVENTORY_UNIT_VALUE_WIDTH)
        SetInventoryHeaderColumn(frame.quantityHeaderButton, frame.listPanel, headerX + quantityX, INVENTORY_QUANTITY_WIDTH)
        SetInventoryHeaderColumn(frame.totalHeaderButton, frame.listPanel, headerX + totalX, INVENTORY_TOTAL_VALUE_WIDTH)
    end

    for _, row in ipairs(frame.inventoryRows or {}) do
        SetInventoryRowControl(row.favoriteButton, row, favoriteX + math.floor((INVENTORY_TRACKED_COLUMN_WIDTH - INVENTORY_TRACKED_BUTTON_WIDTH) / 2), INVENTORY_TRACKED_BUTTON_WIDTH)
        SetInventoryRowControl(row.mapButton, row, mapX + math.floor((INVENTORY_MAP_COLUMN_WIDTH - INVENTORY_MAP_BUTTON_WIDTH) / 2), INVENTORY_MAP_BUTTON_WIDTH)
        SetInventoryRowControl(row.icon, row, iconX, INVENTORY_ICON_SIZE)
        SetInventoryRowColumn(row.itemText, row, itemX, itemWidth)
        SetInventoryRowColumn(row.historySamplesText, row, historyX, INVENTORY_HISTORY_WIDTH)
        SetInventoryRowColumn(row.demandText, row, demandX, INVENTORY_DEMAND_WIDTH)
        SetInventoryRowColumn(row.sellRateText, row, sellRateX, INVENTORY_SELL_RATE_WIDTH)
        SetInventoryRowColumn(row.trendText, row, trendX, INVENTORY_TREND_WIDTH)
        SetInventoryRowColumn(row.unitValueText, row, unitX, INVENTORY_UNIT_VALUE_WIDTH)
        SetInventoryRowColumn(row.quantityText, row, quantityX, INVENTORY_QUANTITY_WIDTH)
        SetInventoryRowColumn(row.totalValueText, row, totalX, INVENTORY_TOTAL_VALUE_WIDTH)
    end
end

function GoldTracker:GetInventoryWindowRow(index)
    local frame = self.inventoryFrame
    if not frame or not frame.inventoryContent then
        return nil
    end

    frame.inventoryRows = frame.inventoryRows or {}
    local row = frame.inventoryRows[index]
    if row then
        return row
    end

    row = CreateFrame("Button", nil, frame.inventoryContent)
    row:EnableMouse(true)
    row:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    row:SetHeight(INVENTORY_ROW_HEIGHT)

    local background = row:CreateTexture(nil, "BACKGROUND")
    background:SetAllPoints(row)
    row.background = background

    local hover = row:CreateTexture(nil, "HIGHLIGHT")
    hover:SetAllPoints(row)
    hover:SetColorTexture(1, 0.82, 0.18, 0.08)
    row.hover = hover

    local favoriteButton = CreateInventoryButton(row, INVENTORY_TRACKED_BUTTON_WIDTH, INVENTORY_TRACKED_BUTTON_HEIGHT, "+", "neutral")
    favoriteButton:RegisterForClicks("LeftButtonUp")
    favoriteButton:SetScript("OnClick", function(self)
        GoldTracker:ToggleInventoryItemFavorite(self:GetParent())
    end)
    favoriteButton:SetScript("OnEnter", function(self)
        if not GameTooltip then
            return
        end
        GameTooltip:SetOwner(self, "ANCHOR_CURSOR")
        GameTooltip:SetText(self:GetParent().favorite and "Remove tracked item" or "Track item", 1.0, 0.82, 0.18)
        GameTooltip:AddLine("Shows this bag item in Favorites with the other farming lists.", 0.72, 0.86, 1.0)
        GameTooltip:Show()
    end)
    favoriteButton:SetScript("OnLeave", function()
        if GameTooltip then
            GameTooltip:Hide()
        end
    end)
    row.favoriteButton = favoriteButton

    local mapButton = CreateInventoryButton(row, INVENTORY_MAP_BUTTON_WIDTH, INVENTORY_MAP_BUTTON_HEIGHT, "Map", "neutral")
    mapButton:RegisterForClicks("LeftButtonUp")
    mapButton:SetScript("OnClick", function(self)
        GoldTracker:OpenInventoryMaterialFarmingMap(self:GetParent())
    end)
    mapButton:SetScript("OnEnter", function(self)
        if not GameTooltip then
            return
        end
        local parent = self:GetParent()
        GameTooltip:SetOwner(self, "ANCHOR_CURSOR")
        if parent and parent.hasFarmingMap then
            GameTooltip:SetText("Open farming map", 1.0, 0.82, 0.18)
            GameTooltip:AddLine("Shows the indexed material route for this bag item.", 0.72, 0.86, 1.0)
        else
            GameTooltip:SetText("No farming map", 0.62, 0.66, 0.74)
            GameTooltip:AddLine("This bag item is not in the static farming map index.", 0.72, 0.76, 0.84)
        end
        GameTooltip:Show()
    end)
    mapButton:SetScript("OnLeave", function()
        if GameTooltip then
            GameTooltip:Hide()
        end
    end)
    row.mapButton = mapButton

    local icon = row:CreateTexture(nil, "ARTWORK")
    icon:SetSize(INVENTORY_ICON_SIZE, INVENTORY_ICON_SIZE)
    icon:SetPoint("LEFT", row, "LEFT", 8, 0)
    row.icon = icon

    local totalValueText = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    totalValueText:SetPoint("RIGHT", row, "RIGHT", -6, 0)
    totalValueText:SetWidth(INVENTORY_TOTAL_VALUE_WIDTH)
    totalValueText:SetJustifyH("RIGHT")
    totalValueText:SetWordWrap(false)
    row.totalValueText = totalValueText

    local quantityText = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    quantityText:SetPoint("RIGHT", totalValueText, "LEFT", -12, 0)
    quantityText:SetWidth(INVENTORY_QUANTITY_WIDTH)
    quantityText:SetJustifyH("RIGHT")
    quantityText:SetWordWrap(false)
    row.quantityText = quantityText

    local unitValueText = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    unitValueText:SetPoint("RIGHT", quantityText, "LEFT", -12, 0)
    unitValueText:SetWidth(INVENTORY_UNIT_VALUE_WIDTH)
    unitValueText:SetJustifyH("RIGHT")
    unitValueText:SetWordWrap(false)
    row.unitValueText = unitValueText

    local trendText = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    trendText:SetPoint("RIGHT", unitValueText, "LEFT", -12, 0)
    trendText:SetWidth(INVENTORY_TREND_WIDTH)
    trendText:SetJustifyH("RIGHT")
    trendText:SetWordWrap(false)
    row.trendText = trendText

    local sellRateText = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    sellRateText:SetPoint("RIGHT", trendText, "LEFT", -12, 0)
    sellRateText:SetWidth(INVENTORY_SELL_RATE_WIDTH)
    sellRateText:SetJustifyH("RIGHT")
    sellRateText:SetWordWrap(false)
    row.sellRateText = sellRateText

    local demandText = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    demandText:SetPoint("RIGHT", sellRateText, "LEFT", -12, 0)
    demandText:SetWidth(INVENTORY_DEMAND_WIDTH)
    demandText:SetJustifyH("RIGHT")
    demandText:SetWordWrap(false)
    row.demandText = demandText

    local historySamplesText = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    historySamplesText:SetPoint("RIGHT", demandText, "LEFT", -12, 0)
    historySamplesText:SetWidth(INVENTORY_HISTORY_WIDTH)
    historySamplesText:SetJustifyH("RIGHT")
    historySamplesText:SetWordWrap(false)
    row.historySamplesText = historySamplesText

    local itemText = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    itemText:SetPoint("LEFT", icon, "RIGHT", 8, 0)
    itemText:SetPoint("RIGHT", historySamplesText, "LEFT", -12, 0)
    itemText:SetJustifyH("LEFT")
    itemText:SetWordWrap(false)
    row.itemText = itemText

    local divider = row:CreateTexture(nil, "ARTWORK")
    divider:SetColorTexture(1, 0.82, 0.18, 0.10)
    divider:SetPoint("BOTTOMLEFT", row, "BOTTOMLEFT", 6, 0)
    divider:SetPoint("BOTTOMRIGHT", row, "BOTTOMRIGHT", -6, 0)
    divider:SetHeight(1)
    row.divider = divider

    row:SetScript("OnEnter", function(self)
        if type(self.itemLink) ~= "string" or self.itemLink == "" then
            return
        end
        GameTooltip:SetOwner(self, "ANCHOR_CURSOR")
        GameTooltip:SetHyperlink(self.itemLink)
        GameTooltip:AddLine(" ")
        GameTooltip:AddLine("TSM regional demand", 1.0, 0.82, 0.18)
        local regionSaleRateText = FormatInventoryDecimalValue(self.regionSaleRate, 3)
        if regionSaleRateText then
            regionSaleRateText = regionSaleRateText .. " (" .. FormatInventorySaleRate(self.regionSaleRate) .. ")"
        end
        GameTooltip:AddDoubleLine(
            "DBRegionSoldPerDay",
            FormatInventoryDecimalValue(self.regionSoldPerDay, 2) or "Unknown",
            0.72, 0.86, 1.0,
            1, 1, 1
        )
        GameTooltip:AddLine("Average volume sold per Auction House per day in your region.", 0.62, 0.66, 0.74)
        GameTooltip:AddDoubleLine(
            "DBRegionSaleRate",
            regionSaleRateText or "Unknown",
            0.72, 0.86, 1.0,
            1, 1, 1
        )
        GameTooltip:AddLine("Average chance/rate of selling per post in your region.", 0.62, 0.66, 0.74)
        local sellRateLabel = GetInventorySellRateTier(self.regionSaleRate)
        GameTooltip:AddDoubleLine(
            "Sell rate",
            sellRateLabel ~= "--" and sellRateLabel or "Unknown",
            0.72, 0.86, 1.0,
            1, 1, 1
        )
        GameTooltip:AddLine(" ")
        GameTooltip:AddLine("TSM market trend", 1.0, 0.82, 0.18)
        GameTooltip:AddDoubleLine(
            "Market trend",
            FormatInventoryTrendPercent(self.marketTrendPercent),
            0.72, 0.86, 1.0,
            GetInventoryTrendColor(self.marketTrendPercent)
        )
        GameTooltip:AddDoubleLine(
            "Market value",
            self.marketValue and GoldTracker:FormatMoney(self.marketValue) or "Unknown",
            0.72, 0.86, 1.0,
            1, 1, 1
        )
        GameTooltip:AddDoubleLine(
            "Historical price",
            self.historicalValue and GoldTracker:FormatMoney(self.historicalValue) or "Unknown",
            0.72, 0.86, 1.0,
            1, 1, 1
        )
        if type(self.valueSourceLabel) == "string" and self.valueSourceLabel ~= "" then
            GameTooltip:AddDoubleLine(
                "Inventory value source",
                self.valueSourceWasFallback and (self.valueSourceLabel .. " fallback") or self.valueSourceLabel,
                0.72, 0.86, 1.0,
                1, 1, 1
            )
        end
        local marketHistoryInsight = self.marketHistoryInsight
        if type(marketHistoryInsight) ~= "table" and type(GoldTracker.GetInventoryMarketInsight) == "function" then
            marketHistoryInsight = GoldTracker:GetInventoryMarketInsight(self)
            self.marketHistoryInsight = marketHistoryInsight
        end
        if type(marketHistoryInsight) == "table" then
            GameTooltip:AddLine(" ")
            GameTooltip:AddLine("Local market history", 1.0, 0.82, 0.18)
            GameTooltip:AddDoubleLine(
                "Saved snapshots",
                tostring(marketHistoryInsight.sampleCount or self.marketHistorySampleCount or 0),
                0.72, 0.86, 1.0,
                1, 1, 1
            )
            GameTooltip:AddLine(marketHistoryInsight.summary or "Collecting local market history.", 0.72, 0.86, 1.0)
            if type(marketHistoryInsight.detail) == "string" and marketHistoryInsight.detail ~= "" then
                GameTooltip:AddLine(marketHistoryInsight.detail, 0.62, 0.66, 0.74)
            end
        end
        GameTooltip:AddLine(" ")
        GameTooltip:AddLine("Left-click for market details. Right-click to load into the Auction House sell tab.", 0.72, 0.86, 1.0)
        GameTooltip:Show()
    end)
    row:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)
    row:SetScript("OnMouseUp", function(self, button)
        if button == "LeftButton" and type(self.itemLink) == "string" and self.itemLink ~= "" then
            if GoldTracker:HandleModifiedItemClickIfModified(self) then
                return
            end
            GoldTracker:OpenInventoryItemDetailsWindow(self)
        elseif button == "RightButton" and type(self.itemLink) == "string" and self.itemLink ~= "" then
            GoldTracker:LoadInventoryItemIntoAuctionHouse(self)
        end
    end)

    frame.inventoryRows[index] = row
    return row
end

function GoldTracker:RefreshInventoryWindowLayout()
    local frame = self.inventoryFrame
    if not frame or not frame.inventoryScrollFrame or not frame.inventoryContent then
        return
    end

    ApplyInventoryTableColumnLayout(frame)
    if frame.inventoryScrollFrame.UpdateScrollChildRect then
        frame.inventoryScrollFrame:UpdateScrollChildRect()
    end
end

function GoldTracker:RefreshInventoryWindow(scrollToTop)
    local frame = self.inventoryFrame
    if not frame or not frame.inventoryContent then
        return
    end

    local source = ResolveInventoryWindowSource(self, frame)
    local minimumQuality = NormalizeMinimumQuality(self, frame.minimumQuality)
    local minimumValueCopper = tonumber(frame.minimumValueCopper) or 0
    local items, totalValue, totalQuantity, scannedStacks, matchedStacks =
        self:BuildInventoryAuctionItemList(
            source.id,
            minimumQuality,
            minimumValueCopper,
            frame.inventorySortKey,
            frame.inventorySortAscending,
            frame.categoryFilterID
        )
    local rowHeight = INVENTORY_ROW_HEIGHT
    local yOffset = 0

    self:RefreshInventoryWindowControls()
    self:UpdateInventorySortHeaderState()

    if frame.metaText then
        if #items > 0 then
            frame.metaText:SetText(string.format(
                "%d items, %d stacks, %d qty, %s",
                #items,
                matchedStacks,
                totalQuantity,
                self:FormatMoney(totalValue)
            ))
        else
            frame.metaText:SetText(string.format("%d stacks scanned", scannedStacks))
        end
    end

    if frame.emptyText then
        frame.emptyText:SetText("")
        frame.emptyText:Hide()
    end

    if frame.inventorySortKey == "historySamples" and type(self.GetMarketHistorySampleCount) == "function" then
        for _, item in ipairs(items) do
            item.marketHistorySampleCount = self:GetMarketHistorySampleCount(item.itemLink)
        end
        SortInventoryItems(items, frame.inventorySortKey, frame.inventorySortAscending)
    end

    local displayRows = BuildInventoryDisplayRows(items, frame.categoryFilterID, frame.groupByCategory)

    for index, displayRow in ipairs(displayRows) do
        local row = self:GetInventoryWindowRow(index)
        if row then
            if displayRow.isCategoryDivider then
                row.isCategoryDivider = true
                row.itemID = nil
                row.itemLink = nil
                row.itemName = nil
                row.itemQuality = nil
                row.iconTexture = nil
                row.quantity = nil
                row.unitValue = nil
                row.totalValue = nil
                row.valueSourceID = nil
                row.bagID = nil
                row.slotIndex = nil
                row.regionSoldPerDay = nil
                row.regionSaleRate = nil
                row.marketValue = nil
                row.historicalValue = nil
                row.marketTrendPercent = nil
                row.valueSourceLabel = nil
                row.valueSourceWasFallback = false
                row.marketHistoryInsight = nil
                row.marketHistorySampleCount = 0
                row.favorite = false
                row.hasFarmingMap = false
                if row.favoriteButton then
                    row.favoriteButton:Hide()
                end
                if row.mapButton then
                    row.mapButton:Hide()
                end
                if row.icon then
                    row.icon:Hide()
                end
                row.itemText:Show()
                row.itemText:SetText(string.format("%s (%d)", displayRow.categoryLabel or "Uncategorized", displayRow.itemCount or 0))
                row.itemText:SetTextColor(1.0, 0.82, 0.18)
                row.quantityText:Hide()
                row.historySamplesText:Hide()
                row.demandText:Hide()
                row.sellRateText:Hide()
                row.trendText:Hide()
                row.unitValueText:Hide()
                row.totalValueText:Hide()
                if row.background then
                    row.background:SetColorTexture(1.0, 0.82, 0.18, 0.10)
                end
                if row.divider then
                    row.divider:SetShown(true)
                end

                row:ClearAllPoints()
                row:SetPoint("TOPLEFT", frame.inventoryContent, "TOPLEFT", 0, -yOffset)
                row:SetPoint("TOPRIGHT", frame.inventoryContent, "TOPRIGHT", 0, -yOffset)
                row:SetHeight(rowHeight)
                row:Show()

                yOffset = yOffset + rowHeight + INVENTORY_ROW_SPACING
            else
                local item = displayRow
                row.isCategoryDivider = false
                row.itemID = item.itemID
                row.itemLink = item.itemLink
                row.itemName = item.itemName
                row.itemQuality = item.itemQuality
                row.iconTexture = item.icon
                row.quantity = item.quantity
                row.unitValue = item.unitValue
                row.totalValue = item.totalValue
                row.valueSourceID = item.valueSourceID
                row.categoryID = item.categoryID
                row.categoryLabel = item.categoryLabel
                row.bagID = item.bagID
                row.slotIndex = item.slotIndex
                row.regionSoldPerDay = item.regionSoldPerDay
                row.regionSaleRate = item.regionSaleRate
                row.marketValue = item.marketValue
                row.historicalValue = item.historicalValue
                row.marketTrendPercent = item.marketTrendPercent
                row.valueSourceLabel = item.valueSourceLabel
                row.valueSourceWasFallback = item.valueSourceWasFallback == true
                row.marketHistoryInsight = nil
                row.marketHistorySampleCount = item.marketHistorySampleCount or 0
                row.favorite = type(self.IsFarmingItemFavorite) == "function" and self:IsFarmingItemFavorite(row)
                row.hasFarmingMap = self:HasInventoryMaterialFarmingMap(row)
                if row.favoriteButton then
                    row.favoriteButton:SetText(row.favorite and "-" or "+")
                    if row.favoriteButton.SetSelected then
                        row.favoriteButton:SetSelected(row.favorite)
                    end
                    row.favoriteButton:Show()
                end
                if row.mapButton then
                    row.mapButton:SetText("Map")
                    if row.mapButton.SetEnabled then
                        row.mapButton:SetEnabled(row.hasFarmingMap)
                    end
                    if row.mapButton.SetAlpha then
                        row.mapButton:SetAlpha(row.hasFarmingMap and 1 or 0.42)
                    end
                    row.mapButton:Show()
                end
                row.itemText:Show()
                row.quantityText:Show()
                row.historySamplesText:Show()
                row.demandText:Show()
                row.sellRateText:Show()
                row.trendText:Show()
                row.unitValueText:Show()
                row.totalValueText:Show()
                row.itemText:SetText(item.itemLink)
                row.quantityText:SetText(tostring(item.quantity or 0))
                row.demandText:SetText(FormatInventorySoldPerDay(item.regionSoldPerDay))
                local sellRateLabel, sellRateR, sellRateG, sellRateB = GetInventorySellRateTier(item.regionSaleRate)
                row.sellRateText:SetText(FormatInventorySaleRate(item.regionSaleRate))
                row.historySamplesText:SetText(row.marketHistorySampleCount > 0 and tostring(row.marketHistorySampleCount) or "--")
                row.trendText:SetText(FormatInventoryTrendPercent(item.marketTrendPercent))
                row.unitValueText:SetText(self:FormatMoney(item.unitValue or 0))
                row.totalValueText:SetText(self:FormatMoney(item.totalValue or 0))
                row.totalValueText:SetTextColor(0.68, 0.96, 0.72)
                row.unitValueText:SetTextColor(0.72, 0.86, 1.0)
                row.trendText:SetTextColor(GetInventoryTrendColor(item.marketTrendPercent))
                row.demandText:SetTextColor(
                    item.demandColorR or 0.62,
                    item.demandColorG or 0.66,
                    item.demandColorB or 0.74
                )
                row.sellRateText:SetTextColor(sellRateR, sellRateG, sellRateB)
                if row.marketHistorySampleCount >= 10 then
                    row.historySamplesText:SetTextColor(0.68, 0.96, 0.72)
                elseif row.marketHistorySampleCount >= 3 then
                    row.historySamplesText:SetTextColor(0.72, 0.86, 1.0)
                else
                    row.historySamplesText:SetTextColor(0.62, 0.66, 0.74)
                end
                row.quantityText:SetTextColor(0.92, 0.95, 1.0)

                if item.icon then
                    row.icon:SetTexture(item.icon)
                    row.icon:Show()
                else
                    row.icon:Hide()
                end

                if row.background then
                    local alpha = index % 2 == 0 and 0.045 or 0.022
                    row.background:SetColorTexture(1, 1, 1, alpha)
                end
                if row.divider then
                    row.divider:SetShown(index < #displayRows)
                end

                row:ClearAllPoints()
                row:SetPoint("TOPLEFT", frame.inventoryContent, "TOPLEFT", 0, -yOffset)
                row:SetPoint("TOPRIGHT", frame.inventoryContent, "TOPRIGHT", 0, -yOffset)
                row:SetHeight(rowHeight)
                row:Show()

                yOffset = yOffset + rowHeight
                if index < #displayRows then
                    yOffset = yOffset + INVENTORY_ROW_SPACING
                end
            end
        end
    end

    for index = (#displayRows + 1), #(frame.inventoryRows or {}) do
        if frame.inventoryRows[index] then
            frame.inventoryRows[index]:Hide()
        end
    end

    frame.inventoryContent:SetHeight(math.max(1, yOffset))
    self:RefreshInventoryWindowLayout()
    if scrollToTop and frame.inventoryScrollFrame then
        frame.inventoryScrollFrame:SetVerticalScroll(0)
    end
end

function GoldTracker:SaveInventoryMinimumValueInput()
    local frame = self.inventoryFrame
    if not frame or not frame.minimumValueInput then
        return
    end

    frame.minimumValueCopper = ReadMinimumValueCopper(self, frame.minimumValueInput)
    frame.minimumValueInput:SetText(FormatGoldInput(self, frame.minimumValueCopper))
    self:RefreshInventoryWindow(true)
end

function GoldTracker:CreateInventoryWindow()
    if self.inventoryFrame then
        return
    end

    local addon = self
    local frame = CreateFrame("Frame", "GoldTrackerInventoryFrame", UIParent, "BasicFrameTemplateWithInset")
    frame:SetSize(INVENTORY_WINDOW_DEFAULT_WIDTH, INVENTORY_WINDOW_DEFAULT_HEIGHT)
    frame:SetPoint("CENTER", UIParent, "CENTER", 0, 40)
    frame:SetFrameStrata("DIALOG")
    if frame.SetToplevel then
        frame:SetToplevel(true)
    end
    frame:SetMovable(true)
    frame:SetResizable(true)
    if frame.SetResizeBounds then
        frame:SetResizeBounds(
            INVENTORY_WINDOW_MIN_WIDTH,
            INVENTORY_WINDOW_MIN_HEIGHT,
            INVENTORY_WINDOW_MAX_WIDTH,
            INVENTORY_WINDOW_MAX_HEIGHT
        )
    else
        if frame.SetMinResize then
            frame:SetMinResize(INVENTORY_WINDOW_MIN_WIDTH, INVENTORY_WINDOW_MIN_HEIGHT)
        end
        if frame.SetMaxResize then
            frame:SetMaxResize(INVENTORY_WINDOW_MAX_WIDTH, INVENTORY_WINDOW_MAX_HEIGHT)
        end
    end
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnMouseDown", function(self)
        self:Raise()
    end)
    frame:SetScript("OnDragStart", function(self)
        self:Raise()
        self:StartMoving()
    end)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
    frame:SetClampedToScreen(true)
    frame:Hide()

    local initialSource = self:GetAuctionableInventoryValueSource()
    frame.valueSourceID = initialSource and initialSource.id
    frame.minimumQuality = self:GetConfiguredMinimumTrackedItemQuality()
    frame.minimumValueCopper = 0
    frame.categoryFilterID = INVENTORY_CATEGORY_ALL_ID
    frame.groupByCategory = false
    frame.inventoryRows = {}
    frame.inventorySortKey = INVENTORY_DEFAULT_SORT_KEY
    frame.inventorySortAscending = INVENTORY_DEFAULT_SORT_ASCENDING

    local chrome = Theme:ApplyWindowChrome(frame, "Auctionable Inventory")
    Theme:RegisterSpecialFrame("GoldTrackerInventoryFrame")

    local controlsPanel = CreateInventoryPanel(frame, { 0.05, 0.06, 0.08, 0.94 }, { 1.0, 0.82, 0.18, 0.12 })
    controlsPanel:SetPoint("TOPLEFT", chrome, "TOPLEFT", 12, -54)
    controlsPanel:SetPoint("TOPRIGHT", chrome, "TOPRIGHT", -12, -54)
    controlsPanel:SetHeight(114)
    frame.controlsPanel = controlsPanel

    local sourceLabel = controlsPanel:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    sourceLabel:SetPoint("TOPLEFT", controlsPanel, "TOPLEFT", 14, -10)
    sourceLabel:SetText("Value source")

    local valueSourceDropdown = CreateFrame("Frame", "GoldTrackerInventoryValueSourceDropdown", controlsPanel, "UIDropDownMenuTemplate")
    valueSourceDropdown:SetPoint("TOPLEFT", sourceLabel, "BOTTOMLEFT", -16, -5)
    UIDropDownMenu_SetWidth(valueSourceDropdown, 210)
    UIDropDownMenu_Initialize(valueSourceDropdown, function(_, level)
        for _, source in ipairs(addon.VALUE_SOURCES) do
            local info = UIDropDownMenu_CreateInfo()
            local sourceID = source.id
            info.text = source.label
            info.value = sourceID
            info.checked = frame.valueSourceID == sourceID
            info.func = function()
                addon:SetAuctionableInventoryValueSource(sourceID)
                addon:RefreshOptionsControls()
                addon:RefreshInventoryWindow(true)
            end
            UIDropDownMenu_AddButton(info, level)
        end
    end)
    frame.valueSourceDropdown = valueSourceDropdown

    local qualityLabel = controlsPanel:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    qualityLabel:SetPoint("TOPLEFT", sourceLabel, "TOPLEFT", 250, 0)
    qualityLabel:SetText("Min quality")

    local qualityDropdown = CreateFrame("Frame", "GoldTrackerInventoryQualityDropdown", controlsPanel, "UIDropDownMenuTemplate")
    qualityDropdown:SetPoint("TOPLEFT", qualityLabel, "BOTTOMLEFT", -16, -5)
    UIDropDownMenu_SetWidth(qualityDropdown, 180)
    UIDropDownMenu_Initialize(qualityDropdown, function(_, level)
        for _, qualityOption in ipairs(addon.TRACKED_ITEM_QUALITY_OPTIONS) do
            local info = UIDropDownMenu_CreateInfo()
            local qualityID = qualityOption.id
            info.text = addon:GetColoredItemQualityLabel(qualityID, qualityOption.label)
            info.value = qualityID
            info.checked = frame.minimumQuality == qualityID
            info.func = function()
                frame.minimumQuality = qualityID
                addon:RefreshInventoryWindow(true)
            end
            UIDropDownMenu_AddButton(info, level)
        end
    end)
    frame.qualityDropdown = qualityDropdown

    local valueLabel = controlsPanel:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    valueLabel:SetPoint("TOPLEFT", qualityLabel, "TOPLEFT", 220, 0)
    valueLabel:SetText("Min stack value (g)")

    local minimumValueInput = CreateFrame("EditBox", nil, controlsPanel, "InputBoxTemplate")
    minimumValueInput:SetSize(92, 22)
    minimumValueInput:SetPoint("TOPLEFT", valueLabel, "BOTTOMLEFT", 0, -8)
    minimumValueInput:SetAutoFocus(false)
    minimumValueInput:SetNumeric(false)
    minimumValueInput:SetText("0")
    minimumValueInput:SetScript("OnEnterPressed", function(editBox)
        editBox:ClearFocus()
    end)
    minimumValueInput:SetScript("OnEscapePressed", function(editBox)
        frame.skipMinimumValueSave = true
        editBox:SetText(FormatGoldInput(addon, frame.minimumValueCopper))
        editBox:ClearFocus()
        frame.skipMinimumValueSave = false
    end)
    minimumValueInput:SetScript("OnEditFocusLost", function()
        if frame.skipMinimumValueSave then
            return
        end
        addon:SaveInventoryMinimumValueInput()
    end)
    frame.minimumValueInput = minimumValueInput

    local categoryLabel = controlsPanel:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    categoryLabel:SetPoint("TOPLEFT", sourceLabel, "BOTTOMLEFT", 0, -42)
    categoryLabel:SetText("Category")

    local categoryDropdown = CreateFrame("Frame", "GoldTrackerInventoryCategoryDropdown", controlsPanel, "UIDropDownMenuTemplate")
    categoryDropdown:SetPoint("TOPLEFT", categoryLabel, "BOTTOMLEFT", -16, -5)
    UIDropDownMenu_SetWidth(categoryDropdown, 210)
    UIDropDownMenu_Initialize(categoryDropdown, function(_, level)
        for _, category in ipairs(INVENTORY_CATEGORY_OPTIONS) do
            local info = UIDropDownMenu_CreateInfo()
            info.text = category.label
            info.value = category.id
            info.checked = frame.categoryFilterID == category.id
            info.func = function()
                frame.categoryFilterID = NormalizeInventoryCategoryFilter(category.id)
                addon:RefreshInventoryWindow(true)
            end
            UIDropDownMenu_AddButton(info, level)
        end
    end)
    frame.categoryDropdown = categoryDropdown

    local groupByCategoryCheckbox = CreateFrame("CheckButton", nil, controlsPanel, "UICheckButtonTemplate")
    groupByCategoryCheckbox:SetPoint("LEFT", categoryDropdown, "RIGHT", 12, 2)
    groupByCategoryCheckbox:SetChecked(frame.groupByCategory == true)
    groupByCategoryCheckbox:SetScript("OnClick", function(button)
        frame.groupByCategory = button:GetChecked() and true or false
        addon:RefreshInventoryWindow(false)
    end)
    frame.groupByCategoryCheckbox = groupByCategoryCheckbox

    local groupByCategoryLabel = controlsPanel:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    groupByCategoryLabel:SetPoint("LEFT", groupByCategoryCheckbox, "RIGHT", 3, 1)
    groupByCategoryLabel:SetText("Group items")
    groupByCategoryLabel:SetTextColor(0.92, 0.95, 1.0)
    frame.groupByCategoryLabel = groupByCategoryLabel

    local refreshButton = CreateInventoryButton(controlsPanel, 86, 22, "Refresh", "neutral")
    refreshButton:SetSize(86, 22)
    refreshButton:SetPoint("RIGHT", controlsPanel, "RIGHT", -14, -10)
    refreshButton:SetScript("OnClick", function()
        addon:SaveInventoryMinimumValueInput()
    end)
    frame.refreshButton = refreshButton

    local listPanel = CreateInventoryPanel(frame, { 0.04, 0.05, 0.07, 0.92 }, { 1.0, 0.82, 0.18, 0.10 })
    listPanel:SetPoint("TOPLEFT", controlsPanel, "BOTTOMLEFT", 0, -10)
    listPanel:SetPoint("BOTTOMRIGHT", chrome, "BOTTOMRIGHT", -12, 38)
    frame.listPanel = listPanel

    local totalHeaderButton = CreateInventoryHeaderButton(listPanel, "Stack value", INVENTORY_TOTAL_VALUE_WIDTH, "RIGHT")
    totalHeaderButton:SetPoint("TOPRIGHT", listPanel, "TOPRIGHT", -34, -12)
    totalHeaderButton:SetScript("OnClick", function()
        addon:ToggleInventorySort("totalValue")
    end)
    frame.totalHeaderButton = totalHeaderButton

    local quantityHeaderButton = CreateInventoryHeaderButton(listPanel, "Qty", INVENTORY_QUANTITY_WIDTH, "RIGHT")
    quantityHeaderButton:SetPoint("RIGHT", totalHeaderButton, "LEFT", -12, 0)
    quantityHeaderButton:SetScript("OnClick", function()
        addon:ToggleInventorySort("quantity")
    end)
    frame.quantityHeaderButton = quantityHeaderButton

    local unitHeaderButton = CreateInventoryHeaderButton(listPanel, "Unit value", INVENTORY_UNIT_VALUE_WIDTH, "RIGHT")
    unitHeaderButton:SetPoint("RIGHT", quantityHeaderButton, "LEFT", -12, 0)
    unitHeaderButton:SetScript("OnClick", function()
        addon:ToggleInventorySort("unitValue")
    end)
    frame.unitHeaderButton = unitHeaderButton

    local trendHeaderButton = CreateInventoryHeaderButton(listPanel, "Trend", INVENTORY_TREND_WIDTH, "RIGHT")
    trendHeaderButton:SetPoint("RIGHT", unitHeaderButton, "LEFT", -12, 0)
    trendHeaderButton:SetScript("OnClick", function()
        addon:ToggleInventorySort("marketTrend")
    end)
    frame.trendHeaderButton = trendHeaderButton

    local sellRateHeaderButton = CreateInventoryHeaderButton(listPanel, "Sale %", INVENTORY_SELL_RATE_WIDTH, "RIGHT")
    sellRateHeaderButton:SetPoint("RIGHT", trendHeaderButton, "LEFT", -12, 0)
    sellRateHeaderButton:SetScript("OnClick", function()
        addon:ToggleInventorySort("sellRate")
    end)
    frame.sellRateHeaderButton = sellRateHeaderButton

    local demandHeaderButton = CreateInventoryHeaderButton(listPanel, "Sold/day", INVENTORY_DEMAND_WIDTH, "RIGHT")
    demandHeaderButton:SetPoint("RIGHT", sellRateHeaderButton, "LEFT", -12, 0)
    demandHeaderButton:SetScript("OnClick", function()
        addon:ToggleInventorySort("demand")
    end)
    frame.demandHeaderButton = demandHeaderButton

    local historyHeaderButton = CreateInventoryHeaderButton(listPanel, "Hist", INVENTORY_HISTORY_WIDTH, "RIGHT")
    historyHeaderButton:SetPoint("RIGHT", demandHeaderButton, "LEFT", -12, 0)
    historyHeaderButton:SetScript("OnClick", function()
        addon:ToggleInventorySort("historySamples")
    end)
    frame.historyHeaderButton = historyHeaderButton

    local favoriteHeaderButton = CreateInventoryHeaderButton(listPanel, "Tracked", INVENTORY_TRACKED_COLUMN_WIDTH, "CENTER")
    favoriteHeaderButton:SetPoint("TOPLEFT", listPanel, "TOPLEFT", 20, -12)
    frame.favoriteHeaderButton = favoriteHeaderButton

    local mapHeaderButton = CreateInventoryHeaderButton(listPanel, "Map", INVENTORY_MAP_COLUMN_WIDTH, "CENTER")
    mapHeaderButton:SetPoint("LEFT", favoriteHeaderButton, "RIGHT", INVENTORY_ACTION_COLUMN_GAP, 0)
    frame.mapHeaderButton = mapHeaderButton

    local itemHeaderButton = CreateInventoryHeaderButton(listPanel, "Item", nil, "LEFT")
    itemHeaderButton:SetPoint("LEFT", mapHeaderButton, "RIGHT", INVENTORY_ACTION_COLUMN_GAP, 0)
    itemHeaderButton:SetPoint("RIGHT", historyHeaderButton, "LEFT", -12, 0)
    itemHeaderButton:SetScript("OnClick", function()
        addon:ToggleInventorySort("itemName")
    end)
    frame.itemHeaderButton = itemHeaderButton

    local headerUnderline = listPanel:CreateTexture(nil, "ARTWORK")
    headerUnderline:SetColorTexture(1, 0.82, 0.18, 0.18)
    headerUnderline:SetPoint("TOPLEFT", listPanel, "TOPLEFT", 12, -30)
    headerUnderline:SetPoint("TOPRIGHT", listPanel, "TOPRIGHT", -12, -30)
    headerUnderline:SetHeight(1)

    local scrollFrame = CreateFrame("ScrollFrame", nil, listPanel, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", listPanel, "TOPLEFT", 12, -36)
    scrollFrame:SetPoint("BOTTOMRIGHT", listPanel, "BOTTOMRIGHT", -26, 12)
    scrollFrame:EnableMouseWheel(true)
    scrollFrame:SetScript("OnMouseWheel", function(self, delta)
        local step = math.max(18, math.floor(self:GetHeight() * 0.12))
        local nextScroll = (tonumber(self:GetVerticalScroll()) or 0) - ((tonumber(delta) or 0) * step)
        local maxScroll = tonumber(self:GetVerticalScrollRange()) or 0
        if nextScroll < 0 then
            nextScroll = 0
        elseif nextScroll > maxScroll then
            nextScroll = maxScroll
        end
        self:SetVerticalScroll(nextScroll)
    end)
    frame.inventoryScrollFrame = scrollFrame

    local content = CreateFrame("Frame", nil, scrollFrame)
    content:SetSize(1, 1)
    scrollFrame:SetScrollChild(content)
    frame.inventoryContent = content

    local emptyText = content:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    emptyText:SetPoint("TOPLEFT", content, "TOPLEFT", 10, -12)
    emptyText:SetPoint("TOPRIGHT", content, "TOPRIGHT", -10, -12)
    emptyText:SetJustifyH("LEFT")
    emptyText:SetTextColor(0.62, 0.66, 0.74)
    emptyText:SetText("")
    emptyText:Hide()
    frame.emptyText = emptyText

    local metaText = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    metaText:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 16, 14)
    metaText:SetPoint("RIGHT", frame, "RIGHT", -40, 14)
    metaText:SetJustifyH("LEFT")
    metaText:SetTextColor(0.72, 0.76, 0.84)
    metaText:SetText("")
    frame.metaText = metaText

    Theme:CreateResizeButton(frame, {
        minWidth = INVENTORY_WINDOW_MIN_WIDTH,
        minHeight = INVENTORY_WINDOW_MIN_HEIGHT,
        maxWidth = INVENTORY_WINDOW_MAX_WIDTH,
        maxHeight = INVENTORY_WINDOW_MAX_HEIGHT,
        onResizeStop = function()
            addon:RefreshInventoryWindowLayout()
        end,
    })

    frame:RegisterEvent("BAG_UPDATE_DELAYED")
    frame:RegisterEvent("GET_ITEM_INFO_RECEIVED")
    frame:RegisterEvent("ITEM_DATA_LOAD_RESULT")
    frame:SetScript("OnEvent", function(self)
        if self:IsShown() then
            addon:RefreshInventoryWindow(false)
        end
    end)
    frame:SetScript("OnSizeChanged", function()
        if frame.isManualResizing then
            return
        end
        addon:RefreshInventoryWindowLayout()
    end)
    frame:SetScript("OnShow", function()
        if frame.suppressExplorerOnShow then
            return
        end
        addon:RefreshInventoryWindow(true)
    end)
    frame:SetScript("OnHide", function()
        GameTooltip:Hide()
    end)

    self.inventoryFrame = frame
    self:RefreshInventoryWindowControls()
end

function GoldTracker:OpenInventoryWindow()
    if type(self.OpenExplorerWindow) == "function" then
        self:OpenExplorerWindow("inventory")
        return
    end

    self:CreateInventoryWindow()
    if not self.inventoryFrame then
        return
    end

    if type(self.QueueMarketHistoryBagSnapshot) == "function" then
        self:QueueMarketHistoryBagSnapshot()
    end
    self.inventoryFrame:Show()
    self.inventoryFrame:Raise()
    self:RefreshInventoryWindow(true)
end

function GoldTracker:ToggleInventoryWindow()
    if type(self.ToggleExplorerWindow) == "function" then
        self:ToggleExplorerWindow("inventory")
        return
    end

    self:CreateInventoryWindow()
    if not self.inventoryFrame then
        return
    end

    if self.inventoryFrame:IsShown() then
        self.inventoryFrame:Hide()
    else
        self:OpenInventoryWindow()
    end
end
