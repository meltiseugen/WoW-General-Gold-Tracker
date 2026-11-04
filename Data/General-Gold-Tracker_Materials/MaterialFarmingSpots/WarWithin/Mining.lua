local _, NS = ...
local Register = NS.RegisterMaterialFarmingSpot
local H = NS.MaterialFarmingSpotHelpers

local function C(x, y, label)
    return { x = x, y = y, label = label }
end

local function ItemUrl(itemID)
    return "https://www.wowhead.com/item=" .. tostring(itemID)
end

local CRYSTALLIZED_GATHERING_SPOTS = {
    {
        id = "tww-crystallized-gathering-ringing-deeps-route",
        source = "Wowhead Crystallized ore and Irradiated herb object map pins, Method mining and herbalism guides",
        sourceUrls = {
            "https://www.wowhead.com/item=213610/crystalline-powder",
            "https://www.wowhead.com/object=413883/crystallized-bismuth",
            "https://www.wowhead.com/object=413900/crystallized-ironclaw",
            "https://www.wowhead.com/object=414337/irradiated-orbinid",
            "https://www.method.gg/guides/the-war-within-mining-profession-leveling-guide",
            "https://www.method.gg/guides/the-war-within-herbalism-profession-leveling-guide",
        },
        mapName = "The Ringing Deeps",
        location = "Northern ore walls and underground herb tunnels with Crystallized ore and Irradiated herb pins",
        routeType = "modified-node-loop",
        density = "Medium",
        dropDifficulty = "Crystalline Powder is a side gather from Crystallized gathering nodes, so clear all "
            .. "modified ore and herbs in the loop.",
        tips = {
            "Crystallized ore deposits and Irradiated herbs share practical route space in The Ringing Deeps.",
            "Use Perception when rare side-gather value beats raw ore or herb volume.",
            "Clear normal nodes too because modified node spawns rotate through the same route.",
        },
        coords = {
            C(0.353, 0.201, "Crystallized Bismuth north bend"),
            C(0.355, 0.164, "Crystallized ore wall"),
            C(0.360, 0.195, "Crystallized ore return"),
            C(0.368, 0.277, "Crystallized Ironclaw check"),
            C(0.379, 0.188, "Irradiated Orbinid tunnel"),
            C(0.382, 0.314, "Irradiated Orbinid south tunnel"),
            C(0.417, 0.203, "Irradiated herb east tunnel"),
        },
        confidence = "high",
    },
    {
        id = "tww-crystallized-gathering-hallowfall-route",
        source = "Wowhead Crystallized Aqirite and Irradiated Arathor's Spear object map pins",
        sourceUrls = {
            "https://www.wowhead.com/item=213610/crystalline-powder",
            "https://www.wowhead.com/object=413890/crystallized-aqirite",
            "https://www.wowhead.com/object=414339/irradiated-arathors-spear",
            "https://www.wowhead.com/guide/the-war-within/professions/herbalism-overview",
        },
        mapName = "Hallowfall",
        location = "Western and southern modified node checks",
        routeType = "modified-node-loop",
        density = "Medium",
        dropDifficulty = "Side-gather route for Crystalline Powder while still producing Aqirite, Bismuth, and herbs.",
        tips = {
            "Use this when mining and herbalism values are both relevant.",
            "Irradiated Arathor's Spear and Crystallized Aqirite can both appear on Hallowfall route edges.",
            "Treat Crystalline Powder as a bonus, not a guaranteed per-node output.",
        },
        coords = {
            C(0.211, 0.596, "Crystallized Aqirite west Hallowfall"),
            C(0.212, 0.646, "Crystallized ore cliff"),
            C(0.264, 0.531, "Irradiated Arathor's Spear west"),
            C(0.279, 0.490, "Irradiated Spear extension"),
            C(0.394, 0.930, "Southern modified ore pocket"),
            C(0.409, 0.865, "Southern modified node return"),
        },
        confidence = "medium",
    },
}

local LEYLINE_RESIDUE_SPOTS = {
    {
        id = "tww-irradiated-herbs-ringing-deeps-route",
        source = "Wowhead herbalism overview and Irradiated herb object map pins",
        sourceUrls = {
            "https://www.wowhead.com/item=213613/leyline-residue",
            "https://www.wowhead.com/guide/the-war-within/professions/herbalism-overview",
            "https://www.wowhead.com/object=414337/irradiated-orbinid",
            "https://www.wowhead.com/object=414335/irradiated-mycobloom",
        },
        mapName = "The Ringing Deeps",
        location = "Underground Irradiated herb loop",
        routeType = "modified-herb-loop",
        density = "Medium",
        dropDifficulty = "Leyline Residue is a side gather from Irradiated herbs; prioritize dense underground "
            .. "herb pins.",
        tips = {
            "Follow the same northern Ringing Deeps herb loop used for Orbinid and Luredrop checks.",
            "Gather every normal herb nearby because Irradiated spawns replace standard nodes.",
            "Perception can help when the residue price is the route target.",
        },
        coords = {
            C(0.379, 0.188, "Irradiated Orbinid north tunnel"),
            C(0.382, 0.315, "Irradiated Orbinid south pocket"),
            C(0.412, 0.174, "Irradiated herb east wall"),
            C(0.420, 0.188, "Irradiated herb return"),
            C(0.423, 0.314, "Irradiated Orbinid east tunnel"),
        },
        confidence = "high",
    },
    {
        id = "tww-irradiated-herbs-hallowfall-route",
        source = "Wowhead herbalism overview and Irradiated Arathor's Spear object map pins",
        sourceUrls = {
            "https://www.wowhead.com/item=213613/leyline-residue",
            "https://www.wowhead.com/object=414339/irradiated-arathors-spear",
            "https://www.wowhead.com/guide/the-war-within/professions/herbalism-overview",
        },
        mapName = "Hallowfall",
        location = "Western Irradiated Arathor's Spear checks",
        routeType = "modified-herb-loop",
        density = "Medium",
        dropDifficulty = "Targeted side-gather route; residue depends on finding Irradiated herb variants.",
        tips = {
            "Use the western Hallowfall Arathor's Spear route when you specifically want outdoor Irradiated "
                .. "herb checks.",
            "Fold this into broader Hallowfall mining if Crystallized Aqirite is also valuable.",
        },
        coords = {
            C(0.222, 0.618, "Irradiated Arathor's Spear west ridge"),
            C(0.250, 0.557, "Irradiated Spear ridge check"),
            C(0.264, 0.531, "Irradiated Spear west route"),
            C(0.279, 0.490, "Irradiated Spear northern extension"),
            C(0.294, 0.360, "Irradiated Spear far north"),
        },
        confidence = "medium",
    },
}

-- Supplied Retail Routes exports in original vertex order; not tested in a running WoW client.
local function SuppliedOreRoute(id, sortOrder, mapID, mapName, location, routeOrigin, source, packedCoords, tips, sourceUrls)
    local coords = {}
    for index, packed in ipairs(packedCoords) do
        coords[index] = C(math.floor(packed / 10000) / 10000, (packed % 10000) / 10000,
            location .. " #" .. index)
    end
    table.insert(tips, 1, "Supplied route provenance: " .. source)
    return {
        id = id,
        sortOrder = sortOrder,
        mapID = mapID,
        mapName = mapName,
        location = location,
        dropdownLabel = mapName .. ": " .. location,
        routeOrigin = routeOrigin,
        routeType = "mining-loop",
        source = source,
        sourceUrls = sourceUrls,
        tips = tips,
        coords = coords,
        isRoute = true,
        inGameTested = false,
        confidence = "medium",
        dropDifficulty = "Published gathering travel anchors, not guaranteed node spawns. Follow ore terrain and cave elevation.",
    }
end

local SUPPLIED_ORE_ROUTES = {
    ["Bismuth"] = {
        SuppliedOreRoute(
            "tww-bismuth-2214-1-supplied", 1, 2214, "The Ringing Deeps",
            "Main route - The Ringing Deeps", "published-zone-gathering-loop", "xScarlife Gaming zone multifarm export selected for Bismuth; shared gathering geometry, not ore-exclusive nodes.",
            {
                51882478, 60122841, 55154006, 56024831, 58205424, 57626165, 61697218, 66648117,
                66759364, 61829352, 58127771, 53027154, 50126404, 53836266, 51925954, 51015361,
                41863920, 43622918,
            },
            {
                "This is my preferred dedicated Bismuth route because it gives a relatively dense underground/mineral-heavy circuit rather than requiring a huge surface-zone sweep.",
                "Do not limit yourself strictly to plain Bismuth. Mine Rich, Camouflaged and empowered Bismuth because those are where the better yield/skill interactions occur.",
                "Run Phial of Truesight. Camouflaged mining nodes are completely invisible without it. Wowhead",
                "If you have Mining Fundamentals completed enough for mounted gathering, this loop becomes considerably smoother because you avoid repeated mount transitions. WoW Professions",
                "For empowered deposits, a useful TWW mechanic is that you can mine the deposit before using Overload. This is particularly important for Weeping nodes, where overloading first can replace the node. Wowhead",
                "Don't burn time reaching a single awkward high/low node. In the Ringing Deeps, route velocity usually matters more than squeezing every isolated node into a lap.",
            },
            {
                "https://www.wowhead.com/guide/the-war-within/professions/mining-overview?utm_source=chatgpt.com",
                "https://xscarlife-gaming.com/farming-retail/?utm_source=chatgpt.com",
                "https://www.wow-professions.com/guides/mining-specialization-guide-and-build-war-within?utm_source=chatgpt.com",
                "https://www.wowhead.com/guide/the-war-within/professions/mining-overview",
                "https://xscarlife-gaming.com/farming-retail/",
            }
        ),
        SuppliedOreRoute(
            "tww-bismuth-2248-2-supplied", 2, 2248, "Isle of Dorn",
            "Alternative - Isle of Dorn long loop", "published-zone-gathering-loop", "xScarlife Gaming zone multifarm export selected for Bismuth; shared gathering geometry, not ore-exclusive nodes.",
            {
                40872173, 43071785, 47021662, 51481934, 55282769, 60022670, 67442815, 70272019,
                75422150, 75532618, 79232912, 77923593, 80293931, 80564664, 78995014, 76204918,
                73935586, 68995296, 64814922, 63995458, 59925745, 66296539, 68367152, 61617088,
                59797340, 56207263, 53497594, 49347728, 42328426, 35328211, 29977170, 18735948,
                26994579, 32725426, 32396142, 36256643, 41536655, 45946073, 47135348, 41484788,
                42564245, 42493833,
            },
            {
                "Better choice if Ringing Deeps is saturated with gatherers.",
                "Because Bismuth is widespread, Isle of Dorn's very large surface sweep produces a good number of additional spawn opportunities per lap. Wowhead",
                "This is a long route. It works better for uninterrupted 30-60 minute farming sessions than short queue-time farming.",
                "The comparatively open terrain makes spotting minimap nodes and correcting your flight path easier than in some underground zones.",
                "This circuit also intersects good Ironclaw territory, so never skip Ironclaw while farming unless you're specifically benchmarking Bismuth/hour.",
                "Keep Phial of Truesight active to reveal camouflaged Khaz Algar ore nodes.",
            },
            {
                "https://www.wowhead.com/guide/the-war-within/professions/mining-overview?utm_source=chatgpt.com",
                "https://xscarlife-gaming.com/farming-retail/?utm_source=chatgpt.com",
                "https://www.wowhead.com/guide/the-war-within/professions/mining-overview",
                "https://xscarlife-gaming.com/farming-retail/",
            }
        ),
    },
    ["Ironclaw Ore"] = {
        SuppliedOreRoute(
            "tww-ironclaw-ore-2248-1-supplied", 1, 2248, "Isle of Dorn",
            "Main route - Isle of Dorn long loop", "published-zone-gathering-loop", "xScarlife Gaming zone multifarm export selected for Ironclaw Ore; shared gathering geometry, not ore-exclusive nodes.",
            {
                40872173, 43071785, 47021662, 51481934, 55282769, 60022670, 67442815, 70272019,
                75422150, 75532618, 79232912, 77923593, 80293931, 80564664, 78995014, 76204918,
                73935586, 68995296, 64814922, 63995458, 59925745, 66296539, 68367152, 61617088,
                59797340, 56207263, 53497594, 49347728, 42328426, 35328211, 29977170, 18735948,
                26994579, 32725426, 32396142, 36256643, 41536655, 45946073, 47135348, 41484788,
                42564245, 42493833,
            },
            {
                "Treat this as the default Ironclaw route. Method's independent testing specifically selected Isle of Dorn for Ironclaw. Method",
                "Pay particular attention to the outer/coastal portions and rocky elevations instead of blindly cutting through empty central terrain.",
                "The long loop helps avoid reaching the same spawn points before nodes have had a chance to repopulate.",
                "Keep Phial of Truesight active for Camouflaged Ironclaw; otherwise you're leaving an entire node category invisible. Wowhead",
                "Rich Ironclaw is worth deviations substantially more than a plain node sitting far outside your route.",
                "Once your Plethora of Ore → Ironclaw specialization is developed, this route becomes substantially better for quality and Null Stone farming. WoW Professions",
            },
            {
                "https://www.method.gg/guides/the-war-within-mining-profession-leveling-guide?utm_source=chatgpt.com",
                "https://www.wowhead.com/guide/the-war-within/professions/mining-overview?utm_source=chatgpt.com",
                "https://www.wow-professions.com/guides/mining-specialization-guide-and-build-war-within?utm_source=chatgpt.com",
                "https://www.wowhead.com/guide/the-war-within/professions/mining-overview",
                "https://xscarlife-gaming.com/farming-retail/",
            }
        ),
        SuppliedOreRoute(
            "tww-ironclaw-ore-2248-2-supplied", 2, 2248, "Isle of Dorn",
            "Alternative - Isle of Dorn compact loop", "published-zone-gathering-loop", "xScarlife Gaming zone multifarm export selected for Ironclaw Ore; shared gathering geometry, not ore-exclusive nodes.",
            {
                26814527, 32725444, 32226113, 35546574, 38706754, 41636654, 44646222, 48966251,
                56297318, 53357793, 49097706, 46178066, 41938425, 35328199, 31697360, 23856535,
                19506006, 20375637, 23275201,
            },
            {
                "Use this one for 10-20 minute sessions, queues, or if you dislike the very large long-route circuit.",
                "A short loop is more sensitive to competition. If another miner is running roughly the same circuit, switch to the long route.",
                "If node availability falls sharply on the second/third lap, that usually means you're outrunning the local spawn cycle; expanding back to the long route fixes that.",
                "Excellent for testing profession builds because the shorter lap makes ore/hour comparisons easier.",
                "Keep Phial of Truesight active to reveal camouflaged Khaz Algar ore nodes.",
            },
            {
                "https://www.method.gg/guides/the-war-within-mining-profession-leveling-guide?utm_source=chatgpt.com",
                "https://xscarlife-gaming.com/farming-retail/?utm_source=chatgpt.com",
                "https://www.wowhead.com/guide/the-war-within/professions/mining-overview",
                "https://xscarlife-gaming.com/farming-retail/",
            }
        ),
    },
    ["Aqirite"] = {
        SuppliedOreRoute(
            "tww-aqirite-2215-1-supplied", 1, 2215, "Hallowfall",
            "Main route - Hallowfall short V2", "published-zone-gathering-loop", "xScarlife Gaming zone multifarm export selected for Aqirite; shared gathering geometry, not ore-exclusive nodes.",
            {
                57501834, 57042575, 55583052, 61693509, 60203756, 57623537, 54373500, 57903821,
                54864135, 50393910, 52373436, 51373046, 48493266, 45733237, 43442973, 42812511,
                44502263, 44421107, 47391210, 45512603, 48051935, 48481384, 50631517, 50242063,
                52001722, 54311396, 55971425, 53602290,
            },
            {
                "Hallowfall should be your first choice for Aqirite. Method specifically observed good node returns by moving up and down the rivers. Method",
                "Keep your scan wide along riverbanks rather than flying directly over the waterline.",
                "Hallowfall has enough vertical variation that poor flight management can erase the advantage of the route. Method explicitly warns about its verticality. Method",
                "Prioritize Rich/empowered Aqirite when multiple nodes appear at once.",
                "Use Truesight: at high mining skill, Camouflaged Aqirite is also one of the node types that remains useful for profession skill progression. WoW Professions",
                "Don't tunnel-vision Aqirite so hard that you skip nearby Bismuth; Bismuth can still be economically important and often costs almost no additional travel time.",
            },
            {
                "https://www.wowhead.com/guide/the-war-within/professions/mining-overview?utm_source=chatgpt.com",
                "https://xscarlife-gaming.com/farming-retail/?utm_source=chatgpt.com",
                "https://www.method.gg/guides/the-war-within-mining-profession-leveling-guide?utm_source=chatgpt.com",
                "https://www.wow-professions.com/the-war-within/khaz-algar-mining-leveling-guide?utm_source=chatgpt.com",
                "https://www.wowhead.com/guide/the-war-within/professions/mining-overview",
                "https://xscarlife-gaming.com/farming-retail/",
            }
        ),
        SuppliedOreRoute(
            "tww-aqirite-2215-2-supplied", 2, 2215, "Hallowfall",
            "Alternative - Hallowfall “Gathering North” community route", "published-community-gathering-loop", "r/woweconomy Hallowfall Gathering North community export; historical results are not guaranteed yields.",
            {
                44211203, 45551032, 47271138, 46661546, 47002328, 48561719, 48311366, 48911325,
                49571346, 50531431, 50951609, 50342043, 53011834, 53941408, 55721436, 53542334,
                56151908, 56392367, 54892715, 59732881, 55483160, 58203483, 62453372, 60243897,
                56843624, 53573310, 57203931, 55554241, 52963809, 50003757, 52413336, 50743055,
                45253234, 44963179, 43683018, 42622730, 42592520, 42882196, 45312536, 44432272,
                44652146, 45221981, 44821660,
            },
            {
                "This is the route I would test if the standard Hallowfall loops feel overcrowded.",
                "It concentrates more heavily on the northern Hallowfall gathering area instead of doing a generic full-zone circuit.",
                "The original farmer used Phial of Truesight and had very high gathering/deftness performance. Reddit",
                "Their reported session included 16 Null Stones, which makes this particularly interesting as a mining route, although that result is historical and should not be treated as a guaranteed current yield. Reddit",
                "Because this is a community route rather than a generic guide route, I would keep it in your addon as a distinct alternative rather than replacing the main Hallowfall loop.",
            },
            {
                "https://www.wowhead.com/guide/the-war-within/professions/mining-overview?utm_source=chatgpt.com",
                "https://www.reddit.com/r/woweconomy/comments/1fwa64r/120k_from_an_hour_of_gathering_in_hallowfall/",
                "https://www.wowhead.com/guide/the-war-within/professions/mining-overview",
            }
        ),
    },
    ["Desolate Talus"] = {
        SuppliedOreRoute(
            "tww-desolate-talus-2371-1-supplied", 1, 2371, "K'aresh",
            "Main route - K'aresh Mega route", "published-ore-route", "GamingHero dedicated Desolate Talus Mega mining export.",
            {
                47374940, 50794947, 52114784, 53914718, 55474755, 59044356, 60734072, 64283906,
                67083571, 67633318, 68502794, 71322428, 75062388, 77742594, 79173191, 77513869,
                78814412, 80224630, 81094919, 80745231, 78095546, 74075601, 71525889, 69775815,
                65785844, 61235977, 59416168, 57306101, 55136094, 52626653, 52246973, 50566977,
                49216769, 46566614, 46086259, 44175950, 42585537, 46405243,
            },
            {
                "This is the clear main route for dedicated Desolate Talus farming; GamingHero explicitly labels the underlying route as the Mega route for dedicated farming sessions. Gaminghero.io",
                "Hug rocky terrain and the outer corners/edges of the landmasses. GamingHero reports that these are where mining nodes frequently spawn. Gaminghero.io",
                "Don't spend the whole lap down in flat/open terrain just because the route line passes nearby; visually scan elevated rocks.",
                "Source recommendation (camouflaged Desolate deposits unverified): Use Phial of Truesight because hidden gathering nodes materially increase the number of opportunities per circuit. Gaminghero.io",
                "Desolate Talus can also yield K'areshi Resonating Stone, making Perception useful if that secondary drop is part of your gold strategy. Wowhead",
                "The material isn't primarily a normal crafting reagent: it can be exchanged in K'aresh/Tazavesh for the other Khaz Algar ores. Exchange ratios can matter when deciding whether to sell Talus directly or convert it. Wowhead",
            },
            {
                "https://www.wowhead.com/guide/the-war-within/professions/mining-overview?utm_source=chatgpt.com",
                "https://gaminghero.io/best-gathering-routes-patch-11-2/",
                "https://www.wowhead.com/item%3D238212/desolate-talus?utm_source=chatgpt.com",
                "https://www.wowhead.com/guide/the-war-within/professions/mining-overview",
            }
        ),
        SuppliedOreRoute(
            "tww-desolate-talus-2371-2-supplied", 2, 2371, "K'aresh",
            "Alternative - K'aresh Mini route", "published-ore-route", "GamingHero dedicated Desolate Talus Mini mining export.",
            {
                75172390, 77712607, 79073231, 77463852, 78764387, 80294622, 81084922, 80685239,
                77535611, 74525723, 69185786, 67315693, 65935653, 65095501, 65335319, 66475100,
                67914953, 69764836, 70644418, 69624061, 67784052, 65304389, 63024739, 61304866,
                59834455, 60724117, 62553786, 66013679, 66963574, 67673286, 68492776, 71412421,
            },
            {
                "GamingHero specifically designed the source Mini route for short sessions such as while queued for dungeons or battlegrounds. Gaminghero.io",
                "Better than the Mega route when you have only 10-15 minutes.",
                "Its smaller footprint makes it easier to learn individual node-spawn rocks.",
                "Conversely, it is more vulnerable to another miner repeatedly clearing the same area.",
                "If you complete a lap and see very few respawns, switch immediately to the Mega route rather than continuing to chase an exhausted small spawn pool.",
            },
            {
                "https://www.wowhead.com/guide/the-war-within/professions/mining-overview?utm_source=chatgpt.com",
                "https://gaminghero.io/best-gathering-routes-patch-11-2/",
                "https://www.wowhead.com/guide/the-war-within/professions/mining-overview",
            }
        ),
    },
}

local function WithSuppliedRoutes(itemName, existingSpots)
    local spots = {}
    for _, spot in ipairs(SUPPLIED_ORE_ROUTES[itemName] or {}) do
        spots[#spots + 1] = spot
    end
    for _, spot in ipairs(existingSpots or {}) do
        spots[#spots + 1] = spot
    end
    return spots
end

local function RegisterOre(itemID, itemName, qualityRank, summary, spots)
    Register({
        itemID = itemID,
        itemName = itemName,
        expansion = "warWithin",
        professions = { "mining" },
        category = "Ore",
        qualityRank = qualityRank,
        isRoute = true,
        sourceUrls = {
            ItemUrl(itemID),
            "https://www.method.gg/guides/best-mining-and-herbalism-routes-for-the-war-within",
            "https://www.method.gg/guides/the-war-within-mining-profession-leveling-guide",
        },
        summary = summary,
        spots = WithSuppliedRoutes(itemName, spots or H.TWW_MINING_SPOTS),
    })
end

RegisterOre(210930, "Bismuth", 1,
    "Common Khaz Algar ore. Farm by clearing dense War Within mining loops and modified ore variants.")
RegisterOre(210931, "Bismuth", 2,
    "Common Khaz Algar ore. Farm by clearing dense War Within mining loops and modified ore variants.")
RegisterOre(210932, "Bismuth", 3,
    "Common Khaz Algar ore. Farm by clearing dense War Within mining loops and modified ore variants.")

RegisterOre(210933, "Aqirite", 1,
    "Uncommon War Within ore associated with Hallowfall and Azj-Kahet; target the Aqirite-heavy shared mining routes.",
    { H.TWW_MINING_SPOTS[3], H.TWW_MINING_SPOTS[4] })
RegisterOre(210934, "Aqirite", 2,
    "Uncommon War Within ore associated with Hallowfall and Azj-Kahet; target the Aqirite-heavy shared mining routes.",
    { H.TWW_MINING_SPOTS[3], H.TWW_MINING_SPOTS[4] })
RegisterOre(210935, "Aqirite", 3,
    "Uncommon War Within ore associated with Hallowfall and Azj-Kahet; target the Aqirite-heavy shared mining routes.",
    { H.TWW_MINING_SPOTS[3], H.TWW_MINING_SPOTS[4] })

RegisterOre(210936, "Ironclaw Ore", 1,
    "Uncommon War Within ore associated with Isle of Dorn and The Ringing Deeps; target the Ironclaw-heavy routes.",
    { H.TWW_MINING_SPOTS[1], H.TWW_MINING_SPOTS[2] })
RegisterOre(210937, "Ironclaw Ore", 2,
    "Uncommon War Within ore associated with Isle of Dorn and The Ringing Deeps; target the Ironclaw-heavy routes.",
    { H.TWW_MINING_SPOTS[1], H.TWW_MINING_SPOTS[2] })
RegisterOre(210938, "Ironclaw Ore", 3,
    "Uncommon War Within ore associated with Isle of Dorn and The Ringing Deeps; target the Ironclaw-heavy routes.",
    { H.TWW_MINING_SPOTS[1], H.TWW_MINING_SPOTS[2] })

Register({
    itemID = 210939,
    itemName = "Null Stone",
    expansion = "warWithin",
    professions = { "mining", "blacksmithing" },
    category = "Stone",
    sourceUrls = {
        ItemUrl(210939),
        "https://www.wowhead.com/object=413874/rich-bismuth",
        "https://www.wowhead.com/guide/the-war-within/professions/mining-overview",
        "https://www.method.gg/guides/the-war-within-mining-profession-leveling-guide",
    },
    summary = "Rare War Within mining side gather. Rich and modified ore nodes are the practical target, with "
        .. "Bismuth specialization improving Null Stone results.",
    spots = H.TWW_MINING_SPOTS,
})

Register({
    itemID = 213610,
    itemName = "Crystalline Powder",
    expansion = "warWithin",
    professions = { "mining", "herbalism", "blacksmithing" },
    category = "Reagent",
    sourceUrls = {
        ItemUrl(213610),
        "https://www.wowhead.com/object=413883/crystallized-bismuth",
        "https://www.wowhead.com/object=413890/crystallized-aqirite",
        "https://www.wowhead.com/object=413900/crystallized-ironclaw",
        "https://www.wowhead.com/guide/the-war-within/professions/mining-overview",
        "https://www.wowhead.com/guide/the-war-within/professions/herbalism-overview",
    },
    summary = "Side gather from Crystallized mining nodes and related modified gathering nodes; farm dense "
        .. "modified-node loops instead of treating it as a standalone spawn.",
    spots = CRYSTALLIZED_GATHERING_SPOTS,
})

Register({
    itemID = 213613,
    itemName = "Leyline Residue",
    expansion = "warWithin",
    professions = { "herbalism", "blacksmithing", "alchemy" },
    category = "Reagent",
    sourceUrls = {
        ItemUrl(213613),
        "https://www.wowhead.com/guide/the-war-within/professions/herbalism-overview",
        "https://www.wowhead.com/object=414337/irradiated-orbinid",
        "https://www.wowhead.com/object=414339/irradiated-arathors-spear",
    },
    summary = "Side gather from Irradiated herbs; use coordinate-backed Irradiated herb loops in "
        .. "The Ringing Deeps and Hallowfall.",
    spots = LEYLINE_RESIDUE_SPOTS,
})

RegisterOre(238201, "Desolate Talus", 1,
    "K'aresh mining and Resource Market exchange material. Choose the dedicated Mega or Mini route.", {})

RegisterOre(238212, "Desolate Talus", 2,
    "K'aresh mining and Resource Market exchange material. Choose the dedicated Mega or Mini route.", {})

RegisterOre(238213, "Desolate Talus", 3,
    "K'aresh mining and Resource Market exchange material. Choose the dedicated Mega or Mini route.", {})
