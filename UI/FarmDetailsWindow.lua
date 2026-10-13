local _, NS = ...
local GoldTracker = NS.GoldTracker
local Theme = NS.JanisTheme

local FARM_DETAILS_WIDTH = 760
local FARM_DETAILS_HEIGHT = 620
local FARM_DETAILS_MIN_WIDTH = 620
local FARM_DETAILS_MIN_HEIGHT = 440
local FARM_DETAILS_MAX_WIDTH = 1100
local FARM_DETAILS_MAX_HEIGHT = 900
local FARM_SUMMARY_HEIGHT = 116
local MAX_VISIBLE_TARGETS = 80
local FARM_ITEM_DATA_REQUEST_TTL = 1
local RARE_BONUS_MAX_RECORDED_QUANTITY = 1
local RARE_BONUS_MIN_VALUE_SHARE = 0.50
local MAX_MAP_RECORDED_YIELDS = 10
local FARM_VALUATION_ASYNC_BUDGET_MS = 4
local FARM_VALUATION_ASYNC_FALLBACK_BATCH_SIZE = 2

local farmItemDataRequests = {}

local ACTIVITY_GUIDES = {
    mining = {
        label = "Mining",
        requirement = "Mining profession recommended.",
        action = "Mine ore nodes while following the route loop.",
        tips = {
            "Use a gathering-enchant or mounted gathering option when available.",
            "If another player is clearing the same loop, reverse direction or switch route.",
        },
    },
    herbalism = {
        label = "Herbalism",
        requirement = "Herbalism profession required.",
        action = "Gather herb nodes while following the route loop.",
        tips = {
            "Use a gathering-enchant or mounted gathering option when available.",
            "Track herbs on the minimap and avoid long detours from the route.",
        },
    },
    fishing = {
        label = "Fishing",
        requirement = "Fishing is recommended; some targets may require expansion-specific skill.",
        action = "Fish the marked waters or pools along the route.",
        tips = {
            "Prioritize visible pools when the target can be caught from them.",
            "Recorded yields vary with pool availability and travel time.",
        },
    },
    skinning = {
        label = "Skinning",
        requirement = "Skinning profession required.",
        action = "Kill and skin suitable creatures along the route.",
        tips = {
            "Keep moving between dense packs instead of waiting on a single spawn point.",
            "Loot creatures before skinning so the corpses become eligible.",
        },
    },
    cloth = {
        label = "Cloth",
        requirement = "Tailoring may improve cloth yields in some expansions.",
        action = "Kill humanoid packs along the marked loop.",
        tips = {
            "Favor fast, repeatable pulls and include respawn time when judging results.",
            "Check that the selected targets are still tradeable before committing to a long run.",
        },
    },
    ["multi-farm"] = {
        label = "Multi-farm",
        requirement = "Mining and Herbalism are recommended for the complete route.",
        action = "Gather both ore and herbs while following the route loop.",
        tips = {
            "Enable both profession tracking modes on the minimap.",
            "Judge the route by its combined yield, not one material in isolation.",
        },
    },
    miscellaneous = {
        label = "Miscellaneous",
        requirement = "Review the expected targets before starting.",
        action = "Follow the marked route and collect the listed targets.",
        tips = {
            "Use the recorded yields as a comparison sample, not a guaranteed result.",
        },
    },
    transmog = {
        label = "Transmog",
        requirement = "Check instance access, difficulty, and lockout rules before starting.",
        action = "Clear the listed dungeon or raid and collect tradeable appearances.",
        tips = {
            "Auction values are potential asset values, not guaranteed liquid gold.",
            "Compare several runs before treating an estimated value per hour as representative.",
        },
    },
}

local function HasText(value)
    return type(value) == "string" and value ~= ""
end

local function CreatePanel(parent, bg, border)
    return Theme:CreatePanel(parent, bg, border)
end

local function CreateButton(parent, width, height, text, paletteKey)
    return Theme:CreateButton(parent, width, height, text, paletteKey or "neutral")
end

local function GetFarmCatalog()
    return type(NS.FarmCatalog) == "table" and NS.FarmCatalog or {
        farms = {},
        byID = {},
        indexes = { byItemID = {} },
    }
end

local function NormalizeItemID(itemID)
    itemID = tonumber(itemID)
    return itemID and math.floor(itemID + 0.5) or nil
end

local function NormalizePetID(petID)
    petID = tonumber(petID)
    return petID and math.floor(petID + 0.5) or nil
end

local function IsCuratedResearchFarm(farm)
    return type(farm) == "table"
        and (farm.sourceDataset == "GGTMountFarmData"
            or farm.sourceDataset == "GGTPetFarmData"
            or farm.sourceDataset == "GGTToyFarmData")
end

local function GetCuratedResearchLabel(farm)
    if farm and farm.sourceDataset == "GGTPetFarmData" then
        return "GGT researched pet guide"
    end
    if farm and farm.sourceDataset == "GGTToyFarmData" then
        return "GGT researched toy guide"
    end
    return "GGT researched mount guide"
end

local function GetCuratedResearchFallbackSummary(farm)
    if farm and farm.sourceDataset == "GGTPetFarmData" then
        return "Curated pet farm."
    end
    if farm and farm.sourceDataset == "GGTToyFarmData" then
        return "Curated toy farm."
    end
    return "Curated mount farm."
end

local function GetFarmGuide(farm)
    if type(farm) == "table" and type(farm.guide) == "table" then
        local fallback = ACTIVITY_GUIDES[farm.activity] or ACTIVITY_GUIDES.miscellaneous
        return {
            label = HasText(farm.guide.label) and farm.guide.label or fallback.label,
            requirement = HasText(farm.guide.requirement) and farm.guide.requirement or fallback.requirement,
            action = HasText(farm.guide.action) and farm.guide.action or fallback.action,
            tips = type(farm.guide.tips) == "table" and farm.guide.tips or fallback.tips,
        }
    end
    return ACTIVITY_GUIDES[farm and farm.activity] or ACTIVITY_GUIDES.miscellaneous
end

local function GetFarmSourceURLs(farm)
    local urls = {}
    for _, source in ipairs(type(farm) == "table" and farm.sourceUrls or {}) do
        local url = type(source) == "table" and source.url or source
        if HasText(url) then
            urls[#urls + 1] = url
        end
    end
    return urls
end

local function GetFarmPrimarySourceURL(farm)
    local urls = GetFarmSourceURLs(farm)
    return urls[1]
end

local function GetFarmPositionByID(farmID)
    local catalog = GetFarmCatalog()
    local position = catalog.byID and catalog.byID[farmID]
    return tonumber(position)
end

local function GetItemInfoSafe(itemID)
    local name
    local link
    if type(C_Item) == "table" and type(C_Item.GetItemInfo) == "function" then
        local ok, itemName, itemLink = pcall(C_Item.GetItemInfo, itemID)
        if ok then
            name = itemName
            link = itemLink
        end
    elseif type(GetItemInfo) == "function" then
        local ok, itemName, itemLink = pcall(GetItemInfo, itemID)
        if ok then
            name = itemName
            link = itemLink
        end
    end
    return name or ("Item " .. tostring(itemID)), link or ("item:" .. tostring(itemID)), HasText(name)
end

local function GetFarmTargetItemMetadata(itemID)
    local metadata = {}
    if type(C_Item) == "table" and type(C_Item.GetItemInfo) == "function" then
        local results = { pcall(C_Item.GetItemInfo, itemID) }
        if results[1] then
            metadata.className = results[7]
            metadata.subclassName = results[8]
            metadata.classID = tonumber(results[13])
            metadata.subclassID = tonumber(results[14])
            metadata.isCraftingReagent = results[18] == true
        end
    end

    if metadata.classID == nil then
        local instantGetter = type(C_Item) == "table" and C_Item.GetItemInfoInstant or GetItemInfoInstant
        if type(instantGetter) == "function" then
            local ok, _, itemClassName, itemSubclassName, _, _, classID, subclassID = pcall(instantGetter, itemID)
            if ok then
                metadata.className = metadata.className or itemClassName
                metadata.subclassName = metadata.subclassName or itemSubclassName
                metadata.classID = tonumber(classID)
                metadata.subclassID = tonumber(subclassID)
            end
        end
    end
    return metadata
end

local FARM_TARGET_TYPE_BY_CLASS = {
    [1] = "Container",
    [2] = "Weapon",
    [3] = "Gem",
    [4] = "Armor",
    [5] = "Reagent",
    [6] = "Projectile",
    [9] = "Recipe",
    [10] = "Currency",
    [12] = "Quest item",
    [13] = "Key",
    [15] = "Miscellaneous",
    [16] = "Glyph",
    [17] = "Battle pet",
}

local CONSUMABLE_TYPE_BY_SUBCLASS = {
    [1] = "Potion",
    [2] = "Elixir",
    [3] = "Flask",
    [4] = "Scroll",
    [5] = "Food & Drink",
    [8] = "Bandage",
}

local TRADE_GOOD_TYPE_BY_SUBCLASS = {
    [5] = "Cloth",
    [6] = "Leather",
    [7] = "Ore",
    [8] = "Cooking",
    [9] = "Herb",
}

local function GetFarmTargetItemType(metadata)
    local classID = tonumber(metadata and metadata.classID)
    local subclassID = tonumber(metadata and metadata.subclassID)
    if classID == 0 and CONSUMABLE_TYPE_BY_SUBCLASS[subclassID] then
        return CONSUMABLE_TYPE_BY_SUBCLASS[subclassID]
    end
    if classID == 7 and TRADE_GOOD_TYPE_BY_SUBCLASS[subclassID] then
        return TRADE_GOOD_TYPE_BY_SUBCLASS[subclassID]
    end
    if FARM_TARGET_TYPE_BY_CLASS[classID] then
        return FARM_TARGET_TYPE_BY_CLASS[classID]
    end
    if HasText(metadata and metadata.subclassName) then
        return metadata.subclassName
    end
    if HasText(metadata and metadata.className) then
        return metadata.className
    end
    return "Other"
end

local function GetFarmTargetFilterCategory(metadata, itemType)
    local classID = tonumber(metadata and metadata.classID)
    if classID == 2 or classID == 4 then
        return "equipment"
    end
    if metadata and metadata.isCraftingReagent == true then
        return "reagents"
    end
    if classID == 3 or classID == 5 or classID == 7 or classID == 8 then
        return "reagents"
    end
    if itemType == "Ore" or itemType == "Herb" or itemType == "Cloth" or itemType == "Leather" then
        return "reagents"
    end
    return "other"
end

local function RequestItemData(itemID, isLoaded)
    itemID = NormalizeItemID(itemID)
    if not itemID or isLoaded == true or farmItemDataRequests[itemID] then
        return false
    end
    if type(C_Item) == "table" and type(C_Item.RequestLoadItemDataByID) == "function" then
        local request = {}
        farmItemDataRequests[itemID] = request
        local ok = pcall(C_Item.RequestLoadItemDataByID, itemID)
        if not ok then
            farmItemDataRequests[itemID] = nil
            return false
        end
        return true
    end
    return false
end

function GoldTracker:IsFarmItemDataRequest(itemID)
    return farmItemDataRequests[NormalizeItemID(itemID)] ~= nil
end

function GoldTracker:CompleteFarmItemDataRequest(itemID)
    itemID = NormalizeItemID(itemID)
    local request = itemID and farmItemDataRequests[itemID] or nil
    if not request then
        return false
    end
    if request.completed then
        return false
    end

    request.completed = true
    if type(C_Timer) == "table" and type(C_Timer.After) == "function" then
        C_Timer.After(FARM_ITEM_DATA_REQUEST_TTL, function()
            if farmItemDataRequests[itemID] == request then
                farmItemDataRequests[itemID] = nil
            end
        end)
    else
        farmItemDataRequests[itemID] = nil
    end
    return true
end

local function FormatQuantity(value)
    value = tonumber(value) or 0
    if math.floor(value) == value then
        return tostring(math.floor(value))
    end
    return string.format("%.2f", value):gsub("0+$", ""):gsub("%.$", "")
end

local function FormatDuration(seconds)
    seconds = math.max(0, tonumber(seconds) or 0)
    if seconds >= 3600 then
        local hours = seconds / 3600
        if math.floor(hours) == hours then
            return string.format("%d hour%s", hours, hours == 1 and "" or "s")
        end
        return string.format("%.1f hours", hours)
    end
    return string.format("%d minutes", math.max(1, math.floor((seconds / 60) + 0.5)))
end

local function Join(values, fallback)
    if type(values) ~= "table" or #values == 0 then
        return fallback
    end
    return table.concat(values, ", ")
end

function GoldTracker:GetFarmsForItem(itemID)
    local normalizedItemID = NormalizeItemID(itemID)
    if not normalizedItemID then
        return {}
    end

    local catalog = GetFarmCatalog()
    local positions = catalog.indexes and catalog.indexes.byItemID and catalog.indexes.byItemID[normalizedItemID]
    local farms = {}
    local seen = {}
    for _, position in ipairs(positions or {}) do
        local farm = catalog.farms and catalog.farms[tonumber(position)]
        if type(farm) == "table" and HasText(farm.id) and not seen[farm.id] then
            seen[farm.id] = true
            farms[#farms + 1] = farm
        end
    end

    table.sort(farms, function(left, right)
        local leftPrimary = tonumber(left.primaryItemID) == normalizedItemID
        local rightPrimary = tonumber(right.primaryItemID) == normalizedItemID
        if leftPrimary ~= rightPrimary then
            return leftPrimary
        end
        local leftGathering = left.sourceType == "gathering"
        local rightGathering = right.sourceType == "gathering"
        if leftGathering ~= rightGathering then
            return leftGathering
        end
        local leftRouted = (tonumber(left.routeCount) or 0) > 0
        local rightRouted = (tonumber(right.routeCount) or 0) > 0
        if leftRouted ~= rightRouted then
            return leftRouted
        end
        return string.lower(left.name or left.id) < string.lower(right.name or right.id)
    end)
    return farms
end

function GoldTracker:HasFarmForItem(itemID)
    local normalizedItemID = NormalizeItemID(itemID)
    if not normalizedItemID then
        return false, 0
    end
    local catalog = GetFarmCatalog()
    local positions = catalog.indexes and catalog.indexes.byItemID and catalog.indexes.byItemID[normalizedItemID]
    local count = type(positions) == "table" and #positions or 0
    return count > 0, count
end

function GoldTracker:GetFarmsForPet(petID)
    local normalizedPetID = NormalizePetID(petID)
    if not normalizedPetID then
        return {}
    end

    local catalog = GetFarmCatalog()
    local positions = catalog.indexes and catalog.indexes.byPetID and catalog.indexes.byPetID[normalizedPetID]
    local farms = {}
    local seen = {}
    for _, position in ipairs(positions or {}) do
        local farm = catalog.farms and catalog.farms[tonumber(position)]
        if type(farm) == "table" and HasText(farm.id) and not seen[farm.id] then
            seen[farm.id] = true
            farms[#farms + 1] = farm
        end
    end
    table.sort(farms, function(left, right)
        return string.lower(left.name or left.id) < string.lower(right.name or right.id)
    end)
    return farms
end

function GoldTracker:HasFarmForPet(petID)
    local normalizedPetID = NormalizePetID(petID)
    if not normalizedPetID then
        return false, 0
    end
    local catalog = GetFarmCatalog()
    local positions = catalog.indexes and catalog.indexes.byPetID and catalog.indexes.byPetID[normalizedPetID]
    local count = type(positions) == "table" and #positions or 0
    return count > 0, count
end

function GoldTracker:GetFarmsForRecordID(recordID)
    if not HasText(recordID) then
        return {}
    end
    local catalog = GetFarmCatalog()
    local positions = catalog.indexes and catalog.indexes.byRecordID and catalog.indexes.byRecordID[recordID]
    local farms = {}
    local seen = {}
    for _, position in ipairs(positions or {}) do
        local farm = catalog.farms and catalog.farms[tonumber(position)]
        if type(farm) == "table" and HasText(farm.id) and not seen[farm.id] then
            seen[farm.id] = true
            farms[#farms + 1] = farm
        end
    end
    return farms
end

function GoldTracker:HasFarmForRecordID(recordID)
    local farms = self:GetFarmsForRecordID(recordID)
    return #farms > 0, #farms
end

local function ResolveFarmActionItemID(itemLinkOrRow, fallbackItemID)
    local itemID = fallbackItemID
    local itemLink = itemLinkOrRow
    if type(itemLinkOrRow) == "table" then
        itemID = itemLinkOrRow.itemID or fallbackItemID
        itemLink = itemLinkOrRow.itemLink
    end
    itemID = NormalizeItemID(itemID)
    if not itemID and type(itemLink) == "string" then
        itemID = NormalizeItemID(itemLink:match("item:(%d+)"))
    end
    return itemID
end

function GoldTracker:AddFarmActionTooltip(tooltip, itemLinkOrRow, fallbackItemID)
    local itemID = ResolveFarmActionItemID(itemLinkOrRow, fallbackItemID)
    local hasFarm, farmCount = self:HasFarmForItem(itemID)
    if not hasFarm or not tooltip or type(tooltip.AddLine) ~= "function" then
        return false
    end
    tooltip:AddLine(" ")
    tooltip:AddLine(
        string.format("Alt-click: Open Farm map (%d match%s)", farmCount, farmCount == 1 and "" or "es"),
        0.45,
        0.92,
        1.0
    )
    return true
end

function GoldTracker:HandleFarmActionClick(itemLinkOrRow, button, fallbackItemID)
    if button and button ~= "LeftButton" then
        return false
    end
    if type(IsAltKeyDown) ~= "function" or not IsAltKeyDown() then
        return false
    end
    local itemID = ResolveFarmActionItemID(itemLinkOrRow, fallbackItemID)
    if not self:HasFarmForItem(itemID) then
        return false
    end
    return self:OpenFarmDetailsForItem(itemID) == true
end

function GoldTracker:GetFarmByID(farmID)
    local catalog = GetFarmCatalog()
    local position = GetFarmPositionByID(farmID)
    return position and catalog.farms and catalog.farms[position] or nil
end

local function IsRouteMaterialFarm(farm)
    if type(farm) ~= "table" then
        return false
    end

    return farm.sourceCategory == "Herb" or farm.sourceCategory == "Mining"
end

local function BuildMaterialFallbackMapOptions(addon, farm)
    local itemID = NormalizeItemID(farm and farm.primaryItemID)
    if not itemID or type(addon.BuildMaterialFarmingMapOptions) ~= "function" then
        return {}
    end

    local options = addon:BuildMaterialFarmingMapOptions(itemID) or {}
    for optionIndex, option in ipairs(options) do
        if type(option) == "table" then
            option.id = tostring(farm.id) .. ":material:" .. tostring(option.id or optionIndex)
            option.sourceLabel = "Related researched material location"
            option.mapOnly = #(option.pins or {}) == 0
            for _, pin in ipairs(option.pins or {}) do
                pin.sourceLabel = "Related researched material location"
                pin.farmAction = pin.farmAction or "Farm the related material at this location."
            end
        end
    end
    return options
end

local function BuildInstanceEntranceMapOption(addon, farm)
    if type(addon.ResolveCatalogFarmInstanceEntrance) ~= "function" then
        return nil
    end

    local entrance = addon:ResolveCatalogFarmInstanceEntrance(farm)
    if type(entrance) ~= "table" or not tonumber(entrance.mapID)
        or not tonumber(entrance.x) or not tonumber(entrance.y)
    then
        return nil
    end

    return {
        id = tostring(farm.id) .. ":entrance:" .. tostring(entrance.mapID),
        mapID = entrance.mapID,
        mapLabel = entrance.mapName or farm.name or ("Map " .. tostring(entrance.mapID)),
        label = entrance.label or ((farm.name or "Instance") .. " entrance"),
        location = entrance.label or farm.name,
        sourceType = "static",
        sourceLabel = "Encounter Journal entrance",
        pins = {
            {
                mapID = entrance.mapID,
                x = entrance.x,
                y = entrance.y,
                label = entrance.label or ((farm.name or "Instance") .. " entrance"),
                itemName = farm.name,
                spotLocation = entrance.label or farm.name,
                isRoute = false,
                routeType = "instance-entrance",
                density = "Instance entrance",
                dropDifficulty = "Enter the instance to begin this farm.",
                sourceType = "static",
                sourceLabel = "Encounter Journal entrance",
            },
        },
    }
end

function GoldTracker:BuildFarmRouteMapOptions(farm)
    if type(farm) ~= "table" then
        return {}
    end

    if type(farm.mapOptions) == "table" then
        local guide = GetFarmGuide(farm)
        local sourceUrls = GetFarmSourceURLs(farm)
        local isCurated = IsCuratedResearchFarm(farm)
        local sourceType = isCurated and "curated" or "static"
        local sourceLabel = isCurated and GetCuratedResearchLabel(farm)
            or farm.locationResearchSource or "GGT researched map location"
        local options = {}
        for optionIndex, sourceOption in ipairs(farm.mapOptions) do
            local mapID = tonumber(sourceOption and sourceOption.mapID)
            if mapID then
                local option = {
                    id = sourceOption.id or (farm.id .. ":route:" .. tostring(optionIndex)),
                    mapID = mapID,
                    mapLabel = sourceOption.mapLabel or sourceOption.label or farm.name,
                    label = sourceOption.label or sourceOption.mapLabel or farm.name,
                    mapRole = sourceOption.mapRole,
                    location = sourceOption.location or sourceOption.label or farm.name,
                    sourceType = sourceType,
                    sourceLabel = sourceLabel,
                    pins = {},
                }
                for pointIndex, sourcePin in ipairs(type(sourceOption.pins) == "table" and sourceOption.pins or {}) do
                    local x = tonumber(sourcePin and sourcePin.x)
                    local y = tonumber(sourcePin and sourcePin.y)
                    if x and y and x >= 0 and x <= 1 and y >= 0 and y <= 1 then
                        local isRoute = IsRouteMaterialFarm(farm) and sourceOption.isRoute ~= false
                        option.pins[#option.pins + 1] = {
                            mapID = mapID,
                            x = x,
                            y = y,
                            label = sourcePin.label or ("Farm point " .. tostring(pointIndex)),
                            itemName = farm.name,
                            spotLocation = sourceOption.location or sourceOption.label or farm.name,
                            farmAction = guide.action,
                            isRoute = isRoute,
                            routeID = isRoute and option.id or nil,
                            routeType = sourceOption.routeType or (farm.activity == "pet" and "farm-pet"
                                or farm.activity == "toy" and "farm-toy"
                                or "farm-" .. tostring(farm.activity or "location")),
                            density = sourceOption.density,
                            dropDifficulty = sourceOption.dropDifficulty,
                            tips = guide.tips,
                            sourceUrls = sourceUrls,
                            sourceType = sourceType,
                            sourceLabel = sourceLabel,
                        }
                    end
                end
                option.mapOnly = #option.pins == 0
                options[#options + 1] = option
            end
        end
        return options
    end

    if farm.sourceDataset ~= "CatalogGatheringData" then
        local entranceOption = BuildInstanceEntranceMapOption(self, farm)
        if entranceOption then
            return { entranceOption }
        end

        local options = {}
        local seenMapIDs = {}
        for index, rawMapID in ipairs(farm.mapIDs or {}) do
            local mapID = tonumber(rawMapID)
            if mapID and not seenMapIDs[mapID] then
                seenMapIDs[mapID] = true
                local mapLabel = farm.mapNames and farm.mapNames[index] or nil
                options[#options + 1] = {
                    id = farm.id .. ":map:" .. tostring(mapID),
                    mapID = mapID,
                    mapLabel = mapLabel or farm.name or ("Map " .. tostring(mapID)),
                    label = mapLabel or farm.name or ("Map " .. tostring(mapID)),
                    location = mapLabel or farm.name,
                    sourceType = "static",
                    sourceLabel = "GGT bundled farm snapshot",
                    mapOnly = true,
                    pins = {},
                }
            end
        end
        return options
    end

    local gathering = NS.CatalogGatheringData
    local records = type(gathering) == "table" and gathering.farmsByRecordID or nil
    if type(records) ~= "table" then
        return {}
    end

    local guide = GetFarmGuide(farm)
    local catalog = GetFarmCatalog()
    local options = {}
    local seenRoutes = {}
    local isRoute = IsRouteMaterialFarm(farm)
    for _, recordID in ipairs(farm.sourceRecordIDs or {}) do
        local record = records[recordID]
        for routeIndex, route in ipairs(type(record) == "table" and record.routes or {}) do
            local coords = type(route) == "table" and route.coords or nil
            local mapID = tonumber(route and route.mapID)
            local first = type(coords) == "table" and coords[1] or nil
            local last = type(coords) == "table" and coords[#coords] or nil
            local routeKey = table.concat({
                tostring(mapID or ""),
                tostring(route and route.name or routeIndex),
                tostring(#(coords or {})),
                tostring(first and first.x or ""),
                tostring(first and first.y or ""),
                tostring(last and last.x or ""),
                tostring(last and last.y or ""),
            }, ":")
            if mapID and type(coords) == "table" and #coords > 0 and not seenRoutes[routeKey] then
                seenRoutes[routeKey] = true
                local option = {
                    id = farm.id .. ":route:" .. tostring(#options + 1),
                    mapID = mapID,
                    mapLabel = route.mapName or ("Map " .. tostring(mapID)),
                    label = route.name or farm.name,
                    location = route.name or farm.name,
                    sourceType = "static",
                    sourceLabel = "GGT bundled farm snapshot",
                    pins = {},
                }
                for pointIndex, coord in ipairs(coords) do
                    local x = tonumber(coord and coord.x)
                    local y = tonumber(coord and coord.y)
                    if x and y and x >= 0 and x <= 1 and y >= 0 and y <= 1 then
                        option.pins[#option.pins + 1] = {
                            mapID = mapID,
                            x = x,
                            y = y,
                            label = coord.label or ("Route point " .. tostring(pointIndex)),
                            itemName = farm.name,
                            spotLocation = route.name or farm.name,
                            farmAction = guide.action,
                            isRoute = isRoute,
                            routeID = isRoute and option.id or nil,
                            routeType = "farm-" .. tostring(farm.activity or "route"),
                            density = "Recorded farm route",
                            dropDifficulty = "Yield varies with competition, profession skill, and character setup.",
                            tips = guide.tips,
                            sourceUrls = HasText(catalog.sourceURL) and { catalog.sourceURL } or nil,
                            sourceType = "static",
                            sourceLabel = "GGT bundled farm snapshot",
                        }
                    end
                end
                if #option.pins > 0 then
                    options[#options + 1] = option
                end
            end
        end
    end
    if #options == 0 then
        return BuildMaterialFallbackMapOptions(self, farm)
    end

    return options
end

local function AppendMapDetailLine(lines, text, r, g, b, gap, fontObject)
    if HasText(text) then
        lines[#lines + 1] = {
            type = "text",
            text = text,
            r = r or 0.82,
            g = g or 0.86,
            b = b or 0.92,
            gap = gap or 4,
            fontObject = fontObject,
        }
    end
end

local function BuildCuratedFarmMapDetailLines(farm, mapLabel)
    local lines = {}
    local guide = GetFarmGuide(farm)
    AppendMapDetailLine(lines, mapLabel or Join(farm.mapNames, "Mapped farm"), 1.0, 0.82, 0.18, 8, "GameFontNormalLarge")
    AppendMapDetailLine(
        lines,
        string.format("%s | %s", guide.label, farm.expansion or "Unknown expansion"),
        0.68,
        0.72,
        0.80,
        8,
        "GameFontHighlight"
    )

    AppendMapDetailLine(lines, "Overview", 1.0, 0.82, 0.18, 4, "GameFontNormal")
    AppendMapDetailLine(lines, farm.summary, 0.82, 0.86, 0.92, 8, "GameFontHighlight")

    AppendMapDetailLine(lines, "How to farm", 1.0, 0.82, 0.18, 4, "GameFontNormal")
    AppendMapDetailLine(lines, guide.action, 1.0, 0.45, 0.20, 4, "GameFontHighlight")
    AppendMapDetailLine(lines, guide.requirement, 0.72, 0.86, 1.0, 8, "GameFontHighlight")

    if type(farm.details) == "table" and #farm.details > 0 then
        AppendMapDetailLine(lines, "Details", 1.0, 0.82, 0.18, 4, "GameFontNormal")
        for _, detail in ipairs(farm.details) do
            AppendMapDetailLine(lines, "- " .. tostring(detail), 0.82, 0.86, 0.92, 4, "GameFontHighlight")
        end
    end

    AppendMapDetailLine(lines, "Tips", 1.0, 0.82, 0.18, 4, "GameFontNormal")
    for _, tip in ipairs(guide.tips or {}) do
        AppendMapDetailLine(lines, "- " .. tip, 0.82, 0.86, 0.92, 4, "GameFontHighlight")
    end

    for _, source in ipairs(farm.sourceUrls or {}) do
        if type(source) == "table" and HasText(source.url) then
            lines[#lines + 1] = {
                type = "source",
                siteName = HasText(source.siteName) and source.siteName or "Research source",
                url = source.url,
                gap = 4,
            }
        end
    end
    return lines
end

local function AppendMapDetailFarmTarget(
    lines,
    itemID,
    itemLink,
    itemName,
    itemType,
    quantity,
    totalValue,
    totalValueText,
    selected
)
    lines[#lines + 1] = {
        type = "farmTarget",
        itemID = itemID,
        itemLink = itemLink,
        itemName = itemName,
        itemType = itemType,
        quantity = tonumber(quantity) or 0,
        quantityText = "x" .. FormatQuantity(quantity),
        totalValue = tonumber(totalValue) or 0,
        totalValueText = totalValueText,
        selected = selected == true,
        gap = 3,
    }
end

local function GetFarmValuationTarget(valuationSnapshot, itemID)
    local normalizedItemID = NormalizeItemID(itemID)
    if type(valuationSnapshot) ~= "table" or not normalizedItemID then
        return nil
    end
    for _, target in ipairs(valuationSnapshot.targets or {}) do
        if NormalizeItemID(target.itemID) == normalizedItemID then
            return target
        end
    end
    return nil
end

local function GetFarmTargetTotalValue(valuationSnapshot, itemID)
    local target = GetFarmValuationTarget(valuationSnapshot, itemID)
    if not target or (tonumber(target.unitValue) or 0) <= 0 then
        return 0
    end
    return math.floor((tonumber(target.sampleValue) or 0) + 0.5)
end

local function FormatFarmTargetTotalValue(addon, valuationSnapshot, itemID)
    local totalValue = GetFarmTargetTotalValue(valuationSnapshot, itemID)
    return totalValue > 0 and addon:FormatMoney(totalValue) or "unavailable"
end

local FARM_TARGET_FILTER_OPTIONS = {
    { id = "all", label = "All" },
    { id = "reagents", label = "Reagents" },
    { id = "equipment", label = "Armor and Weapons" },
    { id = "other", label = "Other" },
}

local FARM_TARGET_FILTERS = {
    all = true,
    reagents = true,
    equipment = true,
    other = true,
}

local FARM_TARGET_SORT_KEYS = {
    itemName = true,
    itemType = true,
    quantity = true,
    totalValue = true,
}

local function SortFarmMapTargets(targets, sortKey, sortAscending)
    table.sort(targets, function(left, right)
        local leftValue = left[sortKey]
        local rightValue = right[sortKey]
        if type(leftValue) == "string" then
            leftValue = string.lower(leftValue)
            rightValue = string.lower(tostring(rightValue or ""))
        else
            leftValue = tonumber(leftValue) or 0
            rightValue = tonumber(rightValue) or 0
        end
        if leftValue == rightValue then
            return left.sourceIndex < right.sourceIndex
        end
        if sortAscending == true then
            return leftValue < rightValue
        end
        return leftValue > rightValue
    end)
end

local function BuildFarmMapTarget(addon, target, sourceIndex, normalizedSelectedItemID, valuationSnapshot)
    local itemID = NormalizeItemID(target and target.itemID)
    if not itemID then
        return nil
    end
    local itemName, itemLink, isLoaded = GetItemInfoSafe(itemID)
    RequestItemData(itemID, isLoaded)
    local metadata = GetFarmTargetItemMetadata(itemID)
    local itemType = GetFarmTargetItemType(metadata)
    local targetValue = GetFarmTargetTotalValue(valuationSnapshot, itemID)
    return {
        itemID = itemID,
        itemLink = itemLink,
        itemName = itemName,
        itemType = itemType,
        filterCategory = GetFarmTargetFilterCategory(metadata, itemType),
        quantity = tonumber(target.quantity) or 0,
        totalValue = targetValue,
        totalValueText = targetValue > 0 and addon:FormatMoney(targetValue) or "unavailable",
        selected = itemID == normalizedSelectedItemID,
        sourceIndex = sourceIndex,
    }
end

local function BuildFarmMapTargets(addon, farm, selectedItemID, valuationSnapshot, targetFilter)
    local targets = {}
    local normalizedSelectedItemID = NormalizeItemID(selectedItemID)
    for sourceIndex, target in ipairs(farm.targets or {}) do
        local entry = BuildFarmMapTarget(addon, target, sourceIndex, normalizedSelectedItemID, valuationSnapshot)
        if entry and (targetFilter == "all" or targetFilter == entry.filterCategory) then
            targets[#targets + 1] = entry
        end
    end
    return targets
end

local function GetTopFarmTargetsByQuantity(farm, limit)
    local candidates = {}
    for sourceIndex, target in ipairs(farm.targets or {}) do
        if NormalizeItemID(target.itemID) then
            candidates[#candidates + 1] = {
                target = target,
                sourceIndex = sourceIndex,
                quantity = tonumber(target.quantity) or 0,
            }
        end
    end
    table.sort(candidates, function(left, right)
        if left.quantity == right.quantity then
            return left.sourceIndex < right.sourceIndex
        end
        return left.quantity > right.quantity
    end)

    local limited = {}
    for index = 1, math.min(#candidates, tonumber(limit) or #candidates) do
        limited[index] = candidates[index]
    end
    return limited, #candidates
end

local function BuildTopFarmMapTargetsByQuantity(addon, farm, selectedItemID, valuationSnapshot, limit)
    local candidates, totalTargetCount = GetTopFarmTargetsByQuantity(farm, limit)

    local targets = {}
    local normalizedSelectedItemID = NormalizeItemID(selectedItemID)
    for _, candidate in ipairs(candidates) do
        local entry = BuildFarmMapTarget(
            addon,
            candidate.target,
            candidate.sourceIndex,
            normalizedSelectedItemID,
            valuationSnapshot
        )
        if entry then
            targets[#targets + 1] = entry
        end
    end
    return targets, totalTargetCount
end

local function AppendFarmMapTargetRows(lines, targets, maximumRows)
    local rowCount = math.min(#targets, tonumber(maximumRows) or #targets)
    for index = 1, rowCount do
        local entry = targets[index]
        AppendMapDetailFarmTarget(
            lines,
            entry.itemID,
            entry.itemLink,
            entry.itemName,
            entry.itemType,
            entry.quantity,
            entry.totalValue,
            entry.totalValueText,
            entry.selected
        )
    end
end

function GoldTracker:BuildFarmRecordedYieldLines(farm, selectedItemID, valuationSnapshot, options)
    options = type(options) == "table" and options or {}
    if type(farm) ~= "table" then
        return {
            { type = "text", text = "Farm data is unavailable.", r = 0.72, g = 0.76, b = 0.84 },
        }
    end

    valuationSnapshot = valuationSnapshot or self:BuildFarmValuationSnapshot(farm)
    local targetFilter = FARM_TARGET_FILTERS[options.targetFilter] and options.targetFilter or "all"
    local targetSortKey = FARM_TARGET_SORT_KEYS[options.targetSortKey] and options.targetSortKey or "itemName"
    local targetSortAscending = options.targetSortAscending ~= false
    local targets = BuildFarmMapTargets(self, farm, selectedItemID, valuationSnapshot, targetFilter)
    SortFarmMapTargets(targets, targetSortKey, targetSortAscending)

    local lines = {
        {
            type = "farmTargetFilter",
            selectedFilter = targetFilter,
            filterOptions = FARM_TARGET_FILTER_OPTIONS,
            onSelect = options.onTargetFilterChanged,
            gap = 3,
        },
        {
            type = "farmTargetHeader",
            sortKey = targetSortKey,
            sortAscending = targetSortAscending,
            onSort = options.onTargetSortChanged,
            gap = 2,
        },
    }
    AppendFarmMapTargetRows(lines, targets)
    if #targets == 0 then
        local emptyText = #(farm.targets or {}) == 0
            and "No recorded item yields."
            or "No recorded items match this filter."
        AppendMapDetailLine(lines, emptyText, 0.72, 0.76, 0.84, 8, "GameFontDisable")
    end
    return lines
end

function GoldTracker:OpenFarmRecordedYieldsForFarm(farm, selectedItemID, valuationSnapshot, tableState)
    if type(farm) ~= "table" or type(self.OpenRecordedYieldsWindow) ~= "function" then
        return false
    end

    tableState = type(tableState) == "table" and tableState or {}
    tableState.filter = FARM_TARGET_FILTERS[tableState.filter] and tableState.filter or "all"
    tableState.sortKey = FARM_TARGET_SORT_KEYS[tableState.sortKey] and tableState.sortKey or "itemName"
    if tableState.sortAscending == nil then
        tableState.sortAscending = true
    end

    local previousRequest = self.recordedYieldsValuationRequest
    if previousRequest then
        previousRequest.cancelled = true
        if previousRequest.asyncTask then
            previousRequest.asyncTask.cancelled = true
        end
    end

    local addon = self
    local activeSnapshot = valuationSnapshot
    self:OpenRecordedYieldsWindow({
        title = farm.name or farm.id or "Farm",
        detailLinesBuilder = function()
            return addon:BuildFarmRecordedYieldLines(farm, selectedItemID, activeSnapshot, {
                targetFilter = tableState.filter,
                targetSortKey = tableState.sortKey,
                targetSortAscending = tableState.sortAscending,
                onTargetFilterChanged = function(filterID)
                    tableState.filter = filterID
                    addon:RefreshRecordedYieldsWindow()
                end,
                onTargetSortChanged = function(sortKey)
                    if tableState.sortKey == sortKey then
                        tableState.sortAscending = not tableState.sortAscending
                    else
                        tableState.sortKey = sortKey
                        tableState.sortAscending = sortKey == "itemName" or sortKey == "itemType"
                    end
                    addon:RefreshRecordedYieldsWindow()
                end,
            })
        end,
    })

    local _, totalTargetCount = GetTopFarmTargetsByQuantity(farm, 0)
    local snapshotTargetCount = type(activeSnapshot) == "table" and #(activeSnapshot.targets or {}) or 0
    if snapshotTargetCount < totalTargetCount then
        local request = { cancelled = false }
        self.recordedYieldsValuationRequest = request
        request.asyncTask = self:BuildFarmValuationSnapshotAsync(farm, function(completedSnapshot)
            if request.cancelled or addon.recordedYieldsValuationRequest ~= request then
                return
            end
            activeSnapshot = completedSnapshot
            addon.recordedYieldsValuationRequest = nil
            addon:RefreshRecordedYieldsWindow()
        end)
    else
        self.recordedYieldsValuationRequest = nil
    end
    return true
end

function GoldTracker:BuildFarmMapDetailLines(farm, selectedItemID, mapLabel, valuationSnapshot, options)
    local lines = {}
    if type(farm) ~= "table" then
        AppendMapDetailLine(lines, "Farm data is unavailable.", 0.72, 0.76, 0.84, 4, "GameFontDisable")
        return lines
    end

    if IsCuratedResearchFarm(farm) then
        return BuildCuratedFarmMapDetailLines(farm, mapLabel)
    end

    options = type(options) == "table" and options or {}
    local guide = GetFarmGuide(farm)
    local catalog = GetFarmCatalog()
    valuationSnapshot = valuationSnapshot or self:BuildFarmValuationSnapshot(farm)
    local totalValue, hourlyValue, pricedTargets, valueSourceLabel = self:GetFarmEstimatedValue(farm, valuationSnapshot)
    local selected = self:GetFarmSelectedMaterialSummary(farm, selectedItemID, valuationSnapshot)

    AppendMapDetailLine(lines, mapLabel or Join(farm.mapNames, "Mapped route"), 1.0, 0.82, 0.18, 8, "GameFontNormalLarge")
    AppendMapDetailLine(
        lines,
        string.format("%s | %s", guide.label, farm.expansion or "Unknown expansion"),
        0.68,
        0.72,
        0.80,
        8,
        "GameFontHighlight"
    )
    if HasText(farm.sourcePath) then
        AppendMapDetailLine(lines, "Farm category: " .. farm.sourcePath, 0.72, 0.86, 1.0, 8, "GameFontHighlightSmall")
    end
    if farm.sourceType == "drops" and (tonumber(farm.routeCount) or 0) == 0 then
        AppendMapDetailLine(
            lines,
            "Instance map available; this farm entry does not include route coordinates.",
            0.72,
            0.76,
            0.84,
            8,
            "GameFontHighlightSmall"
        )
    end

    if selected then
        local itemName, _, isLoaded = GetItemInfoSafe(selected.itemID)
        RequestItemData(selected.itemID, isLoaded)
        AppendMapDetailLine(lines, itemName .. " estimate", 0.45, 0.92, 1.0, 4, "GameFontNormalLarge")
        AppendMapDetailLine(
            lines,
            string.format(
                "%s x%s per %s",
                selected.isPrimary and "Primary target" or (selected.isRareBonus and "Rare bonus" or "Byproduct"),
                FormatQuantity(selected.quantity),
                FormatDuration(selected.recordedSeconds)
            ),
            0.82,
            0.90,
            1.0,
            3,
            "GameFontHighlight"
        )
        AppendMapDetailLine(
            lines,
            selected.valuePerHour > 0 and (self:FormatMoney(selected.valuePerHour) .. "/hour")
                or "Price unavailable",
            selected.valuePerHour > 0 and 0.35 or 0.68,
            selected.valuePerHour > 0 and 0.95 or 0.72,
            selected.valuePerHour > 0 and 0.55 or 0.80,
            3,
            "GameFontNormalLarge"
        )
        if selected.valueSharePercent then
            AppendMapDetailLine(
                lines,
                string.format("%.1f%% of the recorded farm value", selected.valueSharePercent),
                0.68,
                0.72,
                0.80,
                8,
                "GameFontHighlight"
            )
        end
        lines[#lines + 1] = {
            type = "divider",
            gap = 6,
        }
    end

    AppendMapDetailLine(
        lines,
        valuationSnapshot.isPartial and "Top 10 yield estimate" or "Farm estimate",
        1.0,
        0.82,
        0.18,
        4,
        "GameFontNormal"
    )
    if pricedTargets > 0 or (tonumber(farm.rawCopper) or 0) > 0 then
        AppendMapDetailLine(lines, self:FormatMoney(hourlyValue) .. "/hour", 0.35, 0.95, 0.55, 3, "GameFontNormalLarge")
        if valuationSnapshot.rareBonus then
            local bonus = valuationSnapshot.rareBonus
            local bonusName, _, isLoaded = GetItemInfoSafe(bonus.itemID)
            RequestItemData(bonus.itemID, isLoaded)
            AppendMapDetailLine(
                lines,
                string.format(
                    "Rare bonus: %s adds %s/hour in this recorded sample",
                    bonusName,
                    self:FormatMoney(bonus.valuePerHour or 0)
                ),
                1.0,
                0.72,
                0.24,
                3,
                "GameFontHighlight"
            )
            AppendMapDetailLine(
                lines,
                "Including rare bonus: " .. self:FormatMoney(valuationSnapshot.hourlyValue or 0) .. "/hour",
                0.72,
                0.76,
                0.84,
                3,
                "GameFontHighlightSmall"
            )
        end
        AppendMapDetailLine(
            lines,
            string.format("%s recorded sample | %s", FormatDuration(farm.recordedSeconds), valueSourceLabel),
            0.72,
            0.76,
            0.84,
            3,
            "GameFontHighlightSmall"
        )
        AppendMapDetailLine(
            lines,
            "Sample value: " .. self:FormatMoney(totalValue),
            0.72,
            0.76,
            0.84,
            8,
            "GameFontHighlightSmall"
        )
        if valuationSnapshot.isPartial then
            AppendMapDetailLine(
                lines,
                "Open all recorded items to calculate the complete farm estimate.",
                0.72,
                0.76,
                0.84,
                8,
                "GameFontHighlightSmall"
            )
        end
    else
        AppendMapDetailLine(
            lines,
            valuationSnapshot.isPartial
                and "Open all recorded items to calculate the complete farm estimate."
                or "Waiting for item prices.",
            0.72,
            0.76,
            0.84,
            8,
            "GameFontDisable"
        )
    end

    AppendMapDetailLine(lines, "How to farm", 1.0, 0.82, 0.18, 4, "GameFontNormal")
    AppendMapDetailLine(lines, guide.action, 1.0, 0.45, 0.20, 4, "GameFontHighlight")
    AppendMapDetailLine(lines, guide.requirement, 0.72, 0.86, 1.0, 8, "GameFontHighlight")

    local targets, totalTargetCount = BuildTopFarmMapTargetsByQuantity(
        self,
        farm,
        selectedItemID,
        valuationSnapshot,
        MAX_MAP_RECORDED_YIELDS
    )

    AppendMapDetailLine(lines, "Recorded yields", 1.0, 0.82, 0.18, 4, "GameFontNormal")
    if totalTargetCount > 0 then
        lines[#lines + 1] = {
            type = "detailButton",
            text = "View all recorded items (" .. tostring(totalTargetCount) .. ")",
            onClick = options.onOpenAllTargets,
            gap = 4,
        }
    end
    lines[#lines + 1] = {
        type = "farmTargetHeader",
        sortKey = "quantity",
        sortAscending = false,
        gap = 2,
    }
    AppendFarmMapTargetRows(lines, targets)
    if totalTargetCount == 0 then
        AppendMapDetailLine(lines, "No recorded item yields.", 0.72, 0.76, 0.84, 8, "GameFontDisable")
    end

    AppendMapDetailLine(lines, "Tips", 1.0, 0.82, 0.18, 4, "GameFontNormal")
    for _, tip in ipairs(guide.tips or {}) do
        AppendMapDetailLine(lines, "- " .. tip, 0.82, 0.86, 0.92, 4, "GameFontHighlight")
    end
    if farm.durationInferred == true then
        AppendMapDetailLine(lines, "Recorded yields were normalized to one hour.", 0.72, 0.76, 0.84, 7, "GameFontHighlightSmall")
    end
    if HasText(catalog.sourceURL) then
        lines[#lines + 1] = {
            type = "source",
            siteName = "Farm catalog source",
            url = catalog.sourceURL,
            gap = 4,
        }
    end
    return lines
end

function GoldTracker:BuildFarmDetailsMapOptions(farms, selectedItemID)
    local options = {}
    farms = type(farms) == "table" and farms or {}
    local showFarmName = #farms > 1
    for _, farm in ipairs(farms) do
        local routeOptions = self:BuildFarmRouteMapOptions(farm)
        local showRouteLabel = showFarmName or #routeOptions > 1
        for _, option in ipairs(routeOptions) do
            local routeLabel = option.label or option.mapLabel or farm.name or farm.id
            option.farm = farm
            option.farmID = farm.id
            option.windowTitle = farm.name or farm.id
            option.selectedItemID = NormalizeItemID(selectedItemID)
            if option.mapRole == "boss" then
                option.label = "Boss location"
            elseif option.mapRole == "entrance" then
                option.label = "Instance entrance"
            elseif option.mapRole == "alternate" then
                option.label = "Alternate instance entrance"
            else
                option.label = "farm: " .. tostring(farm.name or farm.id)
                if showRouteLabel and routeLabel ~= (farm.name or farm.id) then
                    option.label = option.label .. " - " .. tostring(routeLabel)
                end
            end
            options[#options + 1] = option
        end
    end
    return options
end

local function CreateFarmValuationState(addon, farm, options)
    options = type(options) == "table" and options or {}
    local includeTargets = options.includeTargets ~= false
    local source = type(addon.GetCraftingFarmingValueSource) == "function" and addon:GetCraftingFarmingValueSource()
        or (type(addon.GetCurrentValueSource) == "function" and addon:GetCurrentValueSource())
    return {
        addon = addon,
        farm = farm,
        includeTargets = includeTargets,
        source = source,
        total = math.max(0, tonumber(farm and farm.rawCopper) or 0),
        pricedTargets = 0,
        targets = {},
        primaryItemID = NormalizeItemID(farm and farm.primaryItemID),
    }
end

local function AccumulateFarmValuationTarget(state, target)
    local itemID = NormalizeItemID(target and target.itemID)
    if not itemID then
        return
    end

    local _, itemLink = GetItemInfoSafe(itemID)
    local value = 0
    if type(state.addon.ResolveItemUnitValue) == "function" then
        value = tonumber((state.addon:ResolveItemUnitValue(
            state.source and state.source.id,
            itemLink,
            itemID,
            true
        ))) or 0
    end
    local quantity = math.max(0, tonumber(target.quantity) or 0)
    local sampleValue = value * quantity
    if value > 0 then
        state.pricedTargets = state.pricedTargets + 1
        state.total = state.total + sampleValue
        if state.farm.sourceType == "gathering"
            and itemID ~= state.primaryItemID
            and quantity > 0
            and quantity <= RARE_BONUS_MAX_RECORDED_QUANTITY
            and (not state.rareBonusCandidate or sampleValue > state.rareBonusCandidate.sampleValue)
        then
            state.rareBonusCandidate = {
                itemID = itemID,
                quantity = quantity,
                unitValue = value,
                sampleValue = sampleValue,
            }
        end
    end
    if state.includeTargets then
        state.targets[#state.targets + 1] = {
            itemID = itemID,
            quantity = quantity,
            unitValue = value,
            sampleValue = sampleValue,
        }
    end
end

local function FinalizeFarmValuationState(state)
    local duration = math.max(1, tonumber(state.farm and state.farm.recordedSeconds) or 3600)
    local perHour = math.floor(((state.total * 3600) / duration) + 0.5)
    local rareBonus
    if state.rareBonusCandidate and state.total > state.rareBonusCandidate.sampleValue then
        local valueShare = state.rareBonusCandidate.sampleValue / state.total
        if valueShare >= RARE_BONUS_MIN_VALUE_SHARE then
            rareBonus = state.rareBonusCandidate
            rareBonus.valueSharePercent = valueShare * 100
            rareBonus.valuePerHour = math.floor(((rareBonus.sampleValue * 3600) / duration) + 0.5)
        end
    end
    local steadyTotal = rareBonus and (state.total - rareBonus.sampleValue) or state.total
    local steadyPerHour = math.floor(((steadyTotal * 3600) / duration) + 0.5)
    if rareBonus and state.includeTargets then
        for _, target in ipairs(state.targets) do
            if target.itemID == rareBonus.itemID then
                target.isRareBonus = true
                break
            end
        end
    end
    return {
        totalValue = math.floor(state.total + 0.5),
        hourlyValue = perHour,
        estimatedHourlyValue = steadyPerHour,
        steadyTotalValue = math.floor(steadyTotal + 0.5),
        rareBonus = rareBonus,
        pricedTargets = state.pricedTargets,
        sourceLabel = state.source and state.source.label or "Unknown",
        duration = duration,
        targets = state.targets,
    }
end

function GoldTracker:BuildFarmValuationSnapshot(farm, options)
    if type(farm) ~= "table" then
        return {
            totalValue = 0,
            hourlyValue = 0,
            estimatedHourlyValue = 0,
            steadyTotalValue = 0,
            pricedTargets = 0,
            sourceLabel = "Unknown",
            targets = {},
        }
    end

    local state = CreateFarmValuationState(self, farm, options)
    for _, target in ipairs(farm.targets or {}) do
        AccumulateFarmValuationTarget(state, target)
    end
    return FinalizeFarmValuationState(state)
end

function GoldTracker:BuildFarmValuationSnapshotAsync(farm, onComplete, options)
    if type(onComplete) ~= "function" then
        return nil
    end
    if type(farm) ~= "table" or not C_Timer or type(C_Timer.After) ~= "function" then
        onComplete(self:BuildFarmValuationSnapshot(farm, options))
        return nil
    end

    local task = { cancelled = false }
    local state = CreateFarmValuationState(self, farm, options)
    local targets = farm.targets or {}
    local targetIndex = 1

    local function processBatch()
        if task.cancelled then
            return
        end
        local startedAt = type(debugprofilestop) == "function" and debugprofilestop() or nil
        local processed = 0
        while targetIndex <= #targets do
            AccumulateFarmValuationTarget(state, targets[targetIndex])
            targetIndex = targetIndex + 1
            processed = processed + 1
            if startedAt then
                if (debugprofilestop() - startedAt) >= FARM_VALUATION_ASYNC_BUDGET_MS then
                    break
                end
            elseif processed >= FARM_VALUATION_ASYNC_FALLBACK_BATCH_SIZE then
                break
            end
        end
        if task.cancelled then
            return
        end
        if targetIndex <= #targets then
            C_Timer.After(0, processBatch)
        else
            onComplete(FinalizeFarmValuationState(state))
        end
    end

    C_Timer.After(0, processBatch)
    return task
end

function GoldTracker:BuildFarmPreviewValuationSnapshot(farm)
    if type(farm) ~= "table" then
        return self:BuildFarmValuationSnapshot(farm)
    end

    local state = CreateFarmValuationState(self, farm, { includeTargets = true })
    local topTargets, totalTargetCount = GetTopFarmTargetsByQuantity(farm, MAX_MAP_RECORDED_YIELDS)
    for _, candidate in ipairs(topTargets) do
        AccumulateFarmValuationTarget(state, candidate.target)
    end
    local snapshot = FinalizeFarmValuationState(state)

    local cache = type(self.db) == "table" and self.db.farmCatalogValueCache or self.farmCatalogViewSnapshots
    local cachedSnapshot = type(cache) == "table" and cache[farm.id] or nil
    if type(cachedSnapshot) == "table"
        and cachedSnapshot.totalValue ~= nil
        and (cachedSnapshot.estimatedHourlyValue ~= nil or cachedSnapshot.hourlyValue ~= nil)
    then
        for _, key in ipairs({
            "totalValue",
            "hourlyValue",
            "estimatedHourlyValue",
            "steadyTotalValue",
            "pricedTargets",
            "sourceLabel",
            "duration",
        }) do
            if cachedSnapshot[key] ~= nil then
                snapshot[key] = cachedSnapshot[key]
            end
        end
        snapshot.usesCachedSummary = true
    end
    snapshot.isPartial = totalTargetCount > #topTargets and snapshot.usesCachedSummary ~= true
    snapshot.totalTargetCount = totalTargetCount
    return snapshot
end

function GoldTracker:GetFarmEstimatedValue(farm, valuationSnapshot)
    local snapshot = valuationSnapshot or self:BuildFarmValuationSnapshot(farm)
    return snapshot.totalValue or 0,
        snapshot.estimatedHourlyValue or snapshot.hourlyValue or 0,
        snapshot.pricedTargets or 0,
        snapshot.sourceLabel or "Unknown"
end

function GoldTracker:GetFarmHighValueDropSuggestions(farm, excludedItemIDs, limit)
    if type(farm) ~= "table"
        or farm.sourceDataset ~= "CatalogDropsData"
        or (farm.sourceCategory ~= "instances" and farm.sourceCategory ~= "openWorldInstances") then
        return {}, "Unknown"
    end

    local excluded = {}
    for key, value in pairs(type(excludedItemIDs) == "table" and excludedItemIDs or {}) do
        local itemID
        if value == true then
            itemID = NormalizeItemID(key)
        else
            itemID = NormalizeItemID(value)
        end
        if itemID then
            excluded[itemID] = true
        end
    end

    local source = type(self.GetInstanceFarmingValueSource) == "function" and self:GetInstanceFarmingValueSource()
        or (type(self.GetCraftingFarmingValueSource) == "function" and self:GetCraftingFarmingValueSource())
        or (type(self.GetCurrentValueSource) == "function" and self:GetCurrentValueSource())
    local sourceLabel = source and source.label or "Unknown"
    local suggestions = {}
    local duration = math.max(1, tonumber(farm.recordedSeconds) or 3600)
    for _, target in ipairs(farm.targets or {}) do
        local itemID = NormalizeItemID(target.itemID)
        if itemID and not excluded[itemID] then
            local unitValue = 0
            local resolvedLabel = sourceLabel
            if type(self.ResolveItemUnitValue) == "function" then
                local _, itemLink = GetItemInfoSafe(itemID)
                local resolvedValue, _, valueLabel = self:ResolveItemUnitValue(
                    source and source.id,
                    itemLink,
                    itemID,
                    true
                )
                unitValue = math.max(0, tonumber(resolvedValue) or 0)
                if HasText(valueLabel) then
                    resolvedLabel = valueLabel
                end
            end
            if unitValue > 0 then
                local quantity = math.max(0, tonumber(target.quantity) or 0)
                suggestions[#suggestions + 1] = {
                    itemID = itemID,
                    quantity = quantity,
                    unitValue = math.floor(unitValue + 0.5),
                    sampleValue = math.floor((unitValue * quantity) + 0.5),
                    valuePerHour = math.floor(((unitValue * quantity * 3600) / duration) + 0.5),
                    valueSourceLabel = resolvedLabel,
                }
            end
        end
    end

    table.sort(suggestions, function(left, right)
        if left.unitValue ~= right.unitValue then
            return left.unitValue > right.unitValue
        end
        if left.sampleValue ~= right.sampleValue then
            return left.sampleValue > right.sampleValue
        end
        return left.itemID < right.itemID
    end)

    local maxResults = math.max(0, math.floor(tonumber(limit) or 5))
    while #suggestions > maxResults do
        table.remove(suggestions)
    end
    return suggestions, sourceLabel
end

function GoldTracker:GetFarmSelectedMaterialSummary(farm, selectedItemID, valuationSnapshot)
    local itemID = NormalizeItemID(selectedItemID)
    if type(farm) ~= "table" or not itemID then
        return nil
    end

    local snapshot = valuationSnapshot or self:BuildFarmValuationSnapshot(farm)
    local selectedTarget
    for _, target in ipairs(snapshot.targets or {}) do
        if target.itemID == itemID then
            selectedTarget = target
            break
        end
    end
    if not selectedTarget then
        return nil
    end

    local duration = snapshot.duration or math.max(1, tonumber(farm.recordedSeconds) or 3600)
    local totalValue = snapshot.totalValue or 0
    local selectedValue = selectedTarget.sampleValue or 0
    local selectedPriced = (selectedTarget.unitValue or 0) > 0
    local byproducts = {}

    for _, target in ipairs(snapshot.targets or {}) do
        if target.itemID ~= itemID then
            byproducts[#byproducts + 1] = {
                itemID = target.itemID,
                quantity = target.quantity,
                sampleValue = target.sampleValue,
            }
        end
    end

    table.sort(byproducts, function(left, right)
        if left.sampleValue ~= right.sampleValue then
            return left.sampleValue > right.sampleValue
        end
        if left.quantity ~= right.quantity then
            return left.quantity > right.quantity
        end
        return left.itemID < right.itemID
    end)

    local importantByproducts = {}
    for index = 1, math.min(3, #byproducts) do
        importantByproducts[index] = byproducts[index]
    end

    return {
        itemID = itemID,
        quantity = selectedTarget.quantity,
        isPrimary = NormalizeItemID(farm.primaryItemID) == itemID,
        isRareBonus = selectedTarget.isRareBonus == true,
        recordedSeconds = duration,
        sampleValue = math.floor(selectedValue + 0.5),
        valuePerHour = math.floor(((selectedValue * 3600) / duration) + 0.5),
        totalSampleValue = math.floor(totalValue + 0.5),
        valueSharePercent = selectedPriced and totalValue > 0 and ((selectedValue / totalValue) * 100) or nil,
        byproducts = importantByproducts,
        valueSourceLabel = snapshot.sourceLabel or "Unknown",
    }
end

function GoldTracker:BuildFarmSelectedMaterialSummaryText(farm, selectedItemID, valuationSnapshot)
    local summary = self:GetFarmSelectedMaterialSummary(farm, selectedItemID, valuationSnapshot)
    if not summary then
        return nil
    end

    local itemName, _, isLoaded = GetItemInfoSafe(summary.itemID)
    RequestItemData(summary.itemID, isLoaded)
    local targetRole = summary.isPrimary and "Primary target" or (summary.isRareBonus and "Rare bonus" or "Byproduct")
    local lines = {
        string.format("%s  |  %s", itemName, targetRole),
        string.format(
            "Expected: %s per %s  |  Estimated: %s/hour",
            FormatQuantity(summary.quantity),
            FormatDuration(summary.recordedSeconds),
            summary.valuePerHour > 0 and self:FormatMoney(summary.valuePerHour) or "price unavailable"
        ),
        summary.valueSharePercent and string.format(
            "Share of recorded farm value: %.1f%%  |  Price source: %s",
            summary.valueSharePercent,
            summary.valueSourceLabel
        ) or ("Share of recorded farm value: unavailable  |  Price source: " .. summary.valueSourceLabel),
    }

    local byproductLabels = {}
    for _, byproduct in ipairs(summary.byproducts or {}) do
        local byproductName, _, isLoaded = GetItemInfoSafe(byproduct.itemID)
        RequestItemData(byproduct.itemID, isLoaded)
        local valueText = byproduct.sampleValue > 0 and ("; " .. self:FormatMoney(byproduct.sampleValue)) or ""
        byproductLabels[#byproductLabels + 1] = string.format(
            "%s x%s%s",
            byproductName,
            FormatQuantity(byproduct.quantity),
            valueText
        )
    end
    lines[#lines + 1] = "Important byproducts: " .. Join(byproductLabels, "None recorded")
    return table.concat(lines, "\n")
end

function GoldTracker:BuildFarmDetailsText(farm, selectedItemID, valuationSnapshot)
    if type(farm) ~= "table" then
        return "Farm data is unavailable."
    end

    if IsCuratedResearchFarm(farm) then
        local guide = GetFarmGuide(farm)
        local lines = {
            farm.name or farm.id,
            string.format("%s | %s", guide.label, farm.expansion or "Unknown expansion"),
            "Location: " .. Join(farm.mapNames, "No mapped location"),
            string.format("Mapped options: %d", tonumber(farm.routeCount) or 0),
            "",
            "OVERVIEW",
            farm.summary or GetCuratedResearchFallbackSummary(farm),
            "",
            "HOW TO FARM",
            guide.action,
            "Requirement: " .. guide.requirement,
        }
        if type(farm.details) == "table" and #farm.details > 0 then
            lines[#lines + 1] = ""
            lines[#lines + 1] = "DETAILS"
            for _, detail in ipairs(farm.details) do
                lines[#lines + 1] = "- " .. tostring(detail)
            end
        end
        lines[#lines + 1] = ""
        lines[#lines + 1] = "TIPS"
        for _, tip in ipairs(guide.tips or {}) do
            lines[#lines + 1] = "- " .. tip
        end
        if type(farm.sourceUrls) == "table" and #farm.sourceUrls > 0 then
            lines[#lines + 1] = ""
            lines[#lines + 1] = "SOURCES"
            for _, source in ipairs(farm.sourceUrls) do
                if type(source) == "table" and HasText(source.url) then
                    lines[#lines + 1] = string.format("- %s: %s", source.siteName or "Research source", source.url)
                end
            end
        end
        return table.concat(lines, "\n")
    end

    local guide = GetFarmGuide(farm)
    local catalog = GetFarmCatalog()
    valuationSnapshot = valuationSnapshot or self:BuildFarmValuationSnapshot(farm)
    local totalValue, hourlyValue, pricedTargets, valueSourceLabel = self:GetFarmEstimatedValue(farm, valuationSnapshot)
    local lines = {
        farm.name or farm.id,
        string.format("%s | %s", guide.label, farm.expansion or "Unknown expansion"),
        "Location: " .. Join(farm.mapNames, "No mapped location"),
        string.format("Route: %d available", tonumber(farm.routeCount) or 0),
        "Recorded sample: " .. FormatDuration(farm.recordedSeconds),
    }

    if farm.durationInferred == true then
        lines[#lines + 1] = "Duration note: no duration is recorded; yields are normalized to one hour."
    end
    lines[#lines + 1] = "Requirement: " .. guide.requirement
    lines[#lines + 1] = ""
    lines[#lines + 1] = "VALUATION"
    if pricedTargets > 0 or (tonumber(farm.rawCopper) or 0) > 0 then
        lines[#lines + 1] = "Recorded sample value: " .. self:FormatMoney(totalValue)
        lines[#lines + 1] = "Estimated value/hour: " .. self:FormatMoney(hourlyValue)
        if valuationSnapshot.rareBonus then
            local bonus = valuationSnapshot.rareBonus
            local bonusName, _, isLoaded = GetItemInfoSafe(bonus.itemID)
            RequestItemData(bonus.itemID, isLoaded)
            lines[#lines + 1] = string.format(
                "Rare bonus: %s adds %s/hour in this recorded sample",
                bonusName,
                self:FormatMoney(bonus.valuePerHour or 0)
            )
            lines[#lines + 1] = "Including rare bonus: " .. self:FormatMoney(valuationSnapshot.hourlyValue or 0) .. "/hour"
        end
        lines[#lines + 1] = "Price source: " .. tostring(valueSourceLabel)
    else
        lines[#lines + 1] = "Estimated value: unavailable until item prices are cached."
    end
    lines[#lines + 1] = "Auction values are potential asset values, not guaranteed liquid gold."
    lines[#lines + 1] = ""
    lines[#lines + 1] = "RECORDED YIELDS"

    local selected = NormalizeItemID(selectedItemID)
    local targets = {}
    for targetIndex, target in ipairs(farm.targets or {}) do
        targets[#targets + 1] = { target = target, sourceIndex = targetIndex }
    end
    table.sort(targets, function(left, right)
        local leftSelected = NormalizeItemID(left.target.itemID) == selected
        local rightSelected = NormalizeItemID(right.target.itemID) == selected
        if leftSelected ~= rightSelected then
            return leftSelected
        end
        return left.sourceIndex < right.sourceIndex
    end)

    for index, entry in ipairs(targets) do
        if index > MAX_VISIBLE_TARGETS then
            break
        end
        local target = entry.target
        local itemID = NormalizeItemID(target.itemID)
        if itemID then
            local itemName, _, isLoaded = GetItemInfoSafe(itemID)
            RequestItemData(itemID, isLoaded)
            local marker = itemID == selected and "> " or "- "
            lines[#lines + 1] = string.format(
                "%s%s x%s | Total value: %s",
                marker,
                itemName,
                FormatQuantity(target.quantity),
                FormatFarmTargetTotalValue(self, valuationSnapshot, itemID)
            )
        end
    end
    if #targets > MAX_VISIBLE_TARGETS then
        lines[#lines + 1] = string.format("...and %d more recorded targets.", #targets - MAX_VISIBLE_TARGETS)
    elseif #targets == 0 then
        lines[#lines + 1] = "No recorded item yields."
    end

    lines[#lines + 1] = ""
    lines[#lines + 1] = "TIPS"
    lines[#lines + 1] = "- " .. guide.action
    for _, tip in ipairs(guide.tips or {}) do
        lines[#lines + 1] = "- " .. tip
    end
    lines[#lines + 1] = ""
    lines[#lines + 1] = string.format(
        "Source: bundled GGT farm catalog (%s).",
        tostring(catalog.sourceVersion or "unknown")
    )
    return table.concat(lines, "\n")
end

local function ShowFarmSourceLink(url)
    if not HasText(url) then
        return
    end
    local frame = GoldTracker.farmSourceLinkFrame
    if not frame then
        frame = CreateFrame("Frame", "GoldTrackerFarmSourceLinkFrame", UIParent, "BasicFrameTemplateWithInset")
        frame:SetSize(620, 150)
        frame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
        frame:SetFrameStrata("TOOLTIP")
        frame:SetClampedToScreen(true)
        frame:SetMovable(true)
        frame:EnableMouse(true)
        frame:RegisterForDrag("LeftButton")
        frame:SetScript("OnDragStart", frame.StartMoving)
        frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
        if frame.TitleText then
            frame.TitleText:SetText("Farm Source")
        end

        local body = CreatePanel(frame, "body", "goldBorder")
        body:SetPoint("TOPLEFT", frame, "TOPLEFT", 12, -34)
        body:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -12, 12)
        local label = body:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        label:SetPoint("TOPLEFT", body, "TOPLEFT", 12, -12)
        label:SetText("Copy source link")
        local editBox = CreateFrame("EditBox", nil, body, "InputBoxTemplate")
        editBox:SetPoint("TOPLEFT", label, "BOTTOMLEFT", 0, -12)
        editBox:SetPoint("TOPRIGHT", body, "TOPRIGHT", -12, -42)
        editBox:SetHeight(24)
        editBox:SetAutoFocus(false)
        editBox:SetScript("OnEditFocusGained", function(self) self:HighlightText() end)
        editBox:SetScript("OnMouseUp", function(self) self:HighlightText() end)
        editBox:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
        local closeButton = CreateButton(body, 78, 24, "Close", "neutral")
        closeButton:SetPoint("BOTTOMRIGHT", body, "BOTTOMRIGHT", -12, 12)
        closeButton:SetScript("OnClick", function() frame:Hide() end)
        frame.urlEditBox = editBox
        GoldTracker.farmSourceLinkFrame = frame
    end
    frame.urlEditBox:SetText(url)
    frame:Show()
    frame:Raise()
    frame.urlEditBox:SetFocus()
    frame.urlEditBox:HighlightText()
end

function GoldTracker:RefreshFarmDetailsWindow()
    local frame = self.farmDetailsFrame
    if not frame then
        return
    end
    local farm = frame.farms and frame.farms[frame.selectedFarmIndex or 1]
    if not farm then
        frame.bodyText:SetText("Farm data is unavailable.")
        return
    end

    frame.selectedFarmID = farm.id
    local valuationSnapshot = self:BuildFarmValuationSnapshot(farm)
    local summaryText = self:BuildFarmSelectedMaterialSummaryText(farm, frame.selectedItemID, valuationSnapshot)
    local showSummary = HasText(summaryText)
    frame.summaryPanel:SetShown(showSummary)
    frame.summaryText:SetText(summaryText or "")
    frame.body:ClearAllPoints()
    if showSummary then
        frame.body:SetPoint("TOPLEFT", frame.summaryPanel, "BOTTOMLEFT", 0, -10)
    else
        frame.body:SetPoint("TOPLEFT", frame.controls, "BOTTOMLEFT", 0, -10)
    end
    frame.body:SetPoint("BOTTOMRIGHT", frame.chrome, "BOTTOMRIGHT", -12, 12)
    frame.bodyText:SetText(self:BuildFarmDetailsText(farm, frame.selectedItemID, valuationSnapshot))
    local contentWidth = math.max(1, math.floor((frame.scrollFrame:GetWidth() or 1) - 8))
    frame.scrollContent:SetWidth(contentWidth)
    local contentHeight = math.max(
        math.floor(frame.scrollFrame:GetHeight() or 1),
        math.floor((frame.bodyText:GetStringHeight() or 0) + 24)
    )
    frame.scrollContent:SetHeight(contentHeight)

    UIDropDownMenu_SetSelectedValue(frame.farmDropdown, frame.selectedFarmIndex or 1)
    UIDropDownMenu_SetText(frame.farmDropdown, farm.name or farm.id)
    frame.farmDropdown:SetShown(#(frame.farms or {}) > 1)
    frame.selectorLabel:SetShown(#(frame.farms or {}) > 1)

    local routeOptions = self:BuildFarmRouteMapOptions(farm)
    frame.routeOptions = routeOptions
    local hasRoute = #routeOptions > 0
    if frame.routeButton.SetEnabled then
        frame.routeButton:SetEnabled(hasRoute)
    end
    frame.routeButton:SetAlpha(hasRoute and 1 or 0.42)
    frame.routeButton.tooltipText = hasRoute
        and string.format("Open %d route%s on the GGT map.", #routeOptions, #routeOptions == 1 and "" or "s")
        or "This farm does not contain route coordinates."

    local sourceURL = GetFarmPrimarySourceURL(farm) or GetFarmCatalog().sourceURL
    frame.sourceButton:SetShown(HasText(sourceURL))
    frame.sourceButton.sourceURL = sourceURL
end

function GoldTracker:CreateFarmDetailsWindow()
    if self.farmDetailsFrame then
        return self.farmDetailsFrame
    end

    local addon = self
    local frame = CreateFrame("Frame", "GoldTrackerFarmDetailsFrame", UIParent, "BasicFrameTemplateWithInset")
    frame:SetSize(FARM_DETAILS_WIDTH, FARM_DETAILS_HEIGHT)
    frame:SetPoint("CENTER", UIParent, "CENTER", 30, 30)
    frame:SetFrameStrata("DIALOG")
    frame:SetClampedToScreen(true)
    frame:SetMovable(true)
    frame:SetResizable(true)
    if frame.SetResizeBounds then
        frame:SetResizeBounds(FARM_DETAILS_MIN_WIDTH, FARM_DETAILS_MIN_HEIGHT, FARM_DETAILS_MAX_WIDTH, FARM_DETAILS_MAX_HEIGHT)
    end
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnMouseDown", function(self) self:Raise() end)
    frame:SetScript("OnDragStart", function(self) self:Raise(); self:StartMoving() end)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
    frame:Hide()

    local chrome = Theme:ApplyWindowChrome(frame, "Farm Details", { closeButtonKey = "farmDetailsCloseButton" })
    frame.chrome = chrome
    Theme:RegisterSpecialFrame("GoldTrackerFarmDetailsFrame")

    local controls = CreatePanel(frame, "section", "goldBorder")
    controls:SetPoint("TOPLEFT", chrome, "TOPLEFT", 12, -54)
    controls:SetPoint("TOPRIGHT", chrome, "TOPRIGHT", -12, -54)
    controls:SetHeight(54)
    frame.controls = controls

    local selectorLabel = controls:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    selectorLabel:SetPoint("LEFT", controls, "LEFT", 12, 0)
    selectorLabel:SetText("Farm")
    frame.selectorLabel = selectorLabel

    local farmDropdown = CreateFrame("Frame", "GoldTrackerFarmDetailsSelectorDropdown", controls, "UIDropDownMenuTemplate")
    farmDropdown:SetPoint("LEFT", selectorLabel, "RIGHT", -4, 0)
    UIDropDownMenu_SetWidth(farmDropdown, 310)
    UIDropDownMenu_Initialize(farmDropdown, function(_, level)
        for index, farm in ipairs(frame.farms or {}) do
            local info = UIDropDownMenu_CreateInfo()
            info.text = farm.name or farm.id
            info.value = index
            info.checked = frame.selectedFarmIndex == index
            info.func = function()
                frame.selectedFarmIndex = index
                addon:RefreshFarmDetailsWindow()
            end
            UIDropDownMenu_AddButton(info, level)
        end
    end)
    frame.farmDropdown = farmDropdown

    local sourceButton = CreateButton(controls, 86, 24, "Source", "neutral")
    sourceButton:SetPoint("RIGHT", controls, "RIGHT", -12, 0)
    sourceButton:SetScript("OnClick", function(self) ShowFarmSourceLink(self.sourceURL) end)
    frame.sourceButton = sourceButton

    local routeButton = CreateButton(controls, 104, 24, "View Route", "primary")
    routeButton:SetPoint("RIGHT", sourceButton, "LEFT", -8, 0)
    routeButton:SetScript("OnClick", function()
        local farm = frame.farms and frame.farms[frame.selectedFarmIndex or 1]
        if farm and type(frame.routeOptions) == "table" and #frame.routeOptions > 0 then
            addon:OpenStandaloneMapWindow({
                title = farm.name,
                projectionKey = farm.id,
                mapOptions = frame.routeOptions,
            })
        end
    end)
    routeButton:SetScript("OnEnter", function(self)
        if GameTooltip and HasText(self.tooltipText) then
            GameTooltip:SetOwner(self, "ANCHOR_TOP")
            GameTooltip:SetText(self.tooltipText, 1, 0.82, 0.18)
            GameTooltip:Show()
        end
    end)
    routeButton:SetScript("OnLeave", function() if GameTooltip then GameTooltip:Hide() end end)
    frame.routeButton = routeButton

    local summaryPanel = CreatePanel(frame, "section", "goldBorder")
    summaryPanel:SetPoint("TOPLEFT", controls, "BOTTOMLEFT", 0, -10)
    summaryPanel:SetPoint("TOPRIGHT", controls, "BOTTOMRIGHT", 0, -10)
    summaryPanel:SetHeight(FARM_SUMMARY_HEIGHT)
    local summaryTitle = summaryPanel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    summaryTitle:SetPoint("TOPLEFT", summaryPanel, "TOPLEFT", 12, -10)
    summaryTitle:SetText("Selected material")
    local summaryText = summaryPanel:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    summaryText:SetPoint("TOPLEFT", summaryTitle, "BOTTOMLEFT", 0, -7)
    summaryText:SetPoint("BOTTOMRIGHT", summaryPanel, "BOTTOMRIGHT", -12, 10)
    summaryText:SetJustifyH("LEFT")
    summaryText:SetJustifyV("TOP")
    summaryText:SetWordWrap(true)
    summaryText:SetTextColor(0.78, 0.90, 1.0)
    frame.summaryPanel = summaryPanel
    frame.summaryText = summaryText

    local body = CreatePanel(frame, "body", "goldBorder")
    body:SetPoint("TOPLEFT", summaryPanel, "BOTTOMLEFT", 0, -10)
    body:SetPoint("BOTTOMRIGHT", chrome, "BOTTOMRIGHT", -12, 12)
    frame.body = body
    local scrollFrame = CreateFrame("ScrollFrame", nil, body, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", body, "TOPLEFT", 14, -14)
    scrollFrame:SetPoint("BOTTOMRIGHT", body, "BOTTOMRIGHT", -28, 14)
    scrollFrame:EnableMouseWheel(true)
    scrollFrame:SetScript("OnMouseWheel", function(self, delta)
        local nextScroll = (self:GetVerticalScroll() or 0) - (delta * 40)
        self:SetVerticalScroll(math.max(0, math.min(self:GetVerticalScrollRange() or 0, nextScroll)))
    end)
    local scrollContent = CreateFrame("Frame", nil, scrollFrame)
    scrollContent:SetSize(1, 1)
    scrollFrame:SetScrollChild(scrollContent)
    local bodyText = scrollContent:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    bodyText:SetPoint("TOPLEFT", scrollContent, "TOPLEFT", 0, 0)
    bodyText:SetPoint("TOPRIGHT", scrollContent, "TOPRIGHT", 0, 0)
    bodyText:SetJustifyH("LEFT")
    bodyText:SetJustifyV("TOP")
    bodyText:SetWordWrap(true)
    bodyText:SetTextColor(0.88, 0.92, 1.0)
    frame.scrollFrame = scrollFrame
    frame.scrollContent = scrollContent
    frame.bodyText = bodyText

    Theme:CreateResizeButton(frame, {
        maximize = true,
        minWidth = FARM_DETAILS_MIN_WIDTH,
        minHeight = FARM_DETAILS_MIN_HEIGHT,
        maxWidth = FARM_DETAILS_MAX_WIDTH,
        maxHeight = FARM_DETAILS_MAX_HEIGHT,
        onResizeStop = function() addon:RefreshFarmDetailsWindow() end,
    })
    frame:SetScript("OnSizeChanged", function()
        if not frame.isManualResizing and frame:IsShown() then
            addon:RefreshFarmDetailsWindow()
        end
    end)
    frame:RegisterEvent("GET_ITEM_INFO_RECEIVED")
    frame:RegisterEvent("ITEM_DATA_LOAD_RESULT")
    frame:SetScript("OnEvent", function(_, _, itemID)
        if frame:IsShown()
            and type(addon.CompleteFarmItemDataRequest) == "function"
            and addon:CompleteFarmItemDataRequest(itemID)
        then
            addon:RefreshFarmDetailsWindow()
        end
    end)
    self.farmDetailsFrame = frame
    return frame
end

function GoldTracker:OpenFarmDetails(farmID, options)
    local farm = self:GetFarmByID(farmID)
    if not farm then
        return false
    end
    options = type(options) == "table" and options or {}
    local farms = type(options.farms) == "table" and options.farms or { farm }
    if #farms == 0 then
        farms = { farm }
    end
    local selectedItemID = NormalizeItemID(options.itemID)
    local mapOptions = self:BuildFarmDetailsMapOptions(farms, selectedItemID)
    if #mapOptions > 0 and type(self.OpenStandaloneMapWindow) == "function" then
        local selectedMapOptionIndex = 1
        for index, mapOption in ipairs(mapOptions) do
            if mapOption.farmID == farm.id then
                selectedMapOptionIndex = index
                break
            end
        end
        if self.farmDetailsFrame then
            self.farmDetailsFrame:Hide()
        end
        local addon = self
        local valuationSnapshots = {}
        local farmTargetTableStates = {}
        self:OpenStandaloneMapWindow({
            title = farm.name or farm.id,
            projectionKey = selectedItemID and ("farm-item:" .. tostring(selectedItemID)) or farm.id,
            mapOptions = mapOptions,
            selectedMapOptionIndex = selectedMapOptionIndex,
            detailLinesBuilder = function(mapOption, _, mapLabel)
                local selectedFarm = mapOption and mapOption.farm or farm
                local valuationKey = selectedFarm.id or tostring(selectedFarm)
                local valuationSnapshot = valuationSnapshots[valuationKey]
                if not valuationSnapshot then
                    valuationSnapshot = addon:BuildFarmPreviewValuationSnapshot(selectedFarm)
                    valuationSnapshots[valuationKey] = valuationSnapshot
                end
                local tableState = farmTargetTableStates[valuationKey]
                if not tableState then
                    tableState = { filter = "all", sortKey = "itemName", sortAscending = true }
                    farmTargetTableStates[valuationKey] = tableState
                end
                return addon:BuildFarmMapDetailLines(selectedFarm, selectedItemID, mapLabel, valuationSnapshot, {
                    onOpenAllTargets = function()
                        addon:OpenFarmRecordedYieldsForFarm(
                            selectedFarm,
                            selectedItemID,
                            valuationSnapshot,
                            tableState
                        )
                    end,
                })
            end,
        })
        return true
    end

    local frame = self:CreateFarmDetailsWindow()
    frame.farms = farms
    frame.selectedItemID = selectedItemID
    frame.selectedFarmIndex = 1
    for index, candidate in ipairs(frame.farms) do
        if candidate.id == farm.id then
            frame.selectedFarmIndex = index
            break
        end
    end
    frame:Show()
    frame:Raise()
    frame.scrollFrame:SetVerticalScroll(0)
    self:RefreshFarmDetailsWindow()
    return true
end

function GoldTracker:OpenFarmDetailsForItem(itemID)
    local farms = self:GetFarmsForItem(itemID)
    if #farms == 0 then
        return false
    end
    return self:OpenFarmDetails(farms[1].id, { itemID = itemID, farms = farms })
end

function GoldTracker:OpenFarmDetailsForPet(petID)
    local farms = self:GetFarmsForPet(petID)
    if #farms == 0 then
        return false
    end
    return self:OpenFarmDetails(farms[1].id, { farms = farms })
end

function GoldTracker:OpenFarmDetailsForRecordID(recordID)
    local farms = self:GetFarmsForRecordID(recordID)
    if #farms == 0 then
        return false
    end
    return self:OpenFarmDetails(farms[1].id, { farms = farms })
end
