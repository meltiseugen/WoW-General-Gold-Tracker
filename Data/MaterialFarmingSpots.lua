local _, NS = ...

NS.MaterialFarmingSpots = {
    dataVersion = 12,
    schemaVersion = 1,
    researchedAt = "2026-09-02",
    sourceNote = "Curated farming-spot seed data summarized from public farming guides, item/object database pages, and high-signal Wowhead comments. Comments are paraphrased, not copied. Items are only present when researched; missingItems tracks catalog entries still waiting on real research.",
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
