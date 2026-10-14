local _, NS = ...
local Register = NS.RegisterMaterialFarmingSpot
local H = NS.MaterialFarmingSpotHelpers

local function C(x, y, label)
    return { x = x, y = y, label = label }
end

local function ItemUrl(itemID)
    return "https://www.wowhead.com/item=" .. tostring(itemID)
end

local DRUSTVAR_BOAR_ROUTE = {
    id = "bfa-drustvar-hockings-plot-boar-skinning",
    source = "wow-professions Coarse Leather guide and BFA cooking route notes",
    sourceUrls = {
        "https://www.wow-professions.com/farming/coarse-leather-farming",
        "https://en.guiaswow.com/game-guide/cooking-guide-in-battle-for-azeroth-best-farming-routes.html",
    },
    mapName = "Drustvar",
    location = "Hocking's Plot Scavenging Boar and Invasive Quillrat packs",
    routeType = "skinning-loop",
    density = "High",
    dropDifficulty = "Easy to moderate. Compact beasts keep skinning volume high.",
    tips = H.withBfaGatheringTips({
        "Pull packs together, loot fully, then skin before moving to the next group.",
        "This route gives leather, bones, and cooking meat side drops.",
        "Use it when both Coarse Leather and Blood-Stained Bone are valuable.",
    }),
    coords = {
        C(0.554, 0.314, "North Hocking's Plot beasts"),
        C(0.592, 0.346, "Central boar packs"),
        C(0.622, 0.392, "East boar route"),
        C(0.578, 0.452, "Southern quillrat packs"),
        C(0.520, 0.402, "Western return"),
    },
    confidence = "high",
}

local ZULDAZAR_BEAST_ROUTE = {
    id = "bfa-zuldazar-gorilla-and-raptor-skinning",
    source = "wow-professions skinning guides and BFA cooking route notes",
    sourceUrls = {
        "https://www.wow-professions.com/farming/coarse-leather-farming",
        "https://www.wow-professions.com/farming/meaty-haunch-farming",
        "https://www.wow-professions.com/farming/thick-paleo-steak-farming",
    },
    mapName = "Zuldazar",
    location = "Zuldazar gorilla and ravasaur beast route",
    routeType = "skinning-loop",
    density = "Medium to high",
    dropDifficulty = "Good Horde-side route with meat and bone side value.",
    tips = H.withBfaGatheringTips({
        "Farm when meat and bone prices are also useful, not just leather.",
        "Avoid overpulling dinosaurs if you are on a weak character.",
    }),
    coords = {
        C(0.428, 0.662, "Xibala ravasaur packs"),
        C(0.458, 0.716, "Southern ravasaur route"),
        C(0.566, 0.612, "Central beast packs"),
        C(0.654, 0.528, "Eastern gorilla route"),
        C(0.696, 0.382, "Northern gorilla packs"),
    },
    confidence = "medium",
}

local VOLDUN_KROLUSK_ROUTE = {
    id = "bfa-voldun-saltspine-krolusk-skinning",
    source = "wow-professions Mistscale guide and skinning route notes",
    sourceUrls = {
        "https://www.wow-professions.com/farming/mistscale-farming",
        "https://legacy-wow.com/skinning-guide-battle-for-azeroth/",
    },
    mapName = "Vol'dun",
    location = "Vol'dun Saltspine Krolusk and scale-beast packs",
    routeType = "skinning-loop",
    density = "High",
    dropDifficulty = "Good scale farm, especially when other players leave corpses.",
    tips = H.withBfaGatheringTips({
        "Prioritize krolusk and saurolisk packs over scattered single beasts.",
        "Assaults and world quests can increase corpse volume.",
    }),
    coords = {
        C(0.452, 0.700, "Northern krolusk pack"),
        C(0.488, 0.746, "Central Saltspine pack"),
        C(0.526, 0.792, "Southern krolusk"),
        C(0.592, 0.746, "Eastern scale-beast pack"),
        C(0.548, 0.646, "Northern return"),
    },
    confidence = "high",
}

local TIRAGARDE_SAUROLISK_ROUTE = {
    id = "bfa-tiragarde-venomspine-saurolisk-skinning",
    source = "wow-professions Mistscale and Thick Paleo Steak guides",
    sourceUrls = {
        "https://www.wow-professions.com/farming/mistscale-farming",
        "https://www.wow-professions.com/farming/thick-paleo-steak-farming",
    },
    mapName = "Tiragarde Sound",
    location = "Venomspine Saurolisk packs in eastern Tiragarde",
    routeType = "skinning-loop",
    density = "Medium",
    dropDifficulty = "Good backup scale route with Thick Paleo Steak side drops.",
    tips = H.withBfaGatheringTips({
        "Use this when Vol'dun scale routes are crowded.",
        "Skin every saurolisk and pull around rocks to keep downtime low.",
    }),
    coords = {
        C(0.680, 0.338, "North Venomspine route"),
        C(0.724, 0.378, "Central saurolisk packs"),
        C(0.758, 0.442, "Eastern saurolisk"),
        C(0.704, 0.510, "Southern return"),
        C(0.642, 0.452, "Western return"),
    },
    confidence = "medium",
}

local NAZJATAR_SNAPDRAGON_ROUTE = {
    id = "bfa-nazjatar-snapdragon-dredged-leather-route",
    source = "wow-professions Dredged Leather, Cragscale, Moist Fillet, and Rubbery Flank guides",
    sourceUrls = {
        "https://www.wow-professions.com/farming/dredged-leather-farming",
        "https://www.wow-professions.com/farming/cragscale-farming",
        "https://www.wow-professions.com/farming/rubbery-flank-farming",
    },
    mapName = "Nazjatar",
    location = "Snapdragon and aquatic beast loops near Deepcoil Tunnels and Kal'methir",
    routeType = "skinning-loop",
    density = "High",
    dropDifficulty = "Good patch 8.2 farm, but many targets are elite or mixed with naga packs.",
    tips = H.withBfaGatheringTips({
        "Snapdragons are the core target for Dredged Leather and Rubbery Flank.",
        "Forgotten Tunnel and Deepcoil Tunnels are strong small-loop anchors.",
        "Use the Snap Back quest scroll if available to kill elite snapdragons faster.",
    }),
    coords = {
        C(0.656, 0.220, "Deepcoil Tunnels beast route"),
        C(0.593, 0.145, "Shirakess Repository edge"),
        C(0.657, 0.434, "Kal'methir snapdragons"),
        C(0.756, 0.457, "Drowned Market beasts"),
        C(0.402, 0.581, "Hanging Reef backup"),
    },
    confidence = "high",
}

local function RegisterSkinning(itemID, itemName, category, spots, summary)
    Register({
        itemID = itemID,
        itemName = itemName,
        expansion = "battleForAzeroth",
        professions = { "skinning", "leatherworking" },
        category = category,
        sourceUrls = { ItemUrl(itemID) },
        summary = summary,
        spots = spots,
    })
end

RegisterSkinning(152541, "Coarse Leather", "Leather", {
    DRUSTVAR_BOAR_ROUTE,
    ZULDAZAR_BEAST_ROUTE,
}, "Common BFA leather from dense Kul Tiras and Zandalar beast packs.")

RegisterSkinning(154722, "Tempest Hide", "Leather", {
    DRUSTVAR_BOAR_ROUTE,
    ZULDAZAR_BEAST_ROUTE,
}, "Rare BFA hide side-drop from normal skinning routes.")

RegisterSkinning(153050, "Shimmerscale", "Scale", {
    TIRAGARDE_SAUROLISK_ROUTE,
    VOLDUN_KROLUSK_ROUTE,
}, "Common BFA scale from saurolisks, krolusks, and other scale beasts.")

RegisterSkinning(153051, "Mistscale", "Scale", {
    VOLDUN_KROLUSK_ROUTE,
    TIRAGARDE_SAUROLISK_ROUTE,
}, "Rare BFA scale from the same scale-beast routes as Shimmerscale.")

RegisterSkinning(154164, "Blood-Stained Bone", "Bone", {
    DRUSTVAR_BOAR_ROUTE,
    ZULDAZAR_BEAST_ROUTE,
}, "Common BFA bone side-drop from skinning beast packs.")

RegisterSkinning(154165, "Calcified Bone", "Bone", {
    DRUSTVAR_BOAR_ROUTE,
    ZULDAZAR_BEAST_ROUTE,
}, "Rare BFA bone side-drop from normal beast skinning routes.")

RegisterSkinning(168649, "Dredged Leather", "Leather", {
    NAZJATAR_SNAPDRAGON_ROUTE,
}, "Nazjatar leather from patch 8.2 snapdragon and aquatic beast routes.")

RegisterSkinning(168650, "Cragscale", "Scale", {
    NAZJATAR_SNAPDRAGON_ROUTE,
}, "Nazjatar scale from Deeptide Frenzy, eels, turtles, and other aquatic beast routes.")
