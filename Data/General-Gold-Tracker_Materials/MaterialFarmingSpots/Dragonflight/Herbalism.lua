local _, NS = ...
local Register = NS.RegisterMaterialFarmingSpot

local function C(x, y, label)
    return { x = x, y = y, label = label }
end

local function ItemUrl(itemID)
    return "https://www.wowhead.com/item=" .. tostring(itemID)
end

local OHNAHRAN_HERB_ROUTE = {
    id = "dragonflight-ohnahran-plains-hochenblume-saxifrage-route",
    mapID = 2023,
    source = "Artisans of Azeroth Ohn'ahran herb and ore route, Wowhead herbalism overview, Warcraft Wiki, WoWDB",
    sourceUrls = {
        "https://artisansofazeroth.com/ohnahran-plains-herb-and-ore-route-wow-dragonflight-gold-guide/",
        "https://www.wowhead.com/guide/professions/herbalism/overview-leveling-dragonflight",
        "https://www.wowhead.com/object=381209/hochenblume",
        "https://www.wowhead.com/object=381207/saxifrage",
        "https://www.wowhead.com/item=191465/saxifrage",
        "https://warcraft.wiki.gg/wiki/Hochenblume",
        "https://www.wowdb.com/items/191460-hochenblume",
    },
    mapName = "Ohn'ahran Plains",
    location = "Northeast ridge, river bends, and southern plains herb loop",
    routeType = "herbalism-loop",
    density = "Medium to high",
    dropDifficulty = "Hochenblume is widespread. Saxifrage is less common and favors rocky or elevated terrain.",
    tips = {
        "Clear every herb node because Saxifrage and elemental modifiers share the regional spawn pool.",
        "Use the ridge sections for stronger Saxifrage checks and the open plains for fast Hochenblume volume.",
        "Frigid, Windswept, Decayed, and Titan-Touched herbs can add elemental side value.",
    },
    coords = {
        C(0.7510, 0.3814, "Northeast ridge start"),
        C(0.7817, 0.4423, "Northeast ridge turn"),
        C(0.7448, 0.5020, "Eastern river ridge"),
        C(0.7243, 0.5665, "Southeast slope"),
        C(0.6768, 0.6147, "South river bend"),
        C(0.6311, 0.7116, "Southern plains herb"),
        C(0.5558, 0.7465, "Southwest sweep"),
        C(0.5192, 0.5490, "Central return"),
        C(0.6026, 0.4892, "Maruukai ridge"),
        C(0.7040, 0.4344, "Northeast return"),
    },
    confidence = "high",
}

local OHNAHRAN_BUBBLE_POPPY_ROUTE = {
    id = "dragonflight-ohnahran-plains-bubble-poppy-water-route",
    mapID = 2023,
    source = "Wowhead Dragonflight herbalism overview, Bubble Poppy comments, and Ohn'ahran route pins",
    sourceUrls = {
        "https://www.wowhead.com/guide/professions/herbalism/overview-leveling-dragonflight",
        "https://www.wowhead.com/item=191467/bubble-poppy",
        "https://www.wowhead.com/item=191468/bubble-poppy",
        "https://artisansofazeroth.com/ohnahran-plains-herb-and-ore-route-wow-dragonflight-gold-guide/",
    },
    mapName = "Ohn'ahran Plains",
    location = "River and lake bends from the northeast route down to the south plains",
    routeType = "herbalism-water-loop",
    density = "Medium",
    dropDifficulty = "Bubble Poppy prefers coasts, rivers, damp caves, and lake edges; clear Hochenblume on the same banks to refresh node rolls.",
    tips = {
        "Ride the waterline and nearby damp ground instead of cutting across dry plains.",
        "Pick common Hochenblume and Saxifrage on the banks so Bubble Poppy can respawn into the shared regional pool.",
        "This loop pairs well with mining because the eastern ridge has ore along the same travel line.",
    },
    coords = {
        C(0.7448, 0.5020, "Eastern river bank"),
        C(0.7243, 0.5665, "Southeast water slope"),
        C(0.6768, 0.6147, "South river bend"),
        C(0.6311, 0.7116, "Southern river crossing"),
        C(0.5558, 0.7465, "Southwest lake edge"),
        C(0.5192, 0.5490, "Central stream return"),
        C(0.6026, 0.4892, "Maruukai waterline"),
    },
    confidence = "high",
}

local OHNAHRAN_WRITHEBARK_ROUTE = {
    id = "dragonflight-ohnahran-plains-writhebark-foliage-route",
    mapID = 2023,
    source = "Wowhead Dragonflight herbalism overview and Writhebark comments around wooded Ohn'ahran foliage",
    sourceUrls = {
        "https://www.wowhead.com/guide/professions/herbalism/overview-leveling-dragonflight",
        "https://www.wowhead.com/item=191470/writhebark",
        "https://www.wowhead.com/item=191471/writhebark",
    },
    mapName = "Ohn'ahran Plains",
    location = "Emerald Gardens, Shady Sanctuary, and nearby wooded Ohn'ahran paths",
    routeType = "herbalism-foliage-loop",
    density = "Medium",
    dropDifficulty = "Writhebark favors dense forest and foliage pockets and is less common than Hochenblume on the same zone route.",
    tips = {
        "Sweep under trees and around foliage rather than open plains.",
        "The 27.43,47.06 pin is a confirmed Writhebark comment anchor; expand around it while clearing every herb node.",
        "Use this route when Writhebark is the target and switch to the river route when Bubble Poppy is stronger.",
    },
    coords = {
        C(0.2743, 0.4706, "Emerald Gardens Writhebark pin"),
        C(0.2500, 0.4880, "Western foliage pocket"),
        C(0.2840, 0.4920, "Sanctuary tree line"),
        C(0.3050, 0.4680, "Eastern foliage return"),
        C(0.3260, 0.4490, "North tree sweep"),
        C(0.3120, 0.4210, "Northwest return"),
    },
    confidence = "medium",
}

-- Supplied Retail Routes geometry, decoded in its original point order.
-- Adapted routes retain their source-resource provenance; vertices are travel anchors.
local function SuppliedHerbRoute(id, sortOrder, mapID, mapName, location, routeOrigin, source, packedCoords, tips, sourceUrls)
    local coords = {}
    for index, packed in ipairs(packedCoords) do
        coords[index] = C(math.floor(packed / 10000) / 10000, (packed % 10000) / 10000,
            location .. " #" .. index)
    end
    -- Provenance also appears in map details, which consume tips and source URLs.
    table.insert(tips, 1, "Supplied route provenance: " .. source)
    return {
        id = id,
        sortOrder = sortOrder,
        mapID = mapID,
        mapName = mapName,
        location = location,
        dropdownLabel = mapName .. ": " .. location,
        routeType = "herbalism-loop",
        routeOrigin = routeOrigin,
        source = source,
        sourceUrls = sourceUrls,
        tips = tips,
        coords = coords,
        dropDifficulty = "Follow nearby herb habitat and elevation; route vertices are travel anchors, not guaranteed node spawns.",
        confidence = "medium",
        inGameTested = false,
        isRoute = true,
    }
end

local SUPPLIED_HERB_ROUTES = {
    ["Hochenblume"] = {
        SuppliedHerbRoute(
            "dragonflight-hochenblume-2023-1-supplied", 1,
            2023, "Ohn'ahran Plains", "Main route - Ohn'ahran Plains",
            "published", "Published xScarlife Hochenblume & Serevite loop, normalized to Hochenblume. xScarlife still lists this route in its current Dragonflight library.",
            {
                50484333, 63514862, 68184511, 68393705, 66433122, 69762981, 73563125, 75012928,
                78352671, 80373272, 77063673, 80874192, 79294617, 77935008, 75425574, 70696706,
                72337387, 68877934, 63947329, 57907256, 50176990, 46316982, 43846999, 42026600,
                46126512, 51996507, 53296293, 52585931, 49846195, 48696269, 46075990, 46385580,
                48915266, 47395001, 45355267, 43155318, 43674661,
            },
            {
                "This is my main choice because Ohn'ahran is extremely open and therefore has very low vertical/turning overhead compared with Azure Span.",
                "Do not skip ordinary Hochenblume. It is the most common replacement in Dragon Isles herb-node locations, so clearing it contributes to node turnover.",
                "The route covers a large section of the zone rather than repeatedly hammering a tiny cluster, which is useful when another farmer is active.",
                "Deviate briefly for elemental nodes; because Hochenblume has no strict terrain requirement, staying glued exactly to the drawn line is unnecessary.",
                "If you gather mining at the same time, this is particularly efficient because the source route was deliberately designed around Hochenblume + Serevite.",
            },
            {
                "https://xscarlife-gaming.com/farming-retail/?utm_source=chatgpt.com",
                "https://www.wowhead.com/mx/guide/professions/herbalism/overview-leveling-dragonflight?utm_source=chatgpt.com",
                "https://www.wowhead.com/guide/list-of-zone-map-id-number-for-navigation-in-wow-and-tomtom-19501?utm_source=chatgpt.com",
                "https://xscarlife-gaming.com/farming-retail/",
                "https://www.wowhead.com/guide/professions/herbalism/overview-leveling-dragonflight?utm_source=chatgpt.com",
            }
        ),
        SuppliedHerbRoute(
            "dragonflight-hochenblume-2022-2-supplied", 2,
            2022, "The Waking Shores", "Alternative A - The Waking Shores",
            "published", "Published xScarlife Bubble Poppy & Hochenblume multifarm, normalized to Hochenblume.",
            {
                53022940, 54893545, 60533839, 60025096, 61395540, 64085945, 66566015, 67556122,
                64816714, 62036748, 58846264, 56116035, 54296168, 54935761, 54585581, 54055440,
                50844849, 49464624, 48334663, 49184315, 49713984, 51323557, 48763083,
            },
            {
                "Excellent dual-purpose Hochenblume/Bubble Poppy route.",
                "Search both sides of streams instead of remaining exactly over the route centerline.",
                "Rocky transitions also give you a reasonable shot at Saxifrage, making this a strong general Dragonflight herbalism loop.",
                "The route is considerably shorter than the Ohn'ahran loop, which can be useful if respawn turnover is fast.",
            },
            {
                "https://xscarlife-gaming.com/farming-retail/?utm_source=chatgpt.com",
                "https://www.wowhead.com/guide/list-of-zone-map-id-number-for-navigation-in-wow-and-tomtom-19501?utm_source=chatgpt.com",
                "https://xscarlife-gaming.com/farming-retail/",
                "https://www.wowhead.com/guide/professions/herbalism/overview-leveling-dragonflight?utm_source=chatgpt.com",
            }
        ),
        SuppliedHerbRoute(
            "dragonflight-hochenblume-2024-3-supplied", 3,
            2024, "The Azure Span", "Alternative B - The Azure Span",
            "published", "Published xScarlife Hochenblume & Serevite Azure Span route.",
            {
                25152910, 26263101, 26233324, 25443682, 26623730, 28163699, 29213459, 30873506,
                32183670, 33133997, 30934125, 28664136, 27703832, 26223995, 28124730, 26104776,
                22914818, 20214565, 16844505, 17084193, 18804121, 20624336, 20784025, 22443800,
                20483353, 18173205, 17293033, 21582946, 23203039,
            },
            {
                "This western Azure Span loop is useful if you also want Writhebark and Decayed elemental nodes.",
                "It has more altitude changes than Ohn'ahran, so use it for material diversity rather than maximum Hochenblume/hour.",
                "Clear herbs around Brackenhide even if they are not Hochenblume; shared node turnover matters here particularly. Wowhead notes Decayed herbs occur frequently around Brackenhide Hollow.",
            },
            {
                "https://xscarlife-gaming.com/farming-retail/?utm_source=chatgpt.com",
                "https://www.wowhead.com/guide/professions/herbalism/overview-leveling-dragonflight?utm_source=chatgpt.com",
                "https://www.wowhead.com/guide/list-of-zone-map-id-number-for-navigation-in-wow-and-tomtom-19501?utm_source=chatgpt.com",
                "https://xscarlife-gaming.com/farming-retail/",
            }
        ),
    },
    ["Bubble Poppy"] = {
        SuppliedHerbRoute(
            "dragonflight-bubble-poppy-2022-1-supplied", 1,
            2022, "The Waking Shores", "Main route - The Waking Shores",
            "published", "Published xScarlife Bubble Poppy & Hochenblume route, normalized to Bubble Poppy.",
            {
                53022940, 54893545, 60533839, 60025096, 61395540, 64085945, 66566015, 67556122,
                64816714, 62036748, 58846264, 56116035, 54296168, 54935761, 54585581, 54055440,
                50844849, 49464624, 48334663, 49184315, 49713984, 51323557, 48763083,
            },
            {
                "Follow the water, not the drawn polyline religiously. When the route runs parallel to a river, zig-zag visually between both banks.",
                "A long-standing community farm starts around Wingrest, takes the swamp/river system, then eventually follows the major river toward Ohn'ahran; that independently matches the logic of this route.",
                "Check small islands, river bends and damp cave entrances.",
                "Pick nearby Hochenblume too. Leaving them untouched can reduce the rate at which useful nodes recycle.",
                "If specializing specifically for this herb, Dragonflight's corresponding herb specialization is Fungiculture.",
            },
            {
                "https://xscarlife-gaming.com/farming-retail/?utm_source=chatgpt.com",
                "https://us.forums.blizzard.com/en/wow/t/can-we-talk-about-the-dearth-of-bubble-poppy/1484515?utm_source=chatgpt.com",
                "https://www.wowhead.com/guide/professions/herbalism/specialization-builds-dragonflight?utm_source=chatgpt.com",
                "https://www.wowhead.com/object%3D375241/bubble-poppy?utm_source=chatgpt.com",
                "https://www.wowhead.com/guide/list-of-zone-map-id-number-for-navigation-in-wow-and-tomtom-19501?utm_source=chatgpt.com",
                "https://xscarlife-gaming.com/farming-retail/",
                "https://www.wowhead.com/guide/professions/herbalism/overview-leveling-dragonflight?utm_source=chatgpt.com",
            }
        ),
        SuppliedHerbRoute(
            "dragonflight-bubble-poppy-2023-2-supplied", 2,
            2023, "Ohn'ahran Plains", "Alternative A - Ohn'ahran Plains Riverlands",
            "adapted", "Adapted. Uses xScarlife's large Ohn'ahran gathering loop as the navigational spine; selected because Ohn'ahran's extensive rivers/lakes are confirmed Bubble Poppy habitat. Wowhead comments specifically identify Ohn'ahran rivers and lakes as productive.",
            {
                50484333, 63514862, 68184511, 68393705, 66433122, 69762981, 73563125, 75012928,
                78352671, 80373272, 77063673, 80874192, 79294617, 77935008, 75425574, 70696706,
                72337387, 68877934, 63947329, 57907256, 50176990, 46316982, 43846999, 42026600,
                46126512, 51996507, 53296293, 52585931, 49846195, 48696269, 46075990, 46385580,
                48915266, 47395001, 45355267, 43155318, 43674661,
            },
            {
                "Whenever the route intersects the large central/eastern river system, temporarily abandon the exact line and follow both banks.",
                "The Ohn'ahran community route is especially useful when Waking Shores has other gatherers.",
                "Windswept variants are particularly well represented in Ohn'ahran compared with most other Dragonflight zones.",
                "Keep the loop broad rather than repeatedly circling one small pond.",
            },
            {
                "https://www.wowhead.com/item%3D191469/bubble-poppy?utm_source=chatgpt.com",
                "https://www.wowhead.com/object%3D375245/windswept-bubble-poppy?utm_source=chatgpt.com",
                "https://www.wowhead.com/object%3D375241/bubble-poppy?utm_source=chatgpt.com",
                "https://www.wowhead.com/guide/list-of-zone-map-id-number-for-navigation-in-wow-and-tomtom-19501?utm_source=chatgpt.com",
                "https://xscarlife-gaming.com/farming-retail/",
                "https://www.wowhead.com/guide/professions/herbalism/overview-leveling-dragonflight?utm_source=chatgpt.com",
            }
        ),
        SuppliedHerbRoute(
            "dragonflight-bubble-poppy-2024-3-supplied", 3,
            2024, "The Azure Span", "Alternative B - The Azure Span compact water/soil loop",
            "adapted", "Adapted hidden/community route. Derived from the Routes import attached to Wowhead's Rich Soil coordinate collection, which concentrates around central Azure Span. Azure Span has the highest current Wowhead base Bubble Poppy node count.",
            {
                41504048, 45012997, 46725562, 44125964, 40776134, 40085888, 38664968, 41275046,
                41174862, 40984797,
            },
            {
                "Treat this as a compact search circuit rather than a strict racing line.",
                "Search river/lake edges extending slightly outward from every route point.",
                "Azure Span records 532 base Bubble Poppy locations, the highest of the original four Dragon Isles outdoor zones in Wowhead's current dataset.",
                "Especially good if you also want Frigid herbs/Rousing Frost.",
            },
            {
                "https://www.wowhead.com/ptr-2/object%3D248114/rich-soil?utm_source=chatgpt.com",
                "https://www.wowhead.com/object%3D375241/bubble-poppy?utm_source=chatgpt.com",
                "https://www.wowhead.com/guide/list-of-zone-map-id-number-for-navigation-in-wow-and-tomtom-19501?utm_source=chatgpt.com",
                "https://xscarlife-gaming.com/farming-retail/",
                "https://www.wowhead.com/guide/professions/herbalism/overview-leveling-dragonflight?utm_source=chatgpt.com",
            }
        ),
    },
    ["Saxifrage"] = {
        SuppliedHerbRoute(
            "dragonflight-saxifrage-2022-1-supplied", 1,
            2022, "The Waking Shores", "Main route - The Waking Shores mountain circuit",
            "adapted", "Adapted from Golden Routes' published Draconium Waking Shores mountain loop. The route follows exactly the type of rocky/high-elevation terrain Saxifrage prefers.",
            {
                30546863, 33165861, 29575447, 35964846, 38434904, 39355392, 43105454, 45445806,
                39075623, 40246546, 35156156, 33946524, 34956800, 38896837, 38387197, 39627746,
                37147784, 32337799, 30757329, 29137417, 23807708, 24217229, 25576860,
            },
            {
                "Fly the contour of the ridge, rather than cutting directly across valleys between route points.",
                "Check ledges above and below your current altitude; Saxifrage's vertical habitat means minimap nodes can sit on another elevation.",
                "Waking Shores is the strongest statistical choice: 616 base-node records plus 481 Lush Saxifrage records.",
                "Titan-Touched Saxifrage is also strongly concentrated here: Wowhead records 349 Waking Shores locations.",
                "For Windswept nodes, mount immediately when gathering completes; community reports note you can get onto your drake before the knockback takes effect.",
            },
            {
                "https://opachiiguides.wordpress.com/2022/12/09/where-to-farm-draconium-wow-dragonflight-gold-making-guide/",
                "https://www.wowhead.com/object%3D381207/saxifrage?utm_source=chatgpt.com",
                "https://www.wowhead.com/object%3D381205/titan-touched-saxifrage?utm_source=chatgpt.com",
                "https://www.wowhead.com/item%3D191466/saxifrage?utm_source=chatgpt.com",
                "https://www.wowhead.com/guide/list-of-zone-map-id-number-for-navigation-in-wow-and-tomtom-19501?utm_source=chatgpt.com",
                "https://xscarlife-gaming.com/farming-retail/",
                "https://www.wowhead.com/guide/professions/herbalism/overview-leveling-dragonflight?utm_source=chatgpt.com",
            }
        ),
        SuppliedHerbRoute(
            "dragonflight-saxifrage-2023-2-supplied", 2,
            2023, "Ohn'ahran Plains", "Alternative A - Ohn'ahran ridge/open-country circuit",
            "adapted", "Adapted from xScarlife's Ohn'ahran gathering circuit.",
            {
                50484333, 63514862, 68184511, 68393705, 66433122, 69762981, 73563125, 75012928,
                78352671, 80373272, 77063673, 80874192, 79294617, 77935008, 75425574, 70696706,
                72337387, 68877934, 63947329, 57907256, 50176990, 46316982, 43846999, 42026600,
                46126512, 51996507, 53296293, 52585931, 49846195, 48696269, 46075990, 46385580,
                48915266, 47395001, 45355267, 43155318, 43674661,
            },
            {
                "Ohn'ahran is the #2 base Saxifrage zone in recorded nodes, only slightly behind Waking Shores.",
                "Unlike Waking Shores, you can maintain much higher average flight speed because of the open terrain.",
                "Inspect elevated rocky borders whenever the route passes from grassland into hills.",
                "This is arguably the better route if you specifically value Windswept Saxifrage: Wowhead records 430 locations in Ohn'ahran versus 193 in Waking Shores.",
                "Clear nearby Hochenblume to promote shared-node turnover.",
            },
            {
                "https://www.wowhead.com/object%3D381207/saxifrage?utm_source=chatgpt.com",
                "https://www.wowhead.com/object%3D381202/windswept-saxifrage?utm_source=chatgpt.com",
                "https://www.wowhead.com/guide/list-of-zone-map-id-number-for-navigation-in-wow-and-tomtom-19501?utm_source=chatgpt.com",
                "https://xscarlife-gaming.com/farming-retail/",
                "https://www.wowhead.com/guide/professions/herbalism/overview-leveling-dragonflight?utm_source=chatgpt.com",
            }
        ),
        SuppliedHerbRoute(
            "dragonflight-saxifrage-2025-3-supplied", 3,
            2025, "Thaldraszus", "Alternative B - Thaldraszus jagged terrain loop",
            "adapted", "Adapted/obscure community route from an old Disturbed Dirt/Explorer's Pack Routes dump. The original author specifically built these paths around actual outdoor spawn locations and elevation/mountain terrain.",
            {
                41274796, 49544832, 50904630, 49934479, 54253976, 56003589, 54533417, 55443163,
                56053171, 59572819, 55975146, 62466656, 62286983, 59496899, 58186722, 55576803,
                56937400, 54047906, 59418818, 56048385, 55628472, 53488739, 52858334, 46727738,
                39908217, 39138411, 38258181, 37707746, 37807607, 35647543, 32337320, 35677180,
                35477004, 37436854, 38946835, 35496769, 34446590, 34026495, 34596219,
            },
            {
                "This is the less-obvious competition-avoidance route, not the maximum raw-node route.",
                "Follow mountainsides rather than cutting horizontally through open ground.",
                "Thaldraszus has fewer base Saxifrage records than Waking/Ohn'ahran, but is still a useful Titan-Touched farming zone.",
                "Useful when the two conventional zones are heavily farmed.",
            },
            {
                "https://www.reddit.com/r/wow/comments/10s3idk",
                "https://www.wowhead.com/object%3D381207/saxifrage?utm_source=chatgpt.com",
                "https://www.wowhead.com/guide/list-of-zone-map-id-number-for-navigation-in-wow-and-tomtom-19501?utm_source=chatgpt.com",
                "https://xscarlife-gaming.com/farming-retail/",
                "https://www.wowhead.com/guide/professions/herbalism/overview-leveling-dragonflight?utm_source=chatgpt.com",
            }
        ),
    },
    ["Writhebark"] = {
        SuppliedHerbRoute(
            "dragonflight-writhebark-2024-1-supplied", 1,
            2024, "The Azure Span", "Main route - Western Azure Span",
            "published", "Dedicated xScarlife Writhebark route. I retained the exact closed-loop geometry but normalized traversal direction. xScarlife's current library still lists The Azure Span: Writhebark - WM ON.",
            {
                21573069, 22762871, 23002673, 21622577, 18642833, 18223224, 20563648, 18333864,
                16544045, 15334429, 20174566, 20224112, 21924219, 21134560, 22474797, 25494814,
                27524714, 27424424, 26764000, 30424018, 30874658, 33504769, 36754371, 39014408,
                41334290, 35024027, 35443754, 41743917, 39353324, 37012874, 35343437, 32153329,
                30193552, 32833907, 27843740, 27103797, 25713732, 24273591, 25933397, 27033134,
                24612844, 24513059, 23203159, 22853349, 23003472, 21663483,
            },
            {
                "This is the route I would put first in your addon.",
                "It deliberately stays in western Azure Span, matching the long-standing report that the west side is particularly good for Writhebark.",
                "Fly through tree lines and shrub belts, not over the center of roads or open snow fields.",
                "Inspect both sides of tree-covered ridges.",
                "The xScarlife source calls this WM ON; that is a source label rather than a requirement of the Routes geometry.",
                "Arboriculture is the Dragonflight herb specialization corresponding to Writhebark.",
            },
            {
                "https://xscarlife-gaming.com/farming-retail/?utm_source=chatgpt.com",
                "https://www.wowhead.com/ptr/item%3D191470/writhebark?utm_source=chatgpt.com",
                "https://www.wowhead.com/guide/professions/herbalism/specialization-builds-dragonflight?utm_source=chatgpt.com",
                "https://www.wowhead.com/guide/list-of-zone-map-id-number-for-navigation-in-wow-and-tomtom-19501?utm_source=chatgpt.com",
                "https://xscarlife-gaming.com/farming-retail/",
                "https://www.wowhead.com/guide/professions/herbalism/overview-leveling-dragonflight?utm_source=chatgpt.com",
            }
        ),
        SuppliedHerbRoute(
            "dragonflight-writhebark-2024-2-supplied", 2,
            2024, "The Azure Span", "Alternative A - Broad north/west Azure forest loop",
            "published", "Dedicated Writhebark route recovered from the older Golden Routes / Opachii archive.",
            {
                24252953, 27133340, 32623470, 38823923, 37053439, 40433299, 44873085, 49743648,
                51153139, 55072641, 58123132, 54793604, 51884399, 51385273, 47245345, 47704856,
                40074408, 27853875, 23033758, 21343420, 21643211,
            },
            {
                "Broader than the xScarlife route, reaching from the western forests toward roughly the central/northern part of Azure Span.",
                "Better if the far-western Brackenhide side is occupied.",
                "Because it crosses more terrain types, expect somewhat more Hochenblume and Saxifrage mixed into the farm.",
                "Do not skip Writhebark icons that appear slightly inside the forest; the best spawn can require a short detour from the visible route line.",
            },
            {
                "https://opachiiguides.wordpress.com/2022/12/04/writhebark-route-in-wow-dragonflight-the-azure-span/",
                "https://www.wowhead.com/ptr/item%3D191470/writhebark?utm_source=chatgpt.com",
                "https://www.wowhead.com/guide/list-of-zone-map-id-number-for-navigation-in-wow-and-tomtom-19501?utm_source=chatgpt.com",
                "https://xscarlife-gaming.com/farming-retail/",
                "https://www.wowhead.com/guide/professions/herbalism/overview-leveling-dragonflight?utm_source=chatgpt.com",
            }
        ),
        SuppliedHerbRoute(
            "dragonflight-writhebark-2024-3-supplied", 3,
            2024, "The Azure Span", "Alternative B - Eastern/central Azure compact forest loop",
            "published", "The second dedicated Writhebark loop preserved by Golden Routes, originally called Writhebark 2.",
            {
                55272591, 50603189, 49663887, 50554232, 52343790, 54353923, 55613426, 57564134,
                57844695, 59274196, 63334484, 66063763, 63723853, 62263719, 64582951, 58503141,
            },
            {
                "This loop occupies roughly the 50–66 X / 26–47 Y part of Azure Span, making it geographically distinct from the western main route.",
                "It is substantially shorter, so it is good for quick repeated circuits.",
                "Use this when the western forest has visible competition.",
                "Forest boundaries are more important than strict route proximity: when the path enters an open area, scan the nearby tree line first.",
            },
            {
                "https://opachiiguides.wordpress.com/2022/12/04/writhebark-route-in-wow-dragonflight-the-azure-span/",
                "https://www.wowhead.com/ptr/item%3D191470/writhebark?utm_source=chatgpt.com",
                "https://www.wowhead.com/guide/list-of-zone-map-id-number-for-navigation-in-wow-and-tomtom-19501?utm_source=chatgpt.com",
                "https://xscarlife-gaming.com/farming-retail/",
                "https://www.wowhead.com/guide/professions/herbalism/overview-leveling-dragonflight?utm_source=chatgpt.com",
            }
        ),
    },
}

local function WithSuppliedRoutes(itemName, existingSpots)
    local spots = {}
    for _, spot in ipairs(SUPPLIED_HERB_ROUTES[itemName] or {}) do
        spots[#spots + 1] = spot
    end
    for _, spot in ipairs(existingSpots or { OHNAHRAN_HERB_ROUTE }) do
        spot.isRoute = true
        spots[#spots + 1] = spot
    end
    return spots
end

local function RegisterHerb(itemID, itemName, summary, qualityRank, spots)
    Register({
        itemID = itemID,
        itemName = itemName,
        expansion = "dragonflight",
        professions = { "herbalism", "alchemy", "inscription" },
        category = "Herb",
        qualityRank = qualityRank,
        isRoute = true,
        sourceUrls = { ItemUrl(itemID) },
        summary = summary,
        spots = WithSuppliedRoutes(itemName, spots),
    })
end

RegisterHerb(191460, "Hochenblume",
    "Common Dragon Isles herb; start with the broad Ohn'ahran loop, with Waking Shores and Azure Span alternatives.", 1)
RegisterHerb(191461, "Hochenblume",
    "Common Dragon Isles herb; start with the broad Ohn'ahran loop, with Waking Shores and Azure Span alternatives.", 2)
RegisterHerb(191462, "Hochenblume",
    "Common Dragon Isles herb; start with the broad Ohn'ahran loop, with Waking Shores and Azure Span alternatives.", 3)
RegisterHerb(191464, "Saxifrage",
    "Rocky-terrain Dragonflight herb; start with the adapted Waking Shores mountain circuit, then Ohn'ahran or Thaldraszus.", 1)
RegisterHerb(191465, "Saxifrage",
    "Rocky-terrain Dragonflight herb; start with the adapted Waking Shores mountain circuit, then Ohn'ahran or Thaldraszus.", 2)
RegisterHerb(191466, "Saxifrage",
    "Rocky-terrain Dragonflight herb; start with the adapted Waking Shores mountain circuit, then Ohn'ahran or Thaldraszus.", 3)
RegisterHerb(191467, "Bubble Poppy",
    "Water-edge Dragonflight herb; start with Waking Shores, with Ohn'ahran riverlands and a compact Azure Span alternative.", 1,
    { OHNAHRAN_BUBBLE_POPPY_ROUTE, OHNAHRAN_HERB_ROUTE })
RegisterHerb(191468, "Bubble Poppy",
    "Water-edge Dragonflight herb; start with Waking Shores, with Ohn'ahran riverlands and a compact Azure Span alternative.", 2,
    { OHNAHRAN_BUBBLE_POPPY_ROUTE, OHNAHRAN_HERB_ROUTE })
RegisterHerb(191469, "Bubble Poppy",
    "Water-edge Dragonflight herb; start with Waking Shores, with Ohn'ahran riverlands and a compact Azure Span alternative.", 3,
    { OHNAHRAN_BUBBLE_POPPY_ROUTE, OHNAHRAN_HERB_ROUTE })
RegisterHerb(191470, "Writhebark",
    "Forest-favoring Dragonflight herb; start in western Azure Span, with two distinct Azure forest alternatives and legacy Ohn'ahran checks.", 1,
    { OHNAHRAN_WRITHEBARK_ROUTE, OHNAHRAN_HERB_ROUTE })
RegisterHerb(191471, "Writhebark",
    "Forest-favoring Dragonflight herb; start in western Azure Span, with two distinct Azure forest alternatives and legacy Ohn'ahran checks.", 2,
    { OHNAHRAN_WRITHEBARK_ROUTE, OHNAHRAN_HERB_ROUTE })
RegisterHerb(191472, "Writhebark",
    "Forest-favoring Dragonflight herb; start in western Azure Span, with two distinct Azure forest alternatives and legacy Ohn'ahran checks.", 3,
    { OHNAHRAN_WRITHEBARK_ROUTE, OHNAHRAN_HERB_ROUTE })
