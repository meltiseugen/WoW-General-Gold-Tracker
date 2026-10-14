local _, NS = ...
local Register = NS.RegisterMaterialFarmingSpot

local function C(x, y, label)
    return { x = x, y = y, label = label }
end

local function ItemUrl(itemID)
    return "https://www.wowhead.com/item=" .. tostring(itemID)
end

local OPALCREG_DISENCHANT_FEED_ROUTE = {
    id = "tww-enchanting-isle-of-dorn-opalcreg-disenchant-feed-route",
    source = "Wowhead and Method enchanting guides plus Opalcreg humanoid farming sources",
    sourceUrls = {
        "https://www.wowhead.com/item=219946/storm-dust",
        "https://www.wowhead.com/guide/the-war-within/professions/enchanting-overview",
        "https://www.wowhead.com/guide/the-war-within/professions/enchanting-leveling",
        "https://www.method.gg/guides/the-war-within-enchanting-profession-leveling-guide",
        "https://www.method.gg/guides/weavercloth-and-darkmoon-card-farm-in-the-war-within",
        "https://www.wowhead.com/npc=226292/opalcreg-worker",
    },
    mapName = "Isle of Dorn",
    location = "Opalcreg humanoid packs for War Within green gear to disenchant",
    routeType = "disenchant-feed-farm",
    density = "Medium",
    dropDifficulty = "Indirect but directly farmable through disenchantable gear; Storm Dust comes from "
        .. "disenchanting uncommon War Within items.",
    tips = {
        "Farm humanoids for green War Within drops, then disenchant rather than vendoring them.",
        "The route doubles as a Weavercloth farm, so compare cloth sale value against disenchant value.",
        "Higher-rank Storm Dust yield depends on enchanting skill and specialization, not on a separate outdoor spawn.",
    },
    coords = {
        C(0.470, 0.612, "Opalcreg Worker west pack"),
        C(0.472, 0.624, "Opalcreg ramp pack"),
        C(0.476, 0.602, "Mine entrance worker pack"),
        C(0.480, 0.614, "Central Opalcreg pack"),
        C(0.484, 0.624, "East Opalcreg pack"),
        C(0.484, 0.626, "East mine return"),
    },
    confidence = "medium",
}

local VENERATION_DISENCHANT_FEED_ROUTE = {
    id = "tww-enchanting-hallowfall-veneration-disenchant-feed-route",
    source = "Wowhead Storm Dust page, enchanting guides, and Weavercloth comment route",
    sourceUrls = {
        "https://www.wowhead.com/item=219946/storm-dust",
        "https://www.wowhead.com/guide/the-war-within/professions/enchanting-overview",
        "https://www.wowhead.com/guide/the-war-within/professions/enchanting-leveling",
        "https://www.wowhead.com/item=228231/weavercloth",
    },
    mapName = "Hallowfall",
    location = "Veneration Grounds humanoid cloth and gear-feed route",
    routeType = "disenchant-feed-farm",
    density = "Medium",
    dropDifficulty = "Supplemental gear-feed route; use it when Opalcreg is contested or Hallowfall cloth is "
        .. "also valuable.",
    tips = {
        "Storm Dust is not a creature drop; the farm target is disenchantable uncommon gear.",
        "A Wowhead Weavercloth comment places this open-world farm around 34.27, 53.23.",
        "Keep green gear for disenchanting and sell non-disenchantable materials separately.",
    },
    coords = {
        C(0.3427, 0.5323, "Veneration Grounds gear-feed waypoint"),
        C(0.336, 0.526, "Western star point"),
        C(0.348, 0.522, "Northern star point"),
        C(0.352, 0.538, "Eastern star point"),
        C(0.341, 0.548, "Southern star point"),
    },
    confidence = "medium",
}

local function RegisterStormDust(itemID, qualityRank)
    Register({
        itemID = itemID,
        itemName = "Storm Dust",
        expansion = "warWithin",
        professions = { "enchanting" },
        category = "Enchanting",
        qualityRank = qualityRank,
        sourceUrls = { ItemUrl(itemID) },
        summary = "War Within enchanting material from disenchanting uncommon gear; coordinate-backed farms "
            .. "are gear-feed routes, not direct dust spawns.",
        spots = {
            OPALCREG_DISENCHANT_FEED_ROUTE,
            VENERATION_DISENCHANT_FEED_ROUTE,
        },
    })
end

RegisterStormDust(219946, 1)
RegisterStormDust(219947, 2)
RegisterStormDust(219948, 3)

local function RegisterDisenchantMaterial(itemID, itemName, qualityRank, gearQuality)
    Register({
        itemID = itemID,
        itemName = itemName,
        expansion = "warWithin",
        professions = { "enchanting" },
        category = "Enchanting",
        qualityRank = qualityRank,
        sourceUrls = {
            ItemUrl(itemID),
            "https://www.wowhead.com/guide/the-war-within/professions/enchanting-overview",
            "https://www.wowhead.com/guide/the-war-within/professions/enchanting-leveling",
        },
        summary = "War Within enchanting material from disenchanting " .. gearQuality .. " gear. "
            .. "Coordinate-backed farms are gear-feed routes, not direct outdoor reagent spawns.",
        spots = {
            OPALCREG_DISENCHANT_FEED_ROUTE,
            VENERATION_DISENCHANT_FEED_ROUTE,
        },
    })
end

RegisterDisenchantMaterial(219949, "Gleaming Shard", 1, "rare")
RegisterDisenchantMaterial(219950, "Gleaming Shard", 2, "rare")
RegisterDisenchantMaterial(219951, "Gleaming Shard", 3, "rare")
RegisterDisenchantMaterial(219952, "Refulgent Crystal", 1, "epic")
RegisterDisenchantMaterial(219953, "Refulgent Crystal", 2, "epic")
RegisterDisenchantMaterial(219954, "Refulgent Crystal", 3, "epic")
