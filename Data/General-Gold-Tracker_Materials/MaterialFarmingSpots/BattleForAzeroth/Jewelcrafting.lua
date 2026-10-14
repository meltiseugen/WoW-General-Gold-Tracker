local _, NS = ...
local Register = NS.RegisterMaterialFarmingSpot
local H = NS.MaterialFarmingSpotHelpers

local function C(x, y, label)
    return { x = x, y = y, label = label }
end

local function ItemUrl(itemID)
    return "https://www.wowhead.com/item=" .. tostring(itemID)
end

local BASE_PROSPECTING_SOURCE_URLS = {
    "https://www.wowhead.com/guide/battle-for-azeroth-1-175-jewelcrafting-profession-guide-6277",
    "https://www.wowhead.com/guide/battle-for-azeroth-1-175-mining-profession-guide-patch-8-3-6293",
    "https://www.wowhead.com/spell=31252/prospecting",
    "https://www.wowhead.com/item=152513/platinum-ore",
    "https://thelazygoldmaker.com/battle-for-azeroth-jewelcrafting-gold-guide",
}

local PLATINUM_PROSPECTING_ROUTE = {
    id = "bfa-gems-stormsong-platinum-prospecting-input",
    source = "Retail Wowhead BFA Jewelcrafting/Mining guides, Wowhead prospecting notes, and sampled xScarlife retail Stormsong ore route pins",
    sourceUrls = {
        BASE_PROSPECTING_SOURCE_URLS[1],
        BASE_PROSPECTING_SOURCE_URLS[2],
        BASE_PROSPECTING_SOURCE_URLS[3],
        BASE_PROSPECTING_SOURCE_URLS[4],
        "https://xscarlife-gaming.com/farming-retail/",
    },
    mapName = "Stormsong Valley",
    location = "Stormsong Storm Silver and Platinum ore loop used as BFA base-gem prospecting input",
    routeType = "prospecting-input-route",
    density = "Medium to high",
    dropDifficulty = "Prospecting output is RNG. Platinum is the higher-value prospecting input, while Storm Silver and Monelite add volume.",
    tips = H.withBfaGatheringTips({
        "Prospect in batches of five ore, or use mass prospecting recipes when available.",
        "Mine Monelite replacements while targeting Storm Silver and Platinum; skipping common nodes slows rare-node turnover.",
        "Use this route for base BFA gems when ore prices are below expected gem value.",
    }),
    coords = {
        C(0.4421, 0.4955, "AoA/xScarlife Stormsong prospecting input pin"),
        C(0.4860, 0.5266, "AoA/xScarlife lower valley ore pin"),
        C(0.5303, 0.5319, "AoA/xScarlife central ore bend"),
        C(0.5557, 0.6143, "AoA/xScarlife ridge route pin"),
        C(0.6081, 0.6419, "AoA/xScarlife east ridge ore"),
        C(0.6669, 0.6518, "AoA/xScarlife eastern route pin"),
        C(0.7216, 0.6553, "AoA/xScarlife coast approach"),
        C(0.7515, 0.6941, "AoA/xScarlife southeast route"),
        C(0.6421, 0.7581, "AoA/xScarlife south return"),
        C(0.5004, 0.7610, "AoA/xScarlife western return"),
        C(0.4585, 0.6605, "AoA/xScarlife northwest return"),
        C(0.3990, 0.5090, "AoA/xScarlife route close"),
    },
    confidence = "high",
}

local MECHAGON_PROSPECTING_ROUTE = {
    id = "bfa-gems-mechagon-monelite-stormsilver-prospecting-input",
    source = "Wowhead Monelite and Storm Silver comments, retail BFA Mining guide, and Mechagon route notes",
    sourceUrls = {
        BASE_PROSPECTING_SOURCE_URLS[2],
        BASE_PROSPECTING_SOURCE_URLS[3],
        "https://www.wowhead.com/item=152512/monelite-ore",
        "https://www.wowhead.com/item=152579/storm-silver-ore",
        "https://www.wowhead.com/guide/comprehensive-mechagon-guide",
    },
    mapName = "Mechagon Island",
    location = "Mechagon Anti-Gravity Pack ore loop used as bulk BFA prospecting input",
    routeType = "prospecting-input-route",
    density = "Medium",
    dropDifficulty = "Good when Anti-Gravity Pack is available; prospecting returns skew lower than Platinum but volume is strong.",
    tips = H.withBfaGatheringTips({
        "A Wowhead Monelite comment calls out Mechagon Anti-Gravity Pack mining for strong Monelite and Storm Silver volume.",
        "Use this for cheaper bulk prospecting input rather than pure rare-gem hunting.",
        "Open Mechanized Chests while crossing the island if doing the full ore loop.",
    }),
    coords = {
        C(0.250, 0.540, "Western junkyard ore"),
        C(0.356, 0.382, "Central ridge"),
        C(0.522, 0.300, "Northern depot ore"),
        C(0.662, 0.482, "Eastern return"),
        C(0.548, 0.706, "Southern cliff ore"),
    },
    confidence = "medium",
}

local OSMENITE_PROSPECTING_ROUTE = {
    id = "bfa-gems-nazjatar-osmenite-prospecting-input",
    source = "Retail Wowhead patch 8.2 Jewelcrafting notes, Wowhead Osmenite page, Warcraft Wiki Leviathan's Eye page, and sampled xScarlife retail Nazjatar route pins",
    sourceUrls = {
        "https://www.wowhead.com/news/jewelcrafting-changes-in-patch-8-2-rise-of-azshara-epic-gems-292347",
        "https://www.wowhead.com/item=168185/osmenite-ore",
        "https://warcraft.wiki.gg/wiki/Leviathan%27s_Eye",
        "https://xscarlife-gaming.com/farming-retail/",
    },
    mapName = "Nazjatar",
    location = "Nazjatar Osmenite route used as patch 8.2 gem prospecting input",
    routeType = "prospecting-input-route",
    density = "High",
    dropDifficulty = "Prospecting output is RNG. Osmenite is the input for patch 8.2 gems and Leviathan's Eye.",
    tips = H.withBfaGatheringTips({
        "Prospect Osmenite when patch 8.2 epic or rare gem value beats raw ore.",
        "Pair the route with Zin'anthid if both markets are active.",
        "Treat Lava Lazuli, Sage Agate, Dark Opal, Sea Currant, Sand Spinel, Azsharine, and Leviathan's Eye as Osmenite outputs.",
    }),
    coords = {
        C(0.4002, 0.1549, "AoA/xScarlife northwestern Nazjatar ore pin"),
        C(0.4487, 0.2686, "AoA/xScarlife northern rise"),
        C(0.4733, 0.2990, "AoA/xScarlife upper Coral Forest"),
        C(0.6138, 0.2588, "AoA/xScarlife north Kal'methir"),
        C(0.6867, 0.2585, "AoA/xScarlife eastern ridge"),
        C(0.7595, 0.2582, "AoA/xScarlife Drowned Market north"),
        C(0.8035, 0.3606, "AoA/xScarlife eastern turn"),
        C(0.7719, 0.4930, "AoA/xScarlife southeast return"),
        C(0.7066, 0.4978, "AoA/xScarlife Kal'methir return"),
        C(0.6453, 0.5620, "AoA/xScarlife central return"),
        C(0.5200, 0.5588, "AoA/xScarlife Coral Forest south"),
        C(0.4772, 0.6077, "AoA/xScarlife lower Coral Forest"),
        C(0.4387, 0.6114, "AoA/xScarlife western slope"),
        C(0.4460, 0.6641, "AoA/xScarlife Hanging Reef approach"),
        C(0.4808, 0.7463, "AoA/xScarlife southern reef"),
        C(0.4114, 0.7603, "AoA/xScarlife southwest loop"),
        C(0.3752, 0.6785, "AoA/xScarlife west route"),
        C(0.3928, 0.5757, "AoA/xScarlife western return"),
        C(0.2960, 0.4756, "AoA/xScarlife far west point"),
        C(0.3514, 0.2151, "AoA/xScarlife north route close"),
    },
    confidence = "high",
}

local JEWELHAMMER_SHRINE_ROUTE = {
    id = "bfa-rare-gems-jewelhammer-focus-cache",
    source = "Wowhead BFA rare-gem comments and Jewelhammer Focus shrine coordinate reports",
    sourceUrls = {
        "https://www.wowhead.com/item=154123/amberblaze",
        "https://www.wowhead.com/item=154120/owlseye",
        "https://www.wowhead.com/item=154125/royal-quartz",
    },
    mapName = "Kul Tiras and Zandalar",
    location = "Jewelhammer Focus shrine color checks for rare BFA gems",
    routeType = "daily-gem-cache",
    density = "Limited daily-style checks",
    dropDifficulty = "Supplemental coordinate-backed rare-gem source; use prospecting routes for repeatable volume.",
    tips = {
        "Use this as a low-effort rare-gem check while traveling, not as the main farm.",
        "The color-specific shrines are useful for map-window pins because each check has a fixed coordinate.",
        "Prospecting Platinum remains the repeatable rare-gem route.",
    },
    coords = {
        C(0.4314, 0.6435, "Zuldazar green shrine report"),
        C(0.6132, 0.3724, "Nazmir red shrine report"),
        C(0.4418, 0.3805, "Vol'dun orange shrine report"),
        C(0.3413, 0.3546, "Drustvar purple shrine report"),
        C(0.6070, 0.5851, "Stormsong yellow shrine report"),
        C(0.4636, 0.2345, "Tiragarde blue shrine report"),
    },
    confidence = "medium",
}

local BASE_UNCOMMON_SPOTS = {
    PLATINUM_PROSPECTING_ROUTE,
    MECHAGON_PROSPECTING_ROUTE,
}

local BASE_RARE_SPOTS = {
    PLATINUM_PROSPECTING_ROUTE,
    JEWELHAMMER_SHRINE_ROUTE,
}

local OSMENITE_GEM_SPOTS = {
    OSMENITE_PROSPECTING_ROUTE,
}

local function RegisterGem(itemID, itemName, quality, spots, summary)
    Register({
        itemID = itemID,
        itemName = itemName,
        expansion = "battleForAzeroth",
        professions = { "jewelcrafting" },
        category = "Gem",
        sourceUrls = {
            ItemUrl(itemID),
            BASE_PROSPECTING_SOURCE_URLS[1],
            BASE_PROSPECTING_SOURCE_URLS[3],
        },
        summary = summary,
        qualityRank = quality,
        spots = spots,
    })
end

RegisterGem(153700, "Golden Beryl", "uncommon", BASE_UNCOMMON_SPOTS, "Uncommon BFA gem from prospecting Monelite Ore, Storm Silver Ore, and Platinum Ore.")
RegisterGem(153701, "Rubellite", "uncommon", BASE_UNCOMMON_SPOTS, "Uncommon BFA gem from prospecting Monelite Ore, Storm Silver Ore, and Platinum Ore.")
RegisterGem(153702, "Kubiline", "uncommon", BASE_UNCOMMON_SPOTS, "Uncommon BFA gem from prospecting Monelite Ore, Storm Silver Ore, and Platinum Ore.")
RegisterGem(153703, "Solstone", "uncommon", BASE_UNCOMMON_SPOTS, "Uncommon BFA gem from prospecting Monelite Ore, Storm Silver Ore, and Platinum Ore.")
RegisterGem(153704, "Viridium", "uncommon", BASE_UNCOMMON_SPOTS, "Uncommon BFA gem from prospecting Monelite Ore, Storm Silver Ore, and Platinum Ore.")
RegisterGem(153705, "Kyanite", "uncommon", BASE_UNCOMMON_SPOTS, "Uncommon BFA gem from prospecting Monelite Ore, Storm Silver Ore, and Platinum Ore.")
RegisterGem(153706, "Kraken's Eye", "rare", BASE_RARE_SPOTS, "Rare BFA jewelcrafting gem, best treated as Platinum prospecting output with shrine checks as a side source.")
RegisterGem(154120, "Owlseye", "rare", BASE_RARE_SPOTS, "Rare BFA gem, best treated as Platinum prospecting output with Jewelhammer shrine checks as a side source.")
RegisterGem(154121, "Scarlet Diamond", "rare", BASE_RARE_SPOTS, "Rare BFA gem, best treated as Platinum prospecting output with Jewelhammer shrine checks as a side source.")
RegisterGem(154122, "Tidal Amethyst", "rare", BASE_RARE_SPOTS, "Rare BFA gem, best treated as Platinum prospecting output with Jewelhammer shrine checks as a side source.")
RegisterGem(154123, "Amberblaze", "rare", BASE_RARE_SPOTS, "Rare BFA gem, best treated as Platinum prospecting output with Jewelhammer shrine checks as a side source.")
RegisterGem(154124, "Laribole", "rare", BASE_RARE_SPOTS, "Rare BFA gem, best treated as Platinum prospecting output with Jewelhammer shrine checks as a side source.")
RegisterGem(154125, "Royal Quartz", "rare", BASE_RARE_SPOTS, "Rare BFA gem, best treated as Platinum prospecting output with Jewelhammer shrine checks as a side source.")

RegisterGem(168188, "Sage Agate", "rare", OSMENITE_GEM_SPOTS, "Patch 8.2 BFA gem from prospecting Osmenite Ore in Nazjatar.")
RegisterGem(168189, "Dark Opal", "rare", OSMENITE_GEM_SPOTS, "Patch 8.2 BFA gem from prospecting Osmenite Ore in Nazjatar.")
RegisterGem(168190, "Lava Lazuli", "rare", OSMENITE_GEM_SPOTS, "Patch 8.2 BFA gem from prospecting Osmenite Ore in Nazjatar.")
RegisterGem(168191, "Sea Currant", "rare", OSMENITE_GEM_SPOTS, "Patch 8.2 BFA gem from prospecting Osmenite Ore in Nazjatar.")
RegisterGem(168192, "Sand Spinel", "rare", OSMENITE_GEM_SPOTS, "Patch 8.2 BFA gem from prospecting Osmenite Ore in Nazjatar.")
RegisterGem(168193, "Azsharine", "rare", OSMENITE_GEM_SPOTS, "Patch 8.2 BFA epic gem from prospecting Osmenite Ore in Nazjatar.")
RegisterGem(168635, "Leviathan's Eye", "rare", OSMENITE_GEM_SPOTS, "Patch 8.2 BFA jewelcrafting gem from prospecting Osmenite Ore in Nazjatar.")
