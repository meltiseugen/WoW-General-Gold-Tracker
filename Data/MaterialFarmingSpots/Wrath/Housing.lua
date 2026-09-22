local _, NS = ...

NS.WrathHousing = {
    dataVersion = 1,
    researchedAt = "2026-09-21",
    sourceUrl = "https://www.wowhead.com/guide/player-housing/crafting-decor-items",
    updateUrl = "https://www.wowhead.com/news/over-200-decor-recipe-costs-nerfed-in-patch-12-1-5-382919",
    reagentScope = "Farmable and auction-relevant inputs only; vendor dyes, vials, parchment, and vendor-only engineering parts are intentionally omitted.",
    quantityVersion = "Patch 12.1.5 PTR reductions published 2026-09-15",
    recipes = {
        { outputItemID = 258213, outputName = "Icecrown Plague Canister", profession = "alchemy", reagents = { { itemID = 251762, quantity = 12 }, { itemID = 40077, quantity = 4 }, { itemID = 33447, quantity = 4 }, { itemID = 36908, quantity = 2 }, { itemID = 35625, quantity = 1 }, { itemID = 43102, quantity = 1 } } },
        { outputItemID = 258212, outputName = "San'layn Blood Orb", profession = "alchemy", reagents = { { itemID = 251762, quantity = 8 }, { itemID = 36905, quantity = 8 }, { itemID = 35627, quantity = 3 }, { itemID = 36908, quantity = 1 } } },
        { outputItemID = 257040, outputName = "Dalaran Runic Anvil", profession = "blacksmithing", reagents = { { itemID = 251762, quantity = 8 }, { itemID = 37663, quantity = 5 }, { itemID = 45087, quantity = 2 }, { itemID = 35624, quantity = 2 } } },
        { outputItemID = 264676, outputName = "Dalaran Sewer Gate", profession = "blacksmithing", reagents = { { itemID = 251762, quantity = 15 }, { itemID = 37663, quantity = 4 }, { itemID = 45087, quantity = 2 }, { itemID = 35622, quantity = 1 } } },
        { outputItemID = 264710, outputName = "Dalaran Sun Sconce", profession = "blacksmithing", reagents = { { itemID = 251762, quantity = 5 }, { itemID = 37663, quantity = 2 }, { itemID = 36860, quantity = 2 } } },
        { outputItemID = 257094, outputName = "Mark of the Mages' Eye", profession = "enchanting", reagents = { { itemID = 251762, quantity = 5 }, { itemID = 34057, quantity = 2 }, { itemID = 34055, quantity = 4 }, { itemID = 34054, quantity = 5 } } },
        { outputItemID = 257101, outputName = "Stampwhistle's Postal Portal", profession = "enchanting", reagents = { { itemID = 251762, quantity = 12 }, { itemID = 34057, quantity = 2 }, { itemID = 34055, quantity = 2 }, { itemID = 41163, quantity = 3 }, { itemID = 41510, quantity = 4 } } },
        { outputItemID = 264708, outputName = "Home Defense Gadget", profession = "engineering", reagents = { { itemID = 251762, quantity = 10 }, { itemID = 39681, quantity = 5 }, { itemID = 39682, quantity = 2 } } },
        { outputItemID = 264711, outputName = "Joybuzz's Joyful Wall of Trains", profession = "engineering", reagents = { { itemID = 251762, quantity = 18 }, { itemID = 41163, quantity = 8 }, { itemID = 39683, quantity = 5 }, { itemID = 39682, quantity = 2 }, { itemID = 39681, quantity = 1 } } },
        { outputItemID = 264707, outputName = "Resizable All-Purpose Gear", profession = "engineering", reagents = { { itemID = 251762, quantity = 7 }, { itemID = 41163, quantity = 8 } } },
        { outputItemID = 258204, outputName = "Dalaran Post", profession = "inscription", reagents = { { itemID = 251762, quantity = 8 }, { itemID = 36916, quantity = 5 }, { itemID = 43126, quantity = 3 } } },
        { outputItemID = 258207, outputName = "Dalaran Scholar's Bookcase", profession = "inscription", reagents = { { itemID = 251762, quantity = 16 }, { itemID = 37663, quantity = 5 }, { itemID = 43127, quantity = 4 }, { itemID = 43126, quantity = 4 }, { itemID = 36931, quantity = 3 } } },
        { outputItemID = 258210, outputName = "Dalaran Street Sign", profession = "inscription", reagents = { { itemID = 251762, quantity = 5 }, { itemID = 41163, quantity = 4 }, { itemID = 43126, quantity = 3 } } },
        { outputItemID = 258209, outputName = "Kirin Tor Crate", profession = "inscription", reagents = { { itemID = 251762, quantity = 5 }, { itemID = 43127, quantity = 2 }, { itemID = 36931, quantity = 2 } } },
        { outputItemID = 258203, outputName = "Silver Dalaran Bench", profession = "inscription", reagents = { { itemID = 251762, quantity = 10 }, { itemID = 37663, quantity = 2 }, { itemID = 43127, quantity = 4 } } },
        { outputItemID = 258211, outputName = "Kirin Tor Glass Table", profession = "jewelcrafting", reagents = { { itemID = 251762, quantity = 10 }, { itemID = 36916, quantity = 6 }, { itemID = 42225, quantity = 2 } } },
        { outputItemID = 258208, outputName = "Kirin Tor Sun Chandelier", profession = "jewelcrafting", reagents = { { itemID = 251762, quantity = 8 }, { itemID = 36916, quantity = 4 }, { itemID = 41285, quantity = 3 } } },
        { outputItemID = 257693, outputName = "Snowfall Tribe Scare-Totem", profession = "leatherworking", reagents = { { itemID = 251762, quantity = 7 }, { itemID = 38425, quantity = 5 }, { itemID = 35627, quantity = 4 }, { itemID = 44128, quantity = 1 } } },
        { outputItemID = 258205, outputName = "Wolvar Postbag", profession = "leatherworking", reagents = { { itemID = 251762, quantity = 8 }, { itemID = 38425, quantity = 8 }, { itemID = 35623, quantity = 3 }, { itemID = 35624, quantity = 2 } } },
        { outputItemID = 258206, outputName = "Gilded Dalaran Banner", profession = "tailoring", reagents = { { itemID = 251762, quantity = 8 }, { itemID = 41595, quantity = 3 }, { itemID = 36925, quantity = 1 } } },
        { outputItemID = 258298, outputName = "Kirin Tor Skyline Banner", profession = "tailoring", reagents = { { itemID = 251762, quantity = 15 }, { itemID = 41595, quantity = 3 }, { itemID = 41594, quantity = 3 } } },
    },
}

for _, recipe in ipairs(NS.WrathHousing.recipes) do
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
