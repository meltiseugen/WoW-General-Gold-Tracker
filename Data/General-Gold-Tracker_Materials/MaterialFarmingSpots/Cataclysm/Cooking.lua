local _, NS = ...
local Register = NS.RegisterMaterialFarmingSpot

local function C(x, y, label, mapID)
    return { x = x, y = y, label = label, mapID = mapID }
end

local function ItemUrl(itemID)
    return "https://www.wowhead.com/item=" .. tostring(itemID)
end

local function NpcUrl(npcID)
    return "https://www.wowhead.com/npc=" .. tostring(npcID)
end

local ULDUM_HYENAS = {
    id = "cataclysm-toughened-flesh-uldum-mangy-hyenas",
    source = "Retail Wowhead Toughened Flesh comments and Mangy Hyena NPC map pins",
    sourceUrls = {
        ItemUrl(62778),
        NpcUrl(45202),
    },
    mapName = "Uldum",
    location = "Obelisk of the Stars hyena packs",
    routeType = "open-world-kill-loop",
    density = "High",
    dropDifficulty = "Tight Uldum beast route; use Zidormi if the zone phase is wrong.",
    tips = {
        "Circle the Obelisk of the Stars packs and keep the loop small.",
        "Skinning adds Savage Leather side value if the beasts are skinnable for your character.",
    },
    coords = {
        C(0.614, 0.306, "West hyena pack", 249),
        C(0.624, 0.284, "Northwest hyena pack", 249),
        C(0.628, 0.316, "Central west hyena pack", 249),
        C(0.636, 0.304, "Central hyena pack", 249),
        C(0.654, 0.308, "Central east hyena pack", 249),
        C(0.662, 0.296, "East hyena pack", 249),
        C(0.664, 0.254, "North hyena pack", 249),
        C(0.672, 0.352, "South hyena pack", 249),
    },
    confidence = "high",
}

local KELPTHAR_CRABS = {
    id = "cataclysm-monstrous-claw-kelpthar-crab-pins",
    source = "Retail Wowhead Monstrous Claw comments and Sabreclaw Skitterer/Clacksnap Pincer NPC map pins",
    sourceUrls = {
        ItemUrl(62779),
        NpcUrl(40276),
        NpcUrl(39918),
    },
    mapName = "Kelp'thar Forest",
    location = "Smuggler's Scar, Gurboggle's Ledge, and Gorrok's Lament crab loop",
    routeType = "open-world-kill-loop",
    density = "High",
    dropDifficulty = "Dense underwater route; movement is easier after the Vashj'ir intro sea legs setup.",
    tips = {
        "Sweep crabs around the wrecks, then detour to nearby serpent and gilblin packs for Snake Eye and Blood Shrimp.",
        "Ground-level crabs and serpents are faster than chasing scattered swimmers high above the sea floor.",
    },
    coords = {
        C(0.484, 0.442, "West crab pin", 201),
        C(0.490, 0.444, "Smuggler's Scar crab pin", 201),
        C(0.514, 0.408, "Gurboggle's Ledge crab pin", 201),
        C(0.526, 0.408, "Central crab pin", 201),
        C(0.538, 0.356, "North crab pin", 201),
        C(0.542, 0.476, "South crab pin", 201),
        C(0.564, 0.374, "Gorrok's Lament crab pin", 201),
        C(0.586, 0.394, "East crab pin", 201),
    },
    confidence = "high",
}

local KELPTHAR_SERPENTS = {
    id = "cataclysm-snake-eye-kelpthar-brinescale-serpents",
    source = "Retail Wowhead Snake Eye comments and Brinescale Serpent NPC map pins",
    sourceUrls = {
        ItemUrl(62780),
        NpcUrl(39948),
    },
    mapName = "Kelp'thar Forest",
    location = "Gorrok's Lament Brinescale Serpent wreck loop",
    routeType = "open-world-kill-loop",
    density = "Localized",
    dropDifficulty = "Narrow underwater drop route; exact pins cluster tightly around the wreck.",
    tips = {
        "Anchor at the 58,38 comment coordinate and sweep the ground-level serpents around the wreck.",
        "Combine with nearby crab pins when Monstrous Claw is also useful.",
    },
    coords = {
        C(0.552, 0.372, "West serpent pin", 201),
        C(0.562, 0.372, "Northwest serpent pin", 201),
        C(0.564, 0.354, "North serpent pin", 201),
        C(0.566, 0.378, "Central serpent pin", 201),
        C(0.568, 0.396, "South serpent pin", 201),
        C(0.580, 0.380, "Comment anchor near Gorrok's Lament", 201),
        C(0.588, 0.394, "East serpent pin", 201),
        C(0.592, 0.402, "Southeast serpent pin", 201),
    },
    confidence = "high",
}

local KELPTHAR_TURTLES = {
    id = "cataclysm-giant-turtle-tongue-kelpthar-speckled-sea-turtles",
    source = "Retail Wowhead Giant Turtle Tongue comments and Speckled Sea Turtle NPC map pins",
    sourceUrls = {
        ItemUrl(62781),
        NpcUrl(40223),
    },
    mapName = "Kelp'thar Forest",
    location = "Smuggler's Scar and Gurboggle's Ledge turtle route",
    routeType = "open-world-kill-loop",
    density = "Medium",
    dropDifficulty = "Focused turtle route with nearby mixed seafood side targets.",
    tips = {
        "Sweep between Smuggler's Scar and Gurboggle's Ledge rather than crossing all of Vashj'ir.",
        "Pair with crab and serpent loops when cooking several Cataclysm recipes.",
    },
    coords = {
        C(0.492, 0.404, "West turtle pin", 201),
        C(0.492, 0.418, "Northwest turtle pin", 201),
        C(0.510, 0.424, "Central turtle pin", 201),
        C(0.514, 0.446, "Gurboggle's Ledge turtle pin", 201),
        C(0.516, 0.468, "South central turtle pin", 201),
        C(0.522, 0.402, "North turtle pin", 201),
        C(0.524, 0.484, "South turtle pin", 201),
        C(0.536, 0.466, "East turtle pin", 201),
    },
    confidence = "high",
}

local DEEPHOLM_DRAKES = {
    id = "cataclysm-dragon-flank-deepholm-stonescale-drakes",
    source = "Retail Wowhead Dragon Flank comments and Stonescale Drake NPC map pins",
    sourceUrls = {
        ItemUrl(62782),
        NpcUrl(43971),
    },
    mapName = "Deepholm",
    location = "Alabaster Shelf and southern Pale Roost drake route",
    routeType = "open-world-kill-loop",
    density = "Medium",
    dropDifficulty = "Tight Deepholm dragonkin cluster; good when cooking and skinning scale value overlap.",
    tips = {
        "Stay on the southern drake shelf and avoid stretching into sparse Deepholm spawns.",
        "Skinning can add Blackened Dragonscale or Savage Leather side value.",
    },
    coords = {
        C(0.526, 0.794, "West drake pin", 207),
        C(0.526, 0.816, "Northwest drake pin", 207),
        C(0.532, 0.802, "Central west drake pin", 207),
        C(0.542, 0.848, "Southwest drake pin", 207),
        C(0.562, 0.884, "South drake pin", 207),
        C(0.574, 0.854, "Southeast drake pin", 207),
        C(0.586, 0.838, "East drake pin", 207),
        C(0.596, 0.832, "Far east drake pin", 207),
    },
    confidence = "high",
}

local DEEPHOLM_BASILISKS = {
    id = "cataclysm-basilisk-liver-deepholm-shalehide-basilisks",
    source = "Retail Wowhead Basilisk Liver comments and Shalehide Basilisk NPC map pins",
    sourceUrls = {
        ItemUrl(62783),
        NpcUrl(43181),
    },
    mapName = "Deepholm",
    location = "Northern Deepholm Shalehide Basilisk route",
    routeType = "open-world-kill-loop",
    density = "High",
    dropDifficulty = "Best focused Basilisk Liver route; Shalehide Basilisks hit hard at level but are trivial on retail max-level characters.",
    tips = {
        "Use the northern Deepholm pin cluster instead of roaming the whole zone.",
        "Skin the basilisks if you want Savage Leather and Pristine Hide side value.",
    },
    coords = {
        C(0.352, 0.238, "Northwest basilisk pin", 207),
        C(0.358, 0.268, "West basilisk pin", 207),
        C(0.370, 0.246, "Central west basilisk pin", 207),
        C(0.376, 0.316, "Southwest basilisk pin", 207),
        C(0.394, 0.274, "Central basilisk pin", 207),
        C(0.408, 0.216, "North central basilisk pin", 207),
        C(0.422, 0.256, "East basilisk pin", 207),
        C(0.444, 0.258, "Far east basilisk pin", 207),
    },
    confidence = "high",
}

local ULDUM_CROCOLISKS = {
    id = "cataclysm-crocolisk-tail-uldum-riverbed-crocolisks",
    source = "Retail Wowhead Crocolisk Tail comments and Riverbed Crocolisk NPC map pins",
    sourceUrls = {
        ItemUrl(62784),
        NpcUrl(45321),
    },
    mapName = "Uldum",
    location = "Vir'naal River and Lost City Riverbed Crocolisk route",
    routeType = "open-world-kill-loop",
    density = "High",
    dropDifficulty = "Dense Uldum river route; use Zidormi if the zone phase is wrong.",
    tips = {
        "Follow the riverbed pins through the Lost City bend and southern delta.",
        "Skinning and nearby Whiptail nodes add side value.",
    },
    coords = {
        C(0.450, 0.274, "North river crocolisk", 249),
        C(0.494, 0.306, "Central river crocolisk", 249),
        C(0.544, 0.462, "Lost City north crocolisk", 249),
        C(0.552, 0.474, "Lost City west crocolisk", 249),
        C(0.570, 0.446, "Lost City center crocolisk", 249),
        C(0.574, 0.506, "Lost City east crocolisk", 249),
        C(0.578, 0.544, "South river crocolisk", 249),
        C(0.600, 0.570, "Southeast river crocolisk", 249),
    },
    confidence = "high",
}

local ULDUM_CARRION_BIRDS = {
    id = "cataclysm-delicate-wing-uldum-carrion-birds",
    source = "Retail Wowhead Delicate Wing comments and Carrion Bird NPC map pins",
    sourceUrls = {
        ItemUrl(62785),
        NpcUrl(51760),
    },
    mapName = "Uldum",
    location = "Southeast Uldum carrion bird route",
    routeType = "open-world-kill-loop",
    density = "Localized",
    dropDifficulty = "Small pin cluster; useful when you need Delicate Wing specifically.",
    tips = {
        "Sweep the southeast bird pins, then check nearby Uldum cooking routes if respawns lag.",
        "Use Zidormi if Uldum is in the wrong phase.",
    },
    coords = {
        C(0.664, 0.604, "Northwest carrion bird", 249),
        C(0.666, 0.602, "North carrion bird", 249),
        C(0.670, 0.632, "Central carrion bird", 249),
        C(0.692, 0.624, "East carrion bird", 249),
        C(0.692, 0.626, "East return carrion bird", 249),
        C(0.702, 0.674, "South carrion bird", 249),
        C(0.702, 0.676, "South return carrion bird", 249),
    },
    confidence = "high",
}

local KELPTHAR_BLOOD_SHRIMP = {
    id = "cataclysm-blood-shrimp-kelpthar-zinjatar-clams",
    source = "Retail Wowhead Blood Shrimp comments and Zin'jatar Raider NPC map pins",
    sourceUrls = {
        ItemUrl(62791),
        NpcUrl(39313),
    },
    mapName = "Kelp'thar Forest",
    location = "Legion's Fate Zin'jatar Raider and clam route",
    routeType = "open-world-kill-loop",
    density = "High",
    dropDifficulty = "Indirect cooking farm: kill Vashj'ir mobs, loot Abyssal Clams, then open them for Blood Shrimp.",
    tips = {
        "Use the Legion's Fate pin cluster near the 41,35 comment anchor.",
        "Nespirah at 51,48 and Lightless Reaches around 33.59,88.47 are backups when this camp is crowded.",
    },
    coords = {
        C(0.394, 0.312, "West Legion's Fate raiders", 201),
        C(0.404, 0.304, "Northwest Legion's Fate raiders", 201),
        C(0.406, 0.336, "Central west raiders", 201),
        C(0.410, 0.350, "Comment anchor near Legion's Fate", 201),
        C(0.416, 0.318, "Central Legion's Fate raiders", 201),
        C(0.426, 0.336, "East Legion's Fate raiders", 201),
        C(0.446, 0.276, "Northeast raider pin", 201),
        C(0.486, 0.270, "Far east raider pin", 201),
    },
    confidence = "high",
}

local function RegisterCooking(itemID, itemName, spots, summary)
    Register({
        itemID = itemID,
        itemName = itemName,
        expansion = "cataclysm",
        professions = { "cooking" },
        category = "Meat",
        sourceUrls = {
            ItemUrl(itemID),
            "https://www.wowhead.com/guide/achievements/professions/cooking-achievements-guide",
        },
        summary = summary,
        spots = spots,
    })
end

RegisterCooking(62778, "Toughened Flesh", { ULDUM_HYENAS }, "Cataclysm cooking meat from beasts, with Uldum hyena pins providing the best focused open-world route.")
RegisterCooking(62779, "Monstrous Claw", { KELPTHAR_CRABS }, "Cataclysm cooking claw from Vashj'ir crabs; Kelp'thar pins pair well with Snake Eye and Blood Shrimp farming.")
RegisterCooking(62780, "Snake Eye", { KELPTHAR_SERPENTS }, "Cataclysm cooking meat from Vashj'ir serpents, focused around Brinescale Serpents at Gorrok's Lament.")
RegisterCooking(62781, "Giant Turtle Tongue", { KELPTHAR_TURTLES }, "Cataclysm cooking meat from Vashj'ir turtles, especially Speckled Sea Turtle pins near Smuggler's Scar.")
RegisterCooking(62782, "Dragon Flank", { DEEPHOLM_DRAKES }, "Cataclysm cooking meat from dragonkin, with Stonescale Drake pins in southern Deepholm as the most focused route.")
RegisterCooking(62783, "Basilisk \"Liver\"", { DEEPHOLM_BASILISKS }, "Cataclysm cooking meat from basilisks, with Shalehide Basilisks in northern Deepholm as the strongest target.")
RegisterCooking(62784, "Crocolisk Tail", { ULDUM_CROCOLISKS }, "Cataclysm cooking meat from crocolisks, using the Uldum Riverbed Crocolisk pin chain.")
RegisterCooking(62785, "Delicate Wing", { ULDUM_CARRION_BIRDS }, "Cataclysm cooking meat from birds, with Uldum Carrion Bird pins as a narrow target route.")
RegisterCooking(62791, "Blood Shrimp", { KELPTHAR_BLOOD_SHRIMP }, "Cataclysm cooking reagent looted from Abyssal Clams, best farmed from dense Vashj'ir mob clusters.")
