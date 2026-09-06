local _, NS = ...
local GoldTracker = NS.GoldTracker
local Theme = NS.JanisTheme

local RARE_FARMING_WINDOW_WIDTH = 1080
local RARE_FARMING_WINDOW_HEIGHT = 620
local RARE_FARMING_WINDOW_MIN_WIDTH = 980
local RARE_FARMING_WINDOW_MIN_HEIGHT = 420
local RARE_FARMING_WINDOW_MAX_WIDTH = 1320
local RARE_FARMING_WINDOW_MAX_HEIGHT = 900
local RARE_FARMING_ROW_HEIGHT = 24
local RARE_FARMING_ROW_SPACING = 2
local RARE_FARMING_ROW_STRIDE = RARE_FARMING_ROW_HEIGHT + RARE_FARMING_ROW_SPACING
local RARE_FARMING_ICON_SIZE = 18
local RARE_FARMING_COLUMN_GAP = 12
local RARE_FARMING_FAVORITE_WIDTH = 58
local RARE_FARMING_LOCATION_WIDTH = 150
local RARE_FARMING_RARE_WIDTH = 150
local RARE_FARMING_VALUE_WIDTH = 96
local RARE_FARMING_ITEM_MIN_WIDTH = 150
local RARE_FARMING_HEADER_LEFT_INSET = 12
local RARE_FARMING_ROW_RIGHT_PADDING = 6
local RARE_FARMING_SORT_ICON_SIZE = 10
local RARE_FARMING_WOWHEAD_BUTTON_WIDTH = 64
local RARE_FARMING_MAP_BUTTON_WIDTH = 48
local RARE_FARMING_HORIZONTAL_SCROLL_HEIGHT = 14
local RARE_FARMING_TRACKED_BUTTON_WIDTH = 24
local RARE_FARMING_TRACKED_BUTTON_HEIGHT = 20
local RARE_FARMING_SCAN_MODE_BACKGROUND_ID = "background"
local RARE_FARMING_SCAN_MODE_FOREGROUND_ID = "foreground"
local RARE_FARMING_BACKGROUND_SCAN_ITEMS_PER_TICK = 150
local RARE_FARMING_FOREGROUND_SCAN_ITEMS_PER_TICK = 3000
local RARE_FARMING_SCAN_REFRESH_INTERVAL = 0.35
local RARE_FARMING_ITEM_REFRESH_DELAY = 0.5
local RARE_FARMING_SCAN_CACHE_VERSION = 1
local RARE_FARMING_SCAN_CACHE_MAX_ENTRIES = 30
local RARE_FARMING_SORT_KEY_DEFAULT = "value"
local RARE_FARMING_EXPANSION_CURRENT_ID = "current"
local RARE_FARMING_EXPANSION_ALL_ID = "all"
local RARE_FARMING_CURRENT_EXPANSION_ID = 16
local RARE_FARMING_CURRENT_EXPANSION_LABEL_MAP_ID = 2537

local RARE_FARMING_CURRENT_EXPANSION_MAP_IDS = {
    [2393] = true,
    [2395] = true,
    [2405] = true,
    [2413] = true,
    [2424] = true,
    [2432] = true,
    [2437] = true,
    [2444] = true,
    [2509] = true,
    [2512] = true,
    [2536] = true,
    [2537] = true,
    [2541] = true,
    [2545] = true,
    [2599] = true,
    [2600] = true,
}

local RARE_FARMING_SORT_KEYS = {
    favorite = true,
    location = true,
    rareName = true,
    itemName = true,
    value = true,
    marketValue = true,
    regionMarketValue = true,
    averageValue = true,
}

local RARE_FARMING_SCAN_MODE_OPTIONS = {
    {
        id = RARE_FARMING_SCAN_MODE_BACKGROUND_ID,
        label = "Background",
        batchSize = RARE_FARMING_BACKGROUND_SCAN_ITEMS_PER_TICK,
    },
    {
        id = RARE_FARMING_SCAN_MODE_FOREGROUND_ID,
        label = "Foreground",
        batchSize = RARE_FARMING_FOREGROUND_SCAN_ITEMS_PER_TICK,
    },
}

local function CreateRareFarmingPanel(parent, bg, border)
    return Theme:CreatePanel(parent, bg, border)
end

local function CreateRareFarmingButton(parent, width, height, text, paletteKey)
    return Theme:CreateButton(parent, width, height, text, paletteKey)
end

local function SetRareFarmingFrameLevel(frame, referenceFrame, offset)
    if not frame or not referenceFrame or type(frame.SetFrameLevel) ~= "function" or type(referenceFrame.GetFrameLevel) ~= "function" then
        return
    end

    frame:SetFrameLevel((referenceFrame:GetFrameLevel() or 0) + (offset or 1))
end

local function CreateRareFarmingHeaderButton(parent, label, width, justifyH)
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
    sortIcon:SetSize(RARE_FARMING_SORT_ICON_SIZE, RARE_FARMING_SORT_ICON_SIZE)
    sortIcon:SetPoint("RIGHT", button, "RIGHT", 0, 0)
    sortIcon:Hide()
    button.sortIcon = sortIcon

    return button
end

local function BuildRareFarmingWowheadItemURL(itemID)
    local normalizedItemID = tonumber(itemID)
    if not normalizedItemID then
        return ""
    end
    return string.format("https://www.wowhead.com/item=%d", math.floor(normalizedItemID + 0.5))
end

local function BuildRareFarmingWowheadNpcURL(npcID)
    local normalizedNpcID = tonumber(npcID)
    if not normalizedNpcID then
        return ""
    end
    return string.format("https://www.wowhead.com/npc=%d", math.floor(normalizedNpcID + 0.5))
end

local function ReadRareFarmingMinimumValueCopper(addon, editBox)
    local rawText = editBox and editBox:GetText() or ""
    rawText = tostring(rawText or ""):gsub(",", ".")
    local goldValue = tonumber(rawText)
    if not goldValue or goldValue < 0 then
        goldValue = 0
    end
    return math.max(0, math.floor((goldValue * addon.COPPER_PER_GOLD) + 0.5))
end

local function FormatRareFarmingGoldInput(addon, copperValue)
    local normalizedCopper = math.max(0, math.floor(tonumber(copperValue) or 0))
    if normalizedCopper % addon.COPPER_PER_GOLD == 0 then
        return tostring(normalizedCopper / addon.COPPER_PER_GOLD)
    end
    return string.format("%.2f", normalizedCopper / addon.COPPER_PER_GOLD)
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

local RequestRareFarmingItemData

local function ApplyRareFarmingItemDisplayDataToRow(row, itemID)
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

local function EnsureRareFarmingRowItemDisplayData(addon, row)
    local itemID = tonumber(row and row.itemID)
    if not itemID then
        return false
    end
    local changed = ApplyRareFarmingItemDisplayDataToRow(row, itemID)
    if (not row.itemName or not row.itemLink) and not row.dataRequested then
        row.dataRequested = true
        RequestRareFarmingItemData(addon, itemID)
    end
    return changed
end

local function GetRareFarmingTSMValue(addon, priceSource, itemID)
    if type(priceSource) ~= "string" or priceSource == "" then
        return 0
    end
    if type(addon.GetTSMItemValueForItemID) ~= "function" then
        return 0
    end
    return addon:GetTSMItemValueForItemID(priceSource, itemID, true) or 0
end

local function GetRareFarmingPriceSnapshot(addon, itemID, valueSource)
    local selectedValue = 0
    if valueSource and valueSource.tsmKey then
        selectedValue = GetRareFarmingTSMValue(addon, valueSource.tsmKey, itemID)
    end

    return {
        value = selectedValue,
        marketValue = GetRareFarmingTSMValue(addon, "DBMarket", itemID),
        regionMarketValue = GetRareFarmingTSMValue(addon, "DBRegionMarketAvg", itemID),
        averageValue = GetRareFarmingTSMValue(addon, "DBRegionSaleAvg", itemID),
    }
end

local function GetRareFarmingFavoriteKey(rowOrNpcID, itemID)
    if GoldTracker and type(GoldTracker.GetFarmingFavoriteKey) == "function" then
        if type(rowOrNpcID) == "table" then
            return GoldTracker:GetFarmingFavoriteKey(rowOrNpcID)
        end
        return GoldTracker:GetFarmingFavoriteKey(itemID or rowOrNpcID)
    end
    local normalizedItemID = tonumber(type(rowOrNpcID) == "table" and rowOrNpcID.itemID or (itemID or rowOrNpcID))
    if not normalizedItemID then
        return nil
    end
    return "item:" .. tostring(math.floor(normalizedItemID + 0.5))
end

local function SetRareFarmingItemTooltip(row)
    local itemLink = type(row.itemLink) == "string" and row.itemLink ~= "" and row.itemLink or nil
    local itemID = tonumber(row.itemID)
    if not itemLink and not itemID then
        return false
    end

    GameTooltip:SetOwner(row, "ANCHOR_CURSOR")
    GameTooltip:ClearLines()
    if itemLink then
        GameTooltip:SetHyperlink(itemLink)
    elseif itemID then
        if type(GameTooltip.SetItemByID) == "function" then
            GameTooltip:SetItemByID(itemID)
        else
            GameTooltip:SetHyperlink("item:" .. tostring(math.floor(itemID + 0.5)))
        end
    end

    if GameTooltip:NumLines() == 0 and itemID then
        GameTooltip:AddLine("Item " .. tostring(math.floor(itemID + 0.5)), 1, 1, 1)
    end
    GameTooltip:AddLine(" ")
    GameTooltip:AddDoubleLine("Rare", row.rareName or tostring(row.npcID), 0.72, 0.86, 1.0, 1, 1, 1)
    GameTooltip:AddDoubleLine("Location", row.locationLabel or "Unknown", 0.72, 0.86, 1.0, 1, 1, 1)
    GameTooltip:Show()
    return true
end

local function GetBindOnAcquireValue()
    return LE_ITEM_BIND_ON_ACQUIRE or 1
end

local function GetQuestBindValue()
    return LE_ITEM_BIND_QUEST or 4
end

local function IsRareFarmingBindRestricted(bindType)
    local normalizedBindType = tonumber(bindType)
    if not normalizedBindType then
        return false
    end

    return normalizedBindType == GetBindOnAcquireValue() or normalizedBindType == GetQuestBindValue()
end

local function FormatRareFarmingCoord(value)
    local normalizedValue = tonumber(value)
    if not normalizedValue then
        return nil
    end
    if normalizedValue > 0 and normalizedValue <= 1 then
        return string.format("%.1f", normalizedValue * 100)
    end
    return string.format("%.1f", normalizedValue / 100)
end

local mapNameCache = {}
local mapIDByNameCache = {}
local function GetRareFarmingMapName(mapID)
    local normalizedMapID = tonumber(mapID)
    if not normalizedMapID or normalizedMapID <= 0 then
        return nil
    end
    if mapNameCache[normalizedMapID] ~= nil then
        return mapNameCache[normalizedMapID]
    end

    local mapInfo = C_Map and C_Map.GetMapInfo and C_Map.GetMapInfo(normalizedMapID)
    local mapName = mapInfo and mapInfo.name or nil
    if type(mapName) ~= "string" or mapName == "" then
        mapName = tostring(normalizedMapID)
    end
    mapNameCache[normalizedMapID] = mapName
    return mapName
end

local function NormalizeRareFarmingMapName(mapName)
    if type(mapName) ~= "string" then
        return nil
    end

    local normalizedName = mapName:gsub("^%s+", ""):gsub("%s+$", "")
    if normalizedName == "" then
        return nil
    end
    return string.lower(normalizedName)
end

local function TryMatchRareFarmingMapName(targetName, mapID)
    local normalizedMapID = tonumber(mapID)
    if not normalizedMapID then
        return nil
    end

    local mapName = GetRareFarmingMapName(normalizedMapID)
    if NormalizeRareFarmingMapName(mapName) == targetName then
        return normalizedMapID
    end
    return nil
end

local function GetRareFarmingMapIDByName(mapName)
    local normalizedName = NormalizeRareFarmingMapName(mapName)
    if not normalizedName then
        return nil
    end
    if mapIDByNameCache[normalizedName] ~= nil then
        return mapIDByNameCache[normalizedName] or nil
    end

    local rareDropsData = NS.RareDropsData
    local expansionData = type(rareDropsData) == "table" and rareDropsData.expansions or nil
    if type(expansionData) == "table" then
        if type(expansionData.mapToExpansionID) == "table" then
            for mapID in pairs(expansionData.mapToExpansionID) do
                local matchedMapID = TryMatchRareFarmingMapName(normalizedName, mapID)
                if matchedMapID then
                    mapIDByNameCache[normalizedName] = matchedMapID
                    return matchedMapID
                end
            end
        end

        if type(expansionData.options) == "table" then
            for _, option in ipairs(expansionData.options) do
                local matchedMapID = TryMatchRareFarmingMapName(normalizedName, option and option.continentMapID)
                if matchedMapID then
                    mapIDByNameCache[normalizedName] = matchedMapID
                    return matchedMapID
                end

                if type(option and option.zones) == "table" then
                    for _, mapID in ipairs(option.zones) do
                        matchedMapID = TryMatchRareFarmingMapName(normalizedName, mapID)
                        if matchedMapID then
                            mapIDByNameCache[normalizedName] = matchedMapID
                            return matchedMapID
                        end
                    end
                end
            end
        end
    end

    if type(rareDropsData) == "table" and type(rareDropsData.rares) == "table" then
        for _, rareData in pairs(rareDropsData.rares) do
            if type(rareData) == "table" and type(rareData.locations) == "table" then
                for _, location in ipairs(rareData.locations) do
                    local matchedMapID = TryMatchRareFarmingMapName(normalizedName, location and location.mapID)
                    if matchedMapID then
                        mapIDByNameCache[normalizedName] = matchedMapID
                        return matchedMapID
                    end
                end
            end
        end
    end

    mapIDByNameCache[normalizedName] = false
    return nil
end

local function BuildRareFarmingLocationLabel(locations)
    if type(locations) ~= "table" or #locations == 0 then
        return "Unknown"
    end

    local labels = {}
    local seen = {}
    for _, location in ipairs(locations) do
        local mapName = GetRareFarmingMapName(location and location.mapID)
        if mapName and not seen[mapName] then
            local label = mapName
            local x = FormatRareFarmingCoord(location.x)
            local y = FormatRareFarmingCoord(location.y)
            if x and y then
                label = string.format("%s %s,%s", mapName, x, y)
            end
            labels[#labels + 1] = label
            seen[mapName] = true
        end
    end

    if #labels == 0 then
        return "Unknown"
    end
    if #labels == 1 then
        return labels[1]
    end
    return string.format("%s +%d", labels[1], #labels - 1)
end

local function CloneRareFarmingLocations(locations)
    local cloned = {}
    if type(locations) ~= "table" then
        return cloned
    end

    for _, location in ipairs(locations) do
        if type(location) == "table" then
            cloned[#cloned + 1] = {
                mapID = tonumber(location.mapID),
                x = tonumber(location.x),
                y = tonumber(location.y),
            }
        end
    end
    return cloned
end

local function BuildRareFarmingSource(npcID, rareName, locations, locationLabel)
    local normalizedNpcID = tonumber(npcID)
    local clonedLocations = CloneRareFarmingLocations(locations)
    return {
        npcID = normalizedNpcID and math.floor(normalizedNpcID + 0.5) or nil,
        rareName = rareName or (normalizedNpcID and tostring(math.floor(normalizedNpcID + 0.5))) or "Unknown rare",
        locationLabel = locationLabel or BuildRareFarmingLocationLabel(clonedLocations),
        locations = clonedLocations,
    }
end

local function BuildRareFarmingSourceFromRow(row)
    if type(row) ~= "table" then
        return nil
    end
    if type(row.rareSources) == "table" and #row.rareSources > 0 then
        return nil
    end
    return BuildRareFarmingSource(row.npcID, row.rareName, row.locations, row.locationLabel)
end

local function GetRareFarmingSourceKey(source)
    if type(source) ~= "table" then
        return nil
    end
    local firstLocation = type(source.locations) == "table" and source.locations[1] or nil
    return table.concat({
        tostring(source.npcID or ""),
        tostring(source.rareName or ""),
        tostring(firstLocation and firstLocation.mapID or ""),
        tostring(firstLocation and firstLocation.x or ""),
        tostring(firstLocation and firstLocation.y or ""),
        tostring(source.locationLabel or ""),
    }, "|")
end

local function AddRareFarmingSourceToRow(row, source)
    if type(row) ~= "table" or type(source) ~= "table" then
        return false
    end

    if type(row.rareSources) ~= "table" then
        row.rareSources = {}
    end
    if type(row.rareSourceKeys) ~= "table" then
        row.rareSourceKeys = {}
    end

    local sourceKey = GetRareFarmingSourceKey(source)
    if sourceKey and row.rareSourceKeys[sourceKey] then
        return false
    end
    if sourceKey then
        row.rareSourceKeys[sourceKey] = true
    end

    row.rareSources[#row.rareSources + 1] = source
    local sourceCount = #row.rareSources
    if sourceCount == 1 then
        row.npcID = source.npcID
        row.rareName = source.rareName
        row.locationLabel = source.locationLabel
        row.locations = source.locations
    else
        row.npcID = nil
        row.rareName = string.format("%d rares", sourceCount)
        row.locationLabel = string.format("%d locations", sourceCount)
        row.locations = nil
    end
    row.rareSourceCount = sourceCount
    return true
end

local function GetRareFarmingResultItemKey(rowOrItemID)
    local itemID = tonumber(type(rowOrItemID) == "table" and rowOrItemID.itemID or rowOrItemID)
    if not itemID then
        return nil
    end
    return tostring(math.floor(itemID + 0.5))
end

local function CloneRareFarmingSources(sources)
    local cloned = {}
    if type(sources) ~= "table" then
        return cloned
    end
    for _, source in ipairs(sources) do
        if type(source) == "table" then
            cloned[#cloned + 1] = BuildRareFarmingSource(
                source.npcID,
                source.rareName,
                source.locations,
                source.locationLabel
            )
        end
    end
    return cloned
end

local function BuildRareFarmingGroupedRows(rows)
    local groupedRows = {}
    local rowsByItemID = {}

    for _, row in ipairs(rows or {}) do
        if type(row) == "table" then
            local itemKey = GetRareFarmingResultItemKey(row)
            if itemKey then
                local grouped = rowsByItemID[itemKey]
                if not grouped then
                    grouped = row
                    grouped.rareSources = CloneRareFarmingSources(row.rareSources)
                    grouped.rareSourceKeys = {}
                    local existingSources = grouped.rareSources
                    grouped.rareSources = {}
                    if #existingSources > 0 then
                        for _, source in ipairs(existingSources) do
                            AddRareFarmingSourceToRow(grouped, source)
                        end
                    else
                        AddRareFarmingSourceToRow(grouped, BuildRareFarmingSourceFromRow(row))
                    end
                    rowsByItemID[itemKey] = grouped
                    groupedRows[#groupedRows + 1] = grouped
                elseif type(row.rareSources) == "table" and #row.rareSources > 0 then
                    for _, source in ipairs(row.rareSources) do
                        AddRareFarmingSourceToRow(grouped, BuildRareFarmingSource(
                            source.npcID,
                            source.rareName,
                            source.locations,
                            source.locationLabel
                        ))
                    end
                else
                    AddRareFarmingSourceToRow(grouped, BuildRareFarmingSourceFromRow(row))
                end
            end
        end
    end

    for _, row in ipairs(groupedRows) do
        row.rareSourceKeys = nil
    end
    return groupedRows
end

function GoldTracker:BuildRareFarmingGroupedRows(rows)
    return BuildRareFarmingGroupedRows(rows)
end

local function NormalizeRareFarmingWaypointCoord(value)
    local normalizedValue = tonumber(value)
    if not normalizedValue then
        return nil
    end
    if normalizedValue >= 0 and normalizedValue <= 1 then
        return normalizedValue
    end
    if normalizedValue > 1 and normalizedValue <= 100 then
        return normalizedValue / 100
    end
    return normalizedValue / 10000
end

local function GetRareFarmingSnapshotLocations(npcID)
    local normalizedNpcID = tonumber(npcID)
    local rareDropsData = NS.RareDropsData
    local rareData = type(rareDropsData) == "table"
        and type(rareDropsData.rares) == "table"
        and rareDropsData.rares[normalizedNpcID]
        or nil

    if type(rareData) == "table" and type(rareData.locations) == "table" and #rareData.locations > 0 then
        return rareData.locations
    end
    return nil
end

local function GetRareFarmingWaypointFromLocationLabel(locationLabel)
    if type(locationLabel) ~= "string" or locationLabel == "" then
        return nil
    end

    local mapName, xText, yText = locationLabel:match("^%s*(.-)%s+([%d%.]+)%s*,%s*([%d%.]+)")
    local mapID = GetRareFarmingMapIDByName(mapName)
    local x = tonumber(xText)
    local y = tonumber(yText)
    if not mapID or not x or not y then
        return nil
    end

    x = x / 100
    y = y / 100
    if x >= 0 and x <= 1 and y >= 0 and y <= 1 then
        return mapID, x, y
    end
    return nil
end

local function GetRareFarmingFirstWaypointLocation(row)
    local locations = row and row.locations
    if (type(locations) ~= "table" or #locations == 0)
        and type(row and row.rareSources) == "table"
        and type(row.rareSources[1]) == "table" then
        locations = row.rareSources[1].locations
    end
    if (type(locations) ~= "table" or #locations == 0) and row and row.npcID then
        locations = GetRareFarmingSnapshotLocations(row.npcID)
        if type(locations) == "table" and #locations > 0 then
            row.locations = locations
            if not row.locationLabel or row.locationLabel == "" or row.locationLabel == "Unknown" then
                row.locationLabel = BuildRareFarmingLocationLabel(locations)
            end
        end
    end

    if type(locations) ~= "table" then
        return GetRareFarmingWaypointFromLocationLabel(row and row.locationLabel)
    end

    for _, location in ipairs(locations) do
        local mapID = tonumber(location and location.mapID)
        local x = NormalizeRareFarmingWaypointCoord(location and location.x)
        local y = NormalizeRareFarmingWaypointCoord(location and location.y)
        if mapID and x and y and x >= 0 and x <= 1 and y >= 0 and y <= 1 then
            return mapID, x, y
        end
    end
    return GetRareFarmingWaypointFromLocationLabel(row and row.locationLabel)
end

local function AddRareFarmingMapLocationOption(options, byMapID, itemLabel, source, location)
    local mapID = tonumber(location and location.mapID)
    local x = NormalizeRareFarmingWaypointCoord(location and location.x)
    local y = NormalizeRareFarmingWaypointCoord(location and location.y)
    if not mapID or not x or not y or x < 0 or x > 1 or y < 0 or y > 1 then
        return false
    end

    local option = byMapID[mapID]
    if not option then
        option = {
            mapID = mapID,
            label = GetRareFarmingMapName(mapID) or ("Map " .. tostring(mapID)),
            pins = {},
            spotCount = 0,
        }
        byMapID[mapID] = option
        options[#options + 1] = option
    end

    local rareLabel = source and source.rareName or nil
    local npcID = tonumber(source and source.npcID)
    option.pins[#option.pins + 1] = {
        mapID = mapID,
        x = x,
        y = y,
        label = rareLabel or itemLabel or "Rare",
        spotLocation = source and source.locationLabel or itemLabel,
        routeType = "Rare drop",
        sourceUrls = npcID and { BuildRareFarmingWowheadNpcURL(npcID) } or nil,
    }
    option.spotCount = option.spotCount + 1
    return true
end

local function AddRareFarmingMapLocations(options, byMapID, itemLabel, source)
    if type(source) ~= "table" or type(source.locations) ~= "table" then
        return
    end

    for _, location in ipairs(source.locations) do
        AddRareFarmingMapLocationOption(options, byMapID, itemLabel, source, location)
    end
end

local function BuildRareFarmingMapOptionsFromRow(row)
    if type(row) ~= "table" then
        return {}
    end

    local options = {}
    local byMapID = {}
    local itemLabel = row.itemName or row.itemLink or (row.itemID and ("Item " .. tostring(row.itemID))) or "Rare drop"
    if type(row.rareSources) == "table" and #row.rareSources > 0 then
        for _, source in ipairs(row.rareSources) do
            AddRareFarmingMapLocations(options, byMapID, itemLabel, source)
        end
    else
        AddRareFarmingMapLocations(options, byMapID, itemLabel, BuildRareFarmingSourceFromRow(row))
    end

    if #options == 0 then
        local mapID, x, y = GetRareFarmingFirstWaypointLocation(row)
        if mapID and x and y then
            AddRareFarmingMapLocationOption(options, byMapID, itemLabel, {
                rareName = row.rareName,
                locationLabel = row.locationLabel,
            }, {
                mapID = mapID,
                x = x,
                y = y,
            })
        end
    end

    table.sort(options, function(left, right)
        return tostring(left.label or "") < tostring(right.label or "")
    end)
    return options
end

function GoldTracker:BuildRareFarmingMapOptions(row)
    return BuildRareFarmingMapOptionsFromRow(row)
end

local function GetRareScannerRuntimeVersion()
    local rareDropsData = NS.RareDropsData
    if type(rareDropsData) == "table" and rareDropsData.sourceVersion then
        return rareDropsData.sourceVersion
    end

    if type(C_AddOns) == "table" and type(C_AddOns.GetAddOnMetadata) == "function" then
        local ok, version = pcall(C_AddOns.GetAddOnMetadata, "RareScanner", "Version")
        if ok and version then
            return version
        end
    end
    if type(GetAddOnMetadata) == "function" then
        local ok, version = pcall(GetAddOnMetadata, "RareScanner", "Version")
        if ok and version then
            return version
        end
    end
    return "unknown"
end

local function BuildRareFarmingExpansionData()
    local rareDropsData = NS.RareDropsData
    if type(rareDropsData) == "table" and type(rareDropsData.expansions) == "table" then
        return rareDropsData.expansions
    end

    local label = GetRareFarmingMapName(RARE_FARMING_CURRENT_EXPANSION_LABEL_MAP_ID)
        or "Current expansion"
    local expansionData = {
        currentID = RARE_FARMING_CURRENT_EXPANSION_ID,
        options = {
            {
                id = RARE_FARMING_CURRENT_EXPANSION_ID,
                label = label,
                continentMapID = RARE_FARMING_CURRENT_EXPANSION_LABEL_MAP_ID,
                current = true,
                zones = {},
            },
        },
        mapToExpansionID = {},
    }

    for mapID in pairs(RARE_FARMING_CURRENT_EXPANSION_MAP_IDS) do
        expansionData.mapToExpansionID[mapID] = RARE_FARMING_CURRENT_EXPANSION_ID
        expansionData.options[1].zones[#expansionData.options[1].zones + 1] = mapID
    end
    table.sort(expansionData.options[1].zones)

    return expansionData
end

local function RareFarmingHasKnownLocation(rare)
    local locations = rare and rare.locations or nil
    if type(locations) ~= "table" or #locations == 0 then
        return false
    end
    for _, location in ipairs(locations) do
        if tonumber(location and location.mapID) then
            return true
        end
    end
    return false
end

local function IsRareFarmingScanStateActive(state)
    return type(state) == "table"
        and state.cancelled ~= true
        and type(state.rareIDs) == "table"
        and tonumber(state.rareIndex)
        and state.rareIndex <= #state.rareIDs
end

local function NormalizeRareFarmingScanMode(modeID)
    for _, option in ipairs(RARE_FARMING_SCAN_MODE_OPTIONS) do
        if modeID == option.id then
            return option.id
        end
    end
    return RARE_FARMING_SCAN_MODE_BACKGROUND_ID
end

local function GetRareFarmingScanModeOption(modeID)
    local normalizedModeID = NormalizeRareFarmingScanMode(modeID)
    for _, option in ipairs(RARE_FARMING_SCAN_MODE_OPTIONS) do
        if option.id == normalizedModeID then
            return option
        end
    end
    return RARE_FARMING_SCAN_MODE_OPTIONS[1]
end

local function GetRareFarmingExpansionByID(expansionID)
    local normalizedExpansionID = tonumber(expansionID)
    if not normalizedExpansionID then
        return nil
    end

    local expansions = BuildRareFarmingExpansionData()
    if type(expansions) ~= "table" or type(expansions.options) ~= "table" then
        return nil
    end

    for _, expansion in ipairs(expansions.options) do
        if tonumber(expansion and expansion.id) == normalizedExpansionID then
            return expansion
        end
    end
    return nil
end

local function NormalizeRareFarmingExpansionFilter(filterID)
    if filterID == RARE_FARMING_EXPANSION_ALL_ID then
        return RARE_FARMING_EXPANSION_ALL_ID
    end
    if filterID == RARE_FARMING_EXPANSION_CURRENT_ID then
        return RARE_FARMING_EXPANSION_CURRENT_ID
    end

    local expansionID = tonumber(filterID)
    if expansionID and GetRareFarmingExpansionByID(expansionID) then
        return tostring(expansionID)
    end
    return RARE_FARMING_EXPANSION_CURRENT_ID
end

local function GetRareFarmingExpansionFilterLabel(filterID)
    local normalizedFilterID = NormalizeRareFarmingExpansionFilter(filterID)
    if normalizedFilterID == RARE_FARMING_EXPANSION_ALL_ID then
        return "All expansions"
    end

    local expansions = BuildRareFarmingExpansionData()
    if normalizedFilterID == RARE_FARMING_EXPANSION_CURRENT_ID then
        local currentExpansion = expansions and GetRareFarmingExpansionByID(expansions.currentID) or nil
        return currentExpansion and ("Current: " .. currentExpansion.label) or "Current expansion"
    end

    local expansion = GetRareFarmingExpansionByID(normalizedFilterID)
    return expansion and expansion.label or "Current expansion"
end

local function GetRareFarmingExpansionOptions()
    local options = {
        {
            id = RARE_FARMING_EXPANSION_CURRENT_ID,
            label = GetRareFarmingExpansionFilterLabel(RARE_FARMING_EXPANSION_CURRENT_ID),
        },
        {
            id = RARE_FARMING_EXPANSION_ALL_ID,
            label = "All expansions",
        },
    }

    local expansions = BuildRareFarmingExpansionData()
    if type(expansions) == "table" and type(expansions.options) == "table" then
        local expansionOptions = {}
        for _, expansion in ipairs(expansions.options) do
            if type(expansion) == "table"
                and tonumber(expansion.id)
                and tonumber(expansion.id) ~= tonumber(expansions.currentID)
                and type(expansion.label) == "string" then
                expansionOptions[#expansionOptions + 1] = {
                    id = tostring(expansion.id),
                    label = expansion.label,
                }
            end
        end
        table.sort(expansionOptions, function(left, right)
            return (tonumber(left.id) or 0) > (tonumber(right.id) or 0)
        end)
        for _, expansion in ipairs(expansionOptions) do
            options[#options + 1] = expansion
        end
    end

    return options
end

local function GetRareFarmingExpansionFilterOption(filterID)
    local normalizedFilterID = NormalizeRareFarmingExpansionFilter(filterID)
    for _, option in ipairs(GetRareFarmingExpansionOptions()) do
        if option.id == normalizedFilterID then
            return option
        end
    end
    return {
        id = RARE_FARMING_EXPANSION_CURRENT_ID,
        label = GetRareFarmingExpansionFilterLabel(RARE_FARMING_EXPANSION_CURRENT_ID),
    }
end

local function GetRareFarmingLocationExpansionID(location)
    local mapID = tonumber(location and location.mapID)
    local expansions = BuildRareFarmingExpansionData()
    local mapToExpansionID = expansions and expansions.mapToExpansionID or nil
    if not mapID or type(mapToExpansionID) ~= "table" then
        return nil
    end
    return tonumber(mapToExpansionID[mapID])
end

local function RareFarmingRareMatchesExpansion(rare, filterID)
    local normalizedFilterID = NormalizeRareFarmingExpansionFilter(filterID)
    if normalizedFilterID == RARE_FARMING_EXPANSION_ALL_ID then
        return true
    end

    local expansions = BuildRareFarmingExpansionData()
    local targetExpansionID
    if normalizedFilterID == RARE_FARMING_EXPANSION_CURRENT_ID then
        targetExpansionID = tonumber(expansions and expansions.currentID)
    else
        targetExpansionID = tonumber(normalizedFilterID)
    end
    if not targetExpansionID then
        return true
    end

    if not RareFarmingHasKnownLocation(rare) then
        return true
    end

    local locations = rare and rare.locations or nil
    if type(locations) ~= "table" or #locations == 0 then
        return false
    end
    for _, location in ipairs(locations) do
        if GetRareFarmingLocationExpansionID(location) == targetExpansionID then
            return true
        end
    end
    return false
end

local function NormalizeRareFarmingSortKey(sortKey)
    if RARE_FARMING_SORT_KEYS[sortKey] then
        return sortKey
    end
    return RARE_FARMING_SORT_KEY_DEFAULT
end

local function GetRareFarmingSortValue(row, sortKey)
    if sortKey == "favorite" then
        return row and row.favorite and 1 or 0
    end
    if sortKey == "location" then
        return string.lower(tostring(row and row.locationLabel or ""))
    end
    if sortKey == "rareName" then
        return string.lower(tostring(row and row.rareName or ""))
    end
    if sortKey == "itemName" then
        return string.lower(tostring(row and (row.itemName or row.itemLink or row.itemID) or ""))
    end
    if sortKey == "marketValue" then
        return tonumber(row and row.marketValue) or 0
    end
    if sortKey == "regionMarketValue" then
        return tonumber(row and row.regionMarketValue) or 0
    end
    if sortKey == "averageValue" then
        return tonumber(row and row.averageValue) or 0
    end
    return tonumber(row and row.value) or 0
end

local function CompareRareFarmingRowsByItem(left, right)
    local leftName = string.lower(tostring(left and (left.itemName or left.itemLink or left.itemID) or ""))
    local rightName = string.lower(tostring(right and (right.itemName or right.itemLink or right.itemID) or ""))
    if leftName ~= rightName then
        return leftName < rightName
    end

    return (tonumber(left and left.itemID) or 0) < (tonumber(right and right.itemID) or 0)
end

local function SortRareFarmingRows(rows, sortKey, sortAscending)
    local normalizedSortKey = NormalizeRareFarmingSortKey(sortKey)
    local ascending = sortAscending == true

    table.sort(rows, function(left, right)
        local leftValue = GetRareFarmingSortValue(left, normalizedSortKey)
        local rightValue = GetRareFarmingSortValue(right, normalizedSortKey)
        if leftValue ~= rightValue then
            if ascending then
                return leftValue < rightValue
            end
            return leftValue > rightValue
        end

        if normalizedSortKey ~= "value" then
            local leftGold = tonumber(left and left.value) or 0
            local rightGold = tonumber(right and right.value) or 0
            if leftGold ~= rightGold then
                return leftGold > rightGold
            end
        end

        return CompareRareFarmingRowsByItem(left, right)
    end)
end

local function AddUniqueLoot(loot, seen, itemID)
    local normalizedItemID = tonumber(itemID)
    if not normalizedItemID or seen[normalizedItemID] then
        return
    end

    seen[normalizedItemID] = true
    loot[#loot + 1] = math.floor(normalizedItemID + 0.5)
end

local function GetRareScannerSavedVariableGlobal()
    if type(RareScannerDB) == "table"
        and type(RareScannerDB.global) == "table" then
        return RareScannerDB.global
    end
    return nil
end

local function GetRuntimeRareScannerName(npcID)
    local globalDB = GetRareScannerSavedVariableGlobal()
    local namesByLocale = globalDB
        and type(globalDB.rare_names) == "table"
        and globalDB.rare_names[GetLocale()]
        or nil
    local npcName = namesByLocale and namesByLocale[npcID]
    if type(npcName) == "string" and npcName ~= "" then
        return npcName
    end
    return nil
end

local function AddRareFarmingLocation(locations, mapID, x, y)
    local normalizedMapID = tonumber(mapID)
    if not normalizedMapID or normalizedMapID <= 0 then
        return
    end

    local normalizedX = tonumber(x)
    local normalizedY = tonumber(y)
    for _, location in ipairs(locations) do
        if location.mapID == normalizedMapID
            and location.x == normalizedX
            and location.y == normalizedY then
            return
        end
    end

    locations[#locations + 1] = {
        mapID = normalizedMapID,
        x = normalizedX,
        y = normalizedY,
    }
end

local function BuildRuntimeRareScannerLocations(npcID)
    local globalDB = GetRareScannerSavedVariableGlobal()
    local customNpc = globalDB
        and type(globalDB.custom_npcs) == "table"
        and globalDB.custom_npcs[npcID]
        or nil
    if type(customNpc) ~= "table" then
        return nil
    end

    local locations = {}
    if type(customNpc.zoneID) == "table" then
        for mapID, zoneInfo in pairs(customNpc.zoneID) do
            if tonumber(mapID) then
                locations[#locations + 1] = {
                    mapID = tonumber(mapID),
                    x = tonumber(zoneInfo and zoneInfo.x),
                    y = tonumber(zoneInfo and zoneInfo.y),
                }
            end
        end
    elseif tonumber(customNpc.zoneID) and tonumber(customNpc.zoneID) > 0 then
        locations[#locations + 1] = {
            mapID = tonumber(customNpc.zoneID),
            x = tonumber(customNpc.x),
            y = tonumber(customNpc.y),
        }
    end

    return #locations > 0 and locations or nil
end

local function BuildFoundRareScannerLocations(npcID)
    local globalDB = GetRareScannerSavedVariableGlobal()
    local foundRare = globalDB
        and type(globalDB.rares_found) == "table"
        and globalDB.rares_found[npcID]
        or nil
    if type(foundRare) ~= "table" then
        return nil
    end

    local locations = {}
    AddRareFarmingLocation(locations, foundRare.mapID, foundRare.coordX, foundRare.coordY)
    return #locations > 0 and locations or nil
end

local function EnsureRareFarmingRare(rares, npcID)
    local normalizedNpcID = tonumber(npcID)
    if not normalizedNpcID then
        return nil
    end

    local rare = rares[normalizedNpcID]
    if rare then
        return rare
    end

    rare = {
        npcID = normalizedNpcID,
        name = GetRuntimeRareScannerName(normalizedNpcID) or tostring(normalizedNpcID),
        locations = BuildRuntimeRareScannerLocations(normalizedNpcID)
            or BuildFoundRareScannerLocations(normalizedNpcID)
            or {},
        loot = {},
        seenLoot = {},
    }
    rares[normalizedNpcID] = rare
    return rare
end

local function AddRareFarmingLootList(rare, lootList)
    if type(rare) ~= "table" or type(lootList) ~= "table" then
        return
    end

    for _, itemID in ipairs(lootList) do
        AddUniqueLoot(rare.loot, rare.seenLoot, itemID)
    end
end

local function AddRareScannerCollectionLoot(rares, collectionsLoot)
    local npcCollectionsLoot = type(collectionsLoot) == "table" and collectionsLoot[1] or nil
    if type(npcCollectionsLoot) ~= "table" then
        return 0
    end

    local addedRares = 0
    for npcID, lootByType in pairs(npcCollectionsLoot) do
        if type(lootByType) == "table" then
            local rare = EnsureRareFarmingRare(rares, npcID)
            local beforeCount = rare and #rare.loot or 0
            if rare then
                for _, lootList in pairs(lootByType) do
                    AddRareFarmingLootList(rare, lootList)
                end
                if #rare.loot > beforeCount then
                    addedRares = addedRares + 1
                end
            end
        end
    end
    return addedRares
end

local function BuildRareFarmingRareList(expansionFilterID)
    local normalizedExpansionFilterID = NormalizeRareFarmingExpansionFilter(expansionFilterID)
    local rares = {}
    local rareDropsData = NS.RareDropsData
    if type(rareDropsData) == "table" and type(rareDropsData.rares) == "table" then
        for npcID, rareData in pairs(rareDropsData.rares) do
            local normalizedNpcID = tonumber(npcID)
            if normalizedNpcID
                and type(rareData) == "table"
                and type(rareData.loot) == "table"
                and #rareData.loot > 0 then
                local rare = EnsureRareFarmingRare(rares, normalizedNpcID)
                rare.name = rareData.name or rare.name
                rare.locations = rareData.locations or rare.locations or {}
                AddRareFarmingLootList(rare, rareData.loot)
            end
        end
    end

    local globalDB = GetRareScannerSavedVariableGlobal()

    AddRareScannerCollectionLoot(
        rares,
        globalDB and globalDB.entity_collections_loot or nil
    )

    local runtimeLootSources = {}
    if globalDB and type(globalDB.rares_loot) == "table" then
        runtimeLootSources[#runtimeLootSources + 1] = globalDB.rares_loot
    end
    if globalDB and type(globalDB.custom_loot) == "table" then
        runtimeLootSources[#runtimeLootSources + 1] = globalDB.custom_loot
    end
    for _, runtimeLoot in ipairs(runtimeLootSources) do
        if type(runtimeLoot) == "table" then
            for npcID, lootList in pairs(runtimeLoot) do
                local normalizedNpcID = tonumber(npcID)
                if normalizedNpcID and type(lootList) == "table" then
                    local rare = EnsureRareFarmingRare(rares, normalizedNpcID)
                    rare.name = GetRuntimeRareScannerName(normalizedNpcID) or rare.name
                    if #rare.locations == 0 then
                        rare.locations = BuildRuntimeRareScannerLocations(normalizedNpcID)
                            or BuildFoundRareScannerLocations(normalizedNpcID)
                            or rare.locations
                    end
                    AddRareFarmingLootList(rare, lootList)
                end
            end
        end
    end

    local rareIDs = {}
    local totalDrops = 0
    for npcID, rare in pairs(rares) do
        if type(rare.loot) == "table"
            and #rare.loot > 0
            and RareFarmingRareMatchesExpansion(rare, normalizedExpansionFilterID) then
            rareIDs[#rareIDs + 1] = npcID
            totalDrops = totalDrops + #rare.loot
        end
        rare.seenLoot = nil
    end
    table.sort(rareIDs)

    if totalDrops <= 0 then
        return rares, rareIDs, totalDrops,
            "No rare drop data is available."
    end

    return rares, rareIDs, totalDrops
end

local function IsRareScannerInstalledOrLoaded()
    if type(C_AddOns) == "table" then
        if type(C_AddOns.IsAddOnLoaded) == "function" and C_AddOns.IsAddOnLoaded("RareScanner") then
            return true
        end
        if type(C_AddOns.GetAddOnMetadata) == "function" then
            local ok, title = pcall(C_AddOns.GetAddOnMetadata, "RareScanner", "Title")
            if not ok then
                title = nil
            end
            if title ~= nil then
                return true
            end
        end
    end

    if type(IsAddOnLoaded) == "function" and IsAddOnLoaded("RareScanner") then
        return true
    end
    if type(GetAddOnMetadata) == "function" then
        local ok, title = pcall(GetAddOnMetadata, "RareScanner", "Title")
        if not ok then
            title = nil
        end
        if title ~= nil then
            return true
        end
    end
    return false
end

function RequestRareFarmingItemData(addon, itemID)
    if Item and type(Item.CreateFromItemID) == "function" then
        local item = Item:CreateFromItemID(itemID)
        if item and type(item.ContinueOnItemLoad) == "function" then
            item:ContinueOnItemLoad(function()
                if addon:UpdateRareFarmingItemDisplayData(itemID) then
                    addon:ScheduleRareFarmingWindowRefresh(false)
                end
            end)
            return
        end
    end

    if C_Item and type(C_Item.RequestLoadItemDataByID) == "function" then
        pcall(C_Item.RequestLoadItemDataByID, itemID)
    end
end

function GoldTracker:GetRareFarmingValueSource()
    local source = self.VALUE_SOURCE_BY_ID[self.db and self.db.rareFarmingValueSource]
    if source then
        return source
    end

    return self.VALUE_SOURCE_BY_ID[self.DEFAULTS.rareFarmingValueSource]
        or self:GetCurrentValueSource()
end

function GoldTracker:SetRareFarmingValueSource(sourceID)
    local source = self.VALUE_SOURCE_BY_ID[sourceID] or self:GetRareFarmingValueSource()
    if self.db and source then
        self.db.rareFarmingValueSource = source.id
    end
    if self.rareFarmingFrame and source then
        self.rareFarmingFrame.valueSourceID = source.id
        local hasRows = type(self.rareFarmingFrame.lastResults) == "table" and #self.rareFarmingFrame.lastResults > 0
        local shouldLoadCache = self.rareFarmingFrame.rareFarmingViewID ~= "scan"
            or (
                not hasRows
                and not self.rareFarmingFrame.loadedRareFarmingCacheKey
                and not self.rareFarmingFrame.editingRareFarmingCacheKey
            )
        if shouldLoadCache then
            self:LoadRareFarmingScanCacheForCurrentFilters()
        end
    end
    return source
end

function GoldTracker:GetRareFarmingMinimumValue()
    local value = tonumber(self.db and self.db.rareFarmingMinimumValue) or self.DEFAULTS.rareFarmingMinimumValue
    return math.max(0, math.floor(value + 0.5))
end

function GoldTracker:SetRareFarmingMinimumValue(value)
    local normalizedValue = math.max(0, math.floor((tonumber(value) or 0) + 0.5))
    if self.db then
        self.db.rareFarmingMinimumValue = normalizedValue
    end
    if self.rareFarmingFrame then
        self.rareFarmingFrame.minimumValueCopper = normalizedValue
        if self.rareFarmingFrame.rareFarmingViewID ~= "scan" or not self.rareFarmingFrame.editingRareFarmingCacheKey then
            self:LoadRareFarmingScanCacheForCurrentFilters()
        end
    end
    return normalizedValue
end

function GoldTracker:GetRareFarmingExpansionFilter()
    local filterID = self.db and self.db.rareFarmingExpansionFilter or self.DEFAULTS.rareFarmingExpansionFilter
    return NormalizeRareFarmingExpansionFilter(filterID)
end

function GoldTracker:SetRareFarmingExpansionFilter(filterID)
    local normalizedFilterID = NormalizeRareFarmingExpansionFilter(filterID)
    if self.db then
        self.db.rareFarmingExpansionFilter = normalizedFilterID
    end
    if self.rareFarmingFrame then
        self.rareFarmingFrame.expansionFilterID = normalizedFilterID
        if self.rareFarmingFrame.rareFarmingViewID ~= "scan" or not self.rareFarmingFrame.editingRareFarmingCacheKey then
            self:LoadRareFarmingScanCacheForCurrentFilters()
        end
    end
    return normalizedFilterID
end

function GoldTracker:GetRareFarmingScanMode()
    local modeID = self.db and self.db.rareFarmingScanMode or self.DEFAULTS.rareFarmingScanMode
    return NormalizeRareFarmingScanMode(modeID)
end

function GoldTracker:SetRareFarmingScanMode(modeID)
    local normalizedModeID = NormalizeRareFarmingScanMode(modeID)
    local scanModeOption = GetRareFarmingScanModeOption(normalizedModeID)
    if self.db then
        self.db.rareFarmingScanMode = normalizedModeID
    end
    if self.rareFarmingFrame then
        self.rareFarmingFrame.scanModeID = normalizedModeID
        if IsRareFarmingScanStateActive(self.rareFarmingFrame.scanState) then
            self.rareFarmingFrame.scanState.scanModeID = scanModeOption.id
            self.rareFarmingFrame.scanState.scanModeLabel = scanModeOption.label
            self.rareFarmingFrame.scanState.scanBatchSize = scanModeOption.batchSize
        end
    end
    return normalizedModeID
end

function GoldTracker:SaveRareFarmingMinimumValueInput(skipRefresh)
    local frame = self.rareFarmingFrame
    if not frame or not frame.minimumValueInput then
        return
    end

    local minimumValue = ReadRareFarmingMinimumValueCopper(self, frame.minimumValueInput)
    self:SetRareFarmingMinimumValue(minimumValue)
    frame.minimumValueInput:SetText(FormatRareFarmingGoldInput(self, minimumValue))
    if skipRefresh ~= true and not IsRareFarmingScanStateActive(frame.scanState) then
        self:RefreshRareFarmingWindow(true)
    end
end

function GoldTracker:UpdateRareFarmingItemDisplayData(itemID)
    local frame = self.rareFarmingFrame
    local state = frame and frame.scanState
    if type(state) ~= "table" or type(state.itemCache) ~= "table" then
        return false
    end

    local normalizedItemID = tonumber(itemID)
    local cache = normalizedItemID and state.itemCache[normalizedItemID] or nil
    if not cache then
        return false
    end

    local itemName, itemLink, itemQuality, _, _, _, _, _, itemEquipLoc, itemIcon, _, itemClassID, itemSubclassID, bindType =
        GetItemInfoByID(normalizedItemID)
    if not itemName then
        local _, instantItemType, instantItemSubType, instantItemEquipLoc, instantIcon, instantClassID, instantSubclassID =
            GetItemInstantInfoByID(normalizedItemID)
        itemEquipLoc = itemEquipLoc or instantItemEquipLoc
        itemIcon = itemIcon or instantIcon
        itemClassID = itemClassID or instantClassID
        itemSubclassID = itemSubclassID or instantSubclassID
    end

    cache.itemName = itemName or cache.itemName
    cache.itemLink = itemLink or cache.itemLink
    cache.itemQuality = tonumber(itemQuality) or cache.itemQuality
    cache.itemEquipLoc = itemEquipLoc or cache.itemEquipLoc
    cache.icon = itemIcon or cache.icon
    cache.itemClassID = tonumber(itemClassID) or cache.itemClassID
    cache.itemSubclassID = tonumber(itemSubclassID) or cache.itemSubclassID
    cache.bindType = tonumber(bindType) or cache.bindType
    cache.dataRequested = false

    if IsRareFarmingBindRestricted(cache.bindType) then
        cache.auctionable = false
        self:RemoveRareFarmingResultsForItem(normalizedItemID)
    elseif itemName or itemLink or itemIcon then
        cache.auctionable = true
    end
    return true
end

function GoldTracker:UpdateRareFarmingCachedRowItemDisplayData(itemID)
    local normalizedItemID = tonumber(itemID)
    if not normalizedItemID then
        return false
    end
    normalizedItemID = math.floor(normalizedItemID + 0.5)

    local changed = false
    local function UpdateRows(rows)
        if type(rows) ~= "table" then
            return
        end
        for _, row in ipairs(rows) do
            if tonumber(row and row.itemID) == normalizedItemID then
                changed = ApplyRareFarmingItemDisplayDataToRow(row, normalizedItemID) or changed
            end
        end
    end

    local frame = self.rareFarmingFrame
    if frame then
        UpdateRows(frame.lastResults)
        if type(frame.loadedRareFarmingCache) == "table" then
            UpdateRows(frame.loadedRareFarmingCache.results)
        end
    end
    local favorites = type(self.GetFarmingFavoriteStore) == "function" and self:GetFarmingFavoriteStore()
        or (type(self.db) == "table" and self.db.rareFarmingFavorites or nil)
    if type(favorites) == "table" then
        for _, favorite in pairs(favorites) do
            if tonumber(favorite and favorite.itemID) == normalizedItemID then
                changed = ApplyRareFarmingItemDisplayDataToRow(favorite, normalizedItemID) or changed
            end
        end
    end
    if type(self.db) == "table" and type(self.db.rareFarmingScanCache) == "table" then
        for _, entry in pairs(self.db.rareFarmingScanCache) do
            UpdateRows(entry and entry.results)
        end
    end

    return changed
end

function GoldTracker:RemoveRareFarmingResultsForItem(itemID)
    local frame = self.rareFarmingFrame
    local state = frame and frame.scanState
    if type(state) ~= "table" or type(state.results) ~= "table" then
        return
    end

    local kept = {}
    local removed = 0
    for _, row in ipairs(state.results) do
        if tonumber(row and row.itemID) == tonumber(itemID) then
            removed = removed + 1
        else
            kept[#kept + 1] = row
        end
    end
    if removed > 0 then
        state.results = kept
    end
end

local function ResolveRareFarmingItemCache(addon, state, itemID)
    local cached = state.itemCache[itemID]
    if cached then
        return cached
    end

    local source = state.valueSource
    local prices = GetRareFarmingPriceSnapshot(addon, itemID, source)

    local itemName, itemLink, itemQuality, _, _, _, _, _, itemEquipLoc, itemIcon, _, itemClassID, itemSubclassID, bindType =
        GetItemInfoByID(itemID)
    if not itemName then
        local _, _, _, instantItemEquipLoc, instantIcon, instantClassID, instantSubclassID = GetItemInstantInfoByID(itemID)
        itemEquipLoc = itemEquipLoc or instantItemEquipLoc
        itemIcon = itemIcon or instantIcon
        itemClassID = itemClassID or instantClassID
        itemSubclassID = itemSubclassID or instantSubclassID
    end

    cached = {
        itemID = itemID,
        value = prices.value,
        marketValue = prices.marketValue,
        regionMarketValue = prices.regionMarketValue,
        averageValue = prices.averageValue,
        valueSourceID = source and source.id,
        valueSourceLabel = source and source.label,
        itemName = itemName,
        itemLink = itemLink,
        itemQuality = tonumber(itemQuality),
        itemEquipLoc = itemEquipLoc,
        icon = itemIcon,
        itemClassID = tonumber(itemClassID),
        itemSubclassID = tonumber(itemSubclassID),
        bindType = tonumber(bindType),
        auctionable = not IsRareFarmingBindRestricted(bindType),
    }
    state.itemCache[itemID] = cached

    if cached.value > state.minimumValueCopper and not itemName and not cached.dataRequested then
        cached.dataRequested = true
        RequestRareFarmingItemData(addon, itemID)
    end

    return cached
end

local function AddRareFarmingResult(state, rare, itemID, itemCache)
    local resultKey = GetRareFarmingResultItemKey(itemID)
    if not resultKey then
        return
    end
    local source = BuildRareFarmingSource(
        rare.npcID,
        rare.name or tostring(rare.npcID),
        rare.locations,
        BuildRareFarmingLocationLabel(rare.locations)
    )
    local existing = state.resultsByKey[resultKey]
    if type(existing) == "table" then
        AddRareFarmingSourceToRow(existing, source)
        return
    end

    local row = {
        npcID = rare.npcID,
        rareName = rare.name or tostring(rare.npcID),
        itemID = itemID,
        itemName = itemCache.itemName,
        itemLink = itemCache.itemLink,
        itemQuality = itemCache.itemQuality,
        icon = itemCache.icon,
        value = itemCache.value,
        marketValue = itemCache.marketValue,
        regionMarketValue = itemCache.regionMarketValue,
        averageValue = itemCache.averageValue,
        valueSourceID = itemCache.valueSourceID,
        valueSourceLabel = itemCache.valueSourceLabel,
        locationLabel = BuildRareFarmingLocationLabel(rare.locations),
        expansionFilterID = state.expansionFilterID,
        expansionFilterLabel = state.expansionFilterLabel,
        locations = rare.locations,
    }
    AddRareFarmingSourceToRow(row, source)
    state.resultsByKey[resultKey] = row
    state.results[#state.results + 1] = row
end

local function BuildRareFarmingScanCacheKey(addon, expansionFilterID, valueSourceID, minimumValueCopper)
    local normalizedExpansionFilterID = NormalizeRareFarmingExpansionFilter(expansionFilterID)
    local normalizedValueSourceID = type(valueSourceID) == "string" and valueSourceID or ""
    local normalizedMinimumValue = math.max(0, math.floor((tonumber(minimumValueCopper) or 0) + 0.5))
    return table.concat({
        tostring(RARE_FARMING_SCAN_CACHE_VERSION),
        normalizedExpansionFilterID,
        normalizedValueSourceID,
        tostring(normalizedMinimumValue),
        tostring(GetRareScannerRuntimeVersion() or "unknown"),
    }, "|")
end

local function CloneRareFarmingResultForCache(row)
    local itemID = tonumber(row and row.itemID)
    local npcID = tonumber(row and row.npcID)
    if not itemID then
        return nil
    end

    return {
        npcID = npcID and math.floor(npcID + 0.5) or nil,
        rareName = row.rareName,
        itemID = math.floor(itemID + 0.5),
        itemName = row.itemName,
        itemLink = row.itemLink,
        itemQuality = tonumber(row.itemQuality),
        icon = row.icon or row.iconTexture,
        bindType = row.bindType,
        value = math.max(0, math.floor((tonumber(row.value) or 0) + 0.5)),
        marketValue = math.max(0, math.floor((tonumber(row.marketValue) or 0) + 0.5)),
        regionMarketValue = math.max(0, math.floor((tonumber(row.regionMarketValue) or 0) + 0.5)),
        averageValue = math.max(0, math.floor((tonumber(row.averageValue) or 0) + 0.5)),
        valueSourceID = row.valueSourceID,
        valueSourceLabel = row.valueSourceLabel,
        locationLabel = row.locationLabel,
        expansionFilterID = row.expansionFilterID,
        expansionFilterLabel = row.expansionFilterLabel,
        expansionID = row.expansionID,
        expansionLabel = row.expansionLabel,
        contentType = row.contentType,
        instanceName = row.instanceName,
        instanceEncounterJournalID = row.instanceEncounterJournalID,
        instanceMapID = row.instanceMapID,
        bossName = row.bossName,
        bossEncounterJournalID = row.bossEncounterJournalID,
        difficulties = row.difficulties,
        locations = row.locations,
        rareSources = CloneRareFarmingSources(row.rareSources),
        rareSourceCount = tonumber(row.rareSourceCount),
        farmingSourceType = row.farmingSourceType,
        marketHistoryItemKey = row.marketHistoryItemKey,
    }
end

local function PruneRareFarmingScanCache(cache)
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
    if #entries <= RARE_FARMING_SCAN_CACHE_MAX_ENTRIES then
        return
    end

    table.sort(entries, function(left, right)
        return (left.savedAtTime or 0) < (right.savedAtTime or 0)
    end)
    for index = 1, #entries - RARE_FARMING_SCAN_CACHE_MAX_ENTRIES do
        cache[entries[index].key] = nil
    end
end

function GoldTracker:SaveRareFarmingScanCache(state, replaceCacheKey)
    if type(self.db) ~= "table" or type(state) ~= "table" or type(state.results) ~= "table" then
        return nil
    end

    if type(self.db.rareFarmingScanCache) ~= "table" then
        self.db.rareFarmingScanCache = {}
    end

    local source = state.valueSource
    local sourceID = source and source.id or state.valueSourceID
    local minimumValue = tonumber(state.minimumValueCopper) or self:GetRareFarmingMinimumValue()
    local cacheKey = BuildRareFarmingScanCacheKey(self, state.expansionFilterID, sourceID, minimumValue)
    if type(replaceCacheKey) == "string" and replaceCacheKey ~= "" and replaceCacheKey ~= cacheKey then
        self.db.rareFarmingScanCache[replaceCacheKey] = nil
    end
    local cachedResults = {}
    for _, row in ipairs(state.results) do
        local cachedRow = CloneRareFarmingResultForCache(row)
        if cachedRow then
            cachedResults[#cachedResults + 1] = cachedRow
        end
    end

    local savedAtTime = type(time) == "function" and time() or 0
    self.db.rareFarmingScanCache[cacheKey] = {
        cacheVersion = RARE_FARMING_SCAN_CACHE_VERSION,
        sourceVersion = GetRareScannerRuntimeVersion(),
        savedAt = type(date) == "function" and date("%Y-%m-%d %H:%M") or nil,
        savedAtTime = savedAtTime,
        expansionFilterID = NormalizeRareFarmingExpansionFilter(state.expansionFilterID),
        expansionFilterLabel = state.expansionFilterLabel,
        valueSourceID = sourceID,
        valueSourceLabel = source and source.label or state.valueSourceLabel,
        minimumValueCopper = math.max(0, math.floor(minimumValue + 0.5)),
        totalDrops = tonumber(state.totalDrops) or 0,
        resultCount = #cachedResults,
        results = cachedResults,
    }
    PruneRareFarmingScanCache(self.db.rareFarmingScanCache)
    if type(self.RecordRareFarmingMarketSnapshots) == "function" then
        self:RecordRareFarmingMarketSnapshots(cachedResults)
    end

    return self.db.rareFarmingScanCache[cacheKey], cacheKey
end

function GoldTracker:SaveCurrentRareFarmingScan()
    local frame = self.rareFarmingFrame
    if not frame or IsRareFarmingScanStateActive(frame.scanState) then
        return
    end

    local state = frame.scanState
    if type(state) ~= "table" then
        state = {
            results = frame.lastResults,
            totalDrops = frame.loadedRareFarmingCache and frame.loadedRareFarmingCache.totalDrops or #(frame.lastResults or {}),
        }
    end
    if type(state.results) ~= "table" or #state.results == 0 then
        if frame.statusText then
            frame.statusText:SetText("Nothing to save yet. Run a scan first.")
        end
        return
    end

    state.valueSource = self.VALUE_SOURCE_BY_ID[frame.valueSourceID] or state.valueSource
    state.valueSourceID = frame.valueSourceID or state.valueSourceID
    state.valueSourceLabel = state.valueSource and state.valueSource.label or state.valueSourceLabel
    state.minimumValueCopper = tonumber(frame.minimumValueCopper) or state.minimumValueCopper
    state.expansionFilterID = frame.expansionFilterID or state.expansionFilterID
    state.expansionFilterLabel = GetRareFarmingExpansionFilterLabel(state.expansionFilterID)

    local replaceCacheKey = frame.editingRareFarmingCacheKey or frame.loadedRareFarmingCacheKey
    local entry, cacheKey = self:SaveRareFarmingScanCache(state, replaceCacheKey)
    if entry then
        frame.loadedRareFarmingCache = entry
        frame.loadedRareFarmingCacheKey = cacheKey
        frame.editingRareFarmingCacheKey = cacheKey
        if frame.statusText then
            frame.statusText:SetText(string.format(
                "Saved scan for %s: %d matching rare drops.",
                entry.expansionFilterLabel or GetRareFarmingExpansionFilterLabel(entry.expansionFilterID),
                tonumber(entry.resultCount) or #(entry.results or {})
            ))
        end
        self:RefreshRareFarmingWindowControls()
        self:RefreshRareFarmingLibraryWindow()
    end
end

function GoldTracker:LoadRareFarmingScanCacheForCurrentFilters()
    local frame = self.rareFarmingFrame
    if not frame or IsRareFarmingScanStateActive(frame.scanState) then
        return false
    end

    frame.scanState = nil
    frame.loadedRareFarmingCacheKey = nil
    frame.loadedRareFarmingCache = nil
    frame.editingRareFarmingCacheKey = nil

    local source = self.VALUE_SOURCE_BY_ID[frame.valueSourceID] or self:GetRareFarmingValueSource()
    local expansionFilterID = self:GetRareFarmingExpansionFilter()
    local minimumValue = tonumber(frame.minimumValueCopper) or self:GetRareFarmingMinimumValue()
    local cacheKey = BuildRareFarmingScanCacheKey(self, expansionFilterID, source and source.id, minimumValue)
    local cache = type(self.db) == "table" and self.db.rareFarmingScanCache or nil
    local entry = type(cache) == "table" and cache[cacheKey] or nil

    if type(entry) ~= "table" or type(entry.results) ~= "table" then
        frame.lastResults = {}
        frame.hasRareFarmingScanRun = false
        if frame.progressBar then
            frame.progressBar:SetMinMaxValues(0, 1)
            frame.progressBar:SetValue(0)
        end
        if frame.statusText then
            frame.statusText:SetText("Ready.")
        end
        return false
    end

    local loadedResults = {}
    for _, row in ipairs(entry.results) do
        local cachedRow = CloneRareFarmingResultForCache(row)
        if cachedRow then
            loadedResults[#loadedResults + 1] = cachedRow
        end
    end

    frame.lastResults = loadedResults
    frame.loadedRareFarmingCacheKey = cacheKey
    frame.loadedRareFarmingCache = entry
    frame.editingRareFarmingCacheKey = cacheKey
    frame.hasRareFarmingScanRun = true
    if frame.progressBar then
        local totalDrops = math.max(1, tonumber(entry.totalDrops) or #loadedResults or 1)
        frame.progressBar:SetMinMaxValues(0, totalDrops)
        frame.progressBar:SetValue(totalDrops)
    end
    if frame.statusText then
        frame.statusText:SetText(string.format(
            "Loaded cached scan for %s: %d matching rare drops.",
            entry.expansionFilterLabel or GetRareFarmingExpansionFilterLabel(expansionFilterID),
            #loadedResults
        ))
    end

    return true
end

function GoldTracker:IsRareFarmingFavorite(rowOrNpcID, itemID)
    if type(self.IsFarmingItemFavorite) == "function" then
        return self:IsFarmingItemFavorite(type(rowOrNpcID) == "table" and rowOrNpcID or (itemID or rowOrNpcID))
    end
    local key = GetRareFarmingFavoriteKey(rowOrNpcID, itemID)
    local favorites = type(self.db) == "table" and self.db.rareFarmingFavorites or nil
    return key ~= nil and type(favorites) == "table" and favorites[key] ~= nil
end

function GoldTracker:SetRareFarmingFavorite(row, isFavorite)
    local key = GetRareFarmingFavoriteKey(row)
    if not key then
        return false
    end
    local favorites = type(self.GetFarmingFavoriteStore) == "function" and self:GetFarmingFavoriteStore()
        or (type(self.db) == "table" and self.db.rareFarmingFavorites or nil)
    if type(favorites) ~= "table" then
        return false
    end

    if isFavorite then
        local cachedRow = CloneRareFarmingResultForCache(row)
        if not cachedRow then
            return false
        end
        cachedRow.favoriteKey = key
        cachedRow.farmingSourceType = cachedRow.farmingSourceType or "rare"
        cachedRow.favoritedAt = type(date) == "function" and date("%Y-%m-%d %H:%M") or nil
        cachedRow.favoritedAtTime = type(time) == "function" and time() or 0
        favorites[key] = cachedRow
        if type(self.RecordRareFarmingMarketSnapshots) == "function" then
            self:RecordRareFarmingMarketSnapshots({ cachedRow })
        end
    else
        favorites[key] = nil
    end
    return true
end

function GoldTracker:ToggleRareFarmingFavorite(row)
    local shouldFavorite = not self:IsRareFarmingFavorite(row)
    if self:SetRareFarmingFavorite(row, shouldFavorite) then
        self:RefreshRareFarmingWindow(false)
        self:RefreshRareFarmingLibraryWindow()
        if self.instanceFarmingFrame and type(self.RefreshInstanceFarmingWindow) == "function" then
            self:RefreshInstanceFarmingWindow(false)
            self:RefreshInstanceFarmingLibraryWindow()
        end
    end
end

function GoldTracker:UpdateRareFarmingRowsPrices(rows, valueSourceID)
    local source = self.VALUE_SOURCE_BY_ID[valueSourceID] or self:GetRareFarmingValueSource()
    if type(rows) ~= "table" or not source then
        return 0
    end

    local updated = 0
    for _, row in ipairs(rows) do
        local itemID = tonumber(row and row.itemID)
        if itemID then
            local prices = GetRareFarmingPriceSnapshot(self, math.floor(itemID + 0.5), source)
            row.value = prices.value
            row.marketValue = prices.marketValue
            row.regionMarketValue = prices.regionMarketValue
            row.averageValue = prices.averageValue
            row.valueSourceID = source.id
            row.valueSourceLabel = source.label
            updated = updated + 1
        end
    end
    if updated > 0 and type(self.RecordRareFarmingMarketSnapshots) == "function" then
        self:RecordRareFarmingMarketSnapshots(rows)
    end
    return updated
end

function GoldTracker:UpdateCurrentRareFarmingScanPrices()
    local frame = self.rareFarmingFrame
    if not frame or IsRareFarmingScanStateActive(frame.scanState) then
        return
    end

    local rows = frame.lastResults
    local loadedEntry = frame.loadedRareFarmingCache
    local source = self.VALUE_SOURCE_BY_ID[frame.valueSourceID]
        or (loadedEntry and self.VALUE_SOURCE_BY_ID[loadedEntry.valueSourceID])
        or self:GetRareFarmingValueSource()
    local updated = self:UpdateRareFarmingRowsPrices(rows, source and source.id)
    if loadedEntry and type(rows) == "table" then
        local cachedResults = {}
        for _, row in ipairs(rows) do
            local cachedRow = CloneRareFarmingResultForCache(row)
            if cachedRow then
                cachedResults[#cachedResults + 1] = cachedRow
            end
        end
        loadedEntry.results = cachedResults
        loadedEntry.resultCount = #cachedResults
        loadedEntry.valueSourceID = source and source.id or loadedEntry.valueSourceID
        loadedEntry.valueSourceLabel = source and source.label or loadedEntry.valueSourceLabel
        loadedEntry.minimumValueCopper = tonumber(frame.minimumValueCopper) or loadedEntry.minimumValueCopper
        loadedEntry.expansionFilterID = frame.expansionFilterID or loadedEntry.expansionFilterID
        loadedEntry.expansionFilterLabel = GetRareFarmingExpansionFilterLabel(loadedEntry.expansionFilterID)
        loadedEntry.savedAt = type(date) == "function" and date("%Y-%m-%d %H:%M") or loadedEntry.savedAt
        loadedEntry.savedAtTime = type(time) == "function" and time() or loadedEntry.savedAtTime

        local oldCacheKey = frame.editingRareFarmingCacheKey or frame.loadedRareFarmingCacheKey
        local newCacheKey = BuildRareFarmingScanCacheKey(
            self,
            loadedEntry.expansionFilterID,
            loadedEntry.valueSourceID,
            loadedEntry.minimumValueCopper
        )
        if type(self.db) == "table" and type(self.db.rareFarmingScanCache) == "table" then
            if type(oldCacheKey) == "string" and oldCacheKey ~= "" and oldCacheKey ~= newCacheKey then
                self.db.rareFarmingScanCache[oldCacheKey] = nil
            end
            self.db.rareFarmingScanCache[newCacheKey] = loadedEntry
            frame.loadedRareFarmingCacheKey = newCacheKey
            frame.editingRareFarmingCacheKey = newCacheKey
        end
    end
    if frame.statusText then
        frame.statusText:SetText(string.format("Updated prices for %d scan items.", updated))
    end
    self:RefreshRareFarmingWindow(false)
    self:RefreshRareFarmingLibraryWindow()
end

function GoldTracker:RescanCurrentRareFarmingSelection()
    local frame = self.rareFarmingFrame
    if not frame or IsRareFarmingScanStateActive(frame.scanState) then
        return
    end

    local loadedEntry = frame.loadedRareFarmingCache
    if loadedEntry then
        self:SetRareFarmingExpansionFilter(loadedEntry.expansionFilterID)
        self:SetRareFarmingMinimumValue(loadedEntry.minimumValueCopper)
        self:SetRareFarmingValueSource(loadedEntry.valueSourceID)
    end
    self:SetRareFarmingWindowView("scan")
    self:StartRareFarmingScan()
end

function GoldTracker:UpdateRareFarmingFavoritePrices()
    local favorites = type(self.GetFarmingFavoriteStore) == "function" and self:GetFarmingFavoriteStore()
        or (type(self.db) == "table" and self.db.rareFarmingFavorites or nil)
    if type(favorites) ~= "table" then
        return
    end

    local rows = {}
    for key, favorite in pairs(favorites) do
        local cachedRow = CloneRareFarmingResultForCache(favorite)
        if cachedRow then
            cachedRow.favoriteKey = key
            rows[#rows + 1] = cachedRow
        end
    end
    local updated = self:UpdateRareFarmingRowsPrices(rows, self:GetRareFarmingValueSource().id)
    for _, row in ipairs(rows) do
        local key = row.favoriteKey or GetRareFarmingFavoriteKey(row)
        if key then
            row.favoriteKey = key
            row.favoritedAt = favorites[key] and favorites[key].favoritedAt
            row.favoritedAtTime = favorites[key] and favorites[key].favoritedAtTime
            row.farmingSourceType = favorites[key] and favorites[key].farmingSourceType or row.farmingSourceType
            favorites[key] = row
        end
    end
    if self.rareFarmingFrame and self.rareFarmingFrame.libraryStatusText then
        self.rareFarmingFrame.libraryStatusText:SetText(string.format("Updated prices for %d favorite items.", updated))
    end
    self:RefreshRareFarmingWindow(false)
    self:RefreshRareFarmingLibraryWindow()
    if self.instanceFarmingFrame and type(self.RefreshInstanceFarmingWindow) == "function" then
        self:RefreshInstanceFarmingWindow(false)
        self:RefreshInstanceFarmingLibraryWindow()
    end
end

function GoldTracker:RefreshRareFarmingNavigationTabs()
    local frame = self.rareFarmingFrame
    if not frame then
        return
    end

    local activeTab = frame.rareFarmingNavigationTab
    if frame.rareFarmingViewID ~= "scan" then
        activeTab = frame.rareFarmingLibraryTab or "saved"
    elseif activeTab ~= "saved" and activeTab ~= "favorites" and activeTab ~= "new" then
        activeTab = "new"
    end
    frame.rareFarmingNavigationTab = activeTab

    if frame.librarySavedTabButton then
        frame.librarySavedTabButton:SetPalette(activeTab == "saved" and "primary" or "neutral")
    end
    if frame.libraryFavoritesTabButton then
        frame.libraryFavoritesTabButton:SetPalette(activeTab == "favorites" and "primary" or "neutral")
    end
    if frame.libraryNewScanButton then
        frame.libraryNewScanButton:SetPalette(activeTab == "new" and "primary" or "neutral")
    end
end

function GoldTracker:SetRareFarmingWindowView(viewID)
    local frame = self.rareFarmingFrame
    if not frame then
        return
    end

    local normalizedViewID = viewID == "scan" and "scan" or "library"
    frame.rareFarmingViewID = normalizedViewID
    local showScan = normalizedViewID == "scan"
    if showScan then
        frame.rareFarmingNavigationTab = frame.rareFarmingNavigationTab or "new"
    else
        frame.rareFarmingNavigationTab = frame.rareFarmingLibraryTab or "saved"
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
    if frame.libraryUpdateFavoritesButton then
        frame.libraryUpdateFavoritesButton:SetShown(not showScan and frame.rareFarmingLibraryTab == "favorites")
    end
    if type(self.RefreshRareFarmingNavigationTabs) == "function" then
        self:RefreshRareFarmingNavigationTabs()
    end

    if showScan then
        self:RefreshRareFarmingWindowControls()
        self:RefreshRareFarmingWindow(true)
    else
        self:RefreshRareFarmingLibraryWindow()
    end
end

local function GetRareFarmingSavedScanEntries(addon)
    local cache = type(addon.db) == "table" and addon.db.rareFarmingScanCache or nil
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

local function GetRareFarmingFavoriteEntries(addon)
    local favorites = type(addon.GetFarmingFavoriteStore) == "function" and addon:GetFarmingFavoriteStore()
        or (type(addon.db) == "table" and addon.db.rareFarmingFavorites or nil)
    local entries = {}
    if type(favorites) ~= "table" then
        return entries
    end
    for key, favorite in pairs(favorites) do
        if type(favorite) == "table" then
            local row = CloneRareFarmingResultForCache(favorite)
            if row then
                row.favoriteKey = key
                entries[#entries + 1] = {
                    key = key,
                    row = row,
                    savedAtTime = tonumber(favorite.favoritedAtTime) or 0,
                }
            end
        end
    end
    table.sort(entries, function(left, right)
        local leftRow = left.row or {}
        local rightRow = right.row or {}
        local leftExpansion = leftRow.expansionFilterLabel
            or (leftRow.expansionFilterID and GetRareFarmingExpansionFilterLabel(leftRow.expansionFilterID))
            or leftRow.expansionLabel
            or leftRow.locationLabel
            or "Unknown"
        local rightExpansion = rightRow.expansionFilterLabel
            or (rightRow.expansionFilterID and GetRareFarmingExpansionFilterLabel(rightRow.expansionFilterID))
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

local function GetRareFarmingFavoriteEntryExpansionLabel(entry)
    local row = entry and entry.row or {}
    return row.expansionFilterLabel
        or (row.expansionFilterID and GetRareFarmingExpansionFilterLabel(row.expansionFilterID))
        or row.expansionLabel
        or row.locationLabel
        or "Unknown"
end

local function BuildRareFarmingFavoriteDisplayEntries(entries)
    local displayEntries = {}
    local currentExpansionLabel
    for _, entry in ipairs(entries or {}) do
        local expansionLabel = GetRareFarmingFavoriteEntryExpansionLabel(entry)
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

local function GetRareFarmingFavoriteColumnLayout(contentWidth)
    local removeWidth = 24
    local valueWidth = 92
    local columnGap = 10
    local expansionWidth = 116
    local sourceWidth = 150
    local detailsX = contentWidth - RARE_FARMING_WOWHEAD_BUTTON_WIDTH - 12
    local averageX = detailsX - valueWidth - columnGap
    local regionX = averageX - valueWidth - columnGap
    local marketX = regionX - valueWidth - columnGap
    local selectedX = marketX - valueWidth - columnGap
    local sourceX = removeWidth + columnGap + expansionWidth + columnGap
    local itemX = sourceX + sourceWidth + columnGap

    return {
        removeWidth = removeWidth,
        valueWidth = valueWidth,
        columnGap = columnGap,
        expansionX = removeWidth + columnGap,
        expansionWidth = expansionWidth,
        sourceX = sourceX,
        sourceWidth = sourceWidth,
        itemX = itemX,
        itemWidth = math.max(120, selectedX - itemX - columnGap),
        selectedX = selectedX,
        marketX = marketX,
        regionX = regionX,
        averageX = averageX,
        detailsX = detailsX,
        detailsWidth = RARE_FARMING_WOWHEAD_BUTTON_WIDTH,
    }
end

local function ApplyRareFarmingFavoriteHeaderLayout(frame, contentWidth)
    local headerFrame = frame and frame.libraryFavoritesHeaderFrame
    local labels = frame and frame.libraryFavoriteHeaderLabels
    if not headerFrame or type(labels) ~= "table" then
        return
    end

    local layout = GetRareFarmingFavoriteColumnLayout(contentWidth)
    local specs = {
        { key = "expansion", x = layout.expansionX, width = layout.expansionWidth, justify = "LEFT" },
        { key = "source", x = layout.sourceX, width = layout.sourceWidth, justify = "LEFT" },
        { key = "item", x = layout.itemX, width = layout.itemWidth, justify = "LEFT" },
        { key = "selected", x = layout.selectedX, width = layout.valueWidth, justify = "RIGHT" },
        { key = "market", x = layout.marketX, width = layout.valueWidth, justify = "RIGHT" },
        { key = "region", x = layout.regionX, width = layout.valueWidth, justify = "RIGHT" },
        { key = "average", x = layout.averageX, width = layout.valueWidth, justify = "RIGHT" },
        { key = "details", x = layout.detailsX, width = layout.detailsWidth, justify = "CENTER" },
    }

    for _, spec in ipairs(specs) do
        local label = labels[spec.key]
        if label then
            label:ClearAllPoints()
            label:SetPoint("LEFT", headerFrame, "LEFT", spec.x, 0)
            label:SetWidth(spec.width)
            label:SetJustifyH(spec.justify)
        end
    end
end

function GoldTracker:OpenRareFarmingSavedScan(cacheKey)
    local frame = self.rareFarmingFrame
    local cache = type(self.db) == "table" and self.db.rareFarmingScanCache or nil
    local entry = type(cache) == "table" and cache[cacheKey] or nil
    if not frame or type(entry) ~= "table" then
        return
    end

    if entry.valueSourceID then
        self.db.rareFarmingValueSource = entry.valueSourceID
        frame.valueSourceID = entry.valueSourceID
    end
    if entry.expansionFilterID then
        self.db.rareFarmingExpansionFilter = NormalizeRareFarmingExpansionFilter(entry.expansionFilterID)
        frame.expansionFilterID = self.db.rareFarmingExpansionFilter
    end
    if tonumber(entry.minimumValueCopper) then
        self.db.rareFarmingMinimumValue = math.max(0, math.floor(tonumber(entry.minimumValueCopper) + 0.5))
        frame.minimumValueCopper = self.db.rareFarmingMinimumValue
    end

    frame.scanState = nil
    frame.loadedRareFarmingCacheKey = cacheKey
    frame.loadedRareFarmingCache = entry
    frame.editingRareFarmingCacheKey = cacheKey
    frame.hasRareFarmingScanRun = true

    local loadedResults = {}
    for _, row in ipairs(entry.results or {}) do
        local cachedRow = CloneRareFarmingResultForCache(row)
        if cachedRow then
            loadedResults[#loadedResults + 1] = cachedRow
        end
    end
    frame.lastResults = loadedResults
    if frame.statusText then
        frame.statusText:SetText(string.format(
            "Loaded saved scan for %s: %d matching rare drops.",
            entry.expansionFilterLabel or GetRareFarmingExpansionFilterLabel(frame.expansionFilterID),
            #loadedResults
        ))
    end
    frame.rareFarmingNavigationTab = "saved"
    self:SetRareFarmingWindowView("scan")
end

function GoldTracker:DeleteRareFarmingSavedScan(cacheKey)
    if type(cacheKey) ~= "string" or type(self.db) ~= "table" or type(self.db.rareFarmingScanCache) ~= "table" then
        return
    end

    self.db.rareFarmingScanCache[cacheKey] = nil

    local frame = self.rareFarmingFrame
    if frame and (frame.loadedRareFarmingCacheKey == cacheKey or frame.editingRareFarmingCacheKey == cacheKey) then
        frame.loadedRareFarmingCacheKey = nil
        frame.loadedRareFarmingCache = nil
        frame.editingRareFarmingCacheKey = nil
        if frame.rareFarmingViewID == "scan" then
            self:RefreshRareFarmingWindowControls()
        end
    end

    self:RefreshRareFarmingLibraryWindow()
end

function GoldTracker:OpenRareFarmingNewScan()
    local frame = self.rareFarmingFrame
    if not frame then
        return
    end
    frame.scanState = nil
    frame.lastResults = {}
    frame.loadedRareFarmingCacheKey = nil
    frame.loadedRareFarmingCache = nil
    frame.editingRareFarmingCacheKey = nil
    frame.hasRareFarmingScanRun = false
    if frame.progressBar then
        frame.progressBar:SetMinMaxValues(0, 1)
        frame.progressBar:SetValue(0)
    end
    if frame.statusText then
        frame.statusText:SetText("Ready.")
    end
    frame.rareFarmingNavigationTab = "new"
    self:SetRareFarmingWindowView("scan")
end

function GoldTracker:CreateRareFarmingWowheadWindow()
    if self.rareFarmingWowheadWindow then
        return
    end

    local frame = CreateFrame("Frame", "GoldTrackerRareFarmingWowheadWindow", UIParent, "BasicFrameTemplateWithInset")
    frame:SetSize(620, 220)
    frame:SetPoint("CENTER", UIParent, "CENTER", 0, 80)
    frame:SetFrameStrata("DIALOG")
    if frame.SetToplevel then
        frame:SetToplevel(true)
    end
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
    frame:Hide()

    local chrome = Theme:ApplyWindowChrome(frame, "Wowhead Links")
    Theme:RegisterSpecialFrame("GoldTrackerRareFarmingWowheadWindow")

    local panel = CreateRareFarmingPanel(frame, { 0.04, 0.05, 0.07, 0.96 }, { 1.0, 0.82, 0.18, 0.12 })
    panel:SetPoint("TOPLEFT", chrome, "TOPLEFT", 14, -54)
    panel:SetPoint("BOTTOMRIGHT", chrome, "BOTTOMRIGHT", -14, 14)

    local title = panel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    title:SetPoint("TOPLEFT", panel, "TOPLEFT", 14, -14)
    title:SetPoint("TOPRIGHT", panel, "TOPRIGHT", -14, -14)
    title:SetJustifyH("LEFT")
    title:SetText("Select a link and copy it.")
    frame.itemTitleText = title

    local itemLabel = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    itemLabel:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -18)
    itemLabel:SetText("Item")

    local itemEditBox = CreateFrame("EditBox", nil, panel, "InputBoxTemplate")
    itemEditBox:SetPoint("TOPLEFT", itemLabel, "BOTTOMLEFT", 0, -6)
    itemEditBox:SetPoint("TOPRIGHT", panel, "TOPRIGHT", -18, -58)
    itemEditBox:SetHeight(22)
    itemEditBox:SetAutoFocus(false)
    itemEditBox:SetScript("OnEditFocusGained", function(self)
        self:HighlightText()
    end)
    itemEditBox:SetScript("OnEscapePressed", function(self)
        self:ClearFocus()
    end)
    frame.itemEditBox = itemEditBox

    local rareLabel = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    rareLabel:SetPoint("TOPLEFT", itemEditBox, "BOTTOMLEFT", 0, -18)
    rareLabel:SetText("Rare")

    local rareEditBox = CreateFrame("EditBox", nil, panel, "InputBoxTemplate")
    rareEditBox:SetPoint("TOPLEFT", rareLabel, "BOTTOMLEFT", 0, -6)
    rareEditBox:SetPoint("TOPRIGHT", panel, "TOPRIGHT", -18, -122)
    rareEditBox:SetHeight(22)
    rareEditBox:SetAutoFocus(false)
    rareEditBox:SetScript("OnEditFocusGained", function(self)
        self:HighlightText()
    end)
    rareEditBox:SetScript("OnEscapePressed", function(self)
        self:ClearFocus()
    end)
    frame.rareEditBox = rareEditBox

    self.rareFarmingWowheadWindow = frame
end

function GoldTracker:OpenRareFarmingWowheadLinks(row)
    local itemID = tonumber(row and row.itemID)
    local npcID = tonumber(row and row.npcID)
    if not itemID and not npcID then
        return
    end

    self:CreateRareFarmingWowheadWindow()
    local frame = self.rareFarmingWowheadWindow
    if not frame then
        return
    end

    frame.itemTitleText:SetText(string.format(
        "%s | %s",
        row.itemLink or row.itemName or (itemID and ("Item " .. tostring(itemID)) or "Item"),
        row.rareName or (npcID and ("Rare " .. tostring(npcID)) or "Rare")
    ))
    frame.itemEditBox:SetText(BuildRareFarmingWowheadItemURL(itemID))
    frame.rareEditBox:SetText(BuildRareFarmingWowheadNpcURL(npcID))
    frame:Show()
    frame:Raise()
    frame.itemEditBox:SetFocus()
    frame.itemEditBox:HighlightText()
end

function GoldTracker:SetRareFarmingWaypoint(row)
    local mapID, x, y = GetRareFarmingFirstWaypointLocation(row)
    if not mapID or not x or not y then
        self:Print("No waypoint coordinates are available for this rare.")
        return false
    end

    if not (C_Map and type(C_Map.SetUserWaypoint) == "function" and UiMapPoint and type(UiMapPoint.CreateFromCoordinates) == "function") then
        self:Print("Blizzard waypoint API is unavailable.")
        return false
    end

    C_Map.SetUserWaypoint(UiMapPoint.CreateFromCoordinates(mapID, x, y))
    if C_SuperTrack and type(C_SuperTrack.SetSuperTrackedUserWaypoint) == "function" then
        C_SuperTrack.SetSuperTrackedUserWaypoint(true)
    end
    self:Print(string.format(
        "Waypoint set for %s at %s.",
        row and row.rareName or "rare",
        row and row.locationLabel or tostring(mapID)
    ))
    return true
end

function GoldTracker:OpenRareFarmingMap(row)
    local mapOptions = self:BuildRareFarmingMapOptions(row)
    if #mapOptions == 0 then
        self:Print("No map coordinates are available for this rare.")
        return false
    end

    if type(self.OpenStandaloneMapWindow) ~= "function" then
        self:Print("The map window is not loaded yet.")
        return false
    end

    self:OpenStandaloneMapWindow({
        title = (row.itemName or row.itemLink or ("Item " .. tostring(row.itemID or ""))) .. " Rare Map",
        mapOptions = mapOptions,
        selectedMapOptionIndex = 1,
    })
    return true
end

function GoldTracker:RefreshRareFarmingLibraryWindow()
    local frame = self.rareFarmingFrame
    if not frame or not frame.libraryPanel then
        return
    end

    local activeTab = frame.rareFarmingLibraryTab or "saved"
    if frame.rareFarmingViewID ~= "scan" then
        frame.rareFarmingNavigationTab = activeTab
    end
    if type(self.RefreshRareFarmingNavigationTabs) == "function" then
        self:RefreshRareFarmingNavigationTabs()
    end
    if frame.libraryUpdateFavoritesButton then
        frame.libraryUpdateFavoritesButton:SetShown(frame.rareFarmingViewID ~= "scan" and activeTab == "favorites")
    end

    local entries = activeTab == "favorites"
        and GetRareFarmingFavoriteEntries(self)
        or GetRareFarmingSavedScanEntries(self)
    local favoriteCount = activeTab == "favorites" and #entries or nil
    if activeTab == "favorites" then
        entries = BuildRareFarmingFavoriteDisplayEntries(entries)
    end
    local yOffset = 0
    frame.libraryRows = frame.libraryRows or {}
    local contentWidth = frame.libraryScrollFrame and math.max(1, math.floor(frame.libraryScrollFrame:GetWidth() or 1)) or 1
    if contentWidth <= 1 and frame.libraryPanel and frame.libraryPanel.GetWidth then
        contentWidth = math.max(1, math.floor((frame.libraryPanel:GetWidth() or 1) - 40))
    end
    frame.libraryContent:SetWidth(contentWidth)

    if frame.libraryFavoritesHeaderFrame then
        frame.libraryFavoritesHeaderFrame:SetShown(activeTab == "favorites")
        ApplyRareFarmingFavoriteHeaderLayout(frame, contentWidth)
    end
    if frame.libraryScrollFrame and frame.libraryStatusText then
        frame.libraryScrollFrame:ClearAllPoints()
        if activeTab == "favorites" and frame.libraryFavoritesHeaderFrame then
            frame.libraryScrollFrame:SetPoint("TOPLEFT", frame.libraryFavoritesHeaderFrame, "BOTTOMLEFT", 0, -6)
        else
            frame.libraryScrollFrame:SetPoint("TOPLEFT", frame.libraryStatusText, "BOTTOMLEFT", 0, -10)
        end
        frame.libraryScrollFrame:SetPoint("BOTTOMRIGHT", frame.libraryPanel, "BOTTOMRIGHT", -26, 12)
    end

    for index, data in ipairs(entries) do
        local row = frame.libraryRows[index]
        if not row then
            row = CreateFrame("Button", nil, frame.libraryContent)
            SetRareFarmingFrameLevel(row, frame.libraryContent, 1)
            row:RegisterForClicks("LeftButtonUp")
            row:EnableMouse(true)
            row.background = row:CreateTexture(nil, "BACKGROUND")
            row.background:SetAllPoints(row)
            row.primaryText = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
            row.primaryText:SetPoint("TOPLEFT", row, "TOPLEFT", 10, -8)
            row.primaryText:SetPoint("RIGHT", row, "RIGHT", -138, 0)
            row.primaryText:SetJustifyH("LEFT")
            row.primaryText:SetWordWrap(false)
            row.secondaryText = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
            row.secondaryText:SetPoint("TOPLEFT", row.primaryText, "BOTTOMLEFT", 0, -5)
            row.secondaryText:SetPoint("RIGHT", row, "RIGHT", -138, 0)
            row.secondaryText:SetJustifyH("LEFT")
            row.secondaryText:SetWordWrap(false)
            row.valueText = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
            row.valueText:SetPoint("RIGHT", row, "RIGHT", -12, 0)
            row.valueText:SetWidth(110)
            row.valueText:SetJustifyH("RIGHT")
            row.groupHeaderText = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
            row.groupHeaderText:SetJustifyH("LEFT")
            row.groupHeaderText:SetWordWrap(false)

            row.savedDeleteButton = CreateRareFarmingButton(row, 64, 20, "Delete", "danger")
            row.savedDeleteButton:RegisterForClicks("LeftButtonUp")
            row.savedDeleteButton:SetScript("OnClick", function(self)
                local parent = self:GetParent()
                if parent and parent.scanKey then
                    GoldTracker:DeleteRareFarmingSavedScan(parent.scanKey)
                end
            end)
            row.savedDeleteButton:SetScript("OnEnter", function(self)
                GameTooltip:SetOwner(self, "ANCHOR_CURSOR")
                GameTooltip:AddLine("Delete saved scan", 1, 1, 1)
                GameTooltip:Show()
            end)
            row.savedDeleteButton:SetScript("OnLeave", function()
                GameTooltip:Hide()
            end)

            row.favoriteRemoveButton = CreateRareFarmingButton(row, RARE_FARMING_TRACKED_BUTTON_WIDTH, RARE_FARMING_TRACKED_BUTTON_HEIGHT, "-", "neutral")
            row.favoriteRemoveButton:RegisterForClicks("LeftButtonUp")
            if row.favoriteRemoveButton.SetSelected then
                row.favoriteRemoveButton:SetSelected(true)
            end
            row.favoriteRemoveButton.text = row.favoriteRemoveButton.label
            row.favoriteRemoveButton:SetScript("OnEnter", function(self)
                self.isHovered = true
                if self.theme and self.theme.UpdateButtonVisual then
                    self.theme:UpdateButtonVisual(self)
                end
                GameTooltip:SetOwner(self, "ANCHOR_CURSOR")
                GameTooltip:AddLine("Remove favorite", 1, 1, 1)
                GameTooltip:Show()
            end)
            row.favoriteRemoveButton:SetScript("OnLeave", function(self)
                self.isHovered = false
                self.isPressed = false
                if self.theme and self.theme.UpdateButtonVisual then
                    self.theme:UpdateButtonVisual(self)
                end
                GameTooltip:Hide()
            end)

            row.favoriteWowheadButton = CreateRareFarmingButton(row, RARE_FARMING_WOWHEAD_BUTTON_WIDTH, 20, "Details", "neutral")
            row.favoriteWowheadButton:RegisterForClicks("LeftButtonUp")
            row.favoriteWowheadButton:SetScript("OnClick", function(self)
                GoldTracker:OpenInventoryItemDetailsWindow(self:GetParent())
            end)
            row.favoriteWowheadButton:SetScript("OnEnter", function(self)
                GameTooltip:SetOwner(self, "ANCHOR_CURSOR")
                GameTooltip:AddLine("Open price history", 1, 1, 1)
                GameTooltip:Show()
            end)
            row.favoriteWowheadButton:SetScript("OnLeave", function()
                GameTooltip:Hide()
            end)

            row.favoriteExpansionText = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
            row.favoriteExpansionText:SetJustifyH("LEFT")
            row.favoriteExpansionText:SetWordWrap(false)
            row.favoriteRareText = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
            row.favoriteRareText:SetJustifyH("LEFT")
            row.favoriteRareText:SetWordWrap(false)
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

            frame.libraryRows[index] = row
        else
            SetRareFarmingFrameLevel(row, frame.libraryContent, 1)
        end

        local isExpansionHeader = activeTab == "favorites" and data.isExpansionHeader == true
        local rowHeight = isExpansionHeader and 24 or (activeTab == "favorites" and 30 or 54)
        row:SetHeight(rowHeight)
        row:ClearAllPoints()
        row:SetPoint("TOPLEFT", frame.libraryContent, "TOPLEFT", 0, -yOffset)
        row:SetPoint("TOPRIGHT", frame.libraryContent, "TOPRIGHT", 0, -yOffset)
        row.background:SetColorTexture(1, 1, 1, isExpansionHeader and 0.075 or (index % 2 == 0 and 0.045 or 0.022))
        row.primaryText:ClearAllPoints()
        row.primaryText:SetPoint("TOPLEFT", row, "TOPLEFT", 10, -8)
        row.primaryText:SetPoint("RIGHT", row, "RIGHT", -138, 0)
        row.secondaryText:ClearAllPoints()
        row.secondaryText:SetPoint("TOPLEFT", row.primaryText, "BOTTOMLEFT", 0, -5)
        row.secondaryText:SetPoint("RIGHT", row, "RIGHT", -138, 0)
        row.valueText:ClearAllPoints()
        row.valueText:SetPoint("RIGHT", row, "RIGHT", -12, 0)
        row:SetScript("OnEnter", nil)
        row:SetScript("OnLeave", nil)
        row.scanKey = nil
        row.groupHeaderText:SetShown(isExpansionHeader)
        row.primaryText:SetShown(activeTab ~= "favorites")
        row.secondaryText:SetShown(activeTab ~= "favorites")
        row.valueText:SetShown(activeTab ~= "favorites")
        row.savedDeleteButton:SetShown(activeTab ~= "favorites")
        row.favoriteRemoveButton:SetShown(activeTab == "favorites" and not isExpansionHeader)
        row.favoriteExpansionText:SetShown(activeTab == "favorites" and not isExpansionHeader)
        row.favoriteRareText:SetShown(activeTab == "favorites" and not isExpansionHeader)
        row.favoriteItemText:SetShown(activeTab == "favorites" and not isExpansionHeader)
        row.favoriteSelectedText:SetShown(activeTab == "favorites" and not isExpansionHeader)
        row.favoriteMarketText:SetShown(activeTab == "favorites" and not isExpansionHeader)
        row.favoriteRegionText:SetShown(activeTab == "favorites" and not isExpansionHeader)
        row.favoriteAverageText:SetShown(activeTab == "favorites" and not isExpansionHeader)
        row.favoriteWowheadButton:SetShown(activeTab == "favorites" and not isExpansionHeader)
        if isExpansionHeader then
            row.groupHeaderText:ClearAllPoints()
            row.groupHeaderText:SetPoint("LEFT", row, "LEFT", 8, 0)
            row.groupHeaderText:SetPoint("RIGHT", row, "RIGHT", -8, 0)
            row.groupHeaderText:SetText(data.label or "Unknown")
            row.groupHeaderText:SetTextColor(1.0, 0.82, 0.18)
            row:SetScript("OnClick", nil)
        elseif activeTab == "favorites" then
            local favorite = data.row
            local favoriteKey = data.key
            EnsureRareFarmingRowItemDisplayData(self, favorite)
            local layout = GetRareFarmingFavoriteColumnLayout(contentWidth)
            local expansionLabel = favorite.expansionFilterLabel
                or (favorite.expansionFilterID and GetRareFarmingExpansionFilterLabel(favorite.expansionFilterID))
                or favorite.expansionLabel
                or favorite.locationLabel
                or "Unknown"
            local sourceLabel = favorite.rareName
                or favorite.bossName
                or favorite.instanceName
                or "Unknown source"

            row.npcID = favorite.npcID
            row.rareName = favorite.rareName
            row.itemID = favorite.itemID
            row.itemName = favorite.itemName
            row.itemLink = favorite.itemLink
            row.itemQuality = favorite.itemQuality
            row.iconTexture = favorite.icon
            row.value = favorite.value
            row.marketValue = favorite.marketValue
            row.regionMarketValue = favorite.regionMarketValue
            row.averageValue = favorite.averageValue
            row.valueSourceID = favorite.valueSourceID
            row.valueSourceLabel = favorite.valueSourceLabel
            row.locationLabel = favorite.locationLabel
            row.locations = favorite.locations
            row.rareSources = favorite.rareSources
            row.rareSourceCount = favorite.rareSourceCount
            row.instanceName = favorite.instanceName
            row.bossName = favorite.bossName
            row.farmingSourceType = favorite.farmingSourceType

            row.favoriteRemoveButton:ClearAllPoints()
            row.favoriteRemoveButton:SetPoint("LEFT", row, "LEFT", 0, 0)
            row.favoriteRemoveButton:SetScript("OnClick", function()
                local favorites = type(self.GetFarmingFavoriteStore) == "function" and self:GetFarmingFavoriteStore()
                    or (type(self.db) == "table" and self.db.rareFarmingFavorites or nil)
                if type(favorites) == "table" then
                    favorites[favoriteKey] = nil
                end
                self:RefreshRareFarmingWindow(false)
                self:RefreshRareFarmingLibraryWindow()
                if self.instanceFarmingFrame and type(self.RefreshInstanceFarmingWindow) == "function" then
                    self:RefreshInstanceFarmingWindow(false)
                    self:RefreshInstanceFarmingLibraryWindow()
                end
            end)
            row.favoriteExpansionText:ClearAllPoints()
            row.favoriteExpansionText:SetPoint("LEFT", row, "LEFT", layout.expansionX, 0)
            row.favoriteExpansionText:SetWidth(layout.expansionWidth)
            row.favoriteExpansionText:SetText(expansionLabel or "Unknown")
            row.favoriteRareText:ClearAllPoints()
            row.favoriteRareText:SetPoint("LEFT", row, "LEFT", layout.sourceX, 0)
            row.favoriteRareText:SetWidth(layout.sourceWidth)
            row.favoriteRareText:SetText(sourceLabel)
            row.favoriteItemText:ClearAllPoints()
            row.favoriteItemText:SetPoint("LEFT", row, "LEFT", layout.itemX, 0)
            row.favoriteItemText:SetWidth(layout.itemWidth)
            row.favoriteItemText:SetText(favorite.itemLink or favorite.itemName or ("Item " .. tostring(favorite.itemID)))
            row.favoriteSelectedText:ClearAllPoints()
            row.favoriteSelectedText:SetPoint("LEFT", row, "LEFT", layout.selectedX, 0)
            row.favoriteSelectedText:SetWidth(layout.valueWidth)
            row.favoriteSelectedText:SetText(self:FormatMoney(favorite.value or 0))
            row.favoriteMarketText:ClearAllPoints()
            row.favoriteMarketText:SetPoint("LEFT", row, "LEFT", layout.marketX, 0)
            row.favoriteMarketText:SetWidth(layout.valueWidth)
            row.favoriteMarketText:SetText(self:FormatMoney(favorite.marketValue or 0))
            row.favoriteRegionText:ClearAllPoints()
            row.favoriteRegionText:SetPoint("LEFT", row, "LEFT", layout.regionX, 0)
            row.favoriteRegionText:SetWidth(layout.valueWidth)
            row.favoriteRegionText:SetText(self:FormatMoney(favorite.regionMarketValue or 0))
            row.favoriteAverageText:ClearAllPoints()
            row.favoriteAverageText:SetPoint("LEFT", row, "LEFT", layout.averageX, 0)
            row.favoriteAverageText:SetWidth(layout.valueWidth)
            row.favoriteAverageText:SetText(self:FormatMoney(favorite.averageValue or 0))
            row.favoriteWowheadButton:ClearAllPoints()
            row.favoriteWowheadButton:SetPoint("LEFT", row, "LEFT", layout.detailsX, 0)
            row.favoriteWowheadButton:SetWidth(layout.detailsWidth)
            row:SetScript("OnEnter", function(self)
                SetRareFarmingItemTooltip(self)
            end)
            row:SetScript("OnLeave", function()
                GameTooltip:Hide()
            end)
            row:SetScript("OnClick", nil)
        else
            local entry = data.entry
            local scanKey = data.key
            local expansionLabel = entry.expansionFilterLabel or GetRareFarmingExpansionFilterLabel(entry.expansionFilterID)
            local itemCount = tonumber(entry.resultCount) or #(entry.results or {})
            local minimumValue = tonumber(entry.minimumValueCopper) or 0
            local sourceLabel = entry.valueSourceLabel or entry.valueSourceID or "Unknown source"
            row.scanKey = scanKey
            row.primaryText:SetPoint("RIGHT", row, "RIGHT", -202, 0)
            row.secondaryText:SetPoint("RIGHT", row, "RIGHT", -202, 0)
            row.primaryText:SetText(string.format("%s scan", expansionLabel or "Saved"))
            row.secondaryText:SetText(string.format(
                "%d items found | Threshold %s | %s | %s",
                itemCount,
                self:FormatMoney(minimumValue),
                sourceLabel,
                entry.savedAt or "unknown time"
            ))
            row.valueText:ClearAllPoints()
            row.valueText:SetPoint("RIGHT", row, "RIGHT", -86, 0)
            row.valueText:SetWidth(52)
            row.valueText:SetText("Open")
            row.savedDeleteButton:ClearAllPoints()
            row.savedDeleteButton:SetPoint("RIGHT", row, "RIGHT", -10, 0)
            row:SetScript("OnClick", function()
                self:OpenRareFarmingSavedScan(scanKey)
            end)
        end
        row.valueText:SetTextColor(0.68, 0.96, 0.72)
        row.primaryText:SetTextColor(0.92, 0.95, 1.0)
        row.secondaryText:SetTextColor(0.72, 0.76, 0.84)
        row.favoriteRemoveButton.text:SetTextColor(1.0, 0.82, 0.18)
        row.favoriteExpansionText:SetTextColor(0.72, 0.76, 0.84)
        row.favoriteRareText:SetTextColor(0.92, 0.95, 1.0)
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
    if frame.libraryEmptyText then
        frame.libraryEmptyText:SetShown(#entries == 0)
        frame.libraryEmptyText:SetText(activeTab == "favorites" and "No favorite farming items yet." or "No saved rare scans yet.")
    end
    if frame.libraryStatusText then
        frame.libraryStatusText:SetText(activeTab == "favorites"
            and string.format("%d favorite items grouped by expansion", favoriteCount or 0)
            or string.format("%d saved scans", #entries))
    end
end

function GoldTracker:RefreshRareFarmingWindowControls()
    local frame = self.rareFarmingFrame
    if not frame then
        return
    end

    local source = self.VALUE_SOURCE_BY_ID[frame.valueSourceID] or self:GetRareFarmingValueSource()
    frame.valueSourceID = source and source.id
    if frame.valueSourceDropdown and source then
        UIDropDownMenu_SetSelectedValue(frame.valueSourceDropdown, source.id)
        UIDropDownMenu_SetText(frame.valueSourceDropdown, source.label)
    end

    local minimumValue = tonumber(frame.minimumValueCopper) or self:GetRareFarmingMinimumValue()
    frame.minimumValueCopper = math.max(0, math.floor(minimumValue + 0.5))
    if frame.minimumValueInput and not frame.minimumValueInput:HasFocus() then
        frame.minimumValueInput:SetText(FormatRareFarmingGoldInput(self, frame.minimumValueCopper))
    end

    frame.expansionFilterID = self:GetRareFarmingExpansionFilter()
    if frame.expansionDropdown then
        local expansionOption = GetRareFarmingExpansionFilterOption(frame.expansionFilterID)
        UIDropDownMenu_SetSelectedValue(frame.expansionDropdown, expansionOption.id)
        UIDropDownMenu_SetText(frame.expansionDropdown, expansionOption.label)
    end

    frame.scanModeID = self:GetRareFarmingScanMode()
    if frame.scanModeDropdown then
        local scanModeOption = GetRareFarmingScanModeOption(frame.scanModeID)
        UIDropDownMenu_SetSelectedValue(frame.scanModeDropdown, scanModeOption.id)
        UIDropDownMenu_SetText(frame.scanModeDropdown, scanModeOption.label)
    end

    local isScanning = IsRareFarmingScanStateActive(frame.scanState)
    if frame.scanButton then
        frame.scanButton:SetEnabled(not isScanning)
        frame.scanButton:SetText(isScanning and "Scanning" or "Scan")
    end
    if frame.stopScanButton then
        frame.stopScanButton:SetEnabled(isScanning)
        frame.stopScanButton:SetAlpha(isScanning and 1 or 0.45)
    end
    local hasRows = type(frame.lastResults) == "table" and #frame.lastResults > 0
    local hasLoadedSavedScan = type(frame.loadedRareFarmingCache) == "table"
    if frame.updateScanPricesButton then
        frame.updateScanPricesButton:SetShown(hasLoadedSavedScan)
        frame.updateScanPricesButton:SetEnabled(hasLoadedSavedScan and not isScanning and hasRows)
        frame.updateScanPricesButton:SetAlpha((hasLoadedSavedScan and not isScanning and hasRows) and 1 or 0.45)
    end
    if frame.rescanScanButton then
        frame.rescanScanButton:SetShown(hasLoadedSavedScan)
        frame.rescanScanButton:SetEnabled(hasLoadedSavedScan and not isScanning)
        frame.rescanScanButton:SetAlpha((hasLoadedSavedScan and not isScanning) and 1 or 0.45)
    end
    if frame.savedScansButton then
        frame.savedScansButton:SetText("Save")
        frame.savedScansButton:SetEnabled(not isScanning)
        frame.savedScansButton:SetAlpha(not isScanning and 1 or 0.45)
    end
end

function GoldTracker:UpdateRareFarmingSortHeaderState()
    local frame = self.rareFarmingFrame
    if not frame then
        return
    end

    local sortKey = NormalizeRareFarmingSortKey(frame.sortKey)
    local sortAscending = frame.sortAscending == true
    local headers = {
        favorite = { button = frame.favoriteHeaderButton, label = "Tracked" },
        location = { button = frame.locationHeaderButton, label = "Location" },
        rareName = { button = frame.rareHeaderButton, label = "Rare" },
        itemName = { button = frame.itemHeaderButton, label = "Item" },
        value = { button = frame.valueHeaderButton, label = "Selected" },
        marketValue = { button = frame.marketHeaderButton, label = "Market" },
        regionMarketValue = { button = frame.regionMarketHeaderButton, label = "Region" },
        averageValue = { button = frame.averageHeaderButton, label = "Avg" },
    }

    for key, header in pairs(headers) do
        if header.button then
            header.button.text:SetText(header.label)
            if header.button.sortIcon then
                if key == sortKey then
                    local asset = sortAscending and "sortAscending" or "sortDescending"
                    Theme:SetTexture(header.button.sortIcon, asset)
                    header.button.sortIcon:Show()
                else
                    header.button.sortIcon:Hide()
                end
            end
        end
    end
end

function GoldTracker:ToggleRareFarmingSort(sortKey)
    local frame = self.rareFarmingFrame
    if not frame then
        return
    end

    local normalizedSortKey = NormalizeRareFarmingSortKey(sortKey)
    if frame.sortKey == normalizedSortKey then
        frame.sortAscending = not frame.sortAscending
    else
        frame.sortKey = normalizedSortKey
        frame.sortAscending = normalizedSortKey ~= "value"
            and normalizedSortKey ~= "marketValue"
            and normalizedSortKey ~= "regionMarketValue"
            and normalizedSortKey ~= "averageValue"
            and normalizedSortKey ~= "favorite"
    end

    self:RefreshRareFarmingWindow(false)
end

function GoldTracker:ScheduleRareFarmingWindowRefresh(scrollToTop)
    local frame = self.rareFarmingFrame
    if not frame then
        return
    end

    frame.pendingRareFarmingScrollToTop = frame.pendingRareFarmingScrollToTop or scrollToTop == true
    if frame.pendingRareFarmingRefresh then
        return
    end
    frame.pendingRareFarmingRefresh = true

    if C_Timer and type(C_Timer.After) == "function" then
        C_Timer.After(RARE_FARMING_ITEM_REFRESH_DELAY, function()
            local refreshFrame = self.rareFarmingFrame
            if not refreshFrame then
                return
            end

            local shouldScrollToTop = refreshFrame.pendingRareFarmingScrollToTop == true
            refreshFrame.pendingRareFarmingRefresh = false
            refreshFrame.pendingRareFarmingScrollToTop = false
            if refreshFrame:IsShown() then
                self:RefreshRareFarmingWindow(shouldScrollToTop)
            end
        end)
        return
    end

    frame.pendingRareFarmingRefresh = false
    frame.pendingRareFarmingScrollToTop = false
    self:RefreshRareFarmingWindow(scrollToTop)
end

local function SetRareFarmingColumn(frameOrText, row, left, width)
    if not frameOrText then
        return
    end

    frameOrText:ClearAllPoints()
    frameOrText:SetPoint("LEFT", row, "LEFT", left, 0)
    frameOrText:SetWidth(width)
end

local function SetRareFarmingHeaderColumn(frameOrText, listPanel, left, width)
    if not frameOrText then
        return
    end

    frameOrText:ClearAllPoints()
    frameOrText:SetPoint("TOPLEFT", listPanel, "TOPLEFT", left, -12)
    frameOrText:SetWidth(width)
end

local function GetRareFarmingTableViewportWidth(frame)
    local width = 0
    if frame and frame.scrollFrame then
        width = tonumber(frame.scrollFrame:GetWidth()) or 0
    end
    if width <= 1 and frame and frame.listPanel then
        width = (tonumber(frame.listPanel:GetWidth()) or 0) - 38
    end
    return math.max(1, math.floor(width - 6))
end

local function GetRareFarmingHorizontalOffset(frame)
    return math.max(0, math.floor(tonumber(frame and frame.horizontalScrollOffset) or 0))
end

local function GetRareFarmingVerticalScrollBar(scrollFrame)
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

local function RefreshRareFarmingVerticalScrollFrame(frame)
    if not frame or not frame.scrollFrame then
        return
    end

    if frame.scrollFrame.UpdateScrollChildRect then
        frame.scrollFrame:UpdateScrollChildRect()
    end

    local scrollBar = GetRareFarmingVerticalScrollBar(frame.scrollFrame)
    if scrollBar then
        frame.verticalScrollBar = scrollBar
        SetRareFarmingFrameLevel(scrollBar, frame.listPanel or frame.scrollFrame, 3)
    end
end

local function UpdateRareFarmingHorizontalScroll(frame)
    if not frame then
        return
    end

    local maxOffset = math.max(0, math.floor((tonumber(frame.tableWidth) or 0) - GetRareFarmingTableViewportWidth(frame)))
    local offset = math.min(GetRareFarmingHorizontalOffset(frame), maxOffset)
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

local function ApplyRareFarmingTableColumnLayout(frame)
    if not frame or not frame.listPanel then
        return
    end

    local availableWidth = GetRareFarmingTableViewportWidth(frame)
    local favoriteX = RARE_FARMING_ROW_RIGHT_PADDING
    local locationX = favoriteX + RARE_FARMING_FAVORITE_WIDTH + RARE_FARMING_COLUMN_GAP
    local rareX = locationX + RARE_FARMING_LOCATION_WIDTH + RARE_FARMING_COLUMN_GAP
    local fixedWidth =
        RARE_FARMING_FAVORITE_WIDTH
        + RARE_FARMING_LOCATION_WIDTH
        + RARE_FARMING_RARE_WIDTH
        + (RARE_FARMING_VALUE_WIDTH * 4)
        + RARE_FARMING_WOWHEAD_BUTTON_WIDTH
        + RARE_FARMING_MAP_BUTTON_WIDTH
        + (RARE_FARMING_COLUMN_GAP * 8)
        + RARE_FARMING_ROW_RIGHT_PADDING
    local tableWidth = math.max(availableWidth, fixedWidth + RARE_FARMING_ITEM_MIN_WIDTH)
    frame.tableWidth = tableWidth
    if frame.content then
        frame.content:SetWidth(tableWidth)
    end
    UpdateRareFarmingHorizontalScroll(frame)

    local horizontalOffset = GetRareFarmingHorizontalOffset(frame)
    local mapX = tableWidth - RARE_FARMING_MAP_BUTTON_WIDTH - RARE_FARMING_ROW_RIGHT_PADDING
    local wowheadX = mapX - RARE_FARMING_COLUMN_GAP - RARE_FARMING_WOWHEAD_BUTTON_WIDTH
    local averageX = wowheadX - RARE_FARMING_COLUMN_GAP - RARE_FARMING_VALUE_WIDTH
    local regionMarketX = averageX - RARE_FARMING_COLUMN_GAP - RARE_FARMING_VALUE_WIDTH
    local marketX = regionMarketX - RARE_FARMING_COLUMN_GAP - RARE_FARMING_VALUE_WIDTH
    local valueX = marketX - RARE_FARMING_COLUMN_GAP - RARE_FARMING_VALUE_WIDTH
    local itemX = rareX + RARE_FARMING_RARE_WIDTH + RARE_FARMING_COLUMN_GAP
    local itemWidth = math.max(RARE_FARMING_ITEM_MIN_WIDTH, valueX - RARE_FARMING_COLUMN_GAP - itemX)

    local headerX = RARE_FARMING_HEADER_LEFT_INSET
    SetRareFarmingHeaderColumn(frame.favoriteHeaderButton, frame.listPanel, headerX + favoriteX - horizontalOffset, RARE_FARMING_FAVORITE_WIDTH)
    SetRareFarmingHeaderColumn(frame.locationHeaderButton, frame.listPanel, headerX + locationX - horizontalOffset, RARE_FARMING_LOCATION_WIDTH)
    SetRareFarmingHeaderColumn(frame.rareHeaderButton, frame.listPanel, headerX + rareX - horizontalOffset, RARE_FARMING_RARE_WIDTH)
    SetRareFarmingHeaderColumn(frame.itemHeaderButton, frame.listPanel, headerX + itemX - horizontalOffset, itemWidth)
    SetRareFarmingHeaderColumn(frame.valueHeaderButton, frame.listPanel, headerX + valueX - horizontalOffset, RARE_FARMING_VALUE_WIDTH)
    SetRareFarmingHeaderColumn(frame.marketHeaderButton, frame.listPanel, headerX + marketX - horizontalOffset, RARE_FARMING_VALUE_WIDTH)
    SetRareFarmingHeaderColumn(frame.regionMarketHeaderButton, frame.listPanel, headerX + regionMarketX - horizontalOffset, RARE_FARMING_VALUE_WIDTH)
    SetRareFarmingHeaderColumn(frame.averageHeaderButton, frame.listPanel, headerX + averageX - horizontalOffset, RARE_FARMING_VALUE_WIDTH)
    SetRareFarmingHeaderColumn(frame.wowheadHeaderButton, frame.listPanel, headerX + wowheadX - horizontalOffset, RARE_FARMING_WOWHEAD_BUTTON_WIDTH)
    SetRareFarmingHeaderColumn(frame.mapHeaderButton, frame.listPanel, headerX + mapX - horizontalOffset, RARE_FARMING_MAP_BUTTON_WIDTH)

    for _, row in ipairs(frame.rows or {}) do
        if row.favoriteButton then
            row.favoriteButton:ClearAllPoints()
            row.favoriteButton:SetPoint(
                "LEFT",
                row,
                "LEFT",
                favoriteX + math.floor((RARE_FARMING_FAVORITE_WIDTH - RARE_FARMING_TRACKED_BUTTON_WIDTH) / 2) - horizontalOffset,
                0
            )
            row.favoriteButton:SetSize(RARE_FARMING_TRACKED_BUTTON_WIDTH, RARE_FARMING_TRACKED_BUTTON_HEIGHT)
        end
        SetRareFarmingColumn(row.locationButton, row, locationX - horizontalOffset, RARE_FARMING_LOCATION_WIDTH)
        SetRareFarmingColumn(row.locationText, row, locationX - horizontalOffset, RARE_FARMING_LOCATION_WIDTH)
        SetRareFarmingColumn(row.rareText, row, rareX - horizontalOffset, RARE_FARMING_RARE_WIDTH)
        SetRareFarmingColumn(row.itemText, row, itemX + RARE_FARMING_ICON_SIZE + 8 - horizontalOffset, math.max(80, itemWidth - RARE_FARMING_ICON_SIZE - 8))
        SetRareFarmingColumn(row.valueText, row, valueX - horizontalOffset, RARE_FARMING_VALUE_WIDTH)
        SetRareFarmingColumn(row.marketText, row, marketX - horizontalOffset, RARE_FARMING_VALUE_WIDTH)
        SetRareFarmingColumn(row.regionMarketText, row, regionMarketX - horizontalOffset, RARE_FARMING_VALUE_WIDTH)
        SetRareFarmingColumn(row.averageText, row, averageX - horizontalOffset, RARE_FARMING_VALUE_WIDTH)
        SetRareFarmingColumn(row.wowheadButton, row, wowheadX - horizontalOffset, RARE_FARMING_WOWHEAD_BUTTON_WIDTH)
        SetRareFarmingColumn(row.mapButton, row, mapX - horizontalOffset, RARE_FARMING_MAP_BUTTON_WIDTH)
        if row.icon then
            row.icon:ClearAllPoints()
            row.icon:SetPoint("LEFT", row, "LEFT", itemX - horizontalOffset, 0)
        end
    end
end

local function ScrollRareFarmingResultsVertically(scrollFrame, delta)
    if not scrollFrame then
        return
    end

    if scrollFrame.UpdateScrollChildRect then
        scrollFrame:UpdateScrollChildRect()
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
    local scrollBar = GetRareFarmingVerticalScrollBar(scrollFrame)
    if scrollBar and scrollBar.SetValue then
        scrollBar:SetValue(nextScroll)
    end
end

local function ScrollRareFarmingResultsHorizontally(frame, delta)
    if not frame or not (type(IsShiftKeyDown) == "function" and IsShiftKeyDown()) then
        return false
    end

    local maxOffset = math.max(0, math.floor((tonumber(frame.tableWidth) or 0) - GetRareFarmingTableViewportWidth(frame)))
    if maxOffset <= 0 then
        return false
    end

    local currentOffset = math.min(GetRareFarmingHorizontalOffset(frame), maxOffset)
    local step = math.max(20, math.floor(GetRareFarmingTableViewportWidth(frame) * 0.10))
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
            ApplyRareFarmingTableColumnLayout(frame)
        end
    end
    return true
end

local function HandleRareFarmingResultsMouseWheel(frame, delta)
    if ScrollRareFarmingResultsHorizontally(frame, delta) then
        return
    end
    ScrollRareFarmingResultsVertically(frame and frame.scrollFrame, delta)
end

local function BindRareFarmingResultsMouseWheel(frameObject, frame)
    if not frameObject or not frameObject.EnableMouseWheel then
        return
    end
    frameObject:EnableMouseWheel(true)
    frameObject:SetScript("OnMouseWheel", function(_, delta)
        HandleRareFarmingResultsMouseWheel(frame, delta)
    end)
end

function GoldTracker:GetRareFarmingWindowRow(index)
    local frame = self.rareFarmingFrame
    if not frame then
        return nil
    end
    frame.rows = frame.rows or {}
    if frame.rows[index] then
        SetRareFarmingFrameLevel(frame.rows[index], frame.content, 1)
        return frame.rows[index]
    end

    local row = CreateFrame("Button", nil, frame.content)
    SetRareFarmingFrameLevel(row, frame.content, 1)
    row:SetHeight(RARE_FARMING_ROW_HEIGHT)
    row:RegisterForClicks("LeftButtonUp")
    row:EnableMouse(true)
    BindRareFarmingResultsMouseWheel(row, frame)

    local background = row:CreateTexture(nil, "BACKGROUND")
    background:SetAllPoints(row)
    row.background = background

    local favoriteButton = CreateRareFarmingButton(row, RARE_FARMING_TRACKED_BUTTON_WIDTH, RARE_FARMING_TRACKED_BUTTON_HEIGHT, "+", "neutral")
    BindRareFarmingResultsMouseWheel(favoriteButton, frame)
    favoriteButton:RegisterForClicks("LeftButtonUp")
    favoriteButton:SetScript("OnClick", function(self)
        GoldTracker:ToggleRareFarmingFavorite(self:GetParent())
    end)
    favoriteButton:SetScript("OnEnter", function(self)
        self.isHovered = true
        if self.theme and self.theme.UpdateButtonVisual then
            self.theme:UpdateButtonVisual(self)
        end
        GameTooltip:SetOwner(self, "ANCHOR_CURSOR")
        GameTooltip:AddLine(self:GetParent().favorite and "Remove tracked item" or "Track item", 1, 1, 1)
        GameTooltip:Show()
    end)
    favoriteButton:SetScript("OnLeave", function(self)
        self.isHovered = false
        self.isPressed = false
        if self.theme and self.theme.UpdateButtonVisual then
            self.theme:UpdateButtonVisual(self)
        end
        GameTooltip:Hide()
    end)
    row.favoriteButton = favoriteButton

    local locationText = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    locationText:SetJustifyH("LEFT")
    locationText:SetWordWrap(false)
    row.locationText = locationText

    local locationButton = CreateFrame("Button", nil, row)
    locationButton:SetHeight(RARE_FARMING_ROW_HEIGHT)
    BindRareFarmingResultsMouseWheel(locationButton, frame)
    locationButton:RegisterForClicks("LeftButtonUp")
    locationButton:SetScript("OnClick", function(self)
        GoldTracker:SetRareFarmingWaypoint(self:GetParent())
    end)
    locationButton:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_CURSOR")
        GameTooltip:AddLine("Set waypoint", 1, 1, 1)
        local parent = self:GetParent()
        if parent and parent.locationLabel then
            GameTooltip:AddLine(parent.locationLabel, 0.72, 0.76, 0.84)
        end
        GameTooltip:Show()
    end)
    locationButton:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)
    row.locationButton = locationButton

    local rareText = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    rareText:SetJustifyH("LEFT")
    rareText:SetWordWrap(false)
    row.rareText = rareText

    local icon = row:CreateTexture(nil, "ARTWORK")
    icon:SetSize(RARE_FARMING_ICON_SIZE, RARE_FARMING_ICON_SIZE)
    row.icon = icon

    local itemText = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    itemText:SetJustifyH("LEFT")
    itemText:SetWordWrap(false)
    row.itemText = itemText

    local valueText = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    valueText:SetJustifyH("RIGHT")
    valueText:SetWordWrap(false)
    row.valueText = valueText

    local marketText = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    marketText:SetJustifyH("RIGHT")
    marketText:SetWordWrap(false)
    row.marketText = marketText

    local regionMarketText = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    regionMarketText:SetJustifyH("RIGHT")
    regionMarketText:SetWordWrap(false)
    row.regionMarketText = regionMarketText

    local averageText = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    averageText:SetJustifyH("RIGHT")
    averageText:SetWordWrap(false)
    row.averageText = averageText

    local wowheadButton = CreateRareFarmingButton(row, RARE_FARMING_WOWHEAD_BUTTON_WIDTH, 20, "Details", "neutral")
    BindRareFarmingResultsMouseWheel(wowheadButton, frame)
    wowheadButton:RegisterForClicks("LeftButtonUp")
    wowheadButton:SetScript("OnClick", function(self)
        GoldTracker:OpenInventoryItemDetailsWindow(self:GetParent())
    end)
    wowheadButton:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_CURSOR")
        GameTooltip:AddLine("Open price history", 1, 1, 1)
        GameTooltip:Show()
    end)
    wowheadButton:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)
    row.wowheadButton = wowheadButton

    local mapButton = CreateRareFarmingButton(row, RARE_FARMING_MAP_BUTTON_WIDTH, 20, "Map", "neutral")
    BindRareFarmingResultsMouseWheel(mapButton, frame)
    mapButton:RegisterForClicks("LeftButtonUp")
    mapButton:SetScript("OnClick", function(self)
        GoldTracker:OpenRareFarmingMap(self:GetParent())
    end)
    mapButton:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_CURSOR")
        if self:GetParent().hasRareFarmingMap then
            GameTooltip:AddLine("Open rare map", 1, 1, 1)
            GameTooltip:AddLine("Shows every known rare location for this item.", 0.72, 0.86, 1.0)
        else
            GameTooltip:AddLine("No map data yet", 1, 1, 1)
            GameTooltip:AddLine("This rare does not have coordinate-backed locations yet.", 0.72, 0.86, 1.0)
        end
        GameTooltip:Show()
    end)
    mapButton:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)
    row.mapButton = mapButton

    local divider = row:CreateTexture(nil, "ARTWORK")
    divider:SetColorTexture(1, 1, 1, 0.045)
    divider:SetPoint("BOTTOMLEFT", row, "BOTTOMLEFT", 0, 0)
    divider:SetPoint("BOTTOMRIGHT", row, "BOTTOMRIGHT", 0, 0)
    divider:SetHeight(1)
    row.divider = divider

    row:SetScript("OnEnter", function(self)
        SetRareFarmingItemTooltip(self)
    end)
    row:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)
    row:SetScript("OnClick", function(self)
        GoldTracker:HandleModifiedItemClickIfModified(self)
    end)

    frame.rows[index] = row
    return row
end

function GoldTracker:UpdateRareFarmingScanProgress()
    local frame = self.rareFarmingFrame
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
        local expansionLabel = state.expansionFilterLabel or "selected expansion"
        local scanModeLabel = state.scanModeLabel or GetRareFarmingScanModeOption(state.scanModeID).label
        frame.statusText:SetText(string.format(
            "Scanning %s (%s): %d / %d drops, %d matches",
            expansionLabel,
            scanModeLabel,
            math.min(scanned, total),
            total,
            #(state.results or {})
        ))
    end
end

function GoldTracker:GetRareFarmingScanWorker()
    if not self.rareFarmingScanWorker then
        self.rareFarmingScanWorker = CreateFrame("Frame")
        self.rareFarmingScanWorker:Hide()
    end
    return self.rareFarmingScanWorker
end

function GoldTracker:StopRareFarmingScanWorker()
    local worker = self.rareFarmingScanWorker
    if worker then
        worker:SetScript("OnUpdate", nil)
        worker.scanState = nil
        worker:Hide()
    end
end

function GoldTracker:NotifyRareFarmingScanComplete(resultCount, expansionLabel)
    local label = type(expansionLabel) == "string" and expansionLabel ~= "" and expansionLabel or "selected expansion"
    if type(self.Print) == "function" then
        self:Print(string.format("Rare Farming scan complete for %s: %d matching drops.", label, tonumber(resultCount) or 0))
    end
    if UIErrorsFrame and type(UIErrorsFrame.AddMessage) == "function" then
        UIErrorsFrame:AddMessage("General Gold Tracker: Rare Farming scan complete.", 1.0, 0.82, 0.18)
    end
end

function GoldTracker:FinishRareFarmingScan()
    local frame = self.rareFarmingFrame
    if not frame then
        return
    end

    self:StopRareFarmingScanWorker()
    frame:SetScript("OnUpdate", nil)
    local state = frame.scanState
    local resultCount = state and #(state.results or {}) or 0
    local expansionLabel = state and state.expansionFilterLabel or GetRareFarmingExpansionFilterLabel(self:GetRareFarmingExpansionFilter())
    if state then
        local entry, cacheKey = self:SaveRareFarmingScanCache(state, frame.editingRareFarmingCacheKey)
        if frame.editingRareFarmingCacheKey and entry then
            frame.loadedRareFarmingCache = entry
            frame.loadedRareFarmingCacheKey = cacheKey
            frame.editingRareFarmingCacheKey = cacheKey
        end
    end
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
        frame.statusText:SetText(string.format("Scan complete for %s: %d matching rare drops.", expansionLabel, resultCount))
    end
    if frame:IsShown() then
        self:RefreshRareFarmingWindow(true)
    end
    self:NotifyRareFarmingScanComplete(resultCount, expansionLabel)
end

function GoldTracker:CancelRareFarmingScan()
    local frame = self.rareFarmingFrame
    if not frame or not IsRareFarmingScanStateActive(frame.scanState) then
        return
    end

    local state = frame.scanState
    state.cancelled = true
    self:StopRareFarmingScanWorker()

    local scanned = tonumber(state.scannedDrops) or 0
    local total = math.max(1, tonumber(state.totalDrops) or 1)
    local resultCount = #(state.results or {})
    if frame.progressBar then
        frame.progressBar:SetMinMaxValues(0, total)
        frame.progressBar:SetValue(math.min(scanned, total))
    end
    if frame.statusText then
        frame.statusText:SetText(string.format(
            "Scan stopped: %d / %d drops scanned, %d matches kept.",
            math.min(scanned, total),
            total,
            resultCount
        ))
    end

    self:RefreshRareFarmingWindow(false)
end

local function ProcessRareFarmingScanFrame(worker, elapsed)
    local addon = GoldTracker
    local state = worker and worker.scanState or nil
    if type(state) ~= "table" then
        if worker then
            worker:SetScript("OnUpdate", nil)
            worker:Hide()
        end
        return
    end
    if state.cancelled then
        addon:StopRareFarmingScanWorker()
        return
    end

    local processed = 0
    local batchSize = tonumber(state.scanBatchSize) or RARE_FARMING_BACKGROUND_SCAN_ITEMS_PER_TICK
    while processed < batchSize and state.rareIndex <= #state.rareIDs do
        local npcID = state.rareIDs[state.rareIndex]
        local rare = state.rares[npcID]
        local loot = rare and rare.loot or nil
        if type(loot) ~= "table" or #loot == 0 then
            state.rareIndex = state.rareIndex + 1
            state.lootIndex = 1
        else
            local itemID = tonumber(loot[state.lootIndex])
            state.lootIndex = state.lootIndex + 1
            state.scannedDrops = (state.scannedDrops or 0) + 1
            processed = processed + 1

            if itemID then
                itemID = math.floor(itemID + 0.5)
                local itemCache = ResolveRareFarmingItemCache(addon, state, itemID)
                if itemCache.value > state.minimumValueCopper and itemCache.auctionable ~= false then
                    AddRareFarmingResult(state, rare, itemID, itemCache)
                end
            end

            if state.lootIndex > #loot then
                state.rareIndex = state.rareIndex + 1
                state.lootIndex = 1
            end
        end
    end

    addon:UpdateRareFarmingScanProgress()
    state.refreshElapsed = (state.refreshElapsed or 0) + (elapsed or 0)
    if state.refreshElapsed >= RARE_FARMING_SCAN_REFRESH_INTERVAL then
        state.refreshElapsed = 0
        if addon.rareFarmingFrame and addon.rareFarmingFrame:IsShown() then
            addon:RefreshRareFarmingWindow(false)
        end
    end

    if state.rareIndex > #state.rareIDs then
        addon:FinishRareFarmingScan()
    end
end

function GoldTracker:StartRareFarmingScan()
    local frame = self.rareFarmingFrame
    if not frame then
        return
    end

    self:SaveRareFarmingMinimumValueInput(true)
    self:StopRareFarmingScanWorker()
    local source = self.VALUE_SOURCE_BY_ID[frame.valueSourceID] or self:GetRareFarmingValueSource()
    if not source or not source.tsmKey then
        frame.statusText:SetText("Select a TSM value source before scanning.")
        return
    end
    if type(TSM_API) ~= "table" or type(TSM_API.GetCustomPriceValue) ~= "function" then
        frame.statusText:SetText("TradeSkillMaster API is unavailable.")
        return
    end

    local expansionFilterID = self:GetRareFarmingExpansionFilter()
    local expansionFilterLabel = GetRareFarmingExpansionFilterLabel(expansionFilterID)
    local scanModeOption = GetRareFarmingScanModeOption(self:GetRareFarmingScanMode())
    local rares, rareIDs, totalDrops, errorMessage = BuildRareFarmingRareList(expansionFilterID)
    if totalDrops <= 0 then
        frame.statusText:SetText(errorMessage or string.format("No RareScanner rare loot data is available for %s.", expansionFilterLabel))
        return
    end

    frame.scanState = {
        valueSource = source,
        minimumValueCopper = self:GetRareFarmingMinimumValue(),
        expansionFilterID = expansionFilterID,
        expansionFilterLabel = expansionFilterLabel,
        scanModeID = scanModeOption.id,
        scanModeLabel = scanModeOption.label,
        scanBatchSize = scanModeOption.batchSize,
        rares = rares,
        rareIDs = rareIDs,
        totalDrops = totalDrops,
        scannedDrops = 0,
        rareIndex = 1,
        lootIndex = 1,
        itemCache = {},
        results = {},
        resultsByKey = {},
    }
    frame.hasRareFarmingScanRun = true
    frame.loadedRareFarmingCacheKey = nil
    frame.loadedRareFarmingCache = nil

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
            expansionFilterLabel,
            scanModeOption.label,
            totalDrops
        ))
    end

    self:RefreshRareFarmingWindow(true)
    local worker = self:GetRareFarmingScanWorker()
    worker.scanState = frame.scanState
    worker:Show()
    worker:SetScript("OnUpdate", ProcessRareFarmingScanFrame)
end

function GoldTracker:RefreshRareFarmingWindow(scrollToTop)
    local frame = self.rareFarmingFrame
    if not frame then
        return
    end

    frame.isRareFarmingRefreshing = true
    local scrollOnly = frame.rareFarmingScrollOnlyRefresh == true
    if not scrollOnly then
        self:RefreshRareFarmingWindowControls()
        self:UpdateRareFarmingSortHeaderState()
    end

    local state = frame.scanState
    local displayRows = {}
    if scrollOnly and type(frame.lastResults) == "table" then
        displayRows = frame.lastResults
    else
        local rows = BuildRareFarmingGroupedRows(type(state) == "table" and state.results or frame.lastResults or {})
        for _, row in ipairs(rows) do
            local itemCache = state and state.itemCache and state.itemCache[row.itemID] or nil
            if itemCache then
                row.itemName = itemCache.itemName or row.itemName
                row.itemLink = itemCache.itemLink or row.itemLink
                row.itemQuality = itemCache.itemQuality or row.itemQuality
                row.icon = itemCache.icon or row.icon
            end
            EnsureRareFarmingRowItemDisplayData(self, row)
            row.favorite = self:IsRareFarmingFavorite(row)
            displayRows[#displayRows + 1] = row
        end
        SortRareFarmingRows(displayRows, frame.sortKey, frame.sortAscending)
        frame.lastResults = displayRows
    end
    local resultCount = #displayRows

    local contentHeight = resultCount > 0
        and ((resultCount - 1) * RARE_FARMING_ROW_STRIDE + RARE_FARMING_ROW_HEIGHT)
        or 1
    if frame.content then
        local contentWidth = frame.tableWidth
            or (frame.scrollFrame and math.max(1, math.floor(frame.scrollFrame:GetWidth() or 1)))
            or 1
        frame.content:SetWidth(contentWidth)
        frame.content:SetHeight(contentHeight)
    end
    RefreshRareFarmingVerticalScrollFrame(frame)
    if scrollToTop and frame.scrollFrame then
        frame.suppressRareFarmingScrollRefresh = true
        frame.scrollFrame:SetVerticalScroll(0)
        frame.suppressRareFarmingScrollRefresh = false
    end

    if frame.emptyText then
        local isScanning = IsRareFarmingScanStateActive(state)
        if resultCount == 0 then
            frame.emptyText:Show()
            if isScanning then
                frame.emptyText:SetText(string.format(
                    "Scanning rare drops for %s...",
                    state.expansionFilterLabel or "selected expansion"
                ))
            elseif frame.hasRareFarmingScanRun then
                frame.emptyText:SetText("No rare drops above the selected value.")
            else
                frame.emptyText:SetText("Press Scan to build a rare-drop farm list.")
            end
        else
            frame.emptyText:Hide()
        end
    end

    local scrollOffset = frame.scrollFrame and (tonumber(frame.scrollFrame:GetVerticalScroll()) or 0) or 0
    local visibleHeight = frame.scrollFrame and (tonumber(frame.scrollFrame:GetHeight()) or 0) or RARE_FARMING_WINDOW_HEIGHT
    local firstResultIndex = resultCount > 0 and math.max(1, math.floor(scrollOffset / RARE_FARMING_ROW_STRIDE) + 1) or 1
    local visibleRowCount = math.max(1, math.ceil(visibleHeight / RARE_FARMING_ROW_STRIDE) + 2)
    local lastResultIndex = math.min(resultCount, firstResultIndex + visibleRowCount - 1)
    local poolIndex = 1

    for resultIndex = firstResultIndex, lastResultIndex do
        local result = displayRows[resultIndex]
        local row = self:GetRareFarmingWindowRow(poolIndex)
        if row then
            row.npcID = result.npcID
            row.rareName = result.rareName
            row.itemID = result.itemID
            row.itemName = result.itemName
            row.itemLink = result.itemLink
            row.itemQuality = result.itemQuality
            row.iconTexture = result.icon
            row.locationLabel = result.locationLabel
            row.locations = result.locations
            row.rareSources = result.rareSources
            row.rareSourceCount = result.rareSourceCount
            row.hasRareFarmingMap = #BuildRareFarmingMapOptionsFromRow(result) > 0
            row.value = result.value
            row.marketValue = result.marketValue
            row.regionMarketValue = result.regionMarketValue
            row.averageValue = result.averageValue
            row.valueSourceID = result.valueSourceID
            row.valueSourceLabel = result.valueSourceLabel
            row.favorite = self:IsRareFarmingFavorite(result)

            row.favoriteButton:SetText(row.favorite and "-" or "+")
            if row.favoriteButton.SetSelected then
                row.favoriteButton:SetSelected(row.favorite)
            end
            row.locationText:SetText(result.locationLabel or "Unknown")
            row.rareText:SetText(result.rareName or tostring(result.npcID or "Unknown"))
            row.itemText:SetText(result.itemLink or result.itemName or ("Item " .. tostring(result.itemID)))
            row.valueText:SetText(self:FormatMoney(result.value or 0))
            row.marketText:SetText(self:FormatMoney(result.marketValue or 0))
            row.regionMarketText:SetText(self:FormatMoney(result.regionMarketValue or 0))
            row.averageText:SetText(self:FormatMoney(result.averageValue or 0))
            if row.mapButton then
                row.mapButton:SetText("Map")
                if row.mapButton.SetEnabled then
                    row.mapButton:SetEnabled(true)
                end
                if row.mapButton.SetAlpha then
                    row.mapButton:SetAlpha(row.hasRareFarmingMap and 1 or 0.42)
                end
            end
            row.valueText:SetTextColor(0.68, 0.96, 0.72)
            row.marketText:SetTextColor(0.68, 0.86, 1.0)
            row.regionMarketText:SetTextColor(0.78, 0.82, 1.0)
            row.averageText:SetTextColor(0.92, 0.78, 1.0)
            row.locationText:SetTextColor(0.72, 0.76, 0.84)
            row.rareText:SetTextColor(0.92, 0.95, 1.0)
            if result.icon then
                row.icon:SetTexture(result.icon)
                row.icon:Show()
            else
                row.icon:Hide()
            end
            if row.background then
                row.background:SetColorTexture(1, 1, 1, resultIndex % 2 == 0 and 0.045 or 0.022)
            end
            if row.divider then
                row.divider:SetShown(resultIndex < resultCount)
            end

            row:ClearAllPoints()
            row:SetPoint("TOPLEFT", frame.content, "TOPLEFT", 0, -((resultIndex - 1) * RARE_FARMING_ROW_STRIDE))
            row:SetPoint("TOPRIGHT", frame.content, "TOPRIGHT", 0, -((resultIndex - 1) * RARE_FARMING_ROW_STRIDE))
            row:SetHeight(RARE_FARMING_ROW_HEIGHT)
            row:Show()
        end
        poolIndex = poolIndex + 1
    end

    for index = poolIndex, #(frame.rows or {}) do
        if frame.rows[index] then
            frame.rows[index]:Hide()
        end
    end

    if frame.metaText then
        local source = self.VALUE_SOURCE_BY_ID[frame.valueSourceID] or self:GetRareFarmingValueSource()
        local installedText = IsRareScannerInstalledOrLoaded() and "RareScanner detected" or "RareScanner not detected"
        local expansionLabel = GetRareFarmingExpansionFilterLabel(frame.expansionFilterID or self:GetRareFarmingExpansionFilter())
        local scanModeOption = GetRareFarmingScanModeOption(frame.scanModeID or self:GetRareFarmingScanMode())
        frame.metaText:SetText(string.format(
            "%d results | %s | %s | %s | Snapshot %s | %s",
            resultCount,
            source and source.label or "Unknown source",
            expansionLabel,
            scanModeOption.label,
            GetRareScannerRuntimeVersion(),
            installedText
        ))
    end

    ApplyRareFarmingTableColumnLayout(frame)
    frame.isRareFarmingRefreshing = false
end

function GoldTracker:CreateRareFarmingWindow()
    if self.rareFarmingFrame then
        return
    end

    local addon = self
    local frame = CreateFrame("Frame", "GoldTrackerRareFarmingFrame", UIParent, "BasicFrameTemplateWithInset")
    frame:SetSize(RARE_FARMING_WINDOW_WIDTH, RARE_FARMING_WINDOW_HEIGHT)
    frame:SetPoint("CENTER", UIParent, "CENTER", 0, 40)
    frame:SetFrameStrata("DIALOG")
    if frame.SetToplevel then
        frame:SetToplevel(true)
    end
    frame:SetMovable(true)
    frame:SetResizable(true)
    if frame.SetResizeBounds then
        frame:SetResizeBounds(
            RARE_FARMING_WINDOW_MIN_WIDTH,
            RARE_FARMING_WINDOW_MIN_HEIGHT,
            RARE_FARMING_WINDOW_MAX_WIDTH,
            RARE_FARMING_WINDOW_MAX_HEIGHT
        )
    else
        if frame.SetMinResize then
            frame:SetMinResize(RARE_FARMING_WINDOW_MIN_WIDTH, RARE_FARMING_WINDOW_MIN_HEIGHT)
        end
        if frame.SetMaxResize then
            frame:SetMaxResize(RARE_FARMING_WINDOW_MAX_WIDTH, RARE_FARMING_WINDOW_MAX_HEIGHT)
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

    local source = self:GetRareFarmingValueSource()
    frame.valueSourceID = source and source.id
    frame.minimumValueCopper = self:GetRareFarmingMinimumValue()
    frame.expansionFilterID = self:GetRareFarmingExpansionFilter()
    frame.scanModeID = self:GetRareFarmingScanMode()
    frame.rows = {}
    frame.sortKey = RARE_FARMING_SORT_KEY_DEFAULT
    frame.sortAscending = false

    local chrome = Theme:ApplyWindowChrome(frame, "Rare Farming")
    Theme:RegisterSpecialFrame("GoldTrackerRareFarmingFrame")

    frame.rareFarmingLibraryTab = "saved"
    frame.rareFarmingNavigationTab = "saved"

    local savedTabButton = CreateRareFarmingButton(frame, 104, 24, "Saved Scans", "primary")
    savedTabButton:SetPoint("TOPLEFT", chrome, "TOPLEFT", 12, -54)
    savedTabButton:SetScript("OnClick", function()
        frame.rareFarmingLibraryTab = "saved"
        frame.rareFarmingNavigationTab = "saved"
        addon:SetRareFarmingWindowView("library")
        addon:RefreshRareFarmingLibraryWindow()
    end)
    frame.librarySavedTabButton = savedTabButton

    local favoritesTabButton = CreateRareFarmingButton(frame, 96, 24, "Favorites", "neutral")
    favoritesTabButton:SetPoint("LEFT", savedTabButton, "RIGHT", 8, 0)
    favoritesTabButton:SetScript("OnClick", function()
        frame.rareFarmingLibraryTab = "favorites"
        frame.rareFarmingNavigationTab = "favorites"
        addon:SetRareFarmingWindowView("library")
        addon:RefreshRareFarmingLibraryWindow()
    end)
    frame.libraryFavoritesTabButton = favoritesTabButton

    local newScanButton = CreateRareFarmingButton(frame, 96, 24, "New Scan", "neutral")
    newScanButton:SetPoint("LEFT", favoritesTabButton, "RIGHT", 8, 0)
    newScanButton:SetScript("OnClick", function()
        addon:OpenRareFarmingNewScan()
    end)
    frame.libraryNewScanButton = newScanButton

    local libraryPanel = CreateRareFarmingPanel(frame, { 0.04, 0.05, 0.07, 0.94 }, { 1.0, 0.82, 0.18, 0.12 })
    SetRareFarmingFrameLevel(libraryPanel, chrome, 1)
    libraryPanel:SetPoint("TOPLEFT", chrome, "TOPLEFT", 12, -86)
    libraryPanel:SetPoint("BOTTOMRIGHT", chrome, "BOTTOMRIGHT", -12, 38)
    frame.libraryPanel = libraryPanel

    local updateFavoritesButton = CreateRareFarmingButton(frame, 126, 24, "Update Prices", "neutral")
    updateFavoritesButton:SetPoint("TOPRIGHT", chrome, "TOPRIGHT", -12, -54)
    updateFavoritesButton:SetScript("OnClick", function()
        addon:UpdateRareFarmingFavoritePrices()
    end)
    frame.libraryUpdateFavoritesButton = updateFavoritesButton

    local libraryStatusText = libraryPanel:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    libraryStatusText:SetPoint("TOPLEFT", libraryPanel, "TOPLEFT", 14, -12)
    libraryStatusText:SetPoint("RIGHT", libraryPanel, "RIGHT", -14, 0)
    libraryStatusText:SetJustifyH("LEFT")
    libraryStatusText:SetTextColor(0.72, 0.76, 0.84)
    frame.libraryStatusText = libraryStatusText

    local libraryFavoritesHeaderFrame = CreateFrame("Frame", nil, libraryPanel)
    SetRareFarmingFrameLevel(libraryFavoritesHeaderFrame, libraryPanel, 2)
    libraryFavoritesHeaderFrame:SetPoint("TOPLEFT", libraryStatusText, "BOTTOMLEFT", 0, -8)
    libraryFavoritesHeaderFrame:SetPoint("TOPRIGHT", libraryPanel, "TOPRIGHT", -26, 0)
    libraryFavoritesHeaderFrame:SetHeight(18)
    libraryFavoritesHeaderFrame:Hide()
    frame.libraryFavoritesHeaderFrame = libraryFavoritesHeaderFrame

    frame.libraryFavoriteHeaderLabels = {}
    local favoriteHeaders = {
        { key = "expansion", label = "Expansion" },
        { key = "source", label = "Source" },
        { key = "item", label = "Item" },
        { key = "selected", label = "Selected" },
        { key = "market", label = "Market" },
        { key = "region", label = "Region" },
        { key = "average", label = "Avg" },
        { key = "details", label = "Details" },
    }
    for _, header in ipairs(favoriteHeaders) do
        local headerText = libraryFavoritesHeaderFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        headerText:SetTextColor(1.0, 0.82, 0.18)
        headerText:SetWordWrap(false)
        headerText:SetText(header.label)
        frame.libraryFavoriteHeaderLabels[header.key] = headerText
    end

    local libraryScrollFrame = CreateFrame("ScrollFrame", nil, libraryPanel, "UIPanelScrollFrameTemplate")
    SetRareFarmingFrameLevel(libraryScrollFrame, libraryPanel, 2)
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
    SetRareFarmingFrameLevel(libraryContent, libraryScrollFrame, 1)
    libraryContent:SetSize(1, 1)
    libraryScrollFrame:SetScrollChild(libraryContent)
    frame.libraryContent = libraryContent

    local libraryEmptyText = libraryContent:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    libraryEmptyText:SetPoint("TOPLEFT", libraryContent, "TOPLEFT", 10, -12)
    libraryEmptyText:SetPoint("RIGHT", libraryPanel, "RIGHT", -40, 0)
    libraryEmptyText:SetJustifyH("LEFT")
    libraryEmptyText:SetTextColor(0.62, 0.66, 0.74)
    frame.libraryEmptyText = libraryEmptyText

    local controlsPanel = CreateRareFarmingPanel(frame, { 0.05, 0.06, 0.08, 0.94 }, { 1.0, 0.82, 0.18, 0.12 })
    SetRareFarmingFrameLevel(controlsPanel, chrome, 1)
    controlsPanel:SetPoint("TOPLEFT", chrome, "TOPLEFT", 12, -86)
    controlsPanel:SetPoint("TOPRIGHT", chrome, "TOPRIGHT", -12, -86)
    controlsPanel:SetHeight(178)
    frame.controlsPanel = controlsPanel

    local sourceLabel = controlsPanel:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    sourceLabel:SetPoint("TOPLEFT", controlsPanel, "TOPLEFT", 14, -10)
    sourceLabel:SetText("Value source")

    local valueSourceDropdown = CreateFrame("Frame", "GoldTrackerRareFarmingValueSourceDropdown", controlsPanel, "UIDropDownMenuTemplate")
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
                    addon:SetRareFarmingValueSource(sourceID)
                    addon:RefreshRareFarmingWindow(true)
                end
                UIDropDownMenu_AddButton(info, level)
            end
        end
    end)
    frame.valueSourceDropdown = valueSourceDropdown

    local valueLabel = controlsPanel:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    valueLabel:SetPoint("TOPLEFT", sourceLabel, "TOPLEFT", 250, 0)
    valueLabel:SetText("Min value (g)")

    local minimumValueInput = CreateFrame("EditBox", nil, controlsPanel, "InputBoxTemplate")
    minimumValueInput:SetSize(92, 22)
    minimumValueInput:SetPoint("TOPLEFT", valueLabel, "BOTTOMLEFT", 0, -8)
    minimumValueInput:SetAutoFocus(false)
    minimumValueInput:SetNumeric(false)
    minimumValueInput:SetText(FormatRareFarmingGoldInput(self, frame.minimumValueCopper))
    minimumValueInput:SetScript("OnEnterPressed", function(editBox)
        editBox:ClearFocus()
    end)
    minimumValueInput:SetScript("OnEscapePressed", function(editBox)
        frame.skipMinimumValueSave = true
        editBox:SetText(FormatRareFarmingGoldInput(addon, frame.minimumValueCopper))
        editBox:ClearFocus()
        frame.skipMinimumValueSave = false
    end)
    minimumValueInput:SetScript("OnEditFocusLost", function()
        if frame.skipMinimumValueSave then
            return
        end
        addon:SaveRareFarmingMinimumValueInput()
    end)
    frame.minimumValueInput = minimumValueInput

    local expansionLabel = controlsPanel:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    expansionLabel:SetPoint("TOPLEFT", valueLabel, "TOPLEFT", 150, 0)
    expansionLabel:SetText("Expansion")

    local expansionDropdown = CreateFrame("Frame", "GoldTrackerRareFarmingExpansionDropdown", controlsPanel, "UIDropDownMenuTemplate")
    expansionDropdown:SetPoint("TOPLEFT", expansionLabel, "BOTTOMLEFT", -16, -5)
    UIDropDownMenu_SetWidth(expansionDropdown, 150)
    UIDropDownMenu_Initialize(expansionDropdown, function(_, level)
        for _, option in ipairs(GetRareFarmingExpansionOptions()) do
            local info = UIDropDownMenu_CreateInfo()
            local optionID = option.id
            info.text = option.label
            info.value = optionID
            info.checked = addon:GetRareFarmingExpansionFilter() == optionID
            info.func = function()
                addon:SetRareFarmingExpansionFilter(optionID)
                addon:RefreshRareFarmingWindow(true)
            end
            UIDropDownMenu_AddButton(info, level)
        end
    end)
    frame.expansionDropdown = expansionDropdown

    local scanModeLabel = controlsPanel:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    scanModeLabel:SetPoint("TOPLEFT", expansionLabel, "TOPLEFT", 165, 0)
    scanModeLabel:SetText("Mode")

    local scanModeDropdown = CreateFrame("Frame", "GoldTrackerRareFarmingScanModeDropdown", controlsPanel, "UIDropDownMenuTemplate")
    scanModeDropdown:SetPoint("TOPLEFT", scanModeLabel, "BOTTOMLEFT", -16, -5)
    UIDropDownMenu_SetWidth(scanModeDropdown, 130)
    UIDropDownMenu_Initialize(scanModeDropdown, function(_, level)
        for _, option in ipairs(RARE_FARMING_SCAN_MODE_OPTIONS) do
            local info = UIDropDownMenu_CreateInfo()
            local optionID = option.id
            info.text = option.label
            info.value = optionID
            info.checked = addon:GetRareFarmingScanMode() == optionID
            info.func = function()
                addon:SetRareFarmingScanMode(optionID)
                addon:RefreshRareFarmingWindow(true)
            end
            UIDropDownMenu_AddButton(info, level)
        end
    end)
    frame.scanModeDropdown = scanModeDropdown

    local scanButton = CreateRareFarmingButton(controlsPanel, 92, 24, "Scan", "primary")
    scanButton:SetPoint("TOPRIGHT", controlsPanel, "TOPRIGHT", -14, -62)
    scanButton:SetScript("OnClick", function()
        addon:StartRareFarmingScan()
    end)
    frame.scanButton = scanButton

    local stopScanButton = CreateRareFarmingButton(controlsPanel, 82, 24, "Stop", "danger")
    stopScanButton:SetPoint("RIGHT", scanButton, "LEFT", -8, 0)
    stopScanButton:SetEnabled(false)
    stopScanButton:SetAlpha(0.45)
    stopScanButton:SetScript("OnClick", function()
        addon:CancelRareFarmingScan()
    end)
    frame.stopScanButton = stopScanButton

    local savedScansButton = CreateRareFarmingButton(controlsPanel, 82, 24, "Save", "neutral")
    savedScansButton:SetPoint("RIGHT", scanButton, "LEFT", -8, 0)
    savedScansButton:SetScript("OnClick", function()
        addon:SaveCurrentRareFarmingScan()
    end)
    frame.savedScansButton = savedScansButton

    stopScanButton:ClearAllPoints()
    stopScanButton:SetPoint("RIGHT", savedScansButton, "LEFT", -8, 0)

    local updatePricesButton = CreateRareFarmingButton(controlsPanel, 116, 24, "Update Prices", "neutral")
    updatePricesButton:SetPoint("RIGHT", stopScanButton, "LEFT", -8, 0)
    updatePricesButton:SetScript("OnClick", function()
        addon:UpdateCurrentRareFarmingScanPrices()
    end)
    frame.updateScanPricesButton = updatePricesButton

    local rescanButton = CreateRareFarmingButton(controlsPanel, 126, 24, "Rescan Expansion", "primary")
    rescanButton:SetPoint("RIGHT", updatePricesButton, "LEFT", -8, 0)
    rescanButton:SetScript("OnClick", function()
        addon:RescanCurrentRareFarmingSelection()
    end)
    frame.rescanScanButton = rescanButton

    local hintText = controlsPanel:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    hintText:SetPoint("TOPLEFT", controlsPanel, "TOPLEFT", 14, -104)
    hintText:SetPoint("TOPRIGHT", controlsPanel, "TOPRIGHT", -14, -104)
    hintText:SetJustifyH("LEFT")
    hintText:SetTextColor(0.84, 0.78, 0.58)
    hintText:SetText("Background lets you keep playing; Foreground is faster but can lower FPS. All expansions can take quite a while.")
    frame.scanHintText = hintText

    local progressBackdrop = CreateRareFarmingPanel(controlsPanel, { 0.03, 0.04, 0.06, 0.96 }, { 1, 1, 1, 0.08 })
    progressBackdrop:SetPoint("TOPLEFT", hintText, "BOTTOMLEFT", 0, -8)
    progressBackdrop:SetPoint("TOPRIGHT", hintText, "BOTTOMRIGHT", 0, -8)
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
    statusText:SetTextColor(0.72, 0.76, 0.84)
    statusText:SetText("Ready.")
    frame.statusText = statusText

    local listPanel = CreateRareFarmingPanel(frame, { 0.04, 0.05, 0.07, 0.92 }, { 1.0, 0.82, 0.18, 0.10 })
    SetRareFarmingFrameLevel(listPanel, chrome, 1)
    listPanel:SetPoint("TOPLEFT", controlsPanel, "BOTTOMLEFT", 0, -10)
    listPanel:SetPoint("BOTTOMRIGHT", chrome, "BOTTOMRIGHT", -12, 38)
    if listPanel.SetClipsChildren then
        listPanel:SetClipsChildren(true)
    end
    frame.listPanel = listPanel

    local favoriteHeaderButton = CreateRareFarmingHeaderButton(listPanel, "Tracked", RARE_FARMING_FAVORITE_WIDTH, "CENTER")
    SetRareFarmingFrameLevel(favoriteHeaderButton, listPanel, 2)
    favoriteHeaderButton:SetPoint("TOPLEFT", listPanel, "TOPLEFT", 20, -12)
    favoriteHeaderButton:SetScript("OnClick", function()
        addon:ToggleRareFarmingSort("favorite")
    end)
    frame.favoriteHeaderButton = favoriteHeaderButton

    local locationHeaderButton = CreateRareFarmingHeaderButton(listPanel, "Location", RARE_FARMING_LOCATION_WIDTH, "LEFT")
    SetRareFarmingFrameLevel(locationHeaderButton, listPanel, 2)
    locationHeaderButton:SetPoint("LEFT", favoriteHeaderButton, "RIGHT", RARE_FARMING_COLUMN_GAP, 0)
    locationHeaderButton:SetScript("OnClick", function()
        addon:ToggleRareFarmingSort("location")
    end)
    frame.locationHeaderButton = locationHeaderButton

    local rareHeaderButton = CreateRareFarmingHeaderButton(listPanel, "Rare", RARE_FARMING_RARE_WIDTH, "LEFT")
    SetRareFarmingFrameLevel(rareHeaderButton, listPanel, 2)
    rareHeaderButton:SetPoint("LEFT", locationHeaderButton, "RIGHT", RARE_FARMING_COLUMN_GAP, 0)
    rareHeaderButton:SetScript("OnClick", function()
        addon:ToggleRareFarmingSort("rareName")
    end)
    frame.rareHeaderButton = rareHeaderButton

    local averageHeaderButton = CreateRareFarmingHeaderButton(listPanel, "Avg", RARE_FARMING_VALUE_WIDTH, "RIGHT")
    SetRareFarmingFrameLevel(averageHeaderButton, listPanel, 2)
    averageHeaderButton:SetPoint("TOPRIGHT", listPanel, "TOPRIGHT", -88, -12)
    averageHeaderButton:SetScript("OnClick", function()
        addon:ToggleRareFarmingSort("averageValue")
    end)
    frame.averageHeaderButton = averageHeaderButton

    local wowheadHeaderButton = CreateRareFarmingHeaderButton(listPanel, "Details", RARE_FARMING_WOWHEAD_BUTTON_WIDTH, "CENTER")
    SetRareFarmingFrameLevel(wowheadHeaderButton, listPanel, 2)
    wowheadHeaderButton:SetPoint("TOPRIGHT", listPanel, "TOPRIGHT", -34, -12)
    frame.wowheadHeaderButton = wowheadHeaderButton

    local mapHeaderButton = CreateRareFarmingHeaderButton(listPanel, "Map", RARE_FARMING_MAP_BUTTON_WIDTH, "CENTER")
    SetRareFarmingFrameLevel(mapHeaderButton, listPanel, 2)
    mapHeaderButton:SetPoint("LEFT", wowheadHeaderButton, "RIGHT", RARE_FARMING_COLUMN_GAP, 0)
    frame.mapHeaderButton = mapHeaderButton

    local regionMarketHeaderButton = CreateRareFarmingHeaderButton(listPanel, "Region", RARE_FARMING_VALUE_WIDTH, "RIGHT")
    SetRareFarmingFrameLevel(regionMarketHeaderButton, listPanel, 2)
    regionMarketHeaderButton:SetPoint("RIGHT", averageHeaderButton, "LEFT", -RARE_FARMING_COLUMN_GAP, 0)
    regionMarketHeaderButton:SetScript("OnClick", function()
        addon:ToggleRareFarmingSort("regionMarketValue")
    end)
    frame.regionMarketHeaderButton = regionMarketHeaderButton

    local marketHeaderButton = CreateRareFarmingHeaderButton(listPanel, "Market", RARE_FARMING_VALUE_WIDTH, "RIGHT")
    SetRareFarmingFrameLevel(marketHeaderButton, listPanel, 2)
    marketHeaderButton:SetPoint("RIGHT", regionMarketHeaderButton, "LEFT", -RARE_FARMING_COLUMN_GAP, 0)
    marketHeaderButton:SetScript("OnClick", function()
        addon:ToggleRareFarmingSort("marketValue")
    end)
    frame.marketHeaderButton = marketHeaderButton

    local valueHeaderButton = CreateRareFarmingHeaderButton(listPanel, "Selected", RARE_FARMING_VALUE_WIDTH, "RIGHT")
    SetRareFarmingFrameLevel(valueHeaderButton, listPanel, 2)
    valueHeaderButton:SetPoint("RIGHT", marketHeaderButton, "LEFT", -RARE_FARMING_COLUMN_GAP, 0)
    valueHeaderButton:SetScript("OnClick", function()
        addon:ToggleRareFarmingSort("value")
    end)
    frame.valueHeaderButton = valueHeaderButton

    local itemHeaderButton = CreateRareFarmingHeaderButton(listPanel, "Item", nil, "LEFT")
    SetRareFarmingFrameLevel(itemHeaderButton, listPanel, 2)
    itemHeaderButton:SetPoint("LEFT", rareHeaderButton, "RIGHT", RARE_FARMING_COLUMN_GAP, 0)
    itemHeaderButton:SetPoint("RIGHT", valueHeaderButton, "LEFT", -RARE_FARMING_COLUMN_GAP, 0)
    itemHeaderButton:SetScript("OnClick", function()
        addon:ToggleRareFarmingSort("itemName")
    end)
    frame.itemHeaderButton = itemHeaderButton

    local headerUnderline = listPanel:CreateTexture(nil, "ARTWORK")
    headerUnderline:SetColorTexture(1, 0.82, 0.18, 0.18)
    headerUnderline:SetPoint("TOPLEFT", listPanel, "TOPLEFT", 12, -30)
    headerUnderline:SetPoint("TOPRIGHT", listPanel, "TOPRIGHT", -12, -30)
    headerUnderline:SetHeight(1)

    local scrollFrame = CreateFrame("ScrollFrame", nil, listPanel, "UIPanelScrollFrameTemplate")
    SetRareFarmingFrameLevel(scrollFrame, listPanel, 2)
    scrollFrame:SetPoint("TOPLEFT", listPanel, "TOPLEFT", 12, -36)
    scrollFrame:SetPoint("BOTTOMRIGHT", listPanel, "BOTTOMRIGHT", -26, 12 + RARE_FARMING_HORIZONTAL_SCROLL_HEIGHT)
    BindRareFarmingResultsMouseWheel(scrollFrame, frame)
    scrollFrame:SetScript("OnVerticalScroll", function()
        if frame.suppressRareFarmingScrollRefresh or frame.isRareFarmingRefreshing then
            return
        end
        frame.rareFarmingScrollOnlyRefresh = true
        addon:RefreshRareFarmingWindow(false)
        frame.rareFarmingScrollOnlyRefresh = false
    end)
    frame.scrollFrame = scrollFrame
    RefreshRareFarmingVerticalScrollFrame(frame)

    local content = CreateFrame("Frame", nil, scrollFrame)
    SetRareFarmingFrameLevel(content, scrollFrame, 1)
    content:SetSize(1, 1)
    scrollFrame:SetScrollChild(content)
    frame.content = content

    local horizontalScrollBar = CreateFrame("Slider", "GoldTrackerRareFarmingHorizontalScrollBar", listPanel, "OptionsSliderTemplate")
    SetRareFarmingFrameLevel(horizontalScrollBar, listPanel, 3)
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
        ApplyRareFarmingTableColumnLayout(frame)
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
    emptyText:SetText("Press Scan to build a rare-drop farm list.")
    frame.emptyText = emptyText

    local metaText = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    metaText:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 16, 14)
    metaText:SetPoint("RIGHT", frame, "RIGHT", -40, 14)
    metaText:SetJustifyH("LEFT")
    metaText:SetTextColor(0.72, 0.76, 0.84)
    metaText:SetText("")
    frame.metaText = metaText

    Theme:CreateResizeButton(frame, {
        minWidth = RARE_FARMING_WINDOW_MIN_WIDTH,
        minHeight = RARE_FARMING_WINDOW_MIN_HEIGHT,
        maxWidth = RARE_FARMING_WINDOW_MAX_WIDTH,
        maxHeight = RARE_FARMING_WINDOW_MAX_HEIGHT,
        onResizeStop = function()
            ApplyRareFarmingTableColumnLayout(frame)
            addon:RefreshRareFarmingWindow(false)
        end,
    })

    frame:RegisterEvent("GET_ITEM_INFO_RECEIVED")
    frame:RegisterEvent("ITEM_DATA_LOAD_RESULT")
    frame:SetScript("OnEvent", function(_, _, itemID)
        if itemID then
            local updatedScanState = addon:UpdateRareFarmingItemDisplayData(itemID)
            local updatedCachedRows = addon:UpdateRareFarmingCachedRowItemDisplayData(itemID)
            if updatedScanState or updatedCachedRows then
                addon:ScheduleRareFarmingWindowRefresh(false)
            end
        end
    end)
    frame:SetScript("OnSizeChanged", function()
        if frame.isManualResizing then
            return
        end
        ApplyRareFarmingTableColumnLayout(frame)
    end)
    frame:SetScript("OnShow", function()
        if frame.suppressExplorerOnShow then
            return
        end
        if frame.rareFarmingViewID == "scan" then
            addon:RefreshRareFarmingWindow(true)
        else
            addon:RefreshRareFarmingLibraryWindow()
        end
    end)
    frame:SetScript("OnHide", function()
        GameTooltip:Hide()
    end)

    self.rareFarmingFrame = frame
    self:RefreshRareFarmingWindowControls()
    self:LoadRareFarmingScanCacheForCurrentFilters()
    self:SetRareFarmingWindowView("library")
end

function GoldTracker:OpenRareFarmingWindow()
    if type(self.OpenExplorerWindow) == "function" then
        self:OpenExplorerWindow("rares")
        return
    end

    self:CreateRareFarmingWindow()
    if not self.rareFarmingFrame then
        return
    end

    self.rareFarmingFrame:Show()
    self.rareFarmingFrame:Raise()
    if IsRareFarmingScanStateActive(self.rareFarmingFrame.scanState) then
        self:SetRareFarmingWindowView("scan")
    else
        self:SetRareFarmingWindowView("library")
    end
end

function GoldTracker:ToggleRareFarmingWindow()
    if type(self.ToggleExplorerWindow) == "function" then
        self:ToggleExplorerWindow("rares")
        return
    end

    self:CreateRareFarmingWindow()
    if not self.rareFarmingFrame then
        return
    end

    if self.rareFarmingFrame:IsShown() then
        self.rareFarmingFrame:Hide()
    else
        self:OpenRareFarmingWindow()
    end
end
