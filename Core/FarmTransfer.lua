local _, NS = ...
local GoldTracker = NS.GoldTracker
local PREFIX = "GGT-FARMS:1:"
local MAX_TEXT, MAX_DATA = 8 * 1024 * 1024, 32 * 1024 * 1024

local function Require(value, message)
    if not value then error(message, 0) end
end

local function Integer(value)
    return type(value) == "number" and value > 0 and value < math.huge and value == math.floor(value)
end

local function Array(value)
    if type(value) ~= "table" then return false end
    local count = 0
    for key in pairs(value) do
        if not Integer(key) or key > #value then return false end
        count = count + 1
    end
    return count == #value
end

local function CheckData(value, stack, depth, budget)
    Require(not (type(issecretvalue) == "function" and issecretvalue(value)), "Restricted data cannot be exported.")
    local kind = type(value)
    Require(kind == "table" or kind == "string" or kind == "number" or kind == "boolean", "Unsupported farm data value.")
    budget.count = budget.count + 1
    Require(budget.count <= 1000000 and depth <= 40, "Farm data exceeds the supported size or nesting limit.")
    if kind == "number" then Require(value == value and math.abs(value) < math.huge, "Invalid number in farm data.") end
    if kind ~= "table" then return end
    Require(not stack[value], "Farm data contains a circular reference.")
    stack[value] = true
    for key, child in pairs(value) do
        Require(type(key) == "string" or type(key) == "number" or type(key) == "boolean", "Invalid farm data key.")
        CheckData(key, stack, depth + 1, budget)
        CheckData(child, stack, depth + 1, budget)
    end
    stack[value] = nil
end

local function CheckStrings(value, message)
    Require(Array(value), message)
    for _, text in ipairs(value) do Require(type(text) == "string", message) end
end

local function CheckMapOption(option)
    Require(type(option) == "table" and Integer(option.mapID), "Invalid farm map.")
    Require(option.id == nil or type(option.id) == "string" or type(option.id) == "number", "Invalid map identity.")
    for _, field in ipairs({ "label", "mapLabel", "sourceType", "sourceLabel", "location" }) do
        Require(option[field] == nil or type(option[field]) == "string", "Invalid map metadata.")
    end
    Require(Array(option.pins), "Invalid map pins.")
    for _, pin in ipairs(option.pins) do
        Require(type(pin) == "table" and (pin.mapID == nil or Integer(pin.mapID)), "Invalid map pin.")
        Require(type(pin.x) == "number" and pin.x >= 0 and pin.x <= 1
            and type(pin.y) == "number" and pin.y >= 0 and pin.y <= 1, "Invalid map coordinates.")
        Require(pin.routeID == nil or type(pin.routeID) == "string" or type(pin.routeID) == "number", "Invalid route identity.")
        for _, field in ipairs({ "label", "itemName", "routeType", "sourceType", "sourceLabel" }) do
            Require(pin[field] == nil or type(pin[field]) == "string", "Invalid pin metadata.")
        end
        if pin.tips then CheckStrings(pin.tips, "Invalid map tips.") end
        if pin.sourceUrls then CheckStrings(pin.sourceUrls, "Invalid map sources.") end
    end
end

local function CheckStringArray(value)
    Require(Array(value), "Invalid route plan order.")
    for _, key in ipairs(value) do Require(type(key) == "string", "Invalid route plan key.") end
end

local function CheckPlan(plan)
    Require(type(plan) == "table", "Invalid route plan.")
    if plan.order then CheckStringArray(plan.order) end
    for _, field in ipairs({ "locked", "locationOverrides", "guidance", "runs" }) do
        if plan[field] then Require(type(plan[field]) == "table", "Invalid route plan settings.") end
    end
    for key, value in pairs(plan.locked or {}) do
        Require(type(key) == "string" and type(value) == "boolean", "Invalid locked route stop.")
    end
    for key, value in pairs(plan.locationOverrides or {}) do
        Require(type(key) == "string" and type(value) == "string", "Invalid route location override.")
    end
    for key, value in pairs(plan.guidance or {}) do
        Require(type(key) == "string" and type(value) == "boolean", "Invalid route guidance.")
    end
    for character, run in pairs(plan.runs or {}) do
        Require(type(character) == "string" and type(run) == "table", "Invalid route run.")
        if run.completed then Require(type(run.completed) == "table", "Invalid route progress.") end
        for key, value in pairs(run.completed or {}) do
            Require(type(key) == "string" and type(value) == "boolean", "Invalid completed route stop.")
        end
        if run.currentStepKey then Require(type(run.currentStepKey) == "string", "Invalid current route stop.") end
    end
end

local function CheckPackage(package)
    CheckData(package, {}, 0, { count = 0 })
    Require(package.kind == "GGT_CUSTOM_FARMS" and package.version == 1, "Unsupported farm export format.")
    Require(package.farmSchema == 4 and Array(package.farms) and #package.farms > 0, "Invalid farm collection.")
    local farmIDs = {}
    for _, farm in ipairs(package.farms) do
        Require(type(farm) == "table" and Integer(farm.id) and not farmIDs[farm.id], "Invalid or duplicate farm ID.")
        farmIDs[farm.id] = true
        Require(type(farm.name) == "string" and farm.name:find("%S"), "A farm is missing its name.")
        Require(Array(farm.entries), "Invalid farm items.")
        Require(farm.nextEntryID == nil or Integer(farm.nextEntryID), "Invalid farm item counter.")
        Require(farm.assignedCharacter == nil or type(farm.assignedCharacter) == "string", "Invalid assigned character.")
        local entryIDs, entryKeys = {}, {}
        for _, entry in ipairs(farm.entries) do
            Require(type(entry) == "table" and Integer(entry.id) and Integer(entry.itemID), "Invalid farm item.")
            Require(not entryIDs[entry.id] and type(entry.entryKey) == "string" and not entryKeys[entry.entryKey], "Duplicate farm item identity.")
            entryIDs[entry.id], entryKeys[entry.entryKey] = true, true
            for _, field in ipairs({ "itemName", "itemLink", "sourceType", "sourceLabel", "sourceKey", "locationLabel", "targetName", "catalogFarmID" }) do
                Require(entry[field] == nil or type(entry[field]) == "string", "Invalid farm item metadata.")
            end
            Require(entry.mapID == nil or Integer(entry.mapID), "Invalid item location.")
            if entry.mapSource then CheckMapOption(entry.mapSource) end
            if entry.portableMapSource then CheckMapOption(entry.portableMapSource) end
            if entry.catalogFarmID then
                local snapshot = entry.catalogSnapshot
                Require(type(snapshot) == "table" and snapshot.id == entry.catalogFarmID, "Missing linked farm snapshot.")
                Require(type(snapshot.name) == "string", "Invalid linked farm name.")
                Require(Array(snapshot.ggtMapOptions) and type(snapshot.ggtGatheringRecords) == "table", "Missing linked route data.")
                if snapshot.sourceRecordIDs then CheckStrings(snapshot.sourceRecordIDs, "Invalid source record IDs.") end
                if snapshot.mapNames then CheckStrings(snapshot.mapNames, "Invalid map names.") end
                if snapshot.targets then
                    Require(Array(snapshot.targets), "Invalid linked farm targets.")
                    for _, target in ipairs(snapshot.targets) do
                        Require(type(target) == "table" and Integer(target.itemID)
                            and (target.quantity == nil or (type(target.quantity) == "number" and target.quantity >= 0)), "Invalid linked farm target.")
                    end
                end
                for _, option in ipairs(snapshot.ggtMapOptions) do CheckMapOption(option) end
                if snapshot.ggtEntrance then
                    Require(type(snapshot.ggtEntrance) == "table" and type(snapshot.ggtEntrance.id) == "string"
                        and Integer(snapshot.ggtEntrance.mapID), "Invalid instance entrance.")
                end
                if snapshot.mapIDs then
                    Require(Array(snapshot.mapIDs), "Invalid linked farm locations.")
                    for _, mapID in ipairs(snapshot.mapIDs) do Require(Integer(mapID), "Invalid linked farm map.") end
                end
                for _, record in pairs(snapshot.ggtGatheringRecords) do
                    Require(type(record) == "table" and Array(record.routes or {}), "Invalid gathering routes.")
                    for _, route in ipairs(record.routes or {}) do
                        Require(type(route) == "table" and Integer(route.mapID) and Array(route.coords), "Invalid gathering route.")
                        for _, coord in ipairs(route.coords) do
                            Require(type(coord) == "table" and type(coord.x) == "number" and coord.x >= 0 and coord.x <= 1
                                and type(coord.y) == "number" and coord.y >= 0 and coord.y <= 1, "Invalid route coordinates.")
                        end
                    end
                end
            end
        end
        if farm.routePlan then CheckPlan(farm.routePlan) end
    end
    Require(Array(package.history or {}), "Invalid farm run history.")
    local historyIDs = {}
    for _, history in ipairs(package.history or {}) do
        Require(type(history) == "table" and Integer(history.id) and not historyIDs[history.id]
            and farmIDs[history.farmID] and (history.recordType == "farm" or history.isFarm == true), "Invalid farm history record.")
        historyIDs[history.id] = true
    end
end

local function Codec()
    Require(type(C_EncodingUtil) == "table", "Farm sharing requires the current Retail client.")
    for _, name in ipairs({ "SerializeCBOR", "DeserializeCBOR", "CompressString", "DecompressString", "EncodeBase64", "DecodeBase64" }) do
        Require(type(C_EncodingUtil[name]) == "function", "Farm sharing is unavailable in this client.")
    end
    return C_EncodingUtil
end

local function Checksum(data)
    local a, b = 1, 0
    for index = 1, #data do
        a = (a + data:byte(index)) % 65521
        b = (b + a) % 65521
    end
    return string.format("%08x", b * 65536 + a)
end

local function Decode(text)
    Require(type(text) == "string" and #text <= MAX_TEXT, "Farm string is empty or too large.")
    text = text:gsub("%s+", "")
    Require(text:sub(1, #PREFIX) == PREFIX, "This is not a supported GGT farm string.")
    local length, checksum, encoded = text:sub(#PREFIX + 1):match("^(%d+):(%x%x%x%x%x%x%x%x):([%w+/=]+)$")
    Require(length and tonumber(length) <= MAX_DATA, "Farm string is truncated or too large.")
    local codec = Codec()
    local compressed = codec.DecodeBase64(encoded)
    Require(type(compressed) == "string", "Invalid farm string encoding.")
    local data = codec.DecompressString(compressed)
    Require(type(data) == "string" and #data <= MAX_DATA and #data == tonumber(length), "Farm string is damaged or incomplete.")
    Require(Checksum(data) == checksum:lower(), "Farm string checksum does not match. Copy the complete string again.")
    local package = codec.DeserializeCBOR(data)
    Require(type(package) == "table", "Invalid farm data.")
    CheckPackage(package)
    return package
end

function GoldTracker:BuildCustomFarmExport(farmID)
    local ok, result = pcall(function()
        local codec, store = Codec(), self:GetCustomFarmStore()
        Require(store, "Farm storage is unavailable.")
        local selected = farmID and self:GetCustomFarmByID(farmID)
        Require(not farmID or selected, "Select a farm to export.")
        local package = { kind = "GGT_CUSTOM_FARMS", version = 1, farmSchema = 4, farms = {}, history = {} }
        local sourceFarms = selected and { selected } or store.farms
        Require(#sourceFarms > 0, "There are no farms to export.")
        local snapshots, exportedIDs = {}, {}
        for _, farm in ipairs(sourceFarms) do
            local copy = self:CopyCustomFarmData(farm)
            copy.transferContext = copy.transferContext or { sourceFarmID = farm.id,
                wasBuilding = store.activeBuildFarmID == farm.id, activeRouteCharacters = {} }
            for character, activeID in pairs(store.activeRouteFarmIDs or {}) do
                if activeID == farm.id then copy.transferContext.activeRouteCharacters[character] = true end
            end
            for index, entry in ipairs(farm.entries) do
                local target = copy.entries[index]
                if entry.catalogFarmID then
                    local catalog = self:ResolveCustomFarmCatalog(entry)
                    Require(catalog, "Linked farm data is unavailable: " .. entry.catalogFarmID)
                    if not snapshots[catalog] then
                        local snapshot = self:CopyCustomFarmData(catalog)
                        if not snapshot.ggtMapOptions then
                            Require(type(self.BuildFarmRouteMapOptions) == "function", "Farm map tools are unavailable.")
                            snapshot.ggtMapOptions = self:CopyCustomFarmData(self:BuildFarmRouteMapOptions(catalog))
                        end
                        if not snapshot.ggtGatheringRecords then
                            snapshot.ggtGatheringRecords = {}
                            if #(catalog.sourceRecordIDs or {}) > 0 and catalog.sourceDataset == "CatalogGatheringData" then
                                local gathering = NS.CatalogGatheringData
                                for _, id in ipairs(catalog.sourceRecordIDs) do
                                    local record = gathering and gathering.farmsByRecordID and gathering.farmsByRecordID[id]
                                    Require(record, "Linked gathering data is unavailable: " .. tostring(id))
                                    snapshot.ggtGatheringRecords[id] = self:CopyCustomFarmData(record)
                                end
                            end
                        end
                        if not snapshot.ggtEntrance and type(self.ResolveCatalogFarmInstanceEntrance) == "function" then
                            snapshot.ggtEntrance = self:CopyCustomFarmData(self:ResolveCatalogFarmInstanceEntrance(catalog))
                        end
                        snapshots[catalog] = snapshot
                    end
                    target.catalogSnapshot = snapshots[catalog]
                elseif entry.mapSource then
                    target.portableMapSource = self:CopyCustomFarmData(self:ResolveCustomFarmEntryMapOption(entry))
                    Require(target.portableMapSource, "Saved farm map data is unavailable.")
                end
            end
            package.farms[#package.farms + 1] = copy
            exportedIDs[farm.id] = true
        end
        for _, history in ipairs(type(self.db.sessionHistory) == "table" and self.db.sessionHistory or {}) do
            if exportedIDs[history.farmID] and (history.recordType == "farm" or history.isFarm == true) then
                package.history[#package.history + 1] = self:CopyCustomFarmData(history)
            end
        end
        CheckPackage(package)
        local data = codec.SerializeCBOR(package)
        Require(type(data) == "string" and #data <= MAX_DATA, "Farm export is too large.")
        local compressed = codec.CompressString(data)
        Require(type(compressed) == "string", "Could not compress farm data.")
        local encoded = codec.EncodeBase64(compressed)
        Require(type(encoded) == "string", "Could not encode farm data.")
        local text = PREFIX .. #data .. ":" .. Checksum(data) .. ":" .. encoded
        Require(#text <= MAX_TEXT, "Farm export string is too large.")
        return text
    end)
    if ok then return result end
    return nil, tostring(result)
end

function GoldTracker:ImportCustomFarmString(text)
    -- Decode and validate every farm before touching the destination store.
    local ok, package = pcall(Decode, text)
    if not ok then return nil, "Import failed: " .. tostring(package) end
    local store = self:GetCustomFarmStore()
    if not store then return nil, "Farm storage is unavailable." end
    local copies, idMap, nextID = {}, {}, Integer(store.nextID) and store.nextID or 1
    for _, farm in ipairs(store.farms) do nextID = math.max(nextID, farm.id + 1) end
    for _, source in ipairs(package.farms) do
        local copy = self:CopyCustomFarmData(source)
        copy.id = nextID
        nextID = nextID + 1
        local maximum = 0
        for _, entry in ipairs(copy.entries) do maximum = math.max(maximum, entry.id) end
        copy.nextEntryID = math.max(maximum + 1, tonumber(copy.nextEntryID) or 1)
        copies[#copies + 1], idMap[source.id] = copy, copy.id
    end
    local historyCopies, nextHistoryID = {}, tonumber(self.db.nextHistoryID) or 1
    for _, history in ipairs(type(self.db.sessionHistory) == "table" and self.db.sessionHistory or {}) do
        nextHistoryID = math.max(nextHistoryID, (tonumber(history.id) or 0) + 1)
    end
    for _, source in ipairs(package.history or {}) do
        local copy = self:CopyCustomFarmData(source)
        copy.id, copy.farmID = nextHistoryID, idMap[source.farmID]
        nextHistoryID = nextHistoryID + 1
        historyCopies[#historyCopies + 1] = copy
    end
    for _, copy in ipairs(copies) do store.farms[#store.farms + 1] = copy end
    store.nextID = nextID
    if #historyCopies > 0 then
        self.db.sessionHistory = type(self.db.sessionHistory) == "table" and self.db.sessionHistory or {}
        for _, history in ipairs(historyCopies) do self.db.sessionHistory[#self.db.sessionHistory + 1] = history end
        self.db.nextHistoryID = nextHistoryID
        if type(self.RefreshHistoryWindow) == "function" then self:RefreshHistoryWindow() end
    end
    if self.myFarmsFrame then self.myFarmsFrame.selectedFarmID = copies[1].id end
    self:NotifyCustomFarmsChanged()
    return { count = #copies, farmIDs = idMap, farms = copies, historyCount = #historyCopies }
end
