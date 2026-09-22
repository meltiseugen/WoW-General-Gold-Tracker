local _, NS = ...
local GoldTracker = NS.GoldTracker
local MapAreaOverlay = GoldTracker.MapAreaOverlay

local PIN_TEMPLATE = "GoldTrackerWorldMapRoutePinTemplate"
local LINE_THICKNESS = 3
local ROUTE_OVERLAY_FRAME_LEVEL_OFFSET = 100
local PIN_BASE_SIZE = 26
local PIN_ICON_SIZE = 18
local PIN_RING_SIZE = 32
local MINIMAP_PIN_SIZE = 18
local MINIMAP_PIN_ICON_SIZE = 14
local MINIMAP_PIN_RING_SIZE = 22
local MINIMAP_PIN_PADDING = 8
local MINIMAP_PIN_REFRESH_SECONDS = 0.20
local MAX_MINIMAP_PROJECTION_PINS = 80
local FALLBACK_MINIMAP_COORDINATE_RADIUS = 0.08
local CONTROLS_WIDTH = 176
local CONTROLS_HEIGHT = 22
local CONTROLS_CANVAS_INSET = 16

local function LoadBlizzardMapAddOns()
    if C_AddOns and type(C_AddOns.LoadAddOn) == "function" then
        pcall(C_AddOns.LoadAddOn, "Blizzard_MapCanvas")
        pcall(C_AddOns.LoadAddOn, "Blizzard_WorldMap")
    elseif type(LoadAddOn) == "function" then
        pcall(LoadAddOn, "Blizzard_MapCanvas")
        pcall(LoadAddOn, "Blizzard_WorldMap")
    end
end

local function NormalizeCoordinate(value)
    local normalized = tonumber(value)
    if not normalized then
        return nil
    end
    if normalized > 1 then
        normalized = normalized / 100
    end
    if normalized < 0 or normalized > 1 then
        return nil
    end
    return normalized
end

local function GetMapName(mapID)
    if C_Map and type(C_Map.GetMapInfo) == "function" then
        local ok, mapInfo = pcall(C_Map.GetMapInfo, mapID)
        if ok and mapInfo and mapInfo.name then
            return mapInfo.name
        end
    end
    return "Map " .. tostring(mapID)
end

local function CopyArray(values)
    if type(values) ~= "table" then
        return nil
    end

    local copy = {}
    for index, value in ipairs(values) do
        copy[index] = value
    end
    return copy
end

local function CopyProjectionPin(pinData, fallbackMapID)
    if type(pinData) ~= "table" then
        return nil
    end

    local mapID = tonumber(pinData.mapID) or fallbackMapID
    local x = NormalizeCoordinate(pinData.x)
    local y = NormalizeCoordinate(pinData.y)
    if not mapID or not x or not y then
        return nil
    end

    return {
        mapID = mapID,
        x = x,
        y = y,
        label = pinData.label,
        itemName = pinData.itemName,
        spotLocation = pinData.spotLocation,
        targetName = pinData.targetName,
        targetType = pinData.targetType,
        farmAction = pinData.farmAction,
        isRoute = pinData.isRoute == true,
        routeID = pinData.routeID,
        routeType = pinData.routeType,
        density = pinData.density,
        dropDifficulty = pinData.dropDifficulty,
        sourceType = pinData.sourceType,
        sourceKind = pinData.sourceKind,
        sourceLabel = pinData.sourceLabel,
        seenCount = tonumber(pinData.seenCount),
        totalQuantity = tonumber(pinData.totalQuantity),
        projectionTitle = pinData.projectionTitle,
        tips = CopyArray(pinData.tips),
        sourceUrls = CopyArray(pinData.sourceUrls),
    }
end

local function CopyMapOptions(mapOptions)
    if type(mapOptions) ~= "table" then
        return nil
    end

    local copiedOptions = {}
    for _, option in ipairs(mapOptions) do
        if type(option) == "table" then
            local copiedOption = {
                id = option.id,
                mapID = tonumber(option.mapID),
                mapLabel = option.mapLabel,
                label = option.label,
                location = option.location,
                spotCount = option.spotCount,
                sourceType = option.sourceType,
                sourceLabel = option.sourceLabel,
                pins = {},
            }
            for _, pinData in ipairs(option.pins or {}) do
                local copiedPin = CopyProjectionPin(pinData, copiedOption.mapID)
                if copiedPin then
                    copiedOption.pins[#copiedOption.pins + 1] = copiedPin
                end
            end
            copiedOptions[#copiedOptions + 1] = copiedOption
        end
    end
    return copiedOptions
end

local function BuildPinsForMap(mapID, pins)
    local projectedPins = {}
    for _, pinData in ipairs(pins or {}) do
        local copiedPin = CopyProjectionPin(pinData, mapID)
        if copiedPin and copiedPin.mapID == mapID then
            projectedPins[#projectedPins + 1] = copiedPin
        end
    end
    return projectedPins
end

local function FormatPinCoordinate(pinData)
    return string.format("#%s %.1f %.1f", tostring(pinData.mapID), (pinData.x or 0) * 100, (pinData.y or 0) * 100)
end

local function AddProjectionTooltipLines(tooltip, pinData)
    tooltip:SetText(pinData.label or "Farming route pin", 1, 0.82, 0.18)
    tooltip:AddLine(FormatPinCoordinate(pinData), 0.82, 0.86, 0.92)
    if type(pinData.projectionTitle) == "string" and pinData.projectionTitle ~= "" then
        tooltip:AddDoubleLine("Projection", pinData.projectionTitle, 0.72, 0.86, 1.0, 1, 1, 1)
    end
    if type(pinData.itemName) == "string" and pinData.itemName ~= "" then
        tooltip:AddDoubleLine("Item", pinData.itemName, 0.72, 0.86, 1.0, 1, 1, 1)
    end
    if type(pinData.farmAction) == "string" and pinData.farmAction ~= "" then
        tooltip:AddLine(pinData.farmAction, 1.0, 0.45, 0.20, true)
    elseif type(pinData.targetName) == "string" and pinData.targetName ~= "" then
        local actionLabels = {
            fish = "Fish",
            gather = "Gather",
            kill = "Kill",
            mine = "Mine",
            skin = "Kill and skin",
        }
        tooltip:AddDoubleLine(
            actionLabels[pinData.targetType] or "Farm",
            pinData.targetName,
            1.0, 0.45, 0.20,
            1, 0.72, 0.55
        )
    end
    if type(pinData.sourceLabel) == "string" and pinData.sourceLabel ~= "" then
        tooltip:AddDoubleLine("Source", pinData.sourceLabel, 0.72, 0.86, 1.0, 1, 1, 1)
    end
    if type(pinData.spotLocation) == "string" and pinData.spotLocation ~= "" then
        tooltip:AddLine(pinData.spotLocation, 0.92, 0.95, 1.0, true)
    end
    if type(pinData.routeType) == "string" and pinData.routeType ~= "" then
        tooltip:AddDoubleLine("Route", pinData.routeType, 0.72, 0.86, 1.0, 1, 1, 1)
    end
    if type(pinData.density) == "string" and pinData.density ~= "" then
        tooltip:AddDoubleLine("Density", pinData.density, 0.72, 0.86, 1.0, 1, 1, 1)
    end
    if type(pinData.dropDifficulty) == "string" and pinData.dropDifficulty ~= "" then
        tooltip:AddLine(pinData.dropDifficulty, 0.72, 0.86, 1.0, true)
    end
    if type(pinData.tips) == "table" and #pinData.tips > 0 then
        tooltip:AddLine("Tips", 1.0, 0.82, 0.18)
        for index = 1, math.min(3, #pinData.tips) do
            tooltip:AddLine(pinData.tips[index], 0.72, 0.86, 1.0, true)
        end
    end
end

local function BringWorldMapToFront(mapFrame)
    if not mapFrame then
        return
    end

    -- WorldMapFrame is a composite Blizzard panel. Its quest log and other
    -- controls use their own frames and levels, so changing or raising only
    -- the map root can place the map canvas in front of its own UI. Keep the
    -- native map hierarchy intact and move only our addon windows behind it.
    local theme = NS.JanisTheme
    if theme and type(theme.DemoteInactiveAddonWindows) == "function" then
        pcall(theme.DemoteInactiveAddonWindows, theme, mapFrame, "LOW")
    end
end

local function KeepWorldMapInFrontAfterOpen(mapFrame)
    if not C_Timer or type(C_Timer.After) ~= "function" then
        return
    end

    C_Timer.After(0, function()
        if mapFrame == WorldMapFrame
            and (not mapFrame.IsShown or mapFrame:IsShown()) then
            BringWorldMapToFront(mapFrame)
        end
    end)
end

local function OpenWorldMapToMapID(mapID)
    LoadBlizzardMapAddOns()

    local mapFrame = WorldMapFrame
    if mapFrame and mapFrame.IsShown and mapFrame:IsShown() then
        if mapFrame.SetMapID then
            mapFrame:SetMapID(mapID)
        end
        BringWorldMapToFront(mapFrame)
        KeepWorldMapInFrontAfterOpen(mapFrame)
        return true
    end

    if InCombatLockdown and InCombatLockdown() then
        return false
    end

    local opened = false
    if C_Map and type(C_Map.OpenWorldMap) == "function" then
        opened = pcall(C_Map.OpenWorldMap, mapID)
    elseif type(OpenWorldMap) == "function" then
        opened = pcall(OpenWorldMap, mapID)
    elseif type(ToggleWorldMap) == "function" then
        opened = pcall(ToggleWorldMap)
    end

    mapFrame = WorldMapFrame
    if mapFrame and mapFrame.SetMapID then
        pcall(mapFrame.SetMapID, mapFrame, mapID)
    end
    BringWorldMapToFront(mapFrame)
    KeepWorldMapInFrontAfterOpen(mapFrame)
    return opened
end

local function CreateWorldMapButton(parent, width, text)
    local button = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
    button:SetSize(width, 22)
    button:SetText(text or "")
    return button
end

local function GetWorldMapProjectionControlsParent()
    if not WorldMapFrame then
        return nil
    end
    return WorldMapFrame.ScrollContainer or (WorldMapFrame.GetCanvas and WorldMapFrame:GetCanvas()) or WorldMapFrame
end

local function PositionWorldMapProjectionControls(controls)
    local parent = GetWorldMapProjectionControlsParent()
    if not controls or not parent then
        return
    end

    if controls.SetParent and controls.GetParent and controls:GetParent() ~= parent then
        controls:SetParent(parent)
    end
    controls:ClearAllPoints()
    controls:SetPoint("BOTTOMLEFT", parent, "BOTTOMLEFT", CONTROLS_CANVAS_INSET, CONTROLS_CANVAS_INSET)
end

local function GetProjectionPinScale(addon)
    if addon and type(addon.GetWorldMapProjectionPinScale) == "function" then
        return addon:GetWorldMapProjectionPinScale()
    end
    return 1
end

local function EnsureProjectionPinTexture(pin, key, layer, subLevel)
    local texture = pin and pin[key]
    if not texture and pin and type(pin.CreateTexture) == "function" then
        texture = pin:CreateTexture(nil, layer or "OVERLAY")
        pin[key] = texture
    end
    if texture and texture.SetDrawLayer then
        texture:SetDrawLayer(layer or "OVERLAY", subLevel or 0)
    end
    return texture
end

local function TrySetAtlas(texture, atlas)
    return texture
        and type(texture.SetAtlas) == "function"
        and pcall(texture.SetAtlas, texture, atlas, true)
end

local function ApplyProjectionPinTexture(texture, atlas, fallbackTexture)
    if not texture then
        return false
    end
    if atlas and TrySetAtlas(texture, atlas) then
        return "atlas"
    end
    if fallbackTexture and type(texture.SetTexture) == "function" then
        texture:SetTexture(fallbackTexture)
        return "texture"
    end
    return nil
end

local function ApplyConfiguredProjectionPinIcon(texture, addon)
    local iconOption
    if addon and type(addon.GetMapPinIconOption) == "function" then
        iconOption = addon:GetMapPinIconOption()
    end
    iconOption = type(iconOption) == "table" and iconOption or {
        atlas = "VignetteLoot",
        texture = "Interface\\Icons\\INV_Misc_Map02",
    }

    local textureKind = ApplyProjectionPinTexture(texture, iconOption.atlas, iconOption.texture)
    if textureKind ~= "atlas" and texture and texture.SetTexCoord then
        texture:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    end
    return textureKind
end

local function BuildProjectionKey(projection)
    if type(projection) ~= "table" then
        return nil
    end
    return table.concat({
        tostring(projection.projectionKey or projection.title or "Projected Farming Route"),
        tostring(projection.mapID or ""),
    }, "\031")
end

local function GetProjectionIdentity(projection)
    if type(projection) ~= "table" then
        return nil
    end
    return projection.projectionKey or projection.title
end

local function GetProjectionStore(addon)
    if not addon then
        return {}
    end

    if type(addon.worldMapProjections) ~= "table" then
        addon.worldMapProjections = {}
        if type(addon.worldMapProjection) == "table" then
            addon.worldMapProjections[1] = addon.worldMapProjection
        end
    end
    return addon.worldMapProjections
end

local function HasActiveProjection(addon)
    return type(addon and addon.worldMapProjections) == "table"
        and #addon.worldMapProjections > 0
        or type(addon and addon.worldMapProjection) == "table"
end

local function CopyDisplayProjectionPin(pinData, projection, projectionIndex, pinIndex, pinCount)
    local displayPin = {}
    for key, value in pairs(pinData or {}) do
        displayPin[key] = value
    end
    displayPin.projectionTitle = projection and projection.title
    displayPin.projectionIndex = projectionIndex
    displayPin.projectionPinIndex = pinIndex
    displayPin.projectionPinCount = pinCount
    return displayPin
end

local function GetProjectedPinsForMap(addon, mapID)
    local normalizedMapID = tonumber(mapID)
    local pins = {}
    if not normalizedMapID then
        return pins
    end

    for projectionIndex, projection in ipairs(GetProjectionStore(addon)) do
        if type(projection) == "table" and tonumber(projection.mapID) == normalizedMapID then
            local projectionPins = type(projection.pins) == "table" and projection.pins or {}
            for pinIndex, pinData in ipairs(projectionPins) do
                if type(pinData) == "table" and tonumber(pinData.mapID) == normalizedMapID then
                    pins[#pins + 1] = CopyDisplayProjectionPin(
                        pinData,
                        projection,
                        projectionIndex,
                        pinIndex,
                        #projectionPins
                    )
                end
            end
        end
    end
    return pins
end

local function GetPointXY(point)
    if type(point) ~= "table" then
        return nil, nil
    end
    if type(point.GetXY) == "function" then
        return point:GetXY()
    end
    return point.x or point[1], point.y or point[2]
end

local function GetPlayerMapPosition(mapID)
    if not C_Map or type(C_Map.GetPlayerMapPosition) ~= "function" then
        return nil, nil
    end

    local ok, position = pcall(C_Map.GetPlayerMapPosition, mapID, "player")
    if not ok then
        return nil, nil
    end
    local x, y = GetPointXY(position)
    x = NormalizeCoordinate(x)
    y = NormalizeCoordinate(y)
    return x, y
end

local function GetWorldPositionFromMapPosition(mapID, x, y)
    if not C_Map or type(C_Map.GetWorldPosFromMapPos) ~= "function"
        or not UiMapPoint or type(UiMapPoint.CreateFromCoordinates) ~= "function" then
        return nil, nil
    end

    local pointOK, point = pcall(UiMapPoint.CreateFromCoordinates, mapID, x, y)
    if not pointOK or not point then
        return nil, nil
    end

    local ok, first, second = pcall(C_Map.GetWorldPosFromMapPos, mapID, point)
    if not ok then
        return nil, nil
    end
    if type(first) == "number" and type(second) == "number" then
        return first, second
    end
    if type(second) == "table" then
        return GetPointXY(second)
    end
    if type(first) == "table" then
        return GetPointXY(first)
    end
    return nil, nil
end

local function GetMinimapViewRadius()
    if C_Minimap and type(C_Minimap.GetViewRadius) == "function" then
        local ok, radius = pcall(C_Minimap.GetViewRadius)
        if ok and tonumber(radius) and tonumber(radius) > 0 then
            return tonumber(radius)
        end
    end
    if Minimap and type(Minimap.GetViewRadius) == "function" then
        local ok, radius = pcall(Minimap.GetViewRadius, Minimap)
        if ok and tonumber(radius) and tonumber(radius) > 0 then
            return tonumber(radius)
        end
    end
    return nil
end

local function GetMinimapCurrentMapID()
    if C_Map and type(C_Map.GetBestMapForUnit) == "function" then
        local ok, mapID = pcall(C_Map.GetBestMapForUnit, "player")
        if ok and tonumber(mapID) then
            return tonumber(mapID)
        end
    end
    return nil
end

local function CalculateMinimapProjectionOffset(mapID, pinData, radius)
    local playerX, playerY = GetPlayerMapPosition(mapID)
    if not playerX or not playerY then
        return nil, nil
    end

    local playerWorldX, playerWorldY = GetWorldPositionFromMapPosition(mapID, playerX, playerY)
    local pinWorldX, pinWorldY = GetWorldPositionFromMapPosition(mapID, pinData.x, pinData.y)
    local viewRadius = GetMinimapViewRadius()
    local offsetX
    local offsetY
    if playerWorldX and playerWorldY and pinWorldX and pinWorldY and viewRadius then
        offsetX = ((pinWorldX - playerWorldX) / viewRadius) * radius
        offsetY = -((pinWorldY - playerWorldY) / viewRadius) * radius
    else
        offsetX = ((pinData.x - playerX) / FALLBACK_MINIMAP_COORDINATE_RADIUS) * radius
        offsetY = -((pinData.y - playerY) / FALLBACK_MINIMAP_COORDINATE_RADIUS) * radius
    end

    local distance = math.sqrt((offsetX * offsetX) + (offsetY * offsetY))
    if distance > radius and distance > 0 then
        local clampedScale = radius / distance
        offsetX = offsetX * clampedScale
        offsetY = offsetY * clampedScale
    end
    return offsetX, offsetY
end

local function EnsureWorldMapOverlayMixins()
    LoadBlizzardMapAddOns()
    if type(CreateFromMixins) ~= "function" or not MapCanvasPinMixin or not MapCanvasDataProviderMixin then
        return false
    end

    if not _G.GoldTrackerWorldMapRoutePinMixin or _G.GoldTrackerWorldMapRoutePinMixin.goldTrackerReady ~= true then
        local pinMixin = CreateFromMixins(MapCanvasPinMixin)
        pinMixin.goldTrackerReady = true

        function pinMixin:ApplyGoldTrackerVisuals()
            self:SetSize(PIN_BASE_SIZE, PIN_BASE_SIZE)
            if self.UseFrameLevelType then
                self:UseFrameLevelType("PIN_FRAME_LEVEL_TOPMOST")
            end
            if self.SetScalingLimits then
                self:SetScalingLimits(1, 1.0, 1.2)
            end
            if self.RegisterForClicks then
                self:RegisterForClicks("LeftButtonUp")
            end
            if self.SetMouseClickEnabled then
                self:SetMouseClickEnabled(true)
            end
            if self.SetMouseMotionEnabled then
                self:SetMouseMotionEnabled(true)
            end
            if self.SetIgnoreGlobalPinScale then
                self:SetIgnoreGlobalPinScale(true)
            end
            if self.SetAlpha then
                self:SetAlpha(1)
            end

            local ring = EnsureProjectionPinTexture(self, "Ring", "OVERLAY", 6)
            if ring then
                ring:ClearAllPoints()
                ring:SetPoint("CENTER", self, "CENTER")
                ring:SetSize(PIN_RING_SIZE, PIN_RING_SIZE)
                ApplyProjectionPinTexture(ring, "worldquest-icon-ring", "Interface\\Minimap\\MiniMap-TrackingBorder")
                if ring.SetVertexColor then
                    ring:SetVertexColor(1.0, 0.82, 0.18, 0.9)
                end
                if ring.SetAlpha then
                    ring:SetAlpha(0.95)
                end
                ring:Show()
            end

            local icon = EnsureProjectionPinTexture(self, "Icon", "OVERLAY", 7)
            if icon then
                icon:ClearAllPoints()
                icon:SetPoint("CENTER", self, "CENTER")
                icon:SetSize(PIN_ICON_SIZE, PIN_ICON_SIZE)
                ApplyConfiguredProjectionPinIcon(icon, self.dataProvider and self.dataProvider.addon)
                if icon.SetVertexColor then
                    icon:SetVertexColor(1, 1, 1, 1)
                end
                if icon.SetAlpha then
                    icon:SetAlpha(1)
                end
                icon:Show()
            end
            if self.Number then
                if self.Number.SetDrawLayer then
                    self.Number:SetDrawLayer("OVERLAY", 8)
                end
                self.Number:SetTextColor(1, 1, 1, 1)
            end
            self.goldTrackerVisualsReady = true
        end

        function pinMixin:ApplyGoldTrackerScale()
            self:SetScale(GetProjectionPinScale(self.dataProvider and self.dataProvider.addon))
        end

        function pinMixin:OnLoad()
            self:ApplyGoldTrackerVisuals()
        end

        function pinMixin:OnAcquired(dataProvider, pinData, pinIndex, pinCount)
            self.dataProvider = dataProvider
            self.pinData = pinData
            self.pinIndex = pinIndex
            self.pinCount = pinCount
            self:ApplyGoldTrackerVisuals()
            self:ApplyGoldTrackerScale()
            if self.SetFrameLevel and dataProvider and type(dataProvider.GetMap) == "function" then
                local map = dataProvider:GetMap()
                local canvas = map and map.GetCanvas and map:GetCanvas()
                if canvas and canvas.GetFrameLevel then
                    self:SetFrameLevel((canvas:GetFrameLevel() or 0) + 50)
                end
            end
            if self.Number then
                self.Number:SetText(pinCount and pinCount > 1 and tostring(pinIndex) or "")
                if pinData.projectionPinCount and pinData.projectionPinCount > 1 then
                    self.Number:SetText(tostring(pinData.projectionPinIndex or pinIndex))
                end
            end
            self:Show()
        end

        function pinMixin:OnReleased()
            MapCanvasPinMixin.OnReleased(self)
            self.dataProvider = nil
            self.pinData = nil
            self.pinIndex = nil
            self.pinCount = nil
            if self.Number then
                self.Number:SetText("")
            end
        end

        function pinMixin:OnMouseEnter()
            if not GameTooltip or not self.pinData then
                return
            end
            GameTooltip:SetOwner(self, "ANCHOR_CURSOR_RIGHT", 5, 2)
            AddProjectionTooltipLines(GameTooltip, self.pinData)
            GameTooltip:Show()
        end

        function pinMixin:OnMouseLeave()
            if GameTooltip then
                GameTooltip:Hide()
            end
        end

        function pinMixin:OnMouseClickAction(button)
            if button ~= "LeftButton" or not self.dataProvider or not self.dataProvider.addon then
                return
            end
            self.dataProvider.addon:SetWorldMapProjectionWaypoint(self.pinData)
        end

        function pinMixin:ShouldMouseButtonBePassthrough(button)
            return button == "RightButton"
        end

        _G.GoldTrackerWorldMapRoutePinMixin = pinMixin
    end

    if not _G.GoldTrackerWorldMapRouteDataProviderMixin or _G.GoldTrackerWorldMapRouteDataProviderMixin.goldTrackerReady ~= true then
        local providerMixin = CreateFromMixins(MapCanvasDataProviderMixin)
        providerMixin.goldTrackerReady = true

        function providerMixin:HideRouteLines()
            for _, line in ipairs(self.routeLines or {}) do
                line:Hide()
            end
        end

        function providerMixin:HideNonRouteAreas()
            if MapAreaOverlay then
                MapAreaOverlay:Hide(self, "worldMapArea")
            end
        end

        function providerMixin:GetRouteOverlay(canvas)
            if not canvas or type(CreateFrame) ~= "function" then
                return nil
            end

            local overlay = self.routeOverlay
            if not overlay then
                overlay = CreateFrame("Frame", nil, canvas)
                if overlay.EnableMouse then
                    overlay:EnableMouse(false)
                end
                self.routeOverlay = overlay
            elseif overlay.SetParent then
                overlay:SetParent(canvas)
            end

            if overlay.ClearAllPoints then
                overlay:ClearAllPoints()
            end
            if overlay.SetAllPoints then
                overlay:SetAllPoints(canvas)
            else
                overlay:SetPoint("TOPLEFT", canvas, "TOPLEFT", 0, 0)
                overlay:SetPoint("BOTTOMRIGHT", canvas, "BOTTOMRIGHT", 0, 0)
            end
            if overlay.SetFrameLevel then
                local canvasLevel = canvas.GetFrameLevel and canvas:GetFrameLevel() or 0
                overlay:SetFrameLevel(canvasLevel + ROUTE_OVERLAY_FRAME_LEVEL_OFFSET)
            end
            if overlay.Show then
                overlay:Show()
            end
            return overlay
        end

        function providerMixin:GetRouteLine(index, canvas)
            self.routeLines = self.routeLines or {}
            local line = self.routeLines[index]
            local overlay = self:GetRouteOverlay(canvas)
            if not overlay then
                return nil
            end
            if not line then
                if type(overlay.CreateLine) ~= "function" then
                    return nil
                end
                line = overlay:CreateLine(nil, "OVERLAY", nil, 7)
                self.routeLines[index] = line
            end
            if line.SetParent then
                line:SetParent(overlay)
            end
            return line
        end

        function providerMixin:RefreshRouteLines()
            self:HideRouteLines()
            local map = self:GetMap()
            if not map or not map.GetMapID then
                return
            end

            local canvas = map:GetCanvas()
            if not canvas or not canvas.GetWidth or not canvas.GetHeight then
                return
            end

            local width = math.max(1, canvas:GetWidth() or 1)
            local height = math.max(1, canvas:GetHeight() or 1)
            local currentMapID = map:GetMapID()
            local lineIndex = 1
            for _, projection in ipairs(GetProjectionStore(self.addon)) do
                if type(projection) == "table" and tonumber(projection.mapID) == tonumber(currentMapID) then
                    local pins = projection.pins or {}
                    for index = 1, #pins - 1 do
                        local fromPin = pins[index]
                        local toPin = pins[index + 1]
                        local isRouteSegment = fromPin
                            and toPin
                            and fromPin.isRoute == true
                            and toPin.isRoute == true
                            and fromPin.routeID == toPin.routeID
                        local line = isRouteSegment and self:GetRouteLine(lineIndex, canvas) or nil
                        if line then
                            line:ClearAllPoints()
                            line:SetStartPoint("TOPLEFT", self.routeOverlay, width * fromPin.x, -(height * fromPin.y))
                            line:SetEndPoint("TOPLEFT", self.routeOverlay, width * toPin.x, -(height * toPin.y))
                            if line.SetThickness then
                                line:SetThickness(LINE_THICKNESS)
                            end
                            if line.SetColorTexture then
                                line:SetColorTexture(1.0, 0.82, 0.18, 0.58)
                            elseif line.SetVertexColor then
                                line:SetVertexColor(1.0, 0.82, 0.18, 0.58)
                            end
                            line:Show()
                            lineIndex = lineIndex + 1
                        end
                    end
                end
            end
        end

        function providerMixin:RefreshNonRouteAreas()
            self:HideNonRouteAreas()
            if not MapAreaOverlay then
                return 0
            end

            local map = self:GetMap()
            if not map or not map.GetMapID then
                return 0
            end
            local canvas = map:GetCanvas()
            if not canvas or not canvas.GetWidth or not canvas.GetHeight then
                return 0
            end

            local currentMapID = map:GetMapID()
            local polygons = {}
            for _, projection in ipairs(GetProjectionStore(self.addon)) do
                if type(projection) == "table" and tonumber(projection.mapID) == tonumber(currentMapID) then
                    for _, polygon in ipairs(MapAreaOverlay:BuildPolygons(projection.pins, currentMapID)) do
                        polygons[#polygons + 1] = polygon
                    end
                end
            end

            return MapAreaOverlay:Render(
                self,
                self:GetRouteOverlay(canvas),
                "worldMapArea",
                polygons,
                canvas:GetWidth(),
                canvas:GetHeight(),
                {
                    layer = "ARTWORK",
                    fillSubLevel = 1,
                    glowSubLevel = 2,
                    borderSubLevel = 3,
                }
            )
        end

        function providerMixin:RemoveAllData()
            local map = self:GetMap()
            if map and type(map.RemoveAllPinsByTemplate) == "function" then
                map:RemoveAllPinsByTemplate(PIN_TEMPLATE)
            end
            for _, pin in ipairs(self.acquiredPins or {}) do
                if pin and pin.Hide then
                    pin:Hide()
                end
            end
            self.acquiredPins = {}
            self:HideRouteLines()
            self:HideNonRouteAreas()
        end

        function providerMixin:RefreshAllData()
            self:RemoveAllData()
            local map = self:GetMap()
            if not map or not map.GetMapID then
                return
            end

            self:RefreshRouteLines()
            self:RefreshNonRouteAreas()
            self.acquiredPins = {}
        end

        function providerMixin:OnMapChanged()
            self:RefreshAllData()
            if self.addon and type(self.addon.RefreshWorldMapProjectionControls) == "function" then
                self.addon:RefreshWorldMapProjectionControls()
            end
        end

        function providerMixin:OnShow()
            self:RefreshAllData()
            if self.addon and type(self.addon.RefreshWorldMapProjectionControls) == "function" then
                self.addon:RefreshWorldMapProjectionControls()
            end
        end

        function providerMixin:OnHide()
            if self.addon and type(self.addon.RefreshWorldMapProjectionControls) == "function" then
                self.addon:RefreshWorldMapProjectionControls()
            end
        end

        function providerMixin:OnCanvasSizeChanged()
            self:RefreshAllData()
        end

        _G.GoldTrackerWorldMapRouteDataProviderMixin = providerMixin
    end

    return true
end

local function HideMinimapProjectionPins(frame, usedPins)
    for index, pin in ipairs(frame and frame.pins or {}) do
        if index > (usedPins or 0) and pin.Hide then
            pin:Hide()
        end
    end
end

local function CreateMinimapProjectionPin(frame)
    local pin = CreateFrame("Button", nil, frame)
    pin:SetSize(MINIMAP_PIN_SIZE, MINIMAP_PIN_SIZE)
    if pin.RegisterForClicks then
        pin:RegisterForClicks("LeftButtonUp")
    end

    local ring = pin:CreateTexture(nil, "ARTWORK")
    ring:SetPoint("CENTER", pin, "CENTER")
    ring:SetSize(MINIMAP_PIN_RING_SIZE, MINIMAP_PIN_RING_SIZE)
    ApplyProjectionPinTexture(ring, "worldquest-icon-ring", "Interface\\Minimap\\MiniMap-TrackingBorder")
    if ring.SetVertexColor then
        ring:SetVertexColor(1.0, 0.82, 0.18, 0.92)
    end
    pin.ring = ring

    local icon = pin:CreateTexture(nil, "OVERLAY")
    icon:SetPoint("CENTER", pin, "CENTER")
    icon:SetSize(MINIMAP_PIN_ICON_SIZE, MINIMAP_PIN_ICON_SIZE)
    ApplyConfiguredProjectionPinIcon(icon, frame.addon)
    pin.icon = icon

    pin:SetScript("OnEnter", function(self)
        if not GameTooltip or not self.pinData then
            return
        end
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        AddProjectionTooltipLines(GameTooltip, self.pinData)
        GameTooltip:Show()
    end)
    pin:SetScript("OnLeave", function()
        if GameTooltip then
            GameTooltip:Hide()
        end
    end)
    pin:SetScript("OnClick", function(self, button)
        if button == "LeftButton" and frame.addon and self.pinData then
            frame.addon:SetWorldMapProjectionWaypoint(self.pinData)
        end
    end)
    return pin
end

local function GetMinimapProjectionPin(frame, index)
    frame.pins = frame.pins or {}
    if not frame.pins[index] then
        frame.pins[index] = CreateMinimapProjectionPin(frame)
    end
    return frame.pins[index]
end

function GoldTracker:EnsureMinimapProjectionOverlay()
    if self.minimapProjectionOverlay then
        return self.minimapProjectionOverlay
    end
    if not Minimap or type(CreateFrame) ~= "function" then
        return nil
    end

    local overlay = CreateFrame("Frame", "GoldTrackerMinimapProjectionOverlay", Minimap)
    overlay.addon = self
    overlay.pins = {}
    if overlay.SetAllPoints then
        overlay:SetAllPoints(Minimap)
    else
        overlay:SetPoint("TOPLEFT", Minimap, "TOPLEFT", 0, 0)
        overlay:SetPoint("BOTTOMRIGHT", Minimap, "BOTTOMRIGHT", 0, 0)
    end
    if overlay.SetFrameStrata then
        overlay:SetFrameStrata("HIGH")
    end
    if overlay.EnableMouse then
        overlay:EnableMouse(false)
    end
    if overlay.RegisterEvent then
        overlay:RegisterEvent("PLAYER_ENTERING_WORLD")
        overlay:RegisterEvent("ZONE_CHANGED")
        overlay:RegisterEvent("ZONE_CHANGED_INDOORS")
        overlay:RegisterEvent("ZONE_CHANGED_NEW_AREA")
        overlay:RegisterEvent("MINIMAP_UPDATE_ZOOM")
    end
    overlay:SetScript("OnEvent", function()
        self:RefreshMinimapProjectionPins(true)
    end)
    overlay:SetScript("OnUpdate", function(frame, elapsed)
        frame.elapsed = (frame.elapsed or 0) + (elapsed or 0)
        if frame.elapsed >= MINIMAP_PIN_REFRESH_SECONDS then
            frame.elapsed = 0
            self:RefreshMinimapProjectionPins(false)
        end
    end)
    overlay:Hide()

    self.minimapProjectionOverlay = overlay
    return overlay
end

function GoldTracker:RefreshMinimapProjectionPins(force)
    local overlay = self.minimapProjectionOverlay
    if not overlay and HasActiveProjection(self) then
        overlay = self:EnsureMinimapProjectionOverlay()
    end
    if not overlay then
        return false
    end

    if not HasActiveProjection(self) then
        HideMinimapProjectionPins(overlay, 0)
        overlay:Hide()
        return true
    end

    local mapID = GetMinimapCurrentMapID()
    local pins = GetProjectedPinsForMap(self, mapID)
    if #pins == 0 then
        HideMinimapProjectionPins(overlay, 0)
        overlay:Hide()
        return true
    end

    if force then
        overlay.elapsed = 0
    end
    if overlay.SetAllPoints and Minimap then
        overlay:SetAllPoints(Minimap)
    end

    local width = Minimap and Minimap.GetWidth and tonumber(Minimap:GetWidth()) or 140
    local height = Minimap and Minimap.GetHeight and tonumber(Minimap:GetHeight()) or 140
    local radius = math.max(1, (math.min(width, height) * 0.5) - MINIMAP_PIN_PADDING)
    local usedPins = 0
    for _, pinData in ipairs(pins) do
        if usedPins >= MAX_MINIMAP_PROJECTION_PINS then
            break
        end

        local offsetX, offsetY = CalculateMinimapProjectionOffset(mapID, pinData, radius)
        if offsetX and offsetY then
            usedPins = usedPins + 1
            local pin = GetMinimapProjectionPin(overlay, usedPins)
            pin.pinData = pinData
            ApplyConfiguredProjectionPinIcon(pin.icon, self)
            pin:ClearAllPoints()
            pin:SetPoint("CENTER", overlay, "CENTER", offsetX, offsetY)
            pin:Show()
        end
    end

    HideMinimapProjectionPins(overlay, usedPins)
    overlay:SetShown(usedPins > 0)
    return true
end

function GoldTracker:ClearMinimapProjectionPins()
    if self.minimapProjectionOverlay then
        HideMinimapProjectionPins(self.minimapProjectionOverlay, 0)
        self.minimapProjectionOverlay:Hide()
    end
    return true
end

function GoldTracker:BuildWorldMapProjectionPayload(options)
    options = type(options) == "table" and options or {}
    local mapID = tonumber(options.mapID)
    if not mapID then
        return nil
    end

    local pins = BuildPinsForMap(mapID, options.pins)
    if #pins == 0 then
        return nil
    end

    local mapOptions = CopyMapOptions(options.mapOptions)
    if not mapOptions or #mapOptions == 0 then
        mapOptions = {
            {
                mapID = mapID,
                label = options.mapLabel or GetMapName(mapID),
                pins = pins,
                spotCount = #pins,
            },
        }
    end

    return {
        title = options.title or "Projected Farming Route",
        projectionKey = options.projectionKey,
        mapID = mapID,
        mapName = options.mapLabel or GetMapName(mapID),
        pins = pins,
        mapOptions = mapOptions,
        selectedMapOptionIndex = tonumber(options.selectedMapOptionIndex) or 1,
    }
end

function GoldTracker:EnsureWorldMapProjectionProvider()
    if not EnsureWorldMapOverlayMixins() then
        return false, "Blizzard map canvas APIs are unavailable."
    end
    if not WorldMapFrame or type(WorldMapFrame.AddDataProvider) ~= "function" then
        return false, "Blizzard world map is unavailable."
    end

    if not self.worldMapRouteDataProvider then
        local provider = CreateFromMixins(_G.GoldTrackerWorldMapRouteDataProviderMixin)
        provider.addon = self
        WorldMapFrame:AddDataProvider(provider)
        self.worldMapRouteDataProvider = provider
    end

    self:EnsureWorldMapProjectionControls()
    return true
end

function GoldTracker:EnsureWorldMapProjectionControls()
    if self.worldMapProjectionControls or not WorldMapFrame or type(CreateFrame) ~= "function" then
        PositionWorldMapProjectionControls(self.worldMapProjectionControls)
        return self.worldMapProjectionControls
    end

    local parent = GetWorldMapProjectionControlsParent()
    local controls = CreateFrame("Frame", "GoldTrackerWorldMapProjectionControls", parent)
    controls:SetSize(CONTROLS_WIDTH, CONTROLS_HEIGHT)
    PositionWorldMapProjectionControls(controls)
    controls:EnableMouse(true)
    if controls.SetToplevel then
        controls:SetToplevel(true)
    end
    if controls.SetFrameLevel and parent.GetFrameLevel then
        controls:SetFrameLevel((parent:GetFrameLevel() or 0) + 100)
    end

    local detailsButton = CreateWorldMapButton(controls, 72, "Details")
    detailsButton:SetPoint("LEFT", controls, "LEFT", 0, 0)
    detailsButton:SetScript("OnClick", function()
        GoldTracker:OpenWorldMapProjectionDetails()
    end)
    controls.detailsButton = detailsButton

    local clearButton = CreateWorldMapButton(controls, 92, "Clear Pins")
    clearButton:SetPoint("LEFT", detailsButton, "RIGHT", 8, 0)
    clearButton:SetScript("OnClick", function()
        GoldTracker:ClearWorldMapProjection()
    end)
    controls.clearButton = clearButton

    controls:Hide()
    self.worldMapProjectionControls = controls
    return controls
end

function GoldTracker:RefreshWorldMapProjectionControls()
    local controls = self.worldMapProjectionControls
    if not controls then
        return
    end

    PositionWorldMapProjectionControls(controls)
    local shouldShow = HasActiveProjection(self)
        and (not WorldMapFrame or not WorldMapFrame.IsShown or WorldMapFrame:IsShown())
    controls:SetShown(shouldShow)
end

function GoldTracker:SetWorldMapProjectionWaypoint(pinData)
    if not pinData or not pinData.mapID or not pinData.x or not pinData.y then
        return false
    end
    if not C_Map or type(C_Map.SetUserWaypoint) ~= "function" or not UiMapPoint or type(UiMapPoint.CreateFromCoordinates) ~= "function" then
        if type(self.Print) == "function" then
            self:Print("Blizzard waypoint API is unavailable.")
        end
        return false
    end

    C_Map.SetUserWaypoint(UiMapPoint.CreateFromCoordinates(pinData.mapID, pinData.x, pinData.y))
    if C_SuperTrack and type(C_SuperTrack.SetSuperTrackedUserWaypoint) == "function" then
        C_SuperTrack.SetSuperTrackedUserWaypoint(true)
    end
    if type(self.Print) == "function" then
        self:Print("Waypoint set for " .. tostring(pinData.label or "projected route pin") .. ".")
    end
    return true
end

function GoldTracker:ProjectMapRouteToWorldMap(options)
    local projection = self:BuildWorldMapProjectionPayload(options)
    if not projection then
        if type(self.Print) == "function" then
            self:Print("No route pins are available to project.")
        end
        return false, "No route pins are available to project."
    end

    local projections = GetProjectionStore(self)
    local projectionKey = BuildProjectionKey(projection)
    for index = #projections, 1, -1 do
        if BuildProjectionKey(projections[index]) == projectionKey then
            table.remove(projections, index)
        end
    end
    projections[#projections + 1] = projection
    self.worldMapProjection = projection

    local providerReady, message = self:EnsureWorldMapProjectionProvider()
    if not providerReady then
        if type(self.Print) == "function" then
            self:Print(message)
        end
        return false, message
    end

    local opened = OpenWorldMapToMapID(projection.mapID)
    if self.worldMapRouteDataProvider then
        self.worldMapRouteDataProvider:RefreshAllData()
    end
    self:RefreshMinimapProjectionPins(true)
    self:RefreshWorldMapProjectionControls()

    if type(self.Print) == "function" then
        local suffix = opened and "" or " Open the world map after combat to view it."
        self:Print(string.format(
            "Projected %d %s on %s. %d %s active.%s",
            #projection.pins,
            #projection.pins == 1 and "pin" or "route pins",
            projection.mapName,
            #projections,
            #projections == 1 and "projection" or "projections",
            suffix
        ))
    end
    return true
end

function GoldTracker:ClearWorldMapProjection()
    self.worldMapProjections = {}
    self.worldMapProjection = nil
    if self.worldMapRouteDataProvider then
        self.worldMapRouteDataProvider:RemoveAllData()
    end
    self:ClearMinimapProjectionPins()
    self:RefreshWorldMapProjectionControls()
    if type(self.Print) == "function" then
        self:Print("Cleared projected farming routes from the world map and minimap.")
    end
    return true
end

function GoldTracker:ClearWorldMapProjectionByKey(projectionKey)
    if projectionKey == nil then
        return false, 0
    end

    local projections = GetProjectionStore(self)
    local removedCount = 0
    for index = #projections, 1, -1 do
        if GetProjectionIdentity(projections[index]) == projectionKey then
            table.remove(projections, index)
            removedCount = removedCount + 1
        end
    end
    if removedCount == 0 then
        return false, 0
    end

    self.worldMapProjection = projections[#projections]
    if self.worldMapRouteDataProvider then
        self.worldMapRouteDataProvider:RefreshAllData()
    end
    self:RefreshMinimapProjectionPins(true)
    self:RefreshWorldMapProjectionControls()
    if type(self.Print) == "function" then
        self:Print("Cleared this farming map's projected pins from the world map and minimap.")
    end
    return true, removedCount
end

function GoldTracker:OpenWorldMapProjectionDetails()
    local projections = GetProjectionStore(self)
    local projection = self.worldMapProjection or projections[#projections]
    if not projection then
        return false
    end
    if type(self.OpenStandaloneMapWindow) ~= "function" then
        if type(self.Print) == "function" then
            self:Print("The standalone map window is unavailable.")
        end
        return false
    end

    self:OpenStandaloneMapWindow({
        title = projection.title,
        projectionKey = projection.projectionKey,
        mapID = projection.mapID,
        pins = projection.pins,
        mapOptions = projection.mapOptions,
        selectedMapOptionIndex = projection.selectedMapOptionIndex,
    })
    return true
end
