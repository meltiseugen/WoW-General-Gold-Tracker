local _, NS = ...
local Register = NS.RegisterMaterialFarmingSpot

local function C(x, y, label)
    return { x = x, y = y, label = label }
end

local function ItemUrl(itemID)
    return "https://www.wowhead.com/item=" .. tostring(itemID)
end

local FISHING_GUIDE = "https://www.wowhead.com/guide/cooking-materials-best-farming-locations"

local FROZEN_SEA_ROUTE = {
    id = "wrath-frozen-sea-borean-tundra-iceberg-schools",
    source = "Wowhead Moonglow Cuttlefish School comments, Warcraft Wiki fish pages, and Wowhead cooking material guide",
    sourceUrls = {
        "https://www.wowhead.com/object=192054/moonglow-cuttlefish-school",
        "https://warcraft.wiki.gg/wiki/Deep_Sea_Monsterbelly",
        FISHING_GUIDE,
    },
    mapName = "Borean Tundra",
    location = "Frozen Sea icebergs southeast of Unu'pe",
    routeType = "fishing-school-loop",
    density = "Localized",
    dropDifficulty = "One of the stricter Wrath fishing routes because the useful schools are offshore and limited.",
    tips = {
        "Circle the icebergs southeast of Unu'pe and fish visible schools first.",
        "Moonglow Cuttlefish and Deep Sea Monsterbelly can share offshore school territory.",
        "Use high fishing skill and lures to reduce junk and missed catches.",
    },
    coords = {
        C(0.842, 0.700, "North iceberg school check"),
        C(0.870, 0.742, "Central iceberg school check"),
        C(0.902, 0.786, "Outer iceberg school check"),
        C(0.816, 0.756, "Western iceberg school check"),
    },
    confidence = "medium",
}

local MANTA_COAST_ROUTE = {
    id = "wrath-imperial-manta-ray-howling-fjord-coast",
    source = "Wowhead cooking material guide and Wowhead fishing leveling guide",
    sourceUrls = {
        FISHING_GUIDE,
        "https://www.wowhead.com/guide/professions/fishing/leveling-1-450",
    },
    mapName = "Howling Fjord",
    location = "Howling Fjord coastal fishing route",
    routeType = "coastal-fishing-loop",
    density = "Medium",
    dropDifficulty = "Straightforward coastal fishing route with broad Northrend fish side catches.",
    tips = {
        "Follow the coast and fish pools first, then open water while moving between pool checks.",
        "Treat Rockfin Grouper and clams as side value on broad coastal routes.",
    },
    coords = {
        C(0.242, 0.604, "Western coast"),
        C(0.302, 0.684, "Southwest coast"),
        C(0.462, 0.792, "Southern coast"),
        C(0.598, 0.722, "Southeast coast"),
        C(0.724, 0.616, "Eastern coast"),
    },
    confidence = "medium",
}

local BOREAN_MANOWAR_ROUTE = {
    id = "wrath-borean-man-o-war-borean-tundra-inland-waters",
    source = "Wowhead Borean Man O' War item page, Wowhead cooking material guide, and Wowhead fishing leveling guide",
    sourceUrls = {
        "https://www.wowhead.com/item=41805/borean-man-o-war",
        FISHING_GUIDE,
        "https://www.wowhead.com/guide/professions/fishing/leveling-1-450",
    },
    mapName = "Borean Tundra",
    location = "Borean Tundra inland pools and waterway checks",
    routeType = "inland-fishing-loop",
    density = "Medium",
    dropDifficulty = "Good target while leveling Northrend fishing; pool availability changes the pace.",
    tips = {
        "Fish visible pools first, then open water between checks.",
        "Pair with Musselback Sculpin checks when moving northeast of Warsong Hold.",
    },
    coords = {
        C(0.500, 0.150, "North water checks"),
        C(0.568, 0.270, "Northeast water checks"),
        C(0.410, 0.410, "Central water checks"),
        C(0.640, 0.500, "Eastern water checks"),
    },
    confidence = "medium",
}

local MUSSELBACK_ROUTE = {
    id = "wrath-musselback-sculpin-borean-tundra-warsong-hold",
    source = "Wowhead cooking material guide",
    sourceUrls = { FISHING_GUIDE },
    mapName = "Borean Tundra",
    location = "Waters northeast of Warsong Hold",
    routeType = "fishing-school-loop",
    density = "High for Musselback Sculpin Schools",
    dropDifficulty = "Strong targeted Fish Feast ingredient route.",
    tips = {
        "Wowhead's cooking material guide calls out the waters northeast of Warsong Hold at /way 51 44.",
        "Stay in the local water pocket instead of drifting into a full-zone fishing route.",
    },
    coords = {
        C(0.510, 0.440, "Warsong Hold northeast water"),
        C(0.548, 0.432, "East pool checks"),
        C(0.486, 0.478, "Southwest pool checks"),
    },
    confidence = "high",
}

local GRIZZLY_SALMON_ROUTE = {
    id = "wrath-glacial-salmon-grizzly-hills-rivers",
    source = "Retail Wowhead Glacial Salmon and Glacial Salmon School comments",
    sourceUrls = {
        "https://www.wowhead.com/item=41809/glacial-salmon",
        "https://www.wowhead.com/object=192050/glacial-salmon-school",
        FISHING_GUIDE,
    },
    mapName = "Grizzly Hills",
    location = "Grizzly Hills river route for Glacial Salmon and Fangtooth Herring side catches",
    routeType = "fishing-school-loop",
    density = "High for Glacial Salmon schools",
    dropDifficulty = "Good river route; fish visible schools first, then open water while moving.",
    tips = {
        "Stay on the Grizzly Hills river network because retail comments call it the common Salmon area.",
        "Use Howling Fjord water as a Fangtooth Herring backup if Salmon schools are thin.",
        "Fish schools first for cooking-material throughput.",
    },
    coords = {
        C(0.198, 0.400, "West river school checks"),
        C(0.288, 0.392, "Amberpine river bend"),
        C(0.352, 0.320, "North river bend"),
        C(0.422, 0.362, "Central river school"),
        C(0.314, 0.463, "South river return"),
        C(0.252, 0.738, "Southwest waterline"),
    },
    confidence = "high",
}

local SHOLAZAR_OPEN_WATER_ROUTE = {
    id = "wrath-barrelhead-goby-nettlefish-sholazar-rivers-heart",
    source = "Retail Wowhead Barrelhead Goby and Nettlefish comments",
    sourceUrls = {
        "https://www.wowhead.com/item=41812/barrelhead-goby",
        "https://www.wowhead.com/item=41813/nettlefish",
        FISHING_GUIDE,
    },
    mapName = "Sholazar Basin",
    location = "River's Heart and Sholazar open-water route for Barrelhead Goby and Nettlefish",
    routeType = "open-water-fishing-loop",
    density = "High for Sholazar open-water fish",
    dropDifficulty = "Good if you can maintain casts around River's Heart and nearby waterways.",
    tips = {
        "Fish River's Heart open water; Barrelhead Goby and Nettlefish share this basin catch table.",
        "Move between pool checks only when open-water catches slow down.",
        "This route pairs well with Adder's Tongue and Tiger Lily gathering.",
    },
    coords = {
        C(0.500, 0.600, "River's Heart west bank"),
        C(0.528, 0.586, "River's Heart center"),
        C(0.556, 0.610, "River's Heart east bank"),
        C(0.594, 0.566, "Eastern waterway"),
        C(0.476, 0.642, "Southwest water return"),
    },
    confidence = "high",
}

local DRAGONFIN_ROUTE = {
    id = "wrath-dragonfin-angelfish-dragonblight-lake-indule",
    source = "Wowhead cooking material guide, Warcraft Wiki Dragonfin Angelfish page, and Wowhead fishing leveling guide",
    sourceUrls = {
        FISHING_GUIDE,
        "https://warcraft.wiki.gg/wiki/Dragonfin_Angelfish",
        "https://www.wowhead.com/guide/professions/fishing/leveling-1-450",
    },
    mapName = "Dragonblight",
    location = "Lake Indu'le and nearby Dragonblight waterways",
    routeType = "inland-fishing-loop",
    density = "Medium to high",
    dropDifficulty = "Good high-demand cooking fish route with open-water fallback.",
    tips = {
        "Fish Lake Indu'le and nearby waterways for Dragonfin Angelfish.",
        "Use this route when Strength and Agility food demand makes Dragonfin valuable.",
        "Rockfin Grouper can appear as side value while fishing broader Northrend waters.",
    },
    coords = {
        C(0.400, 0.660, "Lake Indu'le west"),
        C(0.414, 0.646, "Lake Indu'le center"),
        C(0.438, 0.626, "Lake Indu'le north"),
        C(0.504, 0.612, "Eastern waterway"),
        C(0.604, 0.612, "Dragonblight river check"),
    },
    confidence = "high",
}

local function RegisterFish(itemID, itemName, spots, summary)
    Register({
        itemID = itemID,
        itemName = itemName,
        expansion = "wrath",
        professions = { "fishing", "cooking" },
        category = "Fish",
        sourceUrls = { ItemUrl(itemID), FISHING_GUIDE },
        summary = summary,
        spots = spots,
    })
end

RegisterFish(36782, "Succulent Clam Meat", { MANTA_COAST_ROUTE, MUSSELBACK_ROUTE }, "Cooking material from Northrend clams, best tracked as side value while fishing coastal and high-value Northrend pools.")
RegisterFish(41800, "Deep Sea Monsterbelly", { FROZEN_SEA_ROUTE }, "Offshore Frozen Sea fish found around Borean Tundra iceberg school routes.")
RegisterFish(41801, "Moonglow Cuttlefish", { FROZEN_SEA_ROUTE }, "Limited offshore Frozen Sea fish from schools around the Borean Tundra icebergs.")
RegisterFish(41802, "Imperial Manta Ray", { MANTA_COAST_ROUTE }, "Broad Northrend coastal fish; Howling Fjord coast is a practical coordinate-backed route.")
RegisterFish(41803, "Rockfin Grouper", { DRAGONFIN_ROUTE, MANTA_COAST_ROUTE }, "Common Northrend fish best valued as side catch while targeting more specialized fish.")
RegisterFish(41805, "Borean Man O' War", { BOREAN_MANOWAR_ROUTE }, "Borean Tundra fish from inland waters and pool checks.")
RegisterFish(41806, "Musselback Sculpin", { MUSSELBACK_ROUTE }, "Fish Feast ingredient with a strong targeted route northeast of Warsong Hold.")
RegisterFish(41807, "Dragonfin Angelfish", { DRAGONFIN_ROUTE }, "High-demand Dragonblight fish used for Strength and Agility foods.")
RegisterFish(41808, "Bonescale Snapper", { DRAGONFIN_ROUTE, GRIZZLY_SALMON_ROUTE },
    "Common Northrend inland fish best treated as side catch while targeting Dragonfin or Salmon routes.")
RegisterFish(41809, "Glacial Salmon", { GRIZZLY_SALMON_ROUTE },
    "Grizzly Hills river fish from Glacial Salmon schools and open-water river casts.")
RegisterFish(41810, "Fangtooth Herring", { GRIZZLY_SALMON_ROUTE, MANTA_COAST_ROUTE },
    "Howling Fjord and Grizzly Hills fish; use river/coast routes and visible schools.")
RegisterFish(41812, "Barrelhead Goby", { SHOLAZAR_OPEN_WATER_ROUTE },
    "Sholazar Basin open-water fish, especially around River's Heart.")
RegisterFish(41813, "Nettlefish", { SHOLAZAR_OPEN_WATER_ROUTE },
    "Sholazar Basin open-water and school fish that shares routes with Barrelhead Goby.")
