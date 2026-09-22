local _, NS = ...
local Register = NS.RegisterMaterialFarmingSpot

local function C(x, y, label)
    return { x = x, y = y, label = label }
end

local function ItemUrl(itemID)
    return "https://www.wowhead.com/item=" .. tostring(itemID)
end

local XSCARLIFE_REPO = "https://github.com/Cion6982/retail-farm-routes"
local XSCARLIFE_GUIDE = "https://xscarlife-gaming.com/farming-retail/"
local COBALT_GUIDE = "https://www.wow-professions.com/farming/cobalt-ore-farming"
local COBALT_WOWHEAD = "https://www.wowhead.com/item=36909/cobalt-ore"
local EPIC_COBALT = "https://epicwowguides.com/material/cobalt-ore-farming/"
local SARONITE_GUIDE = "https://www.wow-professions.com/farming/saronite-ore-farming"
local SARONITE_WOWHEAD = "https://www.wowhead.com/guide/ore-deposit-best-farming-routes"
local EPIC_SARONITE = "https://epicwowguides.com/material/saronite-ore-farming/"
local TITANIUM_WOWHEAD = "https://www.wowhead.com/object=191133/titanium-vein"
local EPIC_TITANIUM = "https://epicwowguides.com/material/titanium-ore-farming/"
local EPIC_TITANIUM_ICECROWN = "https://epicwowguides.com/wp-content/uploads/2024/04/Titanium-Ore-Icecrown.txt"

local function RouteCoords(label, packedCoords)
    local coords = {}
    for index, packed in ipairs(packedCoords) do
        local x = math.floor(packed / 10000)
        local y = packed % 10000
        coords[index] = {
            x = x / 10000,
            y = y / 10000,
            label = string.format("%s pin %d", label, index),
        }
    end
    return coords
end

-- Coordinates are decoded from the supplied Retail Routes exports. Their order is significant.
local COBALT_HOWLING_FJORD_COORDS = RouteCoords("Cobalt Howling Fjord route", {
    22651390, 31741595, 40691377, 52081009, 55861475, 56972097, 63772229, 67271023,
    72551328, 72222639, 69683328, 72014015, 78704448, 73285441, 77056543, 70896800,
    68127481, 64697117, 66506457, 68535853, 65445559, 65494638, 62733829, 52383556,
    37143049, 27093146, 26122365, 20622418, 23341993,
})

local COBALT_GRIZZLY_HILLS_COORDS = RouteCoords("Cobalt Grizzly Hills route", {
    14903900, 12603450, 19203420, 24703170, 49103840, 51303710, 59001810, 64091939,
    65402220, 65702660, 68502450, 70303050, 73703460, 76213884, 76504310, 76994635,
    77504920, 81005230, 77205580, 75105650, 75305990, 72606240, 69806120, 67106390,
    63306350, 60006480, 56005850, 53605960, 44806400, 46705610, 40405810, 29605700,
    13206320, 12905250, 14004490,
})

local SARONITE_SHOLAZAR_COORDS = RouteCoords("Saronite Sholazar route", {
    47352034, 40902090, 38822346, 33773230, 31203660, 28104130, 25034626, 23214833,
    22175324, 20805620, 21106250, 20677016, 20947450, 20657866, 22428406, 23758574,
    27888552, 35348786, 41308810, 45898777, 50008860, 52208830, 55308857, 59818732,
    63568432, 65318239, 68067888, 72037280, 74006920, 78526323, 78385789, 77395292,
    74294857, 67164022, 64173530, 63102970, 58832097, 53142094,
})

local SARONITE_ICECROWN_COORDS = RouteCoords("Saronite Icecrown route", {
    75416421, 71117111, 67417269, 63906199, 62004822, 55634420, 50074754, 48055385,
    48935935, 49556447, 47287099, 43836800, 39716349, 36465488, 37564820, 40524339,
    47073665, 56343427, 63663426, 68934612,
})

local SARONITE_WINTERGRASP_COORDS = RouteCoords("Saronite Wintergrasp route", {
    35851733, 40602748, 49053386, 57363223, 59682106, 70672998, 83784357, 78964808,
    73704727, 73835894, 81476100, 85226757, 86757348, 81197663, 77698111, 76617411,
    75906689, 67796587, 64367623, 58088096, 57577214, 57056397, 62815880, 62515074,
    51944807, 46454871, 48435423, 49235841, 46766125, 43556098, 42535435, 31275794,
    20605798, 19366273, 15026303, 12605650, 8125153, 14684557, 18323928, 21324002,
    22844319, 25174700, 24545168, 26275437, 28595484, 31905440, 33735176, 33194755,
    29844525, 26703777, 24842413, 28801885, 31891399,
})

local TITANIUM_ICECROWN_COORDS = RouteCoords("Titanium Icecrown route", {
    56184450, 68876339, 76456061, 77576457, 72826952, 69787071, 60217398,
    55108383, 46738282, 36646496, 41994711, 46144661, 48305284, 50464530,
})

local TITANIUM_STORM_PEAKS_COORDS = RouteCoords("Titanium Storm Peaks route", {
    42523281, 48333290, 64184592, 65505913, 55307125, 43207583,
    41336467, 37385448, 29455137, 24044823, 28924359,
})

local function MiningRoute(id, sourceUrls, mapID, mapName, location, coords, density, difficulty, tips)
    return {
        id = id,
        source = "Supplied Retail Routes export with route-specific public-source cross-checks",
        sourceUrls = sourceUrls,
        mapID = mapID,
        mapName = mapName,
        location = location,
        routeType = "mining-loop",
        isRoute = true,
        density = density,
        dropDifficulty = difficulty,
        tips = tips,
        coords = coords,
        confidence = "high",
    }
end

local COBALT_ROUTES = {
    MiningRoute(
        "wrath-cobalt-howling-fjord-main-route",
        { XSCARLIFE_REPO, XSCARLIFE_GUIDE, COBALT_GUIDE, COBALT_WOWHEAD },
        117,
        "Howling Fjord",
        "1. Main - mountain-edge and cliff circuit",
        COBALT_HOWLING_FJORD_COORDS,
        "Very high Cobalt concentration",
        "Strong default Cobalt route; competition is the main constraint.",
        {
            "Learn Northrend Mining first; Retail permits mining without it, but ore yields are substantially lower.",
            "Prioritize mountain edges, cliffs, cave mouths, and excavation areas instead of crossing the open center.",
            "Mine both normal and Rich Cobalt Deposits along the circuit.",
            "Use the Grizzly Hills alternative when another miner is directly ahead of you on this loop.",
        }
    ),
    MiningRoute(
        "wrath-cobalt-grizzly-hills-alternative-route",
        { EPIC_COBALT, COBALT_GUIDE },
        116,
        "Grizzly Hills",
        "2. Alternative - lower-competition outer mountain circuit",
        COBALT_GRIZZLY_HILLS_COORDS,
        "Moderate Cobalt concentration",
        "Usually less contested than Howling Fjord, with somewhat lower theoretical density.",
        {
            "Use this route when the Howling Fjord circuit is occupied.",
            "Stay close to the outer mountain formations rather than flying through the zone center.",
            "Mine both normal and Rich Cobalt Deposits encountered on the loop.",
            "Treat lower competition as the route's main advantage over Howling Fjord.",
        }
    ),
}

local SARONITE_ROUTES = {
    MiningRoute(
        "wrath-saronite-sholazar-basin-main-route",
        { EPIC_SARONITE, SARONITE_WOWHEAD, SARONITE_GUIDE },
        119,
        "Sholazar Basin",
        "1. Main - outer rim and interior pillar circuit",
        SARONITE_SHOLAZAR_COORDS,
        "Very high Saronite concentration",
        "Reliable continuous-flying route with little awkward cave routing, but often popular.",
        {
            "Follow the perimeter, then zig-zag inward around the pillars to catch nodes missed by outer-ring farmers.",
            "Mine every normal and Rich Saronite Deposit encountered.",
            "This circuit also creates Titanium opportunities because Titanium can appear among Saronite spawns.",
            "Switch to Icecrown when another player is directly ahead of you on the Sholazar loop.",
        }
    ),
    MiningRoute(
        "wrath-saronite-icecrown-alternative-route",
        { EPIC_SARONITE, SARONITE_WOWHEAD },
        118,
        "Icecrown",
        "2. Alternative - nested perimeter and central terrain rings",
        SARONITE_ICECROWN_COORDS,
        "High Saronite and Titanium opportunity",
        "Flying is effectively required; elevation changes make this more demanding than Sholazar.",
        {
            "Treat the route as nested rings: follow the perimeter and make interior passes around elevated terrain.",
            "Follow cliffs and major elevation transitions rather than crossing broad flat areas.",
            "Mine every Saronite node to keep the shared spawn cycle moving and create Titanium opportunities.",
            "Use this route when Sholazar Basin is heavily farmed.",
        }
    ),
    MiningRoute(
        "wrath-saronite-wintergrasp-alternative-route",
        { XSCARLIFE_REPO, XSCARLIFE_GUIDE, TITANIUM_WOWHEAD, SARONITE_GUIDE },
        123,
        "Wintergrasp",
        "3. Alternative - broad high-coverage circuit",
        SARONITE_WINTERGRASP_COORDS,
        "Very high coverage and Titanium opportunity",
        "Long, dense route; phasing or the active battle can disrupt practical farming.",
        {
            "Mine every Saronite node instead of cherry-picking Titanium so the spawn cycle keeps moving.",
            "Use this broad circuit when Sholazar and Icecrown are actively contested.",
            "If nodes unexpectedly disappear because of Wintergrasp phasing, relog before abandoning the route.",
            "Skip or postpone the circuit if the active Wintergrasp battle makes farming impractical.",
        }
    ),
}

local TITANIUM_ROUTES = {
    MiningRoute(
        "wrath-titanium-icecrown-main-route",
        { EPIC_TITANIUM, EPIC_TITANIUM_ICECROWN, TITANIUM_WOWHEAD },
        118,
        "Icecrown",
        "1. Main - native published Titanium circuit",
        TITANIUM_ICECROWN_COORDS,
        "Rare Titanium with high Saronite turnover",
        "RNG-heavy rare-node farm; several laps may contain no Titanium.",
        {
            "Mine every Saronite node; do not fly past it while looking only for Titanium.",
            "Clearing Saronite increases turnover at locations that can produce rare Titanium Veins.",
            "Follow Icecrown's cliff contours instead of crossing broad flat terrain.",
            "Judge the farm over several complete circuits rather than a single lap.",
        }
    ),
    MiningRoute(
        "wrath-titanium-storm-peaks-alternative-route",
        { EPIC_TITANIUM, TITANIUM_WOWHEAD },
        120,
        "The Storm Peaks",
        "2. Alternative - mountain shelf and ridgeline circuit",
        TITANIUM_STORM_PEAKS_COORDS,
        "Rare Titanium with Saronite side yield",
        "Flying is mandatory and underground node indicators can waste substantial time.",
        {
            "Use this route when Icecrown is being actively mined.",
            "Stay close to mountains, cliffs, shelves, and ridgelines.",
            "Do not enter every cave unless the node is clearly close to an entrance.",
            "Clear every Saronite deposit encountered to create more Titanium spawn opportunities.",
        }
    ),
}

Register({
    itemID = 37701,
    itemName = "Crystallized Earth",
    expansion = "wrath",
    professions = { "mining", "alchemy", "engineering" },
    category = "Elemental",
    sourceUrls = {
        "https://www.wow-professions.com/farming/crystallized-earth-farming",
        "https://www.wowhead.com/npc=29124/lifeblood-elemental",
        ItemUrl(37701),
    },
    summary = "Crystallized Earth is best targeted from Lifeblood Elementals in Sholazar Basin, with Saronite mining as a useful side source.",
    spots = {
        {
            id = "crystallized-earth-sholazar-lifeblood-elementals",
            source = "wow-professions Crystallized Earth guide and Wowhead Lifeblood Elemental comments",
            sourceUrls = {
                "https://www.wow-professions.com/farming/crystallized-earth-farming",
                "https://www.wowhead.com/npc=29124/lifeblood-elemental",
            },
            mapName = "Sholazar Basin",
            location = "Lifeblood Elementals around the Glimmering Pillar wetlands",
            routeType = "open-world-loop",
            density = "High",
            dropDifficulty = "Good targeted farm with fast respawns, but competition can flatten the loop.",
            tips = {
                "Keep the route tight around the Lifeblood Elemental cluster instead of doing a full-zone circuit.",
                "Use Saronite mining as secondary value only if ore prices justify leaving the elemental loop.",
            },
            coords = {
                C(0.710, 0.550, "Lifeblood Elemental cluster"),
                C(0.730, 0.550, "Eastern Lifeblood spawn"),
                C(0.740, 0.560, "Southeast Lifeblood spawn"),
                C(0.706, 0.526, "Northern wetland spawn"),
                C(0.762, 0.586, "Outer wetland spawn"),
            },
            confidence = "high",
        },
        SARONITE_ROUTES[1],
    },
})

Register({
    itemID = 36909,
    itemName = "Cobalt Ore",
    expansion = "wrath",
    professions = { "mining" },
    category = "Ore",
    researchStatus = "researched",
    isRoute = true,
    sourceUrls = { ItemUrl(36909), COBALT_GUIDE, XSCARLIFE_REPO, EPIC_COBALT },
    summary = "Howling Fjord is the main supplied Cobalt route; Grizzly Hills is the lower-competition alternative.",
    spots = COBALT_ROUTES,
})

Register({
    itemID = 36912,
    itemName = "Saronite Ore",
    expansion = "wrath",
    professions = { "mining" },
    category = "Ore",
    researchStatus = "researched",
    isRoute = true,
    sourceUrls = { ItemUrl(36912), SARONITE_GUIDE, SARONITE_WOWHEAD, EPIC_SARONITE, XSCARLIFE_REPO },
    summary = "Sholazar Basin is the main supplied Saronite route, with distinct Icecrown and Wintergrasp alternatives.",
    spots = SARONITE_ROUTES,
})

Register({
    itemID = 36910,
    itemName = "Titanium Ore",
    expansion = "wrath",
    professions = { "mining" },
    category = "Ore",
    researchStatus = "researched",
    isRoute = true,
    rareNode = true,
    sharedSpawn = "Saronite Ore",
    sourceUrls = { ItemUrl(36910), TITANIUM_WOWHEAD, EPIC_TITANIUM },
    summary = "Titanium is a rare Saronite-family replacement node; Icecrown is the main supplied route and The Storm Peaks is the alternative.",
    spots = TITANIUM_ROUTES,
})
