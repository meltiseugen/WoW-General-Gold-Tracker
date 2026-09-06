local _, NS = ...
local Register = NS.RegisterMaterialFarmingSpot

local function C(x, y, label)
    return { x = x, y = y, label = label }
end

local function ItemUrl(itemID)
    return "https://www.wowhead.com/item=" .. tostring(itemID)
end

local BFA_MYTHIC_DUNGEON_CORE_ROUTE = {
    id = "bfa-hydrocore-tidalcore-mythic-final-boss-route",
    source = "Retail Wowhead Hydrocore/Tidalcore pages and Battle for Azeroth dungeon entrance guide",
    sourceUrls = {
        "https://www.wowhead.com/item=162460/hydrocore",
        "https://www.wowhead.com/item=165948/tidalcore",
        "https://www.wowhead.com/guide/dungeon-entrances-wow-battle-for-azeroth",
        "https://www.wowhead.com/guide/dungeon-and-raid-entrances-8974",
    },
    mapName = "Kul Tiras and Zandalar",
    location = "Fast BFA Mythic dungeon final-boss rotation",
    routeType = "mythic-dungeon-final-boss-farm",
    density = "Instance-gated",
    dropDifficulty = "Instance reagent route. Use Mythic/M+ final bosses rather than open-world farming.",
    tips = {
        "Hydrocore and Tidalcore are not normal outdoor drops; route to BFA Mythic dungeon entrances and clear final bosses.",
        "Atal'Dazar and The Underrot are included as short, coordinate-backed entrances rather than listing every dungeon.",
        "Check lockout and difficulty before farming, because the reagent source is the instance completion path.",
    },
    coords = {
        C(0.4374, 0.3920, "Atal'Dazar entrance, Zuldazar"),
        C(0.5192, 0.6582, "The Underrot entrance, Nazmir"),
        C(0.3774, 0.3948, "King's Rest entrance, Zuldazar"),
        C(0.8843, 0.5313, "Siege of Boralus Horde-side entrance, Tiragarde Sound"),
    },
    confidence = "high",
}

local ULDIR_REAGENT_ROUTE = {
    id = "bfa-sanguicell-uldir-raid-boss-route",
    source = "Retail Wowhead Sanguicell item page, Uldir zone page, and Battle for Azeroth raid entrance guide",
    sourceUrls = {
        "https://www.wowhead.com/item=162461/sanguicell",
        "https://www.wowhead.com/zone=9389/uldir",
        "https://www.wowhead.com/guide/dungeon-and-raid-entrances-8974",
    },
    mapName = "Nazmir",
    location = "Uldir entrance and raid-boss route",
    routeType = "raid-boss-reagent-route",
    density = "Raid-lockout gated",
    dropDifficulty = "Raid reagent route. Farm Uldir bosses rather than outdoor trash.",
    tips = {
        "Sanguicell is best represented as a Uldir boss reagent route, not a normal material grind.",
        "Run eligible difficulties when the reagent is the target.",
        "Use the Nazmir entrance pin as the map-window anchor for this lockout route.",
    },
    coords = {
        C(0.5419, 0.5310, "Uldir entrance, Nazmir"),
    },
    confidence = "high",
}

local BOD_REAGENT_ROUTE = {
    id = "bfa-breath-of-bwonsamdi-battle-of-dazaralor-route",
    source = "Retail Wowhead Breath of Bwonsamdi page, Battle of Dazar'alor overview, and BFA raid entrance guide",
    sourceUrls = {
        "https://www.wowhead.com/item=165703/breath-of-bwonsamdi",
        "https://www.wowhead.com/guide/battle-of-dazaralor-raid-overview",
        "https://www.wowhead.com/guide/dungeon-and-raid-entrances-8974",
        "https://www.wowhead.com/guide/daily-weekly-pve-checklist-level-120",
    },
    mapName = "Dazar'alor and Boralus",
    location = "Battle of Dazar'alor raid entrances",
    routeType = "raid-boss-reagent-route",
    density = "Raid-lockout gated",
    dropDifficulty = "Raid reagent route. Battle of Dazar'alor bosses are the target, with faction-specific entrance pins.",
    tips = {
        "Breath of Bwonsamdi is a Battle of Dazar'alor boss reagent, so outdoor fallback routes are intentionally not used.",
        "Use the Dazar'alor pin for Horde and the Boralus pin for Alliance.",
        "Sanguicell can be connected to this route through Breath conversion, but Uldir is the cleaner Sanguicell source.",
    },
    coords = {
        C(0.390, 0.020, "Horde Battle of Dazar'alor entrance, Dazar'alor"),
        C(0.700, 0.350, "Alliance Battle of Dazar'alor entrance, Boralus"),
    },
    confidence = "high",
}

local function RegisterReagent(itemID, itemName, professions, spots, summary)
    Register({
        itemID = itemID,
        itemName = itemName,
        expansion = "battleForAzeroth",
        professions = professions,
        category = "Reagent",
        sourceUrls = { ItemUrl(itemID) },
        summary = summary,
        spots = spots,
    })
end

RegisterReagent(
    162460,
    "Hydrocore",
    { "alchemy", "blacksmithing", "enchanting", "engineering", "leatherworking", "tailoring" },
    { BFA_MYTHIC_DUNGEON_CORE_ROUTE },
    "BFA dungeon reagent from Mythic dungeon final-boss and completion routes."
)

RegisterReagent(
    162461,
    "Sanguicell",
    { "alchemy", "blacksmithing", "cooking", "enchanting", "jewelcrafting", "leatherworking", "tailoring" },
    { ULDIR_REAGENT_ROUTE, BOD_REAGENT_ROUTE },
    "BFA raid reagent best represented by Uldir boss routes, with Battle of Dazar'alor conversion side value."
)

RegisterReagent(
    165703,
    "Breath of Bwonsamdi",
    { "alchemy", "blacksmithing", "enchanting", "jewelcrafting", "leatherworking", "tailoring" },
    { BOD_REAGENT_ROUTE },
    "Battle of Dazar'alor raid reagent from boss lockout routes."
)

RegisterReagent(
    165948,
    "Tidalcore",
    { "alchemy", "blacksmithing", "enchanting", "engineering", "leatherworking", "tailoring" },
    { BFA_MYTHIC_DUNGEON_CORE_ROUTE },
    "Later BFA dungeon reagent from Mythic and Mythic+ final-boss/completion routes."
)
