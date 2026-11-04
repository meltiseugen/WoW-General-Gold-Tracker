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

local FROSTFIRE_FROSTWEED_ROUTE = {
    id = "warlords-frostweed-frostfire-imported-route",
    source = "Retail Wowhead WoD gathering overview, wow-professions Frostweed guide, and Artisans of Azeroth retail Frostfire herb pins",
    sourceUrls = {
        WOD_GATHERING_GUIDE,
        "https://www.wow-professions.com/farming/frostweed-farming",
        AOA_ROUTE_SOURCE,
    },
    mapName = "Frostfire Ridge",
    location = "Frostfire Ridge snowfield herb route",
    routeType = "herbalism-loop",
    density = "High",
    dropDifficulty = "Good starter Draenor herb route with relatively simple terrain.",
    tips = {
        "Sweep snowfield edges rather than climbing deep mountain spurs.",
        "These sampled pins are dense enough for a future in-addon map route.",
    },
    coords = {
        C(0.4195, 0.1169, "Northern snowfield start"),
        C(0.4266, 0.1977, "Northwest snowfield"),
        C(0.4857, 0.1475, "North ridge herb"),
        C(0.4716, 0.2275, "North central herb"),
        C(0.5371, 0.2869, "Thunder Pass approach"),
        C(0.5322, 0.3773, "Central snowfield"),
        C(0.5129, 0.3467, "Central return"),
        C(0.4835, 0.4011, "West central node"),
        C(0.5102, 0.4099, "Central node pair"),
        C(0.4940, 0.4554, "Frostwall approach"),
        C(0.4323, 0.4492, "Western return"),
        C(0.4064, 0.4757, "West snowfield"),
        C(0.4173, 0.4148, "Northwest return"),
        C(0.4495, 0.3745, "Return ridge"),
    },
    confidence = "high",
}

local FROSTFIRE_FIREWEED_ROUTE = {
    id = "warlords-fireweed-frostfire-lava-imported-route",
    source = "Retail Wowhead Fireweed item page, WoD gathering overview, wow-professions Fireweed guide, and Artisans of Azeroth Frostfire pins",
    sourceUrls = {
        ItemUrl(109125),
        WOD_GATHERING_GUIDE,
        "https://www.wow-professions.com/farming/fireweed-farming",
        AOA_ROUTE_SOURCE,
    },
    mapName = "Frostfire Ridge",
    location = "Frostfire Ridge lava-side Fireweed route",
    routeType = "lava-herbalism-loop",
    density = "Medium to high",
    dropDifficulty = "Lava terrain and cliff transitions make this slower than generic Frostweed loops.",
    tips = {
        "Fireweed favors Frostfire lava pockets; do not sweep the whole snowfield when Fireweed is the target.",
        "Use the sampled loop as a route spine, then detour into visible lava-side herbs.",
    },
    coords = {
        C(0.6397, 0.7702, "Southern lava route start"),
        C(0.6772, 0.7275, "Southeast lava bend"),
        C(0.6807, 0.6848, "Lava shelf"),
        C(0.7111, 0.7111, "East lava pocket"),
        C(0.7228, 0.6237, "East pass"),
        C(0.7234, 0.5864, "Northeast lava edge"),
        C(0.7497, 0.5628, "Far east lava edge"),
        C(0.7095, 0.5542, "East return"),
        C(0.6724, 0.4764, "North lava bend"),
        C(0.6518, 0.5078, "Central lava node"),
        C(0.6651, 0.6317, "Central return"),
        C(0.6285, 0.5809, "West lava shelf"),
        C(0.6091, 0.6672, "Southwest lava edge"),
        C(0.5845, 0.6066, "Western return"),
    },
    confidence = "high",
}

local GORGROND_FLYTRAP_ROUTE = {
    id = "warlords-gorgrond-flytrap-central-jungle-loop",
    source = "Retail Wowhead object page, WoD gathering overview, and wow-professions Gorgrond Flytrap guide",
    sourceUrls = {
        "https://www.wowhead.com/object=228573/gorgrond-flytrap",
        WOD_GATHERING_GUIDE,
        "https://www.wow-professions.com/farming/gorgrond-flytrap-farming",
    },
    mapName = "Gorgrond",
    location = "Central and southern Gorgrond jungle herb loop",
    routeType = "herbalism-loop",
    density = "High",
    dropDifficulty = "Dense but mob-heavy compared with Frostfire and Shadowmoon.",
    tips = {
        "Stay in central and southern Gorgrond where plant density is highest.",
        "Use this route when Flytrap is needed for alchemy or daily cooldowns.",
    },
    coords = {
        C(0.4380, 0.4080, "Central jungle west"),
        C(0.5260, 0.4540, "Central jungle"),
        C(0.6120, 0.5420, "East jungle"),
        C(0.5080, 0.6480, "South jungle"),
        C(0.4080, 0.6120, "West jungle return"),
    },
    confidence = "high",
}

local SHADOWMOON_STARFLOWER_ROUTE = {
    id = "warlords-starflower-shadowmoon-imported-route",
    source = "Retail Wowhead WoD gathering overview, wow-professions Starflower guide, and Artisans of Azeroth Shadowmoon herb pins",
    sourceUrls = {
        ItemUrl(109127),
        WOD_GATHERING_GUIDE,
        "https://www.wow-professions.com/farming/starflower-farming",
        AOA_ROUTE_SOURCE,
    },
    mapName = "Shadowmoon Valley (Draenor)",
    location = "Shadowmoon Valley grove and field herb route",
    routeType = "herbalism-loop",
    density = "High",
    dropDifficulty = "Good Alliance-side route with low-to-medium mob pressure.",
    tips = {
        "Run wide loops through groves and field edges rather than mountain interiors.",
        "This route also covers Frostweed overlap mentioned in the retail gathering guide.",
    },
    coords = {
        C(0.1990, 0.1260, "Northwest grove start"),
        C(0.2608, 0.1344, "Northwest field"),
        C(0.2940, 0.3228, "Elodor approach"),
        C(0.3857, 0.2814, "Elodor grove"),
        C(0.4178, 0.2424, "North central grove"),
        C(0.4338, 0.3447, "Central grove"),
        C(0.3820, 0.3337, "Central return"),
        C(0.3944, 0.4178, "Central field"),
        C(0.4067, 0.4875, "South central field"),
        C(0.3739, 0.5177, "West return"),
        C(0.3134, 0.4422, "Western field"),
        C(0.2677, 0.3301, "Northwest return"),
        C(0.2349, 0.2557, "Northwest pass"),
        C(0.2078, 0.3035, "Return grove"),
    },
    confidence = "high",
}

local NAGRAND_ARROWBLOOM_ROUTE = {
    id = "warlords-nagrand-arrowbloom-imported-route",
    source = "Retail Wowhead WoD gathering overview, wow-professions Nagrand Arrowbloom guide, and Artisans of Azeroth Nagrand herb pins",
    sourceUrls = {
        ItemUrl(109128),
        WOD_GATHERING_GUIDE,
        "https://www.wow-professions.com/farming/nagrand-arrowbloom-farming",
        AOA_ROUTE_SOURCE,
    },
    mapName = "Nagrand (Draenor)",
    location = "Nagrand plains and tree-line Arrowbloom route",
    routeType = "herbalism-loop",
    density = "High",
    dropDifficulty = "Strong route, but Nagrand beast density can slow low-geared characters.",
    tips = {
        "Pick around tree lines, river edges, and open plains instead of bare rocky ridges.",
        "Pair with meat or hide farming if material prices favor mixed routes.",
    },
    coords = {
        C(0.8944, 0.4615, "Eastern plains start"),
        C(0.7546, 0.4094, "Ring-side plains"),
        C(0.7505, 0.4730, "East plains waterline"),
        C(0.6529, 0.5480, "Central river edge"),
        C(0.6389, 0.4865, "Central plains"),
        C(0.5850, 0.4894, "West central tree line"),
        C(0.6212, 0.4169, "North central plains"),
        C(0.6597, 0.3560, "North plains"),
        C(0.5833, 0.2491, "Northwest plains"),
        C(0.6557, 0.2238, "Northern tree line"),
        C(0.6779, 0.1593, "Far north plains"),
        C(0.7468, 0.1820, "Northeast plains"),
        C(0.7313, 0.2916, "East return"),
        C(0.7373, 0.3592, "Return plains"),
    },
    confidence = "high",
}

local TALADOR_ORCHID_ROUTE = {
    id = "warlords-talador-orchid-imported-route",
    source = "Retail Wowhead WoD gathering overview, wow-professions Talador Orchid guide, and Artisans of Azeroth Talador herb pins",
    sourceUrls = {
        ItemUrl(109129),
        WOD_GATHERING_GUIDE,
        "https://www.wow-professions.com/farming/talador-orchid-farming",
        AOA_ROUTE_SOURCE,
    },
    mapName = "Talador",
    location = "Talador waterline, meadow, and Auchindoun approach herb route",
    routeType = "herbalism-loop",
    density = "High",
    dropDifficulty = "Good route with mob pockets around ruins and Auchindoun approaches.",
    tips = {
        "Keep close to rivers, pools, and meadow edges.",
        "Avoid deep Shattrath pulls unless also farming cloth or green drops.",
    },
    coords = {
        C(0.6571, 0.1330, "Northern meadow start"),
        C(0.7170, 0.1878, "North ridge meadow"),
        C(0.7287, 0.2852, "Northeast waterline"),
        C(0.7813, 0.3845, "East waterline"),
        C(0.7922, 0.5215, "East river bend"),
        C(0.7946, 0.6037, "Southeast waterline"),
        C(0.7602, 0.6308, "Southeast return"),
        C(0.7511, 0.5199, "Central east return"),
        C(0.7237, 0.4990, "Central waterline"),
        C(0.7161, 0.5896, "South central bend"),
        C(0.6616, 0.5568, "Central meadow"),
        C(0.6957, 0.5404, "Central loop"),
        C(0.6485, 0.4793, "West central waterline"),
        C(0.6232, 0.5108, "Western return"),
    },
    confidence = "high",
}

local TANAAN_HERB_ROUTE = {
    id = "warlords-herbs-tanaan-felblight-imported-route",
    source = "Retail Wowhead Felblight and WoD gathering pages plus Artisans of Azeroth Tanaan herb pins",
    sourceUrls = {
        ItemUrl(127759),
        WOD_GATHERING_GUIDE,
        AOA_ROUTE_SOURCE,
    },
    mapName = "Tanaan Jungle",
    location = "Tanaan Jungle mixed-herb route for Draenor herbs and Felblight chances",
    routeType = "herbalism-loop",
    density = "Medium to high",
    dropDifficulty = "Tanaan herb routes are more dangerous, but they are the correct Felblight-era herbalism target.",
    tips = {
        "Use Tanaan for Felblight chances; use the original zone herb routes for easier bulk herb farming.",
        "Retail Wowhead notes Withered Herb nodes can contain Draenor herbs and Felblight.",
    },
    coords = {
        C(0.3852, 0.4269, "Central west Tanaan herb"),
        C(0.3569, 0.3183, "Northwest herb"),
        C(0.3878, 0.3662, "North central herb"),
        C(0.4135, 0.3550, "Central herb"),
        C(0.4332, 0.3900, "Central loop"),
        C(0.4855, 0.3722, "East central herb"),
        C(0.4814, 0.3078, "Northeast herb"),
        C(0.5258, 0.2650, "Northern pass"),
        C(0.5276, 0.1966, "Throne approach"),
        C(0.6326, 0.2041, "Far northeast herb"),
        C(0.5936, 0.2288, "Northeast return"),
        C(0.5602, 0.2366, "Northern return"),
        C(0.5637, 0.3097, "East central return"),
        C(0.5409, 0.3633, "Central return"),
    },
    confidence = "high",
}

-- Control points decoded from the 18 supplied Retail Routes candidate imports.
-- These are reconstructed paths, not guaranteed node spawns or benchmarked yields.
-- Published xScarlife exports are references only; their route geometry is not bundled here.
local function RouteCoords(label, packedCoords)
    local coords = {}
    for index, packed in ipairs(packedCoords) do
        local x = math.floor(packed / 10000)
        local y = packed % 10000
        coords[index] = C(x / 10000, y / 10000, string.format("%s pin %d", label, index))
    end
    return coords
end

local function HerbRoute(id, sortOrder, mapID, mapName, location, packedCoords, tips, sourceUrls, experimental)
    return {
        id = id,
        sortOrder = sortOrder,
        mapID = mapID,
        mapName = mapName,
        location = location,
        routeType = "herbalism-loop",
        source = "User-supplied constructed Retail Routes candidate; original published export linked for reference only",
        sourceUrls = sourceUrls,
        dropDifficulty = "Constructed candidate path, not tested or benchmarked in WoW. Control points are not guaranteed herb spawns.",
        tips = tips,
        coords = RouteCoords(location, packedCoords),
        confidence = experimental and "low" or "medium",
        inGameTested = false,
        experimental = experimental,
        isRoute = true,
    }
end

local SUPPLIED_HERB_ROUTES = {
    [109124] = {
        HerbRoute(
            "warlords-frostweed-frostfire-ridge-supplied-main", 1,
            525, "Frostfire Ridge", "1. Main route - Bladespire and Cracking Plains",
            { 33004500, 37003500, 44002900, 51002700, 58003100, 61003900, 55004300, 49004700, 45005500, 51006100, 58006200, 60006900, 53007200, 46006800, 41006000, 34006200, 29005700, 28005000 },
            {
                "Follow the foothills around Bladespire and the Cracking Plains instead of crossing large areas of empty snow.",
                "Check ridgelines and adjacent lower ground; this loop covers a relatively broad area.",
            },
            {
                "https://github.com/Cion6982/retail-farm-routes/blob/main/Routes%20-%20Warlords%20of%20Draenor/Frostweed.txt",
                "https://www.wow-professions.com/farming/frostweed-farming",
                ItemUrl(109124),
                WOD_GATHERING_GUIDE,
            }, false
        ),
        HerbRoute(
            "warlords-frostweed-shadowmoon-valley-supplied-alternative-1", 2,
            539, "Shadowmoon Valley (Draenor)", "2. Alternative 1 - Gloomshade to Burial Fields",
            { 29002200, 34001700, 42002000, 46002700, 52003300, 55004100, 48004400, 44005200, 50005800, 56006100, 58006800, 53007300, 47006700, 40007000, 37006100, 42005600, 38004900, 33004400, 29003600 },
            {
                "Follow open areas around Gloomshade, Embaari, and the Burial Fields.",
                "Collect Starflower opportunistically during the same sweep.",
            },
            {
                "https://github.com/Cion6982/retail-farm-routes/blob/main/Routes%20-%20Warlords%20of%20Draenor/Frostweed.txt",
                "https://www.wow-professions.com/farming/frostweed-farming",
                ItemUrl(109124),
                WOD_GATHERING_GUIDE,
            }, false
        ),
        HerbRoute(
            "warlords-frostweed-frostfire-ridge-supplied-alternative-2", 3,
            525, "Frostfire Ridge", "3. Alternative 2 - Western Daggermaw short loop (Experimental)",
            { 26004700, 29003900, 34003300, 40002900, 44003500, 40004100, 37004900, 42005400, 38006000, 32006300, 27005800, 23005300 },
            {
                "Use a shorter circuit when the main route takes too long between respawn checks.",
                "Watch for opportunistic Fireweed nodes in nearby warmer terrain.",
                "Experimental candidate: compare herbs collected over several complete laps before relying on this route.",
            },
            {
                "https://github.com/Cion6982/retail-farm-routes/blob/main/Routes%20-%20Warlords%20of%20Draenor/Frostweed.txt",
                "https://www.wow-professions.com/farming/frostweed-farming",
                ItemUrl(109124),
                WOD_GATHERING_GUIDE,
            }, true
        ),
    },
    [109125] = {
        HerbRoute(
            "warlords-fireweed-frostfire-ridge-supplied-main", 1,
            525, "Frostfire Ridge", "1. Main route - Bladespire lava basins",
            { 42004700, 45004300, 49004600, 53003900, 57003200, 54002600, 61002500, 65003300, 63004200, 57004700, 54005500, 49006000, 45005600, 40005900, 37005300, 39004800 },
            {
                "Sweep the accessible edges of lava pools and fissures.",
                "Skip large snow-covered sections without volcanic terrain or tracked nodes.",
            },
            {
                "https://github.com/Cion6982/retail-farm-routes/blob/main/Routes%20-%20Warlords%20of%20Draenor/Fireweed.txt",
                "https://www.wow-professions.com/farming/fireweed-farming",
                ItemUrl(109125),
                WOD_GATHERING_GUIDE,
            }, false
        ),
        HerbRoute(
            "warlords-fireweed-frostfire-ridge-supplied-alternative-1", 2,
            525, "Frostfire Ridge", "2. Alternative 1 - Magnarok volcanic area",
            { 65002700, 69002400, 74002600, 78003000, 80003600, 77004200, 72004400, 68004000, 66003400 },
            {
                "Try this compact northeastern route when the main route is contested.",
                "Switch to the central lava basins if tracking reveals too few nodes.",
            },
            {
                "https://github.com/Cion6982/retail-farm-routes/blob/main/Routes%20-%20Warlords%20of%20Draenor/Fireweed.txt",
                "https://www.wow-professions.com/farming/fireweed-farming",
                ItemUrl(109125),
                WOD_GATHERING_GUIDE,
            }, false
        ),
        HerbRoute(
            "warlords-fireweed-spires-of-arak-supplied-alternative-2", 3,
            542, "Spires of Arak", "3. Alternative 2 - Spires of Arak mixed-herb sweep (Experimental)",
            { 54003500, 61003800, 67004300, 71004900, 67005600, 60006100, 55006700, 49006800, 43006400, 41005600, 46005000, 49004300 },
            {
                "Treat this as a multi-herb scouting loop, not a dedicated Fireweed route.",
                "Record Fireweed pickups separately before considering it a reliable alternative.",
                "Experimental candidate: compare herbs collected over several complete laps before relying on this route.",
            },
            {
                "https://github.com/Cion6982/retail-farm-routes/blob/main/Routes%20-%20Warlords%20of%20Draenor/Fireweed.txt",
                "https://www.wow-professions.com/farming/fireweed-farming",
                ItemUrl(109125),
                WOD_GATHERING_GUIDE,
            }, true
        ),
    },
    [109126] = {
        HerbRoute(
            "warlords-gorgrond-flytrap-gorgrond-supplied-main", 1,
            543, "Gorgrond", "1. Main route - Highpass and Beastwatch foothills",
            { 43004800, 49004600, 56004700, 61005100, 59005700, 55006300, 51006100, 48006800, 44007200, 40007600, 35007200, 37006400, 41005800, 39005300 },
            {
                "Prioritize vegetation near the foothills, Tangleheart, Highpass, and Beastwatch.",
                "Avoid long detours into barren cliffs unless a nearby node is visible on the minimap.",
            },
            {
                "https://github.com/Cion6982/retail-farm-routes/blob/main/Routes%20-%20Warlords%20of%20Draenor/Gorgrond-Flytrap.txt",
                "https://www.wow-professions.com/farming/gorgrond-flytrap-farming",
                ItemUrl(109126),
                WOD_GATHERING_GUIDE,
            }, false
        ),
        HerbRoute(
            "warlords-gorgrond-flytrap-gorgrond-supplied-alternative-1", 2,
            543, "Gorgrond", "2. Alternative 1 - Evermorn and southern Gorgrond",
            { 34006800, 39006700, 43007100, 47007400, 52007700, 49008200, 44008500, 39008100, 36007700, 32007300 },
            {
                "Explore vegetation-rich areas around Evermorn Springs and the southern approach.",
                "This is a shorter loop that avoids the extensive northern terrain.",
            },
            {
                "https://github.com/Cion6982/retail-farm-routes/blob/main/Routes%20-%20Warlords%20of%20Draenor/Gorgrond-Flytrap.txt",
                "https://www.wow-professions.com/farming/gorgrond-flytrap-farming",
                ItemUrl(109126),
                WOD_GATHERING_GUIDE,
            }, false
        ),
        HerbRoute(
            "warlords-gorgrond-flytrap-spires-of-arak-supplied-alternative-2", 3,
            542, "Spires of Arak", "3. Alternative 2 - Spires of Arak wooded middle (Experimental)",
            { 35004100, 42003700, 50004000, 56004600, 59005300, 55006000, 49006500, 43006200, 37005600, 33004900 },
            {
                "Scout wooded terrain as a cross-zone alternative; Flytrap has recorded spawns in Spires.",
                "Compare actual pickup counts before integrating this into an optimized Flytrap farming recommendation.",
                "Experimental candidate: compare herbs collected over several complete laps before relying on this route.",
            },
            {
                "https://github.com/Cion6982/retail-farm-routes/blob/main/Routes%20-%20Warlords%20of%20Draenor/Gorgrond-Flytrap.txt",
                "https://www.wow-professions.com/farming/gorgrond-flytrap-farming",
                ItemUrl(109126),
                WOD_GATHERING_GUIDE,
            }, true
        ),
    },
    [109127] = {
        HerbRoute(
            "warlords-starflower-shadowmoon-valley-supplied-main", 1,
            539, "Shadowmoon Valley (Draenor)", "1. Main route - Gloomshade and Embaari woodlands",
            { 27002900, 29002200, 35001600, 42002100, 44002700, 48003000, 55003300, 59004000, 56004500, 50004300, 46004900, 42005300, 36005000, 31004500, 26003900 },
            {
                "Farm the northern and central woodland clearings rather than the eastern temple area.",
                "Frostweed can appear along the same general route, improving mixed-herb gathering.",
            },
            {
                "https://github.com/Cion6982/retail-farm-routes/blob/main/Routes%20-%20Warlords%20of%20Draenor/Starflower.txt",
                "https://www.wow-professions.com/farming/starflower-farming",
                ItemUrl(109127),
                WOD_GATHERING_GUIDE,
            }, false
        ),
        HerbRoute(
            "warlords-starflower-shadowmoon-valley-supplied-alternative-1", 2,
            539, "Shadowmoon Valley (Draenor)", "2. Alternative 1 - Burial Fields figure-eight",
            { 39005300, 45005000, 51005300, 55005900, 54006700, 58007300, 53007700, 48007100, 44006500, 39007000, 36006400, 40005900 },
            {
                "Focus on southern wooded ground around the Burial Fields.",
                "The shorter loop may be advantageous when the northern route is heavily farmed.",
            },
            {
                "https://github.com/Cion6982/retail-farm-routes/blob/main/Routes%20-%20Warlords%20of%20Draenor/Starflower.txt",
                "https://www.wow-professions.com/farming/starflower-farming",
                ItemUrl(109127),
                WOD_GATHERING_GUIDE,
            }, false
        ),
        HerbRoute(
            "warlords-starflower-spires-of-arak-supplied-alternative-2", 3,
            542, "Spires of Arak", "3. Alternative 2 - Spires of Arak northern groves (Experimental)",
            { 31003700, 36003100, 43003000, 49003400, 53004100, 49004800, 44005000, 38004600, 34004200 },
            {
                "This is a mixed-herb alternative where Starflower has documented spawn records.",
                "Do not treat the route as yield-optimized until you test several complete laps.",
                "Experimental candidate: compare herbs collected over several complete laps before relying on this route.",
            },
            {
                "https://github.com/Cion6982/retail-farm-routes/blob/main/Routes%20-%20Warlords%20of%20Draenor/Starflower.txt",
                "https://www.wow-professions.com/farming/starflower-farming",
                ItemUrl(109127),
                WOD_GATHERING_GUIDE,
            }, true
        ),
    },
    [109128] = {
        HerbRoute(
            "warlords-nagrand-arrowbloom-nagrand-supplied-main", 1,
            550, "Nagrand (Draenor)", "1. Main route - Throne of the Elements and Ring of Trials",
            { 57002700, 65002400, 72002500, 78002900, 83003600, 80004400, 75004600, 70005300, 64005900, 59006200, 54005800, 57005000, 62004500, 59003800, 54003500 },
            {
                "Prioritize accessible grassy plains between the Throne of the Elements and Ring of Trials.",
                "Avoid flying long distances around cliff faces or through heavily fortified camps.",
            },
            {
                "https://github.com/Cion6982/retail-farm-routes/blob/main/Routes%20-%20Warlords%20of%20Draenor/Nagrand-Arrowbloom.txt",
                "https://www.wow-professions.com/farming/nagrand-arrowbloom-farming",
                ItemUrl(109128),
                WOD_GATHERING_GUIDE,
            }, false
        ),
        HerbRoute(
            "warlords-nagrand-arrowbloom-nagrand-supplied-alternative-1", 2,
            550, "Nagrand (Draenor)", "2. Alternative 1 - Oshu'gun and southern grasslands",
            { 36005400, 22004900, 49004800, 54005500, 53006200, 48006900, 47007800, 40008200, 34007800, 30006800, 32006100 },
            {
                "Sweep the open grass near Oshu'gun and the southern approaches to Telaar.",
                "Prioritize lowlands and gentle ridges rather than climbing steep rock faces.",
            },
            {
                "https://github.com/Cion6982/retail-farm-routes/blob/main/Routes%20-%20Warlords%20of%20Draenor/Nagrand-Arrowbloom.txt",
                "https://www.wow-professions.com/farming/nagrand-arrowbloom-farming",
                ItemUrl(109128),
                WOD_GATHERING_GUIDE,
            }, false
        ),
        HerbRoute(
            "warlords-nagrand-arrowbloom-spires-of-arak-supplied-alternative-2", 3,
            542, "Spires of Arak", "3. Alternative 2 - Spires of Arak lower forest (Experimental)",
            { 40005200, 48004900, 56005100, 63005700, 61006400, 55007100, 48007300, 42006800, 37006100 },
            {
                "This is a cross-zone mixed-herb experiment rather than a dedicated Arrowbloom route.",
                "Use the Nagrand alternatives first if maximizing Arrowbloom specifically.",
                "Experimental candidate: compare herbs collected over several complete laps before relying on this route.",
            },
            {
                "https://github.com/Cion6982/retail-farm-routes/blob/main/Routes%20-%20Warlords%20of%20Draenor/Nagrand-Arrowbloom.txt",
                "https://www.wow-professions.com/farming/nagrand-arrowbloom-farming",
                ItemUrl(109128),
                WOD_GATHERING_GUIDE,
            }, true
        ),
    },
    [109129] = {
        HerbRoute(
            "warlords-talador-orchid-talador-supplied-main", 1,
            535, "Talador", "1. Main route - Tuurem and eastern waterways",
            { 57002000, 62001600, 66002100, 64002800, 70003100, 75003800, 77004600, 73005100, 70006100, 64006700, 59006200, 55005600, 53004800, 56004000, 54003300 },
            {
                "Farm grassy forest margins around Tuurem and the eastern waterways.",
                "Concentrate on green clearings rather than traversing Shattrath or bare rocky areas.",
            },
            {
                "https://github.com/Cion6982/retail-farm-routes/blob/main/Routes%20-%20Warlords%20of%20Draenor/Talador-Orchid.txt",
                "https://www.wow-professions.com/farming/talador-orchid-farming",
                ItemUrl(109129),
                WOD_GATHERING_GUIDE,
            }, false
        ),
        HerbRoute(
            "warlords-talador-orchid-talador-supplied-alternative-1", 2,
            535, "Talador", "2. Alternative 1 - Southeast lakes and ruins",
            { 49005500, 55005800, 61006300, 67006900, 70007500, 66008200, 60008500, 54008000, 49007500, 45006800, 46006100 },
            {
                "Use this more compact route when the main eastern circuit has long empty stretches.",
                "Skirt lakes and ruins without spending time in deep water or inside structures.",
            },
            {
                "https://github.com/Cion6982/retail-farm-routes/blob/main/Routes%20-%20Warlords%20of%20Draenor/Talador-Orchid.txt",
                "https://www.wow-professions.com/farming/talador-orchid-farming",
                ItemUrl(109129),
                WOD_GATHERING_GUIDE,
            }, false
        ),
        HerbRoute(
            "warlords-talador-orchid-spires-of-arak-supplied-alternative-2", 3,
            542, "Spires of Arak", "3. Alternative 2 - Spires of Arak border area (Experimental)",
            { 28003300, 35002900, 43003300, 48003900, 52004600, 47005300, 4005500, 30004200 },
            {
                "Scout the northern Spires region closest to Talador.",
                "Treat this route as experimental; the primary Talador routes are better candidates for Orchid-focused farming.",
                "Experimental candidate: compare herbs collected over several complete laps before relying on this route.",
                "The supplied import contains eight control points (indices 1-7 and 10), although its heading says nine. Available points are retained in order; no missing point is invented.",
                "The seventh supplied control point decodes to 4.0%, 55.0%. Verify that western detour in game before following it; the original coordinate is preserved.",
            },
            {
                "https://github.com/Cion6982/retail-farm-routes/blob/main/Routes%20-%20Warlords%20of%20Draenor/Talador-Orchid.txt",
                "https://www.wow-professions.com/farming/talador-orchid-farming",
                ItemUrl(109129),
                WOD_GATHERING_GUIDE,
            }, true
        ),
    },
}

local function RegisterHerbalismMaterial(itemID, itemName, category, spots, summary)
    local routes = {}
    local sourceUrls = { ItemUrl(itemID), WOD_GATHERING_GUIDE, AOA_ROUTE_SOURCE }
    local seenSources = {}
    for _, url in ipairs(sourceUrls) do
        seenSources[url] = true
    end
    -- Give every supplied main/alternative its own dropdown option, before legacy routes.
    for _, spot in ipairs(SUPPLIED_HERB_ROUTES[itemID] or {}) do
        routes[#routes + 1] = spot
    end
    for _, spot in ipairs(spots) do
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
        professions = { "herbalism", "alchemy", "inscription" },
        category = category,
        isRoute = category == "Herb",
        sourceUrls = sourceUrls,
        summary = summary,
        spots = routes,
    })
end

RegisterHerbalismMaterial(109124, "Frostweed", "Herb", { FROSTFIRE_FROSTWEED_ROUTE, SHADOWMOON_STARFLOWER_ROUTE }, "Frostfire Ridge and Shadowmoon Valley zone herb; farm Frostfire snowfields for the cleanest loop.")
RegisterHerbalismMaterial(109125, "Fireweed", "Herb", { FROSTFIRE_FIREWEED_ROUTE }, "Frostfire Ridge lava herb; farm lava-pool chains rather than generic herb paths.")
RegisterHerbalismMaterial(109126, "Gorgrond Flytrap", "Herb", { GORGROND_FLYTRAP_ROUTE }, "Gorgrond and Spires herb; central Gorgrond remains the best dense outdoor target.")
RegisterHerbalismMaterial(109127, "Starflower", "Herb", { SHADOWMOON_STARFLOWER_ROUTE }, "Shadowmoon Valley zone herb from open groves and field edges.")
RegisterHerbalismMaterial(109128, "Nagrand Arrowbloom", "Herb", { NAGRAND_ARROWBLOOM_ROUTE }, "Nagrand zone herb from plains, tree lines, and water edges.")
RegisterHerbalismMaterial(109129, "Talador Orchid", "Herb", { TALADOR_ORCHID_ROUTE }, "Talador zone herb from central waterlines and meadow routes.")

RegisterHerbalismMaterial(109624, "Broken Frostweed Stem", "Herb Fragment", { FROSTFIRE_FROSTWEED_ROUTE, SHADOWMOON_STARFLOWER_ROUTE }, "Low-skill herbalism fragment from Frostweed nodes; combine ten into Frostweed.")
RegisterHerbalismMaterial(109625, "Broken Fireweed Stem", "Herb Fragment", { FROSTFIRE_FIREWEED_ROUTE }, "Low-skill herbalism fragment from Fireweed nodes; combine ten into Fireweed.")
RegisterHerbalismMaterial(109626, "Gorgrond Flytrap Ichor", "Herb Fragment", { GORGROND_FLYTRAP_ROUTE }, "Low-skill herbalism fragment from Gorgrond Flytrap nodes; combine ten into Gorgrond Flytrap.")
RegisterHerbalismMaterial(109627, "Starflower Petal", "Herb Fragment", { SHADOWMOON_STARFLOWER_ROUTE }, "Low-skill herbalism fragment from Starflower nodes; combine ten into Starflower.")
RegisterHerbalismMaterial(109628, "Nagrand Arrowbloom Petal", "Herb Fragment", { NAGRAND_ARROWBLOOM_ROUTE }, "Low-skill herbalism fragment from Nagrand Arrowbloom nodes; combine ten into Nagrand Arrowbloom.")
RegisterHerbalismMaterial(109629, "Talador Orchid Petal", "Herb Fragment", { TALADOR_ORCHID_ROUTE }, "Low-skill herbalism fragment from Talador Orchid nodes; combine ten into Talador Orchid.")
RegisterHerbalismMaterial(116053, "Draenic Seeds", "Seed", { FROSTFIRE_FROSTWEED_ROUTE, NAGRAND_ARROWBLOOM_ROUTE, TALADOR_ORCHID_ROUTE, TANAAN_HERB_ROUTE }, "Draenor herb-gathering byproduct from outdoor herb nodes and Withered Herb nodes in Tanaan.")
