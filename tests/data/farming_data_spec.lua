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

local function item_has_spot(item, spot_id)
    for _, spot in ipairs((item or {}).spots or {}) do
        if spot.id == spot_id then
            return true
        end
    end

    return false
end

local function find_spot(item, spot_id)
    for _, spot in ipairs((item or {}).spots or {}) do
        if spot.id == spot_id then
            return spot
        end
    end

    return nil
end

local function spot_has_coord(item, spot_id, x, y)
    for _, spot in ipairs((item or {}).spots or {}) do
        if spot.id == spot_id then
            for _, coord in ipairs(spot.coords or {}) do
                if coord.x == x and coord.y == y then
                    return true
                end
            end
        end
    end

    return false
end

local MATERIAL_FARMING_SPOT_MODULES = {
    "Data/MaterialFarmingSpots.lua",
    "Data/MaterialFarmingSpots/Shared.lua",
    "Data/MaterialFarmingSpots/BurningCrusade/NpcLocations.lua",
    "Data/MaterialFarmingSpots/BurningCrusade/NpcLocationsElementals.lua",
    "Data/MaterialFarmingSpots/BurningCrusade/NpcLocationsSkinning.lua",
    "Data/MaterialFarmingSpots/BurningCrusade/NpcLocationsCooking.lua",
    "Data/MaterialFarmingSpots/BurningCrusade/NpcLocationsStarterZones.lua",
    "Data/MaterialFarmingSpots/BurningCrusade/NpcLocationsTailoring.lua",
    "Data/MaterialFarmingSpots/BurningCrusade/NpcLocationsMiscellaneous.lua",
    "Data/MaterialFarmingSpots/BurningCrusade/NpcLocationsReputation.lua",
    "Data/MaterialFarmingSpots/BurningCrusade/NpcLocationsReputationAdditional.lua",
    "Data/MaterialFarmingSpots/BurningCrusade/NpcLocationsNagrandMiscellaneous.lua",
    "Data/MaterialFarmingSpots/BurningCrusade/ObjectLocations.lua",
    "Data/MaterialFarmingSpots/BurningCrusade/ObjectLocationsFishing.lua",
    "Data/MaterialFarmingSpots/BurningCrusade/ObjectLocationsMiscellaneous.lua",
    "Data/MaterialFarmingSpots/Classic/Alchemy.lua",
    "Data/MaterialFarmingSpots/Classic/Enchanting.lua",
    "Data/MaterialFarmingSpots/Classic/Herbalism.lua",
    "Data/MaterialFarmingSpots/Classic/Jewelcrafting.lua",
    "Data/MaterialFarmingSpots/Classic/Mining.lua",
    "Data/MaterialFarmingSpots/Classic/Skinning.lua",
    "Data/MaterialFarmingSpots/Classic/Tailoring.lua",
    "Data/MaterialFarmingSpots/Classic/Fishing.lua",
    "Data/MaterialFarmingSpots/Classic/Reagents.lua",
    "Data/MaterialFarmingSpots/Classic/Housing.lua",
    "Data/MaterialFarmingSpots/BurningCrusade/Alchemy.lua",
    "Data/MaterialFarmingSpots/BurningCrusade/Cooking.lua",
    "Data/MaterialFarmingSpots/BurningCrusade/Enchanting.lua",
    "Data/MaterialFarmingSpots/BurningCrusade/Fishing.lua",
    "Data/MaterialFarmingSpots/BurningCrusade/Herbalism.lua",
    "Data/MaterialFarmingSpots/BurningCrusade/Jewelcrafting.lua",
    "Data/MaterialFarmingSpots/BurningCrusade/Mining.lua",
    "Data/MaterialFarmingSpots/BurningCrusade/Skinning.lua",
    "Data/MaterialFarmingSpots/BurningCrusade/Tailoring.lua",
    "Data/MaterialFarmingSpots/BurningCrusade/Miscellaneous.lua",
    "Data/MaterialFarmingSpots/BurningCrusade/Housing.lua",
    "Data/MaterialFarmingSpots/Wrath/Enchanting.lua",
    "Data/MaterialFarmingSpots/Wrath/Engineering.lua",
    "Data/MaterialFarmingSpots/Wrath/Cooking.lua",
    "Data/MaterialFarmingSpots/Wrath/Fishing.lua",
    "Data/MaterialFarmingSpots/Wrath/Herbalism.lua",
    "Data/MaterialFarmingSpots/Wrath/Jewelcrafting.lua",
    "Data/MaterialFarmingSpots/Wrath/Mining.lua",
    "Data/MaterialFarmingSpots/Wrath/Skinning.lua",
    "Data/MaterialFarmingSpots/Wrath/Tailoring.lua",
    "Data/MaterialFarmingSpots/Wrath/Reagents.lua",
    "Data/MaterialFarmingSpots/Wrath/Miscellaneous.lua",
    "Data/MaterialFarmingSpots/Wrath/Housing.lua",
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
    "Data/MaterialFarmingSpots/Mists/Reagents.lua",
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
    "Data/MaterialFarmingSpots/Dragonflight/Reagents.lua",
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
    "Data/MaterialFarmingSpots/WITGathering.lua",
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
        assert.equals("miscellaneous", data.professions[#data.professions].id)
        assert.equals("Miscellaneous", data.professions[#data.professions].label)
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
        assert.equals("Creature Reagent", items_by_id[201399].tag)
        assert.same({ "miscellaneous" }, items_by_id[201399].professions)
        assert.equals("Herb", items_by_id[191470].tag)
        assert.equals("Gem", items_by_id[192852].tag)
    end)

    it("distinguishes instance mining materials from outdoor gathered ore", function()
        local data = load_data("Data/FarmingItems.lua", "FarmingItems")
        local items_by_id = {}

        for _, item in ipairs(data.items or {}) do
            items_by_id[item.itemID] = item
        end

        assert.is_nil(items_by_id[2770].acquisitionType)
        assert.equals("Dungeon Ore", items_by_id[11370].tag)
        assert.equals("Raid Ore", items_by_id[18562].tag)
        assert.equals("Obsidian Shard", items_by_id[22202].tag)
        assert.equals("Obsidian Shard", items_by_id[22203].tag)
        for _, item_id in ipairs({ 11370, 18562, 22202, 22203 }) do
            assert.equals("instance", items_by_id[item_id].acquisitionType)
        end
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

    it("keeps every Burning Crusade farming spot isolated in its own dropdown option", function()
        local spots, ns = load_material_farming_spots(true)
        local chunk, err = loadfile("UI/CraftingFarmingWindow.lua")
        assert(chunk, err)
        chunk("General-Gold-Tracker", ns)

        for item_id, item in pairs(spots.items) do
            if item.expansion == "burningCrusade" then
                local expected_spots = {}
                for _, spot in ipairs(item.spots or {}) do
                    if type(spot.mapName) == "string"
                        and not spot.mapName:find("/", 1, true)
                        and type(spot.coords) == "table"
                        and #spot.coords > 0
                    then
                        expected_spots[spot.id] = spot
                    end
                end

                local seen_spots = {}
                for _, option in ipairs(ns.GoldTracker:BuildMaterialFarmingMapOptions(item_id)) do
                    if option.sourceType == "static" then
                        local context = "item " .. tostring(item_id) .. " spot " .. tostring(option.id)
                        assert.is_table(expected_spots[option.id], "unexpected dropdown option for " .. context)
                        assert.is_nil(seen_spots[option.id], "duplicate dropdown option for " .. context)
                        seen_spots[option.id] = true
                        assert.equals(1, option.spotCount, context)
                        assert.is_true(#(option.pins or {}) > 0, context)
                        for _, pin in ipairs(option.pins or {}) do
                            assert.equals(option.id, pin.routeID, context)
                            assert.equals(option.mapID, pin.mapID, context)
                        end
                    end
                end

                for spot_id in pairs(expected_spots) do
                    assert.is_true(
                        seen_spots[spot_id] == true,
                        "missing dropdown option for item " .. tostring(item_id) .. " spot " .. tostring(spot_id)
                    )
                end
            end
        end

        local terocone_options = ns.GoldTracker:BuildMaterialFarmingMapOptions(22789)
        local wind_scale_options = ns.GoldTracker:BuildMaterialFarmingMapOptions(29547)
        assert.equals(3, #terocone_options)
        assert.equals(2, #wind_scale_options)
        assert.equals("wind-scales-blades-edge-scalewing-shelf", wind_scale_options[1].id)
        assert.equals("wind-scales-shadowmoon-eclipsion-dragonhawks", wind_scale_options[2].id)
    end)

    it("includes researched Classic farming data while leaving composed-only Classic materials pending", function()
        local spots = load_material_farming_spots(true)
        local researched_classic_ids = {
            765, 774, 783, 785, 818, 1206, 1210, 1529, 1705, 2318,
            2319, 2447, 2450, 2452, 2453, 2589, 2592, 2770, 2771, 2772,
            2775, 2776, 2835, 2836, 2838, 2934, 3355, 3356, 3357, 3358,
            3369, 3818, 3820, 3821, 3858, 3864, 4232, 4234, 4235, 4304,
            4306, 4338, 4625, 7067, 7068, 7069, 7070, 7076, 7078, 7080,
            7082, 7909, 7910, 7911, 7912, 8153, 8169, 8170, 8171, 8831, 8836,
            8838, 8839, 8845, 8846, 10620, 11370, 12361, 12363, 12364, 12365,
            12799, 12800, 12803, 12808, 13463, 13464, 13465, 13466, 13467,
            13468, 14047, 14256, 16202, 16203, 18562, 22202, 22203, 2449,
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

    it("includes the non-ore and non-herb Classic specialty-material discovery pass", function()
        local spots = load_material_farming_spots(true)
        local specialty_ids = {
            6470, 6471, 8154, 8165, 8167, 15408, 15412, 15414, 15415, 15416,
            15417, 15419, 15422, 15423, 17012, 19767, 19768, 20381,
            3182, 4337, 14227,
            5523, 5524, 7973, 5498, 5500, 7971, 13926, 5503, 5504, 7974,
            6358, 6359, 13422,
            7075, 7077, 7079, 7081, 7972, 11382, 12809, 12811, 17010, 17011,
            20520, 5784, 5785, 15420, 1475, 1288, 3174, 8151, 12804, 18512,
            8146, 5635, 5637, 12207, 8150, 245586, 6474, 6475, 6476,
            10940, 11083, 11137, 11176, 16204, 10938, 10939, 10998, 11082,
            11134, 11135, 11174, 11175, 10978, 11084, 11138, 11139, 11177,
            11178, 14343, 14344, 20725,
        }

        for _, item_id in ipairs(specialty_ids) do
            local message = "missing Classic specialty farming entry: " .. tostring(item_id)
            assert.is_table(spots.items[item_id], message)
            assert.equals("classic", spots.items[item_id].expansion, message)
            assert.equals("researched", spots.items[item_id].researchStatus, message)
            assert.is_true(spots.items[item_id].category ~= "Ore", message)
            assert.is_true(spots.items[item_id].category ~= "Herb", message)
        end
    end)

    it("adds unusual auction farms and excludes non-tradeable or vendor-sourced inputs", function()
        local spots = load_material_farming_spots(true)
        local catalog = load_data("Data/FarmingItems.lua", "FarmingItems")
        local items = {}
        for _, item in ipairs(catalog.items or {}) do
            items[item.itemID] = item
        end

        local unusual_ids = {
            20381, 6474, 6475, 6476,
            44703, 43299, 92426, 161344, 187662,
            201399, 201404, 201405, 201883, 200224, 201991,
        }
        for _, item_id in ipairs(unusual_ids) do
            local message = "missing unusual auction farm: " .. tostring(item_id)
            assert.is_table(items[item_id], message)
            assert.is_table(spots.items[item_id], message)
            assert.equals("researched", spots.items[item_id].researchStatus, message)
        end

        assert.is_nil(items[208015]) -- Stuffed Deviate Scale Pouch is bind-on-pickup.
        for _, vendor_item_id in ipairs({ 2321, 2325, 2604, 2880, 4289, 4341, 4342, 8925, 14341, 39354 }) do
            assert.is_nil(items[vendor_item_id])
        end
        assert.is_nil(items[236952].components) -- Mote of Pure Void is not an assumed match for "Mote of Night".
        assert.is_true(item_has_coord(spots.items[25699], 0.300, 0.700))
        assert.is_true(item_has_coord(spots.items[20381], 0.692, 0.540))
        assert.is_true(item_has_coord(spots.items[187662], 0.518, 0.745))
        assert.is_true(item_has_coord(spots.items[201404], 0.770, 0.170))
        assert.is_true(item_has_coord(spots.items[201883], 0.224, 0.677))

        assert.same({
            { itemID = 6471, quantity = 6 },
            { itemID = 6470, quantity = 4 },
        }, items[6468].components)
        assert.equals(6, items[20380].components[2].quantity)
        assert.equals(20381, items[20380].components[2].itemID)
    end)

    it("models Classic crafted intermediates and Midnight housing decor as expandable compositions", function()
        local data = load_data("Data/FarmingItems.lua", "FarmingItems")
        local items = {}
        for _, item in ipairs(data.items or {}) do
            items[item.itemID] = item
        end

        local composed_ids = {
            4231, 4233, 4236, 8172, 15409, 15407, 14342, 12360, 12810,
            15994, 16000, 16006, 3470, 3478, 3486, 7966, 12644,
            6338, 11128, 11144, 16206,
            4357, 4364, 4377, 10505, 15992, 4361, 4371, 4375, 4382,
            4387, 10558, 10559, 10560, 18631, 6370, 6371, 13423,
            43119, 43120, 43121, 43123, 10308,
        }
        for _, item_id in ipairs(composed_ids) do
            local message = "missing expandable Classic intermediate: " .. tostring(item_id)
            assert.is_table(items[item_id], message)
            assert.is_table(items[item_id].components, message)
            assert.is_true(#items[item_id].components > 0, message)
        end

        local housing_ids = {
            257100, 257041, 246111, 246489, 263027, 253250, 246410, 246700,
            245502, 245503, 246420, 258289, 246423, 246488, 246413, 242948,
            257725, 246685, 243336,
        }
        for _, item_id in ipairs(housing_ids) do
            local message = "missing expandable Classic housing recipe: " .. tostring(item_id)
            assert.is_table(items[item_id], message)
            assert.equals("classic", items[item_id].expansion, message)
            assert.equals("Housing Decor", items[item_id].tag, message)
            assert.is_table(items[item_id].components, message)
            assert.is_true(#items[item_id].components >= 2, message)
        end

        assert.same({ { itemID = 12359, quantity = 1 }, { itemID = 12363, quantity = 1 } }, items[12360].components)
        assert.same({ { itemID = 12360, quantity = 1 }, { itemID = 14227, quantity = 1 } }, items[16006].components)
        assert.equals(2, items[10308].outputQuantity)
        assert.same({ { itemID = 43120, quantity = 1 } }, items[10308].components)
        assert.equals(40, items[246410].components[1].quantity)
        assert.equals(245586, items[246410].components[1].itemID)
    end)

    it("links every Classic Midnight housing recipe back to its researched farm materials", function()
        local spots, ns = load_material_farming_spots(true)
        local housing = ns.ClassicHousing

        assert.is_table(housing)
        assert.equals(19, #housing.recipes)
        assert.equals(19, #spots.items[245586].housingUses)

        local devilsaur_use
        for _, use in ipairs(spots.items[15417].housingUses or {}) do
            if use.outputItemID == 257725 then
                devilsaur_use = use
            end
        end
        assert.is_table(devilsaur_use)
        assert.equals(8, devilsaur_use.quantity)

        local core_use_count = 0
        for _, use in ipairs(spots.items[17011].housingUses or {}) do
            core_use_count = core_use_count + 1
        end
        assert.equals(2, core_use_count)
    end)

    it("keeps imported Classic herbalism routes as separate spot entries", function()
        local spots = load_material_farming_spots(true)
        local expectations = {
            { 2447, "classic-herb-2447-peaceSilverTirisfalMain", 0.4592, 0.2929 },
            { 765, "classic-herb-765-peaceSilverElwynnAlt", 0.2700, 0.8700 },
            { 2449, "classic-herb-2449-earthrootMulgoreMain", 0.3300, 0.7400 },
            { 2449, "classic-herb-2449-earthrootDunMoroghAlt", 0.2000, 0.5600 },
            { 785, "classic-herb-785-briarMageHillsbradMain", 0.4694, 0.1090 },
            { 2450, "classic-herb-2450-briarMageDarkshoreAlt", 0.4200, 0.9100 },
            { 2452, "classic-herb-2452-briarMageHillsbradMain", 0.4694, 0.1090 },
            { 3820, "classic-herb-3820-stranglekelpThousandNeedlesMain", 0.3142, 0.2420 },
            { 2453, "classic-herb-2453-bruiseSteelbloomStranglethornMain", 0.2285, 0.1954 },
            { 3355, "classic-herb-3355-bruiseSteelbloomStranglethornMain", 0.2285, 0.1954 },
            { 3369, "classic-herb-3369-graveMossDuskwoodMain", 0.1800, 0.3000 },
            { 3356, "classic-herb-3356-kingsbloodStranglethornMain", 0.3704, 0.2165 },
            { 3356, "classic-herb-3356-wplKingsKhadgarFadeRoute", 0.3300, 0.8200 },
            { 3357, "classic-herb-3357-wplLiferootBlindweedRoute", 0.5500, 0.8300 },
            { 3357, "classic-herb-3357-eplLiferootKhadgarSungrassRoute", 0.0800, 0.6500 },
            { 3358, "classic-herb-3358-eplLiferootKhadgarSungrassRoute", 0.0800, 0.6500 },
            { 3818, "classic-herb-3818-fadeleafFeralasMain", 0.6879, 0.4354 },
            { 3821, "classic-herb-3821-goldthornHinterlandsMain", 0.3378, 0.4415 },
            { 3821, "classic-herb-3821-goldthornArathiAlt", 0.2226, 0.1899 },
            { 4625, "classic-herb-4625-firebloomBurningSteppesMain", 0.1400, 0.5300 },
            { 4625, "classic-herb-4625-firebloomSearingGorgeAlt", 0.2400, 0.7100 },
            { 4625, "classic-herb-4625-firebloomTanarisAlt", 0.3700, 0.1900 },
            { 8831, "classic-herb-8831-purpleLotusFelwoodMain", 0.5700, 0.8500 },
            { 8838, "classic-herb-8838-sungrassThousandNeedlesMain", 0.3000, 0.5200 },
            { 8839, "classic-herb-8839-blindweedFeralasMain", 0.2700, 0.3500 },
            { 8845, "classic-herb-8845-ghostMushroomUngoroMain", 0.6300, 0.1600 },
            { 8845, "classic-herb-8845-ghostMushroomZangarmarshAlt", 0.7500, 0.9100 },
            { 8846, "classic-herb-8846-felwoodGromSansamRoute", 0.4086, 0.3153 },
            { 8846, "classic-herb-8846-gromDreamBlastedLandsRoute", 0.3900, 0.1800 },
            { 13464, "classic-herb-13464-goldenSansamSwampMain", 0.1400, 0.5400 },
            { 13464, "classic-herb-13464-felwoodGromSansamRoute", 0.4086, 0.3153 },
            { 13463, "classic-herb-13463-silithusDreamSilversageLotusRoute", 0.1800, 0.2900 },
            { 13465, "classic-herb-13465-winterspringSilversageIcecapLotusRoute", 0.3100, 0.3700 },
            { 13465, "classic-herb-13465-silithusDreamSilversageLotusRoute", 0.1800, 0.2900 },
            { 13467, "classic-herb-13467-winterspringSilversageIcecapLotusRoute", 0.3100, 0.3700 },
            { 13468, "classic-herb-13468-silithusDreamSilversageLotusRoute", 0.1800, 0.2900 },
            { 13468, "classic-herb-13468-winterspringSilversageIcecapLotusRoute", 0.3100, 0.3700 },
            { 13468, "classic-herb-13468-gromDreamBlastedLandsRoute", 0.3900, 0.1800 },
            { 8153, "classic-herb-8153-purpleLotusFelwoodMain", 0.5700, 0.8500 },
            { 8153, "classic-herb-8153-goldthornHinterlandsMain", 0.3378, 0.4415 },
        }

        for _, expected in ipairs(expectations) do
            local item_id, spot_id, x, y = expected[1], expected[2], expected[3], expected[4]
            local item = spots.items[item_id]
            local message = "missing imported Classic herbalism spot: " .. spot_id
            assert.is_true(item_has_spot(item, spot_id), message)
            assert.is_true(spot_has_coord(item, spot_id, x, y), message)
        end
    end)

    it("keeps imported Classic herbalism route notes on each dropdown spot", function()
        local spots = load_material_farming_spots(true)
        local ghost_mushroom = spots.items[8845]
        local ungoro = find_spot(ghost_mushroom, "classic-herb-8845-ghostMushroomUngoroMain")
        local zangarmarsh = find_spot(ghost_mushroom, "classic-herb-8845-ghostMushroomZangarmarshAlt")

        assert.is_table(ungoro)
        assert.equals("Un'Goro Crater Fungal Rock cave Ghost Mushroom route", ungoro.location)
        assert.equals("cave-herbalism-loop", ungoro.routeType)
        assert.equals("Cave farm, not a classic zone perimeter farm.", ungoro.dropDifficulty)
        assert.equals("Enter Fungal Rock and fully clear the cave's herb spawns.", ungoro.tips[1])
        assert.equals(
            "Use the route to guide you into and around the cave area rather than circling Un'Goro.",
            ungoro.tips[2]
        )

        assert.is_table(zangarmarsh)
        assert.equals("Zangarmarsh Funggor Cavern Ghost Mushroom route", zangarmarsh.location)
        assert.equals("cave-herbalism-loop", zangarmarsh.routeType)
        assert.equals(
            "Burning Crusade zone cave route for the Classic Ghost Mushroom material.",
            zangarmarsh.dropDifficulty
        )
        assert.equals(
            "Although Zangarmarsh is TBC content, Ghost Mushroom itself is a Vanilla herb "
                .. "and still appears there in Retail.",
            zangarmarsh.tips[1]
        )
        assert.equals("Use this when Un'Goro has another farmer clearing the cave.", zangarmarsh.tips[2])
    end)

    it("includes sampled Classic coordinates from the supplied Retail Routes imports", function()
        local spots = load_material_farming_spots(true)

        assert.is_true(item_has_coord(spots.items[2770], 0.4391, 0.1401))
        assert.is_true(item_has_coord(spots.items[2771], 0.4687, 0.1045))
        assert.is_true(item_has_coord(spots.items[3858], 0.3896, 0.3440))
        assert.is_true(item_has_coord(spots.items[10620], 0.5093, 0.2243))
    end)

    it("keeps imported Classic mining routes as separate spot entries", function()
        local spots = load_material_farming_spots(true)
        local expectations = {
            { 2770, "classic-mining-copperDurotarRoutesMain-2770", 0.4391, 0.1401 },
            { 2770, "classic-mining-copperDurotarWitAlt-2770", 0.5401, 0.1143 },
            { 2771, "classic-mining-tinHillsbradRoutesMain-2771", 0.4687, 0.1045 },
            { 2771, "classic-mining-tinAshenvaleWitAlt-2771", 0.9355, 0.3717 },
            { 2771, "classic-mining-tinNorthernStranglethornAlt-2771", 0.3436, 0.2125 },
            { 2775, "classic-mining-tinHillsbradRoutesMain-2775", 0.4687, 0.1045 },
            { 2772, "classic-mining-ironFeralasRoutesMain-2772", 0.4376, 0.0890 },
            { 2772, "classic-mining-ironWesternPlaguelandsWitAlt-2772", 0.5533, 0.4767 },
            { 2776, "classic-mining-ironFeralasRoutesMain-2776", 0.4376, 0.0890 },
            { 3858, "classic-mining-mithrilBurningSteppesCompact-3858", 0.3896, 0.3440 },
            { 3858, "classic-mining-mithrilBurningSteppesCoverage-3858", 0.5726, 0.2841 },
            { 7911, "classic-mining-mithrilBurningSteppesCompact-7911", 0.3896, 0.3440 },
            { 7911, "classic-mining-thoriumWinterspringRoutesMain-7911", 0.5093, 0.2243 },
            { 10620, "classic-mining-thoriumWinterspringRoutesMain-10620", 0.5093, 0.2243 },
            { 10620, "classic-mining-thoriumSilithusWitAlt-10620", 0.3038, 0.1430 },
            { 10620, "classic-mining-thoriumWinterspringCoverage-10620", 0.2310, 0.4701 },
            { 2835, "classic-mining-copperDurotarRoutesMain-2835", 0.4391, 0.1401 },
            { 7912, "classic-mining-mithrilBurningSteppesCoverage-7912", 0.5726, 0.2841 },
            { 12365, "classic-mining-thoriumSilithusWitAlt-12365", 0.3038, 0.1430 },
        }

        for _, expected in ipairs(expectations) do
            local item_id, spot_id, x, y = expected[1], expected[2], expected[3], expected[4]
            local item = spots.items[item_id]
            local message = "missing imported Classic mining spot: " .. spot_id
            assert.is_true(item_has_spot(item, spot_id), message)
            assert.is_true(spot_has_coord(item, spot_id, x, y), message)
        end
    end)

    it("includes researched Wrath farming data while leaving catalog-only Wrath materials pending", function()
        local spots = load_material_farming_spots(true)
        local researched_wrath_ids = {
            33470, 33568, 34052, 34054, 34055, 34057, 34736, 36781, 36782, 36783, 36784, 36901, 36903, 36904,
            36905, 36906, 36907, 36908, 36909, 36910, 36912, 36917, 36918, 36920,
            36921, 36923, 36924, 36926, 36927, 36929, 36930, 36932, 36933, 37700,
            37701, 37702, 37703, 37704, 37705, 37921, 38557, 38558, 38561, 39970, 41800,
            41801, 41802, 41803, 41805, 41806, 41807, 41808, 41809, 41810, 41812,
            41813, 42780, 43009, 43010, 43011, 43012, 43013, 43102, 43299, 43501, 44128, 44703,
            45087, 45909, 45912, 47556, 49908, 251762,
        }
        local composed_wrath_ids = {
            33447, 35622, 35623, 35624, 35625, 35627, 36860, 36913, 36916, 36919,
            36922, 36925, 36928, 36931, 36934, 37663, 38425, 39343, 39681, 39682,
            39683, 40077, 41163, 41285, 41334,
            41510, 41511, 41593, 41594, 41595, 42225, 43109, 43126, 43127,
        }

        for _, item_id in ipairs(researched_wrath_ids) do
            local message = "missing researched Wrath farming entry: " .. tostring(item_id)
            assert.is_table(spots.items[item_id], message)
            assert.equals("researched", spots.items[item_id].researchStatus, message)
            assert.is_nil(spots.missingItems[item_id], message)
        end

        for _, item_id in ipairs(composed_wrath_ids) do
            local message = "catalog-only Wrath item should stay pending: " .. tostring(item_id)
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

    it("keeps the Crystallized Shadow farm explicit about its kill target", function()
        local spots = load_material_farming_spots(true)
        local farm = find_spot(
            spots.items[37703],
            "crystallized-shadow-dragonblight-frostmourne-cavern"
        )

        assert.is_table(farm)
        assert.equals("Deathbringer Revenant", farm.targetName)
        assert.equals("kill", farm.targetType)
        assert.equals("Frostmourne Cavern (entrance near 74, 24)", farm.location)
        assert.matches("Kill Deathbringer Revenants", farm.tips[2], 1, true)
    end)

    it("explains the direct and herbalism methods for Crystallized Life", function()
        local spots = load_material_farming_spots(true)
        local item = spots.items[37704]
        local direct = find_spot(item, "crystallized-life-howling-fjord-thornvine-creepers")
        local herbalism = find_spot(item, "wrath-adders-tongue-sholazar-large-main-route")

        assert.equals("Thornvine Creeper", direct.targetName)
        assert.equals("kill", direct.targetType)
        assert.equals(0, direct.sortOrder)
        assert.matches("Harvest Adder's Tongue nodes", herbalism.farmAction, 1, true)
    end)

    it("identifies Borean Man O' War as a coastal fishing-school farm", function()
        local spots = load_material_farming_spots(true)
        local farm = find_spot(spots.items[41805], "wrath-borean-man-o-war-borean-tundra-inland-waters")

        assert.equals("fish", farm.targetType)
        assert.matches("Borean Man O' War Schools", farm.targetName, 1, true)
        assert.matches("coastal waters", farm.location, 1, true)
        assert.equals("coastal-fishing-pool-loop", farm.routeType)
        assert.equals(0.3275, farm.coords[1].x)
        assert.equals(0.6916, farm.coords[1].y)
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

        assert.is_true(item_has_coord(spots.items[37921], 0.5850, 0.2578))
        assert.is_true(item_has_coord(spots.items[43010], 0.470, 0.550))
        assert.is_true(item_has_coord(spots.items[43012], 0.430, 0.740))
        assert.is_true(item_has_coord(spots.items[43501], 0.590, 0.280))
        assert.is_true(item_has_coord(spots.items[41812], 0.528, 0.586))
    end)

    it("includes sampled Wrath route coordinates from retail route import strings", function()
        local spots = load_material_farming_spots(true)

        assert.is_true(item_has_coord(spots.items[36909], 0.2265, 0.1390))
        assert.is_true(item_has_coord(spots.items[36912], 0.3585, 0.1733))
        assert.is_true(item_has_coord(spots.items[36903], 0.2622, 0.5119))
        assert.is_true(item_has_coord(spots.items[36906], 0.4780, 0.4310))
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
            76140, 76141, 76142, 79010, 79011, 79101, 83064, 89112, 92426,
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
            161344, 168645, 168646, 168649, 168650, 174327, 174328, 174353,
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
            187662, 187704, 187707,
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
            197746, 197747, 197748, 197749, 200113, 200224, 201399, 201404,
            201405, 201883, 201991,
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
            25707, 25708, 29539, 29547, 29548, 23676, 27668, 27669, 27677, 24477,
            33823, 33824, 24476, 24478, 24479, 21882, 23572, 30183, 32428, 34664,
            32227, 32228, 32229, 32230, 32231, 32249, 242691, 24368, 24401, 25433,
            25719, 25744, 25802, 29425, 29426, 29460, 29739, 29740, 30809, 30810,
            24245, 24246, 24291, 24449, 25416, 25463, 32388, 32620, 32897,
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

    it("catalogs the complete Burning Crusade auctionable intermediate-material recipes", function()
        local data = load_data("Data/FarmingItems.lua", "FarmingItems")
        local itemsByID = {}
        local composedCount = 0
        for _, item in ipairs(data.items or {}) do
            itemsByID[item.itemID] = item
            if item.expansion == "burningCrusade" and type(item.components) == "table" and #item.components > 0 then
                composedCount = composedCount + 1
                assert.is_number(item.outputQuantity)
                assert.is_true(item.outputQuantity > 0)
                assert_non_empty_string(item.recipeSourceLabel)
            end
        end

        assert.equals(40, composedCount)

        local expectedRecipeComponents = {
            [20816] = { { 2840, 2 } },
            [21842] = { { 21840, 3 }, { 22445, 2 } },
            [21845] = { { 21842, 1 }, { 21886, 1 }, { 21885, 1 } },
            [23448] = { { 23445, 3 }, { 23447, 2 } },
            [23571] = { { 22452, 1 }, { 21885, 1 }, { 22451, 1 }, { 21884, 1 }, { 22457, 1 } },
            [23781] = { { 22574, 1 }, { 22573, 2 } },
            [23787] = { { 23448, 2 } },
            [23793] = { { 21887, 5 } },
            [24271] = { { 21842, 1 }, { 22457, 1 }, { 21884, 1 } },
            [25867] = { { 23079, 3 }, { 23107, 3 }, { 23112, 3 }, { 22452, 2 }, { 21885, 2 } },
            [31079] = { { 24243, 4 }, { 22452, 1 } },
            [32423] = { { 21885, 1 }, { 23781, 2 }, { 21877, 2 } },
            [35128] = { { 23449, 3 }, { 23573, 1 } },
        }

        for itemID, expectedComponents in pairs(expectedRecipeComponents) do
            local item = itemsByID[itemID]
            assert.is_table(item, "missing composed Burning Crusade item " .. tostring(itemID))
            assert.equals(#expectedComponents, #item.components)
            for index, expected in ipairs(expectedComponents) do
                assert.equals(expected[1], item.components[index].itemID)
                assert.equals(expected[2], item.components[index].quantity)
            end
        end

        assert.equals(4, itemsByID[23781].outputQuantity)
        assert.equals(10, itemsByID[32423].outputQuantity)
        assert.equals("world-drop", itemsByID[35128].recipeSource)
        assert.equals("Sunwell Plateau world-drop recipe", itemsByID[35128].recipeSourceLabel)
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

    it("retains complete published Burning Crusade mob and fishing-school pin sets", function()
        local data = load_material_farming_spots()
        local moteOfFire = find_spot(data.items[22574], "mote-fire-hellfire-throne-of-kiljaeden")
        local cobra = data.items[29539]
        local twilight = find_spot(cobra, "cobra-scales-nagrand-twilight-serpents")
        local coilskar = find_spot(cobra, "cobra-scales-shadowmoon-coilskar-cobras")
        local shadow = find_spot(cobra, "cobra-scales-shadowmoon-shadow-serpents")

        assert.equals(51, #twilight.coords)
        assert.equals(28, #coilskar.coords)
        assert.equals(69, #shadow.coords)
        assert.equals("Incandescent Fel Spark", moteOfFire.coords[1].targetName)
        assert.equals("kill", moteOfFire.coords[1].targetType)

        local brackish = find_spot(data.items[27422], "bc-fish-27422-pool-route")
        assert.equals(45, #brackish.coords)

        local clam = data.items[24476]
        local bloodscale = find_spot(clam, "jaggal-clam-bloodscale")
        assert.is_true(#bloodscale.coords > 100)
        assert.is_true(spot_has_coord(clam, "jaggal-clam-bloodscale", 0.262, 0.444))
        assert.is_true(spot_has_coord(clam, "jaggal-clam-bloodscale", 0.262, 0.446))
    end)

    it("models Jaggal Clams, their contents, and dynamic Olemba Lumber routes", function()
        local data = load_material_farming_spots()

        assert.equals("Openable", data.items[24476].category)
        assert.equals("Pearl", data.items[24478].category)
        assert.equals("Pearl", data.items[24479].category)
        assert.is_true(item_has_spot(data.items[24476], "jaggal-clam-steamvault"))
        assert.is_true(item_has_spot(data.items[24478], "jaggal-clam-hydra"))

        local lumber = data.items[242691]
        assert.equals("Housing Lumber", lumber.category)
        assert.equals(9, #lumber.spots)
        assert.equals("dynamic-lumber-route", find_spot(lumber, "olemba-lumber-skettis").routeType)
        assert.is_true(item_has_spot(lumber, "olemba-lumber-netherstorm-midrealm"))
        assert.is_true(item_has_spot(lumber, "olemba-lumber-bloodmyst"))
    end)

    it("records all current Outland housing recipes and links their farmed reagents", function()
        local data, ns = load_material_farming_spots()
        local housing = ns.BurningCrusadeHousing

        assert.is_table(housing)
        assert.equals(20, #housing.recipes)
        assert.equals("https://www.wowhead.com/guide/player-housing/crafting-decor-items", housing.sourceUrl)
        assert.equals(20, #data.items[242691].housingUses)

        local found_lamppost = false
        for _, use in ipairs(data.items[32230].housingUses or {}) do
            if use.outputItemID == 258201 and use.quantity == 2 then
                found_lamppost = true
            end
        end
        assert.is_true(found_lamppost)

        local found_scarecrow = false
        for _, use in ipairs(data.items[29539].housingUses or {}) do
            if use.outputItemID == 258191 and use.quantity == 4 then
                found_scarecrow = true
            end
        end
        assert.is_true(found_scarecrow)
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

    it("keeps the supplied Retail Burning Crusade mining routes ordered and fully cited", function()
        local data = load_material_farming_spots()
        local expected_routes = {
            { 23424, "fel-iron-hellfire-peninsula-main-route", 41, 0.2958, 0.3750, 0.2409, 0.4143 },
            { 23424, "fel-iron-terokkar-forest-alternative-route", 98, 0.5523, 0.3915, 0.5692, 0.4413 },
            { 23425, "adamantite-nagrand-main-route", 26, 0.2598, 0.2167, 0.2422, 0.3476 },
            { 23425, "adamantite-terokkar-forest-alternative-route", 98, 0.5523, 0.3915, 0.5692, 0.4413 },
            { 23426, "khorium-nagrand-main-route", 35, 0.2721, 0.1883, 0.2777, 0.2457 },
            { 23426, "khorium-terokkar-forest-alternative-route", 98, 0.5523, 0.3915, 0.5692, 0.4413 },
            { 23426, "khorium-nagrand-broad-adamantite-alternative-route", 26, 0.2598, 0.2167, 0.2422, 0.3476 },
            { 23427, "eternium-terokkar-forest-main-route", 98, 0.5523, 0.3915, 0.5692, 0.4413 },
            { 23427, "eternium-nagrand-adamantite-alternative-route", 26, 0.2598, 0.2167, 0.2422, 0.3476 },
            { 23427, "eternium-hellfire-peninsula-alternative-route", 41, 0.2958, 0.3750, 0.2409, 0.4143 },
        }

        for _, expected in ipairs(expected_routes) do
            local item = data.items[expected[1]]
            local spot = find_spot(item, expected[2])
            local context = "missing or invalid route " .. expected[2]
            assert.is_true(item.isRoute, context)
            assert.is_table(spot, context)
            assert.equals(expected[3], #spot.coords, context)
            assert.equals(expected[4], spot.coords[1].x, context)
            assert.equals(expected[5], spot.coords[1].y, context)
            assert.equals(expected[6], spot.coords[#spot.coords].x, context)
            assert.equals(expected[7], spot.coords[#spot.coords].y, context)
            assert.is_true(#spot.tips >= 4, context)
            assert.is_true(#spot.sourceUrls >= 2, context)
        end

        assert.is_nil(data.items[2770].isRoute)
    end)

    it("models Wrath specialty farms, recursive profession intermediates, and Northrend housing decor", function()
        local data, ns = load_material_farming_spots(true)
        local farming = ns.FarmingItems
        local items = {}
        for _, item in ipairs(farming.items or {}) do
            items[item.itemID] = item
        end

        assert.equals("Openable", data.items[36781].category)
        assert.equals("Pearl", data.items[36784].category)
        assert.is_true(item_has_spot(data.items[36781], "darkwater-clam-winterfin-retreat"))
        assert.is_true(item_has_spot(data.items[45909], "giant-darkwater-clam-wintergrasp"))
        assert.is_true(item_has_coord(data.items[45912], 0.660, 0.510))
        assert.is_true(item_has_spot(data.items[45087], "runed-orb-ulduar"))
        assert.is_true(item_has_spot(data.items[49908], "primordial-saronite-icecrown-citadel"))

        local intermediate_ids = {
            35622, 35623, 35624, 35625, 35627, 36860, 36913, 36916, 37663,
            38425, 39681, 39682, 39683, 40077, 41163, 41285, 41334, 41510, 41511,
            41593, 41594, 41595, 43126, 43127,
        }
        for _, item_id in ipairs(intermediate_ids) do
            local message = "missing expandable Wrath intermediate: " .. tostring(item_id)
            assert.is_table(items[item_id], message)
            assert.is_table(items[item_id].components, message)
            assert.is_true(#items[item_id].components > 0, message)
        end

        assert.same({
            { itemID = 41163, quantity = 3 },
            { itemID = 36860, quantity = 1 },
            { itemID = 35624, quantity = 1 },
            { itemID = 35627, quantity = 1 },
        }, items[37663].components)
        assert.same({ { itemID = 41511, quantity = 1 }, { itemID = 36860, quantity = 2 } }, items[41595].components)

        local housing_ids = {
            257040, 257094, 257101, 257693, 258203, 258204, 258205, 258206,
            258207, 258208, 258209, 258210, 258211, 258212, 258213, 258298,
            264676, 264707, 264708, 264710, 264711,
        }
        for _, item_id in ipairs(housing_ids) do
            local message = "missing expandable Wrath housing recipe: " .. tostring(item_id)
            assert.is_table(items[item_id], message)
            assert.equals("wrath", items[item_id].expansion, message)
            assert.equals("Housing Decor", items[item_id].tag, message)
            assert.is_true(#items[item_id].components >= 2, message)
        end

        assert.same({
            { itemID = 251762, quantity = 8 },
            { itemID = 37663, quantity = 5 },
            { itemID = 45087, quantity = 2 },
            { itemID = 35624, quantity = 2 },
        }, items[257040].components)
        assert.same({
            { itemID = 251762, quantity = 10 },
            { itemID = 36916, quantity = 6 },
            { itemID = 42225, quantity = 2 },
        }, items[258211].components)

        local housing = ns.WrathHousing
        assert.is_table(housing)
        assert.equals(21, #housing.recipes)
        assert.equals(21, #data.items[251762].housingUses)
        assert.equals("Patch 12.1.5 PTR reductions published 2026-09-15", housing.quantityVersion)

        local runed_orb_uses = data.items[45087].housingUses or {}
        assert.equals(2, #runed_orb_uses)
        assert.equals(2, runed_orb_uses[1].quantity)
        assert.equals(2, runed_orb_uses[2].quantity)
    end)

    it("keeps every supplied Retail Wrath ore route separate, ordered, and visible to the map window", function()
        local data, ns = load_material_farming_spots(true)
        local chunk, err = loadfile("UI/CraftingFarmingWindow.lua")
        assert(chunk, err)
        chunk("General-Gold-Tracker", ns)

        local expected_routes = {
            { 36909, "wrath-cobalt-howling-fjord-main-route", 117, 29, 0.2265, 0.1390, 0.2334, 0.1993 },
            { 36909, "wrath-cobalt-grizzly-hills-alternative-route", 116, 35, 0.1490, 0.3900, 0.1400, 0.4490 },
            { 36912, "wrath-saronite-sholazar-basin-main-route", 119, 38, 0.4735, 0.2034, 0.5314, 0.2094 },
            { 36912, "wrath-saronite-icecrown-alternative-route", 118, 20, 0.7541, 0.6421, 0.6893, 0.4612 },
            { 36912, "wrath-saronite-wintergrasp-alternative-route", 123, 53, 0.3585, 0.1733, 0.3189, 0.1399 },
            { 36910, "wrath-titanium-icecrown-main-route", 118, 14, 0.5618, 0.4450, 0.5046, 0.4530 },
            { 36910, "wrath-titanium-storm-peaks-alternative-route", 120, 11, 0.4252, 0.3281, 0.2892, 0.4359 },
        }

        local expected_option_counts = {
            [36909] = 2,
            [36912] = 3,
            [36910] = 2,
        }

        for item_id, expected_count in pairs(expected_option_counts) do
            local item = data.items[item_id]
            local context = "Wrath mining item " .. tostring(item_id)
            assert.is_table(item, context)
            assert.is_true(item.isRoute, context)
            assert.equals(expected_count, #(item.spots or {}), context)

            local options = ns.GoldTracker:BuildMaterialFarmingMapOptions(item_id)
            assert.equals(expected_count, #options, context)
            for _, option in ipairs(options) do
                assert.equals(1, option.spotCount, context)
                assert.is_true(#(option.pins or {}) > 0, context)
                local pin = option.pins[1]
                assert.is_true(pin.isRoute, context)
                assert.equals(option.id, pin.routeID, context)
                assert.is_table(pin.tips, context)
                assert.is_true(#pin.tips >= 4, context)
                assert.is_table(pin.sourceUrls, context)
                assert.is_true(#pin.sourceUrls >= 2, context)
            end
        end

        for _, expected in ipairs(expected_routes) do
            local spot = find_spot(data.items[expected[1]], expected[2])
            local context = "missing or invalid Wrath route " .. expected[2]
            assert.is_table(spot, context)
            assert.equals(expected[3], spot.mapID, context)
            assert.equals(expected[4], #spot.coords, context)
            assert.equals(expected[5], spot.coords[1].x, context)
            assert.equals(expected[6], spot.coords[1].y, context)
            assert.equals(expected[7], spot.coords[#spot.coords].x, context)
            assert.equals(expected[8], spot.coords[#spot.coords].y, context)
        end

        assert.is_true(data.items[36910].rareNode)
        assert.equals("Saronite Ore", data.items[36910].sharedSpawn)
    end)

    it("keeps every supplied Retail Wrath herb route separate, ordered, cited, and visible to the map window", function()
        local data, ns = load_material_farming_spots(true)
        local chunk, err = loadfile("UI/CraftingFarmingWindow.lua")
        assert(chunk, err)
        chunk("General-Gold-Tracker", ns)

        local expected_routes = {
            { 36901, "wrath-goldclover-grizzly-hills-main-route", 116, 19, 0.1236, 0.3201, 0.1095, 0.4624 },
            { 36901, "wrath-goldclover-howling-fjord-alternative-route", 117, 36, 0.5850, 0.2578, 0.5512, 0.1967 },
            { 36901, "wrath-goldclover-borean-tundra-alternative-route", 114, 23, 0.3421, 0.6103, 0.3380, 0.6576 },
            { 36904, "wrath-tiger-lily-grizzly-hills-main-route", 116, 17, 0.0924, 0.3723, 0.1425, 0.5112 },
            { 36904, "wrath-tiger-lily-howling-fjord-alternative-route", 117, 26, 0.5982, 0.3242, 0.5609, 0.3483 },
            { 36907, "wrath-talandras-rose-zuldrak-main-route", 121, 28, 0.3530, 0.6340, 0.3520, 0.6940 },
            { 36907, "wrath-talandras-rose-zuldrak-compact-alternative-route", 121, 10, 0.2946, 0.4046, 0.2901, 0.4699 },
            { 36903, "wrath-adders-tongue-sholazar-large-main-route", 119, 24, 0.2622, 0.5119, 0.2260, 0.5910 },
            { 36903, "wrath-adders-tongue-sholazar-compact-alternative-route", 119, 16, 0.2865, 0.5144, 0.3098, 0.5544 },
            { 36905, "wrath-lichbloom-storm-peaks-main-route", 120, 30, 0.3750, 0.5980, 0.3590, 0.6409 },
            { 36905, "wrath-lichbloom-icecrown-alternative-route", 118, 26, 0.3720, 0.4640, 0.3905, 0.5260 },
            { 36906, "wrath-icethorn-icecrown-main-route", 118, 17, 0.4780, 0.4310, 0.4730, 0.5420 },
            { 36906, "wrath-icethorn-storm-peaks-alternative-route", 120, 20, 0.2730, 0.5900, 0.3070, 0.6450 },
            { 39970, "wrath-fire-leaf-scalding-pools-main-route", 114, 21, 0.5881, 0.2867, 0.6030, 0.3080 },
            { 39970, "wrath-fire-leaf-borean-wide-alternative-route", 114, 23, 0.3421, 0.6103, 0.3380, 0.6576 },
            { 37921, "wrath-deadnettle-howling-fjord-main-route", 117, 36, 0.5850, 0.2578, 0.5512, 0.1967 },
            { 37921, "wrath-deadnettle-borean-tundra-alternative-route", 114, 23, 0.3421, 0.6103, 0.3380, 0.6576 },
            { 36908, "wrath-frost-lotus-storm-peaks-main-route", 120, 30, 0.3750, 0.5980, 0.3590, 0.6409 },
            { 36908, "wrath-frost-lotus-icecrown-alternative-route", 118, 17, 0.4780, 0.4310, 0.4730, 0.5420 },
        }

        local expected_option_counts = {
            [36901] = 3,
            [36903] = 2,
            [36904] = 2,
            [36905] = 2,
            [36906] = 2,
            [36907] = 2,
            [36908] = 2,
            [37921] = 2,
            [39970] = 2,
        }

        for item_id, expected_count in pairs(expected_option_counts) do
            local item = data.items[item_id]
            local context = "Wrath herbalism item " .. tostring(item_id)
            assert.is_table(item, context)
            assert.is_true(item.isRoute, context)
            assert.equals(expected_count, #(item.spots or {}), context)

            local options = ns.GoldTracker:BuildMaterialFarmingMapOptions(item_id)
            assert.equals(expected_count, #options, context)
            assert.equals(item.spots[1].id, options[1].id, context .. " should default to its main route")
            for _, option in ipairs(options) do
                assert.equals(1, option.spotCount, context)
                assert.is_true(#(option.pins or {}) > 0, context)
                local pin = option.pins[1]
                assert.is_true(pin.isRoute, context)
                assert.equals(option.id, pin.routeID, context)
                assert.is_table(pin.tips, context)
                assert.is_true(#pin.tips >= 3, context)
                assert.is_table(pin.sourceUrls, context)
                assert.is_true(#pin.sourceUrls >= 2, context)
            end
        end

        for _, expected in ipairs(expected_routes) do
            local spot = find_spot(data.items[expected[1]], expected[2])
            local context = "missing or invalid Wrath herb route " .. expected[2]
            assert.is_table(spot, context)
            assert.equals(expected[3], spot.mapID, context)
            assert.equals(expected[4], #spot.coords, context)
            assert.equals(expected[5], spot.coords[1].x, context)
            assert.equals(expected[6], spot.coords[1].y, context)
            assert.equals(expected[7], spot.coords[#spot.coords].x, context)
            assert.equals(expected[8], spot.coords[#spot.coords].y, context)
        end

        assert.matches("Wintergrasp", table.concat(data.items[36908].spots[1].tips, " "), 1, true)
        assert.equals("adapted-source-herb-loop", data.items[37921].spots[1].routeType)
        assert.equals("firethorn-herbalism-loop", data.items[39970].spots[1].routeType)
    end)

    it("keeps every supplied Retail Burning Crusade herb route separate, ordered, and cited", function()
        local data = load_material_farming_spots(true)
        local expected_routes = {
            { 22710, "bloodthistle-eversong-outer-settlements-main", 94, 9, 0.36, 0.48, 0.39, 0.38 },
            { 22710, "bloodthistle-eversong-central-settlements-alternative", 94, 7, 0.53, 0.44, 0.59, 0.41 },
            { 22785, "felweed-blades-edge-supplied-main", 105, 15, 0.72, 0.39, 0.81, 0.30 },
            { 22785, "felweed-nagrand-supplied-alternative", 107, 11, 0.82, 0.26, 0.84, 0.29 },
            { 22786, "dreaming-glory-blades-edge-supplied-main", 105, 15, 0.72, 0.39, 0.81, 0.30 },
            { 22786, "dreaming-glory-nagrand-supplied-alternative", 107, 11, 0.82, 0.25, 0.84, 0.29 },
            { 22787, "ragveil-zangarmarsh-supplied-main", 102, 32, 0.72, 0.38, 0.32, 0.31 },
            { 22787, "ragveil-terokkar-supplied-alternative", 108, 14, 0.16, 0.25, 0.22, 0.25 },
            { 22788, "flame-cap-zangarmarsh-supplied-main", 102, 13, 0.46, 0.18, 0.21, 0.22 },
            { 22788, "flame-cap-zangarmarsh-supplied-alternative", 102, 11, 0.72, 0.38, 0.68, 0.30 },
            { 22789, "terocone-terokkar-supplied-main", 108, 14, 0.16, 0.25, 0.22, 0.25 },
            { 22789, "terocone-shadowmoon-supplied-alternative", 104, 19, 0.32, 0.29, 0.43, 0.20 },
            { 22790, "ancient-lichen-slave-pens-supplied-main", 260, 11, 0.55, 0.18, 0.34, 0.32 },
            { 22790, "ancient-lichen-underbog-supplied-alternative", 262, 11, 0.62, 0.16, 0.70, 0.30 },
            { 22791, "netherbloom-netherstorm-supplied-main", 109, 24, 0.28, 0.36, 0.26, 0.33 },
            { 22791, "netherbloom-netherstorm-supplied-alternative", 109, 14, 0.70, 0.18, 0.45, 0.25 },
            { 22792, "nightmare-vine-shadowmoon-supplied-main", 104, 19, 0.32, 0.29, 0.43, 0.20 },
            { 22792, "nightmare-vine-blades-edge-supplied-alternative", 105, 13, 0.72, 0.39, 0.18, 0.39 },
            { 22793, "mana-thistle-blades-edge-supplied-main", 105, 14, 0.68, 0.27, 0.60, 0.44 },
            { 22793, "mana-thistle-skettis-supplied-alternative", 108, 7, 0.65, 0.61, 0.68, 0.57 },
            { 22794, "fel-lotus-netherstorm-supplied-main", 109, 24, 0.28, 0.36, 0.26, 0.33 },
            { 22794, "fel-lotus-shadowmoon-supplied-alternative", 104, 19, 0.32, 0.29, 0.43, 0.20 },
        }

        assert.is_nil(data.missingItems[22710])
        for _, expected in ipairs(expected_routes) do
            local item = data.items[expected[1]]
            local spot = find_spot(item, expected[2])
            local context = "missing or invalid herb route " .. expected[2]
            assert.is_table(spot, context)
            assert.is_true(spot.isRoute, context)
            assert.equals(expected[3], spot.mapID, context)
            assert.equals(expected[4], #spot.coords, context)
            assert.equals(expected[5], spot.coords[1].x, context)
            assert.equals(expected[6], spot.coords[1].y, context)
            assert.equals(expected[7], spot.coords[#spot.coords].x, context)
            assert.equals(expected[8], spot.coords[#spot.coords].y, context)
            assert.is_true(#spot.tips >= 3, context)
            assert.is_true(#spot.sourceUrls >= 2, context)
            local has_route_variant = spot.location:find("^Main %- ") ~= nil
                or spot.location:find("^Alternative %- ") ~= nil
            assert.is_true(has_route_variant, context)
        end
    end)

    it("exposes every supplied Classic ore option with route-specific tips and sources", function()
        local spots, ns = load_material_farming_spots(true)
        local chunk, err = loadfile("UI/CraftingFarmingWindow.lua")
        assert(chunk, err)
        chunk("General-Gold-Tracker", ns)

        local expected_option_counts = {
            [2770] = 2,
            [2771] = 3,
            [2772] = 2,
            [2775] = 2,
            [2776] = 2,
            [3858] = 2,
            [7911] = 2,
            [10620] = 3,
            [11370] = 1,
            [18562] = 1,
            [22202] = 1,
            [22203] = 1,
        }

        for item_id, expected_count in pairs(expected_option_counts) do
            local item = spots.items[item_id]
            local context = "Classic mining item " .. tostring(item_id)
            assert.is_table(item, context)
            assert.equals(expected_count, #(item.spots or {}), context)

            local options = ns.GoldTracker:BuildMaterialFarmingMapOptions(item_id)
            assert.equals(expected_count, #options, context)
            for _, option in ipairs(options) do
                assert.equals(1, option.spotCount, context)
                assert.is_true(#(option.pins or {}) > 0, context)
                local pin = option.pins[1]
                assert.is_table(pin.tips, context)
                assert.is_true(#pin.tips >= 3, context)
                assert.is_table(pin.sourceUrls, context)
                assert.is_true(#pin.sourceUrls >= 2, context)
                assert.equals(option.id, pin.routeID, context)
            end
        end

        for _, item_id in ipairs({ 2770, 2771, 2772, 2775, 2776, 3858, 7911, 10620 }) do
            for _, option in ipairs(ns.GoldTracker:BuildMaterialFarmingMapOptions(item_id)) do
                assert.is_true(option.pins[1].isRoute, "outdoor Classic mining option should draw a route")
            end
        end
        for _, item_id in ipairs({ 11370, 18562, 22202, 22203 }) do
            assert.is_false(ns.GoldTracker:BuildMaterialFarmingMapOptions(item_id)[1].pins[1].isRoute)
        end

        local exhaustive = find_spot(spots.items[10620], "classic-mining-thoriumWinterspringCoverage-10620")
        assert.equals(56, #exhaustive.coords)
        assert.equals(0.4163, exhaustive.coords[6].x)
        assert.equals(0.5050, exhaustive.coords[6].y)
        assert.equals(0.4453, exhaustive.coords[19].x)
        assert.equals(0.4454, exhaustive.coords[20].x)
    end)

    it("keeps other supplied Burning Crusade route samples", function()
        local data = load_material_farming_spots()
        assert.is_true(spot_has_coord(data.items[22785], "felweed-nagrand-aoa-dreaming-glory-loop", 0.2768, 0.6189))
        assert.is_true(item_has_coord(data.items[25700], 0.5296, 0.2984))
    end)

    it("keeps imported Burning Crusade herbalism routes as separate spot entries", function()
        local data = load_material_farming_spots()
        local expected_routes = {
            { 22787, "ragveil-zangarmarsh-golden-routes-main", 0.8646, 0.3365 },
            { 22787, "ragveil-zangarmarsh-golden-routes-alt", 0.8696, 0.2712 },
            { 22787, "ragveil-zangarmarsh-wit-mixed-herb-route", 0.1843, 0.1767 },
            { 22788, "flame-cap-zangarmarsh-ragveil-main-route", 0.8646, 0.3365 },
            { 22788, "flame-cap-zangarmarsh-ragveil-alt-route", 0.8696, 0.2712 },
            { 22788, "flame-cap-zangarmarsh-wit-mixed-herb-route", 0.1843, 0.1767 },
            { 22790, "ancient-lichen-zangarmarsh-wit-bog-lord-proxy", 0.1843, 0.1767 },
            { 22789, "terocone-terokkar-golden-routes-compact-alt", 0.6012, 0.2340 },
            { 22789, "terocone-terokkar-searchforloot-main", 0.3208, 0.3763 },
            { 22793, "mana-thistle-terokkar-searchforloot-main", 0.3208, 0.3763 },
            { 22794, "fel-lotus-terokkar-searchforloot-main", 0.3208, 0.3763 },
            { 22791, "netherbloom-netherstorm-xscarlife-main", 0.3628, 0.1901 },
            { 22791, "netherbloom-netherstorm-wit-mixed-alt", 0.4609, 0.1430 },
            { 22793, "mana-thistle-netherstorm-wit-mixed-alt", 0.4609, 0.1430 },
            { 22794, "fel-lotus-netherstorm-wit-mixed-alt", 0.4609, 0.1430 },
            { 22792, "nightmare-vine-shadowmoon-golden-routes-main", 0.2491, 0.2984 },
            { 22794, "fel-lotus-shadowmoon-nightmare-vine-import", 0.2491, 0.2984 },
            { 22792, "nightmare-vine-blades-edge-wit-alt", 0.6510, 0.2064 },
        }

        for _, expected in ipairs(expected_routes) do
            local item_id, spot_id, x, y = expected[1], expected[2], expected[3], expected[4]
            local item = data.items[item_id]
            local message = "missing route spot: " .. tostring(item_id) .. " / " .. spot_id
            assert.is_true(item_has_spot(item, spot_id), message)
            assert.is_true(spot_has_coord(item, spot_id, x, y), message)
        end
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

    it("loads every defined WIT Gathering row with decoded routes and hidden yields", function()
        local spots, ns = load_material_farming_spots(true)
        local wit = ns.WITGatheringData

        assert.is_table(wit)
        assert.equals("v4.3.1", wit.sourceVersion)
        assert.equals(415, wit.farmCount)
        assert.equals(317, wit.routeCount)
        assert.equals(10872, wit.pointCount)
        assert.equals(wit.farmCount, #wit.farms)

        local route_count = 0
        local point_count = 0
        local records = {}
        for _, farm in ipairs(wit.farms) do
            assert_non_empty_string(farm.recordID)
            assert.is_nil(records[farm.recordID])
            records[farm.recordID] = farm
            assert_non_empty_string(farm.category)
            assert.is_number(farm.recordedSeconds)
            assert.is_true(farm.recordedSeconds > 0)
            assert.is_table(farm.results)
            assert.is_table(farm.routes)
            for _, result in ipairs(farm.results) do
                assert.is_number(result.itemID)
                assert.is_true(result.itemID > 0)
                assert.is_number(result.quantity)
                assert.is_true(result.quantity >= 0)
            end
            for _, route in ipairs(farm.routes) do
                route_count = route_count + 1
                point_count = point_count + #route.coords
                assert_non_empty_string(route.name)
                assert.is_number(route.mapID)
                assert.is_true(route.mapID > 0)
                assert.is_true(#route.coords > 0)
            end
        end
        assert.equals(wit.routeCount, route_count)
        assert.equals(wit.pointCount, point_count)

        local copper = records["Mining:CopperOre:1"]
        assert.is_table(copper)
        assert.equals(2770, copper.itemID)
        assert.equals(540, copper.results[1].quantity)
        assert.equals(0.5080, copper.routes[1].coords[1].x)
        assert.equals(0.5080, copper.routes[1].coords[1].y)

        local copper_wit_spots = 0
        for _, spot in ipairs(spots.items[2770].spots) do
            if type(spot.dropdownLabel) == "string" and spot.dropdownLabel:find("^WIT: ") then
                copper_wit_spots = copper_wit_spots + 1
                assert.is_table(records[spot.witFarmRecordID])
            end
        end
        assert.is_true(copper_wit_spots > 1)
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

describe("Data/WITDrops", function()
    it("matches the generated WIT category counters", function()
        local data = load_data("Data/WITDrops.lua", "WITDropsData")

        assert_non_empty_string(data.sourceVersion)
        assert_non_empty_string(data.sourceURL)
        assert.is_table(data.categories)
        assert.is_table(data.categoryCounts)

        local total = 0
        for _, category in ipairs({ "transmogs", "openWorldInstances", "mounts", "toys", "pets", "raidPets" }) do
            local rows = data.categories[category]
            assert.is_table(rows)
            assert.equals(data.categoryCounts[category], #rows)
            assert.is_true(#rows > 0)
            total = total + #rows
            for _, row in ipairs(rows) do
                assert_non_empty_string(row.recordID)
                assert_non_empty_string(row.farmID)
                assert_non_empty_string(row.farmName)
                assert.is_number(row.itemID)
                assert.is_true(row.itemID > 0)
                assert.is_number(row.quantity)
                assert.is_number(row.contentID)
                assert_non_empty_string(row.expansion)
                assert_non_empty_string(row.expansionLabel)
                assert_non_empty_string(row.locationLabel)
                if category == "raidPets" then
                    assert.is_number(row.petID)
                    assert_non_empty_string(row.itemLink)
                end
            end
        end

        assert.equals(data.itemSourceCount, total)
        assert.equals(9049, data.categoryCounts.transmogs)
        assert.equals(147, data.categoryCounts.openWorldInstances)
        assert.equals(7, data.categoryCounts.mounts)
        assert.equals(7, data.categoryCounts.toys)
        assert.equals(179, data.categoryCounts.pets)
        assert.equals(91, data.categoryCounts.raidPets)
    end)
end)

describe("Data/Farms", function()
    it("contains the generated, runtime-independent WIT farm index", function()
        local data = load_data("Data/Farms.lua", "FarmCatalog")

        assert.equals(2, data.dataVersion)
        assert.equals("v4.3.1", data.sourceVersion)
        assert.is_false(data.runtimeDependency)
        assert.equals(504, data.farmCount)
        assert.equals(11151, data.targetCount)
        assert.equals(4966, data.uniqueItemCount)
        assert.equals(414, data.sourceCounts.gathering)
        assert.equals(90, data.sourceCounts.drops)
        assert.equals(data.farmCount, #data.farms)
        assert.is_table(data.byID)
        assert.is_table(data.indexes)

        local seen = {}
        local target_count = 0
        for position, farm in ipairs(data.farms) do
            assert_non_empty_string(farm.id)
            assert.is_nil(seen[farm.id])
            seen[farm.id] = true
            assert.equals(position, data.byID[farm.id])
            assert.equals("wit", farm.provider)
            assert_non_empty_string(farm.providerKey)
            assert_non_empty_string(farm.providerFarmID)
            assert_non_empty_string(farm.activity)
            assert_non_empty_string(farm.sourceCategory)
            assert_non_empty_string(farm.sourcePath)
            assert_non_empty_string(farm.name)
            assert_non_empty_string(farm.expansion)
            assert.is_number(farm.recordedSeconds)
            assert.is_true(farm.recordedSeconds > 0)
            assert.is_table(farm.mapIDs)
            assert.is_table(farm.targets)
            target_count = target_count + #farm.targets
            for _, target in ipairs(farm.targets) do
                assert.is_number(target.itemID)
                assert.is_true(target.itemID > 0)
                assert.is_number(target.quantity)
            end
        end
        assert.equals(data.targetCount, target_count)

        local copper_position = data.byID["wit:gathering:mining:copperore"]
        assert.is_number(copper_position)
        assert.equals(2770, data.farms[copper_position].primaryItemID)
        assert.is_true(#data.indexes.byItemID[2770] > 0)

        local dark_iron_position = data.byID["wit:gathering:mining:darkironore"]
        assert.is_number(dark_iron_position)
        assert.same({
            { itemID = 11370, quantity = 303 },
            { itemID = 11382, quantity = 3 },
        }, data.farms[dark_iron_position].targets)

        local scarlet_position = data.byID["wit:drops:transmogs:scarletmonastayold"]
        assert.is_number(scarlet_position)
        assert.equals("transmog", data.farms[scarlet_position].activity)
        assert.equals("WITDropsData", data.farms[scarlet_position].sourceDataset)
        assert.equals("instances", data.farms[scarlet_position].sourceCategory)
        assert.equals("Instances", data.farms[scarlet_position].sourcePath)

        local ragefire_position = data.byID["wit:drops:openworldinstances:ragefire"]
        assert.is_number(ragefire_position)
        assert.equals("openWorldInstances", data.farms[ragefire_position].sourceCategory)
        assert.equals("Open World > Instances", data.farms[ragefire_position].sourcePath)
        assert.equals(213, data.farms[ragefire_position].mapIDs[1])
        assert.equals(20, #data.indexes.bySourceCategory.openWorldInstances)
        assert.equals(70, #data.indexes.bySourceCategory.instances)
    end)
end)
