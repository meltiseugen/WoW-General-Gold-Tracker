local _, NS = ...
local Register = NS.RegisterMaterialFarmingSpot

local function C(x, y, label)
    return { x = x, y = y, label = label }
end

local function ItemUrl(itemID)
    return "https://www.wowhead.com/item=" .. tostring(itemID)
end

local BASTION_ORE_ROUTE = {
    id = "shadowlands-bastion-solenium-laestrite-ridge-loop",
    source = "Wowhead Shadowlands mining guide and mining route notes",
    sourceUrls = {
        "https://www.wowhead.com/guide/shadowlands-mining-profession",
        "https://www.wow-professions.com/guides/shadowlands-mining-leveling-guide",
    },
    mapName = "Bastion",
    location = "Aspirant's Rest, Hero's Rest, and southern Bastion rocky ridge loop",
    routeType = "mining-loop",
    density = "High for Solenium and Laestrite",
    dropDifficulty = "Easy. Bastion is one of the friendliest Shadowlands mining zones, with open ridges "
        .. "and moderate hostile pressure.",
    tips = {
        "Stay on top of rocky ridges instead of below cliffs because Shadowlands ore favors ridge edges.",
        "Mine every Laestrite and zone ore node because Elethium and stone are bonus results.",
        "The route overlaps with easy herbalism and neutral beast skinning areas.",
    },
    coords = {
        C(0.460, 0.440, "Aspirant's Rest switchback ridge"),
        C(0.536, 0.520, "Hero's Rest ridge line"),
        C(0.612, 0.620, "Southern plateau edge"),
        C(0.548, 0.724, "Purity's Reflection ridge"),
        C(0.414, 0.682, "Western return ridge"),
    },
    confidence = "high",
}

local MALDRAXXUS_ORE_ROUTE = {
    id = "shadowlands-maldraxxus-theater-oxxein-loop",
    source = "Wowhead Shadowlands mining guide and Theater of Pain gatherer reports",
    sourceUrls = {
        "https://www.wowhead.com/guide/shadowlands-mining-profession",
        "https://www.wowhead.com/guide/shadowlands-herbalism-profession",
    },
    mapName = "Maldraxxus",
    location = "Outer Theater of Pain and Glutharn's Decay ridge route",
    routeType = "mining-loop",
    density = "Medium",
    dropDifficulty = "Moderate. Good Oxxein targeting, but mob density and terrain make it slower than Bastion.",
    tips = {
        "Circle the Theater of Pain perimeter for the least painful Oxxein route.",
        "Avoid deep House areas unless you are already clearing mobs for another goal.",
        "This route can pick up Marrowroot and Death Blossom while mining.",
    },
    coords = {
        C(0.446, 0.468, "West Theater ridge"),
        C(0.506, 0.392, "North Theater rim"),
        C(0.584, 0.472, "East Theater ridge"),
        C(0.628, 0.604, "Glutharn's Decay extension"),
        C(0.494, 0.646, "Southern return ridge"),
    },
    confidence = "high",
}

local ARDENWEALD_ORE_ROUTE = {
    id = "shadowlands-ardenweald-phaedrum-cloverleaf-loop",
    source = "Wowhead Shadowlands mining guide and Ardenweald gather route comments",
    sourceUrls = {
        "https://www.wowhead.com/guide/shadowlands-mining-profession",
        "https://www.wowhead.com/guide/shadowlands-herbalism-profession",
    },
    mapName = "Ardenweald",
    location = "Refugee Camp cloverleaf route across root ridges and open forest edges",
    routeType = "mining-loop",
    density = "Medium to high",
    dropDifficulty = "Easy to moderate. Open terrain is good, but nodes can hide behind trees and roots.",
    tips = {
        "Use a cloverleaf around the central camp rather than only the outer zone edge.",
        "Check root-strewn ridges carefully because ore can be visually hidden.",
        "Pair with Vigil's Torch and Death Blossom if dual gathering.",
    },
    coords = {
        C(0.352, 0.518, "Western cloverleaf start"),
        C(0.418, 0.636, "Southwest root ridge"),
        C(0.516, 0.586, "Central camp return"),
        C(0.612, 0.492, "Eastern forest ridge"),
        C(0.542, 0.356, "Northern ridge line"),
    },
    confidence = "high",
}

local REVENDRETH_ORE_ROUTE = {
    id = "shadowlands-revendreth-sinvyr-sanctuary-pridefall-route",
    source = "Wowhead Shadowlands mining guide and Revendreth herb waypoint route reports",
    sourceUrls = {
        "https://www.wowhead.com/guide/shadowlands-mining-profession",
        "https://www.wowhead.com/guide/shadowlands-herbalism-profession",
        "https://www.wow-professions.com/farming/widowbloom-farming",
    },
    mapName = "Revendreth",
    location = "Sanctuary of the Mad to Pridefall Hamlet and Sinfall-side ridges",
    routeType = "mining-loop",
    density = "Medium",
    dropDifficulty = "Moderate. Good Sinvyr targeting, but elevators, walls, and elevation changes slow the loop.",
    tips = {
        "Use the southern half of Revendreth and the western Sinfall ridge pockets.",
        "Avoid dense urban blocks unless a node is directly visible.",
        "The same path works as a Widowbloom and Death Blossom route.",
    },
    coords = {
        C(0.310, 0.527, "Sanctuary approach"),
        C(0.406, 0.682, "Southern lower route"),
        C(0.505, 0.719, "Pridefall road edge"),
        C(0.619, 0.694, "Eastern ridge check"),
        C(0.350, 0.430, "Sinfall-side ridge"),
    },
    confidence = "high",
}

local KORTHIA_ELETHIUM_ROUTE = {
    id = "shadowlands-korthia-elethium-node-loop",
    source = "Wowhead Shadowlands mining guide and Elethium farming guide",
    sourceUrls = {
        "https://www.wowhead.com/guide/shadowlands-mining-profession",
        "https://www.wow-professions.com/farming/elethium-ore-farming",
    },
    mapName = "Korthia",
    location = "Korthia dedicated Elethium node route through ridges and ruins",
    routeType = "elethium-mining-loop",
    density = "Medium",
    dropDifficulty = "Moderate. Korthia is the best targeted Elethium zone, but mobs and terrain can slow "
        .. "ground routes.",
    tips = {
        "Use Korthia when Elethium is the target instead of hoping for rare Laestrite-node results.",
        "Check ridge tops and ruin edges before dropping into lower terrain.",
        "Flying makes this route much smoother once unlocked.",
    },
    coords = {
        C(0.432, 0.348, "Keeper's Respite north ridge"),
        C(0.500, 0.426, "Central ruin edge"),
        C(0.586, 0.544, "Eastern ridge check"),
        C(0.482, 0.662, "Southern return ridge"),
        C(0.354, 0.552, "Western Korthia ridge"),
    },
    confidence = "high",
}

local MAW_ELETHIUM_ROUTE = {
    id = "shadowlands-maw-elethium-edge-route",
    source = "Wowhead Shadowlands mining guide and Elethium farming guide",
    sourceUrls = {
        "https://www.wowhead.com/guide/shadowlands-mining-profession",
        "https://www.wow-professions.com/farming/elethium-ore-farming",
    },
    mapName = "The Maw",
    location = "Maw ridge and ruin checks for dedicated Elethium deposits",
    routeType = "elethium-mining-loop",
    density = "Medium",
    dropDifficulty = "Harder than Korthia because old Maw travel restrictions and hostile density can punish "
        .. "long loops.",
    tips = {
        "Farm this only when you can move through the Maw comfortably.",
        "Dedicated Elethium deposits make it better than covenant zones for targeted Elethium.",
        "Skip long detours into heavy elite areas unless the node is visible.",
    },
    coords = {
        C(0.346, 0.492, "Western ruin edge"),
        C(0.420, 0.386, "Northwest ridge"),
        C(0.514, 0.542, "Central Maw check"),
        C(0.588, 0.644, "Southeast ridge"),
        C(0.474, 0.720, "Southern return edge"),
    },
    confidence = "medium",
}

local ZERETH_MORTIS_PROGENIUM_ROUTE = {
    id = "shadowlands-zereth-mortis-progenium-first-flower-route",
    source = "Retail Wowhead Patch 9.2 mining guide, Wowhead Progenium Deposit object pins, and Artisans of Azeroth Zereth Mortis route string",
    sourceUrls = {
        "https://www.wowhead.com/guide/shadowlands-mining-profession",
        "https://www.wowhead.com/guide/profession-updates-patch-9-2-vestige-of-the-eternal",
        "https://www.wowhead.com/item=187700/progenium-ore",
        "https://www.wowhead.com/object=370400/progenium-deposit",
        "https://artisansofazeroth.com/progenium-ore-frist-flower-route-zereth-mortis/",
    },
    mapName = "Zereth Mortis",
    location = "Northern and northeastern Zereth Mortis Progenium route through Resonant Peaks and desert ridges",
    routeType = "mining-loop",
    density = "Medium for rare Progenium, with Laestrite and Elethium side nodes",
    dropDifficulty = "Moderate. Progenium is rare and concentrated in rugged Zereth Mortis pockets, so clear normal ore while moving.",
    tips = {
        "Use this as a map-route seed for Progenium Ore, then clear every mining node on the loop.",
        "Progenium can be prospected, but Patch 9.2 guides note it does not add new gem types.",
        "The path overlaps First Flower and Progenitor Essentia gathering chances for dual gatherers.",
    },
    coords = {
        C(0.5005, 0.2543, "Artisans route northwestern loop point"),
        C(0.5534, 0.2880, "Artisans route northern ridge"),
        C(0.5814, 0.2962, "Artisans route Resonant Peaks point"),
        C(0.5796, 0.2573, "Northern Progenium route turn"),
        C(0.5944, 0.2443, "Northern ridge object cluster"),
        C(0.6234, 0.2120, "Wowhead object and Artisans route overlap"),
        C(0.6551, 0.2140, "Northeastern route point"),
        C(0.6719, 0.2668, "Northeast Progenium object cluster"),
        C(0.6660, 0.2997, "Eastern route descent"),
        C(0.6459, 0.2925, "Eastern return object cluster"),
        C(0.6286, 0.3083, "Central-eastern route point"),
        C(0.6171, 0.3441, "Southern ridge return"),
        C(0.6630, 0.3513, "Southeastern loop point"),
        C(0.6931, 0.3355, "Eastern Progenium object pin"),
        C(0.6723, 0.3943, "Southeast return ridge"),
        C(0.6457, 0.4186, "Southern route bend"),
        C(0.6434, 0.3795, "Eastern ridge return"),
        C(0.5964, 0.3578, "Central return"),
    },
    confidence = "high",
}

-- Decoded from the supplied Retail Routes payloads, preserving every point in order.
-- Provenance labels describe the attachment; published/derived paths are not game-tested here.
local function SuppliedMiningRoute(id, sortOrder, mapID, mapName, location, sourceStatus, source, packedCoords, tips, sourceUrls)
    local coords = {}
    for index, packed in ipairs(packedCoords) do
        coords[index] = C(math.floor(packed / 10000) / 10000, (packed % 10000) / 10000,
            location .. " #" .. index)
    end
    local repairNotes
    if sourceStatus == "repaired" then
        repairNotes = "The supplied Ardenweald payload corrects RouteZone from 2022 (The Waking Shores) to 1565 (Ardenweald); the complete replacement block is used."
    end
    return {
        id = id,
        sortOrder = sortOrder,
        mapID = mapID,
        mapName = mapName,
        location = location,
        dropdownLabel = mapName .. ": " .. sortOrder .. ". " .. location .. " (" .. sourceStatus .. ")",
        routeType = "mining-loop",
        sourceStatus = sourceStatus,
        source = "User-supplied route: " .. source,
        sourceUrls = sourceUrls,
        repairNotes = repairNotes,
        dropDifficulty = (repairNotes or ("Supplied " .. sourceStatus .. " route; waypoints are route vertices, not guaranteed ore deposits."))
            .. " Not tested in game.",
        tips = tips,
        coords = coords,
        confidence = sourceStatus == "derived" and "low" or "medium",
        inGameTested = false,
        isRoute = true,
    }
end

local SUPPLIED_MINING_ROUTES = {
    [171828] = {
        SuppliedMiningRoute(
            "shadowlands-laestrite-ore-main-route-bastion-1533-supplied", 1,
            1533, "Bastion", "Main route — Bastion / 1533",
            "published", "PUBLISHED — Golden Routes / Artisans of Azeroth",
            {
                59951144, 57771452, 54111599, 54961873, 51172330, 52452581, 55072257, 56292455,
                53572791, 56043182, 59513761, 61253629, 61503114, 64163251, 65422995, 66203308,
                64283813, 61644160, 61214537, 62934873, 60474998, 60035485, 57275191, 55375006,
                54794797, 53484459, 49534446, 47794099, 44304450, 42174187, 45263762, 53113327,
                51712759, 48502550, 48971985, 50281742, 49441419, 53681405, 56581009,
            },
            {
                "Bastion is one of the least annoying Shadowlands zones for continuous mining because much of this loop runs through relatively open terrain with comparatively low mob interference.",
                "Mine Solenium Ore at the same time. There is effectively no reason to ignore it while targeting Laestrite.",
                "This is a medium-length ~39-point loop rather than an enormous perimeter route, so node respawn can catch up reasonably well during repeated laps.",
                "With flying unlocked, cut directly between elevations instead of following the original ground-path assumptions.",
                "This same published route was designed as a combined gathering route, which is why its internal route name may not say “Laestrite”; that does not affect import into Routes.",
            },
            {
                "https://artisansofazeroth.com/materials/laestrite-ore/",
                "https://artisansofazeroth.com/laestrite-ore-farming/",
                "https://www.wowhead.com/item=171828",
            }
        ),
        SuppliedMiningRoute(
            "shadowlands-laestrite-ore-alternative-revendreth-1525-supplied", 2,
            1525, "Revendreth", "Alternative — Revendreth / 1525",
            "published", "PUBLISHED mining loop — GoldGoblin; repurposed for Laestrite",
            {
                32703272, 34883266, 35533281, 36143363, 35973483, 35193582, 34533976, 34204634,
                35245174, 36765368, 38275562, 40985655, 42515827, 43145992, 44035999, 44745926,
                45315832, 47355841, 48925961, 50956060, 53145933, 55385746, 58105558, 61515295,
                63015375, 65245584, 68375687, 69605947, 69776143, 69226360, 68436568, 67506684,
                61706936, 58727270, 56607445, 53837344, 52147189, 50177071, 48817330, 46897542,
                45947626, 45077879, 44308044, 43208213, 41398284, 39968336, 38338347, 37588237,
                37238116, 37807809, 38057710, 38507661, 38597543, 39337370, 40297204, 41917146,
                43547107, 43807006, 42816975, 40996911, 40076676, 37356479, 34046315, 32706058,
                30385801, 26884700, 26014233, 26093848,
            },
            {
                "Use this when you want Laestrite + Sinvyr rather than Laestrite + Solenium.",
                "GoldGoblin's route consists effectively of two connected loops. You don't have to run the entire thing every lap.",
                "The right/eastern portion is the easier sub-loop from a mob-interference perspective.",
                "Revendreth's vertical terrain makes flying disproportionately valuable compared with Bastion.",
                "If Sinvyr has substantially more AH value than Solenium on your realm/region, this may produce better combined gold/hour than the Bastion route even when raw Laestrite/hour is similar.",
            },
            {
                "https://artisansofazeroth.com/materials/laestrite-ore/",
                "https://www.goldgoblin.net/farmspots/sinvyrerz-farmen/",
                "https://www.wowhead.com/item=171828",
            }
        ),
    },
    [171829] = {
        SuppliedMiningRoute(
            "shadowlands-solenium-ore-main-route-bastion-1533-supplied", 1,
            1533, "Bastion", "Main route — Bastion / 1533",
            "published", "PUBLISHED — Golden Routes / Artisans",
            {
                59951144, 57771452, 54111599, 54961873, 51172330, 52452581, 55072257, 56292455,
                53572791, 56043182, 59513761, 61253629, 61503114, 64163251, 65422995, 66203308,
                64283813, 61644160, 61214537, 62934873, 60474998, 60035485, 57275191, 55375006,
                54794797, 53484459, 49534446, 47794099, 44304450, 42174187, 45263762, 53113327,
                51712759, 48502550, 48971985, 50281742, 49441419, 53681405, 56581009,
            },
            {
                "Recommended default Solenium route.",
                "It covers Bastion's productive central/northern mining terrain without making the lap unnecessarily huge.",
                "Bastion has relatively open terrain and fewer forced pulls than Maldraxxus or Revendreth.",
                "Collect Laestrite on every lap; both ores share this mining circuit.",
                "Because the route is shorter than the GoldGoblin alternative, it is preferable when the zone is quiet and nodes are respawning normally.",
            },
            {
                "https://artisansofazeroth.com/solenium-ore-farming/",
                "https://www.wowhead.com/item=171829",
            }
        ),
        SuppliedMiningRoute(
            "shadowlands-solenium-ore-alternative-large-bastion-loop-1533-supplied", 2,
            1533, "Bastion", "Alternative — large Bastion loop / 1533",
            "published", "PUBLISHED — GoldGoblin",
            {
                53373626, 54663586, 55793588, 56883652, 58203657, 59613765, 60933815, 62093739,
                62633623, 62873482, 64743438, 65903521, 65613685, 64933807, 64253930, 63574052,
                62644140, 61704227, 60874349, 60844541, 61134728, 61954915, 62635042, 62435209,
                61295263, 60445383, 59615480, 57695362, 56665414, 56085542, 54995694, 54035847,
                53116071, 53006269, 53126445, 53356606, 53876710, 54356744, 54646646, 55216534,
                56546516, 57496579, 58216730, 58206838, 57506889, 55946989, 54767089, 53357155,
                52067281, 50867336, 50047380, 49177203, 48577121, 48297026, 48736926, 49176826,
                49506684, 48676581, 47716585, 47026703, 45776870, 45326985, 45457143, 46127256,
                46557410, 45707485, 44477448, 42627195, 40767100, 39146980, 37366885, 36546796,
                37016639, 40216569, 41616651, 42696616, 42996455, 42176412, 41426361, 40296415,
                38346430, 37466363, 38246299, 39266305, 41676236, 43346054, 44446004, 45275843,
                45955705, 47215601, 48215476, 49205351, 49555100, 48404960, 46715064, 45185268,
                43975343, 42955284, 41495115, 39875087, 39835012, 40164936, 39944779, 38924736,
                38224789, 38054948, 37255090, 36075144, 34525028, 33394860, 33534712, 34414540,
                35464447, 36404507, 37764613, 38264688, 38934599, 40174305, 40644111, 42454077,
                43893967, 45413787, 46643833, 49263692, 51513691,
            },
            {
                "The huge coverage makes this particularly useful when other farmers are clearing the obvious shorter loops.",
                "It takes much longer to complete one lap, so node respawning is less likely to become your bottleneck.",
                "Flying is strongly preferable because the value of this route is its coverage, not a minimal travel distance.",
                "Collect every Laestrite node encountered rather than filtering only Solenium.",
            },
            {
                "https://artisansofazeroth.com/solenium-ore-farming/",
                "https://www.goldgoblin.net/farmspots/soleniumerz-farmen/",
                "https://www.wowhead.com/item=171829",
            }
        ),
    },
    [171830] = {
        SuppliedMiningRoute(
            "shadowlands-oxxein-ore-main-route-maldraxxus-1536-supplied", 1,
            1536, "Maldraxxus", "Main route — Maldraxxus / 1536",
            "published", "PUBLISHED — GoldGoblin",
            {
                69135305, 64954996, 62954789, 60814628, 58304500, 56184099, 52333856, 49583869,
                48443978, 47333967, 46853831, 46883560, 40363015, 45522727, 46712496, 47682458,
                49002362, 50432190, 51501919, 53632001, 54082370, 54352655, 55352982, 56813140,
                58573281, 60333298, 61323263, 62233291, 64043137, 65322965, 65052741, 65812534,
                67642489, 70312799, 72033067, 71573253, 69733264, 68013132, 66563014, 65093034,
                63263217, 63033330, 63733463, 64033595, 65443696, 66453796, 73094244, 75494399,
                75894715, 75145019, 74225231, 72595430,
            },
            {
                "This is the more comprehensive Oxxein circuit.",
                "Maldraxxus has tightly packed enemies along parts of the route, so flying substantially reduces interruptions.",
                "One part of the old recommended path also contains stealth-detecting mobs; don't rely solely on stealth as your avoidance strategy.",
                "Skip a node rather than forcing a landing into a large pack—the route has enough additional spawn points that a single skipped node is rarely worth the combat downtime.",
                "Gather Laestrite simultaneously.",
            },
            {
                "https://www.goldgoblin.net/farmspots/oxxeinerz-farmen/",
                "https://www.wowhead.com/item=171830",
            }
        ),
        SuppliedMiningRoute(
            "shadowlands-oxxein-ore-alternative-compact-maldraxxus-loop-1536-supplied", 2,
            1536, "Maldraxxus", "Alternative — compact Maldraxxus loop / 1536",
            "published", "PUBLISHED — Golden Routes / Artisans",
            {
                48142483, 46022902, 44263406, 47543753, 46104069, 45224318, 43834613, 42544880,
                43904984, 45565226, 40035536, 42325112, 39155114, 36145258, 32265728, 30535968,
                28725765, 28746113, 27205776, 25455981, 25795200, 27555166, 28714983, 30795072,
                31545193, 32644839, 36334881, 37074607, 38874047, 37263662, 35633655, 35453961,
                33913938, 33523641, 35413573, 37213220, 37642902, 38643271, 40453279, 41663285,
                42873387, 42502904, 41362782, 42252707, 45262457,
            },
            {
                "This circuit is substantially tighter than the GoldGoblin route.",
                "Use it when the zone is quiet and you want a short, repeatable lap.",
                "If you begin reaching previously mined locations before nodes have respawned, swap to the longer route above.",
                "The internal name is Marrowroot because the source route was built for combined gathering; the coordinates remain useful for mining and RouteZone=1536 is correct.",
            },
            {
                "https://www.goldgoblin.net/farmspots/oxxeinerz-farmen/",
                "https://artisansofazeroth.com/oxxein-ore-farming/",
                "https://www.wowhead.com/item=171830",
            }
        ),
    },
    [171831] = {
        SuppliedMiningRoute(
            "shadowlands-phaedrum-ore-main-route-central-ardenweald-1565-supplied", 1,
            1565, "Ardenweald", "Main route — central Ardenweald / 1565",
            "published", "PUBLISHED — Golden Routes / Artisans",
            {
                52204759, 56314917, 57935562, 56226395, 49216313, 48506631, 47087124, 43867652,
                43146676, 40366212, 38245770, 40885259, 37754953, 36844398, 33294318, 33533947,
                30523834, 34613580, 30393443, 37582784, 42583076, 45683482, 40624066, 43374148,
                40604516, 46324148, 50514266,
            },
            {
                "The route intentionally favors the central/heart area of Ardenweald, where the original guide found less mob interference.",
                "Good default when optimizing actual gathering uptime rather than raw geographical coverage.",
                "It is only 27 points, so it works particularly well as a fast repeat circuit.",
                "If you consistently outrun node respawns, move to the larger alternative below.",
                "Gather Laestrite at the same time.",
            },
            {
                "https://www.goldgoblin.net/farmspots/phaedrumerz-farmen/",
                "https://artisansofazeroth.com/phaedrum-ore-farming/",
                "https://www.wowhead.com/item=171831",
            }
        ),
        SuppliedMiningRoute(
            "shadowlands-phaedrum-ore-alternative-large-ardenweald-loop-1565-supplied", 2,
            1565, "Ardenweald", "Alternative — large Ardenweald loop / 1565",
            "repaired", "REPAIRED PUBLISHED PAYLOAD — GoldGoblin",
            {
                29393618, 29393424, 30453290, 32423260, 36773217, 42693192, 44243202, 45743261,
                47713220, 48863061, 49042682, 50072518, 56632508, 59562704, 61202740, 63962556,
                65272503, 66422616, 66132995, 63733030, 61203145, 59583374, 58623796, 54984084,
                53904642, 51775180, 49895480, 50056092, 51526464, 52826546, 54256490, 56526001,
                57865492, 56714831, 57614526, 62544206, 65623994, 67733778, 68943862, 66014247,
                64794691, 66525136, 68245283, 68905518, 68125621, 66155645, 63915573, 61155667,
                59055922, 55776632, 54206865, 53447232, 53187417, 52267562, 50817674, 49637562,
                48317517, 47297426, 47737342, 49297234, 49757038, 49356864, 48156754, 46306810,
                45507022, 44037067, 42456897, 41196717, 40116713, 38376818, 37026972, 36446864,
                37186615, 38776404, 40376163, 40005978, 39015784, 37645765, 36545726, 35135886,
                33756007, 32595992, 31675883, 30745775, 28295369, 27225111, 27054913, 27524734,
                28984675, 33244643, 33634875, 35335174, 36725219, 36605010, 38344672, 38654470,
                37424284, 35884268, 34924159, 34733961, 34213782, 33173681, 31613757, 30213771,
                38202875, 38054948, 37255090, 36075144, 34525028, 33394860, 33534712, 34414540,
                35464447, 36404507, 37764613, 38264688, 38934599, 40174305, 40644111, 42454077,
                43893967, 45413787, 46643833, 49263692, 51513691,
            },
            {
                "This is a much larger circuit and is better suited to flying.",
                "Use it when the short central Ardenweald route is being contested or you're completing laps faster than nodes return.",
                "The value is broad spawn coverage rather than minimal distance.",
                "This repaired legacy route uses Ardenweald map ID 1565; the supplied correction replaces the original map ID 2022.",
            },
            {
                "https://www.goldgoblin.net/farmspots/phaedrumerz-farmen/",
                "https://www.wowhead.com/item=171831",
            }
        ),
    },
    [171832] = {
        SuppliedMiningRoute(
            "shadowlands-sinvyr-ore-main-route-large-revendreth-circuit-1525-supplied", 1,
            1525, "Revendreth", "Main route — large Revendreth circuit / 1525",
            "published", "PUBLISHED — GoldGoblin",
            {
                32703272, 34883266, 35533281, 36143363, 35973483, 35193582, 34533976, 34204634,
                35245174, 36765368, 38275562, 40985655, 42515827, 43145992, 44035999, 44745926,
                45315832, 47355841, 48925961, 50956060, 53145933, 55385746, 58105558, 61515295,
                63015375, 65245584, 68375687, 69605947, 69776143, 69226360, 68436568, 67506684,
                61706936, 58727270, 56607445, 53837344, 52147189, 50177071, 48817330, 46897542,
                45947626, 45077879, 44308044, 43208213, 41398284, 39968336, 38338347, 37588237,
                37238116, 37807809, 38057710, 38507661, 38597543, 39337370, 40297204, 41917146,
                43547107, 43807006, 42816975, 40996911, 40076676, 37356479, 34046315, 32706058,
                30385801, 26884700, 26014233, 26093848,
            },
            {
                "This is really two loops connected into one route.",
                "GoldGoblin notes that they can be run separately or together, which is useful when competition is concentrated on one side of the zone.",
                "The right/green-side loop is the safer one if you want less mob interference.",
                "For maximum mining coverage, run both halves.",
                "Revendreth's cliffs make flying particularly important.",
                "Pick up Laestrite as a secondary material.",
            },
            {
                "https://www.goldgoblin.net/farmspots/sinvyrerz-farmen/",
                "https://www.wowhead.com/item=171832",
            }
        ),
        SuppliedMiningRoute(
            "shadowlands-sinvyr-ore-alternative-compact-lower-revendreth-1525-supplied", 2,
            1525, "Revendreth", "Alternative — compact lower Revendreth / 1525",
            "published", "PUBLISHED — Golden Routes / Artisans",
            {
                39746813, 43556626, 44986426, 45326143, 48246189, 50596299, 49326466, 50866661,
                54547186, 55377569, 50867193, 47597147, 44857426, 45017100,
            },
            {
                "This is a very compact 14-point circuit.",
                "Lower Revendreth is the important part—the historical farming guides note that ore becomes much less useful/scarce in much of the upper terrain.",
                "Short loops are excellent when node density is high and competition is low.",
                "If nodes don't respawn by the next lap, switch immediately to the 68-point GoldGoblin circuit rather than waiting.",
                "The payload's internal name is Widowbloom, again because it originated as a combined-gathering route.",
            },
            {
                "https://artisansofazeroth.com/sinvyr-ore-farming/",
                "https://www.wowhead.com/item=171832",
            }
        ),
    },
    [171833] = {
        SuppliedMiningRoute(
            "shadowlands-elethium-ore-main-route-the-maw-1543-supplied", 1,
            1543, "The Maw", "Main route — The Maw / 1543",
            "published", "PUBLISHED — GoldGoblin",
            {
                26622361, 28332180, 30581832, 29931658, 29271573, 29401461, 30531539, 31681677,
                32721983, 34492394, 34982610, 36622906, 39093905, 40984008, 42804161, 43294348,
                42644536, 40344749, 36814776, 33264621, 31164584, 29654733, 27644838, 26574920,
                25494902, 25294714, 26674508, 28824350, 31333963, 31343791, 29403590, 26843640,
                24503801, 22624141, 20863959, 19293518, 22003232, 23422911, 24322829, 25112907,
                26423193, 27083198, 26813023, 26022816, 24972525,
            },
            {
                "This is the proper dedicated Elethium route from the original Shadowlands zones.",
                "The Maw historically had dramatically better Elethium reliability than Bastion/Maldraxxus/Ardenweald/Revendreth.",
                "Don't waste time fighting for a badly positioned node; the circuit contains enough spawn locations to keep moving.",
                "This route predates Zereth Mortis, so for modern old-content farming I would benchmark it against the ZM alternative below rather than automatically assuming it remains the best gold/hour.",
            },
            {
                "https://www.goldgoblin.net/farmspots/elethiumerz-farmen/",
                "https://www.wowhead.com/item=171833",
            }
        ),
        SuppliedMiningRoute(
            "shadowlands-elethium-ore-alternative-1-resonant-peaks-zereth-mortis-1970-supplied", 2,
            1970, "Zereth Mortis", "Alternative #1 — Resonant Peaks, Zereth Mortis / 1970",
            "derived", "DERIVED",
            {
                47502650, 49002300, 52002150, 55202380, 56502750, 55503100, 53003320, 49803350,
                47203050,
            },
            {
                "Run this when you want Elethium + Progenium simultaneously.",
                "The route concentrates around Resonant Peaks instead of circling the entire Zereth Mortis map.",
                "Elusive nodes can appear on top of rocks/structures, so vertical mobility is useful.",
                "If the nine-point circuit respawns too slowly, use the broader Progenium NE route under item #7 instead.",
                "This is not a copied route string; the payload was generated from the published hotspot/coordinate information and validated against the Routes serialization format.",
            },
            {
                "https://www.goldgoblin.net/farmspots/elethiumerz-farmen/",
                "https://www.wowhead.com/ptr-2/item%3D171833/elethium-ore",
                "https://www.wowhead.com/guide/shadowlands-mining-profession",
                "https://www.wowhead.com/item=171833",
            }
        ),
        SuppliedMiningRoute(
            "shadowlands-elethium-ore-alternative-2-maldraxxus-1536-supplied", 3,
            1536, "Maldraxxus", "Alternative #2 — Maldraxxus / 1536",
            "published", "PUBLISHED — Golden Routes / Artisans; low-yield Elethium fallback",
            {
                41306675, 41087278, 39587343, 35647205, 33716523, 35576317, 36696526, 38266229,
            },
            {
                "Use this as an Elethium fallback, not the default dedicated farm.",
                "It is interesting as an obscure fallback because it is an actual published route, but Elethium occurrence outside its dedicated zones is much less reliable.",
                "Treat Elethium as a bonus here while primarily farming Oxxein + Laestrite.",
                "Low Elethium chance / Oxxein cross-farm.",
            },
            {
                "https://www.goldgoblin.net/farmspots/elethiumerz-farmen/",
                "https://artisansofazeroth.com/elethium-ore-farming/",
                "https://www.wowhead.com/item=171833",
            }
        ),
    },
    [187700] = {
        SuppliedMiningRoute(
            "shadowlands-progenium-ore-main-route-north-northeast-zereth-mortis-1970-supplied", 1,
            1970, "Zereth Mortis", "Main route — North / Northeast Zereth Mortis / 1970",
            "derived", "DERIVED — broad 19-point route",
            {
                48503100, 50502700, 52002250, 55501850, 59801800, 63502050, 65502500, 64802980,
                61803300, 58003550, 55803880, 58504200, 60804580, 60204920, 57404700, 55004300,
                52503900, 49803600, 47503400,
            },
            {
                "Recommended main Progenium route.",
                "The northern half around the Dread Portal is the important section; the southern extension prevents the loop from becoming too short while picking up additional Zereth Mortis mining spawns.",
                "Mine Elethium too. The two materials overlap here and ignoring Elethium would reduce gold/hour.",
                "Check elevated rocks, structures and floating terrain for Elusive deposits instead of assuming the minimap marker is at ground level.",
                "If the southern half consistently produces little, shorten the route around roughly 48–66 X / 18–38 Y.",
                "GoldGoblin specifically marks some northern areas as mob-heavy, so with weak/low-level farming characters it can be more efficient to skirt those pockets instead of landing on every node.",
            },
            {
                "https://www.goldgoblin.net/farmspots/progeniumerz-farmen/",
                "https://www.wowhead.com/item=187700",
            }
        ),
        SuppliedMiningRoute(
            "shadowlands-progenium-ore-alternative-resonant-peaks-1970-supplied", 2,
            1970, "Zereth Mortis", "Alternative — Resonant Peaks / 1970",
            "derived", "DERIVED — tight 9-point route",
            {
                47502650, 49002300, 52002150, 55202380, 56502750, 55503100, 53003320, 49803350,
                47203050,
            },
            {
                "Use this as the high-density short-loop alternative.",
                "It focuses specifically on the Resonant Peaks/northern mining cluster rather than trying to cover Zereth Mortis.",
                "Particularly attractive because Elusive Rich Elethium has also been reported around ~51,28, creating a good dual-material farm.",
                "If you complete laps before respawns, switch to the 19-point route rather than extending this loop randomly.",
                "Mobility abilities remain useful for deposits spawning above normal ground level.",
            },
            {
                "https://www.goldgoblin.net/farmspots/progeniumerz-farmen/",
                "https://www.wowhead.com/ptr-2/item%3D171833/elethium-ore",
                "https://www.wowhead.com/item=187700",
            }
        ),
    },
}

local function WithSuppliedRoutes(itemID, legacySpots)
    local spots = {}
    for _, spot in ipairs(SUPPLIED_MINING_ROUTES[itemID] or {}) do
        spots[#spots + 1] = spot
    end
    for _, spot in ipairs(legacySpots) do
        spots[#spots + 1] = spot
    end
    return spots
end

local function RegisterOre(itemID, itemName, spots, summary, category)
    Register({
        itemID = itemID,
        itemName = itemName,
        expansion = "shadowlands",
        professions = { "mining" },
        category = category or "Ore",
        isRoute = category == nil,
        sourceUrls = { ItemUrl(itemID) },
        summary = summary,
        spots = WithSuppliedRoutes(itemID, spots),
    })
end

RegisterOre(171828, "Laestrite Ore", {
    BASTION_ORE_ROUTE,
    ARDENWEALD_ORE_ROUTE,
    REVENDRETH_ORE_ROUTE,
}, "Common Shadowlands ore from all four covenant zones; Bastion and Ardenweald are the easiest general "
    .. "routes.")
RegisterOre(171829, "Solenium Ore", { BASTION_ORE_ROUTE },
    "Bastion zone ore found from Solenium deposits and rich deposits.")
RegisterOre(171830, "Oxxein Ore", { MALDRAXXUS_ORE_ROUTE },
    "Maldraxxus zone ore best targeted around Theater of Pain ridges.")
RegisterOre(171831, "Phaedrum Ore", { ARDENWEALD_ORE_ROUTE },
    "Ardenweald zone ore from forest ridge routes.")
RegisterOre(171832, "Sinvyr Ore", { REVENDRETH_ORE_ROUTE },
    "Revendreth zone ore from southern and Sinfall-side ridge routes.")
RegisterOre(171833, "Elethium Ore", {
    KORTHIA_ELETHIUM_ROUTE,
    MAW_ELETHIUM_ROUTE,
}, "Rare covenant-zone ore, best target-farmed from dedicated deposits in Korthia and The Maw.")
RegisterOre(171840, "Porous Stone", {
    BASTION_ORE_ROUTE,
    MALDRAXXUS_ORE_ROUTE,
    ARDENWEALD_ORE_ROUTE,
    REVENDRETH_ORE_ROUTE,
}, "Common Shadowlands stone side material from mining covenant-zone deposits.", "Stone")
RegisterOre(171841, "Shaded Stone", {
    BASTION_ORE_ROUTE,
    REVENDRETH_ORE_ROUTE,
    KORTHIA_ELETHIUM_ROUTE,
    ZERETH_MORTIS_PROGENIUM_ROUTE,
}, "Shadowlands stone side material gathered through mining and used by blacksmithing.", "Stone")
RegisterOre(187700, "Progenium Ore", { ZERETH_MORTIS_PROGENIUM_ROUTE },
    "Patch 9.2 Zereth Mortis ore from rare Progenium deposits, rich deposits, and rugged northern/eastern mining loops.")
