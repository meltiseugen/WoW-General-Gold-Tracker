local _, NS = ...

-- Six missing visible Shadowlands maps; composed recipes are outside scope.
-- Evidence: docs/research/shadowlands-materials-audit-2026-10-23.md.
if NS.ShadowlandsMissingMaterialMapAudit then return end
local items = NS.MaterialFarmingSpots.items
local audit = { researchedAt = "2026-10-23", items = {} }
NS.ShadowlandsMissingMaterialMapAudit = audit
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
    [1533] = "Bastion", [1536] = "Maldraxxus", [1565] = "Ardenweald",
    [1525] = "Revendreth", [1543] = "The Maw", [1961] = "Korthia", [1970] = "Zereth Mortis",
}
local mapIDs = { ["Reven Dreth"] = 1525, ["Map 1970"] = 1970 }
for id, name in pairs(maps) do mapIDs[name] = id end
local function Prepare(id, sources, tips)
    local item = assert(items[id])
    assert(not item.components or #item.components == 0, "Composed material outside map scope")
    assert(not item.spots or #item.spots == 0, "Existing Shadowlands maps must be preserved")
    item = Copy(item)
    items[id] = item
    item.spots, item.researchedAt = {}, audit.researchedAt
    item.sourceUrls = Merge(item.sourceUrls, Merge({URL(id)}, sources))
    item.tips = Merge(item.tips, tips)
    audit.items[id] = true
    return item
end
local function InputMaps(item, inputIDs, action, kind)
    item.mapInputItemIDs = Copy(inputIDs)
    for _, inputID in ipairs(inputIDs) do
        local input = assert(items[inputID])
        for _, original in ipairs(input.spots or {}) do
            local spot = Copy(original)
            local mapID = tonumber(spot.mapID) or mapIDs[spot.mapName]
            assert(maps[mapID], "Unresolved Shadowlands input map: " .. tostring(spot.mapName))
            spot.id = "shadowlands-input-" .. item.itemID .. "-" .. original.id
            spot.mapID, spot.mapName = mapID, maps[mapID]
            spot.location = input.itemName .. " input - " .. (original.location or original.mapName)
            spot.inputItemID, spot.inputRouteID = inputID, original.id
            spot.routeType = kind
            spot.farmAction = action(input.itemName, item.itemName)
            spot.tips = Merge(original.tips, item.tips)
            spot.sourceUrls = Merge(original.sourceUrls, item.sourceUrls)
            spot.inGameTested = false
            item.spots[#item.spots + 1] = spot
        end
    end
end
local herbs = {169701,168589,168586,170554,168583,171315,187699}
for _, id in ipairs({173056,173057,175788}) do
    local item = Prepare(id, {
        "https://www.wowhead.com/spell=51005/milling",
        "https://www.wowhead.com/item=175788/tranquil-pigment",
        "https://www.wow-professions.com/guides/shadowlands-inscription-leveling-guide",
    }, {
        "Gather the named Shadowlands herb, then use Inscription Milling. These markers locate the input herb; pigment is a random processing result, not a plant or mob drop.",
        "Ordinary Milling consumes five of the same herb. Learned mass-milling recipes process larger batches; no fixed pigment yield is assumed.",
        "Nightshade and First Flower are documented Tranquil Pigment sources; other Shadowlands herbs can also yield it at a lower reported frequency. Compare input costs without assuming a current profit.",
        "Use Inscription Milling for legacy inscription pigments; housing dye-pigment processing is a different recipe system.",
    })
    InputMaps(item, herbs, function(inputName, outputName)
        return "Gather " .. inputName .. ", then use Inscription Milling for a chance at " .. outputName .. "."
    end, "milling-input-route")
end
local bark = Prepare(177061, {
    "https://www.wowhead.com/item=177061/twilight-bark",
    "https://warcraft.wiki.gg/wiki/Twilight_Bark",
}, {
    "Mine Phaedrum Deposits and Rich Phaedrum Deposits in Ardenweald for a chance at Twilight Bark alongside the ore. Skinning tree creatures is not this acquisition path.",
    "The copied Phaedrum locations are input-node search routes, not guaranteed Twilight Bark spawns. Clear eligible nodes as you travel; no fixed bark per node or hourly yield is assumed.",
    "Historical sources also list limited vendor stocks; this map documents the farmable mining source and does not assume current vendor stock.",
})
InputMaps(bark, {171831}, function()
    return "Mine Phaedrum Deposits and Rich Phaedrum Deposits in Ardenweald for a chance at Twilight Bark."
end, "mining-byproduct-source")

local function Area(item, suffix, mapID, location, action, kind, difficulty)
    item.spots[#item.spots + 1] = {
        id = "shadowlands-area-" .. item.itemID .. "-" .. suffix,
        mapID = mapID, mapName = maps[mapID], location = location,
        mapOnly = true, coords = {}, isRoute = false,
        routeType = kind, farmAction = action,
        tips = Copy(item.tips), sourceUrls = Copy(item.sourceUrls),
        source = "Published source-area guidance; no fixed spawn coordinates supplied",
        confidence = "medium", density = "Availability varies; no measured hourly yield",
        dropDifficulty = difficulty, inGameTested = false,
    }
end
local poultrid = Prepare(189148, {
    "https://www.icy-veins.com/wow/protoform-synthesis-mount-and-pet-guide",
    "https://www.wowhead.com/guide/protoform-synthesis-crafting-system-mounts-pets-zereth-mortis",
}, {
    "Search Zereth Mortis for interactable Avian Nests and open them for a chance at Poultrid Lattice. The source is the nest treasure, not killing Proto Avian creatures.",
    "Nest locations and availability vary. This option opens the source zone without inventing a permanent nest coordinate or connecting unrelated points into a route.",
    "Unlock Protoform Synthesis through the relevant research and forge quests. Keep the lattice unused for sale; synthesis consumes it, and other synthesis components can be bound.",
})
Area(poultrid, "avian-nests", 1970, "Interactable Avian Nests across Zereth Mortis",
    "Find and open Avian Nest treasures in Zereth Mortis for a chance at Poultrid Lattice.",
    "dynamic-treasure", "Random nest availability and chance loot; no guaranteed number of nests.")
local crystal = Prepare(186017, {
    "https://www.wowhead.com/guide/korthia-comprehensive-guide",
    "https://www.wowhead.com/guide/daily-korthia-to-do-list-archivists-codex-reputation-rares-treasures",
    "https://www.icy-veins.com/wow/korthia-zone-overview-and-guide",
}, {
    "Unlock Korthia through the Chains of Domination introduction. Daily quests and related activities depend on the character's campaign progress and current availability.",
    "Inspect the offered rewards before doing a daily quest: only some offer Korthite Crystal. Loot eligible treasures and rares as chance-based alternatives.",
    "The weekly Shaping Fate quest rewards a Death's Advance War Chest with a documented crystal reward. Respect the quest's weekly availability; this is not a repeatable mob farm.",
    "Zone navigation identifies the source area without inventing current questgiver or treasure-spawn coordinates. No current drop rate, market value or hourly yield is assumed.",
})
Area(crystal, "daily-quests", 1961, "Available Korthia daily quests",
    "Check Korthia daily quests and complete those currently offering Korthite Crystal.",
    "rotating-daily-quest", "Quest and reward selection varies; inspect the reward before starting.")
Area(crystal, "treasures-rares", 1961, "Eligible Korthia treasures and rares",
    "Open eligible Korthia treasures and loot rares for a chance at Korthite Crystal.",
    "treasure-and-rare", "Chance loot and source-specific limits; no guaranteed crystal per treasure or rare.")
Area(crystal, "shaping-fate", 1961, "Shaping Fate weekly reward",
    "Complete Shaping Fate when available and open its Death's Advance War Chest reward.",
    "weekly-quest-reward", "Weekly quest availability and campaign prerequisites apply.")
