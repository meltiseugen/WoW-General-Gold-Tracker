local _, NS = ...
local Register = NS.RegisterMaterialFarmingSpot
local H = NS.MaterialFarmingSpotHelpers

Register(H.BuildMidnightItem(
    243599,
    "Eversinging Dust",
    { "enchanting" },
    "Enchanting",
    {
        "https://www.wowhead.com/item=243599/eversinging-dust",
        "https://www.curseforge.com/wow/addons/disenchantvalue/files/7701600",
    },
    "Midnight enchanting material from disenchanting green-quality eligible gear.",
    H.MIDNIGHT_ENCHANTING_SPOTS,
    1
))

Register(H.BuildMidnightItem(
    243600,
    "Eversinging Dust",
    { "enchanting" },
    "Enchanting",
    {
        "https://www.wowhead.com/item=243600/eversinging-dust",
        "https://www.curseforge.com/wow/addons/disenchantvalue/files/7701600",
    },
    "High-quality Eversinging Dust from disenchanting eligible gear.",
    H.MIDNIGHT_ENCHANTING_SPOTS,
    2
))

Register(H.BuildMidnightItem(
    243602,
    "Radiant Shard",
    { "enchanting" },
    "Enchanting",
    {
        "https://www.wowhead.com/item=243602/radiant-shard",
        "https://warcraft.wiki.gg/wiki/Radiant_Shard",
    },
    "Midnight enchanting material from disenchanting rare-quality eligible gear.",
    H.MIDNIGHT_ENCHANTING_SPOTS,
    1
))

Register(H.BuildMidnightItem(
    243603,
    "Radiant Shard",
    { "enchanting" },
    "Enchanting",
    {
        "https://www.wowhead.com/item=243603/radiant-shard",
        "https://warcraft.wiki.gg/wiki/Radiant_Shard",
    },
    "High-quality Radiant Shard from disenchanting rare-quality eligible gear.",
    H.MIDNIGHT_ENCHANTING_SPOTS,
    2
))

Register(H.BuildMidnightItem(
    243605,
    "Dawn Crystal",
    { "enchanting" },
    "Enchanting",
    {
        "https://www.wowhead.com/item=243605/dawn-crystal",
        "https://www.wowhead.com/item=243606/dawn-crystal",
    },
    "Midnight enchanting crystal from disenchanting epic-quality eligible gear.",
    H.MIDNIGHT_ENCHANTING_SPOTS,
    1
))

Register(H.BuildMidnightItem(
    243606,
    "Dawn Crystal",
    { "enchanting" },
    "Enchanting",
    {
        "https://www.wowhead.com/item=243606/dawn-crystal",
        "https://www.curseforge.com/wow/addons/disenchantvalue/files/7701600",
    },
    "High-quality Dawn Crystal from disenchanting epic-quality eligible gear.",
    H.MIDNIGHT_ENCHANTING_SPOTS,
    2
))
