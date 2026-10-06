local loader = require("tests.helpers.addon_loader")

local function with_planner(catalog, gathering, callback, options)
    options = options or {}
    local addon = {
        db = {},
        messages = {},
        Print = function(self, message)
            self.messages[#self.messages + 1] = message
        end,
    }
    local waypoint
    local openedMapID
    local mapInfo = options.mapInfo or {
        [1] = { name = "Durotar", mapType = 3, parentMapID = 12 },
        [12] = { name = "Kalimdor", mapType = 2, parentMapID = 0 },
        [37] = { name = "Elwynn Forest", mapType = 3, parentMapID = 13 },
        [291] = { name = "The Deadmines", mapType = 4, parentMapID = 37 },
        [13] = { name = "Eastern Kingdoms", mapType = 2, parentMapID = 0 },
    }
    loader.with_globals({
        time = function() return 123456 end,
        UnitFullName = function() return options.characterName or "Goldie", "Silvermoon" end,
        GetRealmName = function() return "Silvermoon" end,
        Enum = { UIMapType = { Continent = 2 } },
        C_Map = {
            GetBestMapForUnit = function() return options.playerMapID or 1 end,
            GetPlayerMapPosition = function()
                return {
                    GetXY = function() return options.playerX or 0.9, options.playerY or 0.9 end,
                }
            end,
            GetMapInfo = function(mapID) return mapInfo[mapID] end,
            SetUserWaypoint = function(point) waypoint = point end,
            OpenWorldMap = function(mapID) openedMapID = mapID end,
        },
        C_AddOns = { LoadAddOn = function() return true end },
        C_EncounterJournal = options.encounterJournal,
        C_AreaPoiInfo = options.areaPoiInfo,
        EJ_GetInstanceInfo = options.getInstanceInfo,
        UiMapPoint = {
            CreateFromCoordinates = function(mapID, x, y)
                return { mapID = mapID, x = x, y = y }
            end,
        },
        C_SuperTrack = { SetSuperTrackedUserWaypoint = function() end },
    }, function()
        local ns = {
            GoldTracker = addon,
            FarmCatalog = catalog,
            WITGatheringData = gathering,
            InstanceDropsData = options.instanceDropsData,
            ATTBoEDropsData = options.attBoEDropsData,
        }
        assert(loadfile("Core/CustomFarms.lua"))("General-Gold-Tracker", ns)
        assert(loadfile("Core/InstanceEntrances.lua"))("General-Gold-Tracker", ns)
        assert(loadfile("Core/FarmRoutePlanner.lua"))("General-Gold-Tracker", ns)
        callback(addon, function() return waypoint end, function() return openedMapID end)
    end)
end

local function build_catalog()
    local farms = {
        {
            id = "wit:drops:transmogs:deadmines",
            name = "The Deadmines",
            sourceType = "drops",
            sourcePath = "Instances",
            mapIDs = { 291 },
            mapNames = { "The Deadmines" },
            targets = { { itemID = 100, quantity = 1 } },
        },
        {
            id = "wit:gathering:mining:copperore",
            name = "Copper Ore",
            sourceType = "gathering",
            sourcePath = "Gathering > Mining",
            sourceRecordIDs = { "Mining:CopperOre:1" },
            mapIDs = { 1 },
            mapNames = { "Durotar" },
            targets = { { itemID = 2770, quantity = 540 } },
        },
    }
    return {
        farms = farms,
        byID = { [farms[1].id] = 1, [farms[2].id] = 2 },
    }, {
        farmsByRecordID = {
            ["Mining:CopperOre:1"] = {
                routes = {
                    {
                        name = "Copper Ore",
                        mapID = 1,
                        mapName = "Durotar",
                        coords = { { x = 0.1, y = 0.1 }, { x = 0.8, y = 0.8 } },
                    },
                },
            },
        },
    }
end

local function add_catalog_target(addon, farm, itemID, itemName, catalogFarmID, sourceType)
    local entry = addon:BuildCustomFarmEntry({ itemID = itemID, itemName = itemName }, sourceType)
    entry = addon:LinkCustomFarmEntryToCatalogFarm(entry, catalogFarmID)
    assert.is_true(addon:AddEntryToCustomFarm(farm.id, entry))
end

describe("Core/FarmRoutePlanner", function()
    it("puts the current continent first and uses the closest point on a gathering loop", function()
        local catalog, gathering = build_catalog()
        with_planner(catalog, gathering, function(addon)
            local farm = addon:CreateCustomFarm("Mixed", true)
            add_catalog_target(addon, farm, 100, "Sword", catalog.farms[1].id, "instances")
            add_catalog_target(addon, farm, 2770, "Copper Ore", catalog.farms[2].id, "materials")

            local plan = addon:BuildCustomFarmRoutePlan(farm.id, true)

            assert.equals(catalog.farms[2].id, plan[1].catalogFarmID)
            assert.equals("exact", plan[1].confidence)
            assert.equals(0.8, plan[1].x)
            assert.equals(0.8, plan[1].y)
            assert.equals(catalog.farms[1].id, plan[2].catalogFarmID)
            assert.equals("approximate", plan[2].confidence)
        end)
    end)

    it("keeps manual ordering and locked positions during recalculation", function()
        local catalog, gathering = build_catalog()
        with_planner(catalog, gathering, function(addon)
            local farm = addon:CreateCustomFarm("Mixed", true)
            add_catalog_target(addon, farm, 100, "Sword", catalog.farms[1].id, "instances")
            add_catalog_target(addon, farm, 2770, "Copper Ore", catalog.farms[2].id, "materials")
            local plan = addon:BuildCustomFarmRoutePlan(farm.id, true)
            local instanceKey = plan[2].key

            assert.is_true(addon:MoveCustomFarmRoutePlanStep(farm.id, instanceKey, -1))
            assert.is_true(addon:SetCustomFarmRoutePlanStepLocked(farm.id, instanceKey, true))
            plan = addon:BuildCustomFarmRoutePlan(farm.id, true)

            assert.equals(instanceKey, plan[1].key)
            assert.is_true(plan[1].locked)
        end)
    end)

    it("uses the Instances tab entrance as the exact destination for a WIT instance farm", function()
        local catalog, gathering = build_catalog()
        with_planner(catalog, gathering, function(addon)
            local farm = addon:CreateCustomFarm("Deadmines", true)
            add_catalog_target(addon, farm, 100, "Sword", catalog.farms[1].id, "instances")

            local plan = addon:BuildCustomFarmRoutePlan(farm.id, true)

            assert.equals(37, plan[1].mapID)
            assert.equals(0.42, plan[1].x)
            assert.equals(0.71, plan[1].y)
            assert.equals("exact", plan[1].confidence)
            assert.equals("Exact instance entrance", plan[1].confidenceLabel)
            assert.equals(1, #plan[1].candidates)
        end, {
            instanceDropsData = {
                instances = {
                    { name = "Deadmines", encounterJournalID = 63, mapID = 291 },
                },
            },
            getInstanceInfo = function(instanceID)
                return instanceID == 63 and "Deadmines" or nil
            end,
            encounterJournal = {
                GetDungeonEntrancesForMap = function(mapID)
                    if mapID == 37 then
                        return {
                            { journalInstanceID = 63, name = "Deadmines entrance", x = 0.42, y = 0.71 },
                        }
                    end
                    return {}
                end,
            },
        })
    end)

    it("tracks completion independently for the current character", function()
        local catalog, gathering = build_catalog()
        with_planner(catalog, gathering, function(addon)
            local farm = addon:CreateCustomFarm("Mixed", true)
            add_catalog_target(addon, farm, 100, "Sword", catalog.farms[1].id, "instances")
            add_catalog_target(addon, farm, 2770, "Copper Ore", catalog.farms[2].id, "materials")
            local plan = addon:BuildCustomFarmRoutePlan(farm.id, true)

            assert.is_true(addon:StartCustomFarmRoutePlan(farm.id))
            local run, character = addon:GetCustomFarmRoutePlanRun(farm.id)
            assert.equals("Goldie-Silvermoon", character)
            assert.equals(plan[1].key, run.currentStepKey)
            assert.is_true(addon:SetCustomFarmRoutePlanStepComplete(farm.id, plan[1].key, true))
            run = addon:GetCustomFarmRoutePlanRun(farm.id)
            assert.is_true(run.completed[plan[1].key])
            assert.equals(plan[2].key, run.currentStepKey)
        end)
    end)

    it("sets a Blizzard waypoint for an exact route destination", function()
        local catalog, gathering = build_catalog()
        with_planner(catalog, gathering, function(addon, getWaypoint)
            local farm = addon:CreateCustomFarm("Mining", true)
            add_catalog_target(addon, farm, 2770, "Copper Ore", catalog.farms[2].id, "materials")
            local plan = addon:BuildCustomFarmRoutePlan(farm.id, true)

            assert.is_true(addon:NavigateCustomFarmRoutePlanStep(farm.id, plan[1].key))
            local waypoint = getWaypoint()
            assert.equals(1, waypoint.mapID)
            assert.equals(0.8, waypoint.x)
            assert.equals(0.8, waypoint.y)
        end)
    end)

    it("cycles between alternate map-only locations for a step", function()
        local catalog = {
            farms = {
                {
                    id = "wit:gathering:mining:alternate",
                    name = "Alternate Mining",
                    sourceType = "gathering",
                    mapIDs = { 1, 37 },
                    mapNames = { "Durotar", "Elwynn Forest" },
                    targets = { { itemID = 300, quantity = 10 } },
                },
            },
            byID = { ["wit:gathering:mining:alternate"] = 1 },
        }
        with_planner(catalog, { farmsByRecordID = {} }, function(addon)
            local farm = addon:CreateCustomFarm("Alternate", true)
            add_catalog_target(addon, farm, 300, "Ore", catalog.farms[1].id, "materials")
            local plan = addon:BuildCustomFarmRoutePlan(farm.id, true)
            assert.equals(1, plan[1].mapID)

            assert.is_true(addon:CycleCustomFarmRoutePlanLocation(farm.id, plan[1].key))
            plan = addon:BuildCustomFarmRoutePlan(farm.id, false)
            assert.equals(37, plan[1].mapID)
        end)
    end)

    it("routes to the selected map source instead of the original item row location", function()
        local catalog, gathering = build_catalog()
        with_planner(catalog, gathering, function(addon, getWaypoint)
            local farm = addon:CreateCustomFarm("Map choice", true)
            local entry = addon:BuildCustomFarmEntry({ itemID = 22574, mapID = 1, x = 0.1, y = 0.2 }, "materials")
            local option = { id = "selected", sourceType = "static", mapID = 37,
                pins = { { mapID = 37, x = 0.6, y = 0.7 } } }
            assert.is_true(addon:CommitCustomFarmEntry({ farmID = farm.id, entry = entry }, nil, option))
            local plan = addon:BuildCustomFarmRoutePlan(farm.id, true)
            assert.equals(37, plan[1].mapID)
            assert.is_true(addon:NavigateCustomFarmRoutePlanStep(farm.id, plan[1].key))
            assert.equals(37, getWaypoint().mapID)
            assert.equals(0.6, getWaypoint().x)
        end)
    end)

    it("places unresolved item-only steps after mapped destinations", function()
        local catalog, gathering = build_catalog()
        with_planner(catalog, gathering, function(addon)
            local farm = addon:CreateCustomFarm("Mixed", true)
            assert.is_true(addon:AddEntryToCustomFarm(
                farm.id,
                addon:BuildCustomFarmEntry({ itemID = 200, itemName = "Unknown Cloth" }, "materials")
            ))
            add_catalog_target(addon, farm, 2770, "Copper Ore", catalog.farms[2].id, "materials")

            local plan = addon:BuildCustomFarmRoutePlan(farm.id, true)

            assert.equals("exact", plan[1].confidence)
            assert.equals("unknown", plan[2].confidence)
        end)
    end)
end)
