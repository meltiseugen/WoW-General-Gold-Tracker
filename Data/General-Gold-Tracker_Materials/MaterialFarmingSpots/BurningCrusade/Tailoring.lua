local _, NS = ...
local Register = NS.RegisterMaterialFarmingSpot
local Pins = NS.GetBurningCrusadeNpcCoords

local function C(x, y, label)
    return { x = x, y = y, label = label }
end

local DREADFANG_COORDS = Pins({ 18466, 18467 }, 108)
DREADFANG_COORDS[#DREADFANG_COORDS + 1] = C(0.440, 0.320, "Retail Wowhead comment northern spider pack")

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
            coords = Pins({ 21302 }, 104),
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
            coords = Pins({ 17981 }, 107),
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
            coords = DREADFANG_COORDS,
            confidence = "high",
        },
    },
})
