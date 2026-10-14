local _, NS = ...
local Register = NS.RegisterMaterialFarmingSpot
local H = NS.MaterialFarmingSpotHelpers

local function C(x, y, label)
    return { x = x, y = y, label = label }
end

local function ItemUrl(itemID)
    return "https://www.wowhead.com/item=" .. tostring(itemID)
end

local CRYSTALLIZED_GATHERING_SPOTS = {
    {
        id = "tww-crystallized-gathering-ringing-deeps-route",
        source = "Wowhead Crystallized ore and Irradiated herb object map pins, Method mining and herbalism guides",
        sourceUrls = {
            "https://www.wowhead.com/item=213610/crystalline-powder",
            "https://www.wowhead.com/object=413883/crystallized-bismuth",
            "https://www.wowhead.com/object=413900/crystallized-ironclaw",
            "https://www.wowhead.com/object=414337/irradiated-orbinid",
            "https://www.method.gg/guides/the-war-within-mining-profession-leveling-guide",
            "https://www.method.gg/guides/the-war-within-herbalism-profession-leveling-guide",
        },
        mapName = "The Ringing Deeps",
        location = "Northern ore walls and underground herb tunnels with Crystallized ore and Irradiated herb pins",
        routeType = "modified-node-loop",
        density = "Medium",
        dropDifficulty = "Crystalline Powder is a side gather from Crystallized gathering nodes, so clear all "
            .. "modified ore and herbs in the loop.",
        tips = {
            "Crystallized ore deposits and Irradiated herbs share practical route space in The Ringing Deeps.",
            "Use Perception when rare side-gather value beats raw ore or herb volume.",
            "Clear normal nodes too because modified node spawns rotate through the same route.",
        },
        coords = {
            C(0.353, 0.201, "Crystallized Bismuth north bend"),
            C(0.355, 0.164, "Crystallized ore wall"),
            C(0.360, 0.195, "Crystallized ore return"),
            C(0.368, 0.277, "Crystallized Ironclaw check"),
            C(0.379, 0.188, "Irradiated Orbinid tunnel"),
            C(0.382, 0.314, "Irradiated Orbinid south tunnel"),
            C(0.417, 0.203, "Irradiated herb east tunnel"),
        },
        confidence = "high",
    },
    {
        id = "tww-crystallized-gathering-hallowfall-route",
        source = "Wowhead Crystallized Aqirite and Irradiated Arathor's Spear object map pins",
        sourceUrls = {
            "https://www.wowhead.com/item=213610/crystalline-powder",
            "https://www.wowhead.com/object=413890/crystallized-aqirite",
            "https://www.wowhead.com/object=414339/irradiated-arathors-spear",
            "https://www.wowhead.com/guide/the-war-within/professions/herbalism-overview",
        },
        mapName = "Hallowfall",
        location = "Western and southern modified node checks",
        routeType = "modified-node-loop",
        density = "Medium",
        dropDifficulty = "Side-gather route for Crystalline Powder while still producing Aqirite, Bismuth, and herbs.",
        tips = {
            "Use this when mining and herbalism values are both relevant.",
            "Irradiated Arathor's Spear and Crystallized Aqirite can both appear on Hallowfall route edges.",
            "Treat Crystalline Powder as a bonus, not a guaranteed per-node output.",
        },
        coords = {
            C(0.211, 0.596, "Crystallized Aqirite west Hallowfall"),
            C(0.212, 0.646, "Crystallized ore cliff"),
            C(0.264, 0.531, "Irradiated Arathor's Spear west"),
            C(0.279, 0.490, "Irradiated Spear extension"),
            C(0.394, 0.930, "Southern modified ore pocket"),
            C(0.409, 0.865, "Southern modified node return"),
        },
        confidence = "medium",
    },
}

local LEYLINE_RESIDUE_SPOTS = {
    {
        id = "tww-irradiated-herbs-ringing-deeps-route",
        source = "Wowhead herbalism overview and Irradiated herb object map pins",
        sourceUrls = {
            "https://www.wowhead.com/item=213613/leyline-residue",
            "https://www.wowhead.com/guide/the-war-within/professions/herbalism-overview",
            "https://www.wowhead.com/object=414337/irradiated-orbinid",
            "https://www.wowhead.com/object=414335/irradiated-mycobloom",
        },
        mapName = "The Ringing Deeps",
        location = "Underground Irradiated herb loop",
        routeType = "modified-herb-loop",
        density = "Medium",
        dropDifficulty = "Leyline Residue is a side gather from Irradiated herbs; prioritize dense underground "
            .. "herb pins.",
        tips = {
            "Follow the same northern Ringing Deeps herb loop used for Orbinid and Luredrop checks.",
            "Gather every normal herb nearby because Irradiated spawns replace standard nodes.",
            "Perception can help when the residue price is the route target.",
        },
        coords = {
            C(0.379, 0.188, "Irradiated Orbinid north tunnel"),
            C(0.382, 0.315, "Irradiated Orbinid south pocket"),
            C(0.412, 0.174, "Irradiated herb east wall"),
            C(0.420, 0.188, "Irradiated herb return"),
            C(0.423, 0.314, "Irradiated Orbinid east tunnel"),
        },
        confidence = "high",
    },
    {
        id = "tww-irradiated-herbs-hallowfall-route",
        source = "Wowhead herbalism overview and Irradiated Arathor's Spear object map pins",
        sourceUrls = {
            "https://www.wowhead.com/item=213613/leyline-residue",
            "https://www.wowhead.com/object=414339/irradiated-arathors-spear",
            "https://www.wowhead.com/guide/the-war-within/professions/herbalism-overview",
        },
        mapName = "Hallowfall",
        location = "Western Irradiated Arathor's Spear checks",
        routeType = "modified-herb-loop",
        density = "Medium",
        dropDifficulty = "Targeted side-gather route; residue depends on finding Irradiated herb variants.",
        tips = {
            "Use the western Hallowfall Arathor's Spear route when you specifically want outdoor Irradiated "
                .. "herb checks.",
            "Fold this into broader Hallowfall mining if Crystallized Aqirite is also valuable.",
        },
        coords = {
            C(0.222, 0.618, "Irradiated Arathor's Spear west ridge"),
            C(0.250, 0.557, "Irradiated Spear ridge check"),
            C(0.264, 0.531, "Irradiated Spear west route"),
            C(0.279, 0.490, "Irradiated Spear northern extension"),
            C(0.294, 0.360, "Irradiated Spear far north"),
        },
        confidence = "medium",
    },
}

local function RegisterOre(itemID, itemName, qualityRank, summary, spots)
    Register({
        itemID = itemID,
        itemName = itemName,
        expansion = "warWithin",
        professions = { "mining" },
        category = "Ore",
        qualityRank = qualityRank,
        sourceUrls = {
            ItemUrl(itemID),
            "https://www.method.gg/guides/best-mining-and-herbalism-routes-for-the-war-within",
            "https://www.method.gg/guides/the-war-within-mining-profession-leveling-guide",
        },
        summary = summary,
        spots = spots or H.TWW_MINING_SPOTS,
    })
end

RegisterOre(210930, "Bismuth", 1,
    "Common Khaz Algar ore. Farm by clearing dense War Within mining loops and modified ore variants.")
RegisterOre(210931, "Bismuth", 2,
    "Common Khaz Algar ore. Farm by clearing dense War Within mining loops and modified ore variants.")
RegisterOre(210932, "Bismuth", 3,
    "Common Khaz Algar ore. Farm by clearing dense War Within mining loops and modified ore variants.")

RegisterOre(210933, "Aqirite", 1,
    "Uncommon War Within ore associated with Hallowfall and Azj-Kahet; target the Aqirite-heavy shared mining routes.",
    { H.TWW_MINING_SPOTS[3], H.TWW_MINING_SPOTS[4] })
RegisterOre(210934, "Aqirite", 2,
    "Uncommon War Within ore associated with Hallowfall and Azj-Kahet; target the Aqirite-heavy shared mining routes.",
    { H.TWW_MINING_SPOTS[3], H.TWW_MINING_SPOTS[4] })
RegisterOre(210935, "Aqirite", 3,
    "Uncommon War Within ore associated with Hallowfall and Azj-Kahet; target the Aqirite-heavy shared mining routes.",
    { H.TWW_MINING_SPOTS[3], H.TWW_MINING_SPOTS[4] })

RegisterOre(210936, "Ironclaw Ore", 1,
    "Uncommon War Within ore associated with Isle of Dorn and The Ringing Deeps; target the Ironclaw-heavy routes.",
    { H.TWW_MINING_SPOTS[1], H.TWW_MINING_SPOTS[2] })
RegisterOre(210937, "Ironclaw Ore", 2,
    "Uncommon War Within ore associated with Isle of Dorn and The Ringing Deeps; target the Ironclaw-heavy routes.",
    { H.TWW_MINING_SPOTS[1], H.TWW_MINING_SPOTS[2] })
RegisterOre(210938, "Ironclaw Ore", 3,
    "Uncommon War Within ore associated with Isle of Dorn and The Ringing Deeps; target the Ironclaw-heavy routes.",
    { H.TWW_MINING_SPOTS[1], H.TWW_MINING_SPOTS[2] })

Register({
    itemID = 210939,
    itemName = "Null Stone",
    expansion = "warWithin",
    professions = { "mining", "blacksmithing" },
    category = "Stone",
    sourceUrls = {
        ItemUrl(210939),
        "https://www.wowhead.com/object=413874/rich-bismuth",
        "https://www.wowhead.com/guide/the-war-within/professions/mining-overview",
        "https://www.method.gg/guides/the-war-within-mining-profession-leveling-guide",
    },
    summary = "Rare War Within mining side gather. Rich and modified ore nodes are the practical target, with "
        .. "Bismuth specialization improving Null Stone results.",
    spots = H.TWW_MINING_SPOTS,
})

Register({
    itemID = 213610,
    itemName = "Crystalline Powder",
    expansion = "warWithin",
    professions = { "mining", "herbalism", "blacksmithing" },
    category = "Reagent",
    sourceUrls = {
        ItemUrl(213610),
        "https://www.wowhead.com/object=413883/crystallized-bismuth",
        "https://www.wowhead.com/object=413890/crystallized-aqirite",
        "https://www.wowhead.com/object=413900/crystallized-ironclaw",
        "https://www.wowhead.com/guide/the-war-within/professions/mining-overview",
        "https://www.wowhead.com/guide/the-war-within/professions/herbalism-overview",
    },
    summary = "Side gather from Crystallized mining nodes and related modified gathering nodes; farm dense "
        .. "modified-node loops instead of treating it as a standalone spawn.",
    spots = CRYSTALLIZED_GATHERING_SPOTS,
})

Register({
    itemID = 213613,
    itemName = "Leyline Residue",
    expansion = "warWithin",
    professions = { "herbalism", "blacksmithing", "alchemy" },
    category = "Reagent",
    sourceUrls = {
        ItemUrl(213613),
        "https://www.wowhead.com/guide/the-war-within/professions/herbalism-overview",
        "https://www.wowhead.com/object=414337/irradiated-orbinid",
        "https://www.wowhead.com/object=414339/irradiated-arathors-spear",
    },
    summary = "Side gather from Irradiated herbs; use coordinate-backed Irradiated herb loops in "
        .. "The Ringing Deeps and Hallowfall.",
    spots = LEYLINE_RESIDUE_SPOTS,
})
