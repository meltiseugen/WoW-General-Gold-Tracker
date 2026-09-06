local _, NS = ...
local Register = NS.RegisterMaterialFarmingSpot

local function C(x, y, label)
    return { x = x, y = y, label = label }
end

local function ItemUrl(itemID)
    return "https://www.wowhead.com/item=" .. tostring(itemID)
end

local FREEHOLD_DISENCHANT_ROUTE = {
    id = "bfa-freehold-cloth-and-disenchant-feed-route",
    source = "Wowhead enchanting guide, Wowhead material comments, and BFA cloth farm reports",
    sourceUrls = {
        "https://www.wowhead.com/guide/battle-for-azeroth-1-175-enchanting-profession-guide-6279",
        "https://www.wowhead.com/item=152875/gloom-dust",
        "https://www.wowhead.com/item=152876/umbra-shard",
        "https://www.wowhead.com/item=152877/veiled-crystal",
        "https://www.wow-professions.com/farming/tidespray-linen-farming",
    },
    mapName = "Tiragarde Sound",
    location = "Outdoor Freehold cloth and BFA gear disenchant feed",
    routeType = "disenchant-feed-farm",
    density = "Medium",
    dropDifficulty = "Indirect. Farm cloth and BFA greens/blues, then craft or disenchant eligible gear.",
    tips = {
        "Gloom Dust mainly comes from disenchanting green BFA items.",
        "Umbra Shard comes from rare-quality BFA items, with some chance from epics.",
        "Veiled Crystal comes from epic BFA items or high-value disenchant feed.",
    },
    coords = {
        C(0.742, 0.806, "Northern Freehold packs"),
        C(0.784, 0.836, "Central Freehold packs"),
        C(0.816, 0.786, "Eastern pirate packs"),
        C(0.766, 0.742, "Bridge and lower yard"),
    },
    confidence = "medium",
}

local BORALUS_SCRAPPER_ROUTE = {
    id = "bfa-boralus-scrap-o-matic-expulsom",
    source = "Wowhead Scrapper guide, Wowhead Expulsom comments, and wow-professions Expulsom guide",
    sourceUrls = {
        "https://www.wowhead.com/guide/how-the-scrapper-in-battle-for-azeroth-works",
        "https://www.wowhead.com/item=152668/expulsom",
        "https://www.wow-professions.com/farming/how-to-get-expulsom",
    },
    mapName = "Boralus",
    location = "Scrap-o-Matic 1000 in Tradewinds Market",
    routeType = "scrapper-material-conversion",
    density = "Stationary",
    dropDifficulty = "Indirect. Requires BFA armor or weapon inputs to scrap.",
    tips = {
        "Alliance scrapper is reported at Boralus 77,16.",
        "Scrap crafted or looted BFA gear for Expulsom and material returns.",
        "Compare against disenchanting before scrapping valuable greens or blues.",
    },
    coords = {
        C(0.770, 0.160, "Scrap-o-Matic 1000"),
    },
    confidence = "high",
}

local DAZARALOR_SCRAPPER_ROUTE = {
    id = "bfa-dazaralor-shred-master-expulsom",
    source = "Wowhead Scrapper guide, Wowhead Expulsom comments, and wow-professions Expulsom guide",
    sourceUrls = {
        "https://www.wowhead.com/guide/how-the-scrapper-in-battle-for-azeroth-works",
        "https://www.wowhead.com/item=152668/expulsom",
        "https://www.wow-professions.com/farming/how-to-get-expulsom",
    },
    mapName = "Dazar'alor",
    location = "Shred-Master Mk1 in the Terrace of Crafters",
    routeType = "scrapper-material-conversion",
    density = "Stationary",
    dropDifficulty = "Indirect. Requires BFA armor or weapon inputs to scrap.",
    tips = {
        "Horde scrapper is reported at Dazar'alor 44.9,40.2.",
        "Scrap crafted or looted BFA gear for Expulsom and material returns.",
        "Use TSM prices to decide whether to scrap, disenchant, or sell the item.",
    },
    coords = {
        C(0.449, 0.402, "Shred-Master Mk1"),
    },
    confidence = "high",
}

local function RegisterEnchanting(itemID, itemName, spots, summary)
    Register({
        itemID = itemID,
        itemName = itemName,
        expansion = "battleForAzeroth",
        professions = { "enchanting" },
        category = "Enchanting",
        sourceUrls = { ItemUrl(itemID) },
        summary = summary,
        spots = spots,
    })
end

RegisterEnchanting(152875, "Gloom Dust", {
    FREEHOLD_DISENCHANT_ROUTE,
}, "Common BFA enchanting material from disenchanting eligible green BFA gear.")
RegisterEnchanting(152876, "Umbra Shard", {
    FREEHOLD_DISENCHANT_ROUTE,
}, "BFA shard from disenchanting rare-quality BFA gear and some epic results.")
RegisterEnchanting(152877, "Veiled Crystal", {
    FREEHOLD_DISENCHANT_ROUTE,
}, "BFA crystal from disenchanting epic BFA gear.")
RegisterEnchanting(152668, "Expulsom", {
    BORALUS_SCRAPPER_ROUTE,
    DAZARALOR_SCRAPPER_ROUTE,
}, "BFA scrapper reagent created by scrapping crafted or looted BFA gear.")
