local _, NS = ...
local Register = NS.RegisterMaterialFarmingSpot

local function C(x, y, label)
    return { x = x, y = y, label = label }
end

local function ItemUrl(itemID)
    return "https://www.wowhead.com/item=" .. tostring(itemID)
end

local ICEFANG_ROUTE = {
    id = "legion-lean-shank-highmountain-icefang-packs",
    source = "wow-professions Lean Shank guide and Wowhead Icefang NPC pages",
    sourceUrls = {
        "https://www.wow-professions.com/farming/lean-shank-farming",
        "https://www.wowhead.com/npc=97793/icefang-packleader",
        "https://www.wowhead.com/npc=97794/icefang-howler",
    },
    mapName = "Highmountain",
    location = "Icefang Packleader and Howler packs in northern Highmountain",
    routeType = "beast-meat-loop",
    density = "High",
    dropDifficulty = "Excellent low-HP pack pulls; each packleader has extra howlers nearby.",
    tips = {
        "The guide calls out packleaders with two low-HP howlers nearby.",
        "Pull by pack rather than chasing single beasts.",
        "Skinning adds side value if you have it.",
    },
    coords = {
        C(0.398, 0.366, "Northwest Icefang pack"),
        C(0.426, 0.392, "Central Icefang pack"),
        C(0.462, 0.408, "Eastern Icefang pack"),
        C(0.444, 0.452, "Southern return pack"),
    },
    confidence = "medium",
}

local SURAMAR_SNARLER_MEAT_ROUTE = {
    id = "legion-lean-shank-suramar-snarler-crimson-thicket",
    source = "wow-professions Lean Shank guide and Wowhead Stonehide comments",
    sourceUrls = {
        "https://www.wow-professions.com/farming/lean-shank-farming",
        "https://www.wowhead.com/item=124113/stonehide-leather",
        "https://www.wowhead.com/npc=107469/suramar-snarler",
    },
    mapName = "Suramar",
    location = "Crimson Thicket Suramar Snarler loop",
    routeType = "beast-meat-and-skinning-loop",
    density = "High",
    dropDifficulty = "Fast respawn route; lower levels should avoid it.",
    tips = {
        "The guide says Suramar Snarlers respawn so fast you will not run out.",
        "Pull seven or eight together if your gear can handle it.",
        "The same loop also supports Stonehide Leather.",
    },
    coords = {
        C(0.320, 0.370, "Snarler hillside"),
        C(0.306, 0.316, "Northern snarler packs"),
        C(0.346, 0.352, "Central pull area"),
    },
    confidence = "high",
}

local BEAR_STORMHEIM_ROUTE = {
    id = "legion-fatty-bearsteak-stormheim-voracious-bears",
    source = "wow-professions Fatty Bearsteak guide, Wowhead Fatty Bearsteak page, and Warcraft Wiki",
    sourceUrls = {
        "https://www.wow-professions.com/farming/fatty-bearsteak-farming",
        "https://www.wowhead.com/item=124118/fatty-bearsteak",
        "https://warcraft.wiki.gg/wiki/Fatty_Bearsteak",
    },
    mapName = "Stormheim",
    location = "Voracious Bear route in Stormheim",
    routeType = "beast-meat-loop",
    density = "High",
    dropDifficulty = "Reliable bear farm with fast enough respawns for continuous pulls.",
    tips = {
        "The guide identifies Voracious Bears in Stormheim as a farm where respawns keep up.",
        "Farm in a compact loop rather than chasing every bear on the map.",
        "Skinning adds Stonehide Leather side value.",
    },
    coords = {
        C(0.706, 0.522, "Bear route center"),
        C(0.682, 0.498, "West bear pack"),
        C(0.730, 0.548, "East bear pack"),
    },
    confidence = "medium",
}

local BEAR_HIGHMOUNTAIN_ROUTE = {
    id = "legion-fatty-bearsteak-highmountain-bristlefur-bears",
    source = "wow-professions Fatty Bearsteak guide, Petopia Bristlefur Bear page, and Blizzplanet quest notes",
    sourceUrls = {
        "https://www.wow-professions.com/farming/fatty-bearsteak-farming",
        "https://www.wow-petopia.com/npc.php?id=96146",
        "https://warcraft.blizzplanet.com/blog/comments/bear-huntin",
    },
    mapName = "Highmountain",
    location = "Fields of An'she Bristlefur Bear route",
    routeType = "beast-meat-loop",
    density = "Medium to high",
    dropDifficulty = "Good backup farm; world quest traffic can make tagging competitive.",
    tips = {
        "The guide points to Bristlefur Bears and warns that world quests can crowd the spot.",
        "Petopia places Bristlefur Bears in the Fields of An'she.",
        "Pull tightly only when the world quest is not crowded.",
    },
    coords = {
        C(0.398, 0.486, "Fields of An'she bears"),
        C(0.366, 0.454, "West bear pack"),
        C(0.426, 0.522, "South bear pack"),
    },
    confidence = "medium",
}

local BIG_GAMY_RIBS_ROUTE = {
    id = "legion-big-gamy-ribs-highmountain-nesingwary-hillstriders",
    source = "wow-professions Big Gamy Ribs guide and Wowhead Stonehide comments",
    sourceUrls = {
        "https://www.wow-professions.com/farming/big-gamy-ribs-farming",
        "https://www.wowhead.com/item=124113/stonehide-leather",
        "https://www.wowhead.com/npc=96410/sated-hillstrider",
    },
    mapName = "Highmountain",
    location = "Nesingwary camp Sated Hillstriders",
    routeType = "beast-meat-and-skinning-loop",
    density = "High",
    dropDifficulty = "Very good compact route because Sated Hillstriders respawn constantly.",
    tips = {
        "The guide identifies Nesingwary's camp as the best Big Gamy Ribs spot.",
        "A Wowhead comment gives the area around 41,53 and notes near-immediate goat respawns.",
        "Skin the goats for Stonehide Leather if you have Skinning.",
    },
    coords = {
        C(0.410, 0.530, "Nesingwary camp hillstriders"),
        C(0.432, 0.512, "North hillstrider packs"),
        C(0.392, 0.548, "South hillstrider packs"),
    },
    confidence = "high",
}

local LEYBLOOD_MISTHOLLOW_ROUTE = {
    id = "legion-leyblood-suramar-misthollow-hunters",
    source = "wow-professions Leyblood guide and Warcraft Wiki Misthollow Hunter page",
    sourceUrls = {
        "https://www.wow-professions.com/farming/leyblood-farming",
        "https://warcraft.wiki.gg/wiki/Misthollow_Hunter",
    },
    mapName = "Suramar",
    location = "Misthollow Hunter farm with Moonlight Hunter backup packs",
    routeType = "beast-meat-loop",
    density = "High",
    dropDifficulty = "Best Leyblood route; geared characters may wait on respawns.",
    tips = {
        "The guide identifies Misthollow Hunters as the best Leyblood farm.",
        "Kill nearby Moonlight Hunter packs while waiting for respawns.",
        "If this camp is busy, use Thicket Hunters as a second Suramar route.",
    },
    coords = {
        C(0.410, 0.442, "Misthollow Hunter camp"),
        C(0.438, 0.464, "Moonlight Hunter backup"),
        C(0.386, 0.480, "Western respawn check"),
    },
    confidence = "medium",
}

local LEYBLOOD_AZSUNA_ROUTE = {
    id = "legion-leyblood-azsuna-flashwyrm-cave",
    source = "wow-professions Leyblood guide",
    sourceUrls = {
        "https://www.wow-professions.com/farming/leyblood-farming",
    },
    mapName = "Azsuna",
    location = "Azurewing Repose Flashwyrm cave",
    routeType = "cave-aoe-meat-farm",
    density = "Burst only",
    dropDifficulty = "Good quick burst of Leyblood but long respawn makes it poor for continuous farming.",
    tips = {
        "The guide says to pull all Flashwyrms together for a fast 40-50 Leyblood burst.",
        "Leave after clearing if respawns are slow.",
        "Use this when you only need a small amount quickly.",
    },
    coords = {
        C(0.488, 0.266, "Azurewing Repose cave entrance"),
        C(0.506, 0.258, "Inner Flashwyrm pack"),
    },
    confidence = "medium",
}

local WILDFOWL_STORMHEIM_ROUTE = {
    id = "legion-wildfowl-egg-stormheim-coastal-seagulls",
    source = "wow-professions Wildfowl Egg guide and Wowhead Wildfowl Egg page",
    sourceUrls = {
        "https://www.wow-professions.com/farming/wildfowl-egg-farming",
        "https://www.wowhead.com/item=124121/wildfowl-egg",
    },
    mapName = "Stormheim",
    location = "Stormheim Coastal Seagull and Direbreak cliffs",
    routeType = "bird-egg-farm",
    density = "Very high",
    dropDifficulty = "Excellent egg farm, but cliff corpses and elite patrols can be annoying.",
    tips = {
        "The guide reports large Coastal Seagull groups on cliffs and rocks.",
        "Pull a ground mob near cliff corpses to mass-loot birds that died above you.",
        "Avoid elite patrols unless your character can burst them safely.",
    },
    coords = {
        C(0.512, 0.208, "Coastal seagull cliffs"),
        C(0.540, 0.232, "Direbreak bird packs"),
        C(0.572, 0.260, "Eastern cliff birds"),
    },
    confidence = "medium",
}

local WILDFOWL_AZSUNA_ROUTE = {
    id = "legion-wildfowl-egg-azsuna-bloodgazers",
    source = "wow-professions Wildfowl Egg guide and Wowhead Wildfowl Egg page",
    sourceUrls = {
        "https://www.wow-professions.com/farming/wildfowl-egg-farming",
        "https://www.wowhead.com/item=124121/wildfowl-egg",
    },
    mapName = "Azsuna",
    location = "Young Bloodgazer and Bloodgazer Nest-Keeper falcosaur area",
    routeType = "bird-egg-farm",
    density = "High",
    dropDifficulty = "Fast respawn egg route with elite patrols nearby.",
    tips = {
        "The guide says Young Bloodgazers and Nest-Keepers have very fast respawn.",
        "Avoid elite patrols; they are not worth killing for egg volume.",
        "This same area can provide Stonehide Leather if skinned.",
    },
    coords = {
        C(0.330, 0.197, "Bloodgazer nest center"),
        C(0.314, 0.214, "West nests"),
        C(0.354, 0.228, "East nests"),
    },
    confidence = "high",
}

local SLICE_OF_BACON_AZSUNA_ROUTE = {
    id = "legion-slice-of-bacon-azsuna-slab-world-quest",
    source = "Retail Wowhead Slice of Bacon item comments, Wowhead Slab of Bacon quest page, and Wowhead Legion Cooking guide",
    sourceUrls = {
        "https://www.wowhead.com/item=133680/slice-of-bacon",
        "https://www.wowhead.com/quest=41551/slab-of-bacon",
        "https://www.wowhead.com/guide/legion-cooking",
    },
    mapName = "Azsuna",
    location = "Slab of Bacon cooking world quest rare-beast checks",
    routeType = "cooking-world-quest-target",
    density = "Intermittent",
    dropDifficulty = "Only available when the relevant Legion Cooking world quest is active.",
    tips = {
        "Slice of Bacon comes from Legion Cooking world quests, not from a repeatable normal beast loop.",
        "A Wowhead quest comment reports Well-Fed Sea Lion checks at 33.8,11.5 and 65,71.5 in Azsuna.",
        "Current comments indicate Legion Cooking skill is needed before bacon world quests appear.",
    },
    coords = {
        C(0.338, 0.115, "Challiane's Terrace Well-Fed Sea Lion report"),
        C(0.650, 0.715, "Southeast Azsuna Well-Fed Sea Lion report"),
    },
    confidence = "medium",
}

local DALARAN_COOKING_VENDOR_ROUTE = {
    id = "legion-cooking-dalaran-supply-vendors",
    source = "Retail Wowhead Legion Cooking guide, Wowhead vendor material pages, and Bradford Duncan/Misensi NPC pages",
    sourceUrls = {
        "https://www.wowhead.com/guide/legion-cooking",
        "https://www.wowhead.com/item=133588/flaked-sea-salt",
        "https://www.wowhead.com/item=133589/dalapeno-pepper",
        "https://www.wowhead.com/item=133590/muskenbutter",
        "https://www.wowhead.com/item=133591/river-onion",
        "https://www.wowhead.com/item=133592/stonedark-snail",
        "https://www.wowhead.com/item=133593/royal-olive",
        "https://www.wowhead.com/npc=93545/bradford-duncan",
        "https://www.wowhead.com/npc=93537/misensi",
    },
    mapName = "Dalaran",
    location = "Legion Dalaran cooking supply vendors in A Hero's Welcome and The Filthy Animal",
    routeType = "vendor-purchase",
    density = "Always available from vendor",
    dropDifficulty = "Purchase route; no outdoor farming required.",
    tips = {
        "Buy these directly from the Legion Dalaran cooking supply vendors before pricing AH resale or recipe costs.",
        "Bradford Duncan is the Alliance-side vendor in A Hero's Welcome; Misensi is the Horde-side vendor in The Filthy Animal.",
        "Vendor stack sizes can force small overbuys, so compare stack cost against auction prices.",
    },
    coords = {
        C(0.408, 0.652, "A Hero's Welcome cooking vendor area"),
        C(0.633, 0.330, "The Filthy Animal cooking vendor area"),
    },
    confidence = "medium",
}

local function RegisterMeat(itemID, itemName, spots, summary)
    Register({
        itemID = itemID,
        itemName = itemName,
        expansion = "legion",
        professions = { "cooking" },
        category = "Meat",
        sourceUrls = { ItemUrl(itemID) },
        summary = summary,
        spots = spots,
    })
end

local function RegisterCookingVendor(itemID, itemName)
    Register({
        itemID = itemID,
        itemName = itemName,
        expansion = "legion",
        professions = { "vendor", "cooking" },
        category = "Vendor",
        sourceUrls = { ItemUrl(itemID), "https://www.wowhead.com/guide/legion-cooking" },
        summary = "Legion cooking vendor reagent purchased from Dalaran cooking supply vendors.",
        spots = { DALARAN_COOKING_VENDOR_ROUTE },
    })
end

RegisterMeat(
    124117,
    "Lean Shank",
    { ICEFANG_ROUTE, SURAMAR_SNARLER_MEAT_ROUTE },
    "Broken Isles meat from dense wolf and beast pack farms."
)
RegisterMeat(
    124118,
    "Fatty Bearsteak",
    { BEAR_STORMHEIM_ROUTE, BEAR_HIGHMOUNTAIN_ROUTE },
    "Bear meat farmed from Voracious Bears in Stormheim or Bristlefur Bears in Highmountain."
)
RegisterMeat(
    124119,
    "Big Gamy Ribs",
    { BIG_GAMY_RIBS_ROUTE },
    "Highmountain goat and elderhorn meat farm near Nesingwary's camp."
)
RegisterMeat(
    124120,
    "Leyblood",
    { LEYBLOOD_MISTHOLLOW_ROUTE, LEYBLOOD_AZSUNA_ROUTE },
    "Legion meat best farmed from Misthollow Hunters, with Flashwyrm cave as a burst backup."
)
RegisterMeat(
    124121,
    "Wildfowl Egg",
    { WILDFOWL_STORMHEIM_ROUTE, WILDFOWL_AZSUNA_ROUTE },
    "Legion bird egg from dense Coastal Seagull and Bloodgazer farms."
)
RegisterMeat(
    133680,
    "Slice of Bacon",
    { SLICE_OF_BACON_AZSUNA_ROUTE },
    "Legion cooking material from Slab of Bacon world quests."
)

RegisterCookingVendor(133588, "Flaked Sea Salt")
RegisterCookingVendor(133589, "Dalapeno Pepper")
RegisterCookingVendor(133590, "Muskenbutter")
RegisterCookingVendor(133591, "River Onion")
RegisterCookingVendor(133592, "Stonedark Snail")
RegisterCookingVendor(133593, "Royal Olive")
