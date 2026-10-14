local _, NS = ...
local Register = NS.RegisterMaterialFarmingSpot

local function C(x, y, label)
    return { x = x, y = y, label = label }
end

Register({
    itemID = 111557,
    itemName = "Sumptuous Fur",
    expansion = "warlords",
    professions = { "tailoring" },
    category = "Cloth",
    sourceUrls = {
        "https://www.wowhead.com/item=111557/sumptuous-fur",
        "https://www.wow-professions.com/farming/sumptuous-fur-farming",
        "https://www.wowhead.com/npc=79034/tamed-clefthoof",
    },
    summary = "Draenor cloth-equivalent fur from beasts and humanoids; Tamed Clefthoof is the strongest single camp.",
    spots = {
        {
            id = "warlords-sumptuous-fur-nagrand-tamed-clefthoof",
            source = "wow-professions Sumptuous Fur guide and Wowhead Tamed Clefthoof comments",
            sourceUrls = {
                "https://www.wow-professions.com/farming/sumptuous-fur-farming",
                "https://www.wowhead.com/npc=79034/tamed-clefthoof",
            },
            mapName = "Nagrand (Draenor)",
            location = "Tamed Clefthoof instant-respawn pack at 78.7,72.2",
            routeType = "stationary-beast-farm",
            density = "Very high",
            dropDifficulty = "Excellent if uncontested; crowding is the main weakness.",
            tips = {
                "Stand at 78.7,72.2 and kill the pack as it respawns.",
                "The same spot also produces Raw Beast Hide and Raw Clefthoof Meat.",
                "Kill nearby extra clefthoofs if the main pack pauses.",
            },
            coords = {
                C(0.787, 0.722, "Tamed Clefthoof pack"),
                C(0.802, 0.704, "Gorian-side extra clefthoofs"),
                C(0.768, 0.742, "South pack return"),
            },
            confidence = "high",
        },
        {
            id = "warlords-sumptuous-fur-gorgrond-steamscar-tailthrasher",
            source = "wow-professions Sumptuous Fur guide",
            sourceUrls = { "https://www.wow-professions.com/farming/sumptuous-fur-farming" },
            mapName = "Gorgrond",
            location = "Steamscar mobs in central Gorgrond and Tailthrasher mobs in south Gorgrond",
            routeType = "open-world-beast-farm",
            density = "Medium to high",
            dropDifficulty = "Good moving farm when Nagrand is occupied.",
            tips = {
                "Use Steamscar mobs in central Gorgrond or Tailthrasher mobs in south Gorgrond.",
                "Choose whichever camp has fewer players because the guide notes little difference between them.",
            },
            coords = {
                C(0.532, 0.468, "Central Steamscar mobs"),
                C(0.488, 0.632, "Southwest Tailthrasher mobs"),
                C(0.566, 0.680, "South Tailthrasher return"),
            },
            confidence = "medium",
        },
        {
            id = "warlords-sumptuous-fur-talador-daggerjaw-lakes",
            source = "wow-professions Sumptuous Fur guide",
            sourceUrls = { "https://www.wow-professions.com/farming/sumptuous-fur-farming" },
            mapName = "Talador",
            location = "Daggerjaw packs around lakes near Vol'jin's Pride",
            routeType = "open-world-beast-farm",
            density = "High",
            dropDifficulty = "Fast respawn lake loops; good when you want movement instead of a single spawn camp.",
            tips = {
                "Circle the small lake north of Vol'jin's Pride because mobs usually respawn after one lap.",
                "Use the second marked lake if the first one is occupied.",
            },
            coords = {
                C(0.568, 0.350, "North Vol'jin's Pride lake"),
                C(0.606, 0.382, "East Daggerjaw pack"),
                C(0.516, 0.424, "West Daggerjaw pack"),
            },
            confidence = "medium",
        },
    },
})
