local _, NS = ...
local Register = NS.RegisterMaterialFarmingSpot

local function C(x, y, label)
    return { x = x, y = y, label = label }
end

local function ItemUrl(itemID)
    return "https://www.wowhead.com/item=" .. tostring(itemID)
end

local SHALDOREI_HIGHMOUNTAIN_ROUTE = {
    id = "legion-shaldorei-silk-highmountain-snowblind-mesa",
    source = "wow-professions Shal'dorei Silk guide and Wowhead Mightstone Flanker/Slinger pages",
    sourceUrls = {
        "https://www.wow-professions.com/farming/shaldorei-silk-farming",
        "https://www.wowhead.com/npc=96690/mightstone-flanker",
        "https://www.wowhead.com/npc=96689/mightstone-slinger",
    },
    mapName = "Highmountain",
    location = "Snowblind Mesa Mightstone Flanker and Slinger battle area",
    routeType = "humanoid-cloth-farm",
    density = "High",
    dropDifficulty = "Fast respawns and friendly NPC combat, but pulling too many ranged mobs is dangerous.",
    tips = {
        "The guide calls Snowblind Mesa a strong cloth spot because mobs respawn almost instantly.",
        "Try to land killing blows on low-health mobs fighting friendly NPCs so they remain lootable.",
        "Tailors get much more Shal'dorei Silk than non-tailors.",
    },
    coords = {
        C(0.524, 0.584, "Snowblind Mesa cave and battle line"),
        C(0.506, 0.612, "Western battle edge"),
        C(0.548, 0.624, "Eastern battle edge"),
    },
    confidence = "high",
}

local SHALDOREI_AZSUNA_ROUTE = {
    id = "legion-shaldorei-silk-azsuna-murloc-shore",
    source = "wow-professions Shal'dorei Silk guide and r/woweconomy cloth farming discussion",
    sourceUrls = {
        "https://www.wow-professions.com/farming/shaldorei-silk-farming",
        "https://www.reddit.com/r/woweconomy/comments/5ybwrt/shaldorei_silk_farming_in_715/",
    },
    mapName = "Azsuna",
    location = "Azsuna lake-shore murloc packs",
    routeType = "humanoid-cloth-farm",
    density = "High",
    dropDifficulty = "Good AoE cloth spot; world quests can make it crowded.",
    tips = {
        "Farm the murloc shore when your class can AoE grouped mobs quickly.",
        "A community farming discussion still called the Azsuna murloc area strong for Shal'dorei Silk in patch 7.1.5.",
        "Expect competition when a world quest is active here.",
    },
    coords = {
        C(0.484, 0.342, "Northern murloc shore"),
        C(0.502, 0.386, "Central murloc shore"),
        C(0.526, 0.426, "Southern murloc shore"),
    },
    confidence = "medium",
}

local SHALDOREI_STORMHEIM_ROUTE = {
    id = "legion-shaldorei-silk-stormheim-runeaxe-training",
    source = "wow-professions Shal'dorei Silk guide and Wowhead Bonespeaker Runeaxe page",
    sourceUrls = {
        "https://www.wow-professions.com/farming/shaldorei-silk-farming",
        "https://www.wowhead.com/npc=102110/bonespeaker-runeaxe",
    },
    mapName = "Stormheim",
    location = "Runeaxe Training Grounds Bonespeaker Runeaxe camp",
    routeType = "humanoid-cloth-farm",
    density = "Medium to high",
    dropDifficulty = "Stable ranged farm; standing near the center works well for ranged classes.",
    tips = {
        "The guide notes that killing the last Runeaxe quickly spawns two or three more.",
        "Ranged classes can stand near the camp center and chain-pull.",
    },
    coords = {
        C(0.434, 0.640, "Runeaxe camp center"),
        C(0.406, 0.622, "West tents"),
        C(0.462, 0.668, "East tents"),
    },
    confidence = "medium",
}

local LIGHTWEAVE_EREDATH_ROUTE = {
    id = "legion-lightweave-eredath-two-point-demon-farm",
    source = "wow-professions Lightweave Cloth guide and Warcraft Wiki",
    sourceUrls = {
        "https://www.wow-professions.com/farming/lightweave-cloth-farming",
        "https://warcraft.wiki.gg/wiki/Lightweave_Cloth",
    },
    mapName = "Eredath",
    location = "Eredath demon packs at the upper and lower marked farms",
    routeType = "demon-cloth-farm",
    density = "Very high",
    dropDifficulty = "Best Lightweave Cloth route; respawns are fast enough to stay at one of the two farm points.",
    tips = {
        "The guide calls Eredath the best Lightweave farm and notes the two points do not require moving between them.",
        "Tailors get much more cloth than non-tailors.",
        "Use a sturdy spec if killing several demons at once.",
    },
    coords = {
        C(0.530, 0.388, "Upper Eredath demon farm"),
        C(0.568, 0.448, "Lower Eredath demon farm"),
    },
    confidence = "high",
}

local LIGHTWEAVE_ANTORAN_ROUTE = {
    id = "legion-lightweave-antoran-wastes-demon-respawn",
    source = "wow-professions Lightweave Cloth guide",
    sourceUrls = {
        "https://www.wow-professions.com/farming/lightweave-cloth-farming",
    },
    mapName = "Antoran Wastes",
    location = "Antoran Wastes hard-hitting demon respawn camp",
    routeType = "demon-cloth-farm",
    density = "High",
    dropDifficulty = "Good backup but harder than Eredath; some mobs hit hard and rare elites can interfere.",
    tips = {
        "Pull conservatively until you know what your character can survive.",
        "If a rare elite is active at the spot, use Eredath or Krokuun instead.",
    },
    coords = {
        C(0.644, 0.388, "Demon camp center"),
        C(0.618, 0.424, "West camp"),
        C(0.678, 0.432, "East camp"),
    },
    confidence = "medium",
}

local function RegisterCloth(itemID, itemName, spots, summary)
    Register({
        itemID = itemID,
        itemName = itemName,
        expansion = "legion",
        professions = { "tailoring" },
        category = "Cloth",
        sourceUrls = { ItemUrl(itemID) },
        summary = summary,
        spots = spots,
    })
end

RegisterCloth(
    124437,
    "Shal'dorei Silk",
    { SHALDOREI_HIGHMOUNTAIN_ROUTE, SHALDOREI_AZSUNA_ROUTE, SHALDOREI_STORMHEIM_ROUTE },
    "Broken Isles cloth from dense humanoid spots; tailors receive much higher cloth volume."
)
RegisterCloth(
    151567,
    "Lightweave Cloth",
    { LIGHTWEAVE_EREDATH_ROUTE, LIGHTWEAVE_ANTORAN_ROUTE },
    "Argus cloth from dense demon farms, strongest in Eredath."
)
