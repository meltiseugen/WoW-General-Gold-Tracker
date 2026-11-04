local _, NS = ...
local Register = NS.RegisterMaterialFarmingSpot

local function C(x, y, label)
    return { x = x, y = y, label = label }
end

local function ItemUrl(itemID)
    return "https://www.wowhead.com/item=" .. tostring(itemID)
end

local GHOST_IRON_ROUTES = {
    {
        id = "mists-ghost-iron-valley-four-winds-north-loop",
        source = "wow-professions Ghost Iron guide, retail xScarlife Routes import string, and retail Wowhead object pages",
        sourceUrls = {
            "https://www.wow-professions.com/farming/ghost-iron-ore-farming",
            "https://xscarlife-gaming.com/farming-retail/",
            "https://www.wowhead.com/object=209311/ghost-iron-deposit",
            "https://www.wowhead.com/object=209330/rich-ghost-iron-deposit",
        },
        mapName = "Valley of the Four Winds",
        location = "Northern Valley route around Paoquan Hollow, The Heartland, and Pool of Purity",
        routeType = "mining-loop",
        density = "High",
        dropDifficulty = "Best general Ghost Iron route, but Tillers traffic can make it busy.",
        tips = {
            "Stay mostly in the northern half of the zone because that is where most Valley Ghost Iron nodes spawn.",
            "Mine Ghost Iron even when targeting Trillium because many potential spawns are shared.",
            "Use Mist-Piercing Goggles when available to reveal extra Pandaria ore nodes.",
        },
        coords = {
            C(0.2934, 0.3115, "xScarlife west Heartland pin"),
            C(0.3338, 0.2500, "Northwest Heartland ridge"),
            C(0.3299, 0.4240, "Western Heartland node"),
            C(0.3773, 0.4090, "Heartland ridge bend"),
            C(0.4382, 0.3190, "North Heartland sweep"),
            C(0.5093, 0.2523, "Halfhill north ridge"),
            C(0.5863, 0.2491, "Paoquan north approach"),
            C(0.6687, 0.2685, "Paoquan Hollow north"),
            C(0.5645, 0.3920, "Paoquan return node"),
            C(0.4594, 0.4398, "Heartland south bend"),
            C(0.4105, 0.5305, "Central return"),
            C(0.3454, 0.5383, "Western return ridge"),
            C(0.1613, 0.7438, "Southwest extension"),
            C(0.1290, 0.7328, "Southwest cliff check"),
            C(0.0838, 0.7619, "Far west node check"),
            C(0.1051, 0.7030, "Far west return"),
            C(0.1232, 0.6425, "Western water edge"),
            C(0.0877, 0.5230, "Northwest river bend"),
            C(0.1340, 0.3646, "Northwest ridge return"),
            C(0.1733, 0.2943, "Northwest wall"),
            C(0.2105, 0.3286, "West Heartland entry"),
            C(0.2133, 0.3740, "Western slope node"),
            C(0.1985, 0.4180, "Western ridge pocket"),
            C(0.2082, 0.4747, "West-central return"),
            C(0.2409, 0.5055, "West-central bend"),
            C(0.3023, 0.4645, "Heartland return"),
        },
        confidence = "high",
    },
    {
        id = "mists-ghost-iron-jade-forest-windward-tian-loop",
        source = "wow-professions Ghost Iron guide and retail Wowhead ore object pages",
        sourceUrls = {
            "https://www.wow-professions.com/farming/ghost-iron-ore-farming",
            "https://www.wowhead.com/object=209311/ghost-iron-deposit",
            "https://www.wowhead.com/object=209328/trillium-vein",
        },
        mapName = "The Jade Forest",
        location = "Tian Monastery, Paw'don Village, and Windward Isle checks",
        routeType = "mining-loop",
        density = "Medium to high",
        dropDifficulty = "Good alternate Ghost Iron route with simple terrain and several notable node areas.",
        tips = {
            "Use this route if Valley of the Four Winds is crowded.",
            "Windward Isle nodes can share with Trillium, so clear Ghost Iron there to refresh rare ore checks.",
            "Do not widen the route into sparse forest sections unless competition is high.",
        },
        coords = {
            C(0.444, 0.244, "Tian Monastery hills"),
            C(0.512, 0.334, "North Jade ridge"),
            C(0.436, 0.520, "Central Jade hill"),
            C(0.374, 0.738, "Paw'don Village hills"),
            C(0.650, 0.276, "Windward Isle north"),
            C(0.704, 0.316, "Windward Isle east"),
        },
        confidence = "high",
    },
}

local KYPARITE_ROUTES = {
    {
        id = "mists-kyparite-dread-wastes-zanvess-klaxxivess-loop",
        source = "retail xScarlife Routes import string, wow-professions Ghost Iron guide, and retail Wowhead Kyparite pages",
        sourceUrls = {
            "https://xscarlife-gaming.com/farming-retail/",
            "https://www.wow-professions.com/farming/ghost-iron-ore-farming",
            "https://www.wowhead.com/object=209312/kyparite-deposit",
            "https://www.wowhead.com/object=209313/rich-kyparite-deposit",
        },
        mapName = "Dread Wastes",
        location = "Zan'Vess south checks into Klaxxi'vess and Kypari Vor",
        routeType = "mining-loop",
        density = "Medium",
        dropDifficulty = "Kyparite is zone-limited and less dense than Ghost Iron; competition is noticeable.",
        tips = {
            "Check Zan'Vess first, then sweep northeast toward Klaxxi'vess and Kypari Vor.",
            "Skip the Heart of Fear and Kypari Ik area because the ore guide excludes those from good Ghost Iron/Kyparite routes.",
            "Mine nearby Ghost Iron and Trillium to keep shared node turnover moving.",
        },
        coords = {
            C(0.3482, 0.1875, "Northern Kypari Vor pin"),
            C(0.4005, 0.1546, "Kypari Vor north ridge"),
            C(0.4223, 0.1048, "Northeast Kyparite check"),
            C(0.4905, 0.1339, "Northeast return"),
            C(0.4874, 0.1967, "Kypari Vor return"),
            C(0.4648, 0.2837, "North-central bend"),
            C(0.4286, 0.3393, "North-central ridge"),
            C(0.4161, 0.4061, "Klaxxi'vess west"),
            C(0.4716, 0.4166, "Klaxxi'vess approach"),
            C(0.5088, 0.4529, "Klaxxi'vess south"),
            C(0.4962, 0.3301, "Kypari Vor south"),
            C(0.4931, 0.2475, "Kypari Vor central"),
            C(0.5182, 0.2067, "Kypari Vor east"),
            C(0.5843, 0.1465, "East ridge check"),
            C(0.6301, 0.1277, "Far northeast ridge"),
            C(0.6736, 0.1282, "Northeast cliff check"),
            C(0.6944, 0.2303, "Northeast return ridge"),
            C(0.6485, 0.3008, "East Kyparite pocket"),
            C(0.6571, 0.3518, "East ridge south"),
            C(0.7143, 0.3093, "Far east pocket"),
            C(0.7088, 0.3375, "Far east return"),
            C(0.6904, 0.3609, "Eastern descent"),
            C(0.6117, 0.3940, "Central east bend"),
            C(0.5541, 0.4473, "Central return"),
            C(0.6123, 0.4746, "East central node"),
            C(0.6833, 0.4923, "Eastern pass"),
            C(0.6817, 0.6130, "Southeast route"),
            C(0.6564, 0.7224, "South route"),
            C(0.5465, 0.6408, "South-central route"),
            C(0.4120, 0.6991, "Zan'Vess east"),
            C(0.4024, 0.5917, "Zan'Vess north return"),
            C(0.3391, 0.5872, "Zan'Vess west"),
            C(0.3400, 0.7651, "Zan'Vess south"),
            C(0.3321, 0.8320, "Southwest Kyparite check"),
            C(0.2767, 0.8700, "Far southwest route"),
            C(0.2349, 0.8276, "Southwest coast"),
            C(0.2166, 0.7502, "Southwest return"),
            C(0.2970, 0.4662, "West Dread Wastes check"),
            C(0.2580, 0.3503, "Northwest pocket"),
            C(0.2829, 0.2657, "Northwest return"),
        },
        confidence = "high",
    },
    {
        id = "mists-kyparite-townlong-kri-sra-niuzao-loop",
        source = "wow-professions Ghost Iron guide and retail Wowhead Kyparite pages",
        sourceUrls = {
            "https://www.wow-professions.com/farming/ghost-iron-ore-farming",
            "https://www.wowhead.com/object=209312/kyparite-deposit",
        },
        mapName = "Townlong Steppes",
        location = "Gao-Ran, Sik'vess, Kri'vess, Niuzao Temple, and Sra'vess checks",
        routeType = "mining-loop",
        density = "Medium",
        dropDifficulty = "Good backup route when Dread Wastes is crowded.",
        tips = {
            "Follow the mantid and kypari landmarks rather than trying to full-clear the zone.",
            "Use Sra'vess and Niuzao Temple as loop anchors.",
        },
        coords = {
            C(0.392, 0.300, "Gao-Ran Battlefront"),
            C(0.482, 0.420, "Sik'vess"),
            C(0.532, 0.548, "Kri'vess"),
            C(0.388, 0.626, "Niuzao Temple south"),
            C(0.238, 0.144, "Sra'vess"),
        },
        confidence = "high",
    },
}

local TRILLIUM_ROUTES = {
    {
        id = "mists-trillium-dread-wastes-south-east-loop",
        source = "retail xScarlife Routes import string, wow-professions Ghost Iron guide, and retail Wowhead Trillium pages",
        sourceUrls = {
            "https://xscarlife-gaming.com/farming-retail/",
            "https://www.wow-professions.com/farming/ghost-iron-ore-farming",
            "https://www.wowhead.com/object=209328/trillium-vein",
            "https://www.wowhead.com/object=209329/rich-trillium-vein",
        },
        mapName = "Dread Wastes",
        location = "Southern and eastern Dread Wastes Ghost Iron/Trillium shared route",
        routeType = "mining-loop",
        density = "Medium for Trillium, high for ore turnover",
        dropDifficulty = "Trillium is a rare shared spawn, so the route needs steady Ghost Iron clearing.",
        tips = {
            "The ore guide identifies Dread Wastes south and east as the practical Trillium route.",
            "Mine every Ghost Iron Deposit because Trillium can replace shared spawns.",
            "Trillium veins can produce either Black or White Trillium Ore; this route cannot guarantee one color.",
        },
        coords = {
            C(0.324, 0.684, "Southwest ore sweep"),
            C(0.456, 0.732, "Southern ore sweep"),
            C(0.590, 0.690, "Southeast ore sweep"),
            C(0.686, 0.520, "Eastern ore sweep"),
            C(0.638, 0.338, "Northeast ore sweep"),
            C(0.520, 0.430, "Central return"),
        },
        confidence = "high",
    },
    {
        id = "mists-trillium-kunlai-central-mountain-loop",
        source = "wow-professions Ghost Iron guide and retail Wowhead Trillium page",
        sourceUrls = {
            "https://www.wow-professions.com/farming/ghost-iron-ore-farming",
            "https://www.wowhead.com/object=209328/trillium-vein",
        },
        mapName = "Kun-Lai Summit",
        location = "Central and southern Kun-Lai mountain Trillium checks",
        routeType = "mining-loop",
        density = "Medium",
        dropDifficulty = "Mountain route with scattered spawns; stronger when Dread Wastes is contested.",
        tips = {
            "Prioritize central and southern mountain ridges instead of lowland travel.",
            "Use this as an alternate Trillium route because the ore guide calls out those hills for Trillium.",
        },
        coords = {
            C(0.456, 0.486, "Central mountain ridge"),
            C(0.530, 0.396, "North central ridge"),
            C(0.626, 0.474, "East mountain checks"),
            C(0.586, 0.654, "South central ridge"),
            C(0.438, 0.704, "Southwest mountain return"),
        },
        confidence = "high",
    },
}

-- Ordered patrol control points decoded from the 12 supplied original Retail Routes proposals.
-- These are not verified individual nodes; no new xScarlife route geometry is copied here.
local function RouteCoords(label, packedCoords)
    local coords = {}
    for index, packed in ipairs(packedCoords) do
        local x = math.floor(packed / 10000)
        local y = packed % 10000
        coords[index] = C(x / 10000, y / 10000, string.format("%s pin %d", label, index))
    end
    return coords
end

local SHARED_MINING_TIPS = {
    "Mist-Piercing Goggles: Carry these to reveal additional Pandaria gathering nodes. They are worth obtaining for sustained farming.",
    "Forager's Gloves: These can reduce gathering time, potentially improving node throughput.",
    "Snakeroot Seeds: A non-route alternative for obtaining both Black and White Trillium at Sunsong Ranch, particularly for characters with The Tillers farm unlocked.",
    "Ghost Iron respawns: Do not ignore Ghost Iron when Trillium is your goal. Much of the rare Trillium vein distribution overlaps Ghost Iron locations.",
    "Retail-specific mining: Use the Pandaria Mining profession progression and the Retail game client. The 550/575/600 skill thresholds cited in older Classic guides should not be treated as Retail's profession skill requirements.",
}

local function MiningRoute(id, sortOrder, mapID, mapName, location, packedCoords, tips, sourceUrls, targetName)
    for _, tip in ipairs(SHARED_MINING_TIPS) do
        tips[#tips + 1] = tip
    end
    local farmAction
    if targetName == "Trillium Vein" then
        tips[#tips + 1] = "Trillium Veins and Rich Trillium Veins can produce either Black or White Trillium Ore; this route cannot guarantee one color."
        farmAction = "Mine Trillium Veins and Rich Trillium Veins; collect both Black and White Trillium Ore and clear Ghost Iron deposits."
    else
        farmAction = "Mine " .. targetName .. " nodes and their rich variants."
    end
    return {
        id = id,
        sortOrder = sortOrder,
        mapID = mapID,
        mapName = mapName,
        location = location,
        routeType = "mining-loop",
        source = "Supplied original Retail Routes proposal; linked research supports farming context, not exact waypoint validation",
        sourceUrls = sourceUrls,
        dropDifficulty = "Proposed patrol waypoints, not verified mining nodes. Not tested in WoW; check current Retail node density and terrain.",
        targetName = targetName,
        targetType = "object",
        farmAction = farmAction,
        tips = tips,
        coords = RouteCoords(location, packedCoords),
        confidence = "medium",
        isRoute = true,
    }
end

local SUPPLIED_ORE_ROUTES = {
    [72092] = {
        MiningRoute(
            "mists-ghost-iron-ore-valley-of-the-four-winds-supplied-main-route", 1,
            376, "Valley of the Four Winds", "1. Main route - Valley of the Four Winds: Northern hills, Paoquan Hollow and Pool of Purity",
            { 14003400, 22003000, 31002800, 37002200, 47002000, 56002100, 64002400, 72002900, 72003500, 63004000, 56003700, 47004200, 37004300, 28004900, 18004700, 13005400, 13006200, 20006600, 27005900, 29005300 },
            {
                "Fly through the northern mineral-bearing hills, especially around Paoquan Hollow, the Heartland and Pool of Purity.",
                "Mine both Ghost Iron Deposits and Rich Ghost Iron Deposits.",
                "Keep the flight path close enough to the ground for mining nodes to appear on the minimap.",
                "If competition is high, shorten the route to the western hills instead of completing the entire circuit.",
                "This is my first recommendation because multiple guides identify Valley of the Four Winds as a strong Ghost Iron farming zone.",
            },
            {
                "https://www.wowhead.com/item=72092/ghost-iron-ore",
                "https://www.wow-professions.com/farming/ghost-iron-ore-farming",
                "https://www.wow-professions.com/guides/pandaria-mining-leveling",
                "https://www.warcrafttavern.com/mop/guides/mining",
                "https://xscarlife-gaming.com/farming/retail/",
                "https://github.com/CallanWIT/Routes-Import-Export/blob/master/RoutesImportExport.lua",
            },
            "Ghost Iron Deposit"
        ),
        MiningRoute(
            "mists-ghost-iron-ore-the-jade-forest-supplied-alternative-route-1", 2,
            371, "The Jade Forest", "2. Alternative route 1 - The Jade Forest: Tian Monastery, central foothills and eastern ridge",
            { 32002400, 40001600, 50001500, 61002000, 72002200, 80003000, 79003800, 67003700, 62004700, 72005600, 78006700, 68007800, 55007800, 49007000, 48006100, 43005200, 38004300, 33003300 },
            {
                "Search the mountainous terrain around Tian Monastery, Dawn's Blossom and the surrounding forest ridges.",
                "Check the sides of hills instead of following the roads.",
                "Include Windward Isle if nearby nodes are active.",
                "Most Ghost Iron spawn locations here do not overlap Trillium spawns, making this a useful Ghost Iron-focused alternative.",
            },
            {
                "https://www.wowhead.com/item=72092/ghost-iron-ore",
                "https://www.wow-professions.com/farming/ghost-iron-ore-farming",
                "https://www.wow-professions.com/guides/pandaria-mining-leveling",
                "https://www.warcrafttavern.com/mop/guides/mining",
                "https://xscarlife-gaming.com/farming/retail/",
                "https://github.com/CallanWIT/Routes-Import-Export/blob/master/RoutesImportExport.lua",
            },
            "Ghost Iron Deposit"
        ),
        MiningRoute(
            "mists-ghost-iron-ore-townlong-steppes-supplied-alternative-route-2", 3,
            388, "Townlong Steppes", "3. Alternative route 2 - Townlong Steppes: Short eastern circuit",
            { 67005200, 74005900, 80006500, 84007200, 77008100, 69008200, 61007500, 57006700, 61005800 },
            {
                "Fly around the eastern side of Townlong Steppes, near Fire Camp Osul and Gao-Ran Battlefront.",
                "Mine Kyparite and Trillium when encountered for additional auction-house materials.",
                "Test a short loop instead of crossing the entire zone on every pass.",
                "WoW-Professions identifies Townlong Steppes as a good, often less-contested Ghost Iron option.",
            },
            {
                "https://www.wowhead.com/item=72092/ghost-iron-ore",
                "https://www.wow-professions.com/farming/ghost-iron-ore-farming",
                "https://www.wow-professions.com/guides/pandaria-mining-leveling",
                "https://www.warcrafttavern.com/mop/guides/mining",
                "https://xscarlife-gaming.com/farming/retail/",
                "https://github.com/CallanWIT/Routes-Import-Export/blob/master/RoutesImportExport.lua",
            },
            "Ghost Iron Deposit"
        ),
    },
    [72093] = {
        MiningRoute(
            "mists-kyparite-townlong-steppes-supplied-main-route", 1,
            388, "Townlong Steppes", "1. Main route - Townlong Steppes: Sra'vess, Niuzao Temple, Kri'vess and Gao-Ran Battlefront",
            { 29005000, 23004500, 19003400, 27002800, 38003200, 43004000, 51004300, 58005000, 66005200, 74005500, 80006300, 83007400, 76007900, 65008100, 57007600, 47007900, 40007300, 32006800 },
            {
                "Search around Niuzao Temple and Sra'vess before continuing toward Kri'vess and the eastern battlefront.",
                "Pay attention to islands, cliff edges and raised terrain around the temple.",
                "Mine Rich Kyparite Deposits whenever available.",
                "Townlong Steppes is a particularly good choice when focusing on Kyparite rather than mixed ores.",
                "The source guides identify multiple separate spawn clusters here, which is why the route covers both western and eastern areas.",
            },
            {
                "https://www.wowhead.com/item=72093/kyparite",
                "https://www.wow-professions.com/farming/ghost-iron-ore-farming",
                "https://www.wow-professions.com/guides/pandaria-mining-leveling",
                "https://www.warcrafttavern.com/mop/guides/mining",
                "https://xscarlife-gaming.com/farming/retail/",
                "https://github.com/CallanWIT/Routes-Import-Export/blob/master/RoutesImportExport.lua",
            },
            "Kyparite Deposit"
        ),
        MiningRoute(
            "mists-kyparite-dread-wastes-supplied-alternative-route-1", 2,
            422, "Dread Wastes", "2. Alternative route 1 - Dread Wastes: Northeastern Kypari forest",
            { 40002700, 47002300, 54001700, 61001400, 70001700, 76002200, 72003100, 65003400, 59004200, 68004500, 75004900, 78005700, 69006000, 59005600, 53004800, 47004000 },
            {
                "Focus on the northeastern section of Dread Wastes, particularly Kypari Vor and the surrounding Klaxxi'vess territory.",
                "Avoid unnecessary detours into the Heart of Fear area when exclusively hunting Kyparite.",
                "Fly above hostile mantid groups and descend for mining.",
                "Collect Ghost Iron and Trillium opportunistically.",
                "Use this when you want to combine Kyparite with additional Pandaria mining materials.",
            },
            {
                "https://www.wowhead.com/item=72093/kyparite",
                "https://www.wow-professions.com/farming/ghost-iron-ore-farming",
                "https://www.wow-professions.com/guides/pandaria-mining-leveling",
                "https://www.warcrafttavern.com/mop/guides/mining",
                "https://xscarlife-gaming.com/farming/retail/",
                "https://github.com/CallanWIT/Routes-Import-Export/blob/master/RoutesImportExport.lua",
            },
            "Kyparite Deposit"
        ),
        MiningRoute(
            "mists-kyparite-zanvess-island-dread-wastes-supplied-alternative-route-2", 3,
            422, "Dread Wastes", "3. Alternative route 2 - Zan'vess Island, Dread Wastes: Secluded southwestern island",
            { 27007100, 21007500, 20008300, 25008800, 32008700, 37008300, 35007500 },
            {
                "Zan'vess is a small, isolated mining area southwest of mainland Dread Wastes.",
                "Check the island's edges and around the large Kypari tree.",
                "The reported Kyparite locations are much more limited here than in the northeastern mainland.",
                "Use it as a short supplementary route rather than depending on it for continuous farming.",
                "This is a useful experimental option because most conventional farming guides emphasize the main northeastern route.",
            },
            {
                "https://www.wowhead.com/item=72093/kyparite",
                "https://www.wow-professions.com/farming/ghost-iron-ore-farming",
                "https://www.wow-professions.com/guides/pandaria-mining-leveling",
                "https://www.warcrafttavern.com/mop/guides/mining",
                "https://xscarlife-gaming.com/farming/retail/",
                "https://github.com/CallanWIT/Routes-Import-Export/blob/master/RoutesImportExport.lua",
            },
            "Kyparite Deposit"
        ),
    },
    [72094] = {
        MiningRoute(
            "mists-black-trillium-ore-dread-wastes-supplied-main-route", 1,
            422, "Dread Wastes", "1. Main route - Dread Wastes: Eastern and southern Trillium spawn areas",
            { 54001700, 65001500, 75002000, 80002900, 73003900, 80004900, 77006000, 68006400, 70007200, 64008200, 54008300, 48007200, 43006300, 49005500, 55004300, 48003700, 52002700 },
            {
                "Search the eastern and southern sections of Dread Wastes where many Ghost Iron and Trillium spawns overlap.",
                "Always mine Ghost Iron Deposits, even when they are not your intended item. Clearing them creates opportunities for Trillium to appear.",
                "Do not expect every lap to produce Trillium; the spawn type is uncommon.",
                "A May 2023 farming report recorded more Black Trillium than White Trillium in Dread Wastes, but the sample is too small to establish a reliable color bias.",
                "This is the main route because Dread Wastes is consistently recommended for Trillium farming.",
            },
            {
                "https://www.wowhead.com/item=72094/black-trillium-ore",
                "https://www.wow-professions.com/farming/ghost-iron-ore-farming",
                "https://www.wow-professions.com/guides/pandaria-mining-leveling",
                "https://www.warcrafttavern.com/mop/guides/mining",
                "https://xscarlife-gaming.com/farming/retail/",
                "https://github.com/CallanWIT/Routes-Import-Export/blob/master/RoutesImportExport.lua",
                "https://www.wowhead.com/item=72103/white-trillium-ore",
                "https://us.forums.blizzard.com/en/wow/t/trillium-ore/577758",
            },
            "Trillium Vein"
        ),
        MiningRoute(
            "mists-black-trillium-ore-kun-lai-summit-supplied-alternative-route-1", 2,
            379, "Kun-Lai Summit", "2. Alternative route 1 - Kun-Lai Summit: Mountain foothills and cave entrances",
            { 32005800, 39005400, 46005700, 52005900, 58005800, 59006900, 54007400, 49007300, 42007900, 35007500, 29007000, 26006400, 36006300, 44006600, 51006500 },
            {
                "Fly through the foothills near One Keg, Kota Basecamp and the Burlap Trail.",
                "Check the entrances of yeti caves and nearby mountain recesses.",
                "Some mining nodes are inside caves, not on the surface. Treat an ore signal above or below you as a reason to investigate the entrance.",
                "Mining Ghost Iron is necessary for efficient shared-spawn farming.",
                "Experienced miners have specifically recommended Kun-Lai cave circuits as an alternative to open-world Dread Wastes loops.",
            },
            {
                "https://www.wowhead.com/item=72094/black-trillium-ore",
                "https://www.wow-professions.com/farming/ghost-iron-ore-farming",
                "https://www.wow-professions.com/guides/pandaria-mining-leveling",
                "https://www.warcrafttavern.com/mop/guides/mining",
                "https://xscarlife-gaming.com/farming/retail/",
                "https://github.com/CallanWIT/Routes-Import-Export/blob/master/RoutesImportExport.lua",
                "https://www.wowhead.com/item=72103/white-trillium-ore",
                "https://us.forums.blizzard.com/en/wow/t/trillium-ore/577758",
            },
            "Trillium Vein"
        ),
        MiningRoute(
            "mists-black-trillium-ore-townlong-steppes-supplied-alternative-route-2", 3,
            388, "Townlong Steppes", "3. Alternative route 2 - Townlong Steppes: Short eastern wall circuit",
            { 66004900, 73005200, 79005800, 83006600, 79007400, 73008200, 65008300, 59007600, 57006700, 61005700 },
            {
                "Follow the eastern wall of Townlong Steppes from near Fire Camp Osul toward Gao-Ran Battlefront.",
                "Collect all nearby ores, including Kyparite and Ghost Iron.",
                "This is a short, experimental mixed-mining loop rather than a proven Black Trillium hotspot.",
                "Use it when you want to avoid Kun-Lai caves or Dread Wastes.",
            },
            {
                "https://www.wowhead.com/item=72094/black-trillium-ore",
                "https://www.wow-professions.com/farming/ghost-iron-ore-farming",
                "https://www.wow-professions.com/guides/pandaria-mining-leveling",
                "https://www.warcrafttavern.com/mop/guides/mining",
                "https://xscarlife-gaming.com/farming/retail/",
                "https://github.com/CallanWIT/Routes-Import-Export/blob/master/RoutesImportExport.lua",
                "https://www.wowhead.com/item=72103/white-trillium-ore",
                "https://us.forums.blizzard.com/en/wow/t/trillium-ore/577758",
            },
            "Trillium Vein"
        ),
    },
    [72103] = {
        MiningRoute(
            "mists-white-trillium-ore-kun-lai-summit-supplied-main-route", 1,
            379, "Kun-Lai Summit", "1. Main route - Kun-Lai Summit: One Keg, Burlap Trail and southern foothills",
            { 37005600, 44005500, 50005800, 56005500, 61005900, 58006600, 53006900, 46006600, 40007200, 36007700, 43008100, 50007900, 57007500, 63008100, 65008700, 56008900, 48008500 },
            {
                "Focus on central and southern Kun-Lai Summit, particularly the mountain foothills around One Keg and Kota Basecamp.",
                "Make detours into caves where mineral nodes appear on the minimap.",
                "A historical Wowhead comment identifies two particularly interesting areas: One Keg toward the Dooker Dome, and the foothills southwest of Kota Basecamp.",
                "Kun-Lai Summit is a good Trillium farming location, although neither the route nor individual veins guarantee White Trillium.",
                "A May 2023 report found 20 White versus 8 Black in an hour here; treat this as anecdotal, not a verified probability.",
            },
            {
                "https://www.wowhead.com/item=72103/white-trillium-ore",
                "https://www.wow-professions.com/farming/ghost-iron-ore-farming",
                "https://www.wow-professions.com/guides/pandaria-mining-leveling",
                "https://www.warcrafttavern.com/mop/guides/mining",
                "https://xscarlife-gaming.com/farming/retail/",
                "https://github.com/CallanWIT/Routes-Import-Export/blob/master/RoutesImportExport.lua",
                "https://www.wowhead.com/item=72094/black-trillium-ore",
                "https://us.forums.blizzard.com/en/wow/t/trillium-ore/577758",
            },
            "Trillium Vein"
        ),
        MiningRoute(
            "mists-white-trillium-ore-dread-wastes-supplied-alternative-route-1", 2,
            422, "Dread Wastes", "2. Alternative route 1 - Dread Wastes: Eastern spawn belt",
            { 43002400, 49002900, 55002800, 65002400, 74002800, 71003900, 62004300, 67005200, 64006100, 58006600, 51006300, 48005300, 51004200 },
            {
                "Search eastern Dread Wastes around its shared Ghost Iron and Trillium spawn locations.",
                "Clear ordinary Ghost Iron Deposits instead of waiting for Trillium Veins alone.",
                "Consider making a second pass through an area after completing the loop to check newly spawned veins.",
                "This is a good all-around mixed-ore alternative if you also want Ghost Iron, Black Trillium and Kyparite.",
            },
            {
                "https://www.wowhead.com/item=72103/white-trillium-ore",
                "https://www.wow-professions.com/farming/ghost-iron-ore-farming",
                "https://www.wow-professions.com/guides/pandaria-mining-leveling",
                "https://www.warcrafttavern.com/mop/guides/mining",
                "https://xscarlife-gaming.com/farming/retail/",
                "https://github.com/CallanWIT/Routes-Import-Export/blob/master/RoutesImportExport.lua",
                "https://www.wowhead.com/item=72094/black-trillium-ore",
                "https://us.forums.blizzard.com/en/wow/t/trillium-ore/577758",
            },
            "Trillium Vein"
        ),
        MiningRoute(
            "mists-white-trillium-ore-townlong-steppes-supplied-alternative-route-2", 3,
            388, "Townlong Steppes", "3. Alternative route 2 - Townlong Steppes: Eastern wall and Gao-Ran area",
            { 67004900, 74005100, 79005800, 81006600, 76007300, 70008000, 64008200, 60007700, 56007100, 59006300, 62005600 },
            {
                "Search the eastern part of Townlong Steppes instead of circling the distant western islands.",
                "Use the Fire Camp Osul and Gao-Ran Battlefront area as your primary patrol corridor.",
                "Collect both Trillium colors, Ghost Iron and Kyparite.",
                "This is an alternative for quick, repeatable mixed-ore farming, particularly when the longer Kun-Lai routes are inconvenient.",
                "The route is based on an older community recommendation for the Townlong eastern wall, but its current Retail productivity is unverified.",
            },
            {
                "https://www.wowhead.com/item=72103/white-trillium-ore",
                "https://www.wow-professions.com/farming/ghost-iron-ore-farming",
                "https://www.wow-professions.com/guides/pandaria-mining-leveling",
                "https://www.warcrafttavern.com/mop/guides/mining",
                "https://xscarlife-gaming.com/farming/retail/",
                "https://github.com/CallanWIT/Routes-Import-Export/blob/master/RoutesImportExport.lua",
                "https://www.wowhead.com/item=72094/black-trillium-ore",
                "https://us.forums.blizzard.com/en/wow/t/trillium-ore/577758",
            },
            "Trillium Vein"
        ),
    },
}

local function RegisterOre(item)
    local routes = {}
    local sourceUrls = { ItemUrl(item.itemID) }
    local seenSources = { [sourceUrls[1]] = true }
    -- Default to the supplied main route while retaining existing researched choices.
    for _, spot in ipairs(SUPPLIED_ORE_ROUTES[item.itemID] or {}) do
        routes[#routes + 1] = spot
    end
    for _, spot in ipairs(item.spots or {}) do
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
    item.isRoute = true
    item.sourceUrls = sourceUrls
    item.spots = routes
    Register(item)
end

RegisterOre({
    itemID = 72092,
    itemName = "Ghost Iron Ore",
    expansion = "mists",
    professions = { "mining" },
    category = "Ore",
    sourceUrls = { ItemUrl(72092), "https://www.wow-professions.com/farming/ghost-iron-ore-farming" },
    summary = "Baseline Pandaria ore, best farmed in Valley of the Four Winds with Jade Forest and Townlong backups.",
    spots = GHOST_IRON_ROUTES,
})

RegisterOre({
    itemID = 72093,
    itemName = "Kyparite",
    expansion = "mists",
    professions = { "mining" },
    category = "Ore",
    sourceUrls = { ItemUrl(72093), "https://www.wow-professions.com/farming/ghost-iron-ore-farming" },
    summary = "Zone-limited Pandaria ore from Dread Wastes and Townlong Steppes Kyparite deposits.",
    spots = KYPARITE_ROUTES,
})

RegisterOre({
    itemID = 72094,
    itemName = "Black Trillium Ore",
    expansion = "mists",
    professions = { "mining" },
    category = "Ore",
    sourceUrls = { ItemUrl(72094), "https://www.wow-professions.com/farming/ghost-iron-ore-farming" },
    summary = "Rare Trillium node output; farm shared Ghost Iron/Trillium routes and keep node turnover high.",
    spots = TRILLIUM_ROUTES,
})

RegisterOre({
    itemID = 72103,
    itemName = "White Trillium Ore",
    expansion = "mists",
    professions = { "mining" },
    category = "Ore",
    sourceUrls = { ItemUrl(72103), "https://www.wow-professions.com/farming/ghost-iron-ore-farming" },
    summary = "White and Black Trillium Ore share Trillium Vein and Rich Trillium Vein sources; neither color is guaranteed on a route.",
    spots = TRILLIUM_ROUTES,
})
