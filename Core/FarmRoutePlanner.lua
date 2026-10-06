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

local function GetCatalogFarmByID(farmID)
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
    if type(addon.ResolveCatalogFarmInstanceEntrance) == "function" then
        instanceEntrance = addon:ResolveCatalogFarmInstanceEntrance(catalogFarm)
        if instanceEntrance then
            candidates[#candidates + 1] = instanceEntrance
            seen[instanceEntrance.id] = true
        end
    end
    local records = type(NS.WITGatheringData) == "table" and NS.WITGatheringData.farmsByRecordID or nil
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

local function BuildPlanNodes(addon, farm, playerLocation)
    local state = GetPlanState(farm)
    local nodes = {}
    for originalIndex, step in ipairs(addon:GetCustomFarmSteps(farm)) do
        local catalogFarm = step.catalogFarmID and GetCatalogFarmByID(step.catalogFarmID) or nil
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

function GoldTracker:BuildCustomFarmRoutePlan(farmID, recalculate)
    local farm = self:GetCustomFarmByID(farmID)
    if not farm then
        return {}
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
    return ordered
end

function GoldTracker:NotifyFarmRoutePlanChanged()
    if self.farmRoutePlanFrame and type(self.RefreshFarmRoutePlanWindow) == "function" then
        self:RefreshFarmRoutePlanWindow()
    end
    if self.myFarmsFrame and type(self.RefreshMyFarmsWindow) == "function" then
        self:RefreshMyFarmsWindow()
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
    local run = GetCharacterRunState(self, farm, true)
    run.startedAt = type(time) == "function" and time() or 0
    run.currentStepKey = plan[1] and plan[1].key or nil
    self:NotifyFarmRoutePlanChanged()
    return #plan > 0
end

function GoldTracker:ResetCustomFarmRoutePlanRun(farmID)
    local farm = self:GetCustomFarmByID(farmID)
    if not farm then
        return false
    end
    GetCharacterRunState(self, farm, true)
    self:NotifyFarmRoutePlanChanged()
    return true
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
    local run = GetCharacterRunState(self, farm, false)
    run.completed[stepKey] = complete == true or nil
    if complete == true and run.currentStepKey == stepKey then
        run.currentStepKey = FindNextIncomplete(plan, run, stepKey, false)
    elseif complete ~= true then
        run.currentStepKey = stepKey
    end
    self:NotifyFarmRoutePlanChanged()
    return true
end

function GoldTracker:SkipCustomFarmRoutePlanStep(farmID)
    local farm = self:GetCustomFarmByID(farmID)
    if not farm then
        return false
    end
    local plan = self:BuildCustomFarmRoutePlan(farmID, false)
    local run = GetCharacterRunState(self, farm, false)
    run.currentStepKey = FindNextIncomplete(plan, run, run.currentStepKey, true)
    self:NotifyFarmRoutePlanChanged()
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
    local run = GetCharacterRunState(self, farm, false)
    run.currentStepKey = stepKey
    self:NotifyFarmRoutePlanChanged()
    return true
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
            self:Print("Next farm stop: " .. (selected.mapName or selected.name) .. ".")
            return true
        end
    end
    if selected.catalogFarmID and type(self.OpenFarmDetails) == "function" then
        self:Print("Exact arrival coordinates are unavailable; opening the farm map.")
        return self:OpenFarmDetails(selected.catalogFarmID, {
            itemID = selected.entries[1] and selected.entries[1].itemID or nil,
        }) == true
    end
    if selected.mapID and type(C_Map) == "table" and type(C_Map.OpenWorldMap) == "function" then
        self:Print("Exact arrival coordinates are unavailable; opening the destination map.")
        return pcall(C_Map.OpenWorldMap, selected.mapID)
    end
    if selected.mapID and type(OpenWorldMap) == "function" then
        self:Print("Exact arrival coordinates are unavailable; opening the destination map.")
        return pcall(OpenWorldMap, selected.mapID)
    end
    self:Print("This farm step has no navigable location yet.")
    return false
end
