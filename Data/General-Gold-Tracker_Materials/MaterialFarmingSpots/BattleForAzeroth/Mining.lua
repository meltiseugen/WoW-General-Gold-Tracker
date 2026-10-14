local _, NS = ...
local Register = NS.RegisterMaterialFarmingSpot
local H = NS.MaterialFarmingSpotHelpers

local function C(x, y, label)
    return { x = x, y = y, label = label }
end

local function ItemUrl(itemID)
    return "https://www.wowhead.com/item=" .. tostring(itemID)
end

local BFA_ORE_SOURCE_URLS = {
    "https://www.wow-professions.com/farming/monelite-ore-farming",
    "https://www.wow-professions.com/farming/storm-silver-ore-farming",
    "https://www.wow-professions.com/farming/platinum-ore-farming",
    "https://www.wowhead.com/guide/battle-for-azeroth-1-175-mining-profession-guide-patch-8-3-6293",
    "https://xscarlife-gaming.com/farming-retail/",
}

local TIRAGARDE_ORE_ROUTE = {
    id = "bfa-tiragarde-south-monelite-storm-silver-route",
    source = "wow-professions ore guides, retail Wowhead BFA mining guide, and sampled xScarlife retail Routes import pins",
    sourceUrls = BFA_ORE_SOURCE_URLS,
    mapName = "Tiragarde Sound",
    location = "Southern Tiragarde ore loop through Freehold cliffs, river edges, and Norwington return",
    routeType = "mining-loop",
    density = "High",
    dropDifficulty = "Good mixed BFA ore loop. Platinum is rare and Storm Silver is a Monelite respawn outcome.",
    tips = H.withBfaGatheringTips({
        "Mine every Monelite node because Storm Silver and Platinum depend on respawn rolls.",
        "This route is sampled from retail Routes import coordinates and kept dense enough for a later map overlay.",
        "Use this as the steady Monelite route and treat Storm Silver and Platinum as route bonuses.",
    }),
    coords = {
        C(0.7638, 0.5083, "AoA/xScarlife south Tiragarde ore pin"),
        C(0.7872, 0.5944, "AoA/xScarlife southeast ridge pin"),
        C(0.7673, 0.6355, "AoA/xScarlife Freehold cliff pin"),
        C(0.7342, 0.6270, "AoA/xScarlife south road pin"),
        C(0.7069, 0.6195, "AoA/xScarlife river-edge ore pin"),
        C(0.6796, 0.6119, "AoA/xScarlife inland return pin"),
        C(0.6447, 0.6344, "AoA/xScarlife west ridge pin"),
        C(0.6161, 0.6274, "AoA/xScarlife central south pin"),
        C(0.5874, 0.6203, "AoA/xScarlife west return pin"),
        C(0.5301, 0.6061, "AoA/xScarlife western loop pin"),
        C(0.5410, 0.5503, "AoA/xScarlife north bend pin"),
        C(0.5758, 0.5585, "AoA/xScarlife central ridge pin"),
        C(0.5882, 0.5965, "AoA/xScarlife route reconnect"),
        C(0.6001, 0.4859, "AoA/xScarlife northern spur"),
        C(0.6384, 0.5059, "AoA/xScarlife northeast return"),
        C(0.6767, 0.5258, "AoA/xScarlife east route pin"),
        C(0.7071, 0.4815, "AoA/xScarlife high ridge pin"),
        C(0.7354, 0.4949, "AoA/xScarlife route close"),
    },
    confidence = "high",
}

local NAZMIR_ORE_ROUTE = {
    id = "bfa-nazmir-ore-loop",
    source = "wow-professions Storm Silver guide and BFA mining route guides",
    sourceUrls = {
        "https://www.wow-professions.com/farming/storm-silver-ore-farming",
        "https://www.wow-professions.com/farming/platinum-ore-farming",
        "https://en.guiaswow.com/game-guide/Mining-guide-in-battle-for-azeroth-best-farming-routes.html",
    },
    mapName = "Nazmir",
    location = "Nazmir swamp and ridge mining loop",
    routeType = "mining-loop",
    density = "Medium",
    dropDifficulty = "Good route, but water and uneven terrain slow ground-only farming.",
    tips = H.withBfaGatheringTips({
        "Clear every ore node because rare ore replaces common ore on respawn.",
        "Waterwalking helps through the central swamp sections.",
        "Use this route when Tiragarde and Stormsong are crowded.",
    }),
    coords = {
        C(0.338, 0.424, "Western Nazmir ridge"),
        C(0.444, 0.318, "Northern swamp edge"),
        C(0.572, 0.352, "Eastern ridge ore"),
        C(0.638, 0.520, "Central return"),
        C(0.504, 0.662, "Southern swamp ore"),
    },
    confidence = "medium",
}

local STORMSONG_ORE_ROUTE = {
    id = "bfa-stormsong-valley-storm-silver-route",
    source = "wow-professions ore guides, retail Wowhead BFA mining guide, and sampled xScarlife retail Routes import pins",
    sourceUrls = BFA_ORE_SOURCE_URLS,
    mapName = "Stormsong Valley",
    location = "Stormsong Valley cliff and coastline ore loop",
    routeType = "mining-loop",
    density = "Medium to high",
    dropDifficulty = "Good Storm Silver target route with some vertical travel.",
    tips = H.withBfaGatheringTips({
        "Stormsong is useful when Storm Silver is the target price.",
        "Follow cliffs and coastlines; do not ignore Monelite while hunting rare ore.",
        "This denser loop is route-overlay ready and can be simplified later by the map UI.",
    }),
    coords = {
        C(0.4421, 0.4955, "AoA/xScarlife western Stormsong ore pin"),
        C(0.4860, 0.5266, "AoA/xScarlife lower valley pin"),
        C(0.5303, 0.5319, "AoA/xScarlife central bend"),
        C(0.5258, 0.5635, "AoA/xScarlife river cliff pin"),
        C(0.5086, 0.5901, "AoA/xScarlife south-central pin"),
        C(0.5557, 0.6143, "AoA/xScarlife ridge route pin"),
        C(0.6081, 0.6419, "AoA/xScarlife east ridge pin"),
        C(0.6669, 0.6518, "AoA/xScarlife eastern valley pin"),
        C(0.7216, 0.6553, "AoA/xScarlife coast approach"),
        C(0.7515, 0.6941, "AoA/xScarlife southeast coast pin"),
        C(0.7052, 0.7412, "AoA/xScarlife southern turn"),
        C(0.6421, 0.7581, "AoA/xScarlife south return"),
        C(0.5932, 0.7374, "AoA/xScarlife southwest ridge"),
        C(0.5004, 0.7610, "AoA/xScarlife west return"),
        C(0.4917, 0.7076, "AoA/xScarlife western valley pin"),
        C(0.4585, 0.6605, "AoA/xScarlife northwest return"),
        C(0.3595, 0.6103, "AoA/xScarlife west extension"),
        C(0.3760, 0.5415, "AoA/xScarlife northwestern bend"),
        C(0.3990, 0.5090, "AoA/xScarlife route close"),
    },
    confidence = "high",
}

local MECHAGON_ORE_ROUTE = {
    id = "bfa-mechagon-ore-and-chest-loop",
    source = "Wowhead Monelite comments and Mechagon mining notes",
    sourceUrls = {
        "https://www.wowhead.com/item=152512/monelite-ore",
        "https://www.wowhead.com/item=152579/storm-silver-ore",
        "https://www.wowhead.com/guide/comprehensive-mechagon-guide",
    },
    mapName = "Mechagon Island",
    location = "Mechagon Anti-Gravity Pack ore and chest loop",
    routeType = "mining-loop",
    density = "Medium",
    dropDifficulty = "Strong when the Anti-Gravity Pack is available; slower without it.",
    tips = H.withBfaGatheringTips({
        "A Wowhead comment highlights Mechagon mining with Anti-Gravity Pack as very efficient.",
        "Open Mechanized Chests while moving between ore nodes.",
        "Use this as a mixed Monelite, Storm Silver, and Platinum route.",
    }),
    coords = {
        C(0.250, 0.540, "Western junkyard ore"),
        C(0.356, 0.382, "Central ridge"),
        C(0.522, 0.300, "Northern depot ore"),
        C(0.662, 0.482, "Eastern return"),
        C(0.548, 0.706, "Southern cliff ore"),
    },
    confidence = "medium",
}

local OSMENITE_NAZJATAR_ROUTE = {
    id = "bfa-nazjatar-osmenite-zinanthid-route",
    source = "wow-professions Osmenite guide, Wowhead item page, and sampled xScarlife retail Routes import pins",
    sourceUrls = {
        "https://www.wow-professions.com/farming/osmenite-ore-farming",
        "https://www.wowhead.com/item=168185/osmenite-ore",
        "https://www.wowhead.com/guide/battle-for-azeroth-1-175-mining-profession-guide-patch-8-3-6293",
        "https://xscarlife-gaming.com/farming-retail/",
    },
    mapName = "Nazjatar",
    location = "Nazjatar ore route through Coral Forest, Kal'methir, Hanging Reef, and the Drowned Market",
    routeType = "mining-loop",
    density = "High",
    dropDifficulty = "Good patch 8.2 route, but mob density makes mounted gathering support valuable.",
    tips = H.withBfaGatheringTips({
        "Pair Osmenite with Zin'anthid whenever both are valuable.",
        "Use the Coral Forest and Kal'methir pins as the core route, then extend through Hanging Reef.",
        "These pins are intentionally dense because Osmenite routes are useful input for BFA prospecting data.",
    }),
    coords = {
        C(0.4002, 0.1549, "AoA/xScarlife northwestern Nazjatar pin"),
        C(0.4487, 0.2686, "AoA/xScarlife northern rise"),
        C(0.4733, 0.2990, "AoA/xScarlife upper Coral Forest"),
        C(0.6138, 0.2588, "AoA/xScarlife north Kal'methir"),
        C(0.6867, 0.2585, "AoA/xScarlife eastern ridge"),
        C(0.7595, 0.2582, "AoA/xScarlife Drowned Market north"),
        C(0.8035, 0.3606, "AoA/xScarlife eastern turn"),
        C(0.7719, 0.4930, "AoA/xScarlife southeast return"),
        C(0.7066, 0.4978, "AoA/xScarlife Kal'methir return"),
        C(0.6453, 0.5620, "AoA/xScarlife central return"),
        C(0.5200, 0.5588, "AoA/xScarlife Coral Forest south"),
        C(0.4772, 0.6077, "AoA/xScarlife lower Coral Forest"),
        C(0.4387, 0.6114, "AoA/xScarlife western slope"),
        C(0.4460, 0.6641, "AoA/xScarlife Hanging Reef approach"),
        C(0.4808, 0.7463, "AoA/xScarlife southern reef"),
        C(0.4114, 0.7603, "AoA/xScarlife southwest loop"),
        C(0.3752, 0.6785, "AoA/xScarlife west route"),
        C(0.3928, 0.5757, "AoA/xScarlife western return"),
        C(0.2960, 0.4756, "AoA/xScarlife far west point"),
        C(0.2800, 0.3681, "AoA/xScarlife northwest return"),
        C(0.3269, 0.3455, "AoA/xScarlife northwestern bend"),
        C(0.3514, 0.2151, "AoA/xScarlife north route close"),
    },
    confidence = "high",
}

local function RegisterOre(itemID, itemName, spots, summary)
    Register({
        itemID = itemID,
        itemName = itemName,
        expansion = "battleForAzeroth",
        professions = { "mining" },
        category = "Ore",
        sourceUrls = { ItemUrl(itemID) },
        summary = summary,
        spots = spots,
    })
end

RegisterOre(152512, "Monelite Ore", {
    TIRAGARDE_ORE_ROUTE,
    NAZMIR_ORE_ROUTE,
    MECHAGON_ORE_ROUTE,
}, "Common BFA ore from Kul Tiras, Zandalar, and Mechagon node loops.")

RegisterOre(152579, "Storm Silver Ore", {
    STORMSONG_ORE_ROUTE,
    TIRAGARDE_ORE_ROUTE,
    NAZMIR_ORE_ROUTE,
    MECHAGON_ORE_ROUTE,
}, "Rare Monelite respawn ore. Mine all BFA ore nodes to force more spawn chances.")

RegisterOre(152513, "Platinum Ore", {
    STORMSONG_ORE_ROUTE,
    TIRAGARDE_ORE_ROUTE,
    MECHAGON_ORE_ROUTE,
}, "Rare BFA ore respawn; also the strongest base-BFA prospecting input when gem prices justify it.")

RegisterOre(168185, "Osmenite Ore", {
    OSMENITE_NAZJATAR_ROUTE,
}, "Nazjatar patch 8.2 ore, best paired with Zin'anthid route loops and 8.2 gem prospecting.")
