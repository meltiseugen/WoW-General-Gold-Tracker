local _, NS = ...
local Register = NS.RegisterMaterialFarmingSpot

local function C(x, y, label)
    return { x = x, y = y, label = label }
end

local function ItemUrl(itemID)
    return "https://www.wowhead.com/item=" .. tostring(itemID)
end

local ROUTES = {
    small = {
        mapName = "Darkshore",
        location = "Coastal threshers, murlocs, and shoreline fishing from Auberdine northward",
        targetUrl = "https://www.wowhead.com/item=5523/small-barnacled-clam",
        coords = { C(0.356, 0.404, "Auberdine north shore"), C(0.386, 0.304, "Cliffspring coast"), C(0.424, 0.222, "Northern shore return") },
    },
    thick = {
        mapName = "The Cape of Stranglethorn",
        location = "Naga and coastal creature loop around the southern cape",
        targetUrl = "https://www.wowhead.com/item=5524/thick-shelled-clam",
        coords = { C(0.448, 0.694, "Southern cape naga"), C(0.500, 0.760, "Wild Shore coast"), C(0.604, 0.808, "Southeast cape shoreline") },
    },
    big = {
        mapName = "Azshara",
        location = "Naga, turtles, and high-level coastal creatures along the eastern shore",
        targetUrl = "https://www.wowhead.com/item=7973/big-mouth-clam",
        coords = { C(0.574, 0.514, "Bay of Storms west shore"), C(0.646, 0.594, "Bay of Storms naga"), C(0.720, 0.674, "Eastern shore creatures") },
    },
}

local function RegisterClamProduct(itemID, itemName, professions, category, routeKey, summary)
    local route = ROUTES[routeKey]
    local urls = { ItemUrl(itemID), route.targetUrl, "https://www.wowhead.com/guide/fishing-leveling-1-300-wow-classic" }
    Register({
        itemID = itemID,
        itemName = itemName,
        expansion = "classic",
        professions = professions,
        category = category,
        researchStatus = "researched",
        sourceUrls = urls,
        summary = summary,
        spots = {
            {
                id = "classic-clam-product-" .. tostring(itemID),
                source = "Wowhead retail clam/item pages, aquatic-creature drop tables, and shoreline map pins",
                sourceUrls = urls,
                mapName = route.mapName,
                location = route.location,
                routeType = "aquatic-creature-and-shoreline-farm",
                density = "Medium",
                dropDifficulty = "Clams are container drops; pearl yield is random, while clam meat is the steadier result.",
                tips = {
                    "Open the clams before valuing the session so pearl and meat results are counted.",
                    "Compare unopened-clam pricing with the expected value of their contents.",
                    "Kill coastal aquatic mobs while moving between fishing casts for mixed acquisition.",
                },
                coords = route.coords,
                confidence = "medium",
            },
        },
    })
end

RegisterClamProduct(5523, "Small Barnacled Clam", { "fishing", "cooking" }, "Clam", "small", "Openable low-level clam containing meat and a chance at early pearls.")
RegisterClamProduct(5524, "Thick-shelled Clam", { "fishing", "cooking" }, "Clam", "thick", "Openable mid-level clam containing Tangy Clam Meat and pearl chances.")
RegisterClamProduct(7973, "Big-mouth Clam", { "fishing", "cooking" }, "Clam", "big", "Openable high-level clam containing Zesty Clam Meat and premium pearl chances.")
RegisterClamProduct(5498, "Small Lustrous Pearl", { "fishing", "jewelcrafting" }, "Pearl", "small", "Early pearl obtained by opening low-level clams.")
RegisterClamProduct(5500, "Iridescent Pearl", { "fishing", "jewelcrafting" }, "Pearl", "thick", "Mid-level pearl obtained from clam containers.")
RegisterClamProduct(7971, "Black Pearl", { "fishing", "jewelcrafting" }, "Pearl", "big", "Rare dark pearl from high-level clams.")
RegisterClamProduct(13926, "Golden Pearl", { "fishing", "jewelcrafting", "tailoring" }, "Pearl", "big", "Rare premium pearl from Big-mouth Clams, now also used by Midnight Classic decor.")
RegisterClamProduct(5503, "Clam Meat", { "fishing", "cooking" }, "Clam Meat", "small", "Cooking meat obtained by opening Small Barnacled Clams.")
RegisterClamProduct(5504, "Tangy Clam Meat", { "fishing", "cooking" }, "Clam Meat", "thick", "Cooking meat obtained by opening Thick-shelled Clams.")
RegisterClamProduct(7974, "Zesty Clam Meat", { "fishing", "cooking" }, "Clam Meat", "big", "Cooking meat obtained by opening Big-mouth Clams.")

local function RegisterAlchemyFish(itemID, itemName, mapName, location, coords, targetUrl, summary)
    local urls = { ItemUrl(itemID), targetUrl, "https://www.wowhead.com/guide/fishing-leveling-1-300-wow-classic" }
    Register({
        itemID = itemID,
        itemName = itemName,
        expansion = "classic",
        professions = { "fishing", "alchemy" },
        category = "Fish",
        researchStatus = "researched",
        sourceUrls = urls,
        summary = summary,
        spots = {
            {
                id = "classic-alchemy-fish-" .. tostring(itemID),
                source = "Wowhead retail fish/school pages and coastal fishing map pins",
                sourceUrls = urls,
                mapName = mapName,
                location = location,
                routeType = "fishing-school-route",
                density = "School dependent",
                dropDifficulty = "Follow the shoreline and fish named schools when present; open-water catches are less targeted.",
                tips = {
                    "Use water walking or a surface mount to chain coastal pools quickly.",
                    "These fish feed current Classic Alchemy oils, so compare raw fish and processed-oil prices.",
                    "Move zones if another farmer is clearing the same pool circuit.",
                },
                coords = coords,
                confidence = "high",
            },
        },
    })
end

RegisterAlchemyFish(6358, "Oily Blackmouth", "Northern Barrens", "Ratchet coast and nearby Oily Blackmouth schools", {
    C(0.626, 0.366, "Ratchet north coast"), C(0.640, 0.390, "Ratchet docks"), C(0.662, 0.430, "Merchant Coast return"),
}, "https://www.wowhead.com/item=6358/oily-blackmouth", "School fish processed into Blackmouth Oil.")
RegisterAlchemyFish(6359, "Firefin Snapper", "The Cape of Stranglethorn", "Booty Bay and southern cape Firefin schools", {
    C(0.420, 0.682, "Booty Bay west water"), C(0.472, 0.760, "Wild Shore pools"), C(0.604, 0.808, "Southeast cape pools"),
}, "https://www.wowhead.com/item=6359/firefin-snapper", "School fish processed into Fire Oil.")
RegisterAlchemyFish(13422, "Stonescale Eel", "Azshara", "Bay of Storms and eastern Azshara Stonescale Eel schools", {
    C(0.574, 0.514, "Bay of Storms west"), C(0.646, 0.594, "Bay of Storms center"), C(0.720, 0.674, "Eastern shore pools"),
}, "https://www.wowhead.com/item=13422/stonescale-eel", "High-level fish processed into Stonescale Oil.")

Register({
    itemID = 5784,
    itemName = "Slimy Murloc Scale",
    expansion = "classic",
    professions = { "fishing", "leatherworking" },
    category = "Scale",
    researchStatus = "researched",
    sourceUrls = { ItemUrl(5784), "https://www.wowhead.com/zone=719/blackfathom-deeps" },
    summary = "Legacy leatherworking scale whose current retail source is fishing inside Blackfathom Deeps.",
    spots = {
        {
            id = "classic-fishing-blackfathom-slimy-murloc-scale",
            source = "Wowhead retail item fishing-location data and Blackfathom Deeps zone page",
            sourceUrls = { ItemUrl(5784), "https://www.wowhead.com/zone=719/blackfathom-deeps" },
            mapName = "Ashenvale",
            location = "Blackfathom Deeps entrance; fish the dungeon waters",
            routeType = "dungeon-fishing",
            density = "Dungeon-water source",
            dropDifficulty = "Retail-specific source: the item page lists Blackfathom Deeps as its fishing location.",
            tips = {
                "Bring enough fishing skill or bonuses to avoid junk catches.",
                "This is not modeled as a normal murloc kill route because the retail source is fishing.",
                "Check the niche leatherworking demand before farming a large quantity.",
            },
            coords = { C(0.142, 0.142, "Blackfathom Deeps entrance") },
            confidence = "high",
        },
    },
})
