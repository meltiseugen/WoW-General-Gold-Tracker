local _, NS = ...
local Register = NS.RegisterMaterialFarmingSpot

local function C(x, y, label)
    return { x = x, y = y, label = label }
end

local function ItemUrl(itemID)
    return "https://www.wowhead.com/item=" .. tostring(itemID)
end

local function RegisterVolatile(itemID, itemName, professions, sourceUrls, summary, spots)
    Register({
        itemID = itemID,
        itemName = itemName,
        expansion = "cataclysm",
        professions = professions,
        category = "Volatile",
        sourceUrls = sourceUrls,
        summary = summary,
        spots = spots,
    })
end

RegisterVolatile(52325, "Volatile Fire", { "alchemy", "engineering" }, {
    ItemUrl(52325),
    "https://www.wowhead.com/item=52325/volatile-fire",
    "https://www.wow-professions.com/farming/volatile-fire-farming",
}, "Volatile Fire is best targeted from Unbound Emberfiends at Humboldt Conflagration or by fishing Pool of Fire when active.", {
    {
        id = "cataclysm-volatile-fire-twilight-highlands-humboldt-conflagration",
        source = "Wowhead Volatile Fire guide and wow-professions Volatile Fire guide",
        sourceUrls = {
            "https://www.wowhead.com/item=52325/volatile-fire",
            "https://www.wow-professions.com/farming/volatile-fire-farming",
        },
        mapName = "Twilight Highlands",
        location = "Humboldt Conflagration northwest of Thundermar",
        routeType = "open-world-loop",
        density = "Medium to high",
        dropDifficulty = "Good targeted fire farm; competition can make the small area feel cramped.",
        tips = {
            "Farm Unbound Emberfiends around the burning ground and lava pools.",
            "Fish Pool of Fire when one is active nearby for extra Volatile Fire.",
        },
        coords = {
            C(0.428, 0.244, "North Humboldt fire pocket"),
            C(0.452, 0.264, "Central Humboldt fire pocket"),
            C(0.480, 0.284, "East Humboldt fire pocket"),
            C(0.444, 0.316, "South Humboldt fire pocket"),
        },
        confidence = "high",
    },
})

RegisterVolatile(52326, "Volatile Water", { "alchemy", "engineering" }, {
    ItemUrl(52326),
    "https://www.wowhead.com/item=52326/volatile-water",
    "https://www.wow-professions.com/farming/volatile-water-farming",
}, "Volatile Water can be targeted from Muddied Water Elementals in Twilight Highlands or fished from Cataclysm waters.", {
    {
        id = "cataclysm-volatile-water-twilight-highlands-muddied-water-elementals",
        source = "Wowhead Volatile Water guide, wow-professions Volatile Water guide, and community farming reports",
        sourceUrls = {
            "https://www.wowhead.com/item=52326/volatile-water",
            "https://www.wow-professions.com/farming/volatile-water-farming",
            "https://www.reddit.com/r/woweconomy/comments/azzohl/modest_millions_best_volatile_water_farm_tiny/",
        },
        mapName = "Twilight Highlands",
        location = "Muddied Water Elementals near the Verrall Delta west of Dragonmaw Port",
        routeType = "open-world-loop",
        density = "High",
        dropDifficulty = "Strong targeted farm, but often heavily contested.",
        tips = {
            "Anchor near 66,46 and keep a tight kill-loot loop around the water pocket.",
            "Use Potion of Treasure Finding if you are also killing nearby eligible mobs.",
            "Fishing Cataclysm pools can be steadier when this camp is crowded.",
        },
        coords = {
            C(0.660, 0.460, "Reported water elemental anchor"),
            C(0.642, 0.438, "North delta water pocket"),
            C(0.684, 0.442, "East delta water pocket"),
            C(0.674, 0.486, "South delta water pocket"),
        },
        confidence = "high",
    },
})

RegisterVolatile(52328, "Volatile Air", { "alchemy", "engineering" }, {
    ItemUrl(52328),
    "https://www.wowhead.com/item=52328/volatile-air",
    "https://www.wow-professions.com/farming/volatile-air-farming",
}, "Volatile Air is best farmed in Vortex Pinnacle on high-level characters, with Uldum air elementals as an outdoor option.", {
    {
        id = "cataclysm-volatile-air-uldum-vortex-pinnacle",
        source = "wow-professions Volatile Air guide and Wowhead Volatile Air guide",
        sourceUrls = {
            "https://www.wow-professions.com/farming/volatile-air-farming",
            "https://www.wowhead.com/item=52328/volatile-air",
        },
        mapName = "Uldum",
        location = "Vortex Pinnacle entrance and nearby southeastern Uldum air route",
        routeType = "instance-trash-loop",
        density = "High in instance",
        dropDifficulty = "Best on high-level retail characters; the entrance is high in the southeastern sky.",
        tips = {
            "Use Vortex Pinnacle trash loops when you can clear quickly.",
            "If running outdoors, use Orsis-area air elementals instead of wide desert roaming.",
        },
        coords = {
            C(0.765, 0.846, "Vortex Pinnacle entrance"),
            C(0.470, 0.430, "Orsis air elemental fallback"),
        },
        confidence = "high",
    },
})
