local _, NS = ...
local Register = NS.RegisterMaterialFarmingSpot

local ENCHANTING_GUIDE = "https://www.wowhead.com/guide/enchanting-leveling-1-300-wow-classic"
local WOW_PROFESSIONS_GUIDE = "https://www.wow-professions.com/guides/vanilla-enchanting-leveling"
local DISENCHANT_TABLE = "https://www.wow-professions.com/classic/disenchanting-guide"

local function C(x, y, label)
    return { x = x, y = y, label = label }
end

local function ItemUrl(itemID)
    return "https://www.wowhead.com/item=" .. tostring(itemID)
end

local HIGH_LEVEL_GEAR_SPOTS = {
    {
        id = "classic-enchanting-plaguelands-tyrs-hand",
        source = "Wowhead retail enchanting guides, disenchant tables, and Plaguelands high-level humanoid route notes",
        sourceUrls = {
            ENCHANTING_GUIDE,
            WOW_PROFESSIONS_GUIDE,
            DISENCHANT_TABLE,
            "https://www.wowhead.com/zone=139/eastern-plaguelands",
        },
        mapName = "Eastern Plaguelands",
        location = "Tyr's Hand, Corin's Crossing, and Plaguewood high-level humanoid/undead route for disenchantable gear",
        routeType = "disenchant-gear-farm",
        density = "Medium to high",
        dropDifficulty = "Disenchant target. Farm eligible high-level green weapons/armor, then compare disenchant value against auction value.",
        tips = {
            "Weapons are usually better essence candidates than armor, which more often yields dust.",
            "Use the route for Runecloth and green gear; disenchant only when market math supports it.",
            "Stratholme and Scholomance clears are repeatable backups if outdoor camps are crowded.",
        },
        coords = {
            C(0.760, 0.744, "Tyr's Hand Scarlet camps"),
            C(0.344, 0.456, "Corin's Crossing undead"),
            C(0.220, 0.248, "Plaguewood undead"),
            C(0.272, 0.116, "Stratholme service entrance backup"),
        },
        confidence = "medium",
    },
    {
        id = "classic-enchanting-scholomance-entrance",
        source = "Wowhead retail enchanting guides, disenchant tables, and Scholomance/Stratholme farming notes",
        sourceUrls = {
            ENCHANTING_GUIDE,
            WOW_PROFESSIONS_GUIDE,
            DISENCHANT_TABLE,
            "https://www.wowhead.com/zone=2057/scholomance",
        },
        mapName = "Western Plaguelands",
        location = "Scholomance entrance and Sorrow Hill/Andorhal undead route for high-level disenchantable gear",
        routeType = "disenchant-gear-farm",
        density = "Medium",
        dropDifficulty = "Reset/clear dependent. Best if your character can quickly generate item level 51+ uncommon gear.",
        tips = {
            "Farm or buy high-level green gear, then compare disenchant value against direct auction value.",
            "Use Scholomance-style clears when you want instance control over open-world competition.",
            "Sorrow Hill and Andorhal can add outdoor undead density and Runecloth.",
        },
        coords = {
            C(0.694, 0.734, "Scholomance entrance"),
            C(0.488, 0.788, "Sorrow Hill undead"),
            C(0.472, 0.620, "Andorhal undead"),
        },
        confidence = "medium",
    },
}

local function RegisterEssence(itemID, itemName, summary, itemLevelNote)
    local sourceUrls = { ItemUrl(itemID), ENCHANTING_GUIDE, WOW_PROFESSIONS_GUIDE, DISENCHANT_TABLE, "https://warcraft.wiki.gg/wiki/" .. itemName:gsub(" ", "_") }
    local spots = {}
    for _, spot in ipairs(HIGH_LEVEL_GEAR_SPOTS) do
        local copy = {}
        for key, value in pairs(spot) do
            copy[key] = value
        end
        copy.id = spot.id .. "-" .. tostring(itemID)
        copy.dropDifficulty = itemLevelNote .. " " .. spot.dropDifficulty
        spots[#spots + 1] = copy
    end

    Register({
        itemID = itemID,
        itemName = itemName,
        expansion = "classic",
        professions = { "enchanting" },
        category = "Enchanting",
        researchStatus = "researched",
        sourceUrls = sourceUrls,
        summary = summary,
        spots = spots,
    })
end

RegisterEssence(
    16202,
    "Lesser Eternal Essence",
    "Classic high-end enchanting essence from disenchanting roughly item level 51-55 uncommon gear, especially weapons.",
    "Target item level is roughly 51-55 uncommon gear."
)

RegisterEssence(
    16203,
    "Greater Eternal Essence",
    "Classic high-end enchanting essence from disenchanting roughly item level 56+ uncommon gear, especially weapons.",
    "Target item level is roughly 56+ uncommon gear."
)

local DISENCHANT_ROUTES = {
    early = {
        mapName = "Westfall",
        location = "Defias camps and Deadmines entrance for low-level uncommon gear",
        targetUrl = "https://www.wowhead.com/zone=40/westfall",
        coords = {
            C(0.444, 0.200, "Jangolode Defias camp"), C(0.452, 0.704, "Moonbrook Defias"), C(0.424, 0.716, "Deadmines entrance"),
        },
        note = "Disenchant low-level uncommon armor for dust/shards and weapons for essences.",
    },
    low = {
        mapName = "Tirisfal Glades",
        location = "Scarlet Monastery entrance and repeatable Scarlet clears",
        targetUrl = "https://www.wowhead.com/zone=796/scarlet-monastery",
        coords = {
            C(0.846, 0.322, "Scarlet Monastery entrance"), C(0.818, 0.346, "Scarlet outer road"),
        },
        note = "Disenchant matching low-mid-level uncommon and rare gear from Scarlet clears.",
    },
    mid = {
        mapName = "Tanaris",
        location = "Zul'Farrak entrance and repeatable dungeon clears",
        targetUrl = "https://www.wowhead.com/zone=978/zulfarrak",
        coords = {
            C(0.394, 0.214, "Zul'Farrak entrance"), C(0.430, 0.244, "Zul'Farrak approach"),
        },
        note = "Disenchant matching mid-level uncommon and rare gear from Zul'Farrak clears.",
    },
    high = {
        mapName = "Eastern Plaguelands",
        location = "Tyr's Hand, Stratholme, and high-level Plaguelands gear farm",
        targetUrl = "https://www.wowhead.com/zone=2017/stratholme",
        coords = {
            C(0.760, 0.744, "Tyr's Hand"), C(0.344, 0.456, "Corin's Crossing"), C(0.272, 0.116, "Stratholme entrance"),
        },
        note = "Disenchant matching high-level uncommon and rare gear; compare valuable appearances before disenchanting.",
    },
    epic = {
        mapName = "Burning Steppes",
        location = "Blackrock Mountain raid and dungeon entrances for level-60 epic gear",
        targetUrl = "https://www.wowhead.com/zone=2717/molten-core",
        coords = {
            C(0.210, 0.382, "Blackrock Mountain entrance"), C(0.270, 0.240, "Molten Core entrance area"),
        },
        note = "Disenchant eligible level-60 epic gear only after checking transmog and vendor value.",
    },
}

local function RegisterDisenchantMaterial(itemID, itemName, routeKey, summary)
    local route = DISENCHANT_ROUTES[routeKey]
    local urls = { ItemUrl(itemID), ENCHANTING_GUIDE, WOW_PROFESSIONS_GUIDE, DISENCHANT_TABLE, route.targetUrl }
    Register({
        itemID = itemID,
        itemName = itemName,
        expansion = "classic",
        professions = { "enchanting" },
        category = "Enchanting",
        researchStatus = "researched",
        sourceUrls = urls,
        summary = summary,
        spots = {
            {
                id = "classic-disenchant-" .. routeKey .. "-" .. tostring(itemID),
                source = "Wowhead retail enchanting pages, disenchant tables, and repeatable gear-farm locations",
                sourceUrls = urls,
                mapName = route.mapName,
                location = route.location,
                routeType = "disenchant-gear-farm",
                density = "Gear-drop dependent",
                dropDifficulty = route.note,
                tips = {
                    "Armor favors dust while weapons are often better essence targets.",
                    "Rare-quality gear is the practical shard target for the corresponding level band.",
                    "Check transmog sale value before disenchanting any unusual appearance.",
                },
                coords = route.coords,
                confidence = "medium",
            },
        },
    })
end

RegisterDisenchantMaterial(10940, "Strange Dust", "early", "Starter enchanting dust from low-level uncommon armor.")
RegisterDisenchantMaterial(11083, "Soul Dust", "low", "Low-mid enchanting dust from uncommon armor.")
RegisterDisenchantMaterial(11137, "Vision Dust", "low", "Mid-level enchanting dust from uncommon armor.")
RegisterDisenchantMaterial(11176, "Dream Dust", "mid", "High-mid enchanting dust from uncommon armor.")
RegisterDisenchantMaterial(16204, "Illusion Dust", "high", "Endgame Classic enchanting dust from high-level uncommon armor.")
RegisterDisenchantMaterial(10938, "Lesser Magic Essence", "early", "Starter weapon-disenchanting essence.")
RegisterDisenchantMaterial(10939, "Greater Magic Essence", "early", "Starter weapon-disenchanting essence from the upper part of the first tier.")
RegisterDisenchantMaterial(10998, "Lesser Astral Essence", "early", "Early weapon-disenchanting essence.")
RegisterDisenchantMaterial(11082, "Greater Astral Essence", "low", "Low-mid weapon-disenchanting essence.")
RegisterDisenchantMaterial(11134, "Lesser Mystic Essence", "low", "Mid-level weapon-disenchanting essence.")
RegisterDisenchantMaterial(11135, "Greater Mystic Essence", "low", "Mid-level weapon-disenchanting essence.")
RegisterDisenchantMaterial(11174, "Lesser Nether Essence", "mid", "High-mid weapon-disenchanting essence.")
RegisterDisenchantMaterial(11175, "Greater Nether Essence", "mid", "High-mid weapon-disenchanting essence.")
RegisterDisenchantMaterial(10978, "Small Glimmering Shard", "early", "Starter shard from low-level rare gear.")
RegisterDisenchantMaterial(11084, "Large Glimmering Shard", "early", "Low-level shard from rare gear.")
RegisterDisenchantMaterial(11138, "Small Glowing Shard", "low", "Low-mid shard from rare gear.")
RegisterDisenchantMaterial(11139, "Large Glowing Shard", "low", "Mid-level shard from rare gear.")
RegisterDisenchantMaterial(11177, "Small Radiant Shard", "mid", "Mid-high shard from rare gear.")
RegisterDisenchantMaterial(11178, "Large Radiant Shard", "mid", "High-mid shard from rare gear.")
RegisterDisenchantMaterial(14343, "Small Brilliant Shard", "high", "High-level shard from rare gear.")
RegisterDisenchantMaterial(14344, "Large Brilliant Shard", "high", "Endgame Classic shard used by enchants and Midnight housing decor.")
RegisterDisenchantMaterial(20725, "Nexus Crystal", "epic", "Endgame crystal from eligible level-60 epic gear.")
