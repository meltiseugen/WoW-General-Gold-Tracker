local _, NS = ...
local Register = NS.RegisterMaterialFarmingSpot

local function C(x, y, label)
    return { x = x, y = y, label = label }
end

local function ItemUrl(itemID)
    return "https://www.wowhead.com/item=" .. tostring(itemID)
end

Register({
    itemID = 37703,
    itemName = "Crystallized Shadow",
    expansion = "wrath",
    professions = { "alchemy", "enchanting" },
    category = "Elemental",
    sourceUrls = {
        ItemUrl(37703),
        "https://www.wow-professions.com/farming/crystallized-shadow-farming",
        "https://www.wowhead.com/item=37703/crystallized-shadow",
    },
    summary = "Crystallized Shadow is best targeted from Deathbringer Revenants in Frostmourne Cavern.",
    spots = {
        {
            id = "crystallized-shadow-dragonblight-frostmourne-cavern",
            source = "wow-professions Crystallized Shadow guide and Wowhead Crystallized Shadow comments",
            sourceUrls = {
                "https://www.wow-professions.com/farming/crystallized-shadow-farming",
                "https://www.wowhead.com/item=37703/crystallized-shadow",
            },
            mapName = "Dragonblight",
            location = "Frostmourne Cavern Deathbringer Revenants",
            routeType = "open-world-cave-loop",
            density = "High",
            dropDifficulty = "Excellent targeted farm because the cave keeps a small number of revenants active.",
            tips = {
                "Anchor at /way 74 24 and stay in the first leg of the cave.",
                "Do not overextend deeper if the front cave respawns are keeping pace.",
            },
            coords = {
                C(0.740, 0.240, "Frostmourne Cavern entrance"),
                C(0.752, 0.236, "First revenant pocket"),
                C(0.732, 0.258, "West cave pocket"),
                C(0.766, 0.260, "East cave pocket"),
            },
            confidence = "high",
        },
    },
})

local DISENCHANT_GEAR_SPOTS = {
    {
        id = "wrath-enchanting-icecrown-pit-of-saron-trash-disenchant",
        source = "Wowhead enchanting material pages and Wrath dungeon drop/disenchant route practice",
        sourceUrls = {
            ItemUrl(34052),
            ItemUrl(34054),
            ItemUrl(34055),
            "https://www.wowhead.com/zone=4813/pit-of-saron",
        },
        mapName = "Icecrown",
        location = "Pit of Saron entrance and trash reset path",
        routeType = "disenchant-gear-farm",
        density = "Medium",
        dropDifficulty = "Indirect material farm. The input is Northrend uncommon and rare gear, then disenchanting.",
        tips = {
            "Use this when you can quickly clear disenchantable trash drops.",
            "Dust usually comes from uncommon armor, essences from uncommon weapons, and shards from rare gear.",
            "Compare vendor, auction, and disenchant values before committing the drops.",
        },
        coords = {
            C(0.535, 0.894, "Pit of Saron entrance"),
            C(0.545, 0.874, "Entrance trash staging"),
        },
        confidence = "medium",
    },
    {
        id = "wrath-enchanting-icecrown-onslaught-green-farm",
        source = "Wowhead enchanting material pages and Icecrown humanoid farming route research",
        sourceUrls = {
            ItemUrl(34052),
            ItemUrl(34054),
            ItemUrl(34055),
            "https://www.wowhead.com/zone=210/icecrown",
        },
        mapName = "Icecrown",
        location = "Onslaught Harbor and central Icecrown humanoid green-drop loops",
        routeType = "disenchant-gear-farm",
        density = "Medium",
        dropDifficulty = "Indirect and RNG-heavy. Works best when greens are worth more disenchanted than sold.",
        tips = {
            "Farm dense humanoid packs for Northrend greens, then disenchant eligible items.",
            "Use this as a flexible outdoor option when dungeon resets are capped or inconvenient.",
        },
        coords = {
            C(0.750, 0.160, "Onslaught Harbor packs"),
            C(0.500, 0.340, "Central Icecrown pack checks"),
        },
        confidence = "medium",
    },
}

local function RegisterEnchantingMaterial(itemID, itemName, summary)
    Register({
        itemID = itemID,
        itemName = itemName,
        expansion = "wrath",
        professions = { "enchanting" },
        category = "Enchanting",
        sourceUrls = { ItemUrl(itemID) },
        summary = summary,
        spots = DISENCHANT_GEAR_SPOTS,
    })
end

RegisterEnchantingMaterial(34054, "Infinite Dust", "Main Wrath dust from disenchanting Northrend uncommon gear, especially armor.")
RegisterEnchantingMaterial(34052, "Dream Shard", "Wrath shard from disenchanting Northrend rare-quality gear and some crafted/disenchant routes.")
RegisterEnchantingMaterial(34055, "Greater Cosmic Essence", "Wrath essence from disenchanting higher-level Northrend uncommon gear, especially weapons.")
