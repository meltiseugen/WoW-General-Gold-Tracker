local loader = require("tests.helpers.addon_loader")

local item_links = {
    [2001] = "|cff1eff00|Hitem:2001::::::::|h[Sellable Girdle]|h|r",
    [2002] = "|cff0070dd|Hitem:2002::::::::|h[Bound Blade]|h|r",
    [2003] = "|cffffffff|Hitem:2003::::::::|h[Fallback Dust]|h|r",
}

local item_data = {
    [2001] = {
        name = "Sellable Girdle",
        quality = 2,
        itemType = "Armor",
        itemSubType = "Plate",
        itemEquipLoc = "INVTYPE_WAIST",
        classID = 4,
        subclassID = 4,
        icon = "icon-2001",
    },
    [2002] = {
        name = "Bound Blade",
        quality = 3,
        itemType = "Weapon",
        itemSubType = "Sword",
        itemEquipLoc = "INVTYPE_WEAPON",
        classID = 2,
        subclassID = 7,
        icon = "icon-2002",
    },
    [2003] = {
        name = "Fallback Dust",
        quality = 1,
        itemType = "Trade Goods",
        itemSubType = "Enchanting",
        itemEquipLoc = "",
        classID = 7,
        subclassID = 12,
        icon = "icon-2003",
        isCraftingReagent = true,
    },
}

local slot_infos = {
    [1] = { hyperlink = item_links[2001], stackCount = 1, quality = 2, iconFileID = "icon-2001" },
    [2] = { hyperlink = item_links[2001], stackCount = 2, quality = 2, iconFileID = "icon-2001" },
    [3] = { hyperlink = item_links[2002], stackCount = 1, quality = 3, iconFileID = "icon-2002" },
    [4] = { hyperlink = item_links[2003], stackCount = 5, quality = 1, iconFileID = "icon-2003" },
}

local function get_item_id(item_link)
    return tonumber(string.match(item_link or "", "item:(%d+)"))
end

local function build_category_options()
    local options = {
        { id = "all", label = "All" },
        { id = "armorWeapons", label = "Armor and Weapons" },
        { id = "crafting", label = "Crafting" },
        { id = "consumables", label = "Consumables" },
        { id = "transmog", label = "Transmog" },
        { id = "uncategorized", label = "Uncategorized" },
    }
    local by_id = {}
    for _, option in ipairs(options) do
        by_id[option.id] = option
    end
    return options, by_id
end

local function build_addon()
    local category_options, category_by_id = build_category_options()
    return {
        INVENTORY_CATEGORY_ALL_ID = "all",
        INVENTORY_CATEGORY_OPTIONS = category_options,
        INVENTORY_CATEGORY_BY_ID = category_by_id,
        TRACKED_ITEM_QUALITY_BY_ID = {
            [0] = { id = 0, label = "Poor" },
            [1] = { id = 1, label = "Common" },
            [2] = { id = 2, label = "Uncommon" },
            [3] = { id = 3, label = "Rare" },
        },
        VALUE_SOURCE_BY_ID = {
            TSM_DBMARKET = { id = "TSM_DBMARKET", label = "Market Value" },
            TSM_AUCTIONINGOPNORMAL = { id = "TSM_AUCTIONINGOPNORMAL", label = "Normal Price" },
        },
        db = {
            farmingItemFavorites = {},
        },
        GetFarmingFavoriteKey = function(_, row_or_item_id)
            local item_id = type(row_or_item_id) == "table" and row_or_item_id.itemID or row_or_item_id
            item_id = tonumber(item_id)
            return item_id and ("item:" .. tostring(math.floor(item_id + 0.5))) or nil
        end,
        GetFarmingFavoriteStore = function(self)
            return self.db and self.db.farmingItemFavorites or nil
        end,
        IsFarmingItemFavorite = function(self, row_or_item_id)
            local key = self:GetFarmingFavoriteKey(row_or_item_id)
            local favorites = self:GetFarmingFavoriteStore()
            return key ~= nil and type(favorites) == "table" and favorites[key] ~= nil
        end,
        GetAuctionableInventoryValueSource = function(self)
            return self.VALUE_SOURCE_BY_ID.TSM_DBMARKET
        end,
        GetConfiguredMinimumTrackedItemQuality = function()
            return 0
        end,
        IsBagItemBindingRestricted = function(_, _, slot_index)
            return slot_index == 3
        end,
        GetItemQualityFromLink = function(_, item_link)
            return item_data[get_item_id(item_link)].quality
        end,
        GetItemUnitValueFromSource = function(_, source_id, item_link)
            local item_id = get_item_id(item_link)
            if source_id == "TSM_DBMARKET" then
                return ({
                    [2001] = 5000,
                    [2002] = 9000,
                    [2003] = 0,
                })[item_id] or 0, source_id, "Market Value"
            end
            if source_id == "TSM_AUCTIONINGOPNORMAL" then
                return ({
                    [2003] = 3000,
                })[item_id] or 0, source_id, "Normal Price"
            end
            return 0, source_id, nil
        end,
        GetTSMRawCustomValue = function(_, source, item_link)
            local values = {
                DBRegionSoldPerDay = { [2001] = 12.2, [2003] = 2.1 },
                DBRegionSaleRate = { [2001] = 0.31, [2003] = 0.05 },
                DBMarket = { [2001] = 5000, [2003] = 0 },
                DBHistorical = { [2001] = 10000, [2003] = 6000 },
            }
            return values[source] and values[source][get_item_id(item_link)] or nil
        end,
        GetMarketHistorySampleCount = function(_, item_link)
            return get_item_id(item_link) == 2001 and 2 or 0
        end,
    }
end

local function with_loaded_inventory(addon, callback, ns_overrides)
    return loader.with_globals({
        BACKPACK_CONTAINER = 0,
        NUM_BAG_SLOTS = 0,
        Enum = {
            ItemClass = {
                Consumable = 0,
                Weapon = 2,
                Armor = 4,
                Tradegoods = 7,
            },
        },
        C_Container = {
            GetContainerNumSlots = function(bag_id)
                return bag_id == 0 and #slot_infos or 0
            end,
            GetContainerItemInfo = function(_, slot_index)
                return slot_infos[slot_index]
            end,
            GetContainerItemLink = function(_, slot_index)
                return slot_infos[slot_index] and slot_infos[slot_index].hyperlink or nil
            end,
        },
        C_Item = {
            GetItemInfo = function(item_link)
                local data = item_data[get_item_id(item_link)]
                return data.name,
                    item_links[get_item_id(item_link)],
                    data.quality,
                    nil,
                    nil,
                    data.itemType,
                    data.itemSubType,
                    nil,
                    data.itemEquipLoc,
                    data.icon,
                    nil,
                    data.classID,
                    data.subclassID,
                    nil,
                    nil,
                    nil,
                    data.isCraftingReagent
            end,
        },
        date = os.date,
        time = os.time,
    }, function()
        loader.load_module("Core/InventoryScan.lua", addon)
        return callback(loader.load_module("UI/InventoryWindow.lua", addon, ns_overrides))
    end)
end

local function make_text()
    return {
        SetText = function(self, text)
            self.text = text
        end,
        SetTextColor = function(self, r, g, b)
            self.text_color = { r, g, b }
        end,
        SetShown = function(self, shown)
            self.shown = shown
        end,
    }
end

local function make_panel()
    return {
        SetShown = function(self, shown)
            self.shown = shown
        end,
        SetHeight = function(self, height)
            self.height = height
        end,
    }
end

local function make_edit_box()
    return {
        SetText = function(self, text)
            self.text = text
        end,
        SetCursorPosition = function(self, position)
            self.cursor_position = position
        end,
        ClearFocus = function(self)
            self.cleared_focus = true
        end,
        SetShown = function(self, shown)
            self.shown = shown
        end,
    }
end

local function make_icon()
    return {
        SetTexture = function(self, texture)
            self.texture = texture
        end,
        Show = function(self)
            self.shown = true
        end,
        Hide = function(self)
            self.shown = false
        end,
    }
end

describe("UI/InventoryWindow auctionable rows", function()
    it("aggregates sellable stacks and excludes restricted bag items", function()
        with_loaded_inventory(build_addon(), function(addon)
            local rows, total_value, total_quantity, scanned_stacks, matched_stacks =
                addon:BuildInventoryAuctionItemList("TSM_DBMARKET", 2, 0, "itemName", true, "armorWeapons")

            assert.equals(1, #rows)
            assert.equals(2001, get_item_id(rows[1].itemLink))
            assert.equals(3, rows[1].quantity)
            assert.equals(2, rows[1].stackCount)
            assert.equals(15000, rows[1].totalValue)
            assert.equals(2, rows[1].marketHistorySampleCount)
            assert.equals(-50, rows[1].marketTrendPercent)
            assert.equals(15000, total_value)
            assert.equals(3, total_quantity)
            assert.equals(4, scanned_stacks)
            assert.equals(2, matched_stacks)
        end)
    end)

    it("falls back to the normal auctioning source when the selected source has no price", function()
        with_loaded_inventory(build_addon(), function(addon)
            local rows = addon:BuildInventoryAuctionItemList("TSM_DBMARKET", 1, 14999, "itemName", true, "all")

            assert.equals(2, #rows)
            assert.equals(2003, get_item_id(rows[1].itemLink))
            assert.equals("TSM_AUCTIONINGOPNORMAL", rows[1].valueSourceID)
            assert.is_true(rows[1].valueSourceWasFallback)
            assert.equals(15000, rows[1].totalValue)
        end)
    end)

    it("marks bag items that have indexed material farming maps", function()
        with_loaded_inventory(build_addon(), function(addon)
            local rows = addon:BuildInventoryAuctionItemList("TSM_DBMARKET", 1, 0, "itemName", true, "all")
            local by_id = {}
            for _, row in ipairs(rows) do
                by_id[row.itemID] = row
            end

            assert.equals(2001, by_id[2001].itemID)
            assert.is_true(addon:HasInventoryMaterialFarmingMap(by_id[2003]))
            assert.is_false(addon:HasInventoryMaterialFarmingMap(by_id[2001]))
        end, {
            MaterialFarmingSpots = {
                items = {
                    [2003] = {
                        itemID = 2003,
                        itemName = "Fallback Dust",
                        spots = {
                            {
                                mapName = "Nagrand",
                                coords = {
                                    { x = 0.10, y = 0.20 },
                                },
                            },
                        },
                    },
                },
            },
        })
    end)

    it("toggles bag items in the shared farming favorites store", function()
        with_loaded_inventory(build_addon(), function(addon)
            local refreshes = 0
            addon.RefreshInventoryWindow = function()
                refreshes = refreshes + 1
            end

            local row = {
                itemID = 2001,
                itemName = "Sellable Girdle",
                itemLink = item_links[2001],
                itemQuality = 2,
                iconTexture = "icon-2001",
                quantity = 3,
                stackCount = 2,
                totalValue = 15000,
                unitValue = 5000,
                valueSourceID = "TSM_DBMARKET",
                valueSourceLabel = "Market Value",
            }

            assert.is_true(addon:ToggleInventoryItemFavorite(row))
            assert.is_table(addon.db.farmingItemFavorites["item:2001"])
            assert.equals("inventory", addon.db.farmingItemFavorites["item:2001"].farmingSourceType)
            assert.equals("Bags", addon.db.farmingItemFavorites["item:2001"].locationLabel)

            assert.is_true(addon:ToggleInventoryItemFavorite(row))
            assert.is_nil(addon.db.farmingItemFavorites["item:2001"])
            assert.equals(2, refreshes)
        end, nil)
    end)

    it("shows a Wowhead item link in item details even without rare or instance context", function()
        with_loaded_inventory(build_addon(), function(addon)
            addon.inventoryItemDetailsFrame = {
                itemData = {
                    itemID = 2001,
                    itemName = "Sellable Girdle",
                    icon = "icon-2001",
                },
                itemIcon = make_icon(),
                itemText = make_text(),
                metaText = make_text(),
                wowheadPanel = make_panel(),
                wowheadTitleText = make_text(),
                wowheadItemEditBox = make_edit_box(),
                wowheadRareEditBox = make_edit_box(),
                wowheadRareLabelText = make_text(),
            }

            addon:RefreshInventoryItemDetailsWindow()

            local frame = addon.inventoryItemDetailsFrame
            assert.is_true(frame.wowheadPanel.shown)
            assert.equals(56, frame.wowheadPanel.height)
            assert.equals("https://www.wowhead.com/item=2001", frame.wowheadItemEditBox.text)
            assert.is_false(frame.wowheadRareEditBox.shown)
            assert.is_false(frame.wowheadRareLabelText.shown)
        end)
    end)
end)
