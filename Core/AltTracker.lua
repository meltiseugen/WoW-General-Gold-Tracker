local _, NS = ...
local GoldTracker = NS.GoldTracker
local CHARACTER_ROLES = {
    { id = "main", label = "Main" },
    { id = "bank", label = "Bank" },
    { id = "other", label = "Other" },
}

local function IsPublic(value)
    return not (type(issecretvalue) == "function" and issecretvalue(value))
end

local function ReadPosition(mapID)
    if not mapID or not C_Map or type(C_Map.GetPlayerMapPosition) ~= "function" then return end
    local ok, x, y = pcall(function()
        local position = C_Map.GetPlayerMapPosition(mapID, "player")
        if position then return position:GetXY() end
    end)
    if ok and IsPublic(x) and IsPublic(y) and type(x) == "number" and type(y) == "number"
        and x >= 0 and x <= 1 and y >= 0 and y <= 1 and (x ~= 0 or y ~= 0) then
        return x, y
    end
end

local function ProjectToMap(mapID, parentMapID, x, y)
    if not parentMapID or not C_Map.GetWorldPosFromMapPos or not C_Map.GetMapPosFromWorldPos
        or type(CreateVector2D) ~= "function" then return end
    local ok, px, py = pcall(function()
        local instanceID, world = C_Map.GetWorldPosFromMapPos(mapID, CreateVector2D(x, y))
        if not world then return end
        local projectedMapID, position = C_Map.GetMapPosFromWorldPos(instanceID, world, parentMapID)
        if projectedMapID == parentMapID and position then return position:GetXY() end
    end)
    if ok and IsPublic(px) and IsPublic(py) and type(px) == "number" and type(py) == "number"
        and px >= 0 and px <= 1 and py >= 0 and py <= 1 then return px, py end
end

local function ResolveZonePosition(mapID)
    local x, y = ReadPosition(mapID)
    local zoneType = Enum and Enum.UIMapType and Enum.UIMapType.Zone or 3
    local continentType = Enum and Enum.UIMapType and Enum.UIMapType.Continent or 2
    local continentMapID, continentX, continentY
    local seen = {}
    while mapID and not seen[mapID] do
        seen[mapID] = true
        local info = C_Map and C_Map.GetMapInfo and C_Map.GetMapInfo(mapID)
        if not info or not x then break end
        if info.mapType and info.mapType >= zoneType then return mapID, x, y end
        if info.mapType == continentType then
            continentMapID, continentX, continentY = mapID, x, y
        end
        local child
        if C_Map.GetMapInfoAtPosition then
            local ok, candidate = pcall(C_Map.GetMapInfoAtPosition, mapID, x, y, true)
            if ok and candidate and candidate.mapID ~= mapID and candidate.mapType
                and candidate.mapType > (info.mapType or -1) then child = candidate end
        end
        -- Some login/phase transitions initially report only the continent.
        -- Match the actual zone name if its positional child lookup is not ready.
        if not child and C_Map.GetMapChildrenInfo and type(GetRealZoneText) == "function" then
            local zoneName = GetRealZoneText()
            local ok, children = pcall(C_Map.GetMapChildrenInfo, mapID, zoneType, true)
            if ok then
                for _, candidate in ipairs(children or {}) do
                    if candidate.name == zoneName then child = candidate; break end
                end
            end
        end
        if not child or not child.mapID or seen[child.mapID] then break end
        local childX, childY = ReadPosition(child.mapID)
        if not childX then childX, childY = ProjectToMap(mapID, child.mapID, x, y) end
        mapID, x, y = child.mapID, childX, childY
    end
    -- Coastlines, ocean areas and other continent edges may have no valid child map.
    return continentMapID, continentX, continentY, continentMapID ~= nil
end

function GoldTracker:GetAltCharacters()
    if type(self.db) ~= "table" then return {} end
    if type(self.db.altCharacters) ~= "table" then self.db.altCharacters = {} end
    return self.db.altCharacters
end

function GoldTracker:GetAltCharacterRoleOptions()
    return CHARACTER_ROLES
end

function GoldTracker:GetAltLowLevelThreshold()
    local value = self.db and tonumber(self.db.altLowLevelThreshold)
    if not value or value ~= value or math.abs(value) == math.huge then
        value = self.DEFAULTS and self.DEFAULTS.altLowLevelThreshold or 20
    end
    return math.max(0, math.min(1000, math.floor(value)))
end

function GoldTracker:IsLowLevelAlt(character)
    local level = type(character) == "table" and character.level
    return type(level) == "number" and level > 0 and level < self:GetAltLowLevelThreshold()
end

function GoldTracker:SetAltLowLevelThreshold(value)
    local threshold = tonumber(value)
    if not self.db or not threshold or threshold ~= threshold or math.abs(threshold) == math.huge then
        return self:GetAltLowLevelThreshold()
    end
    threshold = math.max(0, math.min(1000, math.floor(threshold)))
    if self.db.altLowLevelThreshold == threshold then return threshold end
    self.db.altLowLevelThreshold = threshold
    if self.altsFrame and self.altsFrame:IsShown() then self:RefreshAltsWindow() end
    if self.myFarmsFrame and self.myFarmsFrame:IsShown() then self:RefreshMyFarmsWindow() end
    return threshold
end

function GoldTracker:GetAltCharacterRoles(guid)
    local character = self:GetAltCharacters()[guid]
    local roles = character and character.roles
    local labels = {}
    if type(roles) == "table" then
        for _, option in ipairs(CHARACTER_ROLES) do
            if roles[option.id] == true then labels[#labels + 1] = option.label end
        end
    end
    return labels
end

function GoldTracker:SetAltCharacterRole(guid, roleID, enabled)
    local character = self:GetAltCharacters()[guid]
    if type(character) ~= "table" or type(enabled) ~= "boolean" then return false end
    local valid
    for _, option in ipairs(CHARACTER_ROLES) do
        if option.id == roleID then valid = true; break end
    end
    if not valid then return false end
    local roles = type(character.roles) == "table" and character.roles or {}
    roles[roleID] = enabled or nil
    character.roles = next(roles) and roles or nil
    if self.altsFrame and self.altsFrame:IsShown() then self:RefreshAltsWindow() end
    return true
end

function GoldTracker:ClearAltCharacterRoles(guid)
    local character = self:GetAltCharacters()[guid]
    if type(character) ~= "table" then return false end
    character.roles = nil
    if self.altsFrame and self.altsFrame:IsShown() then self:RefreshAltsWindow() end
    return true
end

function GoldTracker:GetAltMapHierarchy(mapID)
    local result, seen = {}, {}
    local continentType = Enum and Enum.UIMapType and Enum.UIMapType.Continent or 2
    while mapID and mapID > 0 and not seen[mapID] do
        seen[mapID] = true
        local info = C_Map and C_Map.GetMapInfo and C_Map.GetMapInfo(mapID)
        if not info then break end
        if not result.mapID then
            result.mapID, result.mapName = mapID, info.name
            if info.parentMapID and info.parentMapID > 0 then
                result.parentMapID = info.parentMapID
                local parent = C_Map.GetMapInfo(info.parentMapID)
                result.parentMapName = parent and parent.name
            end
        end
        if info.mapType == continentType then
            result.continentMapID, result.continentName = mapID, info.name
            break
        end
        mapID = info.parentMapID
    end
    return result
end

function GoldTracker:CaptureCurrentAltProfessions(character, allowEmpty)
    -- Skill APIs can be cleared before PLAYER_LOGOUT. Keep the last live snapshot.
    if self.altTrackerLeavingWorld then return end
    if type(GetProfessions) ~= "function" or type(GetProfessionInfo) ~= "function" then return end
    local first, second = GetProfessions()
    if not first and not second and not allowEmpty
        and character.professions and #character.professions > 0 then return end
    local slots, professions = { first, second }, {}
    for index = 1, 2 do
        if slots[index] then
            local name, icon, _, _, _, _, skillLineID = GetProfessionInfo(slots[index])
            -- Skills may still be loading at login. Retry on SKILL_LINES_CHANGED.
            if not name or not icon or not skillLineID then return end
            professions[#professions + 1] = { name = name, icon = icon, skillLineID = skillLineID }
        end
    end
    character.professions = professions
end

function GoldTracker:CaptureAltMapExploration(character, includeContinent)
    local location = character and character.location
    if not location or not C_MapExplorationInfo or not C_MapExplorationInfo.GetExploredMapTextures then return end
    local snapshots = character.exploredMaps or {}
    local mapIDs, seen = {}, {}
    local function include(mapID)
        if mapID and not seen[mapID] then seen[mapID] = true; mapIDs[#mapIDs + 1] = mapID end
    end
    include(location.mapID)
    include(location.parentMapID)
    if includeContinent then
        include(location.continentMapID)
        if location.continentMapID and C_Map.GetMapChildrenInfo then
            local ok, children = pcall(C_Map.GetMapChildrenInfo, location.continentMapID, nil, true)
            if ok then
                for _, child in ipairs(children or {}) do
                    if child.mapType == 3 then include(child.mapID) end
                end
            end
        end
    end
    for _, mapID in ipairs(mapIDs) do
        local art = self.MapDataSource and self.MapDataSource.ReadArt(mapID)
        local previousArt = character.mapArtSnapshots and character.mapArtSnapshots[mapID]
        local phaseChanged = art and previousArt and art.artID ~= previousArt.artID
        local ok, overlays = pcall(C_MapExplorationInfo.GetExploredMapTextures, mapID)
        -- Exploration does not disappear when a login/teardown API is temporarily empty.
        local captured = ok and type(overlays) == "table"
        if captured and not (#overlays == 0 and snapshots[mapID] and #snapshots[mapID] > 0 and not phaseChanged) then
            local copied = {}
            for _, overlay in ipairs(overlays) do
                local fileDataIDs = {}
                for index, fileID in ipairs(overlay.fileDataIDs or {}) do fileDataIDs[index] = fileID end
                copied[#copied + 1] = {
                    textureWidth = overlay.textureWidth, textureHeight = overlay.textureHeight,
                    offsetX = overlay.offsetX, offsetY = overlay.offsetY,
                    isShownByMouseOver = overlay.isShownByMouseOver,
                    isDrawOnTopLayer = overlay.isDrawOnTopLayer,
                    fileDataIDs = fileDataIDs,
                }
            end
            snapshots[mapID] = copied
        end
        -- Preserve this character's phased base art as well as its discovered overlays.
        -- The reusable source is available by the time login events are dispatched.
        if art and (not phaseChanged or captured) then
            art.world = self.MapDataSource.ReadWorld(mapID)
            character.mapArtSnapshots = character.mapArtSnapshots or {}
            character.mapArtSnapshots[mapID] = art
        end
    end
    -- Other zones remain available when this offline character's map is explored.
    character.exploredMaps = snapshots
    character.mapExplorationRevision = (character.mapExplorationRevision or 0) + 1
end

function GoldTracker:CaptureCurrentAlt(saveLocation, allowEmptyProfessions, suppressRefresh)
    if not self.db or type(UnitGUID) ~= "function" then return end
    local guid = UnitGUID("player")
    if not guid then return end
    local name, realm = UnitFullName("player")
    if not name then return end
    if not realm or realm == "" then realm = GetRealmName() end
    local characters = self:GetAltCharacters()
    local character = characters[guid] or {}
    character.guid, character.name, character.realm = guid, name, realm
    character.classFile = select(2, UnitClass("player"))
    local level = type(UnitLevel) == "function" and UnitLevel("player")
    if IsPublic(level) and type(level) == "number" and level > 0 and level == math.floor(level) then
        -- Preserve the last known level if login/logout APIs are temporarily unavailable.
        character.level = level
    end
    character.lastSeenAt = time()
    self.currentAltGUID = guid
    self:CaptureCurrentAltProfessions(character, allowEmptyProfessions)
    if saveLocation then
        local mapID = C_Map and C_Map.GetBestMapForUnit and C_Map.GetBestMapForUnit("player")
        if not IsPublic(mapID) then mapID = nil end
        local x, y, continentOnly
        mapID, x, y, continentOnly = ResolveZonePosition(mapID)
        if continentOnly and self.altTrackerLoggingOut and character.location
            and character.location.mapID ~= mapID and character.location.continentMapID == mapID then
            -- A late teardown result must not replace the precise pre-logout checkpoint.
            mapID = nil
        end
        local location = mapID and self:GetAltMapHierarchy(mapID)
        if location and location.mapID and x then
            location.x, location.y = x, y
            location.parentX, location.parentY = ReadPosition(location.parentMapID)
            if not location.parentX then
                location.parentX, location.parentY = ProjectToMap(mapID, location.parentMapID, x, y)
            end
            location.savedAt = time()
            character.location = location
            character.locationUnavailable = nil
        else
            -- Preserve the complete prior snapshot, including its timestamp and parent pin.
            character.locationUnavailable = true
        end
        self:CaptureAltMapExploration(character)
    end
    characters[guid] = character
    if not suppressRefresh and self.altsFrame and self.altsFrame:IsShown() then self:RefreshAltsWindow() end
    return character
end

local SPECIAL_GROUP_NAMES = { bank = "Banks", other = "Other", unknown = "Unknown location" }
local SPECIAL_GROUP_RANKS = { bank = 1, other = 2, lowLevel = 3, unknown = 4 }

local function AltCharacterLess(a, b)
    local ac, bc = a.character, b.character
    local an, bn = string.lower(ac.name), string.lower(bc.name)
    if an ~= bn then return an < bn end
    if ac.realm ~= bc.realm then return (ac.realm or "") < (bc.realm or "") end
    return a.guid < b.guid
end

local function SavedContinentRanks(addon)
    local ranks = {}
    local order = addon.db and addon.db.altContinentOrder
    if type(order) == "table" then
        for index, id in ipairs(order) do
            if (SPECIAL_GROUP_RANKS[id] or (type(id) == "number" and id > 0 and id < math.huge and id == math.floor(id)))
                and not ranks[id] then ranks[id] = index end
        end
    end
    return ranks
end

function GoldTracker:BuildAltCharacterGroups()
    local groups, byID = {}, {}
    for guid, character in pairs(self:GetAltCharacters()) do
        if type(character) == "table" and type(character.name) == "string" then
            local location = character.location or {}
            local key = location.continentMapID or "unknown"
            local roles = type(character.roles) == "table" and character.roles or {}
            if roles.bank == true then key = "bank"
            elseif roles.other == true then key = "other"
            elseif self:IsLowLevelAlt(character) then key = "lowLevel" end
            local group = byID[key]
            if not group then
                group = { id = key, name = SPECIAL_GROUP_NAMES[key]
                    or (key == "lowLevel" and ("Low level (below " .. self:GetAltLowLevelThreshold() .. ")"))
                    or location.continentName or "Unknown location", characters = {} }
                byID[key], groups[#groups + 1] = group, group
            end
            group.characters[#group.characters + 1] = { guid = guid, character = character }
        end
    end
    local ranks = SavedContinentRanks(self)
    table.sort(groups, function(a, b)
        if ranks[a.id] ~= ranks[b.id] then
            if not ranks[a.id] then return false end
            if not ranks[b.id] then return true end
            return ranks[a.id] < ranks[b.id]
        end
        local specialA = SPECIAL_GROUP_RANKS[a.id] or 0
        local specialB = SPECIAL_GROUP_RANKS[b.id] or 0
        if specialA ~= specialB then return specialA < specialB end
        if a.name ~= b.name then return a.name < b.name end
        return tostring(a.id) < tostring(b.id)
    end)
    for _, group in ipairs(groups) do
        table.sort(group.characters, AltCharacterLess)
    end
    return groups
end

function GoldTracker:MoveAltContinentGroup(groupID, beforeGroupID)
    if groupID == beforeGroupID then return false end
    local groups, present = self:BuildAltCharacterGroups(), {}
    for _, group in ipairs(groups) do present[group.id] = true end
    if not present[groupID] or (beforeGroupID ~= nil and not present[beforeGroupID]) then return false end
    local order, seen = {}, {}
    local ranks = SavedContinentRanks(self)
    -- Retain temporarily empty groups in the saved order for their next visit.
    for _, id in ipairs(type(self.db.altContinentOrder) == "table" and self.db.altContinentOrder or {}) do
        if ranks[id] and not seen[id] then order[#order + 1], seen[id] = id, true end
    end
    for _, group in ipairs(groups) do
        if not seen[group.id] then order[#order + 1], seen[group.id] = group.id, true end
    end
    local original = table.concat(order, ",")
    for index, id in ipairs(order) do
        if id == groupID then table.remove(order, index); break end
    end
    local target = #order + 1
    for index, id in ipairs(order) do
        if id == beforeGroupID then target = index; break end
    end
    table.insert(order, target, groupID)
    if table.concat(order, ",") == original then return false end
    self.db.altContinentOrder = order
    return true
end

function GoldTracker:BuildAltContinentMap(continentMapID)
    if type(continentMapID) ~= "number" then return end
    -- List role groups must not remove characters from their continent's map.
    local characters = {}
    for guid, character in pairs(self:GetAltCharacters()) do
        local location = type(character) == "table" and character.location
        if type(location) == "table" and type(character.name) == "string" and location.continentMapID == continentMapID
            and not self:IsLowLevelAlt(character) then
            characters[#characters + 1] = { guid = guid, character = character }
        end
    end
    if #characters == 0 then return end
    table.sort(characters, AltCharacterLess)
    local result = { mapID = continentMapID, name = characters[1].character.location.continentName or "Unknown location", pins = {},
        characterCount = #characters, exploredTextures = {} }
    local seenOverlays = {}
    for _, entry in ipairs(characters) do
        local character, location = entry.character, entry.character.location
        local x, y
        if location.mapID == continentMapID then
            x, y = location.x, location.y
        elseif location.parentMapID == continentMapID and location.parentX and location.parentY then
            x, y = location.parentX, location.parentY
        elseif location.x and location.y then
            -- Project the offline character's saved coordinates, never the active player's position.
            x, y = ProjectToMap(location.mapID, continentMapID, location.x, location.y)
        end
        if IsPublic(x) and IsPublic(y) and type(x) == "number" and type(y) == "number"
            and x >= 0 and x <= 1 and y >= 0 and y <= 1 then
            result.pins[#result.pins + 1] = { guid = entry.guid, name = character.name, x = x, y = y,
                label = character.name .. (character.realm and (" - " .. character.realm) or ""),
                professions = character.professions }
        end
        for _, overlay in ipairs(character.exploredMaps and character.exploredMaps[continentMapID] or {}) do
            local key = table.concat({ overlay.textureWidth or 0, overlay.textureHeight or 0,
                overlay.offsetX or 0, overlay.offsetY or 0, table.concat(overlay.fileDataIDs or {}, ",") }, ":")
            if not seenOverlays[key] then
                seenOverlays[key] = true
                result.exploredTextures[#result.exploredTextures + 1] = overlay
            end
        end
    end
    return result
end

function GoldTracker:InitializeAltTracker()
    if self.altTrackerEvents then return end
    self:GetAltCharacters()
    self.altTrackerLeavingWorld = true
    local events = CreateFrame("Frame")
    self.altTrackerEvents = events
    events:RegisterEvent("PLAYER_ENTERING_WORLD")
    events:RegisterEvent("PLAYER_LEAVING_WORLD")
    events:RegisterEvent("PLAYER_LOGOUT")
    events:RegisterEvent("SKILL_LINES_CHANGED")
    events:RegisterEvent("PLAYER_LEVEL_CHANGED")
    events:RegisterEvent("MAP_EXPLORATION_UPDATED")
    events:SetScript("OnEvent", function(_, event)
        if event == "PLAYER_ENTERING_WORLD" then
            self.altTrackerLeavingWorld = false
            self.altTrackerLoggingOut = nil
            -- Only the first world entry after login/reload; no zone or position polling.
            if not self.altLoginCaptured then
                self.altLoginCaptured = true
                self:CaptureCurrentAlt(true)
            else
                self:CaptureCurrentAlt(false)
            end
        elseif event == "PLAYER_LEAVING_WORLD" then
            self.altTrackerLeavingWorld = true
            -- Checkpoint while the character's map data is still available.
            -- PLAYER_LOGOUT retries the final position and retains this if APIs are cleared.
            self:CaptureCurrentAlt(true, nil, true)
        elseif event == "PLAYER_LOGOUT" then
            self.altTrackerLeavingWorld = true
            self.altTrackerLoggingOut = true
            self:CaptureCurrentAlt(true)
        elseif event == "MAP_EXPLORATION_UPDATED" and not self.altTrackerLeavingWorld then
            local character = self:GetAltCharacters()[self.currentAltGUID]
            if character then
                self:CaptureAltMapExploration(character)
                if self.altsFrame and self.altsFrame:IsShown() then self:RefreshAltsWindow() end
            end
        elseif event == "SKILL_LINES_CHANGED" and not self.altTrackerLeavingWorld then
            self:CaptureCurrentAlt(false, true)
        elseif event == "PLAYER_LEVEL_CHANGED" and not self.altTrackerLeavingWorld then
            self:CaptureCurrentAlt(false)
        end
    end)
end
