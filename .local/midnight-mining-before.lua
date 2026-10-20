local _, NS = ...
local Register = NS.RegisterMaterialFarmingSpot
local H = NS.MaterialFarmingSpotHelpers

Register(H.BuildMidnightItem(
    237359,
    "Refulgent Copper Ore",
    { "mining" },
    "Ore",
    {
        "https://www.wowhead.com/item=237359/refulgent-copper-ore",
        "https://www.wowhead.com/guide/midnight/professions/mining-overview-trainer-locations-ores-tools",
        "https://www.wow-professions.com/guides/wow-mining-leveling-guide",
    },
    "Common Midnight ore gathered from Refulgent Copper nodes and seams. Mine all node variants because rich, seam, and infused versions change both yield and skill gains.",
    H.MIDNIGHT_MINING_SPOTS,
    1
))

Register(H.BuildMidnightItem(
    237361,
    "Refulgent Copper Ore",
    { "mining" },
    "Ore",
    {
        "https://www.wowhead.com/item=237361/refulgent-copper-ore",
        "https://www.wowdb.com/items/237361-refulgent-copper-ore",
        "https://www.wowhead.com/guide/midnight/professions/mining-overview-trainer-locations-ores-tools",
    },
    "High-quality Refulgent Copper Ore. The same node routes apply, with better results from skill, Finesse, and route uptime.",
    H.MIDNIGHT_MINING_SPOTS,
    2
))

Register(H.BuildMidnightItem(
    237362,
    "Umbral Tin Ore",
    { "mining" },
    "Ore",
    {
        "https://www.wowhead.com/item=237362/umbral-tin-ore",
        "https://warcraft.wiki.gg/wiki/Umbral_Tin",
        "https://www.wowdb.com/spells/1225366-umbral-tin-seam",
    },
    "Midnight ore found across the new zones, with seams favoring caves and underground spaces. Useful to route through darker or enclosed areas.",
    H.MIDNIGHT_MINING_SPOTS,
    1
))

Register(H.BuildMidnightItem(
    237363,
    "Umbral Tin Ore",
    { "mining" },
    "Ore",
    {
        "https://www.wowhead.com/item=237363/umbral-tin-ore",
        "https://warcraft.wiki.gg/wiki/Umbral_Tin",
        "https://www.wowdb.com/spells/1225366-umbral-tin-seam",
    },
    "High-quality Umbral Tin Ore. Underground and cave-heavy routes are useful because Umbral Tin seams are associated with those spaces.",
    H.MIDNIGHT_MINING_SPOTS,
    2
))

Register(H.BuildMidnightItem(
    237364,
    "Brilliant Silver Ore",
    { "mining" },
    "Ore",
    {
        "https://www.wowhead.com/item=237364/brilliant-silver-ore",
        "https://www.wowhead.com/object=523298/brilliant-silver-seam",
        "https://www.wow-professions.com/guides/wow-mining-leveling-guide",
    },
    "Less common Midnight ore gathered from Brilliant Silver nodes and seams. Prioritize full loops over camping because replacement node rolls matter.",
    H.MIDNIGHT_MINING_SPOTS,
    1
))

Register(H.BuildMidnightItem(
    237365,
    "Brilliant Silver Ore",
    { "mining" },
    "Ore",
    {
        "https://www.wowhead.com/item=237365/brilliant-silver-ore",
        "https://www.wowdb.com/items/237365-brilliant-silver-ore",
        "https://www.wowhead.com/object=523298/brilliant-silver-seam",
    },
    "High-quality Brilliant Silver Ore. Better route uptime and mining skill are more reliable than waiting on a single node cluster.",
    H.MIDNIGHT_MINING_SPOTS,
    2
))

Register(H.BuildMidnightItem(
    237366,
    "Dazzling Thorium",
    { "mining" },
    "Ore",
    {
        "https://www.wowhead.com/item=237366/dazzling-thorium",
        "https://www.wowhead.com/guide/midnight/professions/mining-overview-trainer-locations-ores-tools",
    },
    "Rare mining side gather from Midnight ore nodes. Perception can increase bonus quantity when it appears, but does not make base ore routes unnecessary.",
    H.MIDNIGHT_MINING_SPOTS
))

Register(H.BuildMidnightItem(
    236949,
    "Mote of Light",
    { "mining", "herbalism", "alchemy", "skinning" },
    "Elemental",
    {
        "https://www.wowhead.com/item=236949/mote-of-light",
        "https://www.wowhead.com/guide/midnight/professions/mining-overview-trainer-locations-ores-tools",
        "https://www.wow-professions.com/guides/wow-herbalism-leveling-guide",
    },
    "Lightfused node and herb side material. Eversong is the primary route because Lightfused nodes are concentrated there.",
    H.MIDNIGHT_HERB_SPOTS
))

Register(H.BuildMidnightItem(
    236950,
    "Mote of Primal Energy",
    { "mining", "herbalism", "alchemy", "skinning" },
    "Elemental",
    {
        "https://www.wowhead.com/item=236950/mote-of-primal-energy",
        "https://www.wow-professions.com/guides/wow-herbalism-leveling-guide",
        "https://www.method.gg/guides/midnight-ore-and-mote-farming-route",
    },
    "Primal-infused node and herb side material. Harandar is the cleanest target zone.",
    H.MIDNIGHT_MINING_SPOTS
))

Register(H.BuildMidnightItem(
    236951,
    "Mote of Wild Magic",
    { "mining", "herbalism", "alchemy", "skinning" },
    "Elemental",
    {
        "https://www.wowhead.com/item=236951/mote-of-wild-magic",
        "https://www.wow-professions.com/guides/wow-herbalism-leveling-guide",
        "https://www.method.gg/guides/midnight-ore-and-mote-farming-route",
    },
    "Wild-infused node and herb side material. Zul'Aman is the main target zone.",
    H.MIDNIGHT_MINING_SPOTS
))

Register(H.BuildMidnightItem(
    236952,
    "Mote of Pure Void",
    { "mining", "herbalism", "alchemy", "skinning" },
    "Elemental",
    {
        "https://www.wowhead.com/item=236952/mote-of-pure-void",
        "https://www.wow-professions.com/guides/wow-herbalism-leveling-guide",
        "https://www.method.gg/guides/midnight-ore-and-mote-farming-route",
    },
    "Voidbound node and herb side material. Voidstorm is the main target zone.",
    H.MIDNIGHT_MINING_SPOTS
))
