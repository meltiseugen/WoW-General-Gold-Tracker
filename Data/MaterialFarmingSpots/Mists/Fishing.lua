local _, NS = ...
local Register = NS.RegisterMaterialFarmingSpot

local function C(x, y, label)
    return { x = x, y = y, label = label }
end

local function ItemUrl(itemID)
    return "https://www.wowhead.com/item=" .. tostring(itemID)
end

local FISHING_OVERVIEW = "https://www.wowhead.com/news/mists-of-pandaria-fishing-and-the-anglers-guide-203634"

local JADE_LUNGFISH_ROUTE = {
    id = "mists-fishing-jade-forest-lungfish-water-loop",
    source = "Retail Wowhead Jade Lungfish comments and MoP fishing overview",
    sourceUrls = {
        "https://www.wowhead.com/item=74856/jade-lungfish",
        FISHING_OVERVIEW,
    },
    mapName = "The Jade Forest",
    location = "Serenity Falls, Honeydew Farm, and Slicky Stream Jade Lungfish pools",
    routeType = "fishing-pool-loop",
    density = "Medium to high",
    dropDifficulty = "Fish pool availability varies, but comments call out compact repeatable Jade Forest water pockets.",
    tips = {
        "Check Serenity Falls first, then sweep Slicky Stream and Honeydew Farm if pools are thin.",
        "Jade Lungfish schools are the target; open water works but is slower.",
        "Fish of the Day at Woods of the Lost makes Jade Lungfish much faster when active.",
    },
    coords = {
        C(0.2566, 0.3166, "Serenity Falls pool cluster"),
        C(0.2776, 0.1110, "Honeydew Farm water"),
        C(0.5100, 0.2200, "Slicky Stream pool run"),
        C(0.4400, 0.2400, "Woods of the Lost event water"),
    },
    confidence = "high",
}

local KRASARANG_PADDLEFISH_ROUTE = {
    id = "mists-fishing-krasarang-falls-dojani-paddlefish",
    source = "Retail Wowhead Krasarang Paddlefish comments and MoP fishing overview",
    sourceUrls = {
        "https://www.wowhead.com/item=74865/krasarang-paddlefish",
        FISHING_OVERVIEW,
    },
    mapName = "Krasarang Wilds",
    location = "Krasari Falls and Dojani River pool route",
    routeType = "fishing-pool-loop",
    density = "High when Fish of the Day is active",
    dropDifficulty = "Best targeted Paddlefish route; Emperor Salmon and Golden Carp are common side catches.",
    tips = {
        "Use the large panicked pool at Krasari Falls when active; it has been reported around 34.64,34.24.",
        "Follow the Dojani River north of Anglers Wharf when normal schools are your target.",
        "Paddlefish and Emperor Salmon pools can share spawn points, so clear either school while routing.",
    },
    coords = {
        C(0.3464, 0.3424, "Krasari Falls panicked pool"),
        C(0.3500, 0.3200, "Krasari Falls river bend"),
        C(0.4100, 0.3600, "Dojani River west"),
        C(0.5000, 0.3900, "Dojani River middle"),
        C(0.5850, 0.4150, "Dojani River toward Anglers Wharf"),
    },
    confidence = "high",
}

local EMPEROR_SALMON_ROUTE = {
    id = "mists-fishing-valley-stormstout-yan-zhe-salmon",
    source = "Retail Wowhead fish comments and MoP fishing overview",
    sourceUrls = {
        "https://www.wowhead.com/item=74859/emperor-salmon",
        "https://www.wowhead.com/item=74865/krasarang-paddlefish",
        FISHING_OVERVIEW,
    },
    mapName = "Valley of the Four Winds",
    location = "Stormstout Brewery and Yan-Zhe River Emperor Salmon pools",
    routeType = "fishing-pool-loop",
    density = "Medium to high",
    dropDifficulty = "Reliable waterline route with Golden Carp and Paddlefish side catches.",
    tips = {
        "Fish Stormstout Brewery event pools when Fish of the Day is active.",
        "Outside the event, work the Yan-Zhe River and Cattail Lake water around Halfhill.",
        "Use this route together with nearby turtle or Silkweed loops.",
    },
    coords = {
        C(0.3607, 0.6914, "Stormstout Brewery water"),
        C(0.7133, 0.5353, "Yan-Zhe River island"),
        C(0.7420, 0.5120, "Yan-Zhe River north bank"),
        C(0.4160, 0.3000, "Cattail Lake dock"),
    },
    confidence = "medium",
}

local REDBELLY_ROUTE = {
    id = "mists-fishing-townlong-fields-niuzao-redbelly",
    source = "Retail Wowhead Redbelly Mandarin page and MoP fishing overview",
    sourceUrls = {
        "https://www.wowhead.com/item=74860/redbelly-mandarin",
        FISHING_OVERVIEW,
    },
    mapName = "Townlong Steppes",
    location = "Fields of Niuzao pond and Niuzao Temple waterways",
    routeType = "fishing-pool-loop",
    density = "Localized",
    dropDifficulty = "Small-water route; best when the Crowded Redbelly Mandarin daily event is up.",
    tips = {
        "Prioritize the compact Fields of Niuzao pond while Fish of the Day is active.",
        "Clear nearby normal pools if the crowded event pool is down.",
    },
    coords = {
        C(0.388, 0.626, "Niuzao Temple south pond"),
        C(0.422, 0.640, "Fields of Niuzao water"),
        C(0.458, 0.602, "Niuzao east water check"),
    },
    confidence = "medium",
}

local JEWEL_DANIO_ROUTE = {
    id = "mists-fishing-vale-mad-qao-pao-jewel-danio",
    source = "Retail Wowhead Jewel Danio page and MoP fishing overview",
    sourceUrls = {
        "https://www.wowhead.com/item=74863/jewel-danio",
        FISHING_OVERVIEW,
    },
    mapName = "Vale of Eternal Blossoms",
    location = "Mad Qao Pao Jewel Danio event water and nearby Vale pools",
    routeType = "fishing-pool-loop",
    density = "Event-based",
    dropDifficulty = "Patch-sensitive: the special Fish of the Day spot was removed in original patch 5.4, so use normal Vale and Timeless Isle pools when unavailable.",
    tips = {
        "Check the Mad Qao Pao event water first in timelines where it exists.",
        "Use Timeless Isle Jewel Danio pools as a retail-era fallback if the Vale event is not present.",
    },
    coords = {
        C(0.674, 0.430, "Mad Qao Pao event water"),
        C(0.706, 0.464, "East Vale pool check"),
        C(0.382, 0.744, "Timeless Isle fallback pool"),
    },
    confidence = "medium",
}

local REEF_OCTOPUS_ROUTE = {
    id = "mists-fishing-jade-forest-sri-la-reef-octopus",
    source = "Retail Wowhead Reef Octopus page and MoP fishing overview",
    sourceUrls = {
        "https://www.wowhead.com/item=74864/reef-octopus",
        FISHING_OVERVIEW,
        "https://www.fishinginpandaria.com/",
    },
    mapName = "The Jade Forest",
    location = "Sri-La Village docks and eastern coastal reef pools",
    routeType = "coastal-fishing-pool-loop",
    density = "Medium to high",
    dropDifficulty = "Good coastal loop; Reef Octopus and Giant Mantis Shrimp pools can replace each other in similar waters.",
    tips = {
        "Sweep the Sri-La dock water first, then follow the nearby coast.",
        "Fish other coastal pools on the route to force new school spawns.",
    },
    coords = {
        C(0.556, 0.832, "Sri-La Village dock"),
        C(0.584, 0.846, "Eastern reef pool"),
        C(0.612, 0.826, "North reef return"),
        C(0.536, 0.804, "South reef return"),
    },
    confidence = "medium",
}

local MANTIS_SHRIMP_ROUTE = {
    id = "mists-fishing-dread-wastes-gokklok-giant-mantis-shrimp",
    source = "Retail Wowhead Giant Mantis Shrimp page, MoP fishing overview, and Fishing in Pandaria route notes",
    sourceUrls = {
        "https://www.wowhead.com/item=74857/giant-mantis-shrimp",
        FISHING_OVERVIEW,
        "https://www.fishinginpandaria.com/",
    },
    mapName = "Dread Wastes",
    location = "Gokk'lok Shallows and Lake of Stars shrimp/spinefish water",
    routeType = "coastal-fishing-pool-loop",
    density = "Medium",
    dropDifficulty = "Coastal schools are best; Lake of Stars is included because Spinefish and cooking side catches overlap.",
    tips = {
        "Check Gokk'lok Shallows when Fish of the Day is active.",
        "Clear Reef Octopus or other coastal pools if Mantis Shrimp schools are not up.",
    },
    coords = {
        C(0.272, 0.718, "Gokk'lok Shallows west"),
        C(0.314, 0.736, "Gokk'lok Shallows middle"),
        C(0.356, 0.716, "Gokk'lok Shallows east"),
        C(0.650, 0.590, "Lake of Stars side water"),
    },
    confidence = "medium",
}

local TIGER_GOURAMI_ROUTE = {
    id = "mists-fishing-kunlai-binan-tiger-gourami",
    source = "Retail Wowhead Tiger Gourami page and MoP fishing overview",
    sourceUrls = {
        "https://www.wowhead.com/item=74861/tiger-gourami",
        FISHING_OVERVIEW,
    },
    mapName = "Kun-Lai Summit",
    location = "Binan Village Coast, Inkgill Mere, and northern inland waters",
    routeType = "fishing-pool-loop",
    density = "Medium",
    dropDifficulty = "Use Kun-Lai inland water; special daily pools shift the target around Binan/Peak of Serenity.",
    tips = {
        "Check Binan Village Coast and Inkgill Mere first because multiple fish pages call out those waters.",
        "Peak of Serenity is the Fish of the Day event spot for Tiger Gourami Slush.",
    },
    coords = {
        C(0.720, 0.904, "Binan Village coast"),
        C(0.704, 0.880, "Binan coast return"),
        C(0.430, 0.840, "Firebough Nook and Inkgill Mere"),
        C(0.512, 0.420, "Peak of Serenity event water"),
    },
    confidence = "medium",
}

local SPINEFISH_ROUTE = {
    id = "mists-fishing-kunlai-inkgill-spinefish",
    source = "Retail Wowhead Spinefish comments and MoP fishing overview",
    sourceUrls = {
        "https://www.wowhead.com/item=83064/spinefish",
        FISHING_OVERVIEW,
    },
    mapName = "Kun-Lai Summit",
    location = "Inkgill Mere, Firebough Nook, and Lake of Stars backup",
    routeType = "fishing-pool-loop",
    density = "Medium to high",
    dropDifficulty = "Best in sha-touched inland waters; important for alchemy because it creates Desecrated Oil.",
    tips = {
        "Loop Firebough Nook and Inkgill Mere first; both are repeatedly called out in comments.",
        "Lake of Stars is a compact backup when Kun-Lai pools are crowded.",
    },
    coords = {
        C(0.430, 0.840, "Firebough Nook comment pin"),
        C(0.456, 0.826, "Inkgill Mere west"),
        C(0.492, 0.842, "Inkgill Mere island edge"),
        C(0.650, 0.590, "Lake of Stars backup"),
    },
    confidence = "high",
}

local GOLDEN_CARP_ROUTE = {
    id = "mists-fishing-valley-cattail-lake-golden-carp",
    source = "Retail Wowhead fish comments and MoP fishing overview",
    sourceUrls = {
        "https://www.wowhead.com/item=74866/golden-carp",
        "https://www.wowhead.com/item=74865/krasarang-paddlefish",
        FISHING_OVERVIEW,
    },
    mapName = "Valley of the Four Winds",
    location = "Cattail Lake and Yan-Zhe River open-water catches",
    routeType = "open-water-fishing",
    density = "Common side catch",
    dropDifficulty = "Golden Carp is the common Pandaria open-water catch; target it where other valuable pools overlap.",
    tips = {
        "Fish open water at Cattail Lake if you need bulk Golden Carp near Halfhill.",
        "Clear nearby Emperor Salmon or Paddlefish pools when they are present because those routes still produce Golden Carp.",
    },
    coords = {
        C(0.416, 0.300, "Cattail Lake dock"),
        C(0.7133, 0.5353, "Yan-Zhe River island"),
        C(0.3464, 0.3424, "Krasari Falls side catch"),
    },
    confidence = "high",
}

local function RegisterFish(itemID, itemName, spots, summary, professions)
    Register({
        itemID = itemID,
        itemName = itemName,
        expansion = "mists",
        professions = professions or { "fishing", "cooking" },
        category = "Fish",
        sourceUrls = { ItemUrl(itemID), FISHING_OVERVIEW },
        summary = summary,
        spots = spots,
    })
end

RegisterFish(74856, "Jade Lungfish", { JADE_LUNGFISH_ROUTE }, "Jade Forest freshwater fish from schools and Fish of the Day pools.")
RegisterFish(74857, "Giant Mantis Shrimp", { MANTIS_SHRIMP_ROUTE }, "Coastal Pandaria fish targeted around Gokk'lok Shallows and Dread Wastes waters.")
RegisterFish(74859, "Emperor Salmon", { EMPEROR_SALMON_ROUTE, KRASARANG_PADDLEFISH_ROUTE }, "Freshwater fish from Valley/Krasarang rivers, often paired with Paddlefish routes.")
RegisterFish(74860, "Redbelly Mandarin", { REDBELLY_ROUTE }, "Townlong freshwater fish best targeted during Fields of Niuzao Fish of the Day.")
RegisterFish(74861, "Tiger Gourami", { TIGER_GOURAMI_ROUTE }, "Kun-Lai inland fish from northern waters and Tiger Gourami schools.")
RegisterFish(74863, "Jewel Danio", { JEWEL_DANIO_ROUTE }, "Vale and Timeless Isle fish with patch-sensitive event availability.")
RegisterFish(74864, "Reef Octopus", { REEF_OCTOPUS_ROUTE, MANTIS_SHRIMP_ROUTE }, "Coastal Pandaria fish from Sri-La and similar reef/coastal school spawns.")
RegisterFish(74865, "Krasarang Paddlefish", { KRASARANG_PADDLEFISH_ROUTE, EMPEROR_SALMON_ROUTE }, "Krasarang and Valley fish from river schools, with a strong Krasari Falls event target.")
RegisterFish(74866, "Golden Carp", { GOLDEN_CARP_ROUTE }, "Common Pandaria fish from open water, best gathered alongside valuable pool routes.")
RegisterFish(83064, "Spinefish", { SPINEFISH_ROUTE, MANTIS_SHRIMP_ROUTE }, "Sha-touched fish used for alchemy Desecrated Oil, strongest in Kun-Lai and Dread Wastes inland waters.", { "fishing", "alchemy" })
