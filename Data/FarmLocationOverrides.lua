local _, NS = ...

-- Map points for imported WIT gathering entries that did not include a decoded
-- WIT route and had no matching MaterialFarmingSpots entry.  The coordinates
-- are normalized UI-map coordinates researched from the relevant Wowhead item
-- pages on 2026-10-07; item-mapper results are used where available, while
-- Darkmoon, Deviate Fish, and the two Eternal element farms use a useful
-- zone-level pin at their known fishing/elemental grounds.  They are
-- intentionally pins, not routes: only Herb and Mining farms render lines.

local catalog = NS.FarmCatalog
if type(catalog) ~= "table" or type(catalog.farms) ~= "table" or type(catalog.byID) ~= "table" then
    return
end

local locations = {
    ["wit:gathering:fishing:darkmoondaggermaw"] = { 407, "Darkmoon Island", 0.500, 0.740, "Darkmoon Island fishing water", 124669 },
    ["wit:gathering:fishing:capeofstranglethornfish"] = { 210, "The Cape of Stranglethorn", 0.285, 0.690, "Cape of Stranglethorn fishing water", 6362 },
    ["wit:gathering:fishing:crystalsongforestfish"] = { 127, "Crystalsong Forest", 0.139, 0.165, "Crystalsong Forest fishing water", 41814 },
    ["wit:gathering:fishing:feralasfish"] = { 69, "Feralas", 0.439, 0.115, "Feralas fishing water", 21153 },
    ["wit:gathering:fishing:northenbarrensfish"] = { 10, "Northern Barrens", 0.451, 0.405, "Wailing Caverns oasis fishing water", 6522 },
    ["wit:gathering:fishing:ungorocraterfish"] = { 78, "Un'Goro Crater", 0.257, 0.493, "Un'Goro Crater fishing water", 21153 },
    ["wit:gathering:fishing:stonetalonmountainsfish"] = { 65, "Stonetalon Mountains", 0.476, 0.729, "Stonetalon Mountains fishing water", 21153 },
    ["wit:gathering:fishing:moongladefish"] = { 80, "Moonglade", 0.383, 0.523, "Moonglade fishing water", 13760 },
    ["wit:gathering:fishing:swampofsorrowsfish"] = { 51, "Swamp of Sorrows", 0.623, 0.570, "Swamp of Sorrows fishing water", 8365 },
    ["wit:gathering:fishing:easternplaugelandsfish"] = { 23, "Eastern Plaguelands", 0.029, 0.383, "Eastern Plaguelands fishing water", 13758 },
    ["wit:gathering:fishing:felwoodfish"] = { 77, "Felwood", 0.405, 0.654, "Felwood fishing water", 8365 },
    ["wit:gathering:fishing:blastedlandsfish"] = { 17, "Blasted Lands", 0.357, 0.766, "Blasted Lands fishing water", 13760 },
    ["wit:gathering:fishing:winterspringfish"] = { 83, "Winterspring", 0.224, 0.470, "Winterspring fishing water", 13889 },
    ["wit:gathering:fishing:lochmodanfish"] = { 48, "Loch Modan", 0.214, 0.904, "Loch Modan fishing water", 6317 },
    ["wit:gathering:fishing:darkshorefish"] = { 62, "Darkshore", 0.319, 0.464, "Darkshore fishing water", 12238 },
    ["wit:gathering:fishing:ghostlandsfish"] = { 95, "Ghostlands", 0.112, 0.279, "Ghostlands fishing water", 6361 },
    ["wit:gathering:fishing:ashenvalefish"] = { 63, "Ashenvale", 0.068, 0.715, "Ashenvale fishing water", 6308 },
    ["wit:gathering:fishing:thehinterlandsfish"] = { 26, "The Hinterlands", 0.272, 0.347, "The Hinterlands fishing water", 8365 },
    ["wit:gathering:fishing:westernplaugelandsfish"] = { 22, "Western Plaguelands", 0.293, 0.673, "Western Plaguelands fishing water", 6308 },
    ["wit:gathering:fishing:tannanjunglefish"] = { 534, "Tanaan Jungle", 0.121, 0.470, "Tanaan Jungle fishing water", 127991 },
    ["wit:gathering:fishing:eversongwoodsfish"] = { 94, "Eversong Woods", 0.221, 0.769, "Eversong Woods fishing water", 6303 },
    ["wit:gathering:fishing:durotarfish"] = { 1, "Durotar", 0.496, 0.844, "Durotar fishing water", 6303 },
    ["wit:gathering:fishing:azuremystvalefish"] = { 97, "Azuremyst Isle", 0.144, 0.951, "Azuremyst Isle fishing water", 6303 },
    ["wit:gathering:fishing:silverpineforestfish"] = { 21, "Silverpine Forest", 0.423, 0.832, "Silverpine Forest fishing water", 6308 },
    ["wit:gathering:fishing:tirisfalgladesfish"] = { 18, "Tirisfal Glades", 0.144, 0.527, "Tirisfal Glades fishing water", 6291 },
    ["wit:gathering:fishing:northenstranglethornfish"] = { 50, "Northern Stranglethorn", 0.263, 0.180, "Northern Stranglethorn fishing water", 6308 },
    ["wit:gathering:fishing:arathihighlandsfish"] = { 14, "Arathi Highlands", 0.164, 0.539, "Arathi Highlands fishing water", 6308 },
    ["wit:gathering:fishing:wetlandsfish"] = { 56, "Wetlands", 0.146, 0.396, "Wetlands fishing water", 6308 },
    ["wit:gathering:fishing:redridgemountainsfish"] = { 49, "Redridge Mountains", 0.123, 0.106, "Redridge Mountains fishing water", 6308 },
    ["wit:gathering:fishing:westfallfish"] = { 52, "Westfall", 0.458, 0.588, "Westfall fishing water", 6291 },
    ["wit:gathering:fishing:dunmoroghfish"] = { 27, "Dun Morogh", 0.176, 0.744, "Dun Morogh fishing water", 6291 },
    ["wit:gathering:fishing:darnassusfish"] = { 89, "Darnassus", 0.324, 0.482, "Darnassus fishing water", 6291 },
    ["wit:gathering:fishing:azsharafish"] = { 76, "Azshara", 0.048, 0.857, "Azshara fishing water", 6291 },
    ["wit:gathering:fishing:mulgorefish"] = { 7, "Mulgore", 0.184, 0.648, "Mulgore fishing water", 6289 },
    ["wit:gathering:fishing:elwynforetsfish"] = { 37, "Elwynn Forest", 0.173, 0.644, "Elwynn Forest fishing water", 6289 },
    ["wit:gathering:skinning:isleofdornskin"] = { 2248, "Isle of Dorn", 0.255, 0.681, "Isle of Dorn skinnable-creature area", 223512 },
    ["wit:gathering:misc:eternalair"] = { 120, "The Storm Peaks", 0.457, 0.708, "The Storm Peaks air-elemental area", 35623 },
    ["wit:gathering:misc:eternalearth"] = { 119, "Sholazar Basin", 0.635, 0.594, "Sholazar Basin earth-elemental area", 35624 },
}

-- The WIT display names below are abbreviations, legacy labels, or contain
-- spelling variants.  Match them to the canonical names in our AtlasLoot/ATT
-- snapshots so Core/InstanceEntrances can request the live Encounter Journal
-- entrance for every imported instance farm.
local instanceAliases = {
    ["wit:drops:transmogs:scarletmonastayold"] = "ScarletMonastery",
    ["wit:drops:transmogs:scarletarmoryold"] = "ScarletMonastery",
    ["wit:drops:transmogs:brd"] = "BlackrockDepths",
    ["wit:drops:transmogs:stratholmemainentrence"] = "StratholmeCrusader",
    ["wit:drops:transmogs:thestockades"] = "TheStockade",
    ["wit:drops:transmogs:stratholmeserviceenterence"] = "StratholmeGauntlet",
    ["wit:drops:transmogs:scarletmonastarynew"] = "ScarletMonastery",
    ["wit:drops:transmogs:scarlethallsnew"] = "ScarletHalls",
    ["wit:drops:transmogs:scarletgraveyardold"] = "ScarletMonastery",
    ["wit:drops:transmogs:hellfireramparts"] = "HCHellfireRamparts",
    ["wit:drops:transmogs:sunwell"] = "SunwellPlateau",
    ["wit:drops:transmogs:manatombs"] = "AuchManaTombs",
    ["wit:drops:transmogs:shadowlab"] = "AuchShadowLabyrinth",
    ["wit:drops:transmogs:botanica"] = "TempestKeepBotanica",
    ["wit:drops:transmogs:magistersterrece"] = "MagistersTerrace",
    ["wit:drops:transmogs:shatteredhalls"] = "HCTheShatteredHalls",
    ["wit:drops:transmogs:sethekkhalls"] = "AuchSethekkHalls",
    ["wit:drops:transmogs:theunderbog"] = "CFRTheUnderbog",
    ["wit:drops:transmogs:auchenaicrypts"] = "AuchAuchenaiCrypts",
    ["wit:drops:transmogs:bloodfurnace"] = "HCBloodFurnace",
    ["wit:drops:transmogs:steamvaults"] = "CFRTheSteamvault",
    ["wit:drops:transmogs:themechanar"] = "TempestKeepMechanar",
    ["wit:drops:transmogs:thearcatraz"] = "TempestKeepArcatraz",
    ["wit:drops:transmogs:theslavepens"] = "CFRTheSlavePens",
    ["wit:drops:transmogs:hallsoflightning"] = "UlduarHallsofLightning",
    ["wit:drops:transmogs:utguardpinnacle"] = "UtgardePinnacle",
    ["wit:drops:transmogs:ahnkahettheoldkingdom"] = "AhnKahet",
    ["wit:drops:transmogs:hallsofstone"] = "UlduarHallsofStone",
    ["wit:drops:transmogs:pitofsaron"] = "FHPitOfSaron",
    ["wit:drops:transmogs:forgeofsouls"] = "FHTheForgeOfSouls",
    ["wit:drops:transmogs:throneoftides"] = "ThroneOfTheTides",
    ["wit:drops:openworldinstances:monastary"] = "ScarletMonastery",
    ["wit:drops:openworldinstances:scholomace"] = "Scholomance",
    ["wit:drops:openworldinstances:ulduman"] = "Uldaman",
    ["wit:drops:openworldinstances:dire"] = "DireMaulEast",
    ["wit:drops:openworldinstances:stratholme"] = "StratholmeGauntlet",
    ["wit:drops:openworldinstances:sunken"] = "TheSunkenTemple",
    ["wit:drops:openworldinstances:scarletmonastary"] = "ScarletMonastery",
    ["wit:drops:openworldinstances:scholomace"] = "Scholomance",
    ["wit:drops:openworldinstances:ulduman"] = "Uldaman",
}

local function AddSourceURL(farm, url)
    farm.sourceUrls = type(farm.sourceUrls) == "table" and farm.sourceUrls or {}
    for _, existing in ipairs(farm.sourceUrls) do
        if (type(existing) == "table" and existing.url or existing) == url then
            return
        end
    end
    farm.sourceUrls[#farm.sourceUrls + 1] = {
        siteName = "Wowhead location research",
        url = url,
    }
end

for farmID, data in pairs(locations) do
    local farm = catalog.farms[catalog.byID[farmID]]
    if farm then
        local mapID, mapLabel, x, y, location, itemID = (table.unpack or unpack)(data)
        farm.mapOptions = {
            {
                id = farmID .. ":researched-location",
                mapID = mapID,
                mapLabel = mapLabel,
                label = location,
                location = location,
                isRoute = false,
                density = "Researched farm location",
                dropDifficulty = "Yield varies with profession skill, competition, and character setup.",
                pins = {
                    { x = x, y = y, label = location },
                },
            },
        }
        farm.locationResearchSource = "Wowhead location research"
        AddSourceURL(farm, "https://www.wowhead.com/item=" .. tostring(itemID))
    end
end

for farmID, instanceName in pairs(instanceAliases) do
    local farm = catalog.farms[catalog.byID[farmID]]
    if farm then
        farm.instanceAliases = { instanceName }
    end
end
