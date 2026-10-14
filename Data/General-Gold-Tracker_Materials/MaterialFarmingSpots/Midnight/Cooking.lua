local _, NS = ...
local Register = NS.RegisterMaterialFarmingSpot
local H = NS.MaterialFarmingSpotHelpers

Register(H.BuildMidnightItem(
    242639,
    "Practically Pork",
    { "cooking" },
    "Meat",
    {
        "https://www.wowhead.com/item=242639/practically-pork",
        "https://www.wow-professions.com/guides/wow-cooking-leveling-guide",
    },
    "Midnight meat drop from several beast families, with comments calling out Eversong beast packs around 56,46.",
    H.MIDNIGHT_COOKING_PORK_SPOTS
))

Register(H.BuildMidnightItem(
    242640,
    "Plant Protein",
    { "cooking" },
    "Cooking",
    {
        "https://www.wowhead.com/item=242640/plant-protein",
        "https://www.wow-professions.com/guides/wow-cooking-leveling-guide",
    },
    "Midnight cooking reagent from various creatures and fishing sources, best treated as a side target while doing waterline or beast loops.",
    H.MIDNIGHT_COOKING_PLANT_PROTEIN_SPOTS
))

Register(H.BuildMidnightItem(
    251285,
    "Petrified Root",
    { "cooking", "blacksmithing", "jewelcrafting", "leatherworking", "tailoring", "inscription", "enchanting", "alchemy" },
    "Reagent",
    {
        "https://www.wowhead.com/item=251285/petrified-root",
        "https://www.wow-professions.com/guides/wow-cooking-leveling-guide",
    },
    "Midnight reagent from delves, Prey rewards, dungeon completion, and reagent boxes. Shadowguard Point is the coordinate-backed delve anchor.",
    H.MIDNIGHT_COOKING_PETRIFIED_ROOT_SPOTS
))
