local _, NS = ...
local Register = NS.RegisterMaterialFarmingSpot

local function C(x, y, label)
    return { x = x, y = y, label = label }
end

local function ItemUrl(itemID)
    return "https://www.wowhead.com/item=" .. tostring(itemID)
end

local WAKING_SHORES_DRACONIUM_ROUTE = {
    id = "dragonflight-waking-shores-obsidian-ore-route",
    source = "Artisans of Azeroth Draconium route, Wowhead Dragonflight mining overview, Wowhead ore item/object pages, Warcraft Wiki, WoWDB",
    sourceUrls = {
        "https://artisansofazeroth.com/where-to-farm-draconium-wow-dragonflight-gold-making-guide/",
        "https://www.wowhead.com/guide/professions/mining/overview-leveling-dragonflight",
        "https://www.wowhead.com/item=190396/serevite-ore",
        "https://www.wowhead.com/object=379252/draconium-deposit",
        "https://warcraft.wiki.gg/wiki/Draconium_Ore",
        "https://www.wowdb.com/items/189143-draconium-ore",
        "https://warcraft.wiki.gg/wiki/Khaz%27gorite_Ore",
        "https://www.wowdb.com/items/190312-khazgorite-ore",
    },
    mapName = "The Waking Shores",
    location = "Obsidian Citadel and southwest lava ridges",
    routeType = "mining-loop",
    density = "Medium to high",
    dropDifficulty = "Serevite is common, Draconium is the target ore, and Khaz'gorite is a rare side gather from Serevite or Draconium nodes.",
    tips = {
        "Clear all nearby Serevite and Draconium nodes because rare ore depends on respawn rolls.",
        "Favor rocky lava ridges and cliff edges around the Obsidian Citadel.",
        "Elemental mining modifiers can add Rousing Earth, Fire, Frost, or Order while routing.",
    },
    coords = {
        C(0.3054, 0.6863, "Obsidian Citadel west ore"),
        C(0.3316, 0.5861, "Obsidian Citadel north bend"),
        C(0.3596, 0.4846, "Life-Binder route north"),
        C(0.4310, 0.5454, "Central lava ridge"),
        C(0.4544, 0.5806, "Eastern lava ridge"),
        C(0.4024, 0.6546, "South ridge return"),
        C(0.3495, 0.6800, "Southwest return"),
        C(0.3962, 0.7746, "South coast ore"),
        C(0.2380, 0.7708, "Obsidian approach"),
    },
    confidence = "high",
}

local OHNAHRAN_HERB_ORE_ROUTE = {
    id = "dragonflight-ohnahran-plains-herb-ore-route",
    source = "Artisans of Azeroth Ohn'ahran herb and ore route plus Wowhead mining overview",
    sourceUrls = {
        "https://artisansofazeroth.com/ohnahran-plains-herb-and-ore-route-wow-dragonflight-gold-guide/",
        "https://www.wowhead.com/guide/professions/mining/overview-leveling-dragonflight",
        "https://www.wowhead.com/item=190396/serevite-ore",
        "https://www.wowhead.com/object=379252/draconium-deposit",
        "https://warcraft.wiki.gg/wiki/Khaz%27gorite_Ore",
        "https://www.wowdb.com/items/190312-khazgorite-ore",
    },
    mapName = "Ohn'ahran Plains",
    location = "Northeast ridge into south river sweep and Maruukai return",
    routeType = "dual-gathering-loop",
    density = "Medium",
    dropDifficulty = "Good mixed ore and herb path. Serevite is common, Draconium appears along rocky sections, and Khaz'gorite is rare.",
    tips = {
        "Use this as a dual-gathering loop when ore and herb values are both relevant.",
        "Keep to ridge lines and river bends where node density is more consistent.",
        "Mine all ore nodes while hunting Khaz'gorite because it is a rare side gather.",
    },
    coords = {
        C(0.7510, 0.3814, "Northeast ridge start"),
        C(0.7817, 0.4423, "Northeast ridge turn"),
        C(0.7448, 0.5020, "Eastern river ridge"),
        C(0.7243, 0.5665, "Southeast slope"),
        C(0.6768, 0.6147, "South river bend"),
        C(0.6311, 0.7116, "Southern plains node"),
        C(0.5558, 0.7465, "Southwest sweep"),
        C(0.5192, 0.5490, "Central return"),
        C(0.6026, 0.4892, "Maruukai ridge"),
        C(0.7040, 0.4344, "Northeast return"),
    },
    confidence = "high",
}

local function RegisterOre(itemID, itemName, summary, qualityRank)
    Register({
        itemID = itemID,
        itemName = itemName,
        expansion = "dragonflight",
        professions = { "mining", "jewelcrafting" },
        category = "Ore",
        qualityRank = qualityRank,
        sourceUrls = { ItemUrl(itemID) },
        summary = summary,
        spots = {
            WAKING_SHORES_DRACONIUM_ROUTE,
            OHNAHRAN_HERB_ORE_ROUTE,
        },
    })
end

RegisterOre(190394, "Serevite Ore",
    "Common Dragonflight ore from Dragon Isles mining nodes; clear dense Serevite and Draconium loops for volume and rare side gathers.", 1)
RegisterOre(190395, "Serevite Ore",
    "Common Dragonflight ore from Dragon Isles mining nodes; clear dense Serevite and Draconium loops for volume and rare side gathers.", 2)
RegisterOre(190396, "Serevite Ore",
    "Common Dragonflight ore from Dragon Isles mining nodes; clear dense Serevite and Draconium loops for volume and rare side gathers.", 3)
RegisterOre(190311, "Draconium Ore",
    "Dragonflight ore from rocky Dragon Isles mining loops, especially Waking Shores lava ridges.", 1)
RegisterOre(190312, "Khaz'gorite Ore",
    "Rare Dragonflight ore side gather from Serevite and Draconium nodes; farm by clearing dense ore loops.", 1)
RegisterOre(190313, "Khaz'gorite Ore",
    "Rare Dragonflight ore side gather from Serevite and Draconium nodes; farm by clearing dense ore loops.", 2)
RegisterOre(190314, "Khaz'gorite Ore",
    "Rare Dragonflight ore side gather from Serevite and Draconium nodes; farm by clearing dense ore loops.", 3)
