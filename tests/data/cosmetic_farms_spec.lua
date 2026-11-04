local function load_catalogs()
    local ns = {GoldTracker={}}
    local function load(path) assert(loadfile(path))("GGT",ns) end
    load("Data/FarmingItems.lua")
    for _, name in ipairs({"Materials","Drops","Farms"}) do
        local root = "Data/General-Gold-Tracker_" .. name .. "/"
        for line in io.lines(root .. "General-Gold-Tracker_" .. name .. ".toc") do
            line = line:gsub("\r","")
            if line:match("%.lua$") and line ~= "Namespace.lua" then load(root .. line) end
        end
    end
    load("Data/MaterialIndex.lua")
    return ns
end

describe("Drops Cosmetics catalog and acquisition guides",function()
    it("moves all fishing appearances and retains the two composed crafting graphs",function()
        local ns = load_catalogs()
        local ids,seen,counts = {},{},{}
        for _,item in ipairs(ns.FarmingItems.items) do ids[item.itemID] = item end
        local moved = {225752,225753,225754,225755,225756,225757,225758,225759,225760,225761,225762,225884}
        assert.equals(219,#ns.CosmeticDropsData.rows)
        assert.equals(219,ns.CatalogDropsData.categoryCounts.cosmetics)
        for _,row in ipairs(ns.CosmeticDropsData.rows) do
            assert.is_nil(seen[row.itemID])
            seen[row.itemID] = true
            counts[row.expansion] = (counts[row.expansion] or 0) + 1
            assert.equals("Cosmetic",row.tooltipType)
            assert.is_true(row.auctionable)
            assert.is_true(row.binding == "Binds when equipped" or row.binding == "Binds when used"
                or row.binding == "No binding restriction in tooltip")
            assert.is_string(row.patch)
            assert.is_true(#row.patches > 0 and #row.sourceUrls > 0)
            local positions = ns.FarmCatalog.indexes.byRecordID[row.recordID]
            assert.equals(1,#positions)
            local farm = ns.FarmCatalog.farms[positions[1]]
            assert.equals(row.itemID,farm.primaryItemID)
            assert.equals("cosmetics",farm.sourceCategory)
            assert.equals("Drops > Cosmetics",farm.sourcePath)
            assert.equals(row.patch,farm.patch)
        end
        assert.same({shadowlands=28,dragonflight=80,warWithin=12,midnight=99},counts)
        for _,id in ipairs(moved) do
            assert.is_true(seen[id])
            assert.is_nil(ids[id])
            assert.is_nil(ns.MaterialFarmingSpots.items[id])
            assert.is_nil(ns.MaterialIndex.items[id])
        end
        for _,id in ipairs({193371,194748}) do
            assert.is_true(seen[id])
            assert.is_true(#ids[id].components > 0)
        end
        assert.is_nil(seen[253221]) -- No valid tooltip: eligibility is unverified.
    end)

    it("moves only the fifteen exact Cosmetic-type Midnight fishing items and retains non-Cosmetic catches",function()
        local ns = load_catalogs()
        local materials,cosmetics = {},{}
        for _,item in ipairs(ns.FarmingItems.items) do materials[item.itemID] = item end
        for _,row in ipairs(ns.CosmeticDropsData.rows) do cosmetics[row.itemID] = row end
        for _,id in ipairs({260898,260900,260901,260902,260903,260904,260905,260907,260908,
            266384,266386,266387,266388,266393,266396}) do
            assert.is_nil(materials[id])
            assert.is_nil(ns.MaterialFarmingSpots.items[id])
            assert.is_nil(ns.MaterialIndex.items[id])
            assert.is_true(ns.FarmingItems.dropsOnlyItemIDs[id])
            local row = cosmetics[id]
            assert.equals("midnight",row.expansion)
            assert.equals("Cosmetic",row.tooltipType)
            local options = ns.CosmeticDropsData.guides[row.guideID].mapOptions
            assert.equals(2537,options[1].mapID)
            assert.is_true(options[1].mapOnly)
            assert.equals(0,#options[1].pins)
        end
        for _,id in ipairs({238489,238494,262650,262651,266102}) do
            assert.is_table(materials[id])
            assert.is_table(ns.MaterialFarmingSpots.items[id])
            assert.is_table(ns.MaterialIndex.items[id])
            assert.is_nil(cosmetics[id])
        end
    end)

    it("keeps row counts and farm indexes stable when modules are loaded again",function()
        local ns = load_catalogs()
        local itemCount,farmCount,uniqueCount = ns.CatalogDropsData.itemSourceCount,
            ns.FarmCatalog.farmCount,ns.FarmCatalog.uniqueItemCount
        for _=1,2 do
            assert(loadfile("Data/General-Gold-Tracker_Drops/Cosmetics.lua"))("GGT",ns)
            assert(loadfile("Data/General-Gold-Tracker_Farms/CosmeticFarms.lua"))("GGT",ns)
        end
        assert.equals(itemCount,ns.CatalogDropsData.itemSourceCount)
        assert.equals(farmCount,ns.FarmCatalog.farmCount)
        assert.equals(uniqueCount,ns.FarmCatalog.uniqueItemCount)
        for _,row in ipairs(ns.CosmeticDropsData.rows) do
            assert.equals(1,#ns.FarmCatalog.indexes.byRecordID[row.recordID])
        end
    end)

    it("opens inherited navigation and source-area maps with resale advice and no deterministic yields",function()
        local ns = load_catalogs()
        assert(loadfile("UI/FarmDetailsWindow.lua"))("GGT",ns)
        local addon = ns.GoldTracker
        addon.BuildFarmValuationSnapshot = function() error("Cosmetics must not infer a measured yield") end
        for _,farm in ipairs(ns.CosmeticFarmData.farms) do
            local options = addon:BuildFarmDetailsMapOptions({farm},farm.primaryItemID)
            assert.is_true(#options > 0)
            for _,option in ipairs(options) do
                if option.mapOnly then
                    assert.equals(farm.expansion == "warWithin" and 2274 or 2537,option.mapID)
                    assert.equals(0,#option.pins)
                    assert.is_true(option.mapOnly)
                else
                    assert.is_true(#option.pins > 0)
                end
            end
            local lines = addon:BuildFarmMapDetailLines(farm,farm.primaryItemID,farm.mapNames[1])
            local sources,sellTip = false,false
            for _,line in ipairs(lines) do
                if line.type == "source" then sources = true end
                if line.text == "- " .. farm.guide.tips[1] then sellTip = true end
            end
            assert.is_true(sources and sellTip)
        end
        local source = ns.CosmeticDropsData.guides["Shadowlands:9.1:mawShoulders"].mapOptions[1]
        assert.equals(1961,source.mapID)
        assert.equals("access",source.mapRole)
        assert.near(0.628,source.pins[1].x,0.00001)
        assert.near(0.226,source.pins[1].y,0.00001)
    end)
end)
