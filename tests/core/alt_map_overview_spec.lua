local loader = require("tests.helpers.addon_loader")

local function with_overview(callback)
    local info = {
        [947] = { parentMapID = 946, mapType = 1 }, [12] = { parentMapID = 947, mapType = 2 },
        [13] = { parentMapID = 947, mapType = 2 }, [37] = { parentMapID = 13, mapType = 3 },
        [101] = { parentMapID = 946, mapType = 2 }, [111] = { parentMapID = 101, mapType = 3 },
        [572] = { parentMapID = 946, mapType = 2 }, [550] = { parentMapID = 572, mapType = 3 },
        [1550] = { parentMapID = 946, mapType = 2 }, [1533] = { parentMapID = 1550, mapType = 3 },
        [999] = { parentMapID = 999, mapType = 3 },
    }
    loader.with_globals({ C_Map = {
        GetMapInfo = function(id) return info[id] end,
        GetMapRectOnMap = function(id, root)
            if root == 947 and id == 37 then return 0.2, 0.6, 0.3, 0.7 end
            if root == 947 and id == 13 then return 0.1, 0.7, 0.2, 0.9 end
            if (root == 101 and id == 111) or (root == 572 and id == 550) or (root == 1550 and id == 1533) then
                return 0.1, 0.5, 0.2, 0.8
            end
        end,
        GetPlayerMapPosition = function() error("Global maps must project saved positions") end,
    } }, function()
        local addon = { db = { altCharacters = {} } }
        loader.load_module("Core/AltTracker.lua", addon)
        loader.load_module("Core/AltMapOverview.lua", addon)
        loader.load_module("UI/Maps/Geometry.lua", addon)
        loader.load_module("UI/Maps/MapSource.lua", addon)
        callback(addon)
    end)
end

describe("Global alt map overview", function()
    it("provides all four world maps even when no characters are recorded", function()
        with_overview(function(addon)
            local worlds = addon:GetAltGlobalMapWorlds()
            assert.equals(4, #worlds)
            for i, name in ipairs({ "Azeroth", "Outland", "Draenor", "Shadowlands" }) do
                assert.equals(name, worlds[i].name)
                local overview = addon:BuildAltGlobalMap(worlds[i].id)
                assert.equals(0, overview.characterCount)
                assert.equals(0, #overview.pins)
            end
            assert.is_nil(addon:BuildAltGlobalMap(946))
        end)
    end)

    it("projects offline characters into their own worlds, including low levels and role groups", function()
        with_overview(function(addon)
            for guid, entry in pairs({
                low = { 37, "Low", "Realm A", 1, { main = true } },
                bank = { 37, "Bank", "Realm B", 80, { bank = true } },
                outland = { 111, "Outland", "Realm A", 80 },
                draenor = { 550, "Draenor", "Realm A", 80 },
                shadowlands = { 1533, "Shadowlands", "Realm A", 80 },
            }) do
                addon.db.altCharacters[guid] = { name = entry[2], realm = entry[3], level = entry[4], roles = entry[5],
                    location = { mapID = entry[1], x = 0.25, y = 0.75 } }
            end
            addon.currentAltGUID = "some-other-character"
            local azeroth = addon:BuildAltGlobalMap(947)
            assert.equals(2, #azeroth.pins)
            assert.equals("Bank", azeroth.pins[1].name)
            assert.near(0.3, azeroth.pins[1].x, 0.000001)
            assert.near(0.6, azeroth.pins[1].y, 0.000001)
            for _, id in ipairs({ 101, 572, 1550 }) do
                local overview = addon:BuildAltGlobalMap(id)
                assert.equals(1, #overview.pins)
                assert.near(0.2, overview.pins[1].x, 0.000001)
                assert.near(0.65, overview.pins[1].y, 0.000001)
            end
        end)
    end)

    it("uses saved parent coordinates as a fallback and counts unavailable positions without inventing pins", function()
        with_overview(function(addon)
            addon.db.altCharacters = {
                fallback = { name = "Fallback", location = { mapID = 5000, continentMapID = 13,
                    parentMapID = 13, parentX = 0.5, parentY = 0.5 } },
                missing = { name = "Missing", location = { mapID = 37 } },
                outside = { name = "Outside", location = { mapID = 999 } },
                invalid = { name = "Invalid", location = { mapID = 37, x = 0 / 0, y = 0.4 } },
                edge = { name = "Edge", location = { mapID = 947, x = 0, y = 1 } },
            }
            local overview = addon:BuildAltGlobalMap(947)
            assert.equals(4, overview.characterCount)
            assert.equals(2, #overview.pins)
            assert.equals(2, overview.missingPositionCount)
            assert.equals("Edge", overview.pins[1].name)
            assert.equals(0, overview.pins[1].x)
            assert.equals(1, overview.pins[1].y)
            assert.near(0.4, overview.pins[2].x, 0.000001)
            assert.near(0.55, overview.pins[2].y, 0.000001)
        end)
    end)
end)
