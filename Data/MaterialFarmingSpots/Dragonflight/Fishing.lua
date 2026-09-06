local _, NS = ...
local Register = NS.RegisterMaterialFarmingSpot

local function C(x, y, label)
    return { x = x, y = y, label = label }
end

local function ItemUrl(itemID)
    return "https://www.wowhead.com/item=" .. tostring(itemID)
end

local WAKING_SHORES_WATERFALL_FRESHWATER = {
    id = "dragonflight-waking-shores-waterfall-freshwater-pools",
    source = "Wowhead Scalebelly Mackerel, Thousandbite Piranha, and Temporal Dragonhead comments",
    sourceUrls = {
        "https://www.wowhead.com/item=194730/scalebelly-mackerel",
        "https://www.wowhead.com/item=194966/thousandbite-piranha",
        "https://www.wowhead.com/item=194969/temporal-dragonhead",
    },
    mapName = "The Waking Shores",
    location = "Freshwater pool at the base of the waterfall",
    routeType = "freshwater-fishing-pool",
    density = "Localized",
    dropDifficulty = "Easy fishing spot with a mixed freshwater table.",
    tips = {
        "Use the 63.0, 68.5 pool when Scalebelly Mackerel, Temporal Dragonhead, and Thousandbite Piranha values overlap.",
        "Fish nearby freshwater pools while waiting for pool respawns.",
        "Use fishing bonuses and lures when targeting a specific fish.",
    },
    coords = {
        C(0.630, 0.685, "Waterfall freshwater pool"),
    },
    confidence = "high",
}

local AZURE_SPAN_ISKAARA_SALTWATER = {
    id = "dragonflight-azure-span-iskaara-saltwater-coast",
    source = "Wowhead Aileron Seamoth and Cerulean Spinefish item pages plus fishing comments",
    sourceUrls = {
        "https://www.wowhead.com/item=194967/aileron-seamoth",
        "https://www.wowhead.com/item=194968/cerulean-spinefish",
        "https://www.wowhead.com/item=194970/islefin-dorado",
        "https://www.wowhead.com/item=197742/ribbed-mollusk-meat",
    },
    mapName = "The Azure Span",
    location = "Iskaara coast and open saltwater",
    routeType = "saltwater-fishing",
    density = "Medium",
    dropDifficulty = "Easy. Saltwater fish and Dull Spined Clams are RNG from open water and pools.",
    tips = {
        "Use the Iskaara coast for Aileron Seamoth, Cerulean Spinefish, and clam checks.",
        "Ribbed Mollusk Meat comes through Dull Spined Clams; open water can be better than chasing fish pools.",
        "Move along the coast if pools are exhausted or heavily contested.",
    },
    coords = {
        C(0.130, 0.480, "Iskaara open coast"),
        C(0.168, 0.300, "Northwest coast"),
        C(0.220, 0.281, "Coastal pool check"),
        C(0.234, 0.267, "Coastal pool return"),
    },
    confidence = "medium",
}

local AZURE_SPAN_GRIMTUSK_DORADO_POND = {
    id = "dragonflight-azure-span-grimtusk-dorado-pond",
    source = "Wowhead Islefin Dorado comments",
    sourceUrls = {
        "https://www.wowhead.com/item=194970/islefin-dorado",
    },
    mapName = "The Azure Span",
    location = "Grimtusk's Hideaway pond",
    routeType = "freshwater-fishing-hole",
    density = "Localized",
    dropDifficulty = "Weather and pool state can affect catch mix; use Dorado lures when available.",
    tips = {
        "Fish the large pond at 58,34 when targeting Islefin Dorado.",
        "Use Islefin Dorado Lures from Tuskarr content when available.",
        "Move back to coastal pools if the pond is not producing Dorado.",
    },
    coords = {
        C(0.580, 0.340, "Grimtusk's Hideaway pond"),
    },
    confidence = "medium",
}

local function RegisterFish(itemID, itemName, spots, summary)
    Register({
        itemID = itemID,
        itemName = itemName,
        expansion = "dragonflight",
        professions = { "fishing", "cooking" },
        category = "Fish",
        sourceUrls = { ItemUrl(itemID) },
        summary = summary,
        spots = spots,
    })
end

RegisterFish(194730, "Scalebelly Mackerel", {
    WAKING_SHORES_WATERFALL_FRESHWATER,
}, "Dragonflight freshwater fish from pools and open water; the Waking Shores waterfall pool is comment-confirmed.")

RegisterFish(194966, "Thousandbite Piranha", {
    WAKING_SHORES_WATERFALL_FRESHWATER,
}, "Dragonflight freshwater fish from Dragon Isles rivers and pools.")

RegisterFish(194967, "Aileron Seamoth", {
    AZURE_SPAN_ISKAARA_SALTWATER,
}, "Dragonflight saltwater fish; fish coastal Azure Span pools and open water.")

RegisterFish(194968, "Cerulean Spinefish", {
    AZURE_SPAN_ISKAARA_SALTWATER,
}, "Dragonflight saltwater fish; fish coastal Azure Span pools and open water.")

RegisterFish(194969, "Temporal Dragonhead", {
    WAKING_SHORES_WATERFALL_FRESHWATER,
}, "Dragonflight freshwater fish appearing in mixed freshwater pools.")

RegisterFish(194970, "Islefin Dorado", {
    AZURE_SPAN_GRIMTUSK_DORADO_POND,
    AZURE_SPAN_ISKAARA_SALTWATER,
}, "Dragonflight fish from Dragon Isles fishing holes and pools; Dorado lures improve targeting.")

Register({
    itemID = 197742,
    itemName = "Ribbed Mollusk Meat",
    expansion = "dragonflight",
    professions = { "fishing", "cooking" },
    category = "Meat",
    sourceUrls = { ItemUrl(197742) },
    summary = "Dragonflight cooking meat from Dull Spined Clams, commonly gathered while fishing open saltwater.",
    spots = { AZURE_SPAN_ISKAARA_SALTWATER },
})
