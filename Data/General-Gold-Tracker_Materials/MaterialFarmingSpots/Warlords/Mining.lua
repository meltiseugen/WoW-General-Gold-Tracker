local _, NS = ...
local Register = NS.RegisterMaterialFarmingSpot

local function C(x, y, label)
    return { x = x, y = y, label = label }
end

local function ItemUrl(itemID)
    return "https://www.wowhead.com/item=" .. tostring(itemID)
end

local AOA_ROUTE_SOURCE = "https://artisansofazeroth.com/zone-atlas/"

local TALADOR_ORE_ROUTE = {
    id = "warlords-ore-talador-central-ridge-imported-route",
    source = "Retail Wowhead WoD gathering overview, wow-professions True Iron guide, and Artisans of Azeroth retail route pins",
    sourceUrls = {
        "https://www.wowhead.com/guide/professions/wod/gathering-professions-overview",
        "https://www.wow-professions.com/farming/true-iron-ore-farming",
        "https://artisansofazeroth.com/materials/true-iron-ore/",
        AOA_ROUTE_SOURCE,
    },
    mapName = "Talador",
    location = "Central Talador ore route through ridge and ruin node clusters",
    routeType = "mining-loop",
    density = "High",
    dropDifficulty = "Good node density with higher mob pressure than Frostfire or Shadowmoon.",
    tips = {
        "Follow ridgelines and ruin edges; long flat crossings are lower value.",
        "Mine both True Iron and Blackrock nodes because Draenic Stone and low-skill fragments share the same outdoor node circuit.",
        "These pins sample the Artisans of Azeroth retail route import string so the addon can later reconstruct a map route.",
    },
    coords = {
        C(0.5312, 0.4492, "Central Talador ore start"),
        C(0.5509, 0.4891, "Central ridge bend"),
        C(0.4905, 0.5298, "Western ruin edge"),
        C(0.4933, 0.5629, "Western lower ridge"),
        C(0.4840, 0.6019, "Southwest ridge"),
        C(0.5241, 0.6006, "South central ridge"),
        C(0.5292, 0.5521, "Central return"),
        C(0.5467, 0.5470, "Central node pair"),
        C(0.5629, 0.6323, "Southeast ridge"),
        C(0.5976, 0.6206, "Southeast turn"),
        C(0.5937, 0.5429, "East central ridge"),
        C(0.6258, 0.5264, "Eastern ruin edge"),
        C(0.6749, 0.5468, "Eastern loop"),
        C(0.6408, 0.6241, "Eastern return"),
    },
    confidence = "high",
}

local NAGRAND_ORE_ROUTE = {
    id = "warlords-ore-nagrand-ridge-imported-route",
    source = "Retail Wowhead WoD gathering overview, wow-professions ore guides, and Artisans of Azeroth retail Nagrand ore pins",
    sourceUrls = {
        "https://www.wowhead.com/guide/professions/wod/gathering-professions-overview",
        "https://www.wow-professions.com/farming/blackrock-ore-farming",
        "https://www.wow-professions.com/farming/true-iron-ore-farming",
        AOA_ROUTE_SOURCE,
    },
    mapName = "Nagrand (Draenor)",
    location = "Southern and eastern Nagrand mountain-edge ore loop",
    routeType = "mining-loop",
    density = "High",
    dropDifficulty = "High-value loop, but Nagrand beasts and elites can slow fresh levelers.",
    tips = {
        "Use this when Talador is crowded or when pairing ore with Nagrand leather/meat farms.",
        "Stay on mountain shoulders and cave mouths; open plains are less consistent for mining nodes.",
    },
    coords = {
        C(0.6695, 0.4588, "Central east ridge"),
        C(0.7055, 0.4920, "East ridge bend"),
        C(0.7074, 0.5218, "Eastern slope"),
        C(0.7197, 0.5814, "Southeast ridge"),
        C(0.7699, 0.6065, "South ridge fork"),
        C(0.7765, 0.6536, "South ridge"),
        C(0.8303, 0.6808, "Southeast high ridge"),
        C(0.8889, 0.7159, "Far southeast turn"),
        C(0.8207, 0.7139, "South return"),
        C(0.7973, 0.7343, "Southwest bend"),
        C(0.7802, 0.6953, "Southern pass"),
        C(0.7480, 0.6778, "South central ridge"),
        C(0.7368, 0.7547, "Lower south spur"),
        C(0.7080, 0.6625, "Return ridge"),
    },
    confidence = "high",
}

local TANAAN_ORE_ROUTE = {
    id = "warlords-ore-tanaan-felblight-imported-route",
    source = "Retail Wowhead Felblight and WoD gathering pages plus Artisans of Azeroth Tanaan ore pins",
    sourceUrls = {
        "https://www.wowhead.com/item=127759/felblight",
        "https://www.wowhead.com/guide/professions/wod/gathering-professions-overview",
        AOA_ROUTE_SOURCE,
    },
    mapName = "Tanaan Jungle",
    location = "Tanaan Jungle ore route for ore plus Felblight chances",
    routeType = "mining-loop",
    density = "Medium to high",
    dropDifficulty = "Tanaan mobs are denser and hit harder, but this is the correct mining route when Felblight is part of the goal.",
    tips = {
        "Use this route for Felblight-era value, not as the easiest leveling ore route.",
        "Mine every node; retail Wowhead confirms Tanaan mining nodes can also yield Felblight.",
    },
    coords = {
        C(0.4300, 0.4812, "Central Tanaan ore start"),
        C(0.5003, 0.4923, "Central ridge"),
        C(0.5136, 0.4481, "Central north ridge"),
        C(0.5660, 0.4739, "Eastern ridge"),
        C(0.5336, 0.4038, "North central ridge"),
        C(0.5865, 0.1930, "Throne approach"),
        C(0.5250, 0.2010, "Northern pass"),
        C(0.5369, 0.2705, "Northern return"),
        C(0.4785, 0.3176, "Central west ridge"),
        C(0.5217, 0.3304, "Central node"),
        C(0.4931, 0.3721, "Central loop"),
        C(0.4657, 0.4106, "Western ridge"),
        C(0.4237, 0.4142, "West return"),
        C(0.4194, 0.3431, "Northwest return"),
    },
    confidence = "high",
}

local DRAENOR_ORE_ROUTES = {
    TALADOR_ORE_ROUTE,
    NAGRAND_ORE_ROUTE,
    TANAAN_ORE_ROUTE,
}

local function RegisterMiningMaterial(itemID, itemName, category, summary)
    Register({
        itemID = itemID,
        itemName = itemName,
        expansion = "warlords",
        professions = { "mining" },
        category = category,
        sourceUrls = {
            ItemUrl(itemID),
            "https://www.wowhead.com/guide/professions/wod/gathering-professions-overview",
            "https://www.wow-professions.com/farming/true-iron-ore-farming",
            AOA_ROUTE_SOURCE,
        },
        summary = summary,
        spots = DRAENOR_ORE_ROUTES,
    })
end

RegisterMiningMaterial(109118, "Blackrock Ore", "Ore", "Common Draenor ore farmed from outdoor Blackrock and True Iron node circuits.")
RegisterMiningMaterial(109119, "True Iron Ore", "Ore", "Common Draenor ore farmed from outdoor True Iron and Blackrock node circuits.")
RegisterMiningMaterial(109991, "True Iron Nugget", "Ore Fragment", "Low-skill mining fragment from Draenor True Iron nodes; combine ten into True Iron Ore.")
RegisterMiningMaterial(109992, "Blackrock Fragment", "Ore Fragment", "Low-skill mining fragment from Draenor Blackrock nodes; combine ten into Blackrock Ore.")
RegisterMiningMaterial(115508, "Draenic Stone", "Stone", "Draenor stone byproduct from mining outdoor ore nodes and garrison mine nodes.")
