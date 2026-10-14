local _, NS = ...
local Register = NS.RegisterMaterialFarmingSpot

local function C(x, y, label)
    return { x = x, y = y, label = label }
end

local function ItemUrl(itemID)
    return "https://www.wowhead.com/item=" .. tostring(itemID)
end

local AOA_ROUTE_SOURCE = "https://artisansofazeroth.com/zone-atlas/"
local WOD_GATHERING_GUIDE = "https://www.wowhead.com/guide/professions/wod/gathering-professions-overview"

local FROSTFIRE_FROSTWEED_ROUTE = {
    id = "warlords-frostweed-frostfire-imported-route",
    source = "Retail Wowhead WoD gathering overview, wow-professions Frostweed guide, and Artisans of Azeroth retail Frostfire herb pins",
    sourceUrls = {
        WOD_GATHERING_GUIDE,
        "https://www.wow-professions.com/farming/frostweed-farming",
        AOA_ROUTE_SOURCE,
    },
    mapName = "Frostfire Ridge",
    location = "Frostfire Ridge snowfield herb route",
    routeType = "herbalism-loop",
    density = "High",
    dropDifficulty = "Good starter Draenor herb route with relatively simple terrain.",
    tips = {
        "Sweep snowfield edges rather than climbing deep mountain spurs.",
        "These sampled pins are dense enough for a future in-addon map route.",
    },
    coords = {
        C(0.4195, 0.1169, "Northern snowfield start"),
        C(0.4266, 0.1977, "Northwest snowfield"),
        C(0.4857, 0.1475, "North ridge herb"),
        C(0.4716, 0.2275, "North central herb"),
        C(0.5371, 0.2869, "Thunder Pass approach"),
        C(0.5322, 0.3773, "Central snowfield"),
        C(0.5129, 0.3467, "Central return"),
        C(0.4835, 0.4011, "West central node"),
        C(0.5102, 0.4099, "Central node pair"),
        C(0.4940, 0.4554, "Frostwall approach"),
        C(0.4323, 0.4492, "Western return"),
        C(0.4064, 0.4757, "West snowfield"),
        C(0.4173, 0.4148, "Northwest return"),
        C(0.4495, 0.3745, "Return ridge"),
    },
    confidence = "high",
}

local FROSTFIRE_FIREWEED_ROUTE = {
    id = "warlords-fireweed-frostfire-lava-imported-route",
    source = "Retail Wowhead Fireweed item page, WoD gathering overview, wow-professions Fireweed guide, and Artisans of Azeroth Frostfire pins",
    sourceUrls = {
        ItemUrl(109125),
        WOD_GATHERING_GUIDE,
        "https://www.wow-professions.com/farming/fireweed-farming",
        AOA_ROUTE_SOURCE,
    },
    mapName = "Frostfire Ridge",
    location = "Frostfire Ridge lava-side Fireweed route",
    routeType = "lava-herbalism-loop",
    density = "Medium to high",
    dropDifficulty = "Lava terrain and cliff transitions make this slower than generic Frostweed loops.",
    tips = {
        "Fireweed favors Frostfire lava pockets; do not sweep the whole snowfield when Fireweed is the target.",
        "Use the sampled loop as a route spine, then detour into visible lava-side herbs.",
    },
    coords = {
        C(0.6397, 0.7702, "Southern lava route start"),
        C(0.6772, 0.7275, "Southeast lava bend"),
        C(0.6807, 0.6848, "Lava shelf"),
        C(0.7111, 0.7111, "East lava pocket"),
        C(0.7228, 0.6237, "East pass"),
        C(0.7234, 0.5864, "Northeast lava edge"),
        C(0.7497, 0.5628, "Far east lava edge"),
        C(0.7095, 0.5542, "East return"),
        C(0.6724, 0.4764, "North lava bend"),
        C(0.6518, 0.5078, "Central lava node"),
        C(0.6651, 0.6317, "Central return"),
        C(0.6285, 0.5809, "West lava shelf"),
        C(0.6091, 0.6672, "Southwest lava edge"),
        C(0.5845, 0.6066, "Western return"),
    },
    confidence = "high",
}

local GORGROND_FLYTRAP_ROUTE = {
    id = "warlords-gorgrond-flytrap-central-jungle-loop",
    source = "Retail Wowhead object page, WoD gathering overview, and wow-professions Gorgrond Flytrap guide",
    sourceUrls = {
        "https://www.wowhead.com/object=228573/gorgrond-flytrap",
        WOD_GATHERING_GUIDE,
        "https://www.wow-professions.com/farming/gorgrond-flytrap-farming",
    },
    mapName = "Gorgrond",
    location = "Central and southern Gorgrond jungle herb loop",
    routeType = "herbalism-loop",
    density = "High",
    dropDifficulty = "Dense but mob-heavy compared with Frostfire and Shadowmoon.",
    tips = {
        "Stay in central and southern Gorgrond where plant density is highest.",
        "Use this route when Flytrap is needed for alchemy or daily cooldowns.",
    },
    coords = {
        C(0.4380, 0.4080, "Central jungle west"),
        C(0.5260, 0.4540, "Central jungle"),
        C(0.6120, 0.5420, "East jungle"),
        C(0.5080, 0.6480, "South jungle"),
        C(0.4080, 0.6120, "West jungle return"),
    },
    confidence = "high",
}

local SHADOWMOON_STARFLOWER_ROUTE = {
    id = "warlords-starflower-shadowmoon-imported-route",
    source = "Retail Wowhead WoD gathering overview, wow-professions Starflower guide, and Artisans of Azeroth Shadowmoon herb pins",
    sourceUrls = {
        ItemUrl(109127),
        WOD_GATHERING_GUIDE,
        "https://www.wow-professions.com/farming/starflower-farming",
        AOA_ROUTE_SOURCE,
    },
    mapName = "Shadowmoon Valley (Draenor)",
    location = "Shadowmoon Valley grove and field herb route",
    routeType = "herbalism-loop",
    density = "High",
    dropDifficulty = "Good Alliance-side route with low-to-medium mob pressure.",
    tips = {
        "Run wide loops through groves and field edges rather than mountain interiors.",
        "This route also covers Frostweed overlap mentioned in the retail gathering guide.",
    },
    coords = {
        C(0.1990, 0.1260, "Northwest grove start"),
        C(0.2608, 0.1344, "Northwest field"),
        C(0.2940, 0.3228, "Elodor approach"),
        C(0.3857, 0.2814, "Elodor grove"),
        C(0.4178, 0.2424, "North central grove"),
        C(0.4338, 0.3447, "Central grove"),
        C(0.3820, 0.3337, "Central return"),
        C(0.3944, 0.4178, "Central field"),
        C(0.4067, 0.4875, "South central field"),
        C(0.3739, 0.5177, "West return"),
        C(0.3134, 0.4422, "Western field"),
        C(0.2677, 0.3301, "Northwest return"),
        C(0.2349, 0.2557, "Northwest pass"),
        C(0.2078, 0.3035, "Return grove"),
    },
    confidence = "high",
}

local NAGRAND_ARROWBLOOM_ROUTE = {
    id = "warlords-nagrand-arrowbloom-imported-route",
    source = "Retail Wowhead WoD gathering overview, wow-professions Nagrand Arrowbloom guide, and Artisans of Azeroth Nagrand herb pins",
    sourceUrls = {
        ItemUrl(109128),
        WOD_GATHERING_GUIDE,
        "https://www.wow-professions.com/farming/nagrand-arrowbloom-farming",
        AOA_ROUTE_SOURCE,
    },
    mapName = "Nagrand (Draenor)",
    location = "Nagrand plains and tree-line Arrowbloom route",
    routeType = "herbalism-loop",
    density = "High",
    dropDifficulty = "Strong route, but Nagrand beast density can slow low-geared characters.",
    tips = {
        "Pick around tree lines, river edges, and open plains instead of bare rocky ridges.",
        "Pair with meat or hide farming if material prices favor mixed routes.",
    },
    coords = {
        C(0.8944, 0.4615, "Eastern plains start"),
        C(0.7546, 0.4094, "Ring-side plains"),
        C(0.7505, 0.4730, "East plains waterline"),
        C(0.6529, 0.5480, "Central river edge"),
        C(0.6389, 0.4865, "Central plains"),
        C(0.5850, 0.4894, "West central tree line"),
        C(0.6212, 0.4169, "North central plains"),
        C(0.6597, 0.3560, "North plains"),
        C(0.5833, 0.2491, "Northwest plains"),
        C(0.6557, 0.2238, "Northern tree line"),
        C(0.6779, 0.1593, "Far north plains"),
        C(0.7468, 0.1820, "Northeast plains"),
        C(0.7313, 0.2916, "East return"),
        C(0.7373, 0.3592, "Return plains"),
    },
    confidence = "high",
}

local TALADOR_ORCHID_ROUTE = {
    id = "warlords-talador-orchid-imported-route",
    source = "Retail Wowhead WoD gathering overview, wow-professions Talador Orchid guide, and Artisans of Azeroth Talador herb pins",
    sourceUrls = {
        ItemUrl(109129),
        WOD_GATHERING_GUIDE,
        "https://www.wow-professions.com/farming/talador-orchid-farming",
        AOA_ROUTE_SOURCE,
    },
    mapName = "Talador",
    location = "Talador waterline, meadow, and Auchindoun approach herb route",
    routeType = "herbalism-loop",
    density = "High",
    dropDifficulty = "Good route with mob pockets around ruins and Auchindoun approaches.",
    tips = {
        "Keep close to rivers, pools, and meadow edges.",
        "Avoid deep Shattrath pulls unless also farming cloth or green drops.",
    },
    coords = {
        C(0.6571, 0.1330, "Northern meadow start"),
        C(0.7170, 0.1878, "North ridge meadow"),
        C(0.7287, 0.2852, "Northeast waterline"),
        C(0.7813, 0.3845, "East waterline"),
        C(0.7922, 0.5215, "East river bend"),
        C(0.7946, 0.6037, "Southeast waterline"),
        C(0.7602, 0.6308, "Southeast return"),
        C(0.7511, 0.5199, "Central east return"),
        C(0.7237, 0.4990, "Central waterline"),
        C(0.7161, 0.5896, "South central bend"),
        C(0.6616, 0.5568, "Central meadow"),
        C(0.6957, 0.5404, "Central loop"),
        C(0.6485, 0.4793, "West central waterline"),
        C(0.6232, 0.5108, "Western return"),
    },
    confidence = "high",
}

local TANAAN_HERB_ROUTE = {
    id = "warlords-herbs-tanaan-felblight-imported-route",
    source = "Retail Wowhead Felblight and WoD gathering pages plus Artisans of Azeroth Tanaan herb pins",
    sourceUrls = {
        ItemUrl(127759),
        WOD_GATHERING_GUIDE,
        AOA_ROUTE_SOURCE,
    },
    mapName = "Tanaan Jungle",
    location = "Tanaan Jungle mixed-herb route for Draenor herbs and Felblight chances",
    routeType = "herbalism-loop",
    density = "Medium to high",
    dropDifficulty = "Tanaan herb routes are more dangerous, but they are the correct Felblight-era herbalism target.",
    tips = {
        "Use Tanaan for Felblight chances; use the original zone herb routes for easier bulk herb farming.",
        "Retail Wowhead notes Withered Herb nodes can contain Draenor herbs and Felblight.",
    },
    coords = {
        C(0.3852, 0.4269, "Central west Tanaan herb"),
        C(0.3569, 0.3183, "Northwest herb"),
        C(0.3878, 0.3662, "North central herb"),
        C(0.4135, 0.3550, "Central herb"),
        C(0.4332, 0.3900, "Central loop"),
        C(0.4855, 0.3722, "East central herb"),
        C(0.4814, 0.3078, "Northeast herb"),
        C(0.5258, 0.2650, "Northern pass"),
        C(0.5276, 0.1966, "Throne approach"),
        C(0.6326, 0.2041, "Far northeast herb"),
        C(0.5936, 0.2288, "Northeast return"),
        C(0.5602, 0.2366, "Northern return"),
        C(0.5637, 0.3097, "East central return"),
        C(0.5409, 0.3633, "Central return"),
    },
    confidence = "high",
}

local function RegisterHerbalismMaterial(itemID, itemName, category, spots, summary)
    Register({
        itemID = itemID,
        itemName = itemName,
        expansion = "warlords",
        professions = { "herbalism", "alchemy", "inscription" },
        category = category,
        sourceUrls = {
            ItemUrl(itemID),
            WOD_GATHERING_GUIDE,
            AOA_ROUTE_SOURCE,
        },
        summary = summary,
        spots = spots,
    })
end

RegisterHerbalismMaterial(109124, "Frostweed", "Herb", { FROSTFIRE_FROSTWEED_ROUTE, SHADOWMOON_STARFLOWER_ROUTE }, "Frostfire Ridge and Shadowmoon Valley zone herb; farm Frostfire snowfields for the cleanest loop.")
RegisterHerbalismMaterial(109125, "Fireweed", "Herb", { FROSTFIRE_FIREWEED_ROUTE }, "Frostfire Ridge lava herb; farm lava-pool chains rather than generic herb paths.")
RegisterHerbalismMaterial(109126, "Gorgrond Flytrap", "Herb", { GORGROND_FLYTRAP_ROUTE }, "Gorgrond and Spires herb; central Gorgrond remains the best dense outdoor target.")
RegisterHerbalismMaterial(109127, "Starflower", "Herb", { SHADOWMOON_STARFLOWER_ROUTE }, "Shadowmoon Valley zone herb from open groves and field edges.")
RegisterHerbalismMaterial(109128, "Nagrand Arrowbloom", "Herb", { NAGRAND_ARROWBLOOM_ROUTE }, "Nagrand zone herb from plains, tree lines, and water edges.")
RegisterHerbalismMaterial(109129, "Talador Orchid", "Herb", { TALADOR_ORCHID_ROUTE }, "Talador zone herb from central waterlines and meadow routes.")

RegisterHerbalismMaterial(109624, "Broken Frostweed Stem", "Herb Fragment", { FROSTFIRE_FROSTWEED_ROUTE, SHADOWMOON_STARFLOWER_ROUTE }, "Low-skill herbalism fragment from Frostweed nodes; combine ten into Frostweed.")
RegisterHerbalismMaterial(109625, "Broken Fireweed Stem", "Herb Fragment", { FROSTFIRE_FIREWEED_ROUTE }, "Low-skill herbalism fragment from Fireweed nodes; combine ten into Fireweed.")
RegisterHerbalismMaterial(109626, "Gorgrond Flytrap Ichor", "Herb Fragment", { GORGROND_FLYTRAP_ROUTE }, "Low-skill herbalism fragment from Gorgrond Flytrap nodes; combine ten into Gorgrond Flytrap.")
RegisterHerbalismMaterial(109627, "Starflower Petal", "Herb Fragment", { SHADOWMOON_STARFLOWER_ROUTE }, "Low-skill herbalism fragment from Starflower nodes; combine ten into Starflower.")
RegisterHerbalismMaterial(109628, "Nagrand Arrowbloom Petal", "Herb Fragment", { NAGRAND_ARROWBLOOM_ROUTE }, "Low-skill herbalism fragment from Nagrand Arrowbloom nodes; combine ten into Nagrand Arrowbloom.")
RegisterHerbalismMaterial(109629, "Talador Orchid Petal", "Herb Fragment", { TALADOR_ORCHID_ROUTE }, "Low-skill herbalism fragment from Talador Orchid nodes; combine ten into Talador Orchid.")
RegisterHerbalismMaterial(116053, "Draenic Seeds", "Seed", { FROSTFIRE_FROSTWEED_ROUTE, NAGRAND_ARROWBLOOM_ROUTE, TALADOR_ORCHID_ROUTE, TANAAN_HERB_ROUTE }, "Draenor herb-gathering byproduct from outdoor herb nodes and Withered Herb nodes in Tanaan.")
