local _, NS = ...
local Register = NS.RegisterMaterialFarmingSpot

local function C(x, y, label)
    return { x = x, y = y, label = label }
end

Register({
    itemID = 43299,
    itemName = "Damaged Necklace",
    expansion = "wrath",
    professions = { "jewelcrafting", "miscellaneous" },
    category = "Quest Reagent",
    researchStatus = "researched",
    sourceUrls = {
        "https://www.wowhead.com/item=43299/damaged-necklace",
        "https://www.wowhead.com/zone=210/icecrown",
    },
    summary = "Tradeable Northrend world drop that starts the repeatable Necklace Repair jewelcrafting-token quest.",
    spots = {
        {
            id = "wrath-icecrown-damaged-necklace-world-drop",
            source = "Retail Wowhead Damaged Necklace drop reports and Icecrown mob locations",
            sourceUrls = {
                "https://www.wowhead.com/item=43299/damaged-necklace",
                "https://www.wowhead.com/zone=210/icecrown",
            },
            mapName = "Icecrown",
            location = "Dense Ymirheim and Onslaught Harbor humanoid circuits",
            routeType = "rare-world-drop-cloth-loop",
            density = "High mobs, low target rate",
            dropDifficulty = "Rare Northrend-wide world drop; dense humanoid farms improve attempts, not the individual drop chance.",
            tips = {
                "Use a dense Icecrown humanoid loop and value Frostweave Cloth and bind-on-equip drops alongside the necklace.",
                "The necklace is tradeable until used to accept its jewelcrafting quest.",
                "Do not list this as a guaranteed route-specific drop; it can fall from many Northrend creatures.",
            },
            coords = {
                C(0.548, 0.570, "Ymirheim humanoid circuit"),
                C(0.592, 0.584, "Ymirheim eastern packs"),
                C(0.086, 0.456, "Onslaught Harbor western packs"),
            },
            confidence = "medium",
        },
    },
})
