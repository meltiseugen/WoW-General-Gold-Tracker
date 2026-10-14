local _, NS = ...
local Register = NS.RegisterMaterialFarmingSpot

local function C(x, y, label)
    return { x = x, y = y, label = label }
end

local function ItemUrl(itemID)
    return "https://www.wowhead.com/item=" .. tostring(itemID)
end

local BROKEN_ISLES_BLOOD_ROUTE = {
    id = "legion-blood-of-sargeras-gathering-and-dungeon-feed",
    source = "Retail Wowhead Blood of Sargeras guide/comments, Wowhead Legion gathering guides, and dense Broken Isles route research",
    sourceUrls = {
        "https://www.wowhead.com/item=124124/blood-of-sargeras",
        "https://www.wowhead.com/guide/acquiring-and-spending-blood-of-sargeras-and-obliterum",
        "https://www.wowhead.com/guide/legion-herbalism",
        "https://www.wowhead.com/guide/legion-mining",
    },
    mapName = "Val'sharah",
    location = "Darkheart Thicket exterior and dungeon entrance for gather/feed routes",
    routeType = "rare-gathering-and-instance-reagent-route",
    density = "Intermittent",
    dropDifficulty = "Blood of Sargeras is BoP and not a normal node farm; it is best treated as a byproduct from Legion gathering, world quests, and dungeon disenchant/feed runs.",
    tips = {
        "Use this as a side-value route while farming Dreamleaf, Stonehide, ore, or Legion dungeon gear.",
        "World quests and dungeon runs are more honest targets when you specifically need Blood of Sargeras.",
        "Do not price this like an auctionable commodity; it is account/workflow value, not direct AH value.",
    },
    coords = {
        C(0.476, 0.418, "Darkheart exterior gather/feed loop"),
        C(0.510, 0.376, "Vilepetal and herbable mobs"),
        C(0.548, 0.408, "Dreamleaf sweep"),
        C(0.590, 0.316, "Darkheart Thicket dungeon entrance"),
    },
    confidence = "medium",
}

local ARGUS_PRIMAL_SARGERITE_ROUTE = {
    id = "legion-primal-sargerite-argus-gathering-route",
    source = "Retail Wowhead Primal Sargerite/Blood of Sargeras guide, Wowhead Argus survival guide, and Artisans of Azeroth retail Krokuun route string",
    sourceUrls = {
        "https://www.wowhead.com/guide/acquiring-and-spending-blood-of-sargeras-and-obliterum",
        "https://www.wowhead.com/news/patch-7-3-shadows-of-argus-survival-guide-and-giveaway-270739",
        "https://artisansofazeroth.com/legion-herbalism-leveling/",
    },
    mapName = "Krokuun",
    location = "Krokuun Argus gathering loop for Astral Glory, Empyrium, and Fiendish side value",
    routeType = "argus-gathering-byproduct-route",
    density = "Intermittent",
    dropDifficulty = "Primal Sargerite is BoP and appears as an Argus gathering/world-quest byproduct rather than a targetable node.",
    tips = {
        "Farm this only while you already need Argus ore, herbs, or leather.",
        "Check Argus world quests and Greater Invasions before grinding nodes if Primal Sargerite is the only target.",
        "Pair Krokuun herb and ore pins with Duskcloak Panthara skinning when material prices justify it.",
    },
    coords = {
        C(0.5879, 0.3141, "AoA Krokuun northern Argus route pin"),
        C(0.6175, 0.4583, "AoA Krokuun east ridge pin"),
        C(0.5579, 0.5728, "AoA Krokuun central return pin"),
        C(0.5257, 0.6484, "AoA Krokuun south-central pin"),
        C(0.4540, 0.5647, "AoA Krokuun western pin"),
        C(0.735, 0.706, "Duskcloak Panthara skinning side route"),
    },
    confidence = "medium",
}

local function RegisterReagent(itemID, itemName, professions, spots, summary)
    Register({
        itemID = itemID,
        itemName = itemName,
        expansion = "legion",
        professions = professions,
        category = "Reagent",
        sourceUrls = { ItemUrl(itemID) },
        summary = summary,
        spots = spots,
    })
end

RegisterReagent(
    124124,
    "Blood of Sargeras",
    { "mining", "herbalism", "skinning", "enchanting", "alchemy", "blacksmithing", "engineering", "jewelcrafting", "leatherworking", "tailoring" },
    { BROKEN_ISLES_BLOOD_ROUTE },
    "BoP Legion reagent from gathering byproducts, world quests, dungeon runs, and related profession workflows."
)

RegisterReagent(
    151568,
    "Primal Sargerite",
    { "mining", "herbalism", "skinning", "alchemy", "blacksmithing", "engineering", "jewelcrafting", "leatherworking", "tailoring" },
    { ARGUS_PRIMAL_SARGERITE_ROUTE },
    "BoP Argus reagent from Argus gathering byproducts, world quests, and invasion-era profession workflows."
)
