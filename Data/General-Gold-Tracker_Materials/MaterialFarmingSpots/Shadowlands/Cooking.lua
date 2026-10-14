local _, NS = ...
local Register = NS.RegisterMaterialFarmingSpot

local function C(x, y, label)
    return { x = x, y = y, label = label }
end

local function ItemUrl(itemID)
    return "https://www.wowhead.com/item=" .. tostring(itemID)
end

local BASTION_BEAST_MEAT_ROUTE = {
    id = "shadowlands-bastion-traditional-beast-meat-route",
    source = "Wowhead Shadowlands cooking guide, skinning guide, and Bastion leather farm reports",
    sourceUrls = {
        "https://www.wowhead.com/guide/shadowlands-cooking-profession",
        "https://www.wowhead.com/guide/shadowlands-skinning-profession",
        "https://www.wow-professions.com/farming/desolate-leather-farming",
    },
    mapName = "Bastion",
    location = "Bastion cloudstrider and etherwyrm beast farming pockets",
    routeType = "beast-meat-farm",
    density = "Medium to high",
    dropDifficulty = "Easy. Best used with skinning for added leather value.",
    tips = {
        "Traditional beasts are the practical Aethereal Meat source category.",
        "Cloudstrider and etherwyrm routes double as leather farms.",
        "Use big pulls if your character can kill quickly enough to keep respawns cycling.",
    },
    coords = {
        C(0.456, 0.596, "Cloudstrider west slope"),
        C(0.532, 0.586, "Cloudstrider east slope"),
        C(0.548, 0.442, "Etherwyrm north pocket"),
        C(0.604, 0.526, "Etherwyrm south pocket"),
    },
    confidence = "medium",
}

local BASTION_WINGED_MEAT_ROUTE = {
    id = "shadowlands-bastion-seraphic-winged-beast-route",
    source = "Wowhead Shadowlands cooking guide and Bastion beast route notes",
    sourceUrls = {
        "https://www.wowhead.com/guide/shadowlands-cooking-profession",
        "https://wowanalytica.com/guide/raw-seraphic-wing-farming-guide-1635445885",
    },
    mapName = "Bastion",
    location = "Bastion winged beast pockets around Hero's Rest and southern fields",
    routeType = "winged-beast-meat-farm",
    density = "Medium",
    dropDifficulty = "Easy to moderate. Flying mobs can slow pulls if you lack ranged tags.",
    tips = {
        "Raw Seraphic Wing comes from winged beast sources.",
        "Use ranged pulls to keep flying targets grouped.",
        "Route near leather and herb areas when wing prices are low.",
    },
    coords = {
        C(0.526, 0.456, "Hero's Rest winged beasts"),
        C(0.580, 0.520, "Central Bastion winged packs"),
        C(0.604, 0.632, "Southern winged route"),
        C(0.472, 0.624, "Western return packs"),
    },
    confidence = "medium",
}

local MALDRAXXUS_BONE_BEAST_MEAT_ROUTE = {
    id = "shadowlands-maldraxxus-ribs-and-crawler-meat-route",
    source = "Wowhead Shadowlands cooking guide and Maldraxxus skinning farm reports",
    sourceUrls = {
        "https://www.wowhead.com/guide/shadowlands-cooking-profession",
        "https://www.wow-professions.com/farming/desolate-leather-farming",
    },
    mapName = "Maldraxxus",
    location = "Theater of Pain beast loop and House of Plagues crawler/pest pockets",
    routeType = "beast-meat-farm",
    density = "Medium to high",
    dropDifficulty = "Moderate. Good multi-meat route with skinning side value.",
    tips = {
        "Tenebrous Ribs are commonly tied to stags, stone hounds, and similar beasts.",
        "Creeping Crawler Meat comes from insects, moths, wasps, and other crawler-style beasts.",
        "Swap between Theater of Pain beasts and House of Plagues pests to avoid downtime.",
    },
    coords = {
        C(0.486, 0.564, "Theater beast route west"),
        C(0.596, 0.552, "Theater beast route east"),
        C(0.622, 0.724, "House of Plagues crawler pocket"),
        C(0.664, 0.756, "Virulent pest east pocket"),
    },
    confidence = "medium",
}

local ARDENWEALD_INSECT_MEAT_ROUTE = {
    id = "shadowlands-ardenweald-insect-haunch-meat-route",
    source = "Wowhead Shadowlands cooking guide and Ardenweald skinning guidance",
    sourceUrls = {
        "https://www.wowhead.com/guide/shadowlands-cooking-profession",
        "https://www.wowhead.com/guide/shadowlands-skinning-profession",
    },
    mapName = "Ardenweald",
    location = "Ardenweald moth, wasp, and gorm beast pockets near Tirna Noch",
    routeType = "insect-beast-meat-farm",
    density = "Medium",
    dropDifficulty = "Moderate. Insects are good targets, but some packs are mixed with harder-hitting mobs.",
    tips = {
        "Phantasmal Haunch and Creeping Crawler Meat both favor insect-style beast targets.",
        "Stay near Tirna Noch if you also want cloth from nearby humanoids.",
        "This route is better with skinning enabled for extra value.",
    },
    coords = {
        C(0.404, 0.640, "Southwest gorm and insect checks"),
        C(0.516, 0.585, "Central Ardenweald beast pockets"),
        C(0.612, 0.442, "Northeast insect packs"),
        C(0.640, 0.342, "Tirna Noch side route"),
    },
    confidence = "medium",
}

local REVENDRETH_SHANK_ROUTE = {
    id = "shadowlands-revendreth-shadowy-shank-beast-route",
    source = "Wowhead Shadowlands cooking and skinning guides",
    sourceUrls = {
        "https://www.wowhead.com/guide/shadowlands-cooking-profession",
        "https://www.wowhead.com/guide/shadowlands-skinning-profession",
    },
    mapName = "Revendreth",
    location = "Lower Revendreth traditional beasts between Wanecrypt Hill and Darkhaven",
    routeType = "beast-meat-farm",
    density = "Medium",
    dropDifficulty = "Moderate. Keep to lower beast pockets and avoid unskinnable gargons.",
    tips = {
        "Shadowy Shank comes mostly from traditional beast targets.",
        "Revendreth adds skinning and Widowbloom side value.",
        "Avoid town hounds if they are unskinnable gargon types.",
    },
    coords = {
        C(0.462, 0.684, "Wanecrypt-side beasts"),
        C(0.524, 0.704, "Lower road beast packs"),
        C(0.590, 0.652, "Darkhaven-side beasts"),
        C(0.548, 0.596, "Northern return beasts"),
    },
    confidence = "medium",
}

local ZERETH_MORTIS_PROTOFLESH_ROUTE = {
    id = "shadowlands-zereth-mortis-protoflesh-akkaris-lupine-route",
    source = "Retail Wowhead Protoflesh item page, Akkaris NPC comments/pins, and World of Moudi 9.2 farm notes",
    sourceUrls = {
        "https://www.wowhead.com/item=187704/protoflesh",
        "https://www.wowhead.com/npc=179006/akkaris",
        "https://www.wowhead.com/npc=181360/vexis",
        "https://www.worldofmoudi.com/silken-protofiber",
    },
    mapName = "Zereth Mortis",
    location = "Akkaris rare check and nearby northeast creature route, with Vexis lupine backup check",
    routeType = "meat-farm",
    density = "Opportunistic rare farm with nearby creature checks",
    dropDifficulty = "Moderate to hard. Akkaris and Vexis are rares, so use group finder or combine with nearby loops.",
    tips = {
        "Protoflesh is the Patch 9.2 cooking meat used for Stone Soup contributions.",
        "Akkaris is the clearest targeted repeat-check from retail rare-farm notes.",
        "Use this alongside the Silken Protofiber and Protogenic Pelt routes when rare hopping in Zereth Mortis.",
    },
    coords = {
        C(0.646, 0.334, "Akkaris rare spawn pin"),
        C(0.648, 0.338, "Akkaris second Wowhead pin"),
        C(0.668, 0.344, "Nearby annelid creature check"),
        C(0.680, 0.342, "Northeast annelid route point"),
        C(0.694, 0.340, "Eastern creature check"),
        C(0.392, 0.564, "Vexis lupine rare pack"),
        C(0.394, 0.572, "Vexis route return"),
    },
    confidence = "medium",
}

local function RegisterMeat(itemID, itemName, spots, summary)
    Register({
        itemID = itemID,
        itemName = itemName,
        expansion = "shadowlands",
        professions = { "cooking" },
        category = "Meat",
        sourceUrls = { ItemUrl(itemID) },
        summary = summary,
        spots = spots,
    })
end

RegisterMeat(172052, "Aethereal Meat", { BASTION_BEAST_MEAT_ROUTE },
    "Shadowlands meat from traditional beasts; Bastion routes are easy and skinning-friendly.")
RegisterMeat(172053, "Tenebrous Ribs", { MALDRAXXUS_BONE_BEAST_MEAT_ROUTE },
    "Shadowlands meat from stags, stone hounds, and similar beasts.")
RegisterMeat(172054, "Raw Seraphic Wing", { BASTION_WINGED_MEAT_ROUTE }, "Shadowlands meat from winged beasts.")
RegisterMeat(172055, "Phantasmal Haunch", { ARDENWEALD_INSECT_MEAT_ROUTE },
    "Shadowlands meat from wasps, moths, insects, and similar beasts.")
RegisterMeat(179314, "Creeping Crawler Meat", {
    MALDRAXXUS_BONE_BEAST_MEAT_ROUTE,
    ARDENWEALD_INSECT_MEAT_ROUTE,
}, "Shadowlands crawler-style meat from insects and similar beasts.")
RegisterMeat(179315, "Shadowy Shank", { REVENDRETH_SHANK_ROUTE },
    "Shadowlands meat from traditional beasts, with Revendreth lower-zone packs as a practical route.")
RegisterMeat(187704, "Protoflesh", { ZERETH_MORTIS_PROTOFLESH_ROUTE },
    "Patch 9.2 Zereth Mortis meat-style material used for Empty Kettle of Stone Soup contributions.")
