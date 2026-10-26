local ROOT = "Data/General-Gold-Tracker_Materials/"
local MODULE = "MaterialFarmingSpots/WarWithin/BaseMaterialMaps.lua"
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

describe("The War Within base Materials maps",function()
    it("fills missing maps without touching composed graphs, the catalog, or other research and is idempotent",function()
        local ns,before,catalog = LoadMaps()
        local audit,missing,repaired = ns.WarWithinMissingMaterialMapAudit,0,0
        assert.same(catalog,ns.FarmingItems)
        for id in pairs(audit.missingItems) do
            assert.equals(0,#before[id].spots)
            missing = missing+1
        end
        for id in pairs(audit.repairedItems) do
            repaired = repaired+1
            if id >= 210796 and id <= 210938 then
                local spots = ns.MaterialFarmingSpots.items[id].spots
                assert.equals(#before[id].spots,#spots)
                for index,spot in ipairs(spots) do
                    for _,key in ipairs({"coords","id","isRoute","routeExport","routeOrigin","sortOrder","source"}) do
                        assert.same(before[id].spots[index][key],spot[key])
                    end
                end
            end
        end
        assert.equals(56,missing)
        assert.equals(33,repaired)
        for id,record in pairs(before) do
            if not audit.items[id] then assert.same(record,ns.MaterialFarmingSpots.items[id]) end
        end
        for id in pairs(audit.items) do
            assert.is_nil(ns.MaterialFarmingSpots.items[id].components)
            assert.is_true(#ns.MaterialFarmingSpots.items[id].spots > 0)
        end
        local first = Copy(ns.MaterialFarmingSpots.items)
        assert(loadfile(ROOT .. MODULE))("GGT",ns)
        assert.same(first,ns.MaterialFarmingSpots.items)
    end)

    it("matches pigments and threads to their actual input family while retaining input geometry and provenance",function()
        local ns,before = LoadMaps()
        for _,family in ipairs({
            {ids={222618,222619,222620},input=210796,action="Milling"},
            {ids={222612,222613,222614},input=210799,action="Milling"},
            {ids={224800,224801,224802},input=210802,action="Milling"},
            {ids={224803,224804,224805},input=210805,action="Milling"},
            {ids={222795,222796,222797},input=224828,action="Unravel"},
            {ids={222789,222790,222791},input=224824,action="Unravel"},
            {ids={222792,222793,222794},input=224826,action="Unravel"},
        }) do
            for _,id in ipairs(family.ids) do
                local item = ns.MaterialFarmingSpots.items[id]
                assert.same({family.input},item.mapInputItemIDs)
                assert.equals(#before[family.input].spots,#item.spots)
                for index,spot in ipairs(item.spots) do
                    local original = before[family.input].spots[index]
                    assert.equals(original.id,spot.inputRouteID)
                    for _,key in ipairs({"coords","isRoute","routeExport","routeOrigin","sortOrder","source"}) do
                        assert.same(original[key],spot[key])
                    end
                    assert.is_truthy(spot.farmAction:find(family.action,1,true))
                end
            end
        end
    end)

    it("keeps Crushing's extra Bismuth cost and the fishing-to-Scrap chain explicit without exposing bound inputs",function()
        local ns = LoadMaps()
        local items = ns.MaterialFarmingSpots.items
        for _,id in ipairs({213219,213220,213221}) do
            assert.same({210930},items[id].mapInputItemIDs)
            for _,spot in ipairs(items[id].spots) do
                assert.is_truthy(spot.farmAction:find("three gems and ten Bismuth",1,true))
            end
        end
        assert.same({220147},items[225568].mapInputItemIDs)
        assert.same({220152},items[225883].mapInputItemIDs)
        for _,spot in ipairs(items[225568].spots) do
            assert.is_truthy(spot.farmAction:find("Cooking Fresh Fillet",1,true))
        end
        for _,spot in ipairs(items[225883].spots) do
            assert.is_truthy(spot.farmAction:find("instead of normal fillets",1,true))
        end
        assert.is_truthy(items[223967].summary:find("five Fine Egg Powder",1,true))
        assert.is_truthy(items[210221].summary:find("no longer obtainable",1,true))
        for _,entry in ipairs(ns.FarmingItems.items) do
            assert.is_true(entry.itemID ~= 223487)
            if entry.itemID == 220152 or entry.itemID == 219150 then
                assert.is_false(entry.auctionable)
            end
        end
    end)

    it("splits mixed fishing zones without moving points and restricts Awoken Coelacanth to Azj-Kahet",function()
        local ns,before = LoadMaps()
        local items = ns.MaterialFarmingSpots.items
        local angler = items[220144].spots
        assert.equals(2214,angler[1].mapID)
        assert.equals(2215,angler[2].mapID)
        assert.same(before[220144].spots[1].coords[1],angler[1].coords[1])
        assert.same(before[220144].spots[1].coords[3],angler[1].coords[2])
        assert.same(before[220144].spots[1].coords[2],angler[2].coords[1])
        local royal = items[220151].spots
        assert.equals(2215,royal[1].mapID)
        assert.equals(2255,royal[2].mapID)
        local joined = {}
        for _,spot in ipairs(royal) do
            for _,coord in ipairs(spot.coords) do joined[#joined+1] = coord end
        end
        assert.same(before[220151].spots[1].coords,joined)
        for _,spot in ipairs(items[220153].spots) do assert.equals(2255,spot.mapID) end
        local access = items[220148].spots[2]
        assert.equals("fishing-area-access",access.routeType)
        assert.is_truthy(access.coords[1].label:find("not a pool",1,true))
        assert.same({before[220148].spots[1].coords[4]},access.legacyCoords)
        assert.equals(2255,access.mapID)
        assert.equals(0.548,access.coords[1].x)
        assert.equals(0.726,access.coords[1].y)
    end)

    it("uses exterior instance entrances and preserves the independent Tinderbox exchange",function()
        local ns,before = LoadMaps()
        local items = ns.MaterialFarmingSpots.items
        for _,id in ipairs({221754,221756,221757,221758,221763}) do
            for index=1,4 do
                local spot = items[id].spots[index]
                assert.equals("entrance",spot.mapRole)
                assert.equals("delve-entrance",spot.routeType)
                assert.is_truthy(spot.coords[1].label:find("exterior entrance",1,true))
                assert.is_false(spot.isRoute)
            end
            assert.equals(2215,items[id].spots[3].mapID)
            assert.equals(0.351,items[id].spots[3].coords[1].x)
            assert.equals(0.462,items[id].spots[3].coords[1].y)
        end
        assert.same(before[221758].spots[2].coords,items[221758].spots[5].coords)
        assert.equals(before[221758].spots[2].id,items[221758].spots[5].id)
        assert.equals(2371,items[249218].spots[1].mapID)
        assert.equals("entrance",items[249218].spots[1].mapRole)
    end)

    it("opens every enriched option with acquisition details and keeps unpinned areas free of invented pins",function()
        local ns = LoadMaps()
        assert(loadfile("Data/MaterialIndex.lua"))("GGT",ns)
        assert(loadfile("UI/CraftingFarmingWindow.lua"))("GGT",ns)
        for id in pairs(ns.WarWithinMissingMaterialMapAudit.items) do
            local item = ns.MaterialFarmingSpots.items[id]
            assert.is_true(ns.MaterialIndex.items[id].hasMap)
            local options = ns.GoldTracker:BuildMaterialFarmingMapOptions(id)
            assert.equals(#item.spots,#options)
            for _,option in ipairs(options) do
                local pin = (option.detailPins or option.pins)[1]
                assert.is_string(pin.farmAction)
                assert.is_true(#pin.tips > 0 and #pin.sourceUrls > 0)
                if option.mapOnly then
                    assert.equals(0,#option.pins)
                    assert.is_nil(pin.x)
                end
            end
        end
    end)
end)
