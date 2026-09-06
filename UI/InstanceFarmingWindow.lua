local _, NS = ...
local GoldTracker = NS.GoldTracker
local Theme = NS.JanisTheme

local WINDOW_WIDTH = 1240
local WINDOW_HEIGHT = 620
local WINDOW_MIN_WIDTH = 1100
local WINDOW_MIN_HEIGHT = 420
local ROW_HEIGHT = 24
local ROW_SPACING = 2
local ROW_STRIDE = ROW_HEIGHT + ROW_SPACING
local ICON_SIZE = 18
local COLUMN_GAP = 8
local TRACK_WIDTH = 58
local EXPANSION_MIN_WIDTH = 102
local INSTANCE_MIN_WIDTH = 130
local BOSS_MIN_WIDTH = 118
local TYPE_WIDTH = 60
local VALUE_MIN_WIDTH = 92
local DETAILS_WIDTH = 64
local MAP_WIDTH = 48
local ITEM_MIN_WIDTH = 170
local HEADER_LEFT_INSET = 12
local ROW_RIGHT_PADDING = 6
local SORT_ICON_SIZE = 10
local HORIZONTAL_SCROLL_HEIGHT = 14
local TRACKED_BUTTON_WIDTH = 24
local TRACKED_BUTTON_HEIGHT = 20
local BACKGROUND_SCAN_ITEMS_PER_TICK = 120
local FOREGROUND_SCAN_ITEMS_PER_TICK = 2200
local SCAN_REFRESH_INTERVAL = 0.35
local ITEM_REFRESH_DELAY = 0.5
local SCAN_CACHE_VERSION = 1
local SCAN_CACHE_MAX_ENTRIES = 30
local MAX_PENDING_BINDING_RETRIES = 12
local DEFAULT_SORT_KEY = "value"
local EXPANSION_CURRENT_ID = "current"
local EXPANSION_ALL_ID = "all"

local BIND_ON_ACQUIRE = LE_ITEM_BIND_ON_ACQUIRE or (Enum and Enum.ItemBind and Enum.ItemBind.OnAcquire) or 1
local BIND_ON_EQUIP = LE_ITEM_BIND_ON_EQUIP or (Enum and Enum.ItemBind and Enum.ItemBind.OnEquip) or 2
local BIND_ON_USE = LE_ITEM_BIND_ON_USE or (Enum and Enum.ItemBind and Enum.ItemBind.OnUse) or 3
local BIND_QUEST = LE_ITEM_BIND_QUEST or (Enum and Enum.ItemBind and Enum.ItemBind.Quest) or 4
local BIND_TO_ACCOUNT = LE_ITEM_BIND_TO_ACCOUNT or (Enum and Enum.ItemBind and Enum.ItemBind.ToAccount)

local SORT_KEYS = {
    tracked = true,
    expansion = true,
    type = true,
    instanceName = true,
    bossName = true,
    itemName = true,
    value = true,
    marketValue = true,
    regionMarketValue = true,
    averageValue = true,
}

local SCAN_MODE_OPTIONS = {
    { id = "background", label = "Background", batchSize = BACKGROUND_SCAN_ITEMS_PER_TICK },
    { id = "foreground", label = "Foreground", batchSize = FOREGROUND_SCAN_ITEMS_PER_TICK },
}

local GetInstanceDisplayName
local GetBossDisplayName
local GetPendingBindingCount

local CONTENT_TYPE_OPTIONS = {
    { id = "all", label = "All" },
    { id = "dungeon", label = "Dungeons" },
    { id = "raid", label = "Raids" },
}

local function CreatePanel(parent, bg, border)
    return Theme:CreatePanel(parent, bg, border)
end

local function CreateButton(parent, width, height, text, paletteKey)
    return Theme:CreateButton(parent, width, height, text, paletteKey)
end

local function SetInstanceFarmingFrameLevel(frame, referenceFrame, offset)
    if not frame or not referenceFrame or type(frame.SetFrameLevel) ~= "function" or type(referenceFrame.GetFrameLevel) ~= "function" then
        return
    end

    frame:SetFrameLevel((referenceFrame:GetFrameLevel() or 0) + (offset or 1))
end

local function CreateHeaderButton(parent, label, width, justifyH)
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
    sortIcon:SetSize(SORT_ICON_SIZE, SORT_ICON_SIZE)
    sortIcon:SetPoint("RIGHT", button, "RIGHT", 0, 0)
    sortIcon:Hide()
    button.sortIcon = sortIcon

    return button
end

local function GetData()
    local data = NS.InstanceDropsData
    if type(data) ~= "table" then
        return { expansions = { currentID = nil, options = {} }, instances = {} }
    end
    return data
end

local function GetItemInfoByID(itemID)
    if C_Item and type(C_Item.GetItemInfo) == "function" then
        return C_Item.GetItemInfo(itemID)
    end
    if type(GetItemInfo) == "function" then
        return GetItemInfo(itemID)
    end
    return nil
end

local function GetItemInstantInfoByID(itemID)
    if type(GetItemInfoInstant) == "function" then
        return GetItemInfoInstant(itemID)
    end
    return nil
end

local function RequestItemData(addon, itemID)
    if Item and type(Item.CreateFromItemID) == "function" then
        local item = Item:CreateFromItemID(itemID)
        if item and type(item.ContinueOnItemLoad) == "function" then
            item:ContinueOnItemLoad(function()
                addon:UpdateInstanceFarmingItemDisplayData(itemID)
                addon:ScheduleInstanceFarmingWindowRefresh(false)
            end)
            return
        end
    end

    if C_Item and type(C_Item.RequestLoadItemDataByID) == "function" then
        pcall(C_Item.RequestLoadItemDataByID, itemID)
    end
end

local function ApplyItemDisplayData(row, itemID)
    local normalizedItemID = tonumber(itemID or row and row.itemID)
    if type(row) ~= "table" or not normalizedItemID then
        return false
    end
    normalizedItemID = math.floor(normalizedItemID + 0.5)

    local itemName, itemLink, itemQuality, _, _, _, _, _, _, itemIcon = GetItemInfoByID(normalizedItemID)
    if not itemName and C_Item and type(C_Item.GetItemNameByID) == "function" then
        local ok, resolvedName = pcall(C_Item.GetItemNameByID, normalizedItemID)
        if ok and type(resolvedName) == "string" and resolvedName ~= "" then
            itemName = resolvedName
        end
    end
    if not itemIcon then
        local _, _, _, _, instantIcon = GetItemInstantInfoByID(normalizedItemID)
        itemIcon = instantIcon
    end

    local changed = false
    if itemName and row.itemName ~= itemName then
        row.itemName = itemName
        changed = true
    end
    if itemLink and row.itemLink ~= itemLink then
        row.itemLink = itemLink
        changed = true
    end
    if itemQuality and tonumber(row.itemQuality) ~= tonumber(itemQuality) then
        row.itemQuality = tonumber(itemQuality)
        changed = true
    end
    if itemIcon and row.icon ~= itemIcon then
        row.icon = itemIcon
        changed = true
    end

    return changed
end

local function EnsureRowItemDisplayData(addon, row)
    local itemID = tonumber(row and row.itemID)
    if not itemID then
        return false
    end
    local changed = ApplyItemDisplayData(row, itemID)
    if (not row.itemName or not row.itemLink) and not row.dataRequested then
        row.dataRequested = true
        RequestItemData(addon, itemID)
    end
    return changed
end

local function GetTSMValue(addon, priceSource, itemID)
    if type(priceSource) ~= "string" or priceSource == "" then
        return 0
    end
    if type(addon.GetTSMItemValueForItemID) ~= "function" then
        return 0
    end
    return addon:GetTSMItemValueForItemID(priceSource, itemID, true) or 0
end

local function GetPriceSnapshot(addon, itemID, valueSource)
    local selectedValue = 0
    if valueSource and valueSource.tsmKey then
        selectedValue = GetTSMValue(addon, valueSource.tsmKey, itemID)
    end

    return {
        value = selectedValue,
        marketValue = GetTSMValue(addon, "DBMarket", itemID),
        regionMarketValue = GetTSMValue(addon, "DBRegionMarketAvg", itemID),
        averageValue = GetTSMValue(addon, "DBRegionSaleAvg", itemID),
    }
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

local function NormalizeScanMode(modeID)
    if modeID == "foreground" then
        return "foreground"
    end
    return "background"
end

local function GetScanModeOption(modeID)
    local normalizedModeID = NormalizeScanMode(modeID)
    for _, option in ipairs(SCAN_MODE_OPTIONS) do
        if option.id == normalizedModeID then
            return option
        end
    end
    return SCAN_MODE_OPTIONS[1]
end

local function NormalizeContentTypeFilter(filterID)
    if filterID == "dungeon" or filterID == "raid" then
        return filterID
    end
    return "all"
end

local function GetContentTypeFilterLabel(filterID)
    local normalizedFilterID = NormalizeContentTypeFilter(filterID)
    for _, option in ipairs(CONTENT_TYPE_OPTIONS) do
        if option.id == normalizedFilterID then
            return option.label
        end
    end
    return "All"
end

local function GetMapName(mapID)
    local normalizedMapID = tonumber(mapID)
    if normalizedMapID and C_Map and type(C_Map.GetMapInfo) == "function" then
        local ok, mapInfo = pcall(C_Map.GetMapInfo, normalizedMapID)
        if ok and mapInfo and type(mapInfo.name) == "string" and mapInfo.name ~= "" then
            return mapInfo.name
        end
    end
    return "Map " .. tostring(normalizedMapID or mapID or "?")
end

local function GetMapInfo(mapID)
    local normalizedMapID = tonumber(mapID)
    if not normalizedMapID or not C_Map or type(C_Map.GetMapInfo) ~= "function" then
        return nil
    end
    local ok, mapInfo = pcall(C_Map.GetMapInfo, normalizedMapID)
    if ok and type(mapInfo) == "table" then
        return mapInfo
    end
    return nil
end

local function GetMapLineage(mapID)
    local lineage = {}
    local currentMapID = tonumber(mapID)
    local visited = {}
    while currentMapID and currentMapID > 0 and not visited[currentMapID] and #lineage < 15 do
        visited[currentMapID] = true
        lineage[#lineage + 1] = currentMapID
        local mapInfo = GetMapInfo(currentMapID)
        currentMapID = tonumber(mapInfo and mapInfo.parentMapID)
    end
    return lineage
end

local function IsContinentMap(mapInfo)
    if not mapInfo then
        return false
    end
    local mapType = tonumber(mapInfo.mapType)
    if Enum and Enum.UIMapType and Enum.UIMapType.Continent and mapType == Enum.UIMapType.Continent then
        return true
    end
    return mapType == 2
end

local function GetContinentMapIDFromLineage(lineage)
    for _, mapID in ipairs(lineage or {}) do
        if IsContinentMap(GetMapInfo(mapID)) then
            return mapID
        end
    end
    return lineage and lineage[#lineage] or nil
end

local function GetZoneMapIDFromLineage(lineage)
    return lineage and lineage[2] or nil
end

local function NormalizeMapCoord(value)
    local coord = tonumber(value)
    if not coord then
        return nil
    end
    if coord > 1 then
        coord = coord / 100
    end
    if coord < 0 or coord > 1 then
        return nil
    end
    return coord
end

local function ReadVectorCoordinates(position)
    if type(position) ~= "table" and type(position) ~= "userdata" then
        return nil, nil
    end

    local getXY
    if type(position) == "table" then
        getXY = position.GetXY
    else
        local ok, value = pcall(function()
            return position.GetXY
        end)
        if ok then
            getXY = value
        end
    end
    if type(getXY) == "function" then
        local ok, x, y = pcall(getXY, position)
        if ok then
            return NormalizeMapCoord(x), NormalizeMapCoord(y)
        end
    end

    if type(position) == "table" then
        return NormalizeMapCoord(position.x or position[1]), NormalizeMapCoord(position.y or position[2])
    end

    local okX, x = pcall(function()
        return position.x or position[1]
    end)
    local okY, y = pcall(function()
        return position.y or position[2]
    end)
    return NormalizeMapCoord(okX and x or nil), NormalizeMapCoord(okY and y or nil)
end

local function LoadEncounterJournal()
    if C_AddOns and type(C_AddOns.LoadAddOn) == "function" then
        pcall(C_AddOns.LoadAddOn, "Blizzard_EncounterJournal")
    elseif type(LoadAddOn) == "function" then
        pcall(LoadAddOn, "Blizzard_EncounterJournal")
    end
end

local function GetAreaPOIPosition(mapID, areaPoiID)
    if not areaPoiID or not C_AreaPoiInfo or type(C_AreaPoiInfo.GetAreaPOIInfo) ~= "function" then
        return nil, nil
    end
    local ok, poiInfo = pcall(C_AreaPoiInfo.GetAreaPOIInfo, mapID, areaPoiID)
    if not ok or type(poiInfo) ~= "table" then
        return nil, nil
    end
    local x, y = ReadVectorCoordinates(poiInfo.position)
    return x or NormalizeMapCoord(poiInfo.x), y or NormalizeMapCoord(poiInfo.y)
end

local function GetEntranceCoordinates(mapID, entranceInfo)
    local x, y = ReadVectorCoordinates(entranceInfo and entranceInfo.position)
    if x and y then
        return x, y
    end
    x = NormalizeMapCoord(entranceInfo and (entranceInfo.x or entranceInfo.atlasX))
    y = NormalizeMapCoord(entranceInfo and (entranceInfo.y or entranceInfo.atlasY))
    if x and y then
        return x, y
    end
    return GetAreaPOIPosition(mapID, entranceInfo and entranceInfo.areaPoiID)
end

local function FindInstanceEntranceOnMap(row, mapID)
    local normalizedMapID = tonumber(mapID)
    local journalInstanceID = tonumber(row and row.instanceEncounterJournalID)
    if not normalizedMapID or not journalInstanceID then
        return nil
    end
    LoadEncounterJournal()
    if not C_EncounterJournal or type(C_EncounterJournal.GetDungeonEntrancesForMap) ~= "function" then
        return nil
    end

    local ok, entrances = pcall(C_EncounterJournal.GetDungeonEntrancesForMap, normalizedMapID)
    if not ok or type(entrances) ~= "table" then
        return nil
    end
    for _, entranceInfo in pairs(entrances) do
        if type(entranceInfo) == "table" and tonumber(entranceInfo.journalInstanceID) == journalInstanceID then
            local x, y = GetEntranceCoordinates(normalizedMapID, entranceInfo)
            if x and y then
                return {
                    mapID = normalizedMapID,
                    x = x,
                    y = y,
                    label = entranceInfo.name or (GetInstanceDisplayName(row) .. " entrance"),
                    itemName = row.itemName,
                    spotLocation = GetInstanceDisplayName(row),
                    routeType = "Instance entrance",
                }
            end
        end
    end
    return nil
end

local function BuildStaticEntrancePin(row, mapID)
    local entrance = row and row.instanceEntrance
    local x = NormalizeMapCoord(entrance and entrance.x)
    local y = NormalizeMapCoord(entrance and entrance.y)
    local entranceMapID = tonumber(entrance and entrance.mapID) or tonumber(mapID)
    if not x or not y or not entranceMapID or entranceMapID ~= tonumber(mapID) then
        return nil
    end
    return {
        mapID = entranceMapID,
        x = x,
        y = y,
        label = entrance.label or (GetInstanceDisplayName(row) .. " entrance"),
        itemName = row.itemName,
        spotLocation = GetInstanceDisplayName(row),
        routeType = "Instance entrance",
    }
end

local function IsTrashInstanceDrop(row)
    local bossName = string.lower(tostring(row and row.bossName or ""))
    return bossName:find("trash", 1, true) ~= nil
end

local function AddInstanceMapOption(options, seen, option)
    local mapID = tonumber(option and option.mapID)
    if not mapID or seen[mapID] then
        return
    end
    option.mapID = mapID
    option.pins = type(option.pins) == "table" and option.pins or {}
    options[#options + 1] = option
    seen[mapID] = true
end

local function GetExpansionByID(expansionID)
    local normalizedID = tonumber(expansionID)
    if not normalizedID then
        return nil
    end
    for _, option in ipairs(GetData().expansions and GetData().expansions.options or {}) do
        if tonumber(option.id) == normalizedID then
            return option
        end
    end
    return nil
end

local function NormalizeExpansionFilter(filterID)
    if filterID == EXPANSION_ALL_ID or filterID == EXPANSION_CURRENT_ID then
        return filterID
    end
    local expansionID = tonumber(filterID)
    if expansionID and GetExpansionByID(expansionID) then
        return tostring(math.floor(expansionID + 0.5))
    end
    return EXPANSION_CURRENT_ID
end

local function GetExpansionFilterLabel(filterID)
    local normalizedFilterID = NormalizeExpansionFilter(filterID)
    if normalizedFilterID == EXPANSION_ALL_ID then
        return "All"
    end
    if normalizedFilterID == EXPANSION_CURRENT_ID then
        local currentID = GetData().expansions and GetData().expansions.currentID
        local currentExpansion = currentID and GetExpansionByID(currentID)
        return currentExpansion and currentExpansion.label or "Current"
    end
    local expansion = GetExpansionByID(normalizedFilterID)
    return expansion and expansion.label or tostring(normalizedFilterID)
end

local function GetExpansionOptions()
    local options = {
        { id = EXPANSION_CURRENT_ID, label = "Current: " .. GetExpansionFilterLabel(EXPANSION_CURRENT_ID) },
        { id = EXPANSION_ALL_ID, label = "All" },
    }
    for _, expansion in ipairs(GetData().expansions and GetData().expansions.options or {}) do
        options[#options + 1] = { id = tostring(expansion.id), label = expansion.label or tostring(expansion.id) }
    end
    return options
end

local function InstanceMatchesExpansion(instance, filterID)
    local normalizedFilterID = NormalizeExpansionFilter(filterID)
    if normalizedFilterID == EXPANSION_ALL_ID then
        return true
    end
    local targetID = normalizedFilterID == EXPANSION_CURRENT_ID
        and tonumber(GetData().expansions and GetData().expansions.currentID)
        or tonumber(normalizedFilterID)
    return targetID ~= nil and tonumber(instance and instance.expansionID) == targetID
end

local function InstanceMatchesContentType(instance, filterID)
    local normalizedFilterID = NormalizeContentTypeFilter(filterID)
    return normalizedFilterID == "all" or instance and instance.contentType == normalizedFilterID
end

local function GetFavoriteKey(row)
    if GoldTracker and type(GoldTracker.GetFarmingFavoriteKey) == "function" then
        return GoldTracker:GetFarmingFavoriteKey(row)
    end
    local itemID = tonumber(row and row.itemID)
    if not itemID then
        return nil
    end
    return "item:" .. tostring(math.floor(itemID + 0.5))
end

local function CloneResultForCache(row)
    if type(row) ~= "table" or not tonumber(row.itemID) then
        return nil
    end
    return {
        itemID = math.floor(tonumber(row.itemID) + 0.5),
        itemName = row.itemName,
        itemLink = row.itemLink,
        itemQuality = row.itemQuality,
        icon = row.iconTexture or ((type(row.icon) == "number" or type(row.icon) == "string") and row.icon or nil),
        bindType = row.bindType,
        expansionID = row.expansionID,
        expansionLabel = row.expansionLabel,
        contentType = row.contentType,
        instanceName = row.instanceName,
        instanceEncounterJournalID = row.instanceEncounterJournalID,
        instanceMapID = row.instanceMapID,
        instanceEntrance = row.instanceEntrance,
        bossName = row.bossName,
        bossEncounterJournalID = row.bossEncounterJournalID,
        bossMapID = row.bossMapID,
        bossX = row.bossX,
        bossY = row.bossY,
        difficulties = row.difficulties,
        npcID = row.npcID,
        rareName = row.rareName,
        locationLabel = row.locationLabel,
        expansionFilterID = row.expansionFilterID,
        expansionFilterLabel = row.expansionFilterLabel,
        locations = row.locations,
        value = tonumber(row.value) or 0,
        marketValue = tonumber(row.marketValue) or 0,
        regionMarketValue = tonumber(row.regionMarketValue) or 0,
        averageValue = tonumber(row.averageValue) or 0,
        valueSourceID = row.valueSourceID,
        valueSourceLabel = row.valueSourceLabel,
        marketHistoryItemKey = row.marketHistoryItemKey,
        farmingSourceType = row.farmingSourceType,
    }
end

local function IsBindRestricted(addon, itemID, itemLink, bindType)
    local normalizedBindType = tonumber(bindType)
    if normalizedBindType then
        if normalizedBindType == BIND_ON_ACQUIRE or normalizedBindType == BIND_QUEST then
            return true
        end
        if BIND_TO_ACCOUNT and normalizedBindType == BIND_TO_ACCOUNT then
            return true
        end
    end

    if itemLink and type(addon.IsLootItemBindingRestricted) == "function" then
        return addon:IsLootItemBindingRestricted(itemLink)
    end
    return false
end

local function IsPossiblyAuctionable(addon, itemID, itemLink, bindType)
    if IsBindRestricted(addon, itemID, itemLink, bindType) then
        return false
    end

    local normalizedBindType = tonumber(bindType)
    if not normalizedBindType then
        return false
    end
    return normalizedBindType == 0 or normalizedBindType == BIND_ON_EQUIP or normalizedBindType == BIND_ON_USE
end

local function IsDisplayRowAuctionable(addon, row)
    local itemID = tonumber(row and row.itemID)
    if not itemID then
        return false
    end

    local bindType = tonumber(row.bindType)
    if not bindType then
        bindType = select(14, GetItemInfoByID(itemID))
        if bindType then
            row.bindType = bindType
        else
            RequestItemData(addon, itemID)
            return false
        end
    end

    return IsPossiblyAuctionable(addon, itemID, row.itemLink or ("item:" .. tostring(math.floor(itemID + 0.5))), bindType)
end

local function ResolveItemCache(addon, state, source, itemID)
    state.itemCache = state.itemCache or {}
    local cacheKey = tostring(itemID) .. "|" .. tostring(source and source.id or "")
    local cached = state.itemCache[cacheKey]
    if cached then
        return cached
    end

    local itemName, itemLink, itemQuality, _, _, _, _, _, _, itemIcon = GetItemInfoByID(itemID)
    local bindType = select(14, GetItemInfoByID(itemID))
    if not itemName then
        local _, _, _, _, instantIcon = GetItemInstantInfoByID(itemID)
        itemIcon = itemIcon or instantIcon
        RequestItemData(addon, itemID)
    end
    if not bindType then
        RequestItemData(addon, itemID)
        return { itemID = itemID, pending = true, unloadedBinding = true }
    end
    local itemKeyLink = itemLink or ("item:" .. tostring(itemID))
    if not IsPossiblyAuctionable(addon, itemID, itemLink or itemKeyLink, bindType) then
        state.skippedRestrictedBindingCount = (state.skippedRestrictedBindingCount or 0) + 1
        cached = { itemID = itemID, restricted = true }
        state.itemCache[cacheKey] = cached
        return cached
    end

    local prices = GetPriceSnapshot(addon, itemID, source)
    cached = {
        itemID = itemID,
        itemName = itemName,
        itemLink = itemLink,
        itemQuality = itemQuality,
        icon = itemIcon,
        bindType = bindType,
        value = prices.value,
        marketValue = prices.marketValue,
        regionMarketValue = prices.regionMarketValue,
        averageValue = prices.averageValue,
        marketHistoryItemKey = type(addon.GetMarketHistoryItemKey) == "function" and addon:GetMarketHistoryItemKey(itemLink, itemID) or nil,
    }
    state.itemCache[cacheKey] = cached
    return cached
end

local function AddResult(state, sourceRow, itemCache)
    if not itemCache or itemCache.restricted then
        return
    end
    if (tonumber(itemCache.value) or 0) < (tonumber(state.minimumValueCopper) or 0) then
        return
    end

    local row = {
        itemID = itemCache.itemID,
        itemName = itemCache.itemName,
        itemLink = itemCache.itemLink,
        itemQuality = itemCache.itemQuality,
        icon = itemCache.icon,
        bindType = itemCache.bindType,
        expansionID = sourceRow.expansionID,
        expansionLabel = sourceRow.expansionLabel,
        contentType = sourceRow.contentType,
        instanceName = sourceRow.instanceName,
        instanceEncounterJournalID = sourceRow.instanceEncounterJournalID,
        instanceMapID = sourceRow.instanceMapID,
        instanceEntrance = sourceRow.instanceEntrance,
        bossName = sourceRow.bossName,
        bossEncounterJournalID = sourceRow.bossEncounterJournalID,
        bossMapID = sourceRow.bossMapID,
        bossX = sourceRow.bossX,
        bossY = sourceRow.bossY,
        difficulties = sourceRow.difficulties,
        value = itemCache.value,
        marketValue = itemCache.marketValue,
        regionMarketValue = itemCache.regionMarketValue,
        averageValue = itemCache.averageValue,
        valueSourceID = state.valueSourceID,
        valueSourceLabel = state.valueSourceLabel,
        marketHistoryItemKey = itemCache.marketHistoryItemKey,
    }
    row.favoriteKey = GetFavoriteKey(row)
    state.results[#state.results + 1] = row
end

local function BuildSourceRows(expansionFilterID, contentTypeFilterID)
    local rows = {}
    local seenByInstanceAndItem = {}
    for _, instance in ipairs(GetData().instances or {}) do
        if InstanceMatchesExpansion(instance, expansionFilterID) and InstanceMatchesContentType(instance, contentTypeFilterID) then
            for _, boss in ipairs(instance.bosses or {}) do
                for _, loot in ipairs(boss.loot or {}) do
                    local itemID = tonumber(loot.itemID)
                    if itemID then
                        local normalizedItemID = math.floor(itemID + 0.5)
                        local instanceKey = tostring(instance.encounterJournalID or instance.mapID or instance.name or "?")
                        seenByInstanceAndItem[instanceKey .. ":" .. tostring(normalizedItemID)] = true
                        rows[#rows + 1] = {
                            itemID = normalizedItemID,
                            expansionID = instance.expansionID,
                            expansionLabel = instance.expansion or GetExpansionFilterLabel(instance.expansionID),
                            contentType = instance.contentType,
                            instanceName = instance.name,
                            instanceEncounterJournalID = instance.encounterJournalID,
                            instanceMapID = instance.mapID,
                            instanceEntrance = instance.entrance or instance.entranceLocation,
                            bossName = boss.name,
                            bossEncounterJournalID = boss.encounterJournalID,
                            bossMapID = boss.mapID,
                            bossX = boss.x or boss.coordX,
                            bossY = boss.y or boss.coordY,
                            difficulties = loot.difficulties,
                        }
                    end
                end
            end
        end
    end
    return rows
end

local function NormalizeSortKey(sortKey)
    if SORT_KEYS[sortKey] then
        return sortKey
    end
    return DEFAULT_SORT_KEY
end

local function GetSortValue(row, sortKey)
    if sortKey == "tracked" then
        return row and row.tracked and 1 or 0
    end
    if sortKey == "expansion" then
        return string.lower(tostring(row and row.expansionLabel or ""))
    end
    if sortKey == "type" then
        return string.lower(tostring(row and row.contentType or ""))
    end
    if sortKey == "instanceName" then
        return string.lower(tostring(row and row.instanceName or ""))
    end
    if sortKey == "bossName" then
        return string.lower(tostring(row and row.bossName or ""))
    end
    if sortKey == "itemName" then
        return string.lower(tostring(row and (row.itemName or row.itemLink or row.itemID) or ""))
    end
    return tonumber(row and row[sortKey]) or 0
end

local function SortRows(rows, sortKey, sortAscending)
    local normalizedSortKey = NormalizeSortKey(sortKey)
    local ascending = sortAscending == true
    table.sort(rows, function(left, right)
        local leftValue = GetSortValue(left, normalizedSortKey)
        local rightValue = GetSortValue(right, normalizedSortKey)
        if leftValue ~= rightValue then
            if ascending then
                return leftValue < rightValue
            end
            return leftValue > rightValue
        end
        local leftName = string.lower(tostring(left and (left.itemName or left.itemID) or ""))
        local rightName = string.lower(tostring(right and (right.itemName or right.itemID) or ""))
        return leftName < rightName
    end)
end

local function SetItemTooltip(row)
    GameTooltip:SetOwner(row, "ANCHOR_CURSOR")
    if row.itemLink then
        GameTooltip:SetHyperlink(row.itemLink)
    elseif row.itemID and GameTooltip.SetItemByID then
        GameTooltip:SetItemByID(row.itemID)
    else
        GameTooltip:AddLine(row.itemName or ("Item " .. tostring(row.itemID or "")), 1, 1, 1)
    end
    GameTooltip:Show()
end

local function SetColumn(frameOrText, parent, left, width)
    frameOrText:ClearAllPoints()
    frameOrText:SetPoint("LEFT", parent, "LEFT", left, 0)
    frameOrText:SetWidth(width)
end

local function SetHeaderColumn(frameOrText, listPanel, left, width)
    frameOrText:ClearAllPoints()
    frameOrText:SetPoint("TOPLEFT", listPanel, "TOPLEFT", left, -12)
    frameOrText:SetWidth(width)
end

local function FormatContentType(contentType)
    if contentType == "raid" then
        return "Raid"
    end
    if contentType == "dungeon" then
        return "Dungeon"
    end
    return tostring(contentType or "")
end

local function SplitCamelCaseName(value)
    local text = tostring(value or "")
    text = text:gsub("CFR", "")
    text = text:gsub("([a-z])([A-Z])", "%1 %2")
    text = text:gsub("([A-Z])([A-Z][a-z])", "%1 %2")
    return text
end

function GetInstanceDisplayName(row)
    local instanceID = tonumber(row and row.instanceEncounterJournalID)
    if instanceID and type(EJ_GetInstanceInfo) == "function" then
        local ok, name = pcall(EJ_GetInstanceInfo, instanceID)
        if ok and type(name) == "string" and name ~= "" then
            return name
        end
    end
    return SplitCamelCaseName(row and row.instanceName)
end

function GetBossDisplayName(row)
    local encounterID = tonumber(row and row.bossEncounterJournalID)
    if encounterID and type(EJ_GetEncounterInfo) == "function" then
        local ok, name = pcall(EJ_GetEncounterInfo, encounterID)
        if ok and type(name) == "string" and name ~= "" then
            return name
        end
    end
    return SplitCamelCaseName(row and row.bossName)
end

function GoldTracker:BuildInstanceFarmingMapOptions(row)
    if type(row) ~= "table" then
        return {}
    end

    local options = {}
    local seen = {}
    local instanceMapID = tonumber(row.instanceMapID) or tonumber(row.bossMapID)
    local lineage = GetMapLineage(instanceMapID)
    local zoneMapID = tonumber(row.instanceEntrance and row.instanceEntrance.mapID) or GetZoneMapIDFromLineage(lineage)
    local continentMapID = tonumber(row.instanceEntrance and row.instanceEntrance.continentMapID) or GetContinentMapIDFromLineage(lineage)

    if continentMapID then
        local entrancePin = BuildStaticEntrancePin(row, continentMapID) or FindInstanceEntranceOnMap(row, continentMapID)
        if entrancePin then
            AddInstanceMapOption(options, seen, {
                mapID = continentMapID,
                label = GetMapName(continentMapID) .. " entrance",
                pins = { entrancePin },
            })
        end
    end

    if zoneMapID then
        local entrancePin = BuildStaticEntrancePin(row, zoneMapID) or FindInstanceEntranceOnMap(row, zoneMapID)
        if entrancePin then
            AddInstanceMapOption(options, seen, {
                mapID = zoneMapID,
                label = GetMapName(zoneMapID) .. " entrance",
                pins = { entrancePin },
            })
        end
    end

    if not IsTrashInstanceDrop(row) and instanceMapID then
        local bossMapID = tonumber(row.bossMapID) or instanceMapID
        local bossX = NormalizeMapCoord(row.bossX)
        local bossY = NormalizeMapCoord(row.bossY)
        local pins = {}
        if bossX and bossY then
            pins[1] = {
                mapID = bossMapID,
                x = bossX,
                y = bossY,
                label = GetBossDisplayName(row),
                itemName = row.itemName,
                spotLocation = GetInstanceDisplayName(row),
                routeType = "Boss drop",
            }
        end
        AddInstanceMapOption(options, seen, {
            mapID = bossMapID,
            label = GetInstanceDisplayName(row) .. " - " .. GetBossDisplayName(row),
            pins = pins,
        })
    end

    return options
end

function GoldTracker:OpenInstanceFarmingMap(row)
    local mapOptions = self:BuildInstanceFarmingMapOptions(row)
    if #mapOptions == 0 then
        self:Print("No instance map details are available for this row yet.")
        return false
    end

    if type(self.OpenStandaloneMapWindow) ~= "function" then
        self:Print("The map window is not loaded yet.")
        return false
    end

    self:OpenStandaloneMapWindow({
        title = (row.itemName or ("Item " .. tostring(row.itemID or ""))) .. " Instance Map",
        mapOptions = mapOptions,
        selectedMapOptionIndex = 1,
    })
    return true
end

local function GetSavedScanEntries(addon)
    local cache = type(addon.db) == "table" and addon.db.instanceFarmingScanCache or nil
    local entries = {}
    if type(cache) ~= "table" then
        return entries
    end
    for key, entry in pairs(cache) do
        if type(entry) == "table" and type(entry.results) == "table" then
            entries[#entries + 1] = { key = key, entry = entry, savedAtTime = tonumber(entry.savedAtTime) or 0 }
        end
    end
    table.sort(entries, function(left, right)
        return (left.savedAtTime or 0) > (right.savedAtTime or 0)
    end)
    return entries
end

local function GetFavoriteEntries(addon)
    local favorites = type(addon.GetFarmingFavoriteStore) == "function" and addon:GetFarmingFavoriteStore()
        or (type(addon.db) == "table" and addon.db.instanceFarmingFavorites or nil)
    local entries = {}
    if type(favorites) ~= "table" then
        return entries
    end
    for key, favorite in pairs(favorites) do
        local row = CloneResultForCache(favorite)
        if row then
            row.favoriteKey = key
            entries[#entries + 1] = { key = key, row = row, savedAtTime = tonumber(favorite.favoritedAtTime) or 0 }
        end
    end
    table.sort(entries, function(left, right)
        local leftRow = left.row or {}
        local rightRow = right.row or {}
        local leftExpansion = leftRow.expansionFilterLabel
            or (leftRow.expansionFilterID and GetExpansionFilterLabel(leftRow.expansionFilterID))
            or leftRow.expansionLabel
            or leftRow.locationLabel
            or "Unknown"
        local rightExpansion = rightRow.expansionFilterLabel
            or (rightRow.expansionFilterID and GetExpansionFilterLabel(rightRow.expansionFilterID))
            or rightRow.expansionLabel
            or rightRow.locationLabel
            or "Unknown"
        local leftExpansionSort = string.lower(tostring(leftExpansion))
        local rightExpansionSort = string.lower(tostring(rightExpansion))
        if leftExpansionSort ~= rightExpansionSort then
            return leftExpansionSort < rightExpansionSort
        end

        local leftSource = leftRow.rareName or leftRow.bossName or leftRow.instanceName or ""
        local rightSource = rightRow.rareName or rightRow.bossName or rightRow.instanceName or ""
        local leftSourceSort = string.lower(tostring(leftSource))
        local rightSourceSort = string.lower(tostring(rightSource))
        if leftSourceSort ~= rightSourceSort then
            return leftSourceSort < rightSourceSort
        end

        local leftItem = leftRow.itemName or leftRow.itemLink or tostring(leftRow.itemID or "")
        local rightItem = rightRow.itemName or rightRow.itemLink or tostring(rightRow.itemID or "")
        local leftItemSort = string.lower(tostring(leftItem))
        local rightItemSort = string.lower(tostring(rightItem))
        if leftItemSort ~= rightItemSort then
            return leftItemSort < rightItemSort
        end

        return (left.savedAtTime or 0) > (right.savedAtTime or 0)
    end)
    return entries
end

local function GetFavoriteEntryExpansionLabel(entry)
    local row = entry and entry.row or {}
    return row.expansionFilterLabel
        or (row.expansionFilterID and GetExpansionFilterLabel(row.expansionFilterID))
        or row.expansionLabel
        or row.locationLabel
        or "Unknown"
end

local function BuildFavoriteDisplayEntries(entries)
    local displayEntries = {}
    local currentExpansionLabel
    for _, entry in ipairs(entries or {}) do
        local expansionLabel = GetFavoriteEntryExpansionLabel(entry)
        if expansionLabel ~= currentExpansionLabel then
            currentExpansionLabel = expansionLabel
            displayEntries[#displayEntries + 1] = {
                isExpansionHeader = true,
                label = expansionLabel,
            }
        end
        displayEntries[#displayEntries + 1] = entry
    end
    return displayEntries
end

function GoldTracker:GetInstanceFarmingValueSource()
    local source = self.VALUE_SOURCE_BY_ID[self.db and self.db.instanceFarmingValueSource]
    if source then
        return source
    end
    return self.VALUE_SOURCE_BY_ID[self.DEFAULTS.instanceFarmingValueSource]
end

function GoldTracker:SetInstanceFarmingValueSource(sourceID)
    local source = self.VALUE_SOURCE_BY_ID[sourceID] or self:GetInstanceFarmingValueSource()
    if self.db and source then
        self.db.instanceFarmingValueSource = source.id
    end
    if self.instanceFarmingFrame and source then
        self.instanceFarmingFrame.valueSourceID = source.id
        self:RefreshInstanceFarmingWindow(false)
    end
end

function GoldTracker:GetInstanceFarmingMinimumValue()
    local value = tonumber(self.db and self.db.instanceFarmingMinimumValue) or self.DEFAULTS.instanceFarmingMinimumValue
    return math.max(0, math.floor(value + 0.5))
end

function GoldTracker:SetInstanceFarmingMinimumValue(value)
    local normalizedValue = math.max(0, math.floor((tonumber(value) or 0) + 0.5))
    if self.db then
        self.db.instanceFarmingMinimumValue = normalizedValue
    end
    if self.instanceFarmingFrame then
        self.instanceFarmingFrame.minimumValueCopper = normalizedValue
    end
end

function GoldTracker:GetInstanceFarmingExpansionFilter()
    return NormalizeExpansionFilter(self.db and self.db.instanceFarmingExpansionFilter or self.DEFAULTS.instanceFarmingExpansionFilter)
end

function GoldTracker:SetInstanceFarmingExpansionFilter(filterID)
    local normalizedFilterID = NormalizeExpansionFilter(filterID)
    if self.db then
        self.db.instanceFarmingExpansionFilter = normalizedFilterID
    end
    if self.instanceFarmingFrame then
        self.instanceFarmingFrame.expansionFilterID = normalizedFilterID
        self:RefreshInstanceFarmingWindow(true)
    end
end

function GoldTracker:GetInstanceFarmingContentTypeFilter()
    return NormalizeContentTypeFilter(self.db and self.db.instanceFarmingContentTypeFilter or self.DEFAULTS.instanceFarmingContentTypeFilter)
end

function GoldTracker:SetInstanceFarmingContentTypeFilter(filterID)
    local normalizedFilterID = NormalizeContentTypeFilter(filterID)
    if self.db then
        self.db.instanceFarmingContentTypeFilter = normalizedFilterID
    end
    if self.instanceFarmingFrame then
        self.instanceFarmingFrame.contentTypeFilterID = normalizedFilterID
        self:RefreshInstanceFarmingWindow(true)
    end
end

function GoldTracker:GetInstanceFarmingScanMode()
    return NormalizeScanMode(self.db and self.db.instanceFarmingScanMode or self.DEFAULTS.instanceFarmingScanMode)
end

function GoldTracker:SetInstanceFarmingScanMode(modeID)
    local normalizedModeID = NormalizeScanMode(modeID)
    if self.db then
        self.db.instanceFarmingScanMode = normalizedModeID
    end
    if self.instanceFarmingFrame then
        self.instanceFarmingFrame.scanModeID = normalizedModeID
        if self.instanceFarmingFrame.scanState then
            self.instanceFarmingFrame.scanState.scanBatchSize = GetScanModeOption(normalizedModeID).batchSize
        end
        self:RefreshInstanceFarmingWindowControls()
    end
end

function GoldTracker:SaveInstanceFarmingMinimumValueInput(skipRefresh)
    local frame = self.instanceFarmingFrame
    if not frame then
        return
    end
    local minimumValue = ReadMinimumValueCopper(self, frame.minimumValueInput)
    self:SetInstanceFarmingMinimumValue(minimumValue)
    frame.minimumValueInput:SetText(FormatGoldInput(self, minimumValue))
    if skipRefresh ~= true and not frame.scanState then
        self:RefreshInstanceFarmingWindow(true)
    end
end

function GoldTracker:IsInstanceFarmingFavorite(row)
    if type(self.IsFarmingItemFavorite) == "function" then
        return self:IsFarmingItemFavorite(row)
    end
    local key = row and GetFavoriteKey(row)
    local favorites = type(self.db) == "table" and self.db.instanceFarmingFavorites or nil
    return key ~= nil and type(favorites) == "table" and favorites[key] ~= nil
end

function GoldTracker:ToggleInstanceFarmingFavorite(row)
    local key = row and GetFavoriteKey(row)
    local favorites = type(self.GetFarmingFavoriteStore) == "function" and self:GetFarmingFavoriteStore()
        or (type(self.db) == "table" and self.db.instanceFarmingFavorites or nil)
    if not key or type(favorites) ~= "table" then
        return
    end
    if favorites[key] then
        favorites[key] = nil
    else
        local favorite = CloneResultForCache(row)
        if favorite then
            favorite.favoriteKey = key
            favorite.farmingSourceType = favorite.farmingSourceType or "instance"
            favorite.favoritedAt = date("%Y-%m-%d %H:%M")
            favorite.favoritedAtTime = time()
            favorites[key] = favorite
        end
    end
    self:RefreshInstanceFarmingWindow(false)
    self:RefreshInstanceFarmingLibraryWindow()
    if self.rareFarmingFrame and type(self.RefreshRareFarmingWindow) == "function" then
        self:RefreshRareFarmingWindow(false)
        self:RefreshRareFarmingLibraryWindow()
    end
end

function GoldTracker:UpdateInstanceFarmingItemDisplayData(itemID)
    local frame = self.instanceFarmingFrame
    local changed = false
    local normalizedItemID = tonumber(itemID)
    if not frame or not normalizedItemID then
        return false
    end

    local function updateRows(rows)
        if type(rows) ~= "table" then
            return
        end
        for _, row in ipairs(rows) do
            if tonumber(row.itemID) == normalizedItemID then
                changed = ApplyItemDisplayData(row, normalizedItemID) or changed
            end
        end
    end

    updateRows(frame.lastResults)
    if frame.loadedInstanceFarmingCache and type(frame.loadedInstanceFarmingCache.results) == "table" then
        updateRows(frame.loadedInstanceFarmingCache.results)
    end
    return changed
end

function GoldTracker:ScheduleInstanceFarmingWindowRefresh(scrollToTop)
    if self.instanceFarmingRefreshTimer then
        return
    end
    self.instanceFarmingRefreshTimer = C_Timer.NewTimer(ITEM_REFRESH_DELAY, function()
        self.instanceFarmingRefreshTimer = nil
        if self.instanceFarmingFrame and self.instanceFarmingFrame:IsShown() then
            self:RefreshInstanceFarmingWindow(scrollToTop)
            self:RefreshInstanceFarmingLibraryWindow()
        end
    end)
end

function GoldTracker:RefreshInstanceFarmingWindowControls()
    local frame = self.instanceFarmingFrame
    if not frame then
        return
    end
    local scanning = frame.scanState ~= nil
    local source = self.VALUE_SOURCE_BY_ID[frame.valueSourceID] or self:GetInstanceFarmingValueSource()
    UIDropDownMenu_SetSelectedValue(frame.valueSourceDropdown, source.id)
    UIDropDownMenu_SetText(frame.valueSourceDropdown, source.label)
    UIDropDownMenu_SetSelectedValue(frame.expansionDropdown, frame.expansionFilterID)
    UIDropDownMenu_SetText(frame.expansionDropdown, GetExpansionFilterLabel(frame.expansionFilterID))
    UIDropDownMenu_SetSelectedValue(frame.contentTypeDropdown, frame.contentTypeFilterID)
    UIDropDownMenu_SetText(frame.contentTypeDropdown, GetContentTypeFilterLabel(frame.contentTypeFilterID))
    UIDropDownMenu_SetSelectedValue(frame.scanModeDropdown, frame.scanModeID)
    UIDropDownMenu_SetText(frame.scanModeDropdown, GetScanModeOption(frame.scanModeID).label)
    if frame.minimumValueInput and not frame.minimumValueInput:HasFocus() then
        frame.minimumValueInput:SetText(FormatGoldInput(self, frame.minimumValueCopper))
    end
    frame.scanButton:SetEnabled(not scanning)
    frame.stopScanButton:SetEnabled(scanning)
    frame.saveButton:SetEnabled(not scanning and type(frame.lastResults) == "table" and #frame.lastResults > 0)
    frame.updatePricesButton:SetShown(frame.editingInstanceFarmingCacheKey ~= nil)
    frame.rescanButton:SetShown(frame.editingInstanceFarmingCacheKey ~= nil)
    frame.updatePricesButton:SetEnabled(not scanning and type(frame.lastResults) == "table" and #frame.lastResults > 0)
    frame.rescanButton:SetEnabled(not scanning)
end

function GoldTracker:RefreshInstanceFarmingNavigationTabs()
    local frame = self.instanceFarmingFrame
    if not frame then
        return
    end
    local active = frame.instanceFarmingNavigationTab or "saved"
    frame.savedTabButton:SetSelected(active == "saved")
    frame.favoritesTabButton:SetSelected(active == "favorites")
    frame.newScanTabButton:SetSelected(active == "new")
end

function GoldTracker:SetInstanceFarmingWindowView(viewID)
    local frame = self.instanceFarmingFrame
    if not frame then
        return
    end
    local showScan = viewID == "scan"
    frame.instanceFarmingViewID = showScan and "scan" or "library"
    frame.libraryPanel:SetShown(not showScan)
    frame.controlsPanel:SetShown(showScan)
    frame.listPanel:SetShown(showScan)
    frame.metaText:SetShown(showScan)
    frame.libraryUpdateFavoritesButton:SetShown(not showScan and frame.instanceFarmingLibraryTab == "favorites")
    if showScan then
        self:RefreshInstanceFarmingWindowControls()
        self:RefreshInstanceFarmingWindow(true)
    else
        self:RefreshInstanceFarmingLibraryWindow()
    end
    self:RefreshInstanceFarmingNavigationTabs()
end

function GoldTracker:OpenInstanceFarmingNewScan()
    local frame = self.instanceFarmingFrame
    if not frame then
        return
    end
    frame.scanState = nil
    frame.lastResults = {}
    frame.loadedInstanceFarmingCacheKey = nil
    frame.loadedInstanceFarmingCache = nil
    frame.editingInstanceFarmingCacheKey = nil
    frame.hasInstanceFarmingScanRun = false
    frame.instanceFarmingNavigationTab = "new"
    if frame.statusText then
        frame.statusText:SetText("Ready.")
    end
    if frame.progressBar then
        frame.progressBar:SetMinMaxValues(0, 1)
        frame.progressBar:SetValue(0)
    end
    self:SetInstanceFarmingWindowView("scan")
end

function GoldTracker:OpenInstanceFarmingSavedScan(cacheKey)
    local frame = self.instanceFarmingFrame
    local entry = type(self.db) == "table" and type(self.db.instanceFarmingScanCache) == "table" and self.db.instanceFarmingScanCache[cacheKey] or nil
    if not frame or type(entry) ~= "table" then
        return
    end
    if entry.valueSourceID then
        self.db.instanceFarmingValueSource = entry.valueSourceID
        frame.valueSourceID = entry.valueSourceID
    end
    if entry.expansionFilterID then
        self.db.instanceFarmingExpansionFilter = NormalizeExpansionFilter(entry.expansionFilterID)
        frame.expansionFilterID = self.db.instanceFarmingExpansionFilter
    end
    if entry.contentTypeFilterID then
        self.db.instanceFarmingContentTypeFilter = NormalizeContentTypeFilter(entry.contentTypeFilterID)
        frame.contentTypeFilterID = self.db.instanceFarmingContentTypeFilter
    end
    if tonumber(entry.minimumValueCopper) then
        self.db.instanceFarmingMinimumValue = math.max(0, math.floor(tonumber(entry.minimumValueCopper) + 0.5))
        frame.minimumValueCopper = self.db.instanceFarmingMinimumValue
    end

    frame.scanState = nil
    frame.loadedInstanceFarmingCacheKey = cacheKey
    frame.loadedInstanceFarmingCache = entry
    frame.editingInstanceFarmingCacheKey = cacheKey
    frame.hasInstanceFarmingScanRun = true
    frame.lastResults = {}
    for _, row in ipairs(entry.results or {}) do
        local cachedRow = CloneResultForCache(row)
        if cachedRow then
            frame.lastResults[#frame.lastResults + 1] = cachedRow
        end
    end
    frame.instanceFarmingNavigationTab = "saved"
    if frame.statusText then
        frame.statusText:SetText(string.format("Loaded saved scan for %s: %d matching instance drops.", entry.expansionFilterLabel or "saved filter", #frame.lastResults))
    end
    self:SetInstanceFarmingWindowView("scan")
end

function GoldTracker:DeleteInstanceFarmingSavedScan(cacheKey)
    if type(cacheKey) ~= "string" or type(self.db) ~= "table" or type(self.db.instanceFarmingScanCache) ~= "table" then
        return
    end

    self.db.instanceFarmingScanCache[cacheKey] = nil

    local frame = self.instanceFarmingFrame
    if frame and (frame.loadedInstanceFarmingCacheKey == cacheKey or frame.editingInstanceFarmingCacheKey == cacheKey) then
        frame.loadedInstanceFarmingCacheKey = nil
        frame.loadedInstanceFarmingCache = nil
        frame.editingInstanceFarmingCacheKey = nil
        if frame.instanceFarmingViewID == "scan" then
            self:RefreshInstanceFarmingWindowControls()
        end
    end

    self:RefreshInstanceFarmingLibraryWindow()
end

function GoldTracker:RefreshInstanceFarmingLibraryWindow()
    local frame = self.instanceFarmingFrame
    if not frame or not frame.libraryPanel then
        return
    end

    local activeTab = frame.instanceFarmingLibraryTab or "saved"
    if frame.instanceFarmingViewID ~= "scan" then
        frame.instanceFarmingNavigationTab = activeTab
    end
    frame.libraryUpdateFavoritesButton:SetShown(frame.instanceFarmingViewID ~= "scan" and activeTab == "favorites")
    local entries = activeTab == "favorites" and GetFavoriteEntries(self) or GetSavedScanEntries(self)
    local favoriteCount = activeTab == "favorites" and #entries or nil
    if activeTab == "favorites" then
        entries = BuildFavoriteDisplayEntries(entries)
    end
    frame.libraryRows = frame.libraryRows or {}
    local yOffset = 0
    local contentWidth = frame.libraryScrollFrame and math.max(1, math.floor(frame.libraryScrollFrame:GetWidth() or 1)) or 1
    frame.libraryContent:SetWidth(contentWidth)

    for index, data in ipairs(entries) do
        local row = frame.libraryRows[index]
        if not row then
            row = CreateFrame("Button", nil, frame.libraryContent)
            SetInstanceFarmingFrameLevel(row, frame.libraryContent, 1)
            row:RegisterForClicks("LeftButtonUp")
            row:EnableMouse(true)
            row.background = row:CreateTexture(nil, "BACKGROUND")
            row.background:SetAllPoints(row)
            row.primaryText = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
            row.primaryText:SetJustifyH("LEFT")
            row.primaryText:SetWordWrap(false)
            row.secondaryText = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
            row.secondaryText:SetJustifyH("LEFT")
            row.secondaryText:SetWordWrap(false)
            row.valueText = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
            row.valueText:SetJustifyH("RIGHT")
            row.groupHeaderText = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
            row.groupHeaderText:SetJustifyH("LEFT")
            row.groupHeaderText:SetWordWrap(false)
            row.favoriteRemoveButton = CreateButton(row, TRACKED_BUTTON_WIDTH, TRACKED_BUTTON_HEIGHT, "-", "neutral")
            row.favoriteRemoveButton:RegisterForClicks("LeftButtonUp")
            if row.favoriteRemoveButton.SetSelected then
                row.favoriteRemoveButton:SetSelected(true)
            end
            row.favoriteRemoveText = row.favoriteRemoveButton.label
            row.favoriteExpansionText = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
            row.favoriteExpansionText:SetJustifyH("LEFT")
            row.favoriteExpansionText:SetWordWrap(false)
            row.favoriteSourceText = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
            row.favoriteSourceText:SetJustifyH("LEFT")
            row.favoriteSourceText:SetWordWrap(false)
            row.favoriteItemText = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
            row.favoriteItemText:SetJustifyH("LEFT")
            row.favoriteItemText:SetWordWrap(false)
            row.favoriteSelectedText = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
            row.favoriteSelectedText:SetJustifyH("RIGHT")
            row.favoriteSelectedText:SetWordWrap(false)
            row.favoriteMarketText = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
            row.favoriteMarketText:SetJustifyH("RIGHT")
            row.favoriteMarketText:SetWordWrap(false)
            row.favoriteRegionText = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
            row.favoriteRegionText:SetJustifyH("RIGHT")
            row.favoriteRegionText:SetWordWrap(false)
            row.favoriteAverageText = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
            row.favoriteAverageText:SetJustifyH("RIGHT")
            row.favoriteAverageText:SetWordWrap(false)
            row.removeButton = CreateButton(row, 24, 22, "-", "neutral")
            row.deleteScanButton = CreateButton(row, 64, 22, "Delete", "danger")
            row.deleteScanButton:SetScript("OnClick", function(self)
                local parent = self:GetParent()
                if parent and parent.scanKey then
                    GoldTracker:DeleteInstanceFarmingSavedScan(parent.scanKey)
                end
            end)
            row.detailsButton = CreateButton(row, DETAILS_WIDTH, 20, "Details", "neutral")
            row.detailsButton:SetScript("OnClick", function(self)
                GoldTracker:OpenInventoryItemDetailsWindow(self:GetParent())
            end)
            row:SetScript("OnEnter", function(self)
                if self.itemID then
                    SetItemTooltip(self)
                end
            end)
            row:SetScript("OnLeave", function()
                GameTooltip:Hide()
            end)
            frame.libraryRows[index] = row
        else
            SetInstanceFarmingFrameLevel(row, frame.libraryContent, 1)
        end

        local isExpansionHeader = activeTab == "favorites" and data.isExpansionHeader == true
        local rowHeight = isExpansionHeader and 24 or (activeTab == "favorites" and 30 or 54)
        row:SetHeight(rowHeight)
        row:ClearAllPoints()
        row:SetPoint("TOPLEFT", frame.libraryContent, "TOPLEFT", 0, -yOffset)
        row:SetPoint("TOPRIGHT", frame.libraryContent, "TOPRIGHT", 0, -yOffset)
        row.background:SetColorTexture(1, 1, 1, isExpansionHeader and 0.075 or (index % 2 == 0 and 0.045 or 0.022))
        row.primaryText:ClearAllPoints()
        row.secondaryText:ClearAllPoints()
        row.valueText:ClearAllPoints()
        row.groupHeaderText:SetShown(isExpansionHeader)
        row.primaryText:SetShown(activeTab ~= "favorites")
        row.secondaryText:SetShown(activeTab ~= "favorites")
        row.valueText:SetShown(activeTab ~= "favorites")
        row.removeButton:Hide()
        row.favoriteRemoveButton:Hide()
        row.favoriteExpansionText:Hide()
        row.favoriteSourceText:Hide()
        row.favoriteItemText:Hide()
        row.favoriteSelectedText:Hide()
        row.favoriteMarketText:Hide()
        row.favoriteRegionText:Hide()
        row.favoriteAverageText:Hide()
        row.deleteScanButton:Hide()
        row.detailsButton:Hide()
        row.itemID = nil
        row.scanKey = nil

        if isExpansionHeader then
            row.primaryText:SetText("")
            row.secondaryText:SetText("")
            row.valueText:SetText("")
            row.groupHeaderText:ClearAllPoints()
            row.groupHeaderText:SetPoint("LEFT", row, "LEFT", 10, 0)
            row.groupHeaderText:SetPoint("RIGHT", row, "RIGHT", -10, 0)
            row.groupHeaderText:SetText(data.label or "Unknown")
            row.groupHeaderText:SetTextColor(1.0, 0.82, 0.18)
            row:SetScript("OnClick", nil)
        elseif activeTab == "favorites" then
            local favorite = data.row
            EnsureRowItemDisplayData(self, favorite)
            local removeWidth = 24
            local valueWidth = 92
            local columnGap = 10
            local expansionWidth = 116
            local sourceWidth = 170
            local detailsX = contentWidth - DETAILS_WIDTH - 12
            local averageX = detailsX - valueWidth - columnGap
            local regionX = averageX - valueWidth - columnGap
            local marketX = regionX - valueWidth - columnGap
            local selectedX = marketX - valueWidth - columnGap
            local itemX = removeWidth + columnGap + expansionWidth + columnGap + sourceWidth + columnGap
            local itemWidth = math.max(120, selectedX - itemX - columnGap)
            local expansionLabel = favorite.expansionFilterLabel
                or favorite.expansionLabel
                or favorite.locationLabel
                or "Unknown"
            local sourceLabel = favorite.rareName
                and ("Rare | " .. favorite.rareName)
                or (favorite.bossName and string.format("%s | %s", GetInstanceDisplayName(favorite), GetBossDisplayName(favorite)))
                or favorite.instanceName
                or "Unknown source"

            row.itemID = favorite.itemID
            row.itemName = favorite.itemName
            row.itemLink = favorite.itemLink
            row.itemQuality = favorite.itemQuality
            row.icon = favorite.icon
            row.iconTexture = favorite.icon
            row.bindType = favorite.bindType
            row.instanceName = favorite.instanceName
            row.bossName = favorite.bossName
            row.instanceEncounterJournalID = favorite.instanceEncounterJournalID
            row.bossEncounterJournalID = favorite.bossEncounterJournalID
            row.npcID = favorite.npcID
            row.rareName = favorite.rareName
            row.locationLabel = favorite.locationLabel
            row.locations = favorite.locations
            row.farmingSourceType = favorite.farmingSourceType
            row.valueSourceID = favorite.valueSourceID
            row.valueSourceLabel = favorite.valueSourceLabel
            row.value = favorite.value
            row.marketValue = favorite.marketValue
            row.regionMarketValue = favorite.regionMarketValue
            row.averageValue = favorite.averageValue

            row.primaryText:Hide()
            row.secondaryText:Hide()
            row.valueText:Hide()
            row.favoriteRemoveButton:Show()
            row.favoriteRemoveButton:ClearAllPoints()
            row.favoriteRemoveButton:SetPoint("LEFT", row, "LEFT", 0, 0)
            row.favoriteRemoveButton:SetScript("OnClick", function()
                local favorites = type(self.GetFarmingFavoriteStore) == "function" and self:GetFarmingFavoriteStore()
                    or (type(self.db) == "table" and self.db.instanceFarmingFavorites or nil)
                if type(favorites) == "table" then
                    favorites[data.key] = nil
                end
                self:RefreshInstanceFarmingWindow(false)
                self:RefreshInstanceFarmingLibraryWindow()
                if self.rareFarmingFrame and type(self.RefreshRareFarmingWindow) == "function" then
                    self:RefreshRareFarmingWindow(false)
                    self:RefreshRareFarmingLibraryWindow()
                end
            end)
            row.favoriteExpansionText:Show()
            row.favoriteExpansionText:ClearAllPoints()
            row.favoriteExpansionText:SetPoint("LEFT", row, "LEFT", removeWidth + columnGap, 0)
            row.favoriteExpansionText:SetWidth(expansionWidth)
            row.favoriteExpansionText:SetText(expansionLabel)
            row.favoriteSourceText:Show()
            row.favoriteSourceText:ClearAllPoints()
            row.favoriteSourceText:SetPoint("LEFT", row, "LEFT", removeWidth + columnGap + expansionWidth + columnGap, 0)
            row.favoriteSourceText:SetWidth(sourceWidth)
            row.favoriteSourceText:SetText(sourceLabel)
            row.favoriteItemText:Show()
            row.favoriteItemText:ClearAllPoints()
            row.favoriteItemText:SetPoint("LEFT", row, "LEFT", itemX, 0)
            row.favoriteItemText:SetWidth(itemWidth)
            row.favoriteItemText:SetText(favorite.itemLink or favorite.itemName or ("Item " .. tostring(favorite.itemID)))
            row.favoriteSelectedText:Show()
            row.favoriteSelectedText:ClearAllPoints()
            row.favoriteSelectedText:SetPoint("LEFT", row, "LEFT", selectedX, 0)
            row.favoriteSelectedText:SetWidth(valueWidth)
            row.favoriteSelectedText:SetText(self:FormatMoney(favorite.value or 0))
            row.favoriteMarketText:Show()
            row.favoriteMarketText:ClearAllPoints()
            row.favoriteMarketText:SetPoint("LEFT", row, "LEFT", marketX, 0)
            row.favoriteMarketText:SetWidth(valueWidth)
            row.favoriteMarketText:SetText(self:FormatMoney(favorite.marketValue or 0))
            row.favoriteRegionText:Show()
            row.favoriteRegionText:ClearAllPoints()
            row.favoriteRegionText:SetPoint("LEFT", row, "LEFT", regionX, 0)
            row.favoriteRegionText:SetWidth(valueWidth)
            row.favoriteRegionText:SetText(self:FormatMoney(favorite.regionMarketValue or 0))
            row.favoriteAverageText:Show()
            row.favoriteAverageText:ClearAllPoints()
            row.favoriteAverageText:SetPoint("LEFT", row, "LEFT", averageX, 0)
            row.favoriteAverageText:SetWidth(valueWidth)
            row.favoriteAverageText:SetText(self:FormatMoney(favorite.averageValue or 0))
            row.detailsButton:Show()
            row.detailsButton:ClearAllPoints()
            row.detailsButton:SetPoint("LEFT", row, "LEFT", detailsX, 0)
            row:SetScript("OnClick", nil)
        else
            local entry = data.entry
            local itemCount = tonumber(entry.resultCount) or #(entry.results or {})
            row.scanKey = data.key
            row.primaryText:SetPoint("TOPLEFT", row, "TOPLEFT", 10, -8)
            row.primaryText:SetPoint("RIGHT", row, "RIGHT", -202, 0)
            row.primaryText:SetText(string.format("%s / %s scan", entry.expansionFilterLabel or "All", entry.contentTypeFilterLabel or "All"))
            row.secondaryText:SetPoint("TOPLEFT", row.primaryText, "BOTTOMLEFT", 0, -5)
            row.secondaryText:SetPoint("RIGHT", row, "RIGHT", -202, 0)
            row.secondaryText:SetText(string.format(
                "%d items found | Threshold %s | %s | %s",
                itemCount,
                self:FormatMoney(entry.minimumValueCopper or 0),
                entry.valueSourceLabel or entry.valueSourceID or "Unknown source",
                entry.savedAt or "unknown time"
            ))
            row.valueText:SetPoint("RIGHT", row, "RIGHT", -86, 0)
            row.valueText:SetWidth(52)
            row.valueText:SetText("Open")
            row.deleteScanButton:Show()
            row.deleteScanButton:ClearAllPoints()
            row.deleteScanButton:SetPoint("RIGHT", row, "RIGHT", -10, 0)
            row:SetScript("OnClick", function()
                self:OpenInstanceFarmingSavedScan(data.key)
            end)
        end

        row.primaryText:SetTextColor(0.92, 0.95, 1.0)
        row.secondaryText:SetTextColor(0.72, 0.76, 0.84)
        row.valueText:SetTextColor(0.68, 0.96, 0.72)
        row.favoriteExpansionText:SetTextColor(0.72, 0.76, 0.84)
        row.favoriteSourceText:SetTextColor(0.92, 0.95, 1.0)
        row.favoriteItemText:SetTextColor(0.92, 0.95, 1.0)
        row.favoriteSelectedText:SetTextColor(0.68, 0.96, 0.72)
        row.favoriteMarketText:SetTextColor(0.68, 0.86, 1.0)
        row.favoriteRegionText:SetTextColor(0.78, 0.82, 1.0)
        row.favoriteAverageText:SetTextColor(0.92, 0.78, 1.0)
        row:Show()
        yOffset = yOffset + rowHeight + 2
    end

    for index = #entries + 1, #(frame.libraryRows or {}) do
        frame.libraryRows[index]:Hide()
    end
    frame.libraryContent:SetHeight(math.max(1, yOffset))
    frame.libraryEmptyText:SetShown(#entries == 0)
    frame.libraryEmptyText:SetText(activeTab == "favorites" and "No favorite farming items yet." or "No saved instance scans yet.")
    frame.libraryStatusText:SetText(activeTab == "favorites"
        and string.format("%d favorite items grouped by expansion | Source | Item | Selected | Market | Region | Avg | Details", favoriteCount or 0)
        or string.format("%d saved scans", #entries))
    self:RefreshInstanceFarmingNavigationTabs()
end

function GoldTracker:SaveInstanceFarmingScanCache(state, existingKey)
    if type(self.db) ~= "table" or type(state) ~= "table" then
        return nil
    end
    self.db.instanceFarmingScanCache = self.db.instanceFarmingScanCache or {}
    local key = existingKey or string.format("%d:%s:%s:%d:%s", time(), tostring(state.expansionFilterID), tostring(state.contentTypeFilterID), tonumber(state.minimumValueCopper) or 0, tostring(state.valueSourceID))
    local results = {}
    for _, row in ipairs(state.results or {}) do
        local cached = CloneResultForCache(row)
        if cached then
            results[#results + 1] = cached
        end
    end
    local entry = {
        version = SCAN_CACHE_VERSION,
        savedAt = date("%Y-%m-%d %H:%M"),
        savedAtTime = time(),
        expansionFilterID = state.expansionFilterID,
        expansionFilterLabel = state.expansionFilterLabel,
        contentTypeFilterID = state.contentTypeFilterID,
        contentTypeFilterLabel = state.contentTypeFilterLabel,
        minimumValueCopper = state.minimumValueCopper,
        valueSourceID = state.valueSourceID,
        valueSourceLabel = state.valueSourceLabel,
        resultCount = #results,
        results = results,
    }
    self.db.instanceFarmingScanCache[key] = entry

    local entries = GetSavedScanEntries(self)
    for index = SCAN_CACHE_MAX_ENTRIES + 1, #entries do
        self.db.instanceFarmingScanCache[entries[index].key] = nil
    end

    return entry, key
end

function GoldTracker:SaveCurrentInstanceFarmingScan()
    local frame = self.instanceFarmingFrame
    if not frame or type(frame.lastResults) ~= "table" or #frame.lastResults == 0 then
        return
    end
    local source = self.VALUE_SOURCE_BY_ID[frame.valueSourceID] or self:GetInstanceFarmingValueSource()
    local state = {
        results = frame.lastResults,
        expansionFilterID = frame.expansionFilterID,
        expansionFilterLabel = GetExpansionFilterLabel(frame.expansionFilterID),
        contentTypeFilterID = frame.contentTypeFilterID,
        contentTypeFilterLabel = GetContentTypeFilterLabel(frame.contentTypeFilterID),
        minimumValueCopper = frame.minimumValueCopper,
        valueSourceID = source.id,
        valueSourceLabel = source.label,
    }
    local entry, key = self:SaveInstanceFarmingScanCache(state, frame.editingInstanceFarmingCacheKey)
    if entry then
        frame.loadedInstanceFarmingCache = entry
        frame.loadedInstanceFarmingCacheKey = key
        frame.editingInstanceFarmingCacheKey = key
        frame.statusText:SetText(string.format("Saved %d instance drops.", entry.resultCount or 0))
        self:RefreshInstanceFarmingWindowControls()
        self:RefreshInstanceFarmingLibraryWindow()
    end
end

function GoldTracker:UpdateInstanceFarmingRowsPrices(rows, valueSourceID)
    local source = self.VALUE_SOURCE_BY_ID[valueSourceID] or self:GetInstanceFarmingValueSource()
    for _, row in ipairs(rows or {}) do
        local prices = GetPriceSnapshot(self, row.itemID, source)
        row.value = prices.value
        row.marketValue = prices.marketValue
        row.regionMarketValue = prices.regionMarketValue
        row.averageValue = prices.averageValue
        row.valueSourceID = source.id
        row.valueSourceLabel = source.label
    end
    if type(self.RecordInstanceFarmingMarketSnapshots) == "function" then
        self:RecordInstanceFarmingMarketSnapshots(rows)
    end
end

function GoldTracker:UpdateCurrentInstanceFarmingScanPrices()
    local frame = self.instanceFarmingFrame
    if not frame or type(frame.lastResults) ~= "table" then
        return
    end
    self:UpdateInstanceFarmingRowsPrices(frame.lastResults, frame.valueSourceID)
    if frame.editingInstanceFarmingCacheKey then
        self:SaveCurrentInstanceFarmingScan()
    end
    frame.statusText:SetText(string.format("Updated prices for %d rows.", #frame.lastResults))
    self:RefreshInstanceFarmingWindow(false)
end

function GoldTracker:UpdateInstanceFarmingFavoritePrices()
    local favorites = type(self.GetFarmingFavoriteStore) == "function" and self:GetFarmingFavoriteStore()
        or (type(self.db) == "table" and self.db.instanceFarmingFavorites or nil)
    if type(favorites) ~= "table" then
        return
    end
    local rows = {}
    for _, favorite in pairs(favorites) do
        rows[#rows + 1] = favorite
    end
    self:UpdateInstanceFarmingRowsPrices(rows, self:GetInstanceFarmingValueSource().id)
    self:RefreshInstanceFarmingLibraryWindow()
    if self.rareFarmingFrame and type(self.RefreshRareFarmingLibraryWindow) == "function" then
        self:RefreshRareFarmingWindow(false)
        self:RefreshRareFarmingLibraryWindow()
    end
end

function GoldTracker:GetInstanceFarmingScanWorker()
    if not self.instanceFarmingScanWorker then
        self.instanceFarmingScanWorker = CreateFrame("Frame")
        self.instanceFarmingScanWorker:Hide()
    end
    return self.instanceFarmingScanWorker
end

function GoldTracker:StopInstanceFarmingScanWorker()
    local worker = self.instanceFarmingScanWorker
    if worker then
        worker:SetScript("OnUpdate", nil)
        worker:Hide()
    end
end

function GoldTracker:UpdateInstanceFarmingScanProgress()
    local frame = self.instanceFarmingFrame
    local state = frame and frame.scanState
    if not frame or not state then
        return
    end
    local total = math.max(1, tonumber(state.total) or 1)
    frame.progressBar:SetMinMaxValues(0, total)
    frame.progressBar:SetValue(math.min(total, tonumber(state.index) or 0))
    frame.statusText:SetText(string.format(
        "Scanning %s / %s in %s mode: %d of %d sources checked, %d matches, %d pending item loads, %d restricted skipped.",
        state.expansionFilterLabel,
        state.contentTypeFilterLabel,
        state.scanModeLabel,
        math.min(total, tonumber(state.index) or 0),
        total,
        #(state.results or {}),
        GetPendingBindingCount(state),
        tonumber(state.skippedRestrictedBindingCount) or 0
    ))
end

function GoldTracker:FinishInstanceFarmingScan()
    local frame = self.instanceFarmingFrame
    local state = frame and frame.scanState
    if not frame or not state then
        return
    end
    self:StopInstanceFarmingScanWorker()
    frame.scanState = nil
    frame.lastResults = state.results or {}
    frame.loadedInstanceFarmingCache = nil
    frame.loadedInstanceFarmingCacheKey = nil
    frame.editingInstanceFarmingCacheKey = state.editingInstanceFarmingCacheKey
    frame.hasInstanceFarmingScanRun = true
    if type(self.RecordInstanceFarmingMarketSnapshots) == "function" then
        self:RecordInstanceFarmingMarketSnapshots(frame.lastResults)
    end
    frame.statusText:SetText(string.format(
        "Scan complete: %d auctionable instance drops matched. %d restricted and %d unavailable-binding items skipped.",
        #frame.lastResults,
        tonumber(state.skippedRestrictedBindingCount) or 0,
        tonumber(state.skippedUnloadedBindingCount) or 0
    ))
    self:RefreshInstanceFarmingWindowControls()
    self:RefreshInstanceFarmingWindow(true)
    self:Print(string.format("Instance farming scan complete: %d items found.", #frame.lastResults))
end

function GoldTracker:CancelInstanceFarmingScan()
    local frame = self.instanceFarmingFrame
    if not frame or not frame.scanState then
        return
    end
    self:StopInstanceFarmingScanWorker()
    frame.lastResults = frame.scanState.results or {}
    frame.scanState = nil
    frame.statusText:SetText(string.format("Scan stopped. Showing %d partial matches.", #frame.lastResults))
    self:RefreshInstanceFarmingWindowControls()
    self:RefreshInstanceFarmingWindow(false)
end

local function QueuePendingBindingSourceRow(state, sourceRow)
    if type(state) ~= "table" or type(sourceRow) ~= "table" then
        return
    end
    sourceRow.pendingBindingAttempts = (tonumber(sourceRow.pendingBindingAttempts) or 0) + 1
    if sourceRow.pendingBindingAttempts > MAX_PENDING_BINDING_RETRIES then
        state.skippedUnloadedBindingCount = (state.skippedUnloadedBindingCount or 0) + 1
        return
    end
    state.pendingRows = state.pendingRows or {}
    state.pendingRows[#state.pendingRows + 1] = sourceRow
end

function GetPendingBindingCount(state)
    local count = #(state and state.pendingRows or {})
    if state and type(state.retryRows) == "table" then
        count = count + math.max(0, (tonumber(state.retryTotal) or #state.retryRows) - (tonumber(state.retryIndex) or 0))
    end
    return count
end

local function GetNextInstanceScanSourceRow(state, elapsed)
    if state.index < state.total then
        state.index = state.index + 1
        return state.sourceRows[state.index], false
    end

    if type(state.retryRows) == "table" and state.retryIndex < state.retryTotal then
        state.retryIndex = state.retryIndex + 1
        return state.retryRows[state.retryIndex], false
    end
    state.retryRows = nil
    state.retryIndex = 0
    state.retryTotal = 0

    if type(state.pendingRows) == "table" and #state.pendingRows > 0 then
        state.pendingRetryElapsed = (state.pendingRetryElapsed or 0) + (elapsed or 0)
        if state.pendingRetryElapsed < ITEM_REFRESH_DELAY then
            return nil, true
        end
        state.retryRows = state.pendingRows
        state.retryTotal = #state.retryRows
        state.retryIndex = 0
        state.pendingRows = {}
        state.pendingRetryElapsed = 0
        return GetNextInstanceScanSourceRow(state, 0)
    end

    return nil, false
end

local function ProcessScanFrame(worker, elapsed)
    local addon = worker.addon
    local frame = addon and addon.instanceFarmingFrame
    local state = frame and frame.scanState
    if not state then
        addon:StopInstanceFarmingScanWorker()
        return
    end

    local source = addon.VALUE_SOURCE_BY_ID[state.valueSourceID] or addon:GetInstanceFarmingValueSource()
    local processed = 0
    local batchSize = tonumber(state.scanBatchSize) or BACKGROUND_SCAN_ITEMS_PER_TICK
    local waitingForPendingItems = false
    while processed < batchSize do
        local sourceRow
        sourceRow, waitingForPendingItems = GetNextInstanceScanSourceRow(state, elapsed)
        if not sourceRow then
            break
        end

        local itemCache = ResolveItemCache(addon, state, source, sourceRow.itemID)
        if itemCache and itemCache.pending then
            QueuePendingBindingSourceRow(state, sourceRow)
        else
            AddResult(state, sourceRow, itemCache)
        end
        processed = processed + 1
    end

    state.refreshElapsed = (state.refreshElapsed or 0) + (elapsed or 0)
    if state.refreshElapsed >= SCAN_REFRESH_INTERVAL or state.index >= state.total then
        state.refreshElapsed = 0
        addon:UpdateInstanceFarmingScanProgress()
        if frame and frame:IsShown() then
            frame.lastResults = state.results
            addon:RefreshInstanceFarmingWindow(false)
        end
    end

    if state.index >= state.total and GetPendingBindingCount(state) == 0 and not waitingForPendingItems then
        addon:FinishInstanceFarmingScan()
    end
end

function GoldTracker:StartInstanceFarmingScan()
    local frame = self.instanceFarmingFrame
    if not frame then
        return
    end
    local editingCacheKey = frame.rescanInstanceFarmingCacheKey
    frame.rescanInstanceFarmingCacheKey = nil
    self:SaveInstanceFarmingMinimumValueInput(true)
    self:StopInstanceFarmingScanWorker()
    local source = self.VALUE_SOURCE_BY_ID[frame.valueSourceID] or self:GetInstanceFarmingValueSource()
    local expansionFilterID = self:GetInstanceFarmingExpansionFilter()
    local contentTypeFilterID = self:GetInstanceFarmingContentTypeFilter()
    local sourceRows = BuildSourceRows(expansionFilterID, contentTypeFilterID)
    local scanModeOption = GetScanModeOption(self:GetInstanceFarmingScanMode())
    frame.scanState = {
        sourceRows = sourceRows,
        index = 0,
        total = #sourceRows,
        results = {},
        itemCache = {},
        minimumValueCopper = self:GetInstanceFarmingMinimumValue(),
        valueSourceID = source.id,
        valueSourceLabel = source.label,
        expansionFilterID = expansionFilterID,
        expansionFilterLabel = GetExpansionFilterLabel(expansionFilterID),
        contentTypeFilterID = contentTypeFilterID,
        contentTypeFilterLabel = GetContentTypeFilterLabel(contentTypeFilterID),
        scanModeID = scanModeOption.id,
        scanModeLabel = scanModeOption.label,
        scanBatchSize = scanModeOption.batchSize,
        editingInstanceFarmingCacheKey = editingCacheKey,
    }
    frame.lastResults = {}
    frame.loadedInstanceFarmingCache = nil
    frame.loadedInstanceFarmingCacheKey = nil
    frame.editingInstanceFarmingCacheKey = editingCacheKey
    frame.hasInstanceFarmingScanRun = true
    frame.instanceFarmingNavigationTab = "new"
    self:UpdateInstanceFarmingScanProgress()
    self:RefreshInstanceFarmingWindowControls()
    self:RefreshInstanceFarmingWindow(true)

    if #sourceRows == 0 then
        self:FinishInstanceFarmingScan()
        return
    end

    local worker = self:GetInstanceFarmingScanWorker()
    worker.addon = self
    worker:SetScript("OnUpdate", ProcessScanFrame)
    worker:Show()
end

function GoldTracker:RescanCurrentInstanceFarmingSelection()
    local frame = self.instanceFarmingFrame
    if frame then
        frame.rescanInstanceFarmingCacheKey = frame.editingInstanceFarmingCacheKey
    end
    self:StartInstanceFarmingScan()
end

function GoldTracker:ToggleInstanceFarmingSort(sortKey)
    local frame = self.instanceFarmingFrame
    if not frame then
        return
    end
    local normalizedSortKey = NormalizeSortKey(sortKey)
    if frame.sortKey == normalizedSortKey then
        frame.sortAscending = not frame.sortAscending
    else
        frame.sortKey = normalizedSortKey
        frame.sortAscending = normalizedSortKey ~= DEFAULT_SORT_KEY
    end
    self:RefreshInstanceFarmingWindow(false)
end

function GoldTracker:UpdateInstanceFarmingSortHeaderState()
    local frame = self.instanceFarmingFrame
    if not frame then
        return
    end
    for key, button in pairs(frame.sortHeaders or {}) do
        if button.sortIcon then
            local active = key == frame.sortKey
            button.sortIcon:SetShown(active)
            if active then
                button.sortIcon:SetTexture(frame.sortAscending and "Interface\\Buttons\\UI-SortArrow" or "Interface\\Buttons\\UI-SortArrow")
                button.sortIcon:SetTexCoord(0, 1, frame.sortAscending and 0 or 1, frame.sortAscending and 1 or 0)
            end
        end
    end
end

local ApplyTableColumnLayout

local function GetInstanceFarmingTableViewportWidth(frame)
    local panelWidth = 1
    if frame and frame.listPanel then
        panelWidth = math.max(1, frame.listPanel:GetWidth() or 1)
    end
    return math.max(1, panelWidth - HEADER_LEFT_INSET - ROW_RIGHT_PADDING - 24)
end

local function GetInstanceFarmingVisibleRows(frame)
    if not frame or not frame.listPanel then
        return 1
    end
    return math.max(1, math.floor(((frame.listPanel:GetHeight() or 300) - 52 - HORIZONTAL_SCROLL_HEIGHT) / ROW_STRIDE))
end

local function GetInstanceFarmingVerticalScrollBar(scrollFrame)
    if not scrollFrame then
        return nil
    end

    if scrollFrame.ScrollBar then
        return scrollFrame.ScrollBar
    end
    if scrollFrame.Scrollbar then
        return scrollFrame.Scrollbar
    end
    if type(scrollFrame.GetName) == "function" then
        local scrollFrameName = scrollFrame:GetName()
        if scrollFrameName then
            return _G[scrollFrameName .. "ScrollBar"]
        end
    end
    return nil
end

local function EnsureInstanceFarmingVerticalScrollBar(frame)
    local scrollFrame = frame and frame.scrollFrame
    if not scrollFrame then
        return nil
    end

    local scrollBar = GetInstanceFarmingVerticalScrollBar(scrollFrame)
    if not scrollBar and type(CreateFrame) == "function" then
        local scrollFrameName = type(scrollFrame.GetName) == "function" and scrollFrame:GetName() or nil
        local scrollBarName = scrollFrameName and (scrollFrameName .. "ManualScrollBar") or nil
        scrollBar = CreateFrame("Slider", scrollBarName, scrollFrame, "UIPanelScrollBarTemplate")
        scrollBar.goldTrackerManualScrollBar = true
        if scrollBar.SetPoint then
            scrollBar:SetPoint("TOPRIGHT", scrollFrame, "TOPRIGHT", -4, -16)
            scrollBar:SetPoint("BOTTOMRIGHT", scrollFrame, "BOTTOMRIGHT", -4, 16)
        end
        scrollFrame.ScrollBar = scrollBar
    end

    if not scrollBar then
        return nil
    end

    scrollFrame.ScrollBar = scrollBar
    frame.verticalScrollBar = scrollBar
    SetInstanceFarmingFrameLevel(scrollBar, frame.listPanel or scrollFrame, 3)

    if scrollBar.goldTrackerManualScrollBar and not scrollBar.goldTrackerManualScriptBound and scrollBar.SetScript then
        scrollBar.goldTrackerManualScriptBound = true
        scrollBar:SetScript("OnValueChanged", function(self, value)
            if self.updating then
                return
            end

            local visibleRows = GetInstanceFarmingVisibleRows(frame)
            local maxOffset = math.max(0, #(frame.displayRows or {}) - visibleRows)
            local nextOffset = math.floor(((tonumber(value) or 0) / ROW_STRIDE) + 0.5)
            if nextOffset < 0 then
                nextOffset = 0
            elseif nextOffset > maxOffset then
                nextOffset = maxOffset
            end

            if FauxScrollFrame_SetOffset then
                FauxScrollFrame_SetOffset(scrollFrame, nextOffset)
            else
                scrollFrame.offset = nextOffset
            end
            if GoldTracker and type(GoldTracker.RefreshInstanceFarmingWindow) == "function" then
                GoldTracker:RefreshInstanceFarmingWindow(false)
            end
        end)
    end

    return scrollBar
end

local function UpdateInstanceFarmingVerticalScrollBar(frame, displayRowCount, visibleRows, offset)
    local scrollBar = EnsureInstanceFarmingVerticalScrollBar(frame)
    if not scrollBar then
        return
    end

    local maxOffset = math.max(0, (tonumber(displayRowCount) or 0) - (tonumber(visibleRows) or 0))
    local maxValue = maxOffset * ROW_STRIDE
    local value = math.min(maxValue, math.max(0, (tonumber(offset) or 0) * ROW_STRIDE))

    if scrollBar.SetMinMaxValues then
        scrollBar:SetMinMaxValues(0, maxValue)
    end
    if scrollBar.SetValueStep then
        scrollBar:SetValueStep(ROW_STRIDE)
    end
    if scrollBar.SetStepsPerPage then
        scrollBar:SetStepsPerPage(math.max(1, (tonumber(visibleRows) or 1) - 1))
    end
    if scrollBar.SetObeyStepOnDrag then
        scrollBar:SetObeyStepOnDrag(true)
    end
    if scrollBar.SetShown then
        scrollBar:SetShown(maxOffset > 0)
    elseif maxOffset > 0 and scrollBar.Show then
        scrollBar:Show()
    elseif maxOffset <= 0 and scrollBar.Hide then
        scrollBar:Hide()
    end
    if scrollBar.SetValue then
        scrollBar.updating = true
        scrollBar:SetValue(value)
        scrollBar.updating = false
    end
end

local function ScrollInstanceFarmingResultsHorizontally(frame, delta)
    if not frame or not (type(IsShiftKeyDown) == "function" and IsShiftKeyDown()) then
        return false
    end

    local maxOffset = math.max(0, math.floor((tonumber(frame.tableWidth) or 0) - GetInstanceFarmingTableViewportWidth(frame)))
    if maxOffset <= 0 then
        return false
    end

    local currentOffset = math.min(math.max(0, math.floor(tonumber(frame.horizontalScrollOffset) or 0)), maxOffset)
    local step = math.max(20, math.floor(GetInstanceFarmingTableViewportWidth(frame) * 0.10))
    local nextOffset = currentOffset - ((tonumber(delta) or 0) * step)
    if nextOffset < 0 then
        nextOffset = 0
    elseif nextOffset > maxOffset then
        nextOffset = maxOffset
    end

    if nextOffset ~= currentOffset then
        if frame.horizontalScrollBar and frame.horizontalScrollBar.SetValue then
            frame.horizontalScrollBar:SetValue(nextOffset)
        else
            frame.horizontalScrollOffset = nextOffset
            if ApplyTableColumnLayout then
                ApplyTableColumnLayout(frame)
            end
        end
    end
    return true
end

local function ScrollInstanceFarmingResultsVertically(frame, delta)
    local scrollFrame = frame and frame.scrollFrame
    if not scrollFrame then
        return
    end

    local visibleRows = GetInstanceFarmingVisibleRows(frame)
    local maxOffset = math.max(0, #(frame.displayRows or {}) - visibleRows)
    if maxOffset <= 0 then
        return
    end

    local currentOffset = FauxScrollFrame_GetOffset and FauxScrollFrame_GetOffset(scrollFrame) or tonumber(scrollFrame.offset) or 0
    local nextOffset = currentOffset - ((tonumber(delta) or 0) * 3)
    if nextOffset < 0 then
        nextOffset = 0
    elseif nextOffset > maxOffset then
        nextOffset = maxOffset
    end

    if nextOffset == currentOffset then
        return
    end

    if FauxScrollFrame_SetOffset then
        FauxScrollFrame_SetOffset(scrollFrame, nextOffset)
    else
        scrollFrame.offset = nextOffset
    end

    local scrollBar = EnsureInstanceFarmingVerticalScrollBar(frame)
    if scrollBar and scrollBar.SetValue then
        scrollBar.updating = true
        scrollBar:SetValue(nextOffset * ROW_STRIDE)
        scrollBar.updating = false
    end
    if GoldTracker and type(GoldTracker.RefreshInstanceFarmingWindow) == "function" then
        GoldTracker:RefreshInstanceFarmingWindow(false)
    end
end

local function HandleInstanceFarmingResultsMouseWheel(frame, delta)
    if ScrollInstanceFarmingResultsHorizontally(frame, delta) then
        return
    end
    ScrollInstanceFarmingResultsVertically(frame, delta)
end

local function BindInstanceFarmingResultsMouseWheel(frameObject, frame)
    if not frameObject or not frameObject.EnableMouseWheel then
        return
    end
    frameObject:EnableMouseWheel(true)
    frameObject:SetScript("OnMouseWheel", function(_, delta)
        HandleInstanceFarmingResultsMouseWheel(frame, delta)
    end)
end

function GoldTracker:GetInstanceFarmingWindowRow(index)
    local frame = self.instanceFarmingFrame
    if not frame then
        return nil
    end
    frame.rowPool = frame.rowPool or {}
    local row = frame.rowPool[index]
    if row then
        SetInstanceFarmingFrameLevel(row, frame.listPanel, 3)
        return row
    end
    row = CreateFrame("Button", nil, frame.listPanel)
    SetInstanceFarmingFrameLevel(row, frame.listPanel, 3)
    row:SetHeight(ROW_HEIGHT)
    row:RegisterForClicks("LeftButtonUp")
    row:EnableMouse(true)
    BindInstanceFarmingResultsMouseWheel(row, frame)
    row.background = row:CreateTexture(nil, "BACKGROUND")
    row.background:SetAllPoints(row)
    row.trackButton = CreateButton(row, TRACKED_BUTTON_WIDTH, TRACKED_BUTTON_HEIGHT, "+", "neutral")
    BindInstanceFarmingResultsMouseWheel(row.trackButton, frame)
    row.trackButton:RegisterForClicks("LeftButtonUp")
    row.trackButton:SetScript("OnClick", function(self)
        GoldTracker:ToggleInstanceFarmingFavorite(self:GetParent())
    end)
    row.trackButton:SetScript("OnEnter", function(self)
        self.isHovered = true
        if self.theme and self.theme.UpdateButtonVisual then
            self.theme:UpdateButtonVisual(self)
        end
        GameTooltip:SetOwner(self, "ANCHOR_CURSOR")
        GameTooltip:AddLine(self:GetParent().tracked and "Remove tracked item" or "Track item", 1, 1, 1)
        GameTooltip:Show()
    end)
    row.trackButton:SetScript("OnLeave", function(self)
        self.isHovered = false
        self.isPressed = false
        if self.theme and self.theme.UpdateButtonVisual then
            self.theme:UpdateButtonVisual(self)
        end
        GameTooltip:Hide()
    end)
    row.expansionText = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    row.expansionText:SetJustifyH("LEFT")
    row.expansionText:SetWordWrap(false)
    row.typeText = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    row.typeText:SetJustifyH("LEFT")
    row.typeText:SetWordWrap(false)
    row.instanceText = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    row.instanceText:SetJustifyH("LEFT")
    row.instanceText:SetWordWrap(false)
    row.bossText = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    row.bossText:SetJustifyH("LEFT")
    row.bossText:SetWordWrap(false)
    row.icon = row:CreateTexture(nil, "ARTWORK")
    row.icon:SetSize(ICON_SIZE, ICON_SIZE)
    row.itemText = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    row.itemText:SetJustifyH("LEFT")
    row.itemText:SetWordWrap(false)
    row.valueText = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    row.valueText:SetJustifyH("RIGHT")
    row.marketText = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    row.marketText:SetJustifyH("RIGHT")
    row.regionText = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    row.regionText:SetJustifyH("RIGHT")
    row.averageText = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    row.averageText:SetJustifyH("RIGHT")
    row.detailsButton = CreateButton(row, DETAILS_WIDTH, 20, "Details", "neutral")
    BindInstanceFarmingResultsMouseWheel(row.detailsButton, frame)
    row.detailsButton:SetScript("OnClick", function(self)
        GoldTracker:OpenInventoryItemDetailsWindow(self:GetParent())
    end)
    row.mapButton = CreateButton(row, MAP_WIDTH, 20, "Map", "neutral")
    BindInstanceFarmingResultsMouseWheel(row.mapButton, frame)
    row.mapButton:SetScript("OnClick", function(self)
        GoldTracker:OpenInstanceFarmingMap(self:GetParent())
    end)
    row:SetScript("OnEnter", SetItemTooltip)
    row:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)
    row:SetScript("OnClick", function(self)
        GoldTracker:HandleModifiedItemClickIfModified(self)
    end)
    frame.rowPool[index] = row
    return row
end

ApplyTableColumnLayout = function(frame)
    if not frame or not frame.listPanel then
        return
    end
    local contentWidth = GetInstanceFarmingTableViewportWidth(frame)
    local gapCount = 11
    local fixedMinimum =
        TRACK_WIDTH
        + EXPANSION_MIN_WIDTH
        + TYPE_WIDTH
        + INSTANCE_MIN_WIDTH
        + BOSS_MIN_WIDTH
        + ITEM_MIN_WIDTH
        + (VALUE_MIN_WIDTH * 4)
        + DETAILS_WIDTH
        + MAP_WIDTH
        + (COLUMN_GAP * gapCount)
    local tableWidth = math.max(contentWidth, fixedMinimum)
    frame.tableWidth = tableWidth
    local maxHorizontalOffset = math.max(0, tableWidth - contentWidth)
    frame.horizontalScrollOffset = math.min(
        math.max(0, math.floor(tonumber(frame.horizontalScrollOffset) or 0)),
        maxHorizontalOffset
    )
    if frame.horizontalScrollBar then
        frame.horizontalScrollBar:SetMinMaxValues(0, maxHorizontalOffset)
        frame.horizontalScrollBar:SetValueStep(20)
        if frame.horizontalScrollBar.SetObeyStepOnDrag then
            frame.horizontalScrollBar:SetObeyStepOnDrag(false)
        end
        frame.horizontalScrollBar:SetShown(maxHorizontalOffset > 0)
        frame.horizontalScrollBar.updating = true
        frame.horizontalScrollBar:SetValue(frame.horizontalScrollOffset)
        frame.horizontalScrollBar.updating = false
    end

    local extraWidth = math.max(0, tableWidth - fixedMinimum)
    local valueExtra = math.min(18, math.floor(extraWidth * 0.08))
    local expansionWidth = EXPANSION_MIN_WIDTH + math.min(40, math.floor(extraWidth * 0.10))
    local instanceWidth = INSTANCE_MIN_WIDTH + math.min(150, math.floor(extraWidth * 0.24))
    local bossWidth = BOSS_MIN_WIDTH + math.min(120, math.floor(extraWidth * 0.20))
    local valueWidth = VALUE_MIN_WIDTH + valueExtra
    local itemExtraUsed =
        (expansionWidth - EXPANSION_MIN_WIDTH)
        + (instanceWidth - INSTANCE_MIN_WIDTH)
        + (bossWidth - BOSS_MIN_WIDTH)
        + ((valueWidth - VALUE_MIN_WIDTH) * 4)
    local itemWidth = math.max(ITEM_MIN_WIDTH, ITEM_MIN_WIDTH + extraWidth - itemExtraUsed)

    local trackX = HEADER_LEFT_INSET
    local expansionX = trackX + TRACK_WIDTH + COLUMN_GAP
    local typeX = expansionX + expansionWidth + COLUMN_GAP
    local instanceX = typeX + TYPE_WIDTH + COLUMN_GAP
    local bossX = instanceX + instanceWidth + COLUMN_GAP
    local itemX = bossX + bossWidth + COLUMN_GAP
    local valueX = itemX + itemWidth + COLUMN_GAP
    local marketX = valueX + valueWidth + COLUMN_GAP
    local regionX = marketX + valueWidth + COLUMN_GAP
    local averageX = regionX + valueWidth + COLUMN_GAP
    local detailsX = averageX + valueWidth + COLUMN_GAP
    local mapX = detailsX + DETAILS_WIDTH + COLUMN_GAP
    local horizontalOffset = math.max(0, tonumber(frame.horizontalScrollOffset) or 0)

    SetHeaderColumn(frame.trackHeaderButton, frame.listPanel, trackX - horizontalOffset, TRACK_WIDTH)
    SetHeaderColumn(frame.expansionHeaderButton, frame.listPanel, expansionX - horizontalOffset, expansionWidth)
    SetHeaderColumn(frame.typeHeaderButton, frame.listPanel, typeX - horizontalOffset, TYPE_WIDTH)
    SetHeaderColumn(frame.instanceHeaderButton, frame.listPanel, instanceX - horizontalOffset, instanceWidth)
    SetHeaderColumn(frame.bossHeaderButton, frame.listPanel, bossX - horizontalOffset, bossWidth)
    SetHeaderColumn(frame.itemHeaderButton, frame.listPanel, itemX - horizontalOffset, itemWidth)
    SetHeaderColumn(frame.valueHeaderButton, frame.listPanel, valueX - horizontalOffset, valueWidth)
    SetHeaderColumn(frame.marketHeaderButton, frame.listPanel, marketX - horizontalOffset, valueWidth)
    SetHeaderColumn(frame.regionHeaderButton, frame.listPanel, regionX - horizontalOffset, valueWidth)
    SetHeaderColumn(frame.averageHeaderButton, frame.listPanel, averageX - horizontalOffset, valueWidth)
    SetHeaderColumn(frame.detailsHeaderButton, frame.listPanel, detailsX - horizontalOffset, DETAILS_WIDTH)
    SetHeaderColumn(frame.mapHeaderButton, frame.listPanel, mapX - horizontalOffset, MAP_WIDTH)

    for _, row in ipairs(frame.rowPool or {}) do
        if row.trackButton then
            row.trackButton:ClearAllPoints()
            row.trackButton:SetPoint(
                "LEFT",
                row,
                "LEFT",
                trackX + math.floor((TRACK_WIDTH - TRACKED_BUTTON_WIDTH) / 2) - horizontalOffset,
                0
            )
            row.trackButton:SetSize(TRACKED_BUTTON_WIDTH, TRACKED_BUTTON_HEIGHT)
        end
        SetColumn(row.expansionText, row, expansionX - horizontalOffset, expansionWidth)
        SetColumn(row.typeText, row, typeX - horizontalOffset, TYPE_WIDTH)
        SetColumn(row.instanceText, row, instanceX - horizontalOffset, instanceWidth)
        SetColumn(row.bossText, row, bossX - horizontalOffset, bossWidth)
        row.icon:ClearAllPoints()
        row.icon:SetPoint("LEFT", row, "LEFT", itemX - horizontalOffset, 0)
        SetColumn(row.itemText, row, itemX + ICON_SIZE + 8 - horizontalOffset, math.max(80, itemWidth - ICON_SIZE - 8))
        SetColumn(row.valueText, row, valueX - horizontalOffset, valueWidth)
        SetColumn(row.marketText, row, marketX - horizontalOffset, valueWidth)
        SetColumn(row.regionText, row, regionX - horizontalOffset, valueWidth)
        SetColumn(row.averageText, row, averageX - horizontalOffset, valueWidth)
        SetColumn(row.detailsButton, row, detailsX - horizontalOffset, DETAILS_WIDTH)
        SetColumn(row.mapButton, row, mapX - horizontalOffset, MAP_WIDTH)
    end
end

function GoldTracker:RefreshInstanceFarmingWindow(scrollToTop)
    local frame = self.instanceFarmingFrame
    if not frame or frame.instanceFarmingViewID ~= "scan" then
        return
    end

    self:RefreshInstanceFarmingWindowControls()
    self:UpdateInstanceFarmingSortHeaderState()
    ApplyTableColumnLayout(frame)

    local displayRows = {}
    for _, row in ipairs(frame.lastResults or {}) do
        EnsureRowItemDisplayData(self, row)
        if IsDisplayRowAuctionable(self, row) then
            row.tracked = self:IsInstanceFarmingFavorite(row)
            displayRows[#displayRows + 1] = row
        end
    end
    SortRows(displayRows, frame.sortKey, frame.sortAscending)
    frame.displayRows = displayRows

    local scrollFrame = frame.scrollFrame
    local visibleRows = GetInstanceFarmingVisibleRows(frame)
    if scrollToTop then
        if FauxScrollFrame_SetOffset then
            FauxScrollFrame_SetOffset(scrollFrame, 0)
        else
            scrollFrame.offset = 0
        end
        if scrollFrame.ScrollBar then
            scrollFrame.ScrollBar:SetValue(0)
        elseif scrollFrame.Scrollbar then
            scrollFrame.Scrollbar:SetValue(0)
        end
    end
    FauxScrollFrame_Update(scrollFrame, #displayRows, visibleRows, ROW_STRIDE)
    local maxOffset = math.max(0, #displayRows - visibleRows)
    local offset = FauxScrollFrame_GetOffset and FauxScrollFrame_GetOffset(scrollFrame) or tonumber(scrollFrame.offset) or 0
    if offset > maxOffset then
        offset = maxOffset
        if FauxScrollFrame_SetOffset then
            FauxScrollFrame_SetOffset(scrollFrame, offset)
        else
            scrollFrame.offset = offset
        end
    end
    UpdateInstanceFarmingVerticalScrollBar(frame, #displayRows, visibleRows, offset)

    for poolIndex = 1, visibleRows do
        local rowIndex = offset + poolIndex
        local data = displayRows[rowIndex]
        local row = self:GetInstanceFarmingWindowRow(poolIndex)
        row:ClearAllPoints()
        row:SetPoint("TOPLEFT", frame.listPanel, "TOPLEFT", 0, -34 - ((poolIndex - 1) * ROW_STRIDE))
        row:SetPoint("TOPRIGHT", frame.listPanel, "TOPRIGHT", -24, -34 - ((poolIndex - 1) * ROW_STRIDE))
        if data then
            row.itemID = data.itemID
            row.itemName = data.itemName
            row.itemLink = data.itemLink
            row.itemQuality = data.itemQuality
            row.iconTexture = data.icon
            row.bindType = data.bindType
            row.expansionID = data.expansionID
            row.expansionLabel = data.expansionLabel
            row.contentType = data.contentType
            row.instanceName = data.instanceName
            row.instanceEncounterJournalID = data.instanceEncounterJournalID
            row.instanceMapID = data.instanceMapID
            row.instanceEntrance = data.instanceEntrance
            row.bossName = data.bossName
            row.bossEncounterJournalID = data.bossEncounterJournalID
            row.bossMapID = data.bossMapID
            row.bossX = data.bossX
            row.bossY = data.bossY
            row.difficulties = data.difficulties
            row.value = data.value
            row.marketValue = data.marketValue
            row.regionMarketValue = data.regionMarketValue
            row.averageValue = data.averageValue
            row.valueSourceID = data.valueSourceID
            row.valueSourceLabel = data.valueSourceLabel
            row.marketHistoryItemKey = data.marketHistoryItemKey
            row.tracked = self:IsInstanceFarmingFavorite(data)
            row.favoriteKey = GetFavoriteKey(data)
            row.background:SetColorTexture(1, 1, 1, rowIndex % 2 == 0 and 0.045 or 0.022)
            row.trackButton:SetText(row.tracked and "-" or "+")
            if row.trackButton.SetSelected then
                row.trackButton:SetSelected(row.tracked)
            end
            row.expansionText:SetText(data.expansionLabel or "")
            row.typeText:SetText(FormatContentType(data.contentType))
            row.instanceText:SetText(GetInstanceDisplayName(data))
            row.bossText:SetText(GetBossDisplayName(data))
            if data.icon then
                row.icon:SetTexture(data.icon)
                row.icon:Show()
            else
                row.icon:Hide()
            end
            row.itemText:SetText(data.itemLink or data.itemName or ("Item " .. tostring(data.itemID)))
            row.valueText:SetText(self:FormatMoney(data.value or 0))
            row.marketText:SetText(self:FormatMoney(data.marketValue or 0))
            row.regionText:SetText(self:FormatMoney(data.regionMarketValue or 0))
            row.averageText:SetText(self:FormatMoney(data.averageValue or 0))
            row:Show()
        else
            row:Hide()
        end
    end
    for poolIndex = visibleRows + 1, #(frame.rowPool or {}) do
        frame.rowPool[poolIndex]:Hide()
    end

    if frame.emptyText then
        local state = frame.scanState
        if #displayRows == 0 then
            if state then
                frame.emptyText:SetText("Scanning...")
            elseif frame.hasInstanceFarmingScanRun then
                frame.emptyText:SetText("No matching auctionable instance drops found.")
            else
                frame.emptyText:SetText("Set filters, then click Scan. This can take quite a while, especially All.")
            end
            frame.emptyText:Show()
        else
            frame.emptyText:Hide()
        end
    end
    if frame.metaText then
        frame.metaText:SetText(string.format(
            "%d shown | %s | %s | Threshold %s | %s",
            #displayRows,
            GetExpansionFilterLabel(frame.expansionFilterID),
            GetContentTypeFilterLabel(frame.contentTypeFilterID),
            self:FormatMoney(frame.minimumValueCopper or 0),
            (self.VALUE_SOURCE_BY_ID[frame.valueSourceID] or self:GetInstanceFarmingValueSource()).label
        ))
    end
    ApplyTableColumnLayout(frame)
end

function GoldTracker:CreateInstanceFarmingWindow()
    if self.instanceFarmingFrame then
        return
    end

    local frame = CreateFrame("Frame", "GoldTrackerInstanceFarmingFrame", UIParent, "BasicFrameTemplateWithInset")
    frame:SetSize(WINDOW_WIDTH, WINDOW_HEIGHT)
    frame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    frame:SetFrameStrata("DIALOG")
    if frame.SetResizeBounds then
        frame:SetResizeBounds(WINDOW_MIN_WIDTH, WINDOW_MIN_HEIGHT, 1420, 900)
    end
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
    frame:SetResizable(true)
    frame:Hide()

    local chrome = Theme:ApplyWindowChrome(frame, "Dungeon & Raid Farming")
    Theme:RegisterSpecialFrame("GoldTrackerInstanceFarmingFrame")

    frame.valueSourceID = self:GetInstanceFarmingValueSource().id
    frame.minimumValueCopper = self:GetInstanceFarmingMinimumValue()
    frame.expansionFilterID = self:GetInstanceFarmingExpansionFilter()
    frame.contentTypeFilterID = self:GetInstanceFarmingContentTypeFilter()
    frame.scanModeID = self:GetInstanceFarmingScanMode()
    frame.sortKey = DEFAULT_SORT_KEY
    frame.sortAscending = false
    frame.lastResults = {}
    frame.instanceFarmingLibraryTab = "saved"
    frame.instanceFarmingNavigationTab = "saved"

    local savedTabButton = CreateButton(frame, 104, 24, "Saved Scans", "primary")
    savedTabButton:SetPoint("TOPLEFT", chrome, "TOPLEFT", 14, -54)
    savedTabButton:SetScript("OnClick", function()
        frame.instanceFarmingLibraryTab = "saved"
        frame.instanceFarmingNavigationTab = "saved"
        self:SetInstanceFarmingWindowView("library")
    end)
    frame.savedTabButton = savedTabButton

    local favoritesTabButton = CreateButton(frame, 96, 24, "Favorites", "neutral")
    favoritesTabButton:SetPoint("LEFT", savedTabButton, "RIGHT", 8, 0)
    favoritesTabButton:SetScript("OnClick", function()
        frame.instanceFarmingLibraryTab = "favorites"
        frame.instanceFarmingNavigationTab = "favorites"
        self:SetInstanceFarmingWindowView("library")
    end)
    frame.favoritesTabButton = favoritesTabButton

    local newScanTabButton = CreateButton(frame, 96, 24, "New Scan", "neutral")
    newScanTabButton:SetPoint("LEFT", favoritesTabButton, "RIGHT", 8, 0)
    newScanTabButton:SetScript("OnClick", function()
        self:OpenInstanceFarmingNewScan()
    end)
    frame.newScanTabButton = newScanTabButton

    local libraryUpdateFavoritesButton = CreateButton(frame, 126, 24, "Update Prices", "neutral")
    libraryUpdateFavoritesButton:SetPoint("TOPRIGHT", chrome, "TOPRIGHT", -14, -54)
    libraryUpdateFavoritesButton:SetScript("OnClick", function()
        self:UpdateInstanceFarmingFavoritePrices()
    end)
    frame.libraryUpdateFavoritesButton = libraryUpdateFavoritesButton

    local libraryPanel = CreatePanel(frame, { 0.04, 0.05, 0.07, 0.94 }, { 1.0, 0.82, 0.18, 0.12 })
    SetInstanceFarmingFrameLevel(libraryPanel, chrome, 1)
    libraryPanel:SetPoint("TOPLEFT", chrome, "TOPLEFT", 14, -86)
    libraryPanel:SetPoint("BOTTOMRIGHT", chrome, "BOTTOMRIGHT", -14, 38)
    frame.libraryPanel = libraryPanel

    local libraryStatusText = libraryPanel:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    libraryStatusText:SetPoint("TOPLEFT", libraryPanel, "TOPLEFT", 14, -12)
    libraryStatusText:SetPoint("RIGHT", libraryPanel, "RIGHT", -14, 0)
    libraryStatusText:SetJustifyH("LEFT")
    libraryStatusText:SetTextColor(0.72, 0.76, 0.84)
    frame.libraryStatusText = libraryStatusText

    local libraryScrollFrame = CreateFrame("ScrollFrame", nil, libraryPanel, "UIPanelScrollFrameTemplate")
    SetInstanceFarmingFrameLevel(libraryScrollFrame, libraryPanel, 2)
    libraryScrollFrame:SetPoint("TOPLEFT", libraryStatusText, "BOTTOMLEFT", 0, -10)
    libraryScrollFrame:SetPoint("BOTTOMRIGHT", libraryPanel, "BOTTOMRIGHT", -26, 12)
    libraryScrollFrame:EnableMouseWheel(true)
    libraryScrollFrame:SetScript("OnMouseWheel", function(self, delta)
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
    frame.libraryScrollFrame = libraryScrollFrame

    local libraryContent = CreateFrame("Frame", nil, libraryScrollFrame)
    SetInstanceFarmingFrameLevel(libraryContent, libraryScrollFrame, 1)
    libraryContent:SetSize(1, 1)
    libraryScrollFrame:SetScrollChild(libraryContent)
    frame.libraryContent = libraryContent

    local libraryEmptyText = libraryContent:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    libraryEmptyText:SetPoint("TOPLEFT", libraryContent, "TOPLEFT", 10, -12)
    libraryEmptyText:SetPoint("RIGHT", libraryPanel, "RIGHT", -40, 0)
    libraryEmptyText:SetJustifyH("LEFT")
    libraryEmptyText:SetTextColor(0.62, 0.66, 0.74)
    frame.libraryEmptyText = libraryEmptyText

    local controlsPanel = CreatePanel(frame, { 0.05, 0.06, 0.08, 0.94 }, { 1.0, 0.82, 0.18, 0.12 })
    SetInstanceFarmingFrameLevel(controlsPanel, chrome, 1)
    controlsPanel:SetPoint("TOPLEFT", chrome, "TOPLEFT", 14, -86)
    controlsPanel:SetPoint("TOPRIGHT", chrome, "TOPRIGHT", -14, -86)
    controlsPanel:SetHeight(158)
    frame.controlsPanel = controlsPanel

    local sourceLabel = controlsPanel:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    sourceLabel:SetPoint("TOPLEFT", controlsPanel, "TOPLEFT", 14, -10)
    sourceLabel:SetText("Value source")
    local valueSourceDropdown = CreateFrame("Frame", "GoldTrackerInstanceFarmingValueSourceDropdown", controlsPanel, "UIDropDownMenuTemplate")
    valueSourceDropdown:SetPoint("TOPLEFT", sourceLabel, "BOTTOMLEFT", -16, -5)
    UIDropDownMenu_SetWidth(valueSourceDropdown, 190)
    UIDropDownMenu_Initialize(valueSourceDropdown, function(_, level)
        for _, source in ipairs(self.VALUE_SOURCES) do
            local sourceID = source.id
            local info = UIDropDownMenu_CreateInfo()
            info.text = source.label
            info.value = sourceID
            info.checked = frame.valueSourceID == sourceID
            info.func = function()
                self:SetInstanceFarmingValueSource(sourceID)
            end
            UIDropDownMenu_AddButton(info, level)
        end
    end)
    frame.valueSourceDropdown = valueSourceDropdown

    local minimumLabel = controlsPanel:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    minimumLabel:SetPoint("TOPLEFT", sourceLabel, "TOPLEFT", 260, 0)
    minimumLabel:SetText("Min value (g)")
    local minimumValueInput = CreateFrame("EditBox", nil, controlsPanel, "InputBoxTemplate")
    minimumValueInput:SetSize(96, 22)
    minimumValueInput:SetPoint("TOPLEFT", minimumLabel, "BOTTOMLEFT", 0, -8)
    minimumValueInput:SetAutoFocus(false)
    minimumValueInput:SetNumeric(false)
    minimumValueInput:SetText(FormatGoldInput(self, frame.minimumValueCopper))
    minimumValueInput:SetScript("OnEnterPressed", function(editBox)
        self:SaveInstanceFarmingMinimumValueInput()
        editBox:ClearFocus()
    end)
    minimumValueInput:SetScript("OnEditFocusLost", function()
        self:SaveInstanceFarmingMinimumValueInput()
    end)
    frame.minimumValueInput = minimumValueInput

    local expansionLabel = controlsPanel:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    expansionLabel:SetPoint("TOPLEFT", sourceLabel, "TOPLEFT", 410, 0)
    expansionLabel:SetText("Expansion")
    local expansionDropdown = CreateFrame("Frame", "GoldTrackerInstanceFarmingExpansionDropdown", controlsPanel, "UIDropDownMenuTemplate")
    expansionDropdown:SetPoint("TOPLEFT", expansionLabel, "BOTTOMLEFT", -16, -5)
    UIDropDownMenu_SetWidth(expansionDropdown, 160)
    UIDropDownMenu_Initialize(expansionDropdown, function(_, level)
        for _, option in ipairs(GetExpansionOptions()) do
            local optionID = option.id
            local info = UIDropDownMenu_CreateInfo()
            info.text = option.label
            info.value = optionID
            info.checked = frame.expansionFilterID == optionID
            info.func = function()
                self:SetInstanceFarmingExpansionFilter(optionID)
            end
            UIDropDownMenu_AddButton(info, level)
        end
    end)
    frame.expansionDropdown = expansionDropdown

    local typeLabel = controlsPanel:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    typeLabel:SetPoint("TOPLEFT", sourceLabel, "TOPLEFT", 600, 0)
    typeLabel:SetText("Type")
    local contentTypeDropdown = CreateFrame("Frame", "GoldTrackerInstanceFarmingTypeDropdown", controlsPanel, "UIDropDownMenuTemplate")
    contentTypeDropdown:SetPoint("TOPLEFT", typeLabel, "BOTTOMLEFT", -16, -5)
    UIDropDownMenu_SetWidth(contentTypeDropdown, 110)
    UIDropDownMenu_Initialize(contentTypeDropdown, function(_, level)
        for _, option in ipairs(CONTENT_TYPE_OPTIONS) do
            local optionID = option.id
            local info = UIDropDownMenu_CreateInfo()
            info.text = option.label
            info.value = optionID
            info.checked = frame.contentTypeFilterID == optionID
            info.func = function()
                self:SetInstanceFarmingContentTypeFilter(optionID)
            end
            UIDropDownMenu_AddButton(info, level)
        end
    end)
    frame.contentTypeDropdown = contentTypeDropdown

    local modeLabel = controlsPanel:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    modeLabel:SetPoint("TOPLEFT", sourceLabel, "TOPLEFT", 750, 0)
    modeLabel:SetText("Mode")
    local scanModeDropdown = CreateFrame("Frame", "GoldTrackerInstanceFarmingScanModeDropdown", controlsPanel, "UIDropDownMenuTemplate")
    scanModeDropdown:SetPoint("TOPLEFT", modeLabel, "BOTTOMLEFT", -16, -5)
    UIDropDownMenu_SetWidth(scanModeDropdown, 120)
    UIDropDownMenu_Initialize(scanModeDropdown, function(_, level)
        for _, option in ipairs(SCAN_MODE_OPTIONS) do
            local optionID = option.id
            local info = UIDropDownMenu_CreateInfo()
            info.text = option.label
            info.value = optionID
            info.checked = frame.scanModeID == optionID
            info.func = function()
                self:SetInstanceFarmingScanMode(optionID)
            end
            UIDropDownMenu_AddButton(info, level)
        end
    end)
    frame.scanModeDropdown = scanModeDropdown

    local scanButton = CreateButton(controlsPanel, 92, 24, "Scan", "primary")
    scanButton:SetPoint("TOPRIGHT", controlsPanel, "TOPRIGHT", -14, -62)
    scanButton:SetScript("OnClick", function()
        self:StartInstanceFarmingScan()
    end)
    frame.scanButton = scanButton
    local stopScanButton = CreateButton(controlsPanel, 82, 24, "Stop", "danger")
    stopScanButton:SetPoint("RIGHT", scanButton, "LEFT", -8, 0)
    stopScanButton:SetScript("OnClick", function()
        self:CancelInstanceFarmingScan()
    end)
    frame.stopScanButton = stopScanButton
    local saveButton = CreateButton(controlsPanel, 82, 24, "Save", "neutral")
    saveButton:SetPoint("RIGHT", scanButton, "LEFT", -8, 0)
    saveButton:SetScript("OnClick", function()
        self:SaveCurrentInstanceFarmingScan()
    end)
    frame.saveButton = saveButton
    stopScanButton:ClearAllPoints()
    stopScanButton:SetPoint("RIGHT", saveButton, "LEFT", -8, 0)
    local updatePricesButton = CreateButton(controlsPanel, 116, 24, "Update Prices", "neutral")
    updatePricesButton:SetPoint("RIGHT", stopScanButton, "LEFT", -8, 0)
    updatePricesButton:SetScript("OnClick", function()
        self:UpdateCurrentInstanceFarmingScanPrices()
    end)
    frame.updatePricesButton = updatePricesButton
    local rescanButton = CreateButton(controlsPanel, 126, 24, "Rescan Expansion", "primary")
    rescanButton:SetPoint("RIGHT", updatePricesButton, "LEFT", -8, 0)
    rescanButton:SetScript("OnClick", function()
        self:RescanCurrentInstanceFarmingSelection()
    end)
    frame.rescanButton = rescanButton

    local helpText = controlsPanel:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    helpText:SetPoint("TOPLEFT", controlsPanel, "TOPLEFT", 14, -104)
    helpText:SetPoint("TOPRIGHT", controlsPanel, "TOPRIGHT", -14, -104)
    helpText:SetJustifyH("LEFT")
    helpText:SetText("Background lets you keep playing; Foreground is faster but can lower FPS. All expansions can take quite a while.")
    frame.helpText = helpText
    local progressBackdrop = CreatePanel(controlsPanel, { 0.03, 0.04, 0.06, 0.96 }, { 1, 1, 1, 0.08 })
    progressBackdrop:SetPoint("TOPLEFT", helpText, "BOTTOMLEFT", 0, -8)
    progressBackdrop:SetPoint("TOPRIGHT", helpText, "BOTTOMRIGHT", 0, -8)
    progressBackdrop:SetHeight(14)
    local progressBar = CreateFrame("StatusBar", nil, progressBackdrop)
    progressBar:SetAllPoints(progressBackdrop)
    progressBar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
    progressBar:SetStatusBarColor(0.92, 0.68, 0.18, 0.8)
    progressBar:SetMinMaxValues(0, 1)
    progressBar:SetValue(0)
    frame.progressBar = progressBar
    local statusText = controlsPanel:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    statusText:SetPoint("TOPLEFT", progressBackdrop, "BOTTOMLEFT", 0, -8)
    statusText:SetText("Ready.")
    frame.statusText = statusText

    local listPanel = CreatePanel(frame, { 0.04, 0.05, 0.07, 0.92 }, { 1.0, 0.82, 0.18, 0.10 })
    SetInstanceFarmingFrameLevel(listPanel, chrome, 1)
    listPanel:SetPoint("TOPLEFT", controlsPanel, "BOTTOMLEFT", 0, -10)
    listPanel:SetPoint("BOTTOMRIGHT", chrome, "BOTTOMRIGHT", -14, 36)
    if listPanel.SetClipsChildren then
        listPanel:SetClipsChildren(true)
    end
    frame.listPanel = listPanel
    local divider = listPanel:CreateTexture(nil, "ARTWORK")
    divider:SetColorTexture(1.0, 0.82, 0.18, 0.18)
    divider:SetPoint("TOPLEFT", listPanel, "TOPLEFT", 12, -30)
    divider:SetPoint("TOPRIGHT", listPanel, "TOPRIGHT", -28, -30)
    divider:SetHeight(1)

    frame.trackHeaderButton = CreateHeaderButton(listPanel, "Tracked", TRACK_WIDTH, "CENTER")
    SetInstanceFarmingFrameLevel(frame.trackHeaderButton, listPanel, 2)
    frame.expansionHeaderButton = CreateHeaderButton(listPanel, "Expansion", 102, "LEFT")
    SetInstanceFarmingFrameLevel(frame.expansionHeaderButton, listPanel, 2)
    frame.typeHeaderButton = CreateHeaderButton(listPanel, "Type", TYPE_WIDTH, "LEFT")
    SetInstanceFarmingFrameLevel(frame.typeHeaderButton, listPanel, 2)
    frame.instanceHeaderButton = CreateHeaderButton(listPanel, "Instance", INSTANCE_MIN_WIDTH, "LEFT")
    SetInstanceFarmingFrameLevel(frame.instanceHeaderButton, listPanel, 2)
    frame.bossHeaderButton = CreateHeaderButton(listPanel, "Boss", BOSS_MIN_WIDTH, "LEFT")
    SetInstanceFarmingFrameLevel(frame.bossHeaderButton, listPanel, 2)
    frame.itemHeaderButton = CreateHeaderButton(listPanel, "Item", nil, "LEFT")
    SetInstanceFarmingFrameLevel(frame.itemHeaderButton, listPanel, 2)
    frame.valueHeaderButton = CreateHeaderButton(listPanel, "Selected", VALUE_MIN_WIDTH, "RIGHT")
    SetInstanceFarmingFrameLevel(frame.valueHeaderButton, listPanel, 2)
    frame.marketHeaderButton = CreateHeaderButton(listPanel, "Market", VALUE_MIN_WIDTH, "RIGHT")
    SetInstanceFarmingFrameLevel(frame.marketHeaderButton, listPanel, 2)
    frame.regionHeaderButton = CreateHeaderButton(listPanel, "Region", VALUE_MIN_WIDTH, "RIGHT")
    SetInstanceFarmingFrameLevel(frame.regionHeaderButton, listPanel, 2)
    frame.averageHeaderButton = CreateHeaderButton(listPanel, "Avg", VALUE_MIN_WIDTH, "RIGHT")
    SetInstanceFarmingFrameLevel(frame.averageHeaderButton, listPanel, 2)
    frame.detailsHeaderButton = CreateHeaderButton(listPanel, "Details", DETAILS_WIDTH, "CENTER")
    SetInstanceFarmingFrameLevel(frame.detailsHeaderButton, listPanel, 2)
    frame.mapHeaderButton = CreateHeaderButton(listPanel, "Map", MAP_WIDTH, "CENTER")
    SetInstanceFarmingFrameLevel(frame.mapHeaderButton, listPanel, 2)
    frame.sortHeaders = {
        tracked = frame.trackHeaderButton,
        expansion = frame.expansionHeaderButton,
        type = frame.typeHeaderButton,
        instanceName = frame.instanceHeaderButton,
        bossName = frame.bossHeaderButton,
        itemName = frame.itemHeaderButton,
        value = frame.valueHeaderButton,
        marketValue = frame.marketHeaderButton,
        regionMarketValue = frame.regionHeaderButton,
        averageValue = frame.averageHeaderButton,
    }
    for sortKey, button in pairs(frame.sortHeaders) do
        button:SetScript("OnClick", function()
            self:ToggleInstanceFarmingSort(sortKey)
        end)
    end

    local scrollFrame = CreateFrame("ScrollFrame", "GoldTrackerInstanceFarmingResultsScrollFrame", listPanel, "FauxScrollFrameTemplate")
    SetInstanceFarmingFrameLevel(scrollFrame, listPanel, 2)
    scrollFrame:SetPoint("TOPLEFT", listPanel, "TOPLEFT", 0, -34)
    scrollFrame:SetPoint("BOTTOMRIGHT", listPanel, "BOTTOMRIGHT", -4, HORIZONTAL_SCROLL_HEIGHT)
    BindInstanceFarmingResultsMouseWheel(scrollFrame, frame)
    scrollFrame:SetScript("OnVerticalScroll", function(self, offset)
        FauxScrollFrame_OnVerticalScroll(self, offset, ROW_STRIDE, function()
            GoldTracker:RefreshInstanceFarmingWindow(false)
        end)
    end)
    frame.scrollFrame = scrollFrame
    EnsureInstanceFarmingVerticalScrollBar(frame)

    local horizontalScrollBar = CreateFrame("Slider", "GoldTrackerInstanceFarmingHorizontalScrollBar", listPanel, "OptionsSliderTemplate")
    SetInstanceFarmingFrameLevel(horizontalScrollBar, listPanel, 4)
    horizontalScrollBar:SetOrientation("HORIZONTAL")
    horizontalScrollBar:SetPoint("BOTTOMLEFT", listPanel, "BOTTOMLEFT", 14, 8)
    horizontalScrollBar:SetPoint("BOTTOMRIGHT", listPanel, "BOTTOMRIGHT", -32, 8)
    horizontalScrollBar:SetHeight(12)
    horizontalScrollBar:SetMinMaxValues(0, 0)
    horizontalScrollBar:SetValue(0)
    horizontalScrollBar:SetScript("OnValueChanged", function(self, value)
        if self.updating then
            return
        end
        frame.horizontalScrollOffset = math.max(0, math.floor((tonumber(value) or 0) + 0.5))
        ApplyTableColumnLayout(frame)
    end)
    local sliderName = horizontalScrollBar:GetName()
    for _, labelSuffix in ipairs({ "Text", "Low", "High" }) do
        local label = _G[sliderName .. labelSuffix]
        if label then
            label:SetText("")
        end
    end
    horizontalScrollBar:Hide()
    frame.horizontalScrollBar = horizontalScrollBar

    local emptyText = listPanel:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    emptyText:SetPoint("CENTER", listPanel, "CENTER", 0, 0)
    emptyText:SetText("Set filters, then click Scan. This can take quite a while, especially All.")
    frame.emptyText = emptyText
    local metaText = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    metaText:SetPoint("BOTTOMLEFT", chrome, "BOTTOMLEFT", 22, 16)
    frame.metaText = metaText

    frame:SetScript("OnSizeChanged", function()
        ApplyTableColumnLayout(frame)
        self:RefreshInstanceFarmingWindow(false)
        self:RefreshInstanceFarmingLibraryWindow()
    end)
    frame:SetScript("OnShow", function()
        if frame.suppressExplorerOnShow then
            return
        end
        self:RefreshInstanceFarmingWindowControls()
        if frame.instanceFarmingViewID == "scan" then
            self:RefreshInstanceFarmingWindow(true)
        else
            self:RefreshInstanceFarmingLibraryWindow()
        end
    end)
    frame:SetScript("OnHide", function()
        if frame.suppressInstanceFarmingHideMessage == true then
            return
        end
        if frame.scanState then
            self:Print("Instance farming scan continues in the background. Reopen the window to watch progress, or use Stop before closing next time.")
        end
    end)

    self.instanceFarmingFrame = frame
    self:SetInstanceFarmingWindowView("library")
end

function GoldTracker:OpenInstanceFarmingWindow()
    if type(self.OpenExplorerWindow) == "function" then
        self:OpenExplorerWindow("instances")
        return
    end

    self:CreateInstanceFarmingWindow()
    if not self.instanceFarmingFrame then
        return
    end
    self.instanceFarmingFrame:Show()
    self.instanceFarmingFrame:Raise()
    if self.instanceFarmingFrame.scanState then
        self:SetInstanceFarmingWindowView("scan")
    else
        self:SetInstanceFarmingWindowView("library")
    end
end

function GoldTracker:ToggleInstanceFarmingWindow()
    if type(self.ToggleExplorerWindow) == "function" then
        self:ToggleExplorerWindow("instances")
        return
    end

    self:CreateInstanceFarmingWindow()
    if not self.instanceFarmingFrame then
        return
    end
    if self.instanceFarmingFrame:IsShown() then
        self.instanceFarmingFrame:Hide()
    else
        self:OpenInstanceFarmingWindow()
    end
end
