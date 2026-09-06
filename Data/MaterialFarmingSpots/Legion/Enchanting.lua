local _, NS = ...
local Register = NS.RegisterMaterialFarmingSpot

local function C(x, y, label)
    return { x = x, y = y, label = label }
end

local function ItemUrl(itemID)
    return "https://www.wowhead.com/item=" .. tostring(itemID)
end

local SHALDOREI_DE_ROUTE = {
    id = "legion-enchanting-highmountain-snowblind-disenchant-feed",
    source = "Wowhead Legion Enchanting guide and wow-professions Shal'dorei Silk guide",
    sourceUrls = {
        "https://www.wowhead.com/guide/legion-enchanting",
        "https://www.wow-professions.com/farming/shaldorei-silk-farming",
    },
    mapName = "Highmountain",
    location = "Snowblind Mesa humanoid farm for cloth, greens, and crafted bracer disenchant feed",
    routeType = "disenchant-feed-farm",
    density = "High",
    dropDifficulty = "Best used by tailors/enchanters; outdoor drops are RNG, crafted bracers make the input steadier.",
    tips = {
        "Legion enchanting materials come primarily from disenchanting gear, not from outdoor resource nodes.",
        "Use dense humanoid farms to collect cloth and green drops, then disenchant eligible gear.",
        "The enchanting guide identifies dust, shard, and crystal outputs by gear rarity.",
    },
    coords = {
        C(0.524, 0.584, "Snowblind Mesa cloth and green-feed farm"),
        C(0.506, 0.612, "Western battle edge"),
        C(0.548, 0.624, "Eastern battle edge"),
    },
    confidence = "medium",
}

local LEGION_DUNGEON_DE_ROUTE = {
    id = "legion-enchanting-darkheart-thicket-dungeon-feed",
    source = "Wowhead Legion Enchanting guide and Wowhead Blood of Sargeras comments",
    sourceUrls = {
        "https://www.wowhead.com/guide/legion-enchanting",
        "https://www.wowhead.com/item=124124/blood-of-sargeras",
    },
    mapName = "Val'sharah",
    location = "Darkheart Thicket entrance for repeatable Legion dungeon disenchant feed",
    routeType = "dungeon-disenchant-feed",
    density = "Instance reset limited",
    dropDifficulty = "Good legacy-farm feed for rare and epic disenchant materials, gated by dungeon reset rhythm.",
    tips = {
        "Use legacy Legion dungeons when you want disenchantable rare and epic gear rather than cloth-only input.",
        "A Wowhead comment notes old Legion dungeon runs as a fast source of disenchantable loot.",
        "Chaos Crystal supply depends on epic gear volume; do not expect it from normal outdoor green farming.",
    },
    coords = {
        C(0.590, 0.316, "Darkheart Thicket dungeon entrance"),
    },
    confidence = "medium",
}

local ARGUS_MAGIC_CACHE_ROUTE = {
    id = "legion-enchanting-argus-rare-magic-caches",
    source = "Wowhead Legion Enchanting guide",
    sourceUrls = {
        "https://www.wowhead.com/guide/legion-enchanting",
    },
    mapName = "Krokuun",
    location = "Argus rare route for Wyrmtongue Cache of Magic side drops",
    routeType = "rare-cache-route",
    density = "Opportunistic",
    dropDifficulty = "Low reliability, but useful while farming Argus rares for other rewards.",
    tips = {
        "The enchanting guide notes that Argus rares can drop Wyrmtongue Cache of Magic with enchanting materials.",
        "Treat this as a side route, not the main enchanting material farm.",
        "Pair it with Empyrium and Astral Glory routes on Argus.",
    },
    coords = {
        C(0.420, 0.624, "Krokuun rare route west"),
        C(0.540, 0.548, "Krokuun rare route center"),
        C(0.638, 0.608, "Krokuun rare route east"),
    },
    confidence = "low",
}

local function RegisterEnchanting(itemID, itemName, spots, summary)
    Register({
        itemID = itemID,
        itemName = itemName,
        expansion = "legion",
        professions = { "enchanting" },
        category = "Enchanting",
        sourceUrls = { ItemUrl(itemID) },
        summary = summary,
        spots = spots,
    })
end

RegisterEnchanting(
    124440,
    "Arkhana",
    { SHALDOREI_DE_ROUTE, LEGION_DUNGEON_DE_ROUTE, ARGUS_MAGIC_CACHE_ROUTE },
    "Legion dust primarily from disenchanting gear; dense farms can feed crafted or dropped inputs."
)
RegisterEnchanting(
    124441,
    "Leylight Shard",
    { LEGION_DUNGEON_DE_ROUTE, SHALDOREI_DE_ROUTE, ARGUS_MAGIC_CACHE_ROUTE },
    "Legion shard primarily from rare gear disenchanting and Blood of Sargeras trader side paths."
)
RegisterEnchanting(
    124442,
    "Chaos Crystal",
    { LEGION_DUNGEON_DE_ROUTE },
    "Legion crystal primarily from epic gear disenchanting; dungeon or raid loot is the honest anchor."
)
