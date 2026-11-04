local _, NS = ...

-- Expose existing catalog compositions as research records. Source quantities
-- stay in FarmingItems; these modules add no new recipes or vendor supplies.
function NS.RegisterMaterialCraftingRecords(expansion)
    for _, recipe in ipairs((NS.FarmingItems and NS.FarmingItems.items) or {}) do
        if recipe.expansion == expansion and type(recipe.components) == "table" and #recipe.components > 0 then
            local itemID = recipe.itemID
            local itemUrl = "https://www.wowhead.com/item=" .. tostring(itemID)
            local sourceUrl = recipe.recipeSpellID
                and ("https://www.wowhead.com/spell=" .. tostring(recipe.recipeSpellID)) or itemUrl
            local item = NS.MaterialFarmingSpots.items[itemID]
            if not item then
                local itemName = recipe.itemName
                if not itemName and C_Item and C_Item.GetItemNameByID then
                    itemName = C_Item.GetItemNameByID(itemID)
                end
                if not itemName and GetItemInfo then
                    itemName = GetItemInfo(itemID)
                end
                item = {
                    itemID = itemID,
                    itemName = itemName or ("Item " .. tostring(itemID)),
                    expansion = expansion,
                    category = recipe.tag,
                    sourceUrls = { itemUrl },
                    acquisitionType = "crafting",
                    summary = recipe.auctionable == false
                        and "Bound crafting input; cannot be sold on the Auction House. Expand its components to plan finished crafts."
                        or "Crafted or converted item from the existing material catalog. Expand its components for farmable inputs; vendor-only supplies are omitted. Check the recorded recipe requirements before crafting.",
                    spots = {},
                }
                NS.RegisterMaterialFarmingSpot(item)
            end
            item.sourceUrls = item.sourceUrls or { itemUrl }
            local found = false
            for _, url in ipairs(item.sourceUrls) do
                if url == sourceUrl then
                    found = true
                    break
                end
            end
            if not found then
                item.sourceUrls[#item.sourceUrls + 1] = sourceUrl
            end
            recipe.isRoute = false
            item.isRoute = false
            item.professions = recipe.professions
            item.components = recipe.components
            item.outputQuantity = recipe.outputQuantity
            item.recipeSpellID = recipe.recipeSpellID
            item.recipeSource = recipe.recipeSource
            item.recipeSourceLabel = recipe.recipeSourceLabel
            if recipe.auctionable ~= nil then
                item.auctionable = recipe.auctionable
            end
            for _, spot in ipairs(item.spots or {}) do
                spot.isRoute = false
            end
        end
    end
end
