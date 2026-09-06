local _, NS = ...
local GoldTracker = NS.GoldTracker
local Theme = NS.JanisTheme

local PIN_TEMPLATE = "GoldTrackerWorldMapRoutePinTemplate"
local LINE_THICKNESS = 3
local PIN_BASE_SIZE = 26
local PIN_ICON_SIZE = 18
local PIN_RING_SIZE = 32
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

LoadBlizzardMapAddOns()

local function FocusWorldMapFrame()
    if not WorldMapFrame or not Theme then
        return
    end

    if type(Theme.RegisterExternalFocusFrames) == "function" then
        Theme:RegisterExternalFocusFrames({ "WorldMapFrame" })
    end
    if type(Theme.BringManagedWindowToFront) == "function" then
        Theme:BringManagedWindowToFront(WorldMapFrame)
    elseif type(WorldMapFrame.Raise) == "function" then
        WorldMapFrame:Raise()
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
        routeType = pinData.routeType,
        density = pinData.density,
        dropDifficulty = pinData.dropDifficulty,
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
                mapID = tonumber(option.mapID),
                label = option.label,
                spotCount = option.spotCount,
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
    if type(pinData.itemName) == "string" and pinData.itemName ~= "" then
        tooltip:AddDoubleLine("Item", pinData.itemName, 0.72, 0.86, 1.0, 1, 1, 1)
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

local function OpenWorldMapToMapID(mapID)
    LoadBlizzardMapAddOns()

    local mapFrame = WorldMapFrame
    if mapFrame and mapFrame.IsShown and mapFrame:IsShown() then
        if mapFrame.SetMapID then
            mapFrame:SetMapID(mapID)
        end
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
                if ring.SetColorTexture then
                    ring:SetColorTexture(1.0, 0.82, 0.18, 0.58)
                elseif ring.SetTexture then
                    ring:SetTexture("Interface\\Buttons\\WHITE8X8")
                end
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
                if icon.SetTexture then
                    icon:SetTexture("Interface\\Icons\\INV_Misc_Map02")
                end
                if icon.SetTexCoord then
                    icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
                end
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

        function providerMixin:GetRouteLine(index, canvas)
            self.routeLines = self.routeLines or {}
            local line = self.routeLines[index]
            if not line then
                if not canvas or type(canvas.CreateLine) ~= "function" then
                    return nil
                end
                line = canvas:CreateLine(nil, "ARTWORK")
                self.routeLines[index] = line
            end
            line:SetParent(canvas)
            return line
        end

        function providerMixin:RefreshRouteLines()
            self:HideRouteLines()
            local projection = self.addon and self.addon.worldMapProjection
            local map = self:GetMap()
            if not projection or not map or not map.GetMapID or projection.mapID ~= map:GetMapID() then
                return
            end

            local canvas = map:GetCanvas()
            if not canvas or not canvas.GetWidth or not canvas.GetHeight then
                return
            end

            local width = math.max(1, canvas:GetWidth() or 1)
            local height = math.max(1, canvas:GetHeight() or 1)
            local pins = projection.pins or {}
            for index = 1, #pins - 1 do
                local fromPin = pins[index]
                local toPin = pins[index + 1]
                local line = self:GetRouteLine(index, canvas)
                if line and fromPin and toPin then
                    line:ClearAllPoints()
                    line:SetStartPoint("TOPLEFT", canvas, width * fromPin.x, -(height * fromPin.y))
                    line:SetEndPoint("TOPLEFT", canvas, width * toPin.x, -(height * toPin.y))
                    if line.SetThickness then
                        line:SetThickness(LINE_THICKNESS)
                    end
                    if line.SetColorTexture then
                        line:SetColorTexture(1.0, 0.82, 0.18, 0.58)
                    elseif line.SetVertexColor then
                        line:SetVertexColor(1.0, 0.82, 0.18, 0.58)
                    end
                    line:Show()
                end
            end
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
        end

        function providerMixin:RefreshAllData()
            self:RemoveAllData()
            local projection = self.addon and self.addon.worldMapProjection
            local map = self:GetMap()
            if not projection or not map or not map.GetMapID or projection.mapID ~= map:GetMapID() then
                return
            end

            self:RefreshRouteLines()
            self.acquiredPins = {}
            for index, pinData in ipairs(projection.pins or {}) do
                local pin = map:AcquirePin(PIN_TEMPLATE, self, pinData, index, #projection.pins)
                pin:SetPosition(pinData.x, pinData.y)
                if pin.ApplyGoldTrackerScale then
                    pin:ApplyGoldTrackerScale()
                end
                self.acquiredPins[#self.acquiredPins + 1] = pin
            end
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

EnsureWorldMapOverlayMixins()

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
    local shouldShow = self.worldMapProjection ~= nil
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

    self.worldMapProjection = projection

    local providerReady, message = self:EnsureWorldMapProjectionProvider()
    if not providerReady then
        if type(self.Print) == "function" then
            self:Print(message)
        end
        return false, message
    end

    local opened = OpenWorldMapToMapID(projection.mapID)
    if opened then
        FocusWorldMapFrame()
    end
    if self.worldMapRouteDataProvider then
        self.worldMapRouteDataProvider:RefreshAllData()
    end
    self:RefreshWorldMapProjectionControls()

    if type(self.Print) == "function" then
        local suffix = opened and "" or " Open the world map after combat to view it."
        self:Print(string.format(
            "Projected %d %s on %s.%s",
            #projection.pins,
            #projection.pins == 1 and "pin" or "route pins",
            projection.mapName,
            suffix
        ))
    end
    return true
end

function GoldTracker:ClearWorldMapProjection()
    self.worldMapProjection = nil
    if self.worldMapRouteDataProvider then
        self.worldMapRouteDataProvider:RemoveAllData()
    end
    self:RefreshWorldMapProjectionControls()
    if type(self.Print) == "function" then
        self:Print("Cleared projected farming route from the world map.")
    end
    return true
end

function GoldTracker:OpenWorldMapProjectionDetails()
    local projection = self.worldMapProjection
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
        mapID = projection.mapID,
        pins = projection.pins,
        mapOptions = projection.mapOptions,
        selectedMapOptionIndex = projection.selectedMapOptionIndex,
    })
    return true
end
