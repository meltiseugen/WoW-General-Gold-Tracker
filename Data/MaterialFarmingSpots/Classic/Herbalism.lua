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

local IMPORTED_ROUTES_SOURCE = "Retail Routes addon import strings supplied by the user and decoded into static route pins"

local function ImportedRouteCoords(labelPrefix, pins)
    local coords = {}
    for index, pin in ipairs(pins) do
        coords[index] = C(pin[1], pin[2], labelPrefix .. " pin " .. tostring(index))
    end

    return coords
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

local IMPORTED_HERB_ROUTE_DETAILS = {
    peaceSilverTirisfalMain = {
        location = "Tirisfal Glades Peacebloom and Silverleaf mixed circuit",
        routeType = "starter-herbalism-loop",
        difficulty = "Compact and relatively flat low-level loop for repeated fast laps.",
        tips = {
            "Do not skip Silverleaf while farming Peacebloom; clearing both keeps the area cycling.",
            "Favor open ground rather than entering buildings or ruins.",
            "If your lap catches the respawn cycle, widen it slightly instead of stopping.",
        },
    },
    peaceSilverElwynnAlt = {
        location = "Elwynn Forest wide Peacebloom and Silverleaf circuit",
        routeType = "starter-herbalism-loop",
        difficulty = "Wide Alliance-side low-level route that benefits from faster flying.",
        tips = {
            "Best if you want Peacebloom and Silverleaf simultaneously.",
            "Stay on open grass and forest edges.",
            "Do not over-follow roads; herbs often sit several yards away from the road.",
        },
    },
    earthrootMulgoreMain = {
        location = "Mulgore Earthroot hill and rock-face route",
        routeType = "cliff-herbalism-loop",
        difficulty = "Earthroot-focused route around hills, rock faces, and elevated terrain.",
        tips = {
            "Avoid spending too much time across the perfectly flat center.",
            "Follow the bases of hills instead of flying directly over their summits.",
            "This is an excellent herb route to combine with low-level mining.",
        },
    },
    earthrootDunMoroghAlt = {
        location = "Dun Morogh Earthroot cliff, hill, and quarry route",
        routeType = "cliff-herbalism-loop",
        difficulty = "More obstructive terrain than Mulgore, with good Copper Ore overlap.",
        tips = {
            "Favor cliffs, hills, and the quarry region.",
            "Use this when you simultaneously want Copper Ore.",
            "Avoid unnecessary altitude changes.",
        },
    },
    briarMageHillsbradMain = {
        location = "Hillsbrad Foothills Briarthorn, Mageroyal, and Swiftthistle circuit",
        routeType = "mixed-herbalism-loop",
        difficulty = "Useful multi-material Vanilla circuit through fields and rolling terrain.",
        tips = {
            "Pick Briarthorn and Mageroyal together because the two herbs overlap heavily.",
            "Gathering both herbs indirectly farms Swiftthistle.",
            "Fields and gently rolling terrain make herbs easy to spot.",
        },
    },
    briarMageDarkshoreAlt = {
        location = "Darkshore north-south Briarthorn and Mageroyal circuit",
        routeType = "mixed-herbalism-loop",
        difficulty = "Long narrow-zone route that is useful when Hillsbrad is busy.",
        tips = {
            "Use the natural north-south shape of Darkshore for a steady circuit.",
            "Sweep both inland terrain and forest edges.",
            "Keep the route moving rather than doubling back through the same stretch.",
        },
    },
    stranglekelpThousandNeedlesMain = {
        location = "Thousand Needles flooded Stranglekelp shoreline circuit",
        routeType = "waterline-herb-loop",
        difficulty = "Aquatic herb route; stay low and scan shorelines and submerged terrain.",
        tips = {
            "Scan shorelines and shallow submerged terrain.",
            "Do not fly high; stay low enough that aquatic nodes are easy to see on the minimap.",
            "Water Walking can help, but do not let it carry you too far from submerged nodes.",
        },
    },
    bruiseSteelbloomStranglethornMain = {
        location = "Northern Stranglethorn Bruiseweed and Wild Steelbloom ridge circuit",
        routeType = "cliff-herbalism-loop",
        difficulty = "Hilly jungle route where ridges, slopes, and cliff edges matter.",
        tips = {
            "Follow ridges and hillside terrain rather than cutting directly through dense jungle.",
            "Wild Steelbloom overlaps well here, so gather both herb families.",
            "Keep your altitude low enough to scan cliff edges.",
        },
    },
    graveMossDuskwoodMain = {
        location = "Duskwood targeted Grave Moss cemetery circuit",
        routeType = "graveyard-herbalism-loop",
        difficulty = "Short targeted route around graveyards and undead areas, not a whole-zone loop.",
        tips = {
            "Grave Moss concentrates around graveyards and undead areas.",
            "Move to the next graveyard if outdoor nodes are exhausted rather than waiting.",
            "Razorfen Downs can outperform outdoor farming, but this entry keeps the outdoor route mapped.",
        },
    },
    kingsbloodStranglethornMain = {
        location = "Northern Stranglethorn Kingsblood mixed ground route",
        routeType = "mixed-herbalism-loop",
        difficulty = "Covers open ground between hills because Kingsblood is less terrain-specific.",
        tips = {
            "Cover the open ground between the hills too.",
            "A mixed Bruiseweed, Steelbloom, and Kingsblood circuit is generally more efficient.",
            "Do not ignore the other useful nodes along the route.",
        },
    },
    wplKingsKhadgarFadeRoute = {
        location = "Western Plaguelands Kingsblood, Khadgar's Whisker, and Fadeleaf route",
        routeType = "mixed-herbalism-loop",
        difficulty = "Diversified Plaguelands route for several mid-high herbs.",
        tips = {
            "Use this when you also need Khadgar's Whisker or Fadeleaf.",
            "Because several herb types occupy the zone, clear anything useful.",
            "Do not exclusively hunt one herb while ignoring node turnover.",
        },
    },
    wplLiferootBlindweedRoute = {
        location = "Western Plaguelands Darrowmere Lake Liferoot and Blindweed shoreline route",
        routeType = "waterline-herb-loop",
        difficulty = "Water-adjacent route where shoreline micro-routing matters.",
        tips = {
            "Water is the important clue; Liferoot strongly favors river and lake banks.",
            "Darrowmere Lake is a particularly useful section.",
            "Fly just outside the shoreline rather than directly over the middle of the water.",
        },
    },
    eplLiferootKhadgarSungrassRoute = {
        location = "Eastern Plaguelands Liferoot, Khadgar's Whisker, and Sungrass route",
        routeType = "mixed-herbalism-loop",
        difficulty = "Mixed route following streams, pools, and water-adjacent ground.",
        tips = {
            "Follow streams, pools, and water-adjacent ground.",
            "This is a good mixed route with Sungrass and Khadgar's Whisker.",
            "Pick everything useful rather than attempting a single-herb lap.",
        },
    },
    fadeleafFeralasMain = {
        location = "Feralas Fadeleaf forest route",
        routeType = "forest-herbalism-loop",
        difficulty = "Dense vegetation route where minimap tracking is more important than visual spotting.",
        tips = {
            "Fly low enough to quickly land between trees.",
            "Combine with Blindweed where their distributions overlap.",
            "Use minimap tracking heavily because Feralas vegetation can hide herbs.",
        },
    },
    goldthornHinterlandsMain = {
        location = "The Hinterlands Goldthorn hill and cliff route",
        routeType = "cliff-herbalism-loop",
        difficulty = "Goldthorn-focused route that also works as a secondary Wildvine method.",
        tips = {
            "Follow the Goldthorn route and harvest every Goldthorn.",
            "Trace hillsides and rocky outcrops instead of flat roads.",
            "Use this if you also need Goldthorn itself.",
        },
    },
    goldthornArathiAlt = {
        location = "Arathi Highlands Goldthorn alternate ridge route",
        routeType = "cliff-herbalism-loop",
        difficulty = "Longer Goldthorn alternative through hills, cliffs, and mountain edges.",
        tips = {
            "Prioritize hills, cliffs, and mountain edges.",
            "Pick nearby mid-tier herbs while moving.",
            "Use this as a backup when the Hinterlands route is crowded.",
        },
    },
    firebloomBurningSteppesMain = {
        location = "Burning Steppes Firebloom hot-zone route",
        routeType = "lava-herbalism-loop",
        difficulty = "Compact Firebloom route through scorched and lava-adjacent terrain.",
        tips = {
            "Stay near lava chasms and scorched ridges.",
            "Pick Sungrass and Dreamfoil while moving when useful.",
            "Use Searing Gorge or Tanaris as backups when the loop is thin.",
        },
    },
    firebloomSearingGorgeAlt = {
        location = "Searing Gorge Firebloom lava and ash route",
        routeType = "lava-herbalism-loop",
        difficulty = "Alternative Firebloom route through rocky lava terrain.",
        tips = {
            "Trace lava edges and scorched ridges.",
            "Use this when Burning Steppes is busy.",
            "Stay low enough to see herbs against the ash-colored ground.",
        },
    },
    firebloomTanarisAlt = {
        location = "Tanaris desert Firebloom circuit",
        routeType = "desert-herbalism-loop",
        difficulty = "Open desert route with broad movement and easy visibility.",
        tips = {
            "Use the open terrain for fast complete laps.",
            "Check dunes and rocky transitions without overcommitting to detours.",
            "Use this as a simple backup Firebloom route.",
        },
    },
    purpleLotusFelwoodMain = {
        location = "Felwood Purple Lotus ruin-cluster route for Wildvine chances",
        routeType = "ruins-herbalism-loop",
        difficulty = "Point-to-point ruin route, not a random Felwood perimeter loop.",
        tips = {
            "Prioritize ruins because Purple Lotus grows around them.",
            "Do not just circle Felwood's forests randomly.",
            "Goldthorn can also provide Wildvine, so Goldthorn routes are worth considering if this is crowded.",
        },
    },
    sungrassThousandNeedlesMain = {
        location = "Thousand Needles Sungrass route",
        routeType = "open-ground-herbalism-loop",
        difficulty = "Dedicated Sungrass route through open Thousand Needles terrain.",
        tips = {
            "Keep moving through sunny open terrain.",
            "Pick compatible herbs along the route for turnover.",
            "Use this as the more dedicated Sungrass option.",
        },
    },
    blindweedFeralasMain = {
        location = "Feralas Jademir Lake and damp-terrain Blindweed route",
        routeType = "waterline-herb-loop",
        difficulty = "Shoreline-focused Blindweed loop that can outperform a broad Feralas circle.",
        tips = {
            "Concentrate heavily around water and damp terrain.",
            "Jademir Lake is particularly useful.",
            "Avoid wasting flight time through dry mountain sections.",
        },
    },
    ghostMushroomUngoroMain = {
        location = "Un'Goro Crater Fungal Rock cave Ghost Mushroom route",
        routeType = "cave-herbalism-loop",
        difficulty = "Cave farm, not a classic zone perimeter farm.",
        tips = {
            "Enter Fungal Rock and fully clear the cave's herb spawns.",
            "Use the route to guide you into and around the cave area rather than circling Un'Goro.",
            "Because nodes are concentrated, repeated cave sweeps can outperform large outdoor routes.",
        },
    },
    ghostMushroomZangarmarshAlt = {
        location = "Zangarmarsh Funggor Cavern Ghost Mushroom route",
        routeType = "cave-herbalism-loop",
        difficulty = "Burning Crusade zone cave route for the Classic Ghost Mushroom material.",
        tips = {
            "Although Zangarmarsh is TBC content, Ghost Mushroom itself is a Vanilla herb and still appears there in Retail.",
            "Use this when Un'Goro has another farmer clearing the cave.",
            "Focus on Funggor Cavern rather than a broad Zangarmarsh herb loop.",
        },
    },
    felwoodGromSansamRoute = {
        location = "Felwood Gromsblood, Golden Sansam, Dreamfoil, and Purple Lotus route",
        routeType = "mixed-herbalism-loop",
        difficulty = "High-value Felwood route where several useful Vanilla herbs coexist.",
        tips = {
            "Gather Gromsblood, Golden Sansam, Dreamfoil, and Purple Lotus rather than tunnel-visioning one herb.",
            "Felwood's long narrow geometry makes north-south circuits natural.",
            "Ruins are worth slight deviations because of Purple Lotus and Wildvine potential.",
        },
    },
    gromDreamBlastedLandsRoute = {
        location = "Blasted Lands Gromsblood and Dreamfoil route",
        routeType = "open-ground-herbalism-loop",
        difficulty = "Very open terrain with Retail Zidormi phase considerations.",
        tips = {
            "Check your Blasted Lands phase or Zidormi state.",
            "Changing the zone timeline can effectively give you another version of the zone.",
            "Pick Gromsblood and other useful herbs to help node turnover.",
        },
    },
    goldenSansamSwampMain = {
        location = "Swamp of Sorrows Golden Sansam continuous loop",
        routeType = "swamp-herbalism-loop",
        difficulty = "Straightforward continuous loop through dense swamp vegetation.",
        tips = {
            "Stay close to the ground because vegetation can visually obscure herbs.",
            "Pick other Vanilla herbs while looping for better total value.",
            "Use this when you want a simpler Golden Sansam-focused route.",
        },
    },
    silithusDreamSilversageLotusRoute = {
        location = "Silithus Dreamfoil, Mountain Silversage, and Black Lotus full clearing route",
        routeType = "rare-herbalism-loop",
        difficulty = "Diversified high-herb route where full clearing beats camping one icon.",
        tips = {
            "Clear everything useful in Silithus.",
            "Dreamfoil, Mountain Silversage, and Black Lotus are connected enough that a complete loop makes sense.",
            "Outer-zone loops are generally easier than repeatedly crossing central hive terrain.",
        },
    },
    winterspringSilversageIcecapLotusRoute = {
        location = "Winterspring Mountain Silversage, Icecap, and Black Lotus route",
        routeType = "snow-herbalism-loop",
        difficulty = "Mountain-edge and snowy-section route with excellent baseline herb value.",
        tips = {
            "Follow mountain bases and elevated edges rather than flying the flat center.",
            "Gather Mountain Silversage and Icecap simultaneously.",
            "Pick any Black Lotus you encounter while clearing the circuit.",
        },
    },
}

local function AddImportedHerbRoute(routeKey, mapName, labelPrefix, pins)
    local details = IMPORTED_HERB_ROUTE_DETAILS[routeKey] or {}
    ROUTES[routeKey] = {
        urls = { HERB_INDEX, HERBALISM_GUIDE },
        mapName = mapName,
        location = details.location or labelPrefix .. " imported circuit",
        routeType = details.routeType or "imported-herbalism-loop",
        density = details.density or "Route-backed",
        difficulty = details.difficulty or "Imported Routes addon circuit decoded into static pins.",
        tips = details.tips or {
            "Follow the pins as a complete loop rather than judging after a partial lap.",
            "Clear nearby overlapping herbs to keep the shared herb-node ecosystem cycling.",
            "Adjust slightly for terrain, caves, waterlines, and phased Retail zone state.",
        },
        coords = ImportedRouteCoords(labelPrefix, pins),
        source = IMPORTED_ROUTES_SOURCE,
        confidence = "high",
    }
end

AddImportedHerbRoute("peaceSilverTirisfalMain", "Tirisfal Glades", "Routes Tirisfal Peacebloom Silverleaf", {
    { 0.4592, 0.2929 },
    { 0.4887, 0.3010 },
    { 0.4924, 0.3797 },
    { 0.4758, 0.4223 },
    { 0.4773, 0.4792 },
    { 0.5293, 0.4855 },
    { 0.5558, 0.4694 },
    { 0.5972, 0.4292 },
    { 0.6966, 0.3229 },
    { 0.7390, 0.4372 },
    { 0.7293, 0.5770 },
    { 0.5553, 0.5814 },
    { 0.5632, 0.7178 },
    { 0.5332, 0.7224 },
    { 0.5171, 0.6519 },
    { 0.4346, 0.6232 },
    { 0.4185, 0.5314 },
    { 0.3467, 0.4686 },
    { 0.3786, 0.4413 },
    { 0.3901, 0.3963 },
    { 0.4303, 0.4107 },
    { 0.4069, 0.3679 },
})

AddImportedHerbRoute("peaceSilverElwynnAlt", "Elwynn Forest", "Routes Elwynn Peacebloom Silverleaf", {
    { 0.2700, 0.8700 },
    { 0.3300, 0.7500 },
    { 0.4300, 0.7400 },
    { 0.5500, 0.8100 },
    { 0.6700, 0.7800 },
    { 0.8000, 0.7000 },
    { 0.8400, 0.5500 },
    { 0.7700, 0.4200 },
    { 0.6700, 0.3300 },
    { 0.5500, 0.3100 },
    { 0.4200, 0.3600 },
    { 0.3200, 0.4700 },
    { 0.2500, 0.6000 },
})

AddImportedHerbRoute("earthrootMulgoreMain", "Mulgore", "Routes Mulgore Earthroot", {
    { 0.3300, 0.7400 },
    { 0.2900, 0.5900 },
    { 0.3100, 0.4200 },
    { 0.3800, 0.2700 },
    { 0.5100, 0.1900 },
    { 0.6200, 0.2400 },
    { 0.6800, 0.3900 },
    { 0.6700, 0.5500 },
    { 0.6000, 0.6900 },
    { 0.4900, 0.7800 },
})

AddImportedHerbRoute("earthrootDunMoroghAlt", "Dun Morogh", "Routes Dun Morogh Earthroot", {
    { 0.2000, 0.5600 },
    { 0.2700, 0.4000 },
    { 0.4000, 0.3100 },
    { 0.5300, 0.3100 },
    { 0.6400, 0.3800 },
    { 0.7200, 0.5100 },
    { 0.6900, 0.6500 },
    { 0.5700, 0.7200 },
    { 0.4300, 0.6900 },
    { 0.3100, 0.6400 },
})

AddImportedHerbRoute("briarMageHillsbradMain", "Hillsbrad Foothills", "Routes Hillsbrad Briarthorn Mageroyal", {
    { 0.4694, 0.1090 },
    { 0.5154, 0.1283 },
    { 0.5348, 0.1765 },
    { 0.5609, 0.1913 },
    { 0.5795, 0.2483 },
    { 0.5737, 0.2979 },
    { 0.5575, 0.3341 },
    { 0.5643, 0.3853 },
    { 0.5592, 0.4021 },
    { 0.5300, 0.3719 },
    { 0.5011, 0.4150 },
    { 0.5091, 0.4858 },
    { 0.4979, 0.4968 },
    { 0.4768, 0.4408 },
    { 0.4481, 0.4730 },
    { 0.4537, 0.5235 },
    { 0.4409, 0.5274 },
    { 0.4204, 0.4658 },
    { 0.4050, 0.4874 },
    { 0.3882, 0.4956 },
    { 0.3993, 0.4531 },
    { 0.3918, 0.4014 },
    { 0.3704, 0.3563 },
    { 0.3637, 0.2868 },
})

AddImportedHerbRoute("briarMageDarkshoreAlt", "Darkshore", "Routes Darkshore Briarthorn Mageroyal", {
    { 0.4200, 0.9100 },
    { 0.4800, 0.8200 },
    { 0.5000, 0.6900 },
    { 0.4400, 0.5800 },
    { 0.4000, 0.4500 },
    { 0.4300, 0.3200 },
    { 0.4900, 0.2100 },
    { 0.5500, 0.2500 },
    { 0.5600, 0.3900 },
    { 0.5200, 0.5200 },
    { 0.5500, 0.6700 },
    { 0.5000, 0.7900 },
})

AddImportedHerbRoute("stranglekelpThousandNeedlesMain", "Thousand Needles", "Routes Thousand Needles Stranglekelp", {
    { 0.3142, 0.2420 },
    { 0.3577, 0.2808 },
    { 0.3636, 0.3405 },
    { 0.3769, 0.4289 },
    { 0.4315, 0.4750 },
    { 0.4768, 0.4137 },
    { 0.5591, 0.4609 },
    { 0.6514, 0.4778 },
    { 0.6794, 0.5582 },
    { 0.5899, 0.5616 },
    { 0.5270, 0.5328 },
    { 0.4904, 0.5801 },
    { 0.4802, 0.5394 },
    { 0.4552, 0.5409 },
    { 0.4511, 0.5804 },
    { 0.4217, 0.5955 },
    { 0.3120, 0.5118 },
    { 0.3069, 0.3764 },
})

AddImportedHerbRoute("bruiseSteelbloomStranglethornMain", "Northern Stranglethorn", "Routes Northern Stranglethorn Bruiseweed Steelbloom", {
    { 0.2285, 0.1954 },
    { 0.4376, 0.2872 },
    { 0.5780, 0.1994 },
    { 0.6629, 0.3580 },
    { 0.6583, 0.4979 },
    { 0.6328, 0.7266 },
    { 0.5196, 0.5928 },
    { 0.4708, 0.5287 },
    { 0.4656, 0.3937 },
    { 0.3643, 0.3662 },
    { 0.2737, 0.3536 },
    { 0.2245, 0.3121 },
    { 0.2132, 0.2459 },
})

AddImportedHerbRoute("graveMossDuskwoodMain", "Duskwood", "Routes Duskwood Grave Moss", {
    { 0.1800, 0.3000 },
    { 0.2400, 0.3500 },
    { 0.3300, 0.3700 },
    { 0.4100, 0.3900 },
    { 0.4500, 0.6700 },
    { 0.3200, 0.7000 },
    { 0.2000, 0.6700 },
    { 0.1700, 0.5200 },
})

AddImportedHerbRoute("kingsbloodStranglethornMain", "Northern Stranglethorn", "Routes Northern Stranglethorn Kingsblood", {
    { 0.3704, 0.2165 },
    { 0.5097, 0.3486 },
    { 0.5535, 0.3456 },
    { 0.5544, 0.2762 },
    { 0.6182, 0.2748 },
    { 0.6159, 0.5506 },
    { 0.5722, 0.6146 },
    { 0.5184, 0.5921 },
    { 0.5236, 0.5193 },
    { 0.5184, 0.4243 },
    { 0.4853, 0.4173 },
    { 0.4565, 0.4834 },
    { 0.4179, 0.4939 },
    { 0.3998, 0.4333 },
    { 0.3430, 0.3832 },
    { 0.3625, 0.3133 },
    { 0.3271, 0.2917 },
    { 0.3183, 0.2456 },
})

AddImportedHerbRoute("wplKingsKhadgarFadeRoute", "Western Plaguelands", "Routes Western Plaguelands Kingsblood Khadgar Fadeleaf", {
    { 0.3300, 0.8200 },
    { 0.4500, 0.8000 },
    { 0.5700, 0.7800 },
    { 0.6700, 0.6700 },
    { 0.6600, 0.5300 },
    { 0.5900, 0.4200 },
    { 0.4700, 0.3600 },
    { 0.3600, 0.3900 },
    { 0.2800, 0.5000 },
    { 0.2500, 0.6500 },
})

AddImportedHerbRoute("wplLiferootBlindweedRoute", "Western Plaguelands", "Routes Western Plaguelands Liferoot Blindweed", {
    { 0.5500, 0.8300 },
    { 0.4900, 0.8000 },
    { 0.4300, 0.7400 },
    { 0.3900, 0.6600 },
    { 0.4200, 0.5800 },
    { 0.4900, 0.5500 },
    { 0.5600, 0.5800 },
    { 0.6100, 0.6500 },
    { 0.6300, 0.7300 },
    { 0.6000, 0.8000 },
})

AddImportedHerbRoute("eplLiferootKhadgarSungrassRoute", "Eastern Plaguelands", "Routes Eastern Plaguelands Liferoot Khadgar Sungrass", {
    { 0.0800, 0.6500 },
    { 0.1700, 0.7400 },
    { 0.2900, 0.7600 },
    { 0.4000, 0.7200 },
    { 0.5100, 0.6500 },
    { 0.6300, 0.6700 },
    { 0.7600, 0.6100 },
    { 0.8200, 0.4800 },
    { 0.7600, 0.3500 },
    { 0.6500, 0.2600 },
    { 0.5000, 0.2200 },
    { 0.3600, 0.2900 },
    { 0.2300, 0.3800 },
    { 0.1300, 0.4900 },
})

AddImportedHerbRoute("fadeleafFeralasMain", "Feralas", "Routes Feralas Fadeleaf", {
    { 0.6879, 0.4354 },
    { 0.7139, 0.3610 },
    { 0.7650, 0.3751 },
    { 0.8270, 0.3907 },
    { 0.8092, 0.4467 },
    { 0.7593, 0.4895 },
    { 0.7103, 0.6182 },
    { 0.6876, 0.5970 },
    { 0.6770, 0.5584 },
    { 0.6918, 0.5067 },
    { 0.6530, 0.5015 },
    { 0.6400, 0.5293 },
    { 0.6004, 0.6691 },
    { 0.5961, 0.7352 },
    { 0.5598, 0.7616 },
    { 0.5475, 0.6751 },
    { 0.5579, 0.5939 },
    { 0.5682, 0.5010 },
    { 0.6291, 0.4872 },
    { 0.6618, 0.4663 },
})

AddImportedHerbRoute("goldthornHinterlandsMain", "The Hinterlands", "Routes Hinterlands Goldthorn", {
    { 0.3378, 0.4415 },
    { 0.3735, 0.5250 },
    { 0.4043, 0.5158 },
    { 0.4254, 0.4344 },
    { 0.5483, 0.4010 },
    { 0.5532, 0.4642 },
    { 0.5834, 0.4868 },
    { 0.6549, 0.4452 },
    { 0.6971, 0.5084 },
    { 0.7406, 0.5493 },
    { 0.7100, 0.6130 },
    { 0.5928, 0.5326 },
    { 0.5553, 0.5398 },
    { 0.4792, 0.4925 },
    { 0.3996, 0.5921 },
    { 0.3552, 0.6550 },
    { 0.2869, 0.7113 },
    { 0.3116, 0.6103 },
})

AddImportedHerbRoute("goldthornArathiAlt", "Arathi Highlands", "Routes Arathi Goldthorn", {
    { 0.2226, 0.1899 },
    { 0.3139, 0.2904 },
    { 0.4317, 0.3940 },
    { 0.4925, 0.4966 },
    { 0.5362, 0.4526 },
    { 0.5510, 0.3586 },
    { 0.5946, 0.3425 },
    { 0.5905, 0.3012 },
    { 0.6247, 0.2733 },
    { 0.6646, 0.3016 },
    { 0.7044, 0.3298 },
    { 0.7227, 0.3948 },
    { 0.7232, 0.4641 },
    { 0.6661, 0.5235 },
    { 0.6608, 0.6072 },
    { 0.5362, 0.6007 },
    { 0.5148, 0.6360 },
    { 0.4681, 0.6313 },
    { 0.4646, 0.6832 },
    { 0.4301, 0.7128 },
    { 0.4193, 0.7719 },
    { 0.3891, 0.7942 },
    { 0.3722, 0.7655 },
    { 0.3292, 0.6982 },
    { 0.2861, 0.6484 },
    { 0.2379, 0.6952 },
    { 0.1792, 0.7285 },
    { 0.1453, 0.7448 },
    { 0.0996, 0.7410 },
    { 0.0777, 0.7047 },
    { 0.0957, 0.6551 },
    { 0.1447, 0.5855 },
    { 0.0874, 0.4528 },
    { 0.1550, 0.3214 },
    { 0.1786, 0.3328 },
    { 0.1940, 0.2965 },
    { 0.1888, 0.2557 },
})

AddImportedHerbRoute("firebloomBurningSteppesMain", "Burning Steppes", "Routes Burning Steppes Firebloom", {
    { 0.1400, 0.5300 },
    { 0.2200, 0.6300 },
    { 0.3600, 0.6500 },
    { 0.4800, 0.5800 },
    { 0.5800, 0.4800 },
    { 0.6900, 0.4500 },
    { 0.7900, 0.5200 },
    { 0.8400, 0.4000 },
    { 0.7500, 0.2900 },
    { 0.6100, 0.2800 },
    { 0.4800, 0.3600 },
    { 0.3400, 0.3800 },
    { 0.2200, 0.4400 },
})

AddImportedHerbRoute("firebloomSearingGorgeAlt", "Searing Gorge", "Routes Searing Gorge Firebloom", {
    { 0.2400, 0.7100 },
    { 0.3500, 0.7600 },
    { 0.5000, 0.7200 },
    { 0.6300, 0.6300 },
    { 0.7200, 0.4800 },
    { 0.6700, 0.3400 },
    { 0.5400, 0.2600 },
    { 0.4000, 0.2800 },
    { 0.2900, 0.3800 },
    { 0.2200, 0.5300 },
})

AddImportedHerbRoute("firebloomTanarisAlt", "Tanaris", "Routes Tanaris Firebloom", {
    { 0.3700, 0.1900 },
    { 0.5000, 0.2200 },
    { 0.6200, 0.2900 },
    { 0.7200, 0.3800 },
    { 0.7900, 0.5000 },
    { 0.7000, 0.6100 },
    { 0.6100, 0.7000 },
    { 0.4800, 0.7700 },
    { 0.3700, 0.7200 },
    { 0.2900, 0.6100 },
    { 0.2500, 0.4700 },
    { 0.3000, 0.3200 },
})

AddImportedHerbRoute("purpleLotusFelwoodMain", "Felwood", "Routes Felwood Purple Lotus Wildvine", {
    { 0.5700, 0.8500 },
    { 0.3800, 0.6800 },
    { 0.4000, 0.4500 },
    { 0.4200, 0.3600 },
    { 0.5000, 0.3100 },
})

AddImportedHerbRoute("sungrassThousandNeedlesMain", "Thousand Needles", "Routes Thousand Needles Sungrass", {
    { 0.3000, 0.5200 },
    { 0.3100, 0.3700 },
    { 0.3800, 0.2800 },
    { 0.4900, 0.2500 },
    { 0.6100, 0.3000 },
    { 0.7000, 0.4100 },
    { 0.6900, 0.5500 },
    { 0.6100, 0.6700 },
    { 0.4900, 0.7300 },
    { 0.3800, 0.6900 },
})

AddImportedHerbRoute("blindweedFeralasMain", "Feralas", "Routes Feralas Blindweed", {
    { 0.2700, 0.3500 },
    { 0.2200, 0.4000 },
    { 0.4000, 0.4800 },
    { 0.2400, 0.5600 },
    { 0.3100, 0.5800 },
    { 0.3500, 0.5100 },
    { 0.3500, 0.4200 },
    { 0.3100, 0.3600 },
    { 0.4700, 0.4500 },
    { 0.5200, 0.4800 },
    { 0.5400, 0.5600 },
    { 0.4900, 0.6100 },
    { 0.4400, 0.5700 },
})

AddImportedHerbRoute("ghostMushroomUngoroMain", "Un'Goro Crater", "Routes Un'Goro Ghost Mushroom", {
    { 0.6300, 0.1600 },
    { 0.6600, 0.1600 },
    { 0.6800, 0.1800 },
    { 0.6900, 0.2100 },
    { 0.6800, 0.2400 },
    { 0.6500, 0.2500 },
    { 0.6200, 0.2300 },
    { 0.6100, 0.2000 },
})

AddImportedHerbRoute("ghostMushroomZangarmarshAlt", "Zangarmarsh", "Routes Zangarmarsh Ghost Mushroom", {
    { 0.7500, 0.9100 },
    { 0.7700, 0.9200 },
    { 0.7800, 0.9000 },
    { 0.7700, 0.8800 },
    { 0.7500, 0.8800 },
})

AddImportedHerbRoute("felwoodGromSansamRoute", "Felwood", "Routes Felwood Gromsblood Golden Sansam", {
    { 0.4086, 0.3153 },
    { 0.4280, 0.2541 },
    { 0.4560, 0.2225 },
    { 0.4926, 0.2078 },
    { 0.5132, 0.2007 },
    { 0.5392, 0.2181 },
    { 0.5648, 0.2678 },
    { 0.4608, 0.3984 },
    { 0.4410, 0.4266 },
    { 0.4540, 0.4547 },
    { 0.4441, 0.4735 },
    { 0.4366, 0.5202 },
    { 0.4255, 0.5310 },
    { 0.4230, 0.5545 },
    { 0.4235, 0.5909 },
    { 0.4224, 0.6103 },
    { 0.4458, 0.6512 },
    { 0.4599, 0.6776 },
    { 0.4710, 0.7346 },
    { 0.4862, 0.7701 },
    { 0.5046, 0.8163 },
    { 0.5388, 0.8126 },
    { 0.5630, 0.8264 },
    { 0.5687, 0.8605 },
    { 0.5372, 0.8734 },
    { 0.5056, 0.8558 },
    { 0.4718, 0.8744 },
    { 0.4215, 0.8109 },
    { 0.4000, 0.7771 },
    { 0.3935, 0.7274 },
    { 0.3910, 0.6724 },
    { 0.4083, 0.6582 },
    { 0.4137, 0.6300 },
    { 0.3949, 0.5770 },
    { 0.3866, 0.5302 },
    { 0.3805, 0.4832 },
    { 0.3908, 0.4448 },
    { 0.3869, 0.4041 },
    { 0.4031, 0.3736 },
})

AddImportedHerbRoute("gromDreamBlastedLandsRoute", "Blasted Lands", "Routes Blasted Lands Gromsblood Dreamfoil", {
    { 0.3900, 0.1800 },
    { 0.5200, 0.1800 },
    { 0.6400, 0.2500 },
    { 0.7400, 0.3800 },
    { 0.7600, 0.5400 },
    { 0.6700, 0.6700 },
    { 0.5400, 0.7500 },
    { 0.4100, 0.7200 },
    { 0.3000, 0.6100 },
    { 0.2700, 0.4500 },
    { 0.3100, 0.3000 },
})

AddImportedHerbRoute("goldenSansamSwampMain", "Swamp of Sorrows", "Routes Swamp of Sorrows Golden Sansam", {
    { 0.1400, 0.5400 },
    { 0.2200, 0.6500 },
    { 0.3500, 0.6700 },
    { 0.4800, 0.6000 },
    { 0.6200, 0.6200 },
    { 0.7500, 0.5600 },
    { 0.8300, 0.4300 },
    { 0.7600, 0.3100 },
    { 0.6100, 0.2700 },
    { 0.4800, 0.3500 },
    { 0.3600, 0.3000 },
    { 0.2400, 0.3900 },
})

AddImportedHerbRoute("silithusDreamSilversageLotusRoute", "Silithus", "Routes Silithus Dreamfoil Silversage Black Lotus", {
    { 0.1800, 0.2900 },
    { 0.2900, 0.2000 },
    { 0.4300, 0.1800 },
    { 0.5800, 0.2200 },
    { 0.7000, 0.3100 },
    { 0.7900, 0.4400 },
    { 0.7800, 0.5900 },
    { 0.6900, 0.7200 },
    { 0.5500, 0.8000 },
    { 0.4000, 0.7800 },
    { 0.2700, 0.6900 },
    { 0.1800, 0.5600 },
    { 0.1400, 0.4200 },
})

AddImportedHerbRoute("winterspringSilversageIcecapLotusRoute", "Winterspring", "Routes Winterspring Silversage Icecap Black Lotus", {
    { 0.3100, 0.3700 },
    { 0.4000, 0.2800 },
    { 0.5300, 0.2400 },
    { 0.6500, 0.2900 },
    { 0.7300, 0.4000 },
    { 0.7600, 0.5300 },
    { 0.6900, 0.6400 },
    { 0.5700, 0.7000 },
    { 0.4500, 0.6800 },
    { 0.3500, 0.5900 },
    { 0.2800, 0.4800 },
})

local function NormalizeRouteKeys(routeKeys)
    if type(routeKeys) == "string" then
        return { routeKeys }
    end

    return routeKeys
end

local function RegisterHerb(itemID, itemName, summary, routeKeys, extraUrls)
    local spots = {}
    local normalizedRouteKeys = NormalizeRouteKeys(routeKeys)
    local sourceUrls = { ItemUrl(itemID), HERB_INDEX, HERBALISM_GUIDE }

    for _, routeKey in ipairs(normalizedRouteKeys) do
        local route = ROUTES[routeKey]
        for _, url in ipairs(route.urls or {}) do
            sourceUrls[#sourceUrls + 1] = url
        end
        spots[#spots + 1] = {
            id = "classic-herb-" .. tostring(itemID) .. "-" .. routeKey,
            source = route.source
                or "Wowhead retail herb object/item pages, Wowhead comments, wow-professions route guides, and Warcraft Wiki herb notes",
            sourceUrls = route.urls,
            mapName = route.mapName,
            location = route.location,
            routeType = route.routeType,
            density = route.density,
            dropDifficulty = route.difficulty,
            tips = route.tips,
            coords = route.coords,
            confidence = route.confidence or "high",
        }
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
        spots = spots,
    })
end

RegisterHerb(2447, "Peacebloom", "Starter herb gathered in open low-level terrain. Durotar gives a concrete Horde-friendly route with dense beginner nodes.", { "durotarStarter", "peaceSilverTirisfalMain", "peaceSilverElwynnAlt" })
RegisterHerb(765, "Silverleaf", "Starter herb gathered near trees and ridges in beginner zones. Durotar overlaps well with Peacebloom.", { "durotarStarter", "peaceSilverTirisfalMain", "peaceSilverElwynnAlt" })
RegisterHerb(2449, "Earthroot", "Starter herb gathered around hills, cliffs, and elevated low-level terrain.", { "earthrootMulgoreMain", "earthrootDunMoroghAlt" })
RegisterHerb(785, "Mageroyal", "Low-level herb commonly farmed with Briarthorn around oasis and road-edge routes.", { "barrensLow", "briarMageHillsbradMain", "briarMageDarkshoreAlt" })
RegisterHerb(2450, "Briarthorn", "Low-level herb from tree bases and open routes; also a Swiftthistle source.", { "barrensLow", "briarMageHillsbradMain", "briarMageDarkshoreAlt" })
RegisterHerb(2452, "Swiftthistle", "Bonus herb gathered from Briarthorn and Mageroyal nodes. Farm those source nodes rather than searching for standalone Swiftthistle.", { "barrensLow", "briarMageHillsbradMain", "briarMageDarkshoreAlt" })
RegisterHerb(2453, "Bruiseweed", "Mid-level herb around structures, ridges, and tree/building edges.", { "stonetalonMid", "bruiseSteelbloomStranglethornMain" })
RegisterHerb(3355, "Wild Steelbloom", "Mid-level cliff and hillside herb. Stonetalon gives a coordinate-backed ledge route.", { "stonetalonMid", "bruiseSteelbloomStranglethornMain" })
RegisterHerb(3369, "Grave Moss", "Mid-level graveyard herb. Raven Hill in Duskwood is a compact targeted route.", { "duskwoodGrave", "graveMossDuskwoodMain" })
RegisterHerb(3356, "Kingsblood", "Mid-level open-field herb. Arathi provides useful mixed herb density and side farming.", { "arathiMid", "kingsbloodStranglethornMain", "wplKingsKhadgarFadeRoute" })
RegisterHerb(3357, "Liferoot", "Water-edge herb gathered along rivers, lakes, and swamp routes.", { "wetlandsWater", "wplLiferootBlindweedRoute", "eplLiferootKhadgarSungrassRoute" })
RegisterHerb(3358, "Khadgar's Whisker", "Mid-high herb collected along Arathi and swamp routes as a regular route target.", { "arathiMid", "wplKingsKhadgarFadeRoute", "eplLiferootKhadgarSungrassRoute" })
RegisterHerb(3818, "Fadeleaf", "Mid-high herb from ruins and forested routes. Best treated as a side target on Arathi-style circuits.", { "arathiMid", "fadeleafFeralasMain", "wplKingsKhadgarFadeRoute" })
RegisterHerb(3820, "Stranglekelp", "Water herb from coastlines and underwater routes. Wetlands gives a concrete waterline route.", { "wetlandsWater", "stranglekelpThousandNeedlesMain" })
RegisterHerb(3821, "Goldthorn", "Mid-level hill and cliff herb. Hinterlands gives a compact coordinate-backed ridge route.", { "hinterlandsGoldthorn", "goldthornHinterlandsMain", "goldthornArathiAlt" })
RegisterHerb(4625, "Firebloom", "High-mid hot-zone herb. Burning Steppes lava chasms give a focused retail route.", { "burningSteppesFirebloom", "firebloomBurningSteppesMain", "firebloomSearingGorgeAlt", "firebloomTanarisAlt" })
RegisterHerb(8831, "Purple Lotus", "High-level herb around ruins and outdoor highland routes, commonly paired with Sungrass and Dreamfoil farms.", { "feralasSungrass", "purpleLotusFelwoodMain" })
RegisterHerb(8836, "Arthas' Tears", "Plaguelands-era herb gathered in undead and corrupted high-level zones.", "plaguelands")
RegisterHerb(8838, "Sungrass", "High-level open-area herb from Feralas, Tanaris, Hinterlands, and similar sunny routes.", { "feralasSungrass", "sungrassThousandNeedlesMain", "eplLiferootKhadgarSungrassRoute" })
RegisterHerb(8839, "Blindweed", "Swamp herb best targeted in Swamp of Sorrows with a zig-zag route.", { "swampBlindweed", "blindweedFeralasMain", "wplLiferootBlindweedRoute" })
RegisterHerb(8845, "Ghost Mushroom", "Cave mushroom from Hinterlands and Maraudon-style routes. Skulk Rock provides an open-world mapped route.", { "hinterlandsGhost", "ghostMushroomUngoroMain", "ghostMushroomZangarmarshAlt" })
RegisterHerb(8846, "Gromsblood", "High-level demon/corruption herb. Felwood is the best mixed-herb route.", { "felwoodHigh", "felwoodGromSansamRoute", "gromDreamBlastedLandsRoute" })
RegisterHerb(13463, "Dreamfoil", "Endgame herb from Felwood, Plaguelands, Un'Goro, Silithus, and similar high-level routes.", { "plaguelands", "gromDreamBlastedLandsRoute", "silithusDreamSilversageLotusRoute" })
RegisterHerb(13464, "Golden Sansam", "High-level herb from Felwood and Swamp of Sorrows-style routes, often collected with Dreamfoil or Blindweed.", { "felwoodHigh", "goldenSansamSwampMain", "felwoodGromSansamRoute" })
RegisterHerb(13465, "Mountain Silversage", "Endgame cliff and mountain herb. Winterspring gives a concrete ridge route.", { "winterspringIcecap", "winterspringSilversageIcecapLotusRoute", "silithusDreamSilversageLotusRoute" })
RegisterHerb(13466, "Sorrowmoss", "Retail replacement for the old Plaguebloom item ID, gathered around Swamp of Sorrows pools and waterlines.", "swampSorrowmoss")
RegisterHerb(13467, "Icecap", "Winterspring-specific high-level herb from snowy endgame routes.", { "winterspringIcecap", "winterspringSilversageIcecapLotusRoute" })
RegisterHerb(13468, "Black Lotus", "Rare endgame herb from old-world high-level zones. Silithus has explicit retail Wowhead pin clusters for a targeted route.", { "silithusBlackLotus", "silithusDreamSilversageLotusRoute", "winterspringSilversageIcecapLotusRoute", "gromDreamBlastedLandsRoute" })
RegisterHerb(8153, "Wildvine", "Secondary herb gathered through Purple Lotus and Goldthorn routes rather than standalone nodes.", { "purpleLotusFelwoodMain", "goldthornHinterlandsMain" })
