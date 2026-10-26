local loader = require("tests.helpers.addon_loader")

local function with_destinations(callback)
    local state = { waypoint = nil, sets = 0, clears = 0, allowed = true }
    local function vector(x, y) return { GetXY = function() return x, y end } end
    loader.with_globals({
        UnitGUID = function() return "one" end,
        CreateVector2D = vector,
        UiMapPoint = { CreateFromCoordinates = function(mapID, x, y)
            return { uiMapID = mapID, position = vector(x, y) }
        end },
        C_SuperTrack = { SetSuperTrackedUserWaypoint = function(value) state.tracked = value end },
        C_Map = {
            GetMapInfo = function(id)
                return { mapID = id, name = "Map " .. id, mapType = id == 200 and 2 or 3 }
            end,
            GetWorldPosFromMapPos = function(mapID, position)
                if state.worldError then error("unavailable") end
                if state.worldMissing then return end
                local x, y = position:GetXY()
                return mapID == 102 and 2 or 1, vector(x * 10000 + (mapID == 101 and 100 or 0), y * 10000)
            end,
            CanSetUserWaypointOnMap = function() return state.allowed end,
            SetUserWaypoint = function(point)
                if state.setError then error("rejected") end
                if state.setFalse then return false end
                state.waypoint, state.sets = point, state.sets + 1
                return true
            end,
            GetUserWaypoint = function() return state.waypoint end,
            ClearUserWaypoint = function() state.waypoint, state.clears = nil, state.clears + 1 end,
        },
    }, function()
        local addon = { db = { altCharacters = {
            one = { name = "Amy", realm = "A", location = { mapID = 100, x = 0.5, y = 0.5 } },
            two = { name = "Amy", realm = "B", location = { mapID = 100, x = 0.1, y = 0.1 } },
        } }, currentAltGUID = "one" }
        loader.load_module("Core/AltTracker.lua", addon)
        loader.load_module("Core/AltDestinations.lua", addon)
        callback(addon, state)
    end)
end

describe("Core/AltDestinations", function()
    it("defaults to free roam and stores an optional destination by GUID across module reloads", function()
        with_destinations(function(addon)
            assert.equals("free", addon:GetAltDestinationStatus("one"))
            assert.is_true(addon:SetAltDestination("one", 100, 0.505, 0.5))
            assert.equals("free", addon:GetAltDestinationStatus("two"))
            local reloaded = { db = addon.db }
            loader.load_module("Core/AltTracker.lua", reloaded)
            loader.load_module("Core/AltDestinations.lua", reloaded)
            assert.equals(0.505, reloaded.db.altCharacters.one.destination.x)
            assert.equals("arrived", reloaded:GetAltDestinationStatus("one"))
            assert.is_true(addon:ClearAltDestination("one"))
            assert.equals("free", addon:GetAltDestinationStatus("one"))
        end)
    end)

    it("uses world distances for arrival, including nearby points on different maps", function()
        with_destinations(function(addon)
            addon:SetAltDestination("one", 100, 0.505, 0.5)
            local status, distance = addon:GetAltDestinationStatus("one")
            assert.equals("arrived", status)
            assert.equals(50, distance)
            addon:SetAltDestination("one", 100, 0.52, 0.5)
            assert.equals("away", addon:GetAltDestinationStatus("one"))
            addon:SetAltDestination("one", 101, 0.49, 0.5)
            assert.equals("arrived", addon:GetAltDestinationStatus("one"))
            addon:SetAltDestination("one", 102, 0.5, 0.5)
            assert.equals("away", addon:GetAltDestinationStatus("one"))
        end)
    end)

    it("labels offline snapshots and does not claim arrival when position data is unavailable", function()
        with_destinations(function(addon, state)
            addon:SetAltDestination("two", 100, 0.1, 0.1)
            assert.equals("Last recorded: at destination", addon:GetAltDestinationStatusText("two"))
            addon:SetAltDestination("two", 100, 0.8, 0.8)
            assert.equals("Last recorded: away", addon:GetAltDestinationStatusText("two"))
            addon:SetAltDestination("one", 100, 0.5, 0.5)
            addon.db.altCharacters.one.locationUnavailable = true
            assert.equals("unknown", addon:GetAltDestinationStatus("one"))
            addon.db.altCharacters.two.location = nil
            assert.equals("Location unknown", addon:GetAltDestinationStatusText("two"))
            addon.db.altCharacters.one.locationUnavailable = nil
            addon:SetAltDestination("one", 100, 0.6, 0.6)
            state.worldError = true
            assert.equals("unknown", addon:GetAltDestinationStatus("one"))
            state.worldError, state.worldMissing = nil, true
            assert.equals("unknown", addon:GetAltDestinationStatus("one"))
        end)
    end)

    it("rejects invalid positions and continent destinations without changing the saved destination", function()
        with_destinations(function(addon)
            addon:SetAltDestination("one", 100, 0.5, 0.5)
            local original = addon.db.altCharacters.one.destination
            for _, invalid in ipairs({ -0.1, 1.1, math.huge, 0 / 0 }) do
                assert.is_false(addon:SetAltDestination("one", 100, invalid, 0.5))
            end
            assert.is_false(addon:SetAltDestination("one", 200, 0.5, 0.5))
            assert.is_false(addon:SetAltDestination("missing", 100, 0.5, 0.5))
            assert.is_false(addon:SetAltDestination("one", 100.5, 0.5, 0.5))
            assert.equals(original, addon.db.altCharacters.one.destination)
        end)
    end)

    it("places waypoints only through explicit navigation on the logged-in character", function()
        with_destinations(function(addon, state)
            addon:SetAltDestination("one", 100, 0.5, 0.5)
            addon:SetAltDestination("two", 101, 0.6, 0.7)
            assert.equals(0, state.sets)
            assert.is_false(addon:NavigateToAltDestination("two"))
            assert.is_true(addon:NavigateToAltDestination("one"))
            assert.equals(1, state.sets)
            assert.equals(100, state.waypoint.uiMapID)
            assert.is_true(state.tracked)
            addon.altTrackerLeavingWorld = true
            assert.is_false(addon:NavigateToAltDestination("one"))
            assert.equals(1, state.sets)
        end)
    end)

    it("handles unsupported maps and waypoint API failures without recording ownership", function()
        with_destinations(function(addon, state)
            addon:SetAltDestination("one", 100, 0.5, 0.5)
            state.allowed = false
            assert.is_false(addon:NavigateToAltDestination("one"))
            state.allowed, state.setFalse = true, true
            assert.is_false(addon:NavigateToAltDestination("one"))
            state.setFalse, state.setError = nil, true
            assert.is_false(addon:NavigateToAltDestination("one"))
            assert.is_nil(addon.altDestinationWaypoint)
        end)
    end)

    it("clears its own waypoint but preserves a manual replacement", function()
        with_destinations(function(addon, state)
            addon:SetAltDestination("one", 100, 0.5, 0.5)
            addon:NavigateToAltDestination("one")
            addon:ClearAltDestination("one")
            assert.equals(1, state.clears)
            assert.is_nil(state.waypoint)
            addon:SetAltDestination("one", 100, 0.5, 0.5)
            addon:NavigateToAltDestination("one")
            local manual = UiMapPoint.CreateFromCoordinates(101, 0.2, 0.3)
            state.waypoint = manual
            addon:ClearAltDestination("one")
            assert.equals(1, state.clears)
            assert.equals(manual, state.waypoint)
        end)
    end)

    it("refreshes visible Alts after edits and leaves farm assignments unchanged", function()
        with_destinations(function(addon)
            local refreshes = 0
            addon.altsFrame = { IsShown = function() return true end }
            addon.RefreshAltsWindow = function() refreshes = refreshes + 1 end
            addon.db.customFarms = { farms = { { assignedCharacter = "Amy-A" } } }
            addon:SetAltDestination("one", 100, 0.5, 0.5)
            addon:ClearAltDestination("one")
            assert.equals(2, refreshes)
            assert.equals("Amy-A", addon.db.customFarms.farms[1].assignedCharacter)
        end)
    end)
end)
