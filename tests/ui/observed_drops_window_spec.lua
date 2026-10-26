local loader = require("tests.helpers.addon_loader")

local function build_addon()
    local item_links = {
        [1001] = "|cff1eff00|Hitem:1001::::::::|h[Observed Green]|h|r",
        [1002] = "|cff1eff00|Hitem:1002::::::::|h[Expensive Green]|h|r",
        [1003] = "|cff1eff00|Hitem:1003::::::::|h[Cheap Green]|h|r",
    }
    local item_names = {
        [1001] = "Observed Green",
        [1002] = "Expensive Green",
        [1003] = "Cheap Green",
    }
    local selected_values = {
        [1001] = 400000,
        [1002] = 900000,
        [1003] = 1000,
    }

    local addon = {
        db = {
            observedWorldDropsValueSource = "TSM_DBMARKET",
            observedWorldDrops = {
            },
            observedSavedSessionDropsScannedAt = 1710000000,
            observedSavedSessionDrops = {
                ["i:1001"] = {
                    itemKey = "i:1001",
                    itemID = 1001,
                    itemLink = item_links[1001],
                    itemQuality = 2,
                    totalQuantity = 3,
                    seenCount = 2,
                    lastLocationLabel = "Elwynn Forest 42.0,51.0",
                    lastExpansionID = 0,
                    lastExpansionName = "Classic",
                    lastSourceText = "Test Gnoll",
                    lastSourceName = "Test Gnoll",
                },
                ["i:1002"] = {
                    itemKey = "i:1002",
                    itemID = 1002,
                    itemLink = item_links[1002],
                    itemQuality = 2,
                    totalQuantity = 1,
                    seenCount = 1,
                    lastLocationLabel = "Deepholm 58.6,51.2",
                    lastExpansionID = 3,
                    lastExpansionName = "Cataclysm",
                    lastSourceText = "Stone Trogg",
                    lastSourceName = "Stone Trogg",
                },
                ["i:1003"] = {
                    itemKey = "i:1003",
                    itemID = 1003,
                    itemLink = item_links[1003],
                    itemQuality = 2,
                    totalQuantity = 1,
                    seenCount = 1,
                    lastLocationLabel = "Westfall 10.0,20.0",
                    lastExpansionID = 0,
                    lastExpansionName = "Classic",
                    lastSourceText = "Tiny Murloc",
                    lastSourceName = "Tiny Murloc",
                },
            },
        },
        VALUE_SOURCE_BY_ID = {
            TSM_DBMARKET = {
                id = "TSM_DBMARKET",
                label = "Market Value",
                tsmKey = "DBMarket",
            },
        },
        observedDropsFrame = {
            expansionFilterID = "all",
            minimumValueCopper = 100000,
            itemCache = {},
            priceCache = {},
            sortKey = "value",
            sortAscending = false,
        },
        NormalizeObservedWorldDrops = function(self)
            return self.db.observedWorldDrops
        end,
        NormalizeObservedSavedSessionDrops = function(self)
            return self.db.observedSavedSessionDrops
        end,
        GetAuctionableInventoryValueSource = function(self)
            return self.VALUE_SOURCE_BY_ID.TSM_DBMARKET
        end,
        GetItemUnitValueFromSource = function(_, _, item_link)
            local item_id = tonumber(string.match(item_link or "", "item:(%d+)"))
            return selected_values[item_id] or 0
        end,
        GetTSMRawCustomValue = function(_, source)
            return ({
                DBMarket = 500000,
                DBHistorical = 600000,
                DBRegionMarketAvg = 700000,
                DBRegionSaleAvg = 300000,
            })[source]
        end,
        IsFarmingItemFavorite = function(_, row)
            return row.itemID == 1002
        end,
    }

    return addon, item_links, item_names
end

local function load_window(addon, item_links, item_names, ns_overrides)
    return loader.with_globals({
        C_Map = {
            GetMapInfo = function(map_id)
                return ({ [37] = { name = "Elwynn Forest" } })[map_id]
            end,
        },
        GetItemInfo = function(item_id)
            return item_names[item_id], item_links[item_id], 2, nil, nil, nil, nil, nil, nil, "icon-" .. item_id
        end,
        GetItemInfoInstant = function(item_id)
            return nil, nil, nil, nil, "icon-" .. item_id
        end,
    }, function()
        return loader.load_module("UI/ObservedDropsWindow.lua", addon, ns_overrides)
    end)
end

local function project_rows(rows)
    local projected = {}
    for _, row in ipairs(rows) do
        projected[#projected + 1] = {
            itemID = row.itemID,
            itemName = row.itemName,
            expansionLabel = row.expansionLabel,
            locationLabel = row.locationLabel,
            sourceText = row.sourceText,
            seenCount = row.seenCount,
            quantity = row.quantity,
            value = row.value,
            marketValue = row.marketValue,
            regionMarketValue = row.regionMarketValue,
            averageValue = row.averageValue,
            tracked = row.tracked,
        }
    end
    return projected
end

describe("UI/ObservedDropsWindow row snapshots", function()
    local function load_loot_map_window()
        local addon, links, names = build_addon()
        addon.GetItemIDFromLink = function(_, link) return tonumber((link or ""):match("item:(%d+)")) end
        addon.GetTSMItemStringFromLink = function(_, link)
            local itemID = (link or ""):match("item:(%d+)")
            return itemID and ("i:" .. itemID)
        end
        addon = loader.load_module("Tracking/ObservedDrops.lua", addon)
        return load_window(addon, links, names, { JanisTheme = {} })
    end

    it("refreshes visible Session Observed automatically before any saved-session scan", function()
        local addon, ns = load_loot_map_window()
        addon.db.observedSavedSessionDrops = {}
        addon.db.observedSavedSessionDropsScannedAt = nil
        local frame = addon.observedDropsFrame
        frame.dropSourceID = "observed"
        frame.observedDropsViewID = "scan"
        frame.IsShown = function() return true end
        local refreshed = 0
        addon.RefreshObservedDropsWindow = function() refreshed = refreshed + 1 end
        require("tests.helpers.explorer_ui").with_ui(ns, function()
            loader.with_globals({ time = function() return 1710000001 end }, function()
                assert.is_true(addon:RecordObservedWorldDrop(
                    "|Hitem:1001:|h[Observed Green]|h", 2, 2, false, false, { kind = "Unit" },
                    { mapID = 37, mapX = 0.42, mapY = 0.51 }, { selectedUnitValue = 400000 }
                ))
                assert.equals(1, refreshed)
                assert.is_true(frame.hasObservedDropsScanRun)
                assert.equals(1, #frame.scannedObservedDropsRows)
                assert.equals(1001, frame.scannedObservedDropsRows[1].itemID)
                assert.equals(2, frame.scannedObservedDropsRows[1].quantity)
                assert.is_nil(addon.db.observedSavedSessionDropsScannedAt)
                frame.dropSourceID = "att-zones"
                addon:RecordObservedWorldDrop("|Hitem:1002:|h[Expensive Green]|h", 1, 2, false, false, { kind = "Unit" })
                assert.equals(1, refreshed)
                assert.equals(1, addon.db.observedSavedSessionDrops["i:1002"].totalQuantity)
            end)
        end)
    end)

    it("opens recorded loot pins on their own maps and leaves missing coordinates unpinned", function()
        local addon = load_loot_map_window()
        local drop = addon.db.observedSavedSessionDrops["i:1001"]
        drop.lastMapID = 37
        drop.lootLocations = {
            { mapID = 37, mapX = 0.42, mapY = 0.51, sourceText = "Test Gnoll" },
            { mapID = 225, mapName = "Stockade" },
        }
        addon.db.sessionHistory = { { itemLoots = {
            { itemLink = drop.itemLink, lootSourceType = "Unit", mapID = 100, mapX = 0.3, mapY = 0.4 },
            { itemLink = drop.itemLink, lootSourceType = "Unit", mapID = 37, mapX = 0.42, mapY = 0.51 },
        } } }
        local row = { observedDropKey = "i:1001", itemID = 1001, itemName = "Observed Green" }
        local opened
        addon.OpenStandaloneMapWindow = function(_, options) opened = options end
        assert.is_true(addon:OpenObservedDropLootMap(row))
        assert.equals("observed:i:1001", opened.projectionKey)
        assert.equals(row, opened.customFarmRow)
        assert.equals(3, #opened.mapOptions)
        assert.equals(37, opened.mapOptions[1].mapID)
        assert.equals(1, #opened.mapOptions[1].pins)
        assert.equals(0.42, opened.mapOptions[1].pins[1].x)
        assert.equals(0.51, opened.mapOptions[1].pins[1].y)
        assert.equals("Looted here from Test Gnoll.", opened.mapOptions[1].pins[1].tips[1])
        assert.equals(100, opened.mapOptions[2].mapID)
        assert.equals(0.3, opened.mapOptions[2].pins[1].x)
        assert.is_true(opened.mapOptions[3].mapOnly)
        assert.equals(0, #opened.mapOptions[3].pins)

        addon.Print = function(_, message) assert.matches("No loot map", message) end
        assert.is_false(addon:OpenObservedDropLootMap({ observedDropKey = "missing" }))
    end)

    it("keeps Add beside the loot Map button and resets Map visibility when rows are reused", function()
        local addon, ns = load_loot_map_window()
        require("tests.helpers.explorer_ui").with_ui(ns, function()
            local frame = addon.observedDropsFrame
            frame.content = CreateFrame("Frame")
            frame.listPanel = CreateFrame("Frame")
            frame.scrollFrame = CreateFrame("ScrollFrame")
            frame.mapHeaderButton = CreateFrame("Button")
            frame.dropSourceID = "observed"
            local row = addon:GetObservedDropsWindowRow(1)
            local clickedKey
            addon.OpenObservedDropLootMap = function(_, target) clickedKey = target.observedDropKey end
            row.observedDropKey = "i:1001"
            addon:RefreshObservedDropsWindowLayout()
            assert.is_true(row.mapButton:IsShown())
            assert.is_true(row.addButton:IsShown())
            assert.is_true(frame.mapHeaderButton:IsShown())
            assert.is_function(row.addButton:GetScript("OnClick"))
            row.mapButton:GetScript("OnClick")(row.mapButton)
            assert.equals("i:1001", clickedKey)
            row.observedDropKey = "i:1002"
            row.mapButton:GetScript("OnClick")(row.mapButton)
            assert.equals("i:1002", clickedKey)
            frame.dropSourceID = "att-zones"
            addon:RefreshObservedDropsWindowLayout()
            assert.is_false(row.mapButton:IsShown())
            assert.is_false(frame.mapHeaderButton:IsShown())
            frame.dropSourceID = "observed"
            addon:RefreshObservedDropsWindowLayout()
            assert.is_true(row.mapButton:IsShown())
            row.isLocationGroupHeader = true
            addon:RefreshObservedDropsWindowLayout()
            assert.is_false(row.mapButton:IsShown())
        end)
    end)

    it("opens exact researched maps for every new AH toy and preserves all pin metadata", function()
        local addon, item_links, item_names = build_addon()
        local ns = {}
        for _, path in ipairs({
            "Data/General-Gold-Tracker_Drops/CatalogDrops.lua",
            "Data/General-Gold-Tracker_Farms/ToyAcquisitionResearch.lua",
            "Data/General-Gold-Tracker_Farms/ToyFarms.lua",
        }) do assert(loadfile(path))("General-Gold-Tracker", ns) end
        addon = loader.load_module("UI/FarmDetailsWindow.lua", addon, ns)
        addon = load_window(addon, item_links, item_names, ns)
        addon.observedDropsFrame.dropSourceID = "catalog-toys"
        local visible = {}
        for _, row in ipairs(addon:BuildObservedDropsRows()) do visible[row.itemID] = row end
        local openedFarmID
        addon.OpenFarmDetails = function(_, farmID) openedFarmID = farmID; return true end
        for _, research in ipairs(ns.ToyAcquisitionResearch) do
            local row = visible[research.itemID]
            assert.is_table(row, "new toy missing from Drops: " .. research.itemName)
            assert.equals(research.itemName, row.itemName)
            assert.equals(research.expansionLabel, row.expansionLabel)
            local farm = addon:GetFarmsForRecordID(row.observedDropKey)[1]
            assert.equals(research.itemID, farm.primaryItemID)
            local scripts = {}
            local button = {
                SetText = function() end,
                SetScript = function(_, event, callback) scripts[event] = callback end,
                GetParent = function() return row end,
            }
            assert.equals("map", addon:ConfigureObservedDropRowActionButton(button, row, "catalog-toys"))
            scripts.OnClick(button)
            assert.equals(farm.id, openedFarmID)
            local options = addon:BuildFarmRouteMapOptions(farm)
            assert.equals(#research.mapOptions, #options)
            for index, option in ipairs(options) do
                assert.equals(research.mapOptions[index].mapID, option.mapID)
                assert.equals(research.mapOptions[index].mapRole, option.mapRole)
                assert.equals(#research.mapOptions[index].pins, #option.pins)
                for pinIndex, pin in ipairs(option.pins) do
                    local source = research.mapOptions[index].pins[pinIndex]
                    assert.equals(source.x, pin.x)
                    assert.equals(source.y, pin.y)
                    assert.equals(source.label, pin.label)
                    assert.equals("farm-toy", pin.routeType)
                    assert.is_false(pin.isRoute)
                    assert.same(research.sourceUrls, pin.sourceUrls)
                    assert.same(research.tips, pin.tips)
                    assert.equals(research.action, pin.farmAction)
                end
            end
        end
    end)

    it("opens researched maps for all new AH mounts through the actual row action", function()
        local addon, item_links, item_names = build_addon()
        local ns = {}
        for _, path in ipairs({
            "Data/General-Gold-Tracker_Drops/CatalogDrops.lua",
            "Data/General-Gold-Tracker_Farms/MountAcquisitionResearch.lua",
            "Data/General-Gold-Tracker_Farms/MountFarms.lua",
        }) do assert(loadfile(path))("General-Gold-Tracker", ns) end
        addon = loader.load_module("UI/FarmDetailsWindow.lua", addon, ns)
        addon = load_window(addon, item_links, item_names, ns)
        addon.observedDropsFrame.dropSourceID = "catalog-mounts"
        local visible = {}
        for _, row in ipairs(addon:BuildObservedDropsRows()) do visible[row.itemID] = row end
        local openedFarmID
        addon.OpenFarmDetails = function(_, farmID) openedFarmID = farmID; return true end
        for _, research in ipairs(ns.MountAcquisitionResearch) do
            local row = visible[research.itemID]
            assert.is_table(row, "new mount missing from Drops: " .. research.itemName)
            assert.equals(research.itemName, row.itemName)
            assert.equals(research.expansionLabel, row.expansionLabel)
            local farm = addon:GetFarmsForItem(row.itemID)[1]
            local scripts = {}
            local button = {
                SetText = function() end,
                SetScript = function(_, event, callback) scripts[event] = callback end,
                GetParent = function() return row end,
            }
            assert.equals("map", addon:ConfigureObservedDropRowActionButton(button, row, "catalog-mounts"))
            scripts.OnClick(button)
            assert.equals(farm.id, openedFarmID)
            local options = addon:BuildFarmRouteMapOptions(farm)
            assert.equals(#research.mapOptions, #options)
            for index, option in ipairs(options) do
                assert.equals(research.mapOptions[index].mapID, option.mapID)
                assert.equals(research.mapOptions[index].mapRole, option.mapRole)
                assert.equals(#research.mapOptions[index].pins, #option.pins)
                for pinIndex, pin in ipairs(option.pins) do
                    local source = research.mapOptions[index].pins[pinIndex]
                    assert.equals(source.x, pin.x)
                    assert.equals(source.y, pin.y)
                    assert.equals(source.label, pin.label)
                    assert.equals("farm-mount", pin.routeType)
                    assert.is_false(pin.isRoute)
                    assert.same(research.sourceUrls, pin.sourceUrls)
                    assert.same(research.tips, pin.tips)
                    assert.equals(research.action, pin.farmAction)
                end
            end
        end
    end)

    it("opens the exact farm map for every new AH pet and retains expansion labels", function()
        local addon, item_links, item_names = build_addon()
        local ns = {}
        for _, path in ipairs({
            "Data/General-Gold-Tracker_Drops/CatalogDrops.lua",
            "Data/General-Gold-Tracker_Farms/PetAcquisitionResearch.lua",
            "Data/General-Gold-Tracker_Farms/PetFarms.lua",
        }) do assert(loadfile(path))("General-Gold-Tracker", ns) end
        addon = loader.load_module("UI/FarmDetailsWindow.lua", addon, ns)
        addon = load_window(addon, item_links, item_names, ns)
        addon.observedDropsFrame.dropSourceID = "catalog-pets"
        addon.observedDropsFrame.minimumValueCopper = 0
        addon.observedDropsFrame.expansionFilterID = "all"
        local visible = {}
        for _, row in ipairs(addon:BuildObservedDropsRows()) do visible[row.petID] = row end
        local openedFarmID
        addon.OpenFarmDetails = function(_, farmID) openedFarmID = farmID; return true end
        for _, research in ipairs(ns.PetAcquisitionResearch) do
            local row = visible[research.petID]
            assert.is_table(row, "new pet missing from Drops: " .. research.itemName)
            assert.equals(research.expansionLabel, row.expansionLabel)
            local farm = addon:GetFarmsForPet(row.petID)[1]
            local scripts = {}
            local button = {
                SetText = function() end,
                SetScript = function(_, event, callback) scripts[event] = callback end,
                GetParent = function() return row end,
            }
            assert.equals("map", addon:ConfigureObservedDropRowActionButton(button, row, "catalog-pets"))
            scripts.OnClick(button)
            assert.equals(farm.id, openedFarmID)
            local options = addon:BuildFarmRouteMapOptions(farm)
            assert.equals(#research.spots, #options)
            for index, option in ipairs(options) do
                assert.equals(research.spots[index].mapID, option.mapID)
                assert.equals(#research.spots[index].coords, #option.pins)
                if research.spots[index].mapOnly then
                    assert.is_true(option.mapOnly)
                    assert.equals("profession-context",option.mapRole)
                else
                    assert.equals("farm-pet", option.pins[1].routeType)
                    assert.is_false(option.pins[1].isRoute)
                end
            end
        end
    end)

    it("uses Blizzard's battle-pet tooltip for Drops Pets rows", function()
        local addon, item_links, item_names = build_addon()
        addon = load_window(addon, item_links, item_names)
        local owner
        local shownLink

        loader.with_globals({
            GameTooltip = {
                SetOwner = function(_, target, anchor) owner = { target, anchor } end,
            },
            BattlePetToolTip_ShowLink = function(link) shownLink = link end,
        }, function()
            assert.is_true(addon:ShowObservedDropItemTooltip({
                itemID = 82800,
                petID = 59,
                itemLink = "|cff0070dd|Hbattlepet:59:1:3:161:10:11:0|h[Emerald Whelpling]|h|r",
            }, "pet-row"))
        end)

        assert.same({ "pet-row", "ANCHOR_CURSOR" }, owner)
        assert.is_truthy(string.find(shownLink, "battlepet:59", 1, true))
    end)

    it("shows a direct researched Map action for Mounts rows", function()
        local addon, item_links, item_names = build_addon()
        addon.HasFarmForItem = function(_, itemID)
            return itemID == 163575, itemID == 163575 and 1 or 0
        end
        local openedItemID
        addon.OpenFarmDetailsForItem = function(_, itemID)
            openedItemID = itemID
            return true
        end
        addon = load_window(addon, item_links, item_names)

        local row = { itemID = 163575 }
        local scripts = {}
        local button = {
            SetText = function(self, text) self.text = text end,
            SetPalette = function(self, palette) self.palette = palette end,
            SetScript = function(_, event, callback) scripts[event] = callback end,
            GetParent = function() return row end,
        }

        assert.equals("map", addon:ConfigureObservedDropRowActionButton(button, row, "catalog-mounts"))
        assert.equals("Map", button.text)
        assert.equals("primary", button.palette)
        scripts.OnClick(button)
        assert.equals(163575, openedItemID)
    end)

    it("uses pet identity for researched Pets rows and item identity for collateral rows", function()
        local addon, item_links, item_names = build_addon()
        addon.HasFarmForPet = function(_, petID)
            return petID == 59, petID == 59 and 1 or 0
        end
        addon.HasFarmForItem = function(_, itemID)
            return itemID == 19019, itemID == 19019 and 1 or 0
        end
        addon.HasFarmForRecordID = function(_, recordID)
            return recordID == "pets:MoltenCoreRaid:1", recordID == "pets:MoltenCoreRaid:1" and 1 or 0
        end
        local openedPetID
        local openedItemID
        local openedRecordID
        addon.OpenFarmDetailsForPet = function(_, petID)
            openedPetID = petID
            return true
        end
        addon.OpenFarmDetailsForItem = function(_, itemID)
            openedItemID = itemID
            return true
        end
        addon.OpenFarmDetailsForRecordID = function(_, recordID)
            openedRecordID = recordID
            return true
        end
        addon = load_window(addon, item_links, item_names)

        local petRow = { itemID = 82800, petID = 59 }
        local petScripts = {}
        local petButton = {
            SetText = function(self, text) self.text = text end,
            SetPalette = function(self, palette) self.palette = palette end,
            SetScript = function(_, event, callback) petScripts[event] = callback end,
            GetParent = function() return petRow end,
        }
        assert.equals("map", addon:ConfigureObservedDropRowActionButton(petButton, petRow, "catalog-pets"))
        petScripts.OnClick(petButton)
        assert.equals(59, openedPetID)
        assert.is_nil(openedItemID)

        local itemRow = { itemID = 19019, observedDropKey = "pets:MoltenCoreRaid:1" }
        local itemScripts = {}
        local itemButton = {
            SetText = function(self, text) self.text = text end,
            SetPalette = function(self, palette) self.palette = palette end,
            SetScript = function(_, event, callback) itemScripts[event] = callback end,
            GetParent = function() return itemRow end,
        }
        assert.equals("map", addon:ConfigureObservedDropRowActionButton(itemButton, itemRow, "catalog-pets"))
        itemScripts.OnClick(itemButton)
        assert.equals("pets:MoltenCoreRaid:1", openedRecordID)
        assert.is_nil(openedItemID)
    end)

    it("uses exact Toys, Recipes and Cosmetics record identities for researched Map actions", function()
        for _, source in ipairs({ {id="catalog-toys",recordID="toys:BigRedRayGun:1",itemID=142265},
            {id="catalog-recipes",recordID="recipes:Dragonflight:191544",itemID=191544},
            {id="catalog-cosmetics",recordID="cosmetics:warWithin:225759",itemID=225759} }) do
        local addon, item_links, item_names = build_addon()
        local openedRecordID
        addon.HasFarmForRecordID = function(_, recordID)
            return recordID == source.recordID, recordID == source.recordID and 1 or 0
        end
        addon.OpenFarmDetailsForRecordID = function(_, recordID)
            openedRecordID = recordID
            return true
        end
        addon = load_window(addon, item_links, item_names)

        local row = { itemID = source.itemID, observedDropKey = source.recordID }
        local scripts = {}
        local button = {
            SetText = function(self, text) self.text = text end,
            SetPalette = function(self, palette) self.palette = palette end,
            SetScript = function(_, event, callback) scripts[event] = callback end,
            GetParent = function() return row end,
        }

        assert.equals("map", addon:ConfigureObservedDropRowActionButton(button, row, source.id))
        assert.equals("Map", button.text)
        assert.equals("primary", button.palette)
        scripts.OnClick(button)
        assert.equals(source.recordID, openedRecordID)
        end
    end)

    it("maximizes the Explorer that owns the embedded Zones list", function()
        local addon, item_links, item_names = build_addon()
        local content_frame = {}
        local explorer = {
            contentFrame = content_frame,
        }
        addon.explorerFrame = explorer
        addon.observedDropsFrame.GetParent = function()
            return content_frame
        end
        local toggled_target = nil
        local theme = {
            ToggleWindowMaximized = function(_, target)
                toggled_target = target
                target.goldTrackerIsMaximized = true
                return true
            end,
        }
        addon = load_window(addon, item_links, item_names, {
            JanisTheme = theme,
        })
        addon.RefreshObservedDropsWindowControls = function(self)
            self.controlsRefreshed = true
        end

        assert.is_true(addon:ToggleObservedDropsListMaximized())
        assert.equals(explorer, toggled_target)
        assert.is_true(addon.controlsRefreshed)
    end)

    it("paginates drop results in groups of thirty", function()
        local addon, item_links, item_names = build_addon()
        addon = load_window(addon, item_links, item_names)

        assert.equals(1, addon:GetObservedDropsPageCount(0))
        assert.equals(1, addon:GetObservedDropsPageCount(30))
        assert.equals(2, addon:GetObservedDropsPageCount(31))
        assert.equals(3, addon:GetObservedDropsPageCount(90))
    end)

    it("clamps drop result page navigation and scrolls the new page to the top", function()
        local addon, item_links, item_names = build_addon()
        addon = load_window(addon, item_links, item_names)
        addon.observedDropsFrame.hasObservedDropsScanRun = true
        addon.observedDropsFrame.currentPage = 1
        addon.observedDropsFrame.scannedObservedDropsRows = {}
        for index = 1, 65 do
            addon.observedDropsFrame.scannedObservedDropsRows[index] = { itemID = index }
        end
        local refresh_scroll_to_top
        addon.RefreshObservedDropsWindow = function(_, scroll_to_top)
            refresh_scroll_to_top = scroll_to_top
        end

        addon:SetObservedDropsPage(2)
        assert.equals(2, addon.observedDropsFrame.currentPage)
        assert.is_true(refresh_scroll_to_top)

        addon:SetObservedDropsPage(99)
        assert.equals(3, addon.observedDropsFrame.currentPage)

        addon:SetObservedDropsPage(-10)
        assert.equals(1, addon.observedDropsFrame.currentPage)
    end)

    it("builds stable sorted rows for the observed drops list", function()
        local addon, item_links, item_names = build_addon()
        addon = load_window(addon, item_links, item_names)

        local rows = addon:BuildObservedDropsRows()

        assert.same(require("tests.snapshots.observed_drops_rows"), project_rows(rows))
    end)

    it("keeps a drop when the preferred price is missing but an ordered fallback resolves it", function()
        local addon, item_links, item_names = build_addon()
        addon.ResolveItemUnitValue = function(_, source_id, _, item_id)
            if item_id == 1003 then
                return 250000, "TSM_DBREGIONMARKETAVG", "Region Market Avg", true
            end
            return 400000, source_id, "Market Value", false
        end
        addon = load_window(addon, item_links, item_names)

        local rows = addon:BuildObservedDropsRows()
        local fallback_row
        for _, row in ipairs(rows) do
            if row.itemID == 1003 then
                fallback_row = row
            end
        end

        assert.is_table(fallback_row)
        assert.equals(250000, fallback_row.value)
        assert.equals("TSM_DBREGIONMARKETAVG", fallback_row.valueSourceID)
        assert.is_true(fallback_row.valueSourceWasFallback)
    end)

    it("keeps the observed list empty until saved sessions have been scanned", function()
        local addon, item_links, item_names = build_addon()
        addon.db.observedSavedSessionDrops = {}
        addon.db.observedSavedSessionDropsScannedAt = nil
        addon = load_window(addon, item_links, item_names)

        local rows = addon:BuildObservedDropsRows()

        assert.equals(0, #rows)
    end)

    it("keeps saved-session results out of the shared drop scan library", function()
        local addon, item_links, item_names = build_addon()
        addon.db.observedDropsShared = {
            scanCache = {},
            savedSessionDrops = addon.db.observedSavedSessionDrops,
        }
        addon.db.observedDropsScanCache = addon.db.observedDropsShared.scanCache
        addon = load_window(addon, item_links, item_names, {
            ATTBoEDropsData = {
                expansions = { options = { { id = 1, label = "Classic" } } },
                zones = {
                    [37] = {
                        mapID = 37,
                        expansionID = 1,
                        expansion = "Classic",
                        items = {},
                    },
                },
                world = { items = {} },
            },
        })
        addon.RefreshObservedDropsSavedScansWindow = function() end
        addon.RefreshObservedDropsWindowControls = function() end

        addon.observedDropsFrame.dropSourceID = "observed"
        addon.observedDropsFrame.zoneFilterID = "all"
        addon.observedDropsFrame.scannedObservedDropsRows = addon:BuildObservedDropsRows()
        addon:SaveCurrentObservedDropsScan()

        assert.is_nil(next(addon.db.observedDropsShared.scanCache))

        addon.observedDropsFrame.dropSourceID = "att-zones"
        addon.observedDropsFrame.expansionFilterID = "1"
        addon.observedDropsFrame.zoneFilterID = "37"
        addon.observedDropsFrame.loadedObservedDropsScanCache = nil
        addon.observedDropsFrame.loadedObservedDropsScanCacheKey = nil
        addon.observedDropsFrame.editingObservedDropsScanCacheKey = nil
        addon.observedDropsFrame.scannedObservedDropsRows = { addon.observedDropsFrame.scannedObservedDropsRows[1] }
        addon:SaveCurrentObservedDropsScan()

        local zone_key
        local zone_entry
        for key, entry in pairs(addon.db.observedDropsShared.scanCache) do
            if entry.dropSourceID == "att-zones" then
                zone_key = key
                zone_entry = entry
            end
        end

        assert.equals("att-zones", zone_entry.dropSourceID)
        assert.equals("37", zone_entry.zoneFilterID)
        assert.equals(zone_entry, addon.db.observedDropsShared.scanCache[zone_key])
    end)

    it("applies the expansion filter before building rows", function()
        local addon, item_links, item_names = build_addon()
        addon.observedDropsFrame.expansionFilterID = "4"
        addon = load_window(addon, item_links, item_names)

        local rows = project_rows(addon:BuildObservedDropsRows())

        assert.equals(1, #rows)
        assert.equals("Cataclysm", rows[1].expansionLabel)
        assert.equals("Expensive Green", rows[1].itemName)
    end)

    it("builds zone drop rows from the static snapshot", function()
        local addon, item_links, item_names = build_addon()
        item_links[2001] = "|cff1eff00|Hitem:2001::::::::|h[Static Green]|h|r"
        item_names[2001] = "Static Green"
        addon.observedDropsFrame.dropSourceID = "att-zones"
        addon.observedDropsFrame.zoneFilterID = "37"
        addon.observedDropsFrame.minimumValueCopper = 0

        addon = load_window(addon, item_links, item_names, {
            ATTBoEDropsData = {
                expansions = {
                    options = {
                        { id = 1, label = "Classic" },
                    },
                },
                zones = {
                    [37] = {
                        mapID = 37,
                        expansionID = 1,
                        expansion = "Classic",
                        items = {
                            { itemID = 2001 },
                        },
                    },
                },
                world = { items = {} },
            },
        })

        local rows = project_rows(addon:BuildObservedDropsRows())

        assert.equals(1, #rows)
        assert.equals(2001, rows[1].itemID)
        assert.equals("Zone 37", rows[1].locationLabel)
        assert.equals("Zone Drop", rows[1].sourceText)
    end)

    it("excludes poor-quality items from zone drop rows by default", function()
        local addon, item_links, item_names = build_addon()
        item_links[2001] = "|cff9d9d9d|Hitem:2001::::::::|h[Poor Zone Drop]|h|r"
        item_names[2001] = "Poor Zone Drop"
        item_links[2002] = "|cffffffff|Hitem:2002::::::::|h[Common Zone Drop]|h|r"
        item_names[2002] = "Common Zone Drop"
        addon.observedDropsFrame.dropSourceID = "att-zones"
        addon.observedDropsFrame.zoneFilterID = "37"
        addon.observedDropsFrame.minimumValueCopper = 0
        addon = load_window(addon, item_links, item_names, {
            ATTBoEDropsData = {
                expansions = { options = { { id = 1, label = "Classic" } } },
                zones = {
                    [37] = {
                        mapID = 37,
                        expansionID = 1,
                        expansion = "Classic",
                        items = { { itemID = 2001 }, { itemID = 2002 } },
                    },
                },
                world = { items = {} },
            },
        })

        local rows
        loader.with_globals({
            GetItemInfo = function(item_id)
                local quality = item_id == 2001 and 0 or 1
                return item_names[item_id], item_links[item_id], quality, nil, nil, nil, nil, nil, nil, "icon-" .. item_id
            end,
        }, function()
            rows = addon:BuildObservedDropsRows()
        end)

        assert.equals(1, #rows)
        assert.equals(2002, rows[1].itemID)
    end)

    it("filters zone drop rows by selected expansion", function()
        local addon, item_links, item_names = build_addon()
        item_links[2001] = "|cff1eff00|Hitem:2001::::::::|h[Classic Static]|h|r"
        item_links[30001] = "|cff1eff00|Hitem:30001::::::::|h[Burning Static]|h|r"
        item_names[2001] = "Classic Static"
        item_names[30001] = "Burning Static"
        addon.observedDropsFrame.dropSourceID = "att-zones"
        addon.observedDropsFrame.expansionFilterID = "2"
        addon.observedDropsFrame.zoneFilterID = "all"
        addon.observedDropsFrame.minimumValueCopper = 0

        addon = load_window(addon, item_links, item_names, {
            ATTBoEDropsData = {
                expansions = {
                    options = {
                        { id = 1, label = "Classic" },
                        { id = 2, label = "Burning Crusade" },
                    },
                },
                zones = {
                    [37] = {
                        mapID = 37,
                        expansionID = 1,
                        expansion = "Classic",
                        items = {
                            { itemID = 2001 },
                        },
                    },
                    [100] = {
                        mapID = 100,
                        expansionID = 2,
                        expansion = "Burning Crusade",
                        items = {
                            { itemID = 30001 },
                        },
                    },
                },
                world = { items = {} },
            },
        })

        local rows = project_rows(addon:BuildObservedDropsRows())

        assert.equals(1, #rows)
        assert.equals(30001, rows[1].itemID)
        assert.equals("Burning Crusade", rows[1].expansionLabel)
    end)

    it("adds expansion world drops when a specific zone is selected", function()
        local addon, item_links, item_names = build_addon()
        item_links[31134] = "|cff0070dd|Hitem:31134::::::::|h[Blade of Misfortune]|h|r"
        item_names[31134] = "Blade of Misfortune"
        addon.observedDropsFrame.dropSourceID = "att-zones"
        addon.observedDropsFrame.expansionFilterID = "2"
        addon.observedDropsFrame.zoneFilterID = "100"
        addon.observedDropsFrame.minimumValueCopper = 0

        addon = load_window(addon, item_links, item_names, {
            ATTBoEDropsData = {
                expansions = {
                    options = {
                        { id = 1, label = "Classic" },
                        { id = 2, label = "Burning Crusade" },
                    },
                },
                zones = {
                    [100] = {
                        mapID = 100,
                        expansionID = 0,
                        expansion = "Expansion 0",
                        items = {
                            { itemID = 31347 },
                        },
                    },
                },
                world = {
                    items = {
                        { itemID = 31134, sourceID = 14160, level = 25 },
                    },
                },
            },
        })

        local rows = project_rows(addon:BuildObservedDropsRows())

        local blade_row
        for _, row in ipairs(rows) do
            if row.itemID == 31134 then
                blade_row = row
                break
            end
        end
        assert.is_table(blade_row)
        assert.equals("Burning Crusade", blade_row.expansionLabel)
        assert.equals("Expansion World Drop", blade_row.sourceText)
    end)

    it("filters world drop rows by selected expansion", function()
        local addon, item_links, item_names = build_addon()
        item_links[2001] = "|cff1eff00|Hitem:2001::::::::|h[Classic World]|h|r"
        item_links[30001] = "|cff1eff00|Hitem:30001::::::::|h[Burning World]|h|r"
        item_names[2001] = "Classic World"
        item_names[30001] = "Burning World"
        addon.observedDropsFrame.dropSourceID = "att-world"
        addon.observedDropsFrame.expansionFilterID = "2"
        addon.observedDropsFrame.minimumValueCopper = 0

        addon = load_window(addon, item_links, item_names, {
            ATTBoEDropsData = {
                expansions = {
                    options = {
                        { id = 1, label = "Classic" },
                        { id = 2, label = "Burning Crusade" },
                    },
                },
                zones = {},
                world = {
                    items = {
                        { itemID = 2001, expansionID = 1, expansion = "Classic" },
                        { itemID = 30001, expansionID = 2, expansion = "Burning Crusade" },
                    },
                },
            },
        })

        local rows = project_rows(addon:BuildObservedDropsRows())

        assert.equals(1, #rows)
        assert.equals(30001, rows[1].itemID)
        assert.equals("Burning Crusade", rows[1].expansionLabel)
        assert.equals("World Drop", rows[1].sourceText)
    end)

    it("does not expose the retired Drops Transmogs source", function()
        local addon, item_links, item_names = build_addon()
        addon.observedDropsFrame.dropSourceID = "catalog-transmogs"
        addon.observedDropsFrame.minimumValueCopper = 0

        addon = load_window(addon, item_links, item_names, {
            CatalogDropsData = {
                categories = {
                    transmogs = {
                        {
                            recordID = "transmogs:TestFarm:1",
                            farmID = "TestFarm",
                            farmName = "Test Farm",
                            itemID = 2001,
                            contentID = 1,
                            locationLabel = "Test Dungeon",
                        },
                    },
                },
            },
        })

        local rows = addon:BuildObservedDropsRows()
        local catalogRow
        for _, row in ipairs(rows) do
            if row.farmingSourceType == "catalog-transmogs" then
                catalogRow = row
            end
        end

        assert.is_nil(catalogRow)
    end)

    it("shows all 23 migrated Dragonflight entries when selecting Drops Recipes", function()
        local data = {}
        assert(loadfile("Data/General-Gold-Tracker_Drops/CatalogDrops.lua"))("GGT",data)
        assert(loadfile("Data/General-Gold-Tracker_Drops/Recipes.lua"))("GGT",data)
        local addon, links, names = build_addon()
        for _,item in ipairs(data.RecipeDropsData.rows) do
            names[item.itemID] = item.itemName
            links[item.itemID] = "|Hitem:" .. item.itemID .. "|h[" .. item.itemName .. "]|h"
        end
        addon = load_window(addon,links,names,{CatalogDropsData=data.CatalogDropsData})
        addon.RefreshObservedDropsWindow = function() end
        addon.SetObservedDropsWindowView = function() end
        addon:SetObservedDropsSourceTab("catalog-recipes")
        assert.equals("catalog-recipes",addon.observedDropsFrame.dropSourceID)
        local rows = addon.observedDropsFrame.scannedObservedDropsRows
        assert.equals(23,#rows)
        local seen = {}
        for _,row in ipairs(rows) do
            assert.equals("catalog-recipes",row.farmingSourceType)
            assert.equals("10",row.expansionID)
            assert.is_nil(seen[row.itemID])
            seen[row.itemID] = true
            assert.is_truthy(row.observedDropKey:find("recipes:Dragonflight:",1,true))
        end
    end)

    it("shows all audited Cosmetics once across expansions when selecting the new tab", function()
        local data = {}
        assert(loadfile("Data/General-Gold-Tracker_Drops/CatalogDrops.lua"))("GGT",data)
        assert(loadfile("Data/General-Gold-Tracker_Drops/Cosmetics.lua"))("GGT",data)
        local addon, links, names = build_addon()
        for _,item in ipairs(data.CosmeticDropsData.rows) do
            if item.itemID ~= 225759 then -- Exercise a cold item cache, too.
                names[item.itemID] = item.itemName
                links[item.itemID] = "|Hitem:" .. item.itemID .. "|h[" .. item.itemName .. "]|h"
            end
        end
        addon = load_window(addon,links,names,{CatalogDropsData=data.CatalogDropsData})
        addon.RefreshObservedDropsWindow = function() end
        addon.SetObservedDropsWindowView = function() end
        addon:SetObservedDropsSourceTab("catalog-cosmetics")
        assert.equals("catalog-cosmetics",addon.observedDropsFrame.dropSourceID)
        local rows = addon.observedDropsFrame.scannedObservedDropsRows
        assert.equals(219,#rows)
        local seen,expansions = {},{}
        addon.HasFarmForRecordID = function() error("Rendering Cosmetics must not load Farms") end
        for _,row in ipairs(rows) do
            assert.equals("catalog-cosmetics",row.farmingSourceType)
            assert.is_nil(seen[row.itemID])
            seen[row.itemID] = true
            expansions[row.expansionID] = true
            assert.is_truthy(row.observedDropKey:find("cosmetics:",1,true))
            if row.itemID == 225759 then assert.equals("Coreway Engineer's Forceps",row.itemName) end
            local button = {SetText=function() end,SetPalette=function() end,SetScript=function() end}
            assert.equals("map",addon:ConfigureObservedDropRowActionButton(button,row,"catalog-cosmetics"))
        end
        assert.same({["9"]=true,["10"]=true,["11"]=true,["12"]=true},expansions)
        assert.is_true(seen[225759])
        for _,id in ipairs({260898,260900,260901,260902,260903,260904,260905,260907,260908,
            266384,266386,266387,266388,266393,266396}) do assert.is_true(seen[id]) end
        for _,id in ipairs({238489,238494,262650,262651,266102}) do assert.is_nil(seen[id]) end
    end)

    it("shows Writhing Transmutagen in Drops Pets and opens its exact species guide", function()
        local data = {FarmCatalog={farms={},byID={},indexes={},sourceCounts={}}}
        for _,file in ipairs({"Data/General-Gold-Tracker_Drops/CatalogDrops.lua",
            "Data/General-Gold-Tracker_Farms/PetAcquisitionResearch.lua",
            "Data/General-Gold-Tracker_Farms/PetFarms.lua"}) do
            assert(loadfile(file))("GGT",data)
        end
        local addon,links,names = build_addon()
        addon = load_window(addon,links,names,{CatalogDropsData=data.CatalogDropsData,PetFarmData=data.PetFarmData})
        addon.RefreshObservedDropsWindow = function() end
        addon.SetObservedDropsWindowView = function() end
        addon:SetObservedDropsSourceTab("catalog-pets")
        local found,count = nil,0
        for _,row in ipairs(addon.observedDropsFrame.scannedObservedDropsRows) do
            if row.petID == 4482 then found,count = row,count + 1 end
        end
        assert.equals(1,count)
        assert.equals("Writhing Transmutagen",found.itemName)
        assert.equals("11",found.expansionID)
        assert.equals("catalog-pets",found.farmingSourceType)
        local opened,scripts = nil,{}
        addon.HasFarmForPet = function(_,id) return id == 4482 end
        addon.OpenFarmDetailsForPet = function(_,id) opened = id end
        local button = {SetText=function() end,SetPalette=function() end,
            SetScript=function(_,event,callback) scripts[event] = callback end,GetParent=function() return found end}
        assert.equals("map",addon:ConfigureObservedDropRowActionButton(button,found,"catalog-pets"))
        scripts.OnClick(button)
        assert.equals(4482,opened)
    end)

    it("always loads every Catalog collectible without applying scan filters", function()
        for _, source in ipairs({
            { id = "catalog-mounts", category = "mounts", itemID = 2001 },
            { id = "catalog-toys", category = "toys", itemID = 30001 },
            { id = "catalog-recipes", category = "recipes", itemID = 191544 },
            { id = "catalog-cosmetics", category = "cosmetics", itemID = 225759 },
        }) do
            local addon, item_links, item_names = build_addon()
            item_links[source.itemID] = "|cff0070dd|Hitem:" .. source.itemID .. "::::::::|h[Catalog Collectible]|h|r"
            item_names[source.itemID] = "Catalog Collectible"
            addon.observedDropsFrame.expansionFilterID = "12"
            addon.observedDropsFrame.minimumValueCopper = 99999999
            addon = load_window(addon, item_links, item_names, {
                CatalogDropsData = {
                    categories = {
                        [source.category] = {
                            {
                                recordID = source.category .. ":Test:1",
                                farmID = "Test",
                                farmName = "Test Collectible",
                                itemID = source.itemID,
                                contentID = 1,
                                locationLabel = "Test Location",
                            },
                        },
                    },
                },
            })
            addon.RefreshObservedDropsWindow = function() end
            addon.SetObservedDropsWindowView = function() end

            addon:SetObservedDropsSourceTab(source.id)

            assert.is_true(addon.observedDropsFrame.hasObservedDropsScanRun)
            assert.equals(1, #addon.observedDropsFrame.scannedObservedDropsRows)
            assert.equals(source.itemID, addon.observedDropsFrame.scannedObservedDropsRows[1].itemID)
        end
    end)

    it("resolves pet continents from researched maps and exterior raid entrances", function()
        local addon, item_links, item_names = build_addon()
        addon.observedDropsFrame.dropSourceID = "catalog-pets"
        addon = load_window(addon, item_links, item_names, {
            PetFarmData = {
                rows = {
                    { recordID = "outdoor", itemID = 1001, locationID = 357, locationLabel = "Feralas" },
                    { recordID = "raid", itemID = 1002, locationLabel = "Blackwing Lair" },
                    { recordID = "detached", itemID = 1003, mapID = 407, locationLabel = "Darkmoon Island" },
                    { recordID = "missing", itemID = 1001, locationLabel = "Unmapped" },
                    { recordID = "cycle", itemID = 1001, mapID = 900, locationLabel = "Cycle" },
                },
                farms = {
                    { sourceRecordID = "outdoor", mapOptions = { { mapID = 69 } } },
                    { sourceRecordID = "raid", mapOptions = {
                        { mapID = 287, mapRole = "boss" },
                        { mapID = 36, mapRole = "entrance" },
                    } },
                },
            },
        })
        local maps = {
            [69] = { name = "Feralas", mapType = 3, parentMapID = 12 },
            [12] = { name = "Kalimdor", mapType = 2, parentMapID = 947 },
            [36] = { name = "Burning Steppes", mapType = 3, parentMapID = 13 },
            [13] = { name = "Eastern Kingdoms", mapType = 2, parentMapID = 947 },
            [287] = { name = "Blackwing Lair", mapType = 4, parentMapID = 0 },
            [407] = { name = "Darkmoon Island", mapType = 3, parentMapID = 947 },
            [947] = { name = "Azeroth", mapType = 1, parentMapID = 0 },
            [900] = { parentMapID = 901 },
            [901] = { parentMapID = 900 },
        }
        local rows = loader.with_globals({ C_Map = { GetMapInfo = function(mapID)
            assert.is_not.equals(357, mapID, "area IDs must not be used as UI map IDs")
            return maps[mapID]
        end } }, function()
            return addon:BuildObservedDropsRows()
        end)
        local byRecordID = {}
        for _, row in ipairs(rows) do byRecordID[row.observedDropKey] = row end

        assert.equals(5, #rows)
        assert.equals("Kalimdor", byRecordID.outdoor.continentLabel)
        assert.equals("Eastern Kingdoms", byRecordID.raid.continentLabel)
        assert.equals("Darkmoon Island", byRecordID.detached.continentLabel)
        assert.equals("Unknown continent", byRecordID.missing.continentLabel)
        assert.equals("Unknown continent", byRecordID.cycle.continentLabel)
    end)

    it("nests collapsed pet locations under continents and preserves child state when a continent closes", function()
        local addon, item_links, item_names = build_addon()
        addon = load_window(addon, item_links, item_names)
        local frame = addon.observedDropsFrame
        frame.dropSourceID = "catalog-pets"
        local rows = {
            { itemID = 1, continentLabel = "Eastern Kingdoms", locationLabel = "Badlands 10.0,20.0" },
            { itemID = 2, continentLabel = "Eastern Kingdoms", locationLabel = "Badlands 30.0,40.0" },
            { itemID = 3, continentLabel = "Kalimdor", locationLabel = "Feralas" },
            { itemID = 4, continentLabel = "Kalimdor", locationLabel = "Winterspring" },
        }

        local display = addon:BuildObservedDropsDisplayRows(rows)
        assert.equals(2, #display)
        assert.is_true(display[1].isContinentGroupHeader)
        assert.equals("Eastern Kingdoms", display[1].locationGroupLabel)
        assert.equals(2, display[1].itemCount)
        assert.equals("Kalimdor", display[2].locationGroupLabel)

        frame.collapsedContinentGroups = { ["continent:eastern kingdoms"] = false }
        display = addon:BuildObservedDropsDisplayRows(rows)
        assert.equals(3, #display)
        assert.equals("Badlands", display[2].locationGroupLabel)
        assert.equals(2, display[2].itemCount)
        assert.is_true(display[2].collapsed)
        assert.is_nil(display[2].isContinentGroupHeader)

        frame.collapsedLocationGroups = { [display[2].locationGroupKey] = false }
        display = addon:BuildObservedDropsDisplayRows(rows)
        assert.equals(5, #display)
        assert.equals(rows[1], display[3])
        assert.equals(rows[2], display[4])
        assert.equals("Kalimdor", display[5].locationGroupLabel)

        addon:ToggleLocationGroupCollapsed(frame.collapsedContinentGroups, display[1].locationGroupKey, false)
        assert.equals(2, #addon:BuildObservedDropsDisplayRows(rows))
        addon:ToggleLocationGroupCollapsed(frame.collapsedContinentGroups, display[1].locationGroupKey, true)
        assert.equals(5, #addon:BuildObservedDropsDisplayRows(rows))
    end)

    it("keeps pet location states independent between continents and retains the flat-list option", function()
        local addon, item_links, item_names = build_addon()
        addon = load_window(addon, item_links, item_names)
        local frame = addon.observedDropsFrame
        frame.dropSourceID = "catalog-pets"
        frame.collapsedContinentGroups = { ["continent:kalimdor"] = false, ["continent:northrend"] = false }
        frame.collapsedLocationGroups = { ["continent:kalimdor:shared location"] = false }
        local rows = {
            { itemID = 1, continentLabel = "Kalimdor", locationLabel = "Shared Location" },
            { itemID = 2, continentLabel = "Northrend", locationLabel = "Shared Location" },
        }

        local display = addon:BuildObservedDropsDisplayRows(rows)
        assert.equals(5, #display)
        assert.equals(rows[1], display[3])
        assert.is_true(display[5].collapsed)
        assert.is_not.equals(display[2].locationGroupKey, display[5].locationGroupKey)

        addon:SetCollapsedLocationHeadersEnabled(false)
        assert.equals(rows, addon:BuildObservedDropsDisplayRows(rows))
        addon:SetCollapsedLocationHeadersEnabled(true)
        frame.dropSourceID = "catalog-mounts"
        assert.equals(rows, addon:BuildObservedDropsDisplayRows(rows))
    end)

    it("exposes Catalog pets as an always-visible Drops source with pet identity retained", function()
        local addon, item_links, item_names = build_addon()
        addon = load_window(addon, item_links, item_names, {
            CatalogDropsData = {
                categories = {
                    pets = {
                        {
                            recordID = "pets:Whelpling:1",
                            farmID = "Whelpling",
                            farmName = "Emerald Whelpling",
                            itemID = 82800,
                            itemLink = "|cff0070dd|Hbattlepet:1150:1:3:152:13:10:0000000000000000:6291|h[Abyssius]|h|r",
                            petID = 1624,
                            quantity = 1,
                            contentID = 1,
                            locationLabel = "Feralas",
                        },
                    },
                },
            },
        })
        addon.RefreshObservedDropsWindow = function() end
        addon.SetObservedDropsWindowView = function() end

        addon:SetObservedDropsSourceTab("catalog-pets")

        assert.equals("catalog-pets", addon.observedDropsFrame.dropSourceID)
        assert.is_true(addon.observedDropsFrame.hasObservedDropsScanRun)
        assert.equals(1, #addon.observedDropsFrame.scannedObservedDropsRows)
        assert.equals(1624, addon.observedDropsFrame.scannedObservedDropsRows[1].petID)
        assert.equals(82800, addon.observedDropsFrame.scannedObservedDropsRows[1].itemID)
        assert.is_truthy(string.find(addon.observedDropsFrame.scannedObservedDropsRows[1].itemLink, "battlepet:1624", 1, true))
    end)

    local function check_catalog_first_open(category)
        local addon, links, names = build_addon()
        local fallback = "|Hitem:40001::::::::|h[Uncached Catalog Item]|h"
        local colored = "|cffa335ee|Hitem:40001::::::::|h[Localized Catalog Item]|h|r"
        local callbacks, requests, refreshes = {}, {}, {}
        local loaded = false
        local ns
        local catalog_rows = {
            { itemID = 40001, itemLink = fallback, recordID = category .. ":uncached", contentID = 1 },
            { itemID = 1001, itemLink = links[1001], recordID = category .. ":cached", contentID = 1 },
        }
        addon, ns = load_window(addon, links, names, {
            JanisTheme = {},
            [category == "mounts" and "MountFarmData" or "ToyFarmData"] = { rows = catalog_rows },
        })
        addon.RefreshObservedDropsWindowControls = function() end
        addon.UpdateObservedDropsSortHeaderState = function() end
        addon.SetObservedDropsWindowView = function() end
        addon.FormatMoney = function(_, value) return tostring(value) end
        local get_row = addon.GetObservedDropsWindowRow
        addon.GetObservedDropsWindowRow = function(self, index)
            local row = get_row(self, index)
            row.icon.SetTexture = function(icon, texture) icon.texture = texture end
            return row
        end
        require("tests.helpers.explorer_ui").with_ui(ns, function()
            local frame = addon.observedDropsFrame
            frame.content = CreateFrame("Frame")
            frame.listPanel = CreateFrame("Frame")
            frame.scrollFrame = CreateFrame("ScrollFrame")
            frame.IsShown = function() return true end
            loader.with_globals({
                C_Item = { GetItemInfo = function(id)
                    if id == 40001 then
                        if loaded then return "Localized Catalog Item", colored, 4, nil, nil, nil, nil, nil, nil, "catalog-icon" end
                        return nil
                    end
                    return names[id], links[id], 2, nil, nil, nil, nil, nil, nil, "cached-icon"
                end },
                GetItemInfoInstant = function() return nil end,
                Item = { CreateFromItemID = function(_, id)
                    requests[id] = (requests[id] or 0) + 1
                    return { ContinueOnItemLoad = function(_, callback) callbacks[id] = callback end }
                end },
                C_Timer = { After = function(_, callback) refreshes[#refreshes + 1] = callback end },
            }, function()
                addon:SetObservedDropsSourceTab("catalog-" .. category)
                local mount_row
                for _, row in ipairs(frame.rows) do if row.itemID == 40001 then mount_row = row end end
                assert.is_table(mount_row)
                assert.equals(fallback, mount_row.itemText:GetText())
                assert.is_false(mount_row.icon:IsShown())
                assert.equals(1, requests[40001])
                assert.is_nil(frame.itemCache["item:40001"])
                assert.is_nil(frame.itemCache[fallback])

                -- A second read while loading must not add another request.
                addon:BuildObservedDropsRows()
                assert.equals(1, requests[40001])
                loaded = true
                callbacks[40001]()
                addon:RefreshObservedDropItemData(40001) -- the native item-data event may also arrive
                assert.equals(1, #refreshes)
                refreshes[1]()
                assert.equals("catalog-" .. category, frame.dropSourceID)
                assert.equals(colored, mount_row.itemText:GetText())
                assert.equals(4, mount_row.itemQuality)
                assert.is_true(mount_row.icon:IsShown())
                assert.equals("catalog-icon", mount_row.icon.texture)
                assert.equals(colored, frame.itemCache["item:40001"].itemLink)
                assert.is_nil(frame.itemCache[fallback])
            end)
        end)
    end

    for _, category in ipairs({ "mounts", "toys" }) do
        it("hydrates fallback " .. category .. " links and visible icons on first open without changing tabs", function()
            check_catalog_first_open(category)
        end)
    end

    for _, load_mode in ipairs({ "cached", "synchronous", "asynchronous", "saved-name" }) do
        it("hydrates saved Zone scan item displays with " .. load_mode .. " item data", function()
            local addon, links, names = build_addon()
            local ns
            addon, ns = load_window(addon, links, names, { JanisTheme = {} })
            local saved_name = load_mode == "saved-name" and "Saved Zone Item" or "Item 40001"
            local saved_row = {
                itemID = 40001, itemName = saved_name, itemLink = "item:40001",
                icon = "saved-icon", minimumQuality = 1,
                value = 123456, marketValue = 234567, regionMarketValue = 345678,
                locationLabel = "Hellfire Peninsula", sourceText = "Expansion World Drop",
                farmingSourceType = "att-zones",
            }
            addon.db.observedDropsScanCache = { zone = {
                dropSourceID = "att-zones", expansionFilterID = "all", zoneFilterID = "all",
                results = { saved_row }, totalDrops = 1,
            } }
            addon.RefreshObservedDropsWindowControls = function() end
            addon.UpdateObservedDropsSortHeaderState = function() end
            addon.FormatMoney = function(_, value) return tostring(value) end
            addon.GetItemUnitValueFromSource = function() error("opening a saved scan must preserve prices") end
            local get_row = addon.GetObservedDropsWindowRow
            addon.GetObservedDropsWindowRow = function(self, index)
                local row = get_row(self, index)
                row.icon.SetTexture = function(icon, texture) icon.texture = texture end
                return row
            end
            local loaded = load_mode == "cached"
            local callback, requests = nil, 0
            local refreshes = {}
            local colored = "|cff1eff00|Hitem:40001::::::::|h[Localized Zone Item]|h|r"
            require("tests.helpers.explorer_ui").with_ui(ns, function()
                local frame = addon.observedDropsFrame
                frame.content = CreateFrame("Frame")
                frame.listPanel = CreateFrame("Frame")
                frame.scrollFrame = CreateFrame("ScrollFrame")
                frame.IsShown = function() return true end
                loader.with_globals({
                    C_Item = { GetItemInfo = function()
                        if loaded then
                            return "Localized Zone Item", colored, 2, nil, nil, nil, nil, nil, nil, "loaded-icon"
                        end
                    end },
                    GetItemInfoInstant = function() return nil end,
                    Item = { CreateFromItemID = function(_, id)
                        assert.equals(40001, id)
                        requests = requests + 1
                        return { ContinueOnItemLoad = function(_, on_load)
                            callback = on_load
                            if load_mode == "synchronous" then loaded = true; on_load() end
                        end }
                    end },
                    C_Timer = { After = function(_, on_refresh) refreshes[#refreshes + 1] = on_refresh end },
                }, function()
                    addon:OpenObservedDropsSavedScan("zone")
                    assert.equals(load_mode == "cached" and 0 or 1, requests)
                    if not loaded then
                        assert.equals(saved_name, frame.scannedObservedDropsRows[1].itemName)
                        assert.is_nil(frame.itemCache["item:40001"])
                        -- Reopening while the request is pending must still hydrate
                        -- the newly cloned rows when the original callback arrives.
                        addon:OpenObservedDropsSavedScan("zone")
                        assert.equals(1, requests)
                        loaded = true
                        callback()
                        addon:RefreshObservedDropItemData(40001)
                        assert.equals(1, #refreshes)
                        refreshes[1]()
                    end
                    local result = frame.scannedObservedDropsRows[1]
                    assert.equals("Localized Zone Item", result.itemName)
                    assert.equals(colored, result.itemLink)
                    assert.equals("loaded-icon", result.iconTexture)
                    assert.equals(colored, frame.rows[1].itemText:GetText())
                    assert.equals("loaded-icon", frame.rows[1].icon.texture)
                    assert.equals(123456, result.value)
                    assert.equals(234567, result.marketValue)
                    assert.equals(345678, result.regionMarketValue)
                    assert.equals("Hellfire Peninsula", result.locationLabel)
                    assert.equals(saved_name, saved_row.itemName)
                    assert.equals("item:40001", saved_row.itemLink)
                end)
            end)
        end)
    end

    local function check_synchronous_catalog_load(category)
        local addon, links, names = build_addon()
        addon = load_window(addon, links, names, {
            [category == "mounts" and "MountFarmData" or "ToyFarmData"] = { rows = { {
                itemID = 40002, itemLink = "|Hitem:40002::::::::|h[Fallback Catalog Item]|h", contentID = 1,
            } } },
        })
        addon.observedDropsFrame.dropSourceID = "catalog-" .. category
        local loaded, requests = false, 0
        local colored = "|cffa335ee|Hitem:40002::::::::|h[Loaded Mount]|h|r"
        loader.with_globals({
            C_Item = { GetItemInfo = function()
                if loaded then return "Loaded Mount", colored, 4, nil, nil, nil, nil, nil, nil, "mount-icon" end
            end },
            GetItemInfoInstant = function() return nil end,
            Item = { CreateFromItemID = function()
                requests = requests + 1
                return { ContinueOnItemLoad = function(_, callback) loaded = true; callback() end }
            end },
        }, function()
            local rows = addon:BuildObservedDropsRows()
            assert.equals(1, requests)
            assert.equals("Loaded Mount", rows[1].itemName)
            assert.equals(colored, rows[1].itemLink)
            assert.equals(4, rows[1].itemQuality)
            assert.equals("mount-icon", rows[1].iconTexture)
            assert.is_nil(addon.observedDropsFrame.pendingItemDataRequests[40002])
        end)
    end

    for _, category in ipairs({ "mounts", "toys" }) do
        it("uses item data that loads synchronously while " .. category .. " rows are being built", function()
            check_synchronous_catalog_load(category)
        end)
    end

    it("keeps cached battle pet displays separate for species sharing cage item 82800", function()
        local addon, links, names = build_addon()
        local first = "|cff0070dd|Hbattlepet:11:1:3:0:0:0:0|h[First Pet]|h|r"
        local second = "|cff0070dd|Hbattlepet:22:1:3:0:0:0:0|h[Second Pet]|h|r"
        addon = load_window(addon, links, names, {
            CatalogDropsData = { categories = { pets = {
                { itemID = 82800, petID = 11, itemLink = first, recordID = "pet:11", contentID = 1 },
                { itemID = 82800, petID = 22, itemLink = second, recordID = "pet:22", contentID = 1 },
            } } },
        })
        addon.observedDropsFrame.dropSourceID = "catalog-pets"
        loader.with_globals({
            C_PetJournal = { GetPetInfoBySpeciesID = function(id) return "Pet " .. id, "icon-" .. id end },
            C_Item = { GetItemInfo = function() error("pet displays must not resolve the cage") end },
            Item = { CreateFromItemID = function() error("pet displays must not request the cage") end },
        }, function()
            addon:BuildObservedDropsRows()
            local rows = addon:BuildObservedDropsRows()
            assert.equals(2, #rows)
            local cache = addon.observedDropsFrame.itemCache
            assert.equals("Pet 11", cache[first].itemName)
            assert.equals("Pet 22", cache[second].itemName)
            assert.equals("icon-11", cache[first].icon)
            assert.equals("icon-22", cache[second].icon)
            assert.is_nil(cache["item:82800"])
        end)
    end)

    it("replaces a static item ID placeholder when item data finishes loading", function()
        local addon, item_links, item_names = build_addon()
        addon.observedDropsFrame.dropSourceID = "att-zones"
        addon.observedDropsFrame.expansionFilterID = "1"
        addon.observedDropsFrame.zoneFilterID = "37"
        addon.observedDropsFrame.minimumValueCopper = 0
        addon.observedDropsFrame.IsShown = function()
            return false
        end
        addon = load_window(addon, item_links, item_names, {
            ATTBoEDropsData = {
                expansions = { options = { { id = 1, label = "Classic" } } },
                zones = {
                    [37] = {
                        mapID = 37,
                        expansionID = 1,
                        expansion = "Classic",
                        items = { { itemID = 40001 } },
                    },
                },
                world = { items = {} },
            },
        })

        addon.observedDropsFrame.scannedObservedDropsRows = addon:BuildObservedDropsRows()
        assert.equals("Item 40001", addon.observedDropsFrame.scannedObservedDropsRows[1].itemName)

        item_names[40001] = "Loaded Static Item"
        item_links[40001] = "|cff1eff00|Hitem:40001::::::::|h[Loaded Static Item]|h|r"
        loader.with_globals({
            GetItemInfo = function(item_id)
                return item_names[item_id], item_links[item_id], 2, nil, nil, nil, nil, nil, nil, "icon-" .. item_id
            end,
        }, function()
            addon:RefreshObservedDropItemData(40001)
        end)

        assert.equals("Loaded Static Item", addon.observedDropsFrame.scannedObservedDropsRows[1].itemName)
        assert.equals(item_links[40001], addon.observedDropsFrame.scannedObservedDropsRows[1].itemLink)
    end)

    it("removes an unresolved zone drop when loaded item data identifies poor quality", function()
        local addon, item_links, item_names = build_addon()
        addon.observedDropsFrame.dropSourceID = "att-zones"
        addon.observedDropsFrame.expansionFilterID = "1"
        addon.observedDropsFrame.zoneFilterID = "37"
        addon.observedDropsFrame.minimumValueCopper = 0
        addon.observedDropsFrame.IsShown = function()
            return false
        end
        addon = load_window(addon, item_links, item_names, {
            ATTBoEDropsData = {
                expansions = { options = { { id = 1, label = "Classic" } } },
                zones = {
                    [37] = {
                        mapID = 37,
                        expansionID = 1,
                        expansion = "Classic",
                        items = { { itemID = 40002 } },
                    },
                },
                world = { items = {} },
            },
        })

        addon.observedDropsFrame.scannedObservedDropsRows = addon:BuildObservedDropsRows()
        assert.equals(1, #addon.observedDropsFrame.scannedObservedDropsRows)

        item_names[40002] = "Loaded Poor Item"
        item_links[40002] = "|cff9d9d9d|Hitem:40002::::::::|h[Loaded Poor Item]|h|r"
        loader.with_globals({
            GetItemInfo = function(item_id)
                return item_names[item_id], item_links[item_id], 0, nil, nil, nil, nil, nil, nil, "icon-" .. item_id
            end,
        }, function()
            addon:RefreshObservedDropItemData(40002)
        end)

        assert.equals(0, #addon.observedDropsFrame.scannedObservedDropsRows)
    end)

end)
