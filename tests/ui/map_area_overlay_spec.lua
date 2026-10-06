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

    it("keeps the default area padding tight around a single location", function()
        local overlay = load_overlay()
        local polygon = overlay:BuildPolygons({
            { mapID = 100, x = 0.50, y = 0.50, routeID = "camp" },
        }, 100)[1]
        local minX, maxX, minY, maxY = 1, 0, 1, 0

        for _, point in ipairs(polygon.points) do
            minX = math.min(minX, point.x)
            maxX = math.max(maxX, point.x)
            minY = math.min(minY, point.y)
            maxY = math.max(maxY, point.y)
        end

        assert.is_true((maxX - minX) <= 0.029)
        assert.is_true((maxY - minY) <= 0.041)
    end)

    it("splits distant pockets from the same item area into separate polygons", function()
        local overlay = load_overlay()
        local polygons = overlay:BuildPolygons({
            { mapID = 100, x = 0.20, y = 0.30, routeID = "shared-camp" },
            { mapID = 100, x = 0.25, y = 0.34, routeID = "shared-camp" },
            { mapID = 100, x = 0.28, y = 0.37, routeID = "shared-camp" },
            { mapID = 100, x = 0.72, y = 0.68, routeID = "shared-camp" },
            { mapID = 100, x = 0.76, y = 0.72, routeID = "shared-camp" },
        }, 100)

        assert.equals(2, #polygons)
        assert.equals("shared-camp", polygons[1].routeID)
        assert.equals(3, polygons[1].sourcePointCount)
        assert.equals("shared-camp", polygons[2].routeID)
        assert.equals(2, polygons[2].sourcePointCount)
        assert.are_not.equals(polygons[1].key, polygons[2].key)
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
