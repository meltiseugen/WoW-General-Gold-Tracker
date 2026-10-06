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

        assert.equals("map", addon:ConfigureObservedDropRowActionButton(button, row, "wit-mounts"))
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
        assert.equals("map", addon:ConfigureObservedDropRowActionButton(petButton, petRow, "wit-pets"))
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
        assert.equals("map", addon:ConfigureObservedDropRowActionButton(itemButton, itemRow, "wit-pets"))
        itemScripts.OnClick(itemButton)
        assert.equals("pets:MoltenCoreRaid:1", openedRecordID)
        assert.is_nil(openedItemID)
    end)

    it("uses exact Toys record identity for the researched Map action", function()
        local addon, item_links, item_names = build_addon()
        local openedRecordID
        addon.HasFarmForRecordID = function(_, recordID)
            return recordID == "toys:BigRedRayGun:1", recordID == "toys:BigRedRayGun:1" and 1 or 0
        end
        addon.OpenFarmDetailsForRecordID = function(_, recordID)
            openedRecordID = recordID
            return true
        end
        addon = load_window(addon, item_links, item_names)

        local row = { itemID = 142265, observedDropKey = "toys:BigRedRayGun:1" }
        local scripts = {}
        local button = {
            SetText = function(self, text) self.text = text end,
            SetPalette = function(self, palette) self.palette = palette end,
            SetScript = function(_, event, callback) scripts[event] = callback end,
            GetParent = function() return row end,
        }

        assert.equals("map", addon:ConfigureObservedDropRowActionButton(button, row, "wit-toys"))
        assert.equals("Map", button.text)
        assert.equals("primary", button.palette)
        scripts.OnClick(button)
        assert.equals("toys:BigRedRayGun:1", openedRecordID)
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
        addon.observedDropsFrame.dropSourceID = "wit-transmogs"
        addon.observedDropsFrame.minimumValueCopper = 0

        addon = load_window(addon, item_links, item_names, {
            WITDropsData = {
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
        local witRow
        for _, row in ipairs(rows) do
            if row.farmingSourceType == "wit-transmogs" then
                witRow = row
            end
        end

        assert.is_nil(witRow)
    end)

    it("always loads every WIT mount and toy without applying scan filters", function()
        for _, source in ipairs({
            { id = "wit-mounts", category = "mounts", itemID = 2001 },
            { id = "wit-toys", category = "toys", itemID = 30001 },
        }) do
            local addon, item_links, item_names = build_addon()
            item_links[source.itemID] = "|cff0070dd|Hitem:" .. source.itemID .. "::::::::|h[WIT Collectible]|h|r"
            item_names[source.itemID] = "WIT Collectible"
            addon.observedDropsFrame.expansionFilterID = "12"
            addon.observedDropsFrame.minimumValueCopper = 99999999
            addon = load_window(addon, item_links, item_names, {
                WITDropsData = {
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

    it("exposes WIT pets as an always-visible Drops source with pet identity retained", function()
        local addon, item_links, item_names = build_addon()
        addon = load_window(addon, item_links, item_names, {
            WITDropsData = {
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

        addon:SetObservedDropsSourceTab("wit-pets")

        assert.equals("wit-pets", addon.observedDropsFrame.dropSourceID)
        assert.is_true(addon.observedDropsFrame.hasObservedDropsScanRun)
        assert.equals(1, #addon.observedDropsFrame.scannedObservedDropsRows)
        assert.equals(1624, addon.observedDropsFrame.scannedObservedDropsRows[1].petID)
        assert.equals(82800, addon.observedDropsFrame.scannedObservedDropsRows[1].itemID)
        assert.is_truthy(string.find(addon.observedDropsFrame.scannedObservedDropsRows[1].itemLink, "battlepet:1624", 1, true))
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
