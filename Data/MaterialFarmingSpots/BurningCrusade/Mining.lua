local _, NS = ...
local Register = NS.RegisterMaterialFarmingSpot

local FEL_IRON_HELLFIRE_COORDS = {
    { x = 0.3882, y = 0.3128, label = "AoA northern Hellfire route start" },
    { x = 0.062, y = 0.494, label = "Western Hellfire ridge node cluster" },
    { x = 0.103, y = 0.555, label = "Thornfang Hill mining edge" },
    { x = 0.168, y = 0.608, label = "Southwest ravager ridge node" },
    { x = 0.212, y = 0.627, label = "Expedition Armory south ridge" },
    { x = 0.288, y = 0.586, label = "Western Path of Glory ridge" },
    { x = 0.334, y = 0.499, label = "Hellfire Citadel western approach" },
    { x = 0.416, y = 0.498, label = "Central Path of Glory cliff" },
    { x = 0.4564, y = 0.6314, label = "AoA southern Hellfire route node" },
    { x = 0.493, y = 0.494, label = "Central Hellfire ridge node" },
    { x = 0.5159, y = 0.5470, label = "AoA south-central Hellfire node" },
    { x = 0.596, y = 0.500, label = "Eastern Path of Glory cliff" },
    { x = 0.6029, y = 0.4971, label = "AoA Path of Glory return node" },
    { x = 0.694, y = 0.435, label = "Zeth'gor northern cliff" },
    { x = 0.7194, y = 0.5410, label = "AoA southeast Hellfire route node" },
    { x = 0.767, y = 0.594, label = "Southeast Hellfire ridge" },
    { x = 0.706, y = 0.734, label = "Southern broken ridge" },
}

local ADAMANTITE_NAGRAND_COORDS = {
    { x = 0.071, y = 0.399, label = "Twilight Ridge cave edge node" },
    { x = 0.232, y = 0.278, label = "Northwest Nagrand ridge" },
    { x = 0.292, y = 0.541, label = "Western Nagrand cave path" },
    { x = 0.348, y = 0.482, label = "Western cave return node" },
    { x = 0.431, y = 0.622, label = "Central cave and ridge node" },
    { x = 0.494, y = 0.727, label = "Southern mountain edge" },
    { x = 0.572, y = 0.576, label = "Halaa-side ridge node" },
    { x = 0.603, y = 0.170, label = "Northern ridge node" },
    { x = 0.6532, y = 0.3433, label = "AoA eastern Nagrand Adamantite route start" },
    { x = 0.6924, y = 0.3796, label = "AoA eastern Nagrand ridge node" },
    { x = 0.7276, y = 0.4324, label = "AoA northeast Nagrand route node" },
    { x = 0.698, y = 0.725, label = "Southeast Nagrand ridge" },
    { x = 0.7131, y = 0.6266, label = "AoA southeast Nagrand node" },
    { x = 0.762, y = 0.604, label = "Eastern mountain edge" },
}

local ADAMANTITE_NETHERSTORM_COORDS = {
    { x = 0.194, y = 0.721, label = "Northwest island edge" },
    { x = 0.237, y = 0.350, label = "Ruins cliff node" },
    { x = 0.254, y = 0.406, label = "Manaforge-side node" },
    { x = 0.419, y = 0.571, label = "Central Netherstorm ridge" },
    { x = 0.489, y = 0.125, label = "Northern island cliff" },
    { x = 0.604, y = 0.493, label = "Eastern bridge ridge" },
    { x = 0.720, y = 0.430, label = "Celestial Ridge route node" },
}

local ADAMANTITE_ISLE_QUELDANAS_COORDS = {
    { x = 0.610, y = 0.440, label = "Northeast waterline Adamantite node" },
    { x = 0.600, y = 0.400, label = "Northeast hillside Adamantite node" },
    { x = 0.620, y = 0.400, label = "Northeast upper hillside node" },
    { x = 0.370, y = 0.510, label = "Sunwell Plateau lower shelf node" },
    { x = 0.360, y = 0.440, label = "Northwest inner shelf node" },
    { x = 0.350, y = 0.350, label = "Northwest high shelf node" },
    { x = 0.390, y = 0.350, label = "Dawnstar Village high shelf node" },
    { x = 0.430, y = 0.320, label = "Dawnstar Village ridge node" },
    { x = 0.450, y = 0.370, label = "North Dawning Square node" },
    { x = 0.500, y = 0.410, label = "Dawning Square west shelf node" },
    { x = 0.490, y = 0.460, label = "Sun's Reach shelf node" },
    { x = 0.470, y = 0.500, label = "Sun's Reach Armory node" },
}

local KHORIUM_NAGRAND_COORDS = {
    { x = 0.071, y = 0.399, label = "Khorium-capable Twilight Ridge node" },
    { x = 0.1802, y = 0.3108, label = "AoA Twilight Ridge Khorium route start" },
    { x = 0.2363, y = 0.2932, label = "AoA Twilight Ridge west Khorium check" },
    { x = 0.244, y = 0.335, label = "Northwest cave node" },
    { x = 0.2639, y = 0.1870, label = "AoA northwest Khorium-capable node" },
    { x = 0.2870, y = 0.1238, label = "AoA high ridge Khorium-capable node" },
    { x = 0.299, y = 0.306, label = "Northwest ridge replacement node" },
    { x = 0.341, y = 0.443, label = "Western Nagrand cave node" },
    { x = 0.417, y = 0.416, label = "Central ridge replacement node" },
    { x = 0.494, y = 0.727, label = "Southern mountain node" },
    { x = 0.603, y = 0.170, label = "Northern ridge replacement node" },
}

local function MiningSpot(id, sourceUrls, mapName, location, coords, density, difficulty, tips, confidence)
    return {
        id = id,
        source = "Wowhead object map pins, Artisans of Azeroth Routes import strings, Wowhead mining guide, and farming guide cross-checks",
        sourceUrls = sourceUrls,
        mapName = mapName,
        location = location,
        routeType = "mining-loop",
        density = density,
        dropDifficulty = difficulty,
        tips = tips,
        coords = coords,
        confidence = confidence,
    }
end

Register({
    itemID = 23424,
    itemName = "Fel Iron Ore",
    expansion = "burningCrusade",
    professions = { "mining" },
    category = "Ore",
    researchStatus = "researched",
    sourceUrls = {
        "https://www.wowhead.com/object=181555/fel-iron-deposit",
        "https://www.wow-professions.com/farming/fel-iron-ore-farming",
        "https://artisansofazeroth.com/fel-iron-ore-farming/",
    },
    summary = "Core Outland ore. Hellfire Peninsula is the cleanest Fel Iron route because Fel Iron nodes dominate the zone and the path has many cliff and cave-edge anchors.",
    spots = {
        MiningSpot(
            "fel-iron-hellfire-peninsula-mountain-loop",
            {
                "https://www.wowhead.com/object=181555/fel-iron-deposit",
                "https://www.wow-professions.com/farming/fel-iron-ore-farming",
                "https://artisansofazeroth.com/fel-iron-ore-farming/",
            },
            "Hellfire Peninsula",
            "Mountain edges, cave mouths, Hellfire Citadel approaches, Zeth'gor, and the western ravager ridges",
            FEL_IRON_HELLFIRE_COORDS,
            "High",
            "Easy. Stay on ridges and mine every node to keep respawns turning over.",
            {
                "Follow zone edges and cliff lines instead of crossing the flat center.",
                "Fel Iron nodes can also yield Mote of Fire, Mote of Earth, Eternium Ore, and occasional gems.",
                "The western ravager side pairs well with Fel Scales or Knothide skinning.",
            },
            "high"
        ),
    },
})

Register({
    itemID = 23425,
    itemName = "Adamantite Ore",
    expansion = "burningCrusade",
    professions = { "mining" },
    category = "Ore",
    researchStatus = "researched",
    sourceUrls = {
        "https://www.wowhead.com/object=181556/adamantite-deposit",
        "https://www.wow-professions.com/farming/adamantite-ore-farming",
        "https://artisansofazeroth.com/adamantite-ore-farming/",
    },
    summary = "Primary high-level Outland ore. Nagrand is the strongest all-around route; Netherstorm is a good flying-mount alternative with wide island-edge loops.",
    spots = {
        MiningSpot(
            "adamantite-nagrand-caves-and-ridges",
            {
                "https://www.wowhead.com/object=181556/adamantite-deposit",
                "https://www.wow-professions.com/farming/adamantite-ore-farming",
                "https://artisansofazeroth.com/adamantite-ore-farming/",
            },
            "Nagrand",
            "Caves, rocky boundaries, Twilight Ridge, and outer mountain loops across Nagrand",
            ADAMANTITE_NAGRAND_COORDS,
            "High",
            "Good. Cave checks add yield, but skip them if combat slows the route.",
            {
                "Mine Fel Iron and Adamantite while looking for rare Khorium replacements.",
                "Nagrand nodes can produce Eternium Ore, gems, and Mote of Earth as side value.",
                "Use a tighter cave-and-ridge circuit when the full-zone loop feels too long.",
            },
            "high"
        ),
        MiningSpot(
            "adamantite-isle-queldanas-sunwell-route",
            {
                "https://www.wowhead.com/item=24243/adamantite-powder",
                "https://www.wowhead.com/object=181556/adamantite-deposit",
            },
            "Isle of Quel'Danas",
            "East coastline and northwest Sunwell Plateau shelves, using the exact node set from a retail Wowhead comment",
            ADAMANTITE_ISLE_QUELDANAS_COORDS,
            "Medium to high when uncontested",
            "Compact but competition-sensitive. Strong when you also want Adamantite Powder from prospecting.",
            {
                "Start on the northeast hillside, then sweep west through Dawnstar Village and Sun's Reach shelves.",
                "The route is small enough that clearing every Adamantite-capable node matters more than long travel.",
                "Treat Khorium as a rare replacement, not the baseline yield.",
            },
            "medium"
        ),
        MiningSpot(
            "adamantite-netherstorm-wide-loop",
            {
                "https://www.wowhead.com/object=181556/adamantite-deposit",
                "https://www.wow-professions.com/farming/adamantite-ore-farming",
            },
            "Netherstorm",
            "Outer island edges, ruins, cliff shelves, and cave entrances across Netherstorm",
            ADAMANTITE_NETHERSTORM_COORDS,
            "High",
            "Good with flying. Bigger gaps and higher-level mobs make it slower than Nagrand for some characters.",
            {
                "Use outdoor loops unless you can clear cave mobs quickly.",
                "Do not skip normal nodes if you want Khorium replacement chances.",
                "Pairs naturally with Netherbloom and Arcane Vortex cloud checks.",
            },
            "medium"
        ),
    },
})

Register({
    itemID = 23426,
    itemName = "Khorium Ore",
    expansion = "burningCrusade",
    professions = { "mining" },
    category = "Ore",
    researchStatus = "researched",
    sourceUrls = {
        "https://www.wowhead.com/object=181557/khorium-vein",
        "https://www.wowhead.com/object=181556/adamantite-deposit",
        "https://www.wow-professions.com/farming/adamantite-ore-farming",
        "https://artisansofazeroth.com/khorium-ore-routes/",
    },
    summary = "Rare Outland ore from Khorium Veins. The practical strategy is high node turnover in Nagrand and Netherstorm, not camping one old spawn.",
    spots = {
        MiningSpot(
            "khorium-nagrand-node-turnover",
            {
                "https://www.wowhead.com/object=181557/khorium-vein",
                "https://www.wowhead.com/object=181556/adamantite-deposit",
                "https://artisansofazeroth.com/khorium-ore-routes/",
            },
            "Nagrand",
            "Khorium-capable Nagrand cave and ridge nodes",
            KHORIUM_NAGRAND_COORDS,
            "Low for Khorium, high for node turnover",
            "Rare and competition-sensitive. Mine every normal node so replacement spawns can roll Khorium.",
            {
                "Check caves around Nagrand; they are frequently called out for Khorium sightings.",
                "Early morning or low-competition windows matter more than a perfect path.",
                "Expect Adamantite, Fel Iron, Eternium, and gems while hunting Khorium.",
            },
            "high"
        ),
        MiningSpot(
            "khorium-netherstorm-wide-loop",
            {
                "https://www.wowhead.com/object=181557/khorium-vein",
                "https://www.wow-professions.com/farming/adamantite-ore-farming",
            },
            "Netherstorm",
            "Netherstorm Khorium-capable cliffs, island edges, and cave approaches",
            ADAMANTITE_NETHERSTORM_COORDS,
            "Low for Khorium, high for node turnover",
            "Rare. Good if you are already gathering Netherstorm herbs or clouds.",
            {
                "Clear Adamantite and Fel Iron nodes instead of waiting at one historical Khorium point.",
                "Flying makes this route much less painful because node clusters sit on separated landmasses.",
            },
            "medium"
        ),
    },
})

Register({
    itemID = 23427,
    itemName = "Eternium Ore",
    expansion = "burningCrusade",
    professions = { "mining" },
    category = "Ore",
    researchStatus = "researched",
    sourceUrls = {
        "https://www.wowhead.com/item=23427/eternium-ore",
        "https://www.wowhead.com/object=181556/adamantite-deposit",
        "https://www.wow-professions.com/farming/adamantite-ore-farming",
    },
    summary = "Uncommon side ore from Outland mining nodes. Nagrand Adamantite routes are the practical farm because they maximize high-value node count.",
    spots = {
        MiningSpot(
            "eternium-nagrand-adamantite-side-drop",
            {
                "https://www.wowhead.com/item=23427/eternium-ore",
                "https://www.wowhead.com/object=181556/adamantite-deposit",
            },
            "Nagrand",
            "Adamantite-heavy Nagrand cave and ridge loop",
            ADAMANTITE_NAGRAND_COORDS,
            "Low",
            "Uncommon side material. Farm Adamantite and Khorium routes, then treat Eternium as extra value.",
            {
                "Do not target Eternium by itself; use the highest-density Adamantite loop your character can clear.",
                "Nagrand is the recommended route because it combines node density with Khorium replacement chances.",
            },
            "high"
        ),
    },
})
