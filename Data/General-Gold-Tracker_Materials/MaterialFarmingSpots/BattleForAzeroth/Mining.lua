local _, NS = ...
local Register = NS.RegisterMaterialFarmingSpot
local H = NS.MaterialFarmingSpotHelpers

local function C(x, y, label)
    return { x = x, y = y, label = label }
end

local function ItemUrl(itemID)
    return "https://www.wowhead.com/item=" .. tostring(itemID)
end

local BFA_ORE_SOURCE_URLS = {
    "https://www.wow-professions.com/farming/monelite-ore-farming",
    "https://www.wow-professions.com/farming/storm-silver-ore-farming",
    "https://www.wow-professions.com/farming/platinum-ore-farming",
    "https://www.wowhead.com/guide/battle-for-azeroth-1-175-mining-profession-guide-patch-8-3-6293",
    "https://xscarlife-gaming.com/farming-retail/",
}

local TIRAGARDE_ORE_ROUTE = {
    id = "bfa-tiragarde-south-monelite-storm-silver-route",
    source = "wow-professions ore guides, retail Wowhead BFA mining guide, and sampled xScarlife retail Routes import pins",
    sourceUrls = BFA_ORE_SOURCE_URLS,
    mapName = "Tiragarde Sound",
    location = "Southern Tiragarde ore loop through Freehold cliffs, river edges, and Norwington return",
    routeType = "mining-loop",
    density = "High",
    dropDifficulty = "Good mixed BFA ore loop. Platinum is rare and Storm Silver is a Monelite respawn outcome.",
    tips = H.withBfaGatheringTips({
        "Mine every Monelite node because Storm Silver and Platinum depend on respawn rolls.",
        "This route is sampled from retail Routes import coordinates and kept dense enough for a later map overlay.",
        "Use this as the steady Monelite route and treat Storm Silver and Platinum as route bonuses.",
    }),
    coords = {
        C(0.7638, 0.5083, "AoA/xScarlife south Tiragarde ore pin"),
        C(0.7872, 0.5944, "AoA/xScarlife southeast ridge pin"),
        C(0.7673, 0.6355, "AoA/xScarlife Freehold cliff pin"),
        C(0.7342, 0.6270, "AoA/xScarlife south road pin"),
        C(0.7069, 0.6195, "AoA/xScarlife river-edge ore pin"),
        C(0.6796, 0.6119, "AoA/xScarlife inland return pin"),
        C(0.6447, 0.6344, "AoA/xScarlife west ridge pin"),
        C(0.6161, 0.6274, "AoA/xScarlife central south pin"),
        C(0.5874, 0.6203, "AoA/xScarlife west return pin"),
        C(0.5301, 0.6061, "AoA/xScarlife western loop pin"),
        C(0.5410, 0.5503, "AoA/xScarlife north bend pin"),
        C(0.5758, 0.5585, "AoA/xScarlife central ridge pin"),
        C(0.5882, 0.5965, "AoA/xScarlife route reconnect"),
        C(0.6001, 0.4859, "AoA/xScarlife northern spur"),
        C(0.6384, 0.5059, "AoA/xScarlife northeast return"),
        C(0.6767, 0.5258, "AoA/xScarlife east route pin"),
        C(0.7071, 0.4815, "AoA/xScarlife high ridge pin"),
        C(0.7354, 0.4949, "AoA/xScarlife route close"),
    },
    confidence = "high",
}

local NAZMIR_ORE_ROUTE = {
    id = "bfa-nazmir-ore-loop",
    source = "wow-professions Storm Silver guide and BFA mining route guides",
    sourceUrls = {
        "https://www.wow-professions.com/farming/storm-silver-ore-farming",
        "https://www.wow-professions.com/farming/platinum-ore-farming",
        "https://en.guiaswow.com/game-guide/Mining-guide-in-battle-for-azeroth-best-farming-routes.html",
    },
    mapName = "Nazmir",
    location = "Nazmir swamp and ridge mining loop",
    routeType = "mining-loop",
    density = "Medium",
    dropDifficulty = "Good route, but water and uneven terrain slow ground-only farming.",
    tips = H.withBfaGatheringTips({
        "Clear every ore node because rare ore replaces common ore on respawn.",
        "Waterwalking helps through the central swamp sections.",
        "Use this route when Tiragarde and Stormsong are crowded.",
    }),
    coords = {
        C(0.338, 0.424, "Western Nazmir ridge"),
        C(0.444, 0.318, "Northern swamp edge"),
        C(0.572, 0.352, "Eastern ridge ore"),
        C(0.638, 0.520, "Central return"),
        C(0.504, 0.662, "Southern swamp ore"),
    },
    confidence = "medium",
}

local STORMSONG_ORE_ROUTE = {
    id = "bfa-stormsong-valley-storm-silver-route",
    source = "wow-professions ore guides, retail Wowhead BFA mining guide, and sampled xScarlife retail Routes import pins",
    sourceUrls = BFA_ORE_SOURCE_URLS,
    mapName = "Stormsong Valley",
    location = "Stormsong Valley cliff and coastline ore loop",
    routeType = "mining-loop",
    density = "Medium to high",
    dropDifficulty = "Good Storm Silver target route with some vertical travel.",
    tips = H.withBfaGatheringTips({
        "Stormsong is useful when Storm Silver is the target price.",
        "Follow cliffs and coastlines; do not ignore Monelite while hunting rare ore.",
        "This denser loop is route-overlay ready and can be simplified later by the map UI.",
    }),
    coords = {
        C(0.4421, 0.4955, "AoA/xScarlife western Stormsong ore pin"),
        C(0.4860, 0.5266, "AoA/xScarlife lower valley pin"),
        C(0.5303, 0.5319, "AoA/xScarlife central bend"),
        C(0.5258, 0.5635, "AoA/xScarlife river cliff pin"),
        C(0.5086, 0.5901, "AoA/xScarlife south-central pin"),
        C(0.5557, 0.6143, "AoA/xScarlife ridge route pin"),
        C(0.6081, 0.6419, "AoA/xScarlife east ridge pin"),
        C(0.6669, 0.6518, "AoA/xScarlife eastern valley pin"),
        C(0.7216, 0.6553, "AoA/xScarlife coast approach"),
        C(0.7515, 0.6941, "AoA/xScarlife southeast coast pin"),
        C(0.7052, 0.7412, "AoA/xScarlife southern turn"),
        C(0.6421, 0.7581, "AoA/xScarlife south return"),
        C(0.5932, 0.7374, "AoA/xScarlife southwest ridge"),
        C(0.5004, 0.7610, "AoA/xScarlife west return"),
        C(0.4917, 0.7076, "AoA/xScarlife western valley pin"),
        C(0.4585, 0.6605, "AoA/xScarlife northwest return"),
        C(0.3595, 0.6103, "AoA/xScarlife west extension"),
        C(0.3760, 0.5415, "AoA/xScarlife northwestern bend"),
        C(0.3990, 0.5090, "AoA/xScarlife route close"),
    },
    confidence = "high",
}

local MECHAGON_ORE_ROUTE = {
    id = "bfa-mechagon-ore-and-chest-loop",
    source = "Wowhead Monelite comments and Mechagon mining notes",
    sourceUrls = {
        "https://www.wowhead.com/item=152512/monelite-ore",
        "https://www.wowhead.com/item=152579/storm-silver-ore",
        "https://www.wowhead.com/guide/comprehensive-mechagon-guide",
    },
    mapName = "Mechagon Island",
    location = "Mechagon Anti-Gravity Pack ore and chest loop",
    routeType = "mining-loop",
    density = "Medium",
    dropDifficulty = "Strong when the Anti-Gravity Pack is available; slower without it.",
    tips = H.withBfaGatheringTips({
        "A Wowhead comment highlights Mechagon mining with Anti-Gravity Pack as very efficient.",
        "Open Mechanized Chests while moving between ore nodes.",
        "Use this as a mixed Monelite, Storm Silver, and Platinum route.",
    }),
    coords = {
        C(0.250, 0.540, "Western junkyard ore"),
        C(0.356, 0.382, "Central ridge"),
        C(0.522, 0.300, "Northern depot ore"),
        C(0.662, 0.482, "Eastern return"),
        C(0.548, 0.706, "Southern cliff ore"),
    },
    confidence = "medium",
}

local OSMENITE_NAZJATAR_ROUTE = {
    id = "bfa-nazjatar-osmenite-zinanthid-route",
    source = "wow-professions Osmenite guide, Wowhead item page, and sampled xScarlife retail Routes import pins",
    sourceUrls = {
        "https://www.wow-professions.com/farming/osmenite-ore-farming",
        "https://www.wowhead.com/item=168185/osmenite-ore",
        "https://www.wowhead.com/guide/battle-for-azeroth-1-175-mining-profession-guide-patch-8-3-6293",
        "https://xscarlife-gaming.com/farming-retail/",
    },
    mapName = "Nazjatar",
    location = "Nazjatar ore route through Coral Forest, Kal'methir, Hanging Reef, and the Drowned Market",
    routeType = "mining-loop",
    density = "High",
    dropDifficulty = "Good patch 8.2 route, but mob density makes mounted gathering support valuable.",
    tips = H.withBfaGatheringTips({
        "Pair Osmenite with Zin'anthid whenever both are valuable.",
        "Use the Coral Forest and Kal'methir pins as the core route, then extend through Hanging Reef.",
        "These pins are intentionally dense because Osmenite routes are useful input for BFA prospecting data.",
    }),
    coords = {
        C(0.4002, 0.1549, "AoA/xScarlife northwestern Nazjatar pin"),
        C(0.4487, 0.2686, "AoA/xScarlife northern rise"),
        C(0.4733, 0.2990, "AoA/xScarlife upper Coral Forest"),
        C(0.6138, 0.2588, "AoA/xScarlife north Kal'methir"),
        C(0.6867, 0.2585, "AoA/xScarlife eastern ridge"),
        C(0.7595, 0.2582, "AoA/xScarlife Drowned Market north"),
        C(0.8035, 0.3606, "AoA/xScarlife eastern turn"),
        C(0.7719, 0.4930, "AoA/xScarlife southeast return"),
        C(0.7066, 0.4978, "AoA/xScarlife Kal'methir return"),
        C(0.6453, 0.5620, "AoA/xScarlife central return"),
        C(0.5200, 0.5588, "AoA/xScarlife Coral Forest south"),
        C(0.4772, 0.6077, "AoA/xScarlife lower Coral Forest"),
        C(0.4387, 0.6114, "AoA/xScarlife western slope"),
        C(0.4460, 0.6641, "AoA/xScarlife Hanging Reef approach"),
        C(0.4808, 0.7463, "AoA/xScarlife southern reef"),
        C(0.4114, 0.7603, "AoA/xScarlife southwest loop"),
        C(0.3752, 0.6785, "AoA/xScarlife west route"),
        C(0.3928, 0.5757, "AoA/xScarlife western return"),
        C(0.2960, 0.4756, "AoA/xScarlife far west point"),
        C(0.2800, 0.3681, "AoA/xScarlife northwest return"),
        C(0.3269, 0.3455, "AoA/xScarlife northwestern bend"),
        C(0.3514, 0.2151, "AoA/xScarlife north route close"),
    },
    confidence = "high",
}

-- Supplied exports remain separate map options, including same-map alternatives.
-- Published creator geometry and reconstructed candidates retain their provenance.
local function SuppliedMiningRoute(id, sortOrder, mapID, mapName, name, variant, verificationStatus, routeType, packedCoords, tips, sourceUrls)
    local coords = {}
    for index, packed in ipairs(packedCoords) do
        coords[#coords + 1] = C(math.floor(packed / 10000) / 10000, (packed % 10000) / 10000, name .. " #" .. index)
    end
    local published = verificationStatus == "published_exact"
    return {
        id = id,
        sortOrder = sortOrder,
        mapID = mapID,
        mapName = mapName,
        location = name,
        dropdownLabel = mapName .. ": " .. sortOrder .. ". " .. variant .. " - " .. name,
        routeType = routeType,
        source = published and "User-supplied xScarlife creator export; published route geometry, not independently tested in-game"
            or "User-supplied reconstructed mining circuit inspired by the linked source; not an exact published route export",
        sourceUrls = sourceUrls,
        dropDifficulty = published and "Published creator route; not independently tested in-game. Waypoints are navigation targets, not guaranteed ore spawns."
            or "Reconstructed route; not tested in-game. Waypoints are navigation targets, not guaranteed ore spawns.",
        tips = H.withBfaGatheringTips(tips),
        coords = coords,
        confidence = published and "medium" or "low",
        verificationStatus = verificationStatus,
        inGameTested = false,
        isRoute = true,
    }
end

local SUPPLIED_MINING_ROUTES = {
    [152512] = {
        SuppliedMiningRoute(
            "bfa-monelite-ore-tiragarde-hand-drawn-creator-export-supplied", 1,
            895, "Tiragarde Sound", "Tiragarde hand-drawn creator export", "Main",
            "published_exact", "mining-loop",
            { 76385083, 78725944, 76736355, 73426270, 70696195, 67966119, 64476344, 61616274, 58746203, 53016061, 54105503, 57585585, 58825965, 60014859, 63845059, 67675258, 70714815, 73544949 },
            {
                "Creator-made Retail route; follow existing waypoint geometry through Tiragarde mining zones.",
                "Gather Storm Silver and Platinum when they replace Monelite nodes; clearing every vein keeps mixed-spawn turnover moving.",
                "Use a BfA Mining glove enchant and mounted-gathering consumables where applicable.",
            },
            {
                "https://xscarlife-gaming.com/farming/retail/",
            }
        ),
        SuppliedMiningRoute(
            "bfa-monelite-ore-deadwash-brennadam-sagehold-perimeter-supplied", 2,
            942, "Stormsong Valley", "Deadwash Brennadam Sagehold perimeter", "Alternative 1",
            "reconstructed", "mining-loop",
            { 35005200, 40004800, 45004700, 48004100, 49003400, 55003100, 60003500, 65004100, 65004900, 63005800, 68006200, 66006800, 60007000, 56007300, 51007600, 46007300, 44006600, 41006100, 38005600 },
            {
                "Reconstructed aerial circuit linking the Deadwash, Warfang Hold, Sagehold and Brennadam ore areas.",
                "Inspect rocky ridges and slopes between landmarks, rather than entering every underground cave.",
                "Use flying to bridge the ridges efficiently; source guide favors Stormsong for Monelite.",
            },
            {
                "https://epicwowguides.com/material/monelite-ore-farming/",
            }
        ),
        SuppliedMiningRoute(
            "bfa-monelite-ore-nazmir-southern-wetland-quick-loop-supplied", 3,
            863, "Nazmir", "Nazmir southern wetland quick loop", "Alternative 2",
            "reconstructed", "mining-loop",
            { 31006000, 34005600, 38005800, 42006200, 47006300, 51006500, 55006500, 59006800, 61007300, 56007900, 50008200, 44008400, 38008100, 34007600, 31006900 },
            {
                "Use the southern wetland belt below the Heart of Darkness as a short repeatable loop.",
                "Water walking helps without flying; skip the central hostile temple interior.",
                "If the lap completes before nodes respawn, expand the loop toward the northern edges.",
            },
            {
                "https://www.wow-professions.com/farming/monelite-ore-farming",
            }
        ),
    },
    [152579] = {
        SuppliedMiningRoute(
            "bfa-storm-silver-ore-stormsong-xscarlife-published-circuit-supplied", 1,
            942, "Stormsong Valley", "Stormsong xScarlife published circuit", "Main",
            "published_exact", "mining-loop",
            { 44214955, 48605266, 53035319, 52585635, 50865901, 55576143, 60816419, 66696518, 72166553, 75156941, 70527412, 64217581, 59327374, 50047610, 49177076, 45856605, 35956103, 37605415, 39905090 },
            {
                "Original xScarlife hand-drawn Stormsong mining loop; use this as the first Storm Silver test route.",
                "Mine Monelite deposits as well to keep shared node spawns cycling.",
                "Use flying to shorten transitions and check exposed slopes before entering caves.",
            },
            {
                "https://xscarlife-gaming.com/farming-retail/",
            }
        ),
        SuppliedMiningRoute(
            "bfa-storm-silver-ore-stormsong-uplands-circuit-supplied", 2,
            942, "Stormsong Valley", "Stormsong uplands circuit", "Alternative 1",
            "reconstructed", "mining-loop",
            { 35005100, 39005000, 44005200, 46004600, 49004100, 51003500, 57003500, 62004200, 65004900, 65005700, 63006300, 58006700, 56007200, 50007600, 45007200, 42006500, 38006000 },
            {
                "Epic WoW Guides identifies Stormsong as its preferred Storm Silver farming area.",
                "Clear Monelite veins too: Storm Silver shares the same spawn cycle.",
                "The route is flight-oriented; caves near the center are optional detours depending on density.",
            },
            {
                "https://epicwowguides.com/material/storm-silver-ore-farming/",
            }
        ),
        SuppliedMiningRoute(
            "bfa-storm-silver-ore-voldun-cliff-and-basin-survey-supplied", 3,
            864, "Vol'dun", "Voldun cliff and basin survey", "Alternative 2",
            "reconstructed", "mining-loop",
            { 29005200, 34004000, 39003300, 45003100, 52003400, 58004000, 63004300, 62005200, 57006100, 54007100, 53008600, 45008600, 38007800, 31007500, 26006800, 27005900 },
            {
                "Vol’dun is explicitly listed as the second farming option by Epic WoW Guides.",
                "Search along exposed rock faces around Shatterstone Harbor, Brine Basin and the eastern ridges.",
                "Vertical elevation changes are significant; flying is strongly preferable.",
            },
            {
                "https://epicwowguides.com/material/storm-silver-ore-farming/",
            }
        ),
        SuppliedMiningRoute(
            "bfa-storm-silver-ore-tiragarde-coastal-reuse-supplied", 4,
            895, "Tiragarde Sound", "Tiragarde coastal reuse", "Alternative 3",
            "reconstructed", "mining-loop",
            { 62004300, 71004400, 78004900, 79005800, 75006400, 80007100, 77007900, 71008200, 66007800, 64006900, 58006500, 54005800, 57005200, 59004500 },
            {
                "Patrol the Bridgeport–Kennings Lodge–Freehold side of Tiragarde Sound.",
                "This is an independently reconstructed alternative, not the native xScarlife Storm Silver export.",
                "Mining nearby Monelite deposits is required when Storm Silver is scarce.",
            },
            {
                "https://www.wow-professions.com/farming/storm-silver-ore-farming",
            }
        ),
    },
    [152513] = {
        SuppliedMiningRoute(
            "bfa-platinum-ore-nazmir-high-turnover-lowland-sweep-supplied", 1,
            863, "Nazmir", "Nazmir high-turnover lowland sweep", "Main",
            "reconstructed", "mining-loop",
            { 31005800, 36005700, 40006000, 45006000, 50006400, 55006400, 60006500, 63007000, 60007700, 55008200, 48008300, 41008100, 35007600, 30006700 },
            {
                "Rare-spawn farming: collect every Monelite and Storm Silver node; no standalone Platinum-only circuit exists.",
                "A compact lowland loop emphasizes repeated node turnover rather than covering the whole zone.",
                "Expand the circuit if you begin catching up with the respawn cycle.",
            },
            {
                "https://www.wow-professions.com/farming/platinum-ore-farming",
            }
        ),
        SuppliedMiningRoute(
            "bfa-platinum-ore-drustvar-foothills-circuit-supplied", 2,
            896, "Drustvar", "Drustvar foothills circuit", "Alternative 1",
            "reconstructed", "mining-loop",
            { 31002800, 37002700, 45003000, 53003400, 60003800, 65004500, 67005300, 70006300, 65007000, 59007300, 51007300, 44006700, 40005800, 34005100, 30004200 },
            {
                "Follow the Fallhaven–Highroad Pass–Fletcher’s Hollow foothill band on a continuous loop.",
                "Drustvar gives an alternate Monelite and Storm Silver node pool for rare Platinum replacements.",
                "Avoid slow mountain interiors unless your minimap shows ore close to a cave entrance.",
            },
            {
                "https://www.wow-professions.com/farming/platinum-ore-farming",
            }
        ),
        SuppliedMiningRoute(
            "bfa-platinum-ore-stormsong-western-valley-circuit-supplied", 3,
            942, "Stormsong Valley", "Stormsong western valley circuit", "Alternative 2",
            "reconstructed", "mining-loop",
            { 35005100, 39004700, 44005000, 47005800, 45006500, 48007100, 55007200, 61006900, 65006300, 61005700, 57005300, 52005100, 47004600, 42004300 },
            {
                "Shorter sub-loop around Fort Daelin, Deadwash, Brennadam and rocky western flanks.",
                "Clear all BfA mining deposits so the rare Platinum replacement has opportunities to spawn.",
                "Swap to the longer Stormsong Monelite route if this compact loop is underpopulated.",
            },
            {
                "https://www.wow-professions.com/farming/platinum-ore-farming",
            }
        ),
    },
    [168185] = {
        -- Recovered the damaged point-25 index marker in the attachment; coordinate 36435433 is unchanged.
        SuppliedMiningRoute(
            "bfa-osmenite-ore-nazjatar-creator-published-flight-circuit-supplied", 1,
            1355, "Nazjatar", "Nazjatar creator-published flight circuit", "Main",
            "published_exact", "mining-loop",
            { 40021549, 44872686, 47332990, 61382588, 68672585, 75952582, 80353606, 77194930, 70664978, 64535620, 52005588, 47726077, 45805962, 43876114, 44606641, 48407019, 48087463, 44237674, 41147603, 38047531, 37526785, 40456479, 42136081, 39285757, 36435433, 29604756, 28003681, 32693455, 36723189, 35142151, 38501949 },
            {
                "Original xScarlife Retail import for Nazjatar; a long multi-region aerial loop.",
                "Check cave entrances and seams on your minimap when passing; some are hidden until you enter.",
                "Unlock the Nazjatar introduction and learn Osmenite Deposit/Seam ranks for higher yield.",
            },
            {
                "https://xscarlife-gaming.com/farming/retail/",
            }
        ),
        SuppliedMiningRoute(
            "bfa-osmenite-ore-nazjatar-cave-and-seam-patrol-supplied", 2,
            1355, "Nazjatar", "Nazjatar cave and seam patrol", "Alternative 1",
            "reconstructed", "mining-cave-seam-loop",
            { 40508200, 41877925, 45727441, 37006580, 38904930, 44005430, 46005200, 49435024, 48004650, 51833881, 58472926, 60653155, 61212700, 61501985, 55172865, 46842792, 36002700, 28402650, 29002860, 27793300, 28503849, 36004300, 37604260, 29404950 },
            {
                "A specialized Osmenite Seam route built from cave coordinates published in Wowhead comments.",
                "Most waypoints are entrances, not guaranteed live ore spawns: enter each cave and search thoroughly.",
                "Consider flying between entrances; this is a rank-progression and cave-seam route, not a proven ore/hour record.",
            },
            {
                "https://www.wowhead.com/object=325874/osmenite-seam",
            }
        ),
        SuppliedMiningRoute(
            "bfa-osmenite-ore-eastern-kalmethir-perimeter-supplied", 3,
            1355, "Nazjatar", "Eastern Kalmethir perimeter", "Alternative 2 - experimental",
            "reconstructed", "mining-loop",
            { 40007200, 44006700, 50006500, 57005900, 64005300, 71004500, 76003800, 80003000, 78002400, 72002300, 66002900, 62003500, 57004200, 51004900, 46005500, 42006100, 38006700 },
            {
                "Experimental eastern-side flight loop intended to cover areas away from the highest-traffic central circuit.",
                "This is a reconstruction inspired by WoW-Professions alternative routing, not their exact traced map.",
                "Prioritize visible deposits on the outer ridges and skip dead stretches if spawn density is poor.",
            },
            {
                "https://www.wow-professions.com/farming/osmenite-ore-farming",
            }
        ),
    },
}

local function WithSuppliedRoutes(itemID, existingSpots)
    local spots = {}
    for _, spot in ipairs(SUPPLIED_MINING_ROUTES[itemID] or {}) do
        spots[#spots + 1] = spot
    end
    for _, spot in ipairs(existingSpots or {}) do
        spot.isRoute = true
        spots[#spots + 1] = spot
    end
    return spots
end

local function RegisterOre(itemID, itemName, spots, summary)
    Register({
        itemID = itemID,
        itemName = itemName,
        expansion = "battleForAzeroth",
        professions = { "mining" },
        category = "Ore",
        isRoute = true,
        sourceUrls = { ItemUrl(itemID) },
        summary = summary,
        spots = WithSuppliedRoutes(itemID, spots),
    })
end

RegisterOre(152512, "Monelite Ore", {
    TIRAGARDE_ORE_ROUTE,
    NAZMIR_ORE_ROUTE,
    MECHAGON_ORE_ROUTE,
}, "Common BFA ore from Kul Tiras, Zandalar, and Mechagon node loops.")

RegisterOre(152579, "Storm Silver Ore", {
    STORMSONG_ORE_ROUTE,
    TIRAGARDE_ORE_ROUTE,
    NAZMIR_ORE_ROUTE,
    MECHAGON_ORE_ROUTE,
}, "Rare Monelite respawn ore. Mine all BFA ore nodes to force more spawn chances.")

RegisterOre(152513, "Platinum Ore", {
    STORMSONG_ORE_ROUTE,
    TIRAGARDE_ORE_ROUTE,
    MECHAGON_ORE_ROUTE,
}, "Rare BFA ore respawn; also the strongest base-BFA prospecting input when gem prices justify it.")

RegisterOre(168185, "Osmenite Ore", {
    OSMENITE_NAZJATAR_ROUTE,
}, "Nazjatar patch 8.2 ore, best paired with Zin'anthid route loops and 8.2 gem prospecting.")
