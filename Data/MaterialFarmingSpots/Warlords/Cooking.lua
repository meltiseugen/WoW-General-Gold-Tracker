local _, NS = ...
local Register = NS.RegisterMaterialFarmingSpot

local function C(x, y, label)
    return { x = x, y = y, label = label }
end

local function ItemUrl(itemID)
    return "https://www.wowhead.com/item=" .. tostring(itemID)
end

local CLEFTHOOF_ROUTE = {
    id = "warlords-meat-nagrand-tamed-clefthoof",
    source = "wow-professions Raw Beast Hide guide and Wowhead Tamed Clefthoof comments",
    sourceUrls = {
        "https://www.wow-professions.com/farming/raw-beast-hide-farming",
        "https://www.wowhead.com/npc=79034/tamed-clefthoof",
    },
    mapName = "Nagrand (Draenor)",
    location = "Tamed Clefthoof pack south of Nagrand at 78.7,72.2",
    routeType = "stationary-beast-farm",
    density = "Very high",
    dropDifficulty = "Very strong Raw Clefthoof Meat spot if uncontested.",
    tips = {
        "Use the instant-respawn Tamed Clefthoof pack for meat, fur, and hides.",
        "Keep nearby extra clefthoofs dead to force respawns when needed.",
    },
    coords = {
        C(0.787, 0.722, "Tamed Clefthoof pack"),
        C(0.802, 0.704, "Gorian-side extra clefthoofs"),
    },
    confidence = "high",
}

local TALBUK_ROUTE = {
    id = "warlords-meat-nagrand-breezestrider-talbuk-tree-loop",
    source = "Wowhead Raw Talbuk Meat comments and Breezestrider Talbuk NPC page",
    sourceUrls = {
        "https://www.wowhead.com/item=109132/raw-talbuk-meat",
        "https://www.wowhead.com/npc=78278/breezestrider-talbuk",
        "https://www.wowhead.com/npc=86727/thorncoat-talbuk",
    },
    mapName = "Nagrand (Draenor)",
    location = "Breezestrider and Thorncoat Talbuks around central Nagrand tree clusters",
    routeType = "open-world-beast-loop",
    density = "High",
    dropDifficulty = "Plentiful, but talbuks charge and move, so pull control is annoying.",
    tips = {
        "Favor Breezestrider Talbuks in Nagrand and skip colts because comments say colts do not drop meat.",
        "Route through tree clusters; comments note talbuks are commonly found around trees.",
    },
    coords = {
        C(0.604, 0.380, "North central tree cluster"),
        C(0.682, 0.456, "East tree cluster"),
        C(0.720, 0.574, "South tree cluster"),
        C(0.552, 0.642, "River tree return"),
        C(0.438, 0.512, "West plains return"),
    },
    confidence = "medium",
}

local RYLAK_EGG_ROUTE = {
    id = "warlords-rylak-egg-shadowmoon-darktide-roost",
    source = "Wowhead Rylak Egg object pages and Giant Rylak Egg comments",
    sourceUrls = {
        "https://www.wowhead.com/item=109133/rylak-egg",
        "https://www.wowhead.com/object=234587/rylak-egg",
        "https://www.wowhead.com/object=235826/giant-rylak-egg",
    },
    mapName = "Shadowmoon Valley (Draenor)",
    location = "Darktide Roost rylak egg nests and ridge checks",
    routeType = "object-and-rylak-loop",
    density = "Localized",
    dropDifficulty = "Object spawns are limited and some nests require vertical movement or daily/assault state.",
    tips = {
        "Use Darktide Roost and the nearby peak as the anchor because object pages place Rylak Eggs in Shadowmoon Valley.",
        "A Giant Rylak Egg comment gives 61.27,88.77 and recommends Goblin Rocket Pack or similar mobility.",
        "Kill nearby rylaks while waiting on object respawns.",
    },
    coords = {
        C(0.6127, 0.8877, "Giant Rylak Egg peak"),
        C(0.586, 0.846, "Darktide Roost lower nests"),
        C(0.642, 0.858, "Darktide Roost east nests"),
    },
    confidence = "medium",
}

local ELEKK_ROUTE = {
    id = "warlords-meat-shadowmoon-karabor-elekk-fields",
    source = "Wowhead Raw Elekk Meat comments",
    sourceUrls = { "https://www.wowhead.com/item=109134/raw-elekk-meat" },
    mapName = "Shadowmoon Valley (Draenor)",
    location = "Rockhide Elekk fields west of Temple of Karabor around 61,51",
    routeType = "open-world-beast-loop",
    density = "Medium to high",
    dropDifficulty = "Good low-level Draenor farm with clustered packs.",
    tips = {
        "Farm the fields around 61,51 west of Temple of Karabor.",
        "Comments report packs of three or more elekks and about one meat per four kills.",
    },
    coords = {
        C(0.610, 0.510, "Karabor west elekk field"),
        C(0.586, 0.488, "North elekk cluster"),
        C(0.638, 0.532, "East elekk cluster"),
    },
    confidence = "high",
}

local RIVERBEAST_ROUTE = {
    id = "warlords-meat-nagrand-riverside-post-wetland-riverbeasts",
    source = "Wowhead Raw Riverbeast Meat comments and Wetland Riverbeast NPC page",
    sourceUrls = {
        "https://www.wowhead.com/item=109135/raw-riverbeast-meat",
        "https://www.wowhead.com/npc=87020/wetland-riverbeast",
    },
    mapName = "Nagrand (Draenor)",
    location = "Wetland Riverbeasts and Tramplers west of Riverside Post above the Ancestral Grounds",
    routeType = "river-beast-loop",
    density = "High",
    dropDifficulty = "Strong meat and hide farm; large mobs can hit hard if you are undergeared.",
    tips = {
        "Follow the river west of Riverside Post above the Ancestral Grounds.",
        "A 2024 comment reports 58 Raw Riverbeast Meat from 100 kills here.",
        "Skin the corpses for Raw Beast Hide if you have Skinning.",
    },
    coords = {
        C(0.506, 0.448, "Riverside Post west river"),
        C(0.456, 0.478, "Wetland Riverbeast cluster"),
        C(0.414, 0.528, "Ancestral Grounds north river"),
        C(0.374, 0.562, "West river return"),
    },
    confidence = "high",
}

local BOAR_ROUTE = {
    id = "warlords-meat-frostfire-coldsnout-boars-frostwall",
    source = "Wowhead Coldsnout Boar comments and Draenor cooking guide notes",
    sourceUrls = {
        "https://www.wowhead.com/item=109136/raw-boar-meat",
        "https://www.wowhead.com/npc=75416/coldsnout-boar",
        "https://mein-mmo.de/en/bufffood-in-warlords-of-draenor091%2C24399/",
    },
    mapName = "Frostfire Ridge",
    location = "Coldsnout Boars west and north of Frostwall",
    routeType = "open-world-beast-loop",
    density = "Medium",
    dropDifficulty = "Easy farm near the Horde garrison area.",
    tips = {
        "Use the boar packs west and north of Frostwall for a compact Raw Boar Meat route.",
        "The Coldsnout Boar page notes they are easy Barn-style targets for level 100 characters.",
    },
    coords = {
        C(0.454, 0.438, "North Frostwall boars"),
        C(0.414, 0.500, "West Frostwall boars"),
        C(0.486, 0.536, "Southwest return"),
    },
    confidence = "medium",
}

local function RegisterMeat(itemID, itemName, spots, summary)
    Register({
        itemID = itemID,
        itemName = itemName,
        expansion = "warlords",
        professions = { "cooking" },
        category = "Meat",
        sourceUrls = { ItemUrl(itemID) },
        summary = summary,
        spots = spots,
    })
end

RegisterMeat(109131, "Raw Clefthoof Meat", { CLEFTHOOF_ROUTE }, "Farm Tamed Clefthoof in southern Nagrand for dense meat, fur, and hide drops.")
RegisterMeat(109132, "Raw Talbuk Meat", { TALBUK_ROUTE }, "Farm Breezestrider and Thorncoat Talbuks across central Nagrand tree clusters.")
RegisterMeat(109133, "Rylak Egg", { RYLAK_EGG_ROUTE }, "Object and rylak farm around Shadowmoon Valley's Darktide Roost.")
RegisterMeat(109134, "Raw Elekk Meat", { ELEKK_ROUTE }, "Farm Rockhide Elekk fields west of Temple of Karabor in Shadowmoon Valley.")
RegisterMeat(109135, "Raw Riverbeast Meat", { RIVERBEAST_ROUTE }, "Farm Wetland Riverbeasts along the river west of Riverside Post in Nagrand.")
RegisterMeat(109136, "Raw Boar Meat", { BOAR_ROUTE }, "Farm Coldsnout Boars near Frostwall in Frostfire Ridge.")
