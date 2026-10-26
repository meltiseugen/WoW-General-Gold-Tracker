local _, NS = ...

NS.MaterialFarmingSpots = {
    dataVersion = 33,
    schemaVersion = 2,
    researchedAt = "2026-10-21",
    sourceNote = "Curated farming-spot data summarized from current retail item, NPC, object, instance, housing-guide, and high-signal comment sources, plus GGT's bundled Gathering route catalog. Burning Crusade mob and fishing-school routes retain every published coordinate without proximity deduplication. Wrath specialty farms cover clam contents, rare inscription drops, reputation items, legacy instance reagents, and dynamic housing lumber. Dynamic sources use explicitly labeled route anchors. Comments are paraphrased, not copied.",
    sources = {
        wowhead = "https://www.wowhead.com/",
        wowProfessions = "https://www.wow-professions.com/farming",
        wowdb = "https://www.wowdb.com/",
        method = "https://www.method.gg/guides/best-mining-and-herbalism-routes-for-the-war-within",
        skycoach = "https://skycoach.gg/blog/wow/articles/herbalism-guide",
        warcraftWiki = "https://warcraft.wiki.gg/",
        artisansOfAzeroth = "https://artisansofazeroth.com/",
    },
    items = {},
}

function NS.RegisterMaterialFarmingSpot(item)
    if type(item) ~= "table" or not item.itemID then
        return
    end

    item.researchStatus = item.researchStatus or "researched"
    NS.MaterialFarmingSpots.items[item.itemID] = item
end
