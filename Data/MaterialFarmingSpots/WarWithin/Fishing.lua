local _, NS = ...
local Register = NS.RegisterMaterialFarmingSpot

local function C(x, y, label)
    return { x = x, y = y, label = label }
end

local function ItemUrl(itemID)
    return "https://www.wowhead.com/item=" .. tostring(itemID)
end

local FISHING_OVERVIEW = "https://www.wowhead.com/guide/the-war-within/professions/fishing-overview"
local FISHING_LEVELING = "https://www.wow-professions.com/the-war-within/khaz-algar-fishing-leveling-guide"

local ISLE_DORN_POOL_ROUTE = {
    id = "tww-fishing-isle-of-dorn-coastal-pool-route",
    source = "Wowhead Fishing overview, fish item comments, and Calm Surfacing Ripple/Glimmerpool/Stargazer Swarm pages",
    sourceUrls = {
        FISHING_OVERVIEW,
        FISHING_LEVELING,
        "https://www.wowhead.com/object=451670/calm-surfacing-ripple",
        "https://www.wowhead.com/object=451669/glimmerpool",
        "https://www.wowhead.com/object=451672/stargazer-swarm",
    },
    mapName = "Isle of Dorn",
    location = "Coastal and river pool sweep for Calm Surfacing Ripple, Glimmerpool, and Stargazer Swarm",
    routeType = "fishing-pool-loop",
    density = "Medium to high",
    dropDifficulty = "Good baseline fish route; clear all visible pools to rotate spawns into the target pool type.",
    tips = {
        "Stargazer Swarm is the practical target for Whispering Stargazer and Spiked Sea Raven.",
        "Glimmerpool supplies Bismuth Bitterling, Crystalline Sturgeon, Specular Rainbowfish, and Goldengill Trout.",
        "Calm Surfacing Ripple supplies Nibbling Minnow, Dornish Pike, Quiet River Bass, and other common fish.",
    },
    coords = {
        C(0.5711, 0.5238, "The Proscenium Calm Surfacing Ripple report"),
        C(0.4090, 0.7378, "Freywold fishing hand-in water"),
        C(0.6470, 0.2470, "Northeast coastal pool sweep"),
        C(0.7020, 0.2190, "North coast Glimmerpool/Stargazer check"),
        C(0.7723, 0.2446, "Eastern coast pool return"),
        C(0.7557, 0.3741, "East Isle pool and nerubian shore"),
    },
    confidence = "medium",
}

local HALLOWFALL_BLOOD_ROUTE = {
    id = "tww-fishing-hallowfall-blood-in-the-water-route",
    source = "Wowhead Blood in the Water object comments and Fishing overview",
    sourceUrls = {
        FISHING_OVERVIEW,
        "https://www.wowhead.com/object=451678/blood-in-the-water",
        "https://www.wowhead.com/object=451671/bloody-perch-swarm",
        "https://www.wowhead.com/item=220147/kaheti-slum-shark",
    },
    mapName = "Hallowfall",
    location = "Blood in the Water pool route through western, central, and eastern Hallowfall rivers",
    routeType = "fishing-pool-route",
    density = "Medium",
    dropDifficulty = "Target pools rotate with other pool types; fish out nearby unwanted pools to force respawns.",
    tips = {
        "Use this for Bloody Perch, Arathor Hammerfish, Kaheti Slum Shark, Sanguine Dogfish, and Cursed Ghoulfish.",
        "A Wowhead comment provides a Routes import string and TomTom points for this Blood in the Water loop.",
        "Throw back Bloody Perch only when standing still and actively targeting Sanguine Dogfish.",
    },
    coords = {
        C(0.3507, 0.4550, "Blood in the Water west pool"),
        C(0.3787, 0.4906, "West route pool"),
        C(0.3862, 0.6828, "Southwest river pool"),
        C(0.3883, 0.6756, "Southwest return pool"),
        C(0.4193, 0.6270, "Central river pool"),
        C(0.4347, 0.4254, "North-central pool"),
        C(0.4459, 0.6185, "Captain Oathmyt river bend"),
        C(0.4588, 0.3539, "Northern Hallowfall pool"),
        C(0.6361, 0.4746, "Eastern route pool"),
        C(0.6396, 0.5012, "Eastern route return"),
        C(0.6463, 0.4718, "East Blood in the Water"),
        C(0.6607, 0.4602, "East river pool"),
        C(0.6654, 0.4675, "East route bend"),
        C(0.6688, 0.4288, "Northeast pool"),
        C(0.6726, 0.4197, "Northeast return"),
        C(0.6946, 0.4148, "Far northeast pool"),
    },
    confidence = "high",
}

local ANGLERSEEKER_ROUTE = {
    id = "tww-fishing-anglerseeker-torrent-route",
    source = "Wowhead Anglerseeker Torrent comments, The Derby Dash comments, and Fishing overview",
    sourceUrls = {
        FISHING_OVERVIEW,
        "https://www.wowhead.com/object=451675/anglerseeker-torrent",
        "https://www.wowhead.com/achievement=40539/the-derby-dash",
    },
    mapName = "The Ringing Deeps / Hallowfall",
    location = "Anglerseeker Torrent checks in The Ringing Deeps and Hallowfall",
    routeType = "targeted-fishing-pool-check",
    density = "Localized",
    dropDifficulty = "Targeted pool hunt. Clear nearby pools if Anglerseeker Torrent is not visible.",
    tips = {
        "Anglerseeker Torrent is the practical pool for Roaring Anglerseeker.",
        "It can also produce Spiked Sea Raven and Awoken Coelacanth according to the fishing overview.",
        "Use pool tracking from the Angler's Fishing Guide while flying between checks.",
    },
    coords = {
        C(0.5197, 0.5872, "Ringing Deeps Anglerseeker Torrent report"),
        C(0.4002, 0.2145, "Hallowfall Anglerseeker Torrent report"),
        C(0.4100, 0.4080, "Ringing Deeps route extension"),
    },
    confidence = "medium",
}

local ROYAL_RIPPLE_ROUTE = {
    id = "tww-fishing-royal-ripple-hallowfall-azj-kahet-route",
    source = "Wowhead Royal Ripple and Queen's Lurefish comments, plus Fishing overview",
    sourceUrls = {
        FISHING_OVERVIEW,
        "https://www.wowhead.com/object=451680/royal-ripple",
        "https://www.wowhead.com/item=220151/queens-lurefish",
    },
    mapName = "Hallowfall / Azj-Kahet",
    location = "Royal Ripple checks and open-water fallback after Regal Dottyback",
    routeType = "rare-fishing-pool-check",
    density = "Low",
    dropDifficulty = "Rare pool target. Fish out other pools in a compact area to rotate a Royal Ripple spawn.",
    tips = {
        "Use this for Regal Dottyback and Queen's Lurefish.",
        "Throw Regal Dottyback back into the water before targeting Queen's Lurefish.",
        "Some comments report success from open water with Royal Chum, but the route keeps Royal Ripple pins first.",
    },
    coords = {
        C(0.4313, 0.4408, "Hallowfall Royal Ripple rock pool"),
        C(0.3700, 0.7200, "Hallowfall small-puddle report"),
        C(0.3900, 0.6200, "Hallowfall open-water fallback report"),
        C(0.5544, 0.6868, "Azj-Kahet river-meet Royal Ripple"),
        C(0.4089, 0.5918, "Azj-Kahet Royal Ripple report"),
        C(0.3590, 0.5231, "Azj-Kahet Royal Ripple west"),
        C(0.2492, 0.3049, "Azj-Kahet Royal Ripple north"),
    },
    confidence = "medium",
}

local SLUM_SHARK_SWARM_ROUTE = {
    id = "tww-fishing-azj-kahet-slum-shark-swarm-route",
    source = "Wowhead Swarm of Slum Sharks object page, Kaheti Slum Shark comments, and Fishing overview",
    sourceUrls = {
        FISHING_OVERVIEW,
        "https://www.wowhead.com/object=451681/swarm-of-slum-sharks",
        "https://www.wowhead.com/item=220147/kaheti-slum-shark",
    },
    mapName = "Azj-Kahet",
    location = "Azj-Kahet river and lower-water checks where Swarm of Slum Sharks can replace other pools",
    routeType = "targeted-fishing-pool-check",
    density = "Low to medium",
    dropDifficulty = "Targeted pool hunt. Clear nearby pools if no Swarm of Slum Sharks is visible.",
    tips = {
        "Use this as the Azj-Kahet half of Kaheti Slum Shark farming after checking Hallowfall Blood pools.",
        "Pool types rotate, so compact river loops beat long open-water casts.",
        "Fishing perception bonuses help when targeting rarer pool fish.",
    },
    coords = {
        C(0.5544, 0.6868, "Azj-Kahet river-meet pool check"),
        C(0.4089, 0.5918, "Central Azj-Kahet pool check"),
        C(0.3590, 0.5231, "Western Azj-Kahet pool check"),
        C(0.2492, 0.3049, "Northern Azj-Kahet pool check"),
    },
    confidence = "medium",
}

local AZJ_KAHET_RARE_WATER_ROUTE = {
    id = "tww-fishing-azj-kahet-rare-water-route",
    source = "Wowhead Awoken Coelacanth, Pale Huskfish, Royal Ripple, and The Derby Dash comments",
    sourceUrls = {
        FISHING_OVERVIEW,
        "https://www.wowhead.com/item=220153/awoken-coelacanth",
        "https://www.wowhead.com/item=220148/pale-huskfish",
        "https://www.wowhead.com/achievement=40539/the-derby-dash",
        "https://www.method.gg/guides/tak-rethan-abyss-delve-guide",
    },
    mapName = "Azj-Kahet / City of Threads",
    location = "Tak-Rethan Abyss entrance water and nearby rare-pool checks",
    routeType = "rare-open-water-and-pool-check",
    density = "Low",
    dropDifficulty = "Rare fish targeting. Awoken Coelacanth needs Whispering Stargazer bait and enough Khaz Algar Fishing skill.",
    tips = {
        "Throw 10 Whispering Stargazer into Azj-Kahet water before fishing for Awoken Coelacanth.",
        "Wowhead comments place the useful water near the Explorer's League rope outside Tak-Rethan Abyss.",
        "Pale Huskfish is best treated as an Azj-Kahet rare-pool target while rotating Infused Ichor Spill and other pools.",
    },
    coords = {
        C(0.5750, 0.7750, "Explorer's League rope water under Tak-Rethan bridge"),
        C(0.5800, 0.6800, "Large pond open-water report"),
        C(0.5544, 0.6868, "Azj-Kahet river-meet rare pool"),
        C(0.6772, 0.2429, "City of Threads Tak-Rethan Abyss map pin"),
    },
    confidence = "medium",
}

local function RegisterFish(itemID, itemName, summary, spots)
    Register({
        itemID = itemID,
        itemName = itemName,
        expansion = "warWithin",
        professions = { "fishing", "cooking" },
        category = "Fish",
        sourceUrls = {
            ItemUrl(itemID),
            FISHING_OVERVIEW,
            FISHING_LEVELING,
        },
        summary = summary,
        spots = spots,
    })
end

RegisterFish(220134, "Dilly-Dally Dace",
    "Common Khaz Algar fish from Calm Surfacing Ripple, Blood in the Water, and Festering Rotpool.",
    { ISLE_DORN_POOL_ROUTE, HALLOWFALL_BLOOD_ROUTE })
RegisterFish(220135, "Bloody Perch",
    "Common Khaz Algar fish from Blood in the Water, Bloody Perch Swarm, Calm Surfacing Ripple, and related pools.",
    { HALLOWFALL_BLOOD_ROUTE, ISLE_DORN_POOL_ROUTE })
RegisterFish(220136, "Crystalline Sturgeon",
    "Common Khaz Algar fish from Glimmerpool in Isle of Dorn and The Ringing Deeps.",
    { ISLE_DORN_POOL_ROUTE })
RegisterFish(220137, "Bismuth Bitterling",
    "Common Khaz Algar fish from Glimmerpool in Isle of Dorn and The Ringing Deeps.",
    { ISLE_DORN_POOL_ROUTE })
RegisterFish(220138, "Nibbling Minnow",
    "Uncommon Khaz Algar fish from Calm Surfacing Ripple across Khaz Algar.",
    { ISLE_DORN_POOL_ROUTE })
RegisterFish(220139, "Whispering Stargazer",
    "Uncommon Khaz Algar fish from Stargazer Swarm, especially Isle of Dorn coasts; also bait for Awoken Coelacanth.",
    { ISLE_DORN_POOL_ROUTE })
RegisterFish(220141, "Specular Rainbowfish",
    "Uncommon Khaz Algar fish from Glimmerpool in Isle of Dorn and The Ringing Deeps.",
    { ISLE_DORN_POOL_ROUTE })
RegisterFish(220142, "Quiet River Bass",
    "Uncommon Khaz Algar fish from Calm Surfacing Ripple and River Bass Pool in Isle of Dorn and The Ringing Deeps.",
    { ISLE_DORN_POOL_ROUTE })
RegisterFish(220143, "Dornish Pike",
    "Common Khaz Algar fish from Calm Surfacing Ripple; comments support The Proscenium and Isle of Dorn pool loops.",
    { ISLE_DORN_POOL_ROUTE })
RegisterFish(220144, "Roaring Anglerseeker",
    "Uncommon Khaz Algar fish from Anglerseeker Torrent.",
    { ANGLERSEEKER_ROUTE })
RegisterFish(220145, "Arathor Hammerfish",
    "Uncommon Hallowfall fish from Blood in the Water pools.",
    { HALLOWFALL_BLOOD_ROUTE })
RegisterFish(220146, "Regal Dottyback",
    "Rare Khaz Algar fish from Royal Ripple in Hallowfall and Azj-Kahet.",
    { ROYAL_RIPPLE_ROUTE })
RegisterFish(220147, "Kaheti Slum Shark",
    "Uncommon Khaz Algar fish from Blood in the Water and Swarm of Slum Sharks in Hallowfall or Azj-Kahet.",
    { HALLOWFALL_BLOOD_ROUTE, SLUM_SHARK_SWARM_ROUTE })
RegisterFish(220148, "Pale Huskfish",
    "Uncommon rare-pool fish associated with Azj-Kahet and Infused Ichor Spill/Festering Rotpool checks.",
    { AZJ_KAHET_RARE_WATER_ROUTE })
RegisterFish(220149, "Sanguine Dogfish",
    "Rare Khaz Algar fish from Blood in the Water and Bloody Perch Swarm; Bloody Chum improves targeting.",
    { HALLOWFALL_BLOOD_ROUTE })
RegisterFish(220150, "Spiked Sea Raven",
    "Rare Khaz Algar fish from Stargazer Swarm, Glimmerpool, Calm Surfacing Ripple, and Anglerseeker Torrent.",
    { ISLE_DORN_POOL_ROUTE, ANGLERSEEKER_ROUTE })
RegisterFish(220151, "Queen's Lurefish",
    "Rare Khaz Algar fish from Royal Ripple after using Regal Dottyback/Royal Chum.",
    { ROYAL_RIPPLE_ROUTE })
RegisterFish(220152, "Cursed Ghoulfish",
    "Rare disruptive Khaz Algar fish from fishing above your skill level and from many pools, especially Blood in the Water.",
    { HALLOWFALL_BLOOD_ROUTE, AZJ_KAHET_RARE_WATER_ROUTE })
RegisterFish(220153, "Awoken Coelacanth",
    "Rare Azj-Kahet fish attracted by throwing Whispering Stargazer into the water.",
    { AZJ_KAHET_RARE_WATER_ROUTE, ANGLERSEEKER_ROUTE })
RegisterFish(222533, "Goldengill Trout",
    "Uncommon Khaz Algar fish from Glimmerpool, Festering Rotpool, and Infused Ichor Spill.",
    { ISLE_DORN_POOL_ROUTE, AZJ_KAHET_RARE_WATER_ROUTE })
