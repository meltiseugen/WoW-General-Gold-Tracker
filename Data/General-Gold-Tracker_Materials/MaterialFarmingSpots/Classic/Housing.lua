local _, NS = ...

NS.ClassicHousing = {
    dataVersion = 2,
    researchedAt = "2026-09-21",
    sourceUrl = "https://news.blizzard.com/en-us/article/24247147/professions-unpacked-craft-housing-decor-with-reagents-from-every-era",
    guideUrl = "https://www.wowhead.com/guide/player-housing/crafting-decor-items",
    reagentScope = "Farmable inputs only; vendor-sourced reagents are intentionally omitted.",
    recipes = {
        { outputItemID = 257100, outputName = "Apothecary's Worktable", profession = "alchemy", reagents = { { itemID = 245586, quantity = 40 }, { itemID = 12808, quantity = 16 }, { itemID = 12360, quantity = 12 }, { itemID = 13468, quantity = 8 } } },
        { outputItemID = 257041, outputName = "Stoppered Black Potion", profession = "alchemy", reagents = { { itemID = 245586, quantity = 10 }, { itemID = 20520, quantity = 2 } } },
        { outputItemID = 246111, outputName = "Shadowforge Sconce", profession = "blacksmithing", reagents = { { itemID = 245586, quantity = 10 }, { itemID = 11371, quantity = 12 }, { itemID = 17011, quantity = 4 }, { itemID = 14344, quantity = 2 } } },
        { outputItemID = 246489, outputName = "Steel Ironforge Emblem", profession = "blacksmithing", reagents = { { itemID = 245586, quantity = 20 }, { itemID = 11371, quantity = 20 }, { itemID = 12360, quantity = 8 }, { itemID = 12810, quantity = 4 } } },
        { outputItemID = 263027, outputName = "Darkmaster's Mystical Brazier", profession = "enchanting", reagents = { { itemID = 245586, quantity = 30 }, { itemID = 12808, quantity = 16 }, { itemID = 14344, quantity = 12 }, { itemID = 16203, quantity = 8 }, { itemID = 20520, quantity = 8 } } },
        { outputItemID = 253250, outputName = "Tirisfal Hollow Campfire", profession = "enchanting", reagents = { { itemID = 245586, quantity = 20 }, { itemID = 16203, quantity = 12 }, { itemID = 12365, quantity = 12 }, { itemID = 17010, quantity = 5 } } },
        { outputItemID = 246410, outputName = "Dark Iron Table Saw", profession = "engineering", reagents = { { itemID = 245586, quantity = 40 }, { itemID = 11371, quantity = 12 }, { itemID = 16006, quantity = 8 }, { itemID = 7076, quantity = 8 }, { itemID = 15994, quantity = 6 } } },
        { outputItemID = 246700, outputName = "Gnomish Steam-Powered Bed", profession = "engineering", reagents = { { itemID = 245586, quantity = 25 }, { itemID = 16000, quantity = 4 }, { itemID = 16006, quantity = 4 }, { itemID = 7078, quantity = 4 }, { itemID = 14048, quantity = 8 } } },
        { outputItemID = 245502, outputName = "Brill Coffin", profession = "inscription", reagents = { { itemID = 245586, quantity = 25 }, { itemID = 12808, quantity = 8 }, { itemID = 7076, quantity = 8 }, { itemID = 43123, quantity = 5 } } },
        { outputItemID = 245503, outputName = "Brill Coffin Lid", profession = "inscription", reagents = { { itemID = 245586, quantity = 15 }, { itemID = 12808, quantity = 4 }, { itemID = 7076, quantity = 2 }, { itemID = 43123, quantity = 2 } } },
        { outputItemID = 246420, outputName = "Kharanos Bookcase", profession = "inscription", reagents = { { itemID = 245586, quantity = 50 }, { itemID = 10308, quantity = 50 }, { itemID = 12365, quantity = 24 }, { itemID = 12359, quantity = 12 } } },
        { outputItemID = 258289, outputName = "Thunder Bluff Totem", profession = "inscription", reagents = { { itemID = 245586, quantity = 30 }, { itemID = 7076, quantity = 8 }, { itemID = 43121, quantity = 6 } } },
        { outputItemID = 246423, outputName = "Wooden Ironforge Table", profession = "inscription", reagents = { { itemID = 245586, quantity = 45 }, { itemID = 6037, quantity = 12 }, { itemID = 43119, quantity = 8 }, { itemID = 12810, quantity = 8 }, { itemID = 20963, quantity = 4 } } },
        { outputItemID = 246488, outputName = "Ironforge Chandelier", profession = "jewelcrafting", reagents = { { itemID = 245586, quantity = 30 }, { itemID = 6037, quantity = 12 }, { itemID = 20963, quantity = 8 }, { itemID = 12799, quantity = 8 } } },
        { outputItemID = 246413, outputName = "Blackrock Lamppost", profession = "jewelcrafting", reagents = { { itemID = 245586, quantity = 40 }, { itemID = 11371, quantity = 16 }, { itemID = 7910, quantity = 20 }, { itemID = 17011, quantity = 6 } } },
        { outputItemID = 242948, outputName = "Loch Modan Bearskin Rug", profession = "leatherworking", reagents = { { itemID = 245586, quantity = 15 }, { itemID = 8170, quantity = 12 }, { itemID = 15407, quantity = 2 } } },
        { outputItemID = 257725, outputName = "Camp Narache Rug", profession = "leatherworking", reagents = { { itemID = 245586, quantity = 18 }, { itemID = 15417, quantity = 8 } } },
        { outputItemID = 246685, outputName = "Dwarven District Banner", profession = "tailoring", reagents = { { itemID = 245586, quantity = 25 }, { itemID = 14342, quantity = 12 }, { itemID = 13926, quantity = 2 } } },
        { outputItemID = 243336, outputName = "Elder Rise Rug", profession = "tailoring", reagents = { { itemID = 245586, quantity = 18 }, { itemID = 14048, quantity = 12 } } },
    },
}

for _, recipe in ipairs(NS.ClassicHousing.recipes) do
    recipe.isRoute = false
    local output = NS.MaterialFarmingSpots.items[recipe.outputItemID]
    if output then
        output.itemName = recipe.outputName
    end
    for _, reagent in ipairs(recipe.reagents) do
        local item = NS.MaterialFarmingSpots.items[reagent.itemID]
        if item then
            item.housingUses = item.housingUses or {}
            item.housingUses[#item.housingUses + 1] = {
                outputItemID = recipe.outputItemID,
                outputName = recipe.outputName,
                profession = recipe.profession,
                quantity = reagent.quantity,
            }
        end
    end
end
