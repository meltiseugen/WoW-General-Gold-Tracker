local _, NS = ...
local Register = NS.RegisterMaterialFarmingSpot

local function C(x, y, label)
    return { x = x, y = y, label = label }
end

local function ItemUrl(itemID)
    return "https://www.wowhead.com/item=" .. tostring(itemID)
end

local HALLOWFALL_VENERATION_LEATHER_ROUTE = {
    id = "tww-skinning-hallowfall-veneration-grounds-leather-route",
    source = "Method Stormcharged Leather farm, Wowhead comments, and Hallowfall beast NPC map pins",
    sourceUrls = {
        "https://www.method.gg/guides/stormcharged-leather-farms-in-the-war-within",
        "https://www.wowhead.com/item=212664/stormcharged-leather",
        "https://www.wowhead.com/npc=221470/feral-sharpclaw",
        "https://www.wowhead.com/npc=223191/light-bathed-eagle",
    },
    mapName = "Hallowfall",
    location = "Western Veneration Grounds beast packs",
    routeType = "skinning-loop",
    density = "High",
    dropDifficulty = "Strong raw leather route with Shalehorn, lynx, and eagle packs; competition can thin "
        .. "hyperspawn density.",
    tips = {
        "Method gives /way Hallowfall 26.79 55.20 for this leather farm.",
        "A Wowhead Stormcharged Leather comment points to the same west Veneration Grounds area around 26.67, 52.51.",
        "Pull between the Feral Sharpclaw and Light-Bathed Eagle clusters, then skin before the route spreads too far.",
    },
    coords = {
        C(0.2679, 0.5520, "Method Veneration Grounds waypoint"),
        C(0.2667, 0.5251, "Wowhead leather comment waypoint"),
        C(0.236, 0.580, "Feral Sharpclaw west pack"),
        C(0.262, 0.514, "Feral Sharpclaw north pack"),
        C(0.258, 0.532, "Light-Bathed Eagle center"),
        C(0.282, 0.562, "Feral Sharpclaw east pack"),
    },
    confidence = "high",
}

local ISLE_DORN_RAMBLESHIRE_SHALEMAW_ROUTE = {
    id = "tww-skinning-isle-of-dorn-rambleshire-shalemaw-route",
    source = "Wowhead Stormcharged Leather comments, Stormtop Shalemaw NPC map pins, and supplemental skinning guides",
    sourceUrls = {
        "https://www.wowhead.com/item=212664/stormcharged-leather",
        "https://www.wowhead.com/npc=212364/stormtop-shalemaw",
        "https://www.wowhead.com/npc=212368/stormtop-shalemaw-young",
        "https://powerupgaming.co.uk/2024/09/07/how-to-farm-stormcharged-leather-in-wow-the-war-within/",
    },
    mapName = "Isle of Dorn",
    location = "Rambleshire Stormtop Shalemaw packs",
    routeType = "skinning-loop",
    density = "Medium to high",
    dropDifficulty = "Good alternate leather route. Elite-wolf variants can be better in groups, while "
        .. "Shalemaw pins support steadier solo loops.",
    tips = {
        "A Wowhead comment reports Stormtop Shalemaw around 57.85, 33.17.",
        "Loop the north and east edges of Rambleshire where adult and young Shalemaw pins overlap.",
        "Use this if the Hallowfall Veneration Grounds farm is crowded.",
    },
    coords = {
        C(0.5785, 0.3317, "Reported Rambleshire leather waypoint"),
        C(0.570, 0.334, "Stormtop Shalemaw west pack"),
        C(0.578, 0.272, "Stormtop Shalemaw north pack"),
        C(0.592, 0.256, "Stormtop Shalemaw northern ridge"),
        C(0.606, 0.314, "Stormtop Shalemaw east pack"),
        C(0.616, 0.300, "Shalemaw east return"),
    },
    confidence = "medium",
}

local HALLOWFALL_SHORE_CHITIN_ROUTE = {
    id = "tww-skinning-hallowfall-strange-shore-crawler-chitin-route",
    source = "Wowhead Gloom Chitin comments and Strange Shore Crawler NPC map pins",
    sourceUrls = {
        "https://www.wowhead.com/item=212667/gloom-chitin",
        "https://www.wowhead.com/npc=219365/strange-shore-crawler",
    },
    mapName = "Hallowfall",
    location = "Mereldar shore Strange Shore Crawler packs",
    routeType = "skinning-loop",
    density = "Medium",
    dropDifficulty = "Targeted chitin route from crawler packs; kill speed and respawn competition decide the pace.",
    tips = {
        "A Wowhead Gloom Chitin comment points to Strange Shore Crawlers near Mereldar around /way 36,46.",
        "Follow the shoreline instead of riding inland, because the NPC pins cluster near the water.",
        "Use this when Gloom Chitin is the main target rather than Stormcharged Leather.",
    },
    coords = {
        C(0.360, 0.460, "Mereldar shore comment waypoint"),
        C(0.344, 0.422, "Strange Shore Crawler northwest pack"),
        C(0.356, 0.460, "Crawler central pack"),
        C(0.368, 0.464, "Crawler shoreline pack"),
        C(0.374, 0.492, "Crawler southern shore"),
        C(0.384, 0.464, "Crawler east return"),
    },
    confidence = "high",
}

local HALLOWFALL_BELEDARS_CHITIN_ROUTE = {
    id = "tww-skinning-hallowfall-beledars-bounty-jawcrawler-route",
    source = "Wowhead skinning overview, Gloom Chitin comments, and Gluttonous Jawcrawler NPC map pins",
    sourceUrls = {
        "https://www.wowhead.com/guide/the-war-within/professions/skinning-overview",
        "https://www.wowhead.com/item=212667/gloom-chitin",
        "https://www.wowhead.com/npc=223931/gluttonous-jawcrawler",
    },
    mapName = "Hallowfall",
    location = "Beledar's Bounty Gluttonous Jawcrawler packs",
    routeType = "skinning-loop",
    density = "Localized",
    dropDifficulty = "Useful compact chitin loop, especially while also checking nearby herb and Rich Soil spawns.",
    tips = {
        "Wowhead's skinning overview calls out Beledar's Bounty jawcrawlers as a good Gloom Chitin source.",
        "The same area supports nearby herb loops, so it can be used as a mixed profession detour.",
        "Keep the pull tight around the farm edge because the pins are compact.",
    },
    coords = {
        C(0.460, 0.644, "Gluttonous Jawcrawler west pack"),
        C(0.464, 0.648, "Jawcrawler farm edge"),
        C(0.468, 0.634, "Central Jawcrawler pin"),
        C(0.480, 0.620, "North Jawcrawler check"),
        C(0.486, 0.632, "East Jawcrawler pack"),
        C(0.488, 0.620, "Jawcrawler return"),
    },
    confidence = "high",
}

local ISLE_DORN_ELITE_WOLF_HIDE_ROUTE = {
    id = "tww-skinning-isle-of-dorn-cinderbrew-elite-wolf-hide-route",
    source = "Method Stormcharged Leather farm, Wowhead Thunderous Hide comments, and Isle of Dorn beast pins",
    sourceUrls = {
        "https://www.method.gg/guides/stormcharged-leather-farms-in-the-war-within",
        "https://www.wowhead.com/item=212670/thunderous-hide",
        "https://www.wowhead.com/item=212673/thunderous-hide",
        "https://www.wowhead.com/item=218337/honed-bone-shards",
    },
    mapName = "Isle of Dorn",
    location = "North Isle of Dorn near Cinderbrew Meadery, elite Tempest Wolf packs",
    routeType = "elite-skinning-loop",
    density = "High in groups",
    dropDifficulty = "Best used as a group pull. Thunderous Hide and Honed Bone Shards are rare skinning "
        .. "side gathers from the same elite wolf loop.",
    tips = {
        "Method gives /way Isle of Dorn 73.88 32.64 for the elite wolf farm.",
        "Kill Tempest Wolf, Cyclonecrier Alpha, and Rustcloud Runt packs, then skin before bodies despawn.",
        "Use this route when rare-hide value beats safer solo leather loops.",
    },
    coords = {
        C(0.7388, 0.3264, "Method elite wolf waypoint"),
        C(0.730, 0.408, "Matriarch Charfuria rare-hide pin"),
        C(0.732, 0.384, "Tephratennae rare-hide pin"),
        C(0.742, 0.274, "Shallowshell rare-hide pin"),
        C(0.570, 0.226, "Twice-Stinger rare-hide pin"),
        C(0.586, 0.368, "Warphorn rare-hide pin"),
    },
    confidence = "medium",
}

local ISLE_DORN_BOULDER_SPRINGS_BONE_ROUTE = {
    id = "tww-skinning-isle-of-dorn-boulder-springs-bone-route",
    source = "Wowhead Honed Bone Shards comments and Boulder Springs shalehorn farming reports",
    sourceUrls = {
        "https://www.wowhead.com/item=218337/honed-bone-shards",
        "https://www.wowhead.com/item=212672/thunderous-hide",
    },
    mapName = "Isle of Dorn",
    location = "Boulder Springs shalehorn packs",
    routeType = "species-skinning-loop",
    density = "Medium",
    dropDifficulty = "Targeted side-gather route for horned beasts; bone shards are uncommon and should be "
        .. "treated as a bonus while farming leather.",
    tips = {
        "A Wowhead comment reports Boulder Springs shalehorns at 58.33, 61.46 for Honed Bone Shards.",
        "Stay near the shalehorn packs instead of widening into unrelated beast types.",
        "Rare hides can appear along with leather, so skin every eligible beast.",
    },
    coords = {
        C(0.5833, 0.6146, "Boulder Springs shalehorn comment waypoint"),
        C(0.570, 0.604, "West shalehorn pull"),
        C(0.586, 0.628, "Central Boulder Springs pack"),
        C(0.600, 0.616, "East shalehorn return"),
    },
    confidence = "medium",
}

local function RegisterStormchargedLeather(itemID, qualityRank)
    Register({
        itemID = itemID,
        itemName = "Stormcharged Leather",
        expansion = "warWithin",
        professions = { "skinning", "leatherworking" },
        category = "Leather",
        qualityRank = qualityRank,
        sourceUrls = { ItemUrl(itemID) },
        summary = "War Within leather from skinnable Khaz Algar beasts; Veneration Grounds and Rambleshire "
            .. "are coordinate-backed farm loops.",
        spots = {
            HALLOWFALL_VENERATION_LEATHER_ROUTE,
            ISLE_DORN_RAMBLESHIRE_SHALEMAW_ROUTE,
        },
    })
end

RegisterStormchargedLeather(212664, 1)
RegisterStormchargedLeather(212665, 2)
RegisterStormchargedLeather(212666, 3)

Register({
    itemID = 212667,
    itemName = "Gloom Chitin",
    expansion = "warWithin",
    professions = { "skinning", "leatherworking" },
    category = "Hide",
    sourceUrls = { ItemUrl(212667) },
    summary = "War Within chitin from skinnable crawlers and jawcrawlers, with shoreline and Beledar's "
        .. "Bounty spots backed by NPC pins.",
    spots = {
        HALLOWFALL_SHORE_CHITIN_ROUTE,
        HALLOWFALL_BELEDARS_CHITIN_ROUTE,
    },
})

local function RegisterThunderousHide(itemID, qualityRank)
    Register({
        itemID = itemID,
        itemName = "Thunderous Hide",
        expansion = "warWithin",
        professions = { "skinning", "leatherworking" },
        category = "Hide",
        qualityRank = qualityRank,
        sourceUrls = {
            ItemUrl(itemID),
            "https://www.method.gg/guides/stormcharged-leather-farms-in-the-war-within",
            "https://www.wowhead.com/guide/the-war-within/professions/skinning-overview",
        },
        summary = "Rare War Within skinning hide. Target elite Isle of Dorn wolf packs and horned beast "
            .. "loops while farming Stormcharged Leather.",
        spots = {
            ISLE_DORN_ELITE_WOLF_HIDE_ROUTE,
            ISLE_DORN_BOULDER_SPRINGS_BONE_ROUTE,
        },
    })
end

RegisterThunderousHide(212670, 1)
RegisterThunderousHide(212672, 2)
RegisterThunderousHide(212673, 3)

local function RegisterSunlessCarapace(itemID, qualityRank)
    Register({
        itemID = itemID,
        itemName = "Sunless Carapace",
        expansion = "warWithin",
        professions = { "skinning", "leatherworking" },
        category = "Carapace",
        qualityRank = qualityRank,
        sourceUrls = {
            ItemUrl(itemID),
            "https://www.wowhead.com/guide/the-war-within/professions/skinning-overview",
            "https://www.wowhead.com/item=218336/kaheti-swarm-chitin",
        },
        summary = "Rare chitinous War Within skinning material. Use crawler and jawcrawler loops, then "
            .. "treat carapace drops as rare side gathers.",
        spots = {
            HALLOWFALL_SHORE_CHITIN_ROUTE,
            HALLOWFALL_BELEDARS_CHITIN_ROUTE,
        },
    })
end

RegisterSunlessCarapace(212674, 1)
RegisterSunlessCarapace(212675, 2)
RegisterSunlessCarapace(212676, 3)

Register({
    itemID = 218336,
    itemName = "Kaheti Swarm Chitin",
    expansion = "warWithin",
    professions = { "skinning", "leatherworking" },
    category = "Chitin",
    sourceUrls = {
        ItemUrl(218336),
        "https://www.wowhead.com/guide/the-war-within/professions/skinning-overview",
        "https://www.wowhead.com/item=212676/sunless-carapace",
    },
    summary = "Chitinous War Within skinning material. Farm compact crawler and jawcrawler packs rather "
        .. "than broad beast routes.",
    spots = {
        HALLOWFALL_SHORE_CHITIN_ROUTE,
        HALLOWFALL_BELEDARS_CHITIN_ROUTE,
    },
})

Register({
    itemID = 218337,
    itemName = "Honed Bone Shards",
    expansion = "warWithin",
    professions = { "skinning", "leatherworking" },
    category = "Bone",
    sourceUrls = {
        ItemUrl(218337),
        "https://www.method.gg/guides/stormcharged-leather-farms-in-the-war-within",
        "https://www.wowhead.com/item=218337/honed-bone-shards",
    },
    summary = "Species-specific War Within skinning material from horned or bony beasts. Boulder Springs "
        .. "and the elite wolf route are the researched coordinate anchors.",
    spots = {
        ISLE_DORN_BOULDER_SPRINGS_BONE_ROUTE,
        ISLE_DORN_ELITE_WOLF_HIDE_ROUTE,
    },
})
