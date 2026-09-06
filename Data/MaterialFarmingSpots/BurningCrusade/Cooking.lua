local _, NS = ...
local Register = NS.RegisterMaterialFarmingSpot

local function C(x, y, label)
    return { x = x, y = y, label = label }
end

local function RegisterMeat(itemID, itemName, sourceUrls, summary, spot)
    Register({
        itemID = itemID,
        itemName = itemName,
        expansion = "burningCrusade",
        professions = { "cooking" },
        category = "Meat",
        researchStatus = "researched",
        sourceUrls = sourceUrls,
        summary = summary,
        spots = { spot },
    })
end

RegisterMeat(27671, "Buzzard Meat", {
    "https://www.wowhead.com/item=27671/buzzard-meat",
    "https://www.wowhead.com/npc=16972/bonestripper-buzzard",
    "https://www.wowhead.com/npc=18470/bonelasher",
    "https://warcraft.wiki.gg/wiki/Buzzard_Meat",
}, "Buzzard Meat drops from Outland carrion birds. Hellfire Peninsula Bonestripper Buzzards are the cleanest dense route, with Terokkar Bonelashers as a backup.", {
    id = "buzzard-meat-hellfire-bonestripper-buzzards",
    source = "Retail Wowhead NPC comments, NPC map pins, and Warcraft Wiki source list",
    sourceUrls = {
        "https://www.wowhead.com/item=27671/buzzard-meat",
        "https://www.wowhead.com/npc=16972/bonestripper-buzzard",
        "https://warcraft.wiki.gg/wiki/Buzzard_Meat",
    },
    mapName = "Hellfire Peninsula",
    location = "Bonestripper Buzzards south of Honor Hold and around the southern Hellfire bird loop",
    routeType = "beast-meat-grind",
    density = "High",
    dropDifficulty = "Easy. Buzzards chain toward nearby bird corpses, which can speed up pulls if you stay ready.",
    tips = {
        "Use the dense bird circle around 61, 73 as the route anchor.",
        "Pull carefully if you are leveling; buzzards can chain into the next corpse.",
        "Terokkar Bonelashers are the fallback when the Honor Hold route is crowded.",
    },
    coords = {
        C(0.572, 0.722, "South of Honor Hold buzzard pack"),
        C(0.596, 0.704, "Western Bonestripper circle"),
        C(0.610, 0.730, "Retail Wowhead comment buzzard circle"),
        C(0.626, 0.704, "Eastern Bonestripper circle"),
        C(0.646, 0.742, "Southeast Bonestripper loop"),
    },
    confidence = "high",
})

RegisterMeat(27674, "Ravager Flesh", {
    "https://www.wowhead.com/item=27674/ravager-flesh",
    "https://www.wowhead.com/npc=16934/quillfang-ravager",
    "https://www.wowhead.com/npc=19349/thornfang-ravager",
}, "Ravager Flesh drops from Outland ravagers. Hellfire Peninsula is the simplest route and overlaps Fel Scales and Knothide skinning.", {
    id = "ravager-flesh-hellfire-ravagers",
    source = "Wowhead NPC map pins and cooking material farming guides",
    sourceUrls = {
        "https://www.wowhead.com/npc=16934/quillfang-ravager",
        "https://www.wowhead.com/npc=19349/thornfang-ravager",
    },
    mapName = "Hellfire Peninsula",
    location = "Quillfang and Thornfang ravager packs in western Hellfire",
    routeType = "beast-meat-grind",
    density = "High",
    dropDifficulty = "Easy. Compact ravager packs make this a smooth route.",
    tips = {
        "Skinning turns this into a stronger mixed farm.",
        "Run the same route used for Fel Scales and Knothide Leather Scraps.",
    },
    coords = {
        C(0.214, 0.654, "Quillfang Ravager western pack"),
        C(0.222, 0.670, "Quillfang Ravager central pack"),
        C(0.046, 0.504, "Thornfang Ravager western pack"),
        C(0.094, 0.522, "Thornfang Hill ravager pack"),
        C(0.126, 0.476, "Thornfang Venomspitter pack"),
    },
    confidence = "high",
})

RegisterMeat(27678, "Clefthoof Meat", {
    "https://www.wowhead.com/item=27678/clefthoof-meat",
    "https://www.wowhead.com/npc=17133/aged-clefthoof",
    "https://www.wowhead.com/npc=17132/clefthoof-bull",
}, "Clefthoof Meat drops from Nagrand clefthoofs. The same route supports Knothide and Thick Clefthoof Leather.", {
    id = "clefthoof-meat-nagrand-clefthoofs",
    source = "Wowhead NPC map pins and cooking material farming guides",
    sourceUrls = {
        "https://www.wowhead.com/npc=17133/aged-clefthoof",
        "https://www.wowhead.com/npc=17132/clefthoof-bull",
    },
    mapName = "Nagrand",
    location = "Clefthoof and Aged Clefthoof herds west and south of Garadar",
    routeType = "beast-meat-grind",
    density = "High",
    dropDifficulty = "Good. Herds are dense enough for a continuous loop.",
    tips = {
        "Use Track Beasts and skin every kill if possible.",
        "This is one of the best places to combine cooking meat and leather.",
    },
    coords = {
        C(0.240, 0.472, "Aged Clefthoof western route"),
        C(0.282, 0.334, "Northwest Aged Clefthoof"),
        C(0.304, 0.632, "Southern Aged Clefthoof loop"),
        C(0.438, 0.718, "South-central Clefthoof Bull"),
        C(0.604, 0.390, "Eastern Clefthoof herd"),
    },
    confidence = "high",
})

RegisterMeat(27681, "Warped Flesh", {
    "https://www.wowhead.com/item=27681/warped-flesh",
    "https://www.wowhead.com/npc=18464/warp-stalker",
    "https://www.wowhead.com/npc=18465/warp-hunter",
}, "Warped Flesh drops from warp stalkers and warp hunters. Terokkar has dense, coordinate-backed warp beast pockets.", {
    id = "warped-flesh-terokkar-warp-beasts",
    source = "Wowhead NPC map pins and cooking material farming guides",
    sourceUrls = {
        "https://www.wowhead.com/npc=18464/warp-stalker",
        "https://www.wowhead.com/npc=18465/warp-hunter",
    },
    mapName = "Terokkar Forest",
    location = "Warp Stalker and Warp Hunter pockets in western and eastern Terokkar",
    routeType = "beast-meat-grind",
    density = "Medium",
    dropDifficulty = "Moderate. Warp mobs are spread between several pockets.",
    tips = {
        "Use the larger eastern Warp Stalker pocket first.",
        "Skinning adds Knothide value to the route.",
    },
    coords = {
        C(0.302, 0.374, "Western Warp Stalker pocket"),
        C(0.336, 0.386, "Central-west Warp Stalker pocket"),
        C(0.556, 0.384, "Eastern Warp Stalker pocket"),
        C(0.598, 0.434, "East-central Warp Stalker pocket"),
        C(0.176, 0.748, "Southern Warp Hunter pocket"),
    },
    confidence = "medium",
})

RegisterMeat(27682, "Talbuk Venison", {
    "https://www.wowhead.com/item=27682/talbuk-venison",
    "https://www.wowhead.com/npc=17130/talbuk-stag",
    "https://www.wowhead.com/npc=17131/talbuk-thorngrazer",
}, "Talbuk Venison drops from Nagrand talbuks. Eastern Nagrand and central talbuk ranges provide stable meat-and-leather loops.", {
    id = "talbuk-venison-nagrand-talbuks",
    source = "Wowhead NPC map pins and cooking material farming guides",
    sourceUrls = {
        "https://www.wowhead.com/npc=17130/talbuk-stag",
        "https://www.wowhead.com/npc=17131/talbuk-thorngrazer",
    },
    mapName = "Nagrand",
    location = "Talbuk Stag and Talbuk Thorngrazer ranges across central and eastern Nagrand",
    routeType = "beast-meat-grind",
    density = "High",
    dropDifficulty = "Easy. Talbuks are plentiful and easy to chain pull.",
    tips = {
        "Run a broad loop through central Nagrand when eastern packs are empty.",
        "Skinning keeps the route profitable even when venison prices dip.",
    },
    coords = {
        C(0.474, 0.426, "Central Talbuk Thorngrazer"),
        C(0.502, 0.478, "Central-east Talbuk Thorngrazer"),
        C(0.604, 0.446, "Eastern Talbuk Stag"),
        C(0.662, 0.470, "East Nagrand talbuk range"),
        C(0.724, 0.486, "Far east Talbuk Stag"),
    },
    confidence = "high",
})

RegisterMeat(31670, "Raptor Ribs", {
    "https://www.wowhead.com/item=31670/raptor-ribs",
    "https://www.wowhead.com/npc=20728/bladespire-raptor",
    "https://www.wowhead.com/npc=20634/scythetooth-raptor",
}, "Raptor Ribs drop from Outland raptors. Blade's Edge has the easiest repeated pack route.", {
    id = "raptor-ribs-blades-edge-raptors",
    source = "Wowhead NPC map pins and cooking material farming guides",
    sourceUrls = {
        "https://www.wowhead.com/npc=20728/bladespire-raptor",
        "https://www.wowhead.com/npc=20634/scythetooth-raptor",
    },
    mapName = "Blade's Edge Mountains",
    location = "Bladespire Raptor packs in central Blade's Edge",
    routeType = "beast-meat-grind",
    density = "Medium",
    dropDifficulty = "Easy. Packs are localized and simple to loop.",
    tips = {
        "Circle the Bladespire raptor pockets before using Netherstorm as a backup.",
        "Skinning adds extra value if you can skin the kills.",
    },
    coords = {
        C(0.392, 0.554, "West Bladespire Raptor"),
        C(0.404, 0.534, "Central-west Bladespire Raptor"),
        C(0.418, 0.554, "Central Bladespire Raptor"),
        C(0.436, 0.530, "East Bladespire Raptor"),
        C(0.478, 0.522, "Far east Bladespire Raptor"),
    },
    confidence = "high",
})

RegisterMeat(31671, "Serpent Flesh", {
    "https://www.wowhead.com/item=31671/serpent-flesh",
    "https://www.wowhead.com/npc=23026/twilight-serpent",
    "https://www.wowhead.com/npc=20749/scalewing-serpent",
}, "Serpent Flesh drops from Outland serpents. Twilight Ridge and Scalewing Shelf both have coordinate-backed serpent routes.", {
    id = "serpent-flesh-nagrand-twilight-serpents",
    source = "Wowhead NPC map pins and cooking material farming guides",
    sourceUrls = {
        "https://www.wowhead.com/npc=23026/twilight-serpent",
        "https://www.wowhead.com/npc=20749/scalewing-serpent",
    },
    mapName = "Nagrand",
    location = "Twilight Serpents across Twilight Ridge",
    routeType = "beast-meat-grind",
    density = "Medium",
    dropDifficulty = "Moderate. Requires flying access but overlaps Cobra Scales.",
    tips = {
        "Use this when Cobra Scales are valuable; otherwise Scalewing Shelf can be easier.",
        "Skin every serpent if possible.",
    },
    coords = {
        C(0.074, 0.418, "Far west Twilight Serpent"),
        C(0.096, 0.442, "Western Twilight Serpent cluster"),
        C(0.124, 0.374, "Central Twilight Serpent cluster"),
        C(0.174, 0.316, "Eastern Twilight Serpent cluster"),
        C(0.200, 0.348, "Far east Twilight Serpent"),
    },
    confidence = "high",
})
