local _, NS = ...
local Register = NS.RegisterMaterialFarmingSpot

local function C(x, y, label)
    return { x = x, y = y, label = label }
end

local function ItemUrl(itemID)
    return "https://www.wowhead.com/item=" .. tostring(itemID)
end

local CURSED_QUEENFISH_ROUTE = {
    id = "legion-cursed-queenfish-azsuna-drowned-gardens-schools",
    source = "Wowhead Cursed Queenfish School comments and wow-professions Legion Fishing guide",
    sourceUrls = {
        "https://www.wowhead.com/object=246488/cursed-queenfish-school",
        "https://www.wow-professions.com/guides/legion-fishing-leveling",
    },
    mapName = "Azsuna",
    location = "Azsuna Drowned Gardens and nearby pool checks",
    routeType = "fishing-school-loop",
    density = "High",
    dropDifficulty = "Easy pool route; cave and lake checks help keep the loop full.",
    tips = {
        "Cursed Queenfish is the Azsuna zone fish.",
        "Use the Drowned Gardens pool cluster first, then widen to the north if pools are dry.",
        "The cave pool around 50.5,50.4 is worth checking when nearby pools are empty.",
    },
    coords = {
        C(0.483, 0.319, "Drowned Gardens pool"),
        C(0.485, 0.341, "Drowned Gardens south pool"),
        C(0.482, 0.355, "Drowned Gardens lower pool"),
        C(0.485, 0.403, "Central lake pool"),
        C(0.499, 0.463, "South lake pool"),
        C(0.505, 0.504, "Cave pool"),
        C(0.523, 0.339, "East Drowned Gardens pool"),
        C(0.544, 0.285, "North ridge pool"),
        C(0.453, 0.172, "Northern extra pool"),
    },
    confidence = "high",
}

local MOSSGILL_ROUTE = {
    id = "legion-mossgill-perch-valsharah-rivers",
    source = "Wowhead Mossgill Perch School comments and wow-professions Legion Fishing guide",
    sourceUrls = {
        "https://www.wowhead.com/object=246489/mossgill-perch-school",
        "https://www.wow-professions.com/guides/legion-fishing-leveling",
    },
    mapName = "Val'sharah",
    location = "Val'sharah freshwater river route north of Temple of Elune and south river chain",
    routeType = "freshwater-fishing-school-loop",
    density = "High",
    dropDifficulty = "Good route if you stay inland; this is not a coast fish.",
    tips = {
        "A Wowhead comment warns not to look on the coast; Mossgill Perch is a freshwater fish.",
        "Use the river north of Temple of Elune around 52,47, then follow the longer southern chain.",
    },
    coords = {
        C(0.532, 0.726, "Southern river pool"),
        C(0.533, 0.680, "Southern river upper pool"),
        C(0.489, 0.650, "West river pool"),
        C(0.483, 0.631, "West river lower pool"),
        C(0.537, 0.469, "Temple north river"),
        C(0.549, 0.485, "Temple northeast river"),
        C(0.614, 0.535, "Central river"),
        C(0.626, 0.639, "East river chain"),
        C(0.615, 0.710, "South river chain"),
        C(0.726, 0.419, "Far northeast pool"),
    },
    confidence = "high",
}

local HIGHMOUNTAIN_SALMON_ROUTE = {
    id = "legion-highmountain-salmon-whitewater-wash",
    source = "Wowhead Highmountain Salmon School comments and wow-professions Legion Fishing guide",
    sourceUrls = {
        "https://www.wowhead.com/object=246490/highmountain-salmon-school",
        "https://www.wow-professions.com/guides/legion-fishing-leveling",
    },
    mapName = "Highmountain",
    location = "Whitewater Wash and Thunder Totem river pools",
    routeType = "freshwater-fishing-school-loop",
    density = "High",
    dropDifficulty = "Compact pools around Whitewater Wash, with more hostile checks downstream.",
    tips = {
        "Highmountain Salmon is the Highmountain zone fish.",
        "Whitewater Wash around 42,59 has multiple nearby schools.",
        "Extend to eastern Thunder Totem river pools when the main cluster is dry.",
    },
    coords = {
        C(0.547, 0.508, "Eastern river pool"),
        C(0.564, 0.482, "Northeast river pool"),
        C(0.503, 0.570, "Thunder Totem river"),
        C(0.448, 0.607, "Whitewater Wash east"),
        C(0.421, 0.597, "Whitewater Wash center"),
        C(0.421, 0.604, "Whitewater Wash lower"),
        C(0.412, 0.579, "Whitewater Wash west"),
        C(0.396, 0.638, "Southwest river"),
        C(0.350, 0.782, "Southern river end"),
    },
    confidence = "high",
}

local STORMRAY_ROUTE = {
    id = "legion-stormray-stormheim-fever-schools",
    source = "Wowhead Fever of Stormrays comments and wow-professions Legion Fishing guide",
    sourceUrls = {
        "https://www.wowhead.com/object=246491/fever-of-stormrays",
        "https://www.wow-professions.com/guides/legion-fishing-leveling",
    },
    mapName = "Stormheim",
    location = "Stormheim inland and coast Fever of Stormrays pools",
    routeType = "fishing-school-loop",
    density = "High",
    dropDifficulty = "Large pool chain, but Stormheim terrain makes travel uneven.",
    tips = {
        "Stormray is the Stormheim zone fish.",
        "Use the central chain around 36-58 x 55-70 first; check northwest pools when the route is crowded.",
    },
    coords = {
        C(0.369, 0.558, "Western fever pool"),
        C(0.365, 0.566, "Western lower pool"),
        C(0.334, 0.552, "West bank pool"),
        C(0.290, 0.454, "Northwest pool"),
        C(0.387, 0.604, "Central pool"),
        C(0.424, 0.619, "Central east pool"),
        C(0.498, 0.656, "Eastern chain"),
        C(0.527, 0.658, "Eastern chain lower"),
        C(0.516, 0.704, "Southern pool"),
        C(0.555, 0.656, "Southeast pool"),
        C(0.569, 0.561, "Northeast return"),
    },
    confidence = "high",
}

local RUNESCALE_KOI_ROUTE = {
    id = "legion-runescale-koi-suramar-river-schools",
    source = "Wowhead Runescale Koi School comments and wow-professions Legion Fishing guide",
    sourceUrls = {
        "https://www.wowhead.com/object=246492/runescale-koi-school",
        "https://www.wow-professions.com/guides/legion-fishing-leveling",
    },
    mapName = "Suramar",
    location = "Suramar freshwater pools from Meredil toward northern river bends",
    routeType = "freshwater-fishing-school-loop",
    density = "High",
    dropDifficulty = "Good pool chain; Suramar mob density and phasing can slow shoreline movement.",
    tips = {
        "Runescale Koi is the Suramar zone fish.",
        "Start from the Meredil side of the river and move north/east through the documented pool chain.",
    },
    coords = {
        C(0.379, 0.563, "Meredil river start"),
        C(0.372, 0.553, "Meredil west pool"),
        C(0.373, 0.525, "Upper Meredil pool"),
        C(0.344, 0.480, "Northwest river"),
        C(0.335, 0.425, "Northwest river bend"),
        C(0.366, 0.385, "North river pool"),
        C(0.404, 0.324, "Northeast route"),
        C(0.458, 0.293, "Eastern route"),
        C(0.464, 0.277, "Eastern upper pool"),
        C(0.502, 0.424, "Central river return"),
    },
    confidence = "high",
}

local BLACK_BARRACUDA_ROUTE = {
    id = "legion-black-barracuda-suramar-jandvik-open-sea",
    source = "Wowhead Black Barracuda comments, Warcraft Wiki, and wow-professions Legion Fishing guide",
    sourceUrls = {
        "https://www.wowhead.com/item=124112/black-barracuda",
        "https://warcraft.wiki.gg/wiki/Black_Barracuda_School",
        "https://www.wow-professions.com/guides/legion-fishing-leveling",
    },
    mapName = "Suramar",
    location = "Jandvik and Azuregale Bay open sea pools",
    routeType = "open-sea-fishing-school-loop",
    density = "High",
    dropDifficulty = "Strong pool loop, but some offshore pools are easier with a fishing raft.",
    tips = {
        "Black Barracuda is caught from open sea pools around the Broken Isles.",
        "Wowhead comments point to Jandvik around 78,61 and the line from 75.41,50.71 to 84.28,55.40.",
        "Astravar Harbor around 51,73 is a calmer raft-friendly backup.",
    },
    coords = {
        C(0.780, 0.610, "Jandvik open sea pools"),
        C(0.7541, 0.5071, "Jandvik to naga island west"),
        C(0.8428, 0.5540, "Jandvik to naga island east"),
        C(0.510, 0.730, "Astravar Harbor raft route"),
    },
    confidence = "high",
}

local SILVER_MACKEREL_ROUTE = {
    id = "legion-silver-mackerel-valsharah-open-water",
    source = "Retail Wowhead Legion Fishing guide, Wowhead Silver Mackerel item page, and Warcraft Wiki",
    sourceUrls = {
        "https://www.wowhead.com/guide/legion-fishing",
        "https://www.wowhead.com/item=133607/silver-mackerel",
        "https://warcraft.wiki.gg/wiki/Silver_Mackerel",
    },
    mapName = "Val'sharah",
    location = "Lorathil and southern Val'sharah open-water fishing stops",
    routeType = "open-water-fishing-loop",
    density = "High for common open-water fish",
    dropDifficulty = "Common catch in Broken Isles water; no pool hunting needed.",
    tips = {
        "Silver Mackerel is the common Legion fish and is caught from open water rather than schools.",
        "Use open-water casts beside Mossgill Perch routes when you need Seed-Battered Fish Plate materials.",
        "The Wowhead fishing guide comment confirms Lorathil water around 53,73 catches Silver Mackerel with Mossgill Perch.",
    },
    coords = {
        C(0.530, 0.730, "Lorathil open-water cast"),
        C(0.532, 0.726, "Southern river open water"),
        C(0.533, 0.680, "Southern river upper cast"),
        C(0.489, 0.650, "West river cast"),
        C(0.483, 0.631, "West river lower cast"),
    },
    confidence = "high",
}

local function RegisterFish(itemID, itemName, spots, summary)
    Register({
        itemID = itemID,
        itemName = itemName,
        expansion = "legion",
        professions = { "fishing", "cooking" },
        category = "Fish",
        sourceUrls = { ItemUrl(itemID) },
        summary = summary,
        spots = spots,
    })
end

RegisterFish(
    124107,
    "Cursed Queenfish",
    { CURSED_QUEENFISH_ROUTE },
    "Azsuna fishing-school route around Drowned Gardens."
)
RegisterFish(
    124108,
    "Mossgill Perch",
    { MOSSGILL_ROUTE },
    "Val'sharah freshwater fishing route; avoid coastlines."
)
RegisterFish(
    124109,
    "Highmountain Salmon",
    { HIGHMOUNTAIN_SALMON_ROUTE },
    "Highmountain freshwater pools around Whitewater Wash and Thunder Totem rivers."
)
RegisterFish(124110, "Stormray", { STORMRAY_ROUTE }, "Stormheim Fever of Stormrays pool route.")
RegisterFish(124111, "Runescale Koi", { RUNESCALE_KOI_ROUTE }, "Suramar freshwater Runescale Koi school chain.")
RegisterFish(
    124112,
    "Black Barracuda",
    { BLACK_BARRACUDA_ROUTE },
    "Open-sea Broken Isles fish with a strong Suramar Jandvik pool loop."
)
RegisterFish(
    133607,
    "Silver Mackerel",
    { SILVER_MACKEREL_ROUTE },
    "Common Legion fish from open water across Broken Isles zones; Val'sharah is a convenient coordinate-backed route."
)
