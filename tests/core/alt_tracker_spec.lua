local loader = require("tests.helpers.addon_loader")

local function with_tracker(callback)
    local state = { guid = "Player-1", name = "Zara", realm = "Realm A", level = 79, mapID = 100, x = 0.123456, y = 0.654321, now = 10 }
    local maps = {
        [100] = { name = "City", parentMapID = 101, mapType = 4 },
        [101] = { name = "Zone", parentMapID = 102, mapType = 3 },
        [102] = { name = "Kalimdor", parentMapID = 0, mapType = 2 },
        [200] = { name = "Other zone", parentMapID = 201, mapType = 3 },
        [201] = { name = "Eastern Kingdoms", parentMapID = 0, mapType = 2 },
    }
    loader.with_globals({
        UnitGUID = function() return state.guid end,
        UnitFullName = function() return state.name, state.realm end,
        GetRealmName = function() return "Fallback realm" end,
        UnitClass = function() return "Mage", "MAGE" end,
        UnitLevel = function() return state.level end,
        time = function() return state.now end,
        GetProfessions = function() return 1, 2, 3, 4, 5 end,
        GetProfessionInfo = function(index)
            return index == 1 and "Mining" or "Engineering", 1000 + index, 100, 100, nil, nil, 180 + index
        end,
        C_Map = {
            GetBestMapForUnit = function() return state.mapID end,
            GetMapInfo = function(id) return maps[id] end,
            GetPlayerMapPosition = function(id)
                if not state.x then return end
                return { GetXY = function()
                    if id == state.mapID then return state.x, state.y end
                    return 0.4, 0.6
                end }
            end,
        },
        CreateFrame = function()
            return {
                events = {},
                RegisterEvent = function(self, event) self.events[event] = true end,
                SetScript = function(self, script, handler) self[script] = handler end,
            }
        end,
    }, function()
        local addon = loader.load_module("Core/AltTracker.lua", { db = {} })
        callback(addon, state)
    end)
end

describe("Core/AltTracker", function()
    it("groups recorded levels below the configurable cutoff without losing character data", function()
        with_tracker(function(addon)
            assert.equals(20, addon:GetAltLowLevelThreshold())
            local low = { name = "Amy", level = 19, roles = { main = true }, location = {
                continentMapID = 200, continentName = "Kalimdor", mapID = 100, x = 0.3, y = 0.4 } }
            addon.db.altCharacters = {
                low = low,
                boundary = { name = "Bo", level = 20, location = { continentMapID = 200, continentName = "Kalimdor" } },
                unknown = { name = "Cara", location = { continentMapID = 200, continentName = "Kalimdor" } },
            }
            local groups = addon:BuildAltCharacterGroups()
            assert.equals(200, groups[1].id)
            assert.equals(2, #groups[1].characters)
            assert.equals("lowLevel", groups[2].id)
            assert.equals(low, groups[2].characters[1].character)
            assert.equals("Low level (below 20)", groups[2].name)
            assert.is_true(addon:MoveAltContinentGroup("lowLevel", 200))
            assert.equals("lowLevel", addon:BuildAltCharacterGroups()[1].id)
            assert.equals(10, addon:SetAltLowLevelThreshold("10"))
            assert.equals(1, #addon:BuildAltCharacterGroups())
            assert.equals(3, #addon:BuildAltCharacterGroups()[1].characters)
            assert.equals(30, addon:SetAltLowLevelThreshold("30"))
            assert.equals(2, #addon:BuildAltCharacterGroups()[1].characters)
            assert.equals(30, addon:SetAltLowLevelThreshold("invalid"))
            assert.equals(30, addon:SetAltLowLevelThreshold(0 / 0))
            assert.equals(1000, addon:SetAltLowLevelThreshold(2000))
            assert.equals(0, addon:SetAltLowLevelThreshold(-1))
            assert.is_false(addon:IsLowLevelAlt(low))
            assert.equals(1, #addon:BuildAltCharacterGroups())
            assert.equals(19, low.level)
            assert.is_true(low.roles.main)
            assert.equals(0.3, low.location.x)
        end)
    end)

    it("persists continent order while retaining empty groups and appending newly seen continents", function()
        with_tracker(function(addon)
            addon.db.altCharacters = {
                one = { name = "Amy", location = { continentMapID = 200, continentName = "Kalimdor" } },
                two = { name = "Bo", location = { continentMapID = 300, continentName = "Other continent" } },
                lost = { name = "Lost" },
            }
            local function ids()
                local result = {}
                for _, group in ipairs(addon:BuildAltCharacterGroups()) do result[#result + 1] = group.id end
                return result
            end
            assert.same({ 200, 300, "unknown" }, ids())
            assert.is_false(addon:MoveAltContinentGroup(999, 200))
            assert.is_false(addon:MoveAltContinentGroup(200, 999))
            assert.is_false(addon:MoveAltContinentGroup(200, 300))
            assert.is_nil(addon.db.altContinentOrder)
            assert.is_true(addon:MoveAltContinentGroup(300, 200))
            assert.same({ 300, 200, "unknown" }, ids())
            assert.is_true(addon:MoveAltContinentGroup(300, nil))
            assert.same({ 200, "unknown", 300 }, ids())
            local reloaded = loader.load_module("Core/AltTracker.lua", { db = addon.db })
            assert.equals(200, reloaded:BuildAltCharacterGroups()[1].id)
            assert.equals("unknown", reloaded:BuildAltCharacterGroups()[2].id)
            addon.db.altCharacters.one = nil
            assert.is_true(addon:MoveAltContinentGroup(300, "unknown"))
            assert.same({ 200, 300, "unknown" }, addon.db.altContinentOrder)
            addon.db.altCharacters.one = { name = "Amy", location = { continentMapID = 200, continentName = "Kalimdor" } }
            addon.db.altCharacters.new = { name = "Zara", location = { continentMapID = 400, continentName = "A new continent" } }
            assert.same({ 200, 300, "unknown", 400 }, ids())
            assert.is_true(addon:MoveAltContinentGroup("unknown", 200))
            assert.same({ "unknown", 200, 300, 400 }, ids())
        end)
    end)

    it("keeps editable offline roles by GUID through captures and reloads", function()
        with_tracker(function(addon, state)
            local first = addon:CaptureCurrentAlt(true)
            state.guid, state.realm = "Player-2", "Realm B"
            addon:CaptureCurrentAlt(true)
            local location = first.location
            local options = addon:GetAltCharacterRoleOptions()
            assert.equals(3, #options)
            assert.equals("Main", options[1].label)
            assert.equals("Bank", options[2].label)
            assert.equals("Other", options[3].label)
            loader.with_globals({ UnitGUID = function() error("Role edits must not capture the active player") end }, function()
                assert.is_true(addon:SetAltCharacterRole("Player-1", "main", true))
                assert.is_true(addon:SetAltCharacterRole("Player-1", "bank", true))
                assert.is_true(addon:SetAltCharacterRole("Player-2", "other", true))
                assert.is_false(addon:SetAltCharacterRole("missing", "main", true))
                assert.is_false(addon:SetAltCharacterRole("Player-1", "unsupported", true))
                assert.is_false(addon:SetAltCharacterRole("Player-1", "main", "yes"))
            end)
            assert.same({ "Main", "Bank" }, addon:GetAltCharacterRoles("Player-1"))
            assert.same({ "Other" }, addon:GetAltCharacterRoles("Player-2"))
            assert.equals(location, first.location)
            state.guid, state.realm = "Player-1", "Realm A"
            addon:CaptureCurrentAlt(true)
            local reloaded = loader.load_module("Core/AltTracker.lua", { db = addon.db })
            assert.same({ "Main", "Bank" }, reloaded:GetAltCharacterRoles("Player-1"))
            assert.is_true(reloaded:SetAltCharacterRole("Player-1", "main", false))
            assert.same({ "Bank" }, reloaded:GetAltCharacterRoles("Player-1"))
            assert.is_true(reloaded:SetAltCharacterRole("Player-1", "bank", false))
            assert.is_nil(first.roles)
            assert.is_true(reloaded:ClearAltCharacterRoles("Player-2"))
            assert.is_nil(addon.db.altCharacters["Player-2"].roles)
            assert.is_false(reloaded:ClearAltCharacterRoles("missing"))
        end)
    end)

    it("captures full precision and replaces the login snapshot with final logout coordinates", function()
        with_tracker(function(addon, state)
            addon:InitializeAltTracker()
            local events = addon.altTrackerEvents
            assert.is_nil(events.OnUpdate)
            assert.is_nil(events.events.ZONE_CHANGED)
            events:OnEvent("PLAYER_ENTERING_WORLD")
            local record = addon.db.altCharacters["Player-1"]
            assert.equals(79, record.level)
            local destination = { mapID = 200, mapName = "Other zone", x = 0.7, y = 0.8 }
            record.destination = destination
            assert.equals(0.123456, record.location.x)
            assert.equals(102, record.location.continentMapID)
            assert.equals(101, record.location.parentMapID)
            assert.equals(0.4, record.location.parentX)
            assert.equals(2, #record.professions)
            state.x, state.y, state.now = 0.987654, 0.333333, 20
            events:OnEvent("PLAYER_ENTERING_WORLD")
            assert.equals(0.123456, record.location.x)
            state.level = 80
            local refreshes = 0
            addon.altsFrame = { IsShown = function() return true end }
            addon.RefreshAltsWindow = function() refreshes = refreshes + 1 end
            loader.with_globals({ C_Map = { GetBestMapForUnit = function()
                error("Level changes must not read the player's location")
            end } }, function()
                events:OnEvent("PLAYER_LEVEL_CHANGED", 79, 80, true)
            end)
            assert.equals(80, record.level)
            assert.equals(1, refreshes)
            assert.equals(0.123456, record.location.x)
            state.level = 0
            events:OnEvent("PLAYER_LOGOUT")
            assert.equals(80, record.level)
            assert.equals(0.987654, record.location.x)
            assert.equals(0.333333, record.location.y)
            assert.equals(20, record.location.savedAt)
            assert.equals(destination, record.destination)
            local reloaded = loader.load_module("Core/AltTracker.lua", { db = addon.db })
            assert.equals(80, reloaded:GetAltCharacters()["Player-1"].level)
        end)
    end)

    it("keeps realm identities separate and groups and sorts saved characters", function()
        with_tracker(function(addon, state)
            addon:CaptureCurrentAlt(true)
            state.guid, state.name, state.realm = "Player-2", "Amy", "Realm B"
            addon:CaptureCurrentAlt(true)
            state.guid, state.name, state.mapID = "Player-3", "Zara", 200
            addon:CaptureCurrentAlt(true)
            state.guid, state.name, state.mapID = "Player-4", "Lost", nil
            addon:CaptureCurrentAlt(true)
            local groups = addon:BuildAltCharacterGroups()
            assert.equals("Eastern Kingdoms", groups[1].name)
            assert.equals("Kalimdor", groups[2].name)
            assert.equals("Amy", groups[2].characters[1].character.name)
            assert.equals("Zara", groups[2].characters[2].character.name)
            assert.equals("unknown", groups[3].id)
            assert.equals("Realm A", addon.db.altCharacters["Player-1"].realm)
            assert.equals("Realm B", addon.db.altCharacters["Player-3"].realm)
        end)
    end)

    it("preserves the last complete location when logout has no coordinates", function()
        with_tracker(function(addon, state)
            local record = addon:CaptureCurrentAlt(true)
            local original = record.location
            state.mapID, state.x, state.now = nil, nil, 30
            addon:CaptureCurrentAlt(true)
            assert.equals(original, record.location)
            assert.equals(10, record.location.savedAt)
            assert.is_true(record.locationUnavailable)
            assert.equals(30, record.lastSeenAt)
        end)
    end)

    it("refreshes professions without sampling or changing the position", function()
        with_tracker(function(addon, state)
            addon:InitializeAltTracker()
            addon.altTrackerEvents:OnEvent("PLAYER_ENTERING_WORLD")
            local record = addon.db.altCharacters["Player-1"]
            state.x = 0.9
            loader.with_globals({ GetProfessions = function() return nil, 2, 3 end }, function()
                addon.altTrackerEvents:OnEvent("SKILL_LINES_CHANGED")
            end)
            assert.equals(1, #record.professions)
            assert.equals("Engineering", record.professions[1].name)
            assert.equals(0.123456, record.location.x)
            loader.with_globals({ GetProfessions = function() end }, function()
                addon.altTrackerEvents:OnEvent("SKILL_LINES_CHANGED")
            end)
            assert.equals(0, #record.professions)
        end)
    end)

    it("preserves professions through world teardown, logout and switching characters", function()
        with_tracker(function(addon, state)
            addon:InitializeAltTracker()
            local events = addon.altTrackerEvents
            events:OnEvent("PLAYER_ENTERING_WORLD")
            local original = addon.db.altCharacters["Player-1"].professions
            loader.with_globals({ GetProfessions = function() end }, function()
                events:OnEvent("PLAYER_LEAVING_WORLD")
                events:OnEvent("SKILL_LINES_CHANGED")
                state.x, state.now = 0.75, 20
                events:OnEvent("PLAYER_LOGOUT")
                events:OnEvent("SKILL_LINES_CHANGED")
            end)
            assert.equals(original, addon.db.altCharacters["Player-1"].professions)
            assert.equals(2, #original)
            assert.equals("Mining", original[1].name)
            assert.equals(1001, original[1].icon)
            assert.equals(0.75, addon.db.altCharacters["Player-1"].location.x)
            assert.equals(20, addon.db.altCharacters["Player-1"].location.savedAt)
            state.guid, state.name = "Player-2", "Janis"
            local reloaded = loader.load_module("Core/AltTracker.lua", { db = addon.db })
            reloaded:InitializeAltTracker()
            reloaded.altTrackerEvents:OnEvent("PLAYER_ENTERING_WORLD")
            assert.equals(original, reloaded.db.altCharacters["Player-1"].professions)
            assert.equals(2, #reloaded.db.altCharacters["Player-2"].professions)
        end)
    end)

    it("keeps saved professions when login skills are not ready and refreshes after loading", function()
        with_tracker(function(addon)
            local record = addon:CaptureCurrentAlt(true)
            local original = record.professions
            local reloaded = loader.load_module("Core/AltTracker.lua", { db = addon.db })
            reloaded:InitializeAltTracker()
            loader.with_globals({ GetProfessions = function() end }, function()
                reloaded.altTrackerEvents:OnEvent("SKILL_LINES_CHANGED")
                reloaded.altTrackerEvents:OnEvent("PLAYER_ENTERING_WORLD")
            end)
            assert.equals(original, record.professions)
            loader.with_globals({ GetProfessionInfo = function() return "Mining", nil end }, function()
                reloaded.altTrackerEvents:OnEvent("SKILL_LINES_CHANGED")
            end)
            assert.equals(original, record.professions)
            loader.with_globals({ GetProfessions = function() return nil, 2 end }, function()
                reloaded.altTrackerEvents:OnEvent("SKILL_LINES_CHANGED")
            end)
            assert.equals(1, #record.professions)
            assert.equals("Engineering", record.professions[1].name)
        end)
    end)

    it("projects the precise saved position when the parent map has no direct player position", function()
        with_tracker(function(addon, state)
            local maps = C_Map
            local localPosition = maps.GetPlayerMapPosition
            loader.with_globals({
                CreateVector2D = function(x, y) return { x = x, y = y } end,
            }, function()
                maps.GetPlayerMapPosition = function(id)
                    if id == 100 then return localPosition(id) end
                end
                maps.GetWorldPosFromMapPos = function(id, position)
                    assert.equals(100, id)
                    assert.equals(state.x, position.x)
                    return 1, position
                end
                maps.GetMapPosFromWorldPos = function(instanceID, world, parentID)
                    assert.equals(1, instanceID)
                    assert.equals(101, parentID)
                    return parentID, { GetXY = function() return world.x / 2, world.y / 2 end }
                end
                local record = addon:CaptureCurrentAlt(true)
                assert.equals(state.x / 2, record.location.parentX)
                assert.equals(state.y / 2, record.location.parentY)
            end)
        end)
    end)

    it("retains other alts across reloads and refuses unavailable or restricted coordinates", function()
        with_tracker(function(addon, state)
            addon:CaptureCurrentAlt(true)
            local db = addon.db
            local reloaded = loader.load_module("Core/AltTracker.lua", { db = db })
            state.guid, state.name = "Player-2", "Amy"
            reloaded:CaptureCurrentAlt(true)
            assert.equals("Zara", db.altCharacters["Player-1"].name)
            local record = db.altCharacters["Player-2"]
            state.x, state.y = 0, 0
            reloaded:CaptureCurrentAlt(true)
            assert.equals(0.123456, record.location.x)
            state.x, state.y = 0.8, 0.9
            loader.with_globals({ issecretvalue = function(value) return value == 0.8 end }, function()
                reloaded:CaptureCurrentAlt(true)
            end)
            assert.equals(0.123456, record.location.x)
            assert.is_true(record.locationUnavailable)
        end)
    end)

    it("saves independent exploration snapshots and retains them through logout and character switches", function()
        with_tracker(function(addon, state)
            local overlays = { { textureWidth = 300, textureHeight = 270, offsetX = 10, offsetY = 20,
                fileDataIDs = { 101, 102, 103, 104 } } }
            loader.with_globals({ C_MapExplorationInfo = { GetExploredMapTextures = function(mapID)
                if mapID == 100 then return overlays end
                return {}
            end } }, function()
                addon:InitializeAltTracker()
                local events = addon.altTrackerEvents
                events:OnEvent("PLAYER_ENTERING_WORLD")
                local record = addon.db.altCharacters["Player-1"]
                assert.equals(101, record.exploredMaps[100][1].fileDataIDs[1])
                assert.equals(0, #record.exploredMaps[101])
                overlays[1].fileDataIDs[1] = 201
                assert.equals(101, record.exploredMaps[100][1].fileDataIDs[1])
                events:OnEvent("MAP_EXPLORATION_UPDATED")
                assert.equals(201, record.exploredMaps[100][1].fileDataIDs[1])
                assert.equals(10, record.location.savedAt)
                local liveOverlays = overlays
                overlays = {}
                events:OnEvent("MAP_EXPLORATION_UPDATED")
                assert.equals(201, record.exploredMaps[100][1].fileDataIDs[1])
                overlays = liveOverlays
                local saved = record.exploredMaps[100]
                events:OnEvent("PLAYER_LEAVING_WORLD")
                assert.equals(201, record.exploredMaps[100][1].fileDataIDs[1])
                saved = record.exploredMaps[100]
                overlays = {}
                state.mapID, state.x = nil, nil
                events:OnEvent("PLAYER_LOGOUT")
                assert.equals(saved, record.exploredMaps[100])
                state.guid, state.name, state.mapID, state.x = "Player-2", "Janis", 200, 0.5
                local reloaded = loader.load_module("Core/AltTracker.lua", { db = addon.db })
                reloaded:InitializeAltTracker()
                reloaded.altTrackerEvents:OnEvent("PLAYER_ENTERING_WORLD")
                assert.equals(saved, reloaded.db.altCharacters["Player-1"].exploredMaps[100])
                assert.equals(0, #reloaded.db.altCharacters["Player-2"].exploredMaps[200])
                assert.is_nil(reloaded.db.altCharacters["Player-2"].exploredMaps[100])
            end)
        end)
    end)

    it("captures the requested continent only on demand and retains earlier zones", function()
        with_tracker(function(addon)
            local reads = {}
            C_Map.GetMapChildrenInfo = function(id)
                assert.equals(102, id)
                return { { mapID = 103, mapType = 3 }, { mapID = 104, mapType = 5 } }
            end
            loader.with_globals({ C_MapExplorationInfo = { GetExploredMapTextures = function(id)
                reads[#reads + 1] = id
                return {}
            end } }, function()
                local record = { location = { mapID = 100, parentMapID = 101, continentMapID = 102 }, exploredMaps = { [99] = {} } }
                addon:CaptureAltMapExploration(record)
                assert.equals(2, #reads)
                assert.is_nil(record.exploredMaps[103])
                addon:CaptureAltMapExploration(record, true)
                assert.is_table(record.exploredMaps[103])
                assert.is_table(record.exploredMaps[99])
                assert.is_nil(record.exploredMaps[104])
            end)
        end)
    end)

    it("keeps base art independent per character and clears old-phase discoveries on an art change", function()
        with_tracker(function(addon)
            local artID = 10
            addon.MapDataSource = {
                ReadArt = function() return { artID = artID, textures = { artID * 100 }, width = 1000, height = 650 } end,
                ReadWorld = function() return { id = 0, n0 = 100, n1 = 0, w0 = 100, w1 = 0 } end,
            }
            loader.with_globals({ C_MapExplorationInfo = { GetExploredMapTextures = function() return {} end } }, function()
                local first = { location = { mapID = 100 }, exploredMaps = {} }
                addon:CaptureAltMapExploration(first)
                first.exploredMaps[100] = { { fileDataIDs = { 7001 } } }
                artID = 20
                local second = { location = { mapID = 100 } }
                addon:CaptureAltMapExploration(second)
                assert.equals(10, first.mapArtSnapshots[100].artID)
                assert.equals(20, second.mapArtSnapshots[100].artID)
                addon:CaptureAltMapExploration(first)
                assert.equals(20, first.mapArtSnapshots[100].artID)
                assert.equals(0, #first.exploredMaps[100])
            end)
        end)
    end)

    it("resolves a continent-level player map to the actual zone and its parent", function()
        with_tracker(function(addon, state)
            state.mapID = 102
            C_Map.GetMapInfoAtPosition = function(mapID, x, y, physicalPosition)
                assert.equals(102, mapID)
                assert.equals(state.x, x)
                assert.equals(state.y, y)
                assert.is_true(physicalPosition)
                return { mapID = 101, name = "Zone", mapType = 3 }
            end
            local record = addon:CaptureCurrentAlt(true)
            assert.equals(101, record.location.mapID)
            assert.equals("Zone", record.location.mapName)
            assert.equals(102, record.location.parentMapID)
            assert.equals("Kalimdor", record.location.parentMapName)
            assert.equals(0.4, record.location.x)
            assert.equals(0.6, record.location.y)
            assert.equals(state.x, record.location.parentX)
            assert.equals(state.y, record.location.parentY)
        end)
    end)

    it("uses the actual zone name when the continent's positional lookup is not ready", function()
        with_tracker(function(addon, state)
            state.mapID = 102
            C_Map.GetMapInfoAtPosition = function() return nil end
            C_Map.GetMapChildrenInfo = function(mapID, mapType, descendants)
                assert.equals(102, mapID)
                assert.equals(3, mapType)
                assert.is_true(descendants)
                return { { mapID = 200, name = "Other zone", mapType = 3 },
                    { mapID = 101, name = "Zone", mapType = 3 } }
            end
            loader.with_globals({ GetRealZoneText = function() return "Zone" end }, function()
                assert.equals(101, addon:CaptureCurrentAlt(true).location.mapID)
            end)
        end)
    end)

    it("records a new character at Northrend's edge even when no zone contains its coordinates", function()
        with_tracker(function(addon, state)
            state.mapID, state.x, state.y = 113, 0.3087, 0.6730
            local mapInfo = C_Map.GetMapInfo
            C_Map.GetMapInfo = function(mapID)
                if mapID == 113 then return { name = "Northrend", mapType = 2, parentMapID = 0 } end
                if mapID == 114 then return { name = "Borean Tundra", mapType = 3, parentMapID = 113 } end
                return mapInfo(mapID)
            end
            C_Map.GetMapInfoAtPosition = function() return nil end
            C_Map.GetMapChildrenInfo = function()
                return { { mapID = 114, name = "Borean Tundra", mapType = 3 } }
            end
            local playerPosition = C_Map.GetPlayerMapPosition
            C_Map.GetPlayerMapPosition = function(mapID)
                if mapID == 114 then return { GetXY = function() return 1.02, 0.5 end } end
                return playerPosition(mapID)
            end
            loader.with_globals({ GetRealZoneText = function() return "Borean Tundra" end }, function()
                addon:InitializeAltTracker()
                addon.altTrackerEvents:OnEvent("PLAYER_ENTERING_WORLD")
                local record = addon.db.altCharacters["Player-1"]
                assert.equals(113, record.location.mapID)
                assert.equals("Northrend", record.location.continentName)
                assert.equals(0.3087, record.location.x)
                assert.equals(0.6730, record.location.y)
                assert.is_nil(record.locationUnavailable)
                assert.equals("Northrend", addon:BuildAltCharacterGroups()[1].name)
                assert.equals(0.3087, addon:BuildAltContinentMap(113).pins[1].x)
                state.x = 0.31
                addon.altTrackerEvents:OnEvent("PLAYER_LEAVING_WORLD")
                state.mapID = nil
                addon.altTrackerEvents:OnEvent("PLAYER_LOGOUT")
                assert.equals(113, record.location.mapID)
                assert.equals(0.31, record.location.x)
            end)
        end)
    end)

    it("checkpoints the final zone before teardown and rejects a later continent-only snapshot", function()
        with_tracker(function(addon, state)
            addon:InitializeAltTracker()
            local events = addon.altTrackerEvents
            events:OnEvent("PLAYER_ENTERING_WORLD")
            state.x, state.now = 0.8, 20
            events:OnEvent("PLAYER_LEAVING_WORLD")
            local record = addon.db.altCharacters["Player-1"]
            assert.equals(0.8, record.location.x)
            assert.equals(20, record.location.savedAt)
            state.mapID, state.now = 102, 30
            events:OnEvent("PLAYER_LOGOUT")
            assert.equals(100, record.location.mapID)
            assert.equals(0.8, record.location.x)
            assert.equals(20, record.location.savedAt)
            assert.is_true(record.locationUnavailable)
            assert.is_nil(events.OnUpdate)
        end)
    end)

    it("builds continent pins from saved locations, including cities, without reading another player's coordinates", function()
        with_tracker(function(addon)
            local overlay = { textureWidth = 64, textureHeight = 64, offsetX = 0, offsetY = 0, fileDataIDs = { 123 } }
            addon.db.altCharacters = {
                one = { name = "Amy", realm = "Realm A", roles = { bank = true }, professions = { { name = "Mining", icon = 101 } },
                    location = { mapID = 101, parentMapID = 102,
                    x = 0.2, y = 0.3, parentX = 0.4, parentY = 0.6, continentMapID = 102, continentName = "Kalimdor" },
                    exploredMaps = { [102] = { overlay } } },
                two = { name = "Zara", realm = "Realm B", roles = { other = true }, location = { mapID = 100, parentMapID = 101,
                    x = 0.1, y = 0.2, parentX = 0.3, parentY = 0.4, continentMapID = 102, continentName = "Kalimdor" },
                    exploredMaps = { [102] = { overlay } } },
                three = { name = "Bea", realm = "Realm A", location = { mapID = 102,
                    x = 0.11, y = 0.12, continentMapID = 102, continentName = "Kalimdor" } },
                four = { name = "Lost", realm = "Realm A", location = { mapID = 101,
                    continentMapID = 102, continentName = "Kalimdor" } },
                other = { name = "Other", realm = "Realm A", location = { mapID = 200,
                    x = 0.5, y = 0.6, continentMapID = 201, continentName = "Eastern Kingdoms" } },
            }
            C_Map.GetPlayerMapPosition = function() error("Continent pins must use saved positions") end
            C_Map.GetWorldPosFromMapPos = function(mapID, position)
                assert.equals(100, mapID)
                assert.equals(0.1, position.x)
                assert.equals(0.2, position.y)
                return 1, position
            end
            C_Map.GetMapPosFromWorldPos = function(_, _, mapID)
                assert.equals(102, mapID)
                return mapID, { GetXY = function() return 0.75, 0.25 end }
            end
            loader.with_globals({ CreateVector2D = function(x, y) return { x = x, y = y } end }, function()
                local overview = addon:BuildAltContinentMap(102)
                assert.equals("Kalimdor", overview.name)
                assert.equals(4, overview.characterCount)
                assert.equals(3, #overview.pins)
                assert.equals("Amy - Realm A", overview.pins[1].label)
                assert.equals(101, overview.pins[1].professions[1].icon)
                assert.equals(0.4, overview.pins[1].x)
                assert.equals("Bea - Realm A", overview.pins[2].label)
                assert.equals(0.11, overview.pins[2].x)
                assert.equals("Zara - Realm B", overview.pins[3].label)
                assert.equals(0.75, overview.pins[3].x)
                assert.equals(0.25, overview.pins[3].y)
                assert.equals(1, #overview.exploredTextures)
                assert.is_nil(addon:BuildAltContinentMap("unknown"))
            end)
        end)
    end)
end)
