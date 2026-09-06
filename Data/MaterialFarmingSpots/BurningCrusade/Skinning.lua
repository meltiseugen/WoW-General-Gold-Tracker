local _, NS = ...
local Register = NS.RegisterMaterialFarmingSpot

local function C(x, y, label)
    return { x = x, y = y, label = label }
end

local function RegisterSkinning(itemID, itemName, category, sourceUrls, summary, spots)
    Register({
        itemID = itemID,
        itemName = itemName,
        expansion = "burningCrusade",
        professions = { "skinning", "leatherworking" },
        category = category,
        researchStatus = "researched",
        sourceUrls = sourceUrls,
        summary = summary,
        spots = spots,
    })
end

local RAVAGER_HELLFIRE_COORDS = {
    C(0.214, 0.654, "Quillfang Ravager western pack"),
    C(0.222, 0.670, "Quillfang Ravager central pack"),
    C(0.234, 0.650, "Quillfang Ravager eastern pack"),
    C(0.046, 0.504, "Thornfang Ravager western pack"),
    C(0.094, 0.522, "Thornfang Hill ravager pack"),
    C(0.126, 0.476, "Thornfang Venomspitter pack"),
}

local NAGRAND_CLEFTHOOF_COORDS = {
    C(0.240, 0.472, "Aged Clefthoof western route"),
    C(0.282, 0.334, "Northwest Aged Clefthoof"),
    C(0.304, 0.632, "Southern Aged Clefthoof loop"),
    C(0.438, 0.718, "South-central Clefthoof Bull"),
    C(0.496, 0.520, "Central Clefthoof Bull"),
    C(0.604, 0.390, "Eastern Clefthoof herd"),
}

RegisterSkinning(25649, "Knothide Leather Scraps", "Scrap", {
    "https://www.wowhead.com/item=25649/knothide-leather-scraps",
    "https://www.wowhead.com/npc=16934/quillfang-ravager",
    "https://www.wowhead.com/npc=19349/thornfang-ravager",
}, "Base Outland skinning scrap from lower-level beasts. Hellfire ravager routes are the cleanest early farm and also feed Fel Scales routes.", {
    {
        id = "knothide-scraps-hellfire-ravagers",
        source = "Wowhead NPC map pins and TBC skinning route notes",
        sourceUrls = {
            "https://www.wowhead.com/npc=16934/quillfang-ravager",
            "https://www.wowhead.com/npc=19349/thornfang-ravager",
            "https://www.wowhead.com/item=25649/knothide-leather-scraps",
        },
        mapName = "Hellfire Peninsula",
        location = "Quillfang and Thornfang ravager packs around western Hellfire and Thornfang Hill",
        routeType = "skinning-loop",
        density = "High",
        dropDifficulty = "Easy. Lower-level ravagers die quickly and are close together.",
        tips = {
            "Use this as the starter Outland skinning route.",
            "Expect Knothide Leather, Fel Scales, and occasional Crystal-Infused Leather as side materials.",
        },
        coords = RAVAGER_HELLFIRE_COORDS,
        confidence = "high",
    },
})

RegisterSkinning(21887, "Knothide Leather", "Leather", {
    "https://www.wow-professions.com/farming/knothide-leather-farming",
    "https://www.wowhead.com/item=21887/knothide-leather",
    "https://www.wowhead.com/npc=17133/aged-clefthoof",
}, "Base Outland leather from most skinnable beasts. Nagrand clefthoofs are a practical open-world route with valuable Thick Clefthoof Leather side drops.", {
    {
        id = "knothide-nagrand-clefthoof-loop",
        source = "Wowhead NPC map pins, Wowhead comments, and skinning farming guides",
        sourceUrls = {
            "https://www.wowhead.com/item=21887/knothide-leather",
            "https://www.wowhead.com/npc=17133/aged-clefthoof",
            "https://www.wow-professions.com/farming/knothide-leather-farming",
        },
        mapName = "Nagrand",
        location = "Clefthoof and Aged Clefthoof packs across western and central Nagrand",
        routeType = "skinning-loop",
        density = "High",
        dropDifficulty = "Good open-world farm with several dense herd pockets.",
        tips = {
            "Use Track Beasts if available and keep moving between clefthoof packs.",
            "Pair this with Thick Clefthoof Leather rather than farming Knothide alone.",
        },
        coords = NAGRAND_CLEFTHOOF_COORDS,
        confidence = "high",
    },
})

RegisterSkinning(25699, "Crystal-Infused Leather", "Leather", {
    "https://www.wowhead.com/item=25699/crystal-infused-leather",
    "https://www.wowhead.com/npc=19349/thornfang-ravager",
    "https://www.wowhead.com/npc=18463/dampscale-devourer",
}, "Rare Outland skinning material associated with ravagers and basilisks. It is best tracked as side value while farming Fel Scales.", {
    {
        id = "crystal-infused-hellfire-ravagers",
        source = "Wowhead NPC map pins and item drop tables",
        sourceUrls = {
            "https://www.wowhead.com/item=25699/crystal-infused-leather",
            "https://www.wowhead.com/npc=19349/thornfang-ravager",
        },
        mapName = "Hellfire Peninsula",
        location = "Western Hellfire Thornfang and Quillfang ravagers",
        routeType = "skinning-loop",
        density = "High",
        dropDifficulty = "Good side drop while farming Fel Scales; inefficient if farmed alone.",
        tips = {
            "Run the same ravager route as Fel Scales.",
            "Switch to Terokkar basilisks if Hellfire is crowded.",
        },
        coords = RAVAGER_HELLFIRE_COORDS,
        confidence = "medium",
    },
})

RegisterSkinning(25700, "Fel Scales", "Scale", {
    "https://www.wow-professions.com/farming/fel-scales-farming",
    "https://www.wowhead.com/npc=19349/thornfang-ravager",
    "https://www.wowhead.com/npc=18463/dampscale-devourer",
    "https://artisansofazeroth.com/fel-scales-farming/",
}, "Outland skinning scale from ravagers and basilisks. Hellfire ravagers are the simplest route; Terokkar Dampscale basilisks are a good backup.", {
    {
        id = "fel-scales-hellfire-thornfang-ravagers",
        source = "Wowhead NPC map pins, Wowhead comments, and Fel Scales farming guides",
        sourceUrls = {
            "https://www.wowhead.com/npc=19349/thornfang-ravager",
            "https://www.wowhead.com/npc=19350/thornfang-venomspitter",
            "https://www.wow-professions.com/farming/fel-scales-farming",
        },
        mapName = "Hellfire Peninsula",
        location = "Thornfang Hill and western Hellfire ravager packs",
        routeType = "skinning-loop",
        density = "High",
        dropDifficulty = "Easy to moderate. Ravagers respawn quickly and lower-level packs are efficient to kill.",
        tips = {
            "Farm ravagers in compact western Hellfire pockets rather than chasing higher-level mobs.",
            "Expect Knothide scraps, Knothide Leather, and Crystal-Infused Leather as side materials.",
        },
        coords = RAVAGER_HELLFIRE_COORDS,
        confidence = "high",
    },
    {
        id = "fel-scales-terokkar-dampscale-basilisks",
        source = "Wowhead NPC map pins and item drop tables",
        sourceUrls = {
            "https://www.wowhead.com/npc=18463/dampscale-devourer",
            "https://www.wowhead.com/npc=18648/stonegazer",
            "https://artisansofazeroth.com/fel-scales-farming/",
        },
        mapName = "Terokkar Forest",
        location = "Dampscale Devourers and Stonegazer basilisks along eastern Terokkar river banks",
        routeType = "skinning-loop",
        density = "Medium",
        dropDifficulty = "More travel than Hellfire, but useful when ravagers are contested.",
        tips = {
            "Follow the eastern river banks and kill basilisks as they respawn.",
            "Skin every basilisk; Crystal-Infused Leather can appear as side value.",
        },
        coords = {
            C(0.5296, 0.2984, "AoA north Terokkar Fel Scale route pin"),
            C(0.530, 0.422, "Northern Dampscale river bank"),
            C(0.5882, 0.3043, "AoA northeast Terokkar Fel Scale route pin"),
            C(0.596, 0.374, "Central Dampscale river bank"),
            C(0.6012, 0.3846, "AoA central Terokkar basilisk pin"),
            C(0.628, 0.438, "Eastern Dampscale cluster"),
            C(0.6390, 0.4504, "AoA eastern Terokkar basilisk pin"),
            C(0.686, 0.436, "Southern Dampscale river bank"),
            C(0.638, 0.294, "Stonegazer basilisk ridge"),
        },
        confidence = "medium",
    },
})

RegisterSkinning(25707, "Fel Hide", "Hide", {
    "https://www.wow-professions.com/farming/fel-hide-farming",
    "https://www.wowhead.com/npc=19852/artifact-seeker",
    "https://www.wowhead.com/npc=19853/felblade-doomguard",
}, "Rare Outland hide from skinnable demon-like mobs. Netherstorm Arklon Ruins are the cleanest coordinate-backed route.", {
    {
        id = "fel-hide-netherstorm-arklon-ruins",
        source = "Wowhead NPC map pins and Fel Hide farming guides",
        sourceUrls = {
            "https://www.wowhead.com/npc=19852/artifact-seeker",
            "https://www.wowhead.com/npc=19853/felblade-doomguard",
            "https://www.wow-professions.com/farming/fel-hide-farming",
        },
        mapName = "Netherstorm",
        location = "Arklon Ruins near Area 52, killing Artifact Seekers and nearby demon packs",
        routeType = "skinning-loop",
        density = "High",
        dropDifficulty = "Good respawn rate; casters may dislike Mana Burn and Spell Lock.",
        tips = {
            "Loop the Arklon Ruins floor and skin every eligible demon-beast corpse.",
            "Use defensive pulls if Mana Burn or Spell Lock slows your character down.",
        },
        coords = {
            C(0.384, 0.714, "Arklon Ruins western Artifact Seeker"),
            C(0.394, 0.726, "Arklon Ruins north cluster"),
            C(0.404, 0.742, "Arklon Ruins center cluster"),
            C(0.418, 0.718, "Arklon Ruins eastern cluster"),
            C(0.424, 0.744, "Arklon Ruins southeast cluster"),
        },
        confidence = "high",
    },
})

RegisterSkinning(25708, "Thick Clefthoof Leather", "Leather", {
    "https://www.wow-professions.com/farming/thick-clefthoof-leather-farming",
    "https://www.wowhead.com/npc=17133/aged-clefthoof",
    "https://www.wowhead.com/npc=17132/clefthoof-bull",
}, "Nagrand clefthoof skinning material with strong Leatherworking demand. Western and central Nagrand herd loops are the strongest route.", {
    {
        id = "thick-clefthoof-nagrand-herd-loop",
        source = "Wowhead NPC map pins, Wowhead comments, and Thick Clefthoof farming guides",
        sourceUrls = {
            "https://www.wowhead.com/npc=17133/aged-clefthoof",
            "https://www.wowhead.com/npc=17132/clefthoof-bull",
            "https://www.wow-professions.com/farming/thick-clefthoof-leather-farming",
        },
        mapName = "Nagrand",
        location = "Clefthoof Bulls and Aged Clefthoofs west, south, and east of Garadar",
        routeType = "skinning-loop",
        density = "High",
        dropDifficulty = "Good. Multiple dense herd pockets support a continuous loop.",
        tips = {
            "Start southwest of Garadar, move through bull herds, then turn back once the first packs respawn.",
            "Use Track Beasts if available; the area has few irrelevant red beast targets.",
        },
        coords = NAGRAND_CLEFTHOOF_COORDS,
        confidence = "high",
    },
})

RegisterSkinning(29539, "Cobra Scales", "Scale", {
    "https://www.wow-professions.com/farming/cobra-scales-farming",
    "https://www.wowhead.com/npc=23026/twilight-serpent",
    "https://www.wowhead.com/npc=19784/coilskar-cobra",
}, "Premium Outland scale from skinning Twilight Serpents, Coilskar Cobras, and Shadowmoon serpents. Nagrand Twilight Ridge and Shadowmoon Coilskar Cistern are both coordinate-backed farms.", {
    {
        id = "cobra-scales-nagrand-twilight-serpents",
        source = "Wowhead NPC map pins, Wowhead comments, and Cobra Scales farming guides",
        sourceUrls = {
            "https://www.wowhead.com/npc=23026/twilight-serpent",
            "https://www.wow-professions.com/farming/cobra-scales-farming",
        },
        mapName = "Nagrand",
        location = "Twilight Ridge, farming Twilight Serpents across the western plateau",
        routeType = "skinning-loop",
        density = "Medium",
        dropDifficulty = "Moderate. Requires flying access and the drop can feel streaky, but the spawn area is compact.",
        tips = {
            "Sweep the ridge from west to east, then return as the first serpents respawn.",
            "Stay on non-elite serpent pulls if the western end is awkward.",
            "Mana Thistle and Dreaming Glory can add herbalism side value nearby.",
        },
        coords = {
            C(0.074, 0.418, "Far west Twilight Serpent"),
            C(0.096, 0.442, "Western Twilight Serpent cluster"),
            C(0.124, 0.374, "Central Twilight Serpent cluster"),
            C(0.174, 0.316, "Eastern Twilight Serpent cluster"),
            C(0.200, 0.348, "Far east Twilight Serpent"),
        },
        confidence = "high",
    },
    {
        id = "cobra-scales-shadowmoon-coilskar-cobras",
        source = "Wowhead NPC map pins and Cobra Scales farming guides",
        sourceUrls = {
            "https://www.wowhead.com/npc=19784/coilskar-cobra",
            "https://www.wowhead.com/item=29539/cobra-scales",
        },
        mapName = "Shadowmoon Valley",
        location = "Coilskar Cistern and Coilskar cave approaches, farming Coilskar Cobras",
        routeType = "skinning-loop",
        density = "Medium",
        dropDifficulty = "More awkward than Nagrand because cave pulls and nearby naga can slow the route.",
        tips = {
            "Kill Coilskar Cobras outside the cave first; only farm inside if your character can handle the extra pulls.",
            "Use the outside Cistern cluster when you want a cleaner route.",
        },
        coords = {
            C(0.454, 0.294, "Southwest Coilskar Cobra"),
            C(0.476, 0.308, "South Coilskar Cobra"),
            C(0.516, 0.226, "Coilskar cave approach"),
            C(0.534, 0.224, "Coilskar Cistern center"),
            C(0.560, 0.216, "Northeast Coilskar Cobra"),
        },
        confidence = "high",
    },
})

RegisterSkinning(29547, "Wind Scales", "Scale", {
    "https://www.wow-professions.com/farming/wind-scales-farming",
    "https://www.wowhead.com/npc=20502/eclipsion-dragonhawk",
    "https://www.wowhead.com/npc=20749/scalewing-serpent",
}, "Outland scale from dragonhawk and serpent skinning. Shadowmoon Eclipsion Dragonhawks are the preferred route; Scalewing Shelf is a strong backup.", {
    {
        id = "wind-scales-shadowmoon-eclipsion-dragonhawks",
        source = "Wowhead NPC map pins and Wind Scales farming guides",
        sourceUrls = {
            "https://www.wowhead.com/npc=20502/eclipsion-dragonhawk",
            "https://www.wow-professions.com/farming/wind-scales-farming",
        },
        mapName = "Shadowmoon Valley",
        location = "Eclipsion Dragonhawks south of Eclipse Point",
        routeType = "skinning-loop",
        density = "High",
        dropDifficulty = "Good targeted route; watch nearby hostile camps.",
        tips = {
            "Circle the dragonhawk clusters and skin before moving to the next pocket.",
            "Switch to Scalewing Shelf if Shadowmoon is contested.",
        },
        coords = {
            C(0.436, 0.682, "West Eclipsion Dragonhawk"),
            C(0.452, 0.668, "Northwest Eclipsion Dragonhawk"),
            C(0.468, 0.706, "Central Eclipsion Dragonhawk"),
            C(0.484, 0.654, "East Eclipsion Dragonhawk"),
            C(0.516, 0.604, "Northeast Eclipsion Dragonhawk"),
        },
        confidence = "high",
    },
    {
        id = "wind-scales-blades-edge-scalewing-shelf",
        source = "Wowhead NPC map pins and Wind Scales farming guides",
        sourceUrls = {
            "https://www.wowhead.com/npc=20749/scalewing-serpent",
            "https://www.wowhead.com/npc=20751/daggermaw-lashtail",
        },
        mapName = "Blade's Edge Mountains",
        location = "Scalewing Shelf near Toshley's Station",
        routeType = "skinning-loop",
        density = "Medium",
        dropDifficulty = "Mobs are spread out; crisscross the shelf to keep kills flowing.",
        tips = {
            "Kill Scalewing Serpents and Daggermaw Lashtails.",
            "The shelf route also supports Serpent Flesh side farming.",
        },
        coords = {
            C(0.614, 0.542, "Northwest Scalewing Shelf"),
            C(0.650, 0.504, "North Scalewing Shelf"),
            C(0.668, 0.604, "Central Scalewing Shelf"),
            C(0.680, 0.698, "South Scalewing Shelf"),
            C(0.686, 0.742, "Far south Scalewing Shelf"),
        },
        confidence = "medium",
    },
})

RegisterSkinning(29548, "Nether Dragonscales", "Scale", {
    "https://www.wow-professions.com/farming/nether-dragonscale-farming",
    "https://www.wowhead.com/npc=18877/nether-drake",
    "https://www.wowhead.com/npc=20021/nether-whelp",
}, "Outland dragonkin skinning material. Netherstorm Celestial Ridge and Blade's Edge Singing Ridge are coordinate-backed farms.", {
    {
        id = "nether-dragonscales-netherstorm-celestial-ridge",
        source = "Wowhead NPC map pins and Nether Dragonscale farming guides",
        sourceUrls = {
            "https://www.wowhead.com/npc=18877/nether-drake",
            "https://www.wow-professions.com/farming/nether-dragonscale-farming",
        },
        mapName = "Netherstorm",
        location = "Celestial Ridge nether drakes and dragons",
        routeType = "skinning-loop",
        density = "Medium",
        dropDifficulty = "Good drop reports, but respawns can be slower than Blade's Edge.",
        tips = {
            "Loop the Celestial Ridge platform and kill every skinnable nether dragonkin.",
            "Use Blade's Edge if Netherstorm travel feels too spread out.",
        },
        coords = {
            C(0.692, 0.342, "West Celestial Ridge drake"),
            C(0.700, 0.400, "Central Celestial Ridge drake"),
            C(0.722, 0.386, "East Celestial Ridge drake"),
            C(0.734, 0.420, "Southeast Celestial Ridge drake"),
            C(0.746, 0.386, "Far east Celestial Ridge drake"),
        },
        confidence = "high",
    },
    {
        id = "nether-dragonscales-blades-edge-singing-ridge",
        source = "Wowhead NPC map pins and Nether Dragonscale farming guides",
        sourceUrls = {
            "https://www.wowhead.com/npc=20021/nether-whelp",
            "https://www.wowhead.com/item=29548/nether-dragonscales",
        },
        mapName = "Blade's Edge Mountains",
        location = "Singing Ridge nether whelps and nearby dragonkin",
        routeType = "skinning-loop",
        density = "Medium",
        dropDifficulty = "Easy. Lower-level dragonkin make the loop smooth on modern characters.",
        tips = {
            "Stay on Singing Ridge and reset the route once the first whelps respawn.",
            "If Netherwing reputation affects nearby dragons elsewhere, use neutral dragonkin routes instead.",
        },
        coords = {
            C(0.586, 0.726, "Northwest Singing Ridge whelp"),
            C(0.602, 0.760, "Central Singing Ridge whelp"),
            C(0.622, 0.762, "East Singing Ridge whelp"),
            C(0.644, 0.754, "Southeast Singing Ridge whelp"),
            C(0.672, 0.754, "Far southeast Singing Ridge whelp"),
        },
        confidence = "medium",
    },
})
