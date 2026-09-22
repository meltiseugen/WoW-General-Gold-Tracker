local _, NS = ...
local Register = NS.RegisterMaterialFarmingSpot

local ORE_GUIDE = "https://www.wowhead.com/guide/classic-mining-best-farming-basics-early-ores"
local MINING_GUIDE = "https://www.wowhead.com/guide/mining-leveling-1-300-wow-classic"
local COPPER_GUIDE = "https://www.wow-professions.com/farming/copper-ore-farming"
local TIN_GUIDE = "https://www.wow-professions.com/farming/tin-ore-farming"
local IRON_GUIDE = "https://www.wow-professions.com/farming/iron-ore-farming"
local MITHRIL_GUIDE = "https://www.wow-professions.com/farming/mithril-ore-farming"
local THORIUM_GUIDE = "https://www.wow-professions.com/farming/thorium-ore-farming"
local DARK_IRON_GUIDE = "https://www.wow-professions.com/farming/dark-iron-ore-farming"
local ARTISANS_COPPER = "https://artisansofazeroth.com/copper-ore-farming/"
local ARTISANS_TIN = "https://artisansofazeroth.com/tin-ore-farming/"
local ARTISANS_MITHRIL = "https://artisansofazeroth.com/mithril-ore-farming/"
local ARTISANS_THORIUM = "https://artisansofazeroth.com/thorium-ore-farming/"

local function C(x, y, label)
    return { x = x, y = y, label = label }
end

local function ItemUrl(itemID)
    return "https://www.wowhead.com/item=" .. tostring(itemID)
end

local IMPORTED_ROUTES_SOURCE = "Supplied Retail Routes exports decoded into ordered static route pins and cross-checked against public farming guides"

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
    urls = { COPPER_GUIDE, ARTISANS_COPPER, "https://www.wowhead.com/object=1731/copper-vein" },
    mapID = 1,
    mapName = "Durotar",
    location = "Main - straightforward Durotar Copper loop",
    routeType = "imported-mining-loop",
    density = "High",
    difficulty = "Straightforward low-terrain Copper loop; best when hugging ridges, hills, cliffs, and zone edges.",
    tips = {
        "Good route if you want a simple uninterrupted circuit.",
        "Stay close to hills, ridges, cliffs, and zone edges; Copper nodes heavily favor terrain boundaries.",
        "If the route feels empty, complete the full circuit before changing zones because node respawns are distributed across the zone.",
        "Works well with fast ground movement or flying in Retail.",
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
    urls = { COPPER_GUIDE, ARTISANS_COPPER, "https://www.wowhead.com/object=1731/copper-vein" },
    mapID = 1,
    mapName = "Durotar",
    location = "Alternative - Durotar Copper loop for crowded main-route conditions",
    routeType = "imported-mining-loop",
    density = "Medium-High",
    difficulty = "Alternative Durotar Copper geometry for crowded main-route conditions.",
    tips = {
        "This is useful when you want to avoid following the exact same path as other farmers.",
        "Because both routes use Durotar, compare them over 2-3 complete laps rather than judging after only a few minutes.",
        "Favor outer mountain walls over cutting directly through the middle of the zone.",
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
    urls = { TIN_GUIDE, ARTISANS_TIN, "https://www.wowhead.com/object=1732/tin-vein" },
    mapID = 25,
    mapName = "Hillsbrad Foothills",
    location = "Main - Hillsbrad Foothills Tin and Silver turnover loop",
    routeType = "imported-mining-loop",
    density = "High",
    difficulty = "Compact Tin route that also supports rare Silver replacement chances.",
    tips = {
        "Follow mountain faces closely instead of flying through flat open fields.",
        "Tin commonly shares its spawn ecosystem with Silver, so mine every node you see.",
        "Do not skip Copper or other eligible nodes along the route; clearing nodes helps cycle the spawn pool.",
        "Hillsbrad is compact enough that repeated loops are efficient.",
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
    urls = { TIN_GUIDE, ARTISANS_TIN, "https://www.wowhead.com/object=1732/tin-vein" },
    mapID = 63,
    mapName = "Ashenvale",
    location = "Alternative - longer Ashenvale Tin and Silver loop",
    routeType = "imported-mining-loop",
    density = "Medium",
    difficulty = "Longer, less compact Tin route with irregular terrain and tree cover.",
    tips = {
        "Ashenvale terrain is irregular; use the route as a guide, but prioritize cliff bases and rocky transitions.",
        "Do not fly too high because tree cover can make node spotting annoying even with minimap tracking.",
        "This route is more suitable for longer farming sessions than short 10-minute runs.",
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
    urls = { TIN_GUIDE, ARTISANS_TIN, "https://www.wowhead.com/object=1732/tin-vein" },
    mapID = 50,
    mapName = "Northern Stranglethorn",
    location = "Alternative - Northern Stranglethorn Tin and Silver wall loop",
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
    urls = { IRON_GUIDE, "https://www.wowhead.com/object=1735/iron-deposit" },
    mapID = 69,
    mapName = "Feralas",
    location = "Main - broad Feralas Iron and Gold outer-mountain loop",
    routeType = "imported-mining-loop",
    density = "High",
    difficulty = "Broad Iron farming route with Gold bonus potential; flying makes a significant difference.",
    tips = {
        "Follow mountain ranges and high terrain rather than crossing open central areas.",
        "Feralas is large, so flying makes a significant difference.",
        "Mine Mithril and Gold-compatible nodes you encounter instead of selectively skipping them.",
        "This is a good route if you want a mixture of mid-tier Vanilla mining materials.",
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
    urls = { IRON_GUIDE, "https://www.wowhead.com/object=1735/iron-deposit" },
    mapID = 22,
    mapName = "Western Plaguelands",
    location = "Alternative - compact Western Plaguelands Iron and Gold loop",
    routeType = "imported-mining-loop",
    density = "Medium-High",
    difficulty = "Shorter, more compact Iron route for repeated spawn cycling.",
    tips = {
        "This is better than Feralas if you prefer short loops.",
        "The zone is good for repeatedly clearing the same spawn areas.",
        "Check terrain edges and hills rather than staying exactly on roads.",
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
    urls = { MITHRIL_GUIDE, ARTISANS_MITHRIL, "https://www.wowhead.com/object=2040/mithril-deposit" },
    mapID = 36,
    mapName = "Burning Steppes",
    location = "Main - compact Burning Steppes Mithril and Truesilver mountain loop",
    routeType = "imported-mining-loop",
    density = "High",
    difficulty = "Compact Mithril farm with Truesilver potential and little wasted open space.",
    tips = {
        "Hug the mountains surrounding the zone.",
        "Check around caves and rocky formations when they are close to the route.",
        "Burning Steppes has relatively little wasted open space, making it efficient for repeated loops.",
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
    urls = { MITHRIL_GUIDE, ARTISANS_MITHRIL, "https://www.wowhead.com/object=2040/mithril-deposit" },
    mapID = 36,
    mapName = "Burning Steppes",
    location = "Alternative - denser Burning Steppes Mithril coverage sweep",
    routeType = "imported-mining-loop",
    density = "High",
    difficulty = "More exhaustive Mithril sweep with extra turns for broader node coverage.",
    tips = {
        "More route points means better coverage but slightly more turning.",
        "Prefer this if you want maximum node coverage rather than the shortest lap time.",
        "This route is useful when nodes are sparse because it checks more of the viable terrain.",
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
    urls = { THORIUM_GUIDE, ARTISANS_THORIUM, "https://www.wowhead.com/object=324/small-thorium-vein", "https://www.wowhead.com/object=175404/rich-thorium-vein" },
    mapID = 83,
    mapName = "Winterspring",
    location = "Main - Winterspring Thorium and Truesilver mountain loop",
    routeType = "imported-mining-loop",
    density = "High",
    difficulty = "Reliable Thorium route that benefits from flying speed due to Winterspring size.",
    tips = {
        "Hug mountain chains.",
        "Prioritize Rich Thorium Deposit areas.",
        "Do not skip standard Thorium nodes because cycling all nodes improves overall throughput.",
        "Winterspring's large size means flying is strongly recommended.",
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
    urls = { THORIUM_GUIDE, ARTISANS_THORIUM, "https://www.wowhead.com/object=324/small-thorium-vein", "https://www.wowhead.com/object=175404/rich-thorium-vein" },
    mapID = 81,
    mapName = "Silithus",
    location = "Alternative - Silithus Thorium outer-zone loop",
    routeType = "imported-mining-loop",
    density = "High",
    difficulty = "Excellent Thorium alternative for dense outer-zone mining when Winterspring has competition.",
    tips = {
        "Circle the outside of the zone and major rocky formations.",
        "Silithus terrain naturally suits circular mining routes.",
        "Use this route if Winterspring has competition.",
        "Check hive and mountain areas when they do not require a large detour.",
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
    urls = { THORIUM_GUIDE, ARTISANS_THORIUM, "https://www.wowhead.com/object=324/small-thorium-vein", "https://www.wowhead.com/object=175404/rich-thorium-vein" },
    mapID = 83,
    mapName = "Winterspring",
    location = "Alternative - exhaustive 56-point Winterspring Thorium loop",
    routeType = "imported-mining-loop",
    density = "High",
    difficulty = "Denser Winterspring coverage route with more direction changes than the main loop.",
    tips = {
        "This route is much denser than the main Winterspring route.",
        "Use it when you care more about node coverage than smooth flying.",
        "Expect more direction changes.",
        "Test this route if the shorter Winterspring circuit consistently misses nodes.",
    },
    coords = ImportedRouteCoords("Routes Winterspring Thorium coverage", {
        { 0.2310, 0.4701 },
        { 0.2740, 0.4853 },
        { 0.3423, 0.4800 },
        { 0.4031, 0.4588 },
        { 0.4297, 0.4725 },
        { 0.4163, 0.5050 },
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
        { 0.4453, 0.1833 },
        { 0.4454, 0.2148 },
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

ROUTES.tinHillsbradRoutesMain.itemVariants = {
    [2775] = {
        location = "Main - Hillsbrad Foothills Tin route for Silver turnover",
        difficulty = "Best supplied Silver option; Silver is a rare bonus while cycling the full Tin route.",
        tips = {
            "Mine all Tin nodes; do not only search for Silver.",
            "Clearing Tin helps keep the node ecosystem cycling.",
            "One full Hillsbrad loop is generally better than randomly jumping between reported Silver spawn points.",
            "If Silver is the goal, run this route first.",
        },
    },
}

ROUTES.tinAshenvaleWitAlt.itemVariants = {
    [2775] = {
        location = "Alternative - Ashenvale Tin route for Silver turnover",
        difficulty = "Longer Silver-turnover alternative when Hillsbrad is heavily farmed.",
        tips = {
            "Use this route if Hillsbrad is heavily farmed.",
            "Keep close to rocky terrain.",
            "Treat Silver as a bonus spawn while aggressively clearing Tin.",
        },
    },
}

ROUTES.ironFeralasRoutesMain.itemVariants = {
    [2776] = {
        location = "Main - Feralas Iron route for Gold turnover",
        difficulty = "Best supplied combination of Iron and Gold potential; Gold remains a rare bonus node.",
        tips = {
            "Mine Iron and Mithril too.",
            "Do not fly from known Gold coordinate to Gold coordinate; that usually wastes time.",
            "Treat Gold as a high-value bonus while cycling the whole zone.",
            "Outer Feralas mountain chains are more important than open ground.",
        },
    },
}

ROUTES.ironWesternPlaguelandsWitAlt.itemVariants = {
    [2776] = {
        location = "Alternative - Western Plaguelands Iron route for Gold turnover",
        difficulty = "Faster full-loop option for repeatedly cycling Iron and Gold spawn opportunities.",
        tips = {
            "This route has a faster full-loop time than Feralas.",
            "Use it when your goal is repeatedly cycling Iron and Gold spawn points.",
            "It is a good alternative when Feralas feels too spread out.",
        },
    },
}

ROUTES.mithrilBurningSteppesCompact.itemVariants = {
    [7911] = {
        location = "Main - Burning Steppes Mithril route for Truesilver turnover",
        difficulty = "Compact mountainous route for Mithril and rare Truesilver replacement opportunities.",
        tips = {
            "Mine every Mithril node.",
            "Do not ignore Thorium nodes if present.",
            "Burning Steppes is particularly convenient because the route is compact and mountainous.",
            "If Truesilver is your only goal, repeat full laps rather than waiting around known coordinates.",
        },
    },
}

ROUTES.thoriumWinterspringRoutesMain.itemVariants = {
    [7911] = {
        location = "Alternative - Winterspring Thorium route for Truesilver turnover",
        difficulty = "Longer Truesilver-turnover route that also targets Small and Rich Thorium nodes.",
        tips = {
            "Use this route if you also want Thorium.",
            "Mine both Small Thorium and Rich Thorium nodes where available.",
            "Winterspring is larger than Burning Steppes, so this route benefits more from flying speed.",
            "Stay close to mountains and cliff bases.",
        },
    },
}

ROUTES.darkIronInstances = {
    source = "Supplied Classic mining notes cross-checked against public Dark Iron and Blackrock instance pages",
    urls = {
        DARK_IRON_GUIDE,
        "https://www.wowhead.com/item=11370/dark-iron-ore",
        "https://www.wowhead.com/zone=1584/blackrock-depths",
        "https://www.wowhead.com/zone=2717/molten-core",
    },
    mapID = 36,
    mapName = "Burning Steppes",
    location = "Blackrock Depths and Molten Core entrance anchors - no verified in-instance route",
    routeType = "instance-mining-target",
    density = "Instance-specific",
    difficulty = "No trustworthy Retail Routes import exists; dungeon geometry, doors, packs, and resets determine efficiency.",
    tips = {
        "Treat Dark Iron as an instance farming material, not an outdoor Routes-addon material.",
        "Blackrock Depths is the main practical mining environment.",
        "Mine every Dark Iron Deposit you can access during the dungeon circuit.",
        "If farming purely for ore, optimize your dungeon path around deposits instead of clearing unnecessary bosses or trash.",
    },
    coords = {
        C(0.210, 0.382, "Blackrock Mountain entrance"),
        C(0.270, 0.240, "Blackrock instance entrance area"),
    },
    confidence = "high",
    isRoute = false,
}

ROUTES.elementiumBwl = {
    source = "Supplied Classic mining notes cross-checked against Wowhead's Elementium Ore and Blackwing Lair pages",
    urls = {
        "https://www.wowhead.com/item=18562/elementium-ore",
        "https://www.wowhead.com/zone=2677/blackwing-lair",
    },
    mapID = 36,
    mapName = "Burning Steppes",
    location = "Blackwing Lair entrance anchor - no outdoor mining route",
    routeType = "instance-mining-target",
    density = "Instance-specific",
    difficulty = "The original Vanilla material is tied to Blackwing Lair rather than normal outdoor mining.",
    tips = {
        "Do not confuse this with Cataclysm Elementium Ore.",
        "The original Vanilla material is associated with Blackwing Lair rather than normal outdoor mining.",
        "A Routes-addon line provides little practical value for this material.",
        "Use an instance-specific farming path rather than a continent mining loop.",
    },
    coords = { C(0.210, 0.382, "Blackrock Mountain and Blackwing Lair approach") },
    confidence = "high",
    isRoute = false,
}

ROUTES.obsidianAq = {
    source = "Supplied Classic mining notes cross-checked against Wowhead's Obsidian Shard and Ahn'Qiraj pages",
    urls = {
        "https://www.wowhead.com/zone=3429/ruins-of-ahnqiraj",
        "https://www.wowhead.com/zone=3428/temple-of-ahnqiraj",
    },
    mapID = 81,
    mapName = "Silithus",
    location = "Ruins and Temple of Ahn'Qiraj entrance anchor - no verified in-instance route",
    routeType = "instance-mining-target",
    density = "Instance-specific",
    difficulty = "Obsidian chunks are tied to Ahn'Qiraj content and instance mechanics, not predictable outdoor mountain nodes.",
    coords = { C(0.289, 0.920, "Ahn'Qiraj gate and instance entrances") },
    confidence = "high",
    isRoute = false,
    itemVariants = {
        [22202] = {
            urls = {
                "https://www.wowhead.com/item=22202/small-obsidian-shard",
                "https://www.wowhead.com/zone=3429/ruins-of-ahnqiraj",
                "https://www.wowhead.com/zone=3428/temple-of-ahnqiraj",
            },
            tips = {
                "Treat this as an Ahn'Qiraj-specific mining material.",
                "Do not treat it like Thorium with predictable outdoor mountain-node circuits.",
                "The relevant Obsidian chunks are tied to Ahn'Qiraj content and instance mechanics.",
                "Instance routing and reset efficiency matter more than a Routes-addon overlay.",
            },
        },
        [22203] = {
            urls = {
                "https://www.wowhead.com/item=22203/large-obsidian-shard",
                "https://www.wowhead.com/zone=3429/ruins-of-ahnqiraj",
                "https://www.wowhead.com/zone=3428/temple-of-ahnqiraj",
            },
            tips = {
                "Use the same Ahn'Qiraj farming category as Small Obsidian Shard.",
                "Prioritize an Ahn'Qiraj instance path rather than trying to construct an outdoor route.",
                "If farming both shard sizes, treat them as one farming session rather than separate routes.",
            },
        },
    },
}

local function RegisterMiningItem(itemID, itemName, professions, category, summary, routeKeys)
    local spots = {}
    local sourceUrls = { ItemUrl(itemID), ORE_GUIDE, MINING_GUIDE }
    for _, routeKey in ipairs(routeKeys) do
        local route = ROUTES[routeKey]
        local variant = route.itemVariants and route.itemVariants[itemID] or nil
        local routeUrls = variant and variant.urls or route.urls
        local function Field(name)
            if variant and variant[name] ~= nil then
                return variant[name]
            end
            return route[name]
        end

        for _, url in ipairs(routeUrls) do
            sourceUrls[#sourceUrls + 1] = url
        end
        spots[#spots + 1] = {
            id = "classic-mining-" .. routeKey .. "-" .. tostring(itemID),
            source = Field("source")
                or "Wowhead retail object pages, Wowhead mining guides, wow-professions route guides, Artisans of Azeroth route pins, and Classic database notes",
            sourceUrls = routeUrls,
            mapID = Field("mapID"),
            mapName = Field("mapName"),
            location = Field("location"),
            routeType = Field("routeType"),
            density = Field("density"),
            dropDifficulty = Field("difficulty"),
            tips = Field("tips"),
            coords = Field("coords"),
            confidence = Field("confidence") or "high",
            isRoute = Field("isRoute") ~= false,
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

RegisterMiningItem(2770, "Copper Ore", { "mining" }, "Ore", "Two supplied Durotar routes provide distinct geometry for straightforward Copper farming.", { "copperDurotarRoutesMain", "copperDurotarWitAlt" })
RegisterMiningItem(2771, "Tin Ore", { "mining" }, "Ore", "Hillsbrad is the main supplied Tin route; Ashenvale and Northern Stranglethorn are alternatives with different competition.", { "tinHillsbradRoutesMain", "tinAshenvaleWitAlt", "tinNorthernStranglethornAlt" })
RegisterMiningItem(2772, "Iron Ore", { "mining" }, "Ore", "Feralas is the broad main Iron route; Western Plaguelands is the shorter alternative.", { "ironFeralasRoutesMain", "ironWesternPlaguelandsWitAlt" })
RegisterMiningItem(2775, "Silver Ore", { "mining" }, "Ore", "Farm strong Tin routes and treat Silver as a rarer bonus in the same general node tier.", { "tinHillsbradRoutesMain", "tinAshenvaleWitAlt" })
RegisterMiningItem(2776, "Gold Ore", { "mining" }, "Ore", "Farm strong Iron and Mithril-tier routes instead of chasing isolated Gold spawn reports.", { "ironFeralasRoutesMain", "ironWesternPlaguelandsWitAlt" })
RegisterMiningItem(3858, "Mithril Ore", { "mining" }, "Ore", "Burning Steppes has both a compact main route and a denser maximum-coverage alternative.", { "mithrilBurningSteppesCompact", "mithrilBurningSteppesCoverage" })
RegisterMiningItem(7911, "Truesilver Ore", { "mining" }, "Ore", "Use the compact Burning Steppes Mithril loop first or the Winterspring Thorium loop when Thorium is also valuable.", { "mithrilBurningSteppesCompact", "thoriumWinterspringRoutesMain" })
RegisterMiningItem(10620, "Thorium Ore", { "mining" }, "Ore", "Winterspring is the main Thorium route, with Silithus and an exhaustive Winterspring sweep as alternatives.", { "thoriumWinterspringRoutesMain", "thoriumSilithusWitAlt", "thoriumWinterspringCoverage" })
RegisterMiningItem(11370, "Dark Iron Ore", { "mining" }, "Dungeon Ore", "Instance-specific Blackrock mining material with no trustworthy Retail Routes import.", { "darkIronInstances" })
RegisterMiningItem(18562, "Elementium Ore", { "mining" }, "Raid Ore", "Original Vanilla Blackwing Lair material; it is not the Cataclysm ore and has no outdoor mining route.", { "elementiumBwl" })
RegisterMiningItem(22202, "Small Obsidian Shard", { "mining" }, "Obsidian Shard", "Ahn'Qiraj-specific mining material without a trustworthy Retail Routes import.", { "obsidianAq" })
RegisterMiningItem(22203, "Large Obsidian Shard", { "mining" }, "Obsidian Shard", "Ahn'Qiraj-specific mining material best farmed in the same sessions as Small Obsidian Shards.", { "obsidianAq" })

RegisterMiningItem(2835, "Rough Stone", { "mining", "engineering" }, "Stone", "Common side material from Copper nodes; farm the supplied Durotar Copper routes for volume.", { "copperDurotarRoutesMain", "copperDurotarWitAlt" })
RegisterMiningItem(2836, "Coarse Stone", { "mining", "engineering" }, "Stone", "Common side material from Tin nodes; use the supplied Tin loops.", { "tinHillsbradRoutesMain", "tinAshenvaleWitAlt", "tinNorthernStranglethornAlt" })
RegisterMiningItem(2838, "Heavy Stone", { "mining", "engineering" }, "Stone", "Side material from Iron nodes; use the supplied Feralas or Western Plaguelands loops.", { "ironFeralasRoutesMain", "ironWesternPlaguelandsWitAlt" })
RegisterMiningItem(7912, "Solid Stone", { "mining", "engineering" }, "Stone", "Side material from Mithril nodes; use either supplied Burning Steppes loop.", { "mithrilBurningSteppesCompact", "mithrilBurningSteppesCoverage" })
RegisterMiningItem(12365, "Dense Stone", { "mining", "engineering" }, "Stone", "Side material from Thorium nodes; Winterspring and Silithus have supplied route options.", { "thoriumWinterspringRoutesMain", "thoriumSilithusWitAlt", "thoriumWinterspringCoverage" })
