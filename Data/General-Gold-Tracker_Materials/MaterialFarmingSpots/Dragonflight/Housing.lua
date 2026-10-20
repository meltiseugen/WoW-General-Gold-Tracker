local _, NS = ...

NS.DragonflightHousing = {
    dataVersion = 1,
    researchedAt = "2026-10-20",
    sourceUrl = "https://www.wowhead.com/guide/player-housing/crafting-decor-items",
    quantityVersion = "Retail recipe tooltips plus client spell-effect batch checks, researched 2026-10-19 and 2026-10-20",
    reagentScope = "Farmable inputs only; vendor-only reagents are omitted. Dragonpine Lumber binds to the Warband; other bound intermediates are labeled as support inputs, not Auction House products.",
    recipes = {},
}

for _, item in ipairs((NS.FarmingItems and NS.FarmingItems.items) or {}) do
    if item.expansion == "dragonflight" and item.tag == "Housing Decor" then
        local recipe = {
            outputItemID = item.itemID,
            outputName = item.itemName,
            profession = item.professions[1],
            recipeSpellID = item.recipeSpellID,
            sourceUrl = "https://www.wowhead.com/spell=" .. tostring(item.recipeSpellID),
            reagents = item.components,
            isRoute = false,
        }
        NS.DragonflightHousing.recipes[#NS.DragonflightHousing.recipes + 1] = recipe
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
