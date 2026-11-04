local _, NS = ...

-- Retail AH mount additions, researched 2026-10-21. Each finished item was
-- checked against its current Retail tooltip; bound mounts are not cageable.
-- Map roles distinguish recipe sources, suppliers, entrances and area anchors.
local expansions = {
    [2] = { "burningCrusade", "The Burning Crusade" },
    [3] = { "wrath", "Wrath of the Lich King" },
    [4] = { "cataclysm", "Cataclysm" },
    [5] = { "mists", "Mists of Pandaria" },
    [6] = { "warlords", "Warlords of Draenor" },
    [7] = { "legion", "Legion" },
    [8] = { "battleForAzeroth", "Battle for Azeroth" },
    [11] = { "warWithin", "The War Within" },
}

local function P(x, y, label)
    return { x = x / 100, y = y / 100, label = label }
end

local function Map(mapID, name, label, role, pins)
    return {
        mapID = mapID, mapLabel = name, label = label, location = label,
        mapRole = role, pins = pins, isRoute = false,
        routeType = "farm-mount", confidence = "medium",
        density = "Named acquisition source or labelled access anchor",
        dropDifficulty = "Follow the source prerequisites; no hourly yield is assumed.",
    }
end

local function Mount(data)
    local guideLabels = {
        crafting = "Crafted mount",
        ["crafting-cooldown"] = "Crafting with a daily cooldown",
        ["garrison-mission"] = "Garrison follower mission",
        ["holiday-container"] = "Winter Veil reward container",
        ["component-assembly"] = "Combine crafted components",
    }
    data.guideLabel = guideLabels[data.acquisitionType]
    data.expansion = expansions[data.contentID][1]
    data.expansionLabel = expansions[data.contentID][2]
    data.auctionable = true
    data.saleMethod = "unlearned-item"
    data.researchedAt = "2026-10-21"
    data.tips[#data.tips + 1] = data.repeatability
    data.tips[#data.tips + 1] = "Keep the finished mount item unlearned to sell it. A learned mount cannot be caged or returned to an auctionable item."
    data.sourceUrls[#data.sourceUrls + 1] = "https://www.wowhead.com/item=" .. data.itemID
    data.sourceUrls[#data.sourceUrls + 1] = "https://nether.wowhead.com/tooltip/item/" .. data.itemID .. "?dataEnv=1&locale=0"
    return data
end

local rows = {}

for _, data in ipairs({
    { 34060, "Flying Machine", "Outland Engineering (1)" },
    { 34061, "Turbo-Charged Flying Machine", "Outland Engineering (75)" },
}) do
    rows[#rows + 1] = Mount {
        itemID = data[1], itemName = data[2], contentID = 2,
        acquisitionType = "crafting", profession = "engineering", useRequirement = data[3],
        requirement = "Train the Outland Engineering recipe from your faction's flying-machine trainer. The buyer must also meet " .. data[3] .. ".",
        action = "Learn the recipe, gather its components and craft the finished flying machine for sale.",
        repeatability = "Repeatable crafts while materials are available. The Turbo-Charged version consumes a Flying Machine as one of its components.",
        tips = { "Use the trainer for your faction. The pins mark trainers, not free mount vendors; older guides use obsolete combined Engineering skill numbers." },
        sourceUrls = {
            "https://www.warcraftmounts.com/crafted.php",
            "https://warcraft.wiki.gg/wiki/Niobe_Whizzlespark",
            "https://warcraft.wiki.gg/wiki/Jonathan_Garrett",
            "https://www.wowhead.com/npc=25099/jonathan-garrett",
        },
        mapOptions = {
            Map(104, "Shadowmoon Valley (Outland)", "Alliance recipe trainer - Niobe Whizzlespark", "recipe", {
                P(36.7, 54.9, "Niobe Whizzlespark - Alliance trainer in Wildhammer Stronghold"),
            }),
            Map(104, "Shadowmoon Valley (Outland)", "Horde recipe trainer - Jonathan Garrett", "recipe", {
                P(29, 28, "Jonathan Garrett - stables search anchor in Shadowmoon Village"),
            }),
        },
    }
end

for _, data in ipairs({
    { 41508, "Mechano-Hog", "Horde", "Horde Expedition", 41.4, 53.7, "Gara Skullcrush", "https://warcraft.wiki.gg/wiki/Gara_Skullcrush" },
    { 44413, "Mekgineer's Chopper", "Alliance", "Alliance Vanguard", 57.7, 66.5, "Logistics Officer Silverstone", "https://warcraft.wiki.gg/wiki/Logistics_Officer_Silverstone" },
}) do
    rows[#rows + 1] = Mount {
        itemID = data[1], itemName = data[2], contentID = 3,
        acquisitionType = "crafting", profession = "engineering", faction = data[3],
        requirement = "Use a " .. data[3] .. " Northrend engineer, reach Exalted with " .. data[4] .. " and buy the matching faction schematic.",
        action = "Learn the faction schematic, obtain the required motorcycle parts from Roxi Ramrocket and craft the finished motorcycle.",
        repeatability = "Repeatable crafts after the reputation and recipe unlocks; each craft consumes expensive components.",
        tips = { "The mount has faction restrictions. Roxi only sells the special parts to engineers who already know an eligible motorcycle schematic; recipe purchase and parts purchase are separate stops." },
        sourceUrls = {
            "https://www.warcraftmounts.com/crafted.php", data[8],
            "https://warcraft.wiki.gg/wiki/Roxi_Ramrocket",
        },
        mapOptions = {
            Map(114, "Borean Tundra", data[3] .. " schematic - " .. data[7], "recipe", {
                P(data[5], data[6], data[7] .. " - Exalted faction schematic"),
            }),
            Map(120, "The Storm Peaks", "Required motorcycle parts - Roxi Ramrocket", "supplier", {
                P(40.7, 84.8, "Roxi Ramrocket at K3 - learn the schematic before visiting"),
            }),
        },
    }
end

rows[#rows + 1] = Mount {
    itemID = 44554, itemName = "Flying Carpet", contentID = 3,
    acquisitionType = "crafting", profession = "tailoring", useRequirement = "Northrend Tailoring (1)",
    requirement = "Learn Northrend Tailoring and train Flying Carpet. The buyer also needs Northrend Tailoring (1), as shown in the current item tooltip.",
    action = "Train Flying Carpet from a Northrend tailoring trainer such as Charles Worth, then craft the finished carpet.",
    repeatability = "Repeatable crafts while materials are available; this is the ordinary Flying Carpet, not the bound Magnificent or Frosty variants.",
    tips = { "The pin is Charles Worth's shop in Northrend Dalaran. The item is tradeable, but its profession requirement limits eligible buyers." },
    sourceUrls = {
        "https://www.warcraftmounts.com/mount.php?mountid=193",
        "https://warcraft.wiki.gg/wiki/Charles_Worth",
    },
    mapOptions = { Map(125, "Dalaran (Northrend)", "Charles Worth - Flying Carpet recipe trainer", "recipe", {
        P(37.0, 33.2, "Charles Worth - Talismanic Textiles"),
    }) },
}

rows[#rows + 1] = Mount {
    itemID = 65891, itemName = "Vial of the Sands", contentID = 4,
    acquisitionType = "crafting", profession = "alchemy",
    requirement = "An alchemist must learn Recipe: Vial of the Sands from a Tol'vir Archaeology Canopic Jar; the bound recipe must be obtained on the crafter.",
    action = "Solve Tol'vir Archaeology artifacts for the recipe, obtain Yasmin's required components and craft Vial of the Sands for sale.",
    repeatability = "The recipe is an RNG archaeology unlock. Once learned, the finished mount can be crafted repeatedly when all components are available.",
    tips = { "The map marks the required supplier, not a guaranteed Canopic Jar dig site. Dig sites rotate; follow active Tol'vir sites in original Uldum. The finished mount does not require Alchemy to use." },
    sourceUrls = {
        "https://www.warcraftmounts.com/crafted.php",
        "https://www.wowhead.com/item=67538/recipe-vial-of-the-sands",
        "https://www.wowhead.com/npc=49406/yasmin",
    },
    mapOptions = { Map(249, "Uldum", "Yasmin - required Vial of the Sands components", "supplier", {
        P(26.62, 7.24, "Yasmin - Oasis of Vir'sar supplier, original Uldum phase"),
    }) },
}

for _, data in ipairs({
    {83088, "Jade Panther", "Honored"},
    {83089, "Sunstone Panther", "Honored"},
    {83087, "Ruby Panther", "Revered"},
    {83090, "Sapphire Panther", "Revered"},
    {82453, "Jeweled Onyx Panther", "Exalted"},
}) do
    rows[#rows + 1] = Mount {
        itemID = data[1], itemName = data[2], contentID = 5,
        acquisitionType = "crafting", profession = "jewelcrafting",
        requirement = "Learn Pandaria Jewelcrafting and reach " .. data[3] .. " with Order of the Cloud Serpent to buy this design from San Redscale.",
        action = data[1] == 82453
            and "Craft Jeweled Onyx Panther using one each of the Jade, Sunstone, Ruby and Sapphire Panthers. The four colored mounts are consumed."
            or "Buy the matching design, obtain the Orb of Mystery and other recipe reagents, then craft the finished panther for sale.",
        repeatability = "Repeatable crafts after learning the design. Price all consumed components before crafting; the finished mount has no Jewelcrafting requirement.",
        tips = { "The Big Keech pin is a documented patrol anchor in the original Vale phase. Check the nearby dried lakebed and use Zidormi if you are in the N'Zoth assault phase. Recent reports disagree on his presence, so confirm the supplier before committing materials." },
        sourceUrls = {
            "https://www.warcraftmounts.com/crafted.php",
            "https://warcraft.wiki.gg/wiki/San_Redscale",
            "https://warcraft.wiki.gg/wiki/Big_Keech",
            "https://www.wowhead.com/npc=61650/big-keech",
        },
        mapOptions = {
            Map(371, "The Jade Forest", "San Redscale - " .. data[3] .. " design", "recipe", {
                P(56.8, 44.4, "San Redscale - Order of the Cloud Serpent quartermaster"),
            }),
            Map(390, "Vale of Eternal Blossoms", "Orb of Mystery supplier - documented Big Keech patrol", "supplier", {
                P(70, 42, "Big Keech patrol search anchor - original Vale phase; check nearby"),
            }),
        },
    }
end

for _, data in ipairs({
    {87250, "Depleted-Kyparium Rocket", "Goblin"},
    {87251, "Geosynchronous World Spinner", "Gnomish"},
}) do
    rows[#rows + 1] = Mount {
        itemID = data[1], itemName = data[2], contentID = 5,
        acquisitionType = "crafting", profession = "engineering",
        requirement = "Use a Pandaria engineer with the " .. data[3] .. " Engineering specialization and train the matching rocket recipe.",
        action = "Visit Sally Fizzlefury to learn the matching specialization recipe, then craft the finished rocket from its required components.",
        repeatability = "Repeatable crafts after the profession and specialization unlock; buyers do not need Engineering to use the finished mount.",
        tips = { "The two rocket recipes require different Engineering specializations. Check your specialization before travelling to the trainer." },
        sourceUrls = {
            "https://www.warcraftmounts.com/crafted.php",
            "https://www.wowhead.com/npc=55143/sally-fizzlefury",
        },
        mapOptions = { Map(376, "Valley of the Four Winds", "Sally Fizzlefury - " .. data[3] .. " rocket recipe", "recipe", {
            P(16.06, 83.15, "Sally Fizzlefury - Nesingwary's Safari"),
        }) },
    }
end

rows[#rows + 1] = Mount {
    itemID = 95416, itemName = "Sky Golem", contentID = 5,
    acquisitionType = "crafting-cooldown", profession = "engineering",
    requirement = "Reach Pandaria Engineering 75, loot Schematic: Chief Engineer Jard's Journal from eligible Pandaria enemies and learn its recipes.",
    action = "Farm the journal if needed, make 30 Jard's Peculiar Energy Sources on their daily cooldown and combine them with 30 Living Steel to craft Sky Golem.",
    repeatability = "A new set of Jard's components takes 30 daily crafts per engineer; existing component stock can shorten the remaining wait.",
    tips = { "The Imperial Granary point is a reported recipe-farming anchor, not a guaranteed journal drop. Sky Golem's current tooltip limits mounted herb gathering to expansions before Dragonflight; do not advertise that benefit for newer zones." },
    sourceUrls = {
        "https://www.warcraftmounts.com/mount.php?mountid=438",
        "https://www.wowhead.com/item=100910/schematic-chief-engineer-jards-journal",
        "https://www.icy-veins.com/forums/topic/23145-gold-making-the-sky-golem/",
    },
    mapOptions = { Map(376, "Valley of the Four Winds", "Imperial Granary - reported journal farming area", "farming-area", {
        P(54, 63, "Imperial Granary area - reported journal drop from nearby enemies"),
    }) },
}

rows[#rows + 1] = Mount {
    itemID = 128311, itemName = "Coalfist Gronnling", contentID = 6,
    acquisitionType = "garrison-mission",
    requirement = "Develop a Draenor garrison and a follower roster able to run the rare item-level-675 Breaker Two mission with three followers.",
    action = "Check the Town Hall's follower mission table for Breaker Two, counter its threats and complete it for the Coalfist Gronnling reward.",
    repeatability = "The mission is a random rare offer, not a guaranteed daily. Check eligible characters; more kills at the map anchor do not produce this mount.",
    tips = { "The pins are named garrison access anchors, not exact mission-table or mount-drop pins. Use your Garrison Hearthstone and enter the Town Hall; layout changes with garrison tier." },
    sourceUrls = {
        "https://www.wowhead.com/guide/vanity-collections/mounts-from-the-garrison",
        "https://www.wowhead.com/mission=679/breaker-two",
        "https://www.wowhead.com/guide/world-events/holidays/hallows-end",
        "https://wow.gg/guides/coalfist-gronnling-mount-guide",
    },
    mapOptions = {
        Map(539, "Shadowmoon Valley (Draenor)", "Alliance - Lunarfall access anchor", "access", {
            P(29.6, 16.5, "Lunarfall garrison area - enter Town Hall for follower missions"),
        }),
        Map(525, "Frostfire Ridge", "Horde - Frostwall access anchor", "access", {
            P(47.0, 64.2, "Frostwall garrison area - enter Town Hall for follower missions"),
        }),
    },
}

rows[#rows + 1] = Mount {
    itemID = 128671, itemName = "Minion of Grumpus", contentID = 6,
    acquisitionType = "holiday-container",
    requirement = "During Feast of Winter Veil, use a level-3 Draenor garrison and complete its seasonal dailies. Check the in-game calendar for dates.",
    action = "Complete the garrison Winter Veil dailies in Frostfire Ridge, spend five Merry Supplies on a Savage Gift from Izzy Hollyfizzle and open it for a mount chance.",
    repeatability = "The seasonal dailies limit supplies per character. The gift is random; the Grumpus enemy does not directly drop the mount.",
    tips = { "Start and turn in the dailies in your own garrison. The outdoor Frostwall marker is an access anchor; the Lunarfall option marks Izzy inside the garrison." },
    sourceUrls = {
        "https://www.warcraftmounts.com/mounts/minionofgrumpus.php",
        "https://warcraft.wiki.gg/wiki/Izzy_Hollyfizzle",
        "https://www.wowhead.com/quest=39651/grumpus",
        "https://www.wowhead.com/guide/world-events/holidays/hallows-end",
    },
    mapOptions = {
        Map(525, "Frostfire Ridge", "Winter Veil daily quest area - not a direct mount drop", "quest-area", {
            P(46, 28, "Grumpus daily area - collect Merry Supplies, then buy Savage Gift"),
        }),
        Map(582, "Lunarfall", "Alliance - Izzy Hollyfizzle", "supplier", {
            P(44.3, 51.2, "Izzy Hollyfizzle - Savage Gift for five Merry Supplies"),
        }),
        Map(525, "Frostfire Ridge", "Horde - return to Frostwall and find Izzy", "access", {
            P(47.0, 64.2, "Frostwall access anchor - Izzy is inside your level-3 garrison"),
        }),
    },
}

rows[#rows + 1] = Mount {
    itemID = 137686, itemName = "Steelbound Harness", contentID = 7,
    acquisitionType = "crafting", profession = "blacksmithing",
    requirement = "Use a Legion blacksmith and learn Plans: Fel Core Hound Harness, dropped by Tichondrius in The Nighthold.",
    action = "Farm Tichondrius for the recipe if needed, then craft Steelbound Harness from 100 Demonsteel Bars, 50 Blood of Sargeras, 10 Infernal Brimstone and 10 Felhide.",
    repeatability = "The raid recipe has lockout-limited attempts. Subsequent crafts depend on materials, including the crafter's bound Blood of Sargeras.",
    tips = { "The map distinguishes the building access and underground raid portal. Enter on a difficulty that can award the recipe; the pin is not a surface Tichondrius spawn. The mount does not require Blacksmithing to use." },
    sourceUrls = {
        "https://www.wowhead.com/spell=213916/fel-core-hound-harness",
        "https://www.wowhead.com/guide/raid-entrances-of-legion-6034",
    },
    mapOptions = { Map(680, "Suramar", "The Nighthold - recipe source inside", "entrance", {
        P(46, 64.6, "Building access to Sanctum of Order"),
        P(44, 60, "Underground Nighthold portal - Tichondrius inside"),
    }) },
}

rows[#rows + 1] = Mount {
    itemID = 161134, itemName = "Mecha-Mogul Mk2", contentID = 8,
    acquisitionType = "crafting", profession = "engineering",
    requirement = "Use BfA Engineering and learn the Mecha-Mogul Mk2 schematic from Mogul Razdunk in Mythic The MOTHERLODE!!.",
    action = "Obtain the schematic and required engineering parts from The MOTHERLODE!!, then craft the finished mount for sale.",
    repeatability = "The schematic and some parts require eligible dungeon attempts; keep Engineering active when collecting profession-specific salvage.",
    tips = { "Choose the entrance for your faction. This is a crafted mount, not a direct boss mount drop, and buyers do not need Engineering." },
    sourceUrls = {
        "https://www.warcraftmounts.com/mount.php?mountid=961",
        "https://www.wow-professions.com/guides/bfa-engineering",
        "https://www.wowhead.com/guide/dungeon-entrances-wow-battle-for-azeroth",
    },
    mapOptions = {
        Map(862, "Zuldazar", "Alliance - The MOTHERLODE!! entrance", "entrance", {
            P(39.3, 71.4, "Alliance MOTHERLODE entrance - schematic and parts inside"),
        }),
        Map(862, "Zuldazar", "Horde - The MOTHERLODE!! entrance", "entrance", {
            P(56.1, 59.9, "Horde MOTHERLODE entrance - schematic and parts inside"),
        }),
    },
}

rows[#rows + 1] = Mount {
    itemID = 153594, itemName = "Xiwyllag ATV", contentID = 8,
    acquisitionType = "component-assembly", profession = "blacksmithing-engineering",
    requirement = "Obtain a Monelite Reinforced Chassis from BfA Blacksmithing and a Super-Charged Engine from BfA Engineering; their recipes drop from K.U.-J.0. in Operation: Mechagon.",
    action = "Craft or acquire both finished components and combine them into the Xiwyllag ATV mount item for sale.",
    repeatability = "Repeatable assembly when both components are available. You can source the other profession's part from another crafter or the AH.",
    tips = { "The map marks the dungeon recipe-source entrance. The chassis belongs to Blacksmithing and the engine to Engineering; the finished mount does not require either profession to ride." },
    sourceUrls = {
        "https://warcraft.wiki.gg/wiki/Xiwyllag_ATV",
        "https://www.wowhead.com/guide/operation-mechagon-megadungeon-loot",
        "https://www.wowhead.com/guide/battle-for-azeroth-dungeon-overview-6390",
    },
    mapOptions = { Map(1462, "Mechagon Island", "Operation: Mechagon - component recipes inside", "entrance", {
        P(73.0, 36.3, "Operation: Mechagon entrance - K.U.-J.0. component recipes"),
    }) },
}

rows[#rows + 1] = Mount {
    itemID = 221967, itemName = "Crowd Pummeler 2-30", contentID = 11,
    acquisitionType = "crafting", profession = "engineering",
    requirement = "Use Khaz Algar Engineering and discover the mount schematic through its Inventing/Scouring system.",
    action = "Unlock the schematic, obtain the required mount components through eligible engineering part pilfering, purchases or Paxton Bombshell, then craft the finished mount.",
    repeatability = "Repeatable crafts after discovering the schematic. Parts can be costly; compare current component costs before buying vendor stock.",
    tips = { "Paxton's coordinates changed with the Undermine update. Use the current 59.76, 78.43 Ringing Deeps location, not the older 63.8, 78.4 marker. The pin is a component supplier, not a mount drop." },
    sourceUrls = {
        "https://www.warcraftmounts.com/mount.php?mountid=1801",
        "https://www.wowhead.com/npc=223163/paxton-bombshell",
        "https://www.wowhead.com/item=227774/pummel-permit",
    },
    mapOptions = { Map(2214, "The Ringing Deeps", "Paxton Bombshell - Crowd Pummeler components", "supplier", {
        P(59.76, 78.43, "Paxton Bombshell - coordinates updated after Undermine"),
    }) },
}

NS.MountAcquisitionResearch = rows
