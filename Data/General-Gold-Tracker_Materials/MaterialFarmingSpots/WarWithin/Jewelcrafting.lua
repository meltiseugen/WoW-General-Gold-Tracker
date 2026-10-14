local _, NS = ...
local Register = NS.RegisterMaterialFarmingSpot
local H = NS.MaterialFarmingSpotHelpers

local function ItemUrl(itemID)
    return "https://www.wowhead.com/item=" .. tostring(itemID)
end

local PROSPECTING_SOURCES = {
    "https://www.method.gg/guides/the-war-within-ore-prospecting-guide",
    "https://www.wowhead.com/guide/the-war-within/professions/jewelcrafting-overview",
}

local function SourceUrls(itemID)
    return {
        ItemUrl(itemID),
        PROSPECTING_SOURCES[1],
        PROSPECTING_SOURCES[2],
    }
end

local function ProspectingSpot(baseSpot, targetText)
    return {
        id = baseSpot.id .. "-prospecting-feed",
        source = baseSpot.source .. ", cross-checked against Method prospecting outcomes",
        sourceUrls = {
            baseSpot.sourceUrls[1],
            baseSpot.sourceUrls[2],
            PROSPECTING_SOURCES[1],
        },
        mapName = baseSpot.mapName,
        location = baseSpot.location,
        routeType = "prospecting-ore-feed",
        density = baseSpot.density,
        dropDifficulty = targetText,
        tips = {
            "Mine this route for ore, then prospect the ore on a Jewelcrafter.",
            "Higher ore quality improves prospecting output.",
            "Null Stone can produce any of the baseline rare gems, but it is itself a rare mining side gather.",
        },
        coords = baseSpot.coords,
        confidence = baseSpot.confidence,
    }
end

local ALL_ORE_FEED_SPOTS = {
    ProspectingSpot(H.TWW_MINING_SPOTS[1], "Bismuth, Ironclaw Ore, and Null Stone feed prospecting byproducts."),
    ProspectingSpot(H.TWW_MINING_SPOTS[2], "Ironclaw Ore and Bismuth feed prospecting byproducts."),
    ProspectingSpot(H.TWW_MINING_SPOTS[3], "Aqirite and Bismuth feed prospecting byproducts."),
    ProspectingSpot(H.TWW_MINING_SPOTS[4], "Aqirite and Null Stone feed prospecting byproducts."),
}

local AQIRITE_FEED_SPOTS = {
    ProspectingSpot(H.TWW_MINING_SPOTS[3], "Method confirms Aqirite can yield Ambivalent Amber, Stunning Sapphire, and Extravagant Emerald."),
    ProspectingSpot(H.TWW_MINING_SPOTS[4], "Method confirms Aqirite can yield Ambivalent Amber, Stunning Sapphire, and Extravagant Emerald."),
}

local IRONCLAW_FEED_SPOTS = {
    ProspectingSpot(H.TWW_MINING_SPOTS[1], "Method confirms Ironclaw Ore can yield Ambivalent Amber, Radiant Ruby, and Ostentatious Onyx."),
    ProspectingSpot(H.TWW_MINING_SPOTS[2], "Method confirms Ironclaw Ore can yield Ambivalent Amber, Radiant Ruby, and Ostentatious Onyx."),
}

local function RegisterProspectingItem(itemID, itemName, category, summary, spots)
    Register({
        itemID = itemID,
        itemName = itemName,
        expansion = "warWithin",
        professions = { "jewelcrafting", "mining" },
        category = category,
        sourceUrls = SourceUrls(itemID),
        summary = summary,
        spots = spots,
    })
end

RegisterProspectingItem(213398, "Handful of Pebbles", "Prospecting",
    "Common War Within prospecting byproduct from Algari ore. Farm dense ore routes, then prospect.",
    ALL_ORE_FEED_SPOTS)

RegisterProspectingItem(213399, "Glittering Glass", "Prospecting",
    "Common War Within prospecting byproduct from Algari ore. Farm dense ore routes, then prospect.",
    ALL_ORE_FEED_SPOTS)

RegisterProspectingItem(212498, "Ambivalent Amber", "Gem",
    "Uncommon War Within prospecting gem. Method lists it from Bismuth, Aqirite, Ironclaw Ore, and Null Stone.",
    ALL_ORE_FEED_SPOTS)

RegisterProspectingItem(212508, "Stunning Sapphire", "Gem",
    "Rare War Within prospecting gem. Method lists it from Aqirite or Null Stone before specialization changes.",
    AQIRITE_FEED_SPOTS)

RegisterProspectingItem(212505, "Extravagant Emerald", "Gem",
    "Rare War Within prospecting gem. Method lists it from Aqirite or Null Stone before specialization changes.",
    AQIRITE_FEED_SPOTS)

RegisterProspectingItem(212495, "Radiant Ruby", "Gem",
    "Rare War Within prospecting gem. Method lists it from Ironclaw Ore or Null Stone before specialization changes.",
    IRONCLAW_FEED_SPOTS)

RegisterProspectingItem(212511, "Ostentatious Onyx", "Gem",
    "Rare War Within prospecting gem. Method lists it from Ironclaw Ore or Null Stone before specialization changes.",
    IRONCLAW_FEED_SPOTS)
