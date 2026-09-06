local _, NS = ...
local Register = NS.RegisterMaterialFarmingSpot

local function C(x, y, label)
    return { x = x, y = y, label = label }
end

local function ItemUrl(itemID)
    return "https://www.wowhead.com/item=" .. tostring(itemID)
end

local LEGION_HERB_TIPS = {
    "Use Enchant Gloves - Legion Herbalism to reduce gather time.",
    "Use Sky Golem or Demonsteel Stirrups when available so hostile mobs interrupt fewer gathers.",
    "If a route is dry, keep moving; Legion nodes are shared but still affected by competition and phasing.",
}

local function WithHerbTips(extra)
    local tips = {}
    for _, tip in ipairs(LEGION_HERB_TIPS) do
        tips[#tips + 1] = tip
    end
    for _, tip in ipairs(extra or {}) do
        tips[#tips + 1] = tip
    end
    return tips
end

local AETHRIL_ROUTE = {
    id = "legion-aethril-azsuna-road-loop",
    source = "wow-professions Aethril guide and Wowhead Aethril object page",
    sourceUrls = {
        "https://www.wow-professions.com/farming/aethril-farming",
        "https://www.wowhead.com/object=244774/aethril",
    },
    mapName = "Azsuna",
    location = "Azsuna main-road and Drowned Gardens Aethril route",
    routeType = "herbalism-loop",
    density = "High",
    dropDifficulty = "Easy Legion herb route with modest combat pressure.",
    tips = WithHerbTips({
        "The guide describes Aethril as an Azsuna route that follows roads well for non-flying characters.",
        "Kill Withered Hungerers that spawn from herbs because they can drop extra Aethril.",
        "Use the larger outer loop if you are gathering faster than respawns.",
    }),
    coords = {
        C(0.386, 0.268, "Northern road herbs"),
        C(0.482, 0.318, "Drowned Gardens"),
        C(0.556, 0.420, "Central road"),
        C(0.542, 0.566, "Azurewing road"),
        C(0.448, 0.646, "Western road return"),
        C(0.342, 0.506, "Ruined Sanctum return"),
    },
    confidence = "high",
}

local DREAMLEAF_ROUTE = {
    id = "legion-dreamleaf-valsharah-darkheart-rooters",
    source = "wow-professions Dreamleaf guide, Wowhead Dreamleaf object page, Wowhead comments, and Artisans of Azeroth retail Val'sharah route string",
    sourceUrls = {
        "https://www.wow-professions.com/farming/dreamleaf-farming",
        "https://www.wowhead.com/object=244776/dreamleaf",
        "https://www.wowhead.com/item=124102/dreamleaf",
        "https://artisansofazeroth.com/legion-herbalism-leveling/",
    },
    mapName = "Val'sharah",
    location = "Darkheart Thicket exterior Vilepetal Rooter and Dreamleaf route",
    routeType = "herbalism-and-herbable-mob-loop",
    density = "High",
    dropDifficulty = "Strong targeted Dreamleaf farm using Vilepetal Rooters and corrupted plant mobs.",
    tips = WithHerbTips({
        "The guide calls Vilepetal Rooters the best Dreamleaf target because their corpses can be gathered.",
        "A community note also points to short treants and flower mobs outside Darkheart Thicket.",
        "Kill Nightmare Creepers that spawn from nodes for additional Dreamleaf.",
    }),
    coords = {
        C(0.476, 0.418, "Darkheart Thicket west"),
        C(0.510, 0.376, "Vilepetal Rooter pocket"),
        C(0.548, 0.408, "Dreamleaf node sweep"),
        C(0.590, 0.470, "Eastern thicket edge"),
        C(0.536, 0.536, "Southern return"),
        C(0.462, 0.518, "Western return"),
        C(0.7421, 0.3759, "AoA Val'sharah eastern route pin"),
        C(0.6995, 0.4923, "AoA Val'sharah east bank pin"),
        C(0.6575, 0.5570, "AoA Val'sharah central pin"),
        C(0.6008, 0.8087, "AoA Val'sharah southern river pin"),
        C(0.5095, 0.7959, "AoA Val'sharah southwest river pin"),
        C(0.4054, 0.8759, "AoA Val'sharah far southwest pin"),
        C(0.3441, 0.6261, "AoA Val'sharah western return pin"),
        C(0.4433, 0.5874, "AoA Val'sharah central return pin"),
    },
    confidence = "high",
}

local FOXFLOWER_ROUTE = {
    id = "legion-foxflower-highmountain-felbane-prepfoot-loop",
    source = "wow-professions Foxflower guide and Wowhead Foxflower object page",
    sourceUrls = {
        "https://www.wow-professions.com/farming/foxflower-farming",
        "https://www.wowhead.com/object=241641/foxflower",
    },
    mapName = "Highmountain",
    location = "Highmountain Foxflower path from Felbane Camp toward Prepfoot and Blind Marshlands",
    routeType = "herbalism-loop",
    density = "Medium",
    dropDifficulty = "Useful but awkward; terrain and aggressive mobs make the route slower before flying.",
    tips = WithHerbTips({
        "The guide notes Highmountain terrain is the main problem, so learn the descent paths before long farms.",
        "Use the Felbane Camp and Prepfoot flight paths to reset between long ground loops.",
        "Chase the fox spawn trail when it appears, because it drops extra Foxflower along the ground.",
    }),
    coords = {
        C(0.426, 0.424, "Northwest cliff herbs"),
        C(0.494, 0.492, "Central Highmountain path"),
        C(0.570, 0.564, "Prepfoot descent"),
        C(0.606, 0.684, "Felbane Camp end"),
        C(0.488, 0.704, "Southern valley return"),
        C(0.364, 0.566, "Western ridge return"),
    },
    confidence = "high",
}

local FJARNSKAGGL_ROUTE = {
    id = "legion-fjarnskaggl-stormheim-main-route",
    source = "wow-professions Fjarnskaggl guide and Wowhead Fjarnskaggl object page",
    sourceUrls = {
        "https://www.wow-professions.com/farming/fjarnskaggl-farming",
        "https://www.wowhead.com/object=244777/fjarnskaggl",
    },
    mapName = "Stormheim",
    location = "Stormheim Fjarnskaggl cliff and road route",
    routeType = "herbalism-loop",
    density = "Medium to high",
    dropDifficulty = "Good route but rough without mounted gathering because many sections force mob contact.",
    tips = WithHerbTips({
        "The guide calls Stormheim the main Fjarnskaggl route and warns that competition can dry both routes.",
        "Stick to the right side of the hill near the small Horde camp if playing Alliance.",
        "Use the alternative route when the main cliff route is already farmed.",
    }),
    coords = {
        C(0.360, 0.372, "Western cliff herbs"),
        C(0.486, 0.338, "Northern road herbs"),
        C(0.608, 0.424, "Eastern cliff check"),
        C(0.636, 0.566, "Southeast path"),
        C(0.524, 0.688, "Southern return"),
        C(0.386, 0.610, "Western return"),
    },
    confidence = "high",
}

local STARLIGHT_ROSE_ROUTE = {
    id = "legion-starlight-rose-suramar-loop",
    source = "wow-professions Starlight Rose guide and Wowhead Starlight Rose object page",
    sourceUrls = {
        "https://www.wow-professions.com/farming/starlight-rose-farming",
        "https://www.wowhead.com/object=244789/starlight-rose",
    },
    mapName = "Suramar",
    location = "Suramar Starlight Rose loop around city outskirts, roads, and ruins",
    routeType = "herbalism-loop",
    density = "Medium",
    dropDifficulty = "Valuable but fussy; failed gathers produce Starlight Rosedust until higher ranks.",
    tips = WithHerbTips({
        "Turn off Mana Divining Stone while farming if the mana ping becomes distracting.",
        "Kill Withered Hungerers spawned by gathering because they can drop extra Starlight Rose.",
        "Use a wider loop if you gather faster than the non-flying route respawns.",
    }),
    coords = {
        C(0.418, 0.250, "Northern Suramar roses"),
        C(0.510, 0.322, "Central road roses"),
        C(0.604, 0.468, "Eastern ruins"),
        C(0.520, 0.620, "Southern road"),
        C(0.370, 0.562, "Western return"),
    },
    confidence = "high",
}

local FELWORT_AZSUNA_ROUTE = {
    id = "legion-felwort-azsuna-world-quest",
    source = "Wowhead Felwort comments, Wowhead Felwort object page, and MMO-Champion coordinate reports",
    sourceUrls = {
        "https://www.wowhead.com/item=124106/felwort",
        "https://www.wowhead.com/object=252404/felwort",
        "https://www.mmo-champion.com/threads/2061690-Felwort-gathering",
    },
    mapName = "Azsuna",
    location = "Azsuna Felwort profession world quest report",
    routeType = "world-quest-herb-target",
    density = "Intermittent",
    dropDifficulty = "Only reliable when a Felwort world quest or Felwort Seed source is available.",
    tips = WithHerbTips({
        "A Wowhead comment reports Azsuna at 48.6,57.2 as a Felwort world quest location.",
        "Do not treat Felwort as a normal repeating herb loop; check WQs or seed sources first.",
    }),
    coords = {
        C(0.486, 0.572, "Azsuna Felwort WQ report"),
    },
    confidence = "medium",
}

local FELWORT_HIGHMOUNTAIN_ROUTE = {
    id = "legion-felwort-highmountain-witchwood-world-quest",
    source = "Wowhead Felwort comments, Wowhead Felwort object page, and MMO-Champion coordinate reports",
    sourceUrls = {
        "https://www.wowhead.com/item=124106/felwort",
        "https://www.wowhead.com/object=252404/felwort",
        "https://www.mmo-champion.com/threads/2061690-Felwort-gathering",
    },
    mapName = "Highmountain",
    location = "The Witchwood Felwort profession world quest report",
    routeType = "world-quest-herb-target",
    density = "Intermittent",
    dropDifficulty = "Only reliable when a Felwort world quest or Felwort Seed source is available.",
    tips = WithHerbTips({
        "A community report places a Highmountain Felwort world quest around 36.0,42.2 near The Witchwood.",
        "Do not treat Felwort as a normal repeating herb loop; check WQs or seed sources first.",
    }),
    coords = {
        C(0.360, 0.422, "Highmountain Witchwood WQ report"),
    },
    confidence = "medium",
}

local ASTRAL_GLORY_KROKUUN_ROUTE = {
    id = "legion-astral-glory-krokuun-fel-encrusted-herbs",
    source = "wow-professions Astral Glory guide, Wowhead Argus herb object pages, and Artisans of Azeroth retail Krokuun route string",
    sourceUrls = {
        "https://www.wow-professions.com/farming/astral-glory-farming",
        "https://www.wowhead.com/item=151565/astral-glory",
        "https://artisansofazeroth.com/legion-herbalism-leveling/",
    },
    mapName = "Krokuun",
    location = "Krokuun Fel-Encrusted Herb route",
    routeType = "herbalism-loop",
    density = "High",
    dropDifficulty = "Best Astral Glory route, but Argus mobs make every gather more dangerous.",
    tips = WithHerbTips({
        "The guide identifies Krokuun as the best Astral Glory zone.",
        "Gather Fel-Encrusted Herbs; those nodes provide Astral Glory.",
        "Use tank spec or anti-daze support because the guide warns mobs are hard to avoid.",
    }),
    coords = {
        C(0.5879, 0.3141, "AoA Krokuun northern herb pin"),
        C(0.5935, 0.3613, "AoA Krokuun northern ridge herb pin"),
        C(0.5913, 0.4013, "AoA Krokuun north-central herb pin"),
        C(0.486, 0.610, "Central Krokuun herbs"),
        C(0.562, 0.560, "Eastern ridge"),
        C(0.6175, 0.4583, "AoA Krokuun east ridge herb pin"),
        C(0.638, 0.604, "Southern ridge"),
        C(0.594, 0.704, "Southern return"),
        C(0.5497, 0.6117, "AoA Krokuun southern return herb pin"),
        C(0.450, 0.706, "Western return"),
    },
    confidence = "high",
}

local ASTRAL_GLORY_EREDATH_ROUTE = {
    id = "legion-astral-glory-eredath-backup-loop",
    source = "wow-professions Astral Glory guide and Wowhead Astral Glory page",
    sourceUrls = {
        "https://www.wow-professions.com/farming/astral-glory-farming",
        "https://www.wowhead.com/item=151565/astral-glory",
    },
    mapName = "Eredath",
    location = "Eredath Fel-Encrusted Herb backup route",
    routeType = "herbalism-loop",
    density = "Medium",
    dropDifficulty = "Slightly lower yield than Krokuun but usually less punishing.",
    tips = WithHerbTips({
        "Use Eredath when Krokuun is crowded or too hostile.",
        "Loop the flatter western and central islands before pushing into denser mob pockets.",
    }),
    coords = {
        C(0.400, 0.330, "Western Eredath herbs"),
        C(0.480, 0.412, "Central platform"),
        C(0.568, 0.486, "Eastern bridge herbs"),
        C(0.522, 0.600, "Southern return"),
        C(0.382, 0.530, "Western return"),
    },
    confidence = "medium",
}

local function RegisterHerb(itemID, itemName, spots, summary)
    Register({
        itemID = itemID,
        itemName = itemName,
        expansion = "legion",
        professions = { "herbalism", "alchemy", "inscription" },
        category = "Herb",
        sourceUrls = { ItemUrl(itemID) },
        summary = summary,
        spots = spots,
    })
end

local function RegisterSeed(itemID, itemName, spots, summary)
    Register({
        itemID = itemID,
        itemName = itemName,
        expansion = "legion",
        professions = { "herbalism", "alchemy", "inscription" },
        category = "Seed",
        sourceUrls = {
            ItemUrl(itemID),
            "https://www.wowhead.com/guide/legion-herbalism",
            "https://www.reddit.com/r/woweconomy/comments/6iet7b/guide_legion_seed_raid_wow_seed_raid_discord/",
        },
        summary = summary,
        spots = spots,
    })
end

RegisterHerb(124101, "Aethril", { AETHRIL_ROUTE }, "Azsuna road and Drowned Gardens node route.")
RegisterHerb(
    124102,
    "Dreamleaf",
    { DREAMLEAF_ROUTE },
    "Val'sharah herb and gatherable-mob farm around Darkheart Thicket."
)
RegisterHerb(124103, "Foxflower", { FOXFLOWER_ROUTE }, "Highmountain herb route with fox-trail bonus spawns.")
RegisterHerb(124104, "Fjarnskaggl", { FJARNSKAGGL_ROUTE }, "Stormheim herb route across cliffs and roads.")
RegisterHerb(
    124105,
    "Starlight Rose",
    { STARLIGHT_ROSE_ROUTE },
    "Suramar herb route with failed-gather and Withered Hungerer mechanics."
)
RegisterHerb(
    124106,
    "Felwort",
    { FELWORT_AZSUNA_ROUTE, FELWORT_HIGHMOUNTAIN_ROUTE },
    "World-quest and seed-gated Legion herb with intermittent coordinate anchors."
)
RegisterHerb(
    151565,
    "Astral Glory",
    { ASTRAL_GLORY_KROKUUN_ROUTE, ASTRAL_GLORY_EREDATH_ROUTE },
    "Argus herb from Fel-Encrusted Herb routes, best in Krokuun with Eredath as backup."
)

Register({
    itemID = 128304,
    itemName = "Yseralline Seed",
    expansion = "legion",
    professions = { "herbalism", "alchemy", "inscription", "cooking" },
    category = "Seed",
    sourceUrls = {
        ItemUrl(128304),
        "https://www.wowhead.com/guide/legion-herbalism",
        "https://www.wowhead.com/guide/legion-alchemy",
        "https://warcraft.wiki.gg/wiki/Yseralline_Seed",
    },
    summary = "Common Legion seed found while gathering Broken Isles herbs and used by Alchemy, Inscription, and Cooking workflows.",
    spots = { DREAMLEAF_ROUTE, AETHRIL_ROUTE, STARLIGHT_ROSE_ROUTE },
})

RegisterSeed(129284, "Aethril Seed", { AETHRIL_ROUTE }, "Plantable Legion herb seed obtained from Aethril and other Broken Isles herbalism routes.")
RegisterSeed(129285, "Dreamleaf Seed", { DREAMLEAF_ROUTE }, "Plantable Legion herb seed obtained from Dreamleaf and other Broken Isles herbalism routes.")
RegisterSeed(129286, "Foxflower Seed", { FOXFLOWER_ROUTE }, "Plantable Legion herb seed obtained from Foxflower and other Broken Isles herbalism routes.")
RegisterSeed(129287, "Fjarnskaggl Seed", { FJARNSKAGGL_ROUTE }, "Plantable Legion herb seed obtained from Fjarnskaggl and other Broken Isles herbalism routes.")
RegisterSeed(129288, "Starlight Rose Seed", { STARLIGHT_ROSE_ROUTE }, "Plantable Legion herb seed obtained from Starlight Rose and other Broken Isles herbalism routes.")
RegisterSeed(129289, "Felwort Seed", { FELWORT_AZSUNA_ROUTE, FELWORT_HIGHMOUNTAIN_ROUTE }, "Rare Legion herb seed associated with Felwort gathering and world-quest/seed workflows.")
