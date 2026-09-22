local loader = require("tests.helpers.addon_loader")

local function noop() end

local function panel()
    return {
        shown = nil,
        SetShown = function(self, shown)
            self.shown = shown
        end,
    }
end

local function button()
    return {
        selected = nil,
        shown = nil,
        enabled = nil,
        SetSelected = function(self, selected)
            self.selected = selected
        end,
        SetPalette = function(self, palette)
            self.palette = palette
        end,
        SetShown = function(self, shown)
            self.shown = shown
        end,
        SetEnabled = function(self, enabled)
            self.enabled = enabled
        end,
    }
end

local function load_rare_and_instance(addon)
    return loader.with_globals({
        LE_ITEM_BIND_ON_ACQUIRE = 1,
        LE_ITEM_BIND_ON_EQUIP = 2,
        LE_ITEM_BIND_ON_USE = 3,
        LE_ITEM_BIND_QUEST = 4,
        date = function()
            return "2026-08-27 10:00"
        end,
        time = function()
            return 1800
        end,
    }, function()
        loader.load_module("UI/RareFarmingWindow.lua", addon, {
            RareDropsData = {
                sourceVersion = "test",
                expansions = { currentID = 1, options = { { id = 1, label = "Classic", current = true } } },
                rares = {},
            },
        })
        return loader.load_module("UI/InstanceFarmingWindow.lua", addon, {
            InstanceDropsData = {
                sourceVersion = "test",
                expansions = { currentID = 1, options = { { id = 1, label = "Classic", current = true } } },
                instances = {},
            },
        })
    end)
end

local function load_instance_with_data(addon, instance_data, globals, att_data)
    local values = {
        LE_ITEM_BIND_ON_ACQUIRE = 1,
        LE_ITEM_BIND_ON_EQUIP = 2,
        LE_ITEM_BIND_ON_USE = 3,
        LE_ITEM_BIND_QUEST = 4,
    }
    for key, value in pairs(globals or {}) do
        values[key] = value
    end
    return loader.with_globals(values, function()
        return loader.load_module("UI/InstanceFarmingWindow.lua", addon, {
            InstanceDropsData = instance_data,
            ATTBoEDropsData = att_data,
        })
    end)
end

local function build_addon()
    local addon = {
        db = {
            farmingItemFavorites = {},
            rareFarmingFavorites = {},
            instanceFarmingFavorites = {},
            rareFarmingScanCache = {},
            instanceFarmingScanCache = {},
            rareFarmingValueSource = "TSM_DBMARKET",
            instanceFarmingValueSource = "TSM_DBMARKET",
            rareFarmingMinimumValue = 1000,
            instanceFarmingMinimumValue = 1000,
            rareFarmingExpansionFilter = "current",
            instanceFarmingExpansionFilter = "current",
            instanceFarmingContentTypeFilter = "all",
            rareFarmingScanMode = "background",
            instanceFarmingScanMode = "background",
        },
        DEFAULTS = {
            rareFarmingValueSource = "TSM_DBMARKET",
            instanceFarmingValueSource = "TSM_DBMARKET",
            rareFarmingMinimumValue = 1000,
            instanceFarmingMinimumValue = 1000,
            rareFarmingExpansionFilter = "current",
            instanceFarmingExpansionFilter = "current",
            instanceFarmingContentTypeFilter = "all",
            rareFarmingScanMode = "background",
            instanceFarmingScanMode = "background",
        },
        VALUE_SOURCE_BY_ID = {
            TSM_DBMARKET = { id = "TSM_DBMARKET", label = "Market Value", tsmKey = "DBMarket" },
        },
        GetFarmingFavoriteKey = function(_, row_or_item_id)
            local item_id = type(row_or_item_id) == "table" and row_or_item_id.itemID or row_or_item_id
            item_id = tonumber(item_id)
            return item_id and ("item:" .. tostring(math.floor(item_id + 0.5))) or nil
        end,
        GetFarmingFavoriteStore = function(self)
            self.db.farmingItemFavorites = self.db.farmingItemFavorites or {}
            self.db.rareFarmingFavorites = self.db.farmingItemFavorites
            self.db.instanceFarmingFavorites = self.db.farmingItemFavorites
            return self.db.farmingItemFavorites
        end,
        IsFarmingItemFavorite = function(self, row_or_item_id)
            local key = self:GetFarmingFavoriteKey(row_or_item_id)
            return key ~= nil and self:GetFarmingFavoriteStore()[key] ~= nil
        end,
        RefreshRareFarmingWindow = noop,
        RefreshRareFarmingLibraryWindow = noop,
        RefreshInstanceFarmingWindow = noop,
        RefreshInstanceFarmingLibraryWindow = noop,
        RefreshRareFarmingWindowControls = noop,
        RefreshInstanceFarmingWindowControls = noop,
    }
    return addon
end

describe("UI farming windows shared state", function()
    it("uses the shared fallback resolver for rare and instance row prices", function()
        local addon = build_addon()
        addon.VALUE_SOURCE_BY_ID.TSM_DBREGIONMARKETAVG = {
            id = "TSM_DBREGIONMARKETAVG",
            label = "Region Market Avg",
            tsmKey = "DBRegionMarketAvg",
        }
        addon.ResolveItemUnitValue = function(_, _, _, item_id)
            return item_id == 40001 and 125000 or 0,
                "TSM_DBREGIONMARKETAVG",
                "Region Market Avg",
                true
        end
        addon.GetTSMItemValueForItemID = function()
            return 0
        end
        addon = load_rare_and_instance(addon)

        local rare_rows = { { itemID = 40001 } }
        local instance_rows = { { itemID = 40001 } }
        addon:UpdateRareFarmingRowsPrices(rare_rows, "TSM_DBMARKET")
        addon:UpdateInstanceFarmingRowsPrices(instance_rows, "TSM_DBMARKET")

        for _, row in ipairs({ rare_rows[1], instance_rows[1] }) do
            assert.equals(125000, row.value)
            assert.equals("TSM_DBREGIONMARKETAVG", row.valueSourceID)
            assert.equals("Region Market Avg", row.valueSourceLabel)
            assert.is_true(row.valueSourceWasFallback)
        end
    end)

    it("shares favorites between rare and instance farming windows by item ID", function()
        local addon = load_rare_and_instance(build_addon())

        local rare_row = {
            itemID = 40001,
            itemName = "Shared Cape",
            rareName = "Rare One",
            value = 120000,
            valueSourceID = "TSM_DBMARKET",
        }
        local instance_row = {
            itemID = 40001,
            itemName = "Shared Cape",
            instanceName = "Raid One",
            bossName = "Trash Mobs",
            value = 130000,
            valueSourceID = "TSM_DBMARKET",
        }

        assert.is_true(addon:SetRareFarmingFavorite(rare_row, true))
        assert.is_true(addon:IsInstanceFarmingFavorite(instance_row))

        addon:ToggleInstanceFarmingFavorite(instance_row)

        assert.is_false(addon:IsRareFarmingFavorite(rare_row))
    end)

    it("groups duplicate rare farming items and keeps each rare source", function()
        local addon = load_rare_and_instance(build_addon())
        local rows = addon:BuildRareFarmingGroupedRows({
            {
                npcID = 1001,
                rareName = "Rare One",
                itemID = 40001,
                itemName = "Shared Cape",
                locationLabel = "Zone A 42.0,51.0",
                locations = { { mapID = 1, x = 42, y = 51 } },
                value = 120000,
            },
            {
                npcID = 1002,
                rareName = "Rare Two",
                itemID = 40001,
                itemName = "Shared Cape",
                locationLabel = "Zone B 30.0,44.0",
                locations = { { mapID = 2, x = 30, y = 44 } },
                value = 120000,
            },
            {
                npcID = 1003,
                rareName = "Rare Three",
                itemID = 40002,
                itemName = "Other Boots",
                locationLabel = "Zone C 20.0,22.0",
                locations = { { mapID = 3, x = 20, y = 22 } },
                value = 90000,
            },
        })

        assert.equals(2, #rows)
        assert.equals(40001, rows[1].itemID)
        assert.equals("2 rares", rows[1].rareName)
        assert.equals("1 42.0,51.0 / 2 30.0,44.0", rows[1].locationLabel)
        assert.equals(2, #rows[1].locations)
        assert.equals(2, rows[1].rareSourceCount)
        assert.equals("Rare One", rows[1].rareSources[1].rareName)
        assert.equals("Zone B 30.0,44.0", rows[1].rareSources[2].locationLabel)
    end)

    it("applies rare-table sort criteria in priority order", function()
        local addon = load_rare_and_instance(build_addon())
        local rows = {
            { itemID = 1, itemName = "Alpha", favorite = true, value = 500 },
            { itemID = 2, itemName = "Zulu", favorite = true, value = 100 },
            { itemID = 3, itemName = "Middle", favorite = false, value = 900 },
        }

        addon:SortRareFarmingRows(rows, "favorite", false, {
            { key = "favorite", ascending = false },
            { key = "itemName", ascending = false },
        })

        assert.equals("Zulu", rows[1].itemName)
        assert.equals("Alpha", rows[2].itemName)
        assert.equals("Middle", rows[3].itemName)
    end)

    it("keeps every rare spawn location and sorts rows into location groups", function()
        local addon = load_rare_and_instance(build_addon())
        local rows, map_options = loader.with_globals({
            C_Map = {
                GetMapInfo = function(map_id)
                    return ({
                        [11] = { name = "Zone A" },
                        [22] = { name = "Zone B" },
                    })[map_id]
                end,
            },
        }, function()
            local grouped = addon:BuildRareFarmingGroupedRows({
                {
                    npcID = 1001,
                    rareName = "Rare One",
                    itemID = 40001,
                    itemName = "Shared Cape",
                    locations = {
                        { mapID = 22, x = 30, y = 44 },
                        { mapID = 22, x = 35, y = 49 },
                    },
                    value = 120000,
                },
                {
                    npcID = 1002,
                    rareName = "Rare Two",
                    itemID = 40002,
                    itemName = "Other Boots",
                    locations = { { mapID = 11, x = 42, y = 51 } },
                    value = 90000,
                },
            })
            addon:SortRareFarmingRows(grouped, "location", true)
            return grouped, addon:BuildRareFarmingMapOptions(grouped[2])
        end)

        assert.equals(2, #rows[2].locations)
        assert.equals("Zone B 30.0,44.0 / 35.0,49.0", rows[2].locationLabel)
        assert.equals("Zone A", addon:GetRareFarmingLocationGroupLabel(rows[1]))
        assert.equals("Zone B", addon:GetRareFarmingLocationGroupLabel(rows[2]))
        assert.equals(1, #map_options)
        assert.equals(2, #map_options[1].pins)
    end)

    it("builds rare farming map options from every grouped rare source location", function()
        local addon = load_rare_and_instance(build_addon())
        local rows = addon:BuildRareFarmingGroupedRows({
            {
                npcID = 1001,
                rareName = "Rare One",
                itemID = 40001,
                itemName = "Shared Cape",
                locationLabel = "Zone A 42.0,51.0",
                locations = { { mapID = 11, x = 42, y = 51 } },
                value = 120000,
            },
            {
                npcID = 1002,
                rareName = "Rare Two",
                itemID = 40001,
                itemName = "Shared Cape",
                locationLabel = "Zone B 30.0,44.0",
                locations = { { mapID = 22, x = 0.30, y = 0.44 } },
                value = 120000,
            },
        })

        local options = loader.with_globals({
            C_Map = {
                GetMapInfo = function(map_id)
                    return ({
                        [11] = { name = "Zone A" },
                        [22] = { name = "Zone B" },
                    })[map_id]
                end,
            },
        }, function()
            return addon:BuildRareFarmingMapOptions(rows[1])
        end)

        assert.equals(2, #options)
        assert.equals(11, options[1].mapID)
        assert.equals("Zone A", options[1].label)
        assert.equals(0.42, options[1].pins[1].x)
        assert.equals("Rare One", options[1].pins[1].label)
        assert.same({ "https://www.wowhead.com/npc=1001" }, options[1].pins[1].sourceUrls)
        assert.equals(22, options[2].mapID)
        assert.equals("Zone B", options[2].label)
        assert.equals(0.44, options[2].pins[1].y)
        assert.equals("Rare Two", options[2].pins[1].label)
        assert.same({ "https://www.wowhead.com/npc=1002" }, options[2].pins[1].sourceUrls)
    end)

    it("resets instance scan state when opening the New Scan tab", function()
        local addon = load_rare_and_instance(build_addon())
        addon.instanceFarmingFrame = {
            scanState = { active = true },
            lastResults = { { itemID = 1 } },
            loadedInstanceFarmingCacheKey = "old",
            loadedInstanceFarmingCache = { results = { { itemID = 1 } } },
            editingInstanceFarmingCacheKey = "old",
            hasInstanceFarmingScanRun = true,
            statusText = {
                SetText = function(self, text)
                    self.text = text
                end,
            },
            progressBar = {
                SetMinMaxValues = function(self, min_value, max_value)
                    self.minValue = min_value
                    self.maxValue = max_value
                end,
                SetValue = function(self, value)
                    self.value = value
                end,
            },
            libraryPanel = panel(),
            controlsPanel = panel(),
            listPanel = panel(),
            metaText = panel(),
            libraryUpdateFavoritesButton = button(),
            savedTabButton = button(),
            favoritesTabButton = button(),
            newScanTabButton = button(),
        }

        addon.RefreshInstanceFarmingWindowControls = noop
        addon.RefreshInstanceFarmingWindow = noop
        addon.RefreshInstanceFarmingLibraryWindow = noop
        addon:OpenInstanceFarmingNewScan()

        assert.same({}, addon.instanceFarmingFrame.lastResults)
        assert.is_nil(addon.instanceFarmingFrame.scanState)
        assert.is_nil(addon.instanceFarmingFrame.loadedInstanceFarmingCacheKey)
        assert.is_nil(addon.instanceFarmingFrame.editingInstanceFarmingCacheKey)
        assert.is_false(addon.instanceFarmingFrame.hasInstanceFarmingScanRun)
        assert.equals("new", addon.instanceFarmingFrame.instanceFarmingNavigationTab)
        assert.equals("scan", addon.instanceFarmingFrame.instanceFarmingViewID)
        assert.is_true(addon.instanceFarmingFrame.controlsPanel.shown)
        assert.is_false(addon.instanceFarmingFrame.libraryPanel.shown)
        assert.is_true(addon.instanceFarmingFrame.newScanTabButton.selected)
    end)

    it("keeps waiting item-binding rows in the same instance scan", function()
        local worker
        local requested = 0
        local loaded = false
        local status_text = {}
        local addon = {
            db = {
                instanceFarmingValueSource = "TSM_DBMARKET",
                instanceFarmingExpansionFilter = "1",
                instanceFarmingContentTypeFilter = "raid",
                instanceFarmingMinimumValue = 1000,
                instanceFarmingScanMode = "foreground",
            },
            DEFAULTS = {
                instanceFarmingValueSource = "TSM_DBMARKET",
                instanceFarmingExpansionFilter = "current",
                instanceFarmingContentTypeFilter = "all",
                instanceFarmingMinimumValue = 0,
                instanceFarmingScanMode = "background",
            },
            VALUE_SOURCE_BY_ID = {
                TSM_DBMARKET = { id = "TSM_DBMARKET", label = "Market Value", tsmKey = "DBMarket" },
            },
            GetTSMItemValueForItemID = function()
                return 5000
            end,
            GetMarketHistoryItemKey = function(_, _, item_id)
                return "item:" .. tostring(item_id)
            end,
            IsLootItemBindingRestricted = function()
                return false
            end,
            IsInstanceFarmingFavorite = function()
                return false
            end,
            RecordInstanceFarmingMarketSnapshots = noop,
            RefreshInstanceFarmingWindowControls = noop,
            RefreshInstanceFarmingWindow = noop,
            Print = noop,
            COPPER_PER_GOLD = 10000,
        }
        addon = load_instance_with_data(addon, {
            sourceVersion = "test",
            expansions = { currentID = 1, options = { { id = 1, label = "Classic", current = true } } },
            instances = {
                {
                    name = "RaidOne",
                    expansionID = 1,
                    expansion = "Classic",
                    contentType = "raid",
                    encounterJournalID = 900,
                    mapID = 100,
                    bosses = {
                        { name = "BossOne", encounterJournalID = 901, loot = { { itemID = 70001 } } },
                    },
                },
            },
        }, {
            CreateFrame = function()
                worker = {
                    SetScript = function(self, _, script)
                        self.on_update = script
                    end,
                    Hide = function(self)
                        self.hidden = true
                    end,
                    Show = function(self)
                        self.hidden = false
                    end,
                }
                return worker
            end,
            C_Item = {
                RequestLoadItemDataByID = function()
                    requested = requested + 1
                end,
            },
            GetItemInfo = function()
                if loaded then
                    return "Loaded Drop", "item:70001", 2, nil, nil, nil, nil, nil, nil, 134400, nil, nil, nil, 2
                end
                return nil
            end,
            GetItemInfoInstant = function()
                return nil, nil, nil, nil, 134400
            end,
        })
        addon.RefreshInstanceFarmingWindowControls = noop
        addon.RefreshInstanceFarmingWindow = noop
        addon.RefreshInstanceFarmingLibraryWindow = noop
        addon.instanceFarmingFrame = {
            valueSourceID = "TSM_DBMARKET",
            expansionFilterID = "1",
            contentTypeFilterID = "raid",
            scanModeID = "foreground",
            minimumValueCopper = 1000,
            lastResults = {},
            minimumValueInput = {
                GetText = function()
                    return "0.10"
                end,
                SetText = noop,
                HasFocus = function()
                    return false
                end,
            },
            progressBar = {
                SetMinMaxValues = noop,
                SetValue = noop,
            },
            statusText = {
                SetText = function(_, text)
                    status_text[#status_text + 1] = text
                end,
            },
            IsShown = function()
                return false
            end,
        }

        loader.with_globals({
            CreateFrame = function()
                worker = {
                    SetScript = function(self, _, script)
                        self.on_update = script
                    end,
                    Hide = function(self)
                        self.hidden = true
                    end,
                    Show = function(self)
                        self.hidden = false
                    end,
                }
                return worker
            end,
            C_Item = {
                RequestLoadItemDataByID = function()
                    requested = requested + 1
                end,
            },
            GetItemInfo = function()
                if loaded then
                    return "Loaded Drop", "item:70001", 2, nil, nil, nil, nil, nil, nil, 134400, nil, nil, nil, 2
                end
                return nil
            end,
            GetItemInfoInstant = function()
                return nil, nil, nil, nil, 134400
            end,
        }, function()
            addon:StartInstanceFarmingScan()
            assert.is_table(addon.instanceFarmingFrame.scanState)
            worker.on_update(worker, 0.1)
            assert.is_table(addon.instanceFarmingFrame.scanState)
            assert.equals(0, #addon.instanceFarmingFrame.lastResults)
            assert.is_true(requested > 0)

            loaded = true
            worker.on_update(worker, 0.5)
            assert.is_nil(addon.instanceFarmingFrame.scanState)
            assert.equals(1, #addon.instanceFarmingFrame.lastResults)
            assert.equals(70001, addon.instanceFarmingFrame.lastResults[1].itemID)
            assert.matches("unavailable%-binding items skipped", status_text[#status_text])
        end)
    end)

    it("includes ATT instance BoE rows in instance farming scans", function()
        local worker
        local status_text = {}
        local addon = build_addon()
        addon.db.instanceFarmingExpansionFilter = "2"
        addon.db.instanceFarmingContentTypeFilter = "dungeon"
        addon.db.instanceFarmingMinimumValue = 0
        addon.db.instanceFarmingScanMode = "foreground"
        addon.GetTSMItemValueForItemID = function()
            return 5000
        end
        addon.GetMarketHistoryItemKey = function(_, _, item_id)
            return "item:" .. tostring(item_id)
        end
        addon.IsLootItemBindingRestricted = function()
            return false
        end
        addon.IsInstanceFarmingFavorite = function()
            return false
        end
        addon.RecordInstanceFarmingMarketSnapshots = noop
        addon.Print = noop
        addon.COPPER_PER_GOLD = 10000
        local function get_test_item_info(item_id)
            local id = tonumber(item_id)
            if id == 80001 or id == 80002 then
                return "Drop " .. tostring(id),
                    "item:" .. tostring(id),
                    2,
                    nil,
                    nil,
                    nil,
                    nil,
                    nil,
                    nil,
                    134400,
                    nil,
                    nil,
                    nil,
                    2
            end
            return nil
        end

        addon = load_instance_with_data(addon, {
            sourceVersion = "test",
            expansions = {
                currentID = 2,
                options = {
                    { id = 2, label = "Burning Crusade", current = true },
                },
            },
            instances = {
                {
                    name = "TBCDungeon",
                    expansionID = 2,
                    expansion = "Burning Crusade",
                    contentType = "dungeon",
                    encounterJournalID = 777,
                    mapID = 100,
                    bosses = {
                        { name = "Trash Mobs", loot = { { itemID = 80001 } } },
                    },
                },
            },
        }, {
            CreateFrame = function()
                worker = {
                    SetScript = function(self, _, script)
                        self.on_update = script
                    end,
                    Hide = function(self)
                        self.hidden = true
                    end,
                    Show = function(self)
                        self.hidden = false
                    end,
                }
                return worker
            end,
            GetItemInfo = get_test_item_info,
        }, {
            instances = {
                [777] = {
                    journalInstanceID = 777,
                    name = "TBCDungeon",
                    expansionID = 2,
                    expansion = "Burning Crusade",
                    contentType = "dungeon",
                    mapID = 100,
                    items = {
                        { itemID = 80001 },
                        { itemID = 80002 },
                    },
                },
            },
        })
        addon.RefreshInstanceFarmingWindowControls = noop
        addon.RefreshInstanceFarmingWindow = noop
        addon.RefreshInstanceFarmingLibraryWindow = noop
        addon.instanceFarmingFrame = {
            valueSourceID = "TSM_DBMARKET",
            expansionFilterID = "2",
            contentTypeFilterID = "dungeon",
            scanModeID = "foreground",
            minimumValueCopper = 0,
            lastResults = {},
            minimumValueInput = {
                GetText = function()
                    return "0"
                end,
                SetText = noop,
                HasFocus = function()
                    return false
                end,
            },
            progressBar = {
                SetMinMaxValues = noop,
                SetValue = noop,
            },
            statusText = {
                SetText = function(_, text)
                    status_text[#status_text + 1] = text
                end,
            },
            IsShown = function()
                return false
            end,
        }

        loader.with_globals({
            CreateFrame = function()
                worker = {
                    SetScript = function(self, _, script)
                        self.on_update = script
                    end,
                    Hide = function(self)
                        self.hidden = true
                    end,
                    Show = function(self)
                        self.hidden = false
                    end,
                }
                return worker
            end,
            GetItemInfo = get_test_item_info,
        }, function()
            addon:StartInstanceFarmingScan()
            assert.is_table(addon.instanceFarmingFrame.scanState)
            assert.equals(2, addon.instanceFarmingFrame.scanState.total)

            worker.on_update(worker, 0.1)

            assert.is_nil(addon.instanceFarmingFrame.scanState)
            assert.equals(2, #addon.instanceFarmingFrame.lastResults)
            assert.equals(80001, addon.instanceFarmingFrame.lastResults[1].itemID)
            assert.equals(80002, addon.instanceFarmingFrame.lastResults[2].itemID)
            assert.equals("att-instance", addon.instanceFarmingFrame.lastResults[2].farmingSourceType)
            assert.matches("2 auctionable instance drops matched", status_text[#status_text])
        end)
    end)

    it("builds staged instance map options and skips boss maps for trash", function()
        local addon = load_instance_with_data(build_addon(), {
            sourceVersion = "test",
            expansions = { currentID = 1, options = { { id = 1, label = "Classic", current = true } } },
            instances = {},
        }, {
            Enum = { UIMapType = { Continent = 2 } },
            C_AddOns = { LoadAddOn = noop },
            C_Map = {
                GetMapInfo = function(map_id)
                    return ({
                        [1] = { name = "Eastern Kingdoms", mapType = 2 },
                        [10] = { name = "Burning Steppes", mapType = 3, parentMapID = 1 },
                        [100] = { name = "Molten Core", mapType = 5, parentMapID = 10 },
                        [101] = { name = "Molten Core - Inner Depths", mapType = 5, parentMapID = 10 },
                    })[map_id]
                end,
            },
            C_EncounterJournal = {
                GetDungeonEntrancesForMap = function(map_id)
                    if map_id == 1 then
                        return {
                            { journalInstanceID = 409, name = "Molten Core", position = { x = 0.46, y = 0.54 } },
                        }
                    end
                    if map_id == 10 then
                        return {
                            { journalInstanceID = 409, name = "Molten Core", position = { x = 0.32, y = 0.84 } },
                        }
                    end
                    return {}
                end,
                GetEncountersOnMap = function(map_id)
                    if map_id == 100 then
                        return {
                            { encounterID = 999, mapX = 0.12, mapY = 0.34 },
                            { encounterID = 663, mapX = 0.44, mapY = 0.55 },
                        }
                    end
                    return {}
                end,
            },
        })

        local boss_row = {
            itemID = 70001,
            itemName = "Hot Boots",
            instanceName = "MoltenCore",
            instanceEncounterJournalID = 409,
            instanceMapID = 100,
            bossName = "Lucifron",
            bossEncounterJournalID = 663,
        }
        local runtime_globals = {
            Enum = { UIMapType = { Continent = 2 } },
            C_AddOns = { LoadAddOn = noop },
            C_Map = {
                GetMapInfo = function(map_id)
                    return ({
                        [1] = { name = "Eastern Kingdoms", mapType = 2 },
                        [10] = { name = "Burning Steppes", mapType = 3, parentMapID = 1 },
                        [100] = { name = "Molten Core", mapType = 5, parentMapID = 10 },
                    })[map_id]
                end,
            },
            C_EncounterJournal = {
                GetDungeonEntrancesForMap = function(map_id)
                    if map_id == 1 then
                        return {
                            { journalInstanceID = 409, name = "Molten Core", position = { x = 0.46, y = 0.54 } },
                        }
                    end
                    if map_id == 10 then
                        return {
                            { journalInstanceID = 409, name = "Molten Core", position = { x = 0.32, y = 0.84 } },
                        }
                    end
                    return {}
                end,
                GetEncountersOnMap = function(map_id)
                    if map_id == 100 then
                        return {
                            { encounterID = 999, mapX = 0.12, mapY = 0.34 },
                            { encounterID = 663, mapX = 0.44, mapY = 0.55 },
                        }
                    end
                    return {}
                end,
            },
        }

        local options = loader.with_globals(runtime_globals, function()
            return addon:BuildInstanceFarmingMapOptions(boss_row)
        end)
        assert.equals(3, #options)
        assert.equals(1, options[1].mapID)
        assert.equals(10, options[2].mapID)
        assert.equals(100, options[3].mapID)
        assert.equals(0.44, options[3].pins[1].x)
        assert.equals(0.55, options[3].pins[1].y)
        assert.equals("Boss drop", options[3].pins[1].routeType)

        local trash_row = {
            itemID = 70002,
            itemName = "Ashy Gloves",
            instanceName = "MoltenCore",
            instanceEncounterJournalID = 409,
            instanceMapID = 100,
            bossName = "Trash Mobs",
        }
        local trash_options = loader.with_globals(runtime_globals, function()
            return addon:BuildInstanceFarmingMapOptions(trash_row)
        end)
        assert.equals(2, #trash_options)
        assert.equals(1, trash_options[1].mapID)
        assert.equals(10, trash_options[2].mapID)

        runtime_globals.C_Map.GetMapGroupID = function(map_id)
            return map_id == 100 and 7 or nil
        end
        runtime_globals.C_Map.GetMapGroupMembersInfo = function(map_group_id)
            if map_group_id == 7 then
                return { { mapID = 100 }, { mapID = 101 } }
            end
            return {}
        end
        runtime_globals.C_EncounterJournal.GetEncountersOnMap = function(map_id)
            if map_id == 101 then
                return { { encounterID = 663, mapX = 0.62, mapY = 0.73 } }
            end
            return {}
        end

        local multi_floor_options = loader.with_globals(runtime_globals, function()
            return addon:BuildInstanceFarmingMapOptions(boss_row)
        end)
        assert.equals(3, #multi_floor_options)
        assert.equals(101, multi_floor_options[3].mapID)
        assert.equals(0.62, multi_floor_options[3].pins[1].x)
        assert.equals(0.73, multi_floor_options[3].pins[1].y)
    end)
end)
