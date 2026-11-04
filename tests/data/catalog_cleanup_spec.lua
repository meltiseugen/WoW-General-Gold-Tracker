local function load_catalogs()
    local ns = { GoldTracker = {} }
    local function load(path)
        assert(loadfile(path))("General-Gold-Tracker", ns)
    end
    load("Data/FarmingItems.lua")
    local root = "Data/General-Gold-Tracker_Materials/"
    for line in io.lines(root .. "General-Gold-Tracker_Materials.toc") do
        line = line:gsub("\r", "")
        if line:match("%.lua$") and line ~= "Namespace.lua" then load(root .. line) end
    end
    for _, path in ipairs({ "Data/MaterialIndex.lua",
        "Data/General-Gold-Tracker_Drops/CatalogDrops.lua",
        "Data/General-Gold-Tracker_Farms/Farms.lua",
        "Data/General-Gold-Tracker_Farms/MountAcquisitionResearch.lua",
        "Data/General-Gold-Tracker_Farms/MountFarms.lua",
        "Data/General-Gold-Tracker_Farms/PetAcquisitionResearch.lua",
        "Data/General-Gold-Tracker_Farms/PetFarms.lua",
        "Data/General-Gold-Tracker_Farms/ToyAcquisitionResearch.lua",
        "Data/General-Gold-Tracker_Farms/ToyFarms.lua",
        "Data/General-Gold-Tracker_Rares/RareDrops.lua" }) do load(path) end
    return ns
end

describe("Catalog product cleanup", function()
    it("excludes Darkmoon products and activities from every bundled catalog", function()
        local ns = load_catalogs()
        local function check(record)
            for _, key in ipairs({ "itemName", "name", "tag", "category", "farmName", "locationLabel" }) do
                assert.is_nil(tostring(record[key] or ""):lower():find("darkmoon", 1, true))
            end
        end
        for _, item in ipairs(ns.FarmingItems.items) do check(item) end
        for _, item in pairs(ns.MaterialFarmingSpots.items) do check(item) end
        for _, item in pairs(ns.MaterialIndex.items) do check(item) end
        for _, rows in pairs(ns.CatalogDropsData.categories) do
            for _, row in ipairs(rows) do
                check(row)
                assert.is_true(row.petID ~= 848 and row.petID ~= 1276)
            end
        end
        for _, farm in ipairs(ns.FarmCatalog.farms) do check(farm) end
        for _, rare in pairs(ns.RareDropsData.rares) do check(rare) end
        assert.is_nil(ns.RareDropsData.rares[71992])
        -- Named cards and decks whose names do not contain Darkmoon.
        for _, itemID in ipairs({ 79283, 79323, 112271, 112303, 112319, 128713,
            153603, 173070, 177840, 194785, 198614, 222654, 245830 }) do
            assert.is_nil(ns.MaterialFarmingSpots.items[itemID])
            assert.is_nil(ns.MaterialIndex.items[itemID])
        end
    end)

    it("excludes augment runes from all bundled catalogs and nested loot", function()
        local ns, seen = load_catalogs(), {}
        local function check(value)
            if type(value) == "table" then
                if seen[value] then return end
                seen[value] = true
                for _, entry in pairs(value) do check(entry) end
            elseif type(value) == "string" then
                assert.is_nil(value:lower():find("augment[%s%-]*rune"))
            elseif type(value) == "number" then
                assert.is_true(value ~= 160053 and value ~= 181468)
            end
        end
        check(ns)
        for _, id in ipairs({160053,181468}) do
            assert.is_nil(ns.MaterialIndex.items[id])
            assert.is_nil(ns.MaterialFarmingSpots.items[id])
        end
    end)

    it("keeps each removed mount exactly once in Drops with its researched guide", function()
        local ns = load_catalogs()
        for _, itemID in ipairs({ 163573, 163574, 163575, 163576, 163131 }) do
            for _, item in ipairs(ns.FarmingItems.items) do assert.is_true(item.itemID ~= itemID) end
            assert.is_nil(ns.MaterialFarmingSpots.items[itemID])
            assert.is_nil(ns.MaterialIndex.items[itemID])
            local count = 0
            for _, row in ipairs(ns.CatalogDropsData.categories.mounts) do
                if row.itemID == itemID then count = count + 1 end
            end
            assert.equals(1, count)
            local positions = ns.FarmCatalog.indexes.byItemID[itemID]
            assert.equals(1, #positions)
            local farm = ns.FarmCatalog.farms[positions[1]]
            assert.equals("mounts", farm.sourceCategory)
            assert.is_true(#farm.guide.tips > 0)
            assert.is_true(#farm.mapOptions > 0)
            assert.is_true(#farm.sourceUrls > 0)
        end
    end)
end)
