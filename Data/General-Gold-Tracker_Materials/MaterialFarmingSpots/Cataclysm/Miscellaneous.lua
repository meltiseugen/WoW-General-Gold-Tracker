local _, NS = ...
local Register = NS.RegisterMaterialFarmingSpot

local function ItemUrl(itemID)
    return "https://www.wowhead.com/item=" .. tostring(itemID)
end

local function Copy(value)
    if type(value) ~= "table" then
        return value
    end
    local copy = {}
    for key, child in pairs(value) do
        copy[key] = Copy(child)
    end
    return copy
end

local function RegisterMaterial(itemID, name, category, professions, summary, spots, urls, auctionable)
    Register({
        itemID = itemID,
        itemName = name,
        expansion = "cataclysm",
        professions = professions,
        category = category,
        acquisitionType = #(spots or {}) == 0 and "processing" or nil,
        isRoute = false,
        auctionable = auctionable ~= false,
        researchedAt = "2026-10-19",
        sourceUrls = urls or { ItemUrl(itemID) },
        summary = summary,
        spots = spots or {},
    })
end

local function Entrance(id, mapID, mapName, location, x, y, action, urls, tips)
    return {
        id = id,
        mapID = mapID,
        mapName = mapName,
        location = location,
        isRoute = false,
        routeType = "instance-entrance",
        density = "Legacy instance source",
        source = "Retail item sources and Cataclysm instance entrance guides",
        sourceUrls = urls,
        farmAction = action,
        dropDifficulty = "Legacy instance source; difficulty and lockouts limit repeat attempts.",
        tips = tips,
        coords = { { x = x, y = y, label = location } },
        confidence = "medium",
    }
end

local RAID_ENTRANCES = "https://www.wowhead.com/guide/raid-entrances-of-cataclysm-6071"
local CLAM_URLS = { ItemUrl(52340), "https://warcraft.wiki.gg/wiki/Abyssal_Clam" }
local CLAM_SPOTS = {
    {
        id = "cataclysm-abyssal-clam-shimmering-southern-naga",
        mapID = 205,
        mapName = "Shimmering Expanse",
        location = "Southern underwater cliff near 27,85",
        targetName = "Naz'jar Serpent Guard",
        targetType = "npc",
        farmAction = "Kill and loot naga for Abyssal Clams; open the clams for Blood Shrimp.",
        routeType = "mob-farm-anchor",
        density = "Historical mob cluster; no fixed yield",
        isRoute = false,
        source = "Retail Wowhead Abyssal Clam comments; historical southern-cliff farming report",
        sourceUrls = CLAM_URLS,
        dropDifficulty = "Historical scouting anchor; local phasing and loot changes can affect results.",
        tips = {
            "Descend along the southern cliff and check the naga packs below the map anchor.",
            "Blood Shrimp is the useful cooking output. Darkfathom and Flawless Pearls are vendor-quality bonuses, not crafting pearls.",
            "Do not rely on old Uldum Neferset drop tables; later reports dispute those sources.",
            "Sell unopened clams or their shrimp according to demand; do not assume a profitable rare pearl outcome.",
        },
        coords = { { x = 0.27, y = 0.85, label = "Historical southern-cliff naga anchor" } },
        confidence = "medium",
    },
}
RegisterMaterial(52340, "Abyssal Clam", "Openable", { "fishing", "cooking", "miscellaneous" },
    "Tradeable Cataclysm clam from Vashj'ir aquatic enemies. Open it for Blood Shrimp and occasional vendor-quality pearls.", CLAM_SPOTS, CLAM_URLS)

local CHAOS_SPOTS = {
    Entrance("cataclysm-chaos-orb-vortex-pinnacle", 249, "Uldum", "Vortex Pinnacle entrance", 0.765, 0.846,
        "Clear legacy Heroic Vortex Pinnacle and loot Asaad for a chance at Chaos Orbs.",
        { ItemUrl(52078), "https://www.wowhead.com/npc=43875/asaad" }, {
            "Choose the legacy Cataclysm Heroic version; modern seasonal or Timewalking loot can differ.",
            "The pin marks the high platform entrance, not the final boss inside the dungeon.",
            "Observe heroic lockouts; ordinary trash resets do not reset a saved final boss.",
        }),
}
RegisterMaterial(52078, "Chaos Orb", "Dungeon Reagent", { "blacksmithing", "leatherworking", "tailoring" },
    "Tradeable reagent from Cataclysm heroic end bosses. Used by equipment, Dreamcloth, and housing recipes; old bind-on-pickup launch guides are outdated.", CHAOS_SPOTS)

local FIRELANDS_SPOTS = {
    Entrance("cataclysm-living-ember-firelands", 198, "Mount Hyjal", "Firelands raid entrance", 0.478, 0.778,
        "Kill Firelands raid bosses and loot Living Embers.", { ItemUrl(69237), RAID_ENTRANCES }, {
            "Living Ember is the tradeable crafting reagent; Eternal Ember is a different, bound legendary quest item.",
            "Boss loot and raid lockouts control this farm. A trash reset is not another boss-loot attempt.",
            "Keep bind-on-equip patterns and transmog drops; compare them with disenchant value before destroying gear.",
        }),
}
RegisterMaterial(69237, "Living Ember", "Raid Reagent", { "blacksmithing", "leatherworking", "tailoring", "alchemy" },
    "Tradeable Firelands boss reagent used in epic crafted gear and Cataclysm housing decor.", FIRELANDS_SPOTS)

local DRAGON_SOUL_SPOTS = {
    Entrance("cataclysm-essence-destruction-dragon-soul", 75, "Caverns of Time", "Dragon Soul portal inside the Caverns of Time", 0.622, 0.282,
        "Enter Dragon Soul and kill raid bosses for Essence of Destruction.", { ItemUrl(71998), RAID_ENTRANCES }, {
            "Travel to the Caverns of Time in Tanaris, then use the northeastern Dragon Soul portal beside End Time and Hour of Twilight.",
            "This pin uses the Caverns of Time map, not the outdoor Tanaris map or Northrend's Wyrmrest Temple.",
            "Legacy raid lockouts and the Spine encounter limit repetition; plan a full clear rather than trash resets.",
        }),
}
RegisterMaterial(71998, "Essence of Destruction", "Raid Reagent", { "blacksmithing", "leatherworking", "tailoring" },
    "Tradeable Dragon Soul raid reagent for the final tier of Cataclysm crafted armor.", DRAGON_SOUL_SPOTS)

local DISENCHANT_SPOTS = Copy(NS.MaterialFarmingSpots.items[52718].spots)
for _, spot in ipairs(DISENCHANT_SPOTS) do
    spot.isRoute = false
end
RegisterMaterial(52555, "Hypnotic Dust", "Enchanting", { "enchanting" },
    "Tradeable dust from disenchanting eligible Cataclysm uncommon equipment. Favor armor; input item level and scaling affect the result.", DISENCHANT_SPOTS)
RegisterMaterial(52720, "Small Heavenly Shard", "Enchanting", { "enchanting" },
    "Tradeable shard from eligible lower-tier Cataclysm rare equipment. Three small shards combine into one Heavenly Shard; do not treat all blue items as identical inputs.", Copy(DISENCHANT_SPOTS))
local CRYSTAL_SPOTS = Copy(FIRELANDS_SPOTS)
CRYSTAL_SPOTS[1].id = "cataclysm-maelstrom-crystal-firelands-disenchant"
CRYSTAL_SPOTS[1].farmAction = "Disenchant eligible Cataclysm epic boss equipment for Maelstrom Crystals."
CRYSTAL_SPOTS[1].sourceUrls = { ItemUrl(52722), RAID_ENTRANCES }
CRYSTAL_SPOTS[1].tips = {
    "Enchanting and suitable legacy epic equipment are required; the crystal is a disenchant result, not a guaranteed boss drop.",
    "Compare transmog and auction value before disenchanting bind-on-equip gear.",
    "Other Cataclysm raids and late Cataclysm heroic epics are alternatives; verify the scaled item still disenchants into Cataclysm materials.",
}
RegisterMaterial(52722, "Maelstrom Crystal", "Enchanting", { "enchanting" },
    "Tradeable Cataclysm epic disenchant material used in illusion tomes, enchants, and Twilight Fire Canister decor.", CRYSTAL_SPOTS)

local RAID_GEMS = {
    { 71805, "Queen's Garnet" }, { 71806, "Lightstone" }, { 71807, "Deepholm Iolite" },
    { 71808, "Lava Coral" }, { 71809, "Shadow Spinel" }, { 71810, "Elven Peridot" },
}
for _, gem in ipairs(RAID_GEMS) do
    local spots = Copy(DRAGON_SOUL_SPOTS)
    spots[1].id = "cataclysm-dragon-soul-geode-gem-" .. tostring(gem[1])
    spots[1].farmAction = "Kill Normal or Heroic Dragon Soul bosses, exchange their currencies with Dasnurimi, and open the geodes for gems."
    spots[1].sourceUrls = { ItemUrl(gem[1]), "https://warcraft.wiki.gg/wiki/Mote_of_Darkness" }
    spots[1].tips = {
        "Normal and Heroic boss currencies are the input; Raid Finder does not award Motes of Darkness.",
        "Crystalline Geodes can contain lower-quality gems. The epic color is random; no individual epic gem is guaranteed.",
        "The currencies are not Auction House products. Sell the resulting uncut epic gems or their learned cuts.",
    }
    RegisterMaterial(gem[1], gem[2], "Raid Gem", { "jewelcrafting" },
        "Tradeable epic gem obtained through Dragon Soul currency geodes; this is an instance-reward farm, not a mining-node route.", spots)
end

RegisterMaterial(61979, "Ashen Pigment", "Pigment", { "inscription" },
    "Tradeable Cataclysm milling output used to make Blackfallow Ink. Milling consumes existing herbs and has variable yields; this entry adds no herbalism route.")
RegisterMaterial(61980, "Burning Embers", "Pigment", { "inscription" },
    "Tradeable uncommon Cataclysm milling pigment used to make Inferno Ink. This is not Living Ember or the bound Eternal Ember.")

RegisterMaterial(251764, "Ashwood Lumber", "Bound Housing Lumber", { "miscellaneous" },
    "Warband-bound Cataclysm lumber for housing crafts. It cannot be sold on the Auction House; finished unlearned decor can be sold.", {
        {
            id = "cataclysm-ashwood-lumber-uldum-river-anchor",
            mapID = 249,
            mapName = "Uldum",
            location = "Ramkahen and the Virnaal riverbanks",
            routeType = "dynamic-lumber-area",
            density = "Dynamic tree spawns",
            isRoute = false,
            farmAction = "Scout the riverbanks for visible harvestable Ashwood trees.",
            source = "Retail lumber item and player reports comparing Cataclysm lumber areas",
            sourceUrls = { ItemUrl(251764), "https://us.forums.blizzard.com/en/wow/t/what-cataclysm-zones-are-best-for-lumber/2250131" },
            dropDifficulty = "Dynamic lumber nodes; this pin is an area access anchor, not a guaranteed tree.",
            tips = {
                "Complete the housing lumber introduction and unlock lumber gathering on this character first.",
                "Scout visible trees along the river; Twilight Highlands and Mount Hyjal are alternatives when phasing or competition interferes.",
                "Use Zidormi when Uldum's assault phase interferes with the older zone. Lumber stays bound; sell crafted decor instead.",
            },
            coords = { { x = 0.55, y = 0.32, label = "Ramkahen river access anchor" } },
            confidence = "medium",
        },
    }, { ItemUrl(251764) }, false)

-- Preserve the existing non-ore/non-herb farm geometry, while making its display
-- contract explicit. None of these materials should draw a gathering-route line.
local seenSpots = {}
for _, item in pairs(NS.MaterialFarmingSpots.items) do
    if item.expansion == "cataclysm" and item.category ~= "Ore" and item.category ~= "Herb" then
        item.isRoute = false
        for _, spot in ipairs(item.spots or {}) do
            spot.isRoute = false
            if not seenSpots[spot] and (item.itemID == 52976 or item.itemID == 52979 or item.itemID == 52980) then
                spot.tips = spot.tips or {}
                spot.tips[#spot.tips + 1] = "Strange Bloated Stomach is a bound skinning bonus. Open it for tradeable Volatiles; the unopened stomach cannot be auctioned."
                spot.sourceUrls = spot.sourceUrls or {}
                spot.sourceUrls[#spot.sourceUrls + 1] = ItemUrl(67495)
                seenSpots[spot] = true
            end
        end
    end
end
