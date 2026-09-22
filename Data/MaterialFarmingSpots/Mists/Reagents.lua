local _, NS = ...
local Register = NS.RegisterMaterialFarmingSpot

local function C(x, y, label)
    return { x = x, y = y, label = label }
end

Register({
    itemID = 92426,
    itemName = "Sealed Tome of the Lost Legion",
    expansion = "mists",
    professions = { "miscellaneous" },
    category = "Class Unlock",
    researchStatus = "researched",
    sourceUrls = {
        "https://www.wowhead.com/item=92426/sealed-tome-of-the-lost-legion",
        "https://www.wowhead.com/zone=6507/isle-of-thunder",
    },
    summary = "Tradeable Warlock-only rare loot from Isle of Thunder rares, used to begin the green-fire quest line.",
    spots = {
        {
            id = "mists-isle-of-thunder-sealed-tome-rare-loop",
            source = "Retail/Mists Wowhead Sealed Tome source notes and Isle of Thunder rare coordinates",
            sourceUrls = {
                "https://www.wowhead.com/item=92426/sealed-tome-of-the-lost-legion",
                "https://www.wowhead.com/zone=6507/isle-of-thunder",
            },
            mapName = "Isle of Thunder",
            location = "Warlock rare-spawn circuit around the island",
            routeType = "class-gated-rare-loop",
            density = "Ten rare checks",
            dropDifficulty = "Low drop chance and lootable only by Warlocks; rare respawns limit attempts.",
            tips = {
                "Farm on a Warlock; other classes cannot loot the tome even when it appears.",
                "Cycle the full rare route instead of camping one spawn.",
                "The tome is tradeable and auctionable before it is combined with a Healthstone.",
            },
            coords = {
                C(0.350, 0.630, "Mumta"),
                C(0.380, 0.830, "Ku'lai the Skyclaw"),
                C(0.510, 0.710, "Progenitus"),
                C(0.540, 0.530, "Goda"),
                C(0.620, 0.500, "God-Hulk Ramuk"),
                C(0.450, 0.300, "Al'tabim the All-Seeing"),
                C(0.480, 0.250, "Backbreaker Uru patrol"),
                C(0.540, 0.360, "Lu-Ban"),
                C(0.590, 0.360, "Molthor"),
                C(0.500, 0.920, "Haywire Sunreaver Construct patrol"),
            },
            confidence = "high",
        },
    },
})
