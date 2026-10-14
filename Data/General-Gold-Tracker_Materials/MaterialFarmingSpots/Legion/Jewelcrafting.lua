local _, NS = ...
local Register = NS.RegisterMaterialFarmingSpot

local function C(x, y, label)
    return { x = x, y = y, label = label }
end

local function ItemUrl(itemID)
    return "https://www.wowhead.com/item=" .. tostring(itemID)
end

local PROSPECTING_SOURCE_URLS = {
    "https://www.wowhead.com/guide/legion-jewelcrafting",
    "https://www.wowhead.com/spell=31252/prospecting",
    "https://www.wow-professions.com/farming/leystone-ore-farming",
    "https://www.wow-professions.com/farming/felslate-farming",
    "https://artisansofazeroth.com/legion-mining-leveling/",
}

local LEYSTONE_PROSPECTING_ROUTE = {
    id = "legion-gems-suramar-leystone-prospecting-input",
    source = "Retail Wowhead Legion Jewelcrafting guide, Wowhead Prospecting comments, wow-professions Leystone guide, and Artisans of Azeroth retail Suramar route string",
    sourceUrls = PROSPECTING_SOURCE_URLS,
    mapName = "Suramar",
    location = "Suramar cave and river Leystone/Felslate seam route used as prospecting input",
    routeType = "prospecting-input-route",
    density = "High for shared Legion ore turnover",
    dropDifficulty = "Prospecting output is RNG; Leystone is the cheaper volume input and mostly yields uncommon gems and Gem Chips.",
    tips = {
        "Prospect in batches of five ore, or use Mass Prospect Leystone after discovering it.",
        "Use Leystone to build broad gem volume or to fish for the next gem-chip color before switching to Felslate.",
        "Mine Felslate replacements and seams on the same route instead of skipping them.",
    },
    coords = {
        C(0.2121, 0.1693, "AoA Suramar northwest route pin"),
        C(0.2183, 0.2310, "AoA Suramar northern cave approach"),
        C(0.2390, 0.2768, "AoA Suramar north river seam"),
        C(0.2797, 0.2905, "AoA Suramar ridge bend"),
        C(0.3016, 0.3189, "AoA Suramar north return"),
        C(0.3587, 0.3087, "AoA Suramar river approach"),
        C(0.4040, 0.2940, "Suramar cave waypoint from guide"),
        C(0.4220, 0.2990, "Behind-waterfall cave waypoint"),
        C(0.2830, 0.5620, "Guide cave waypoint"),
        C(0.2930, 0.5080, "Guide cave waypoint return"),
    },
    confidence = "high",
}

local FELSLATE_PROSPECTING_ROUTE = {
    id = "legion-gems-suramar-felslate-prospecting-input",
    source = "Retail Wowhead Legion Jewelcrafting guide, Wowhead Prospecting comments, wow-professions Felslate guide, and Artisans of Azeroth retail Suramar route string",
    sourceUrls = PROSPECTING_SOURCE_URLS,
    mapName = "Suramar",
    location = "Suramar seam-heavy loop for Felslate prospecting input",
    routeType = "prospecting-input-route",
    density = "Medium to high for Felslate replacements",
    dropDifficulty = "Felslate is rarer than Leystone but has much better rare-gem yield when prospected.",
    tips = {
        "The Wowhead Jewelcrafting guide identifies Felslate as the stronger rare-gem prospecting ore.",
        "Follow rivers and cave interiors because Legion seams spawn in those places.",
        "Only prospect Felslate when rare gem value beats selling the raw ore.",
    },
    coords = {
        C(0.2420, 0.5070, "Guide cave waypoint"),
        C(0.2830, 0.5620, "Guide southern cave waypoint"),
        C(0.3150, 0.2610, "Guide northern cave waypoint"),
        C(0.4040, 0.2940, "Guide north-central cave"),
        C(0.4220, 0.2990, "Guide waterfall cave"),
        C(0.2518, 0.3509, "AoA Suramar seam route pin"),
        C(0.2959, 0.4088, "AoA Suramar seam route pin"),
        C(0.2536, 0.3998, "AoA Suramar cave-return pin"),
        C(0.2235, 0.3480, "AoA Suramar northwestern route pin"),
        C(0.1940, 0.3855, "AoA Suramar western waterline"),
    },
    confidence = "high",
}

local UNCOMMON_GEM_SPOTS = {
    LEYSTONE_PROSPECTING_ROUTE,
    FELSLATE_PROSPECTING_ROUTE,
}

local RARE_GEM_SPOTS = {
    FELSLATE_PROSPECTING_ROUTE,
    LEYSTONE_PROSPECTING_ROUTE,
}

local function RegisterGem(itemID, itemName, quality, spots, summary)
    Register({
        itemID = itemID,
        itemName = itemName,
        expansion = "legion",
        professions = { "jewelcrafting" },
        category = "Gem",
        sourceUrls = {
            ItemUrl(itemID),
            "https://www.wowhead.com/guide/legion-jewelcrafting",
            "https://www.wowhead.com/spell=31252/prospecting",
        },
        summary = summary,
        qualityRank = quality,
        spots = spots,
    })
end

Register({
    itemID = 129100,
    itemName = "Gem Chip",
    expansion = "legion",
    professions = { "jewelcrafting", "inscription", "cooking" },
    category = "Gem Chip",
    sourceUrls = {
        ItemUrl(129100),
        "https://www.wowhead.com/guide/legion-jewelcrafting",
        "https://warcraft.wiki.gg/wiki/Gem_Chip",
    },
    summary = "Legion crafting reagent produced by prospecting Legion ores and milling Broken Isles herbs.",
    spots = { LEYSTONE_PROSPECTING_ROUTE, FELSLATE_PROSPECTING_ROUTE },
})

RegisterGem(130172, "Sangrite", "uncommon", UNCOMMON_GEM_SPOTS, "Uncommon red Legion gem from prospecting Leystone Ore and Felslate.")
RegisterGem(130173, "Deep Amber", "uncommon", UNCOMMON_GEM_SPOTS, "Uncommon orange Legion gem from prospecting Leystone Ore and Felslate.")
RegisterGem(130174, "Azsunite", "uncommon", UNCOMMON_GEM_SPOTS, "Uncommon yellow Legion gem from prospecting Leystone Ore and Felslate.")
RegisterGem(130175, "Chaotic Spinel", "uncommon", UNCOMMON_GEM_SPOTS, "Uncommon green Legion gem from prospecting Leystone Ore and Felslate.")
RegisterGem(130176, "Skystone", "uncommon", UNCOMMON_GEM_SPOTS, "Uncommon blue Legion gem from prospecting Leystone Ore and Felslate.")
RegisterGem(130177, "Queen's Opal", "uncommon", UNCOMMON_GEM_SPOTS, "Uncommon purple Legion gem from prospecting Leystone Ore and Felslate.")
RegisterGem(130178, "Furystone", "rare", RARE_GEM_SPOTS, "Rare red Legion gem best treated as Felslate prospecting output, with Leystone as lower-yield backup.")
RegisterGem(130179, "Eye of Prophecy", "rare", RARE_GEM_SPOTS, "Rare orange Legion gem best treated as Felslate prospecting output, with Leystone as lower-yield backup.")
RegisterGem(130180, "Dawnlight", "rare", RARE_GEM_SPOTS, "Rare yellow Legion gem best treated as Felslate prospecting output, with Leystone as lower-yield backup.")
RegisterGem(130181, "Pandemonite", "rare", RARE_GEM_SPOTS, "Rare green Legion gem best treated as Felslate prospecting output, with Leystone as lower-yield backup.")
RegisterGem(130182, "Maelstrom Sapphire", "rare", RARE_GEM_SPOTS, "Rare blue Legion gem best treated as Felslate prospecting output, with Leystone as lower-yield backup.")
RegisterGem(130183, "Shadowruby", "rare", RARE_GEM_SPOTS, "Rare purple Legion gem best treated as Felslate prospecting output, with Leystone as lower-yield backup.")
