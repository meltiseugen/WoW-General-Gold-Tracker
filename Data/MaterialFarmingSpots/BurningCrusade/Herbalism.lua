local _, NS = ...
local Register = NS.RegisterMaterialFarmingSpot

local function C(x, y, label)
    return { x = x, y = y, label = label }
end

local function RegisterHerb(itemID, itemName, sourceUrls, summary, spot)
    Register({
        itemID = itemID,
        itemName = itemName,
        expansion = "burningCrusade",
        professions = { "herbalism", "alchemy", "inscription" },
        category = "Herb",
        researchStatus = "researched",
        sourceUrls = sourceUrls,
        summary = summary,
        spots = { spot },
    })
end

RegisterHerb(22785, "Felweed", {
    "https://www.wowhead.com/object=181270/felweed",
    "https://www.wow-professions.com/farming/felweed-farming",
    "https://warcraft.wiki.gg/wiki/Felweed",
    "https://artisansofazeroth.com/felweed-farming/",
}, "Common Outland herb. Hellfire Peninsula and Nagrand have dense node maps; gather every nearby herb to keep replacements moving.", {
    id = "felweed-hellfire-peninsula-loop",
    source = "Wowhead object map pins and Outland herb farming guides",
    sourceUrls = {
        "https://www.wowhead.com/object=181270/felweed",
        "https://www.wow-professions.com/farming/felweed-farming",
    },
    mapName = "Hellfire Peninsula",
    location = "Outer Hellfire herb loop through cliffs, ruins, and Hellfire Citadel approaches",
    routeType = "herbalism-loop",
    density = "High",
    dropDifficulty = "Easy. The zone is broad, so shorten the loop if respawns keep up.",
    tips = {
        "Gather every herb on the path, not just Felweed.",
        "The western and southern cliff lines are easy to combine with Fel Iron mining.",
    },
    coords = {
        C(0.109, 0.544, "Western Hellfire Felweed"),
        C(0.158, 0.608, "Southwest ridge Felweed"),
        C(0.202, 0.467, "Hellfire Citadel approach herb"),
        C(0.307, 0.485, "Central Hellfire herb"),
        C(0.398, 0.519, "Path of Glory herb"),
        C(0.488, 0.591, "Southern Hellfire herb"),
        C(0.584, 0.513, "Eastern Path of Glory Felweed"),
        C(0.667, 0.771, "Southeast Hellfire herb"),
        C(0.724, 0.636, "Zeth'gor side herb"),
    },
    confidence = "high",
})

local felweed = NS.MaterialFarmingSpots.items[22785]
if felweed then
    felweed.spots[#felweed.spots + 1] = {
        id = "felweed-nagrand-aoa-dreaming-glory-loop",
        source = "Artisans of Azeroth Routes import string, wow-professions Felweed guide, and Wowhead Felweed object page",
        sourceUrls = {
            "https://artisansofazeroth.com/felweed-farming/",
            "https://www.wow-professions.com/farming/felweed-farming",
            "https://www.wowhead.com/object=181270/felweed",
        },
        mapName = "Nagrand",
        location = "Nagrand Felweed and Dreaming Glory mixed herb loop",
        routeType = "herbalism-loop",
        density = "High for common Outland herbs",
        dropDifficulty = "Easy. Use this when Felweed value is good and you want a smoother common-herb route than Hellfire.",
        tips = {
            "The Artisans route string provides a compact Nagrand loop; wow-professions cross-checks Nagrand as a strong Felweed zone.",
            "Gather Dreaming Glory and Mana Thistle side checks while keeping Felweed as the baseline target.",
        },
        coords = {
            C(0.2768, 0.6189, "AoA Nagrand Felweed route start"),
            C(0.2861, 0.5936, "AoA west Nagrand Felweed pin"),
            C(0.3470, 0.6371, "AoA central-west Nagrand Felweed pin"),
            C(0.3745, 0.6491, "AoA south-central Nagrand Felweed pin"),
            C(0.4165, 0.6051, "AoA central Nagrand Felweed pin"),
            C(0.4885, 0.5521, "AoA east-central Nagrand Felweed pin"),
            C(0.5320, 0.6005, "AoA eastern Nagrand Felweed pin"),
            C(0.5568, 0.5902, "AoA far-east Nagrand Felweed pin"),
        },
        confidence = "medium",
    }
end

RegisterHerb(22786, "Dreaming Glory", {
    "https://www.wowhead.com/object=181271/dreaming-glory",
    "https://warcraft.wiki.gg/wiki/Dreaming_Glory",
    "https://www.wow-professions.com/farming/felweed-farming",
    "https://artisansofazeroth.com/felweed-farming/",
}, "Common Outland herb that favors cliffsides and raised terrain. Nagrand and Blade's Edge routes pair it with Felweed, Mana Thistle, and Nightmare Vine.", {
    id = "dreaming-glory-nagrand-cliff-loop",
    source = "Wowhead object map pins and Outland herb farming guides",
    sourceUrls = {
        "https://www.wowhead.com/object=181271/dreaming-glory",
        "https://warcraft.wiki.gg/wiki/Dreaming_Glory",
        "https://artisansofazeroth.com/felweed-farming/",
    },
    mapName = "Nagrand",
    location = "Nagrand cliffs, raised ground, Twilight Ridge, and western ridgelines",
    routeType = "herbalism-loop",
    density = "High",
    dropDifficulty = "Easy. Best treated as side value while sweeping high terrain.",
    tips = {
        "Follow cliffs and raised ground rather than flat-only loops.",
        "Add Twilight Ridge checks for Mana Thistle and Cobra Scales side routes.",
    },
    coords = {
        C(0.071, 0.436, "Northwest cliff Dreaming Glory"),
        C(0.147, 0.355, "Twilight Ridge Dreaming Glory"),
        C(0.242, 0.557, "Western ridge Dreaming Glory"),
        C(0.2768, 0.6189, "AoA Nagrand Felweed/Dreaming Glory route pin"),
        C(0.292, 0.541, "Western cave-path Dreaming Glory"),
        C(0.348, 0.584, "Central ridge Dreaming Glory"),
        C(0.3745, 0.6491, "AoA south-central Nagrand herb pin"),
        C(0.431, 0.622, "Central cave-ridge herb"),
        C(0.484, 0.744, "Southern ridge Dreaming Glory"),
        C(0.5035, 0.6023, "AoA central Nagrand herb pin"),
        C(0.5568, 0.5902, "AoA eastern Nagrand herb pin"),
        C(0.604, 0.390, "Eastern raised-ground herb"),
        C(0.762, 0.604, "Eastern mountain-edge herb"),
    },
    confidence = "high",
})

RegisterHerb(22787, "Ragveil", {
    "https://www.wowhead.com/object=181275/ragveil",
    "https://www.wow-professions.com/farming/ragveil-farming",
    "https://warcraft.wiki.gg/wiki/Ragveil",
    "https://artisansofazeroth.com/ragveil-farming-2/",
}, "Zangarmarsh-only herb. It shares the zone with Flame Cap as a rare related spawn, so high-volume Zangarmarsh laps are the practical farm.", {
    id = "ragveil-zangarmarsh-zone-loop",
    source = "Wowhead object map pins and Ragveil farming guides",
    sourceUrls = {
        "https://www.wowhead.com/object=181275/ragveil",
        "https://www.wow-professions.com/farming/ragveil-farming",
        "https://artisansofazeroth.com/ragveil-farming-2/",
    },
    mapName = "Zangarmarsh",
    location = "Full Zangarmarsh herb loop around lakes, marsh edges, and dry paths",
    routeType = "herbalism-loop",
    density = "High",
    dropDifficulty = "Easy but the zone lap is long.",
    tips = {
        "Pick every herb on the loop because Ragveil respawns are spread out.",
        "Watch for Flame Cap as a valuable rare spawn along the same route.",
    },
    coords = {
        C(0.084, 0.539, "Western marsh Ragveil"),
        C(0.174, 0.576, "Northwest marsh Ragveil"),
        C(0.3262, 0.2581, "AoA northwest Zangarmarsh Ragveil route pin"),
        C(0.3422, 0.4088, "AoA west Zangarmarsh Ragveil route pin"),
        C(0.314, 0.635, "Central-west Ragveil"),
        C(0.430, 0.686, "Marsh path Ragveil"),
        C(0.546, 0.689, "Central-east Ragveil"),
        C(0.6902, 0.6690, "AoA east-marsh Ragveil route pin"),
        C(0.592, 0.693, "Eastern marsh Ragveil"),
        C(0.701, 0.758, "Eastern marsh Ragveil"),
        C(0.8646, 0.3365, "AoA Dead Mire Ragveil route pin"),
        C(0.798, 0.843, "Far southeast Ragveil"),
        C(0.842, 0.420, "Dead Mire Ragveil side check"),
    },
    confidence = "high",
})

RegisterHerb(22788, "Flame Cap", {
    "https://www.wowhead.com/object=181276/flame-cap",
    "https://www.wowhead.com/item=22788/flame-cap",
    "https://www.wow-professions.com/farming/ragveil-farming",
    "https://artisansofazeroth.com/ragveil-farming-2/",
}, "Rare Zangarmarsh herb tied to Ragveil routes. Farm Ragveil volume and treat Flame Cap as the valuable bonus.", {
    id = "flame-cap-zangarmarsh-ragveil-route",
    source = "Wowhead object map pins and Outland herb farming guides",
    sourceUrls = {
        "https://www.wowhead.com/object=181276/flame-cap",
        "https://www.wow-professions.com/farming/ragveil-farming",
        "https://artisansofazeroth.com/ragveil-farming-2/",
    },
    mapName = "Zangarmarsh",
    location = "Flame Cap-capable Ragveil nodes across Zangarmarsh",
    routeType = "rare-herb-side-spawn",
    density = "Low",
    dropDifficulty = "Rare. Do not camp a single point; keep the Ragveil route moving.",
    tips = {
        "Use the same path as Ragveil farming.",
        "Compare Flame Cap value against steady Ragveil, Felweed, and fish pool value.",
    },
    coords = {
        C(0.084, 0.539, "Western Flame Cap-capable node"),
        C(0.153, 0.637, "Northwest Flame Cap-capable node"),
        C(0.314, 0.635, "Central Flame Cap-capable node"),
        C(0.592, 0.693, "Eastern Flame Cap-capable node"),
        C(0.743, 0.704, "Southeast Flame Cap-capable node"),
    },
    confidence = "high",
})

RegisterHerb(22789, "Terocone", {
    "https://www.wowhead.com/object=181277/terocone",
    "https://www.wow-professions.com/farming/terocone-farming",
    "https://warcraft.wiki.gg/wiki/Terocone",
    "https://artisansofazeroth.com/terocone-farming/",
}, "Terokkar Forest herb used heavily by Alchemy. Terokkar is the reliable farm; Shadowmoon has too few nodes to target as the main route.", {
    id = "terocone-terokkar-forest-loop",
    source = "Wowhead object map pins and Terocone farming guides",
    sourceUrls = {
        "https://www.wowhead.com/object=181277/terocone",
        "https://www.wow-professions.com/farming/terocone-farming",
        "https://artisansofazeroth.com/terocone-farming/",
    },
    mapName = "Terokkar Forest",
    location = "Outer Terokkar route through roads, forests, hillsides, and open terrain",
    routeType = "herbalism-loop",
    density = "High",
    dropDifficulty = "Good. Flying helps, but many nodes are reachable without it.",
    tips = {
        "Pick every other herb so Terocone nodes have time to respawn.",
        "Skip flying-only Shattrath and Skettis checks if you only want dense Terocone turnover.",
    },
    coords = {
        C(0.166, 0.669, "Western forest Terocone"),
        C(0.252, 0.555, "West-central Terocone"),
        C(0.371, 0.292, "Northern forest Terocone"),
        C(0.6012, 0.2340, "AoA northern Terokkar Terocone route pin"),
        C(0.6563, 0.3070, "AoA northeast Terokkar Terocone pin"),
        C(0.453, 0.614, "Central Terocone"),
        C(0.556, 0.635, "East-central Terocone"),
        C(0.6322, 0.4984, "AoA east-central Terokkar Terocone pin"),
        C(0.688, 0.505, "Eastern forest Terocone"),
        C(0.5797, 0.2645, "AoA north return Terocone pin"),
    },
    confidence = "high",
})

RegisterHerb(22790, "Ancient Lichen", {
    "https://www.wowhead.com/object=181278/ancient-lichen",
    "https://www.wowhead.com/npc=18124/withered-giant",
    "https://www.wow-professions.com/farming/mote-of-life-farming",
}, "Dungeon herb and plant-creature gather. The most useful outdoor anchors are Zangarmarsh bog giants, which Herbalists can gather after looting.", {
    id = "ancient-lichen-zangarmarsh-bog-giants",
    source = "Wowhead object/NPC map pins and Primal Life farming guides",
    sourceUrls = {
        "https://www.wowhead.com/object=181278/ancient-lichen",
        "https://www.wowhead.com/npc=18124/withered-giant",
    },
    mapName = "Zangarmarsh",
    location = "Gatherable bog giant corpses in Dead Mire and Spawning Glen",
    routeType = "herbalism-corpse-route",
    density = "Medium",
    dropDifficulty = "Situational. Best as side value during Primal Life farming.",
    tips = {
        "Loot bog giants first, then gather their corpses with Herbalism.",
        "Do not route only for Ancient Lichen unless the market price beats Primal Life and Ragveil value.",
    },
    coords = {
        C(0.102, 0.620, "Spawning Glen gatherable giant"),
        C(0.136, 0.602, "Western giant corpse route"),
        C(0.782, 0.402, "Dead Mire gatherable giant"),
        C(0.814, 0.432, "Central Dead Mire corpse route"),
        C(0.852, 0.400, "Eastern Dead Mire corpse route"),
    },
    confidence = "medium",
})

RegisterHerb(22791, "Netherbloom", {
    "https://www.wowhead.com/object=181279/netherbloom",
    "https://www.wow-professions.com/farming/netherbloom-farming",
    "https://warcraft.wiki.gg/wiki/Netherbloom",
    "https://artisansofazeroth.com/netherbloom-farming/",
}, "Netherstorm signature herb. It is gathered in open Netherstorm routes and can add Mote of Mana side value.", {
    id = "netherbloom-netherstorm-wide-loop",
    source = "Wowhead object map pins and Netherbloom farming guides",
    sourceUrls = {
        "https://www.wowhead.com/object=181279/netherbloom",
        "https://www.wow-professions.com/farming/netherbloom-farming",
        "https://artisansofazeroth.com/netherbloom-farming/",
    },
    mapName = "Netherstorm",
    location = "Roads, manaforges, ruins, and outer edges across Netherstorm",
    routeType = "herbalism-loop",
    density = "High",
    dropDifficulty = "Good with flying; avoid waiting on single spawns.",
    tips = {
        "Keep a wide route and gather every Netherbloom you see.",
        "Netherbloom can grant random stat buffs and occasional Mote of Mana side gathers.",
        "Combine this with Adamantite and cloud checks if you have Mining or Engineering.",
    },
    coords = {
        C(0.2844, 0.1409, "AoA northern Netherbloom route pin"),
        C(0.194, 0.677, "Northwest Netherbloom"),
        C(0.2863, 0.5317, "AoA western Netherbloom route pin"),
        C(0.277, 0.571, "Western Netherbloom"),
        C(0.342, 0.500, "Central-west Netherbloom"),
        C(0.3519, 0.5462, "AoA central-west Netherbloom pin"),
        C(0.462, 0.605, "Central Netherbloom"),
        C(0.568, 0.567, "Eastern Netherbloom"),
        C(0.5328, 0.1999, "AoA northeast Netherbloom route pin"),
        C(0.638, 0.645, "Far eastern Netherbloom"),
    },
    confidence = "high",
})

RegisterHerb(22792, "Nightmare Vine", {
    "https://www.wowhead.com/object=181280/nightmare-vine",
    "https://www.wow-professions.com/farming/nightmare-vine-farming",
    "https://warcraft.wiki.gg/wiki/Nightmare_Vine",
    "https://artisansofazeroth.com/nightmare-vine-farming-2/",
}, "High-value Outland herb strongly associated with Shadowmoon Valley, with smaller side clusters in Blade's Edge and Hellfire.", {
    id = "nightmare-vine-shadowmoon-valley-loop",
    source = "Wowhead object map pins and Nightmare Vine farming guides",
    sourceUrls = {
        "https://www.wowhead.com/object=181280/nightmare-vine",
        "https://www.wow-professions.com/farming/nightmare-vine-farming",
        "https://artisansofazeroth.com/nightmare-vine-farming-2/",
    },
    mapName = "Shadowmoon Valley",
    location = "Shadowmoon Valley open terrain, rocky edges, Legion Hold, and Netherwing approaches",
    routeType = "herbalism-loop",
    density = "Medium",
    dropDifficulty = "Moderate. It is less dense than common herbs, so gather other nodes along the lap.",
    tips = {
        "Check open ground and rock edges instead of only roads.",
        "Add Legion Hold and Netherwing-side checks when you also want cloth or air motes.",
    },
    coords = {
        C(0.194, 0.229, "Northwest Nightmare Vine"),
        C(0.2491, 0.2984, "AoA northwest Shadowmoon vine route pin"),
        C(0.260, 0.354, "Legion Hold-side vine"),
        C(0.3171, 0.3507, "AoA Legion Hold-side vine pin"),
        C(0.326, 0.444, "West-central Shadowmoon vine"),
        C(0.3851, 0.3015, "AoA north-central Shadowmoon vine pin"),
        C(0.429, 0.610, "Central Shadowmoon vine"),
        C(0.4666, 0.4026, "AoA central Shadowmoon vine pin"),
        C(0.516, 0.316, "Northern Shadowmoon vine"),
        C(0.551, 0.724, "Southern Shadowmoon vine"),
        C(0.612, 0.638, "Netherwing-side vine"),
        C(0.677, 0.534, "Eastern Shadowmoon vine"),
    },
    confidence = "high",
})

RegisterHerb(22793, "Mana Thistle", {
    "https://www.wowhead.com/object=181281/mana-thistle",
    "https://www.wowhead.com/item=22793/mana-thistle",
    "https://warcraft.wiki.gg/wiki/Mana_Thistle",
}, "Rare high-skill Outland herb from flying-access highland areas and Isle of Quel'Danas. Skettis and Twilight Ridge are practical checks.", {
    id = "mana-thistle-terokkar-skettis-highlands",
    source = "Wowhead object map pins and Mana Thistle farming guides",
    sourceUrls = {
        "https://www.wowhead.com/object=181281/mana-thistle",
        "https://www.wowhead.com/item=22793/mana-thistle",
    },
    mapName = "Terokkar Forest",
    location = "High-elevation Terokkar nodes above Shattrath and around Skettis",
    routeType = "rare-herb-highland-loop",
    density = "Low",
    dropDifficulty = "Rare and often camped. Requires high Herbalism and usually flying.",
    tips = {
        "Check Skettis highlands as part of a wider Terokkar herb lap.",
        "Keep moving through highland points rather than camping one node.",
    },
    coords = {
        C(0.202, 0.142, "Northwest highland Mana Thistle"),
        C(0.214, 0.104, "Upper Shattrath highland node"),
        C(0.472, 0.760, "Skettis approach highland node"),
        C(0.613, 0.760, "Skettis west Mana Thistle"),
        C(0.693, 0.746, "Skettis central Mana Thistle"),
        C(0.706, 0.824, "Skettis south return"),
        C(0.749, 0.874, "Skettis southeast Mana Thistle"),
    },
    confidence = "high",
})

Register({
    itemID = 22794,
    itemName = "Fel Lotus",
    expansion = "burningCrusade",
    professions = { "herbalism", "alchemy" },
    category = "Herb",
    researchStatus = "researched",
    sourceUrls = {
        "https://www.wowhead.com/item=22794/fel-lotus",
        "https://warcraft.wiki.gg/wiki/Fel_Lotus",
        "https://www.wowhead.com/object=181280/nightmare-vine",
        "https://www.wowhead.com/npc=18124/withered-giant",
    },
    summary = "Rare Outland herb side gather used for flasks. It is not a standalone node farm; the best approach is to clear high-volume Outland herb routes and gather eligible bog giant corpses.",
    spots = {
        {
            id = "fel-lotus-zangarmarsh-bog-giant-herbing",
            source = "Retail Wowhead item comments, Withered Giant pins, and Warcraft Wiki herb notes",
            sourceUrls = {
                "https://www.wowhead.com/item=22794/fel-lotus",
                "https://www.wowhead.com/npc=18124/withered-giant",
                "https://warcraft.wiki.gg/wiki/Fel_Lotus",
            },
            mapName = "Zangarmarsh",
            location = "Dead Mire and Spawning Glen bog giants, gathered after looting",
            routeType = "rare-herb-side-gather",
            density = "Low for Fel Lotus, medium for Life/Ancient Lichen side value",
            dropDifficulty = "Rare. Kill, loot, and herb-gather eligible bog giant corpses while treating Mote of Life as the steady reward.",
            tips = {
                "Use this route when Fel Lotus, Mote of Life, and Ancient Lichen values all matter.",
                "Keep moving between Dead Mire and Spawning Glen rather than waiting on one corpse cluster.",
            },
            coords = {
                C(0.102, 0.620, "Spawning Glen herbable giant"),
                C(0.136, 0.602, "Western giant corpse route"),
                C(0.782, 0.402, "Dead Mire herbable giant"),
                C(0.814, 0.432, "Central Dead Mire corpse route"),
                C(0.852, 0.400, "Eastern Dead Mire corpse route"),
            },
            confidence = "medium",
        },
        {
            id = "fel-lotus-shadowmoon-nightmare-vine-route",
            source = "Retail Wowhead item comments and Nightmare Vine object map pins",
            sourceUrls = {
                "https://www.wowhead.com/item=22794/fel-lotus",
                "https://www.wowhead.com/object=181280/nightmare-vine",
            },
            mapName = "Shadowmoon Valley",
            location = "Nightmare Vine and mixed-herb route through Shadowmoon Valley",
            routeType = "rare-herb-side-gather",
            density = "Low for Fel Lotus, medium for Nightmare Vine",
            dropDifficulty = "Rare. Pick every Outland herb on the lap; Fel Lotus is the bonus, not the route's baseline.",
            tips = {
                "Use this when Nightmare Vine is already profitable.",
                "Netherwing-side checks can also feed daily/rep movement if relevant.",
            },
            coords = {
                C(0.194, 0.229, "Northwest Nightmare Vine Fel Lotus check"),
                C(0.260, 0.354, "Legion Hold-side herb check"),
                C(0.429, 0.610, "Central Shadowmoon herb check"),
                C(0.551, 0.724, "Southern Shadowmoon herb check"),
                C(0.612, 0.638, "Netherwing-side herb check"),
                C(0.677, 0.534, "Eastern Shadowmoon herb check"),
            },
            confidence = "medium",
        },
    },
})
