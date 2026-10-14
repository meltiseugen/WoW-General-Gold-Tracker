local _, NS = ...
local Register = NS.RegisterMaterialFarmingSpot

local function C(x, y, label)
    return { x = x, y = y, label = label }
end

local function ItemUrl(itemID)
    return "https://www.wowhead.com/item=" .. tostring(itemID)
end

local WINDWARD_TURTLE_ROUTE = {
    id = "mists-cooking-jade-forest-windward-turtle-ripper-loop",
    source = "Retail Wowhead Raw Turtle Meat, Mist-Touched Leather, and Prismatic Scale comments",
    sourceUrls = {
        "https://www.wowhead.com/item=74837/raw-turtle-meat",
        "https://www.wowhead.com/item=72120/mist-touched-leather",
        "https://www.wowhead.com/item=79101/prismatic-scale",
    },
    mapName = "The Jade Forest",
    location = "Windward Isle Saltback turtle and Slitherscale packs",
    routeType = "open-world-beast-loop",
    density = "High",
    dropDifficulty = "Strong compact farm for turtle meat, skins, and scale side value; the island can be mob-heavy.",
    tips = {
        "Use the 64,33 to 69,25 turtle loop reported on Wowhead, then fold in nearby Slitherscale packs if safe.",
        "Skinning adds Mist-Touched Leather, Prismatic Scale, and rare Magnificent Hide value.",
        "Battle Horn or similar pull tools speed this up only if your character can handle large packs.",
    },
    coords = {
        C(0.640, 0.330, "Southwest Windward turtle start"),
        C(0.650, 0.270, "West turtle pack"),
        C(0.660, 0.260, "Northwest turtle pack"),
        C(0.670, 0.250, "North turtle pack"),
        C(0.680, 0.250, "North Slitherscale path"),
        C(0.690, 0.250, "Northeast turtle pack"),
        C(0.680, 0.270, "East turtle return"),
        C(0.680, 0.280, "Central turtle return"),
        C(0.680, 0.320, "South Slitherscale return"),
    },
    confidence = "high",
}

local VALLEY_RIVER_TURTLE_ROUTE = {
    id = "mists-cooking-valley-yan-zhe-river-turtle-loop",
    source = "Retail Wowhead Raw Turtle Meat and Mist-Touched Leather comments",
    sourceUrls = {
        "https://www.wowhead.com/item=74837/raw-turtle-meat",
        "https://www.wowhead.com/item=72120/mist-touched-leather",
    },
    mapName = "Valley of the Four Winds",
    location = "Yan-Zhe River island and banks east of Silken Fields",
    routeType = "open-world-beast-loop",
    density = "High",
    dropDifficulty = "Fast turtle respawns close to Halfhill; good lower-pressure alternative to Windward Isle.",
    tips = {
        "Start around the Galleon river island, sweep east toward the small waterfall, then return on the opposite bank.",
        "Kill Riverbank Barbshells and nearby river beasts while moving; this spot also produces Motes of Harmony.",
        "Fish Emperor Salmon or Krasarang Paddlefish pools nearby when turtle spawns thin out.",
    },
    coords = {
        C(0.7133, 0.5353, "Yan-Zhe River island"),
        C(0.730, 0.550, "Galleon-side east bank"),
        C(0.750, 0.548, "Small island turtle check"),
        C(0.772, 0.540, "Small waterfall approach"),
        C(0.742, 0.512, "North bank return"),
        C(0.710, 0.512, "West bank return"),
    },
    confidence = "high",
}

local VALLEY_SKYRANGE_MEAT_ROUTE = {
    id = "mists-cooking-valley-skyrange-shaghorn-mushan",
    source = "Retail Wowhead Mushan Ribs, Raw Tiger Steak, Mote of Harmony, and Mist-Touched Leather comments",
    sourceUrls = {
        "https://www.wowhead.com/item=74834/mushan-ribs",
        "https://www.wowhead.com/item=74833/raw-tiger-steak",
        "https://www.wowhead.com/item=89112/mote-of-harmony",
        "https://www.wowhead.com/item=72120/mist-touched-leather",
    },
    mapName = "Valley of the Four Winds",
    location = "Skyrange and Nesingwary-side beast packs",
    routeType = "open-world-beast-loop",
    density = "Medium to high",
    dropDifficulty = "Best when you can fly up to Skyrange and AoE neutral packs safely.",
    tips = {
        "Use Skyrange Stout Shaghorn packs for leather and Motes of Harmony side value.",
        "Dip toward Nesingwary's Safari when targeting Mushan Ribs or Raw Tiger Steak together.",
        "This is weaker for pure tiger meat than Timeless Isle, but it stays near other Halfhill material farms.",
    },
    coords = {
        C(0.240, 0.382, "Skyrange west pack"),
        C(0.274, 0.338, "Skyrange northwest pack"),
        C(0.312, 0.366, "Skyrange central pack"),
        C(0.292, 0.424, "Skyrange south pack"),
        C(0.176, 0.598, "Nesingwary west beasts"),
        C(0.214, 0.620, "Nesingwary tiger and mushan check"),
        C(0.256, 0.636, "Nesingwary return"),
    },
    confidence = "medium",
}

local TOWNLONG_MUSHAN_ROUTE = {
    id = "mists-cooking-townlong-underbough-longshadow-mushan",
    source = "Retail Wowhead Mushan Ribs and Mist-Touched Leather comments plus wow-professions leather guide",
    sourceUrls = {
        "https://www.wowhead.com/item=74834/mushan-ribs",
        "https://www.wowhead.com/item=72120/mist-touched-leather",
        "https://www.wow-professions.com/farming/mist-touched-leather-farming",
    },
    mapName = "Townlong Steppes",
    location = "The Underbough and Kri'vess Longshadow Mushan packs",
    routeType = "open-world-beast-loop",
    density = "High",
    dropDifficulty = "Dense mushan packs with strong skinning overlap; knockbacks can slow melee characters.",
    tips = {
        "Circle the middle Kri'vess tree and pull large Longshadow Mushan and Bull packs.",
        "Skin everything if you can; reports pair this route with leather, scales, hides, ribs, and motes.",
        "Use the nearby turtles as filler when the largest mushan packs are down.",
    },
    coords = {
        C(0.470, 0.548, "West Kri'vess mushan"),
        C(0.512, 0.518, "North Kri'vess mushan"),
        C(0.552, 0.552, "East Kri'vess mushan"),
        C(0.526, 0.606, "South Kri'vess mushan"),
        C(0.474, 0.622, "Garrison-side return"),
    },
    confidence = "high",
}

local DREAD_BRINY_CRAB_ROUTE = {
    id = "mists-cooking-dread-wastes-briny-muck-muck-sifter",
    source = "Retail Wowhead Raw Crab Meat comments",
    sourceUrls = {
        "https://www.wowhead.com/item=74838/raw-crab-meat",
        "https://www.wowhead.com/npc=63010/muck-sifter",
    },
    mapName = "Dread Wastes",
    location = "The Briny Muck crab island and nearby water",
    routeType = "open-world-beast-loop",
    density = "High localized",
    dropDifficulty = "Compact crab route with fast respawns; later reports still use the 38-39,61-63 island.",
    tips = {
        "Loop the island and nearby water instead of widening into sparse shore sections.",
        "Kill turtles only as side value when crab spawns are momentarily down.",
        "Skinning can add leather value but the main reason to stay here is the crab respawn timing.",
    },
    coords = {
        C(0.380, 0.620, "Muck Sifter island"),
        C(0.386, 0.634, "South island crab pack"),
        C(0.390, 0.610, "North island crab pack"),
        C(0.370, 0.540, "Bonfire island extension"),
        C(0.399, 0.537, "East water crab check"),
    },
    confidence = "high",
}

local DREAD_LAKE_CROC_ROUTE = {
    id = "mists-cooking-dread-wastes-lake-stars-crocolisk-loop",
    source = "Retail Wowhead Raw Crocolisk Belly comments",
    sourceUrls = {
        "https://www.wowhead.com/item=75014/raw-crocolisk-belly",
        "https://www.wowhead.com/npc=65357/coldbite-crocolisk",
    },
    mapName = "Dread Wastes",
    location = "Lake of Stars north and east shoreline Coldbite Crocolisks",
    routeType = "open-world-beast-loop",
    density = "Medium to high",
    dropDifficulty = "High drop chance but some targets are underwater; Klaxxi buffs and water-walking help.",
    tips = {
        "Favor the north and east shoreline; several comments warn the southwest lake edge is worse.",
        "Use the Lake of Stars loop when you want crocolisk belly and turtle meat together.",
        "Mark of Korven, water breathing, or a fishing raft reduce underwater travel friction.",
    },
    coords = {
        C(0.630, 0.580, "Lake of Stars retail comment pin"),
        C(0.650, 0.590, "East lake crocolisks"),
        C(0.664, 0.608, "Northeast shore"),
        C(0.610, 0.548, "North shore return"),
        C(0.574, 0.690, "South lake turtle side check"),
    },
    confidence = "high",
}

local VALLEY_CRANE_ROUTE = {
    id = "mists-cooking-valley-singing-marshes-whitefisher-cranes",
    source = "Retail Wowhead Wildfowl Breast comments",
    sourceUrls = {
        "https://www.wowhead.com/item=74839/wildfowl-breast",
        "https://www.wowhead.com/npc=56707/whitefisher-crane",
    },
    mapName = "Valley of the Four Winds",
    location = "Singing Marshes west of Halfhill and east of the Gilded Fan",
    routeType = "open-world-beast-loop",
    density = "High localized",
    dropDifficulty = "Easy bird farm with quick respawns and low incoming damage.",
    tips = {
        "Use the 26.3,41.5 marsh pin as the center and circle the ground cranes.",
        "This is an accessible farm for Halfhill cooking dailies because it is close to the market.",
        "Skip high-flying plainshawks unless you have strong ranged tagging.",
    },
    coords = {
        C(0.263, 0.415, "Singing Marshes crane center"),
        C(0.246, 0.394, "West marsh cranes"),
        C(0.286, 0.402, "East marsh cranes"),
        C(0.300, 0.430, "Gilded Fan edge"),
        C(0.270, 0.446, "South marsh return"),
    },
    confidence = "high",
}

local function RegisterCooking(itemID, itemName, spots, summary)
    Register({
        itemID = itemID,
        itemName = itemName,
        expansion = "mists",
        professions = { "cooking" },
        category = "Meat",
        sourceUrls = { ItemUrl(itemID), "https://www.wowhead.com/news/mists-of-pandaria-cooking-overview-204275" },
        summary = summary,
        spots = spots,
    })
end

RegisterCooking(74833, "Raw Tiger Steak", { VALLEY_SKYRANGE_MEAT_ROUTE }, "Tiger and cat meat from Pandaria cats; Skyrange/Nesingwary checks keep it near other Valley farms.")
RegisterCooking(74834, "Mushan Ribs", { TOWNLONG_MUSHAN_ROUTE, VALLEY_SKYRANGE_MEAT_ROUTE }, "Mushan meat from dense Longshadow and Valley beast packs.")
RegisterCooking(74837, "Raw Turtle Meat", { WINDWARD_TURTLE_ROUTE, VALLEY_RIVER_TURTLE_ROUTE }, "Turtle meat with strong skinning overlap from Windward Isle and Valley river turtle loops.")
RegisterCooking(74838, "Raw Crab Meat", { DREAD_BRINY_CRAB_ROUTE }, "Crab meat from fast-respawning Muck Sifters in the Briny Muck.")
RegisterCooking(74839, "Wildfowl Breast", { VALLEY_CRANE_ROUTE }, "Bird meat from Whitefisher Crane and nearby Valley bird loops.")
RegisterCooking(75014, "Raw Crocolisk Belly", { DREAD_LAKE_CROC_ROUTE }, "Crocolisk meat best farmed around Lake of Stars, with Kea Krak as a lower-level backup.")
