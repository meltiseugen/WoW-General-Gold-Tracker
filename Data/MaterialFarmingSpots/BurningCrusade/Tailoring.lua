local _, NS = ...
local Register = NS.RegisterMaterialFarmingSpot

local function C(x, y, label)
    return { x = x, y = y, label = label }
end

Register({
    itemID = 21877,
    itemName = "Netherweave Cloth",
    expansion = "burningCrusade",
    professions = { "tailoring" },
    category = "Cloth",
    researchStatus = "researched",
    sourceUrls = {
        "https://www.wowhead.com/item=21877/netherweave-cloth",
        "https://www.wow-professions.com/farming/netherweave-cloth-farming",
        "https://www.wowhead.com/npc=21302/shadow-council-warlock",
        "https://www.wowhead.com/npc=17981/voidspawn",
    },
    summary = "Core Burning Crusade cloth from humanoids and some void mobs. Legion Hold is a long-running cloth/rep farm, while Oshu'gun Voidspawns add Mote of Shadow side value.",
    spots = {
        {
            id = "netherweave-shadowmoon-legion-hold",
            source = "Wowhead item comments, Wowhead NPC map pins, and Netherweave farming guides",
            sourceUrls = {
                "https://www.wowhead.com/item=21877/netherweave-cloth",
                "https://www.wow-professions.com/farming/netherweave-cloth-farming",
                "https://www.wowhead.com/npc=21302/shadow-council-warlock",
            },
            mapName = "Shadowmoon Valley",
            location = "Legion Hold, killing Shadow Council Warlocks and nearby demons",
            routeType = "humanoid-cloth-grind",
            density = "Medium",
            dropDifficulty = "Good. The camp is compact, but watch the roaming elite.",
            tips = {
                "Use this when Aldor marks and Fel Armaments also have value.",
                "If Legion Hold feels nerfed or crowded, swap to Oshu'gun Voidspawns.",
            },
            coords = {
                { x = 0.222, y = 0.384, label = "North Legion Hold warlock" },
                { x = 0.224, y = 0.396, label = "Central Legion Hold warlock" },
                { x = 0.230, y = 0.384, label = "East Legion Hold warlock" },
                { x = 0.236, y = 0.400, label = "South Legion Hold warlock" },
            },
            confidence = "high",
        },
        {
            id = "netherweave-nagrand-oshugun-voidspawns",
            source = "Wowhead item comments and Wowhead NPC map pins",
            sourceUrls = {
                "https://www.wowhead.com/item=21877/netherweave-cloth",
                "https://www.wowhead.com/npc=17981/voidspawn",
            },
            mapName = "Nagrand",
            location = "Voidspawns around Oshu'gun",
            routeType = "voidwalker-cloth-grind",
            density = "Medium",
            dropDifficulty = "Good backup that also yields Mote of Shadow.",
            tips = {
                "Comments repeatedly praise Voidspawns for Netherweave plus shadow motes.",
                "Move around Oshu'gun instead of camping a single side.",
            },
            coords = {
                { x = 0.314, y = 0.696, label = "Northwest Oshu'gun Voidspawn" },
                { x = 0.332, y = 0.756, label = "West Oshu'gun Voidspawn" },
                { x = 0.374, y = 0.666, label = "North Oshu'gun Voidspawn" },
                { x = 0.394, y = 0.702, label = "Central Oshu'gun Voidspawn" },
                { x = 0.432, y = 0.704, label = "East Oshu'gun Voidspawn" },
            },
            confidence = "high",
        },
    },
})

Register({
    itemID = 21881,
    itemName = "Netherweb Spider Silk",
    expansion = "burningCrusade",
    professions = { "tailoring" },
    category = "Cloth",
    researchStatus = "researched",
    sourceUrls = {
        "https://www.wowhead.com/item=21881/netherweb-spider-silk",
        "https://www.wowhead.com/npc=18466/dreadfang-lurker",
        "https://www.wowhead.com/npc=18467/dreadfang-widow",
        "https://warcraft.wiki.gg/wiki/Netherweb_Spider_Silk",
    },
    summary = "Tailoring silk from Outland spiders. Terokkar Dreadfang spiders south of Allerian Stronghold are the best outdoor route; Black Morass is a private-instance backup with more travel friction.",
    spots = {
        {
            id = "netherweb-spider-silk-terokkar-dreadfang-route",
            source = "Retail Wowhead item comments, Dreadfang NPC pages, and Warcraft Wiki source list",
            sourceUrls = {
                "https://www.wowhead.com/item=21881/netherweb-spider-silk",
                "https://www.wowhead.com/npc=18466/dreadfang-lurker",
                "https://www.wowhead.com/npc=18467/dreadfang-widow",
            },
            mapName = "Terokkar Forest",
            location = "Dreadfang Lurkers and Widows from northern Terokkar to Netherweb Ridge south of Allerian Stronghold",
            routeType = "spider-silk-grind",
            density = "Medium to high",
            dropDifficulty = "RNG-heavy but practical. Retail Wowhead comments favor Terokkar outdoor spiders for speed and respawn flow.",
            tips = {
                "Use the 44, 32 northern spider pack when the Allerian route is crowded.",
                "Run north-south between Allerian Stronghold and Netherweb Ridge instead of camping one spawn.",
                "Watch for Deathskitter around the Allerian route if farming on a low-level character.",
            },
            coords = {
                C(0.440, 0.320, "Northern Terokkar spider pack"),
                C(0.550, 0.580, "Allerian Stronghold spider route"),
                C(0.510, 0.700, "Netherweb Ridge north edge"),
                C(0.470, 0.760, "Netherweb Ridge south edge"),
                C(0.360, 0.780, "Bone Wastes west spider route"),
                C(0.289, 0.788, "Sha'tari Base Camp southwest spider group"),
            },
            confidence = "high",
        },
    },
})
