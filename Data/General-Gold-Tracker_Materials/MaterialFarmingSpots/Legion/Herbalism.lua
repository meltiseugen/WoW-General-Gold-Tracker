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

-- Supplied generated candidates: each variant stays a separate map dropdown option.
-- Coordinates are approximate route vertices, not independently tested herb nodes.
local function SuppliedHerbRoute(id, sortOrder, mapID, mapName, name, variant, routeType, packedCoords, tips, sourceUrls)
    local coords = {}
    for index, packed in ipairs(packedCoords) do
        coords[#coords + 1] = C(math.floor(packed / 10000) / 10000, (packed % 10000) / 10000, name .. " #" .. index)
    end
    return {
        id = id,
        sortOrder = sortOrder,
        mapID = mapID,
        mapName = mapName,
        location = name,
        dropdownLabel = mapName .. ": " .. sortOrder .. ". " .. variant .. " - " .. name,
        routeType = routeType,
        source = "User-supplied generated Retail Routes candidate; linked guides credited for inspiration",
        sourceUrls = sourceUrls,
        dropDifficulty = "Generated candidate loop, not independently game-tested. Waypoints are approximate route vertices, not guaranteed herb nodes.",
        tips = tips,
        coords = coords,
        confidence = "low",
        inGameTested = false,
        isRoute = true,
    }
end

local SUPPLIED_HERB_ROUTES = {
    [124101] = {
        SuppliedHerbRoute(
            "legion-aethril-north-azsuna-arc-supplied", 1,
            630, "Azsuna", "Aethril North Azsuna Arc", "Main",
            "herbalism-loop",
            { 46202620, 49301950, 53001540, 58701880, 63102370, 63503250, 66804080, 63004980, 59405460, 54205170, 49004450, 45203810 },
            {
                "Fly around Azurewing Repose, Narthalas Academy and the northeastern slopes; this is a long respawn-friendly sweep rather than a fixed-node trail.",
                "Collect the extra Aethril from Withered Hungerers that can appear on harvest.",
                "Prioritize Rank 3 Aethril and the Legion Herbalism glove enchant.",
            },
            {
                "https://www.wow-professions.com/farming/aethril-farming",
                "https://epicwowguides.com/material/aethril-farming/",
            }
        ),
        SuppliedHerbRoute(
            "legion-aethril-south-azsuna-coast-supplied", 2,
            630, "Azsuna", "Aethril South Azsuna Coast", "Alternative",
            "herbalism-loop",
            { 45204340, 50104760, 55205360, 58606030, 56906900, 50807280, 45106990, 42706320, 40805660, 42604920 },
            {
                "Use the southern Azsuna coastal and roadside path when the northern corridor is occupied.",
                "Check water-adjacent greenery and avoid spending time clearing non-gathering mobs.",
                "Flying helps to bridge sparse sections and return to your first harvested nodes.",
            },
            {
                "https://www.wow-professions.com/farming/aethril-farming",
                "https://epicwowguides.com/material/aethril-farming/",
            }
        ),
    },
    [124102] = {
        SuppliedHerbRoute(
            "legion-dreamleaf-valsharah-broad-forest-supplied", 1,
            641, "Val'sharah", "Dreamleaf Valsharah Broad Forest", "Main",
            "herbalism-loop",
            { 41203520, 46003190, 51303210, 56703680, 63403530, 69403940, 71304780, 67005340, 62105750, 56006340, 49806610, 44606090, 41105440, 38804370 },
            {
                "Run the larger forest sweep to provide respawn time; pick Dreamleaf along forest edges and glades.",
                "Kill Nightmare Creepers that appear from corrupted Dreamleaf harvests to gain bonus Dreamleaf.",
                "Rank 3 increases output per node; use GatherMate2 to cut unproductive sections after one lap.",
            },
            {
                "https://www.wow-professions.com/farming/dreamleaf-farming",
                "https://www.wowhead.com/item=124102/dreamleaf",
            }
        ),
        SuppliedHerbRoute(
            "legion-dreamleaf-shalanir-treant-farm-supplied", 2,
            641, "Val'sharah", "Dreamleaf Shalanir Treant Farm", "Alternative",
            "herbalism-and-herbable-mob-loop",
            { 58003570, 59303620, 61603650, 62503870, 61404050, 59404140, 57803970, 57403750 },
            {
                "This is a kill-and-herb circuit, not a standard plant-node loop: kill Vilepetal Rooters, Defiled Grovewalkers and Desecrated Ancients.",
                "Use Herbalism on eligible corpses after looting; farm around the 60,38 Shala’nir cluster.",
                "Also generates Yseralline Seeds; competitive alternative when normal plant nodes are scarce.",
            },
            {
                "https://www.wow-professions.com/farming/dreamleaf-farming",
                "https://www.wowhead.com/item=124102/dreamleaf",
            }
        ),
    },
    [124103] = {
        SuppliedHerbRoute(
            "legion-foxflower-highmountain-valley-arc-supplied", 1,
            650, "Highmountain", "Foxflower Highmountain Valley Arc", "Main",
            "herbalism-loop",
            { 43503880, 49203550, 54503990, 59904270, 65504990, 68505740, 66506580, 61007050, 56107540, 50407080, 45406530, 40105770, 39804750 },
            {
                "Follow valley floors and lower slopes where possible; mountain walls create detours even with flying.",
                "When a fox appears after harvesting, follow its trail and run over the scattered Foxflowers.",
                "Use the Majestic Elderhorn Hoof if owned, but its speed effect does not stack with Leystone Hoofplates.",
            },
            {
                "https://www.wow-professions.com/farming/foxflower-farming",
            }
        ),
        SuppliedHerbRoute(
            "legion-foxflower-southern-wetlands-supplied", 2,
            650, "Highmountain", "Foxflower Southern Wetlands", "Alternative",
            "herbalism-loop",
            { 48106230, 54006440, 59806800, 64607330, 61507990, 55108360, 49608010, 45407490, 43706870 },
            {
                "Focus on the southern and Blind Marshlands side of Highmountain if central valleys are contested.",
                "Watch for hostile mobs; the original non-flying guide recommends flight-path repositioning between sectors.",
                "Collect bonus Foxflower along a fox trail immediately rather than finishing the circuit.",
            },
            {
                "https://www.wow-professions.com/farming/foxflower-farming",
            }
        ),
    },
    [124104] = {
        SuppliedHerbRoute(
            "legion-fjarnskaggl-stormheim-upland-sweep-supplied", 1,
            634, "Stormheim", "Fjarnskaggl Stormheim Upland Sweep", "Main",
            "herbalism-loop",
            { 35803550, 40203170, 47403120, 53203500, 59403790, 65104220, 68704950, 64705580, 58105310, 52205870, 45505610, 40204940, 35804240 },
            {
                "Sweep open Stormheim highlands and the cliff-adjacent terraces rather than pushing into mob-packed settlements.",
                "Alliance characters should avoid cutting through hostile Horde encampments on the ground.",
                "Fjarnskaggl Rank 3 helps remount speed; pick while mounted where eligible.",
            },
            {
                "https://www.wow-professions.com/farming/fjarnskaggl-farming",
            }
        ),
        SuppliedHerbRoute(
            "legion-fjarnskaggl-eastern-fjord-loop-supplied", 2,
            634, "Stormheim", "Fjarnskaggl Eastern Fjord Loop", "Alternative",
            "herbalism-loop",
            { 55602590, 62402790, 67403160, 74303920, 75404770, 71005580, 64305900, 60405390, 60804470, 57903710 },
            {
                "Test the eastern fjord terrain as a secondary circuit if the interior route is depleted.",
                "Use flying to avoid steep elevation changes; on foot, follow available ramps and bridges.",
                "Allow enough time between short laps for nodes to respawn.",
            },
            {
                "https://www.wow-professions.com/farming/fjarnskaggl-farming",
            }
        ),
    },
    [124105] = {
        SuppliedHerbRoute(
            "legion-starlight-rose-falanaar-telanor-supplied", 1,
            680, "Suramar", "Starlight Rose Falanaar Telanor", "Main",
            "herbalism-loop",
            { 27404390, 31203850, 35203290, 40103220, 44603520, 48102950, 53003230, 56603870, 53304360, 49204920, 43005070, 37104870, 32505300, 28105020 },
            {
                "Sweep the Falanaar and Tel’anor exterior terrain; avoid unnecessary detours into the city itself.",
                "Prioritize Rank 3 Starlight Rose: lower ranks can fail and give Starlight Rosedust instead.",
                "Kill Withered Hungerers created on a gather for possible extra Starlight Rose.",
            },
            {
                "https://www.wow-professions.com/farming/starlight-rose-farming",
                "https://www.mmobase.de/spiele/world-of-warcraft-legion/tipps/32/",
            }
        ),
        SuppliedHerbRoute(
            "legion-starlight-rose-irongrove-northern-supplied", 2,
            680, "Suramar", "Starlight Rose Irongrove Northern", "Alternative",
            "herbalism-loop",
            { 27102820, 31202330, 37402170, 44002480, 50002730, 53003380, 49103830, 42803700, 37903400, 31903530, 27403370 },
            {
                "Cover the northern Suramar ridges and Irongrove Retreat margins as an alternative to crowded Falanaar.",
                "The loop is better suited to a flying character, since forest ridges interrupt ground travel.",
                "Use a wider circuit to give Starlight Rose nodes time to repopulate.",
            },
            {
                "https://www.wow-professions.com/farming/starlight-rose-farming",
                "https://www.mmobase.de/spiele/world-of-warcraft-legion/tipps/32/",
            }
        ),
    },
    [124106] = {
        SuppliedHerbRoute(
            "legion-felwort-azsuna-wq-check-supplied", 1,
            630, "Azsuna", "Felwort Azsuna WQ Check", "Main - WQ only",
            "world-quest-herb-target",
            { 47405570, 48605720, 49505900, 50905740, 49405540 },
            {
                "Only investigate this short waypoint circuit when an active Felwort Herbalism World Quest targets Azsuna.",
                "Historical Felwort WQ location reported near 48.6,57.2; the marker can change or be absent.",
                "Felwort is not a repeatably spawning ordinary herb route.",
            },
            {
                "https://www.wowhead.com/item=124106/felwort",
                "https://warcraft.wiki.gg/wiki/Fertile_Soil_(Broken_Isles)",
            }
        ),
        SuppliedHerbRoute(
            "legion-felwort-highmountain-wq-check-supplied", 2,
            650, "Highmountain", "Felwort Highmountain WQ Check", "Alternative - WQ only",
            "world-quest-herb-target",
            { 34804080, 36104220, 37504360, 38004110, 36704020 },
            {
                "Check for an active Felwort profession World Quest before visiting the historical location at 36.1,42.2.",
                "Harvest the quest-specific Felwort after meeting quest and herbalism unlock requirements.",
                "This is a reconnaissance route; repeating it with no active quest will not reliably yield Felwort.",
            },
            {
                "https://www.wowhead.com/item=124106/felwort",
                "https://warcraft.wiki.gg/wiki/Fertile_Soil_(Broken_Isles)",
            }
        ),
        SuppliedHerbRoute(
            "legion-felwort-ironhorn-fertile-soil-supplied", 3,
            650, "Highmountain", "Felwort Ironhorn Fertile Soil", "Alternative - seeds only",
            "seed-planting-loop",
            { 54408410, 55108490, 56308530, 56908390, 55908340 },
            {
                "Carry Felwort Seeds obtained from the relevant profession source; these are not Yseralline Seeds.",
                "Find Fertile Soil around the Ironhorn Enclave, especially near 55.4,84.9.",
                "Plant seeds and remain nearby until harvestable. Other herbalists may harvest planted herbs.",
            },
            {
                "https://www.wowhead.com/item=124106/felwort",
                "https://warcraft.wiki.gg/wiki/Fertile_Soil_(Broken_Isles)",
            }
        ),
    },
    [151565] = {
        SuppliedHerbRoute(
            "legion-astral-glory-krokuun-fel-herb-sweep-supplied", 1,
            830, "Krokuun", "Astral Glory Krokuun Fel Herb Sweep", "Main",
            "herbalism-loop",
            { 53202980, 58703630, 63704260, 66804990, 64905980, 59606510, 55407390, 47807380, 42706640, 36805980, 38905010, 45204190, 48303580 },
            {
                "Harvest Fel-Encrusted Herb nodes: despite their name, they can yield Astral Glory.",
                "Expect heavy enemy density and combat interruptions; anti-daze or a tank specialization helps.",
                "Argus is ground-based; Demonsteel Stirrups are not effective here according to the farming guide.",
            },
            {
                "https://www.wow-professions.com/farming/astral-glory-farming",
                "https://www.wowhead.com/item=151565/astral-glory",
            }
        ),
        SuppliedHerbRoute(
            "legion-astral-glory-eredath-northern-supplied", 2,
            882, "Eredath", "Astral Glory Eredath Northern", "Alternative",
            "herbalism-loop",
            { 37803940, 44003310, 51902880, 58203390, 63004140, 67005020, 63905840, 58506310, 52406230, 46105690, 40304870 },
            {
                "Target the actual Astral Glory nodes scattered across Eredath rather than Krokuun-style Fel-Encrusted Herbs.",
                "Use the opened Vindicaar teleport network to minimize travel to the starting sector.",
                "Eredath had somewhat lower yields than Krokuun in the source guide, so measure herbs per minute.",
            },
            {
                "https://www.wow-professions.com/farming/astral-glory-farming",
                "https://www.wowhead.com/item=151565/astral-glory",
            }
        ),
        SuppliedHerbRoute(
            "legion-astral-glory-antoran-fel-clusters-supplied", 3,
            885, "Antoran Wastes", "Astral Glory Antoran Fel Clusters", "Alternative - mixed",
            "herbalism-loop",
            { 54003090, 59803350, 64704090, 67704880, 65005700, 60706310, 55605980, 49505420, 47404650, 50703930 },
            {
                "This is an experimental Antoran Wastes scouting circuit, not a proven optimal route.",
                "Look for Fel-Encrusted Herbs as you move; these nodes can produce Astral Glory.",
                "Expect hostile mobs and inaccessible cliff shortcuts; take road-grade detours.",
            },
            {
                "https://www.wow-professions.com/farming/astral-glory-farming",
                "https://www.wowhead.com/item=151565/astral-glory",
            }
        ),
    },
    [128304] = {
        SuppliedHerbRoute(
            "legion-yseralline-seed-shalanir-plants-supplied", 1,
            641, "Val'sharah", "Yseralline Seed Shalanir Plants", "Main - corpse gather",
            "herbalism-and-herbable-mob-loop",
            { 58003630, 59803610, 61703740, 62903900, 61104130, 59604080, 57703950, 57803760 },
            {
                "Kill Vilepetal Rooters, Defiled Grovewalkers and Desecrated Ancients and herbalism-gather their corpses.",
                "Circle Shala’nir near 60,38.5; this is a targeted alternative to indiscriminate herb gathering.",
                "You will also collect Dreamleaf while farming Yseralline Seeds.",
            },
            {
                "https://warcraft.wiki.gg/wiki/Yseralline_Seed",
                "https://www.wowhead.com/item=128304/yseralline-seed",
            }
        ),
        SuppliedHerbRoute(
            "legion-yseralline-seed-foxflower-valley-supplied", 2,
            650, "Highmountain", "Yseralline Seed Foxflower Valley", "Alternative - herb nodes",
            "herbalism-loop",
            { 45704580, 51404170, 57704560, 64705040, 66605750, 61806330, 56606500, 50106160, 45105520 },
            {
                "Collect Foxflower nodes in Highmountain; Yseralline Seeds can be bonus gathering output.",
                "Follow foxes that appear from Foxflower harvesting to maximize total herb yield.",
                "Avoid Suramar Starlight Rose circuits for this particular material.",
            },
            {
                "https://warcraft.wiki.gg/wiki/Yseralline_Seed",
                "https://www.wowhead.com/item=128304/yseralline-seed",
            }
        ),
        SuppliedHerbRoute(
            "legion-yseralline-seed-azsuna-aethril-supplied", 3,
            630, "Azsuna", "Yseralline Seed Azsuna Aethril", "Alternative - herb nodes",
            "herbalism-loop",
            { 48102630, 54002110, 60802630, 64603440, 62604300, 58204980, 53204630, 48504050, 44803370 },
            {
                "Collect Aethril herb nodes as the main source of Yseralline Seeds on this circuit.",
                "The more open Azsuna terrain can be easier than Highmountain for flying or fast mounts.",
                "Expect an accompanying haul of Aethril; compare both reagent prices when choosing a farm.",
            },
            {
                "https://warcraft.wiki.gg/wiki/Yseralline_Seed",
                "https://www.wowhead.com/item=128304/yseralline-seed",
            }
        ),
    },
}

local function WithSuppliedRoutes(itemID, spots)
    local routes = {}
    for _, spot in ipairs(SUPPLIED_HERB_ROUTES[itemID] or {}) do
        routes[#routes + 1] = spot
    end
    for _, spot in ipairs(spots) do
        spot.isRoute = true
        routes[#routes + 1] = spot
    end
    return routes
end

local function RegisterHerb(itemID, itemName, spots, summary)
    Register({
        itemID = itemID,
        itemName = itemName,
        expansion = "legion",
        professions = { "herbalism", "alchemy", "inscription" },
        category = "Herb",
        isRoute = true,
        sourceUrls = { ItemUrl(itemID) },
        summary = summary,
        spots = WithSuppliedRoutes(itemID, spots),
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
    isRoute = true,
    sourceUrls = {
        ItemUrl(128304),
        "https://www.wowhead.com/guide/legion-herbalism",
        "https://www.wowhead.com/guide/legion-alchemy",
        "https://warcraft.wiki.gg/wiki/Yseralline_Seed",
    },
    summary = "Common Legion seed found while gathering Broken Isles herbs and used by Alchemy, Inscription, and Cooking workflows.",
    spots = WithSuppliedRoutes(128304, { DREAMLEAF_ROUTE, AETHRIL_ROUTE, STARLIGHT_ROSE_ROUTE }),
})

RegisterSeed(129284, "Aethril Seed", { AETHRIL_ROUTE }, "Plantable Legion herb seed obtained from Aethril and other Broken Isles herbalism routes.")
RegisterSeed(129285, "Dreamleaf Seed", { DREAMLEAF_ROUTE }, "Plantable Legion herb seed obtained from Dreamleaf and other Broken Isles herbalism routes.")
RegisterSeed(129286, "Foxflower Seed", { FOXFLOWER_ROUTE }, "Plantable Legion herb seed obtained from Foxflower and other Broken Isles herbalism routes.")
RegisterSeed(129287, "Fjarnskaggl Seed", { FJARNSKAGGL_ROUTE }, "Plantable Legion herb seed obtained from Fjarnskaggl and other Broken Isles herbalism routes.")
RegisterSeed(129288, "Starlight Rose Seed", { STARLIGHT_ROSE_ROUTE }, "Plantable Legion herb seed obtained from Starlight Rose and other Broken Isles herbalism routes.")
RegisterSeed(129289, "Felwort Seed", { FELWORT_AZSUNA_ROUTE, FELWORT_HIGHMOUNTAIN_ROUTE }, "Rare Legion herb seed associated with Felwort gathering and world-quest/seed workflows.")
