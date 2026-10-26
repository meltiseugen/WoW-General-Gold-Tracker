local _, NS = ...
local GoldTracker = NS.GoldTracker

local function TrimText(value)
    if type(value) ~= "string" then
        return nil
    end
    local trimmed = value:match("^%s*(.-)%s*$")
    return trimmed ~= "" and trimmed or nil
end

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

local function GetPointXY(point)
    if type(point) ~= "table" then
        return nil, nil
    end
    if type(point.GetXY) == "function" then
        local ok, x, y = pcall(point.GetXY, point)
        if ok then
            return NormalizeCoordinate(x), NormalizeCoordinate(y)
        end
    end
    return NormalizeCoordinate(point.x or point[1]), NormalizeCoordinate(point.y or point[2])
end

local function GetCatalogFarmByID(farmID, entry)
    if entry and type(entry.catalogSnapshot) == "table" then return entry.catalogSnapshot end
    local catalog = NS.FarmCatalog
    local position = type(catalog) == "table" and type(catalog.byID) == "table" and catalog.byID[farmID] or nil
    return position and type(catalog.farms) == "table" and catalog.farms[tonumber(position)] or nil
end

local function GetMapInfo(mapID)
    if not tonumber(mapID) or type(C_Map) ~= "table" or type(C_Map.GetMapInfo) ~= "function" then
        return nil
    end
    local ok, mapInfo = pcall(C_Map.GetMapInfo, tonumber(mapID))
    return ok and type(mapInfo) == "table" and mapInfo or nil
end

local function IsContinentMap(mapInfo)
    local mapType = tonumber(mapInfo and mapInfo.mapType)
    if Enum and Enum.UIMapType and Enum.UIMapType.Continent then
        return mapType == Enum.UIMapType.Continent
    end
    return mapType == 2
end

local function GetContinentMapID(mapID)
    local currentMapID = tonumber(mapID)
    local lastMapID = currentMapID
    local visited = {}
    for _ = 1, 15 do
        if not currentMapID or currentMapID <= 0 or visited[currentMapID] then
            break
        end
        visited[currentMapID] = true
        lastMapID = currentMapID
        local mapInfo = GetMapInfo(currentMapID)
        if IsContinentMap(mapInfo) then
            return currentMapID
        end
        currentMapID = tonumber(mapInfo and mapInfo.parentMapID)
    end
    return lastMapID
end

local function GetSharedRouteOverviewMapID(plan)
    local firstMapID
    local allSameMap = true
    for _, node in ipairs(plan or {}) do
        local mapID = tonumber(node and node.mapID)
        if not mapID then
            return nil, "Every route stop needs map data before an overview can be built."
        end
        firstMapID = firstMapID or mapID
        if mapID ~= firstMapID then
            allSameMap = false
        end
    end
    if not firstMapID then
        return nil, "This route has no stops to display."
    end
    if allSameMap then
        return firstMapID
    end

    local sharedParentMapID
    for _, node in ipairs(plan) do
        local mapInfo = GetMapInfo(node.mapID)
        local parentMapID = tonumber(mapInfo and mapInfo.parentMapID)
        if not parentMapID or parentMapID <= 0 then
            return nil, "The route stops do not share one parent map."
        end
        sharedParentMapID = sharedParentMapID or parentMapID
        if parentMapID ~= sharedParentMapID then
            return nil, "The route stops do not share one parent map."
        end
    end
    return sharedParentMapID
end

local function ProjectRoutePointToOverviewMap(sourceMapID, overviewMapID, x, y)
    sourceMapID = tonumber(sourceMapID)
    overviewMapID = tonumber(overviewMapID)
    x = NormalizeCoordinate(x) or 0.5
    y = NormalizeCoordinate(y) or 0.5
    if sourceMapID == overviewMapID then
        return x, y
    end
    if not sourceMapID or not overviewMapID or type(C_Map) ~= "table"
        or type(C_Map.GetMapRectOnMap) ~= "function" then
        return nil, nil
    end
    local ok, minX, maxX, minY, maxY = pcall(C_Map.GetMapRectOnMap, sourceMapID, overviewMapID)
    minX, maxX, minY, maxY = tonumber(minX), tonumber(maxX), tonumber(minY), tonumber(maxY)
    if not ok or not minX or not maxX or not minY or not maxY or minX == maxX or minY == maxY then
        return nil, nil
    end
    local projectedX = minX + (x * (maxX - minX))
    local projectedY = minY + (y * (maxY - minY))
    if projectedX < 0 or projectedX > 1 or projectedY < 0 or projectedY > 1 then
        return nil, nil
    end
    return projectedX, projectedY
end

local function GetPlayerLocation()
    if type(C_Map) ~= "table" or type(C_Map.GetBestMapForUnit) ~= "function" then
        return nil
    end
    local ok, mapID = pcall(C_Map.GetBestMapForUnit, "player")
    mapID = ok and tonumber(mapID) or nil
    if not mapID then
        return nil
    end
    local x
    local y
    if type(C_Map.GetPlayerMapPosition) == "function" then
        local positionOK, position = pcall(C_Map.GetPlayerMapPosition, mapID, "player")
        if positionOK then
            x, y = GetPointXY(position)
        end
    end
    return {
        mapID = mapID,
        continentMapID = GetContinentMapID(mapID),
        x = x,
        y = y,
    }
end

local function GetClosestRoutePoint(coords, playerLocation, mapID)
    local bestX
    local bestY
    local bestDistance
    for _, coord in ipairs(type(coords) == "table" and coords or {}) do
        local x = NormalizeCoordinate(coord and coord.x)
        local y = NormalizeCoordinate(coord and coord.y)
        if x and y then
            local distance = 0
            if playerLocation and playerLocation.mapID == mapID and playerLocation.x and playerLocation.y then
                distance = ((x - playerLocation.x) ^ 2) + ((y - playerLocation.y) ^ 2)
            elseif bestX then
                distance = 1
            end
            if not bestX or distance < bestDistance then
                bestX = x
                bestY = y
                bestDistance = distance
            end
        end
    end
    return bestX, bestY
end

local function BuildCatalogCandidates(addon, catalogFarm, playerLocation)
    local candidates = {}
    local seen = {}
    local mapsWithExactRoutes = {}
    local instanceEntrance
    if type(catalogFarm.ggtEntrance) == "table" then
        instanceEntrance = catalogFarm.ggtEntrance
        candidates[#candidates + 1] = instanceEntrance
        seen[instanceEntrance.id] = true
    elseif type(addon.ResolveCatalogFarmInstanceEntrance) == "function" then
        instanceEntrance = addon:ResolveCatalogFarmInstanceEntrance(catalogFarm)
        if instanceEntrance then
            candidates[#candidates + 1] = instanceEntrance
            seen[instanceEntrance.id] = true
        end
    end
    local records = catalogFarm.ggtGatheringRecords
    if not records then records = type(NS.CatalogGatheringData) == "table" and NS.CatalogGatheringData.farmsByRecordID or nil end
    for _, recordID in ipairs(catalogFarm and catalogFarm.sourceRecordIDs or {}) do
        local record = records and records[recordID] or nil
        for routeIndex, route in ipairs(type(record) == "table" and record.routes or {}) do
            local mapID = tonumber(route and route.mapID)
            local x, y = GetClosestRoutePoint(route and route.coords, playerLocation, mapID)
            if mapID and x and y then
                local key = table.concat({ tostring(recordID), tostring(routeIndex), tostring(mapID) }, ":")
                if not seen[key] then
                    seen[key] = true
                    mapsWithExactRoutes[mapID] = true
                    candidates[#candidates + 1] = {
                        id = "route:" .. key,
                        mapID = mapID,
                        mapName = TrimText(route.mapName) or TrimText(route.name) or ("Map " .. tostring(mapID)),
                        label = TrimText(route.name) or TrimText(route.mapName) or catalogFarm.name,
                        x = x,
                        y = y,
                        confidence = "exact",
                        confidenceLabel = "Exact route point",
                    }
                end
            end
        end
    end

    for index, rawMapID in ipairs(not instanceEntrance and catalogFarm and catalogFarm.mapIDs or {}) do
        local mapID = tonumber(rawMapID)
        local key = mapID and ("map:" .. tostring(mapID)) or nil
        if key and not seen[key] and not mapsWithExactRoutes[mapID] then
            seen[key] = true
            candidates[#candidates + 1] = {
                id = key,
                mapID = mapID,
                mapName = catalogFarm.mapNames and catalogFarm.mapNames[index] or ("Map " .. tostring(mapID)),
                label = catalogFarm.mapNames and catalogFarm.mapNames[index] or catalogFarm.name,
                confidence = "approximate",
                confidenceLabel = "Map known; exact arrival unavailable",
            }
        end
    end
    return candidates
end

local function BuildStandaloneCandidates(addon, step)
    local candidates = {}
    local entry = step and step.entries and step.entries[1] or nil
    local option = entry and entry.mapSource and addon:ResolveCustomFarmEntryMapOption(entry) or nil
    local pin = option and option.pins and option.pins[1] or nil
    local mapID = tonumber(option and option.mapID or (entry and entry.mapID))
    if mapID then
        local x = NormalizeCoordinate(option and pin and pin.x or (not option and entry.x))
        local y = NormalizeCoordinate(option and pin and pin.y or (not option and entry.y))
        candidates[1] = {
            id = "entry:" .. tostring(entry.id or entry.entryKey),
            mapID = mapID,
            mapName = option and (option.mapLabel or (GetMapInfo(mapID) or {}).name or option.label)
                or TrimText(entry.locationLabel) or ("Map " .. tostring(mapID)),
            label = option and option.label or TrimText(entry.locationLabel) or step.name,
            x = x,
            y = y,
            confidence = x and y and "exact" or "approximate",
            confidenceLabel = x and y and "Exact source point" or "Map known; exact arrival unavailable",
        }
    end
    return candidates
end

local function GetPlanState(farm)
    farm.routePlan = type(farm.routePlan) == "table" and farm.routePlan or {}
    local state = farm.routePlan
    state.order = type(state.order) == "table" and state.order or {}
    state.locked = type(state.locked) == "table" and state.locked or {}
    state.locationOverrides = type(state.locationOverrides) == "table" and state.locationOverrides or {}
    state.runs = type(state.runs) == "table" and state.runs or {}
    return state
end

local FARM_GUIDANCE_SETTING_KEYS = {
    areaIndicator = true,
    routeDeviation = true,
    recoveryArrow = true,
    breadcrumbs = true,
    minimapOverlay = true,
}

function GoldTracker:GetCustomFarmGuidanceSettings(farmID)
    local farm = self:GetCustomFarmByID(farmID)
    if not farm then
        return nil
    end
    local state = GetPlanState(farm)
    state.guidance = type(state.guidance) == "table" and state.guidance or {}
    for key in pairs(FARM_GUIDANCE_SETTING_KEYS) do
        if type(state.guidance[key]) ~= "boolean" then
            state.guidance[key] = true
        end
    end
    return state.guidance
end

function GoldTracker:SetCustomFarmGuidanceSetting(farmID, key, enabled)
    if FARM_GUIDANCE_SETTING_KEYS[key] ~= true then
        return false
    end
    local settings = self:GetCustomFarmGuidanceSettings(farmID)
    if not settings then
        return false
    end
    settings[key] = enabled == true
    if key == "areaIndicator" then
        settings.minimapOverlay = settings.areaIndicator
    elseif key == "minimapOverlay" then
        settings.areaIndicator = settings.minimapOverlay
    end
    local farm = self:GetCustomFarmByID(farmID)
    if farm then
        farm.updatedAt = type(time) == "function" and time() or farm.updatedAt
    end
    self:NotifyFarmRoutePlanChanged()
    if (key == "minimapOverlay" or key == "areaIndicator")
        and type(self.RefreshMinimapProjectionPins) == "function" then
        self:RefreshMinimapProjectionPins(true)
    end
    return true
end

function GoldTracker:ToggleActiveCustomFarmGuidanceSetting(key)
    local active = type(self.GetActiveCustomFarmRoutePlan) == "function"
        and self:GetActiveCustomFarmRoutePlan() or nil
    if not active or not active.farm then
        return false
    end
    local settings = self:GetCustomFarmGuidanceSettings(active.farm.id)
    if not settings or FARM_GUIDANCE_SETTING_KEYS[key] ~= true then
        return false
    end
    return self:SetCustomFarmGuidanceSetting(active.farm.id, key, settings[key] == false)
end

function GoldTracker:IsActiveCustomFarmMinimapOverlayEnabled()
    local store = self:GetCustomFarmStore()
    local character = self:RegisterCurrentCustomFarmCharacter()
    local farmID = store and character and type(store.activeRouteFarmIDs) == "table"
        and store.activeRouteFarmIDs[character] or nil
    if not farmID then
        return true
    end
    local settings = self:GetCustomFarmGuidanceSettings(farmID)
    return not settings or (settings.minimapOverlay ~= false and settings.areaIndicator ~= false)
end

function GoldTracker:IsActiveCustomFarmBreadcrumbsEnabled()
    local store = self:GetCustomFarmStore()
    local character = self:RegisterCurrentCustomFarmCharacter()
    local farmID = store and character and type(store.activeRouteFarmIDs) == "table"
        and store.activeRouteFarmIDs[character] or nil
    if not farmID then
        return true
    end
    local settings = self:GetCustomFarmGuidanceSettings(farmID)
    return not settings or settings.breadcrumbs ~= false
end

local function SelectCandidate(candidates, overrideID, playerLocation)
    for _, candidate in ipairs(candidates) do
        if candidate.id == overrideID then
            return candidate
        end
    end
    if playerLocation then
        for _, candidate in ipairs(candidates) do
            if candidate.mapID == playerLocation.mapID then
                return candidate
            end
        end
    end
    return candidates[1]
end

local function IsInstancePlanStop(step, catalogFarm, destination)
    if destination and tonumber(destination.journalInstanceID) then
        return true
    end
    local sourcePath = TrimText((catalogFarm and catalogFarm.sourcePath) or (step and step.sourcePath))
    sourcePath = sourcePath and sourcePath:lower() or ""
    if sourcePath == "instances" or sourcePath:find("^instances%s*>") then
        return true
    end
    local activity = TrimText((catalogFarm and catalogFarm.activity) or (step and step.activity))
    activity = activity and activity:lower() or ""
    return activity:find("dungeon", 1, true) ~= nil
        or activity:find("raid", 1, true) ~= nil
        or activity:find("instance", 1, true) ~= nil
end

local function BuildPlanNodes(addon, farm, playerLocation)
    local state = GetPlanState(farm)
    local nodes = {}
    for originalIndex, step in ipairs(addon:GetCustomFarmSteps(farm)) do
        local catalogFarm = step.catalogFarmID and GetCatalogFarmByID(step.catalogFarmID, step.entries and step.entries[1]) or nil
        local candidates = catalogFarm and BuildCatalogCandidates(addon, catalogFarm, playerLocation) or BuildStandaloneCandidates(addon, step)
        local destination = SelectCandidate(candidates, state.locationOverrides[step.key], playerLocation)
        local mapID = destination and destination.mapID or tonumber(step.mapIDs and step.mapIDs[1])
        local mapInfo = GetMapInfo(mapID)
        nodes[#nodes + 1] = {
            key = step.key,
            name = step.name,
            activity = step.activity,
            sourcePath = step.sourcePath,
            catalogFarmID = step.catalogFarmID,
            entries = step.entries,
            targetCount = #(step.entries or {}),
            originalIndex = originalIndex,
            candidates = candidates,
            destination = destination,
            mapID = mapID,
            mapName = destination and destination.mapName or (mapInfo and mapInfo.name) or (step.mapNames and step.mapNames[1]),
            continentMapID = GetContinentMapID(mapID),
            x = destination and destination.x or nil,
            y = destination and destination.y or nil,
            confidence = destination and destination.confidence or "unknown",
            confidenceLabel = destination and destination.confidenceLabel or "Location unavailable",
            isInstance = IsInstancePlanStop(step, catalogFarm, destination),
            locked = state.locked[step.key] == true,
        }
    end
    return nodes
end

local function DistanceSquared(leftX, leftY, rightX, rightY)
    if not leftX or not leftY or not rightX or not rightY then
        return nil
    end
    return ((leftX - rightX) ^ 2) + ((leftY - rightY) ^ 2)
end

local function OrderGroup(nodes, startLocation)
    local remaining = {}
    for _, node in ipairs(nodes) do
        remaining[#remaining + 1] = node
    end
    local ordered = {}
    local currentMapID = startLocation and startLocation.mapID or nil
    local currentX = startLocation and startLocation.x or nil
    local currentY = startLocation and startLocation.y or nil
    while #remaining > 0 do
        local bestIndex = 1
        local bestScore
        for index, node in ipairs(remaining) do
            local score = node.originalIndex * 0.000001
            if not node.mapID then
                score = score + 1000
            elseif currentMapID and node.mapID == currentMapID then
                score = score + (DistanceSquared(currentX, currentY, node.x, node.y) or 0.5)
            elseif currentMapID then
                score = score + 10
            end
            if not bestScore or score < bestScore then
                bestScore = score
                bestIndex = index
            end
        end
        local selected = table.remove(remaining, bestIndex)
        ordered[#ordered + 1] = selected
        currentMapID = selected.mapID or currentMapID
        currentX = selected.x
        currentY = selected.y
    end
    return ordered
end

local function BuildSuggestedOrder(nodes, playerLocation)
    local groups = {}
    local groupOrder = {}
    for _, node in ipairs(nodes) do
        local key = node.mapID and ("continent:" .. tostring(node.continentMapID or node.mapID)) or "unknown"
        if not groups[key] then
            groups[key] = { key = key, nodes = {}, firstIndex = node.originalIndex, unknown = key == "unknown" }
            groupOrder[#groupOrder + 1] = groups[key]
        end
        groups[key].nodes[#groups[key].nodes + 1] = node
    end
    table.sort(groupOrder, function(left, right)
        local currentKey = playerLocation and ("continent:" .. tostring(playerLocation.continentMapID or playerLocation.mapID)) or nil
        if left.key == currentKey and right.key ~= currentKey then
            return true
        elseif right.key == currentKey and left.key ~= currentKey then
            return false
        elseif left.unknown ~= right.unknown then
            return not left.unknown
        end
        return left.firstIndex < right.firstIndex
    end)
    local ordered = {}
    for _, group in ipairs(groupOrder) do
        local startLocation = playerLocation and group.key == ("continent:" .. tostring(playerLocation.continentMapID or playerLocation.mapID)) and playerLocation or nil
        for _, node in ipairs(OrderGroup(group.nodes, startLocation)) do
            ordered[#ordered + 1] = node
        end
    end
    return ordered
end

local function ApplyLockedPositions(suggested, previousOrder, locked)
    local byKey = {}
    for _, node in ipairs(suggested) do
        byKey[node.key] = node
    end
    local result = {}
    local used = {}
    for index, key in ipairs(previousOrder or {}) do
        if index <= #suggested and locked[key] and byKey[key] then
            result[index] = byKey[key]
            used[key] = true
        end
    end
    local nextSuggestedIndex = 1
    for index = 1, #suggested do
        if not result[index] then
            while suggested[nextSuggestedIndex] and used[suggested[nextSuggestedIndex].key] do
                nextSuggestedIndex = nextSuggestedIndex + 1
            end
            result[index] = suggested[nextSuggestedIndex]
            if result[index] then
                used[result[index].key] = true
            end
            nextSuggestedIndex = nextSuggestedIndex + 1
        end
    end
    return result
end

local function OrderFromSavedKeys(nodes, savedOrder)
    local byKey = {}
    for _, node in ipairs(nodes) do
        byKey[node.key] = node
    end
    local ordered = {}
    for _, key in ipairs(savedOrder or {}) do
        if byKey[key] then
            ordered[#ordered + 1] = byKey[key]
            byKey[key] = nil
        end
    end
    table.sort(nodes, function(left, right) return left.originalIndex < right.originalIndex end)
    for _, node in ipairs(nodes) do
        if byKey[node.key] then
            ordered[#ordered + 1] = node
            byKey[node.key] = nil
        end
    end
    return ordered
end

local function SaveOrder(state, nodes)
    state.order = {}
    for _, node in ipairs(nodes) do
        state.order[#state.order + 1] = node.key
    end
end

function GoldTracker:InvalidateCustomFarmRoutePlanCache(farmID)
    if farmID == nil then
        self.customFarmRoutePlanCache = {}
        return
    end
    if type(self.customFarmRoutePlanCache) == "table" then
        self.customFarmRoutePlanCache[farmID] = nil
    end
end

function GoldTracker:BuildCustomFarmRoutePlan(farmID, recalculate)
    local farm = self:GetCustomFarmByID(farmID)
    if not farm then
        return {}
    end
    self.customFarmRoutePlanCache = type(self.customFarmRoutePlanCache) == "table"
        and self.customFarmRoutePlanCache or {}
    local cached = self.customFarmRoutePlanCache[farm.id]
    if recalculate ~= true and cached and cached.farm == farm then
        return cached.plan
    end
    local state = GetPlanState(farm)
    local playerLocation = GetPlayerLocation()
    local nodes = BuildPlanNodes(self, farm, playerLocation)
    local ordered
    if recalculate == true or #state.order == 0 then
        ordered = ApplyLockedPositions(BuildSuggestedOrder(nodes, playerLocation), state.order, state.locked)
        SaveOrder(state, ordered)
        farm.updatedAt = type(time) == "function" and time() or farm.updatedAt
    else
        ordered = OrderFromSavedKeys(nodes, state.order)
        SaveOrder(state, ordered)
    end
    self.customFarmRoutePlanCache[farm.id] = {
        farm = farm,
        plan = ordered,
    }
    return ordered
end

function GoldTracker:HasCustomFarmRoutePlan(farmID)
    local farm = self:GetCustomFarmByID(farmID)
    return farm ~= nil
        and type(farm.routePlan) == "table"
        and type(farm.routePlan.order) == "table"
        and #farm.routePlan.order > 0
end

function GoldTracker:NotifyFarmRoutePlanChanged()
    self:InvalidateCustomFarmRoutePlanCache()
    if self.farmRoutePlanFrame and type(self.RefreshFarmRoutePlanWindow) == "function" then
        self:RefreshFarmRoutePlanWindow()
    end
    if self.myFarmsFrame and type(self.RefreshMyFarmsWindow) == "function" then
        self:RefreshMyFarmsWindow()
    end
    if self.mainFrame and type(self.UpdateMainWindow) == "function" then
        self:UpdateMainWindow()
    end
    if type(self.RefreshFarmingHud) == "function" then
        self:RefreshFarmingHud(true)
    end
end

function GoldTracker:MoveCustomFarmRoutePlanStep(farmID, stepKey, direction)
    local farm = self:GetCustomFarmByID(farmID)
    local state = farm and GetPlanState(farm) or nil
    if not state then
        return false
    end
    self:BuildCustomFarmRoutePlan(farmID, false)
    local index
    for position, key in ipairs(state.order) do
        if key == stepKey then
            index = position
            break
        end
    end
    local targetIndex = index and (index + (tonumber(direction) or 0)) or nil
    if not targetIndex or targetIndex < 1 or targetIndex > #state.order then
        return false
    end
    state.order[index], state.order[targetIndex] = state.order[targetIndex], state.order[index]
    farm.updatedAt = type(time) == "function" and time() or farm.updatedAt
    self:NotifyFarmRoutePlanChanged()
    return true
end

function GoldTracker:SetCustomFarmRoutePlanStepLocked(farmID, stepKey, locked)
    local farm = self:GetCustomFarmByID(farmID)
    local state = farm and GetPlanState(farm) or nil
    if not state or not TrimText(stepKey) then
        return false
    end
    state.locked[stepKey] = locked == true or nil
    farm.updatedAt = type(time) == "function" and time() or farm.updatedAt
    self:NotifyFarmRoutePlanChanged()
    return true
end

function GoldTracker:CycleCustomFarmRoutePlanLocation(farmID, stepKey)
    local farm = self:GetCustomFarmByID(farmID)
    local state = farm and GetPlanState(farm) or nil
    if not state then
        return false
    end
    local plan = self:BuildCustomFarmRoutePlan(farmID, false)
    for _, node in ipairs(plan) do
        if node.key == stepKey and #node.candidates > 1 then
            local selectedIndex = 1
            for index, candidate in ipairs(node.candidates) do
                if node.destination and candidate.id == node.destination.id then
                    selectedIndex = index
                    break
                end
            end
            local nextCandidate = node.candidates[(selectedIndex % #node.candidates) + 1]
            state.locationOverrides[stepKey] = nextCandidate.id
            farm.updatedAt = type(time) == "function" and time() or farm.updatedAt
            self:NotifyFarmRoutePlanChanged()
            return true
        end
    end
    return false
end

local function GetCharacterRunState(addon, farm, reset)
    local state = GetPlanState(farm)
    local character = addon:RegisterCurrentCustomFarmCharacter() or "Unknown character"
    if reset or type(state.runs[character]) ~= "table" then
        state.runs[character] = { completed = {}, currentStepKey = nil }
    end
    local run = state.runs[character]
    run.completed = type(run.completed) == "table" and run.completed or {}
    return run, character
end

local function GetActiveRouteProjectionKey(farmID)
    return "active-farm-route:" .. tostring(farmID)
end

local function RecordClosedFarmRun(addon, farm, run, closeReason)
    if type(run) ~= "table" then
        return false
    end
    run.closedAt = type(time) == "function" and time() or 0
    run.closeReason = closeReason or "stopped"
    if type(addon.SaveCustomFarmRunToHistory) == "function" then
        return addon:SaveCustomFarmRunToHistory(farm, run, run.closeReason) == true
    end
    return false
end

local function FindRoutePlanNode(addon, farmID, stepKey)
    for _, node in ipairs(addon:BuildCustomFarmRoutePlan(farmID, false)) do
        if node.key == stepKey then
            return node
        end
    end
    return nil
end

local function SelectRoutePlanMapOption(mapOptions, node)
    local selectedIndex = 1
    local sameMapIndex
    for index, option in ipairs(mapOptions or {}) do
        if tonumber(option.mapID) == tonumber(node and node.mapID) then
            sameMapIndex = sameMapIndex or index
            if node.destination and option.location == node.destination.label then
                selectedIndex = index
                break
            end
        end
    end
    if selectedIndex == 1 and sameMapIndex then
        selectedIndex = sameMapIndex
    end
    return mapOptions and mapOptions[selectedIndex] or nil, selectedIndex
end

function GoldTracker:BuildCustomFarmRoutePlanStepProjection(farmID, stepKey)
    local selected = FindRoutePlanNode(self, farmID, stepKey)
    if not selected or not selected.mapID then
        return nil
    end

    local firstEntry = selected.entries and selected.entries[1] or nil
    local mapOptions
    local mapOption
    local selectedMapOptionIndex = 1
    if selected.catalogFarmID and type(self.BuildFarmDetailsMapOptions) == "function" then
        local catalogFarm = GetCatalogFarmByID(selected.catalogFarmID, firstEntry)
        mapOptions = catalogFarm and self:BuildFarmDetailsMapOptions(
            { catalogFarm },
            firstEntry and firstEntry.itemID or nil
        ) or nil
        mapOption, selectedMapOptionIndex = SelectRoutePlanMapOption(mapOptions, selected)
    elseif firstEntry and firstEntry.mapSource and type(self.ResolveCustomFarmEntryMapOption) == "function" then
        mapOption = self:ResolveCustomFarmEntryMapOption(firstEntry)
        mapOptions = mapOption and { mapOption } or nil
    end

    local pins = mapOption and mapOption.pins or nil
    if type(pins) ~= "table" or #pins == 0 then
        if not selected.x or not selected.y then
            return nil
        end
        pins = {
            {
                mapID = selected.mapID,
                x = selected.x,
                y = selected.y,
                label = selected.destination and selected.destination.label or selected.name,
                isRoute = false,
            },
        }
        mapOptions = {
            {
                id = selected.destination and selected.destination.id or tostring(stepKey),
                mapID = selected.mapID,
                mapLabel = selected.mapName,
                label = selected.destination and selected.destination.label or selected.mapName,
                pins = pins,
            },
        }
        selectedMapOptionIndex = 1
    end

    return {
        title = selected.name or "Active farm route",
        projectionKey = GetActiveRouteProjectionKey(farmID),
        mapID = selected.mapID,
        mapLabel = selected.mapName,
        pins = pins,
        mapOptions = mapOptions,
        selectedMapOptionIndex = selectedMapOptionIndex,
        customFarmRow = firstEntry and {
            itemID = firstEntry.itemID,
            itemName = firstEntry.itemName,
            itemLink = firstEntry.itemLink,
        } or nil,
        silent = true,
        openMap = false,
    }
end

function GoldTracker:ClearCustomFarmRoutePlanNavigation(farmID, clearWaypoint)
    if farmID == nil then
        return false
    end
    local hudRuntime = self.farmingHudRuntime
    if clearWaypoint == true and hudRuntime and hudRuntime.farmID == farmID and self.FarmRecoveryWaypoint then
        self.FarmRecoveryWaypoint:Clear(hudRuntime)
    end
    local cleared = false
    if type(self.ClearWorldMapProjectionByKey) == "function" then
        cleared = self:ClearWorldMapProjectionByKey(GetActiveRouteProjectionKey(farmID), true) == true or cleared
    end
    if clearWaypoint == true and type(C_Map) == "table" and type(C_Map.ClearUserWaypoint) == "function" then
        pcall(C_Map.ClearUserWaypoint)
        if C_SuperTrack and type(C_SuperTrack.SetSuperTrackedUserWaypoint) == "function" then
            pcall(C_SuperTrack.SetSuperTrackedUserWaypoint, false)
        end
        cleared = true
    end
    return cleared
end

function GoldTracker:ActivateCustomFarmRoutePlanStep(farmID, stepKey)
    local selected = FindRoutePlanNode(self, farmID, stepKey)
    if not selected then
        return false
    end

    self:ClearCustomFarmRoutePlanNavigation(farmID, true)
    local projection = self:BuildCustomFarmRoutePlanStepProjection(farmID, stepKey)
    local projected = false
    if projection and type(self.ProjectMapRouteToWorldMap) == "function" then
        projected = self:ProjectMapRouteToWorldMap(projection) == true
    end

    if selected.x and selected.y then
        return self:NavigateCustomFarmRoutePlanStep(farmID, stepKey) or projected
    end
    if projected then
        return true
    end
    return self:NavigateCustomFarmRoutePlanStep(farmID, stepKey)
end

function GoldTracker:GetCustomFarmRoutePlanRun(farmID)
    local farm = self:GetCustomFarmByID(farmID)
    if not farm then
        return nil
    end
    return GetCharacterRunState(self, farm, false)
end

function GoldTracker:StartCustomFarmRoutePlan(farmID)
    local farm = self:GetCustomFarmByID(farmID)
    if not farm then
        return false
    end
    local plan = self:BuildCustomFarmRoutePlan(farmID, false)
    local run, character = GetCharacterRunState(self, farm, true)
    run.startedAt = type(time) == "function" and time() or 0
    run.currentStepKey = plan[1] and plan[1].key or nil
    local store = self:GetCustomFarmStore()
    local previousActiveFarmID = store and character and type(store.activeRouteFarmIDs) == "table"
        and store.activeRouteFarmIDs[character] or nil
    if previousActiveFarmID and previousActiveFarmID ~= farm.id then
        self:StopCustomFarmRoutePlan(previousActiveFarmID, "replaced")
    end
    if store and character then
        store.activeRouteFarmIDs = type(store.activeRouteFarmIDs) == "table" and store.activeRouteFarmIDs or {}
        if run.currentStepKey then
            store.activeRouteFarmIDs[character] = farm.id
        elseif store.activeRouteFarmIDs[character] == farm.id then
            store.activeRouteFarmIDs[character] = nil
        end
    end
    local guidanceSettings = self:GetCustomFarmGuidanceSettings(farm.id)
    if guidanceSettings then
        guidanceSettings.breadcrumbs = false
        guidanceSettings.minimapOverlay = true
    end
    self:NotifyFarmRoutePlanChanged()
    if run.currentStepKey then
        self:ActivateCustomFarmRoutePlanStep(farm.id, run.currentStepKey)
    else
        self:ClearCustomFarmRoutePlanNavigation(farm.id, true)
    end
    return #plan > 0
end

function GoldTracker:ResetCustomFarmRoutePlanRun(farmID)
    local farm = self:GetCustomFarmByID(farmID)
    if not farm then
        return false
    end
    local run, character = GetCharacterRunState(self, farm, false)
    local store = self:GetCustomFarmStore()
    local wasActive = store and character and type(store.activeRouteFarmIDs) == "table"
        and store.activeRouteFarmIDs[character] == farm.id
    if wasActive then
        store.activeRouteFarmIDs[character] = nil
        RecordClosedFarmRun(self, farm, run, "reset")
    end
    GetCharacterRunState(self, farm, true)
    self:ClearCustomFarmRoutePlanNavigation(farm.id, wasActive)
    self:NotifyFarmRoutePlanChanged()
    return true
end

function GoldTracker:StopCustomFarmRoutePlan(farmID, closeReason)
    local farm = self:GetCustomFarmByID(farmID)
    if not farm then
        return false
    end
    local run, character = GetCharacterRunState(self, farm, false)
    local store = self:GetCustomFarmStore()
    local wasActive = store and character and type(store.activeRouteFarmIDs) == "table"
        and store.activeRouteFarmIDs[character] == farm.id
    if wasActive then
        store.activeRouteFarmIDs[character] = nil
        RecordClosedFarmRun(self, farm, run, closeReason or "stopped")
    end
    run.currentStepKey = nil
    self:ClearCustomFarmRoutePlanNavigation(farm.id, wasActive)
    self:NotifyFarmRoutePlanChanged()
    return true
end

function GoldTracker:IsCustomFarmRoutePlanActive(farmID)
    local active = self:GetActiveCustomFarmRoutePlan()
    return active ~= nil
        and active.farm ~= nil
        and active.farm.id == farmID
end

function GoldTracker:ToggleCustomFarmRoutePlan(farmID)
    if self:IsCustomFarmRoutePlanActive(farmID) then
        return self:StopCustomFarmRoutePlan(farmID)
    end
    return self:StartCustomFarmRoutePlan(farmID)
end

local function FindNextIncomplete(plan, run, currentKey, wrap)
    local currentIndex = 0
    for index, node in ipairs(plan) do
        if node.key == currentKey then
            currentIndex = index
            break
        end
    end
    for index = currentIndex + 1, #plan do
        if not run.completed[plan[index].key] then
            return plan[index].key
        end
    end
    if wrap then
        for index = 1, currentIndex - 1 do
            if not run.completed[plan[index].key] then
                return plan[index].key
            end
        end
    end
    return nil
end

function GoldTracker:SetCustomFarmRoutePlanStepComplete(farmID, stepKey, complete)
    local farm = self:GetCustomFarmByID(farmID)
    if not farm then
        return false
    end
    local plan = self:BuildCustomFarmRoutePlan(farmID, false)
    local run, character = GetCharacterRunState(self, farm, false)
    local wasCurrent = run.currentStepKey == stepKey
    run.completed[stepKey] = complete == true or nil
    if complete == true and wasCurrent then
        run.currentStepKey = FindNextIncomplete(plan, run, stepKey, false)
    elseif complete ~= true then
        run.currentStepKey = stepKey
    end
    local store = self:GetCustomFarmStore()
    local previousActiveFarmID = store and character and type(store.activeRouteFarmIDs) == "table"
        and store.activeRouteFarmIDs[character] or nil
    local closedActiveFarm = false
    if store and character then
        store.activeRouteFarmIDs = type(store.activeRouteFarmIDs) == "table" and store.activeRouteFarmIDs or {}
        local isActiveFarm = store.activeRouteFarmIDs[character] == farm.id
        if complete ~= true and run.currentStepKey then
            store.activeRouteFarmIDs[character] = farm.id
        elseif isActiveFarm and not run.currentStepKey then
            store.activeRouteFarmIDs[character] = nil
            closedActiveFarm = true
        end
    end
    if closedActiveFarm then
        RecordClosedFarmRun(self, farm, run, "completed")
    end
    self:NotifyFarmRoutePlanChanged()
    if complete ~= true and run.currentStepKey == stepKey then
        if previousActiveFarmID and previousActiveFarmID ~= farm.id then
            self:ClearCustomFarmRoutePlanNavigation(previousActiveFarmID, true)
        end
        self:ActivateCustomFarmRoutePlanStep(farm.id, stepKey)
    elseif wasCurrent and previousActiveFarmID == farm.id then
        if run.currentStepKey then
            self:ActivateCustomFarmRoutePlanStep(farm.id, run.currentStepKey)
        else
            self:ClearCustomFarmRoutePlanNavigation(farm.id, true)
        end
    end
    return true
end

function GoldTracker:SkipCustomFarmRoutePlanStep(farmID)
    local farm = self:GetCustomFarmByID(farmID)
    if not farm then
        return false
    end
    local plan = self:BuildCustomFarmRoutePlan(farmID, false)
    local run, character = GetCharacterRunState(self, farm, false)
    run.currentStepKey = FindNextIncomplete(plan, run, run.currentStepKey, true)
    self:NotifyFarmRoutePlanChanged()
    local store = self:GetCustomFarmStore()
    local isActive = store and character and type(store.activeRouteFarmIDs) == "table"
        and store.activeRouteFarmIDs[character] == farm.id
    if isActive and run.currentStepKey then
        self:ActivateCustomFarmRoutePlanStep(farm.id, run.currentStepKey)
    elseif isActive then
        self:ClearCustomFarmRoutePlanNavigation(farm.id, true)
    end
    return run.currentStepKey ~= nil
end

function GoldTracker:SetCustomFarmRoutePlanCurrentStep(farmID, stepKey)
    local farm = self:GetCustomFarmByID(farmID)
    if not farm then
        return false
    end
    local exists = false
    for _, node in ipairs(self:BuildCustomFarmRoutePlan(farmID, false)) do
        if node.key == stepKey then
            exists = true
            break
        end
    end
    if not exists then
        return false
    end
    local run, character = GetCharacterRunState(self, farm, false)
    run.currentStepKey = stepKey
    run.startedAt = tonumber(run.startedAt) or (type(time) == "function" and time() or 0)
    local store = self:GetCustomFarmStore()
    local previousActiveFarmID = store and character and type(store.activeRouteFarmIDs) == "table"
        and store.activeRouteFarmIDs[character] or nil
    if previousActiveFarmID and previousActiveFarmID ~= farm.id then
        self:ClearCustomFarmRoutePlanNavigation(previousActiveFarmID, true)
    end
    if store and character then
        store.activeRouteFarmIDs = type(store.activeRouteFarmIDs) == "table" and store.activeRouteFarmIDs or {}
        store.activeRouteFarmIDs[character] = farm.id
    end
    self:NotifyFarmRoutePlanChanged()
    return true
end

function GoldTracker:GetActiveCustomFarmRoutePlan()
    local store = self:GetCustomFarmStore()
    local character = self:RegisterCurrentCustomFarmCharacter()
    local farmID = store and character and type(store.activeRouteFarmIDs) == "table"
        and store.activeRouteFarmIDs[character] or nil
    local farm = farmID and self:GetCustomFarmByID(farmID) or nil
    if not farm then
        return nil
    end

    local plan = self:BuildCustomFarmRoutePlan(farm.id, false)
    local run = GetCharacterRunState(self, farm, false)
    local currentNode
    local currentIndex
    for index, node in ipairs(plan) do
        if node.key == run.currentStepKey then
            currentNode = node
            currentIndex = index
            break
        end
    end
    if not currentNode then
        store.activeRouteFarmIDs[character] = nil
        self:ClearCustomFarmRoutePlanNavigation(farm.id, true)
        return nil
    end

    return {
        farm = farm,
        plan = plan,
        run = run,
        character = character,
        currentNode = currentNode,
        currentIndex = currentIndex,
        totalSteps = #plan,
        canGoPrevious = currentIndex > 1,
        canGoNext = currentIndex < #plan,
    }
end

function GoldTracker:NavigateActiveCustomFarmRoutePlanStep(direction)
    local active = self:GetActiveCustomFarmRoutePlan()
    local offset = tonumber(direction) or 0
    local targetIndex = active and (active.currentIndex + offset) or nil
    local target = targetIndex and active.plan[targetIndex] or nil
    if not target then
        return false
    end
    if not self:SetCustomFarmRoutePlanCurrentStep(active.farm.id, target.key) then
        return false
    end
    return self:ActivateCustomFarmRoutePlanStep(active.farm.id, target.key)
end

function GoldTracker:BuildCustomFarmRoutePlanOverview(farmID)
    local farm = self:GetCustomFarmByID(farmID)
    if not farm then
        return nil, "The selected custom farm is unavailable."
    end
    local plan = self:BuildCustomFarmRoutePlan(farm.id, false)
    local overviewMapID, reason = GetSharedRouteOverviewMapID(plan)
    if not overviewMapID then
        return nil, reason
    end

    local routeID = "farm-plan:" .. tostring(farm.id)
    local pins = {}
    for index, node in ipairs(plan) do
        local hasExactLocation = node.x ~= nil and node.y ~= nil
        local x, y = ProjectRoutePointToOverviewMap(node.mapID, overviewMapID, node.x, node.y)
        if not x or not y then
            return nil, "A route stop could not be projected onto the shared parent map."
        end
        local sourceMapName = node.mapName or (GetMapInfo(node.mapID) or {}).name
            or ("Map " .. tostring(node.mapID))
        pins[#pins + 1] = {
            mapID = overviewMapID,
            x = x,
            y = y,
            label = string.format("%d. %s", index, node.name or "Farm stop"),
            itemName = node.name,
            spotLocation = hasExactLocation and sourceMapName
                or (sourceMapName .. " zone center; exact arrival unavailable"),
            isRoute = true,
            routeID = routeID,
            routeType = "farm-plan",
            routeOrder = index,
            routeTotal = #plan,
            mapIconType = node.isInstance and "dungeon" or nil,
            mapIconAtlas = node.isInstance and "Dungeon" or nil,
            sourceMapID = node.mapID,
            sourceMapName = sourceMapName,
            confidence = node.confidence,
            approximate = not hasExactLocation,
        }
    end

    local overviewMapInfo = GetMapInfo(overviewMapID)
    return {
        farm = farm,
        plan = plan,
        mapID = overviewMapID,
        mapName = overviewMapInfo and overviewMapInfo.name or ("Map " .. tostring(overviewMapID)),
        pins = pins,
        routeID = routeID,
        usesParentMap = tonumber(plan[1] and plan[1].mapID) ~= overviewMapID,
    }
end

function GoldTracker:OpenCustomFarmRoutePlanOverview(farmID)
    local overview, reason = self:BuildCustomFarmRoutePlanOverview(farmID)
    if not overview then
        if reason and type(self.Print) == "function" then
            self:Print(reason, "warnings")
        end
        return false
    end
    if type(self.OpenStandaloneMapWindow) ~= "function" then
        return false
    end

    local detailLines = {
        {
            type = "text",
            text = "Route plan — " .. overview.farm.name,
            r = 1.0, g = 0.82, b = 0.18,
            gap = 8,
            fontObject = "GameFontNormalLarge",
        },
        {
            type = "text",
            text = overview.usesParentMap
                and ("Shared parent map: " .. overview.mapName)
                or ("All route stops are on " .. overview.mapName),
            r = 0.72, g = 0.86, b = 1.0,
            gap = 8,
            fontObject = "GameFontHighlight",
        },
    }
    for index, node in ipairs(overview.plan) do
        local pin = overview.pins[index]
        detailLines[#detailLines + 1] = {
            type = "text",
            text = string.format(
                "%d. %s — %s%s",
                index,
                node.name or "Farm stop",
                node.mapName or "Unknown location",
                pin.approximate and " (zone center)" or ""
            ),
            r = 0.82, g = 0.86, b = 0.92,
            gap = 4,
            fontObject = "GameFontHighlightSmall",
        }
    end

    self:OpenStandaloneMapWindow({
        title = "Route Overview — " .. overview.farm.name,
        projectionKey = overview.routeID,
        mapOptions = {
            {
                id = overview.routeID,
                mapID = overview.mapID,
                mapLabel = overview.mapName,
                label = "Route overview",
                sourceType = "route-plan",
                sourceLabel = "Custom farm route plan",
                showRouteLinesWithIcons = true,
                pins = overview.pins,
            },
        },
        displayMode = "icons",
        detailLinesBuilder = function()
            return detailLines
        end,
    })
    return true
end

function GoldTracker:OpenCustomFarmRoutePlanStepMap(farmID, stepKey)
    local selected
    for _, node in ipairs(self:BuildCustomFarmRoutePlan(farmID, false)) do
        if node.key == stepKey then
            selected = node
            break
        end
    end
    if not selected then
        return false
    end

    local firstEntry = selected.entries and selected.entries[1] or nil
    if selected.catalogFarmID and type(self.BuildFarmDetailsMapOptions) == "function"
        and type(self.OpenStandaloneMapWindow) == "function" then
        local catalogFarm = GetCatalogFarmByID(selected.catalogFarmID, firstEntry)
        local mapOptions = catalogFarm and self:BuildFarmDetailsMapOptions(
            { catalogFarm },
            firstEntry and firstEntry.itemID or nil
        ) or {}
        if #mapOptions > 0 then
            local selectedIndex = 1
            local sameMapIndex
            for index, option in ipairs(mapOptions) do
                if tonumber(option.mapID) == tonumber(selected.mapID) then
                    sameMapIndex = sameMapIndex or index
                    if selected.destination and option.location == selected.destination.label then
                        selectedIndex = index
                        break
                    end
                end
            end
            if selectedIndex == 1 and sameMapIndex then
                selectedIndex = sameMapIndex
            end
            self:OpenStandaloneMapWindow({
                title = selected.name or catalogFarm.name,
                projectionKey = "route-plan:" .. tostring(farmID) .. ":" .. tostring(stepKey),
                mapOptions = mapOptions,
                selectedMapOptionIndex = selectedIndex,
                displayMode = "overlay",
            })
            return true
        end
    end

    if firstEntry and firstEntry.mapSource and type(self.OpenCustomFarmEntryMap) == "function"
        and self:OpenCustomFarmEntryMap(firstEntry) then
        return true
    end

    if selected.mapID and type(self.OpenStandaloneMapWindow) == "function" then
        local pins = {}
        if selected.x and selected.y then
            pins[1] = {
                mapID = selected.mapID,
                x = selected.x,
                y = selected.y,
                label = selected.destination and selected.destination.label or selected.name,
                isRoute = false,
            }
        end
        self:OpenStandaloneMapWindow({
            title = selected.name or "Farm map data",
            projectionKey = "route-plan:" .. tostring(farmID) .. ":" .. tostring(stepKey),
            mapOptions = {
                {
                    id = selected.destination and selected.destination.id or tostring(stepKey),
                    mapID = selected.mapID,
                    mapLabel = selected.mapName,
                    label = selected.destination and selected.destination.label or selected.mapName,
                    mapOnly = #pins == 0,
                    pins = pins,
                },
            },
            displayMode = "overlay",
        })
        return true
    end
    return false
end

function GoldTracker:NavigateCustomFarmRoutePlanStep(farmID, stepKey)
    local plan = self:BuildCustomFarmRoutePlan(farmID, false)
    local selected
    for _, node in ipairs(plan) do
        if node.key == stepKey then
            selected = node
            break
        end
    end
    if not selected then
        return false
    end
    if selected.mapID and selected.x and selected.y
        and type(C_Map) == "table" and type(C_Map.SetUserWaypoint) == "function"
        and UiMapPoint and type(UiMapPoint.CreateFromCoordinates) == "function" then
        local pointOK, point = pcall(UiMapPoint.CreateFromCoordinates, selected.mapID, selected.x, selected.y)
        if pointOK and point then
            C_Map.SetUserWaypoint(point)
            if C_SuperTrack and type(C_SuperTrack.SetSuperTrackedUserWaypoint) == "function" then
                C_SuperTrack.SetSuperTrackedUserWaypoint(true)
            end
            self:Print("Next farm stop: " .. (selected.mapName or selected.name) .. ".", "navigation")
            return true
        end
    end
    if selected.catalogFarmID and type(self.OpenFarmDetails) == "function" then
        self:Print("Exact arrival coordinates are unavailable; opening the farm map.", "warnings")
        return self:OpenFarmDetails(selected.catalogFarmID, {
            itemID = selected.entries[1] and selected.entries[1].itemID or nil,
            farmSnapshot = selected.entries[1] and selected.entries[1].catalogSnapshot,
        }) == true
    end
    if selected.mapID and type(C_Map) == "table" and type(C_Map.OpenWorldMap) == "function" then
        self:Print("Exact arrival coordinates are unavailable; opening the destination map.", "warnings")
        return pcall(C_Map.OpenWorldMap, selected.mapID)
    end
    if selected.mapID and type(OpenWorldMap) == "function" then
        self:Print("Exact arrival coordinates are unavailable; opening the destination map.", "warnings")
        return pcall(OpenWorldMap, selected.mapID)
    end
    self:Print("This farm step has no navigable location yet.", "warnings")
    return false
end
