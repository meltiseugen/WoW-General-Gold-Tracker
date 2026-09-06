local _, NS = ...
local Register = NS.RegisterMaterialFarmingSpot

local function C(x, y, label)
    return { x = x, y = y, label = label }
end

local function ItemUrl(itemID)
    return "https://www.wowhead.com/item=" .. tostring(itemID)
end

local ZANDALAR_COASTAL_ROUTE = {
    id = "bfa-zandalar-coastal-fishing-route",
    source = "Wowhead BFA Fishing guide, Legacy WoW fishing guide, and BFA fishing notes",
    sourceUrls = {
        "https://www.wowhead.com/guide/bfa-fishing",
        "https://legacy-wow.com/fishing-guide-battle-for-azeroth/",
        "https://mynoobnotebook1.blogspot.com/2019/01/bfa-fishing.html",
    },
    mapName = "Zuldazar",
    location = "Zandalar coastal fishing route",
    routeType = "coastal-fishing",
    density = "Steady",
    dropDifficulty = "Easy. Fish from coastal water and pools around Zandalar shores.",
    tips = {
        "Zandalar coastal water is the practical target for Sand Shifter and Slimy Mackerel.",
        "Fishing skill does not change BFA catch volume, so route selection matters more than skill level.",
        "Move between pools instead of waiting on an exhausted section of coastline.",
    },
    coords = {
        C(0.272, 0.716, "Southwest Zuldazar coast"),
        C(0.438, 0.802, "Southern Zuldazar shore"),
        C(0.624, 0.760, "Southeast coast"),
        C(0.746, 0.568, "Eastern coast"),
        C(0.674, 0.316, "Northeast coast"),
    },
    confidence = "medium",
}

local KUL_TIRAS_COASTAL_ROUTE = {
    id = "bfa-kul-tiras-coastal-fishing-route",
    source = "Wowhead BFA Fishing guide, Legacy WoW fishing guide, and BFA fishing notes",
    sourceUrls = {
        "https://www.wowhead.com/guide/bfa-fishing",
        "https://legacy-wow.com/fishing-guide-battle-for-azeroth/",
        "https://mynoobnotebook1.blogspot.com/2019/01/bfa-fishing.html",
    },
    mapName = "Tiragarde Sound",
    location = "Kul Tiras coastal fishing route",
    routeType = "coastal-fishing",
    density = "Steady",
    dropDifficulty = "Easy. Fish from coastal waters and pools around Kul Tiras shores.",
    tips = {
        "Kul Tiras coastal water is the practical target for Lane Snapper and Frenzied Fangtooth.",
        "Check pools while circling the east and south coasts.",
        "Great Sea Ray can also come from BFA sea and ocean waters as a low-chance bonus.",
    },
    coords = {
        C(0.742, 0.224, "Northeast Tiragarde coast"),
        C(0.812, 0.384, "Eastern coast"),
        C(0.728, 0.626, "South cape"),
        C(0.594, 0.724, "Southern coast"),
        C(0.474, 0.676, "West return shore"),
    },
    confidence = "medium",
}

local KUL_TIRAS_INLAND_ROUTE = {
    id = "bfa-kul-tiras-inland-fishing-route",
    source = "Wowhead BFA Fishing guide and Legacy WoW fishing table",
    sourceUrls = {
        "https://www.wowhead.com/guide/bfa-fishing",
        "https://legacy-wow.com/fishing-guide-battle-for-azeroth/",
    },
    mapName = "Tiragarde Sound",
    location = "Kul Tiras river and lake fishing route",
    routeType = "inland-fishing",
    density = "Steady",
    dropDifficulty = "Easy. Fish from rivers and lakes, not coastal water.",
    tips = {
        "Tiragarde Perch comes from Kul Tiras inland water.",
        "Great Sea Catfish also appears in BFA inland water.",
        "Use rivers and lakes that are close to flight paths for shorter loops.",
    },
    coords = {
        C(0.512, 0.454, "Central Tiragarde river"),
        C(0.602, 0.506, "Eastern lake edge"),
        C(0.472, 0.648, "Southern river turn"),
        C(0.408, 0.566, "Western stream"),
        C(0.548, 0.344, "Northern river"),
    },
    confidence = "medium",
}

local ZANDALAR_INLAND_ROUTE = {
    id = "bfa-zandalar-inland-fishing-route",
    source = "Wowhead BFA Fishing guide and Legacy WoW fishing table",
    sourceUrls = {
        "https://www.wowhead.com/guide/bfa-fishing",
        "https://legacy-wow.com/fishing-guide-battle-for-azeroth/",
    },
    mapName = "Nazmir",
    location = "Zandalar rivers, lakes, and swamp water route",
    routeType = "inland-fishing",
    density = "Steady",
    dropDifficulty = "Easy. Nazmir has plentiful inland water but more hostile pathing.",
    tips = {
        "Redtail Loach comes from Zandalar inland water.",
        "Great Sea Catfish also appears in BFA inland water.",
        "Use Nazmir when you want inland pools and nearby herb/mining side checks.",
    },
    coords = {
        C(0.344, 0.426, "Western Nazmir water"),
        C(0.456, 0.518, "Central swamp pool"),
        C(0.560, 0.456, "Eastern water edge"),
        C(0.618, 0.590, "Southeast river"),
        C(0.504, 0.668, "Southern swamp water"),
    },
    confidence = "medium",
}

local BFA_RARE_SALMON_ROUTE = {
    id = "bfa-midnight-salmon-general-water-route",
    source = "Retail Wowhead BFA Fishing guide and wow-professions BFA Fishing guide",
    sourceUrls = {
        "https://www.wowhead.com/guide/bfa-fishing",
        "https://www.wow-professions.com/guides/zandalari-kul-tiran-bfa-fishing-leveling-guide",
    },
    mapName = "Tiragarde Sound",
    location = "Representative BFA open-water route for rare Midnight Salmon catches",
    routeType = "rare-fishing",
    density = "Rare",
    dropDifficulty = "Rare open-water catch; farm whatever BFA fish is profitable and treat Midnight Salmon as a bonus.",
    tips = {
        "Midnight Salmon can come from BFA waters, so do not build a single-zone-only expectation around it.",
        "Use compact inland and coastal loops to keep casts moving through fresh pools.",
        "Keep common fish and Aromatic Fish Oil value in the route calculation.",
    },
    coords = {
        C(0.742, 0.224, "Northeast Tiragarde coast"),
        C(0.812, 0.384, "Eastern coast"),
        C(0.602, 0.506, "Eastern inland lake"),
        C(0.512, 0.454, "Central Tiragarde river"),
        C(0.472, 0.648, "Southern river turn"),
        C(0.594, 0.724, "Southern coast"),
    },
    confidence = "medium",
}

local NAZJATAR_FISHING_ROUTE = {
    id = "bfa-nazjatar-viper-mauve-stinger-route",
    source = "Retail Wowhead BFA Fishing guide, wow-professions BFA Fishing guide, and Wowhead Mauve Stinger school comment coordinates",
    sourceUrls = {
        "https://www.wowhead.com/guide/bfa-fishing",
        "https://www.wow-professions.com/guides/zandalari-kul-tiran-bfa-fishing-leveling-guide",
        "https://www.wowhead.com/object=327162/mauve-stinger-school",
    },
    mapName = "Nazjatar",
    location = "Nazjatar pool route through Hanging Reef, Deepcoil, and Kal'methir water",
    routeType = "pool-fishing",
    density = "Medium",
    dropDifficulty = "Patch 8.2 fish route. Use pools when visible, with Hanging Reef as the safest targeted point.",
    tips = {
        "A Wowhead school comment points to a no-fighting Hanging Reef pool around 40.67,55.75.",
        "Viper Fish and Mauve Stinger both belong to Nazjatar fishing, so use one shared route.",
        "Pair this with Nazjatar herb/ore travel when Zin'anthid or Osmenite prices are good.",
    },
    coords = {
        C(0.4067, 0.5575, "Hanging Reef pool report"),
        C(0.402, 0.581, "Hanging Reef water route"),
        C(0.656, 0.220, "Deepcoil Tunnels lake"),
        C(0.593, 0.145, "Shirakess Repository water"),
        C(0.657, 0.434, "Kal'methir water edge"),
        C(0.756, 0.457, "Drowned Market water"),
    },
    confidence = "high",
}

local MECHAGON_MINNOW_ROUTE = {
    id = "bfa-mechagon-ionized-minnow-route",
    source = "Retail Wowhead BFA Fishing guide, wow-professions BFA Fishing guide, and Wowhead Ionized Minnow item page",
    sourceUrls = {
        "https://www.wowhead.com/guide/bfa-fishing",
        "https://www.wow-professions.com/guides/zandalari-kul-tiran-bfa-fishing-leveling-guide",
        "https://www.wowhead.com/item=167562/ionized-minnow",
    },
    mapName = "Mechagon Island",
    location = "Mechagon shore route for Ionized Minnow",
    routeType = "zone-fishing",
    density = "Limited",
    dropDifficulty = "Patch 8.2 Mechagon fishing reagent; use shoreline casts while doing Mechagon circuits.",
    tips = {
        "Ionized Minnow is a Mechagon fishing target, not a general Kul Tiras/Zandalar fish.",
        "Use this route as a side pass while crossing Mechagon for ore, chests, or daily work.",
    },
    coords = {
        C(0.730, 0.380, "Eastern Mechagon shoreline"),
        C(0.684, 0.556, "Southeast shore"),
        C(0.524, 0.706, "Southern shore"),
        C(0.344, 0.650, "Southwest junkyard water"),
        C(0.250, 0.540, "Western shore return"),
    },
    confidence = "medium",
}

local ULDUM_CORRUPTED_FISHING_ROUTE = {
    id = "bfa-uldum-malformed-gnasher-corrupted-water-route",
    source = "Retail Wowhead BFA Fishing guide, Wowhead Malformed Gnasher comments, and Questionable Meat comment coordinate reports",
    sourceUrls = {
        "https://www.wowhead.com/guide/bfa-fishing",
        "https://www.wowhead.com/item=174327/malformed-gnasher",
        "https://www.wowhead.com/item=174353/questionable-meat",
    },
    mapName = "Uldum",
    location = "Patch 8.3 Uldum assault water and Cursed Landing route",
    routeType = "corrupted-fishing",
    density = "Medium during 8.3 assault content",
    dropDifficulty = "Patch 8.3 corrupted fish route. Uldum is strongest for Malformed Gnasher, with Voidfin as a side catch.",
    tips = {
        "Wowhead comments call out Cursed Landing around 84,58 and a northern Uldum fishing/meat setup around 30.8,13.6.",
        "Use this route when Uldum assaults are active or when Malformed Gnasher is the target.",
        "Nearby crocolisks can feed Questionable Meat farming while you fish.",
    },
    coords = {
        C(0.840, 0.580, "Cursed Landing Gnasher report"),
        C(0.308, 0.136, "Northern Uldum fishing and crocolisk setup"),
        C(0.298, 0.157, "Northern Uldum catch-ratio report"),
    },
    confidence = "high",
}

local VALE_CORRUPTED_FISHING_ROUTE = {
    id = "bfa-vale-aberrant-voidfin-corrupted-water-route",
    source = "Retail Wowhead BFA Fishing guide and Wowhead Malformed Gnasher/Aberrant Voidfin comment coordinates",
    sourceUrls = {
        "https://www.wowhead.com/guide/bfa-fishing",
        "https://www.wowhead.com/item=174328/aberrant-voidfin",
        "https://www.wowhead.com/item=174327/malformed-gnasher",
    },
    mapName = "Vale of Eternal Blossoms",
    location = "Patch 8.3 Vale corrupted-water fishing route",
    routeType = "corrupted-fishing",
    density = "Medium during 8.3 assault content",
    dropDifficulty = "Patch 8.3 corrupted fish route. Vale is strongest for Aberrant Voidfin, with Gnasher as a side catch.",
    tips = {
        "Wowhead comments report productive Voidfin fishing around 72,58 and 72,56.8 in the Vale.",
        "Open-water fishing works; do not wait only for pool spawns.",
        "Use Uldum instead when Malformed Gnasher is the primary target.",
    },
    coords = {
        C(0.720, 0.580, "Vale Voidfin report"),
        C(0.720, 0.568, "Vale catch-ratio report"),
        C(0.730, 0.610, "Vale corrupted water sweep"),
    },
    confidence = "high",
}

local function RegisterFish(itemID, itemName, spots, summary)
    Register({
        itemID = itemID,
        itemName = itemName,
        expansion = "battleForAzeroth",
        professions = { "fishing", "cooking" },
        category = "Fish",
        sourceUrls = { ItemUrl(itemID) },
        summary = summary,
        spots = spots,
    })
end

local function RegisterFishOil(itemID, itemName, spots, summary)
    Register({
        itemID = itemID,
        itemName = itemName,
        expansion = "battleForAzeroth",
        professions = { "fishing", "cooking" },
        category = "Fish Oil",
        sourceUrls = { ItemUrl(itemID) },
        summary = summary,
        spots = spots,
    })
end

RegisterFish(152543, "Sand Shifter", { ZANDALAR_COASTAL_ROUTE }, "Zandalar coastal BFA fish.")
RegisterFish(152544, "Slimy Mackerel", { ZANDALAR_COASTAL_ROUTE }, "Zandalar coastal BFA fish.")
RegisterFish(152545, "Frenzied Fangtooth", { KUL_TIRAS_COASTAL_ROUTE }, "Kul Tiras coastal BFA fish.")
RegisterFish(152546, "Lane Snapper", { KUL_TIRAS_COASTAL_ROUTE }, "Kul Tiras coastal BFA fish.")
RegisterFish(152547, "Great Sea Catfish", {
    KUL_TIRAS_INLAND_ROUTE,
    ZANDALAR_INLAND_ROUTE,
}, "BFA inland-water fish found from both Kul Tiras and Zandalar inland routes.")
RegisterFish(152548, "Tiragarde Perch", { KUL_TIRAS_INLAND_ROUTE }, "Kul Tiras inland-water fish.")
RegisterFish(152549, "Redtail Loach", { ZANDALAR_INLAND_ROUTE }, "Zandalar inland-water fish.")
RegisterFishOil(160711, "Aromatic Fish Oil", {
    KUL_TIRAS_COASTAL_ROUTE,
    ZANDALAR_COASTAL_ROUTE,
    KUL_TIRAS_INLAND_ROUTE,
    ZANDALAR_INLAND_ROUTE,
}, "BFA cooking reagent obtained by processing common BFA fish from coastal and inland fishing routes.")
RegisterFish(162515, "Midnight Salmon", {
    BFA_RARE_SALMON_ROUTE,
    KUL_TIRAS_INLAND_ROUTE,
    ZANDALAR_INLAND_ROUTE,
}, "Rare BFA fish from Kul Tiras and Zandalar waters; best treated as bonus value while fishing profitable common routes.")
RegisterFish(167562, "Ionized Minnow", {
    MECHAGON_MINNOW_ROUTE,
}, "Patch 8.2 Mechagon fishing reagent from Mechagon Island water.")
RegisterFish(168302, "Viper Fish", {
    NAZJATAR_FISHING_ROUTE,
}, "Patch 8.2 Nazjatar fish from Nazjatar water and pools.")
RegisterFish(168646, "Mauve Stinger", {
    NAZJATAR_FISHING_ROUTE,
}, "Patch 8.2 Nazjatar fish from Nazjatar water and Mauve Stinger pools.")
RegisterFish(174327, "Malformed Gnasher", {
    ULDUM_CORRUPTED_FISHING_ROUTE,
    VALE_CORRUPTED_FISHING_ROUTE,
}, "Patch 8.3 corrupted fish, strongest from Uldum assault water with Vale as a side route.")
RegisterFish(174328, "Aberrant Voidfin", {
    VALE_CORRUPTED_FISHING_ROUTE,
    ULDUM_CORRUPTED_FISHING_ROUTE,
}, "Patch 8.3 corrupted fish, strongest from Vale assault water with Uldum as a side route.")
