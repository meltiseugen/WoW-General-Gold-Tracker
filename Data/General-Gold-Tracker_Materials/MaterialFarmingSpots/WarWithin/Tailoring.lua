local _, NS = ...
local Register = NS.RegisterMaterialFarmingSpot

local function C(x, y, label)
    return { x = x, y = y, label = label }
end

local function ItemUrl(itemID)
    return "https://www.wowhead.com/item=" .. tostring(itemID)
end

local ISLE_DORN_OPALCREG_CLOTH_ROUTE = {
    id = "tww-tailoring-isle-of-dorn-opalcreg-weavercloth-route",
    source = "Method Weavercloth guide, Warcraft Wiki Opalcreg page, and Opalcreg Worker NPC map pins",
    sourceUrls = {
        "https://www.method.gg/guides/weavercloth-and-darkmoon-card-farm-in-the-war-within",
        "https://warcraft.wiki.gg/wiki/Opalcreg",
        "https://www.wowhead.com/npc=226292/opalcreg-worker",
        "https://www.wowhead.com/item=228231/weavercloth",
    },
    mapName = "Isle of Dorn",
    location = "Opalcreg mine south of Dornogal, Nerubian humanoid packs",
    routeType = "humanoid-cloth-farm",
    density = "High",
    dropDifficulty = "Strong group farm and usable solo pull route. Weavercloth output improves with Tailoring "
        .. "cloth specializations.",
    tips = {
        "Method identifies Opalcreg as a strong Weavercloth and Darkmoon Card farm, especially with a 2x4 group.",
        "Stay near the mine ramps and worker packs instead of spreading into the full zone.",
        "Webbed ore nearby can add Weavercloth for dual gatherers, but humanoid kills are the cloth route itself.",
    },
    coords = {
        C(0.470, 0.612, "Opalcreg Worker west pack"),
        C(0.472, 0.624, "Opalcreg ramp pack"),
        C(0.476, 0.602, "Mine entrance worker pack"),
        C(0.480, 0.614, "Central Opalcreg pack"),
        C(0.484, 0.624, "East Opalcreg pack"),
        C(0.484, 0.626, "East mine return"),
    },
    confidence = "high",
}

local HALLOWFALL_VENERATION_CLOTH_ROUTE = {
    id = "tww-tailoring-hallowfall-veneration-grounds-weavercloth-route",
    source = "Wowhead Weavercloth comments and Hallowfall Veneration Grounds farming reports",
    sourceUrls = {
        "https://www.wowhead.com/item=228231/weavercloth",
        "https://www.wowhead.com/guide/the-war-within/professions/tailoring-overview",
    },
    mapName = "Hallowfall",
    location = "Veneration Grounds star-shaped Nightfall daily area",
    routeType = "humanoid-cloth-farm",
    density = "Medium to high",
    dropDifficulty = "Community-reported open-world cloth route; density depends on daily phase and competition.",
    tips = {
        "A Wowhead Weavercloth comment calls out the star-shaped Veneration Grounds area around 34.27, 53.23.",
        "Use this as an outdoor alternative when Opalcreg is crowded.",
        "Tailoring investment affects cloth yield, so compare results with and without your current spec path.",
    },
    coords = {
        C(0.3427, 0.5323, "Veneration Grounds cloth comment waypoint"),
        C(0.336, 0.526, "Western star point"),
        C(0.348, 0.522, "Northern star point"),
        C(0.352, 0.538, "Eastern star point"),
        C(0.341, 0.548, "Southern star point"),
    },
    confidence = "medium",
}

Register({
    itemID = 228231,
    itemName = "Weavercloth",
    expansion = "warWithin",
    professions = { "tailoring" },
    category = "Cloth",
    sourceUrls = { ItemUrl(228231) },
    summary = "War Within cloth from humanoid farms and cloth-specialized Tailoring, with Opalcreg as the "
        .. "main coordinate-backed outdoor route.",
    spots = {
        ISLE_DORN_OPALCREG_CLOTH_ROUTE,
        HALLOWFALL_VENERATION_CLOTH_ROUTE,
    },
})

local function RegisterSpecialtyCloth(itemID, itemName, specName)
    Register({
        itemID = itemID,
        itemName = itemName,
        expansion = "warWithin",
        professions = { "tailoring" },
        category = "Cloth",
        sourceUrls = {
            ItemUrl(itemID),
            "https://www.wowhead.com/guide/the-war-within/professions/tailoring-overview",
            "https://www.method.gg/guides/weavercloth-and-darkmoon-card-farm-in-the-war-within",
        },
        summary = itemName .. " is a specialty cloth sourced by Tailors from humanoid farming after choosing "
            .. specName .. " in the From Dawn Until Dusk specialization path.",
        spots = {
            {
                id = "tww-tailoring-isle-of-dorn-opalcreg-" .. string.lower(itemName) .. "-route",
                source = "Wowhead Tailoring overview and Method Opalcreg Weavercloth guide",
                sourceUrls = {
                    ItemUrl(itemID),
                    "https://www.wowhead.com/guide/the-war-within/professions/tailoring-overview",
                    "https://www.method.gg/guides/weavercloth-and-darkmoon-card-farm-in-the-war-within",
                },
                mapName = ISLE_DORN_OPALCREG_CLOTH_ROUTE.mapName,
                location = ISLE_DORN_OPALCREG_CLOTH_ROUTE.location,
                routeType = "specialized-humanoid-cloth-farm",
                density = ISLE_DORN_OPALCREG_CLOTH_ROUTE.density,
                dropDifficulty = "Requires Tailoring specialization investment; use dense humanoid routes and "
                    .. "expect lower volume than Weavercloth.",
                tips = {
                    "Wowhead notes Tailors can unlock " .. itemName .. " drops through From Dawn Until Dusk.",
                    "Method's Opalcreg farm is still the strongest researched humanoid density anchor.",
                    "Follower-dungeon reports were later nerfed, so this entry uses outdoor humanoid farms.",
                },
                coords = ISLE_DORN_OPALCREG_CLOTH_ROUTE.coords,
                confidence = "medium",
            },
            HALLOWFALL_VENERATION_CLOTH_ROUTE,
        },
    })
end

RegisterSpecialtyCloth(224824, "Duskweave", "Duskweave Tailoring")
RegisterSpecialtyCloth(224826, "Dawnweave", "Dawnweave Tailoring")
