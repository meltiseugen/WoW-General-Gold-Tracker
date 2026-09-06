local _, NS = ...
local Register = NS.RegisterMaterialFarmingSpot

local function C(x, y, label)
    return { x = x, y = y, label = label }
end

local function ItemUrl(itemID)
    return "https://www.wowhead.com/item=" .. tostring(itemID)
end

local ROUTE_STRING_SOURCE = "https://xscarlife-gaming.com/farming-retail/"

local COBALT_ROUTE = {
    {
        id = "wrath-cobalt-howling-fjord-outer-cliff-loop",
        source = "wow-professions Cobalt guide, Wowhead Cobalt Deposit comments, and Wowhead mining overview",
        sourceUrls = {
            "https://www.wow-professions.com/farming/cobalt-ore-farming",
            "https://www.wowhead.com/object=189978/cobalt-deposit",
            "https://www.wowhead.com/guide/professions/mining/overview-leveling-routes",
            ROUTE_STRING_SOURCE,
        },
        mapName = "Howling Fjord",
        location = "Outer Howling Fjord cliff and mountain loop",
        routeType = "mining-loop",
        density = "High",
        dropDifficulty = "Easy starter Northrend ore route, but often contested on busy realms.",
        tips = {
            "Follow the outer cliffs, cave mouths, and mountain edges instead of crossing the open center.",
            "Use Borean Tundra, Grizzly Hills, or Zul'Drak as backup zones if Howling Fjord is crowded.",
            "Prospect only when the expected gem value beats the raw ore value.",
        },
        coords = {
            C(0.2265, 0.1390, "Northwest cliff line"),
            C(0.3174, 0.1595, "West coast ridge"),
            C(0.4069, 0.1377, "Northern ridge"),
            C(0.5208, 0.1009, "North ridge cave check"),
            C(0.5586, 0.1475, "Utgarde ridge"),
            C(0.5697, 0.2097, "North central mountain edge"),
            C(0.6377, 0.2229, "Northeast cliff loop"),
            C(0.6727, 0.1023, "Northeast wall"),
            C(0.7222, 0.2639, "Eastern mountain pass"),
            C(0.6968, 0.3328, "Skorn ridge"),
            C(0.7201, 0.4015, "Eastern return ridge"),
            C(0.7328, 0.5441, "Southeast cliff loop"),
            C(0.7705, 0.6543, "South east coast ridge"),
            C(0.6812, 0.7481, "Southern coast rocks"),
            C(0.6469, 0.7117, "Southeast return"),
            C(0.5238, 0.3556, "Central ridge crossing"),
            C(0.3714, 0.3049, "Western mountain return"),
            C(0.2709, 0.3146, "West cliff return"),
            C(0.2062, 0.2418, "Northwest return ridge"),
        },
        confidence = "high",
    },
}

local SARONITE_TITANIUM_ROUTES = {
    {
        id = "wrath-saronite-titanium-wintergrasp-figure-eight",
        source = "wow-professions Saronite guide, Wowhead Saronite/Titanium route guide, and Wowhead Titanium comments",
        sourceUrls = {
            "https://www.wow-professions.com/farming/saronite-ore-farming",
            "https://www.wowhead.com/guide/ore-deposit-best-farming-routes",
            "https://www.wowhead.com/object=191133/titanium-vein",
            ROUTE_STRING_SOURCE,
        },
        mapName = "Wintergrasp",
        location = "Wintergrasp high-density Saronite and Titanium replacement route",
        routeType = "mining-loop",
        density = "High when accessible",
        dropDifficulty = "Very good node density, but the active battle and faction control can interrupt the route.",
        tips = {
            "Skip the route while the Wintergrasp battle is active.",
            "Mine every Saronite node when targeting Titanium because Titanium is a rare replacement node.",
            "Expect competition when your faction controls the zone.",
        },
        coords = {
            C(0.3585, 0.1733, "Northwest wall"),
            C(0.4060, 0.2748, "Northern central ridge"),
            C(0.4905, 0.3386, "North inner wall"),
            C(0.5736, 0.3223, "Northeast ridge"),
            C(0.5968, 0.2106, "North return"),
            C(0.7067, 0.2998, "Eastern wall upper"),
            C(0.8378, 0.4357, "Far east wall"),
            C(0.7896, 0.4808, "East return"),
            C(0.7370, 0.4727, "Eastern basin"),
            C(0.7383, 0.5894, "Southeast ridge"),
            C(0.8147, 0.6100, "East fortress ridge"),
            C(0.8522, 0.6757, "Southeast edge"),
            C(0.8119, 0.7663, "Southern wall"),
            C(0.7769, 0.8111, "South return wall"),
            C(0.6779, 0.6587, "Lower central basin"),
            C(0.5808, 0.8096, "Southern basin"),
            C(0.5705, 0.6397, "Central south"),
            C(0.5194, 0.4807, "Central route crossing"),
            C(0.4645, 0.4871, "West central ridge"),
            C(0.4355, 0.6098, "West basin"),
            C(0.3127, 0.5794, "Western return"),
            C(0.1936, 0.6273, "Southwest wall"),
            C(0.1502, 0.6303, "Far southwest wall"),
            C(0.1260, 0.5650, "West return edge"),
            C(0.2132, 0.4002, "Northwest basin return"),
            C(0.2517, 0.4700, "West inner wall"),
            C(0.3373, 0.5176, "Western central loop"),
        },
        confidence = "high",
    },
    {
        id = "wrath-saronite-titanium-sholazar-basin-rim",
        source = "wow-professions Saronite guide and Wowhead Saronite/Titanium route guide",
        sourceUrls = {
            "https://www.wow-professions.com/farming/saronite-ore-farming",
            "https://www.wowhead.com/guide/ore-deposit-best-farming-routes",
        },
        mapName = "Sholazar Basin",
        location = "Sholazar Basin outer rim and pillar loop",
        routeType = "mining-loop",
        density = "High",
        dropDifficulty = "Excellent lower-friction alternative to Wintergrasp with easier terrain.",
        tips = {
            "Use this route when Wintergrasp is contested or the battle is active.",
            "Stay near the zone rim and pillars where deposits cluster.",
            "Good dual-gather route if herbs are also valuable.",
        },
        coords = {
            C(0.222, 0.604, "Western rim"),
            C(0.286, 0.402, "Northwest pillar edge"),
            C(0.428, 0.286, "Northern rim"),
            C(0.604, 0.372, "Northeast rim"),
            C(0.702, 0.548, "Eastern rim"),
            C(0.534, 0.746, "Southern return"),
        },
        confidence = "high",
    },
}

Register({
    itemID = 37701,
    itemName = "Crystallized Earth",
    expansion = "wrath",
    professions = { "mining", "alchemy", "engineering" },
    category = "Elemental",
    sourceUrls = {
        "https://www.wow-professions.com/farming/crystallized-earth-farming",
        "https://www.wowhead.com/npc=29124/lifeblood-elemental",
        ItemUrl(37701),
    },
    summary = "Crystallized Earth is best targeted from Lifeblood Elementals in Sholazar Basin, with Saronite mining as a useful side source.",
    spots = {
        {
            id = "crystallized-earth-sholazar-lifeblood-elementals",
            source = "wow-professions Crystallized Earth guide and Wowhead Lifeblood Elemental comments",
            sourceUrls = {
                "https://www.wow-professions.com/farming/crystallized-earth-farming",
                "https://www.wowhead.com/npc=29124/lifeblood-elemental",
            },
            mapName = "Sholazar Basin",
            location = "Lifeblood Elementals around the Glimmering Pillar wetlands",
            routeType = "open-world-loop",
            density = "High",
            dropDifficulty = "Good targeted farm with fast respawns, but competition can flatten the loop.",
            tips = {
                "Keep the route tight around the Lifeblood Elemental cluster instead of doing a full-zone circuit.",
                "Use Saronite mining as secondary value only if ore prices justify leaving the elemental loop.",
            },
            coords = {
                C(0.710, 0.550, "Lifeblood Elemental cluster"),
                C(0.730, 0.550, "Eastern Lifeblood spawn"),
                C(0.740, 0.560, "Southeast Lifeblood spawn"),
                C(0.706, 0.526, "Northern wetland spawn"),
                C(0.762, 0.586, "Outer wetland spawn"),
            },
            confidence = "high",
        },
        SARONITE_TITANIUM_ROUTES[2],
    },
})

Register({
    itemID = 36909,
    itemName = "Cobalt Ore",
    expansion = "wrath",
    professions = { "mining" },
    category = "Ore",
    sourceUrls = { ItemUrl(36909), "https://www.wow-professions.com/farming/cobalt-ore-farming" },
    summary = "Starter Northrend ore from Howling Fjord, Borean Tundra, Grizzly Hills, and Zul'Drak mining loops.",
    spots = COBALT_ROUTE,
})

Register({
    itemID = 36912,
    itemName = "Saronite Ore",
    expansion = "wrath",
    professions = { "mining" },
    category = "Ore",
    sourceUrls = { ItemUrl(36912), "https://www.wow-professions.com/farming/saronite-ore-farming" },
    summary = "Primary high-level Northrend ore from Wintergrasp, Sholazar Basin, Icecrown, and The Storm Peaks routes.",
    spots = SARONITE_TITANIUM_ROUTES,
})

Register({
    itemID = 36910,
    itemName = "Titanium Ore",
    expansion = "wrath",
    professions = { "mining" },
    category = "Ore",
    sourceUrls = { ItemUrl(36910), "https://www.wowhead.com/object=191133/titanium-vein" },
    summary = "Rare high-level Northrend ore that appears as a replacement for Saronite-family nodes.",
    spots = SARONITE_TITANIUM_ROUTES,
})
