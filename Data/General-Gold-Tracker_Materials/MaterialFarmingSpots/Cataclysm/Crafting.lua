local _, NS = ...
local Register = NS.RegisterMaterialFarmingSpot

-- Recipe quantities live in the main material catalog so the existing recursive
-- component UI and farming metadata use the same definition.
for _, recipe in ipairs((NS.FarmingItems and NS.FarmingItems.items) or {}) do
    if recipe.expansion == "cataclysm" and type(recipe.components) == "table" then
        local sourceUrl = "https://www.wowhead.com/spell=" .. tostring(recipe.recipeSpellID)
        local item = NS.MaterialFarmingSpots.items[recipe.itemID]
        if not item then
            item = {
                itemID = recipe.itemID,
                itemName = recipe.itemName,
                expansion = "cataclysm",
                professions = recipe.professions,
                category = recipe.tag,
                acquisitionType = "crafting",
                researchedAt = "2026-10-19",
                sourceUrls = { "https://www.wowhead.com/item=" .. tostring(recipe.itemID), sourceUrl },
                summary = recipe.auctionable == false
                    and "Bound crafting input; cannot be sold on the Auction House. Expand its components to plan the finished crafts."
                    or "Profession-crafted item. Expand its components for farmable inputs; vendor-only reagents are omitted. The recipe must be learned before crafting.",
                -- A crafting recipe has no outdoor spawn location.
                spots = {},
            }
            Register(item)
        else
            item.sourceUrls = item.sourceUrls or {}
            item.sourceUrls[#item.sourceUrls + 1] = sourceUrl
        end
        item.isRoute = false
        item.professions = recipe.professions
        item.auctionable = recipe.auctionable
        item.components = recipe.components
        item.outputQuantity = recipe.outputQuantity
        item.recipeSpellID = recipe.recipeSpellID
        item.recipeSource = recipe.recipeSource
        item.recipeSourceLabel = recipe.recipeSourceLabel
        for _, spot in ipairs(item.spots or {}) do
            spot.isRoute = false
        end
    end
end
