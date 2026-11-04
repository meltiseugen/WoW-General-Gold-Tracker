local loader = require("tests.helpers.addon_loader")

local base_farming_data = {
    expansions = {
        { id = "all", label = "All expansions" },
        { id = "classic", label = "Classic" },
        { id = "warWithin", label = "The War Within" },
    },
    professions = {
        { id = "all", label = "All professions" },
        { id = "mining", label = "Mining" },
        { id = "herbalism", label = "Herbalism" },
        { id = "skinning", label = "Skinning" },
        { id = "cooking", label = "Cooking" },
    },
    items = {
        { itemID = 3001, expansion = "classic", professions = { "mining" }, tag = "Ore" },
        { itemID = 3002, expansion = "warWithin", professions = { "herbalism" }, tag = "Herb" },
        { itemID = 3003, expansion = "classic", professions = { "herbalism" }, tag = "Herb" },
        { itemID = 3001, expansion = "classic", professions = { "mining" }, tag = "Duplicate" },
    },
}

local item_names = {
    [3001] = "Old Ore",
    [3002] = "New Herb",
    [3003] = "Old Herb",
    [3004] = "Custom Ore",
    [3005] = "Composed Bar",
    [3009] = "Session Meat",
    [3010] = "Nested Alloy",
    [3011] = "Lazy Ore",
}

local item_values = {
    [3001] = 1000,
    [3002] = 5000,
    [3003] = 100,
    [3004] = 7000,
    [3005] = 10000,
    [3009] = 2500,
    [3010] = 20000,
    [3011] = 4000,
}

local market_data = {
    DBRegionSoldPerDay = { [3001] = 4.2, [3002] = 12.2, [3004] = 0.8, [3005] = 1.1 },
    DBRegionSaleRate = { [3001] = 0.05, [3002] = 0.31, [3004] = 0.02, [3005] = 0.12 },
    DBMarket = { [3001] = 1500, [3002] = 2500, [3004] = 7000, [3005] = 15000 },
    DBHistorical = { [3001] = 1000, [3002] = 5000, [3004] = 3500, [3005] = 10000 },
}

local function get_item_id_from_string(item_string)
    return tonumber(string.match(item_string or "", "item:(%d+)"))
        or tonumber(string.match(item_string or "", "i:(%d+)"))
end

local function copy_farming_data(extra_items)
    local copied = {
        expansions = base_farming_data.expansions,
        professions = base_farming_data.professions,
        items = {},
    }
    for _, item in ipairs(base_farming_data.items) do
        copied.items[#copied.items + 1] = item
    end
    for _, item in ipairs(extra_items or {}) do
        copied.items[#copied.items + 1] = item
    end
    return copied
end

local function build_addon(frame_overrides)
    local custom_items = {
        { itemID = 3004, expansion = "classic", professions = { "mining" }, tag = "Custom" },
    }
    local frame = {
        valueSourceID = "TSM_DBMARKET",
        expansionID = "all",
        professionID = "all",
        itemCache = {},
        sortKey = "value",
        sortAscending = false,
    }
    for key, value in pairs(frame_overrides or {}) do
        frame[key] = value
    end
    for item_id, item_name in pairs(item_names) do
        frame.itemCache[tostring(item_id) .. "|TSM_DBMARKET"] = {
            itemID = item_id,
            itemName = item_name,
            itemLink = "|Hitem:" .. tostring(item_id) .. "::::::::|h[" .. item_name .. "]|h",
            itemQuality = 2,
            icon = "icon-" .. tostring(item_id),
            value = item_values[item_id],
            valueSourceID = "TSM_DBMARKET",
            valueSourceLabel = "Market Value",
        }
    end

    return {
        DEFAULTS = {
            craftingFarmingValueSource = "TSM_DBMARKET",
            craftingFarmingExpansionID = "classic",
            craftingFarmingProfessionID = "mining",
        },
        db = {
            craftingFarmingExpansionID = "classic",
            craftingFarmingProfessionID = "mining",
            craftingFarmingCustomItems = custom_items,
            farmingItemFavorites = {},
        },
        VALUE_SOURCE_BY_ID = {
            TSM_DBMARKET = {
                id = "TSM_DBMARKET",
                label = "Market Value",
                tsmKey = "DBMarket",
            },
        },
        craftingFarmingFrame = frame,
        GetAuctionableInventoryValueSource = function(self)
            return self.VALUE_SOURCE_BY_ID.TSM_DBMARKET
        end,
        GetCurrentValueSource = function(self)
            return self.VALUE_SOURCE_BY_ID.TSM_DBMARKET
        end,
        GetCraftingFarmingCustomItems = function(self)
            return self.db.craftingFarmingCustomItems
        end,
        GetSessionHistory = function(self)
            return self.history or {}
        end,
        GetItemIDFromLink = function(_, item_link)
            return tonumber(string.match(item_link or "", "item:(%d+)"))
        end,
        IsCraftingReagentItem = function(_, item_link)
            local item_id = tonumber(string.match(item_link or "", "item:(%d+)"))
            return item_id == 3006 or item_id == 3007 or item_id == 3008 or item_id == 3009
        end,
        IsLootItemBindingRestricted = function(_, item_link)
            local item_id = tonumber(string.match(item_link or "", "item:(%d+)"))
            return item_id == 3008
        end,
        AddCraftingFarmingCustomItem = function(self, item_id, expansion, profession, tag, _, metadata)
            local normalized = {
                itemID = item_id,
                expansion = expansion,
                professions = { profession },
                tag = tag,
                custom = true,
            }
            if type(metadata) == "table" then
                normalized.learnedFromSession = metadata.learnedFromSession == true
                normalized.importSource = metadata.importSource
            end
            self.db.craftingFarmingCustomItems[#self.db.craftingFarmingCustomItems + 1] = normalized
            return normalized
        end,
        GetTSMItemValueForItemID = function(_, _, item_id)
            return item_values[item_id] or 0
        end,
        GetTSMRawCustomValue = function(_, source, item_link)
            local item_id = get_item_id_from_string(item_link)
            return market_data[source] and market_data[source][item_id] or nil
        end,
    }
end

local function load_window(addon, farming_data, theme)
    return loader.with_globals({
        C_Item = {
            GetItemInfo = function(item_id)
                return item_names[item_id],
                    "|Hitem:" .. tostring(item_id) .. "::::::::|h[" .. item_names[item_id] .. "]|h",
                    2,
                    nil,
                    nil,
                    nil,
                    nil,
                    nil,
                    nil,
                    "icon-" .. tostring(item_id)
            end,
        },
    }, function()
        return loader.load_module("UI/CraftingFarmingWindow.lua", addon, {
            FarmingItems = farming_data or copy_farming_data(),
            MaterialFarmingSpots = addon.materialFarmingSpots,
            FarmCatalog = addon.farmCatalog,
            JanisTheme = theme,
        })
    end)
end

local function project_rows(rows)
    local projected = {}
    for _, row in ipairs(rows) do
        local current = {
            expansionID = row.expansionID,
            expansionLabel = row.expansionLabel,
            itemID = row.itemID,
            itemName = row.itemName,
            professionLabel = row.professionLabel,
            tag = row.tag,
            value = row.value,
        }
        if row.rowType then
            current.rowType = row.rowType
        end
        if row.isComposedMaterial then
            current.isComposedMaterial = row.isComposedMaterial
        end
        if row.componentQuantity then
            current.componentQuantity = row.componentQuantity
        end
        if row.componentCost then
            current.componentCost = row.componentCost
        end
        if row.profitValue then
            current.profitValue = row.profitValue
        end
        projected[#projected + 1] = current
    end
    return projected
end

describe("Materials display market history", function()
    it("records ordinary and expanded valued lists without an explicit snapshot action", function()
        local addon = load_window(build_addon())
        addon.DEFAULTS.marketHistoryRetentionDays = 120
        addon.DEFAULTS.marketHistoryMaxItems = 0
        addon.DEFAULTS.marketHistoryMaxSnapshotsPerItem = 240
        addon.GetTSMItemStringFromLink = function(_, link)
            local id = get_item_id_from_string(link)
            return id and ("i:" .. id)
        end
        loader.load_module("Core/MarketHistory.lua", addon)
        addon.FormatMoney = function(_, value) return tostring(value) end
        addon.GetCraftingFarmingWindowRow = function() return nil end
        addon.RefreshCraftingFarmingWindowLayout = function() end
        addon.UpdateCraftingFarmingSortHeaderState = function() end
        local function content()
            return { SetHeight = function() end }
        end
        addon.craftingFarmingFrame.content = content()
        local expanded = { content = content(), rows = {}, IsShown = function() return true end }
        addon.craftingFarmingExpandedFrame = expanded
        loader.with_globals({ time = function() return 1710000000 end, date = os.date }, function()
            addon:RefreshCraftingFarmingWindow(false, { synchronous = true, skipControls = true })
        end)
        local count = 0
        for _, row in ipairs(addon.craftingFarmingFrame.materialDisplayRows) do
            if row.itemID and row.value > 0 then
                local history = addon.db.marketHistory.items["i:" .. row.itemID]
                assert.is_table(history)
                assert.equals(1, #history.snapshots)
                assert.equals(row.value, history.snapshots[1].selectedUnitValue)
                count = count + 1
            end
        end
        assert.is_true(count > 0)
        assert.equals(addon.craftingFarmingFrame.materialDisplayRows, expanded.materialDisplayRows)
    end)
end)

describe("UI/CraftingFarmingWindow rows", function()
    local function protoform_window(expansionID)
        local data = copy_farming_data({
            {itemID=3005,expansion="shadowlands",professions={"protoformLattices"},tag="Protoform Lattice"},
        })
        data.expansions = {{id="all",label="All expansions"},{id="classic",label="Classic"},
            {id="shadowlands",label="Shadowlands"},{id="warWithin",label="The War Within"}}
        data.professions = {{id="all",label="All professions"},{id="mining",label="Mining"},
            {id="miscellaneous",label="Miscellaneous"},
            {id="protoformLattices",label="Protoform Lattices",expansion="shadowlands",browsingOnly=true}}
        return load_window(build_addon({expansionID=expansionID or "shadowlands",professionID="all"}),data)
    end

    it("shows Protoform Lattices only in Shadowlands and All expansions browsing menus", function()
        local addon = protoform_window()
        for _, expansionID in ipairs({"all","shadowlands","classic","warWithin"}) do
            local found = false
            for _, option in ipairs(addon:GetCraftingFarmingBrowseProfessionOptions(expansionID)) do
                if option.id == "protoformLattices" then found = true end
            end
            assert.equals(expansionID == "all" or expansionID == "shadowlands",found)
        end
        for _, option in ipairs(addon:GetCraftingFarmingProfessionOptions()) do
            assert.is_true(option.id ~= "protoformLattices")
        end
    end)

    it("moves lattice rows out of Miscellaneous and preserves category selection across All expansions", function()
        local addon = protoform_window()
        addon:SetCraftingFarmingProfessionFilter("protoformLattices")
        local rows = addon:BuildCraftingFarmingRows()
        assert.equals(1,#rows)
        assert.equals(3005,rows[1].itemID)
        assert.equals("Protoform Lattices",rows[1].professionLabel)
        addon:SetCraftingFarmingExpansionFilter("all")
        assert.equals("protoformLattices",addon.craftingFarmingFrame.professionID)
        assert.equals(3005,addon:BuildCraftingFarmingRows()[1].itemID)
        addon:SetCraftingFarmingProfessionFilter("miscellaneous")
        assert.same({},addon:BuildCraftingFarmingRows())
    end)

    it("resets scoped profession filters when leaving Shadowlands and rejects stale selections", function()
        local addon = protoform_window()
        addon:SetCraftingFarmingProfessionFilter("protoformLattices")
        addon:SetCraftingFarmingExpansionFilter("classic")
        assert.equals("all",addon.craftingFarmingFrame.professionID)
        assert.same({all=true},addon.craftingFarmingFrame.professionIDs)
        assert.equals("all",addon.db.craftingFarmingProfessionID)
        assert.same({"all"},addon.db.craftingFarmingProfessionIDs)
        assert.equals("all",addon:SetCraftingFarmingProfessionFilter("protoformLattices"))
        assert.same({all=true},addon:ToggleCraftingFarmingProfessionFilter("protoformLattices"))
        addon.craftingFarmingFrame.professionID = "protoformLattices"
        addon.craftingFarmingFrame.professionIDs = {protoformLattices=true}
        assert.is_true(#addon:BuildCraftingFarmingRows() > 0)
    end)

    local function load_uncached_classic_materials()
        local _, catalog = loader.load_module("Data/MaterialIndex.lua", {})
        local _, farming = loader.load_module("Data/FarmingItems.lua", {})
        local addon = build_addon({ expansionID = "classic", professionID = "enchanting", raidMaterialsExpanded = true })
        addon.craftingFarmingFrame.itemCache = {}
        addon.db.craftingFarmingCustomItems = {}
        loader.load_module("UI/CraftingFarmingWindow.lua", addon, {
            FarmingItems = farming.FarmingItems,
            MaterialIndex = catalog.MaterialIndex,
        })
        return addon, catalog.MaterialIndex.items
    end

    it("shows catalog names for uncached Classic enchanting materials and accepts localized item data later", function()
        local addon, catalog = load_uncached_classic_materials()
        local requested = {}
        loader.with_globals({ C_Item = {
            GetItemInfo = function() return nil end,
            RequestLoadItemDataByID = function(itemID) requested[itemID] = true end,
        } }, function()
            local by_id = {}
            for _, row in ipairs(addon:BuildCraftingFarmingRows({ deferMetrics = true })) do
                if row.itemID then by_id[row.itemID] = row end
            end
            for _, itemID in ipairs({ 10978, 10998, 11082, 11083, 11084, 11134, 11135, 11137,
                11138, 11139, 11174, 11175, 11176, 11177, 11178, 20725 }) do
                assert.equals(catalog[itemID].itemName, by_id[itemID].itemName)
                assert.is_nil(by_id[itemID].itemLink)
                assert.is_true(requested[itemID])
            end
            assert.equals("Nexus Crystal", by_id[20725].itemName)
        end)
        loader.with_globals({ C_Item = { GetItemInfo = function(itemID)
            if itemID == 10978 then
                return "Localized Shard", "|Hitem:10978|h[Localized Shard]|h", 3
            end
        end } }, function()
            addon:UpdateCraftingFarmingItemDisplayData(10978)
            local cache = addon.craftingFarmingFrame.itemCache["10978|TSM_DBMARKET"]
            assert.equals("Localized Shard", cache.itemName)
            assert.equals("|Hitem:10978|h[Localized Shard]|h", cache.itemLink)
            assert.equals(3, cache.itemQuality)
        end)
    end)

    it("finds uncached materials by catalog name while still requesting item data", function()
        local addon = load_uncached_classic_materials()
        addon.craftingFarmingFrame.searchText = "greater astral"
        local requested = {}
        loader.with_globals({ C_Item = {
            GetItemInfo = function() return nil end,
            RequestLoadItemDataByID = function(itemID) requested[itemID] = true end,
        } }, function()
            local rows = addon:BuildCraftingFarmingRows({ deferMetrics = true })
            assert.equals(1, #rows)
            assert.equals(11082, rows[1].itemID)
            assert.equals("Greater Astral Essence", rows[1].itemName)
            assert.is_true(requested[11082])
        end)
    end)

    it("uses researched names when an uncached material has no index entry", function()
        local addon = build_addon({ expansionID = "classic", professionID = "mining" })
        addon.craftingFarmingFrame.itemCache = {}
        loader.load_module("UI/CraftingFarmingWindow.lua", addon, {
            FarmingItems = copy_farming_data(),
            MaterialFarmingSpots = { items = { [3001] = { itemName = "Researched Ore" } } },
        })
        loader.with_globals({ C_Item = { GetItemInfo = function() return nil end } }, function()
            local rows = addon:BuildCraftingFarmingRows({ deferMetrics = true })
            local names = {}
            for _, row in ipairs(rows) do names[row.itemID] = row.itemName end
            assert.equals("Researched Ore", names[3001])
        end)
    end)

    it("fits long Type text and keeps its header and neighboring column aligned in both views", function()
        assert(loadfile("Libs/JanisTheme-1.0/JanisTheme-1.0.lua"))()
        local _, ns = loader.load_module("UI/Theme.lua", {})
        local addon = load_window(build_addon(), nil, ns.JanisTheme)
        local function column(textWidth)
            return {
                ClearAllPoints = function() end,
                SetPoint = function(self, _, _, _, x) self.x = x end,
                SetWidth = function(self, width) self.width = width end,
                GetUnboundedStringWidth = function() return textWidth end,
            }
        end
        for _, target in ipairs({ addon.craftingFarmingFrame, {} }) do
            target.scrollFrame = { GetWidth = function() return 900 end }
            target.content = { SetWidth = function() end }
            target.listPanel = {}
            target.tagHeaderButton = column(0)
            target.rows = { { tagText = column(231), valueText = column(0) } }
            addon:RefreshCraftingFarmingWindowLayout(target)
            local tag = target.rows[1].tagText
            assert.equals(241, tag.width)
            assert.equals(tag.width, target.tagHeaderButton.width)
            assert.equals(tag.x + 12, target.tagHeaderButton.x)
            assert.is_true(target.rows[1].valueText.x >= tag.x + tag.width + 8)
        end
    end)

    it("collapses composed materials on expansion, profession and value-source selection changes", function()
        local addon = load_window(build_addon())
        local changes = {
            function() addon:SetCraftingFarmingExpansionFilter("classic") end,
            function() addon:SetCraftingFarmingProfessionFilter("mining") end,
            function() addon:ToggleCraftingFarmingProfessionFilter("herbalism") end,
            function() addon:SetCraftingFarmingValueSource("TSM_DBMARKET") end,
        }
        for _, change in ipairs(changes) do
            addon.craftingFarmingFrame.composedMaterialsExpanded = true
            addon.craftingFarmingFrame.expandedComposedMaterials = { [3005] = true }
            change()
            assert.is_false(addon.craftingFarmingFrame.composedMaterialsExpanded)
            assert.same({}, addon.craftingFarmingFrame.expandedComposedMaterials)
        end
    end)

    it("invalidates expanded results and pending prices when composed materials collapse", function()
        local addon = load_window(build_addon({
            composedMaterialsExpanded = true,
            materialDisplayRows = { { itemID = 3005 } },
            materialsRefreshGeneration = 3,
            materialsRealtimeLoading = true,
        }))
        addon.craftingFarmingExpandedFrame = { materialDisplayRows = { { itemID = 3005 } } }
        assert.is_true(addon:CollapseCraftingFarmingComposedMaterials())
        assert.is_nil(addon.craftingFarmingFrame.materialDisplayRows)
        assert.is_nil(addon.craftingFarmingExpandedFrame.materialDisplayRows)
        assert.equals(4, addon.craftingFarmingFrame.materialsRefreshGeneration)
        assert.is_false(addon.craftingFarmingFrame.materialsRealtimeLoading)
        assert.is_false(addon:CollapseCraftingFarmingComposedMaterials())
    end)

    it("renders herb coordinates as a route without requiring a redundant spot flag", function()
        local addon = build_addon()
        addon.materialFarmingSpots = {
            items = {
                [3002] = {
                    itemID = 3002,
                    itemName = "New Herb",
                    spots = {
                        {
                            id = "new-herb-loop",
                            mapName = "Nagrand",
                            coords = {
                                { x = 0.20, y = 0.30 },
                                { x = 0.40, y = 0.50 },
                            },
                        },
                    },
                },
            },
        }
        addon = load_window(addon)

        local options = addon:BuildMaterialFarmingMapOptions(3002)

        assert.equals(1, #options)
        assert.equals(2, #options[1].pins)
        assert.is_true(options[1].pins[1].isRoute)
        assert.is_true(options[1].pins[2].isRoute)
        assert.equals("new-herb-loop", options[1].pins[1].routeID)
    end)

    it("provides a separate expanded materials results window", function()
        local addon = load_window(build_addon())

        assert.is_function(addon.CreateCraftingFarmingExpandedWindow)
        assert.is_function(addon.RefreshCraftingFarmingExpandedWindow)
        assert.is_function(addon.OpenCraftingFarmingExpandedWindow)
    end)

    it("builds a stable sorted materials snapshot", function()
        local addon = load_window(build_addon())

        assert.same(require("tests.snapshots.crafting_farming_rows"), project_rows(addon:BuildCraftingFarmingRows()))
    end)

    it("filters materials by expansion and profession while keeping custom items", function()
        local addon = load_window(build_addon({
            expansionID = "classic",
            professionID = "mining",
        }))

        local rows = project_rows(addon:BuildCraftingFarmingRows())

        assert.equals(2, #rows)
        assert.equals(3004, rows[1].itemID)
        assert.equals(3001, rows[2].itemID)
    end)

    it("shows one profession across all expansions", function()
        local addon = load_window(build_addon({
            expansionID = "classic",
            professionID = "mining",
        }))

        addon:SetCraftingFarmingExpansionFilter("all")
        addon:SetCraftingFarmingProfessionFilter("herbalism")
        local rows = project_rows(addon:BuildCraftingFarmingRows())

        assert.equals("all", addon.db.craftingFarmingExpansionID)
        assert.equals("herbalism", addon.db.craftingFarmingProfessionID)
        assert.equals(2, #rows)
        assert.equals(3002, rows[1].itemID)
        assert.equals("warWithin", rows[1].expansionID)
        assert.equals(3003, rows[2].itemID)
        assert.equals("classic", rows[2].expansionID)
    end)

    it("searches item names across all expansions and professions", function()
        local addon = load_window(build_addon({
            expansionID = "classic",
            professionID = "mining",
            searchText = "  NEW h  ",
        }))

        local rows = project_rows(addon:BuildCraftingFarmingRows())

        assert.equals(1, #rows)
        assert.equals(3002, rows[1].itemID)
        assert.equals("New Herb", rows[1].itemName)
        assert.equals("warWithin", rows[1].expansionID)
        assert.equals("Herbalism", rows[1].professionLabel)
    end)

    it("treats search punctuation as literal text", function()
        local addon = load_window(build_addon({
            searchText = "%",
        }))

        assert.same({}, addon:BuildCraftingFarmingRows())
    end)

    it("excludes unsellable products, Darkmoon products and world-drop mounts across filters and search", function()
        local excluded = {
            { tag = "Bound Crafting Input" },
            { tag = "Bound Reagent" },
            { auctionable = false },
            { supportOnly = true },
            { tag = "Darkmoon Card" },
            { itemName = "Darkmoon Deck: Test" },
            { tag = "World Drop Mount" },
            { tag = "Augment Rune" },
            { itemName = "Battle-Scarred Augment Rune" },
            { itemID = 160053 },
            { itemID = 181468 },
            { itemID = 163131 },
        }
        for _, properties in ipairs(excluded) do
            local item = { itemID = 3005, expansion = "classic", professions = { "mining" } }
            for key, value in pairs(properties) do item[key] = value end
            for _, search in ipairs({ "", "Composed" }) do
                local addon = load_window(build_addon({ expansionID = "all", searchText = search,
                    composedMaterialsExpanded = true, raidMaterialsExpanded = true }), copy_farming_data({ item }))
                for _, row in ipairs(addon:BuildCraftingFarmingRows()) do
                    assert.is_true(row.itemID ~= item.itemID)
                end
            end
        end
    end)

    it("keeps bound recipe inputs expandable without listing them as sale products", function()
        local data = copy_farming_data({
            { itemID = 3010, expansion = "classic", professions = { "mining" }, auctionable = false,
                tag = "Bound Crafting Input", components = { { itemID = 3001, quantity = 3 } } },
            { itemID = 3005, expansion = "classic", professions = { "mining" }, auctionable = true,
                components = { { itemID = 3010, quantity = 2 } } },
        })
        local addon = load_window(build_addon({ expansionID = "classic", composedMaterialsExpanded = true,
            expandedComposedMaterials = { [3005] = true } }), data)
        local foundProduct, foundComponent = false, false
        for _, row in ipairs(addon:BuildCraftingFarmingRows()) do
            if row.itemID == 3005 then foundProduct = true end
            if row.itemID == 3010 then
                assert.equals("component", row.rowType)
                foundComponent = true
            end
        end
        assert.is_true(foundProduct)
        assert.is_true(foundComponent)
    end)

    it("honors non-auctionable research metadata when the base item has no binding flag", function()
        local addon = build_addon({ expansionID = "all", searchText = "Composed" })
        addon.materialFarmingSpots = { items = { [3005] = { auctionable = false } } }
        addon = load_window(addon, copy_farming_data({
            { itemID = 3005, expansion = "classic", professions = { "mining" } },
        }))
        for _, row in ipairs(addon:BuildCraftingFarmingRows()) do assert.is_true(row.itemID ~= 3005) end
    end)

    it("groups dungeon mining materials under the collapsed Instance items header", function()
        local data = copy_farming_data({
            {
                itemID = 3011,
                expansion = "classic",
                professions = { "mining" },
                tag = "Dungeon Ore",
                acquisitionType = "instance",
            },
        })
        local addon = load_window(build_addon({
            expansionID = "classic",
            professionID = "mining",
        }), data)

        local rows = addon:BuildCraftingFarmingRows()

        assert.equals(3004, rows[1].itemID)
        assert.equals(3001, rows[2].itemID)
        assert.equals("divider", rows[3].rowType)
        assert.equals("Instance items", rows[3].label)
        assert.equals("raidMaterials", rows[3].dividerKind)
        assert.is_false(rows[3].expanded)
        assert.equals(3, #rows)

        addon.craftingFarmingFrame.raidMaterialsExpanded = true
        rows = addon:BuildCraftingFarmingRows()
        assert.equals(3011, rows[4].itemID)
        assert.equals("instance", rows[4].acquisitionType)
    end)

    it("keeps raid and dungeon items collapsed across every expansion and profession", function()
        for _, expansion in ipairs(base_farming_data.expansions) do
            for _, profession in ipairs(base_farming_data.professions) do
                local data = copy_farming_data({
                    { itemID = 3011, expansion = "classic", professions = { profession.id }, isRaidMaterial = true },
                    { itemID = 3010, expansion = "warWithin", professions = { profession.id }, acquisitionType = "raid-drop" },
                    { itemID = 3009, expansion = "classic", professions = { profession.id }, tag = "Dungeon Reagent" },
                    { itemID = 3005, expansion = "warWithin", professions = { profession.id }, acquisitionType = "dungeon-drop" },
                })
                local addon = load_window(build_addon({ expansionID = expansion.id, professionID = profession.id }), data)
                local rows = addon:BuildCraftingFarmingRows()
                local divider = rows[#rows]
                assert.equals("raidMaterials", divider.dividerKind)
                assert.is_false(divider.expanded)
                for _, row in ipairs(rows) do
                    assert.is_true(row.itemID ~= 3011 and row.itemID ~= 3010
                        and row.itemID ~= 3009 and row.itemID ~= 3005)
                end
                addon.craftingFarmingFrame.raidMaterialsExpanded = true
                local found = {}
                for _, row in ipairs(addon:BuildCraftingFarmingRows()) do
                    if row.itemID then found[row.itemID] = true end
                end
                assert.equals(expansion.id ~= "warWithin", found[3011] == true)
                assert.equals(expansion.id ~= "classic", found[3010] == true)
                assert.equals(expansion.id ~= "warWithin", found[3009] == true)
                assert.equals(expansion.id ~= "classic", found[3005] == true)
            end
        end
    end)

    it("filters elemental IDs by expansion while retaining their profession links and composed groups", function()
        local data = copy_farming_data({
            { itemID = 3005, expansion = "classic", professions = { "mining" },
                components = { { itemID = 3001, quantity = 10 } } },
        })
        data.elementalItemIDs = { [3001] = true, [3002] = true, [3005] = true }
        local addon = load_window(build_addon({ expansionID = "classic", professionID = "elemental" }), data)
        local rows = addon:BuildCraftingFarmingRows()
        assert.equals(2, #rows)
        assert.equals(3001, rows[1].itemID)
        assert.equals("Mining", rows[1].professionLabel)
        assert.equals("composedMaterials", rows[2].dividerKind)

        addon.craftingFarmingFrame.composedMaterialsExpanded = true
        rows = addon:BuildCraftingFarmingRows()
        assert.equals(3005, rows[3].itemID)
        addon:SetCraftingFarmingExpansionFilter("warWithin")
        rows = addon:BuildCraftingFarmingRows()
        assert.equals(1, #rows)
        assert.equals(3002, rows[1].itemID)
        addon:ToggleCraftingFarmingProfessionFilter("elemental")
        assert.same({ "elemental" }, addon.db.craftingFarmingProfessionIDs)

        addon:SetCraftingFarmingExpansionFilter("classic")
        addon:ToggleCraftingFarmingProfessionFilter("mining")
        rows = addon:BuildCraftingFarmingRows()
        local found = {}
        for _, row in ipairs(rows) do found[row.itemID or row.dividerKind] = true end
        assert.is_true(found[3001])
        assert.is_true(found[3004])
        for _, option in ipairs(addon:GetCraftingFarmingProfessionOptions()) do
            assert.is_false(option.id == "elemental" or option.id == "raidItems")
        end
    end)

    it("does not infer elemental membership from names or from recipe components", function()
        local data = copy_farming_data({
            { itemID = 3005, itemName = "Primal Diamond", tag = "Elemental", expansion = "classic",
                professions = { "mining" }, components = { { itemID = 3001, quantity = 2 } } },
        })
        data.elementalItemIDs = { [3001] = true }
        local addon = load_window(build_addon({ professionID = "elemental", composedMaterialsExpanded = true }), data)
        local rows = addon:BuildCraftingFarmingRows()
        assert.equals(1, #rows)
        assert.equals(3001, rows[1].itemID)
    end)

    it("covers elemental catalog families across every expansion and keeps bound inputs hidden", function()
        local ns = {}
        assert(loadfile("Data/FarmingItems.lua"))("General-Gold-Tracker", ns)
        local data = ns.FarmingItems
        local expected_counts = {
            classic = 14, burningCrusade = 17, wrath = 12, cataclysm = 5, mists = 2,
            warlords = 4, legion = 1, battleForAzeroth = 0, shadowlands = 2,
            dragonflight = 14, warWithin = 0, midnight = 4, all = 75,
        }
        local addon = build_addon({ professionID = "elemental", raidMaterialsExpanded = true,
            composedMaterialsExpanded = true })
        addon.materialFarmingSpots = { items = {} }
        addon.db.craftingFarmingCustomItems = {}
        addon = load_window(addon, data)
        for _, expansion in ipairs(data.expansions) do
            addon.craftingFarmingFrame.expansionID = expansion.id
            local count = 0
            for _, row in ipairs(addon:BuildCraftingFarmingRows()) do
                if row.itemID then
                    count = count + 1
                    assert.is_true(data.elementalItemIDs[row.itemID])
                    assert.is_true(expansion.id == "all" or expansion.id == row.expansionID)
                end
            end
            assert.equals(expected_counts[expansion.id], count)
        end
    end)

    it("filters raid items by expansion using categories, routes and acquisition metadata", function()
        local addon = build_addon({ expansionID = "classic", professionID = "raidItems", raidMaterialsExpanded = true })
        addon.materialFarmingSpots = { items = {
            [3011] = { category = "Raid Reagent" },
            [3010] = { spots = { { routeType = "disenchant-raid-gear-farm" } } },
        } }
        addon = load_window(addon, copy_farming_data({
            { itemID = 3011, expansion = "classic", professions = { "mining" } },
            { itemID = 3010, expansion = "classic", professions = { "herbalism" } },
            { itemID = 3005, expansion = "warWithin", professions = { "skinning" }, acquisitionType = "raid-drop" },
        }))
        local rows = addon:BuildCraftingFarmingRows()
        assert.equals(3, #rows)
        assert.equals("raidMaterials", rows[1].dividerKind)
        assert.equals(3010, rows[2].itemID)
        assert.equals(3011, rows[3].itemID)
        assert.equals("Herbalism", rows[2].professionLabel)
        addon:SetCraftingFarmingExpansionFilter("warWithin")
        rows = addon:BuildCraftingFarmingRows()
        assert.equals(2, #rows)
        assert.equals(3005, rows[2].itemID)
        addon:SetCraftingFarmingExpansionFilter("all")
        assert.equals(4, #addon:BuildCraftingFarmingRows())
        addon:ToggleCraftingFarmingProfessionFilter("raidItems")
        assert.same({ "raidItems" }, addon.db.craftingFarmingProfessionIDs)
    end)

    it("defers raid pricing while collapsed and preserves composed drill-down inside the raid group", function()
        local data = copy_farming_data({
            { itemID = 3005, expansion = "classic", professions = { "mining" }, tag = "Dungeon Reagent",
                components = { { itemID = 3011, quantity = 2 } } },
        })
        local addon = build_addon({ professionID = "raidItems", expandedComposedMaterials = { [3005] = true } })
        addon.craftingFarmingFrame.itemCache = {}
        local lookups = 0
        addon.GetTSMItemValueForItemID = function(_, _, itemID)
            lookups = lookups + 1
            return item_values[itemID] or 0
        end
        addon = load_window(addon, data)
        assert.equals(1, #addon:BuildCraftingFarmingRows())
        assert.equals(0, lookups)
        addon.craftingFarmingFrame.raidMaterialsExpanded = true
        local rows = addon:BuildCraftingFarmingRows()
        assert.equals(3, #rows)
        assert.equals(3005, rows[2].itemID)
        assert.equals(8000, rows[2].componentCost)
        assert.equals("component", rows[3].rowType)
        assert.equals(3011, rows[3].itemID)
        assert.is_true(lookups > 0)
    end)

    it("includes dungeon sources in the raid filter without including recipe inputs or recipe locations", function()
        local addon = build_addon({ professionID = "raidItems", raidMaterialsExpanded = true })
        addon.materialFarmingSpots = { items = {
            [3011] = { category = "Dungeon Reagent", spots = { { routeType = "instance-boss" } } },
        } }
        addon = load_window(addon, copy_farming_data({
            { itemID = 3011, expansion = "classic", professions = { "mining" }, acquisitionType = "instance" },
            { itemID = 3005, expansion = "classic", professions = { "mining" },
                components = { { itemID = 3010, quantity = 2 } }, recipeSourceLabel = "Drop: Dungeons" },
            { itemID = 3010, expansion = "classic", professions = { "mining" }, isRaidMaterial = true },
        }))
        local rows = addon:BuildCraftingFarmingRows()
        assert.equals(3, #rows)
        assert.equals(3010, rows[2].itemID)
        assert.equals(3011, rows[3].itemID)
    end)

    it("recognizes dungeon and delve metadata on catalog items, research records and nested spots", function()
        for _, field in ipairs({ "acquisitionType", "tag", "category", "routeType" }) do
            for _, sourceType in ipairs({ "Dungeon Reagent", "dungeon-boss", "instance", "Instances",
                "Delve Reagent", "delve-container", "Delves", "delve-container-farm" }) do
                for _, location in ipairs({ "item", "research", "spot" }) do
                    local item = { itemID = 3011, expansion = "classic", professions = { "mining" } }
                    local record = { [field] = sourceType }
                    local addon = build_addon({ professionID = "raidItems", raidMaterialsExpanded = true })
                    if location == "item" then
                        item[field] = sourceType
                    else
                        addon.materialFarmingSpots = { items = {
                            [3011] = location == "spot" and { spots = { record } } or record,
                        } }
                    end
                    addon = load_window(addon, copy_farming_data({ item }))
                    local rows = addon:BuildCraftingFarmingRows()
                    assert.equals(2, #rows)
                    assert.equals("raidMaterials", rows[1].dividerKind)
                    assert.equals(3011, rows[2].itemID)
                end
            end
        end
    end)

    it("prices bait through the shared fallback chain and retains fractional TSM demand", function()
        local data = {
            expansions = { { id = "all", label = "All expansions" }, { id = "warlords", label = "Warlords of Draenor" } },
            professions = { { id = "all", label = "All professions" }, { id = "fishing", label = "Fishing" } },
            items = {},
        }
        for _, itemID in ipairs({ 110274, 110294, 110290, 128229 }) do
            data.items[#data.items + 1] = { itemID = itemID, expansion = "warlords", professions = { "fishing" }, tag = "Fishing Bait" }
        end
        local addon = build_addon({ valueSourceID = "TSM_DBMINBUYOUT" })
        addon.db.craftingFarmingCustomItems = {}
        addon.craftingFarmingFrame.itemCache = {}
        addon.VALUE_SOURCE_BY_ID.TSM_DBMINBUYOUT = { id = "TSM_DBMINBUYOUT", label = "Min Buyout", tsmKey = "DBMinBuyout" }
        addon.VALUE_SOURCE_BY_ID.TSM_DBREGIONMARKETAVG = { id = "TSM_DBREGIONMARKETAVG", label = "Region Market Value Avg", tsmKey = "DBRegionMarketAvg" }
        addon.GetValueSourceResolutionOrder = function(_, preferred)
            return { preferred, "TSM_DBMARKET", "TSM_DBREGIONMARKETAVG" }
        end
        addon = loader.load_module("Tracking/Valuation.lua", load_window(addon, data))
        local query_count = 0
        loader.with_globals({ TSM_API = { GetCustomPriceValue = function(expression, itemString)
            query_count = query_count + 1
            local values = {
                ["i:110274"] = { DBMarket = 120200, DBHistorical = 120000 },
                ["i:110294"] = { DBRegionMarketAvg = 178400, DBHistorical = 1100098 },
                ["i:110290"] = { DBMinBuyout = 950, DBMarket = 1800 },
            }
            if expression == "1000 * DBRegionSaleRate" or expression == "1000 * DBRegionSoldPerDay" then return 2 end
            return (values[itemString] or {})[expression]
        end } }, function()
            addon:BuildCraftingFarmingRows({ deferMetrics = true })
            assert.equals(0, query_count)
            addon.craftingFarmingFrame.itemCache = {}
            local found = {}
            for _, row in ipairs(addon:BuildCraftingFarmingRows()) do found[row.itemID] = row end
            assert.equals(120200, found[110274].value)
            assert.equals("TSM_DBMARKET", found[110274].valueSourceID)
            assert.is_true(found[110274].valueSourceWasFallback)
            assert.equals(178400, found[110294].value)
            assert.equals("Region Market Value Avg", found[110294].valueSourceLabel)
            assert.is_true(found[110294].valueSourceWasFallback)
            assert.equals(950, found[110290].value)
            assert.equals("TSM_DBMINBUYOUT", found[110290].valueSourceID)
            assert.is_false(found[110290].valueSourceWasFallback)
            assert.equals(0, found[128229].value)
            assert.equals("TSM_DBMINBUYOUT", found[128229].valueSourceID)
            assert.is_false(found[128229].valueSourceWasFallback)
            assert.equals(0.002, found[110294].regionSoldPerDay)
            assert.equals(0.002, found[110294].regionSaleRate)
            assert.equals("slow", found[110294].demandTier)

            local pending = {}
            local refresh = addon.RefreshCraftingFarmingWindow
            addon.craftingFarmingFrame.content = {}
            addon.RefreshCraftingFarmingWindow = function(self, scrollToTop, options)
                if options and options.renderOnly then
                    self.craftingFarmingFrame.materialDisplayRows = options.rows
                    return
                end
                return refresh(self, scrollToTop, options)
            end
            loader.with_globals({ C_Timer = { After = function(_, callback) pending[#pending + 1] = callback end } }, function()
                local previousQueries = query_count
                addon:RefreshCraftingFarmingWindow()
                assert.equals(previousQueries, query_count)
                assert.is_true(addon.craftingFarmingFrame.materialsRealtimeLoading)
                while #pending > 0 do table.remove(pending, 1)() end
                assert.is_false(addon.craftingFarmingFrame.materialsRealtimeLoading)
                local asyncRows = {}
                for _, row in ipairs(addon.craftingFarmingFrame.materialDisplayRows) do asyncRows[row.itemID] = row end
                for itemID, expected in pairs(found) do
                    assert.equals(expected.value, asyncRows[itemID].value)
                    assert.equals(expected.valueSourceID, asyncRows[itemID].valueSourceID)
                    assert.equals(expected.valueSourceWasFallback, asyncRows[itemID].valueSourceWasFallback)
                    assert.equals(expected.regionSoldPerDay, asyncRows[itemID].regionSoldPerDay)
                end
            end)
        end)
    end)

    it("adds sortable regional demand, sell rate, and market trend data", function()
        local addon = load_window(build_addon({
            sortKey = "demand",
            sortAscending = false,
        }))

        local rows = addon:BuildCraftingFarmingRows()

        assert.equals(3002, rows[1].itemID)
        assert.equals(12.2, rows[1].regionSoldPerDay)
        assert.equals(0.31, rows[1].regionSaleRate)
        assert.equals("Fast", rows[1].demandLabel)
        assert.equals(-50, rows[1].marketTrendPercent)
    end)

    it("can build placeholder rows without reusing or querying market values", function()
        local addon = build_addon({ materialsDemandCache = {} })
        addon.craftingFarmingFrame.itemCache = {}
        local selected_value_calls = 0
        local regional_value_calls = 0
        addon.GetTSMItemValueForItemID = function()
            selected_value_calls = selected_value_calls + 1
            return 9999
        end
        addon.GetTSMRawCustomValue = function()
            regional_value_calls = regional_value_calls + 1
            return 9999
        end
        addon = load_window(addon)

        local rows = addon:BuildCraftingFarmingRows({ deferMetrics = true })

        assert.is_true(#rows > 0)
        assert.equals(0, selected_value_calls)
        assert.equals(0, regional_value_calls)
        for _, row in ipairs(rows) do
            if row.itemID then
                assert.equals(0, row.value)
            end
        end
    end)

    it("saves and removes material favorites in the shared item store", function()
        local addon = load_window(build_addon())
        local material_row
        for _, row in ipairs(addon:BuildCraftingFarmingRows()) do
            if row.itemID == 3001 then
                material_row = row
                break
            end
        end

        assert.is_false(addon:IsCraftingFarmingFavorite(material_row))
        assert.is_true(addon:SetCraftingFarmingFavorite(material_row, true))

        local favorite = addon.db.farmingItemFavorites["item:3001"]
        assert.is_table(favorite)
        assert.equals(3001, favorite.itemID)
        assert.equals("Old Ore", favorite.itemName)
        assert.equals("material", favorite.farmingSourceType)
        assert.equals("Mining", favorite.materialProfessionLabel)
        assert.equals("Classic", favorite.expansionFilterLabel)
        assert.is_true(addon:IsCraftingFarmingFavorite(3001))

        assert.is_true(addon:SetCraftingFarmingFavorite(material_row, false))
        assert.is_nil(addon.db.farmingItemFavorites["item:3001"])
    end)

    it("uses the primary profession when legacy state contains multiple selected professions", function()
        local addon = load_window(build_addon({
            expansionID = "classic",
            professionID = "mining",
            professionIDs = {
                mining = true,
                herbalism = true,
            },
        }))

        local rows = project_rows(addon:BuildCraftingFarmingRows())

        assert.equals(2, #rows)
        assert.equals(3004, rows[1].itemID)
        assert.equals(3001, rows[2].itemID)
    end)

    it("keeps single-select profession dropdown state and label stable", function()
        local addon = load_window(build_addon({
            professionID = "all",
            professionIDs = { all = true },
        }))
        local dropdown = {}
        addon.craftingFarmingFrame.professionDropdown = dropdown
        local dropdown_texts = {}

        loader.with_globals({
            UIDropDownMenu_SetSelectedValue = function() end,
            UIDropDownMenu_SetText = function(target, text)
                assert.equals(dropdown, target)
                dropdown_texts[#dropdown_texts + 1] = text
            end,
        }, function()
            addon:RefreshCraftingFarmingWindowControls()
            assert.equals("All professions", dropdown_texts[#dropdown_texts])

            addon:ToggleCraftingFarmingProfessionFilter("mining")
            addon:RefreshCraftingFarmingWindowControls()
            assert.is_true(addon.craftingFarmingFrame.professionIDs.mining)
            assert.is_nil(addon.craftingFarmingFrame.professionIDs.all)
            assert.same({ "mining" }, addon.db.craftingFarmingProfessionIDs)
            assert.equals("Mining", dropdown_texts[#dropdown_texts])

            addon:ToggleCraftingFarmingProfessionFilter("herbalism")
            addon:RefreshCraftingFarmingWindowControls()
            assert.is_true(addon.craftingFarmingFrame.professionIDs.herbalism)
            assert.is_nil(addon.craftingFarmingFrame.professionIDs.mining)
            assert.same({ "herbalism" }, addon.db.craftingFarmingProfessionIDs)
            assert.equals("Herbalism", dropdown_texts[#dropdown_texts])

            addon:ToggleCraftingFarmingProfessionFilter("mining")
            addon:RefreshCraftingFarmingWindowControls()
            assert.is_true(addon.craftingFarmingFrame.professionIDs.mining)
            assert.is_nil(addon.craftingFarmingFrame.professionIDs.herbalism)
            assert.same({ "mining" }, addon.db.craftingFarmingProfessionIDs)
            assert.equals("Mining", dropdown_texts[#dropdown_texts])

            addon:ToggleCraftingFarmingProfessionFilter("herbalism")
            addon:RefreshCraftingFarmingWindowControls()
            assert.is_true(addon.craftingFarmingFrame.professionIDs.herbalism)
            assert.is_nil(addon.craftingFarmingFrame.professionIDs.mining)
            assert.same({ "herbalism" }, addon.db.craftingFarmingProfessionIDs)
            assert.equals("Herbalism", dropdown_texts[#dropdown_texts])

            addon:ToggleCraftingFarmingProfessionFilter("elemental")
            addon:RefreshCraftingFarmingWindowControls()
            assert.same({ "elemental" }, addon.db.craftingFarmingProfessionIDs)
            assert.equals("Elemental", dropdown_texts[#dropdown_texts])
        end)
    end)

    it("refreshes visible profession menu checkmarks from the single selection", function()
        local addon = load_window(build_addon({
            professionID = "mining",
            professionIDs = {
                mining = true,
                herbalism = true,
            },
        }))
        local dropdown = {}
        addon.craftingFarmingFrame.professionDropdown = dropdown

        local function marker()
            return {
                shown = nil,
                Show = function(self)
                    self.shown = true
                end,
                Hide = function(self)
                    self.shown = false
                end,
            }
        end

        local all_check = marker()
        local all_uncheck = marker()
        local mining_check = marker()
        local mining_uncheck = marker()
        local herb_check = marker()
        local herb_uncheck = marker()

        local all_button = { value = "all", Check = all_check, UnCheck = all_uncheck }
        local mining_button = { value = "mining", Check = mining_check, UnCheck = mining_uncheck }
        local herb_button = { value = "herbalism", Check = herb_check, UnCheck = herb_uncheck }

        loader.with_globals({
            UIDROPDOWNMENU_OPEN_MENU = dropdown,
            UIDROPDOWNMENU_MAXLEVELS = 1,
            UIDROPDOWNMENU_MAXBUTTONS = 3,
            DropDownList1 = { numButtons = 3 },
            DropDownList1Button1 = all_button,
            DropDownList1Button2 = mining_button,
            DropDownList1Button3 = herb_button,
            UIDropDownMenu_SetSelectedValue = function() end,
            UIDropDownMenu_SetText = function() end,
        }, function()
            addon:RefreshCraftingFarmingWindowControls()

            assert.is_false(all_button.checked)
            assert.is_false(all_check.shown)
            assert.is_true(all_uncheck.shown)
            assert.is_true(mining_button.checked)
            assert.is_true(mining_check.shown)
            assert.is_false(mining_uncheck.shown)
            assert.is_false(herb_button.checked)
            assert.is_false(herb_check.shown)
            assert.is_true(herb_uncheck.shown)
        end)
    end)

    it("separates composed materials and expands their priced components", function()
        local data = copy_farming_data({
            {
                itemID = 3005,
                expansion = "classic",
                professions = { "mining" },
                tag = "Bar",
                outputQuantity = 2,
                components = {
                    { itemID = 3001, quantity = 3 },
                    { itemID = 3003, quantity = 2 },
                },
            },
        })
        local addon = load_window(build_addon({
            expansionID = "classic",
            professionID = "mining",
            composedMaterialsExpanded = true,
            expandedComposedMaterials = {
                [3005] = true,
            },
        }), data)

        local rows = project_rows(addon:BuildCraftingFarmingRows())

        assert.equals("divider", rows[3].rowType)
        assert.equals(3005, rows[4].itemID)
        assert.is_true(rows[4].isComposedMaterial)
        assert.equals(3200, rows[4].componentCost)
        assert.equals(16800, rows[4].profitValue)
        assert.equals("component", rows[5].rowType)
        assert.equals(3001, rows[5].itemID)
        assert.equals(3, rows[5].componentQuantity)
        assert.equals(3000, rows[5].componentCost)
        assert.equals("component", rows[6].rowType)
        assert.equals(3003, rows[6].itemID)
        assert.equals(2, rows[6].componentQuantity)
        assert.equals(200, rows[6].componentCost)
    end)

    it("defers all composed pricing until the composed materials section is expanded", function()
        local data = copy_farming_data({
            {
                itemID = 3005,
                expansion = "classic",
                professions = { "mining" },
                tag = "Bar",
                components = {
                    { itemID = 3011, quantity = 2 },
                },
            },
        })
        local addon = build_addon({
            expansionID = "classic",
            professionID = "mining",
        })
        addon.craftingFarmingFrame.itemCache["3011|TSM_DBMARKET"] = nil
        local componentValueLookups = 0
        addon.GetTSMItemValueForItemID = function(_, _, itemID)
            if itemID == 3011 then
                componentValueLookups = componentValueLookups + 1
            end
            return item_values[itemID] or 0
        end
        addon = load_window(addon, data)

        local collapsedRows = addon:BuildCraftingFarmingRows()
        local composedDivider
        for _, row in ipairs(collapsedRows) do
            if row.dividerKind == "composedMaterials" then
                composedDivider = row
                break
            end
        end

        assert.is_table(composedDivider)
        assert.is_false(composedDivider.expanded)
        assert.is_nil(collapsedRows[#collapsedRows].itemID)
        assert.equals(0, componentValueLookups)

        addon.craftingFarmingFrame.composedMaterialsExpanded = true
        local expandedRows = addon:BuildCraftingFarmingRows()
        local expandedComposed
        for _, row in ipairs(expandedRows) do
            if row.itemID == 3005 and row.rowType ~= "component" then
                expandedComposed = row
                break
            end
        end

        assert.is_true(expandedComposed.componentsLoaded)
        assert.equals(8000, expandedComposed.componentCost)
        assert.equals(1, componentValueLookups)
    end)

    it("calculates gold per hour from drop rate and unit value", function()
        local addon = load_window(build_addon({
            expansionID = "classic",
            professionID = "mining",
            dropRateByItemID = {
                [3001] = { dropPerHour = 12.5 },
            },
        }))

        local rows = addon:BuildCraftingFarmingRows()
        local ore
        for _, row in ipairs(rows) do
            if row.itemID == 3001 then
                ore = row
                break
            end
        end

        assert.is_table(ore)
        assert.equals(12500, ore.goldPerHour)
    end)

    it("expands composed components recursively to their base recipe inputs", function()
        local data = copy_farming_data({
            {
                itemID = 3005,
                expansion = "classic",
                professions = { "mining" },
                tag = "Bar",
                outputQuantity = 2,
                recipeSpellID = 5005,
                recipeSourceLabel = "Mining trainer",
                components = {
                    { itemID = 3001, quantity = 3 },
                },
            },
            {
                itemID = 3010,
                expansion = "classic",
                professions = { "mining" },
                tag = "Alloy",
                outputQuantity = 1,
                recipeSpellID = 5010,
                recipeSourceLabel = "World-drop recipe",
                components = {
                    { itemID = 3005, quantity = 3 },
                },
            },
        })
        local addon = load_window(build_addon({
            expansionID = "classic",
            professionID = "mining",
            composedMaterialsExpanded = true,
            expandedComposedMaterials = {
                [3005] = true,
                [3010] = true,
            },
        }), data)

        local rows = addon:BuildCraftingFarmingRows()
        local alloyIndex
        for index, row in ipairs(rows) do
            if row.itemID == 3010 and row.rowType ~= "component" then
                alloyIndex = index
                break
            end
        end

        assert.is_number(alloyIndex)
        assert.equals("World-drop recipe", rows[alloyIndex].recipeSourceLabel)
        assert.equals("component", rows[alloyIndex + 1].rowType)
        assert.equals(3005, rows[alloyIndex + 1].itemID)
        assert.equals(3, rows[alloyIndex + 1].componentQuantity)
        assert.equals(1, rows[alloyIndex + 1].componentDepth)
        assert.is_true(rows[alloyIndex + 1].isComposedMaterial)
        assert.equals("Mining trainer", rows[alloyIndex + 1].recipeSourceLabel)
        assert.equals("component", rows[alloyIndex + 2].rowType)
        assert.equals(3001, rows[alloyIndex + 2].itemID)
        assert.equals(6, rows[alloyIndex + 2].componentQuantity)
        assert.equals(6000, rows[alloyIndex + 2].componentCost)
        assert.equals(2, rows[alloyIndex + 2].componentDepth)
        assert.equals(3010, rows[alloyIndex + 2].rootItemID)
    end)

    it("calculates median material drop per hour from live and saved sessions where the item appeared", function()
        local addon = build_addon()
        addon.session = {
            active = true,
            itemLoots = {
                { itemID = 3001, quantity = 4, isCraftingReagent = true },
                { itemID = 3002, quantity = 2, isCraftingReagent = true },
            },
        }
        addon.GetSessionRateDurationSeconds = function()
            return 1800
        end
        addon.history = {
            {
                duration = 3600,
                itemLoots = {
                    { itemLink = "|Hitem:3001::::::::|h[Old Ore]|h", quantity = 6, isCraftingReagent = true },
                    { itemLink = "|Hitem:9999::::::::|h[Not Mat]|h", quantity = 1, isCraftingReagent = false },
                },
            },
            {
                duration = 7200,
                itemLoots = {
                    { itemID = 3002, quantity = 8, isCraftingReagent = true },
                },
            },
        }
        addon = load_window(addon)

        local rates = addon:BuildCraftingFarmingDropRateLookup()

        assert.equals(10, rates[3001].quantity)
        assert.equals(5400, rates[3001].durationSeconds)
        assert.equals(2, rates[3001].sessionCount)
        assert.equals(7, rates[3001].dropPerHour)
        assert.equals(10, rates[3002].quantity)
        assert.equals(9000, rates[3002].durationSeconds)
        assert.equals(4, rates[3002].dropPerHour)
    end)

    it("saves refreshed material drop rates and restores them from saved variables", function()
        local addon = build_addon()
        addon.history = {
            {
                duration = 1800,
                itemLoots = {
                    { itemID = 3001, quantity = 5, isCraftingReagent = true },
                },
            },
        }
        addon = load_window(addon)

        local savedRates = addon:SaveCraftingFarmingDropRateLookup(addon:BuildCraftingFarmingDropRateLookup(), 1234)

        assert.equals(10, savedRates[3001].dropPerHour)
        assert.equals(1234, addon.db.craftingFarmingDropRates.updatedAt)
        assert.equals(10, addon.db.craftingFarmingDropRates.items["3001"].dropPerHour)
        assert.equals(10, addon.craftingFarmingFrame.dropRateByItemID[3001].dropPerHour)
        assert.is_nil(addon.db.craftingFarmingDropRates.items[3001])

        local restoredAddon = build_addon()
        restoredAddon.db.craftingFarmingDropRates = addon.db.craftingFarmingDropRates
        restoredAddon = load_window(restoredAddon)

        local restoredRates, restoredAt = restoredAddon:GetSavedCraftingFarmingDropRateLookup()

        assert.equals(1234, restoredAt)
        assert.equals(5, restoredRates[3001].quantity)
        assert.equals(1800, restoredRates[3001].durationSeconds)
        assert.equals(1, restoredRates[3001].sessionCount)
        assert.equals(10, restoredRates[3001].dropPerHour)
    end)

    it("keeps saved material drop rates when a refresh has no usable replacement", function()
        local addon = build_addon()
        addon.db.craftingFarmingDropRates = {
            updatedAt = 1000,
            items = {
                ["3001"] = {
                    itemID = 3001,
                    quantity = 8,
                    durationSeconds = 1800,
                    sessionCount = 2,
                    dropPerHour = 16,
                },
                ["3002"] = {
                    itemID = 3002,
                    quantity = 6,
                    durationSeconds = 3600,
                    sessionCount = 1,
                    dropPerHour = 6,
                },
            },
        }
        addon = load_window(addon)

        local savedRates = addon:SaveCraftingFarmingDropRateLookup({
            [3001] = {
                itemID = 3001,
                quantity = 2,
                durationSeconds = 0,
                sessionCount = 1,
                dropPerHour = 0,
            },
        }, 2000)

        assert.equals(16, savedRates[3001].dropPerHour)
        assert.equals(6, savedRates[3002].dropPerHour)
        assert.equals(16, addon.db.craftingFarmingDropRates.items["3001"].dropPerHour)
        assert.equals(6, addon.db.craftingFarmingDropRates.items["3002"].dropPerHour)
        assert.equals(2000, addon.db.craftingFarmingDropRates.updatedAt)
    end)

    it("learns missing crafting reagents from saved sessions into custom materials", function()
        local addon = build_addon()
        addon.history = {
            {
                itemLoots = {
                    {
                        itemLink = "|Hitem:3006::::::::|h[Session Herb]|h",
                        quantity = 3,
                        isCraftingReagent = true,
                        expansionID = 10,
                        lootSourceType = "Herbalism",
                    },
                    {
                        itemLink = "|Hitem:3001::::::::|h[Old Ore]|h",
                        quantity = 1,
                        isCraftingReagent = true,
                    },
                    {
                        itemLink = "|Hitem:3007::::::::|h[Not Learned Twice]|h",
                        quantity = 1,
                        isCraftingReagent = true,
                        expansionName = "Classic",
                    },
                    {
                        itemLink = "|Hitem:3007::::::::|h[Not Learned Twice]|h",
                        quantity = 1,
                        isCraftingReagent = true,
                    },
                    {
                        itemLink = "|Hitem:3008::::::::|h[Bound Reagent]|h",
                        quantity = 1,
                        isCraftingReagent = true,
                        lootSourceType = "Mining",
                    },
                },
            },
        }
        addon = load_window(addon)

        local learned = addon:LearnCraftingFarmingMaterialsFromSessions()

        assert.equals(1, learned)
        assert.equals(2, #addon.db.craftingFarmingCustomItems)
        assert.same({
            itemID = 3006,
            expansion = "warWithin",
            professions = { "herbalism" },
            tag = "Session",
            custom = true,
            learnedFromSession = true,
            importSource = "session",
        }, addon.db.craftingFarmingCustomItems[2])
    end)

    it("learns cooking subtype reagents as cooking even when the loot source was skinning", function()
        local addon = build_addon()
        addon.db.craftingFarmingProfessionID = "skinning"
        addon.history = {
            {
                itemLoots = {
                    {
                        itemLink = "|Hitem:3009::::::::|h[Session Meat]|h",
                        quantity = 1,
                        isCraftingReagent = true,
                        itemSubType = "Cooking",
                        lootSourceType = "Skinning",
                        expansionID = 1,
                    },
                },
            },
        }
        addon = load_window(addon)

        local learned = addon:LearnCraftingFarmingMaterialsFromSessions()

        assert.equals(1, learned)
        assert.same({
            itemID = 3009,
            expansion = "burningCrusade",
            professions = { "cooking" },
            tag = "Session",
            custom = true,
            learnedFromSession = true,
            importSource = "session",
        }, addon.db.craftingFarmingCustomItems[2])
    end)

    it("opens researched source-area maps with guidance and no fabricated pins", function()
        local addon = build_addon()
        addon.materialFarmingSpots = { items = { [3001] = {
            itemID = 3001, itemName = "Old Ore", spots = { {
                id = "active-digsite", mapID = 371, mapName = "The Jade Forest",
                location = "Possible active digsite", mapOnly = true, coords = {},
                farmAction = "Check the active Archaeology overlay.",
                tips = { "Sites rotate per character." }, sourceUrls = { "https://example.com/source" },
            } },
        } } }
        addon = load_window(addon)
        local opened
        addon.OpenStandaloneMapWindow = function(_, options) opened = options end
        addon.BuildStandaloneMapDetailLines = function(_, pins) return pins end
        local rows = addon:BuildCraftingFarmingRows()
        local hasMap
        for _, row in ipairs(rows) do if row.itemID == 3001 then hasMap = row.hasFarmingMap end end
        assert.is_true(hasMap)
        assert.is_true(addon:OpenMaterialFarmingMap(3001))
        local option = opened.mapOptions[1]
        assert.is_true(option.mapOnly)
        assert.equals(0, #option.pins)
        local details = opened.detailLinesBuilder(option, nil, option.mapLabel)
        assert.equals("Check the active Archaeology overlay.", details[1].farmAction)
        assert.is_nil(details[1].x)
        assert.same({ "Sites rotate per character." }, details[1].tips)
        assert.same({ "https://example.com/source" }, details[1].sourceUrls)
    end)

    it("builds coordinate-backed map options for researched material spots", function()
        local addon = build_addon()
        addon.materialFarmingSpots = {
            items = {
                [3001] = {
                    itemID = 3001,
                    itemName = "Old Ore",
                    spots = {
                        {
                            id = "nagrand-main",
                            mapName = "Nagrand",
                            location = "Twilight Ridge",
                            targetName = "Twilight Serpent",
                            targetType = "kill",
                            farmAction = "Kill: Twilight Serpent and loot Old Ore.",
                            density = "High",
                            dropDifficulty = "Easy loop",
                            tips = { "Stay on the ridge." },
                            coords = {
                                {
                                    x = 0.10,
                                    y = 0.20,
                                    label = "West ridge",
                                },
                                { x = 14, y = 24, label = "Central ridge" },
                            },
                        },
                        {
                            id = "nagrand-alt",
                            mapName = "Nagrand",
                            location = "Warmaul Hill",
                            dropdownLabel = "Catalog: Warmaul route",
                            isRoute = true,
                            coords = {
                                { x = 0.30, y = 0.40, label = "Hill camp" },
                            },
                        },
                        {
                            id = "shadowmoon-main",
                            mapName = "Shadowmoon Valley",
                            location = "Coilskar Cistern",
                            coords = {
                                { x = 0.45, y = 0.29, label = "Cistern" },
                            },
                        },
                        {
                            mapName = "Badlands / Silithus",
                            location = "Broad route without a single map",
                            coords = {
                                { x = 0.50, y = 0.50, label = "Ignored" },
                            },
                        },
                    },
                },
            },
        }
        addon = load_window(addon)

        local options = addon:BuildMaterialFarmingMapOptions(3001)

        assert.equals(3, #options)
        assert.equals("Nagrand: Twilight Ridge", options[1].label)
        assert.equals("Nagrand", options[1].mapLabel)
        assert.equals("nagrand-main", options[1].id)
        assert.equals(107, options[1].mapID)
        assert.equals(2, #options[1].pins)
        assert.equals(1, options[1].spotCount)
        assert.equals(0.14, options[1].pins[2].x)
        assert.equals("Old Ore", options[1].pins[1].itemName)
        assert.equals("Twilight Ridge", options[1].pins[1].spotLocation)
        assert.equals("Twilight Serpent", options[1].pins[1].targetName)
        assert.equals("kill", options[1].pins[1].targetType)
        assert.equals("Kill: Twilight Serpent and loot Old Ore.", options[1].pins[1].farmAction)
        assert.equals("static", options[1].sourceType)
        assert.equals("Addon seed data", options[1].pins[1].sourceLabel)
        assert.is_true(options[1].pins[1].isRoute)
        assert.equals("nagrand-main", options[1].pins[1].routeID)
        assert.equals("Catalog: Warmaul route", options[2].label)
        assert.equals(107, options[2].mapID)
        assert.equals(1, #options[2].pins)
        assert.is_true(options[2].pins[1].isRoute)
        assert.equals("nagrand-alt", options[2].pins[1].routeID)
        assert.equals("Shadowmoon Valley: Coilskar Cistern", options[3].label)
        assert.equals(104, options[3].mapID)
    end)

    it("keeps addon seed pins and user-discovered material pins as separate map options", function()
        local addon = build_addon()
        addon.materialFarmingSpots = {
            items = {
                [3001] = {
                    itemID = 3001,
                    itemName = "Old Ore",
                    spots = {
                        {
                            id = "nagrand-main",
                            mapName = "Nagrand",
                            location = "Twilight Ridge",
                            coords = {
                                { x = 0.10, y = 0.20, label = "West ridge" },
                            },
                        },
                    },
                },
            },
        }
        addon.BuildUserMaterialFarmingMapOptions = function()
            return {
                {
                    mapID = 107,
                    label = "Nagrand (User)",
                    sourceType = "user",
                    sourceLabel = "User discoveries",
                    spotCount = 1,
                    pins = {
                        {
                            mapID = 107,
                            x = 0.33,
                            y = 0.44,
                            label = "Clefthoof",
                            itemName = "Old Ore",
                            sourceType = "user",
                            sourceLabel = "User discoveries",
                        },
                    },
                },
            }
        end
        addon = load_window(addon)

        local options = addon:BuildMaterialFarmingMapOptions(3001)

        assert.equals(2, #options)
        assert.equals("Nagrand (User)", options[1].label)
        assert.equals("user", options[1].sourceType)
        assert.equals("User discoveries", options[1].sourceLabel)
        assert.equals(1, #options[1].pins)
        assert.equals("user", options[1].pins[1].sourceType)
        assert.equals("Nagrand: Twilight Ridge", options[2].label)
        assert.equals("static", options[2].sourceType)
        assert.equals("Addon seed data", options[2].sourceLabel)
        assert.equals(1, #options[2].pins)
        assert.equals("static", options[2].pins[1].sourceType)
        assert.is_nil(addon.materialFarmingSpots.items[3001].spots[1].sourceType)
    end)

    it("opens material farming maps with the material name as the toolbar title", function()
        local capturedOptions
        local addon = build_addon()
        addon.OpenStandaloneMapWindow = function(_, options)
            capturedOptions = options
        end
        addon.materialFarmingSpots = {
            items = {
                [3001] = {
                    itemID = 3001,
                    itemName = "Old Ore",
                    isRoute = true,
                    spots = {
                        {
                            id = "old-ore-nagrand-route",
                            mapName = "Nagrand",
                            coords = {
                                { x = 0.10, y = 0.20, label = "West ridge" },
                            },
                        },
                    },
                },
            },
        }
        addon = load_window(addon)

        assert.is_true(addon:OpenMaterialFarmingMap(3001))
        assert.equals("Old Ore", capturedOptions.title)
        assert.equals(3001, capturedOptions.customFarmRow.itemID)
        assert.equals("materials", capturedOptions.customFarmSourceType)
        assert.equals("Nagrand", capturedOptions.mapOptions[1].mapLabel)
        assert.equals("Nagrand", capturedOptions.mapOptions[1].label)
        assert.equals("map", capturedOptions.mapOptions[1].dropdownGroup)
        assert.equals("Map data", capturedOptions.mapOptions[1].dropdownGroupLabel)
        assert.is_true(capturedOptions.mapOptions[1].pins[1].isRoute)
        assert.equals("old-ore-nagrand-route", capturedOptions.mapOptions[1].pins[1].routeID)
    end)

    it("groups material map options and retains each farm's full-yield-window state", function()
        local capturedOptions
        local buildOptions = {}
        local openedStates = {}
        local previewedFarms = {}
        local smallerFarm = {
            id = "smaller-farm",
            name = "Smaller Farm",
            targets = { { itemID = 3001, quantity = 3 } },
        }
        local largerFarm = {
            id = "larger-farm",
            name = "Larger Farm",
            targets = { { itemID = 3001, quantity = 12 } },
        }
        local addon = build_addon()
        addon.materialFarmingSpots = {
            items = {
                [3001] = {
                    itemID = 3001,
                    itemName = "Old Ore",
                    spots = {
                        { id = "addon-map", mapName = "Nagrand", coords = { { x = 0.1, y = 0.2 } } },
                    },
                },
            },
        }
        addon.BuildUserMaterialFarmingMapOptions = function()
            return {
                { id = "user-map", mapID = 107, label = "Nagrand (User)", sourceType = "user",
                    pins = { { mapID = 107, x = 0.3, y = 0.4, sourceType = "user" } } },
            }
        end
        addon = load_window(addon)
        addon.GetFarmsForItem = function() return { smallerFarm, largerFarm } end
        addon.BuildFarmDetailsMapOptions = function()
            return {
                { id = "smaller-farm-map", mapID = 107, label = "farm: Smaller Farm", farm = smallerFarm, pins = {} },
                { id = "larger-farm-map", mapID = 107, label = "farm: Larger Farm", farm = largerFarm, pins = {} },
            }
        end
        addon.BuildFarmPreviewValuationSnapshot = function(_, farm)
            previewedFarms[#previewedFarms + 1] = farm
            return {}
        end
        addon.BuildFarmValuationSnapshot = function()
            error("the map dropdown must not build a full-farm valuation")
        end
        addon.BuildFarmMapDetailLines = function(_, _, _, _, _, options)
            buildOptions[#buildOptions + 1] = options
            return {
                { type = "detailButton", onClick = options.onOpenAllTargets },
            }
        end
        addon.OpenFarmRecordedYieldsForFarm = function(_, farm, _, _, tableState)
            openedStates[#openedStates + 1] = { farm = farm, state = tableState }
            if farm == largerFarm then
                tableState.filter = "equipment"
                tableState.sortKey = "totalValue"
                tableState.sortAscending = false
            end
        end
        addon.OpenStandaloneMapWindow = function(_, options) capturedOptions = options end

        assert.is_true(addon:OpenMaterialFarmingMap(3001))
        assert.same({ "user", "map", "farm", "farm" }, {
            capturedOptions.mapOptions[1].dropdownGroup,
            capturedOptions.mapOptions[2].dropdownGroup,
            capturedOptions.mapOptions[3].dropdownGroup,
            capturedOptions.mapOptions[4].dropdownGroup,
        })
        assert.same({ "User map data", "Map data", "Farm data", "Farm data" }, {
            capturedOptions.mapOptions[1].dropdownGroupLabel,
            capturedOptions.mapOptions[2].dropdownGroupLabel,
            capturedOptions.mapOptions[3].dropdownGroupLabel,
            capturedOptions.mapOptions[4].dropdownGroupLabel,
        })
        assert.equals("farm: Larger Farm", capturedOptions.mapOptions[3].label)
        assert.equals("farm: Smaller Farm", capturedOptions.mapOptions[4].label)

        local largerLines = capturedOptions.detailLinesBuilder(capturedOptions.mapOptions[3], 107, "Nagrand")
        largerLines[1].onClick()
        assert.equals(largerFarm, openedStates[1].farm)
        assert.equals("equipment", openedStates[1].state.filter)
        assert.equals("totalValue", openedStates[1].state.sortKey)
        assert.is_false(openedStates[1].state.sortAscending)

        capturedOptions.detailLinesBuilder(capturedOptions.mapOptions[3], 107, "Nagrand")[1].onClick()
        assert.equals(openedStates[1].state, openedStates[2].state)
        assert.equals("equipment", openedStates[2].state.filter)

        capturedOptions.detailLinesBuilder(capturedOptions.mapOptions[4], 107, "Nagrand")[1].onClick()
        assert.equals(smallerFarm, openedStates[3].farm)
        assert.equals("all", openedStates[3].state.filter)
        assert.equals("itemName", openedStates[3].state.sortKey)
        assert.is_true(openedStates[3].state.sortAscending)
        assert.equals(3, #buildOptions)
        assert.same({ largerFarm, smallerFarm }, previewedFarms)
    end)

    it("marks rows that have material farming map data", function()
        local addon = build_addon()
        addon.materialFarmingSpots = {
            items = {
                [3001] = {
                    itemID = 3001,
                    itemName = "Old Ore",
                    spots = {
                        {
                            mapName = "Hellfire Peninsula",
                            coords = {
                                { x = 0.20, y = 0.30, label = "Route point" },
                            },
                        },
                    },
                },
            },
        }
        addon = load_window(addon)

        local by_id = {}
        for _, row in ipairs(addon:BuildCraftingFarmingRows()) do
            by_id[row.itemID] = row
        end

        assert.is_true(by_id[3001].hasFarmingMap)
        assert.is_false(by_id[3002].hasFarmingMap)
    end)

    it("marks rows that only have user-discovered material pins", function()
        local addon = build_addon()
        addon.BuildUserMaterialFarmingMapOptions = function(_, itemID)
            if itemID == 3002 then
                return {
                    {
                        mapID = 1,
                        label = "User map",
                        sourceType = "user",
                        pins = {
                            { mapID = 1, x = 0.2, y = 0.3, sourceType = "user" },
                        },
                    },
                }
            end
            return {}
        end
        addon = load_window(addon)

        local by_id = {}
        for _, row in ipairs(addon:BuildCraftingFarmingRows()) do
            by_id[row.itemID] = row
        end

        assert.is_true(by_id[3002].hasFarmingMap)
    end)

    it("marks only materials indexed by the static Farms catalog", function()
        local addon = build_addon()
        addon.farmCatalog = {
            indexes = {
                byItemID = {
                    [3001] = { 1, 2 },
                },
            },
        }
        addon = load_window(addon)

        local by_id = {}
        for _, row in ipairs(addon:BuildCraftingFarmingRows()) do
            by_id[row.itemID] = row
        end

        assert.is_true(by_id[3001].hasFarm)
        assert.equals(2, by_id[3001].farmCount)
        assert.is_false(by_id[3002].hasFarm)
        assert.equals(0, by_id[3002].farmCount)
    end)
end)
