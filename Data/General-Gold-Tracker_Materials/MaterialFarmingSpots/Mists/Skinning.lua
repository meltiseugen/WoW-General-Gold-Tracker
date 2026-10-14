local _, NS = ...
local Register = NS.RegisterMaterialFarmingSpot

local function C(x, y, label)
    return { x = x, y = y, label = label }
end

local function ItemUrl(itemID)
    return "https://www.wowhead.com/item=" .. tostring(itemID)
end

local TOWNLONG_MUSHAN_ROUTE = {
    id = "mists-leather-townlong-kri-vess-longshadow-mushan",
    source = "Wowhead Mist-Touched Leather guide and wow-professions leather guide",
    sourceUrls = {
        "https://www.wowhead.com/item=72120/mist-touched-leather",
        "https://www.wow-professions.com/farming/mist-touched-leather-farming",
        "https://www.wowhead.com/npc=59197/longshadow-mushan",
    },
    mapName = "Townlong Steppes",
    location = "Longshadow Mushans and Bulls northeast of Shado-Pan Garrison around Kri'vess",
    routeType = "skinning-loop",
    density = "High",
    dropDifficulty = "Excellent general leather route with fast respawns; competition can be heavy.",
    tips = {
        "Circle around the Kri'vess tree and dip toward Shado-Pan Garrison to close the loop.",
        "Skin nearby turtles while waiting for mushan respawns.",
        "Use this for Mist-Touched Leather, Sha-Touched Leather, and rare Magnificent Hide attempts.",
    },
    coords = {
        C(0.470, 0.548, "West Kri'vess mushan"),
        C(0.512, 0.518, "North Kri'vess mushan"),
        C(0.552, 0.552, "East Kri'vess mushan"),
        C(0.526, 0.606, "South Kri'vess mushan"),
        C(0.474, 0.622, "Garrison-side return"),
    },
    confidence = "high",
}

local VALLEY_SKYRANGE_ROUTE = {
    id = "mists-leather-valley-four-winds-skyrange-stout-shaghorn",
    source = "Wowhead Mist-Touched Leather guide, wow-professions leather guide, and Stout Shaghorn NPC page",
    sourceUrls = {
        "https://www.wowhead.com/item=72120/mist-touched-leather",
        "https://www.wow-professions.com/farming/mist-touched-leather-farming",
        "https://www.wowhead.com/npc=59153/stout-shaghorn",
    },
    mapName = "Valley of the Four Winds",
    location = "Skyrange ridge Stout Shaghorn packs",
    routeType = "skinning-loop",
    density = "High",
    dropDifficulty = "Very strong if you can reach Skyrange; flying makes the route much easier.",
    tips = {
        "Pull Stout Shaghorn packs across the top ridge and skin as you return.",
        "The packs are yellow mobs, so you can split pulls if your AoE is weak.",
        "This is also a strong Mote of Harmony side route because of mob density.",
    },
    coords = {
        C(0.240, 0.382, "Skyrange west pack"),
        C(0.274, 0.338, "Skyrange northwest pack"),
        C(0.312, 0.366, "Skyrange central pack"),
        C(0.292, 0.424, "Skyrange south pack"),
    },
    confidence = "high",
}

local JADE_WINDWARD_ROUTE = {
    id = "mists-leather-jade-forest-windward-turtles-serpents",
    source = "Player route reports, Wowhead leather guide, and Windward Isle source NPC pages",
    sourceUrls = {
        "https://www.reddit.com/r/wow/comments/1ar13g/leather_workers_where_do_you_farm_exotic_leather/",
        "https://www.wowhead.com/item=72120/mist-touched-leather",
        "https://www.wowhead.com/zone=5785/the-jade-forest",
    },
    mapName = "The Jade Forest",
    location = "Windward Isle turtles, serpents, and Slitherscale Ripper camp",
    routeType = "skinning-loop",
    density = "Medium to high",
    dropDifficulty = "Good mixed leather and scale farm; level 90 mobs can be rough for weak characters.",
    tips = {
        "Use this route when you want a Jade Forest skinning backup or scale side value.",
        "Fold in the Slitherscale Ripper camp around 68,30 when it is not crowded.",
        "Expect more movement than the Townlong mushan loop.",
    },
    coords = {
        C(0.645, 0.240, "Windward Isle north shore"),
        C(0.684, 0.230, "Windward Isle northeast"),
        C(0.704, 0.286, "Slitherscale camp center"),
        C(0.658, 0.312, "Windward Isle south return"),
    },
    confidence = "medium",
}

local DREAD_WASTES_SCORPID_ROUTE = {
    id = "mists-leather-dread-wastes-lake-stars-scorpids-turtles",
    source = "Wowhead Mist-Touched Leather guide and wow-professions leather guide",
    sourceUrls = {
        "https://www.wowhead.com/item=72120/mist-touched-leather",
        "https://www.wowhead.com/item=79101/prismatic-scale",
        "https://www.wow-professions.com/farming/mist-touched-leather-farming",
    },
    mapName = "Dread Wastes",
    location = "Lake of Stars scorpids, turtles, and nearby Forgotten Mire beasts",
    routeType = "skinning-loop",
    density = "Medium",
    dropDifficulty = "Useful fallback with Klaxxi daily overlap; scorpids and turtles can add scale value.",
    tips = {
        "Circle Lake of Stars and avoid widening into sparse mantid sections.",
        "Check Forgotten Mire for roaming basilisks and dreadstalkers if Lake of Stars is crowded.",
        "Use this when you also want Dread Wastes herb or cloth side routes nearby.",
    },
    coords = {
        C(0.574, 0.690, "Lake of Stars south"),
        C(0.664, 0.608, "Lake of Stars east"),
        C(0.618, 0.502, "Forgotten Mire beasts"),
        C(0.530, 0.542, "West lake return"),
    },
    confidence = "medium",
}

local SKINNING_ROUTES = {
    TOWNLONG_MUSHAN_ROUTE,
    VALLEY_SKYRANGE_ROUTE,
    JADE_WINDWARD_ROUTE,
    DREAD_WASTES_SCORPID_ROUTE,
}

local function RegisterLeather(itemID, itemName, category, summary)
    Register({
        itemID = itemID,
        itemName = itemName,
        expansion = "mists",
        professions = { "skinning", "leatherworking" },
        category = category,
        sourceUrls = { ItemUrl(itemID), "https://www.wow-professions.com/farming/mist-touched-leather-farming" },
        summary = summary,
        spots = SKINNING_ROUTES,
    })
end

RegisterLeather(72120, "Mist-Touched Leather", "Leather", "Baseline Pandaria leather from most skinnable beasts; farm high-density beast loops.")
RegisterLeather(72162, "Sha-Touched Leather", "Leather", "Pandaria skinning side leather from beasts; can be converted into Mist-Touched Leather.")
RegisterLeather(72163, "Magnificent Hide", "Hide", "Rare Pandaria hide from skinning beasts, commonly pursued while farming dense leather routes.")
RegisterLeather(79101, "Prismatic Scale", "Scale", "Pandaria scale from skinnable turtles, crocolisks, serpents, and mixed beast farms.")
