local _, NS = ...
local Register = NS.RegisterMaterialFarmingSpot

local function C(x, y, label)
    return { x = x, y = y, label = label }
end

local function ItemUrl(itemID)
    return "https://www.wowhead.com/item=" .. tostring(itemID)
end

local REVENDRETH_ARCHIVAM_DISENCHANT_ROUTE = {
    id = "shadowlands-revendreth-archivam-disenchant-feed",
    source = "Wowhead Shadowlands enchanting guide, Shadowlands cloth farm guides, and enchanting shuffle notes",
    sourceUrls = {
        "https://www.wowhead.com/guide/shadowlands-enchanting-profession",
        "https://www.wow-professions.com/farming/shrouded-cloth-farming",
        "https://thelazygoldmaker.com/the-shadowlands-enchanting-shuffle",
    },
    mapName = "Revendreth",
    location = "Archivam humanoid route for cloth, green items, and crafted disenchant feed",
    routeType = "disenchant-feed-farm",
    density = "High",
    dropDifficulty = "Indirect. Farm cloth and eligible Shadowlands gear, then disenchant or craft-shuffle "
        .. "based on TSM prices.",
    tips = {
        "Soul Dust mainly comes from disenchanting uncommon Shadowlands gear.",
        "Sacred Shards come from rare-quality Shadowlands gear and conversion paths.",
        "Eternal Crystals come from epic Shadowlands gear, so track the input cost carefully.",
    },
    coords = {
        C(0.684, 0.738, "Archivam west packs"),
        C(0.712, 0.712, "Archivam central packs"),
        C(0.742, 0.734, "Archivam east packs"),
        C(0.724, 0.772, "Southern return packs"),
    },
    confidence = "medium",
}

local ORIBOS_ENCHANTING_ROUTE = {
    id = "shadowlands-oribos-enchanting-trainer-and-vendor",
    source = "Wowhead Shadowlands enchanting guide and wow-professions enchanting guide",
    sourceUrls = {
        "https://www.wowhead.com/guide/shadowlands-enchanting-profession",
        "https://www.wow-professions.com/guides/shadowlands-enchanting-leveling-guide",
    },
    mapName = "Oribos",
    location = "Hall of Shapes enchanting trainer and shuffle setup point",
    routeType = "stationary-disenchant-setup",
    density = "Stationary",
    dropDifficulty = "Indirect. This is the trainer/vendor setup location for processing farmed or crafted gear.",
    tips = {
        "Use Oribos to learn enchanting and process crafted or looted Shadowlands gear.",
        "Compare dust, shard, and crystal prices before converting materials upward.",
        "The actual item feed can come from cloth farms, crafted gear, or auction purchases.",
    },
    coords = {
        C(0.482, 0.294, "Hall of Shapes enchanting area"),
    },
    confidence = "medium",
}

local function RegisterEnchanting(itemID, itemName, summary)
    Register({
        itemID = itemID,
        itemName = itemName,
        expansion = "shadowlands",
        professions = { "enchanting" },
        category = "Enchanting",
        sourceUrls = { ItemUrl(itemID) },
        summary = summary,
        spots = {
            REVENDRETH_ARCHIVAM_DISENCHANT_ROUTE,
            ORIBOS_ENCHANTING_ROUTE,
        },
    })
end

RegisterEnchanting(172230, "Soul Dust",
    "Common Shadowlands enchanting material from disenchanting eligible uncommon gear.")
RegisterEnchanting(172231, "Sacred Shard", "Shadowlands enchanting shard from rare gear or material conversion routes.")
RegisterEnchanting(172232, "Eternal Crystal",
    "Shadowlands enchanting crystal from epic gear; farm through disenchant feed rather than world nodes.")
