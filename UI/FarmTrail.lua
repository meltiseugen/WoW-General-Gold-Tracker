local _, NS = ...
local GoldTracker = NS.GoldTracker
local FarmTrail = { MAX_POINTS = 15, MAX_AGE_SECONDS = 15 }
local ARROW_SIZE = 14
local MIN_ARROW_SPACING = 12
local TRAIL_REFRESH_SECONDS = 0.05

function FarmTrail:HideArrow(owner)
    if not owner.goldTrackerTrailDirection then
        return
    end
    for _, line in ipairs(owner.goldTrackerTrailLines or {}) do
        line:Hide()
    end
    owner.goldTrackerTrailDirection = nil
end

function FarmTrail:DrawArrow(owner, dx, dy)
    local length = math.sqrt((dx * dx) + (dy * dy))
    if length < 0.001 then
        self:HideArrow(owner)
        return
    end
    dx, dy = dx / length, dy / length
    local previous = owner.goldTrackerTrailDirection
    if previous and math.abs(previous.x - dx) < 0.001 and math.abs(previous.y - dy) < 0.001 then
        return
    end
    owner.goldTrackerTrailDirection = { x = dx, y = dy }
    owner.goldTrackerTrailLines = owner.goldTrackerTrailLines or {}
    local tipX, tipY = dx * 5, dy * 5
    local backX, backY = -dx * 2, -dy * 2
    local points = {
        { backX - dy * 4, backY + dx * 4, tipX, tipY },
        { backX + dy * 4, backY - dx * 4, tipX, tipY },
    }
    for index, point in ipairs(points) do
        for layer = 1, 2 do
            local lineIndex = ((index - 1) * 2) + layer
            local line = owner.goldTrackerTrailLines[lineIndex]
            if not line then
                line = owner:CreateLine(nil, "OVERLAY", nil, layer == 1 and 6 or 7)
                line:SetThickness(layer == 1 and 4.5 or 2.5)
                if layer == 1 then
                    line:SetColorTexture(0.12, 0.01, 0.01, 0.90)
                else
                    line:SetColorTexture(1.0, 0.12, 0.08, 0.96)
                end
                owner.goldTrackerTrailLines[lineIndex] = line
            end
            line:ClearAllPoints()
            line:SetStartPoint("CENTER", owner, point[1], point[2])
            line:SetEndPoint("CENTER", owner, point[3], point[4])
            line:Show()
        end
    end
end

local function RemovePin(owner, pin)
    if not pin.pinData and not pin.minimapPinLibrary then
        return
    end
    if pin.minimapPinLibrary then
        pin.minimapPinLibrary:RemoveMinimapIcon(owner, pin)
        pin.minimapPinLibrary = nil
    end
    pin.pinData = nil
    pin.previousPin, pin.nextPin = nil, nil
    pin:Hide()
    FarmTrail:HideArrow(pin)
end

function FarmTrail:UpdateDirections(owner)
    local trail = owner.minimapFarmTrail
    if not trail or not trail.active then
        return
    end
    local lastX, lastY, lastRoute
    for index = trail.usedPins, 1, -1 do
        local pin = trail.pins[index]
        local from, to
        if pin:IsShown() then
            if pin.previousPin and pin.previousPin:IsShown() then
                from, to = pin.previousPin, pin
            elseif pin.nextPin and pin.nextPin:IsShown() then
                from, to = pin, pin.nextPin
            end
        end
        local fromX, fromY, toX, toY
        if from and to then
            fromX, fromY = from:GetCenter()
            toX, toY = to:GetCenter()
        end
        local x, y = pin:GetCenter()
        local tooClose = x and y and lastX and lastRoute == pin.pinData.routeID
            and (((x - lastX) ^ 2) + ((y - lastY) ^ 2)) < (MIN_ARROW_SPACING ^ 2)
        if fromX and fromY and toX and toY and not tooClose then
            -- Both points are positioned by the same map-pin library. Direction
            -- follows the travelled path, not the character or camera heading.
            self:DrawArrow(pin, toX - fromX, toY - fromY)
            -- Keep separate arrowheads when zoomed out, rather than a solid stripe.
            lastX, lastY, lastRoute = x, y, pin.pinData.routeID
        else
            self:HideArrow(pin)
        end
    end
end

function FarmTrail:HideMinimap(owner)
    local trail = owner.minimapFarmTrail
    if not trail or not trail.active then
        return
    end
    trail.active = false
    trail.usedPins = 0
    trail.frame.elapsed = 0
    for _, pin in ipairs(trail.pins) do
        RemovePin(owner, pin)
    end
    trail.frame:Hide()
end

function FarmTrail:RefreshMinimap(owner, pins, library, positionFallback, radius, enabled)
    if not enabled then
        self:HideMinimap(owner)
        return 0
    end
    local trail = owner.minimapFarmTrail
    if not trail then
        trail = { pins = {}, usedPins = 0 }
        trail.frame = CreateFrame("Frame", nil, Minimap)
        trail.frame:SetSize(1, 1)
        trail.frame:SetPoint("CENTER", Minimap, "CENTER")
        trail.frame:EnableMouse(false)
        trail.frame:SetScript("OnUpdate", function(frame, elapsed)
            frame.elapsed = (frame.elapsed or 0) + elapsed
            if frame.elapsed < TRAIL_REFRESH_SECONDS then
                return
            end
            frame.elapsed = 0
            self:UpdateDirections(owner)
        end)
        owner.minimapFarmTrail = trail
    end
    local used = 0
    local previousPin
    for _, pinData in ipairs(pins) do
        if pinData.routeType == "farm-breadcrumb" and used < self.MAX_POINTS then
            used = used + 1
            local pin = trail.pins[used]
            if not pin then
                pin = CreateFrame("Frame", nil, Minimap)
                pin:SetSize(ARROW_SIZE, ARROW_SIZE)
                pin:EnableMouse(false)
                pin:SetFrameStrata("HIGH")
                pin:SetFrameLevel((Minimap:GetFrameLevel() or 0) + 21)
                pin:Hide()
                trail.pins[used] = pin
            end
            local oldData = pin.pinData
            local moved = not oldData or oldData.mapID ~= pinData.mapID
                or oldData.x ~= pinData.x or oldData.y ~= pinData.y
            if pin.minimapPinLibrary and (pin.minimapPinLibrary ~= library or moved) then
                RemovePin(owner, pin)
            end
            pin.pinData = pinData
            pin.previousPin, pin.nextPin = nil, nil
            if previousPin and previousPin.pinData.routeID == pinData.routeID then
                pin.previousPin = previousPin
                previousPin.nextPin = pin
            end
            previousPin = pin
            if library then
                if pin.minimapPinLibrary ~= library then
                    library:AddMinimapIconMap(owner, pin, pinData.mapID, pinData.x, pinData.y, false, false)
                    pin.minimapPinLibrary = library
                end
            else
                local x, y = positionFallback(pinData)
                local visible = x and y and ((x * x) + (y * y)) <= (radius * radius)
                if visible then
                    pin:ClearAllPoints()
                    pin:SetPoint("CENTER", Minimap, "CENTER", x, y)
                end
                pin:SetShown(visible == true)
            end
        end
    end
    for index = used + 1, #trail.pins do
        RemovePin(owner, trail.pins[index])
    end
    trail.usedPins = used
    if used > 0 and not trail.active then
        trail.frame.elapsed = TRAIL_REFRESH_SECONDS
    end
    trail.active = used > 0
    trail.frame:SetShown(trail.active)
    return used
end

GoldTracker.FarmTrail = FarmTrail
