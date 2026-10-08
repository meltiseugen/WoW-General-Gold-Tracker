local _, NS = ...
local GoldTracker = NS.GoldTracker
local Theme = NS.JanisTheme

local MATERIALS_WINDOW_WIDTH = 960
local MATERIALS_WINDOW_HEIGHT = 600
local MATERIALS_WINDOW_MIN_WIDTH = 820
local MATERIALS_WINDOW_MIN_HEIGHT = 420
local MATERIALS_WINDOW_MAX_WIDTH = 1240
local MATERIALS_WINDOW_MAX_HEIGHT = 860
local MATERIALS_EXPANDED_WINDOW_WIDTH = 1680
local MATERIALS_EXPANDED_WINDOW_HEIGHT = 880
local MATERIALS_EXPANDED_WINDOW_MIN_WIDTH = 960
local MATERIALS_EXPANDED_WINDOW_MIN_HEIGHT = 520
local MATERIALS_EXPANDED_WINDOW_MAX_WIDTH = 1900
local MATERIALS_EXPANDED_WINDOW_MAX_HEIGHT = 1100
local MATERIALS_ROW_HEIGHT = 24
local MATERIALS_ROW_SPACING = 2
local MATERIALS_ICON_SIZE = 18
local MATERIALS_COLUMN_GAP = 8
local MATERIALS_ROW_RIGHT_PADDING = 6
local MATERIALS_HEADER_LEFT_INSET = 12
local MATERIALS_FAVORITE_WIDTH = 24
local MATERIALS_FAVORITE_BUTTON_WIDTH = 24
local MATERIALS_FAVORITE_BUTTON_HEIGHT = 18
local MATERIALS_TOGGLE_WIDTH = 18
local MATERIALS_PROFESSION_WIDTH = 112
local MATERIALS_EXPANSION_WIDTH = 140
local MATERIALS_TAG_WIDTH = 76
local MATERIALS_DROP_RATE_WIDTH = 86
local MATERIALS_GOLD_RATE_WIDTH = 100
local MATERIALS_DEMAND_WIDTH = 82
local MATERIALS_SELL_RATE_WIDTH = 78
local MATERIALS_TREND_WIDTH = 64
local MATERIALS_VALUE_WIDTH = 100
local MATERIALS_COMPONENT_COST_WIDTH = 118
local MATERIALS_MARGIN_WIDTH = 118
local MATERIALS_FARM_BUTTON_WIDTH = 52
local MATERIALS_MAP_BUTTON_WIDTH = 52
local MATERIALS_ADD_BUTTON_WIDTH = 48
local MATERIALS_ITEM_MIN_WIDTH = 160
local MATERIALS_SORT_ICON_SIZE = 10
local MATERIALS_HORIZONTAL_SCROLL_HEIGHT = 14
local MATERIALS_DEFAULT_SORT_KEY = "value"
local MATERIALS_REALTIME_FRAME_BUDGET_MS = 4
local MATERIALS_REALTIME_FALLBACK_BATCH_SIZE = 8
local MATERIALS_SEARCH_DEBOUNCE_SECONDS = 0.20

local QueueMaterialsItemDisplayRefresh

local MATERIALS_SORT_KEYS = {
    expansion = true,
    profession = true,
    tag = true,
    itemName = true,
    dropRate = true,
    goldRate = true,
    demand = true,
    sellRate = true,
    marketTrend = true,
    value = true,
    componentCost = true,
    profit = true,
}

local function GetCraftingFarmingFavoriteKey(rowOrItemID)
    local itemID
    if type(rowOrItemID) == "table" then
        itemID = tonumber(rowOrItemID.itemID)
    else
        itemID = tonumber(rowOrItemID)
    end
    if not itemID then
        return nil
    end
    return "item:" .. tostring(math.floor(itemID + 0.5))
end

local function CloneCraftingFarmingFavorite(row)
    local itemID = tonumber(row and row.itemID)
    if not itemID then
        return nil
    end

    local professionLabel = row.materialProfessionLabel or row.professionLabel
    return {
        itemID = math.floor(itemID + 0.5),
        itemName = row.itemName,
        itemLink = row.itemLink,
        itemQuality = tonumber(row.itemQuality),
        icon = row.icon or row.iconTexture,
        value = math.max(0, math.floor((tonumber(row.value) or 0) + 0.5)),
        marketValue = math.max(0, math.floor((tonumber(row.marketValue) or tonumber(row.value) or 0) + 0.5)),
        regionMarketValue = math.max(0, math.floor((tonumber(row.regionMarketValue) or 0) + 0.5)),
        averageValue = math.max(0, math.floor((tonumber(row.historicalValue) or tonumber(row.averageValue) or 0) + 0.5)),
        valueSourceID = row.valueSourceID,
        valueSourceLabel = row.valueSourceLabel,
        expansionID = row.materialExpansionID or row.expansionID,
        expansionLabel = row.materialExpansionLabel or row.expansionLabel,
        expansionFilterLabel = row.materialExpansionLabel or row.expansionLabel,
        professionLabel = professionLabel,
        materialProfessionLabel = professionLabel,
        materialProfessionIDs = row.materialProfessionIDs,
        tag = row.tag,
        materialTag = row.tag,
        locationLabel = professionLabel and ("Materials: " .. professionLabel) or "Materials",
        farmingSourceType = "material",
        hasFarmingMap = row.hasFarmingMap == true,
        hasFarm = row.hasFarm == true,
        farmCount = math.max(0, math.floor(tonumber(row.farmCount) or 0)),
    }
end

local MATERIAL_FARMING_MAP_IDS = {
    ["Arathi Highlands"] = 14,
    ["Ashenvale"] = 63,
    ["Azuremyst Isle"] = 97,
    ["Blade's Edge Mountains"] = 105,
    ["Badlands"] = 15,
    ["Bloodmyst Isle"] = 106,
    ["Burning Steppes"] = 36,
    ["Deadwind Pass"] = 42,
    ["Durotar"] = 1,
    ["Duskwood"] = 47,
    ["Eastern Plaguelands"] = 23,
    ["Elwynn Forest"] = 37,
    ["Felwood"] = 77,
    ["Feralas"] = 69,
    ["Ghostlands"] = 95,
    ["Hellfire Peninsula"] = 100,
    ["Hillsbrad Foothills"] = 25,
    ["Borean Tundra"] = 114,
    ["Dragonblight"] = 115,
    ["Grizzly Hills"] = 116,
    ["Howling Fjord"] = 117,
    ["Icecrown"] = 118,
    ["Isle of Quel'Danas"] = 122,
    ["Sholazar Basin"] = 119,
    ["The Storm Peaks"] = 120,
    ["Zul'Drak"] = 121,
    ["Wintergrasp"] = 123,
    ["Loch Modan"] = 48,
    ["Nagrand"] = 107,
    ["Netherstorm"] = 109,
    ["Northern Stranglethorn"] = 50,
    ["Searing Gorge"] = 32,
    ["Shadowmoon Valley"] = 104,
    ["Silithus"] = 81,
    ["Stonetalon Mountains"] = 65,
    ["Stranglethorn Vale"] = 50,
    ["Swamp of Sorrows"] = 51,
    ["Tanaris"] = 71,
    ["Terokkar Forest"] = 108,
    ["The Barrens"] = 10,
    ["The Hinterlands"] = 26,
    ["Tirisfal Glades"] = 18,
    ["Un'Goro Crater"] = 78,
    ["Westfall"] = 52,
    ["Western Plaguelands"] = 22,
    ["Wetlands"] = 56,
    ["Winterspring"] = 83,
    ["Zangarmarsh"] = 102,
    ["Abyssal Depths"] = 204,
    ["Deepholm"] = 207,
    ["Mount Hyjal"] = 198,
    ["Shimmering Expanse"] = 205,
    ["Tol Barad"] = 244,
    ["Tol Barad Peninsula"] = 245,
    ["Twilight Highlands"] = 241,
    ["Uldum"] = 249,
    ["Dread Wastes"] = 422,
    ["Isle of Thunder"] = 504,
    ["Krasarang Wilds"] = 418,
    ["Kun-Lai Summit"] = 379,
    ["The Jade Forest"] = 371,
    ["Timeless Isle"] = 554,
    ["Townlong Steppes"] = 388,
    ["Valley of the Four Winds"] = 376,
    ["Frostfire Ridge"] = 525,
    ["Gorgrond"] = 543,
    ["Nagrand (Draenor)"] = 550,
    ["Shadowmoon Valley (Draenor)"] = 539,
    ["Spires of Arak"] = 542,
    ["Talador"] = 535,
    ["Tanaan Jungle"] = 534,
    ["Antoran Wastes"] = 885,
    ["Azsuna"] = 630,
    ["Broken Shore"] = 646,
    ["Eredath"] = 882,
    ["Highmountain"] = 650,
    ["Krokuun"] = 830,
    ["Stormheim"] = 634,
    ["Suramar"] = 680,
    ["Val'sharah"] = 641,
    ["Boralus"] = 1161,
    ["Dazar'alor"] = 1165,
    ["Drustvar"] = 896,
    ["Mechagon Island"] = 1462,
    ["Nazjatar"] = 1355,
    ["Nazmir"] = 863,
    ["Oribos"] = 1670,
    ["Ardenweald"] = 1565,
    ["Bastion"] = 1533,
    ["Korthia"] = 1961,
    ["Maldraxxus"] = 1536,
    ["Revendreth"] = 1525,
    ["The Maw"] = 1543,
    ["Stormsong Valley"] = 942,
    ["Tiragarde Sound"] = 895,
    ["Vol'dun"] = 864,
    ["Zuldazar"] = 862,
    ["Silvermoon City"] = 2393,
    ["Eversong Woods"] = 2395,
    ["Harandar"] = 2413,
    ["Voidstorm"] = 2405,
    ["Zul'Aman"] = 2437,
}

local materialMapIDByNormalizedName = nil

local function CreateMaterialsPanel(parent, bg, border)
    return Theme:CreatePanel(parent, bg, border)
end

local function CreateMaterialsButton(parent, width, height, text, paletteKey)
    return Theme:CreateButton(parent, width, height, text, paletteKey)
end

local function CreateMaterialsHeaderButton(parent, label, width, justifyH)
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
    button.sortLabel = label

    local sortIcon = button:CreateTexture(nil, "ARTWORK")
    sortIcon:SetSize(MATERIALS_SORT_ICON_SIZE, MATERIALS_SORT_ICON_SIZE)
    sortIcon:SetPoint("RIGHT", button, "RIGHT", 0, 0)
    sortIcon:Hide()
    button.sortIcon = sortIcon

    return button
end

local function SetMaterialsFrameLevel(frame, referenceFrame, offset)
    if not frame or not referenceFrame or type(frame.SetFrameLevel) ~= "function" or type(referenceFrame.GetFrameLevel) ~= "function" then
        return
    end

    frame:SetFrameLevel((referenceFrame:GetFrameLevel() or 0) + (offset or 1))
end

local function GetMaterialsData()
    local data = NS.FarmingItems
    if type(data) ~= "table" then
        return { expansions = {}, professions = {}, items = {} }
    end
    return data
end

local function BuildMaterialsItemList(addon)
    local items = {}
    local overrides = addon and type(addon.GetCraftingFarmingItemOverrides) == "function"
        and addon:GetCraftingFarmingItemOverrides()
        or {}

    local function addItem(item)
        local itemID = tonumber(item and item.itemID)
        local override = itemID and overrides[tostring(math.floor(itemID + 0.5))] or nil
        if type(override) == "table" and type(override.professions) == "table" and #override.professions > 0 then
            local copied = {}
            for key, value in pairs(item) do
                copied[key] = value
            end
            copied.professions = override.professions
            copied.manualProfessionOverride = true
            items[#items + 1] = copied
            return
        end
        items[#items + 1] = item
    end

    for _, item in ipairs(GetMaterialsData().items or {}) do
        addItem(item)
    end
    if addon and type(addon.GetCraftingFarmingCustomItems) == "function" then
        for _, item in ipairs(addon:GetCraftingFarmingCustomItems() or {}) do
            addItem(item)
        end
    end
    return items
end

local function BuildMaterialsItemLookup(addon)
    local lookup = {}
    for _, item in ipairs(BuildMaterialsItemList(addon)) do
        local itemID = tonumber(item and item.itemID)
        if itemID and not lookup[itemID] then
            lookup[itemID] = item
        end
    end
    return lookup
end

local function NormalizeMaterialMapName(mapName)
    if type(mapName) ~= "string" then
        return nil
    end

    local normalized = mapName:gsub("^%s+", ""):gsub("%s+$", "")
    if normalized == "" or string.find(normalized, "/", 1, true) then
        return nil
    end
    return string.lower(normalized)
end

local function BuildMaterialMapIDLookup()
    if materialMapIDByNormalizedName then
        return materialMapIDByNormalizedName
    end

    local lookup = {}
    for mapName, mapID in pairs(MATERIAL_FARMING_MAP_IDS) do
        local normalizedName = NormalizeMaterialMapName(mapName)
        if normalizedName then
            lookup[normalizedName] = mapID
        end
    end
    materialMapIDByNormalizedName = lookup
    return lookup
end

local function TryResolveMaterialMapIDFromClient(normalizedName, mapID)
    local normalizedMapID = tonumber(mapID)
    if not normalizedMapID or not C_Map or type(C_Map.GetMapInfo) ~= "function" then
        return nil
    end

    local mapInfo = C_Map.GetMapInfo(normalizedMapID)
    if NormalizeMaterialMapName(mapInfo and mapInfo.name) == normalizedName then
        return normalizedMapID
    end
    return nil
end

local function ResolveMaterialMapID(mapName)
    local normalizedName = NormalizeMaterialMapName(mapName)
    if not normalizedName then
        return nil
    end

    local staticMapID = BuildMaterialMapIDLookup()[normalizedName]
    if staticMapID then
        return staticMapID
    end

    local rareDropsData = NS.RareDropsData
    local expansionData = type(rareDropsData) == "table" and rareDropsData.expansions or nil
    if type(expansionData) == "table" then
        if type(expansionData.mapToExpansionID) == "table" then
            for mapID in pairs(expansionData.mapToExpansionID) do
                local matchedMapID = TryResolveMaterialMapIDFromClient(normalizedName, mapID)
                if matchedMapID then
                    materialMapIDByNormalizedName[normalizedName] = matchedMapID
                    return matchedMapID
                end
            end
        end

        for _, option in ipairs(expansionData.options or {}) do
            local matchedMapID = TryResolveMaterialMapIDFromClient(normalizedName, option and option.continentMapID)
            if matchedMapID then
                materialMapIDByNormalizedName[normalizedName] = matchedMapID
                return matchedMapID
            end
            for _, mapID in ipairs((option and option.zones) or {}) do
                matchedMapID = TryResolveMaterialMapIDFromClient(normalizedName, mapID)
                if matchedMapID then
                    materialMapIDByNormalizedName[normalizedName] = matchedMapID
                    return matchedMapID
                end
            end
        end
    end

    return nil
end

local function NormalizeMaterialSpotCoord(coord)
    if type(coord) ~= "table" then
        return nil
    end

    local x = tonumber(coord.x)
    local y = tonumber(coord.y)
    if not x or not y then
        return nil
    end
    if x > 1 then
        x = x / 100
    end
    if y > 1 then
        y = y / 100
    end
    if x < 0 or x > 1 or y < 0 or y > 1 then
        return nil
    end

    return {
        x = x,
        y = y,
        label = coord.label,
        targetName = coord.targetName,
        targetType = coord.targetType,
    }
end

local function GetMaterialFarmingSpotData(itemID)
    local spots = NS.MaterialFarmingSpots
    spots = type(spots) == "table" and spots.items or nil
    return spots and spots[tonumber(itemID)] or nil
end

local function IsRouteMaterial(item)
    return type(item) == "table" and (item.category == "Herb" or item.category == "Ore")
end

local function BuildMaterialFarmingPin(item, spot, coord, mapID)
    local itemName = item.itemName or ("Item " .. tostring(item.itemID))
    return {
        mapID = mapID,
        x = coord.x,
        y = coord.y,
        label = coord.label or spot.location or itemName,
        itemName = itemName,
        spotLocation = spot.location,
        targetName = coord.targetName or spot.targetName,
        targetType = coord.targetType or spot.targetType,
        farmAction = spot.farmAction,
        -- A sequence of pins is a rendered route only for raw herbs and ore.
        -- Other materials can retain every mapped point without a misleading
        -- line joining unrelated spawn locations.
        isRoute = IsRouteMaterial(item) and (spot.isRoute == true or item.isRoute == true),
        routeID = spot.id,
        routeType = spot.routeType,
        density = spot.density,
        dropDifficulty = spot.dropDifficulty,
        tips = spot.tips,
        sourceUrls = spot.sourceUrls or item.sourceUrls,
        sourceType = "static",
        sourceLabel = "Addon seed data",
    }
end

local function BuildMaterialFarmingMapOptionsFromData(item)
    if type(item) ~= "table" or type(item.spots) ~= "table" then
        return {}
    end

    local options = {}
    for _, spot in ipairs(item.spots) do
        local mapID = tonumber(spot and spot.mapID) or ResolveMaterialMapID(spot and spot.mapName)
        if mapID and type(spot.coords) == "table" then
            local option
            for _, rawCoord in ipairs(spot.coords) do
                local coord = NormalizeMaterialSpotCoord(rawCoord)
                if coord then
                    if not option then
                        local mapLabel = spot.mapName or ("Map " .. tostring(mapID))
                        local locationLabel = type(spot.location) == "string" and spot.location or nil
                        local dropdownLabel = type(spot.dropdownLabel) == "string" and spot.dropdownLabel or nil
                        option = {
                            id = spot.id,
                            sortOrder = tonumber(spot.sortOrder),
                            mapID = mapID,
                            mapLabel = mapLabel,
                            label = dropdownLabel or (locationLabel and (mapLabel .. ": " .. locationLabel) or mapLabel),
                            location = locationLabel,
                            pins = {},
                            spotCount = 1,
                            sourceType = "static",
                            sourceLabel = "Addon seed data",
                        }
                        options[#options + 1] = option
                    end
                    option.pins[#option.pins + 1] = BuildMaterialFarmingPin(item, spot, coord, mapID)
                end
            end
        end
    end

    table.sort(options, function(left, right)
        local leftOrder = tonumber(left.sortOrder)
        local rightOrder = tonumber(right.sortOrder)
        if leftOrder or rightOrder then
            leftOrder = leftOrder or math.huge
            rightOrder = rightOrder or math.huge
            if leftOrder ~= rightOrder then
                return leftOrder < rightOrder
            end
        end
        return tostring(left.label or "") < tostring(right.label or "")
    end)
    return options
end

local function BuildMaterialFarmingMapOptions(addon, itemID)
    local materialData = GetMaterialFarmingSpotData(itemID)
    local mapOptions = BuildMaterialFarmingMapOptionsFromData(materialData)

    if addon and type(addon.BuildUserMaterialFarmingMapOptions) == "function" then
        local fallbackItemName = materialData and materialData.itemName
        for _, userOption in ipairs(addon:BuildUserMaterialFarmingMapOptions(itemID, fallbackItemName) or {}) do
            if type(userOption) == "table" and type(userOption.pins) == "table" and #userOption.pins > 0 then
                mapOptions[#mapOptions + 1] = userOption
            end
        end
    end

    table.sort(mapOptions, function(left, right)
        local leftOrder = tonumber(left.sortOrder)
        local rightOrder = tonumber(right.sortOrder)
        if leftOrder or rightOrder then
            leftOrder = leftOrder or math.huge
            rightOrder = rightOrder or math.huge
            if leftOrder ~= rightOrder then
                return leftOrder < rightOrder
            end
        end
        local leftLabel = tostring(left.label or "")
        local rightLabel = tostring(right.label or "")
        if leftLabel ~= rightLabel then
            return leftLabel < rightLabel
        end
        if tonumber(left.mapID) ~= tonumber(right.mapID) then
            return (tonumber(left.mapID) or 0) < (tonumber(right.mapID) or 0)
        end
        return tostring(left.id or left.sourceType or "") < tostring(right.id or right.sourceType or "")
    end)
    return mapOptions
end

local function GetMaterialFarmCount(itemID)
    local normalizedItemID = tonumber(itemID)
    normalizedItemID = normalizedItemID and math.floor(normalizedItemID + 0.5) or nil
    local catalog = NS.FarmCatalog
    local byItemID = type(catalog) == "table" and type(catalog.indexes) == "table"
        and type(catalog.indexes.byItemID) == "table" and catalog.indexes.byItemID or nil
    local positions = normalizedItemID and byItemID and byItemID[normalizedItemID] or nil
    return type(positions) == "table" and #positions or 0
end

local function HasMaterialFarmingMapData(addon, itemID)
    local materialData = GetMaterialFarmingSpotData(itemID)
    if type(materialData) == "table" and type(materialData.spots) == "table" then
        for _, spot in ipairs(materialData.spots) do
            if type(spot) == "table" and type(spot.coords) == "table" and #spot.coords > 0 then
                return true
            end
        end
    end

    if addon and type(addon.GetUserMaterialFarmingPinsForItem) == "function" then
        local itemEntry = addon:GetUserMaterialFarmingPinsForItem(itemID)
        if type(itemEntry) == "table" and type(itemEntry.maps) == "table" then
            for _, mapEntry in pairs(itemEntry.maps) do
                if type(mapEntry) == "table" and type(mapEntry.pins) == "table" and next(mapEntry.pins) then
                    return true
                end
            end
        end
    elseif addon and type(addon.BuildUserMaterialFarmingMapOptions) == "function" then
        -- Compatibility fallback for callers that provide only the option builder.
        -- The live addon exposes the direct pin-store accessor above, so normal row
        -- refreshes do not construct map option and pin tables.
        return #(addon:BuildUserMaterialFarmingMapOptions(itemID) or {}) > 0
    end

    return false
end

local function BuildOptionLookup(options)
    local lookup = {}
    for _, option in ipairs(options or {}) do
        if type(option) == "table" and type(option.id) == "string" then
            lookup[option.id] = option
        end
    end
    return lookup
end

local function GetExpansionOptions()
    return GetMaterialsData().expansions or {}
end

local function GetProfessionOptions()
    return GetMaterialsData().professions or {}
end

local function GetExpansionLookup()
    if not NS.FarmingItemsExpansionLookup then
        NS.FarmingItemsExpansionLookup = BuildOptionLookup(GetExpansionOptions())
    end
    return NS.FarmingItemsExpansionLookup
end

local function GetProfessionLookup()
    if not NS.FarmingItemsProfessionLookup then
        NS.FarmingItemsProfessionLookup = BuildOptionLookup(GetProfessionOptions())
    end
    return NS.FarmingItemsProfessionLookup
end

local function NormalizeExpansionID(expansionID)
    local lookup = GetExpansionLookup()
    if lookup[expansionID] then
        return expansionID
    end
    return "all"
end

local function GetOptionLabel(lookup, optionID, fallback)
    local option = lookup and lookup[optionID]
    return option and option.label or fallback or tostring(optionID or "")
end

local function NormalizeProfessionID(professionID)
    local lookup = GetProfessionLookup()
    if lookup[professionID] then
        return professionID
    end
    if lookup.mining then
        return "mining"
    end
    for _, profession in ipairs(GetProfessionOptions()) do
        if profession.id ~= "all" then
            return profession.id
        end
    end
    return "all"
end

local function NormalizeProfessionSelections(professionIDs, fallbackProfessionID)
    local lookup = GetProfessionLookup()
    local selectedProfessionID

    local function setProfession(professionID)
        if lookup[professionID] then
            selectedProfessionID = professionID
            return true
        end
        return false
    end

    setProfession(fallbackProfessionID)

    if not selectedProfessionID and type(professionIDs) == "table" then
        for _, professionID in ipairs(professionIDs) do
            if setProfession(professionID) then
                break
            end
        end
        if not selectedProfessionID then
            for professionID, enabled in pairs(professionIDs) do
                if enabled == true and type(professionID) == "string" and setProfession(professionID) then
                    break
                end
            end
        end
    end

    selectedProfessionID = selectedProfessionID or NormalizeProfessionID(nil)
    return { [selectedProfessionID] = true }, { selectedProfessionID }
end

local function BuildProfessionSelectionArray(selected)
    local selectedMap = type(selected) == "table" and selected or {}
    for _, profession in ipairs(GetProfessionOptions()) do
        if selectedMap[profession.id] then
            return { profession.id }
        end
    end
    return { NormalizeProfessionID(nil) }
end

local function GetProfessionSelectionText(selected)
    local ordered = BuildProfessionSelectionArray(selected)
    return GetOptionLabel(GetProfessionLookup(), ordered[1], "Mining")
end

local function IsProfessionSelected(selected, professionID)
    if type(selected) ~= "table" then
        return false
    end
    if professionID == "all" then
        return selected.all == true
    end
    return selected[professionID] == true
end

local function SetProfessionDropdownText(frame)
    if not frame or not frame.professionDropdown then
        return
    end

    UIDropDownMenu_SetSelectedValue(frame.professionDropdown, frame.professionID or NormalizeProfessionID(nil))
    UIDropDownMenu_SetText(frame.professionDropdown, GetProfessionSelectionText(frame.professionIDs))
end

local function RefreshProfessionDropdownMenu(frame, defer)
    if not frame or not frame.professionDropdown then
        return
    end

    SetProfessionDropdownText(frame)

    local openMenu = _G.UIDROPDOWNMENU_OPEN_MENU
    if openMenu ~= frame.professionDropdown then
        return
    end

    local maxLevels = tonumber(_G.UIDROPDOWNMENU_MAXLEVELS) or 2
    local maxButtons = tonumber(_G.UIDROPDOWNMENU_MAXBUTTONS) or 32
    local professionLookup = GetProfessionLookup()
    for level = 1, maxLevels do
        local listFrame = _G["DropDownList" .. tostring(level)]
        local numButtons = tonumber(listFrame and listFrame.numButtons) or maxButtons
        for index = 1, numButtons do
            local button = _G["DropDownList" .. tostring(level) .. "Button" .. tostring(index)]
            local value = button and button.value
            if type(value) == "string" and professionLookup[value] then
                local checked = IsProfessionSelected(frame.professionIDs, value)
                button.checked = checked
                local buttonName = button.GetName and button:GetName()
                local check = button.Check or (buttonName and _G[buttonName .. "Check"])
                local uncheck = button.UnCheck or (buttonName and _G[buttonName .. "UnCheck"])
                if checked then
                    if button.LockHighlight then
                        button:LockHighlight()
                    end
                    if check then
                        check:Show()
                    end
                    if uncheck then
                        uncheck:Hide()
                    end
                else
                    if button.UnlockHighlight then
                        button:UnlockHighlight()
                    end
                    if check then
                        check:Hide()
                    end
                    if uncheck then
                        uncheck:Show()
                    end
                end
            end
        end
    end

    if defer == true and C_Timer and type(C_Timer.After) == "function" then
        C_Timer.After(0, function()
            RefreshProfessionDropdownMenu(frame, false)
        end)
    end
end

local EXPANSION_ID_TO_MATERIALS_ID = {
    [0] = "classic",
    [1] = "burningCrusade",
    [2] = "wrath",
    [3] = "cataclysm",
    [4] = "mists",
    [5] = "warlords",
    [6] = "legion",
    [7] = "battleForAzeroth",
    [8] = "shadowlands",
    [9] = "dragonflight",
    [10] = "warWithin",
    [11] = "midnight",
}

local LOOT_SOURCE_PROFESSION_BY_TYPE = {
    MINING = "mining",
    Mining = "mining",
    HERBALISM = "herbalism",
    Herbalism = "herbalism",
    SKINNING = "skinning",
    Skinning = "skinning",
    FISHING = "fishing",
    Fishing = "fishing",
}

local MATERIALS_PROFESSION_BY_ITEM_SUBTYPE = {
    cooking = "cooking",
    meat = "cooking",
    fish = "fishing",
    fishing = "fishing",
    herb = "herbalism",
    herbs = "herbalism",
    enchanting = "enchanting",
    jewelcrafting = "jewelcrafting",
    inscription = "inscription",
    leather = "skinning",
    cloth = "tailoring",
}

local MATERIALS_GATHERING_PROFESSIONS = {
    mining = true,
    herbalism = true,
    skinning = true,
    fishing = true,
}

local function GetMaterialsProfessionIDFromItemSubtype(loot)
    local itemSubType = string.lower(tostring(loot and loot.itemSubType or ""))
    if itemSubType == "" then
        return nil
    end
    if itemSubType == "metal & stone" or itemSubType == "metal and stone" then
        return "mining"
    end
    for token, professionID in pairs(MATERIALS_PROFESSION_BY_ITEM_SUBTYPE) do
        if string.find(itemSubType, token, 1, true) then
            return professionID
        end
    end
    return nil
end

local function ItemMatchesProfessionSelection(item, selected)
    local selectedMap = type(selected) == "table" and selected or { all = true }
    if selectedMap.all then
        return true
    end
    for _, currentProfessionID in ipairs(item.professions or {}) do
        if selectedMap[currentProfessionID] then
            return true
        end
    end
    return false
end

local function GetPrimaryProfessionLabel(item)
    local professionID = item and item.professions and item.professions[1]
    return GetOptionLabel(GetProfessionLookup(), professionID, tostring(professionID or "Unknown"))
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

local function RequestMaterialsItemData(addon, itemID)
    local frame = addon and addon.craftingFarmingFrame
    if frame then
        frame.pendingMaterialsItemRequests = frame.pendingMaterialsItemRequests or {}
        if frame.pendingMaterialsItemRequests[itemID] then
            return
        end
        frame.pendingMaterialsItemRequests[itemID] = true
    end

    if Item and type(Item.CreateFromItemID) == "function" then
        local item = Item:CreateFromItemID(itemID)
        if item and type(item.ContinueOnItemLoad) == "function" then
            item:ContinueOnItemLoad(function()
                addon:UpdateCraftingFarmingItemDisplayData(itemID)
                if QueueMaterialsItemDisplayRefresh then
                    QueueMaterialsItemDisplayRefresh(addon, itemID)
                end
            end)
            return
        end
    end

    if C_Item and type(C_Item.RequestLoadItemDataByID) == "function" then
        pcall(C_Item.RequestLoadItemDataByID, itemID)
    end
end

local function FormatMaterialsSignedMoney(addon, value)
    local amount = math.floor(math.abs(tonumber(value) or 0) + 0.5)
    local text = addon:FormatMoney(amount)
    if (tonumber(value) or 0) < 0 then
        return "-" .. text
    end
    return text
end

local function GetMaterialsDemandTier(regionSoldPerDay)
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

local function FormatMaterialsSoldPerDay(regionSoldPerDay)
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

local function FormatMaterialsSaleRate(regionSaleRate)
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

local function GetMaterialsSellRateTier(regionSaleRate)
    local saleRate = tonumber(regionSaleRate)
    if not saleRate or saleRate <= 0 then
        return "--", 0.62, 0.66, 0.74
    end
    if saleRate >= 0.50 then
        return "Instant", 0.52, 1.00, 0.56
    end
    if saleRate >= 0.25 then
        return "Fast", 0.68, 0.96, 0.72
    end
    if saleRate >= 0.10 then
        return "Steady", 0.72, 0.86, 1.0
    end
    if saleRate >= 0.03 then
        return "Slow", 1.0, 0.82, 0.18
    end
    return "Very Slow", 1.00, 0.58, 0.42
end

local function FormatMaterialsDecimalValue(value, decimals)
    local numberValue = tonumber(value)
    if not numberValue then
        return nil
    end
    return string.format("%." .. tostring(decimals or 2) .. "f", numberValue)
end

local function FormatMaterialsTrendPercent(marketTrendPercent)
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

local function GetMaterialsTrendColor(marketTrendPercent)
    local trend = tonumber(marketTrendPercent)
    if not trend then
        return 0.62, 0.66, 0.74
    end
    if trend > 0 then
        return 0.52, 1.00, 0.56
    end
    if trend < 0 then
        return 1.00, 0.58, 0.42
    end
    return 0.72, 0.86, 1.0
end

local function GetMaterialsRawTSMValue(addon, itemLink, itemID, tsmKey)
    local normalizedItemID = tonumber(itemID)
    if normalizedItemID and type(TSM_API) == "table" and type(TSM_API.GetCustomPriceValue) == "function" then
        local itemString = string.format("i:%d", math.floor(normalizedItemID + 0.5))
        local ok, value = pcall(TSM_API.GetCustomPriceValue, tsmKey, itemString)
        if ok and type(value) == "number" and value > 0 then
            return value
        end
        return nil
    end

    if type(itemLink) == "string" and itemLink ~= "" and type(addon.GetTSMRawCustomValue) == "function" then
        return addon:GetTSMRawCustomValue(tsmKey, itemLink)
    end
    return nil
end

local function GetMaterialsRegionalDemandData(addon, itemLink, itemID, demandCache)
    local normalizedItemID = tonumber(itemID)
    local cacheKey = normalizedItemID and tostring(math.floor(normalizedItemID + 0.5))
        or (type(itemLink) == "string" and itemLink ~= "" and itemLink or nil)
    if not cacheKey then
        return nil
    end

    if type(demandCache) == "table" and demandCache[cacheKey] then
        return demandCache[cacheKey]
    end

    local regionSoldPerDay = GetMaterialsRawTSMValue(addon, itemLink, normalizedItemID, "DBRegionSoldPerDay")
    local regionSaleRate = GetMaterialsRawTSMValue(addon, itemLink, normalizedItemID, "DBRegionSaleRate")
    local marketValue = GetMaterialsRawTSMValue(addon, itemLink, normalizedItemID, "DBMarket")
    local historicalValue = GetMaterialsRawTSMValue(addon, itemLink, normalizedItemID, "DBHistorical")
    local tierKey, tierLabel, r, g, b = GetMaterialsDemandTier(regionSoldPerDay)
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

local function GetCachedMaterialsRegionalDemandData(frame, itemID)
    local normalizedItemID = tonumber(itemID)
    local cacheKey = normalizedItemID and tostring(math.floor(normalizedItemID + 0.5)) or nil
    if not cacheKey or type(frame and frame.materialsDemandCache) ~= "table" then
        return nil
    end
    return frame.materialsDemandCache[cacheKey]
end

local function NormalizeMaterialsSortKey(sortKey)
    if MATERIALS_SORT_KEYS[sortKey] then
        return sortKey
    end
    return MATERIALS_DEFAULT_SORT_KEY
end

local function GetMaterialsSortValue(row, sortKey)
    if row and row.rowType == "divider" then
        return 0
    end
    if sortKey == "expansion" then
        return string.lower(tostring(row and row.expansionLabel or ""))
    end
    if sortKey == "profession" then
        return string.lower(tostring(row and row.professionLabel or ""))
    end
    if sortKey == "tag" then
        return string.lower(tostring(row and row.tag or ""))
    end
    if sortKey == "itemName" then
        return string.lower(tostring(row and (row.itemName or row.itemLink or row.itemID) or ""))
    end
    if sortKey == "dropRate" then
        return tonumber(row and row.dropPerHour) or 0
    end
    if sortKey == "goldRate" then
        return tonumber(row and row.goldPerHour) or 0
    end
    if sortKey == "demand" then
        return tonumber(row and row.regionSoldPerDay) or 0
    end
    if sortKey == "sellRate" then
        return tonumber(row and row.regionSaleRate) or 0
    end
    if sortKey == "marketTrend" then
        return tonumber(row and row.marketTrendPercent) or -1000000
    end
    if sortKey == "componentCost" then
        return tonumber(row and row.componentCost) or 0
    end
    if sortKey == "profit" then
        return tonumber(row and row.profitValue) or 0
    end
    return tonumber(row and row.value) or 0
end

local function SortMaterialsRows(rows, sortKey, sortAscending, sortCriteria)
    local criteria = type(sortCriteria) == "table" and sortCriteria or {
        { key = NormalizeMaterialsSortKey(sortKey), ascending = sortAscending == true },
    }
    local primarySortKey = criteria[1] and NormalizeMaterialsSortKey(criteria[1].key)
        or NormalizeMaterialsSortKey(sortKey)

    table.sort(rows, function(left, right)
        for _, criterion in ipairs(criteria) do
            local normalizedSortKey = NormalizeMaterialsSortKey(criterion.key)
            local leftValue = GetMaterialsSortValue(left, normalizedSortKey)
            local rightValue = GetMaterialsSortValue(right, normalizedSortKey)
            if leftValue ~= rightValue then
                if criterion.ascending == true then
                    return leftValue < rightValue
                end
                return leftValue > rightValue
            end
        end

        if primarySortKey == "demand" or primarySortKey == "sellRate" then
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

            local leftValueTotal = tonumber(left and left.value) or 0
            local rightValueTotal = tonumber(right and right.value) or 0
            if leftValueTotal ~= rightValueTotal then
                return leftValueTotal > rightValueTotal
            end
        end

        local leftName = string.lower(tostring(left and (left.itemName or left.itemLink or left.itemID) or ""))
        local rightName = string.lower(tostring(right and (right.itemName or right.itemLink or right.itemID) or ""))
        if leftName ~= rightName then
            return leftName < rightName
        end

        return (tonumber(left and left.itemID) or 0) < (tonumber(right and right.itemID) or 0)
    end)
end

local function FormatMaterialsDropRate(value)
    local normalized = tonumber(value) or 0
    if normalized <= 0 then
        return "--"
    end
    if normalized >= 100 then
        return tostring(math.floor(normalized + 0.5)) .. "/h"
    end
    if normalized >= 10 then
        return string.format("%.1f/h", normalized)
    end
    return string.format("%.2f/h", normalized)
end

local function NormalizeMaterialsDropRateLookup(rawLookup)
    local normalized = {}
    if type(rawLookup) ~= "table" then
        return normalized
    end

    for key, rawEntry in pairs(rawLookup) do
        if key ~= "updatedAt" and key ~= "items" then
            local itemID = tonumber(type(rawEntry) == "table" and rawEntry.itemID or nil) or tonumber(key)
            if itemID then
                itemID = math.floor(itemID + 0.5)
            end
            if itemID and itemID > 0 and type(rawEntry) == "table" then
                local quantity = math.max(0, tonumber(rawEntry.quantity) or 0)
                local durationSeconds = math.max(0, math.floor((tonumber(rawEntry.durationSeconds) or 0) + 0.5))
                local sessionCount = math.max(0, math.floor((tonumber(rawEntry.sessionCount) or 0) + 0.5))
                local dropPerHour = math.max(0, tonumber(rawEntry.dropPerHour) or 0)
                if dropPerHour <= 0 and quantity > 0 and durationSeconds > 0 then
                    dropPerHour = (quantity * 3600) / durationSeconds
                end

                if quantity > 0 or durationSeconds > 0 or dropPerHour > 0 then
                    normalized[itemID] = {
                        itemID = itemID,
                        quantity = quantity,
                        durationSeconds = durationSeconds,
                        sessionCount = sessionCount,
                        dropPerHour = dropPerHour,
                    }
                end
            end
        end
    end

    return normalized
end

local function CopyMaterialsDropRateLookupForStorage(lookup)
    local stored = {}
    for itemID, entry in pairs(NormalizeMaterialsDropRateLookup(lookup)) do
        stored[tostring(itemID)] = {
            itemID = entry.itemID,
            quantity = entry.quantity,
            durationSeconds = entry.durationSeconds,
            sessionCount = entry.sessionCount,
            dropPerHour = entry.dropPerHour,
        }
    end
    return stored
end

function GoldTracker:GetSavedCraftingFarmingDropRateLookup()
    local saved = type(self.db) == "table" and self.db.craftingFarmingDropRates or nil
    local rawLookup = type(saved) == "table" and (saved.items or saved) or nil
    local updatedAt = type(saved) == "table" and tonumber(saved.updatedAt) or nil
    return NormalizeMaterialsDropRateLookup(rawLookup), updatedAt
end

function GoldTracker:SaveCraftingFarmingDropRateLookup(lookup, updatedAt)
    local refreshed = NormalizeMaterialsDropRateLookup(lookup)
    local normalized = self:GetSavedCraftingFarmingDropRateLookup()
    for itemID, entry in pairs(refreshed) do
        if (tonumber(entry.dropPerHour) or 0) > 0 then
            normalized[itemID] = entry
        end
    end
    local timestamp = tonumber(updatedAt) or (type(time) == "function" and time()) or nil

    if type(self.db) == "table" then
        self.db.craftingFarmingDropRates = {
            updatedAt = timestamp,
            items = CopyMaterialsDropRateLookupForStorage(normalized),
        }
    end

    if self.craftingFarmingFrame then
        self.craftingFarmingFrame.dropRateByItemID = normalized
        self.craftingFarmingFrame.dropRateUpdatedAt = timestamp
    end

    return normalized
end

local function ResolveMaterialsItemCache(addon, frame, source, itemID, deferMetrics)
    frame.itemCache = frame.itemCache or {}
    local cacheKey = tostring(itemID) .. "|" .. tostring(source and source.id or "")
    local cached = frame.itemCache[cacheKey]
    if cached then
        return cached
    end

    local itemName, itemLink, itemQuality, _, _, _, _, _, _, itemIcon = GetItemInfoByID(itemID)
    if not itemName then
        local _, _, _, _, instantIcon = GetItemInstantInfoByID(itemID)
        itemIcon = itemIcon or instantIcon
    end

    local value = 0
    if deferMetrics ~= true and source and source.tsmKey and type(addon.GetTSMItemValueForItemID) == "function" then
        value = addon:GetTSMItemValueForItemID(source.tsmKey, itemID, true)
    end

    cached = {
        itemID = itemID,
        itemName = itemName,
        itemLink = itemLink,
        itemQuality = tonumber(itemQuality),
        icon = itemIcon,
        value = value,
        metricsLoaded = deferMetrics ~= true,
        valueSourceID = source and source.id,
        valueSourceLabel = source and source.label,
    }
    frame.itemCache[cacheKey] = cached

    if not itemName and not cached.dataRequested then
        cached.dataRequested = true
        RequestMaterialsItemData(addon, itemID)
    end

    return cached
end


local function LoadMaterialsItemMetrics(addon, frame, source, itemID)
    local normalizedItemID = tonumber(itemID)
    if not normalizedItemID then
        return nil
    end
    normalizedItemID = math.floor(normalizedItemID + 0.5)

    local cache = ResolveMaterialsItemCache(addon, frame, source, normalizedItemID, true)
    if cache.metricsLoaded == true then
        return cache
    end

    frame.materialsDemandCache = frame.materialsDemandCache or {}
    local demandData = GetMaterialsRegionalDemandData(
        addon,
        cache.itemLink,
        normalizedItemID,
        frame.materialsDemandCache
    ) or {}

    local valueByDemandSource = {
        DBMarket = demandData.marketValue,
        DBHistorical = demandData.historicalValue,
        DBRegionSaleRate = demandData.regionSaleRate,
        DBRegionSoldPerDay = demandData.regionSoldPerDay,
    }
    local value = source and source.tsmKey and valueByDemandSource[source.tsmKey] or nil
    if value == nil and source and source.tsmKey and type(addon.GetTSMItemValueForItemID) == "function" then
        value = addon:GetTSMItemValueForItemID(source.tsmKey, normalizedItemID, true)
    end
    cache.value = math.max(0, tonumber(value) or 0)
    cache.valueSourceID = source and source.id
    cache.valueSourceLabel = source and source.label
    cache.metricsLoaded = true
    return cache
end

local function ItemHasComponents(item)
    return type(item and item.components) == "table" and #item.components > 0
end

local function GetComposedMaterialExpandedStore(frame)
    if not frame then
        return {}
    end
    if type(frame.expandedComposedMaterials) ~= "table" then
        frame.expandedComposedMaterials = {}
    end
    return frame.expandedComposedMaterials
end

local function NormalizeMaterialsSearchText(value)
    return string.lower(tostring(value or ""):gsub("^%s+", ""):gsub("%s+$", ""))
end

local function MaterialItemMatchesSearch(addon, frame, source, itemID, normalizedSearchText)
    if normalizedSearchText == "" then
        return true
    end

    local cacheKey = tostring(itemID) .. "|" .. tostring(source and source.id or "")
    local cached = frame.itemCache and frame.itemCache[cacheKey]
    local itemName = cached and cached.itemName
    if not itemName then
        itemName = GetItemInfoByID(itemID)
    end
    if not itemName then
        frame.searchItemDataRequested = frame.searchItemDataRequested or {}
        if not frame.searchItemDataRequested[itemID] then
            frame.searchItemDataRequested[itemID] = true
            RequestMaterialsItemData(addon, itemID)
        end
        return false
    end

    return string.find(string.lower(itemName), normalizedSearchText, 1, true) ~= nil
end

local function GetComposedMaterialLoadedStore(frame)
    if not frame then
        return {}
    end
    if type(frame.loadedComposedMaterials) ~= "table" then
        frame.loadedComposedMaterials = {}
    end
    return frame.loadedComposedMaterials
end

local function BuildMaterialRow(addon, frame, source, expansionLookup, item, deferMetrics, loadComposedComponents)
    local itemID = tonumber(item and item.itemID)
    if not itemID then
        return nil
    end

    local cache = ResolveMaterialsItemCache(addon, frame, source, math.floor(itemID + 0.5), deferMetrics)
    local normalizedItemID = math.floor(itemID + 0.5)
    local outputQuantity = math.max(1, math.floor(tonumber(item.outputQuantity) or 1))
    local dropRate = frame.dropRateByItemID and frame.dropRateByItemID[normalizedItemID] or nil
    frame.materialsDemandCache = frame.materialsDemandCache or {}
    local demandData = deferMetrics == true
        and (GetCachedMaterialsRegionalDemandData(frame, normalizedItemID) or {})
        or (GetMaterialsRegionalDemandData(
            addon,
            cache.itemLink,
            normalizedItemID,
            frame.materialsDemandCache
        ) or {})
    local row = {
        itemID = normalizedItemID,
        itemName = cache.itemName,
        itemLink = cache.itemLink,
        itemQuality = cache.itemQuality,
        icon = cache.icon,
        value = cache.value,
        valueSourceID = cache.valueSourceID,
        valueSourceLabel = cache.valueSourceLabel,
        expansionID = item.expansion,
        expansionLabel = GetOptionLabel(expansionLookup, item.expansion, tostring(item.expansion or "Unknown")),
        professionLabel = GetPrimaryProfessionLabel(item),
        professionIDs = item.professions,
        tag = item.tag or "Material",
        acquisitionType = item.acquisitionType,
        learnedFromSession = item.learnedFromSession == true,
        manualProfessionOverride = item.manualProfessionOverride == true,
        outputQuantity = outputQuantity,
        recipeSpellID = item.recipeSpellID,
        recipeSource = item.recipeSource,
        recipeSourceLabel = item.recipeSourceLabel,
        dropPerHour = dropRate and dropRate.dropPerHour or 0,
        dropQuantity = dropRate and dropRate.quantity or 0,
        dropDurationSeconds = dropRate and dropRate.durationSeconds or 0,
        dropSessionCount = dropRate and dropRate.sessionCount or 0,
        isComposedMaterial = ItemHasComponents(item),
        components = item.components,
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
        marketHistorySnapshot = {
            dbMarket = demandData.marketValue,
            dbHistorical = demandData.historicalValue,
            dbRegionSaleRate = demandData.regionSaleRate,
            dbRegionSoldPerDay = demandData.regionSoldPerDay,
            selectedUnitValue = cache.value,
        },
        hasFarmingMap = HasMaterialFarmingMapData(addon, normalizedItemID),
        farmCount = GetMaterialFarmCount(normalizedItemID),
    }

    row.goldPerHour = math.max(0, tonumber(row.dropPerHour) or 0)
        * math.max(0, tonumber(row.value) or 0)

    row.hasFarm = row.farmCount > 0

    if row.isComposedMaterial then
        row.expanded = GetComposedMaterialExpandedStore(frame)[row.itemID] == true
        local loadedStore = GetComposedMaterialLoadedStore(frame)
        if row.expanded or loadComposedComponents == true then
            loadedStore[row.itemID] = true
        end
        row.componentsLoaded = loadComposedComponents == true or loadedStore[row.itemID] == true

        if not row.componentsLoaded then
            return row
        end

        row.componentCost = 0
        for _, component in ipairs(item.components) do
            local componentItemID = tonumber(component and component.itemID)
            local componentQuantity = math.max(0, tonumber(component and component.quantity) or 0)
            if componentItemID and componentQuantity > 0 then
                local componentCache = ResolveMaterialsItemCache(
                    addon,
                    frame,
                    source,
                    math.floor(componentItemID + 0.5),
                    deferMetrics
                )
                row.componentCost = row.componentCost + (math.max(0, tonumber(componentCache.value) or 0) * componentQuantity)
            end
        end
        row.craftValue = math.max(0, tonumber(row.value) or 0) * outputQuantity
        row.profitValue = row.craftValue - row.componentCost
    end

    return row
end

local function BuildComponentRow(addon, frame, source, expansionLookup, itemLookup, parentRow, component, depth, quantityMultiplier, deferMetrics)
    local itemID = tonumber(component and component.itemID)
    if not itemID then
        return nil
    end

    local componentItem = itemLookup[itemID] or {}
    local cache = ResolveMaterialsItemCache(addon, frame, source, math.floor(itemID + 0.5), deferMetrics)
    local quantity = math.max(0, tonumber(component.quantity) or 0)
        * math.max(0, tonumber(quantityMultiplier) or 1)
    local normalizedItemID = math.floor(itemID + 0.5)
    local isComposedMaterial = ItemHasComponents(componentItem)
    local farmCount = GetMaterialFarmCount(normalizedItemID)
    local dropRate = frame.dropRateByItemID and frame.dropRateByItemID[normalizedItemID] or nil
    frame.materialsDemandCache = frame.materialsDemandCache or {}
    local demandData = deferMetrics == true
        and (GetCachedMaterialsRegionalDemandData(frame, normalizedItemID) or {})
        or (GetMaterialsRegionalDemandData(
            addon,
            cache.itemLink,
            normalizedItemID,
            frame.materialsDemandCache
        ) or {})
    local row = {
        rowType = "component",
        parentItemID = parentRow.itemID,
        rootItemID = parentRow.rootItemID or parentRow.itemID,
        componentDepth = math.max(1, math.floor(tonumber(depth) or 1)),
        itemID = normalizedItemID,
        itemName = cache.itemName,
        itemLink = cache.itemLink,
        itemQuality = cache.itemQuality,
        icon = cache.icon,
        value = cache.value,
        componentQuantity = quantity,
        componentCost = math.max(0, tonumber(cache.value) or 0) * quantity,
        outputQuantity = math.max(1, math.floor(tonumber(componentItem.outputQuantity) or 1)),
        isComposedMaterial = isComposedMaterial,
        components = componentItem.components,
        expanded = isComposedMaterial and GetComposedMaterialExpandedStore(frame)[normalizedItemID] == true or false,
        recipeSpellID = componentItem.recipeSpellID,
        recipeSource = componentItem.recipeSource,
        recipeSourceLabel = componentItem.recipeSourceLabel,
        valueSourceID = cache.valueSourceID,
        valueSourceLabel = cache.valueSourceLabel,
        dropPerHour = dropRate and dropRate.dropPerHour or 0,
        dropQuantity = dropRate and dropRate.quantity or 0,
        dropDurationSeconds = dropRate and dropRate.durationSeconds or 0,
        dropSessionCount = dropRate and dropRate.sessionCount or 0,
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
        marketHistorySnapshot = {
            dbMarket = demandData.marketValue,
            dbHistorical = demandData.historicalValue,
            dbRegionSaleRate = demandData.regionSaleRate,
            dbRegionSoldPerDay = demandData.regionSoldPerDay,
            selectedUnitValue = cache.value,
        },
        expansionID = componentItem.expansion or parentRow.expansionID,
        expansionLabel = GetOptionLabel(expansionLookup, componentItem.expansion, parentRow.expansionLabel),
        professionLabel = GetPrimaryProfessionLabel(componentItem),
        tag = componentItem.tag or "Component",
        hasFarmingMap = HasMaterialFarmingMapData(addon, normalizedItemID),
        farmCount = farmCount,
        hasFarm = farmCount > 0,
    }
    row.goldPerHour = math.max(0, tonumber(row.dropPerHour) or 0)
        * math.max(0, tonumber(row.value) or 0)
    return row
end

local function AppendExpandedComponentRows(addon, frame, source, expansionLookup, itemLookup, rows, parentRow, depth, ancestry, deferMetrics)
    local quantityMultiplier = 1
    if parentRow.rowType == "component" then
        local requiredQuantity = math.max(0, tonumber(parentRow.componentQuantity) or 0)
        local outputQuantity = math.max(1, tonumber(parentRow.outputQuantity) or 1)
        quantityMultiplier = math.ceil(requiredQuantity / outputQuantity)
    end

    for _, component in ipairs(parentRow.components or {}) do
        local componentRow = BuildComponentRow(
            addon,
            frame,
            source,
            expansionLookup,
            itemLookup,
            parentRow,
            component,
            depth,
            quantityMultiplier,
            deferMetrics
        )
        if componentRow then
            rows[#rows + 1] = componentRow
            if componentRow.isComposedMaterial and componentRow.expanded and not ancestry[componentRow.itemID] then
                ancestry[componentRow.itemID] = true
                AppendExpandedComponentRows(
                    addon,
                    frame,
                    source,
                    expansionLookup,
                    itemLookup,
                    rows,
                    componentRow,
                    depth + 1,
                    ancestry,
                    deferMetrics
                )
                ancestry[componentRow.itemID] = nil
            end
        end
    end
end

function GoldTracker:GetCraftingFarmingValueSource()
    local source = self.VALUE_SOURCE_BY_ID[self.db and self.db.craftingFarmingValueSource]
    if source then
        return source
    end

    return self.VALUE_SOURCE_BY_ID[self.DEFAULTS.craftingFarmingValueSource]
        or self:GetAuctionableInventoryValueSource()
        or self:GetCurrentValueSource()
end

function GoldTracker:SetCraftingFarmingValueSource(sourceID)
    local source = self.VALUE_SOURCE_BY_ID[sourceID] or self:GetCraftingFarmingValueSource()
    if self.db and source then
        self.db.craftingFarmingValueSource = source.id
    end
    if self.craftingFarmingFrame and source then
        self.craftingFarmingFrame.valueSourceID = source.id
        self.craftingFarmingFrame.itemCache = {}
    end
    return source
end

function GoldTracker:SetCraftingFarmingExpansionFilter(expansionID)
    local normalizedExpansionID = NormalizeExpansionID(expansionID)
    if self.db then
        self.db.craftingFarmingExpansionID = normalizedExpansionID
    end
    if self.craftingFarmingFrame then
        self.craftingFarmingFrame.expansionID = normalizedExpansionID
    end
    return normalizedExpansionID
end

function GoldTracker:SetCraftingFarmingProfessionFilter(professionID)
    local selected, ordered = NormalizeProfessionSelections(nil, professionID)
    local normalizedProfessionID = ordered[1] or NormalizeProfessionID(nil)
    if self.db then
        self.db.craftingFarmingProfessionID = normalizedProfessionID
        self.db.craftingFarmingProfessionIDs = ordered
    end
    if self.craftingFarmingFrame then
        self.craftingFarmingFrame.professionID = normalizedProfessionID
        self.craftingFarmingFrame.professionIDs = selected
    end
    return normalizedProfessionID
end

function GoldTracker:ToggleCraftingFarmingProfessionFilter(professionID)
    local frame = self.craftingFarmingFrame
    local selected, ordered = NormalizeProfessionSelections(nil, professionID)
    local normalizedProfessionID = ordered[1] or NormalizeProfessionID(nil)
    if self.db then
        self.db.craftingFarmingProfessionID = normalizedProfessionID
        self.db.craftingFarmingProfessionIDs = ordered
    end
    if frame then
        frame.professionID = normalizedProfessionID
        frame.professionIDs = selected
    end
    return selected
end

function GoldTracker:BuildCraftingFarmingRows(options)
    local frame = self.craftingFarmingFrame
    if not frame then
        return {}
    end

    options = type(options) == "table" and options or {}
    local deferMetrics = options.deferMetrics == true
    local source = self.VALUE_SOURCE_BY_ID[frame.valueSourceID] or self:GetCraftingFarmingValueSource()
    local expansionID = NormalizeExpansionID(frame.expansionID)
    local professionIDs = NormalizeProfessionSelections(frame.professionIDs, frame.professionID)
    local searchText = NormalizeMaterialsSearchText(frame.searchText)
    local isSearching = searchText ~= ""
    local expansionLookup = GetExpansionLookup()
    local rows = {}
    local baseRows = {}
    local instanceRows = {}
    local composedRows = {}
    local composedMaterialCount = 0
    local composedMaterialsExpanded = frame.composedMaterialsExpanded == true
    local seenItems = {}
    local materialItems = BuildMaterialsItemList(self)
    local itemLookup = {}
    for _, item in ipairs(materialItems) do
        local itemID = tonumber(item and item.itemID)
        if itemID and not itemLookup[itemID] then
            itemLookup[itemID] = item
        end
    end

    for _, item in ipairs(materialItems) do
        local itemID = tonumber(item and item.itemID)
        if itemID
            and not seenItems[itemID]
            and (isSearching or expansionID == "all" or item.expansion == expansionID)
            and (isSearching or ItemMatchesProfessionSelection(item, professionIDs))
            and MaterialItemMatchesSearch(self, frame, source, itemID, searchText) then
            seenItems[itemID] = true
            local isComposedMaterial = ItemHasComponents(item)
            local row
            if isComposedMaterial and not composedMaterialsExpanded then
                composedMaterialCount = composedMaterialCount + 1
            else
                row = BuildMaterialRow(
                    self,
                    frame,
                    source,
                    expansionLookup,
                    item,
                    deferMetrics,
                    isComposedMaterial and composedMaterialsExpanded
                )
            end
            if row then
                if row.isComposedMaterial then
                    composedMaterialCount = composedMaterialCount + 1
                    composedRows[#composedRows + 1] = row
                elseif row.acquisitionType == "instance" then
                    instanceRows[#instanceRows + 1] = row
                else
                    baseRows[#baseRows + 1] = row
                end
            end
        end
    end

    local sortCriteria = self:GetTableSortCriteria(frame, "sortKey", "sortAscending", MATERIALS_SORT_KEYS)
    SortMaterialsRows(baseRows, frame.sortKey, frame.sortAscending, sortCriteria)
    SortMaterialsRows(instanceRows, frame.sortKey, frame.sortAscending, sortCriteria)
    SortMaterialsRows(composedRows, frame.sortKey, frame.sortAscending, sortCriteria)

    for _, row in ipairs(baseRows) do
        rows[#rows + 1] = row
    end
    if #instanceRows > 0 then
        rows[#rows + 1] = {
            rowType = "divider",
            label = "Raid and dungeon mining materials",
        }
        for _, row in ipairs(instanceRows) do
            rows[#rows + 1] = row
        end
    end
    if composedMaterialCount > 0 then
        rows[#rows + 1] = {
            rowType = "divider",
            label = "Composed materials",
            dividerKind = "composedMaterials",
            expanded = composedMaterialsExpanded,
        }
        if composedMaterialsExpanded then
            for _, row in ipairs(composedRows) do
                rows[#rows + 1] = row
                if row.expanded then
                    AppendExpandedComponentRows(
                        self,
                        frame,
                        source,
                        expansionLookup,
                        itemLookup,
                        rows,
                        row,
                        1,
                        { [row.itemID] = true },
                        deferMetrics
                    )
                end
            end
        end
    end

    return rows
end

function GoldTracker:GetCraftingFarmingKnownMaterialItems()
    return BuildMaterialsItemList(self)
end

function GoldTracker:GetCraftingFarmingProfessionOptions()
    return GetProfessionOptions()
end

function GoldTracker:IsCraftingFarmingFavorite(rowOrItemID)
    if type(self.IsFarmingItemFavorite) == "function" then
        return self:IsFarmingItemFavorite(rowOrItemID)
    end

    local key = GetCraftingFarmingFavoriteKey(rowOrItemID)
    local favorites = type(self.db) == "table" and self.db.farmingItemFavorites or nil
    return key ~= nil and type(favorites) == "table" and favorites[key] ~= nil
end

function GoldTracker:SetCraftingFarmingFavorite(row, isFavorite)
    local key = type(self.GetFarmingFavoriteKey) == "function"
        and self:GetFarmingFavoriteKey(row)
        or GetCraftingFarmingFavoriteKey(row)
    if not key then
        return false
    end

    local favorites = type(self.GetFarmingFavoriteStore) == "function" and self:GetFarmingFavoriteStore()
        or (type(self.db) == "table" and self.db.farmingItemFavorites or nil)
    if type(favorites) ~= "table" then
        return false
    end

    if isFavorite then
        local cachedRow = CloneCraftingFarmingFavorite(row)
        if not cachedRow then
            return false
        end
        cachedRow.favoriteKey = key
        cachedRow.favoritedAt = type(date) == "function" and date("%Y-%m-%d %H:%M") or nil
        cachedRow.favoritedAtTime = type(time) == "function" and time() or 0
        favorites[key] = cachedRow
    else
        favorites[key] = nil
    end
    return true
end

function GoldTracker:ToggleCraftingFarmingFavorite(row)
    local shouldFavorite = not self:IsCraftingFarmingFavorite(row)
    if self:SetCraftingFarmingFavorite(row, shouldFavorite) then
        self:RefreshCraftingFarmingWindow(false)
        if self.rareFarmingFrame and type(self.RefreshRareFarmingLibraryWindow) == "function" then
            self:RefreshRareFarmingLibraryWindow()
        end
    end
end

function GoldTracker:BuildMaterialFarmingMapOptions(itemID)
    return BuildMaterialFarmingMapOptions(self, itemID)
end

local function GetFarmSelectedItemQuantity(option, selectedItemID)
    local normalizedItemID = tonumber(selectedItemID)
    if not normalizedItemID or type(option) ~= "table" or type(option.farm) ~= "table" then
        return 0
    end

    local quantity = 0
    for _, target in ipairs(option.farm.targets or {}) do
        if tonumber(target and target.itemID) == normalizedItemID then
            quantity = quantity + math.max(0, tonumber(target.quantity) or 0)
        end
    end
    return quantity
end

local function GroupMaterialFarmingMapOptions(mapOptions, selectedItemID)
    local grouped = {
        user = {},
        map = {},
        farm = {},
    }
    local groupLabels = {
        user = "User map data",
        map = "Map data",
        farm = "Farm data",
    }

    local farmOrder = {}
    local farmQuantity = {}
    for optionIndex, option in ipairs(mapOptions or {}) do
        local groupID = option.farm and "farm" or (option.sourceType == "user" and "user" or "map")
        option.dropdownGroup = groupID
        option.dropdownGroupLabel = groupLabels[groupID]
        grouped[groupID][#grouped[groupID] + 1] = option
        if groupID == "farm" then
            farmOrder[option] = optionIndex
            farmQuantity[option] = GetFarmSelectedItemQuantity(option, selectedItemID)
        end
    end

    table.sort(grouped.farm, function(left, right)
        local leftQuantity = farmQuantity[left] or 0
        local rightQuantity = farmQuantity[right] or 0
        if leftQuantity ~= rightQuantity then
            return leftQuantity > rightQuantity
        end
        return (farmOrder[left] or 0) < (farmOrder[right] or 0)
    end)

    local ordered = {}
    for _, groupID in ipairs({ "user", "map", "farm" }) do
        for _, option in ipairs(grouped[groupID]) do
            ordered[#ordered + 1] = option
        end
    end
    return ordered
end

function GoldTracker:OpenMaterialFarmingMap(itemID)
    local materialData = GetMaterialFarmingSpotData(itemID)
    local mapOptions = BuildMaterialFarmingMapOptions(self, itemID)
    local farms = type(self.GetFarmsForItem) == "function" and self:GetFarmsForItem(itemID) or {}
    if #farms > 0 and type(self.BuildFarmDetailsMapOptions) == "function" then
        for _, farmOption in ipairs(self:BuildFarmDetailsMapOptions(farms, itemID) or {}) do
            farmOption.label = "farm: " .. tostring((farmOption.farm and farmOption.farm.name) or farmOption.windowTitle or farmOption.label)
            mapOptions[#mapOptions + 1] = farmOption
        end
    end
    mapOptions = GroupMaterialFarmingMapOptions(mapOptions, itemID)
    if #mapOptions == 0 then
        local frame = self.craftingFarmingFrame
        if frame and frame.metaText then
            frame.metaText:SetText("No coordinate-backed farming map data for this material yet.")
        end
        return false
    end

    if type(self.OpenStandaloneMapWindow) ~= "function" then
        local frame = self.craftingFarmingFrame
        if frame and frame.metaText then
            frame.metaText:SetText("The standalone map window is not available yet.")
        end
        return false
    end

    local title = materialData and materialData.itemName
    if type(title) ~= "string" or title == "" then
        local firstPin = mapOptions[1] and mapOptions[1].pins and mapOptions[1].pins[1]
        title = (firstPin and firstPin.itemName) or (farms[1] and farms[1].name)
    end

    local valuationSnapshots = {}
    local expandedFarmTargets = {}
    self:OpenStandaloneMapWindow({
        title = title or ("Item " .. tostring(itemID)),
        projectionKey = "material:" .. tostring(itemID),
        mapOptions = mapOptions,
        customFarmRow = { itemID = itemID, itemName = title },
        customFarmSourceType = "materials",
        detailLinesBuilder = function(mapOption, _, mapLabel)
            if mapOption and mapOption.farm and type(self.BuildFarmMapDetailLines) == "function" then
                local farm = mapOption.farm
                local key = farm.id or tostring(farm)
                valuationSnapshots[key] = valuationSnapshots[key] or self:BuildFarmValuationSnapshot(farm)
                return self:BuildFarmMapDetailLines(farm, itemID, mapLabel, valuationSnapshots[key], {
                    showAllTargets = expandedFarmTargets[key] == true,
                    onToggleTargets = function()
                        expandedFarmTargets[key] = not expandedFarmTargets[key]
                        self:RefreshStandaloneMapWindow()
                    end,
                })
            end
            return self:BuildStandaloneMapDetailLines((mapOption and mapOption.pins) or {}, mapOption and mapOption.mapID, mapLabel)
        end,
    })
    return true
end

local function GetMaterialsSessionDuration(addon, session)
    if session == addon.session and session and session.active == true and type(addon.GetSessionRateDurationSeconds) == "function" then
        return math.max(1, tonumber(addon:GetSessionRateDurationSeconds()) or 0)
    end
    local activeDuration = tonumber(session and session.activeDuration) or tonumber(session and session.activeDurationSeconds) or 0
    if activeDuration > 0 then
        return math.max(1, math.floor(activeDuration + 0.5))
    end
    local duration = tonumber(session and session.duration) or 0
    if duration > 0 then
        return math.max(1, math.floor(duration + 0.5))
    end
    local startTime = tonumber(session and session.startTime) or 0
    local stopTime = tonumber(session and (session.stopTime or session.savedAt)) or 0
    if startTime > 0 and stopTime > startTime then
        return math.max(1, math.floor((stopTime - startTime) + 0.5))
    end
    return 0
end

local function IterateMaterialsSessions(addon, callback)
    if type(addon.session) == "table" and type(addon.session.itemLoots) == "table" then
        callback(addon.session)
    end
    if type(addon.GetSessionHistory) == "function" then
        for _, session in ipairs(addon:GetSessionHistory() or {}) do
            if type(session) == "table" and type(session.itemLoots) == "table" then
                callback(session)
            end
        end
    end
end

local function GetMaterialsMedian(values)
    if type(values) ~= "table" or #values == 0 then
        return 0
    end

    table.sort(values)
    local middle = math.floor((#values + 1) / 2)
    if #values % 2 == 1 then
        return values[middle]
    end
    return (values[middle] + values[middle + 1]) / 2
end

function GoldTracker:BuildCraftingFarmingDropRateLookup()
    local lookup = {}
    IterateMaterialsSessions(self, function(session)
        local perSessionQuantity = {}
        for _, loot in ipairs(session.itemLoots or {}) do
            local itemID = tonumber(loot and loot.itemID)
            if not itemID and type(loot and loot.itemLink) == "string" then
                itemID = self:GetItemIDFromLink(loot.itemLink)
            end
            local isCraftingReagent = loot and loot.isCraftingReagent == true
            if not isCraftingReagent and type(loot and loot.itemLink) == "string" then
                isCraftingReagent = self:IsCraftingReagentItem(loot.itemLink)
            end
            if itemID and isCraftingReagent then
                itemID = math.floor(itemID + 0.5)
                perSessionQuantity[itemID] = (perSessionQuantity[itemID] or 0) + math.max(0, tonumber(loot.quantity) or 0)
            end
        end

        local durationSeconds = GetMaterialsSessionDuration(self, session)
        for itemID, quantity in pairs(perSessionQuantity) do
            if quantity > 0 then
                local entry = lookup[itemID] or {
                    itemID = itemID,
                    quantity = 0,
                    durationSeconds = 0,
                    sessionCount = 0,
                    dropPerHour = 0,
                    sessionDropRates = {},
                }
                entry.quantity = entry.quantity + quantity
                entry.durationSeconds = entry.durationSeconds + durationSeconds
                entry.sessionCount = entry.sessionCount + 1
                if durationSeconds > 0 then
                    entry.sessionDropRates[#entry.sessionDropRates + 1] = (quantity * 3600) / durationSeconds
                end
                lookup[itemID] = entry
            end
        end
    end)

    for _, entry in pairs(lookup) do
        entry.dropPerHour = GetMaterialsMedian(entry.sessionDropRates)
        entry.sessionDropRates = nil
    end
    return lookup
end

local function GetMaterialsExpansionIDFromLoot(loot)
    local expansionID = tonumber(loot and loot.expansionID)
    if expansionID and EXPANSION_ID_TO_MATERIALS_ID[expansionID] then
        return EXPANSION_ID_TO_MATERIALS_ID[expansionID], "loot"
    end

    local expansionName = string.lower(tostring(loot and loot.expansionName or ""))
    for _, option in ipairs(GetExpansionOptions()) do
        if option.id ~= "all" and expansionName ~= "" and string.lower(option.label) == expansionName then
            return option.id, "loot"
        end
    end
    return "all", "unknown"
end

local function GetMaterialsProfessionIDFromLoot(loot, fallbackProfessionID)
    local subtypeProfessionID = GetMaterialsProfessionIDFromItemSubtype(loot)
    if subtypeProfessionID then
        return subtypeProfessionID, true, "itemSubType"
    end
    local sourceType = loot and loot.lootSourceType
    local professionID = LOOT_SOURCE_PROFESSION_BY_TYPE[sourceType]
    if professionID then
        return professionID, true, "lootSourceType"
    end
    local fallback = NormalizeProfessionID(fallbackProfessionID)
    if fallback ~= "all" then
        return fallback, false, "filterFallback"
    end
    return "all", false, "unknown"
end

local function IsMaterialsLootSellable(addon, loot, itemLink)
    if loot and (loot.isSoulbound == true or loot.ahTracked == false) then
        return false
    end
    if type(itemLink) == "string"
        and itemLink ~= ""
        and type(addon.IsLootItemBindingRestricted) == "function"
        and addon:IsLootItemBindingRestricted(itemLink) then
        return false
    end
    return true
end

function GoldTracker:LearnCraftingFarmingMaterialsFromSessions()
    local knownItems = BuildMaterialsItemLookup(self)
    local learned = 0
    local seenCandidates = {}

    IterateMaterialsSessions(self, function(session)
        for _, loot in ipairs(session.itemLoots or {}) do
            local itemID = tonumber(loot and loot.itemID)
            if not itemID and type(loot and loot.itemLink) == "string" then
                itemID = self:GetItemIDFromLink(loot.itemLink)
            end
            if itemID then
                itemID = math.floor(itemID + 0.5)
            end
            local isCraftingReagent = loot and loot.isCraftingReagent == true
            if not isCraftingReagent and type(loot and loot.itemLink) == "string" then
                isCraftingReagent = self:IsCraftingReagentItem(loot.itemLink)
            end
            local professionID, professionFromLootSource, professionSource = GetMaterialsProfessionIDFromLoot(
                loot,
                self.db and self.db.craftingFarmingProfessionID
            )
            local expansionID, expansionSource = GetMaterialsExpansionIDFromLoot(loot)
            local canTrustProfession = professionFromLootSource
                or professionID == "all"
                or not MATERIALS_GATHERING_PROFESSIONS[professionID]
            if itemID
                and isCraftingReagent
                and IsMaterialsLootSellable(self, loot, loot and loot.itemLink)
                and canTrustProfession
                and not knownItems[itemID]
                and not seenCandidates[itemID] then
                seenCandidates[itemID] = true
                local customItem = self:AddCraftingFarmingCustomItem(
                    itemID,
                    expansionID,
                    professionID,
                    "Session",
                    true,
                    {
                        learnedFromSession = true,
                        importSource = "session",
                        learnedExpansionSource = expansionSource,
                        learnedProfessionSource = professionSource,
                    }
                )
                if customItem then
                    knownItems[itemID] = customItem
                    learned = learned + 1
                end
            end
        end
    end)

    return learned
end

function GoldTracker:UpdateCraftingFarmingItemDisplayData(itemID)
    local frame = self.craftingFarmingFrame
    if not frame or type(frame.itemCache) ~= "table" then
        return
    end

    local normalizedItemID = tonumber(itemID)
    if not normalizedItemID then
        return
    end
    normalizedItemID = math.floor(normalizedItemID + 0.5)
    if type(frame.pendingMaterialsItemRequests) == "table" then
        frame.pendingMaterialsItemRequests[normalizedItemID] = nil
    end

    local itemName, itemLink, itemQuality, _, _, _, _, _, _, itemIcon = GetItemInfoByID(normalizedItemID)
    if not itemName then
        local _, _, _, _, instantIcon = GetItemInstantInfoByID(normalizedItemID)
        itemIcon = itemIcon or instantIcon
    end

    for _, cache in pairs(frame.itemCache) do
        if type(cache) == "table" and tonumber(cache.itemID) == normalizedItemID then
            cache.itemName = itemName or cache.itemName
            cache.itemLink = itemLink or cache.itemLink
            cache.itemQuality = tonumber(itemQuality) or cache.itemQuality
            cache.icon = itemIcon or cache.icon
            cache.dataRequested = false
        end
    end
end

QueueMaterialsItemDisplayRefresh = function(addon, itemID)
    local frame = addon and addon.craftingFarmingFrame
    if not frame then
        return
    end

    frame.pendingMaterialsItemDisplayIDs = frame.pendingMaterialsItemDisplayIDs or {}
    local normalizedItemID = tonumber(itemID)
    if normalizedItemID then
        frame.pendingMaterialsItemDisplayIDs[math.floor(normalizedItemID + 0.5)] = true
    end
    if frame.materialsItemDisplayRefreshQueued then
        return
    end
    frame.materialsItemDisplayRefreshQueued = true

    local function flush()
        local currentFrame = addon.craftingFarmingFrame
        if not currentFrame then
            return
        end
        currentFrame.materialsItemDisplayRefreshQueued = false
        currentFrame.pendingMaterialsItemDisplayIDs = {}
        local expandedFrame = addon.craftingFarmingExpandedFrame
        local expandedShown = expandedFrame and expandedFrame.IsShown and expandedFrame:IsShown()
        if currentFrame.IsShown and not currentFrame:IsShown() and not expandedShown then
            return
        end
        local rows = addon:BuildCraftingFarmingRows({ deferMetrics = true })
        if not currentFrame.materialsRealtimeLoading then
            local source = addon.VALUE_SOURCE_BY_ID[currentFrame.valueSourceID] or addon:GetCraftingFarmingValueSource()
            for _, row in ipairs(rows) do
                local rowItemID = tonumber(row and row.itemID)
                if rowItemID then
                    rowItemID = math.floor(rowItemID + 0.5)
                    local cacheKey = tostring(rowItemID) .. "|" .. tostring(source and source.id or "")
                    local cache = currentFrame.itemCache and currentFrame.itemCache[cacheKey]
                    if not (cache and cache.metricsLoaded == true) then
                        addon:RefreshCraftingFarmingWindow(false)
                        return
                    end
                end
            end
        end
        addon:RefreshCraftingFarmingWindow(false, {
            renderOnly = true,
            deferMetrics = true,
            rows = rows,
            skipControls = true,
        })
    end

    if C_Timer and type(C_Timer.After) == "function" then
        C_Timer.After(0.05, flush)
    else
        flush()
    end
end

function GoldTracker:RefreshCraftingFarmingWindowControls()
    local frame = self.craftingFarmingFrame
    if not frame then
        return
    end

    local source = self.VALUE_SOURCE_BY_ID[frame.valueSourceID] or self:GetCraftingFarmingValueSource()
    frame.valueSourceID = source and source.id
    if frame.valueSourceDropdown and source then
        UIDropDownMenu_SetSelectedValue(frame.valueSourceDropdown, source.id)
        UIDropDownMenu_SetText(frame.valueSourceDropdown, source.label)
    end

    frame.expansionID = NormalizeExpansionID(frame.expansionID)
    local expansionOption = GetExpansionLookup()[frame.expansionID]
    if frame.expansionDropdown and expansionOption then
        UIDropDownMenu_SetSelectedValue(frame.expansionDropdown, expansionOption.id)
        UIDropDownMenu_SetText(frame.expansionDropdown, expansionOption.label)
    end

    local professionIDs, orderedProfessionIDs = NormalizeProfessionSelections(frame.professionIDs, frame.professionID)
    frame.professionIDs = professionIDs
    frame.professionID = orderedProfessionIDs[1] or NormalizeProfessionID(nil)
    if frame.professionDropdown then
        RefreshProfessionDropdownMenu(frame)
    end
end

function GoldTracker:UpdateCraftingFarmingSortHeaderState(targetFrame)
    local frame = targetFrame or self.craftingFarmingFrame
    if not frame then
        return
    end

    local criteria = self:GetTableSortCriteria(frame, "sortKey", "sortAscending", MATERIALS_SORT_KEYS)
    local showPriority = #criteria > 1
    local headers = {
        expansion = { button = frame.expansionHeaderButton, label = "Expansion" },
        profession = { button = frame.professionHeaderButton, label = "Profession" },
        tag = { button = frame.tagHeaderButton, label = "Type" },
        itemName = { button = frame.itemHeaderButton, label = "Item" },
        dropRate = { button = frame.dropRateHeaderButton, label = "Drop/h" },
        goldRate = { button = frame.goldRateHeaderButton, label = "Gold/h" },
        demand = { button = frame.demandHeaderButton, label = "Sold/day" },
        sellRate = { button = frame.sellRateHeaderButton, label = "Sale %" },
        marketTrend = { button = frame.trendHeaderButton, label = "Trend" },
        value = { button = frame.valueHeaderButton, label = "Value" },
        componentCost = { button = frame.componentCostHeaderButton, label = "Mat cost" },
        profit = { button = frame.profitHeaderButton, label = "Margin" },
    }

    for headerSortKey, header in pairs(headers) do
        local button = header.button
        if button and button.text then
            self:AttachTableSortHeaderTooltip(button, header.label)
            local criterion, priority = self:GetTableSortCriterion(criteria, headerSortKey)
            button.text:SetText(showPriority and criterion and (header.label .. " " .. priority) or header.label)
            if criterion then
                button.text:SetTextColor(1, 1, 1)
                if button.sortIcon then
                    Theme:SetTexture(button.sortIcon, criterion.ascending and "sortAscending" or "sortDescending")
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

function GoldTracker:ToggleCraftingFarmingSort(sortKey)
    local frame = self.craftingFarmingFrame
    if not frame or not MATERIALS_SORT_KEYS[sortKey] then
        return
    end

    self:ToggleTableSortCriterion(frame, sortKey, sortKey ~= "value", {
        validKeys = MATERIALS_SORT_KEYS,
    })

    self:RefreshCraftingFarmingWindow(true)
end

local function GetMaterialsTableAvailableWidth(frame)
    local width = 0
    if frame and frame.scrollFrame then
        width = tonumber(frame.scrollFrame:GetWidth()) or 0
    end
    if width <= 1 and frame and frame.listPanel then
        width = (tonumber(frame.listPanel:GetWidth()) or 0) - 38
    end
    return math.max(1, width - 6)
end

local function SetMaterialsHeaderColumn(button, listPanel, leftOffset, width)
    if not button or not listPanel then
        return
    end
    button:ClearAllPoints()
    button:SetPoint("TOPLEFT", listPanel, "TOPLEFT", leftOffset, -12)
    button:SetWidth(math.max(1, width))
end

local function SetMaterialsRowColumn(fontString, row, leftOffset, width)
    if not fontString or not row then
        return
    end
    fontString:ClearAllPoints()
    fontString:SetPoint("LEFT", row, "LEFT", leftOffset, 0)
    fontString:SetWidth(math.max(1, width))
end

local function SetMaterialsRowButton(button, row, leftOffset, width)
    if not button or not row then
        return
    end
    button:ClearAllPoints()
    button:SetPoint("LEFT", row, "LEFT", leftOffset, 0)
    button:SetWidth(math.max(1, width))
end

local function GetMaterialsHorizontalOffset(frame)
    return math.max(0, math.floor(tonumber(frame and frame.horizontalScrollOffset) or 0))
end

local function UpdateMaterialsHorizontalScroll(frame)
    if not frame then
        return
    end

    local maxOffset = math.max(0, math.floor((tonumber(frame.tableWidth) or 0) - GetMaterialsTableAvailableWidth(frame)))
    local offset = math.min(GetMaterialsHorizontalOffset(frame), maxOffset)
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

local function ApplyMaterialsTableColumnLayout(frame)
    if not frame then
        return
    end

    local availableWidth = GetMaterialsTableAvailableWidth(frame)
    local favoriteX = 8
    local mapX = favoriteX + MATERIALS_FAVORITE_WIDTH + MATERIALS_COLUMN_GAP
    local addX = mapX + MATERIALS_MAP_BUTTON_WIDTH + MATERIALS_COLUMN_GAP
    local toggleX = addX + MATERIALS_ADD_BUTTON_WIDTH + MATERIALS_COLUMN_GAP
    local iconX = toggleX + MATERIALS_TOGGLE_WIDTH
    local itemX = iconX + MATERIALS_ICON_SIZE + 8
    local requiredItemWidth = Theme:GetRequiredTextColumnWidth(
        frame.rows,
        "itemText",
        MATERIALS_ITEM_MIN_WIDTH,
        {
            padding = 10,
            getLeadingWidth = function(row)
                return row.rowType == "component" and 18 or 0
            end,
        }
    )
    local minimumTableWidth =
        favoriteX
        + MATERIALS_FAVORITE_WIDTH
        + MATERIALS_TOGGLE_WIDTH
        + MATERIALS_ICON_SIZE
        + 8
        + requiredItemWidth
        + MATERIALS_EXPANSION_WIDTH
        + MATERIALS_PROFESSION_WIDTH
        + MATERIALS_TAG_WIDTH
        + MATERIALS_DROP_RATE_WIDTH
        + MATERIALS_GOLD_RATE_WIDTH
        + MATERIALS_DEMAND_WIDTH
        + MATERIALS_SELL_RATE_WIDTH
        + MATERIALS_TREND_WIDTH
        + MATERIALS_VALUE_WIDTH
        + MATERIALS_COMPONENT_COST_WIDTH
        + MATERIALS_MARGIN_WIDTH
        + MATERIALS_MAP_BUTTON_WIDTH
        + MATERIALS_ADD_BUTTON_WIDTH
        + (MATERIALS_COLUMN_GAP * 15)
        + MATERIALS_ROW_RIGHT_PADDING
    local tableWidth = math.max(availableWidth, minimumTableWidth)
    if frame.content then
        frame.content:SetWidth(tableWidth)
    end
    frame.tableWidth = tableWidth
    UpdateMaterialsHorizontalScroll(frame)

    local horizontalOffset = GetMaterialsHorizontalOffset(frame)
    local rightEdge = tableWidth - MATERIALS_ROW_RIGHT_PADDING
    local expansionX = rightEdge - MATERIALS_EXPANSION_WIDTH
    local professionX = expansionX - MATERIALS_COLUMN_GAP - MATERIALS_PROFESSION_WIDTH
    local trendX = professionX - MATERIALS_COLUMN_GAP - MATERIALS_TREND_WIDTH
    local sellRateX = trendX - MATERIALS_COLUMN_GAP - MATERIALS_SELL_RATE_WIDTH
    local profitX = sellRateX - MATERIALS_COLUMN_GAP - MATERIALS_MARGIN_WIDTH
    local componentCostX = profitX - MATERIALS_COLUMN_GAP - MATERIALS_COMPONENT_COST_WIDTH
    local demandX = componentCostX - MATERIALS_COLUMN_GAP - MATERIALS_DEMAND_WIDTH
    local goldRateX = demandX - MATERIALS_COLUMN_GAP - MATERIALS_GOLD_RATE_WIDTH
    local dropRateX = goldRateX - MATERIALS_COLUMN_GAP - MATERIALS_DROP_RATE_WIDTH
    local valueX = dropRateX - MATERIALS_COLUMN_GAP - MATERIALS_VALUE_WIDTH
    local tagX = valueX - MATERIALS_COLUMN_GAP - MATERIALS_TAG_WIDTH
    local itemWidth = math.max(requiredItemWidth, tagX - MATERIALS_COLUMN_GAP - itemX)

    if frame.listPanel then
        local headerX = MATERIALS_HEADER_LEFT_INSET
        SetMaterialsHeaderColumn(frame.favoriteHeaderButton, frame.listPanel, headerX + favoriteX - horizontalOffset, MATERIALS_FAVORITE_WIDTH)
        SetMaterialsHeaderColumn(frame.mapHeaderButton, frame.listPanel, headerX + mapX - horizontalOffset, MATERIALS_MAP_BUTTON_WIDTH)
        SetMaterialsHeaderColumn(frame.addHeaderButton, frame.listPanel, headerX + addX - horizontalOffset, MATERIALS_ADD_BUTTON_WIDTH)
        SetMaterialsHeaderColumn(frame.itemHeaderButton, frame.listPanel, headerX + itemX - horizontalOffset, itemWidth)
        SetMaterialsHeaderColumn(frame.tagHeaderButton, frame.listPanel, headerX + tagX - horizontalOffset, MATERIALS_TAG_WIDTH)
        SetMaterialsHeaderColumn(frame.valueHeaderButton, frame.listPanel, headerX + valueX - horizontalOffset, MATERIALS_VALUE_WIDTH)
        SetMaterialsHeaderColumn(frame.componentCostHeaderButton, frame.listPanel, headerX + componentCostX - horizontalOffset, MATERIALS_COMPONENT_COST_WIDTH)
        SetMaterialsHeaderColumn(frame.profitHeaderButton, frame.listPanel, headerX + profitX - horizontalOffset, MATERIALS_MARGIN_WIDTH)
        SetMaterialsHeaderColumn(frame.dropRateHeaderButton, frame.listPanel, headerX + dropRateX - horizontalOffset, MATERIALS_DROP_RATE_WIDTH)
        SetMaterialsHeaderColumn(frame.goldRateHeaderButton, frame.listPanel, headerX + goldRateX - horizontalOffset, MATERIALS_GOLD_RATE_WIDTH)
        SetMaterialsHeaderColumn(frame.demandHeaderButton, frame.listPanel, headerX + demandX - horizontalOffset, MATERIALS_DEMAND_WIDTH)
        SetMaterialsHeaderColumn(frame.sellRateHeaderButton, frame.listPanel, headerX + sellRateX - horizontalOffset, MATERIALS_SELL_RATE_WIDTH)
        SetMaterialsHeaderColumn(frame.trendHeaderButton, frame.listPanel, headerX + trendX - horizontalOffset, MATERIALS_TREND_WIDTH)
        SetMaterialsHeaderColumn(frame.professionHeaderButton, frame.listPanel, headerX + professionX - horizontalOffset, MATERIALS_PROFESSION_WIDTH)
        SetMaterialsHeaderColumn(frame.expansionHeaderButton, frame.listPanel, headerX + expansionX - horizontalOffset, MATERIALS_EXPANSION_WIDTH)
    end

    for _, row in ipairs(frame.rows or {}) do
        local rowIndent = row.rowType == "component" and 18 or 0
        if row.favoriteButton then
            row.favoriteButton:ClearAllPoints()
            row.favoriteButton:SetPoint(
                "LEFT",
                row,
                "LEFT",
                favoriteX + math.floor((MATERIALS_FAVORITE_WIDTH - MATERIALS_FAVORITE_BUTTON_WIDTH) / 2) - horizontalOffset,
                0
            )
            row.favoriteButton:SetSize(MATERIALS_FAVORITE_BUTTON_WIDTH, MATERIALS_FAVORITE_BUTTON_HEIGHT)
        end
        if row.toggleText then
            row.toggleText:ClearAllPoints()
            row.toggleText:SetPoint("LEFT", row, "LEFT", toggleX + rowIndent - horizontalOffset, 0)
            row.toggleText:SetWidth(MATERIALS_TOGGLE_WIDTH)
        end
        SetMaterialsRowButton(row.mapButton, row, mapX - horizontalOffset, MATERIALS_MAP_BUTTON_WIDTH)
        SetMaterialsRowButton(row.addButton, row, addX - horizontalOffset, MATERIALS_ADD_BUTTON_WIDTH)
        if row.icon then
            row.icon:ClearAllPoints()
            row.icon:SetPoint("LEFT", row, "LEFT", iconX + rowIndent - horizontalOffset, 0)
        end
        SetMaterialsRowColumn(row.itemText, row, itemX + rowIndent - horizontalOffset, math.max(1, itemWidth - rowIndent))
        SetMaterialsRowColumn(row.tagText, row, tagX - horizontalOffset, MATERIALS_TAG_WIDTH)
        SetMaterialsRowColumn(row.valueText, row, valueX - horizontalOffset, MATERIALS_VALUE_WIDTH)
        SetMaterialsRowColumn(row.componentCostText, row, componentCostX - horizontalOffset, MATERIALS_COMPONENT_COST_WIDTH)
        SetMaterialsRowColumn(row.profitText, row, profitX - horizontalOffset, MATERIALS_MARGIN_WIDTH)
        SetMaterialsRowColumn(row.dropRateText, row, dropRateX - horizontalOffset, MATERIALS_DROP_RATE_WIDTH)
        SetMaterialsRowColumn(row.goldRateText, row, goldRateX - horizontalOffset, MATERIALS_GOLD_RATE_WIDTH)
        SetMaterialsRowColumn(row.demandText, row, demandX - horizontalOffset, MATERIALS_DEMAND_WIDTH)
        SetMaterialsRowColumn(row.sellRateText, row, sellRateX - horizontalOffset, MATERIALS_SELL_RATE_WIDTH)
        SetMaterialsRowColumn(row.trendText, row, trendX - horizontalOffset, MATERIALS_TREND_WIDTH)
        SetMaterialsRowColumn(row.professionText, row, professionX - horizontalOffset, MATERIALS_PROFESSION_WIDTH)
        SetMaterialsRowColumn(row.expansionText, row, expansionX - horizontalOffset, MATERIALS_EXPANSION_WIDTH)
    end
end

local function QueueMaterialsVisibleRowsRefresh(frame)
    if not frame or frame.materialsVisibleRowsRefreshQueued then
        return
    end
    frame.materialsVisibleRowsRefreshQueued = true

    local function flush()
        frame.materialsVisibleRowsRefreshQueued = false
        if frame.IsShown and not frame:IsShown() then
            return
        end
        local currentOffset = frame.scrollFrame and (tonumber(frame.scrollFrame:GetVerticalScroll()) or 0) or 0
        if math.abs(currentOffset - (tonumber(frame.materialsRenderedScrollOffset) or 0)) < 0.5 then
            return
        end
        GoldTracker:RefreshCraftingFarmingWindow(false, {
            renderOnly = true,
            deferMetrics = true,
            rows = frame.materialDisplayRows,
            skipControls = true,
            targetFrame = frame,
        })
    end

    if C_Timer and type(C_Timer.After) == "function" then
        C_Timer.After(0, flush)
    else
        flush()
    end
end

local function ScrollMaterialsResultsVertically(frame, delta)
    local scrollFrame = frame and frame.scrollFrame
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
    QueueMaterialsVisibleRowsRefresh(frame)
end

local function ScrollMaterialsResultsHorizontally(frame, delta)
    if not frame or not (type(IsShiftKeyDown) == "function" and IsShiftKeyDown()) then
        return false
    end

    local maxOffset = math.max(0, math.floor((tonumber(frame.tableWidth) or 0) - GetMaterialsTableAvailableWidth(frame)))
    if maxOffset <= 0 then
        return false
    end

    local currentOffset = math.min(GetMaterialsHorizontalOffset(frame), maxOffset)
    local step = math.max(20, math.floor(GetMaterialsTableAvailableWidth(frame) * 0.10))
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
            ApplyMaterialsTableColumnLayout(frame)
        end
    end
    return true
end

local function HandleMaterialsResultsMouseWheel(frame, delta)
    if ScrollMaterialsResultsHorizontally(frame, delta) then
        return
    end
    ScrollMaterialsResultsVertically(frame, delta)
end

local function BindMaterialsResultsMouseWheel(frameObject, frame)
    if not frameObject or not frameObject.EnableMouseWheel then
        return
    end
    frameObject:EnableMouseWheel(true)
    frameObject:SetScript("OnMouseWheel", function(_, delta)
        HandleMaterialsResultsMouseWheel(frame, delta)
    end)
end

function GoldTracker:GetCraftingFarmingWindowRow(index, targetFrame)
    local frame = targetFrame or self.craftingFarmingFrame
    if not frame or not frame.content then
        return nil
    end

    frame.rows = frame.rows or {}
    local row = frame.rows[index]
    if row then
        SetMaterialsFrameLevel(row, frame.content, 1)
        return row
    end

    row = CreateFrame("Button", nil, frame.content)
    SetMaterialsFrameLevel(row, frame.content, 1)
    row:EnableMouse(true)
    BindMaterialsResultsMouseWheel(row, frame)
    row:RegisterForClicks("LeftButtonUp")
    row:SetHeight(MATERIALS_ROW_HEIGHT)

    local background = row:CreateTexture(nil, "BACKGROUND")
    background:SetAllPoints(row)
    row.background = background

    local hover = row:CreateTexture(nil, "HIGHLIGHT")
    hover:SetAllPoints(row)
    hover:SetColorTexture(1, 0.82, 0.18, 0.08)
    row.hover = hover

    local favoriteButton = CreateMaterialsButton(row, MATERIALS_FAVORITE_BUTTON_WIDTH, MATERIALS_FAVORITE_BUTTON_HEIGHT, "<3", "neutral")
    BindMaterialsResultsMouseWheel(favoriteButton, frame)
    favoriteButton:RegisterForClicks("LeftButtonUp")
    favoriteButton:SetScript("OnClick", function(self)
        GoldTracker:ToggleCraftingFarmingFavorite(self:GetParent())
    end)
    favoriteButton:SetScript("OnEnter", function(self)
        if self.theme and self.theme.UpdateButtonVisual then
            self.isHovered = true
            self.theme:UpdateButtonVisual(self)
        end
        GameTooltip:SetOwner(self, "ANCHOR_CURSOR")
        GameTooltip:AddLine(self:GetParent().favorite and "Remove tracked material" or "Track material", 1, 1, 1)
        GameTooltip:Show()
    end)
    favoriteButton:SetScript("OnLeave", function(self)
        if self.theme and self.theme.UpdateButtonVisual then
            self.isHovered = false
            self.isPressed = false
            self.theme:UpdateButtonVisual(self)
        end
        GameTooltip:Hide()
    end)
    row.favoriteButton = favoriteButton

    local toggleText = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    toggleText:SetJustifyH("CENTER")
    toggleText:SetWordWrap(false)
    row.toggleText = toggleText

    local icon = row:CreateTexture(nil, "ARTWORK")
    icon:SetSize(MATERIALS_ICON_SIZE, MATERIALS_ICON_SIZE)
    row.icon = icon

    local itemText = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    itemText:SetJustifyH("LEFT")
    itemText:SetWordWrap(false)
    row.itemText = itemText

    local expansionText = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    expansionText:SetJustifyH("LEFT")
    expansionText:SetWordWrap(false)
    row.expansionText = expansionText

    local professionText = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    professionText:SetJustifyH("LEFT")
    professionText:SetWordWrap(false)
    row.professionText = professionText

    local tagText = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    tagText:SetJustifyH("LEFT")
    tagText:SetWordWrap(false)
    row.tagText = tagText

    local dropRateText = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    dropRateText:SetJustifyH("RIGHT")
    dropRateText:SetWordWrap(false)
    row.dropRateText = dropRateText

    local goldRateText = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    goldRateText:SetJustifyH("RIGHT")
    goldRateText:SetWordWrap(false)
    row.goldRateText = goldRateText

    local demandText = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    demandText:SetJustifyH("RIGHT")
    demandText:SetWordWrap(false)
    row.demandText = demandText

    local sellRateText = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    sellRateText:SetJustifyH("RIGHT")
    sellRateText:SetWordWrap(false)
    row.sellRateText = sellRateText

    local trendText = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    trendText:SetJustifyH("RIGHT")
    trendText:SetWordWrap(false)
    row.trendText = trendText

    local valueText = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    valueText:SetJustifyH("RIGHT")
    valueText:SetWordWrap(false)
    row.valueText = valueText

    local componentCostText = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    componentCostText:SetJustifyH("RIGHT")
    componentCostText:SetWordWrap(false)
    row.componentCostText = componentCostText

    local profitText = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    profitText:SetJustifyH("RIGHT")
    profitText:SetWordWrap(false)
    row.profitText = profitText

    local mapButton = CreateMaterialsButton(row, MATERIALS_MAP_BUTTON_WIDTH, 18, "Map", "neutral")
    BindMaterialsResultsMouseWheel(mapButton, frame)
    mapButton:SetScript("OnClick", function(self)
        GoldTracker:OpenMaterialFarmingMap(self:GetParent().itemID)
    end)
    mapButton:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_CURSOR")
        if self:GetParent().hasFarmingMap or self:GetParent().hasFarm then
            GameTooltip:AddLine("Open farming map", 1, 1, 1)
            GameTooltip:AddLine("Shows map locations and any available farm routes.", 0.72, 0.86, 1.0)
        else
            GameTooltip:AddLine("No map data yet", 1, 1, 1)
            GameTooltip:AddLine("This material does not have researched coordinate-backed spots yet.", 0.72, 0.86, 1.0)
        end
        GameTooltip:Show()
    end)
    mapButton:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)
    row.mapButton = mapButton

    local addButton = CreateMaterialsButton(row, MATERIALS_ADD_BUTTON_WIDTH, 18, "Add", "neutral")
    BindMaterialsResultsMouseWheel(addButton, frame)
    GoldTracker:ConfigureCustomFarmAddButton(addButton, "materials")
    row.addButton = addButton

    local divider = row:CreateTexture(nil, "ARTWORK")
    divider:SetColorTexture(1, 1, 1, 0.045)
    divider:SetPoint("BOTTOMLEFT", row, "BOTTOMLEFT", 0, 0)
    divider:SetPoint("BOTTOMRIGHT", row, "BOTTOMRIGHT", 0, 0)
    divider:SetHeight(1)
    row.divider = divider

    local itemTooltipTarget = self:CreateItemTooltipTarget(row, itemText, icon, function(self, target)
        if self.rowType == "divider" then
            return
        end
        local itemID = tonumber(self.itemID)
        if (type(self.itemLink) ~= "string" or self.itemLink == "") and not itemID then
            return
        end
        GameTooltip:SetOwner(target, "ANCHOR_CURSOR")
        if type(self.itemLink) == "string" and self.itemLink ~= "" then
            GameTooltip:SetHyperlink(self.itemLink)
        elseif type(GameTooltip.SetItemByID) == "function" then
            GameTooltip:SetItemByID(itemID)
        else
            GameTooltip:SetHyperlink("item:" .. tostring(math.floor(itemID + 0.5)))
        end
        GameTooltip:AddLine(" ")
        GameTooltip:AddDoubleLine("Expansion", self.expansionLabel or "Unknown", 0.72, 0.86, 1.0, 1, 1, 1)
        GameTooltip:AddDoubleLine("Profession", self.professionLabel or "Unknown", 0.72, 0.86, 1.0, 1, 1, 1)
        if self.materialLearnedFromSession then
            GameTooltip:AddDoubleLine("Material source", "Learned from session", 0.72, 0.86, 1.0, 1, 1, 1)
        elseif self.materialManualProfessionOverride then
            GameTooltip:AddDoubleLine("Material source", "Manual profession override", 0.72, 0.86, 1.0, 1, 1, 1)
        end
        GameTooltip:AddDoubleLine("Value source", self.valueSourceLabel or "Unknown", 0.72, 0.86, 1.0, 1, 1, 1)
        GameTooltip:AddLine(" ")
        GameTooltip:AddLine("TSM regional demand", 1.0, 0.82, 0.18)
        local regionSaleRateText = FormatMaterialsDecimalValue(self.regionSaleRate, 3)
        if regionSaleRateText then
            regionSaleRateText = regionSaleRateText .. " (" .. FormatMaterialsSaleRate(self.regionSaleRate) .. ")"
        end
        GameTooltip:AddDoubleLine(
            "DBRegionSoldPerDay",
            FormatMaterialsDecimalValue(self.regionSoldPerDay, 2) or "Unknown",
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
        local sellRateLabel = GetMaterialsSellRateTier(self.regionSaleRate)
        GameTooltip:AddDoubleLine("Sell rate", sellRateLabel ~= "--" and sellRateLabel or "Unknown",
            0.72, 0.86, 1.0, 1, 1, 1)
        GameTooltip:AddLine(" ")
        GameTooltip:AddLine("TSM market trend", 1.0, 0.82, 0.18)
        GameTooltip:AddDoubleLine(
            "Market trend",
            FormatMaterialsTrendPercent(self.marketTrendPercent),
            0.72, 0.86, 1.0,
            GetMaterialsTrendColor(self.marketTrendPercent)
        )
        GameTooltip:AddDoubleLine(
            "Market value",
            self.marketValue and GoldTracker:FormatMoney(self.marketValue) or "Unknown",
            0.72, 0.86, 1.0,
            1, 1, 1
        )
        GameTooltip:AddDoubleLine(
            "Historical value",
            self.historicalValue and GoldTracker:FormatMoney(self.historicalValue) or "Unknown",
            0.72, 0.86, 1.0,
            1, 1, 1
        )
        if (tonumber(self.dropPerHour) or 0) > 0 then
            GameTooltip:AddDoubleLine("Drop/hour", FormatMaterialsDropRate(self.dropPerHour), 0.72, 0.86, 1.0, 1, 1, 1)
            GameTooltip:AddDoubleLine(
                "Gold/hour",
                GoldTracker:FormatMoney(self.goldPerHour or 0),
                0.72, 0.86, 1.0,
                1, 1, 1
            )
            GameTooltip:AddDoubleLine("Observed quantity", tostring(math.floor((tonumber(self.dropQuantity) or 0) + 0.5)), 0.72, 0.86, 1.0, 1, 1, 1)
            GameTooltip:AddDoubleLine("Observed sessions", tostring(math.floor((tonumber(self.dropSessionCount) or 0) + 0.5)), 0.72, 0.86, 1.0, 1, 1, 1)
        end
        if self.rowType == "component" then
            GameTooltip:AddDoubleLine("Required", tostring(self.componentQuantity or 0), 0.72, 0.86, 1.0, 1, 1, 1)
            GameTooltip:AddDoubleLine("Required value", GoldTracker:FormatMoney(self.componentCost or 0), 0.72, 0.86, 1.0, 1, 1, 1)
            if self.isComposedMaterial then
                GameTooltip:AddLine("Click to expand or collapse this component's recipe.", 0.72, 0.86, 1.0)
            end
        elseif self.isComposedMaterial then
            GameTooltip:AddDoubleLine("Output", tostring(self.outputQuantity or 1), 0.72, 0.86, 1.0, 1, 1, 1)
            if self.componentsLoaded then
                GameTooltip:AddDoubleLine("Material cost", GoldTracker:FormatMoney(self.componentCost or 0), 0.72, 0.86, 1.0, 1, 1, 1)
                GameTooltip:AddDoubleLine("Margin", FormatMaterialsSignedMoney(GoldTracker, self.profitValue or 0), 0.72, 0.86, 1.0, 1, 1, 1)
            else
                GameTooltip:AddLine("Component prices load when this recipe is expanded.", 0.72, 0.86, 1.0)
            end
            GameTooltip:AddLine("Click to expand or collapse components.", 0.72, 0.86, 1.0)
        end
        if self.recipeSourceLabel then
            GameTooltip:AddDoubleLine("Recipe", self.recipeSourceLabel, 0.72, 0.86, 1.0, 1, 1, 1)
        end
        GameTooltip:AddLine(" ")
        if not self.isComposedMaterial then
            GameTooltip:AddLine("Left-click for market details. Modified-click to link the item.", 0.72, 0.86, 1.0)
        end
        if type(GoldTracker.AddFarmActionTooltip) == "function" then
            GoldTracker:AddFarmActionTooltip(GameTooltip, self)
        end
        GameTooltip:Show()
    end)
    BindMaterialsResultsMouseWheel(itemTooltipTarget, frame)
    row:SetScript("OnClick", function(self, button)
        if self.rowType == "divider" then
            if self.dividerKind == "composedMaterials" then
                local primaryFrame = GoldTracker.craftingFarmingFrame
                primaryFrame.composedMaterialsExpanded = not primaryFrame.composedMaterialsExpanded
                GoldTracker:RefreshCraftingFarmingWindow(false)
            end
            return
        end
        if type(GoldTracker.HandleFarmActionClick) == "function" and GoldTracker:HandleFarmActionClick(self, button) then
            return
        end
        if GoldTracker:HandleModifiedItemClickIfModified(self) then
            return
        end
        if self.isComposedMaterial then
            local store = GetComposedMaterialExpandedStore(GoldTracker.craftingFarmingFrame)
            GetComposedMaterialLoadedStore(GoldTracker.craftingFarmingFrame)[self.itemID] = true
            store[self.itemID] = not store[self.itemID]
            GoldTracker:RefreshCraftingFarmingWindow(false)
            return
        end
        GoldTracker:OpenInventoryItemDetailsWindow(self)
    end)

    frame.rows[index] = row
    return row
end

function GoldTracker:RefreshCraftingFarmingWindowLayout(targetFrame)
    local frame = targetFrame or self.craftingFarmingFrame
    if not frame or not frame.scrollFrame or not frame.content then
        return
    end

    ApplyMaterialsTableColumnLayout(frame)
    if frame.scrollFrame.UpdateScrollChildRect then
        frame.scrollFrame:UpdateScrollChildRect()
    end
end

local function SyncMaterialsResultsFrame(sourceFrame, targetFrame)
    if not sourceFrame or not targetFrame then
        return
    end

    targetFrame.valueSourceID = sourceFrame.valueSourceID
    targetFrame.sortKey = sourceFrame.sortKey
    targetFrame.sortAscending = sourceFrame.sortAscending
    targetFrame.sortCriteria = sourceFrame.sortCriteria
    targetFrame.lastMaterialsImportSummary = sourceFrame.lastMaterialsImportSummary
    targetFrame.dropRateUpdatedAt = sourceFrame.dropRateUpdatedAt
    targetFrame.materialsRealtimeLoading = sourceFrame.materialsRealtimeLoading
    targetFrame.materialsRealtimeLoaded = sourceFrame.materialsRealtimeLoaded
    targetFrame.materialsRealtimeTotal = sourceFrame.materialsRealtimeTotal

    if targetFrame.filterText then
        local expansionLabel = GetOptionLabel(
            GetExpansionLookup(),
            NormalizeExpansionID(sourceFrame.expansionID),
            "All expansions"
        )
        local professionLabel = GetProfessionSelectionText(sourceFrame.professionIDs)
        local text = string.format("%s | %s", expansionLabel, professionLabel)
        local searchText = NormalizeMaterialsSearchText(sourceFrame.searchText)
        if searchText ~= "" then
            text = text .. " | Search: " .. searchText
        end
        targetFrame.filterText:SetText(text)
    end
end

local function GetMaterialsRealtimeWorkQueue(rows)
    local queue = {}
    local seen = {}
    local function addItem(itemID)
        itemID = tonumber(itemID)
        if itemID then
            itemID = math.floor(itemID + 0.5)
            if not seen[itemID] then
                seen[itemID] = true
                queue[#queue + 1] = itemID
            end
        end
    end
    for _, row in ipairs(rows or {}) do
        addItem(row and row.itemID)
        if row and row.componentsLoaded then
            for _, component in ipairs(row.components or {}) do
                addItem(component and component.itemID)
            end
        end
    end
    return queue
end

local function StartMaterialsRealtimeRefresh(addon, scrollToTop, options)
    local frame = addon.craftingFarmingFrame
    if not frame then
        return
    end

    frame.materialsRefreshGeneration = (tonumber(frame.materialsRefreshGeneration) or 0) + 1
    local generation = frame.materialsRefreshGeneration

    -- These stores belong only to this refresh generation. No market value survives
    -- a filter, sort, search, source, or explicit refresh action.
    frame.itemCache = {}
    frame.materialsDemandCache = {}
    frame.searchItemDataRequested = {}

    local source = addon.VALUE_SOURCE_BY_ID[frame.valueSourceID] or addon:GetCraftingFarmingValueSource()
    local placeholderRows = addon:BuildCraftingFarmingRows({ deferMetrics = true })
    local queue = GetMaterialsRealtimeWorkQueue(placeholderRows)
    local queuedItemIDs = {}
    for _, itemID in ipairs(queue) do
        queuedItemIDs[itemID] = true
    end
    frame.materialsRealtimeLoading = #queue > 0
    frame.materialsRealtimeLoaded = 0
    frame.materialsRealtimeTotal = #queue

    addon:RefreshCraftingFarmingWindow(scrollToTop, {
        renderOnly = true,
        deferMetrics = true,
        rows = placeholderRows,
    })

    if #queue == 0 then
        frame.materialsRealtimeLoading = false
        return
    end

    local queueIndex = 1
    local function processBatch()
        local currentFrame = addon.craftingFarmingFrame
        if not currentFrame or currentFrame.materialsRefreshGeneration ~= generation then
            return
        end
        local expandedFrame = addon.craftingFarmingExpandedFrame
        local expandedShown = expandedFrame and expandedFrame.IsShown and expandedFrame:IsShown()
        if currentFrame.IsShown and not currentFrame:IsShown() and not expandedShown then
            currentFrame.materialsRealtimeLoading = false
            return
        end

        local batchStart = type(debugprofilestop) == "function" and debugprofilestop() or nil
        local processed = 0
        while queueIndex <= #queue do
            LoadMaterialsItemMetrics(addon, currentFrame, source, queue[queueIndex])
            queueIndex = queueIndex + 1
            processed = processed + 1
            currentFrame.materialsRealtimeLoaded = queueIndex - 1

            if batchStart then
                if (debugprofilestop() - batchStart) >= MATERIALS_REALTIME_FRAME_BUDGET_MS then
                    break
                end
            elseif processed >= MATERIALS_REALTIME_FALLBACK_BATCH_SIZE then
                break
            end
        end

        if queueIndex <= #queue then
            if currentFrame.metaText then
                currentFrame.metaText:SetText(string.format(
                    "Loading fresh prices %d/%d...",
                    currentFrame.materialsRealtimeLoaded,
                    currentFrame.materialsRealtimeTotal
                ))
            end
            C_Timer.After(0, processBatch)
            return
        end

        local finalRows = addon:BuildCraftingFarmingRows({ deferMetrics = true })
        local addedWork = false
        for _, row in ipairs(finalRows) do
            local itemID = tonumber(row and row.itemID)
            if itemID then
                itemID = math.floor(itemID + 0.5)
                local cacheKey = tostring(itemID) .. "|" .. tostring(source and source.id or "")
                local cache = currentFrame.itemCache and currentFrame.itemCache[cacheKey]
                if not queuedItemIDs[itemID] and not (cache and cache.metricsLoaded == true) then
                    queuedItemIDs[itemID] = true
                    queue[#queue + 1] = itemID
                    addedWork = true
                end
            end
        end
        if addedWork then
            currentFrame.materialsRealtimeTotal = #queue
            C_Timer.After(0, processBatch)
            return
        end

        currentFrame.materialsRealtimeLoading = false
        addon:RefreshCraftingFarmingWindow(false, {
            renderOnly = true,
            deferMetrics = true,
            rows = finalRows,
            recordSnapshots = options and options.recordSnapshots == true,
        })
    end

    C_Timer.After(0, processBatch)
end

function GoldTracker:RefreshCraftingFarmingWindow(scrollToTop, options)
    options = type(options) == "table" and options or {}
    local primaryFrame = self.craftingFarmingFrame
    local frame = options.targetFrame or primaryFrame
    if not frame or not frame.content then
        return
    end

    if options.renderOnly ~= true
        and options.synchronous ~= true
        and C_Timer
        and type(C_Timer.After) == "function" then
        StartMaterialsRealtimeRefresh(self, scrollToTop, options)
        return
    end

    if options.skipControls ~= true then
        self:RefreshCraftingFarmingWindowControls()
        self:UpdateCraftingFarmingSortHeaderState()
    end

    local rows = type(options.rows) == "table"
        and options.rows
        or self:BuildCraftingFarmingRows({ deferMetrics = options.deferMetrics == true })
    frame.materialDisplayRows = rows
    if options.recordSnapshots == true and type(self.RecordCraftingFarmingMarketSnapshots) == "function" then
        local snapshotRows = {}
        local seenSnapshotItems = {}
        for _, row in ipairs(rows) do
            local itemID = tonumber(row and row.itemID)
            if itemID and not seenSnapshotItems[itemID] then
                seenSnapshotItems[itemID] = true
                snapshotRows[#snapshotRows + 1] = row
            end
        end
        self:RecordCraftingFarmingMarketSnapshots(snapshotRows)
    end
    if scrollToTop and frame.scrollFrame then
        frame.scrollFrame:SetVerticalScroll(0)
    end

    local rowOffsets = {}
    local contentHeight = 0
    local totalValue = 0
    local materialCount = 0
    for index, result in ipairs(rows) do
        rowOffsets[index] = contentHeight
        contentHeight = contentHeight
            + (result.rowType == "divider" and (MATERIALS_ROW_HEIGHT + 4) or MATERIALS_ROW_HEIGHT)
        if index < #rows then
            contentHeight = contentHeight + MATERIALS_ROW_SPACING
        end
        if result.itemID and result.rowType ~= "component" then
            totalValue = totalValue + math.max(0, tonumber(result.value) or 0)
        end
        if result.itemID then
            materialCount = materialCount + 1
        end
    end
    frame.materialDisplayRowOffsets = rowOffsets

    local scrollOffset = frame.scrollFrame and (tonumber(frame.scrollFrame:GetVerticalScroll()) or 0) or 0
    frame.materialsRenderedScrollOffset = scrollOffset
    local viewportHeight = frame.scrollFrame and math.max(1, tonumber(frame.scrollFrame:GetHeight()) or 1) or 600
    local firstVisibleIndex = 1
    while firstVisibleIndex <= #rows do
        local result = rows[firstVisibleIndex]
        local resultHeight = result.rowType == "divider" and (MATERIALS_ROW_HEIGHT + 4) or MATERIALS_ROW_HEIGHT
        if (rowOffsets[firstVisibleIndex] + resultHeight) >= scrollOffset then
            break
        end
        firstVisibleIndex = firstVisibleIndex + 1
    end
    firstVisibleIndex = math.max(1, firstVisibleIndex - 1)

    local lastVisibleIndex = firstVisibleIndex - 1
    while lastVisibleIndex < #rows do
        local nextIndex = lastVisibleIndex + 1
        if nextIndex > firstVisibleIndex and (rowOffsets[nextIndex] or 0) > (scrollOffset + viewportHeight + MATERIALS_ROW_HEIGHT) then
            break
        end
        lastVisibleIndex = nextIndex
    end

    local poolIndex = 0

    for index = firstVisibleIndex, lastVisibleIndex do
        local result = rows[index]
        poolIndex = poolIndex + 1
        local row = self:GetCraftingFarmingWindowRow(poolIndex, frame)
        if row then
            row.rowType = result.rowType
            row.dividerKind = result.dividerKind
            row.itemID = result.itemID
            row.itemName = result.itemName
            row.itemLink = result.itemLink
            row.itemQuality = result.itemQuality
            row.iconTexture = result.icon
            row.parentItemID = result.parentItemID
            row.rootItemID = result.rootItemID
            row.componentDepth = result.componentDepth
            row.materialExpansionID = result.expansionID
            row.materialExpansionLabel = result.expansionLabel
            row.materialProfessionIDs = result.professionIDs
            row.materialProfessionLabel = result.professionLabel
            row.materialLearnedFromSession = result.learnedFromSession == true
            row.materialManualProfessionOverride = result.manualProfessionOverride == true
            row.expansionLabel = result.expansionLabel
            row.professionLabel = result.professionLabel
            row.tag = result.tag
            row.value = result.value
            row.unitValue = result.value
            row.totalValue = result.value
            row.quantity = 1
            row.componentQuantity = result.componentQuantity
            row.componentCost = result.componentCost
            row.craftValue = result.craftValue
            row.profitValue = result.profitValue
            row.outputQuantity = result.outputQuantity
            row.isComposedMaterial = result.isComposedMaterial == true
            row.componentsLoaded = result.componentsLoaded == true
            row.expanded = result.expanded == true
            row.recipeSpellID = result.recipeSpellID
            row.recipeSource = result.recipeSource
            row.recipeSourceLabel = result.recipeSourceLabel
            row.valueSourceID = result.valueSourceID
            row.valueSourceLabel = result.valueSourceLabel
            row.dropPerHour = result.dropPerHour
            row.goldPerHour = result.goldPerHour
            row.dropQuantity = result.dropQuantity
            row.dropDurationSeconds = result.dropDurationSeconds
            row.dropSessionCount = result.dropSessionCount
            row.regionSoldPerDay = result.regionSoldPerDay
            row.regionSaleRate = result.regionSaleRate
            row.marketValue = result.marketValue
            row.historicalValue = result.historicalValue
            row.marketTrendPercent = result.marketTrendPercent
            row.demandTier = result.demandTier
            row.demandLabel = result.demandLabel
            row.demandColorR = result.demandColorR
            row.demandColorG = result.demandColorG
            row.demandColorB = result.demandColorB
            row.hasFarmingMap = result.hasFarmingMap == true
            row.farmCount = math.max(0, math.floor(tonumber(result.farmCount) or 0))
            row.hasFarm = result.hasFarm == true or row.farmCount > 0
            row.favorite = result.rowType ~= "divider" and self:IsCraftingFarmingFavorite(result) or false

            if result.rowType == "divider" then
                if row.favoriteButton then
                    row.favoriteButton:Hide()
                end
                local dividerToggle = result.dividerKind == "composedMaterials"
                    and (result.expanded and "-" or "+")
                    or ""
                row.toggleText:SetText(dividerToggle)
                row.toggleText:SetTextColor(1.0, 0.82, 0.18)
                row.itemText:SetText(result.label or "Composed materials")
                row.expansionText:SetText("")
                row.professionText:SetText("")
                row.tagText:SetText("")
                row.dropRateText:SetText("")
                row.goldRateText:SetText("")
                row.demandText:SetText("")
                row.sellRateText:SetText("")
                row.trendText:SetText("")
                row.valueText:SetText("")
                row.componentCostText:SetText("")
                row.profitText:SetText("")
                if row.mapButton then
                    row.mapButton:Hide()
                end
                if row.addButton then
                    row.addButton:Hide()
                end
                row.itemText:SetTextColor(1.0, 0.82, 0.18)
                row.icon:Hide()
                row:SetHeight(MATERIALS_ROW_HEIGHT + 4)
                if row.background then
                    row.background:SetColorTexture(1, 0.82, 0.18, 0.08)
                end
            else
                if row.favoriteButton then
                    row.favoriteButton:SetText(row.favorite and "-" or "<3")
                    if row.favoriteButton.SetSelected then
                        row.favoriteButton:SetSelected(row.favorite)
                    end
                    row.favoriteButton:Show()
                end
                row.toggleText:SetText(result.isComposedMaterial and (result.expanded and "-" or "+") or "")
                row.toggleText:SetTextColor(1.0, 0.82, 0.18)
                if result.rowType == "component" then
                    local indent = string.rep("  ", math.max(1, tonumber(result.componentDepth) or 1))
                    row.itemText:SetText(string.format("%s%sx %s", indent, tostring(result.componentQuantity or 0), result.itemLink or result.itemName or ("Item " .. tostring(result.itemID))))
                else
                    row.itemText:SetText(result.itemLink or result.itemName or ("Item " .. tostring(result.itemID)))
                end
                row.expansionText:SetText(result.expansionLabel or "Unknown")
                row.professionText:SetText(result.professionLabel or "Unknown")
                row.tagText:SetText(result.tag or "Material")
                row.dropRateText:SetText(FormatMaterialsDropRate(result.dropPerHour))
                row.goldRateText:SetText(
                    result.goldPerHour and result.goldPerHour > 0 and self:FormatMoney(result.goldPerHour) or "--"
                )
                row.demandText:SetText(FormatMaterialsSoldPerDay(result.regionSoldPerDay))
                local sellRateLabel, sellRateR, sellRateG, sellRateB = GetMaterialsSellRateTier(result.regionSaleRate)
                row.sellRateText:SetText(FormatMaterialsSaleRate(result.regionSaleRate))
                row.trendText:SetText(FormatMaterialsTrendPercent(result.marketTrendPercent))
                row.valueText:SetText(result.value > 0 and self:FormatMoney(result.value) or "--")
                row.componentCostText:SetText(
                    result.componentCost and result.componentCost > 0 and self:FormatMoney(result.componentCost) or "--"
                )
                row.profitText:SetText(result.profitValue and FormatMaterialsSignedMoney(self, result.profitValue) or "--")
                row.valueText:SetTextColor(
                    result.value > 0 and 0.68 or 0.62,
                    result.value > 0 and 0.96 or 0.66,
                    result.value > 0 and 0.72 or 0.74
                )
                if result.profitValue then
                    row.profitText:SetTextColor(
                        result.profitValue >= 0 and 0.68 or 1.0,
                        result.profitValue >= 0 and 0.96 or 0.38,
                        result.profitValue >= 0 and 0.72 or 0.38
                    )
                else
                    row.profitText:SetTextColor(0.62, 0.66, 0.74)
                end
                row.componentCostText:SetTextColor(0.92, 0.95, 1.0)
                row.expansionText:SetTextColor(0.72, 0.76, 0.84)
                row.professionText:SetTextColor(0.72, 0.86, 1.0)
                row.tagText:SetTextColor(0.92, 0.95, 1.0)
                local hasDropRate = (tonumber(result.dropPerHour) or 0) > 0
                row.dropRateText:SetTextColor(
                    hasDropRate and 0.72 or 0.62,
                    hasDropRate and 0.86 or 0.66,
                    hasDropRate and 1.0 or 0.74
                )
                row.goldRateText:SetTextColor(
                    (tonumber(result.goldPerHour) or 0) > 0 and 1.0 or 0.62,
                    (tonumber(result.goldPerHour) or 0) > 0 and 0.82 or 0.66,
                    (tonumber(result.goldPerHour) or 0) > 0 and 0.18 or 0.74
                )
                row.demandText:SetTextColor(
                    result.demandColorR or 0.62,
                    result.demandColorG or 0.66,
                    result.demandColorB or 0.74
                )
                row.sellRateText:SetTextColor(sellRateR, sellRateG, sellRateB)
                row.trendText:SetTextColor(GetMaterialsTrendColor(result.marketTrendPercent))
                row.itemText:SetTextColor(result.rowType == "component" and 0.76 or 1.0, result.rowType == "component" and 0.82 or 1.0, 1.0)
                if row.mapButton then
                    row.mapButton:SetText("Map")
                    if row.mapButton.SetEnabled then
                        row.mapButton:SetEnabled(result.hasFarmingMap == true or result.hasFarm == true)
                    end
                    if row.mapButton.SetAlpha then
                    row.mapButton:SetAlpha((result.hasFarmingMap == true or result.hasFarm == true) and 1 or 0.42)
                    end
                    row.mapButton:Show()
                end
                if row.addButton then
                    row.addButton:Show()
                end
                if result.icon then
                    row.icon:SetTexture(result.icon)
                    row.icon:Show()
                else
                    row.icon:Hide()
                end
                row:SetHeight(MATERIALS_ROW_HEIGHT)
                if row.background then
                    local alpha = result.rowType == "component" and 0.032 or (index % 2 == 0 and 0.045 or 0.022)
                    row.background:SetColorTexture(1, 1, 1, alpha)
                end
            end

            if result.icon and result.rowType ~= "divider" then
                row.icon:SetTexture(result.icon)
                row.icon:Show()
            end
            if row.divider then
                row.divider:SetShown(index < #rows)
            end

            row:ClearAllPoints()
            row:SetPoint("TOPLEFT", frame.content, "TOPLEFT", 0, -(rowOffsets[index] or 0))
            row:SetPoint("TOPRIGHT", frame.content, "TOPRIGHT", 0, -(rowOffsets[index] or 0))
            row:Show()
        end
    end

    for index = (poolIndex + 1), #(frame.rows or {}) do
        if frame.rows[index] then
            frame.rows[index]:Hide()
        end
    end

    frame.content:SetHeight(math.max(1, contentHeight))
    if frame.emptyText then
        if #rows == 0 then
            frame.emptyText:SetText("No materials match the selected filters.")
            frame.emptyText:Show()
        else
            frame.emptyText:Hide()
        end
    end
    if frame.metaText then
        local source = self.VALUE_SOURCE_BY_ID[frame.valueSourceID] or self:GetCraftingFarmingValueSource()
        local text = string.format(
            "%d materials | %s | Total unit value %s",
            materialCount,
            source and source.label or "Unknown source",
            self:FormatMoney(totalValue)
        )
        if type(frame.lastMaterialsImportSummary) == "string" and frame.lastMaterialsImportSummary ~= "" then
            text = text .. " | " .. frame.lastMaterialsImportSummary
        elseif frame.dropRateUpdatedAt then
            text = text .. " | Drop/h refreshed"
        end
        if frame.materialsRealtimeLoading then
            text = text .. string.format(
                " | Loading fresh prices %d/%d",
                tonumber(frame.materialsRealtimeLoaded) or 0,
                tonumber(frame.materialsRealtimeTotal) or 0
            )
        end
        frame.metaText:SetText(text)
    end

    self:RefreshCraftingFarmingWindowLayout(frame)

    local expandedFrame = self.craftingFarmingExpandedFrame
    if frame == primaryFrame
        and expandedFrame
        and expandedFrame.IsShown
        and expandedFrame:IsShown() then
        SyncMaterialsResultsFrame(primaryFrame, expandedFrame)
        self:UpdateCraftingFarmingSortHeaderState(expandedFrame)
        self:RefreshCraftingFarmingWindow(scrollToTop, {
            renderOnly = true,
            deferMetrics = true,
            rows = rows,
            skipControls = true,
            targetFrame = expandedFrame,
        })
    end
end

function GoldTracker:CreateCraftingFarmingWindow()
    if self.craftingFarmingFrame then
        return
    end

    local addon = self
    local frame = CreateFrame("Frame", "GoldTrackerCraftingFarmingFrame", UIParent, "BasicFrameTemplateWithInset")
    frame:SetSize(MATERIALS_WINDOW_WIDTH, MATERIALS_WINDOW_HEIGHT)
    frame:SetPoint("CENTER", UIParent, "CENTER", 0, 40)
    frame:SetFrameStrata("DIALOG")
    if frame.SetToplevel then
        frame:SetToplevel(true)
    end
    frame:SetMovable(true)
    frame:SetResizable(true)
    if frame.SetResizeBounds then
        frame:SetResizeBounds(
            MATERIALS_WINDOW_MIN_WIDTH,
            MATERIALS_WINDOW_MIN_HEIGHT,
            MATERIALS_WINDOW_MAX_WIDTH,
            MATERIALS_WINDOW_MAX_HEIGHT
        )
    else
        if frame.SetMinResize then
            frame:SetMinResize(MATERIALS_WINDOW_MIN_WIDTH, MATERIALS_WINDOW_MIN_HEIGHT)
        end
        if frame.SetMaxResize then
            frame:SetMaxResize(MATERIALS_WINDOW_MAX_WIDTH, MATERIALS_WINDOW_MAX_HEIGHT)
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

    local initialSource = self:GetCraftingFarmingValueSource()
    frame.valueSourceID = initialSource and initialSource.id
    frame.expansionID = NormalizeExpansionID(self.db and self.db.craftingFarmingExpansionID)
    local professionOrder
    frame.professionIDs, professionOrder = NormalizeProfessionSelections(
        self.db and self.db.craftingFarmingProfessionIDs,
        self.db and self.db.craftingFarmingProfessionID
    )
    frame.professionID = professionOrder[1] or NormalizeProfessionID(nil)
    frame.rows = {}
    frame.itemCache = {}
    frame.materialsDemandCache = {}
    frame.dropRateByItemID, frame.dropRateUpdatedAt = self:GetSavedCraftingFarmingDropRateLookup()
    frame.sortKey = MATERIALS_DEFAULT_SORT_KEY
    frame.sortAscending = false
    frame.sortCriteria = {
        { key = MATERIALS_DEFAULT_SORT_KEY, ascending = false },
    }
    frame.searchText = ""

    local chrome = Theme:ApplyWindowChrome(frame, "Materials Farming")
    Theme:RegisterSpecialFrame("GoldTrackerCraftingFarmingFrame")

    local controlsPanel = CreateMaterialsPanel(frame, { 0.05, 0.06, 0.08, 0.94 }, { 1.0, 0.82, 0.18, 0.12 })
    controlsPanel:SetPoint("TOPLEFT", chrome, "TOPLEFT", 12, -54)
    controlsPanel:SetPoint("TOPRIGHT", chrome, "TOPRIGHT", -12, -54)
    controlsPanel:SetHeight(114)
    frame.controlsPanel = controlsPanel

    local expansionLabel = controlsPanel:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    expansionLabel:SetPoint("TOPLEFT", controlsPanel, "TOPLEFT", 14, -10)
    expansionLabel:SetText("Expansion")

    local expansionDropdown = CreateFrame("Frame", "GoldTrackerMaterialsExpansionDropdown", controlsPanel, "UIDropDownMenuTemplate")
    expansionDropdown:SetPoint("TOPLEFT", expansionLabel, "BOTTOMLEFT", -16, -5)
    UIDropDownMenu_SetWidth(expansionDropdown, 210)
    UIDropDownMenu_Initialize(expansionDropdown, function(_, level)
        for _, expansion in ipairs(GetExpansionOptions()) do
            local info = UIDropDownMenu_CreateInfo()
            info.text = expansion.label
            info.value = expansion.id
            info.checked = frame.expansionID == expansion.id
            info.func = function()
                addon:SetCraftingFarmingExpansionFilter(expansion.id)
                addon:RefreshCraftingFarmingWindow(true)
            end
            UIDropDownMenu_AddButton(info, level)
        end
    end)
    frame.expansionDropdown = expansionDropdown

    local professionLabel = controlsPanel:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    professionLabel:SetPoint("TOPLEFT", expansionLabel, "TOPLEFT", 250, 0)
    professionLabel:SetText("Profession")

    local professionDropdown = CreateFrame("Frame", "GoldTrackerMaterialsProfessionDropdown", controlsPanel, "UIDropDownMenuTemplate")
    professionDropdown:SetPoint("TOPLEFT", professionLabel, "BOTTOMLEFT", -16, -5)
    UIDropDownMenu_SetWidth(professionDropdown, 210)
    if type(UIDropDownMenu_SetAnchor) == "function" then
        local button = _G[professionDropdown:GetName() .. "Button"]
        UIDropDownMenu_SetAnchor(professionDropdown, 0, -2, "TOPRIGHT", button or professionDropdown, "BOTTOMRIGHT")
    end
    UIDropDownMenu_Initialize(professionDropdown, function(_, level)
        for _, profession in ipairs(GetProfessionOptions()) do
            local info = UIDropDownMenu_CreateInfo()
            info.text = profession.label
            info.value = profession.id
            info.checked = function()
                return IsProfessionSelected(frame.professionIDs, profession.id)
            end
            info.func = function()
                addon:ToggleCraftingFarmingProfessionFilter(profession.id)
                addon:RefreshCraftingFarmingWindow(true)
            end
            UIDropDownMenu_AddButton(info, level)
        end
    end)
    frame.professionDropdown = professionDropdown

    local sourceLabel = controlsPanel:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    sourceLabel:SetPoint("TOPLEFT", professionLabel, "TOPLEFT", 250, 0)
    sourceLabel:SetText("Value source")

    local valueSourceDropdown = CreateFrame("Frame", "GoldTrackerMaterialsValueSourceDropdown", controlsPanel, "UIDropDownMenuTemplate")
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
                    addon:SetCraftingFarmingValueSource(sourceID)
                    addon:RefreshCraftingFarmingWindow(true)
                end
                UIDropDownMenu_AddButton(info, level)
            end
        end
    end)
    frame.valueSourceDropdown = valueSourceDropdown

    local refreshButton = CreateMaterialsButton(controlsPanel, 96, 24, "Refresh", "neutral")
    refreshButton:SetScript("OnClick", function()
        addon:RefreshCraftingFarmingWindow(true, { recordSnapshots = true })
    end)
    frame.refreshButton = refreshButton

    local dropRateButton = CreateMaterialsButton(controlsPanel, 112, 24, "Refresh Drop/h", "neutral")
    dropRateButton:SetScript("OnClick", function()
        addon:SaveCraftingFarmingDropRateLookup(addon:BuildCraftingFarmingDropRateLookup())
        frame.lastMaterialsImportSummary = nil
        addon:RefreshCraftingFarmingWindow(false)
    end)
    frame.dropRateButton = dropRateButton

    local learnButton = CreateMaterialsButton(controlsPanel, 128, 24, "Learn Sessions", "neutral")
    learnButton:SetScript("OnClick", function()
        local learned = addon:LearnCraftingFarmingMaterialsFromSessions()
        addon:SaveCraftingFarmingDropRateLookup(addon:BuildCraftingFarmingDropRateLookup())
        frame.itemCache = {}
        frame.materialsDemandCache = {}
        frame.lastMaterialsImportSummary = string.format("Learned %d materials and refreshed Drop/h.", learned)
        addon:RefreshCraftingFarmingWindow(true)
    end)
    frame.learnButton = learnButton

    local searchInput = CreateFrame("EditBox", nil, controlsPanel, "InputBoxTemplate")
    searchInput:SetSize(280, 22)
    searchInput:SetAutoFocus(false)
    searchInput:SetMaxLetters(80)
    searchInput:SetText(frame.searchText)
    searchInput:SetScript("OnTextChanged", function(editBox)
        local searchText = editBox:GetText() or ""
        if frame.searchText == searchText then
            return
        end
        frame.searchText = searchText
        frame.materialsSearchGeneration = (tonumber(frame.materialsSearchGeneration) or 0) + 1
        local searchGeneration = frame.materialsSearchGeneration
        local function applySearch()
            if frame.materialsSearchGeneration ~= searchGeneration then
                return
            end
            if frame.IsShown and not frame:IsShown() then
                return
            end
            addon:RefreshCraftingFarmingWindow(true)
        end
        if C_Timer and type(C_Timer.After) == "function" then
            C_Timer.After(MATERIALS_SEARCH_DEBOUNCE_SECONDS, applySearch)
        else
            applySearch()
        end
    end)
    searchInput:SetScript("OnEnterPressed", function(editBox)
        editBox:ClearFocus()
    end)
    searchInput:SetScript("OnEscapePressed", function(editBox)
        if editBox:GetText() ~= "" then
            editBox:SetText("")
        else
            editBox:ClearFocus()
        end
    end)
    frame.searchInput = searchInput

    local searchLabel = controlsPanel:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    searchLabel:SetText("Search")
    frame.searchLabel = searchLabel

    local maximizeListButton = CreateMaterialsButton(controlsPanel, 116, 24, "Maximize list", "neutral")
    maximizeListButton:SetPoint("LEFT", searchInput, "RIGHT", 8, 0)
    maximizeListButton:SetScript("OnClick", function()
        addon:OpenCraftingFarmingExpandedWindow()
    end)
    maximizeListButton.tooltipText = "Open a larger window that mirrors the current Materials results."
    frame.maximizeListButton = maximizeListButton

    Theme:LayoutExplorerFilterFields(controlsPanel, {
        { label = expansionLabel, control = expansionDropdown, kind = "dropdown", widthKey = "wideDropdown" },
        { label = professionLabel, control = professionDropdown, kind = "dropdown", widthKey = "wideDropdown" },
        { label = sourceLabel, control = valueSourceDropdown, kind = "dropdown", widthKey = "valueSource" },
    })
    Theme:LayoutExplorerFilterFields(controlsPanel, {
        { label = searchLabel, control = searchInput, widthKey = "search" },
    }, { row = 2 })
    maximizeListButton:ClearAllPoints()
    maximizeListButton:SetPoint("LEFT", searchInput, "RIGHT", 8, 0)
    Theme:LayoutExplorerActionButtons(controlsPanel, { refreshButton, dropRateButton, learnButton })

    local listPanel = CreateMaterialsPanel(frame, { 0.04, 0.05, 0.07, 0.92 }, { 1.0, 0.82, 0.18, 0.10 })
    listPanel:SetPoint("TOPLEFT", controlsPanel, "BOTTOMLEFT", 0, -10)
    listPanel:SetPoint("BOTTOMRIGHT", chrome, "BOTTOMRIGHT", -12, 38)
    SetMaterialsFrameLevel(listPanel, chrome, 1)
    if listPanel.SetClipsChildren then
        listPanel:SetClipsChildren(true)
    end
    frame.listPanel = listPanel

    local mapHeaderButton = CreateMaterialsHeaderButton(listPanel, "Map", MATERIALS_MAP_BUTTON_WIDTH, "CENTER")
    SetMaterialsFrameLevel(mapHeaderButton, listPanel, 2)
    mapHeaderButton:SetPoint("TOPLEFT", listPanel, "TOPLEFT", 86, -12)
    frame.mapHeaderButton = mapHeaderButton

    local addHeaderButton = CreateMaterialsHeaderButton(listPanel, "Add", MATERIALS_ADD_BUTTON_WIDTH, "CENTER")
    SetMaterialsFrameLevel(addHeaderButton, listPanel, 2)
    addHeaderButton:SetPoint("LEFT", mapHeaderButton, "RIGHT", MATERIALS_COLUMN_GAP, 0)
    frame.addHeaderButton = addHeaderButton

    local profitHeaderButton = CreateMaterialsHeaderButton(listPanel, "Margin", MATERIALS_MARGIN_WIDTH, "RIGHT")
    SetMaterialsFrameLevel(profitHeaderButton, listPanel, 2)
    profitHeaderButton:SetPoint("RIGHT", mapHeaderButton, "LEFT", -MATERIALS_COLUMN_GAP, 0)
    profitHeaderButton:SetScript("OnClick", function()
        addon:ToggleCraftingFarmingSort("profit")
    end)
    frame.profitHeaderButton = profitHeaderButton

    local componentCostHeaderButton = CreateMaterialsHeaderButton(listPanel, "Mat cost", MATERIALS_COMPONENT_COST_WIDTH, "RIGHT")
    SetMaterialsFrameLevel(componentCostHeaderButton, listPanel, 2)
    componentCostHeaderButton:SetPoint("RIGHT", profitHeaderButton, "LEFT", -MATERIALS_COLUMN_GAP, 0)
    componentCostHeaderButton:SetScript("OnClick", function()
        addon:ToggleCraftingFarmingSort("componentCost")
    end)
    frame.componentCostHeaderButton = componentCostHeaderButton

    local valueHeaderButton = CreateMaterialsHeaderButton(listPanel, "Value", MATERIALS_VALUE_WIDTH, "RIGHT")
    SetMaterialsFrameLevel(valueHeaderButton, listPanel, 2)
    valueHeaderButton:SetPoint("RIGHT", componentCostHeaderButton, "LEFT", -MATERIALS_COLUMN_GAP, 0)
    valueHeaderButton:SetScript("OnClick", function()
        addon:ToggleCraftingFarmingSort("value")
    end)
    frame.valueHeaderButton = valueHeaderButton

    local trendHeaderButton = CreateMaterialsHeaderButton(listPanel, "Trend", MATERIALS_TREND_WIDTH, "RIGHT")
    SetMaterialsFrameLevel(trendHeaderButton, listPanel, 2)
    trendHeaderButton:SetPoint("RIGHT", valueHeaderButton, "LEFT", -MATERIALS_COLUMN_GAP, 0)
    trendHeaderButton:SetScript("OnClick", function()
        addon:ToggleCraftingFarmingSort("marketTrend")
    end)
    frame.trendHeaderButton = trendHeaderButton

    local sellRateHeaderButton = CreateMaterialsHeaderButton(listPanel, "Sale %", MATERIALS_SELL_RATE_WIDTH, "RIGHT")
    SetMaterialsFrameLevel(sellRateHeaderButton, listPanel, 2)
    sellRateHeaderButton:SetPoint("RIGHT", trendHeaderButton, "LEFT", -MATERIALS_COLUMN_GAP, 0)
    sellRateHeaderButton:SetScript("OnClick", function()
        addon:ToggleCraftingFarmingSort("sellRate")
    end)
    frame.sellRateHeaderButton = sellRateHeaderButton

    local demandHeaderButton = CreateMaterialsHeaderButton(listPanel, "Sold/day", MATERIALS_DEMAND_WIDTH, "RIGHT")
    SetMaterialsFrameLevel(demandHeaderButton, listPanel, 2)
    demandHeaderButton:SetPoint("RIGHT", sellRateHeaderButton, "LEFT", -MATERIALS_COLUMN_GAP, 0)
    demandHeaderButton:SetScript("OnClick", function()
        addon:ToggleCraftingFarmingSort("demand")
    end)
    frame.demandHeaderButton = demandHeaderButton

    local dropRateHeaderButton = CreateMaterialsHeaderButton(listPanel, "Drop/h", MATERIALS_DROP_RATE_WIDTH, "RIGHT")
    SetMaterialsFrameLevel(dropRateHeaderButton, listPanel, 2)
    dropRateHeaderButton:SetPoint("RIGHT", demandHeaderButton, "LEFT", -MATERIALS_COLUMN_GAP, 0)
    dropRateHeaderButton:SetScript("OnClick", function()
        addon:ToggleCraftingFarmingSort("dropRate")
    end)
    frame.dropRateHeaderButton = dropRateHeaderButton

    local goldRateHeaderButton = CreateMaterialsHeaderButton(listPanel, "Gold/h", MATERIALS_GOLD_RATE_WIDTH, "RIGHT")
    SetMaterialsFrameLevel(goldRateHeaderButton, listPanel, 2)
    goldRateHeaderButton:SetPoint("RIGHT", demandHeaderButton, "LEFT", -MATERIALS_COLUMN_GAP, 0)
    goldRateHeaderButton:SetScript("OnClick", function()
        addon:ToggleCraftingFarmingSort("goldRate")
    end)
    frame.goldRateHeaderButton = goldRateHeaderButton

    local tagHeaderButton = CreateMaterialsHeaderButton(listPanel, "Type", MATERIALS_TAG_WIDTH, "LEFT")
    SetMaterialsFrameLevel(tagHeaderButton, listPanel, 2)
    tagHeaderButton:SetPoint("RIGHT", dropRateHeaderButton, "LEFT", -MATERIALS_COLUMN_GAP, 0)
    tagHeaderButton:SetScript("OnClick", function()
        addon:ToggleCraftingFarmingSort("tag")
    end)
    frame.tagHeaderButton = tagHeaderButton

    local professionHeaderButton = CreateMaterialsHeaderButton(listPanel, "Profession", MATERIALS_PROFESSION_WIDTH, "LEFT")
    SetMaterialsFrameLevel(professionHeaderButton, listPanel, 2)
    professionHeaderButton:SetPoint("RIGHT", tagHeaderButton, "LEFT", -MATERIALS_COLUMN_GAP, 0)
    professionHeaderButton:SetScript("OnClick", function()
        addon:ToggleCraftingFarmingSort("profession")
    end)
    frame.professionHeaderButton = professionHeaderButton

    local expansionHeaderButton = CreateMaterialsHeaderButton(listPanel, "Expansion", MATERIALS_EXPANSION_WIDTH, "LEFT")
    SetMaterialsFrameLevel(expansionHeaderButton, listPanel, 2)
    expansionHeaderButton:SetPoint("RIGHT", professionHeaderButton, "LEFT", -MATERIALS_COLUMN_GAP, 0)
    expansionHeaderButton:SetScript("OnClick", function()
        addon:ToggleCraftingFarmingSort("expansion")
    end)
    frame.expansionHeaderButton = expansionHeaderButton

    local itemHeaderButton = CreateMaterialsHeaderButton(listPanel, "Item", nil, "LEFT")
    SetMaterialsFrameLevel(itemHeaderButton, listPanel, 2)
    itemHeaderButton:SetPoint("TOPLEFT", listPanel, "TOPLEFT", 92, -12)
    itemHeaderButton:SetPoint("RIGHT", expansionHeaderButton, "LEFT", -MATERIALS_COLUMN_GAP, 0)
    itemHeaderButton:SetScript("OnClick", function()
        addon:ToggleCraftingFarmingSort("itemName")
    end)
    frame.itemHeaderButton = itemHeaderButton

    local favoriteHeaderButton = CreateMaterialsHeaderButton(listPanel, "Fav", MATERIALS_FAVORITE_WIDTH, "CENTER")
    SetMaterialsFrameLevel(favoriteHeaderButton, listPanel, 2)
    favoriteHeaderButton:SetPoint("TOPLEFT", listPanel, "TOPLEFT", 20, -12)
    frame.favoriteHeaderButton = favoriteHeaderButton

    local headerUnderline = listPanel:CreateTexture(nil, "ARTWORK")
    headerUnderline:SetColorTexture(1, 0.82, 0.18, 0.18)
    headerUnderline:SetPoint("TOPLEFT", listPanel, "TOPLEFT", 12, -30)
    headerUnderline:SetPoint("TOPRIGHT", listPanel, "TOPRIGHT", -12, -30)
    headerUnderline:SetHeight(1)

    local scrollFrame = CreateFrame("ScrollFrame", nil, listPanel, "UIPanelScrollFrameTemplate")
    SetMaterialsFrameLevel(scrollFrame, listPanel, 2)
    scrollFrame:SetPoint("TOPLEFT", listPanel, "TOPLEFT", 12, -36)
    scrollFrame:SetPoint("BOTTOMRIGHT", listPanel, "BOTTOMRIGHT", -26, 12 + MATERIALS_HORIZONTAL_SCROLL_HEIGHT)
    frame.scrollFrame = scrollFrame
    BindMaterialsResultsMouseWheel(scrollFrame, frame)
    local function refreshVisibleRowsAfterScroll()
        QueueMaterialsVisibleRowsRefresh(frame)
    end
    if scrollFrame.HookScript then
        scrollFrame:HookScript("OnVerticalScroll", refreshVisibleRowsAfterScroll)
    else
        scrollFrame:SetScript("OnVerticalScroll", refreshVisibleRowsAfterScroll)
    end

    local content = CreateFrame("Frame", nil, scrollFrame)
    SetMaterialsFrameLevel(content, scrollFrame, 1)
    content:SetSize(1, 1)
    scrollFrame:SetScrollChild(content)
    frame.content = content

    local horizontalScrollBar = CreateFrame("Slider", "GoldTrackerMaterialsHorizontalScrollBar", listPanel, "OptionsSliderTemplate")
    SetMaterialsFrameLevel(horizontalScrollBar, listPanel, 3)
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
        ApplyMaterialsTableColumnLayout(frame)
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
    if metaText.SetDrawLayer then
        metaText:SetDrawLayer("OVERLAY", 7)
    end
    metaText:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 16, 14)
    metaText:SetPoint("RIGHT", frame, "RIGHT", -40, 14)
    metaText:SetJustifyH("LEFT")
    metaText:SetTextColor(0.72, 0.76, 0.84)
    metaText:SetText("")
    frame.metaText = metaText

    Theme:CreateResizeButton(frame, {
        maximize = true,
        minWidth = MATERIALS_WINDOW_MIN_WIDTH,
        minHeight = MATERIALS_WINDOW_MIN_HEIGHT,
        maxWidth = MATERIALS_WINDOW_MAX_WIDTH,
        maxHeight = MATERIALS_WINDOW_MAX_HEIGHT,
        onResizeStop = function()
            addon:RefreshCraftingFarmingWindow(false, {
                renderOnly = true,
                deferMetrics = true,
                rows = frame.materialDisplayRows,
                skipControls = true,
            })
        end,
    })

    frame:RegisterEvent("GET_ITEM_INFO_RECEIVED")
    frame:RegisterEvent("ITEM_DATA_LOAD_RESULT")
    frame:SetScript("OnEvent", function(_, _, itemID)
        if itemID then
            local normalizedItemID = math.floor((tonumber(itemID) or 0) + 0.5)
            local wasRequested = type(frame.pendingMaterialsItemRequests) == "table"
                and frame.pendingMaterialsItemRequests[normalizedItemID] == true
            addon:UpdateCraftingFarmingItemDisplayData(itemID)
            local expandedFrame = addon.craftingFarmingExpandedFrame
            local expandedShown = expandedFrame and expandedFrame.IsShown and expandedFrame:IsShown()
            if wasRequested and (frame:IsShown() or expandedShown) then
                QueueMaterialsItemDisplayRefresh(addon, itemID)
            end
        end
    end)
    frame:SetScript("OnSizeChanged", function()
        if frame.isManualResizing then
            return
        end
        addon:RefreshCraftingFarmingWindowLayout()
    end)
    frame:SetScript("OnShow", function()
        if frame.suppressExplorerOnShow then
            return
        end
        addon:RefreshCraftingFarmingWindow(true)
    end)
    frame:SetScript("OnHide", function()
        frame.materialsRefreshGeneration = (tonumber(frame.materialsRefreshGeneration) or 0) + 1
        frame.materialsRealtimeLoading = false
        GameTooltip:Hide()
    end)

    self.craftingFarmingFrame = frame
    self:RefreshCraftingFarmingWindowControls()
end

function GoldTracker:CreateCraftingFarmingExpandedWindow()
    if self.craftingFarmingExpandedFrame then
        return
    end

    self:CreateCraftingFarmingWindow()
    local addon = self
    local frame = CreateFrame("Frame", "GoldTrackerMaterialsExpandedFrame", UIParent, "BasicFrameTemplateWithInset")
    local width = MATERIALS_EXPANDED_WINDOW_WIDTH
    local height = MATERIALS_EXPANDED_WINDOW_HEIGHT
    if UIParent and type(UIParent.GetWidth) == "function" then
        width = math.min(width, math.max(MATERIALS_EXPANDED_WINDOW_MIN_WIDTH, (tonumber(UIParent:GetWidth()) or width) - 60))
    end
    if UIParent and type(UIParent.GetHeight) == "function" then
        height = math.min(height, math.max(MATERIALS_EXPANDED_WINDOW_MIN_HEIGHT, (tonumber(UIParent:GetHeight()) or height) - 80))
    end
    frame:SetSize(width, height)
    frame:SetPoint("CENTER", UIParent, "CENTER", 0, 20)
    frame:SetFrameStrata("DIALOG")
    if frame.SetToplevel then
        frame:SetToplevel(true)
    end
    frame:SetMovable(true)
    frame:SetResizable(true)
    if frame.SetResizeBounds then
        frame:SetResizeBounds(
            MATERIALS_EXPANDED_WINDOW_MIN_WIDTH,
            MATERIALS_EXPANDED_WINDOW_MIN_HEIGHT,
            MATERIALS_EXPANDED_WINDOW_MAX_WIDTH,
            MATERIALS_EXPANDED_WINDOW_MAX_HEIGHT
        )
    else
        if frame.SetMinResize then
            frame:SetMinResize(MATERIALS_EXPANDED_WINDOW_MIN_WIDTH, MATERIALS_EXPANDED_WINDOW_MIN_HEIGHT)
        end
        if frame.SetMaxResize then
            frame:SetMaxResize(MATERIALS_EXPANDED_WINDOW_MAX_WIDTH, MATERIALS_EXPANDED_WINDOW_MAX_HEIGHT)
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
    frame.rows = {}

    local chrome = Theme:ApplyWindowChrome(frame, "Materials List")
    Theme:RegisterSpecialFrame("GoldTrackerMaterialsExpandedFrame")

    local filterText = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    filterText:SetPoint("TOPLEFT", chrome, "TOPLEFT", 16, -55)
    filterText:SetPoint("RIGHT", chrome, "RIGHT", -16, 0)
    filterText:SetJustifyH("LEFT")
    filterText:SetTextColor(0.72, 0.86, 1.0)
    frame.filterText = filterText

    local listPanel = CreateMaterialsPanel(frame, { 0.04, 0.05, 0.07, 0.96 }, { 1.0, 0.82, 0.18, 0.10 })
    listPanel:SetPoint("TOPLEFT", chrome, "TOPLEFT", 12, -76)
    listPanel:SetPoint("BOTTOMRIGHT", chrome, "BOTTOMRIGHT", -12, 38)
    SetMaterialsFrameLevel(listPanel, chrome, 1)
    if listPanel.SetClipsChildren then
        listPanel:SetClipsChildren(true)
    end
    frame.listPanel = listPanel

    local function addHeader(frameKey, label, widthValue, justify, sortKey)
        local button = CreateMaterialsHeaderButton(listPanel, label, widthValue, justify)
        SetMaterialsFrameLevel(button, listPanel, 2)
        if sortKey then
            button:SetScript("OnClick", function()
                addon:ToggleCraftingFarmingSort(sortKey)
            end)
        end
        frame[frameKey] = button
        return button
    end

    addHeader("favoriteHeaderButton", "Fav", MATERIALS_FAVORITE_WIDTH, "CENTER")
    addHeader("mapHeaderButton", "Map", MATERIALS_MAP_BUTTON_WIDTH, "CENTER")
    addHeader("addHeaderButton", "Add", MATERIALS_ADD_BUTTON_WIDTH, "CENTER")
    addHeader("itemHeaderButton", "Item", MATERIALS_ITEM_MIN_WIDTH, "LEFT", "itemName")
    addHeader("tagHeaderButton", "Type", MATERIALS_TAG_WIDTH, "LEFT", "tag")
    addHeader("valueHeaderButton", "Value", MATERIALS_VALUE_WIDTH, "RIGHT", "value")
    addHeader("dropRateHeaderButton", "Drop/h", MATERIALS_DROP_RATE_WIDTH, "RIGHT", "dropRate")
    addHeader("goldRateHeaderButton", "Gold/h", MATERIALS_GOLD_RATE_WIDTH, "RIGHT", "goldRate")
    addHeader("demandHeaderButton", "Sold/day", MATERIALS_DEMAND_WIDTH, "RIGHT", "demand")
    addHeader("componentCostHeaderButton", "Mat cost", MATERIALS_COMPONENT_COST_WIDTH, "RIGHT", "componentCost")
    addHeader("profitHeaderButton", "Margin", MATERIALS_MARGIN_WIDTH, "RIGHT", "profit")
    addHeader("sellRateHeaderButton", "Sale %", MATERIALS_SELL_RATE_WIDTH, "RIGHT", "sellRate")
    addHeader("trendHeaderButton", "Trend", MATERIALS_TREND_WIDTH, "RIGHT", "marketTrend")
    addHeader("professionHeaderButton", "Profession", MATERIALS_PROFESSION_WIDTH, "LEFT", "profession")
    addHeader("expansionHeaderButton", "Expansion", MATERIALS_EXPANSION_WIDTH, "LEFT", "expansion")

    local headerUnderline = listPanel:CreateTexture(nil, "ARTWORK")
    headerUnderline:SetColorTexture(1, 0.82, 0.18, 0.18)
    headerUnderline:SetPoint("TOPLEFT", listPanel, "TOPLEFT", 12, -30)
    headerUnderline:SetPoint("TOPRIGHT", listPanel, "TOPRIGHT", -12, -30)
    headerUnderline:SetHeight(1)

    local scrollFrame = CreateFrame("ScrollFrame", nil, listPanel, "UIPanelScrollFrameTemplate")
    SetMaterialsFrameLevel(scrollFrame, listPanel, 2)
    scrollFrame:SetPoint("TOPLEFT", listPanel, "TOPLEFT", 12, -36)
    scrollFrame:SetPoint("BOTTOMRIGHT", listPanel, "BOTTOMRIGHT", -26, 12 + MATERIALS_HORIZONTAL_SCROLL_HEIGHT)
    frame.scrollFrame = scrollFrame
    BindMaterialsResultsMouseWheel(scrollFrame, frame)
    local function refreshVisibleRowsAfterScroll()
        QueueMaterialsVisibleRowsRefresh(frame)
    end
    if scrollFrame.HookScript then
        scrollFrame:HookScript("OnVerticalScroll", refreshVisibleRowsAfterScroll)
    else
        scrollFrame:SetScript("OnVerticalScroll", refreshVisibleRowsAfterScroll)
    end

    local content = CreateFrame("Frame", nil, scrollFrame)
    SetMaterialsFrameLevel(content, scrollFrame, 1)
    content:SetSize(1, 1)
    scrollFrame:SetScrollChild(content)
    frame.content = content

    local horizontalScrollBar = CreateFrame(
        "Slider",
        "GoldTrackerMaterialsExpandedHorizontalScrollBar",
        listPanel,
        "OptionsSliderTemplate"
    )
    SetMaterialsFrameLevel(horizontalScrollBar, listPanel, 3)
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
        ApplyMaterialsTableColumnLayout(frame)
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
    if metaText.SetDrawLayer then
        metaText:SetDrawLayer("OVERLAY", 7)
    end
    metaText:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 16, 14)
    metaText:SetPoint("RIGHT", frame, "RIGHT", -40, 14)
    metaText:SetJustifyH("LEFT")
    metaText:SetTextColor(0.72, 0.76, 0.84)
    metaText:SetText("")
    frame.metaText = metaText

    Theme:CreateResizeButton(frame, {
        maximize = true,
        minWidth = MATERIALS_EXPANDED_WINDOW_MIN_WIDTH,
        minHeight = MATERIALS_EXPANDED_WINDOW_MIN_HEIGHT,
        maxWidth = MATERIALS_EXPANDED_WINDOW_MAX_WIDTH,
        maxHeight = MATERIALS_EXPANDED_WINDOW_MAX_HEIGHT,
        onResizeStop = function()
            addon:RefreshCraftingFarmingExpandedWindow(false)
        end,
    })

    frame:SetScript("OnSizeChanged", function()
        if frame.isManualResizing then
            return
        end
        addon:RefreshCraftingFarmingWindowLayout(frame)
    end)
    frame:SetScript("OnShow", function()
        addon:RefreshCraftingFarmingExpandedWindow(true)
    end)
    frame:SetScript("OnHide", function()
        GameTooltip:Hide()
    end)

    self.craftingFarmingExpandedFrame = frame
    SyncMaterialsResultsFrame(self.craftingFarmingFrame, frame)
    self:UpdateCraftingFarmingSortHeaderState(frame)
end

function GoldTracker:RefreshCraftingFarmingExpandedWindow(scrollToTop)
    local sourceFrame = self.craftingFarmingFrame
    local frame = self.craftingFarmingExpandedFrame
    if not sourceFrame or not frame then
        return
    end

    SyncMaterialsResultsFrame(sourceFrame, frame)
    self:UpdateCraftingFarmingSortHeaderState(frame)
    local rows = sourceFrame.materialDisplayRows
    if type(rows) ~= "table" then
        self:RefreshCraftingFarmingWindow(scrollToTop == true)
        return
    end
    self:RefreshCraftingFarmingWindow(scrollToTop == true, {
        renderOnly = true,
        deferMetrics = true,
        rows = rows,
        skipControls = true,
        targetFrame = frame,
    })
end

function GoldTracker:OpenCraftingFarmingExpandedWindow()
    self:CreateCraftingFarmingExpandedWindow()
    local frame = self.craftingFarmingExpandedFrame
    if not frame then
        return
    end

    local wasShown = frame:IsShown()
    frame:Show()
    frame:Raise()
    if wasShown then
        self:RefreshCraftingFarmingExpandedWindow(true)
    end
end

function GoldTracker:OpenCraftingFarmingWindow()
    if type(self.OpenExplorerWindow) == "function" then
        self:OpenExplorerWindow("materials")
        return
    end

    self:CreateCraftingFarmingWindow()
    if not self.craftingFarmingFrame then
        return
    end

    self.craftingFarmingFrame.suppressExplorerOnShow = true
    self.craftingFarmingFrame:Show()
    self.craftingFarmingFrame.suppressExplorerOnShow = nil
    self.craftingFarmingFrame:Raise()
    self:RefreshCraftingFarmingWindow(true)
end

function GoldTracker:ToggleCraftingFarmingWindow()
    if type(self.ToggleExplorerWindow) == "function" then
        self:ToggleExplorerWindow("materials")
        return
    end

    self:CreateCraftingFarmingWindow()
    if not self.craftingFarmingFrame then
        return
    end

    if self.craftingFarmingFrame:IsShown() then
        self.craftingFarmingFrame:Hide()
    else
        self:OpenCraftingFarmingWindow()
    end
end
