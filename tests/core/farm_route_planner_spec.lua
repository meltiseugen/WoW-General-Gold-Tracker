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
    local clearedWaypointCount = 0
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
            GetMapRectOnMap = options.getMapRectOnMap,
            SetUserWaypoint = function(point) waypoint = point end,
            ClearUserWaypoint = function()
                waypoint = nil
                clearedWaypointCount = clearedWaypointCount + 1
            end,
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
            CatalogGatheringData = gathering,
            InstanceDropsData = options.instanceDropsData,
            ATTBoEDropsData = options.attBoEDropsData,
        }
        assert(loadfile("Core/CustomFarms.lua"))("General-Gold-Tracker", ns)
        assert(loadfile("Core/InstanceEntrances.lua"))("General-Gold-Tracker", ns)
        assert(loadfile("Core/FarmRoutePlanner.lua"))("General-Gold-Tracker", ns)
        callback(
            addon,
            function() return waypoint end,
            function() return openedMapID end,
            function() return clearedWaypointCount end
        )
    end)
end

local function build_catalog()
    local farms = {
        {
            id = "catalog:drops:transmogs:deadmines",
            name = "The Deadmines",
            sourceType = "drops",
            sourcePath = "Instances",
            mapIDs = { 291 },
            mapNames = { "The Deadmines" },
            targets = { { itemID = 100, quantity = 1 } },
        },
        {
            id = "catalog:gathering:mining:copperore",
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
    it("starts breadcrumbs disabled while keeping minimap farm pins enabled", function()
        local catalog, gathering = build_catalog()
        with_planner(catalog, gathering, function(addon)
            local farm = addon:CreateCustomFarm("Guided farm", true)
            add_catalog_target(addon, farm, 2770, "Copper Ore", catalog.farms[2].id, "materials")
            local settings = addon:GetCustomFarmGuidanceSettings(farm.id)

            assert.is_true(settings.areaIndicator)
            assert.is_true(settings.routeDeviation)
            assert.is_true(settings.recoveryArrow)
            assert.is_true(settings.breadcrumbs)
            assert.is_true(settings.minimapOverlay)
            assert.is_true(addon:StartCustomFarmRoutePlan(farm.id))
            assert.is_false(addon:GetCustomFarmGuidanceSettings(farm.id).breadcrumbs)
            assert.is_true(addon:GetCustomFarmGuidanceSettings(farm.id).minimapOverlay)
            assert.is_false(addon:IsActiveCustomFarmBreadcrumbsEnabled())
            assert.is_true(addon:IsActiveCustomFarmMinimapOverlayEnabled())
            assert.is_true(addon:ToggleActiveCustomFarmGuidanceSetting("breadcrumbs"))
            assert.is_true(addon:IsActiveCustomFarmBreadcrumbsEnabled())
            assert.is_false(addon:SetCustomFarmGuidanceSetting(farm.id, "unknown", false))
        end)
    end)

    it("does not rebuild map-source route data while an active farm is polled", function()
        local catalog, gathering = build_catalog()
        with_planner(catalog, gathering, function(addon)
            local farm = addon:CreateCustomFarm("Cached route", true)
            local entry = addon:BuildCustomFarmEntry({ itemID = 22574, itemName = "Mote of Fire" }, "materials")
            local option = {
                id = "mote-of-fire",
                sourceType = "static",
                mapID = 1,
                mapLabel = "Durotar",
                pins = { { mapID = 1, x = 0.60, y = 0.70 } },
            }
            assert.is_true(addon:CommitCustomFarmEntry({ farmID = farm.id, entry = entry }, nil, option))

            local resolveCount = 0
            local originalResolve = addon.ResolveCustomFarmEntryMapOption
            addon.ResolveCustomFarmEntryMapOption = function(self, targetEntry)
                resolveCount = resolveCount + 1
                return originalResolve(self, targetEntry)
            end

            assert.is_true(addon:StartCustomFarmRoutePlan(farm.id))
            local countAfterStart = resolveCount
            for _ = 1, 20 do
                assert.is_table(addon:GetActiveCustomFarmRoutePlan())
                assert.is_true(addon:IsActiveCustomFarmMinimapOverlayEnabled())
            end

            assert.equals(countAfterStart, resolveCount)
        end)
    end)

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

    it("uses the Instances tab entrance as the exact destination for a Catalog instance farm", function()
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
            assert.is_true(plan[1].isInstance)
            assert.equals(1, #plan[1].candidates)
            local overview = assert(addon:BuildCustomFarmRoutePlanOverview(farm.id))
            assert.equals(1, overview.pins[1].routeOrder)
            assert.equals("dungeon", overview.pins[1].mapIconType)
            assert.equals("Dungeon", overview.pins[1].mapIconAtlas)
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
            local active = addon:GetActiveCustomFarmRoutePlan()
            assert.equals(farm, active.farm)
            assert.equals(2, active.currentIndex)
            assert.is_true(active.canGoPrevious)
            assert.is_false(active.canGoNext)
            assert.is_true(addon:SetCustomFarmRoutePlanStepComplete(farm.id, plan[2].key, true))
            assert.is_nil(addon:GetActiveCustomFarmRoutePlan())
        end)
    end)

    it("replaces the active Blizzard-map projection and waypoint as the route advances", function()
        local catalog, gathering = build_catalog()
        with_planner(catalog, gathering, function(addon, getWaypoint, _, getClearedWaypointCount)
            local farm = addon:CreateCustomFarm("Projected route", true)
            add_catalog_target(addon, farm, 100, "Sword", catalog.farms[1].id, "instances")
            add_catalog_target(addon, farm, 2770, "Copper Ore", catalog.farms[2].id, "materials")
            local plan = addon:BuildCustomFarmRoutePlan(farm.id, true)
            local projections = {}
            local clearedKeys = {}

            addon.BuildFarmDetailsMapOptions = function(_, farms)
                local catalogFarm = farms[1]
                local mapID = catalogFarm.id == catalog.farms[1].id and 37 or 1
                return {
                    {
                        mapID = mapID,
                        mapLabel = mapID == 37 and "Westfall" or "Durotar",
                        location = catalogFarm.name,
                        pins = { { mapID = mapID, x = 0.4, y = 0.6, label = catalogFarm.name } },
                    },
                }
            end
            addon.ProjectMapRouteToWorldMap = function(_, options)
                projections[#projections + 1] = options
                return true
            end
            addon.ClearWorldMapProjectionByKey = function(_, projectionKey, silent)
                clearedKeys[#clearedKeys + 1] = { key = projectionKey, silent = silent }
                return true, 1
            end

            assert.is_true(addon:StartCustomFarmRoutePlan(farm.id))
            assert.equals("active-farm-route:" .. tostring(farm.id), projections[1].projectionKey)
            assert.equals(plan[1].mapID, projections[1].mapID)
            assert.is_true(projections[1].silent)
            assert.is_false(projections[1].openMap)
            assert.equals(plan[1].mapID, getWaypoint().mapID)

            assert.is_true(addon:SetCustomFarmRoutePlanStepComplete(farm.id, plan[1].key, true))
            assert.equals(2, #projections)
            assert.equals(plan[2].mapID, projections[2].mapID)
            assert.equals(plan[2].mapID, getWaypoint().mapID)
            assert.equals("active-farm-route:" .. tostring(farm.id), clearedKeys[#clearedKeys].key)
            assert.is_true(clearedKeys[#clearedKeys].silent)

            assert.is_true(addon:SetCustomFarmRoutePlanStepComplete(farm.id, plan[2].key, true))
            assert.is_nil(getWaypoint())
            assert.is_nil(addon:GetActiveCustomFarmRoutePlan())
            assert.is_true(getClearedWaypointCount() >= 3)
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

    it("stops an active route without clearing completed progress", function()
        local catalog, gathering = build_catalog()
        with_planner(catalog, gathering, function(addon, getWaypoint)
            local farm = addon:CreateCustomFarm("Mining", true)
            add_catalog_target(addon, farm, 2770, "Copper Ore", catalog.farms[2].id, "materials")
            local plan = addon:BuildCustomFarmRoutePlan(farm.id, true)
            local clearedKey
            local savedReason
            addon.ClearWorldMapProjectionByKey = function(_, projectionKey)
                clearedKey = projectionKey
                return true, 1
            end
            addon.SaveCustomFarmRunToHistory = function(_, savedFarm, savedRun, reason)
                assert.equals(farm, savedFarm)
                assert.is_not_nil(savedRun.currentStepKey)
                savedReason = reason
                return true
            end

            assert.is_true(addon:StartCustomFarmRoutePlan(farm.id))
            local run = addon:GetCustomFarmRoutePlanRun(farm.id)
            run.completed[plan[1].key] = true
            assert.is_not_nil(getWaypoint())

            assert.is_true(addon:StopCustomFarmRoutePlan(farm.id))
            run = addon:GetCustomFarmRoutePlanRun(farm.id)
            assert.is_true(run.completed[plan[1].key])
            assert.is_nil(run.currentStepKey)
            assert.is_nil(getWaypoint())
            assert.equals("active-farm-route:" .. tostring(farm.id), clearedKey)
            assert.equals("stopped", savedReason)
            assert.is_nil(addon:GetActiveCustomFarmRoutePlan())
        end)
    end)

    it("toggles the selected farm route between started and stopped", function()
        local catalog, gathering = build_catalog()
        with_planner(catalog, gathering, function(addon)
            local farm = addon:CreateCustomFarm("Mining", true)
            add_catalog_target(addon, farm, 2770, "Copper Ore", catalog.farms[2].id, "materials")

            assert.is_false(addon:IsCustomFarmRoutePlanActive(farm.id))
            assert.is_true(addon:ToggleCustomFarmRoutePlan(farm.id))
            assert.is_true(addon:IsCustomFarmRoutePlanActive(farm.id))

            assert.is_true(addon:ToggleCustomFarmRoutePlan(farm.id))
            assert.is_false(addon:IsCustomFarmRoutePlanActive(farm.id))
        end)
    end)

    it("records a completed active farm before closing it", function()
        local catalog, gathering = build_catalog()
        with_planner(catalog, gathering, function(addon)
            local farm = addon:CreateCustomFarm("Mining", true)
            add_catalog_target(addon, farm, 2770, "Copper Ore", catalog.farms[2].id, "materials")
            local plan = addon:BuildCustomFarmRoutePlan(farm.id, true)
            local savedReason
            addon.SaveCustomFarmRunToHistory = function(_, savedFarm, savedRun, reason)
                assert.equals(farm, savedFarm)
                assert.is_true(savedRun.completed[plan[1].key])
                savedReason = reason
                return true
            end

            assert.is_true(addon:StartCustomFarmRoutePlan(farm.id))
            assert.is_true(addon:SetCustomFarmRoutePlanStepComplete(farm.id, plan[1].key, true))

            assert.equals("completed", savedReason)
            assert.is_nil(addon:GetActiveCustomFarmRoutePlan())
        end)
    end)

    it("moves the active farm backward and forward from the main tracker controls", function()
        local catalog, gathering = build_catalog()
        with_planner(catalog, gathering, function(addon, getWaypoint, getOpenedMapID)
            local farm = addon:CreateCustomFarm("Mixed", true)
            add_catalog_target(addon, farm, 100, "Sword", catalog.farms[1].id, "instances")
            add_catalog_target(addon, farm, 2770, "Copper Ore", catalog.farms[2].id, "materials")
            local plan = addon:BuildCustomFarmRoutePlan(farm.id, true)

            assert.is_true(addon:StartCustomFarmRoutePlan(farm.id))
            assert.is_true(addon:NavigateActiveCustomFarmRoutePlanStep(1))
            assert.equals(291, getOpenedMapID())
            assert.equals(plan[2].key, addon:GetActiveCustomFarmRoutePlan().currentNode.key)

            assert.is_true(addon:NavigateActiveCustomFarmRoutePlanStep(-1))
            assert.equals(1, getWaypoint().mapID)
            assert.equals(plan[1].key, addon:GetActiveCustomFarmRoutePlan().currentNode.key)
            assert.is_false(addon:NavigateActiveCustomFarmRoutePlanStep(-1))
        end)
    end)

    it("does not replace the active farm when a paused plan row is completed", function()
        local catalog, gathering = build_catalog()
        with_planner(catalog, gathering, function(addon)
            local firstFarm = addon:CreateCustomFarm("First", true)
            local secondFarm = addon:CreateCustomFarm("Second", true)
            add_catalog_target(addon, firstFarm, 2770, "Copper Ore", catalog.farms[2].id, "materials")
            add_catalog_target(addon, secondFarm, 100, "Sword", catalog.farms[1].id, "instances")
            local firstPlan = addon:BuildCustomFarmRoutePlan(firstFarm.id, true)
            local clearedKeys = {}
            addon.ClearWorldMapProjectionByKey = function(_, projectionKey)
                clearedKeys[#clearedKeys + 1] = projectionKey
                return true, 1
            end

            assert.is_true(addon:StartCustomFarmRoutePlan(firstFarm.id))
            assert.is_true(addon:StartCustomFarmRoutePlan(secondFarm.id))
            local clearCountBeforePausedCompletion = #clearedKeys
            assert.is_true(addon:SetCustomFarmRoutePlanStepComplete(firstFarm.id, firstPlan[1].key, true))
            assert.equals(secondFarm, addon:GetActiveCustomFarmRoutePlan().farm)
            assert.equals(clearCountBeforePausedCompletion, #clearedKeys)
        end)
    end)

    it("opens the selected route row's matching map data", function()
        local catalog, gathering = build_catalog()
        with_planner(catalog, gathering, function(addon)
            local farm = addon:CreateCustomFarm("Mining", true)
            add_catalog_target(addon, farm, 2770, "Copper Ore", catalog.farms[2].id, "materials")
            local plan = addon:BuildCustomFarmRoutePlan(farm.id, true)
            local opened
            addon.BuildFarmDetailsMapOptions = function(_, farms, itemID)
                assert.equals(catalog.farms[2], farms[1])
                assert.equals(2770, itemID)
                return {
                    { mapID = 1, mapLabel = "Durotar", location = "Wrong route", pins = {} },
                    { mapID = 1, mapLabel = "Durotar", location = "Copper Ore", pins = { { x = 0.8, y = 0.8 } } },
                }
            end
            addon.OpenStandaloneMapWindow = function(_, options)
                opened = options
            end

            assert.is_true(addon:OpenCustomFarmRoutePlanStepMap(farm.id, plan[1].key))
            assert.equals(2, opened.selectedMapOptionIndex)
            assert.equals("overlay", opened.displayMode)
            assert.equals("route-plan:" .. tostring(farm.id) .. ":" .. plan[1].key, opened.projectionKey)
        end)
    end)

    it("projects sibling-zone route stops onto their shared parent map in plan order", function()
        local mapInfo = {
            [1] = { name = "West Zone", mapType = 3, parentMapID = 12 },
            [2] = { name = "East Zone", mapType = 3, parentMapID = 12 },
            [12] = { name = "Shared Continent", mapType = 2, parentMapID = 0 },
        }
        with_planner({ farms = {}, byID = {} }, { farmsByRecordID = {} }, function(addon)
            local farm = addon:CreateCustomFarm("Continent Tour", true)
            local west = addon:BuildCustomFarmEntry({ itemID = 1001, itemName = "West Farm" }, "materials")
            local east = addon:BuildCustomFarmEntry({ itemID = 1002, itemName = "East Farm" }, "materials")
            assert.is_true(addon:CommitCustomFarmEntry({ farmID = farm.id, entry = west }, nil, {
                id = "west", mapID = 1, mapLabel = "West Zone",
                pins = { { mapID = 1, x = 0.2, y = 0.3 } },
            }))
            assert.is_true(addon:CommitCustomFarmEntry({ farmID = farm.id, entry = east }, nil, {
                id = "east", mapID = 2, mapLabel = "East Zone",
                pins = { { mapID = 2, x = 0.8, y = 0.7 } },
            }))

            local overview = assert(addon:BuildCustomFarmRoutePlanOverview(farm.id))
            assert.equals(12, overview.mapID)
            assert.equals("Shared Continent", overview.mapName)
            assert.is_true(overview.usesParentMap)
            assert.equals(2, #overview.pins)
            assert.equals(1, overview.pins[1].routeOrder)
            assert.equals(2, overview.pins[2].routeOrder)
            assert.equals(overview.routeID, overview.pins[1].routeID)
            assert.equals(overview.routeID, overview.pins[2].routeID)
            assert.near(0.16, overview.pins[1].x, 0.0001)
            assert.near(0.32, overview.pins[1].y, 0.0001)
            assert.near(0.82, overview.pins[2].x, 0.0001)
            assert.near(0.38, overview.pins[2].y, 0.0001)
        end, {
            playerMapID = 1,
            playerX = 0.2,
            playerY = 0.3,
            mapInfo = mapInfo,
            getMapRectOnMap = function(childMapID, parentMapID)
                assert.equals(12, parentMapID)
                if childMapID == 1 then
                    return 0.1, 0.4, 0.2, 0.6
                elseif childMapID == 2 then
                    return 0.5, 0.9, 0.1, 0.5
                end
            end,
        })
    end)

    it("keeps same-map overview coordinates and opens numbered icons with the route line", function()
        local catalog, gathering = build_catalog()
        with_planner(catalog, gathering, function(addon)
            local farm = addon:CreateCustomFarm("Durotar Circuit", true)
            for index, point in ipairs({ { 0.2, 0.3 }, { 0.8, 0.7 } }) do
                local entry = addon:BuildCustomFarmEntry({
                    itemID = 2000 + index,
                    itemName = "Farm " .. tostring(index),
                }, "materials")
                assert.is_true(addon:CommitCustomFarmEntry({ farmID = farm.id, entry = entry }, nil, {
                    id = "durotar-" .. tostring(index), mapID = 1, mapLabel = "Durotar",
                    pins = { { mapID = 1, x = point[1], y = point[2] } },
                }))
            end

            local overview = assert(addon:BuildCustomFarmRoutePlanOverview(farm.id))
            assert.equals(1, overview.mapID)
            assert.is_false(overview.usesParentMap)
            for index, node in ipairs(overview.plan) do
                assert.equals(node.x, overview.pins[index].x)
                assert.equals(node.y, overview.pins[index].y)
            end

            local opened
            addon.OpenStandaloneMapWindow = function(_, options) opened = options end
            assert.is_true(addon:OpenCustomFarmRoutePlanOverview(farm.id))
            assert.equals("icons", opened.displayMode)
            assert.is_true(opened.mapOptions[1].showRouteLinesWithIcons)
            assert.equals(overview.routeID, opened.projectionKey)
            assert.equals(4, #opened.detailLinesBuilder())
        end)
    end)

    it("opens separate map choices when route stops do not share a map parent", function()
        local catalog, gathering = build_catalog()
        with_planner(catalog, gathering, function(addon)
            local farm = addon:CreateCustomFarm("Cross-continent", true)
            add_catalog_target(addon, farm, 100, "Sword", catalog.farms[1].id, "instances")
            add_catalog_target(addon, farm, 2770, "Copper Ore", catalog.farms[2].id, "materials")
            local overview = assert(addon:BuildCustomFarmRoutePlanOverview(farm.id))
            assert.equals(2, #overview.mapOptions)
            for index, option in ipairs(overview.mapOptions) do
                assert.equals(overview.plan[index].mapID, option.mapID)
                assert.equals(index, option.pins[1].routeOrder)
                assert.equals(overview.plan[index].x or 0.5, option.pins[1].x)
                assert.equals(overview.plan[index].y or 0.5, option.pins[1].y)
            end
            local opened
            addon.OpenStandaloneMapWindow = function(_, options) opened = options end
            assert.is_true(addon:OpenCustomFarmRoutePlanOverview(farm.id))
            assert.equals(2, #opened.mapOptions)
            assert.matches("Choose a map", opened.detailLinesBuilder()[2].text)
        end)
    end)

    it("falls back to source maps if a shared map cannot project every stop", function()
        with_planner({}, {}, function(addon)
            addon.GetCustomFarmByID = function() return { id = 1, name = "Sibling zones" } end
            addon.BuildCustomFarmRoutePlan = function()
                return {
                    { mapID = 1, x = 0.2, y = 0.3 },
                    { mapID = 2, x = 0.6, y = 0.7 },
                    { mapID = 1, x = 0.8, y = 0.9 },
                }
            end
            local overview = assert(addon:BuildCustomFarmRoutePlanOverview(1))
            assert.equals(2, #overview.mapOptions)
            local first = overview.mapOptions[1]
            assert.equals(1, first.mapID)
            assert.equals(2, #first.pins)
            assert.equals(1, first.pins[1].routeOrder)
            assert.equals(3, first.pins[2].routeOrder)
            assert.equals(0.2, first.pins[1].x)
            assert.equals(0.9, first.pins[2].y)
            -- A visit to another map interrupts the line between these stops.
            assert.is_false(first.pins[1].routeID == first.pins[2].routeID)
        end, { mapInfo = {
            [1] = { name = "West", parentMapID = 12 },
            [2] = { name = "East", parentMapID = 12 },
            [12] = { name = "Continent" },
        }, getMapRectOnMap = function(childMapID)
            if childMapID == 1 then return 0.1, 0.4, 0.2, 0.6 end
        end })
    end)

    it("shows mapped stops and explicitly lists unresolved stops with their original numbers", function()
        with_planner({}, {}, function(addon)
            addon.GetCustomFarmByID = function() return { id = 1, name = "Unresolved" } end
            addon.BuildCustomFarmRoutePlan = function()
                return { {}, { mapID = 1, x = 0.2, y = 0.3 }, {}, { mapID = 1 } }
            end
            local overview = assert(addon:BuildCustomFarmRoutePlanOverview(1))
            assert.equals(1, #overview.mapOptions)
            assert.equals(2, overview.unmappedStopCount)
            assert.equals(2, #overview.pins)
            assert.equals(2, overview.pins[1].routeOrder)
            assert.equals(4, overview.pins[2].routeOrder)
            assert.is_false(overview.pins[1].routeID == overview.pins[2].routeID)
            assert.is_true(overview.pins[2].approximate)
            local opened
            addon.OpenStandaloneMapWindow = function(_, options) opened = options end
            assert.is_true(addon:OpenCustomFarmRoutePlanOverview(1))
            local lines = opened.detailLinesBuilder()
            assert.equals(6, #lines)
            assert.matches("2 stops have no map data", lines[2].text)
            assert.matches("map location unavailable", lines[3].text)
            assert.matches("zone center", lines[6].text)
        end)
    end)

    it("explains why an overview cannot open when no stops have map data", function()
        with_planner({}, {}, function(addon)
            addon.GetCustomFarmByID = function() return { id = 1, name = "Unresolved" } end
            addon.BuildCustomFarmRoutePlan = function() return { {}, {} } end
            addon.OpenStandaloneMapWindow = function() error("An overview without maps must not open") end
            local overview, reason = addon:BuildCustomFarmRoutePlanOverview(1)
            assert.is_nil(overview)
            assert.matches("No route stops have map data", reason)
            assert.is_false(addon:OpenCustomFarmRoutePlanOverview(1))
            assert.equals(reason, addon.messages[1])
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
                    id = "catalog:gathering:mining:alternate",
                    name = "Alternate Mining",
                    sourceType = "gathering",
                    mapIDs = { 1, 37 },
                    mapNames = { "Durotar", "Elwynn Forest" },
                    targets = { { itemID = 300, quantity = 10 } },
                },
            },
            byID = { ["catalog:gathering:mining:alternate"] = 1 },
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

            assert.is_true(addon:HasCustomFarmRoutePlan(farm.id))

            assert.equals("exact", plan[1].confidence)
            assert.equals("unknown", plan[2].confidence)
        end)
    end)
end)
