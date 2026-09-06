local _, NS = ...
local Register = NS.RegisterMaterialFarmingSpot

local function C(x, y, label)
    return { x = x, y = y, label = label }
end

local function ItemUrl(itemID)
    return "https://www.wowhead.com/item=" .. tostring(itemID)
end

local function RegisterElemental(itemID, itemName, professions, sourceUrls, summary, spot)
    Register({
        itemID = itemID,
        itemName = itemName,
        expansion = "wrath",
        professions = professions,
        category = "Elemental",
        sourceUrls = sourceUrls,
        summary = summary,
        spots = { spot },
    })
end

RegisterElemental(37700, "Crystallized Air", { "alchemy", "engineering" }, {
    ItemUrl(37700),
    "https://www.wow-professions.com/farming/crystallized-air-farming",
    "https://www.wowhead.com/npc=25415/enraged-tempest",
}, "Crystallized Air is best targeted from Enraged Tempests in Borean Tundra, with low-level mobs and quick respawns.", {
    id = "crystallized-air-borean-tundra-enraged-tempests",
    source = "wow-professions Crystallized Air guide and Wowhead Enraged Tempest page",
    sourceUrls = {
        "https://www.wow-professions.com/farming/crystallized-air-farming",
        "https://www.wowhead.com/npc=25415/enraged-tempest",
    },
    mapName = "Borean Tundra",
    location = "Enraged Tempests near Bor'gorok Outpost",
    routeType = "open-world-loop",
    density = "High",
    dropDifficulty = "Easy targeted farm with low-level mobs and little downtime.",
    tips = {
        "Keep a compact loop around the elemental pocket.",
        "Use Zul'Drak as a fallback only if Borean Tundra is crowded.",
    },
    coords = {
        C(0.546, 0.110, "Northwest tempest pocket"),
        C(0.568, 0.136, "Central tempest pocket"),
        C(0.590, 0.166, "South tempest pocket"),
        C(0.612, 0.126, "East tempest pocket"),
    },
    confidence = "high",
})

RegisterElemental(37702, "Crystallized Fire", { "alchemy", "engineering" }, {
    ItemUrl(37702),
    "https://www.wow-professions.com/farming/crystallized-fire-farming",
    "https://www.wowhead.com/item=37702/crystallized-fire",
}, "Crystallized Fire is best targeted in Frostfloe Deep in The Storm Peaks, with Borean Tundra boilers as a lower-value backup.", {
    id = "crystallized-fire-storm-peaks-frostfloe-deep",
    source = "wow-professions Crystallized Fire guide and Wowhead Crystallized Fire comments",
    sourceUrls = {
        "https://www.wow-professions.com/farming/crystallized-fire-farming",
        "https://www.wowhead.com/item=37702/crystallized-fire",
    },
    mapName = "The Storm Peaks",
    location = "Frostfloe Deep cave Wailing Wind loop",
    routeType = "open-world-cave-loop",
    density = "Medium",
    dropDifficulty = "Good but slower than some elemental farms; phasing and competition can affect the cave.",
    tips = {
        "Use the cave around 62,42 as the anchor and loop the nearby Wailing Winds.",
        "Do not widen the loop far beyond the cave unless respawns are slow.",
    },
    coords = {
        C(0.620, 0.420, "Frostfloe Deep cave"),
        C(0.598, 0.408, "West cave check"),
        C(0.636, 0.438, "Inner cave check"),
        C(0.660, 0.430, "East cave check"),
    },
    confidence = "high",
})

RegisterElemental(37705, "Crystallized Water", { "alchemy", "engineering" }, {
    ItemUrl(37705),
    "https://www.wow-professions.com/farming/crystallized-water-farming",
    "https://www.wowhead.com/npc=25419/boiling-spirit",
}, "Crystallized Water is best targeted from Boiling Spirits in Borean Tundra, with Dragonblight revenants as a backup.", {
    id = "crystallized-water-borean-tundra-boiling-spirits",
    source = "wow-professions Crystallized Water guide and Wowhead Boiling Spirit page",
    sourceUrls = {
        "https://www.wow-professions.com/farming/crystallized-water-farming",
        "https://www.wowhead.com/npc=25419/boiling-spirit",
    },
    mapName = "Borean Tundra",
    location = "Boiling Spirits around the Geyser Fields",
    routeType = "open-world-loop",
    density = "High",
    dropDifficulty = "Strong targeted farm; note that some water elementals can be frost immune.",
    tips = {
        "Stay around the geyser pool and rotate through Boiling Spirit spawns.",
        "Use a non-frost damage setup if your class can choose.",
    },
    coords = {
        C(0.464, 0.118, "West geyser spirit"),
        C(0.488, 0.136, "Central geyser spirit"),
        C(0.512, 0.154, "South geyser spirit"),
        C(0.536, 0.124, "East geyser spirit"),
    },
    confidence = "high",
})
