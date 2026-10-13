local _, NS = ...
local GoldTracker = NS.GoldTracker
local RecoveryWaypoint = {}
local POSITION_TOLERANCE = 0.00001

local function Matches(first, second)
    return first and second and first.mapID == second.mapID
        and math.abs(first.x - second.x) <= POSITION_TOLERANCE
        and math.abs(first.y - second.y) <= POSITION_TOLERANCE
end

local function GetCurrentWaypoint()
    if not C_Map or type(C_Map.GetUserWaypoint) ~= "function" then
        return nil, false
    end
    local ok, point = pcall(C_Map.GetUserWaypoint)
    if not ok then
        return nil, false
    end
    if not point then
        return nil, true
    end
    local position = point.position
    if not position or type(position.GetXY) ~= "function" then
        return nil, false
    end
    local positionOK, x, y = pcall(position.GetXY, position)
    local mapID = tonumber(point.uiMapID)
    x, y = tonumber(x), tonumber(y)
    if not positionOK or not mapID or not x or not y then
        return nil, false
    end
    return { mapID = mapID, x = x, y = y }, true
end

function RecoveryWaypoint:Clear(runtime, navigationPoint)
    if not runtime then
        return false
    end
    local current, readable = GetCurrentWaypoint()
    local owned = Matches(current, runtime.recoveryWaypoint) or Matches(current, navigationPoint)
    runtime.recoveryWaypointSuppressed = nil
    runtime.recoveryWaypointRetryAt = nil
    if not readable then
        return false
    end
    if not owned then
        runtime.recoveryWaypoint = nil
        return false
    end
    if type(C_Map.ClearUserWaypoint) ~= "function" then
        return false
    end
    local cleared = pcall(C_Map.ClearUserWaypoint)
    if cleared then
        runtime.recoveryWaypoint = nil
        if C_SuperTrack and type(C_SuperTrack.SetSuperTrackedUserWaypoint) == "function" then
            pcall(C_SuperTrack.SetSuperTrackedUserWaypoint, false)
        end
    end
    return cleared
end

function RecoveryWaypoint:Update(runtime, target, navigationPoint)
    if not runtime then
        return false
    end
    if not target then
        self:Clear(runtime, navigationPoint)
        return false
    end

    local current, readable = GetCurrentWaypoint()
    if not readable then
        return false
    end
    if runtime.recoveryWaypoint then
        if Matches(current, runtime.recoveryWaypoint) then
            return true
        end
        -- Respect a manual replacement/removal until the player returns.
        runtime.recoveryWaypoint = nil
        runtime.recoveryWaypointSuppressed = true
    end
    if runtime.recoveryWaypointSuppressed then
        return false
    end
    if current and not Matches(current, navigationPoint) then
        runtime.recoveryWaypointSuppressed = true
        return false
    end
    local now = GetTime()
    if runtime.recoveryWaypointRetryAt and now < runtime.recoveryWaypointRetryAt then
        return false
    end
    runtime.recoveryWaypointRetryAt = now + 1
    if type(C_Map.SetUserWaypoint) ~= "function"
        or not UiMapPoint or type(UiMapPoint.CreateFromCoordinates) ~= "function" then
        return false
    end
    if type(C_Map.CanSetUserWaypointOnMap) == "function" then
        local ok, allowed = pcall(C_Map.CanSetUserWaypointOnMap, target.mapID)
        if not ok or not allowed then
            return false
        end
    end
    local pointOK, point = pcall(UiMapPoint.CreateFromCoordinates, target.mapID, target.x, target.y)
    if not pointOK or not point then
        return false
    end
    local setOK, wasSet = pcall(C_Map.SetUserWaypoint, point)
    if not setOK or wasSet == false then
        return false
    end
    -- Verify ownership before allowing arrival cleanup to remove this pin.
    local placed = GetCurrentWaypoint()
    if not Matches(placed, target) then
        return false
    end
    runtime.recoveryWaypoint = { mapID = target.mapID, x = target.x, y = target.y }
    runtime.recoveryWaypointRetryAt = nil
    if C_SuperTrack and type(C_SuperTrack.SetSuperTrackedUserWaypoint) == "function" then
        pcall(C_SuperTrack.SetSuperTrackedUserWaypoint, true)
    end
    return true
end

GoldTracker.FarmRecoveryWaypoint = RecoveryWaypoint
