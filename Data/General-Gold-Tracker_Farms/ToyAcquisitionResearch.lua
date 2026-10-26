local _, NS = ...

-- Additional Retail AH toy outputs, reviewed 2026-10-21 against current item
-- tooltips. Coordinates use Retail UI maps. Recipe, quest, crafting and
-- optional-upgrade locations are labelled separately from direct toy drops.
local expansions = {
    [1] = { "classic", "Classic" }, [2] = { "burningCrusade", "The Burning Crusade" },
    [3] = { "wrath", "Wrath of the Lich King" }, [4] = { "cataclysm", "Cataclysm" },
    [5] = { "mists", "Mists of Pandaria" }, [6] = { "warlords", "Warlords of Draenor" },
    [7] = { "legion", "Legion" }, [8] = { "battleForAzeroth", "Battle for Azeroth" },
    [9] = { "shadowlands", "Shadowlands" }, [10] = { "dragonflight", "Dragonflight" },
    [11] = { "warWithin", "The War Within" }, [12] = { "midnight", "Midnight" },
}
local rows = {}
local minimumUseLevels = { [48933] = 24, [87215] = 29, [112059] = 34,
    [151652] = 39, [168807] = 45, [168808] = 45, [221966] = 68, [248485] = 78 }
local function Map(mapID, name, label, role, points)
    local pins = {}
    for _, point in ipairs(points) do
        pins[#pins + 1] = { x = point[1] / 100, y = point[2] / 100, label = point[3] }
    end
    return { mapID = mapID, mapLabel = name, label = label, location = label,
        mapRole = role, isRoute = false, routeType = "farm-toy", pins = pins,
        confidence = "medium", density = "Named acquisition source or labelled access point",
        dropDifficulty = "Follow the recipe or source prerequisites; no hourly yield is assumed." }
end
local function Add(data)
    data.expansion, data.expansionLabel = unpack(expansions[data.contentID])
    data.auctionable, data.saleMethod, data.researchedAt = true, "unlearned-item", "2026-10-21"
    data.minimumUseLevel = minimumUseLevels[data.itemID]
    data.acquisitionType = data.acquisitionType or "crafting"
    data.guideLabel = data.guideLabel or "Crafted toy"
    data.profession = data.profession or (data.acquisitionType == "crafting" and "engineering" or nil)
    data.repeatability = data.repeatability or "Repeatable crafts after learning the recipe; each sale item consumes its own materials."
    data.tips = data.tips or {}
    data.tips[#data.tips + 1] = data.repeatability
    data.tips[#data.tips + 1] = data.useRequirement and ("Using the toy requires " .. data.useRequirement
        .. (data.minimumUseLevel and (" and level " .. data.minimumUseLevel) or "") .. ". Check buyer eligibility; learning a toy and using it are separate requirements.")
        or "The current finished-item tooltip has no profession-use requirement. Crafting prerequisites still apply to the maker."
    data.tips[#data.tips + 1] = "Keep the finished toy item unlearned to sell it. Adding it to the Toy Box does not create an item you can resell."
    data.sourceUrls[#data.sourceUrls + 1] = "https://www.wowhead.com/item=" .. data.itemID
    data.sourceUrls[#data.sourceUrls + 1] = "https://nether.wowhead.com/tooltip/item/" .. data.itemID .. "?dataEnv=1&locale=0"
    for index, option in ipairs(data.mapOptions) do option.id = "ggt:toy:research:" .. data.itemID .. ":map:" .. index end
    rows[#rows + 1] = data
end

Add {
    itemID = 1973, itemName = "Orb of Deception", contentID = 1,
    acquisitionType = "world-drop", guideLabel = "Rare Classic world drop",
    requirement = "Farm eligible original Classic content. Blackwing Lair is one documented raid source; this is not a guaranteed boss reward.",
    action = "Clear original Blackwing Lair and loot its enemies, including Nefarian, for a very rare Orb of Deception chance alongside other loot.",
    repeatability = "Blackwing Lair uses a weekly raid lockout per character. Other original Classic world-drop sources may also award the toy.",
    tips = { "The pin marks Blackrock Mountain access to Blackwing Lair, not an outdoor Nefarian spawn. Enter the original raid, not Blackwing Descent. Old Dire Maul arena-rare advice predates Cataclysm source changes." },
    sourceUrls = { "https://warcraft.wiki.gg/wiki/Orb_of_Deception", "https://www.wowdb.com/items/1973-orb-of-deception", "https://us.forums.blizzard.com/en/wow/t/orb-of-deception/371254", "https://warcraft.wiki.gg/wiki/Blackwing_Lair" },
    mapOptions = { Map(36, "Burning Steppes", "Blackwing Lair access - original raid inside Blackrock Mountain", "entrance", {
        { 23.1, 26.3, "Blackrock Mountain / Blackwing Lair access - Nefarian inside" },
    }) },
}
Add {
    itemID = 18660, itemName = "World Enlarger", contentID = 1,
    useRequirement = "Classic Engineering (1) and Gnomish Engineer",
    requirement = "Use a Gnomish engineer and learn Schematic: World Enlarger (Classic Engineering 260), dropped by Weapon Technicians in original Blackrock Depths.",
    action = "Farm the Weapon Technicians in the Manufactory for the schematic if needed, then craft the finished World Enlarger.",
    tips = { "The map marks the original dungeon entrance. Inside, continue to the Manufactory; it is the schematic that drops, not the finished toy. Avoid the anniversary raid version." },
    sourceUrls = { "https://warcraft.wiki.gg/wiki/Schematic%3A_World_Enlarger", "https://www.wowhead.com/item=18661/schematic-world-enlarger", "https://wago.tools/db2/JournalInstanceEntrance/csv" },
    mapOptions = { Map(32, "Searing Gorge", "Blackrock Depths - schematic from Weapon Technicians inside", "entrance", {
        { 27.5518, 72.3785, "Original Blackrock Depths entrance inside Blackrock Mountain" },
    }) },
}
for _, data in ipairs({
    { 18984, "Dimensional Ripper - Everlook", 1, "Classic Engineering (260) and Goblin Engineer", "Zap Farflinger", 83, "Winterspring", 59.7, 49.8, "https://www.wowhead.com/npc=14742/zap-farflinger" },
    { 18986, "Ultrasafe Transporter: Gadgetzan", 1, "Classic Engineering (260) and Gnomish Engineer", "Jhordy Lapforge", 71, "Tanaris", 52.2, 27.8, "https://www.wowhead.com/spell=23489/ultrasafe-transporter-gadgetzan" },
    { 30542, "Dimensional Ripper - Area 52", 2, "Outland Engineering (50) and Goblin Engineer", "Kablamm Farflinger", 109, "Netherstorm", 32.95, 63.70, "https://www.wowhead.com/npc=21493/kablamm-farflinger" },
    { 30544, "Ultrasafe Transporter: Toshley's Station", 2, "Outland Engineering (50) and Gnomish Engineer", "Smiles O'Byron", 105, "Blade's Edge Mountains", 60, 65, "https://www.wowhead.com/spell=36955/ultrasafe-transporter-toshleys-station" },
}) do
    Add {
        itemID = data[1], itemName = data[2], contentID = data[3], useRequirement = data[4],
        requirement = "Meet " .. data[4] .. " and speak to " .. data[5] .. " by the transport pad to learn the recipe through the dialogue option.",
        action = "Learn the transport-device recipe from " .. data[5] .. ", then craft the finished toy for sale.",
        tips = { "The pin is the named recipe trainer. Select the engineering dialogue; these recipes may not appear as a normal purchasable schematic. Classic specialization skill is distinct from the Outland skill line. Everlook's older 61,38 coordinate belongs to the pre-Cataclysm map." },
        sourceUrls = { data[10], "https://www.wowhead.com/achievement=18855/portal-to-everywhere" },
        mapOptions = { Map(data[6], data[7], data[5] .. " - recipe dialogue", "recipe", { { data[8], data[9], data[5] .. " - transport-pad trainer" } }) },
    }
end
Add {
    itemID = 23767, itemName = "Crashin' Thrashin' Robot", contentID = 2,
    requirement = "Learn Schematic: Crashin' Thrashin' Robot with Outland Engineering (25). The schematic is a rare Burning Crusade world/instance drop and can also be traded.",
    action = "Obtain the schematic, then craft the finished robot from an Adamantite Frame, two Fel Iron Casings, a Gold Power Core and two Handfuls of Fel Iron Bolts.",
    tips = { "Black Temple is a documented schematic source, including Shadowmoon Weapon Masters. The entrance pin is a recipe-farming option, not a direct finished-toy drop. The finished robot is a Toy Box toy; it is separate from the controller toys." },
    sourceUrls = { "https://www.wowhead.com/item=23810/schematic-crashin-thrashin-robot", "https://www.wowhead.com/guide/raid-entrances-of-the-burning-crusade-6076" },
    mapOptions = { Map(104, "Shadowmoon Valley (Outland)", "Black Temple - rare schematic source inside", "entrance", { { 71.0, 46.2, "Black Temple entrance - schematic can drop from eligible enemies inside" } }) },
}
for _, data in ipairs({
    { 48933, "Wormhole Generator: Northrend", "Northrend Engineering (40)", "https://warcraft.wiki.gg/wiki/Wormhole_Generator%3A_Northrend" },
    { 40768, "MOLL-E", "Northrend Engineering (50)", "https://www.wowhead.com/spell=56472/moll-e" },
}) do
    Add {
        itemID = data[1], itemName = data[2], contentID = 3, useRequirement = data[3],
        requirement = "Level Northrend Engineering and learn the recipe from Timofey Oshenko in Northrend Dalaran. Check the current trainer's required crafting skill.",
        action = "Visit Like Clockwork in Northrend Dalaran, train the recipe and craft the finished toy.",
        tips = { "Use the Crystalsong Forest version of Dalaran (map 125). The similarly named Legion city and its trainers do not substitute for this recipe source." },
        sourceUrls = { data[4], "https://www.wowhead.com/npc=28697/timofey-oshenko" },
        mapOptions = { Map(125, "Dalaran (Northrend)", "Timofey Oshenko - Northrend recipe trainer", "recipe", { { 38, 25, "Like Clockwork shop - Timofey Oshenko, ground level" } }) },
    }
end
for _, data in ipairs({
    { 40727, "Gnomish Gravity Well", "Cataclysm Engineering (50) and Gnomish Engineer", "Train the recipe at Cataclysm Engineering (50) on a Gnomish engineer.", "https://www.wowhead.com/spell=95705/gnomish-gravity-well" },
    { 60854, "Loot-A-Rang", "Cataclysm Engineering (70)", "Train the recipe at Cataclysm Engineering (40); the user needs Cataclysm Engineering (70).", "https://www.wowhead.com/item=60854/loot-a-rang" },
}) do
    Add {
        itemID = data[1], itemName = data[2], contentID = 4, useRequirement = data[3], requirement = data[4],
        action = "Visit your faction's Cataclysm Engineering trainer, learn the recipe and craft the finished toy.",
        tips = { "Choose the trainer for your faction. Crafting and usage skill requirements can differ; the current expansion-specific tooltip takes precedence over old combined-skill guides. Gravity Well is a Cataclysm recipe despite its low item ID." },
        sourceUrls = { data[5], "https://warcraft.wiki.gg/wiki/Engineering_trainers" },
        mapOptions = {
            Map(84, "Stormwind City", "Alliance - Lilliam Sparkspindle", "recipe", { { 63.2, 31.5, "Lilliam Sparkspindle - Dwarven District Engineering trainer" } }),
            Map(85, "Orgrimmar", "Horde - Roxxik", "recipe", { { 56.8, 56.4, "Roxxik - Nogg's Machine Shop in the Drag" } }),
        },
    }
end
Add {
    itemID = 87215, itemName = "Wormhole Generator: Pandaria", contentID = 5, useRequirement = "Pandaria Engineering (1)",
    requirement = "Train Pandaria Engineering and level it sufficiently to learn Wormhole Generator: Pandaria from an eligible trainer such as Sally Fizzlefury.",
    action = "Visit Sally Fizzlefury at Nesingwary's Safari, learn the recipe, then craft the toy with 12 Trillium Bars and two Spirits of Harmony.",
    tips = { "The marker is Sally's current documented trainer position. The device's destination is unpredictable; this is an acquisition map, not a promised landing location." },
    sourceUrls = { "https://www.wowhead.com/spell=127132/wormhole-generator-pandaria", "https://www.wowhead.com/npc=55143/sally-fizzlefury" },
    mapOptions = { Map(376, "Valley of the Four Winds", "Sally Fizzlefury - recipe trainer", "recipe", { { 16.06, 83.15, "Sally Fizzlefury - Nesingwary's Safari" } }) },
}
local function DraenorRecipeMaps()
    return {
        Map(624, "Warspear", "Horde - Nik Steelrings, recipe vendor", "recipe", { { 70.37, 38.99, "Nik Steelrings - inside Gallywix's Garage" } }),
        Map(539, "Shadowmoon Valley (Draenor)", "Alliance - Lunarfall access, use Engineering Works vendor", "access", { { 29.6, 16.5, "Lunarfall access anchor - Zaren Hoffle is inside your Engineering Works" } }),
    }
end
for _, data in ipairs({
    { 109183, "World Shrinker", "Draenor Engineering (1)", "50 Gearspring Parts", "https://www.wowhead.com/item=118481/schematic-world-shrinker" },
    { 109167, "Findle's Loot-A-Rang", nil, "its Draenor Engineering components", "https://www.wowhead.com/item=118480/schematic-findles-loot-a-rang" },
    { 112059, "Wormhole Centrifuge", "Draenor Engineering (1)", "its Draenor Engineering components", "https://warcraft.wiki.gg/wiki/Wormhole_Centrifuge" },
}) do
    Add {
        itemID = data[1], itemName = data[2], contentID = 6, useRequirement = data[3],
        requirement = "Learn Draenor Engineering and purchase the matching schematic for one Secret of Draenor Engineering from an Engineering Works or Ashran plans vendor.",
        action = "Make the daily Secret if needed, buy and learn the schematic, then craft the finished toy using " .. data[4] .. ".",
        repeatability = "Recipe currency and Gearspring production use daily profession systems. After unlocking, craft additional sale items when components are available.",
        tips = { "Alliance can use Zaren Hoffle in its own Engineering Works or Sean Catchpole in Stormshield. Horde can use Nik Steelrings in Warspear or Pozzlow in its Engineering Works. The Lunarfall marker is an access area, not an exact building position; garrison layouts vary. Findle's toy works only in Draenor." },
        sourceUrls = { data[5], "https://www.icy-veins.com/wow/garrison-engineering-works-guide", "https://www.wowhead.com/spell=177054/secrets-of-draenor-engineering", "https://www.wowhead.com/guide/world-events/holidays/hallows-end" },
        mapOptions = DraenorRecipeMaps(),
    }
end
Add {
    itemID = 128807, itemName = "Coin of Many Faces", contentID = 6,
    acquisitionType = "holiday-drop", guideLabel = "Hallow's End enemy farm",
    requirement = "During Hallow's End, reach the Isle of Shadows in Draenor Shadowmoon Valley. Check the in-game calendar for current holiday dates.",
    action = "Kill and loot the seasonal Boneship skeleton enemies around the island for a Coin of Many Faces chance.",
    repeatability = "Repeated eligible enemy kills while the seasonal mobs are active; this is not a guaranteed daily-quest reward.",
    tips = { "The marker is a documented farming-area anchor, not one guaranteed toy spawn. Pick up nearby holiday dailies if useful, but do not confuse the daily reward with the random enemy drop." },
    sourceUrls = { "https://www.icy-veins.com/forums/topic/33674-gold-making-coin-of-many-faces/", "https://warcraft.wiki.gg/wiki/Culling_the_Crew" },
    mapOptions = { Map(539, "Shadowmoon Valley (Draenor)", "Isle of Shadows - seasonal skeleton farming area", "farming-area", { { 40, 83, "Boneship skeleton area during Hallow's End" } }) },
}
Add {
    itemID = 129956, itemName = "Leather Love Seat", contentID = 7, profession = "leatherworking",
    requirement = "Use Legion Leatherworking and buy Pattern: Leather Love Seat from Xur'ios for one Curious Coin. The pattern is bound; the finished toy is tradeable.",
    action = "Buy and learn the pattern, then craft the finished toy from 50 Stonehide Leather and 10 Felhide.",
    tips = { "The recipe is in Xur'ios's fixed stock. Farm eligible Legion content for the Curious Coin; this is a recipe purchase followed by crafting, not a direct toy vendor purchase." },
    sourceUrls = { "https://www.wowhead.com/item=137935/pattern-leather-love-seat", "https://warcraft.wiki.gg/wiki/Xur%27ios" },
    mapOptions = { Map(627, "Dalaran (Broken Isles)", "Xur'ios - Leather Love Seat pattern", "recipe", { { 48.8, 13.6, "Xur'ios - beside the bank near Antonidas Memorial" } }) },
}
Add {
    itemID = 132518, itemName = "Blingtron's Circuit Design Tutorial", contentID = 7,
    requirement = "Progress the Legion Engineering questline until Didi offers Short Circuit; earlier profession quests and dungeon prerequisites must be completed first.",
    action = "Complete Short Circuit in its marked order, borrowing Winkey's diving helmet before entering Gnopetto's underwater workshop. Learn the schematic from the journal, then craft the toy.",
    tips = { "The map options cover Didi and all six Short Circuit stops. These are quest/recipe locations. Once learned, the finished tutorial uses 50 Leystone Ore, 50 Felslate and five Infernal Brimstone. Buyers do not need Engineering for the minigame." },
    sourceUrls = { "https://www.wowhead.com/quest=40880/short-circuit", "https://www.wowhead.com/guide/legion-engineering", "https://www.wowhead.com/guide/the-ultimate-achievements-guide-professions-31332" },
    mapOptions = {
        Map(627, "Dalaran (Broken Isles)", "Quest start - Didi the Wrench", "quest", { { 38.82, 24.77, "Didi - progress Legion Engineering to Short Circuit" } }),
        Map(109, "Netherstorm", "Short Circuit step 1 - Rocket-Chief Fuselage", "quest", { { 32.68, 64.40, "1. Rocket-Chief Fuselage in Area 52" } }),
        Map(120, "The Storm Peaks", "Short Circuit step 2 - Ricket", "quest", { { 40.92, 85.32, "2. Ricket in K3" } }),
        Map(10, "Northern Barrens", "Short Circuit step 3 - Chief Engineer Foote", "quest", { { 67, 74.67, "3. Chief Engineer Foote - Broken Keel Tavern" } }),
        Map(71, "Tanaris", "Short Circuit steps 4-6 - Gadgetzan, Winkey, underwater workshop", "quest", {
            { 52.37, 28.31, "4. Nixx Sprocketspring in Gadgetzan" }, { 65.04, 63.54, "5. Winkey - borrow the diving helmet" },
            { 69.55, 68.44, "6. Gnopetto's underwater workshop - journal on the table" },
        }),
    },
}
Add {
    itemID = 151652, itemName = "Wormhole Generator: Argus", contentID = 7, useRequirement = "Legion Engineering (1)",
    requirement = "Unlock Argus through The Sigil of Awakening, then The Wrench Calls and Didi's Extraterrestrial Exploration quest.",
    action = "Take the Ionized Geographical Recorder to all five survey areas in Krokuun and Eredath, return to Didi for the schematic, then craft the toy from 30 Empyrium, two Loose Triggers and two Primal Sargerite.",
    tips = { "The five survey pins are documented quest areas; use the active quest markers to find the exact interaction range. Eredath is named Mac'Aree in older guides. These acquisition pins are not the wormhole's random landing positions." },
    sourceUrls = { "https://www.wowhead.com/quest=48065/extraterrestrial-exploration", "https://www.wowhead.com/quest=48069/the-wrench-calls", "https://www.wowhead.com/spell=247744/wormhole-generator-argus", "https://warcraft.wiki.gg/wiki/Didi_the_Wrench" },
    mapOptions = {
        Map(627, "Dalaran (Broken Isles)", "Didi - quest start and schematic turn-in", "quest", { { 38.82, 24.77, "Didi the Wrench - Like Clockwork" } }),
        Map(830, "Krokuun", "Extraterrestrial Exploration - three survey areas", "quest", {
            { 69.7, 67.7, "Petrified Forest reading area" }, { 61.1, 25.0, "Nath'raxas Hold reading area" }, { 32.9, 62.3, "Shattered Fields reading area" },
        }),
        Map(882, "Eredath", "Extraterrestrial Exploration - two survey areas", "quest", {
            { 57.1, 29.3, "Arinor Gardens reading area" }, { 43.9, 60.2, "Oronaar Collapse reading area" },
        }),
    },
}
for _, data in ipairs({ { 168807, "Wormhole Generator: Kul Tiras" }, { 168808, "Wormhole Generator: Zandalar" } }) do
    Add {
        itemID = data[1], itemName = data[2], contentID = 8, useRequirement = "Kul Tiran or Zandalari Engineering (1)",
        requirement = "Reach Battle for Azeroth Engineering (150) and unlock your faction's Nazjatar base profession trainer.",
        action = "Train the recipe from Instructor Alikana (Alliance) or Jada (Horde) in Nazjatar, then craft the finished generator.",
        tips = { "Both trainers teach both generator recipes. Choose your own faction's base. The device has an Engineering use requirement but its destination does not impose a matching faction restriction." },
        sourceUrls = { "https://www.icy-veins.com/wow/patch-8-2-engineering-profession-changes", "https://www.wowhead.com/npc=154321/jada", "https://www.wowhead.com/item=168808/wormhole-generator-zandalar" },
        mapOptions = {
            Map(1355, "Nazjatar", "Alliance - Instructor Alikana in Mezzamere", "recipe", { { 38.0, 53.6, "Instructor Alikana - unlock Mezzamere's profession trainers first" } }),
            Map(1355, "Nazjatar", "Horde - Jada in Newhome", "recipe", { { 49.1, 61.5, "Jada - Newhome profession trainer" } }),
        },
    }
end
Add {
    itemID = 172924, itemName = "Wormhole Generator: Shadowlands", contentID = 9, useRequirement = "Shadowlands Engineering (1)",
    requirement = "Reach Shadowlands Engineering (70) and Honored with The Undying Army; buy Schematic: Wormhole Generator: Shadowlands from a faction quartermaster.",
    action = "Buy the schematic from Dar Vattish in Oribos, learn it and craft the finished toy from its Shadowlands components.",
    tips = { "The map marks the schematic vendor, not a trainer recipe. Honored reputation and skill 70 apply to learning the recipe; buyers need only Shadowlands Engineering (1) to use the toy. Zone-specific destination unlocks are separate." },
    sourceUrls = { "https://www.wowhead.com/item=183858/schematic-wormhole-generator-shadowlands", "https://www.wow-professions.com/guides/shadowlands-engineering-guide", "https://warcraft-secrets.com/guides/hidden-toys" },
    mapOptions = { Map(1670, "Oribos", "Dar Vattish - Honored Undying Army schematic", "recipe", { { 47.8, 78.1, "Dar Vattish - Ring of Fates, main level" } }) },
}
for _, data in ipairs({
    { 198173, "Atomic Recalibrator", 10, "https://www.wowhead.com/spell=382408/atomic-recalibrator" },
    { 198206, "Environmental Emulator", 25, "https://www.wowhead.com/spell=382369/environmental-emulator" },
}) do
    Add {
        itemID = data[1], itemName = data[2], contentID = 10,
        requirement = "Unlock Mechanical Mind and invest " .. data[3] .. " points in its Novelties sub-specialization to learn the schematic; meet its displayed Dragon Isles Engineering crafting skill.",
        action = "Unlock the schematic in your profession tree and craft the toy at a Tinker's Workbench. The Valdrakken marker identifies the Engineering station area.",
        tips = { "The trainer helps you learn the profession but does not sell this specialization unlock. Atomic Recalibrator has a 12-hour use cooldown. Environmental Emulator needs Fiery and Earthen Souls among its reagents; use its complete recipe before committing materials." },
        sourceUrls = { data[4], "https://www.wowhead.com/npc=185548/clinkyclick-shatterboom", "https://www.wowhead.com/guide/dragonflight-toybox" },
        mapOptions = { Map(2112, "Valdrakken", "Engineering station - craft after specialization unlock", "crafting", { { 42.27, 48.74, "Clinkyclick Shatterboom / Engineering station area" } }) },
    }
end
Add {
    itemID = 198156, itemName = "Wyrmhole Generator: Dragon Isles", contentID = 10, useRequirement = "Dragon Isles Engineering (1)",
    requirement = "Unlock the recipe through the Dragon Isles Engineering Mechanical Mind specialization, then meet the recipe's crafting requirements.",
    action = "Craft the generator at a Tinker's Workbench. Optional: after reaching Novelties (30), activate all three Signal Transmitters in each desired zone to unlock that destination.",
    tips = { "Only the Valdrakken crafting stop is needed to make the sale item. The other options are labelled optional user upgrades, not required crafting materials or toy drops. Transmitter unlocks are per character. The Zaralek compass is another optional destination upgrade; do not advertise them as unlocked by buying the item." },
    sourceUrls = { "https://www.wowhead.com/item=198156/wyrmhole-generator-dragon-isles", "https://www.wowhead.com/spell=382367/wyrmhole-generator-dragon-isles", "https://www.wowhead.com/npc=185548/clinkyclick-shatterboom" },
    mapOptions = {
        Map(2112, "Valdrakken", "Crafting - Engineering station", "crafting", { { 42.27, 48.74, "Engineering station area - craft after recipe unlock" } }),
        Map(2022, "The Waking Shores", "Optional destination upgrade - three Signal Transmitters", "upgrade", { { 23.42, 43.84, "Waking Shores transmitter 1" }, { 74.62, 25.50, "Waking Shores transmitter 2" }, { 62.20, 78.90, "Waking Shores transmitter 3" } }),
        Map(2023, "Ohn'ahran Plains", "Optional destination upgrade - three Signal Transmitters", "upgrade", { { 67.68, 84.95, "Ohn'ahran transmitter 1" }, { 28.02, 35.67, "Ohn'ahran transmitter 2" }, { 56.87, 28.89, "Ohn'ahran transmitter 3" } }),
        Map(2024, "The Azure Span", "Optional destination upgrade - three Signal Transmitters", "upgrade", { { 71.05, 47.88, "Azure Span transmitter 1" }, { 45.76, 65.25, "Azure Span transmitter 2" }, { 27.56, 26.45, "Azure Span transmitter 3" } }),
        Map(2025, "Thaldraszus", "Optional destination upgrade - three Signal Transmitters", "upgrade", { { 70.30, 44.30, "Thaldraszus transmitter 1" }, { 63.67, 77.10, "Thaldraszus transmitter 2" }, { 50.74, 55.66, "Thaldraszus transmitter 3" } }),
        Map(2151, "The Forbidden Reach", "Optional destination upgrade - three Signal Transmitters", "upgrade", { { 31.82, 26.18, "Forbidden Reach transmitter 1" }, { 78.03, 51.11, "Forbidden Reach transmitter 2" }, { 39.99, 81.82, "Forbidden Reach transmitter 3" } }),
        Map(2133, "Zaralek Cavern", "Optional destination upgrade - Three-Dimensional Compass", "upgrade", { { 37.8, 58.8, "Busted Wyrmhole Generator - optional compass, Engineering 25" } }),
    },
}
for _, data in ipairs({ { 221966, "Wormhole Generator: Khaz Algar", "Khaz Algar Engineering (1)" }, { 221964, "Filmless Camera" } }) do
    Add {
        itemID = data[1], itemName = data[2], contentID = 11, useRequirement = data[3],
        requirement = "Learn Khaz Algar Engineering and discover the recipe through its Inventing, prototype disassembly and Scour Through Scrap system.",
        action = "Use the Khaz Algar discovery system to learn the toy recipe, then craft the finished item at an Engineering workbench.",
        repeatability = "Discovery is random; there is no guaranteed number of scrap attempts. Once learned, repeat crafts while materials are available.",
        tips = { "The Dornogal pin marks Thermalseer Arhdas and the workbench area, not an NPC selling the finished toy or a guaranteed discovery. Prototype: Filmless Camera is a discovery step; item 221964 is the finished sale item." },
        sourceUrls = { "https://www.wowhead.com/guide/the-war-within/professions/engineering-overview", "https://www.wowhead.com/npc=219099/thermalseer-arhdas", "https://erenion-gaming.de/berufe-in-the-war-within-ingenieurskunst/", "https://www.wowhead.com/item=221963/prototype-filmless-camera" },
        mapOptions = { Map(2339, "Dornogal", "Engineering trainer / workbench - discover and craft recipe", "crafting", { { 49, 56, "Thermalseer Arhdas - Engineering workbench area" } }) },
    }
end
Add {
    itemID = 248485, itemName = "Wormhole Generator: Quel'Thalas", contentID = 12, useRequirement = "Midnight Engineering (1)",
    requirement = "Learn Midnight Engineering, invest 10 points in Recycling to enable recipe discovery, then discover the wormhole recipe through Recycling.",
    action = "Recycle eligible Midnight crafted reagents until the schematic is discovered, then craft the finished generator at a Tinker's Workbench using three Piles of Junk, a Song Gear and an Evercore.",
    repeatability = "Recipe discovery is random. Once unlocked, additional generators can be crafted while components are available.",
    tips = { "The pin is the current Midnight Silvermoon Engineering area, not old Silvermoon. Danwe teaches the profession; Recycling supplies the schematic. The item also requires level 78 to use. Do not confuse this discovery system with The War Within's Inventing loop." },
    sourceUrls = { "https://www.wow-professions.com/midnight/engineering-guide", "https://www.method.gg/guides/midnight-engineering-profession-guide", "https://warcraft.wiki.gg/wiki/Wormhole_Generator%3A_Quel%27Thalas" },
    mapOptions = { Map(2393, "Silvermoon City (Midnight)", "Danwe / Engineering area - Recycling recipe discovery", "crafting", { { 43.36, 54.35, "Danwe - west side of the Bazaar, Midnight Silvermoon" } }) },
}

NS.ToyAcquisitionResearch = rows
