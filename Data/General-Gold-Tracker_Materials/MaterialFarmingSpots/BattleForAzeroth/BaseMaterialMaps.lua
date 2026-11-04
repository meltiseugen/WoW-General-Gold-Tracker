local _, NS = ...

-- Missing visible BfA maps only, including the Raid items recipe.
-- Evidence and scope: docs/research/bfa-missing-map-audit-2026-10-23.md.
if NS.BfaMissingMaterialMapAudit then return end
local items = NS.MaterialFarmingSpots.items
local audit = { researchedAt = "2026-10-23", items = {} }
NS.BfaMissingMaterialMapAudit = audit

local function Copy(value)
    if type(value) ~= "table" then return value end
    local result = {}
    for key, entry in pairs(value) do result[key] = Copy(entry) end
    return result
end

local function Merge(first, second)
    local result, seen = {}, {}
    for _, list in ipairs({ first or {}, second or {} }) do
        for _, value in ipairs(list) do
            if not seen[value] then result[#result + 1], seen[value] = value, true end
        end
    end
    return result
end

local function URL(id) return "https://www.wowhead.com/item=" .. id end
local maps = {
    [862] = "Zuldazar", [863] = "Nazmir", [864] = "Vol'dun",
    [895] = "Tiragarde Sound", [896] = "Drustvar", [942] = "Stormsong Valley",
    [1355] = "Nazjatar",
}
local mapIDs = {}
for id, name in pairs(maps) do mapIDs[name] = id end
mapIDs.Voldun, mapIDs.Zandalar = 864, 862

local function Prepare(id, sources, tips)
    local item = assert(items[id], "Missing BfA material " .. id)
    assert(not item.components or #item.components == 0, "Composed item in BfA map scope")
    assert(not item.spots or #item.spots == 0, "BfA map would replace existing locations")
    item = Copy(item)
    items[id] = item
    item.spots = {}
    item.researchedAt = audit.researchedAt
    item.sourceUrls = Merge(item.sourceUrls, Merge({ URL(id) }, sources))
    item.tips = Merge(item.tips, tips)
    audit.items[id] = true
    return item
end

-- Pigments are random processing outputs, not plants at the marked locations.
-- Copy complete existing herb routes, retaining their coordinates, order,
-- route exports and provenance; the source herb records are never mutated.
local millingSources = {
    "https://www.wowhead.com/spell=51005/milling",
    "https://www.wowhead.com/guide/herbs-pigments-inks-oh-my-1994",
    "https://us.forums.blizzard.com/en/wow/t/so-confused-about-milling/2217291",
}
local baseHerbs = { 152505, 152506, 152507, 152508, 152509, 152510, 152511 }
for _, id in ipairs({ 153635, 153636, 153669, 168662 }) do
    local inputs = id == 168662 and { 168487 } or baseHerbs
    local item = Prepare(id, millingSources, {
        "Gather the named input herb, then use Inscription Milling for a chance at this pigment. The markers locate herbs, not pigment drops.",
        "Ordinary Milling consumes five of the same herb; learned mass-milling recipes process larger batches. Pigment quantities are random and no fixed yield is assumed.",
        "Use Inscription Milling for these legacy pigments. Housing dye-pigment recipes are a separate process.",
    })
    item.mapInputItemIDs = Copy(inputs)
    for _, herbID in ipairs(inputs) do
        local herb = assert(items[herbID])
        for _, source in ipairs(herb.spots or {}) do
            local mapID = tonumber(source.mapID) or mapIDs[source.mapName]
            assert(maps[mapID], "Unresolved BfA herb map: " .. tostring(source.mapName))
            local spot = Copy(source)
            spot.id = "bfa-pigment-" .. id .. "-" .. source.id
            spot.mapID, spot.mapName = mapID, maps[mapID]
            spot.location = herb.itemName .. " for milling - " .. (source.location or source.mapName)
            spot.routeType = "milling-input-route"
            spot.inputItemID = herbID
            spot.inputRouteID = source.id
            spot.farmAction = "Gather " .. herb.itemName .. ", then use Inscription Milling for a chance at " .. item.itemName .. "."
            spot.sourceUrls = Merge(source.sourceUrls, item.sourceUrls)
            spot.tips = Merge(source.tips, item.tips)
            spot.inGameTested = false
            item.spots[#item.spots + 1] = spot
        end
    end
end

-- Archaeology digsites rotate. Open the correct zone and use the active
-- digsite overlays; a zone-wide source is not a fixed keystone spawn pin.
local archaeologySources = {
    "https://www.cymre.com/2018/06/01/archaeology-in-bfa/",
    "https://warcraft.wiki.gg/wiki/Archaeology_locations",
}
local archaeology = {
    { id = 154990, race = "Drust", zones = {
        { 896, "Arom's Crossing, Brackish Coast, Crimson Forest and other active Drust digsites" },
        { 895, "Brokenbough Roost, Placid Springs, Vigil Hill and other active Drust digsites" },
        { 942, "Briny Flats, Drowned Lands, Goldfield Farmstead and other active Drust digsites" },
    } },
    { id = 154989, race = "Zandalari", zones = {
        { 862, "Atal'Gral, Dreadpearl Shallows, Tusk Isle and other active Zandalari digsites" },
        { 863, "Natha'vor, Terrace of Sorrows, Xal'vor and other active Zandalari digsites" },
        { 864, "Arid Basin, Cracked Coast, Verdant Plateau and other active Zandalari digsites" },
    } },
}
for _, entry in ipairs(archaeology) do
    local item = Prepare(entry.id, archaeologySources, {
        "Learn Archaeology and enable digsite overlays on the world map. Survey inside an active " .. entry.race .. " digsite and loot the finds for a chance at the keystone.",
        "The named digsites identify eligible source areas; not every site is active at once. Clear available sites to rotate the selection.",
        "Keep the keystone unused to sell it. Consuming it in an archaeology solve spends it; it is not a crafted output or a guaranteed find.",
    })
    for _, zone in ipairs(entry.zones) do
        item.spots[#item.spots + 1] = {
            id = "bfa-archaeology-" .. entry.id .. "-" .. zone[1],
            mapID = zone[1], mapName = maps[zone[1]], location = zone[2],
            mapOnly = true, coords = {}, isRoute = false,
            routeType = "rotating-archaeology-digsites", confidence = "medium",
            farmAction = "Survey active " .. entry.race .. " digsites in " .. maps[zone[1]] .. " for a chance at " .. item.itemName .. ".",
            source = "Published BfA archaeology research and digsite list; zone navigation only",
            sourceUrls = Copy(item.sourceUrls), tips = Copy(item.tips),
            density = "Rotating digsites; no fixed spawn or measured yield",
            dropDifficulty = "Chance keystone from Archaeology finds; use the current digsite overlay.",
            inGameTested = false,
        }
    end
end

local recipe = Prepare(163833, {
    "https://www.wowhead.com/zone=9424/waycrest-manor",
    "https://www.wowhead.com/spell=280282/heartsbane-hexwurst",
}, {
    "Enter Waycrest Manor in Drustvar and defeat Raal the Gluttonous for a chance at the recipe. The marker is the outdoor dungeon entrance, not the boss's room.",
    "Normal-difficulty drops are reported; Mythic is not required by the source evidence. Respect the selected difficulty's lockout and instance limits.",
    "Keep the recipe unlearned for sale. The drop is Recipe: Heartsbane Hexwurst, not the cooked food; no drop rate or guaranteed number of runs is assumed.",
})
recipe.spots = { {
    id = "bfa-heartsbane-hexwurst-waycrest-manor", mapID = 896, mapName = "Drustvar",
    location = "Waycrest Manor entrance - Raal the Gluttonous recipe",
    coords = { { x = 0.3389, y = 0.1314, label = "Waycrest Manor entrance; defeat Raal inside" } },
    routeType = "dungeon-boss-recipe", isRoute = false, confidence = "medium",
    farmAction = "Enter Waycrest Manor and loot Raal the Gluttonous for a chance at Recipe: Heartsbane Hexwurst.",
    source = "Wowhead recipe drop reports and published Waycrest Manor entrance coordinates",
    sourceUrls = Copy(recipe.sourceUrls), tips = Copy(recipe.tips),
    density = "Instance and difficulty limits apply",
    dropDifficulty = "Chance boss drop; the entrance marker is not a boss spawn pin.",
    inGameTested = false,
} }
