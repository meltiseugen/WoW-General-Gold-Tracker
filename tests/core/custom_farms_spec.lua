local loader = require("tests.helpers.addon_loader")

local function load_custom_farms(saved_db, globals, ns_overrides)
    local addon = {
        db = saved_db or {},
        messages = {},
        Print = function(self, message)
            self.messages[#self.messages + 1] = message
        end,
    }
    local values = {
        time = function()
            return 123456
        end,
        UnitFullName = function()
            return "Goldie", "Silvermoon"
        end,
        GetRealmName = function()
            return "Silvermoon"
        end,
    }
    for key, value in pairs(globals or {}) do
        values[key] = value
    end
    loader.with_globals(values, function()
        addon = loader.load_module("Core/CustomFarms.lua", addon, ns_overrides)
    end)
    return addon
end

describe("Core/CustomFarms", function()
    local function map_option(id, mapID, sourceType)
        return {
            id = id, mapID = mapID, sourceType = sourceType or "static", label = id or "User map",
            pins = { { mapID = mapID, x = 0.4, y = 0.6, sourceType = sourceType or "static" } },
        }
    end

    it("offers both static maps and user discoveries even without a catalog farm", function()
        local addon = load_custom_farms({})
        local options = { map_option("throne", 100), map_option("fel-pits", 104), map_option(nil, 100, "user") }
        addon.BuildMaterialFarmingMapOptions = function(_, itemID)
            assert.equals(22574, itemID)
            return options
        end
        local payload
        addon.ShowCustomFarmMethodDialog = function(_, data) payload = data; return true end
        assert.is_true(addon:RequestAddToCustomFarm({ itemID = 22574 }, "materials"))
        assert.equals(0, #payload.farms)
        assert.equals(options, payload.mapOptions)
        assert.equals(0, #addon:GetCustomFarms())
    end)

    it("persists distinct map sources and rejects adding the same source twice", function()
        local addon = load_custom_farms({})
        local farm = addon:CreateCustomFarm("Fire", true)
        local entry = addon:BuildCustomFarmEntry({ itemID = 22574, mapID = 1 }, "materials")
        local first = map_option("throne", 100)
        for _, option in ipairs({ first, map_option("fel-pits", 104), map_option(nil, 100, "user") }) do
            assert.is_true(addon:CommitCustomFarmEntry({ farmID = farm.id, entry = entry }, nil, option))
        end
        local added, reason = addon:CommitCustomFarmEntry({ farmID = farm.id, entry = entry }, nil, first)
        assert.is_false(added)
        assert.equals("duplicate", reason)
        first.pins[1].x = 0.9
        local reloaded = load_custom_farms(addon.db)
        local entries = reloaded:GetCustomFarmByID(farm.id).entries
        assert.equals(3, #entries)
        assert.equals(0.4, entries[1].mapSource.pins[1].x)
        assert.equals("user", entries[3].mapSource.sourceType)
        assert.equals(104, entries[2].mapSource.mapID)
        assert.is_nil(entries[1].catalogFarmID)
    end)

    it("reopens current discovery data and falls back to the saved map when unavailable", function()
        local addon = load_custom_farms({})
        local entry = addon:LinkCustomFarmEntryToMapSource(
            addon:BuildCustomFarmEntry({ itemID = 22574 }, "materials"), map_option(nil, 100, "user"))
        local current = map_option(nil, 100, "user")
        current.pins[2] = { mapID = 100, x = 0.5, y = 0.7 }
        addon.BuildMaterialFarmingMapOptions = function() return { current } end
        local opened
        addon.OpenStandaloneMapWindow = function(_, options) opened = options end
        assert.is_true(addon:OpenCustomFarmEntryMap(entry))
        assert.equals(current, opened.mapOptions[1])
        assert.equals(2, #opened.mapOptions[1].pins)
        addon.BuildMaterialFarmingMapOptions = function() return {} end
        assert.is_true(addon:OpenCustomFarmEntryMap(entry))
        assert.equals(1, #opened.mapOptions[1].pins)
    end)

    it("switches farm data to map data to item only without keeping stale methods", function()
        local catalog = { id = "fire", name = "Fire" }
        local addon = load_custom_farms({}, nil, { FarmCatalog = { farms = { catalog }, byID = { fire = 1 } } })
        local farm = addon:CreateCustomFarm("Fire", true)
        local entry = addon:BuildCustomFarmEntry({ itemID = 22574, mapID = 1, x = 0.2, y = 0.3 }, "materials")
        assert.is_true(addon:CommitCustomFarmEntry({ farmID = farm.id, entry = entry }, "fire"))
        local entryID = farm.entries[1].id
        assert.is_true(addon:SetCustomFarmEntryMethod(farm.id, entryID, nil, map_option("throne", 100)))
        assert.is_nil(farm.entries[1].catalogFarmID)
        assert.equals(100, farm.entries[1].mapSource.mapID)
        assert.is_true(addon:SetCustomFarmEntryMethod(farm.id, entryID, "fire"))
        assert.is_nil(farm.entries[1].mapSource)
        assert.equals("fire", farm.entries[1].catalogFarmID)
        assert.is_true(addon:SetCustomFarmEntryMethod(farm.id, entryID))
        assert.is_nil(farm.entries[1].catalogFarmID)
        assert.equals(entry.entryKey, farm.entries[1].entryKey)
        assert.equals(1, farm.entries[1].mapID)
        assert.equals(0.2, farm.entries[1].x)
    end)

    it("rejects conflicting map edits and invalid maps without altering a farm", function()
        local addon = load_custom_farms({})
        local entry = addon:BuildCustomFarmEntry({ itemID = 22574 }, "materials")
        assert.is_false(addon:CommitCustomFarmEntry({ entry = entry }, nil, { mapID = 100, pins = {} }))
        assert.equals(0, #addon:GetCustomFarms())
        local farm = addon:CreateCustomFarm("Fire", true)
        assert.is_true(addon:CommitCustomFarmEntry({ farmID = farm.id, entry = entry }, nil, map_option("one", 100)))
        assert.is_true(addon:CommitCustomFarmEntry({ farmID = farm.id, entry = entry }, nil, map_option("two", 100)))
        local saved = farm.entries[2]
        local changed, reason = addon:SetCustomFarmEntryMethod(farm.id, saved.id, nil, map_option("one", 100))
        assert.is_false(changed)
        assert.equals("duplicate", reason)
        assert.equals(saved, farm.entries[2])
    end)

    it("migrates existing item-only farms without losing entries", function()
        local addon = load_custom_farms({
            customFarms = {
                schemaVersion = 1,
                nextID = 2,
                farms = {
                    {
                        id = 1,
                        name = "Existing",
                        entries = {
                            { id = 1, itemID = 2589, itemName = "Linen Cloth", sourceType = "materials" },
                        },
                    },
                },
            },
        })

        local store = addon:GetCustomFarmStore()
        assert.equals(4, store.schemaVersion)
        assert.equals(1, #store.farms)
        assert.equals(1, #store.farms[1].entries)
        assert.equals(2589, store.farms[1].entries[1].itemID)
        assert.is_nil(store.farms[1].entries[1].catalogFarmID)
    end)

    it("saves farms immediately and treats finish build as an active-state change only", function()
        local addon = load_custom_farms({})
        local farm = addon:CreateCustomFarm("Old World Tour", false)

        assert.equals(1, farm.id)
        assert.equals("Old World Tour", addon.db.customFarms.farms[1].name)
        assert.is_nil(addon:GetActiveCustomFarm())

        assert.is_true(addon:SetActiveCustomFarm(farm.id))
        assert.equals(farm, addon:GetActiveCustomFarm())
        assert.is_true(addon:FinishCustomFarmBuild(farm.id))
        assert.is_nil(addon:GetActiveCustomFarm())
        assert.equals(farm, addon:GetCustomFarmByID(farm.id))
    end)

    it("adds normalized entries once and persists one character assignment", function()
        local addon = load_custom_farms({})
        local farm = addon:CreateCustomFarm("Materials", true)
        local entry = addon:BuildCustomFarmEntry({
            itemID = 2770,
            itemName = "Copper Ore",
            itemLink = "item:2770",
            locationLabel = "Durotar",
            mapID = 1,
        }, "materials")

        assert.is_true(addon:AddEntryToCustomFarm(farm.id, entry))
        local addedAgain, reason = addon:AddEntryToCustomFarm(farm.id, entry)
        assert.is_false(addedAgain)
        assert.equals("duplicate", reason)
        assert.equals(1, #farm.entries)
        assert.equals("Materials", farm.entries[1].sourceLabel)

        loader.with_globals({ UnitFullName = function() return "Goldie", "Silvermoon" end }, function()
            assert.equals("Goldie-Silvermoon", addon:RegisterCurrentCustomFarmCharacter())
        end)
        assert.is_true(addon:SetCustomFarmAssignedCharacter(farm.id, "Goldie-Silvermoon"))
        assert.equals("Goldie-Silvermoon", farm.assignedCharacter)
        assert.is_true(addon:SetCustomFarmAssignedCharacter(farm.id, "Miner-Silvermoon"))
        assert.equals("Miner-Silvermoon", farm.assignedCharacter)
        assert.is_true(addon:SetCustomFarmAssignedCharacter(farm.id, nil))
        assert.is_nil(farm.assignedCharacter)
    end)

    it("migrates old multi-character assignments to one deterministic character", function()
        local addon = load_custom_farms({
            customFarms = {
                schemaVersion = 2,
                farms = {
                    {
                        id = 1,
                        name = "Legacy Farm",
                        assignedCharacters = { "Zulu-Silvermoon", "Alpha-Silvermoon" },
                        entries = {},
                    },
                },
            },
        })

        local store = addon:GetCustomFarmStore()
        assert.equals(4, store.schemaVersion)
        assert.equals("Alpha-Silvermoon", store.farms[1].assignedCharacter)
        assert.is_nil(store.farms[1].assignedCharacters)
        assert.is_true(store.knownCharacters["Alpha-Silvermoon"])
        assert.is_true(store.knownCharacters["Zulu-Silvermoon"])
    end)

    it("groups several selected targets under one catalog farm step", function()
        local catalogFarm = {
            id = "wit:gathering:mining:copperore",
            name = "Copper Ore",
            sourcePath = "Gathering > Mining",
            activity = "mining",
            mapIDs = { 1 },
            mapNames = { "Durotar" },
            routeCount = 1,
            targets = {
                { itemID = 2770, quantity = 540 },
                { itemID = 2835, quantity = 504 },
            },
        }
        local addon = load_custom_farms({}, nil, {
            FarmCatalog = {
                farms = { catalogFarm },
                byID = { [catalogFarm.id] = 1 },
            },
        })
        local farm = addon:CreateCustomFarm("Mining", true)
        local copper = addon:LinkCustomFarmEntryToCatalogFarm(
            addon:BuildCustomFarmEntry({ itemID = 2770, itemName = "Copper Ore" }, "materials"),
            catalogFarm.id
        )
        local stone = addon:LinkCustomFarmEntryToCatalogFarm(
            addon:BuildCustomFarmEntry({ itemID = 2835, itemName = "Rough Stone" }, "materials"),
            catalogFarm.id
        )

        assert.is_true(addon:AddEntryToCustomFarm(farm.id, copper))
        assert.is_true(addon:AddEntryToCustomFarm(farm.id, stone))
        local steps = addon:GetCustomFarmSteps(farm)

        assert.equals(1, #steps)
        assert.equals(catalogFarm.id, steps[1].catalogFarmID)
        assert.equals("Durotar", steps[1].mapNames[1])
        assert.equals(2, #steps[1].entries)
    end)

    it("keeps catalog farms and standalone targets as separate ordered steps", function()
        local catalogFarm = {
            id = "wit:drops:instances:deadmines",
            name = "The Deadmines",
            sourcePath = "Instances",
            mapIDs = { 291 },
            mapNames = { "The Deadmines" },
            routeCount = 0,
            targets = { { itemID = 100, quantity = 1 } },
        }
        local addon = load_custom_farms({}, nil, {
            FarmCatalog = {
                farms = { catalogFarm },
                byID = { [catalogFarm.id] = 1 },
            },
        })
        local farm = addon:CreateCustomFarm("Mixed", true)
        local material = addon:BuildCustomFarmEntry({ itemID = 200, itemName = "Cloth" }, "materials")
        local instance = addon:LinkCustomFarmEntryToCatalogFarm(
            addon:BuildCustomFarmEntry({ itemID = 100, itemName = "Sword" }, "instances"),
            catalogFarm.id
        )

        assert.is_true(addon:AddEntryToCustomFarm(farm.id, material))
        assert.is_true(addon:AddEntryToCustomFarm(farm.id, instance))
        local steps = addon:GetCustomFarmSteps(farm)

        assert.equals(2, #steps)
        assert.is_nil(steps[1].catalogFarmID)
        assert.equals(catalogFarm.id, steps[2].catalogFarmID)
    end)

    it("can change and unlink a target farming method without removing the target", function()
        local farms = {
            {
                id = "wit:gathering:mining:copper-a",
                name = "Copper A",
                mapNames = { "Durotar" },
                targets = { { itemID = 2770, quantity = 100 } },
            },
            {
                id = "wit:gathering:mining:copper-b",
                name = "Copper B",
                mapNames = { "Elwynn Forest" },
                targets = { { itemID = 2770, quantity = 90 } },
            },
        }
        local addon = load_custom_farms({}, nil, {
            FarmCatalog = {
                farms = farms,
                byID = { [farms[1].id] = 1, [farms[2].id] = 2 },
            },
        })
        local farm = addon:CreateCustomFarm("Copper", true)
        local entry = addon:LinkCustomFarmEntryToCatalogFarm(
            addon:BuildCustomFarmEntry({ itemID = 2770, itemName = "Copper Ore" }, "materials"),
            farms[1].id
        )
        assert.is_true(addon:AddEntryToCustomFarm(farm.id, entry))

        assert.is_true(addon:SetCustomFarmEntryCatalogFarm(farm.id, farm.entries[1].id, farms[2].id))
        assert.equals(farms[2].id, farm.entries[1].catalogFarmID)
        assert.equals("Elwynn Forest", farm.entries[1].catalogMapNames[1])

        assert.is_true(addon:SetCustomFarmEntryCatalogFarm(farm.id, farm.entries[1].id, nil))
        assert.is_nil(farm.entries[1].catalogFarmID)
        assert.equals(1, #farm.entries)
    end)

    it("removes one selected target and drops an empty grouped step", function()
        local catalogFarm = {
            id = "wit:gathering:mining:copperore",
            name = "Copper Ore",
            mapNames = { "Durotar" },
            targets = {
                { itemID = 2770, quantity = 540 },
                { itemID = 2835, quantity = 504 },
            },
        }
        local addon = load_custom_farms({}, nil, {
            FarmCatalog = {
                farms = { catalogFarm },
                byID = { [catalogFarm.id] = 1 },
            },
        })
        local farm = addon:CreateCustomFarm("Mining", true)
        for _, item in ipairs({ { 2770, "Copper Ore" }, { 2835, "Rough Stone" } }) do
            local entry = addon:LinkCustomFarmEntryToCatalogFarm(
                addon:BuildCustomFarmEntry({ itemID = item[1], itemName = item[2] }, "materials"),
                catalogFarm.id
            )
            assert.is_true(addon:AddEntryToCustomFarm(farm.id, entry))
        end

        assert.is_true(addon:RemoveEntryFromCustomFarm(farm.id, farm.entries[1].id))
        assert.equals(1, #farm.entries)
        assert.equals(1, #addon:GetCustomFarmSteps(farm))
        assert.is_true(addon:RemoveEntryFromCustomFarm(farm.id, farm.entries[1].id))
        assert.equals(0, #farm.entries)
        assert.equals(0, #addon:GetCustomFarmSteps(farm))
    end)

    it("asks before adding to the active farm", function()
        local popup
        local dialogs = {}
        local addon = load_custom_farms({}, {
            StaticPopupDialogs = dialogs,
            StaticPopup_Show = function(key, text1, text2, data)
                popup = { key = key, text1 = text1, text2 = text2, data = data }
            end,
        })
        local farm = addon:CreateCustomFarm("Dungeon Run", true)

        loader.with_globals({
            StaticPopupDialogs = dialogs,
            StaticPopup_Show = function(key, text1, text2, data)
                popup = { key = key, text1 = text1, text2 = text2, data = data }
            end,
        }, function()
            assert.is_true(addon:RequestAddToCustomFarm({ itemID = 100, itemName = "Sword" }, "instances"))
            assert.equals(addon.CUSTOM_FARM_CONFIRM_ADD_DIALOG_KEY, popup.key)
            assert.equals("Dungeon Run", popup.text2)
            dialogs[popup.key].OnAccept({ data = popup.data })
        end)

        assert.equals(1, #farm.entries)
    end)

    it("opens the farming-method chooser when catalog farms match the target", function()
        local addon = load_custom_farms({})
        local farm = addon:CreateCustomFarm("Mining", true)
        local shownPayload
        addon.GetFarmsForItem = function()
            return { { id = "wit:gathering:mining:copperore", name = "Copper Ore" } }
        end
        addon.ShowCustomFarmMethodDialog = function(_, payload)
            shownPayload = payload
            return true
        end

        assert.is_true(addon:RequestAddToCustomFarm({ itemID = 2770, itemName = "Copper Ore" }, "materials"))
        assert.equals(farm.id, shownPayload.farmID)
        assert.equals(2770, shownPayload.entry.itemID)
        assert.equals("wit:gathering:mining:copperore", shownPayload.farms[1].id)
        assert.equals(0, #farm.entries)
    end)

    it("offers to create and activate a farm when none is being built", function()
        local popup
        local dialogs = {}
        local addon = load_custom_farms({}, {
            StaticPopupDialogs = dialogs,
            StaticPopup_Show = function(key, text1, text2, data)
                popup = { key = key, text1 = text1, text2 = text2, data = data }
            end,
        })

        loader.with_globals({
            StaticPopupDialogs = dialogs,
            StaticPopup_Show = function(key, text1, text2, data)
                popup = { key = key, text1 = text1, text2 = text2, data = data }
            end,
        }, function()
            assert.is_true(addon:RequestAddToCustomFarm({ itemID = 200, itemName = "Cloth" }, "drops"))
            assert.equals(addon.CUSTOM_FARM_CREATE_AND_ADD_DIALOG_KEY, popup.key)
            dialogs[popup.key].OnAccept({ data = popup.data })
        end)

        local activeFarm = addon:GetActiveCustomFarm()
        assert.is_table(activeFarm)
        assert.equals("New Farm 1", activeFarm.name)
        assert.equals(1, #activeFarm.entries)
    end)
end)
