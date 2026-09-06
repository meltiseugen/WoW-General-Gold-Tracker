local _, NS = ...
local Register = NS.RegisterMaterialFarmingSpot

local function C(x, y, label)
    return { x = x, y = y, label = label }
end

Register({
    itemID = 33470,
    itemName = "Frostweave Cloth",
    expansion = "wrath",
    professions = { "tailoring" },
    category = "Cloth",
    sourceUrls = {
        "https://www.wowhead.com/item=33470/frostweave-cloth",
        "https://www.wowhead.com/zone=4813/pit-of-saron",
    },
    summary = "Baseline Wrath cloth from Northrend humanoids. Dense dungeon trash and Icecrown humanoid packs are the most practical routes.",
    spots = {
        {
            id = "wrath-frostweave-pit-of-saron-trash",
            source = "Wowhead Frostweave item comments and Pit of Saron route research",
            sourceUrls = {
                "https://www.wowhead.com/item=33470/frostweave-cloth",
                "https://www.wowhead.com/zone=4813/pit-of-saron",
            },
            mapName = "Icecrown",
            location = "Pit of Saron trash reset path",
            routeType = "dungeon-trash-loop",
            density = "High",
            dropDifficulty = "Strong controlled cloth farm when resets and clear speed allow it.",
            tips = {
                "Clear dense trash packs, loot, reset when efficient, and compare greens for disenchant value.",
                "Tailors should use Northern Cloth Scavenging where available.",
            },
            coords = {
                C(0.535, 0.894, "Pit of Saron entrance"),
                C(0.545, 0.874, "Entrance trash staging"),
            },
            confidence = "high",
        },
        {
            id = "wrath-frostweave-sholazar-avalanche",
            source = "Wowhead Frostweave item comments",
            sourceUrls = { "https://www.wowhead.com/item=33470/frostweave-cloth" },
            mapName = "Sholazar Basin",
            location = "Avalanche undead and humanoid packs",
            routeType = "open-world-humanoid-loop",
            density = "Medium",
            dropDifficulty = "Good outdoor fallback with exact user-reported route anchors.",
            tips = {
                "Use the tight 66,50 to 66,51 path when dungeon resets are not available.",
                "The spot is less controlled than Pit of Saron, so competition matters more.",
            },
            coords = {
                C(0.660, 0.500, "Avalanche cloth pack"),
                C(0.660, 0.510, "Avalanche return pack"),
            },
            confidence = "medium",
        },
        {
            id = "wrath-frostweave-icecrown-humanoid-loop",
            source = "Wowhead Frostweave item comments and Icecrown humanoid farming route research",
            sourceUrls = {
                "https://www.wowhead.com/item=33470/frostweave-cloth",
                "https://www.wowhead.com/zone=210/icecrown",
            },
            mapName = "Icecrown",
            location = "Onslaught Harbor and central Icecrown humanoid pack checks",
            routeType = "open-world-humanoid-loop",
            density = "Medium",
            dropDifficulty = "Outdoor fallback route. Good when dungeon routes are occupied or reset-limited.",
            tips = {
                "Farm dense humanoid packs and route through nearby green-drop camps for extra auction/disenchant value.",
                "Avoid long travel between sparse packs.",
            },
            coords = {
                C(0.750, 0.160, "Onslaught Harbor packs"),
                C(0.500, 0.340, "Central Icecrown pack checks"),
            },
            confidence = "medium",
        },
    },
})
