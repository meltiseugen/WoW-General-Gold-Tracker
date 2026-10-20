local _, NS = ...

NS.CataclysmHousing = {
    dataVersion = 1,
    researchedAt = "2026-10-19",
    sourceUrl = "https://www.wowhead.com/guide/player-housing/crafting-decor-items",
    quantityVersion = "Live Wowhead recipe tooltips retrieved 2026-10-19",
    reagentScope = "Farmable inputs only; vendor-only reagents are omitted. Ashwood Lumber and Dreamcloth are bound crafting inputs, not Auction House products.",
    recipes = {},
}

for _, item in ipairs((NS.FarmingItems and NS.FarmingItems.items) or {}) do
    if item.expansion == "cataclysm" and item.tag == "Housing Decor" then
        local recipe = {
            outputItemID = item.itemID,
            outputName = item.itemName,
            profession = item.professions[1],
            recipeSpellID = item.recipeSpellID,
            sourceUrl = "https://www.wowhead.com/spell=" .. tostring(item.recipeSpellID),
            reagents = item.components,
            isRoute = false,
        }
        NS.CataclysmHousing.recipes[#NS.CataclysmHousing.recipes + 1] = recipe
        for _, reagent in ipairs(recipe.reagents or {}) do
            local material = NS.MaterialFarmingSpots.items[reagent.itemID]
            if material then
                material.housingUses = material.housingUses or {}
                material.housingUses[#material.housingUses + 1] = {
                    outputItemID = recipe.outputItemID,
                    outputName = recipe.outputName,
                    profession = recipe.profession,
                    quantity = reagent.quantity,
                }
            end
        end
    end
end
