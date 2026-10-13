local _, NS = ...
local GoldTracker = NS.GoldTracker
local MapAreaOverlay = GoldTracker.MapAreaOverlay
local RecoveryWaypoint = GoldTracker.FarmRecoveryWaypoint
local Theme = NS.JanisTheme

local HUD_UPDATE_SECONDS = 0.20
local BREADCRUMB_SAMPLE_SECONDS = 1.0
local BREADCRUMB_MIN_YARDS = 10
local BREADCRUMB_MIN_MAP_DISTANCE = 0.0025
local MAX_BREADCRUMBS_PER_MAP = GoldTracker.FarmTrail.MAX_POINTS
local BREADCRUMB_MAX_AGE_SECONDS = GoldTracker.FarmTrail.MAX_AGE_SECONDS
local ROUTE_TOLERANCE_YARDS = 40
local ROUTE_TOLERANCE_MAP_DISTANCE = 0.012

local GUIDANCE_OPTIONS = {
    {
        key = "areaIndicator",
        label = "Area boundary",
        tooltip = "Shows or hides the blue perimeter and transparent blue fill on the minimap. Also controls the INSIDE FARMING AREA or OUTSIDE FARMING AREA status, including how far outside you are.\n\nDoes not hide farm location pins or the red-arrow trail.",
    },
    {
        key = "routeDeviation",
        label = "Route deviation",
        tooltip = string.format(
            "For farms with a planned route, shows ON ROUTE or OFF ROUTE and your distance from the planned line.\n\nMore than %d yards away counts as off-route when yard measurements are available.",
            ROUTE_TOLERANCE_YARDS
        ),
    },
    {
        -- Preserve the saved preference from the old floating-window arrow.
        key = "recoveryArrow",
        label = "Recovery waypoint",
        tooltip = "Places a tracked Blizzard waypoint back to the farming area when you leave it. The pin stays in place and clears automatically as soon as you enter the area. For route-only farms, it clears when you are back on route.\n\nTurning this off removes the recovery pin. Automatic arrival cleanup leaves a different waypoint you set manually alone. Works independently of the other Farm HUD options.",
    },
    {
        key = "breadcrumbs",
        label = "Red-arrow trail",
        tooltip = string.format(
            "Marks where you actually travel with red directional arrows. Keeps at most %d trail points. Each point disappears after %d seconds, even while you stand still.\n\nTurning it off clears the trail.",
            MAX_BREADCRUMBS_PER_MAP,
            BREADCRUMB_MAX_AGE_SECONDS
        ),
    },
}

local function ShowGuidanceTooltip(checkbox)
    if not GameTooltip then
        return
    end
    local option = checkbox.guidanceOption
    GameTooltip:SetOwner(checkbox, "ANCHOR_TOP")
    GameTooltip:SetText(option.label)
    GameTooltip:AddLine(option.tooltip, 1, 1, 1, true)
    GameTooltip:AddLine("Saved separately for each farm.", 0.65, 0.68, 0.76, true)
    GameTooltip:Show()
end

local function HideGuidanceTooltip(checkbox)
    if GameTooltip and GameTooltip:IsOwned(checkbox) then
        GameTooltip:Hide()
    end
end

local Guidance = {}
GoldTracker.FarmGuidance = Guidance

local function NormalizeCoordinate(value)
    local coordinate = tonumber(value)
    if not coordinate then
        return nil
    end
    if coordinate > 1 then
        coordinate = coordinate / 100
    end
    return coordinate >= 0 and coordinate <= 1 and coordinate or nil
end

local function GetPointXY(point)
    if type(point) ~= "table" then
        return nil, nil
    end
    if type(point.GetXY) == "function" then
        local ok, x, y = pcall(point.GetXY, point)
        if ok then
            return tonumber(x), tonumber(y)
        end
    end
    return tonumber(point.x or point[1]), tonumber(point.y or point[2])
end

local function DistanceSquared(firstX, firstY, secondX, secondY)
    return ((firstX - secondX) ^ 2) + ((firstY - secondY) ^ 2)
end

local function ClosestPointOnSegment(pointX, pointY, firstX, firstY, secondX, secondY)
    local deltaX = secondX - firstX
    local deltaY = secondY - firstY
    local lengthSquared = (deltaX * deltaX) + (deltaY * deltaY)
    if lengthSquared <= 0 then
        return firstX, firstY, DistanceSquared(pointX, pointY, firstX, firstY)
    end
    local ratio = (((pointX - firstX) * deltaX) + ((pointY - firstY) * deltaY)) / lengthSquared
    ratio = math.max(0, math.min(1, ratio))
    local targetX = firstX + (deltaX * ratio)
    local targetY = firstY + (deltaY * ratio)
    return targetX, targetY, DistanceSquared(pointX, pointY, targetX, targetY)
end

local function PointIsInsidePolygon(x, y, points)
    local inside = false
    local previous = points and points[#points]
    if not previous then
        return false
    end
    for _, current in ipairs(points) do
        local crosses = (current.y > y) ~= (previous.y > y)
        if crosses then
            local edgeX = ((previous.x - current.x) * (y - current.y))
                / (previous.y - current.y) + current.x
            if x < edgeX then
                inside = not inside
            end
        end
        previous = current
    end
    return inside
end

local function FindClosestPolygonPoint(x, y, polygons)
    local closestX
    local closestY
    local closestDistanceSquared
    for _, polygon in ipairs(polygons or {}) do
        local points = polygon.points or {}
        if PointIsInsidePolygon(x, y, points) then
            return x, y, 0, true
        end
        for index, first in ipairs(points) do
            local second = points[(index % #points) + 1]
            local targetX, targetY, distanceSquared = ClosestPointOnSegment(
                x, y, first.x, first.y, second.x, second.y
            )
            if not closestDistanceSquared or distanceSquared < closestDistanceSquared then
                closestX = targetX
                closestY = targetY
                closestDistanceSquared = distanceSquared
            end
        end
    end
    return closestX, closestY, closestDistanceSquared, false
end

local function FindClosestRoutePoint(x, y, pins, mapID)
    local closestX
    local closestY
    local closestDistanceSquared
    local previous
    for _, pin in ipairs(pins or {}) do
        local pinX = NormalizeCoordinate(pin and pin.x)
        local pinY = NormalizeCoordinate(pin and pin.y)
        if pin and pin.isRoute == true and pin.routeType ~= "farm-breadcrumb"
            and tonumber(pin.mapID or mapID) == mapID and pinX and pinY then
            local pointDistance = DistanceSquared(x, y, pinX, pinY)
            if not closestDistanceSquared or pointDistance < closestDistanceSquared then
                closestX = pinX
                closestY = pinY
                closestDistanceSquared = pointDistance
            end
            if previous and previous.routeID == pin.routeID then
                local targetX, targetY, segmentDistance = ClosestPointOnSegment(
                    x, y, previous.x, previous.y, pinX, pinY
                )
                if not closestDistanceSquared or segmentDistance < closestDistanceSquared then
                    closestX = targetX
                    closestY = targetY
                    closestDistanceSquared = segmentDistance
                end
            end
            previous = { x = pinX, y = pinY, routeID = pin.routeID }
        else
            previous = nil
        end
    end
    return closestX, closestY, closestDistanceSquared
end

function Guidance:Evaluate(pins, mapID, playerX, playerY, cachedPolygons)
    playerX = NormalizeCoordinate(playerX)
    playerY = NormalizeCoordinate(playerY)
    mapID = tonumber(mapID)
    if not playerX or not playerY or not mapID then
        return nil
    end

    local routeX, routeY, routeDistanceSquared = FindClosestRoutePoint(playerX, playerY, pins, mapID)
    if routeX and routeY then
        return {
            mode = "route",
            targetX = routeX,
            targetY = routeY,
            normalizedDistance = math.sqrt(routeDistanceSquared or 0),
        }
    end

    local polygons = cachedPolygons
    if type(polygons) ~= "table" then
        polygons = MapAreaOverlay and MapAreaOverlay:BuildPolygons(pins, mapID) or {}
    end
    local areaX, areaY, areaDistanceSquared, inside = FindClosestPolygonPoint(playerX, playerY, polygons)
    if areaX and areaY then
        return {
            mode = "area",
            targetX = areaX,
            targetY = areaY,
            normalizedDistance = math.sqrt(areaDistanceSquared or 0),
            inside = inside == true,
        }
    end
    return nil
end

local function GetPlayerPosition(mapID)
    if type(C_Map) ~= "table" or type(C_Map.GetPlayerMapPosition) ~= "function" then
        return nil, nil
    end
    local ok, point = pcall(C_Map.GetPlayerMapPosition, mapID, "player")
    if not ok then
        return nil, nil
    end
    local x, y = GetPointXY(point)
    x = NormalizeCoordinate(x)
    y = NormalizeCoordinate(y)
    if x == 0 and y == 0 then
        return nil, nil
    end
    return x, y
end

local function GetWorldPosition(mapID, x, y)
    if type(C_Map) ~= "table" or type(C_Map.GetWorldPosFromMapPos) ~= "function"
        or type(CreateVector2D) ~= "function" then
        return nil
    end
    local pointOK, mapPoint = pcall(CreateVector2D, x, y)
    if not pointOK or not mapPoint then
        return nil
    end
    local ok, first, second = pcall(C_Map.GetWorldPosFromMapPos, mapID, mapPoint)
    if not ok then
        return nil
    end
    if type(second) == "table" then
        local worldX, worldY = GetPointXY(second)
        return worldX and worldY and { continentID = tonumber(first), x = worldX, y = worldY } or nil
    end
    if type(first) == "table" then
        local worldX, worldY = GetPointXY(first)
        return worldX and worldY and { x = worldX, y = worldY } or nil
    end
    if tonumber(first) and tonumber(second) then
        return { x = tonumber(first), y = tonumber(second) }
    end
    return nil
end

local function GetWorldDistance(mapID, firstX, firstY, secondX, secondY)
    local first = GetWorldPosition(mapID, firstX, firstY)
    local second = GetWorldPosition(mapID, secondX, secondY)
    if not first or not second
        or (first.continentID and second.continentID and first.continentID ~= second.continentID) then
        return nil
    end
    return math.sqrt(DistanceSquared(first.x, first.y, second.x, second.y))
end

local function AllGuidanceDisabled(settings)
    return settings.areaIndicator == false
        and settings.routeDeviation == false
        and settings.recoveryArrow == false
        and settings.breadcrumbs == false
end

local function SetStatusColor(fontString, red, green, blue)
    if fontString and fontString.SetTextColor then
        fontString:SetTextColor(red, green, blue)
    end
end

local function FormatDistance(yards, normalizedDistance)
    if yards then
        return string.format("%d yd", math.floor(yards + 0.5))
    end
    if normalizedDistance then
        return string.format("%.1f%% of map", normalizedDistance * 100)
    end
    return "distance unavailable"
end

function GoldTracker:CreateFarmingHud()
    if self.farmingHudFrame or type(CreateFrame) ~= "function" or not UIParent then
        return self.farmingHudFrame
    end
    local template = BackdropTemplateMixin and "BackdropTemplate" or nil
    local frame = CreateFrame("Frame", "GoldTrackerFarmingHud", UIParent, template)
    frame:SetSize(360, 184)
    frame:SetPoint("TOP", UIParent, "TOP", 0, -170)
    frame:SetFrameStrata("HIGH")
    frame:SetClampedToScreen(true)
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
    if frame.SetBackdrop then
        frame:SetBackdrop({
            bgFile = "Interface\\Buttons\\WHITE8X8",
            edgeFile = "Interface\\Buttons\\WHITE8X8",
            edgeSize = 1,
        })
        frame:SetBackdropColor(0.018, 0.025, 0.04, 0.92)
        frame:SetBackdropBorderColor(0.42, 1.0, 0.72, 0.58)
    end

    frame.titleText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    frame.titleText:SetPoint("TOPLEFT", frame, "TOPLEFT", 12, -10)
    frame.titleText:SetPoint("RIGHT", frame, "RIGHT", -12, 0)
    frame.titleText:SetJustifyH("LEFT")
    frame.titleText:SetWordWrap(false)
    frame.titleText:SetTextColor(0.42, 1.0, 0.72)

    frame.statusText = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    frame.statusText:SetPoint("TOPLEFT", frame.titleText, "BOTTOMLEFT", 0, -7)
    frame.statusText:SetPoint("RIGHT", frame, "RIGHT", -12, 0)
    frame.statusText:SetJustifyH("LEFT")
    frame.statusText:SetWordWrap(false)

    frame.detailText = frame:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    frame.detailText:SetPoint("TOPLEFT", frame.statusText, "BOTTOMLEFT", 0, -5)
    frame.detailText:SetPoint("RIGHT", frame, "RIGHT", -12, 0)
    frame.detailText:SetJustifyH("LEFT")
    frame.detailText:SetWordWrap(false)

    local guidancePanel = Theme:CreatePanel(frame, { 0.035, 0.055, 0.075, 0.92 }, { 0.42, 1.0, 0.72, 0.16 })
    guidancePanel:SetPoint("TOPLEFT", frame, "TOPLEFT", 12, -76)
    guidancePanel:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -12, -76)
    guidancePanel:SetHeight(68)
    frame.guidancePanel = guidancePanel

    local guidanceLabel = guidancePanel:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    guidanceLabel:SetPoint("TOPLEFT", guidancePanel, "TOPLEFT", 8, -6)
    guidanceLabel:SetTextColor(0.42, 1.0, 0.72)
    guidanceLabel:SetText("Farm HUD:")

    frame.guidanceCheckboxes = {}
    for index, option in ipairs(GUIDANCE_OPTIONS) do
        local settingKey = option.key
        local column = (index - 1) % 2
        local row = math.floor((index - 1) / 2)
        local checkbox = CreateFrame("CheckButton", nil, guidancePanel, "UICheckButtonTemplate")
        checkbox:SetSize(22, 22)
        checkbox:SetPoint("TOPLEFT", guidancePanel, "TOPLEFT", 8 + (column * 168), -20 - (row * 22))
        -- Include the label in the hover/click area without overlapping columns.
        checkbox:SetHitRectInsets(0, -132, 0, 0)
        checkbox.guidanceOption = option
        checkbox:SetScript("OnEnter", ShowGuidanceTooltip)
        checkbox:SetScript("OnLeave", HideGuidanceTooltip)
        checkbox:SetScript("OnHide", HideGuidanceTooltip)
        checkbox:SetScript("OnClick", function(button)
            local runtime = GoldTracker.farmingHudRuntime
            if runtime and runtime.farmID then
                GoldTracker:SetCustomFarmGuidanceSetting(runtime.farmID, settingKey, button:GetChecked() == true)
            end
        end)
        local label = guidancePanel:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        label:SetPoint("LEFT", checkbox, "RIGHT", 2, 1)
        label:SetText(option.label)
        frame.guidanceCheckboxes[settingKey] = checkbox
    end

    local stopButton = Theme:CreateButton(frame, 54, 20, "Stop", "danger")
    stopButton:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -12, 9)
    stopButton:SetScript("OnClick", function()
        local active = GoldTracker:GetActiveCustomFarmRoutePlan()
        if active and active.farm then
            GoldTracker:StopCustomFarmRoutePlan(active.farm.id)
        end
    end)
    frame.stopButton = stopButton

    local nextButton = Theme:CreateButton(frame, 54, 20, "Next", "primary")
    nextButton:SetPoint("RIGHT", stopButton, "LEFT", -6, 0)
    nextButton:SetScript("OnClick", function()
        GoldTracker:NavigateActiveCustomFarmRoutePlanStep(1)
    end)
    frame.nextButton = nextButton

    local prevButton = Theme:CreateButton(frame, 54, 20, "Prev", "primary")
    prevButton:SetPoint("RIGHT", nextButton, "LEFT", -6, 0)
    prevButton:SetScript("OnClick", function()
        GoldTracker:NavigateActiveCustomFarmRoutePlanStep(-1)
    end)
    frame.prevButton = prevButton

    frame:RegisterEvent("PLAYER_ENTERING_WORLD")
    frame:RegisterEvent("ZONE_CHANGED")
    frame:RegisterEvent("ZONE_CHANGED_INDOORS")
    frame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
    frame:SetScript("OnEvent", function()
        GoldTracker:RefreshFarmingHud(true)
    end)
    frame:SetScript("OnUpdate", function(_, elapsed)
        GoldTracker:UpdateFarmingHudTracking(elapsed)
    end)
    frame:Hide()
    self.farmingHudFrame = frame
    return frame
end

function GoldTracker:RefreshFarmingHudOverlayButtons()
    local frame = self.farmingHudFrame
    local settings = self.farmingHudRuntime and self.farmingHudRuntime.settings
    if not frame or not settings then
        return false
    end
    local active = self.farmingHudRuntime.active
    for key, checkbox in pairs(frame.guidanceCheckboxes or {}) do
        checkbox:SetChecked(settings[key] ~= false)
        checkbox:SetEnabled(active ~= nil)
    end
    local canGoPrevious = active and active.canGoPrevious == true
    if frame.prevButton then
        frame.prevButton:SetShown(true)
        frame.prevButton:SetEnabled(canGoPrevious == true)
        frame.prevButton:SetAlpha(canGoPrevious and 1 or 0.55)
    end
    local canGoNext = active and active.canGoNext == true
    if frame.nextButton then
        frame.nextButton:SetShown(canGoNext == true)
        frame.nextButton:SetEnabled(canGoNext == true)
    end
    if frame.stopButton then
        frame.stopButton:SetEnabled(active ~= nil)
    end
    return true
end

function GoldTracker:ClearFarmingHudBreadcrumbs()
    local runtime = self.farmingHudRuntime
    for projectionKey in pairs(runtime and runtime.breadcrumbProjectionKeys or {}) do
        if type(self.ClearWorldMapProjectionByKey) == "function" then
            self:ClearWorldMapProjectionByKey(projectionKey, true)
        end
    end
    if runtime then
        runtime.breadcrumbProjectionKeys = {}
        runtime.breadcrumbsByMap = {}
        runtime.lastBreadcrumbByMap = {}
    end
end

function GoldTracker:StopFarmingHud()
    RecoveryWaypoint:Clear(self.farmingHudRuntime)
    self:ClearFarmingHudBreadcrumbs()
    self.farmingHudRuntime = nil
    if self.farmingHudFrame then
        self.farmingHudFrame:Hide()
    end
end

local function BuildGuidanceContext(addon, active)
    local node = active and active.currentNode
    local projection = node and addon:BuildCustomFarmRoutePlanStepProjection(active.farm.id, node.key) or nil
    if not projection then
        return nil
    end
    local mapID = tonumber(projection.mapID)
    local pins = projection.pins or {}
    return {
        mapID = mapID,
        mapName = projection.mapLabel or node.mapName,
        pins = pins,
        polygons = MapAreaOverlay and MapAreaOverlay:BuildPolygons(pins, mapID) or {},
        stepKey = node.key,
    }
end

function GoldTracker:RefreshFarmingHud(force)
    local active = type(self.GetActiveCustomFarmRoutePlan) == "function"
        and self:GetActiveCustomFarmRoutePlan() or nil
    if not active or not active.farm or not active.currentNode then
        self:StopFarmingHud()
        return nil
    end
    local settings = type(self.GetCustomFarmGuidanceSettings) == "function"
        and self:GetCustomFarmGuidanceSettings(active.farm.id) or nil
    settings = settings or {
        areaIndicator = true,
        routeDeviation = true,
        recoveryArrow = true,
        breadcrumbs = true,
    }
    local runtime = self.farmingHudRuntime
    if not runtime or runtime.farmID ~= active.farm.id then
        self:StopFarmingHud()
        runtime = {
            farmID = active.farm.id,
            breadcrumbsByMap = {},
            breadcrumbProjectionKeys = {},
            lastBreadcrumbByMap = {},
        }
        self.farmingHudRuntime = runtime
    end
    runtime.active = active
    runtime.settings = settings
    if runtime.context and runtime.context.stepKey ~= active.currentNode.key then
        RecoveryWaypoint:Clear(runtime)
    end
    if force == true or not runtime.context or runtime.context.stepKey ~= active.currentNode.key then
        runtime.context = BuildGuidanceContext(self, active)
    end
    if settings.breadcrumbs == false then
        self:ClearFarmingHudBreadcrumbs()
    end
    if settings.recoveryArrow == false then
        RecoveryWaypoint:Clear(runtime)
    end

    local frame = self:CreateFarmingHud()
    if frame then
        frame.titleText:SetText("FARMING: " .. tostring(active.farm.name or "Custom farm"))
        self:RefreshFarmingHudOverlayButtons()
        frame:Show()
    end
    self:UpdateFarmingHudTracking(0, true)
    return active
end

function GoldTracker:RefreshFarmingHudBreadcrumbProjection(mapID)
    local runtime = self.farmingHudRuntime
    local points = runtime and runtime.breadcrumbsByMap and runtime.breadcrumbsByMap[mapID] or nil
    if not runtime then
        return false
    end
    local projectionKey = "active-farm-breadcrumb:" .. tostring(runtime.farmID) .. ":" .. tostring(mapID)
    if not points or #points == 0 then
        if runtime.breadcrumbProjectionKeys[projectionKey] then
            runtime.breadcrumbProjectionKeys[projectionKey] = nil
            if type(self.ClearWorldMapProjectionByKey) == "function" then
                return self:ClearWorldMapProjectionByKey(projectionKey, true) == true
            end
        end
        return false
    end
    if type(self.ProjectMapRouteToWorldMap) ~= "function" then
        return false
    end
    local pins = {}
    for index, point in ipairs(points) do
        pins[index] = {
            mapID = mapID,
            x = point.x,
            y = point.y,
            label = "Trail arrow " .. tostring(index),
            isRoute = true,
            routeID = projectionKey,
            routeType = "farm-breadcrumb",
        }
    end
    runtime.breadcrumbProjectionKeys[projectionKey] = true
    return self:ProjectMapRouteToWorldMap({
        title = "Red-arrow trail - " .. tostring(runtime.active.farm.name or "Custom farm"),
        projectionKey = projectionKey,
        mapID = mapID,
        mapLabel = runtime.context and runtime.context.mapName,
        pins = pins,
        displayMode = "icons",
        silent = true,
        openMap = false,
        background = true,
    }) == true
end

function GoldTracker:ExpireFarmingHudBreadcrumbs()
    local runtime = self.farmingHudRuntime
    if not runtime then
        return
    end
    local now = GetTime()
    for mapID, points in pairs(runtime.breadcrumbsByMap) do
        local expired = false
        while points[1] and now - points[1].recordedAt >= BREADCRUMB_MAX_AGE_SECONDS do
            table.remove(points, 1)
            expired = true
        end
        if expired then
            if #points == 0 then
                runtime.breadcrumbsByMap[mapID] = nil
            end
            self:RefreshFarmingHudBreadcrumbProjection(mapID)
        end
    end
end

function GoldTracker:RecordFarmingHudBreadcrumb(mapID, x, y)
    local runtime = self.farmingHudRuntime
    if not runtime or not runtime.settings or runtime.settings.breadcrumbs == false then
        return false
    end
    -- Keep the last position after visible points expire, so standing still
    -- cannot recreate the trail once it has cleared.
    local previous = runtime.lastBreadcrumbByMap[mapID]
    if previous then
        local yards = GetWorldDistance(mapID, previous.x, previous.y, x, y)
        local normalizedDistance = math.sqrt(DistanceSquared(previous.x, previous.y, x, y))
        if (yards and yards < BREADCRUMB_MIN_YARDS)
            or (not yards and normalizedDistance < BREADCRUMB_MIN_MAP_DISTANCE) then
            return false
        end
    end
    runtime.breadcrumbsByMap[mapID] = runtime.breadcrumbsByMap[mapID] or {}
    local points = runtime.breadcrumbsByMap[mapID]
    local point = { x = x, y = y, recordedAt = GetTime() }
    points[#points + 1] = point
    runtime.lastBreadcrumbByMap[mapID] = point
    if #points > MAX_BREADCRUMBS_PER_MAP then
        table.remove(points, 1)
    end
    self:RefreshFarmingHudBreadcrumbProjection(mapID)
    return true
end

function GoldTracker:UpdateFarmingHudTracking(elapsed, force)
    local runtime = self.farmingHudRuntime
    local frame = self.farmingHudFrame
    if not runtime or not frame or not frame:IsShown() then
        return false
    end
    runtime.updateElapsed = (runtime.updateElapsed or 0) + (tonumber(elapsed) or 0)
    if force ~= true and runtime.updateElapsed < HUD_UPDATE_SECONDS then
        return false
    end
    runtime.updateElapsed = 0

    -- Age every map's trail independently of movement or position availability.
    self:ExpireFarmingHudBreadcrumbs()

    local active = runtime.active
    local settings = runtime.settings or {}
    local context = runtime.context
    if AllGuidanceDisabled(settings) then
        frame.statusText:SetText("FARM GUIDANCE OFF")
        SetStatusColor(frame.statusText, 0.62, 0.68, 0.76)
        frame.detailText:SetText("Enable a Farm HUD option below.")
        RecoveryWaypoint:Clear(runtime)
        return true
    end
    if not active or not context or not context.mapID then
        frame.statusText:SetText("Guidance unavailable for this farm location")
        SetStatusColor(frame.statusText, 1.0, 0.52, 0.30)
        frame.detailText:SetText("The location has no usable map geometry.")
        RecoveryWaypoint:Clear(runtime)
        return false
    end

    local playerX, playerY = GetPlayerPosition(context.mapID)
    if not playerX or not playerY then
        frame.statusText:SetText("Travel to " .. tostring(context.mapName or "the farm map"))
        SetStatusColor(frame.statusText, 1.0, 0.72, 0.24)
        frame.detailText:SetText("The farm area cannot be measured from the current map.")
        RecoveryWaypoint:Clear(runtime)
        return false
    end

    local result = Guidance:Evaluate(
        context.pins,
        context.mapID,
        playerX,
        playerY,
        context.polygons
    )
    local distanceYards = result and GetWorldDistance(
        context.mapID, playerX, playerY, result.targetX, result.targetY
    ) or nil
    local onTrack = result and (
        result.mode == "area" and result.inside == true
        or result.mode == "route" and (
            distanceYards and distanceYards <= ROUTE_TOLERANCE_YARDS
            or not distanceYards and result.normalizedDistance <= ROUTE_TOLERANCE_MAP_DISTANCE
        )
    ) or false

    local navigationPoint = {
        mapID = tonumber(active.currentNode.mapID),
        x = NormalizeCoordinate(active.currentNode.x),
        y = NormalizeCoordinate(active.currentNode.y),
    }
    if not navigationPoint.mapID or not navigationPoint.x or not navigationPoint.y then
        navigationPoint = nil
    end
    local recoveryTarget
    if settings.recoveryArrow ~= false then
        -- Entering any part of the area counts as arrival, even when its
        -- planned route is farther away than the route-deviation tolerance.
        local areaX, areaY, _, inside = FindClosestPolygonPoint(playerX, playerY, context.polygons)
        if areaX and areaY then
            if not inside then
                recoveryTarget = { mapID = context.mapID, x = areaX, y = areaY }
            end
        elseif result and not onTrack then
            recoveryTarget = { mapID = context.mapID, x = result.targetX, y = result.targetY }
        end
    end
    local recoveryActive
    if settings.recoveryArrow ~= false and result then
        recoveryActive = RecoveryWaypoint:Update(runtime, recoveryTarget, navigationPoint)
    else
        RecoveryWaypoint:Clear(runtime)
    end
    local recoveryHint = recoveryActive and " - follow the waypoint back" or ""

    local showIndicator = result and (
        result.mode == "route" and settings.routeDeviation ~= false
        or result.mode == "area" and settings.areaIndicator ~= false
    )
    if showIndicator and result.mode == "route" then
        frame.statusText:SetText(onTrack and "ON ROUTE" or "OFF ROUTE")
        SetStatusColor(frame.statusText, onTrack and 0.42 or 1.0, onTrack and 1.0 or 0.48, onTrack and 0.72 or 0.22)
        frame.detailText:SetText(
            FormatDistance(distanceYards, result.normalizedDistance)
                .. (onTrack and " from the planned line" or (" away" .. recoveryHint))
        )
    elseif showIndicator and result.mode == "area" then
        frame.statusText:SetText(onTrack and "INSIDE FARMING AREA" or "OUTSIDE FARMING AREA")
        SetStatusColor(frame.statusText, onTrack and 0.42 or 1.0, onTrack and 1.0 or 0.48, onTrack and 0.72 or 0.22)
        frame.detailText:SetText(onTrack and "Remain inside the projected overlay."
            or (FormatDistance(distanceYards, result.normalizedDistance) .. " outside" .. recoveryHint))
    elseif settings.breadcrumbs ~= false then
        local breadcrumbCount = #(runtime.breadcrumbsByMap[context.mapID] or {})
        frame.statusText:SetText("BREADCRUMB TRAIL ACTIVE")
        SetStatusColor(frame.statusText, 0.42, 0.86, 1.0)
        frame.detailText:SetText(string.format("%d trail %s recorded on this map.", breadcrumbCount, breadcrumbCount == 1 and "point" or "points"))
    else
        frame.statusText:SetText(recoveryActive and "RECOVERY WAYPOINT ACTIVE" or "RECOVERY WAYPOINT READY")
        SetStatusColor(frame.statusText, 1.0, 0.82, 0.32)
        frame.detailText:SetText(recoveryActive and "Follow the waypoint back; it clears when you return."
            or (result and "A waypoint appears when you leave the farm area or route." or "No usable farm geometry."))
    end

    runtime.breadcrumbElapsed = (runtime.breadcrumbElapsed or 0) + HUD_UPDATE_SECONDS
    if settings.breadcrumbs ~= false
        and (force == true or runtime.breadcrumbElapsed >= BREADCRUMB_SAMPLE_SECONDS) then
        runtime.breadcrumbElapsed = 0
        self:RecordFarmingHudBreadcrumb(context.mapID, playerX, playerY)
    end
    return true
end

if type(CreateFrame) == "function" then
    local bootstrap = CreateFrame("Frame")
    bootstrap:RegisterEvent("PLAYER_LOGIN")
    bootstrap:SetScript("OnEvent", function(self)
        if self.UnregisterEvent then
            self:UnregisterEvent("PLAYER_LOGIN")
        end
        GoldTracker:RefreshFarmingHud(true)
    end)
end
