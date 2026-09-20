local _, NS = ...
local Register = NS.RegisterMaterialFarmingSpot

local ORE_GUIDE = "https://www.wowhead.com/guide/classic-mining-best-farming-basics-early-ores"
local MINING_GUIDE = "https://www.wowhead.com/guide/mining-leveling-1-300-wow-classic"

local function C(x, y, label)
    return { x = x, y = y, label = label }
end

local function ItemUrl(itemID)
    return "https://www.wowhead.com/item=" .. tostring(itemID)
end

local IMPORTED_ROUTES_SOURCE = "Retail Routes addon import strings supplied by the user and decoded into static route pins"

local function ImportedRouteCoords(labelPrefix, pins)
    local coords = {}
    for index, pin in ipairs(pins) do
        coords[index] = C(pin[1], pin[2], labelPrefix .. " pin " .. tostring(index))
    end

    return coords
end

local COPPER_DUROTAR = {
    C(0.5449, 0.1109, "Skull Rock north ridge"),
    C(0.5435, 0.1407, "Skull Rock cave approach"),
    C(0.5859, 0.1732, "Northeast Durotar rocks"),
    C(0.5063, 0.1741, "Drygulch north rocks"),
    C(0.4983, 0.2114, "Drygulch ridge"),
    C(0.5204, 0.2461, "Razor Hill north ridge"),
    C(0.5627, 0.2553, "Tiragarde north rocks"),
    C(0.5602, 0.3107, "Tiragarde approach"),
    C(0.5067, 0.2701, "Razor Hill west spur"),
    C(0.4512, 0.2488, "Razor Hill northwest rocks"),
    C(0.4910, 0.3322, "Razor Hill west pass"),
    C(0.4753, 0.3644, "Razor Hill southwest ridge"),
    C(0.5297, 0.3459, "Razor Hill south rocks"),
    C(0.5578, 0.4990, "Sen'jin approach ridge"),
    C(0.4755, 0.4855, "Drygulch south rocks"),
    C(0.3678, 0.5647, "Southfury western ridge"),
    C(0.3701, 0.4605, "Drygulch Ravine south"),
    C(0.4305, 0.3881, "Razor Hill southwest pass"),
    C(0.3589, 0.3476, "Western Durotar rocks"),
    C(0.3877, 0.1532, "Northwest Durotar ridge"),
}

local TIN_HILLSBRAD = {
    C(0.7357, 0.5904, "Alterac foothill east"),
    C(0.7507, 0.6028, "Darrow Hill northeast ridge"),
    C(0.7178, 0.6437, "Darrow Hill north"),
    C(0.6979, 0.6712, "Darrow Hill west ridge"),
    C(0.6506, 0.6889, "Darrow Hill outer rocks"),
    C(0.6705, 0.7158, "Eastern mountain pocket"),
    C(0.6663, 0.7555, "Southeast mountain pass"),
    C(0.6395, 0.7644, "South mountain wall"),
    C(0.6165, 0.7276, "Ruins ridge south"),
    C(0.6010, 0.7686, "Southwest mountain rocks"),
    C(0.5872, 0.7646, "Southwest foothill"),
    C(0.5596, 0.7336, "Western ridge"),
    C(0.5662, 0.6961, "Western mountain pocket"),
    C(0.6165, 0.6644, "Central ridge return"),
    C(0.5913, 0.6352, "Foothill connector"),
    C(0.6325, 0.6084, "North return rocks"),
    C(0.6223, 0.4617, "Alterac mountain spur"),
    C(0.6628, 0.5356, "East ridge connector"),
    C(0.6833, 0.5479, "Northeast foothill"),
    C(0.7148, 0.5611, "Route return ridge"),
}

local IRON_ARATHI = {
    C(0.276, 0.375, "Northfold Manor ridge"),
    C(0.386, 0.305, "Circle of West Binding ridge"),
    C(0.484, 0.456, "Central Arathi highlands"),
    C(0.600, 0.560, "Dabyrie's Farmstead hills"),
    C(0.730, 0.388, "Hammerfall eastern ridge"),
    C(0.308, 0.745, "Stromgarde outer rocks"),
}

local MITHRIL_BADLANDS = {
    C(0.1136, 0.3685, "Badlands west ridge"),
    C(0.1652, 0.3623, "Angor Fortress west"),
    C(0.2044, 0.3649, "Angor road rocks"),
    C(0.2440, 0.3848, "Dustbowl northwest"),
    C(0.2733, 0.3718, "Dustbowl ridge"),
    C(0.3061, 0.3753, "Central ridge"),
    C(0.3730, 0.3242, "Camp Cagg north rocks"),
    C(0.4495, 0.2585, "Lethlor west rise"),
    C(0.4767, 0.1342, "Lethlor north wall"),
    C(0.5246, 0.1689, "Lethlor upper ridge"),
    C(0.5604, 0.2112, "Lethlor Ravine rim"),
    C(0.5927, 0.3117, "Eastern Lethlor rocks"),
    C(0.5746, 0.3898, "Ravine southeast"),
    C(0.5629, 0.4573, "Agmond connector"),
    C(0.5730, 0.5392, "Agmond's End ridge"),
    C(0.5813, 0.5966, "Southern Agmond rocks"),
    C(0.5309, 0.6244, "South Badlands wall"),
    C(0.4749, 0.6416, "Camp Cagg south ridge"),
    C(0.4158, 0.6584, "Western south ridge"),
    C(0.2405, 0.6430, "Dustbelch approach"),
    C(0.1209, 0.6352, "Far west return"),
}

local THORIUM_WINTERSPRING = {
    C(0.3121, 0.6533, "Owl Wing Thicket ridge"),
    C(0.2405, 0.5613, "Frostfire Hot Springs west"),
    C(0.2861, 0.4804, "Winterfall Village west"),
    C(0.2727, 0.4170, "Lake Kel'Theril west"),
    C(0.2832, 0.3795, "Lake Kel'Theril north"),
    C(0.2597, 0.2921, "Frostsaber approach"),
    C(0.2879, 0.1102, "Frostsaber Rock north"),
    C(0.3493, 0.1262, "Frostsaber east ridge"),
    C(0.3566, 0.2363, "Northern ridge return"),
    C(0.4040, 0.1476, "North central rocks"),
    C(0.4758, 0.1970, "Starfall Village north"),
    C(0.5914, 0.1139, "Northeast Winterspring"),
    C(0.6932, 0.1642, "Mazthoril north"),
    C(0.6821, 0.2652, "Mazthoril west wall"),
    C(0.7225, 0.4003, "East wall ridge"),
    C(0.6920, 0.4520, "Everlook east wall"),
    C(0.6462, 0.4534, "Everlook southeast rocks"),
    C(0.5780, 0.4323, "Everlook south connector"),
    C(0.5613, 0.4083, "Central return ridge"),
    C(0.5550, 0.4685, "Central gorge rim"),
    C(0.6324, 0.4841, "South-east ridge"),
    C(0.6748, 0.5694, "Ice Thistle ridge"),
    C(0.6701, 0.6311, "Darkwhisper north"),
    C(0.6940, 0.6899, "Darkwhisper east"),
    C(0.6430, 0.8341, "Darkwhisper south wall"),
    C(0.5471, 0.8162, "Southern return ridge"),
    C(0.4908, 0.7964, "Owl Wing south wall"),
    C(0.4074, 0.8065, "Southwest ridge"),
    C(0.2533, 0.7995, "Western south wall"),
    C(0.3034, 0.6952, "Owl Wing return"),
}

local DARK_IRON_SEARING_GORGE = {
    C(0.346, 0.266, "Thorium Point south ridge"),
    C(0.426, 0.382, "Cauldron northwest rim"),
    C(0.512, 0.446, "Cauldron inner ramp"),
    C(0.604, 0.380, "Grimesilt Dig Site approach"),
    C(0.666, 0.548, "Dustfire Valley approach"),
    C(0.358, 0.744, "Blackrock Mountain approach"),
}

local ROUTES = {
    copper = {
        urls = {
            ORE_GUIDE,
            MINING_GUIDE,
            "https://www.wow-professions.com/farming/copper-ore-farming",
            "https://artisansofazeroth.com/copper-ore-farming/",
            "https://www.wowhead.com/object=1731/copper-vein",
        },
        mapName = "Durotar",
        location = "Durotar outer ridge and cave loop, with Skull Rock, Razor Hill, Drygulch, and southern ridge checks",
        routeType = "mining-loop",
        density = "High",
        difficulty = "Easy starter route. Copper nodes also supply Rough Stone and low-tier gems.",
        tips = {
            "Keep to ridges, cave mouths, and rocky edges rather than crossing empty open ground.",
            "Skip Echo Isles if you only want ore speed; add it if competition is heavy.",
            "Mine every Copper node completely to keep low-tier gem turnover moving.",
        },
        coords = COPPER_DUROTAR,
    },
    tin = {
        urls = {
            ORE_GUIDE,
            MINING_GUIDE,
            "https://www.wow-professions.com/farming/tin-ore-farming",
            "https://artisansofazeroth.com/tin-ore-farming/",
            "https://www.wowhead.com/object=1732/tin-vein",
        },
        mapName = "Hillsbrad Foothills",
        location = "Hillsbrad and Alterac foothill mountain loop for Tin and rare Silver replacement nodes",
        routeType = "mining-loop",
        density = "High",
        difficulty = "Good low-mid route. Tin nodes can produce Coarse Stone, Moss Agate, Shadowgem, and rare Silver.",
        tips = {
            "Use the southern route first; it has stronger Tin density around Bael Modan.",
            "Clear Copper too when moving between Tin pockets so replacement nodes keep cycling.",
            "Treat Silver as a bonus from Tin turnover rather than a campable route target.",
        },
        coords = TIN_HILLSBRAD,
    },
    iron = {
        urls = {
            ORE_GUIDE,
            MINING_GUIDE,
            "https://www.wow-professions.com/farming/iron-ore-farming",
            "https://www.wowhead.com/object=1735/iron-deposit",
        },
        mapName = "Arathi Highlands",
        location = "Outer ridge and Stromgarde-adjacent Arathi loop for Iron and rare Gold replacement nodes",
        routeType = "mining-loop",
        density = "High",
        difficulty = "Good mid-level route, though faction travel and quest traffic can slow early characters.",
        tips = {
            "Follow mountain walls and Stromgarde-adjacent rocks instead of crossing the central roads.",
            "Gold comes from Iron-family replacement behavior, so keep the full Iron route moving.",
            "Arathi pairs well with Kingsblood, Goldthorn, Heavy Leather, and elemental side farms.",
        },
        coords = IRON_ARATHI,
    },
    mithril = {
        urls = {
            ORE_GUIDE,
            MINING_GUIDE,
            "https://www.wow-professions.com/farming/mithril-ore-farming",
            "https://artisansofazeroth.com/mithril-ore-farming/",
            "https://www.wowhead.com/object=2040/mithril-deposit",
        },
        mapName = "Badlands",
        location = "Badlands Camp Cagg, Dustbowl, Agmond's End, and Lethlor Ravine Mithril loop",
        routeType = "mining-loop",
        density = "High",
        difficulty = "Strong compact route. Mithril supplies Solid Stone, mid-high gems, and rare Truesilver replacements.",
        tips = {
            "Use Badlands when you want compact Mithril rather than a long Tanaris wall loop.",
            "Check cave approaches and ravine rims; many nodes sit on terrain edges.",
            "Clear Mithril to spawn Truesilver replacement opportunities.",
        },
        coords = MITHRIL_BADLANDS,
    },
    thorium = {
        urls = {
            ORE_GUIDE,
            MINING_GUIDE,
            "https://www.wow-professions.com/farming/thorium-ore-farming",
            "https://artisansofazeroth.com/thorium-ore-farming/",
            "https://www.wowhead.com/object=324/small-thorium-vein",
            "https://www.wowhead.com/object=175404/rich-thorium-vein",
        },
        mapName = "Winterspring",
        location = "Winterspring outer mountain-wall Thorium route with Frostsaber, Mazthoril, Everlook, and Darkwhisper checks",
        routeType = "mining-loop",
        density = "High",
        difficulty = "Simple endgame loop. Rich Thorium is the key source for Arcane Crystal and high-end gems.",
        tips = {
            "Follow the outer mountain wall and ridge pockets rather than crossing the open snowfields.",
            "Use Un'Goro or Silithus as backups if the Winterspring loop is heavily contested.",
            "Prioritize Rich Thorium for Arcane Crystal and high-end gem value.",
        },
        coords = THORIUM_WINTERSPRING,
    },
    darkIron = {
        urls = {
            "https://www.wow-professions.com/farming/dark-iron-ore-farming",
            "https://www.wow-professions.com/guides/dark-iron-ore-smelting",
            "https://warcraft.wiki.gg/wiki/Dark_Iron_Deposit",
            "https://www.wowhead.com/item=11370/dark-iron-ore",
        },
        mapName = "Searing Gorge",
        location = "Searing Gorge Dark Iron pockets around the Cauldron, Grimesilt, Dustfire, and Blackrock approaches",
        routeType = "mining-loop",
        density = "Medium",
        difficulty = "Outdoor nodes are scattered; Molten Core and Blackrock Depths are stronger but reset/clear constrained.",
        tips = {
            "Use outdoor Searing Gorge when you want an open-world route with no instance reset pressure.",
            "Use Molten Core or Blackrock Depths when your character can clear safely and you want controlled nodes.",
            "Dark Iron Bars need extra smelting setup, so compare ore versus bar prices.",
        },
        coords = DARK_IRON_SEARING_GORGE,
    },
}

local function AddImportedMiningRoute(routeKey, route)
    route.urls = route.urls or { ORE_GUIDE, MINING_GUIDE }
    route.source = route.source or IMPORTED_ROUTES_SOURCE
    route.confidence = route.confidence or "high"
    ROUTES[routeKey] = route
end

AddImportedMiningRoute("copperDurotarRoutesMain", {
    mapName = "Durotar",
    location = "Durotar Copper Ore - Horde imported loop",
    routeType = "imported-mining-loop",
    density = "High",
    difficulty = "Straightforward low-terrain Copper loop; best when hugging ridges, hills, cliffs, and zone edges.",
    tips = {
        "Complete the full circuit before changing zones because Copper respawns are distributed across the route.",
        "Favor outer mountain walls over shortcuts through the middle of the zone.",
        "Mine every Copper node to keep Rough Stone and starter gem turnover moving.",
    },
    coords = ImportedRouteCoords("Routes Durotar Copper", {
        { 0.4391, 0.1401 },
        { 0.4885, 0.1430 },
        { 0.5171, 0.1313 },
        { 0.5455, 0.1815 },
        { 0.5695, 0.2572 },
        { 0.5678, 0.3075 },
        { 0.5381, 0.3267 },
        { 0.5392, 0.4107 },
        { 0.5819, 0.4285 },
        { 0.5921, 0.5304 },
        { 0.5536, 0.5946 },
        { 0.5765, 0.7020 },
        { 0.4994, 0.7439 },
        { 0.5191, 0.6718 },
        { 0.5136, 0.5753 },
        { 0.4960, 0.4974 },
        { 0.4305, 0.4868 },
        { 0.3767, 0.5183 },
        { 0.3885, 0.3152 },
        { 0.3847, 0.2295 },
    }),
})

AddImportedMiningRoute("copperDurotarWitAlt", {
    mapName = "Durotar",
    location = "Durotar alternate WIT Copper loop",
    routeType = "imported-mining-loop",
    density = "Medium-High",
    difficulty = "Alternative Durotar Copper geometry for crowded main-route conditions.",
    tips = {
        "Use this when the main Durotar route is being heavily farmed.",
        "Compare routes over two or three complete laps instead of judging after a short pass.",
        "Stay close to rocky edges and outer terrain walls.",
    },
    coords = ImportedRouteCoords("WIT Durotar Copper", {
        { 0.5401, 0.1143 },
        { 0.5665, 0.2113 },
        { 0.5573, 0.4073 },
        { 0.5831, 0.4330 },
        { 0.5973, 0.5454 },
        { 0.5616, 0.5706 },
        { 0.5541, 0.6344 },
        { 0.5745, 0.7002 },
        { 0.5311, 0.8037 },
        { 0.4903, 0.7407 },
        { 0.5056, 0.6135 },
        { 0.4918, 0.4902 },
        { 0.3854, 0.5379 },
        { 0.4520, 0.3637 },
        { 0.4425, 0.2272 },
        { 0.3786, 0.2295 },
        { 0.3959, 0.1429 },
    }),
})

AddImportedMiningRoute("tinHillsbradRoutesMain", {
    mapName = "Hillsbrad Foothills",
    location = "Hillsbrad Foothills Tin and Silver turnover loop",
    routeType = "imported-mining-loop",
    density = "High",
    difficulty = "Compact Tin route that also supports rare Silver replacement chances.",
    tips = {
        "Follow mountain faces closely instead of flying through flat open fields.",
        "Mine every Tin node because Silver shares the same general spawn ecosystem.",
        "Clear other eligible nodes along the route to keep the spawn pool cycling.",
    },
    coords = ImportedRouteCoords("Routes Hillsbrad Tin", {
        { 0.4687, 0.1045 },
        { 0.5116, 0.1292 },
        { 0.5278, 0.1738 },
        { 0.5602, 0.1943 },
        { 0.5794, 0.2548 },
        { 0.5706, 0.3263 },
        { 0.5821, 0.4198 },
        { 0.5485, 0.4260 },
        { 0.5320, 0.3911 },
        { 0.5182, 0.4123 },
        { 0.5263, 0.5393 },
        { 0.4948, 0.5339 },
        { 0.4669, 0.4742 },
        { 0.4723, 0.5487 },
        { 0.4399, 0.5644 },
        { 0.3622, 0.5052 },
        { 0.3926, 0.4028 },
        { 0.3701, 0.3516 },
        { 0.3638, 0.2894 },
    }),
})

AddImportedMiningRoute("tinAshenvaleWitAlt", {
    mapName = "Ashenvale",
    location = "Ashenvale WIT Tin and Silver alternate loop",
    routeType = "imported-mining-loop",
    density = "Medium",
    difficulty = "Longer, less compact Tin route with irregular terrain and tree cover.",
    tips = {
        "Use Ashenvale when Hillsbrad is crowded or you want a longer farming session.",
        "Keep close to cliff bases and rocky transitions.",
        "Do not fly too high because tree cover can hide minimap node context.",
    },
    coords = ImportedRouteCoords("WIT Ashenvale Tin", {
        { 0.9355, 0.3717 },
        { 0.8985, 0.6053 },
        { 0.8583, 0.6973 },
        { 0.7969, 0.7497 },
        { 0.6249, 0.7955 },
        { 0.5546, 0.7373 },
        { 0.4417, 0.6685 },
        { 0.2053, 0.5308 },
        { 0.1812, 0.4810 },
        { 0.1743, 0.3955 },
        { 0.2343, 0.2484 },
        { 0.2591, 0.1941 },
        { 0.2838, 0.1398 },
        { 0.3205, 0.2083 },
        { 0.3571, 0.2767 },
        { 0.4770, 0.4978 },
        { 0.5849, 0.5321 },
        { 0.7087, 0.4763 },
        { 0.7691, 0.3849 },
    }),
})

AddImportedMiningRoute("tinNorthernStranglethornAlt", {
    mapName = "Northern Stranglethorn",
    location = "Northern Stranglethorn alternate Tin and Silver wall loop",
    routeType = "imported-mining-loop",
    density = "Medium",
    difficulty = "Alternative Tin and Silver route with different competition from Hillsbrad or Ashenvale.",
    tips = {
        "Keep close to mountain walls.",
        "Avoid unnecessary passes through the lower-density center.",
        "Use this if you are already farming other Vanilla materials in Stranglethorn.",
    },
    coords = ImportedRouteCoords("Routes Northern Stranglethorn Tin", {
        { 0.3436, 0.2125 },
        { 0.3701, 0.2298 },
        { 0.3796, 0.2833 },
        { 0.4057, 0.2964 },
        { 0.4092, 0.3217 },
        { 0.4251, 0.3335 },
        { 0.4254, 0.3836 },
        { 0.4055, 0.4316 },
        { 0.4030, 0.4538 },
        { 0.3783, 0.4846 },
        { 0.3675, 0.4444 },
        { 0.3495, 0.4190 },
        { 0.3643, 0.3908 },
        { 0.3593, 0.3372 },
        { 0.3196, 0.3731 },
        { 0.3171, 0.3125 },
        { 0.2853, 0.3210 },
        { 0.2430, 0.3139 },
        { 0.2316, 0.2905 },
        { 0.2053, 0.2849 },
        { 0.1911, 0.2415 },
        { 0.2155, 0.1919 },
        { 0.2228, 0.2086 },
        { 0.2264, 0.2249 },
        { 0.2398, 0.2426 },
        { 0.2590, 0.2023 },
        { 0.2840, 0.2058 },
        { 0.2753, 0.2531 },
    }),
})

AddImportedMiningRoute("ironFeralasRoutesMain", {
    mapName = "Feralas",
    location = "Feralas broad Iron and Gold outer mountain loop",
    routeType = "imported-mining-loop",
    density = "High",
    difficulty = "Broad Iron farming route with Gold bonus potential; flying makes a significant difference.",
    tips = {
        "Follow mountain ranges and high terrain rather than crossing open central areas.",
        "Mine Mithril and Gold-compatible nodes you encounter instead of selectively skipping them.",
        "Use this when you want a mixture of mid-tier Vanilla mining materials.",
    },
    coords = ImportedRouteCoords("Routes Feralas Iron", {
        { 0.4376, 0.0890 },
        { 0.5149, 0.1077 },
        { 0.5292, 0.1803 },
        { 0.5138, 0.2462 },
        { 0.4948, 0.3453 },
        { 0.4950, 0.4400 },
        { 0.5425, 0.4848 },
        { 0.5930, 0.4919 },
        { 0.6567, 0.4705 },
        { 0.7203, 0.3515 },
        { 0.7396, 0.4022 },
        { 0.7293, 0.4794 },
        { 0.7827, 0.5386 },
        { 0.7553, 0.5866 },
        { 0.7250, 0.5848 },
        { 0.7147, 0.6320 },
        { 0.6704, 0.5794 },
        { 0.6749, 0.4947 },
        { 0.6276, 0.5403 },
        { 0.6052, 0.6566 },
        { 0.6036, 0.7494 },
        { 0.5544, 0.7557 },
        { 0.5470, 0.6470 },
        { 0.5648, 0.5648 },
        { 0.5508, 0.5276 },
        { 0.4924, 0.4904 },
        { 0.4629, 0.4355 },
        { 0.4755, 0.3705 },
        { 0.4658, 0.2952 },
        { 0.4347, 0.2470 },
        { 0.3984, 0.2642 },
        { 0.3842, 0.2345 },
        { 0.3678, 0.1547 },
        { 0.3909, 0.0942 },
    }),
})

AddImportedMiningRoute("ironWesternPlaguelandsWitAlt", {
    mapName = "Western Plaguelands",
    location = "Western Plaguelands compact WIT Iron and Gold loop",
    routeType = "imported-mining-loop",
    density = "Medium-High",
    difficulty = "Shorter, more compact Iron route for repeated spawn cycling.",
    tips = {
        "Use this when you prefer short loops over wide Feralas laps.",
        "Check terrain edges and hills rather than staying exactly on roads.",
        "Treat Gold as a bonus while clearing the Iron-family route.",
    },
    coords = ImportedRouteCoords("WIT Western Plaguelands Iron", {
        { 0.5533, 0.4767 },
        { 0.5982, 0.5207 },
        { 0.6735, 0.4261 },
        { 0.6900, 0.4854 },
        { 0.6448, 0.5946 },
        { 0.5573, 0.6562 },
        { 0.5108, 0.8207 },
        { 0.4246, 0.8269 },
        { 0.3558, 0.7981 },
        { 0.3021, 0.6958 },
        { 0.3116, 0.5854 },
        { 0.3549, 0.5444 },
        { 0.4034, 0.5052 },
        { 0.4569, 0.4934 },
        { 0.4496, 0.4301 },
        { 0.5071, 0.4247 },
    }),
})

AddImportedMiningRoute("mithrilBurningSteppesCompact", {
    mapName = "Burning Steppes",
    location = "Burning Steppes compact Mithril and Truesilver mountain loop",
    routeType = "imported-mining-loop",
    density = "High",
    difficulty = "Compact Mithril farm with Truesilver potential and little wasted open space.",
    tips = {
        "Hug the mountains around the zone.",
        "Check caves and rocky formations when they sit close to the route.",
        "Mine Truesilver and Thorium-compatible nodes you see rather than skipping them.",
    },
    coords = ImportedRouteCoords("Routes Burning Steppes Mithril compact", {
        { 0.3896, 0.3440 },
        { 0.4575, 0.3323 },
        { 0.5210, 0.3050 },
        { 0.6671, 0.2704 },
        { 0.8059, 0.3223 },
        { 0.7924, 0.5780 },
        { 0.7423, 0.5686 },
        { 0.6952, 0.6057 },
        { 0.5095, 0.6089 },
        { 0.4254, 0.6488 },
        { 0.3989, 0.5801 },
        { 0.3222, 0.5689 },
        { 0.2141, 0.6032 },
        { 0.1027, 0.5853 },
        { 0.1043, 0.4797 },
        { 0.2625, 0.4828 },
        { 0.3372, 0.4467 },
        { 0.3693, 0.4065 },
    }),
})

AddImportedMiningRoute("mithrilBurningSteppesCoverage", {
    mapName = "Burning Steppes",
    location = "Burning Steppes extended Mithril coverage sweep",
    routeType = "imported-mining-loop",
    density = "High",
    difficulty = "More exhaustive Mithril sweep with extra turns for broader node coverage.",
    tips = {
        "Use this when nodes are sparse and you want maximum coverage.",
        "Expect more direction changes than the compact Burning Steppes route.",
        "Clear each viable node to improve Mithril and Truesilver turnover.",
    },
    coords = ImportedRouteCoords("Routes Burning Steppes Mithril coverage", {
        { 0.5726, 0.2841 },
        { 0.6486, 0.2715 },
        { 0.7161, 0.2508 },
        { 0.7728, 0.2921 },
        { 0.7975, 0.2866 },
        { 0.8164, 0.3041 },
        { 0.8000, 0.4060 },
        { 0.8003, 0.5200 },
        { 0.8139, 0.6213 },
        { 0.7682, 0.5818 },
        { 0.7291, 0.6222 },
        { 0.7178, 0.6739 },
        { 0.6860, 0.6308 },
        { 0.6717, 0.6598 },
        { 0.6535, 0.6229 },
        { 0.6209, 0.6150 },
        { 0.5558, 0.5991 },
        { 0.5394, 0.5346 },
        { 0.5865, 0.5454 },
        { 0.5061, 0.4520 },
        { 0.5900, 0.4554 },
        { 0.5784, 0.4070 },
        { 0.6442, 0.4043 },
        { 0.6877, 0.4143 },
        { 0.7112, 0.3499 },
        { 0.7392, 0.4415 },
        { 0.7146, 0.4988 },
        { 0.6633, 0.4873 },
        { 0.6451, 0.4043 },
        { 0.5946, 0.3828 },
    }),
})

AddImportedMiningRoute("thoriumWinterspringRoutesMain", {
    mapName = "Winterspring",
    location = "Winterspring Thorium and Truesilver mountain loop",
    routeType = "imported-mining-loop",
    density = "High",
    difficulty = "Reliable Thorium route that benefits from flying speed due to Winterspring size.",
    tips = {
        "Hug mountain chains and cliff bases.",
        "Prioritize Rich Thorium Deposit areas while also clearing Small Thorium nodes.",
        "Use this as the primary Thorium and Truesilver loop when Burning Steppes is not the goal.",
    },
    coords = ImportedRouteCoords("Routes Winterspring Thorium", {
        { 0.5093, 0.2243 },
        { 0.5795, 0.2096 },
        { 0.6777, 0.3034 },
        { 0.5996, 0.3333 },
        { 0.5775, 0.3711 },
        { 0.5888, 0.4267 },
        { 0.6300, 0.4338 },
        { 0.6712, 0.4252 },
        { 0.6849, 0.5101 },
        { 0.6413, 0.4563 },
        { 0.6147, 0.4666 },
        { 0.6242, 0.5139 },
        { 0.6669, 0.5523 },
        { 0.6682, 0.6291 },
        { 0.6613, 0.6845 },
        { 0.6352, 0.7112 },
        { 0.6186, 0.7445 },
        { 0.6123, 0.7933 },
        { 0.5882, 0.8067 },
        { 0.5607, 0.7792 },
        { 0.5531, 0.7204 },
        { 0.5595, 0.6419 },
        { 0.5890, 0.6064 },
        { 0.5683, 0.5699 },
        { 0.5350, 0.5955 },
        { 0.4691, 0.6076 },
        { 0.4234, 0.5313 },
        { 0.3614, 0.5797 },
        { 0.2860, 0.5614 },
        { 0.2498, 0.5738 },
        { 0.2270, 0.5041 },
        { 0.3386, 0.4824 },
        { 0.4532, 0.4961 },
        { 0.5094, 0.4057 },
        { 0.4969, 0.3260 },
        { 0.4710, 0.2596 },
    }),
})

AddImportedMiningRoute("thoriumSilithusWitAlt", {
    mapName = "Silithus",
    location = "Silithus WIT Thorium outer-zone loop",
    routeType = "imported-mining-loop",
    density = "High",
    difficulty = "Excellent Thorium alternative for dense outer-zone mining when Winterspring has competition.",
    tips = {
        "Circle the outside of the zone and major rocky formations.",
        "Check hive and mountain areas when they do not require a large detour.",
        "Mine both Small and Rich Thorium nodes to keep the route productive.",
    },
    coords = ImportedRouteCoords("WIT Silithus Thorium", {
        { 0.3038, 0.1430 },
        { 0.3925, 0.1467 },
        { 0.4811, 0.1503 },
        { 0.5697, 0.1539 },
        { 0.6583, 0.1576 },
        { 0.6815, 0.2738 },
        { 0.7468, 0.3563 },
        { 0.6880, 0.4280 },
        { 0.6824, 0.4836 },
        { 0.6768, 0.5392 },
        { 0.6774, 0.7231 },
        { 0.5648, 0.8121 },
        { 0.2734, 0.7932 },
        { 0.3358, 0.6535 },
        { 0.2528, 0.5697 },
        { 0.2886, 0.4681 },
        { 0.2954, 0.3572 },
        { 0.2612, 0.2680 },
        { 0.2686, 0.1867 },
    }),
})

AddImportedMiningRoute("thoriumWinterspringCoverage", {
    mapName = "Winterspring",
    location = "Winterspring maximum-coverage Thorium loop",
    routeType = "imported-mining-loop",
    density = "High",
    difficulty = "Denser Winterspring coverage route with more direction changes than the main loop.",
    tips = {
        "Use this when you care more about node coverage than smooth flying.",
        "Expect more turns than the shorter Winterspring circuit.",
        "Follow mountain walls and high-value Rich Thorium pockets.",
    },
    coords = ImportedRouteCoords("Routes Winterspring Thorium coverage", {
        { 0.2310, 0.4701 },
        { 0.2740, 0.4853 },
        { 0.3423, 0.4800 },
        { 0.4031, 0.4588 },
        { 0.4297, 0.4725 },
        { 0.0416, 0.3505 },
        { 0.4601, 0.5328 },
        { 0.5078, 0.4866 },
        { 0.4869, 0.4406 },
        { 0.5403, 0.4448 },
        { 0.5899, 0.4426 },
        { 0.6061, 0.3828 },
        { 0.5639, 0.3851 },
        { 0.5274, 0.4159 },
        { 0.5281, 0.3250 },
        { 0.4712, 0.3366 },
        { 0.4752, 0.2837 },
        { 0.4572, 0.2359 },
        { 0.4868, 0.1581 },
        { 0.5146, 0.2060 },
        { 0.5264, 0.1869 },
        { 0.5552, 0.2018 },
        { 0.5861, 0.1650 },
        { 0.5969, 0.2267 },
        { 0.5899, 0.2661 },
        { 0.6092, 0.3273 },
        { 0.6571, 0.3063 },
        { 0.6669, 0.3698 },
        { 0.6787, 0.4157 },
        { 0.6904, 0.4616 },
        { 0.6345, 0.4939 },
        { 0.6748, 0.5219 },
        { 0.6777, 0.6796 },
        { 0.6563, 0.7210 },
        { 0.6351, 0.7774 },
        { 0.6617, 0.8270 },
        { 0.6438, 0.8414 },
        { 0.6240, 0.8100 },
        { 0.6035, 0.8531 },
        { 0.5772, 0.8304 },
        { 0.5567, 0.7818 },
        { 0.5367, 0.6819 },
        { 0.5295, 0.6477 },
        { 0.5079, 0.5962 },
        { 0.5103, 0.5833 },
        { 0.4691, 0.5969 },
        { 0.4258, 0.5436 },
        { 0.3782, 0.5732 },
        { 0.3209, 0.5713 },
        { 0.2657, 0.5876 },
        { 0.2479, 0.6277 },
        { 0.2218, 0.6262 },
        { 0.2302, 0.5783 },
        { 0.2421, 0.5414 },
    }),
})

local function RegisterMiningItem(itemID, itemName, professions, category, summary, routeKeys)
    local spots = {}
    local sourceUrls = { ItemUrl(itemID), ORE_GUIDE, MINING_GUIDE }
    for _, routeKey in ipairs(routeKeys) do
        local route = ROUTES[routeKey]
        for _, url in ipairs(route.urls) do
            sourceUrls[#sourceUrls + 1] = url
        end
        spots[#spots + 1] = {
            id = "classic-mining-" .. routeKey .. "-" .. tostring(itemID),
            source = route.source
                or "Wowhead retail object pages, Wowhead mining guides, wow-professions route guides, Artisans of Azeroth route pins, and Classic database notes",
            sourceUrls = route.urls,
            mapName = route.mapName,
            location = route.location,
            routeType = route.routeType,
            density = route.density,
            dropDifficulty = route.difficulty,
            tips = route.tips,
            coords = route.coords,
            confidence = route.confidence or "high",
        }
    end

    Register({
        itemID = itemID,
        itemName = itemName,
        expansion = "classic",
        professions = professions,
        category = category,
        researchStatus = "researched",
        sourceUrls = sourceUrls,
        summary = summary,
        spots = spots,
    })
end

RegisterMiningItem(2770, "Copper Ore", { "mining" }, "Ore", "Starter ore from low-level rocky zones. Durotar is a dense coordinate-backed route.", { "copper", "copperDurotarRoutesMain", "copperDurotarWitAlt" })
RegisterMiningItem(2771, "Tin Ore", { "mining" }, "Ore", "Low-mid ore from 10-30 zones. Hillsbrad and Alterac foothills have practical Tin density and rare Silver replacement chances.", { "tin", "tinHillsbradRoutesMain", "tinAshenvaleWitAlt", "tinNorthernStranglethornAlt" })
RegisterMiningItem(2772, "Iron Ore", { "mining" }, "Ore", "Mid-level ore from Arathi-style ridge routes with Heavy Stone and gem side value.", { "iron", "ironFeralasRoutesMain", "ironWesternPlaguelandsWitAlt" })
RegisterMiningItem(2775, "Silver Ore", { "mining" }, "Ore", "Rare Tin-node replacement. Farm Tin routes and treat Silver as premium turnover value.", { "tin", "tinHillsbradRoutesMain", "tinAshenvaleWitAlt", "tinNorthernStranglethornAlt" })
RegisterMiningItem(2776, "Gold Ore", { "mining" }, "Ore", "Rare Iron-node replacement. Farm Iron routes rather than camping old Gold points.", { "iron", "ironFeralasRoutesMain", "ironWesternPlaguelandsWitAlt" })
RegisterMiningItem(3858, "Mithril Ore", { "mining" }, "Ore", "High-mid ore from Badlands-style loops, with Truesilver and valuable gems as side value.", { "mithril", "mithrilBurningSteppesCompact", "mithrilBurningSteppesCoverage" })
RegisterMiningItem(7911, "Truesilver Ore", { "mining" }, "Ore", "Rare Mithril-node replacement. Use compact Mithril loops and maintain node turnover.", { "mithril", "mithrilBurningSteppesCompact", "mithrilBurningSteppesCoverage", "thoriumWinterspringRoutesMain" })
RegisterMiningItem(10620, "Thorium Ore", { "mining" }, "Ore", "Endgame ore from Small and Rich Thorium nodes. Winterspring has a dense coordinate-backed mountain route.", { "thorium", "thoriumWinterspringRoutesMain", "thoriumSilithusWitAlt", "thoriumWinterspringCoverage" })
RegisterMiningItem(11370, "Dark Iron Ore", { "mining" }, "Ore", "Specialty Blackrock-area ore. Searing Gorge is the open-world route; BRD/MC are controlled alternatives.", { "darkIron" })

RegisterMiningItem(2835, "Rough Stone", { "mining", "engineering" }, "Stone", "Common side material from Copper nodes; farm dense Copper routes for volume.", { "copper", "copperDurotarRoutesMain", "copperDurotarWitAlt" })
RegisterMiningItem(2836, "Coarse Stone", { "mining", "engineering" }, "Stone", "Common side material from Tin nodes; Barrens Tin loops are the practical route.", { "tin", "tinHillsbradRoutesMain", "tinAshenvaleWitAlt", "tinNorthernStranglethornAlt" })
RegisterMiningItem(2838, "Heavy Stone", { "mining", "engineering" }, "Stone", "Side material from Iron nodes; farm Arathi Iron loops.", { "iron", "ironFeralasRoutesMain", "ironWesternPlaguelandsWitAlt" })
RegisterMiningItem(7912, "Solid Stone", { "mining", "engineering" }, "Stone", "Side material from Mithril nodes; Badlands is a compact route.", { "mithril", "mithrilBurningSteppesCompact", "mithrilBurningSteppesCoverage" })
RegisterMiningItem(12365, "Dense Stone", { "mining", "engineering" }, "Stone", "Side material from Thorium nodes; Winterspring, Un'Goro, and Silithus are the main families.", { "thorium", "thoriumWinterspringRoutesMain", "thoriumSilithusWitAlt", "thoriumWinterspringCoverage" })
