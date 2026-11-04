local _, NS = ...
local Register = NS.RegisterMaterialFarmingSpot

local function C(x, y, label)
    return { x = x, y = y, label = label }
end

local function ItemUrl(itemID)
    return "https://www.wowhead.com/item=" .. tostring(itemID)
end

local AOA_ROUTE_SOURCE = "https://artisansofazeroth.com/zone-atlas/"
local WOD_GATHERING_GUIDE = "https://www.wowhead.com/guide/professions/wod/gathering-professions-overview"

local TALADOR_ORE_ROUTE = {
    id = "warlords-ore-talador-central-ridge-imported-route",
    source = "Retail Wowhead WoD gathering overview, wow-professions True Iron guide, and Artisans of Azeroth retail route pins",
    sourceUrls = {
        "https://www.wowhead.com/guide/professions/wod/gathering-professions-overview",
        "https://www.wow-professions.com/farming/true-iron-ore-farming",
        "https://artisansofazeroth.com/materials/true-iron-ore/",
        AOA_ROUTE_SOURCE,
    },
    mapName = "Talador",
    location = "Central Talador ore route through ridge and ruin node clusters",
    routeType = "mining-loop",
    density = "High",
    dropDifficulty = "Good node density with higher mob pressure than Frostfire or Shadowmoon.",
    tips = {
        "Follow ridgelines and ruin edges; long flat crossings are lower value.",
        "Mine both True Iron and Blackrock nodes because Draenic Stone and low-skill fragments share the same outdoor node circuit.",
        "These pins sample the Artisans of Azeroth retail route import string so the addon can later reconstruct a map route.",
    },
    coords = {
        C(0.5312, 0.4492, "Central Talador ore start"),
        C(0.5509, 0.4891, "Central ridge bend"),
        C(0.4905, 0.5298, "Western ruin edge"),
        C(0.4933, 0.5629, "Western lower ridge"),
        C(0.4840, 0.6019, "Southwest ridge"),
        C(0.5241, 0.6006, "South central ridge"),
        C(0.5292, 0.5521, "Central return"),
        C(0.5467, 0.5470, "Central node pair"),
        C(0.5629, 0.6323, "Southeast ridge"),
        C(0.5976, 0.6206, "Southeast turn"),
        C(0.5937, 0.5429, "East central ridge"),
        C(0.6258, 0.5264, "Eastern ruin edge"),
        C(0.6749, 0.5468, "Eastern loop"),
        C(0.6408, 0.6241, "Eastern return"),
    },
    confidence = "high",
}

local NAGRAND_ORE_ROUTE = {
    id = "warlords-ore-nagrand-ridge-imported-route",
    source = "Retail Wowhead WoD gathering overview, wow-professions ore guides, and Artisans of Azeroth retail Nagrand ore pins",
    sourceUrls = {
        "https://www.wowhead.com/guide/professions/wod/gathering-professions-overview",
        "https://www.wow-professions.com/farming/blackrock-ore-farming",
        "https://www.wow-professions.com/farming/true-iron-ore-farming",
        AOA_ROUTE_SOURCE,
    },
    mapName = "Nagrand (Draenor)",
    location = "Southern and eastern Nagrand mountain-edge ore loop",
    routeType = "mining-loop",
    density = "High",
    dropDifficulty = "High-value loop, but Nagrand beasts and elites can slow fresh levelers.",
    tips = {
        "Use this when Talador is crowded or when pairing ore with Nagrand leather/meat farms.",
        "Stay on mountain shoulders and cave mouths; open plains are less consistent for mining nodes.",
    },
    coords = {
        C(0.6695, 0.4588, "Central east ridge"),
        C(0.7055, 0.4920, "East ridge bend"),
        C(0.7074, 0.5218, "Eastern slope"),
        C(0.7197, 0.5814, "Southeast ridge"),
        C(0.7699, 0.6065, "South ridge fork"),
        C(0.7765, 0.6536, "South ridge"),
        C(0.8303, 0.6808, "Southeast high ridge"),
        C(0.8889, 0.7159, "Far southeast turn"),
        C(0.8207, 0.7139, "South return"),
        C(0.7973, 0.7343, "Southwest bend"),
        C(0.7802, 0.6953, "Southern pass"),
        C(0.7480, 0.6778, "South central ridge"),
        C(0.7368, 0.7547, "Lower south spur"),
        C(0.7080, 0.6625, "Return ridge"),
    },
    confidence = "high",
}

local TANAAN_ORE_ROUTE = {
    id = "warlords-ore-tanaan-felblight-imported-route",
    source = "Retail Wowhead Felblight and WoD gathering pages plus Artisans of Azeroth Tanaan ore pins",
    sourceUrls = {
        "https://www.wowhead.com/item=127759/felblight",
        "https://www.wowhead.com/guide/professions/wod/gathering-professions-overview",
        AOA_ROUTE_SOURCE,
    },
    mapName = "Tanaan Jungle",
    location = "Tanaan Jungle ore route for ore plus Felblight chances",
    routeType = "mining-loop",
    density = "Medium to high",
    dropDifficulty = "Tanaan mobs are denser and hit harder, but this is the correct mining route when Felblight is part of the goal.",
    tips = {
        "Use this route for Felblight-era value, not as the easiest leveling ore route.",
        "Mine every node; retail Wowhead confirms Tanaan mining nodes can also yield Felblight.",
    },
    coords = {
        C(0.4300, 0.4812, "Central Tanaan ore start"),
        C(0.5003, 0.4923, "Central ridge"),
        C(0.5136, 0.4481, "Central north ridge"),
        C(0.5660, 0.4739, "Eastern ridge"),
        C(0.5336, 0.4038, "North central ridge"),
        C(0.5865, 0.1930, "Throne approach"),
        C(0.5250, 0.2010, "Northern pass"),
        C(0.5369, 0.2705, "Northern return"),
        C(0.4785, 0.3176, "Central west ridge"),
        C(0.5217, 0.3304, "Central node"),
        C(0.4931, 0.3721, "Central loop"),
        C(0.4657, 0.4106, "Western ridge"),
        C(0.4237, 0.4142, "West return"),
        C(0.4194, 0.3431, "Northwest return"),
    },
    confidence = "high",
}

local DRAENOR_ORE_ROUTES = {
    TALADOR_ORE_ROUTE,
    NAGRAND_ORE_ROUTE,
    TANAAN_ORE_ROUTE,
}

-- Decoded control points from the ten supplied Retail Routes candidate imports.
-- These paths are untested navigation guides, not confirmed mining-node spawns.
-- xScarlife's published exports are linked as references only; their geometry is not bundled here.
local function RouteCoords(label, packedCoords)
    local coords = {}
    for index, packed in ipairs(packedCoords) do
        local x = math.floor(packed / 10000)
        local y = packed % 10000
        coords[index] = C(x / 10000, y / 10000, string.format("%s pin %d", label, index))
    end
    return coords
end

local function OreRoute(id, sortOrder, mapID, mapName, location, packedCoords, tips, sourceUrls, experimental)
    return {
        id = id,
        sortOrder = sortOrder,
        mapID = mapID,
        mapName = mapName,
        location = location,
        routeType = "mining-loop",
        source = "User-supplied constructed Retail Routes candidate with route-specific farming-map references",
        sourceUrls = sourceUrls,
        dropDifficulty = "Constructed candidate path, not tested or benchmarked in WoW. Control points are not guaranteed mining spawns.",
        tips = tips,
        coords = RouteCoords(location, packedCoords),
        confidence = experimental and "low" or "medium",
        inGameTested = false,
        experimental = experimental,
        isRoute = true,
    }
end

local SUPPLIED_ORE_ROUTES = {
    [109118] = {
        OreRoute(
            "warlords-blackrock-ore-frostfire-ridge-supplied-main", 1,
            525, "Frostfire Ridge", "1. Main - Bladespire Citadel / Stonefang Outpost loop",
            { 17004200, 16004700, 18805300, 15405750, 17106700, 21406900, 21806100, 24005750, 31305690, 34806300, 37306270, 39505250, 42705000, 48204570, 49904970, 48405690, 43605330, 37004790, 31204990, 22905120, 19204550 },
            {
                "Follow the rocky slopes and ridges rather than the open snowfields; ore deposits are commonly associated with rocky terrain.",
                "Check both regular and rich deposits.",
                "The western portion is useful for repeated short farming sessions; shorten the eastern extension if it proves inefficient.",
                "Use GatherMate2 to record actual node positions and refine the route after a few circuits.",
            },
            {
                "https://www.wow-professions.com/farming/blackrock-ore-farming",
                "https://xscarlife-gaming.com/farming/retail/",
                ItemUrl(109118),
                WOD_GATHERING_GUIDE,
            }, false
        ),
        OreRoute(
            "warlords-blackrock-ore-talador-supplied-alternative-1", 2,
            535, "Talador", "2. Alternative 1 - Tuurem / Fort Wrynn eastern ridge",
            { 57602450, 58403280, 64703600, 68103300, 70204160, 73804960, 75506000, 81507330, 84707350, 84806250, 82405430, 78605130, 85304300, 84503920, 75604020, 77003240, 74802980, 81302250, 78501930, 69001870, 64102160, 61202650 },
            {
                "Search the uneven ground around the eastern ridge; avoid assuming every waypoint marks an exact deposit.",
                "Watch for elevation differences near the winding path and cliffs.",
                "Talador is a good fallback when Frostfire's common farming corridor is busy.",
                "The longest southern extension should be evaluated separately for ore collected per minute.",
            },
            {
                "https://www.wow-professions.com/farming/blackrock-ore-farming",
                ItemUrl(109118),
                WOD_GATHERING_GUIDE,
            }, false
        ),
        OreRoute(
            "warlords-blackrock-ore-shadowmoon-valley-supplied-alternative-2", 3,
            539, "Shadowmoon Valley (Draenor)", "3. Alternative 2 - Anguish Fortress / Burial Fields",
            { 40500630, 44300880, 46001720, 46002620, 44403520, 49604150, 59903900, 65304470, 65805780, 60006400, 56606950, 61007450, 59807840, 53007300, 50308180, 44108280, 42506700, 40605120, 31004310, 29503560, 34402910, 40003330, 41001950 },
            {
                "Begin near the central-western region and work toward the Burial Fields.",
                "Check rocky outcrops on either side of the marked route.",
                "Use this as an Alliance-friendly alternative when operating from Lunarfall.",
                "Remove dead-end deviations if the associated nodes are consistently absent.",
            },
            {
                "https://www.wow-professions.com/farming/blackrock-ore-farming",
                ItemUrl(109118),
                WOD_GATHERING_GUIDE,
            }, false
        ),
        OreRoute(
            "warlords-blackrock-ore-nagrand-supplied-alternative-3", 4,
            550, "Nagrand (Draenor)", "4. Alternative 3 - Eastern and southern mining corridor (Experimental)",
            { 51004700, 58004700, 65004500, 70004200, 75003600, 81003500, 88004200, 91005100, 86005900, 84006700, 78007300, 71007600, 65008100, 59007700, 53007300, 48006900, 45006000, 43005300 },
            {
                "Prioritize the eastern terrain and the southern highlands, where historical maps show dense clusters.",
                "Detour toward visible rich deposits where terrain permits.",
                "Watch for vertical separation between nodes on different elevations.",
                "Benchmark this route against Frostfire. Its historical density makes it interesting, but does not establish its current Retail efficiency.",
                "Experimental route based on historical deposit maps; benchmark several complete laps before relying on its current Retail yield.",
            },
            {
                "https://almostgaming.com/wow-farming/ore/warlords-of-draenor-mining-guide-1-700",
                "https://en.guiaswow.com/mineria/guia-de-mineria-de-draenor-1-700-actualizada-6-2.html",
                ItemUrl(109118),
                WOD_GATHERING_GUIDE,
            }, true
        ),
        OreRoute(
            "warlords-blackrock-ore-gorgrond-supplied-alternative-4", 5,
            543, "Gorgrond", "5. Alternative 4 - Central and southern mineral clusters (Experimental)",
            { 40004500, 46004100, 53003800, 60004300, 65005000, 63005700, 57006100, 52006800, 47007500, 44008600, 49009200, 54009000, 54008100, 59007500, 56006700, 51006000, 44005500, 40006100, 38006700, 36005700 },
            {
                "Sweep the central rocky terrain before turning toward the southern mining clusters.",
                "Avoid unnecessary detours deep into the most densely vegetated sections.",
                "Historical node density is promising, but the route is less well documented than Frostfire or Talador.",
                "Treat the southernmost leg as optional if it produces low ore-per-minute returns.",
                "Experimental route based on historical deposit maps; benchmark several complete laps before relying on its current Retail yield.",
            },
            {
                "https://en.guiaswow.com/mineria/guia-de-mineria-de-draenor-1-700-actualizada-6-2.html",
                ItemUrl(109118),
                WOD_GATHERING_GUIDE,
            }, true
        ),
    },
    [109119] = {
        OreRoute(
            "warlords-true-iron-ore-frostfire-ridge-supplied-main", 1,
            525, "Frostfire Ridge", "1. Main - Bladespire / Stonefang compact loop",
            { 18704540, 21904010, 25904320, 29004710, 34004950, 38904510, 44604420, 48704860, 47105410, 42105250, 39905880, 35106170, 33005530, 27805510, 24406250, 22106610, 19206140, 16805700, 18805210 },
            {
                "Focus on the western and central rocky formations, where the route has its densest coverage.",
                "Prioritize Rich True Iron Deposits when they appear, but collect Blackrock along the same circuit.",
                "This variant is shorter than the Blackrock Frostfire draft, making it useful for comparing circuit times.",
                "Skip extended detours away from the mountains if the minimap reveals no mining nodes.",
            },
            {
                "https://www.wow-professions.com/farming/true-iron-ore-farming",
                "https://xscarlife-gaming.com/farming/retail/",
                ItemUrl(109119),
                WOD_GATHERING_GUIDE,
            }, false
        ),
        OreRoute(
            "warlords-true-iron-ore-talador-supplied-alternative-1", 2,
            535, "Talador", "2. Alternative 1 - Eastern Talador / Tuurem",
            { 57602450, 58403280, 64703600, 68103300, 70204160, 73804960, 75506000, 81507330, 84707350, 84806250, 82405430, 78605130, 85304300, 84503920, 75604020, 77003240, 74802980, 81302250, 78501930, 69001870, 64102160, 61202650 },
            {
                "Work the elevated ridges around Tuurem instead of flying directly through settlements.",
                "Search the outer slopes around the northern section, where the route bends near Fort Wrynn.",
                "Both ore types occur in Talador, so mining every relevant node improves the yield of a combined farm.",
                "This is a larger circuit; compare its yield against the shorter Frostfire variation before choosing a permanent route.",
            },
            {
                "https://www.wow-professions.com/farming/true-iron-ore-farming",
                ItemUrl(109119),
                WOD_GATHERING_GUIDE,
            }, false
        ),
        OreRoute(
            "warlords-true-iron-ore-shadowmoon-valley-supplied-alternative-2", 3,
            539, "Shadowmoon Valley (Draenor)", "3. Alternative 2 - Anguish Fortress / Shaz'gul",
            { 40500630, 44300880, 46001720, 46002620, 44403520, 49604150, 59903900, 65304470, 65805780, 60006400, 56606950, 61007450, 59807840, 53007300, 50308180, 44108280, 42506700, 40605120, 31004310, 29503560, 34402910, 40003330, 41001950 },
            {
                "Begin around the central-western terrain and follow the ridges southward.",
                "The loop is useful for Alliance players already operating in Shadowmoon Valley.",
                "The area around the Burial Fields has several route turns; use these as opportunities to scan nearby rocks for deposits.",
                "Use the route as a navigational guide, not an exact list of guaranteed mining spawn points.",
            },
            {
                "https://www.wow-professions.com/farming/true-iron-ore-farming",
                ItemUrl(109119),
                WOD_GATHERING_GUIDE,
            }, false
        ),
        OreRoute(
            "warlords-true-iron-ore-nagrand-supplied-alternative-3", 4,
            550, "Nagrand (Draenor)", "4. Alternative 3 - Eastern highlands and southern corridor (Experimental)",
            { 51004700, 58004700, 65004500, 70004200, 75003600, 81003500, 88004200, 91005100, 86005900, 84006700, 78007300, 71007600, 65008100, 59007700, 53007300, 48006900, 45006000, 43005300 },
            {
                "Concentrate on the eastern mountains and southern plateau rather than covering the entire zone.",
                "Look for Rich True Iron Deposits around the elevated terrain.",
                "Take advantage of the same route to collect Blackrock Ore; the mining areas overlap.",
                "This is one of the most promising experimental alternatives, but current deposits-per-hour performance still needs testing.",
                "The supplied import has a malformed map field. This addon uses Draenor Nagrand map ID 550 from the route heading and preserves every supplied control point.",
                "Experimental route based on historical deposit maps; benchmark several complete laps before relying on its current Retail yield.",
            },
            {
                "https://almostgaming.com/wow-farming/ore/warlords-of-draenor-mining-guide-1-700",
                "https://en.guiaswow.com/mineria/guia-de-mineria-de-draenor-1-700-actualizada-6-2.html",
                ItemUrl(109119),
                WOD_GATHERING_GUIDE,
            }, true
        ),
        OreRoute(
            "warlords-true-iron-ore-gorgrond-supplied-alternative-4", 5,
            543, "Gorgrond", "5. Alternative 4 - Central highlands / southern Gorgrond (Experimental)",
            { 40004500, 46004100, 53003800, 60004300, 65005000, 63005700, 57006100, 52006800, 47007500, 44008600, 49009200, 54009000, 54008100, 59007500, 56006700, 51006000, 44005500, 40006100, 38006700, 36005700 },
            {
                "Follow the ore-bearing rocky ridges of central Gorgrond instead of the main roads.",
                "The southern portion may provide additional deposits, but the changing terrain makes navigation less straightforward.",
                "Check Rich True Iron nodes whenever they appear.",
                "Compare shorter central loops against the complete southern extension; a high number of historical nodes does not automatically translate to the highest hourly yield.",
                "Experimental route based on historical deposit maps; benchmark several complete laps before relying on its current Retail yield.",
            },
            {
                "https://en.guiaswow.com/mineria/guia-de-mineria-de-draenor-1-700-actualizada-6-2.html",
                ItemUrl(109119),
                WOD_GATHERING_GUIDE,
            }, true
        ),
    },
}

local function RegisterMiningMaterial(itemID, itemName, category, summary)
    local routes = {}
    local sourceUrls = {
        ItemUrl(itemID),
        WOD_GATHERING_GUIDE,
        "https://www.wow-professions.com/farming/true-iron-ore-farming",
        AOA_ROUTE_SOURCE,
    }
    local seenSources = {}
    for _, url in ipairs(sourceUrls) do
        seenSources[url] = true
    end
    -- Keep each supplied variant separate and ordered before existing researched routes.
    for _, spot in ipairs(SUPPLIED_ORE_ROUTES[itemID] or {}) do
        routes[#routes + 1] = spot
    end
    for _, spot in ipairs(DRAENOR_ORE_ROUTES) do
        spot.isRoute = true
        routes[#routes + 1] = spot
    end
    for _, spot in ipairs(routes) do
        for _, url in ipairs(spot.sourceUrls or {}) do
            if not seenSources[url] then
                seenSources[url] = true
                sourceUrls[#sourceUrls + 1] = url
            end
        end
    end
    Register({
        itemID = itemID,
        itemName = itemName,
        expansion = "warlords",
        professions = { "mining" },
        category = category,
        isRoute = category == "Ore",
        sourceUrls = sourceUrls,
        summary = summary,
        spots = routes,
    })
end

RegisterMiningMaterial(109118, "Blackrock Ore", "Ore", "Common Draenor ore farmed from outdoor Blackrock and True Iron node circuits.")
RegisterMiningMaterial(109119, "True Iron Ore", "Ore", "Common Draenor ore farmed from outdoor True Iron and Blackrock node circuits.")
RegisterMiningMaterial(109991, "True Iron Nugget", "Ore Fragment", "Low-skill mining fragment from Draenor True Iron nodes; combine ten into True Iron Ore.")
RegisterMiningMaterial(109992, "Blackrock Fragment", "Ore Fragment", "Low-skill mining fragment from Draenor Blackrock nodes; combine ten into Blackrock Ore.")
RegisterMiningMaterial(115508, "Draenic Stone", "Stone", "Draenor stone byproduct from mining outdoor ore nodes and garrison mine nodes.")
