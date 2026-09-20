local _, NS = ...
local Register = NS.RegisterMaterialFarmingSpot

local XSCARLIFE = "https://xscarlife-gaming.com/farming-retail/"
local FEL_IRON_GUIDE = "https://www.wow-professions.com/farming/fel-iron-ore-farming"
local ADAMANTITE_GUIDE = "https://www.wow-professions.com/farming/adamantite-ore-farming"
local TEROKKAR_TEST = "https://searchforloot.com/terokkar-forest-mining-herbalism-gold-farming/"
local KHORIUM_WIKI = "https://warcraft.wiki.gg/wiki/Khorium_Vein"
local ETERNIUM_WIKI = "https://warcraft.wiki.gg/wiki/Eternium_Ore"
local FEL_IRON_WIKI = "https://warcraft.wiki.gg/wiki/Fel_Iron_Deposit"
local NAGRAND_REPORT = "https://www.reddit.com/r/woweconomy/comments/jqw956"
local KHORIUM_REPORT = "https://www.reddit.com/r/woweconomy/comments/mnpkdx"
local TEROKKAR_FORUM = "https://us.forums.blizzard.com/en/wow/t/mining-in-nagrand-and-terrokar-forest/2215334"

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
local FEL_IRON_HELLFIRE_COORDS = RouteCoords("Fel Iron Hellfire route", {
    29583750, 30893071, 34423279, 31013804, 31294328, 36864676, 40955023, 44305282,
    37824294, 38443638, 39133125, 48343302, 52232259, 55223367, 49323689, 48004652,
    50324987, 54255100, 66434950, 66415588, 59195663, 51895758, 42166362, 40857208,
    39396902, 36456905, 37156381, 33126055, 29126552, 30037907, 27328099, 24777335,
    25716731, 23105992, 16875752, 13746178, 10994976, 12384473, 13763781, 19564181,
    24094143,
})

local TEROKKAR_MINING_COORDS = RouteCoords("Terokkar mining route", {
    55233915, 49183599, 47063604, 44133519, 37763088, 38133876, 39314226, 42204744,
    46364896, 50815769, 44176110, 48276250, 50006830, 56746720, 56436417, 56946144,
    62596562, 66596833, 67277279, 72677321, 71898120, 75538206, 75708860, 72978779,
    68658766, 66047864, 63288463, 60578449, 60657894, 62567210, 57447196, 55097185,
    55007540, 53487674, 49158047, 46107918, 42598018, 39958153, 38097873, 31797911,
    29307612, 30746801, 27706398, 26086668, 26997429, 25427755, 19897826, 17577807,
    16536926, 18906290, 24515521, 27245224, 29134771, 30064348, 30193639, 20841543,
    21011089, 23331162, 23970871, 27621080, 30740878, 33160880, 35340607, 36100290,
    36010678, 36881097, 39321510, 41062112, 42562184, 42631566, 43440882, 45931284,
    48001220, 51671576, 48091956, 50132027, 53572459, 53012799, 52283148, 54413279,
    57103387, 56792442, 58612214, 60572294, 62752664, 65062956, 67553052, 71202972,
    72343289, 73483636, 68443758, 72404538, 68545438, 66455248, 64625566, 62645194,
    58504633, 56924413,
})

local ADAMANTITE_NAGRAND_COORDS = RouteCoords("Adamantite Nagrand route", {
    25982167, 34362252, 38602781, 38243888, 42474795, 40513173, 43422039, 53982104,
    62673457, 66863897, 72864256, 75295193, 74836252, 71117111, 68107830, 58127905,
    56005634, 42925476, 42877662, 39378256, 28817823, 28846746, 25245778, 32184815,
    7504251, 24223476,
})

local KHORIUM_NAGRAND_COORDS = RouteCoords("Khorium Nagrand route", {
    27211883, 40243200, 46702222, 46411833, 52152173, 57882347, 63393438, 72424133,
    77655490, 75926210, 74357293, 69798193, 66666932, 58255902, 49965722, 42563715,
    38873726, 37704322, 40625211, 42667329, 42697793, 41068554, 29958098, 27937771,
    29207013, 26686016, 19865085, 12294905, 7594113, 15233354, 18453396, 22484351,
    24493671, 24083074, 27772457,
})

local function MiningRoute(id, sourceUrls, mapName, location, coords, density, difficulty, tips, confidence)
    return {
        id = id,
        source = "Supplied Retail Routes export with route-specific public-source cross-checks",
        sourceUrls = sourceUrls,
        mapName = mapName,
        location = location,
        routeType = "mining-loop",
        density = density,
        dropDifficulty = difficulty,
        tips = tips,
        coords = coords,
        confidence = confidence,
    }
end

Register({
    itemID = 23424,
    itemName = "Fel Iron Ore",
    expansion = "burningCrusade",
    professions = { "mining" },
    category = "Ore",
    researchStatus = "researched",
    isRoute = true,
    sourceUrls = { XSCARLIFE, FEL_IRON_GUIDE, TEROKKAR_TEST, KHORIUM_WIKI },
    summary = "Hellfire Peninsula is the strongest dedicated Fel Iron route; Terokkar is the mixed-ore alternative.",
    spots = {
        MiningRoute(
            "fel-iron-hellfire-peninsula-main-route",
            { XSCARLIFE, FEL_IRON_GUIDE },
            "Hellfire Peninsula",
            "Main Retail Fel Iron circuit along Hellfire Peninsula ridges, cliff bases, and mountain edges",
            FEL_IRON_HELLFIRE_COORDS,
            "Very high Fel Iron concentration",
            "Easy dedicated Fel Iron circuit with quick respawns and useful short-loop options.",
            {
                "Learn Outland Mining in Shattrath first; Retail permits mining without it, but yields are substantially lower.",
                "Use Hellfire when Fel Iron itself is the target because Adamantite does not dilute the node pool as much.",
                "Do not wait for the entire circuit to respawn; smaller repeat circuits can be more productive.",
                "Stay close to ridgelines, cliff bases, and mountain edges instead of crossing large open areas.",
                "Mine every nearby Fel Iron Deposit, even slightly off-route, rather than preserving a perfect line.",
                "Expect Eternium Ore, Motes of Fire, and Motes of Earth as side yields.",
            },
            "high"
        ),
        MiningRoute(
            "fel-iron-terokkar-forest-alternative-route",
            { TEROKKAR_TEST, KHORIUM_WIKI },
            "Terokkar Forest",
            "Alternative tested Retail circuit for Fel Iron, Adamantite, Eternium, and Khorium",
            TEROKKAR_MINING_COORDS,
            "Tested mixed-ore route",
            "Longer all-round circuit; the source test averaged about 131.3 Fel Iron per hour.",
            {
                "Choose this over Hellfire when you want Fel Iron, Adamantite, Khorium, and Eternium together.",
                "The source test averaged about 131.3 Fel Iron, 182.3 Adamantite, 24 Eternium, and 11.6 Khorium per hour; these are test results, not guaranteed spawn rates.",
                "Mine Adamantite as well as Fel Iron because Khorium can replace both node types.",
                "Use Hellfire instead when Fel Iron is the only objective.",
            },
            "high"
        ),
    },
})

Register({
    itemID = 23425,
    itemName = "Adamantite Ore",
    expansion = "burningCrusade",
    professions = { "mining" },
    category = "Ore",
    researchStatus = "researched",
    isRoute = true,
    sourceUrls = { XSCARLIFE, ADAMANTITE_GUIDE, TEROKKAR_TEST, KHORIUM_WIKI, NAGRAND_REPORT },
    summary = "Nagrand is the primary Adamantite route; Terokkar is a tested mixed-ore alternative.",
    spots = {
        MiningRoute(
            "adamantite-nagrand-main-route",
            { XSCARLIFE, ADAMANTITE_GUIDE, KHORIUM_WIKI, NAGRAND_REPORT },
            "Nagrand",
            "Main Retail Adamantite circuit through Nagrand ridges and useful ogre caves",
            ADAMANTITE_NAGRAND_COORDS,
            "High Adamantite and Rich Adamantite concentration",
            "Strong all-around route; cave detours improve parent-node turnover.",
            {
                "Nagrand remains one of the strongest Adamantite zones, and its relatively small caves are generally worth entering.",
                "Do not blindly follow the outdoor line when the minimap shows ore inside an ogre cave.",
                "Clear every Adamantite deposit to create more opportunities for Khorium replacement spawns.",
                "Prioritize Rich Adamantite for more ore and a better Eternium opportunity.",
                "Stay close to cliffs and enter useful caves rather than flying through the open center.",
            },
            "high"
        ),
        MiningRoute(
            "adamantite-terokkar-forest-alternative-route",
            { TEROKKAR_TEST, KHORIUM_WIKI },
            "Terokkar Forest",
            "Alternative tested Retail circuit with high Adamantite and mixed Outland ore turnover",
            TEROKKAR_MINING_COORDS,
            "Tested mixed-ore route",
            "Useful when Nagrand is occupied; the source test averaged about 182.3 Adamantite per hour.",
            {
                "Use this route when Nagrand is occupied or when you want a more diversified ore yield.",
                "The source test averaged more Adamantite than Fel Iron on this circuit.",
                "Clear every Fel Iron node too so the shared node pool has more opportunities to produce Khorium.",
                "Expect useful Eternium and Khorium side yields.",
            },
            "high"
        ),
    },
})

Register({
    itemID = 23426,
    itemName = "Khorium Ore",
    expansion = "burningCrusade",
    professions = { "mining" },
    category = "Ore",
    researchStatus = "researched",
    isRoute = true,
    sourceUrls = { XSCARLIFE, KHORIUM_WIKI, TEROKKAR_TEST, NAGRAND_REPORT, KHORIUM_REPORT, TEROKKAR_FORUM },
    summary = "Khorium Veins are rare replacements for Fel Iron or Adamantite deposits, so successful routes maximize parent-node turnover.",
    spots = {
        MiningRoute(
            "khorium-nagrand-main-route",
            { XSCARLIFE, KHORIUM_WIKI, NAGRAND_REPORT, KHORIUM_REPORT },
            "Nagrand",
            "Main native Retail Khorium circuit through Nagrand's cliff and cave node clusters",
            KHORIUM_NAGRAND_COORDS,
            "Low Khorium density; high replacement opportunity",
            "RNG-heavy. Evaluate several circuits and clear every ordinary ore node.",
            {
                "Mine everything; every Adamantite or Fel Iron node cleared creates another later Khorium opportunity.",
                "Do not fly past Adamantite just because Khorium is the target.",
                "Enter useful Nagrand caves to maximize node turnover.",
                "Retail farming reports specifically recommend mining every Nagrand node to force more Khorium opportunities.",
                "Judge the route across several circuits rather than abandoning it after one zero-Khorium lap.",
            },
            "high"
        ),
        MiningRoute(
            "khorium-terokkar-forest-alternative-route",
            { TEROKKAR_TEST, KHORIUM_WIKI, TEROKKAR_FORUM },
            "Terokkar Forest",
            "Alternative tested mixed-ore circuit through Terokkar mountain loops and the Skettis area",
            TEROKKAR_MINING_COORDS,
            "Low Khorium density; many parent-node checks",
            "Useful when Nagrand is heavily farmed; the source test averaged about 11.6 Khorium per hour.",
            {
                "Use this route when Nagrand is heavily farmed.",
                "Its many Adamantite and Fel Iron nodes provide repeated Khorium replacement opportunities.",
                "Retail player reports point to Terokkar mountain loops and the southeast Skettis area; treat that as observation, not a guaranteed rate increase.",
                "Do not skip ordinary nodes around Skettis just because they are not Khorium.",
            },
            "high"
        ),
        MiningRoute(
            "khorium-nagrand-broad-adamantite-alternative-route",
            { XSCARLIFE, KHORIUM_WIKI },
            "Nagrand",
            "Broader Nagrand Adamantite circuit for maximum Khorium parent-node turnover",
            ADAMANTITE_NAGRAND_COORDS,
            "High parent-node turnover",
            "Use when the dedicated Khorium circuit is starved or when broader coverage is preferable.",
            {
                "This is the native Adamantite payload reused for Khorium because Khorium replaces ordinary Outland ore nodes.",
                "Use it when maximum parent-node turnover matters more than known historic Khorium locations.",
                "The underlying Adamantite route is mechanically valid for Khorium farming.",
                "This route also stocks Adamantite and Eternium.",
            },
            "high"
        ),
    },
})

Register({
    itemID = 23427,
    itemName = "Eternium Ore",
    expansion = "burningCrusade",
    professions = { "mining" },
    category = "Ore",
    researchStatus = "researched",
    isRoute = true,
    sourceUrls = { ETERNIUM_WIKI, TEROKKAR_TEST, KHORIUM_WIKI, ADAMANTITE_GUIDE, NAGRAND_REPORT, FEL_IRON_WIKI },
    summary = "Eternium has no dedicated deposit; these routes maximize productive taps on Outland nodes that can contain it.",
    spots = {
        MiningRoute(
            "eternium-terokkar-forest-main-route",
            { TEROKKAR_TEST, ETERNIUM_WIKI, KHORIUM_WIKI },
            "Terokkar Forest",
            "Main tested mixed-node circuit chosen for measured Eternium yield",
            TEROKKAR_MINING_COORDS,
            "Tested mixed-ore route",
            "The source test averaged about 24 Eternium per hour while also producing the three primary Outland ores.",
            {
                "When travel time is similar, prioritize Rich Adamantite, then Adamantite, then Fel Iron.",
                "Still mine every nearby Fel Iron node because it can contain Eternium and contributes to node turnover.",
                "Khorium Veins are especially valuable when they appear and currently list roughly a 30 percent Eternium chance.",
                "Terokkar works well because the route does not depend on only one parent-node type.",
            },
            "high"
        ),
        MiningRoute(
            "eternium-nagrand-adamantite-alternative-route",
            { XSCARLIFE, ETERNIUM_WIKI, ADAMANTITE_GUIDE, NAGRAND_REPORT },
            "Nagrand",
            "Alternative Adamantite and Rich Adamantite circuit for Eternium side yields",
            ADAMANTITE_NAGRAND_COORDS,
            "High concentration of stronger Eternium parent nodes",
            "Clean choice when Eternium is the sole secondary target; enter the short caves.",
            {
                "Nagrand is a clean Eternium choice because of its strong Adamantite and Rich Adamantite concentration.",
                "Enter short ogre caves because they can contain several deposits in a small area.",
                "Khorium replacement spawns provide another chance at Eternium.",
                "Historical Retail farming data found Nagrand productive for all four Outland ores.",
            },
            "high"
        ),
        MiningRoute(
            "eternium-hellfire-peninsula-alternative-route",
            { XSCARLIFE, FEL_IRON_GUIDE, FEL_IRON_WIKI },
            "Hellfire Peninsula",
            "Fallback high-turnover Fel Iron circuit for Eternium side yields",
            FEL_IRON_HELLFIRE_COORDS,
            "Very high Fel Iron tap count",
            "Use for node taps per hour when Nagrand and Terokkar are crowded, not for the best per-node chance.",
            {
                "Fel Iron Deposits can yield Eternium as an uncommon secondary result.",
                "Use this route for node taps per hour, not because Fel Iron has the highest Eternium chance.",
                "Short repeated circuits can outperform a full-zone lap because Hellfire has so many Fel Iron nodes.",
                "This fallback also provides Fel Iron and Motes of Fire when Eternium luck is poor.",
            },
            "high"
        ),
    },
})
