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

local TANAAN_HERB_FELBLIGHT_ROUTE = {
    id = "warlords-felblight-tanaan-mixed-herb-imported-route",
    source = "Retail Wowhead Felblight page, WoD gathering overview, and Artisans of Azeroth Tanaan mixed-herb route pins",
    sourceUrls = {
        ItemUrl(127759),
        WOD_GATHERING_GUIDE,
        AOA_ROUTE_SOURCE,
    },
    mapName = "Tanaan Jungle",
    location = "Tanaan Jungle mixed-herb route for Felblight chances",
    routeType = "felblight-herbalism-loop",
    density = "Medium to high",
    dropDifficulty = "Tanaan herb loops are more dangerous than original Draenor zone herb routes.",
    tips = {
        "Use Tanaan gathering when Felblight is part of the target; standard Draenor zone herbs are easier for bulk herbs alone.",
        "Retail Wowhead confirms Felblight can come from herbalism in Tanaan Jungle.",
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

local TANAAN_ORE_FELBLIGHT_ROUTE = {
    id = "warlords-felblight-tanaan-ore-imported-route",
    source = "Retail Wowhead Felblight page, WoD gathering overview, and Artisans of Azeroth Tanaan ore route pins",
    sourceUrls = {
        ItemUrl(127759),
        WOD_GATHERING_GUIDE,
        AOA_ROUTE_SOURCE,
    },
    mapName = "Tanaan Jungle",
    location = "Tanaan Jungle ore route for Felblight chances",
    routeType = "felblight-mining-loop",
    density = "Medium to high",
    dropDifficulty = "Ore route has heavy Tanaan mob pockets; use it for Felblight-era mining value.",
    tips = {
        "Mine every Tanaan node for Felblight chances.",
        "Use the original Draenor ore routes when Felblight is not needed.",
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

local TANAAN_SKINNING_FISHING_ROUTE = {
    id = "warlords-felblight-tanaan-fangrila-skinning-fishing-route",
    source = "Retail Wowhead Felblight page and WoD gathering overview comments favoring Tanaan skinning/fishing",
    sourceUrls = {
        ItemUrl(127759),
        WOD_GATHERING_GUIDE,
        "https://www.wowhead.com/zone=6723/tanaan-jungle",
    },
    mapName = "Tanaan Jungle",
    location = "Fang'rila saberon packs and nearby Tanaan water checks",
    routeType = "felblight-skinning-fishing-loop",
    density = "Medium",
    dropDifficulty = "Requires quick Tanaan kills or active pool scanning; best for characters already comfortable in Tanaan.",
    tips = {
        "Retail Wowhead comments call out skinning and fishing as strong Felblight approaches in Tanaan.",
        "Use the Fang'rila loop when you can kill and skin quickly; swap to pools if skinnable density is poor.",
    },
    coords = {
        C(0.5460, 0.7480, "Fang'rila west packs"),
        C(0.5840, 0.7620, "Blackfang Challenge Arena"),
        C(0.6320, 0.7280, "East saberon packs"),
    },
    confidence = "medium",
}

Register({
    itemID = 120945,
    itemName = "Primal Spirit",
    expansion = "warlords",
    professions = { "mining", "herbalism", "skinning", "alchemy", "blacksmithing", "engineering", "inscription", "jewelcrafting", "leatherworking", "tailoring" },
    category = "Reagent",
    sourceUrls = {
        ItemUrl(120945),
        "https://warcraft.wiki.gg/wiki/Primal_Spirit",
        WOD_GATHERING_GUIDE,
        AOA_ROUTE_SOURCE,
    },
    summary = "General Warlords profession reagent that can be gathered as a byproduct from Draenor outdoor resource farming; use dense herb/ore routes rather than treating it as a single mob drop.",
    spots = {
        TANAAN_HERB_FELBLIGHT_ROUTE,
        TANAAN_ORE_FELBLIGHT_ROUTE,
    },
})

Register({
    itemID = 127759,
    itemName = "Felblight",
    expansion = "warlords",
    professions = { "mining", "herbalism", "skinning", "fishing", "alchemy", "blacksmithing", "engineering", "inscription", "jewelcrafting", "leatherworking", "tailoring" },
    category = "Reagent",
    sourceUrls = {
        ItemUrl(127759),
        WOD_GATHERING_GUIDE,
        "https://warcraft.wiki.gg/wiki/Felblight",
        AOA_ROUTE_SOURCE,
    },
    summary = "Tanaan Jungle reagent obtained through mining, herbalism, skinning, or fishing; use Tanaan gathering routes and Fang'rila skinning/fishing checks.",
    spots = {
        TANAAN_HERB_FELBLIGHT_ROUTE,
        TANAAN_ORE_FELBLIGHT_ROUTE,
        TANAAN_SKINNING_FISHING_ROUTE,
    },
})

-- Sorcerous Air, Fire, Earth, and Water remain pending under the raw-material
-- rule: profession guides describe them primarily as work-order or cooldown
-- byproducts rather than coordinate-backed outdoor farming targets.
