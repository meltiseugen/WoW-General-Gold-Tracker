local _, NS = ...
local Register = NS.RegisterMaterialFarmingSpot
local Pins = NS.GetBurningCrusadeNpcCoords

local function C(x, y, label)
    return { x = x, y = y, label = label }
end

local BUZZARD_COORDS = Pins({ 16972 }, 100)
BUZZARD_COORDS[#BUZZARD_COORDS + 1] = C(0.610, 0.730, "Dense buzzard loop from retail comment")

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
    coords = BUZZARD_COORDS,
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
    coords = Pins({ 16934, 19349, 19350 }, 100),
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
    coords = Pins({ 17132, 17133 }, 107),
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
    coords = Pins({ 18464, 18465 }, 108),
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
    coords = Pins({ 17130, 17131 }, 107),
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
    coords = Pins({ 20728, 20634 }, 105),
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
    coords = Pins({ 23026 }, 107),
    confidence = "high",
})

local function RegisterAdditionalMeat(itemID, itemName, summary, spots)
    Register({
        itemID = itemID,
        itemName = itemName,
        expansion = "burningCrusade",
        professions = { "cooking" },
        category = "Meat",
        researchStatus = "researched",
        sourceUrls = { "https://www.wowhead.com/item=" .. itemID },
        summary = summary,
        spots = spots,
    })
end

RegisterAdditionalMeat(23676, "Moongraze Stag Tenderloin", "Azuremyst cooking meat with a near-guaranteed drop from Moongraze Stags and Bucks. Every Retail Wowhead spawn pin for both mobs is retained.", {
    {
        id = "moongraze-tenderloin-azuremyst-stags-bucks",
        source = "Complete Retail Wowhead NPC drop tables and map-pin sets",
        sourceUrls = {
            "https://www.wowhead.com/item=23676/moongraze-stag-tenderloin",
            "https://www.wowhead.com/npc=17200/moongraze-stag",
            "https://www.wowhead.com/npc=17201/moongraze-buck",
        },
        mapName = "Azuremyst Isle",
        location = "Moongraze Stags and Bucks throughout central and southern Azuremyst Isle",
        routeType = "beast-meat-grind",
        density = "Very high",
        dropDifficulty = "Easy. Both target mobs have an almost guaranteed meat drop.",
        tips = { "Sweep every marked stag and buck pocket; no close pins were removed." },
        coords = Pins({ 17200, 17201 }, 97),
        confidence = "high",
    },
})

RegisterAdditionalMeat(27668, "Lynx Meat", "Blood elf starting-zone cooking meat from Springpaw and Ghostclaw lynxes. Eversong and Ghostlands are preserved as separate full-pin farms.", {
    {
        id = "lynx-meat-eversong-springpaws",
        source = "Complete Retail Wowhead NPC drop tables and map-pin sets",
        sourceUrls = {
            "https://www.wowhead.com/item=27668/lynx-meat",
            "https://www.wowhead.com/npc=15651/springpaw-stalker",
            "https://www.wowhead.com/npc=15652/elder-springpaw",
        },
        mapName = "Eversong Woods",
        location = "Springpaw Stalkers and Elder Springpaws across Eversong Woods",
        routeType = "beast-meat-grind",
        density = "Very high",
        dropDifficulty = "Easy.",
        tips = { "Use the Eversong sweep when you also want Olemba Lumber." },
        coords = Pins({ 15651, 15652 }, 94),
        confidence = "high",
    },
    {
        id = "lynx-meat-ghostlands-ghostclaws",
        source = "Complete Retail Wowhead NPC drop tables and map-pin sets",
        sourceUrls = {
            "https://www.wowhead.com/item=27668/lynx-meat",
            "https://www.wowhead.com/npc=16347/starving-ghostclaw",
            "https://www.wowhead.com/npc=16348/ghostclaw-lynx",
            "https://www.wowhead.com/npc=16349/ghostclaw-ravager",
        },
        mapName = "Ghostlands",
        location = "Starving Ghostclaws, Ghostclaw Lynxes, and Ghostclaw Ravagers throughout Ghostlands",
        routeType = "beast-meat-grind",
        density = "Very high",
        dropDifficulty = "Easy.",
        tips = { "This route overlaps the Bat Flesh sources and Olemba Lumber." },
        coords = Pins({ 16347, 16348, 16349 }, 95),
        confidence = "high",
    },
})

RegisterAdditionalMeat(27669, "Bat Flesh", "Ghostlands cooking meat from Lesser Scourgebats and Vampiric Mistbats. All currently published mob pins are retained.", {
    {
        id = "bat-flesh-ghostlands-mistbats-scourgebats",
        source = "Complete Retail Wowhead NPC drop tables and map-pin sets",
        sourceUrls = {
            "https://www.wowhead.com/item=27669/bat-flesh",
            "https://www.wowhead.com/npc=16354/vampiric-mistbat",
            "https://www.wowhead.com/npc=16355/lesser-scourgebat",
        },
        mapName = "Ghostlands",
        location = "Vampiric Mistbats and Lesser Scourgebats throughout Ghostlands",
        routeType = "beast-meat-grind",
        density = "High",
        dropDifficulty = "Easy.",
        tips = { "Combine this with Lynx Meat and Olemba Lumber instead of flying a bat-only line." },
        coords = Pins({ 16354, 16355 }, 95),
        confidence = "high",
    },
})

RegisterAdditionalMeat(27677, "Chunk o' Basilisk", "Outland basilisk cooking meat. Terokkar, Zangarmarsh, and Blade's Edge mob families are kept as separate farms with every published spawn pin.", {
    {
        id = "chunk-basilisk-terokkar-dampscale-ironspine",
        source = "Complete Retail Wowhead NPC drop tables and map-pin sets",
        sourceUrls = {
            "https://www.wowhead.com/item=27677/chunk-o-basilisk",
            "https://www.wowhead.com/npc=18461/dampscale-basilisk",
            "https://www.wowhead.com/npc=18463/dampscale-devourer",
            "https://www.wowhead.com/npc=21816/ironspine-chomper",
        },
        mapName = "Terokkar Forest",
        location = "Dampscale and Ironspine basilisks across eastern Terokkar",
        routeType = "beast-meat-grind",
        density = "High",
        dropDifficulty = "Easy; skinning adds Fel Scales and Crystal-Infused Leather.",
        tips = { "Retain both the riverbank and ridge clusters." },
        coords = Pins({ 18461, 18463, 21816 }, 108),
        confidence = "high",
    },
    {
        id = "chunk-basilisk-zangarmarsh-marshrock-ragestone",
        source = "Complete Retail Wowhead NPC drop tables and map-pin sets",
        sourceUrls = {
            "https://www.wowhead.com/npc=19706/marshrock-threshalisk",
            "https://www.wowhead.com/npc=20279/ragestone-threshalisk",
            "https://www.wowhead.com/npc=20283/marshrock-stomper",
        },
        mapName = "Zangarmarsh",
        location = "Marshrock and Ragestone basilisk pockets",
        routeType = "beast-meat-grind",
        density = "Medium",
        dropDifficulty = "Easy.",
        tips = { "Use this as a separate alternative rather than merging it into Terokkar." },
        coords = Pins({ 19706, 20279, 20283 }, 102),
        confidence = "high",
    },
    {
        id = "chunk-basilisk-blades-edge-ruuan-weald",
        source = "Complete Retail Wowhead NPC drop table and map-pin set",
        sourceUrls = { "https://www.wowhead.com/npc=20987/ruuan-weald-basilisk" },
        mapName = "Blade's Edge Mountains",
        location = "Ruuan Weald Basilisk pocket",
        routeType = "beast-meat-grind",
        density = "Low",
        dropDifficulty = "Easy but less dense than Terokkar.",
        tips = { "Keep this small pocket as an independent fallback." },
        coords = Pins({ 20987 }, 105),
        confidence = "high",
    },
})
