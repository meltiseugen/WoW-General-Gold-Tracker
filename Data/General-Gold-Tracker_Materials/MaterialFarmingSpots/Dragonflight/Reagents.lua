local _, NS = ...
local Register = NS.RegisterMaterialFarmingSpot

local function C(x, y, label)
    return { x = x, y = y, label = label }
end

local function ItemUrl(itemID)
    return "https://www.wowhead.com/item=" .. tostring(itemID)
end

local BEAR_SPINE_ROUTE = {
    id = "dragonflight-azure-span-primal-bear-spine",
    source = "Retail Wowhead Primal Bear Spine comments and Frigidpelt source pins",
    sourceUrls = {
        ItemUrl(201399),
        "https://www.wowhead.com/npc=193063/frigidpelt-matriarch",
        "https://www.wowhead.com/npc=193062/prowling-frigidpelt",
    },
    mapName = "The Azure Span",
    location = "Upper Frostlands Frigidpelt cave and nearby bear circuit",
    routeType = "rare-creature-reagent-loop",
    density = "Medium",
    dropDifficulty = "Low-frequency creature drop; expect many bear kills per spine.",
    tips = {
        "Reset around the Frigidpelt cave instead of crossing the full zone.",
        "Burly Bear Haunch, Maybe Meat, and skins provide side value.",
        "This is a cosmetic-vendor reagent, not cooking meat.",
    },
    coords = {
        C(0.6391, 0.2977, "Frigidpelt bear cave route"),
        C(0.6442, 0.3020, "Frigidpelt cave comment waypoint"),
        C(0.626, 0.308, "Western bear pack"),
    },
    confidence = "high",
}

local TALLSTRIDER_ROUTE = {
    id = "dragonflight-ohnahran-tallstrider-sinew",
    source = "Retail Wowhead Tallstrider Sinew comments and Swift Hornstrider source reports",
    sourceUrls = {
        ItemUrl(201404),
        "https://www.wowhead.com/npc=192093/swift-hornstrider",
    },
    mapName = "Ohn'ahran Plains",
    location = "Hornstrider circuits southwest of Rubyscale Outpost and around Pinewood Post",
    routeType = "rare-creature-reagent-loop",
    density = "Medium",
    dropDifficulty = "Very low drop rate. Recent reports place the long-run rate near a few percent.",
    tips = {
        "Start near 77,17 and sweep the compact hornstrider spawn cluster.",
        "Extend south toward Pinewood Post when waiting for the five-minute respawn cycle.",
        "The sinew is looted from kills, not from skinning; Maybe Meat and leather are side value.",
    },
    coords = {
        C(0.770, 0.170, "Rubyscale southwest hornstrider cluster"),
        C(0.770, 0.220, "Swift Hornstrider route"),
        C(0.780, 0.540, "Pinewood Post hornstriders"),
    },
    confidence = "high",
}

local PRIMAL_WOOL_ROUTE = {
    id = "dragonflight-ohnahran-primal-wool",
    source = "Retail Wowhead Tuft of Primal Wool comments and Wild Argali source reports",
    sourceUrls = {
        ItemUrl(201405),
        "https://www.wowhead.com/npc=191451/wild-argali",
    },
    mapName = "Ohn'ahran Plains",
    location = "Rusza'thar Reach argali and Cloverwood Hollow cliffhoof circuit",
    routeType = "rare-creature-reagent-loop",
    density = "Medium",
    dropDifficulty = "Uncommon creature drop with streaky reported results.",
    tips = {
        "Clear Wild Argali around Rusza'thar Reach first.",
        "Use the longer Cloverwood Hollow loop when the eastern pack is exhausted.",
        "Sell in cosmetic-vendor stack sizes rather than treating this as ordinary wool cloth.",
    },
    coords = {
        C(0.810, 0.365, "Rusza'thar Reach Wild Argali"),
        C(0.750, 0.470, "Pinewood river argali"),
        C(0.670, 0.580, "Cloverwood Hollow route start"),
        C(0.640, 0.710, "Cloverwood Hollow route turn"),
    },
    confidence = "high",
}

local MAGMA_SHELL_ROUTE = {
    id = "dragonflight-waking-shores-empty-magma-shell",
    source = "Retail Wowhead Empty Magma Shell, Magmashell, and Lavaslurper comments plus Blizzard's Dragonflight mount overview",
    sourceUrls = {
        ItemUrl(201883),
        "https://www.wowhead.com/item=192777/magmashell",
        "https://www.wowhead.com/npc=187297/lavaslurper",
        "https://www.wowhead.com/blue-tracker/news/us/dragonflight-mounts-pets-and-more-await-in-the-dragon-isles-23891317",
    },
    mapName = "The Waking Shores",
    location = "Western lava river Lavaslurper, Lava Slug, and Lava Snail circuit",
    routeType = "mount-reagent-creature-loop",
    density = "Localized",
    dropDifficulty = "Uncommon non-soulbound drop from lava creatures.",
    tips = {
        "Sweep the western lava river rather than camping the Empowered Snail mount-use location.",
        "The shell is auctionable and can be sold directly to mount collectors.",
        "The 71,25 lava pool is where buyers consume the shell, not the farm route.",
    },
    coords = {
        C(0.224, 0.677, "Western lava river Lavaslurpers"),
        C(0.2275, 0.7163, "Southern Lavaslurper pack"),
        C(0.2908, 0.7424, "Lava creature route extension"),
        C(0.330, 0.720, "Lava Slug pack"),
    },
    confidence = "high",
}

local OBSIDIAN_CITADEL_TOKEN_ROUTE = {
    id = "dragonflight-waking-shores-sargha-tokens",
    source = "Retail Wowhead Mark of Sargha and Sargha's Signet comments",
    sourceUrls = {
        ItemUrl(200224),
        ItemUrl(201991),
        "https://www.wowhead.com/guide/reputation/wrathion-sabellian-rewards",
    },
    mapName = "The Waking Shores",
    location = "Djaradin and elite circuit around the Obsidian Citadel",
    routeType = "reputation-token-creature-loop",
    density = "High",
    dropDifficulty = "Repeatable mob grind, but weekly allegiance and campaign progress control which token can be seen and turned in.",
    tips = {
        "Finish the Waking Shores campaign and choose a weekly allegiance before farming.",
        "Both tokens are tradeable and can be auctioned to players catching up reputation.",
        "Wrathion signets turn in near 26.6,62.4; Sabellian marks near 27.6,56.2.",
    },
    coords = {
        C(0.246, 0.578, "Obsidian Citadel western Djaradin"),
        C(0.282, 0.588, "Citadel central elite packs"),
        C(0.304, 0.620, "Citadel southern packs"),
        C(0.266, 0.624, "Wrathion turn-in and route reset"),
        C(0.276, 0.562, "Sabellian turn-in and northern route"),
    },
    confidence = "high",
}

local function RegisterReagent(itemID, itemName, category, spots, summary)
    Register({
        itemID = itemID,
        itemName = itemName,
        expansion = "dragonflight",
        professions = { "miscellaneous" },
        category = category,
        researchStatus = "researched",
        sourceUrls = { ItemUrl(itemID) },
        summary = summary,
        spots = spots,
    })
end

RegisterReagent(201399, "Primal Bear Spine", "Creature Reagent", { BEAR_SPINE_ROUTE }, "Auctionable Dragon Isles bear drop consumed by cosmetic vendors.")
RegisterReagent(201404, "Tallstrider Sinew", "Creature Reagent", { TALLSTRIDER_ROUTE }, "Auctionable hornstrider drop used as a currency for Dragon Isles cosmetics.")
RegisterReagent(201405, "Tuft of Primal Wool", "Creature Reagent", { PRIMAL_WOOL_ROUTE }, "Auctionable argali and musken drop used by Dragon Isles cosmetic vendors.")
RegisterReagent(201883, "Empty Magma Shell", "Mount Reagent", { MAGMA_SHELL_ROUTE }, "Auctionable creature drop consumed to unlock the Magmashell mount.")
RegisterReagent(200224, "Mark of Sargha", "Reputation Token", { OBSIDIAN_CITADEL_TOKEN_ROUTE }, "Tradeable Obsidian Citadel reputation token associated with Sabellian support.")
RegisterReagent(201991, "Sargha's Signet", "Reputation Token", { OBSIDIAN_CITADEL_TOKEN_ROUTE }, "Tradeable Obsidian Citadel reputation token associated with Wrathion support.")
