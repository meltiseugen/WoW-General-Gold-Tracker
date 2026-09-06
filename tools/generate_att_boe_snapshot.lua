local repoRoot = arg[0]:gsub("[/\\]tools[/\\][^/\\]+$", "")
if repoRoot == arg[0] then
    repoRoot = "."
end
local addonsRoot = repoRoot == "." and ".." or repoRoot:gsub("[/\\][^/\\]+$", "")
local attRoot = addonsRoot .. "\\AllTheThings"
local outputPath = repoRoot .. "\\Data\\ATTBoEDrops.lua"
local instanceDropsPath = repoRoot .. "\\Data\\InstanceDrops.lua"

local ZONE_DROPS_HEADER_ID = -63

local EXPANSION_LABELS = {
    [1] = "Classic",
    [2] = "Burning Crusade",
    [3] = "Wrath of the Lich King",
    [4] = "Cataclysm",
    [5] = "Mists of Pandaria",
    [6] = "Warlords of Draenor",
    [7] = "Legion",
    [8] = "Battle for Azeroth",
    [9] = "Shadowlands",
    [10] = "Dragonflight",
    [11] = "The War Within",
    [12] = "Midnight",
}

local function readFile(path)
    local handle = assert(io.open(path, "rb"))
    local text = handle:read("*a")
    handle:close()
    return text
end

local function parseATTVersion()
    local text = readFile(attRoot .. "\\AllTheThings.toc")
    for line in text:gmatch("[^\r\n]+") do
        local version = line:match("^##%s*Version:%s*(.-)%s*$")
        if version then
            return version
        end
    end
    return "unknown"
end

local function luaString(value)
    value = tostring(value or "")
    local chunks = { '"' }
    for index = 1, #value do
        local byte = value:byte(index)
        local char = value:sub(index, index)
        if char == "\\" then
            chunks[#chunks + 1] = "\\\\"
        elseif char == '"' then
            chunks[#chunks + 1] = '\\"'
        elseif char == "\n" then
            chunks[#chunks + 1] = "\\n"
        elseif char == "\r" then
            chunks[#chunks + 1] = "\\r"
        elseif byte >= 32 and byte <= 126 then
            chunks[#chunks + 1] = char
        else
            chunks[#chunks + 1] = string.format("\\%03d", byte)
        end
    end
    chunks[#chunks + 1] = '"'
    return table.concat(chunks)
end

local function makeNode(fields)
    if type(fields) == "table" then
        return fields
    end
    return {}
end

local function makeCreator(idField)
    return function(id, fields)
        local node = makeNode(fields)
        node[idField] = id
        return node
    end
end

local function genericCreator(idField)
    return function(id, fields)
        local node = makeNode(fields)
        if id ~= nil then
            node[idField or "id"] = id
        end
        return node
    end
end

local function deepStub()
    local stub = {}
    setmetatable(stub, {
        __index = function(tableRef, key)
            local value = deepStub()
            rawset(tableRef, key, value)
            return value
        end,
        __call = function()
            return nil
        end,
    })
    return stub
end

local function buildATTStub(categories)
    local att = {
        Categories = categories,
        Settings = {},
        L = {
            HEADER_NAMES = {},
            MAP_ID_TO_ZONE_TEXT = {},
        },
        OnTooltipDB = setmetatable({}, {
            __index = function(tableRef, key)
                local value = function() end
                rawset(tableRef, key, value)
                return value
            end,
        }),
    }

    att.AddEventHandler = function(_, callback)
        if type(callback) == "function" then
            callback(categories)
        end
    end

    att.CreateAchievement = genericCreator("achievementID")
    att.CreateAchievementCriteria = genericCreator("criteriaID")
    att.CreateCategory = genericCreator("categoryID")
    att.CreateCharacterClass = genericCreator("classID")
    att.CreateCurrencyClass = genericCreator("currencyID")
    att.CreateCustomHeader = makeCreator("headerID")
    att.CreateDifficulty = makeCreator("difficultyID")
    att.CreateEncounter = makeCreator("encounterID")
    att.CreateExpansion = makeCreator("expansionID")
    att.CreateFaction = genericCreator("factionID")
    att.CreateFilter = makeCreator("filterID")
    att.CreateFlightPath = genericCreator("flightPathID")
    att.CreateHeader = makeCreator("headerID")
    att.CreateInstance = makeCreator("instanceID")
    att.CreateItem = makeCreator("itemID")
    att.CreateItemSource = function(sourceID, itemID, fields)
        local node = makeNode(fields)
        node.sourceID = sourceID
        node.itemID = itemID
        return node
    end
    att.CreateMap = makeCreator("mapID")
    att.CreateNPC = genericCreator("npcID")
    att.CreateObject = genericCreator("objectID")
    att.CreateProfession = genericCreator("professionID")
    att.CreateQuest = genericCreator("questID")
    att.CreateRecipe = genericCreator("recipeID")
    att.CreateSpecies = genericCreator("speciesID")
    att.CreateSpell = genericCreator("spellID")

    setmetatable(att, {
        __index = function(tableRef, key)
            if type(key) == "string" and key:match("^Create") then
                local fn = genericCreator(key:gsub("^Create", "") .. "ID")
                rawset(tableRef, key, fn)
                return fn
            end
            local value = deepStub()
            rawset(tableRef, key, value)
            return value
        end,
    })

    return att
end

local function runATTCategory(relativePath)
    local categories = {}
    local att = buildATTStub(categories)
    local path = attRoot .. "\\" .. relativePath
    local chunk = assert(loadfile(path))
    local function inert()
        return nil
    end
    local previousGlobals = {
        C_Item = _G.C_Item,
        C_Map = _G.C_Map,
        C_MountJournal = _G.C_MountJournal,
        C_PetJournal = _G.C_PetJournal,
        C_QuestLog = _G.C_QuestLog,
        C_ToyBox = _G.C_ToyBox,
        C_TransmogCollection = _G.C_TransmogCollection,
        Enum = _G.Enum,
        GetAchievementInfo = _G.GetAchievementInfo,
        GetCVar = _G.GetCVar,
        GetItemInfo = _G.GetItemInfo,
        GetSpellInfo = _G.GetSpellInfo,
        WOW_PROJECT_ID = _G.WOW_PROJECT_ID,
        WOW_PROJECT_MAINLINE = _G.WOW_PROJECT_MAINLINE,
    }
    _G.C_Item = deepStub()
    _G.C_Item.GetItemInfoInstant = function()
        return nil, nil, nil, 1, nil, ""
    end
    _G.C_Item.GetItemCount = function()
        return 0
    end
    _G.C_Map = deepStub()
    _G.C_MountJournal = deepStub()
    _G.C_PetJournal = deepStub()
    _G.C_QuestLog = deepStub()
    _G.C_ToyBox = deepStub()
    _G.C_TransmogCollection = deepStub()
    _G.Enum = deepStub()
    _G.GetAchievementInfo = inert
    _G.GetCVar = function()
        return ""
    end
    _G.GetItemInfo = inert
    _G.GetSpellInfo = inert
    _G.WOW_PROJECT_ID = 1
    _G.WOW_PROJECT_MAINLINE = 1

    local ok, err = pcall(chunk, "AllTheThings", att)
    for key, value in pairs(previousGlobals) do
        _G[key] = value
    end
    if not ok then
        error(err, 0)
    end
    return categories
end

local function loadInstanceMetadata()
    local metadata = {}
    local ns = {}
    local chunk = loadfile(instanceDropsPath)
    if not chunk then
        return metadata
    end
    chunk("General-Gold-Tracker", ns)
    local data = ns.InstanceDropsData
    if type(data) ~= "table" or type(data.instances) ~= "table" then
        return metadata
    end
    for _, instance in pairs(data.instances) do
        if type(instance) == "table" and type(instance.encounterJournalID) == "number" then
            metadata[instance.encounterJournalID] = {
                name = instance.name,
                expansionID = instance.expansionID,
                expansion = instance.expansion,
                contentType = instance.contentType,
                mapID = instance.mapID,
            }
        end
    end
    return metadata
end

local function firstMapID(node)
    if type(node) ~= "table" then
        return nil
    end
    if type(node.mapID) == "number" then
        return node.mapID
    end
    if type(node.maps) == "table" then
        for _, mapID in ipairs(node.maps) do
            if type(mapID) == "number" then
                return mapID
            end
        end
    end
    if type(node.coords) == "table" then
        for mapID in pairs(node.coords) do
            if type(mapID) == "number" then
                return mapID
            end
        end
    end
    return nil
end

local function isRejectedItem(node)
    if type(node) ~= "table" or type(node.itemID) ~= "number" or node.itemID <= 0 then
        return true
    end
    if node.b ~= nil and node.b ~= 2 then
        return true
    end
    if node.u == 2 or node.cost ~= nil or node.requireSkill ~= nil then
        return true
    end
    return false
end

local function addItem(items, node)
    if isRejectedItem(node) then
        return
    end
    local item = items[node.itemID]
    if not item then
        item = {
            itemID = node.itemID,
            sourceID = type(node.sourceID) == "number" and node.sourceID or nil,
            attBindType = type(node.b) == "number" and node.b or nil,
            level = type(node.lvl) == "number" and node.lvl or nil,
        }
        items[node.itemID] = item
    elseif not item.sourceID and type(node.sourceID) == "number" then
        item.sourceID = node.sourceID
    end
end

local function childNodes(node)
    local children = {}
    if type(node) ~= "table" then
        return children
    end
    if type(node.g) == "table" then
        for _, child in ipairs(node.g) do
            children[#children + 1] = child
        end
    end
    for _, child in ipairs(node) do
        children[#children + 1] = child
    end
    return children
end

local function collectItems(node, items)
    if type(node) ~= "table" then
        return
    end
    addItem(items, node)
    for _, child in ipairs(childNodes(node)) do
        collectItems(child, items)
    end
end

local function collectInstanceDrops(root, metadata)
    local instances = {}

    local function visit(node, context)
        if type(node) ~= "table" then
            return
        end

        local nextContext = {
            expansionID = context.expansionID,
            instanceID = context.instanceID,
            mapID = context.mapID,
            contentType = context.contentType,
        }

        if type(node.expansionID) == "number" then
            nextContext.expansionID = node.expansionID
        end
        if type(node.instanceID) == "number" then
            nextContext.instanceID = node.instanceID
            nextContext.mapID = firstMapID(node)
            nextContext.contentType = node.isRaid and "raid" or "dungeon"
        end

        if node.headerID == ZONE_DROPS_HEADER_ID and type(nextContext.instanceID) == "number" then
            local items = {}
            collectItems(node, items)
            if next(items) then
                local meta = metadata[nextContext.instanceID] or {}
                local expansionID = meta.expansionID or nextContext.expansionID or 0
                local instance = instances[nextContext.instanceID]
                if not instance then
                    instance = {
                        journalInstanceID = nextContext.instanceID,
                        name = meta.name or ("Instance " .. tostring(nextContext.instanceID)),
                        expansionID = expansionID,
                        expansion = meta.expansion or EXPANSION_LABELS[expansionID] or ("Expansion " .. tostring(expansionID)),
                        contentType = meta.contentType or nextContext.contentType or "dungeon",
                        mapID = meta.mapID or nextContext.mapID,
                        items = {},
                    }
                    instances[nextContext.instanceID] = instance
                end
                for itemID, item in pairs(items) do
                    instance.items[itemID] = item
                end
            end
            return
        end

        for _, child in ipairs(childNodes(node)) do
            visit(child, nextContext)
        end
    end

    visit(root, {})
    return instances
end

local function collectZoneDrops(root)
    local zones = {}

    local function visit(node, context)
        if type(node) ~= "table" then
            return
        end

        local nextContext = {
            expansionID = context.expansionID,
            mapID = context.mapID,
        }
        if type(node.expansionID) == "number" then
            nextContext.expansionID = node.expansionID
        end
        if type(node.mapID) == "number" then
            nextContext.mapID = node.mapID
        end

        if node.headerID == ZONE_DROPS_HEADER_ID and type(nextContext.mapID) == "number" then
            local items = {}
            collectItems(node, items)
            if next(items) then
                local expansionID = nextContext.expansionID or 0
                local zone = zones[nextContext.mapID]
                if not zone then
                    zone = {
                        mapID = nextContext.mapID,
                        expansionID = expansionID,
                        expansion = EXPANSION_LABELS[expansionID] or ("Expansion " .. tostring(expansionID)),
                        items = {},
                    }
                    zones[nextContext.mapID] = zone
                end
                for itemID, item in pairs(items) do
                    zone.items[itemID] = item
                end
            end
            return
        end

        for _, child in ipairs(childNodes(node)) do
            visit(child, nextContext)
        end
    end

    visit(root, {})
    return zones
end

local function collectWorldDrops(root)
    local items = {}

    local function visit(node, context)
        if type(node) ~= "table" then
            return
        end

        local nextContext = {
            expansionID = context.expansionID,
        }
        if type(node.expansionID) == "number" then
            nextContext.expansionID = node.expansionID
        end

        local itemID = tonumber(node.itemID)
        if itemID then
            itemID = math.floor(itemID + 0.5)
            addItem(items, node)
            local item = items[itemID]
            if item and type(nextContext.expansionID) == "number" then
                item.expansionID = nextContext.expansionID
                item.expansion = EXPANSION_LABELS[nextContext.expansionID] or ("Expansion " .. tostring(nextContext.expansionID))
            end
        end

        for _, child in ipairs(childNodes(node)) do
            visit(child, nextContext)
        end
    end

    visit(root, {})
    return items
end

local function sortedKeys(tableRef)
    local keys = {}
    for key in pairs(tableRef or {}) do
        keys[#keys + 1] = key
    end
    table.sort(keys)
    return keys
end

local function writeItem(handle, item, indent)
    handle:write(indent, "{ itemID = ", tostring(item.itemID))
    if item.sourceID then
        handle:write(", sourceID = ", tostring(item.sourceID))
    end
    if item.attBindType then
        handle:write(", attBindType = ", tostring(item.attBindType))
    end
    if item.level then
        handle:write(", level = ", tostring(item.level))
    end
    if item.expansionID then
        handle:write(", expansionID = ", tostring(item.expansionID))
    end
    if item.expansion then
        handle:write(", expansion = ", luaString(item.expansion))
    end
    handle:write(" },\n")
end

local function countItems(groups)
    local total = 0
    for _, group in pairs(groups or {}) do
        if type(group) == "table" and type(group.items) == "table" then
            for _ in pairs(group.items) do
                total = total + 1
            end
        end
    end
    return total
end

local function writeSnapshot()
    local version = parseATTVersion()
    local metadata = loadInstanceMetadata()
    local instanceCategories = runATTCategory("db\\Standard\\Categories\\Instances.lua")
    local zoneCategories = runATTCategory("db\\Standard\\Categories\\Zones.lua")
    local worldCategories = runATTCategory("db\\Standard\\Categories\\WorldDrops.lua")

    local instances = collectInstanceDrops(instanceCategories.Instances, metadata)
    local zones = collectZoneDrops(zoneCategories.Zones)
    local worldItems = collectWorldDrops(worldCategories.WorldDrops)
    local instanceItemCount = countItems(instances)
    local zoneItemCount = countItems(zones)
    local worldItemCount = 0
    for _ in pairs(worldItems) do
        worldItemCount = worldItemCount + 1
    end

    local handle = assert(io.open(outputPath, "wb"))
    handle:write("local _, NS = ...\n\n")
    handle:write("-- Generated by tools/generate_att_boe_snapshot.lua from the installed AllTheThings addon.\n")
    handle:write("-- Re-run the generator after updating AllTheThings to refresh this bundled source.\n")
    handle:write("NS.ATTBoEDropsData = {\n")
    handle:write('    source = "AllTheThings",\n')
    handle:write("    sourceVersion = ", luaString(version), ",\n")
    handle:write('    sourceURL = "https://github.com/DFortun81/AllTheThings",\n')
    handle:write('    sourceLicense = "MIT",\n')
    handle:write("    generatedAt = ", luaString(os.date("!%Y-%m-%d")), ",\n")
    handle:write("    instanceCount = ", tostring(#sortedKeys(instances)), ",\n")
    handle:write("    instanceItemCount = ", tostring(instanceItemCount), ",\n")
    handle:write("    zoneCount = ", tostring(#sortedKeys(zones)), ",\n")
    handle:write("    zoneItemCount = ", tostring(zoneItemCount), ",\n")
    handle:write("    worldItemCount = ", tostring(worldItemCount), ",\n")
    handle:write("    expansions = {\n")
    handle:write("        currentID = 12,\n")
    handle:write("        options = {\n")
    for _, expansionID in ipairs(sortedKeys(EXPANSION_LABELS)) do
        handle:write("            { id = ", tostring(expansionID), ", label = ", luaString(EXPANSION_LABELS[expansionID]), ", current = ", expansionID == 12 and "true" or "false", " },\n")
    end
    handle:write("        },\n")
    handle:write("    },\n")
    handle:write("    instances = {\n")
    for _, instanceID in ipairs(sortedKeys(instances)) do
        local instance = instances[instanceID]
        handle:write("        [", tostring(instanceID), "] = { journalInstanceID = ", tostring(instanceID))
        handle:write(", name = ", luaString(instance.name))
        handle:write(", expansionID = ", tostring(instance.expansionID))
        handle:write(", expansion = ", luaString(instance.expansion))
        handle:write(", contentType = ", luaString(instance.contentType))
        if instance.mapID then
            handle:write(", mapID = ", tostring(instance.mapID))
        end
        handle:write(", items = {\n")
        for _, itemID in ipairs(sortedKeys(instance.items)) do
            writeItem(handle, instance.items[itemID], "            ")
        end
        handle:write("        } },\n")
    end
    handle:write("    },\n")
    handle:write("    zones = {\n")
    for _, mapID in ipairs(sortedKeys(zones)) do
        local zone = zones[mapID]
        handle:write("        [", tostring(mapID), "] = { mapID = ", tostring(mapID))
        handle:write(", expansionID = ", tostring(zone.expansionID))
        handle:write(", expansion = ", luaString(zone.expansion))
        handle:write(", items = {\n")
        for _, itemID in ipairs(sortedKeys(zone.items)) do
            writeItem(handle, zone.items[itemID], "            ")
        end
        handle:write("        } },\n")
    end
    handle:write("    },\n")
    handle:write("    world = {\n")
    handle:write("        items = {\n")
    for _, itemID in ipairs(sortedKeys(worldItems)) do
        writeItem(handle, worldItems[itemID], "            ")
    end
    handle:write("        },\n")
    handle:write("    },\n")
    handle:write("}\n")
    handle:close()

    print(string.format(
        "Wrote %s with %d instances/%d instance items, %d zones/%d zone items, and %d world items.",
        outputPath,
        #sortedKeys(instances),
        instanceItemCount,
        #sortedKeys(zones),
        zoneItemCount,
        worldItemCount
    ))
end

writeSnapshot()
