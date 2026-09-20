local _, NS = ...
local GoldTracker = NS.GoldTracker

local USER_PIN_SCHEMA_VERSION = 1
local USER_PIN_BUCKET_SIZE = 0.005
local MAX_USER_PINS_PER_ITEM = 200

local function NormalizeItemID(value)
    local itemID = tonumber(value)
    if not itemID or itemID <= 0 then
        return nil
    end
    return math.floor(itemID + 0.5)
end

local function NormalizeCoordinate(value)
    local coordinate = tonumber(value)
    if not coordinate then
        return nil
    end
    if coordinate > 1 then
        coordinate = coordinate / 100
    end
    if coordinate < 0 or coordinate > 1 then
        return nil
    end
    return coordinate
end

local function GetItemNameFromLink(itemLink)
    if type(itemLink) ~= "string" then
        return nil
    end
    return itemLink:match("|h%[([^%]]+)%]|h")
end

local function BuildPinKey(mapID, x, y)
    local bucketX = math.floor((x / USER_PIN_BUCKET_SIZE) + 0.5)
    local bucketY = math.floor((y / USER_PIN_BUCKET_SIZE) + 0.5)
    return table.concat({ tostring(mapID), tostring(bucketX), tostring(bucketY) }, ":")
end

local function SortPinsByLastSeenAscending(left, right)
    return (tonumber(left and left.lastSeenAt) or 0) < (tonumber(right and right.lastSeenAt) or 0)
end

local function GetStoreItemCount(itemEntry)
    local count = 0
    for _, mapEntry in pairs(itemEntry and itemEntry.maps or {}) do
        for _ in pairs(mapEntry and mapEntry.pins or {}) do
            count = count + 1
        end
    end
    return count
end

local function PruneItemPins(itemEntry)
    local pinCount = GetStoreItemCount(itemEntry)
    if pinCount <= MAX_USER_PINS_PER_ITEM then
        return
    end

    local pins = {}
    for mapKey, mapEntry in pairs(itemEntry.maps or {}) do
        for pinKey, pin in pairs(mapEntry.pins or {}) do
            pins[#pins + 1] = {
                mapKey = mapKey,
                pinKey = pinKey,
                lastSeenAt = tonumber(pin and pin.lastSeenAt) or 0,
            }
        end
    end
    table.sort(pins, SortPinsByLastSeenAscending)

    for index = 1, pinCount - MAX_USER_PINS_PER_ITEM do
        local stale = pins[index]
        local mapEntry = stale and itemEntry.maps and itemEntry.maps[stale.mapKey]
        if mapEntry and mapEntry.pins then
            mapEntry.pins[stale.pinKey] = nil
        end
    end
end

local function IsKnownMaterialItem(addon, itemID)
    local normalizedItemID = NormalizeItemID(itemID)
    if not normalizedItemID then
        return false
    end

    local data = NS and NS.FarmingItems
    local items = type(data) == "table" and type(data.items) == "table" and data.items or {}
    for _, item in ipairs(items) do
        if NormalizeItemID(item and item.itemID) == normalizedItemID then
            return true
        end
    end

    if addon and type(addon.GetCraftingFarmingCustomItems) == "function" then
        local customItems = addon:GetCraftingFarmingCustomItems()
        customItems = type(customItems) == "table" and customItems or {}
        for _, item in ipairs(customItems) do
            if NormalizeItemID(item and item.itemID) == normalizedItemID then
                return true
            end
        end
    end

    return false
end

function GoldTracker:NormalizeUserMaterialFarmingPinStore()
    if type(self.db) ~= "table" then
        return { schemaVersion = USER_PIN_SCHEMA_VERSION, items = {} }
    end

    if type(self.db.userMaterialFarmingPins) ~= "table" then
        self.db.userMaterialFarmingPins = {}
    end
    local store = self.db.userMaterialFarmingPins
    store.schemaVersion = USER_PIN_SCHEMA_VERSION
    if type(store.items) ~= "table" then
        store.items = {}
    end

    for rawItemKey, itemEntry in pairs(store.items) do
        local itemID = NormalizeItemID(itemEntry and itemEntry.itemID) or NormalizeItemID(rawItemKey)
        if not itemID or type(itemEntry) ~= "table" then
            store.items[rawItemKey] = nil
        else
            local itemKey = tostring(itemID)
            if rawItemKey ~= itemKey then
                store.items[rawItemKey] = nil
                store.items[itemKey] = itemEntry
            end
            itemEntry.itemID = itemID
            if type(itemEntry.maps) ~= "table" then
                itemEntry.maps = {}
            end
            for rawMapKey, mapEntry in pairs(itemEntry.maps) do
                local mapID = tonumber(mapEntry and mapEntry.mapID) or tonumber(rawMapKey)
                if not mapID or type(mapEntry) ~= "table" or type(mapEntry.pins) ~= "table" then
                    itemEntry.maps[rawMapKey] = nil
                else
                    local mapKey = tostring(math.floor(mapID + 0.5))
                    if rawMapKey ~= mapKey then
                        itemEntry.maps[rawMapKey] = nil
                        itemEntry.maps[mapKey] = mapEntry
                    end
                    mapEntry.mapID = math.floor(mapID + 0.5)
                    for pinKey, pin in pairs(mapEntry.pins) do
                        local x = NormalizeCoordinate(pin and pin.x)
                        local y = NormalizeCoordinate(pin and pin.y)
                        if not x or not y or type(pin) ~= "table" then
                            mapEntry.pins[pinKey] = nil
                        else
                            pin.x = x
                            pin.y = y
                            pin.seenCount = math.max(1, math.floor((tonumber(pin.seenCount) or 1) + 0.5))
                            pin.totalQuantity = math.max(1, math.floor((tonumber(pin.totalQuantity) or 1) + 0.5))
                        end
                    end
                end
            end
        end
    end

    return store
end

function GoldTracker:GetUserMaterialFarmingPinStore()
    return self:NormalizeUserMaterialFarmingPinStore()
end

function GoldTracker:ShouldRecordUserMaterialFarmingPin(
    itemLink,
    itemMetadata,
    isCraftingReagent,
    _lootSourceInfo,
    locationData
)
    if locationData and locationData.isInstanced == true then
        return false
    end

    local itemID = NormalizeItemID(itemMetadata and itemMetadata.itemID)
    if not itemID and type(self.GetItemIDFromLink) == "function" then
        itemID = NormalizeItemID(self:GetItemIDFromLink(itemLink))
    end
    if not itemID then
        return false
    end

    if isCraftingReagent ~= true and not IsKnownMaterialItem(self, itemID) then
        return false
    end

    local mapID = tonumber(locationData and locationData.mapID)
    local x = NormalizeCoordinate(locationData and locationData.mapX)
    local y = NormalizeCoordinate(locationData and locationData.mapY)
    return mapID ~= nil and mapID > 0 and x ~= nil and y ~= nil
end

function GoldTracker:RecordUserMaterialFarmingPin(
    itemID,
    itemLink,
    quantity,
    lootSourceInfo,
    locationData,
    itemMetadata
)
    local normalizedItemID = NormalizeItemID(itemID)
    local mapID = tonumber(locationData and locationData.mapID)
    local x = NormalizeCoordinate(locationData and locationData.mapX)
    local y = NormalizeCoordinate(locationData and locationData.mapY)
    if not normalizedItemID or not mapID or mapID <= 0 or not x or not y then
        return false
    end
    mapID = math.floor(mapID + 0.5)

    local store = self:GetUserMaterialFarmingPinStore()
    local itemKey = tostring(normalizedItemID)
    local itemEntry = store.items[itemKey]
    local now = type(_G.time) == "function" and _G.time() or 0
    if type(itemEntry) ~= "table" then
        itemEntry = {
            itemID = normalizedItemID,
            itemLink = itemLink,
            itemName = GetItemNameFromLink(itemLink),
            firstSeenAt = now,
            lastSeenAt = now,
            totalQuantity = 0,
            seenCount = 0,
            maps = {},
        }
        store.items[itemKey] = itemEntry
    end

    itemEntry.itemLink = itemLink or itemEntry.itemLink
    itemEntry.itemName = GetItemNameFromLink(itemLink) or itemEntry.itemName
    itemEntry.lastSeenAt = now
    itemEntry.totalQuantity = math.max(0, tonumber(itemEntry.totalQuantity) or 0)
        + math.max(1, math.floor(tonumber(quantity) or 1))
    itemEntry.seenCount = math.max(0, tonumber(itemEntry.seenCount) or 0) + 1
    if type(itemEntry.maps) ~= "table" then
        itemEntry.maps = {}
    end

    local mapKey = tostring(mapID)
    local mapEntry = itemEntry.maps[mapKey]
    if type(mapEntry) ~= "table" then
        mapEntry = {
            mapID = mapID,
            mapName = locationData and locationData.mapName,
            pins = {},
        }
        itemEntry.maps[mapKey] = mapEntry
    end
    mapEntry.mapName = (locationData and locationData.mapName) or mapEntry.mapName
    if type(mapEntry.pins) ~= "table" then
        mapEntry.pins = {}
    end

    local pinKey = BuildPinKey(mapID, x, y)
    local pin = mapEntry.pins[pinKey]
    local normalizedQuantity = math.max(1, math.floor(tonumber(quantity) or 1))
    if type(pin) ~= "table" then
        pin = {
            mapID = mapID,
            x = x,
            y = y,
            firstSeenAt = now,
            seenCount = 0,
            totalQuantity = 0,
        }
        mapEntry.pins[pinKey] = pin
    end

    pin.x = x
    pin.y = y
    pin.lastSeenAt = now
    pin.seenCount = math.max(0, tonumber(pin.seenCount) or 0) + 1
    pin.totalQuantity = math.max(0, tonumber(pin.totalQuantity) or 0) + normalizedQuantity
    pin.sourceType = "user"
    pin.sourceKind = lootSourceInfo and lootSourceInfo.kind or pin.sourceKind
    pin.sourceName = lootSourceInfo and lootSourceInfo.name or pin.sourceName
    pin.sourceText = lootSourceInfo and lootSourceInfo.text or pin.sourceText
    pin.itemName = itemEntry.itemName or (itemMetadata and itemMetadata.itemName)

    PruneItemPins(itemEntry)
    return true, pin
end

function GoldTracker:RecordUserMaterialFarmingPinForLoot(
    itemLink,
    quantity,
    itemMetadata,
    isCraftingReagent,
    lootSourceInfo,
    locationData
)
    local function IncrementCounter(key)
        if type(self.IncrementDiagnosticCounter) == "function" then
            self:IncrementDiagnosticCounter(key)
        end
    end

    if not self:ShouldRecordUserMaterialFarmingPin(
        itemLink,
        itemMetadata,
        isCraftingReagent,
        lootSourceInfo,
        locationData
    ) then
        local itemID = NormalizeItemID(itemMetadata and itemMetadata.itemID)
        if not itemID and type(self.GetItemIDFromLink) == "function" then
            itemID = NormalizeItemID(self:GetItemIDFromLink(itemLink))
        end
        local isMaterialCandidate = itemID
            and (isCraftingReagent == true or IsKnownMaterialItem(self, itemID))
        local isWorldSourceCandidate = not (locationData and locationData.isInstanced == true)
        local mapID = tonumber(locationData and locationData.mapID)
        local x = NormalizeCoordinate(locationData and locationData.mapX)
        local y = NormalizeCoordinate(locationData and locationData.mapY)
        if isMaterialCandidate
            and isWorldSourceCandidate
            and mapID
            and mapID > 0
            and (x == nil or y == nil) then
            IncrementCounter("material_pin_missing_coordinates")
        else
            IncrementCounter("material_pin_rejected")
        end
        return false
    end

    local itemID = NormalizeItemID(itemMetadata and itemMetadata.itemID)
    if not itemID and type(self.GetItemIDFromLink) == "function" then
        itemID = NormalizeItemID(self:GetItemIDFromLink(itemLink))
    end
    local recorded, pin = self:RecordUserMaterialFarmingPin(
        itemID,
        itemLink,
        quantity,
        lootSourceInfo,
        locationData,
        itemMetadata
    )
    IncrementCounter(recorded and "material_pin_recorded" or "material_pin_rejected")
    return recorded, pin
end

function GoldTracker:GetUserMaterialFarmingPinsForItem(itemID)
    local normalizedItemID = NormalizeItemID(itemID)
    if not normalizedItemID then
        return {}
    end

    local store = self:GetUserMaterialFarmingPinStore()
    local itemEntry = store.items[tostring(normalizedItemID)]
    return type(itemEntry) == "table" and itemEntry or {}
end

function GoldTracker:BuildUserMaterialFarmingMapOptions(itemID, fallbackItemName)
    local itemEntry = self:GetUserMaterialFarmingPinsForItem(itemID)
    if type(itemEntry.maps) ~= "table" then
        return {}
    end

    local options = {}
    for _, mapEntry in pairs(itemEntry.maps) do
        if type(mapEntry) == "table" and type(mapEntry.pins) == "table" then
            local pins = {}
            for _, pin in pairs(mapEntry.pins) do
                local x = NormalizeCoordinate(pin and pin.x)
                local y = NormalizeCoordinate(pin and pin.y)
                local mapID = tonumber(pin and pin.mapID) or tonumber(mapEntry.mapID)
                if mapID and x and y then
                    local seenCount = math.max(1, math.floor((tonumber(pin.seenCount) or 1) + 0.5))
                    local totalQuantity = math.max(1, math.floor((tonumber(pin.totalQuantity) or 1) + 0.5))
                    pins[#pins + 1] = {
                        mapID = math.floor(mapID + 0.5),
                        x = x,
                        y = y,
                        label = pin.sourceName or pin.sourceText or "User discovery",
                        itemName = itemEntry.itemName or fallbackItemName,
                        spotLocation = pin.sourceText or pin.sourceName or "User-discovered farming spot",
                        targetName = (pin.sourceKind == "NPC" or pin.sourceKind == "AOE") and pin.sourceName or nil,
                        targetType = (pin.sourceKind == "NPC" or pin.sourceKind == "AOE") and "kill" or nil,
                        routeType = "user-discovered",
                        density = string.format("%d seen, %d looted", seenCount, totalQuantity),
                        sourceType = "user",
                        sourceKind = pin.sourceKind,
                        sourceLabel = "User discoveries",
                        seenCount = seenCount,
                        totalQuantity = totalQuantity,
                        tips = {
                            "Recorded automatically while you were farming.",
                        },
                    }
                end
            end
            table.sort(pins, function(left, right)
                if left.y ~= right.y then
                    return left.y < right.y
                end
                return left.x < right.x
            end)

            if #pins > 0 then
                local mapName = mapEntry.mapName or ("Map " .. tostring(mapEntry.mapID))
                options[#options + 1] = {
                    mapID = tonumber(mapEntry.mapID),
                    label = mapName .. " (User)",
                    pins = pins,
                    spotCount = #pins,
                    sourceType = "user",
                    sourceLabel = "User discoveries",
                }
            end
        end
    end

    table.sort(options, function(left, right)
        return tostring(left.label or "") < tostring(right.label or "")
    end)
    return options
end
