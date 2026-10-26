local ROOT = "Data/General-Gold-Tracker_Materials/"
local MODULE = "MaterialFarmingSpots/Dragonflight/BaseMaterialMaps.lua"
local function Copy(value)
    if type(value) ~= "table" then return value end
    local result = {}
    for key, entry in pairs(value) do result[key] = Copy(entry) end
    return result
end
local function LoadMaps()
    local ns = {GoldTracker={}}
    assert(loadfile("Data/FarmingItems.lua"))("GGT",ns)
    for line in io.lines(ROOT .. "General-Gold-Tracker_Materials.toc") do
        line = line:gsub("\r","")
        if line:match("%.lua$") and line ~= "Namespace.lua" and line ~= MODULE then
            assert(loadfile(ROOT .. line))("GGT",ns)
        end
    end
    local before, catalog = Copy(ns.MaterialFarmingSpots.items), Copy(ns.FarmingItems)
    assert(loadfile(ROOT .. MODULE))("GGT",ns)
    return ns,before,catalog
end

describe("Dragonflight missing Materials maps",function()
    it("fills only 44 missing maps, repairs 14 unusable maps and preserves every composed entry and other route",function()
        local ns,before,catalog = LoadMaps()
        assert.same(catalog,ns.FarmingItems)
        local audit,missing,repaired = ns.DragonflightMissingMaterialMapAudit,0,0
        for id in pairs(audit.missingItems) do
            assert.equals(0,#before[id].spots)
            assert.is_true(#ns.MaterialFarmingSpots.items[id].spots > 0)
            missing = missing + 1
        end
        for id in pairs(audit.repairedItems) do
            assert.equals(1,#before[id].spots)
            assert.equals("dragonflight-prospecting-ore-input-route",before[id].spots[1].id)
            repaired = repaired + 1
        end
        assert.equals(44,missing)
        assert.equals(14,repaired)
        for id,record in pairs(before) do
            if not audit.items[id] then assert.same(record,ns.MaterialFarmingSpots.items[id]) end
        end
        for id in pairs(audit.items) do
            assert.is_nil(ns.MaterialFarmingSpots.items[id].components)
        end
        local first = Copy(ns.MaterialFarmingSpots.items)
        assert(loadfile(ROOT .. MODULE))("GGT",ns)
        assert.same(first,ns.MaterialFarmingSpots.items)
    end)

    it("uses the right herb for each pigment rank and preserves complete input-route geometry and provenance",function()
        local ns,before = LoadMaps()
        for _,family in ipairs({
            {ids={198412,198413,198414},input=191467},
            {ids={198415,198416,198417},input=191470},
            {ids={198418,198419,198420},input=191464},
            {ids={198421,198422,198423},input=191460},
        }) do
            for _,id in ipairs(family.ids) do
                local item = ns.MaterialFarmingSpots.items[id]
                assert.same({family.input},item.mapInputItemIDs)
                assert.equals(#before[family.input].spots,#item.spots)
                for index,spot in ipairs(item.spots) do
                    local original = before[family.input].spots[index]
                    assert.equals(family.input,spot.inputItemID)
                    assert.equals(original.id,spot.inputRouteID)
                    for _,key in ipairs({"coords","isRoute","routeExport","routeSource","routeOrigin","sortOrder","source"}) do
                        assert.same(original[key],spot[key])
                    end
                    assert.is_truthy(spot.farmAction:find("Milling",1,true))
                    assert.is_true(#spot.tips > 0 and #spot.sourceUrls > 0)
                    assert.is_false(spot.inGameTested)
                end
            end
        end
    end)

    it("distinguishes prospecting gems from crushing three gems into dust without adding deterministic recipes",function()
        local ns,before = LoadMaps()
        for id in pairs(ns.DragonflightMissingMaterialMapAudit.missingItems) do
            local item = ns.MaterialFarmingSpots.items[id]
            if item.category == "Gem" or item.category == "Gemdust" then
                assert.same({190394,188658},item.mapInputItemIDs)
                assert.equals(#before[190394].spots + #before[188658].spots,#item.spots)
                for _,spot in ipairs(item.spots) do
                    assert.is_truthy(spot.farmAction:find("prospect",1,true))
                    if item.category == "Gemdust" then
                        assert.is_truthy(spot.farmAction:find("crush three",1,true))
                    end
                    local original
                    for _,inputSpot in ipairs(before[spot.inputItemID].spots) do
                        if inputSpot.id == spot.inputRouteID then original = inputSpot end
                    end
                    assert.is_table(original)
                    assert.same(original.coords,spot.coords)
                end
                assert.is_nil(item.components)
            end
        end
    end)

    it("splits the legacy mixed-zone arrays without losing or reordering any original point",function()
        local ns,before = LoadMaps()
        for id in pairs(ns.DragonflightMissingMaterialMapAudit.repairedItems) do
            local spots = ns.MaterialFarmingSpots.items[id].spots
            assert.equals(2,#spots)
            assert.equals(2022,spots[1].mapID)
            assert.equals(2023,spots[2].mapID)
            assert.equals(7,#spots[1].coords)
            assert.equals(5,#spots[2].coords)
            local joined = {}
            for _,spot in ipairs(spots) do
                assert.is_false(spot.isRoute)
                for _,coord in ipairs(spot.coords) do joined[#joined + 1] = coord end
            end
            assert.same(before[id].spots[1].coords,joined)
        end
    end)

    it("shows source areas honestly and discloses node modifiers and War Mode requirements",function()
        local ns = LoadMaps()
        local items = ns.MaterialFarmingSpots.items
        for _,spot in ipairs(items[190322].spots) do
            assert.is_truthy(spot.farmAction:find("Titan-Touched",1,true))
        end
        for _,spot in ipairs(items[190451].spots) do
            assert.is_truthy(spot.farmAction:find("War Mode",1,true))
            assert.is_truthy(spot.farmAction:find("Infurious",1,true))
        end
        for _,id in ipairs({193258,201406}) do
            for _,spot in ipairs(items[id].spots) do
                assert.is_true(spot.mapOnly)
                assert.equals(0,#spot.coords)
                assert.is_false(spot.isRoute)
            end
        end
        assert.equals(0.18,items[190330].spots[2].coords[1].x)
        assert.equals("player-reported",items[190330].spots[2].confidence)
    end)

    it("opens both Raid Items at sourced outdoor entrances and exposes every researched map in the lightweight index",function()
        local ns = LoadMaps()
        assert(loadfile("Data/MaterialIndex.lua"))("GGT",ns)
        assert(loadfile("UI/CraftingFarmingWindow.lua"))("GGT",ns)
        local items = ns.MaterialFarmingSpots.items
        assert.equals(2200,items[208212].spots[1].mapID)
        assert.equals(0.2730,items[208212].spots[1].coords[1].x)
        assert.equals(0.3104,items[208212].spots[1].coords[1].y)
        assert.equals(2133,items[204464].spots[1].mapID)
        assert.equals(0.4846,items[204464].spots[1].coords[1].x)
        assert.equals(0.1035,items[204464].spots[1].coords[1].y)
        assert.equals(2200,items[204464].spots[2].mapID)
        for id in pairs(ns.DragonflightMissingMaterialMapAudit.items) do
            assert.is_true(ns.MaterialIndex.items[id].hasMap)
            local options = ns.GoldTracker:BuildMaterialFarmingMapOptions(id)
            assert.is_true(#options > 0)
            for _,option in ipairs(options) do
                local pin = (option.detailPins or option.pins)[1]
                assert.is_string(pin.farmAction)
                assert.is_true(#pin.tips > 0 and #pin.sourceUrls > 0)
            end
        end
    end)
end)
