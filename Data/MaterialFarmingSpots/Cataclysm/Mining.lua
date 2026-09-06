local _, NS = ...
local Register = NS.RegisterMaterialFarmingSpot

local function C(x, y, label)
    return { x = x, y = y, label = label }
end

local function ItemUrl(itemID)
    return "https://www.wowhead.com/item=" .. tostring(itemID)
end

local OBSIDIUM_ROUTES = {
    {
        id = "cataclysm-obsidium-shimmering-expanse-high-density",
        source = "Retail Wowhead Obsidium node pins, wow-professions Obsidium guide, and Artisans of Azeroth catalog cross-check",
        sourceUrls = {
            "https://www.wowhead.com/object=202736/obsidium-deposit",
            "https://www.wow-professions.com/farming/obsidium-ore-farming",
            "https://artisansofazeroth.com/materials/obsidium-ore/",
        },
        mapName = "Shimmering Expanse",
        location = "Central Shimmering Expanse Obsidium route",
        routeType = "mining-loop",
        density = "High",
        dropDifficulty = "Excellent node density, but underwater navigation is slower if you dislike Vashj'ir routing.",
        tips = {
            "Stay in the highlighted central Shimmering Expanse section instead of doing all of Vashj'ir.",
            "Use Mount Hyjal as the dry-land alternative.",
            "Mine every Obsidium node if you also value Cataclysm uncommon gems.",
        },
        coords = {
            C(0.356, 0.698, "Northwest Obsidium pin"),
            C(0.367, 0.651, "North ridge Obsidium pin"),
            C(0.398, 0.324, "North shelf Obsidium pin"),
            C(0.404, 0.394, "Central shelf Obsidium pin"),
            C(0.410, 0.340, "Northwest Obsidium sweep"),
            C(0.500, 0.380, "Central Obsidium sweep"),
            C(0.610, 0.470, "Eastern Obsidium sweep"),
            C(0.530, 0.590, "Southern Obsidium sweep"),
            C(0.390, 0.550, "Western Obsidium sweep"),
        },
        confidence = "high",
    },
    {
        id = "cataclysm-obsidium-mount-hyjal-rim-loop",
        source = "Retail Wowhead Obsidium node pins and wow-professions Obsidium guide",
        sourceUrls = {
            "https://www.wowhead.com/object=202736/obsidium-deposit",
            "https://www.wow-professions.com/farming/obsidium-ore-farming",
        },
        mapName = "Mount Hyjal",
        location = "Mount Hyjal rim and shrine mining loop",
        routeType = "mining-loop",
        density = "Medium to high",
        dropDifficulty = "Good dry-land route with simpler movement than Vashj'ir.",
        tips = {
            "Follow cliffs and zone edges, then cut through shrine areas when node density is high.",
            "Use this when Vashj'ir is crowded or underwater farming feels slow.",
        },
        coords = {
            C(0.620, 0.240, "Northern ridge"),
            C(0.540, 0.330, "Shrine ridge"),
            C(0.450, 0.440, "Central cut-through"),
            C(0.280, 0.560, "Western rim"),
            C(0.480, 0.700, "Southern rim"),
            C(0.720, 0.460, "Eastern rim"),
        },
        confidence = "high",
    },
}

local ELEMENTIUM_PYRITE_ROUTES = {
    {
        id = "cataclysm-elementium-pyrite-twilight-highlands-loop",
        source = "Retail Wowhead Elementium/Pyrite node pins, wow-professions Elementium guide, and Artisans of Azeroth catalog cross-check",
        sourceUrls = {
            "https://www.wowhead.com/object=202738/elementium-vein",
            "https://www.wowhead.com/object=202737/pyrite-deposit",
            "https://www.wow-professions.com/farming/elementium-ore-farming",
            "https://artisansofazeroth.com/materials/elementium-ore/",
        },
        mapName = "Twilight Highlands",
        location = "Twilight Highlands Elementium loop with Pyrite replacement checks",
        routeType = "mining-loop",
        density = "High",
        dropDifficulty = "Strong Elementium route. Pyrite is rarer and depends on Elementium node turnover.",
        tips = {
            "Mine every Elementium node when targeting Pyrite because Pyrite can replace Elementium nodes.",
            "Use the full route when competition is high; tighten it around active clusters when the zone is quiet.",
            "Potion of Treasure Finding can add side value if you also kill nearby humanoids.",
        },
        coords = {
            C(0.172, 0.567, "Western Elementium pin"),
            C(0.178, 0.633, "Western ridge Elementium pin"),
            C(0.181, 0.570, "Northwest ridge Elementium pin"),
            C(0.280, 0.300, "Northwest ridge"),
            C(0.400, 0.230, "Northern ridge"),
            C(0.560, 0.260, "Thundermar ridge"),
            C(0.680, 0.360, "Eastern ridge"),
            C(0.640, 0.600, "Southeast return"),
            C(0.450, 0.720, "Southern highlands"),
            C(0.260, 0.560, "Western return"),
        },
        confidence = "high",
    },
    {
        id = "cataclysm-elementium-pyrite-uldum-north-loop",
        source = "Retail Wowhead Elementium/Pyrite node pins and wow-professions Elementium guide",
        sourceUrls = {
            "https://www.wowhead.com/object=202738/elementium-vein",
            "https://www.wowhead.com/object=202737/pyrite-deposit",
            "https://www.wow-professions.com/farming/elementium-ore-farming",
        },
        mapName = "Uldum",
        location = "Northern Uldum Elementium route with Pyrite checks",
        routeType = "mining-loop",
        density = "Medium to high",
        dropDifficulty = "Good alternative to Twilight Highlands; use Zidormi if you are in the newer Uldum phase.",
        tips = {
            "Stay mostly on the northern half of the zone for better node density.",
            "Detour around the Obelisk of the Sun only when competition is high.",
            "Mine Elementium aggressively to force Pyrite replacement chances.",
        },
        coords = {
            C(0.154, 0.597, "Northwest Uldum Elementium pin"),
            C(0.166, 0.577, "Northwest ridge Elementium pin"),
            C(0.180, 0.566, "Western ridge Elementium pin"),
            C(0.231, 0.493, "Obelisk ridge Elementium pin"),
            C(0.360, 0.220, "Northwest Uldum ridge"),
            C(0.470, 0.260, "Northern central ridge"),
            C(0.590, 0.280, "Northeast ridge"),
            C(0.700, 0.350, "Eastern ridge"),
            C(0.630, 0.500, "Obelisk detour"),
        },
        confidence = "high",
    },
}

Register({
    itemID = 53038,
    itemName = "Obsidium Ore",
    expansion = "cataclysm",
    professions = { "mining" },
    category = "Ore",
    sourceUrls = { ItemUrl(53038), "https://www.wowhead.com/object=202736/obsidium-deposit" },
    summary = "Starter Cataclysm ore best farmed in Shimmering Expanse or Mount Hyjal.",
    spots = OBSIDIUM_ROUTES,
})

Register({
    itemID = 52185,
    itemName = "Elementium Ore",
    expansion = "cataclysm",
    professions = { "mining" },
    category = "Ore",
    sourceUrls = { ItemUrl(52185), "https://www.wowhead.com/object=202738/elementium-vein" },
    summary = "Primary high-level Cataclysm ore from Twilight Highlands, Uldum, Deepholm, and Tol Barad routes.",
    spots = ELEMENTIUM_PYRITE_ROUTES,
})

Register({
    itemID = 52183,
    itemName = "Pyrite Ore",
    expansion = "cataclysm",
    professions = { "mining" },
    category = "Ore",
    sourceUrls = { ItemUrl(52183), "https://www.wowhead.com/object=202737/pyrite-deposit" },
    summary = "Rare Cataclysm ore that shares spawn points with Elementium; farm Elementium routes and keep node turnover high.",
    spots = ELEMENTIUM_PYRITE_ROUTES,
})

Register({
    itemID = 52327,
    itemName = "Volatile Earth",
    expansion = "cataclysm",
    professions = { "mining", "alchemy", "engineering" },
    category = "Volatile",
    sourceUrls = {
        ItemUrl(52327),
        "https://www.wowhead.com/npc=47226/obsidian-stoneslave",
        "https://www.wow-professions.com/farming/volatile-earth-farming",
    },
    summary = "Volatile Earth is a mining side material and can also be targeted from Obsidian Stoneslaves in Twilight Highlands.",
    spots = {
        {
            id = "cataclysm-volatile-earth-twilight-highlands-obsidian-stoneslaves",
            source = "Wowhead Volatile Earth guide, wow-professions Volatile Earth guide, and Obsidian Stoneslave page",
            sourceUrls = {
                "https://www.wowhead.com/npc=47226/obsidian-stoneslave",
                "https://www.wow-professions.com/farming/volatile-earth-farming",
                "https://www.wowhead.com/object=202738/elementium-vein",
            },
            mapName = "Twilight Highlands",
            location = "Obsidian Stoneslaves east of Thundermar at The Black Breach",
            routeType = "open-world-loop",
            density = "High",
            dropDifficulty = "Good targeted farm; miners can mine the corpses for extra value.",
            tips = {
                "Stay in the Black Breach pocket east of Thundermar instead of widening into a full-zone route.",
                "Mine eligible corpses after looting if you have Mining.",
                "Switch to the normal Elementium loop when the camp is crowded.",
            },
            coords = {
                C(0.596, 0.304, "North Black Breach pack"),
                C(0.620, 0.320, "Central Black Breach pack"),
                C(0.644, 0.346, "East Black Breach pack"),
                C(0.612, 0.374, "South Black Breach pack"),
            },
            confidence = "high",
        },
        ELEMENTIUM_PYRITE_ROUTES[1],
    },
})
