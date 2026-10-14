local _, NS = ...
local Register = NS.RegisterMaterialFarmingSpot

local function C(x, y, label)
    return { x = x, y = y, label = label }
end

local function ItemUrl(itemID)
    return "https://www.wowhead.com/item=" .. tostring(itemID)
end

local AZURE_SPAN_RESILIENT_LEATHER_ROUTE = {
    id = "dragonflight-azure-span-riverback-resilient-leather-route",
    source = "Artisans of Azeroth Resilient Leather route, wow-professions Resilient Leather guide, Wowhead Resilient Leather comments",
    sourceUrls = {
        "https://artisansofazeroth.com/where-to-farm-resilient-leather-wow-dragonflight-gold-guide/",
        "https://www.wow-professions.com/farming/resilient-leather-farming",
        "https://www.wowhead.com/item=193208/resilient-leather",
        "https://www.wowhead.com/item=193210/resilient-leather",
        "https://www.wowhead.com/guide/professions/skinning/overview-leveling-dragonflight",
    },
    mapName = "The Azure Span",
    location = "Western Azure Span riverback and mixed skinning loop",
    routeType = "skinning-loop",
    density = "High",
    dropDifficulty = "Easy. Best with Dragonflight Skinning and large pull tools.",
    tips = {
        "Farm the riverback route when Resilient Leather is the target material.",
        "The route overlaps with mixed skinning targets, so Dense Hide can appear as rare side value.",
        "Use Finesse for base leather volume unless rare hides are the goal.",
    },
    coords = {
        C(0.2711, 0.4587, "Riverback route west"),
        C(0.2941, 0.4778, "Riverback route east"),
        C(0.2771, 0.4803, "Riverback route south"),
        C(0.3048, 0.4687, "Nearby skinning extension"),
        C(0.3236, 0.4633, "Eastern return"),
    },
    confidence = "high",
}

local OHNAHRAN_WATERFOWL_SKINNING_ROUTE = {
    id = "dragonflight-ohnahran-ruszathar-waterfowl-skinning-route",
    source = "Artisans of Azeroth Ohn'ahran skinning route and Wowhead skinning overview",
    sourceUrls = {
        "https://artisansofazeroth.com/quick-skinning-farm-ruszathar-reach/",
        "https://www.wowhead.com/item=193208/resilient-leather",
        "https://www.wowhead.com/guide/professions/skinning/overview-leveling-dragonflight",
    },
    mapName = "Ohn'ahran Plains",
    location = "Ruszathar Reach waterfowl and river skinning loop",
    routeType = "skinning-loop",
    density = "Medium to high",
    dropDifficulty = "Good open-world leather loop with simple terrain.",
    tips = {
        "Use the compact waterfowl route when Azure Span is contested.",
        "Skin every eligible target on the loop rather than chasing single rare drops.",
        "Extend along the river only if respawns lag behind your kill speed.",
    },
    coords = {
        C(0.4004, 0.4251, "Waterfowl route west"),
        C(0.4190, 0.4455, "Waterfowl route north"),
        C(0.4217, 0.4751, "Waterfowl route east"),
        C(0.4323, 0.4631, "Waterfowl route bend"),
        C(0.4304, 0.4441, "Waterfowl route return"),
        C(0.4194, 0.4272, "Waterfowl route south"),
    },
    confidence = "medium",
}

local AZURE_SPAN_CRYSTALSPINE_FUR_ROUTE = {
    id = "dragonflight-azure-span-camp-nowhere-crystalspine-fur-route",
    source = "Wowhead Crystalspine Fur comments and Artisans of Azeroth Fur/Horns route import pins",
    sourceUrls = {
        "https://www.wowhead.com/item=193251/crystalspine-fur",
        "https://artisansofazeroth.com/where-to-farm-resilient-leather-wow-dragonflight-gold-guide/",
    },
    mapName = "The Azure Span",
    location = "Camp Nowhere tree and grass sweep",
    routeType = "species-specific-skinning-loop",
    density = "Medium",
    dropDifficulty = "Rare species-specific fur; expect low drop rates and gather Resilient Leather while looping.",
    tips = {
        "Loop the trees and yellow grass north and west of Camp Nowhere.",
        "Use the compact imported pins as a route spine, then expand around visible packs.",
        "Avoid spending the whole route in the river center because comments call out the tree border as stronger.",
    },
    coords = {
        C(0.6665, 0.5708, "Camp Nowhere northwest trees"),
        C(0.6396, 0.5674, "Camp Nowhere west trees"),
        C(0.6524, 0.5872, "Camp Nowhere south grass"),
        C(0.6679, 0.5881, "Camp Nowhere east return"),
        C(0.6500, 0.6000, "Commented Crystalspine pocket"),
    },
    confidence = "high",
}

local AZURE_SPAN_VORQUIN_HORN_ROUTE = {
    id = "dragonflight-azure-span-ancient-outlook-vorquin-horn-route",
    source = "Wowhead Pristine Vorquin Horn comments and Artisans of Azeroth Pristine Horn route import pins",
    sourceUrls = {
        "https://www.wowhead.com/item=193255/pristine-vorquin-horn",
        "https://www.wowhead.com/item=193213/adamant-scales",
        "https://artisansofazeroth.com/where-to-farm-resilient-leather-wow-dragonflight-gold-guide/",
    },
    mapName = "The Azure Span",
    location = "Ancient Outlook Vorquin and nearby horn route",
    routeType = "species-specific-skinning-loop",
    density = "Medium",
    dropDifficulty = "Rare species-specific horn; useful side route for Adamant Scales.",
    tips = {
        "Stay around Ancient Outlook when targeting horns rather than using the general leather loop.",
        "Both Vorquin and nearby armored targets can add Adamant Scales as side value.",
        "The Brackenhide-east note around 16,28 is lower confidence, so this route stores the denser imported loop instead.",
    },
    coords = {
        C(0.4073, 0.3971, "Ancient Outlook route north"),
        C(0.3724, 0.3490, "Ancient Outlook west rise"),
        C(0.3571, 0.3748, "Ancient Outlook middle"),
        C(0.3875, 0.3976, "Ancient Outlook east"),
        C(0.3741, 0.4204, "Ancient Outlook south"),
        C(0.3548, 0.4030, "Southwest horn sweep"),
        C(0.3313, 0.3912, "Western return"),
        C(0.3263, 0.4133, "Lower west return"),
        C(0.3671, 0.4382, "South path"),
        C(0.3885, 0.4392, "Southeast bend"),
        C(0.4079, 0.4631, "East path"),
        C(0.4058, 0.4301, "North return"),
    },
    confidence = "high",
}

local OHNAHRAN_DAILY_HIDE_SCALE_ROUTE = {
    id = "dragonflight-ohnahran-daily-hide-scale-route",
    source = "Wowhead Dense Hide and Lustrous Scaled Hide comments with rare skinning map pins",
    sourceUrls = {
        "https://www.wowhead.com/item=193216/dense-hide",
        "https://www.wowhead.com/item=193223/lustrous-scaled-hide",
        "https://www.wowhead.com/item=193213/adamant-scales",
    },
    mapName = "Ohn'ahran Plains",
    location = "Skaara cave, Territorial Coastling, and Sunscale Behemoth daily skinning pins",
    routeType = "daily-rare-skinning-pins",
    density = "Low route density, high first-kill value",
    dropDifficulty = "Rare hide and scaled hide are daily-style first-kill targets; do not treat this as a bulk farm.",
    tips = {
        "Use these as daily check pins for Dense Hide and Lustrous Scaled Hide.",
        "Skaara is a Dense Hide anchor, while Territorial Coastling and Sunscale Behemoth anchor Lustrous Scaled Hide.",
        "After daily checks, switch to general leather or scale loops for repeatable volume.",
    },
    coords = {
        C(0.4520, 0.4840, "Skaara cave Dense Hide pin"),
        C(0.2300, 0.6660, "Territorial Coastling Lustrous pin"),
        C(0.6320, 0.4860, "Sunscale Behemoth Lustrous pin"),
        C(0.5560, 0.7720, "Henlare Dense Hide extension"),
        C(0.5500, 0.5500, "Elusive Tempest Lizard scale pin"),
        C(0.5600, 0.7100, "Elusive Cliffdweller Vorquin scale and horn pin"),
    },
    confidence = "high",
}

local WAKING_SHORES_SCALE_HIDE_ROUTE = {
    id = "dragonflight-waking-shores-adamant-scale-hide-route",
    source = "Wowhead Adamant Scales comments, Dense Hide comments, and skinning quest map-pin comments",
    sourceUrls = {
        "https://www.wowhead.com/item=193213/adamant-scales",
        "https://www.wowhead.com/item=193216/dense-hide",
        "https://www.wowhead.com/quest=70034/artisans-supply-salamanther-scales",
    },
    mapName = "The Waking Shores",
    location = "Wingrest Embassy wetlands and Ancient Hornswog daily pin",
    routeType = "skinning-scale-loop",
    density = "Medium",
    dropDifficulty = "Adamant Scales are repeatable from scaled targets; Dense Hide is rarer and stronger as daily pins.",
    tips = {
        "Use the Restless Wetlands loop for scale volume near Wingrest Embassy.",
        "Add the Ancient Hornswog pin as a daily Dense Hide check when nearby.",
        "If the wetlands are crowded, move to Ohn'ahran scale pins and return later.",
    },
    coords = {
        C(0.8370, 0.3840, "Restless Wetlands salamanther scale spot"),
        C(0.8348, 0.3880, "Restless Wetlands cove"),
        C(0.8300, 0.3700, "Wingrest shoreline"),
        C(0.7760, 0.2240, "Ancient Hornswog Dense Hide daily pin"),
        C(0.4500, 0.7700, "Elusive Proto Skyterror scale pin"),
        C(0.5470, 0.5860, "Elusive Deepwater Salamanther scale pin"),
    },
    confidence = "medium",
}

local function RegisterSkinning(itemID, itemName, category, summary, qualityRank, spots)
    Register({
        itemID = itemID,
        itemName = itemName,
        expansion = "dragonflight",
        professions = { "skinning", "leatherworking" },
        category = category,
        qualityRank = qualityRank,
        sourceUrls = { ItemUrl(itemID) },
        summary = summary,
        spots = spots,
    })
end

local leatherSpots = {
    AZURE_SPAN_RESILIENT_LEATHER_ROUTE,
    OHNAHRAN_WATERFOWL_SKINNING_ROUTE,
}

RegisterSkinning(193208, "Resilient Leather", "Leather",
    "Dragonflight common leather from skinnable Dragon Isles targets; Azure Span and Ohn'ahran routes are practical dense farms.", 1, leatherSpots)
RegisterSkinning(193210, "Resilient Leather", "Leather",
    "Dragonflight common leather from skinnable Dragon Isles targets; Azure Span and Ohn'ahran routes are practical dense farms.", 3, leatherSpots)

local scaleSpots = {
    WAKING_SHORES_SCALE_HIDE_ROUTE,
    OHNAHRAN_DAILY_HIDE_SCALE_ROUTE,
    AZURE_SPAN_VORQUIN_HORN_ROUTE,
}

RegisterSkinning(193213, "Adamant Scales", "Scale",
    "Dragonflight common scales from scaled skinnable targets; Wingrest and Ohn'ahran routes provide repeatable coordinate-backed checks.", 1, scaleSpots)
RegisterSkinning(193214, "Adamant Scales", "Scale",
    "Dragonflight common scales from scaled skinnable targets; Wingrest and Ohn'ahran routes provide repeatable coordinate-backed checks.", 2, scaleSpots)
RegisterSkinning(193215, "Adamant Scales", "Scale",
    "Dragonflight common scales from scaled skinnable targets; Wingrest and Ohn'ahran routes provide repeatable coordinate-backed checks.", 3, scaleSpots)

local denseHideSpots = {
    OHNAHRAN_DAILY_HIDE_SCALE_ROUTE,
    WAKING_SHORES_SCALE_HIDE_ROUTE,
    AZURE_SPAN_RESILIENT_LEATHER_ROUTE,
}

RegisterSkinning(193216, "Dense Hide", "Hide",
    "Rare Dragonflight hide from skinnable rare and rare-plus targets, with daily pins and general leather loops as fallback side value.", 1, denseHideSpots)
RegisterSkinning(193217, "Dense Hide", "Hide",
    "Rare Dragonflight hide from skinnable rare and rare-plus targets, with daily pins and general leather loops as fallback side value.", 2, denseHideSpots)
RegisterSkinning(193218, "Dense Hide", "Hide",
    "Rare Dragonflight hide from skinnable rare and rare-plus targets, with daily pins and general leather loops as fallback side value.", 3, denseHideSpots)
RegisterSkinning(193223, "Lustrous Scaled Hide", "Hide",
    "Rare Dragonflight scaled hide from daily rare skinning pins and scaled targets; Ohn'ahran pins are the strongest confirmed anchors.", 1,
    { OHNAHRAN_DAILY_HIDE_SCALE_ROUTE, WAKING_SHORES_SCALE_HIDE_ROUTE })
RegisterSkinning(193251, "Crystalspine Fur", "Fur",
    "Rare species-specific Dragonflight skinning material from Crystalspines; Camp Nowhere is the focused route.", nil,
    { AZURE_SPAN_CRYSTALSPINE_FUR_ROUTE, AZURE_SPAN_RESILIENT_LEATHER_ROUTE })
RegisterSkinning(193255, "Pristine Vorquin Horn", "Horn",
    "Rare species-specific Dragonflight skinning material from Vorquin; Ancient Outlook is the focused route.", nil,
    { AZURE_SPAN_VORQUIN_HORN_ROUTE, OHNAHRAN_DAILY_HIDE_SCALE_ROUTE })
