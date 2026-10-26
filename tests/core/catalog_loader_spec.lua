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
    it("opens and refreshes Favorites without loading catalogs or restoring scans", function()
        with_addon(function(addon, ns, loaded, calls)
            addon:InitializeDatabase()
            addon:InitializeMemoryStorage()
            -- Numeric scan filters used to load Rares even before a view opened.
            addon.db.rareFarmingExpansionFilter = "6"
            local favorites = addon:GetFarmingFavoriteStore()
            favorites["item:2770"] = { itemID = 2770, itemName = "Copper Ore", itemLink = "item:2770",
                farmingSourceType = "material", expansionLabel = "Classic" }
            favorites["item:40001"] = { itemID = 40001, itemName = "Rare Cape", itemLink = "item:40001",
                npcID = 1001, rareName = "Rare One", expansionFilterID = "6",
                locationLabel = "Pandaria", locations = { { mapID = 371, x = 42, y = 51 } } }
            favorites["item:40002"] = { itemID = 40002, itemName = "Boss Cape", itemLink = "item:40002",
                instanceName = "Raid One", instanceMapID = 100, expansionLabel = "Classic" }
            addon.LoadRareFarmingScanCacheForCurrentFilters = function()
                error("Favorites must not restore an unrelated scan")
            end
            local ui = require("tests.helpers.explorer_ui")
            ui.with_ui(ns, function()
                addon:OpenExplorerWindow()
                assert.equals("favorites", addon.explorerFrame.activeTabID)
                assert.equals("3 favorite items grouped by expansion", addon.rareFarmingFrame.libraryStatusText:GetText())
                local itemRows = {}
                for _, row in ipairs(addon.rareFarmingFrame.libraryRows) do
                    if row.itemID then
                        itemRows[row.itemID] = row
                        assert.is_true(row.favoriteFarmButton:IsShown())
                        row.itemTooltipTarget:GetScript("OnEnter")(row.itemTooltipTarget)
                    end
                end
                assert.is_table(itemRows[2770])
                assert.is_table(itemRows[40001])
                assert.is_table(itemRows[40002])
                -- Item-data callbacks and resize refreshes must stay in the library.
                local unrelatedResults = { setmetatable({}, { __index = function()
                    error("Favorites must not walk unrelated saved scan results")
                end }) }
                addon.db.rareFarmingScanCache.unrelated = { results = unrelatedResults }
                loader.with_globals({ C_Item = { GetItemInfo = function()
                    return "Loaded Copper Ore", "item:2770", 1
                end } }, function()
                    addon.rareFarmingFrame:GetScript("OnEvent")(nil, "GET_ITEM_INFO_RECEIVED", 2770)
                end)
                assert.equals("Loaded Copper Ore", favorites["item:2770"].itemName)
                addon.db.rareFarmingScanCache.unrelated = nil
                addon:RefreshRareFarmingWindow(false)
                addon.rareFarmingFrame:GetScript("OnSizeChanged")()
                addon.explorerFrame:Hide()
                addon:OpenExplorerWindow()
                assert.same({}, loaded)
                assert.same({}, calls)
                assert.is_nil(addon.instanceFarmingFrame)
                assert.is_nil(addon.craftingFarmingFrame)
                assert.is_nil(addon.observedDropsFrame)
                assert.is_nil(addon.myFarmsFrame)
                -- Only the requested scan subtab loads Rares and its dropdown.
                addon:SetExplorerTab("rares")
                assert.same({}, loaded)
                addon:OpenRareFarmingNewScan()
                assert.is_true(loaded["General-Gold-Tracker_Rares"])
                assert.equals(1, calls["General-Gold-Tracker_Rares"])
                assert.is_nil(loaded["General-Gold-Tracker_Materials"])
                assert.is_nil(loaded["General-Gold-Tracker_Farms"])
                assert.is_nil(loaded["General-Gold-Tracker_Drops"])
                assert.is_nil(loaded["General-Gold-Tracker_Instances"])
            end)
        end)
    end)

    it("defers material map loading until a favorite Map button is clicked", function()
        with_addon(function(addon, ns, loaded)
            addon:InitializeDatabase()
            addon:InitializeMemoryStorage()
            addon:GetFarmingFavoriteStore()["item:2770"] = {
                itemID = 2770, itemName = "Copper Ore", itemLink = "item:2770",
                farmingSourceType = "material", expansionLabel = "Classic",
            }
            require("tests.helpers.explorer_ui").with_ui(ns, function()
                addon:OpenExplorerWindow()
                assert.same({}, loaded)
                -- Native map rendering is separate; map selection/data lookup is real.
                local openedItemID
                addon.OpenMaterialFarmingMap = function(_, itemID)
                    openedItemID = itemID
                    return true
                end
                for _, row in ipairs(addon.rareFarmingFrame.libraryRows) do
                    if row.itemID == 2770 then
                        row.favoriteFarmButton:GetScript("OnClick")(row.favoriteFarmButton)
                    end
                end
                assert.equals(2770, openedItemID)
                assert.is_true(loaded["General-Gold-Tracker_Materials"])
                assert.is_nil(loaded["General-Gold-Tracker_Rares"])
                assert.is_nil(loaded["General-Gold-Tracker_Instances"])
            end)
        end)
    end)

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

    it("loads recipe rows with Drops alone and defers recipe guides to the Farms module", function()
        with_addon(function(_,ns,loaded,calls)
            assert.is_nil(rawget(ns,"RecipeDropsData"))
            assert.equals(23,#ns.RecipeDropsData.rows)
            assert.equals(1,calls["General-Gold-Tracker_Drops"])
            assert.is_nil(loaded["General-Gold-Tracker_Farms"])
            assert.is_nil(loaded["General-Gold-Tracker_Materials"])
            assert.equals(23,#ns.RecipeFarmData.farms)
            assert.equals(1,calls["General-Gold-Tracker_Farms"])
            assert.equals(1,calls["General-Gold-Tracker_Drops"])
            assert.is_nil(loaded["General-Gold-Tracker_Materials"])
        end)
    end)

    it("loads Cosmetics rows separately from guides and never needs Materials", function()
        with_addon(function(_,ns,loaded,calls)
            assert.is_nil(rawget(ns,"CosmeticDropsData"))
            assert.equals(219,#ns.CosmeticDropsData.rows)
            assert.equals(1,calls["General-Gold-Tracker_Drops"])
            assert.is_nil(loaded["General-Gold-Tracker_Farms"])
            assert.is_nil(loaded["General-Gold-Tracker_Materials"])
            assert.equals(219,#ns.CosmeticFarmData.farms)
            assert.equals(1,calls["General-Gold-Tracker_Farms"])
            assert.equals(1,calls["General-Gold-Tracker_Drops"])
            assert.is_nil(loaded["General-Gold-Tracker_Materials"])
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
            assert.equals(27, #ns.MountFarmData.rows)
            assert.equals(20, #ns.MountAcquisitionResearch)
            assert.is_table(ns.FarmCatalog.indexes.byItemID[221967])
            assert.is_table(ns.ToyFarmData)
            assert.equals(36, #ns.ToyFarmData.rows)
            assert.equals(28, #ns.ToyAcquisitionResearch)
            assert.is_table(ns.FarmCatalog.indexes.byItemID[248485])
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
