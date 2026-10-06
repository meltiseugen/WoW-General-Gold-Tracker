local _, NS = ...

-- Curated Retail acquisition research for every visible Drops > Pets row.
-- Coordinates are normalized UI-map coordinates. Research reviewed 2026-10-03.

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

local bossByPetID = {
    [1143] = "Maexxna", [1144] = "Loatheb", [1146] = "Gluth",
    [1177] = "Sand Elemental trash", [1183] = "Dark Animus", [1200] = "Horridon", [1202] = "Ji-Kun",
    [1226] = "Opera Hall", [1227] = "The Curator", [1228] = "Prince Malchezaar", [1229] = "Terestian Illhoof",
    [1230] = "Morogrim Tidewalker", [1231] = "Hydross the Unstable / The Lurker Below", [1232] = "Lady Vashj",
    [1233] = "Void Reaver", [1234] = "High Astromancer Solarian", [1235] = "Al'ar",
    [1243] = "Primordius", [1244] = "Primordius", [1322] = "Siegecrafter Blackfuse",
    [1331] = "Sha of Pride", [1332] = "Sha of Pride", [1334] = "Paragons of the Klaxxi",
    [1622] = "Azgalor", [1623] = "High Warlord Naj'entus", [1624] = "Supremus",
    [1625] = "Reliquary of Souls", [1626] = "Reliquary of Souls", [1627] = "Reliquary of Souls", [1628] = "Mother Shahraz",
    [1629] = "Anetheron", [1631] = "Archimonde", [1632] = "Brutallus", [1633] = "M'uru / Entropius",
    [1634] = "Eredar Twins", [1672] = "Shadow-Lord Iskar", [1723] = "Dragons of Nightmare",
    [1952] = "Northrend Beasts", [1953] = "Northrend Beasts", [1954] = "Anub'arak",
    [1955] = "Ignis the Furnace Master", [1956] = "Razorscale", [1957] = "Assembly of Iron", [1958] = "Auriaya",
    [1959] = "Hodir", [1960] = "Freya", [1961] = "Mimiron", [1962] = "Yogg-Saron",
    [1963] = "Lord Marrowgar", [1964] = "Deathbringer Saurfang", [1965] = "Professor Putricide",
    [1966] = "Sindragosa", [1967] = "The Lich King", [1968] = "The Lich King",
    [2078] = "Omnotron Defense System", [2079] = "Maloriak", [2080] = "Nefarian",
    [2081] = "Valiona and Theralion", [2082] = "Ascendant Council", [2083] = "Cho'gall",
    [2084] = "Al'Akir", [2085] = "Conclave of Wind", [2086] = "Shannox", [2087] = "Beth'tilac", [2088] = "Baleroc",
    [2090] = "Yor'sahj the Unsleeping", [2091] = "Spine of Deathwing", [2092] = "Madness of Deathwing",
    [2527] = "Pa'ku's Aspect", [2528] = "Pa'ku's Aspect", [2529] = "Pa'ku's Aspect",
    [2579] = "Stone Guard", [2580] = "Gara'jal the Spiritbinder", [2581] = "Elegon", [2582] = "Will of the Emperor",
    [2583] = "Tsulong", [2584] = "Tsulong", [2585] = "Imperial Vizier Zor'lok", [2586] = "Blade Lord Ta'yak",
    [2587] = "Garalon", [2589] = "Amber-Shaper Un'sok", [2590] = "Grand Empress Shek'zeer",
    [2680] = "Queen Azshara", [2692] = "Lady Ashvane", [2694] = "Blackwater Behemoth", [2696] = "Za'qul",
    [2832] = "Maut", [2833] = "Ra-den", [2834] = "Tek'ris", [2835] = "Tek'ris", [2836] = "N'Zoth the Corruptor",
}

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
local petRows = NS.WITDropsData and NS.WITDropsData.categories and NS.WITDropsData.categories.pets or {}
for _, row in ipairs(petRows) do
    local petID = tonumber(row.petID)
    local name = GetPetName(row)
    local outdoor = petID and outdoorByPetID[petID]
    local raid = raidByFarmID[row.farmID]
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
        sourceName = petID and (bossByPetID[petID] or "raid drop") or (raid.instance .. " drop table")
        mapOptions[1] = BuildMapOption(row, name, raid.mapLabel, raid.instance .. " entrance", raid.mapID, raid.x, raid.y)
        if raid.alternate then
            mapOptions[2] = BuildMapOption(row, name, raid.alternate.mapLabel, raid.instance .. " alternate entrance", raid.alternate.mapID, raid.alternate.x, raid.alternate.y, "alternate")
        end
        if petID then
            summary = string.format("%s drops from %s in %s. The map opens on the raid entrance.", name, sourceName, raid.instance)
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
                "The pin is the exterior entrance; the named boss or source is inside the instance.",
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
    dataVersion = 1,
    researchedAt = "2026-10-03",
    sourceRowCount = #petRows,
    farms = farms,
}
