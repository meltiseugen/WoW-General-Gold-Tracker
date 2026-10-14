local loader = require("tests.helpers.addon_loader")

local function with_addon(callback)
    loader.with_globals({
        GeneralGoldTrackerCatalogNamespace = false,
        JanisTheme = false,
        SlashCmdList = {},
        WOW_PROJECT_MAINLINE = 1,
        WoWGeneralGoldTrackerDB = {},
        time = function() return 1710000000 end,
        date = os.date,
        C_AddOns = {},
    }, function()
        local loaded, calls = {}, {}
        C_AddOns.LoadAddOn = function(name)
            calls[name] = (calls[name] or 0) + 1
            if loaded[name] then return true end
            local root = "Data/" .. name .. "/"
            local private = {}
            for line in io.lines(root .. name .. ".toc") do
                line = line:gsub("\r", "")
                if line:match("%.lua$") then
                    assert(loadfile(root .. line))(name, private)
                end
            end
            loaded[name] = true
            return true
        end
        local ns = { GoldTracker = { SetScript = function() end, RegisterEvent = function() end } }
        for line in io.lines("General-Gold-Tracker.toc") do
            line = line:gsub("\r", "")
            if line:match("^[^#].*%.lua$") then
                assert(loadfile(line))("General-Gold-Tracker", ns)
            end
        end
        callback(ns.GoldTracker, ns, loaded, calls)
    end)
end

describe("On-demand catalog modules", function()
    it("keeps catalogs unloaded through database initialization and automatic price work", function()
        with_addon(function(addon, ns, loaded)
            addon:InitializeDatabase()
            addon:InitializeMemoryStorage()
            local candidates = addon:BuildKnownPriceScanCandidates()
            assert.is_true(#candidates > 1000)
            assert.is_true(#candidates < 1500)
            addon:StartKnownPriceScan()
            addon:BuildPriceIncreaseAlertRows()
            addon:HasInventoryMaterialFarmingMap(2770)
            assert.same({}, loaded)
            assert.is_nil(rawget(ns, "MaterialFarmingSpots"))
            assert.is_nil(rawget(ns, "CatalogDropsData"))
        end)
    end)

    it("loads each requested module once and preserves cross-catalog augmentation", function()
        with_addon(function(_, ns, loaded, calls)
            local rares = ns.RareDropsData
            assert.is_table(rares)
            assert.equals(rares, ns.RareDropsData)
            assert.equals(1, calls["General-Gold-Tracker_Rares"])
            assert.is_nil(loaded["General-Gold-Tracker_Materials"])
            assert.is_table(ns.InstanceDropsData.instances)
            assert.is_table(ns.ATTBoEDropsData)
            assert.is_table(ns.InstanceLocationResearch)
            assert.equals(1, calls["General-Gold-Tracker_Instances"])
            assert.is_table(ns.FarmCatalog.farms)
            assert.is_table(ns.PetFarmData.rows)
            assert.is_table(ns.MountFarmData)
            assert.is_table(ns.ToyFarmData)
            assert.is_table(ns.CatalogDropsData.categories)
            assert.equals(1, calls["General-Gold-Tracker_Farms"])
            assert.equals(1, calls["General-Gold-Tracker_Drops"])
            assert.is_nil(loaded["General-Gold-Tracker_Materials"])
            assert.is_table(ns.MaterialFarmingSpots.items[2770])
            assert.is_table(ns.MaterialFarmingSpots.coverage)
            assert.is_table(ns.CatalogGatheringData)
            assert.equals(1, calls["General-Gold-Tracker_Materials"])
        end)
    end)

    it("keeps the lightweight material index in sync with the full map catalog", function()
        with_addon(function(_, ns)
            local materials = ns.MaterialFarmingSpots.items
            for id, item in pairs(materials) do
                local index = ns.MaterialIndex.items[id]
                assert.is_table(index)
                assert.equals(type(item.spots) == "table" and #item.spots > 0, index.hasMap)
                assert.equals(item.expansion, index.expansion)
                assert.same(item.professions, index.professions)
            end
            for id in pairs(ns.MaterialIndex.items) do assert.is_table(materials[id]) end
        end)
    end)

    it("reports a missing data module instead of caching an empty catalog", function()
        with_addon(function(_, ns)
            C_AddOns.LoadAddOn = function() return nil, "MISSING" end
            assert.has_error(function() return ns.RareDropsData end,
                "General Gold Tracker could not load Rares data (MISSING). Install all GGT folders and restart WoW after adding data addons.")
            assert.is_nil(rawget(ns, "RareDropsData"))
        end)
    end)
end)
