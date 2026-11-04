local _, NS = ...
local Register = NS.RegisterMaterialFarmingSpot
local H = NS.MaterialFarmingSpotHelpers

local function C(x, y, label)
    return { x = x, y = y, label = label }
end

local function ItemUrl(itemID)
    return "https://www.wowhead.com/item=" .. tostring(itemID)
end

local TIRAGARDE_WATER_HERB_ROUTE = {
    id = "bfa-tiragarde-riverbud-water-route",
    source = "wow-professions Riverbud guide, Warcraft Wiki, and sampled xScarlife retail Routes import pins",
    sourceUrls = {
        "https://www.wow-professions.com/farming/riverbud-farming",
        "https://warcraft.wiki.gg/wiki/Riverbud",
        "https://xscarlife-gaming.com/farming-retail/",
    },
    mapName = "Tiragarde Sound",
    location = "Northern Tiragarde waterways and pond edges",
    routeType = "herbalism-loop",
    density = "High",
    dropDifficulty = "Easy water-route herb; stronger when dual-gathering with northern ore nodes.",
    tips = H.withBfaGatheringTips({
        "Riverbud grows near freshwater, not ocean water.",
        "Follow river bends and pond edges rather than straight road lines.",
        "This dense route is useful map-window input for reconstructing a water-edge farming loop.",
    }),
    coords = {
        C(0.5121, 0.2258, "AoA/xScarlife northern Tiragarde water pin"),
        C(0.5293, 0.2607, "AoA/xScarlife water bend"),
        C(0.5551, 0.2993, "AoA/xScarlife Norwington stream"),
        C(0.5449, 0.2299, "AoA/xScarlife north pond"),
        C(0.5730, 0.2083, "AoA/xScarlife upper water route"),
        C(0.6113, 0.1644, "AoA/xScarlife northern return"),
        C(0.6392, 0.1895, "AoA/xScarlife northeast river edge"),
        C(0.6575, 0.2271, "AoA/xScarlife eastern water bend"),
        C(0.6491, 0.2716, "AoA/xScarlife lower stream pin"),
        C(0.6221, 0.2953, "AoA/xScarlife central river pin"),
        C(0.5376, 0.3469, "AoA/xScarlife southern water route"),
        C(0.4931, 0.2943, "AoA/xScarlife west return"),
        C(0.4760, 0.2431, "AoA/xScarlife northwest return"),
        C(0.4493, 0.2156, "AoA/xScarlife route close"),
    },
    confidence = "high",
}

local VOLDUN_AKUNDA_ROUTE = {
    id = "bfa-voldun-akundas-bite-route",
    source = "wow-professions Akunda's Bite guide, retail Wowhead item page, and sampled xScarlife retail Routes import pins",
    sourceUrls = {
        "https://www.wow-professions.com/farming/akundas-bite-farming",
        "https://www.wowhead.com/item=152507/akundas-bite",
        "https://xscarlife-gaming.com/farming-retail/",
    },
    mapName = "Vol'dun",
    location = "Vol'dun desert herb loop around dunes and ruin edges",
    routeType = "herbalism-loop",
    density = "Medium to high",
    dropDifficulty = "Good targeted Akunda's Bite route; open terrain is fast with flying.",
    tips = H.withBfaGatheringTips({
        "Vol'dun is the dedicated Akunda's Bite zone.",
        "Use this route when Akunda's Bite is the target or when the Mechagon daily raises demand.",
        "Anchor Weed can appear as a rare respawn while clearing normal herbs.",
    }),
    coords = {
        C(0.5190, 0.3321, "AoA/xScarlife northern dune herbs"),
        C(0.6042, 0.3968, "AoA/xScarlife northeast dunes"),
        C(0.6061, 0.4893, "AoA/xScarlife eastern ruins"),
        C(0.5786, 0.5819, "AoA/xScarlife southeast turn"),
        C(0.5206, 0.5576, "AoA/xScarlife central route"),
        C(0.4879, 0.7011, "AoA/xScarlife southern route"),
        C(0.3892, 0.8080, "AoA/xScarlife south dunes"),
        C(0.3570, 0.7407, "AoA/xScarlife southwest return"),
        C(0.2733, 0.7011, "AoA/xScarlife west extension"),
        C(0.3592, 0.4255, "AoA/xScarlife western ruin edge"),
        C(0.4378, 0.3600, "AoA/xScarlife northwestern route"),
        C(0.4797, 0.3252, "AoA/xScarlife route close"),
    },
    confidence = "high",
}

local DRUSTVAR_WINTER_ROUTE = {
    id = "bfa-drustvar-winters-kiss-route",
    source = "wow-professions Winter's Kiss guide, Wowhead item page, and sampled xScarlife retail Routes import pins",
    sourceUrls = {
        "https://www.wow-professions.com/farming/winters-kiss-farming",
        "https://www.wowhead.com/item=152508/winters-kiss",
        "https://xscarlife-gaming.com/farming-retail/",
    },
    mapName = "Drustvar",
    location = "Western and northern Drustvar snowy herb route",
    routeType = "herbalism-loop",
    density = "High",
    dropDifficulty = "Good if flying; snowy terrain and hills slow ground-only loops.",
    tips = H.withBfaGatheringTips({
        "Winter's Kiss favors snowy Drustvar areas.",
        "Use a wider flying loop to let nodes respawn before returning to the start.",
        "Drustvar also supplies Siren's Pollen and Anchor Weed respawn chances.",
    }),
    coords = {
        C(0.5097, 0.2539, "AoA/xScarlife northeast snowfield pin"),
        C(0.4777, 0.3607, "AoA/xScarlife central snowfield pin"),
        C(0.4604, 0.3789, "AoA/xScarlife snowy road bend"),
        C(0.4560, 0.4118, "AoA/xScarlife central route"),
        C(0.4090, 0.4526, "AoA/xScarlife west-central route"),
        C(0.3811, 0.5240, "AoA/xScarlife southern bend"),
        C(0.3539, 0.4759, "AoA/xScarlife western ridge"),
        C(0.3095, 0.4358, "AoA/xScarlife west return"),
        C(0.2644, 0.4482, "AoA/xScarlife southwest snowline"),
        C(0.2338, 0.3536, "AoA/xScarlife western snowfield"),
        C(0.2579, 0.1881, "AoA/xScarlife northwest turn"),
        C(0.3328, 0.1909, "AoA/xScarlife northern route"),
        C(0.3145, 0.2688, "AoA/xScarlife north return"),
        C(0.3541, 0.3309, "AoA/xScarlife central north"),
        C(0.4143, 0.3682, "AoA/xScarlife route close"),
        C(0.4464, 0.3404, "AoA/xScarlife northeast return"),
    },
    confidence = "high",
}

local DRUSTVAR_SIREN_ROUTE = {
    id = "bfa-drustvar-sirens-pollen-forest-route",
    source = "wow-professions Siren's Pollen guide, Wowhead item page, and sampled xScarlife retail Routes import pins",
    sourceUrls = {
        "https://www.wow-professions.com/farming/sirens-pollen-farming",
        "https://www.wowhead.com/item=152509/sirens-pollen",
        "https://xscarlife-gaming.com/farming-retail/",
    },
    mapName = "Drustvar",
    location = "Tree-heavy eastern Drustvar route",
    routeType = "herbalism-loop",
    density = "Medium to high",
    dropDifficulty = "Good, especially when competition is lower than on generic routes.",
    tips = H.withBfaGatheringTips({
        "Siren's Pollen appears near trees, so hug forest edges instead of roads.",
        "Clear other herbs nearby because Anchor Weed can replace normal herbs.",
        "Use the dense eastern loop for future map overlay testing, then trim if the UI needs fewer pins.",
    }),
    coords = {
        C(0.6010, 0.3797, "AoA/xScarlife north Drustvar tree line"),
        C(0.6255, 0.4128, "AoA/xScarlife northeast forest"),
        C(0.6348, 0.4546, "AoA/xScarlife eastern tree pin"),
        C(0.6547, 0.4486, "AoA/xScarlife east route"),
        C(0.6586, 0.4009, "AoA/xScarlife northeast return"),
        C(0.6741, 0.4320, "AoA/xScarlife far east tree line"),
        C(0.6926, 0.5196, "AoA/xScarlife eastern descent"),
        C(0.6712, 0.5976, "AoA/xScarlife southeast route"),
        C(0.6165, 0.6121, "AoA/xScarlife south-central forest"),
        C(0.6113, 0.6452, "AoA/xScarlife southern route"),
        C(0.6270, 0.6808, "AoA/xScarlife south turn"),
        C(0.6024, 0.7055, "AoA/xScarlife southwest turn"),
        C(0.5822, 0.6833, "AoA/xScarlife lower return"),
        C(0.5998, 0.5806, "AoA/xScarlife central return"),
        C(0.5930, 0.5393, "AoA/xScarlife central tree line"),
        C(0.6094, 0.5051, "AoA/xScarlife route close"),
        C(0.5609, 0.4336, "AoA/xScarlife western forest pin"),
        C(0.5491, 0.4005, "AoA/xScarlife northwest return"),
    },
    confidence = "high",
}

local VOLDUN_STAR_MOSS_ROUTE = {
    id = "bfa-voldun-star-moss-ruins-route",
    source = "wow-professions Star Moss guide, Wowhead item page, and sampled xScarlife retail Routes import pins",
    sourceUrls = {
        "https://www.wow-professions.com/farming/star-moss-farming",
        "https://www.wowhead.com/item=152506/star-moss",
        "https://xscarlife-gaming.com/farming-retail/",
    },
    mapName = "Vol'dun",
    location = "Vol'dun structure and ruin-edge route for Star Moss",
    routeType = "structure-herb-loop",
    density = "Medium",
    dropDifficulty = "Moderate. Star Moss is easy to miss because it prefers walls and buildings.",
    tips = H.withBfaGatheringTips({
        "Look up onto walls, ruins, and buildings instead of scanning only the ground.",
        "Use this as a structure route with Akunda's Bite and Anchor Weed side value.",
    }),
    coords = {
        C(0.4780, 0.5740, "AoA/xScarlife central Vol'dun structure pin"),
        C(0.5165, 0.6586, "AoA/xScarlife southern ruins"),
        C(0.5808, 0.6322, "AoA/xScarlife eastern wall line"),
        C(0.5553, 0.6978, "AoA/xScarlife southeast bend"),
        C(0.5067, 0.7489, "AoA/xScarlife southern return"),
        C(0.4667, 0.7975, "AoA/xScarlife south ruins"),
        C(0.4235, 0.8010, "AoA/xScarlife southwest ruins"),
        C(0.3692, 0.8074, "AoA/xScarlife western turn"),
        C(0.3407, 0.7751, "AoA/xScarlife west return"),
        C(0.3531, 0.6738, "AoA/xScarlife central-west structure"),
        C(0.3657, 0.6046, "AoA/xScarlife northwestern route"),
        C(0.4171, 0.6231, "AoA/xScarlife route close"),
    },
    confidence = "high",
}

local TIRAGARDE_ANCHOR_WEED_ROUTE = {
    id = "bfa-tiragarde-anchor-weed-respawn-route",
    source = "wow-professions Anchor Weed guide, retail Wowhead object page, and sampled xScarlife retail Routes import pins",
    sourceUrls = {
        "https://www.wow-professions.com/farming/anchor-weed-farming",
        "https://www.wowhead.com/object=294125/anchor-weed",
        "https://xscarlife-gaming.com/farming-retail/",
    },
    mapName = "Tiragarde Sound",
    location = "Northern Tiragarde broad herb-clearing route for rare Anchor Weed respawns",
    routeType = "rare-herb-respawn-loop",
    density = "Rare",
    dropDifficulty = "Hard. Anchor Weed is a rare respawn, so value depends on clearing other herbs.",
    tips = H.withBfaGatheringTips({
        "Do not camp one point; gather normal herbs aggressively to trigger respawn chances.",
        "Use this when you want Riverbud, Sea Stalk coastline checks, and Anchor Weed chances together.",
    }),
    coords = {
        C(0.4103, 0.1302, "AoA/xScarlife northern Anchor Weed check"),
        C(0.4548, 0.2044, "AoA/xScarlife north river bend"),
        C(0.4924, 0.1903, "AoA/xScarlife northern waterline"),
        C(0.5456, 0.2192, "AoA/xScarlife Norwington check"),
        C(0.5819, 0.1994, "AoA/xScarlife northern route"),
        C(0.6175, 0.1525, "AoA/xScarlife upper return"),
        C(0.6455, 0.1951, "AoA/xScarlife northeast route"),
        C(0.6636, 0.2390, "AoA/xScarlife east turn"),
        C(0.6282, 0.2948, "AoA/xScarlife lower river"),
        C(0.5416, 0.3405, "AoA/xScarlife south-central check"),
        C(0.4905, 0.3630, "AoA/xScarlife western return"),
        C(0.4756, 0.3036, "AoA/xScarlife route close"),
        C(0.4026, 0.2650, "AoA/xScarlife west edge"),
        C(0.3684, 0.2449, "AoA/xScarlife northwest return"),
    },
    confidence = "high",
}

local STORMSONG_SEA_STALK_ROUTE = {
    id = "bfa-stormsong-sea-stalk-coast-route",
    source = "wow-professions Sea Stalk guide, retail Wowhead Sea Stalk object pages, and sampled xScarlife retail Routes import pins",
    sourceUrls = {
        "https://www.wow-professions.com/farming/sea-stalk-farming",
        "https://www.wowhead.com/object=276240/sea-stalks",
        "https://www.wowhead.com/object=281872/sea-stalks",
        "https://xscarlife-gaming.com/farming-retail/",
    },
    mapName = "Stormsong Valley",
    location = "Stormsong coast and waterline route for Sea Stalk",
    routeType = "coastal-herbalism-loop",
    density = "Medium to high",
    dropDifficulty = "Easy coastal herb route; best with flying or water travel support.",
    tips = H.withBfaGatheringTips({
        "Sea Stalk grows near the sea and coastal waterlines.",
        "Stormsong gives a clean coastal loop without needing to list every BFA shoreline.",
        "Use this route when the map UI needs a focused Sea Stalk overlay rather than a generic herb pass.",
    }),
    coords = {
        C(0.3404, 0.2754, "AoA/xScarlife northern Stormsong coast"),
        C(0.3741, 0.2885, "AoA/xScarlife north coast route"),
        C(0.3626, 0.4016, "AoA/xScarlife inland waterline"),
        C(0.4040, 0.4034, "AoA/xScarlife east water bend"),
        C(0.3944, 0.5768, "AoA/xScarlife central waterline"),
        C(0.3315, 0.6541, "AoA/xScarlife west coast"),
        C(0.2241, 0.6880, "AoA/xScarlife western coast"),
        C(0.2811, 0.5990, "AoA/xScarlife southwest return"),
        C(0.3392, 0.5368, "AoA/xScarlife center return"),
        C(0.3002, 0.5312, "AoA/xScarlife west-center coast"),
        C(0.2781, 0.4823, "AoA/xScarlife route close"),
        C(0.2949, 0.4250, "AoA/xScarlife northern return"),
        C(0.3232, 0.3985, "AoA/xScarlife north waterline"),
        C(0.3026, 0.3309, "AoA/xScarlife upper coast"),
        C(0.3126, 0.2977, "AoA/xScarlife loop close"),
    },
    confidence = "high",
}

local ZINANTHID_NAZJATAR_ROUTE = {
    id = "bfa-nazjatar-zinanthid-osmenite-route",
    source = "wow-professions Zin'anthid guide, Wowhead comments, Artisans of Azeroth retail route string, and sampled xScarlife retail Routes import pins",
    sourceUrls = {
        "https://www.wow-professions.com/farming/zin-anthid-farming",
        "https://www.wowhead.com/item=168487/zinanthid",
        "https://artisansofazeroth.com/zandalari-kul-tiran-bfa-herbalism-leveling-guide/",
        "https://xscarlife-gaming.com/farming-retail/",
    },
    mapName = "Nazjatar",
    location = "Nazjatar Coral Forest, Kal'methir, and Hanging Reef herb route",
    routeType = "herbalism-loop",
    density = "High",
    dropDifficulty = "High-value route with heavy competition and hostile terrain.",
    tips = H.withBfaGatheringTips({
        "Use this as the paired Zin'anthid and Osmenite route.",
        "A Wowhead comment notes planting later Germinating Seeds near the Coral Forest around 54,41.",
        "Route through Coral Forest and Kal'methir, then extend to Hanging Reef when competition is high.",
    }),
    coords = {
        C(0.540, 0.410, "Coral Forest seed and herb check"),
        C(0.5514, 0.1735, "AoA northern Nazjatar herb pin"),
        C(0.5944, 0.2215, "AoA upper reef route"),
        C(0.5293, 0.2958, "AoA Coral Forest approach"),
        C(0.5157, 0.3523, "AoA central route"),
        C(0.4831, 0.3602, "AoA western Coral Forest"),
        C(0.4658, 0.4146, "AoA central-west route"),
        C(0.4811, 0.4588, "AoA Coral Forest south"),
        C(0.4600, 0.4951, "AoA lower Coral Forest"),
        C(0.4862, 0.5376, "AoA southern Coral Forest"),
        C(0.4383, 0.5777, "AoA western Hanging Reef"),
        C(0.4290, 0.4975, "AoA west return"),
        C(0.4060, 0.4295, "AoA western route"),
        C(0.3532, 0.4206, "AoA northwest return"),
        C(0.2959, 0.3848, "AoA far west route"),
        C(0.2778, 0.3148, "AoA northwestern approach"),
        C(0.3337, 0.3676, "AoA route close"),
        C(0.3897, 0.2736, "AoA northern route"),
        C(0.3997, 0.1563, "AoA northwest close"),
        C(0.4579, 0.3057, "AoA Coral Forest reconnect"),
    },
    confidence = "high",
}

-- Supplied reconstructed circuits retain their exact ordered route vertices.
-- These are not verified herb-node exports; keep alternatives separate in the map dropdown.
local function SuppliedHerbRoute(id, sortOrder, mapID, mapName, name, variant, routeType, packedCoords, tips, sourceUrls)
    local coords = {}
    for index, packed in ipairs(packedCoords) do
        coords[#coords + 1] = C(math.floor(packed / 10000) / 10000, (packed % 10000) / 10000, name .. " #" .. index)
    end
    return {
        id = id,
        sortOrder = sortOrder,
        mapID = mapID,
        mapName = mapName,
        location = name,
        dropdownLabel = mapName .. ": " .. sortOrder .. ". " .. variant .. " - " .. name,
        routeType = routeType,
        source = "User-supplied reconstructed Retail Routes circuit; wow-professions guide inspiration and community reports where linked; xScarlife collection for comparison",
        sourceUrls = sourceUrls,
        dropDifficulty = "Reconstructed circuit; not tested in-game. Checkpoints are route vertices, not confirmed herb nodes.",
        tips = H.withBfaGatheringTips(tips),
        coords = coords,
        confidence = "low",
        verificationStatus = "reconstructed",
        inGameTested = false,
        isRoute = true,
    }
end

local SUPPLIED_HERB_ROUTES = {
    [152505] = {
        SuppliedHerbRoute(
            "bfa-riverbud-tiragarde-freshwater-circuit-supplied", 1,
            895, "Tiragarde Sound", "Tiragarde freshwater circuit", "Main",
            "herbalism-loop",
            { 48001850, 51502180, 54202500, 56002890, 59702940, 63202100, 65002270, 63802740, 59403270, 53903400, 49302970, 47102480 },
            {
                "Prioritize riverbanks, ponds, and freshwater streams; ignore coastal saltwater sections.",
                "Collect nearby Sea Stalk and Siren's Pollen only when the detour is worthwhile.",
                "Refine the circuit using actual node observations, especially near waterways with steep terrain.",
            },
            {
                "https://www.wow-professions.com/farming/riverbud-farming",
                "https://xscarlife-gaming.com/farming/retail/",
            }
        ),
        SuppliedHerbRoute(
            "bfa-riverbud-nazmir-wetlands-supplied", 2,
            863, "Nazmir", "Nazmir wetlands", "Alternative",
            "herbalism-loop",
            { 37527005, 33757394, 28677897, 35187852, 37798238, 41478575, 51927849, 61016287, 64675188, 61443785, 56403620, 54583966, 46344144, 43783457, 37813414, 32913555, 28143490, 29124040, 29435276, 33376581 },
            {
                "Adapted from a community-documented Nazmir circuit containing Riverbud and other BfA herbs.",
                "Expect Siren's Pollen and potentially Anchor Weed along the wider loop.",
                "Flying is particularly useful over Nazmir's waterways and vegetation.",
            },
            {
                "https://www.wow-professions.com/farming/riverbud-farming",
                "https://www.wowhead.com/item=152505/riverbud",
                "https://xscarlife-gaming.com/farming/retail/",
            }
        ),
    },
    [152511] = {
        SuppliedHerbRoute(
            "bfa-sea-stalk-stormsong-saltwater-circuit-supplied", 1,
            942, "Stormsong Valley", "Stormsong saltwater circuit", "Main",
            "coastal-herbalism-loop",
            { 34042754, 37412885, 40404034, 39445768, 33156541, 22416880, 28115990, 33925368, 30025312, 27814823, 29494250, 32323985, 30263309, 31262977 },
            {
                "Search rocky coastlines, seaside cliffs, and coves.",
                "Avoid spending time around inland rivers, where Riverbud is more likely.",
                "The route can require combat without flying or protection against being dismounted.",
            },
            {
                "https://www.wow-professions.com/farming/sea-stalk-farming",
                "https://xscarlife-gaming.com/farming/retail/",
            }
        ),
        SuppliedHerbRoute(
            "bfa-sea-stalk-norwington-coastal-sweep-supplied", 2,
            895, "Tiragarde Sound", "Norwington coastal sweep", "Alternative",
            "coastal-herbalism-loop",
            { 42103080, 45003110, 48402710, 50202320, 54002180, 58002300, 62002350, 66902310, 70202570, 71003040, 66703460, 62903260, 58103070, 53003300, 49503480, 46803310 },
            {
                "Explore the Norwington-side coastline rather than only the most frequently recommended Stormsong circuit.",
                "Follow accessible shorelines and adjust waypoints that cross coastal cliffs.",
                "Riverbud and Siren's Pollen provide supplementary gathering opportunities.",
            },
            {
                "https://www.wow-professions.com/farming/sea-stalk-farming",
                "https://xscarlife-gaming.com/farming/retail/",
            }
        ),
    },
    [152506] = {
        SuppliedHerbRoute(
            "bfa-star-moss-northern-ruins-terrace-of-the-fang-supplied", 1,
            864, "Vol'dun", "Northern ruins / Terrace of the Fang", "Main",
            "structure-herb-loop",
            { 58001260, 60001500, 62101780, 64802030, 63102400, 60702700, 57802640, 55602320, 54501960, 55601580 },
            {
                "Search stone walls around the Terrace of the Fang area, approximately 60,15.",
                "Check multiple elevations of the ruins; Star Moss may not be visible from the ground.",
                "A compact structural loop is more useful than sweeping open desert.",
            },
            {
                "https://www.wow-professions.com/farming/star-moss-farming",
                "https://xscarlife-gaming.com/farming/retail/",
            }
        ),
        SuppliedHerbRoute(
            "bfa-star-moss-bridgeport-ashvane-foundry-supplied", 2,
            895, "Tiragarde Sound", "Bridgeport / Ashvane Foundry", "Alternative - niche location",
            "structure-herb-loop",
            { 75804870, 77304700, 79904770, 82004920, 81805120, 79705290, 77605200, 75705070 },
            {
                "Investigate the industrial walls and buildings near Bridgeport / Ashvane Foundry, around 75-82,48-52.",
                "This is a shorter, less-common route based on reported Star Moss spawn areas.",
                "If nodes have not respawned by the end of a circuit, expand the path or combine it with another nearby farm.",
            },
            {
                "https://www.wow-professions.com/farming/star-moss-farming",
                "https://xscarlife-gaming.com/farming/retail/",
            }
        ),
    },
    [152507] = {
        SuppliedHerbRoute(
            "bfa-akundas-bite-temple-of-akunda-highlands-supplied", 1,
            864, "Vol'dun", "Temple of Akunda highlands", "Main",
            "herbalism-loop",
            { 48007370, 51507200, 55107450, 57207800, 55308280, 53608830, 51509130, 49108720, 46608460, 46808070, 49007780 },
            {
                "Prioritize hills and rocky slopes surrounding the Temple of Akunda.",
                "Avoid spending excessive time on exposed sandy roads between herb clusters.",
                "Improve your BfA Herbalism rank to obtain better yields from gathered nodes.",
            },
            {
                "https://www.wow-professions.com/farming/akundas-bite-farming",
                "https://xscarlife-gaming.com/farming/retail/",
            }
        ),
        SuppliedHerbRoute(
            "bfa-akundas-bite-atul-aman-ridges-supplied", 2,
            864, "Vol'dun", "Atul'Aman ridges", "Alternative - exploratory",
            "herbalism-loop",
            { 42905920, 44805720, 48105840, 50806100, 50206500, 47906940, 44707120, 42506840, 41706370 },
            {
                "Survey the Atul'Aman rock terraces as an alternative to the popular southern circuit.",
                "Avoid abrupt elevation changes and inaccessible cliff faces when optimizing the path.",
                "Treat herb density on this alternative as unverified until tested in Retail.",
            },
            {
                "https://www.wow-professions.com/farming/akundas-bite-farming",
                "https://xscarlife-gaming.com/farming/retail/",
            }
        ),
    },
    [152508] = {
        SuppliedHerbRoute(
            "bfa-winters-kiss-iceveil-glacier-circuit-supplied", 1,
            896, "Drustvar", "Iceveil Glacier circuit", "Main",
            "herbalism-loop",
            { 43706320, 47805910, 52405940, 57206180, 60006640, 58507140, 54107600, 49207880, 44907520, 42606950 },
            {
                "Concentrate on the Iceveil Glacier region and surrounding snowy terrain.",
                "Search open snowfields and accessible mountain slopes rather than dense forests.",
                "Flying minimizes time lost to steep terrain.",
            },
            {
                "https://www.wow-professions.com/farming/winters-kiss-farming",
                "https://xscarlife-gaming.com/farming/retail/",
            }
        ),
        SuppliedHerbRoute(
            "bfa-winters-kiss-gol-koval-snowy-ring-supplied", 2,
            896, "Drustvar", "Gol Koval snowy ring", "Alternative 1",
            "herbalism-loop",
            { 57106230, 59006070, 62206200, 64206530, 62706910, 59807100, 57106890, 55906570 },
            {
                "Covers the area around Gol Koval, where players have reported Winter's Kiss occurrences.",
                "Provides an alternative to circling the main glacial farming area.",
                "Because this is a small circuit, combine it with another Drustvar route if node respawns are insufficient.",
            },
            {
                "https://www.wow-professions.com/farming/winters-kiss-farming",
                "https://xscarlife-gaming.com/farming/retail/",
            }
        ),
        SuppliedHerbRoute(
            "bfa-winters-kiss-western-alpine-pass-supplied", 3,
            896, "Drustvar", "Western alpine pass", "Alternative 2 - experimental",
            "herbalism-loop",
            { 36404840, 40104300, 44703740, 47704070, 49804680, 47605250, 43105690, 39005500 },
            {
                "Explores higher western terrain outside the more conventional southern circuits.",
                "Suitable as an experimental alternative when other farming routes are heavily contested.",
                "Herb density is not independently verified. Use GatherMate2 observations to determine whether this route deserves inclusion in your final addon.",
            },
            {
                "https://www.wow-professions.com/farming/winters-kiss-farming",
                "https://xscarlife-gaming.com/farming/retail/",
            }
        ),
    },
    [152509] = {
        SuppliedHerbRoute(
            "bfa-sirens-pollen-barrowknoll-woodland-circuit-supplied", 1,
            896, "Drustvar", "Barrowknoll woodland circuit", "Main",
            "herbalism-loop",
            { 60203750, 63004140, 66004470, 69704790, 68005310, 64105620, 60305390, 57104960, 55704510, 57404120 },
            {
                "Investigate the trees around Barrowknoll Cemetery and the surrounding woodland.",
                "Search tree trunks rather than open fields; Siren's Sting nodes can be overlooked.",
                "Gather Winter's Kiss when passing snowy sections for additional materials.",
            },
            {
                "https://www.wow-professions.com/farming/sirens-pollen-farming",
                "https://xscarlife-gaming.com/farming/retail/",
            }
        ),
        SuppliedHerbRoute(
            "bfa-sirens-pollen-nazmir-eastern-canopy-and-wetlands-supplied", 2,
            863, "Nazmir", "Nazmir eastern canopy and wetlands", "Alternative",
            "herbalism-loop",
            { 61403780, 59403670, 57803660, 54603610, 55603960, 54603970, 46304140, 43803460, 40903430, 35603700, 32903560, 28103490, 29104040, 29405280, 33406580, 37507010, 44507920, 51907850, 61006290, 64705190 },
            {
                "This path draws on a community-published mixed Riverbud/Siren's Pollen circuit in Nazmir.",
                "Follow wooded wetlands and inspect trees near waterways.",
                "Riverbud is an important secondary yield; collect eligible ground herbs for possible Anchor Weed spawns.",
            },
            {
                "https://www.wow-professions.com/farming/sirens-pollen-farming",
                "https://www.wowhead.com/item=152509/sirens-pollen",
                "https://xscarlife-gaming.com/farming/retail/",
            }
        ),
    },
    [152510] = {
        SuppliedHerbRoute(
            "bfa-anchor-weed-zone-wide-mixed-herb-sweep-supplied", 1,
            896, "Drustvar", "Zone-wide mixed-herb sweep", "Main",
            "rare-herb-respawn-loop",
            { 27602560, 34902410, 40902670, 46003250, 54203310, 61803390, 67003860, 67804600, 63005270, 60806260, 55006750, 49307110, 42006840, 36406110, 29005690, 23505050, 22704060 },
            {
                "Gather all eligible ground herbs along the route; this is how you encounter replacement spawns.",
                "Drustvar offers supplementary Riverbud and Winter's Kiss.",
                "Do not interpret the route's individual checkpoints as confirmed Anchor Weed nodes.",
            },
            {
                "https://www.wow-professions.com/farming/anchor-weed-farming",
                "https://xscarlife-gaming.com/farming/retail/",
            }
        ),
        SuppliedHerbRoute(
            "bfa-anchor-weed-freshwater-and-marshland-node-cycle-supplied", 2,
            863, "Nazmir", "Freshwater and marshland node cycle", "Alternative",
            "rare-herb-respawn-loop",
            { 29104040, 28404450, 29405280, 31905680, 33406580, 37507010, 35207850, 41508580, 51907850, 61006290, 59805730, 64705190, 61403790, 54603610, 46304140, 40903430, 35603700 },
            {
                "Uses waterways and marshland zones with documented mixed-herb activity.",
                "Collect Riverbud and other eligible herbs, rather than searching only for Anchor Weed.",
                "Compared with Drustvar, this is a good option when you also want Siren's Pollen.",
            },
            {
                "https://www.wow-professions.com/farming/anchor-weed-farming",
                "https://xscarlife-gaming.com/farming/retail/",
            }
        ),
    },
    [168487] = {
        SuppliedHerbRoute(
            "bfa-zin-anthid-eastern-nazjatar-sweep-supplied", 1,
            1355, "Nazjatar", "Eastern Nazjatar sweep", "Main",
            "herbalism-loop",
            { 54025432, 58245525, 62185660, 61974894, 63734438, 70764443, 77614728, 82403896, 83683326, 76642742, 71863116, 68343643, 68052918, 67712346, 65671605, 64661419, 64662239, 58643060, 60823401, 58914344, 57054979 },
            {
                "Derived from a broader community-posted Nazjatar waypoint circuit, including eastern and northeastern areas.",
                "Take the time to obtain Zin'anthid gathering ranks, which improve yield.",
                "Use a flying mount where available, particularly around steep terrain and hostile mobs.",
            },
            {
                "https://www.wow-professions.com/farming/zin-anthid-farming",
                "https://www.wowhead.com/item=168487/zinanthid",
                "https://xscarlife-gaming.com/farming/retail/",
            }
        ),
        SuppliedHerbRoute(
            "bfa-zin-anthid-western-nazjatar-sweep-supplied", 2,
            1355, "Nazjatar", "Western Nazjatar sweep", "Alternative",
            "herbalism-loop",
            { 55141735, 49442215, 52932958, 51573523, 48313602, 46584146, 48114588, 46004951, 48625376, 43835777, 42904975, 40604295, 35324206, 33424813, 30644950, 29593848, 31683015, 38972736, 39971563, 42672015, 45792241, 48983078 },
            {
                "Covers the western side of Nazjatar as an alternative to the eastern circuit.",
                "Watch for terrain restrictions, especially if farming without flight.",
                "Use GatherMate2 recordings to remove inefficient segments and refine the route for respawn timing.",
            },
            {
                "https://www.wow-professions.com/farming/zin-anthid-farming",
                "https://xscarlife-gaming.com/farming/retail/",
            }
        ),
    },
}

local function WithSuppliedRoutes(itemID, existingSpots)
    local spots = {}
    for _, spot in ipairs(SUPPLIED_HERB_ROUTES[itemID] or {}) do
        spots[#spots + 1] = spot
    end
    for _, spot in ipairs(existingSpots or {}) do
        spot.isRoute = true
        spots[#spots + 1] = spot
    end
    return spots
end

local function RegisterHerb(itemID, itemName, spots, summary)
    Register({
        itemID = itemID,
        itemName = itemName,
        expansion = "battleForAzeroth",
        professions = { "herbalism", "alchemy", "inscription" },
        category = "Herb",
        isRoute = true,
        sourceUrls = { ItemUrl(itemID) },
        summary = summary,
        spots = WithSuppliedRoutes(itemID, spots),
    })
end

RegisterHerb(152505, "Riverbud", {
    TIRAGARDE_WATER_HERB_ROUTE,
}, "Freshwater BFA herb from rivers, ponds, and lake edges.")

RegisterHerb(152506, "Star Moss", {
    VOLDUN_STAR_MOSS_ROUTE,
}, "Structure-favoring BFA herb found on ruins, walls, and buildings.")

RegisterHerb(152507, "Akunda's Bite", {
    VOLDUN_AKUNDA_ROUTE,
}, "Vol'dun desert herb best farmed on open dune and ruin-edge loops.")

RegisterHerb(152508, "Winter's Kiss", {
    DRUSTVAR_WINTER_ROUTE,
}, "Snow-area Kul Tiras herb, strongest in Drustvar routes.")

RegisterHerb(152509, "Siren's Pollen", {
    DRUSTVAR_SIREN_ROUTE,
}, "Tree-line herb with a practical Drustvar route.")

RegisterHerb(152510, "Anchor Weed", {
    TIRAGARDE_ANCHOR_WEED_ROUTE,
    VOLDUN_AKUNDA_ROUTE,
}, "Rare BFA herb respawn from clearing normal BFA herbs.")

RegisterHerb(152511, "Sea Stalk", {
    STORMSONG_SEA_STALK_ROUTE,
    TIRAGARDE_WATER_HERB_ROUTE,
}, "Coastal BFA herb from sea and waterline route loops.")

RegisterHerb(168487, "Zin'anthid", {
    ZINANTHID_NAZJATAR_ROUTE,
}, "Nazjatar patch 8.2 herb, best paired with Osmenite route loops.")
