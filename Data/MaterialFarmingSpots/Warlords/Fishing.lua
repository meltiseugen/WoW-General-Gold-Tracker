local _, NS = ...
local Register = NS.RegisterMaterialFarmingSpot

local function C(x, y, label)
    return { x = x, y = y, label = label }
end

local function ItemUrl(itemID)
    return "https://www.wowhead.com/item=" .. tostring(itemID)
end

local FISHING_GUIDE = "https://www.wowhead.com/guide/professions/wod/fishing-overview"
local DRAENOR_ANGLER = "https://www.wowhead.com/achievement=9462/draenor-angler"

local CRESCENT_SABERFISH_ROUTE = {
    id = "warlords-crescent-saberfish-shadowmoon-coast-open-water",
    source = "Retail Wowhead WoD fishing overview and Warcraft Wiki Crescent Saberfish page",
    sourceUrls = {
        FISHING_GUIDE,
        "https://warcraft.wiki.gg/wiki/Crescent_Saberfish",
    },
    mapName = "Shadowmoon Valley (Draenor)",
    location = "Open coastal water around Shadowmoon Valley and Lunarfall approaches",
    routeType = "open-water-fishing",
    density = "Broad open-water catch",
    dropDifficulty = "Easy but low-value; Crescent Saberfish is the fallback fish across Draenor waters.",
    tips = {
        "Fish open Draenor water when you want Crescent Saberfish rather than a zone-specific bait target.",
        "Avoid activating zone-specific bait if Crescent Saberfish Flesh is the goal.",
    },
    coords = {
        C(0.3560, 0.7440, "Southwest Shadowmoon coast"),
        C(0.4700, 0.7940, "Lunarfall coast"),
        C(0.5840, 0.7380, "Karabor coast"),
    },
    confidence = "medium",
}

local JAWLESS_SKULKER_ROUTE = {
    id = "warlords-jawless-skulker-gorgrond-pool-cluster",
    source = "Retail Wowhead Draenor Angler and Jawless Skulker Angler comment coordinate clusters",
    sourceUrls = {
        ItemUrl(109138),
        FISHING_GUIDE,
        DRAENOR_ANGLER,
        "https://www.wowhead.com/achievement=9460/jawless-skulker-angler",
    },
    mapName = "Gorgrond",
    location = "Gorgrond inland water and The Fertile Ground pool cluster",
    routeType = "pool-fishing-loop",
    density = "High when pools are up",
    dropDifficulty = "Pool spawns move, so fly the cluster instead of camping a single pin.",
    tips = {
        "Use Jawless Skulker Bait in Gorgrond inland water when targeting this flesh.",
        "The route samples repeated Wowhead comment pins around The Fertile Ground and southern pools.",
    },
    coords = {
        C(0.4034, 0.7656, "The Fertile Ground pool"),
        C(0.4780, 0.8760, "Southern pool"),
        C(0.4260, 0.8010, "Southwest pool"),
        C(0.5760, 0.5540, "Central east pool"),
        C(0.6220, 0.5350, "Eastern pool"),
        C(0.5780, 0.4360, "Northeast pool"),
        C(0.3960, 0.5200, "Western pool"),
        C(0.4020, 0.6020, "West central pool"),
        C(0.5170, 0.6090, "Central pool"),
    },
    confidence = "high",
}

local FAT_SLEEPER_ROUTE = {
    id = "warlords-fat-sleeper-nagrand-inland-pool-route",
    source = "Retail Wowhead Draenor Angler comments and WoD fishing overview",
    sourceUrls = {
        ItemUrl(109139),
        FISHING_GUIDE,
        DRAENOR_ANGLER,
    },
    mapName = "Nagrand (Draenor)",
    location = "Nagrand inland lakes and river bends near Wor'var and Ancestral Grounds",
    routeType = "pool-fishing-loop",
    density = "Medium to high",
    dropDifficulty = "Easy fishing route with some nearby beast packs.",
    tips = {
        "Use Fat Sleeper Bait in Nagrand inland water.",
        "Start near the Wor'var pools, then sweep the northern and western inland water edges.",
    },
    coords = {
        C(0.8453, 0.4367, "Wor'var pool"),
        C(0.7400, 0.2200, "Northern pool route start"),
        C(0.5140, 0.3860, "Ancestral Grounds water"),
        C(0.4140, 0.5280, "Western river bend"),
    },
    confidence = "high",
}

local BLIND_LAKE_STURGEON_ROUTE = {
    id = "warlords-blind-lake-sturgeon-shadowmoon-inland-route",
    source = "Retail Wowhead Draenor Angler comments, Blind Lake Sturgeon pages, and WoD fishing overview",
    sourceUrls = {
        ItemUrl(109140),
        FISHING_GUIDE,
        DRAENOR_ANGLER,
        "https://www.wowhead.com/item=112623/blind-lake-sturgeon-egg",
    },
    mapName = "Shadowmoon Valley (Draenor)",
    location = "Shadowmoon inland lake and grove pool route",
    routeType = "pool-fishing-loop",
    density = "Medium to high",
    dropDifficulty = "Easy route; pool visibility is the main limiter.",
    tips = {
        "Use Blind Lake Sturgeon Bait in Shadowmoon inland water.",
        "Sweep Arbor Glen and Gloomshade Grove lakes instead of coastal water.",
    },
    coords = {
        C(0.4839, 0.3400, "Arbor Glen pool"),
        C(0.3600, 0.2500, "Gloomshade Grove lake"),
        C(0.5750, 0.6440, "Central Shadowmoon inland water"),
    },
    confidence = "high",
}

local FIRE_AMMONITE_ROUTE = {
    id = "warlords-fire-ammonite-frostfire-lava-pool-route",
    source = "Retail Wowhead Draenor Angler comments and WoD fishing overview",
    sourceUrls = {
        ItemUrl(109141),
        FISHING_GUIDE,
        DRAENOR_ANGLER,
    },
    mapName = "Frostfire Ridge",
    location = "Frostfire Ridge lava pools around Frostwall Approach",
    routeType = "pool-fishing-loop",
    density = "Medium",
    dropDifficulty = "Lava pools are clustered but terrain makes movement slower.",
    tips = {
        "Use Fire Ammonite Bait in Frostfire lava pools.",
        "Stay around Frostwall Approach lava; normal inland water favors other fish.",
    },
    coords = {
        C(0.5110, 0.5921, "Frostwall Approach lava pool"),
        C(0.5100, 0.6000, "Frostwall lava edge"),
        C(0.5360, 0.5580, "East lava pool"),
        C(0.4770, 0.6160, "West lava pool"),
    },
    confidence = "high",
}

local SEA_SCORPION_ROUTE = {
    id = "warlords-sea-scorpion-draenor-coastal-route",
    source = "Retail Wowhead Draenor Angler comments, Sea Scorpion item comments, and WoD fishing overview",
    sourceUrls = {
        ItemUrl(109142),
        "https://www.wowhead.com/item=111665/sea-scorpion",
        FISHING_GUIDE,
        DRAENOR_ANGLER,
    },
    mapName = "Nagrand (Draenor)",
    location = "Draenor coastal water route, anchored at Zangar Shore and Frostfire southwest cliffs",
    routeType = "coastal-fishing-loop",
    density = "Medium to high",
    dropDifficulty = "Coastal catch; flying between coastlines is faster than waiting on one empty stretch.",
    tips = {
        "Use Sea Scorpion Bait in Draenor coastal water.",
        "If Nagrand coast is empty, swap to the Frostfire southwest cliffs or Spires east coast.",
    },
    coords = {
        C(0.3533, 0.4569, "Nagrand Zangar Shore islands"),
        C(0.5610, 0.7499, "Frostfire southwest cliffs"),
        C(0.7500, 0.5000, "Spires east coast"),
    },
    confidence = "high",
}

local ABYSSAL_GULPER_EEL_ROUTE = {
    id = "warlords-abyssal-gulper-eel-spires-pool-route",
    source = "Retail Wowhead Abyssal Gulper Eel comments, Draenor Angler comments, and WoD fishing overview",
    sourceUrls = {
        ItemUrl(109143),
        FISHING_GUIDE,
        DRAENOR_ANGLER,
    },
    mapName = "Spires of Arak",
    location = "Spires inland water around Crows Crook and The Undergrowth",
    routeType = "pool-fishing-loop",
    density = "High when pools are up",
    dropDifficulty = "Good compact route; watch for terrain breaks around the Undergrowth.",
    tips = {
        "Use Abyssal Gulper Eel Bait in Spires inland water.",
        "Circle the pools southwest of Crows Crook and the Undergrowth pins from Wowhead comments.",
    },
    coords = {
        C(0.5167, 0.3291, "The Undergrowth pool"),
        C(0.5100, 0.3000, "Crows Crook southwest pool"),
        C(0.5500, 0.3300, "Crows Crook east pool"),
        C(0.6427, 0.2187, "Northern inland pool"),
    },
    confidence = "high",
}

local BLACKWATER_WHIPTAIL_ROUTE = {
    id = "warlords-blackwater-whiptail-talador-inland-route",
    source = "Retail Wowhead Draenor Angler comments and WoD fishing overview",
    sourceUrls = {
        ItemUrl(109144),
        FISHING_GUIDE,
        DRAENOR_ANGLER,
    },
    mapName = "Talador",
    location = "Talador inland water route around Anchorite's Sojourn and southern river laps",
    routeType = "pool-fishing-loop",
    density = "High when pools are up",
    dropDifficulty = "Easy route, but some river sections pass close to hostile camps.",
    tips = {
        "Use Blackwater Whiptail Bait in Talador inland water.",
        "Sweep Anchorite's Sojourn first, then fly the southern river lap if pools are sparse.",
    },
    coords = {
        C(0.7893, 0.5476, "Anchorite's Sojourn pool"),
        C(0.7100, 0.8400, "Southern raft lap"),
        C(0.5800, 0.7700, "Southwest river lap"),
        C(0.3900, 0.5200, "Western river pool"),
    },
    confidence = "high",
}

local function RegisterFish(itemID, itemName, spots, summary)
    Register({
        itemID = itemID,
        itemName = itemName,
        expansion = "warlords",
        professions = { "fishing", "cooking" },
        category = "Fish",
        sourceUrls = {
            ItemUrl(itemID),
            FISHING_GUIDE,
            DRAENOR_ANGLER,
        },
        summary = summary,
        spots = spots,
    })
end

RegisterFish(109137, "Crescent Saberfish Flesh", { CRESCENT_SABERFISH_ROUTE }, "Common Draenor fish flesh from Crescent Saberfish, the broad open-water catch across Draenor.")
RegisterFish(109138, "Jawless Skulker Flesh", { JAWLESS_SKULKER_ROUTE }, "Gorgrond inland fish flesh; use Jawless Skulker Bait and fly repeated pool clusters.")
RegisterFish(109139, "Fat Sleeper Flesh", { FAT_SLEEPER_ROUTE }, "Nagrand inland fish flesh; use Fat Sleeper Bait around Wor'var and northern/western inland water.")
RegisterFish(109140, "Blind Lake Sturgeon Flesh", { BLIND_LAKE_STURGEON_ROUTE }, "Shadowmoon Valley inland fish flesh; use Blind Lake Sturgeon Bait in lake and grove pools.")
RegisterFish(109141, "Fire Ammonite Tentacle", { FIRE_AMMONITE_ROUTE }, "Frostfire Ridge lava-pool fish flesh; use Fire Ammonite Bait around Frostwall Approach lava.")
RegisterFish(109142, "Sea Scorpion Segment", { SEA_SCORPION_ROUTE }, "Draenor coastal fish material; use Sea Scorpion Bait and rotate between confirmed coastline pins.")
RegisterFish(109143, "Abyssal Gulper Eel Flesh", { ABYSSAL_GULPER_EEL_ROUTE }, "Spires of Arak inland fish flesh; use Abyssal Gulper Eel Bait near Crows Crook and The Undergrowth.")
RegisterFish(109144, "Blackwater Whiptail Flesh", { BLACKWATER_WHIPTAIL_ROUTE }, "Talador inland fish flesh; use Blackwater Whiptail Bait around Anchorite's Sojourn and river laps.")
