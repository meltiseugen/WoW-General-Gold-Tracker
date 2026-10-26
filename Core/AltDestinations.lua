local _, NS = ...
local GoldTracker = NS.GoldTracker
local ARRIVAL_RADIUS = 100

local function PublicNumber(value)
    return not (type(issecretvalue) == "function" and issecretvalue(value))
        and type(value) == "number" and value == value and math.abs(value) < math.huge
end

local function ValidPoint(point)
    return type(point) == "table" and PublicNumber(point.mapID) and point.mapID > 0
        and point.mapID == math.floor(point.mapID)
        and PublicNumber(point.x) and PublicNumber(point.y)
        and point.x >= 0 and point.x <= 1 and point.y >= 0 and point.y <= 1
end

local function WorldPosition(point)
    if not ValidPoint(point) or not C_Map or not C_Map.GetWorldPosFromMapPos
        or type(CreateVector2D) ~= "function" then return end
    local ok, continent, x, y = pcall(function()
        local id, position = C_Map.GetWorldPosFromMapPos(point.mapID, CreateVector2D(point.x, point.y))
        if not position then return end
        local wx, wy = position:GetXY()
        return id, wx, wy
    end)
    if ok and PublicNumber(continent) and PublicNumber(x) and PublicNumber(y) then
        return continent, x, y
    end
end

local function Refresh(addon)
    if addon.altsFrame and addon.altsFrame:IsShown() then addon:RefreshAltsWindow() end
end

function GoldTracker:GetAltDestinationStatus(guid)
    local character = self:GetAltCharacters()[guid]
    local destination = character and character.destination
    if not destination then return "free" end
    local location = character.location
    if not ValidPoint(destination) or not ValidPoint(location) then return "unknown" end
    -- An unavailable live position must not report arrival from an old snapshot.
    if guid == self.currentAltGUID and character.locationUnavailable then return "unknown" end
    if location.mapID == destination.mapID and location.x == destination.x and location.y == destination.y then
        return "arrived", 0
    end
    local continent, x, y = WorldPosition(location)
    local targetContinent, tx, ty = WorldPosition(destination)
    if not continent or not targetContinent then return "unknown" end
    if continent ~= targetContinent then return "away" end
    local distance = math.sqrt((x - tx) ^ 2 + (y - ty) ^ 2)
    return distance <= ARRIVAL_RADIUS and "arrived" or "away", distance
end

function GoldTracker:GetAltDestinationStatusText(guid)
    local status = self:GetAltDestinationStatus(guid)
    local offline = guid ~= self.currentAltGUID
    if status == "free" then return "Free roam", 0.6, 0.64, 0.7 end
    if status == "arrived" then
        return offline and "Last recorded: at destination" or "At destination", 0.4, 0.85, 0.5
    end
    if status == "away" then
        return offline and "Last recorded: away" or "Away from destination", 1, 0.72, 0.25
    end
    return "Location unknown", 0.6, 0.64, 0.7
end

function GoldTracker:ClearAltDestinationWaypoint(guid)
    local owned = self.altDestinationWaypoint
    if not owned or owned.guid ~= guid then return end
    self.altDestinationWaypoint = nil
    -- Clear only the pin placed by Navigate; preserve manual or farm-route replacements.
    if not C_Map or not C_Map.GetUserWaypoint or not C_Map.ClearUserWaypoint then return end
    pcall(function()
        local point = C_Map.GetUserWaypoint()
        if not point or not point.position then return end
        local x, y = point.position:GetXY()
        if PublicNumber(x) and PublicNumber(y) and point.uiMapID == owned.mapID
            and math.abs(x - owned.x) < 0.00001 and math.abs(y - owned.y) < 0.00001 then
            C_Map.ClearUserWaypoint()
        end
    end)
end

function GoldTracker:SetAltDestination(guid, mapID, x, y)
    local character = self:GetAltCharacters()[guid]
    local point = { mapID = mapID, x = x, y = y }
    if not character or not ValidPoint(point) then return false, "Choose a valid map position." end
    local info = C_Map and C_Map.GetMapInfo and C_Map.GetMapInfo(mapID)
    if not info or not info.mapType or info.mapType < 3 then
        return false, "Choose a zone or city map."
    end
    self:ClearAltDestinationWaypoint(guid)
    character.destination = { mapID = mapID, mapName = info.name, x = x, y = y }
    Refresh(self)
    return true
end

function GoldTracker:ClearAltDestination(guid)
    local character = self:GetAltCharacters()[guid]
    if not character then return false end
    self:ClearAltDestinationWaypoint(guid)
    character.destination = nil
    Refresh(self)
    return true
end

function GoldTracker:NavigateToAltDestination(guid)
    local playerGUID = type(UnitGUID) == "function" and UnitGUID("player") or self.currentAltGUID
    if guid ~= playerGUID or self.altTrackerLeavingWorld then
        return false, "Log in to this character to navigate to its destination."
    end
    local character = self:GetAltCharacters()[guid]
    local destination = character and character.destination
    if not ValidPoint(destination) then return false, "Set a destination first." end
    if not C_Map or not C_Map.SetUserWaypoint or not UiMapPoint or not UiMapPoint.CreateFromCoordinates then
        return false, "Waypoint navigation is unavailable."
    end
    local ok, placed = pcall(function()
        if C_Map.CanSetUserWaypointOnMap and not C_Map.CanSetUserWaypointOnMap(destination.mapID) then return false end
        local point = UiMapPoint.CreateFromCoordinates(destination.mapID, destination.x, destination.y)
        if not point or C_Map.SetUserWaypoint(point) == false then return false end
        if C_SuperTrack and C_SuperTrack.SetSuperTrackedUserWaypoint then
            pcall(C_SuperTrack.SetSuperTrackedUserWaypoint, true)
        end
        return true
    end)
    if not ok or not placed then return false, "This map does not support waypoint navigation." end
    self.altDestinationWaypoint = { guid = guid, mapID = destination.mapID, x = destination.x, y = destination.y }
    return true, "Waypoint set for " .. (destination.mapName or "destination") .. "."
end
