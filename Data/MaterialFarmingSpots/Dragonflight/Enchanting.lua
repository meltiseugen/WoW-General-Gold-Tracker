local _, NS = ...
local Register = NS.RegisterMaterialFarmingSpot

local function C(x, y, label)
    return { x = x, y = y, label = label }
end

local function ItemUrl(itemID)
    return "https://www.wowhead.com/item=" .. tostring(itemID)
end

local BRACKENHIDE_DISENCHANT_FEED_ROUTE = {
    id = "dragonflight-azure-span-brackenhide-disenchant-feed-route",
    source = "Wowhead Dragonflight enchanting overview and leveling guide plus Brackenhide humanoid NPC map pins",
    sourceUrls = {
        "https://www.wowhead.com/guide/professions/enchanting/overview-dragonflight",
        "https://www.wowhead.com/guide/professions/enchanting/leveling-dragonflight",
        "https://www.wowhead.com/npc=187941/duskpaw-hidestitcher",
        "https://www.wowhead.com/npc=187936/gnawbone-totemchewer",
    },
    mapName = "The Azure Span",
    location = "Brackenhide humanoid packs for Dragonflight green and rare gear to disenchant",
    routeType = "disenchant-feed-farm",
    density = "Medium",
    dropDifficulty = "Indirect but farmable. Dust, shards, and crystals come from disenchanting eligible Dragonflight gear.",
    tips = {
        "Chromatic Dust comes from disenchanting uncommon Dragonflight gear.",
        "Vibrant Shards come from rare Dragonflight gear, so they are less consistent from raw farming.",
        "Resonant Crystals come from epic Dragonflight gear; treat outdoor farming as supplemental to dungeons, crafting, and market buys.",
    },
    coords = {
        C(0.234, 0.424, "Duskpaw Hidestitcher west hut"),
        C(0.238, 0.436, "Duskpaw Hidestitcher east pack"),
        C(0.246, 0.404, "Hidestitcher north pack"),
        C(0.222, 0.404, "Gnawbone Totemchewer west pack"),
        C(0.244, 0.400, "Gnawbone Totemchewer central pack"),
    },
    confidence = "medium",
}

local function RegisterEnchanting(itemID, itemName, summary)
    Register({
        itemID = itemID,
        itemName = itemName,
        expansion = "dragonflight",
        professions = { "enchanting" },
        category = "Enchanting",
        sourceUrls = { ItemUrl(itemID) },
        summary = summary,
        spots = { BRACKENHIDE_DISENCHANT_FEED_ROUTE },
    })
end

RegisterEnchanting(194123, "Chromatic Dust",
    "Dragonflight enchanting material from disenchanting uncommon gear; Brackenhide humanoids are a coordinate-backed gear feed route.")
RegisterEnchanting(194124, "Vibrant Shard",
    "Dragonflight enchanting material from disenchanting rare gear; raw farms are best treated as gear-feed routes.")
RegisterEnchanting(200113, "Resonant Crystal",
    "Dragonflight enchanting material from disenchanting epic gear; coordinate-backed outdoor farms are supplemental rather than primary.")
