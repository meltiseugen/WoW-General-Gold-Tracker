local _, NS = ...
local GoldTracker = NS.GoldTracker

local function NormalizeCoordinate(value)
    local coordinate = tonumber(value)
    if not coordinate then
        return nil
    end
    if coordinate > 1 then
        coordinate = coordinate / 100
    end
    return coordinate >= 0 and coordinate <= 1 and coordinate or nil
end

local function ReadVectorCoordinates(position)
    if type(position) ~= "table" and type(position) ~= "userdata" then
        return nil, nil
    end

    local getXY
    if type(position) == "table" then
        getXY = position.GetXY
    else
        local ok, value = pcall(function() return position.GetXY end)
        getXY = ok and value or nil
    end
    if type(getXY) == "function" then
        local ok, x, y = pcall(getXY, position)
        if ok then
            return NormalizeCoordinate(x), NormalizeCoordinate(y)
        end
    end

    if type(position) == "table" then
        return NormalizeCoordinate(position.x or position[1]), NormalizeCoordinate(position.y or position[2])
    end
    return nil, nil
end

local function LoadEncounterJournal()
    if C_AddOns and type(C_AddOns.LoadAddOn) == "function" then
        pcall(C_AddOns.LoadAddOn, "Blizzard_EncounterJournal")
    elseif type(LoadAddOn) == "function" then
        pcall(LoadAddOn, "Blizzard_EncounterJournal")
    end
end

local function GetMapInfo(mapID)
    if not tonumber(mapID) or type(C_Map) ~= "table" or type(C_Map.GetMapInfo) ~= "function" then
        return nil
    end
    local ok, mapInfo = pcall(C_Map.GetMapInfo, tonumber(mapID))
    return ok and type(mapInfo) == "table" and mapInfo or nil
end

local function GetMapLineage(mapID)
    local lineage = {}
    local currentMapID = tonumber(mapID)
    local visited = {}
    while currentMapID and currentMapID > 0 and not visited[currentMapID] and #lineage < 15 do
        visited[currentMapID] = true
        lineage[#lineage + 1] = currentMapID
        local mapInfo = GetMapInfo(currentMapID)
        currentMapID = tonumber(mapInfo and mapInfo.parentMapID)
    end
    return lineage
end

local function IsContinentMap(mapInfo)
    local mapType = tonumber(mapInfo and mapInfo.mapType)
    if Enum and Enum.UIMapType and Enum.UIMapType.Continent then
        return mapType == Enum.UIMapType.Continent
    end
    return mapType == 2
end

local function GetInstanceDisplayName(instance)
    local journalInstanceID = tonumber(instance and (instance.encounterJournalID or instance.journalInstanceID))
    if journalInstanceID and type(EJ_GetInstanceInfo) == "function" then
        local ok, name = pcall(EJ_GetInstanceInfo, journalInstanceID)
        if ok and type(name) == "string" and name ~= "" then
            return name
        end
    end
    return type(instance and instance.name) == "string" and instance.name or nil
end

local function NormalizeInstanceName(value)
    if type(value) ~= "string" then
        return nil
    end
    local key = value:lower():gsub("[%s%p_]", "")
    return key ~= "" and key or nil
end

local function AddNameKeys(target, value)
    local key = NormalizeInstanceName(value)
    if not key then
        return
    end
    target[key] = true
    if key:sub(1, 3) == "the" and #key > 3 then
        target[key:sub(4)] = true
    end
end

local function GetRecordIdentity(instance)
    return tostring(tonumber(instance and (instance.encounterJournalID or instance.journalInstanceID)) or "?")
end

local cachedNameIndex
local cachedInstanceDropsData
local cachedATTBoEDropsData

local function BuildInstanceNameIndex()
    if cachedNameIndex and cachedInstanceDropsData == NS.InstanceDropsData
        and cachedATTBoEDropsData == NS.ATTBoEDropsData then
        return cachedNameIndex
    end
    LoadEncounterJournal()
    local index = {}
    local function addInstance(instance)
        if type(instance) ~= "table" or not tonumber(instance.encounterJournalID or instance.journalInstanceID) then
            return
        end
        local keys = {}
        AddNameKeys(keys, instance.name)
        AddNameKeys(keys, GetInstanceDisplayName(instance))
        for key in pairs(keys) do
            local existing = index[key]
            if existing == nil then
                index[key] = instance
            elseif existing ~= false and GetRecordIdentity(existing) ~= GetRecordIdentity(instance) then
                index[key] = false
            end
        end
    end

    for _, instance in pairs(type(NS.InstanceDropsData) == "table" and NS.InstanceDropsData.instances or {}) do
        addInstance(instance)
    end
    for _, instance in pairs(type(NS.ATTBoEDropsData) == "table" and NS.ATTBoEDropsData.instances or {}) do
        addInstance(instance)
    end
    cachedNameIndex = index
    cachedInstanceDropsData = NS.InstanceDropsData
    cachedATTBoEDropsData = NS.ATTBoEDropsData
    return index
end

local function FindInstanceRecord(catalogFarm)
    local index = BuildInstanceNameIndex()
    local keys = {}
    AddNameKeys(keys, catalogFarm and catalogFarm.name)
    AddNameKeys(keys, catalogFarm and catalogFarm.providerFarmID)
    AddNameKeys(keys, catalogFarm and catalogFarm.providerKey)
    for _, mapName in ipairs(catalogFarm and catalogFarm.mapNames or {}) do
        AddNameKeys(keys, mapName)
    end

    local matched
    for key in pairs(keys) do
        local instance = index[key]
        if instance and (not matched or GetRecordIdentity(matched) == GetRecordIdentity(instance)) then
            matched = matched or instance
        elseif instance and matched then
            return nil
        end
    end
    return matched
end

local function GetAreaPOIPosition(mapID, areaPoiID)
    if not areaPoiID or type(C_AreaPoiInfo) ~= "table" or type(C_AreaPoiInfo.GetAreaPOIInfo) ~= "function" then
        return nil, nil
    end
    local ok, poiInfo = pcall(C_AreaPoiInfo.GetAreaPOIInfo, mapID, areaPoiID)
    if not ok or type(poiInfo) ~= "table" then
        return nil, nil
    end
    local x, y = ReadVectorCoordinates(poiInfo.position)
    return x or NormalizeCoordinate(poiInfo.x), y or NormalizeCoordinate(poiInfo.y)
end

local function GetEntranceCoordinates(mapID, entranceInfo)
    local x, y = ReadVectorCoordinates(entranceInfo and entranceInfo.position)
    if x and y then
        return x, y
    end
    x = NormalizeCoordinate(entranceInfo and (entranceInfo.x or entranceInfo.atlasX))
    y = NormalizeCoordinate(entranceInfo and (entranceInfo.y or entranceInfo.atlasY))
    if x and y then
        return x, y
    end
    return GetAreaPOIPosition(mapID, entranceInfo and entranceInfo.areaPoiID)
end

function GoldTracker:ResolveInstanceEntranceOnMap(instance, mapID)
    local normalizedMapID = tonumber(mapID)
    local journalInstanceID = tonumber(instance and (instance.encounterJournalID
        or instance.journalInstanceID or instance.instanceEncounterJournalID))
    if not normalizedMapID or not journalInstanceID then
        return nil
    end

    local staticEntrance = instance.entrance or instance.entranceLocation or instance.instanceEntrance
    local staticMapID = tonumber(staticEntrance and staticEntrance.mapID)
    local staticX = NormalizeCoordinate(staticEntrance and staticEntrance.x)
    local staticY = NormalizeCoordinate(staticEntrance and staticEntrance.y)
    if staticMapID == normalizedMapID and staticX and staticY then
        return {
            mapID = normalizedMapID,
            x = staticX,
            y = staticY,
            name = staticEntrance.label or (GetInstanceDisplayName(instance) .. " entrance"),
            journalInstanceID = journalInstanceID,
        }
    end

    LoadEncounterJournal()
    if type(C_EncounterJournal) ~= "table" or type(C_EncounterJournal.GetDungeonEntrancesForMap) ~= "function" then
        return nil
    end
    local ok, entrances = pcall(C_EncounterJournal.GetDungeonEntrancesForMap, normalizedMapID)
    if not ok or type(entrances) ~= "table" then
        return nil
    end
    for _, entranceInfo in pairs(entrances) do
        if type(entranceInfo) == "table" and tonumber(entranceInfo.journalInstanceID) == journalInstanceID then
            local x, y = GetEntranceCoordinates(normalizedMapID, entranceInfo)
            if x and y then
                return {
                    mapID = normalizedMapID,
                    x = x,
                    y = y,
                    name = entranceInfo.name or (GetInstanceDisplayName(instance) .. " entrance"),
                    journalInstanceID = journalInstanceID,
                }
            end
        end
    end
    return nil
end

function GoldTracker:ResolveCatalogFarmInstanceEntrance(catalogFarm)
    local sourceCategory = NormalizeInstanceName(catalogFarm and catalogFarm.sourceCategory)
    local sourcePath = NormalizeInstanceName(catalogFarm and catalogFarm.sourcePath)
    if sourceCategory ~= "instances" and not (sourcePath and sourcePath:find("instances", 1, true)) then
        return nil
    end

    local instance = FindInstanceRecord(catalogFarm)
    if not instance then
        return nil
    end

    local maps = {}
    local seen = {}
    local function addMap(mapID)
        mapID = tonumber(mapID)
        if mapID and not seen[mapID] then
            seen[mapID] = true
            maps[#maps + 1] = mapID
        end
    end

    local entrance = instance.entrance or instance.entranceLocation
    addMap(entrance and entrance.mapID)
    local lineage = GetMapLineage(instance.mapID)
    addMap(lineage[2])
    for _, mapID in ipairs(lineage) do
        if IsContinentMap(GetMapInfo(mapID)) then
            addMap(mapID)
            break
        end
    end

    for _, mapID in ipairs(maps) do
        local resolved = self:ResolveInstanceEntranceOnMap(instance, mapID)
        if resolved then
            local mapInfo = GetMapInfo(mapID)
            return {
                id = "instance-entrance:" .. tostring(resolved.journalInstanceID) .. ":" .. tostring(mapID),
                mapID = mapID,
                mapName = mapInfo and mapInfo.name or ("Map " .. tostring(mapID)),
                label = resolved.name or ((catalogFarm.name or "Instance") .. " entrance"),
                x = resolved.x,
                y = resolved.y,
                confidence = "exact",
                confidenceLabel = "Exact instance entrance",
                journalInstanceID = resolved.journalInstanceID,
            }
        end
    end
    return nil
end
