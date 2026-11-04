local _, NS = ...
local Register = NS.RegisterMaterialFarmingSpot

local function C(x, y, label)
    return { x = x, y = y, label = label }
end

local function ItemUrl(itemID)
    return "https://www.wowhead.com/item=" .. tostring(itemID)
end

local BASTION_HERB_ROUTE = {
    id = "shadowlands-bastion-rising-glory-route",
    source = "Wowhead Shadowlands herbalism guide and Shadowlands route comments",
    sourceUrls = {
        "https://www.wowhead.com/guide/shadowlands-herbalism-profession",
        "https://www.wow-professions.com/guides/shadowlands-herbalism-leveling-guide",
    },
    mapName = "Bastion",
    location = "Bastion open terrain herb route through Shimmering Pools, Hero's Rest, and Purity's Reflection",
    routeType = "herbalism-loop",
    density = "High for Rising Glory and Death Blossom",
    dropDifficulty = "Easy. Bastion is one of the friendliest Shadowlands herb zones.",
    tips = {
        "Use Bastion when you want the easiest Death Blossom and Nightshade side chances.",
        "Sky Golem or a gathering-speed glove enchant reduces dismount pain.",
        "The route pairs well with Bastion ore ridges.",
    },
    coords = {
        C(0.420, 0.320, "Shimmering Pools herbs"),
        C(0.464, 0.454, "Aspirant's Rest fields"),
        C(0.536, 0.522, "Hero's Rest herb line"),
        C(0.612, 0.482, "Eastern open fields"),
        C(0.530, 0.730, "Purity's Reflection water edge"),
    },
    confidence = "high",
}

local MALDRAXXUS_HERB_ROUTE = {
    id = "shadowlands-maldraxxus-theater-marrowroot-route",
    source = "Wowhead Shadowlands herbalism guide and Theater of Pain farming comment",
    sourceUrls = {
        "https://www.wowhead.com/guide/shadowlands-herbalism-profession",
        "https://www.wow-professions.com/farming/marrowroot-farming",
    },
    mapName = "Maldraxxus",
    location = "Theater of Pain circuits and House of Plagues side checks",
    routeType = "herbalism-loop",
    density = "Medium",
    dropDifficulty = "Moderate because Maldraxxus has more hostile pressure than Bastion.",
    tips = {
        "Circle Theater of Pain for Marrowroot while also checking Death Blossom and Oxxein.",
        "Avoid deep House interiors unless already farming mobs.",
        "Use this route only when Marrowroot is the target value.",
    },
    coords = {
        C(0.500, 0.530, "Theater of Pain central circuit"),
        C(0.440, 0.454, "West Theater herb checks"),
        C(0.530, 0.392, "North Theater return"),
        C(0.610, 0.506, "East Theater herb line"),
        C(0.580, 0.760, "House of Plagues water edge"),
    },
    confidence = "high",
}

local ARDENWEALD_HERB_ROUTE = {
    id = "shadowlands-ardenweald-vigils-torch-waypoint-route",
    source = "Wowhead Shadowlands herbalism guide and Ardenweald TomTom waypoint comment",
    sourceUrls = {
        "https://www.wowhead.com/guide/shadowlands-herbalism-profession",
        "https://www.wow-professions.com/farming/vigils-torch-farming",
    },
    mapName = "Ardenweald",
    location = "Ardenweald waypoint loop through Tirna Noch and central forest edges",
    routeType = "herbalism-loop",
    density = "Medium to high",
    dropDifficulty = "Moderate. Good density, but trees and roots can hide nodes.",
    tips = {
        "Use the published Ardenweald waypoint chain as the backbone of the route.",
        "Vigil's Torch and Death Blossom share a strong loop here.",
        "Nightshade is still rare, so treat it as bonus value.",
    },
    coords = {
        C(0.351, 0.518, "Western route start"),
        C(0.393, 0.634, "Southwest waypoint cluster"),
        C(0.491, 0.676, "Southern forest return"),
        C(0.516, 0.585, "Central forest checks"),
        C(0.608, 0.363, "Northern waypoint cluster"),
    },
    confidence = "high",
}

local REVENDRETH_HERB_ROUTE = {
    id = "shadowlands-revendreth-widowbloom-waypoint-route",
    source = "Wowhead Shadowlands herbalism guide, Revendreth TomTom waypoint comment, and Widowbloom guide",
    sourceUrls = {
        "https://www.wowhead.com/guide/shadowlands-herbalism-profession",
        "https://www.wow-professions.com/farming/widowbloom-farming",
    },
    mapName = "Revendreth",
    location = "Sanctuary of the Mad, lower Revendreth, and Sinfall-side Widowbloom loops",
    routeType = "herbalism-loop",
    density = "Medium",
    dropDifficulty = "Moderate to hard. Elevators, walls, and elite pockets can slow the path.",
    tips = {
        "Follow lower Revendreth and Sinfall-side waypoint clusters rather than the dense towns.",
        "Use the alternate Sinfall loop if the main lower route is crowded.",
        "Watch for Endmire damage and elevator delays.",
    },
    coords = {
        C(0.310, 0.527, "Sanctuary of the Mad start"),
        C(0.382, 0.650, "Lower Revendreth herb line"),
        C(0.505, 0.719, "Pridefall route center"),
        C(0.584, 0.645, "Eastern lower route"),
        C(0.350, 0.430, "Sinfall alternate loop"),
    },
    confidence = "high",
}

local ZERETH_MORTIS_FIRST_FLOWER_ROUTE = {
    id = "shadowlands-zereth-mortis-first-flower-progenium-route",
    source = "Retail Wowhead Patch 9.2 herbalism guide, Wowhead First Flower object pins, and Artisans of Azeroth Zereth Mortis route string",
    sourceUrls = {
        "https://www.wowhead.com/guide/profession-updates-patch-9-2-vestige-of-the-eternal",
        "https://www.wowhead.com/guide/profession-changes-patch-92-eternitys-end-shadowlands",
        "https://www.wowhead.com/item=187699/first-flower",
        "https://www.wowhead.com/object=370398/first-flower",
        "https://artisansofazeroth.com/progenium-ore-frist-flower-route-zereth-mortis/",
    },
    mapName = "Zereth Mortis",
    location = "Northern and northeastern Zereth Mortis First Flower route, overlapping Progenium checks",
    routeType = "herbalism-loop",
    density = "Medium for First Flower, with Death Blossom and Nightshade side herbs",
    dropDifficulty = "Moderate. First Flower is rare, so clear Death Blossom and Nightshade while moving the route.",
    tips = {
        "Patch 9.2 sources place First Flower only in Zereth Mortis.",
        "The route favors the northern and northeastern pin clusters instead of wandering the whole zone.",
        "This loop intentionally mirrors the Progenium path for future map-window route reconstruction.",
    },
    coords = {
        C(0.449, 0.080, "Wowhead First Flower far-north object pin"),
        C(0.462, 0.042, "Far-north object pin"),
        C(0.5005, 0.2543, "Artisans route northwestern loop point"),
        C(0.5534, 0.2880, "Artisans route northern ridge"),
        C(0.558, 0.365, "Wowhead First Flower central object pin"),
        C(0.5814, 0.2962, "Resonant Peaks route point"),
        C(0.5944, 0.2443, "Northern flower route"),
        C(0.6234, 0.2120, "First Flower object and route overlap"),
        C(0.6551, 0.2140, "Northeastern route point"),
        C(0.6719, 0.2668, "Northeast First Flower object cluster"),
        C(0.6660, 0.2997, "Eastern route descent"),
        C(0.6459, 0.2925, "Eastern return flower pin"),
        C(0.6171, 0.3441, "Southern flower route"),
        C(0.6630, 0.3513, "Southeastern loop point"),
        C(0.6931, 0.3355, "Eastern First Flower object pin"),
        C(0.6434, 0.3795, "Eastern ridge return"),
        C(0.5964, 0.3578, "Central return"),
    },
    confidence = "high",
}

-- Supplied reconstructed Retail Routes payloads, decoded without changing point order.
-- Linked sources explain the farming strategy; these vertices are not verified herb spawns.
local function SuppliedHerbRoute(id, sortOrder, mapID, mapName, location, packedCoords, tips, sourceUrls)
    sourceUrls[#sourceUrls + 1] = "https://xscarlife-gaming.com/farming/retail/"
    local archiveUrl = "https://github.com/Cion6982/retail-farm-routes"
    local hasArchive = false
    for _, url in ipairs(sourceUrls) do
        if url == archiveUrl then
            hasArchive = true
        end
    end
    if not hasArchive then
        sourceUrls[#sourceUrls + 1] = archiveUrl
    end
    local coords = {}
    for index, packed in ipairs(packedCoords) do
        coords[index] = C(math.floor(packed / 10000) / 10000, (packed % 10000) / 10000,
            location .. " #" .. index)
    end
    return {
        id = id,
        sortOrder = sortOrder,
        mapID = mapID,
        mapName = mapName,
        location = location,
        dropdownLabel = mapName .. ": " .. sortOrder .. ". " .. location,
        routeType = "herbalism-loop",
        source = "User-supplied reconstructed Retail Routes candidate; linked references include historical reports",
        sourceUrls = sourceUrls,
        dropDifficulty = "Reconstructed route control points, not guaranteed herb spawns. Not tested in game.",
        tips = tips,
        coords = coords,
        confidence = "low",
        inGameTested = false,
        isRoute = true,
    }
end

local SUPPLIED_HERB_ROUTES = {
    [169701] = {
        SuppliedHerbRoute(
            "shadowlands-death-blossom-bastion-broad-loop-supplied", 1,
            1533, "Bastion", "Main — Bastion broad loop",
            {
                55262490, 62153409, 60994146, 62355082, 58325496, 53686676, 54897085, 48736366,
                46726239, 45026950, 44426296, 38366436, 46635237, 36254418, 48343344, 52262445,
                54552043,
            },
            {
                "Recommended default Death Blossom route.",
                "It cycles a much larger section of Bastion, which matters because Death Blossom and Rising Glory compete across the zone's herb spawn network.",
                "Wow-Professions estimates that ordinary Shadowlands herb spawns broadly alternate between Death Blossom and the zone-specific herb; consequently a large, continuously moving loop is preferable to camping individual nodes.",
                "If mining is also trained, gather Solenium along the same path rather than deviating heavily from the loop.",
            },
            {
                "https://www.wow-professions.com/farming/death-blossom-farming",
            }
        ),
        SuppliedHerbRoute(
            "shadowlands-death-blossom-bastion-compact-loop-supplied", 2,
            1533, "Bastion", "Alternative — Bastion compact loop",
            {
                47365745, 50984910, 50195581, 50715955, 54056268, 55236592, 55707049, 50937628,
                48097740, 45148099, 49717168, 50806569, 48126189,
            },
            {
                "Better when the zone is empty and nodes are respawning quickly enough to support a smaller circuit.",
                "The corresponding compact Bastion farming style has several elevation changes; historically, farming guides warned about cliff drops on the shorter Bastion route.",
                "With flying available to the character, this becomes substantially more attractive because the vertical transitions cease to be meaningful.",
            },
            {
                "https://www.wow-professions.com/farming/death-blossom-farming",
            }
        ),
        SuppliedHerbRoute(
            "shadowlands-death-blossom-ardenweald-mixed-loop-supplied", 3,
            1565, "Ardenweald", "Alternative — Ardenweald mixed-herb loop",
            {
                42682898, 55232722, 56283221, 53794410, 44934628, 39914961, 35535655, 33685922,
                34404942, 38763384, 40012975,
            },
            {
                "This is primarily useful when you want Death Blossom + Vigil's Torch rather than Death Blossom alone.",
                "Use Ardenweald when you want a different zone from the two Bastion circuits.",
                "Ardenweald World Quests can phase areas or even remove herb nodes, so bypass a temporarily bad section instead of forcing the exact line.",
            },
            {
                "https://www.wow-professions.com/farming/death-blossom-farming",
                "https://www.wow-professions.com/farming/vigils-torch-farming",
            }
        ),
    },
    [168586] = {
        SuppliedHerbRoute(
            "shadowlands-rising-glory-bastion-full-loop-supplied", 1,
            1533, "Bastion", "Main — Bastion full loop",
            {
                55262490, 59893479, 60333788, 60684695, 62355082, 60915344, 53635938, 56166542,
                54897085, 50786511, 47415990, 49476620, 45026950, 44286716, 41696856, 42615937,
                46635237, 38564727, 46643986, 49053018, 52262445, 54552043,
            },
            {
                "Recommended main route.",
                "The larger circuit better cycles Bastion's Rising Glory spawn network rather than returning to recently harvested ground too soon.",
                "Pick Death Blossom on the way. Leaving it untouched does not help Rising Glory throughput; you want the herb spawn pool cycling.",
                "This layout also works particularly well as a combined Rising Glory/Solenium farm.",
            },
            {
                "https://www.wow-professions.com/farming/rising-glory-farming",
            }
        ),
        SuppliedHerbRoute(
            "shadowlands-rising-glory-bastion-compact-loop-supplied", 2,
            1533, "Bastion", "Alternative — Bastion compact loop",
            {
                47365745, 49845107, 51885091, 50195581, 50125883, 52536035, 54056268, 53866742,
                57296585, 55707049, 51467488, 49977654, 48097740, 46658007, 45677914, 49717168,
                52186776, 50296458, 48126189,
            },
            {
                "Use this when you want shorter laps and can verify the nodes are keeping pace with you.",
                "Historically the second compact Bastion route involved dangerous cliff drops; use flying or fall-damage mitigation if following it on the ground.",
                "If you catch another gatherer doing essentially the same loop, switch to the broad route rather than following directly behind them.",
            },
            {
                "https://www.wow-professions.com/farming/rising-glory-farming",
            }
        ),
    },
    [168589] = {
        SuppliedHerbRoute(
            "shadowlands-marrowroot-maldraxxus-broad-loop-supplied", 1,
            1536, "Maldraxxus", "Main — Maldraxxus broad loop",
            {
                49392341, 54583456, 65424840, 74135129, 66205429, 56575953, 53695714, 48226022,
                37415533, 32945608, 30515948, 25045940, 29125804, 32175074, 34563706, 41834151,
                44372873,
            },
            {
                "Best general-purpose route because it gives the spawn network enough time to replenish.",
                "Older Wowhead farming reports specifically mention good Marrowroot concentrations around the House of Rituals, around the Theater of Pain, and in the swampy area northeast of Theater of Pain.",
                "Gather Death Blossom and Nightshade as well; they share the Maldraxxus gathering ecosystem.",
            },
            {
                "https://www.wow-professions.com/farming/marrowroot-farming",
                "https://www.wowhead.com/item%3D168589/marrowroot",
            }
        ),
        SuppliedHerbRoute(
            "shadowlands-marrowroot-maldraxxus-short-loop-supplied", 2,
            1536, "Maldraxxus", "Alternative — shorter Maldraxxus loop",
            {
                50562364, 54372597, 53933488, 56633756, 58424347, 64663649, 70864312, 76195312,
                67285356, 60196045, 58616054, 53505968, 44695668, 44184824, 42984238, 42652977,
            },
            {
                "Better if you prefer the northern/eastern concentration instead of committing to the entire map.",
                "Wow-Professions reports no meaningful yield difference between its two principal Maldraxxus paths, so test both under current realm/shard conditions.",
                "A stealth-capable class is particularly convenient around denser hostile areas.",
            },
            {
                "https://www.wow-professions.com/farming/marrowroot-farming",
            }
        ),
        SuppliedHerbRoute(
            "shadowlands-marrowroot-central-micro-loop-supplied", 3,
            1536, "Maldraxxus", "Obscure alternative — central micro-loop",
            {
                43604430, 41204520, 40504800, 41005240, 43005560, 45205480, 46005220, 45304900,
                44004650,
            },
            {
                "This is a deliberately tight 40–46 X / 44–56 Y circuit rather than a conventional zone lap.",
                "Use it only when you observe healthy node respawns; otherwise you will lap the circuit faster than it can replenish.",
                "An old goldmaking tip worth retaining: Necrolord characters who obtained the House of Rituals disguise could farm portions of Maldraxxus with dramatically less aggro.",
            },
            {
                "https://www.wow-professions.com/farming/marrowroot-farming",
                "https://www.reddit.com/r/woweconomy/comments/lkrz6c",
            }
        ),
    },
    [170554] = {
        SuppliedHerbRoute(
            "shadowlands-vigil-s-torch-ardenweald-broad-loop-supplied", 1,
            1565, "Ardenweald", "Main — Ardenweald broad loop",
            {
                44554046, 53054467, 55204131, 61134013, 62114591, 64675234, 57246054, 53826527,
                48246471, 45707174, 43666826, 41816361, 39804982, 34284851, 32754137, 34053541,
                39843754,
            },
            {
                "Primary recommendation for maximum node coverage.",
                "This mirrors the whole-zone strategy that Wow-Professions found yielded the most Vigil's Torch.",
                "If a World Quest has transformed a section of the map, cut across and resume the route farther ahead rather than clearing through it.",
                "Particularly suitable as a combined Vigil's Torch + Phaedrum Ore + Death Blossom circuit.",
            },
            {
                "https://www.wow-professions.com/farming/vigils-torch-farming",
            }
        ),
        SuppliedHerbRoute(
            "shadowlands-vigil-s-torch-ardenweald-compact-loop-supplied", 2,
            1565, "Ardenweald", "Alternative — Ardenweald compact loop",
            {
                42682898, 49112732, 54522870, 56283221, 55384149, 51704557, 44934628, 41745004,
                37655170, 35535655, 33406128, 35265532, 34404942, 36164025, 40012975,
            },
            {
                "Use when you care more about herbs/hour with minimal travel than touching every possible cluster.",
                "It is also useful when one portion of the broad route is ruined by World Quest phasing.",
                "If respawns begin disappearing by your second or third lap, switch back to the broad route.",
            },
            {
                "https://www.wow-professions.com/farming/vigils-torch-farming",
            }
        ),
    },
    [168583] = {
        SuppliedHerbRoute(
            "shadowlands-widowbloom-revendreth-broad-loop-supplied", 1,
            1525, "Revendreth", "Main — broad Revendreth loop",
            {
                26363816, 34053688, 36545188, 40475791, 44476013, 61095615, 70336402, 69537022,
                59627205, 51507271, 44437348, 36886446, 31465285, 24573785,
            },
            {
                "General-purpose loop when you don't want to depend on one concentrated respawn pocket.",
                "If ground farming, Revendreth's verticality is the biggest time sink; flying materially changes this farm.",
                "Gather Death Blossom/Nightshade as well so the spawn network continues cycling.",
            },
            {
                "https://www.wow-professions.com/farming/widowbloom-farming",
            }
        ),
        SuppliedHerbRoute(
            "shadowlands-widowbloom-lower-revendreth-loop-supplied", 2,
            1525, "Revendreth", "Alternative — lower Revendreth",
            {
                46156168, 62195629, 65176214, 71176662, 70556940, 67886829, 64136882, 55417501,
                54197134, 53877655, 49367651, 48017196, 43287409, 42357928, 39358214, 39497737,
                41767487, 42747122, 40076745,
            },
            {
                "Wow-Professions says its lower Revendreth route produced the most Widowbloom in its testing.",
                "Ground farmers can skip the elevator/elite subsection—the guide notes only one herb node is lost by bypassing it.",
                "On another older route, Stonehead can block passage; either use the opening north of him or complete his associated quest.",
            },
            {
                "https://www.wow-professions.com/farming/widowbloom-farming",
            }
        ),
        SuppliedHerbRoute(
            "shadowlands-widowbloom-dredhollow-micro-loop-supplied", 3,
            1525, "Revendreth", "Hidden alternative — Dredhollow micro-loop",
            {
                39007700, 40007550, 42007500, 43707620, 44107820, 43508050, 42308200, 40408250,
                38808140, 38207920,
            },
            {
                "Dredhollow is a concentrated Widowbloom hotspot alternative.",
                "An old Wowhead report identifies Dredhollow around 40,80 as having roughly a dozen herb spawn points plus numerous mining nodes; many mobs are sleeping or fighting each other.",
                "Warcraft Wiki separately records Lush Widowbloom specifically in Dredhollow, corroborating the area's herb association.",
                "Do not use this loop blindly: its efficiency depends heavily on shard population and respawn activity. If one lap comes back empty, move to the lower-zone or broad loop.",
            },
            {
                "https://www.wow-professions.com/farming/widowbloom-farming",
                "https://www.wowhead.com/object%3D336433/widowbloom",
                "https://warcraft.wiki.gg/wiki/Lush_Widowbloom",
            }
        ),
        SuppliedHerbRoute(
            "shadowlands-widowbloom-dominance-keep-flying-loop-supplied", 4,
            1525, "Revendreth", "Hidden alternative — Dominance Keep flying loop",
            {
                23802860, 25002450, 27002000, 27601190, 31001450, 32901910, 30502470, 33902900,
                30003150, 26002880,
            },
            {
                "Flying strongly recommended.",
                "A 2021 goldmaking discovery found that Dominance Keep's elites and awkward elevation caused the area to be under-farmed; once flying was available, the poster could simply circle the keep without fighting.",
                "The report observed roughly 4–5 nodes on some laps and reported 110 Widowbloom after 15 minutes, but treat that rate as historical/anecdotal rather than a current guaranteed yield.",
                "Use this as an optional hotspot route; the reported results do not make it a universal default.",
            },
            {
                "https://www.wow-professions.com/farming/widowbloom-farming",
                "https://www.reddit.com/r/woweconomy/comments/ogbglt",
            }
        ),
    },
    [171315] = {
        SuppliedHerbRoute(
            "shadowlands-nightshade-maw-safer-loop-supplied", 1,
            1543, "The Maw", "Main — The Maw safer loop",
            {
                29242056, 31781887, 33572484, 25473597, 35653526, 40424041, 43124478, 38154800,
                31014698, 30374173, 20723401, 27873129, 31632463,
            },
            {
                "Recommended default Nightshade route: the supplied guide favors The Maw because its herb nodes are Nightshade, while covenant zones have a low replacement chance.",
                "The route deliberately favors the less hostile portions of the normal Maw circuit.",
                "Wow-Professions' safer Maw route normally requires fighting only one or two mobs around each herb rather than traversing the densest packs.",
                "Stealth, Feign Death and similar aggro-reset abilities allow more aggressive shortcuts.",
                "If an elite patrol blocks a node, skipping it is generally faster than forcing the fight.",
            },
            {
                "https://www.wow-professions.com/farming/nightshade-farming",
            }
        ),
        SuppliedHerbRoute(
            "shadowlands-nightshade-korthia-loop-supplied", 2,
            1961, "Korthia", "Alternative / obscure — Korthia",
            {
                56202115, 58363587, 55674375, 51395051, 49204820, 40915323, 31375778, 38334717,
                39833537, 45863897, 50383388, 49022782, 51532465,
            },
            {
                "The older Shadowlands route archive contains a combined Korthia Nightshade/Elethium route, making this a useful alternative if you also mine.",
                "It is not my preferred pure Nightshade farm; The Maw wins for target specificity.",
                "It is much more compelling as a Nightshade + Elethium multifarm.",
                "Use Korthia as an alternative to the main Maw route.",
            },
            {
                "https://www.wow-professions.com/farming/nightshade-farming",
                "https://github.com/Cion6982/retail-farm-routes",
            }
        ),
    },
    [187699] = {
        SuppliedHerbRoute(
            "shadowlands-first-flower-zereth-mortis-broad-loop-supplied", 1,
            1970, "Zereth Mortis", "Main — Zereth Mortis northeast/desert broad loop",
            {
                60871719, 65052108, 67782498, 65603069, 68783231, 68313529, 67693872, 65294009,
                63224071, 63583761, 63033417, 60433718, 50363077, 50182494, 58062410, 58772057,
            },
            {
                "Recommended main route because it does not depend solely on the hottest northeast pocket.",
                "This remains concentrated toward the northern/eastern First Flower territory while giving respawns more time.",
                "Pick Progenium Ore if you have Mining—the old route archive paired these two resources for good reason.",
                "Watch vertical terrain; some First Flower variants were deliberately placed in awkward locations.",
            },
            {
                "https://www.wowhead.com/item%3D187699/first-flower",
            }
        ),
        SuppliedHerbRoute(
            "shadowlands-first-flower-ne-mawsworn-hot-loop-supplied", 2,
            1970, "Zereth Mortis", "Alternative — northeast Mawsworn hot loop",
            {
                60871719, 62851978, 65052108, 67192328, 67782498, 67832764, 65603069, 67383310,
                68783231, 69223311, 68313529, 65203400, 63003200, 61002900, 59002500,
            },
            {
                "Use this as a specialized First Flower alternative to the broad Zereth Mortis loop.",
                "It deliberately concentrates on approximately 59–69 X / 17–35 Y, following the northeastern Mawsworn region highlighted by players as unusually dense for First Flower.",
                "Warcraft Wiki additionally places Elusive First Flower around the Dread Portal, reinforcing the northeast-focused farming strategy.",
                "Check ledges instead of relying exclusively on the ordinary minimap ping; Elusive nodes are specifically known for awkward elevated placements.",
                "Because this loop is short, abandon it quickly if another farmer is cycling the same pocket.",
            },
            {
                "https://www.wowhead.com/item%3D187699/first-flower",
                "https://warcraft.wiki.gg/wiki/Elusive_First_Flower",
            }
        ),
    },
}

local function WithSuppliedRoutes(itemID, legacySpots)
    local spots = {}
    for _, spot in ipairs(SUPPLIED_HERB_ROUTES[itemID] or {}) do
        spots[#spots + 1] = spot
    end
    -- Preserve older coordinate anchors after the supplied main and alternative routes.
    for index, spot in ipairs(legacySpots) do
        spot.sortOrder = 100 + index
        spot.isRoute = true
        spots[#spots + 1] = spot
    end
    return spots
end

local function RegisterHerb(itemID, itemName, spots, summary)
    Register({
        itemID = itemID,
        itemName = itemName,
        expansion = "shadowlands",
        professions = { "herbalism", "alchemy", "inscription" },
        category = "Herb",
        isRoute = true,
        sourceUrls = { ItemUrl(itemID) },
        summary = summary,
        spots = WithSuppliedRoutes(itemID, spots),
    })
end

RegisterHerb(168583, "Widowbloom", { REVENDRETH_HERB_ROUTE },
    "Revendreth zone herb; lower Revendreth and Sinfall-side loops are the practical target routes.")
RegisterHerb(168586, "Rising Glory", { BASTION_HERB_ROUTE },
    "Bastion zone herb gathered along open-field and water-edge routes.")
RegisterHerb(168589, "Marrowroot", { MALDRAXXUS_HERB_ROUTE },
    "Maldraxxus zone herb best target-farmed around Theater of Pain.")
RegisterHerb(169701, "Death Blossom", {
    BASTION_HERB_ROUTE,
    ARDENWEALD_HERB_ROUTE,
    REVENDRETH_HERB_ROUTE,
    ZERETH_MORTIS_FIRST_FLOWER_ROUTE,
}, "Common Shadowlands herb gathered while farming zone-specific herbs.")
RegisterHerb(170554, "Vigil's Torch", { ARDENWEALD_HERB_ROUTE }, "Ardenweald zone herb from forest waypoint loops.")
RegisterHerb(171315, "Nightshade", {
    BASTION_HERB_ROUTE,
    ARDENWEALD_HERB_ROUTE,
    REVENDRETH_HERB_ROUTE,
    ZERETH_MORTIS_FIRST_FLOWER_ROUTE,
}, "Target Nightshade in The Maw, with Korthia as a Nightshade/Elethium alternative; covenant-zone "
    .. "and Zereth Mortis routes remain available for mixed-herb gathering.")
RegisterHerb(187699, "First Flower", { ZERETH_MORTIS_FIRST_FLOWER_ROUTE },
    "Patch 9.2 Zereth Mortis herb used by Alchemy and Inscription recipes.")
