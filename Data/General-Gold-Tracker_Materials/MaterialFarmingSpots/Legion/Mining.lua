local _, NS = ...
local Register = NS.RegisterMaterialFarmingSpot

local function C(x, y, label)
    return { x = x, y = y, label = label }
end

local function ItemUrl(itemID)
    return "https://www.wowhead.com/item=" .. tostring(itemID)
end

local VALSHARAH_ORE_ROUTE = {
    id = "legion-ore-valsharah-low-vertical-loop",
    source = "wow-professions Leystone/Felslate guides and Wowhead Legion Mining guide",
    sourceUrls = {
        "https://www.wow-professions.com/farming/leystone-ore-farming",
        "https://www.wow-professions.com/farming/felslate-farming",
        "https://www.wowhead.com/guide/legion-mining",
    },
    mapName = "Val'sharah",
    location = "Val'sharah low-vertical ore loop through roads, rivers, and cave mouths",
    routeType = "mining-loop",
    density = "Medium",
    dropDifficulty = "Good general Leystone route with occasional Felslate; easier terrain than Highmountain.",
    tips = {
        "Use Val'sharah as the relaxed node loop because the guide calls out its flatter route.",
        "Mine every Leystone node because Felslate is a rarer replacement spawn.",
        "Use Demonsteel Stirrups or Sky Golem-style mounted gathering support when available.",
    },
    coords = {
        C(0.442, 0.332, "Northern road node checks"),
        C(0.548, 0.364, "Temple road ridge"),
        C(0.620, 0.446, "Eastern river bend"),
        C(0.592, 0.584, "Southern road cut"),
        C(0.466, 0.638, "Western return"),
        C(0.354, 0.514, "Black Rook foothills"),
    },
    confidence = "high",
}

local SURAMAR_ORE_ROUTE = {
    id = "legion-ore-suramar-max-level-seam-loop",
    source = "wow-professions Felslate guide, Wowhead Legion Mining comments, and Artisans of Azeroth retail Suramar route string",
    sourceUrls = {
        "https://www.wow-professions.com/farming/felslate-farming",
        "https://www.wowhead.com/guide/legion-mining",
        "https://artisansofazeroth.com/legion-mining-leveling/",
    },
    mapName = "Suramar",
    location = "Suramar ridge, river, and cave seam checks",
    routeType = "mining-loop",
    density = "Medium",
    dropDifficulty = "Better Felslate chance than casual routes, but max-level Suramar mobs and phasing can slow laps.",
    tips = {
        "Use Suramar when Felslate is the main target and your character can handle level-scaled mobs.",
        "Check river and cave seam points; comments call out seams as the missing rank-up source for many miners.",
        "Skip dense city sections unless the ore price justifies the combat time.",
    },
    coords = {
        C(0.2121, 0.1693, "AoA Suramar northwest route pin"),
        C(0.2183, 0.2310, "AoA Suramar northern cave approach"),
        C(0.2390, 0.2768, "AoA Suramar north river seam"),
        C(0.2480, 0.3212, "AoA Suramar ridge bend"),
        C(0.280, 0.272, "Northwest river seam check"),
        C(0.3016, 0.3189, "AoA Suramar river bend"),
        C(0.360, 0.326, "Crimson Thicket ridge"),
        C(0.4040, 0.2940, "Guide cave waypoint"),
        C(0.430, 0.396, "Shal'Aran cave approach"),
        C(0.4220, 0.2990, "Behind-waterfall cave waypoint"),
        C(0.542, 0.448, "Central waterline"),
        C(0.646, 0.546, "Moon Guard ridge"),
        C(0.522, 0.654, "Falanaar return"),
    },
    confidence = "medium",
}

local AZSUNA_BASILISK_ROUTE = {
    id = "legion-leystone-azsuna-lagoon-basilisks",
    source = "wow-professions Leystone guide and Wowhead Lagoon Basilisk page",
    sourceUrls = {
        "https://www.wow-professions.com/farming/leystone-ore-farming",
        "https://www.wowhead.com/npc=89013/lagoon-basilisk",
    },
    mapName = "Azsuna",
    location = "Lagoon Basilisks near Azsuna waterlines",
    routeType = "mineable-creature-loop",
    density = "High when uncontested",
    dropDifficulty = "Strong Leystone-only farm; does not meaningfully supply Felslate.",
    tips = {
        "Kill and mine Lagoon Basilisks when you want Leystone without waiting on world node respawns.",
        "Do not use this route for Felslate unless a side source such as a shoulder enchant is the real target.",
        "Move on if another player is tagging but not looting, because unlooted corpses cannot be mined.",
    },
    coords = {
        C(0.454, 0.604, "Southwestern basilisk bank"),
        C(0.488, 0.628, "Central lagoon"),
        C(0.526, 0.608, "Eastern lagoon edge"),
        C(0.506, 0.566, "Northern return"),
    },
    confidence = "high",
}

local EMPYRIUM_BASILISK_ROUTE = {
    id = "legion-empyrium-antoran-felfang-basilisks",
    source = "wow-professions Empyrium guide and Wowhead Empyrium object pages",
    sourceUrls = {
        "https://www.wow-professions.com/farming/empyrium-ore-farming",
        "https://www.wowhead.com/object=272780/empyrium-seam",
        "https://www.wowhead.com/npc=126938/felfang-basilisk",
    },
    mapName = "Antoran Wastes",
    location = "Felfang Basilisks in the Antoran green lava fields",
    routeType = "mineable-creature-loop",
    density = "High",
    dropDifficulty = "Best targeted Empyrium farm, but the lava path is punishing and mobs are dense.",
    tips = {
        "Mine each Felfang Basilisk corpse; the guide reports multiple Empyrium per mined corpse.",
        "Jump rock to rock and avoid standing in the green lava.",
        "Use a tank spec or anti-daze barding because Argus mob density is high.",
    },
    coords = {
        C(0.594, 0.498, "Northwest lava rock"),
        C(0.632, 0.532, "Central basilisk path"),
        C(0.680, 0.560, "Eastern lava edge"),
        C(0.646, 0.620, "Southern rock return"),
        C(0.588, 0.604, "Western rock return"),
    },
    confidence = "high",
}

local EMPYRIUM_KROKUUN_ROUTE = {
    id = "legion-empyrium-krokuun-nathraxas-node-loop",
    source = "wow-professions Empyrium guide, Wowhead Empyrium Seam object page, and Artisans of Azeroth retail Krokuun route string",
    sourceUrls = {
        "https://www.wow-professions.com/farming/empyrium-ore-farming",
        "https://www.wowhead.com/object=272780/empyrium-seam",
        "https://artisansofazeroth.com/legion-herbalism-leveling/",
    },
    mapName = "Krokuun",
    location = "Krokuun Empyrium node route, skipping the heaviest Nath'Raxas pulls when needed",
    routeType = "mining-loop",
    density = "Medium",
    dropDifficulty = "Good backup to basilisk mining, but combat is hard to avoid.",
    tips = {
        "Use Feign Death, stealth, or tank spec if available because the guide notes heavy mob pressure.",
        "Skip the north Nath'Raxas Hold section if it costs too much time.",
        "Mine seams and deposits together; do not camp a single node pocket.",
    },
    coords = {
        C(0.5879, 0.3141, "AoA Krokuun northern Argus route pin"),
        C(0.5935, 0.3613, "AoA Krokuun north ridge pin"),
        C(0.5913, 0.4013, "AoA Krokuun central ridge pin"),
        C(0.410, 0.350, "Nath'Raxas south edge"),
        C(0.522, 0.386, "Central ridge"),
        C(0.6175, 0.4583, "AoA Krokuun east ridge pin"),
        C(0.626, 0.476, "Eastern ridge"),
        C(0.596, 0.632, "Southern return"),
        C(0.5497, 0.6117, "AoA Krokuun southern return pin"),
        C(0.456, 0.686, "Western return"),
    },
    confidence = "medium",
}

local INFERNAL_BRIMSTONE_AZSUNA_ROUTE = {
    id = "legion-infernal-brimstone-azsuna-rhutvan-destroyer",
    source = "Wowhead Infernal Brimstone comments, Wowhead Legion Mining guide, and r/woweconomy Brimstone notes",
    sourceUrls = {
        "https://www.wowhead.com/item=124444/infernal-brimstone",
        "https://www.wowhead.com/guide/legion-mining",
        "https://www.reddit.com/r/woweconomy/wiki/mining-legion-infernal-brimstone/",
    },
    mapName = "Azsuna",
    location = "Rhut'van Divide Brimstone Destroyer mining world quest report",
    routeType = "world-quest-mining-target",
    density = "Intermittent",
    dropDifficulty = "Only practical when the Brimstone Destroyer world quest is active.",
    tips = {
        "Check Legion mining world quests before travelling; the source is the destroyer core, not normal ore nodes.",
        "Kill the Brimstone Destroyer inside the active quest area before mining the core.",
        "A Wowhead comment reports the Azsuna destroyer around 38,24.",
    },
    coords = {
        C(0.380, 0.240, "Azsuna Rhut'van Divide destroyer report"),
    },
    confidence = "medium",
}

local INFERNAL_BRIMSTONE_HIGHMOUNTAIN_ROUTE = {
    id = "legion-infernal-brimstone-highmountain-snowblind-destroyer",
    source = "Wowhead Infernal Brimstone comments, Wowhead Legion Mining guide, and r/woweconomy Brimstone notes",
    sourceUrls = {
        "https://www.wowhead.com/item=124444/infernal-brimstone",
        "https://www.wowhead.com/guide/legion-mining",
        "https://www.reddit.com/r/woweconomy/wiki/mining-legion-infernal-brimstone/",
    },
    mapName = "Highmountain",
    location = "Snowblind Mesa Brimstone Destroyer mining world quest report",
    routeType = "world-quest-mining-target",
    density = "Intermittent",
    dropDifficulty = "Only practical when the Brimstone Destroyer world quest is active.",
    tips = {
        "Check Legion mining world quests before travelling; the source is the destroyer core, not normal ore nodes.",
        "Kill the Brimstone Destroyer inside the active quest area before mining the core.",
        "A Wowhead comment reports the Highmountain destroyer around 55,68.",
    },
    coords = {
        C(0.550, 0.680, "Highmountain Snowblind Mesa destroyer report"),
    },
    confidence = "medium",
}

-- Supplied mining exports are independent dropdown options, including same-map variants.
-- Source-based paths and scouting candidates have not been tested in the live client.
local function SuppliedMiningRoute(id, sortOrder, mapID, mapName, name, variant, routeType, provenance, packedCoords, tips, sourceUrls, experimental)
    local coords = {}
    for index, packed in ipairs(packedCoords) do
        coords[#coords + 1] = C(math.floor(packed / 10000) / 10000, (packed % 10000) / 10000, name .. " #" .. index)
    end
    local worldQuest = routeType == "world-quest-mining-target"
    local difficulty = "Source-derived route, not live-game tested. Follow terrain-accessible paths between waypoints."
    if worldQuest then
        difficulty = "World Quest location guide only; not a repeatable ore loop. Requires the active Brimstone Destroyer quest and Legion Mining 25."
        tips[#tips + 1] = "Visit only during the corresponding active Brimstone Destroyer World Quest; Legion Mining skill 25 is required to mine the core."
    elseif experimental then
        difficulty = "Experimental scouting patrol with approximate checkpoints; test corpse mining in current Retail before farming."
    end
    return {
        id = id,
        sortOrder = sortOrder,
        mapID = mapID,
        mapName = mapName,
        location = name,
        dropdownLabel = mapName .. ": " .. sortOrder .. ". " .. variant .. " - " .. name
            .. (worldQuest and " (WQ only)" or (experimental and " (Experimental)" or "")),
        routeType = routeType,
        provenance = provenance,
        source = provenance,
        sourceUrls = sourceUrls,
        dropDifficulty = difficulty,
        tips = tips,
        coords = coords,
        confidence = experimental and "low" or "medium",
        experimental = experimental,
        inGameTested = false,
        isRoute = true,
    }
end

local SUPPLIED_MINING_ROUTES = {
    [123918] = {
        SuppliedMiningRoute(
            "legion-leystone-ore-suramar-northwest-mining-circuit-supplied", 1,
            680, "Suramar", "Leystone Ore - Northwest mining circuit", "Main route",
            "mining-loop",
            "User-supplied export based on Epic WoW Guides downloadable Suramar mining route; not live-game tested",
            { 26790868, 28501439, 26912173, 23933103, 44982664, 42654099, 33634082, 35274967, 38905896, 26445248, 24875850, 24896841, 15454835, 19754202, 15853795, 17552954, 20002575, 20201817, 24701725 },
            {
                "Use a flying mount to cover the northwest Suramar hills and valleys.",
                "Mine every Leystone deposit, rich deposit and seam, including nodes near the waterways.",
                "Do not skip Felslate; both ores share this established farming circuit.",
            },
            {
                "https://epicwowguides.com/material/leystone-ore-farming/",
                "https://www.wowhead.com/item=123918/leystone-ore",
            }, false
        ),
        SuppliedMiningRoute(
            "legion-leystone-ore-azsuna-coastal-and-inland-circuit-supplied", 2,
            630, "Azsuna", "Leystone Ore - Coastal and inland circuit", "Alternative A",
            "mining-loop",
            "User-supplied export based on Epic WoW Guides downloadable Azsuna mining route; not live-game tested",
            { 26494163, 33664370, 48305250, 49554390, 45243523, 48913272, 55653368, 66823697, 66114251, 64115462, 64306059, 63806372, 57606431, 59476983, 61326978, 60667303, 59157293, 58828083, 52818081, 51308390, 47398489, 38668609, 41447232, 41276072, 35585992, 36375664, 33815555, 25765513, 24434558 },
            {
                "A broad alternative when Suramar has competition.",
                "Check the eastern side around 55,34 for eligible mineable basilisks, but confirm corpse-mining functionality in Retail.",
                "Gather Leystone and Felslate together instead of ignoring the less valuable ore.",
            },
            {
                "https://epicwowguides.com/material/leystone-ore-farming/",
                "https://www.wowhead.com/item=123918/leystone-ore",
            }, false
        ),
        SuppliedMiningRoute(
            "legion-leystone-ore-suramar-hidden-seam-cave-circuit-supplied", 3,
            680, "Suramar", "Leystone Ore - Hidden seam cave circuit", "Alternative B",
            "mining-cave-inspection-loop",
            "User-supplied Suramar cave and waterfall seam inspection circuit; source-inspired waypoint ordering, not live-game tested",
            { 40402940, 42202990, 31502610, 19331912, 24205070, 29305080, 28305620 },
            {
                "Visit the cave entrances around 40.4,29.4, 31.5,26.1, 24.2,50.7, and 28.3,56.2.",
                "At 42.2,29.9, search behind the waterfall.",
                "Mine seams inside caves all the way to their deepest rooms. A seam may be invisible on the minimap from outside.",
                "Treat this as a cave inspection route; straight lines between entrances are not always walkable.",
                "Leystone Seams can respawn as Felslate Seams; inspect the caves for both ores.",
            },
            {
                "https://www.wow-professions.com/farming/leystone-ore-farming",
                "https://www.wow-professions.com/farming/felslate-farming",
                "https://www.wowhead.com/item=123918/leystone-ore",
            }, false
        ),
    },
    [123919] = {
        SuppliedMiningRoute(
            "legion-felslate-suramar-northwest-mixed-ore-circuit-supplied", 1,
            680, "Suramar", "Felslate - Northwest mixed ore circuit", "Main route",
            "mining-loop",
            "User-supplied export based on Epic WoW Guides downloadable Suramar mining route; not live-game tested",
            { 26790868, 28501439, 26912173, 23933103, 44982664, 42654099, 33634082, 35274967, 38905896, 26445248, 24875850, 24896841, 15454835, 19754202, 15853795, 17552954, 20002575, 20201817, 24701725 },
            {
                "Suramar is the first choice in Epic WoW Guides' Felslate route recommendations.",
                "Focus on cliffside ore deposits, river seams and rich nodes.",
                "Mine Leystone nodes as well; pure Felslate-only routing can mean considerable dead travel.",
            },
            {
                "https://epicwowguides.com/material/felslate-farming/",
                "https://www.wowhead.com/item=123919/felslate",
            }, false
        ),
        SuppliedMiningRoute(
            "legion-felslate-azsuna-northern-and-southern-sweep-supplied", 2,
            630, "Azsuna", "Felslate - Northern and southern sweep", "Alternative A",
            "mining-loop",
            "User-supplied export based on Epic WoW Guides downloadable Azsuna mining route; not live-game tested",
            { 26494163, 33664370, 48305250, 49554390, 45243523, 48913272, 55653368, 66823697, 66114251, 64115462, 64306059, 63806372, 57606431, 59476983, 61326978, 60667303, 59157293, 58828083, 52818081, 51308390, 47398489, 38668609, 41447232, 41276072, 35585992, 36375664, 33815555, 25765513, 24434558 },
            {
                "Use this if Suramar is crowded or you want an easier continuous flight path.",
                "Focus on both deposit types, rather than searching exclusively for Felslate.",
                "Add nearby riverside seams whenever they appear on the minimap.",
            },
            {
                "https://epicwowguides.com/material/felslate-farming/",
                "https://www.wowhead.com/item=123919/felslate",
            }, false
        ),
        SuppliedMiningRoute(
            "legion-felslate-suramar-felsoul-hold-basilisk-patrol-supplied", 3,
            680, "Suramar", "Felslate - Felsoul Hold basilisk patrol", "Alternative B",
            "mineable-creature-loop",
            "User-supplied experimental Felsoul Hold basilisk scouting patrol; approximate checkpoints, not verified creature spawns",
            { 27005750, 28005900, 29006000, 28406140, 26806090, 26505920 },
            {
                "Check mineable Felslate/Felfire Basilisks near Felsoul Hold, around 28,59.",
                "Kill a basilisk and test corpse mining before committing to the route.",
                "The six encoded waypoints are approximate scouting positions surrounding the documented farming area, not individually verified mob spawns.",
                "The supplied research notes 2026 Retail reports of some basilisk corpses no longer being mineable; treat this as a conditional experiment.",
            },
            {
                "https://www.wowhead.com/item=123919/felslate",
                "https://www.wowhead.com/guide/legion-mining",
            }, true
        ),
    },
    [151564] = {
        SuppliedMiningRoute(
            "legion-empyrium-krokuun-thirty-point-empyrium-seam-circuit-supplied", 1,
            830, "Krokuun", "Empyrium - Thirty point Empyrium seam circuit", "Main route",
            "mining-loop",
            "User-supplied route reconstructed from dralian's documented Krokuun coordinates on the Wowhead Empyrium Seam page; ordering not tested for traversability",
            { 71023042, 73303312, 71663574, 69763395, 60053298, 54993374, 60643712, 61264252, 70015736, 69245587, 68845746, 68315904, 63796860, 64026675, 62886707, 69597490, 74456442, 75386507, 57705369, 52305288, 53305945, 53896404, 46617839, 44968577, 43168686, 42557891, 31526894, 29396551, 29515799, 31415729 },
            {
                "Start near Destiny Point, cover the northeastern mining locations, then move through the southern and western node pockets.",
                "Mine both Empyrium Deposits and Empyrium Seams.",
                "No regular flying is available on Argus. Use the area's teleportation beacons and terrain-accessible paths.",
                "Look around each waypoint instead of assuming a seam must spawn at exactly that point.",
                "The 30 coordinates are from dralian's three-macro list; reconstructed route order may require detours or teleports.",
            },
            {
                "https://www.wowhead.com/object=272780/empyrium-seam",
                "https://www.wow-professions.com/farming/empyrium-ore-farming",
            }, false
        ),
        SuppliedMiningRoute(
            "legion-empyrium-krokuun-tereck-cave-seam-pocket-supplied", 2,
            830, "Krokuun", "Empyrium - Tereck cave seam pocket", "Alternative A",
            "mining-loop",
            "User-supplied route reconstructed from dralian's documented Krokuun coordinates on the Wowhead Empyrium Seam page; ordering not tested for traversability",
            { 69245587, 68845746, 70015736, 68315904 },
            {
                "Focus on the cluster around 69,58.",
                "Search inside the cave, as seams can be concealed by the cave's geometry.",
                "Useful for targeted checks, but too small to guarantee continuous ore gathering without respawn downtime.",
                "This shorter pocket route uses points from the documented Krokuun seam locations.",
            },
            {
                "https://www.wowhead.com/object=272780/empyrium-seam",
                "https://www.wow-professions.com/farming/empyrium-ore-farming",
            }, false
        ),
        SuppliedMiningRoute(
            "legion-empyrium-antoran-wastes-shattered-chasm-basilisk-scouting-supplied", 3,
            885, "Antoran Wastes", "Empyrium - Shattered Chasm basilisk scouting", "Alternative B",
            "mineable-creature-loop",
            "User-supplied experimental Shattered Chasm basilisk patrol inspired by WoW-Professions; approximate exploration checkpoints, not verified spawns",
            { 69004840, 71604800, 74005000, 75105300, 72705610, 69405530, 68005200 },
            {
                "Search for Felfang Basilisks around the fel-lava areas of Antoran Wastes.",
                "Use rocky islands to move through the green lava basin without taking unnecessary damage.",
                "Test whether defeated basilisks can still be mined on your current Retail version.",
                "The encoded patrol points are approximate exploration checkpoints, not verified individual basilisk spawns.",
            },
            {
                "https://www.wow-professions.com/farming/empyrium-ore-farming",
                "https://www.wowhead.com/npc=126938/felfang-basilisk",
            }, true
        ),
    },
    [124444] = {
        SuppliedMiningRoute(
            "legion-infernal-brimstone-val-sharah-brimstone-wq-candidate-sites-supplied", 1,
            641, "Val'sharah", "Infernal Brimstone - Brimstone WQ candidate sites", "Main",
            "world-quest-mining-target",
            "User-supplied Brimstone Destroyer World Quest location guide based on Wowhead reports; conditional quest sites, not repeatable mining",
            { 53394572, 39103300, 39006905 },
            {
                "Check reported sites 53.39,45.72, 39.1,33.0 and 39.0,69.05.",
                "The northern mountain point requires an ascending path.",
                "These are possible locations of different quests, not three simultaneous mineable cores.",
            },
            {
                "https://www.wowhead.com/item=124444/infernal-brimstone",
                "https://www.wowhead.com/guide/legion-mining",
            }, false
        ),
        SuppliedMiningRoute(
            "legion-infernal-brimstone-azsuna-brimstone-wq-candidate-sites-supplied", 2,
            630, "Azsuna", "Infernal Brimstone - Brimstone WQ candidate sites", "Alternative A",
            "world-quest-mining-target",
            "User-supplied Brimstone Destroyer World Quest location guide based on Wowhead reports; conditional quest sites, not repeatable mining",
            { 38802540, 34005300, 39103290 },
            {
                "Northern Destroyer area: 38.8,25.4; the approach trail starts around 39.1,32.9.",
                "Another reported Destroyer site is near 34,53.",
                "Fight within the active World Quest area and mine the remaining core afterward.",
            },
            {
                "https://www.wowhead.com/item=124444/infernal-brimstone",
                "https://www.wowhead.com/guide/legion-mining",
            }, false
        ),
        SuppliedMiningRoute(
            "legion-infernal-brimstone-stormheim-brimstone-wq-candidate-sites-supplied", 3,
            634, "Stormheim", "Infernal Brimstone - Brimstone WQ candidate sites", "Alternative B",
            "world-quest-mining-target",
            "User-supplied Brimstone Destroyer World Quest location guide based on Wowhead reports; conditional quest sites, not repeatable mining",
            { 61303554, 64556877 },
            {
                "Northern area: 61.3,35.54.",
                "Gates of Valor site: 64.55,68.77.",
                "For the Gates of Valor site, approach from the upper platform and use the rocky slope, rather than jumping off the cliffs.",
            },
            {
                "https://www.wowhead.com/item=124444/infernal-brimstone",
                "https://www.wowhead.com/guide/legion-mining",
            }, false
        ),
        SuppliedMiningRoute(
            "legion-infernal-brimstone-highmountain-thunder-totem-mountain-wq-sites-supplied", 4,
            650, "Highmountain", "Infernal Brimstone - Thunder Totem mountain WQ sites", "Alternative C",
            "world-quest-mining-target",
            "User-supplied Brimstone Destroyer World Quest location guide based on Wowhead reports; conditional quest sites, not repeatable mining",
            { 56007000, 55006800, 59006800 },
            {
                "Check the area above Thunder Totem near 56,70 or 55,68.",
                "Use Stonehoof Watch as an approach point; the mountain ascent starts around 59,68.",
                "The last waypoint is a path marker, not a separate resource node.",
            },
            {
                "https://www.wowhead.com/item=124444/infernal-brimstone",
                "https://www.wowhead.com/guide/legion-mining",
            }, false
        ),
        SuppliedMiningRoute(
            "legion-infernal-brimstone-suramar-northwest-and-felsoul-wq-sites-supplied", 5,
            680, "Suramar", "Infernal Brimstone - Northwest and Felsoul WQ sites", "Alternative D",
            "world-quest-mining-target",
            "User-supplied Brimstone Destroyer World Quest location guide based on Wowhead reports; conditional quest sites, not repeatable mining",
            { 20531969, 23206000 },
            {
                "The northwest Suramar World Quest can be reached using a narrow mountain path near 20.53,19.69, including an approach from southern Highmountain.",
                "Another reported Destroyer appears around 23.2,60.0, above Felsoul Hold.",
                "These are widely separated quest alternatives and should not be treated as a continuous farming loop.",
            },
            {
                "https://www.wowhead.com/item=124444/infernal-brimstone",
                "https://www.wowhead.com/guide/legion-mining",
            }, false
        ),
    },
}

local function WithSuppliedRoutes(itemID, spots)
    local routes = {}
    for _, spot in ipairs(SUPPLIED_MINING_ROUTES[itemID] or {}) do
        routes[#routes + 1] = spot
    end
    for _, spot in ipairs(spots) do
        spot.isRoute = true
        routes[#routes + 1] = spot
    end
    return routes
end

local function RegisterOre(itemID, itemName, spots, summary)
    Register({
        itemID = itemID,
        itemName = itemName,
        expansion = "legion",
        professions = { "mining" },
        category = "Ore",
        isRoute = true,
        sourceUrls = { ItemUrl(itemID) },
        summary = summary,
        spots = WithSuppliedRoutes(itemID, spots),
    })
end

RegisterOre(
    123918,
    "Leystone Ore",
    { VALSHARAH_ORE_ROUTE, SURAMAR_ORE_ROUTE, AZSUNA_BASILISK_ROUTE },
    "Common Legion ore from Broken Isles nodes and mineable Lagoon Basilisks."
)
RegisterOre(
    123919,
    "Felslate",
    { SURAMAR_ORE_ROUTE, VALSHARAH_ORE_ROUTE },
    "Rare Legion ore from nodes and seams, best checked on Suramar and Val'sharah loops."
)
RegisterOre(
    151564,
    "Empyrium",
    { EMPYRIUM_BASILISK_ROUTE, EMPYRIUM_KROKUUN_ROUTE },
    "Argus ore from Empyrium nodes and mineable Felfang Basilisks."
)
RegisterOre(
    124444,
    "Infernal Brimstone",
    { INFERNAL_BRIMSTONE_AZSUNA_ROUTE, INFERNAL_BRIMSTONE_HIGHMOUNTAIN_ROUTE },
    "World-quest-gated Legion mining material from Brimstone Destroyer cores."
)
