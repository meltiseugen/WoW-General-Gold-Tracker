local _, NS = ...
local Register = NS.RegisterMaterialFarmingSpot

local HERB_INDEX = "https://www.wow-professions.com/farming/herbs"
local HERBALISM_GUIDE = "https://www.wowhead.com/guide/herbalism-leveling-1-300-wow-classic"
local EARLY_HERB_GUIDE = "https://www.wowhead.com/guide/classic-herbalism-best-farming-basics-early-herbs"

local function C(x, y, label)
    return { x = x, y = y, label = label }
end

local function ItemUrl(itemID)
    return "https://www.wowhead.com/item=" .. tostring(itemID)
end

local function HerbUrl(slug)
    return "https://www.wow-professions.com/farming/" .. slug .. "-farming"
end

local ROUTES = {
    durotarStarter = {
        urls = { HERB_INDEX, EARLY_HERB_GUIDE, HERBALISM_GUIDE, HerbUrl("peacebloom-and-silverleaf") },
        mapName = "Durotar",
        location = "Razor Hill, Tiragarde Keep, Drygulch, and Skull Rock beginner herb loop",
        routeType = "herbalism-loop",
        density = "High",
        difficulty = "Easy. Peacebloom grows in open ground and Silverleaf follows trees/ridges.",
        tips = {
            "Circle Razor Hill and the nearby ridges instead of crossing the whole zone.",
            "Pick both Peacebloom and Silverleaf because their low-level nodes overlap heavily.",
            "Move to The Barrens once competition or green skill gains slow the route.",
        },
        coords = {
            C(0.520, 0.230, "Skull Rock herb checks"),
            C(0.480, 0.340, "Razor Hill west field"),
            C(0.555, 0.418, "Tiragarde Keep tree line"),
            C(0.438, 0.482, "Drygulch ridge herbs"),
            C(0.522, 0.548, "Southfury herb edge"),
        },
    },
    barrensLow = {
        urls = { HERB_INDEX, EARLY_HERB_GUIDE, HERBALISM_GUIDE, HerbUrl("briarthorn"), HerbUrl("mageroyal"), HerbUrl("swiftthistle") },
        mapName = "The Barrens",
        location = "Oasis and road-edge herb loop through Stagnant Oasis, Forgotten Pools, and Lushwater Oasis",
        routeType = "herbalism-loop",
        density = "Medium to high",
        difficulty = "Good low-level route. Swiftthistle is a bonus from Briarthorn and Mageroyal nodes.",
        tips = {
            "Pick every Briarthorn and Mageroyal node when targeting Swiftthistle.",
            "The oasis chain overlaps with Tin and early leather routes.",
            "Use the southern Barrens extension if the north oasis route is crowded.",
        },
        coords = {
            C(0.430, 0.246, "Stagnant Oasis herbs"),
            C(0.470, 0.314, "Lushwater Oasis herbs"),
            C(0.520, 0.374, "Forgotten Pools herbs"),
            C(0.546, 0.442, "Crossroads south herb edge"),
            C(0.456, 0.520, "Camp Taurajo north herb edge"),
        },
    },
    stonetalonMid = {
        urls = { HERB_INDEX, EARLY_HERB_GUIDE, HERBALISM_GUIDE, HerbUrl("bruiseweed"), HerbUrl("wild-steelbloom") },
        mapName = "Stonetalon Mountains",
        location = "Windshear Crag and cliff-side herb route for Bruiseweed and Wild Steelbloom",
        routeType = "cliff-herbalism-loop",
        density = "Medium",
        difficulty = "Moderate. Herbs sit on cliffs, ridges, and around camps, so detours matter.",
        tips = {
            "Wild Steelbloom is cliff-biased; follow zone walls and ledges.",
            "Bruiseweed appears around buildings, ruins, and tree lines near the same route.",
            "This route also overlaps Wool and Medium Leather farms.",
        },
        coords = {
            C(0.604, 0.654, "Windshear Crag north ledge"),
            C(0.664, 0.600, "Windshear Crag east ledge"),
            C(0.724, 0.764, "Webwinder Path ridge"),
            C(0.512, 0.714, "Sun Rock approach cliffs"),
            C(0.444, 0.596, "Stonetalon Peak approach"),
        },
    },
    duskwoodGrave = {
        urls = { HERB_INDEX, HERBALISM_GUIDE, HerbUrl("grave-moss"), "https://www.wowhead.com/item=3369/grave-moss" },
        mapName = "Duskwood",
        location = "Raven Hill graveyard and cemetery loops for Grave Moss",
        routeType = "graveyard-herbalism-loop",
        density = "Localized",
        difficulty = "Moderate. Grave Moss is strong when cemetery nodes are up, but there are not many spawn pockets.",
        tips = {
            "Sweep both Raven Hill cemetery and nearby crypt approaches.",
            "Add Duskwood Bruiseweed checks while waiting on graveyard respawns.",
            "Ignore long cross-zone travel unless you also need quest or cloth side value.",
        },
        coords = {
            C(0.192, 0.450, "Raven Hill cemetery west"),
            C(0.208, 0.424, "Raven Hill cemetery north"),
            C(0.232, 0.466, "Raven Hill cemetery east"),
            C(0.206, 0.520, "Raven Hill crypt approach"),
        },
    },
    arathiMid = {
        urls = { HERB_INDEX, HERBALISM_GUIDE, HerbUrl("kingsblood"), HerbUrl("goldthorn"), HerbUrl("fadeleaf"), "https://www.wowhead.com/object=1621/briarthorn", "https://www.wowhead.com/object=1624/kingsblood" },
        mapName = "Arathi Highlands",
        location = "Arathi open-field, hill, and ruin loop for Kingsblood, Goldthorn, Fadeleaf, and Khadgar's Whisker",
        routeType = "herbalism-loop",
        density = "Medium to high",
        difficulty = "Good, but routes are spread and often overlap quest traffic.",
        tips = {
            "Use the outer hills and Stromgarde approaches for the best mixed herb checks.",
            "Goldthorn favors hills and cliffs; Fadeleaf and Khadgar's Whisker are useful side targets.",
            "This route pairs naturally with Iron, Heavy Stone, and Heavy Leather.",
        },
        coords = {
            C(0.274, 0.372, "Northfold hill herbs"),
            C(0.392, 0.306, "Circle of West Binding herbs"),
            C(0.502, 0.432, "Central field herb checks"),
            C(0.596, 0.570, "Dabyrie's Farmstead herbs"),
            C(0.312, 0.746, "Stromgarde outer herb checks"),
        },
    },
    hinterlandsGoldthorn = {
        urls = { HERB_INDEX, HERBALISM_GUIDE, HerbUrl("goldthorn"), "https://www.wowhead.com/item=3821/goldthorn", "https://www.wowhead.com/object=2046/goldthorn" },
        mapName = "The Hinterlands",
        location = "Hinterlands cliff and hill loop for Goldthorn map-pin clusters",
        routeType = "cliff-herbalism-loop",
        density = "High for Goldthorn",
        difficulty = "Good. Goldthorn favors rocky hills and cliff texture, so the compact Hinterlands ridge loop is efficient.",
        tips = {
            "Trace hillsides and rocky outcrops instead of flat roads.",
            "Hinterlands is compact; use Arathi as a backup if the ridge loop is recently cleared.",
            "Pick nearby Khadgar's Whisker and Purple Lotus to keep shared herb spawns turning over.",
        },
        coords = {
            C(0.301, 0.663, "Southwest hill pin"),
            C(0.331, 0.621, "Quel'Danil west ridge"),
            C(0.387, 0.454, "Central north hill pin"),
            C(0.401, 0.504, "Central ridge pin"),
            C(0.439, 0.593, "Shadra'Alor approach"),
            C(0.522, 0.552, "Middenvale ridge"),
            C(0.672, 0.585, "Jintha'Alor west hills"),
            C(0.766, 0.683, "East cliff pin"),
            C(0.792, 0.579, "Northeast hill pin"),
        },
    },
    wetlandsWater = {
        urls = { HERB_INDEX, HERBALISM_GUIDE, HerbUrl("stranglekelp"), HerbUrl("liferoot") },
        mapName = "Wetlands",
        location = "Wetlands river-mouth and coastal route for Stranglekelp and Liferoot",
        routeType = "waterline-herb-loop",
        density = "Medium",
        difficulty = "Moderate. Swimming slows Stranglekelp routes unless movement tools are available.",
        tips = {
            "Follow the shore and river edge rather than cutting inland.",
            "Use underwater breathing or swim speed effects if your character has them.",
            "Liferoot can be added along river and marsh edges while moving between kelp pockets.",
        },
        coords = {
            C(0.100, 0.590, "Menethil coast kelp"),
            C(0.136, 0.462, "Bluegill Marsh waterline"),
            C(0.222, 0.376, "Green Belt river mouth"),
            C(0.336, 0.470, "Whelgar marsh waterline"),
            C(0.462, 0.396, "Angerfang river bend"),
        },
    },
    feralasSungrass = {
        urls = { HERB_INDEX, HERBALISM_GUIDE, HerbUrl("sungrass"), HerbUrl("purple-lotus") },
        mapName = "Feralas",
        location = "Feralas High Wilderness, Ruins of Isildien, and Gordunni herb circuit",
        routeType = "herbalism-loop",
        density = "Medium",
        difficulty = "Good high-mid route with useful cloth, leather, and ore side value.",
        tips = {
            "Use this route for Sungrass and Purple Lotus while collecting other high herbs.",
            "Check ruins and ogre areas closely; some herbs sit off the main road.",
            "Pair with Mageweave or Thick Leather farms if your class clears camps quickly.",
        },
        coords = {
            C(0.580, 0.526, "High Wilderness herb route"),
            C(0.612, 0.548, "Gordunni Outpost herbs"),
            C(0.596, 0.660, "Ruins of Isildien west herbs"),
            C(0.642, 0.694, "Ruins of Isildien east herbs"),
            C(0.726, 0.566, "Lower Wilds herb edge"),
        },
    },
    swampBlindweed = {
        urls = { HERB_INDEX, HERBALISM_GUIDE, HerbUrl("blindweed"), HerbUrl("liferoot") },
        mapName = "Swamp of Sorrows",
        location = "Full swamp zig-zag through pools and marsh edges for Blindweed, Liferoot, Fadeleaf, and Khadgar's Whisker",
        routeType = "swamp-herbalism-loop",
        density = "High for Blindweed",
        difficulty = "Good. The route is simple but wet terrain can slow movement.",
        tips = {
            "Zig-zag through the waterlogged middle instead of only tracing the zone border.",
            "Pick Liferoot and Fadeleaf along the way to keep node turnover useful.",
            "Use this as the default focused Blindweed route.",
        },
        coords = {
            C(0.168, 0.514, "Western swamp pools"),
            C(0.286, 0.380, "Fallow Sanctuary marsh edge"),
            C(0.444, 0.452, "Central swamp herbs"),
            C(0.606, 0.586, "Pool of Tears route"),
            C(0.784, 0.454, "Eastern swamp pools"),
        },
    },
    swampSorrowmoss = {
        urls = { HERB_INDEX, HERBALISM_GUIDE, HerbUrl("sorrowmoss"), "https://www.wowhead.com/item=13466/sorrowmoss", "https://www.wowhead.com/object=176587/sorrowmoss", "https://warcraft.wiki.gg/wiki/Sorrowmoss" },
        mapName = "Swamp of Sorrows",
        location = "Swamp of Sorrows waterline and pool-edge route for Sorrowmoss",
        routeType = "waterline-herb-loop",
        density = "High for Sorrowmoss",
        difficulty = "Good. Retail Sorrowmoss grows around Swamp of Sorrows pools and waterways.",
        tips = {
            "Follow pools, rivers, and marsh edges; do not waste time sweeping dry beach terrain.",
            "Use the Blindweed zig-zag as a side pass while checking Sorrowmoss waterlines.",
            "Keep Golden Sansam and Blindweed nodes cleared to improve overall herb turnover.",
        },
        coords = {
            C(0.156, 0.520, "Western pool edge"),
            C(0.210, 0.426, "Northwest waterline"),
            C(0.334, 0.384, "Fallow Sanctuary marsh edge"),
            C(0.466, 0.454, "Central water channel"),
            C(0.596, 0.522, "Pool of Tears north"),
            C(0.706, 0.442, "Eastern waterline"),
            C(0.832, 0.592, "Stagalbog marsh edge"),
            C(0.742, 0.714, "Southeast pool edge"),
            C(0.558, 0.694, "Pool of Tears south"),
            C(0.384, 0.616, "Central south waterline"),
        },
    },
    burningSteppesFirebloom = {
        urls = { HERB_INDEX, HERBALISM_GUIDE, HerbUrl("firebloom"), "https://www.wowhead.com/item=4625/firebloom", "https://www.wowhead.com/object=2866/firebloom" },
        mapName = "Burning Steppes",
        location = "Burning Steppes lava-chasm route for Firebloom, Sungrass, and Dreamfoil",
        routeType = "lava-herbalism-loop",
        density = "High for Firebloom",
        difficulty = "Moderate. Firebloom is concentrated around fiery trenches and lava seams.",
        tips = {
            "Stay near lava chasms and scorched ridges; Dreadmaul Rock itself is a weaker detour.",
            "Pick Sungrass and Dreamfoil while moving so herb spawns keep cycling.",
            "Use Searing Gorge or Tanaris as backups when the Burning Steppes loop is thin.",
        },
        coords = {
            C(0.424, 0.332, "Blackrock north lava ridge"),
            C(0.478, 0.382, "Western chasm pin"),
            C(0.542, 0.446, "Central lava crack"),
            C(0.602, 0.528, "Terror Wing Path lava edge"),
            C(0.676, 0.608, "Dreadmaul south chasm"),
            C(0.734, 0.534, "Eastern lava pocket"),
            C(0.690, 0.418, "Dreadmaul east ridge"),
            C(0.604, 0.316, "Flame Crest south ridge"),
            C(0.510, 0.284, "Blackrock pass return"),
        },
    },
    hinterlandsGhost = {
        urls = { HERB_INDEX, HERBALISM_GUIDE, HerbUrl("ghost-mushroom"), "https://www.wowhead.com/item=8845/ghost-mushroom" },
        mapName = "The Hinterlands",
        location = "Skulk Rock and cave mushroom checks for Ghost Mushroom",
        routeType = "cave-herbalism-loop",
        density = "Localized",
        difficulty = "Moderate to hard. Ghost Mushroom is cave-focused and respawn constrained.",
        tips = {
            "Prioritize cave interiors and entrances rather than normal outdoor herb paths.",
            "Use Maraudon if you prefer instance-style mushroom checks, but this entry keeps the open-world route mapped.",
            "Expect downtime if other herbalists recently swept the cave.",
        },
        coords = {
            C(0.570, 0.400, "Skulk Rock outer entrance"),
            C(0.584, 0.438, "Skulk Rock upper cave"),
            C(0.598, 0.462, "Skulk Rock inner cave"),
            C(0.554, 0.480, "Skulk Rock lower mushrooms"),
        },
    },
    felwoodHigh = {
        urls = { HERB_INDEX, HERBALISM_GUIDE, HerbUrl("gromsblood"), HerbUrl("golden-sansam"), HerbUrl("dreamfoil") },
        mapName = "Felwood",
        location = "Full-zone Felwood corrupted herb route for Gromsblood, Golden Sansam, Dreamfoil, and side Purple Lotus",
        routeType = "herbalism-loop",
        density = "High mixed-herb density",
        difficulty = "Good. Felwood is compact for high herbs and pairs with demon cloth farms.",
        tips = {
            "Run north-south through corrupted camps and forest edges rather than cutting straight roads.",
            "Pick every high herb so Golden Sansam, Dreamfoil, and Gromsblood nodes keep cycling.",
            "Pair with Runecloth/Felcloth and Timbermaw side value.",
        },
        coords = {
            C(0.488, 0.176, "Irontree Woods herb checks"),
            C(0.426, 0.382, "Bloodvenom Falls herbs"),
            C(0.390, 0.564, "Jaedenar edge herbs"),
            C(0.482, 0.736, "Jadefire Run herbs"),
            C(0.598, 0.842, "Deadwood Village herbs"),
        },
    },
    plaguelands = {
        urls = { HERB_INDEX, HERBALISM_GUIDE, HerbUrl("plaguebloom"), HerbUrl("dreamfoil"), HerbUrl("mountain-silversage") },
        mapName = "Eastern Plaguelands",
        location = "Eastern Plaguelands endgame herb loop through Plaguewood, Corin's Crossing, and Light's Hope ridges",
        routeType = "herbalism-loop",
        density = "Medium to high",
        difficulty = "Moderate. High-value herbs are spread and commonly contested.",
        tips = {
            "Use Plaguelands when Plaguebloom is the target.",
            "Mountain Silversage favors ridges and higher terrain on the same circuit.",
            "Dreamfoil and Golden Sansam are useful side pickups while maintaining node turnover.",
        },
        coords = {
            C(0.224, 0.240, "Plaguewood northwest herbs"),
            C(0.336, 0.462, "Corin's Crossing herbs"),
            C(0.526, 0.648, "Lake Mereldar herb edge"),
            C(0.684, 0.566, "Light's Hope ridge herbs"),
            C(0.760, 0.338, "Northpass tower herbs"),
        },
    },
    winterspringIcecap = {
        urls = { HERB_INDEX, HERBALISM_GUIDE, HerbUrl("icecap"), HerbUrl("mountain-silversage") },
        mapName = "Winterspring",
        location = "Winterspring snowy ridge loop for Icecap and Mountain Silversage",
        routeType = "snow-herbalism-loop",
        density = "Medium",
        difficulty = "Moderate. Winterspring terrain and high-level mobs make the loop slower.",
        tips = {
            "Use Winterspring when Icecap is the target; it is the signature high-level herb of the zone.",
            "Follow ridges and open snowfields rather than just the road.",
            "Pair with Rugged Leather and Thorium checks when possible.",
        },
        coords = {
            C(0.604, 0.164, "Frostsaber Rock herbs"),
            C(0.666, 0.348, "Lake Kel'Theril ridge herbs"),
            C(0.592, 0.522, "Everlook east herbs"),
            C(0.502, 0.640, "Owl Wing Thicket herbs"),
            C(0.386, 0.764, "Darkwhisper Gorge approach herbs"),
        },
    },
    silithusBlackLotus = {
        urls = { HERB_INDEX, HERBALISM_GUIDE, "https://www.wowhead.com/item=13468/black-lotus", "https://www.wowhead.com/object=176589/black-lotus" },
        mapName = "Silithus",
        location = "Silithus rare Black Lotus spawn circuit from retail Wowhead object pin clusters and comments",
        routeType = "rare-herbalism-loop",
        density = "Rare but targetable",
        difficulty = "Hard. Black Lotus is rare; keep a wider Silithus herb loop moving to force spawn turnover.",
        tips = {
            "Use Zidormi to enter the old Silithus phase if the modern phase has no Classic herb spawns.",
            "Pick surrounding high herbs while checking lotus pins so the zone can recycle nodes.",
            "Expect long dry streaks; this is a rare-node route, not a volume herb farm.",
        },
        coords = {
            C(0.630, 0.536, "Hive'Zora north lotus pin"),
            C(0.621, 0.832, "South Silithus lotus pin"),
            C(0.453, 0.913, "Hive'Regal south lotus pin"),
            C(0.394, 0.851, "Hive'Regal west lotus pin"),
            C(0.198, 0.846, "Twilight Base Camp south pin"),
            C(0.384, 0.606, "Central Silithus lotus pin"),
            C(0.257, 0.588, "Southwest ridge lotus pin"),
            C(0.514, 0.504, "Central east lotus pin"),
            C(0.401, 0.467, "Cenarion Hold south pin"),
            C(0.206, 0.235, "Northwest Silithus lotus pin"),
            C(0.632, 0.387, "Hive'Ashi south lotus pin"),
        },
    },
}

local function RegisterHerb(itemID, itemName, summary, routeKey, extraUrls)
    local route = ROUTES[routeKey]
    local sourceUrls = { ItemUrl(itemID), HERB_INDEX, HERBALISM_GUIDE }
    for _, url in ipairs(route.urls or {}) do
        sourceUrls[#sourceUrls + 1] = url
    end
    for _, url in ipairs(extraUrls or {}) do
        sourceUrls[#sourceUrls + 1] = url
    end

    Register({
        itemID = itemID,
        itemName = itemName,
        expansion = "classic",
        professions = { "herbalism", "alchemy" },
        category = "Herb",
        researchStatus = "researched",
        sourceUrls = sourceUrls,
        summary = summary,
        spots = {
            {
                id = "classic-herb-" .. tostring(itemID) .. "-" .. routeKey,
                source = "Wowhead retail herb object/item pages, Wowhead comments, wow-professions route guides, and Warcraft Wiki herb notes",
                sourceUrls = route.urls,
                mapName = route.mapName,
                location = route.location,
                routeType = route.routeType,
                density = route.density,
                dropDifficulty = route.difficulty,
                tips = route.tips,
                coords = route.coords,
                confidence = "high",
            },
        },
    })
end

RegisterHerb(2447, "Peacebloom", "Starter herb gathered in open low-level terrain. Durotar gives a concrete Horde-friendly route with dense beginner nodes.", "durotarStarter")
RegisterHerb(765, "Silverleaf", "Starter herb gathered near trees and ridges in beginner zones. Durotar overlaps well with Peacebloom.", "durotarStarter")
RegisterHerb(785, "Mageroyal", "Low-level herb commonly farmed with Briarthorn around oasis and road-edge routes.", "barrensLow")
RegisterHerb(2450, "Briarthorn", "Low-level herb from tree bases and open routes; also a Swiftthistle source.", "barrensLow")
RegisterHerb(2452, "Swiftthistle", "Bonus herb gathered from Briarthorn and Mageroyal nodes. Farm those source nodes rather than searching for standalone Swiftthistle.", "barrensLow")
RegisterHerb(2453, "Bruiseweed", "Mid-level herb around structures, ridges, and tree/building edges.", "stonetalonMid")
RegisterHerb(3355, "Wild Steelbloom", "Mid-level cliff and hillside herb. Stonetalon gives a coordinate-backed ledge route.", "stonetalonMid")
RegisterHerb(3369, "Grave Moss", "Mid-level graveyard herb. Raven Hill in Duskwood is a compact targeted route.", "duskwoodGrave")
RegisterHerb(3356, "Kingsblood", "Mid-level open-field herb. Arathi provides useful mixed herb density and side farming.", "arathiMid")
RegisterHerb(3357, "Liferoot", "Water-edge herb gathered along rivers, lakes, and swamp routes.", "wetlandsWater")
RegisterHerb(3358, "Khadgar's Whisker", "Mid-high herb collected along Arathi and swamp routes as a regular route target.", "arathiMid")
RegisterHerb(3818, "Fadeleaf", "Mid-high herb from ruins and forested routes. Best treated as a side target on Arathi-style circuits.", "arathiMid")
RegisterHerb(3820, "Stranglekelp", "Water herb from coastlines and underwater routes. Wetlands gives a concrete waterline route.", "wetlandsWater")
RegisterHerb(3821, "Goldthorn", "Mid-level hill and cliff herb. Hinterlands gives a compact coordinate-backed ridge route.", "hinterlandsGoldthorn")
RegisterHerb(4625, "Firebloom", "High-mid hot-zone herb. Burning Steppes lava chasms give a focused retail route.", "burningSteppesFirebloom")
RegisterHerb(8831, "Purple Lotus", "High-level herb around ruins and outdoor highland routes, commonly paired with Sungrass and Dreamfoil farms.", "feralasSungrass")
RegisterHerb(8836, "Arthas' Tears", "Plaguelands-era herb gathered in undead and corrupted high-level zones.", "plaguelands")
RegisterHerb(8838, "Sungrass", "High-level open-area herb from Feralas, Tanaris, Hinterlands, and similar sunny routes.", "feralasSungrass")
RegisterHerb(8839, "Blindweed", "Swamp herb best targeted in Swamp of Sorrows with a zig-zag route.", "swampBlindweed")
RegisterHerb(8845, "Ghost Mushroom", "Cave mushroom from Hinterlands and Maraudon-style routes. Skulk Rock provides an open-world mapped route.", "hinterlandsGhost")
RegisterHerb(8846, "Gromsblood", "High-level demon/corruption herb. Felwood is the best mixed-herb route.", "felwoodHigh")
RegisterHerb(13463, "Dreamfoil", "Endgame herb from Felwood, Plaguelands, Un'Goro, Silithus, and similar high-level routes.", "plaguelands")
RegisterHerb(13464, "Golden Sansam", "High-level herb from Felwood and Swamp of Sorrows-style routes, often collected with Dreamfoil or Blindweed.", "felwoodHigh")
RegisterHerb(13465, "Mountain Silversage", "Endgame cliff and mountain herb. Winterspring gives a concrete ridge route.", "winterspringIcecap")
RegisterHerb(13466, "Sorrowmoss", "Retail replacement for the old Plaguebloom item ID, gathered around Swamp of Sorrows pools and waterlines.", "swampSorrowmoss")
RegisterHerb(13467, "Icecap", "Winterspring-specific high-level herb from snowy endgame routes.", "winterspringIcecap")
RegisterHerb(13468, "Black Lotus", "Rare endgame herb from old-world high-level zones. Silithus has explicit retail Wowhead pin clusters for a targeted route.", "silithusBlackLotus")
