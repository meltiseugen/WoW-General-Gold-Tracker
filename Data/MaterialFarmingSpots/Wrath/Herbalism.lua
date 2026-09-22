local _, NS = ...
local Register = NS.RegisterMaterialFarmingSpot

local function C(x, y, label)
    return { x = x, y = y, label = label }
end

local function ItemUrl(itemID)
    return "https://www.wowhead.com/item=" .. tostring(itemID)
end

local function RouteCoords(label, packedCoords)
    local coords = {}
    for index, packed in ipairs(packedCoords) do
        local x = math.floor(packed / 10000)
        local y = packed % 10000
        coords[index] = C(x / 10000, y / 10000, string.format("%s pin %d", label, index))
    end
    return coords
end

local ROUTES_IMPORT_EXPORT = "https://www.curseforge.com/wow/addons/routes-import-export"
local XSCARLIFE_REPO = "https://github.com/Cion6982/retail-farm-routes"
local GOLDCLOVER_GUIDE = "https://www.wow-professions.com/farming/goldclover-farming"
local EPIC_GOLDCLOVER = "https://epicwowguides.com/material/goldclover-farming/"
local GOLDCLOVER_WOWHEAD = "https://www.wowhead.com/mop-classic/object=189973/goldclover"
local TIGER_LILY_GUIDE = "https://www.wow-professions.com/farming/tiger-lily-farming"
local EPIC_TIGER_LILY = "https://epicwowguides.com/material/tiger-lilly-farming/"
local EPIC_TALANDRAS_ROSE = "https://epicwowguides.com/material/talandras-rose-farming/"
local EPIC_ADDERS_TONGUE = "https://epicwowguides.com/material/adders-tongue-farming/"
local ADDERS_TONGUE_WOWHEAD = "https://www.wowhead.com/item=36903/adders-tongue"
local ICETHORN_WOWHEAD = "https://www.wowhead.com/object=190172/icethorn"
local EPIC_LICHBLOOM = "https://epicwowguides.com/material/lichbloom-farming/"
local EPIC_ICETHORN = "https://epicwowguides.com/material/icethorn-farming/"
local EPIC_FIRE_LEAF = "https://epicwowguides.com/material/fire-leaf-farming/"
local FIRE_LEAF_WOWHEAD = "https://www.wowhead.com/item=39970/fire-leaf"
local FROST_LOTUS_WOWHEAD = "https://www.wowhead.com/object=190176/frost-lotus"
local FROST_LOTUS_ARCHIVE = "https://www.geocities.ws/ipassoutcandy/wowherbWotLK.html"
local HERBS_BY_AREA = "https://warcraft.wiki.gg/wiki/Herbs_by_Area"

-- Coordinates are decoded from the supplied Retail Routes exports. Their order is significant.
local GOLDCLOVER_GRIZZLY_COORDS = RouteCoords("Goldclover Grizzly Hills main", {
    12363201, 22902801, 32263756, 44422859, 51322750, 55132734, 58792405,
    68921503, 68962713, 76393524, 76194378, 83855544, 64396048, 54855439,
    25845334, 18326356, 12577312, 12365512, 10954624,
})

local GOLDCLOVER_HOWLING_COORDS = RouteCoords("Goldclover Howling Fjord alternative", {
    58502578, 61892849, 65932704, 68272216, 70061932, 72321820, 74572243,
    73532666, 70413247, 70493895, 74204461, 76444254, 80554613, 79384974,
    75375092, 71455447, 75766058, 76886399, 76466786, 70856597, 69996972,
    69787497, 67277496, 64836755, 57176687, 48596276, 45834991, 40943992,
    36963994, 34703421, 39173324, 42062770, 48882103, 48071810, 50151654,
    55121967,
})

local GOLDCLOVER_BOREAN_COORDS = RouteCoords("Goldclover Borean Tundra alternative", {
    34216103, 36365510, 34725155, 41144501, 42674009, 47404495, 48514835,
    50375045, 53414721, 57944703, 61884687, 59125431, 62006081, 54256151,
    51706463, 50986992, 49827586, 46177334, 43047595, 39197319, 39646795,
    37166820, 33806576,
})

local TIGER_LILY_GRIZZLY_COORDS = RouteCoords("Tiger Lily Grizzly Hills main", {
    9243723, 19604031, 28773917, 32843788, 35133192, 39693097, 42173623,
    37174238, 31424630, 29275870, 27866376, 25197378, 23246981, 18036895,
    16387348, 12876656, 14255112,
})

local TIGER_LILY_HOWLING_COORDS = RouteCoords("Tiger Lily Howling Fjord alternative", {
    59823242, 64032591, 66821894, 68401925, 68482081, 67202237, 62133261,
    60555339, 59865629, 57135706, 53505800, 52655320, 52924489, 49364034,
    46604195, 42164001, 41842445, 26562759, 22522635, 32462566, 36862258,
    40382236, 39221994, 46291867, 45512188, 56093483,
})

local TALANDRAS_ROSE_LARGE_COORDS = RouteCoords("Talandra's Rose Zul'Drak main", {
    35306340, 34925973, 33314844, 34214686, 34404290, 37504200, 39704529,
    42104660, 43404680, 44405190, 42905703, 42976284, 40546516, 49206320,
    49506470, 56487073, 58337351, 57557540, 55967665, 54208080, 51568323,
    46808230, 45008200, 38608020, 31598719, 35907430, 36107170, 35206940,
})

local TALANDRAS_ROSE_COMPACT_COORDS = RouteCoords("Talandra's Rose Zul'Drak compact alternative", {
    29464046, 34124031, 36274460, 43073851, 47334967, 35206101, 40918579,
    25978312, 32125151, 29014699,
})

local ADDERS_TONGUE_LARGE_COORDS = RouteCoords("Adder's Tongue Sholazar large main", {
    26225119, 32004170, 34403279, 38502940, 40632589, 43902350, 56403140,
    62693393, 57584144, 57704720, 66307230, 65307540, 62008310, 59008050,
    43167787, 42508300, 40808780, 38478471, 33208381, 33208380, 28407940,
    29806680, 28406010, 22605910,
})

local ADDERS_TONGUE_COMPACT_COORDS = RouteCoords("Adder's Tongue Sholazar compact alternative", {
    28655144, 29604669, 32004170, 34403279, 37112715, 39842116, 42552125,
    56403140, 59533242, 62603429, 57584144, 53084621, 48084978, 40185593,
    34805990, 30985544,
})

local LICHBLOOM_STORM_PEAKS_COORDS = RouteCoords("Lichbloom Storm Peaks main", {
    37505980, 39105280, 38904860, 39704490, 42304380, 44804050, 45103560,
    47703600, 52104900, 58104270, 60804780, 64304960, 68704780, 72905320,
    72105670, 72706190, 72606510, 64907480, 58407210, 55407140, 52306960,
    50507360, 46707900, 42607559, 40507770, 37008240, 34507930, 35297350,
    34506960, 35906409,
})

local LICHBLOOM_ICECROWN_COORDS = RouteCoords("Lichbloom Icecrown alternative", {
    37204640, 39063547, 43823415, 47333816, 51303805, 56403670, 58103540,
    61763569, 65463879, 65503890, 69403910, 72954121, 72704820, 72305300,
    69405650, 70706350, 70206850, 68607600, 58407680, 58367679, 51907370,
    48407590, 46507130, 45106709, 41565918, 39055260,
})

local ICETHORN_ICECROWN_COORDS = RouteCoords("Icethorn Icecrown main", {
    47804310, 48303940, 51103790, 55963793, 61503590, 65403880, 69404860,
    69305640, 70806349, 69906810, 69836814, 69507420, 60717350, 58807630,
    50607400, 47006330, 47305420,
})

local ICETHORN_STORM_PEAKS_COORDS = RouteCoords("Icethorn Storm Peaks alternative", {
    27305900, 28605310, 31304950, 33904740, 36504210, 43904210, 52004890,
    58004260, 62804770, 64204940, 66905850, 65606360, 63506760, 56907100,
    51407560, 48307740, 45607910, 39907630, 34607080, 30706450,
})

local FIRE_LEAF_SCALDING_POOLS_COORDS = RouteCoords("Fire Leaf Scalding Pools main", {
    58812867, 59202030, 58201580, 60801400, 64801590, 67231543, 67301540,
    71202240, 73702420, 72102860, 74053680, 75003990, 72304120, 70703980,
    68603850, 65593670, 62104060, 59504190, 58503900, 61503360, 60303080,
})

local function HerbRoute(id, sortOrder, sourceUrls, mapID, mapName, location, coords, density, difficulty, tips, routeType)
    return {
        id = id,
        sortOrder = sortOrder,
        source = "Supplied Retail Routes export with route-specific public sources",
        sourceUrls = sourceUrls,
        mapID = mapID,
        mapName = mapName,
        location = location,
        routeType = routeType or "herbalism-loop",
        density = density,
        dropDifficulty = difficulty,
        tips = tips,
        coords = coords,
        confidence = "high",
        isRoute = true,
    }
end

local GOLDCLOVER_ROUTES = {
    HerbRoute(
        "wrath-goldclover-grizzly-hills-main-route", 1,
        { GOLDCLOVER_GUIDE, XSCARLIFE_REPO, ROUTES_IMPORT_EXPORT },
        116, "Grizzly Hills", "1. Main - broad outside loop through open grassy terrain",
        GOLDCLOVER_GRIZZLY_COORDS, "Very high Goldclover concentration",
        "Easy, long circuit with enough travel time for early nodes to begin respawning.",
        {
            "Follow the broad outside loop instead of cutting across the middle.",
            "Goldclover favors open grassy portions of Northrend rather than snowy terrain.",
            "Pick Tiger Lily too; clearing other Northrend herbs improves shared spawn-pool turnover.",
            "This circuit is also useful when farming Deadnettle passively.",
            "If another herbalist is repeatedly ahead of you, reverse the route direction.",
        }
    ),
    HerbRoute(
        "wrath-goldclover-howling-fjord-alternative-route", 2,
        { EPIC_GOLDCLOVER, GOLDCLOVER_WOWHEAD, ROUTES_IMPORT_EXPORT },
        117, "Howling Fjord", "2. Alternative - compact published Retail circuit",
        GOLDCLOVER_HOWLING_COORDS, "High Goldclover concentration",
        "Compact route with less empty travel than a whole-zone sweep.",
        {
            "Use this route when Grizzly Hills is contested.",
            "Expect plenty of Tiger Lily alongside Goldclover.",
            "The compact route reduces long empty flights.",
            "Howling Fjord is useful when targeting Goldclover rather than Sholazar's broader mixed-herb population.",
        }
    ),
    HerbRoute(
        "wrath-goldclover-borean-tundra-alternative-route", 3,
        { EPIC_GOLDCLOVER, XSCARLIFE_REPO, ROUTES_IMPORT_EXPORT },
        114, "Borean Tundra", "3. Alternative - Goldclover and Tiger Lily mixed circuit",
        GOLDCLOVER_BOREAN_COORDS, "Good mixed-herb concentration",
        "Slightly less convenient terrain than Grizzly Hills, with useful Firethorn overlap.",
        {
            "Expect slightly less convenient terrain than Grizzly Hills.",
            "Use this as a dual Goldclover and Tiger Lily farm.",
            "The circuit overlaps Borean Tundra's Firethorn and Fire Leaf region.",
        }
    ),
}

local TIGER_LILY_ROUTES = {
    HerbRoute(
        "wrath-tiger-lily-grizzly-hills-main-route", 1,
        { TIGER_LILY_GUIDE, XSCARLIFE_REPO, ROUTES_IMPORT_EXPORT },
        116, "Grizzly Hills", "1. Main - shoreline and riverbank waterline loop",
        TIGER_LILY_GRIZZLY_COORDS, "Very high Tiger Lily concentration",
        "Strong waterline route; Tiger Lily favors rivers, lakes, and other bodies of water.",
        {
            "Grizzly Hills is the strongest dedicated Tiger Lily zone in the supplied research.",
            "Hug shorelines and riverbanks rather than flying straight between route points.",
            "Do not skip nearby Goldclover; clearing it helps recycle Northrend herb spawn locations.",
            "This route gives useful incidental Deadnettle.",
        },
        "waterline-herbalism-loop"
    ),
    HerbRoute(
        "wrath-tiger-lily-howling-fjord-alternative-route", 2,
        { EPIC_TIGER_LILY, TIGER_LILY_GUIDE, ROUTES_IMPORT_EXPORT },
        117, "Howling Fjord", "2. Alternative - compact lake and waterline circuit",
        TIGER_LILY_HOWLING_COORDS, "High Tiger Lily concentration",
        "Good water-focused alternative when Grizzly Hills is occupied.",
        {
            "Follow the lakes closely; this route uses Tiger Lily's preference for water.",
            "Goldclover is common along the same circuit.",
            "Use this if another farmer is running the Grizzly Hills shoreline.",
        },
        "waterline-herbalism-loop"
    ),
}

local TALANDRAS_ROSE_ROUTES = {
    HerbRoute(
        "wrath-talandras-rose-zuldrak-main-route", 1,
        { ItemUrl(36907), EPIC_TALANDRAS_ROSE, ROUTES_IMPORT_EXPORT },
        121, "Zul'Drak", "1. Main - large non-snowy ruins and structures circuit",
        TALANDRAS_ROSE_LARGE_COORDS, "High Talandra's Rose concentration",
        "The useful section is smaller than many whole-zone herb routes, so competition is noticeable.",
        {
            "Zul'Drak is the primary dedicated zone for Talandra's Rose.",
            "Prioritize the non-snow-covered portions of the zone.",
            "Check beside walls, trees, and structures where Talandra's Rose typically spawns.",
            "Competition matters because the productive section is smaller than a whole-zone Goldclover circuit.",
        }
    ),
    HerbRoute(
        "wrath-talandras-rose-zuldrak-compact-alternative-route", 2,
        { XSCARLIFE_REPO, EPIC_TALANDRAS_ROSE, ROUTES_IMPORT_EXPORT },
        121, "Zul'Drak", "2. Alternative - compact xScarlife circuit",
        TALANDRAS_ROSE_COMPACT_COORDS, "Focused Talandra's Rose circuit",
        "Shorter loop for less empty travel or for avoiding a player following the larger route.",
        {
            "The shorter circuit means less empty travel.",
            "Use it if the larger circuit is being stripped just ahead of you.",
            "Dragonblight Frozen Herbs can yield Talandra's Rose, but that method is substantially less efficient.",
        }
    ),
}

local ADDERS_TONGUE_ROUTES = {
    HerbRoute(
        "wrath-adders-tongue-sholazar-large-main-route", 1,
        { EPIC_ADDERS_TONGUE, ADDERS_TONGUE_WOWHEAD, ROUTES_IMPORT_EXPORT },
        119, "Sholazar Basin", "1. Main - large published Sholazar circuit",
        ADDERS_TONGUE_LARGE_COORDS, "Very high Adder's Tongue concentration",
        "Long high-yield loop through the definitive Adder's Tongue farming zone.",
        {
            "This is the recommended large Sholazar route.",
            "Sholazar Basin is the definitive Adder's Tongue farming zone.",
            "Pick Goldclover and Tiger Lily rather than flying past them.",
            "Productive sub-routes also yield Deadnettle and occasional Frost Lotus.",
        }
    ),
    HerbRoute(
        "wrath-adders-tongue-sholazar-compact-alternative-route", 2,
        { EPIC_ADDERS_TONGUE, ADDERS_TONGUE_WOWHEAD, ROUTES_IMPORT_EXPORT },
        119, "Sholazar Basin", "2. Alternative - compact quick-lap circuit",
        ADDERS_TONGUE_COMPACT_COORDS, "Focused Adder's Tongue circuit",
        "Efficient when spawn density is high enough that a full-zone circuit is unnecessary.",
        {
            "Use the shorter route when spawn density makes a full-zone circuit unnecessary.",
            "It is well suited to repeated quick laps.",
            "Switch between the large and compact circuits based on competition.",
        }
    ),
}

for _, route in ipairs(ADDERS_TONGUE_ROUTES) do
    route.farmAction =
        "Gather: Harvest Adder's Tongue nodes; Crystallized Life is a possible bonus gather."
end

local LICHBLOOM_ROUTES = {
    HerbRoute(
        "wrath-lichbloom-storm-peaks-main-route", 1,
        { EPIC_LICHBLOOM, ICETHORN_WOWHEAD, ROUTES_IMPORT_EXPORT },
        120, "The Storm Peaks", "1. Main - high-level mountain herb circuit",
        LICHBLOOM_STORM_PEAKS_COORDS, "High Lichbloom and Icethorn concentration",
        "Strong endgame route with vertical terrain; a flying mount is effectively required.",
        {
            "Pick Icethorn and Lichbloom together because they occupy the same useful circuit.",
            "Do not cherry-pick Lichbloom; clearing Icethorn refreshes the shared spawn pool.",
            "Storm Peaks is especially useful when Frost Lotus also has value.",
            "Historic one-hour tests recorded substantial quantities of both primary herbs here.",
            "The published guide ranks Storm Peaks as its first Lichbloom route.",
        }
    ),
    HerbRoute(
        "wrath-lichbloom-icecrown-alternative-route", 2,
        { EPIC_LICHBLOOM, ICETHORN_WOWHEAD, ROUTES_IMPORT_EXPORT },
        118, "Icecrown", "2. Alternative - mixed Lichbloom and Icethorn circuit",
        LICHBLOOM_ICECROWN_COORDS, "High mixed endgame-herb concentration",
        "Less forgiving terrain than Storm Peaks in places, but useful when the main route is crowded.",
        {
            "Gather Icethorn along with Lichbloom.",
            "Avoid unnecessary elevation changes in Icecrown's less forgiving terrain.",
            "Use this alternative when Storm Peaks is being farmed by several players.",
        }
    ),
}

local ICETHORN_ROUTES = {
    HerbRoute(
        "wrath-icethorn-icecrown-main-route", 1,
        { EPIC_ICETHORN, ICETHORN_WOWHEAD, ROUTES_IMPORT_EXPORT },
        118, "Icecrown", "1. Main - rocky and icy terrain circuit",
        ICETHORN_ICECROWN_COORDS, "High Icethorn concentration",
        "Strong Icethorn route whose terrain rewards low, contour-following flight.",
        {
            "The published guide ranks Icecrown first for Icethorn.",
            "Pick every Lichbloom encountered.",
            "Stay close enough to rocky and icy terrain for node detection.",
            "The circuit can also produce Frost Lotus.",
        }
    ),
    HerbRoute(
        "wrath-icethorn-storm-peaks-alternative-route", 2,
        { EPIC_ICETHORN, ICETHORN_WOWHEAD, ROUTES_IMPORT_EXPORT },
        120, "The Storm Peaks", "2. Alternative - mixed high-level herb circuit",
        ICETHORN_STORM_PEAKS_COORDS, "High mixed endgame-herb concentration",
        "Excellent combined Icethorn, Lichbloom, and Frost Lotus side-value farm.",
        {
            "Use this as a mixed Icethorn, Lichbloom, and Frost Lotus farm.",
            "Historic farming reports indicate high density of both primary herbs here.",
            "Choose it when you need both high-level Northrend herbs rather than Icethorn alone.",
        }
    ),
}

local FIRE_LEAF_ROUTES = {
    HerbRoute(
        "wrath-fire-leaf-scalding-pools-main-route", 1,
        { EPIC_FIRE_LEAF, FIRE_LEAF_WOWHEAD, ROUTES_IMPORT_EXPORT },
        114, "Borean Tundra", "1. Main - compact Scalding Pools Firethorn circuit",
        FIRE_LEAF_SCALDING_POOLS_COORDS, "High localized Firethorn concentration",
        "The only meaningful dedicated outdoor Fire Leaf route; remain near the Scalding Pools.",
        {
            "Stay around the Scalding Pools instead of farming the whole zone.",
            "Firethorn is concentrated around the edges of the pools.",
            "Watch for the fiery ground effect, which can appear before the herb model is in normal detection range.",
            "Pick nearby Goldclover while waiting for Firethorn respawns.",
        },
        "firethorn-herbalism-loop"
    ),
    HerbRoute(
        "wrath-fire-leaf-borean-wide-alternative-route", 2,
        { EPIC_GOLDCLOVER, EPIC_FIRE_LEAF, XSCARLIFE_REPO },
        114, "Borean Tundra", "2. Alternative - adapted wide Goldclover and Firethorn sweep",
        GOLDCLOVER_BOREAN_COORDS, "Broad mixed-herb coverage",
        "Adapted Retail route alias; less targeted than the Scalding Pools circuit.",
        {
            "Treat this as a secondary sweep rather than the primary Fire Leaf circuit.",
            "Use it if you also want Goldclover, Tiger Lily, and Deadnettle.",
            "Return to the compact Scalding Pools loop afterward.",
        },
        "adapted-source-herb-loop"
    ),
}

local DEADNETTLE_ROUTES = {
    HerbRoute(
        "wrath-deadnettle-howling-fjord-main-route", 1,
        { ItemUrl(37921), EPIC_GOLDCLOVER, ROUTES_IMPORT_EXPORT },
        117, "Howling Fjord", "1. Main - adapted high-throughput source-herb circuit",
        GOLDCLOVER_HOWLING_COORDS, "High source-herb turnover",
        "Deadnettle has no dedicated node; yield depends on harvesting Goldclover and Tiger Lily quickly.",
        {
            "Howling Fjord, Borean Tundra, and Grizzly Hills are similarly strong Deadnettle zones.",
            "Gather every Goldclover and Tiger Lily on the circuit.",
            "Node throughput matters more than searching for a particular visual node.",
            "A fast compact mount route is preferable to cherry-picking.",
        },
        "adapted-source-herb-loop"
    ),
    HerbRoute(
        "wrath-deadnettle-borean-tundra-alternative-route", 2,
        { ItemUrl(37921), EPIC_GOLDCLOVER, ROUTES_IMPORT_EXPORT },
        114, "Borean Tundra", "2. Alternative - adapted mixed source-herb circuit",
        GOLDCLOVER_BOREAN_COORDS, "High source-herb turnover",
        "Adapted Retail route alias for farming Deadnettle from ordinary Northrend herbs.",
        {
            "Farm Goldclover and Tiger Lily indiscriminately.",
            "Firethorn is a bonus here but is not a Deadnettle source.",
            "Use this route if Howling Fjord is crowded.",
            "Grizzly Hills is another strong option for a Tiger Lily-heavy strategy.",
        },
        "adapted-source-herb-loop"
    ),
}

local FROST_LOTUS_ROUTES = {
    HerbRoute(
        "wrath-frost-lotus-storm-peaks-main-route", 1,
        { FROST_LOTUS_WOWHEAD, ICETHORN_WOWHEAD, FROST_LOTUS_ARCHIVE, ROUTES_IMPORT_EXPORT },
        120, "The Storm Peaks", "1. Main - adapted high-volume Lichbloom and Icethorn circuit",
        LICHBLOOM_STORM_PEAKS_COORDS, "Rare Frost Lotus with high source-herb turnover",
        "Frost Lotus is a rare direct or secondary gather; maximize high-level herb-node turnover.",
        {
            "Pick every Lichbloom and Icethorn; maximum herb-node turnover is the goal.",
            "Historic reporting recorded 13 Frost Lotus during a one-hour Storm Peaks herb circuit.",
            "Older dedicated research also found a productive mix of Lichbloom, Icethorn, Frost Lotus, and Crystallized Life.",
            "Do not hover at known Frost Lotus coordinates; keep cycling the herb pool.",
            "Wintergrasp is an experimental manual alternative: clear every Frozen Herb, Lichbloom, and Icethorn spawn, especially in the south.",
        },
        "adapted-rare-side-gather-loop"
    ),
    HerbRoute(
        "wrath-frost-lotus-icecrown-alternative-route", 2,
        { FROST_LOTUS_WOWHEAD, HERBS_BY_AREA, ICETHORN_WOWHEAD, ROUTES_IMPORT_EXPORT },
        118, "Icecrown", "2. Alternative - adapted high-volume Icethorn circuit",
        ICETHORN_ICECROWN_COORDS, "Rare Frost Lotus with high source-herb turnover",
        "Use when Storm Peaks is crowded; a fast flying mount helps with hostile terrain and mob packs.",
        {
            "Pick both Icethorn and Lichbloom instead of looking exclusively for Frost Lotus.",
            "Icecrown and Storm Peaks are both documented Frost Lotus zones.",
            "Use Icecrown when competition in Storm Peaks is high.",
            "A fast flying mount helps with Icecrown's hostile terrain and mob packs.",
        },
        "adapted-rare-side-gather-loop"
    ),
}

local CRYSTALLIZED_LIFE_ROUTE = {
    id = "crystallized-life-howling-fjord-thornvine-creepers",
    sortOrder = 0,
    source = "wow-professions Crystallized Life guide and Wowhead Thornvine Creeper comments",
    sourceUrls = {
        "https://www.wow-professions.com/farming/crystallized-life-farming",
        "https://www.wowhead.com/npc=23874/thornvine-creeper",
        ItemUrl(37704),
    },
    mapID = 117,
    mapName = "Howling Fjord",
    location = "Thornvine Creepers north of Fort Wildervar",
    targetName = "Thornvine Creeper",
    targetType = "kill",
    routeType = "plant-mob-grind",
    density = "Medium",
    dropDifficulty = "Good targeted farm with low travel time once the small spawn area is learned.",
    tips = {
        "Stay around the Thornvine Creeper cluster instead of widening into a full-zone herb route.",
        "Use this as a direct Crystallized Life farm when herb routes are too contested.",
    },
    coords = {
        C(0.520, 0.170, "Reported Thornvine Creeper cluster"),
        C(0.500, 0.156, "West Thornvine check"),
        C(0.540, 0.184, "East Thornvine check"),
        C(0.566, 0.198, "Outer Thornvine check"),
    },
    confidence = "high",
}

local function RegisterHerb(itemID, itemName, routes, summary, sourceUrls)
    Register({
        itemID = itemID,
        itemName = itemName,
        expansion = "wrath",
        professions = { "herbalism", "alchemy", "inscription" },
        category = "Herb",
        researchStatus = "researched",
        isRoute = true,
        sourceUrls = sourceUrls or { ItemUrl(itemID) },
        summary = summary,
        spots = routes,
    })
end

RegisterHerb(
    36901, "Goldclover", GOLDCLOVER_ROUTES,
    "Grizzly Hills is the main Goldclover route, with compact Howling Fjord and mixed Borean Tundra alternatives.",
    { ItemUrl(36901), GOLDCLOVER_GUIDE, EPIC_GOLDCLOVER, XSCARLIFE_REPO }
)
RegisterHerb(
    36904, "Tiger Lily", TIGER_LILY_ROUTES,
    "Grizzly Hills is the main waterline route, with Howling Fjord as a compact alternative.",
    { ItemUrl(36904), TIGER_LILY_GUIDE, EPIC_TIGER_LILY }
)
RegisterHerb(
    36907, "Talandra's Rose", TALANDRAS_ROSE_ROUTES,
    "Zul'Drak has both a broad primary circuit and a distinct compact alternative.",
    { ItemUrl(36907), EPIC_TALANDRAS_ROSE, XSCARLIFE_REPO }
)
RegisterHerb(
    36903, "Adder's Tongue", ADDERS_TONGUE_ROUTES,
    "Sholazar Basin has separate large and compact routes for different competition and respawn conditions.",
    { ItemUrl(36903), EPIC_ADDERS_TONGUE, ADDERS_TONGUE_WOWHEAD }
)
RegisterHerb(
    36905, "Lichbloom", LICHBLOOM_ROUTES,
    "The Storm Peaks is the main Lichbloom route, with Icecrown as the mixed-herb alternative.",
    { ItemUrl(36905), EPIC_LICHBLOOM, ICETHORN_WOWHEAD }
)
RegisterHerb(
    36906, "Icethorn", ICETHORN_ROUTES,
    "Icecrown is the main Icethorn route, with The Storm Peaks as a mixed high-level-herb alternative.",
    { ItemUrl(36906), EPIC_ICETHORN, ICETHORN_WOWHEAD }
)
RegisterHerb(
    39970, "Fire Leaf", FIRE_LEAF_ROUTES,
    "Use the compact Scalding Pools Firethorn route first and the adapted wide Borean sweep second.",
    { ItemUrl(39970), EPIC_FIRE_LEAF, FIRE_LEAF_WOWHEAD, EPIC_GOLDCLOVER }
)
RegisterHerb(
    37921, "Deadnettle", DEADNETTLE_ROUTES,
    "Deadnettle has no dedicated nodes; these adapted routes maximize Goldclover and Tiger Lily throughput.",
    { ItemUrl(37921), EPIC_GOLDCLOVER, XSCARLIFE_REPO }
)
RegisterHerb(
    36908, "Frost Lotus", FROST_LOTUS_ROUTES,
    "Frost Lotus is rare side value from high-level herb pools; use Storm Peaks first and Icecrown second.",
    { ItemUrl(36908), FROST_LOTUS_WOWHEAD, ICETHORN_WOWHEAD, HERBS_BY_AREA }
)

Register({
    itemID = 37704,
    itemName = "Crystallized Life",
    expansion = "wrath",
    professions = { "herbalism", "alchemy" },
    category = "Elemental",
    sourceUrls = { ItemUrl(37704), "https://www.wow-professions.com/farming/crystallized-life-farming" },
    summary = "Crystallized Life can be farmed from Thornvine Creepers or treated as side value from Northrend herbs.",
    spots = { CRYSTALLIZED_LIFE_ROUTE, ADDERS_TONGUE_ROUTES[1] },
})
