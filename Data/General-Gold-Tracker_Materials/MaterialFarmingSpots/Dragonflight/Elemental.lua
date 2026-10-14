local _, NS = ...
local Register = NS.RegisterMaterialFarmingSpot

local function C(x, y, label)
    return { x = x, y = y, label = label }
end

local function ItemUrl(itemID)
    return "https://www.wowhead.com/item=" .. tostring(itemID)
end

local LIFE_VAULT_EARTH_ROUTE = {
    id = "dragonflight-waking-shores-life-vault-earth-elementals",
    source = "Wowhead Rousing Essence guide, wow-professions Rousing Earth guide, Wowhead Raging Elemental and Crushing Elemental NPC map pins",
    sourceUrls = {
        "https://www.wowhead.com/guide/professions/farming-rousing-and-awakened-essences",
        "https://www.wow-professions.com/farming/rousing-earth-farming",
        "https://www.wowhead.com/npc=194523/raging-elemental",
        "https://www.wowhead.com/npc=194517/crushing-elemental",
    },
    mapName = "The Waking Shores",
    location = "Life Vault Ruins elemental packs",
    routeType = "elemental-mob-farm",
    density = "High",
    dropDifficulty = "Easy to moderate. Dense earth elementals with Rousing Earth as the target drop.",
    tips = {
        "Loop between Raging Elemental and Crushing Elemental pin clusters.",
        "Stay mobile through the ruins and reset the loop when the central packs are exhausted.",
        "Mining nearby Hardened nodes can add extra Rousing Earth while waiting on respawns.",
    },
    coords = {
        C(0.492, 0.326, "Raging Elemental west cluster"),
        C(0.504, 0.314, "Raging Elemental center"),
        C(0.528, 0.314, "Raging Elemental east cluster"),
        C(0.462, 0.366, "Crushing Elemental west edge"),
        C(0.502, 0.308, "Crushing Elemental north ruins"),
        C(0.542, 0.322, "Crushing Elemental east edge"),
    },
    confidence = "high",
}

local RUBY_LIFESHRINE_FIRE_ROUTE = {
    id = "dragonflight-waking-shores-ruby-lifeshrine-ashen-sparks",
    source = "Wowhead Rousing Essence guide, wow-professions Rousing Fire guide, Wowhead Ashen Spark NPC map pins",
    sourceUrls = {
        "https://www.wowhead.com/guide/professions/farming-rousing-and-awakened-essences",
        "https://www.wow-professions.com/farming/rousing-fire-farming",
        "https://www.wowhead.com/npc=190528/ashen-spark",
    },
    mapName = "The Waking Shores",
    location = "Northeast of Ruby Life Pools around the Ashen Spark lava pit",
    routeType = "elemental-mob-farm",
    density = "Medium",
    dropDifficulty = "Easy localized fire route with small but quick Ashen Spark clusters.",
    tips = {
        "Use this as a compact Rousing Fire loop when the Serene Spa route is crowded.",
        "Clear all Ashen Sparks around the lava pit before extending into nearby lava mobs.",
        "Pair with Molten mining nodes in Waking Shores when dual gathering.",
    },
    coords = {
        C(0.684, 0.640, "Ashen Spark west lava edge"),
        C(0.686, 0.634, "Ashen Spark north edge"),
        C(0.692, 0.646, "Ashen Spark center"),
        C(0.696, 0.644, "Ashen Spark east edge"),
        C(0.698, 0.656, "Ashen Spark south edge"),
    },
    confidence = "high",
}

local SERENE_SPA_FIRE_ROUTE = {
    id = "dragonflight-thaldraszus-serene-spa-flame-boilers",
    source = "Wowhead Rousing Essence guide and Wowhead Flame Boiler NPC map pins",
    sourceUrls = {
        "https://www.wowhead.com/guide/professions/farming-rousing-and-awakened-essences",
        "https://www.wowhead.com/npc=196171/flame-boiler",
    },
    mapName = "Thaldraszus",
    location = "Serene Spa north of Valdrakken",
    routeType = "elemental-mob-farm",
    density = "Medium",
    dropDifficulty = "Easy localized fire route; good alternate spot to Waking Shores.",
    tips = {
        "Farm Flame Boiler pins around the spa pools.",
        "Use the central 39.2, 47.2 waypoint as the reset point after sweeping north and south.",
        "Watch for other farmers because the cluster is compact.",
    },
    coords = {
        C(0.378, 0.476, "Flame Boiler west pool"),
        C(0.380, 0.470, "Flame Boiler north-west pool"),
        C(0.392, 0.472, "Flame Boiler central spa"),
        C(0.396, 0.478, "Flame Boiler south pool"),
        C(0.398, 0.468, "Flame Boiler east pool"),
    },
    confidence = "high",
}

local OHNAHRAN_SPRINGS_AIR_FROST_ROUTE = {
    id = "dragonflight-ohnahran-springs-air-frost-elementals",
    source = "Wowhead Rousing Essence guide, Rousing Frost item comments, Sulfuric Rager and Hissing Springsoul NPC map pins",
    sourceUrls = {
        "https://www.wowhead.com/guide/professions/farming-rousing-and-awakened-essences",
        "https://www.wowhead.com/item=190328/rousing-frost",
        "https://www.wowhead.com/npc=191682/sulfuric-rager",
        "https://www.wowhead.com/npc=191712/hissing-springsoul",
    },
    mapName = "Ohn'ahran Plains",
    location = "Ohn'ahran Springs and Forkriver Crossing elemental pools",
    routeType = "elemental-mob-farm",
    density = "High",
    dropDifficulty = "Good mixed farm. Sulfuric Ragers target Air while Hissing Springsouls add Frost.",
    tips = {
        "Use the /way 78,78 comment cluster as the center of the route.",
        "Sweep the northern and southern pools because Sulfuric Ragers and Hissing Springsouls overlap.",
        "This is best when both Air and Frost prices are useful.",
    },
    coords = {
        C(0.774, 0.788, "Sulfuric Rager west pool"),
        C(0.780, 0.774, "Sulfuric Rager north path"),
        C(0.790, 0.772, "Sulfuric Rager center"),
        C(0.788, 0.784, "Hissing Springsoul overlap"),
        C(0.794, 0.796, "Hissing Springsoul east pool"),
        C(0.802, 0.756, "Hissing Springsoul southeast pool"),
    },
    confidence = "high",
}

local WAKING_SHORES_STEAM_REAVER_FROST_ROUTE = {
    id = "dragonflight-waking-shores-obsidian-bulwark-steam-reavers",
    source = "Wowhead Rousing Essence guide, Rousing Frost item comments, Wowhead Steam Reaver NPC map pins",
    sourceUrls = {
        "https://www.wowhead.com/guide/professions/farming-rousing-and-awakened-essences",
        "https://www.wowhead.com/item=190328/rousing-frost",
        "https://www.wowhead.com/npc=190700/steam-reaver",
    },
    mapName = "The Waking Shores",
    location = "East of the Obsidian Bulwark",
    routeType = "elemental-mob-farm",
    density = "Medium",
    dropDifficulty = "Compact Rousing Frost alternative with fewer mixed elemental drops than Ohn'ahran Springs.",
    tips = {
        "Farm the Steam Reaver pins around 49.2, 59.4.",
        "The cluster is small, so extend only if respawns fall behind your kill speed.",
        "Use this route when Ohn'ahran Springs is crowded.",
    },
    coords = {
        C(0.474, 0.592, "Steam Reaver west"),
        C(0.480, 0.612, "Steam Reaver south-west"),
        C(0.492, 0.594, "Steam Reaver center"),
        C(0.502, 0.594, "Steam Reaver east"),
        C(0.502, 0.596, "Steam Reaver southeast"),
    },
    confidence = "high",
}

local AZURE_SPAN_FROST_SCALE_ROUTE = {
    id = "dragonflight-azure-span-frost-borer-route",
    source = "Artisans of Azeroth Rousing Frost route, wow-professions Rousing Frost guide, Wowhead Vicious Ice Borer NPC map pins",
    sourceUrls = {
        "https://artisansofazeroth.com/where-to-farm-rousing-frost-wow-dragonflight-gold-making/",
        "https://www.wow-professions.com/farming/rousing-frost-farming",
        "https://www.wowhead.com/npc=186392/vicious-ice-borer",
    },
    mapName = "The Azure Span",
    location = "Northern Azure Span frost borer and scale route",
    routeType = "elemental-and-skinning-farm",
    density = "Medium",
    dropDifficulty = "Good Rousing Frost side route; also useful for skinners when scale values are high.",
    tips = {
        "Follow the Artisans route around 60.31, 20.82, 64.91, 24.31, and 58.63, 23.27.",
        "Kill Vicious Ice Borers along the route and skin when possible.",
        "Use this as a value route rather than the pure fastest Frost route.",
    },
    coords = {
        C(0.6031, 0.2082, "Northern frost route west"),
        C(0.6491, 0.2431, "Northern frost route east"),
        C(0.5863, 0.2327, "Northern frost route return"),
        C(0.458, 0.498, "Vicious Ice Borer west pins"),
        C(0.468, 0.504, "Vicious Ice Borer center pins"),
        C(0.488, 0.532, "Vicious Ice Borer south pins"),
    },
    confidence = "medium",
}

local function RegisterElemental(itemID, itemName, professions, spots, summary)
    Register({
        itemID = itemID,
        itemName = itemName,
        expansion = "dragonflight",
        professions = professions,
        category = "Elemental",
        sourceUrls = { ItemUrl(itemID) },
        summary = summary,
        spots = spots,
    })
end

RegisterElemental(190315, "Rousing Earth", { "mining", "herbalism", "alchemy" }, {
    LIFE_VAULT_EARTH_ROUTE,
}, "Dragonflight elemental material from earth elementals and Hardened mining nodes.")

RegisterElemental(190320, "Rousing Fire", { "mining", "herbalism", "alchemy" }, {
    RUBY_LIFESHRINE_FIRE_ROUTE,
    SERENE_SPA_FIRE_ROUTE,
}, "Dragonflight elemental material from fire elementals and Molten mining nodes.")

RegisterElemental(190326, "Rousing Air", { "mining", "herbalism", "alchemy" }, {
    OHNAHRAN_SPRINGS_AIR_FROST_ROUTE,
}, "Dragonflight elemental material from air elementals and Windswept gathering nodes.")

RegisterElemental(190327, "Awakened Air", { "mining", "herbalism", "skinning" }, {
    OHNAHRAN_SPRINGS_AIR_FROST_ROUTE,
}, "Awakened Air is tied to the same Air farms as Rousing Air; combine Rousing Air when direct Awakened drops do not appear.")

RegisterElemental(190328, "Rousing Frost", { "mining", "herbalism", "alchemy" }, {
    OHNAHRAN_SPRINGS_AIR_FROST_ROUTE,
    WAKING_SHORES_STEAM_REAVER_FROST_ROUTE,
    AZURE_SPAN_FROST_SCALE_ROUTE,
}, "Dragonflight elemental material from frost elementals, Frigid gathering nodes, and selected fishing side sources.")

RegisterElemental(190329, "Awakened Frost", { "mining", "herbalism", "alchemy" }, {
    OHNAHRAN_SPRINGS_AIR_FROST_ROUTE,
    WAKING_SHORES_STEAM_REAVER_FROST_ROUTE,
    AZURE_SPAN_FROST_SCALE_ROUTE,
}, "Awakened Frost is tied to the same Frost farms as Rousing Frost; combine Rousing Frost when direct Awakened drops do not appear.")
