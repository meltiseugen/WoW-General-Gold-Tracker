local _, NS = ...
local Register = NS.RegisterMaterialFarmingSpot

local function C(x, y, label)
    return { x = x, y = y, label = label }
end

local function ItemUrl(itemID)
    return "https://www.wowhead.com/item=" .. tostring(itemID)
end

local BASTION_ORE_ROUTE = {
    id = "shadowlands-bastion-solenium-laestrite-ridge-loop",
    source = "Wowhead Shadowlands mining guide and mining route notes",
    sourceUrls = {
        "https://www.wowhead.com/guide/shadowlands-mining-profession",
        "https://www.wow-professions.com/guides/shadowlands-mining-leveling-guide",
    },
    mapName = "Bastion",
    location = "Aspirant's Rest, Hero's Rest, and southern Bastion rocky ridge loop",
    routeType = "mining-loop",
    density = "High for Solenium and Laestrite",
    dropDifficulty = "Easy. Bastion is one of the friendliest Shadowlands mining zones, with open ridges "
        .. "and moderate hostile pressure.",
    tips = {
        "Stay on top of rocky ridges instead of below cliffs because Shadowlands ore favors ridge edges.",
        "Mine every Laestrite and zone ore node because Elethium and stone are bonus results.",
        "The route overlaps with easy herbalism and neutral beast skinning areas.",
    },
    coords = {
        C(0.460, 0.440, "Aspirant's Rest switchback ridge"),
        C(0.536, 0.520, "Hero's Rest ridge line"),
        C(0.612, 0.620, "Southern plateau edge"),
        C(0.548, 0.724, "Purity's Reflection ridge"),
        C(0.414, 0.682, "Western return ridge"),
    },
    confidence = "high",
}

local MALDRAXXUS_ORE_ROUTE = {
    id = "shadowlands-maldraxxus-theater-oxxein-loop",
    source = "Wowhead Shadowlands mining guide and Theater of Pain gatherer reports",
    sourceUrls = {
        "https://www.wowhead.com/guide/shadowlands-mining-profession",
        "https://www.wowhead.com/guide/shadowlands-herbalism-profession",
    },
    mapName = "Maldraxxus",
    location = "Outer Theater of Pain and Glutharn's Decay ridge route",
    routeType = "mining-loop",
    density = "Medium",
    dropDifficulty = "Moderate. Good Oxxein targeting, but mob density and terrain make it slower than Bastion.",
    tips = {
        "Circle the Theater of Pain perimeter for the least painful Oxxein route.",
        "Avoid deep House areas unless you are already clearing mobs for another goal.",
        "This route can pick up Marrowroot and Death Blossom while mining.",
    },
    coords = {
        C(0.446, 0.468, "West Theater ridge"),
        C(0.506, 0.392, "North Theater rim"),
        C(0.584, 0.472, "East Theater ridge"),
        C(0.628, 0.604, "Glutharn's Decay extension"),
        C(0.494, 0.646, "Southern return ridge"),
    },
    confidence = "high",
}

local ARDENWEALD_ORE_ROUTE = {
    id = "shadowlands-ardenweald-phaedrum-cloverleaf-loop",
    source = "Wowhead Shadowlands mining guide and Ardenweald gather route comments",
    sourceUrls = {
        "https://www.wowhead.com/guide/shadowlands-mining-profession",
        "https://www.wowhead.com/guide/shadowlands-herbalism-profession",
    },
    mapName = "Ardenweald",
    location = "Refugee Camp cloverleaf route across root ridges and open forest edges",
    routeType = "mining-loop",
    density = "Medium to high",
    dropDifficulty = "Easy to moderate. Open terrain is good, but nodes can hide behind trees and roots.",
    tips = {
        "Use a cloverleaf around the central camp rather than only the outer zone edge.",
        "Check root-strewn ridges carefully because ore can be visually hidden.",
        "Pair with Vigil's Torch and Death Blossom if dual gathering.",
    },
    coords = {
        C(0.352, 0.518, "Western cloverleaf start"),
        C(0.418, 0.636, "Southwest root ridge"),
        C(0.516, 0.586, "Central camp return"),
        C(0.612, 0.492, "Eastern forest ridge"),
        C(0.542, 0.356, "Northern ridge line"),
    },
    confidence = "high",
}

local REVENDRETH_ORE_ROUTE = {
    id = "shadowlands-revendreth-sinvyr-sanctuary-pridefall-route",
    source = "Wowhead Shadowlands mining guide and Revendreth herb waypoint route reports",
    sourceUrls = {
        "https://www.wowhead.com/guide/shadowlands-mining-profession",
        "https://www.wowhead.com/guide/shadowlands-herbalism-profession",
        "https://www.wow-professions.com/farming/widowbloom-farming",
    },
    mapName = "Revendreth",
    location = "Sanctuary of the Mad to Pridefall Hamlet and Sinfall-side ridges",
    routeType = "mining-loop",
    density = "Medium",
    dropDifficulty = "Moderate. Good Sinvyr targeting, but elevators, walls, and elevation changes slow the loop.",
    tips = {
        "Use the southern half of Revendreth and the western Sinfall ridge pockets.",
        "Avoid dense urban blocks unless a node is directly visible.",
        "The same path works as a Widowbloom and Death Blossom route.",
    },
    coords = {
        C(0.310, 0.527, "Sanctuary approach"),
        C(0.406, 0.682, "Southern lower route"),
        C(0.505, 0.719, "Pridefall road edge"),
        C(0.619, 0.694, "Eastern ridge check"),
        C(0.350, 0.430, "Sinfall-side ridge"),
    },
    confidence = "high",
}

local KORTHIA_ELETHIUM_ROUTE = {
    id = "shadowlands-korthia-elethium-node-loop",
    source = "Wowhead Shadowlands mining guide and Elethium farming guide",
    sourceUrls = {
        "https://www.wowhead.com/guide/shadowlands-mining-profession",
        "https://www.wow-professions.com/farming/elethium-ore-farming",
    },
    mapName = "Korthia",
    location = "Korthia dedicated Elethium node route through ridges and ruins",
    routeType = "elethium-mining-loop",
    density = "Medium",
    dropDifficulty = "Moderate. Korthia is the best targeted Elethium zone, but mobs and terrain can slow "
        .. "ground routes.",
    tips = {
        "Use Korthia when Elethium is the target instead of hoping for rare Laestrite-node results.",
        "Check ridge tops and ruin edges before dropping into lower terrain.",
        "Flying makes this route much smoother once unlocked.",
    },
    coords = {
        C(0.432, 0.348, "Keeper's Respite north ridge"),
        C(0.500, 0.426, "Central ruin edge"),
        C(0.586, 0.544, "Eastern ridge check"),
        C(0.482, 0.662, "Southern return ridge"),
        C(0.354, 0.552, "Western Korthia ridge"),
    },
    confidence = "high",
}

local MAW_ELETHIUM_ROUTE = {
    id = "shadowlands-maw-elethium-edge-route",
    source = "Wowhead Shadowlands mining guide and Elethium farming guide",
    sourceUrls = {
        "https://www.wowhead.com/guide/shadowlands-mining-profession",
        "https://www.wow-professions.com/farming/elethium-ore-farming",
    },
    mapName = "The Maw",
    location = "Maw ridge and ruin checks for dedicated Elethium deposits",
    routeType = "elethium-mining-loop",
    density = "Medium",
    dropDifficulty = "Harder than Korthia because old Maw travel restrictions and hostile density can punish "
        .. "long loops.",
    tips = {
        "Farm this only when you can move through the Maw comfortably.",
        "Dedicated Elethium deposits make it better than covenant zones for targeted Elethium.",
        "Skip long detours into heavy elite areas unless the node is visible.",
    },
    coords = {
        C(0.346, 0.492, "Western ruin edge"),
        C(0.420, 0.386, "Northwest ridge"),
        C(0.514, 0.542, "Central Maw check"),
        C(0.588, 0.644, "Southeast ridge"),
        C(0.474, 0.720, "Southern return edge"),
    },
    confidence = "medium",
}

local ZERETH_MORTIS_PROGENIUM_ROUTE = {
    id = "shadowlands-zereth-mortis-progenium-first-flower-route",
    source = "Retail Wowhead Patch 9.2 mining guide, Wowhead Progenium Deposit object pins, and Artisans of Azeroth Zereth Mortis route string",
    sourceUrls = {
        "https://www.wowhead.com/guide/shadowlands-mining-profession",
        "https://www.wowhead.com/guide/profession-updates-patch-9-2-vestige-of-the-eternal",
        "https://www.wowhead.com/item=187700/progenium-ore",
        "https://www.wowhead.com/object=370400/progenium-deposit",
        "https://artisansofazeroth.com/progenium-ore-frist-flower-route-zereth-mortis/",
    },
    mapName = "Zereth Mortis",
    location = "Northern and northeastern Zereth Mortis Progenium route through Resonant Peaks and desert ridges",
    routeType = "mining-loop",
    density = "Medium for rare Progenium, with Laestrite and Elethium side nodes",
    dropDifficulty = "Moderate. Progenium is rare and concentrated in rugged Zereth Mortis pockets, so clear normal ore while moving.",
    tips = {
        "Use this as a map-route seed for Progenium Ore, then clear every mining node on the loop.",
        "Progenium can be prospected, but Patch 9.2 guides note it does not add new gem types.",
        "The path overlaps First Flower and Progenitor Essentia gathering chances for dual gatherers.",
    },
    coords = {
        C(0.5005, 0.2543, "Artisans route northwestern loop point"),
        C(0.5534, 0.2880, "Artisans route northern ridge"),
        C(0.5814, 0.2962, "Artisans route Resonant Peaks point"),
        C(0.5796, 0.2573, "Northern Progenium route turn"),
        C(0.5944, 0.2443, "Northern ridge object cluster"),
        C(0.6234, 0.2120, "Wowhead object and Artisans route overlap"),
        C(0.6551, 0.2140, "Northeastern route point"),
        C(0.6719, 0.2668, "Northeast Progenium object cluster"),
        C(0.6660, 0.2997, "Eastern route descent"),
        C(0.6459, 0.2925, "Eastern return object cluster"),
        C(0.6286, 0.3083, "Central-eastern route point"),
        C(0.6171, 0.3441, "Southern ridge return"),
        C(0.6630, 0.3513, "Southeastern loop point"),
        C(0.6931, 0.3355, "Eastern Progenium object pin"),
        C(0.6723, 0.3943, "Southeast return ridge"),
        C(0.6457, 0.4186, "Southern route bend"),
        C(0.6434, 0.3795, "Eastern ridge return"),
        C(0.5964, 0.3578, "Central return"),
    },
    confidence = "high",
}

local function RegisterOre(itemID, itemName, spots, summary, category)
    Register({
        itemID = itemID,
        itemName = itemName,
        expansion = "shadowlands",
        professions = { "mining" },
        category = category or "Ore",
        sourceUrls = { ItemUrl(itemID) },
        summary = summary,
        spots = spots,
    })
end

RegisterOre(171828, "Laestrite Ore", {
    BASTION_ORE_ROUTE,
    ARDENWEALD_ORE_ROUTE,
    REVENDRETH_ORE_ROUTE,
}, "Common Shadowlands ore from all four covenant zones; Bastion and Ardenweald are the easiest general "
    .. "routes.")
RegisterOre(171829, "Solenium Ore", { BASTION_ORE_ROUTE },
    "Bastion zone ore found from Solenium deposits and rich deposits.")
RegisterOre(171830, "Oxxein Ore", { MALDRAXXUS_ORE_ROUTE },
    "Maldraxxus zone ore best targeted around Theater of Pain ridges.")
RegisterOre(171831, "Phaedrum Ore", { ARDENWEALD_ORE_ROUTE },
    "Ardenweald zone ore from forest ridge routes.")
RegisterOre(171832, "Sinvyr Ore", { REVENDRETH_ORE_ROUTE },
    "Revendreth zone ore from southern and Sinfall-side ridge routes.")
RegisterOre(171833, "Elethium Ore", {
    KORTHIA_ELETHIUM_ROUTE,
    MAW_ELETHIUM_ROUTE,
}, "Rare covenant-zone ore, best target-farmed from dedicated deposits in Korthia and The Maw.")
RegisterOre(171840, "Porous Stone", {
    BASTION_ORE_ROUTE,
    MALDRAXXUS_ORE_ROUTE,
    ARDENWEALD_ORE_ROUTE,
    REVENDRETH_ORE_ROUTE,
}, "Common Shadowlands stone side material from mining covenant-zone deposits.", "Stone")
RegisterOre(171841, "Shaded Stone", {
    BASTION_ORE_ROUTE,
    REVENDRETH_ORE_ROUTE,
    KORTHIA_ELETHIUM_ROUTE,
    ZERETH_MORTIS_PROGENIUM_ROUTE,
}, "Shadowlands stone side material gathered through mining and used by blacksmithing.", "Stone")
RegisterOre(187700, "Progenium Ore", { ZERETH_MORTIS_PROGENIUM_ROUTE },
    "Patch 9.2 Zereth Mortis ore from rare Progenium deposits, rich deposits, and rugged northern/eastern mining loops.")
