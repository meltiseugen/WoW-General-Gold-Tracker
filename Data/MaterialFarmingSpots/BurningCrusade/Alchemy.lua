local _, NS = ...
local Register = NS.RegisterMaterialFarmingSpot
local Pins = NS.GetBurningCrusadeNpcCoords

local function C(x, y, label)
    return { x = x, y = y, label = label }
end

local function RegisterMote(itemID, itemName, professions, sourceUrls, summary, spots)
    Register({
        itemID = itemID,
        itemName = itemName,
        expansion = "burningCrusade",
        professions = professions,
        category = "Mote",
        researchStatus = "researched",
        sourceUrls = sourceUrls,
        summary = summary,
        spots = spots,
    })
end

RegisterMote(22572, "Mote of Air", { "alchemy", "engineering" }, {
    "https://www.wow-professions.com/farming/mote-of-air-farming",
    "https://www.wowhead.com/npc=21060/enraged-air-spirit",
}, "Air mote used to create Primal Air. Shadowmoon Valley Enraged Air Spirits are the cleanest non-engineering source.", {
    {
        id = "mote-air-shadowmoon-enraged-air-spirits",
        source = "Wowhead NPC map pins and Primal Air farming guides",
        sourceUrls = {
            "https://www.wowhead.com/npc=21060/enraged-air-spirit",
            "https://www.wow-professions.com/farming/mote-of-air-farming",
        },
        mapName = "Shadowmoon Valley",
        location = "Enraged Air Spirits along Netherwing Fields and southern Shadowmoon ridges",
        routeType = "elemental-grind",
        density = "Medium",
        dropDifficulty = "Good. Mobs are spread across several pockets, so loop instead of camping one spawn.",
        tips = {
            "Start at the Netherwing Fields cluster, then sweep north toward smaller ridge pockets.",
            "Pair this with nearby Cobra Scales if you can skin Shadow Serpents.",
        },
        coords = Pins({ 21060 }, 104),
        confidence = "high",
    },
})

RegisterMote(22573, "Mote of Earth", { "mining", "alchemy", "engineering" }, {
    "https://www.wow-professions.com/farming/mote-of-earth-farming",
    "https://www.wowhead.com/npc=17157/shattered-rumbler",
    "https://www.wowhead.com/object=181556/adamantite-deposit",
}, "Earth mote used to create Primal Earth. Shattered Rumblers in southern Nagrand are the best targeted route.", {
    {
        id = "mote-earth-nagrand-shattered-rumblers",
        source = "Wowhead NPC map pins and Primal Earth farming guides",
        sourceUrls = {
            "https://www.wowhead.com/npc=17157/shattered-rumbler",
            "https://www.wow-professions.com/farming/mote-of-earth-farming",
        },
        mapName = "Nagrand",
        location = "Shattered Rumblers along the southern Nagrand chasm route",
        routeType = "elemental-grind",
        density = "Medium",
        dropDifficulty = "Good. The route is long and linear, so fly back to the start once you run out of mobs.",
        tips = {
            "Run west to east along the chasm, then loop back once the first mobs respawn.",
            "Mine Adamantite nearby for extra Mote of Earth and Eternium chances.",
        },
        coords = Pins({ 17157 }, 107),
        confidence = "high",
    },
})

RegisterMote(22574, "Mote of Fire", { "mining", "alchemy" }, {
    "https://www.wow-professions.com/farming/mote-of-fire-farming",
    "https://www.wowhead.com/npc=22323/incandescent-fel-spark",
    "https://www.wowhead.com/npc=21061/enraged-fire-spirit",
}, "Fire mote used to create Primal Fire. Throne of Kil'jaeden is the strongest focused route; Shadowmoon Fel Pits are the lower-pressure backup.", {
    {
        id = "mote-fire-hellfire-throne-of-kiljaeden",
        source = "Wowhead NPC map pins and Primal Fire farming guides",
        sourceUrls = {
            "https://www.wowhead.com/npc=22323/incandescent-fel-spark",
            "https://www.wow-professions.com/farming/mote-of-fire-farming",
        },
        mapName = "Hellfire Peninsula",
        location = "Throne of Kil'jaeden, killing Incandescent Fel Sparks",
        routeType = "elemental-grind",
        density = "High",
        dropDifficulty = "Strong but popular. Requires access to the northern plateau.",
        tips = {
            "Circle the fire elemental spawns and avoid wasting time on unkillable Felblood Initiates.",
            "Switch to Shadowmoon if the plateau is crowded.",
        },
        coords = Pins({ 22323 }, 100),
        confidence = "high",
    },
    {
        id = "mote-fire-shadowmoon-fel-pits",
        source = "Wowhead NPC map pins and Primal Fire farming guides",
        sourceUrls = {
            "https://www.wowhead.com/npc=21061/enraged-fire-spirit",
            "https://www.wow-professions.com/farming/mote-of-fire-farming",
        },
        mapName = "Shadowmoon Valley",
        location = "Fel Pits lower levels, killing Enraged Fire Spirits",
        routeType = "elemental-grind",
        density = "Medium",
        dropDifficulty = "Lower rate than Throne of Kil'jaeden, but usually less contested.",
        tips = {
            "Circle the lower Fel Pits lava pockets.",
            "Earth elementals on the rim can add mixed mote value if the fire route runs dry.",
        },
        coords = Pins({ 21061 }, 104),
        confidence = "medium",
    },
})

RegisterMote(22575, "Mote of Life", { "herbalism", "alchemy" }, {
    "https://www.wow-professions.com/farming/mote-of-life-farming",
    "https://www.wowhead.com/npc=18124/withered-giant",
    "https://www.wowhead.com/npc=18125/starving-fungal-giant",
}, "Life mote used to create Primal Life. Zangarmarsh bog giants are the default kill route, and Herbalism adds corpse-gathering value.", {
    {
        id = "mote-life-zangarmarsh-bog-giants",
        source = "Wowhead NPC map pins and Primal Life farming guides",
        sourceUrls = {
            "https://www.wowhead.com/npc=18124/withered-giant",
            "https://www.wowhead.com/npc=18125/starving-fungal-giant",
            "https://www.wow-professions.com/farming/mote-of-life-farming",
        },
        mapName = "Zangarmarsh",
        location = "Bog giant pockets in eastern Dead Mire and western Spawning Glen",
        routeType = "plant-mob-grind",
        density = "High",
        dropDifficulty = "Good. Herbalists get extra value by gathering eligible corpses after looting.",
        tips = {
            "Kill, loot, then herb-gather eligible bog giant corpses before moving.",
            "Use the eastern Dead Mire cluster when you want the tightest kill loop.",
        },
        coords = Pins({ 18124, 18125 }, 102),
        confidence = "high",
    },
})

RegisterMote(22576, "Mote of Mana", { "alchemy", "engineering" }, {
    "https://www.wow-professions.com/farming/mote-of-mana-farming",
    "https://www.wowhead.com/npc=18864/mana-wraith",
}, "Mana mote used to create Primal Mana. Netherstorm is the dominant zone, especially mana creatures around Area 52.", {
    {
        id = "mote-mana-netherstorm-mana-wraiths",
        source = "Wowhead NPC map pins and Primal Mana farming guides",
        sourceUrls = {
            "https://www.wowhead.com/npc=18864/mana-wraith",
            "https://www.wow-professions.com/farming/mote-of-mana-farming",
        },
        mapName = "Netherstorm",
        location = "Mana Wraith clusters above Area 52",
        routeType = "mana-creature-grind",
        density = "High",
        dropDifficulty = "Strong. Respawns are compact, but the route is popular.",
        tips = {
            "Sweep the Area 52 ridge, then expand south if the main cluster is empty.",
            "Pair with Netherbloom and mining routes if pure mote value is weak.",
        },
        coords = Pins({ 18864 }, 109),
        confidence = "high",
    },
})

RegisterMote(22577, "Mote of Shadow", { "alchemy", "enchanting" }, {
    "https://www.wow-professions.com/farming/mote-of-shadow-farming",
    "https://www.wowhead.com/npc=17014/collapsing-voidwalker",
    "https://www.wowhead.com/npc=17981/voidspawn",
}, "Shadow mote used to create Primal Shadow. Void Ridge in Hellfire is the dense default route; Nagrand Oshu'gun Voidspawns are a strong cloth-and-mote backup.", {
    {
        id = "mote-shadow-hellfire-void-ridge",
        source = "Wowhead NPC map pins and Primal Shadow farming guides",
        sourceUrls = {
            "https://www.wowhead.com/npc=17014/collapsing-voidwalker",
            "https://www.wow-professions.com/farming/mote-of-shadow-farming",
        },
        mapName = "Hellfire Peninsula",
        location = "Void Ridge, west of Zeth'Gor",
        routeType = "voidwalker-grind",
        density = "High",
        dropDifficulty = "Steady and accessible. Watch Collapsing Voidwalker explosions at low health.",
        tips = {
            "Move along the ridge instead of camping a single cluster.",
            "Keep distance from Collapsing Voidwalkers when they are about to die.",
        },
        coords = Pins({ 17014 }, 100),
        confidence = "high",
    },
    {
        id = "mote-shadow-nagrand-oshugun-voidspawns",
        source = "Wowhead NPC map pins and Wowhead item comments",
        sourceUrls = {
            "https://www.wowhead.com/npc=17981/voidspawn",
            "https://www.wowhead.com/item=21877/netherweave-cloth",
        },
        mapName = "Nagrand",
        location = "Voidspawns around Oshu'gun",
        routeType = "voidwalker-grind",
        density = "Medium",
        dropDifficulty = "Good backup that also yields Netherweave Cloth.",
        tips = {
            "Use this route when Void Ridge is crowded.",
            "Oshu'gun Crystal Powder Samples are useful side drops if you still need Halaa turn-ins.",
        },
        coords = Pins({ 17981 }, 107),
        confidence = "high",
    },
})

RegisterMote(22578, "Mote of Water", { "alchemy", "engineering" }, {
    "https://www.wow-professions.com/farming/mote-of-water-farming",
    "https://www.wowhead.com/npc=17153/lake-spirit",
    "https://www.wowhead.com/object=182957/highland-mixed-school",
}, "Water mote used to create Primal Water. Nagrand lake elementals and highland fishing pools are practical routes.", {
    {
        id = "mote-water-nagrand-lake-spirits",
        source = "Wowhead NPC map pins and Primal Water farming guides",
        sourceUrls = {
            "https://www.wowhead.com/npc=17153/lake-spirit",
            "https://www.wow-professions.com/farming/mote-of-water-farming",
        },
        mapName = "Nagrand",
        location = "Lake Spirits in Skysong Lake northeast of Halaa",
        routeType = "water-elemental-grind",
        density = "Medium",
        dropDifficulty = "Good. Elementals are concentrated around a clear lake route.",
        tips = {
            "Circle the lake and kill elementals while checking fishing pools.",
            "This route can be paired with Icefin Bluefish and Figluster's Mudfish pool checks.",
        },
        coords = Pins({ 17153 }, 107),
        confidence = "high",
    },
})
