local _, NS = ...

-- Several old mote records share their base spot arrays. Own both the array
-- and spot tables before composition registration or bundled catalog inserts.
for _, item in pairs(NS.MaterialFarmingSpots.items) do
    if item.expansion == "midnight" and item.category ~= "Ore" and item.category ~= "Herb" then
        local spots = {}
        for _, spot in ipairs(item.spots or {}) do
            local copy = {}
            for key, value in pairs(spot) do copy[key] = value end
            copy.isRoute = false
            spots[#spots + 1] = copy
        end
        item.spots = spots
        item.isRoute = false
    end
end

NS.RegisterMaterialCraftingRecords("midnight")
for _, recipe in ipairs((NS.FarmingItems and NS.FarmingItems.items) or {}) do
    if recipe.expansion == "midnight" and recipe.recipeSpellID and recipe.components then
        local item = NS.MaterialFarmingSpots.items[recipe.itemID]
        if item then
            item.qualityRank = recipe.qualityRank
            item.sourceUrls[#item.sourceUrls + 1] = "https://wago.tools/db2/SpellEffect?filter[SpellID]=" .. recipe.recipeSpellID
        end
    end
end
