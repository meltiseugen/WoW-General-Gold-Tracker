local _, NS = ...
local GoldTracker = NS.GoldTracker

local SCHEMA_VERSION = 4
local CONFIRM_ADD_DIALOG_KEY = "GGT_CONFIRM_ADD_TO_CUSTOM_FARM"
local CREATE_AND_ADD_DIALOG_KEY = "GGT_CREATE_CUSTOM_FARM_FOR_ITEM"

local SOURCE_LABELS = {
    alerts = "Alerts",
    drops = "Drops",
    favorites = "Favorites",
    instances = "Instances",
    inventory = "Bags",
    materials = "Materials",
    map = "Map",
    rares = "Rares",
}

local function TrimText(value)
    if type(value) ~= "string" then
        return nil
    end
    local trimmed = value:match("^%s*(.-)%s*$")
    return trimmed ~= "" and trimmed or nil
end

local function NormalizePositiveInteger(value)
    local numberValue = tonumber(value)
    if not numberValue or numberValue <= 0 then
        return nil
    end
    return math.floor(numberValue + 0.5)
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

local function Now()
    return type(time) == "function" and time() or 0
end

local function CopyStringList(values)
    local copied = {}
    local seen = {}
    for _, value in ipairs(type(values) == "table" and values or {}) do
        local normalized = TrimText(value)
        if normalized and not seen[normalized] then
            copied[#copied + 1] = normalized
            seen[normalized] = true
        end
    end
    table.sort(copied)
    return copied
end

local function GetMapSourceKey(option)
    return table.concat({ option.sourceType or "static", tostring(option.mapID),
        tostring(option.id or (option.sourceType == "user" and "discoveries") or option.label or "map") }, ":")
end

local function CopyMapSource(option)
    if type(option) ~= "table" or not NormalizePositiveInteger(option.mapID) then
        return nil
    end
    local copy = {
        id = option.id,
        mapID = NormalizePositiveInteger(option.mapID),
        label = TrimText(option.label),
        mapLabel = TrimText(option.mapLabel),
        sourceType = TrimText(option.sourceType) or "static",
        sourceLabel = TrimText(option.sourceLabel),
        pins = {},
    }
    copy.key = GetMapSourceKey(copy)
    for _, pin in ipairs(type(option.pins) == "table" and option.pins or {}) do
        local x, y = NormalizeCoordinate(pin.x), NormalizeCoordinate(pin.y)
        if x and y and NormalizePositiveInteger(pin.mapID) == copy.mapID then
            local copiedPin = {}
            for key, value in pairs(pin) do
                if type(value) == "string" or type(value) == "number" or type(value) == "boolean" then
                    copiedPin[key] = value
                end
            end
            copiedPin.x, copiedPin.y = x, y
            copiedPin.tips = CopyStringList(pin.tips)
            copiedPin.sourceUrls = CopyStringList(pin.sourceUrls)
            copy.pins[#copy.pins + 1] = copiedPin
        end
    end
    return #copy.pins > 0 and copy or nil
end

local function ClearEntryMethod(entry)
    entry.catalogFarmID = nil
    entry.catalogFarmName = nil
    entry.catalogSourcePath = nil
    entry.catalogActivity = nil
    entry.catalogMapNames = {}
    entry.mapSource = nil
    entry.entryKey = entry.originEntryKey
        or table.concat({ entry.sourceType, tostring(entry.itemID), entry.sourceKey or "item" }, ":")
    entry.originEntryKey = nil
    return entry
end

local function GetCatalogFarmByID(catalogFarmID)
    local normalizedID = TrimText(catalogFarmID)
    local catalog = NS.FarmCatalog
    if not normalizedID or type(catalog) ~= "table" then
        return nil
    end
    local position = type(catalog.byID) == "table" and tonumber(catalog.byID[normalizedID]) or nil
    return position and type(catalog.farms) == "table" and catalog.farms[position] or nil
end

local function GetCurrentCharacterLabel()
    local name
    local realm
    if type(UnitFullName) == "function" then
        name, realm = UnitFullName("player")
    end
    if not TrimText(name) and type(UnitName) == "function" then
        name = UnitName("player")
    end
    if not TrimText(realm) and type(GetRealmName) == "function" then
        realm = GetRealmName()
    end
    name = TrimText(name)
    realm = TrimText(realm)
    if not name then
        return nil
    end
    if realm then
        return name .. "-" .. realm
    end
    return name
end

local function GetFarmByIDFromStore(store, farmID)
    local normalizedID = NormalizePositiveInteger(farmID)
    if not normalizedID then
        return nil
    end
    for _, farm in ipairs(store.farms or {}) do
        if NormalizePositiveInteger(farm and farm.id) == normalizedID then
            return farm
        end
    end
    return nil
end

local function NormalizeEntry(entry, fallbackID)
    if type(entry) ~= "table" then
        return nil
    end
    local itemID = NormalizePositiveInteger(entry.itemID)
    if not itemID then
        return nil
    end
    local sourceType = TrimText(entry.sourceType) or "unknown"
    local sourceKey = TrimText(entry.sourceKey)
    local entryKey = TrimText(entry.entryKey)
        or table.concat({ sourceType, tostring(itemID), sourceKey or "item" }, ":")
    return {
        id = NormalizePositiveInteger(entry.id) or NormalizePositiveInteger(fallbackID),
        entryKey = entryKey,
        originEntryKey = TrimText(entry.originEntryKey),
        itemID = itemID,
        itemName = TrimText(entry.itemName),
        itemLink = TrimText(entry.itemLink),
        icon = tonumber(entry.icon),
        sourceType = sourceType,
        sourceLabel = TrimText(entry.sourceLabel) or SOURCE_LABELS[sourceType] or sourceType,
        sourceKey = sourceKey,
        targetName = TrimText(entry.targetName),
        locationLabel = TrimText(entry.locationLabel),
        mapID = NormalizePositiveInteger(entry.mapID),
        x = NormalizeCoordinate(entry.x),
        y = NormalizeCoordinate(entry.y),
        catalogFarmID = TrimText(entry.catalogFarmID),
        catalogFarmName = TrimText(entry.catalogFarmName),
        catalogSourcePath = TrimText(entry.catalogSourcePath),
        catalogActivity = TrimText(entry.catalogActivity),
        catalogMapNames = CopyStringList(entry.catalogMapNames),
        mapSource = CopyMapSource(entry.mapSource),
        addedAt = tonumber(entry.addedAt) or Now(),
    }
end

local function NormalizeFarm(farm, fallbackID)
    if type(farm) ~= "table" then
        return nil
    end
    local farmID = NormalizePositiveInteger(farm.id) or NormalizePositiveInteger(fallbackID)
    if not farmID then
        return nil
    end
    local entries = {}
    local entryKeys = {}
    local nextEntryID = 1
    for _, rawEntry in ipairs(type(farm.entries) == "table" and farm.entries or {}) do
        local entry = NormalizeEntry(rawEntry, nextEntryID)
        if entry and not entryKeys[entry.entryKey] then
            entry.id = NormalizePositiveInteger(entry.id) or nextEntryID
            entries[#entries + 1] = entry
            entryKeys[entry.entryKey] = true
            nextEntryID = math.max(nextEntryID, entry.id + 1)
        end
    end
    local assignedCharacter = TrimText(farm.assignedCharacter)
    if not assignedCharacter then
        assignedCharacter = CopyStringList(farm.assignedCharacters)[1]
    end
    return {
        id = farmID,
        name = TrimText(farm.name) or ("New Farm " .. tostring(farmID)),
        createdAt = tonumber(farm.createdAt) or Now(),
        updatedAt = tonumber(farm.updatedAt) or tonumber(farm.createdAt) or Now(),
        nextEntryID = math.max(nextEntryID, NormalizePositiveInteger(farm.nextEntryID) or 1),
        assignedCharacter = assignedCharacter,
        entries = entries,
        routePlan = type(farm.routePlan) == "table" and farm.routePlan or nil,
    }
end

function GoldTracker:GetCustomFarmStore()
    if type(self.db) ~= "table" then
        return nil
    end
    if type(self.db.customFarms) ~= "table" then
        self.db.customFarms = {}
    end
    local store = self.db.customFarms
    if self.customFarmsNormalizedStore == store
        and store.schemaVersion == SCHEMA_VERSION
        and type(store.knownCharacters) == "table"
        and type(store.farms) == "table" then
        if store.activeBuildFarmID and not GetFarmByIDFromStore(store, store.activeBuildFarmID) then
            store.activeBuildFarmID = nil
        end
        return store
    end
    store.schemaVersion = SCHEMA_VERSION
    store.knownCharacters = type(store.knownCharacters) == "table" and store.knownCharacters or {}
    store.farms = type(store.farms) == "table" and store.farms or {}

    local normalizedFarms = {}
    local seenIDs = {}
    local nextID = 1
    for index, rawFarm in ipairs(store.farms) do
        local farm = NormalizeFarm(rawFarm, index)
        if farm and not seenIDs[farm.id] then
            normalizedFarms[#normalizedFarms + 1] = farm
            seenIDs[farm.id] = true
            nextID = math.max(nextID, farm.id + 1)
            for _, legacyLabel in ipairs(CopyStringList(rawFarm.assignedCharacters)) do
                store.knownCharacters[legacyLabel] = true
            end
            if farm.assignedCharacter then
                store.knownCharacters[farm.assignedCharacter] = true
            end
        end
    end
    store.farms = normalizedFarms
    store.nextID = math.max(nextID, NormalizePositiveInteger(store.nextID) or 1)
    store.activeBuildFarmID = NormalizePositiveInteger(store.activeBuildFarmID)
    if store.activeBuildFarmID and not GetFarmByIDFromStore(store, store.activeBuildFarmID) then
        store.activeBuildFarmID = nil
    end
    self.customFarmsNormalizedStore = store
    return store
end

function GoldTracker:RegisterCurrentCustomFarmCharacter()
    local store = self:GetCustomFarmStore()
    local label = GetCurrentCharacterLabel()
    if store and label then
        store.knownCharacters[label] = true
    end
    return label
end

function GoldTracker:GetKnownCustomFarmCharacters()
    local store = self:GetCustomFarmStore()
    if not store then
        return {}
    end
    self:RegisterCurrentCustomFarmCharacter()
    for _, session in ipairs(type(self.db.sessionHistory) == "table" and self.db.sessionHistory or {}) do
        for _, label in ipairs(type(session.savedByCharacters) == "table" and session.savedByCharacters or {}) do
            label = TrimText(label)
            if label then
                store.knownCharacters[label] = true
            end
        end
        local label = TrimText(session.savedBy)
        if label then
            store.knownCharacters[label] = true
        end
    end
    local characters = {}
    for label, known in pairs(store.knownCharacters) do
        if known == true and TrimText(label) then
            characters[#characters + 1] = label
        end
    end
    table.sort(characters)
    return characters
end

function GoldTracker:GetCustomFarms()
    local store = self:GetCustomFarmStore()
    return store and store.farms or {}
end

function GoldTracker:GetCustomFarmByID(farmID)
    local store = self:GetCustomFarmStore()
    return store and GetFarmByIDFromStore(store, farmID) or nil
end

function GoldTracker:GetActiveCustomFarm()
    local store = self:GetCustomFarmStore()
    if not store then
        return nil
    end
    return GetFarmByIDFromStore(store, store.activeBuildFarmID)
end

function GoldTracker:GetSuggestedCustomFarmName()
    local store = self:GetCustomFarmStore()
    return "New Farm " .. tostring(store and store.nextID or 1)
end

function GoldTracker:NotifyCustomFarmsChanged()
    if self.myFarmsFrame and type(self.RefreshMyFarmsWindow) == "function" then
        self:RefreshMyFarmsWindow()
    end
    if self.farmRoutePlanFrame and type(self.RefreshFarmRoutePlanWindow) == "function" then
        self:RefreshFarmRoutePlanWindow()
    end
end

function GoldTracker:CreateCustomFarm(name, activateBuild)
    local store = self:GetCustomFarmStore()
    if not store then
        return nil
    end
    local farmID = store.nextID
    store.nextID = farmID + 1
    local timestamp = Now()
    local farm = {
        id = farmID,
        name = TrimText(name) or ("New Farm " .. tostring(farmID)),
        createdAt = timestamp,
        updatedAt = timestamp,
        nextEntryID = 1,
        assignedCharacter = nil,
        entries = {},
    }
    store.farms[#store.farms + 1] = farm
    if activateBuild == true then
        store.activeBuildFarmID = farmID
        if self.myFarmsFrame then
            self.myFarmsFrame.selectedFarmID = farmID
        end
    end
    self:NotifyCustomFarmsChanged()
    return farm
end

function GoldTracker:RenameCustomFarm(farmID, name)
    local farm = self:GetCustomFarmByID(farmID)
    local normalizedName = TrimText(name)
    if not farm or not normalizedName then
        return false
    end
    farm.name = normalizedName
    farm.updatedAt = Now()
    self:NotifyCustomFarmsChanged()
    return true
end

function GoldTracker:DeleteCustomFarm(farmID)
    local store = self:GetCustomFarmStore()
    local normalizedID = NormalizePositiveInteger(farmID)
    if not store or not normalizedID then
        return false
    end
    for index, farm in ipairs(store.farms) do
        if farm.id == normalizedID then
            table.remove(store.farms, index)
            if store.activeBuildFarmID == normalizedID then
                store.activeBuildFarmID = nil
            end
            self:NotifyCustomFarmsChanged()
            return true
        end
    end
    return false
end

function GoldTracker:SetActiveCustomFarm(farmID)
    local store = self:GetCustomFarmStore()
    local farm = store and GetFarmByIDFromStore(store, farmID) or nil
    if not farm then
        return false
    end
    store.activeBuildFarmID = farm.id
    farm.updatedAt = Now()
    self:NotifyCustomFarmsChanged()
    return true
end

function GoldTracker:FinishCustomFarmBuild(farmID)
    local store = self:GetCustomFarmStore()
    local normalizedID = NormalizePositiveInteger(farmID)
    if not store or store.activeBuildFarmID ~= normalizedID then
        return false
    end
    store.activeBuildFarmID = nil
    self:NotifyCustomFarmsChanged()
    return true
end

function GoldTracker:SetCustomFarmAssignedCharacter(farmID, characterLabel)
    local farm = self:GetCustomFarmByID(farmID)
    local label = TrimText(characterLabel)
    if not farm then
        return false
    end
    if farm.assignedCharacter == label then
        return true
    end
    farm.assignedCharacter = label
    local store = self:GetCustomFarmStore()
    if label then
        store.knownCharacters[label] = true
    end
    farm.updatedAt = Now()
    self:NotifyCustomFarmsChanged()
    return true
end

function GoldTracker:BuildCustomFarmEntry(row, sourceType)
    if type(row) ~= "table" then
        return nil
    end
    local itemID = NormalizePositiveInteger(row.itemID or row.id)
    if not itemID then
        return nil
    end
    sourceType = TrimText(sourceType) or TrimText(row.farmingSourceType) or "unknown"
    local sourceKey = TrimText(row.providerKey)
        or TrimText(row.recordID)
        or tostring(NormalizePositiveInteger(row.npcID or row.bossEncounterJournalID or row.instanceEncounterJournalID or row.mapID) or "item")
    if sourceKey == "item" then
        sourceKey = TrimText(row.favoriteKey) or sourceKey
    end
    local itemName = TrimText(row.itemName)
    if not itemName and type(GetItemInfo) == "function" then
        itemName = GetItemInfo(itemID)
    end
    local locationLabel = TrimText(row.locationLabel)
        or TrimText(row.locationName)
        or TrimText(row.instanceName)
        or TrimText(row.mapName)
    local targetName = TrimText(row.rareName)
        or TrimText(row.bossName)
        or TrimText(row.sourceName)
        or TrimText(row.npcName)
    local firstLocation = type(row.locations) == "table" and row.locations[1] or nil
    local mapID = NormalizePositiveInteger(row.mapID or row.uiMapID or row.locationMapID or row.instanceMapID or (firstLocation and firstLocation.mapID))
    local x = NormalizeCoordinate(row.x or row.coordX or (firstLocation and firstLocation.x))
    local y = NormalizeCoordinate(row.y or row.coordY or (firstLocation and firstLocation.y))
    return NormalizeEntry({
        entryKey = table.concat({ sourceType, tostring(itemID), sourceKey }, ":"),
        itemID = itemID,
        itemName = itemName,
        itemLink = row.itemLink,
        icon = row.iconTexture or (type(row.icon) == "number" and row.icon or nil),
        sourceType = sourceType,
        sourceLabel = SOURCE_LABELS[sourceType] or sourceType,
        sourceKey = sourceKey,
        targetName = targetName,
        locationLabel = locationLabel,
        mapID = mapID,
        x = x,
        y = y,
        addedAt = Now(),
    })
end

function GoldTracker:LinkCustomFarmEntryToCatalogFarm(entry, catalogFarmID)
    entry = NormalizeEntry(entry)
    local catalogFarm = GetCatalogFarmByID(catalogFarmID)
    if not entry or not catalogFarm then
        return nil
    end
    ClearEntryMethod(entry)
    entry.catalogFarmID = catalogFarm.id
    entry.catalogFarmName = TrimText(catalogFarm.name) or catalogFarm.id
    entry.catalogSourcePath = TrimText(catalogFarm.sourcePath)
    entry.catalogActivity = TrimText(catalogFarm.activity) or TrimText(catalogFarm.sourceType)
    entry.catalogMapNames = CopyStringList(catalogFarm.mapNames)
    entry.originEntryKey = entry.originEntryKey or entry.entryKey
    entry.entryKey = table.concat({ "catalog", catalogFarm.id, tostring(entry.itemID) }, ":")
    return entry
end

function GoldTracker:GetCustomFarmMapOptions(itemID)
    return type(self.BuildMaterialFarmingMapOptions) == "function" and self:BuildMaterialFarmingMapOptions(itemID) or {}
end

function GoldTracker:GetCustomFarmMapSourceKey(option)
    return GetMapSourceKey(option)
end

function GoldTracker:ResolveCustomFarmEntryMapOption(entry)
    local saved = entry and entry.mapSource
    if not saved then
        return nil
    end
    for _, option in ipairs(self:GetCustomFarmMapOptions(entry.itemID)) do
        if GetMapSourceKey(option) == saved.key then
            return option
        end
    end
    return saved
end

function GoldTracker:LinkCustomFarmEntryToMapSource(entry, option)
    entry = NormalizeEntry(entry)
    local mapSource = CopyMapSource(option)
    if not entry or not mapSource then
        return nil
    end
    ClearEntryMethod(entry)
    entry.originEntryKey = entry.entryKey
    entry.mapSource = mapSource
    entry.entryKey = table.concat({ "map", tostring(entry.itemID), mapSource.key }, ":")
    return entry
end

function GoldTracker:OpenCustomFarmEntryMap(entry)
    local option = self:ResolveCustomFarmEntryMapOption(entry)
    if not option or type(self.OpenStandaloneMapWindow) ~= "function" then
        return false
    end
    self:OpenStandaloneMapWindow({
        title = entry.itemName or ("Item " .. tostring(entry.itemID)),
        projectionKey = entry.entryKey,
        mapOptions = { option },
        customFarmRow = { itemID = entry.itemID, itemName = entry.itemName, itemLink = entry.itemLink },
        customFarmSourceType = entry.sourceType,
        displayMode = "overlay",
    })
    return true
end

function GoldTracker:SetCustomFarmEntryMethod(farmID, entryID, catalogFarmID, mapOption)
    local farm = self:GetCustomFarmByID(farmID)
    local normalizedEntryID = NormalizePositiveInteger(entryID)
    if not farm or not normalizedEntryID then
        return false, "invalid"
    end
    for index, existing in ipairs(farm.entries or {}) do
        if existing.id == normalizedEntryID then
            local candidate = NormalizeEntry(existing)
            ClearEntryMethod(candidate)
            if mapOption then
                candidate = self:LinkCustomFarmEntryToMapSource(candidate, mapOption)
                if not candidate then
                    return false, "invalid-map"
                end
            elseif catalogFarmID then
                candidate = self:LinkCustomFarmEntryToCatalogFarm(candidate, catalogFarmID)
                if not candidate then
                    return false, "invalid-farm"
                end
            end
            for otherIndex, other in ipairs(farm.entries or {}) do
                if otherIndex ~= index and other.entryKey == candidate.entryKey then
                    return false, "duplicate"
                end
            end
            candidate.id = existing.id
            farm.entries[index] = candidate
            farm.updatedAt = Now()
            self:NotifyCustomFarmsChanged()
            return true, candidate
        end
    end
    return false, "missing"
end

function GoldTracker:SetCustomFarmEntryCatalogFarm(farmID, entryID, catalogFarmID)
    return self:SetCustomFarmEntryMethod(farmID, entryID, catalogFarmID)
end

function GoldTracker:GetCustomFarmSteps(farmID)
    local farm = type(farmID) == "table" and farmID or self:GetCustomFarmByID(farmID)
    local steps = {}
    local catalogSteps = {}
    if not farm then
        return steps
    end
    for _, entry in ipairs(farm.entries or {}) do
        local step
        if entry.catalogFarmID then
            step = catalogSteps[entry.catalogFarmID]
            if not step then
                local catalogFarm = GetCatalogFarmByID(entry.catalogFarmID)
                step = {
                    key = "catalog:" .. entry.catalogFarmID,
                    catalogFarmID = entry.catalogFarmID,
                    name = catalogFarm and catalogFarm.name or entry.catalogFarmName or entry.catalogFarmID,
                    sourcePath = catalogFarm and catalogFarm.sourcePath or entry.catalogSourcePath,
                    activity = catalogFarm and (catalogFarm.activity or catalogFarm.sourceType) or entry.catalogActivity,
                    mapNames = CopyStringList(catalogFarm and catalogFarm.mapNames or entry.catalogMapNames),
                    mapIDs = catalogFarm and catalogFarm.mapIDs or nil,
                    routeCount = catalogFarm and tonumber(catalogFarm.routeCount) or 0,
                    entries = {},
                }
                catalogSteps[entry.catalogFarmID] = step
                steps[#steps + 1] = step
            end
        else
            step = {
                key = "item:" .. tostring(entry.id or entry.entryKey),
                name = entry.itemName or ("Item " .. tostring(entry.itemID)),
                sourcePath = entry.mapSource and ("Map data | " .. (entry.mapSource.sourceLabel or entry.mapSource.sourceType)) or entry.sourceLabel,
                mapNames = entry.mapSource and { entry.mapSource.label or ("Map " .. tostring(entry.mapSource.mapID)) }
                    or (entry.locationLabel and { entry.locationLabel } or {}),
                entries = {},
            }
            steps[#steps + 1] = step
        end
        step.entries[#step.entries + 1] = entry
    end
    return steps
end

function GoldTracker:AddEntryToCustomFarm(farmID, entry)
    local farm = self:GetCustomFarmByID(farmID)
    entry = NormalizeEntry(entry)
    if not farm or not entry then
        return false, "invalid"
    end
    for _, existing in ipairs(farm.entries or {}) do
        if existing.entryKey == entry.entryKey then
            return false, "duplicate"
        end
    end
    entry.id = farm.nextEntryID
    farm.nextEntryID = farm.nextEntryID + 1
    farm.entries[#farm.entries + 1] = entry
    farm.updatedAt = Now()
    self:NotifyCustomFarmsChanged()
    return true, entry
end

function GoldTracker:RemoveEntryFromCustomFarm(farmID, entryID)
    local farm = self:GetCustomFarmByID(farmID)
    local normalizedEntryID = NormalizePositiveInteger(entryID)
    if not farm or not normalizedEntryID then
        return false
    end
    for index, entry in ipairs(farm.entries or {}) do
        if entry.id == normalizedEntryID then
            table.remove(farm.entries, index)
            farm.updatedAt = Now()
            self:NotifyCustomFarmsChanged()
            return true
        end
    end
    return false
end

local function AddConfirmedEntry(payload)
    if type(payload) ~= "table" then
        return false, "invalid"
    end
    local added, reason = GoldTracker:AddEntryToCustomFarm(payload.farmID, payload.entry)
    local farm = GoldTracker:GetCustomFarmByID(payload.farmID)
    if added then
        GoldTracker:Print(string.format("Added %s to %s.", payload.entry.itemName or ("Item " .. payload.entry.itemID), farm and farm.name or "custom farm"))
    elseif reason == "duplicate" then
        GoldTracker:Print("That entry is already in this farm.")
    end
    return added, reason
end

function GoldTracker:CommitCustomFarmEntry(payload, catalogFarmID, mapOption)
    if type(payload) ~= "table" or type(payload.entry) ~= "table" then
        return false, "invalid"
    end
    local entry = NormalizeEntry(payload.entry)
    if not entry then
        return false, "invalid"
    end
    ClearEntryMethod(entry)
    if mapOption then
        entry = self:LinkCustomFarmEntryToMapSource(entry, mapOption)
        if not entry then
            return false, "invalid-map"
        end
    elseif catalogFarmID then
        entry = self:LinkCustomFarmEntryToCatalogFarm(entry, catalogFarmID)
        if not entry then
            return false, "invalid-farm"
        end
    end
    local farmID = payload.farmID
    if not farmID then
        local farm = self:CreateCustomFarm(nil, true)
        farmID = farm and farm.id or nil
    end
    if not farmID then
        return false, "invalid"
    end
    local committedPayload = { farmID = farmID, entry = entry }
    local added, reason = AddConfirmedEntry(committedPayload)
    return added, added and entry or reason
end

local function EnsureCustomFarmDialogs()
    if type(StaticPopupDialogs) ~= "table" then
        return false
    end
    if not StaticPopupDialogs[CONFIRM_ADD_DIALOG_KEY] then
        StaticPopupDialogs[CONFIRM_ADD_DIALOG_KEY] = {
            text = "Add %s to |cffffd24a%s|r?",
            button1 = "Add",
            button2 = "Cancel",
            timeout = 0,
            whileDead = true,
            hideOnEscape = true,
            preferredIndex = 3,
            OnAccept = function(dialog)
                AddConfirmedEntry(dialog.data)
            end,
        }
    end
    if not StaticPopupDialogs[CREATE_AND_ADD_DIALOG_KEY] then
        StaticPopupDialogs[CREATE_AND_ADD_DIALOG_KEY] = {
            text = "No farm is currently being built.\nCreate a new farm and add %s?",
            button1 = "Create",
            button2 = "Cancel",
            timeout = 0,
            whileDead = true,
            hideOnEscape = true,
            preferredIndex = 3,
            OnAccept = function(dialog)
                local payload = dialog.data
                if type(payload) ~= "table" then
                    return
                end
                local farm = GoldTracker:CreateCustomFarm(nil, true)
                if farm then
                    payload.farmID = farm.id
                    AddConfirmedEntry(payload)
                end
            end,
        }
    end
    return true
end

function GoldTracker:RequestAddToCustomFarm(row, sourceType, mapOption)
    local entry = self:BuildCustomFarmEntry(row, sourceType)
    if not entry then
        self:Print("This row cannot be added to a custom farm.")
        return false
    end
    if mapOption then
        entry = self:LinkCustomFarmEntryToMapSource(entry, mapOption)
        if not entry then
            return false
        end
    end
    local activeFarm = self:GetActiveCustomFarm()
    local matchingFarms = type(self.GetFarmsForItem) == "function" and self:GetFarmsForItem(entry.itemID) or {}
    local mapOptions = self:GetCustomFarmMapOptions(entry.itemID)
    if (entry.mapSource or #matchingFarms > 0 or #mapOptions > 0) and type(self.ShowCustomFarmMethodDialog) == "function" then
        return self:ShowCustomFarmMethodDialog({
            farmID = activeFarm and activeFarm.id or nil,
            entry = entry,
            farms = matchingFarms,
            mapOptions = mapOptions,
        })
    end
    if not EnsureCustomFarmDialogs() or type(StaticPopup_Show) ~= "function" then
        return false
    end
    if activeFarm then
        StaticPopup_Show(
            CONFIRM_ADD_DIALOG_KEY,
            entry.itemName or ("Item " .. tostring(entry.itemID)),
            activeFarm.name,
            { farmID = activeFarm.id, entry = entry }
        )
    else
        StaticPopup_Show(
            CREATE_AND_ADD_DIALOG_KEY,
            entry.itemName or ("Item " .. tostring(entry.itemID)),
            nil,
            { entry = entry }
        )
    end
    return true
end

function GoldTracker:GetCustomFarmAddButtonTooltip(itemID)
    local activeFarm = self:GetActiveCustomFarm()
    local methodText = " Choose from available farm data or map data before adding."
    if activeFarm then
        return "Add to custom farm", "You will be asked to confirm adding this entry to " .. activeFarm.name .. "." .. methodText
    end
    return "Add to custom farm", "No farm is being built. You will be asked whether to create one." .. methodText
end

function GoldTracker:ConfigureCustomFarmAddButton(button, sourceType)
    if not button or type(button.SetScript) ~= "function" then
        return button
    end
    button.customFarmSourceType = sourceType
    if type(button.RegisterForClicks) == "function" then
        button:RegisterForClicks("LeftButtonUp")
    end
    button:SetScript("OnClick", function(self)
        local row = self:GetParent()
        GoldTracker:RequestAddToCustomFarm(row, self.customFarmSourceType or row.farmingSourceType)
    end)
    button:SetScript("OnEnter", function(self)
        if not GameTooltip then
            return
        end
        local row = self:GetParent()
        local title, detail = GoldTracker:GetCustomFarmAddButtonTooltip(row and (row.itemID or row.id))
        GameTooltip:SetOwner(self, "ANCHOR_CURSOR")
        GameTooltip:AddLine(title, 1, 1, 1)
        GameTooltip:AddLine(detail, 0.72, 0.86, 1.0, true)
        GameTooltip:Show()
    end)
    button:SetScript("OnLeave", function()
        if GameTooltip then
            GameTooltip:Hide()
        end
    end)
    return button
end

GoldTracker.CUSTOM_FARM_SOURCE_LABELS = SOURCE_LABELS
GoldTracker.CUSTOM_FARM_CONFIRM_ADD_DIALOG_KEY = CONFIRM_ADD_DIALOG_KEY
GoldTracker.CUSTOM_FARM_CREATE_AND_ADD_DIALOG_KEY = CREATE_AND_ADD_DIALOG_KEY
