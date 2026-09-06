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
