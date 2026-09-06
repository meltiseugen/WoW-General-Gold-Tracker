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
        id = "mists-enchanting-dread-wastes-ikthik-green-disenchant",
        source = "Wowhead enchanting material pages, Blizzard Watch enchanting notes, and Windwool farming guides",
        sourceUrls = {
            ItemUrl(74249),
            ItemUrl(74250),
            ItemUrl(74247),
            ItemUrl(74248),
            "https://www.wow-professions.com/farming/windwool-cloth-farming",
        },
        mapName = "Dread Wastes",
        location = "Ik'thik humanoid packs used for green and cloth drops, then disenchanting",
        routeType = "disenchant-gear-farm",
        density = "High for kill volume",
        dropDifficulty = "Indirect material farm. Green gear yields dust/essence chances; Sha Crystal is mainly from epics or conversions.",
        tips = {
            "Farm dense Ik'thik packs for green drops, then compare auction, vendor, and disenchant values.",
            "Uncommon armor leans toward Spirit Dust while weapons are better for Mysterious Essence.",
            "Sha Crystal should be treated as an epic-disenchant or conversion target, not a normal mob drop.",
        },
        coords = {
            C(0.5813, 0.4839, "Ik'thik start pack"),
            C(0.548, 0.522, "Second green-drop pack"),
            C(0.508, 0.560, "Third green-drop pack"),
            C(0.472, 0.592, "Fourth green-drop pack"),
            C(0.438, 0.620, "Final pack before reset"),
        },
        confidence = "medium",
    },
    {
        id = "mists-enchanting-halfhill-magebulb-seed-check",
        source = "Wowhead Spirit Dust comments and Tillers farm notes",
        sourceUrls = {
            ItemUrl(74249),
            ItemUrl(74250),
            "https://www.wowhead.com/item=74249/spirit-dust",
            "https://www.wowhead.com/item=74250/mysterious-essence",
            "https://www.wowhead.com/item=74247/ethereal-shard",
        },
        mapName = "Valley of the Four Winds",
        location = "Sunsong Ranch Magebulb Seed harvests near Halfhill",
        routeType = "daily-farm-plot",
        density = "Daily limited",
        dropDifficulty = "Daily and reputation-gated, but comments report Magebulb Seeds can provide MoP enchanting materials.",
        tips = {
            "Use this only as a supplemental daily source, not a grindable route.",
            "Requires access to the Tillers farm and the relevant seed vendor unlock.",
        },
        coords = {
            C(0.528, 0.482, "Sunsong Ranch plots"),
            C(0.534, 0.516, "Halfhill Market seed vendor area"),
        },
        confidence = "medium",
    },
}

local function RegisterEnchantingMaterial(itemID, itemName, summary)
    Register({
        itemID = itemID,
        itemName = itemName,
        expansion = "mists",
        professions = { "enchanting" },
        category = "Enchanting",
        sourceUrls = { ItemUrl(itemID), "https://www.wowhead.com/news/mists-of-pandaria-enchanting-overview-updated-for-5-4-204287" },
        summary = summary,
        spots = DISENCHANT_GEAR_SPOTS,
    })
end

RegisterEnchantingMaterial(74249, "Spirit Dust", "MoP dust from disenchanting eligible green gear, with Magebulb Seed harvests as a limited side source.")
RegisterEnchantingMaterial(74250, "Mysterious Essence", "MoP essence from disenchanting eligible green gear, especially weapon-leaning sources and conversions.")
RegisterEnchantingMaterial(74247, "Ethereal Shard", "MoP shard from disenchanting eligible rare gear, with crafted rare gear and conversions as secondary inputs.")
RegisterEnchantingMaterial(74248, "Sha Crystal", "MoP crystal from disenchanting epic gear or converting Ethereal Shards; listed with farm routes for the disenchantable gear input.")
