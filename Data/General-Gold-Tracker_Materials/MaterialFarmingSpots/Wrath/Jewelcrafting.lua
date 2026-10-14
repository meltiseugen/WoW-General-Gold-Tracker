local _, NS = ...
local Register = NS.RegisterMaterialFarmingSpot

local function C(x, y, label)
    return { x = x, y = y, label = label }
end

local function ItemUrl(itemID)
    return "https://www.wowhead.com/item=" .. tostring(itemID)
end

local ROUTE_STRING_SOURCE = "https://xscarlife-gaming.com/farming-retail/"

local COBALT_PROSPECTING_SPOT = {
    id = "wrath-gems-howling-fjord-cobalt-prospecting-route",
    source = "wow-professions Cobalt guide, Wowhead Cobalt Deposit comments, and Wowhead prospecting data",
    sourceUrls = {
        "https://www.wow-professions.com/farming/cobalt-ore-farming",
        "https://www.wowhead.com/object=189978/cobalt-deposit",
        "https://www.wowhead.com/spell=49252/prospecting",
        ROUTE_STRING_SOURCE,
    },
    mapName = "Howling Fjord",
    location = "Howling Fjord Cobalt Ore route for prospecting uncommon Northrend gems",
    routeType = "prospecting-input-route",
    density = "High for Cobalt input",
    dropDifficulty = "Prospecting output is RNG; farm ore volume first and compare raw ore versus gem value.",
    tips = {
        "Follow the outer cliff and ridge loop used for Cobalt Ore.",
        "Prospect only after checking whether the uncommon gem basket beats raw Cobalt Ore.",
        "Keep rare gem results as bonus value, not the main target for Cobalt prospecting.",
    },
    coords = {
        C(0.2265, 0.1390, "Northwest Cobalt ridge"),
        C(0.3174, 0.1595, "West coast Cobalt ridge"),
        C(0.4069, 0.1377, "Northern Cobalt ridge"),
        C(0.5208, 0.1009, "North ridge cave Cobalt"),
        C(0.5586, 0.1475, "Utgarde Cobalt ridge"),
        C(0.6377, 0.2229, "Northeast Cobalt ridge"),
        C(0.7201, 0.4015, "Eastern Cobalt wall"),
        C(0.7328, 0.5441, "Southeast Cobalt loop"),
        C(0.6812, 0.7481, "Southern Cobalt ridge"),
        C(0.3714, 0.3049, "Western Cobalt return"),
        C(0.2062, 0.2418, "Northwest Cobalt return"),
    },
    confidence = "high",
}

local SARONITE_PROSPECTING_SPOT = {
    id = "wrath-gems-wintergrasp-saronite-titanium-prospecting-route",
    source = "wow-professions Saronite guide, Wowhead Saronite/Titanium route guide, and Wowhead prospecting data",
    sourceUrls = {
        "https://www.wow-professions.com/farming/saronite-ore-farming",
        "https://www.wowhead.com/guide/ore-deposit-best-farming-routes",
        "https://www.wowhead.com/spell=49252/prospecting",
        ROUTE_STRING_SOURCE,
    },
    mapName = "Wintergrasp",
    location = "Wintergrasp Saronite and Titanium route for prospecting rare Northrend gems",
    routeType = "prospecting-input-route",
    density = "High when accessible",
    dropDifficulty = "Rare gem output is RNG and depends on high ore volume; Wintergrasp access can interrupt farming.",
    tips = {
        "Mine every Saronite node while searching for Titanium replacements.",
        "Avoid the route during the Wintergrasp battle.",
        "Check raw Saronite, Titanium, and gem prices before prospecting large batches.",
    },
    coords = {
        C(0.3585, 0.1733, "Northwest Saronite wall"),
        C(0.4905, 0.3386, "North inner Saronite wall"),
        C(0.5736, 0.3223, "Northeast Saronite ridge"),
        C(0.7067, 0.2998, "Eastern Saronite wall"),
        C(0.8378, 0.4357, "Far east Saronite wall"),
        C(0.7383, 0.5894, "Southeast Saronite ridge"),
        C(0.8119, 0.7663, "Southern Saronite wall"),
        C(0.6779, 0.6587, "Lower central Saronite basin"),
        C(0.5808, 0.8096, "Southern Saronite basin"),
        C(0.4645, 0.4871, "West central Saronite ridge"),
        C(0.3127, 0.5794, "Western Saronite return"),
        C(0.1502, 0.6303, "Far southwest Saronite wall"),
        C(0.2132, 0.4002, "Northwest basin return"),
    },
    confidence = "high",
}

local function RegisterGem(itemID, itemName, rarity, spot, summary)
    Register({
        itemID = itemID,
        itemName = itemName,
        expansion = "wrath",
        professions = { "jewelcrafting" },
        category = "Gem",
        sourceUrls = {
            ItemUrl(itemID),
            "https://www.wowhead.com/spell=49252/prospecting",
        },
        summary = summary or (itemName .. " is a " .. rarity .. " Northrend gem produced by prospecting Wrath ores."),
        spots = { spot },
    })
end

RegisterGem(36917, "Bloodstone", "uncommon", COBALT_PROSPECTING_SPOT)
RegisterGem(36920, "Sun Crystal", "uncommon", COBALT_PROSPECTING_SPOT)
RegisterGem(36923, "Chalcedony", "uncommon", COBALT_PROSPECTING_SPOT)
RegisterGem(36926, "Shadow Crystal", "uncommon", COBALT_PROSPECTING_SPOT)
RegisterGem(36929, "Huge Citrine", "uncommon", COBALT_PROSPECTING_SPOT)
RegisterGem(36932, "Dark Jade", "uncommon", COBALT_PROSPECTING_SPOT)
RegisterGem(36918, "Scarlet Ruby", "rare", SARONITE_PROSPECTING_SPOT, "Scarlet Ruby is a rare Northrend gem best treated as Saronite/Titanium prospecting output.")
RegisterGem(36921, "Autumn's Glow", "rare", SARONITE_PROSPECTING_SPOT, "Autumn's Glow is a rare Northrend gem best treated as Saronite/Titanium prospecting output.")
RegisterGem(36924, "Sky Sapphire", "rare", SARONITE_PROSPECTING_SPOT, "Sky Sapphire is a rare Northrend gem best treated as Saronite/Titanium prospecting output.")
RegisterGem(36927, "Twilight Opal", "rare", SARONITE_PROSPECTING_SPOT, "Twilight Opal is a rare Northrend gem best treated as Saronite/Titanium prospecting output.")
RegisterGem(36930, "Monarch Topaz", "rare", SARONITE_PROSPECTING_SPOT, "Monarch Topaz is a rare Northrend gem best treated as Saronite/Titanium prospecting output.")
RegisterGem(36933, "Forest Emerald", "rare", SARONITE_PROSPECTING_SPOT, "Forest Emerald is a rare Northrend gem best treated as Saronite/Titanium prospecting output.")
