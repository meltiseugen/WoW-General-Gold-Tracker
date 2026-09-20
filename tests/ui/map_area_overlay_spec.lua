local loader = require("tests.helpers.addon_loader")

local function load_overlay(addon)
    addon = addon or {}
    loader.load_module("UI/MapAreaOverlay.lua", addon, {})
    return addon.MapAreaOverlay
end

describe("UI/MapAreaOverlay", function()
    it("wraps grouped non-route coordinates in padded n-gons", function()
        local overlay = load_overlay()
        local polygons = overlay:BuildPolygons({
            { mapID = 100, x = 0.20, y = 0.30, routeID = "camp-a" },
            { mapID = 100, x = 0.28, y = 0.34, routeID = "camp-a" },
            { mapID = 100, x = 0.70, y = 0.72, routeID = "camp-b" },
            { mapID = 100, x = 0.50, y = 0.50, routeID = "route", isRoute = true },
            { mapID = 101, x = 0.40, y = 0.40, routeID = "other-map" },
        }, 100)

        assert.equals(2, #polygons)
        assert.equals("camp-a", polygons[1].routeID)
        assert.equals(2, polygons[1].sourcePointCount)
        assert.is_true(#polygons[1].points >= 12)
        assert.equals("camp-b", polygons[2].routeID)
        assert.equals(1, polygons[2].sourcePointCount)
        assert.is_true(#polygons[2].points >= 6)
    end)

    it("keeps padded polygons inside normalized map bounds", function()
        local overlay = load_overlay()
        local polygons = overlay:BuildPolygons({
            { mapID = 100, x = 0, y = 1, routeID = "edge" },
        }, 100)

        assert.equals(1, #polygons)
        for _, point in ipairs(polygons[1].points) do
            assert.is_true(point.x >= 0 and point.x <= 1)
            assert.is_true(point.y >= 0 and point.y <= 1)
        end
    end)

    it("merges overlapping user-discovered areas but keeps distant clusters separate", function()
        local overlay = load_overlay()
        local polygons = overlay:BuildPolygons({
            { mapID = 100, x = 0.70, y = 0.20, sourceType = "user", spotLocation = "Unit: Spark" },
            { mapID = 100, x = 0.715, y = 0.21, sourceType = "user", spotLocation = "AOE Unit: Spark" },
            { mapID = 100, x = 0.73, y = 0.22, sourceType = "user", spotLocation = "Unit: Spark" },
            { mapID = 100, x = 0.30, y = 0.70, sourceType = "user", spotLocation = "Unit: Spark" },
        }, 100)

        assert.equals(2, #polygons)
        assert.is_true(polygons[1].isUserCluster)
        assert.equals(3, polygons[1].sourcePointCount)
        assert.is_true(polygons[2].isUserCluster)
        assert.equals(1, polygons[2].sourcePointCount)
    end)
end)
