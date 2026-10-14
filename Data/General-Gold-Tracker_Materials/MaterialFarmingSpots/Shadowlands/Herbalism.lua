local _, NS = ...
local Register = NS.RegisterMaterialFarmingSpot

local function C(x, y, label)
    return { x = x, y = y, label = label }
end

local function ItemUrl(itemID)
    return "https://www.wowhead.com/item=" .. tostring(itemID)
end

local BASTION_HERB_ROUTE = {
    id = "shadowlands-bastion-rising-glory-route",
    source = "Wowhead Shadowlands herbalism guide and Shadowlands route comments",
    sourceUrls = {
        "https://www.wowhead.com/guide/shadowlands-herbalism-profession",
        "https://www.wow-professions.com/guides/shadowlands-herbalism-leveling-guide",
    },
    mapName = "Bastion",
    location = "Bastion open terrain herb route through Shimmering Pools, Hero's Rest, and Purity's Reflection",
    routeType = "herbalism-loop",
    density = "High for Rising Glory and Death Blossom",
    dropDifficulty = "Easy. Bastion is one of the friendliest Shadowlands herb zones.",
    tips = {
        "Use Bastion when you want the easiest Death Blossom and Nightshade side chances.",
        "Sky Golem or a gathering-speed glove enchant reduces dismount pain.",
        "The route pairs well with Bastion ore ridges.",
    },
    coords = {
        C(0.420, 0.320, "Shimmering Pools herbs"),
        C(0.464, 0.454, "Aspirant's Rest fields"),
        C(0.536, 0.522, "Hero's Rest herb line"),
        C(0.612, 0.482, "Eastern open fields"),
        C(0.530, 0.730, "Purity's Reflection water edge"),
    },
    confidence = "high",
}

local MALDRAXXUS_HERB_ROUTE = {
    id = "shadowlands-maldraxxus-theater-marrowroot-route",
    source = "Wowhead Shadowlands herbalism guide and Theater of Pain farming comment",
    sourceUrls = {
        "https://www.wowhead.com/guide/shadowlands-herbalism-profession",
        "https://www.wow-professions.com/farming/marrowroot-farming",
    },
    mapName = "Maldraxxus",
    location = "Theater of Pain circuits and House of Plagues side checks",
    routeType = "herbalism-loop",
    density = "Medium",
    dropDifficulty = "Moderate because Maldraxxus has more hostile pressure than Bastion.",
    tips = {
        "Circle Theater of Pain for Marrowroot while also checking Death Blossom and Oxxein.",
        "Avoid deep House interiors unless already farming mobs.",
        "Use this route only when Marrowroot is the target value.",
    },
    coords = {
        C(0.500, 0.530, "Theater of Pain central circuit"),
        C(0.440, 0.454, "West Theater herb checks"),
        C(0.530, 0.392, "North Theater return"),
        C(0.610, 0.506, "East Theater herb line"),
        C(0.580, 0.760, "House of Plagues water edge"),
    },
    confidence = "high",
}

local ARDENWEALD_HERB_ROUTE = {
    id = "shadowlands-ardenweald-vigils-torch-waypoint-route",
    source = "Wowhead Shadowlands herbalism guide and Ardenweald TomTom waypoint comment",
    sourceUrls = {
        "https://www.wowhead.com/guide/shadowlands-herbalism-profession",
        "https://www.wow-professions.com/farming/vigils-torch-farming",
    },
    mapName = "Ardenweald",
    location = "Ardenweald waypoint loop through Tirna Noch and central forest edges",
    routeType = "herbalism-loop",
    density = "Medium to high",
    dropDifficulty = "Moderate. Good density, but trees and roots can hide nodes.",
    tips = {
        "Use the published Ardenweald waypoint chain as the backbone of the route.",
        "Vigil's Torch and Death Blossom share a strong loop here.",
        "Nightshade is still rare, so treat it as bonus value.",
    },
    coords = {
        C(0.351, 0.518, "Western route start"),
        C(0.393, 0.634, "Southwest waypoint cluster"),
        C(0.491, 0.676, "Southern forest return"),
        C(0.516, 0.585, "Central forest checks"),
        C(0.608, 0.363, "Northern waypoint cluster"),
    },
    confidence = "high",
}

local REVENDRETH_HERB_ROUTE = {
    id = "shadowlands-revendreth-widowbloom-waypoint-route",
    source = "Wowhead Shadowlands herbalism guide, Revendreth TomTom waypoint comment, and Widowbloom guide",
    sourceUrls = {
        "https://www.wowhead.com/guide/shadowlands-herbalism-profession",
        "https://www.wow-professions.com/farming/widowbloom-farming",
    },
    mapName = "Revendreth",
    location = "Sanctuary of the Mad, lower Revendreth, and Sinfall-side Widowbloom loops",
    routeType = "herbalism-loop",
    density = "Medium",
    dropDifficulty = "Moderate to hard. Elevators, walls, and elite pockets can slow the path.",
    tips = {
        "Follow lower Revendreth and Sinfall-side waypoint clusters rather than the dense towns.",
        "Use the alternate Sinfall loop if the main lower route is crowded.",
        "Watch for Endmire damage and elevator delays.",
    },
    coords = {
        C(0.310, 0.527, "Sanctuary of the Mad start"),
        C(0.382, 0.650, "Lower Revendreth herb line"),
        C(0.505, 0.719, "Pridefall route center"),
        C(0.584, 0.645, "Eastern lower route"),
        C(0.350, 0.430, "Sinfall alternate loop"),
    },
    confidence = "high",
}

local ZERETH_MORTIS_FIRST_FLOWER_ROUTE = {
    id = "shadowlands-zereth-mortis-first-flower-progenium-route",
    source = "Retail Wowhead Patch 9.2 herbalism guide, Wowhead First Flower object pins, and Artisans of Azeroth Zereth Mortis route string",
    sourceUrls = {
        "https://www.wowhead.com/guide/profession-updates-patch-9-2-vestige-of-the-eternal",
        "https://www.wowhead.com/guide/profession-changes-patch-92-eternitys-end-shadowlands",
        "https://www.wowhead.com/item=187699/first-flower",
        "https://www.wowhead.com/object=370398/first-flower",
        "https://artisansofazeroth.com/progenium-ore-frist-flower-route-zereth-mortis/",
    },
    mapName = "Zereth Mortis",
    location = "Northern and northeastern Zereth Mortis First Flower route, overlapping Progenium checks",
    routeType = "herbalism-loop",
    density = "Medium for First Flower, with Death Blossom and Nightshade side herbs",
    dropDifficulty = "Moderate. First Flower is rare, so clear Death Blossom and Nightshade while moving the route.",
    tips = {
        "Patch 9.2 sources place First Flower only in Zereth Mortis.",
        "The route favors the northern and northeastern pin clusters instead of wandering the whole zone.",
        "This loop intentionally mirrors the Progenium path for future map-window route reconstruction.",
    },
    coords = {
        C(0.449, 0.080, "Wowhead First Flower far-north object pin"),
        C(0.462, 0.042, "Far-north object pin"),
        C(0.5005, 0.2543, "Artisans route northwestern loop point"),
        C(0.5534, 0.2880, "Artisans route northern ridge"),
        C(0.558, 0.365, "Wowhead First Flower central object pin"),
        C(0.5814, 0.2962, "Resonant Peaks route point"),
        C(0.5944, 0.2443, "Northern flower route"),
        C(0.6234, 0.2120, "First Flower object and route overlap"),
        C(0.6551, 0.2140, "Northeastern route point"),
        C(0.6719, 0.2668, "Northeast First Flower object cluster"),
        C(0.6660, 0.2997, "Eastern route descent"),
        C(0.6459, 0.2925, "Eastern return flower pin"),
        C(0.6171, 0.3441, "Southern flower route"),
        C(0.6630, 0.3513, "Southeastern loop point"),
        C(0.6931, 0.3355, "Eastern First Flower object pin"),
        C(0.6434, 0.3795, "Eastern ridge return"),
        C(0.5964, 0.3578, "Central return"),
    },
    confidence = "high",
}

local function RegisterHerb(itemID, itemName, spots, summary)
    Register({
        itemID = itemID,
        itemName = itemName,
        expansion = "shadowlands",
        professions = { "herbalism", "alchemy", "inscription" },
        category = "Herb",
        sourceUrls = { ItemUrl(itemID) },
        summary = summary,
        spots = spots,
    })
end

RegisterHerb(168583, "Widowbloom", { REVENDRETH_HERB_ROUTE },
    "Revendreth zone herb; lower Revendreth and Sinfall-side loops are the practical target routes.")
RegisterHerb(168586, "Rising Glory", { BASTION_HERB_ROUTE },
    "Bastion zone herb gathered along open-field and water-edge routes.")
RegisterHerb(168589, "Marrowroot", { MALDRAXXUS_HERB_ROUTE },
    "Maldraxxus zone herb best target-farmed around Theater of Pain.")
RegisterHerb(169701, "Death Blossom", {
    BASTION_HERB_ROUTE,
    ARDENWEALD_HERB_ROUTE,
    REVENDRETH_HERB_ROUTE,
    ZERETH_MORTIS_FIRST_FLOWER_ROUTE,
}, "Common Shadowlands herb gathered while farming zone-specific herbs.")
RegisterHerb(170554, "Vigil's Torch", { ARDENWEALD_HERB_ROUTE }, "Ardenweald zone herb from forest waypoint loops.")
RegisterHerb(171315, "Nightshade", {
    BASTION_HERB_ROUTE,
    ARDENWEALD_HERB_ROUTE,
    REVENDRETH_HERB_ROUTE,
    ZERETH_MORTIS_FIRST_FLOWER_ROUTE,
}, "Rare Shadowlands herb that can appear while farming other zone herbs; Bastion and Ardenweald are the "
    .. "easiest practical routes.")
RegisterHerb(187699, "First Flower", { ZERETH_MORTIS_FIRST_FLOWER_ROUTE },
    "Patch 9.2 Zereth Mortis herb used by Alchemy and Inscription recipes.")
