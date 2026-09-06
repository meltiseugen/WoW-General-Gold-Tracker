local _, NS = ...
local Register = NS.RegisterMaterialFarmingSpot

local function C(x, y, label)
    return { x = x, y = y, label = label }
end

local function ItemUrl(itemID)
    return "https://www.wowhead.com/item=" .. tostring(itemID)
end

local WAKING_SHORES_BASILISK_EGG_ROUTE = {
    id = "dragonflight-waking-shores-skytop-basilisk-eggs",
    source = "Wowhead Basilisk Eggs comments, Artisans of Azeroth Basilisk Egg route, Wowhead Stalking Basilisk NPC map pins",
    sourceUrls = {
        "https://www.wowhead.com/item=197745/basilisk-eggs",
        "https://artisansofazeroth.com/basilisk-egg-farm-world-of-warcraft-dragonflight-gold-guide/",
        "https://www.wowhead.com/npc=191695/stalking-basilisk",
    },
    mapName = "The Waking Shores",
    location = "Skytop Observatory west shore and southern basilisk island",
    routeType = "beast-meat-farm",
    density = "Medium",
    dropDifficulty = "Easy basilisk loop for Basilisk Eggs with Maybe Meat as side value.",
    tips = {
        "Use the 67.79, 50.42 cluster west of Skytop Observatory as the main loop.",
        "Extend to the 74.42, 67.95 island cluster when respawns are slow.",
        "Kill Stalking and Mature Basilisks rather than roaming into sparse mixed-beast packs.",
    },
    coords = {
        C(0.674, 0.504, "Skytop west Stalking Basilisks"),
        C(0.676, 0.506, "Skytop shore center"),
        C(0.688, 0.526, "Skytop shore south"),
        C(0.7442, 0.6795, "Southern island basilisk camp"),
        C(0.746, 0.674, "Southern island north"),
    },
    confidence = "high",
}

local WAKING_SHORES_RIVER_HORNSWOG_ROUTE = {
    id = "dragonflight-waking-shores-river-hornswog-hunk-route",
    source = "Wowhead Hornswog Hunk item data and River Hornswog NPC map pins",
    sourceUrls = {
        "https://www.wowhead.com/item=197744/hornswog-hunk",
        "https://www.wowhead.com/npc=191618/river-hornswog",
    },
    mapName = "The Waking Shores",
    location = "Dragonheart Outpost river and eastern shore hornswog clusters",
    routeType = "beast-meat-farm",
    density = "Medium",
    dropDifficulty = "Easy. River Hornswogs are narrow, map-pin-backed sources for Hornswog Hunk.",
    tips = {
        "Start on the Dragonheart Outpost river pins, then sweep east along the shore.",
        "Kill hornswogs as a targeted farm instead of listing every lunker or rare source.",
        "Add nearby basilisks only if Maybe Meat or eggs are also valuable.",
    },
    coords = {
        C(0.524, 0.526, "River Hornswog west bank"),
        C(0.536, 0.510, "River Hornswog north bank"),
        C(0.580, 0.626, "River Hornswog south bend"),
        C(0.638, 0.408, "Eastern shore north"),
        C(0.662, 0.430, "Eastern shore center"),
        C(0.678, 0.484, "Eastern shore south"),
    },
    confidence = "high",
}

local OHNAHRAN_FORKRIVER_BRUFFALON_ROUTE = {
    id = "dragonflight-ohnahran-forkriver-bruffalon-flank-route",
    source = "Wowhead Bruffalon Flank comments and Forkriver Pinehoof NPC map pins",
    sourceUrls = {
        "https://www.wowhead.com/item=197746/bruffalon-flank",
        "https://www.wowhead.com/npc=193739/forkriver-pinehoof",
    },
    mapName = "Ohn'ahran Plains",
    location = "Forkriver Crossing southeast bruffalon arc",
    routeType = "beast-meat-farm",
    density = "High",
    dropDifficulty = "Easy to moderate. Wide bruffalon arc with neutral and hostile packs.",
    tips = {
        "Sweep the outside edge around Forkriver Crossing to keep bruffalon respawns cycling.",
        "Add bulls and calves in the same area when Pinehoof packs thin out.",
        "Good route when Maybe Meat and Bruffalon Flank both have value.",
    },
    coords = {
        C(0.712, 0.844, "Forkriver Pinehoof west arc"),
        C(0.714, 0.856, "Forkriver Pinehoof west river"),
        C(0.744, 0.808, "Forkriver Pinehoof north-east"),
        C(0.748, 0.870, "Forkriver Pinehoof east arc"),
        C(0.752, 0.848, "Forkriver Pinehoof center"),
        C(0.766, 0.866, "Forkriver Pinehoof south-east"),
    },
    confidence = "high",
}

local OHNAHRAN_MAMMOTH_RIBS_ROUTE = {
    id = "dragonflight-ohnahran-waterhole-mosshair-mammoth-ribs",
    source = "Wowhead Mighty Mammoth Ribs comments plus Mosshair Mammoth and Mosshair Bull NPC map pins",
    sourceUrls = {
        "https://www.wowhead.com/item=197747/mighty-mammoth-ribs",
        "https://www.wowhead.com/npc=193395/mosshair-mammoth",
        "https://www.wowhead.com/npc=193394/mosshair-bull",
    },
    mapName = "Ohn'ahran Plains",
    location = "The Watering Hole southeast of Maruukai",
    routeType = "beast-meat-farm",
    density = "High",
    dropDifficulty = "Moderate. Some mammoths are elite or grouped; strong cleave helps.",
    tips = {
        "Use the 72.13, 50.31 comment waypoint as the center of the route.",
        "Clear both Mosshair Mammoths and Mosshair Bulls for steady rib drops.",
        "Stay near the waterhole rather than chasing sparse mammoths across the plains.",
    },
    coords = {
        C(0.7213, 0.5031, "The Watering Hole center"),
        C(0.704, 0.518, "Mosshair Mammoth west"),
        C(0.724, 0.524, "Mosshair Mammoth south"),
        C(0.744, 0.498, "Mosshair Mammoth east"),
        C(0.734, 0.474, "Mosshair Bull north"),
        C(0.756, 0.522, "Mosshair Bull east"),
    },
    confidence = "high",
}

local AZURE_SPAN_FRIGIDPELT_BEAR_ROUTE = {
    id = "dragonflight-azure-span-frigidpelt-bear-haunch-spine",
    source = "Wowhead Primal Bear Spine and Burly Bear Haunch comments, Artisans of Azeroth Primal Bear Spine route, Frigidpelt NPC map pins",
    sourceUrls = {
        "https://www.wowhead.com/item=201399/primal-bear-spine",
        "https://www.wowhead.com/item=197748/burly-bear-haunch",
        "https://artisansofazeroth.com/where-to-farm-resilient-leather-wow-dragonflight-gold-guide/",
        "https://www.wowhead.com/npc=193063/frigidpelt-matriarch",
        "https://www.wowhead.com/npc=193062/prowling-frigidpelt",
        "https://www.wowhead.com/npc=195743/roaming-frigidpelt",
    },
    mapName = "The Azure Span",
    location = "Upper Frostlands Frigidpelt bear cave and nearby roaming bear route",
    routeType = "beast-meat-farm",
    density = "Medium",
    dropDifficulty = "Moderate. Primal Bear Spine is a narrow, lower-frequency drop from bear sources.",
    tips = {
        "Use the 63.91, 29.77 and 64.42, 30.20 bear cave waypoints as the main reset point.",
        "Kill Prowling Frigidpelts and Frigidpelt Matriarchs around the cave for spine and haunch chances.",
        "Extend to roaming Frigidpelts only when the cave loop is exhausted.",
    },
    coords = {
        C(0.6391, 0.2977, "Frigidpelt bear cave route"),
        C(0.6442, 0.3020, "Frigidpelt cave comment waypoint"),
        C(0.626, 0.308, "Frigidpelt Matriarch west"),
        C(0.632, 0.316, "Prowling Frigidpelt cave center"),
        C(0.646, 0.302, "Frigidpelt cave east"),
        C(0.136, 0.544, "Roaming Frigidpelt extension"),
    },
    confidence = "high",
}

local AZURE_SPAN_SHORTCOAT_BEAR_ROUTE = {
    id = "dragonflight-azure-span-parched-shortcoat-bear-haunch-route",
    source = "Wowhead Burly Bear Haunch item page and Parched Shortcoat Bear NPC map pins",
    sourceUrls = {
        "https://www.wowhead.com/item=197748/burly-bear-haunch",
        "https://www.wowhead.com/npc=195247/parched-shortcoat-bear",
    },
    mapName = "The Azure Span",
    location = "Parched Shortcoat Bear pack east of Brackenhide",
    routeType = "beast-meat-farm",
    density = "Localized",
    dropDifficulty = "Easy localized Burly Bear Haunch route with Maybe Meat side drops.",
    tips = {
        "Use this compact bear pack when the Frigidpelt cave is contested.",
        "Reset around the 65.6, 54.8 pin cluster.",
        "Skinning adds extra value but is not required for the meat drops.",
    },
    coords = {
        C(0.652, 0.544, "Parched Shortcoat Bear west"),
        C(0.656, 0.540, "Parched Shortcoat Bear north"),
        C(0.656, 0.548, "Parched Shortcoat Bear south"),
        C(0.666, 0.544, "Parched Shortcoat Bear east"),
        C(0.666, 0.546, "Parched Shortcoat Bear east-south"),
    },
    confidence = "high",
}

local WAKING_SHORES_LAVA_PHOENIX_MEAT_ROUTE = {
    id = "dragonflight-waking-shores-lava-phoenix-maybe-meat-route",
    source = "Wowhead Maybe Meat item page and Lava Phoenix NPC map pins",
    sourceUrls = {
        "https://www.wowhead.com/item=197741/maybe-meat",
        "https://www.wowhead.com/npc=181764/lava-phoenix",
    },
    mapName = "The Waking Shores",
    location = "Lava Phoenix packs around Obsidian Citadel lava flows",
    routeType = "beast-meat-farm",
    density = "Medium",
    dropDifficulty = "Moderate. Flying or spread targets can slow melee-heavy characters.",
    tips = {
        "Use this as a confirmed Maybe Meat route when mixed-beast farms are crowded.",
        "Sweep between the 41.4, 55.4 and 45.6, 56.8 lava pins.",
        "Add nearby basilisks if Basilisk Eggs also have value.",
    },
    coords = {
        C(0.414, 0.554, "Lava Phoenix west"),
        C(0.428, 0.582, "Lava Phoenix south-west"),
        C(0.438, 0.552, "Lava Phoenix center"),
        C(0.446, 0.546, "Lava Phoenix east"),
        C(0.456, 0.568, "Lava Phoenix southeast"),
    },
    confidence = "high",
}

local OHNAHRAN_POTATO_VENDOR_ROUTE = {
    id = "dragonflight-ohnahran-potato-vendors",
    source = "Wowhead Ohn'ahran Potato vendor comments",
    sourceUrls = {
        "https://www.wowhead.com/item=197749/ohnahran-potato",
    },
    mapName = "Dragon Isles",
    location = "Cooking ingredient vendors in Maruukai, Forkriver Crossing, Valdrakken, and Loamm",
    routeType = "vendor-purchase",
    density = "Vendor",
    dropDifficulty = "Direct purchase. No mob or node farm is needed.",
    tips = {
        "Buy from Windsage Oohr in Maruukai when farming Ohn'ahran Plains materials.",
        "Use Windsage Asuta at Forkriver Crossing while farming Bruffalon Flank nearby.",
        "Valdrakken and Loamm vendors are convenient restock points between farms.",
    },
    coords = {
        C(0.6192, 0.3580, "Maruukai Windsage Oohr"),
        C(0.7150, 0.8070, "Forkriver Crossing Windsage Asuta"),
        C(0.4600, 0.4600, "Valdrakken Erugosa"),
        C(0.5680, 0.5620, "Loamm Phiary"),
    },
    confidence = "high",
}

local function RegisterMeat(itemID, itemName, spots, summary)
    Register({
        itemID = itemID,
        itemName = itemName,
        expansion = "dragonflight",
        professions = { "cooking" },
        category = "Meat",
        sourceUrls = { ItemUrl(itemID) },
        summary = summary,
        spots = spots,
    })
end

RegisterMeat(197741, "Maybe Meat", {
    WAKING_SHORES_LAVA_PHOENIX_MEAT_ROUTE,
    WAKING_SHORES_BASILISK_EGG_ROUTE,
    OHNAHRAN_FORKRIVER_BRUFFALON_ROUTE,
}, "General Dragonflight meat from many creatures; these are coordinate-backed dense source clusters.")

RegisterMeat(197744, "Hornswog Hunk", {
    WAKING_SHORES_RIVER_HORNSWOG_ROUTE,
}, "Dragonflight meat from hornswog sources, using River Hornswog NPC pins as the narrow farm.")

RegisterMeat(197745, "Basilisk Eggs", {
    WAKING_SHORES_BASILISK_EGG_ROUTE,
}, "Dragonflight cooking material from basilisk sources around Skytop Observatory and the southern Waking Shores island.")

RegisterMeat(197746, "Bruffalon Flank", {
    OHNAHRAN_FORKRIVER_BRUFFALON_ROUTE,
}, "Dragonflight cooking material from bruffalon sources around Forkriver Crossing.")

RegisterMeat(197747, "Mighty Mammoth Ribs", {
    OHNAHRAN_MAMMOTH_RIBS_ROUTE,
}, "Dragonflight cooking material from Mosshair mammoth and bull packs at The Watering Hole.")

RegisterMeat(197748, "Burly Bear Haunch", {
    AZURE_SPAN_FRIGIDPELT_BEAR_ROUTE,
    AZURE_SPAN_SHORTCOAT_BEAR_ROUTE,
}, "Dragonflight cooking material from bear sources, with Frigidpelt and Shortcoat clusters as pinned farms.")

RegisterMeat(197749, "Ohn'ahran Potato", {
    OHNAHRAN_POTATO_VENDOR_ROUTE,
}, "Dragonflight cooking vendor ingredient; use direct purchase waypoints instead of mob-farm placeholders.")

RegisterMeat(201399, "Primal Bear Spine", {
    AZURE_SPAN_FRIGIDPELT_BEAR_ROUTE,
}, "Narrow Dragonflight bear drop from Frigidpelt bear clusters in the Upper Frostlands.")
