local _, NS = ...
local Register = NS.RegisterMaterialFarmingSpot

local function C(x, y, label)
    return { x = x, y = y, label = label }
end

local function ItemUrl(itemID)
    return "https://www.wowhead.com/item=" .. tostring(itemID)
end

local TIRAGARDE_SEAL_ROUTE = {
    id = "bfa-tiragarde-surly-seal-briny-flesh-route",
    source = "Wowhead Briny Flesh comments and BFA cooking route notes",
    sourceUrls = {
        "https://www.wowhead.com/item=152631/briny-flesh",
        "https://en.guiaswow.com/game-guide/cooking-guide-in-battle-for-azeroth-best-farming-routes.html",
    },
    mapName = "Tiragarde Sound",
    location = "Surly Seal packs around Tiragarde Sound 60,46",
    routeType = "beast-meat-farm",
    density = "Medium",
    dropDifficulty = "Good localized Briny Flesh route with nearby humanoid cloth side drops.",
    tips = {
        "A Wowhead comment reports strong Briny Flesh returns from Surly Seals around 60,46.",
        "Use Azerite pools if the nearby world quest is active for a damage and healing boost.",
        "Nearby humanoids and crabs add cloth and extra cooking material side value.",
    },
    coords = {
        C(0.600, 0.460, "Surly Seal pack report"),
        C(0.626, 0.438, "North seal cluster"),
        C(0.646, 0.484, "East shore seals"),
        C(0.592, 0.512, "South seal cluster"),
    },
    confidence = "high",
}

local DRUSTVAR_FALLHAVEN_ROUTE = {
    id = "bfa-drustvar-fallhaven-stringy-loins-route",
    source = "Wowhead Stringy Loins comments and BFA cooking route notes",
    sourceUrls = {
        "https://www.wowhead.com/item=154897/stringy-loins",
        "https://en.guiaswow.com/game-guide/cooking-guide-in-battle-for-azeroth-best-farming-routes.html",
    },
    mapName = "Drustvar",
    location = "North of Fallhaven ensorcelled beasts and bonepickers",
    routeType = "beast-meat-farm",
    density = "Medium to high",
    dropDifficulty = "Good if you can pull birds and ground beasts quickly.",
    tips = {
        "A Wowhead comment recommends the ensorcelled animals north of Fallhaven.",
        "Use ranged pulls for bonepickers so the flying targets do not slow the loop.",
        "This route overlaps with skinning, bone, and leather value.",
    },
    coords = {
        C(0.544, 0.302, "North Fallhaven beasts"),
        C(0.574, 0.256, "Bonepicker ridge"),
        C(0.606, 0.312, "East beast packs"),
        C(0.592, 0.372, "South return"),
        C(0.520, 0.366, "West return"),
    },
    confidence = "medium",
}

local DRUSTVAR_BARROWKNOLL_ROUTE = {
    id = "bfa-drustvar-barrowknoll-meaty-haunch-route",
    source = "Wowhead Meaty Haunch comments and BFA cooking route notes",
    sourceUrls = {
        "https://www.wowhead.com/item=154898/meaty-haunch",
        "https://www.wow-professions.com/farming/meaty-haunch-farming",
    },
    mapName = "Drustvar",
    location = "Northeast of Barrowknoll Cemetery beast route",
    routeType = "beast-meat-farm",
    density = "Medium",
    dropDifficulty = "Good mixed beast route for meat and skinning side value.",
    tips = {
        "Use this when Meaty Haunch is the target but keep skinning enabled for extra value.",
        "Avoid long chases; the best pulls are clustered near the cemetery edge.",
    },
    coords = {
        C(0.584, 0.530, "Barrowknoll north edge"),
        C(0.626, 0.502, "Northeast beast packs"),
        C(0.658, 0.548, "East cemetery route"),
        C(0.616, 0.594, "Southern return"),
        C(0.548, 0.574, "Western return"),
    },
    confidence = "medium",
}

local DRUSTVAR_SAUROLISK_MEAT_ROUTE = {
    id = "bfa-drustvar-shallows-saurolisk-thick-paleo-route",
    source = "wow-professions Thick Paleo Steak guide and Artisans route notes",
    sourceUrls = {
        "https://www.wow-professions.com/farming/thick-paleo-steak-farming",
        "https://artisansofazeroth.com/thick-paleo-steak-farming/",
        "https://www.wowhead.com/item=154899/thick-paleo-steak",
    },
    mapName = "Drustvar",
    location = "Shallows Saurolisk route",
    routeType = "beast-meat-farm",
    density = "Medium",
    dropDifficulty = "Good dinosaur meat route with skinning side value.",
    tips = {
        "Farm Shallows Saurolisks across the marked Drustvar area.",
        "Use Tiragarde or Zuldazar saurolisk routes if Drustvar is crowded.",
    },
    coords = {
        C(0.642, 0.618, "North Shallows Saurolisks"),
        C(0.682, 0.664, "Central saurolisk packs"),
        C(0.718, 0.612, "Eastern saurolisks"),
        C(0.676, 0.566, "Northern return"),
    },
    confidence = "medium",
}

local NAZJATAR_SNAPDRAGON_MEAT_ROUTE = {
    id = "bfa-nazjatar-snapdragon-rubbery-flank-route",
    source = "wow-professions Rubbery Flank and Moist Fillet guides",
    sourceUrls = {
        "https://www.wow-professions.com/farming/rubbery-flank-farming",
        "https://www.wow-professions.com/farming/moist-fillet-farming",
        "https://www.reddit.com/r/woweconomy/comments/fghb4g/best_rubbery_flank_dredged_leather_farm/",
    },
    mapName = "Nazjatar",
    location = "Snapdragons and Deeptide Frenzy around Deepcoil Tunnels and Kal'methir",
    routeType = "aquatic-beast-meat-farm",
    density = "High",
    dropDifficulty = "Strong small-loop route, but some mobs are elite and mixed with naga.",
    tips = {
        "Rubbery Flank comes from Nazjatar snapdragons and aquatic beasts.",
        "Moist Fillet is strong at the Forgotten Tunnel Deeptide Frenzy lake.",
        "Use this with skinning for Dredged Leather and Cragscale side value.",
    },
    coords = {
        C(0.656, 0.220, "Deepcoil Tunnels lake"),
        C(0.593, 0.145, "Shirakess Repository edge"),
        C(0.657, 0.434, "Kal'methir snapdragons"),
        C(0.756, 0.457, "Drowned Market beasts"),
    },
    confidence = "high",
}

local ULDUM_QUESTIONABLE_MEAT_ROUTE = {
    id = "bfa-uldum-questionable-meat-crocolisk-route",
    source = "Retail Wowhead Questionable Meat comments, patch 8.3 cooking material notes, and corrupted Uldum fishing coordinate reports",
    sourceUrls = {
        "https://www.wowhead.com/item=174353/questionable-meat",
        "https://www.wowhead.com/item=174327/malformed-gnasher",
        "https://www.wowhead.com/guide/bfa-fishing",
    },
    mapName = "Uldum",
    location = "Northern Uldum Oasis Crocolisk pulls paired with corrupted-water fishing",
    routeType = "assault-beast-meat-farm",
    density = "Medium during 8.3 assault content",
    dropDifficulty = "Patch 8.3 meat route. Use clustered crocolisk pulls and nearby corrupted fishing spots rather than broad rare lists.",
    tips = {
        "A Wowhead comment recommends standing around 30.8,13.6 to fish and pull nearby Oasis Crocolisks for Questionable Meat.",
        "Pair with Malformed Gnasher fishing when Uldum assault routing is convenient.",
        "Do not treat rare mobs as the main source; use repeatable beast pulls around the water.",
    },
    coords = {
        C(0.308, 0.136, "Fishing and crocolisk pull setup"),
        C(0.298, 0.157, "Northern Uldum water edge"),
        C(0.328, 0.142, "Oasis crocolisk sweep"),
        C(0.840, 0.580, "Cursed Landing corrupted-water side route"),
    },
    confidence = "high",
}

local function RegisterMeat(itemID, itemName, spots, summary)
    Register({
        itemID = itemID,
        itemName = itemName,
        expansion = "battleForAzeroth",
        professions = { "cooking" },
        category = "Meat",
        sourceUrls = { ItemUrl(itemID) },
        summary = summary,
        spots = spots,
    })
end

RegisterMeat(152631, "Briny Flesh", { TIRAGARDE_SEAL_ROUTE }, "BFA seafood meat from coastal beasts.")
RegisterMeat(154897, "Stringy Loins", {
    DRUSTVAR_FALLHAVEN_ROUTE,
}, "BFA cooking meat from birds, wolves, and similar beasts.")
RegisterMeat(154898, "Meaty Haunch", {
    DRUSTVAR_BARROWKNOLL_ROUTE,
    DRUSTVAR_FALLHAVEN_ROUTE,
}, "BFA cooking meat from larger beasts.")
RegisterMeat(154899, "Thick Paleo Steak", {
    DRUSTVAR_SAUROLISK_MEAT_ROUTE,
}, "BFA dinosaur meat from saurolisk and raptor routes.")
RegisterMeat(168303, "Rubbery Flank", {
    NAZJATAR_SNAPDRAGON_MEAT_ROUTE,
}, "Nazjatar cooking meat from snapdragons and aquatic beasts.")
RegisterMeat(168645, "Moist Fillet", {
    NAZJATAR_SNAPDRAGON_MEAT_ROUTE,
}, "Nazjatar cooking fish/meat from Deeptide Frenzy and aquatic beast routes.")
RegisterMeat(174353, "Questionable Meat", {
    ULDUM_QUESTIONABLE_MEAT_ROUTE,
}, "Patch 8.3 cooking meat from Uldum assault beasts, best paired with corrupted-water fishing routes.")
