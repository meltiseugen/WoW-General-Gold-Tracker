local _, NS = ...
local Register = NS.RegisterMaterialFarmingSpot

local function C(x, y, label)
    return { x = x, y = y, label = label }
end

local function ItemUrl(itemID)
    return "https://www.wowhead.com/item=" .. tostring(itemID)
end

local AZURE_SPAN_BRACKENHIDE_CLOTH_ROUTE = {
    id = "dragonflight-azure-span-brackenhide-cloth-route",
    source = "wow-professions Tattered Wildercloth guide, Wowhead Duskpaw Hidestitcher and Gnawbone Totemchewer NPC map pins",
    sourceUrls = {
        "https://www.wow-professions.com/farming/tattered-wildercloth-farming",
        "https://www.wow-professions.com/farming/wildercloth-farming",
        "https://www.wowhead.com/item=193050/tattered-wildercloth",
        "https://www.wowhead.com/npc=187941/duskpaw-hidestitcher",
        "https://www.wowhead.com/npc=187936/gnawbone-totemchewer",
    },
    mapName = "The Azure Span",
    location = "Brackenhide Brinetooth and gnoll humanoid packs",
    routeType = "humanoid-cloth-farm",
    density = "High",
    dropDifficulty = "Easy to moderate. Strongest with fast tagging and Tailoring cloth specialization.",
    tips = {
        "Farm dense gnoll humanoid packs rather than roaming sparse outdoor camps.",
        "Brackenhide humanoids can also feed disenchanting through Dragonflight green drops.",
        "Use group tagging only where current loot rules allow it.",
    },
    coords = {
        C(0.234, 0.424, "Duskpaw Hidestitcher west hut"),
        C(0.238, 0.436, "Duskpaw Hidestitcher east pack"),
        C(0.246, 0.404, "Hidestitcher north pack"),
        C(0.222, 0.404, "Gnawbone Totemchewer west pack"),
        C(0.244, 0.400, "Gnawbone Totemchewer central pack"),
    },
    confidence = "high",
}

local AZURE_SPAN_KEY_BASEMENT_CLOTH_ROUTE = {
    id = "dragonflight-azure-span-key-basement-wildercloth-route",
    source = "Wowhead Tattered Wildercloth and Wildercloth comments with Key Basement 2x4 coordinate pins",
    sourceUrls = {
        "https://www.wowhead.com/item=193050/tattered-wildercloth",
        "https://www.wowhead.com/item=193922/wildercloth",
        "https://www.wow-professions.com/farming/wildercloth-farming",
        "https://www.wow-professions.com/farming/tattered-wildercloth-farming",
    },
    mapName = "The Azure Span",
    location = "Key Basement cloth spot and nearby Azure Span humanoid packs",
    routeType = "humanoid-cloth-farm",
    density = "High",
    dropDifficulty = "Strongest with Tailoring cloth scavenging and fast respawns; avoid storing as a solo-only guarantee.",
    tips = {
        "Use the basement pins when Wildercloth and Tattered Wildercloth are both valuable.",
        "Dragon Isles Cloth Scavenging is required for reliable tailoring cloth drops from humanoids.",
        "The route is stored as a route spine so the map window can later reconstruct a compact loop.",
    },
    coords = {
        C(0.246, 0.581, "Key Basement west pin"),
        C(0.283, 0.588, "Key Basement east pin"),
        C(0.250, 0.560, "Key Basement lower pin"),
        C(0.264, 0.570, "Basement connector"),
        C(0.275, 0.580, "Basement return"),
    },
    confidence = "high",
}

local function RegisterCloth(itemID, itemName, summary)
    Register({
        itemID = itemID,
        itemName = itemName,
        expansion = "dragonflight",
        professions = { "tailoring" },
        category = "Cloth",
        sourceUrls = { ItemUrl(itemID) },
        summary = summary,
        spots = {
            AZURE_SPAN_BRACKENHIDE_CLOTH_ROUTE,
            AZURE_SPAN_KEY_BASEMENT_CLOTH_ROUTE,
        },
    })
end

RegisterCloth(193050, "Tattered Wildercloth",
    "Dragonflight cloth from dense humanoid farms, with Brackenhide and Key Basement routes as confirmed practical spots.")
RegisterCloth(193922, "Wildercloth",
    "Dragonflight tailoring cloth from the same dense Dragon Isles humanoid farms as Tattered Wildercloth, but at lower volume.")
