local _, NS = ...

-- Source-area navigation for the recipe scrolls in Drops > Recipes.
-- The bottle's random contents are not a deterministic crafting recipe.
local rows = NS.RecipeDropsData.rows
local catalog = NS.FarmCatalog
catalog.farms, catalog.byID = catalog.farms or {}, catalog.byID or {}
catalog.indexes, catalog.sourceCounts = catalog.indexes or {}, catalog.sourceCounts or {}
local function Copy(values)
    local copy = {}
    for _, value in ipairs(values or {}) do copy[#copy + 1] = value end
    return copy
end
local function Index(name, key, position)
    catalog.indexes[name] = catalog.indexes[name] or {}
    catalog.indexes[name][key] = catalog.indexes[name][key] or {}
    table.insert(catalog.indexes[name][key], position)
end
local farms, addedItems = {}, 0
for _, row in ipairs(rows) do
    local sources = {}
    for _, url in ipairs(row.sourceUrls) do
        sources[#sources + 1] = {siteName="Recipe acquisition research",url=url}
    end
    local farm = {
        id=row.farmID, name=row.itemName, primaryItemID=row.itemID,
        sourceRecordID=row.recordID, sourceType="curated", sourceDataset="GGTRecipeFarmData",
        sourceCategory="recipes", sourcePath="Drops > Recipes", activity="recipe",
        contentID=10, expansion="dragonflight", expansionLabel="Dragonflight",
        auctionable=true, saleMethod="unlearned-item", researchedAt="2026-10-23",
        summary=row.summary, sourceUrls=sources, targets={},
        mapIDs={1978}, mapNames={"Dragon Isles"}, routeCount=1,
        guide={
            label="Fishing reward recipe",
            requirement="Reach the Dragon Isles and use Fishing or eligible fishing-related rewards.",
            action="Obtain and open Draconic Recipe in a Bottle; keep a tradeable recipe scroll unlearned to sell it.",
            tips=Copy(row.tips),
        },
        details={
            "The source map opens the Dragon Isles without a fixed spawn pin. No specific fishing position or recipe outcome is guaranteed.",
            "The sale item is the named recipe scroll. The bottle is bound, and the item taught by the recipe is a separate product.",
        },
        mapOptions={ {
            id=row.farmID .. ":source-area", mapID=1978, mapLabel="Dragon Isles",
            label="Dragon Isles fishing rewards", location="Dragon Isles fishing and eligible reward sources",
            mapRole="source-area", pins={}, mapOnly=true, isRoute=false,
            routeType="fishing-reward-recipe", confidence="medium", inGameTested=false,
            density="Random reward; no measured yield",
            dropDifficulty="Chance to obtain the bottle, followed by random recipe contents; no guaranteed target recipe.",
        } },
    }
    farms[#farms + 1] = farm
    if not catalog.byID[farm.id] then
        if not (catalog.indexes.byItemID and catalog.indexes.byItemID[row.itemID]) then
            addedItems = addedItems + 1
        end
        local position = #catalog.farms + 1
        catalog.farms[position], catalog.byID[farm.id] = farm, position
        Index("byItemID",row.itemID,position)
        Index("byRecordID",row.recordID,position)
        Index("byActivity","recipe",position)
        Index("byExpansion","dragonflight",position)
        Index("bySourceCategory","recipes",position)
        Index("bySourceType","curated",position)
        Index("byMapID",1978,position)
    end
end
catalog.farmCount = #catalog.farms
catalog.uniqueItemCount = (catalog.uniqueItemCount or 0) + addedItems
catalog.sourceCounts.curatedRecipes = #farms
NS.RecipeFarmData = {rows=rows,farms=farms,researchedAt="2026-10-23"}
