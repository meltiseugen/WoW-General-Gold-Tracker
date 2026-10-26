local _, NS = ...
local addon = NS.GoldTracker

-- Blizzard UI map roots, independent of expansion IDs and physical game-map IDs.
local worlds = {
    { id = 947, name = "Azeroth" },
    { id = 101, name = "Outland" },
    { id = 572, name = "Draenor" },
    { id = 1550, name = "Shadowlands" },
}
local worldByID = {}
for _, world in ipairs(worlds) do worldByID[world.id] = world end

function addon:GetAltGlobalMapWorlds()
    return worlds
end

local function worldOf(source, mapID, cache)
    local seen = {}
    while source.Number(mapID) and mapID > 0 and not seen[mapID] do
        if worldByID[mapID] then return mapID end
        seen[mapID] = true
        if cache[mapID] == nil then cache[mapID] = source.Call(C_Map and C_Map.GetMapInfo, mapID) or false end
        local info = cache[mapID]
        mapID = info and info.parentMapID
    end
end

local function position(source, rootID, mapID, x, y)
    if not mapID or not source.Number(x) or not source.Number(y) or x < 0 or x > 1 or y < 0 or y > 1 then return end
    local rect = source.Rect(mapID, rootID)
    if not rect then return end
    local u, v = rect.l + x * (rect.r - rect.l), rect.t + y * (rect.b - rect.t)
    if source.Number(u) and source.Number(v) and u >= 0 and u <= 1 and v >= 0 and v <= 1 then return u, v end
end

function addon:BuildAltGlobalMap(worldID)
    local world, source = worldByID[worldID], self.MapDataSource
    if not world or not source then return end
    local result = { mapID = world.id, name = world.name, pins = {}, characterCount = 0, missingPositionCount = 0 }
    local infoCache = {}
    for guid, character in pairs(self:GetAltCharacters()) do
        local location = type(character) == "table" and character.location
        if type(location) == "table" and type(character.name) == "string" then
            local root = worldOf(source, location.mapID, infoCache) or worldOf(source, location.continentMapID, infoCache)
                or worldOf(source, location.parentMapID, infoCache)
            if root == worldID then
                result.characterCount = result.characterCount + 1
                local x, y = position(source, worldID, location.mapID, location.x, location.y)
                if not x then x, y = position(source, worldID, location.parentMapID, location.parentX, location.parentY) end
                if x then
                    result.pins[#result.pins + 1] = { guid = guid, name = character.name,
                        label = character.name .. (character.realm and (" - " .. character.realm) or ""),
                        professions = character.professions, mapID = location.mapID, x = x, y = y }
                else
                    result.missingPositionCount = result.missingPositionCount + 1
                end
            end
        end
    end
    table.sort(result.pins, function(a, b)
        if a.label ~= b.label then return a.label < b.label end
        return tostring(a.guid) < tostring(b.guid)
    end)
    return result
end
