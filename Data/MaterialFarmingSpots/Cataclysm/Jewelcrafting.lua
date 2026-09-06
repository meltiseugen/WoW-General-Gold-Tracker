local _, NS = ...
local Register = NS.RegisterMaterialFarmingSpot

local function C(x, y, label)
    return { x = x, y = y, label = label }
end

local function ItemUrl(itemID)
    return "https://www.wowhead.com/item=" .. tostring(itemID)
end

local OBSIDIUM_PROSPECTING_SPOT = {
    id = "cataclysm-gems-shimmering-expanse-obsidium-prospecting",
    source = "wow-professions Cataclysm prospecting table, retail Wowhead Obsidium node pins, and Artisans of Azeroth catalog cross-check",
    sourceUrls = {
        "https://www.wow-professions.com/cataclysm/prospecting-table-cataclysm-classic",
        "https://www.wowhead.com/object=202736/obsidium-deposit",
        "https://www.wowhead.com/spell=31252/prospecting",
        "https://artisansofazeroth.com/materials/obsidium-ore/",
    },
    mapName = "Shimmering Expanse",
    location = "Shimmering Expanse Obsidium route for uncommon Cataclysm gems",
    routeType = "prospecting-input-route",
    density = "High for Obsidium input",
    dropDifficulty = "Prospecting output is RNG; Obsidium is best for high-volume uncommon gem input.",
    tips = {
        "Prospect only when the combined gem and byproduct value beats raw Obsidium Ore.",
        "Keep the route tight in the high-density Shimmering Expanse section.",
    },
    coords = {
        C(0.356, 0.698, "Northwest Shimmering Expanse Obsidium pin"),
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
}

local ELEMENTIUM_PROSPECTING_SPOT = {
    id = "cataclysm-gems-twilight-highlands-elementium-prospecting",
    source = "wow-professions Cataclysm prospecting table, retail Wowhead Elementium/Pyrite node pins, and Artisans of Azeroth catalog cross-check",
    sourceUrls = {
        "https://www.wow-professions.com/cataclysm/prospecting-table-cataclysm-classic",
        "https://www.wowhead.com/object=202738/elementium-vein",
        "https://www.wowhead.com/object=202737/pyrite-deposit",
        "https://www.wowhead.com/spell=31252/prospecting",
        "https://artisansofazeroth.com/materials/elementium-ore/",
    },
    mapName = "Twilight Highlands",
    location = "Twilight Highlands Elementium route for rare Cataclysm gems",
    routeType = "prospecting-input-route",
    density = "High for Elementium input",
    dropDifficulty = "Rare gem output is RNG; Elementium has better rare-gem odds than Obsidium but still needs high volume.",
    tips = {
        "Use Elementium when rare gems are the value target.",
        "Check raw Elementium, rare gems, and uncommon jewelry shuffle value before prospecting.",
        "Mine Pyrite replacements as bonus value while staying on the Elementium route.",
    },
    coords = {
        C(0.172, 0.567, "Western Twilight Highlands Elementium pin"),
        C(0.178, 0.633, "Western ridge Elementium pin"),
        C(0.181, 0.570, "Northwest ridge Elementium pin"),
        C(0.280, 0.300, "Northwest Elementium ridge"),
        C(0.400, 0.230, "Northern Elementium ridge"),
        C(0.560, 0.260, "Thundermar ridge"),
        C(0.680, 0.360, "Eastern Elementium ridge"),
        C(0.640, 0.600, "Southeast Elementium return"),
        C(0.450, 0.720, "Southern highlands"),
        C(0.260, 0.560, "Western return"),
    },
    confidence = "high",
}

local function RegisterGem(itemID, itemName, spot, summary)
    Register({
        itemID = itemID,
        itemName = itemName,
        expansion = "cataclysm",
        professions = { "jewelcrafting" },
        category = "Gem",
        sourceUrls = {
            ItemUrl(itemID),
            "https://www.wow-professions.com/cataclysm/prospecting-table-cataclysm-classic",
            "https://www.wowhead.com/spell=31252/prospecting",
        },
        summary = summary,
        spots = { spot },
    })
end

RegisterGem(52177, "Carnelian", OBSIDIUM_PROSPECTING_SPOT, "Uncommon Cataclysm red gem produced by prospecting Obsidium, Elementium, or Pyrite.")
RegisterGem(52178, "Zephyrite", OBSIDIUM_PROSPECTING_SPOT, "Uncommon Cataclysm blue gem produced by prospecting Obsidium, Elementium, or Pyrite.")
RegisterGem(52179, "Alicite", OBSIDIUM_PROSPECTING_SPOT, "Uncommon Cataclysm yellow gem produced by prospecting Obsidium, Elementium, or Pyrite.")
RegisterGem(52180, "Nightstone", OBSIDIUM_PROSPECTING_SPOT, "Uncommon Cataclysm purple gem produced by prospecting Obsidium, Elementium, or Pyrite.")
RegisterGem(52181, "Hessonite", OBSIDIUM_PROSPECTING_SPOT, "Uncommon Cataclysm orange gem produced by prospecting Obsidium, Elementium, or Pyrite.")
RegisterGem(52182, "Jasper", OBSIDIUM_PROSPECTING_SPOT, "Uncommon Cataclysm green gem produced by prospecting Obsidium, Elementium, or Pyrite.")
RegisterGem(52190, "Inferno Ruby", ELEMENTIUM_PROSPECTING_SPOT, "Rare Cataclysm red gem best treated as Elementium/Pyrite prospecting output.")
RegisterGem(52191, "Ocean Sapphire", ELEMENTIUM_PROSPECTING_SPOT, "Rare Cataclysm blue gem best treated as Elementium/Pyrite prospecting output.")
RegisterGem(52192, "Dream Emerald", ELEMENTIUM_PROSPECTING_SPOT, "Rare Cataclysm green gem best treated as Elementium/Pyrite prospecting output.")
RegisterGem(52193, "Ember Topaz", ELEMENTIUM_PROSPECTING_SPOT, "Rare Cataclysm orange gem best treated as Elementium/Pyrite prospecting output.")
RegisterGem(52194, "Demonseye", ELEMENTIUM_PROSPECTING_SPOT, "Rare Cataclysm purple gem best treated as Elementium/Pyrite prospecting output.")
RegisterGem(52195, "Amberjewel", ELEMENTIUM_PROSPECTING_SPOT, "Rare Cataclysm yellow gem best treated as Elementium/Pyrite prospecting output.")
