local _, NS = ...
local Register = NS.RegisterMaterialFarmingSpot
local Pins = NS.GetBurningCrusadeNpcCoords
local ObjectPins = NS.GetBurningCrusadeObjectCoords

local function C(x, y, label)
    return { x = x, y = y, label = label }
end

local function MobSpot(id, mapName, location, npcIDs, tips, density)
    local sourceUrls = {}
    for _, npcID in ipairs(npcIDs) do
        sourceUrls[#sourceUrls + 1] = "https://www.wowhead.com/npc=" .. npcID
    end

    return {
        id = id,
        source = "Retail Wowhead NPC spawn map",
        sourceUrls = sourceUrls,
        mapName = mapName,
        location = location,
        routeType = "mob-density-route",
        density = density or "Dense camp",
        dropDifficulty = "World-drop chance varies by creature; clear the complete marked population.",
        tips = tips,
        coords = Pins(npcIDs, ({
            ["Zangarmarsh"] = 102,
            ["Nagrand"] = 107,
            ["Terokkar Forest"] = 108,
            ["Shadowmoon Valley"] = 104,
            ["Netherstorm"] = 109,
        })[mapName]),
        confidence = "high",
    }
end

local function EntranceSpot(id, mapName, location, x, y, sourceUrl)
    return {
        id = id,
        source = "Retail Wowhead instance and item-source pages",
        sourceUrls = { sourceUrl },
        mapName = mapName,
        location = location,
        routeType = "instance-entrance",
        density = "Instanced source",
        dropDifficulty = "The source mobs are inside the instance; the outdoor pin marks its entrance.",
        tips = {
            "Reset and lockout rules determine repeatability.",
            "The overlay cannot project instance-interior coordinates onto the outdoor zone map.",
        },
        coords = { C(x, y, location .. " entrance") },
        confidence = "high",
    }
end

local function JaggalSpots()
    return {
        MobSpot("jaggal-clam-bloodscale", "Zangarmarsh", "Bloodscale Enclave and Bloodscale Grounds", { 18088, 18089, 20088, 20089 }, {
            "Kill every Bloodscale naga along both western and eastern populations.",
            "Nearby pins are intentionally preserved as separate spawn records.",
        }),
        MobSpot("jaggal-clam-darkcrest", "Zangarmarsh", "Darkcrest Shore and Darkcrest Enclave", { 18086, 18087, 19946, 19947 }, {
            "Sweep both Darkcrest populations around the southeastern lakes.",
        }),
        MobSpot("jaggal-clam-bogstrok", "Zangarmarsh", "Western bogstrok and southern marsh populations", { 20293, 20294, 20295, 18136, 18137 }, {
            "Include the far-southern Marsh Lurker and Marsh Dredger pins.",
        }, "Scattered populations"),
        MobSpot("jaggal-clam-hydra", "Zangarmarsh", "Mire Hydra, Parched Hydra, and Fenclaw Thrasher populations", { 18213, 20324, 18214 }, {
            "The hydra route covers central, eastern, and northeastern Zangarmarsh.",
        }, "Broad zone route"),
        EntranceSpot("jaggal-clam-slave-pens", "Zangarmarsh", "The Slave Pens, Coilfang Reservoir", 0.503, 0.409, "https://www.wowhead.com/zone=3717/the-slave-pens"),
        EntranceSpot("jaggal-clam-underbog", "Zangarmarsh", "The Underbog, Coilfang Reservoir", 0.505, 0.405, "https://www.wowhead.com/zone=3716/the-underbog"),
        EntranceSpot("jaggal-clam-steamvault", "Zangarmarsh", "The Steamvault, Coilfang Reservoir", 0.507, 0.401, "https://www.wowhead.com/zone=3715/the-steamvault"),
    }
end

local function RegisterClamResult(itemID, itemName, category, professions, summary)
    Register({
        itemID = itemID,
        itemName = itemName,
        expansion = "burningCrusade",
        professions = professions,
        category = category,
        researchStatus = "researched",
        sourceUrls = {
            "https://www.wowhead.com/item=" .. itemID,
            "https://www.wowhead.com/item=24476/jaggal-clam",
            "https://warcraft.wiki.gg/wiki/Clam",
        },
        summary = summary,
        spots = JaggalSpots(),
    })
end

RegisterClamResult(24476, "Jaggal Clam", "Openable", { "miscellaneous" }, "Jaggal Clam is an openable Outland drop. It contains Jaggal Clam Meat and can contain Jaggal Pearl or the rarer Shadow Pearl, so every clam source is relevant even when the shell itself has little auction value.")
RegisterClamResult(24477, "Jaggal Clam Meat", "Meat", { "cooking", "miscellaneous" }, "Jaggal Clam Meat is obtained by opening Jaggal Clams. The pins therefore represent clam-dropping creatures and Coilfang instances, not direct meat drops.")
RegisterClamResult(24478, "Jaggal Pearl", "Pearl", { "jewelcrafting", "miscellaneous" }, "Jaggal Pearl can appear when a Jaggal Clam is opened. Farm and open the clams from the marked outdoor populations or Coilfang instances.")
RegisterClamResult(24479, "Shadow Pearl", "Pearl", { "jewelcrafting", "miscellaneous" }, "Shadow Pearl is the rarer pearl outcome from opening Jaggal Clams. The complete clam-source routes are retained because there is no separate pearl-spawn location.")

local OLEMBA_SOURCE_URLS = {
    "https://www.wowhead.com/item=242691/olemba-lumber",
    "https://www.wowhead.com/guide/player-housing/crafting-decor-items",
}

Register({
    itemID = 242691,
    itemName = "Olemba Lumber",
    expansion = "burningCrusade",
    professions = { "miscellaneous" },
    category = "Housing Lumber",
    researchStatus = "researched",
    sourceUrls = {
        "https://www.wowhead.com/item=242691/olemba-lumber",
        "https://www.wowhead.com/guide/player-housing/crafting-decor-items",
    },
    summary = "Olemba Lumber is the Outland-era housing lumber introduced with Player Housing. Lumber nodes are dynamic and Wowhead does not publish a fixed object-pin table, so these are separate full-zone route anchors rather than claimed static spawns.",
    spots = {
        {
            id = "olemba-lumber-zangarmarsh",
            source = "Retail Wowhead Olemba Lumber route reports",
            sourceUrls = OLEMBA_SOURCE_URLS,
            mapName = "Zangarmarsh",
            location = "Outer mushroom and tree line circuit",
            routeType = "dynamic-lumber-route",
            density = "High dynamic-node potential",
            dropDifficulty = "Requires the housing harvesting tutorial and a Harvesting Hatchet; nodes respawn dynamically.",
            tips = { "Follow the outer landmasses and tree lines instead of crossing open water.", "Treat the pins as route anchors, not guaranteed node spawns." },
            coords = { C(0.170, 0.360, "Northwest tree line"), C(0.285, 0.230, "Northern mushroom line"), C(0.435, 0.245, "North-central tree line"), C(0.615, 0.330, "Northeast tree line"), C(0.805, 0.455, "Eastern tree line"), C(0.745, 0.720, "Southeast tree line"), C(0.565, 0.805, "Southern tree line"), C(0.320, 0.760, "Southwest tree line"), C(0.145, 0.575, "Western tree line") },
            confidence = "medium",
        },
        {
            id = "olemba-lumber-nagrand",
            source = "Retail Wowhead Olemba Lumber route reports",
            sourceUrls = OLEMBA_SOURCE_URLS,
            mapName = "Nagrand",
            location = "Zone-wide tree and cliff circuit",
            routeType = "dynamic-lumber-route",
            density = "High dynamic-node potential",
            dropDifficulty = "Requires a Harvesting Hatchet; flying makes the broken terrain much faster.",
            tips = { "Circle the outer tree lines, then cross through the central wooded sections.", "Treat the pins as route anchors, not guaranteed node spawns." },
            coords = { C(0.190, 0.420, "Western tree line"), C(0.285, 0.235, "Northwest tree line"), C(0.455, 0.205, "Northern tree line"), C(0.640, 0.245, "Northeast tree line"), C(0.765, 0.390, "Eastern tree line"), C(0.715, 0.680, "Southeast tree line"), C(0.520, 0.790, "Southern tree line"), C(0.325, 0.700, "Southwest tree line"), C(0.455, 0.500, "Central tree line") },
            confidence = "medium",
        },
        {
            id = "olemba-lumber-terokkar",
            source = "Retail Wowhead Olemba Lumber route reports",
            sourceUrls = OLEMBA_SOURCE_URLS,
            mapName = "Terokkar Forest",
            location = "Terokkar forest perimeter",
            routeType = "dynamic-lumber-route",
            density = "High dynamic-node potential",
            dropDifficulty = "Requires a Harvesting Hatchet.",
            tips = { "Keep the main forest circuit separate from the Skettis circuit." },
            coords = { C(0.205, 0.350, "Northwest forest"), C(0.390, 0.205, "Northern forest"), C(0.555, 0.265, "Northeast forest"), C(0.720, 0.385, "Eastern forest"), C(0.685, 0.585, "Southeast forest"), C(0.480, 0.625, "Southern forest"), C(0.275, 0.570, "Southwest forest") },
            confidence = "medium",
        },
        {
            id = "olemba-lumber-skettis",
            source = "Retail Wowhead Olemba Lumber route reports",
            sourceUrls = OLEMBA_SOURCE_URLS,
            mapName = "Terokkar Forest",
            location = "Skettis tree circuit",
            routeType = "dynamic-lumber-route",
            density = "Compact dynamic-node route",
            dropDifficulty = "Requires a Harvesting Hatchet and flying access.",
            tips = { "Skettis remains a separate location even though it is close to the main Terokkar route." },
            coords = { C(0.590, 0.700, "Northwest Skettis"), C(0.640, 0.665, "North Skettis"), C(0.700, 0.735, "East Skettis"), C(0.660, 0.820, "South Skettis"), C(0.585, 0.790, "West Skettis") },
            confidence = "medium",
        },
        {
            id = "olemba-lumber-netherstorm-midrealm",
            source = "Retail Wowhead Olemba Lumber route reports",
            sourceUrls = OLEMBA_SOURCE_URLS,
            mapName = "Netherstorm",
            location = "Eco-Dome Midrealm",
            routeType = "dynamic-lumber-route",
            density = "Compact dynamic-node route",
            dropDifficulty = "Requires a Harvesting Hatchet.",
            tips = { "Stay inside the Eco-Dome vegetation boundary." },
            coords = { C(0.435, 0.495, "Northwest Midrealm"), C(0.470, 0.455, "North Midrealm"), C(0.515, 0.490, "East Midrealm"), C(0.505, 0.555, "Southeast Midrealm"), C(0.455, 0.565, "Southwest Midrealm") },
            confidence = "medium",
        },
        {
            id = "olemba-lumber-eversong",
            source = "Retail Wowhead Olemba Lumber source reports",
            sourceUrls = OLEMBA_SOURCE_URLS,
            mapName = "Eversong Woods",
            location = "Eversong wooded circuit",
            routeType = "dynamic-lumber-route",
            density = "Dynamic-node route",
            dropDifficulty = "Requires a Harvesting Hatchet.",
            tips = { "Sweep both sides of the central scar and all intact woodland." },
            coords = { C(0.245, 0.355, "West Eversong"), C(0.390, 0.240, "Northwest Eversong"), C(0.585, 0.250, "Northeast Eversong"), C(0.735, 0.420, "East Eversong"), C(0.645, 0.690, "Southeast Eversong"), C(0.350, 0.700, "Southwest Eversong") },
            confidence = "medium",
        },
        {
            id = "olemba-lumber-ghostlands",
            source = "Retail Wowhead Olemba Lumber source reports",
            sourceUrls = OLEMBA_SOURCE_URLS,
            mapName = "Ghostlands",
            location = "Ghostlands wooded circuit",
            routeType = "dynamic-lumber-route",
            density = "Dynamic-node route",
            dropDifficulty = "Requires a Harvesting Hatchet.",
            tips = { "Follow the surviving forest edges around the zone." },
            coords = { C(0.240, 0.300, "Northwest Ghostlands"), C(0.480, 0.235, "North Ghostlands"), C(0.700, 0.335, "Northeast Ghostlands"), C(0.755, 0.610, "Southeast Ghostlands"), C(0.520, 0.770, "South Ghostlands"), C(0.275, 0.640, "Southwest Ghostlands") },
            confidence = "medium",
        },
        {
            id = "olemba-lumber-azuremyst",
            source = "Retail Wowhead Olemba Lumber source reports",
            sourceUrls = OLEMBA_SOURCE_URLS,
            mapName = "Azuremyst Isle",
            location = "Azuremyst wooded circuit",
            routeType = "dynamic-lumber-route",
            density = "Dynamic-node route",
            dropDifficulty = "Requires a Harvesting Hatchet.",
            tips = { "Circle the island forests and the Exodar perimeter." },
            coords = { C(0.205, 0.430, "West Azuremyst"), C(0.350, 0.245, "Northwest Azuremyst"), C(0.585, 0.220, "North Azuremyst"), C(0.760, 0.405, "East Azuremyst"), C(0.620, 0.720, "Southeast Azuremyst"), C(0.330, 0.735, "Southwest Azuremyst") },
            confidence = "medium",
        },
        {
            id = "olemba-lumber-bloodmyst",
            source = "Retail Wowhead Olemba Lumber source reports",
            sourceUrls = OLEMBA_SOURCE_URLS,
            mapName = "Bloodmyst Isle",
            location = "Bloodmyst wooded circuit",
            routeType = "dynamic-lumber-route",
            density = "Dynamic-node route",
            dropDifficulty = "Requires a Harvesting Hatchet.",
            tips = { "Circle the island vegetation and avoid long barren crossings." },
            coords = { C(0.205, 0.375, "West Bloodmyst"), C(0.375, 0.205, "Northwest Bloodmyst"), C(0.610, 0.225, "Northeast Bloodmyst"), C(0.785, 0.455, "East Bloodmyst"), C(0.625, 0.735, "Southeast Bloodmyst"), C(0.335, 0.750, "Southwest Bloodmyst") },
            confidence = "medium",
        },
    },
})

local function RegisterInstanceMaterial(itemID, itemName, category, summary, spots)
    Register({
        itemID = itemID,
        itemName = itemName,
        expansion = "burningCrusade",
        professions = { "miscellaneous" },
        category = category,
        researchStatus = "researched",
        sourceUrls = { "https://www.wowhead.com/item=" .. itemID },
        summary = summary,
        spots = spots,
    })
end

RegisterInstanceMaterial(21882, "Soul Essence", "Reagent", "Soul Essence drops from undead and spectral creatures inside Karazhan. The outdoor pin marks the raid entrance because interior NPC coordinates cannot be drawn on the Deadwind Pass map.", {
    EntranceSpot("soul-essence-karazhan", "Deadwind Pass", "Karazhan", 0.470, 0.750, "https://www.wowhead.com/zone=3457/karazhan"),
})

RegisterInstanceMaterial(23572, "Primal Nether", "Dungeon Reagent", "Primal Nether is associated with final bosses in heroic Burning Crusade dungeons and later sources. Every distinct dungeon entrance is retained, including multiple portals within one complex.", {
    EntranceSpot("primal-nether-ramparts", "Hellfire Peninsula", "Hellfire Ramparts", 0.474, 0.532, "https://www.wowhead.com/zone=3562/hellfire-ramparts"),
    EntranceSpot("primal-nether-blood-furnace", "Hellfire Peninsula", "The Blood Furnace", 0.461, 0.515, "https://www.wowhead.com/zone=3713/the-blood-furnace"),
    EntranceSpot("primal-nether-shattered-halls", "Hellfire Peninsula", "The Shattered Halls", 0.475, 0.520, "https://www.wowhead.com/zone=3714/the-shattered-halls"),
    EntranceSpot("primal-nether-slave-pens", "Zangarmarsh", "The Slave Pens", 0.503, 0.409, "https://www.wowhead.com/zone=3717/the-slave-pens"),
    EntranceSpot("primal-nether-underbog", "Zangarmarsh", "The Underbog", 0.505, 0.405, "https://www.wowhead.com/zone=3716/the-underbog"),
    EntranceSpot("primal-nether-steamvault", "Zangarmarsh", "The Steamvault", 0.507, 0.401, "https://www.wowhead.com/zone=3715/the-steamvault"),
    EntranceSpot("primal-nether-mana-tombs", "Terokkar Forest", "Mana-Tombs", 0.399, 0.621, "https://www.wowhead.com/zone=3792/mana-tombs"),
    EntranceSpot("primal-nether-auchenai-crypts", "Terokkar Forest", "Auchenai Crypts", 0.369, 0.654, "https://www.wowhead.com/zone=3790/auchenai-crypts"),
    EntranceSpot("primal-nether-sethekk-halls", "Terokkar Forest", "Sethekk Halls", 0.443, 0.658, "https://www.wowhead.com/zone=3791/sethekk-halls"),
    EntranceSpot("primal-nether-shadow-labyrinth", "Terokkar Forest", "Shadow Labyrinth", 0.397, 0.716, "https://www.wowhead.com/zone=3789/shadow-labyrinth"),
    EntranceSpot("primal-nether-mechanar", "Netherstorm", "The Mechanar", 0.704, 0.698, "https://www.wowhead.com/zone=3849/the-mechanar"),
    EntranceSpot("primal-nether-botanica", "Netherstorm", "The Botanica", 0.715, 0.553, "https://www.wowhead.com/zone=3847/the-botanica"),
    EntranceSpot("primal-nether-arcatraz", "Netherstorm", "The Arcatraz", 0.743, 0.573, "https://www.wowhead.com/zone=3848/the-arcatraz"),
    EntranceSpot("primal-nether-black-morass", "Tanaris", "The Black Morass via Caverns of Time", 0.646, 0.501, "https://www.wowhead.com/zone=2366/the-black-morass"),
    EntranceSpot("primal-nether-magisters-terrace", "Isle of Quel'Danas", "Magisters' Terrace", 0.613, 0.306, "https://www.wowhead.com/zone=4131/magisters-terrace"),
})

RegisterInstanceMaterial(30183, "Nether Vortex", "Raid Reagent", "Nether Vortex is a Tier 5 raid material. Serpentshrine Cavern and Tempest Keep are kept as separate farm locations.", {
    EntranceSpot("nether-vortex-serpentshrine", "Zangarmarsh", "Serpentshrine Cavern", 0.504, 0.409, "https://www.wowhead.com/zone=3607/serpentshrine-cavern"),
    EntranceSpot("nether-vortex-tempest-keep", "Netherstorm", "Tempest Keep", 0.738, 0.638, "https://www.wowhead.com/zone=3845/tempest-keep"),
})

RegisterInstanceMaterial(32428, "Heart of Darkness", "Raid Reagent", "Heart of Darkness drops in Black Temple and the Battle for Mount Hyjal. Both raid entrances are retained as independent locations.", {
    EntranceSpot("heart-darkness-black-temple", "Shadowmoon Valley", "Black Temple", 0.710, 0.460, "https://www.wowhead.com/zone=3959/black-temple"),
    EntranceSpot("heart-darkness-hyjal", "Tanaris", "Battle for Mount Hyjal via Caverns of Time", 0.646, 0.501, "https://www.wowhead.com/zone=3606/the-battle-for-mount-hyjal"),
})

RegisterInstanceMaterial(34664, "Sunmote", "Raid Reagent", "Sunmote is a Sunwell Plateau raid material. Its outdoor overlay location is the Sunwell Plateau entrance.", {
    EntranceSpot("sunmote-sunwell", "Isle of Quel'Danas", "Sunwell Plateau", 0.442, 0.455, "https://www.wowhead.com/zone=4075/sunwell-plateau"),
})

local function RegisterReputationItem(itemID, itemName, summary, spots)
    Register({
        itemID = itemID,
        itemName = itemName,
        expansion = "burningCrusade",
        professions = { "miscellaneous" },
        category = "Reputation",
        researchStatus = "researched",
        sourceUrls = { "https://www.wowhead.com/item=" .. itemID },
        summary = summary,
        spots = spots,
    })
end

RegisterReputationItem(24368, "Coilfang Armaments", "Coilfang Armaments are Cenarion Expedition turn-ins from Coilfang Reservoir dungeons and raid creatures.", {
    EntranceSpot("coilfang-armaments-slave-pens", "Zangarmarsh", "The Slave Pens", 0.503, 0.409, "https://www.wowhead.com/zone=3717/the-slave-pens"),
    EntranceSpot("coilfang-armaments-underbog", "Zangarmarsh", "The Underbog", 0.505, 0.405, "https://www.wowhead.com/zone=3716/the-underbog"),
    EntranceSpot("coilfang-armaments-steamvault", "Zangarmarsh", "The Steamvault", 0.507, 0.401, "https://www.wowhead.com/zone=3715/the-steamvault"),
    EntranceSpot("coilfang-armaments-serpentshrine", "Zangarmarsh", "Serpentshrine Cavern", 0.504, 0.409, "https://www.wowhead.com/zone=3607/serpentshrine-cavern"),
})

RegisterReputationItem(24401, "Unidentified Plant Parts", "Unidentified Plant Parts are Cenarion Expedition turn-ins farmed from Zangarmarsh plant creatures. All published Bog Lord and sporebat locations are retained.", {
    MobSpot("plant-parts-bog-lords", "Zangarmarsh", "Bog Lord populations", { 18127 }, { "Clear every Bog Lord along the marked marsh paths." }),
    MobSpot("plant-parts-sporebats", "Zangarmarsh", "Sporebat and Greater Sporebat populations", { 18128, 18129 }, { "Use the broad flying loop to cover both sporebat populations." }, "Broad zone population"),
})

RegisterReputationItem(25433, "Obsidian Warbeads", "Obsidian Warbeads are reputation turn-ins dropped by Nagrand ogres. Boulderfist and Warmaul populations remain separate routes.", {
    MobSpot("warbeads-boulderfist", "Nagrand", "Boulderfist ogre camps", { 17136, 17137 }, { "Clear warriors and mages throughout every marked Boulderfist camp." }),
    MobSpot("warbeads-warmaul", "Nagrand", "Warmaul Hill", { 17138, 18064 }, { "Loop the upper and lower Warmaul populations." }),
})

RegisterReputationItem(25719, "Arakkoa Feather", "Arakkoa Feathers are Lower City turn-ins dropped by outdoor arakkoa in Terokkar Forest. Shienor, Skithian, and Shalassi populations are kept separately.", {
    MobSpot("arakkoa-feather-shienor", "Terokkar Forest", "Shienor camps", { 18449, 18450, 18451 }, { "Clear every Shienor arakkoa in both camps." }),
    MobSpot("arakkoa-feather-skithian", "Terokkar Forest", "Skithian camp", { 18452, 18453 }, { "Clear Dreadhawks and Windrippers around the complete camp." }),
    MobSpot("arakkoa-feather-shalassi", "Terokkar Forest", "Shalassi camp", { 18454, 18455 }, { "Clear Talonguards and Oracles around the marked ruins." }),
})

RegisterReputationItem(25744, "Dampscale Basilisk Eye", "Dampscale Basilisk Eyes are Sha'tari Skyguard turn-ins from Terokkar basilisks. Every published basilisk spawn used by the route is retained.", {
    MobSpot("dampscale-eyes-terokkar", "Terokkar Forest", "Terokkar basilisk populations", { 18461, 18463, 18648 }, { "Clear each separate basilisk population; this route overlaps Chunk o' Basilisk and skinning materials." }, "Several dense pockets"),
})

RegisterReputationItem(25802, "Dreadfang Venom Sac", "Dreadfang Venom Sacs are Sha'tari Skyguard turn-ins from Dreadfang spiders in Terokkar Forest.", {
    MobSpot("dreadfang-sac-terokkar", "Terokkar Forest", "Dreadfang Widow and Dreadfang Lurker populations", { 18466, 18467 }, { "Sweep the full Bone Wastes spider population." }),
})

RegisterReputationItem(29425, "Mark of Kil'jaeden", "Marks of Kil'jaeden are early Aldor turn-ins. The Kil'sorrow camp route includes every published Spellbinder, Cultist, and Deathsworn pin.", {
    MobSpot("mark-kiljaeden-kilsorrow", "Nagrand", "Kil'sorrow Fortress", { 17146, 17147, 17148 }, { "Clear every level of the fortress and the outer patrols." }),
})

RegisterReputationItem(29426, "Firewing Signet", "Firewing Signets are early Scryers turn-ins from Firewing Point. Every published Bloodwarder, Defender, and Warlock pin is retained.", {
    MobSpot("firewing-signet-firewing", "Terokkar Forest", "Firewing Point", { 1410, 5355, 16769 }, { "Clear the entire point, including tightly grouped nearby spawns." }),
})

RegisterReputationItem(29460, "Ethereum Prison Key", "Ethereum Prison Keys are Consortium-related drops from Ethereum creatures in Netherstorm. All published spawns for six outdoor Ethereum populations are retained.", {
    MobSpot("ethereum-key-netherstorm", "Netherstorm", "Ethereum camps", { 20452, 20453, 20456, 20458, 20459, 20474 }, { "Sweep all Ethereum camps instead of restricting the route to one preferred pocket." }, "Multiple camps"),
})

local highAldorSpots = {
    MobSpot("aldor-high-shadowmoon", "Shadowmoon Valley", "Legion Hold and Shadowmoon demon populations", { 19740 }, { "Clear the complete Wrathwalker population." }),
    MobSpot("aldor-high-netherstorm", "Netherstorm", "Forge Base and Artifact Seeker populations", { 16943, 16944, 19852 }, { "Clear both Forge Base demons and the Artifact Seeker population." }, "Multiple camps"),
}

RegisterReputationItem(29740, "Fel Armament", "Fel Armaments are high-level Aldor turn-ins from Outland demons. Shadowmoon Valley and Netherstorm demon populations are independent routes.", highAldorSpots)
RegisterReputationItem(30809, "Mark of Sargeras", "Marks of Sargeras are high-level Aldor turn-ins from Outland demons. The same complete high-level demon routes used for Fel Armaments are retained.", {
    MobSpot("mark-sargeras-shadowmoon", "Shadowmoon Valley", "Legion Hold and Shadowmoon demon populations", { 19740 }, { "Clear the complete Wrathwalker population." }),
    MobSpot("mark-sargeras-netherstorm", "Netherstorm", "Forge Base and Artifact Seeker populations", { 16943, 16944, 19852 }, { "Clear both Forge Base demons and the Artifact Seeker population." }, "Multiple camps"),
})

RegisterReputationItem(29739, "Arcane Tome", "Arcane Tomes are high-level Scryers turn-ins from Sunfury blood elves in Netherstorm.", {
    MobSpot("arcane-tome-sunfury", "Netherstorm", "Sunfury camps", { 20134, 20136, 18855, 18853 }, { "Clear every marked Arcanist, Researcher, Magister, and Bloodwarder spawn." }, "Multiple camps"),
})

RegisterReputationItem(30810, "Sunfury Signet", "Sunfury Signets are high-level Scryers turn-ins from Sunfury blood elves in Netherstorm.", {
    MobSpot("sunfury-signet-netherstorm", "Netherstorm", "Sunfury camps", { 20134, 20136, 18855, 18853 }, { "Clear every marked Arcanist, Researcher, Magister, and Bloodwarder spawn." }, "Multiple camps"),
})

RegisterReputationItem(24245, "Glowcap", "Glowcaps are a tradeable Sporeggar currency gathered from fixed objects throughout Zangarmarsh. Every currently published object pin is retained.", {
    {
        id = "glowcap-zangarmarsh-objects",
        source = "Complete Retail Wowhead object map-pin set",
        sourceUrls = {
            "https://www.wowhead.com/item=24245/glowcap",
            "https://www.wowhead.com/object=182053/glowcap",
        },
        mapName = "Zangarmarsh",
        location = "Glowcap objects across Zangarmarsh",
        routeType = "gatherable-object-route",
        density = "Scattered fixed-object population",
        dropDifficulty = "Ground objects can be collected without a gathering profession.",
        tips = { "Follow every object pin; do not collapse the close pairs around mushroom settlements." },
        coords = ObjectPins(182053, 102),
        confidence = "high",
    },
})

RegisterReputationItem(24246, "Sanguine Hibiscus", "Sanguine Hibiscus is a tradeable Sporeggar turn-in found inside The Underbog. The outdoor pin marks the dungeon entrance because interior spawn points cannot be projected onto Zangarmarsh.", {
    EntranceSpot("sanguine-hibiscus-underbog", "Zangarmarsh", "The Underbog", 0.505, 0.405, "https://www.wowhead.com/zone=3716/the-underbog"),
})

RegisterReputationItem(24291, "Bog Lord Tendril", "Bog Lord Tendrils are tradeable Sporeggar turn-ins from Zangarmarsh fungal giants and related marsh creatures. Each creature population remains available as its own sweep.", {
    MobSpot("bog-lord-tendril-giants", "Zangarmarsh", "Bog Lord, fungal giant, and withered giant populations", { 19734, 19519, 18127, 18124, 19402, 18125 }, { "Clear every giant population around the western and central marsh." }, "Multiple populations"),
    MobSpot("bog-lord-tendril-hydra", "Zangarmarsh", "Parched Hydra population", { 20324 }, { "Keep the northeastern hydra population as a separate sweep." }),
    MobSpot("bog-lord-tendril-sporebat", "Zangarmarsh", "Greater Sporebat population", { 18129 }, { "Use the complete airborne Greater Sporebat route." }, "Broad flying population"),
})

RegisterReputationItem(24449, "Fertile Spores", "Fertile Spores are tradeable Sporeggar turn-ins from sporebats and many Zangarmarsh marsh creatures. All published pins for the principal outdoor sources are retained.", {
    MobSpot("fertile-spores-sporebats", "Zangarmarsh", "Sporebat populations", { 18128, 18129, 20387, 18280, 18281 }, { "Fly the full zone circuit to cover ordinary, greater, young, and named sporebats." }, "Broad flying population"),
    MobSpot("fertile-spores-marshfang", "Zangarmarsh", "Marshfang populations", { 18130, 18131, 20196 }, { "Clear both Marshfang species and the Bloodthirsty population." }, "Multiple populations"),
    MobSpot("fertile-spores-stingers", "Zangarmarsh", "Ironspine Gazer and Umbraglow Stinger populations", { 19730, 18132 }, { "Retain both separate stingray populations." }),
    MobSpot("fertile-spores-walkers", "Zangarmarsh", "Marsh Walker and withered giant populations", { 18135, 18124, 18125 }, { "Clear the complete giant and walker populations." }, "Multiple populations"),
})

RegisterReputationItem(25416, "Oshu'gun Crystal Fragment", "Oshu'gun Crystal Fragments are tradeable Consortium turn-ins. They drop from Vir'aani mobs and can be gathered directly from crystal-fragment objects around Oshu'gun.", {
    MobSpot("oshugun-fragment-viraani", "Nagrand", "Vir'aani camps around Oshu'gun", { 17149, 17150 }, { "Clear every Raider and Arcanist pin around the crystal." }),
    {
        id = "oshugun-fragment-objects",
        source = "Complete Retail Wowhead object map-pin set",
        sourceUrls = {
            "https://www.wowhead.com/item=25416/oshugun-crystal-fragment",
            "https://www.wowhead.com/object=182258/oshugun-crystal-fragment",
        },
        mapName = "Nagrand",
        location = "Oshu'gun crystal-fragment objects",
        routeType = "gatherable-object-route",
        density = "Compact object population",
        dropDifficulty = "Ground objects can be collected without a gathering profession.",
        tips = { "Combine the object circuit with the Vir'aani mob route." },
        coords = ObjectPins(182258, 107),
        confidence = "high",
    },
})

RegisterReputationItem(25463, "Pair of Ivory Tusks", "Pairs of Ivory Tusks are tradeable early Consortium turn-ins from Nagrand wildlife and elementals. The route includes every published pin for the principal current sources.", {
    MobSpot("ivory-tusks-talbuk-clefthoof", "Nagrand", "Talbuk and clefthoof populations", { 17130, 17131, 17132, 17133, 18205 }, { "Cover both talbuk and clefthoof populations across the grasslands." }, "Broad zone population"),
    MobSpot("ivory-tusks-windroc", "Nagrand", "Windroc populations", { 17128, 17129, 18220 }, { "Cover ordinary, greater, and ravenous windroc populations." }, "Broad flying population"),
    MobSpot("ivory-tusks-elementals", "Nagrand", "Nagrand elemental populations", { 17156, 17158, 17159, 17160 }, { "Keep the earth, dust, storm, and cyclone populations in the route." }, "Multiple populations"),
})

local skettisTurnInNPCs = { 21804, 21650, 21649, 21644, 21911, 21763, 21651 }

RegisterReputationItem(32388, "Shadow Dust", "Shadow Dust is a tradeable Sha'tari Skyguard turn-in from Skettis arakkoa. Every published pin for the principal Skettis and Time-Lost populations is retained.", {
    MobSpot("shadow-dust-skettis", "Terokkar Forest", "Skettis and Time-Lost arakkoa populations", skettisTurnInNPCs, { "Clear the complete Skettis plateau rather than only one preferred camp." }, "Dense plateau route"),
})

RegisterReputationItem(32620, "Time-Lost Scroll", "Time-Lost Scrolls are tradeable Sha'tari Skyguard items from Skettis and Time-Lost creatures. The full published Skettis route is retained.", {
    MobSpot("time-lost-scroll-skettis", "Terokkar Forest", "Skettis and Time-Lost arakkoa populations", skettisTurnInNPCs, { "Clear the complete Skettis plateau and retain every close spawn pin." }, "Dense plateau route"),
})

RegisterReputationItem(32897, "Mark of the Illidari", "Marks of the Illidari are tradeable raid-era turn-ins from Burning Crusade raid creatures. Each relevant raid entrance remains a separate overlay destination.", {
    EntranceSpot("illidari-mark-serpentshrine", "Zangarmarsh", "Serpentshrine Cavern", 0.504, 0.409, "https://www.wowhead.com/zone=3607/serpentshrine-cavern"),
    EntranceSpot("illidari-mark-tempest-keep", "Netherstorm", "Tempest Keep", 0.738, 0.638, "https://www.wowhead.com/zone=3845/tempest-keep"),
    EntranceSpot("illidari-mark-hyjal", "Tanaris", "Battle for Mount Hyjal via Caverns of Time", 0.646, 0.501, "https://www.wowhead.com/zone=3606/the-battle-for-mount-hyjal"),
    EntranceSpot("illidari-mark-black-temple", "Shadowmoon Valley", "Black Temple", 0.710, 0.460, "https://www.wowhead.com/zone=3959/black-temple"),
})
