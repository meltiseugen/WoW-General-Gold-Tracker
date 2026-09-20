local _, NS = ...
local GoldTracker = NS.GoldTracker

local MapAreaOverlay = {}

local DEFAULT_PADDING_X = 0.018
local DEFAULT_PADDING_Y = 0.026
local DEFAULT_ROUNDING_POINTS = 12
local DEFAULT_FILL_STEP = 3

local function ClampCoordinate(value)
    return math.max(0, math.min(1, value))
end

local function Cross(origin, first, second)
    return ((first.x - origin.x) * (second.y - origin.y))
        - ((first.y - origin.y) * (second.x - origin.x))
end

local function BuildConvexHull(points)
    if #points < 3 then
        return points
    end

    table.sort(points, function(left, right)
        if left.x == right.x then
            return left.y < right.y
        end
        return left.x < right.x
    end)

    local lower = {}
    for _, point in ipairs(points) do
        while #lower >= 2 and Cross(lower[#lower - 1], lower[#lower], point) <= 0 do
            table.remove(lower)
        end
        lower[#lower + 1] = point
    end

    local upper = {}
    for index = #points, 1, -1 do
        local point = points[index]
        while #upper >= 2 and Cross(upper[#upper - 1], upper[#upper], point) <= 0 do
            table.remove(upper)
        end
        upper[#upper + 1] = point
    end

    table.remove(lower)
    table.remove(upper)
    for _, point in ipairs(upper) do
        lower[#lower + 1] = point
    end
    return lower
end

local function GetAreaGroupKey(pinData)
    return tostring(pinData.areaID or pinData.routeID or pinData.spotLocation or "default")
end

local function IsUserDiscoveredPin(pinData)
    return pinData
        and (pinData.sourceType == "user" or pinData.routeType == "user-discovered")
end

local function UserPinAreasOverlap(left, right, paddingX, paddingY)
    local diameterX = math.max(0.0001, paddingX * 2)
    local diameterY = math.max(0.0001, paddingY * 2)
    local normalizedX = (left.x - right.x) / diameterX
    local normalizedY = (left.y - right.y) / diameterY
    return ((normalizedX * normalizedX) + (normalizedY * normalizedY)) <= 1
end

local function BuildUserPinGroups(pins, paddingX, paddingY)
    if #pins == 0 then
        return {}
    end

    local parents = {}
    for index = 1, #pins do
        parents[index] = index
    end

    local function find(index)
        local parent = parents[index]
        while parent ~= parents[parent] do
            parent = parents[parent]
        end
        while index ~= parent do
            local nextIndex = parents[index]
            parents[index] = parent
            index = nextIndex
        end
        return parent
    end

    local function union(leftIndex, rightIndex)
        local leftRoot = find(leftIndex)
        local rightRoot = find(rightIndex)
        if leftRoot ~= rightRoot then
            parents[rightRoot] = leftRoot
        end
    end

    for leftIndex = 1, #pins - 1 do
        for rightIndex = leftIndex + 1, #pins do
            if UserPinAreasOverlap(pins[leftIndex], pins[rightIndex], paddingX, paddingY) then
                union(leftIndex, rightIndex)
            end
        end
    end

    local groupsByRoot = {}
    local groups = {}
    for index, pinData in ipairs(pins) do
        local root = find(index)
        local group = groupsByRoot[root]
        if not group then
            group = {
                key = "user-cluster-" .. tostring(#groups + 1),
                pins = {},
                label = "User-discovered farming cluster",
                isUserCluster = true,
            }
            groupsByRoot[root] = group
            groups[#groups + 1] = group
        end
        group.pins[#group.pins + 1] = pinData
    end
    return groups
end

local function BuildPaddedHull(pins, paddingX, paddingY, roundingPoints)
    local paddedPoints = {}
    for _, pinData in ipairs(pins) do
        for index = 1, roundingPoints do
            local angle = ((index - 1) / roundingPoints) * math.pi * 2
            paddedPoints[#paddedPoints + 1] = {
                x = ClampCoordinate(pinData.x + (math.cos(angle) * paddingX)),
                y = ClampCoordinate(pinData.y + (math.sin(angle) * paddingY)),
            }
        end
    end
    return BuildConvexHull(paddedPoints)
end

function MapAreaOverlay:BuildGroups(pins, mapID, options)
    options = type(options) == "table" and options or {}
    local paddingX = tonumber(options.paddingX) or DEFAULT_PADDING_X
    local paddingY = tonumber(options.paddingY) or DEFAULT_PADDING_Y
    local normalizedMapID = tonumber(mapID)
    local groups = {}
    local orderedGroups = {}
    local userPins = {}

    for _, pinData in ipairs(pins or {}) do
        local x = tonumber(pinData and pinData.x)
        local y = tonumber(pinData and pinData.y)
        if pinData
            and pinData.isRoute ~= true
            and tonumber(pinData.mapID) == normalizedMapID
            and x and y
            and x >= 0 and x <= 1
            and y >= 0 and y <= 1
        then
            if IsUserDiscoveredPin(pinData) then
                userPins[#userPins + 1] = pinData
            else
                local key = GetAreaGroupKey(pinData)
                local group = groups[key]
                if not group then
                    group = {
                        key = key,
                        pins = {},
                        routeID = pinData.routeID,
                        label = pinData.spotLocation or pinData.label or pinData.itemName,
                    }
                    groups[key] = group
                    orderedGroups[#orderedGroups + 1] = group
                end
                group.pins[#group.pins + 1] = pinData
            end
        end
    end

    for _, group in ipairs(BuildUserPinGroups(userPins, paddingX, paddingY)) do
        orderedGroups[#orderedGroups + 1] = group
    end

    return orderedGroups
end

function MapAreaOverlay:BuildPolygons(pins, mapID, options)
    options = type(options) == "table" and options or {}
    local paddingX = tonumber(options.paddingX) or DEFAULT_PADDING_X
    local paddingY = tonumber(options.paddingY) or DEFAULT_PADDING_Y
    local roundingPoints = math.max(6, math.floor(tonumber(options.roundingPoints) or DEFAULT_ROUNDING_POINTS))

    local polygons = {}
    for _, group in ipairs(self:BuildGroups(pins, mapID, options)) do
        local points = BuildPaddedHull(group.pins, paddingX, paddingY, roundingPoints)
        if #points >= 3 then
            polygons[#polygons + 1] = {
                key = group.key,
                routeID = group.routeID,
                label = group.label,
                isUserCluster = group.isUserCluster == true,
                sourcePointCount = #group.pins,
                points = points,
            }
        end
    end
    return polygons
end

local function BuildScanlines(points, width, height, step)
    local pixelPoints = {}
    local minY
    local maxY
    for index, point in ipairs(points or {}) do
        local pixelPoint = {
            x = point.x * width,
            y = point.y * height,
        }
        pixelPoints[index] = pixelPoint
        minY = math.min(minY or pixelPoint.y, pixelPoint.y)
        maxY = math.max(maxY or pixelPoint.y, pixelPoint.y)
    end

    local scanlines = {}
    if #pixelPoints < 3 then
        return scanlines
    end

    local y = minY + (step * 0.5)
    while y <= maxY do
        local intersections = {}
        for index, first in ipairs(pixelPoints) do
            local second = pixelPoints[(index % #pixelPoints) + 1]
            if (first.y <= y and second.y > y) or (second.y <= y and first.y > y) then
                local ratio = (y - first.y) / (second.y - first.y)
                intersections[#intersections + 1] = first.x + ((second.x - first.x) * ratio)
            end
        end
        table.sort(intersections)
        for index = 1, #intersections - 1, 2 do
            scanlines[#scanlines + 1] = {
                x1 = intersections[index],
                x2 = intersections[index + 1],
                y = y,
            }
        end
        y = y + step
    end
    return scanlines
end

local function HideLinePool(owner, poolKey, usedLines)
    for index, line in ipairs(owner[poolKey] or {}) do
        if index > (usedLines or 0) and line.Hide then
            line:Hide()
        end
    end
end

local function GetLine(owner, parent, poolKey, index, layer, subLevel)
    owner[poolKey] = owner[poolKey] or {}
    local line = owner[poolKey][index]
    if not line then
        if not parent or type(parent.CreateLine) ~= "function" then
            return nil
        end
        line = parent:CreateLine(nil, layer or "ARTWORK", nil, subLevel or 0)
        owner[poolKey][index] = line
    end
    if line.SetParent then
        line:SetParent(parent)
    end
    return line
end

local function SetLine(line, parent, x1, y1, x2, y2, thickness, color)
    if not line then
        return false
    end
    line:ClearAllPoints()
    line:SetStartPoint("TOPLEFT", parent, x1, -y1)
    line:SetEndPoint("TOPLEFT", parent, x2, -y2)
    if line.SetThickness then
        line:SetThickness(thickness)
    end
    if line.SetColorTexture then
        line:SetColorTexture(color[1], color[2], color[3], color[4])
    elseif line.SetVertexColor then
        line:SetVertexColor(color[1], color[2], color[3], color[4])
    end
    line:Show()
    return true
end

function MapAreaOverlay:Hide(owner, prefix)
    prefix = prefix or "mapArea"
    HideLinePool(owner, prefix .. "FillLines", 0)
    HideLinePool(owner, prefix .. "GlowLines", 0)
    HideLinePool(owner, prefix .. "BorderLines", 0)
end

function MapAreaOverlay:Render(owner, parent, prefix, polygons, width, height, options)
    options = type(options) == "table" and options or {}
    prefix = prefix or "mapArea"
    self:Hide(owner, prefix)
    if not parent or type(parent.CreateLine) ~= "function" then
        return 0
    end

    width = math.max(1, tonumber(width) or 1)
    height = math.max(1, tonumber(height) or 1)
    local fillStep = tonumber(options.fillStep) or DEFAULT_FILL_STEP
    local fillThickness = tonumber(options.fillThickness) or (fillStep + 0.5)
    local glowThickness = tonumber(options.glowThickness) or 11
    local borderThickness = tonumber(options.borderThickness) or 2.5
    local fillColor = options.fillColor or { 0.08, 0.42, 1.0, 0.20 }
    local glowColor = options.glowColor or { 0.10, 0.50, 1.0, 0.16 }
    local borderColor = options.borderColor or { 0.28, 0.68, 1.0, 0.78 }
    local layer = options.layer or "ARTWORK"
    local fillSubLevel = tonumber(options.fillSubLevel) or -3
    local glowSubLevel = tonumber(options.glowSubLevel) or -2
    local borderSubLevel = tonumber(options.borderSubLevel) or -1
    local fillIndex = 1
    local glowIndex = 1
    local borderIndex = 1
    local renderedPolygons = 0

    for _, polygon in ipairs(polygons or {}) do
        local points = polygon.points or {}
        if #points >= 3 then
            for _, scanline in ipairs(BuildScanlines(points, width, height, fillStep)) do
                local line = GetLine(owner, parent, prefix .. "FillLines", fillIndex, layer, fillSubLevel)
                local rendered = SetLine(
                    line,
                    parent,
                    scanline.x1,
                    scanline.y,
                    scanline.x2,
                    scanline.y,
                    fillThickness,
                    fillColor
                )
                if rendered then
                    fillIndex = fillIndex + 1
                end
            end

            for index, first in ipairs(points) do
                local second = points[(index % #points) + 1]
                local x1 = first.x * width
                local y1 = first.y * height
                local x2 = second.x * width
                local y2 = second.y * height
                local glow = GetLine(owner, parent, prefix .. "GlowLines", glowIndex, layer, glowSubLevel)
                if SetLine(glow, parent, x1, y1, x2, y2, glowThickness, glowColor) then
                    glowIndex = glowIndex + 1
                end
                local border = GetLine(owner, parent, prefix .. "BorderLines", borderIndex, layer, borderSubLevel)
                if SetLine(border, parent, x1, y1, x2, y2, borderThickness, borderColor) then
                    borderIndex = borderIndex + 1
                end
            end
            renderedPolygons = renderedPolygons + 1
        end
    end

    HideLinePool(owner, prefix .. "FillLines", fillIndex - 1)
    HideLinePool(owner, prefix .. "GlowLines", glowIndex - 1)
    HideLinePool(owner, prefix .. "BorderLines", borderIndex - 1)
    return renderedPolygons
end

GoldTracker.MapAreaOverlay = MapAreaOverlay
