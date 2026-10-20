local _, NS = ...
local Register = NS.RegisterMaterialFarmingSpot
local Items = NS.MaterialFarmingSpots.items
local ITEM_URL = "https://www.wowhead.com/item="
local FISHING_GUIDE = "https://www.wowhead.com/guide/professions/wod/fishing-overview"

-- Dynamic pools, dig sites, lumber and work orders have no invented spawn pins.
-- Current binding/recipe evidence is archived in docs/research/draenor-specialty-2026-10-19.*.
local function Copy(value)
    if type(value) ~= "table" then return value end
    local result = {}
    for key, entry in pairs(value) do result[key] = Copy(entry) end
    return result
end

local function Add(id, name, professions, category, summary, urls, spots, tips, auctionable)
    local sources = { ITEM_URL .. id }
    for _, url in ipairs(urls or {}) do sources[#sources + 1] = url end
    Register({
        itemID = id, itemName = name, expansion = "warlords",
        professions = professions, category = category,
        isRoute = false, auctionable = auctionable ~= false,
        summary = summary, sourceUrls = sources, spots = spots or {}, tips = tips or {},
    })
end

local function Pin(id, mapID, mapName, location, x, y, sources, tips, kind)
    return {
        id = "warlords-specialty-" .. id, mapID = mapID, mapName = mapName,
        location = location, isRoute = false,
        source = "Curated item/NPC comments; the marker is the described source or access anchor",
        sourceUrls = sources, routeType = kind or "mob-farm",
        density = "Variable; no measured hourly yield",
        dropDifficulty = "Chance-based source; availability and competition vary.",
        confidence = "medium", tips = tips,
        coords = { { x = x, y = y, label = location } },
    }
end

local FISH_GROUPS = {
    { flesh = 109137, fish = { 111589, 111595, 111601 } },
    { flesh = 109138, fish = { 111650, 111669, 111676 }, bait = 110274 },
    { flesh = 109139, fish = { 111651, 111668, 111675 }, bait = 110289 },
    { flesh = 109140, fish = { 111652, 111667, 111674 }, bait = 110290 },
    { flesh = 109141, fish = { 111656, 111666, 111673 }, bait = 110291 },
    { flesh = 109142, fish = { 111658, 111665, 111672 }, bait = 110292 },
    { flesh = 109143, fish = { 111659, 111664, 111671 }, bait = 110293 },
    { flesh = 109144, fish = { 111662, 111663, 111670 }, bait = 110294 },
}
local FISH_NAMES = {
    [111589] = "Small Crescent Saberfish",
    [111595] = "Crescent Saberfish",
    [111601] = "Enormous Crescent Saberfish",
    [111650] = "Small Jawless Skulker",
    [111669] = "Jawless Skulker",
    [111676] = "Enormous Jawless Skulker",
    [110274] = "Jawless Skulker Bait",
    [111651] = "Small Fat Sleeper",
    [111668] = "Fat Sleeper",
    [111675] = "Enormous Fat Sleeper",
    [110289] = "Fat Sleeper Bait",
    [111652] = "Small Blind Lake Sturgeon",
    [111667] = "Blind Lake Sturgeon",
    [111674] = "Enormous Blind Lake Sturgeon",
    [110290] = "Blind Lake Sturgeon Bait",
    [111656] = "Small Fire Ammonite",
    [111666] = "Fire Ammonite",
    [111673] = "Enormous Fire Ammonite",
    [110291] = "Fire Ammonite Bait",
    [111658] = "Small Sea Scorpion",
    [111665] = "Sea Scorpion",
    [111672] = "Enormous Sea Scorpion",
    [110292] = "Sea Scorpion Bait",
    [111659] = "Small Abyssal Gulper Eel",
    [111664] = "Abyssal Gulper Eel",
    [111671] = "Enormous Abyssal Gulper Eel",
    [110293] = "Abyssal Gulper Eel Bait",
    [111662] = "Small Blackwater Whiptail",
    [111663] = "Blackwater Whiptail",
    [111670] = "Enormous Blackwater Whiptail",
    [110294] = "Blackwater Whiptail Bait",
}
local names = Copy(FISH_NAMES)
for _, item in ipairs((NS.FarmingItems and NS.FarmingItems.items) or {}) do
    names[item.itemID] = item.itemName
end
local maps = {
    [109137] = 539, [109138] = 543, [109139] = 550, [109140] = 539,
    [109141] = 525, [109142] = 542, [109143] = 542, [109144] = 535,
}
local function FishSpots(flesh, itemID, bait)
    local spots = Copy((Items[flesh] or {}).spots or {})
    -- The older flesh entry mixes three zones in one option. Keep the new
    -- whole-fish/bait marker on the Spires coastline in its own map space.
    if flesh == 109142 then
        spots = { Pin("sea-scorpion-" .. itemID, 542, "Spires of Arak", "East coast; coastal-water scouting anchor",
            0.75, 0.50, { FISHING_GUIDE, ITEM_URL .. "111665" }, {
                "Fish coastal seawater for Sea Scorpions; inland water targets a different species.",
                "The marker identifies the coastline to scout, not a guaranteed fishing-school spawn.",
            }, "coastal-fishing") }
    end
    for _, spot in ipairs(spots) do
        spot.id = spot.id .. "-specialty-" .. itemID
        spot.mapID = maps[flesh]
        spot.isRoute = false
        spot.routeType = "fishing-source-pins"
        spot.sourceUrls = spot.sourceUrls or {}
        spot.sourceUrls[#spot.sourceUrls + 1] = ITEM_URL .. itemID
        spot.tips = spot.tips or {}
        spot.tips[#spot.tips + 1] = bait
            and "This bait is a chance fishing catch in the species' waters; check its Unique limit in bags and bank. It is also available from fishing supplies or cavedwellers."
            or "Sell whole fish or clean the required stack for flesh. Compare both markets before cleaning; this entry does not assume a fixed flesh yield."
    end
    return spots
end
for _, group in ipairs(FISH_GROUPS) do
    for _, id in ipairs(group.fish) do
        Add(id, names[id], { "fishing", "cooking" }, "Whole Fish",
            "Tradeable whole Draenor fish. The three sizes are separate items; cleaning consumes a stack and produces cooking material.",
            { FISHING_GUIDE, ITEM_URL .. group.flesh }, FishSpots(group.flesh, id), {
                "Use the appropriate regional water or schools; fishing skill and schools affect the sizes caught.",
                "Avoid Bladebone Hook automatic cleaning when the whole fish is the sale target.",
            })
    end
    if group.bait then
        local id = group.bait
        Add(id, names[id], { "fishing" }, "Fishing Bait",
            "Tradeable regional bait, obtained while fishing the matching waters; not a vendor-only supply.",
            { FISHING_GUIDE, "https://warcraft.wiki.gg/wiki/Fishing_bait" }, FishSpots(group.flesh, id, true))
    end
end

local felmouthSources = { FISHING_GUIDE, ITEM_URL .. "127991", ITEM_URL .. "128229" }
local felmouthTips = {
    "Fish Felmouth Frenzy Schools in Tanaan inland water; fly around Hellfire Citadel to scout active schools.",
    "Felblight is a possible school-fishing bonus. Bait in open water does not replace fishing the schools for Felblight.",
    "Felmouth Frenzy is a tradeable usable fish; the Felmouth Frenzy Lunker is a separate bound quest item.",
}
Add(127991, "Felmouth Frenzy", { "fishing" }, "Fish",
    "Tradeable Tanaan fish; school fishing can also produce Felblight. Schools move, so no fixed spawn is asserted.",
    felmouthSources, nil, felmouthTips)
Add(128229, "Felmouth Frenzy Bait", { "fishing" }, "Fishing Bait",
    "Tradeable fishing catch from Tanaan; increases the chance of Felmouth Frenzy in Tanaan, not the garrison pond.",
    felmouthSources, nil, felmouthTips)

local scrapSpots = Copy((Items[110609] or {}).spots or {})
for _, spot in ipairs(scrapSpots) do
    spot.id = spot.id .. "-scraps"
    spot.isRoute = false
    spot.tips = spot.tips or {}
    spot.tips[#spot.tips + 1] = "Scraps are the lower-skill skinning result. Ten Raw Beast Hide Scraps combine into one Raw Beast Hide; higher skill can favor whole hides."
end
Add(110610, "Raw Beast Hide Scraps", { "skinning", "leatherworking" }, "Leather Scrap",
    "Tradeable lower-skill Draenor skinning material. Combine TEN scraps into one Raw Beast Hide; scraps are not a guaranteed extra drop from every skin.",
    { ITEM_URL .. "110609", "https://www.wow-professions.com/farming/raw-beast-hide-farming" }, scrapSpots)
Add(114931, "Cerulean Pigment", { "inscription" }, "Pigment",
    "Tradeable processed reagent from milling Draenor herbs, used for Warbinder's Ink, War Paints and housing decor. Milling yield is random; no fixed per-pigment composition is assigned.",
    { "https://www.wowhead.com/spell=190381", "https://www.wowhead.com/spell=178497" }, nil, {
        "Milling and mass milling require Inscription. Process gathered or purchased herbs; this entry adds no herb route.",
        "War Paints bind on pickup, while Cerulean Pigment and Warbinder's Ink can be sold.",
    })

local eggSources = { ITEM_URL .. "128499", "https://www.wowhead.com/guide/tanaan-jungle", "https://www.wowhead.com/spell=190788" }
local eggTips = {
    "Kill and loot Greater Axebeaks; check ground birds, logs and branches near 48.3,62.6 through 50.6,62.3.",
    "Fel Egg is normal kill loot, not a skinning reagent. Skinning the corpse is an optional separate byproduct.",
    "Fel Eggs and Ham consumes two eggs and one Fel Ham; the recipe drops from Lok'goron Hashslinger near Ironhold Harbor, 40.0,46.0.",
}
Add(128499, "Fel Egg", { "cooking" }, "Meat", "Tradeable Tanaan axebeak ingredient for Fel Eggs and Ham.", eggSources,
    { Pin("fel-egg-axebeaks", 534, "Tanaan Jungle", "Greater Axebeak log and ground birds", 0.4831, 0.6260, eggSources, eggTips) }, eggTips)
local hamSources = { ITEM_URL .. "128500", "https://warcraft.wiki.gg/wiki/Diretusk_Sow", "https://warcraft.wiki.gg/wiki/Hulking_Diretusk" }
local hamTips = {
    "Kill and loot Diretusk Sows or Hulking Diretusks north of Vol'mar; Fel Ham is kill loot, not a skinning drop.",
    "Combine this farm with raw boar meat, fur and optional skinning. Drops are random, with no assumed hourly rate.",
    "The source is the boar area north of Vol'mar. No exact spawn pin is asserted for these roaming packs.",
}
Add(128500, "Fel Ham", { "cooking" }, "Meat", "Tradeable Tanaan boar ingredient for Fel Eggs and Ham; farm Diretusk boars north of Vol'mar.", hamSources, nil, hamTips)

local sorcerous = {
    { 113261, "Sorcerous Fire", { "alchemy", "blacksmithing", "enchanting", "engineering" } },
    { 113262, "Sorcerous Water", { "alchemy", "inscription", "leatherworking", "tailoring" } },
    { 113263, "Sorcerous Earth", { "blacksmithing", "inscription", "jewelcrafting", "leatherworking" } },
    { 113264, "Sorcerous Air", { "enchanting", "engineering", "jewelcrafting", "tailoring" } },
}
for _, entry in ipairs(sorcerous) do
    Add(entry[1], entry[2], entry[3], "Elemental",
        "Tradeable Draenor elemental byproduct from the listed professions' material crafts and garrison work orders. This is not a Mote/Primal or an elemental-mob drop.",
        { "https://www.wowhead.com/guide/garrisons/buildings" }, nil, {
            "Use the listed professions' Draenor material cooldowns and profession-building work orders; bonus elements are random.",
            "Queue work orders alongside your main material production. A suitable follower can improve profession-building output where applicable.",
            "Alchemy can transmute other Sorcerous elements into this one. Conversion recipes are archived as alternatives, without creating circular component costs.",
        })
end

local archaeologySources = { "https://www.cymre.com/2014/08/21/draenor-archaeology/" }
for _, entry in ipairs({
    { 108439, "Draenor Clan Orator Cane", "Draenor Clans" },
    { 109584, "Ogre Missive", "Ogre" },
    { 109585, "Arakkoa Cipher", "Arakkoa" },
}) do
    Add(entry[1], entry[2], { "miscellaneous" }, "Archaeology Keystone",
        "Tradeable " .. entry[3] .. " keystone from matching active Draenor dig sites and occasional archaeology guardian loot. Dig sites rotate; fragments and restored artifacts are separate items.",
        archaeologySources, nil, {
            "Use Archaeology Survey inside an active matching-culture dig site. Follow the map's current dig sites rather than a permanent spawn marker.",
            "Loot spectral guardians that occasionally appear while surveying for extra fragments and a possible keystone.",
            "Sell the keystone itself instead of socketing it into a solve. Bound archaeology fragments are not Auction House products.",
        })
end

local pearlSources = { ITEM_URL .. "108739", ITEM_URL .. "108738" }
local pearlTips = {
    "Enter the cave near 22,9 in northern Frostfire Ridge and fish the Giant Draenor Clam treasure pool near 21.8,9.7.",
    "Open the bound Giant Draenor Clam for the tradeable Pretty Draenor Pearl toy. Sell the pearl before learning it.",
    "This is a once-per-character treasure (quest 34907), not an endlessly repeatable clam farm. Check treasure completion before travelling.",
}
Add(108739, "Pretty Draenor Pearl", { "fishing" }, "Toy",
    "Tradeable toy inside the bound Giant Draenor Clam fishing treasure. One treasure per character; the clam itself cannot be auctioned.", pearlSources,
    { Pin("pretty-pearl-cave", 525, "Frostfire Ridge", "Giant Draenor Clam cave pool", 0.218, 0.097, pearlSources, pearlTips, "fishing-treasure") }, pearlTips)

local medallionSources = { ITEM_URL .. "128315", "https://www.wowhead.com/npc=95053/deathtalon", "https://www.cymre.com/2015/05/22/tanaan-jungle-rares/" }
local medallionTips = {
    "Kill the four Hellbane rares: Deathtalon, Doomroller, Terrorfist and Vengeance. Each has a chance to drop a tradeable Medallion of the Legion.",
    "Loot eligibility is once per rare per day per character; repeated kills on the same day do not create unlimited attempts.",
    "Watch the zone-wide spawn announcements. Pins indicate reported encounter areas; Terrorfist patrols and exact positions can vary.",
    "The Eldritch Horrors garrison mission is another source when offered. Do not assume that a rare mission will appear on demand.",
}
local medallionSpots = {}
for _, entry in ipairs({ { "deathtalon", 0.232, 0.404 }, { "doomroller", 0.47, 0.52 }, { "terrorfist", 0.15, 0.63 }, { "vengeance", 0.32, 0.73 } }) do
    medallionSpots[#medallionSpots + 1] = Pin("medallion-" .. entry[1], 534, "Tanaan Jungle", entry[1] .. " encounter area", entry[2], entry[3], medallionSources, medallionTips, "daily-rare")
end
Add(128315, "Medallion of the Legion", { "miscellaneous" }, "Reputation Item",
    "Tradeable Draenor reputation consumable from Tanaan Hellbane rares, with daily per-character loot limits; also a rare garrison mission reward.", medallionSources, medallionSpots, medallionTips)
for _, entry in ipairs({ { 128313, "Huge Ogre Cache", "Ogrecoming Adversity" }, { 128314, "Frozen Arms of a Hero", "Blizzard Convention" } }) do
    Add(entry[1], entry[2], { "miscellaneous" }, "Mission Reward",
        "Tradeable reward from the rare Draenor garrison follower mission " .. entry[3] .. ". This is a time-gated mission source, not an open-world grind.",
        { "https://us.forums.blizzard.com/en/wow/t/garrison-treasure-missions-not-showing/2248421" }, nil, {
            "Develop your garrison and follower roster, then check the mission table for the named mission and its displayed follower requirements.",
            "Mission offers are random. Current player reports include eligible rosters receiving few or no treasure missions; availability is not guaranteed.",
            "Keep the reward item unopened when selling it. Consuming the cache or follower upgrade removes the saleable item.",
        })
end

Add(251766, "Shadowmoon Lumber", { "miscellaneous" }, "Warband Housing Lumber",
    "Warband-bound Draenor housing input, harvested from housing lumber trees after the lumber introduction quest. Cannot be sold; finished decor can be auctioned.",
    { "https://www.wowhead.com/news/shadowmoon-lumber-returned-to-warlords-of-draenor-zones-in-the-midnight-pre-380372",
      "https://worldofwarcraft.blizzard.com/en-us/news/24247147/professions-unpacked-craft-housing-decor-with-reagents-from-every-era" }, nil, {
        "Complete Lumber For You and look for axe-marked housing trees in Draenor. Housing lumber is separate from the old garrison Lumber Mill resource.",
        "Draenor trees became harvestable in the Midnight pre-patch; older advice to exchange Outland lumber predates that change.",
        "Scout wooded areas as nodes become available. No fixed node positions or guaranteed per-hour yield are asserted.",
    }, false)

for _, item in ipairs((NS.FarmingItems and NS.FarmingItems.items) or {}) do
    if item.expansion == "warlords" and item.tag == "Darkmoon Card" then
        Add(item.itemID, item.itemName, { "inscription" }, "Darkmoon Card",
            "Tradeable possible result of Darkmoon Card of Draenor. A craft does not guarantee this specific card; collect the eight matching cards to assemble a deck.",
            { "https://www.wowhead.com/spell=163294" }, nil, {
                "Each attempt consumes the recipe's War Paints and Sorcerous Water and yields a random card. War Paints bind on pickup.",
                "Do not value every possible card as if each attempt produced it. Specific cards deliberately have no deterministic component cost.",
                "Complete decks open directly into their matching trinket; a Darkmoon Faire hand-in is not required for these Draenor decks.",
            })
        Items[item.itemID].randomOutput = true
        Items[item.itemID].sourceSpellID = 163294
    end
end

-- Existing specialty farms are also point options; preserve their supplied
-- sources/coordinates and keep the separately maintained ore/herb routes intact.
for _, id in ipairs({ 110609, 111557, 109693, 115502, 111245, 115504, 113588, 118472, 120945, 127759,
    109131, 109132, 109133, 109134, 109135, 109136, 109137, 109138, 109139, 109140, 109141, 109142, 109143, 109144 }) do
    local item = Items[id]
    if item then
        item.isRoute = false
        for _, spot in ipairs(item.spots or {}) do spot.isRoute = false end
    end
end
if Items[120945] then
    Items[120945].auctionable = false
    Items[120945].summary = "Bound Draenor crafting input; cannot be sold on the Auction House. Gather through eligible Draenor gathering or mob/treasure sources for recipes requiring Primal Spirits."
end
