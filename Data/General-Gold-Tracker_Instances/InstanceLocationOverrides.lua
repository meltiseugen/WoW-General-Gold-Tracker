local _, NS = ...

-- Static entrance and boss-map coordinates for instances represented by the
-- bundled noteworthy-item catalog farms. Entrance coordinates come from
-- JournalInstanceEntrance + AreaTable + UiMapAssignment; boss coordinates
-- come from JournalEncounterXMapLoc. Snapshot: Retail 12.1.5.70077,
-- researched 2026-10-08 from the Blizzard DB2 mirror at wago.tools.

local entranceByJournalInstanceID = {
    [63] = { mapID = 52, x = 0.382003, y = 0.774844, mapName = "Westfall" },
    [64] = { mapID = 21, x = 0.446024, y = 0.676667, mapName = "Silverpine Forest" },
    [65] = { mapID = 204, x = 0.696057, y = 0.248812, mapName = "Abyssal Depths" },
    [66] = { mapID = 36, x = 0.274934, y = 0.278033, mapName = "Burning Steppes" },
    [67] = { mapID = 207, x = 0.478284, y = 0.518971, mapName = "Deepholm" },
    -- These three Cataclysm entrance rows use a phased world-map transform
    -- that is absent from current UiMapAssignment. Wowhead's current entrance
    -- guide provides the stable Uldum map coordinates instead.
    [68] = { mapID = 249, x = 0.766000, y = 0.843000, mapName = "Uldum" },
    [69] = { mapID = 249, x = 0.601000, y = 0.699000, mapName = "Uldum" },
    [70] = { mapID = 249, x = 0.723100, y = 0.521100, mapName = "Uldum" },
    [71] = { mapID = 241, x = 0.191042, y = 0.536662, mapName = "Twilight Highlands" },
    [226] = { mapID = 85, x = 0.529446, y = 0.576299, mapName = "Orgrimmar" },
    [227] = { mapID = 62, x = 0.349551, y = 0.920980, mapName = "Darkshore" },
    [228] = { mapID = 32, x = 0.275518, y = 0.723785, mapName = "Searing Gorge" },
    [229] = { mapID = 36, x = 0.276725, y = 0.258323, mapName = "Burning Steppes" },
    [230] = { mapID = 69, x = 0.648452, y = 0.300652, mapName = "Feralas" },
    [231] = { mapID = 27, x = 0.249279, y = 0.371659, mapName = "Dun Morogh" },
    [232] = { mapID = 66, x = 0.305034, y = 0.545067, mapName = "Desolace" },
    [233] = { mapID = 64, x = 0.478091, y = 0.237931, mapName = "Thousand Needles" },
    [234] = { mapID = 199, x = 0.406241, y = 0.942855, mapName = "Southern Barrens" },
    [236] = { mapID = 23, x = 0.273290, y = 0.115985, mapName = "Eastern Plaguelands" },
    [237] = { mapID = 51, x = 0.760972, y = 0.452441, mapName = "Swamp of Sorrows" },
    [238] = { mapID = 84, x = 0.503228, y = 0.661309, mapName = "Stormwind City" },
    [239] = { mapID = 48, x = 0.348490, y = 0.852368, mapName = "Loch Modan" },
    [240] = { mapID = 10, x = 0.420281, y = 0.669237, mapName = "Northern Barrens" },
    [241] = { mapID = 71, x = 0.392298, y = 0.212140, mapName = "Tanaris" },
    [246] = { mapID = 22, x = 0.689628, y = 0.727192, mapName = "Western Plaguelands" },
    [247] = { mapID = 108, x = 0.341937, y = 0.655986, mapName = "Terokkar Forest" },
    [248] = { mapID = 100, x = 0.474765, y = 0.536294, mapName = "Hellfire Peninsula" },
    [249] = { mapID = 122, x = 0.615151, y = 0.310963, mapName = "Isle of Quel'Danas" },
    [250] = { mapID = 108, x = 0.396394, y = 0.574481, mapName = "Terokkar Forest" },
    [252] = { mapID = 108, x = 0.450559, y = 0.656208, mapName = "Terokkar Forest" },
    [253] = { mapID = 108, x = 0.396337, y = 0.737792, mapName = "Terokkar Forest" },
    [254] = { mapID = 109, x = 0.745724, y = 0.576180, mapName = "Netherstorm" },
    [256] = { mapID = 100, x = 0.458715, y = 0.519347, mapName = "Hellfire Peninsula" },
    [257] = { mapID = 109, x = 0.718264, y = 0.548160, mapName = "Netherstorm" },
    [258] = { mapID = 109, x = 0.706357, y = 0.698173, mapName = "Netherstorm" },
    [259] = { mapID = 100, x = 0.473996, y = 0.520206, mapName = "Hellfire Peninsula" },
    [260] = { mapID = 102, x = 0.489296, y = 0.354877, mapName = "Zangarmarsh" },
    [261] = { mapID = 102, x = 0.502021, y = 0.333205, mapName = "Zangarmarsh" },
    [262] = { mapID = 102, x = 0.543668, y = 0.343828, mapName = "Zangarmarsh" },
    [271] = { mapID = 115, x = 0.285269, y = 0.517598, mapName = "Dragonblight" },
    [273] = { mapID = 121, x = 0.283787, y = 0.869115, mapName = "Zul'Drak" },
    [274] = { mapID = 121, x = 0.760216, y = 0.207923, mapName = "Zul'Drak" },
    [275] = { mapID = 120, x = 0.454366, y = 0.212812, mapName = "The Storm Peaks" },
    [277] = { mapID = 120, x = 0.394391, y = 0.269077, mapName = "The Storm Peaks" },
    [278] = { mapID = 118, x = 0.548666, y = 0.919096, mapName = "Icecrown" },
    [280] = { mapID = 118, x = 0.549922, y = 0.896507, mapName = "Icecrown" },
    [281] = { mapID = 114, x = 0.274979, y = 0.258896, mapName = "Borean Tundra" },
    [282] = { mapID = 114, x = 0.275245, y = 0.267468, mapName = "Borean Tundra" },
    [285] = { mapID = 117, x = 0.571726, y = 0.461286, mapName = "Howling Fjord" },
    [286] = { mapID = 117, x = 0.572921, y = 0.468946, mapName = "Howling Fjord" },
    [302] = { mapID = 376, x = 0.361190, y = 0.693951, mapName = "Valley of the Four Winds" },
    [303] = { mapID = 422, x = 0.758434, y = 0.200908, mapName = "Dread Wastes" },
    [311] = { mapID = 18, x = 0.853499, y = 0.322881, mapName = "Tirisfal Glades" },
    [313] = { mapID = 371, x = 0.562452, y = 0.578994, mapName = "The Jade Forest" },
    [316] = { mapID = 18, x = 0.847969, y = 0.303110, mapName = "Tirisfal Glades" },
    [321] = { mapID = 390, x = 0.810950, y = 0.323602, mapName = "Vale of Eternal Blossoms" },
    [385] = { mapID = 525, x = 0.496506, y = 0.246499, mapName = "Frostfire Ridge" },
    [476] = { mapID = 542, x = 0.410032, y = 0.314214, mapName = "Spires of Arak" },
    [537] = { mapID = 539, x = 0.317944, y = 0.427121, mapName = "Shadowmoon Valley" },
    [556] = { mapID = 543, x = 0.596689, y = 0.460309, mapName = "Gorgrond" },
    [558] = { mapID = 543, x = 0.455980, y = 0.135597, mapName = "Gorgrond" },
    [716] = { mapID = 630, x = 0.609996, y = 0.411080, mapName = "Azsuna" },
    [745] = { mapID = 42, x = 0.465915, y = 0.741140, mapName = "Deadwind Pass" },
    [752] = { mapID = 122, x = 0.442750, y = 0.458704, mapName = "Isle of Quel'Danas" },
    [1276] = { mapID = 69, x = 0.648452, y = 0.300652, mapName = "Feralas" },
    [1277] = { mapID = 69, x = 0.626150, y = 0.248910, mapName = "Feralas" },
    [1292] = { mapID = 23, x = 0.273290, y = 0.115985, mapName = "Eastern Plaguelands" },
}

local bossByJournalEncounterID = {
    [373] = { mapID = 243, x = 0.549180, y = 0.948770 }, -- Pyromancer Loregrain
    [393] = { mapID = 254, x = 0.539617, y = 0.844263 }, -- Quartermaster Zigris
    [408] = { mapID = 237, x = 0.338798, y = 0.450820 }, -- Magister Kalendris
    [417] = { mapID = 235, x = 0.319544, y = 0.229482 }, -- King Gordok
    [446] = { mapID = 317, x = 0.042824, y = 0.510000 }, -- Willey Hopebreaker
    [448] = { mapID = 317, x = 0.272333, y = 0.750000 }, -- Instructor Galford
    [449] = { mapID = 317, x = 0.204918, y = 0.818000 }, -- Balnazzar
    [453] = { mapID = 318, x = 0.674864, y = 0.227459 }, -- Maleki the Pallid
    [482] = { mapID = 219, x = 0.328694, y = 0.381156 }, -- Hydromancer Velratha
}

-- A few noteworthy sources are rares or reward containers and therefore have
-- no JournalEncounterXMapLoc row. These positions are keyed to their bundled
-- AtlasLoot names and come from the cited Wowhead/Warcraft Wiki location maps.
local bossByInstanceAndName = {
    ["DireMaulNorth|Dire Maul North Tribute Chest"] = { mapID = 235, x = 0.319544, y = 0.229482 },
    ["LowerBlackrockSpire|Bannok Grimaxe"] = { mapID = 254, x = 0.479000, y = 0.642000 },
    ["RazorfenKraul|Enormous Bullfrog (Rare)"] = { mapID = 301, x = 0.119000, y = 0.327000 },
}

local instancesByJournalID = {}
for _, instance in pairs(type(NS.InstanceDropsData) == "table" and NS.InstanceDropsData.instances or {}) do
    local journalInstanceID = tonumber(instance and instance.encounterJournalID)
    if journalInstanceID then
        instancesByJournalID[journalInstanceID] = instance
        local entrance = entranceByJournalInstanceID[journalInstanceID]
        if entrance then
            instance.entrance = {
                mapID = entrance.mapID,
                x = entrance.x,
                y = entrance.y,
                mapName = entrance.mapName,
                label = tostring(instance.name or "Instance") .. " entrance",
            }
        end
    end
    for _, boss in ipairs(instance and instance.bosses or {}) do
        local location = bossByJournalEncounterID[tonumber(boss.encounterJournalID)]
            or bossByInstanceAndName[tostring(instance.name) .. "|" .. tostring(boss.name)]
        if location then
            boss.mapID = location.mapID
            boss.x = location.x
            boss.y = location.y
        end
    end
end

NS.InstanceLocationResearch = {
    dataVersion = 1,
    clientBuild = "12.1.5.70077",
    researchedAt = "2026-10-08",
    instanceCount = 67,
    bossCount = 12,
    entranceByJournalInstanceID = entranceByJournalInstanceID,
    bossByJournalEncounterID = bossByJournalEncounterID,
    bossByInstanceAndName = bossByInstanceAndName,
    sourceURLs = {
        "https://wago.tools/db2/JournalInstanceEntrance/csv",
        "https://wago.tools/db2/JournalEncounterXMapLoc/csv",
        "https://wago.tools/db2/AreaTable/csv",
        "https://wago.tools/db2/UiMapAssignment/csv",
        "https://www.wowhead.com/guide/dungeon-entrances-wow-kalimdor",
        "https://www.wowhead.com/npc=9596/bannok-grimaxe",
        "https://warcraft.wiki.gg/wiki/Enormous_Bullfrog",
        "https://www.wowhead.com/classic/guide/dire-maul-north-dungeon-strategy-wow-classic",
    },
}
