local _, NS = ...
local Register = NS.RegisterMaterialFarmingSpot

local function C(x, y, label)
    return { x = x, y = y, label = label }
end

local function ItemUrl(itemID)
    return "https://www.wowhead.com/item=" .. tostring(itemID)
end

-- Decoded from the 18 supplied Retail Routes reconstructions, preserving point order.
-- These are route control points, not guaranteed herb spawns; in-game imports are unvalidated.
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
        source = "Supplied Retail Routes reconstruction; research includes historical Cataclysm guides",
        sourceUrls = sourceUrls,
        dropDifficulty = "Reconstructed route control points, not guaranteed herb spawns. In-game import has not been validated.",
        tips = tips,
        coords = RouteCoords(location, packedCoords),
        confidence = "medium",
        isRoute = true,
    }
end

local CINDERBLOOM_ROUTES = {
    HerbRoute(
        "cataclysm-cinderbloom-hyjal-charred", 1,
        198, "Mount Hyjal", "1. Main - Hyjal charred Flamewake circuit",
        {
            24004300, 29004500, 34004900, 39005400, 45005900, 51006200, 56006800, 63007300,
            71007700, 70008200, 61008400, 55008000, 50007500, 45007000, 39006400, 33005800,
            27005500, 22005100,
        },
        {
            "Prioritize this loop while The Flamewake is still burned and un-restored; quest progression converts much of it into The Regrowth.",
            "Skim scorched ground between The Flamewake, Scorched Plain and the southern approach toward Sulfuron Spire.",
            "After completing the restoration questline, switch to the Sulfuron alternative for a more Cinderbloom-focused circuit.",
        },
        {
            "https://www.wowhead.com/cata/guide/professions/cinderbloom-herb-farming-guide",
            "https://www.wow-professions.com/farming/cinderbloom-farming",
        }
    ),
    HerbRoute(
        "cataclysm-cinderbloom-hyjal-sulfuron", 2,
        198, "Mount Hyjal", "2. Alternative 1 - Hyjal Sulfuron Spire after questing",
        {
            38006800, 43006900, 46007400, 48008000, 53008300, 59008500, 65008400, 71007900,
            70007400, 63007100, 58007300, 54007700, 50007100, 46006700, 41006500,
        },
        {
            "Use this after Flamewake has become The Regrowth, when the unburned region yields proportionally more Stormvine.",
            "Circle Sulfuron Spire, Ascendant’s Rise and the scorched approaches toward Gates of Sothann; avoid diving into the lava.",
            "It is intentionally a smaller repeatable loop than a complete Hyjal sweep.",
        },
        {
            "https://www.wowhead.com/cata/guide/professions/cinderbloom-herb-farming-guide",
        }
    ),
    HerbRoute(
        "cataclysm-cinderbloom-deepholm-outer", 3,
        207, "Deepholm", "3. Alternative 2 - Deepholm outer mixed-herb circuit",
        {
            25003900, 30003200, 38002700, 47002800, 58002700, 68003200, 75003900, 76004800,
            72005800, 70007000, 62007900, 52008300, 42007900, 32007400, 26006500, 22005300,
        },
        {
            "Farm this when Hyjal is depleted; expect a substantial amount of Heartblossom alongside Cinderbloom.",
            "Keep the orbit outside Temple of Earth rather than crossing the central structure repeatedly.",
            "Follow the ledges at Needlerock, Verlok Stand and Storm’s Fury Wreckage while checking the minimap for spawns.",
        },
        {
            "https://www.wow-professions.com/farming/cinderbloom-farming",
            "https://www.wowhead.com/cata/guide/professions/cinderbloom-herb-farming-guide",
        }
    ),
}

local STORMVINE_ROUTES = {
    HerbRoute(
        "cataclysm-stormvine-shimmering-north", 1,
        205, "Shimmering Expanse", "1. Main - Shimmering Expanse north and temple loop",
        {
            39003500, 47002800, 55002700, 64003300, 69004200, 65004900, 57004500, 49004100,
            43004700, 35005200, 32006300, 37006900, 44007000, 52007500, 58008300, 62007900,
            56006900, 47006000,
        },
        {
            "Prioritize the Ruins of Thelserai Temple and Silver Tide Hollow clusters; the northern part of this zone is productive.",
            "Stormvine often blends into the bases of large plants and coral; fly/swim close to terrain instead of crossing empty chasms.",
            "Gather Azshara’s Veil as a byproduct and use an underwater mount or Druid aquatic form.",
        },
        {
            "https://www.warcrafttavern.com/cataclysm/guides/stormvine-farming-guide",
            "https://www.wow-professions.com/farming/stormvine-farming",
        }
    ),
    HerbRoute(
        "cataclysm-stormvine-abyssal-lghorek", 2,
        204, "Abyssal Depths", "2. Alternative 1 - Abyssal Depths Lghorek ridges",
        {
            43003000, 50002200, 56002900, 58003900, 54004600, 58005500, 52006400, 45007000,
            36008000, 24008200, 18007400, 20006400, 24005600, 32005100, 35004100,
        },
        {
            "Sweep the Promontory Point ledges, western/southern L’ghorek and the eastern chasm; large spaces between clusters have few nodes.",
            "The Abandoned Reef is a particularly obscure detour for Stormvine, but not a good Azshara’s Veil target.",
            "Use this as an alternative when Shimmering Expanse is crowded.",
        },
        {
            "https://www.warcrafttavern.com/cataclysm/guides/stormvine-farming-guide",
            "https://almarsguides.com/wow/farming/Cataclysm/HerbLocations/Vashjir/",
        }
    ),
    HerbRoute(
        "cataclysm-stormvine-hyjal-greenbelt", 3,
        198, "Mount Hyjal", "3. Alternative 2 - Hyjal green belt and Regrowth",
        {
            20003400, 25002800, 32002700, 39003200, 44004000, 51003800, 59003100, 64002200,
            69002300, 65003100, 58003700, 50004400, 42004900, 34005300, 28004800, 21004200,
        },
        {
            "Choose this if you dislike underwater farming; favor the green northern and western sections, not the charred south.",
            "After local quests restore Flamewake into The Regrowth, that area offers more Stormvine opportunities.",
            "Also gather Cinderbloom when it is near the route to avoid wasted travel.",
        },
        {
            "https://www.wowhead.com/cata/guide/professions/stormvine-herb-farming-guide",
            "https://www.warcrafttavern.com/cataclysm/guides/stormvine-farming-guide",
        }
    ),
}

local AZSHARAS_VEIL_ROUTES = {
    HerbRoute(
        "cataclysm-azsharas-veil-shimmering-lagoons", 1,
        205, "Shimmering Expanse", "1. Main - Shimmering Expanse lagoon circuit",
        {
            42003100, 49002500, 57002900, 64003600, 67004400, 62004900, 55004400, 48004100,
            40004400, 35005400, 35006400, 42006700, 49006800, 56007700, 60008500, 64007900,
            58006800, 49005900, 44004900,
        },
        {
            "Target shallow/bottom terrain around Silver Tide Hollow, Ruins of Thelserai Temple and toward Biel’aran Ridge.",
            "When pockets stop spawning, switch to nearby Abyssal Depths instead of crossing barren chasms.",
            "Stormvine shares many of the same productive underwater patches.",
        },
        {
            "https://www.wow-professions.com/farming/azsharas-veil-farming",
            "https://www.warcrafttavern.com/cataclysm/guides/azsharas-veil-farming-guide",
        }
    ),
    HerbRoute(
        "cataclysm-azsharas-veil-abyssal-coves", 2,
        204, "Abyssal Depths", "2. Alternative 1 - Abyssal Depths Promontory and coves",
        {
            39002500, 47002200, 55002700, 62003400, 64004300, 56004600, 53005500, 59006500,
            63007500, 58008300, 50007600, 45006500, 39005800, 34004800, 35003600,
        },
        {
            "Skim Promontory Point and reef/cove edges toward Darkbreak Cove rather than circling the empty open sea.",
            "Avoid spending time in the far southwest Abandoned Reef if specifically targeting Azshara’s Veil; that is better for Stormvine.",
            "Use when the Shimmering Expanse route has competition.",
        },
        {
            "https://www.wow-professions.com/farming/azsharas-veil-farming",
            "https://almarsguides.com/wow/farming/Cataclysm/HerbLocations/Vashjir/",
        }
    ),
    HerbRoute(
        "cataclysm-azsharas-veil-tol-barad-canal", 3,
        245, "Tol Barad Peninsula", "3. Alternative 2 - Tol Barad Peninsula canal",
        {
            45002000, 51001700, 56002200, 55002800, 48003300, 47004000, 53004600, 60004900,
            61005500, 57006100, 49006100, 43005800, 39005200, 39004400, 45003700, 42002900,
        },
        {
            "Follow the canal through the center of the peninsula and check the Cape of Lost Hope end; water routes work better with aquatic form or water walking.",
            "This area cannot be flown over, unlike Vashj’ir, so keep the circuit compact.",
            "A historical farming note warns about an elite shark near the north end of the water route; check before diving.",
        },
        {
            "https://www.warcrafttavern.com/cataclysm/guides/azsharas-veil-farming-guide",
            "https://warcraftzillionaire.blogspot.com/2010/12/tol-barad-herbalism-route-farming-path.html",
        }
    ),
}

local HEARTBLOSSOM_ROUTES = {
    HerbRoute(
        "cataclysm-heartblossom-deepholm-full-ring", 1,
        207, "Deepholm", "1. Main - Deepholm outer ring",
        {
            30003300, 38002600, 48002100, 56001800, 65002000, 72002900, 75003900, 73004900,
            68005900, 70007100, 62008000, 50008200, 41007600, 32007300, 25006500, 24005200,
            28004300,
        },
        {
            "Heartblossom grows only in Deepholm; this is the broadest route, spanning many terraces and elevations.",
            "Orbit around Temple of Earth and favor herb-bearing outer ledges rather than crossing through the center.",
            "Expect Cinderbloom mixed into the same zone; take it to maintain overall gathering efficiency.",
        },
        {
            "https://www.wow-professions.com/farming/heartblossom-farming",
            "https://warcraftzillionaire.blogspot.com/2010/12/deepholm-herbalism-route-herbing.html",
        }
    ),
    HerbRoute(
        "cataclysm-heartblossom-deepholm-west", 2,
        207, "Deepholm", "2. Alternative 1 - West Needlerock / Stonehearth",
        {
            21003600, 27002900, 35002400, 42002100, 47002700, 44003700, 39004700, 35005700,
            30006700, 27007500, 23006800, 20005800, 18004600,
        },
        {
            "A short western circuit around Needlerock Chasm, Needlerock Slag, Stonehearth and The Pale Roost.",
            "A worthwhile alternative when the full Deepholm perimeter is occupied.",
            "Do not attempt to cut directly across high cliff faces; follow reachable ledges between waypoints.",
        },
        {
            "https://www.wow-professions.com/farming/heartblossom-farming",
            "https://www.wow-professions.com/farming/cinderbloom-farming",
        }
    ),
    HerbRoute(
        "cataclysm-heartblossom-deepholm-east", 3,
        207, "Deepholm", "3. Alternative 2 - East Verlok / Crimson circuit",
        {
            57001900, 66002100, 73002600, 79003500, 77004500, 71005100, 68005900, 72006800,
            70007800, 62008200, 57007300, 58006300, 61005300, 60004300, 60003300,
        },
        {
            "Concentrates on Verlok Stand, Twilight Precipice, Crimson Expanse and the southeast shelf.",
            "This avoids much of the western perimeter and is useful against zone competition.",
            "Search both vertical tiers around the cliffs; these are route control points, not ground-level-only navigation.",
        },
        {
            "https://www.wow-professions.com/farming/heartblossom-farming",
            "https://warcraftzillionaire.blogspot.com/2010/12/deepholm-herbalism-route-herbing.html",
        }
    ),
}

local TWILIGHT_JASMINE_ROUTES = {
    HerbRoute(
        "cataclysm-twilight-jasmine-highlands-interior", 1,
        241, "Twilight Highlands", "1. Main - Twilight Highlands green interior",
        {
            33003500, 39002900, 46002300, 54001900, 62001700, 69002300, 71003200, 67003900,
            60004400, 54004800, 51005500, 56006100, 63006600, 69006900, 70007600, 61007800,
            53007300, 46006600, 39005900, 34005200, 29004500,
        },
        {
            "Keep to grassy interior areas from Thundermar toward Kirthaven and through central Bloodgulch; mountain ridges yield fewer herbs.",
            "An extended interior sweep reduces direct overlap with other farmers on the classic central loop.",
            "Watch for Cinderbloom as a byproduct in the highlands.",
        },
        {
            "https://www.wow-professions.com/farming/twilight-jasmine-farming",
            "https://www.warcrafttavern.com/cataclysm/guides/twilight-jasmine-farming-guide/",
        }
    ),
    HerbRoute(
        "cataclysm-twilight-jasmine-highlands-south", 2,
        241, "Twilight Highlands", "2. Alternative 1 - Southern Dunwald / Crucible circuit",
        {
            39005300, 45005600, 51005900, 57006100, 63006500, 68007000, 73007700, 70008400,
            63008600, 55008100, 49007600, 44007000, 39006400, 35005900,
        },
        {
            "Cover Crucible of Carnage and Dunwald outskirts when the more famous northern route has competition.",
            "Avoid the heavily wooded Obsidian Forest center if you want primarily Twilight Jasmine; that region also carries Cinderbloom.",
            "Treat the very southeastern leg as a scout section; shorten it if the extra distance fails to produce nodes.",
        },
        {
            "https://www.wow-professions.com/farming/twilight-jasmine-farming",
            "https://www.almarsguides.com/wow/farming/Cataclysm/HerbLocations/TwilightHighlands/",
        }
    ),
    HerbRoute(
        "cataclysm-twilight-jasmine-highlands-west", 3,
        241, "Twilight Highlands", "3. Alternative 2 - West Thundermar / Victor Point",
        {
            29003100, 35002800, 42002900, 47003500, 45004300, 42005100, 38005700, 33006000,
            29005500, 26004700, 27003800,
        },
        {
            "This shorter western interior circuit can be easier to repeat than a full-zone sweep.",
            "Scout the lower grassy areas toward Victor’s Point and Thundermar, rather than flying over exposed mountain ridges.",
            "Expected to be a lower-density fallback: compare gathered herbs per minute before replacing the main loop.",
        },
        {
            "https://www.warcrafttavern.com/cataclysm/guides/twilight-jasmine-farming-guide/",
            "https://www.almarsguides.com/wow/farming/Cataclysm/HerbLocations/TwilightHighlands/",
        }
    ),
}

local WHIPTAIL_ROUTES = {
    HerbRoute(
        "cataclysm-whiptail-uldum-riverbanks", 1,
        249, "Uldum", "1. Main - Uldum Virnaal river double bank",
        {
            62002000, 64002700, 61003400, 57004200, 54004900, 56005600, 60006400, 64007100,
            68007600, 66008300, 60008400, 58007700, 59007000, 56006400, 53005500, 51004700,
            53003900, 57003100,
        },
        {
            "Follow the natural riverbanks from Ramkahen toward Lost City and the delta; inspect both sides for plant nodes.",
            "Check crocolisk-populated wet ground and islands at the southern delta, but avoid stone channels with no natural shoreline.",
            "Retail crucial: talk to Zidormi near Ramkahen if the patch-8.3 Black Empire version of Uldum is active; switch to the older phase.",
        },
        {
            "https://www.wow-professions.com/farming/whiptail-farming",
            "https://www.wowhead.com/cata/guide/professions/whiptail-herb-farming-guide",
        }
    ),
    HerbRoute(
        "cataclysm-whiptail-uldum-cradle", 2,
        249, "Uldum", "2. Alternative 1 - Uldum Cradle dry-stream pockets",
        {
            37006400, 41006300, 45006500, 48006900, 49007400, 47007800, 43008100, 39007800,
            37007300, 35006800,
        },
        {
            "An obscure short route at Cradle of the Ancients, west of the main river; target the dry streambed.",
            "Quest phase matters: reports say nodes disappear after the oasis becomes lush; do not use this route if your character has completed that phase.",
            "Too few spawn positions for continuous farming; combine it with a river circuit or check it opportunistically.",
        },
        {
            "https://www.wowhead.com/cata/object=202752/whiptail",
            "https://www.warcrafttavern.com/cataclysm/guides/whiptail-farming/",
        }
    ),
    HerbRoute(
        "cataclysm-whiptail-tol-barad-marsh", 3,
        244, "Tol Barad", "3. Alternative 2 - Tol Barad western crocolisk marsh",
        {
            25004300, 28003900, 33003700, 37004100, 39004700, 38005300, 35005900, 29006300,
            24006000, 22005300,
        },
        {
            "Only patrol the small crocolisk swamp west of Baradin Hold; it is a compact check, not a comparable Uldum farm.",
            "Historical node surveys describe six compact spawn clusters, but only a few nodes may be active simultaneously.",
            "No flying in Tol Barad; combine this stop with dailies instead of running the same small circuit indefinitely.",
        },
        {
            "https://www.mmo-champion.com/threads/threads/threads/threads/threads/818506-Tol-Barad-Mining-and-Herbalism-Guide",
            "https://www.warcrafttavern.com/cataclysm/guides/whiptail-farming/",
        }
    ),
}

local function RegisterHerb(itemID, itemName, routes, summary)
    Register({
        itemID = itemID,
        itemName = itemName,
        expansion = "cataclysm",
        professions = { "herbalism", "alchemy", "inscription" },
        category = "Herb",
        isRoute = true,
        sourceUrls = { ItemUrl(itemID) },
        summary = summary,
        spots = routes,
    })
end

RegisterHerb(52983, "Cinderbloom", CINDERBLOOM_ROUTES, "Starter Cataclysm herb best farmed in Mount Hyjal, with Deepholm as a strong secondary route.")
RegisterHerb(52984, "Stormvine", STORMVINE_ROUTES, "Cataclysm herb farmed in Mount Hyjal and Vashj'ir, with Shimmering Expanse as the strongest mixed route.")
RegisterHerb(52985, "Azshara's Veil", AZSHARAS_VEIL_ROUTES, "Watery Cataclysm herb best farmed in Shimmering Expanse or Abyssal Depths.")
RegisterHerb(52986, "Heartblossom", HEARTBLOSSOM_ROUTES, "Deepholm-only Cataclysm herb with Volatile Life side value.")
RegisterHerb(52987, "Twilight Jasmine", TWILIGHT_JASMINE_ROUTES, "Twilight Highlands herb found in green valley routes away from mountain edges.")
RegisterHerb(52988, "Whiptail", WHIPTAIL_ROUTES, "Uldum riverbank herb with excellent Volatile Life side value.")

-- Existing side-material routes retained for Volatile Life.
local DEEPHOLM_HEARTBLOSSOM_ROUTE = {
    id = "cataclysm-heartblossom-deepholm-outer-loop",
    source = "Wowhead Heartblossom guide, wow-professions herb guide, and Cataclysm herbalism route notes",
    sourceUrls = {
        "https://www.wowhead.com/object=202750/heartblossom",
        "https://www.wow-professions.com/farming/heartblossom-farming",
        "https://goddessmomo.wordpress.com/2011/07/30/cataclysm-herbalism-farming-routes/",
    },
    mapName = "Deepholm",
    location = "Needle Rock, Pale Roost, Temple of Earth, and Silvermarsh loop",
    routeType = "herbalism-loop",
    density = "High",
    dropDifficulty = "Good focused Heartblossom route with Volatile Life side value.",
    tips = {
        "Route through Needle Rock Chasm, Pale Roost, Temple of Earth, Deathwing's Fall, and Silvermarsh.",
        "Skip the dotted/low-herb stretch if another player is not forcing you into a wider loop.",
    },
    coords = {
        C(0.201, 0.548, "Western Heartblossom pin"),
        C(0.202, 0.570, "Western ridge Heartblossom pin"),
        C(0.216, 0.563, "Needle Rock west Heartblossom pin"),
        C(0.221, 0.485, "Temple west Heartblossom pin"),
        C(0.490, 0.190, "Needle Rock Chasm"),
        C(0.612, 0.276, "Pale Roost"),
        C(0.720, 0.430, "Eastern Deepholm sweep"),
        C(0.630, 0.610, "Deathwing's Fall side"),
        C(0.466, 0.674, "Silvermarsh return"),
        C(0.336, 0.520, "Western Deepholm return"),
        C(0.400, 0.334, "Temple of Earth side"),
    },
    confidence = "high",
}

local WHIPTAIL_ROUTE = {
    id = "cataclysm-whiptail-uldum-lost-city-river-loop",
    source = "wow-professions Whiptail/Volatile Life guides, Warcraft Tavern Volatile Life guide, and Cataclysm herbalism route notes",
    sourceUrls = {
        "https://www.wow-professions.com/farming/whiptail-farming",
        "https://www.wow-professions.com/farming/volatile-life-farming",
        "https://www.warcrafttavern.com/cataclysm/guides/volatile-life-farming-guide/",
        "https://goddessmomo.wordpress.com/2011/07/30/cataclysm-herbalism-farming-routes/",
    },
    mapName = "Uldum",
    location = "Lost City of the Tol'vir riverbanks and Uldum waterline loop",
    routeType = "herbalism-loop",
    density = "High",
    dropDifficulty = "Excellent Whiptail and Volatile Life route, but Uldum phasing may require Zidormi.",
    tips = {
        "Follow the riverbanks around the Lost City of the Tol'vir and nearby waterlines.",
        "Talk to Zidormi at Ramkahen if you are in the newer Uldum phase.",
        "This is the preferred Volatile Life route when Whiptail prices are also good.",
    },
    coords = {
        C(0.418, 0.724, "Southern river Whiptail pin"),
        C(0.425, 0.705, "Southwest river Whiptail pin"),
        C(0.450, 0.674, "Lost City river Whiptail pin"),
        C(0.459, 0.290, "Northern river Whiptail pin"),
        C(0.540, 0.360, "Northern riverbank"),
        C(0.590, 0.440, "Lost City north bank"),
        C(0.606, 0.548, "Lost City east bank"),
        C(0.568, 0.642, "Southern riverbank"),
        C(0.492, 0.704, "Southwest riverbank"),
        C(0.420, 0.612, "Western riverbank"),
        C(0.388, 0.474, "Northwest return"),
    },
    confidence = "high",
}

Register({
    itemID = 52329,
    itemName = "Volatile Life",
    expansion = "cataclysm",
    professions = { "herbalism", "alchemy" },
    category = "Volatile",
    sourceUrls = {
        ItemUrl(52329),
        "https://www.wowhead.com/object=202752/whiptail",
        "https://www.wow-professions.com/farming/volatile-life-farming",
    },
    summary = "Volatile Life is a Cataclysm herbalism side material. Whiptail in Uldum is the most practical target route.",
    spots = { WHIPTAIL_ROUTE, DEEPHOLM_HEARTBLOSSOM_ROUTE },
})
