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

local db = load_saved_variables(savedVariablesPath)
local customItems = normalize_custom_items(db)
local dropRatesUpdatedAt, dropRateItems = normalize_drop_rates(db)

local output = assert(io.open(outputPath, "w"))
output:write("local _, NS = ...\n\n")
output:write("NS.CraftingFarmingLearnedData = {\n")
output:write("    dataVersion = 1,\n")
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
output:write("}\n")
output:close()

io.stdout:write(string.format(
    "Exported %d learned materials and %d drop-rate entries to %s\n",
    #customItems,
    #sorted_keys(dropRateItems),
    outputPath
))
