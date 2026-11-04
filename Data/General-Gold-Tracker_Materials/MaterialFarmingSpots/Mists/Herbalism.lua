local _, NS = ...
local Register = NS.RegisterMaterialFarmingSpot

local function C(x, y, label)
    return { x = x, y = y, label = label }
end

local function ItemUrl(itemID)
    return "https://www.wowhead.com/item=" .. tostring(itemID)
end

local JADE_FOREST_HERB_ROUTE = {
    id = "mists-herbs-jade-forest-dawns-blossom-arboretum",
    source = "wow-professions Green Tea Leaf/Rain Poppy guides, retail xScarlife Routes import strings, and retail Wowhead herb pages",
    sourceUrls = {
        "https://www.wow-professions.com/farming/green-tea-leaf-farming",
        "https://www.wow-professions.com/farming/rain-poppy-farming",
        "https://xscarlife-gaming.com/farming-retail/",
        "https://www.wowhead.com/item=72234/green-tea-leaf",
        "https://www.wowhead.com/item=72237/rain-poppy",
    },
    mapName = "The Jade Forest",
    location = "Dawn's Blossom, Arboretum, Pearl Lake, and nearby river herb checks",
    routeType = "herbalism-loop",
    density = "High",
    dropDifficulty = "Excellent for Green Tea Leaf and Rain Poppy; Pearl Lake can be awkward for Horde because of Alliance guards.",
    tips = {
        "Use Jade Forest as the main Green Tea Leaf route and the best practical Rain Poppy zone.",
        "Follow water edges for Rain Poppy and cut through grassy sections for Green Tea Leaf.",
        "If a river section is dry, move to the next water pocket instead of waiting on respawns.",
    },
    coords = {
        C(0.4140, 0.1351, "Northern Green Tea route pin"),
        C(0.4739, 0.1557, "North forest sweep"),
        C(0.4724, 0.2153, "North river bend"),
        C(0.5167, 0.2082, "Tian-side herb pin"),
        C(0.5468, 0.2400, "Sri-La road check"),
        C(0.5121, 0.2381, "North-central return"),
        C(0.4928, 0.2506, "North-central herb pin"),
        C(0.4878, 0.2921, "Arboretum north"),
        C(0.5313, 0.2939, "Arboretum east"),
        C(0.5629, 0.3259, "Eastern forest bend"),
        C(0.4847, 0.3423, "Central Jade route"),
        C(0.4402, 0.3547, "Central Jade herb pin"),
        C(0.4217, 0.3862, "Central river return"),
        C(0.4074, 0.4477, "West river bend"),
        C(0.3804, 0.3494, "Western forest check"),
        C(0.3822, 0.2951, "Western route return"),
        C(0.3173, 0.3309, "West Jade extension"),
        C(0.3077, 0.2964, "West Jade return"),
        C(0.2986, 0.2309, "Northwest extension"),
        C(0.3351, 0.2098, "Northwest return"),
        C(0.3666, 0.2100, "North route close"),
        C(0.3658, 0.1632, "Northern close"),
    },
    confidence = "high",
}

local SILKWEED_ROUTE = {
    id = "mists-silkweed-valley-four-winds-waterline-loop",
    source = "wow-professions Silkweed guide and retail xScarlife Routes import string",
    sourceUrls = {
        "https://www.wow-professions.com/farming/silkweed-farming",
        "https://xscarlife-gaming.com/farming-retail/",
        "https://www.wowhead.com/item=72235/silkweed",
    },
    mapName = "Valley of the Four Winds",
    location = "Valley waterline checks around Halfhill, Pools of Purity, and central waterways",
    routeType = "waterline-herbalism-loop",
    density = "High",
    dropDifficulty = "Best practical Silkweed route because other zones have too few reliable spawns.",
    tips = {
        "Stay near water because Silkweed strongly favors waterline nodes.",
        "Do not idle on dry water sections; continue the loop and let respawns catch up.",
        "Combine with Green Tea Leaf pickups from nearby grass sections.",
    },
    coords = {
        C(0.3049, 0.2988, "Northwest waterline"),
        C(0.3537, 0.3115, "Northwest stream"),
        C(0.3778, 0.3452, "Northern water bend"),
        C(0.4282, 0.3427, "Central north water"),
        C(0.4528, 0.3093, "North canal check"),
        C(0.4828, 0.2934, "Halfhill north water"),
        C(0.5306, 0.2719, "Pool approach north"),
        C(0.5665, 0.4192, "Central waterline"),
        C(0.5980, 0.3975, "Paoquan water bend"),
        C(0.5815, 0.2855, "Northern return"),
        C(0.6143, 0.2895, "Northeast waterline"),
        C(0.6440, 0.3489, "Pool of Purity north"),
        C(0.6628, 0.3210, "Pool of Purity bend"),
        C(0.6535, 0.2598, "Far northeast water"),
        C(0.6990, 0.2974, "Northeast extension"),
        C(0.7458, 0.2683, "Far northeast extension"),
        C(0.8779, 0.2056, "Eastern water check"),
        C(0.8768, 0.2792, "Eastern return"),
        C(0.8608, 0.3274, "East waterline"),
        C(0.8371, 0.3478, "East water bend"),
        C(0.7873, 0.3918, "Southeast return"),
        C(0.7559, 0.4346, "Southeast waterline"),
        C(0.7143, 0.5543, "Southern water bend"),
        C(0.6787, 0.6073, "Southern river"),
        C(0.6522, 0.6547, "South return"),
        C(0.6133, 0.6973, "Southwest canal"),
        C(0.5712, 0.7350, "Southwest waterline"),
        C(0.5148, 0.7140, "Southwest bend"),
        C(0.4507, 0.7124, "West-south return"),
        C(0.3204, 0.7757, "Far southwest check"),
        C(0.2899, 0.6229, "Western stream return"),
        C(0.2963, 0.5506, "Western waterline"),
        C(0.2931, 0.4191, "Northwest close"),
        C(0.2920, 0.3485, "Northwest route close"),
    },
    confidence = "high",
}

local SNOW_LILY_ROUTE = {
    id = "mists-snow-lily-kunlai-summit-mountain-loop",
    source = "wow-professions Snow Lily guide and retail xScarlife Routes import string",
    sourceUrls = {
        "https://www.wow-professions.com/farming/snow-lily-farming",
        "https://xscarlife-gaming.com/farming-retail/",
        "https://www.wowhead.com/item=79010/snow-lily",
    },
    mapName = "Kun-Lai Summit",
    location = "Kun-Lai mountain herb route around central ridges and temple approaches",
    routeType = "herbalism-loop",
    density = "High",
    dropDifficulty = "Good targeted Snow Lily route, but vertical terrain slows characters without flying.",
    tips = {
        "Favor ridges and mountain approaches instead of lowland travel.",
        "Pick nearby Sha-Touched Herbs when they are safe because they can provide useful MoP herb side value.",
    },
    coords = {
        C(0.5121, 0.4842, "Central Snow Lily route pin"),
        C(0.5291, 0.4333, "Central ridge"),
        C(0.5637, 0.4330, "East central ridge"),
        C(0.5407, 0.4826, "Central return"),
        C(0.5886, 0.4871, "East ridge"),
        C(0.5919, 0.5669, "East-south ridge"),
        C(0.5533, 0.5345, "Central-south route"),
        C(0.5305, 0.5296, "Central return bend"),
        C(0.5098, 0.5359, "Southwest central"),
        C(0.5291, 0.5782, "Southern ridge"),
        C(0.5537, 0.6124, "South ridge"),
        C(0.5279, 0.6161, "Southwest ridge"),
        C(0.5002, 0.5904, "Southwest return"),
        C(0.4676, 0.6042, "West-south ridge"),
        C(0.4791, 0.6541, "Far southwest extension"),
        C(0.5100, 0.7023, "South extension"),
        C(0.4036, 0.7996, "Far southwest mountain"),
        C(0.3686, 0.7449, "Western mountain return"),
        C(0.3987, 0.7203, "West ridge check"),
        C(0.3708, 0.6812, "West ridge bend"),
        C(0.4512, 0.6545, "Southwest close"),
        C(0.4048, 0.5992, "West central ridge"),
        C(0.3573, 0.5826, "West mountain herbs"),
        C(0.3546, 0.5360, "West mountain close"),
        C(0.3859, 0.5095, "West central return"),
        C(0.4305, 0.5013, "Central-west return"),
        C(0.4415, 0.4578, "Central approach"),
        C(0.4705, 0.4782, "Central close"),
        C(0.4835, 0.5212, "Central route close"),
    },
    confidence = "high",
}

local FOOLS_CAP_ROUTE = {
    id = "mists-fools-cap-dread-wastes-briny-muck-lake-stars",
    source = "retail xScarlife Routes import string, retail Wowhead Fool's Cap comments, and wow-professions Fool's Cap guide",
    sourceUrls = {
        "https://xscarlife-gaming.com/farming-retail/",
        "https://www.wowhead.com/item=79011/fools-cap",
        "https://www.wow-professions.com/farming/fools-cap-farming",
    },
    mapName = "Dread Wastes",
    location = "The Briny Muck, Lake of Stars, Forgotten Mire, and muddy Sha-Touched Herb checks",
    routeType = "muddy-waterline-herbalism-loop",
    density = "Medium",
    dropDifficulty = "Rare and contested herb; comments note better results from Dread Wastes muddy areas and Sha-Touched Herbs.",
    tips = {
        "Circle Lake of Stars and The Briny Muck first, then check Forgotten Mire if the main loop is dry.",
        "Pick Sha-Touched Herbs when safe; comments and guides note they can yield Fool's Cap.",
        "Do not camp Townlong Steppes unless Dread Wastes is crowded because spawn density is weaker there.",
    },
    coords = {
        C(0.4232, 0.1112, "Northern Fool's Cap route pin"),
        C(0.4519, 0.1469, "North ridge herb"),
        C(0.4714, 0.1991, "North-central herb"),
        C(0.5235, 0.1959, "Kypari Vor herb"),
        C(0.5549, 0.1810, "Northeast herb"),
        C(0.5818, 0.1483, "Northeast loop"),
        C(0.6490, 0.1273, "Far northeast herb"),
        C(0.7019, 0.2331, "East ridge herb"),
        C(0.7173, 0.2909, "East route bend"),
        C(0.6835, 0.3320, "East return"),
        C(0.7045, 0.3531, "East pool check"),
        C(0.6765, 0.4493, "Lake approach"),
        C(0.6167, 0.5529, "Lake of Stars north"),
        C(0.6570, 0.5406, "Lake east herb"),
        C(0.6896, 0.5824, "Lake southeast"),
        C(0.6801, 0.6245, "Lake southeast return"),
        C(0.6550, 0.6501, "Lake south herb"),
        C(0.5995, 0.6255, "South lake return"),
        C(0.5855, 0.5809, "Lake west return"),
        C(0.5596, 0.5563, "Forgotten Mire approach"),
        C(0.5238, 0.5955, "Briny Muck east"),
        C(0.5146, 0.6380, "Briny Muck route"),
        C(0.4413, 0.6320, "Briny Muck west"),
        C(0.3997, 0.5371, "Western muck herb"),
        C(0.4087, 0.6406, "Southwest muck"),
        C(0.3807, 0.6952, "Southwest herb"),
        C(0.3782, 0.6012, "West muck return"),
        C(0.3521, 0.5293, "West muck north"),
        C(0.3531, 0.6448, "Southwest loop"),
        C(0.3363, 0.7070, "Southwest extension"),
        C(0.3239, 0.6015, "Western route close"),
        C(0.3041, 0.5316, "West close"),
        C(0.3038, 0.6193, "Southwest close"),
        C(0.2930, 0.6826, "Southwest final"),
        C(0.2708, 0.5141, "Far west check"),
        C(0.3410, 0.4179, "Northwest return"),
        C(0.3706, 0.3432, "Northwest herb"),
        C(0.3592, 0.2854, "Northwest bend"),
        C(0.3216, 0.3131, "Northwest route close"),
        C(0.2826, 0.2829, "Far northwest herb"),
        C(0.3299, 0.2059, "North return"),
        C(0.3692, 0.1608, "North route close"),
    },
    confidence = "high",
}

local FOOLS_CAP_WINDWARD_ROUTE = {
    id = "mists-fools-cap-jade-forest-windward-slitherscale",
    source = "Wowhead Fool's Cap comments and Windward Isle route notes",
    sourceUrls = {
        "https://www.wowhead.com/item=79011/fools-cap",
        "https://www.wowhead.com/zone=5785/the-jade-forest",
    },
    mapName = "The Jade Forest",
    location = "Windward Isle Slitherscale Ripper camp",
    routeType = "localized-herbalism-loop",
    density = "Medium to high",
    dropDifficulty = "Comment-backed post-nerf spot; mobs around the herbs make it better for level 90 characters.",
    tips = {
        "Use the camp around 68,30 as the anchor, then sweep nearby Windward Isle herb nodes.",
        "The comment reports very quick respawns, but the camp is mob-heavy.",
        "Use this as a compact alternative when Dread Wastes muddy routes are crowded.",
    },
    coords = {
        C(0.680, 0.300, "Slitherscale Ripper camp center"),
        C(0.656, 0.286, "West camp herb check"),
        C(0.704, 0.318, "East camp herb check"),
    },
    confidence = "medium",
}

local GOLDEN_LOTUS_ROUTES = {
    {
        id = "mists-golden-lotus-jade-forest-herb-side-gather",
        source = "Wowhead herb guide, Green Tea Leaf guide, Rain Poppy guide, and Golden Lotus item comments",
        sourceUrls = {
            "https://xscarlife-gaming.com/farming-retail/",
            "https://www.wow-professions.com/farming/green-tea-leaf-farming",
            "https://www.wowhead.com/item=72238/golden-lotus",
        },
        mapName = "The Jade Forest",
        location = "Dense Jade Forest herb loop for rare Golden Lotus side gathers",
        routeType = "rare-side-herb-loop",
        density = "Rare side gather",
        dropDifficulty = "Golden Lotus is a rare Pandaria herb; volume comes from clearing many normal herb nodes.",
        tips = {
            "Treat Golden Lotus as a side target while farming dense herb routes.",
            "Use Jade Forest when you also want Green Tea Leaf and Rain Poppy value.",
        },
        coords = JADE_FOREST_HERB_ROUTE.coords,
        confidence = "medium",
    },
    {
        id = "mists-golden-lotus-dread-wastes-sha-touched-herb-checks",
        source = "Fool's Cap item comments and wow-professions Fool's Cap guide",
        sourceUrls = {
            "https://www.wowhead.com/item=79011/fools-cap",
            "https://www.wow-professions.com/farming/fools-cap-farming",
        },
        mapName = "Dread Wastes",
        location = "Fool's Cap and Sha-Touched Herb loop for Golden Lotus side drops",
        routeType = "rare-side-herb-loop",
        density = "Rare side gather",
        dropDifficulty = "Best as a bonus while targeting Fool's Cap and Sha-Touched Herb nodes.",
        tips = {
            "Pick Sha-Touched Herbs along the Dread Wastes muddy route when safe.",
            "Use this route when Fool's Cap and Golden Lotus both have strong market value.",
        },
        coords = FOOLS_CAP_ROUTE.coords,
        confidence = "medium",
    },
}

-- Decoded from the 16 supplied Retail Routes reconstructions, preserving point order.
-- These are control points, not guaranteed herb spawns or in-game-tested optimized loops.
local function RouteCoords(label, packedCoords)
    local coords = {}
    for index, packed in ipairs(packedCoords) do
        local x = math.floor(packed / 10000)
        local y = packed % 10000
        coords[index] = C(x / 10000, y / 10000, string.format("%s pin %d", label, index))
    end
    return coords
end

local function HerbRoute(id, sortOrder, mapID, mapName, location, packedCoords, tips, sourceUrls)
    return {
        id = id,
        sortOrder = sortOrder,
        mapID = mapID,
        mapName = mapName,
        location = location,
        routeType = "herbalism-loop",
        source = "Supplied Retail Routes reconstruction with route-specific research references",
        sourceUrls = sourceUrls,
        dropDifficulty = "Reconstructed route control points, not guaranteed herb spawns. Not tested in WoW; check node density and quest phasing.",
        tips = tips,
        coords = RouteCoords(location, packedCoords),
        confidence = "medium",
        isRoute = true,
    }
end

local SUPPLIED_HERB_ROUTES = {
    [72234] = {
        HerbRoute(
            "mists-green-tea-leaf-the-jade-forest-supplied-main", 1,
            371, "The Jade Forest", "1. Main - Tian Monastery and Dawn’s Blossom northern loop",
            { 30002100, 35001400, 45001300, 57001500, 59002200, 68002600, 64003200, 57003700, 66004300, 54004200, 43003900, 32003400 },
            {
                "Follow the grassy edges north of Dawn's Blossom and around Tian Monastery rather than cutting through buildings.",
                "Prioritize tight elevation bands; skip barren cliff faces even when the line crosses them.",
                "Use this low-friction loop for consistent Green Tea Leaf pickup, then check the nearby parallel hillside.",
            },
            {
                "https://www.wow-professions.com/farming/green-tea-leaf-farming",
                "https://xscarlife-gaming.com/farming/retail/",
                "https://github.com/CallanWIT/Routes-Import-Export/blob/master/RoutesImportExport.lua",
                "https://github.com/WoWUIDev/Ace3/blob/master/AceSerializer-3.0/AceSerializer-3.0.lua",
            }
        ),
        HerbRoute(
            "mists-green-tea-leaf-valley-of-the-four-winds-supplied-alternative", 2,
            376, "Valley of the Four Winds", "2. Alternative - Paoquan Hollow to The Heartland hill sweep",
            { 15003400, 21002800, 32002800, 43003100, 53003600, 57004200, 49004500, 38004700, 26004400, 18004100 },
            {
                "Start beside Paoquan Hollow and circle through the Heartland's cultivated green slopes.",
                "Favor open grassy hills and terrace margins over village interiors or heavily used roads.",
                "Switch to the main Jade route if this longer mixed-herb sweep yields too many non-target nodes.",
            },
            {
                "https://www.wow-professions.com/farming/green-tea-leaf-farming",
                "https://xscarlife-gaming.com/farming/retail/",
                "https://github.com/CallanWIT/Routes-Import-Export/blob/master/RoutesImportExport.lua",
                "https://github.com/WoWUIDev/Ace3/blob/master/AceSerializer-3.0/AceSerializer-3.0.lua",
            }
        ),
    },
    [72237] = {
        HerbRoute(
            "mists-rain-poppy-the-jade-forest-supplied-main", 1,
            371, "The Jade Forest", "1. Main - Central Jade river and Serpent’s Heart banks",
            { 48004400, 56004800, 62005100, 67005700, 70006400, 64006800, 57006800, 51006100, 49005400 },
            {
                "Track stream and river margins around the Serpent's Heart rather than flying over inland hills.",
                "Pick Rain Poppy at bends, pools and near tributary banks; many straight river stretches have no nodes.",
                "Recheck spawn phasing at the Serpent's Heart; its environment changes with quest progression.",
            },
            {
                "https://www.wow-professions.com/farming/rain-poppy-farming",
                "https://xscarlife-gaming.com/farming/retail/",
                "https://github.com/CallanWIT/Routes-Import-Export/blob/master/RoutesImportExport.lua",
                "https://github.com/WoWUIDev/Ace3/blob/master/AceSerializer-3.0/AceSerializer-3.0.lua",
            }
        ),
        HerbRoute(
            "mists-rain-poppy-the-jade-forest-supplied-alternative", 2,
            371, "The Jade Forest", "2. Alternative - Southern lakes Pearlfin and Moonwater branch",
            { 55006800, 63007200, 71007100, 79007800, 80008400, 72008800, 62008500, 52007900 },
            {
                "Inspect the southern Jade Forest's ponds around Pearlfin and toward Moonwater Retreat.",
                "Horde characters should avoid Alliance guards near Pearl Lake or bypass that shore segment.",
                "This is a lower-density scouting fallback: abandon dry stretches quickly if node tracking stays empty.",
            },
            {
                "https://www.wow-professions.com/farming/rain-poppy-farming",
                "https://xscarlife-gaming.com/farming/retail/",
                "https://github.com/CallanWIT/Routes-Import-Export/blob/master/RoutesImportExport.lua",
                "https://github.com/WoWUIDev/Ace3/blob/master/AceSerializer-3.0/AceSerializer-3.0.lua",
            }
        ),
    },
    [72235] = {
        HerbRoute(
            "mists-silkweed-valley-of-the-four-winds-supplied-main", 1,
            376, "Valley of the Four Winds", "1. Main - Pools of Purity wetlands and east channels",
            { 55002400, 62002200, 70002500, 76003200, 81004100, 76004900, 66004800, 59003800, 54003200 },
            {
                "Follow the Pools of Purity around 60,27, then the neighboring channels toward Mudmug's Place.",
                "Stay close to water and low damp ground; the marked circuit includes transitions between pools.",
                "Use a flying mount to cut out empty upland crossings and shorten the loop on subsequent laps.",
            },
            {
                "https://www.wow-professions.com/farming/silkweed-farming",
                "https://xscarlife-gaming.com/farming/retail/",
                "https://github.com/CallanWIT/Routes-Import-Export/blob/master/RoutesImportExport.lua",
                "https://github.com/WoWUIDev/Ace3/blob/master/AceSerializer-3.0/AceSerializer-3.0.lua",
            }
        ),
        HerbRoute(
            "mists-silkweed-valley-of-the-four-winds-supplied-alternative", 2,
            376, "Valley of the Four Winds", "2. Alternative - Yan-Zhe southern riverside and Silken Fields",
            { 38006300, 49006300, 61005700, 72005900, 81005500, 88006000, 77006900, 65007100, 52007200, 40007000 },
            {
                "Circle the Silken Fields around 63,57 and sweep the southern river corridors.",
                "This covers a different wetland belt from Pools of Purity and often mixes Green Tea Leaf into the run.",
                "Near the Krasarang border, do not cross zones expecting the same Retail route/map ID to continue.",
            },
            {
                "https://www.wow-professions.com/farming/silkweed-farming",
                "https://xscarlife-gaming.com/farming/retail/",
                "https://github.com/CallanWIT/Routes-Import-Export/blob/master/RoutesImportExport.lua",
                "https://github.com/WoWUIDev/Ace3/blob/master/AceSerializer-3.0/AceSerializer-3.0.lua",
            }
        ),
    },
    [79010] = {
        HerbRoute(
            "mists-snow-lily-kun-lai-summit-supplied-main", 1,
            379, "Kun-Lai Summit", "1. Main - Peak of Serenity and Winter’s Blossom high slopes",
            { 32005400, 37004600, 43003800, 47002700, 51004200, 59003800, 66003200, 70004000, 61004800, 49005200, 38005800 },
            {
                "Work the snowy ridges and the approaches to Winter's Blossom, then climb toward Peak of Serenity.",
                "Watch different elevations for Snow Lily; flying saves time over the steep ridges.",
                "Snowy caves may have additional nodes, but are not included in the flight loop unless you detour on foot.",
            },
            {
                "https://www.wow-professions.com/farming/snow-lily-farming",
                "https://xscarlife-gaming.com/farming/retail/",
                "https://github.com/CallanWIT/Routes-Import-Export/blob/master/RoutesImportExport.lua",
                "https://github.com/WoWUIDev/Ace3/blob/master/AceSerializer-3.0/AceSerializer-3.0.lua",
            }
        ),
        HerbRoute(
            "mists-snow-lily-kun-lai-summit-supplied-alternative", 2,
            379, "Kun-Lai Summit", "2. Alternative - Kota Basecamp to Burlap Trail southern slopes",
            { 31006600, 39006400, 49006200, 61006000, 68006300, 68007000, 58007100, 47007300, 35007500 },
            {
                "Use the lower snowline from Kota Basecamp toward Burlap Trail as a less-common scouting option.",
                "Hug accessible slopes and ravine edges rather than repeatedly ascending sheer cliff faces.",
                "If the lower belt dries up, use the main route's higher ridges; node density may be lower here.",
            },
            {
                "https://www.wow-professions.com/farming/snow-lily-farming",
                "https://xscarlife-gaming.com/farming/retail/",
                "https://github.com/CallanWIT/Routes-Import-Export/blob/master/RoutesImportExport.lua",
                "https://github.com/WoWUIDev/Ace3/blob/master/AceSerializer-3.0/AceSerializer-3.0.lua",
            }
        ),
    },
    [79011] = {
        HerbRoute(
            "mists-fools-cap-dread-wastes-supplied-main", 1,
            422, "Dread Wastes", "1. Main - Briny Muck and Lake of Stars mud banks",
            { 28006100, 35005400, 43005300, 52005800, 61005800, 69006000, 74006600, 69007300, 60007600, 50007200, 41007600, 33007000 },
            {
                "Concentrate on muddy ground in the Briny Muck and the shallows surrounding Lake of Stars.",
                "Pick Sha-Touched Herb when it is safely accessible: it can give Fool's Cap in addition to Desecrated Herb.",
                "Avoid wide dry interior detours; repeat the wet belt if the loop takes longer than the respawn cycle.",
            },
            {
                "https://www.wowhead.com/object=214510/sha-touched-herb",
                "https://www.wow-professions.com/farming/fools-cap-farming",
                "https://xscarlife-gaming.com/farming/retail/",
                "https://github.com/CallanWIT/Routes-Import-Export/blob/master/RoutesImportExport.lua",
                "https://github.com/WoWUIDev/Ace3/blob/master/AceSerializer-3.0/AceSerializer-3.0.lua",
            }
        ),
        HerbRoute(
            "mists-fools-cap-townlong-steppes-supplied-alternative", 2,
            388, "Townlong Steppes", "2. Alternative - Sparse western marsh and shoreline test loop",
            { 28004300, 36003900, 45004300, 50005100, 47005900, 37006300, 28005500 },
            {
                "Scout muddy pockets and shoreline edges in western Townlong Steppes.",
                "Fool's Cap is sparse here; this is an experimental fallback, not a verified high-yield route.",
                "If tracking reveals no nodes after a lap, use the Dread Wastes main route rather than persist.",
            },
            {
                "https://www.wow-professions.com/farming/fools-cap-farming",
                "https://xscarlife-gaming.com/farming/retail/",
                "https://github.com/CallanWIT/Routes-Import-Export/blob/master/RoutesImportExport.lua",
                "https://github.com/WoWUIDev/Ace3/blob/master/AceSerializer-3.0/AceSerializer-3.0.lua",
            }
        ),
    },
    [72238] = {
        HerbRoute(
            "mists-golden-lotus-the-jade-forest-supplied-main", 1,
            371, "The Jade Forest", "1. Main - High turnover Green Tea Leaf replacement loop",
            { 29001900, 42001300, 59001700, 70003000, 68004300, 60004800, 48004700, 36003900, 30002900 },
            {
                "Clear every Pandaria herb in this dense Jade circuit; Golden Lotus can occupy rare herb-node spawns.",
                "Check open grassy patches as well as the usual Green Tea Leaf locations.",
                "Golden Lotus has no guaranteed spawn in a fixed point on this route; measure expected return over several laps.",
            },
            {
                "https://www.wowhead.com/object=209354/golden-lotus",
                "https://www.wow-professions.com/farming/green-tea-leaf-farming",
                "https://xscarlife-gaming.com/farming/retail/",
                "https://github.com/CallanWIT/Routes-Import-Export/blob/master/RoutesImportExport.lua",
                "https://github.com/WoWUIDev/Ace3/blob/master/AceSerializer-3.0/AceSerializer-3.0.lua",
            }
        ),
        HerbRoute(
            "mists-golden-lotus-valley-of-the-four-winds-supplied-alternative-1", 2,
            376, "Valley of the Four Winds", "2. Alternative 1 - All-herb multiloop for rare node replacement",
            { 18002800, 32002200, 48002100, 70002800, 88004200, 83006100, 62007300, 43007100, 25005900, 20004500 },
            {
                "Collect both Green Tea Leaf and Silkweed while sweeping the Valley's grass and water edges.",
                "Mixing habitats creates more chances to encounter rare Golden Lotus nodes or secondary loot.",
                "For less travel overhead, shorten this wide route around whichever half currently has visible herbs.",
            },
            {
                "https://www.wowhead.com/object=209354/golden-lotus",
                "https://www.wow-professions.com/farming/green-tea-leaf-farming",
                "https://www.wow-professions.com/farming/silkweed-farming",
                "https://xscarlife-gaming.com/farming/retail/",
                "https://github.com/CallanWIT/Routes-Import-Export/blob/master/RoutesImportExport.lua",
                "https://github.com/WoWUIDev/Ace3/blob/master/AceSerializer-3.0/AceSerializer-3.0.lua",
            }
        ),
        HerbRoute(
            "mists-golden-lotus-dread-wastes-supplied-alternative-2", 3,
            422, "Dread Wastes", "3. Alternative 2 - Sha-Touched Herb and Fool’s Cap lottery circuit",
            { 29003100, 45002900, 59003700, 73004400, 84005800, 74007200, 55007500, 37006400, 27004900 },
            {
                "Harvest Fool's Cap and Sha-Touched Herb along the corrupted Dread Wastes belts.",
                "Golden Lotus is a possible rare outcome; expect extended periods with none.",
                "Use the route primarily when Fool's Cap/Desecrated Herb sales justify the additional farming time.",
            },
            {
                "https://www.wowhead.com/object=209354/golden-lotus",
                "https://www.wow-professions.com/farming/fools-cap-farming",
                "https://www.wowhead.com/object=214510/sha-touched-herb",
                "https://xscarlife-gaming.com/farming/retail/",
                "https://github.com/CallanWIT/Routes-Import-Export/blob/master/RoutesImportExport.lua",
                "https://github.com/WoWUIDev/Ace3/blob/master/AceSerializer-3.0/AceSerializer-3.0.lua",
            }
        ),
    },
    [89639] = {
        HerbRoute(
            "mists-desecrated-herb-dread-wastes-supplied-main", 1,
            422, "Dread Wastes", "1. Main - Sha-corrupted middle and northwest circuit",
            { 31002900, 44003000, 57003600, 68004400, 62005300, 48005700, 34004800, 29003700 },
            {
                "Look specifically for Sha-Touched Herb in corrupted, black-and-white landscape pockets.",
                "Regular Fool's Cap nodes are not the direct source of Desecrated Herb; gather the Sha nodes.",
                "Skip individual nodes that are surrounded by multiple mobs if dismount/recovery costs outweigh the pickup.",
            },
            {
                "https://www.wowhead.com/object=214510/sha-touched-herb",
                "https://xscarlife-gaming.com/farming/retail/",
                "https://github.com/CallanWIT/Routes-Import-Export/blob/master/RoutesImportExport.lua",
                "https://github.com/WoWUIDev/Ace3/blob/master/AceSerializer-3.0/AceSerializer-3.0.lua",
            }
        ),
        HerbRoute(
            "mists-desecrated-herb-valley-of-the-four-winds-supplied-alternative-1", 2,
            376, "Valley of the Four Winds", "2. Alternative 1 - Stoneplow Sha spillover pocket short loop",
            { 13004400, 19004300, 24004700, 27005500, 23006100, 16005900, 12005200 },
            {
                "Run a short loop around the Stoneplow Fields Sha corruption instead of covering the whole Valley.",
                "Historic player reports mention fast Sha-Touched respawns here, but that is not verified for current Retail.",
                "If quest progression changes the Sha landscape, check node visibility before committing to a long session.",
            },
            {
                "https://www.wowhead.com/object=214510/sha-touched-herb",
                "https://xscarlife-gaming.com/farming/retail/",
                "https://github.com/CallanWIT/Routes-Import-Export/blob/master/RoutesImportExport.lua",
                "https://github.com/WoWUIDev/Ace3/blob/master/AceSerializer-3.0/AceSerializer-3.0.lua",
            }
        ),
        HerbRoute(
            "mists-desecrated-herb-kun-lai-summit-supplied-alternative-2", 3,
            379, "Kun-Lai Summit", "3. Alternative 2 - Localized Sha-tainted pocket scout sweep",
            { 33004900, 40004500, 45004200, 49004900, 46005600, 36005600 },
            {
                "Check smaller Sha-corrupted pockets in Kun-Lai rather than circling the entire mountain range.",
                "A short targeted loop can be practical only when Sha-Touched Herb nodes are visible.",
                "Treat it as exploratory: switch back to Dread Wastes if repeated passes are empty.",
            },
            {
                "https://www.wowhead.com/object=214510/sha-touched-herb",
                "https://xscarlife-gaming.com/farming/retail/",
                "https://github.com/CallanWIT/Routes-Import-Export/blob/master/RoutesImportExport.lua",
                "https://github.com/WoWUIDev/Ace3/blob/master/AceSerializer-3.0/AceSerializer-3.0.lua",
            }
        ),
    },
}

local function RegisterHerb(itemID, itemName, spots, summary)
    local routes = {}
    local sourceUrls = { ItemUrl(itemID) }
    local seenSources = { [sourceUrls[1]] = true }
    -- Supplied main/alternative routes come first; keep existing researched options.
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
        expansion = "mists",
        professions = { "herbalism", "alchemy", "inscription" },
        category = "Herb",
        isRoute = true,
        sourceUrls = sourceUrls,
        summary = summary,
        spots = routes,
    })
end

RegisterHerb(72234, "Green Tea Leaf", { JADE_FOREST_HERB_ROUTE }, "Common Pandaria herb; Jade Forest and Valley loops are the strongest practical farms.")
RegisterHerb(72235, "Silkweed", { SILKWEED_ROUTE }, "Waterline Pandaria herb best farmed in Valley of the Four Winds.")
RegisterHerb(72237, "Rain Poppy", { JADE_FOREST_HERB_ROUTE }, "Waterline Pandaria herb with Jade Forest as the best practical route.")
RegisterHerb(79010, "Snow Lily", { SNOW_LILY_ROUTE }, "Mountain Pandaria herb best targeted in Kun-Lai Summit.")
RegisterHerb(79011, "Fool's Cap", { FOOLS_CAP_ROUTE, FOOLS_CAP_WINDWARD_ROUTE }, "Muddy-water Pandaria herb best targeted in Dread Wastes, with Windward Isle as a compact comment-backed backup.")
RegisterHerb(72238, "Golden Lotus", GOLDEN_LOTUS_ROUTES, "Rare MoP herb side gather from high-volume Pandaria herb routes.")

RegisterHerb(89639, "Desecrated Herb", {}, "Gather Sha-Touched Herb in corrupted Pandaria areas for Desecrated Herb; it is a loot result, not a dedicated herb node.")
