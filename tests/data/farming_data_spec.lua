local loader = require("tests.helpers.addon_loader")

local function load_data(relative_path, export_name)
    local _, ns = loader.load_module(relative_path, {})
    return ns[export_name]
end

local function load_modules(relative_paths)
    local ns = {
        GoldTracker = {},
    }

    for _, relative_path in ipairs(relative_paths) do
        local chunk, err = loadfile(relative_path)
        assert(chunk, err)
        chunk("General-Gold-Tracker", ns)
    end

    return ns.GoldTracker, ns
end

local function assert_non_empty_string(value)
    assert.equals("string", type(value))
    assert.is_true(value ~= "")
end

local function count_keys(tbl)
    local count = 0
    for _ in pairs(tbl or {}) do
        count = count + 1
    end
    return count
end

local function item_has_coord(item, x, y)
    for _, spot in ipairs((item or {}).spots or {}) do
        for _, coord in ipairs(spot.coords or {}) do
            if coord.x == x and coord.y == y then
                return true
            end
        end
    end

    return false
end

local MATERIAL_FARMING_SPOT_MODULES = {
    "Data/MaterialFarmingSpots.lua",
    "Data/MaterialFarmingSpots/Shared.lua",
    "Data/MaterialFarmingSpots/Classic/Alchemy.lua",
    "Data/MaterialFarmingSpots/Classic/Enchanting.lua",
    "Data/MaterialFarmingSpots/Classic/Herbalism.lua",
    "Data/MaterialFarmingSpots/Classic/Jewelcrafting.lua",
    "Data/MaterialFarmingSpots/Classic/Mining.lua",
    "Data/MaterialFarmingSpots/Classic/Skinning.lua",
    "Data/MaterialFarmingSpots/Classic/Tailoring.lua",
    "Data/MaterialFarmingSpots/BurningCrusade/Alchemy.lua",
    "Data/MaterialFarmingSpots/BurningCrusade/Cooking.lua",
    "Data/MaterialFarmingSpots/BurningCrusade/Enchanting.lua",
    "Data/MaterialFarmingSpots/BurningCrusade/Fishing.lua",
    "Data/MaterialFarmingSpots/BurningCrusade/Herbalism.lua",
    "Data/MaterialFarmingSpots/BurningCrusade/Jewelcrafting.lua",
    "Data/MaterialFarmingSpots/BurningCrusade/Mining.lua",
    "Data/MaterialFarmingSpots/BurningCrusade/Skinning.lua",
    "Data/MaterialFarmingSpots/BurningCrusade/Tailoring.lua",
    "Data/MaterialFarmingSpots/Wrath/Enchanting.lua",
    "Data/MaterialFarmingSpots/Wrath/Engineering.lua",
    "Data/MaterialFarmingSpots/Wrath/Cooking.lua",
    "Data/MaterialFarmingSpots/Wrath/Fishing.lua",
    "Data/MaterialFarmingSpots/Wrath/Herbalism.lua",
    "Data/MaterialFarmingSpots/Wrath/Jewelcrafting.lua",
    "Data/MaterialFarmingSpots/Wrath/Mining.lua",
    "Data/MaterialFarmingSpots/Wrath/Skinning.lua",
    "Data/MaterialFarmingSpots/Wrath/Tailoring.lua",
    "Data/MaterialFarmingSpots/Cataclysm/Alchemy.lua",
    "Data/MaterialFarmingSpots/Cataclysm/Cooking.lua",
    "Data/MaterialFarmingSpots/Cataclysm/Enchanting.lua",
    "Data/MaterialFarmingSpots/Cataclysm/Fishing.lua",
    "Data/MaterialFarmingSpots/Cataclysm/Herbalism.lua",
    "Data/MaterialFarmingSpots/Cataclysm/Jewelcrafting.lua",
    "Data/MaterialFarmingSpots/Cataclysm/Mining.lua",
    "Data/MaterialFarmingSpots/Cataclysm/Skinning.lua",
    "Data/MaterialFarmingSpots/Cataclysm/Tailoring.lua",
    "Data/MaterialFarmingSpots/Mists/Alchemy.lua",
    "Data/MaterialFarmingSpots/Mists/Cooking.lua",
    "Data/MaterialFarmingSpots/Mists/Enchanting.lua",
    "Data/MaterialFarmingSpots/Mists/Fishing.lua",
    "Data/MaterialFarmingSpots/Mists/Herbalism.lua",
    "Data/MaterialFarmingSpots/Mists/Jewelcrafting.lua",
    "Data/MaterialFarmingSpots/Mists/Mining.lua",
    "Data/MaterialFarmingSpots/Mists/Skinning.lua",
    "Data/MaterialFarmingSpots/Mists/Tailoring.lua",
    "Data/MaterialFarmingSpots/Warlords/Alchemy.lua",
    "Data/MaterialFarmingSpots/Warlords/Cooking.lua",
    "Data/MaterialFarmingSpots/Warlords/Enchanting.lua",
    "Data/MaterialFarmingSpots/Warlords/Fishing.lua",
    "Data/MaterialFarmingSpots/Warlords/Herbalism.lua",
    "Data/MaterialFarmingSpots/Warlords/Mining.lua",
    "Data/MaterialFarmingSpots/Warlords/Skinning.lua",
    "Data/MaterialFarmingSpots/Warlords/Tailoring.lua",
    "Data/MaterialFarmingSpots/Legion/Cooking.lua",
    "Data/MaterialFarmingSpots/Legion/Enchanting.lua",
    "Data/MaterialFarmingSpots/Legion/Fishing.lua",
    "Data/MaterialFarmingSpots/Legion/Herbalism.lua",
    "Data/MaterialFarmingSpots/Legion/Jewelcrafting.lua",
    "Data/MaterialFarmingSpots/Legion/Mining.lua",
    "Data/MaterialFarmingSpots/Legion/Reagents.lua",
    "Data/MaterialFarmingSpots/Legion/Skinning.lua",
    "Data/MaterialFarmingSpots/Legion/Tailoring.lua",
    "Data/MaterialFarmingSpots/BattleForAzeroth/Herbalism.lua",
    "Data/MaterialFarmingSpots/BattleForAzeroth/Mining.lua",
    "Data/MaterialFarmingSpots/BattleForAzeroth/Jewelcrafting.lua",
    "Data/MaterialFarmingSpots/BattleForAzeroth/Reagents.lua",
    "Data/MaterialFarmingSpots/BattleForAzeroth/Skinning.lua",
    "Data/MaterialFarmingSpots/BattleForAzeroth/Cooking.lua",
    "Data/MaterialFarmingSpots/BattleForAzeroth/Enchanting.lua",
    "Data/MaterialFarmingSpots/BattleForAzeroth/Fishing.lua",
    "Data/MaterialFarmingSpots/BattleForAzeroth/Tailoring.lua",
    "Data/MaterialFarmingSpots/Shadowlands/Herbalism.lua",
    "Data/MaterialFarmingSpots/Shadowlands/Mining.lua",
    "Data/MaterialFarmingSpots/Shadowlands/Jewelcrafting.lua",
    "Data/MaterialFarmingSpots/Shadowlands/Reagents.lua",
    "Data/MaterialFarmingSpots/Shadowlands/Skinning.lua",
    "Data/MaterialFarmingSpots/Shadowlands/Cooking.lua",
    "Data/MaterialFarmingSpots/Shadowlands/Enchanting.lua",
    "Data/MaterialFarmingSpots/Shadowlands/Fishing.lua",
    "Data/MaterialFarmingSpots/Shadowlands/Tailoring.lua",
    "Data/MaterialFarmingSpots/Dragonflight/Herbalism.lua",
    "Data/MaterialFarmingSpots/Dragonflight/Mining.lua",
    "Data/MaterialFarmingSpots/Dragonflight/Jewelcrafting.lua",
    "Data/MaterialFarmingSpots/Dragonflight/Skinning.lua",
    "Data/MaterialFarmingSpots/Dragonflight/Cooking.lua",
    "Data/MaterialFarmingSpots/Dragonflight/Enchanting.lua",
    "Data/MaterialFarmingSpots/Dragonflight/Fishing.lua",
    "Data/MaterialFarmingSpots/Dragonflight/Tailoring.lua",
    "Data/MaterialFarmingSpots/Dragonflight/Elemental.lua",
    "Data/MaterialFarmingSpots/WarWithin/Herbalism.lua",
    "Data/MaterialFarmingSpots/WarWithin/Mining.lua",
    "Data/MaterialFarmingSpots/WarWithin/Jewelcrafting.lua",
    "Data/MaterialFarmingSpots/WarWithin/Skinning.lua",
    "Data/MaterialFarmingSpots/WarWithin/Tailoring.lua",
    "Data/MaterialFarmingSpots/WarWithin/Enchanting.lua",
    "Data/MaterialFarmingSpots/WarWithin/Fishing.lua",
    "Data/MaterialFarmingSpots/WarWithin/Reagents.lua",
    "Data/MaterialFarmingSpots/Midnight/Mining.lua",
    "Data/MaterialFarmingSpots/Midnight/Herbalism.lua",
    "Data/MaterialFarmingSpots/Midnight/Skinning.lua",
    "Data/MaterialFarmingSpots/Midnight/Tailoring.lua",
    "Data/MaterialFarmingSpots/Midnight/Enchanting.lua",
    "Data/MaterialFarmingSpots/Midnight/Fishing.lua",
    "Data/MaterialFarmingSpots/Midnight/Cooking.lua",
    "Data/MaterialFarmingSpots/Midnight/Jewelcrafting.lua",
    "Data/MaterialFarmingSpots/Midnight/Engineering.lua",
    "Data/MaterialFarmingSpots/Finalize.lua",
}

local function load_material_farming_spots(include_material_catalog)
    local paths = {}

    if include_material_catalog then
        paths[#paths + 1] = "Data/FarmingItems.lua"
    end

    for _, path in ipairs(MATERIAL_FARMING_SPOT_MODULES) do
        paths[#paths + 1] = path
    end

    local _, ns = load_modules(paths)
    return ns.MaterialFarmingSpots, ns
end

describe("Data/FarmingItems", function()
    it("defines usable expansion and profession filter options", function()
        local data = load_data("Data/FarmingItems.lua", "FarmingItems")

        assert.is_table(data.expansions)
        assert.is_table(data.professions)
        assert.equals("all", data.expansions[1].id)
        assert.equals("all", data.professions[1].id)
        assert.equals("mining", data.professions[2].id)
        assert.equals("herbalism", data.professions[3].id)
        assert.equals("skinning", data.professions[4].id)
        assert.equals("fishing", data.professions[5].id)
        assert.equals("midnight", data.expansions[#data.expansions].id)

        local seen_expansions = {}
        for _, option in ipairs(data.expansions) do
            assert_non_empty_string(option.id)
            assert_non_empty_string(option.label)
            assert.is_nil(seen_expansions[option.id])
            seen_expansions[option.id] = true
        end

        local seen_professions = {}
        for _, option in ipairs(data.professions) do
            assert_non_empty_string(option.id)
            assert_non_empty_string(option.label)
            assert.is_nil(seen_professions[option.id])
            seen_professions[option.id] = true
        end
    end)

    it("keeps material item entries filterable and uniquely addressable", function()
        local data = load_data("Data/FarmingItems.lua", "FarmingItems")
        local expansion_lookup = {}
        for _, option in ipairs(data.expansions) do
            expansion_lookup[option.id] = true
        end
        local profession_lookup = {}
        for _, option in ipairs(data.professions) do
            profession_lookup[option.id] = true
        end

        local seen_item_ids = {}
        local component_item_ids = {}
        for _, item in ipairs(data.items or {}) do
            assert.is_number(item.itemID)
            assert.is_true(item.itemID > 0)
            assert_non_empty_string(item.expansion)
            assert.is_true(expansion_lookup[item.expansion] == true)
            assert.is_table(item.professions)
            assert.is_true(#item.professions > 0)
            for _, profession_id in ipairs(item.professions) do
                local message = "unknown material profession: " .. tostring(profession_id)
                assert.is_true(profession_lookup[profession_id] == true, message)
            end
            assert_non_empty_string(item.tag)
            assert.is_nil(seen_item_ids[item.itemID])
            seen_item_ids[item.itemID] = true
            for _, component in ipairs(item.components or {}) do
                assert.is_number(component.itemID)
                assert.is_true(component.itemID > 0)
                assert.is_number(component.quantity)
                assert.is_true(component.quantity > 0)
                component_item_ids[component.itemID] = true
            end
            if item.outputQuantity then
                assert.is_number(item.outputQuantity)
                assert.is_true(item.outputQuantity > 0)
            end
        end

        for item_id in pairs(component_item_ids) do
            local message = "component item missing from materials list: " .. tostring(item_id)
            assert.is_true(seen_item_ids[item_id] == true, message)
        end
    end)

    it("includes expanded farming-guide base material coverage", function()
        local data = load_data("Data/FarmingItems.lua", "FarmingItems")
        local items_by_id = {}

        for _, item in ipairs(data.items or {}) do
            items_by_id[item.itemID] = item
        end

        assert.equals("Volatile", items_by_id[52325].tag)
        assert.equals("Elemental", items_by_id[37702].tag)
        assert.equals("Enchanting", items_by_id[152875].tag)
        assert.equals("Fish", items_by_id[173032].tag)
        assert.equals("Meat", items_by_id[197741].tag)
        assert.equals("Elemental", items_by_id[190326].tag)
        assert.equals("Ore", items_by_id[237359].tag)
        assert.equals("Herb", items_by_id[236780].tag)
        assert.equals("Leather", items_by_id[238511].tag)
        assert.equals("Cloth", items_by_id[236963].tag)
        assert.equals("Enchanting", items_by_id[243599].tag)
        assert.equals("Fish", items_by_id[238371].tag)
        assert.equals("Meat", items_by_id[242639].tag)
        assert.equals("Gem", items_by_id[242553].tag)
        assert.equals("Stone", items_by_id[242789].tag)
        assert.is_nil(items_by_id[253403])
        assert.is_nil(items_by_id[242621])
    end)

    it("keeps corrected material categories aligned with their gathering sources", function()
        local data = load_data("Data/FarmingItems.lua", "FarmingItems")
        local items_by_id = {}

        for _, item in ipairs(data.items or {}) do
            items_by_id[item.itemID] = item
        end

        assert.equals("Leather", items_by_id[152541].tag)
        assert.same({ "skinning", "leatherworking" }, items_by_id[152541].professions)
        assert.equals("Cloth", items_by_id[152576].tag)
        assert.same({ "tailoring" }, items_by_id[152576].professions)
        assert.equals("Leather", items_by_id[172089].tag)
        assert.same({ "skinning", "leatherworking" }, items_by_id[172089].professions)
        assert.equals("Stone", items_by_id[171840].tag)
        assert.same({ "mining" }, items_by_id[171840].professions)
        assert.equals("Stone", items_by_id[171841].tag)
        assert.same({ "mining" }, items_by_id[171841].professions)
        assert.equals("Elemental", items_by_id[190315].tag)
        assert.equals("Elemental", items_by_id[190320].tag)
        assert.equals("Ore", items_by_id[190395].tag)
        assert.same({ "mining", "jewelcrafting" }, items_by_id[190395].professions)
        assert.equals("Leather", items_by_id[193208].tag)
        assert.same({ "skinning", "leatherworking" }, items_by_id[193208].professions)
        assert.equals("Enchanting", items_by_id[194123].tag)
        assert.same({ "enchanting" }, items_by_id[194123].professions)
        assert.equals("Meat", items_by_id[201399].tag)
        assert.same({ "cooking" }, items_by_id[201399].professions)
        assert.equals("Herb", items_by_id[191470].tag)
        assert.equals("Gem", items_by_id[192852].tag)
    end)
end)

describe("Data/MaterialFarmingSpots", function()
    local function build_material_lookup()
        local farming_data = load_data("Data/FarmingItems.lua", "FarmingItems")
        local lookup = {}

        for _, item in ipairs(farming_data.items or {}) do
            lookup[item.itemID] = item
        end

        return lookup
    end

    it("keeps farming spot research keyed by item ID and sourceable", function()
        local data = load_material_farming_spots()

        assert.is_number(data.dataVersion)
        assert.is_number(data.schemaVersion)
        assert_non_empty_string(data.researchedAt)
        assert_non_empty_string(data.sourceNote)
        assert.is_table(data.sources)
        assert.is_table(data.items)
        assert.is_true(count_keys(data.items) > 0)

        for item_id, item in pairs(data.items) do
            assert.is_number(item_id)
            assert.equals(item_id, item.itemID)
            assert_non_empty_string(item.itemName)
            assert_non_empty_string(item.expansion)
            assert.is_table(item.professions)
            assert.is_true(#item.professions > 0)
            assert_non_empty_string(item.category)
            assert.is_table(item.sourceUrls)
            assert.is_true(#item.sourceUrls > 0)
            assert_non_empty_string(item.summary)
            assert.is_table(item.spots)
            assert.is_true(#item.spots > 0)
        end
    end)

    it("keeps every curated spot usable by the future map UI", function()
        local data = load_material_farming_spots()

        for _, item in pairs(data.items) do
            local seen_spot_ids = {}
            for _, spot in ipairs(item.spots or {}) do
                assert_non_empty_string(spot.id)
                assert.is_nil(seen_spot_ids[spot.id])
                seen_spot_ids[spot.id] = true
                assert_non_empty_string(spot.source)
                assert.is_table(spot.sourceUrls)
                assert.is_true(#spot.sourceUrls > 0)
                assert_non_empty_string(spot.mapName)
                assert_non_empty_string(spot.location)
                assert_non_empty_string(spot.routeType)
                assert_non_empty_string(spot.density)
                assert_non_empty_string(spot.dropDifficulty)
                assert_non_empty_string(spot.confidence)
                assert.is_table(spot.tips)
                assert.is_true(#spot.tips > 0)
                assert.is_table(spot.coords)

                for _, coord in ipairs(spot.coords) do
                    assert.is_number(coord.x)
                    assert.is_number(coord.y)
                    assert.is_true(coord.x >= 0 and coord.x <= 1)
                    assert.is_true(coord.y >= 0 and coord.y <= 1)
                    assert_non_empty_string(coord.label)
                    if coord.mapID then
                        assert.is_number(coord.mapID)
                        assert.is_true(coord.mapID > 0)
                    end
                end
            end
        end
    end)

    it("marks researched materials that still need a base Materials-list entry", function()
        local data = load_material_farming_spots()
        local material_lookup = build_material_lookup()

        for item_id, item in pairs(data.items) do
            local message = "material spot item is not in FarmingItems and is not marked pending: " .. tostring(item_id)
            assert.is_true(material_lookup[item_id] ~= nil or item.needsFarmingItemsEntry == true, message)
        end

        assert.is_table(material_lookup[210799])
        assert.is_table(material_lookup[210802])
        assert.is_nil(data.items[210799].needsFarmingItemsEntry)
        assert.is_nil(data.items[210802].needsFarmingItemsEntry)
    end)

    it("tracks missing farming research without generating fallback details", function()
        local spots, ns = load_material_farming_spots(true)
        local materials = ns.FarmingItems

        assert.is_table(materials.items)
        assert.is_table(spots.items)
        assert.is_table(spots.missingItems)

        for _, item in ipairs(materials.items) do
            local details = spots.items[item.itemID]
            local missing = spots.missingItems[item.itemID]
            local message = "material should be researched or marked missing: " .. tostring(item.itemID)
            assert.is_true(details ~= nil or missing ~= nil, message)
            if details then
                assert.equals("researched", details.researchStatus)
                assert.is_false(details.fallback == true)
            else
                assert.equals("missing", missing.researchStatus)
                assert.equals(item.itemID, missing.itemID)
                assert.equals(item.expansion, missing.expansion)
                assert.same(item.professions, missing.professions)
                assert.equals(item.tag, missing.category)
            end
        end

        assert.is_table(spots.items[237359])
        assert.is_false(spots.items[237359].fallback == true)
        assert.equals("researched", spots.items[237359].researchStatus)
        assert.is_table(spots.items[25700])
        assert.equals("Fel Scales", spots.items[25700].itemName)
        assert.equals("researched", spots.items[25700].researchStatus)
        assert.is_table(spots.items[29539])
        assert.equals("Cobra Scales", spots.items[29539].itemName)
        assert.equals("researched", spots.items[29539].researchStatus)
        assert.is_table(spots.items[2770])
        assert.equals("Copper Ore", spots.items[2770].itemName)
        assert.equals("researched", spots.items[2770].researchStatus)
        assert.is_nil(spots.items[2840])
        assert.is_table(spots.missingItems[2840])
        assert.equals("missing", spots.missingItems[2840].researchStatus)
        assert.equals("curated-only", spots.coverage.mode)
        assert.is_true(spots.coverage.researched > 0)
        assert.is_true(spots.coverage.missing > 0)
    end)

    it("keeps Midnight researched farming data coordinate-backed and retail-safe", function()
        local spots = load_material_farming_spots(true)
        local blocked_patterns = {
            "wowhead%.com/tbc",
            "wowhead%.com/wotlk",
            "wowhead%.com/cata",
            "wowhead%.com/mop%-classic",
            "wowhead%.com/classic",
            "classic%.wowhead",
            "/tbc/",
            "/wotlk/",
            "/cata/",
            "/mop%-classic/",
        }

        local function assert_retail_url(url, context)
            assert_non_empty_string(url)
            local lower_url = url:lower()
            for _, pattern in ipairs(blocked_patterns) do
                assert.is_nil(lower_url:find(pattern), context .. " used Classic source URL: " .. url)
            end
        end

        for item_id, item in pairs(spots.items) do
            if item.expansion == "midnight" then
                local item_context = "Midnight item " .. tostring(item_id)
                for _, url in ipairs(item.sourceUrls or {}) do
                    assert_retail_url(url, item_context)
                end
                for _, spot in ipairs(item.spots or {}) do
                    local spot_context = item_context .. " spot " .. tostring(spot.id)
                    assert.is_true(#(spot.coords or {}) > 0, spot_context .. " has no coords")
                    for _, url in ipairs(spot.sourceUrls or {}) do
                        assert_retail_url(url, spot_context)
                    end
                end
            end
        end

        assert.is_nil(spots.items[243578])
        assert.is_table(spots.missingItems[243578])
        assert.equals("missing", spots.missingItems[243578].researchStatus)
    end)

    it("includes second-pass Midnight route, fishing, cooking, and prospecting coordinates", function()
        local spots = load_material_farming_spots(true)
        local researched_midnight_ids = {
            237359, 237361, 237362, 237363, 237364, 237365, 237366,
            236761, 236767, 236770, 236771, 236774, 236775, 236776, 236777,
            236778, 236779, 236780, 236949, 236950, 236951, 236952,
            238511, 238512, 238513, 238514, 238518, 238520, 238521, 238522,
            238523, 238525, 238528, 238529, 238530,
            236963, 236965, 237015, 237016, 237017, 237018,
            243599, 243600, 243602, 243603, 243605, 243606,
            238371, 238366, 238367, 238365, 238377, 238369, 238370, 238375,
            238382, 238372, 238378, 238384, 238374, 238383, 238381, 238376,
            238380, 238373, 238368, 238379,
            242639, 242640, 251285,
            242553, 242607, 242554, 242721, 242612, 242724, 242726, 242725,
            242712, 242789, 242787,
        }

        for _, item_id in ipairs(researched_midnight_ids) do
            local message = "missing researched Midnight farming entry: " .. tostring(item_id)
            assert.is_table(spots.items[item_id], message)
            assert.equals("researched", spots.items[item_id].researchStatus, message)
            assert.is_nil(spots.missingItems[item_id], message)
        end

        assert.is_true(item_has_coord(spots.items[237359], 0.4055, 0.2693))
        assert.is_true(item_has_coord(spots.items[237359], 0.259, 0.378))
        assert.is_true(item_has_coord(spots.items[236761], 0.4055, 0.2693))
        assert.is_true(item_has_coord(spots.items[236778], 0.500, 0.635))
        assert.is_true(item_has_coord(spots.items[236950], 0.483, 0.427))
        assert.is_true(item_has_coord(spots.items[236951], 0.259, 0.378))
        assert.is_true(item_has_coord(spots.items[236952], 0.227, 0.563))
        assert.is_true(item_has_coord(spots.items[238513], 0.4628, 0.7291))
        assert.is_true(item_has_coord(spots.items[238525], 0.5475, 0.7954))
        assert.is_true(item_has_coord(spots.items[238528], 0.426, 0.796))
        assert.is_true(item_has_coord(spots.items[236963], 0.3738, 0.4774))
        assert.is_true(item_has_coord(spots.items[243599], 0.3738, 0.4774))
        assert.is_true(item_has_coord(spots.items[238371], 0.4201, 0.6926))
        assert.is_true(item_has_coord(spots.items[238380], 0.510, 0.686))
        assert.is_true(item_has_coord(spots.items[242639], 0.560, 0.460))
        assert.is_true(item_has_coord(spots.items[251285], 0.3738, 0.4774))
        assert.is_true(item_has_coord(spots.items[242553], 0.4055, 0.2693))
        assert.is_true(item_has_coord(spots.items[242725], 0.227, 0.563))
    end)

    it("keeps researched Midnight material maps visible from the UI map button", function()
        local spots, ns = load_material_farming_spots(true)
        local chunk, err = loadfile("UI/CraftingFarmingWindow.lua")
        assert(chunk, err)
        chunk("General-Gold-Tracker", ns)

        for item_id, item in pairs(spots.items) do
            if item.expansion == "midnight" then
                local map_options = ns.GoldTracker:BuildMaterialFarmingMapOptions(item_id)
                assert.is_true(#map_options > 0, "Midnight item has no UI map options: " .. tostring(item_id))
            end
        end
    end)

    it("includes researched Classic farming data while leaving composed-only Classic materials pending", function()
        local spots = load_material_farming_spots(true)
        local researched_classic_ids = {
            765, 774, 783, 785, 818, 1206, 1210, 1529, 1705, 2318,
            2319, 2447, 2450, 2452, 2453, 2589, 2592, 2770, 2771, 2772,
            2775, 2776, 2835, 2836, 2838, 2934, 3355, 3356, 3357, 3358,
            3369, 3818, 3820, 3821, 3858, 3864, 4232, 4234, 4235, 4304,
            4306, 4338, 4625, 7067, 7068, 7069, 7070, 7076, 7078, 7080,
            7082, 7909, 7910, 7911, 7912, 8169, 8170, 8171, 8831, 8836,
            8838, 8839, 8845, 8846, 10620, 11370, 12361, 12363, 12364, 12365,
            12799, 12800, 12803, 12808, 13463, 13464, 13465, 13466, 13467,
            13468, 14047, 14256, 16202, 16203,
        }
        local composed_or_vendor_classic_ids = {
            2840, 2841, 2842, 2996, 2997, 3575, 3576, 3577, 3857, 3859,
            3860, 4305, 4339, 6037, 11371, 12359, 14048,
        }

        for _, item_id in ipairs(researched_classic_ids) do
            local message = "missing researched Classic farming entry: " .. tostring(item_id)
            assert.is_table(spots.items[item_id], message)
            assert.equals("researched", spots.items[item_id].researchStatus, message)
            assert.is_nil(spots.missingItems[item_id], message)
        end

        for _, item_id in ipairs(composed_or_vendor_classic_ids) do
            local message = "composed/vendor-only Classic item should stay pending: " .. tostring(item_id)
            assert.is_nil(spots.items[item_id], message)
            assert.is_table(spots.missingItems[item_id], message)
            assert.equals("missing", spots.missingItems[item_id].researchStatus, message)
        end
    end)

    it("keeps every researched Classic spot anchored by coordinates", function()
        local spots = load_material_farming_spots(true)

        for item_id, item in pairs(spots.items) do
            if item.expansion == "classic" then
                for _, spot in ipairs(item.spots or {}) do
                    local message = "Classic spot needs coords: "
                        .. tostring(item_id)
                        .. " / "
                        .. tostring(spot.id)
                    assert.is_table(spot.coords, message)
                    assert.is_true(#spot.coords > 0, message)
                    for _, coord in ipairs(spot.coords) do
                        assert.is_number(coord.x, message)
                        assert.is_number(coord.y, message)
                        assert.is_true(coord.x >= 0 and coord.x <= 1, message)
                        assert.is_true(coord.y >= 0 and coord.y <= 1, message)
                        assert_non_empty_string(coord.label, message)
                    end
                end
            end
        end
    end)

    it("keeps Classic Wowhead farming sources on retail pages", function()
        local spots = load_material_farming_spots(true)

        local function assert_retail_wowhead_url(url, context)
            assert_non_empty_string(url)
            local lower_url = url:lower()
            if lower_url:find("wowhead%.com") then
                local message = context .. " used Classic Wowhead source URL: " .. url
                assert.is_nil(lower_url:find("wowhead%.com/classic"), message)
                assert.is_nil(lower_url:find("classic%.wowhead"), message)
            end
        end

        for item_id, item in pairs(spots.items) do
            if item.expansion == "classic" then
                local item_context = "Classic item " .. tostring(item_id)
                for _, url in ipairs(item.sourceUrls or {}) do
                    assert_retail_wowhead_url(url, item_context)
                end
                for _, spot in ipairs(item.spots or {}) do
                    local spot_context = item_context .. " spot " .. tostring(spot.id)
                    for _, url in ipairs(spot.sourceUrls or {}) do
                        assert_retail_wowhead_url(url, spot_context)
                    end
                end
            end
        end
    end)

    it("includes second-pass Classic material additions and retail-correct herb routes", function()
        local spots = load_material_farming_spots(true)

        assert.equals("Sorrowmoss", spots.items[13466].itemName)
        assert.is_true(item_has_coord(spots.items[13466], 0.596, 0.522))
        assert.is_true(item_has_coord(spots.items[3821], 0.301, 0.663))
        assert.is_true(item_has_coord(spots.items[4625], 0.542, 0.446))
        assert.is_true(item_has_coord(spots.items[13468], 0.630, 0.536))
        assert.is_true(item_has_coord(spots.items[4232], 0.680, 0.472))
    end)

    it("includes sampled Classic route coordinates from Artisans of Azeroth import strings", function()
        local spots = load_material_farming_spots(true)

        assert.is_true(item_has_coord(spots.items[2770], 0.5449, 0.1109))
        assert.is_true(item_has_coord(spots.items[2771], 0.7357, 0.5904))
        assert.is_true(item_has_coord(spots.items[3858], 0.1136, 0.3685))
        assert.is_true(item_has_coord(spots.items[10620], 0.3121, 0.6533))
    end)

    it("includes researched Wrath farming data while leaving composed-only Wrath materials pending", function()
        local spots = load_material_farming_spots(true)
        local researched_wrath_ids = {
            33470, 33568, 34052, 34054, 34055, 34736, 36782, 36901, 36903, 36904,
            36905, 36906, 36907, 36908, 36909, 36910, 36912, 36917, 36918, 36920,
            36921, 36923, 36924, 36926, 36927, 36929, 36930, 36932, 36933, 37700,
            37701, 37702, 37703, 37704, 37705, 37921, 38557, 38558, 38561, 41800,
            41801, 41802, 41803, 41805, 41806, 41807, 41808, 41809, 41810, 41812,
            41813, 43009, 43010, 43011, 43012, 43013, 43501, 44128,
        }
        local composed_wrath_ids = {
            35625, 35627, 41510,
        }

        for _, item_id in ipairs(researched_wrath_ids) do
            local message = "missing researched Wrath farming entry: " .. tostring(item_id)
            assert.is_table(spots.items[item_id], message)
            assert.equals("researched", spots.items[item_id].researchStatus, message)
            assert.is_nil(spots.missingItems[item_id], message)
        end

        for _, item_id in ipairs(composed_wrath_ids) do
            local message = "composed-only Wrath item should stay pending: " .. tostring(item_id)
            assert.is_nil(spots.items[item_id], message)
            assert.is_table(spots.missingItems[item_id], message)
            assert.equals("missing", spots.missingItems[item_id].researchStatus, message)
        end
    end)

    it("keeps every researched Wrath spot anchored by coordinates", function()
        local spots = load_material_farming_spots(true)

        for item_id, item in pairs(spots.items) do
            if item.expansion == "wrath" then
                for _, spot in ipairs(item.spots or {}) do
                    local message = "Wrath spot needs coords: "
                        .. tostring(item_id)
                        .. " / "
                        .. tostring(spot.id)
                    assert.is_table(spot.coords, message)
                    assert.is_true(#spot.coords > 0, message)
                    for _, coord in ipairs(spot.coords) do
                        assert.is_number(coord.x, message)
                        assert.is_number(coord.y, message)
                        assert.is_true(coord.x >= 0 and coord.x <= 1, message)
                        assert.is_true(coord.y >= 0 and coord.y <= 1, message)
                        assert_non_empty_string(coord.label, message)
                    end
                end
            end
        end
    end)

    it("keeps Wrath farming sources on retail-safe pages", function()
        local spots = load_material_farming_spots(true)
        local blocked_patterns = {
            "wowhead%.com/wotlk",
            "wow%-professions%.com/wotlk",
            "wotlk%-classic",
            "/wotlk/",
        }

        local function assert_retail_url(url, context)
            assert_non_empty_string(url)
            local lower_url = url:lower()
            for _, pattern in ipairs(blocked_patterns) do
                assert.is_nil(lower_url:find(pattern), context .. " used WotLK Classic source URL: " .. url)
            end
        end

        for item_id, item in pairs(spots.items) do
            if item.expansion == "wrath" then
                local item_context = "Wrath item " .. tostring(item_id)
                for _, url in ipairs(item.sourceUrls or {}) do
                    assert_retail_url(url, item_context)
                end
                for _, spot in ipairs(item.spots or {}) do
                    local spot_context = item_context .. " spot " .. tostring(spot.id)
                    for _, url in ipairs(spot.sourceUrls or {}) do
                        assert_retail_url(url, spot_context)
                    end
                end
            end
        end
    end)

    it("includes second-pass Wrath material additions and exact sourced coordinates", function()
        local spots = load_material_farming_spots(true)

        assert.is_true(item_has_coord(spots.items[37921], 0.1236, 0.3201))
        assert.is_true(item_has_coord(spots.items[43010], 0.470, 0.550))
        assert.is_true(item_has_coord(spots.items[43012], 0.430, 0.740))
        assert.is_true(item_has_coord(spots.items[43501], 0.590, 0.280))
        assert.is_true(item_has_coord(spots.items[41812], 0.528, 0.586))
    end)

    it("includes sampled Wrath route coordinates from retail route import strings", function()
        local spots = load_material_farming_spots(true)

        assert.is_true(item_has_coord(spots.items[36909], 0.2265, 0.1390))
        assert.is_true(item_has_coord(spots.items[36912], 0.3585, 0.1733))
        assert.is_true(item_has_coord(spots.items[36903], 0.3287, 0.4645))
        assert.is_true(item_has_coord(spots.items[36906], 0.3517, 0.4279))
    end)

    it("includes researched Cataclysm farming data while leaving composed-only Cataclysm materials pending", function()
        local spots = load_material_farming_spots(true)
        local researched_cataclysm_ids = {
            52177, 52178, 52179, 52180, 52181, 52182, 52183, 52185, 52190, 52191,
            52192, 52193, 52194, 52195, 52325, 52326, 52327, 52328, 52329, 52718,
            52719, 52721, 52976, 52977, 52979, 52980, 52982, 52983, 52984, 52985,
            52986, 52987, 52988, 53010, 53038, 53062, 53063, 53064, 53065, 53066,
            53067, 53068, 53069, 53070, 53071, 53072, 62778, 62779, 62780, 62781,
            62782, 62783, 62784, 62785, 62791,
        }
        local composed_cataclysm_ids = {
            52186, 53643,
        }

        for _, item_id in ipairs(researched_cataclysm_ids) do
            local message = "missing researched Cataclysm farming entry: " .. tostring(item_id)
            assert.is_table(spots.items[item_id], message)
            assert.equals("researched", spots.items[item_id].researchStatus, message)
            assert.is_nil(spots.missingItems[item_id], message)
        end

        for _, item_id in ipairs(composed_cataclysm_ids) do
            local message = "composed-only Cataclysm item should stay pending: " .. tostring(item_id)
            assert.is_nil(spots.items[item_id], message)
            assert.is_table(spots.missingItems[item_id], message)
            assert.equals("missing", spots.missingItems[item_id].researchStatus, message)
        end
    end)

    it("keeps every researched Cataclysm spot anchored by coordinates", function()
        local spots = load_material_farming_spots(true)

        for item_id, item in pairs(spots.items) do
            if item.expansion == "cataclysm" then
                for _, spot in ipairs(item.spots or {}) do
                    local message = "Cataclysm spot needs coords: "
                        .. tostring(item_id)
                        .. " / "
                        .. tostring(spot.id)
                    assert.is_table(spot.coords, message)
                    assert.is_true(#spot.coords > 0, message)
                    for _, coord in ipairs(spot.coords) do
                        assert.is_number(coord.x, message)
                        assert.is_number(coord.y, message)
                        assert.is_true(coord.x >= 0 and coord.x <= 1, message)
                        assert.is_true(coord.y >= 0 and coord.y <= 1, message)
                        assert_non_empty_string(coord.label, message)
                    end
                end
            end
        end
    end)

    it("keeps Cataclysm farming sources retail-first for Wowhead pages", function()
        local spots = load_material_farming_spots(true)
        local blocked_patterns = {
            "wowhead%.com/cata",
            "wowhead%.com/classic",
            "classic%.wowhead",
        }

        local function assert_retail_wowhead_url(url, context)
            assert_non_empty_string(url)
            local lower_url = url:lower()
            for _, pattern in ipairs(blocked_patterns) do
                assert.is_nil(lower_url:find(pattern), context .. " used Classic/Cata Wowhead URL: " .. url)
            end
        end

        for item_id, item in pairs(spots.items) do
            if item.expansion == "cataclysm" then
                local item_context = "Cataclysm item " .. tostring(item_id)
                for _, url in ipairs(item.sourceUrls or {}) do
                    assert_retail_wowhead_url(url, item_context)
                end
                for _, spot in ipairs(item.spots or {}) do
                    local spot_context = item_context .. " spot " .. tostring(spot.id)
                    for _, url in ipairs(spot.sourceUrls or {}) do
                        assert_retail_wowhead_url(url, spot_context)
                    end
                end
            end
        end
    end)

    it("includes second-pass Cataclysm cooking, fishing, mining, and prospecting coordinates", function()
        local spots = load_material_farming_spots(true)

        assert.is_true(item_has_coord(spots.items[53066], 0.286, 0.110))
        assert.is_true(item_has_coord(spots.items[53070], 0.215, 0.473))
        assert.is_true(item_has_coord(spots.items[62780], 0.580, 0.380))
        assert.is_true(item_has_coord(spots.items[62782], 0.526, 0.794))
        assert.is_true(item_has_coord(spots.items[52979], 0.526, 0.794))
        assert.is_true(item_has_coord(spots.items[53038], 0.356, 0.698))
        assert.is_true(item_has_coord(spots.items[52185], 0.172, 0.567))
        assert.is_true(item_has_coord(spots.items[52177], 0.356, 0.698))
        assert.is_true(item_has_coord(spots.items[52190], 0.172, 0.567))

        local prospecting_route_found = false
        for _, spot in ipairs(spots.items[52190].spots or {}) do
            if spot.routeType == "prospecting-input-route" and spot.coords and #spot.coords > 0 then
                prospecting_route_found = true
            end
        end
        assert.is_true(prospecting_route_found)
    end)

    it("includes researched Mists farming data while leaving composed-only Mists materials pending", function()
        local spots = load_material_farming_spots(true)
        local researched_mists_ids = {
            72092, 72093, 72094, 72103, 72120, 72162, 72163, 72234, 72235, 72237,
            72238, 72988, 74247, 74248, 74249, 74250, 74833, 74834, 74837, 74838,
            74839, 74856, 74857, 74859, 74860, 74861, 74863, 74864, 74865, 74866,
            75014, 76130, 76131, 76133, 76134, 76135, 76136, 76137, 76138, 76139,
            76140, 76141, 76142, 79010, 79011, 79101, 83064, 89112,
        }
        local composed_mists_ids = {
            76061, 82441,
        }

        for _, item_id in ipairs(researched_mists_ids) do
            local message = "missing researched Mists farming entry: " .. tostring(item_id)
            assert.is_table(spots.items[item_id], message)
            assert.equals("researched", spots.items[item_id].researchStatus, message)
            assert.is_nil(spots.missingItems[item_id], message)
        end

        for _, item_id in ipairs(composed_mists_ids) do
            local message = "composed-only Mists item should stay pending: " .. tostring(item_id)
            assert.is_nil(spots.items[item_id], message)
            assert.is_table(spots.missingItems[item_id], message)
            assert.equals("missing", spots.missingItems[item_id].researchStatus, message)
        end
    end)

    it("keeps Mists farming sources retail-safe for Wowhead pages", function()
        local spots = load_material_farming_spots(true)
        local blocked_patterns = {
            "wowhead%.com/mop%-classic",
            "wowhead%.com/classic",
            "classic%.wowhead",
        }

        local function assert_retail_wowhead_url(url, context)
            assert_non_empty_string(url)
            local lower_url = url:lower()
            for _, pattern in ipairs(blocked_patterns) do
                assert.is_nil(lower_url:find(pattern), context .. " used Classic/MoP Classic Wowhead URL: " .. url)
            end
        end

        for item_id, item in pairs(spots.items) do
            if item.expansion == "mists" then
                local item_context = "Mists item " .. tostring(item_id)
                for _, url in ipairs(item.sourceUrls or {}) do
                    assert_retail_wowhead_url(url, item_context)
                end
                for _, spot in ipairs(item.spots or {}) do
                    local spot_context = item_context .. " spot " .. tostring(spot.id)
                    for _, url in ipairs(spot.sourceUrls or {}) do
                        assert_retail_wowhead_url(url, spot_context)
                    end
                end
            end
        end
    end)

    it("keeps every researched Mists spot anchored by coordinates", function()
        local spots = load_material_farming_spots(true)

        for item_id, item in pairs(spots.items) do
            if item.expansion == "mists" then
                for _, spot in ipairs(item.spots or {}) do
                    local message = "Mists spot needs coords: "
                        .. tostring(item_id)
                        .. " / "
                        .. tostring(spot.id)
                    assert.is_table(spot.coords, message)
                    assert.is_true(#spot.coords > 0, message)
                    for _, coord in ipairs(spot.coords) do
                        assert.is_number(coord.x, message)
                        assert.is_number(coord.y, message)
                        assert.is_true(coord.x >= 0 and coord.x <= 1, message)
                        assert.is_true(coord.y >= 0 and coord.y <= 1, message)
                        assert_non_empty_string(coord.label, message)
                    end
                end
            end
        end
    end)

    it("includes second-pass Mists route, cooking, fishing, and prospecting coordinates", function()
        local spots = load_material_farming_spots(true)

        assert.is_true(item_has_coord(spots.items[72092], 0.2934, 0.3115))
        assert.is_true(item_has_coord(spots.items[72093], 0.3482, 0.1875))
        assert.is_true(item_has_coord(spots.items[72235], 0.3049, 0.2988))
        assert.is_true(item_has_coord(spots.items[79011], 0.4232, 0.1112))
        assert.is_true(item_has_coord(spots.items[79101], 0.470, 0.548))
        assert.is_true(item_has_coord(spots.items[74837], 0.640, 0.330))
        assert.is_true(item_has_coord(spots.items[74838], 0.380, 0.620))
        assert.is_true(item_has_coord(spots.items[75014], 0.630, 0.580))
        assert.is_true(item_has_coord(spots.items[74839], 0.263, 0.415))
        assert.is_true(item_has_coord(spots.items[74865], 0.3464, 0.3424))
        assert.is_true(item_has_coord(spots.items[83064], 0.430, 0.840))
        assert.is_true(item_has_coord(spots.items[89112], 0.681, 0.490))
        assert.is_true(item_has_coord(spots.items[76131], 0.324, 0.684))

        local prospecting_route_found = false
        for _, spot in ipairs(spots.items[76130].spots or {}) do
            if spot.routeType == "prospecting-input-route" and spot.coords and #spot.coords > 0 then
                prospecting_route_found = true
            end
        end
        assert.is_true(prospecting_route_found)
    end)

    it("includes researched Warlords farming data while leaving sorcerous byproducts pending", function()
        local spots = load_material_farming_spots(true)
        local researched_warlords_ids = {
            109118, 109119, 109991, 109992, 115508, 109124, 109125, 109126, 109127, 109128,
            109129, 109624, 109625, 109626, 109627, 109628, 109629, 116053, 109131, 109132,
            109133, 109134, 109135, 109136, 109137, 109138, 109139, 109140, 109141, 109142,
            109143, 109144, 109693, 115502, 111245, 115504, 113588, 110609, 111557, 118472,
            120945, 127759,
        }
        local byproduct_warlords_ids = {
            113261, 113262, 113263, 113264,
        }

        for _, item_id in ipairs(researched_warlords_ids) do
            local message = "missing researched Warlords farming entry: " .. tostring(item_id)
            assert.is_table(spots.items[item_id], message)
            assert.equals("researched", spots.items[item_id].researchStatus, message)
            assert.is_nil(spots.missingItems[item_id], message)
        end

        for _, item_id in ipairs(byproduct_warlords_ids) do
            local message = "sorcerous Warlords byproduct should stay pending: " .. tostring(item_id)
            assert.is_nil(spots.items[item_id], message)
            assert.is_table(spots.missingItems[item_id], message)
            assert.equals("missing", spots.missingItems[item_id].researchStatus, message)
        end
    end)

    it("keeps Warlords farming sources retail-safe for Wowhead pages", function()
        local spots = load_material_farming_spots(true)
        local blocked_patterns = {
            "wowhead%.com/wod%-classic",
            "wowhead%.com/classic",
            "classic%.wowhead",
            "wotlk%-classic",
            "tbc%-classic",
            "mop%-classic",
            "cata%-classic",
        }

        local function assert_retail_wowhead_url(url, context)
            assert_non_empty_string(url)
            local lower_url = url:lower()
            for _, pattern in ipairs(blocked_patterns) do
                assert.is_nil(lower_url:find(pattern), context .. " used Classic Wowhead URL: " .. url)
            end
        end

        for item_id, item in pairs(spots.items) do
            if item.expansion == "warlords" then
                local item_context = "Warlords item " .. tostring(item_id)
                for _, url in ipairs(item.sourceUrls or {}) do
                    assert_retail_wowhead_url(url, item_context)
                end
                for _, spot in ipairs(item.spots or {}) do
                    local spot_context = item_context .. " spot " .. tostring(spot.id)
                    for _, url in ipairs(spot.sourceUrls or {}) do
                        assert_retail_wowhead_url(url, spot_context)
                    end
                end
            end
        end
    end)

    it("keeps every researched Warlords spot anchored by coordinates", function()
        local spots = load_material_farming_spots(true)

        for item_id, item in pairs(spots.items) do
            if item.expansion == "warlords" then
                for _, spot in ipairs(item.spots or {}) do
                    local message = "Warlords spot needs coords: "
                        .. tostring(item_id)
                        .. " / "
                        .. tostring(spot.id)
                    assert.is_table(spot.coords, message)
                    assert.is_true(#spot.coords > 0, message)
                    for _, coord in ipairs(spot.coords) do
                        assert.is_number(coord.x, message)
                        assert.is_number(coord.y, message)
                        assert.is_true(coord.x >= 0 and coord.x <= 1, message)
                        assert.is_true(coord.y >= 0 and coord.y <= 1, message)
                        assert_non_empty_string(coord.label, message)
                    end
                end
            end
        end
    end)

    it("includes researched Legion farming data with intermittent WQ materials labeled as researched", function()
        local spots = load_material_farming_spots(true)
        local researched_legion_ids = {
            123918, 123919, 124101, 124102, 124103, 124104, 124105, 124106, 124107, 124108,
            124109, 124110, 124111, 124112, 124113, 124115, 124117, 124118, 124119, 124120,
            124121, 124437, 124440, 124441, 124442, 124444, 151564, 151565, 151566, 151567,
        }

        for _, item_id in ipairs(researched_legion_ids) do
            local message = "missing researched Legion farming entry: " .. tostring(item_id)
            assert.is_table(spots.items[item_id], message)
            assert.equals("researched", spots.items[item_id].researchStatus, message)
            assert.is_nil(spots.missingItems[item_id], message)
        end
    end)

    it("keeps every researched Legion spot anchored by coordinates", function()
        local spots = load_material_farming_spots(true)

        for item_id, item in pairs(spots.items) do
            if item.expansion == "legion" then
                for _, spot in ipairs(item.spots or {}) do
                    local message = "Legion spot needs coords: "
                        .. tostring(item_id)
                        .. " / "
                        .. tostring(spot.id)
                    assert.is_table(spot.coords, message)
                    assert.is_true(#spot.coords > 0, message)
                    for _, coord in ipairs(spot.coords) do
                        assert.is_number(coord.x, message)
                        assert.is_number(coord.y, message)
                        assert.is_true(coord.x >= 0 and coord.x <= 1, message)
                        assert.is_true(coord.y >= 0 and coord.y <= 1, message)
                        assert_non_empty_string(coord.label, message)
                    end
                end
            end
        end
    end)

    it("includes researched Battle for Azeroth farming data", function()
        local spots = load_material_farming_spots(true)
        local researched_bfa_ids = {
            152505, 152506, 152507, 152508, 152509, 152510, 152511, 152512,
            152513, 152541, 152543, 152544, 152545, 152546, 152547, 152548,
            152549, 152576, 152577, 152579, 152631, 152668, 152875, 152876,
            152877, 153050, 153051, 153700, 153701, 153702, 153703, 153704,
            153705, 153706, 154120, 154121, 154122, 154123, 154124, 154125,
            154164, 154165, 154722, 154897, 154898, 154899, 160711, 162460,
            162461, 162515, 165703, 165948, 167562, 168185, 168188, 168189,
            168190, 168191, 168192, 168193, 168302, 168303, 168487, 168635,
            168645, 168646, 168649, 168650, 174327, 174328, 174353,
        }

        for _, item_id in ipairs(researched_bfa_ids) do
            local message = "missing researched Battle for Azeroth farming entry: " .. tostring(item_id)
            assert.is_table(spots.items[item_id], message)
            assert.equals("researched", spots.items[item_id].researchStatus, message)
            assert.is_nil(spots.missingItems[item_id], message)
        end
    end)

    it("keeps every researched Battle for Azeroth spot anchored by coordinates", function()
        local spots = load_material_farming_spots(true)

        for item_id, item in pairs(spots.items) do
            if item.expansion == "battleForAzeroth" then
                for _, spot in ipairs(item.spots or {}) do
                    local message = "Battle for Azeroth spot needs coords: "
                        .. tostring(item_id)
                        .. " / "
                        .. tostring(spot.id)
                    assert.is_table(spot.coords, message)
                    assert.is_true(#spot.coords > 0, message)
                    for _, coord in ipairs(spot.coords) do
                        assert.is_number(coord.x, message)
                        assert.is_number(coord.y, message)
                        assert.is_true(coord.x >= 0 and coord.x <= 1, message)
                        assert.is_true(coord.y >= 0 and coord.y <= 1, message)
                        assert_non_empty_string(coord.label, message)
                    end
                end
            end
        end
    end)

    it("keeps Battle for Azeroth farming sources on retail-safe pages", function()
        local spots = load_material_farming_spots(true)
        local blocked_patterns = {
            "wowhead%.com/tbc",
            "wowhead%.com/wotlk",
            "wowhead%.com/cata",
            "wowhead%.com/mop%-classic",
            "wowhead%.com/classic",
            "classic%.wowhead",
            "/tbc/",
            "/wotlk/",
            "/cata/",
            "/mop%-classic/",
        }

        local function assert_retail_url(url, context)
            assert_non_empty_string(url)
            local lower_url = url:lower()
            for _, pattern in ipairs(blocked_patterns) do
                assert.is_nil(lower_url:find(pattern), context .. " used Classic source URL: " .. url)
            end
        end

        for item_id, item in pairs(spots.items) do
            if item.expansion == "battleForAzeroth" then
                local item_context = "Battle for Azeroth item " .. tostring(item_id)
                for _, url in ipairs(item.sourceUrls or {}) do
                    assert_retail_url(url, item_context)
                end
                for _, spot in ipairs(item.spots or {}) do
                    local spot_context = item_context .. " spot " .. tostring(spot.id)
                    assert.is_true(#(spot.coords or {}) > 0, spot_context .. " has no coords")
                    for _, url in ipairs(spot.sourceUrls or {}) do
                        assert_retail_url(url, spot_context)
                    end
                end
            end
        end
    end)

    it("includes researched Shadowlands farming data", function()
        local spots = load_material_farming_spots(true)
        local researched_shadowlands_ids = {
            168583, 168586, 168589, 169701, 170554, 171315, 171828, 171829,
            171830, 171831, 171832, 171833, 171840, 171841, 172052, 172053,
            172054, 172055, 172089, 172092, 172094, 172096, 172097, 172230,
            172231, 172232, 173032, 173033, 173034, 173035, 173036, 173037,
            173108, 173109, 173110, 173170, 173171, 173172, 173173, 173202,
            173204, 179314, 179315, 187699, 187700, 187701, 187702, 187703,
            187704, 187707,
        }

        for _, item_id in ipairs(researched_shadowlands_ids) do
            local message = "missing researched Shadowlands farming entry: " .. tostring(item_id)
            assert.is_table(spots.items[item_id], message)
            assert.equals("researched", spots.items[item_id].researchStatus, message)
            assert.is_nil(spots.missingItems[item_id], message)
        end
    end)

    it("keeps every researched Shadowlands spot anchored by coordinates", function()
        local spots = load_material_farming_spots(true)

        for item_id, item in pairs(spots.items) do
            if item.expansion == "shadowlands" then
                for _, spot in ipairs(item.spots or {}) do
                    local message = "Shadowlands spot needs coords: "
                        .. tostring(item_id)
                        .. " / "
                        .. tostring(spot.id)
                    assert.is_table(spot.coords, message)
                    assert.is_true(#spot.coords > 0, message)
                    for _, coord in ipairs(spot.coords) do
                        assert.is_number(coord.x, message)
                        assert.is_number(coord.y, message)
                        assert.is_true(coord.x >= 0 and coord.x <= 1, message)
                        assert.is_true(coord.y >= 0 and coord.y <= 1, message)
                        assert_non_empty_string(coord.label, message)
                    end
                end
            end
        end
    end)

    it("keeps Shadowlands farming sources on retail-safe pages", function()
        local spots = load_material_farming_spots(true)
        local blocked_patterns = {
            "wowhead%.com/tbc",
            "wowhead%.com/wotlk",
            "wowhead%.com/cata",
            "wowhead%.com/mop%-classic",
            "wowhead%.com/classic",
            "classic%.wowhead",
            "/tbc/",
            "/wotlk/",
            "/cata/",
            "/mop%-classic/",
        }

        local function assert_retail_url(url, context)
            assert_non_empty_string(url)
            local lower_url = url:lower()
            for _, pattern in ipairs(blocked_patterns) do
                assert.is_nil(lower_url:find(pattern), context .. " used Classic source URL: " .. url)
            end
        end

        for item_id, item in pairs(spots.items) do
            if item.expansion == "shadowlands" then
                local item_context = "Shadowlands item " .. tostring(item_id)
                for _, url in ipairs(item.sourceUrls or {}) do
                    assert_retail_url(url, item_context)
                end
                for _, spot in ipairs(item.spots or {}) do
                    local spot_context = item_context .. " spot " .. tostring(spot.id)
                    assert.is_true(#(spot.coords or {}) > 0, spot_context .. " has no coords")
                    for _, url in ipairs(spot.sourceUrls or {}) do
                        assert_retail_url(url, spot_context)
                    end
                end
            end
        end
    end)

    it("includes researched Dragonflight farming data from strict coordinate-backed research", function()
        local spots = load_material_farming_spots(true)
        local researched_dragonflight_ids = {
            190311, 190312, 190313, 190314, 190315, 190320, 190326, 190327,
            190328, 190329, 190394, 190395, 190396, 191460, 191461, 191462,
            191464, 191465, 191466, 191467, 191468, 191469, 191470, 191471,
            191472, 192837, 192840, 192843, 192846, 192849, 192852, 192858,
            192861, 192865, 192868, 192869, 192872, 192880, 193050, 193208,
            193210, 193213, 193214, 193215, 193216, 193217, 193218, 193223,
            193251, 193255, 193922, 194123, 194124, 194545, 194730, 194966,
            194967, 194968, 194969, 194970, 197741, 197742, 197744, 197745,
            197746, 197747, 197748, 197749, 200113, 201399,
        }

        for _, item_id in ipairs(researched_dragonflight_ids) do
            local message = "missing researched Dragonflight farming entry: " .. tostring(item_id)
            assert.is_table(spots.items[item_id], message)
            assert.equals("researched", spots.items[item_id].researchStatus, message)
            assert.is_nil(spots.missingItems[item_id], message)
        end
    end)

    it("keeps every researched Dragonflight spot anchored by coordinates", function()
        local spots = load_material_farming_spots(true)

        for item_id, item in pairs(spots.items) do
            if item.expansion == "dragonflight" then
                for _, spot in ipairs(item.spots or {}) do
                    local message = "Dragonflight spot needs coords: "
                        .. tostring(item_id)
                        .. " / "
                        .. tostring(spot.id)
                    assert.is_table(spot.coords, message)
                    assert.is_true(#spot.coords > 0, message)
                    for _, coord in ipairs(spot.coords) do
                        assert.is_number(coord.x, message)
                        assert.is_number(coord.y, message)
                        assert.is_true(coord.x >= 0 and coord.x <= 1, message)
                        assert.is_true(coord.y >= 0 and coord.y <= 1, message)
                        assert_non_empty_string(coord.label, message)
                    end
                end
            end
        end
    end)

    it("keeps Dragonflight farming sources retail-safe and coordinate-backed", function()
        local spots = load_material_farming_spots(true)
        local blocked_patterns = {
            "wowhead%.com/tbc",
            "wowhead%.com/wotlk",
            "wowhead%.com/cata",
            "wowhead%.com/mop%-classic",
            "wowhead%.com/classic",
            "classic%.wowhead",
            "/tbc/",
            "/wotlk/",
            "/cata/",
            "/mop%-classic/",
        }

        local function assert_retail_url(url, context)
            assert_non_empty_string(url)
            local lower_url = url:lower()
            for _, pattern in ipairs(blocked_patterns) do
                assert.is_nil(lower_url:find(pattern), context .. " used Classic source URL: " .. url)
            end
        end

        for item_id, item in pairs(spots.items) do
            if item.expansion == "dragonflight" then
                local item_context = "Dragonflight item " .. tostring(item_id)
                for _, url in ipairs(item.sourceUrls or {}) do
                    assert_retail_url(url, item_context)
                end
                for _, spot in ipairs(item.spots or {}) do
                    local spot_context = item_context .. " spot " .. tostring(spot.id)
                    assert.is_true(#(spot.coords or {}) > 0, spot_context .. " has no coords")
                    for _, url in ipairs(spot.sourceUrls or {}) do
                        assert_retail_url(url, spot_context)
                    end
                end
            end
        end
    end)

    it("includes researched War Within farming data while leaving crafted alloys pending", function()
        local spots = load_material_farming_spots(true)
        local researched_warwithin_ids = {
            210796, 210797, 210798, 210799, 210800, 210801, 210802, 210803,
            210804, 210805, 210806, 210807, 210808, 210809, 210810, 210930,
            210931, 210932, 210933, 210934, 210935, 210936, 210937, 210938,
            210939, 212495, 212498, 212505, 212508, 212511, 212664, 212665,
            212666, 212667, 212670, 212672, 212673, 212674, 212675, 212676,
            213197, 213398, 213399, 213610, 213613, 218336, 218337, 219946,
            219947, 219948, 219949, 219950, 219951, 219952, 219953, 219954,
            220134, 220135, 220136, 220137, 220138, 220139, 220141, 220142,
            220143, 220144, 220145, 220146, 220147, 220148, 220149, 220150,
            220151, 220152, 220153, 221758, 222533, 224824, 224826, 226202,
            228231,
        }
        local crafted_alloy_ids = {
            222417, 222420, 222423, 222428,
        }
        local pending_research_ids = {
            221757, 223512, 225565, 225566, 225567, 225568, 225569, 225911,
            225912,
        }

        for _, item_id in ipairs(researched_warwithin_ids) do
            local message = "missing researched War Within farming entry: " .. tostring(item_id)
            assert.is_table(spots.items[item_id], message)
            assert.equals("researched", spots.items[item_id].researchStatus, message)
            assert.is_nil(spots.missingItems[item_id], message)
        end

        for _, item_id in ipairs(crafted_alloy_ids) do
            local message = "crafted-only War Within alloy should stay pending: " .. tostring(item_id)
            assert.is_nil(spots.items[item_id], message)
            assert.is_table(spots.missingItems[item_id], message)
            assert.equals("missing", spots.missingItems[item_id].researchStatus, message)
        end

        for _, item_id in ipairs(pending_research_ids) do
            local message = "unresearched War Within item should stay pending: " .. tostring(item_id)
            assert.is_nil(spots.items[item_id], message)
            assert.is_table(spots.missingItems[item_id], message)
            assert.equals("missing", spots.missingItems[item_id].researchStatus, message)
        end
    end)

    it("keeps every researched War Within spot anchored by coordinates", function()
        local spots = load_material_farming_spots(true)

        for item_id, item in pairs(spots.items) do
            if item.expansion == "warWithin" then
                for _, spot in ipairs(item.spots or {}) do
                    local message = "War Within spot needs coords: "
                        .. tostring(item_id)
                        .. " / "
                        .. tostring(spot.id)
                    assert.is_table(spot.coords, message)
                    assert.is_true(#spot.coords > 0, message)
                    for _, coord in ipairs(spot.coords) do
                        assert.is_number(coord.x, message)
                        assert.is_number(coord.y, message)
                        assert.is_true(coord.x >= 0 and coord.x <= 1, message)
                        assert.is_true(coord.y >= 0 and coord.y <= 1, message)
                        assert_non_empty_string(coord.label, message)
                    end
                end
            end
        end
    end)

    it("keeps War Within researched sources on retail URLs", function()
        local spots = load_material_farming_spots(true)
        local blocked_patterns = {
            "classic%.wowhead",
            "wowhead%.com/classic",
            "wowhead%.com/tbc",
            "wowhead%.com/wotlk",
            "wowhead%.com/cata",
            "wowhead%.com/mop%-classic",
            "/classic/",
            "/tbc/",
            "/wotlk/",
            "/cata/",
            "/mop%-classic/",
        }

        local function assert_retail_url(url, context)
            local lower_url = url:lower()
            for _, pattern in ipairs(blocked_patterns) do
                assert.is_nil(lower_url:find(pattern), context .. " used Classic source URL: " .. url)
            end
        end

        for item_id, item in pairs(spots.items) do
            if item.expansion == "warWithin" then
                local item_context = "War Within item " .. tostring(item_id)
                for _, url in ipairs(item.sourceUrls or {}) do
                    assert_retail_url(url, item_context)
                end
                for _, spot in ipairs(item.spots or {}) do
                    local spot_context = item_context .. " spot " .. tostring(spot.id)
                    assert.is_true(#(spot.coords or {}) > 0, spot_context .. " has no coords")
                    for _, url in ipairs(spot.sourceUrls or {}) do
                        assert_retail_url(url, spot_context)
                    end
                end
            end
        end
    end)

    it("includes researched Burning Crusade data while leaving composed-only BC materials pending", function()
        local spots = load_material_farming_spots(true)
        local researched_bc_ids = {
            21877, 21881, 21929, 22445, 22446, 22447, 22448, 22449, 22450, 22572,
            22573, 22574, 22575, 22576, 22577, 22578, 22785, 22786, 22787, 22788,
            22789, 22790, 22791, 22792, 22793, 22794, 23077, 23079, 23107, 23112,
            23117, 23424, 23425, 23426, 23427, 23436, 23437, 23438, 23439, 23440,
            23441, 24243, 25649, 27422, 27425, 27429, 27435, 27437, 27438, 27439,
            27671, 27674, 27678, 27681, 27682, 31670, 31671, 21887, 25699, 25700,
            25707, 25708, 29539, 29547, 29548,
        }
        local composed_bc_ids = {
            21840, 23793, 21884, 21885, 21886, 22451, 22452, 22456, 22457,
        }

        for _, item_id in ipairs(researched_bc_ids) do
            local message = "missing researched Burning Crusade farming entry: " .. tostring(item_id)
            assert.is_table(spots.items[item_id], message)
            assert.equals("researched", spots.items[item_id].researchStatus, message)
            assert.is_nil(spots.missingItems[item_id], message)
        end

        for _, item_id in ipairs(composed_bc_ids) do
            local message = "composed-only Burning Crusade material should stay pending: " .. tostring(item_id)
            assert.is_nil(spots.items[item_id], message)
            assert.is_table(spots.missingItems[item_id], message)
            assert.equals("missing", spots.missingItems[item_id].researchStatus, message)
        end
    end)

    it("models Burning Crusade primals as ten-mote composed materials", function()
        local data = load_data("Data/FarmingItems.lua", "FarmingItems")
        local items_by_id = {}
        for _, item in ipairs(data.items or {}) do
            items_by_id[item.itemID] = item
        end

        local primal_components = {
            [22451] = 22572,
            [22452] = 22573,
            [21884] = 22574,
            [21886] = 22575,
            [22457] = 22576,
            [22456] = 22577,
            [21885] = 22578,
        }

        for primal_id, mote_id in pairs(primal_components) do
            local item = items_by_id[primal_id]
            local message = "missing BC primal composed item: " .. tostring(primal_id)
            assert.is_table(item, message)
            assert.equals("burningCrusade", item.expansion, message)
            assert.equals("Primal", item.tag, message)
            assert.equals(1, item.outputQuantity, message)
            assert.is_table(item.components, message)
            assert.equals(1, #item.components, message)
            assert.equals(mote_id, item.components[1].itemID, message)
            assert.equals(10, item.components[1].quantity, message)
        end
    end)

    it("keeps every researched Burning Crusade spot anchored by coordinates", function()
        local spots = load_material_farming_spots(true)

        for item_id, item in pairs(spots.items) do
            if item.expansion == "burningCrusade" then
                for _, spot in ipairs(item.spots or {}) do
                    local message = "Burning Crusade spot needs coords: "
                        .. tostring(item_id)
                        .. " / "
                        .. tostring(spot.id)
                    assert.is_table(spot.coords, message)
                    assert.is_true(#spot.coords > 0, message)
                    for _, coord in ipairs(spot.coords) do
                        assert.is_number(coord.x, message)
                        assert.is_number(coord.y, message)
                        assert.is_true(coord.x >= 0 and coord.x <= 1, message)
                        assert.is_true(coord.y >= 0 and coord.y <= 1, message)
                        assert_non_empty_string(coord.label, message)
                    end
                end
            end
        end
    end)

    it("keeps Burning Crusade farming sources on retail-safe pages", function()
        local spots = load_material_farming_spots(true)
        local blocked_patterns = {
            "wowhead%.com/tbc",
            "wowhead%.com/classic",
            "classic%.wowhead",
            "classic%.goldgoblin",
            "tbc%-classic",
            "/tbc/",
        }

        local function assert_retail_url(url, context)
            assert_non_empty_string(url)
            local lower_url = url:lower()
            for _, pattern in ipairs(blocked_patterns) do
                assert.is_nil(lower_url:find(pattern), context .. " used Classic source URL: " .. url)
            end
        end

        for item_id, item in pairs(spots.items) do
            if item.expansion == "burningCrusade" then
                local item_context = "Burning Crusade item " .. tostring(item_id)
                for _, url in ipairs(item.sourceUrls or {}) do
                    assert_retail_url(url, item_context)
                end
                for _, spot in ipairs(item.spots or {}) do
                    local spot_context = item_context .. " spot " .. tostring(spot.id)
                    for _, url in ipairs(spot.sourceUrls or {}) do
                        assert_retail_url(url, spot_context)
                    end
                end
            end
        end
    end)

    it("includes exact sourced Burning Crusade coordinates from retail comments", function()
        local data = load_material_farming_spots()

        local adamantite_powder_isle_node_found = false
        for _, spot in ipairs(data.items[24243].spots) do
            for _, coord in ipairs(spot.coords or {}) do
                if coord.x == 0.610 and coord.y == 0.440 then
                    adamantite_powder_isle_node_found = true
                end
            end
        end

        local netherweb_terokkar_spiders_found = false
        for _, spot in ipairs(data.items[21881].spots) do
            for _, coord in ipairs(spot.coords or {}) do
                if coord.x == 0.440 and coord.y == 0.320 then
                    netherweb_terokkar_spiders_found = true
                end
            end
        end

        local buzzard_comment_route_found = false
        for _, spot in ipairs(data.items[27671].spots) do
            for _, coord in ipairs(spot.coords or {}) do
                if coord.x == 0.610 and coord.y == 0.730 then
                    buzzard_comment_route_found = true
                end
            end
        end

        assert.is_true(adamantite_powder_isle_node_found)
        assert.is_true(netherweb_terokkar_spiders_found)
        assert.is_true(buzzard_comment_route_found)
    end)

    it("includes sampled Burning Crusade route coordinates from Artisans of Azeroth import strings", function()
        local data = load_material_farming_spots()

        local fel_iron_aoa_pin_found = false
        for _, spot in ipairs(data.items[23424].spots) do
            for _, coord in ipairs(spot.coords or {}) do
                if coord.x == 0.3882 and coord.y == 0.3128 then
                    fel_iron_aoa_pin_found = true
                end
            end
        end

        local felweed_aoa_pin_found = false
        for _, spot in ipairs(data.items[22785].spots) do
            for _, coord in ipairs(spot.coords or {}) do
                if coord.x == 0.2768 and coord.y == 0.6189 then
                    felweed_aoa_pin_found = true
                end
            end
        end

        local fel_scales_aoa_pin_found = false
        for _, spot in ipairs(data.items[25700].spots) do
            for _, coord in ipairs(spot.coords or {}) do
                if coord.x == 0.5296 and coord.y == 0.2984 then
                    fel_scales_aoa_pin_found = true
                end
            end
        end

        assert.is_true(fel_iron_aoa_pin_found)
        assert.is_true(felweed_aoa_pin_found)
        assert.is_true(fel_scales_aoa_pin_found)
    end)

    it("does not include placeholder farming routes in researched data", function()
        local data = load_material_farming_spots()

        for item_id, item in pairs(data.items) do
            assert.equals("researched", item.researchStatus, "unexpected research status for " .. tostring(item_id))
            assert.is_false(item.fallback == true, "fallback item leaked into researched data: " .. tostring(item_id))
            for _, spot in ipairs(item.spots or {}) do
                assert.is_false(spot.confidence == "fallback", "fallback spot leaked: " .. tostring(item_id))
                local is_fallback_id = type(spot.id) == "string" and spot.id:find("^fallback%-") ~= nil
                assert.is_false(is_fallback_id, "fallback ID leaked: " .. tostring(item_id))
            end
        end
    end)

    it("includes exact sourced coordinates where comments provided them", function()
        local data = load_material_farming_spots()

        local frostweave_coords_found = false
        for _, spot in ipairs(data.items[33470].spots) do
            for _, coord in ipairs(spot.coords or {}) do
                if coord.x == 0.660 and coord.y == 0.500 then
                    frostweave_coords_found = true
                end
            end
        end

        local orbinid_coords_found = false
        for _, spot in ipairs(data.items[210802].spots) do
            for _, coord in ipairs(spot.coords or {}) do
                if coord.x == 0.3356 and coord.y == 0.8005 then
                    orbinid_coords_found = true
                end
            end
        end

        assert.is_true(frostweave_coords_found)
        assert.is_true(orbinid_coords_found)
    end)

    it("includes exact sourced coordinates from Shadowlands fishing and herb comments", function()
        local data = load_material_farming_spots()

        local silvergill_purity_found = false
        for _, spot in ipairs(data.items[173034].spots) do
            for _, coord in ipairs(spot.coords or {}) do
                if coord.x == 0.530 and coord.y == 0.730 then
                    silvergill_purity_found = true
                end
            end
        end

        local revendreth_herb_waypoint_found = false
        for _, spot in ipairs(data.items[168583].spots) do
            for _, coord in ipairs(spot.coords or {}) do
                if coord.x == 0.310 and coord.y == 0.527 then
                    revendreth_herb_waypoint_found = true
                end
            end
        end

        assert.is_true(silvergill_purity_found)
        assert.is_true(revendreth_herb_waypoint_found)
    end)

    it("includes exact sourced coordinates from Shadowlands second-pass routes", function()
        local data = load_material_farming_spots()

        assert.is_true(item_has_coord(data.items[173108], 0.6571, 0.2983))
        assert.is_true(item_has_coord(data.items[173171], 0.2636, 0.3816))
        assert.is_true(item_has_coord(data.items[187700], 0.6234, 0.2120))
        assert.is_true(item_has_coord(data.items[187699], 0.6931, 0.3355))
        assert.is_true(item_has_coord(data.items[187701], 0.494, 0.664))
        assert.is_true(item_has_coord(data.items[187702], 0.3301, 0.6963))
        assert.is_true(item_has_coord(data.items[187703], 0.694, 0.340))
        assert.is_true(item_has_coord(data.items[187704], 0.646, 0.334))
        assert.is_true(item_has_coord(data.items[187707], 0.3301, 0.6963))
    end)

    it("includes exact sourced coordinates from Mists farming guide comments", function()
        local data = load_material_farming_spots()

        local windwool_start_found = false
        for _, spot in ipairs(data.items[72988].spots) do
            for _, coord in ipairs(spot.coords or {}) do
                if coord.x == 0.5813 and coord.y == 0.4839 then
                    windwool_start_found = true
                end
            end
        end

        local fools_cap_windward_found = false
        for _, spot in ipairs(data.items[79011].spots) do
            for _, coord in ipairs(spot.coords or {}) do
                if coord.x == 0.680 and coord.y == 0.300 then
                    fools_cap_windward_found = true
                end
            end
        end

        assert.is_true(windwool_start_found)
        assert.is_true(fools_cap_windward_found)
    end)

    it("includes exact sourced coordinates from Warlords farming guide comments", function()
        local data = load_material_farming_spots()

        local clefthoof_camp_found = false
        for _, spot in ipairs(data.items[110609].spots) do
            for _, coord in ipairs(spot.coords or {}) do
                if coord.x == 0.787 and coord.y == 0.722 then
                    clefthoof_camp_found = true
                end
            end
        end

        local savage_blood_bull_found = false
        for _, spot in ipairs(data.items[118472].spots) do
            for _, coord in ipairs(spot.coords or {}) do
                if coord.x == 0.600 and coord.y == 0.300 then
                    savage_blood_bull_found = true
                end
            end
        end

        assert.is_true(clefthoof_camp_found)
        assert.is_true(savage_blood_bull_found)
    end)

    it("includes second-pass Warlords route, fishing, and byproduct coordinates", function()
        local spots = load_material_farming_spots()

        assert.is_true(item_has_coord(spots.items[109118], 0.5312, 0.4492))
        assert.is_true(item_has_coord(spots.items[109119], 0.4300, 0.4812))
        assert.is_true(item_has_coord(spots.items[109128], 0.8944, 0.4615))
        assert.is_true(item_has_coord(spots.items[109138], 0.4034, 0.7656))
        assert.is_true(item_has_coord(spots.items[109143], 0.5167, 0.3291))
        assert.is_true(item_has_coord(spots.items[127759], 0.3852, 0.4269))
    end)

    it("includes exact sourced coordinates from Legion guide comments", function()
        local data = load_material_farming_spots()

        local queenfish_pool_found = false
        for _, spot in ipairs(data.items[124107].spots) do
            for _, coord in ipairs(spot.coords or {}) do
                if coord.x == 0.483 and coord.y == 0.319 then
                    queenfish_pool_found = true
                end
            end
        end

        local stormray_pool_found = false
        for _, spot in ipairs(data.items[124110].spots) do
            for _, coord in ipairs(spot.coords or {}) do
                if coord.x == 0.369 and coord.y == 0.558 then
                    stormray_pool_found = true
                end
            end
        end

        local stormscale_crab_found = false
        for _, spot in ipairs(data.items[124115].spots) do
            for _, coord in ipairs(spot.coords or {}) do
                if coord.x == 0.680 and coord.y == 0.260 then
                    stormscale_crab_found = true
                end
            end
        end

        local fiendish_panthara_found = false
        for _, spot in ipairs(data.items[151566].spots) do
            for _, coord in ipairs(spot.coords or {}) do
                if coord.x == 0.735 and coord.y == 0.706 then
                    fiendish_panthara_found = true
                end
            end
        end

        assert.is_true(queenfish_pool_found)
        assert.is_true(stormray_pool_found)
        assert.is_true(stormscale_crab_found)
        assert.is_true(fiendish_panthara_found)
    end)

    it("includes second-pass Legion material additions and prospecting coverage", function()
        local spots = load_material_farming_spots(true)
        local researched_legion_ids = {
            123918, 123919, 151564, 124101, 124102, 124103, 124104, 124105, 124106,
            151565, 124113, 124115, 124116, 151566, 124437, 151567, 124440, 124441,
            124442, 124444, 124107, 124108, 124109, 124110, 124111, 124112, 124117,
            124118, 124119, 124120, 124121, 124124, 124438, 124439, 128304, 129100,
            129284, 129285, 129286, 129287, 129288, 129289, 130172, 130173, 130174,
            130175, 130176, 130177, 130178, 130179, 130180, 130181, 130182, 130183,
            133588, 133589, 133590, 133591, 133592, 133593, 133607, 133680, 151568,
        }

        for _, item_id in ipairs(researched_legion_ids) do
            local message = "missing researched Legion farming entry: " .. tostring(item_id)
            assert.is_table(spots.items[item_id], message)
            assert.equals("researched", spots.items[item_id].researchStatus, message)
            assert.is_nil(spots.missingItems[item_id], message)
        end
    end)

    it("keeps Legion farming sources on retail-safe pages", function()
        local spots = load_material_farming_spots(true)
        local blocked_patterns = {
            "wowhead%.com/tbc",
            "wowhead%.com/wotlk",
            "wowhead%.com/cata",
            "wowhead%.com/mop%-classic",
            "wowhead%.com/classic",
            "classic%.wowhead",
            "/tbc/",
            "/wotlk/",
            "/cata/",
            "/mop%-classic/",
        }

        local function assert_retail_url(url, context)
            assert_non_empty_string(url)
            local lower_url = url:lower()
            for _, pattern in ipairs(blocked_patterns) do
                assert.is_nil(lower_url:find(pattern), context .. " used Classic source URL: " .. url)
            end
        end

        for item_id, item in pairs(spots.items) do
            if item.expansion == "legion" then
                local item_context = "Legion item " .. tostring(item_id)
                for _, url in ipairs(item.sourceUrls or {}) do
                    assert_retail_url(url, item_context)
                end
                for _, spot in ipairs(item.spots or {}) do
                    local spot_context = item_context .. " spot " .. tostring(spot.id)
                    assert.is_true(#(spot.coords or {}) > 0, spot_context .. " has no coords")
                    for _, url in ipairs(spot.sourceUrls or {}) do
                        assert_retail_url(url, spot_context)
                    end
                end
            end
        end
    end)

    it("includes sampled Legion route coordinates from retail route import strings", function()
        local spots = load_material_farming_spots()

        assert.is_true(item_has_coord(spots.items[123918], 0.2121, 0.1693))
        assert.is_true(item_has_coord(spots.items[123919], 0.2121, 0.1693))
        assert.is_true(item_has_coord(spots.items[124102], 0.7421, 0.3759))
        assert.is_true(item_has_coord(spots.items[151565], 0.5879, 0.3141))
        assert.is_true(item_has_coord(spots.items[130172], 0.2121, 0.1693))
        assert.is_true(item_has_coord(spots.items[151568], 0.5879, 0.3141))
    end)

    it("includes Legion rare reagent and world-quest material coordinate anchors", function()
        local spots = load_material_farming_spots()

        assert.is_true(item_has_coord(spots.items[124116], 0.320, 0.550))
        assert.is_true(item_has_coord(spots.items[124124], 0.590, 0.316))
        assert.is_true(item_has_coord(spots.items[124438], 0.320, 0.370))
        assert.is_true(item_has_coord(spots.items[124439], 0.510, 0.610))
        assert.is_true(item_has_coord(spots.items[128304], 0.7421, 0.3759))
        assert.is_true(item_has_coord(spots.items[129100], 0.2420, 0.5070))
        assert.is_true(item_has_coord(spots.items[133607], 0.530, 0.730))
        assert.is_true(item_has_coord(spots.items[133680], 0.338, 0.115))
        assert.is_true(item_has_coord(spots.items[133588], 0.408, 0.652))
    end)

    it("includes exact sourced coordinates from Battle for Azeroth comments and guides", function()
        local data = load_material_farming_spots()

        assert.is_true(item_has_coord(data.items[152511], 0.3404, 0.2754))
        assert.is_true(item_has_coord(data.items[152512], 0.7638, 0.5083))
        assert.is_true(item_has_coord(data.items[152579], 0.4421, 0.4955))
        assert.is_true(item_has_coord(data.items[152631], 0.600, 0.460))
        assert.is_true(item_has_coord(data.items[152668], 0.770, 0.160))
        assert.is_true(item_has_coord(data.items[152668], 0.449, 0.402))
        assert.is_true(item_has_coord(data.items[153706], 0.4421, 0.4955))
        assert.is_true(item_has_coord(data.items[160711], 0.742, 0.224))
        assert.is_true(item_has_coord(data.items[162461], 0.5419, 0.5310))
        assert.is_true(item_has_coord(data.items[165703], 0.390, 0.020))
        assert.is_true(item_has_coord(data.items[168185], 0.4002, 0.1549))
        assert.is_true(item_has_coord(data.items[168487], 0.540, 0.410))
        assert.is_true(item_has_coord(data.items[168635], 0.4002, 0.1549))
        assert.is_true(item_has_coord(data.items[168646], 0.4067, 0.5575))
        assert.is_true(item_has_coord(data.items[174327], 0.840, 0.580))
        assert.is_true(item_has_coord(data.items[174328], 0.720, 0.580))
        assert.is_true(item_has_coord(data.items[174353], 0.308, 0.136))
    end)

    it("includes exact sourced coordinates from Dragonflight comments, guides, and NPC pins", function()
        local data = load_material_farming_spots()

        local herb_ore_route_found = false
        for _, spot in ipairs(data.items[190311].spots) do
            for _, coord in ipairs(spot.coords or {}) do
                if coord.x == 0.7510 and coord.y == 0.3814 then
                    herb_ore_route_found = true
                end
            end
        end

        local basilisk_pin_found = false
        for _, spot in ipairs(data.items[197745].spots) do
            for _, coord in ipairs(spot.coords or {}) do
                if coord.x == 0.674 and coord.y == 0.504 then
                    basilisk_pin_found = true
                end
            end
        end

        local bear_spine_route_found = false
        for _, spot in ipairs(data.items[201399].spots) do
            for _, coord in ipairs(spot.coords or {}) do
                if coord.x == 0.6391 and coord.y == 0.2977 then
                    bear_spine_route_found = true
                end
            end
        end

        local waterfall_pool_found = false
        for _, spot in ipairs(data.items[194730].spots) do
            for _, coord in ipairs(spot.coords or {}) do
                if coord.x == 0.630 and coord.y == 0.685 then
                    waterfall_pool_found = true
                end
            end
        end

        local serevite_route_found = false
        for _, spot in ipairs(data.items[190395].spots) do
            for _, coord in ipairs(spot.coords or {}) do
                if coord.x == 0.3054 and coord.y == 0.6863 then
                    serevite_route_found = true
                end
            end
        end

        local writhebark_pin_found = false
        for _, spot in ipairs(data.items[191470].spots) do
            for _, coord in ipairs(spot.coords or {}) do
                if coord.x == 0.2743 and coord.y == 0.4706 then
                    writhebark_pin_found = true
                end
            end
        end

        local bubble_poppy_water_pin_found = false
        for _, spot in ipairs(data.items[191467].spots) do
            for _, coord in ipairs(spot.coords or {}) do
                if coord.x == 0.6768 and coord.y == 0.6147 then
                    bubble_poppy_water_pin_found = true
                end
            end
        end

        local crystalspine_route_found = false
        for _, spot in ipairs(data.items[193251].spots) do
            for _, coord in ipairs(spot.coords or {}) do
                if coord.x == 0.6665 and coord.y == 0.5708 then
                    crystalspine_route_found = true
                end
            end
        end

        local vorquin_horn_route_found = false
        for _, spot in ipairs(data.items[193255].spots) do
            for _, coord in ipairs(spot.coords or {}) do
                if coord.x == 0.4073 and coord.y == 0.3971 then
                    vorquin_horn_route_found = true
                end
            end
        end

        local scaled_hide_pin_found = false
        for _, spot in ipairs(data.items[193223].spots) do
            for _, coord in ipairs(spot.coords or {}) do
                if coord.x == 0.2300 and coord.y == 0.6660 then
                    scaled_hide_pin_found = true
                end
            end
        end

        local prospecting_route_found = false
        for _, spot in ipairs(data.items[192852].spots) do
            for _, coord in ipairs(spot.coords or {}) do
                if coord.x == 0.3054 and coord.y == 0.6863 then
                    prospecting_route_found = true
                end
            end
        end

        assert.is_true(herb_ore_route_found)
        assert.is_true(basilisk_pin_found)
        assert.is_true(bear_spine_route_found)
        assert.is_true(waterfall_pool_found)
        assert.is_true(serevite_route_found)
        assert.is_true(writhebark_pin_found)
        assert.is_true(bubble_poppy_water_pin_found)
        assert.is_true(crystalspine_route_found)
        assert.is_true(vorquin_horn_route_found)
        assert.is_true(scaled_hide_pin_found)
        assert.is_true(prospecting_route_found)
    end)

    it("includes exact sourced coordinates from War Within comments, guides, and map pins", function()
        local data = load_material_farming_spots()

        local aqirite_object_pin_found = false
        for _, spot in ipairs(data.items[210933].spots) do
            for _, coord in ipairs(spot.coords or {}) do
                if coord.x == 0.210 and coord.y == 0.320 then
                    aqirite_object_pin_found = true
                end
            end
        end

        local blessing_blossom_pin_found = false
        for _, spot in ipairs(data.items[210806].spots) do
            for _, coord in ipairs(spot.coords or {}) do
                if coord.x == 0.187 and coord.y == 0.580 then
                    blessing_blossom_pin_found = true
                end
            end
        end

        local gloom_chitin_comment_found = false
        for _, spot in ipairs(data.items[212667].spots) do
            for _, coord in ipairs(spot.coords or {}) do
                if coord.x == 0.360 and coord.y == 0.460 then
                    gloom_chitin_comment_found = true
                end
            end
        end

        local profaned_tinderbox_chest_found = false
        for _, spot in ipairs(data.items[221758].spots) do
            for _, coord in ipairs(spot.coords or {}) do
                if coord.x == 0.3912 and coord.y == 0.7433 then
                    profaned_tinderbox_chest_found = true
                end
            end
        end

        local echoing_flux_vendor_found = false
        for _, spot in ipairs(data.items[226202].spots) do
            for _, coord in ipairs(spot.coords or {}) do
                if coord.x == 0.488 and coord.y == 0.626 then
                    echoing_flux_vendor_found = true
                end
            end
        end

        local luredrop_pin_found = item_has_coord(data.items[210799], 0.341, 0.157)
        local null_lotus_route_found = item_has_coord(data.items[213197], 0.187, 0.580)
        local thunderous_hide_route_found = item_has_coord(data.items[212673], 0.7388, 0.3264)
        local honed_bone_shards_pin_found = item_has_coord(data.items[218337], 0.5833, 0.6146)
        local duskweave_humanoid_pin_found = item_has_coord(data.items[224824], 0.470, 0.612)
        local gleaming_shard_feed_pin_found = item_has_coord(data.items[219949], 0.470, 0.612)
        local prospecting_ore_feed_found = item_has_coord(data.items[212508], 0.210, 0.320)
        local blood_pool_pin_found = item_has_coord(data.items[220147], 0.3507, 0.4550)
        local royal_ripple_pin_found = item_has_coord(data.items[220151], 0.4313, 0.4408)
        local coelacanth_water_pin_found = item_has_coord(data.items[220153], 0.5750, 0.7750)

        assert.is_true(aqirite_object_pin_found)
        assert.is_true(blessing_blossom_pin_found)
        assert.is_true(gloom_chitin_comment_found)
        assert.is_true(profaned_tinderbox_chest_found)
        assert.is_true(echoing_flux_vendor_found)
        assert.is_true(luredrop_pin_found)
        assert.is_true(null_lotus_route_found)
        assert.is_true(thunderous_hide_route_found)
        assert.is_true(honed_bone_shards_pin_found)
        assert.is_true(duskweave_humanoid_pin_found)
        assert.is_true(gleaming_shard_feed_pin_found)
        assert.is_true(prospecting_ore_feed_found)
        assert.is_true(blood_pool_pin_found)
        assert.is_true(royal_ripple_pin_found)
        assert.is_true(coelacanth_water_pin_found)
    end)
end)

describe("Data/RareDrops", function()
    it("matches the generated rare and loot counters", function()
        local data = load_data("Data/RareDrops.lua", "RareDropsData")

        assert_non_empty_string(data.source)
        assert.is_table(data.expansions)
        assert.is_table(data.expansions.options)
        assert.is_table(data.expansions.mapToExpansionID)
        assert.is_table(data.rares)
        assert.equals(data.rareCount, count_keys(data.rares))

        local loot_count = 0
        for npc_id, rare in pairs(data.rares) do
            assert.is_number(npc_id)
            assert.is_true(npc_id > 0)
            assert_non_empty_string(rare.name)
            assert.is_table(rare.loot)
            loot_count = loot_count + #rare.loot
            for _, item_id in ipairs(rare.loot) do
                assert.is_number(item_id)
                assert.is_true(item_id > 0)
            end
        end

        assert.equals(data.itemDropCount, loot_count)
    end)

    it("keeps rare location coordinates usable for waypoint actions", function()
        local data = load_data("Data/RareDrops.lua", "RareDropsData")
        local located_rares = 0

        for _, rare in pairs(data.rares) do
            if type(rare.locations) == "table" and #rare.locations > 0 then
                located_rares = located_rares + 1
                for _, location in ipairs(rare.locations) do
                    assert.is_number(location.mapID)
                    assert.is_true(location.mapID > 0)
                    assert.is_number(location.x)
                    assert.is_number(location.y)
                    assert.is_true(location.x >= 0)
                    assert.is_true(location.y >= 0)
                end
            end
        end

        assert.is_true(located_rares > 0)
    end)
end)

describe("Data/InstanceDrops", function()
    it("matches the generated instance, boss, and source counters", function()
        local data = load_data("Data/InstanceDrops.lua", "InstanceDropsData")

        assert_non_empty_string(data.source)
        assert_non_empty_string(data.sourceLicense)
        assert.is_table(data.expansions)
        assert.is_table(data.expansions.options)
        assert.is_table(data.instances)
        assert.equals(data.instanceCount, count_keys(data.instances))

        local boss_count = 0
        local item_source_count = 0
        for instance_id, instance in pairs(data.instances) do
            assert.is_number(instance_id)
            assert.is_true(instance_id > 0)
            assert_non_empty_string(instance.name)
            assert.is_number(instance.expansionID)
            assert_non_empty_string(instance.expansion)
            assert_non_empty_string(instance.contentType)
            assert.is_table(instance.bosses)

            for _, boss in pairs(instance.bosses) do
                boss_count = boss_count + 1
                assert_non_empty_string(boss.name)
                assert.is_table(boss.loot)
                item_source_count = item_source_count + #boss.loot
                for _, loot in ipairs(boss.loot) do
                    assert.is_number(loot.itemID)
                    assert.is_true(loot.itemID >= 0)
                    if loot.difficulties then
                        assert.is_table(loot.difficulties)
                    end
                end
            end
        end

        assert.equals(data.bossCount, boss_count)
        assert.equals(data.itemSourceCount, item_source_count)
    end)
end)

describe("Data/ATTBoEDrops", function()
    it("matches the generated ATT BoE counters", function()
        local data = load_data("Data/ATTBoEDrops.lua", "ATTBoEDropsData")

        assert_non_empty_string(data.source)
        assert_non_empty_string(data.sourceLicense)
        assert.is_table(data.expansions)
        assert.is_table(data.expansions.options)
        assert.is_table(data.instances)
        assert.is_table(data.zones)
        assert.is_table(data.world)
        assert.is_table(data.world.items)
        assert.equals(data.instanceCount, count_keys(data.instances))
        assert.equals(data.zoneCount, count_keys(data.zones))
        assert.equals(data.worldItemCount, #data.world.items)

        local instance_item_count = 0
        for instance_id, instance in pairs(data.instances) do
            assert.is_number(instance_id)
            assert.is_true(instance_id > 0)
            assert_non_empty_string(instance.name)
            assert.is_number(instance.expansionID)
            assert_non_empty_string(instance.expansion)
            assert_non_empty_string(instance.contentType)
            assert.is_table(instance.items)
            instance_item_count = instance_item_count + #instance.items
            for _, item in ipairs(instance.items) do
                assert.is_number(item.itemID)
                assert.is_true(item.itemID > 0)
            end
        end

        local zone_item_count = 0
        for map_id, zone in pairs(data.zones) do
            assert.is_number(map_id)
            assert.is_true(map_id > 0)
            assert.equals(map_id, zone.mapID)
            assert.is_number(zone.expansionID)
            assert_non_empty_string(zone.expansion)
            assert.is_table(zone.items)
            zone_item_count = zone_item_count + #zone.items
            for _, item in ipairs(zone.items) do
                assert.is_number(item.itemID)
                assert.is_true(item.itemID > 0)
            end
        end

        for _, item in ipairs(data.world.items) do
            assert.is_number(item.itemID)
            assert.is_true(item.itemID > 0)
        end

        assert.equals(data.instanceItemCount, instance_item_count)
        assert.equals(data.zoneItemCount, zone_item_count)
    end)
end)
