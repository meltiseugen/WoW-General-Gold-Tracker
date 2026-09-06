local _, NS = ...
local Register = NS.RegisterMaterialFarmingSpot

local function C(x, y, label, mapID)
    return { x = x, y = y, label = label, mapID = mapID }
end

local function ItemUrl(itemID)
    return "https://www.wowhead.com/item=" .. tostring(itemID)
end

local function ObjectUrl(objectID)
    return "https://www.wowhead.com/object=" .. tostring(objectID)
end

local HYJAL_MOUNTAIN_TROUT = {
    id = "cataclysm-mountain-trout-mount-hyjal-schools",
    source = "Retail Wowhead Mountain Trout School object pins and Cataclysm cooking achievement guide",
    sourceUrls = {
        ObjectUrl(202776),
        "https://www.wowhead.com/guide/achievements/professions/cooking-achievements-guide",
    },
    mapName = "Mount Hyjal",
    location = "Nordrassil and southern Hyjal lake school loop",
    routeType = "fishing-school-loop",
    density = "Medium",
    dropDifficulty = "Straightforward school fishing; open-water casts can fill gaps between pools.",
    tips = {
        "Use the northern lake pins first, then sweep the southern lake if pools are thin.",
        "Mountain Trout is also a practical open-water catch in Mount Hyjal.",
    },
    coords = {
        C(0.287, 0.339, "Northwest Hyjal school", 198),
        C(0.391, 0.297, "Nordrassil west school", 198),
        C(0.397, 0.326, "Nordrassil south school", 198),
        C(0.452, 0.234, "North-central school", 198),
        C(0.488, 0.256, "Central northern school", 198),
        C(0.516, 0.231, "Eastern northern school", 198),
        C(0.594, 0.250, "Shrine approach school", 198),
        C(0.700, 0.720, "Southern lake north", 198),
        C(0.718, 0.790, "Southern lake east", 198),
        C(0.748, 0.765, "Southern lake return", 198),
    },
    confidence = "high",
}

local TWILIGHT_GUPPY = {
    id = "cataclysm-highland-guppy-twilight-highlands-schools",
    source = "Retail Wowhead Highland Guppy School object pins and Cataclysm cooking achievement guide",
    sourceUrls = {
        ObjectUrl(202777),
        "https://www.wowhead.com/guide/achievements/professions/cooking-achievements-guide",
    },
    mapName = "Twilight Highlands",
    location = "Loch Verrall and inland Twilight Highlands school loop",
    routeType = "fishing-school-loop",
    density = "Medium",
    dropDifficulty = "School fishing is reliable, with nearby open water supporting Striped Lurker and Sharptooth.",
    tips = {
        "Loop the western river and lake pins before crossing to the central pools.",
        "Use this same waterline when Striped Lurker is valuable.",
    },
    coords = {
        C(0.269, 0.621, "Western river school", 241),
        C(0.284, 0.660, "Southwest river school", 241),
        C(0.301, 0.601, "Western lake school", 241),
        C(0.318, 0.654, "Southwest lake school", 241),
        C(0.354, 0.590, "Loch Verrall west", 241),
        C(0.396, 0.566, "Loch Verrall center", 241),
        C(0.423, 0.545, "Loch Verrall east", 241),
        C(0.496, 0.423, "Central pool", 241),
        C(0.523, 0.396, "Central northern pool", 241),
        C(0.629, 0.413, "Eastern pool", 241),
    },
    confidence = "high",
}

local DEEPHOLM_CAVEFISH = {
    id = "cataclysm-albino-cavefish-deepholm-schools",
    source = "Retail Wowhead Albino Cavefish School object pins and Cataclysm cooking achievement guide",
    sourceUrls = {
        ObjectUrl(202778),
        "https://www.wowhead.com/guide/achievements/professions/cooking-achievements-guide",
    },
    mapName = "Deepholm",
    location = "Western and eastern Deepholm cavefish pools",
    routeType = "fishing-school-loop",
    density = "Medium",
    dropDifficulty = "Focused Deepholm-only school route; nearby open water can also produce Lavascale Catfish.",
    tips = {
        "Check the western pools first, then rotate through the eastern pool chain.",
        "Use the same Deepholm water route when Lavascale Catfish is the price target.",
    },
    coords = {
        C(0.265, 0.384, "Western cavefish pool", 207),
        C(0.269, 0.361, "Western northern pool", 207),
        C(0.291, 0.349, "Western central pool", 207),
        C(0.682, 0.687, "Eastern south pool", 207),
        C(0.703, 0.400, "Eastern north pool", 207),
        C(0.708, 0.601, "Eastern mid pool", 207),
        C(0.722, 0.423, "Eastern upper pool", 207),
        C(0.746, 0.605, "Eastern lower pool", 207),
        C(0.766, 0.386, "Eastern return pool", 207),
        C(0.783, 0.477, "Far eastern pool", 207),
    },
    confidence = "high",
}

local ULDUM_MUDFISH = {
    id = "cataclysm-blackbelly-mudfish-uldum-river-schools",
    source = "Retail Wowhead Blackbelly Mudfish School object pins and Cataclysm cooking achievement guide",
    sourceUrls = {
        ObjectUrl(202779),
        "https://www.wowhead.com/guide/achievements/professions/cooking-achievements-guide",
    },
    mapName = "Uldum",
    location = "Uldum Vir'naal River and Lost City school loop",
    routeType = "fishing-school-loop",
    density = "High",
    dropDifficulty = "Dense school chain, but Uldum phasing may require Zidormi.",
    tips = {
        "Follow the river pins through Ramkahen and the Lost City bend.",
        "Talk to Zidormi at Ramkahen if you are in the newer Uldum phase.",
    },
    coords = {
        C(0.286, 0.110, "Ramkahen north school", 249),
        C(0.304, 0.211, "Ramkahen river school", 249),
        C(0.384, 0.266, "River bend west", 249),
        C(0.427, 0.266, "River bend east", 249),
        C(0.498, 0.332, "Central river school", 249),
        C(0.514, 0.411, "Vir'naal south school", 249),
        C(0.572, 0.436, "Lost City north school", 249),
        C(0.579, 0.526, "Lost City east school", 249),
        C(0.593, 0.600, "Lost City south school", 249),
        C(0.641, 0.780, "Southern delta school", 249),
        C(0.696, 0.753, "Delta return school", 249),
    },
    confidence = "high",
}

local TWILIGHT_SAGEFISH = {
    id = "cataclysm-deepsea-sagefish-twilight-highlands-coast",
    source = "Retail Wowhead Deepsea Sagefish School object pins and Cataclysm cooking achievement guide",
    sourceUrls = {
        ObjectUrl(208311),
        "https://www.wowhead.com/guide/achievements/professions/cooking-achievements-guide",
    },
    mapName = "Twilight Highlands",
    location = "Eastern Twilight Highlands coast and river-mouth school loop",
    routeType = "fishing-school-loop",
    density = "Medium to high",
    dropDifficulty = "Coastal schools are spread out; flying between visible pools helps.",
    tips = {
        "Work the eastern coastline, then dip into river-mouth schools when they are up.",
        "Use this route for Deepsea Sagefish with Algaefin Rockfish as a side catch.",
    },
    coords = {
        C(0.563, 0.899, "Southwest coastal school", 241),
        C(0.664, 0.866, "Southern coast school", 241),
        C(0.690, 0.834, "Dragonmaw coast south", 241),
        C(0.713, 0.357, "Northern coast school", 241),
        C(0.720, 0.617, "Mid coast school", 241),
        C(0.722, 0.805, "Southern coast return", 241),
        C(0.731, 0.757, "Highbank coast", 241),
        C(0.755, 0.471, "Northeast coast", 241),
        C(0.775, 0.768, "Southeast coast", 241),
        C(0.808, 0.792, "Far southeast coast", 241),
    },
    confidence = "high",
}

local TOL_BARAD_EEL = {
    id = "cataclysm-fathom-eel-tol-barad-peninsula-swarms",
    source = "Retail Wowhead Fathom Eel Swarm object pins and Cataclysm cooking achievement guide",
    sourceUrls = {
        ObjectUrl(202780),
        "https://www.wowhead.com/guide/achievements/professions/cooking-achievements-guide",
    },
    mapName = "Tol Barad Peninsula",
    location = "Tol Barad Peninsula coastal Fathom Eel swarm loop",
    routeType = "fishing-school-loop",
    density = "Medium",
    dropDifficulty = "Good focused Fathom Eel route; pools are coastal and spread across the peninsula.",
    tips = {
        "Circle the peninsula coast and fish each visible Fathom Eel Swarm.",
        "Use this route when Uldum coastal pools are crowded or phased awkwardly.",
    },
    coords = {
        C(0.215, 0.473, "West coast swarm", 245),
        C(0.224, 0.380, "Northwest coast swarm", 245),
        C(0.279, 0.533, "Western bay swarm", 245),
        C(0.388, 0.093, "Northern coast swarm", 245),
        C(0.413, 0.203, "North inlet swarm", 245),
        C(0.480, 0.592, "Southwest inlet swarm", 245),
        C(0.533, 0.355, "Central coast swarm", 245),
        C(0.602, 0.413, "East central swarm", 245),
        C(0.687, 0.495, "Eastern coast swarm", 245),
        C(0.756, 0.625, "Southeast coast swarm", 245),
    },
    confidence = "high",
}

local ULDUM_OPEN_WATER = {
    id = "cataclysm-uldum-open-water-mixed-cooking-fish",
    source = "Retail Wowhead fished-in tables and Cataclysm cooking achievement guide",
    sourceUrls = {
        ItemUrl(53062),
        ItemUrl(53068),
        ItemUrl(53070),
        ItemUrl(53072),
        "https://www.wowhead.com/guide/achievements/professions/cooking-achievements-guide",
    },
    mapName = "Uldum",
    location = "Vir'naal River, Lost City waterline, and southern Uldum delta",
    routeType = "open-water-fishing-loop",
    density = "Medium",
    dropDifficulty = "Broad open-water catch route; use schools when a specific fish has a pool nearby.",
    tips = {
        "Use this for mixed Sharptooth, Lavascale Catfish, Fathom Eel, Murglesnout, and Deepsea Sagefish catches.",
        "Talk to Zidormi at Ramkahen if your map is in the Battle for Azeroth phase.",
    },
    coords = {
        C(0.540, 0.360, "Northern Vir'naal water", 249),
        C(0.590, 0.440, "Lost City north water", 249),
        C(0.606, 0.548, "Lost City east water", 249),
        C(0.568, 0.642, "Southern river water", 249),
        C(0.492, 0.704, "Southwest river water", 249),
        C(0.420, 0.612, "Western river water", 249),
        C(0.388, 0.474, "Northwest return water", 249),
    },
    confidence = "high",
}

local function RegisterFish(itemID, itemName, spots, summary)
    Register({
        itemID = itemID,
        itemName = itemName,
        expansion = "cataclysm",
        professions = { "fishing", "cooking" },
        category = "Fish",
        sourceUrls = {
            ItemUrl(itemID),
            "https://www.wowhead.com/guide/achievements/professions/cooking-achievements-guide",
        },
        summary = summary,
        spots = spots,
    })
end

RegisterFish(53062, "Sharptooth", { ULDUM_OPEN_WATER, TWILIGHT_GUPPY, DEEPHOLM_CAVEFISH }, "Common Cataclysm open-water cooking fish from Uldum, Deepholm, Mount Hyjal, and Twilight Highlands.")
RegisterFish(53063, "Mountain Trout", { HYJAL_MOUNTAIN_TROUT }, "Mount Hyjal and Azshara inland fish; Hyjal school pins give the most map-ready Cataclysm route.")
RegisterFish(53064, "Highland Guppy", { TWILIGHT_GUPPY }, "Twilight Highlands inland fish with a dedicated Highland Guppy School route.")
RegisterFish(53065, "Albino Cavefish", { DEEPHOLM_CAVEFISH }, "Deepholm cavefish with a dedicated Albino Cavefish School route.")
RegisterFish(53066, "Blackbelly Mudfish", { ULDUM_MUDFISH, ULDUM_OPEN_WATER }, "Uldum cooking fish with dense river-school support around Ramkahen and the Lost City.")
RegisterFish(53067, "Striped Lurker", { TWILIGHT_GUPPY, HYJAL_MOUNTAIN_TROUT }, "Inland open-water Cataclysm fish from Twilight Highlands and Mount Hyjal water routes.")
RegisterFish(53068, "Lavascale Catfish", { ULDUM_OPEN_WATER, DEEPHOLM_CAVEFISH }, "Cataclysm lava/open-water fish from Uldum and Deepholm.")
RegisterFish(53069, "Murglesnout", { ULDUM_OPEN_WATER, TOL_BARAD_EEL }, "Common Cataclysm open-water side catch across Uldum, Twilight Highlands, Tol Barad, and Vashj'ir.")
RegisterFish(53070, "Fathom Eel", { TOL_BARAD_EEL, ULDUM_OPEN_WATER }, "Cataclysm coastal fish best targeted through Fathom Eel Swarms in Tol Barad Peninsula or Uldum.")
RegisterFish(53071, "Algaefin Rockfish", { TWILIGHT_SAGEFISH, TOL_BARAD_EEL }, "Coastal Cataclysm fish from Twilight Highlands, Tol Barad Peninsula, and Vashj'ir open water.")
RegisterFish(53072, "Deepsea Sagefish", { TWILIGHT_SAGEFISH, ULDUM_OPEN_WATER }, "Cataclysm coastal/open-water fish with dedicated Deepsea Sagefish School pins in Twilight Highlands.")
