local _, NS = ...
local function CreateFrame(...)
    return (NS.CreateThemedFrame or _G.CreateFrame)(...)
end
local GoldTracker = NS.GoldTracker
local Theme = NS.JanisTheme
local MapAreaOverlay = GoldTracker.MapAreaOverlay

local DEFAULT_MAP_ID = 107
local DEFAULT_PIN_X = 41.4
local DEFAULT_PIN_Y = 41.4
local MIN_ZOOM = 1
local MAX_ZOOM = 3
local ZOOM_STEP = 0.25
local MAP_DROPDOWN_WIDTH = 280
local WINDOW_WIDTH = 1080
local WINDOW_HEIGHT = 600
local DETAILS_PANEL_WIDTH = 380
local DETAILS_PANEL_GAP = 10
local DETAILS_CONTENT_PADDING = 12
local SOURCE_BUTTON_WIDTH = 54
local SOURCE_ROW_HEIGHT = 24
local DETAIL_TABLE_ROW_HEIGHT = 20
local DETAIL_TABLE_FILTER_ROW_HEIGHT = 30
local DETAIL_TABLE_HEADER_ROW_HEIGHT = 22
local DETAIL_TOGGLE_ROW_HEIGHT = 20
local DETAIL_BUTTON_ROW_HEIGHT = 28
local DETAIL_BUTTON_WIDTH = 220
local DETAIL_DIVIDER_ROW_HEIGHT = 14
local DETAIL_TABLE_TYPE_WIDTH = 66
local DETAIL_TABLE_QUANTITY_WIDTH = 44
local DETAIL_TABLE_VALUE_WIDTH = 86
local DETAIL_TABLE_COLUMN_GAP = 4
local DETAIL_TEXT_HEIGHT_PADDING = 4
local DETAIL_TEXT_MEASURE_HEIGHT = 1000
local ROUTE_LINE_THICKNESS = 3
local MAP_DISPLAY_MODE_OVERLAY = "overlay"
local MAP_DISPLAY_MODE_ICONS = "icons"
local MAP_DISPLAY_MODE_BUTTON_WIDTH = 72
local WAYPOINT_BUTTON_WIDTH = 104
local ADD_TO_FARM_BUTTON_WIDTH = 104
local PROJECT_BUTTON_WIDTH = 160
local MAP_PIN_SIZE = 18
local MAP_PIN_ICON_SIZE = 14
local MAP_PIN_DUNGEON_ICON_SIZE = 36
local MAP_PIN_DUNGEON_ICON_OFFSET_X = -18
local MAP_PIN_RING_SIZE = 24
local MAP_PIN_RING_SUBLEVEL = 4
local MAP_PIN_ICON_SUBLEVEL = 5
local MAP_PIN_ORDER_BACKGROUND_SUBLEVEL = 6
local MAP_PIN_ORDER_TEXT_SUBLEVEL = 7
local MAP_CLICK_DISTANCE = 5
local RECORDED_YIELDS_WINDOW_WIDTH = 720
local RECORDED_YIELDS_WINDOW_HEIGHT = 560

local GetSelectedMapOption

local function CreatePanel(parent, bg, border)
    if Theme and type(Theme.CreatePanel) == "function" then
        return Theme:CreatePanel(parent, bg, border)
    end

    local panel = CreateFrame("Frame", nil, parent, "BackdropTemplate")
    panel:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Buttons\\WHITE8X8",
        edgeSize = 1,
    })
    panel:SetBackdropColor(0.04, 0.05, 0.07, 0.96)
    panel:SetBackdropBorderColor(1.0, 0.82, 0.18, 0.14)
    return panel
end

local function CreateButton(parent, width, height, text, paletteKey)
    if Theme and type(Theme.CreateButton) == "function" then
        return Theme:CreateButton(parent, width, height, text, paletteKey or "neutral")
    end

    local button = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
    button:SetSize(width, height)
    button:SetText(text or "")
    return button
end

local function ClampZoom(value)
    value = tonumber(value) or 1
    if value < MIN_ZOOM then
        return MIN_ZOOM
    elseif value > MAX_ZOOM then
        return MAX_ZOOM
    end
    return value
end

local function GetMapName(mapID)
    local normalizedMapID = tonumber(mapID)
    if normalizedMapID and C_Map and type(C_Map.GetMapInfo) == "function" then
        local ok, mapInfo = pcall(C_Map.GetMapInfo, normalizedMapID)
        if ok and mapInfo and mapInfo.name then
            return mapInfo.name
        end
    end
    return normalizedMapID and ("Map " .. tostring(normalizedMapID)) or "Map"
end

local function SetStatus(frame, text)
    if frame and frame.statusText then
        frame.statusText:SetText(text or "")
    end
end

local function HasText(value)
    return type(value) == "string" and value ~= ""
end

local function GetPinTitle(pinData)
    if HasText(pinData and pinData.itemName) then
        return pinData.itemName
    end
    if HasText(pinData and pinData.label) then
        return pinData.label
    end
    return "Map location"
end

local function GetStandaloneMapToolbarTitle(frame)
    local option = GetSelectedMapOption and GetSelectedMapOption(frame)
    if HasText(option and option.windowTitle) then
        return option.windowTitle
    end
    if HasText(frame and frame.windowTitle) then
        return frame.windowTitle
    end
    if frame and frame.mapOptions then
        return ""
    end
    return GetMapName(frame and frame.mapID or DEFAULT_MAP_ID)
end

local function GetStandaloneMapHeaderItemID(frame)
    local option = GetSelectedMapOption and GetSelectedMapOption(frame)
    local row = frame.customFarmRow or {}
    return tonumber(option and option.selectedItemID or row.itemID)
end

local function RefreshStandaloneMapHeader(frame)
    local titleText = frame.headerTitleText or frame.TitleText
    if not titleText then
        return
    end
    local row = frame.customFarmRow or {}
    local itemID = GetStandaloneMapHeaderItemID(frame)
    local itemName
    if HasText(row.itemName) and (not itemID or tonumber(row.itemID) == itemID) then
        itemName = row.itemName
    elseif itemID then
        if C_Item and type(C_Item.GetItemInfo) == "function" then
            itemName = C_Item.GetItemInfo(itemID)
        elseif type(GetItemInfo) == "function" then
            itemName = GetItemInfo(itemID)
        end
    end
    titleText:SetText(itemName or (itemID and ("Item " .. tostring(itemID)))
        or frame.windowTitle or "Farm map")
end

local function AppendDetailLine(lines, text, r, g, b, gap, fontObject)
    if HasText(text) then
        lines[#lines + 1] = {
            type = "text",
            text = text,
            r = r or 0.82,
            g = g or 0.86,
            b = b or 0.92,
            gap = gap or 4,
            fontObject = fontObject,
        }
    end
end

local function AppendSourceLine(lines, siteName, url, gap)
    if HasText(siteName) and HasText(url) then
        lines[#lines + 1] = {
            type = "source",
            siteName = siteName,
            url = url,
            gap = gap or 6,
        }
    end
end

local function CopyTips(tips)
    if type(tips) ~= "table" then
        return nil
    end

    local copy = {}
    for _, tip in ipairs(tips) do
        if HasText(tip) then
            copy[#copy + 1] = tip
        end
    end
    return #copy > 0 and copy or nil
end

local function GetSourceSiteName(url)
    if not HasText(url) then
        return nil
    end

    local host = string.match(url, "^%a[%w+.-]*://([^/%?#]+)") or string.match(url, "^([^/%?#]+)")
    host = type(host) == "string" and string.lower(host) or ""
    host = string.gsub(host, "^www%.", "")

    if string.find(host, "wowhead%.com") then
        return "Wowhead"
    elseif string.find(host, "wow%-professions%.com") then
        return "wow-professions"
    elseif string.find(host, "warcraft%.wiki%.gg") or string.find(host, "warcraftwiki%.gg") then
        return "Warcraft Wiki"
    elseif string.find(host, "wowdb%.com") then
        return "WoWDB"
    elseif string.find(host, "mmo%-champion%.com") then
        return "MMO-Champion"
    elseif string.find(host, "reddit%.com") then
        return "Reddit"
    elseif string.find(host, "artisansofazeroth%.com") then
        return "Artisans of Azeroth"
    elseif host ~= "" then
        return host
    end

    return "Source"
end

local function AddSourceUrl(group, url)
    if not group or not HasText(url) then
        return
    end

    group.sourceUrlLookup = group.sourceUrlLookup or {}
    if group.sourceUrlLookup[url] then
        return
    end

    group.sourceUrlLookup[url] = true
    group.sources = group.sources or {}
    group.sources[#group.sources + 1] = {
        siteName = GetSourceSiteName(url),
        url = url,
    }
end

local function AddSourceUrls(group, sourceUrls)
    if type(sourceUrls) ~= "table" then
        return
    end

    for _, url in ipairs(sourceUrls) do
        AddSourceUrl(group, url)
    end
end

local function GetUserPinSourceName(pinData)
    local sourceName = pinData and (pinData.spotLocation or pinData.label)
    if not HasText(sourceName) then
        return nil
    end
    sourceName = sourceName:gsub("^AOE Unit:%s*", ""):gsub("^Unit:%s*", "")
    return HasText(sourceName) and sourceName or nil
end

local function GetPinTargetName(pinData)
    if HasText(pinData and pinData.targetName) then
        return pinData.targetName
    end
    if not pinData or pinData.sourceType ~= "user" then
        return nil
    end
    if pinData.sourceKind == "NPC" or pinData.sourceKind == "AOE" then
        return GetUserPinSourceName(pinData)
    end
    local sourceText = pinData.spotLocation or pinData.label
    if HasText(sourceText)
        and (sourceText:find("^Unit:%s*") or sourceText:find("^AOE Unit:%s*"))
    then
        return GetUserPinSourceName(pinData)
    end
    return nil
end

local function AddTargetName(group, targetName, targetType)
    if not group or not HasText(targetName) then
        return
    end
    group.targetLookup = group.targetLookup or {}
    if group.targetLookup[targetName] then
        return
    end
    group.targetLookup[targetName] = true
    group.targets = group.targets or {}
    group.targets[#group.targets + 1] = targetName
    if HasText(targetType) then
        if not group.targetType then
            group.targetType = targetType
        elseif group.targetType ~= targetType then
            group.targetType = "farm"
        end
    end
end

local TARGET_ACTION_LABELS = {
    collect = "Collect",
    farm = "Farm",
    fish = "Fish",
    gather = "Gather",
    kill = "Kill",
    loot = "Loot",
    mine = "Mine",
    open = "Open",
    skin = "Kill and skin",
}

local function FormatRouteType(routeType)
    if not HasText(routeType) then
        return nil
    end
    local text = routeType:gsub("[_%-]+", " "):gsub("%s+", " ")
    text = text:gsub("^%s+", ""):gsub("%s+$", "")
    return text:gsub("^%l", string.upper)
end

local function InferFarmAction(group)
    if HasText(group and group.farmAction) then
        return group.farmAction
    end

    local hasTargets = type(group and group.targets) == "table" and #group.targets > 0
    if hasTargets then
        local label = TARGET_ACTION_LABELS[group.targetType] or "Farm"
        return label .. ": " .. table.concat(group.targets, ", ")
    end

    local routeType = string.lower(group and group.routeType or "")
    if routeType:find("skinning", 1, true) and routeType:find("fishing", 1, true) then
        return "Farm: Fish the marked waters and skin suitable creatures along the route."
    elseif routeType:find("herbable%-mob") then
        return "Gather: Kill herbable creatures, then harvest their corpses."
    elseif routeType:find("skinning", 1, true) then
        return HasText(group.location)
            and ("Kill and skin here: " .. group.location)
            or "Kill and skin: Farm skinnable creatures throughout the marked area."
    elseif routeType:find("fishing", 1, true) or routeType:find("fish", 1, true) then
        return "Fish: Cast in the marked waters and prioritize visible fishing pools."
    elseif routeType:find("herbalism", 1, true) or routeType:find("herb", 1, true) then
        return "Gather: Harvest herb nodes while following the marked route."
    elseif routeType:find("gather", 1, true) then
        return "Gather: Collect the relevant resources throughout the marked area."
    elseif routeType:find("prospect", 1, true) then
        return "Mine and prospect: Gather the indicated ore, then prospect it for this material."
    elseif routeType:find("mining", 1, true) or routeType:find("mineable", 1, true) then
        return "Mine: Gather ore nodes while following the marked route."
    elseif routeType:find("disenchant", 1, true) then
        return "Disenchant: Farm eligible gear here, then disenchant it for this material."
    elseif routeType:find("vendor", 1, true) then
        return "Buy: Visit the marked vendor and purchase or exchange for this item."
    elseif routeType:find("container", 1, true) or routeType:find("cache", 1, true)
        or routeType:find("object", 1, true) or routeType:find("lumber", 1, true)
    then
        return "Collect: Open or gather the marked objects throughout this area."
    elseif routeType:find("grind", 1, true) or routeType:find("mob", 1, true)
        or routeType:find("creature", 1, true) or routeType:find("beast", 1, true)
        or routeType:find("humanoid", 1, true) or routeType:find("undead", 1, true)
        or routeType:find("elemental", 1, true) or routeType:find("kill", 1, true)
        or routeType:find("cloth", 1, true) or routeType:find("meat", 1, true)
    then
        return HasText(group.location)
            and ("Kill here: " .. group.location)
            or "Kill: Farm creatures throughout the marked area."
    elseif routeType:find("dungeon", 1, true) or routeType:find("raid", 1, true)
        or routeType:find("instance", 1, true) or routeType:find("delve", 1, true)
    then
        return "Farm: Clear the marked instance, boss, or delve route."
    end

    return "Farm: Follow the marked route and the instructions below."
end

local function GetSecondaryAreaText(location, hasTargets)
    if not HasText(location) then
        return nil
    end
    local area = location
    if hasTargets then
        area = area:gsub(",%s*[Kk]illing%s+.+$", "")
    end
    return "Area: " .. area
end

local function BuildUserClusterDetailGroup(areaGroup)
    local firstPin = areaGroup and areaGroup.pins and areaGroup.pins[1]
    if not firstPin then
        return nil
    end

    local group = {
        title = GetPinTitle(firstPin),
        routeType = firstPin.routeType,
        farmAction = firstPin.farmAction,
        sourceType = firstPin.sourceType,
        sourceLabel = firstPin.sourceLabel,
        targets = {},
        targetLookup = {},
        tips = {},
        sources = {},
        sourceUrlLookup = {},
    }
    local tipLookup = {}
    local totalX = 0
    local totalY = 0
    local totalSeen = 0
    local totalLooted = 0

    for _, pinData in ipairs(areaGroup.pins or {}) do
        totalX = totalX + (tonumber(pinData.x) or 0)
        totalY = totalY + (tonumber(pinData.y) or 0)
        totalSeen = totalSeen + math.max(0, tonumber(pinData.seenCount) or 0)
        totalLooted = totalLooted + math.max(0, tonumber(pinData.totalQuantity) or 0)
        local targetName = GetPinTargetName(pinData)
        AddTargetName(group, targetName, pinData.targetType or (targetName and "kill"))
        for _, tip in ipairs(CopyTips(pinData.tips) or {}) do
            if not tipLookup[tip] then
                tipLookup[tip] = true
                group.tips[#group.tips + 1] = tip
            end
        end
        AddSourceUrls(group, pinData.sourceUrls)
    end

    local pointCount = #areaGroup.pins
    local centerX = pointCount > 0 and (totalX / pointCount) or 0
    local centerY = pointCount > 0 and (totalY / pointCount) or 0
    group.location = string.format("Near %.1f, %.1f", centerX * 100, centerY * 100)
    group.density = string.format(
        "%d nearby %s, %d seen, %d looted",
        pointCount,
        pointCount == 1 and "point" or "points",
        totalSeen,
        totalLooted
    )
    return group
end

local function BuildVisiblePinGroups(pins, mapID)
    local groups = {}
    local byKey = {}
    local selectedMapID = tonumber(mapID)
    local clusteredUserPins = {}
    if MapAreaOverlay and type(MapAreaOverlay.BuildGroups) == "function" then
        for _, areaGroup in ipairs(MapAreaOverlay:BuildGroups(pins, selectedMapID)) do
            if areaGroup.isUserCluster == true then
                local group = BuildUserClusterDetailGroup(areaGroup)
                if group then
                    groups[#groups + 1] = group
                end
                for _, pinData in ipairs(areaGroup.pins or {}) do
                    clusteredUserPins[pinData] = true
                end
            end
        end
    end

    for _, pinData in ipairs(pins or {}) do
        if pinData and tonumber(pinData.mapID) == selectedMapID and not clusteredUserPins[pinData] then
            local tips = CopyTips(pinData.tips)
            local key = table.concat({
                GetPinTitle(pinData),
                pinData.spotLocation or pinData.label or "",
                pinData.routeType or "",
                pinData.density or "",
                pinData.dropDifficulty or "",
                pinData.farmAction or "",
                pinData.targetType or "",
                pinData.sourceType or "",
                pinData.sourceLabel or "",
                tips and table.concat(tips, "\n") or "",
            }, "\031")
            local group = byKey[key]
            if not group then
                group = {
                    title = GetPinTitle(pinData),
                    location = pinData.spotLocation,
                    routeType = pinData.routeType,
                    density = pinData.density,
                    dropDifficulty = pinData.dropDifficulty,
                    farmAction = pinData.farmAction,
                    sourceType = pinData.sourceType,
                    sourceLabel = pinData.sourceLabel,
                    targets = {},
                    targetLookup = {},
                    tips = tips,
                    sources = {},
                    sourceUrlLookup = {},
                }
                byKey[key] = group
                groups[#groups + 1] = group
            end
            local targetName = GetPinTargetName(pinData)
            AddTargetName(group, targetName, pinData.targetType or (targetName and "kill"))
            AddSourceUrls(group, pinData.sourceUrls)
        end
    end
    return groups
end

local function IsValidMapCoordinate(value)
    value = tonumber(value)
    return value and value >= 0 and value <= 1
end

local function GetStandaloneMapAreaGroups(frame)
    if not frame or not MapAreaOverlay or type(MapAreaOverlay.BuildGroups) ~= "function" then
        return {}
    end
    return MapAreaOverlay:BuildGroups(frame.mapPins, frame.mapID)
end

local function GetAreaGroupCenter(group)
    local totalX = 0
    local totalY = 0
    local pointCount = 0
    for _, pinData in ipairs(group and group.pins or {}) do
        local x = tonumber(pinData and pinData.x)
        local y = tonumber(pinData and pinData.y)
        if IsValidMapCoordinate(x) and IsValidMapCoordinate(y) then
            totalX = totalX + x
            totalY = totalY + y
            pointCount = pointCount + 1
        end
    end
    if pointCount == 0 then
        return nil, nil
    end
    return totalX / pointCount, totalY / pointCount
end

local function GetAreaGroupLabel(group)
    local x, y = GetAreaGroupCenter(group)
    local label = group and group.label
    if HasText(label) and x and y then
        return string.format("%s (%.1f, %.1f)", label, x * 100, y * 100)
    elseif HasText(label) then
        return label
    elseif x and y then
        return string.format("farming area at %.1f, %.1f", x * 100, y * 100)
    end
    return "farming area"
end

local function FindAreaGroupByKey(groups, key)
    if key == nil then
        return nil
    end
    for _, group in ipairs(groups or {}) do
        if group.key == key then
            return group
        end
    end
    return nil
end

local function PointIsInsidePolygon(x, y, points)
    local inside = false
    local previous = points and points[#points]
    if not previous then
        return false
    end

    for _, current in ipairs(points) do
        if ((current.y > y) ~= (previous.y > y))
            and x < ((previous.x - current.x) * (y - current.y) / (previous.y - current.y)) + current.x
        then
            inside = not inside
        end
        previous = current
    end
    return inside
end

function GoldTracker.BuildStandaloneMapDetailLines(_, pins, mapID, mapLabel)
    local lines = {}
    local groups = BuildVisiblePinGroups(pins, mapID)

    AppendDetailLine(lines, mapLabel or GetMapName(mapID), 1.0, 0.82, 0.18, 10, "GameFontNormalLarge")

    if #groups == 0 then
        AppendDetailLine(lines, "No farming pins for this map.", 0.72, 0.76, 0.84, 4, "GameFontDisable")
        return lines
    end

    for groupIndex, group in ipairs(groups) do
        AppendDetailLine(lines, group.title, 1.0, 0.82, 0.18, 6, "GameFontNormalLarge")
        local hasTargets = type(group.targets) == "table" and #group.targets > 0
        local actionText = InferFarmAction(group)
        local areaText = GetSecondaryAreaText(group.location, hasTargets)
        AppendDetailLine(lines, actionText, 1.0, 0.45, 0.20, 6, "GameFontNormalLarge")
        AppendDetailLine(lines, areaText, 0.68, 0.72, 0.80, 6, "GameFontHighlight")
        local formattedRouteType = FormatRouteType(group.routeType)
        local routeText = formattedRouteType and ("Method: " .. formattedRouteType) or nil
        local densityText = HasText(group.density) and ("Density: " .. group.density) or nil
        local sourceText = HasText(group.sourceLabel) and ("Source: " .. group.sourceLabel) or nil
        local difficultyText = HasText(group.dropDifficulty) and ("Notes: " .. group.dropDifficulty) or nil
        AppendDetailLine(lines, routeText, 0.72, 0.86, 1.0, 5, "GameFontHighlight")
        AppendDetailLine(lines, densityText, 0.72, 0.86, 1.0, 5, "GameFontHighlight")
        AppendDetailLine(lines, sourceText, 0.72, 0.86, 1.0, 5, "GameFontHighlight")
        AppendDetailLine(lines, difficultyText, 0.72, 0.86, 1.0, 7, "GameFontHighlight")

        if type(group.tips) == "table" and #group.tips > 0 then
            AppendDetailLine(lines, "Tips", 1.0, 0.82, 0.18, 5, "GameFontNormal")
            for _, tip in ipairs(group.tips) do
                AppendDetailLine(lines, "- " .. tip, 0.82, 0.86, 0.92, 5, "GameFontHighlight")
            end
        end

        if type(group.sources) == "table" and #group.sources > 0 then
            AppendDetailLine(lines, "Sources", 1.0, 0.82, 0.18, 5, "GameFontNormal")
            for sourceIndex, source in ipairs(group.sources) do
                local gap = (groupIndex < #groups or sourceIndex < #group.sources) and 8 or 4
                AppendSourceLine(lines, source.siteName, source.url, gap)
            end
        elseif groupIndex < #groups then
            AppendDetailLine(lines, " ", 0.82, 0.86, 0.92, 8, "GameFontHighlight")
        end
    end

    return lines
end

local function HideTiles(frame)
    for _, texture in ipairs(frame.mapTileTextures or {}) do
        texture:Hide()
    end
end

local function HideExploredTiles(frame)
    for _, texture in ipairs(frame.mapExploredTileTextures or {}) do
        texture:Hide()
    end
end

local function HidePins(frame)
    for _, pin in ipairs(frame.mapPinFrames or {}) do
        pin:Hide()
    end
end

local function NormalizeMapDisplayMode(mode)
    if mode == MAP_DISPLAY_MODE_ICONS then
        return MAP_DISPLAY_MODE_ICONS
    end
    return MAP_DISPLAY_MODE_OVERLAY
end

local function RefreshMapDisplayModeButton(frame)
    if not frame or not frame.displayModeButton then
        return
    end

    local mode = NormalizeMapDisplayMode(frame.mapDisplayMode)
    frame.displayModeButton:SetText(mode == MAP_DISPLAY_MODE_ICONS and "Overlay" or "Icons")
    frame.displayModeButton.tooltipText = mode == MAP_DISPLAY_MODE_ICONS
        and "Switch to the farming area overlay."
        or "Switch to individual farming location icons."
end

local function TrySetMapPinAtlas(texture, atlas)
    if not texture or type(texture.SetAtlas) ~= "function" then
        return false
    end
    local ok = pcall(texture.SetAtlas, texture, atlas, true)
    if not ok then
        return false
    end
    if type(texture.GetAtlas) == "function" then
        local atlasOK, appliedAtlas = pcall(texture.GetAtlas, texture)
        return atlasOK and appliedAtlas == atlas
    end
    return true
end

local function ApplyMapPinTexture(texture, atlas, fallbackTexture)
    if not texture then
        return nil
    end
    if atlas and TrySetMapPinAtlas(texture, atlas) then
        return "atlas"
    end
    if fallbackTexture and type(texture.SetTexture) == "function" then
        texture:SetTexture(fallbackTexture)
        return "texture"
    end
    return nil
end

local function ApplyConfiguredMapPinIcon(texture, addon)
    local iconOption
    if addon and type(addon.GetMapPinIconOption) == "function" then
        iconOption = addon:GetMapPinIconOption()
    end
    iconOption = type(iconOption) == "table" and iconOption or {
        atlas = "VignetteLoot",
        texture = "Interface\\Icons\\INV_Misc_Map02",
    }

    -- Prefer the concrete file texture. SetAtlas can succeed without producing
    -- visible art on some map/atlas combinations, which leaves a valid pin
    -- frame looking empty in Icons mode.
    local textureKind
    if iconOption.texture then
        textureKind = ApplyMapPinTexture(texture, nil, iconOption.texture)
    else
        textureKind = ApplyMapPinTexture(texture, iconOption.atlas, nil)
    end
    if textureKind ~= "atlas" and texture and texture.SetTexCoord then
        texture:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    end
    if texture and texture.SetVertexColor then
        texture:SetVertexColor(1, 1, 1, 1)
    end
    if texture and texture.SetAlpha then
        texture:SetAlpha(1)
    end
    return textureKind
end

local function ApplyMapPinDataIcon(texture, pinData, addon)
    if type(pinData) == "table" and HasText(pinData.mapIconAtlas) then
        local textureKind = ApplyMapPinTexture(texture, pinData.mapIconAtlas, nil)
        if textureKind then
            return textureKind
        end
    end
    return ApplyConfiguredMapPinIcon(texture, addon)
end

local function GetMapPin(frame, index)
    frame.mapPinFrames = frame.mapPinFrames or {}
    local pin = frame.mapPinFrames[index]
    if not pin then
        if type(CreateFrame) ~= "function" or not frame.mapContent then
            return nil
        end
        pin = CreateFrame("Button", nil, frame.mapContent)
        pin:SetSize(MAP_PIN_SIZE, MAP_PIN_SIZE)
        if pin.RegisterForClicks then
            pin:RegisterForClicks("LeftButtonUp", "RightButtonUp")
        end

        local ring = pin:CreateTexture(nil, "OVERLAY", nil, MAP_PIN_RING_SUBLEVEL)
        ring:SetPoint("CENTER", pin, "CENTER")
        ring:SetSize(MAP_PIN_RING_SIZE, MAP_PIN_RING_SIZE)
        ApplyMapPinTexture(ring, "worldquest-icon-ring", "Interface\\Minimap\\MiniMap-TrackingBorder")
        if ring.SetVertexColor then
            ring:SetVertexColor(0.28, 0.68, 1.0, 0.95)
        end
        pin.ring = ring

        local icon = pin:CreateTexture(nil, "OVERLAY", nil, MAP_PIN_ICON_SUBLEVEL)
        icon:SetPoint("CENTER", pin, "CENTER")
        icon:SetSize(MAP_PIN_ICON_SIZE, MAP_PIN_ICON_SIZE)
        pin.icon = icon

        local orderBackground = pin:CreateTexture(nil, "OVERLAY", nil, MAP_PIN_ORDER_BACKGROUND_SUBLEVEL)
        orderBackground:SetPoint("CENTER", pin, "CENTER")
        orderBackground:SetSize(MAP_PIN_ICON_SIZE + 2, MAP_PIN_ICON_SIZE + 2)
        orderBackground:SetColorTexture(0.04, 0.09, 0.07, 0.96)
        orderBackground:Hide()
        pin.orderBackground = orderBackground

        local orderText = pin:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        if orderText.SetDrawLayer then
            orderText:SetDrawLayer("OVERLAY", MAP_PIN_ORDER_TEXT_SUBLEVEL)
        end
        orderText:SetPoint("CENTER", pin, "CENTER", 0, 0)
        orderText:SetTextColor(1.0, 0.82, 0.18, 1)
        orderText:Hide()
        pin.orderText = orderText

        pin:SetScript("OnEnter", function(self)
            if not GameTooltip or not self.pinData then
                return
            end
            GameTooltip:SetOwner(self, "ANCHOR_LEFT")
            GameTooltip:SetText(self.pinData.label or GetPinTitle(self.pinData), 1.0, 0.82, 0.18)
            if tonumber(self.pinData.routeOrder) then
                GameTooltip:AddDoubleLine(
                    "Route stop",
                    string.format("%d of %d", self.pinData.routeOrder, self.pinData.routeTotal or self.pinData.routeOrder),
                    0.72, 0.86, 1.0,
                    1.0, 0.82, 0.18
                )
            end
            local targetName = GetPinTargetName(self.pinData)
            GameTooltip:AddLine(InferFarmAction({
                farmAction = self.pinData.farmAction,
                routeType = self.pinData.routeType,
                targetType = self.pinData.targetType,
                targets = targetName and { targetName } or nil,
            }), 1.0, 0.45, 0.20, true)
            if HasText(self.pinData.spotLocation) then
                GameTooltip:AddLine(self.pinData.spotLocation, 0.82, 0.86, 0.92, true)
            end
            GameTooltip:AddDoubleLine(
                "Coordinates",
                string.format("%.1f, %.1f", (self.pinData.x or 0) * 100, (self.pinData.y or 0) * 100),
                0.72, 0.86, 1.0,
                1, 1, 1
            )
            GameTooltip:Show()
        end)
        pin:SetScript("OnLeave", function()
            if GameTooltip then
                GameTooltip:Hide()
            end
        end)
        pin:SetScript("OnClick", function(_, button)
            if button == "RightButton" then
                GoldTracker:NavigateStandaloneMapToParent()
            elseif button == "LeftButton" then
                GoldTracker:SelectStandaloneMapAreaForPin(pin.pinData)
            end
        end)
        frame.mapPinFrames[index] = pin
    elseif pin.SetParent then
        pin:SetParent(frame.mapContent)
    end
    if pin.SetFrameLevel and frame.mapContent.GetFrameLevel then
        pin:SetFrameLevel((tonumber(frame.mapContent:GetFrameLevel()) or 0) + 40)
    end
    if pin.SetAlpha then
        pin:SetAlpha(1)
    end
    return pin
end

local function HideRouteLines(frame)
    for _, line in ipairs(frame.mapRouteLines or {}) do
        line:Hide()
    end
end

local function HideMapAreas(frame)
    if MapAreaOverlay then
        MapAreaOverlay:Hide(frame, "standaloneMapArea")
        MapAreaOverlay:Hide(frame, "standaloneSelectedMapArea")
    end
end

local function GetTile(frame, index)
    frame.mapTileTextures = frame.mapTileTextures or {}
    local texture = frame.mapTileTextures[index]
    if not texture then
        texture = frame.mapContent:CreateTexture(nil, "BACKGROUND")
        texture:SetHorizTile(false)
        texture:SetVertTile(false)
        frame.mapTileTextures[index] = texture
    end
    return texture
end

local function GetExploredTile(frame, index)
    frame.mapExploredTileTextures = frame.mapExploredTileTextures or {}
    local texture = frame.mapExploredTileTextures[index]
    if not texture then
        texture = frame.mapContent:CreateTexture(nil, "ARTWORK")
        if texture.SetDrawLayer then
            texture:SetDrawLayer("ARTWORK", -1)
        end
        frame.mapExploredTileTextures[index] = texture
    end
    return texture
end

local function GetRouteLine(frame, index)
    frame.mapRouteLines = frame.mapRouteLines or {}
    local line = frame.mapRouteLines[index]
    if not line then
        if not frame.mapContent or type(frame.mapContent.CreateLine) ~= "function" then
            return nil
        end
        line = frame.mapContent:CreateLine(nil, "ARTWORK", nil, 1)
        frame.mapRouteLines[index] = line
    end
    if line.SetParent then
        line:SetParent(frame.mapContent)
    end
    return line
end

local function LoadMapArt(frame, mapID)
    if C_AddOns and C_AddOns.LoadAddOn then
        pcall(C_AddOns.LoadAddOn, "Blizzard_MapCanvas")
    elseif LoadAddOn then
        pcall(LoadAddOn, "Blizzard_MapCanvas")
    end

    if not C_Map or not C_Map.GetMapArtLayers or not C_Map.GetMapArtLayerTextures then
        HideTiles(frame)
        HideExploredTiles(frame)
        SetStatus(frame, "C_Map map art APIs are unavailable.")
        return nil
    end

    local layers = C_Map.GetMapArtLayers(mapID)
    local layer = layers and layers[1]
    if not layer then
        HideTiles(frame)
        HideExploredTiles(frame)
        SetStatus(frame, "No map art layer for " .. tostring(mapID) .. ".")
        return nil
    end

    local textureFileIDs = C_Map.GetMapArtLayerTextures(mapID, 1)
    if type(textureFileIDs) ~= "table" or #textureFileIDs == 0 then
        HideTiles(frame)
        HideExploredTiles(frame)
        SetStatus(frame, "No map tile textures for " .. tostring(mapID) .. ".")
        return nil
    end

    return layer, textureFileIDs
end

local function UpdateCanvasPosition(frame)
    if not frame.mapLayer or not frame.mapViewport or not frame.mapContent then
        return
    end

    local viewportWidth = math.max(frame.mapViewport:GetWidth() or 1, 1)
    local viewportHeight = math.max(frame.mapViewport:GetHeight() or 1, 1)
    local layerWidth = frame.mapLayer.layerWidth or 1
    local layerHeight = frame.mapLayer.layerHeight or 1
    local fitScale = math.min(viewportWidth / layerWidth, viewportHeight / layerHeight)
    local scale = fitScale * ClampZoom(frame.mapZoom)

    frame.mapCurrentScale = scale
    frame.mapContent:SetSize(layerWidth * scale, layerHeight * scale)
    frame.mapContent:ClearAllPoints()
    frame.mapContent:SetPoint("CENTER", frame.mapViewport, "CENTER", frame.mapPanX or 0, frame.mapPanY or 0)
end

local function RenderTiles(frame)
    if not frame.mapLayer or not frame.mapTextureFileIDs then
        return
    end

    local layerWidth = frame.mapLayer.layerWidth or 1
    local layerHeight = frame.mapLayer.layerHeight or 1
    local tileWidth = frame.mapLayer.tileWidth or 256
    local tileHeight = frame.mapLayer.tileHeight or 256
    local cols = math.ceil(layerWidth / tileWidth)
    local rows = math.ceil(layerHeight / tileHeight)
    local scale = frame.mapCurrentScale or 1
    local textureIndex = 1

    HideTiles(frame)
    for row = 1, rows do
        for col = 1, cols do
            local fileID = frame.mapTextureFileIDs[textureIndex]
            if fileID then
                local texture = GetTile(frame, textureIndex)
                local remainingWidth = layerWidth - ((col - 1) * tileWidth)
                local remainingHeight = layerHeight - ((row - 1) * tileHeight)
                local width = math.min(tileWidth, remainingWidth)
                local height = math.min(tileHeight, remainingHeight)
                texture:SetTexture(fileID)
                texture:ClearAllPoints()
                texture:SetPoint("TOPLEFT", frame.mapContent, "TOPLEFT", (col - 1) * tileWidth * scale, -((row - 1) * tileHeight * scale))
                texture:SetSize(width * scale, height * scale)
                texture:Show()
            end
            textureIndex = textureIndex + 1
        end
    end
end

local function RenderExploredTiles(frame)
    if not frame.mapLayer or not frame.mapContent then
        return
    end

    HideExploredTiles(frame)
    if not C_MapExplorationInfo or not C_MapExplorationInfo.GetExploredMapTextures then
        return
    end

    local exploredMapTextures = C_MapExplorationInfo.GetExploredMapTextures(frame.mapID)
    if type(exploredMapTextures) ~= "table" then
        return
    end

    local tileWidth = frame.mapLayer.tileWidth or 256
    local tileHeight = frame.mapLayer.tileHeight or 256
    local scale = frame.mapCurrentScale or 1
    local overlayIndex = 1

    for _, exploredTextureInfo in ipairs(exploredMapTextures) do
        local textureWidth = exploredTextureInfo.textureWidth or 0
        local textureHeight = exploredTextureInfo.textureHeight or 0
        local fileDataIDs = exploredTextureInfo.fileDataIDs
        if textureWidth > 0 and textureHeight > 0 and type(fileDataIDs) == "table" then
            local cols = math.ceil(textureWidth / tileWidth)
            local rows = math.ceil(textureHeight / tileHeight)
            for row = 1, rows do
                local texturePixelHeight = row < rows and tileHeight or (textureHeight % tileHeight)
                if texturePixelHeight == 0 then
                    texturePixelHeight = tileHeight
                end
                local textureFileHeight = 16
                while textureFileHeight < texturePixelHeight do
                    textureFileHeight = textureFileHeight * 2
                end

                for col = 1, cols do
                    local texturePixelWidth = col < cols and tileWidth or (textureWidth % tileWidth)
                    if texturePixelWidth == 0 then
                        texturePixelWidth = tileWidth
                    end
                    local textureFileWidth = 16
                    while textureFileWidth < texturePixelWidth do
                        textureFileWidth = textureFileWidth * 2
                    end

                    local fileID = fileDataIDs[((row - 1) * cols) + col]
                    if fileID then
                        local texture = GetExploredTile(frame, overlayIndex)
                        texture:SetTexture(fileID, nil, nil, "TRILINEAR")
                        texture:SetTexCoord(0, texturePixelWidth / textureFileWidth, 0, texturePixelHeight / textureFileHeight)
                        texture:ClearAllPoints()
                        texture:SetPoint(
                            "TOPLEFT",
                            frame.mapContent,
                            "TOPLEFT",
                            ((exploredTextureInfo.offsetX or 0) + (tileWidth * (col - 1))) * scale,
                            -(((exploredTextureInfo.offsetY or 0) + (tileHeight * (row - 1))) * scale)
                        )
                        texture:SetSize(texturePixelWidth * scale, texturePixelHeight * scale)
                        texture:Show()
                        overlayIndex = overlayIndex + 1
                    end
                end
            end
        end
    end
end

local function HideDetailLines(frame, usedLines)
    local normalizedUsedLines = usedLines or 0
    for index, text in pairs(frame.detailTextLines or {}) do
        if index > normalizedUsedLines then
            text:Hide()
        end
    end
    for index, row in pairs(frame.detailSourceRows or {}) do
        if index > normalizedUsedLines and row then
            row:Hide()
            if row.button then
                row.button.sourceUrl = nil
                row.button.sourceSiteName = nil
                row.button.tooltipText = nil
            end
        end
    end
    for index, row in pairs(frame.detailTableRows or {}) do
        if index > normalizedUsedLines and row then
            row:Hide()
            row.itemID = nil
            row.itemLink = nil
        end
    end
    for index, row in pairs(frame.detailTableFilterRows or {}) do
        if index > normalizedUsedLines and row then
            row:Hide()
            row.onSelect = nil
        end
    end
    for index, row in pairs(frame.detailTableHeaderRows or {}) do
        if index > normalizedUsedLines and row then
            row:Hide()
            row.onSort = nil
        end
    end
    for index, row in pairs(frame.detailToggleRows or {}) do
        if index > normalizedUsedLines and row then
            row:Hide()
            row.onClick = nil
        end
    end
    for index, row in pairs(frame.detailButtonRows or {}) do
        if index > normalizedUsedLines and row then
            row:Hide()
            row.onClick = nil
        end
    end
    for index, divider in pairs(frame.detailDividerLines or {}) do
        if index > normalizedUsedLines and divider then
            divider:Hide()
        end
    end
end

local function GetDetailLine(frame, index)
    frame.detailTextLines = frame.detailTextLines or {}
    local text = frame.detailTextLines[index]
    if not text then
        text = frame.detailsContent:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        text:SetJustifyH("LEFT")
        text:SetJustifyV("TOP")
        frame.detailTextLines[index] = text
    end
    text:SetWordWrap(true)
    if text.SetNonSpaceWrap then
        text:SetNonSpaceWrap(true)
    end
    if text.SetMaxLines then
        text:SetMaxLines(0)
    end
    return text
end

local function GetDetailDivider(frame, index)
    frame.detailDividerLines = frame.detailDividerLines or {}
    local divider = frame.detailDividerLines[index]
    if not divider then
        divider = frame.detailsContent:CreateLine(nil, "ARTWORK", nil, 2)
        divider:SetThickness(2)
        divider:SetColorTexture(1.0, 0.82, 0.18, 0.85)
        frame.detailDividerLines[index] = divider
    end
    return divider
end

local function ShowSourceLinkWindow(url, siteName)
    if not HasText(url) then
        return
    end

    local frame = GoldTracker.standaloneMapSourceLinkFrame
    if not frame then
        frame = CreateFrame("Frame", "GoldTrackerStandaloneMapSourceLinkFrame", UIParent)
        frame:SetSize(620, 200)
        frame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
        frame:SetFrameStrata("TOOLTIP")
        frame:SetClampedToScreen(true)
        frame:SetMovable(true)
        frame:EnableMouse(true)
        frame:RegisterForDrag("LeftButton")
        frame:SetScript("OnDragStart", frame.StartMoving)
        frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
        local chrome = Theme:ApplyWindowChrome(frame, "Source Link")

        local body = CreatePanel(frame, "body", "goldBorder")
        body:SetPoint("TOPLEFT", chrome, "TOPLEFT", 12, -54)
        body:SetPoint("BOTTOMRIGHT", chrome, "BOTTOMRIGHT", -12, 12)

        local label = body:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        label:SetPoint("TOPLEFT", body, "TOPLEFT", 12, -12)
        label:SetPoint("TOPRIGHT", body, "TOPRIGHT", -12, -12)
        label:SetJustifyH("LEFT")

        local editBox = CreateFrame("EditBox", nil, body, "InputBoxTemplate")
        editBox:SetPoint("TOPLEFT", label, "BOTTOMLEFT", 0, -12)
        editBox:SetPoint("TOPRIGHT", body, "TOPRIGHT", -12, -42)
        editBox:SetHeight(24)
        editBox:SetAutoFocus(false)
        editBox:SetScript("OnEditFocusGained", function(self)
            self:HighlightText()
        end)
        editBox:SetScript("OnMouseUp", function(self)
            self:HighlightText()
        end)
        editBox:SetScript("OnEscapePressed", function(self)
            self:ClearFocus()
        end)

        local closeButton = CreateButton(body, 78, 24, "Close", "neutral")
        closeButton:SetPoint("BOTTOMRIGHT", body, "BOTTOMRIGHT", -12, 12)
        closeButton:SetScript("OnClick", function()
            frame:Hide()
        end)

        frame.body = body
        frame.sourceLabel = label
        frame.sourceUrlEditBox = editBox
        GoldTracker.standaloneMapSourceLinkFrame = frame
    end

    if frame.sourceLabel then
        frame.sourceLabel:SetText("Copy " .. (siteName or "source") .. " link")
    end
    frame:Show()
    frame:Raise()
    if frame.sourceUrlEditBox then
        frame.sourceUrlEditBox:SetText(url)
        frame.sourceUrlEditBox:SetFocus()
        frame.sourceUrlEditBox:HighlightText()
    end
end

local function GetDetailSourceRow(frame, index)
    frame.detailSourceRows = frame.detailSourceRows or {}
    local row = frame.detailSourceRows[index]
    if not row then
        row = CreateFrame("Frame", nil, frame.detailsContent)
        row:SetHeight(SOURCE_ROW_HEIGHT)

        local label = row:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        label:SetPoint("LEFT", row, "LEFT", 0, 0)
        label:SetPoint("RIGHT", row, "RIGHT", -(SOURCE_BUTTON_WIDTH + 8), 0)
        label:SetJustifyH("LEFT")
        label:SetWordWrap(false)
        row.label = label

        local button = CreateButton(row, SOURCE_BUTTON_WIDTH, 22, "Open", "neutral")
        button:SetPoint("RIGHT", row, "RIGHT", 0, 0)
        button:SetScript("OnClick", function(self)
            ShowSourceLinkWindow(self.sourceUrl, self.sourceSiteName)
        end)
        row.button = button

        frame.detailSourceRows[index] = row
    end
    return row
end

local function ScrollStandaloneMapDetails(scrollFrame, delta)
    if not scrollFrame then
        return
    end
    local step = 38
    local current = scrollFrame:GetVerticalScroll() or 0
    local maxScroll = scrollFrame:GetVerticalScrollRange() or 0
    scrollFrame:SetVerticalScroll(math.max(0, math.min(maxScroll, current - (delta * step))))
end

local function GetDetailTableFilterRow(frame, index)
    frame.detailTableFilterRows = frame.detailTableFilterRows or {}
    local row = frame.detailTableFilterRows[index]
    if not row then
        row = CreateFrame("Frame", nil, frame.detailsContent)
        row:SetHeight(DETAIL_TABLE_FILTER_ROW_HEIGHT)
        if type(row.EnableMouseWheel) == "function" then
            row:EnableMouseWheel(true)
            row:SetScript("OnMouseWheel", function(_, delta)
                ScrollStandaloneMapDetails(frame.detailsScrollFrame, delta)
            end)
        end

        local label = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        label:SetPoint("LEFT", row, "LEFT", 0, 0)
        label:SetText("Show")
        row.label = label

        local dropdown = CreateFrame("Frame", nil, row, "UIDropDownMenuTemplate")
        dropdown:SetPoint("LEFT", row, "LEFT", 26, 0)
        row.dropdown = dropdown
        frame.detailTableFilterRows[index] = row
    end
    return row
end

local DETAIL_TABLE_HEADERS = {
    { key = "itemName", label = "Item", justify = "LEFT" },
    { key = "itemType", label = "Type", justify = "LEFT", width = DETAIL_TABLE_TYPE_WIDTH },
    { key = "quantity", label = "Qty", justify = "RIGHT", width = DETAIL_TABLE_QUANTITY_WIDTH },
    { key = "totalValue", label = "Value", justify = "RIGHT", width = DETAIL_TABLE_VALUE_WIDTH },
}

local function GetDetailTableHeaderRow(frame, index)
    frame.detailTableHeaderRows = frame.detailTableHeaderRows or {}
    local row = frame.detailTableHeaderRows[index]
    if not row then
        row = CreateFrame("Frame", nil, frame.detailsContent)
        row:SetHeight(DETAIL_TABLE_HEADER_ROW_HEIGHT)
        if type(row.EnableMouseWheel) == "function" then
            row:EnableMouseWheel(true)
            row:SetScript("OnMouseWheel", function(_, delta)
                ScrollStandaloneMapDetails(frame.detailsScrollFrame, delta)
            end)
        end
        row.buttons = {}

        local previousButton
        for headerIndex = #DETAIL_TABLE_HEADERS, 1, -1 do
            local header = DETAIL_TABLE_HEADERS[headerIndex]
            local button = CreateFrame("Button", nil, row)
            button:SetHeight(DETAIL_TABLE_HEADER_ROW_HEIGHT)
            if header.width then
                button:SetWidth(header.width)
            end
            if previousButton then
                button:SetPoint("RIGHT", previousButton, "LEFT", -DETAIL_TABLE_COLUMN_GAP, 0)
            else
                button:SetPoint("RIGHT", row, "RIGHT", 0, 0)
            end
            if headerIndex == 1 then
                button:SetPoint("LEFT", row, "LEFT", 0, 0)
            end

            local text = button:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
            text:SetPoint("LEFT", button, "LEFT", 0, 0)
            text:SetPoint("RIGHT", button, "RIGHT", 0, 0)
            text:SetJustifyH(header.justify)
            text:SetWordWrap(false)
            button.label = text
            button.sortKey = header.key
            button:SetScript("OnClick", function(self)
                if type(row.onSort) == "function" then
                    row.onSort(self.sortKey)
                end
            end)
            button:SetScript("OnEnter", function(self)
                self.label:SetTextColor(1.0, 0.82, 0.18, 1)
            end)
            button:SetScript("OnLeave", function(self)
                local selected = row.sortKey == self.sortKey
                self.label:SetTextColor(
                    selected and 1.0 or 0.72,
                    selected and 0.82 or 0.76,
                    selected and 0.18 or 0.84,
                    1
                )
            end)
            row.buttons[header.key] = button
            previousButton = button
        end
        frame.detailTableHeaderRows[index] = row
    end
    return row
end

local function UpdateDetailTableHeaderRow(row, sortKey, sortAscending)
    row.sortKey = sortKey
    for _, header in ipairs(DETAIL_TABLE_HEADERS) do
        local button = row.buttons and row.buttons[header.key]
        if button then
            local selected = header.key == sortKey
            local suffix = selected and (sortAscending and " ^" or " v") or ""
            button.label:SetText(header.label .. suffix)
            button.label:SetTextColor(selected and 1.0 or 0.72, selected and 0.82 or 0.76, selected and 0.18 or 0.84, 1)
        end
    end
end

local function GetDetailTableRow(frame, index)
    frame.detailTableRows = frame.detailTableRows or {}
    local row = frame.detailTableRows[index]
    if not row then
        row = CreateFrame("Frame", nil, frame.detailsContent)
        row:SetHeight(DETAIL_TABLE_ROW_HEIGHT)
        if type(row.EnableMouse) == "function" then
            row:EnableMouse(true)
        end
        if type(row.EnableMouseWheel) == "function" then
            row:EnableMouseWheel(true)
            row:SetScript("OnMouseWheel", function(_, delta)
                ScrollStandaloneMapDetails(frame.detailsScrollFrame, delta)
            end)
        end
        row:SetScript("OnEnter", function(self)
            if not GameTooltip or not self.itemID then
                return
            end
            GameTooltip:SetOwner(self, "ANCHOR_CURSOR")
            if HasText(self.itemLink) then
                GameTooltip:SetHyperlink(self.itemLink)
            elseif type(GameTooltip.SetItemByID) == "function" then
                GameTooltip:SetItemByID(self.itemID)
            elseif type(GameTooltip.SetHyperlink) == "function" then
                GameTooltip:SetHyperlink("item:" .. tostring(self.itemID))
            end
            if type(GameTooltip.Show) == "function" then
                GameTooltip:Show()
            end
        end)
        row:SetScript("OnLeave", function()
            if GameTooltip then
                GameTooltip:Hide()
            end
        end)

        local valueText = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        valueText:SetPoint("RIGHT", row, "RIGHT", 0, 0)
        valueText:SetWidth(DETAIL_TABLE_VALUE_WIDTH)
        valueText:SetJustifyH("RIGHT")
        valueText:SetWordWrap(false)
        row.valueText = valueText

        local quantityText = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        quantityText:SetPoint("RIGHT", valueText, "LEFT", -DETAIL_TABLE_COLUMN_GAP, 0)
        quantityText:SetWidth(DETAIL_TABLE_QUANTITY_WIDTH)
        quantityText:SetJustifyH("RIGHT")
        quantityText:SetWordWrap(false)
        row.quantityText = quantityText

        local typeText = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        typeText:SetPoint("RIGHT", quantityText, "LEFT", -DETAIL_TABLE_COLUMN_GAP, 0)
        typeText:SetWidth(DETAIL_TABLE_TYPE_WIDTH)
        typeText:SetJustifyH("LEFT")
        typeText:SetWordWrap(false)
        row.typeText = typeText

        local itemText = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        itemText:SetPoint("LEFT", row, "LEFT", 0, 0)
        itemText:SetPoint("RIGHT", typeText, "LEFT", -DETAIL_TABLE_COLUMN_GAP, 0)
        itemText:SetJustifyH("LEFT")
        itemText:SetWordWrap(false)
        row.itemText = itemText

        frame.detailTableRows[index] = row
    end
    return row
end

local function HideStandardDetailRowsAtIndex(frame, index)
    local text = frame.detailTextLines and frame.detailTextLines[index]
    if text then
        text:Hide()
    end
    local sourceRow = frame.detailSourceRows and frame.detailSourceRows[index]
    if sourceRow then
        sourceRow:Hide()
    end
    local tableRow = frame.detailTableRows and frame.detailTableRows[index]
    if tableRow then
        tableRow:Hide()
        tableRow.itemID = nil
        tableRow.itemLink = nil
    end
    local toggleRow = frame.detailToggleRows and frame.detailToggleRows[index]
    if toggleRow then
        toggleRow:Hide()
        toggleRow.onClick = nil
    end
end

local function GetDetailToggleRow(frame, index)
    frame.detailToggleRows = frame.detailToggleRows or {}
    local row = frame.detailToggleRows[index]
    if not row then
        row = CreateFrame("Button", nil, frame.detailsContent)
        row:SetHeight(DETAIL_TOGGLE_ROW_HEIGHT)
        if type(row.EnableMouseWheel) == "function" then
            row:EnableMouseWheel(true)
            row:SetScript("OnMouseWheel", function(_, delta)
                ScrollStandaloneMapDetails(frame.detailsScrollFrame, delta)
            end)
        end

        local label = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        label:SetPoint("LEFT", row, "LEFT", 0, 0)
        label:SetPoint("RIGHT", row, "RIGHT", 0, 0)
        label:SetJustifyH("LEFT")
        label:SetWordWrap(false)
        row.label = label

        row:SetScript("OnClick", function(self)
            if type(self.onClick) == "function" then
                self.onClick()
            end
        end)
        row:SetScript("OnEnter", function(self)
            self.label:SetTextColor(1.0, 0.82, 0.18, 1)
        end)
        row:SetScript("OnLeave", function(self)
            self.label:SetTextColor(0.68, 0.72, 0.80, 1)
        end)

        frame.detailToggleRows[index] = row
    end
    return row
end

local function GetDetailButtonRow(frame, index)
    frame.detailButtonRows = frame.detailButtonRows or {}
    local row = frame.detailButtonRows[index]
    if not row then
        row = CreateFrame("Frame", nil, frame.detailsContent)
        row:SetHeight(DETAIL_BUTTON_ROW_HEIGHT)
        if type(row.EnableMouseWheel) == "function" then
            row:EnableMouseWheel(true)
            row:SetScript("OnMouseWheel", function(_, delta)
                ScrollStandaloneMapDetails(frame.detailsScrollFrame, delta)
            end)
        end

        local button = CreateButton(row, DETAIL_BUTTON_WIDTH, 24, "View all recorded items", "neutral")
        button:SetPoint("LEFT", row, "LEFT", 0, 0)
        button:SetScript("OnClick", function()
            if type(row.onClick) == "function" then
                row.onClick()
            end
        end)
        row.button = button
        frame.detailButtonRows[index] = row
    end
    return row
end

local function RefreshStandaloneMapDetails(frame)
    if not frame or not frame.detailsContent or not frame.detailsScrollFrame then
        return
    end

    local option = GetSelectedMapOption(frame)
    local mapLabel = (option and (option.mapLabel or option.label)) or GetMapName(frame.mapID)
    local lines
    if type(frame.detailLinesBuilder) == "function" then
        local ok, customLines = pcall(frame.detailLinesBuilder, option, frame.mapID, mapLabel)
        if ok and type(customLines) == "table" then
            lines = customLines
        end
    end
    lines = lines or GoldTracker:BuildStandaloneMapDetailLines(frame.mapPins, frame.mapID, mapLabel)
    local scrollWidth = frame.detailsScrollFrame:GetWidth() or 0
    if scrollWidth <= 1 then
        scrollWidth = DETAILS_PANEL_WIDTH - (DETAILS_CONTENT_PADDING * 2) - 24
    end
    local contentWidth = math.max(1, math.floor(scrollWidth - 8))
    local yOffset = 0

    for index, line in ipairs(lines) do
        local lineHeight = 18
        local existingDivider = frame.detailDividerLines and frame.detailDividerLines[index]
        if existingDivider and line.type ~= "divider" then
            existingDivider:Hide()
        end
        local existingFilterRow = frame.detailTableFilterRows and frame.detailTableFilterRows[index]
        if existingFilterRow and line.type ~= "farmTargetFilter" then
            existingFilterRow:Hide()
            existingFilterRow.onSelect = nil
        end
        local existingHeaderRow = frame.detailTableHeaderRows and frame.detailTableHeaderRows[index]
        if existingHeaderRow and line.type ~= "farmTargetHeader" then
            existingHeaderRow:Hide()
            existingHeaderRow.onSort = nil
        end
        local existingButtonRow = frame.detailButtonRows and frame.detailButtonRows[index]
        if existingButtonRow and line.type ~= "detailButton" then
            existingButtonRow:Hide()
            existingButtonRow.onClick = nil
        end
        if line.type == "source" then
            local text = frame.detailTextLines and frame.detailTextLines[index]
            if text then
                text:Hide()
            end
            local tableRow = frame.detailTableRows and frame.detailTableRows[index]
            if tableRow then
                tableRow:Hide()
                tableRow.itemID = nil
                tableRow.itemLink = nil
            end
            local toggleRow = frame.detailToggleRows and frame.detailToggleRows[index]
            if toggleRow then
                toggleRow:Hide()
                toggleRow.onClick = nil
            end

            local row = GetDetailSourceRow(frame, index)
            row:ClearAllPoints()
            row:SetPoint("TOPLEFT", frame.detailsContent, "TOPLEFT", 0, -yOffset)
            row:SetWidth(contentWidth)
            row.label:SetText(line.siteName or "Source")
            row.button.sourceUrl = line.url
            row.button.sourceSiteName = line.siteName
            row.button.tooltipText = line.url
            row:Show()
            lineHeight = SOURCE_ROW_HEIGHT
        elseif line.type == "divider" then
            local text = frame.detailTextLines and frame.detailTextLines[index]
            if text then
                text:Hide()
            end
            local sourceRow = frame.detailSourceRows and frame.detailSourceRows[index]
            if sourceRow then
                sourceRow:Hide()
            end
            local tableRow = frame.detailTableRows and frame.detailTableRows[index]
            if tableRow then
                tableRow:Hide()
                tableRow.itemID = nil
                tableRow.itemLink = nil
            end
            local toggleRow = frame.detailToggleRows and frame.detailToggleRows[index]
            if toggleRow then
                toggleRow:Hide()
                toggleRow.onClick = nil
            end

            local divider = GetDetailDivider(frame, index)
            divider:ClearAllPoints()
            local dividerOffset = -(yOffset + math.floor(DETAIL_DIVIDER_ROW_HEIGHT / 2))
            divider:SetStartPoint("TOPLEFT", frame.detailsContent, 0, dividerOffset)
            divider:SetEndPoint("TOPRIGHT", frame.detailsContent, 0, dividerOffset)
            divider:Show()
            lineHeight = DETAIL_DIVIDER_ROW_HEIGHT
        elseif line.type == "farmTargetFilter" then
            HideStandardDetailRowsAtIndex(frame, index)
            local row = GetDetailTableFilterRow(frame, index)
            row:ClearAllPoints()
            row:SetPoint("TOPLEFT", frame.detailsContent, "TOPLEFT", 0, -yOffset)
            row:SetWidth(contentWidth)
            row.onSelect = line.onSelect
            row.selectedFilter = line.selectedFilter or "all"
            row.filterOptions = line.filterOptions or {}
            if type(UIDropDownMenu_SetWidth) == "function" then
                UIDropDownMenu_SetWidth(row.dropdown, math.max(100, contentWidth - 54))
            end
            if type(UIDropDownMenu_Initialize) == "function" then
                local filterRow = row
                UIDropDownMenu_Initialize(row.dropdown, function(_, level)
                    for _, filterOption in ipairs(filterRow.filterOptions or {}) do
                        local info = type(UIDropDownMenu_CreateInfo) == "function" and UIDropDownMenu_CreateInfo() or {}
                        local filterID = filterOption.id
                        info.text = filterOption.label
                        info.value = filterID
                        info.checked = filterRow.selectedFilter == filterID
                        info.func = function()
                            if type(filterRow.onSelect) == "function" then
                                filterRow.onSelect(filterID)
                            end
                        end
                        if type(UIDropDownMenu_AddButton) == "function" then
                            UIDropDownMenu_AddButton(info, level)
                        end
                    end
                end)
            end
            if type(UIDropDownMenu_SetSelectedValue) == "function" then
                UIDropDownMenu_SetSelectedValue(row.dropdown, row.selectedFilter)
            end
            if type(UIDropDownMenu_SetText) == "function" then
                local selectedLabel = "All"
                for _, filterOption in ipairs(row.filterOptions) do
                    if filterOption.id == row.selectedFilter then
                        selectedLabel = filterOption.label
                        break
                    end
                end
                UIDropDownMenu_SetText(row.dropdown, selectedLabel)
            end
            row:Show()
            lineHeight = DETAIL_TABLE_FILTER_ROW_HEIGHT
        elseif line.type == "farmTargetHeader" then
            HideStandardDetailRowsAtIndex(frame, index)
            local row = GetDetailTableHeaderRow(frame, index)
            row:ClearAllPoints()
            row:SetPoint("TOPLEFT", frame.detailsContent, "TOPLEFT", 0, -yOffset)
            row:SetWidth(contentWidth)
            row.onSort = line.onSort
            UpdateDetailTableHeaderRow(row, line.sortKey or "itemName", line.sortAscending ~= false)
            row:Show()
            lineHeight = DETAIL_TABLE_HEADER_ROW_HEIGHT
        elseif line.type == "farmTarget" then
            local text = frame.detailTextLines and frame.detailTextLines[index]
            if text then
                text:Hide()
            end
            local sourceRow = frame.detailSourceRows and frame.detailSourceRows[index]
            if sourceRow then
                sourceRow:Hide()
                if sourceRow.button then
                    sourceRow.button.sourceUrl = nil
                    sourceRow.button.sourceSiteName = nil
                    sourceRow.button.tooltipText = nil
                end
            end
            local toggleRow = frame.detailToggleRows and frame.detailToggleRows[index]
            if toggleRow then
                toggleRow:Hide()
                toggleRow.onClick = nil
            end

            local row = GetDetailTableRow(frame, index)
            row:ClearAllPoints()
            row:SetPoint("TOPLEFT", frame.detailsContent, "TOPLEFT", 0, -yOffset)
            row:SetWidth(contentWidth)
            row.itemID = tonumber(line.itemID)
            row.itemLink = line.itemLink
            row.itemText:SetText(line.itemName or "Unknown item")
            row.typeText:SetText(line.itemType or "Other")
            row.quantityText:SetText(line.quantityText or "")
            row.valueText:SetText(line.totalValueText or "unavailable")
            local r = line.selected and 0.45 or 0.82
            local g = line.selected and 0.92 or 0.86
            local b = line.selected and 1.0 or 0.92
            row.itemText:SetTextColor(r, g, b, 1)
            row.typeText:SetTextColor(r, g, b, 1)
            row.quantityText:SetTextColor(r, g, b, 1)
            row.valueText:SetTextColor(r, g, b, 1)
            row:Show()
            lineHeight = DETAIL_TABLE_ROW_HEIGHT
        elseif line.type == "detailButton" then
            HideStandardDetailRowsAtIndex(frame, index)
            local row = GetDetailButtonRow(frame, index)
            row:ClearAllPoints()
            row:SetPoint("TOPLEFT", frame.detailsContent, "TOPLEFT", 0, -yOffset)
            row:SetWidth(contentWidth)
            row.button:SetText(line.text or "View all recorded items")
            row.onClick = line.onClick
            row:Show()
            lineHeight = DETAIL_BUTTON_ROW_HEIGHT
        elseif line.type == "detailToggle" then
            local text = frame.detailTextLines and frame.detailTextLines[index]
            if text then
                text:Hide()
            end
            local sourceRow = frame.detailSourceRows and frame.detailSourceRows[index]
            if sourceRow then
                sourceRow:Hide()
            end
            local tableRow = frame.detailTableRows and frame.detailTableRows[index]
            if tableRow then
                tableRow:Hide()
                tableRow.itemID = nil
                tableRow.itemLink = nil
            end

            local row = GetDetailToggleRow(frame, index)
            row:ClearAllPoints()
            row:SetPoint("TOPLEFT", frame.detailsContent, "TOPLEFT", 0, -yOffset)
            row:SetWidth(contentWidth)
            row.label:SetText(line.text or "")
            row.label:SetTextColor(0.68, 0.72, 0.80, 1)
            row.onClick = line.onClick
            row:Show()
            lineHeight = DETAIL_TOGGLE_ROW_HEIGHT
        else
            local row = frame.detailSourceRows and frame.detailSourceRows[index]
            if row then
                row:Hide()
                if row.button then
                    row.button.sourceUrl = nil
                    row.button.sourceSiteName = nil
                    row.button.tooltipText = nil
                end
            end
            local tableRow = frame.detailTableRows and frame.detailTableRows[index]
            if tableRow then
                tableRow:Hide()
                tableRow.itemID = nil
                tableRow.itemLink = nil
            end
            local toggleRow = frame.detailToggleRows and frame.detailToggleRows[index]
            if toggleRow then
                toggleRow:Hide()
                toggleRow.onClick = nil
            end

            local text = GetDetailLine(frame, index)
            text:ClearAllPoints()
            text:SetPoint("TOPLEFT", frame.detailsContent, "TOPLEFT", 0, -yOffset)
            text:SetWidth(contentWidth)
            if text.SetFontObject and line.fontObject and _G[line.fontObject] then
                text:SetFontObject(_G[line.fontObject])
            end
            text:SetWordWrap(true)
            if text.SetNonSpaceWrap then
                text:SetNonSpaceWrap(true)
            end
            if text.SetMaxLines then
                text:SetMaxLines(0)
            end
            text:SetHeight(DETAIL_TEXT_MEASURE_HEIGHT)
            text:SetTextColor(line.r or 0.82, line.g or 0.86, line.b or 0.92, 1)
            text:SetText(line.text or "")
            text:Show()

            if text.GetStringHeight then
                lineHeight = math.max(lineHeight, math.ceil(text:GetStringHeight() or lineHeight) + DETAIL_TEXT_HEIGHT_PADDING)
            end
            text:SetHeight(lineHeight)
        end
        yOffset = yOffset + lineHeight + (line.gap or 4)
    end

    HideDetailLines(frame, #lines)
    frame.detailsContent:SetSize(contentWidth, math.max(1, yOffset + DETAILS_CONTENT_PADDING))
    if frame.detailsScrollFrame.UpdateScrollChildRect then
        frame.detailsScrollFrame:UpdateScrollChildRect()
    end
end

function GoldTracker:CreateRecordedYieldsWindow()
    if self.recordedYieldsFrame then
        return self.recordedYieldsFrame
    end

    local frame = CreateFrame("Frame", "GoldTrackerRecordedYieldsFrame", UIParent)
    frame:SetSize(RECORDED_YIELDS_WINDOW_WIDTH, RECORDED_YIELDS_WINDOW_HEIGHT)
    frame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    frame:SetFrameStrata("DIALOG")
    if frame.SetToplevel then
        frame:SetToplevel(true)
    end
    frame:SetClampedToScreen(true)
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
    frame:SetScript("OnHide", function()
        local request = GoldTracker.recordedYieldsValuationRequest
        if request then
            request.cancelled = true
            if request.asyncTask then
                request.asyncTask.cancelled = true
            end
            GoldTracker.recordedYieldsValuationRequest = nil
        end
    end)
    frame:RegisterEvent("GET_ITEM_INFO_RECEIVED")
    frame:RegisterEvent("ITEM_DATA_LOAD_RESULT")
    frame:SetScript("OnEvent", function(self, _, itemID)
        if self:IsShown()
            and type(GoldTracker.CompleteFarmItemDataRequest) == "function"
            and GoldTracker:CompleteFarmItemDataRequest(itemID)
        then
            GoldTracker:RefreshRecordedYieldsWindow()
        end
    end)
    frame:Hide()

    local chrome
    if Theme and type(Theme.ApplyWindowChrome) == "function" then
        chrome = Theme:ApplyWindowChrome(frame, "Recorded Yields")
        Theme:RegisterSpecialFrame("GoldTrackerRecordedYieldsFrame")
    else
        chrome = frame
        if frame.TitleText then
            frame.TitleText:SetText("Recorded Yields")
        end
    end

    local body = CreatePanel(frame, "body", "goldBorder")
    body:SetPoint("TOPLEFT", chrome, "TOPLEFT", 12, -54)
    body:SetPoint("BOTTOMRIGHT", chrome, "BOTTOMRIGHT", -12, 12)

    local farmTitle = body:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    farmTitle:SetPoint("TOPLEFT", body, "TOPLEFT", DETAILS_CONTENT_PADDING, -DETAILS_CONTENT_PADDING)
    farmTitle:SetPoint("TOPRIGHT", body, "TOPRIGHT", -DETAILS_CONTENT_PADDING, -DETAILS_CONTENT_PADDING)
    farmTitle:SetJustifyH("LEFT")
    farmTitle:SetWordWrap(false)

    local detailsScrollFrame = CreateFrame("ScrollFrame", nil, body, "UIPanelScrollFrameTemplate")
    detailsScrollFrame:SetPoint("TOPLEFT", farmTitle, "BOTTOMLEFT", 0, -10)
    detailsScrollFrame:SetPoint("BOTTOMRIGHT", body, "BOTTOMRIGHT", -30, DETAILS_CONTENT_PADDING)
    detailsScrollFrame:EnableMouseWheel(true)
    detailsScrollFrame:SetScript("OnMouseWheel", function(self, delta)
        ScrollStandaloneMapDetails(self, delta)
    end)

    local detailsContent = CreateFrame("Frame", nil, detailsScrollFrame)
    detailsContent:SetPoint("TOPLEFT", detailsScrollFrame, "TOPLEFT", 0, 0)
    detailsContent:SetSize(1, 1)
    detailsScrollFrame:SetScrollChild(detailsContent)

    frame.body = body
    frame.farmTitle = farmTitle
    frame.detailsScrollFrame = detailsScrollFrame
    frame.detailsContent = detailsContent
    frame.detailTextLines = {}
    frame.detailSourceRows = {}
    frame.detailTableRows = {}
    frame.detailTableFilterRows = {}
    frame.detailTableHeaderRows = {}
    frame.detailToggleRows = {}
    frame.detailButtonRows = {}
    frame.detailDividerLines = {}
    self.recordedYieldsFrame = frame
    return frame
end

function GoldTracker:RefreshRecordedYieldsWindow()
    local frame = self.recordedYieldsFrame
    if frame then
        RefreshStandaloneMapDetails(frame)
    end
end

function GoldTracker:OpenRecordedYieldsWindow(options)
    options = type(options) == "table" and options or {}
    local frame = self:CreateRecordedYieldsWindow()
    frame.detailLinesBuilder = type(options.detailLinesBuilder) == "function" and options.detailLinesBuilder or nil
    frame.farmTitle:SetText((options.title or "Farm") .. " - all recorded items")
    frame.detailsScrollFrame:SetVerticalScroll(0)
    frame:Show()
    if Theme and type(Theme.BringManagedWindowToFront) == "function" then
        Theme:BringManagedWindowToFront(frame)
    else
        frame:Raise()
    end
    self:RefreshRecordedYieldsWindow()
    return frame
end

local function RenderRouteLines(frame)
    HideRouteLines(frame)
    if not frame.mapLayer or not frame.mapContent then
        return 0
    end

    local scale = frame.mapCurrentScale or 1
    local layerWidth = frame.mapLayer.layerWidth or 1
    local layerHeight = frame.mapLayer.layerHeight or 1
    local previousPin
    local lineIndex = 1
    for _, pinData in ipairs(frame.mapPins or {}) do
        if tonumber(pinData.mapID) == tonumber(frame.mapID) then
            if pinData.isRoute == true
                and previousPin
                and previousPin.isRoute == true
                and previousPin.routeID == pinData.routeID
            then
                local line = GetRouteLine(frame, lineIndex)
                if line then
                    line:ClearAllPoints()
                    line:SetStartPoint("TOPLEFT", frame.mapContent, previousPin.x * layerWidth * scale, -(previousPin.y * layerHeight * scale))
                    line:SetEndPoint("TOPLEFT", frame.mapContent, pinData.x * layerWidth * scale, -(pinData.y * layerHeight * scale))
                    if line.SetThickness then
                        line:SetThickness(ROUTE_LINE_THICKNESS)
                    end
                    if line.SetColorTexture then
                        line:SetColorTexture(1.0, 0.82, 0.18, 0.62)
                    elseif line.SetVertexColor then
                        line:SetVertexColor(1.0, 0.82, 0.18, 0.62)
                    end
                    line:Show()
                    lineIndex = lineIndex + 1
                end
            end
            previousPin = pinData.isRoute == true and pinData or nil
        else
            previousPin = nil
        end
    end
    return lineIndex - 1
end

local function RenderMapPins(frame)
    HidePins(frame)
    if not frame.mapLayer or not frame.mapContent then
        return 0
    end

    local scale = frame.mapCurrentScale or 1
    local width = (frame.mapLayer.layerWidth or 1) * scale
    local height = (frame.mapLayer.layerHeight or 1) * scale
    local pinIndex = 1
    for _, pinData in ipairs(frame.mapPins or {}) do
        local x = tonumber(pinData and pinData.x)
        local y = tonumber(pinData and pinData.y)
        if tonumber(pinData and pinData.mapID) == tonumber(frame.mapID)
            and x and y
            and x >= 0 and x <= 1
            and y >= 0 and y <= 1
        then
            local pin = GetMapPin(frame, pinIndex)
            if pin then
                pin.pinData = pinData
                local textureKind = ApplyMapPinDataIcon(pin.icon, pinData, GoldTracker)
                if not textureKind and pin.icon and pin.icon.SetTexture then
                    pin.icon:SetTexture("Interface\\Icons\\INV_Misc_Map02")
                    if pin.icon.SetTexCoord then
                        pin.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
                    end
                end
                if pin.icon and pin.icon.SetDrawLayer then
                    pin.icon:SetDrawLayer("OVERLAY", MAP_PIN_ICON_SUBLEVEL)
                end
                if pin.icon and pin.icon.SetVertexColor then
                    pin.icon:SetVertexColor(1, 1, 1, 1)
                end
                if pin.icon and pin.icon.SetAlpha then
                    pin.icon:SetAlpha(1)
                end
                local routeOrder = tonumber(pinData.routeOrder)
                local isDungeonStop = routeOrder and (pinData.mapIconType == "dungeon"
                    or pinData.mapIconAtlas == "Dungeon")
                local iconSize = isDungeonStop and MAP_PIN_DUNGEON_ICON_SIZE or MAP_PIN_ICON_SIZE
                pin.icon:ClearAllPoints()
                pin.icon:SetPoint("CENTER", pin, "CENTER",
                    isDungeonStop and MAP_PIN_DUNGEON_ICON_OFFSET_X or 0, 0)
                pin.icon:SetSize(iconSize, iconSize)
                -- Include the shifted icon in the pin's hover/click area, and
                -- reset the bounds when this pooled pin is reused elsewhere.
                pin:SetHitRectInsets(isDungeonStop and -27 or 0, 0,
                    isDungeonStop and -9 or 0, isDungeonStop and -9 or 0)
                if pin.ring then
                    pin.ring:Show()
                end
                if routeOrder then
                    local showLocationIcon = pinData.mapIconType == "dungeon"
                        or HasText(pinData.mapIconAtlas)
                    if showLocationIcon then
                        pin.icon:Show()
                    else
                        pin.icon:Hide()
                    end
                    pin.orderBackground:ClearAllPoints()
                    pin.orderText:ClearAllPoints()
                    if showLocationIcon and not isDungeonStop then
                        pin.orderBackground:SetSize(14, 14)
                        pin.orderBackground:SetPoint("TOPRIGHT", pin, "TOPRIGHT", 4, 4)
                        pin.orderText:SetPoint("CENTER", pin.orderBackground, "CENTER", 0, 0)
                    else
                        pin.orderBackground:SetSize(MAP_PIN_ICON_SIZE + 2, MAP_PIN_ICON_SIZE + 2)
                        pin.orderBackground:SetPoint("CENTER", pin, "CENTER")
                        pin.orderText:SetPoint("CENTER", pin, "CENTER", 0, 0)
                    end
                    pin.orderBackground:Show()
                    pin.orderText:SetText(tostring(routeOrder))
                    pin.orderText:Show()
                else
                    if pin.icon.SetAlpha then
                        pin.icon:SetAlpha(1)
                    end
                    pin.icon:Show()
                    pin.orderBackground:Hide()
                    pin.orderText:Hide()
                end
                pin:ClearAllPoints()
                pin:SetPoint("CENTER", frame.mapContent, "TOPLEFT", x * width, -(y * height))
                pin:Show()
                pinIndex = pinIndex + 1
            end
        end
    end
    return pinIndex - 1
end

local function RenderMapAreas(frame)
    HidePins(frame)
    HideMapAreas(frame)
    if not MapAreaOverlay or not frame.mapLayer or not frame.mapContent then
        return 0
    end

    local scale = frame.mapCurrentScale or 1
    local width = (frame.mapLayer.layerWidth or 1) * scale
    local height = (frame.mapLayer.layerHeight or 1) * scale
    local polygons = MapAreaOverlay:BuildPolygons(frame.mapPins, frame.mapID)
    local renderedCount = MapAreaOverlay:Render(
        frame,
        frame.mapContent,
        "standaloneMapArea",
        polygons,
        width,
        height,
        {
            layer = "OVERLAY",
            fillSubLevel = -3,
            glowSubLevel = -2,
            borderSubLevel = -1,
        }
    )
    local selectedPolygon
    for _, polygon in ipairs(polygons) do
        if polygon.key == frame.selectedMapAreaKey then
            selectedPolygon = polygon
            break
        end
    end
    MapAreaOverlay:Render(
        frame,
        frame.mapContent,
        "standaloneSelectedMapArea",
        selectedPolygon and { selectedPolygon } or {},
        width,
        height,
        {
            layer = "OVERLAY",
            fillSubLevel = 0,
            glowSubLevel = 1,
            borderSubLevel = 2,
            fillColor = { 1.0, 0.66, 0.08, 0.16 },
            glowColor = { 1.0, 0.74, 0.16, 0.32 },
            borderColor = { 1.0, 0.82, 0.18, 1.0 },
        }
    )
    return renderedCount
end

-- A self-contained map canvas for source selection. It shares the map and
-- overlay renderer, but never takes over the standalone window or builds details.
function GoldTracker:RefreshFarmingMapPreview(frame, option)
    if option then
        frame.mapID = option.mapID
        frame.mapPins = option.pins or {}
    end
    if not frame.mapID then
        return
    end
    local layer, textures = LoadMapArt(frame, frame.mapID)
    frame.mapLayer, frame.mapTextureFileIDs = layer, textures
    if not layer then
        frame.mapContent:Hide()
        frame.statusText:Show()
        HideRouteLines(frame)
        HideMapAreas(frame)
        return
    end
    frame.statusText:Hide()
    frame.mapContent:Show()
    UpdateCanvasPosition(frame)
    RenderTiles(frame)
    RenderExploredTiles(frame)
    RenderRouteLines(frame)
    RenderMapAreas(frame)
end

function GoldTracker:CreateFarmingMapPreview(parent)
    local frame = CreatePanel(parent, "input", "inputBorder")
    local viewport = CreateFrame("Frame", nil, frame)
    viewport:SetPoint("TOPLEFT", frame, "TOPLEFT", 1, -1)
    viewport:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -1, 1)
    viewport:SetClipsChildren(true)
    local content = CreateFrame("Frame", nil, viewport)
    content:SetPoint("CENTER", viewport, "CENTER")
    content:SetSize(1, 1)
    frame.mapViewport = viewport
    frame.mapContent = content
    frame.mapTileTextures = {}
    frame.mapExploredTileTextures = {}
    frame.mapRouteLines = {}
    frame.mapPins = {}
    frame.mapZoom = 1
    frame.statusText = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    frame.statusText:SetPoint("CENTER", frame, "CENTER")
    viewport:SetScript("OnSizeChanged", function()
        GoldTracker:RefreshFarmingMapPreview(frame)
    end)
    return frame
end

function GetSelectedMapOption(frame)
    local options = type(frame.mapOptions) == "table" and frame.mapOptions or nil
    local index = tonumber(frame.selectedMapOptionIndex) or 1
    return options and options[index] or nil
end

local function ApplyStandaloneMapOption(frame, optionIndex)
    local option = type(frame.mapOptions) == "table" and frame.mapOptions[optionIndex] or nil
    if not option then
        return false
    end

    frame.selectedMapOptionIndex = optionIndex
    frame.mapID = tonumber(option.mapID) or frame.mapID or DEFAULT_MAP_ID
    frame.mapPins = type(option.pins) == "table" and option.pins or {}
    frame.showRouteLinesWithIcons = option.showRouteLinesWithIcons == true
    frame.selectedMapAreaKey = nil
    frame.mapZoom = 1
    frame.mapPanX = 0
    frame.mapPanY = 0
    if frame.detailsScrollFrame then
        frame.detailsScrollFrame:SetVerticalScroll(0)
    end
    if frame.mapDropdown then
        UIDropDownMenu_SetSelectedValue(frame.mapDropdown, optionIndex)
        UIDropDownMenu_SetText(frame.mapDropdown, option.label or GetMapName(frame.mapID))
    end
    return true
end

local function RefreshStandaloneMapDropdown(frame)
    local options = type(frame.mapOptions) == "table" and frame.mapOptions or {}
    if not frame.mapDropdown then
        return
    end

    if #options <= 1 then
        frame.mapDropdown:Hide()
        return
    end

    frame.mapDropdown:Show()
    UIDropDownMenu_SetSelectedValue(frame.mapDropdown, frame.selectedMapOptionIndex or 1)
    UIDropDownMenu_SetText(frame.mapDropdown, (GetSelectedMapOption(frame) or {}).label or "Select map")
end

function GoldTracker:GetStandaloneMapWaypointDestination()
    local frame = self.standaloneMapFrame
    if not frame then
        return nil, "no-map"
    end

    local groups = GetStandaloneMapAreaGroups(frame)
    local group = FindAreaGroupByKey(groups, frame.selectedMapAreaKey)
    for _, pinData in ipairs(frame.mapPins or {}) do
        local x = tonumber(pinData and pinData.x)
        local y = tonumber(pinData and pinData.y)
        if not group and pinData
            and pinData.isRoute == true
            and tonumber(pinData.mapID) == tonumber(frame.mapID)
            and IsValidMapCoordinate(x)
            and IsValidMapCoordinate(y)
        then
            return {
                mapID = tonumber(frame.mapID),
                x = x,
                y = y,
                label = (pinData.label or GetPinTitle(pinData)) .. " (route start)",
                waypointKind = "route",
                pinData = pinData,
            }
        end
    end

    if not group then
        if #groups == 1 then
            group = groups[1]
        elseif #groups > 1 then
            return nil, "select-area", #groups
        else
            return nil, "no-destination", 0
        end
    end

    local x, y = GetAreaGroupCenter(group)
    if not x or not y then
        return nil, "no-destination", #groups
    end
    return {
        mapID = tonumber(frame.mapID),
        x = x,
        y = y,
        label = GetAreaGroupLabel(group),
        waypointKind = "area",
        areaKey = group.key,
        pinData = group.pins and group.pins[1],
        pins = group.pins,
    }, nil, #groups
end

local function CopyStandaloneMapFarmRow(source)
    local row = {}
    for key, value in pairs(type(source) == "table" and source or {}) do
        if type(value) == "string" or type(value) == "number" or type(value) == "boolean" then
            row[key] = value
        end
    end
    return row
end

function GoldTracker:GetStandaloneMapCustomFarmRow()
    local frame = self.standaloneMapFrame
    if not frame then
        return nil, "No item is available to add from this map."
    end
    local option = GetSelectedMapOption(frame) or {}
    local destination, reason = self:GetStandaloneMapWaypointDestination()
    if reason == "select-area" then
        return nil, "Select a farming overlay, then click Add to farm."
    end
    local pin = destination and destination.pinData or {}
    local row = CopyStandaloneMapFarmRow(frame.customFarmRow)
    row.itemID = tonumber(option.selectedItemID or row.itemID or pin.itemID)
    if not row.itemID or row.itemID <= 0 then
        return nil, "Open this map from an item to add it to a farm."
    end
    if not row.itemName and not option.selectedItemID then
        row.itemName = pin.itemName
    end
    row.farmingSourceType = row.farmingSourceType or "map"
    row.mapID = tonumber(frame.mapID)
    -- Do not retain a source row's coordinates after switching maps.
    row.x = destination and destination.x or nil
    row.y = destination and destination.y or nil
    row.coordX, row.coordY = nil, nil
    row.locationLabel = pin.spotLocation or option.location or option.mapLabel or GetMapName(frame.mapID)
    row.sourceName = pin.targetName or row.sourceName
    row.providerKey = table.concat({
        "map", tostring(frame.mapID), tostring(option.sourceType or pin.sourceType or "static"),
        destination and destination.waypointKind or "map",
        tostring(pin.areaID or pin.routeID or pin.spotLocation or "location"),
        destination and string.format("%.6f:%.6f", destination.x, destination.y) or tostring(option.id or "map"),
    }, ":")
    local mapSource
    if destination then
        local pins = destination.pins or {}
        if destination.waypointKind == "route" then
            for _, routePin in ipairs(frame.mapPins or {}) do
                if routePin.isRoute == true and routePin.routeID == pin.routeID
                    and tonumber(routePin.mapID) == row.mapID
                then
                    pins[#pins + 1] = routePin
                end
            end
        end
        mapSource = {
            id = row.providerKey,
            mapID = row.mapID,
            mapLabel = option.mapLabel or GetMapName(row.mapID),
            label = destination.label,
            sourceType = option.sourceType or pin.sourceType,
            sourceLabel = option.sourceLabel or pin.sourceLabel,
            pins = pins,
        }
    end
    return row, nil, mapSource
end

function GoldTracker:AddStandaloneMapToCustomFarm()
    local row, reason, mapSource = self:GetStandaloneMapCustomFarmRow()
    if not row then
        SetStatus(self.standaloneMapFrame, reason)
        return false
    end
    return self:RequestAddToCustomFarm(row, row.farmingSourceType, mapSource)
end

local function RefreshStandaloneAddToFarmButton(frame)
    local button = frame and frame.addToFarmButton
    if not button then
        return
    end
    local row, reason = GoldTracker:GetStandaloneMapCustomFarmRow()
    button:SetAlpha(row and 1 or 0.5)
    button.tooltipText = reason
end

local function RefreshStandaloneWaypointButton(frame)
    if not frame or not frame.waypointButton then
        return
    end

    local destination, reason, groupCount = GoldTracker:GetStandaloneMapWaypointDestination()
    if destination and destination.waypointKind == "route" then
        frame.waypointButton.tooltipText = "Set a Blizzard waypoint at the starting point of this route."
    elseif destination and groupCount == 1 then
        frame.waypointButton.tooltipText = "Set a Blizzard waypoint at the center of this farming area."
    elseif destination then
        frame.waypointButton.tooltipText = "Set a Blizzard waypoint for the selected farming area: "
            .. tostring(destination.label) .. "."
    elseif reason == "select-area" then
        frame.waypointButton.tooltipText = string.format(
            "This map has %d separate farming areas. Click the requested overlay first, then click Set Waypoint.",
            groupCount or 0
        )
    else
        frame.waypointButton.tooltipText = "No waypoint destination is available for this map."
    end
end

function GoldTracker:SelectStandaloneMapAreaAt(x, y)
    local frame = self.standaloneMapFrame
    x = tonumber(x)
    y = tonumber(y)
    if not frame or not IsValidMapCoordinate(x) or not IsValidMapCoordinate(y)
        or not MapAreaOverlay or type(MapAreaOverlay.BuildPolygons) ~= "function"
    then
        return false
    end

    local selectedKey
    for _, polygon in ipairs(MapAreaOverlay:BuildPolygons(frame.mapPins, frame.mapID)) do
        if PointIsInsidePolygon(x, y, polygon.points) then
            selectedKey = polygon.key
            break
        end
    end
    frame.selectedMapAreaKey = selectedKey
    self:RefreshStandaloneMapWindow()
    return selectedKey ~= nil
end

function GoldTracker:SelectStandaloneMapAreaForPin(pinData)
    local frame = self.standaloneMapFrame
    if not frame or not pinData or pinData.isRoute == true then
        return false
    end

    for _, group in ipairs(GetStandaloneMapAreaGroups(frame)) do
        for _, groupPin in ipairs(group.pins or {}) do
            if groupPin == pinData then
                frame.selectedMapAreaKey = group.key
                self:RefreshStandaloneMapWindow()
                return true
            end
        end
    end
    return false
end

function GoldTracker:SetStandaloneMapWaypoint()
    local frame = self.standaloneMapFrame
    local destination, reason, groupCount = self:GetStandaloneMapWaypointDestination()
    if not destination then
        if reason == "select-area" then
            SetStatus(frame, string.format(
                "Select one of the %d farming overlays, then click Set Waypoint again.",
                groupCount or 0
            ))
        else
            SetStatus(frame, "No waypoint destination is available for this map.")
        end
        return false
    end

    if not C_Map or type(C_Map.SetUserWaypoint) ~= "function"
        or not UiMapPoint or type(UiMapPoint.CreateFromCoordinates) ~= "function"
    then
        SetStatus(frame, "Blizzard waypoint API is unavailable.")
        return false
    end

    local pointOK, point = pcall(UiMapPoint.CreateFromCoordinates, destination.mapID, destination.x, destination.y)
    if not pointOK or not point then
        SetStatus(frame, "Blizzard could not create a waypoint for this destination.")
        return false
    end
    local waypointOK = pcall(C_Map.SetUserWaypoint, point)
    if not waypointOK then
        SetStatus(frame, "Blizzard could not set the waypoint.")
        return false
    end
    if C_SuperTrack and type(C_SuperTrack.SetSuperTrackedUserWaypoint) == "function" then
        pcall(C_SuperTrack.SetSuperTrackedUserWaypoint, true)
    end

    SetStatus(frame, "Blizzard waypoint set for " .. tostring(destination.label) .. ".")
    return true
end

local function SelectStandaloneMapAreaFromCursor(frame)
    if not frame or not frame.mapContent or not frame.mapLayer
        or type(GetCursorPosition) ~= "function"
        or type(frame.mapContent.GetLeft) ~= "function"
        or type(frame.mapContent.GetTop) ~= "function"
    then
        return false
    end

    local cursorX, cursorY = GetCursorPosition()
    local effectiveScale = type(frame.mapContent.GetEffectiveScale) == "function"
        and frame.mapContent:GetEffectiveScale() or 1
    effectiveScale = tonumber(effectiveScale) or 1
    cursorX = cursorX / effectiveScale
    cursorY = cursorY / effectiveScale
    local left = frame.mapContent:GetLeft()
    local top = frame.mapContent:GetTop()
    local width = (frame.mapLayer.layerWidth or 1) * (frame.mapCurrentScale or 1)
    local height = (frame.mapLayer.layerHeight or 1) * (frame.mapCurrentScale or 1)
    if not left or not top or width <= 0 or height <= 0 then
        return false
    end
    return GoldTracker:SelectStandaloneMapAreaAt((cursorX - left) / width, (top - cursorY) / height)
end

function GoldTracker:RefreshStandaloneMapWindow()
    local frame = self.standaloneMapFrame
    if not frame then
        return
    end

    RefreshStandaloneMapDropdown(frame)
    RefreshMapDisplayModeButton(frame)
    RefreshStandaloneWaypointButton(frame)
    RefreshStandaloneAddToFarmButton(frame)
    frame.mapTitle:SetText(GetStandaloneMapToolbarTitle(frame))
    RefreshStandaloneMapDetails(frame)
    RefreshStandaloneMapHeader(frame)
    local layer, textureFileIDs = LoadMapArt(frame, frame.mapID)
    frame.mapLayer = layer
    frame.mapTextureFileIDs = textureFileIDs

    if not layer then
        frame.mapContent:Hide()
        HideRouteLines(frame)
        HidePins(frame)
        HideMapAreas(frame)
        return
    end

    frame.mapContent:Show()
    UpdateCanvasPosition(frame)
    RenderTiles(frame)
    RenderExploredTiles(frame)
    local displayMode = NormalizeMapDisplayMode(frame.mapDisplayMode)
    local routeLineCount = 0
    local areaCount = 0
    local iconCount = 0
    if displayMode == MAP_DISPLAY_MODE_ICONS then
        if frame.showRouteLinesWithIcons then
            routeLineCount = RenderRouteLines(frame)
        else
            HideRouteLines(frame)
        end
        HideMapAreas(frame)
        iconCount = RenderMapPins(frame)
    else
        routeLineCount = RenderRouteLines(frame)
        areaCount = RenderMapAreas(frame)
    end
    local routePointCount = 0
    for _, pinData in ipairs(frame.mapPins or {}) do
        if tonumber(pinData.mapID) == tonumber(frame.mapID) and pinData.isRoute == true then
            routePointCount = routePointCount + 1
        end
    end
    local selectedOption = GetSelectedMapOption(frame)
    local areaGroups = GetStandaloneMapAreaGroups(frame)
    local selectedArea = FindAreaGroupByKey(areaGroups, frame.selectedMapAreaKey)
    if selectedOption and selectedOption.mapOnly == true then
        SetStatus(frame, string.format("%s Zoom %.2fx", selectedOption.mapOnlyStatusText or "Instance map shown; no route coordinates are available.", frame.mapZoom or 1))
    elseif routePointCount == 0 and #areaGroups > 1 and not selectedArea then
        SetStatus(frame, string.format(
            "Select one of the %d farming overlays before setting a waypoint. Zoom %.2fx",
            #areaGroups,
            frame.mapZoom or 1
        ))
    elseif selectedArea then
        SetStatus(frame, string.format(
            "Waypoint area selected: %s. Zoom %.2fx",
            GetAreaGroupLabel(selectedArea),
            frame.mapZoom or 1
        ))
    elseif displayMode == MAP_DISPLAY_MODE_ICONS and iconCount > 0 then
        local iconLabel = frame.showRouteLinesWithIcons and "numbered route stops" or "farming location icons"
        SetStatus(frame, string.format("%d %s visible. Zoom %.2fx", iconCount, iconLabel, frame.mapZoom or 1))
    elseif displayMode == MAP_DISPLAY_MODE_ICONS then
        SetStatus(frame, string.format("No farming locations on this map. Zoom %.2fx", frame.mapZoom or 1))
    elseif routeLineCount > 0 and areaCount > 0 then
        SetStatus(frame, string.format("Route line and %d farming %s visible. Zoom %.2fx", areaCount, areaCount == 1 and "area" or "areas", frame.mapZoom or 1))
    elseif routeLineCount > 0 then
        SetStatus(frame, string.format("Route line visible. Zoom %.2fx", frame.mapZoom or 1))
    elseif areaCount > 0 then
        SetStatus(frame, string.format("%d farming %s visible. Zoom %.2fx", areaCount, areaCount == 1 and "area" or "areas", frame.mapZoom or 1))
    elseif routePointCount == 1 then
        SetStatus(frame, string.format("Need at least two route points for a line. Zoom %.2fx", frame.mapZoom or 1))
    else
        SetStatus(frame, string.format("No farming locations on this map. Zoom %.2fx", frame.mapZoom or 1))
    end
end

function GoldTracker:SetStandaloneMapDisplayMode(mode)
    local frame = self.standaloneMapFrame
    if not frame then
        return false
    end

    frame.mapDisplayMode = NormalizeMapDisplayMode(mode)
    self:RefreshStandaloneMapWindow()
    return true
end

function GoldTracker:ToggleStandaloneMapDisplayMode()
    local frame = self.standaloneMapFrame
    if not frame then
        return false
    end

    local currentMode = NormalizeMapDisplayMode(frame.mapDisplayMode)
    return self:SetStandaloneMapDisplayMode(
        currentMode == MAP_DISPLAY_MODE_ICONS and MAP_DISPLAY_MODE_OVERLAY or MAP_DISPLAY_MODE_ICONS
    )
end

function GoldTracker:AdjustStandaloneMapZoom(delta)
    local frame = self.standaloneMapFrame
    if not frame then
        return
    end

    frame.mapZoom = ClampZoom((frame.mapZoom or 1) + delta)
    self:RefreshStandaloneMapWindow()
end

function GoldTracker:ResetStandaloneMapView()
    local frame = self.standaloneMapFrame
    if not frame then
        return false
    end

    local selectedOptionIndex = tonumber(frame.selectedMapOptionIndex) or 1
    if not ApplyStandaloneMapOption(frame, selectedOptionIndex) then
        frame.mapID = tonumber(frame.originalMapID) or frame.mapID or DEFAULT_MAP_ID
        frame.mapPins = type(frame.originalMapPins) == "table" and frame.originalMapPins or frame.mapPins or {}
        frame.selectedMapAreaKey = nil
        frame.mapZoom = 1
        frame.mapPanX = 0
        frame.mapPanY = 0
        if frame.detailsScrollFrame then
            frame.detailsScrollFrame:SetVerticalScroll(0)
        end
    end
    frame.mapDragging = false
    self:RefreshStandaloneMapWindow()
    return true
end

function GoldTracker:NavigateStandaloneMapToParent()
    local frame = self.standaloneMapFrame
    local mapID = frame and tonumber(frame.mapID)
    if not mapID or not C_Map or type(C_Map.GetMapInfo) ~= "function" then
        return false
    end

    local ok, mapInfo = pcall(C_Map.GetMapInfo, mapID)
    local parentMapID = ok and tonumber(mapInfo and mapInfo.parentMapID) or nil
    if not parentMapID or parentMapID <= 0 or parentMapID == mapID then
        SetStatus(frame, "This map has no parent map.")
        return false
    end

    frame.mapID = parentMapID
    frame.selectedMapAreaKey = nil
    frame.mapZoom = 1
    frame.mapPanX = 0
    frame.mapPanY = 0
    frame.mapDragging = false
    if frame.detailsScrollFrame then
        frame.detailsScrollFrame:SetVerticalScroll(0)
    end
    self:RefreshStandaloneMapWindow()
    return true
end

function GoldTracker:ProjectStandaloneMapToWorldMap()
    local frame = self.standaloneMapFrame
    if not frame then
        return false
    end

    if type(self.ProjectMapRouteToWorldMap) ~= "function" then
        SetStatus(frame, "World map projection is unavailable.")
        return false
    end

    local option = GetSelectedMapOption(frame)
    local projected, message = self:ProjectMapRouteToWorldMap({
        title = frame.windowTitle or "Projected Farming Route",
        projectionKey = frame.projectionKey,
        mapID = frame.mapID,
        mapLabel = option and (option.mapLabel or option.label) or GetMapName(frame.mapID),
        pins = frame.mapPins,
        mapOptions = frame.mapOptions,
        selectedMapOptionIndex = frame.selectedMapOptionIndex,
        customFarmRow = frame.customFarmRow,
        displayMode = frame.mapDisplayMode,
        showRouteLinesWithIcons = frame.showRouteLinesWithIcons,
    })
    if projected then
        local pinCount = 0
        for _, pinData in ipairs(frame.mapPins or {}) do
            if tonumber(pinData.mapID) == tonumber(frame.mapID) then
                pinCount = pinCount + 1
            end
        end
        SetStatus(frame, string.format("Projected %d %s on the Blizzard world map.", pinCount, pinCount == 1 and "pin" or "route pins"))
    else
        SetStatus(frame, message or "No route pins are available to project.")
    end
    return projected
end

function GoldTracker:ClearStandaloneWorldMapProjection()
    local frame = self.standaloneMapFrame
    if not frame or frame.projectionKey == nil or type(self.ClearWorldMapProjectionByKey) ~= "function" then
        SetStatus(frame, "This map's projected pins could not be cleared.")
        return false
    end

    local cleared = self:ClearWorldMapProjectionByKey(frame.projectionKey)
    if cleared then
        SetStatus(frame, "Cleared this map's projected pins from the Blizzard world map.")
    else
        SetStatus(frame, "This map has no projected pins on the Blizzard world map.")
    end
    return cleared
end

function GoldTracker:CreateStandaloneMapWindow()
    if self.standaloneMapFrame then
        return self.standaloneMapFrame
    end

    local frame = CreateFrame("Frame", "GoldTrackerStandaloneMapFrame", UIParent)
    frame:SetSize(WINDOW_WIDTH, WINDOW_HEIGHT)
    frame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    frame:SetFrameStrata("DIALOG")
    if frame.SetToplevel then
        frame:SetToplevel(true)
    end
    frame:SetClampedToScreen(true)
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
    frame:RegisterEvent("GET_ITEM_INFO_RECEIVED")
    frame:RegisterEvent("ITEM_DATA_LOAD_RESULT")
    frame:SetScript("OnEvent", function(self, _, itemID)
        if not self:IsShown() then
            return
        end
        if type(GoldTracker.CompleteFarmItemDataRequest) == "function"
            and GoldTracker:CompleteFarmItemDataRequest(itemID)
        then
            RefreshStandaloneMapDetails(self)
        end
        if tonumber(itemID) == GetStandaloneMapHeaderItemID(self) then
            RefreshStandaloneMapHeader(self)
        end
    end)
    frame:Hide()

    local chrome
    if Theme and type(Theme.ApplyWindowChrome) == "function" then
        chrome = Theme:ApplyWindowChrome(frame, "")
        Theme:RegisterSpecialFrame("GoldTrackerStandaloneMapFrame")
    else
        chrome = frame
        local close = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
        close:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -4, -4)
    end

    local body = CreatePanel(frame, "body", "goldBorder")
    body:SetPoint("TOPLEFT", chrome, "TOPLEFT", 12, -54)
    body:SetPoint("BOTTOMRIGHT", chrome, "BOTTOMRIGHT", -12, 12)

    local toolbar = CreatePanel(body, "section", "goldBorder")
    toolbar:SetPoint("TOPLEFT", body, "TOPLEFT", 12, -12)
    toolbar:SetPoint("TOPRIGHT", body, "TOPRIGHT", -12, -12)
    toolbar:SetHeight(42)

    local mapTitle = toolbar:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    mapTitle:SetPoint("LEFT", toolbar, "LEFT", 12, 0)
    mapTitle:SetPoint("RIGHT", toolbar, "RIGHT", -714, 0)
    mapTitle:SetJustifyH("LEFT")
    mapTitle:SetWordWrap(false)

    local resetButton = CreateButton(toolbar, 72, 24, "Reset", "neutral")
    resetButton:SetPoint("RIGHT", toolbar, "RIGHT", -12, 0)

    local projectButton = CreateButton(toolbar, PROJECT_BUTTON_WIDTH, 24, "Project on BLizzard map", "neutral")
    projectButton:SetPoint("RIGHT", resetButton, "LEFT", -6, 0)

    local clearProjectionButton = CreateButton(toolbar, 92, 24, "Clear Pins", "neutral")
    clearProjectionButton:SetPoint("RIGHT", projectButton, "LEFT", -6, 0)

    local mapDropdown = CreateFrame("Frame", "GoldTrackerStandaloneMapSelectorDropdown", toolbar, "UIDropDownMenuTemplate")
    mapDropdown:SetPoint("RIGHT", clearProjectionButton, "LEFT", -8, 0)
    UIDropDownMenu_SetWidth(mapDropdown, MAP_DROPDOWN_WIDTH)
    UIDropDownMenu_Initialize(mapDropdown, function(_, level)
        local groupCount = 0
        local seenGroups = {}
        for _, option in ipairs(frame.mapOptions or {}) do
            if HasText(option.dropdownGroup) and not seenGroups[option.dropdownGroup] then
                seenGroups[option.dropdownGroup] = true
                groupCount = groupCount + 1
            end
        end
        local showGroupHeaders = groupCount > 1
        local previousGroup
        for index, option in ipairs(frame.mapOptions or {}) do
            if showGroupHeaders and option.dropdownGroup ~= previousGroup then
                local header = UIDropDownMenu_CreateInfo()
                header.text = option.dropdownGroupLabel or option.dropdownGroup
                header.isTitle = true
                header.notCheckable = true
                header.disabled = true
                UIDropDownMenu_AddButton(header, level)
                previousGroup = option.dropdownGroup
            end
            local info = UIDropDownMenu_CreateInfo()
            info.text = option.label or GetMapName(option.mapID)
            info.value = index
            info.checked = frame.selectedMapOptionIndex == index
            info.func = function()
                if ApplyStandaloneMapOption(frame, index) then
                    GoldTracker:RefreshStandaloneMapWindow()
                end
            end
            UIDropDownMenu_AddButton(info, level)
        end
    end)
    mapDropdown:Hide()

    local detailsPanel = CreatePanel(body, "section", "goldBorder")
    detailsPanel:SetPoint("TOPRIGHT", body, "TOPRIGHT", -12, -64)
    detailsPanel:SetPoint("BOTTOMRIGHT", body, "BOTTOMRIGHT", -12, 42)
    detailsPanel:SetWidth(DETAILS_PANEL_WIDTH)

    local detailsScrollFrame = CreateFrame("ScrollFrame", nil, detailsPanel, "UIPanelScrollFrameTemplate")
    detailsScrollFrame:SetPoint("TOPLEFT", detailsPanel, "TOPLEFT", DETAILS_CONTENT_PADDING, -DETAILS_CONTENT_PADDING)
    detailsScrollFrame:SetPoint("BOTTOMRIGHT", detailsPanel, "BOTTOMRIGHT", -30, DETAILS_CONTENT_PADDING)
    detailsScrollFrame:EnableMouseWheel(true)
    detailsScrollFrame:SetScript("OnMouseWheel", function(self, delta)
        ScrollStandaloneMapDetails(self, delta)
    end)

    local detailsContent = CreateFrame("Frame", nil, detailsScrollFrame)
    detailsContent:SetPoint("TOPLEFT", detailsScrollFrame, "TOPLEFT", 0, 0)
    detailsContent:SetSize(1, 1)
    detailsScrollFrame:SetScrollChild(detailsContent)

    local mapViewport = CreatePanel(body, "input", "inputBorder")
    mapViewport:SetPoint("TOPLEFT", toolbar, "BOTTOMLEFT", 0, -10)
    mapViewport:SetPoint("BOTTOMRIGHT", detailsPanel, "BOTTOMLEFT", -DETAILS_PANEL_GAP, 0)
    mapViewport:EnableMouse(true)
    mapViewport:EnableMouseWheel(true)
    if mapViewport.SetClipsChildren then
        mapViewport:SetClipsChildren(true)
    end

    local mapContent = CreateFrame("Frame", nil, mapViewport)
    mapContent:SetPoint("CENTER", mapViewport, "CENTER")
    mapContent:SetSize(1, 1)

    local waypointButton = CreateButton(mapViewport, WAYPOINT_BUTTON_WIDTH, 24, "Set Waypoint", "neutral")
    waypointButton:SetPoint("TOPRIGHT", mapViewport, "TOPRIGHT", -10, -10)

    local displayModeButton = CreateButton(mapViewport, MAP_DISPLAY_MODE_BUTTON_WIDTH, 24, "Icons", "neutral")
    displayModeButton:SetPoint("RIGHT", waypointButton, "LEFT", -6, 0)
    if mapContent.GetFrameLevel and waypointButton.SetFrameLevel and displayModeButton.SetFrameLevel then
        local controlsFrameLevel = (tonumber(mapContent:GetFrameLevel()) or 0) + 10
        waypointButton:SetFrameLevel(controlsFrameLevel)
        displayModeButton:SetFrameLevel(controlsFrameLevel)
    end

    local statusText = body:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    statusText:SetPoint("BOTTOMLEFT", body, "BOTTOMLEFT", 18, 18)
    statusText:SetPoint("BOTTOMRIGHT", body, "BOTTOMRIGHT", -(ADD_TO_FARM_BUTTON_WIDTH + 30), 18)
    statusText:SetJustifyH("LEFT")

    local addToFarmButton = CreateButton(body, ADD_TO_FARM_BUTTON_WIDTH, 24, "Add to farm", "neutral")
    addToFarmButton:SetPoint("BOTTOMRIGHT", body, "BOTTOMRIGHT", -12, 8)
    addToFarmButton:SetScript("OnClick", function()
        GoldTracker:AddStandaloneMapToCustomFarm()
    end)
    addToFarmButton:SetScript("OnEnter", function(self)
        if not GameTooltip then
            return
        end
        local row, reason = GoldTracker:GetStandaloneMapCustomFarmRow()
        local title, detail = "Add to farm", reason
        if row then
            title, detail = GoldTracker:GetCustomFarmAddButtonTooltip(row.itemID)
        end
        GameTooltip:SetOwner(self, "ANCHOR_TOP")
        GameTooltip:AddLine(title, 1, 1, 1)
        GameTooltip:AddLine(detail, 0.72, 0.86, 1.0, true)
        GameTooltip:Show()
    end)
    addToFarmButton:SetScript("OnLeave", function()
        if GameTooltip then
            GameTooltip:Hide()
        end
    end)

    frame.mapID = DEFAULT_MAP_ID
    frame.mapPins = {}
    frame.mapTileTextures = {}
    frame.mapExploredTileTextures = {}
    frame.mapRouteLines = {}
    frame.mapPinFrames = {}
    frame.mapZoom = 1
    frame.mapPanX = 0
    frame.mapPanY = 0
    frame.mapDisplayMode = MAP_DISPLAY_MODE_OVERLAY
    frame.body = body
    frame.mapTitle = mapTitle
    frame.resetButton = resetButton
    frame.projectButton = projectButton
    frame.mapViewport = mapViewport
    frame.mapContent = mapContent
    frame.detailsPanel = detailsPanel
    frame.detailsScrollFrame = detailsScrollFrame
    frame.detailsContent = detailsContent
    frame.detailTextLines = {}
    frame.detailSourceRows = {}
    frame.detailTableRows = {}
    frame.detailTableFilterRows = {}
    frame.detailTableHeaderRows = {}
    frame.detailToggleRows = {}
    frame.detailButtonRows = {}
    frame.statusText = statusText
    frame.mapDropdown = mapDropdown
    frame.displayModeButton = displayModeButton
    frame.waypointButton = waypointButton
    frame.addToFarmButton = addToFarmButton

    mapViewport:SetScript("OnMouseWheel", function(_, delta)
        GoldTracker:AdjustStandaloneMapZoom(delta > 0 and ZOOM_STEP or -ZOOM_STEP)
    end)

    mapViewport:SetScript("OnMouseDown", function(_, button)
        if button == "RightButton" then
            GoldTracker:NavigateStandaloneMapToParent()
            return
        end
        if button ~= "LeftButton" or type(GetCursorPosition) ~= "function" then
            return
        end
        frame.mapDragging = true
        frame.mapDragX, frame.mapDragY = GetCursorPosition()
        frame.mapMouseDownX, frame.mapMouseDownY = frame.mapDragX, frame.mapDragY
    end)

    mapViewport:SetScript("OnMouseUp", function(_, button)
        local mouseDownX = frame.mapMouseDownX
        local mouseDownY = frame.mapMouseDownY
        frame.mapDragging = false
        frame.mapMouseDownX = nil
        frame.mapMouseDownY = nil
        if button ~= "LeftButton" or not mouseDownX or not mouseDownY or type(GetCursorPosition) ~= "function" then
            return
        end
        local cursorX, cursorY = GetCursorPosition()
        local distanceX = cursorX - mouseDownX
        local distanceY = cursorY - mouseDownY
        if ((distanceX * distanceX) + (distanceY * distanceY)) <= (MAP_CLICK_DISTANCE * MAP_CLICK_DISTANCE) then
            SelectStandaloneMapAreaFromCursor(frame)
        end
    end)

    mapViewport:SetScript("OnHide", function()
        frame.mapDragging = false
    end)

    mapViewport:SetScript("OnUpdate", function()
        if not frame.mapDragging or type(GetCursorPosition) ~= "function" then
            return
        end

        local cursorX, cursorY = GetCursorPosition()
        local previousX = frame.mapDragX or cursorX
        local previousY = frame.mapDragY or cursorY
        frame.mapDragX, frame.mapDragY = cursorX, cursorY
        frame.mapPanX = (frame.mapPanX or 0) + (cursorX - previousX)
        frame.mapPanY = (frame.mapPanY or 0) + (cursorY - previousY)
        UpdateCanvasPosition(frame)
    end)

    mapViewport:SetScript("OnSizeChanged", function()
        GoldTracker:RefreshStandaloneMapWindow()
    end)

    resetButton:SetScript("OnClick", function()
        GoldTracker:ResetStandaloneMapView()
    end)

    projectButton:SetScript("OnClick", function()
        GoldTracker:ProjectStandaloneMapToWorldMap()
    end)

    waypointButton:SetScript("OnClick", function()
        GoldTracker:SetStandaloneMapWaypoint()
    end)
    waypointButton:SetScript("OnEnter", function(self)
        if GameTooltip and HasText(self.tooltipText) then
            GameTooltip:SetOwner(self, "ANCHOR_TOP")
            GameTooltip:SetText("Blizzard waypoint", 1.0, 0.82, 0.18)
            GameTooltip:AddLine(self.tooltipText, 0.82, 0.86, 0.92, true)
            GameTooltip:Show()
        end
    end)
    waypointButton:SetScript("OnLeave", function()
        if GameTooltip then
            GameTooltip:Hide()
        end
    end)

    displayModeButton:SetScript("OnClick", function()
        GoldTracker:ToggleStandaloneMapDisplayMode()
    end)
    displayModeButton:SetScript("OnEnter", function(self)
        if GameTooltip and HasText(self.tooltipText) then
            GameTooltip:SetOwner(self, "ANCHOR_TOP")
            GameTooltip:SetText(self.tooltipText, 1.0, 0.82, 0.18)
            GameTooltip:Show()
        end
    end)
    displayModeButton:SetScript("OnLeave", function()
        if GameTooltip then
            GameTooltip:Hide()
        end
    end)

    clearProjectionButton:SetScript("OnClick", function()
        GoldTracker:ClearStandaloneWorldMapProjection()
    end)

    self.standaloneMapFrame = frame
    return frame
end

function GoldTracker:OpenStandaloneMapWindow(options)
    local frame = self:CreateStandaloneMapWindow()
    options = type(options) == "table" and options or {}

    frame.windowTitle = options.title
    frame.projectionKey = options.projectionKey or options.title
    frame.customFarmRow = CopyStandaloneMapFarmRow(options.customFarmRow)
    frame.customFarmRow.farmingSourceType = options.customFarmSourceType or frame.customFarmRow.farmingSourceType
    frame.selectedMapAreaKey = nil
    frame.detailLinesBuilder = type(options.detailLinesBuilder) == "function" and options.detailLinesBuilder or nil
    frame.mapDisplayMode = NormalizeMapDisplayMode(options.displayMode or frame.mapDisplayMode)
    frame.mapOptions = type(options.mapOptions) == "table" and options.mapOptions or nil
    frame.showRouteLinesWithIcons = options.showRouteLinesWithIcons == true
    frame.selectedMapOptionIndex = tonumber(options.selectedMapOptionIndex) or 1
    if frame.mapOptions and frame.mapOptions[frame.selectedMapOptionIndex] then
        ApplyStandaloneMapOption(frame, frame.selectedMapOptionIndex)
    else
        frame.mapID = tonumber(options.mapID) or frame.mapID or DEFAULT_MAP_ID
        frame.mapPins = type(options.pins) == "table" and options.pins or frame.mapPins or {}
        frame.mapOptions = nil
        frame.selectedMapOptionIndex = 1
        if frame.mapDropdown then
            frame.mapDropdown:Hide()
        end
        if frame.detailsScrollFrame then
            frame.detailsScrollFrame:SetVerticalScroll(0)
        end
    end
    frame.originalMapID = frame.mapID
    frame.originalMapPins = frame.mapPins
    frame:Show()
    frame:Raise()
    self:RefreshStandaloneMapWindow()
end

function GoldTracker:OpenStandaloneMapTest()
    self:OpenStandaloneMapWindow({
        mapID = DEFAULT_MAP_ID,
        pins = {
            {
                mapID = DEFAULT_MAP_ID,
                x = DEFAULT_PIN_X / 100,
                y = DEFAULT_PIN_Y / 100,
                label = "Goretooth / Nagrand test pin",
            },
        },
    })
end
