local _, NS = ...
local Register = NS.RegisterMaterialFarmingSpot
local ObjectPins = NS.GetBurningCrusadeObjectCoords

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

RegisterFish(27422, "Barbed Gill Trout", "https://www.wowhead.com/object=182954/brackish-mixed-school", "Zangarmarsh", "Open water and Brackish Mixed School route around Zangarmarsh lakes", ObjectPins(182954, 102), { "Fish open water while moving between schools.", "Use this as general Outland cooking fish value rather than a strict rare-pool target." })

RegisterFish(27425, "Spotted Feltail", "https://www.wowhead.com/object=182954/brackish-mixed-school", "Zangarmarsh", "Brackish Mixed School route around Zangarmarsh", ObjectPins(182954, 102), { "Follow lake edges and fish every Brackish Mixed School.", "Pairs with Zangarian Sporefish and Barbed Gill Trout." })

RegisterFish(27429, "Zangarian Sporefish", "https://www.wowhead.com/object=182953/sporefish-school", "Zangarmarsh", "Sporefish School route around Zangarmarsh lakes", ObjectPins(182953, 102), { "Circle Zangarmarsh lakes and do not skip visible pools.", "Good paired with Ragveil and Flame Cap herbalism." })

RegisterFish(27435, "Figluster's Mudfish", "https://www.wowhead.com/object=182958/mudfish-school", "Nagrand", "Mudfish School route around Nagrand lakes", ObjectPins(182958, 107), { "Circle Skysong Lake and nearby water bodies.", "Check water elemental spawns for Mote of Water between pools." })

RegisterFish(27437, "Icefin Bluefish", "https://www.wowhead.com/object=182959/bluefish-school", "Nagrand", "Bluefish School route around Nagrand lakes", ObjectPins(182959, 107), { "Use the same lake loop as Figluster's Mudfish.", "Fishing pools depend heavily on competition." })

RegisterFish(27438, "Golden Darter", "https://www.wowhead.com/object=182956/school-of-darter", "Terokkar Forest", "School of Darter route along Terokkar rivers", ObjectPins(182956, 108), { "Follow the river instead of crossing dry terrain.", "Pairs naturally with Terocone herb laps nearby." })

RegisterFish(27439, "Furious Crawdad", "https://www.wowhead.com/object=182957/highland-mixed-school", "Terokkar Forest", "Highland Mixed School route around Skettis", ObjectPins(182957, 108), { "Requires high effective Fishing and flying access to the Skettis highland pools.", "Use lures if your skill is low for the area." })

local function RegisterKarazhanFish(itemID, itemName)
    Register({
        itemID = itemID,
        itemName = itemName,
        expansion = "burningCrusade",
        professions = { "fishing", "cooking" },
        category = "Fish",
        researchStatus = "researched",
        sourceUrls = {
            "https://www.wowhead.com/item=" .. itemID,
            "https://www.wowhead.com/zone=41/deadwind-pass",
        },
        summary = itemName .. " is a Karazhan-area open-water catch in Deadwind Pass. It has no fishing-school object, so the pins mark each accessible water section rather than pool spawns.",
        spots = {
            {
                id = "bc-fish-" .. itemID .. "-karazhan-water",
                source = "Retail Wowhead item fishing-source table",
                sourceUrls = {
                    "https://www.wowhead.com/item=" .. itemID,
                    "https://www.wowhead.com/zone=41/deadwind-pass",
                },
                mapName = "Deadwind Pass",
                location = "Karazhan approach water and nearby Deadwind Pass water",
                routeType = "open-water-fishing",
                density = "Open-water catch table",
                dropDifficulty = "No school route; cast in each reachable water section around Karazhan.",
                tips = {
                    "These are water-access anchors, not static school spawns.",
                    "Keep every water anchor enabled because open-water catches are not represented by object pins.",
                },
                coords = {
                    C(0.456, 0.699, "Upper Karazhan approach water"),
                    C(0.470, 0.750, "Karazhan entrance water"),
                    C(0.493, 0.781, "Lower Karazhan approach water"),
                },
                confidence = "medium",
            },
        },
    })
end

RegisterKarazhanFish(33823, "Bloodfin Catfish")
RegisterKarazhanFish(33824, "Crescent-Tail Skullfish")
