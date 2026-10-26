local _, NS = ...

-- Map points for catalog gathering entries that did not include a decoded
-- Catalog route and had no matching MaterialFarmingSpots entry.  The coordinates
-- are normalized UI-map coordinates researched from the relevant Wowhead item
-- pages on 2026-10-07; item-mapper results are used where available, while
-- Some farms use a zone-level pin at their known fishing/elemental grounds. They are
-- intentionally pins, not routes: only Herb and Mining farms render lines.

local catalog = NS.FarmCatalog
if type(catalog) ~= "table" or type(catalog.farms) ~= "table" or type(catalog.byID) ~= "table" then
    return
end

local locations = {
    ["catalog:gathering:fishing:capeofstranglethornfish"] = { 210, "The Cape of Stranglethorn", 0.285, 0.690, "Cape of Stranglethorn fishing water", 6362 },
    ["catalog:gathering:fishing:crystalsongforestfish"] = { 127, "Crystalsong Forest", 0.139, 0.165, "Crystalsong Forest fishing water", 41814 },
    ["catalog:gathering:fishing:feralasfish"] = { 69, "Feralas", 0.439, 0.115, "Feralas fishing water", 21153 },
    ["catalog:gathering:fishing:northenbarrensfish"] = { 10, "Northern Barrens", 0.451, 0.405, "Wailing Caverns oasis fishing water", 6522 },
    ["catalog:gathering:fishing:ungorocraterfish"] = { 78, "Un'Goro Crater", 0.257, 0.493, "Un'Goro Crater fishing water", 21153 },
    ["catalog:gathering:fishing:stonetalonmountainsfish"] = { 65, "Stonetalon Mountains", 0.476, 0.729, "Stonetalon Mountains fishing water", 21153 },
    ["catalog:gathering:fishing:moongladefish"] = { 80, "Moonglade", 0.383, 0.523, "Moonglade fishing water", 13760 },
    ["catalog:gathering:fishing:swampofsorrowsfish"] = { 51, "Swamp of Sorrows", 0.623, 0.570, "Swamp of Sorrows fishing water", 8365 },
    ["catalog:gathering:fishing:easternplaugelandsfish"] = { 23, "Eastern Plaguelands", 0.029, 0.383, "Eastern Plaguelands fishing water", 13758 },
    ["catalog:gathering:fishing:felwoodfish"] = { 77, "Felwood", 0.405, 0.654, "Felwood fishing water", 8365 },
    ["catalog:gathering:fishing:blastedlandsfish"] = { 17, "Blasted Lands", 0.357, 0.766, "Blasted Lands fishing water", 13760 },
    ["catalog:gathering:fishing:winterspringfish"] = { 83, "Winterspring", 0.224, 0.470, "Winterspring fishing water", 13889 },
    ["catalog:gathering:fishing:lochmodanfish"] = { 48, "Loch Modan", 0.214, 0.904, "Loch Modan fishing water", 6317 },
    ["catalog:gathering:fishing:darkshorefish"] = { 62, "Darkshore", 0.319, 0.464, "Darkshore fishing water", 12238 },
    ["catalog:gathering:fishing:ghostlandsfish"] = { 95, "Ghostlands", 0.112, 0.279, "Ghostlands fishing water", 6361 },
    ["catalog:gathering:fishing:ashenvalefish"] = { 63, "Ashenvale", 0.068, 0.715, "Ashenvale fishing water", 6308 },
    ["catalog:gathering:fishing:thehinterlandsfish"] = { 26, "The Hinterlands", 0.272, 0.347, "The Hinterlands fishing water", 8365 },
    ["catalog:gathering:fishing:westernplaugelandsfish"] = { 22, "Western Plaguelands", 0.293, 0.673, "Western Plaguelands fishing water", 6308 },
    ["catalog:gathering:fishing:tannanjunglefish"] = { 534, "Tanaan Jungle", 0.121, 0.470, "Tanaan Jungle fishing water", 127991 },
    ["catalog:gathering:fishing:eversongwoodsfish"] = { 94, "Eversong Woods", 0.221, 0.769, "Eversong Woods fishing water", 6303 },
    ["catalog:gathering:fishing:durotarfish"] = { 1, "Durotar", 0.496, 0.844, "Durotar fishing water", 6303 },
    ["catalog:gathering:fishing:azuremystvalefish"] = { 97, "Azuremyst Isle", 0.144, 0.951, "Azuremyst Isle fishing water", 6303 },
    ["catalog:gathering:fishing:silverpineforestfish"] = { 21, "Silverpine Forest", 0.423, 0.832, "Silverpine Forest fishing water", 6308 },
    ["catalog:gathering:fishing:tirisfalgladesfish"] = { 18, "Tirisfal Glades", 0.144, 0.527, "Tirisfal Glades fishing water", 6291 },
    ["catalog:gathering:fishing:northenstranglethornfish"] = { 50, "Northern Stranglethorn", 0.263, 0.180, "Northern Stranglethorn fishing water", 6308 },
    ["catalog:gathering:fishing:arathihighlandsfish"] = { 14, "Arathi Highlands", 0.164, 0.539, "Arathi Highlands fishing water", 6308 },
    ["catalog:gathering:fishing:wetlandsfish"] = { 56, "Wetlands", 0.146, 0.396, "Wetlands fishing water", 6308 },
    ["catalog:gathering:fishing:redridgemountainsfish"] = { 49, "Redridge Mountains", 0.123, 0.106, "Redridge Mountains fishing water", 6308 },
    ["catalog:gathering:fishing:westfallfish"] = { 52, "Westfall", 0.458, 0.588, "Westfall fishing water", 6291 },
    ["catalog:gathering:fishing:dunmoroghfish"] = { 27, "Dun Morogh", 0.176, 0.744, "Dun Morogh fishing water", 6291 },
    ["catalog:gathering:fishing:darnassusfish"] = { 89, "Darnassus", 0.324, 0.482, "Darnassus fishing water", 6291 },
    ["catalog:gathering:fishing:azsharafish"] = { 76, "Azshara", 0.048, 0.857, "Azshara fishing water", 6291 },
    ["catalog:gathering:fishing:mulgorefish"] = { 7, "Mulgore", 0.184, 0.648, "Mulgore fishing water", 6289 },
    ["catalog:gathering:fishing:elwynforetsfish"] = { 37, "Elwynn Forest", 0.173, 0.644, "Elwynn Forest fishing water", 6289 },
    ["catalog:gathering:skinning:isleofdornskin"] = { 2248, "Isle of Dorn", 0.255, 0.681, "Isle of Dorn skinnable-creature area", 223512 },
    ["catalog:gathering:misc:eternalair"] = { 120, "The Storm Peaks", 0.457, 0.708, "The Storm Peaks air-elemental area", 35623 },
    ["catalog:gathering:misc:eternalearth"] = { 119, "Sholazar Basin", 0.635, 0.594, "Sholazar Basin earth-elemental area", 35624 },
}

-- The Catalog display names below are abbreviations, legacy labels, or contain
-- spelling variants.  Match them to the canonical names in our AtlasLoot/ATT
-- snapshots so Core/InstanceEntrances can request the live Encounter Journal
-- entrance for every imported instance farm.
local instanceAliases = {
    ["catalog:drops:transmogs:scarletmonastayold"] = "ScarletMonastery",
    ["catalog:drops:transmogs:scarletarmoryold"] = "ScarletMonastery",
    ["catalog:drops:transmogs:brd"] = "BlackrockDepths",
    ["catalog:drops:transmogs:stratholmemainentrence"] = "StratholmeCrusader",
    ["catalog:drops:transmogs:thestockades"] = "TheStockade",
    ["catalog:drops:transmogs:stratholmeserviceenterence"] = "StratholmeGauntlet",
    ["catalog:drops:transmogs:scarletmonastarynew"] = "ScarletMonastery",
    ["catalog:drops:transmogs:scarlethallsnew"] = "ScarletHalls",
    ["catalog:drops:transmogs:scarletgraveyardold"] = "ScarletMonastery",
    ["catalog:drops:transmogs:hellfireramparts"] = "HCHellfireRamparts",
    ["catalog:drops:transmogs:sunwell"] = "SunwellPlateau",
    ["catalog:drops:transmogs:manatombs"] = "AuchManaTombs",
    ["catalog:drops:transmogs:shadowlab"] = "AuchShadowLabyrinth",
    ["catalog:drops:transmogs:botanica"] = "TempestKeepBotanica",
    ["catalog:drops:transmogs:magistersterrece"] = "MagistersTerrace",
    ["catalog:drops:transmogs:shatteredhalls"] = "HCTheShatteredHalls",
    ["catalog:drops:transmogs:sethekkhalls"] = "AuchSethekkHalls",
    ["catalog:drops:transmogs:theunderbog"] = "CFRTheUnderbog",
    ["catalog:drops:transmogs:auchenaicrypts"] = "AuchAuchenaiCrypts",
    ["catalog:drops:transmogs:bloodfurnace"] = "HCBloodFurnace",
    ["catalog:drops:transmogs:steamvaults"] = "CFRTheSteamvault",
    ["catalog:drops:transmogs:themechanar"] = "TempestKeepMechanar",
    ["catalog:drops:transmogs:thearcatraz"] = "TempestKeepArcatraz",
    ["catalog:drops:transmogs:theslavepens"] = "CFRTheSlavePens",
    ["catalog:drops:transmogs:hallsoflightning"] = "UlduarHallsofLightning",
    ["catalog:drops:transmogs:utguardpinnacle"] = "UtgardePinnacle",
    ["catalog:drops:transmogs:ahnkahettheoldkingdom"] = "AhnKahet",
    ["catalog:drops:transmogs:hallsofstone"] = "UlduarHallsofStone",
    ["catalog:drops:transmogs:pitofsaron"] = "FHPitOfSaron",
    ["catalog:drops:transmogs:forgeofsouls"] = "FHTheForgeOfSouls",
    ["catalog:drops:transmogs:throneoftides"] = "ThroneOfTheTides",
    ["catalog:drops:openworldinstances:monastary"] = "ScarletMonastery",
    ["catalog:drops:openworldinstances:scholomace"] = "Scholomance",
    ["catalog:drops:openworldinstances:ulduman"] = "Uldaman",
    ["catalog:drops:openworldinstances:dire"] = "DireMaulEast",
    ["catalog:drops:openworldinstances:stratholme"] = "StratholmeGauntlet",
    ["catalog:drops:openworldinstances:sunken"] = "TheSunkenTemple",
    ["catalog:drops:openworldinstances:scarletmonastary"] = "ScarletMonastery",
    ["catalog:drops:openworldinstances:scholomace"] = "Scholomance",
    ["catalog:drops:openworldinstances:ulduman"] = "Uldaman",
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
