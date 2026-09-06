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
}

local item_values = {
    [3001] = 1000,
    [3002] = 5000,
    [3003] = 100,
    [3004] = 7000,
    [3005] = 10000,
    [3009] = 2500,
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

local function load_window(addon, farming_data)
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

describe("UI/CraftingFarmingWindow rows", function()
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

    it("calculates material drop per hour from live and saved sessions where the item appeared", function()
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
        assert.is_true(math.abs(rates[3001].dropPerHour - 6.6667) < 0.001)
        assert.equals(10, rates[3002].quantity)
        assert.equals(9000, rates[3002].durationSeconds)
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

    it("builds coordinate-backed map options for researched material spots", function()
        local addon = build_addon()
        addon.materialFarmingSpots = {
            items = {
                [3001] = {
                    itemID = 3001,
                    itemName = "Old Ore",
                    spots = {
                        {
                            mapName = "Nagrand",
                            location = "Twilight Ridge",
                            density = "High",
                            dropDifficulty = "Easy loop",
                            tips = { "Stay on the ridge." },
                            coords = {
                                { x = 0.10, y = 0.20, label = "West ridge" },
                                { x = 14, y = 24, label = "Central ridge" },
                            },
                        },
                        {
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

        assert.equals(2, #options)
        assert.equals("Nagrand", options[1].label)
        assert.equals(107, options[1].mapID)
        assert.equals(2, #options[1].pins)
        assert.equals(0.14, options[1].pins[2].x)
        assert.equals("Old Ore", options[1].pins[1].itemName)
        assert.equals("Twilight Ridge", options[1].pins[1].spotLocation)
        assert.equals("Shadowmoon Valley", options[2].label)
        assert.equals(104, options[2].mapID)
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
                    spots = {
                        {
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
        assert.equals("Nagrand", capturedOptions.mapOptions[1].label)
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
end)
