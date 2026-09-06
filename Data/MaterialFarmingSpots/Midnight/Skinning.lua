local _, NS = ...
local Register = NS.RegisterMaterialFarmingSpot
local H = NS.MaterialFarmingSpotHelpers

Register(H.BuildMidnightItem(
    238511,
    "Void-Tempered Leather",
    { "skinning", "leatherworking" },
    "Leather",
    {
        "https://www.wowhead.com/item=238511/void-tempered-leather",
        "https://www.wow-professions.com/guides/wow-skinning-leveling-guide",
    },
    "Base Midnight leather from skinnable leather mobs. Use general skinning loops and high-value beast tracking.",
    H.MIDNIGHT_SKINNING_COMMON_SPOTS,
    1
))

Register(H.BuildMidnightItem(
    238512,
    "Void-Tempered Leather",
    { "skinning", "leatherworking" },
    "Leather",
    {
        "https://www.wowhead.com/item=238512/void-tempered-leather",
        "https://www.wow-professions.com/guides/wow-skinning-leveling-guide",
    },
    "High-quality Void-Tempered Leather. The same routes apply, with better results from skill, Finesse, and high-value beast tracking.",
    H.MIDNIGHT_SKINNING_COMMON_SPOTS,
    2
))

Register(H.BuildMidnightItem(
    238513,
    "Void-Tempered Scales",
    { "skinning", "leatherworking" },
    "Scale",
    {
        "https://www.wowhead.com/item=238513/void-tempered-scales",
        "https://www.wow-professions.com/guides/wow-skinning-leveling-guide",
    },
    "Base Midnight scales from scale mobs. Target wyrms, dragonhawks, and other scale-bearing beasts.",
    H.MIDNIGHT_SKINNING_SCALE_SPOTS,
    1
))

Register(H.BuildMidnightItem(
    238514,
    "Void-Tempered Scales",
    { "skinning", "leatherworking" },
    "Scale",
    {
        "https://www.wowhead.com/item=238514/void-tempered-scales",
        "https://www.wow-professions.com/guides/wow-skinning-leveling-guide",
    },
    "High-quality Void-Tempered Scales. Target scale-bearing beasts and high-value targets.",
    H.MIDNIGHT_SKINNING_SCALE_SPOTS,
    2
))

Register(H.BuildMidnightItem(
    238518,
    "Void-Tempered Hide",
    { "skinning", "leatherworking" },
    "Hide",
    {
        "https://www.wowhead.com/item=238518/void-tempered-hide",
        "https://www.method.gg/guides/midnight-skinning-profession-guide",
    },
    "Rare Midnight hide side gather from skinning. Sharpen Your Knife can guarantee hide or plating on the next corpse.",
    H.MIDNIGHT_SKINNING_COMMON_SPOTS
))

Register(H.BuildMidnightItem(
    238520,
    "Void-Tempered Plating",
    { "skinning", "leatherworking" },
    "Plating",
    {
        "https://www.wowhead.com/item=238520/void-tempered-plating",
        "https://www.method.gg/guides/midnight-skinning-profession-guide",
    },
    "Rare Midnight plating side gather from skinning scale mobs. Sharpen Your Knife can guarantee hide or plating on the next corpse.",
    H.MIDNIGHT_SKINNING_SCALE_SPOTS,
    1
))

Register(H.BuildMidnightItem(
    238521,
    "Void-Tempered Plating",
    { "skinning", "leatherworking" },
    "Plating",
    {
        "https://www.wowhead.com/item=238521/void-tempered-plating",
        "https://www.method.gg/guides/midnight-skinning-profession-guide",
    },
    "High-quality Void-Tempered Plating. Target scale mobs and use Sharpen Your Knife when you want rare side materials.",
    H.MIDNIGHT_SKINNING_SCALE_SPOTS,
    2
))

Register(H.BuildMidnightItem(
    238522,
    "Peerless Plumage",
    { "skinning", "leatherworking" },
    "Plumage",
    {
        "https://www.wowhead.com/item=238522/peerless-plumage",
        "https://www.method.gg/guides/where-to-farm-fantastic-fur-peerless-plumage-and-carving-canine",
        "https://us.forums.blizzard.com/en/wow/t/peerless-plumage-drop-rate/2263740",
    },
    "Species-specific Midnight skinning material from feathered or flying creatures. Reports suggest it can feel extremely rare without the right specialization.",
    H.MIDNIGHT_SPECIES_SKINNING_SPOTS
))

Register(H.BuildMidnightItem(
    238523,
    "Carving Canine",
    { "skinning", "leatherworking" },
    "Canine",
    {
        "https://www.wowhead.com/item=238523/carving-canine",
        "https://www.method.gg/guides/where-to-farm-fantastic-fur-peerless-plumage-and-carving-canine",
    },
    "Species-specific Midnight skinning material from fanged creatures such as cats, bears, and pangos.",
    H.MIDNIGHT_SPECIES_SKINNING_SPOTS
))

Register(H.BuildMidnightItem(
    238525,
    "Fantastic Fur",
    { "skinning", "leatherworking" },
    "Fur",
    {
        "https://www.wowhead.com/item=238525/fantastic-fur",
        "https://www.method.gg/guides/where-to-farm-fantastic-fur-peerless-plumage-and-carving-canine",
    },
    "Species-specific Midnight skinning material from furred creatures. Zul'Aman Kapara and Eversong bats/cats/bears are useful checks.",
    H.MIDNIGHT_SPECIES_SKINNING_SPOTS
))

Register(H.BuildMidnightItem(
    238528,
    "Majestic Claw",
    { "skinning", "leatherworking" },
    "Claw",
    {
        "https://www.wowhead.com/item=238528/majestic-claw",
        "https://www.wow-professions.com/guides/wow-skinning-leveling-guide",
    },
    "Majestic material from Renowned Beasts. This is lure-gated and luck-dependent, with better odds from Majestic Materials specialization investment.",
    H.MIDNIGHT_MAJESTIC_SKINNING_SPOTS
))

Register(H.BuildMidnightItem(
    238529,
    "Majestic Hide",
    { "skinning", "leatherworking" },
    "Hide",
    {
        "https://www.wowhead.com/item=238529/majestic-hide",
        "https://www.wow-professions.com/guides/wow-skinning-leveling-guide",
    },
    "Majestic material from Renowned Beasts. Several lure beasts can provide it, but the farm is daily/lure-limited and RNG heavy.",
    H.MIDNIGHT_MAJESTIC_SKINNING_SPOTS
))

Register(H.BuildMidnightItem(
    238530,
    "Majestic Fin",
    { "skinning", "leatherworking" },
    "Fin",
    {
        "https://www.wowhead.com/item=238530/majestic-fin",
        "https://www.wow-professions.com/guides/wow-skinning-leveling-guide",
    },
    "Majestic material from Renowned Beasts such as Lumenfin and Netherscythe.",
    H.MIDNIGHT_MAJESTIC_SKINNING_SPOTS
))
