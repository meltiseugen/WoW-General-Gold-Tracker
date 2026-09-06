local _, NS = ...
local Register = NS.RegisterMaterialFarmingSpot

local function C(x, y, label)
    return { x = x, y = y, label = label }
end

Register({
    itemID = 53010,
    itemName = "Embersilk Cloth",
    expansion = "cataclysm",
    professions = { "tailoring" },
    category = "Cloth",
    sourceUrls = {
        "https://www.wow-professions.com/farming/embersilk-cloth-farming",
        "https://www.wowhead.com/guide/6-1-0-embersilk-cloth-farming-guide-3020",
        "https://www.warcrafttavern.com/cataclysm/guides/embersilk-cloth-farming-guide/",
    },
    summary = "Bastion of Twilight trash is the top reset farm. Outdoor Deepholm and Tol Barad spots are useful when reset limits or competition change the value.",
    spots = {
        {
            id = "embersilk-bastion-of-twilight-trash",
            source = "wow-professions Embersilk guide and Wowhead Embersilk route guide",
            sourceUrls = {
                "https://www.wow-professions.com/farming/embersilk-cloth-farming",
                "https://www.wowhead.com/guide/6-1-0-embersilk-cloth-farming-guide-3020",
            },
            mapName = "Twilight Highlands",
            location = "Bastion of Twilight entrance and trash pulls",
            routeType = "instance-reset",
            density = "High",
            dropDifficulty = "Very strong on high-level retail characters; reset-capped.",
            tips = {
                "Entrance is high above Twilight Highlands around 34.2, 77.9.",
                "Farm trash and avoid killing the first boss if you want quick resets.",
                "Potion of Treasure Finding and Tailoring Cloth Scavenging improve the run.",
            },
            coords = {
                C(0.342, 0.779, "Bastion of Twilight entrance"),
            },
            confidence = "high",
        },
        {
            id = "embersilk-deepholm-verlok-stand",
            source = "wow-professions Embersilk guide and Warcraft Tavern Embersilk guide",
            sourceUrls = {
                "https://www.wow-professions.com/farming/embersilk-cloth-farming",
                "https://www.warcrafttavern.com/cataclysm/guides/embersilk-cloth-farming-guide/",
            },
            mapName = "Deepholm",
            location = "Verlok Stand",
            routeType = "open-world-loop",
            density = "Medium to high",
            dropDifficulty = "Good outdoor route with vertical movement around the pillar.",
            tips = {
                "Rotate above and below the pillar near 73,26.",
                "Use Potion of Treasure Finding for extra Tiny Treasure Chest value.",
            },
            coords = {
                C(0.730, 0.260, "Verlok Stand"),
                C(0.704, 0.238, "Upper Verlok checks"),
                C(0.756, 0.286, "Lower Verlok checks"),
            },
            confidence = "high",
        },
        {
            id = "embersilk-tol-barad-restless-front",
            source = "wow-professions Embersilk guide and Warcraft Tavern Embersilk guide",
            sourceUrls = {
                "https://www.wow-professions.com/farming/embersilk-cloth-farming",
                "https://www.warcrafttavern.com/cataclysm/guides/embersilk-cloth-farming-guide/",
            },
            mapName = "Tol Barad Peninsula",
            location = "Restless Front humanoid packs",
            routeType = "open-world-loop",
            density = "Medium",
            dropDifficulty = "Can be strong, but competition and daily traffic affect output.",
            tips = {
                "Mobs fight each other down to low health, making cleanup fast when the area is active.",
                "Use this as an outdoor fallback when instance reset farms are unavailable.",
            },
            coords = {
                C(0.446, 0.292, "Restless Front west"),
                C(0.486, 0.304, "Restless Front center"),
                C(0.522, 0.328, "Restless Front east"),
            },
            confidence = "medium",
        },
        {
            id = "embersilk-victors-point-ogre-phase",
            source = "Wowhead Embersilk route guide",
            sourceUrls = { "https://www.wowhead.com/guide/6-1-0-embersilk-cloth-farming-guide-3020" },
            mapName = "Twilight Highlands",
            location = "Victor's Point phased Twilight Ettin and Bloodeye Brute farm",
            routeType = "phased-open-world-loop",
            density = "High if phased correctly",
            dropDifficulty = "Requires the Victor's Point quest chain to be left at the correct step.",
            tips = {
                "Stop before completing the final phase step if you want to preserve the farm state.",
                "Works best with Potion of Treasure Finding and fast AoE clears.",
            },
            coords = {
                C(0.392, 0.574, "Victor's Point farm start"),
                C(0.422, 0.596, "Ogre and ettin packs"),
                C(0.448, 0.628, "Southern pack return"),
            },
            confidence = "medium",
        },
    },
})
