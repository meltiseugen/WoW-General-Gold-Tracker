local _, NS = ...

-- Dragonflight recipe-scroll products moved from Materials on 2026-10-23.
-- Keep this curated module separate from the generated upstream snapshot.
local catalog = assert(NS.CatalogDropsData)
if catalog.recipesCuratedLoaded then return end
local rows = {
    { itemID = 191544, itemName = "Recipe: Cauldron of the Pooka" },
    { itemID = 191587, itemName = "Recipe: Somniferous Incense" },
    { itemID = 191589, itemName = "Recipe: Fervid Incense" },
    { itemID = 194671, itemName = "Design: \"Rhinestone\" Sunglasses" },
    { itemID = 198109, itemName = "Recipe: Churnbelly Tea" },
    { itemID = 198113, itemName = "Recipe: Timely Demise" },
    { itemID = 198114, itemName = "Recipe: Filet of Fangs" },
    { itemID = 198115, itemName = "Recipe: Seamoth Surprise" },
    { itemID = 198116, itemName = "Recipe: Salt-Baked Fishcake" },
    { itemID = 198714, itemName = "Plans: Prototype Regal Barding Framework" },
    { itemID = 198891, itemName = "Technique: Cliffside Wylderdrake: Conical Head" },
    { itemID = 198896, itemName = "Technique: Highland Drake: Spined Neck" },
    { itemID = 198899, itemName = "Technique: Renewed Proto-Drake: Predator Pattern" },
    { itemID = 198903, itemName = "Technique: Windborne Velocidrake: Spined Head" },
    { itemID = 198905, itemName = "Technique: Illusion Parchment: Aqua Torrent" },
    { itemID = 198910, itemName = "Technique: Illusion Parchment: Shadow Orb" },
    { itemID = 199228, itemName = "Schematic: Grease Grenade" },
    { itemID = 199232, itemName = "Schematic: Bundle of Fireworks" },
    { itemID = 199236, itemName = "Schematic: D.U.C.K.O.Y." },
    { itemID = 205127, itemName = "Technique: Winding Slitherdrake: Blue and Silver Armor" },
    { itemID = 205128, itemName = "Technique: Winding Slitherdrake: Yellow and Silver Armor" },
    { itemID = 205129, itemName = "Technique: Winding Slitherdrake: Curved Chin Horn" },
    { itemID = 205161, itemName = "Plans: Heat-Resistant Rescue Ring" },
}
local tips = {
    "Fish in Dragon Isles waters and loot eligible lunkers; Draconic Recipe in a Bottle is a bound container whose tradeable recipe contents can be sold.",
    "The named recipe is a random result. Verify the buyer's profession and unlock needs; the bottle itself is not an AH product.",
}
for _, row in ipairs(rows) do
    row.recordID = "recipes:Dragonflight:" .. row.itemID
    row.farmID = "ggt:recipe:item:" .. row.itemID
    row.farmName, row.quantity, row.contentID = row.itemName, 1, 10
    row.expansion, row.expansionLabel = "dragonflight", "Dragonflight"
    row.locationLabel = "Dragon Isles"
    row.auctionable, row.randomOutput = true, true
    row.summary = "Saleable Dragonflight recipe or schematic obtainable from fishing-related rewards."
    row.tips = tips
    row.sourceUrls = { "https://www.wowhead.com/item=" .. row.itemID,
        "https://www.wowhead.com/item=198438/draconic-recipe-in-a-bottle" }
end
local previousCount = #(catalog.categories.recipes or {})
catalog.categories.recipes = rows
catalog.categoryCounts.recipes = #rows
catalog.itemSourceCount = (catalog.itemSourceCount or 0) - previousCount + #rows
catalog.recipesCuratedLoaded = true
NS.RecipeDropsData = { researchedAt = "2026-10-23", rows = rows }
