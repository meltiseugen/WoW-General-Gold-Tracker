local _, NS = ...

-- Base Materials only. Composed recipes and their component chains are excluded.
-- Item/processing identities: docs/research/pandaria-base-map-source-index-2026-10-21.json.
-- Existing gathering geometry retains its original provenance and qualifications.
local SOURCE_ITEMS = {
    [72092] = { name = "Ghost Iron Ore" },
    [72093] = { name = "Kyparite" },
    [72094] = { name = "Black Trillium Ore" },
    [72103] = { name = "White Trillium Ore" },
    [72162] = { name = "Sha-Touched Leather" },
    [72234] = { name = "Green Tea Leaf" },
    [72235] = { name = "Silkweed" },
    [72237] = { name = "Rain Poppy" },
    [72238] = { name = "Golden Lotus" },
    [72988] = { name = "Windwool Cloth" },
    [74249] = { name = "Spirit Dust" },
    [74252] = { name = "Small Ethereal Shard" },
    [74833] = { name = "Raw Tiger Steak" },
    [74834] = { name = "Mushan Ribs" },
    [74837] = { name = "Raw Turtle Meat" },
    [74838] = { name = "Raw Crab Meat" },
    [74839] = { name = "Wildfowl Breast" },
    [74840] = { name = "Green Cabbage" },
    [74841] = { name = "Juicycrunch Carrot" },
    [74842] = { name = "Mogu Pumpkin" },
    [74843] = { name = "Scallions" },
    [74844] = { name = "Red Blossom Leek" },
    [74846] = { name = "Witchberries" },
    [74847] = { name = "Jade Squash" },
    [74848] = { name = "Striped Melon" },
    [74849] = { name = "Pink Turnip" },
    [74850] = { name = "White Turnip" },
    [74856] = { name = "Jade Lungfish" },
    [74857] = { name = "Giant Mantis Shrimp" },
    [74859] = { name = "Emperor Salmon" },
    [74860] = { name = "Redbelly Mandarin" },
    [74861] = { name = "Tiger Gourami" },
    [74863] = { name = "Jewel Danio" },
    [74864] = { name = "Reef Octopus" },
    [74865] = { name = "Krasarang Paddlefish" },
    [74866] = { name = "Golden Carp" },
    [75014] = { name = "Raw Crocolisk Belly" },
    [76130] = { name = "Tiger Opal" },
    [76133] = { name = "Lapis Lazuli" },
    [76134] = { name = "Sunstone" },
    [76135] = { name = "Roguestone" },
    [76136] = { name = "Pandarian Garnet" },
    [76137] = { name = "Alexandrite" },
    [76570] = { name = "Perfect Rigid Lapis Lazuli", spellID = 107617, gemID = 76133, cutName = "Rigid Lapis Lazuli" },
    [76571] = { name = "Perfect Stormy Lapis Lazuli", spellID = 107621, gemID = 76133, cutName = "Stormy Lapis Lazuli" },
    [76572] = { name = "Perfect Sparkling Lapis Lazuli", spellID = 107620, gemID = 76133, cutName = "Sparkling Lapis Lazuli" },
    [76573] = { name = "Perfect Solid Lapis Lazuli", spellID = 107619, gemID = 76133, cutName = "Solid Lapis Lazuli" },
    [76574] = { name = "Perfect Misty Alexandrite", spellID = 107605, gemID = 76137, cutName = "Misty Alexandrite" },
    [76575] = { name = "Perfect Piercing Alexandrite", spellID = 107607, gemID = 76137, cutName = "Piercing Alexandrite" },
    [76576] = { name = "Perfect Lightning Alexandrite", spellID = 107604, gemID = 76137, cutName = "Lightning Alexandrite" },
    [76577] = { name = "Perfect Sensei's Alexandrite", spellID = 107611, gemID = 76137, cutName = "Sensei's Alexandrite" },
    [76578] = { name = "Perfect Effulgent Alexandrite", spellID = 107599, gemID = 76137, cutName = "Effulgent Alexandrite" },
    [76579] = { name = "Perfect Zen Alexandrite", spellID = 107616, gemID = 76137, cutName = "Zen Alexandrite" },
    [76580] = { name = "Perfect Balanced Alexandrite", spellID = 107598, gemID = 76137, cutName = "Balanced Alexandrite" },
    [76581] = { name = "Perfect Vivid Alexandrite", spellID = 107615, gemID = 76137, cutName = "Vivid Alexandrite" },
    [76582] = { name = "Perfect Turbid Alexandrite", spellID = 107614, gemID = 76137, cutName = "Turbid Alexandrite" },
    [76583] = { name = "Perfect Radiant Alexandrite", spellID = 107609, gemID = 76137, cutName = "Radiant Alexandrite" },
    [76584] = { name = "Perfect Shattered Alexandrite", spellID = 107612, gemID = 76137, cutName = "Shattered Alexandrite" },
    [76585] = { name = "Perfect Energized Alexandrite", spellID = 107600, gemID = 76137, cutName = "Energized Alexandrite" },
    [76587] = { name = "Perfect Regal Alexandrite", spellID = 107610, gemID = 76137, cutName = "Regal Alexandrite" },
    [76588] = { name = "Perfect Forceful Alexandrite", spellID = 107601, gemID = 76137, cutName = "Forceful Alexandrite" },
    [76590] = { name = "Perfect Puissant Alexandrite", spellID = 107608, gemID = 76137, cutName = "Puissant Alexandrite" },
    [76591] = { name = "Perfect Steady Alexandrite", spellID = 107613, gemID = 76137, cutName = "Steady Alexandrite" },
    [76592] = { name = "Perfect Deadly Tiger Opal", spellID = 107649, gemID = 76130, cutName = "Deadly Tiger Opal" },
    [76593] = { name = "Perfect Crafty Tiger Opal", spellID = 107648, gemID = 76130, cutName = "Crafty Tiger Opal" },
    [76594] = { name = "Perfect Potent Tiger Opal", spellID = 107657, gemID = 76130, cutName = "Potent Tiger Opal" },
    [76595] = { name = "Perfect Inscribed Tiger Opal", spellID = 107653, gemID = 76130, cutName = "Inscribed Tiger Opal" },
    [76596] = { name = "Perfect Polished Tiger Opal", spellID = 107656, gemID = 76130, cutName = "Polished Tiger Opal" },
    [76597] = { name = "Perfect Resolute Tiger Opal", spellID = 107659, gemID = 76130, cutName = "Resolute Tiger Opal" },
    [76598] = { name = "Perfect Stalwart Tiger Opal", spellID = 107663, gemID = 76130, cutName = "Stalwart Tiger Opal" },
    [76599] = { name = "Perfect Champion's Tiger Opal", spellID = 107647, gemID = 76130, cutName = "Champion's Tiger Opal" },
    [76600] = { name = "Perfect Deft Tiger Opal", spellID = 107650, gemID = 76130, cutName = "Deft Tiger Opal" },
    [76601] = { name = "Perfect Wicked Tiger Opal", spellID = 107666, gemID = 76130, cutName = "Wicked Tiger Opal" },
    [76602] = { name = "Perfect Reckless Tiger Opal", spellID = 107658, gemID = 76130, cutName = "Reckless Tiger Opal" },
    [76603] = { name = "Perfect Fierce Tiger Opal", spellID = 107651, gemID = 76130, cutName = "Fierce Tiger Opal" },
    [76604] = { name = "Perfect Adept Tiger Opal", spellID = 107645, gemID = 76130, cutName = "Adept Tiger Opal" },
    [76605] = { name = "Perfect Keen Tiger Opal", spellID = 107654, gemID = 76130, cutName = "Keen Tiger Opal" },
    [76606] = { name = "Perfect Artful Tiger Opal", spellID = 107646, gemID = 76130, cutName = "Artful Tiger Opal" },
    [76607] = { name = "Perfect Fine Tiger Opal", spellID = 107652, gemID = 76130, cutName = "Fine Tiger Opal" },
    [76608] = { name = "Perfect Skillful Tiger Opal", spellID = 107661, gemID = 76130, cutName = "Skillful Tiger Opal" },
    [76609] = { name = "Perfect Lucent Tiger Opal", spellID = 107655, gemID = 76130, cutName = "Lucent Tiger Opal" },
    [76610] = { name = "Perfect Tenuous Tiger Opal", spellID = 107665, gemID = 76130, cutName = "Tenuous Tiger Opal" },
    [76611] = { name = "Perfect Willful Tiger Opal", spellID = 107667, gemID = 76130, cutName = "Willful Tiger Opal" },
    [76612] = { name = "Perfect Splendid Tiger Opal", spellID = 107662, gemID = 76130, cutName = "Splendid Tiger Opal" },
    [76613] = { name = "Perfect Resplendent Tiger Opal", spellID = 107660, gemID = 76130, cutName = "Resplendent Tiger Opal" },
    [76614] = { name = "Perfect Glinting Roguestone", spellID = 107631, gemID = 76135, cutName = "Glinting Roguestone" },
    [76615] = { name = "Perfect Accurate Roguestone", spellID = 107627, gemID = 76135, cutName = "Accurate Roguestone" },
    [76616] = { name = "Perfect Veiled Roguestone", spellID = 107639, gemID = 76135, cutName = "Veiled Roguestone" },
    [76617] = { name = "Perfect Retaliating Roguestone", spellID = 107635, gemID = 76135, cutName = "Retaliating Roguestone" },
    [76618] = { name = "Perfect Etched Roguestone", spellID = 107630, gemID = 76135, cutName = "Etched Roguestone" },
    [76619] = { name = "Perfect Mysterious Roguestone", spellID = 107633, gemID = 76135, cutName = "Mysterious Roguestone" },
    [76620] = { name = "Perfect Purified Roguestone", spellID = 107634, gemID = 76135, cutName = "Purified Roguestone" },
    [76621] = { name = "Perfect Shifting Roguestone", spellID = 107636, gemID = 76135, cutName = "Shifting Roguestone" },
    [76622] = { name = "Perfect Guardian's Roguestone", spellID = 107632, gemID = 76135, cutName = "Guardian's Roguestone" },
    [76623] = { name = "Perfect Timeless Roguestone", spellID = 107638, gemID = 76135, cutName = "Timeless Roguestone" },
    [76624] = { name = "Perfect Defender's Roguestone", spellID = 107628, gemID = 76135, cutName = "Defender's Roguestone" },
    [76625] = { name = "Perfect Sovereign Roguestone", spellID = 107637, gemID = 76135, cutName = "Sovereign Roguestone" },
    [76626] = { name = "Perfect Delicate Pandarian Garnet", spellID = 107624, gemID = 76136, cutName = "Delicate Pandarian Garnet" },
    [76627] = { name = "Perfect Precise Pandarian Garnet", spellID = 107626, gemID = 76136, cutName = "Precise Pandarian Garnet" },
    [76628] = { name = "Perfect Brilliant Pandarian Garnet", spellID = 107623, gemID = 76136, cutName = "Brilliant Pandarian Garnet" },
    [76629] = { name = "Perfect Flashing Pandarian Garnet", spellID = 107625, gemID = 76136, cutName = "Flashing Pandarian Garnet" },
    [76630] = { name = "Perfect Bold Pandarian Garnet", spellID = 107622, gemID = 76136, cutName = "Bold Pandarian Garnet" },
    [76631] = { name = "Perfect Smooth Sunstone", spellID = 107643, gemID = 76134, cutName = "Smooth Sunstone" },
    [76632] = { name = "Perfect Subtle Sunstone", spellID = 107644, gemID = 76134, cutName = "Subtle Sunstone" },
    [76633] = { name = "Perfect Quick Sunstone", spellID = 107642, gemID = 76134, cutName = "Quick Sunstone" },
    [76634] = { name = "Perfect Fractured Sunstone", spellID = 107640, gemID = 76134, cutName = "Fractured Sunstone" },
    [76635] = { name = "Perfect Mystic Sunstone", spellID = 107641, gemID = 76134, cutName = "Mystic Sunstone" },
    [79010] = { name = "Snow Lily" },
    [79011] = { name = "Fool's Cap" },
    [79101] = { name = "Prismatic Scale" },
    [79251] = { name = "Shadow Pigment" },
    [79253] = { name = "Misty Pigment" },
    [79868] = { name = "Pandaren Pottery Shard" },
    [79869] = { name = "Mogu Statue Piece" },
    [80433] = { name = "Blood Spirit" },
    [83064] = { name = "Spinefish" },
    [85506] = { name = "Viseclaw Meat" },
    [86592] = { name = "Hozen Peace Pipe" },
    [89112] = { name = "Mote of Harmony" },
    [89639] = { name = "Desecrated Herb" },
    [89676] = { name = "Perfect Tense Roguestone", spellID = 130655, gemID = 76135, cutName = "Tense Roguestone" },
    [89679] = { name = "Perfect Assassin's Roguestone", spellID = 130656, gemID = 76135, cutName = "Assassin's Roguestone" },
    [90407] = { name = "Sparkling Shard" },
    [92426] = { name = "Sealed Tome of the Lost Legion" },
    [93707] = { name = "Perfect Nimble Alexandrite", spellID = 107606, gemID = 76137, cutName = "Nimble Alexandrite" },
    [94288] = { name = "Giant Dinosaur Bone" },
    [94289] = { name = "Haunting Spirit" },
    [95373] = { name = "Mantid Amber Sliver" },
    [102218] = { name = "Spirit of War" },
    [105718] = { name = "Sha Crystal Fragment" },
    [251763] = { name = "Bamboo Lumber" },
}

local DATE = "2026-10-21"
if NS.PandariaBaseMaterialMapAudit and NS.PandariaBaseMaterialMapAudit.researchedAt == DATE then return end
local items = NS.MaterialFarmingSpots.items
local catalogByID = {}
for _, item in ipairs(NS.FarmingItems and NS.FarmingItems.items or {}) do
    catalogByID[item.itemID] = item
end

local mapIDs = {
    thejadeforest = 371, valleyofthefourwinds = 376, kunlaisummit = 379,
    townlongsteppes = 388, valeofeternalblossoms = 390, krasarangwilds = 418,
    dreadwastes = 422, theveiledstair = 433, isleofthunder = 504,
    isleofgiants = 507, timelessisle = 554,
}
local allowedMapIDs = { [1530] = true }
for _, mapID in pairs(mapIDs) do allowedMapIDs[mapID] = true end
local mapLabels = {
    [371] = "The Jade Forest", [376] = "Valley of the Four Winds", [379] = "Kun-Lai Summit",
    [388] = "Townlong Steppes", [390] = "Vale of Eternal Blossoms", [418] = "Krasarang Wilds",
    [422] = "Dread Wastes", [433] = "The Veiled Stair", [504] = "Isle of Thunder",
    [507] = "Isle of Giants", [554] = "Timeless Isle", [1530] = "Vale of Eternal Blossoms",
}

local function Copy(values)
    local copy = {}
    for key, value in pairs(values or {}) do copy[key] = value end
    return copy
end

local function Merge(...)
    local result, seen = {}, {}
    for _, values in ipairs({ ... }) do
        for _, value in ipairs(values or {}) do
            if not seen[value] then result[#result + 1] = value; seen[value] = true end
        end
    end
    return result
end

local function ItemURL(itemID) return "https://www.wowhead.com/item=" .. tostring(itemID) end
local function SpellURL(spellID) return "https://www.wowhead.com/spell=" .. tostring(spellID) end
local function IsBase(itemID)
    local row = catalogByID[itemID]
    return SOURCE_ITEMS[itemID] and row and row.expansion == "mists"
        and (type(row.components) ~= "table" or #row.components == 0)
end

local audit = { researchedAt = DATE, scope = "Pandaria base materials only", items = {}, rejectedSpots = {} }
for itemID, source in pairs(SOURCE_ITEMS) do
    if IsBase(itemID) and items[itemID] then
        local item = items[itemID]
        item.itemName = source.name
        item.researchedAt = DATE
        item.sourceUrls = Merge(item.sourceUrls or {}, { ItemURL(itemID) }, source.spellID and { SpellURL(source.spellID) } or {})
        local spots = {}
        for _, original in ipairs(item.spots or {}) do
            local spot = Copy(original)
            spot.mapID = tonumber(spot.mapID) or mapIDs[tostring(spot.mapName or ""):lower():gsub("[^%a]", "")]
            if allowedMapIDs[spot.mapID] then
                spot.mapName = mapLabels[spot.mapID]
                spot.tips = Copy(spot.tips)
                spot.sourceUrls = Merge(spot.sourceUrls or {}, item.sourceUrls)
                spot.density = spot.density or "Source locations; yield not measured in Retail"
                spots[#spots + 1] = spot
            else
                audit.rejectedSpots[#audit.rejectedSpots + 1] = { itemID = itemID, spotID = spot.id, mapID = spot.mapID }
            end
        end
        item.spots = spots
    end
end

local RANCH = "https://warcraft.wiki.gg/wiki/Sunsong_Ranch"
local function AddPoint(itemID, mapID, mapName, location, x, y, action, tips, urls)
    if not IsBase(itemID) then return end
    local item = items[itemID]
    item.spots[#item.spots + 1] = {
        id = "mists-base-point-" .. itemID .. "-" .. location:lower():gsub("[^%w]+", "-"),
        mapID = mapID, mapName = mapName, location = location, isRoute = false,
        routeType = "researched-source-anchor", farmAction = action, tips = tips,
        density = "Named source area; not benchmarked in Retail",
        dropDifficulty = "Reported source-area anchor, not a guaranteed spawn or yield.",
        source = "Item-specific source reports reviewed " .. DATE,
        sourceUrls = Merge(item.sourceUrls, urls), confidence = "medium",
        coords = { { x = x, y = y, label = location } },
    }
end

-- Repair specifically identified map mix-ups without rewriting the supplied routes.
local function RemovePoints(itemID, predicate)
    local spots = {}
    for _, spot in ipairs(items[itemID].spots or {}) do
        local coords = {}
        for _, coord in ipairs(spot.coords or {}) do
            if not predicate(spot, coord) then
                coords[#coords + 1] = coord
            else
                audit.rejectedSpots[#audit.rejectedSpots + 1] = { itemID = itemID, spotID = spot.id, coordinateLabel = coord.label }
            end
        end
        spot.coords = coords
        if #coords > 0 then spots[#spots + 1] = spot end
    end
    items[itemID].spots = spots
end
RemovePoints(74863, function(_, coord) return coord.label == "Timeless Isle fallback pool" end)
RemovePoints(83064, function(spot, coord)
    return spot.id == "mists-fishing-dread-wastes-gokklok-giant-mantis-shrimp" or coord.label == "Lake of Stars backup"
end)
for _, itemID in ipairs({ 74857, 74864 }) do
    RemovePoints(itemID, function(spot, coord)
        return spot.id == "mists-fishing-dread-wastes-gokklok-giant-mantis-shrimp" and coord.label == "Lake of Stars side water"
    end)
end
AddPoint(83064, 422, "Dread Wastes", "Lake of Stars inland Spinefish water", 0.65, 0.59,
    "Fish inland sha-touched water and Spinefish schools. The nearby coastal Giant Mantis Shrimp schools are a different source.",
    { "Keep to the inland lake; coastal shrimp water is not a Spinefish farm.", "Check school names before fishing and move between active schools." },
    { ItemURL(83064), "https://www.elsanglin.com/fish/spinefish.html" })

AddPoint(72988, 418, "Krasarang Wilds", "Korjan Reavers outside Sentinel Basecamp", 0.25, 0.32,
    "Kill and loot the humanoid attackers for Windwool Cloth; this is a reported alternative to the Dread Wastes mantid packs.",
    { "Quest phasing and nearby NPC combat can affect tagging and availability.", "A Tailor's applicable Cloth Scavenging bonus can improve cloth recovery; compare results over a short test lap." },
    { ItemURL(72988), "https://warcraft.wiki.gg/wiki/Windwool_Cloth" })
AddPoint(86592, 379, "Kun-Lai Summit", "Scritch northern patrol check", 0.448, 0.636,
    "Search Scritch's reported patrol area and defeat him for a chance at Hozen Peace Pipe.",
    { "Check both the northern and southern patrol anchors before assuming the rare is absent.", "The consumable cooldown is separate from the NPC respawn timer; a kill does not guarantee the pipe." },
    { "https://www.wowhead.com/guide/mists-of-pandaria-rare-elite-and-rare-item-locations-1452", ItemURL(86592) })

for _, itemID in ipairs({ 74863, 74866, 74859, 74865 }) do
    AddPoint(itemID, 554, "Timeless Isle", "Ruby Lake open-water fishing", 0.6566, 0.3027,
        "Fish Ruby Lake open water for the documented mixed Pandaria freshwater catch table, including " .. items[itemID].itemName .. ".",
        { "This is an open-water alternative; do not wait for a school to appear.", "Reaching the elevated lake can require an appropriate island-access method. Catch proportions and access can change, so test before committing a long session." },
        { ItemURL(itemID), "https://www.wowhead.com/item=94933/tiny-blue-carp" })
end
for _, area in ipairs({
    { "Widening Deep freshwater pools", 0.58, 0.86 },
    { "Lake north of Niuzao Temple", 0.35, 0.52 },
    { "Southeastern Townlong small lake", 0.82, 0.88 },
}) do
    AddPoint(74860, 388, "Townlong Steppes", area[1], area[2], area[3],
        "Search the reported freshwater pool area for Redbelly Mandarin schools; other freshwater schools can share the area.",
        { "Check the school name before casting; Emperor Salmon can occupy nearby pool spots.", "Cycle the named lakes if the first area has no suitable active pools. Historical observations are not guaranteed pool respawns." },
        { ItemURL(74860), "https://www.wowhead.com/guide/mop-fishing-and-anglers-overview-1069" })
end
for _, itemID in ipairs({ 74857, 74864 }) do
    AddPoint(itemID, 418, "Krasarang Wilds", "Nayeli Lagoon coastal schools", 0.48, 0.94,
        "Follow the coastal schools for Giant Mantis Shrimp and Reef Octopus; fish the school matching the selected material.",
        { "This is coastal water. Pool species can differ between nearby schools.", "Finish suitable pools and move along the coast; do not interpret the marker as a permanent school spawn." },
        { ItemURL(74857), ItemURL(74864) })
end
AddPoint(74866, 376, "Valley of the Four Winds", "Yan-Zhe River bridge open water", 0.8666, 0.1937,
    "Fish the river's open water for Golden Carp, rather than targeting a named school for a different fish.",
    { "Golden Carp is a common open-water catch; compare this with fishing the valuable schools you also need.", "The coordinate is a reported access point, not a fixed fish spawn." }, { ItemURL(74866) })
AddPoint(74837, 422, "Dread Wastes", "Lake of Stars turtle shoreline", 0.642, 0.5545,
    "Kill and loot the shoreline turtles for Raw Turtle Meat; skin eligible corpses separately if useful.",
    { "This lake also has crocolisks, so select turtle targets when prioritizing turtle meat.", "Use this as a Dread Wastes alternative to Windward Isle and the Valley river turtles." },
    { ItemURL(74837), ItemURL(79101), "https://www.wowhead.com/guide/vegetables-and-you-1315" })

local function AddRanch(itemID, seed, action)
    if not IsBase(itemID) then return end
    local item = items[itemID]
    item.spots[#item.spots + 1] = {
        id = "mists-base-ranch-" .. itemID, mapID = 376, mapName = "Valley of the Four Winds",
        location = "Sunsong Ranch: " .. seed, routeType = "daily-farm-plot", isRoute = false,
        farmAction = action, density = "Personal farm plots; daily harvest",
        dropDifficulty = "Tillers farm and seed unlocks are required; this supplements outdoor gathering.",
        source = "Sunsong Ranch profession-seed table", sourceUrls = { ItemURL(itemID), RANCH },
        tips = {
            "Unlock the farm and check the seed's Tillers reputation requirement before planning this source.",
            "Harvest mature plants and replant for the next daily cycle; this is not a continuous gathering loop.",
            "Specialty seeds have their own random output rules; do not apply the vegetable bonus-crop forecast to them.",
        },
        coords = { { x = 0.528, y = 0.482, label = "Sunsong Ranch plots" } }, confidence = "medium",
    }
end
for _, itemID in ipairs({ 72092, 72094, 72103 }) do
    AddRanch(itemID, "Snakeroot Seed", "Harvest Snakeroot plants for Ghost Iron and randomly colored Trillium ore; a particular Trillium color is not guaranteed.")
end
for _, itemID in ipairs({ 72234, 72235, 72237, 79010, 79011, 72238 }) do
    AddRanch(itemID, "Enigma Seed", "Harvest Enigma plants for random Pandaria herbs; the selected herb is not a guaranteed output.")
end
AddRanch(72988, "Windshear Cactus Seed", "Harvest Windshear Cactus plants for Windwool Cloth; bolts can also be a bonus output.")

local ORES = { 72092, 72093, 72094, 72103 }
local HERBS = { 72234, 72235, 72237, 79010, 79011, 89639 }
local GEM_GUIDE = "https://www.wowhead.com/guide/mists-of-pandaria-jewelcrafting-overview-1638"
local MILLING_GUIDE = "https://warcraft.wiki.gg/wiki/Shadow_Pigment"

local function AddInputMaps(itemID, inputIDs, action, tips, urls)
    if not IsBase(itemID) then return end
    local item = items[itemID]
    item.isRoute = false
    item.mapInputItemIDs = Copy(inputIDs) -- Acquisition guidance, never guaranteed recipe components.
    for _, inputID in ipairs(inputIDs) do
        local input = items[inputID]
        for _, original in ipairs(input and input.spots or {}) do
            if original.mapID and allowedMapIDs[original.mapID] and #((original or {}).coords or {}) > 0 then
                local spot = Copy(original)
                spot.id = "mists-base-input-" .. itemID .. "-" .. inputID .. "-" .. tostring(original.id)
                spot.location = input.itemName .. " input: " .. tostring(original.location or original.mapName)
                spot.dropdownLabel = original.mapName .. ": " .. spot.location
                spot.sourceItemID, spot.sourceItemName = inputID, input.itemName
                spot.farmAction = action
                spot.tips = Merge(tips, original.tips or {})
                spot.sourceUrls = Merge(item.sourceUrls, urls, original.sourceUrls or {}, input.sourceUrls or {})
                spot.dropDifficulty = "Indirect input farm. Processing and bonus outputs are random; no fixed yield is promised. " .. tostring(original.dropDifficulty or "")
                spot.isRoute = false
                spot.routeType = "processing-input-source"
                item.spots[#item.spots + 1] = spot
            end
        end
    end
    item.sourceUrls = Merge(item.sourceUrls, urls)
end

for _, itemID in ipairs({ 76130, 76133, 76134, 76135, 76136, 76137, 90407 }) do
    AddInputMaps(itemID, ORES,
        "Mine the named input ore here, then prospect five of the same ore on a Pandaria Jewelcrafter. " .. items[itemID].itemName .. " is a possible prospecting result, not a direct node drop.",
        {
            "Keep ore unsmelted for Prospecting; bars cannot be prospected.",
            "Ghost Iron and Kyparite support uncommon-gem prospecting. Trillium is another input, but compare the ore cost and availability first.",
            "Prospecting does not guarantee the selected gem or Sparkling Shard on an individual attempt.",
        }, { GEM_GUIDE, "https://warcraft.wiki.gg/wiki/Prospecting", ItemURL(90407) })
end

for itemID, source in pairs(SOURCE_ITEMS) do
    if IsBase(itemID) and source.gemID then
        local gem = items[source.gemID]
        local action = "Mine the named ore here, prospect for " .. gem.itemName .. ", then use " .. source.cutName .. " (spell " .. source.spellID .. ") on a Jewelcrafter. " .. source.name .. " is a random Perfect cut, not a mining drop."
        AddInputMaps(itemID, ORES, action, {
            "The matching cut consumes one " .. gem.itemName .. " per attempt. The ordinary cut is the usual output; the Perfect version is a bonus result.",
            "Farm the ore first, prospect it in stacks of five, and keep the correct raw gem color for this specific cut.",
            "No fixed Perfect-cut probability or guaranteed gems-per-route is assumed. Learn the named cut before stockpiling inputs.",
        }, { GEM_GUIDE, SpellURL(source.spellID), ItemURL(source.gemID) })
        items[itemID].mapProcessing = { sourceSpellID = source.spellID, rawGemID = source.gemID, randomOutput = true }
    end
end

for _, itemID in ipairs({ 79251, 79253 }) do
    AddInputMaps(itemID, HERBS,
        "Gather the named herb here and mill five of the same herb with Pandaria Inscription for " .. items[itemID].itemName .. ". This is a milling output, not a herb-node drop.",
        {
            "Use millable Green Tea Leaf, Silkweed, Rain Poppy, Snow Lily, Fool's Cap or Desecrated Herb; Golden Lotus is not an input for these pigment farms.",
            "Shadow Pigment is the common pigment; Misty Pigment is the rarer result. Exact output varies per milling attempt.",
            "Keep herbs unprocessed for Milling; existing route qualifications and alternative areas remain applicable.",
        }, { MILLING_GUIDE, "https://warcraft.wiki.gg/wiki/Misty_Pigment" })
end

AddInputMaps(74252, { 72988, 72162 },
    "Farm the named cloth or leather inputs, make suitable rare-quality Pandaria equipment, then disenchant it with an Enchanter for Small Ethereal Shard attempts. These mobs do not drop the shard directly.",
    {
        "Suitable rare Contender's gear and rare crafting upgrades are documented shard sources; test the exact equipment before preparing a large batch.",
        "Ordinary green equipment primarily gives dust or essence. The rare-quality item and its actual disenchant table matter.",
        "The map marks the raw cloth or leather farm. Required crafting and Enchanting skills are separate steps; no guaranteed output count is implied.",
        "Sha-Touched Leather is a scrap input: combine it into Mist-Touched Leather before using a suitable Leatherworking recipe.",
    }, { ItemURL(74252), "https://www.wowhead.com/item=90491/misthide-leggings", "https://www.wowhead.com/item=90904/ornate-band" })

local function AddNavigation(itemID, mapID, mapName, location, action, tips, urls)
    if not IsBase(itemID) then return end
    local item = items[itemID]
    local slug = location:lower():gsub("[^%w]+", "-")
    item.spots[#item.spots + 1] = {
        id = "mists-base-area-" .. itemID .. "-" .. slug, mapID = mapID, mapName = mapName,
        location = location, mapOnly = true, coords = {}, isRoute = false,
        routeType = "source-area-guidance", farmAction = action, tips = tips,
        density = "Availability depends on the source described below",
        dropDifficulty = "This map opens the source zone; no fixed item spawn or live availability is implied.",
        source = "Named source area research; no fabricated coordinates",
        sourceUrls = Merge(item.sourceUrls, urls), confidence = "medium",
    }
end

local archaeologySites = {
    [95373] = {
        { 388, "Townlong Steppes", { "The Underbough", "West Sik'vess", "West Sra'vess" } },
        { 422, "Dread Wastes", { "Amber Quarry", "Kor'vess", "Kypari Vor", "Kypari'ik", "Kypari'zar", "Lake of Stars (north)", "The Briny Muck" } },
    },
    [79869] = {
        { 422, "Dread Wastes", { "Lake of Stars (south)", "Terrace of Gurthan", "Writhingwood" } },
        { 418, "Krasarang Wilds", { "North Ruins of Dojan", "South Ruins of Dojan", "Lost Dynasty / Krasari Ruins", "Fallsong Village" } },
        { 379, "Kun-Lai Summit", { "Gate to Golden Valley", "Snow Covered Hills / Winter's Blossom" } },
        { 371, "The Jade Forest", { "Thunderwood / Camp Gormal", "Nectarbreeze Orchard", "Terrace of Ten Thunders" } },
        { 390, "Vale of Eternal Blossoms", { "North Ruins of Guo-Lai", "West Summer Fields", "Winterbough" } },
    },
    [79868] = {
        { 379, "Kun-Lai Summit", { "Grumblepaw Ranch", "Small Gate / Ox Gate", "Remote Village / Zouchin" } },
        { 371, "The Jade Forest", { "Jade Temple Grounds", "Greenstone Village", "Tian Monastery", "Orchard / Arboretum", "Emperor's Omen", "Tiger's Wood", "Forest Heart", "Gong of Hope", "Woods of the Lost", "Den of Sorrow", "Serpent's Heart" } },
        { 390, "Vale of Eternal Blossoms", { "Mistfall Village" } },
        { 376, "Valley of the Four Winds", { "South Fruited Fields / Heartland" } },
    },
}
for itemID, zones in pairs(archaeologySites) do
    for _, zone in ipairs(zones) do
        for _, site in ipairs(zone[3]) do
            AddNavigation(itemID, zone[1], zone[2], site .. " possible archaeology digsite",
                "Enable the Archaeology digsite overlay and survey the matching active digsite for " .. SOURCE_ITEMS[itemID].name .. ". This named site is a possible location, not a permanent spawn.",
                {
                    "Only digsites currently active for your character can be surveyed. Use the world-map Archaeology overlay to confirm the site's race and boundaries.",
                    "Keystones are random survey finds. Clearing a site rotates the available sites; another player's active sites may differ from yours.",
                    itemID == 95373 and "The Mantid Artifact Sonic Locator biases new Pandaria digsites toward Mantid origin; check access to Brann's archaeology supplies."
                        or "Ancient Haunts can appear while digging and provide extra finds. Pristine artifact hand-ins are another documented keystone source.",
                    "Vale sites can depend on the current zone timeline; check the active overlay after changing timelines.",
                }, { "https://warcraft.wiki.gg/wiki/Archaeology_locations", "https://www.wowhead.com/guide/archaeology-changes-in-mists-of-pandaria-1063" })
        end
    end
end

local fragmentTips = {
    "Sha Crystal Fragments come from disenchanting eligible legacy epic gear that formerly cost Valor. Ordinary raid epics generally give Sha Crystals instead.",
    "These are gear purchase/disenchant source areas, not kill farms. Check the exact item's disenchant result, price and reputation requirement before buying.",
    "Three fragments combine into one Sha Crystal. No purchased gear or vendor reagent is added to the Materials catalog or recipe costs.",
    "Vendor position and availability can depend on the Vale timeline or faction shrine. Verify the vendor in your current phase.",
}
for _, zone in ipairs({
    { 388, "Townlong Steppes", "Rushi the Fox at Shado-Pan Garrison", "https://warcraft.wiki.gg/wiki/Rushi_the_Fox" },
    { 422, "Dread Wastes", "Ambersmith Zikk at Klaxxi'vess", "https://warcraft.wiki.gg/wiki/Ambersmith_Zikk" },
    { 390, "Vale of Eternal Blossoms", "Jaluu the Generous at the faction shrines", "https://warcraft.wiki.gg/wiki/Jaluu_the_Generous" },
}) do
    AddNavigation(105718, zone[1], zone[2], zone[3],
        "Check the named quartermaster's eligible former-Valor epic gear and its exact disenchant table before purchasing for Sha Crystal Fragments.",
        fragmentTips, { "https://warcraft.wiki.gg/wiki/Sha_Crystal_Fragment", zone[4] })
end

-- Record actual map coverage after construction, with a strict base-only boundary.
for itemID in pairs(SOURCE_ITEMS) do
    if IsBase(itemID) then
        local item = items[itemID]
        local count, navigationCount, pinCount = 0, 0, 0
        for _, spot in ipairs(item and item.spots or {}) do
            count = count + 1
            navigationCount = navigationCount + (spot.mapOnly and 1 or 0)
            pinCount = pinCount + #(spot.coords or {})
        end
        audit.items[itemID] = { mapOptionCount = count, navigationCount = navigationCount, pinCount = pinCount }
    end
end
NS.PandariaBaseMaterialMapAudit = audit
