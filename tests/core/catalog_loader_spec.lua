local loader = require("tests.helpers.addon_loader")

local function with_addon(callback)
    loader.with_globals({
        JanisTheme = false,
        SlashCmdList = {},
        WOW_PROJECT_MAINLINE = 1,
        WoWGeneralGoldTrackerDB = {},
        time = function() return 1710000000 end,
        date = os.date,
        GGTTSMRealmDataSettings = false,
        CreateFrame = function() return { SetScript = function() end, RegisterEvent = function() end } end,
        C_AddOns = {},
    }, function()
        C_AddOns.LoadAddOn = function(name)
            error("Unexpected separate addon load: " .. name)
        end
        local ns = { GoldTracker = { SetScript = function() end, RegisterEvent = function() end } }
        for line in io.lines("General-Gold-Tracker.toc") do
            line = line:gsub("\r", "")
            if line:match("^[^#].*%.lua$") then
                assert(loadfile(line))("General-Gold-Tracker", ns)
            end
        end
        callback(ns.GoldTracker, ns)
    end)
end

describe("Bundled catalogs", function()
    it("opens and refreshes Favorites without restoring unrelated scans", function()
        with_addon(function(addon, ns)
            addon:InitializeDatabase()
            addon:InitializeMemoryStorage()
            -- Saved numeric scan filters must not change Favorites navigation.
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
                assert.is_nil(addon.instanceFarmingFrame)
                assert.is_nil(addon.craftingFarmingFrame)
                assert.is_nil(addon.observedDropsFrame)
                assert.is_nil(addon.myFarmsFrame)
                -- Scan navigation uses the bundled Rares catalog.
                addon:SetExplorerTab("rares")
                addon:OpenRareFarmingNewScan()
            end)
        end)
    end)

    it("opens a favorite material map from bundled data", function()
        with_addon(function(addon, ns)
            addon:InitializeDatabase()
            addon:InitializeMemoryStorage()
            addon:GetFarmingFavoriteStore()["item:2770"] = {
                itemID = 2770, itemName = "Copper Ore", itemLink = "item:2770",
                farmingSourceType = "material", expansionLabel = "Classic",
            }
            require("tests.helpers.explorer_ui").with_ui(ns, function()
                addon:OpenExplorerWindow()
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
            end)
        end)
    end)

    it("keeps bundled catalogs available through database initialization and automatic price work", function()
        with_addon(function(addon, ns)
            addon:InitializeDatabase()
            addon:InitializeMemoryStorage()
            local candidates = addon:BuildKnownPriceScanCandidates()
            assert.is_true(#candidates > 0)
            addon:StartKnownPriceScan()
            addon:BuildPriceIncreaseAlertRows()
            addon:HasInventoryMaterialFarmingMap(2770)
        end)
    end)

    it("shares recipe rows with their bundled farm guides", function()
        with_addon(function(_,ns)
            assert.equals(23,#ns.RecipeDropsData.rows)
            assert.equals(23,#ns.RecipeFarmData.farms)
        end)
    end)

    it("shares cosmetic rows with their bundled farm guides", function()
        with_addon(function(_,ns)
            assert.equals(219,#ns.CosmeticDropsData.rows)
            assert.equals(219,#ns.CosmeticFarmData.farms)
        end)
    end)

    it("preserves cross-catalog augmentation in the main namespace", function()
        with_addon(function(_, ns)
            local rares = ns.RareDropsData
            assert.is_table(rares)
            assert.equals(rares, ns.RareDropsData)
            assert.is_table(ns.InstanceDropsData.instances)
            assert.is_table(ns.ATTBoEDropsData)
            assert.is_table(ns.InstanceLocationResearch)
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
            assert.is_table(ns.MaterialFarmingSpots.items[2770])
            assert.is_table(ns.MaterialFarmingSpots.coverage)
            assert.is_table(ns.CatalogGatheringData)
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

    it("keeps tab selection independent of bundled data and preserves saved choices", function()
        with_addon(function(addon, ns)
            local saved = { welcomeCompleted = true, module_materials = false, module_inventory = false }
            loader.with_globals({ WoWGeneralGoldTrackerDB = saved }, function() addon:InitializeDatabase() end)
            assert.is_false(addon:NeedsWelcomeSetup())
            assert.is_false(addon:IsModuleEnabled("materials"))
            assert.is_false(addon:IsModuleEnabled("inventory"))
            local materials, farms = ns.MaterialFarmingSpots, ns.FarmCatalog
            addon:SetModuleEnabled("materials", true)
            assert.is_true(addon:IsModuleEnabled("materials"))
            assert.equals(materials, ns.MaterialFarmingSpots)
            assert.equals(farms, ns.FarmCatalog)
            assert.is_false(addon:IsModuleEnabled("inventory"))
        end)
    end)

    it("renders Materials, Bags, and Market Watch from the single addon", function()
        with_addon(function(addon, ns)
            addon:InitializeDatabase()
            addon:InitializeMemoryStorage()
            require("tests.helpers.explorer_ui").with_ui(ns, function()
                addon:OpenExplorerWindow()
                addon:SetExplorerTab("materials")
                local materials = addon.craftingFarmingFrame
                assert.is_true(#materials.materialDisplayRows > 0)
                assert.is_true(materials.rows[1]:IsShown())

                addon.BuildInventoryAuctionItemList = function()
                    return { { itemID = 2770, itemLink = "item:2770", itemName = "Copper Ore",
                        quantity = 2, unitValue = 10000, totalValue = 20000 } }, 20000, 2, 1, 1
                end
                addon:SetExplorerTab("inventory")
                assert.equals(2770, addon.inventoryFrame.inventoryRows[1].itemID)
                assert.is_true(addon.inventoryFrame.inventoryRows[1]:IsShown())

                addon.BuildPriceAlertRows = function()
                    return { { itemID = 2770, itemLink = "item:2770", itemName = "Copper Ore",
                        quantity = 2, unitValue = 10000, totalValue = 20000, changePercent = 40 } }, {}
                end
                addon:SetExplorerTab("priceAlerts")
                assert.equals(2770, addon.priceIncreaseAlertsFrame.rows[1].itemID)
                assert.is_true(addon.priceIncreaseAlertsFrame.rows[1]:IsShown())
            end)
        end)
    end)

end)
