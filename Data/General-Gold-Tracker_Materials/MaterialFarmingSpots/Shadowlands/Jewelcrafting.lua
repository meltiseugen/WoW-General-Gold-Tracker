local _, NS = ...
local Register = NS.RegisterMaterialFarmingSpot

local function C(x, y, label)
    return { x = x, y = y, label = label }
end

local function ItemUrl(itemID)
    return "https://www.wowhead.com/item=" .. tostring(itemID)
end

local PROSPECTING_GUIDE_URLS = {
    "https://www.wowhead.com/guide/shadowlands-jewelcrafting-profession",
    "https://www.wow-professions.com/guides/shadowlands-jewelcrafting-guide",
    "https://www.wowhead.com/item=173109/angerseye",
    "https://www.wowhead.com/item=173108/oriblase",
    "https://www.wowhead.com/item=173110/umbryl",
}

local LAESTRITE_BASTION_INPUT_ROUTE = {
    id = "shadowlands-jewelcrafting-laestrite-bastion-prospecting-input-route",
    source = "Retail Wowhead prospecting comments, Wowhead Laestrite/Solenium map-pin comments, and xScarlife retail Bastion route string",
    sourceUrls = {
        "https://www.wowhead.com/item=171828/laestrite-ore",
        "https://xscarlife-gaming.com/farming-retail/",
        "https://www.wowhead.com/guide/shadowlands-mining-profession",
    },
    mapName = "Bastion",
    location = "Aspirant's Rest, Hero's Rest, and southern Bastion ore ridges for Laestrite prospecting stock",
    routeType = "prospecting-input-mining-loop",
    density = "High for Laestrite with Solenium side value",
    dropDifficulty = "Easy. Bastion is open, low-friction mining terrain and Laestrite shares many Solenium pin clusters.",
    tips = {
        "Prospect Laestrite when you want a mixed spread of Angerseye, Oriblase, Umbryl, and occasional essences.",
        "Mine every Solenium node on the loop too; it is the stronger input when Essence of Valor is the target.",
        "These pins mix retail Wowhead object/comment pins with a retail Routes import loop.",
    },
    coords = {
        C(0.383, 0.534, "Retail Wowhead Laestrite pin"),
        C(0.424, 0.563, "Laestrite and Solenium shared pin"),
        C(0.466, 0.803, "Southern Laestrite ridge pin"),
        C(0.481, 0.563, "Hero's Rest Laestrite pin"),
        C(0.502, 0.576, "Central Laestrite pin"),
        C(0.512, 0.607, "Shared central ore pin"),
        C(0.522, 0.722, "Purity's Reflection ore pin"),
        C(0.545, 0.439, "Northern return Laestrite pin"),
        C(0.557, 0.588, "Central ridge ore pin"),
        C(0.569, 0.553, "Hero's Rest ridge pin"),
        C(0.581, 0.666, "Southern Bastion ore pin"),
        C(0.600, 0.600, "Eastern return Laestrite pin"),
        C(0.6571, 0.2983, "xScarlife retail Bastion route north point"),
        C(0.6040, 0.3422, "xScarlife retail Bastion route return"),
    },
    confidence = "high",
}

local SOLENIUM_ESSENCE_INPUT_ROUTE = {
    id = "shadowlands-jewelcrafting-solenium-valor-bastion-route",
    source = "Retail Wowhead Essence of Valor prospecting table, Wowhead Solenium pins, and xScarlife retail Bastion route string",
    sourceUrls = {
        "https://www.wowhead.com/item=173173/essence-of-valor",
        "https://www.wowhead.com/item=171829/solenium-ore",
        "https://xscarlife-gaming.com/farming-retail/",
    },
    mapName = "Bastion",
    location = "Bastion Solenium loop from northern ridges through Hero's Rest and Purity's Reflection",
    routeType = "essence-prospecting-input-route",
    density = "High for Solenium and Essence of Valor input farming",
    dropDifficulty = "Easy. Clear every Bastion ore node because Laestrite can replace zone-ore spawns.",
    tips = {
        "Use this when Essence of Valor is the primary target.",
        "Keep Laestrite from the route for mixed-gem prospecting rather than discarding it.",
        "The route is intentionally dense so the addon can later reconstruct a true loop.",
    },
    coords = {
        C(0.6571, 0.2983, "North Bastion route point"),
        C(0.6535, 0.3952, "Northeast ridge"),
        C(0.6103, 0.4242, "Eastern route descent"),
        C(0.6298, 0.4978, "East Hero's Rest ridge"),
        C(0.6302, 0.5281, "Hero's Rest ore bend"),
        C(0.6052, 0.5402, "Eastern lower ridge"),
        C(0.5564, 0.5627, "Central ridge"),
        C(0.5368, 0.5939, "Central Solenium pin"),
        C(0.5425, 0.6433, "Southern ore sweep"),
        C(0.5159, 0.6137, "Central return"),
        C(0.4981, 0.6137, "West-central ore pin"),
        C(0.5040, 0.5341, "Hero's Rest return"),
        C(0.5209, 0.5093, "Northern central ridge"),
        C(0.5500, 0.5042, "Central ore line"),
        C(0.5529, 0.4599, "Northern route return"),
        C(0.5330, 0.3950, "Northwest route return"),
        C(0.4959, 0.3271, "Western Bastion route"),
        C(0.4768, 0.2395, "Northwest route point"),
        C(0.5570, 0.1050, "Northern high ridge"),
        C(0.6040, 0.3422, "Eastern ridge return"),
    },
    confidence = "high",
}

local OXXEIN_ESSENCE_INPUT_ROUTE = {
    id = "shadowlands-jewelcrafting-oxxein-servitude-maldraxxus-route",
    source = "Retail Wowhead Essence of Servitude prospecting data and xScarlife retail Maldraxxus route string",
    sourceUrls = {
        "https://www.wowhead.com/item=173172/essence-of-servitude",
        "https://www.wowhead.com/item=171830/oxxein-ore",
        "https://xscarlife-gaming.com/farming-retail/",
    },
    mapName = "Maldraxxus",
    location = "Outer Theater of Pain and House of Plagues Oxxein route",
    routeType = "essence-prospecting-input-route",
    density = "Medium to high for Oxxein",
    dropDifficulty = "Moderate. Good ore density, but hostile packs and Maldraxxus terrain slow the loop.",
    tips = {
        "Use this when Essence of Servitude is the primary target.",
        "The loop overlaps Marrowroot and Death Blossom if dual-gathering.",
        "Stay outside heavy House interiors unless visible nodes justify the detour.",
    },
    coords = {
        C(0.4929, 0.1925, "Northern Maldraxxus route point"),
        C(0.5549, 0.1999, "North ridge"),
        C(0.5447, 0.2692, "North Theater approach"),
        C(0.5512, 0.3478, "Theater north edge"),
        C(0.5858, 0.4188, "Theater east ridge"),
        C(0.5359, 0.3940, "Theater inner rim"),
        C(0.4915, 0.3841, "Theater west rim"),
        C(0.4478, 0.4369, "Western Theater ridge"),
        C(0.4597, 0.5236, "Southwest Theater bend"),
        C(0.4329, 0.5905, "Southern Oxxein return"),
        C(0.3972, 0.5418, "Western return"),
        C(0.3515, 0.5311, "West House route point"),
        C(0.3684, 0.4502, "Northwest return"),
        C(0.4250, 0.3990, "Theater entry ridge"),
    },
    confidence = "high",
}

local PHAEDRUM_ESSENCE_INPUT_ROUTE = {
    id = "shadowlands-jewelcrafting-phaedrum-rebirth-ardenweald-route",
    source = "Retail Wowhead Essence of Rebirth prospecting data and xScarlife retail Ardenweald route string",
    sourceUrls = {
        "https://www.wowhead.com/item=173170/essence-of-rebirth",
        "https://www.wowhead.com/item=171831/phaedrum-ore",
        "https://xscarlife-gaming.com/farming-retail/",
    },
    mapName = "Ardenweald",
    location = "Central Ardenweald cloverleaf route for Phaedrum prospecting inputs",
    routeType = "essence-prospecting-input-route",
    density = "Medium to high for Phaedrum",
    dropDifficulty = "Easy to moderate. Trees and roots hide some nodes, but the route is smooth once memorized.",
    tips = {
        "Use this when Essence of Rebirth is the primary target.",
        "Pair it with Vigil's Torch if you can herb on the same character.",
        "Watch ridge tops and root edges instead of staying only on roads.",
    },
    coords = {
        C(0.4169, 0.3875, "Northwest Ardenweald route point"),
        C(0.4433, 0.4332, "Central west ridge"),
        C(0.4806, 0.4424, "Central forest ridge"),
        C(0.5460, 0.4466, "Eastern forest ridge"),
        C(0.6307, 0.4598, "Eastern route point"),
        C(0.6521, 0.4976, "East route bend"),
        C(0.6228, 0.5591, "Southeast ore check"),
        C(0.5731, 0.6078, "Southern central ridge"),
        C(0.5351, 0.6264, "Central return"),
        C(0.5055, 0.6555, "South route bend"),
        C(0.4679, 0.7196, "Southwest route point"),
        C(0.4228, 0.7368, "Southwest return"),
        C(0.3781, 0.6340, "Western return"),
        C(0.3584, 0.5196, "West central route"),
        C(0.3839, 0.4276, "Northwest return"),
    },
    confidence = "high",
}

local SINVYR_ESSENCE_INPUT_ROUTE = {
    id = "shadowlands-jewelcrafting-sinvyr-torment-revendreth-route",
    source = "Retail Wowhead Essence of Torment prospecting data, xScarlife retail Revendreth route string, and Artisans of Azeroth Sinvyr route guidance",
    sourceUrls = {
        "https://www.wowhead.com/item=173171/essence-of-torment",
        "https://www.wowhead.com/item=171832/sinvyr-ore",
        "https://xscarlife-gaming.com/farming-retail/",
        "https://artisansofazeroth.com/materials/sinvyr-ore/",
    },
    mapName = "Revendreth",
    location = "Lower Revendreth and Sinfall-side Sinvyr loop",
    routeType = "essence-prospecting-input-route",
    density = "Medium for Sinvyr, with travel friction",
    dropDifficulty = "Moderate. Elevation changes and hostile pockets slow the route compared with Bastion.",
    tips = {
        "Use this when Essence of Torment is the primary target.",
        "Avoid the most vertical town sections unless a visible node is close.",
        "This path can double as Widowbloom and Death Blossom value.",
    },
    coords = {
        C(0.2636, 0.3816, "Western Revendreth route point"),
        C(0.2940, 0.3479, "Sinfall-side north return"),
        C(0.3405, 0.3688, "Northwest ridge"),
        C(0.3654, 0.5188, "Sanctuary approach"),
        C(0.3938, 0.5839, "Lower Revendreth bend"),
        C(0.4447, 0.6013, "Lower ridge line"),
        C(0.4882, 0.6149, "Central lower route"),
        C(0.5449, 0.6047, "Eastern lower route"),
        C(0.6109, 0.5615, "Eastern ridge"),
        C(0.6920, 0.5847, "Far east route point"),
        C(0.7109, 0.6701, "Southeast lower route"),
        C(0.6650, 0.6740, "Southern ridge return"),
        C(0.5962, 0.7205, "Southern lower route"),
        C(0.5345, 0.7117, "Pridefall route"),
        C(0.4702, 0.7257, "Southwest lower route"),
        C(0.4085, 0.6897, "Western lower return"),
        C(0.3146, 0.5285, "Sanctuary return"),
    },
    confidence = "high",
}

local ELETHIUM_ESSENCE_INPUT_ROUTE = {
    id = "shadowlands-jewelcrafting-elethium-korthia-prospecting-route",
    source = "Retail Wowhead mining guide and Elethium prospecting comments",
    sourceUrls = {
        "https://www.wowhead.com/guide/shadowlands-mining-profession",
        "https://www.wowhead.com/item=171833/elethium-ore",
        "https://www.wow-professions.com/farming/elethium-ore-farming",
    },
    mapName = "Korthia",
    location = "Korthia dedicated Elethium node route through ridges and ruins",
    routeType = "prospecting-input-mining-loop",
    density = "Medium targeted Elethium",
    dropDifficulty = "Moderate. Korthia is the stronger targeted Elethium route, but terrain and mobs slow ground farming.",
    tips = {
        "Elethium prospects into all three base gems and all four essences.",
        "Use this when essence prices are broadly high rather than when only one zone essence is needed.",
        "Clear dedicated Elethium deposits instead of waiting on rare covenant-zone side drops.",
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

local BASE_GEM_SPOTS = {
    LAESTRITE_BASTION_INPUT_ROUTE,
    SOLENIUM_ESSENCE_INPUT_ROUTE,
    OXXEIN_ESSENCE_INPUT_ROUTE,
    PHAEDRUM_ESSENCE_INPUT_ROUTE,
    SINVYR_ESSENCE_INPUT_ROUTE,
    ELETHIUM_ESSENCE_INPUT_ROUTE,
}

local function RegisterJewelcrafting(itemID, itemName, category, spots, summary, sourceUrls)
    Register({
        itemID = itemID,
        itemName = itemName,
        expansion = "shadowlands",
        professions = { "jewelcrafting" },
        category = category,
        sourceUrls = sourceUrls or PROSPECTING_GUIDE_URLS,
        summary = summary,
        spots = spots,
    })
end

RegisterJewelcrafting(173108, "Oriblase", "Gem", BASE_GEM_SPOTS,
    "Base Shadowlands jewelcrafting gem from prospecting Laestrite, zone ores, and Elethium.")
RegisterJewelcrafting(173109, "Angerseye", "Gem", BASE_GEM_SPOTS,
    "Base Shadowlands jewelcrafting gem from prospecting Laestrite, zone ores, and Elethium.")
RegisterJewelcrafting(173110, "Umbryl", "Gem", BASE_GEM_SPOTS,
    "Base Shadowlands jewelcrafting gem from prospecting Laestrite, zone ores, and Elethium.")
RegisterJewelcrafting(173170, "Essence of Rebirth", "Essence", {
    PHAEDRUM_ESSENCE_INPUT_ROUTE,
    ELETHIUM_ESSENCE_INPUT_ROUTE,
    LAESTRITE_BASTION_INPUT_ROUTE,
}, "Essence most commonly found by prospecting Phaedrum Ore; Elethium and Laestrite are backup inputs.", {
    ItemUrl(173170),
    "https://www.wow-professions.com/guides/shadowlands-jewelcrafting-guide",
})
RegisterJewelcrafting(173171, "Essence of Torment", "Essence", {
    SINVYR_ESSENCE_INPUT_ROUTE,
    ELETHIUM_ESSENCE_INPUT_ROUTE,
    LAESTRITE_BASTION_INPUT_ROUTE,
}, "Essence most commonly found by prospecting Sinvyr Ore; Elethium and Laestrite are backup inputs.", {
    ItemUrl(173171),
    "https://www.wow-professions.com/guides/shadowlands-jewelcrafting-guide",
})
RegisterJewelcrafting(173172, "Essence of Servitude", "Essence", {
    OXXEIN_ESSENCE_INPUT_ROUTE,
    ELETHIUM_ESSENCE_INPUT_ROUTE,
    LAESTRITE_BASTION_INPUT_ROUTE,
}, "Essence most commonly found by prospecting Oxxein Ore; Elethium and Laestrite are backup inputs.", {
    ItemUrl(173172),
    "https://www.wow-professions.com/guides/shadowlands-jewelcrafting-guide",
})
RegisterJewelcrafting(173173, "Essence of Valor", "Essence", {
    SOLENIUM_ESSENCE_INPUT_ROUTE,
    ELETHIUM_ESSENCE_INPUT_ROUTE,
    LAESTRITE_BASTION_INPUT_ROUTE,
}, "Essence most commonly found by prospecting Solenium Ore; Elethium and Laestrite are backup inputs.", {
    ItemUrl(173173),
    "https://www.wow-professions.com/guides/shadowlands-jewelcrafting-guide",
})
