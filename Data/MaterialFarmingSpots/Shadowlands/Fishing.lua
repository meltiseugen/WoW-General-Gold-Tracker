local _, NS = ...
local Register = NS.RegisterMaterialFarmingSpot

local function C(x, y, label)
    return { x = x, y = y, label = label }
end

local function ItemUrl(itemID)
    return "https://www.wowhead.com/item=" .. tostring(itemID)
end

local BASTION_FISHING_ROUTE = {
    id = "shadowlands-bastion-silvergill-safe-fishing",
    source = "Wowhead Shadowlands fishing guide and wow-professions fishing guide",
    sourceUrls = {
        "https://www.wowhead.com/guide/shadowlands-fishing-profession",
        "https://www.wow-professions.com/guides/shadowlands-fishing-leveling-guide",
    },
    mapName = "Bastion",
    location = "Purity's Reflection and Shimmering Pools safe fishing spots",
    routeType = "fishing-spots",
    density = "Steady",
    dropDifficulty = "Easy. Safe water spots with low hostile pressure.",
    tips = {
        "Use Silvergill Pike bait when specifically targeting Bastion fish.",
        "Move between Purity's Reflection and Shimmering Pools if pools are exhausted.",
        "Lost Sole and Elysian Thade are possible side catches.",
    },
    coords = {
        C(0.530, 0.730, "Purity's Reflection"),
        C(0.420, 0.320, "Shimmering Pools"),
    },
    confidence = "high",
}

local MALDRAXXUS_FISHING_ROUTE = {
    id = "shadowlands-maldraxxus-pocked-bonefish-safe-fishing",
    source = "Wowhead Shadowlands fishing guide and wow-professions fishing guide",
    sourceUrls = {
        "https://www.wowhead.com/guide/shadowlands-fishing-profession",
        "https://www.wow-professions.com/guides/shadowlands-fishing-leveling-guide",
    },
    mapName = "Maldraxxus",
    location = "Theater of Pain and House of Plagues safe fishing water",
    routeType = "fishing-spots",
    density = "Steady",
    dropDifficulty = "Easy to moderate. Some Maldraxxus water is unsafe or awkward, so use confirmed spots.",
    tips = {
        "Use Pocked Bonefish bait when target-fishing Maldraxxus.",
        "Theater of Pain is the safer quick check.",
        "Avoid pools that apply plague-area debuffs or are too shallow to cast.",
    },
    coords = {
        C(0.500, 0.530, "Theater of Pain water"),
        C(0.580, 0.760, "House of Plagues pool"),
    },
    confidence = "high",
}

local ARDENWEALD_FISHING_ROUTE = {
    id = "shadowlands-ardenweald-amberjack-tirna-vaal-fishing",
    source = "Wowhead Shadowlands fishing guide and fishing comments",
    sourceUrls = {
        "https://www.wowhead.com/guide/shadowlands-fishing-profession",
        "https://www.wow-professions.com/guides/shadowlands-fishing-leveling-guide",
    },
    mapName = "Ardenweald",
    location = "Tirna Vaal and central Ardenweald water",
    routeType = "fishing-spots",
    density = "Steady",
    dropDifficulty = "Easy. Tirna Vaal is a relaxed low-pressure fishing spot.",
    tips = {
        "Use Iridescent Amberjack bait when targeting Ardenweald fish.",
        "A fishing comment calls out Tirna Vaal as a restful fishing location.",
        "Check nearby central water if Tirna Vaal is crowded.",
    },
    coords = {
        C(0.630, 0.360, "Tirna Vaal water"),
        C(0.566, 0.492, "Central Ardenweald water"),
        C(0.486, 0.578, "Heartwood Grove water edge"),
    },
    confidence = "medium",
}

local REVENDRETH_FISHING_ROUTE = {
    id = "shadowlands-revendreth-spinefin-safe-fishing",
    source = "Wowhead Shadowlands fishing guide, fishing comments, and Revendreth safe fishing reports",
    sourceUrls = {
        "https://www.wowhead.com/guide/shadowlands-fishing-profession",
        "https://www.reddit.com/r/wow/comments/k9fluj/revendreth_safe_fishing_spot/",
        "https://www.wow-professions.com/guides/shadowlands-fishing-leveling-guide",
    },
    mapName = "Revendreth",
    location = "Sanctuary of the Mad pond, Night Market pond, and Blistering Bog piranha checks",
    routeType = "fishing-spots",
    density = "Steady",
    dropDifficulty = "Easy to moderate. Use safe ponds to avoid Revendreth mob density and shallow water.",
    tips = {
        "Use Spinefin Piranha bait when targeting Revendreth fish.",
        "Night Market and Sanctuary-side ponds are safer than many shallow pools.",
        "The Blistering Bog can work, but watch for shallow casts.",
    },
    coords = {
        C(0.290, 0.450, "Sanctuary of the Mad pond"),
        C(0.508, 0.781, "Night Market pond"),
        C(0.370, 0.300, "Blistering Bog piranha pools"),
        C(0.497, 0.180, "Old Gate safe pool"),
    },
    confidence = "high",
}

local ZERETH_MORTIS_PLACODERM_ROUTE = {
    id = "shadowlands-zereth-mortis-precursor-placoderm-fishing",
    source = "Retail Wowhead Precursor Placoderm item page, Patch 9.2 profession guide, and Zereth Mortis fishing comments",
    sourceUrls = {
        "https://www.wowhead.com/item=187702/precursor-placoderm",
        "https://www.wowhead.com/guide/profession-updates-patch-9-2-vestige-of-the-eternal",
        "https://www.wowhead.com/guide/profession-changes-patch-92-eternitys-end-shadowlands",
        "https://www.wowhead.com/npc=179006/akkaris",
    },
    mapName = "Zereth Mortis",
    location = "Haven cave, Dimensional Falls, and nearby Zereth Mortis waters",
    routeType = "fishing-spots",
    density = "Steady open-water fishing",
    dropDifficulty = "Easy. Precursor Placoderm can be fished from Zereth Mortis water and pools; use safe water first.",
    tips = {
        "Start at the Haven cave pool because a retail item comment gives an exact safe waypoint there.",
        "Dimensional Falls is a useful second stop and overlaps Hirukon/Strange Goop fishing traffic.",
        "Lost Sole and Elysian Thade can be tracked as side catches in the same waters.",
    },
    coords = {
        C(0.3301, 0.6963, "Haven cave pool by the Oribos Waystone"),
        C(0.518, 0.745, "Dimensional Falls Hirukon lake"),
        C(0.522, 0.744, "Dimensional Falls water return"),
        C(0.500, 0.705, "Southern lake edge"),
    },
    confidence = "high",
}

local function RegisterFish(itemID, itemName, spots, summary)
    Register({
        itemID = itemID,
        itemName = itemName,
        expansion = "shadowlands",
        professions = { "fishing", "cooking" },
        category = "Fish",
        sourceUrls = { ItemUrl(itemID) },
        summary = summary,
        spots = spots,
    })
end

RegisterFish(173032, "Lost Sole", {
    BASTION_FISHING_ROUTE,
    MALDRAXXUS_FISHING_ROUTE,
    ARDENWEALD_FISHING_ROUTE,
    REVENDRETH_FISHING_ROUTE,
    ZERETH_MORTIS_PLACODERM_ROUTE,
}, "Common Shadowlands fish from all four covenant zones.")
RegisterFish(173033, "Iridescent Amberjack", { ARDENWEALD_FISHING_ROUTE }, "Ardenweald zone fish.")
RegisterFish(173034, "Silvergill Pike", { BASTION_FISHING_ROUTE }, "Bastion zone fish.")
RegisterFish(173035, "Pocked Bonefish", { MALDRAXXUS_FISHING_ROUTE }, "Maldraxxus zone fish.")
RegisterFish(173036, "Spinefin Piranha", { REVENDRETH_FISHING_ROUTE }, "Revendreth zone fish.")
RegisterFish(173037, "Elysian Thade", {
    BASTION_FISHING_ROUTE,
    MALDRAXXUS_FISHING_ROUTE,
    ARDENWEALD_FISHING_ROUTE,
    REVENDRETH_FISHING_ROUTE,
    ZERETH_MORTIS_PLACODERM_ROUTE,
}, "Rare Shadowlands fish from all four covenant zones; best treated as a bonus while farming zone fish.")
RegisterFish(187702, "Precursor Placoderm", { ZERETH_MORTIS_PLACODERM_ROUTE },
    "Patch 9.2 Zereth Mortis fish from open water and pools.")
