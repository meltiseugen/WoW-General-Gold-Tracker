local _, NS = ...
local Register = NS.RegisterMaterialFarmingSpot

local function C(x, y, label)
    return { x = x, y = y, label = label }
end

local function ItemUrl(itemID)
    return "https://www.wowhead.com/item=" .. tostring(itemID)
end

local DISENCHANT_GEAR_SPOTS = {
    {
        id = "warlords-enchanting-dreadtalon-saberon-green-disenchant",
        source = "Wowhead enchanting material pages, Enchanter's Study guide, and Tanaan rare/mob farming route research",
        sourceUrls = {
            ItemUrl(109693),
            ItemUrl(115502),
            ItemUrl(111245),
            ItemUrl(115504),
            ItemUrl(113588),
            "https://www.wowhead.com/guide/garrisons/buildings/guide-to-the-garrison-enchanters-study",
            "https://www.wowhead.com/zone=6723/tanaan-jungle",
        },
        mapName = "Tanaan Jungle",
        location = "Blackfang Challenge Arena and Fang'rila saberon green-drop loop",
        routeType = "disenchant-gear-farm",
        density = "High",
        dropDifficulty = "Indirect material farm; gear drops are RNG and crystals need eligible epic gear or conversions.",
        tips = {
            "Farm dense saberon packs for Draenor greens, then disenchant eligible gear.",
            "Use Tanaan only if you can kill quickly; otherwise switch to dungeon trash input routes.",
            "Temporal Crystal should be treated as an epic-disenchant or conversion target, not a normal trash drop.",
        },
        coords = {
            C(0.546, 0.748, "Fang'rila west packs"),
            C(0.584, 0.762, "Blackfang Challenge Arena"),
            C(0.632, 0.728, "East saberon packs"),
        },
        confidence = "medium",
    },
    {
        id = "warlords-enchanting-talador-auchindoun-trash-disenchant",
        source = "Wowhead Enchanter's Study guide, Icy Veins WoD enchanting guide, and Auchindoun route research",
        sourceUrls = {
            "https://www.wowhead.com/guide/garrisons/buildings/guide-to-the-garrison-enchanters-study",
            "https://www.icy-veins.com/wow/garrison-leveling-enchanting-in-warlords-of-draenor",
            "https://www.wowhead.com/zone=6912/auchindoun",
        },
        mapName = "Talador",
        location = "Auchindoun entrance and trash reset path",
        routeType = "disenchant-gear-farm",
        density = "Medium",
        dropDifficulty = "Indirect dungeon-input route for disenchanting material value.",
        tips = {
            "Use dungeon trash when open-world green drops are poor or contested.",
            "Draenic Dust comes from most Draenor disenchanting; Temporal Crystals require level 100 epic Draenor gear.",
        },
        coords = {
            C(0.466, 0.740, "Auchindoun entrance"),
            C(0.482, 0.706, "Entrance staging"),
        },
        confidence = "medium",
    },
}

local function RegisterEnchantingMaterial(itemID, itemName, summary)
    Register({
        itemID = itemID,
        itemName = itemName,
        expansion = "warlords",
        professions = { "enchanting" },
        category = "Enchanting",
        sourceUrls = { ItemUrl(itemID), "https://www.wowhead.com/guide/garrisons/buildings/guide-to-the-garrison-enchanters-study" },
        summary = summary,
        spots = DISENCHANT_GEAR_SPOTS,
    })
end

RegisterEnchantingMaterial(109693, "Draenic Dust", "Baseline Warlords enchanting material from disenchanting eligible Draenor gear.")
RegisterEnchantingMaterial(115502, "Small Luminous Shard", "Low-tier Warlords shard fragment from disenchanting eligible Draenor uncommon and rare gear; combine ten into a Luminous Shard.")
RegisterEnchantingMaterial(111245, "Luminous Shard", "Warlords shard from disenchanting eligible Draenor rare gear or combining Small Luminous Shards.")
RegisterEnchantingMaterial(115504, "Fractured Temporal Crystal", "Warlords crystal fragment from eligible epic disenchanting and Enchanter's Study/work-order paths; combine ten into a Temporal Crystal.")
RegisterEnchantingMaterial(113588, "Temporal Crystal", "Warlords crystal from disenchanting eligible level 100 epic Draenor gear or conversion paths.")
