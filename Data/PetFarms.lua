local _, NS = ...

-- Curated Retail acquisition research for every visible Drops > Pets row.
-- Coordinates are normalized UI-map coordinates. Research reviewed 2026-10-08.

local outdoorByPetID = {
    [42] = { mapID = 25, sourceName = "Syndicate Spy", x = 0.488, y = 0.092 }, -- Black Tabby Cat
    [49] = { mapID = 50, sourceName = "Bloodscalp Warrior", x = 0.334, y = 0.354 }, -- Hyacinth Macaw
    [56] = { mapID = 15, sourceName = "Scalding Whelp", x = 0.770, y = 0.500 }, -- Dark Whelpling
    [57] = { mapID = 83, sourceName = "Young Frostsaber", x = 0.448, y = 0.154 }, -- Azure Whelpling
    [58] = { mapID = 56, sourceName = "Highland Lashtail", x = 0.672, y = 0.306 }, -- Crimson Whelpling
    [59] = { mapID = 69, sourceName = "Noxious Whelp", x = 0.462, y = 0.078 }, -- Emerald Whelpling
    [87] = { mapID = 69, sourceName = "Zukk'ash Wasp", x = 0.724, y = 0.628 }, -- Sprite Darter Hatchling
    [114] = { mapID = 51, sourceName = "Shifting Mireglob / Oozing Bag", x = 0.3505, y = 0.4282, kind = "container" },
    [146] = { mapID = 102, sourceName = "Bogflare Needler", x = 0.388, y = 0.376 }, -- Firefly
    [232] = { mapID = 70, sourceName = "Dart's Nest", x = 0.480, y = 0.142, kind = "nest" },
    [234] = { mapID = 121, sourceName = "Gundrak Raptor", x = 0.712, y = 0.184 },
    [235] = { mapID = 10, sourceName = "Takk's Nest", x = 0.655, y = 0.285, kind = "nest" },
    [237] = { mapID = 78, sourceName = "Ravasaur Matriarch's Nest", x = 0.690, y = 0.611, kind = "nest" },
    [238] = { mapID = 56, sourceName = "Razormaw Matriarch's Nest", x = 0.700, y = 0.292, kind = "nest" },
    [278] = { mapID = 245, sourceName = "Baradin Fox", x = 0.324, y = 0.464 },
    [279] = { mapID = 207, sourceName = "Jadefang", x = 0.612, y = 0.224, kind = "rare" },
    [834] = { mapID = 422, sourceName = "Karr the Darkener", x = 0.718, y = 0.374, kind = "rare" },
    [836] = { mapID = 422, sourceName = "Nalash Verdantis", x = 0.642, y = 0.584, kind = "rare" },
    [848] = { mapID = 407, sourceName = "Darkmoon Rabbit", x = 0.758, y = 0.782, kind = "world-boss" },
    [1178] = { mapID = 504, sourceName = "Haywire Sunreaver Construct", x = 0.482, y = 0.872, kind = "rare" },
    [1245] = { mapID = 504, sourceName = "Quivering Filth", x = 0.484, y = 0.804 },
    [1276] = { mapID = 407, sourceName = "Moonfang", x = 0.3945, y = 0.4389, kind = "world-boss" },
    [1323] = { mapID = 554, sourceName = "Leafmender", x = 0.672, y = 0.440, kind = "rare" },
    [1328] = { mapID = 554, sourceName = "Garnia", x = 0.650, y = 0.274, kind = "rare" },
    [1330] = { mapID = 554, sourceName = "Imperial Python", x = 0.308, y = 0.362 },
    [1333] = { mapID = 554, sourceName = "Jademist Dancer", x = 0.230, y = 0.292 },
    [1335] = { mapID = 554, sourceName = "Foreboding Flame", x = 0.448, y = 0.388 },
    [1336] = { mapID = 554, sourceName = "Zhu-Gon the Sour", x = 0.378, y = 0.772, kind = "event-rare" },
    [1337] = { mapID = 554, sourceName = "Monstrous Spineclaw", x = 0.174, y = 0.524, kind = "rare" },
    [1338] = { mapID = 554, sourceName = "Bufo", x = 0.620, y = 0.764, kind = "rare" },
    [1345] = { mapID = 554, sourceName = "Gu'chi the Swarmbringer", x = 0.302, y = 0.710, kind = "rare" },
    [1348] = { mapID = 554, sourceName = "Spirit of Jadefire", x = 0.440, y = 0.372, kind = "rare" },
    [1416] = { mapID = 535, sourceName = "Teroclaw Nest", x = 0.710, y = 0.320, kind = "nest" },
    [1428] = { mapID = 539, sourceName = "Darktide Husk / Reanimated Darktide Boneshell", x = 0.403, y = 0.777 },
    [1471] = { mapID = 525, sourceName = "Wiggling Egg", x = 0.640, y = 0.650, kind = "incubation" },
    [1524] = { mapID = 550, sourceName = "Netherspawn", x = 0.474, y = 0.702, kind = "rare" },
    [1537] = { mapID = 543, sourceName = "Strange Spore", x = 0.571, y = 0.655, kind = "treasure" },
    [1538] = { mapID = 539, sourceName = "Strange Spore", x = 0.562, y = 0.184, kind = "treasure" },
    [1540] = { mapID = 542, sourceName = "Rotcap", x = 0.382, y = 0.278, kind = "rare" },
    [1541] = { mapID = 542, sourceName = "Varasha's Egg", x = 0.294, y = 0.412, kind = "event" },
    [1563] = { mapID = 17, sourceName = "Ironmarch forces", x = 0.600, y = 0.134 },
    [1564] = { mapID = 543, sourceName = "Mandrakor", x = 0.504, y = 0.532, kind = "rare" },
    [1601] = { mapID = 539, sourceName = "Demidos", x = 0.460, y = 0.714, kind = "rare" },
    [1692] = { mapID = 534, sourceName = "Z'tenga the Walker", x = 0.552, y = 0.748, kind = "vendor" },
    [1764] = { mapID = 550, sourceName = "Rukdug", x = 0.262, y = 0.342, kind = "rare" },
    [1765] = { mapID = 550, sourceName = "Guk", x = 0.238, y = 0.379, kind = "rare" },
    [1766] = { mapID = 550, sourceName = "Pugg", x = 0.285, y = 0.303, kind = "rare" },
}

local raidByFarmID = {
    KarazhanPets = { instance = "Karazhan", mapID = 42, mapLabel = "Deadwind Pass", x = 0.469, y = 0.747, guide = "https://www.wowhead.com/guide/raid-entrances-of-the-burning-crusade-6076" },
    SerpentShrineCavernPets = { instance = "Serpentshrine Cavern", mapID = 102, mapLabel = "Zangarmarsh", x = 0.504, y = 0.409, guide = "https://www.wowhead.com/guide/raid-entrances-of-the-burning-crusade-6076" },
    TempestKeepPets = { instance = "Tempest Keep", mapID = 109, mapLabel = "Netherstorm", x = 0.736, y = 0.637, guide = "https://www.wowhead.com/guide/raid-entrances-of-the-burning-crusade-6076" },
    BlackTemplePets = { instance = "Black Temple", mapID = 104, mapLabel = "Shadowmoon Valley (Outland)", x = 0.710, y = 0.462, guide = "https://www.wowhead.com/guide/raid-entrances-of-the-burning-crusade-6076" },
    HyjalSummitPets = { instance = "The Battle for Mount Hyjal", mapID = 71, mapLabel = "Tanaris", x = 0.645, y = 0.500, guide = "https://www.wowhead.com/guide/raid-entrances-of-the-burning-crusade-6076" },
    SunwellPlateauPets = { instance = "Sunwell Plateau", mapID = 122, mapLabel = "Isle of Quel'Danas", x = 0.443, y = 0.456, guide = "https://www.wowhead.com/guide/raid-entrances-of-the-burning-crusade-6076" },
    IceCrownCitidelPets = { instance = "Icecrown Citadel", mapID = 118, mapLabel = "Icecrown", x = 0.539, y = 0.864, guide = "https://www.wowhead.com/guide/raid-entrances-of-wrath-of-the-lich-king-6075" },
    TrialoftheCrusaderPets = { instance = "Trial of the Crusader", mapID = 118, mapLabel = "Icecrown", x = 0.751, y = 0.218, guide = "https://www.wowhead.com/guide/raid-entrances-of-wrath-of-the-lich-king-6075" },
    UlduarPets = { instance = "Ulduar", mapID = 120, mapLabel = "The Storm Peaks", x = 0.416, y = 0.178, guide = "https://www.wowhead.com/guide/raid-entrances-of-wrath-of-the-lich-king-6075" },
    NaxxramasPets = { instance = "Naxxramas", mapID = 115, mapLabel = "Dragonblight", x = 0.873, y = 0.509, guide = "https://www.wowhead.com/guide/raid-entrances-of-wrath-of-the-lich-king-6075" },
    ThroneofTheFourWindsPets = { instance = "Throne of the Four Winds", mapID = 249, mapLabel = "Uldum", x = 0.384, y = 0.805, guide = "https://www.wowhead.com/guide/raid-entrances-of-cataclysm-6071" },
    BastionofTwilightPets = { instance = "The Bastion of Twilight", mapID = 241, mapLabel = "Twilight Highlands", x = 0.349, y = 0.780, guide = "https://www.wowhead.com/guide/raid-entrances-of-cataclysm-6071" },
    FirelandsPets = { instance = "Firelands", mapID = 198, mapLabel = "Mount Hyjal", x = 0.473, y = 0.780, guide = "https://www.wowhead.com/guide/raid-entrances-of-cataclysm-6071" },
    DragonSoulPets = { instance = "Dragon Soul", mapID = 71, mapLabel = "Tanaris", x = 0.622, y = 0.282, guide = "https://www.wowhead.com/guide/raid-entrances-of-cataclysm-6071" },
    BlackwingDecentPets = { instance = "Blackwing Descent", mapID = 36, mapLabel = "Burning Steppes", x = 0.229, y = 0.268, guide = "https://www.wowhead.com/guide/raid-entrances-of-cataclysm-6071" },
    MogushanVaultsPets = { instance = "Mogu'shan Vaults", mapID = 379, mapLabel = "Kun-Lai Summit", x = 0.597, y = 0.390, guide = "https://www.wowhead.com/guide/raid-entrances-mists-of-pandaria" },
    TerraceofEndlessSpringPets = { instance = "Terrace of Endless Spring", mapID = 433, mapLabel = "The Veiled Stair", x = 0.486, y = 0.616, guide = "https://www.wowhead.com/guide/raid-entrances-mists-of-pandaria" },
    HeartofFearPets = { instance = "Heart of Fear", mapID = 422, mapLabel = "Dread Wastes", x = 0.392, y = 0.349, guide = "https://www.wowhead.com/guide/raid-entrances-mists-of-pandaria" },
    ThroneofThunderPets = { instance = "Throne of Thunder", mapID = 504, mapLabel = "Isle of Thunder", x = 0.634, y = 0.326, guide = "https://www.wowhead.com/guide/raid-entrances-mists-of-pandaria" },
    SiegeofOrgrimmarPets = { instance = "Siege of Orgrimmar", mapID = 390, mapLabel = "Vale of Eternal Blossoms", x = 0.723, y = 0.445, guide = "https://www.wowhead.com/guide/raid-entrances-mists-of-pandaria" },
    HellfireCitidelPets = { instance = "Hellfire Citadel", mapID = 534, mapLabel = "Tanaan Jungle", x = 0.470, y = 0.527, guide = "https://www.wowhead.com/zone=7545/hellfire-citadel" },
    EmeraldNightmarePets = { instance = "The Emerald Nightmare", mapID = 641, mapLabel = "Val'sharah", x = 0.571, y = 0.399, guide = "https://www.wowhead.com/guide/raid-entrances-of-legion-6034" },
    BattleofDazaralorPets = { instance = "Battle of Dazar'alor", mapID = 1161, mapLabel = "Boralus", x = 0.703, y = 0.353, guide = "https://www.wowhead.com/guide/raid-entrances-in-wow-battle-for-azeroth" },
    EternalPalacePets = { instance = "The Eternal Palace", mapID = 1355, mapLabel = "Nazjatar", x = 0.500, y = 0.119, guide = "https://www.wowhead.com/guide/raid-entrances-in-wow-battle-for-azeroth" },
    NyalothaWakingCityPets = { instance = "Ny'alotha, the Waking City", mapID = 1527, mapLabel = "Uldum", x = 0.560, y = 0.480, alternate = { mapID = 1530, mapLabel = "Vale of Eternal Blossoms", x = 0.330, y = 0.440 }, guide = "https://www.wowhead.com/guide/raid-entrances-in-wow-battle-for-azeroth" },
    AhnQiraj = { instance = "Temple of Ahn'Qiraj", mapID = 81, mapLabel = "Silithus", x = 0.466, y = 0.075, guide = "https://warcraft.wiki.gg/wiki/Temple_of_Ahn%27Qiraj" },
    BlackwingLairRaid = { instance = "Blackwing Lair", mapID = 36, mapLabel = "Burning Steppes", x = 0.231, y = 0.263, guide = "https://warcraft.wiki.gg/wiki/Blackwing_Lair" },
    MoltenCoreRaid = { instance = "Molten Core", mapID = 36, mapLabel = "Burning Steppes", x = 0.208, y = 0.385, guide = "https://warcraft.wiki.gg/wiki/Molten_Core" },
}

local function BossResearch(name, encounterID, mapID, x, y)
    return { name = name, encounterID = encounterID, mapID = mapID, x = x, y = y }
end

-- Boss sources are verified against Warcraft Wiki's Raiding with Leashes
-- tables and individual post-Pandaria pet pages. Interior coordinates are
-- from Blizzard's JournalEncounterXMapLoc DB2 table (Retail snapshot).
local bossResearchByPetID = {
    [1143] = BossResearch("Maexxna", 1603, 163, 0.686466, 0.152964),
    [1144] = BossResearch("Loatheb", 1606, 165, 0.760165, 0.283523),
    [1146] = BossResearch("Gluth", 1612, 162, 0.462924, 0.438272),
    [1177] = BossResearch("Sand Elemental trash"),
    [1183] = BossResearch("Dark Animus", 824, 512, 0.426558, 0.576073),
    [1200] = BossResearch("Horridon", 819, 509, 0.268397, 0.787498),
    [1202] = BossResearch("Ji-Kun", 828, 511, 0.493506, 0.415584),
    [1226] = BossResearch("Big Bad Wolf", 1556, 353, 0.181023, 0.350770),
    [1227] = BossResearch("The Curator", 1557, 358, 0.494869, 0.366155),
    [1228] = BossResearch("Prince Malchezaar", 1563, 366, 0.514356, 0.309231),
    [1229] = BossResearch("Terestian Illhoof", 1560, 360, 0.525638, 0.696924),
    [1230] = BossResearch("Morogrim Tidewalker", 1571, 332, 0.596410, 0.260001),
    [1231] = BossResearch("Hydross the Unstable", 1567, 332, 0.363590, 0.847692),
    [1232] = BossResearch("Lady Vashj", 1572, 332, 0.722563, 0.589231),
    [1233] = BossResearch("Void Reaver", 1574, 334, 0.264075, 0.490686),
    [1234] = BossResearch("High Astromancer Solarian", 1575, 334, 0.740000, 0.489230),
    [1235] = BossResearch("Al'ar", 1573, 334, 0.501026, 0.587692),
    [1243] = BossResearch("Primordius", 820, 512, 0.572632, 0.782899),
    [1244] = BossResearch("Primordius", 820, 512, 0.572632, 0.782899),
    [1322] = BossResearch("Siegecrafter Blackfuse", 865, 565, 0.587888, 0.465288),
    [1331] = BossResearch("Sha of Pride", 867, 558, 0.293451, 0.669129),
    [1332] = BossResearch("Sha of Pride", 867, 558, 0.293451, 0.669129),
    [1334] = BossResearch("Paragons of the Klaxxi", 853, 566, 0.683407, 0.353028),
    [1622] = BossResearch("Azgalor", 1580, 329, 0.357436, 0.378461),
    [1623] = BossResearch("High Warlord Naj'entus", 1582, 340, 0.439487, 0.187651),
    [1624] = BossResearch("Supremus", 1583, 339, 0.663076, 0.473846),
    [1625] = BossResearch("Reliquary of Souls", 1587, 342, 0.613844, 0.850768),
    [1626] = BossResearch("Reliquary of Souls", 1587, 342, 0.613844, 0.850768),
    [1627] = BossResearch("Reliquary of Souls", 1587, 342, 0.613844, 0.850768),
    [1628] = BossResearch("Mother Shahraz", 1588, 344, 0.675383, 0.367691),
    [1629] = BossResearch("Anetheron", 1578, 329, 0.085641, 0.681538),
    [1631] = BossResearch("Archimonde", 1581, 329, 0.772820, 0.283076),
    [1632] = BossResearch("Brutallus", 1592, 335, 0.658973, 0.864615),
    [1633] = BossResearch("M'uru", 1595, 336, 0.467180, 0.238462),
    [1634] = BossResearch("Eredar Twins", 1594, 335, 0.641566, 0.321000),
    [1672] = BossResearch("Shadow-Lord Iskar", 1433, 666, 0.401112, 0.761434),
    [1723] = BossResearch("Dragons of Nightmare", 1704, 781, 0.369455, 0.479087),
    [1952] = BossResearch("Icehowl", 1618, 172, 0.511514, 0.527373),
    [1953] = BossResearch("Icehowl", 1618, 172, 0.511514, 0.527373),
    [1954] = BossResearch("Anub'arak", 1623, 173, 0.532546, 0.355289),
    [1955] = BossResearch("Ignis the Furnace Master", 1638, 147, 0.383365, 0.266253),
    [1956] = BossResearch("Razorscale", 1639, 147, 0.545846, 0.264819),
    [1957] = BossResearch("Assembly of Iron", 1641, 148, 0.156955, 0.564406),
    [1958] = BossResearch("Auriaya", 1643, 149, 0.512595, 0.571575),
    [1959] = BossResearch("Hodir", 1644, 149, 0.670380, 0.638974),
    [1960] = BossResearch("Freya", 1646, 149, 0.533669, 0.228841),
    [1961] = BossResearch("Mimiron", 1647, 151, 0.436196, 0.412397),
    [1962] = BossResearch("Yogg-Saron", 1649, 150, 0.683763, 0.399364),
    [1963] = BossResearch("Lord Marrowgar", 1624, 186, 0.391055, 0.593338),
    [1964] = BossResearch("Deathbringer Saurfang", 1628, 188, 0.515422, 0.216060),
    [1965] = BossResearch("Professor Putricide", 1631, 190, 0.131101, 0.532982),
    [1966] = BossResearch("Sindragosa", 1635, 189, 0.366325, 0.231898),
    [1967] = BossResearch("The Lich King", 1636, 192, 0.499296, 0.528743),
    [1968] = BossResearch("The Lich King", 1636, 192, 0.499296, 0.528743),
    [2078] = BossResearch("Omnotron Defense System", 169, 285, 0.654691, 0.574850),
    [2079] = BossResearch("Maloriak", 173, 286, 0.714572, 0.702096),
    [2080] = BossResearch("Nefarian", 174, 286, 0.480040, 0.702096),
    [2081] = BossResearch("Valiona and Theralion", 157, 294, 0.539920, 0.784431),
    [2082] = BossResearch("Ascendant Council", 158, 295, 0.425150, 0.455090),
    [2083] = BossResearch("Cho'gall", 167, 295, 0.734532, 0.754491),
    [2084] = BossResearch("Al'Akir", 155, 328, 0.475050, 0.500000),
    [2085] = BossResearch("Conclave of Wind", 154, 328, 0.475050, 0.260479),
    [2086] = BossResearch("Shannox", 195, 367, 0.493013, 0.443113),
    [2087] = BossResearch("Beth'tilac", 192, 367, 0.210579, 0.327844),
    [2088] = BossResearch("Baleroc", 196, 367, 0.495010, 0.309880),
    [2090] = BossResearch("Yor'sahj the Unsleeping", 325, 411, 0.468265, 0.499295),
    [2091] = BossResearch("Spine of Deathwing", 318, 414, 0.332117, 0.852587),
    [2092] = BossResearch("Madness of Deathwing", 333, 415, 0.478702, 0.538485),
    [2527] = BossResearch("Conclave of the Chosen", 2330, 1354, 0.475405, 0.675430),
    [2528] = BossResearch("Conclave of the Chosen", 2330, 1354, 0.475405, 0.675430),
    [2529] = BossResearch("Conclave of the Chosen", 2330, 1354, 0.475405, 0.675430),
    [2579] = BossResearch("Stone Guard", 679, 471, 0.459311, 0.641202),
    [2580] = BossResearch("Gara'jal the Spiritbinder", 682, 472, 0.778662, 0.344856),
    [2581] = BossResearch("Elegon", 726, 473, 0.207037, 0.511502),
    [2582] = BossResearch("Will of the Emperor", 677, 473, 0.688421, 0.819389),
    [2583] = BossResearch("Tsulong", 742, 456, 0.690121, 0.493234),
    [2584] = BossResearch("Lei Shi", 729, 456, 0.538566, 0.493234),
    [2585] = BossResearch("Imperial Vizier Zor'lok", 745, 474, 0.690122, 0.744926),
    [2586] = BossResearch("Blade Lord Ta'yak", 744, 474, 0.600812, 0.196888),
    [2587] = BossResearch("Garalon", 713, 475, 0.665428, 0.167832),
    [2589] = BossResearch("Amber-Shaper Un'sok", 737, 475, 0.441137, 0.736806),
    [2590] = BossResearch("Grand Empress Shek'zeer", 743, 475, 0.267930, 0.736807),
    [2680] = BossResearch("Queen Azshara", 2361, 1520, 0.481735, 0.518265),
    [2692] = BossResearch("Lady Ashvane", 2354, 1513, 0.477169, 0.682648),
    [2694] = BossResearch("Blackwater Behemoth", 2347, 1514, 0.356926, 0.198630),
    [2696] = BossResearch("Za'qul", 2349, 1519, 0.177321, 0.511416),
    [2832] = BossResearch("Maut", 2365, 1581, 0.192402, 0.608455),
    [2833] = BossResearch("Ra-den the Despoiled", 2364, 1591, 0.642297, 0.681357),
    [2834] = BossResearch("The Hivemind", 2372, 1590, 0.503677, 0.538603),
    [2835] = BossResearch("The Hivemind", 2372, 1590, 0.503677, 0.538603),
    [2836] = BossResearch("N'Zoth the Corruptor", 2375, 1597, 0.481618, 0.261029),
}

-- The imported WIT snapshot accidentally stored ordinary raid loot under three
-- Classic pet farms. Replace those collateral rows with the actual
-- Raiding-with-Leashes pets so every visible Pets row has pet identity.
local classicRaidPetRows = {
    { farmID = "MoltenCoreRaid", farmName = "Molten Core", locationID = 232, locationLabel = "Molten Core", petID = 1149, petName = "Corefire Imp", bossName = "Magmadar" },
    { farmID = "MoltenCoreRaid", farmName = "Molten Core", locationID = 232, locationLabel = "Molten Core", petID = 1147, petName = "Harbinger of Flame", bossName = "Sulfuron Harbinger" },
    { farmID = "MoltenCoreRaid", farmName = "Molten Core", locationID = 232, locationLabel = "Molten Core", petID = 1150, petName = "Ashstone Core", bossName = "Golemagg the Incinerator" },
    { farmID = "BlackwingLairRaid", farmName = "Blackwing Lair", locationID = 287, locationLabel = "Blackwing Lair", petID = 1151, petName = "Untamed Hatchling", bossName = "Razorgore the Untamed" },
    { farmID = "BlackwingLairRaid", farmName = "Blackwing Lair", locationID = 287, locationLabel = "Blackwing Lair", petID = 1153, petName = "Death Talon Whelpguard", bossName = "Broodlord Lashlayer" },
    { farmID = "BlackwingLairRaid", farmName = "Blackwing Lair", locationID = 287, locationLabel = "Blackwing Lair", petID = 1152, petName = "Chrominius", bossName = "Chromaggus" },
    { farmID = "AhnQiraj", farmName = "Temple of Ahn'Qiraj", locationID = 320, locationLabel = "Temple of Ahn'Qiraj", petID = 1156, petName = "Mini Mindslayer", bossName = "The Prophet Skeram" },
    { farmID = "AhnQiraj", farmName = "Temple of Ahn'Qiraj", locationID = 320, locationLabel = "Temple of Ahn'Qiraj", petID = 1154, petName = "Viscidus Globule", bossName = "Viscidus" },
    { farmID = "AhnQiraj", farmName = "Temple of Ahn'Qiraj", locationID = 320, locationLabel = "Temple of Ahn'Qiraj", petID = 1155, petName = "Anubisath Idol", bossName = "Emperor Vek'lor" },
}

local function BuildCuratedPetRows(rawRows)
    local rows = {}
    for _, row in ipairs(rawRows or {}) do
        if tonumber(row.petID) then
            rows[#rows + 1] = row
        end
    end
    for index, data in ipairs(classicRaidPetRows) do
        rows[#rows + 1] = {
            recordID = "pets:" .. data.farmID .. ":pet:" .. tostring(data.petID),
            farmID = data.farmID,
            farmName = data.farmName,
            itemID = 82800,
            itemLink = string.format("|cff0070dd|Hbattlepet:%d:1:3:155:12:12:0000000000000000:6291|h[%s]|h|r", data.petID, data.petName),
            petID = data.petID,
            quantity = 1,
            contentID = 1,
            expansion = "classic",
            expansionLabel = "Classic",
            locationID = data.locationID,
            locationLabel = data.locationLabel,
            bossName = data.bossName,
            curatedReplacement = true,
            curatedOrder = index,
        }
    end
    return rows
end

local function GetPetName(row)
    if type(row.itemLink) == "string" then
        local name = row.itemLink:match("|h%[([^%]]+)%]|h")
        if name and name ~= "" then
            return name
        end
    end
    return row.farmName or ("Item " .. tostring(row.itemID or "?"))
end

local function Slug(value)
    return tostring(value or "unknown"):lower():gsub("[^%w]+", "-"):gsub("^-", ""):gsub("-$", "")
end

local function BuildSourceURLs(row, raid)
    local urls = {}
    if tonumber(row.petID) then
        urls[#urls + 1] = { siteName = "Wowhead battle pet and comments", url = "https://www.wowhead.com/battle-pet/" .. tostring(row.petID) }
        urls[#urls + 1] = { siteName = "WarcraftPets database", url = "https://www.warcraftpets.com/wow-pets/" }
    elseif tonumber(row.itemID) then
        urls[#urls + 1] = { siteName = "Wowhead item and comments", url = "https://www.wowhead.com/item=" .. tostring(row.itemID) }
    end
    if raid and raid.guide then
        urls[#urls + 1] = { siteName = "Raid entrance guide", url = raid.guide }
    end
    urls[#urls + 1] = { siteName = "PetScout source map cross-check", url = "https://www.curseforge.com/wow/addons/petscout" }
    return urls
end

local function BuildMapOption(row, name, location, sourceName, mapID, x, y, suffix)
    return {
        id = "ggt:pet:" .. Slug(row.recordID) .. ":" .. (suffix or "location"),
        mapID = mapID,
        mapLabel = location,
        label = sourceName,
        mapRole = suffix,
        location = location,
        isRoute = false,
        density = "Verified acquisition location",
        dropDifficulty = "Drop chance and lockout rules vary by source; see the researched details.",
        pins = {
            { x = x, y = y, label = sourceName .. " - " .. name },
        },
    }
end

local farms = {}
local dropCategories = NS.WITDropsData and NS.WITDropsData.categories or {}
local rawPetRows = {}
for _, categoryRows in ipairs({ dropCategories.pets or {}, dropCategories.raidPets or {} }) do
    for _, row in ipairs(categoryRows) do
        rawPetRows[#rawPetRows + 1] = row
    end
end
local petRows = BuildCuratedPetRows(rawPetRows)
for _, row in ipairs(petRows) do
    local petID = tonumber(row.petID)
    local name = GetPetName(row)
    local outdoor = petID and outdoorByPetID[petID]
    local raid = raidByFarmID[row.farmID]
    local bossResearch = petID and bossResearchByPetID[petID]
    local sourceName
    local mapOptions = {}
    local summary
    local guide
    local details = {
        "This record is matched to the exact Drops > Pets row " .. tostring(row.recordID) .. ".",
    }

    if outdoor then
        sourceName = outdoor.sourceName
        mapOptions[1] = BuildMapOption(row, name, row.locationLabel or "Unknown location", sourceName, outdoor.mapID, outdoor.x, outdoor.y)
        summary = string.format("%s is obtained from %s in %s. The pin marks a verified acquisition point, not a generic zone center.", name, sourceName, row.locationLabel or "the listed zone")
        guide = {
            label = outdoor.kind == "vendor" and "Mapped vendor acquisition" or "Mapped outdoor acquisition",
            requirement = outdoor.kind == "incubation" and "Loot the Wiggling Egg, then wait for it to hatch." or "Reach the marked point and use the source named on the pin.",
            action = outdoor.kind == "nest" and "Check the marked nest location and nearby spawn points; the nest is small and can blend into the terrain."
                or outdoor.kind == "treasure" and "Reach and loot the marked one-time treasure on a character that has not already collected it."
                or "Farm or interact with the named source at the marked location.",
            tips = {
                outdoor.kind == "rare" and "Rare spawns can be absent after another player kills them; use short realm checks instead of assuming the pin is wrong."
                    or "The pin is one confirmed point; sources with patrols or multiple spawns can also appear nearby.",
                "Cageable pets can often be bought on the Auction House when the time cost of the farm exceeds the market price.",
                "The source and coordinate were cross-checked against current pet-location data and pet-specific guide or comment evidence.",
            },
        }
        details[#details + 1] = "Acquisition source: " .. sourceName .. "."
    elseif raid then
        sourceName = petID and (row.bossName or (bossResearch and bossResearch.name) or "raid drop") or (raid.instance .. " drop table")
        if bossResearch and bossResearch.mapID and bossResearch.x and bossResearch.y then
            mapOptions[#mapOptions + 1] = BuildMapOption(
                row,
                name,
                raid.instance .. " - " .. sourceName,
                sourceName,
                bossResearch.mapID,
                bossResearch.x,
                bossResearch.y,
                "boss"
            )
        end
        mapOptions[#mapOptions + 1] = BuildMapOption(row, name, raid.mapLabel, raid.instance .. " entrance", raid.mapID, raid.x, raid.y, "entrance")
        if raid.alternate then
            mapOptions[#mapOptions + 1] = BuildMapOption(row, name, raid.alternate.mapLabel, raid.instance .. " alternate entrance", raid.alternate.mapID, raid.alternate.x, raid.alternate.y, "alternate")
        end
        if petID then
            summary = bossResearch and bossResearch.mapID
                and string.format("%s drops from %s in %s. The first map marks the boss inside the raid; entrance maps remain available in the selector.", name, sourceName, raid.instance)
                or string.format("%s drops from %s in %s. No boss encounter pin exists for this source, so the map opens on the raid entrance.", name, sourceName, raid.instance)
        else
            summary = string.format("This non-pet WIT row is filed under Pets but is farmed inside %s. The map opens on the raid entrance.", raid.instance)
        end
        guide = {
            label = petID and "Raid boss pet drop" or "Raid collateral item row",
            requirement = "Travel to the marked raid entrance and choose a difficulty on which the listed source can be looted.",
            action = petID and ("Enter " .. raid.instance .. " and defeat " .. sourceName .. ".") or ("Enter " .. raid.instance .. " and clear the relevant trash and bosses for item " .. tostring(row.itemID) .. "."),
            tips = {
                "Most raid-boss pet chances are limited by the character's raid lockout; additional eligible characters add attempts.",
                "Legacy raid mechanics can still block a solo clear even when the enemies are numerically easy.",
                bossResearch and bossResearch.mapID
                    and "The first map pin marks the boss inside the instance; use the map selector for the exterior entrance."
                    or "This source has no boss encounter pin; the available pin marks the exterior entrance.",
            },
        }
        details[#details + 1] = "Instance: " .. raid.instance .. "."
        details[#details + 1] = "Target: " .. sourceName .. "."
    end

    if #mapOptions > 0 then
        farms[#farms + 1] = {
            id = "ggt:pet:" .. Slug(row.recordID),
            sourceType = "curated",
            sourceDataset = "GGTPetFarmData",
            sourceCategory = "pets",
            sourcePath = "Drops > Pets",
            activity = petID and "pet" or "item",
            name = name,
            expansion = row.expansionLabel or row.expansion or "Unknown expansion",
            primaryPetID = petID,
            primaryItemID = not petID and tonumber(row.itemID) or nil,
            sourceRecordID = row.recordID,
            providerFarmID = row.farmID,
            bossName = bossResearch and bossResearch.name or row.bossName,
            bossEncounterJournalID = bossResearch and bossResearch.encounterID,
            bossMapID = bossResearch and bossResearch.mapID,
            bossX = bossResearch and bossResearch.x,
            bossY = bossResearch and bossResearch.y,
            routeCount = #mapOptions,
            mapIDs = (function()
                local result = {}
                for _, option in ipairs(mapOptions) do result[#result + 1] = option.mapID end
                return result
            end)(),
            mapNames = (function()
                local result = {}
                for _, option in ipairs(mapOptions) do result[#result + 1] = option.mapLabel end
                return result
            end)(),
            targets = {},
            summary = summary,
            guide = guide,
            details = details,
            sourceUrls = BuildSourceURLs(row, raid),
            mapOptions = mapOptions,
        }
    end
end

local catalog = NS.FarmCatalog
if type(catalog) ~= "table" then
    catalog = { farms = {}, byID = {}, indexes = {}, sourceCounts = {} }
    NS.FarmCatalog = catalog
end
catalog.farms = type(catalog.farms) == "table" and catalog.farms or {}
catalog.byID = type(catalog.byID) == "table" and catalog.byID or {}
catalog.indexes = type(catalog.indexes) == "table" and catalog.indexes or {}
catalog.sourceCounts = type(catalog.sourceCounts) == "table" and catalog.sourceCounts or {}

local function AddIndex(indexName, key, position)
    if key == nil then return end
    catalog.indexes[indexName] = type(catalog.indexes[indexName]) == "table" and catalog.indexes[indexName] or {}
    local entries = catalog.indexes[indexName][key]
    if type(entries) ~= "table" then
        entries = {}
        catalog.indexes[indexName][key] = entries
    end
    entries[#entries + 1] = position
end

local uniqueItemsAdded = 0
for _, farm in ipairs(farms) do
    if not catalog.byID[farm.id] then
        local itemIndex = farm.primaryItemID and catalog.indexes.byItemID
        local isNewItem = farm.primaryItemID and (type(itemIndex) ~= "table" or type(itemIndex[farm.primaryItemID]) ~= "table")
        local position = #catalog.farms + 1
        catalog.farms[position] = farm
        catalog.byID[farm.id] = position
        AddIndex("byPetID", farm.primaryPetID, position)
        AddIndex("byItemID", farm.primaryItemID, position)
        AddIndex("byRecordID", farm.sourceRecordID, position)
        AddIndex("byActivity", farm.activity, position)
        AddIndex("byExpansion", farm.expansion, position)
        AddIndex("bySourceCategory", farm.sourceCategory, position)
        AddIndex("bySourceType", farm.sourceType, position)
        for _, mapID in ipairs(farm.mapIDs or {}) do AddIndex("byMapID", mapID, position) end
        if isNewItem then uniqueItemsAdded = uniqueItemsAdded + 1 end
    end
end

catalog.farmCount = #catalog.farms
catalog.uniqueItemCount = (tonumber(catalog.uniqueItemCount) or 0) + uniqueItemsAdded
catalog.sourceCounts.curatedPets = #farms

NS.PetFarmData = {
    dataVersion = 2,
    researchedAt = "2026-10-08",
    sourceRowCount = #rawPetRows,
    curatedRowCount = #petRows,
    rows = petRows,
    farms = farms,
    researchSources = {
        "https://warcraft.wiki.gg/wiki/Raiding_with_Leashes",
        "https://warcraft.wiki.gg/wiki/Raiding_with_Leashes_II:_Attunement_Edition",
        "https://warcraft.wiki.gg/wiki/Raiding_with_Leashes_III:_Drinkin%27_From_the_Sunwell",
        "https://warcraft.wiki.gg/wiki/Raiding_with_Leashes_IV:_Wrath_of_the_Lick_King",
        "https://warcraft.wiki.gg/wiki/Raiding_with_Leashes_V:_Cuteaclysm",
        "https://warcraft.wiki.gg/wiki/Raiding_with_Leashes_VI:_Pets_of_Pandaria",
        "https://wago.tools/db2/JournalEncounterXMapLoc/csv",
    },
}
