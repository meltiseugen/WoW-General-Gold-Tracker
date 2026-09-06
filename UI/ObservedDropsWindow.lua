local _, NS = ...
local GoldTracker = NS.GoldTracker
local Theme = NS.JanisTheme

local WINDOW_WIDTH = 1280
local WINDOW_HEIGHT = 620
local WINDOW_MIN_WIDTH = 1040
local WINDOW_MIN_HEIGHT = 430
local WINDOW_MAX_WIDTH = 1480
local WINDOW_MAX_HEIGHT = 900
local ROW_HEIGHT = 24
local ROW_SPACING = 2
local ICON_SIZE = 18
local COLUMN_GAP = 10
local ROW_RIGHT_PADDING = 6
local HEADER_LEFT_INSET = 12
local TRACKED_WIDTH = 56
local EXPANSION_WIDTH = 122
local LOCATION_WIDTH = 152
local SOURCE_WIDTH = 138
local SEEN_WIDTH = 54
local QUANTITY_WIDTH = 46
local VALUE_WIDTH = 106
local DETAILS_WIDTH = 70
local ITEM_MIN_WIDTH = 150
local SORT_ICON_SIZE = 10
local HORIZONTAL_SCROLL_HEIGHT = 14
local DEFAULT_SORT_KEY = "value"
local OBSERVED_DROPS_BACKGROUND_SCAN_ITEMS_PER_TICK = 150
local OBSERVED_DROPS_SCAN_REFRESH_INTERVAL = 0.20
local OBSERVED_DROPS_SCAN_CACHE_VERSION = 1
local OBSERVED_DROPS_SCAN_CACHE_MAX_ENTRIES = 30
local EXPANSION_ALL_ID = "all"
local DROP_SOURCE_OBSERVED_ID = "observed"
local DROP_SOURCE_ATT_ZONES_ID = "att-zones"
local DROP_SOURCE_ATT_WORLD_ID = "att-world"
local ZONE_ALL_ID = "all"

local DROP_SOURCE_OPTIONS = {
    { id = DROP_SOURCE_OBSERVED_ID, label = "Observed" },
    { id = DROP_SOURCE_ATT_ZONES_ID, label = "Zones" },
    { id = DROP_SOURCE_ATT_WORLD_ID, label = "World", hidden = true },
}

local ATT_EXPANSION_BY_BLIZZARD_EXPANSION_ID = {
    [0] = "1",
    [1] = "2",
    [2] = "3",
    [3] = "4",
    [4] = "5",
    [5] = "6",
    [6] = "7",
    [7] = "8",
    [8] = "9",
    [9] = "10",
    [10] = "11",
    [11] = "12",
}

local ATT_EXPANSION_BY_MAP_ID = {
    [1] = "1",
    [10] = "1",
    [14] = "1",
    [15] = "1",
    [17] = "1",
    [18] = "1",
    [19] = "1",
    [21] = "1",
    [22] = "1",
    [23] = "1",
    [25] = "1",
    [26] = "1",
    [27] = "1",
    [32] = "1",
    [36] = "1",
    [37] = "1",
    [42] = "1",
    [47] = "1",
    [48] = "1",
    [49] = "1",
    [50] = "1",
    [51] = "1",
    [52] = "1",
    [56] = "1",
    [57] = "1",
    [63] = "1",
    [64] = "1",
    [65] = "1",
    [66] = "1",
    [69] = "1",
    [70] = "1",
    [71] = "1",
    [77] = "1",
    [78] = "1",
    [81] = "1",
    [83] = "1",
    [95] = "2",
    [97] = "2",
    [100] = "2",
    [102] = "2",
    [104] = "2",
    [105] = "2",
    [106] = "2",
    [107] = "2",
    [108] = "2",
    [109] = "2",
    [122] = "2",
    [114] = "3",
    [115] = "3",
    [116] = "3",
    [117] = "3",
    [118] = "3",
    [119] = "3",
    [120] = "3",
    [121] = "3",
    [123] = "3",
    [127] = "3",
    [198] = "4",
    [201] = "4",
    [204] = "4",
    [205] = "4",
    [207] = "4",
    [241] = "4",
    [244] = "4",
    [245] = "4",
    [249] = "4",
    [371] = "5",
    [376] = "5",
    [379] = "5",
    [388] = "5",
    [390] = "5",
    [418] = "5",
    [422] = "5",
    [504] = "5",
    [554] = "5",
    [525] = "6",
    [534] = "6",
    [535] = "6",
    [539] = "6",
    [542] = "6",
    [543] = "6",
    [550] = "6",
    [630] = "7",
    [634] = "7",
    [641] = "7",
    [646] = "7",
    [650] = "7",
    [680] = "7",
    [830] = "7",
    [882] = "7",
    [885] = "7",
    [862] = "8",
    [863] = "8",
    [864] = "8",
    [895] = "8",
    [896] = "8",
    [942] = "8",
    [1161] = "8",
    [1165] = "8",
    [1355] = "8",
    [1462] = "8",
    [1525] = "9",
    [1533] = "9",
    [1536] = "9",
    [1543] = "9",
    [1565] = "9",
    [1670] = "9",
    [1961] = "9",
    [1970] = "9",
    [2022] = "10",
    [2023] = "10",
    [2024] = "10",
    [2025] = "10",
    [2151] = "10",
    [2215] = "11",
    [2248] = "11",
    [2255] = "11",
    [2369] = "11",
    [2395] = "12",
    [2405] = "12",
    [2413] = "12",
    [2437] = "12",
    [2509] = "12",
    [2512] = "12",
}

local SORT_KEYS = {
    tracked = true,
    expansion = true,
    location = true,
    source = true,
    itemName = true,
    seenCount = true,
    quantity = true,
    value = true,
    marketValue = true,
    regionMarketValue = true,
    averageValue = true,
}

local function CreateObservedPanel(parent, bg, border)
    return Theme:CreatePanel(parent, bg, border)
end

local function CreateObservedButton(parent, width, height, text, paletteKey)
    return Theme:CreateButton(parent, width, height, text, paletteKey)
end

local function SetObservedFrameLevel(frame, referenceFrame, offset)
    if not frame or not referenceFrame or type(frame.SetFrameLevel) ~= "function" or type(referenceFrame.GetFrameLevel) ~= "function" then
        return
    end

    frame:SetFrameLevel((referenceFrame:GetFrameLevel() or 0) + (offset or 1))
end

local function SetObservedControlShown(control, isShown)
    if not control then
        return
    end
    if type(control.SetShown) == "function" then
        control:SetShown(isShown == true)
    elseif isShown and type(control.Show) == "function" then
        control:Show()
    elseif not isShown and type(control.Hide) == "function" then
        control:Hide()
    end
end

local function CreateObservedHeaderButton(parent, label, width, justifyH)
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

local function NormalizeCopper(value)
    local normalized = tonumber(value)
    if normalized and normalized > 0 then
        return math.floor(normalized + 0.5)
    end
    return 0
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

local function GetObservedValueSource(addon)
    local sourceID = addon.db and addon.db.observedWorldDropsValueSource
    return addon.VALUE_SOURCE_BY_ID[sourceID] or addon:GetAuctionableInventoryValueSource()
end

local function GetATTBoEDropsData()
    local data = NS.ATTBoEDropsData
    if type(data) ~= "table" then
        return { zones = {}, world = { items = {} }, expansions = { options = {} } }
    end
    return data
end

local function NormalizeDropSourceID(sourceID)
    for _, option in ipairs(DROP_SOURCE_OPTIONS) do
        if option.id == sourceID then
            return sourceID
        end
    end
    return DROP_SOURCE_OBSERVED_ID
end

local function GetDropSourceLabel(sourceID)
    local normalizedSourceID = NormalizeDropSourceID(sourceID)
    for _, option in ipairs(DROP_SOURCE_OPTIONS) do
        if option.id == normalizedSourceID then
            return option.label
        end
    end
    return "Observed"
end

local function IsObservedDropsScanStateActive(state)
    return type(state) == "table" and state.isScanning == true
end

local function GetMapName(mapID)
    local normalizedMapID = tonumber(mapID)
    if normalizedMapID and C_Map and type(C_Map.GetMapInfo) == "function" then
        local ok, info = pcall(C_Map.GetMapInfo, normalizedMapID)
        if ok and type(info) == "table" and type(info.name) == "string" and info.name ~= "" then
            return info.name
        end
    end
    return "Zone " .. tostring(mapID or "?")
end

local function GetATTExpansionLabel(expansionID)
    local normalizedExpansionID = tonumber(expansionID)
    if normalizedExpansionID then
        for _, expansion in ipairs(GetATTBoEDropsData().expansions and GetATTBoEDropsData().expansions.options or {}) do
            if tonumber(expansion.id) == normalizedExpansionID then
                return expansion.label or ("Expansion " .. tostring(normalizedExpansionID))
            end
        end
    end
    return "Unknown"
end

local function GetATTExpansionIDByLabel(label)
    if type(label) ~= "string" or label == "" then
        return nil
    end
    local normalizedLabel = string.lower(label)
    for _, expansion in ipairs(GetATTBoEDropsData().expansions and GetATTBoEDropsData().expansions.options or {}) do
        if type(expansion.label) == "string" and string.lower(expansion.label) == normalizedLabel then
            return tostring(expansion.id)
        end
    end
    return nil
end

local function GetObservedSavedSessionDrops(addon)
    if type(addon.NormalizeObservedSavedSessionDrops) == "function" then
        return addon:NormalizeObservedSavedSessionDrops()
    end
    if type(addon.db) == "table" and type(addon.db.observedSavedSessionDrops) == "table" then
        return addon.db.observedSavedSessionDrops
    end
    return {}
end

local function HasObservedSavedSessionScan(addon)
    return type(addon.db) == "table" and addon.db.observedSavedSessionDropsScannedAt ~= nil
end

local function GetATTExpansionIDFromBlizzardExpansion(expansionID, expansionName)
    local labelExpansionID = GetATTExpansionIDByLabel(expansionName)
    if labelExpansionID then
        return labelExpansionID
    end

    local normalizedExpansionID = tonumber(expansionID)
    if normalizedExpansionID == nil then
        return nil
    end
    normalizedExpansionID = math.floor(normalizedExpansionID + 0.5)

    return ATT_EXPANSION_BY_BLIZZARD_EXPANSION_ID[normalizedExpansionID]
end

local function GetKnownItemExpansionID(item)
    local labelExpansionID = GetATTExpansionIDByLabel(item and item.expansion)
    if labelExpansionID then
        return labelExpansionID
    end

    local explicitExpansionID = tonumber(item and item.expansionID)
    if explicitExpansionID and explicitExpansionID > 0 then
        return tostring(math.floor(explicitExpansionID + 0.5))
    end

    local itemID = tonumber(item and item.itemID)
    if not itemID then
        return nil
    end
    itemID = math.floor(itemID + 0.5)

    if itemID >= 235000 then
        return "12"
    elseif itemID >= 210000 then
        return "11"
    elseif itemID >= 190000 then
        return "10"
    elseif itemID >= 173000 then
        return "9"
    elseif itemID >= 155000 then
        return "8"
    elseif itemID >= 120000 then
        return "7"
    elseif itemID >= 100000 then
        return "6"
    elseif itemID >= 80000 then
        return "5"
    elseif itemID >= 55000 then
        return "4"
    elseif itemID >= 40000 then
        return "3"
    elseif itemID >= 20000 then
        return "2"
    end
    return "1"
end

local function GetKnownZoneExpansionID(zone)
    local labelExpansionID = GetATTExpansionIDByLabel(zone and zone.expansion)
    if labelExpansionID then
        return labelExpansionID
    end

    local mapID = tonumber(zone and zone.mapID)
    if mapID and ATT_EXPANSION_BY_MAP_ID[math.floor(mapID + 0.5)] then
        return ATT_EXPANSION_BY_MAP_ID[math.floor(mapID + 0.5)]
    end

    local explicitExpansionID = tonumber(zone and zone.expansionID)
    if explicitExpansionID and explicitExpansionID > 0 then
        return tostring(math.floor(explicitExpansionID + 0.5))
    end

    local counts = {}
    local bestExpansionID
    local bestCount = 0
    for _, item in ipairs(zone and zone.items or {}) do
        local itemExpansionID = GetKnownItemExpansionID(item)
        if itemExpansionID then
            counts[itemExpansionID] = (counts[itemExpansionID] or 0) + 1
            if counts[itemExpansionID] > bestCount then
                bestExpansionID = itemExpansionID
                bestCount = counts[itemExpansionID]
            end
        end
    end
    return bestExpansionID
end

local function BuildKnownZoneOptions(expansionFilterID)
    local normalizedExpansionFilterID = type(expansionFilterID) == "string" and expansionFilterID or EXPANSION_ALL_ID
    local options = {
        { id = ZONE_ALL_ID, label = "All zones" },
    }
    for mapID, zone in pairs(GetATTBoEDropsData().zones or {}) do
        local normalizedMapID = tonumber(zone and zone.mapID or mapID)
        local zoneExpansionID = GetKnownZoneExpansionID(zone)
        if normalizedMapID
            and (
                normalizedExpansionFilterID == EXPANSION_ALL_ID
                or zoneExpansionID == normalizedExpansionFilterID
            )
        then
            options[#options + 1] = {
                id = tostring(normalizedMapID),
                mapID = normalizedMapID,
                label = GetMapName(normalizedMapID),
            }
        end
    end
    table.sort(options, function(left, right)
        if left.id == ZONE_ALL_ID then
            return true
        end
        if right.id == ZONE_ALL_ID then
            return false
        end
        return string.lower(tostring(left.label or "")) < string.lower(tostring(right.label or ""))
    end)
    return options
end

local function NormalizeKnownZoneFilter(zoneID, expansionFilterID)
    if zoneID == ZONE_ALL_ID then
        return ZONE_ALL_ID
    end
    local normalizedMapID = tonumber(zoneID)
    if normalizedMapID and GetATTBoEDropsData().zones[normalizedMapID] then
        local normalizedExpansionFilterID = type(expansionFilterID) == "string" and expansionFilterID or EXPANSION_ALL_ID
        local zoneExpansionID = GetKnownZoneExpansionID(GetATTBoEDropsData().zones[normalizedMapID])
        if normalizedExpansionFilterID ~= EXPANSION_ALL_ID and zoneExpansionID ~= normalizedExpansionFilterID then
            return ZONE_ALL_ID
        end
        return tostring(math.floor(normalizedMapID + 0.5))
    end
    return ZONE_ALL_ID
end

local function GetKnownZoneFilterLabel(zoneID)
    local normalizedZoneID = NormalizeKnownZoneFilter(zoneID)
    if normalizedZoneID == ZONE_ALL_ID then
        return "All zones"
    end
    return GetMapName(normalizedZoneID)
end

local function NormalizeExpansionFilter(addon, expansionID)
    if type(expansionID) ~= "string" or expansionID == "" then
        return EXPANSION_ALL_ID
    end
    if expansionID == EXPANSION_ALL_ID then
        return EXPANSION_ALL_ID
    end

    local observedDrops = GetObservedSavedSessionDrops(addon)
    for _, drop in pairs(observedDrops) do
        if type(drop) == "table" and tostring(drop.lastExpansionID or drop.lastExpansionName or "") == expansionID then
            return expansionID
        end
    end
    local expansionNumber = tonumber(expansionID)
    if expansionNumber then
        for _, expansion in ipairs(GetATTBoEDropsData().expansions and GetATTBoEDropsData().expansions.options or {}) do
            if tonumber(expansion.id) == expansionNumber then
                return tostring(math.floor(expansionNumber + 0.5))
            end
        end
        if expansionNumber >= 1 and expansionNumber <= 12 then
            return tostring(math.floor(expansionNumber + 0.5))
        end
    end

    return EXPANSION_ALL_ID
end

local function GetDropExpansionID(drop)
    if type(drop) ~= "table" then
        return "unknown"
    end
    local expansionID = GetATTExpansionIDFromBlizzardExpansion(drop.lastExpansionID, drop.lastExpansionName)
    if expansionID then
        return expansionID
    end
    if type(drop.lastExpansionName) == "string" and drop.lastExpansionName ~= "" then
        return drop.lastExpansionName
    end
    return "unknown"
end

local function GetDropExpansionLabel(drop)
    if type(drop) ~= "table" then
        return "Unknown"
    end
    if type(drop.lastExpansionName) == "string" and drop.lastExpansionName ~= "" then
        return drop.lastExpansionName
    end
    local expansionID = drop.lastExpansionID
    if expansionID ~= nil then
        return GetATTExpansionLabel(GetDropExpansionID(drop))
    end
    return "Unknown"
end

local function BuildExpansionOptions(addon)
    local options = {
        { id = EXPANSION_ALL_ID, label = "All expansions" },
    }
    local seen = {
        [EXPANSION_ALL_ID] = true,
    }
    local observedDrops = GetObservedSavedSessionDrops(addon)
    for _, drop in pairs(observedDrops) do
        if type(drop) == "table" then
            local expansionID = GetDropExpansionID(drop)
            if not seen[expansionID] then
                seen[expansionID] = true
                options[#options + 1] = {
                    id = expansionID,
                    label = GetDropExpansionLabel(drop),
                }
            end
        end
    end
    for _, expansion in ipairs(GetATTBoEDropsData().expansions and GetATTBoEDropsData().expansions.options or {}) do
        local expansionID = tostring(expansion.id or "")
        if expansionID ~= "" and not seen[expansionID] then
            seen[expansionID] = true
            options[#options + 1] = {
                id = expansionID,
                label = expansion.label or ("Expansion " .. expansionID),
            }
        end
    end

    table.sort(options, function(left, right)
        if left.id == EXPANSION_ALL_ID then
            return true
        end
        if right.id == EXPANSION_ALL_ID then
            return false
        end
        return string.lower(tostring(left.label or "")) < string.lower(tostring(right.label or ""))
    end)
    return options
end

local function GetExpansionFilterLabel(addon, expansionID)
    local normalizedExpansionID = NormalizeExpansionFilter(addon, expansionID)
    for _, option in ipairs(BuildExpansionOptions(addon)) do
        if option.id == normalizedExpansionID then
            return option.label
        end
    end
    return "All expansions"
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

local function RequestObservedItemData(addon, itemID)
    if Item and type(Item.CreateFromItemID) == "function" then
        local item = Item:CreateFromItemID(itemID)
        if item and type(item.ContinueOnItemLoad) == "function" then
            item:ContinueOnItemLoad(function()
                if addon.observedDropsFrame and addon.observedDropsFrame:IsShown() then
                    addon.observedDropsFrame.itemCache = {}
                    addon:RefreshObservedDropsWindow(false)
                end
            end)
            return
        end
    end

    if C_Item and type(C_Item.RequestLoadItemDataByID) == "function" then
        pcall(C_Item.RequestLoadItemDataByID, itemID)
    end
end

local function GetObservedDropItemDisplay(addon, drop)
    local itemID = tonumber(drop and drop.itemID)
    local itemLink = type(drop and drop.itemLink) == "string" and drop.itemLink ~= "" and drop.itemLink or nil
    local cacheKey = itemLink or (itemID and ("item:" .. tostring(math.floor(itemID + 0.5)))) or nil
    if not cacheKey then
        return nil, nil, nil, nil
    end

    local cache = addon.observedDropsFrame and addon.observedDropsFrame.itemCache
    if type(cache) == "table" and type(cache[cacheKey]) == "table" then
        local cached = cache[cacheKey]
        return cached.itemName, cached.itemLink, cached.itemQuality, cached.icon
    end

    local itemName, resolvedItemLink, itemQuality, itemIcon
    if itemID then
        itemName, resolvedItemLink, itemQuality, _, _, _, _, _, _, itemIcon = GetItemInfoByID(itemID)
        if not itemIcon then
            itemIcon = select(5, GetItemInstantInfoByID(itemID))
        end
    end

    resolvedItemLink = resolvedItemLink or itemLink
    if not itemName and itemLink then
        itemName = string.match(itemLink, "%[([^%]]+)%]")
    end
    if not itemName and itemID then
        itemName = "Item " .. tostring(math.floor(itemID + 0.5))
        if not drop.staticKnownDrop then
            RequestObservedItemData(addon, itemID)
        end
    end

    if type(cache) == "table" then
        cache[cacheKey] = {
            itemName = itemName,
            itemLink = resolvedItemLink,
            itemQuality = itemQuality or drop.itemQuality,
            icon = itemIcon,
        }
    end

    return itemName, resolvedItemLink, itemQuality or drop.itemQuality, itemIcon
end

local function GetRawTSMValue(addon, itemLink, itemID, tsmKey)
    if type(itemLink) == "string" and itemLink ~= "" and type(addon.GetTSMRawCustomValue) == "function" then
        local value = addon:GetTSMRawCustomValue(tsmKey, itemLink)
        if value then
            return NormalizeCopper(value)
        end
    end

    local normalizedItemID = tonumber(itemID)
    if not normalizedItemID or type(TSM_API) ~= "table" or type(TSM_API.GetCustomPriceValue) ~= "function" then
        return 0
    end

    local ok, value = pcall(TSM_API.GetCustomPriceValue, tsmKey, string.format("i:%d", math.floor(normalizedItemID + 0.5)))
    if ok then
        return NormalizeCopper(value)
    end
    return 0
end

local function GetObservedRowPriceSnapshot(addon, drop, itemLink)
    local source = GetObservedValueSource(addon)
    local sourceID = source and source.id
    local sourceLabel = source and source.label or "Unknown"
    local cache = addon.observedDropsFrame and addon.observedDropsFrame.priceCache
    local cacheKey = tostring(drop and (drop.itemKey or drop.itemID or itemLink) or itemLink or "") .. "|" .. tostring(sourceID or "")
    if type(cache) == "table" and type(cache[cacheKey]) == "table" then
        return cache[cacheKey]
    end

    local itemID = tonumber(drop and drop.itemID)
    local selectedValue = 0
    if itemLink and sourceID and type(addon.GetItemUnitValueFromSource) == "function" then
        selectedValue = NormalizeCopper(addon:GetItemUnitValueFromSource(sourceID, itemLink))
    end
    if selectedValue <= 0 and source and source.tsmKey then
        selectedValue = GetRawTSMValue(addon, itemLink, itemID, source.tsmKey)
    end
    if selectedValue <= 0 and sourceID == drop.valueSourceID then
        selectedValue = NormalizeCopper(drop.value)
    end

    local snapshot = {
        selectedValue = selectedValue,
        valueSourceID = sourceID,
        valueSourceLabel = sourceLabel,
        marketValue = GetRawTSMValue(addon, itemLink, itemID, "DBMarket"),
        historicalValue = GetRawTSMValue(addon, itemLink, itemID, "DBHistorical"),
        regionMarketValue = GetRawTSMValue(addon, itemLink, itemID, "DBRegionMarketAvg"),
        averageValue = GetRawTSMValue(addon, itemLink, itemID, "DBRegionSaleAvg"),
    }
    if type(cache) == "table" then
        cache[cacheKey] = snapshot
    end
    return snapshot
end

local function NormalizeSortKey(sortKey)
    if SORT_KEYS[sortKey] then
        return sortKey
    end
    return DEFAULT_SORT_KEY
end

local function GetSortValue(row, sortKey)
    if sortKey == "tracked" then
        return row.tracked and 1 or 0
    end
    if sortKey == "expansion" then
        return string.lower(tostring(row.expansionLabel or ""))
    end
    if sortKey == "location" then
        return string.lower(tostring(row.locationLabel or ""))
    end
    if sortKey == "source" then
        return string.lower(tostring(row.sourceText or ""))
    end
    if sortKey == "itemName" then
        return string.lower(tostring(row.itemName or row.itemLink or row.itemID or ""))
    end
    if sortKey == "seenCount" then
        return tonumber(row.seenCount) or 0
    end
    if sortKey == "quantity" then
        return tonumber(row.quantity) or 0
    end
    if sortKey == "marketValue" then
        return tonumber(row.marketValue) or 0
    end
    if sortKey == "regionMarketValue" then
        return tonumber(row.regionMarketValue) or 0
    end
    if sortKey == "averageValue" then
        return tonumber(row.averageValue) or 0
    end
    return tonumber(row.value) or 0
end

local function SortRows(rows, sortKey, sortAscending)
    local normalizedSortKey = NormalizeSortKey(sortKey)
    local ascending = sortAscending == true
    table.sort(rows, function(left, right)
        local leftValue = GetSortValue(left, normalizedSortKey)
        local rightValue = GetSortValue(right, normalizedSortKey)
        if leftValue == rightValue then
            return string.lower(tostring(left.itemName or "")) < string.lower(tostring(right.itemName or ""))
        end
        if ascending then
            return leftValue < rightValue
        end
        return leftValue > rightValue
    end)
end

local function SetHeaderColumn(button, listPanel, leftOffset, width)
    if not button or not listPanel then
        return
    end
    button:ClearAllPoints()
    button:SetPoint("TOPLEFT", listPanel, "TOPLEFT", leftOffset, -12)
    button:SetWidth(math.max(1, width))
end

local function SetRowColumn(fontString, row, leftOffset, width)
    if not fontString or not row then
        return
    end
    fontString:ClearAllPoints()
    fontString:SetPoint("LEFT", row, "LEFT", leftOffset, 0)
    fontString:SetWidth(math.max(1, width))
end

local function GetObservedTableViewportWidth(frame)
    local width = 0
    if frame and frame.scrollFrame then
        width = tonumber(frame.scrollFrame:GetWidth()) or 0
    end
    if width <= 1 and frame and frame.listPanel then
        width = (tonumber(frame.listPanel:GetWidth()) or 0) - 38
    end
    return math.max(1, math.floor(width - 6))
end

local function GetObservedHorizontalOffset(frame)
    return math.max(0, math.floor(tonumber(frame and frame.horizontalScrollOffset) or 0))
end

local function UpdateObservedHorizontalScroll(frame)
    if not frame then
        return
    end

    local maxOffset = math.max(0, math.floor((tonumber(frame.tableWidth) or 0) - GetObservedTableViewportWidth(frame)))
    local offset = math.min(GetObservedHorizontalOffset(frame), maxOffset)
    frame.horizontalScrollOffset = offset

    if frame.horizontalScrollBar then
        frame.horizontalScrollBar:SetMinMaxValues(0, maxOffset)
        frame.horizontalScrollBar:SetValueStep(20)
        if frame.horizontalScrollBar.SetObeyStepOnDrag then
            frame.horizontalScrollBar:SetObeyStepOnDrag(false)
        end
        frame.horizontalScrollBar:SetShown(maxOffset > 0)
        frame.horizontalScrollBar.updating = true
        frame.horizontalScrollBar:SetValue(offset)
        frame.horizontalScrollBar.updating = false
    end
end

local function ApplyObservedTableColumnLayout(frame)
    if not frame or not frame.listPanel then
        return
    end

    local availableWidth = GetObservedTableViewportWidth(frame)
    local fixedWidth =
        TRACKED_WIDTH
        + EXPANSION_WIDTH
        + LOCATION_WIDTH
        + SOURCE_WIDTH
        + SEEN_WIDTH
        + QUANTITY_WIDTH
        + (VALUE_WIDTH * 4)
        + DETAILS_WIDTH
        + (COLUMN_GAP * 10)
    local tableWidth = math.max(availableWidth, fixedWidth + ITEM_MIN_WIDTH + ROW_RIGHT_PADDING)
    local itemWidth = math.max(ITEM_MIN_WIDTH, tableWidth - fixedWidth)
    frame.tableWidth = tableWidth
    if frame.content then
        frame.content:SetWidth(tableWidth)
    end
    UpdateObservedHorizontalScroll(frame)

    local horizontalOffset = GetObservedHorizontalOffset(frame)
    local trackedX = HEADER_LEFT_INSET
    local expansionX = trackedX + TRACKED_WIDTH + COLUMN_GAP
    local locationX = expansionX + EXPANSION_WIDTH + COLUMN_GAP
    local sourceX = locationX + LOCATION_WIDTH + COLUMN_GAP
    local itemX = sourceX + SOURCE_WIDTH + COLUMN_GAP
    local seenX = itemX + itemWidth + COLUMN_GAP
    local quantityX = seenX + SEEN_WIDTH + COLUMN_GAP
    local valueX = quantityX + QUANTITY_WIDTH + COLUMN_GAP
    local marketX = valueX + VALUE_WIDTH + COLUMN_GAP
    local regionX = marketX + VALUE_WIDTH + COLUMN_GAP
    local averageX = regionX + VALUE_WIDTH + COLUMN_GAP
    local detailsX = averageX + VALUE_WIDTH + COLUMN_GAP

    SetHeaderColumn(frame.trackedHeaderButton, frame.listPanel, trackedX - horizontalOffset, TRACKED_WIDTH)
    SetHeaderColumn(frame.expansionHeaderButton, frame.listPanel, expansionX - horizontalOffset, EXPANSION_WIDTH)
    SetHeaderColumn(frame.locationHeaderButton, frame.listPanel, locationX - horizontalOffset, LOCATION_WIDTH)
    SetHeaderColumn(frame.sourceHeaderButton, frame.listPanel, sourceX - horizontalOffset, SOURCE_WIDTH)
    SetHeaderColumn(frame.itemHeaderButton, frame.listPanel, itemX - horizontalOffset, itemWidth)
    SetHeaderColumn(frame.seenHeaderButton, frame.listPanel, seenX - horizontalOffset, SEEN_WIDTH)
    SetHeaderColumn(frame.quantityHeaderButton, frame.listPanel, quantityX - horizontalOffset, QUANTITY_WIDTH)
    SetHeaderColumn(frame.valueHeaderButton, frame.listPanel, valueX - horizontalOffset, VALUE_WIDTH)
    SetHeaderColumn(frame.marketHeaderButton, frame.listPanel, marketX - horizontalOffset, VALUE_WIDTH)
    SetHeaderColumn(frame.regionHeaderButton, frame.listPanel, regionX - horizontalOffset, VALUE_WIDTH)
    SetHeaderColumn(frame.averageHeaderButton, frame.listPanel, averageX - horizontalOffset, VALUE_WIDTH)
    SetHeaderColumn(frame.detailsHeaderButton, frame.listPanel, detailsX - horizontalOffset, DETAILS_WIDTH)

    for _, row in ipairs(frame.rows or {}) do
        if row.trackedButton then
            row.trackedButton:ClearAllPoints()
            row.trackedButton:SetPoint("LEFT", row, "LEFT", trackedX + 8 - horizontalOffset, 0)
        end
        if row.icon then
            row.icon:ClearAllPoints()
            row.icon:SetPoint("LEFT", row, "LEFT", itemX - horizontalOffset, 0)
        end
        SetRowColumn(row.expansionText, row, expansionX - horizontalOffset, EXPANSION_WIDTH)
        SetRowColumn(row.locationText, row, locationX - horizontalOffset, LOCATION_WIDTH)
        SetRowColumn(row.sourceText, row, sourceX - horizontalOffset, SOURCE_WIDTH)
        SetRowColumn(row.itemText, row, itemX + ICON_SIZE + 7 - horizontalOffset, math.max(1, itemWidth - ICON_SIZE - 7))
        SetRowColumn(row.seenText, row, seenX - horizontalOffset, SEEN_WIDTH)
        SetRowColumn(row.quantityText, row, quantityX - horizontalOffset, QUANTITY_WIDTH)
        SetRowColumn(row.valueText, row, valueX - horizontalOffset, VALUE_WIDTH)
        SetRowColumn(row.marketText, row, marketX - horizontalOffset, VALUE_WIDTH)
        SetRowColumn(row.regionText, row, regionX - horizontalOffset, VALUE_WIDTH)
        SetRowColumn(row.averageText, row, averageX - horizontalOffset, VALUE_WIDTH)
        if row.detailsButton then
            row.detailsButton:ClearAllPoints()
            row.detailsButton:SetPoint("LEFT", row, "LEFT", detailsX - horizontalOffset, 0)
        end
    end
end

local function ScrollObservedResultsVertically(scrollFrame, delta)
    if not scrollFrame then
        return
    end

    local step = math.max(18, math.floor(scrollFrame:GetHeight() * 0.12))
    local nextScroll = (tonumber(scrollFrame:GetVerticalScroll()) or 0) - ((tonumber(delta) or 0) * step)
    local maxScroll = tonumber(scrollFrame:GetVerticalScrollRange()) or 0
    if nextScroll < 0 then
        nextScroll = 0
    elseif nextScroll > maxScroll then
        nextScroll = maxScroll
    end
    scrollFrame:SetVerticalScroll(nextScroll)
end

local function ScrollObservedResultsHorizontally(frame, delta)
    if not frame or not (type(IsShiftKeyDown) == "function" and IsShiftKeyDown()) then
        return false
    end

    local maxOffset = math.max(0, math.floor((tonumber(frame.tableWidth) or 0) - GetObservedTableViewportWidth(frame)))
    if maxOffset <= 0 then
        return false
    end

    local currentOffset = math.min(GetObservedHorizontalOffset(frame), maxOffset)
    local step = math.max(20, math.floor(GetObservedTableViewportWidth(frame) * 0.10))
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
            ApplyObservedTableColumnLayout(frame)
        end
    end
    return true
end

local function HandleObservedResultsMouseWheel(frame, delta)
    if ScrollObservedResultsHorizontally(frame, delta) then
        return
    end
    ScrollObservedResultsVertically(frame and frame.scrollFrame, delta)
end

local function BindObservedResultsMouseWheel(frameObject, frame)
    if not frameObject or not frameObject.EnableMouseWheel then
        return
    end
    frameObject:EnableMouseWheel(true)
    frameObject:SetScript("OnMouseWheel", function(_, delta)
        HandleObservedResultsMouseWheel(frame, delta)
    end)
end

local function AddKnownDropRow(addon, rows, item, source)
    local itemID = tonumber(item and item.itemID)
    if not itemID then
        return
    end
    itemID = math.floor(itemID + 0.5)

    local drop = {
        itemID = itemID,
        itemKey = (source.keyPrefix or "att") .. ":" .. tostring(source.keyID or "all") .. ":" .. tostring(itemID),
        itemQuality = 2,
        staticKnownDrop = true,
        valueSourceID = source.valueSourceID,
    }
    local itemName, itemLink, itemQuality, icon = GetObservedDropItemDisplay(addon, drop)
    local prices = GetObservedRowPriceSnapshot(addon, drop, itemLink)
    local selectedValue = prices.selectedValue
    local minimumValue = tonumber(source.minimumValue) or 0
    if minimumValue > 0 and selectedValue < minimumValue then
        return
    end

    rows[#rows + 1] = {
        observedDropKey = drop.itemKey,
        itemID = itemID,
        itemLink = itemLink,
        itemName = itemName,
        itemQuality = itemQuality or 2,
        iconTexture = icon,
        icon = icon,
        expansionID = tostring(source.expansionID or "unknown"),
        expansionLabel = source.expansionLabel or "Unknown",
        locationLabel = source.locationLabel or "Unknown",
        sourceText = source.sourceText or "ATT",
        seenCount = 0,
        quantity = 0,
        value = prices.selectedValue,
        unitValue = prices.selectedValue,
        totalValue = prices.selectedValue,
        valueSourceID = prices.valueSourceID,
        valueSourceLabel = prices.valueSourceLabel,
        marketValue = prices.marketValue,
        historicalValue = prices.historicalValue,
        regionMarketValue = prices.regionMarketValue,
        averageValue = prices.averageValue,
        farmingSourceType = source.farmingSourceType,
        bossName = source.sourceText,
        instanceName = source.locationLabel,
    }
end

local function AddKnownExpansionWorldRowsForSelectedZone(addon, rows, expansionID, mapID, minimumValue, seenItemIDs)
    if not expansionID or not mapID then
        return
    end

    local source = {
        keyPrefix = "att-zone-world",
        keyID = mapID,
        expansionID = expansionID,
        expansionLabel = GetATTExpansionLabel(expansionID),
        locationLabel = GetMapName(mapID),
        sourceText = "Expansion World Drop",
        farmingSourceType = "att-zone-world",
        minimumValue = minimumValue,
    }
    for _, item in ipairs(GetATTBoEDropsData().world and GetATTBoEDropsData().world.items or {}) do
        local itemID = tonumber(item and item.itemID)
        local normalizedItemID = itemID and math.floor(itemID + 0.5) or nil
        if normalizedItemID
            and GetKnownItemExpansionID(item) == expansionID
            and not (type(seenItemIDs) == "table" and seenItemIDs[normalizedItemID])
        then
            AddKnownDropRow(addon, rows, item, source)
        end
    end
end

local function AddKnownZoneRows(addon, rows, expansionFilterID, zoneFilterID, minimumValue)
    local normalizedZoneID = NormalizeKnownZoneFilter(zoneFilterID, expansionFilterID)
    for mapID, zone in pairs(GetATTBoEDropsData().zones or {}) do
        local normalizedMapID = tonumber(zone and zone.mapID or mapID)
        local expansionID = GetKnownZoneExpansionID(zone) or tostring(zone and zone.expansionID or "unknown")
        if normalizedMapID
            and (normalizedZoneID == ZONE_ALL_ID or tostring(normalizedMapID) == normalizedZoneID)
            and (expansionFilterID == EXPANSION_ALL_ID or expansionFilterID == expansionID)
        then
            local source = {
                keyPrefix = "att-zone",
                keyID = normalizedMapID,
                expansionID = expansionID,
                expansionLabel = GetATTExpansionLabel(expansionID),
                locationLabel = GetMapName(normalizedMapID),
                sourceText = "Zone Drop",
                farmingSourceType = "att-zone",
                minimumValue = minimumValue,
            }
            local seenItemIDs = {}
            for _, item in ipairs(zone.items or {}) do
                local itemID = tonumber(item and item.itemID)
                if itemID then
                    seenItemIDs[math.floor(itemID + 0.5)] = true
                end
                AddKnownDropRow(addon, rows, item, source)
            end
            if normalizedZoneID ~= ZONE_ALL_ID then
                AddKnownExpansionWorldRowsForSelectedZone(addon, rows, expansionID, normalizedMapID, minimumValue, seenItemIDs)
            end
        end
    end
end

local function AddKnownWorldRows(addon, rows, expansionFilterID, minimumValue)
    for _, item in ipairs(GetATTBoEDropsData().world and GetATTBoEDropsData().world.items or {}) do
        local expansionID = GetKnownItemExpansionID(item) or "unknown"
        if expansionFilterID ~= EXPANSION_ALL_ID and expansionID ~= expansionFilterID then
            -- Continue scanning; this source is intentionally filtered from the selected expansion.
        else
            local source = {
                keyPrefix = "att-world",
                keyID = expansionID,
                expansionID = expansionID,
                expansionLabel = GetATTExpansionLabel(expansionID),
                locationLabel = "World drops",
                sourceText = "World Drop",
                farmingSourceType = "att-world",
                minimumValue = minimumValue,
            }
            AddKnownDropRow(addon, rows, item, source)
        end
    end
end

local function AddObservedCapturedDropRow(addon, rows, key, drop, expansionFilterID, minimumValue)
    if type(drop) ~= "table" then
        return
    end

    local expansionID = GetDropExpansionID(drop)
    if expansionFilterID ~= EXPANSION_ALL_ID and expansionFilterID ~= expansionID then
        return
    end

    local itemName, itemLink, itemQuality, icon = GetObservedDropItemDisplay(addon, drop)
    local prices = GetObservedRowPriceSnapshot(addon, drop, itemLink)
    local selectedValue = prices.selectedValue
    if minimumValue > 0 and selectedValue < minimumValue then
        return
    end

    local itemID = tonumber(drop.itemID)
    rows[#rows + 1] = {
        observedDropKey = key,
        itemID = itemID and math.floor(itemID + 0.5) or nil,
        itemLink = itemLink,
        itemName = itemName,
        itemQuality = itemQuality or drop.itemQuality or 2,
        iconTexture = icon,
        icon = icon,
        expansionID = expansionID,
        expansionLabel = GetDropExpansionLabel(drop),
        locationLabel = drop.lastLocationLabel or drop.lastMapName or "Unknown",
        sourceText = drop.lastSourceText or drop.lastSourceName or drop.lastSourceType or "Unknown",
        seenCount = tonumber(drop.seenCount) or 0,
        quantity = tonumber(drop.totalQuantity) or 0,
        value = prices.selectedValue,
        unitValue = prices.selectedValue,
        totalValue = prices.selectedValue,
        valueSourceID = prices.valueSourceID,
        valueSourceLabel = prices.valueSourceLabel,
        marketValue = prices.marketValue,
        historicalValue = prices.historicalValue,
        regionMarketValue = prices.regionMarketValue,
        averageValue = prices.averageValue,
        farmingSourceType = "observed",
        bossName = drop.lastSourceName or drop.lastSourceText,
        instanceName = drop.lastLocationLabel or drop.lastMapName,
    }
end

function GoldTracker:BuildObservedDropsRows()
    local frame = self.observedDropsFrame
    local observedDrops = GetObservedSavedSessionDrops(self)
    local expansionFilterID = NormalizeExpansionFilter(self, frame and frame.expansionFilterID)
    local dropSourceID = NormalizeDropSourceID(frame and frame.dropSourceID)
    local zoneFilterID = NormalizeKnownZoneFilter(frame and frame.zoneFilterID, expansionFilterID)
    local minimumValue = math.max(0, math.floor(tonumber(frame and frame.minimumValueCopper) or 0))
    local rows = {}

    if dropSourceID == DROP_SOURCE_OBSERVED_ID then
        for key, drop in pairs(observedDrops) do
            AddObservedCapturedDropRow(self, rows, key, drop, expansionFilterID, minimumValue)
        end
    elseif dropSourceID == DROP_SOURCE_ATT_ZONES_ID then
        AddKnownZoneRows(self, rows, expansionFilterID, zoneFilterID, minimumValue)
    elseif dropSourceID == DROP_SOURCE_ATT_WORLD_ID then
        AddKnownWorldRows(self, rows, expansionFilterID, minimumValue)
    end

    for _, row in ipairs(rows) do
        row.tracked = type(self.IsFarmingItemFavorite) == "function" and self:IsFarmingItemFavorite(row)
    end
    SortRows(rows, frame and frame.sortKey, frame and frame.sortAscending)
    return rows
end

local function LoadObservedSavedSessionRows(addon, skipRefresh, statusMessage)
    local frame = addon.observedDropsFrame
    if not frame or NormalizeDropSourceID(frame.dropSourceID) ~= DROP_SOURCE_OBSERVED_ID then
        return false
    end

    frame.scanState = nil
    frame.loadedObservedDropsScanCache = nil
    frame.loadedObservedDropsScanCacheKey = nil
    frame.editingObservedDropsScanCacheKey = nil
    frame.itemCache = frame.itemCache or {}
    frame.priceCache = frame.priceCache or {}

    if HasObservedSavedSessionScan(addon) then
        frame.hasObservedDropsScanRun = true
        frame.scannedObservedDropsRows = addon:BuildObservedDropsRows()
        if frame.progressBar then
            local totalRows = #(frame.scannedObservedDropsRows or {})
            frame.progressBar:SetMinMaxValues(0, math.max(1, totalRows))
            frame.progressBar:SetValue(totalRows)
        end
        if frame.statusText then
            frame.statusText:SetText(statusMessage or string.format(
                "Loaded saved-session observed list for %s: %d matching drops.",
                GetExpansionFilterLabel(addon, frame.expansionFilterID),
                #(frame.scannedObservedDropsRows or {})
            ))
        end
    else
        frame.hasObservedDropsScanRun = false
        frame.scannedObservedDropsRows = nil
        if frame.progressBar then
            frame.progressBar:SetMinMaxValues(0, 1)
            frame.progressBar:SetValue(0)
        end
        if frame.statusText then
            frame.statusText:SetText(statusMessage or "Observed list is empty. Press Scan saved sessions to build it from history.")
        end
    end

    if not skipRefresh and type(addon.RefreshObservedDropsWindow) == "function" then
        addon:RefreshObservedDropsWindow(true)
    end
    return true
end

local function AddKnownZoneScanCandidates(candidates, expansionFilterID, zoneFilterID, minimumValue)
    local normalizedZoneID = NormalizeKnownZoneFilter(zoneFilterID, expansionFilterID)
    for mapID, zone in pairs(GetATTBoEDropsData().zones or {}) do
        local normalizedMapID = tonumber(zone and zone.mapID or mapID)
        local expansionID = GetKnownZoneExpansionID(zone) or tostring(zone and zone.expansionID or "unknown")
        if normalizedMapID
            and (normalizedZoneID == ZONE_ALL_ID or tostring(normalizedMapID) == normalizedZoneID)
            and (expansionFilterID == EXPANSION_ALL_ID or expansionFilterID == expansionID)
        then
            local source = {
                keyPrefix = "att-zone",
                keyID = normalizedMapID,
                expansionID = expansionID,
                expansionLabel = GetATTExpansionLabel(expansionID),
                locationLabel = GetMapName(normalizedMapID),
                sourceText = "Zone Drop",
                farmingSourceType = "att-zone",
                minimumValue = minimumValue,
            }
            local seenItemIDs = {}
            for _, item in ipairs(zone.items or {}) do
                local itemID = tonumber(item and item.itemID)
                if itemID then
                    seenItemIDs[math.floor(itemID + 0.5)] = true
                end
                candidates[#candidates + 1] = {
                    kind = "known",
                    item = item,
                    source = source,
                }
            end
            if normalizedZoneID ~= ZONE_ALL_ID then
                local worldSource = {
                    keyPrefix = "att-zone-world",
                    keyID = normalizedMapID,
                    expansionID = expansionID,
                    expansionLabel = GetATTExpansionLabel(expansionID),
                    locationLabel = GetMapName(normalizedMapID),
                    sourceText = "Expansion World Drop",
                    farmingSourceType = "att-zone-world",
                    minimumValue = minimumValue,
                }
                for _, item in ipairs(GetATTBoEDropsData().world and GetATTBoEDropsData().world.items or {}) do
                    local itemID = tonumber(item and item.itemID)
                    local normalizedItemID = itemID and math.floor(itemID + 0.5) or nil
                    if normalizedItemID
                        and GetKnownItemExpansionID(item) == expansionID
                        and not seenItemIDs[normalizedItemID]
                    then
                        candidates[#candidates + 1] = {
                            kind = "known",
                            item = item,
                            source = worldSource,
                        }
                    end
                end
            end
        end
    end
end

local function AddKnownWorldScanCandidates(candidates, expansionFilterID, minimumValue)
    for _, item in ipairs(GetATTBoEDropsData().world and GetATTBoEDropsData().world.items or {}) do
        local expansionID = GetKnownItemExpansionID(item) or "unknown"
        if expansionFilterID == EXPANSION_ALL_ID or expansionID == expansionFilterID then
            candidates[#candidates + 1] = {
                kind = "known",
                item = item,
                source = {
                    keyPrefix = "att-world",
                    keyID = expansionID,
                    expansionID = expansionID,
                    expansionLabel = GetATTExpansionLabel(expansionID),
                    locationLabel = "World drops",
                    sourceText = "World Drop",
                    farmingSourceType = "att-world",
                    minimumValue = minimumValue,
                },
            }
        end
    end
end

local function BuildObservedDropScanCandidates(addon)
    local frame = addon.observedDropsFrame
    local observedDrops = GetObservedSavedSessionDrops(addon)
    local expansionFilterID = NormalizeExpansionFilter(addon, frame and frame.expansionFilterID)
    local dropSourceID = NormalizeDropSourceID(frame and frame.dropSourceID)
    local zoneFilterID = NormalizeKnownZoneFilter(frame and frame.zoneFilterID, expansionFilterID)
    local minimumValue = math.max(0, math.floor(tonumber(frame and frame.minimumValueCopper) or 0))
    local candidates = {}

    if dropSourceID == DROP_SOURCE_OBSERVED_ID then
        for key, drop in pairs(observedDrops) do
            if type(drop) == "table" then
                candidates[#candidates + 1] = {
                    kind = "observed",
                    key = key,
                    drop = drop,
                }
            end
        end
    elseif dropSourceID == DROP_SOURCE_ATT_ZONES_ID then
        AddKnownZoneScanCandidates(candidates, expansionFilterID, zoneFilterID, minimumValue)
    elseif dropSourceID == DROP_SOURCE_ATT_WORLD_ID then
        AddKnownWorldScanCandidates(candidates, expansionFilterID, minimumValue)
    end

    return candidates, expansionFilterID, dropSourceID, zoneFilterID, minimumValue
end

local function ProcessObservedDropScanCandidate(addon, state, candidate)
    if type(candidate) ~= "table" then
        return
    end

    if candidate.kind == "observed" then
        AddObservedCapturedDropRow(
            addon,
            state.results,
            candidate.key,
            candidate.drop,
            state.expansionFilterID,
            state.minimumValueCopper or 0
        )
    elseif candidate.kind == "known" then
        AddKnownDropRow(addon, state.results, candidate.item, candidate.source)
    end
end

function GoldTracker:UpdateObservedDropsPrices()
    local observedDrops = type(self.NormalizeObservedWorldDrops) == "function" and self:NormalizeObservedWorldDrops() or {}
    for _, drop in pairs(observedDrops) do
        if type(drop) == "table" then
            local _, itemLink = GetObservedDropItemDisplay(self, drop)
            local prices = GetObservedRowPriceSnapshot(self, drop, itemLink)
            drop.value = prices.selectedValue
            drop.valueSourceID = prices.valueSourceID
            drop.valueSourceLabel = prices.valueSourceLabel
            drop.marketValue = prices.marketValue
            drop.historicalValue = prices.historicalValue
            drop.regionMarketValue = prices.regionMarketValue
            drop.averageValue = prices.averageValue
        end
    end
end

function GoldTracker:RefreshCurrentObservedDropsScanPrices()
    local frame = self.observedDropsFrame
    local rows = frame and frame.scannedObservedDropsRows
    if type(rows) ~= "table" then
        return 0
    end

    local updated = 0
    for _, row in ipairs(rows) do
        local itemID = tonumber(row and row.itemID)
        if itemID then
            local drop = {
                itemID = math.floor(itemID + 0.5),
                itemLink = row.itemLink,
                itemKey = row.observedDropKey,
                itemQuality = row.itemQuality,
                value = row.value,
                valueSourceID = row.valueSourceID,
                staticKnownDrop = row.farmingSourceType ~= "observed",
            }
            local itemName, itemLink, itemQuality, icon = GetObservedDropItemDisplay(self, drop)
            local prices = GetObservedRowPriceSnapshot(self, drop, itemLink)
            row.itemName = itemName or row.itemName
            row.itemLink = itemLink or row.itemLink
            row.itemQuality = itemQuality or row.itemQuality
            row.iconTexture = icon or row.iconTexture
            row.icon = icon or row.icon
            row.value = prices.selectedValue
            row.unitValue = prices.selectedValue
            row.totalValue = prices.selectedValue
            row.valueSourceID = prices.valueSourceID
            row.valueSourceLabel = prices.valueSourceLabel
            row.marketValue = prices.marketValue
            row.historicalValue = prices.historicalValue
            row.regionMarketValue = prices.regionMarketValue
            row.averageValue = prices.averageValue
            updated = updated + 1
        end
    end

    local state = frame and frame.scanState
    if type(state) == "table" then
        state.results = rows
        state.valueSourceID = frame.valueSourceID
        local source = GetObservedValueSource(self)
        state.valueSourceLabel = source and source.label or state.valueSourceLabel
    end
    return updated
end

function GoldTracker:SaveObservedDropsMinimumValueInput(skipRefresh)
    local frame = self.observedDropsFrame
    if not frame or not frame.minimumValueInput then
        return
    end

    frame.minimumValueCopper = ReadMinimumValueCopper(self, frame.minimumValueInput)
    if self.db then
        self.db.observedWorldDropsMinimumValue = frame.minimumValueCopper
    end
    frame.minimumValueInput:SetText(FormatGoldInput(self, frame.minimumValueCopper))
    if frame.dropSourceID == DROP_SOURCE_OBSERVED_ID then
        LoadObservedSavedSessionRows(self, skipRefresh)
        return
    end
    if not skipRefresh then
        self:ClearObservedDropsScanResults()
    end
end

function GoldTracker:ClearObservedDropsScanResults()
    local frame = self.observedDropsFrame
    if not frame then
        return
    end

    if type(self.StopObservedDropsScanWorker) == "function" then
        self:StopObservedDropsScanWorker()
    end
    frame.scanState = nil
    frame.hasObservedDropsScanRun = false
    frame.scannedObservedDropsRows = nil
    frame.loadedObservedDropsScanCache = nil
    frame.loadedObservedDropsScanCacheKey = nil
    frame.editingObservedDropsScanCacheKey = nil
    frame.itemCache = {}
    frame.priceCache = {}
    if frame.dropSourceID == DROP_SOURCE_OBSERVED_ID then
        LoadObservedSavedSessionRows(self, true)
    end
    if type(self.RefreshObservedDropsWindow) == "function" then
        self:RefreshObservedDropsWindow(true)
    end
end

function GoldTracker:UpdateObservedDropsScanProgress()
    local frame = self.observedDropsFrame
    local state = frame and frame.scanState
    if not frame or type(state) ~= "table" then
        return
    end

    local scanned = tonumber(state.scannedDrops) or 0
    local total = math.max(1, tonumber(state.totalDrops) or 1)
    if frame.progressBar then
        frame.progressBar:SetMinMaxValues(0, total)
        frame.progressBar:SetValue(math.min(scanned, total))
    end
    if frame.statusText then
        frame.statusText:SetText(string.format(
            "Scanning %s (%s): %d / %d drops, %d matches",
            state.expansionFilterLabel or "selected expansion",
            state.dropSourceLabel or "Drops",
            math.min(scanned, total),
            total,
            #(state.results or {})
        ))
    end
end

function GoldTracker:GetObservedDropsScanWorker()
    if not self.observedDropsScanWorker then
        self.observedDropsScanWorker = CreateFrame("Frame")
        self.observedDropsScanWorker:Hide()
    end
    return self.observedDropsScanWorker
end

function GoldTracker:StopObservedDropsScanWorker()
    local worker = self.observedDropsScanWorker
    if worker then
        worker:SetScript("OnUpdate", nil)
        worker.scanState = nil
        worker:Hide()
    end
end

function GoldTracker:FinishObservedDropsScan()
    local frame = self.observedDropsFrame
    if not frame then
        return
    end

    self:StopObservedDropsScanWorker()
    local state = frame.scanState
    if type(state) == "table" then
        state.isScanning = false
        frame.scannedObservedDropsRows = state.results or {}
    end
    frame.hasObservedDropsScanRun = true
    if frame.scanButton then
        frame.scanButton:SetEnabled(true)
        frame.scanButton:SetText("Scan")
    end
    if frame.stopScanButton then
        frame.stopScanButton:SetEnabled(false)
        frame.stopScanButton:SetAlpha(0.45)
    end
    if frame.progressBar then
        local _, maximum = frame.progressBar:GetMinMaxValues()
        frame.progressBar:SetValue(maximum or 1)
    end
    if frame.statusText then
        frame.statusText:SetText(string.format(
            "Scan complete for %s (%s): %d matching drops.",
            state and state.expansionFilterLabel or GetExpansionFilterLabel(self, frame.expansionFilterID),
            state and state.dropSourceLabel or GetDropSourceLabel(frame.dropSourceID),
            #(frame.scannedObservedDropsRows or {})
        ))
    end
    if frame:IsShown() then
        self:RefreshObservedDropsWindow(true)
    end
end

function GoldTracker:CancelObservedDropsScan()
    local frame = self.observedDropsFrame
    local state = frame and frame.scanState
    if not frame or not IsObservedDropsScanStateActive(state) then
        return
    end

    state.isScanning = false
    state.cancelled = true
    self:StopObservedDropsScanWorker()
    frame.scannedObservedDropsRows = state.results or {}
    frame.hasObservedDropsScanRun = true
    if frame.statusText then
        frame.statusText:SetText(string.format(
            "Scan stopped: %d / %d drops scanned, %d matches kept.",
            math.min(tonumber(state.scannedDrops) or 0, math.max(1, tonumber(state.totalDrops) or 1)),
            math.max(1, tonumber(state.totalDrops) or 1),
            #(state.results or {})
        ))
    end
    self:RefreshObservedDropsWindow(false)
end

local function ProcessObservedDropsScanFrame(worker, elapsed)
    local addon = GoldTracker
    local state = worker and worker.scanState or nil
    if type(state) ~= "table" then
        if worker then
            worker:SetScript("OnUpdate", nil)
            worker:Hide()
        end
        return
    end
    if state.cancelled or state.isScanning ~= true then
        addon:StopObservedDropsScanWorker()
        return
    end

    local processed = 0
    local batchSize = tonumber(state.scanBatchSize) or OBSERVED_DROPS_BACKGROUND_SCAN_ITEMS_PER_TICK
    while processed < batchSize and state.candidateIndex <= #state.candidates do
        local candidate = state.candidates[state.candidateIndex]
        state.candidateIndex = state.candidateIndex + 1
        state.scannedDrops = (state.scannedDrops or 0) + 1
        processed = processed + 1
        ProcessObservedDropScanCandidate(addon, state, candidate)
    end

    addon:UpdateObservedDropsScanProgress()
    state.refreshElapsed = (state.refreshElapsed or 0) + (elapsed or 0)
    if state.refreshElapsed >= OBSERVED_DROPS_SCAN_REFRESH_INTERVAL then
        state.refreshElapsed = 0
        if addon.observedDropsFrame and addon.observedDropsFrame:IsShown() then
            addon.observedDropsFrame.scannedObservedDropsRows = state.results
            addon:RefreshObservedDropsWindow(false)
        end
    end

    if state.candidateIndex > #state.candidates then
        addon:FinishObservedDropsScan()
    end
end

function GoldTracker:StartObservedDropsScan()
    local frame = self.observedDropsFrame
    if not frame then
        return
    end

    self:SaveObservedDropsMinimumValueInput(true)
    self:StopObservedDropsScanWorker()
    frame.dropSourceID = NormalizeDropSourceID(frame.dropSourceID)
    frame.expansionFilterID = NormalizeExpansionFilter(self, frame.expansionFilterID)
    frame.zoneFilterID = NormalizeKnownZoneFilter(frame.zoneFilterID, frame.expansionFilterID)
    if frame.dropSourceID == DROP_SOURCE_OBSERVED_ID then
        LoadObservedSavedSessionRows(self, false)
        return
    end
    frame.itemCache = {}
    frame.priceCache = {}
    frame.loadedObservedDropsScanCache = nil
    frame.loadedObservedDropsScanCacheKey = nil
    frame.editingObservedDropsScanCacheKey = nil

    local candidates, expansionFilterID, dropSourceID, zoneFilterID, minimumValue = BuildObservedDropScanCandidates(self)
    local totalDrops = #candidates
    if totalDrops <= 0 then
        frame.hasObservedDropsScanRun = false
        frame.scannedObservedDropsRows = nil
        if frame.progressBar then
            frame.progressBar:SetMinMaxValues(0, 1)
            frame.progressBar:SetValue(0)
        end
        if frame.statusText then
            frame.statusText:SetText("No drops are available for the selected filters.")
        end
        self:RefreshObservedDropsWindow(true)
        return
    end

    local source = GetObservedValueSource(self)
    frame.scanState = {
        isScanning = true,
        candidates = candidates,
        candidateIndex = 1,
        totalDrops = totalDrops,
        scannedDrops = 0,
        scanBatchSize = OBSERVED_DROPS_BACKGROUND_SCAN_ITEMS_PER_TICK,
        results = {},
        valueSourceID = source and source.id,
        valueSourceLabel = source and source.label,
        minimumValueCopper = minimumValue,
        expansionFilterID = expansionFilterID,
        expansionFilterLabel = GetExpansionFilterLabel(self, expansionFilterID),
        dropSourceID = dropSourceID,
        dropSourceLabel = GetDropSourceLabel(dropSourceID),
        zoneFilterID = zoneFilterID,
        zoneFilterLabel = GetKnownZoneFilterLabel(zoneFilterID),
    }
    frame.hasObservedDropsScanRun = true
    frame.scannedObservedDropsRows = {}
    if frame.progressBar then
        frame.progressBar:SetMinMaxValues(0, math.max(1, totalDrops))
        frame.progressBar:SetValue(0)
    end
    if frame.scanButton then
        frame.scanButton:SetEnabled(false)
        frame.scanButton:SetText("Scanning")
    end
    if frame.stopScanButton then
        frame.stopScanButton:SetEnabled(true)
        frame.stopScanButton:SetAlpha(1)
    end
    if frame.statusText then
        frame.statusText:SetText(string.format(
            "Scanning %s (%s): 0 / %d drops...",
            frame.scanState.expansionFilterLabel,
            frame.scanState.dropSourceLabel,
            totalDrops
        ))
    end

    self:RefreshObservedDropsWindow(true)
    local worker = self:GetObservedDropsScanWorker()
    worker.scanState = frame.scanState
    worker:Show()
    worker:SetScript("OnUpdate", ProcessObservedDropsScanFrame)
end

function GoldTracker:ScanObservedDropsSelection()
    self:StartObservedDropsScan()
end

local function BuildObservedDropsScanCacheKey(addon, state)
    local sourceID = state and state.valueSourceID or (GetObservedValueSource(addon) or {}).id or ""
    local minimumValue = math.max(0, math.floor((tonumber(state and state.minimumValueCopper) or 0) + 0.5))
    return table.concat({
        tostring(OBSERVED_DROPS_SCAN_CACHE_VERSION),
        tostring(state and state.expansionFilterID or EXPANSION_ALL_ID),
        tostring(state and state.dropSourceID or DROP_SOURCE_OBSERVED_ID),
        tostring(state and state.zoneFilterID or ZONE_ALL_ID),
        tostring(sourceID),
        tostring(minimumValue),
    }, "|")
end

local function CloneObservedDropResultForCache(row)
    local itemID = tonumber(row and row.itemID)
    if not itemID then
        return nil
    end

    return {
        observedDropKey = row.observedDropKey,
        itemID = math.floor(itemID + 0.5),
        itemLink = row.itemLink,
        itemName = row.itemName,
        itemQuality = tonumber(row.itemQuality),
        icon = row.icon or row.iconTexture,
        iconTexture = row.iconTexture or row.icon,
        expansionID = row.expansionID,
        expansionLabel = row.expansionLabel,
        locationLabel = row.locationLabel,
        sourceText = row.sourceText,
        seenCount = tonumber(row.seenCount) or 0,
        quantity = tonumber(row.quantity) or 0,
        value = math.max(0, math.floor((tonumber(row.value) or 0) + 0.5)),
        unitValue = math.max(0, math.floor((tonumber(row.unitValue) or row.value or 0) + 0.5)),
        totalValue = math.max(0, math.floor((tonumber(row.totalValue) or row.value or 0) + 0.5)),
        valueSourceID = row.valueSourceID,
        valueSourceLabel = row.valueSourceLabel,
        marketValue = math.max(0, math.floor((tonumber(row.marketValue) or 0) + 0.5)),
        historicalValue = math.max(0, math.floor((tonumber(row.historicalValue) or 0) + 0.5)),
        regionMarketValue = math.max(0, math.floor((tonumber(row.regionMarketValue) or 0) + 0.5)),
        averageValue = math.max(0, math.floor((tonumber(row.averageValue) or 0) + 0.5)),
        farmingSourceType = row.farmingSourceType,
        bossName = row.bossName,
        instanceName = row.instanceName,
    }
end

local function PruneObservedDropsScanCache(cache)
    if type(cache) ~= "table" then
        return
    end

    local entries = {}
    for key, entry in pairs(cache) do
        entries[#entries + 1] = {
            key = key,
            savedAtTime = tonumber(entry and entry.savedAtTime) or 0,
        }
    end
    if #entries <= OBSERVED_DROPS_SCAN_CACHE_MAX_ENTRIES then
        return
    end

    table.sort(entries, function(left, right)
        return (left.savedAtTime or 0) < (right.savedAtTime or 0)
    end)
    for index = 1, #entries - OBSERVED_DROPS_SCAN_CACHE_MAX_ENTRIES do
        cache[entries[index].key] = nil
    end
end

local function GetObservedDropsSavedScanEntries(addon)
    local cache = type(addon.db) == "table" and addon.db.observedDropsScanCache or nil
    local entries = {}
    if type(cache) ~= "table" then
        return entries
    end
    for key, entry in pairs(cache) do
        if type(entry) == "table" and type(entry.results) == "table" then
            entries[#entries + 1] = {
                key = key,
                entry = entry,
                savedAtTime = tonumber(entry.savedAtTime) or 0,
            }
        end
    end
    table.sort(entries, function(left, right)
        return (left.savedAtTime or 0) > (right.savedAtTime or 0)
    end)
    return entries
end

function GoldTracker:SaveObservedDropsScanCache(state, replaceCacheKey)
    if type(self.db) ~= "table" or type(state) ~= "table" or type(state.results) ~= "table" then
        return nil
    end

    if type(self.db.observedDropsScanCache) ~= "table" then
        self.db.observedDropsScanCache = {}
    end

    local cacheKey = BuildObservedDropsScanCacheKey(self, state)
    if type(replaceCacheKey) == "string" and replaceCacheKey ~= "" and replaceCacheKey ~= cacheKey then
        self.db.observedDropsScanCache[replaceCacheKey] = nil
    end

    local cachedResults = {}
    for _, row in ipairs(state.results) do
        local cachedRow = CloneObservedDropResultForCache(row)
        if cachedRow then
            cachedResults[#cachedResults + 1] = cachedRow
        end
    end

    local savedAtTime = type(time) == "function" and time() or 0
    self.db.observedDropsScanCache[cacheKey] = {
        cacheVersion = OBSERVED_DROPS_SCAN_CACHE_VERSION,
        savedAt = type(date) == "function" and date("%Y-%m-%d %H:%M") or nil,
        savedAtTime = savedAtTime,
        expansionFilterID = state.expansionFilterID,
        expansionFilterLabel = state.expansionFilterLabel,
        dropSourceID = state.dropSourceID,
        dropSourceLabel = state.dropSourceLabel,
        zoneFilterID = state.zoneFilterID,
        zoneFilterLabel = state.zoneFilterLabel,
        valueSourceID = state.valueSourceID,
        valueSourceLabel = state.valueSourceLabel,
        minimumValueCopper = math.max(0, math.floor((tonumber(state.minimumValueCopper) or 0) + 0.5)),
        totalDrops = tonumber(state.totalDrops) or #cachedResults,
        resultCount = #cachedResults,
        results = cachedResults,
    }
    PruneObservedDropsScanCache(self.db.observedDropsScanCache)

    return self.db.observedDropsScanCache[cacheKey], cacheKey
end

function GoldTracker:SaveCurrentObservedDropsScan()
    local frame = self.observedDropsFrame
    if not frame or IsObservedDropsScanStateActive(frame.scanState) then
        return
    end

    local state = type(frame.scanState) == "table" and frame.scanState or {}
    state.results = frame.scannedObservedDropsRows or state.results
    if type(state.results) ~= "table" or #state.results == 0 then
        if frame.statusText then
            frame.statusText:SetText("Nothing to save yet. Run a scan first.")
        end
        return
    end

    local source = GetObservedValueSource(self)
    state.valueSourceID = frame.valueSourceID or state.valueSourceID or (source and source.id)
    state.valueSourceLabel = (source and source.label) or state.valueSourceLabel
    state.minimumValueCopper = tonumber(frame.minimumValueCopper) or state.minimumValueCopper or 0
    state.expansionFilterID = frame.expansionFilterID or state.expansionFilterID or EXPANSION_ALL_ID
    state.expansionFilterLabel = GetExpansionFilterLabel(self, state.expansionFilterID)
    state.dropSourceID = NormalizeDropSourceID(frame.dropSourceID or state.dropSourceID)
    state.dropSourceLabel = GetDropSourceLabel(state.dropSourceID)
    state.zoneFilterID = NormalizeKnownZoneFilter(frame.zoneFilterID or state.zoneFilterID, state.expansionFilterID)
    state.zoneFilterLabel = GetKnownZoneFilterLabel(state.zoneFilterID)
    state.totalDrops = tonumber(state.totalDrops) or #state.results

    local entry, cacheKey = self:SaveObservedDropsScanCache(state, frame.editingObservedDropsScanCacheKey or frame.loadedObservedDropsScanCacheKey)
    if entry then
        frame.loadedObservedDropsScanCache = entry
        frame.loadedObservedDropsScanCacheKey = cacheKey
        frame.editingObservedDropsScanCacheKey = cacheKey
        if frame.statusText then
            frame.statusText:SetText(string.format(
                "Saved scan for %s (%s): %d matching drops.",
                entry.expansionFilterLabel or GetExpansionFilterLabel(self, entry.expansionFilterID),
                entry.dropSourceLabel or GetDropSourceLabel(entry.dropSourceID),
                tonumber(entry.resultCount) or #(entry.results or {})
            ))
        end
        self:RefreshObservedDropsSavedScansWindow()
        self:RefreshObservedDropsWindowControls()
    end
end

function GoldTracker:OpenObservedDropsSavedScan(cacheKey)
    local frame = self.observedDropsFrame
    local cache = type(self.db) == "table" and self.db.observedDropsScanCache or nil
    local entry = type(cache) == "table" and cache[cacheKey] or nil
    if not frame or type(entry) ~= "table" then
        return
    end

    frame.scanState = nil
    frame.loadedObservedDropsScanCache = entry
    frame.loadedObservedDropsScanCacheKey = cacheKey
    frame.editingObservedDropsScanCacheKey = cacheKey
    frame.hasObservedDropsScanRun = true
    frame.valueSourceID = entry.valueSourceID or frame.valueSourceID
    frame.minimumValueCopper = tonumber(entry.minimumValueCopper) or frame.minimumValueCopper or 0
    frame.expansionFilterID = NormalizeExpansionFilter(self, entry.expansionFilterID)
    frame.dropSourceID = NormalizeDropSourceID(entry.dropSourceID)
    frame.zoneFilterID = NormalizeKnownZoneFilter(entry.zoneFilterID, frame.expansionFilterID)
    if type(self.db) == "table" then
        if frame.valueSourceID then
            self.db.observedWorldDropsValueSource = frame.valueSourceID
        end
        self.db.observedWorldDropsMinimumValue = frame.minimumValueCopper
        self.db.observedWorldDropsExpansionFilter = frame.expansionFilterID
        self.db.observedDropsSourceFilter = frame.dropSourceID
        self.db.observedDropsZoneFilter = frame.zoneFilterID
    end

    local loadedResults = {}
    for _, row in ipairs(entry.results or {}) do
        local cachedRow = CloneObservedDropResultForCache(row)
        if cachedRow then
            loadedResults[#loadedResults + 1] = cachedRow
        end
    end
    frame.scannedObservedDropsRows = loadedResults
    if frame.progressBar then
        local totalDrops = math.max(1, tonumber(entry.totalDrops) or #loadedResults or 1)
        frame.progressBar:SetMinMaxValues(0, totalDrops)
        frame.progressBar:SetValue(totalDrops)
    end
    if frame.statusText then
        frame.statusText:SetText(string.format(
            "Loaded saved scan for %s (%s): %d matching drops.",
            entry.expansionFilterLabel or GetExpansionFilterLabel(self, frame.expansionFilterID),
            entry.dropSourceLabel or GetDropSourceLabel(frame.dropSourceID),
            #loadedResults
        ))
    end
    frame.observedDropsNavigationTab = "saved"
    self:SetObservedDropsWindowView("scan")
end

function GoldTracker:DeleteObservedDropsSavedScan(cacheKey)
    if type(cacheKey) ~= "string" or type(self.db) ~= "table" or type(self.db.observedDropsScanCache) ~= "table" then
        return
    end

    self.db.observedDropsScanCache[cacheKey] = nil
    local frame = self.observedDropsFrame
    if frame and (frame.loadedObservedDropsScanCacheKey == cacheKey or frame.editingObservedDropsScanCacheKey == cacheKey) then
        frame.loadedObservedDropsScanCache = nil
        frame.loadedObservedDropsScanCacheKey = nil
        frame.editingObservedDropsScanCacheKey = nil
    end
    self:RefreshObservedDropsSavedScansWindow()
end

function GoldTracker:OpenObservedDropsNewScan()
    local frame = self.observedDropsFrame
    if not frame then
        return
    end

    self:StopObservedDropsScanWorker()
    frame.scanState = nil
    frame.scannedObservedDropsRows = {}
    frame.hasObservedDropsScanRun = false
    frame.loadedObservedDropsScanCache = nil
    frame.loadedObservedDropsScanCacheKey = nil
    frame.editingObservedDropsScanCacheKey = nil
    frame.observedDropsNavigationTab = "new"
    if frame.progressBar then
        frame.progressBar:SetMinMaxValues(0, 1)
        frame.progressBar:SetValue(0)
    end
    if frame.statusText then
        frame.statusText:SetText("Ready.")
    end
    self:SetObservedDropsWindowView("scan")
end

function GoldTracker:ToggleObservedDropFavorite(row)
    if type(row) ~= "table" then
        return
    end

    local key = type(self.GetFarmingFavoriteKey) == "function" and self:GetFarmingFavoriteKey(row)
    local favorites = type(self.GetFarmingFavoriteStore) == "function" and self:GetFarmingFavoriteStore() or nil
    if not key or type(favorites) ~= "table" then
        return
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
            expansionID = row.expansionID,
            expansionName = row.expansionLabel,
            locationLabel = row.locationLabel,
            rareName = row.sourceText,
            value = row.value,
            marketValue = row.marketValue,
            historicalValue = row.historicalValue,
            regionMarketValue = row.regionMarketValue,
            averageValue = row.averageValue,
            valueSourceID = row.valueSourceID,
            valueSourceLabel = row.valueSourceLabel,
            farmingSourceType = row.farmingSourceType or "observed",
        }
    end

    self:RefreshObservedDropsWindow(false)
    if type(self.RefreshRareFarmingLibraryWindow) == "function" then
        self:RefreshRareFarmingLibraryWindow()
    end
    if type(self.RefreshInstanceFarmingLibraryWindow) == "function" then
        self:RefreshInstanceFarmingLibraryWindow()
    end
end

function GoldTracker:RefreshObservedDropsNavigationTabs()
    local frame = self.observedDropsFrame
    if not frame then
        return
    end

    local activeTab = frame.observedDropsNavigationTab
    if frame.observedDropsViewID ~= "scan" then
        activeTab = "saved"
    elseif activeTab ~= "saved" and activeTab ~= "new" then
        activeTab = "new"
    end
    frame.observedDropsNavigationTab = activeTab

    if frame.savedScansTabButton then
        frame.savedScansTabButton:SetPalette(activeTab == "saved" and "primary" or "neutral")
    end
    if frame.newScanTabButton then
        frame.newScanTabButton:SetPalette(activeTab == "new" and "primary" or "neutral")
    end
end

function GoldTracker:SetObservedDropsWindowView(viewID)
    local frame = self.observedDropsFrame
    if not frame then
        return
    end

    local normalizedViewID = viewID == "scan" and "scan" or "library"
    frame.observedDropsViewID = normalizedViewID
    local showScan = normalizedViewID == "scan"
    if showScan then
        frame.observedDropsNavigationTab = frame.observedDropsNavigationTab or "new"
    else
        frame.observedDropsNavigationTab = "saved"
    end

    if frame.libraryPanel then
        frame.libraryPanel:SetShown(not showScan)
    end
    if frame.controlsPanel then
        frame.controlsPanel:SetShown(showScan)
    end
    if frame.listPanel then
        frame.listPanel:SetShown(showScan)
    end
    if frame.metaText then
        frame.metaText:SetShown(showScan)
    end
    self:RefreshObservedDropsNavigationTabs()

    if showScan then
        if NormalizeDropSourceID(frame.dropSourceID) == DROP_SOURCE_OBSERVED_ID then
            LoadObservedSavedSessionRows(self, true)
        end
        self:RefreshObservedDropsWindowControls()
        self:RefreshObservedDropsWindow(true)
    else
        self:RefreshObservedDropsSavedScansWindow()
    end
end

function GoldTracker:RefreshObservedDropsSavedScansWindow()
    local frame = self.observedDropsFrame
    if not frame or not frame.libraryPanel then
        return
    end

    if frame.observedDropsViewID ~= "scan" then
        frame.observedDropsNavigationTab = "saved"
    end
    self:RefreshObservedDropsNavigationTabs()

    local entries = GetObservedDropsSavedScanEntries(self)
    frame.libraryRows = frame.libraryRows or {}
    local yOffset = 0
    local contentWidth = frame.libraryScrollFrame and math.max(1, math.floor(frame.libraryScrollFrame:GetWidth() or 1)) or 1
    if contentWidth <= 1 and frame.libraryPanel and frame.libraryPanel.GetWidth then
        contentWidth = math.max(1, math.floor((frame.libraryPanel:GetWidth() or 1) - 40))
    end
    frame.libraryContent:SetWidth(contentWidth)

    for index, data in ipairs(entries) do
        local row = frame.libraryRows[index]
        if not row then
            row = CreateFrame("Button", nil, frame.libraryContent)
            SetObservedFrameLevel(row, frame.libraryContent, 1)
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
            row.openText = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
            row.openText:SetJustifyH("RIGHT")
            row.openText:SetText("Open")

            row.deleteButton = CreateObservedButton(row, 64, 20, "Delete", "danger")
            row.deleteButton:RegisterForClicks("LeftButtonUp")
            row.deleteButton:SetScript("OnClick", function(self)
                local parent = self:GetParent()
                if parent and parent.scanKey then
                    GoldTracker:DeleteObservedDropsSavedScan(parent.scanKey)
                end
            end)
            row.deleteButton:SetScript("OnEnter", function(self)
                GameTooltip:SetOwner(self, "ANCHOR_CURSOR")
                GameTooltip:AddLine("Delete saved scan", 1, 1, 1)
                GameTooltip:Show()
            end)
            row.deleteButton:SetScript("OnLeave", function()
                GameTooltip:Hide()
            end)

            frame.libraryRows[index] = row
        else
            SetObservedFrameLevel(row, frame.libraryContent, 1)
        end

        local entry = data.entry
        local scanKey = data.key
        local itemCount = tonumber(entry.resultCount) or #(entry.results or {})
        local minimumValue = tonumber(entry.minimumValueCopper) or 0
        local expansionLabel = entry.expansionFilterLabel or GetExpansionFilterLabel(self, entry.expansionFilterID)
        local sourceLabel = entry.dropSourceLabel or GetDropSourceLabel(entry.dropSourceID)
        local valueSourceLabel = entry.valueSourceLabel or entry.valueSourceID or "Unknown source"

        row.scanKey = scanKey
        row:SetHeight(54)
        row:ClearAllPoints()
        row:SetPoint("TOPLEFT", frame.libraryContent, "TOPLEFT", 0, -yOffset)
        row:SetPoint("TOPRIGHT", frame.libraryContent, "TOPRIGHT", 0, -yOffset)
        row.background:SetColorTexture(1, 1, 1, index % 2 == 0 and 0.045 or 0.022)
        row.primaryText:ClearAllPoints()
        row.primaryText:SetPoint("TOPLEFT", row, "TOPLEFT", 10, -8)
        row.primaryText:SetPoint("RIGHT", row, "RIGHT", -202, 0)
        row.primaryText:SetText(string.format("%s (%s)", expansionLabel or "Saved scan", sourceLabel or "Drops"))
        row.primaryText:SetTextColor(0.92, 0.95, 1.0)
        row.secondaryText:ClearAllPoints()
        row.secondaryText:SetPoint("TOPLEFT", row.primaryText, "BOTTOMLEFT", 0, -5)
        row.secondaryText:SetPoint("RIGHT", row, "RIGHT", -202, 0)
        row.secondaryText:SetText(string.format(
            "%d items found | Threshold %s | %s | %s",
            itemCount,
            self:FormatMoney(minimumValue),
            valueSourceLabel,
            entry.savedAt or "unknown time"
        ))
        row.secondaryText:SetTextColor(0.72, 0.76, 0.84)
        row.openText:ClearAllPoints()
        row.openText:SetPoint("RIGHT", row, "RIGHT", -86, 0)
        row.openText:SetWidth(52)
        row.openText:SetTextColor(0.68, 0.96, 0.72)
        row.deleteButton:ClearAllPoints()
        row.deleteButton:SetPoint("RIGHT", row, "RIGHT", -10, 0)
        row:SetScript("OnClick", function()
            self:OpenObservedDropsSavedScan(scanKey)
        end)
        row:Show()

        yOffset = yOffset + 56
    end

    for index = #entries + 1, #(frame.libraryRows or {}) do
        frame.libraryRows[index]:Hide()
    end

    frame.libraryContent:SetHeight(math.max(1, yOffset))
    if frame.libraryEmptyText then
        frame.libraryEmptyText:SetShown(#entries == 0)
        frame.libraryEmptyText:SetText("No saved drop scans yet. Open New Scan and press Save after a scan to store one.")
    end
    if frame.libraryStatusText then
        frame.libraryStatusText:SetText(string.format("%d saved scans", #entries))
    end
end

function GoldTracker:RefreshObservedDropsWindowControls()
    local frame = self.observedDropsFrame
    if not frame then
        return
    end

    local source = GetObservedValueSource(self)
    frame.valueSourceID = source and source.id
    if frame.valueSourceDropdown and source then
        UIDropDownMenu_SetSelectedValue(frame.valueSourceDropdown, source.id)
        UIDropDownMenu_SetText(frame.valueSourceDropdown, source.label)
    end

    frame.dropSourceID = NormalizeDropSourceID(frame.dropSourceID)
    if frame.dropSourceDropdown then
        UIDropDownMenu_SetSelectedValue(frame.dropSourceDropdown, frame.dropSourceID)
        UIDropDownMenu_SetText(frame.dropSourceDropdown, GetDropSourceLabel(frame.dropSourceID))
    end

    frame.expansionFilterID = NormalizeExpansionFilter(self, frame.expansionFilterID)
    local expansionLabel = "All expansions"
    for _, option in ipairs(BuildExpansionOptions(self)) do
        if option.id == frame.expansionFilterID then
            expansionLabel = option.label
            break
        end
    end
    if frame.expansionDropdown then
        UIDropDownMenu_SetSelectedValue(frame.expansionDropdown, frame.expansionFilterID)
        UIDropDownMenu_SetText(frame.expansionDropdown, expansionLabel)
    end

    frame.zoneFilterID = NormalizeKnownZoneFilter(frame.zoneFilterID, frame.expansionFilterID)
    local showZoneFilter = frame.dropSourceID == DROP_SOURCE_ATT_ZONES_ID
    SetObservedControlShown(frame.zoneLabel, showZoneFilter)
    if frame.zoneDropdown then
        SetObservedControlShown(frame.zoneDropdown, showZoneFilter)
        UIDropDownMenu_SetSelectedValue(frame.zoneDropdown, frame.zoneFilterID)
        UIDropDownMenu_SetText(frame.zoneDropdown, GetKnownZoneFilterLabel(frame.zoneFilterID))
        if showZoneFilter then
            frame.zoneDropdown:EnableMouse(true)
            if type(UIDropDownMenu_EnableDropDown) == "function" then
                UIDropDownMenu_EnableDropDown(frame.zoneDropdown)
            end
        else
            frame.zoneDropdown:EnableMouse(false)
            if type(UIDropDownMenu_DisableDropDown) == "function" then
                UIDropDownMenu_DisableDropDown(frame.zoneDropdown)
            end
        end
    end

    if frame.minimumValueInput and not frame.minimumValueInput:HasFocus() then
        frame.minimumValueInput:SetText(FormatGoldInput(self, frame.minimumValueCopper or 0))
    end

    local isScanning = IsObservedDropsScanStateActive(frame.scanState)
    local isObservedSource = frame.dropSourceID == DROP_SOURCE_OBSERVED_ID
    if frame.scanButton then
        SetObservedControlShown(frame.scanButton, not isObservedSource)
        frame.scanButton:SetEnabled(not isScanning)
        frame.scanButton:SetText(isScanning and "Scanning" or "Scan")
    end
    if frame.stopScanButton then
        SetObservedControlShown(frame.stopScanButton, not isObservedSource)
        frame.stopScanButton:SetEnabled(isScanning)
        frame.stopScanButton:SetAlpha(isScanning and 1 or 0.45)
    end
    local hasRows = type(frame.scannedObservedDropsRows) == "table" and #frame.scannedObservedDropsRows > 0
    if frame.saveScanButton then
        SetObservedControlShown(frame.saveScanButton, not isObservedSource)
        frame.saveScanButton:SetEnabled(not isScanning)
        frame.saveScanButton:SetAlpha(not isScanning and 1 or 0.45)
    end
    if frame.refreshButton then
        frame.refreshButton:SetEnabled(not isScanning and hasRows)
        frame.refreshButton:SetAlpha((not isScanning and hasRows) and 1 or 0.45)
    end
    if frame.scanSavedSessionsButton then
        SetObservedControlShown(frame.scanSavedSessionsButton, isObservedSource)
        frame.scanSavedSessionsButton:SetEnabled(not isScanning)
        frame.scanSavedSessionsButton:SetAlpha((not isScanning and isObservedSource) and 1 or 0.45)
    end
    if isScanning then
        self:UpdateObservedDropsScanProgress()
        return
    end
    if type(frame.loadedObservedDropsScanCache) == "table" then
        if frame.statusText then
            local entry = frame.loadedObservedDropsScanCache
            frame.statusText:SetText(string.format(
                "Loaded saved scan for %s (%s): %d matching drops.",
                entry.expansionFilterLabel or GetExpansionFilterLabel(self, entry.expansionFilterID),
                entry.dropSourceLabel or GetDropSourceLabel(entry.dropSourceID),
                #(frame.scannedObservedDropsRows or {})
            ))
        end
        return
    end
    if frame.hasObservedDropsScanRun and type(frame.scannedObservedDropsRows) == "table" then
        if frame.statusText then
            if frame.dropSourceID == DROP_SOURCE_OBSERVED_ID then
                frame.statusText:SetText(string.format(
                    "Showing saved-session observed list for %s: %d matching drops.",
                    GetExpansionFilterLabel(self, frame.expansionFilterID),
                    #frame.scannedObservedDropsRows
                ))
            else
                frame.statusText:SetText(string.format(
                    "Scan complete for %s (%s): %d matching drops.",
                    GetExpansionFilterLabel(self, frame.expansionFilterID),
                    GetDropSourceLabel(frame.dropSourceID),
                    #frame.scannedObservedDropsRows
                ))
            end
        end
        return
    end

    if frame.statusText then
        if frame.dropSourceID == DROP_SOURCE_ATT_ZONES_ID then
            local data = GetATTBoEDropsData()
            frame.statusText:SetText(string.format(
                "Showing zone-drop candidates: %d zones, %d item sources. Runtime binding and value filters still apply.",
                tonumber(data.zoneCount) or 0,
                tonumber(data.zoneItemCount) or 0
            ))
        elseif frame.dropSourceID == DROP_SOURCE_ATT_WORLD_ID then
            local data = GetATTBoEDropsData()
            frame.statusText:SetText(string.format(
                "Showing world-drop candidates: %d item sources. Choose All expansions to browse the world pool.",
                tonumber(data.worldItemCount) or 0
            ))
        elseif HasObservedSavedSessionScan(self) then
            frame.statusText:SetText("Showing the saved observed list from your last saved-session scan.")
        elseif self:IsObservedWorldDropsEnabled() then
            frame.statusText:SetText("Observed list is empty. Press Scan saved sessions to build it from history.")
        else
            frame.statusText:SetText("Observed list is empty. Press Scan saved sessions to build it from saved history.")
        end
    end
end

function GoldTracker:UpdateObservedDropsSortHeaderState()
    local frame = self.observedDropsFrame
    if not frame then
        return
    end

    local headerBySortKey = {
        tracked = frame.trackedHeaderButton,
        expansion = frame.expansionHeaderButton,
        location = frame.locationHeaderButton,
        source = frame.sourceHeaderButton,
        itemName = frame.itemHeaderButton,
        seenCount = frame.seenHeaderButton,
        quantity = frame.quantityHeaderButton,
        value = frame.valueHeaderButton,
        marketValue = frame.marketHeaderButton,
        regionMarketValue = frame.regionHeaderButton,
        averageValue = frame.averageHeaderButton,
    }

    for sortKey, button in pairs(headerBySortKey) do
        if button and button.sortIcon then
            if sortKey == frame.sortKey then
                button.sortIcon:SetTexture(frame.sortAscending and "Interface\\Buttons\\UI-SortArrow" or "Interface\\Buttons\\UI-SortArrow")
                button.sortIcon:SetTexCoord(0, 1, frame.sortAscending and 0 or 1, frame.sortAscending and 1 or 0)
                button.sortIcon:Show()
            else
                button.sortIcon:Hide()
            end
        end
    end
end

function GoldTracker:ToggleObservedDropsSort(sortKey)
    local frame = self.observedDropsFrame
    if not frame then
        return
    end

    local normalizedSortKey = NormalizeSortKey(sortKey)
    if frame.sortKey == normalizedSortKey then
        frame.sortAscending = not frame.sortAscending
    else
        frame.sortKey = normalizedSortKey
        frame.sortAscending = normalizedSortKey == "itemName" or normalizedSortKey == "expansion"
    end

    self:RefreshObservedDropsWindow(false)
end

function GoldTracker:GetObservedDropsWindowRow(index)
    local frame = self.observedDropsFrame
    if not frame or not frame.content then
        return nil
    end

    frame.rows = frame.rows or {}
    local row = frame.rows[index]
    if row then
        SetObservedFrameLevel(row, frame.content, 1)
        return row
    end

    row = CreateFrame("Button", nil, frame.content)
    SetObservedFrameLevel(row, frame.content, 1)
    row:EnableMouse(true)
    BindObservedResultsMouseWheel(row, frame)
    row:RegisterForClicks("LeftButtonUp")
    row:SetHeight(ROW_HEIGHT)

    local background = row:CreateTexture(nil, "BACKGROUND")
    background:SetAllPoints(row)
    row.background = background

    local hover = row:CreateTexture(nil, "HIGHLIGHT")
    hover:SetAllPoints(row)
    hover:SetColorTexture(1, 0.82, 0.18, 0.08)
    row.hover = hover

    local trackedButton = CreateObservedButton(row, 24, 20, "+", "neutral")
    BindObservedResultsMouseWheel(trackedButton, frame)
    trackedButton:SetScript("OnClick", function(self)
        GoldTracker:ToggleObservedDropFavorite(self:GetParent())
    end)
    row.trackedButton = trackedButton

    local icon = row:CreateTexture(nil, "ARTWORK")
    icon:SetSize(ICON_SIZE, ICON_SIZE)
    row.icon = icon

    local function CreateCell(justifyH)
        local text = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        text:SetJustifyH(justifyH or "LEFT")
        text:SetWordWrap(false)
        return text
    end

    row.expansionText = CreateCell("LEFT")
    row.locationText = CreateCell("LEFT")
    row.sourceText = CreateCell("LEFT")
    row.itemText = CreateCell("LEFT")
    row.seenText = CreateCell("RIGHT")
    row.quantityText = CreateCell("RIGHT")
    row.valueText = CreateCell("RIGHT")
    row.marketText = CreateCell("RIGHT")
    row.regionText = CreateCell("RIGHT")
    row.averageText = CreateCell("RIGHT")

    local detailsButton = CreateObservedButton(row, DETAILS_WIDTH - 8, 20, "Details", "neutral")
    BindObservedResultsMouseWheel(detailsButton, frame)
    detailsButton:SetScript("OnClick", function(self)
        GoldTracker:OpenInventoryItemDetailsWindow(self:GetParent())
    end)
    row.detailsButton = detailsButton

    local divider = row:CreateTexture(nil, "ARTWORK")
    divider:SetColorTexture(1, 1, 1, 0.045)
    divider:SetPoint("BOTTOMLEFT", row, "BOTTOMLEFT", 0, 0)
    divider:SetPoint("BOTTOMRIGHT", row, "BOTTOMRIGHT", 0, 0)
    divider:SetHeight(1)
    row.divider = divider

    row:SetScript("OnEnter", function(self)
        if (type(self.itemLink) ~= "string" or self.itemLink == "") and not self.itemID then
            return
        end
        GameTooltip:SetOwner(self, "ANCHOR_CURSOR")
        if type(self.itemLink) == "string" and self.itemLink ~= "" then
            GameTooltip:SetHyperlink(self.itemLink)
        elseif type(GameTooltip.SetItemByID) == "function" then
            GameTooltip:SetItemByID(self.itemID)
        else
            GameTooltip:SetHyperlink("item:" .. tostring(self.itemID))
        end
        GameTooltip:AddLine(" ")
        GameTooltip:AddDoubleLine("Expansion", self.expansionLabel or "Unknown", 0.72, 0.86, 1.0, 1, 1, 1)
        GameTooltip:AddDoubleLine("Location", self.locationLabel or "Unknown", 0.72, 0.86, 1.0, 1, 1, 1)
        GameTooltip:AddDoubleLine("Source", self.sourceTextValue or "Unknown", 0.72, 0.86, 1.0, 1, 1, 1)
        GameTooltip:AddDoubleLine("Seen / Qty", string.format("%d / %d", tonumber(self.seenCount) or 0, tonumber(self.quantity) or 0), 0.72, 0.86, 1.0, 1, 1, 1)
        GameTooltip:AddLine(" ")
        GameTooltip:AddLine("Click Details for price history.", 0.72, 0.86, 1.0)
        GameTooltip:Show()
    end)
    row:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)
    row:SetScript("OnClick", function(self)
        if GoldTracker:HandleModifiedItemClickIfModified(self) then
            return
        end
        GoldTracker:OpenInventoryItemDetailsWindow(self)
    end)

    frame.rows[index] = row
    return row
end

function GoldTracker:RefreshObservedDropsWindowLayout()
    local frame = self.observedDropsFrame
    if not frame or not frame.scrollFrame or not frame.content then
        return
    end

    ApplyObservedTableColumnLayout(frame)
    if frame.scrollFrame.UpdateScrollChildRect then
        frame.scrollFrame:UpdateScrollChildRect()
    end
end

function GoldTracker:RefreshObservedDropsWindow(scrollToTop)
    local frame = self.observedDropsFrame
    if not frame or not frame.content then
        return
    end

    self:RefreshObservedDropsWindowControls()
    self:UpdateObservedDropsSortHeaderState()

    local rows = frame.hasObservedDropsScanRun and (frame.scannedObservedDropsRows or {}) or {}
    for _, row in ipairs(rows) do
        row.tracked = type(self.IsFarmingItemFavorite) == "function" and self:IsFarmingItemFavorite(row)
    end
    SortRows(rows, frame.sortKey, frame.sortAscending)
    if type(self.RecordInventoryMarketSnapshots) == "function" then
        self:RecordInventoryMarketSnapshots(rows)
    end

    local yOffset = 0
    local totalValue = 0
    for index, result in ipairs(rows) do
        local row = self:GetObservedDropsWindowRow(index)
        if row then
            row.observedDropKey = result.observedDropKey
            row.itemID = result.itemID
            row.itemName = result.itemName
            row.itemLink = result.itemLink
            row.itemQuality = result.itemQuality
            row.iconTexture = result.iconTexture
            row.expansionID = result.expansionID
            row.expansionLabel = result.expansionLabel
            row.locationLabel = result.locationLabel
            row.sourceTextValue = result.sourceText
            row.seenCount = result.seenCount
            row.quantity = result.quantity
            row.value = result.value
            row.unitValue = result.unitValue
            row.totalValue = result.totalValue
            row.valueSourceID = result.valueSourceID
            row.valueSourceLabel = result.valueSourceLabel
            row.marketValue = result.marketValue
            row.historicalValue = result.historicalValue
            row.regionMarketValue = result.regionMarketValue
            row.averageValue = result.averageValue
            row.farmingSourceType = result.farmingSourceType
            row.bossName = result.bossName
            row.instanceName = result.instanceName

            row.trackedButton:SetText(result.tracked and "-" or "+")
            if row.trackedButton.SetSelected then
                row.trackedButton:SetSelected(result.tracked)
            end
            row.expansionText:SetText(result.expansionLabel or "Unknown")
            row.locationText:SetText(result.locationLabel or "Unknown")
            row.sourceText:SetText(result.sourceText or "Unknown")
            row.itemText:SetText(result.itemLink or result.itemName or ("Item " .. tostring(result.itemID or "?")))
            row.seenText:SetText(tostring(math.floor((tonumber(result.seenCount) or 0) + 0.5)))
            row.quantityText:SetText(tostring(math.floor((tonumber(result.quantity) or 0) + 0.5)))
            row.valueText:SetText(result.value > 0 and self:FormatMoney(result.value) or "--")
            row.marketText:SetText(result.marketValue > 0 and self:FormatMoney(result.marketValue) or "--")
            row.regionText:SetText(result.regionMarketValue > 0 and self:FormatMoney(result.regionMarketValue) or "--")
            row.averageText:SetText(result.averageValue > 0 and self:FormatMoney(result.averageValue) or "--")
            if result.iconTexture then
                row.icon:SetTexture(result.iconTexture)
                row.icon:Show()
            else
                row.icon:Hide()
            end
            if row.background then
                row.background:SetColorTexture(1, 1, 1, index % 2 == 0 and 0.045 or 0.022)
            end
            if row.divider then
                row.divider:SetShown(index < #rows)
            end

            row:ClearAllPoints()
            row:SetPoint("TOPLEFT", frame.content, "TOPLEFT", 0, -yOffset)
            row:SetPoint("TOPRIGHT", frame.content, "TOPRIGHT", 0, -yOffset)
            row:SetHeight(ROW_HEIGHT)
            row:Show()

            yOffset = yOffset + ROW_HEIGHT
            if index < #rows then
                yOffset = yOffset + ROW_SPACING
            end
            totalValue = totalValue + math.max(0, tonumber(result.value) or 0)
        end
    end

    for index = (#rows + 1), #(frame.rows or {}) do
        if frame.rows[index] then
            frame.rows[index]:Hide()
        end
    end

    frame.content:SetHeight(math.max(1, yOffset))
    if frame.emptyText then
        if #rows == 0 then
            frame.emptyText:SetText(frame.hasObservedDropsScanRun
                and "No drops match the selected filters."
                or "Choose filters, then press Scan to build the drops list.")
            frame.emptyText:Show()
        else
            frame.emptyText:Hide()
        end
    end
    if frame.metaText then
        local observedDrops = type(self.NormalizeObservedWorldDrops) == "function" and self:NormalizeObservedWorldDrops() or {}
        local storedCount = 0
        for _ in pairs(observedDrops) do
            storedCount = storedCount + 1
        end
        local source = GetObservedValueSource(self)
        frame.metaText:SetText(string.format(
            "%d shown | %d captured | %s | Total selected value %s",
            #rows,
            storedCount,
            source and source.label or "Unknown source",
            self:FormatMoney(totalValue)
        ))
    end

    self:RefreshObservedDropsWindowLayout()
    if scrollToTop and frame.scrollFrame then
        frame.scrollFrame:SetVerticalScroll(0)
    end
end

function GoldTracker:CreateObservedDropsWindow()
    if self.observedDropsFrame then
        return
    end

    local addon = self
    local frame = CreateFrame("Frame", "GoldTrackerObservedDropsFrame", UIParent, "BasicFrameTemplateWithInset")
    frame:SetSize(WINDOW_WIDTH, WINDOW_HEIGHT)
    frame:SetPoint("CENTER", UIParent, "CENTER", 0, 30)
    frame:SetFrameStrata("DIALOG")
    if frame.SetToplevel then
        frame:SetToplevel(true)
    end
    frame:SetMovable(true)
    frame:SetResizable(true)
    if frame.SetResizeBounds then
        frame:SetResizeBounds(WINDOW_MIN_WIDTH, WINDOW_MIN_HEIGHT, WINDOW_MAX_WIDTH, WINDOW_MAX_HEIGHT)
    else
        if frame.SetMinResize then
            frame:SetMinResize(WINDOW_MIN_WIDTH, WINDOW_MIN_HEIGHT)
        end
        if frame.SetMaxResize then
            frame:SetMaxResize(WINDOW_MAX_WIDTH, WINDOW_MAX_HEIGHT)
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

    local initialSource = GetObservedValueSource(self)
    frame.valueSourceID = initialSource and initialSource.id
    frame.minimumValueCopper = NormalizeCopper(self.db and self.db.observedWorldDropsMinimumValue)
    frame.expansionFilterID = NormalizeExpansionFilter(self, self.db and self.db.observedWorldDropsExpansionFilter)
    frame.dropSourceID = NormalizeDropSourceID(self.db and self.db.observedDropsSourceFilter)
    frame.zoneFilterID = NormalizeKnownZoneFilter(self.db and self.db.observedDropsZoneFilter)
    frame.rows = {}
    frame.itemCache = {}
    frame.priceCache = {}
    frame.hasObservedDropsScanRun = false
    frame.scannedObservedDropsRows = nil
    frame.observedDropsViewID = "library"
    frame.observedDropsNavigationTab = "saved"
    frame.sortKey = DEFAULT_SORT_KEY
    frame.sortAscending = false

    local chrome = Theme:ApplyWindowChrome(frame, "Observed BoE Drops")
    Theme:RegisterSpecialFrame("GoldTrackerObservedDropsFrame")

    local savedScansTabButton = CreateObservedButton(frame, 104, 24, "Saved Scans", "primary")
    savedScansTabButton:SetPoint("TOPLEFT", chrome, "TOPLEFT", 12, -54)
    savedScansTabButton:SetScript("OnClick", function()
        frame.observedDropsNavigationTab = "saved"
        addon:SetObservedDropsWindowView("library")
        addon:RefreshObservedDropsSavedScansWindow()
    end)
    frame.savedScansTabButton = savedScansTabButton

    local newScanTabButton = CreateObservedButton(frame, 96, 24, "New Scan", "neutral")
    newScanTabButton:SetPoint("LEFT", savedScansTabButton, "RIGHT", 8, 0)
    newScanTabButton:SetScript("OnClick", function()
        addon:OpenObservedDropsNewScan()
    end)
    frame.newScanTabButton = newScanTabButton

    local libraryPanel = CreateObservedPanel(frame, { 0.04, 0.05, 0.07, 0.94 }, { 1.0, 0.82, 0.18, 0.12 })
    SetObservedFrameLevel(libraryPanel, chrome, 1)
    libraryPanel:SetPoint("TOPLEFT", chrome, "TOPLEFT", 12, -86)
    libraryPanel:SetPoint("BOTTOMRIGHT", chrome, "BOTTOMRIGHT", -12, 38)
    frame.libraryPanel = libraryPanel

    local libraryStatusText = libraryPanel:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    libraryStatusText:SetPoint("TOPLEFT", libraryPanel, "TOPLEFT", 14, -12)
    libraryStatusText:SetPoint("RIGHT", libraryPanel, "RIGHT", -14, 0)
    libraryStatusText:SetJustifyH("LEFT")
    libraryStatusText:SetTextColor(0.72, 0.76, 0.84)
    frame.libraryStatusText = libraryStatusText

    local libraryScrollFrame = CreateFrame("ScrollFrame", nil, libraryPanel, "UIPanelScrollFrameTemplate")
    SetObservedFrameLevel(libraryScrollFrame, libraryPanel, 2)
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
    SetObservedFrameLevel(libraryContent, libraryScrollFrame, 1)
    libraryContent:SetSize(1, 1)
    libraryScrollFrame:SetScrollChild(libraryContent)
    frame.libraryContent = libraryContent

    local libraryEmptyText = libraryContent:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    libraryEmptyText:SetPoint("TOPLEFT", libraryContent, "TOPLEFT", 10, -12)
    libraryEmptyText:SetPoint("RIGHT", libraryPanel, "RIGHT", -40, 0)
    libraryEmptyText:SetJustifyH("LEFT")
    libraryEmptyText:SetTextColor(0.62, 0.66, 0.74)
    frame.libraryEmptyText = libraryEmptyText

    local controlsPanel = CreateObservedPanel(frame, { 0.05, 0.06, 0.08, 0.94 }, { 1.0, 0.82, 0.18, 0.12 })
    SetObservedFrameLevel(controlsPanel, chrome, 1)
    controlsPanel:SetPoint("TOPLEFT", chrome, "TOPLEFT", 12, -86)
    controlsPanel:SetPoint("TOPRIGHT", chrome, "TOPRIGHT", -12, -86)
    controlsPanel:SetHeight(150)
    frame.controlsPanel = controlsPanel

    local sourceLabel = controlsPanel:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    sourceLabel:SetPoint("TOPLEFT", controlsPanel, "TOPLEFT", 14, -10)
    sourceLabel:SetText("Value source")

    local valueSourceDropdown = CreateFrame("Frame", "GoldTrackerObservedDropsValueSourceDropdown", controlsPanel, "UIDropDownMenuTemplate")
    valueSourceDropdown:SetPoint("TOPLEFT", sourceLabel, "BOTTOMLEFT", -16, -5)
    UIDropDownMenu_SetWidth(valueSourceDropdown, 210)
    UIDropDownMenu_Initialize(valueSourceDropdown, function(_, level)
        for _, valueSource in ipairs(addon.VALUE_SOURCES) do
            if valueSource.tsmKey then
                local info = UIDropDownMenu_CreateInfo()
                local sourceID = valueSource.id
                info.text = valueSource.label
                info.value = sourceID
                info.checked = frame.valueSourceID == sourceID
                info.func = function()
                    frame.valueSourceID = sourceID
                    frame.priceCache = {}
                    if addon.db then
                        addon.db.observedWorldDropsValueSource = sourceID
                    end
                    frame.zoneFilterID = NormalizeKnownZoneFilter(frame.zoneFilterID, frame.expansionFilterID)
                    addon:ClearObservedDropsScanResults()
                end
                UIDropDownMenu_AddButton(info, level)
            end
        end
    end)
    frame.valueSourceDropdown = valueSourceDropdown

    local minValueLabel = controlsPanel:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    minValueLabel:SetPoint("TOPLEFT", sourceLabel, "TOPLEFT", 250, 0)
    minValueLabel:SetText("Min value (g)")

    local minimumValueInput = CreateFrame("EditBox", nil, controlsPanel, "InputBoxTemplate")
    minimumValueInput:SetSize(110, 22)
    minimumValueInput:SetPoint("TOPLEFT", minValueLabel, "BOTTOMLEFT", 0, -8)
    minimumValueInput:SetAutoFocus(false)
    minimumValueInput:SetNumeric(false)
    minimumValueInput:SetText("0")
    minimumValueInput:SetScript("OnEnterPressed", function(editBox)
        editBox:ClearFocus()
    end)
    minimumValueInput:SetScript("OnEscapePressed", function(editBox)
        editBox:SetText(FormatGoldInput(addon, frame.minimumValueCopper))
        editBox:ClearFocus()
    end)
    minimumValueInput:SetScript("OnEditFocusLost", function()
        addon:SaveObservedDropsMinimumValueInput()
    end)
    frame.minimumValueInput = minimumValueInput

    local expansionLabel = controlsPanel:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    expansionLabel:SetPoint("TOPLEFT", minValueLabel, "TOPLEFT", 180, 0)
    expansionLabel:SetText("Expansion")

    local expansionDropdown = CreateFrame("Frame", "GoldTrackerObservedDropsExpansionDropdown", controlsPanel, "UIDropDownMenuTemplate")
    expansionDropdown:SetPoint("TOPLEFT", expansionLabel, "BOTTOMLEFT", -16, -5)
    UIDropDownMenu_SetWidth(expansionDropdown, 190)
    UIDropDownMenu_Initialize(expansionDropdown, function(_, level)
        for _, option in ipairs(BuildExpansionOptions(addon)) do
            local info = UIDropDownMenu_CreateInfo()
            info.text = option.label
            info.value = option.id
            info.checked = frame.expansionFilterID == option.id
            info.func = function()
                frame.expansionFilterID = option.id
                frame.zoneFilterID = NormalizeKnownZoneFilter(frame.zoneFilterID, frame.expansionFilterID)
                if addon.db then
                    addon.db.observedWorldDropsExpansionFilter = option.id
                    addon.db.observedDropsZoneFilter = frame.zoneFilterID
                end
                addon:ClearObservedDropsScanResults()
            end
            UIDropDownMenu_AddButton(info, level)
        end
    end)
    frame.expansionDropdown = expansionDropdown

    local dropSourceLabel = controlsPanel:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    dropSourceLabel:SetPoint("TOPLEFT", expansionLabel, "TOPLEFT", 220, 0)
    dropSourceLabel:SetText("Drop list")

    local dropSourceDropdown = CreateFrame("Frame", "GoldTrackerObservedDropsSourceDropdown", controlsPanel, "UIDropDownMenuTemplate")
    dropSourceDropdown:SetPoint("TOPLEFT", dropSourceLabel, "BOTTOMLEFT", -16, -5)
    UIDropDownMenu_SetWidth(dropSourceDropdown, 150)
    UIDropDownMenu_Initialize(dropSourceDropdown, function(_, level)
        for _, option in ipairs(DROP_SOURCE_OPTIONS) do
            if not option.hidden then
                local info = UIDropDownMenu_CreateInfo()
                info.text = option.label
                info.value = option.id
                info.checked = frame.dropSourceID == option.id
                info.func = function()
                    frame.dropSourceID = option.id
                    frame.zoneFilterID = NormalizeKnownZoneFilter(frame.zoneFilterID, frame.expansionFilterID)
                    frame.itemCache = {}
                    frame.priceCache = {}
                    if addon.db then
                        addon.db.observedDropsSourceFilter = option.id
                        addon.db.observedDropsZoneFilter = frame.zoneFilterID
                    end
                    addon:ClearObservedDropsScanResults()
                end
                UIDropDownMenu_AddButton(info, level)
            end
        end
    end)
    frame.dropSourceDropdown = dropSourceDropdown

    local zoneLabel = controlsPanel:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    zoneLabel:SetPoint("TOPLEFT", dropSourceLabel, "TOPLEFT", 178, 0)
    zoneLabel:SetText("Zone")
    frame.zoneLabel = zoneLabel

    local zoneDropdown = CreateFrame("Frame", "GoldTrackerObservedDropsZoneDropdown", controlsPanel, "UIDropDownMenuTemplate")
    zoneDropdown:SetPoint("TOPLEFT", zoneLabel, "BOTTOMLEFT", -16, -5)
    UIDropDownMenu_SetWidth(zoneDropdown, 190)
    UIDropDownMenu_Initialize(zoneDropdown, function(_, level)
        for _, option in ipairs(BuildKnownZoneOptions(frame.expansionFilterID)) do
            local info = UIDropDownMenu_CreateInfo()
            info.text = option.label
            info.value = option.id
            info.checked = frame.zoneFilterID == option.id
            info.func = function()
                frame.zoneFilterID = NormalizeKnownZoneFilter(option.id, frame.expansionFilterID)
                frame.itemCache = {}
                frame.priceCache = {}
                if addon.db then
                    addon.db.observedDropsZoneFilter = option.id
                end
                addon:ClearObservedDropsScanResults()
            end
            UIDropDownMenu_AddButton(info, level)
        end
    end)
    frame.zoneDropdown = zoneDropdown

    local scanButton = CreateObservedButton(controlsPanel, 92, 22, "Scan", "primary")
    scanButton:SetPoint("TOPRIGHT", controlsPanel, "TOPRIGHT", -14, -62)
    scanButton:SetScript("OnClick", function()
        addon:ScanObservedDropsSelection()
    end)
    frame.scanButton = scanButton

    local saveScanButton = CreateObservedButton(controlsPanel, 82, 22, "Save", "neutral")
    saveScanButton:SetPoint("RIGHT", scanButton, "LEFT", -8, 0)
    saveScanButton:SetScript("OnClick", function()
        addon:SaveCurrentObservedDropsScan()
    end)
    frame.saveScanButton = saveScanButton

    local stopScanButton = CreateObservedButton(controlsPanel, 70, 22, "Stop", "danger")
    stopScanButton:SetPoint("RIGHT", saveScanButton, "LEFT", -8, 0)
    stopScanButton:SetEnabled(false)
    stopScanButton:SetAlpha(0.45)
    stopScanButton:SetScript("OnClick", function()
        addon:CancelObservedDropsScan()
    end)
    frame.stopScanButton = stopScanButton

    local refreshButton = CreateObservedButton(controlsPanel, 112, 22, "Refresh Prices", "neutral")
    refreshButton:SetPoint("RIGHT", stopScanButton, "LEFT", -8, 0)
    refreshButton:SetScript("OnClick", function()
        frame.itemCache = {}
        frame.priceCache = {}
        addon:RefreshCurrentObservedDropsScanPrices()
        addon:RefreshObservedDropsWindow(true)
    end)
    frame.refreshButton = refreshButton

    local scanSavedSessionsButton = CreateObservedButton(controlsPanel, 142, 22, "Scan saved sessions", "neutral")
    scanSavedSessionsButton:SetPoint("RIGHT", refreshButton, "LEFT", -8, 0)
    scanSavedSessionsButton:SetScript("OnClick", function()
        local result = type(addon.ScanSavedSessionsForObservedDrops) == "function"
            and addon:ScanSavedSessionsForObservedDrops()
            or nil
        frame.itemCache = {}
        frame.priceCache = {}
        frame.dropSourceID = DROP_SOURCE_OBSERVED_ID
        if addon.db then
            addon.db.observedDropsSourceFilter = DROP_SOURCE_OBSERVED_ID
        end
        local statusMessage
        if frame.statusText and type(result) == "table" then
            statusMessage = string.format(
                "Saved sessions scanned: %d sessions, %d eligible, %d new, %d updated.",
                tonumber(result.scannedSessions) or 0,
                tonumber(result.eligibleItems) or 0,
                tonumber(result.addedItems) or 0,
                tonumber(result.updatedItems) or 0
            )
        end
        LoadObservedSavedSessionRows(addon, false, statusMessage)
    end)
    frame.scanSavedSessionsButton = scanSavedSessionsButton

    local progressBackdrop = CreateObservedPanel(controlsPanel, { 0.03, 0.04, 0.06, 0.96 }, { 1, 1, 1, 0.08 })
    progressBackdrop:SetPoint("TOPLEFT", controlsPanel, "TOPLEFT", 14, -100)
    progressBackdrop:SetPoint("TOPRIGHT", controlsPanel, "TOPRIGHT", -14, -100)
    progressBackdrop:SetHeight(14)
    frame.progressBackdrop = progressBackdrop

    local progressBar = CreateFrame("StatusBar", nil, progressBackdrop)
    progressBar:SetPoint("TOPLEFT", progressBackdrop, "TOPLEFT", 1, -1)
    progressBar:SetPoint("BOTTOMRIGHT", progressBackdrop, "BOTTOMRIGHT", -1, 1)
    progressBar:SetStatusBarTexture("Interface\\Buttons\\WHITE8X8")
    progressBar:SetStatusBarColor(1.0, 0.82, 0.18, 0.75)
    progressBar:SetMinMaxValues(0, 1)
    progressBar:SetValue(0)
    frame.progressBar = progressBar

    local statusText = controlsPanel:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    statusText:SetPoint("TOPLEFT", progressBackdrop, "BOTTOMLEFT", 0, -8)
    statusText:SetPoint("TOPRIGHT", progressBackdrop, "BOTTOMRIGHT", 0, -8)
    statusText:SetJustifyH("LEFT")
    statusText:SetTextColor(0.88, 0.92, 1.0)
    statusText:SetText("")
    frame.statusText = statusText

    local listPanel = CreateObservedPanel(frame, { 0.04, 0.05, 0.07, 0.92 }, { 1.0, 0.82, 0.18, 0.10 })
    SetObservedFrameLevel(listPanel, chrome, 1)
    listPanel:SetPoint("TOPLEFT", controlsPanel, "BOTTOMLEFT", 0, -10)
    listPanel:SetPoint("BOTTOMRIGHT", chrome, "BOTTOMRIGHT", -12, 38)
    if listPanel.SetClipsChildren then
        listPanel:SetClipsChildren(true)
    end
    frame.listPanel = listPanel

    local function AddHeader(label, width, justifyH, sortKey)
        local button = CreateObservedHeaderButton(listPanel, label, width, justifyH)
        SetObservedFrameLevel(button, listPanel, 2)
        if sortKey then
            button:SetScript("OnClick", function()
                addon:ToggleObservedDropsSort(sortKey)
            end)
        end
        return button
    end

    frame.trackedHeaderButton = AddHeader("Tracked", TRACKED_WIDTH, "LEFT", "tracked")
    frame.expansionHeaderButton = AddHeader("Expansion", EXPANSION_WIDTH, "LEFT", "expansion")
    frame.locationHeaderButton = AddHeader("Location", LOCATION_WIDTH, "LEFT", "location")
    frame.sourceHeaderButton = AddHeader("Source", SOURCE_WIDTH, "LEFT", "source")
    frame.itemHeaderButton = AddHeader("Item", nil, "LEFT", "itemName")
    frame.seenHeaderButton = AddHeader("Seen", SEEN_WIDTH, "RIGHT", "seenCount")
    frame.quantityHeaderButton = AddHeader("Qty", QUANTITY_WIDTH, "RIGHT", "quantity")
    frame.valueHeaderButton = AddHeader("Selected", VALUE_WIDTH, "RIGHT", "value")
    frame.marketHeaderButton = AddHeader("Market", VALUE_WIDTH, "RIGHT", "marketValue")
    frame.regionHeaderButton = AddHeader("Region", VALUE_WIDTH, "RIGHT", "regionMarketValue")
    frame.averageHeaderButton = AddHeader("Avg", VALUE_WIDTH, "RIGHT", "averageValue")
    frame.detailsHeaderButton = AddHeader("", DETAILS_WIDTH, "LEFT", nil)

    local headerUnderline = listPanel:CreateTexture(nil, "ARTWORK")
    headerUnderline:SetColorTexture(1, 0.82, 0.18, 0.18)
    headerUnderline:SetPoint("TOPLEFT", listPanel, "TOPLEFT", 12, -30)
    headerUnderline:SetPoint("TOPRIGHT", listPanel, "TOPRIGHT", -12, -30)
    headerUnderline:SetHeight(1)

    local scrollFrame = CreateFrame("ScrollFrame", nil, listPanel, "UIPanelScrollFrameTemplate")
    SetObservedFrameLevel(scrollFrame, listPanel, 2)
    scrollFrame:SetPoint("TOPLEFT", listPanel, "TOPLEFT", 12, -36)
    scrollFrame:SetPoint("BOTTOMRIGHT", listPanel, "BOTTOMRIGHT", -26, 12 + HORIZONTAL_SCROLL_HEIGHT)
    frame.scrollFrame = scrollFrame
    BindObservedResultsMouseWheel(scrollFrame, frame)

    local content = CreateFrame("Frame", nil, scrollFrame)
    SetObservedFrameLevel(content, scrollFrame, 1)
    content:SetSize(1, 1)
    scrollFrame:SetScrollChild(content)
    frame.content = content

    local horizontalScrollBar = CreateFrame("Slider", "GoldTrackerObservedDropsHorizontalScrollBar", listPanel, "OptionsSliderTemplate")
    SetObservedFrameLevel(horizontalScrollBar, listPanel, 3)
    horizontalScrollBar:SetOrientation("HORIZONTAL")
    horizontalScrollBar:SetPoint("BOTTOMLEFT", listPanel, "BOTTOMLEFT", 14, 9)
    horizontalScrollBar:SetPoint("BOTTOMRIGHT", listPanel, "BOTTOMRIGHT", -32, 9)
    horizontalScrollBar:SetHeight(12)
    horizontalScrollBar:SetMinMaxValues(0, 0)
    horizontalScrollBar:SetValue(0)
    horizontalScrollBar:SetScript("OnValueChanged", function(self, value)
        if self.updating then
            return
        end
        frame.horizontalScrollOffset = math.max(0, math.floor((tonumber(value) or 0) + 0.5))
        ApplyObservedTableColumnLayout(frame)
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
        minWidth = WINDOW_MIN_WIDTH,
        minHeight = WINDOW_MIN_HEIGHT,
        maxWidth = WINDOW_MAX_WIDTH,
        maxHeight = WINDOW_MAX_HEIGHT,
        onResizeStop = function()
            addon:RefreshObservedDropsWindowLayout()
        end,
    })

    frame:RegisterEvent("GET_ITEM_INFO_RECEIVED")
    frame:RegisterEvent("ITEM_DATA_LOAD_RESULT")
    frame:SetScript("OnEvent", function(_, _, itemID)
        if itemID then
            frame.itemCache = {}
            if frame:IsShown() then
                addon:RefreshObservedDropsWindow(false)
            end
        end
    end)
    frame:SetScript("OnSizeChanged", function()
        if frame.isManualResizing then
            return
        end
        addon:RefreshObservedDropsWindowLayout()
    end)
    frame:SetScript("OnShow", function()
        if frame.suppressExplorerOnShow then
            return
        end
        if frame.observedDropsViewID == "scan" then
            addon:RefreshObservedDropsWindow(true)
        else
            addon:RefreshObservedDropsSavedScansWindow()
        end
    end)
    frame:SetScript("OnHide", function()
        GameTooltip:Hide()
    end)

    self.observedDropsFrame = frame
    self:RefreshObservedDropsWindowControls()
    self:SetObservedDropsWindowView("library")
end

function GoldTracker:OpenObservedDropsWindow()
    if type(self.OpenExplorerWindow) == "function" then
        self:OpenExplorerWindow("drops")
        return
    end

    self:CreateObservedDropsWindow()
    if not self.observedDropsFrame then
        return
    end

    self.observedDropsFrame:Show()
    self.observedDropsFrame:Raise()
    self:SetObservedDropsWindowView("library")
end

function GoldTracker:ToggleObservedDropsWindow()
    if type(self.ToggleExplorerWindow) == "function" then
        self:ToggleExplorerWindow("drops")
        return
    end

    self:CreateObservedDropsWindow()
    if not self.observedDropsFrame then
        return
    end

    if self.observedDropsFrame:IsShown() then
        self.observedDropsFrame:Hide()
    else
        self:OpenObservedDropsWindow()
    end
end
