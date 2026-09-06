local _, NS = ...
local Register = NS.RegisterMaterialFarmingSpot

local function C(x, y, label)
    return { x = x, y = y, label = label }
end

local function ItemUrl(itemID)
    return "https://www.wowhead.com/item=" .. tostring(itemID)
end

local DRAGON_ISLES_PROSPECTING_ORE_ROUTE = {
    id = "dragonflight-prospecting-ore-input-route",
    source = "Wowhead Dragon Isles Prospecting spell, Dragonflight Jewelcrafting guide, Wowhead mining overview, and Artisans of Azeroth ore route pins",
    sourceUrls = {
        "https://www.wowhead.com/spell=374627/dragon-isles-prospecting",
        "https://www.wowhead.com/guide/professions/jewelcrafting/leveling-dragonflight",
        "https://www.wowhead.com/guide/professions/mining/overview-leveling-dragonflight",
        "https://www.wowhead.com/item=190396/serevite-ore",
        "https://www.wowhead.com/item=190311/draconium-ore",
        "https://www.wowhead.com/item=190314/khazgorite-ore",
        "https://artisansofazeroth.com/where-to-farm-draconium-wow-dragonflight-gold-making-guide/",
        "https://artisansofazeroth.com/ohnahran-plains-herb-and-ore-route-wow-dragonflight-gold-guide/",
    },
    mapName = "Dragon Isles",
    location = "Waking Shores Obsidian ridges and Ohn'ahran mixed ore loop for prospecting inputs",
    routeType = "prospecting-input-mining-loop",
    density = "Medium to high",
    dropDifficulty = "Prospecting outputs require destroying 5 Dragon Isles ores; Serevite is common, Draconium improves value, and Khaz'gorite is rare.",
    tips = {
        "Mine all Serevite and Draconium nodes, then compare ore sale value against prospecting output before processing.",
        "Use higher-quality ore when targeting higher-quality gems; prospecting yield still depends on Jewelcrafting skill and specialization.",
        "Prismatic Ore is a specialized prospecting output and is stored here as a prospecting byproduct, not a ground node.",
    },
    coords = {
        C(0.3054, 0.6863, "Waking Shores ore input start"),
        C(0.3316, 0.5861, "Waking Shores north bend"),
        C(0.3596, 0.4846, "Waking Shores upper ridge"),
        C(0.4310, 0.5454, "Waking Shores central lava ridge"),
        C(0.4544, 0.5806, "Waking Shores east ridge"),
        C(0.4024, 0.6546, "Waking Shores south ridge"),
        C(0.3495, 0.6800, "Waking Shores southwest return"),
        C(0.7510, 0.3814, "Ohn'ahran northeast ridge"),
        C(0.7817, 0.4423, "Ohn'ahran northeast turn"),
        C(0.7448, 0.5020, "Ohn'ahran eastern ridge"),
        C(0.6768, 0.6147, "Ohn'ahran south river bend"),
        C(0.6026, 0.4892, "Ohn'ahran Maruukai return"),
    },
    confidence = "high",
}

local function RegisterProspectingOutput(itemID, itemName, category, summary)
    Register({
        itemID = itemID,
        itemName = itemName,
        expansion = "dragonflight",
        professions = { "jewelcrafting" },
        category = category,
        sourceUrls = {
            ItemUrl(itemID),
            "https://www.wowhead.com/spell=374627/dragon-isles-prospecting",
            "https://www.wowhead.com/guide/professions/jewelcrafting/leveling-dragonflight",
        },
        summary = summary,
        spots = { DRAGON_ISLES_PROSPECTING_ORE_ROUTE },
    })
end

local prospectingSummary = "Dragonflight prospecting output from Dragon Isles ore; farm Serevite, Draconium, and rare Khaz'gorite through dense ore loops, then prospect with Jewelcrafting."

RegisterProspectingOutput(192837, "Queen's Ruby", "Gem", prospectingSummary)
RegisterProspectingOutput(192840, "Mystic Sapphire", "Gem", prospectingSummary)
RegisterProspectingOutput(192843, "Vibrant Emerald", "Gem", prospectingSummary)
RegisterProspectingOutput(192846, "Sundered Onyx", "Gem", prospectingSummary)
RegisterProspectingOutput(192849, "Eternity Amber", "Gem", prospectingSummary)
RegisterProspectingOutput(192852, "Alexstraszite", "Gem", prospectingSummary)
RegisterProspectingOutput(192858, "Malygite", "Gem", prospectingSummary)
RegisterProspectingOutput(192861, "Ysemerald", "Gem", prospectingSummary)
RegisterProspectingOutput(192865, "Neltharite", "Gem", prospectingSummary)
RegisterProspectingOutput(192868, "Nozdorite", "Gem", prospectingSummary)
RegisterProspectingOutput(192869, "Illimited Diamond", "Gem",
    "Rare Dragonflight diamond from Dragon Isles Prospecting; farm ore loops and prospect with Jewelcrafting rather than looking for a ground spawn.")
RegisterProspectingOutput(192872, "Fractured Glass", "Glass",
    "Common Dragonflight prospecting byproduct from Dragon Isles ores; store with ore input route coordinates.")
RegisterProspectingOutput(192880, "Crumbled Stone", "Stone",
    "Common Dragonflight prospecting byproduct from Dragon Isles ores; can also be prospected, but its farm source is still ore input.")
RegisterProspectingOutput(194545, "Prismatic Ore", "Ore",
    "Rare specialized Dragonflight prospecting byproduct from Dragon Isles ores; treat as a prospecting output, not a mineable node.")
