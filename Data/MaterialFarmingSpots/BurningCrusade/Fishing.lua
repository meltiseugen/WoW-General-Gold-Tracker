local _, NS = ...
local Register = NS.RegisterMaterialFarmingSpot

local function C(x, y, label)
    return { x = x, y = y, label = label }
end

local function RegisterFish(itemID, itemName, objectUrl, mapName, location, coords, tips)
    Register({
        itemID = itemID,
        itemName = itemName,
        expansion = "burningCrusade",
        professions = { "fishing", "cooking" },
        category = "Fish",
        researchStatus = "researched",
        sourceUrls = {
            "https://www.wowhead.com/item=" .. itemID,
            objectUrl,
        },
        summary = itemName .. " is farmed from Outland water or fishing schools. Pool routes are preferred when available because the map pins give predictable stops.",
        spots = {
            {
                id = "bc-fish-" .. itemID .. "-pool-route",
                source = "Wowhead fishing-school map pins and TBC fishing guides",
                sourceUrls = {
                    "https://www.wowhead.com/item=" .. itemID,
                    objectUrl,
                },
                mapName = mapName,
                location = location,
                routeType = "fishing-pool-route",
                density = "Pool-dependent",
                dropDifficulty = "Requires enough Fishing skill and patience; competition changes the real rate.",
                tips = tips,
                coords = coords,
                confidence = "medium",
            },
        },
    })
end

RegisterFish(27422, "Barbed Gill Trout", "https://www.wowhead.com/object=182954/brackish-mixed-school", "Zangarmarsh", "Open water and Brackish Mixed School route around Zangarmarsh lakes", {
    C(0.117, 0.491, "Western Zangarmarsh school"),
    C(0.237, 0.502, "West-central Zangarmarsh school"),
    C(0.509, 0.466, "Central Zangarmarsh school"),
    C(0.606, 0.411, "Eastern Zangarmarsh school"),
    C(0.774, 0.693, "Southeast Zangarmarsh school"),
}, { "Fish open water while moving between schools.", "Use this as general Outland cooking fish value rather than a strict rare-pool target." })

RegisterFish(27425, "Spotted Feltail", "https://www.wowhead.com/object=182954/brackish-mixed-school", "Zangarmarsh", "Brackish Mixed School route around Zangarmarsh", {
    C(0.117, 0.491, "Western Brackish Mixed School"),
    C(0.238, 0.374, "Northwest Brackish Mixed School"),
    C(0.472, 0.471, "Central Brackish Mixed School"),
    C(0.591, 0.566, "Eastern Brackish Mixed School"),
    C(0.725, 0.751, "Southeast Brackish Mixed School"),
}, { "Follow lake edges and fish every Brackish Mixed School.", "Pairs with Zangarian Sporefish and Barbed Gill Trout." })

RegisterFish(27429, "Zangarian Sporefish", "https://www.wowhead.com/object=182953/sporefish-school", "Zangarmarsh", "Sporefish School route around Zangarmarsh lakes", {
    C(0.117, 0.491, "Western Sporefish School"),
    C(0.211, 0.500, "West lake Sporefish School"),
    C(0.439, 0.372, "Central Sporefish School"),
    C(0.559, 0.580, "Eastern Sporefish School"),
    C(0.731, 0.648, "Southeast Sporefish School"),
}, { "Circle Zangarmarsh lakes and do not skip visible pools.", "Good paired with Ragveil and Flame Cap herbalism." })

RegisterFish(27435, "Figluster's Mudfish", "https://www.wowhead.com/object=182958/mudfish-school", "Nagrand", "Mudfish School route around Nagrand lakes", {
    C(0.252, 0.454, "Western Nagrand Mudfish School"),
    C(0.323, 0.467, "West-central Mudfish School"),
    C(0.474, 0.442, "Central Mudfish School"),
    C(0.538, 0.260, "Northern lake Mudfish School"),
    C(0.616, 0.341, "Eastern Mudfish School"),
}, { "Circle Skysong Lake and nearby water bodies.", "Check water elemental spawns for Mote of Water between pools." })

RegisterFish(27437, "Icefin Bluefish", "https://www.wowhead.com/object=182959/bluefish-school", "Nagrand", "Bluefish School route around Nagrand lakes", {
    C(0.252, 0.454, "Western Nagrand Bluefish School"),
    C(0.336, 0.537, "West-central Bluefish School"),
    C(0.502, 0.475, "Central Bluefish School"),
    C(0.549, 0.295, "Northern lake Bluefish School"),
    C(0.623, 0.314, "Eastern Bluefish School"),
}, { "Use the same lake loop as Figluster's Mudfish.", "Fishing pools depend heavily on competition." })

RegisterFish(27438, "Golden Darter", "https://www.wowhead.com/object=182956/school-of-darter", "Terokkar Forest", "School of Darter route along Terokkar rivers", {
    C(0.506, 0.415, "Northwest Terokkar darter school"),
    C(0.553, 0.493, "Central Terokkar darter school"),
    C(0.598, 0.368, "North river darter school"),
    C(0.625, 0.417, "East river darter school"),
    C(0.704, 0.425, "Far eastern darter school"),
}, { "Follow the river instead of crossing dry terrain.", "Pairs naturally with Terocone herb laps nearby." })

RegisterFish(27439, "Furious Crawdad", "https://www.wowhead.com/object=182957/highland-mixed-school", "Terokkar Forest", "Highland Mixed School route around Skettis", {
    C(0.449, 0.403, "Northwest highland school"),
    C(0.589, 0.627, "Western Skettis highland school"),
    C(0.633, 0.747, "Central Skettis highland school"),
    C(0.658, 0.827, "Southern Skettis highland school"),
    C(0.686, 0.819, "Southeast Skettis highland school"),
}, { "Requires high effective Fishing and flying access to the Skettis highland pools.", "Use lures if your skill is low for the area." })
