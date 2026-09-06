local _, NS = ...
local Register = NS.RegisterMaterialFarmingSpot

local function C(x, y, label)
    return { x = x, y = y, label = label }
end

local function ItemUrl(itemID)
    return "https://www.wowhead.com/item=" .. tostring(itemID)
end

local VALSHARAH_ORE_ROUTE = {
    id = "legion-ore-valsharah-low-vertical-loop",
    source = "wow-professions Leystone/Felslate guides and Wowhead Legion Mining guide",
    sourceUrls = {
        "https://www.wow-professions.com/farming/leystone-ore-farming",
        "https://www.wow-professions.com/farming/felslate-farming",
        "https://www.wowhead.com/guide/legion-mining",
    },
    mapName = "Val'sharah",
    location = "Val'sharah low-vertical ore loop through roads, rivers, and cave mouths",
    routeType = "mining-loop",
    density = "Medium",
    dropDifficulty = "Good general Leystone route with occasional Felslate; easier terrain than Highmountain.",
    tips = {
        "Use Val'sharah as the relaxed node loop because the guide calls out its flatter route.",
        "Mine every Leystone node because Felslate is a rarer replacement spawn.",
        "Use Demonsteel Stirrups or Sky Golem-style mounted gathering support when available.",
    },
    coords = {
        C(0.442, 0.332, "Northern road node checks"),
        C(0.548, 0.364, "Temple road ridge"),
        C(0.620, 0.446, "Eastern river bend"),
        C(0.592, 0.584, "Southern road cut"),
        C(0.466, 0.638, "Western return"),
        C(0.354, 0.514, "Black Rook foothills"),
    },
    confidence = "high",
}

local SURAMAR_ORE_ROUTE = {
    id = "legion-ore-suramar-max-level-seam-loop",
    source = "wow-professions Felslate guide, Wowhead Legion Mining comments, and Artisans of Azeroth retail Suramar route string",
    sourceUrls = {
        "https://www.wow-professions.com/farming/felslate-farming",
        "https://www.wowhead.com/guide/legion-mining",
        "https://artisansofazeroth.com/legion-mining-leveling/",
    },
    mapName = "Suramar",
    location = "Suramar ridge, river, and cave seam checks",
    routeType = "mining-loop",
    density = "Medium",
    dropDifficulty = "Better Felslate chance than casual routes, but max-level Suramar mobs and phasing can slow laps.",
    tips = {
        "Use Suramar when Felslate is the main target and your character can handle level-scaled mobs.",
        "Check river and cave seam points; comments call out seams as the missing rank-up source for many miners.",
        "Skip dense city sections unless the ore price justifies the combat time.",
    },
    coords = {
        C(0.2121, 0.1693, "AoA Suramar northwest route pin"),
        C(0.2183, 0.2310, "AoA Suramar northern cave approach"),
        C(0.2390, 0.2768, "AoA Suramar north river seam"),
        C(0.2480, 0.3212, "AoA Suramar ridge bend"),
        C(0.280, 0.272, "Northwest river seam check"),
        C(0.3016, 0.3189, "AoA Suramar river bend"),
        C(0.360, 0.326, "Crimson Thicket ridge"),
        C(0.4040, 0.2940, "Guide cave waypoint"),
        C(0.430, 0.396, "Shal'Aran cave approach"),
        C(0.4220, 0.2990, "Behind-waterfall cave waypoint"),
        C(0.542, 0.448, "Central waterline"),
        C(0.646, 0.546, "Moon Guard ridge"),
        C(0.522, 0.654, "Falanaar return"),
    },
    confidence = "medium",
}

local AZSUNA_BASILISK_ROUTE = {
    id = "legion-leystone-azsuna-lagoon-basilisks",
    source = "wow-professions Leystone guide and Wowhead Lagoon Basilisk page",
    sourceUrls = {
        "https://www.wow-professions.com/farming/leystone-ore-farming",
        "https://www.wowhead.com/npc=89013/lagoon-basilisk",
    },
    mapName = "Azsuna",
    location = "Lagoon Basilisks near Azsuna waterlines",
    routeType = "mineable-creature-loop",
    density = "High when uncontested",
    dropDifficulty = "Strong Leystone-only farm; does not meaningfully supply Felslate.",
    tips = {
        "Kill and mine Lagoon Basilisks when you want Leystone without waiting on world node respawns.",
        "Do not use this route for Felslate unless a side source such as a shoulder enchant is the real target.",
        "Move on if another player is tagging but not looting, because unlooted corpses cannot be mined.",
    },
    coords = {
        C(0.454, 0.604, "Southwestern basilisk bank"),
        C(0.488, 0.628, "Central lagoon"),
        C(0.526, 0.608, "Eastern lagoon edge"),
        C(0.506, 0.566, "Northern return"),
    },
    confidence = "high",
}

local EMPYRIUM_BASILISK_ROUTE = {
    id = "legion-empyrium-antoran-felfang-basilisks",
    source = "wow-professions Empyrium guide and Wowhead Empyrium object pages",
    sourceUrls = {
        "https://www.wow-professions.com/farming/empyrium-ore-farming",
        "https://www.wowhead.com/object=272780/empyrium-seam",
        "https://www.wowhead.com/npc=126938/felfang-basilisk",
    },
    mapName = "Antoran Wastes",
    location = "Felfang Basilisks in the Antoran green lava fields",
    routeType = "mineable-creature-loop",
    density = "High",
    dropDifficulty = "Best targeted Empyrium farm, but the lava path is punishing and mobs are dense.",
    tips = {
        "Mine each Felfang Basilisk corpse; the guide reports multiple Empyrium per mined corpse.",
        "Jump rock to rock and avoid standing in the green lava.",
        "Use a tank spec or anti-daze barding because Argus mob density is high.",
    },
    coords = {
        C(0.594, 0.498, "Northwest lava rock"),
        C(0.632, 0.532, "Central basilisk path"),
        C(0.680, 0.560, "Eastern lava edge"),
        C(0.646, 0.620, "Southern rock return"),
        C(0.588, 0.604, "Western rock return"),
    },
    confidence = "high",
}

local EMPYRIUM_KROKUUN_ROUTE = {
    id = "legion-empyrium-krokuun-nathraxas-node-loop",
    source = "wow-professions Empyrium guide, Wowhead Empyrium Seam object page, and Artisans of Azeroth retail Krokuun route string",
    sourceUrls = {
        "https://www.wow-professions.com/farming/empyrium-ore-farming",
        "https://www.wowhead.com/object=272780/empyrium-seam",
        "https://artisansofazeroth.com/legion-herbalism-leveling/",
    },
    mapName = "Krokuun",
    location = "Krokuun Empyrium node route, skipping the heaviest Nath'Raxas pulls when needed",
    routeType = "mining-loop",
    density = "Medium",
    dropDifficulty = "Good backup to basilisk mining, but combat is hard to avoid.",
    tips = {
        "Use Feign Death, stealth, or tank spec if available because the guide notes heavy mob pressure.",
        "Skip the north Nath'Raxas Hold section if it costs too much time.",
        "Mine seams and deposits together; do not camp a single node pocket.",
    },
    coords = {
        C(0.5879, 0.3141, "AoA Krokuun northern Argus route pin"),
        C(0.5935, 0.3613, "AoA Krokuun north ridge pin"),
        C(0.5913, 0.4013, "AoA Krokuun central ridge pin"),
        C(0.410, 0.350, "Nath'Raxas south edge"),
        C(0.522, 0.386, "Central ridge"),
        C(0.6175, 0.4583, "AoA Krokuun east ridge pin"),
        C(0.626, 0.476, "Eastern ridge"),
        C(0.596, 0.632, "Southern return"),
        C(0.5497, 0.6117, "AoA Krokuun southern return pin"),
        C(0.456, 0.686, "Western return"),
    },
    confidence = "medium",
}

local INFERNAL_BRIMSTONE_AZSUNA_ROUTE = {
    id = "legion-infernal-brimstone-azsuna-rhutvan-destroyer",
    source = "Wowhead Infernal Brimstone comments, Wowhead Legion Mining guide, and r/woweconomy Brimstone notes",
    sourceUrls = {
        "https://www.wowhead.com/item=124444/infernal-brimstone",
        "https://www.wowhead.com/guide/legion-mining",
        "https://www.reddit.com/r/woweconomy/wiki/mining-legion-infernal-brimstone/",
    },
    mapName = "Azsuna",
    location = "Rhut'van Divide Brimstone Destroyer mining world quest report",
    routeType = "world-quest-mining-target",
    density = "Intermittent",
    dropDifficulty = "Only practical when the Brimstone Destroyer world quest is active.",
    tips = {
        "Check Legion mining world quests before travelling; the source is the destroyer core, not normal ore nodes.",
        "Kill the Brimstone Destroyer inside the active quest area before mining the core.",
        "A Wowhead comment reports the Azsuna destroyer around 38,24.",
    },
    coords = {
        C(0.380, 0.240, "Azsuna Rhut'van Divide destroyer report"),
    },
    confidence = "medium",
}

local INFERNAL_BRIMSTONE_HIGHMOUNTAIN_ROUTE = {
    id = "legion-infernal-brimstone-highmountain-snowblind-destroyer",
    source = "Wowhead Infernal Brimstone comments, Wowhead Legion Mining guide, and r/woweconomy Brimstone notes",
    sourceUrls = {
        "https://www.wowhead.com/item=124444/infernal-brimstone",
        "https://www.wowhead.com/guide/legion-mining",
        "https://www.reddit.com/r/woweconomy/wiki/mining-legion-infernal-brimstone/",
    },
    mapName = "Highmountain",
    location = "Snowblind Mesa Brimstone Destroyer mining world quest report",
    routeType = "world-quest-mining-target",
    density = "Intermittent",
    dropDifficulty = "Only practical when the Brimstone Destroyer world quest is active.",
    tips = {
        "Check Legion mining world quests before travelling; the source is the destroyer core, not normal ore nodes.",
        "Kill the Brimstone Destroyer inside the active quest area before mining the core.",
        "A Wowhead comment reports the Highmountain destroyer around 55,68.",
    },
    coords = {
        C(0.550, 0.680, "Highmountain Snowblind Mesa destroyer report"),
    },
    confidence = "medium",
}

local function RegisterOre(itemID, itemName, spots, summary)
    Register({
        itemID = itemID,
        itemName = itemName,
        expansion = "legion",
        professions = { "mining" },
        category = "Ore",
        sourceUrls = { ItemUrl(itemID) },
        summary = summary,
        spots = spots,
    })
end

RegisterOre(
    123918,
    "Leystone Ore",
    { VALSHARAH_ORE_ROUTE, SURAMAR_ORE_ROUTE, AZSUNA_BASILISK_ROUTE },
    "Common Legion ore from Broken Isles nodes and mineable Lagoon Basilisks."
)
RegisterOre(
    123919,
    "Felslate",
    { SURAMAR_ORE_ROUTE, VALSHARAH_ORE_ROUTE },
    "Rare Legion ore from nodes and seams, best checked on Suramar and Val'sharah loops."
)
RegisterOre(
    151564,
    "Empyrium",
    { EMPYRIUM_BASILISK_ROUTE, EMPYRIUM_KROKUUN_ROUTE },
    "Argus ore from Empyrium nodes and mineable Felfang Basilisks."
)
RegisterOre(
    124444,
    "Infernal Brimstone",
    { INFERNAL_BRIMSTONE_AZSUNA_ROUTE, INFERNAL_BRIMSTONE_HIGHMOUNTAIN_ROUTE },
    "World-quest-gated Legion mining material from Brimstone Destroyer cores."
)
