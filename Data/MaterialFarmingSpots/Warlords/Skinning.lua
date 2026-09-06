local _, NS = ...
local Register = NS.RegisterMaterialFarmingSpot

local function C(x, y, label)
    return { x = x, y = y, label = label }
end

local function ItemUrl(itemID)
    return "https://www.wowhead.com/item=" .. tostring(itemID)
end

local CLEFTHOOF_ROUTE = {
    id = "warlords-hide-nagrand-tamed-clefthoof-instant-respawn",
    source = "wow-professions Raw Beast Hide guide and Wowhead Tamed Clefthoof comments",
    sourceUrls = {
        "https://www.wow-professions.com/farming/raw-beast-hide-farming",
        "https://www.wowhead.com/npc=79034/tamed-clefthoof",
    },
    mapName = "Nagrand (Draenor)",
    location = "Tamed Clefthoof pack south of Nagrand at 78.7,72.2",
    routeType = "skinning-loop",
    density = "Very high",
    dropDifficulty = "Excellent if uncontested; the instant respawn behavior makes the spot crowded.",
    tips = {
        "Stand around 78.7,72.2 and kill the Tamed Clefthoof pack as it respawns.",
        "Kill the nearby extra clefthoofs near the Gorian Gladiators if the main pack stalls.",
        "This also produces Sumptuous Fur and Raw Clefthoof Meat.",
    },
    coords = {
        C(0.787, 0.722, "Tamed Clefthoof pack"),
        C(0.802, 0.704, "Gorian-side extra clefthoofs"),
        C(0.768, 0.742, "South pack return"),
    },
    confidence = "high",
}

local ELEKK_ROUTE = {
    id = "warlords-hide-shadowmoon-karabor-elekk-fields",
    source = "Wowhead Raw Elekk Meat comments and Raw Beast Hide route research",
    sourceUrls = {
        "https://www.wowhead.com/item=109134/raw-elekk-meat",
        "https://www.wow-professions.com/farming/raw-beast-hide-farming",
    },
    mapName = "Shadowmoon Valley (Draenor)",
    location = "Rockhide Elekk fields west of the Temple of Karabor",
    routeType = "skinning-loop",
    density = "Medium to high",
    dropDifficulty = "Lower-level mobs with clustered packs; good for characters still leveling through Draenor.",
    tips = {
        "Use the fields around 61,51 west of Karabor for clustered Rockhide Elekk packs.",
        "Pull small groups if you are below max level; they are easier than Nagrand elites.",
    },
    coords = {
        C(0.610, 0.510, "Karabor west elekk field"),
        C(0.586, 0.488, "North elekk cluster"),
        C(0.638, 0.532, "East elekk cluster"),
    },
    confidence = "medium",
}

local DRAENOR_SKINNING_ROUTES = {
    CLEFTHOOF_ROUTE,
    ELEKK_ROUTE,
}

Register({
    itemID = 110609,
    itemName = "Raw Beast Hide",
    expansion = "warlords",
    professions = { "skinning", "leatherworking" },
    category = "Leather",
    sourceUrls = { ItemUrl(110609), "https://www.wow-professions.com/farming/raw-beast-hide-farming" },
    summary = "Baseline Draenor leather from skinnable beasts; Tamed Clefthoof and Karabor elekk packs are strong targeted spots.",
    spots = DRAENOR_SKINNING_ROUTES,
})

Register({
    itemID = 118472,
    itemName = "Savage Blood",
    expansion = "warlords",
    professions = { "leatherworking", "tailoring", "blacksmithing" },
    category = "Reagent",
    sourceUrls = {
        ItemUrl(118472),
        "https://www.wowhead.com/guide/guide-to-savage-blood-farming-2867",
        "https://www.wowhead.com/guide/garrisons/buildings/guide-to-the-garrison-barn",
    },
    summary = "Barn Level 3 reagent from trapping elite Nagrand beasts, especially Ironhide Bulls, Direfang Alphas, and Wetland Tramplers.",
    spots = {
        {
            id = "warlords-savage-blood-nagrand-elite-beast-trapping",
            source = "Wowhead Savage Blood guide, Garrison Barn guide, and Caged Mighty Clefthoof comments",
            sourceUrls = {
                "https://www.wowhead.com/guide/guide-to-savage-blood-farming-2867",
                "https://www.wowhead.com/guide/garrisons/buildings/guide-to-the-garrison-barn",
                "https://www.wowhead.com/item=119819/caged-mighty-clefthoof",
            },
            mapName = "Nagrand (Draenor)",
            location = "Northern Nagrand elite beast trapping route",
            routeType = "barn-trapping-loop",
            density = "Medium",
            dropDifficulty = "Requires Barn Level 3, Deadly Iron Trap, and trapping elite beasts below 50 percent health.",
            tips = {
                "Trap Ironhide Bulls around 60,30 for Caged Mighty Clefthoof work orders.",
                "Direfang Alphas and Wetland Tramplers are valid backups in northern Nagrand.",
                "Assign a follower with Skinning to improve Barn work-order output when available.",
            },
            coords = {
                C(0.600, 0.300, "Ironhide Bull trapping area"),
                C(0.646, 0.238, "Direfang Alpha backup"),
                C(0.514, 0.386, "Wetland Trampler river backup"),
            },
            confidence = "high",
        },
    },
})
