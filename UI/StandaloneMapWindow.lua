local _, NS = ...
local GoldTracker = NS.GoldTracker
local Theme = NS.JanisTheme

local DEFAULT_MAP_ID = 107
local DEFAULT_PIN_X = 41.4
local DEFAULT_PIN_Y = 41.4
local MIN_ZOOM = 1
local MAX_ZOOM = 3
local ZOOM_STEP = 0.25
local MAP_DROPDOWN_WIDTH = 190
local DETAILS_PANEL_WIDTH = 292
local DETAILS_PANEL_GAP = 10
local DETAILS_CONTENT_PADDING = 12
local SOURCE_BUTTON_WIDTH = 54
local SOURCE_ROW_HEIGHT = 24
local DETAIL_TEXT_HEIGHT_PADDING = 4
local DETAIL_TEXT_MEASURE_HEIGHT = 1000

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
    if C_Map and C_Map.GetMapInfo then
        local mapInfo = C_Map.GetMapInfo(mapID)
        if mapInfo and mapInfo.name then
            return mapInfo.name
        end
    end
    return "Map " .. tostring(mapID)
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
    if HasText(frame and frame.windowTitle) then
        return frame.windowTitle
    end
    if frame and frame.mapOptions then
        return ""
    end
    return GetMapName(frame and frame.mapID or DEFAULT_MAP_ID)
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

local function BuildVisiblePinGroups(pins, mapID)
    local groups = {}
    local byKey = {}
    local selectedMapID = tonumber(mapID)
    for _, pinData in ipairs(pins or {}) do
        if pinData and tonumber(pinData.mapID) == selectedMapID then
            local tips = CopyTips(pinData.tips)
            local key = table.concat({
                GetPinTitle(pinData),
                pinData.spotLocation or pinData.label or "",
                pinData.routeType or "",
                pinData.density or "",
                pinData.dropDifficulty or "",
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
                    tips = tips,
                    sources = {},
                    sourceUrlLookup = {},
                }
                byKey[key] = group
                groups[#groups + 1] = group
            end
            AddSourceUrls(group, pinData.sourceUrls)
        end
    end
    return groups
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
        AppendDetailLine(lines, group.location, 0.92, 0.95, 1.0, 6, "GameFontHighlight")
        local routeText = HasText(group.routeType) and ("Route: " .. group.routeType) or nil
        local densityText = HasText(group.density) and ("Density: " .. group.density) or nil
        local difficultyText = HasText(group.dropDifficulty) and ("Difficulty: " .. group.dropDifficulty) or nil
        AppendDetailLine(lines, routeText, 0.72, 0.86, 1.0, 5, "GameFontHighlight")
        AppendDetailLine(lines, densityText, 0.72, 0.86, 1.0, 5, "GameFontHighlight")
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

local function SetUserWaypoint(frame, mapID, x, y)
    if not C_Map or not C_Map.SetUserWaypoint or not UiMapPoint or not UiMapPoint.CreateFromCoordinates then
        SetStatus(frame, "This client cannot set user waypoints from addons.")
        return false
    end

    if C_Map.CanSetUserWaypointOnMap and not C_Map.CanSetUserWaypointOnMap(mapID) then
        SetStatus(frame, "This map cannot accept a user waypoint.")
        return false
    end

    C_Map.SetUserWaypoint(UiMapPoint.CreateFromCoordinates(mapID, x, y))
    if C_SuperTrack and C_SuperTrack.SetSuperTrackedUserWaypoint then
        C_SuperTrack.SetSuperTrackedUserWaypoint(true)
    end
    SetStatus(frame, "Waypoint set.")
    return true
end

local function GetPin(frame, index)
    frame.mapPinFrames = frame.mapPinFrames or {}
    local pin = frame.mapPinFrames[index]
    if not pin then
        pin = CreateFrame("Button", nil, frame.mapContent, "BackdropTemplate")
        pin:SetSize(28, 28)
        pin.icon = pin:CreateTexture(nil, "OVERLAY")
        pin.icon:SetPoint("CENTER")
        pin.icon:SetSize(24, 24)
        if not pin.icon.SetAtlas or not pcall(pin.icon.SetAtlas, pin.icon, "VignetteLoot", true) then
            pin.icon:SetTexture("Interface\\Icons\\INV_Misc_Map02")
        end
        pin.ring = pin:CreateTexture(nil, "ARTWORK")
        pin.ring:SetPoint("CENTER")
        pin.ring:SetSize(30, 30)
        pin.ring:SetColorTexture(1.0, 0.82, 0.18, 0.18)
        pin:SetScript("OnEnter", function(target)
            if not GameTooltip then
                return
            end
            GameTooltip:SetOwner(target, "ANCHOR_RIGHT")
            GameTooltip:SetText(GetPinTitle(target), 1, 0.82, 0.18)
            GameTooltip:Show()
        end)
        pin:SetScript("OnLeave", function()
            if GameTooltip then
                GameTooltip:Hide()
            end
        end)
        pin:SetScript("OnClick", function(target)
            SetUserWaypoint(frame, target.mapID, target.x, target.y)
        end)
        frame.mapPinFrames[index] = pin
    end
    return pin
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

local function ShowSourceLinkWindow(url, siteName)
    if not HasText(url) then
        return
    end

    local frame = GoldTracker.standaloneMapSourceLinkFrame
    if not frame then
        frame = CreateFrame("Frame", "GoldTrackerStandaloneMapSourceLinkFrame", UIParent, "BasicFrameTemplateWithInset")
        frame:SetSize(620, 150)
        frame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
        frame:SetFrameStrata("TOOLTIP")
        frame:SetClampedToScreen(true)
        frame:SetMovable(true)
        frame:EnableMouse(true)
        frame:RegisterForDrag("LeftButton")
        frame:SetScript("OnDragStart", frame.StartMoving)
        frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
        if frame.TitleText then
            frame.TitleText:SetText("Source Link")
        end

        local body = CreatePanel(frame, "body", "goldBorder")
        body:SetPoint("TOPLEFT", frame, "TOPLEFT", 12, -34)
        body:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -12, 12)

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

local function RefreshStandaloneMapDetails(frame)
    if not frame or not frame.detailsContent or not frame.detailsScrollFrame then
        return
    end

    local option = GetSelectedMapOption(frame)
    local mapLabel = (option and option.label) or GetMapName(frame.mapID)
    local lines = GoldTracker:BuildStandaloneMapDetailLines(frame.mapPins, frame.mapID, mapLabel)
    local scrollWidth = frame.detailsScrollFrame:GetWidth() or 0
    if scrollWidth <= 1 then
        scrollWidth = DETAILS_PANEL_WIDTH - (DETAILS_CONTENT_PADDING * 2) - 24
    end
    local contentWidth = math.max(1, math.floor(scrollWidth - 8))
    local yOffset = 0

    for index, line in ipairs(lines) do
        local lineHeight = 18
        if line.type == "source" then
            local text = frame.detailTextLines and frame.detailTextLines[index]
            if text then
                text:Hide()
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

local function RenderPins(frame)
    if not frame.mapLayer or not frame.mapContent then
        return
    end

    HidePins(frame)
    local scale = frame.mapCurrentScale or 1
    local layerWidth = frame.mapLayer.layerWidth or 1
    local layerHeight = frame.mapLayer.layerHeight or 1
    local pinIndex = 1
    for _, pinData in ipairs(frame.mapPins or {}) do
        if pinData.mapID == frame.mapID then
            local pin = GetPin(frame, pinIndex)
            pin.mapID = pinData.mapID
            pin.x = pinData.x
            pin.y = pinData.y
            pin.label = pinData.label
            pin.itemName = pinData.itemName
            pin.spotLocation = pinData.spotLocation
            pin.routeType = pinData.routeType
            pin.density = pinData.density
            pin.dropDifficulty = pinData.dropDifficulty
            pin.tips = pinData.tips
            pin:ClearAllPoints()
            pin:SetPoint("CENTER", frame.mapContent, "TOPLEFT", pinData.x * layerWidth * scale, -(pinData.y * layerHeight * scale))
            pin:Show()
            pinIndex = pinIndex + 1
        end
    end
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

function GoldTracker:RefreshStandaloneMapWindow()
    local frame = self.standaloneMapFrame
    if not frame then
        return
    end

    RefreshStandaloneMapDropdown(frame)
    frame.mapTitle:SetText(GetStandaloneMapToolbarTitle(frame))
    RefreshStandaloneMapDetails(frame)
    local layer, textureFileIDs = LoadMapArt(frame, frame.mapID)
    frame.mapLayer = layer
    frame.mapTextureFileIDs = textureFileIDs

    if not layer then
        frame.mapContent:Hide()
        return
    end

    frame.mapContent:Show()
    UpdateCanvasPosition(frame)
    RenderTiles(frame)
    RenderExploredTiles(frame)
    RenderPins(frame)
    local pinCount = 0
    for _, pinData in ipairs(frame.mapPins or {}) do
        if tonumber(pinData.mapID) == tonumber(frame.mapID) then
            pinCount = pinCount + 1
        end
    end
    if pinCount > 0 then
        SetStatus(frame, string.format("Click a pin to set a waypoint. Zoom %.2fx", frame.mapZoom or 1))
    else
        SetStatus(frame, string.format("No route pins on this map. Zoom %.2fx", frame.mapZoom or 1))
    end
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
        return
    end

    frame.mapZoom = 1
    frame.mapPanX = 0
    frame.mapPanY = 0
    self:RefreshStandaloneMapWindow()
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
        mapID = frame.mapID,
        mapLabel = option and option.label or GetMapName(frame.mapID),
        pins = frame.mapPins,
        mapOptions = frame.mapOptions,
        selectedMapOptionIndex = frame.selectedMapOptionIndex,
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
    if type(self.ClearWorldMapProjection) == "function" then
        self:ClearWorldMapProjection()
    end
    SetStatus(self.standaloneMapFrame, "Cleared projected pins from the Blizzard world map.")
    return true
end

function GoldTracker:CreateStandaloneMapWindow()
    if self.standaloneMapFrame then
        return self.standaloneMapFrame
    end

    local frame = CreateFrame("Frame", "GoldTrackerStandaloneMapFrame", UIParent, "BasicFrameTemplateWithInset")
    frame:SetSize(980, 600)
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
    frame:Hide()

    local chrome
    if Theme and type(Theme.ApplyWindowChrome) == "function" then
        chrome = Theme:ApplyWindowChrome(frame, "Farming Route Map")
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
    mapTitle:SetPoint("RIGHT", toolbar, "RIGHT", -546, 0)
    mapTitle:SetJustifyH("LEFT")
    mapTitle:SetWordWrap(false)

    local zoomOutButton = CreateButton(toolbar, 28, 24, "-", "neutral")
    zoomOutButton:SetPoint("RIGHT", toolbar, "RIGHT", -132, 0)

    local resetButton = CreateButton(toolbar, 72, 24, "Reset", "neutral")
    resetButton:SetPoint("LEFT", zoomOutButton, "RIGHT", 6, 0)

    local zoomInButton = CreateButton(toolbar, 28, 24, "+", "neutral")
    zoomInButton:SetPoint("LEFT", resetButton, "RIGHT", 6, 0)

    local projectButton = CreateButton(toolbar, 72, 24, "Project", "neutral")
    projectButton:SetPoint("RIGHT", zoomOutButton, "LEFT", -6, 0)

    local clearProjectionButton = CreateButton(toolbar, 92, 24, "Clear Pins", "neutral")
    clearProjectionButton:SetPoint("RIGHT", projectButton, "LEFT", -6, 0)

    local mapDropdown = CreateFrame("Frame", "GoldTrackerStandaloneMapSelectorDropdown", toolbar, "UIDropDownMenuTemplate")
    mapDropdown:SetPoint("RIGHT", clearProjectionButton, "LEFT", -8, 0)
    UIDropDownMenu_SetWidth(mapDropdown, MAP_DROPDOWN_WIDTH)
    UIDropDownMenu_Initialize(mapDropdown, function(_, level)
        for index, option in ipairs(frame.mapOptions or {}) do
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
        local step = 38
        local current = self:GetVerticalScroll() or 0
        local maxScroll = self:GetVerticalScrollRange() or 0
        self:SetVerticalScroll(math.max(0, math.min(maxScroll, current - (delta * step))))
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

    local statusText = body:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    statusText:SetPoint("BOTTOMLEFT", body, "BOTTOMLEFT", 18, 18)
    statusText:SetPoint("BOTTOMRIGHT", body, "BOTTOMRIGHT", -18, 18)
    statusText:SetJustifyH("LEFT")

    frame.mapID = DEFAULT_MAP_ID
    frame.mapPins = {}
    frame.mapTileTextures = {}
    frame.mapExploredTileTextures = {}
    frame.mapPinFrames = {}
    frame.mapZoom = 1
    frame.mapPanX = 0
    frame.mapPanY = 0
    frame.body = body
    frame.mapTitle = mapTitle
    frame.mapViewport = mapViewport
    frame.mapContent = mapContent
    frame.detailsPanel = detailsPanel
    frame.detailsScrollFrame = detailsScrollFrame
    frame.detailsContent = detailsContent
    frame.detailTextLines = {}
    frame.detailSourceRows = {}
    frame.statusText = statusText
    frame.mapDropdown = mapDropdown

    mapViewport:SetScript("OnMouseWheel", function(_, delta)
        GoldTracker:AdjustStandaloneMapZoom(delta > 0 and ZOOM_STEP or -ZOOM_STEP)
    end)

    mapViewport:SetScript("OnMouseDown", function(_, button)
        if button ~= "LeftButton" or type(GetCursorPosition) ~= "function" then
            return
        end
        frame.mapDragging = true
        frame.mapDragX, frame.mapDragY = GetCursorPosition()
    end)

    mapViewport:SetScript("OnMouseUp", function()
        frame.mapDragging = false
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

    zoomOutButton:SetScript("OnClick", function()
        GoldTracker:AdjustStandaloneMapZoom(-ZOOM_STEP)
    end)

    zoomInButton:SetScript("OnClick", function()
        GoldTracker:AdjustStandaloneMapZoom(ZOOM_STEP)
    end)

    resetButton:SetScript("OnClick", function()
        GoldTracker:ResetStandaloneMapView()
    end)

    projectButton:SetScript("OnClick", function()
        GoldTracker:ProjectStandaloneMapToWorldMap()
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
    frame.mapOptions = type(options.mapOptions) == "table" and options.mapOptions or nil
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
