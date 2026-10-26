local loader = require("tests.helpers.addon_loader")
local encoding = require("tests.helpers.farm_encoding")

local function addon(db, catalog, gathering)
    local result = { db = db or {} }
    local ns = { GoldTracker = result, FarmCatalog = catalog or { farms = {}, byID = {} },
        CatalogGatheringData = gathering or { farmsByRecordID = {} }, JanisTheme = {} }
    for _, path in ipairs({ "Core/CustomFarms.lua", "Core/FarmTransfer.lua", "Core/FarmRoutePlanner.lua", "UI/FarmDetailsWindow.lua" }) do
        assert(loadfile(path))("General-Gold-Tracker", ns)
    end
    return result, ns
end

local function with_codec(callback)
    loader.with_globals({ C_EncodingUtil = encoding.codec, time = function() return 100 end }, callback)
end

local function source()
    local catalog = { id = "catalog:skins", name = "Skins", activity = "skinning", sourceDataset = "CatalogGatheringData",
        sourceRecordIDs = { "skins" }, mapIDs = { 100 }, mapNames = { "Zone" }, targets = { { itemID = 2318, quantity = 7 } },
        description = "Full catalog metadata" }
    local record = { extra = { true, false }, routes = { { mapID = 100, name = "Loop", coords = {
        { x = 0.123456789012345, y = 0.25 }, { x = 0.8, y = 0.9 },
    } } } }
    local result = addon(nil, { farms = { catalog }, byID = { [catalog.id] = 1 } }, { farmsByRecordID = { skins = record } })
    result.BuildFarmRouteMapOptions = function()
        return { { id = "skin-route", mapID = 100, label = "Skin loop", pins = {
            { mapID = 100, x = 0.123456789012345, y = 0.25, isRoute = true, routeID = "skin-route", tips = { "Tip" }, sourceUrls = { "https://example.test/source" } },
            { mapID = 100, x = 0.8, y = 0.9, isRoute = true, routeID = "skin-route" },
        } } }
    end
    local farm = result:CreateCustomFarm("Caf\195\169 farm | Test", false)
    result:AddEntryToCustomFarm(farm.id, { itemID = 2770, itemName = "Ore", entryKey = "ore", mapSource = {
        id = "ore-loop", mapID = 100, label = "Ore loop", sourceType = "user", custom = { [2] = false, name = "kept" },
        pins = { { mapID = 100, x = 0, y = 1, isRoute = true, routeID = "ore-loop", nested = { empty = {}, [9] = "value" },
            tips = { "Second", "First" }, sourceUrls = { "https://example.test/a", "https://example.test/b" } } },
    }, extra = { false, { precision = 0.123456789012345 } } })
    result:AddEntryToCustomFarm(farm.id, { itemID = 2318, itemName = "Leather", entryKey = "skins", catalogFarmID = catalog.id })
    farm.routePlan = { order = { "catalog:catalog:skins", "item:1" }, locked = { ["catalog:catalog:skins"] = true },
        locationOverrides = { ["catalog:catalog:skins"] = "route:skins:1:100" }, guidance = { breadcrumbs = false, areaIndicator = true },
        runs = { ["Hero-Realm"] = { startedAt = 10, completed = { ["item:1"] = true }, currentStepKey = "catalog:catalog:skins" } } }
    farm.extra = { [42] = "number key", ["42"] = "string key", [false] = "boolean key", empty = {} }
    farm.assignedCharacter = "Hero-Realm"
    local store = result:GetCustomFarmStore()
    store.activeBuildFarmID, store.activeRouteFarmIDs["Hero-Realm"] = farm.id, farm.id
    result.db.sessionHistory = {
        { id = 9, farmID = farm.id, recordType = "farm", savedAt = 100, name = "Run", itemLoots = { { itemID = 2770, quantity = 8 } }, extra = { false } },
        { id = 10, recordType = "loot", name = "Unrelated session" },
    }
    return result, farm, catalog
end

describe("Core/FarmTransfer", function()
    it("round trips complete farms, route dependencies, run history and unknown fields into new IDs", function()
        with_codec(function()
            local original, farm = source()
            local before = original:CopyCustomFarmData(farm)
            local text, message = original:BuildCustomFarmExport(farm.id)
            assert.is_nil(message)
            assert.matches("^GGT%-FARMS:1:", text)
            assert.same(before, farm)
            local package = encoding.unwrap(text)
            assert.equals(1, #package.history)
            assert.equals(2, #package.farms[1].entries[2].catalogSnapshot.ggtMapOptions[1].pins)
            local destination = addon({ sessionHistory = { { id = 50, name = "Existing" } }, nextHistoryID = 51 })
            local existing = destination:CreateCustomFarm("Existing", false)
            local result = assert(destination:ImportCustomFarmString("\n" .. text .. "\r\n"))
            assert.equals(1, result.count)
            assert.equals(1, result.historyCount)
            assert.equals(existing, destination:GetCustomFarmByID(existing.id))
            assert.equals(2, result.farms[1].id)
            local imported = result.farms[1]
            assert.same(farm.routePlan, imported.routePlan)
            assert.same(farm.extra, imported.extra)
            assert.equals(farm.assignedCharacter, imported.assignedCharacter)
            local entry = destination:CopyCustomFarmData(imported.entries[1])
            entry.portableMapSource = nil
            assert.same(farm.entries[1], entry)
            assert.equals(51, destination.db.sessionHistory[2].id)
            assert.equals(imported.id, destination.db.sessionHistory[2].farmID)
            assert.same(original.db.sessionHistory[1].itemLoots, destination.db.sessionHistory[2].itemLoots)
        end)
    end)

    it("retains imported maps and planner destinations after reload without a local catalog", function()
        with_codec(function()
            local original, farm = source()
            local destination = addon()
            local imported = assert(destination:ImportCustomFarmString(assert(original:BuildCustomFarmExport(farm.id)))).farms[1]
            local reloaded = addon(destination.db)
            local saved = reloaded:GetCustomFarmByID(imported.id)
            assert.same(farm.extra, saved.extra)
            assert.same(farm.entries[1].extra, saved.entries[1].extra)
            assert.same(farm.entries[1].mapSource.pins, saved.entries[1].mapSource.pins)
            assert.equals(0, reloaded:ResolveCustomFarmEntryMapOption(saved.entries[1]).pins[1].x)
            local plan = reloaded:BuildCustomFarmRoutePlan(saved.id, false)
            assert.equals("catalog:catalog:skins", plan[1].key)
            assert.equals(0.123456789012345, plan[1].x)
            assert.is_true(plan[1].locked)
            local snapshot = saved.entries[2].catalogSnapshot
            local maps = reloaded:BuildFarmDetailsMapOptions({ snapshot }, 2318)
            assert.equals(2, #maps[1].pins)
            assert.is_nil(snapshot.ggtMapOptions[1].farm)
            assert.is_truthy(reloaded:BuildCustomFarmExport(saved.id))
        end)
    end)

    it("exports all farms and retains separate snapshots for the same catalog ID", function()
        with_codec(function()
            local original, farm = source()
            local second = original:CreateCustomFarm("Other version", false)
            original:AddEntryToCustomFarm(second.id, { itemID = 2318, catalogFarmID = "catalog:skins",
                catalogSnapshot = { id = "catalog:skins", name = "Old version", mapIDs = { 200 },
                    ggtMapOptions = {}, ggtGatheringRecords = {} } })
            local package = encoding.unwrap(assert(original:BuildCustomFarmExport()))
            assert.equals(2, #package.farms)
            assert.equals("Skins", package.farms[1].entries[2].catalogSnapshot.name)
            assert.equals("Old version", package.farms[2].entries[1].catalogSnapshot.name)
            local destination = addon()
            local result = assert(destination:ImportCustomFarmString(assert(original:BuildCustomFarmExport())))
            assert.equals(2, result.count)
            assert.equals(1, result.historyCount)
            assert.is_true(result.farms[1].transferContext.wasBuilding)
            assert.is_true(result.farms[1].transferContext.activeRouteCharacters["Hero-Realm"])
            assert.is_nil(destination:GetCustomFarmStore().activeBuildFarmID)
            assert.equals(farm.name, result.farms[1].name)
        end)
    end)

    it("rejects damaged, unsupported and partially invalid collections without adding anything", function()
        with_codec(function()
            local original, farm = source()
            local text = assert(original:BuildCustomFarmExport(farm.id))
            local destination = addon()
            local existing = destination:CreateCustomFarm("Existing", false)
            local function reject(value)
                local before = destination:CopyCustomFarmData(destination.db)
                local result, message = destination:ImportCustomFarmString(value)
                assert.is_nil(result)
                assert.is_string(message)
                assert.same(before, destination.db)
                assert.equals(existing, destination:GetCustomFarmByID(existing.id))
            end
            reject("not a farm")
            reject(text:sub(1, -8))
            reject(text:gsub("GGT%-FARMS:1:", "GGT-FARMS:2:"))
            reject(text:gsub(":%x%x%x%x%x%x%x%x:", ":00000000:", 1))
            local package = encoding.unwrap(text)
            package.farms[2] = original:CopyCustomFarmData(package.farms[1])
            package.farms[2].id = 99
            package.farms[2].entries[1].itemID = "invalid"
            reject(encoding.wrap(package))
            package = encoding.unwrap(text)
            package.farms[1].routePlan.order = { false }
            reject(encoding.wrap(package))
        end)
    end)

    it("fails clearly when linked data or the native codec is unavailable", function()
        with_codec(function()
            local original, farm = source()
            farm.entries[2].catalogFarmID = "missing"
            local text, message = original:BuildCustomFarmExport(farm.id)
            assert.is_nil(text)
            assert.matches("Linked farm data is unavailable", message)
            farm.entries[2].catalogFarmID = "catalog:skins"
            farm.extra.loop = farm
            text, message = original:BuildCustomFarmExport(farm.id)
            assert.is_nil(text)
            assert.matches("circular reference", message)
            farm.extra.loop = nil
            loader.with_globals({ C_EncodingUtil = {} }, function()
                assert.is_nil(original:BuildCustomFarmExport(farm.id))
            end)
        end)
    end)
end)
