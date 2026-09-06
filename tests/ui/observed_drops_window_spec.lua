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
    it("builds stable sorted rows for the observed drops list", function()
        local addon, item_links, item_names = build_addon()
        addon = load_window(addon, item_links, item_names)

        local rows = addon:BuildObservedDropsRows()

        assert.same(require("tests.snapshots.observed_drops_rows"), project_rows(rows))
    end)

    it("keeps the observed list empty until saved sessions have been scanned", function()
        local addon, item_links, item_names = build_addon()
        addon.db.observedSavedSessionDrops = {}
        addon.db.observedSavedSessionDropsScannedAt = nil
        addon = load_window(addon, item_links, item_names)

        local rows = addon:BuildObservedDropsRows()

        assert.equals(0, #rows)
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
end)
