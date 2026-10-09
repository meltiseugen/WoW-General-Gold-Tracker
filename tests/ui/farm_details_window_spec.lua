local loader = require("tests.helpers.addon_loader")

local catalog = {
    sourceVersion = "test",
    sourceURL = "https://example.test/farms",
    farms = {
        {
            id = "catalog:gathering:mining:old-ore",
            provider = "catalog",
            providerKey = "OldOre",
            providerFarmID = "OldOre",
            sourceType = "gathering",
            sourceDataset = "CatalogGatheringData",
            sourceCategory = "Mining",
            sourceRecordIDs = { "Mining:OldOre:1", "Mining:OldOre:2" },
            activity = "mining",
            name = "Old Ore Route",
            expansion = "classic",
            primaryItemID = 3001,
            recordedSeconds = 1800,
            durationInferred = false,
            rawCopper = 500,
            routeCount = 1,
            mapNames = { "Test Valley" },
            targets = {
                { itemID = 3001, quantity = 10 },
                { itemID = 3002, quantity = 2 },
            },
        },
        {
            id = "catalog:gathering:multi:shared-route",
            provider = "catalog",
            providerKey = "SharedRoute",
            providerFarmID = "SharedRoute",
            sourceType = "gathering",
            sourceDataset = "CatalogGatheringData",
            sourceCategory = "MultiFarms",
            sourceRecordIDs = {},
            activity = "multi-farm",
            name = "Shared Route",
            expansion = "classic",
            primaryItemID = 3003,
            recordedSeconds = 3600,
            durationInferred = true,
            rawCopper = nil,
            routeCount = 1,
            mapNames = { "Other Valley" },
            targets = {
                { itemID = 3001, quantity = 4 },
            },
        },
        {
            id = "catalog:drops:transmogs:cloth-place",
            provider = "catalog",
            providerKey = "ClothPlace",
            providerFarmID = "ClothPlace",
            sourceType = "drops",
            sourceDataset = "CatalogDropsData",
            sourceCategory = "instances",
            sourcePath = "Instances",
            sourceRecordIDs = {},
            activity = "transmog",
            name = "Cloth Place",
            expansion = "classic",
            primaryItemID = nil,
            recordedSeconds = 3600,
            durationInferred = false,
            rawCopper = nil,
            routeCount = 0,
            mapIDs = { 77 },
            mapNames = { "Old Dungeon" },
            targets = {
                { itemID = 3001, quantity = 20 },
                { itemID = 3002, quantity = 2 },
                { itemID = 3003, quantity = 1 },
                { itemID = 3004, quantity = 50 },
            },
        },
        {
            id = "catalog:drops:openworldinstances:noteworthy-place",
            provider = "catalog",
            providerKey = "NoteworthyPlace",
            providerFarmID = "NoteworthyPlace",
            sourceType = "drops",
            sourceDataset = "CatalogDropsData",
            sourceCategory = "openWorldInstances",
            sourcePath = "Open World > Transmog",
            sourceRecordIDs = {},
            activity = "transmog",
            name = "Noteworthy Place",
            expansion = "classic",
            primaryItemID = nil,
            recordedSeconds = 3600,
            durationInferred = true,
            rawCopper = nil,
            routeCount = 0,
            mapIDs = { 78 },
            mapNames = { "Open World Dungeon" },
            targets = {
                { itemID = 3003, quantity = 1 },
            },
        },
    },
    byID = {
        ["catalog:gathering:mining:old-ore"] = 1,
        ["catalog:gathering:multi:shared-route"] = 2,
        ["catalog:drops:transmogs:cloth-place"] = 3,
        ["catalog:drops:openworldinstances:noteworthy-place"] = 4,
    },
    indexes = {
        byItemID = {
            [3001] = { 3, 2, 1 },
            [3002] = { 1 },
        },
    },
}

local gathering = {
    farmsByRecordID = {
        ["Mining:OldOre:1"] = {
            routes = {
                {
                    name = "Old Ore Loop",
                    mapID = 42,
                    mapName = "Test Valley",
                    coords = {
                        { x = 0.10, y = 0.20, label = "Point 1" },
                        { x = 0.30, y = 0.40, label = "Point 2" },
                    },
                },
            },
        },
        -- Duplicate source record from the catalog's repeated module entry. The map
        -- builder must not display the same route twice.
        ["Mining:OldOre:2"] = {
            routes = {
                {
                    name = "Old Ore Loop",
                    mapID = 42,
                    mapName = "Test Valley",
                    coords = {
                        { x = 0.10, y = 0.20, label = "Point 1" },
                        { x = 0.30, y = 0.40, label = "Point 2" },
                    },
                },
            },
        },
    },
}

local function load_window(catalogOverride)
    local addon = {
        GetCraftingFarmingValueSource = function()
            return { id = "test-value", label = "Test Value" }
        end,
        ResolveItemUnitValue = function(_, _, _, itemID)
            return ({ [3001] = 100, [3002] = 250, [3003] = 900 })[itemID] or 0, nil, "Test Value"
        end,
        FormatMoney = function(_, copper)
            return tostring(copper) .. "c"
        end,
    }

    return loader.with_globals({
        C_Item = {
            GetItemInfo = function(itemID)
                return ({ [3001] = "Old Ore", [3002] = "New Herb", [3003] = "Rare Sword" })[itemID], "item:" .. tostring(itemID)
            end,
            RequestLoadItemDataByID = function() end,
        },
    }, function()
        return loader.load_module("UI/FarmDetailsWindow.lua", addon, {
            FarmCatalog = catalogOverride or catalog,
            CatalogGatheringData = gathering,
            JanisTheme = {},
        })
    end)
end

describe("UI/FarmDetailsWindow data flow", function()
    it("orders a material's primary gathering farm before byproduct farms", function()
        local addon = load_window()
        local farms = addon:GetFarmsForItem(3001)

        assert.equals(3, #farms)
        assert.equals("catalog:gathering:mining:old-ore", farms[1].id)
        assert.equals("catalog:gathering:multi:shared-route", farms[2].id)
        assert.equals("catalog:drops:transmogs:cloth-place", farms[3].id)
        assert.equals(0, #addon:GetFarmsForItem(9999))
    end)

    it("builds only the selected farm's decoded route and deduplicates repeated records", function()
        local addon = load_window()
        local farm = addon:GetFarmByID("catalog:gathering:mining:old-ore")
        local options = addon:BuildFarmRouteMapOptions(farm)

        assert.equals(1, #options)
        assert.equals(42, options[1].mapID)
        assert.equals("Old Ore Loop", options[1].label)
        assert.equals(2, #options[1].pins)
        assert.equals(0.10, options[1].pins[1].x)
        assert.equals(0.40, options[1].pins[2].y)
        assert.is_true(options[1].pins[1].isRoute)
        assert.equals(options[1].id, options[1].pins[1].routeID)
        assert.equals("GGT bundled farm snapshot", options[1].pins[1].sourceLabel)
    end)

    it("keeps non-herb and non-ore Catalog routes as unconnected map pins", function()
        local addon = load_window()
        local farm = {
            id = "catalog:gathering:fishing:test-fish",
            sourceDataset = "CatalogGatheringData",
            sourceCategory = "Fishing",
            sourceRecordIDs = { "Mining:OldOre:1" },
            activity = "fishing",
            name = "Test Fish",
        }

        local options = addon:BuildFarmRouteMapOptions(farm)

        assert.equals(1, #options)
        assert.equals(2, #options[1].pins)
        assert.is_false(options[1].pins[1].isRoute)
        assert.is_nil(options[1].pins[1].routeID)
    end)

    it("uses researched material points when an imported gathering farm has no decoded route", function()
        local addon = load_window()
        addon.BuildMaterialFarmingMapOptions = function(_, itemID)
            assert.equals(4001, itemID)
            return {
                {
                    id = "researched-material-spot",
                    mapID = 42,
                    mapLabel = "Test Valley",
                    label = "Test Valley: pond",
                    pins = {
                        { mapID = 42, x = 0.25, y = 0.50, label = "Pond", isRoute = false },
                    },
                },
            }
        end

        local options = addon:BuildFarmRouteMapOptions({
            id = "catalog:gathering:fishing:no-route",
            sourceDataset = "CatalogGatheringData",
            sourceCategory = "Fishing",
            sourceRecordIDs = { "Fishing:Missing:1" },
            primaryItemID = 4001,
            name = "Test Fish",
        })

        assert.equals(1, #options)
        assert.equals("catalog:gathering:fishing:no-route:material:researched-material-spot", options[1].id)
        assert.equals("Related researched material location", options[1].pins[1].sourceLabel)
    end)

    it("uses the Encounter Journal entrance when an imported instance farm has no static pins", function()
        local addon = load_window()
        addon.ResolveCatalogFarmInstanceEntrance = function(_, farm)
            assert.equals("catalog:drops:transmogs:test-instance", farm.id)
            return {
                mapID = 42,
                mapName = "Test Valley",
                label = "Test Instance entrance",
                x = 0.25,
                y = 0.50,
            }
        end

        local options = addon:BuildFarmRouteMapOptions({
            id = "catalog:drops:transmogs:test-instance",
            sourceDataset = "CatalogDropsData",
            sourceCategory = "instances",
            mapIDs = { 42 },
            mapNames = { "Test Valley" },
            name = "Test Instance",
        })

        assert.equals(1, #options)
        assert.equals(0.25, options[1].pins[1].x)
        assert.is_false(options[1].pins[1].isRoute)
        assert.equals("Encounter Journal entrance", options[1].pins[1].sourceLabel)
    end)

    it("keeps an imported researched pin non-route and preserves its research source", function()
        local addon = load_window()
        local options = addon:BuildFarmRouteMapOptions({
            id = "catalog:gathering:fishing:researched-location",
            sourceDataset = "CatalogGatheringData",
            sourceCategory = "Fishing",
            activity = "fishing",
            name = "Test Fish",
            locationResearchSource = "Wowhead location research",
            mapOptions = {
                {
                    mapID = 42,
                    label = "Test pond",
                    isRoute = false,
                    pins = { { x = 0.25, y = 0.50, label = "Pond" } },
                },
            },
        })

        assert.equals(1, #options)
        assert.is_false(options[1].pins[1].isRoute)
        assert.equals("farm-fishing", options[1].pins[1].routeType)
        assert.equals("Wowhead location research", options[1].pins[1].sourceLabel)
    end)

    it("builds researched mount pins and guidance without fake yield estimates", function()
        local addon = load_window()
        local farm = {
            id = "ggt:mount:test",
            sourceType = "curated",
            sourceDataset = "GGTMountFarmData",
            sourceCategory = "mounts",
            activity = "mount",
            name = "Test Mount",
            expansion = "battle-for-azeroth",
            primaryItemID = 3003,
            routeCount = 1,
            mapNames = { "Test Valley" },
            targets = {},
            summary = "A researched test summary.",
            guide = {
                label = "World-drop circuit",
                requirement = "Reach the test area.",
                action = "Follow the researched circuit.",
                tips = { "Use the current route, not the obsolete hyperspawn." },
            },
            details = { "Recent reports confirm this mob cluster." },
            sourceUrls = {
                { siteName = "Comment research", url = "https://example.test/comments" },
                { siteName = "Independent guide", url = "https://example.test/guide" },
            },
            mapOptions = {
                {
                    id = "ggt:mount:test:loop",
                    mapID = 42,
                    mapLabel = "Test Valley",
                    label = "Current mob loop",
                    location = "Test farm",
                    isRoute = true,
                    density = "Dense test packs",
                    dropDifficulty = "Very rare world drop.",
                    pins = {
                        { x = 0.25, y = 0.35, label = "Pack one" },
                        { x = 0.45, y = 0.55, label = "Pack two" },
                    },
                },
            },
        }

        local options = addon:BuildFarmRouteMapOptions(farm)
        assert.equals(1, #options)
        assert.equals(2, #options[1].pins)
        assert.equals(42, options[1].pins[1].mapID)
        assert.is_false(options[1].pins[1].isRoute)
        assert.is_nil(options[1].pins[1].routeID)
        assert.equals("farm-mount", options[1].pins[1].routeType)
        assert.equals("Dense test packs", options[1].pins[1].density)
        assert.equals("GGT researched mount guide", options[1].pins[1].sourceLabel)
        assert.same({ "https://example.test/comments", "https://example.test/guide" }, options[1].pins[1].sourceUrls)

        addon.BuildFarmValuationSnapshot = function()
            error("curated mount details must not calculate a fake yield valuation")
        end
        local lines = addon:BuildFarmMapDetailLines(farm, 3003, "Test Valley")
        local rendered = {}
        local sourceCount = 0
        for _, line in ipairs(lines) do
            if line.type == "source" then
                sourceCount = sourceCount + 1
                rendered[#rendered + 1] = line.siteName
            else
                rendered[#rendered + 1] = line.text
            end
        end
        local mapText = table.concat(rendered, "\n")
        assert.is_truthy(string.find(mapText, "A researched test summary.", 1, true))
        assert.is_truthy(string.find(mapText, "Follow the researched circuit.", 1, true))
        assert.is_truthy(string.find(mapText, "Recent reports confirm this mob cluster.", 1, true))
        assert.is_truthy(string.find(mapText, "Independent guide", 1, true))
        assert.is_nil(string.find(mapText, "Farm estimate", 1, true))
        assert.is_nil(string.find(mapText, "Recorded yields", 1, true))
        assert.equals(2, sourceCount)

        local fallbackText = addon:BuildFarmDetailsText(farm, 3003)
        assert.is_truthy(string.find(fallbackText, "SOURCES", 1, true))
        assert.is_truthy(string.find(fallbackText, "https://example.test/guide", 1, true))
        assert.is_nil(string.find(fallbackText, "VALUATION", 1, true))
    end)

    it("looks up researched pet farms by pet ID and opens their mapped details", function()
        local petFarm = {
            id = "ggt:pet:emerald-whelpling",
            sourceType = "curated",
            sourceDataset = "GGTPetFarmData",
            sourceCategory = "pets",
            sourcePath = "Drops > Pets",
            activity = "pet",
            name = "Emerald Whelpling",
            expansion = "Classic",
            primaryPetID = 59,
            routeCount = 1,
            mapNames = { "Feralas" },
            targets = {},
            summary = "A researched pet acquisition.",
            guide = {
                label = "Mapped outdoor acquisition",
                requirement = "Reach the marked point.",
                action = "Farm the named source.",
                tips = { "Check the nearby patrol." },
            },
            sourceUrls = {
                { siteName = "Pet database", url = "https://example.test/pet" },
            },
            mapOptions = {
                {
                    id = "ggt:pet:emerald-whelpling:location",
                    mapID = 69,
                    mapLabel = "Feralas",
                    label = "Noxious Whelp",
                    location = "Feralas",
                    isRoute = false,
                    pins = {
                        { x = 0.462, y = 0.078, label = "Noxious Whelp - Emerald Whelpling" },
                    },
                },
            },
        }
        local petCatalog = {
            farms = { petFarm },
            byID = { [petFarm.id] = 1 },
            indexes = {
                byPetID = { [59] = { 1 } },
                byRecordID = { ["pets:EmeraldWhelplingFeralas:1"] = { 1 } },
            },
        }
        local addon = load_window(petCatalog)

        assert.same({ true, 1 }, { addon:HasFarmForPet(59) })
        assert.same({ false, 0 }, { addon:HasFarmForPet(9999) })
        assert.equals(petFarm, addon:GetFarmsForPet(59)[1])
        assert.same({ true, 1 }, { addon:HasFarmForRecordID("pets:EmeraldWhelplingFeralas:1") })

        local options = addon:BuildFarmRouteMapOptions(petFarm)
        assert.equals(1, #options)
        assert.equals(69, options[1].mapID)
        assert.equals("farm-pet", options[1].pins[1].routeType)
        assert.equals("GGT researched pet guide", options[1].pins[1].sourceLabel)

        local captured
        addon.OpenStandaloneMapWindow = function(_, openOptions)
            captured = openOptions
        end
        assert.is_true(addon:OpenFarmDetailsForPet(59))
        assert.equals(petFarm.id, captured.projectionKey)
        assert.equals(1, #captured.mapOptions)
        local lines = captured.detailLinesBuilder(captured.mapOptions[1], 69, "Feralas")
        local rendered = {}
        for _, line in ipairs(lines) do
            rendered[#rendered + 1] = line.text or line.siteName
        end
        local text = table.concat(rendered, "\n")
        assert.is_truthy(string.find(text, "A researched pet acquisition.", 1, true))
        assert.is_truthy(string.find(text, "Pet database", 1, true))
        assert.is_nil(string.find(text, "Recorded yields", 1, true))

        captured = nil
        assert.is_true(addon:OpenFarmDetailsForRecordID("pets:EmeraldWhelplingFeralas:1"))
        assert.equals(petFarm.id, captured.projectionKey)
    end)

    it("opens researched toy records with toy-specific map metadata", function()
        local toyFarm = {
            id = "ggt:toy:big-red-raygun",
            sourceType = "curated",
            sourceDataset = "GGTToyFarmData",
            sourceCategory = "toys",
            sourcePath = "Drops > Toys",
            activity = "toy",
            name = "Big Red Raygun",
            expansion = "Legion",
            primaryItemID = 142265,
            sourceRecordID = "toys:BigRedRayGun:1",
            routeCount = 1,
            mapNames = { "Dustwallow Marsh" },
            targets = {},
            summary = "A researched toy acquisition.",
            guide = {
                label = "Named elite camp",
                requirement = "Reach Alcaz Island.",
                action = "Defeat Doctor Weavil.",
                tips = { "Enter the largest house." },
            },
            sourceUrls = {
                { siteName = "Toy research", url = "https://example.test/toy" },
            },
            mapOptions = {
                {
                    id = "ggt:toy:big-red-raygun:doctor-weavil",
                    mapID = 70,
                    mapLabel = "Dustwallow Marsh",
                    label = "Doctor Weavil",
                    location = "Alcaz Island",
                    isRoute = false,
                    pins = {
                        { x = 0.778, y = 0.174, label = "Doctor Weavil - upper floor" },
                    },
                },
            },
        }
        local toyCatalog = {
            farms = { toyFarm },
            byID = { [toyFarm.id] = 1 },
            indexes = {
                byItemID = { [142265] = { 1 } },
                byRecordID = { ["toys:BigRedRayGun:1"] = { 1 } },
            },
        }
        local addon = load_window(toyCatalog)

        assert.same({ true, 1 }, { addon:HasFarmForItem(142265) })
        assert.same({ true, 1 }, { addon:HasFarmForRecordID("toys:BigRedRayGun:1") })
        local options = addon:BuildFarmRouteMapOptions(toyFarm)
        assert.equals(1, #options)
        assert.equals(70, options[1].mapID)
        assert.equals("farm-toy", options[1].pins[1].routeType)
        assert.equals("GGT researched toy guide", options[1].pins[1].sourceLabel)

        local captured
        addon.OpenStandaloneMapWindow = function(_, openOptions)
            captured = openOptions
        end
        assert.is_true(addon:OpenFarmDetailsForRecordID("toys:BigRedRayGun:1"))
        assert.equals(toyFarm.id, captured.projectionKey)
        assert.equals(1, #captured.mapOptions)
        local lines = captured.detailLinesBuilder(captured.mapOptions[1], 70, "Dustwallow Marsh")
        local rendered = {}
        for _, line in ipairs(lines) do
            rendered[#rendered + 1] = line.text or line.siteName
        end
        local text = table.concat(rendered, "\n")
        assert.is_truthy(string.find(text, "A researched toy acquisition.", 1, true))
        assert.is_truthy(string.find(text, "Toy research", 1, true))
        assert.is_nil(string.find(text, "Recorded yields", 1, true))
    end)

    it("combines matching routes and instance maps into map options with farm context", function()
        local addon = load_window()
        local farms = addon:GetFarmsForItem(3001)
        local options = addon:BuildFarmDetailsMapOptions(farms, 3001)

        assert.equals(2, #options)
        assert.equals("catalog:gathering:mining:old-ore", options[1].farmID)
        assert.equals("Old Ore Route", options[1].windowTitle)
        assert.equals("farm: Old Ore Route - Old Ore Loop", options[1].label)
        assert.equals(3001, options[1].selectedItemID)
        assert.equals("catalog:drops:transmogs:cloth-place", options[2].farmID)
        assert.equals(77, options[2].mapID)
        assert.equals("farm: Cloth Place - Old Dungeon", options[2].label)
        assert.is_true(options[2].mapOnly)
        assert.equals(0, #options[2].pins)
    end)

    it("distinguishes a pet boss map from its instance entrance", function()
        local addon = load_window()
        local farm = {
            id = "ggt:pet:discarded-experiment",
            sourceType = "curated",
            sourceDataset = "GGTPetFarmData",
            sourceCategory = "pets",
            activity = "pet",
            name = "Discarded Experiment",
            mapOptions = {
                {
                    id = "ggt:pet:discarded-experiment:boss",
                    mapID = 286,
                    mapLabel = "Blackwing Descent - Maloriak",
                    label = "Maloriak",
                    mapRole = "boss",
                    pins = { { x = 0.71, y = 0.70, label = "Maloriak - Discarded Experiment" } },
                },
                {
                    id = "ggt:pet:discarded-experiment:entrance",
                    mapID = 36,
                    mapLabel = "Burning Steppes",
                    label = "Blackwing Descent entrance",
                    mapRole = "entrance",
                    pins = { { x = 0.24, y = 0.27, label = "Blackwing Descent entrance" } },
                },
            },
        }

        local options = addon:BuildFarmDetailsMapOptions({ farm }, 2079)

        assert.equals(2, #options)
        assert.equals("Boss location", options[1].label)
        assert.equals("Instance entrance", options[2].label)
    end)

    it("calculates recorded value per hour and builds selected-material details", function()
        local addon = load_window()
        local farm = addon:GetFarmByID("catalog:gathering:mining:old-ore")
        local snapshot = addon:BuildFarmValuationSnapshot(farm)
        local total, hourly, priced, source = addon:GetFarmEstimatedValue(farm)
        local text = addon:BuildFarmDetailsText(farm, 3002)

        assert.equals(10, snapshot.targets[1].quantity)
        assert.equals(100, snapshot.targets[1].unitValue)
        assert.equals(1000, snapshot.targets[1].sampleValue)
        assert.equals(2, snapshot.targets[2].quantity)
        assert.equals(250, snapshot.targets[2].unitValue)
        assert.equals(500, snapshot.targets[2].sampleValue)
        assert.equals(2000, total)
        assert.equals(4000, hourly)
        assert.equals(2, priced)
        assert.equals("Test Value", source)
        assert.is_truthy(string.find(text, "Estimated value/hour: 4000c", 1, true))
        assert.is_truthy(string.find(text, "> New Herb x2 | Total value: 500c", 1, true))
        assert.is_truthy(string.find(text, "- Old Ore x10 | Total value: 1000c", 1, true))
        assert.is_truthy(string.find(text, "Mine ore nodes while following the route loop.", 1, true))
        assert.is_truthy(string.find(text, "bundled GGT farm catalog (test)", 1, true))
    end)

    it("can calculate only a farm summary without retaining item-row values", function()
        local addon = load_window()
        local farm = addon:GetFarmByID("catalog:gathering:mining:old-ore")
        local snapshot = addon:BuildFarmValuationSnapshot(farm, { includeTargets = false })

        assert.equals(2000, snapshot.totalValue)
        assert.equals(4000, snapshot.hourlyValue)
        assert.equals(2, snapshot.pricedTargets)
        assert.equals(0, #snapshot.targets)
    end)

    it("separates a dominant one-off gathering byproduct from the steady hourly estimate", function()
        local addon = load_window()
        addon.ResolveItemUnitValue = function(_, _, _, itemID)
            return ({ [3001] = 100, [3003] = 2000 })[itemID] or 0, nil, "Test Value"
        end
        local farm = {
            id = "rare-gem-route",
            sourceType = "gathering",
            activity = "mining",
            primaryItemID = 3001,
            recordedSeconds = 3600,
            targets = {
                { itemID = 3001, quantity = 10 },
                { itemID = 3003, quantity = 1 },
            },
        }

        local snapshot = addon:BuildFarmValuationSnapshot(farm)
        local _, estimatedHourly = addon:GetFarmEstimatedValue(farm, snapshot)
        local text = addon:BuildFarmDetailsText(farm, nil, snapshot)

        assert.equals(3000, snapshot.hourlyValue)
        assert.equals(1000, snapshot.estimatedHourlyValue)
        assert.equals(3003, snapshot.rareBonus.itemID)
        assert.equals(2000, snapshot.rareBonus.valuePerHour)
        assert.is_true(snapshot.targets[2].isRareBonus)
        assert.equals(1000, estimatedHourly)
        assert.is_truthy(string.find(text, "Estimated value/hour: 1000c", 1, true))
        assert.is_truthy(string.find(text, "Rare bonus: Rare Sword adds 2000c/hour", 1, true))
        assert.is_truthy(string.find(text, "Including rare bonus: 3000c/hour", 1, true))
    end)

    it("keeps primary targets and instance drops in the full hourly estimate", function()
        local addon = load_window()
        addon.ResolveItemUnitValue = function(_, _, _, itemID)
            return ({ [3001] = 2000, [3003] = 2000 })[itemID] or 0, nil, "Test Value"
        end
        local primaryFarm = {
            sourceType = "gathering",
            primaryItemID = 3001,
            recordedSeconds = 3600,
            targets = { { itemID = 3001, quantity = 1 }, { itemID = 3003, quantity = 2 } },
        }
        local instanceFarm = {
            sourceType = "drops",
            recordedSeconds = 3600,
            targets = { { itemID = 3001, quantity = 1 }, { itemID = 3003, quantity = 1 } },
        }

        local primarySnapshot = addon:BuildFarmValuationSnapshot(primaryFarm)
        local instanceSnapshot = addon:BuildFarmValuationSnapshot(instanceFarm)

        assert.is_nil(primarySnapshot.rareBonus)
        assert.equals(primarySnapshot.hourlyValue, primarySnapshot.estimatedHourlyValue)
        assert.is_nil(instanceSnapshot.rareBonus)
        assert.equals(instanceSnapshot.hourlyValue, instanceSnapshot.estimatedHourlyValue)
    end)

    it("ranks other priced Catalog instance drops by current unit value", function()
        local addon = load_window()
        local farm = addon:GetFarmByID("catalog:drops:transmogs:cloth-place")
        local suggestions, source = addon:GetFarmHighValueDropSuggestions(farm, { [3001] = true }, 2)

        assert.equals("Test Value", source)
        assert.equals(2, #suggestions)
        assert.equals(3003, suggestions[1].itemID)
        assert.equals(900, suggestions[1].unitValue)
        assert.equals(3002, suggestions[2].itemID)
        assert.equals(250, suggestions[2].unitValue)
        assert.equals(500, suggestions[2].sampleValue)
        assert.equals(0, #addon:GetFarmHighValueDropSuggestions(catalog.farms[1], {}, 5))
    end)

    it("summarizes the selected material's role, hourly value, share, and byproducts", function()
        local addon = load_window()
        local farm = addon:GetFarmByID("catalog:gathering:mining:old-ore")
        local summary = addon:GetFarmSelectedMaterialSummary(farm, 3002)
        local text = addon:BuildFarmSelectedMaterialSummaryText(farm, 3002)

        assert.equals(3002, summary.itemID)
        assert.equals(2, summary.quantity)
        assert.is_false(summary.isPrimary)
        assert.equals(500, summary.sampleValue)
        assert.equals(1000, summary.valuePerHour)
        assert.equals(2000, summary.totalSampleValue)
        assert.equals(25, summary.valueSharePercent)
        assert.equals(3001, summary.byproducts[1].itemID)
        assert.is_truthy(string.find(text, "New Herb  |  Byproduct", 1, true))
        assert.is_truthy(string.find(text, "Estimated: 1000c/hour", 1, true))
        assert.is_truthy(string.find(text, "Share of recorded farm value: 25.0%", 1, true))
        assert.is_truthy(string.find(text, "Important byproducts: Old Ore x10; 1000c", 1, true))
    end)

    it("builds compact farm context for the map details panel", function()
        local addon = load_window()
        local farm = addon:GetFarmByID("catalog:gathering:mining:old-ore")
        local lines
        loader.with_globals({
            C_Item = {
                GetItemInfo = function(itemID)
                    return ({ [3001] = "Old Ore", [3002] = "New Herb" })[itemID], "item:" .. tostring(itemID)
                end,
                RequestLoadItemDataByID = function() end,
            },
        }, function()
            lines = addon:BuildFarmMapDetailLines(farm, 3002, "Test Valley")
        end)
        local rendered = {}
        local selectedYield
        local otherYield
        local dividerIndex
        local farmEstimateIndex
        local selectedEstimateLine
        for index, line in ipairs(lines) do
            if line.type == "farmTarget" then
                if line.selected then
                    selectedYield = line
                else
                    otherYield = line
                end
            elseif line.type == "divider" then
                dividerIndex = index
            else
                rendered[#rendered + 1] = line.text or line.siteName
                if line.text == "Farm estimate" then
                    farmEstimateIndex = index
                elseif line.text == "1000c/hour" then
                    selectedEstimateLine = line
                end
            end
        end
        local text = table.concat(rendered, "\n")

        assert.is_truthy(string.find(text, "Test Valley", 1, true))
        assert.is_truthy(string.find(text, "New Herb estimate", 1, true))
        assert.is_table(selectedEstimateLine)
        assert.equals("GameFontNormalLarge", selectedEstimateLine.fontObject)
        assert.same({ 0.35, 0.95, 0.55 }, {
            selectedEstimateLine.r,
            selectedEstimateLine.g,
            selectedEstimateLine.b,
        })
        assert.equals(farmEstimateIndex - 1, dividerIndex)
        assert.is_truthy(string.find(text, "4000c/hour", 1, true))
        assert.is_truthy(string.find(text, "How to farm", 1, true))
        assert.equals("New Herb", selectedYield.itemName)
        assert.equals(3002, selectedYield.itemID)
        assert.equals("item:3002", selectedYield.itemLink)
        assert.equals("x2", selectedYield.quantityText)
        assert.equals("500c", selectedYield.totalValueText)
        assert.is_true(selectedYield.selected)
        assert.equals("Old Ore", otherYield.itemName)
        assert.equals("x10", otherYield.quantityText)
        assert.equals("1000c", otherYield.totalValueText)
        assert.is_false(otherYield.selected)
        assert.is_truthy(string.find(text, "Farm catalog source", 1, true))
    end)

    it("builds an expandable recorded-yields list for the map details panel", function()
        local addon = load_window()
        local farm = {
            id = "many-yields",
            activity = "miscellaneous",
            expansion = "classic",
            recordedSeconds = 3600,
            mapNames = { "Test Valley" },
            targets = {},
        }
        for itemID = 3001, 3010 do
            farm.targets[#farm.targets + 1] = { itemID = itemID, quantity = 1 }
        end
        local valuation = addon:BuildFarmValuationSnapshot(farm)
        local toggled = false
        local collapsed = addon:BuildFarmMapDetailLines(farm, nil, "Test Valley", valuation, {
            onToggleTargets = function()
                toggled = true
            end,
        })

        local collapsedTargets = 0
        local collapsedToggle
        for _, line in ipairs(collapsed) do
            if line.type == "farmTarget" then
                collapsedTargets = collapsedTargets + 1
            elseif line.type == "detailToggle" then
                collapsedToggle = line
            end
        end
        assert.equals(8, collapsedTargets)
        assert.equals("+ 2 more recorded items", collapsedToggle.text)
        collapsedToggle.onClick()
        assert.is_true(toggled)

        local expanded = addon:BuildFarmMapDetailLines(farm, nil, "Test Valley", valuation, {
            showAllTargets = true,
        })
        local expandedTargets = 0
        local expandedToggle
        for _, line in ipairs(expanded) do
            if line.type == "farmTarget" then
                expandedTargets = expandedTargets + 1
            elseif line.type == "detailToggle" then
                expandedToggle = line
            end
        end
        assert.equals(10, expandedTargets)
        assert.equals("- Show fewer recorded items", expandedToggle.text)
        assert.is_true(expandedToggle.expanded)
    end)

    it("reuses one valuation pass while building farm map details", function()
        local addon = load_window()
        local farm = addon:GetFarmByID("catalog:gathering:mining:old-ore")
        local resolve_count = 0
        local original_resolver = addon.ResolveItemUnitValue
        addon.ResolveItemUnitValue = function(...)
            resolve_count = resolve_count + 1
            return original_resolver(...)
        end

        addon:BuildFarmMapDetailLines(farm, 3002, "Test Valley")

        assert.equals(#farm.targets, resolve_count)
    end)

    it("requests missing farm item data once until its load event completes", function()
        local addon = load_window()
        local farm = addon:GetFarmByID("catalog:gathering:mining:old-ore")
        local valuation = addon:BuildFarmValuationSnapshot(farm)
        local requested = {}

        loader.with_globals({
            C_Item = {
                GetItemInfo = function() return nil end,
                RequestLoadItemDataByID = function(itemID)
                    requested[#requested + 1] = itemID
                end,
            },
            C_Timer = false,
        }, function()
            addon:BuildFarmMapDetailLines(farm, 3002, "Test Valley", valuation)
            addon:BuildFarmMapDetailLines(farm, 3002, "Test Valley", valuation)

            assert.equals(2, #requested)
            assert.is_true(addon:IsFarmItemDataRequest(3001))
            assert.is_true(addon:IsFarmItemDataRequest(3002))
            assert.is_true(addon:CompleteFarmItemDataRequest(3001))
            assert.is_false(addon:IsFarmItemDataRequest(3001))
        end)
    end)

    it("opens routed farm details directly in the standalone map", function()
        local addon = load_window()
        local captured
        addon.OpenStandaloneMapWindow = function(_, options)
            captured = options
        end

        assert.is_true(addon:OpenFarmDetailsForItem(3001))
        assert.is_table(captured)
        assert.equals("Old Ore Route", captured.title)
        assert.equals("farm-item:3001", captured.projectionKey)
        assert.equals(2, #captured.mapOptions)
        assert.equals(1, captured.selectedMapOptionIndex)
        assert.is_nil(captured.farmOptionNotice)
        assert.is_function(captured.detailLinesBuilder)

        local lines = captured.detailLinesBuilder(captured.mapOptions[1], 42, "Test Valley")
        assert.is_table(lines)
        assert.equals("Test Valley", lines[1].text)

        captured = nil
        assert.is_true(addon:OpenFarmDetails("catalog:gathering:mining:old-ore"))
        assert.is_nil(captured.farmOptionNotice)
    end)

    it("exposes catalog-aware tooltip and alt-click Farm actions", function()
        local addon = load_window()
        local tooltipLines = {}
        local tooltip = {
            AddLine = function(_, text)
                tooltipLines[#tooltipLines + 1] = text
            end,
        }
        local openedItemID
        addon.OpenFarmDetailsForItem = function(_, itemID)
            openedItemID = itemID
            return true
        end

        assert.same({ true, 3 }, { addon:HasFarmForItem(3001) })
        assert.same({ false, 0 }, { addon:HasFarmForItem(9999) })
        assert.is_true(addon:AddFarmActionTooltip(tooltip, { itemID = 3001 }))
        assert.is_truthy(string.find(tooltipLines[2], "Alt-click: Open Farm map (3 matches)", 1, true))
        loader.with_globals({
            IsAltKeyDown = function() return true end,
        }, function()
            assert.is_true(addon:HandleFarmActionClick({ itemID = 3001 }, "LeftButton"))
        end)
        assert.equals(3001, openedItemID)
    end)
end)

describe("UI/MyFarmsWindow farm catalog list", function()
    local function load_my_farms_window(catalogOverride)
        return loader.load_module("UI/MyFarmsWindow.lua", {}, {
            FarmCatalog = catalogOverride or catalog,
            JanisTheme = {},
        })
    end

    it("uses Gathering as the default Catalog Farms category", function()
        local addon = load_my_farms_window()
        local farms = addon:GetFarmCatalogEntries()

        assert.equals(2, #farms)
        assert.equals("Old Ore Route", farms[1].name)
        assert.equals("Shared Route", farms[2].name)
    end)

    it("filters Instances into Transmog and Noteworthy Items", function()
        local addon = load_my_farms_window()

        local transmogs = addon:GetFarmCatalogEntries(nil, "instances", "transmog")
        local noteworthy = addon:GetFarmCatalogEntries(nil, "instances", "noteworthyItems")

        assert.equals(1, #transmogs)
        assert.equals("Cloth Place", transmogs[1].name)
        assert.equals(1, #noteworthy)
        assert.equals("Noteworthy Place", noteworthy[1].name)
        assert.equals(2, #addon:GetFarmCatalogEntries(nil, "instances"))
    end)

    it("filters Gathering farms by the selected Catalog type", function()
        local addon = load_my_farms_window()

        assert.equals(1, #addon:GetFarmCatalogEntries(nil, "gathering", "Mining"))
        assert.equals("Old Ore Route", addon:GetFarmCatalogEntries(nil, "gathering", "Mining")[1].name)
        assert.equals(1, #addon:GetFarmCatalogEntries(nil, "gathering", "MultiFarms"))
        assert.equals("Shared Route", addon:GetFarmCatalogEntries(nil, "gathering", "MultiFarms")[1].name)
        assert.equals(0, #addon:GetFarmCatalogEntries(nil, "gathering", "Fishing"))
    end)

    it("filters farms by expansion and replaces placeholder map labels", function()
        local customCatalog = {
            farms = {
                { id = "classic", sourceType = "gathering", sourceCategory = "Mining", name = "Classic Farm",
                    expansion = "classic", mapIDs = { 42 }, mapNames = { "Map 42" },
                    mapOptions = { { mapID = 42, mapLabel = "Test Valley" } } },
                { id = "outland", sourceType = "gathering", sourceCategory = "Mining", name = "Outland Farm",
                    expansion = "burningCrusade", mapIDs = { 100 }, mapNames = { "Hellfire Peninsula" } },
            },
            byID = { classic = 1, outland = 2 },
        }
        local addon = load_my_farms_window(customCatalog)

        assert.equals(2, #addon:GetFarmCatalogEntries(nil, "gathering", "Mining", "all"))
        assert.equals("Classic Farm", addon:GetFarmCatalogEntries(nil, "gathering", "Mining", "classic")[1].name)
        assert.equals("Test Valley", addon:GetFarmCatalogLocationGroupLabel(customCatalog.farms[1]))
        assert.same({
            { id = "all", label = "All expansions" },
            { id = "classic", label = "Classic" },
            { id = "burningcrusade", label = "The Burning Crusade" },
        }, addon:GetFarmCatalogExpansionOptions())
    end)

    it("refreshes only the selected type while retaining other cached farm values", function()
        local addon = load_my_farms_window()
        local valuedFarmIDs = {}
        addon.BuildFarmValuationSnapshot = function(_, farm, options)
            valuedFarmIDs[#valuedFarmIDs + 1] = farm.id
            return {
                totalValue = 1,
                hourlyValue = 1,
                pricedTargets = 1,
                targets = options.includeTargets and { { itemID = 3001 } } or {},
            }
        end
        addon.farmCatalogCategoryID = "gathering"
        addon.farmCatalogSubcategoryID = "Mining"

        loader.with_globals({ C_Timer = false }, function()
            addon:RefreshFarmCatalogValues()
        end)

        assert.same({ "catalog:gathering:mining:old-ore" }, valuedFarmIDs)
        assert.equals(1, addon.farmCatalogViewTotal)
        assert.is_table(addon.farmCatalogViewSnapshots["catalog:gathering:mining:old-ore"])
        assert.is_nil(addon.farmCatalogViewSnapshots["catalog:gathering:multi:shared-route"])
        assert.is_nil(addon.farmCatalogViewSnapshots["catalog:drops:transmogs:cloth-place"])

        valuedFarmIDs = {}
        addon.farmCatalogCategoryID = "instances"
        addon.farmCatalogSubcategoryID = "transmog"
        loader.with_globals({ C_Timer = false }, function()
            addon:RefreshFarmCatalogValues()
        end)

        assert.same({ "catalog:drops:transmogs:cloth-place" }, valuedFarmIDs)
        assert.equals(1, addon.farmCatalogViewTotal)
        assert.is_table(addon.farmCatalogViewSnapshots["catalog:gathering:mining:old-ore"])
        assert.is_table(addon.farmCatalogViewSnapshots["catalog:drops:transmogs:cloth-place"])
    end)

    it("does not recalculate cached values during a normal catalog redraw", function()
        local addon = load_my_farms_window()
        local valuationPasses = 0
        addon.BuildFarmValuationSnapshot = function()
            valuationPasses = valuationPasses + 1
            return { totalValue = 1, hourlyValue = 1, pricedTargets = 1 }
        end

        addon:RefreshFarmCatalogWindow(true)

        assert.equals(0, valuationPasses)
    end)

    it("uses the saved per-farm value cache after a reload", function()
        local addon = load_my_farms_window()
        local savedSnapshot = { totalValue = 12345, hourlyValue = 24690, pricedTargets = 1 }
        addon.db = {
            farmCatalogValueCache = {
                ["catalog:gathering:mining:old-ore"] = savedSnapshot,
            },
        }
        addon.farmCatalogCategoryID = "gathering"
        addon.farmCatalogSubcategoryID = "Mining"

        assert.is_true(addon:IsFarmCatalogValuationCurrent())
        assert.equals(savedSnapshot, addon.farmCatalogViewSnapshots["catalog:gathering:mining:old-ore"])
    end)

    it("groups catalog farms by their primary mapped location", function()
        local addon = load_my_farms_window()
        local farms = addon:GetFarmCatalogEntries(nil, "gathering")
        table.sort(farms, function(left, right)
            return addon:GetFarmCatalogLocationGroupLabel(left)
                < addon:GetFarmCatalogLocationGroupLabel(right)
        end)
        local groups = addon:BuildLocationGroupedDisplayRows(
            farms,
            function(farm) return addon:GetFarmCatalogLocationGroupLabel(farm) end,
            { ["other valley"] = false, ["test valley"] = false },
            true
        )

        assert.is_true(groups[1].isLocationGroupHeader)
        assert.equals("Other Valley", groups[1].locationGroupLabel)
        assert.equals("Shared Route", groups[2].name)
        assert.is_true(groups[3].isLocationGroupHeader)
        assert.equals("Test Valley", groups[3].locationGroupLabel)
    end)

    it("recalculates item-row values every time a farm is expanded", function()
        local addon = load_my_farms_window()
        local passes = {}
        addon.BuildFarmValuationSnapshot = function(_, farm, options)
            passes[#passes + 1] = {
                farmID = farm.id,
                includeTargets = options.includeTargets,
            }
            return {
                totalValue = 1,
                hourlyValue = 1,
                pricedTargets = 1,
                targets = options.includeTargets and { { itemID = 3001 } } or {},
            }
        end
        addon.farmCatalogCategoryID = "gathering"
        addon.farmCatalogSubcategoryID = "Mining"

        loader.with_globals({ C_Timer = false }, function()
            addon:RefreshFarmCatalogValues()
        end)
        assert.is_false(passes[1].includeTargets)

        addon:ToggleFarmCatalogExpanded("catalog:gathering:mining:old-ore")
        assert.is_true(passes[2].includeTargets)
        assert.equals(1, #addon.farmCatalogViewSnapshots["catalog:gathering:mining:old-ore"].targets)

        addon:ToggleFarmCatalogExpanded("catalog:gathering:mining:old-ore")
        assert.is_nil(addon.farmCatalogViewSnapshots["catalog:gathering:mining:old-ore"].targets)

        addon:ToggleFarmCatalogExpanded("catalog:gathering:mining:old-ore")
        assert.is_true(passes[3].includeTargets)
        assert.equals(1, #addon.farmCatalogViewSnapshots["catalog:gathering:mining:old-ore"].targets)
    end)

    it("searches Gathering farm names, source paths, activities, expansions, and locations", function()
        local addon = load_my_farms_window()

        assert.equals(0, #addon:GetFarmCatalogEntries("old dungeon"))
        assert.equals("Shared Route", addon:GetFarmCatalogEntries("multi-farm")[1].name)
        assert.equals(2, #addon:GetFarmCatalogEntries("classic"))
        assert.equals(0, #addon:GetFarmCatalogEntries("not a real farm"))
    end)

    it("offers the requested Catalog Gathering and Instances navigation order", function()
        local addon = load_my_farms_window()
        local categories = addon:GetFarmCatalogCategoryDefinitions()
        local subcategories = addon:GetFarmCatalogSubcategoryDefinitions("gathering")
        local instanceSubcategories = addon:GetFarmCatalogSubcategoryDefinitions("instances")

        assert.equals(2, #categories)
        assert.equals("Gathering", categories[1].label)
        assert.equals("Instances", categories[2].label)
        assert.same(
            { "Mining", "Herb", "Fishing", "Skinning", "Cloth", "Misc", "Multi Farms" },
            (function()
                local labels = {}
                for _, option in ipairs(subcategories) do
                    labels[#labels + 1] = option.label
                end
                return labels
            end)()
        )
        assert.same(
            { "Transmog", "Noteworthy Items" },
            (function()
                local labels = {}
                for _, option in ipairs(instanceSubcategories) do
                    labels[#labels + 1] = option.label
                end
                return labels
            end)()
        )
    end)
end)
