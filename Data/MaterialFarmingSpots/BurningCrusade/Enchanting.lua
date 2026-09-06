local _, NS = ...
local Register = NS.RegisterMaterialFarmingSpot

local function RegisterEnchanting(itemID, itemName, summary, spots)
    Register({
        itemID = itemID,
        itemName = itemName,
        expansion = "burningCrusade",
        professions = { "enchanting" },
        category = "Enchanting",
        researchStatus = "researched",
        sourceUrls = {
            "https://www.wowhead.com/item=" .. itemID,
            "https://www.wowhead.com/item=21877/netherweave-cloth",
        },
        summary = summary,
        spots = spots,
    })
end

local LEGION_HOLD = {
    { x = 0.222, y = 0.384, label = "North Legion Hold warlock" },
    { x = 0.224, y = 0.396, label = "Central Legion Hold warlock" },
    { x = 0.230, y = 0.384, label = "East Legion Hold warlock" },
    { x = 0.236, y = 0.400, label = "South Legion Hold warlock" },
}

local OUTLAND_INSTANCE_ENTRANCES = {
    { x = 0.395, y = 0.580, label = "Auchindoun entrance area" },
}

local HELLFIRE_CITADEL_ENTRANCES = {
    { x = 0.472, y = 0.530, label = "Hellfire Ramparts entrance approach" },
    { x = 0.460, y = 0.515, label = "Blood Furnace entrance approach" },
}

RegisterEnchanting(22445, "Arcane Dust", "Arcane Dust comes from disenchanting Burning Crusade uncommon gear. The practical farming route is cloth/green world-drop farms, then disenchant the greens.", {
    {
        id = "arcane-dust-shadowmoon-legion-hold-greens",
        source = "TBC disenchanting tables, Wowhead item comments, and Shadow Council Warlock map pins",
        sourceUrls = {
            "https://www.wowhead.com/item=22445/arcane-dust",
            "https://www.wowhead.com/npc=21302/shadow-council-warlock",
        },
        mapName = "Shadowmoon Valley",
        location = "Legion Hold cloth and green-item farm for disenchanting",
        routeType = "disenchanting-input-route",
        density = "Medium",
        dropDifficulty = "Indirect. Farm uncommon gear, then disenchant it.",
        tips = {
            "Use this only if Arcane Dust value beats selling the greens.",
            "Netherweave, Aldor drops, and raw gold improve the route.",
        },
        coords = LEGION_HOLD,
        confidence = "medium",
    },
})

RegisterEnchanting(22446, "Greater Planar Essence", "Greater Planar Essence comes from disenchanting Burning Crusade uncommon gear, especially weapons and higher-level greens.", {
    {
        id = "greater-planar-essence-shadowmoon-legion-hold-greens",
        source = "TBC disenchanting tables and coordinate-backed Legion Hold farming notes",
        sourceUrls = {
            "https://www.wowhead.com/item=22446/greater-planar-essence",
            "https://www.wowhead.com/npc=21302/shadow-council-warlock",
        },
        mapName = "Shadowmoon Valley",
        location = "Legion Hold green-item farm for disenchanting",
        routeType = "disenchanting-input-route",
        density = "Medium",
        dropDifficulty = "Indirect and RNG-heavy. Essence return depends on the green item mix.",
        tips = {
            "Track both Arcane Dust and Greater Planar Essence before disenchanting.",
            "Weapons are often better essence candidates than armor.",
        },
        coords = LEGION_HOLD,
        confidence = "medium",
    },
})

RegisterEnchanting(22447, "Lesser Planar Essence", "Lesser Planar Essence comes from disenchanting Burning Crusade uncommon gear and can be combined into Greater Planar Essence. Hellfire Ramparts and Blood Furnace are controlled early-Outland input farms.", {
    {
        id = "lesser-planar-essence-hellfire-dungeon-greens",
        source = "Retail Wowhead item comments and Hellfire Citadel dungeon route notes",
        sourceUrls = {
            "https://www.wowhead.com/item=22447/lesser-planar-essence",
            "https://www.wowhead.com/item=22445/arcane-dust",
            "https://www.wowhead.com/zone=3562/hellfire-ramparts",
            "https://www.wowhead.com/zone=3713/the-blood-furnace",
        },
        mapName = "Hellfire Peninsula",
        location = "Hellfire Citadel dungeon entrances for green-item disenchanting runs",
        routeType = "disenchanting-dungeon-route",
        density = "Instance-dependent",
        dropDifficulty = "Indirect. Farm uncommon gear in early Outland dungeons, then disenchant it.",
        tips = {
            "Use this when Lesser Planar Essence is worth more than vendoring or auctioning the greens.",
            "Ramparts and Blood Furnace are useful because they also produce Netherweave and Arcane Dust inputs.",
        },
        coords = HELLFIRE_CITADEL_ENTRANCES,
        confidence = "medium",
    },
})

RegisterEnchanting(22448, "Small Prismatic Shard", "Small Prismatic Shards come primarily from disenchanting Burning Crusade rare gear around the lower Outland item range, with occasional uncommon-item results.", {
    {
        id = "small-prismatic-shard-hellfire-dungeon-blues",
        source = "Retail Wowhead item comments and Hellfire Citadel dungeon route notes",
        sourceUrls = {
            "https://www.wowhead.com/item=22448/small-prismatic-shard",
            "https://www.wowhead.com/zone=3562/hellfire-ramparts",
            "https://www.wowhead.com/zone=3713/the-blood-furnace",
        },
        mapName = "Hellfire Peninsula",
        location = "Hellfire Ramparts and Blood Furnace rare-item disenchanting runs",
        routeType = "disenchanting-dungeon-route",
        density = "Instance-dependent",
        dropDifficulty = "Indirect. Boss and rare drops are deterministic enough for a route marker, but shard yield depends on disenchanting.",
        tips = {
            "Farm lower Outland normal dungeons when Small Prismatic Shards beat Large Prismatic Shards in value.",
            "Compare transmog, vendor, and disenchant value before destroying old rare drops.",
        },
        coords = HELLFIRE_CITADEL_ENTRANCES,
        confidence = "medium",
    },
})

RegisterEnchanting(22449, "Large Prismatic Shard", "Large Prismatic Shards come from disenchanting Burning Crusade rare gear. Normal and heroic dungeon runs are the most controlled source.", {
    {
        id = "large-prismatic-shard-auchindoun-runs",
        source = "TBC disenchanting tables and dungeon farming route notes",
        sourceUrls = {
            "https://www.wowhead.com/item=22449/large-prismatic-shard",
            "https://www.wowhead.com/zone=3792/mana-tombs",
        },
        mapName = "Terokkar Forest",
        location = "Auchindoun dungeon entrance area for rare-item disenchanting runs",
        routeType = "disenchanting-dungeon-route",
        density = "Instance-dependent",
        dropDifficulty = "Indirect. Requires rare drops, boss loot, or crafted rare inputs.",
        tips = {
            "Use dungeons when shards are worth more than selling or vendoring rare drops.",
            "Track lockouts and travel time before treating this as a farming route.",
        },
        coords = OUTLAND_INSTANCE_ENTRANCES,
        confidence = "medium",
    },
})

RegisterEnchanting(22450, "Void Crystal", "Void Crystals come from disenchanting Burning Crusade epic gear. They are best treated as raid/epic disenchant output, not an open-world material grind.", {
    {
        id = "void-crystal-karazhan-epic-disenchanting",
        source = "TBC disenchanting tables and raid disenchanting route notes",
        sourceUrls = {
            "https://www.wowhead.com/item=22450/void-crystal",
            "https://www.wowhead.com/zone=3457/karazhan",
        },
        mapName = "Deadwind Pass",
        location = "Karazhan entrance area for epic-item disenchanting runs",
        routeType = "disenchanting-raid-route",
        density = "Instance-dependent",
        dropDifficulty = "Indirect. Requires epic drops or crafted epic inputs.",
        tips = {
            "Use this as a reminder that Void Crystal farming is tied to epic disenchanting.",
            "Compare transmog/vendor value before disenchanting old raid epics.",
        },
        coords = {
            { x = 0.470, y = 0.750, label = "Karazhan entrance area" },
        },
        confidence = "medium",
    },
})
