local _, NS = ...
local Register = NS.RegisterMaterialFarmingSpot

local function C(x, y, label)
    return { x = x, y = y, label = label }
end

local function ItemUrl(itemID)
    return "https://www.wowhead.com/item=" .. tostring(itemID)
end

local DISENCHANT_GEAR_SPOTS = {
    {
        id = "cataclysm-enchanting-bastion-of-twilight-trash-disenchant",
        source = "Wowhead enchanting material pages, wow-professions disenchanting table, and Bastion of Twilight cloth route research",
        sourceUrls = {
            ItemUrl(52718),
            ItemUrl(52719),
            ItemUrl(52721),
            "https://www.wow-professions.com/cataclysm/disenchanting-table-cataclysm-classic",
            "https://www.wowhead.com/guide/6-1-0-embersilk-cloth-farming-guide-3020",
        },
        mapName = "Twilight Highlands",
        location = "Bastion of Twilight entrance and trash reset path",
        routeType = "disenchant-gear-farm",
        density = "Medium to high",
        dropDifficulty = "Indirect material farm. The input is Cataclysm uncommon and rare gear, then disenchanting.",
        tips = {
            "Farm dense trash for greens/blues, then disenchant eligible gear.",
            "Use armor for dust-leaning results and weapons for essence-leaning results.",
            "Compare auction, vendor, and disenchant values before destroying items.",
        },
        coords = {
            C(0.342, 0.779, "Bastion of Twilight entrance"),
            C(0.354, 0.758, "Entrance trash staging"),
        },
        confidence = "medium",
    },
    {
        id = "cataclysm-enchanting-twilight-highlands-victors-point-green-farm",
        source = "Wowhead Embersilk route guide and Cataclysm disenchanting table",
        sourceUrls = {
            "https://www.wowhead.com/guide/6-1-0-embersilk-cloth-farming-guide-3020",
            "https://www.wow-professions.com/cataclysm/disenchanting-table-cataclysm-classic",
        },
        mapName = "Twilight Highlands",
        location = "Victor's Point phased ogre and ettin green-drop farm",
        routeType = "disenchant-gear-farm",
        density = "High if phased correctly",
        dropDifficulty = "Requires the correct quest phase; otherwise use Bastion trash or general high-level humanoid routes.",
        tips = {
            "Do the Victor's Point chain until the repeatable-style ogre/ettin phase is active, then stop before turning in the final step.",
            "Loot greens and cloth, then decide whether to disenchant the gear.",
        },
        coords = {
            C(0.392, 0.574, "Victor's Point farm start"),
            C(0.422, 0.596, "Ogre and ettin packs"),
            C(0.448, 0.628, "Southern pack return"),
        },
        confidence = "medium",
    },
}

local function RegisterEnchantingMaterial(itemID, itemName, summary)
    Register({
        itemID = itemID,
        itemName = itemName,
        expansion = "cataclysm",
        professions = { "enchanting" },
        category = "Enchanting",
        sourceUrls = { ItemUrl(itemID), "https://www.wow-professions.com/cataclysm/disenchanting-table-cataclysm-classic" },
        summary = summary,
        spots = DISENCHANT_GEAR_SPOTS,
    })
end

RegisterEnchantingMaterial(52718, "Lesser Celestial Essence", "Cataclysm enchanting material created by disenchanting eligible Cataclysm uncommon gear, especially lower item-level weapons.")
RegisterEnchantingMaterial(52719, "Greater Celestial Essence", "Cataclysm enchanting material created from essences or by disenchanting eligible higher Cataclysm uncommon gear.")
RegisterEnchantingMaterial(52721, "Heavenly Shard", "Cataclysm enchanting material created from rare Cataclysm gear or by combining smaller shards.")
