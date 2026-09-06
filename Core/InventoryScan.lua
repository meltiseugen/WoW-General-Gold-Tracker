local _, NS = ...
local GoldTracker = NS.GoldTracker

local INVENTORY_FALLBACK_VALUE_SOURCE_ID = "TSM_AUCTIONINGOPNORMAL"
local INVENTORY_DEFAULT_SORT_KEY = "totalValue"
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

local function GetInventoryItemID(addon, itemLink, slotInfo)
    local itemID = tonumber(slotInfo and slotInfo.itemID)
    if itemID then
        return math.floor(itemID + 0.5)
    end
    if type(addon.GetItemIDFromLink) == "function" then
        itemID = tonumber(addon:GetItemIDFromLink(itemLink))
        if itemID then
            return math.floor(itemID + 0.5)
        end
    end
    itemID = tonumber(string.match(tostring(itemLink or ""), "item:(%d+)"))
    return itemID and math.floor(itemID + 0.5) or nil
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

function GoldTracker:NormalizeInventoryCategoryFilter(categoryID)
    if self.INVENTORY_CATEGORY_BY_ID and self.INVENTORY_CATEGORY_BY_ID[categoryID] then
        return categoryID
    end
    return self.INVENTORY_CATEGORY_ALL_ID or "all"
end

function GoldTracker:GetInventoryCategoryOption(categoryID)
    local categoryByID = self.INVENTORY_CATEGORY_BY_ID or {}
    local allID = self.INVENTORY_CATEGORY_ALL_ID or "all"
    return categoryByID[self:NormalizeInventoryCategoryFilter(categoryID)] or categoryByID[allID]
end

function GoldTracker:GetInventoryItemCategoryID(item)
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

function GoldTracker:NormalizeInventoryMinimumQuality(minimumQuality)
    local normalizedQuality = tonumber(minimumQuality)
    if normalizedQuality then
        normalizedQuality = math.floor(normalizedQuality + 0.5)
    end
    if self.TRACKED_ITEM_QUALITY_BY_ID and self.TRACKED_ITEM_QUALITY_BY_ID[normalizedQuality] then
        return normalizedQuality
    end
    return self:GetConfiguredMinimumTrackedItemQuality()
end

local function ItemPassesMinimumQuality(itemQuality, minimumQuality)
    local normalizedQuality = tonumber(itemQuality)
    if not normalizedQuality then
        return true
    end
    return math.floor(normalizedQuality + 0.5) >= minimumQuality
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
        existingItem.itemID = existingItem.itemID or item.itemID
        existingItem.categoryID = existingItem.categoryID or item.categoryID
        existingItem.categoryLabel = existingItem.categoryLabel or item.categoryLabel
        return
    end

    itemsByLink[item.itemLink] = item
    itemOrder[#itemOrder + 1] = item
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

function GoldTracker:NormalizeInventorySortKey(sortKey)
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

function GoldTracker:SortInventoryItems(items, sortKey, sortAscending)
    local normalizedSortKey = self:NormalizeInventorySortKey(sortKey)
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

function GoldTracker:BuildInventoryBagIDs()
    return BuildInventoryBagIDs()
end

function GoldTracker:InvalidateAuctionableInventoryScanCache()
    self.inventoryBuildCache = {}
    self.inventoryBuildCacheVersion = math.max(0, math.floor(tonumber(self.inventoryBuildCacheVersion) or 0)) + 1
end

function GoldTracker:InvalidateInventoryWindowCache()
    self:InvalidateAuctionableInventoryScanCache()
end

function GoldTracker:BuildAuctionableInventoryItemList(valueSourceID, minimumQuality, minimumValueCopper, sortKey, sortAscending, categoryFilterID)
    local source = self.VALUE_SOURCE_BY_ID[valueSourceID] or self:GetAuctionableInventoryValueSource()
    local sourceID = source and source.id
    local normalizedMinimumQuality = self:NormalizeInventoryMinimumQuality(minimumQuality)
    local normalizedMinimumValue = math.max(0, math.floor(tonumber(minimumValueCopper) or 0))
    local cacheKey = GetInventoryBuildCacheKey(self, sourceID, normalizedMinimumQuality)
    local cachedBuild = type(self.inventoryBuildCache) == "table" and self.inventoryBuildCache[cacheKey] or nil
    local candidateItems
    local scannedStacks
    if cachedBuild then
        candidateItems = cachedBuild.items or {}
        scannedStacks = tonumber(cachedBuild.scannedStacks) or 0
    else
        local itemsByLink = {}
        candidateItems = {}
        local demandCache = {}
        scannedStacks = 0

        for _, bagID in ipairs(BuildInventoryBagIDs()) do
            local slotCount = GetContainerSlotCount(bagID)
            for slotIndex = 1, slotCount do
                local slotInfo = GetContainerSlotInfo(bagID, slotIndex)
                local itemLink = GetContainerSlotLink(bagID, slotIndex, slotInfo)
                if type(itemLink) == "string" and itemLink ~= "" then
                    scannedStacks = scannedStacks + 1

                    if not self:IsBagItemBindingRestricted(bagID, slotIndex, itemLink, slotInfo) then
                        local itemName, infoQuality, itemIcon = GetItemDisplayData(itemLink, slotInfo)
                        local itemQuality = tonumber(slotInfo and slotInfo.quality) or tonumber(infoQuality) or self:GetItemQualityFromLink(itemLink)
                        if ItemPassesMinimumQuality(itemQuality, normalizedMinimumQuality) then
                            local itemID = GetInventoryItemID(self, itemLink, slotInfo)
                            local unitValue, resolvedSourceID, resolvedSourceLabel =
                                GetInventoryUnitValue(self, sourceID, itemLink)
                            local quantity = math.max(1, math.floor(tonumber(slotInfo and slotInfo.stackCount) or 1))
                            local stackValue = math.max(0, math.floor((unitValue * quantity) + 0.5))
                            if unitValue > 0 then
                                local itemMetadata = GetInventoryItemMetadata(itemLink)
                                itemMetadata.categoryID = self:GetInventoryItemCategoryID(itemMetadata)
                                local category = self:GetInventoryCategoryOption(itemMetadata.categoryID)
                                local demandData = GetInventoryRegionalDemandData(self, itemLink, demandCache) or {}
                                AddInventoryItem(itemsByLink, candidateItems, {
                                    itemID = itemID,
                                    itemLink = itemLink,
                                    itemName = itemName or itemLink,
                                    itemQuality = itemQuality,
                                    icon = itemIcon,
                                    itemType = itemMetadata.itemType,
                                    itemSubType = itemMetadata.itemSubType,
                                    itemEquipLoc = itemMetadata.itemEquipLoc,
                                    itemClassID = itemMetadata.itemClassID,
                                    itemSubclassID = itemMetadata.itemSubclassID,
                                    isCraftingReagent = itemMetadata.isCraftingReagent,
                                    categoryID = itemMetadata.categoryID,
                                    categoryLabel = category and category.label or "Uncategorized",
                                    bagID = bagID,
                                    slotIndex = slotIndex,
                                    quantity = quantity,
                                    unitValue = unitValue,
                                    valueSourceID = resolvedSourceID or sourceID,
                                    valueSourceLabel = resolvedSourceLabel,
                                    valueSourceWasFallback = resolvedSourceID ~= sourceID,
                                    totalValue = stackValue,
                                    stackCount = 1,
                                    regionSoldPerDay = demandData.regionSoldPerDay,
                                    regionSaleRate = demandData.regionSaleRate,
                                    marketValue = demandData.marketValue,
                                    historicalValue = demandData.historicalValue,
                                    marketTrendPercent = demandData.marketTrendPercent,
                                    demandTier = demandData.demandTier,
                                    demandLabel = demandData.demandLabel,
                                    demandColorR = demandData.demandColorR,
                                    demandColorG = demandData.demandColorG,
                                    demandColorB = demandData.demandColorB,
                                })
                            end
                        end
                    end
                end
            end
        end

        if type(self.inventoryBuildCache) ~= "table" then
            self.inventoryBuildCache = {}
        end
        self.inventoryBuildCache[cacheKey] = {
            items = candidateItems,
            scannedStacks = scannedStacks,
        }
    end

    local matchedStacks = 0
    local totalValue = 0
    local totalQuantity = 0
    local normalizedCategoryFilterID = self:NormalizeInventoryCategoryFilter(categoryFilterID)

    local items = {}
    for _, item in ipairs(candidateItems) do
        local categoryID = item.categoryID or self:GetInventoryItemCategoryID(item)
        item.categoryID = categoryID
        local category = self:GetInventoryCategoryOption(categoryID)
        item.categoryLabel = category and category.label or "Uncategorized"
        if item.totalValue > normalizedMinimumValue
            and (normalizedCategoryFilterID == (self.INVENTORY_CATEGORY_ALL_ID or "all") or categoryID == normalizedCategoryFilterID) then
            if type(self.GetMarketHistorySampleCount) == "function" then
                item.marketHistorySampleCount = self:GetMarketHistorySampleCount(item.itemLink)
            else
                item.marketHistorySampleCount = 0
            end
            matchedStacks = matchedStacks + item.stackCount
            totalValue = totalValue + item.totalValue
            totalQuantity = totalQuantity + item.quantity
            items[#items + 1] = item
        end
    end

    self:SortInventoryItems(items, sortKey, sortAscending)

    return items, totalValue, totalQuantity, scannedStacks, matchedStacks
end
