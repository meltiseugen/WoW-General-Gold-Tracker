local _, NS = ...
local Register = NS.RegisterMaterialFarmingSpot

local function C(x, y, label)
    return { x = x, y = y, label = label }
end

local function ItemUrl(itemID)
    return "https://www.wowhead.com/item=" .. tostring(itemID)
end

local TOL_BARAD_LEATHER_ROUTE = {
    id = "cataclysm-savage-leather-tol-barad-crocolisk-dailies",
    source = "Wowhead Savage Leather guide, Warcraft Tavern Savage Leather guide, and Wowhead Tol Barad farming comments",
    sourceUrls = {
        ItemUrl(52976),
        "https://www.warcrafttavern.com/cataclysm/guides/savage-leather-farming-guide/",
    },
    mapName = "Tol Barad",
    location = "Crocolisk daily area west of Baradin Hold",
    routeType = "skinning-loop",
    density = "High when daily traffic is active",
    dropDifficulty = "Excellent if other players are killing and looting; weaker when the daily area is empty.",
    tips = {
        "Skin crocolisks around Baradin Hold after players finish daily kills.",
        "Best shortly after a Tol Barad battle when daily traffic spikes.",
        "Use this for Savage Leather volume; Pristine Hide is a rare side result.",
    },
    coords = {
        C(0.360, 0.382, "West Baradin Hold crocolisks"),
        C(0.404, 0.420, "Central crocolisk packs"),
        C(0.442, 0.470, "East crocolisk packs"),
        C(0.390, 0.514, "Southern crocolisk return"),
    },
    confidence = "high",
}

local TWILIGHT_HIGHLANDS_LEATHER_ROUTE = {
    id = "cataclysm-savage-leather-twilight-highlands-obsidian-forest",
    source = "Retail Wowhead skinning material pages and community skinning route reports",
    sourceUrls = {
        ItemUrl(52976),
        ItemUrl(52979),
        "https://www.wowhead.com/npc=43971/stonescale-drake",
    },
    mapName = "Twilight Highlands",
    location = "Obsidian Forest and southeast Kirthaven dragonkin/beast route",
    routeType = "skinning-loop",
    density = "Medium to high",
    dropDifficulty = "Good mixed leather and scale route with more movement than Tol Barad.",
    tips = {
        "Use this when Tol Barad is quiet or too contested.",
        "Skin dragonkin for Deepsea Scale side value and beasts for Savage Leather.",
    },
    coords = {
        C(0.600, 0.248, "Kirthaven southeast start"),
        C(0.646, 0.292, "Obsidian Forest west"),
        C(0.690, 0.342, "Obsidian Forest center"),
        C(0.718, 0.420, "Obsidian Forest east"),
        C(0.666, 0.488, "South return"),
    },
    confidence = "medium",
}

local DEEPSEA_SCALE_ROUTE = {
    id = "cataclysm-deepsea-scale-tol-barad-peninsula-tank",
    source = "Wowhead Deepsea Scale guide, Wowhead Deepsea Scale comments, and Shark Tank quest page",
    sourceUrls = {
        ItemUrl(52982),
        "https://www.wowhead.com/quest=28050/shark-tank",
    },
    mapName = "Tol Barad Peninsula",
    location = "Cape of Lost Hope northern shipwreck area, Tank skinning route",
    routeType = "elite-skinning-loop",
    density = "Localized",
    dropDifficulty = "High if solo undergeared. Tank respawns quickly, but killing him can be slow without a durable character.",
    tips = {
        "Farm Tank when you can kill or kite him reliably.",
        "The farm is best when other players leave skinnable Tank corpses during daily quest traffic.",
        "Use Twilight Highlands threshers if Tank is too slow or crowded.",
    },
    coords = {
        C(0.540, 0.178, "Cape of Lost Hope north patrol"),
        C(0.574, 0.152, "Northern shipwreck patrol"),
        C(0.612, 0.188, "East patrol turn"),
    },
    confidence = "high",
}

local DEEPHOLM_DRAKE_SCALE_ROUTE = {
    id = "cataclysm-blackened-dragonscale-deepholm-stonescale-drakes",
    source = "Retail Wowhead Blackened Dragonscale item page and Stonescale Drake NPC map pins",
    sourceUrls = {
        ItemUrl(52979),
        "https://www.wowhead.com/npc=43971/stonescale-drake",
        "https://www.wowhead.com/item=62782/dragon-flank",
    },
    mapName = "Deepholm",
    location = "Alabaster Shelf and southern Pale Roost Stonescale Drake route",
    routeType = "skinning-loop",
    density = "Medium",
    dropDifficulty = "Focused dragonkin skinning route; useful when Blackened Dragonscale and Dragon Flank both sell.",
    tips = {
        "Stay on the southern drake shelf instead of widening into sparse Deepholm loops.",
        "Loot for Dragon Flank before skinning for Blackened Dragonscale side value.",
    },
    coords = {
        C(0.526, 0.794, "West drake skinning pin"),
        C(0.526, 0.816, "Northwest drake skinning pin"),
        C(0.532, 0.802, "Central west drake skinning pin"),
        C(0.542, 0.848, "Southwest drake skinning pin"),
        C(0.562, 0.884, "South drake skinning pin"),
        C(0.574, 0.854, "Southeast drake skinning pin"),
        C(0.586, 0.838, "East drake skinning pin"),
        C(0.596, 0.832, "Far east drake skinning pin"),
    },
    confidence = "high",
}

local function RegisterSkinning(itemID, itemName, category, spots, summary)
    Register({
        itemID = itemID,
        itemName = itemName,
        expansion = "cataclysm",
        professions = { "skinning", "leatherworking" },
        category = category,
        sourceUrls = { ItemUrl(itemID), ItemUrl(52976) },
        summary = summary,
        spots = spots,
    })
end

RegisterSkinning(52977, "Savage Leather Scraps", "Scrap", { TOL_BARAD_LEATHER_ROUTE, TWILIGHT_HIGHLANDS_LEATHER_ROUTE }, "Lower-yield Cataclysm skinning material from eligible beasts and dragonkin.")
RegisterSkinning(52976, "Savage Leather", "Leather", { TOL_BARAD_LEATHER_ROUTE, TWILIGHT_HIGHLANDS_LEATHER_ROUTE }, "Baseline Cataclysm leather from dense skinnable beast and dragonkin routes.")
RegisterSkinning(52980, "Pristine Hide", "Hide", { TOL_BARAD_LEATHER_ROUTE, TWILIGHT_HIGHLANDS_LEATHER_ROUTE }, "Rare Cataclysm skinning side material from eligible Cataclysm skins.")
RegisterSkinning(52979, "Blackened Dragonscale", "Scale", { DEEPHOLM_DRAKE_SCALE_ROUTE, TWILIGHT_HIGHLANDS_LEATHER_ROUTE }, "Cataclysm scale material directly skinned from dragonkin, with Deepholm Stonescale Drakes as a focused route.")
RegisterSkinning(52982, "Deepsea Scale", "Scale", { DEEPSEA_SCALE_ROUTE, TWILIGHT_HIGHLANDS_LEATHER_ROUTE }, "Cataclysm scale material from skinnable aquatic and dragonkin targets, with Tank as a strong focused route.")
