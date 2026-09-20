local savedVariablesPath = arg and arg[1]
local outputPath = (arg and arg[2]) or "Data/CraftingFarmingLearned.lua"

if type(savedVariablesPath) ~= "string" or savedVariablesPath == "" then
    io.stderr:write(
        "Usage: lua tools/export_crafting_farming_learned.lua "
            .. "<SavedVariables/General-Gold-Tracker.lua> [output]\n"
    )
    os.exit(1)
end

local function load_saved_variables(path)
    local env = {}
    local chunk, err
    if _VERSION == "Lua 5.1" then
        chunk, err = loadfile(path)
        if chunk and setfenv then
            setfenv(chunk, env)
        end
    else
        chunk, err = loadfile(path, "t", env)
    end
    if not chunk then
        error(err)
    end
    chunk()
    return env.WoWGeneralGoldTrackerDB or {}
end

local function is_session_learned(item)
    return type(item) == "table"
        and (item.learnedFromSession == true or item.importSource == "session" or item.tag == "Session")
end

local function normalize_item_id(value)
    local itemID = tonumber(value)
    if not itemID or itemID <= 0 then
        return nil
    end
    return math.floor(itemID + 0.5)
end

local function sorted_keys(tbl, numeric)
    local keys = {}
    for key in pairs(type(tbl) == "table" and tbl or {}) do
        keys[#keys + 1] = key
    end
    table.sort(keys, function(left, right)
        if numeric then
            return (tonumber(left) or 0) < (tonumber(right) or 0)
        end
        return tostring(left) < tostring(right)
    end)
    return keys
end

local function quote(value)
    return string.format("%q", tostring(value or ""))
end

local function write_value(handle, value)
    if value == nil then
        handle:write("nil")
    elseif type(value) == "number" then
        handle:write(tostring(value))
    elseif type(value) == "boolean" then
        handle:write(value and "true" or "false")
    else
        handle:write(quote(value))
    end
end

local function normalize_custom_items(db)
    local items = {}
    local seen = {}
    for _, item in ipairs(type(db.craftingFarmingCustomItems) == "table" and db.craftingFarmingCustomItems or {}) do
        local itemID = normalize_item_id(item and item.itemID)
        if itemID and is_session_learned(item) and not seen[itemID] then
            local professions = {}
            local seenProfessions = {}
            for _, professionID in ipairs(type(item.professions) == "table" and item.professions or {}) do
                if type(professionID) == "string" and professionID ~= "" and not seenProfessions[professionID] then
                    professions[#professions + 1] = professionID
                    seenProfessions[professionID] = true
                end
            end
            if #professions == 0 then
                professions[1] = "all"
            end
            table.sort(professions)
            items[#items + 1] = {
                itemID = itemID,
                expansion = type(item.expansion) == "string" and item.expansion ~= "" and item.expansion or "all",
                professions = professions,
                tag = type(item.tag) == "string" and item.tag ~= "" and item.tag or "Session",
                learnedAt = tonumber(item.learnedAt),
                updatedAt = tonumber(item.updatedAt),
                learnedExpansionSource = type(item.learnedExpansionSource) == "string"
                    and item.learnedExpansionSource
                    or nil,
                learnedProfessionSource = type(item.learnedProfessionSource) == "string"
                    and item.learnedProfessionSource
                    or nil,
            }
            seen[itemID] = true
        end
    end
    table.sort(items, function(left, right)
        return left.itemID < right.itemID
    end)
    return items
end

local function normalize_drop_rates(db)
    local saved = type(db.craftingFarmingDropRates) == "table" and db.craftingFarmingDropRates or {}
    local rawItems = type(saved.items) == "table" and saved.items or saved
    local items = {}
    for key, entry in pairs(type(rawItems) == "table" and rawItems or {}) do
        if key ~= "updatedAt" and key ~= "items" and type(entry) == "table" then
            local itemID = normalize_item_id(entry.itemID) or normalize_item_id(key)
            local quantity = math.max(0, tonumber(entry.quantity) or 0)
            local durationSeconds = math.max(0, math.floor((tonumber(entry.durationSeconds) or 0) + 0.5))
            local sessionCount = math.max(0, math.floor((tonumber(entry.sessionCount) or 0) + 0.5))
            local dropPerHour = math.max(0, tonumber(entry.dropPerHour) or 0)
            if dropPerHour <= 0 and quantity > 0 and durationSeconds > 0 then
                dropPerHour = (quantity * 3600) / durationSeconds
            end
            if itemID and (quantity > 0 or durationSeconds > 0 or dropPerHour > 0) then
                items[tostring(itemID)] = {
                    itemID = itemID,
                    quantity = quantity,
                    durationSeconds = durationSeconds,
                    sessionCount = sessionCount,
                    dropPerHour = dropPerHour,
                }
            end
        end
    end
    return tonumber(saved.updatedAt), items
end

local function normalize_item_overrides(db)
    local overrides = {}
    for key, item in pairs(type(db.craftingFarmingItemOverrides) == "table"
        and db.craftingFarmingItemOverrides
        or {}) do
        local itemID = normalize_item_id(type(item) == "table" and item.itemID) or normalize_item_id(key)
        if itemID and type(item) == "table" then
            local professions = {}
            local seenProfessions = {}
            for _, professionID in ipairs(type(item.professions) == "table" and item.professions or {}) do
                if type(professionID) == "string"
                    and professionID ~= ""
                    and professionID ~= "all"
                    and not seenProfessions[professionID] then
                    professions[#professions + 1] = professionID
                    seenProfessions[professionID] = true
                end
            end
            if #professions > 0 then
                table.sort(professions)
                overrides[tostring(itemID)] = {
                    itemID = itemID,
                    professions = professions,
                    updatedAt = tonumber(item.updatedAt),
                }
            end
        end
    end
    return overrides
end

local OBSERVATION_PIN_BUCKET_SIZE = 0.005

local function normalize_coordinate(value)
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

local function get_item_name_from_link(itemLink)
    if type(itemLink) ~= "string" then
        return nil
    end
    return itemLink:match("|h%[([^%]]+)%]|h")
end

local function get_observation_item(observations, itemID)
    local key = tostring(itemID)
    if not observations[key] then
        observations[key] = {
            itemID = itemID,
            seenCount = 0,
            totalQuantity = 0,
            maps = {},
        }
    end
    return observations[key]
end

local function get_observation_map(item, mapID, source)
    local key = tostring(mapID)
    local map = item.maps[key]
    if not map then
        map = {
            mapID = mapID,
            seenCount = 0,
            totalQuantity = 0,
            pinsByKey = {},
        }
        item.maps[key] = map
    end
    map.mapName = map.mapName or source.mapName
    map.zoneName = map.zoneName or source.zoneName
    map.locationLabel = map.locationLabel or source.locationLabel
    map.expansionID = map.expansionID or tonumber(source.expansionID)
    map.expansionName = map.expansionName or source.expansionName
    if source.isInstanced == true then
        map.isInstanced = true
    end
    return map
end

local function get_observation_pin_key(mapID, x, y)
    local bucketX = math.floor((x / OBSERVATION_PIN_BUCKET_SIZE) + 0.5)
    local bucketY = math.floor((y / OBSERVATION_PIN_BUCKET_SIZE) + 0.5)
    return table.concat({ tostring(mapID), tostring(bucketX), tostring(bucketY) }, ":")
end

local function merge_first_timestamp(current, candidate)
    local normalized = tonumber(candidate)
    if not normalized then
        return current
    end
    if not current or normalized < current then
        return normalized
    end
    return current
end

local function merge_last_timestamp(current, candidate)
    local normalized = tonumber(candidate)
    if not normalized then
        return current
    end
    if not current or normalized > current then
        return normalized
    end
    return current
end

local function add_observation_pin(map, source, quantity, seenCount)
    local x = normalize_coordinate(source.mapX or source.x)
    local y = normalize_coordinate(source.mapY or source.y)
    if not x or not y then
        return false
    end

    local key = get_observation_pin_key(map.mapID, x, y)
    local pin = map.pinsByKey[key]
    if not pin then
        pin = {
            x = x,
            y = y,
            seenCount = 0,
            totalQuantity = 0,
        }
        map.pinsByKey[key] = pin
    end
    pin.x = x
    pin.y = y
    pin.seenCount = pin.seenCount + math.max(1, math.floor((tonumber(seenCount) or 1) + 0.5))
    pin.totalQuantity = pin.totalQuantity + math.max(1, math.floor((tonumber(quantity) or 1) + 0.5))
    pin.sourceKind = source.lootSourceType or source.sourceKind or pin.sourceKind
    pin.sourceName = source.lootSourceName or source.sourceName or pin.sourceName
    pin.sourceText = source.lootSourceText or source.sourceText or pin.sourceText
    pin.coordinateSource = source.coordinateSource or pin.coordinateSource or "legacy"
    pin.firstSeenAt = merge_first_timestamp(
        pin.firstSeenAt,
        tonumber(source.firstSeenAt) or tonumber(source.timestamp)
    )
    pin.lastSeenAt = merge_last_timestamp(
        pin.lastSeenAt,
        tonumber(source.lastSeenAt) or tonumber(source.timestamp)
    )
    return true
end

local function normalize_observations(db, customItems)
    local learnedItemIDs = {}
    for _, item in ipairs(customItems) do
        learnedItemIDs[item.itemID] = true
    end

    local observations = {}
    for _, session in ipairs(type(db.sessionHistory) == "table" and db.sessionHistory or {}) do
        for _, loot in ipairs(type(session.itemLoots) == "table" and session.itemLoots or {}) do
            local itemID = normalize_item_id(loot and loot.itemID)
            if itemID and learnedItemIDs[itemID] then
                local item = get_observation_item(observations, itemID)
                local quantity = math.max(1, math.floor((tonumber(loot.quantity) or 1) + 0.5))
                item.itemName = item.itemName or get_item_name_from_link(loot.itemLink)
                item.seenCount = item.seenCount + 1
                item.totalQuantity = item.totalQuantity + quantity
                item.firstSeenAt = merge_first_timestamp(item.firstSeenAt, loot.timestamp)
                item.lastSeenAt = merge_last_timestamp(item.lastSeenAt, loot.timestamp)

                local mapID = normalize_item_id(loot.mapID)
                if mapID then
                    local map = get_observation_map(item, mapID, loot)
                    map.seenCount = map.seenCount + 1
                    map.totalQuantity = map.totalQuantity + quantity
                    add_observation_pin(map, loot, quantity, 1)
                end
            end
        end
    end

    local pinItems = type(db.userMaterialFarmingPins) == "table"
        and type(db.userMaterialFarmingPins.items) == "table"
        and db.userMaterialFarmingPins.items
        or {}
    for rawItemID, savedItem in pairs(pinItems) do
        local itemID = normalize_item_id(savedItem and savedItem.itemID) or normalize_item_id(rawItemID)
        if itemID and learnedItemIDs[itemID] and type(savedItem) == "table" then
            local item = get_observation_item(observations, itemID)
            item.itemName = item.itemName or savedItem.itemName
            if item.seenCount <= 0 then
                item.seenCount = math.max(0, math.floor((tonumber(savedItem.seenCount) or 0) + 0.5))
                item.totalQuantity = math.max(0, math.floor((tonumber(savedItem.totalQuantity) or 0) + 0.5))
            end
            item.firstSeenAt = merge_first_timestamp(item.firstSeenAt, savedItem.firstSeenAt)
            item.lastSeenAt = merge_last_timestamp(item.lastSeenAt, savedItem.lastSeenAt)

            for rawMapID, savedMap in pairs(type(savedItem.maps) == "table" and savedItem.maps or {}) do
                local mapID = normalize_item_id(savedMap and savedMap.mapID) or normalize_item_id(rawMapID)
                if mapID and type(savedMap) == "table" then
                    local map = get_observation_map(item, mapID, savedMap)
                    for _, savedPin in pairs(type(savedMap.pins) == "table" and savedMap.pins or {}) do
                        local x = normalize_coordinate(savedPin and savedPin.x)
                        local y = normalize_coordinate(savedPin and savedPin.y)
                        local pinKey = x and y and get_observation_pin_key(mapID, x, y) or nil
                        local existingPin = pinKey and map.pinsByKey[pinKey] or nil
                        if existingPin then
                            existingPin.sourceKind = savedPin.sourceKind or existingPin.sourceKind
                            existingPin.sourceName = savedPin.sourceName or existingPin.sourceName
                            existingPin.sourceText = savedPin.sourceText or existingPin.sourceText
                            existingPin.firstSeenAt = merge_first_timestamp(
                                existingPin.firstSeenAt,
                                savedPin.firstSeenAt
                            )
                            existingPin.lastSeenAt = merge_last_timestamp(
                                existingPin.lastSeenAt,
                                savedPin.lastSeenAt
                            )
                        elseif pinKey then
                            add_observation_pin(map, savedPin, savedPin.totalQuantity, savedPin.seenCount)
                        end
                    end
                end
            end
        end
    end

    return observations
end

local function write_optional_field(output, name, value)
    if value == nil then
        return
    end
    output:write(", ", name, " = ")
    write_value(output, value)
end

local db = load_saved_variables(savedVariablesPath)
local customItems = normalize_custom_items(db)
local itemOverrides = normalize_item_overrides(db)
local dropRatesUpdatedAt, dropRateItems = normalize_drop_rates(db)
local observations = normalize_observations(db, customItems)

local output = assert(io.open(outputPath, "w"))
output:write("local _, NS = ...\n\n")
output:write("NS.CraftingFarmingLearnedData = {\n")
output:write("    dataVersion = 3,\n")
output:write(
    "    sourceNote = \"Generated from WoWGeneralGoldTrackerDB "
        .. "by tools/export_crafting_farming_learned.lua.\",\n"
)
output:write("    customItems = {\n")
for _, item in ipairs(customItems) do
    output:write(
        "        { itemID = ",
        item.itemID,
        ", expansion = ",
        quote(item.expansion),
        ", professions = { "
    )
    for index, professionID in ipairs(item.professions) do
        if index > 1 then
            output:write(", ")
        end
        output:write(quote(professionID))
    end
    output:write(
        " }, tag = ",
        quote(item.tag),
        ", custom = true, learnedFromSession = true, importSource = \"session\""
    )
    if item.learnedAt then
        output:write(", learnedAt = ", tostring(item.learnedAt))
    end
    if item.updatedAt then
        output:write(", updatedAt = ", tostring(item.updatedAt))
    end
    if item.learnedExpansionSource then
        output:write(", learnedExpansionSource = ", quote(item.learnedExpansionSource))
    end
    if item.learnedProfessionSource then
        output:write(", learnedProfessionSource = ", quote(item.learnedProfessionSource))
    end
    output:write(" },\n")
end
output:write("    },\n")
output:write("    itemOverrides = {\n")
for _, key in ipairs(sorted_keys(itemOverrides, true)) do
    local item = itemOverrides[key]
    output:write("        [", quote(key), "] = { itemID = ", item.itemID, ", professions = { ")
    for index, professionID in ipairs(item.professions) do
        if index > 1 then
            output:write(", ")
        end
        output:write(quote(professionID))
    end
    output:write(" }")
    if item.updatedAt then
        output:write(", updatedAt = ", tostring(item.updatedAt))
    end
    output:write(" },\n")
end
output:write("    },\n")
output:write("    dropRates = {\n")
output:write("        updatedAt = ")
write_value(output, dropRatesUpdatedAt)
output:write(",\n")
output:write("        items = {\n")
for _, key in ipairs(sorted_keys(dropRateItems, true)) do
    local entry = dropRateItems[key]
    output:write("            [", quote(key), "] = { itemID = ", entry.itemID)
    output:write(", quantity = ", tostring(entry.quantity))
    output:write(", durationSeconds = ", tostring(entry.durationSeconds))
    output:write(", sessionCount = ", tostring(entry.sessionCount))
    output:write(", dropPerHour = ", tostring(entry.dropPerHour), " },\n")
end
output:write("        },\n")
output:write("    },\n")
output:write("    observations = {\n")
for _, itemKey in ipairs(sorted_keys(observations, true)) do
    local item = observations[itemKey]
    output:write("        [", quote(itemKey), "] = { itemID = ", item.itemID)
    write_optional_field(output, "itemName", item.itemName)
    output:write(", seenCount = ", item.seenCount, ", totalQuantity = ", item.totalQuantity)
    write_optional_field(output, "firstSeenAt", item.firstSeenAt)
    write_optional_field(output, "lastSeenAt", item.lastSeenAt)
    output:write(", maps = {\n")
    for _, mapKey in ipairs(sorted_keys(item.maps, true)) do
        local map = item.maps[mapKey]
        output:write("            [", quote(mapKey), "] = { mapID = ", map.mapID)
        write_optional_field(output, "mapName", map.mapName)
        write_optional_field(output, "zoneName", map.zoneName)
        write_optional_field(output, "locationLabel", map.locationLabel)
        write_optional_field(output, "expansionID", map.expansionID)
        write_optional_field(output, "expansionName", map.expansionName)
        if map.isInstanced == true then
            output:write(", isInstanced = true")
        end
        output:write(", seenCount = ", map.seenCount, ", totalQuantity = ", map.totalQuantity)
        output:write(", pins = {\n")

        local pins = {}
        for _, pin in pairs(map.pinsByKey) do
            pins[#pins + 1] = pin
        end
        table.sort(pins, function(left, right)
            if left.y ~= right.y then
                return left.y < right.y
            end
            if left.x ~= right.x then
                return left.x < right.x
            end
            return tostring(left.sourceName or left.sourceText or "")
                < tostring(right.sourceName or right.sourceText or "")
        end)
        for _, pin in ipairs(pins) do
            output:write("                { x = ", pin.x, ", y = ", pin.y)
            output:write(", seenCount = ", pin.seenCount, ", totalQuantity = ", pin.totalQuantity)
            write_optional_field(output, "sourceKind", pin.sourceKind)
            write_optional_field(output, "sourceName", pin.sourceName)
            write_optional_field(output, "sourceText", pin.sourceText)
            write_optional_field(output, "coordinateSource", pin.coordinateSource)
            write_optional_field(output, "firstSeenAt", pin.firstSeenAt)
            write_optional_field(output, "lastSeenAt", pin.lastSeenAt)
            output:write(" },\n")
        end
        output:write("            } },\n")
    end
    output:write("        } },\n")
end
output:write("    },\n")
output:write("}\n")
output:close()

io.stdout:write(string.format(
    "Exported %d learned materials, %d category overrides, %d drop-rate entries, and %d observation sets to %s\n",
    #customItems,
    #sorted_keys(itemOverrides),
    #sorted_keys(dropRateItems),
    #sorted_keys(observations),
    outputPath
))
