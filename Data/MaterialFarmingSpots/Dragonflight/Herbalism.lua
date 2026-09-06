local _, NS = ...
local Register = NS.RegisterMaterialFarmingSpot

local function C(x, y, label)
    return { x = x, y = y, label = label }
end

local function ItemUrl(itemID)
    return "https://www.wowhead.com/item=" .. tostring(itemID)
end

local OHNAHRAN_HERB_ROUTE = {
    id = "dragonflight-ohnahran-plains-hochenblume-saxifrage-route",
    source = "Artisans of Azeroth Ohn'ahran herb and ore route, Wowhead herbalism overview, Warcraft Wiki, WoWDB",
    sourceUrls = {
        "https://artisansofazeroth.com/ohnahran-plains-herb-and-ore-route-wow-dragonflight-gold-guide/",
        "https://www.wowhead.com/guide/professions/herbalism/overview-leveling-dragonflight",
        "https://www.wowhead.com/object=381209/hochenblume",
        "https://www.wowhead.com/object=381207/saxifrage",
        "https://www.wowhead.com/item=191465/saxifrage",
        "https://warcraft.wiki.gg/wiki/Hochenblume",
        "https://www.wowdb.com/items/191460-hochenblume",
    },
    mapName = "Ohn'ahran Plains",
    location = "Northeast ridge, river bends, and southern plains herb loop",
    routeType = "herbalism-loop",
    density = "Medium to high",
    dropDifficulty = "Hochenblume is widespread. Saxifrage is less common and favors rocky or elevated terrain.",
    tips = {
        "Clear every herb node because Saxifrage and elemental modifiers share the regional spawn pool.",
        "Use the ridge sections for stronger Saxifrage checks and the open plains for fast Hochenblume volume.",
        "Frigid, Windswept, Decayed, and Titan-Touched herbs can add elemental side value.",
    },
    coords = {
        C(0.7510, 0.3814, "Northeast ridge start"),
        C(0.7817, 0.4423, "Northeast ridge turn"),
        C(0.7448, 0.5020, "Eastern river ridge"),
        C(0.7243, 0.5665, "Southeast slope"),
        C(0.6768, 0.6147, "South river bend"),
        C(0.6311, 0.7116, "Southern plains herb"),
        C(0.5558, 0.7465, "Southwest sweep"),
        C(0.5192, 0.5490, "Central return"),
        C(0.6026, 0.4892, "Maruukai ridge"),
        C(0.7040, 0.4344, "Northeast return"),
    },
    confidence = "high",
}

local OHNAHRAN_BUBBLE_POPPY_ROUTE = {
    id = "dragonflight-ohnahran-plains-bubble-poppy-water-route",
    source = "Wowhead Dragonflight herbalism overview, Bubble Poppy comments, and Ohn'ahran route pins",
    sourceUrls = {
        "https://www.wowhead.com/guide/professions/herbalism/overview-leveling-dragonflight",
        "https://www.wowhead.com/item=191467/bubble-poppy",
        "https://www.wowhead.com/item=191468/bubble-poppy",
        "https://artisansofazeroth.com/ohnahran-plains-herb-and-ore-route-wow-dragonflight-gold-guide/",
    },
    mapName = "Ohn'ahran Plains",
    location = "River and lake bends from the northeast route down to the south plains",
    routeType = "herbalism-water-loop",
    density = "Medium",
    dropDifficulty = "Bubble Poppy prefers coasts, rivers, damp caves, and lake edges; clear Hochenblume on the same banks to refresh node rolls.",
    tips = {
        "Ride the waterline and nearby damp ground instead of cutting across dry plains.",
        "Pick common Hochenblume and Saxifrage on the banks so Bubble Poppy can respawn into the shared regional pool.",
        "This loop pairs well with mining because the eastern ridge has ore along the same travel line.",
    },
    coords = {
        C(0.7448, 0.5020, "Eastern river bank"),
        C(0.7243, 0.5665, "Southeast water slope"),
        C(0.6768, 0.6147, "South river bend"),
        C(0.6311, 0.7116, "Southern river crossing"),
        C(0.5558, 0.7465, "Southwest lake edge"),
        C(0.5192, 0.5490, "Central stream return"),
        C(0.6026, 0.4892, "Maruukai waterline"),
    },
    confidence = "high",
}

local OHNAHRAN_WRITHEBARK_ROUTE = {
    id = "dragonflight-ohnahran-plains-writhebark-foliage-route",
    source = "Wowhead Dragonflight herbalism overview and Writhebark comments around wooded Ohn'ahran foliage",
    sourceUrls = {
        "https://www.wowhead.com/guide/professions/herbalism/overview-leveling-dragonflight",
        "https://www.wowhead.com/item=191470/writhebark",
        "https://www.wowhead.com/item=191471/writhebark",
    },
    mapName = "Ohn'ahran Plains",
    location = "Emerald Gardens, Shady Sanctuary, and nearby wooded Ohn'ahran paths",
    routeType = "herbalism-foliage-loop",
    density = "Medium",
    dropDifficulty = "Writhebark favors dense forest and foliage pockets and is less common than Hochenblume on the same zone route.",
    tips = {
        "Sweep under trees and around foliage rather than open plains.",
        "The 27.43,47.06 pin is a confirmed Writhebark comment anchor; expand around it while clearing every herb node.",
        "Use this route when Writhebark is the target and switch to the river route when Bubble Poppy is stronger.",
    },
    coords = {
        C(0.2743, 0.4706, "Emerald Gardens Writhebark pin"),
        C(0.2500, 0.4880, "Western foliage pocket"),
        C(0.2840, 0.4920, "Sanctuary tree line"),
        C(0.3050, 0.4680, "Eastern foliage return"),
        C(0.3260, 0.4490, "North tree sweep"),
        C(0.3120, 0.4210, "Northwest return"),
    },
    confidence = "medium",
}

local function RegisterHerb(itemID, itemName, summary, qualityRank, spots)
    Register({
        itemID = itemID,
        itemName = itemName,
        expansion = "dragonflight",
        professions = { "herbalism", "alchemy", "inscription" },
        category = "Herb",
        qualityRank = qualityRank,
        sourceUrls = { ItemUrl(itemID) },
        summary = summary,
        spots = spots or { OHNAHRAN_HERB_ROUTE },
    })
end

RegisterHerb(191460, "Hochenblume",
    "Common Dragon Isles herb; dense Ohn'ahran loops provide reliable volume and elemental side nodes.", 1)
RegisterHerb(191461, "Hochenblume",
    "Common Dragon Isles herb; dense Ohn'ahran loops provide reliable volume and elemental side nodes.", 2)
RegisterHerb(191462, "Hochenblume",
    "Common Dragon Isles herb; dense Ohn'ahran loops provide reliable volume and elemental side nodes.", 3)
RegisterHerb(191464, "Saxifrage",
    "Dragonflight herb that is best chased by clearing mixed herb routes with rocky and elevated sections.", 1)
RegisterHerb(191465, "Saxifrage",
    "Dragonflight herb that is best chased by clearing mixed herb routes with rocky and elevated sections.", 2)
RegisterHerb(191466, "Saxifrage",
    "Dragonflight herb that is best chased by clearing mixed herb routes with rocky and elevated sections.", 3)
RegisterHerb(191467, "Bubble Poppy",
    "Dragonflight herb that favors water edges; Ohn'ahran river and lake loops give practical repeatable checks.", 1,
    { OHNAHRAN_BUBBLE_POPPY_ROUTE, OHNAHRAN_HERB_ROUTE })
RegisterHerb(191468, "Bubble Poppy",
    "Dragonflight herb that favors water edges; Ohn'ahran river and lake loops give practical repeatable checks.", 2,
    { OHNAHRAN_BUBBLE_POPPY_ROUTE, OHNAHRAN_HERB_ROUTE })
RegisterHerb(191469, "Bubble Poppy",
    "Dragonflight herb that favors water edges; Ohn'ahran river and lake loops give practical repeatable checks.", 3,
    { OHNAHRAN_BUBBLE_POPPY_ROUTE, OHNAHRAN_HERB_ROUTE })
RegisterHerb(191470, "Writhebark",
    "Dragonflight herb that favors wooded and foliage-heavy areas; use the Ohn'ahran Emerald Gardens sweep as a focused route.", 1,
    { OHNAHRAN_WRITHEBARK_ROUTE, OHNAHRAN_HERB_ROUTE })
RegisterHerb(191471, "Writhebark",
    "Dragonflight herb that favors wooded and foliage-heavy areas; use the Ohn'ahran Emerald Gardens sweep as a focused route.", 2,
    { OHNAHRAN_WRITHEBARK_ROUTE, OHNAHRAN_HERB_ROUTE })
RegisterHerb(191472, "Writhebark",
    "Dragonflight herb that favors wooded and foliage-heavy areas; use the Ohn'ahran Emerald Gardens sweep as a focused route.", 3,
    { OHNAHRAN_WRITHEBARK_ROUTE, OHNAHRAN_HERB_ROUTE })
