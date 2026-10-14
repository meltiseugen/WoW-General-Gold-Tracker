local _, NS = ...
local Register = NS.RegisterMaterialFarmingSpot

local function C(x, y, label)
    return { x = x, y = y, label = label }
end

local function ItemUrl(itemID)
    return "https://www.wowhead.com/item=" .. tostring(itemID)
end

local SKINNING_TIPS = {
    "Use Enchant Gloves - Legion Skinning to reduce skinning time.",
    "If another player tags but does not loot a corpse, you cannot skin it.",
    "Boon of the Butcher can add leather and meat value while farming Broken Isles beasts.",
}

local function WithSkinningTips(extra)
    local tips = {}
    for _, tip in ipairs(SKINNING_TIPS) do
        tips[#tips + 1] = tip
    end
    for _, tip in ipairs(extra or {}) do
        tips[#tips + 1] = tip
    end
    return tips
end

local STONEHIDE_SURAMAR_ROUTE = {
    id = "legion-stonehide-suramar-snarler-crimson-thicket",
    source = "wow-professions Stonehide guide and Wowhead Stonehide comments",
    sourceUrls = {
        "https://www.wow-professions.com/farming/stonehide-leather-farming",
        "https://www.wowhead.com/item=124113/stonehide-leather",
        "https://www.wowhead.com/npc=107469/suramar-snarler",
    },
    mapName = "Suramar",
    location = "Crimson Thicket Suramar Snarler and deer hillside loop",
    routeType = "skinning-loop",
    density = "High",
    dropDifficulty = "Very good Stonehide loop if you can handle Suramar mobs.",
    tips = WithSkinningTips({
        "The guide says Suramar Snarlers respawn fast enough that you should not run out.",
        "A Wowhead comment gives the Suramar wolf/deer farm around 32,37.",
        "Grab the Ley Ward buff near 41.53,38.96 if you want faster kills.",
    }),
    coords = {
        C(0.320, 0.370, "Wolf and deer hillside"),
        C(0.306, 0.316, "Northern wolf packs"),
        C(0.346, 0.352, "Central pull area"),
        C(0.4153, 0.3896, "Ley Ward cave buff"),
    },
    confidence = "high",
}

local STONEHIDE_HM_ROUTE = {
    id = "legion-stonehide-highmountain-nesingwary-hillstriders",
    source = "Wowhead Stonehide comments and wow-professions Big Gamy Ribs guide",
    sourceUrls = {
        "https://www.wowhead.com/item=124113/stonehide-leather",
        "https://www.wow-professions.com/farming/big-gamy-ribs-farming",
    },
    mapName = "Highmountain",
    location = "Nesingwary camp Sated Hillstriders and nearby beasts",
    routeType = "skinning-and-meat-loop",
    density = "High",
    dropDifficulty = "Fast respawns and strong meat side value.",
    tips = WithSkinningTips({
        "A Wowhead comment reports Highmountain Nesingwary around 41,53 with quick goat respawns.",
        "Skin goats and nearby elderhorn while collecting Big Gamy Ribs and Stonehide Leather.",
    }),
    coords = {
        C(0.410, 0.530, "Nesingwary camp goats"),
        C(0.432, 0.512, "North hillstrider packs"),
        C(0.392, 0.548, "South hillstrider packs"),
    },
    confidence = "high",
}

local STORMSCALE_STORMHEIM_CRABS = {
    id = "legion-stormscale-stormheim-north-island-crabs",
    source = "r/woweconomy Stormscale guide, Wowhead Blood of Sargeras comments, and Wowhead Stormscale quest comments",
    sourceUrls = {
        "https://www.reddit.com/r/woweconomy/comments/5828ds/the_best_place_to_farm_stormscale/",
        "https://www.wowhead.com/item=124124/blood-of-sargeras",
        "https://www.wowhead.com/quest=40142/the-core-of-the-stormscale",
    },
    mapName = "Stormheim",
    location = "Underwater crab groups around the unmarked northern Stormheim island",
    routeType = "underwater-skinning-loop",
    density = "Very high",
    dropDifficulty = "Excellent Stormscale farm with underwater-breathing requirement and group pulls.",
    tips = WithSkinningTips({
        "The reddit guide places the island around 68,26 and describes multiple underwater crab group spawn points.",
        "A Wowhead comment gives a second Stormheim sea-floor route from 65,11 to 65,34.",
        "Bring underwater breathing and be ready for grouped crab aggro.",
    }),
    coords = {
        C(0.680, 0.260, "Unmarked island crab farm"),
        C(0.650, 0.110, "North coast crab route start"),
        C(0.650, 0.220, "Mid coast crab route"),
        C(0.650, 0.340, "North coast crab route end"),
    },
    confidence = "high",
}

local STORMSCALE_HIGHMOUNTAIN_BASILISKS = {
    id = "legion-stormscale-highmountain-coldscale-river",
    source = "Wowhead Stormscale quest comments and wow-professions Stormscale guide",
    sourceUrls = {
        "https://www.wowhead.com/quest=40142/the-core-of-the-stormscale",
        "https://www.wow-professions.com/farming/stormscale-farming",
    },
    mapName = "Highmountain",
    location = "Coldscale Gazecrawlers along the river southeast of Thunder Totem",
    routeType = "skinning-loop",
    density = "High",
    dropDifficulty = "Very good density, but crawler stuns make interrupts valuable.",
    tips = WithSkinningTips({
        "A Wowhead comment reports many Coldscale Gazecrawlers around 51,61.",
        "Interrupt or stun the crawler cast if farming in melee.",
        "Use this when the Stormheim crab route is busy.",
    }),
    coords = {
        C(0.510, 0.610, "Thunder Totem southeast river"),
        C(0.528, 0.636, "Lower river crawlers"),
        C(0.492, 0.584, "Upper river crawlers"),
    },
    confidence = "high",
}

local FIENDISH_KROKUUN_ROUTE = {
    id = "legion-fiendish-leather-krokuun-duskcloak-pantharas",
    source = "wow-professions Fiendish Leather guide and Wowhead Fiendish Leather comments",
    sourceUrls = {
        "https://www.wow-professions.com/farming/fiendish-leather-farming",
        "https://www.wowhead.com/item=151566/fiendish-leather",
        "https://www.wowhead.com/npc=125429/duskcloak-panthara",
    },
    mapName = "Krokuun",
    location = "Duskcloak Pantharas in southern Krokuun",
    routeType = "stationary-skinning-farm",
    density = "High",
    dropDifficulty = "Best Fiendish Leather spot; defensive panthara buffs slow weak burst windows.",
    tips = WithSkinningTips({
        "The guide gives exact coordinates 73.5,70.6 and says you can mostly stand still.",
        "Wait out the short transparent defensive buff if your burst damage is being reduced.",
        "Use this before Mac'Aree/Eredath or Antoran Wastes unless the spot is crowded.",
    }),
    coords = {
        C(0.735, 0.706, "Duskcloak Panthara pull point"),
        C(0.710, 0.692, "West panthara side"),
        C(0.760, 0.720, "East panthara side"),
    },
    confidence = "high",
}

local FIENDISH_EREDATH_ROUTE = {
    id = "legion-fiendish-leather-eredath-manafeeder-pantharas",
    source = "wow-professions Fiendish Leather guide and Wowhead Manafeeder Panthara page",
    sourceUrls = {
        "https://www.wow-professions.com/farming/fiendish-leather-farming",
        "https://www.wowhead.com/npc=126193/manafeeder-panthara",
    },
    mapName = "Eredath",
    location = "Manafeeder Pantharas in Eredath questing pockets",
    routeType = "skinning-loop",
    density = "Medium",
    dropDifficulty = "Decent backup, but quest traffic can interfere.",
    tips = WithSkinningTips({
        "Use Eredath only when Krokuun pantharas are crowded.",
        "Avoid standing in heavy story-quest traffic if shared tagging slows skins.",
    }),
    coords = {
        C(0.518, 0.604, "Manafeeder Panthara pocket"),
        C(0.548, 0.642, "Southern pantharas"),
        C(0.488, 0.646, "Western return"),
    },
    confidence = "medium",
}

local FELHIDE_STORMHEIM_ROUTE = {
    id = "legion-felhide-stormheim-waterfall-gargantuan",
    source = "Retail Wowhead Felhide item comments, Wowhead Felhide Gargantuan NPC page, and Warcraft Wiki Felhide source notes",
    sourceUrls = {
        "https://www.wowhead.com/item=124116/felhide",
        "https://www.wowhead.com/npc=103675/felhide-gargantuan",
        "https://warcraft.wiki.gg/wiki/Felhide",
    },
    mapName = "Stormheim",
    location = "Felhide Gargantuan cave behind the waterfall west of Cullen's Outpost",
    routeType = "world-quest-skinning-target",
    density = "Intermittent",
    dropDifficulty = "Felhide is tied to Legion skinning world quests and the Felhide Gargantuan, not a normal open-loop beast farm.",
    tips = WithSkinningTips({
        "A Wowhead comment places the Stormheim cave behind the waterfall around 32,55.",
        "You need Legion Skinning progress before the world quest target is useful.",
        "Use a target macro for Felhide Gargantuan because the cave location is easy to miss.",
    }),
    coords = {
        C(0.320, 0.550, "Waterfall cave report"),
        C(0.370, 0.520, "Crashed airship approach"),
    },
    confidence = "medium",
}

local FELHIDE_VALSHARAH_ROUTE = {
    id = "legion-felhide-valsharah-gargantuan-report",
    source = "Retail Wowhead Felhide item comments and Wowhead Felhide Gargantuan NPC page",
    sourceUrls = {
        "https://www.wowhead.com/item=124116/felhide",
        "https://www.wowhead.com/npc=103675/felhide-gargantuan",
    },
    mapName = "Val'sharah",
    location = "Val'sharah Felhide Gargantuan world quest report",
    routeType = "world-quest-skinning-target",
    density = "Intermittent",
    dropDifficulty = "Use only when the Felhide world quest is active and the mob is skinnable for your character.",
    tips = WithSkinningTips({
        "A Wowhead comment reports the Val'sharah Gargantuan around 34,61.",
        "If the corpse cannot be skinned, re-check Legion Skinning skill and world quest availability.",
    }),
    coords = {
        C(0.340, 0.610, "Val'sharah Gargantuan report"),
    },
    confidence = "medium",
}

local function RegisterSkinning(itemID, itemName, professions, category, spots, summary)
    Register({
        itemID = itemID,
        itemName = itemName,
        expansion = "legion",
        professions = professions,
        category = category,
        sourceUrls = { ItemUrl(itemID) },
        summary = summary,
        spots = spots,
    })
end

RegisterSkinning(
    124113,
    "Stonehide Leather",
    { "skinning", "leatherworking" },
    "Leather",
    { STONEHIDE_SURAMAR_ROUTE, STONEHIDE_HM_ROUTE },
    "Broken Isles leather from dense wolf, deer, goat, and beast farms."
)
RegisterSkinning(
    124115,
    "Stormscale",
    { "skinning", "leatherworking" },
    "Scale",
    { STORMSCALE_STORMHEIM_CRABS, STORMSCALE_HIGHMOUNTAIN_BASILISKS },
    "Legion scale from dense crab, turtle, basilisk, and crocolisk skinning routes."
)
RegisterSkinning(
    151566,
    "Fiendish Leather",
    { "skinning", "leatherworking" },
    "Leather",
    { FIENDISH_KROKUUN_ROUTE, FIENDISH_EREDATH_ROUTE },
    "Argus leather best farmed from Duskcloak Pantharas in Krokuun."
)
RegisterSkinning(
    124116,
    "Felhide",
    { "skinning", "leatherworking" },
    "Hide",
    { FELHIDE_STORMHEIM_ROUTE, FELHIDE_VALSHARAH_ROUTE },
    "World-quest-gated Legion hide skinned from Felhide Gargantuans."
)
RegisterSkinning(
    124438,
    "Unbroken Claw",
    { "skinning", "leatherworking", "blacksmithing" },
    "Claw",
    { STONEHIDE_SURAMAR_ROUTE, STONEHIDE_HM_ROUTE, FIENDISH_KROKUUN_ROUTE },
    "Legion claw found on beasts or gathered while skinning Broken Isles creatures; use dense skinning routes rather than rare-only sources."
)
RegisterSkinning(
    124439,
    "Unbroken Tooth",
    { "skinning", "leatherworking" },
    "Tooth",
    { STONEHIDE_SURAMAR_ROUTE, STORMSCALE_HIGHMOUNTAIN_BASILISKS, FIENDISH_KROKUUN_ROUTE },
    "Legion tooth found on beasts or gathered while skinning Broken Isles creatures; use dense skinning routes rather than rare-only sources."
)
