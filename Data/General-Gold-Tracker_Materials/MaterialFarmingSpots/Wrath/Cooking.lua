local _, NS = ...
local Register = NS.RegisterMaterialFarmingSpot

local function C(x, y, label)
    return { x = x, y = y, label = label }
end

local function ItemUrl(itemID)
    return "https://www.wowhead.com/item=" .. tostring(itemID)
end

local COOKING_GUIDE = "https://www.wowhead.com/guide/cooking-materials-best-farming-locations"

local CHILLED_MEAT_ROUTE = {
    id = "wrath-chilled-meat-borean-marsh-caribou",
    source = "Retail Wowhead Chilled Meat item/quest comments and Marsh Caribou route notes",
    sourceUrls = {
        ItemUrl(43013),
        "https://www.wowhead.com/quest=13090/northern-cooking",
        "https://www.wowhead.com/npc=25680/marsh-caribou",
        COOKING_GUIDE,
    },
    mapName = "Borean Tundra",
    location = "Marsh Caribou route through the Borean Tundra marsh east of Warsong Hold",
    routeType = "open-world-beast-loop",
    density = "High",
    dropDifficulty = "Broad Northrend beast drop; this route uses a compact comment-backed caribou cluster.",
    tips = {
        "Kill every Marsh Caribou while circling the marsh and skin if you can for Borean Leather side value.",
        "Use this for Chilled Meat volume instead of chasing every Northrend beast source.",
        "Rhino and mammoth routes also produce Chilled Meat as side value, but less predictably in retail data.",
    },
    coords = {
        C(0.612, 0.592, "Marsh Caribou southeast pack"),
        C(0.586, 0.572, "Central caribou pack"),
        C(0.564, 0.516, "North marsh caribou"),
        C(0.570, 0.472, "Northern caribou return"),
    },
    confidence = "high",
}

local SHOVELTUSK_ROUTE = {
    id = "wrath-shoveltusk-flank-howling-fjord-south-herds",
    source = "Retail Wowhead Shoveltusk Flank comments and Shoveltusk NPC page",
    sourceUrls = {
        ItemUrl(43009),
        "https://www.wowhead.com/npc=23690/shoveltusk",
        "https://www.wowhead.com/npc=29479/shoveltusk-forager",
        COOKING_GUIDE,
    },
    mapName = "Howling Fjord",
    location = "Southern Howling Fjord Shoveltusk herds around Nifflevar and Explorer's League outpost",
    routeType = "open-world-beast-loop",
    density = "High",
    dropDifficulty = "Good AoE farm because Shoveltusks move in herds and also drop Chilled Meat.",
    tips = {
        "Stay in the southeast quadrant and pull herds rather than single foragers.",
        "Use the route for Shoveltusk Flank with Chilled Meat and Borean Leather as side value.",
        "Avoid widening into northern Howling Fjord; travel time hurts the meat rate.",
    },
    coords = {
        C(0.724, 0.586, "Nifflevar northwest herd"),
        C(0.760, 0.630, "Comment-backed Shoveltusk herd"),
        C(0.786, 0.666, "Southern herd pack"),
        C(0.742, 0.706, "Explorer's League herd"),
        C(0.682, 0.676, "Western herd return"),
    },
    confidence = "high",
}

local WORM_WORG_ROUTE = {
    id = "wrath-worm-worg-storm-peaks-gimoraks-den",
    source = "Retail Wowhead Worm Meat and Infesting Jormungar comments",
    sourceUrls = {
        ItemUrl(43010),
        ItemUrl(43011),
        "https://www.wowhead.com/npc=30148/infesting-jormungar",
        COOKING_GUIDE,
    },
    mapName = "The Storm Peaks",
    location = "Gimorak's Den cave and nearby worg packs near the Engine of the Makers",
    routeType = "open-world-cave-loop",
    density = "High",
    dropDifficulty = "Good compact cave farm for Worm Meat with Worg Haunch as a useful side target.",
    tips = {
        "Enter around 47,55 and clear the cave loop before widening to nearby worgs.",
        "Skin worms and worgs for Jormungar Scale, Borean Leather, and Arctic Fur side value.",
        "If worm respawns lag, kill the worgs in the same cave rather than leaving the route.",
    },
    coords = {
        C(0.470, 0.550, "Gimorak's Den entrance"),
        C(0.460, 0.530, "Western worm pocket"),
        C(0.480, 0.548, "Central worm and worg pack"),
        C(0.500, 0.562, "Southern worm pocket"),
        C(0.516, 0.534, "Eastern cave pack"),
    },
    confidence = "high",
}

local RHINO_ROUTE = {
    id = "wrath-rhino-meat-borean-tundra-amber-ledge-herds",
    source = "Retail Wowhead Rhino Meat comments and Wooly Rhino Matriarch NPC page",
    sourceUrls = {
        ItemUrl(43012),
        "https://www.wowhead.com/npc=25487/wooly-rhino-matriarch",
        COOKING_GUIDE,
    },
    mapName = "Borean Tundra",
    location = "Rhino packs between Amber Ledge, Warsong Hold, and Valiance Keep",
    routeType = "open-world-beast-loop",
    density = "High",
    dropDifficulty = "Good AoE farm. Rhino packs are compact and also support skinning side value.",
    tips = {
        "Loop west of Valiance Keep and south of Amber Ledge where rhinos travel in packs.",
        "AoE grouped calves and matriarchs first; bulls are more annoying but still useful.",
        "This route is also a practical Borean Leather side farm.",
    },
    coords = {
        C(0.430, 0.740, "Valiance west rhino pack"),
        C(0.455, 0.724, "Central rhino herd"),
        C(0.480, 0.720, "Eastern rhino pack"),
        C(0.444, 0.684, "Amber Ledge south herd"),
        C(0.402, 0.706, "Western herd return"),
    },
    confidence = "high",
}

local MAMMOTH_ROUTE = {
    id = "wrath-mammoth-meat-sholazar-glimmering-pillar",
    source = "Retail Wowhead Chunk o' Mammoth comments and Shattertusk Mammoth route notes",
    sourceUrls = {
        ItemUrl(34736),
        "https://www.wowhead.com/npc=28096/shattertusk-mammoth",
        COOKING_GUIDE,
    },
    mapName = "Sholazar Basin",
    location = "Shattertusk Mammoth families around the Glimmering Pillar",
    routeType = "open-world-beast-loop",
    density = "High",
    dropDifficulty = "Strong compact mammoth route with skinning side value.",
    tips = {
        "Work east and northeast of the Glimmering Pillar instead of chasing isolated mammoths.",
        "Pull family packs together for faster meat and Borean Leather turnover.",
        "Use Borean Tundra mammoths as a backup if Sholazar is crowded.",
    },
    coords = {
        C(0.530, 0.380, "Glimmering Pillar mammoths"),
        C(0.560, 0.360, "Northeast mammoth family"),
        C(0.590, 0.390, "Eastern mammoth pack"),
        C(0.548, 0.420, "South return mammoths"),
    },
    confidence = "high",
}

local NORTHERN_EGG_ROUTE = {
    id = "wrath-northern-egg-sholazar-goretalon-rocs",
    source = "Retail Wowhead Northern Egg comments and Goretalon Roc farm notes",
    sourceUrls = {
        ItemUrl(43501),
        "https://www.wowhead.com/npc=28004/goretalon-roc",
        COOKING_GUIDE,
    },
    mapName = "Sholazar Basin",
    location = "Goretalon Rocs around north Sholazar Basin",
    routeType = "open-world-bird-loop",
    density = "Medium",
    dropDifficulty = "Localized bird drop. Strongest comments point to north Sholazar roc clusters.",
    tips = {
        "Start around 59,28 and sweep nearby rocs before widening east.",
        "Northern Egg demand spikes during Children's Week achievement activity.",
        "Use Howling Fjord hawks only as a backup because the Sholazar route is tighter.",
    },
    coords = {
        C(0.590, 0.280, "Goretalon Roc core"),
        C(0.620, 0.300, "Northeast roc patrol"),
        C(0.602, 0.340, "South roc check"),
        C(0.560, 0.304, "West roc return"),
    },
    confidence = "high",
}

local function RegisterCooking(itemID, itemName, category, spots, summary)
    Register({
        itemID = itemID,
        itemName = itemName,
        expansion = "wrath",
        professions = { "cooking" },
        category = category,
        sourceUrls = { ItemUrl(itemID), COOKING_GUIDE },
        summary = summary,
        spots = spots,
    })
end

RegisterCooking(43013, "Chilled Meat", "Meat", { CHILLED_MEAT_ROUTE, SHOVELTUSK_ROUTE },
    "Broad Northrend beast meat; Borean Marsh Caribou gives a compact coordinate-backed route.")
RegisterCooking(43009, "Shoveltusk Flank", "Meat", { SHOVELTUSK_ROUTE },
    "Howling Fjord Shoveltusk herds are the best practical coordinate-backed flank farm.")
RegisterCooking(43010, "Worm Meat", "Meat", { WORM_WORG_ROUTE },
    "Storm Peaks jormungar cave farm for Worm Meat with skinning side value.")
RegisterCooking(43011, "Worg Haunch", "Meat", { WORM_WORG_ROUTE },
    "Wrath worg meat from compact Storm Peaks cave packs, paired with Worm Meat.")
RegisterCooking(43012, "Rhino Meat", "Meat", { RHINO_ROUTE },
    "Borean Tundra rhino herds west of Valiance Keep and south of Amber Ledge.")
RegisterCooking(34736, "Chunk o' Mammoth", "Meat", { MAMMOTH_ROUTE },
    "Sholazar mammoth families near the Glimmering Pillar are a compact mammoth meat farm.")
RegisterCooking(43501, "Northern Egg", "Egg", { NORTHERN_EGG_ROUTE },
    "Northern Egg from Sholazar roc clusters, with Howling Fjord hawks as backup.")
