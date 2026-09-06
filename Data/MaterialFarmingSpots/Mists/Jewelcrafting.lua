local _, NS = ...
local Register = NS.RegisterMaterialFarmingSpot

local function C(x, y, label)
    return { x = x, y = y, label = label }
end

local function ItemUrl(itemID)
    return "https://www.wowhead.com/item=" .. tostring(itemID)
end

local PROSPECTING_SOURCES = {
    "https://www.wowhead.com/guide/mining-for-ores-gems-and-stones-mop-updated-376",
    "https://thelazygoldmaker.com/everything-you-need-to-know-to-prospect-ore-for-a-profit-in-mists-of-pandaria",
    "https://xscarlife-gaming.com/farming-retail/",
}

local GHOST_IRON_PROSPECTING_ROUTE = {
    id = "mists-prospecting-valley-four-winds-ghost-iron-input",
    source = "Retail Wowhead MoP mining/prospecting guide, Lazy Goldmaker prospecting overview, and retail xScarlife Ghost Iron route",
    sourceUrls = PROSPECTING_SOURCES,
    mapName = "Valley of the Four Winds",
    location = "Ghost Iron Ore route used as prospecting input",
    routeType = "prospecting-input-route",
    density = "High for Ghost Iron Ore",
    dropDifficulty = "Uncommon gems are the main prospecting output; rare gems are possible but lower chance from Ghost Iron.",
    tips = {
        "Farm Ghost Iron Ore here, then prospect in stacks of five on a Jewelcrafter.",
        "Use this route for broad uncommon gem volume and only treat rare gems as bonus value.",
        "The same ore farm also supports Living Steel and other Pandaria shuffle workflows.",
    },
    coords = {
        C(0.2934, 0.3115, "xScarlife Ghost Iron start"),
        C(0.3338, 0.2500, "Northwest ridge"),
        C(0.4382, 0.3190, "North Heartland"),
        C(0.5093, 0.2523, "Halfhill north ridge"),
        C(0.5863, 0.2491, "Paoquan approach"),
        C(0.6687, 0.2685, "Paoquan Hollow"),
        C(0.5645, 0.3920, "Paoquan return"),
        C(0.4594, 0.4398, "Heartland south bend"),
        C(0.4105, 0.5305, "Central return"),
        C(0.3454, 0.5383, "Western return ridge"),
        C(0.3023, 0.4645, "Heartland close"),
    },
    confidence = "high",
}

local TRILLIUM_PROSPECTING_ROUTE = {
    id = "mists-prospecting-dread-wastes-trillium-input",
    source = "Retail Wowhead MoP mining/prospecting guide and retail Trillium/Ghost Iron route research",
    sourceUrls = {
        "https://www.wowhead.com/guide/mining-for-ores-gems-and-stones-mop-updated-376",
        "https://thelazygoldmaker.com/everything-you-need-to-know-to-prospect-ore-for-a-profit-in-mists-of-pandaria",
        "https://www.wowhead.com/object=209328/trillium-vein",
        "https://www.wowhead.com/object=209329/rich-trillium-vein",
    },
    mapName = "Dread Wastes",
    location = "Trillium/Ghost Iron shared south and east ore route used for rare-gem prospecting input",
    routeType = "prospecting-input-route",
    density = "Medium for Trillium, high for shared ore turnover",
    dropDifficulty = "Trillium is rare, but prospecting Trillium ores is the stronger route for rare MoP gems.",
    tips = {
        "Mine Ghost Iron too because Trillium can respawn on shared nodes.",
        "Save Black and White Trillium Ore for rare-gem prospecting if gem prices justify it.",
        "Use Ghost Iron prospecting for uncommon-gem volume when Trillium supply is thin.",
    },
    coords = {
        C(0.324, 0.684, "Southwest ore sweep"),
        C(0.456, 0.732, "Southern ore sweep"),
        C(0.590, 0.690, "Southeast ore sweep"),
        C(0.686, 0.520, "Eastern ore sweep"),
        C(0.638, 0.338, "Northeast ore sweep"),
        C(0.520, 0.430, "Central return"),
    },
    confidence = "high",
}

local KYPARITE_PROSPECTING_ROUTE = {
    id = "mists-prospecting-dread-wastes-kyparite-input",
    source = "Retail Wowhead MoP mining/prospecting guide, Lazy Goldmaker prospecting overview, and retail xScarlife Kyparite route",
    sourceUrls = PROSPECTING_SOURCES,
    mapName = "Dread Wastes",
    location = "Kyparite route used as secondary prospecting input",
    routeType = "prospecting-input-route",
    density = "Medium",
    dropDifficulty = "Kyparite can be prospected, but it is mainly useful when it is cheaper than Ghost Iron or when route value overlaps with Klaxxi materials.",
    tips = {
        "Prospect Kyparite only when its market price makes the shuffle better than Ghost Iron.",
        "Use this route when Dread Wastes ore and Mote of Harmony side value are both useful.",
    },
    coords = {
        C(0.3482, 0.1875, "Northern Kyparite pin"),
        C(0.4005, 0.1546, "North ridge"),
        C(0.4905, 0.1339, "Northeast return"),
        C(0.4648, 0.2837, "North-central bend"),
        C(0.4161, 0.4061, "Klaxxi'vess west"),
        C(0.5088, 0.4529, "Klaxxi'vess south"),
        C(0.4120, 0.6991, "Zan'Vess east"),
        C(0.3400, 0.7651, "Zan'Vess south"),
        C(0.2166, 0.7502, "Southwest return"),
    },
    confidence = "medium",
}

local UNCOMMON_GEM_SPOTS = {
    GHOST_IRON_PROSPECTING_ROUTE,
    KYPARITE_PROSPECTING_ROUTE,
}

local RARE_GEM_SPOTS = {
    TRILLIUM_PROSPECTING_ROUTE,
    GHOST_IRON_PROSPECTING_ROUTE,
    KYPARITE_PROSPECTING_ROUTE,
}

local function RegisterGem(itemID, itemName, quality, spots, summary)
    Register({
        itemID = itemID,
        itemName = itemName,
        expansion = "mists",
        professions = { "jewelcrafting" },
        category = "Gem",
        sourceUrls = { ItemUrl(itemID), "https://www.wowhead.com/guide/mining-for-ores-gems-and-stones-mop-updated-376" },
        summary = summary,
        qualityRank = quality,
        spots = spots,
    })
end

RegisterGem(76130, "Tiger Opal", "uncommon", UNCOMMON_GEM_SPOTS, "Uncommon orange MoP gem from prospecting Ghost Iron, Kyparite, and Trillium-family ores.")
RegisterGem(76133, "Lapis Lazuli", "uncommon", UNCOMMON_GEM_SPOTS, "Uncommon blue MoP gem from prospecting Ghost Iron, Kyparite, and Trillium-family ores.")
RegisterGem(76134, "Sunstone", "uncommon", UNCOMMON_GEM_SPOTS, "Uncommon yellow MoP gem from prospecting Ghost Iron, Kyparite, and Trillium-family ores.")
RegisterGem(76135, "Roguestone", "uncommon", UNCOMMON_GEM_SPOTS, "Uncommon purple MoP gem from prospecting Ghost Iron, Kyparite, and Trillium-family ores.")
RegisterGem(76136, "Pandarian Garnet", "uncommon", UNCOMMON_GEM_SPOTS, "Uncommon red MoP gem from prospecting Ghost Iron, Kyparite, and Trillium-family ores.")
RegisterGem(76137, "Alexandrite", "uncommon", UNCOMMON_GEM_SPOTS, "Uncommon green MoP gem from prospecting Ghost Iron, Kyparite, and Trillium-family ores.")
RegisterGem(76131, "Primordial Ruby", "rare", RARE_GEM_SPOTS, "Rare red MoP gem; prospect Trillium ores first, with Ghost Iron or Kyparite as lower-yield backups.")
RegisterGem(76138, "River's Heart", "rare", RARE_GEM_SPOTS, "Rare blue MoP gem; prospect Trillium ores first, with Ghost Iron or Kyparite as lower-yield backups.")
RegisterGem(76139, "Wild Jade", "rare", RARE_GEM_SPOTS, "Rare green MoP gem; prospect Trillium ores first, with Ghost Iron or Kyparite as lower-yield backups.")
RegisterGem(76140, "Vermilion Onyx", "rare", RARE_GEM_SPOTS, "Rare orange MoP gem; prospect Trillium ores first, with Ghost Iron or Kyparite as lower-yield backups.")
RegisterGem(76141, "Imperial Amethyst", "rare", RARE_GEM_SPOTS, "Rare purple MoP gem; prospect Trillium ores first, with Ghost Iron or Kyparite as lower-yield backups.")
RegisterGem(76142, "Sun's Radiance", "rare", RARE_GEM_SPOTS, "Rare yellow MoP gem; prospect Trillium ores first, with Ghost Iron or Kyparite as lower-yield backups.")
