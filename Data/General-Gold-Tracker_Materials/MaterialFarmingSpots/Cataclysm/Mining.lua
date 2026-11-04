local _, NS = ...
local Register = NS.RegisterMaterialFarmingSpot

local function C(x, y, label)
    return { x = x, y = y, label = label }
end

local function ItemUrl(itemID)
    return "https://www.wowhead.com/item=" .. tostring(itemID)
end

-- Decoded from the nine supplied Retail Routes exports. Point order is significant.
-- Reconstructed paths are travel control points, not guaranteed mining-node locations.
local function RouteCoords(label, packedCoords)
    local coords = {}
    for index, packed in ipairs(packedCoords) do
        local x = math.floor(packed / 10000)
        local y = packed % 10000
        coords[index] = C(x / 10000, y / 10000, string.format("%s pin %d", label, index))
    end
    return coords
end

local XSCARLIFE_GUIDE = "https://xscarlife-gaming.com/farming/retail/"
local OBSIDIUM_GUIDE = "https://www.wow-professions.com/farming/obsidium-ore-farming"
local OBSIDIUM_WOWHEAD = "https://www.wowhead.com/item=53038/obsidium-ore"
local ELEMENTIUM_GUIDE = "https://www.wow-professions.com/farming/elementium-ore-farming"
local ELEMENTIUM_WOWHEAD = "https://www.wowhead.com/object=202738/elementium-vein"
local PYRITE_WOWHEAD = "https://www.wowhead.com/object=202737/pyrite-deposit"
local PYRITE_WIKI = "https://warcraft.wiki.gg/wiki/Pyrite_Ore"
local TOL_BARAD_GUIDE = "https://warcraftzillionaire.blogspot.com/2011/01/tol-barad-mining-route-elementium-ore.html"
local DEEPHOLM_REPORT = "https://www.reddit.com/r/woweconomy/comments/i9kgto/"
local ULDUM_STUDY = "https://searchforloot.com/uldum-mining-herbalism-gold-farming/"
local ULDUM_EXTRA_EXPORT = "https://searchforloot.com/wp-content/uploads/2023/10/Uldum-ElementiumRoute-ImportCode.txt"

local function MiningRoute(id, sortOrder, mapID, mapName, location, published, packedCoords, tips, sourceUrls, rareNode)
    return {
        id = id,
        sortOrder = sortOrder,
        mapID = mapID,
        mapName = mapName,
        location = location,
        routeType = "mining-loop",
        source = published and "Supplied published Retail Routes export by xScarlife"
            or "Supplied Retail Routes reconstruction with public research references",
        sourceUrls = sourceUrls,
        dropDifficulty = rareNode and "Rare Pyrite search circuit; deposits are not guaranteed. In-game path has not been validated."
            or (published and "Published Retail route; in-game path has not been validated."
                or "Reconstructed travel control points, not guaranteed mining nodes. In-game path has not been validated."),
        tips = tips,
        coords = RouteCoords(location, packedCoords),
        confidence = published and "high" or "medium",
        isRoute = true,
        rareNode = rareNode or nil,
        sharedSpawn = rareNode and "Elementium Ore" or nil,
    }
end

local OBSIDIUM_ROUTES = {
    MiningRoute(
        "cataclysm-obsidium-mount-hyjal-main-route", 1,
        198, "Mount Hyjal", "1. Main - Mount Hyjal", true,
        {
            21543201, 29574056, 28765531, 35065139, 38926226, 40335447, 46335156, 52615208,
            53545748, 63875473, 78125742, 77835143, 81104832, 87924989, 85656097, 78336493,
            63026189, 54366796, 59537238, 58788037, 56017822, 52067940, 46328721, 34508990,
            33627338, 28876112, 21475907, 15295138, 9253612,
        },
        {
            "Prioritize rocky ridges and the southern mountain perimeter. Mining nodes generally follow mountain faces rather than open forest.",
            "Flying makes this the easiest consistent Obsidium circuit because it avoids Vashj'ir's underwater navigation.",
            "Pay attention to quest phasing in Mount Hyjal if parts of the route appear depleted.",
            "This is my default land-based route, although Shimmering Expanse may outperform it for ore per hour.",
            "Retail Cataclysm Mining has its own 1-75 progression; ignore 425-525 requirements from Cataclysm Classic guides.",
        },
        { XSCARLIFE_GUIDE, OBSIDIUM_GUIDE, OBSIDIUM_WOWHEAD }
    ),
    MiningRoute(
        "cataclysm-obsidium-shimmering-expanse-alternative-route", 2,
        205, "Shimmering Expanse", "2. Alternative 1 - Shimmering Expanse, Vashj'ir", false,
        {
            39003900, 45003700, 51003900, 57003800, 64004000, 71004100, 75004400, 72004800,
            66005000, 60004700, 54004800, 49004500, 43004600, 38004300,
        },
        {
            "Focus on Silver Tide Hollow, Silver Tide Trench, and the Ruins of Thelserai Temple. This is a documented concentration of Obsidium mining locations.",
            "Check the small side passages and cliff recesses rather than swimming directly between route waypoints.",
            "Stay north of Nespirah. Player farming reports specifically identify its southern/backside area as less productive.",
            "Use the Vashj'ir seahorse mount if available. This route may be the highest-yield Obsidium alternative when competition is low.",
            "Retail Cataclysm Mining has its own 1-75 progression; ignore 425-525 requirements from Cataclysm Classic guides.",
        },
        { OBSIDIUM_WOWHEAD, OBSIDIUM_GUIDE }
    ),
    MiningRoute(
        "cataclysm-obsidium-abyssal-depths-alternative-route", 3,
        204, "Abyssal Depths", "3. Alternative 2 - Abyssal Depths, Vashj'ir", false,
        {
            25004000, 30002900, 39002200, 52001800, 64001700, 76002300, 81003500, 76004400,
            81005400, 75006600, 65007500, 53007900, 41007400, 30006800, 24005700,
        },
        {
            "Follow the underwater cliff edges and seabed transitions, checking rock walls at different depths.",
            "This is a low-traffic fallback rather than my highest-yield recommendation.",
            "Use an underwater mount; vertical movement adds considerable travel time.",
            "If the circuit consistently produces fewer nodes than Shimmering Expanse, switch back. Published comparisons describe Abyssal Depths as viable but generally less productive.",
            "Retail Cataclysm Mining has its own 1-75 progression; ignore 425-525 requirements from Cataclysm Classic guides.",
        },
        { OBSIDIUM_WOWHEAD, OBSIDIUM_GUIDE }
    ),
}

local ELEMENTIUM_ROUTES = {
    MiningRoute(
        "cataclysm-elementium-twilight-highlands-main-route", 1,
        241, "Twilight Highlands", "1. Main - Twilight Highlands", true,
        {
            44581990, 54732248, 67403618, 71414887, 67345406, 63934390, 58963892, 53394018,
            50054722, 44935204, 37576552, 42047716, 58817567, 48218484, 36438856, 36497519,
            33337034, 25736815, 26976056, 37545662, 38324040, 42342806, 38992260,
        },
        {
            "Concentrate on the rocky west, northern ridges, and southern highlands, checking the base of cliffs as well as elevated ledges.",
            "Use a flying mount to avoid unnecessary fights and navigate between elevation changes.",
            "Check for Pyrite Deposits while farming Elementium. Both share spawning locations.",
            "This is my primary recommendation for Elementium because of its established mining density and the availability of a published Retail export.",
            "Retail Cataclysm Mining has its own 1-75 progression; ignore 425-525 requirements from Cataclysm Classic guides.",
        },
        { XSCARLIFE_GUIDE, ELEMENTIUM_GUIDE, ELEMENTIUM_WOWHEAD }
    ),
    MiningRoute(
        "cataclysm-elementium-uldum-alternative-route", 2,
        249, "Uldum", "2. Alternative 1 - Uldum", false,
        {
            21004600, 18003800, 17002900, 22002300, 27001700, 34001500, 41001300, 50001400,
            60001700, 70002100, 78002700, 84003400, 80004200, 74004700, 66004800, 61004100,
            56003500, 49003100, 40003100, 33003500, 27004100,
        },
        {
            "Follow the northern and western mountain boundaries instead of crossing the desert directly.",
            "Inspect the ridges along the Un'Goro border and the rocky formations eastward toward the Halls of Origination.",
            "Retail-specific requirement: If Uldum appears in its Battle for Azeroth 8.3 phase, speak to Zidormi near Ramkahen and switch to the older Cataclysm phase.",
            "This is a useful Elementium/Pyrite combination farm.",
            "Retail Cataclysm Mining has its own 1-75 progression; ignore 425-525 requirements from Cataclysm Classic guides.",
            "The linked Search For Loot export is a separate, more detailed Uldum circuit. Its October 2023 study reported about 458 Elementium and 54 Pyrite per hour; these historical results are not guaranteed current yields for this route.",
        },
        { ELEMENTIUM_GUIDE, ULDUM_STUDY, ULDUM_EXTRA_EXPORT }
    ),
    MiningRoute(
        "cataclysm-elementium-deepholm-alternative-route", 3,
        207, "Deepholm", "3. Alternative 2 - Deepholm", false,
        {
            12004200, 13002900, 22001900, 33001400, 43000900, 52001300, 62001600, 74002100,
            82003400, 85004600, 90005700, 84006900, 73007700, 62008300, 50008600, 37008000,
            25007300, 17006200,
        },
        {
            "Farm the outer perimeter of Deepholm, following rock faces rather than a direct route through the center.",
            "Explore areas around Needlerock Chasm, the Quaking Fields, and the outer cliffs near Therazane's Throne.",
            "Avoid detours through caves unless GatherMate2 records confirmed nodes inside; mining routes lose efficiency when the character must dismount.",
            "Deepholm is especially useful for mixed material farming because Obsidium and Elementium both occur there. A historical Retail farming report recorded substantial quantities of both ores.",
            "Retail Cataclysm Mining has its own 1-75 progression; ignore 425-525 requirements from Cataclysm Classic guides.",
        },
        { DEEPHOLM_REPORT, ELEMENTIUM_GUIDE }
    ),
}

local PYRITE_ROUTES = {
    MiningRoute(
        "cataclysm-pyrite-uldum-main-route", 1,
        249, "Uldum", "1. Main - Uldum", false,
        {
            20004200, 18003200, 21002300, 28001700, 37001400, 47001500, 58001800, 69002300,
            78002800, 84003700, 79004400, 72004700, 65004600, 59003900, 51003300, 43003000,
            35003400, 28004000,
        },
        {
            "Focus on the northern and western mountain belts, including the Un'Goro border.",
            "Mine Elementium nodes instead of bypassing them. This maintains gathering income while searching for rare Pyrite spawns.",
            "Prioritize short, repeatable circuits over very long loops through empty desert.",
            "Confirm the old Cataclysm Uldum phase with Zidormi before farming.",
            "If your only goal is Pyrite, compare hourly yields against Twilight Highlands rather than assuming Uldum will always be superior.",
            "Retail Cataclysm Mining has its own 1-75 progression; ignore 425-525 requirements from Cataclysm Classic guides.",
            "Ordinary Pyrite Deposits are rare spawns associated with Elementium nodes. Historical 10-13% estimates are not a confirmed current Retail rate.",
        },
        { ELEMENTIUM_GUIDE, PYRITE_WOWHEAD }, true
    ),
    MiningRoute(
        "cataclysm-pyrite-twilight-highlands-alternative-route", 2,
        241, "Twilight Highlands", "2. Alternative 1 - Twilight Highlands", false,
        {
            44601990, 54702250, 67403620, 71404890, 63904390, 59003890, 53404020, 50004720,
            44905200, 37606550, 42007720, 48208480, 36408860, 33307030, 25706820, 27006060,
            37505660, 38304040, 42302810,
        },
        {
            "Search the same mining areas used by Elementium farmers. Pyrite shares its spawn locations.",
            "Follow the ridges around Thundermar, then continue into the western and southern mountainous areas.",
            "Check ledges above riverbanks and along cliff faces; routes following the ground-level roads can miss deposits.",
            "Because this is one of the strongest Elementium farming zones, you can retain substantial Elementium output even when Pyrite spawns are scarce.",
            "Retail Cataclysm Mining has its own 1-75 progression; ignore 425-525 requirements from Cataclysm Classic guides.",
            "Ordinary Pyrite Deposits are rare spawns associated with Elementium nodes. Historical 10-13% estimates are not a confirmed current Retail rate.",
        },
        { PYRITE_WIKI, PYRITE_WOWHEAD, ELEMENTIUM_GUIDE }, true
    ),
    MiningRoute(
        "cataclysm-pyrite-tol-barad-peninsula-alternative-route", 3,
        245, "Tol Barad Peninsula", "3. Alternative 2 - Tol Barad Peninsula", false,
        {
            60003100, 69002900, 78003100, 84003800, 82004500, 76005100, 78005900, 81006900,
            78007800, 68008600, 57008400, 45007800, 34007100, 27007400, 20008300, 17007400,
            22006700, 33006300, 45006500, 58006200, 62005400, 57004700, 49004200, 42003600,
            47003000,
        },
        {
            "This route is based on a lesser-known mining circuit documented in 2011 for Elementium and Pyrite.",
            "Rich Pyrite Deposits are the main attraction. These occur in Tol Barad and its peninsula, unlike ordinary Pyrite Deposits in Uldum and Twilight Highlands.",
            "Flying is unavailable here, so use a ground mount and follow accessible terrain.",
            "Historical spawn reports describe clusters of three possible deposit locations, with only one active at a time. Once you find a node in a cluster, checking every other point in that cluster may be unnecessary.",
            "Avoid opposing faction bases and guards.",
            "This is best suited to low-competition farming or combining mining with Tol Barad activities. It is not necessarily the most efficient route for Pyrite per hour.",
            "Retail Cataclysm Mining has its own 1-75 progression; ignore 425-525 requirements from Cataclysm Classic guides.",
            "Ordinary Pyrite Deposits are rare spawns associated with Elementium nodes. Historical 10-13% estimates are not a confirmed current Retail rate.",
        },
        { TOL_BARAD_GUIDE, PYRITE_WIKI, PYRITE_WOWHEAD }, true
    ),
}

local function RegisterOre(itemID, itemName, routes, summary, rareNode)
    Register({
        itemID = itemID,
        itemName = itemName,
        expansion = "cataclysm",
        professions = { "mining" },
        category = "Ore",
        isRoute = true,
        rareNode = rareNode or nil,
        sharedSpawn = rareNode and "Elementium Ore" or nil,
        sourceUrls = { ItemUrl(itemID) },
        summary = summary,
        spots = routes,
    })
end

RegisterOre(53038, "Obsidium Ore", OBSIDIUM_ROUTES, "Cataclysm ore with a Mount Hyjal main route and separate Shimmering Expanse and Abyssal Depths alternatives.")
RegisterOre(52185, "Elementium Ore", ELEMENTIUM_ROUTES, "Cataclysm ore with a Twilight Highlands main route and separate Uldum and Deepholm alternatives.")
RegisterOre(52183, "Pyrite Ore", PYRITE_ROUTES, "Rare Cataclysm ore with an Uldum main search circuit and separate Twilight Highlands and Tol Barad Peninsula alternatives.", true)

-- Keep the existing side-material alternative independent of the imported ore variants.
local VOLATILE_EARTH_MINING_ROUTE = {
    id = "cataclysm-elementium-pyrite-twilight-highlands-loop",
    source = "Retail Wowhead Elementium/Pyrite node pins, wow-professions Elementium guide, and Artisans of Azeroth catalog cross-check",
    sourceUrls = {
        "https://www.wowhead.com/object=202738/elementium-vein",
        "https://www.wowhead.com/object=202737/pyrite-deposit",
        "https://www.wow-professions.com/farming/elementium-ore-farming",
        "https://artisansofazeroth.com/materials/elementium-ore/",
    },
    mapName = "Twilight Highlands",
    location = "Twilight Highlands Elementium loop with Pyrite replacement checks",
    routeType = "mining-loop",
    density = "High",
    dropDifficulty = "Strong Elementium route. Pyrite is rarer and depends on Elementium node turnover.",
    tips = {
        "Mine every Elementium node when targeting Pyrite because Pyrite can replace Elementium nodes.",
        "Use the full route when competition is high; tighten it around active clusters when the zone is quiet.",
        "Potion of Treasure Finding can add side value if you also kill nearby humanoids.",
    },
    coords = {
        C(0.172, 0.567, "Western Elementium pin"),
        C(0.178, 0.633, "Western ridge Elementium pin"),
        C(0.181, 0.570, "Northwest ridge Elementium pin"),
        C(0.280, 0.300, "Northwest ridge"),
        C(0.400, 0.230, "Northern ridge"),
        C(0.560, 0.260, "Thundermar ridge"),
        C(0.680, 0.360, "Eastern ridge"),
        C(0.640, 0.600, "Southeast return"),
        C(0.450, 0.720, "Southern highlands"),
        C(0.260, 0.560, "Western return"),
    },
    confidence = "high",
}

Register({
    itemID = 52327,
    itemName = "Volatile Earth",
    expansion = "cataclysm",
    professions = { "mining", "alchemy", "engineering" },
    category = "Volatile",
    sourceUrls = {
        ItemUrl(52327),
        "https://www.wowhead.com/npc=47226/obsidian-stoneslave",
        "https://www.wow-professions.com/farming/volatile-earth-farming",
    },
    summary = "Volatile Earth is a mining side material and can also be targeted from Obsidian Stoneslaves in Twilight Highlands.",
    spots = {
        {
            id = "cataclysm-volatile-earth-twilight-highlands-obsidian-stoneslaves",
            source = "Wowhead Volatile Earth guide, wow-professions Volatile Earth guide, and Obsidian Stoneslave page",
            sourceUrls = {
                "https://www.wowhead.com/npc=47226/obsidian-stoneslave",
                "https://www.wow-professions.com/farming/volatile-earth-farming",
                "https://www.wowhead.com/object=202738/elementium-vein",
            },
            mapName = "Twilight Highlands",
            location = "Obsidian Stoneslaves east of Thundermar at The Black Breach",
            routeType = "open-world-loop",
            density = "High",
            dropDifficulty = "Good targeted farm; miners can mine the corpses for extra value.",
            tips = {
                "Stay in the Black Breach pocket east of Thundermar instead of widening into a full-zone route.",
                "Mine eligible corpses after looting if you have Mining.",
                "Switch to the normal Elementium loop when the camp is crowded.",
            },
            coords = {
                C(0.596, 0.304, "North Black Breach pack"),
                C(0.620, 0.320, "Central Black Breach pack"),
                C(0.644, 0.346, "East Black Breach pack"),
                C(0.612, 0.374, "South Black Breach pack"),
            },
            confidence = "high",
        },
        VOLATILE_EARTH_MINING_ROUTE,
    },
})
