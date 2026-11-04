local ROOT = "Data/General-Gold-Tracker_Materials/"
local MODULE = "MaterialFarmingSpots/Midnight/BaseMaterialMaps.lua"
local function Copy(value)
    if type(value) ~= "table" then return value end
    local result = {}
    for key,entry in pairs(value) do result[key] = Copy(entry) end
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
    local before,catalog = Copy(ns.MaterialFarmingSpots.items),Copy(ns.FarmingItems)
    assert(loadfile(ROOT .. MODULE))("GGT",ns)
    return ns,before,catalog
end

describe("Midnight missing Materials maps",function()
    it("fills only 54 empty maps and preserves all compositions, working instance maps and other research",function()
        local ns,before,catalog = LoadMaps()
        assert.same(catalog,ns.FarmingItems)
        local count = 0
        for id in pairs(ns.MidnightMissingMaterialMapAudit.items) do
            assert.equals("midnight",before[id].expansion)
            assert.equals(0,#before[id].spots)
            assert.is_nil(before[id].components)
            assert.is_true(#ns.MaterialFarmingSpots.items[id].spots > 0)
            count = count+1
        end
        assert.equals(54,count)
        for id,item in pairs(before) do
            if not ns.MidnightMissingMaterialMapAudit.items[id] then
                assert.same(item,ns.MaterialFarmingSpots.items[id])
            end
        end
        local first = Copy(ns.MaterialFarmingSpots.items)
        assert(loadfile(ROOT .. MODULE))("GGT",ns)
        assert.same(first,ns.MaterialFarmingSpots.items)
    end)

    it("preserves the correct input families and complete gathering geometry without manufacturing routes",function()
        local ns,before = LoadMaps()
        for _,family in ipairs({
            {id=245803,inputs={236776}}, {id=245807,inputs={236761}},
            {id=245865,inputs={236770}}, {id=245867,inputs={236778}},
            {id=242606,inputs={237359,237362}}, {id=242610,inputs={237362}},
            {id=242611,inputs={237362}}, {id=242613,inputs={237364}},
            {id=242788,inputs={237359,237362,237364}}, {id=242608,inputs={237366}},
        }) do
            local item = ns.MaterialFarmingSpots.items[family.id]
            assert.same(family.inputs,item.mapInputItemIDs)
            for _,spot in ipairs(item.spots) do
                local original
                for _,inputSpot in ipairs(before[spot.inputItemID].spots) do
                    if inputSpot.id == spot.inputRouteID then original = inputSpot end
                end
                assert.is_table(original)
                for _,key in ipairs({"coords","routeExport","routeSource","routeOrigin","sortOrder","source"}) do
                    assert.same(original[key],spot[key])
                end
                for _,url in ipairs(original.sourceUrls or {}) do
                    local found = false
                    for _,newUrl in ipairs(spot.sourceUrls) do if url == newUrl then found = true end end
                    assert.is_true(found)
                end
                assert.is_false(spot.isRoute)
                assert.is_false(spot.inGameTested)
            end
        end
    end)

    it("keeps each processing chain explicit including one-fish filleting and Crushing's extra Stone",function()
        local ns = LoadMaps()
        local items = ns.MaterialFarmingSpots.items
        for _,spot in ipairs(items[253403].spots) do
            assert.is_truthy(spot.farmAction:find("on one fish",1,true))
        end
        for _,spot in ipairs(items[242620].spots) do
            assert.is_truthy(spot.farmAction:find("three gems plus one Stone",1,true))
        end
        for _,id in ipairs({245803,245807,245865,245867}) do
            for _,spot in ipairs(items[id].spots) do
                assert.is_truthy(spot.farmAction:find("ten matching herbs",1,true))
            end
        end
        for _,id in ipairs({243581,243582}) do
            assert.same({236761},items[id].mapInputItemIDs)
            for _,spot in ipairs(items[id].spots) do
                assert.is_truthy(spot.farmAction:find("Powder Pigment",1,true))
                assert.is_truthy(spot.farmAction:find("five matching pigments",1,true))
            end
        end
        for _,id in ipairs({243578,243579}) do
            assert.same({237359,237362},items[id].mapInputItemIDs)
            for _,spot in ipairs(items[id].spots) do
                assert.is_truthy(spot.farmAction:find("Soul Sprockets",1,true))
                assert.is_truthy(spot.farmAction:find("purchased Malleable Wireframe",1,true))
            end
        end
    end)

    it("distinguishes pool conversion and access markers from fish spawns and seasonal availability",function()
        local ns = LoadMaps()
        local items = ns.MaterialFarmingSpots.items
        local stargorger = items[274591].spots
        assert.equals(2512,stargorger[1].mapID)
        assert.is_true(stargorger[1].mapOnly)
        assert.equals("access",stargorger[2].mapRole)
        assert.equals(0.516,stargorger[2].coords[1].x)
        assert.equals(0.498,stargorger[2].coords[1].y)
        local detail = table.concat(items[274591].tips," ")
        assert.is_truthy(detail:find("converted pool",1,true))
        assert.is_truthy(table.concat(items[274593].tips," "):find("Shell of Yourself",1,true))
        assert.is_truthy(table.concat(items[256559].tips," "):find("can no longer be earned",1,true))
        assert.same({238490},items[266102].mapInputItemIDs)
        assert.is_truthy(items[266102].summary:find("conversion chain",1,true))
        assert.equals(0.515,items[274587].spots[1].coords[1].x)
        assert.equals("player-reported",items[274587].spots[1].confidence)
        for _,id in ipairs({274777,274781}) do
            assert.is_true(items[id].spots[1].mapOnly)
            assert.equals(2512,items[id].spots[1].mapID)
        end
    end)

    it("maps recipe outputs through treasure pools while keeping the bound bottle and composed outputs out of scope",function()
        local ns = LoadMaps()
        local item = ns.MaterialFarmingSpots.items[275320]
        assert.equals(4,#item.spots)
        local maps = {}
        for _,spot in ipairs(item.spots) do
            maps[spot.mapID] = true
            assert.is_true(spot.mapOnly)
            assert.equals(0,#spot.coords)
            assert.is_truthy(spot.farmAction:find("Careless Cargo or Lost Treasures",1,true))
            assert.is_truthy(spot.farmAction:find("Recipe in a Bottle",1,true))
        end
        assert.same({[2395]=true,[2437]=true,[2413]=true,[2512]=true},maps)
        assert.is_truthy(table.concat(item.tips," "):find("bottle is Warband-bound",1,true))
        assert.is_nil(ns.MidnightMissingMaterialMapAudit.items[278329])
        assert.is_nil(ns.MidnightMissingMaterialMapAudit.items[243576]) -- Soul Sprocket craft graph
    end)

    it("opens every new option with tips, sources and actions and indexes every new map",function()
        local ns = LoadMaps()
        assert(loadfile("Data/MaterialIndex.lua"))("GGT",ns)
        assert(loadfile("UI/CraftingFarmingWindow.lua"))("GGT",ns)
        for id in pairs(ns.MidnightMissingMaterialMapAudit.items) do
            assert.is_true(ns.MaterialIndex.items[id].hasMap)
            local item = ns.MaterialFarmingSpots.items[id]
            local options = ns.GoldTracker:BuildMaterialFarmingMapOptions(id)
            assert.equals(#item.spots,#options)
            for _,option in ipairs(options) do
                local pin = (option.detailPins or option.pins)[1]
                assert.is_string(pin.farmAction)
                assert.is_true(#pin.sourceUrls > 0 and #pin.tips > 0)
                if option.mapOnly then assert.equals(0,#option.pins); assert.is_nil(pin.x) end
            end
        end
    end)
end)
