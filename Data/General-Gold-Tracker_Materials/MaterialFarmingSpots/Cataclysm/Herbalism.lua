local _, NS = ...
local Register = NS.RegisterMaterialFarmingSpot

local function C(x, y, label)
    return { x = x, y = y, label = label }
end

local function ItemUrl(itemID)
    return "https://www.wowhead.com/item=" .. tostring(itemID)
end

local HYJAL_CINDERBLOOM_ROUTE = {
    id = "cataclysm-cinderbloom-mount-hyjal-shrine-loop",
    source = "wow-professions Cinderbloom guide, Wowhead Cinderbloom guide, and Cataclysm herbalism route notes",
    sourceUrls = {
        "https://www.wow-professions.com/farming/cinderbloom-farming",
        "https://www.wowhead.com/object=202747/cinderbloom",
        "https://goddessmomo.wordpress.com/2011/07/30/cataclysm-herbalism-farming-routes/",
    },
    mapName = "Mount Hyjal",
    location = "Mount Hyjal shrine and rim herb circuit",
    routeType = "herbalism-loop",
    density = "High",
    dropDifficulty = "Easy starter Cataclysm herb route with occasional Stormvine.",
    tips = {
        "Loop Circle of Cinders, Shrine of Aviana, Grove of Aessina, and Shrine of Goldrinn.",
        "Pick every herb to keep node turnover high.",
        "Use Deepholm when you also want Heartblossom and Volatile Life side value.",
    },
    coords = {
        C(0.099, 0.382, "West Hyjal Cinderbloom pin"),
        C(0.126, 0.404, "Western shrine Cinderbloom pin"),
        C(0.149, 0.403, "Shrine approach Cinderbloom pin"),
        C(0.168, 0.541, "Grove approach Cinderbloom pin"),
        C(0.350, 0.240, "Circle of Cinders"),
        C(0.480, 0.280, "Shrine of Aviana approach"),
        C(0.620, 0.220, "Northern shrine sweep"),
        C(0.720, 0.440, "Grove of Aessina side"),
        C(0.520, 0.720, "Southern return"),
        C(0.270, 0.540, "Shrine of Goldrinn side"),
    },
    confidence = "high",
}

local VASHJIR_HERB_ROUTE = {
    id = "cataclysm-stormvine-azsharas-veil-shimmering-expanse",
    source = "wow-professions Stormvine/Azshara's Veil guides and Wowhead Cataclysm herb guides",
    sourceUrls = {
        "https://www.wow-professions.com/farming/stormvine-farming",
        "https://www.wow-professions.com/farming/azsharas-veil-farming",
        "https://www.wowhead.com/object=202748/stormvine",
        "https://www.wowhead.com/object=202749/azsharas-veil",
    },
    mapName = "Shimmering Expanse",
    location = "Shimmering Expanse waterline herb route",
    routeType = "herbalism-loop",
    density = "High",
    dropDifficulty = "Strong Stormvine and Azshara's Veil route, but underwater pathing can feel slower.",
    tips = {
        "Use Shimmering Expanse first; swap to Abyssal Depths if another farmer is cycling the same path.",
        "Azshara's Veil favors watery areas, while Stormvine appears naturally on the same Vashj'ir routes.",
        "Keep the route compact rather than crossing all three Vashj'ir sub-zones.",
    },
    coords = {
        C(0.321, 0.531, "Northwest Azshara's Veil pin"),
        C(0.358, 0.641, "Northwest Stormvine pin"),
        C(0.374, 0.560, "Central Stormvine pin"),
        C(0.371, 0.669, "Southwest Azshara's Veil pin"),
        C(0.425, 0.278, "North Shimmering herb sweep"),
        C(0.518, 0.320, "Central Shimmering herb sweep"),
        C(0.610, 0.402, "Eastern Shimmering herb sweep"),
        C(0.568, 0.548, "Southeast Shimmering herb sweep"),
        C(0.438, 0.606, "Southwest Shimmering herb sweep"),
    },
    confidence = "high",
}

local DEEPHOLM_HEARTBLOSSOM_ROUTE = {
    id = "cataclysm-heartblossom-deepholm-outer-loop",
    source = "Wowhead Heartblossom guide, wow-professions herb guide, and Cataclysm herbalism route notes",
    sourceUrls = {
        "https://www.wowhead.com/object=202750/heartblossom",
        "https://www.wow-professions.com/farming/heartblossom-farming",
        "https://goddessmomo.wordpress.com/2011/07/30/cataclysm-herbalism-farming-routes/",
    },
    mapName = "Deepholm",
    location = "Needle Rock, Pale Roost, Temple of Earth, and Silvermarsh loop",
    routeType = "herbalism-loop",
    density = "High",
    dropDifficulty = "Good focused Heartblossom route with Volatile Life side value.",
    tips = {
        "Route through Needle Rock Chasm, Pale Roost, Temple of Earth, Deathwing's Fall, and Silvermarsh.",
        "Skip the dotted/low-herb stretch if another player is not forcing you into a wider loop.",
    },
    coords = {
        C(0.201, 0.548, "Western Heartblossom pin"),
        C(0.202, 0.570, "Western ridge Heartblossom pin"),
        C(0.216, 0.563, "Needle Rock west Heartblossom pin"),
        C(0.221, 0.485, "Temple west Heartblossom pin"),
        C(0.490, 0.190, "Needle Rock Chasm"),
        C(0.612, 0.276, "Pale Roost"),
        C(0.720, 0.430, "Eastern Deepholm sweep"),
        C(0.630, 0.610, "Deathwing's Fall side"),
        C(0.466, 0.674, "Silvermarsh return"),
        C(0.336, 0.520, "Western Deepholm return"),
        C(0.400, 0.334, "Temple of Earth side"),
    },
    confidence = "high",
}

local TWILIGHT_JASMINE_ROUTE = {
    id = "cataclysm-twilight-jasmine-twilight-highlands-green-loop",
    source = "wow-professions Twilight Jasmine guide, Cataclysm herb route notes, and Wowhead herb guides",
    sourceUrls = {
        "https://www.wow-professions.com/farming/twilight-jasmine-farming",
        "https://goddessmomo.wordpress.com/2011/07/30/cataclysm-herbalism-farming-routes/",
        "https://www.wowhead.com/object=202751/twilight-jasmine",
    },
    mapName = "Twilight Highlands",
    location = "Green Twilight Highlands valleys away from mountain ridges",
    routeType = "herbalism-loop",
    density = "Medium to high",
    dropDifficulty = "Slower than Whiptail and Heartblossom because useful nodes are spread through green areas.",
    tips = {
        "Stay in greener valleys and avoid long mountain-edge mining detours if Twilight Jasmine is the target.",
        "Cinderbloom and Volatile Life can appear as side value.",
    },
    coords = {
        C(0.172, 0.601, "Western Twilight Jasmine pin"),
        C(0.181, 0.577, "West ridge Twilight Jasmine pin"),
        C(0.200, 0.158, "Northwest Twilight Jasmine pin"),
        C(0.212, 0.166, "Northern Twilight Jasmine pin"),
        C(0.250, 0.260, "Northwest green valley"),
        C(0.376, 0.322, "Northern green valley"),
        C(0.496, 0.420, "Central green valley"),
        C(0.552, 0.558, "Eastern green valley"),
        C(0.434, 0.666, "Southern green valley"),
        C(0.280, 0.520, "Western return"),
    },
    confidence = "high",
}

local WHIPTAIL_ROUTE = {
    id = "cataclysm-whiptail-uldum-lost-city-river-loop",
    source = "wow-professions Whiptail/Volatile Life guides, Warcraft Tavern Volatile Life guide, and Cataclysm herbalism route notes",
    sourceUrls = {
        "https://www.wow-professions.com/farming/whiptail-farming",
        "https://www.wow-professions.com/farming/volatile-life-farming",
        "https://www.warcrafttavern.com/cataclysm/guides/volatile-life-farming-guide/",
        "https://goddessmomo.wordpress.com/2011/07/30/cataclysm-herbalism-farming-routes/",
    },
    mapName = "Uldum",
    location = "Lost City of the Tol'vir riverbanks and Uldum waterline loop",
    routeType = "herbalism-loop",
    density = "High",
    dropDifficulty = "Excellent Whiptail and Volatile Life route, but Uldum phasing may require Zidormi.",
    tips = {
        "Follow the riverbanks around the Lost City of the Tol'vir and nearby waterlines.",
        "Talk to Zidormi at Ramkahen if you are in the newer Uldum phase.",
        "This is the preferred Volatile Life route when Whiptail prices are also good.",
    },
    coords = {
        C(0.418, 0.724, "Southern river Whiptail pin"),
        C(0.425, 0.705, "Southwest river Whiptail pin"),
        C(0.450, 0.674, "Lost City river Whiptail pin"),
        C(0.459, 0.290, "Northern river Whiptail pin"),
        C(0.540, 0.360, "Northern riverbank"),
        C(0.590, 0.440, "Lost City north bank"),
        C(0.606, 0.548, "Lost City east bank"),
        C(0.568, 0.642, "Southern riverbank"),
        C(0.492, 0.704, "Southwest riverbank"),
        C(0.420, 0.612, "Western riverbank"),
        C(0.388, 0.474, "Northwest return"),
    },
    confidence = "high",
}

local function RegisterHerb(itemID, itemName, route, summary)
    Register({
        itemID = itemID,
        itemName = itemName,
        expansion = "cataclysm",
        professions = { "herbalism", "alchemy", "inscription" },
        category = "Herb",
        sourceUrls = { ItemUrl(itemID) },
        summary = summary,
        spots = { route },
    })
end

RegisterHerb(52983, "Cinderbloom", HYJAL_CINDERBLOOM_ROUTE, "Starter Cataclysm herb best farmed in Mount Hyjal, with Deepholm as a strong secondary route.")
RegisterHerb(52984, "Stormvine", VASHJIR_HERB_ROUTE, "Cataclysm herb farmed in Mount Hyjal and Vashj'ir, with Shimmering Expanse as the strongest mixed route.")
RegisterHerb(52985, "Azshara's Veil", VASHJIR_HERB_ROUTE, "Watery Cataclysm herb best farmed in Shimmering Expanse or Abyssal Depths.")
RegisterHerb(52986, "Heartblossom", DEEPHOLM_HEARTBLOSSOM_ROUTE, "Deepholm-only Cataclysm herb with Volatile Life side value.")
RegisterHerb(52987, "Twilight Jasmine", TWILIGHT_JASMINE_ROUTE, "Twilight Highlands herb found in green valley routes away from mountain edges.")
RegisterHerb(52988, "Whiptail", WHIPTAIL_ROUTE, "Uldum riverbank herb with excellent Volatile Life side value.")

Register({
    itemID = 52329,
    itemName = "Volatile Life",
    expansion = "cataclysm",
    professions = { "herbalism", "alchemy" },
    category = "Volatile",
    sourceUrls = {
        ItemUrl(52329),
        "https://www.wowhead.com/object=202752/whiptail",
        "https://www.wow-professions.com/farming/volatile-life-farming",
    },
    summary = "Volatile Life is a Cataclysm herbalism side material. Whiptail in Uldum is the most practical target route.",
    spots = { WHIPTAIL_ROUTE, DEEPHOLM_HEARTBLOSSOM_ROUTE },
})
