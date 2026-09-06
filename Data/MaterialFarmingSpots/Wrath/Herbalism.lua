local _, NS = ...
local Register = NS.RegisterMaterialFarmingSpot

local function C(x, y, label)
    return { x = x, y = y, label = label }
end

local function ItemUrl(itemID)
    return "https://www.wowhead.com/item=" .. tostring(itemID)
end

local ROUTE_STRING_SOURCE = "https://xscarlife-gaming.com/farming-retail/"

local GOLDCLOVER_DEADNETTLE_ROUTE = {
    id = "wrath-goldclover-deadnettle-grizzly-hills-herb-loop",
    source = "wow-professions Goldclover guide, Wowhead herb farming guide, and Wowhead herbalism overview",
    sourceUrls = {
        "https://www.wow-professions.com/farming/goldclover-farming",
        "https://www.wowhead.com/object=189973/goldclover",
        "https://www.wowhead.com/item=37921/deadnettle",
        "https://www.wowhead.com/guide/herbs-best-farming-locations",
        "https://www.wowhead.com/guide/professions/herbalism/overview-leveling-routes",
        ROUTE_STRING_SOURCE,
    },
    mapName = "Grizzly Hills",
    location = "Grizzly Hills river, ridge, and forest-edge loop for Goldclover and Deadnettle side gathers",
    routeType = "herbalism-loop",
    density = "High",
    dropDifficulty = "Easy starter Northrend herb route, with Deadnettle as a side gather.",
    tips = {
        "Goldclover is common across Northrend; Grizzly Hills has a dense retail route-string loop.",
        "Deadnettle has no standalone node, so farm Goldclover, Tiger Lily, and Talandra's Rose turnover.",
        "Pick every herb to keep node turnover high.",
        "Use Howling Fjord or Borean Tundra when the route is crowded.",
    },
    coords = {
        C(0.1236, 0.3201, "West Grizzly herb edge"),
        C(0.2290, 0.2801, "Amberpine ridge"),
        C(0.3226, 0.3756, "Blue Sky logging road herbs"),
        C(0.4442, 0.2859, "Northern forest edge"),
        C(0.5132, 0.2750, "Ursoc's Den approach"),
        C(0.5513, 0.2734, "Northeast ridge"),
        C(0.5879, 0.2405, "Thor Modan return"),
        C(0.6892, 0.1503, "Northeast river head"),
        C(0.6896, 0.2713, "Eastern river bend"),
        C(0.7639, 0.3524, "East Grizzly herbs"),
        C(0.7619, 0.4378, "Drakil'jin southern pass"),
        C(0.8385, 0.5544, "Eastern forest return"),
        C(0.6439, 0.6048, "South river bend"),
        C(0.5485, 0.5439, "Central river herbs"),
        C(0.2584, 0.5334, "Western river return"),
        C(0.1832, 0.6356, "Southwest Grizzly herbs"),
        C(0.1257, 0.7312, "Southwest edge"),
        C(0.1095, 0.4624, "West return ridge"),
    },
    confidence = "high",
}

local SHOLAZAR_ADDER_ROUTE = {
    id = "wrath-sholazar-basin-adder-tiger-lily-loop",
    source = "Wowhead Adder's Tongue object page, Wowhead herb farming guide, and Wowhead herbalism overview",
    sourceUrls = {
        "https://www.wowhead.com/object=191019/adders-tongue",
        "https://www.wowhead.com/guide/herbs-best-farming-locations",
        "https://www.wowhead.com/guide/professions/herbalism/overview-leveling-routes",
        ROUTE_STRING_SOURCE,
    },
    mapName = "Sholazar Basin",
    location = "Sholazar jungle and waterline herb route",
    routeType = "herbalism-loop",
    density = "High",
    dropDifficulty = "Good all-purpose route. Adder's Tongue favors jungle areas, while Tiger Lily favors waterways.",
    tips = {
        "Sweep jungle pockets for Adder's Tongue and use separate Grizzly/river loops for Tiger Lily volume.",
        "Do not waste time in the burned-up sections when targeting Adder's Tongue.",
        "Keep moving through the full basin if competition is high.",
    },
    coords = {
        C(0.3287, 0.4645, "Northwest jungle pocket"),
        C(0.3799, 0.4815, "Central west jungle"),
        C(0.3522, 0.5855, "Western river bend"),
        C(0.3540, 0.6428, "Southwest jungle"),
        C(0.3736, 0.6679, "South jungle return"),
        C(0.4067, 0.6508, "Central south jungle"),
        C(0.4415, 0.7544, "Southern river edge"),
        C(0.3288, 0.8322, "Southwest return"),
        C(0.2843, 0.7284, "Western basin edge"),
        C(0.2806, 0.6698, "West river return"),
        C(0.2250, 0.6112, "Far west basin edge"),
        C(0.2476, 0.5634, "West jungle return"),
        C(0.2954, 0.5622, "Central west node"),
        C(0.2965, 0.4934, "Northwest return"),
    },
    confidence = "high",
}

local GRIZZLY_TIGER_LILY_ROUTE = {
    id = "wrath-tiger-lily-grizzly-hills-waterline-loop",
    source = "Retail Wowhead Tiger Lily object page, herb guide, and retail route-string sample",
    sourceUrls = {
        "https://www.wowhead.com/object=190169/tiger-lily",
        "https://www.wowhead.com/guide/herbs-best-farming-locations",
        "https://www.wowhead.com/guide/professions/herbalism/overview-leveling-routes",
        ROUTE_STRING_SOURCE,
    },
    mapName = "Grizzly Hills",
    location = "Grizzly Hills river and lake-edge Tiger Lily loop",
    routeType = "waterline-herbalism-loop",
    density = "High",
    dropDifficulty = "Good waterline route. Tiger Lily favors rivers and lake shores.",
    tips = {
        "Follow rivers and lake edges instead of cutting over dry ridges.",
        "Pair with the Goldclover route when you want Deadnettle side value.",
        "Use Sholazar Basin if Grizzly Hills river loops are crowded.",
    },
    coords = {
        C(0.0924, 0.3723, "West river mouth"),
        C(0.1960, 0.4031, "West river edge"),
        C(0.2877, 0.3917, "Amberpine waterline"),
        C(0.3284, 0.3788, "Central west river"),
        C(0.3513, 0.3192, "Northwest river bend"),
        C(0.3969, 0.3097, "North central waterline"),
        C(0.4217, 0.3623, "Central river crossing"),
        C(0.3717, 0.4238, "Central waterline return"),
        C(0.3142, 0.4630, "Southwest river bend"),
        C(0.2927, 0.5870, "South river path"),
        C(0.2519, 0.7378, "Southwest lake edge"),
        C(0.1638, 0.7348, "Southwest waterline"),
        C(0.1425, 0.5112, "Western river return"),
    },
    confidence = "high",
}

local ZULDRAK_ROSE_ROUTE = {
    id = "wrath-talandras-rose-zuldrak-route",
    source = "Wowhead Talandra's Rose object page and Wowhead herbalism overview",
    sourceUrls = {
        "https://www.wowhead.com/object=190170/talandras-rose",
        "https://www.wowhead.com/guide/professions/herbalism/overview-leveling-routes",
        "https://warcraft.wiki.gg/wiki/Talandra%27s_Rose",
        ROUTE_STRING_SOURCE,
    },
    mapName = "Zul'Drak",
    location = "Zul'Drak ruins, walls, and waterline herb route",
    routeType = "herbalism-loop",
    density = "Medium to high",
    dropDifficulty = "Moderate because terrain and structures break up the route.",
    tips = {
        "Check non-snowy ruins, walls, and water edges where Talandra's Rose clusters.",
        "Avoid long empty runs through the snowy northeast unless you are also gathering other herbs.",
    },
    coords = {
        C(0.2946, 0.4046, "Western Zul'Drak wall"),
        C(0.3412, 0.4031, "Altar approach herbs"),
        C(0.3627, 0.4460, "Southwest ruin edge"),
        C(0.4307, 0.3851, "Central ruin wall"),
        C(0.4733, 0.4967, "Argent Stand route"),
        C(0.3520, 0.6101, "Southwest waterline"),
        C(0.4091, 0.8579, "Southern troll ruins"),
        C(0.2597, 0.8312, "Southwest return wall"),
        C(0.3212, 0.5151, "Central west return"),
        C(0.2901, 0.4699, "Western return"),
    },
    confidence = "high",
}

local ENDGAME_HERB_ROUTE = {
    id = "wrath-lichbloom-icethorn-storm-peaks-route",
    source = "wow-professions Lichbloom/Icethorn guide, Wowhead Icethorn object page, and Wowhead herbalism overview",
        sourceUrls = {
        "https://www.wow-professions.com/farming/lichbloom-icethorn-farming",
        "https://www.wowhead.com/object=190172/icethorn",
        "https://www.wowhead.com/object=190171/lichbloom",
        "https://www.wowhead.com/guide/professions/herbalism/overview-leveling-routes",
        ROUTE_STRING_SOURCE,
    },
    mapName = "The Storm Peaks",
    location = "Storm Peaks Lichbloom and Icethorn mountain route",
    routeType = "herbalism-loop",
    density = "High",
    dropDifficulty = "Strong endgame herb route, but vertical terrain makes flying effectively required.",
    tips = {
        "Lichbloom and Icethorn share routes, so gather both instead of tunnel-visioning one node type.",
        "Use Icecrown or Wintergrasp as alternates when Storm Peaks is crowded.",
        "Frost Lotus can appear as rare side value from high-volume herb gathering.",
    },
    coords = {
        C(0.3517, 0.4279, "Western mountain herb line"),
        C(0.3920, 0.4595, "Central west ridge"),
        C(0.3714, 0.5132, "West terrace herbs"),
        C(0.3657, 0.5614, "Western snow shelf"),
        C(0.3911, 0.5984, "Central snow shelf"),
        C(0.4266, 0.5970, "Central mountain line"),
        C(0.4561, 0.5422, "Terrace herb checks"),
        C(0.4899, 0.6326, "South central ridge"),
        C(0.5518, 0.6489, "Southeast herb line"),
        C(0.4427, 0.7289, "Southern mountain return"),
        C(0.3957, 0.8666, "Southwest snow shelf"),
        C(0.3263, 0.8642, "Southwest return"),
        C(0.3632, 0.7797, "Southwest ridge"),
        C(0.3443, 0.6628, "West return ridge"),
        C(0.3114, 0.6548, "West route return"),
        C(0.2717, 0.7028, "Far west loop"),
        C(0.2383, 0.6301, "Western cliff herb"),
        C(0.2802, 0.5027, "Northwest route return"),
        C(0.3204, 0.4909, "Western mountain return"),
    },
    confidence = "high",
}

local FROST_LOTUS_ROUTE = {
    id = "wrath-frost-lotus-wintergrasp-herb-route",
    source = "Wowhead Frost Lotus object page, Wowhead herb farming guide, and wow-professions Lichbloom/Icethorn guide",
    sourceUrls = {
        "https://www.wowhead.com/object=190176/frost-lotus",
        "https://www.wowhead.com/guide/herbs-best-farming-locations",
        "https://www.wow-professions.com/farming/lichbloom-icethorn-farming",
    },
    mapName = "Wintergrasp",
    location = "Wintergrasp lower-half herb and Frozen Herb checks",
    routeType = "rare-side-gather-route",
    density = "Rare",
    dropDifficulty = "Hard to target directly. Treat Frost Lotus as rare value while cycling high-level herbs.",
    tips = {
        "Use this when Wintergrasp is accessible and you are already cycling high-level herbs.",
        "Skip the route during active battle windows.",
        "Do not expect deterministic Lotus spawns; value comes from turnover and side herbs.",
    },
    coords = {
        C(0.264, 0.572, "Southwest herb checks"),
        C(0.392, 0.616, "Lower central herb checks"),
        C(0.508, 0.686, "Southern herb checks"),
        C(0.636, 0.602, "Southeast herb checks"),
        C(0.722, 0.496, "Eastern lower herb checks"),
    },
    confidence = "medium",
}

local CRYSTALLIZED_LIFE_ROUTE = {
    id = "crystallized-life-howling-fjord-thornvine-creepers",
    source = "wow-professions Crystallized Life guide and Wowhead Thornvine Creeper comments",
    sourceUrls = {
        "https://www.wow-professions.com/farming/crystallized-life-farming",
        "https://www.wowhead.com/npc=23874/thornvine-creeper",
        ItemUrl(37704),
    },
    mapName = "Howling Fjord",
    location = "Thornvine Creepers north of Fort Wildervar",
    routeType = "open-world-loop",
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

local function RegisterHerb(itemID, itemName, route, summary)
    Register({
        itemID = itemID,
        itemName = itemName,
        expansion = "wrath",
        professions = { "herbalism", "alchemy", "inscription" },
        category = "Herb",
        sourceUrls = { ItemUrl(itemID) },
        summary = summary,
        spots = { route },
    })
end

RegisterHerb(36901, "Goldclover", GOLDCLOVER_DEADNETTLE_ROUTE, "Starter Northrend herb most plentiful in Howling Fjord and Grizzly Hills, with Deadnettle side value.")
RegisterHerb(36903, "Adder's Tongue", SHOLAZAR_ADDER_ROUTE, "Sholazar Basin signature herb, common in jungle pockets away from burned-up terrain.")
RegisterHerb(36904, "Tiger Lily", GRIZZLY_TIGER_LILY_ROUTE, "Waterline Northrend herb found around rivers and lake shores, especially Grizzly Hills and Sholazar Basin.")
RegisterHerb(36907, "Talandra's Rose", ZULDRAK_ROSE_ROUTE, "Zul'Drak specialty herb found around ruins, walls, and waterline sections.")
RegisterHerb(36905, "Lichbloom", ENDGAME_HERB_ROUTE, "Endgame Northrend herb sharing high-level Storm Peaks, Icecrown, and Wintergrasp routes with Icethorn.")
RegisterHerb(36906, "Icethorn", ENDGAME_HERB_ROUTE, "Endgame Northrend herb sharing high-level Storm Peaks, Icecrown, and Wintergrasp routes with Lichbloom.")

Register({
    itemID = 36908,
    itemName = "Frost Lotus",
    expansion = "wrath",
    professions = { "herbalism", "alchemy", "inscription" },
    category = "Herb",
    sourceUrls = { ItemUrl(36908), "https://www.wowhead.com/object=190176/frost-lotus" },
    summary = "Rare Northrend herb side gather from high-level herb routes and rare Wintergrasp/Frozen Herb checks.",
    spots = { FROST_LOTUS_ROUTE },
})

Register({
    itemID = 37704,
    itemName = "Crystallized Life",
    expansion = "wrath",
    professions = { "herbalism", "alchemy" },
    category = "Elemental",
    sourceUrls = { ItemUrl(37704), "https://www.wow-professions.com/farming/crystallized-life-farming" },
    summary = "Crystallized Life can be farmed from Thornvine Creepers or treated as side value from Northrend herbs.",
    spots = { CRYSTALLIZED_LIFE_ROUTE, SHOLAZAR_ADDER_ROUTE },
})

Register({
    itemID = 37921,
    itemName = "Deadnettle",
    expansion = "wrath",
    professions = { "herbalism", "alchemy", "inscription" },
    category = "Herb",
    sourceUrls = {
        ItemUrl(37921),
        "https://www.wowhead.com/item=37921/deadnettle",
        "https://www.wowhead.com/object=189973/goldclover",
    },
    summary = "Deadnettle is a side gather from Northrend herbs such as Goldclover, Tiger Lily, and Talandra's Rose.",
    spots = { GOLDCLOVER_DEADNETTLE_ROUTE, GRIZZLY_TIGER_LILY_ROUTE, ZULDRAK_ROSE_ROUTE },
})
