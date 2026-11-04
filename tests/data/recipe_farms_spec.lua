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
describe("Drops Recipes catalog and guides",function()
    it("places all 23 Dragonflight scrolls in Recipes exactly once and removes their Materials records",function()
        local ns = load_catalogs()
        local rows = ns.CatalogDropsData.categories.recipes
        assert.equals(23,#rows)
        assert.equals(23,ns.CatalogDropsData.categoryCounts.recipes)
        local materialIDs,seen = {},{}
        for _,item in ipairs(ns.FarmingItems.items) do materialIDs[item.itemID] = true end
        for _,row in ipairs(rows) do
            assert.is_nil(seen[row.itemID])
            seen[row.itemID] = true
            assert.is_nil(materialIDs[row.itemID])
            assert.is_nil(ns.MaterialFarmingSpots.items[row.itemID])
            assert.is_nil(ns.MaterialIndex.items[row.itemID])
            assert.equals("dragonflight",row.expansion)
            assert.equals(10,row.contentID)
            assert.is_true(row.auctionable)
            assert.is_true(row.randomOutput)
            assert.is_true(#row.tips > 0 and #row.sourceUrls > 0)
            local positions = ns.FarmCatalog.indexes.byRecordID[row.recordID]
            assert.equals(1,#positions)
            assert.equals(1,#ns.FarmCatalog.indexes.byItemID[row.itemID])
            local farm = ns.FarmCatalog.farms[positions[1]]
            assert.equals(row.itemID,farm.primaryItemID)
            assert.equals("recipes",farm.sourceCategory)
            assert.equals("Drops > Recipes",farm.sourcePath)
            assert.same(row.tips,farm.guide.tips)
            for index,url in ipairs(row.sourceUrls) do assert.equals(url,farm.sourceUrls[index].url) end
        end
        assert.is_true(seen[191544] and seen[194671] and seen[205161])
        -- This migration is scoped to the Dragonflight entries under review.
        assert.is_table(ns.MaterialFarmingSpots.items[163833])
    end)
    it("keeps recipe rows, counts and farm indexes stable on repeated module loads",function()
        local ns = load_catalogs()
        local itemCount,farmCount,uniqueCount = ns.CatalogDropsData.itemSourceCount,
            ns.FarmCatalog.farmCount,ns.FarmCatalog.uniqueItemCount
        for _=1,2 do
            assert(loadfile("Data/General-Gold-Tracker_Drops/Recipes.lua"))("GGT",ns)
            assert(loadfile("Data/General-Gold-Tracker_Farms/RecipeFarms.lua"))("GGT",ns)
        end
        assert.equals(23,#ns.CatalogDropsData.categories.recipes)
        assert.equals(itemCount,ns.CatalogDropsData.itemSourceCount)
        assert.equals(farmCount,ns.FarmCatalog.farmCount)
        assert.equals(uniqueCount,ns.FarmCatalog.uniqueItemCount)
        for _,row in ipairs(ns.RecipeDropsData.rows) do
            assert.equals(1,#ns.FarmCatalog.indexes.byRecordID[row.recordID])
            assert.equals(1,#ns.FarmCatalog.indexes.byItemID[row.itemID])
        end
    end)
    it("opens source-area maps with the recipe notes and sources without fabricated pins or yield calculations",function()
        local ns = load_catalogs()
        assert(loadfile("UI/FarmDetailsWindow.lua"))("GGT",ns)
        local addon = ns.GoldTracker
        addon.BuildFarmValuationSnapshot = function() error("Recipe guides must not calculate deterministic yields") end
        for _,farm in ipairs(ns.RecipeFarmData.farms) do
            local options = addon:BuildFarmDetailsMapOptions({farm},farm.primaryItemID)
            assert.equals(1,#options)
            assert.equals(1978,options[1].mapID)
            assert.is_true(options[1].mapOnly)
            assert.equals(0,#options[1].pins)
            local lines = addon:BuildFarmMapDetailLines(farm,farm.primaryItemID,"Dragon Isles")
            local tips,sources,action = false,false,false
            for _,line in ipairs(lines) do
                if line.text == "Tips" then tips = true end
                if line.type == "source" then sources = true end
                if line.text == farm.guide.action then action = true end
            end
            assert.is_true(tips and sources and action)
        end
    end)
end)
