local ADDON_NAME, NS = ...

local GoldTracker = NS.GoldTracker or CreateFrame("Frame")
NS.GoldTracker = GoldTracker

GoldTracker.ADDON_NAME = ADDON_NAME
GoldTracker.PREFIX = "|cffffd200[General Gold Tracker]|r"
GoldTracker.COPPER_PER_GOLD = 10000
GoldTracker.MIN_INTERFACE = 120000
GoldTracker.REQUIRED_PROJECT = WOW_PROJECT_MAINLINE
GoldTracker.LEGACY_DEFAULT_WINDOW_WIDTH = 680
GoldTracker.PREVIOUS_DEFAULT_WINDOW_WIDTH = 760
GoldTracker.OLDER_DEFAULT_WINDOW_WIDTH = 790
GoldTracker.WORLD_MAP_PROJECTION_PIN_SCALE_MIN = 0.6
GoldTracker.WORLD_MAP_PROJECTION_PIN_SCALE_MAX = 2.0
GoldTracker.WORLD_MAP_PROJECTION_PIN_SCALE_STEP = 0.1
-- Code-only feature flag. This is intentionally not mirrored to saved variables or options.
local ENABLE_TOTAL_WINDOW_FEATURE = false

GoldTracker.INVENTORY_CATEGORY_ALL_ID = "all"
GoldTracker.INVENTORY_CATEGORY_OPTIONS = {
    { id = GoldTracker.INVENTORY_CATEGORY_ALL_ID, label = "All categories" },
    { id = "crafting", label = "Crafting Items" },
    { id = "consumables", label = "Consumables" },
    { id = "armorWeapons", label = "Armour and Weapons" },
    { id = "transmog", label = "Transmog" },
    { id = "uncategorized", label = "Uncategorized" },
}
GoldTracker.INVENTORY_CATEGORY_DEFAULT_ORDER = {
    "crafting",
    "consumables",
    "armorWeapons",
    "transmog",
    "uncategorized",
}
GoldTracker.INVENTORY_CATEGORY_BY_ID = {}
for categoryIndex, category in ipairs(GoldTracker.INVENTORY_CATEGORY_OPTIONS) do
    category.sortIndex = categoryIndex
    GoldTracker.INVENTORY_CATEGORY_BY_ID[category.id] = category
end

GoldTracker.SESSION_STYLE_ALL_ID = "all"
GoldTracker.SESSION_STYLE_OPTIONS = {
    { id = GoldTracker.SESSION_STYLE_ALL_ID, label = "All" },
    { id = "crafting", label = "Crafting Reagents" },
    { id = "armorWeapons", label = "Armour and Weapons" },
    { id = "other", label = "Other" },
}
GoldTracker.SESSION_STYLE_BY_ID = {}
for _, style in ipairs(GoldTracker.SESSION_STYLE_OPTIONS) do
    GoldTracker.SESSION_STYLE_BY_ID[style.id] = style
end

GoldTracker.DEFAULTS = {
    valueSource = "TSM_DBMINBUYOUT",
    sessionStyleFilter = GoldTracker.SESSION_STYLE_ALL_ID,
    fallbackValueSource = "TSM_AUCTIONINGOPNORMAL",
    auctionableInventoryValueSource = "TSM_DBMINBUYOUT",
    autoOpenAuctionableInventoryOnAuctionHouse = true,
    rareFarmingValueSource = "TSM_DBMARKET",
    rareFarmingMinimumValue = 100000,
    rareFarmingExpansionFilter = "current",
    rareFarmingScanMode = "background",
    rareFarmingShared = {
        scanCache = {},
        favorites = {},
    },
    farmingItemFavorites = {},
    rareFarmingScanCache = {},
    rareFarmingFavorites = {},
    instanceFarmingValueSource = "TSM_DBMARKET",
    instanceFarmingMinimumValue = 100000,
    instanceFarmingExpansionFilter = "current",
    instanceFarmingContentTypeFilter = "all",
    instanceFarmingScanMode = "background",
    instanceFarmingShared = {
        scanCache = {},
        favorites = {},
    },
    instanceFarmingScanCache = {},
    instanceFarmingFavorites = {},
    craftingFarmingValueSource = "TSM_DBMINBUYOUT",
    craftingFarmingExpansionID = "burningCrusade",
    craftingFarmingProfessionID = "mining",
    craftingFarmingProfessionIDs = { "mining" },
    craftingFarmingCustomItems = {},
    craftingFarmingItemOverrides = {},
    craftingFarmingDropRates = {},
    explorerTab = "rares",
    inventoryCategoryOrder = {
        "crafting",
        "consumables",
        "armorWeapons",
        "transmog",
        "uncategorized",
    },
    minimumTrackedItemQuality = 0,
    highlightThreshold = 100000,
    notificationsEnabled = true,
    autoStartSessionOnFirstLoot = true,
    autoStartSessionOnEnterWorld = false,
    autoStartSessionOnLocationChange = false,
    resumeSessionAfterReload = false,
    enableSessionHistory = true,
    historyRowsPerPage = 10,
    historyDetailsFontSize = 14,
    showRawLootedGoldInLog = true,
    ignoreMailboxLootWhenMailOpen = true,
    showMainWindowGoldPerHour = true,
    showTotalWindowGoldPerHour = true,
    enableChatLogging = true,
    mainWindowSlashOpenMode = "maximized",
    useActiveTimeForGoldPerHour = false,
    allowResumeHistorySession = true,
    enableLootSourceTracking = true,
    enableObservedWorldDrops = false,
    observedWorldDropsValueSource = "TSM_DBMARKET",
    observedWorldDropsMinimumValue = 0,
    observedWorldDropsExpansionFilter = "all",
    observedWorldDrops = {},
    observedSavedSessionDrops = {},
    observedSavedSessionDropsScannedAt = nil,
    showLootLogTimestamps = true,
    mainLootStreamExpanded = false,
    mainWindowTransparent = false,
    enableDiagnosticsPanel = false,
    minimapButtonAngle = 225,
    windowWidth = 780,
    collapsedWindowWidth = 388,
    windowHeight = 500,
    marketHistoryRetentionDays = 120,
    marketHistoryMaxItems = 500,
    marketHistoryMaxSnapshotsPerItem = 240,
    priceIncreaseAlertThresholdPercent = 30,
    priceIncreaseAlertLookbackDays = 3,
    priceIncreaseAlertMinimumSamples = 2,
    worldMapProjectionPinScale = 1.0,
}

GoldTracker.VALUE_SOURCES = {
    { id = "TSM_DBMARKET", label = "Market Value", tsmKey = "DBMarket" },
    { id = "TSM_DBRECENT", label = "Recent Value", tsmKey = "DBRecent" },
    { id = "TSM_DBREGIONMARKETAVG", label = "Region Market Avg", tsmKey = "DBRegionMarketAvg" },
    { id = "TSM_DBMINBUYOUT", label = "Min Buyout", tsmKey = "DBMinBuyout" },
    { id = "TSM_DBHISTORICAL", label = "Historical Price", tsmKey = "DBHistorical" },
    { id = "TSM_DBREGIONHISTORICAL", label = "Region Historical Price", tsmKey = "DBRegionHistorical" },
    { id = "TSM_DBREGIONSALEAVG", label = "Region Sale Avg", tsmKey = "DBRegionSaleAvg" },
    { id = "TSM_AUCTIONINGOPMIN", label = "Auctioning Min", tsmKey = "AuctioningOpMin" },
    { id = "TSM_AUCTIONINGOPNORMAL", label = "Auctioning Normal", tsmKey = "AuctioningOpNormal" },
    { id = "TSM_AUCTIONINGOPMAX", label = "Auctioning Max", tsmKey = "AuctioningOpMax" },
    { id = "TSM_CRAFTING", label = "Crafting Cost", tsmKey = "Crafting" },
}

local CRAFTING_FARMING_GATHERING_PROFESSIONS = {
    mining = true,
    herbalism = true,
    skinning = true,
    fishing = true,
}

local function IsCraftingFarmingSessionLearnedItem(item)
    return item
        and (item.learnedFromSession == true or item.importSource == "session" or item.tag == "Session")
end

local function GetBaseCraftingFarmingItemLookup()
    local lookup = {}
    local data = NS and NS.FarmingItems
    if type(data) ~= "table" or type(data.items) ~= "table" then
        return lookup
    end

    for _, item in ipairs(data.items) do
        local itemID = tonumber(item and item.itemID)
        if itemID and itemID > 0 then
            lookup[math.floor(itemID + 0.5)] = true
        end
    end
    return lookup
end

local function NormalizeCraftingFarmingLearnedSource(source)
    return type(source) == "string" and source ~= "" and source or nil
end

local function CopyCraftingFarmingTrackedItem(item)
    local itemID = tonumber(item and item.itemID)
    if itemID then
        itemID = math.floor(itemID + 0.5)
    end
    if not itemID or itemID <= 0 then
        return nil
    end

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

    local copied = {
        itemID = itemID,
        expansion = type(item.expansion) == "string" and item.expansion ~= "" and item.expansion or "all",
        professions = professions,
        tag = type(item.tag) == "string" and item.tag ~= "" and item.tag or "Session",
        custom = true,
    }
    if IsCraftingFarmingSessionLearnedItem(item) then
        copied.learnedFromSession = true
        copied.importSource = "session"
        copied.learnedAt = tonumber(item.learnedAt)
        copied.updatedAt = tonumber(item.updatedAt)
        copied.learnedExpansionSource = NormalizeCraftingFarmingLearnedSource(item.learnedExpansionSource)
        copied.learnedProfessionSource = NormalizeCraftingFarmingLearnedSource(item.learnedProfessionSource)
    elseif type(item.importSource) == "string" and item.importSource ~= "" then
        copied.importSource = item.importSource
        copied.updatedAt = tonumber(item.updatedAt)
    end
    return copied
end

local function CopyCraftingFarmingTrackedDropRate(entry, fallbackItemID)
    local itemID = tonumber(entry and entry.itemID) or tonumber(fallbackItemID)
    if itemID then
        itemID = math.floor(itemID + 0.5)
    end
    if not itemID or itemID <= 0 or type(entry) ~= "table" then
        return nil
    end

    local quantity = math.max(0, tonumber(entry.quantity) or 0)
    local durationSeconds = math.max(0, math.floor((tonumber(entry.durationSeconds) or 0) + 0.5))
    local sessionCount = math.max(0, math.floor((tonumber(entry.sessionCount) or 0) + 0.5))
    local dropPerHour = math.max(0, tonumber(entry.dropPerHour) or 0)
    if dropPerHour <= 0 and quantity > 0 and durationSeconds > 0 then
        dropPerHour = (quantity * 3600) / durationSeconds
    end
    if quantity <= 0 and durationSeconds <= 0 and dropPerHour <= 0 then
        return nil
    end

    return {
        itemID = itemID,
        quantity = quantity,
        durationSeconds = durationSeconds,
        sessionCount = sessionCount,
        dropPerHour = dropPerHour,
    }
end

function GoldTracker:ApplyCraftingFarmingLearnedDataDefaults()
    if type(self.db) ~= "table" then
        return
    end

    local tracked = NS and NS.CraftingFarmingLearnedData
    if type(tracked) ~= "table" then
        return
    end

    if type(tracked.customItems) == "table" then
        if type(self.db.craftingFarmingCustomItems) ~= "table" then
            self.db.craftingFarmingCustomItems = {}
        end
        local seenItems = {}
        for _, item in ipairs(self.db.craftingFarmingCustomItems) do
            local itemID = tonumber(item and item.itemID)
            if itemID then
                seenItems[math.floor(itemID + 0.5)] = true
            end
        end
        for _, item in ipairs(tracked.customItems) do
            local copied = CopyCraftingFarmingTrackedItem(item)
            if copied and not seenItems[copied.itemID] then
                self.db.craftingFarmingCustomItems[#self.db.craftingFarmingCustomItems + 1] = copied
                seenItems[copied.itemID] = true
            end
        end
    end

    local trackedRates = type(tracked.dropRates) == "table" and tracked.dropRates or {}
    local trackedItems = type(trackedRates.items) == "table" and trackedRates.items or {}
    if next(trackedItems) then
        if type(self.db.craftingFarmingDropRates) ~= "table" then
            self.db.craftingFarmingDropRates = {}
        end
        if type(self.db.craftingFarmingDropRates.items) ~= "table" then
            self.db.craftingFarmingDropRates.items = {}
        end

        for key, entry in pairs(trackedItems) do
            local copied = CopyCraftingFarmingTrackedDropRate(entry, key)
            if copied and self.db.craftingFarmingDropRates.items[tostring(copied.itemID)] == nil then
                self.db.craftingFarmingDropRates.items[tostring(copied.itemID)] = copied
            end
        end
        if not self.db.craftingFarmingDropRates.updatedAt then
            self.db.craftingFarmingDropRates.updatedAt = tonumber(trackedRates.updatedAt)
        end
    end
end

GoldTracker.VALUE_SOURCE_BY_ID = {}
GoldTracker.VALUE_SOURCE_BY_TSM_KEY = {}
for _, source in ipairs(GoldTracker.VALUE_SOURCES) do
    GoldTracker.VALUE_SOURCE_BY_ID[source.id] = source
    if type(source.tsmKey) == "string" then
        GoldTracker.VALUE_SOURCE_BY_TSM_KEY[string.lower(source.tsmKey)] = source
    end
end

GoldTracker.VALUE_SOURCE_LABEL_ALIASES = {
    ["tsm market value"] = "Market Value",
    ["tsm recent value"] = "Recent Value",
    ["tsm region market value"] = "Region Market Avg",
    ["tsm min buyout"] = "Min Buyout",
    ["tsm historical price"] = "Historical Price",
    ["tsm region historical price"] = "Region Historical Price",
    ["tsm region sale avg"] = "Region Sale Avg",
    ["tsm auctioning min"] = "Auctioning Min",
    ["tsm auctioning normal"] = "Auctioning Normal",
    ["tsm auctioning max"] = "Auctioning Max",
    ["tsm crafting"] = "Crafting Cost",
    ["dbmarket"] = "Market Value",
    ["dbrecent"] = "Recent Value",
    ["dbregionmarketavg"] = "Region Market Avg",
    ["dbminbuyout"] = "Min Buyout",
    ["dbhistorical"] = "Historical Price",
    ["dbregionhistorical"] = "Region Historical Price",
    ["dbregionsaleavg"] = "Region Sale Avg",
    ["auctioningopmin"] = "Auctioning Min",
    ["auctioningopnormal"] = "Auctioning Normal",
    ["auctioningopmax"] = "Auctioning Max",
    ["crafting"] = "Crafting Cost",
    ["selected value"] = "Selected Value",
    ["region market avg"] = "Region Market Avg",
    ["region historical"] = "Region Historical Price",
    ["region sale avg"] = "Region Sale Avg",
    ["auctioning min"] = "Auctioning Min",
    ["auctioning normal"] = "Auctioning Normal",
    ["auctioning max"] = "Auctioning Max",
}

GoldTracker.MAIN_WINDOW_SLASH_OPEN_MODES = {
    { id = "maximized", label = "Maximized" },
    { id = "minimized", label = "Minimized" },
    { id = "tiny", label = "Tiny" },
}
GoldTracker.MAIN_WINDOW_SLASH_OPEN_MODE_BY_ID = {}
for _, openMode in ipairs(GoldTracker.MAIN_WINDOW_SLASH_OPEN_MODES) do
    GoldTracker.MAIN_WINDOW_SLASH_OPEN_MODE_BY_ID[openMode.id] = openMode
end

GoldTracker.MINIMUM_TRACKED_ITEM_QUALITIES = { 0, 1, 2, 3, 4, 5 }
GoldTracker.TRACKED_ITEM_QUALITY_OPTIONS = {}
GoldTracker.TRACKED_ITEM_QUALITY_BY_ID = {}
GoldTracker.ITEM_QUALITY_BY_LINK_COLOR = {}

local function GetFarmingFavoriteKeyFromEntry(entry, fallbackItemID)
    local itemID
    if type(entry) == "table" then
        itemID = tonumber(entry.itemID)
    else
        itemID = tonumber(entry)
    end
    itemID = itemID or tonumber(fallbackItemID)
    if not itemID then
        return nil
    end
    return "item:" .. tostring(math.floor(itemID + 0.5))
end

local function MergeFarmingFavoriteEntry(target, source, sourceType)
    if type(target) ~= "table" or type(source) ~= "table" then
        return
    end
    for key, value in pairs(source) do
        if target[key] == nil then
            target[key] = value
        end
    end
    target.farmingSourceType = target.farmingSourceType or source.farmingSourceType or sourceType
end

local function MigrateFarmingFavoriteEntries(target, source, sourceType)
    if type(target) ~= "table" or type(source) ~= "table" then
        return
    end

    for _, favoriteEntry in pairs(source) do
        if type(favoriteEntry) == "table" then
            local sharedKey = GetFarmingFavoriteKeyFromEntry(favoriteEntry)
            if sharedKey then
                if type(target[sharedKey]) ~= "table" then
                    target[sharedKey] = favoriteEntry
                    target[sharedKey].farmingSourceType = target[sharedKey].farmingSourceType or sourceType
                else
                    MergeFarmingFavoriteEntry(target[sharedKey], favoriteEntry, sourceType)
                end
                target[sharedKey].favoriteKey = sharedKey
            end
        end
    end
end

function GoldTracker:GetFarmingFavoriteKey(rowOrItemID, itemID)
    if type(rowOrItemID) == "table" then
        return GetFarmingFavoriteKeyFromEntry(rowOrItemID, itemID)
    end
    return GetFarmingFavoriteKeyFromEntry(itemID or rowOrItemID)
end

function GoldTracker:GetFarmingFavoriteStore()
    if type(self.db) ~= "table" then
        return nil
    end
    if type(self.db.farmingItemFavorites) ~= "table" then
        self.db.farmingItemFavorites = {}
    end
    self.db.rareFarmingFavorites = self.db.farmingItemFavorites
    self.db.instanceFarmingFavorites = self.db.farmingItemFavorites
    if type(self.db.rareFarmingShared) == "table" then
        self.db.rareFarmingShared.favorites = self.db.farmingItemFavorites
    end
    if type(self.db.instanceFarmingShared) == "table" then
        self.db.instanceFarmingShared.favorites = self.db.farmingItemFavorites
    end
    return self.db.farmingItemFavorites
end

function GoldTracker:IsFarmingItemFavorite(rowOrItemID, itemID)
    local key = self:GetFarmingFavoriteKey(rowOrItemID, itemID)
    local favorites = self:GetFarmingFavoriteStore()
    return key ~= nil and type(favorites) == "table" and favorites[key] ~= nil
end

local function NormalizeColorHex(colorHex)
    if type(colorHex) ~= "string" then
        return nil
    end

    local cleaned = colorHex:gsub("|[cC]", ""):gsub("#", "")
    local eightDigits = cleaned:match("([%x][%x][%x][%x][%x][%x][%x][%x])")
    if eightDigits then
        return string.lower(eightDigits)
    end

    local sixDigits = cleaned:match("([%x][%x][%x][%x][%x][%x])")
    if sixDigits then
        return string.lower("ff" .. sixDigits)
    end

    return nil
end

if type(ITEM_QUALITY_COLORS) == "table" then
    for quality, colorData in pairs(ITEM_QUALITY_COLORS) do
        if type(quality) == "number" and type(colorData) == "table" then
            local normalizedHex = NormalizeColorHex(colorData.hex)
            if normalizedHex then
                GoldTracker.ITEM_QUALITY_BY_LINK_COLOR[normalizedHex] = quality
            end
        end
    end
end

for _, itemQuality in ipairs(GoldTracker.MINIMUM_TRACKED_ITEM_QUALITIES) do
    local label = _G["ITEM_QUALITY" .. itemQuality .. "_DESC"] or tostring(itemQuality)
    local option = {
        id = itemQuality,
        label = label,
    }
    GoldTracker.TRACKED_ITEM_QUALITY_OPTIONS[#GoldTracker.TRACKED_ITEM_QUALITY_OPTIONS + 1] = option
    GoldTracker.TRACKED_ITEM_QUALITY_BY_ID[itemQuality] = option
end

GoldTracker.session = GoldTracker.session or {
    active = false,
    startTime = nil,
    stopTime = nil,
    goldLooted = 0,
    itemValue = 0,
    itemVendorValue = 0,
    sessionStyleFilter = GoldTracker.SESSION_STYLE_ALL_ID,
    highlightItemCount = 0,
    itemLoots = {},
    moneyLoots = {},
    diagnosisSnapshot = nil,
    isInstanced = false,
    instanceName = nil,
    instanceMapID = nil,
    instanceType = nil,
    zoneName = nil,
    locationKey = nil,
    mapID = nil,
    mapName = nil,
    mapPath = nil,
    continentName = nil,
    expansionID = nil,
    expansionName = nil,
    activeDurationSeconds = 0,
    wasResumed = false,
    resumeCount = 0,
    resumedAt = nil,
    resumedFromHistory = false,
    resumedFromHistoryAt = nil,
    lastResumedFromHistoryAt = nil,
    resumedFromHistorySessionIDs = nil,
    resumedFromHistorySessionNames = nil,
}

GoldTracker.tsmWarningShown = false

function GoldTracker:Trim(text)
    if not text then
        return ""
    end
    return (text:gsub("^%s+", ""):gsub("%s+$", ""))
end

function GoldTracker:NormalizeValueSourceLabel(label)
    if type(label) ~= "string" or label == "" then
        return "Unknown"
    end

    if string.find(label, ",", 1, true) then
        local labels = {}
        local seen = {}
        for part in string.gmatch(label, "([^,]+)") do
            local normalizedPart = self:NormalizeValueSourceLabel(part)
            if normalizedPart ~= "" and not seen[normalizedPart] then
                seen[normalizedPart] = true
                labels[#labels + 1] = normalizedPart
            end
        end
        return #labels > 0 and table.concat(labels, ", ") or "Unknown"
    end

    local trimmed = self:Trim(label)
    if trimmed == "" then
        return "Unknown"
    end

    local source = self.VALUE_SOURCE_BY_ID[trimmed]
    if source then
        return source.label
    end

    local key = string.lower(trimmed)
    source = self.VALUE_SOURCE_BY_TSM_KEY[key]
    if source then
        return source.label
    end

    return self.VALUE_SOURCE_LABEL_ALIASES[key] or trimmed
end

function GoldTracker:GetValueSourceLabel(valueSourceID, fallbackLabel)
    local source = type(valueSourceID) == "string" and self.VALUE_SOURCE_BY_ID[valueSourceID] or nil
    if source then
        return source.label
    end

    return self:NormalizeValueSourceLabel(fallbackLabel)
end

function GoldTracker:FormatMoney(copper)
    local clamped = math.max(0, math.floor(copper or 0))
    return GetMoneyString(clamped, true)
end

function GoldTracker:GetPerHourValue(totalCopper, durationSeconds)
    local total = tonumber(totalCopper) or 0
    local seconds = tonumber(durationSeconds) or 0
    if seconds <= 0 then
        return nil
    end

    return math.max(0, math.floor(((total * 3600) / seconds) + 0.5))
end

function GoldTracker:FormatMoneyPerHour(totalCopper, durationSeconds)
    local perHourValue = self:GetPerHourValue(totalCopper, durationSeconds)
    if not perHourValue then
        return "---"
    end

    return string.format("%s/h", self:FormatMoney(perHourValue))
end

function GoldTracker:FormatDuration(totalSeconds)
    local seconds = math.max(0, math.floor(totalSeconds or 0))
    local hours = math.floor(seconds / 3600)
    local minutes = math.floor((seconds % 3600) / 60)
    local secs = seconds % 60
    return string.format("%02d:%02d:%02d", hours, minutes, secs)
end

function GoldTracker:GetItemIDFromLink(itemLink)
    if not itemLink then
        return nil
    end
    return tonumber(itemLink:match("item:(%d+)"))
end

function GoldTracker:GetTSMItemStringFromLink(itemLink)
    if not itemLink then
        return nil
    end

    local itemID = self:GetItemIDFromLink(itemLink)
    if itemID then
        return string.format("i:%d", itemID)
    end

    local speciesID = tonumber(itemLink:match("battlepet:(%d+)"))
    if speciesID then
        return string.format("p:%d", speciesID)
    end

    return nil
end

function GoldTracker:GetClickableItemLink(itemLinkOrRow, fallbackItemID)
    local itemLink = itemLinkOrRow
    local itemID = fallbackItemID

    if type(itemLinkOrRow) == "table" then
        itemLink = itemLinkOrRow.itemLink
        itemID = itemLinkOrRow.itemID or fallbackItemID
    end

    if type(itemLink) == "string" and itemLink ~= "" then
        return itemLink
    end

    local normalizedItemID = tonumber(itemID)
    if normalizedItemID and normalizedItemID > 0 then
        return "item:" .. tostring(math.floor(normalizedItemID + 0.5))
    end

    return nil
end

function GoldTracker:IsItemClickModified()
    return (IsShiftKeyDown and IsShiftKeyDown())
        or (IsControlKeyDown and IsControlKeyDown())
        or (IsAltKeyDown and IsAltKeyDown())
end

function GoldTracker:HandleModifiedItemClick(itemLinkOrRow, fallbackItemID)
    local itemLink = self:GetClickableItemLink(itemLinkOrRow, fallbackItemID)
    if type(itemLink) ~= "string" or itemLink == "" or type(HandleModifiedItemClick) ~= "function" then
        return false
    end

    local ok, handled = pcall(HandleModifiedItemClick, itemLink)
    return ok and handled == true
end

function GoldTracker:HandleModifiedItemClickIfModified(itemLinkOrRow, fallbackItemID)
    if not self:IsItemClickModified() then
        return false
    end

    return self:HandleModifiedItemClick(itemLinkOrRow, fallbackItemID)
end

function GoldTracker:GetLootItemMetadata(itemLink)
    local metadata = {
        itemID = self:GetItemIDFromLink(itemLink),
    }
    if type(itemLink) ~= "string" or itemLink == "" then
        return metadata
    end

    if C_Item and type(C_Item.GetItemInfo) == "function" then
        local ok, name, link, quality, _, _, itemType, itemSubType, _, itemEquipLoc, icon, _, itemClassID, itemSubclassID, _, _, isCraftingReagent =
            pcall(C_Item.GetItemInfo, itemLink)
        if ok then
            metadata.itemName = name
            metadata.itemLink = link
            metadata.itemQuality = tonumber(quality)
            metadata.itemType = itemType
            metadata.itemSubType = itemSubType
            metadata.itemEquipLoc = itemEquipLoc
            metadata.icon = icon
            metadata.itemClassID = tonumber(itemClassID)
            metadata.itemSubclassID = tonumber(itemSubclassID)
            if type(isCraftingReagent) == "boolean" then
                metadata.isCraftingReagent = isCraftingReagent
            end
        end
    elseif type(GetItemInfo) == "function" then
        local name, link, quality, _, _, itemType, itemSubType, _, itemEquipLoc, icon, _, itemClassID, itemSubclassID, _, _, isCraftingReagent =
            GetItemInfo(itemLink)
        metadata.itemName = name
        metadata.itemLink = link
        metadata.itemQuality = tonumber(quality)
        metadata.itemType = itemType
        metadata.itemSubType = itemSubType
        metadata.itemEquipLoc = itemEquipLoc
        metadata.icon = icon
        metadata.itemClassID = tonumber(itemClassID)
        metadata.itemSubclassID = tonumber(itemSubclassID)
        if type(isCraftingReagent) == "boolean" then
            metadata.isCraftingReagent = isCraftingReagent
        end
    end

    if type(GetItemInfoInstant) == "function" then
        local ok, itemID, itemType, itemSubType, itemEquipLoc, icon, itemClassID, itemSubclassID =
            pcall(GetItemInfoInstant, itemLink)
        if ok then
            metadata.itemID = tonumber(itemID) or metadata.itemID
            metadata.itemType = metadata.itemType or itemType
            metadata.itemSubType = metadata.itemSubType or itemSubType
            metadata.itemEquipLoc = metadata.itemEquipLoc or itemEquipLoc
            metadata.icon = metadata.icon or icon
            metadata.itemClassID = tonumber(metadata.itemClassID) or tonumber(itemClassID)
            metadata.itemSubclassID = tonumber(metadata.itemSubclassID) or tonumber(itemSubclassID)
        end
    end

    return metadata
end

function GoldTracker:NormalizeSessionStyleFilter(styleID)
    if type(styleID) == "string" and self.SESSION_STYLE_BY_ID[styleID] then
        return styleID
    end
    return self.DEFAULTS.sessionStyleFilter or self.SESSION_STYLE_ALL_ID
end

function GoldTracker:GetSessionStyleFilter()
    return self:NormalizeSessionStyleFilter(self.db and self.db.sessionStyleFilter)
end

function GoldTracker:SetSessionStyleFilter(styleID)
    local normalizedStyleID = self:NormalizeSessionStyleFilter(styleID)
    if self.db then
        self.db.sessionStyleFilter = normalizedStyleID
    end
    if self.session then
        self.session.sessionStyleFilter = normalizedStyleID
    end
    if self.mainFrame and self.session and type(self.ImportSessionLootsToMainLootLog) == "function" then
        self:ImportSessionLootsToMainLootLog(self.session.itemLoots, self.session.moneyLoots, true)
    end
    if type(self.UpdateMainWindow) == "function" then
        self:UpdateMainWindow()
    end
    return normalizedStyleID
end

function GoldTracker:GetSessionStyleLabel(styleID)
    local normalizedStyleID = self:NormalizeSessionStyleFilter(styleID)
    local option = self.SESSION_STYLE_BY_ID[normalizedStyleID]
    return option and option.label or "All"
end

function GoldTracker:GetLootItemSessionStyle(entry)
    if type(entry) ~= "table" then
        return "other"
    end
    if entry.isCraftingReagent == true then
        return "crafting"
    end

    local itemClassID = tonumber(entry.itemClassID)
    if not itemClassID and type(entry.itemLink) == "string" and entry.itemLink ~= "" then
        local metadata = self:GetLootItemMetadata(entry.itemLink)
        itemClassID = tonumber(metadata.itemClassID)
        if entry.isCraftingReagent == nil then
            entry.isCraftingReagent = metadata.isCraftingReagent == true or self:IsCraftingReagentItem(entry.itemLink)
        end
        entry.itemID = entry.itemID or metadata.itemID
        entry.itemClassID = itemClassID
        entry.itemSubclassID = entry.itemSubclassID or metadata.itemSubclassID
        entry.itemType = entry.itemType or metadata.itemType
        entry.itemSubType = entry.itemSubType or metadata.itemSubType
        entry.itemEquipLoc = entry.itemEquipLoc or metadata.itemEquipLoc
    end
    if entry.isCraftingReagent == true then
        return "crafting"
    end

    local weaponClassID = (Enum and Enum.ItemClass and Enum.ItemClass.Weapon) or LE_ITEM_CLASS_WEAPON or 2
    local armorClassID = (Enum and Enum.ItemClass and Enum.ItemClass.Armor) or LE_ITEM_CLASS_ARMOR or 4
    if tonumber(itemClassID) == tonumber(weaponClassID)
        or tonumber(itemClassID) == tonumber(armorClassID)
        or entry.itemType == "Weapon"
        or entry.itemType == "Armor" then
        return "armorWeapons"
    end

    return "other"
end

function GoldTracker:LootItemMatchesSessionStyle(entry, styleID)
    local normalizedStyleID = self:NormalizeSessionStyleFilter(styleID)
    if normalizedStyleID == self.SESSION_STYLE_ALL_ID then
        return true
    end
    return self:GetLootItemSessionStyle(entry) == normalizedStyleID
end

function GoldTracker:BuildSessionViewSummary(session, styleID)
    local resolvedSession = type(session) == "table" and session or self.session or {}
    local normalizedStyleID = self:NormalizeSessionStyleFilter(styleID)
    local highlightCount = tonumber(resolvedSession.highlightItemCount)
    if not highlightCount then
        highlightCount = (tonumber(resolvedSession.lowHighlightItemCount) or 0)
            + (tonumber(resolvedSession.highHighlightItemCount) or 0)
    end

    if normalizedStyleID == self.SESSION_STYLE_ALL_ID then
        local rawGold = tonumber(resolvedSession.goldLooted or resolvedSession.rawGold) or 0
        local itemsValue = tonumber(resolvedSession.itemValue or resolvedSession.itemsValue) or 0
        local itemsRawGold = tonumber(resolvedSession.itemVendorValue or resolvedSession.itemsRawGold) or 0
        return {
            styleID = normalizedStyleID,
            rawGold = rawGold,
            itemsValue = itemsValue,
            itemsRawGold = itemsRawGold,
            totalValue = rawGold + itemsValue,
            rawTotal = rawGold + itemsRawGold,
            highlightItemCount = math.max(0, math.floor((highlightCount or 0) + 0.5)),
        }
    end

    local summary = {
        styleID = normalizedStyleID,
        rawGold = 0,
        itemsValue = 0,
        itemsRawGold = 0,
        totalValue = 0,
        rawTotal = 0,
        highlightItemCount = 0,
    }
    local threshold = self:GetHighlightThreshold()
    for _, loot in ipairs(resolvedSession.itemLoots or {}) do
        if self:LootItemMatchesSessionStyle(loot, normalizedStyleID) then
            local totalValue = tonumber(loot.totalValue) or 0
            summary.itemsValue = summary.itemsValue + totalValue
            summary.itemsRawGold = summary.itemsRawGold + (tonumber(loot.vendorTotalValue) or 0)
            if loot.isHighlighted == true or (totalValue > 0 and totalValue >= threshold) then
                summary.highlightItemCount = summary.highlightItemCount + 1
            end
        end
    end
    summary.totalValue = summary.rawGold + summary.itemsValue
    summary.rawTotal = summary.rawGold + summary.itemsRawGold
    return summary
end

function GoldTracker:Print(message)
    if not self:IsChatLoggingEnabled() then
        return
    end

    local text = string.format("%s %s", self.PREFIX, tostring(message))
    if DEFAULT_CHAT_FRAME and DEFAULT_CHAT_FRAME.AddMessage then
        DEFAULT_CHAT_FRAME:AddMessage(text)
    else
        print(text)
    end
end

function GoldTracker:NormalizeInventoryCategoryOrder()
    if type(self.db) ~= "table" then
        return self.INVENTORY_CATEGORY_DEFAULT_ORDER
    end

    local savedOrder = type(self.db.inventoryCategoryOrder) == "table" and self.db.inventoryCategoryOrder or {}
    local normalizedOrder = {}
    local seenCategoryIDs = {}

    for _, categoryID in ipairs(savedOrder) do
        if self.INVENTORY_CATEGORY_BY_ID[categoryID]
            and categoryID ~= self.INVENTORY_CATEGORY_ALL_ID
            and not seenCategoryIDs[categoryID] then
            normalizedOrder[#normalizedOrder + 1] = categoryID
            seenCategoryIDs[categoryID] = true
        end
    end

    for _, categoryID in ipairs(self.INVENTORY_CATEGORY_DEFAULT_ORDER) do
        if not seenCategoryIDs[categoryID] then
            normalizedOrder[#normalizedOrder + 1] = categoryID
            seenCategoryIDs[categoryID] = true
        end
    end

    self.db.inventoryCategoryOrder = normalizedOrder
    return normalizedOrder
end

function GoldTracker:GetInventoryCategoryOrder()
    if type(self.db) ~= "table" then
        return self.INVENTORY_CATEGORY_DEFAULT_ORDER
    end
    return self:NormalizeInventoryCategoryOrder()
end

function GoldTracker:SetInventoryCategoryOrder(categoryOrder)
    if type(self.db) ~= "table" then
        return
    end
    self.db.inventoryCategoryOrder = type(categoryOrder) == "table" and categoryOrder or self.INVENTORY_CATEGORY_DEFAULT_ORDER
    self:NormalizeInventoryCategoryOrder()
    if self.inventoryFrame and self.inventoryFrame:IsShown() then
        self:RefreshInventoryWindow(false)
    end
end

function GoldTracker:MoveInventoryCategory(categoryID, targetIndex)
    if not self.INVENTORY_CATEGORY_BY_ID[categoryID] or categoryID == self.INVENTORY_CATEGORY_ALL_ID then
        return
    end

    local currentOrder = self:GetInventoryCategoryOrder()
    local nextOrder = {}
    for _, currentCategoryID in ipairs(currentOrder) do
        if currentCategoryID ~= categoryID then
            nextOrder[#nextOrder + 1] = currentCategoryID
        end
    end

    local normalizedTargetIndex = math.max(1, math.min(#nextOrder + 1, math.floor((tonumber(targetIndex) or 1) + 0.5)))
    table.insert(nextOrder, normalizedTargetIndex, categoryID)
    self:SetInventoryCategoryOrder(nextOrder)
end

function GoldTracker:NormalizeCraftingFarmingCustomItems()
    if type(self.db) ~= "table" then
        return {}
    end

    local customItems = type(self.db.craftingFarmingCustomItems) == "table" and self.db.craftingFarmingCustomItems or {}
    local baseItems = GetBaseCraftingFarmingItemLookup()
    local normalizedItems = {}
    local seenItems = {}
    for _, item in ipairs(customItems) do
        local itemID = tonumber(item and item.itemID)
        if itemID then
            itemID = math.floor(itemID + 0.5)
        end
        local isSessionLearned = IsCraftingFarmingSessionLearnedItem(item)
        if itemID and itemID > 0 and not seenItems[itemID] and not (isSessionLearned and baseItems[itemID]) then
            local expansionID = type(item.expansion) == "string" and item.expansion or self.DEFAULTS.craftingFarmingExpansionID
            local professions = type(item.professions) == "table" and item.professions or {}
            local normalizedProfessions = {}
            local seenProfessions = {}
            for _, professionID in ipairs(professions) do
                if type(professionID) == "string" and professionID ~= "" and not seenProfessions[professionID] then
                    normalizedProfessions[#normalizedProfessions + 1] = professionID
                    seenProfessions[professionID] = true
                end
            end
            if #normalizedProfessions == 0 then
                normalizedProfessions[1] = self.DEFAULTS.craftingFarmingProfessionID
            end
            local learnedExpansionSource = NormalizeCraftingFarmingLearnedSource(item.learnedExpansionSource)
            local learnedProfessionSource = NormalizeCraftingFarmingLearnedSource(item.learnedProfessionSource)
            if isSessionLearned then
                if not learnedExpansionSource then
                    expansionID = "all"
                end
                if not learnedProfessionSource then
                    local hasUntrustedGatheringProfession = false
                    for _, professionID in ipairs(normalizedProfessions) do
                        if CRAFTING_FARMING_GATHERING_PROFESSIONS[professionID] then
                            hasUntrustedGatheringProfession = true
                            break
                        end
                    end
                    if hasUntrustedGatheringProfession then
                        normalizedProfessions = { "all" }
                    end
                end
            end

            local normalizedItem = {
                itemID = itemID,
                expansion = expansionID,
                professions = normalizedProfessions,
                tag = type(item.tag) == "string" and item.tag ~= "" and item.tag or "Custom",
                custom = true,
            }
            if isSessionLearned then
                normalizedItem.learnedFromSession = true
                normalizedItem.importSource = "session"
                normalizedItem.learnedAt = tonumber(item.learnedAt)
                normalizedItem.updatedAt = tonumber(item.updatedAt)
                normalizedItem.learnedExpansionSource = learnedExpansionSource
                normalizedItem.learnedProfessionSource = learnedProfessionSource
            elseif type(item.importSource) == "string" and item.importSource ~= "" then
                normalizedItem.importSource = item.importSource
                normalizedItem.updatedAt = tonumber(item.updatedAt)
            elseif item.updatedAt ~= nil then
                normalizedItem.updatedAt = tonumber(item.updatedAt)
            end
            normalizedItems[#normalizedItems + 1] = normalizedItem
            seenItems[itemID] = true
        end
    end

    self.db.craftingFarmingCustomItems = normalizedItems
    return normalizedItems
end

function GoldTracker:GetCraftingFarmingCustomItems()
    if type(self.db) ~= "table" then
        return {}
    end
    return self:NormalizeCraftingFarmingCustomItems()
end

function GoldTracker:NormalizeCraftingFarmingItemOverrides()
    if type(self.db) ~= "table" then
        return {}
    end

    local overrides = type(self.db.craftingFarmingItemOverrides) == "table" and self.db.craftingFarmingItemOverrides or {}
    local normalizedOverrides = {}
    for key, item in pairs(overrides) do
        local itemID = tonumber((type(item) == "table" and item.itemID) or key)
        if itemID then
            itemID = math.floor(itemID + 0.5)
        end
        if itemID and itemID > 0 and type(item) == "table" then
            local professions = type(item.professions) == "table" and item.professions or {}
            local normalizedProfessions = {}
            local seenProfessions = {}
            for _, professionID in ipairs(professions) do
                if type(professionID) == "string" and professionID ~= "" and professionID ~= "all" and not seenProfessions[professionID] then
                    normalizedProfessions[#normalizedProfessions + 1] = professionID
                    seenProfessions[professionID] = true
                end
            end
            if #normalizedProfessions > 0 then
                normalizedOverrides[tostring(itemID)] = {
                    itemID = itemID,
                    professions = normalizedProfessions,
                    source = type(item.source) == "string" and item.source ~= "" and item.source or "manual",
                    updatedAt = tonumber(item.updatedAt),
                }
            end
        end
    end

    self.db.craftingFarmingItemOverrides = normalizedOverrides
    return normalizedOverrides
end

function GoldTracker:GetCraftingFarmingItemOverrides()
    if type(self.db) ~= "table" then
        return {}
    end
    return self:NormalizeCraftingFarmingItemOverrides()
end

function GoldTracker:GetCraftingFarmingItemOverride(itemID)
    local normalizedItemID = tonumber(itemID)
    if not normalizedItemID then
        return nil
    end
    normalizedItemID = math.floor(normalizedItemID + 0.5)
    return self:GetCraftingFarmingItemOverrides()[tostring(normalizedItemID)]
end

function GoldTracker:SetCraftingFarmingItemProfession(itemID, professionID)
    if type(self.db) ~= "table" or type(professionID) ~= "string" or professionID == "" or professionID == "all" then
        return nil
    end

    local normalizedItemID = tonumber(itemID)
    if not normalizedItemID or normalizedItemID <= 0 then
        return nil
    end
    normalizedItemID = math.floor(normalizedItemID + 0.5)

    self:NormalizeCraftingFarmingCustomItems()
    for _, item in ipairs(self.db.craftingFarmingCustomItems or {}) do
        if tonumber(item and item.itemID) == normalizedItemID then
            item.professions = { professionID }
            if IsCraftingFarmingSessionLearnedItem(item) then
                item.learnedProfessionSource = "manual"
            end
            if type(time) == "function" then
                item.updatedAt = time()
            end
            if self.craftingFarmingFrame then
                self.craftingFarmingFrame.itemCache = {}
                if self.craftingFarmingFrame:IsShown() and type(self.RefreshCraftingFarmingWindow) == "function" then
                    self:RefreshCraftingFarmingWindow(true)
                end
            end
            return item
        end
    end

    self:NormalizeCraftingFarmingItemOverrides()
    local override = {
        itemID = normalizedItemID,
        professions = { professionID },
        source = "manual",
        updatedAt = type(time) == "function" and time() or nil,
    }
    self.db.craftingFarmingItemOverrides[tostring(normalizedItemID)] = override
    if self.craftingFarmingFrame then
        self.craftingFarmingFrame.itemCache = {}
        if self.craftingFarmingFrame:IsShown() and type(self.RefreshCraftingFarmingWindow) == "function" then
            self:RefreshCraftingFarmingWindow(true)
        end
    end
    return override
end

function GoldTracker:AddCraftingFarmingCustomItem(itemID, expansionID, professionID, tag, suppressRefresh, metadata)
    if type(self.db) ~= "table" then
        return nil
    end

    local normalizedItemID = tonumber(itemID)
    if not normalizedItemID or normalizedItemID <= 0 then
        return nil
    end
    normalizedItemID = math.floor(normalizedItemID + 0.5)

    self:NormalizeCraftingFarmingCustomItems()
    local customItems = self.db.craftingFarmingCustomItems
    for index = #customItems, 1, -1 do
        if tonumber(customItems[index] and customItems[index].itemID) == normalizedItemID then
            table.remove(customItems, index)
        end
    end

    local normalizedItem = {
        itemID = normalizedItemID,
        expansion = type(expansionID) == "string" and expansionID ~= "" and expansionID or self.DEFAULTS.craftingFarmingExpansionID,
        professions = {
            type(professionID) == "string" and professionID ~= "" and professionID or self.DEFAULTS.craftingFarmingProfessionID,
        },
        tag = type(tag) == "string" and tag ~= "" and tag or "Custom",
        custom = true,
    }
    if type(metadata) == "table" then
        if metadata.learnedFromSession == true or metadata.importSource == "session" then
            normalizedItem.learnedFromSession = true
            normalizedItem.importSource = "session"
            normalizedItem.learnedAt = tonumber(metadata.learnedAt) or (type(time) == "function" and time() or nil)
            normalizedItem.learnedExpansionSource = NormalizeCraftingFarmingLearnedSource(metadata.learnedExpansionSource)
            normalizedItem.learnedProfessionSource = NormalizeCraftingFarmingLearnedSource(metadata.learnedProfessionSource)
        elseif type(metadata.importSource) == "string" and metadata.importSource ~= "" then
            normalizedItem.importSource = metadata.importSource
        end
    end
    customItems[#customItems + 1] = normalizedItem

    if self.craftingFarmingFrame and suppressRefresh ~= true then
        self.craftingFarmingFrame.itemCache = {}
        if self.craftingFarmingFrame:IsShown() and type(self.RefreshCraftingFarmingWindow) == "function" then
            self:RefreshCraftingFarmingWindow(true)
        end
    end

    return normalizedItem
end

function GoldTracker:InitializeDatabase()
    if type(WoWGeneralGoldTrackerDB) ~= "table" then
        WoWGeneralGoldTrackerDB = {}
    end

    local function CloneDefaultValue(value)
        if type(value) ~= "table" then
            return value
        end

        local copied = {}
        for key, nestedValue in pairs(value) do
            if type(nestedValue) == "table" then
                copied[key] = CloneDefaultValue(nestedValue)
            else
                copied[key] = nestedValue
            end
        end
        return copied
    end

    self.db = WoWGeneralGoldTrackerDB
    local legacyLowThreshold = tonumber(self.db.lowHighlightThreshold)
    local legacyHighThreshold = tonumber(self.db.highHighlightThreshold)
    local legacyNotificationThreshold = tonumber(self.db.notificationThreshold)
    local hadHighValueDropAlerts = self.db.highValueDropAlerts ~= nil
    local hadPreviousPricingDefaults = self.db.valueSource == "TSM_DBMARKET"
        and (self.db.fallbackValueSource == nil or self.db.fallbackValueSource == "")
    local hadAuctionableInventoryValueSource = self.db.auctionableInventoryValueSource ~= nil

    for key, value in pairs(self.DEFAULTS) do
        if self.db[key] == nil then
            self.db[key] = CloneDefaultValue(value)
        end
    end
    self:ApplyCraftingFarmingLearnedDataDefaults()

    if self.db.pricingDefaultsVersion ~= 2 then
        if hadPreviousPricingDefaults then
            self.db.valueSource = self.DEFAULTS.valueSource
            self.db.fallbackValueSource = self.DEFAULTS.fallbackValueSource
        end
        self.db.pricingDefaultsVersion = 2
    end

    if not self.VALUE_SOURCE_BY_ID[self.db.valueSource] then
        self.db.valueSource = self.DEFAULTS.valueSource
    end
    self.db.sessionStyleFilter = self:NormalizeSessionStyleFilter(self.db.sessionStyleFilter)

    if not hadAuctionableInventoryValueSource then
        self.db.auctionableInventoryValueSource = self.db.valueSource
    end
    if not self.VALUE_SOURCE_BY_ID[self.db.auctionableInventoryValueSource] then
        self.db.auctionableInventoryValueSource = self.DEFAULTS.auctionableInventoryValueSource
    end
    if not self.VALUE_SOURCE_BY_ID[self.db.rareFarmingValueSource] then
        self.db.rareFarmingValueSource = self.DEFAULTS.rareFarmingValueSource
    end
    if not self.VALUE_SOURCE_BY_ID[self.db.instanceFarmingValueSource] then
        self.db.instanceFarmingValueSource = self.DEFAULTS.instanceFarmingValueSource
    end
    if type(self.db.rareFarmingExpansionFilter) ~= "string" or self.db.rareFarmingExpansionFilter == "" then
        self.db.rareFarmingExpansionFilter = self.DEFAULTS.rareFarmingExpansionFilter
    end
    if self.db.rareFarmingScanMode ~= "background" and self.db.rareFarmingScanMode ~= "foreground" then
        self.db.rareFarmingScanMode = self.DEFAULTS.rareFarmingScanMode
    end
    if type(self.db.rareFarmingShared) ~= "table" then
        self.db.rareFarmingShared = {}
    end
    if type(self.db.rareFarmingShared.scanCache) ~= "table" then
        self.db.rareFarmingShared.scanCache = {}
    end
    if type(self.db.rareFarmingShared.favorites) ~= "table" then
        self.db.rareFarmingShared.favorites = {}
    end
    if type(self.db.rareFarmingScanCache) ~= "table" then
        self.db.rareFarmingScanCache = {}
    end
    if type(self.db.rareFarmingFavorites) ~= "table" then
        self.db.rareFarmingFavorites = {}
    end
    for cacheKey, cacheEntry in pairs(self.db.rareFarmingScanCache) do
        if self.db.rareFarmingShared.scanCache[cacheKey] == nil then
            self.db.rareFarmingShared.scanCache[cacheKey] = cacheEntry
        end
    end
    for favoriteKey, favoriteEntry in pairs(self.db.rareFarmingFavorites) do
        if self.db.rareFarmingShared.favorites[favoriteKey] == nil then
            self.db.rareFarmingShared.favorites[favoriteKey] = favoriteEntry
        end
    end
    -- Keep the older field names as runtime aliases so existing rare-farming code
    -- reads and writes the account-wide library.
    self.db.rareFarmingScanCache = self.db.rareFarmingShared.scanCache
    self.db.rareFarmingFavorites = self.db.rareFarmingShared.favorites
    if type(self.db.instanceFarmingExpansionFilter) ~= "string" or self.db.instanceFarmingExpansionFilter == "" then
        self.db.instanceFarmingExpansionFilter = self.DEFAULTS.instanceFarmingExpansionFilter
    end
    if self.db.instanceFarmingContentTypeFilter ~= "all"
        and self.db.instanceFarmingContentTypeFilter ~= "dungeon"
        and self.db.instanceFarmingContentTypeFilter ~= "raid" then
        self.db.instanceFarmingContentTypeFilter = self.DEFAULTS.instanceFarmingContentTypeFilter
    end
    if self.db.instanceFarmingScanMode ~= "background" and self.db.instanceFarmingScanMode ~= "foreground" then
        self.db.instanceFarmingScanMode = self.DEFAULTS.instanceFarmingScanMode
    end
    if type(self.db.instanceFarmingShared) ~= "table" then
        self.db.instanceFarmingShared = {}
    end
    if type(self.db.instanceFarmingShared.scanCache) ~= "table" then
        self.db.instanceFarmingShared.scanCache = {}
    end
    if type(self.db.instanceFarmingShared.favorites) ~= "table" then
        self.db.instanceFarmingShared.favorites = {}
    end
    if type(self.db.instanceFarmingScanCache) ~= "table" then
        self.db.instanceFarmingScanCache = {}
    end
    if type(self.db.instanceFarmingFavorites) ~= "table" then
        self.db.instanceFarmingFavorites = {}
    end
    if type(self.db.farmingItemFavorites) ~= "table" then
        self.db.farmingItemFavorites = {}
    end
    for cacheKey, cacheEntry in pairs(self.db.instanceFarmingScanCache) do
        if self.db.instanceFarmingShared.scanCache[cacheKey] == nil then
            self.db.instanceFarmingShared.scanCache[cacheKey] = cacheEntry
        end
    end
    for favoriteKey, favoriteEntry in pairs(self.db.instanceFarmingFavorites) do
        if self.db.instanceFarmingShared.favorites[favoriteKey] == nil then
            self.db.instanceFarmingShared.favorites[favoriteKey] = favoriteEntry
        end
    end
    self.db.instanceFarmingScanCache = self.db.instanceFarmingShared.scanCache
    self.db.instanceFarmingFavorites = self.db.instanceFarmingShared.favorites
    local sharedFarmingFavorites = {}
    MigrateFarmingFavoriteEntries(sharedFarmingFavorites, self.db.farmingItemFavorites)
    MigrateFarmingFavoriteEntries(sharedFarmingFavorites, self.db.rareFarmingFavorites, "rare")
    MigrateFarmingFavoriteEntries(sharedFarmingFavorites, self.db.instanceFarmingFavorites, "instance")
    self.db.farmingItemFavorites = sharedFarmingFavorites
    self.db.rareFarmingShared.favorites = sharedFarmingFavorites
    self.db.instanceFarmingShared.favorites = sharedFarmingFavorites
    self.db.rareFarmingFavorites = sharedFarmingFavorites
    self.db.instanceFarmingFavorites = sharedFarmingFavorites
    if not self.VALUE_SOURCE_BY_ID[self.db.craftingFarmingValueSource] then
        self.db.craftingFarmingValueSource = self.DEFAULTS.craftingFarmingValueSource
    end
    if type(self.db.craftingFarmingExpansionID) ~= "string" or self.db.craftingFarmingExpansionID == "" then
        self.db.craftingFarmingExpansionID = self.DEFAULTS.craftingFarmingExpansionID
    end
    if type(self.db.craftingFarmingProfessionID) ~= "string" or self.db.craftingFarmingProfessionID == "" then
        self.db.craftingFarmingProfessionID = self.DEFAULTS.craftingFarmingProfessionID
    end
    do
        local selectedProfessionID
        local function setProfession(professionID)
            if type(professionID) ~= "string" or professionID == "" then
                return false
            end
            selectedProfessionID = professionID
            return true
        end

        setProfession(self.db.craftingFarmingProfessionID)
        if not selectedProfessionID and type(self.db.craftingFarmingProfessionIDs) == "table" then
            for _, professionID in ipairs(self.db.craftingFarmingProfessionIDs) do
                if setProfession(professionID) then
                    break
                end
            end
            if not selectedProfessionID then
                for professionID, enabled in pairs(self.db.craftingFarmingProfessionIDs) do
                    if enabled == true and setProfession(professionID) then
                        break
                    end
                end
            end
        end
        selectedProfessionID = selectedProfessionID or self.DEFAULTS.craftingFarmingProfessionID
        self.db.craftingFarmingProfessionID = selectedProfessionID
        self.db.craftingFarmingProfessionIDs = { selectedProfessionID }
    end
    self:NormalizeCraftingFarmingCustomItems()
    self:NormalizeCraftingFarmingItemOverrides()
    local rareFarmingMinimumValue = tonumber(self.db.rareFarmingMinimumValue)
    if not rareFarmingMinimumValue or rareFarmingMinimumValue < 0 then
        rareFarmingMinimumValue = self.DEFAULTS.rareFarmingMinimumValue
    end
    self.db.rareFarmingMinimumValue = math.max(0, math.floor(rareFarmingMinimumValue + 0.5))
    local instanceFarmingMinimumValue = tonumber(self.db.instanceFarmingMinimumValue)
    if not instanceFarmingMinimumValue or instanceFarmingMinimumValue < 0 then
        instanceFarmingMinimumValue = self.DEFAULTS.instanceFarmingMinimumValue
    end
    self.db.instanceFarmingMinimumValue = math.max(0, math.floor(instanceFarmingMinimumValue + 0.5))
    if type(self.db.autoOpenAuctionableInventoryOnAuctionHouse) ~= "boolean" then
        self.db.autoOpenAuctionableInventoryOnAuctionHouse = self.DEFAULTS.autoOpenAuctionableInventoryOnAuctionHouse
    end
    self:NormalizeInventoryCategoryOrder()
    if self.db.auctionHouseSellTabAutoOpenVersion ~= 1 then
        self.db.autoOpenAuctionableInventoryOnAuctionHouse = self.DEFAULTS.autoOpenAuctionableInventoryOnAuctionHouse
        self.db.auctionHouseSellTabAutoOpenVersion = 1
    end

    if type(self.db.fallbackValueSource) ~= "string" then
        self.db.fallbackValueSource = self.DEFAULTS.fallbackValueSource
    end
    if self.db.fallbackValueSource ~= "" and not self.VALUE_SOURCE_BY_ID[self.db.fallbackValueSource] then
        self.db.fallbackValueSource = self.DEFAULTS.fallbackValueSource
    end
    if self.db.fallbackValueSource == self.db.valueSource then
        if self.DEFAULTS.fallbackValueSource ~= self.db.valueSource then
            self.db.fallbackValueSource = self.DEFAULTS.fallbackValueSource
        else
            self.db.fallbackValueSource = ""
        end
    end

    self:NormalizeMinimumTrackedItemQuality()

    local threshold = tonumber(self.db.highlightThreshold)
    if not threshold or threshold < 0 then
        if legacyHighThreshold and legacyHighThreshold >= 0 then
            threshold = legacyHighThreshold
        elseif legacyNotificationThreshold and legacyNotificationThreshold >= 0 then
            threshold = legacyNotificationThreshold
        elseif legacyLowThreshold and legacyLowThreshold >= 0 then
            threshold = legacyLowThreshold
        else
            threshold = self.DEFAULTS.highlightThreshold
        end
    end
    self.db.highlightThreshold = math.max(0, math.floor(threshold + 0.5))
    -- Keep legacy DB keys synchronized for backward compatibility with older saved variables.
    self.db.notificationThreshold = self.db.highlightThreshold
    self.db.lowHighlightThreshold = self.db.highlightThreshold
    self.db.highHighlightThreshold = self.db.highlightThreshold

    if type(self.db.notificationsEnabled) ~= "boolean" then
        self.db.notificationsEnabled = self.DEFAULTS.notificationsEnabled
    end

    if type(self.db.autoStartSessionOnFirstLoot) ~= "boolean" then
        self.db.autoStartSessionOnFirstLoot = self.DEFAULTS.autoStartSessionOnFirstLoot
    end

    if type(self.db.autoStartSessionOnEnterWorld) ~= "boolean" then
        self.db.autoStartSessionOnEnterWorld = self.DEFAULTS.autoStartSessionOnEnterWorld
    end

    if type(self.db.autoStartSessionOnLocationChange) ~= "boolean" then
        self.db.autoStartSessionOnLocationChange = self.DEFAULTS.autoStartSessionOnLocationChange
    end

    if type(self.db.resumeSessionAfterReload) ~= "boolean" then
        self.db.resumeSessionAfterReload = self.DEFAULTS.resumeSessionAfterReload
    end

    if type(self.db.enableSessionHistory) ~= "boolean" then
        self.db.enableSessionHistory = self.DEFAULTS.enableSessionHistory
    end
    if self.db.enableSessionHistoryDefaultVersion ~= 2 then
        if self.db.enableSessionHistory == false then
            self.db.enableSessionHistory = self.DEFAULTS.enableSessionHistory
        end
        self.db.enableSessionHistoryDefaultVersion = 2
    end

    if type(self.db.enableDiagnosticsPanel) ~= "boolean" then
        self.db.enableDiagnosticsPanel = self.DEFAULTS.enableDiagnosticsPanel
    end

    local historyRowsPerPage = tonumber(self.db.historyRowsPerPage)
    if not historyRowsPerPage then
        historyRowsPerPage = self.DEFAULTS.historyRowsPerPage
    end
    self.db.historyRowsPerPage = math.floor(math.max(5, math.min(30, historyRowsPerPage)) + 0.5)

    local historyDetailsFontSize = tonumber(self.db.historyDetailsFontSize)
    if not historyDetailsFontSize then
        historyDetailsFontSize = self.DEFAULTS.historyDetailsFontSize
    end
    if self.db.historyDetailsFontSizeDefaultVersion ~= 2 then
        if historyDetailsFontSize == 12 then
            historyDetailsFontSize = self.DEFAULTS.historyDetailsFontSize
        end
        self.db.historyDetailsFontSizeDefaultVersion = 2
    end
    self.db.historyDetailsFontSize = math.floor(math.max(8, math.min(24, historyDetailsFontSize)) + 0.5)

    if type(self.db.showRawLootedGoldInLog) ~= "boolean" then
        self.db.showRawLootedGoldInLog = self.DEFAULTS.showRawLootedGoldInLog
    end
    if type(self.db.ignoreMailboxLootWhenMailOpen) ~= "boolean" then
        self.db.ignoreMailboxLootWhenMailOpen = self.DEFAULTS.ignoreMailboxLootWhenMailOpen
    end
    if type(self.db.showMainWindowGoldPerHour) ~= "boolean" then
        self.db.showMainWindowGoldPerHour = self.DEFAULTS.showMainWindowGoldPerHour
    end
    if type(self.db.showTotalWindowGoldPerHour) ~= "boolean" then
        self.db.showTotalWindowGoldPerHour = self.DEFAULTS.showTotalWindowGoldPerHour
    end
    if type(self.db.enableChatLogging) ~= "boolean" then
        self.db.enableChatLogging = self.DEFAULTS.enableChatLogging
    end
    if not self.MAIN_WINDOW_SLASH_OPEN_MODE_BY_ID[self.db.mainWindowSlashOpenMode] then
        self.db.mainWindowSlashOpenMode = self.DEFAULTS.mainWindowSlashOpenMode
    end
    if type(self.db.enableLootSourceTracking) ~= "boolean" then
        self.db.enableLootSourceTracking = self.DEFAULTS.enableLootSourceTracking
    end
    if type(self.db.enableObservedWorldDrops) ~= "boolean" then
        self.db.enableObservedWorldDrops = self.DEFAULTS.enableObservedWorldDrops
    end
    if not self.VALUE_SOURCE_BY_ID[self.db.observedWorldDropsValueSource] then
        self.db.observedWorldDropsValueSource = self.DEFAULTS.observedWorldDropsValueSource
    end
    local observedWorldDropsMinimumValue = tonumber(self.db.observedWorldDropsMinimumValue)
    if not observedWorldDropsMinimumValue or observedWorldDropsMinimumValue < 0 then
        observedWorldDropsMinimumValue = self.DEFAULTS.observedWorldDropsMinimumValue
    end
    self.db.observedWorldDropsMinimumValue = math.max(0, math.floor(observedWorldDropsMinimumValue + 0.5))
    if type(self.db.observedWorldDropsExpansionFilter) ~= "string" or self.db.observedWorldDropsExpansionFilter == "" then
        self.db.observedWorldDropsExpansionFilter = self.DEFAULTS.observedWorldDropsExpansionFilter
    end
    if type(self.db.observedWorldDrops) ~= "table" then
        self.db.observedWorldDrops = {}
    end
    if type(self.db.observedSavedSessionDrops) ~= "table" then
        self.db.observedSavedSessionDrops = {}
    end
    if self.db.observedSavedSessionDropsScannedAt ~= nil then
        self.db.observedSavedSessionDropsScannedAt = tonumber(self.db.observedSavedSessionDropsScannedAt)
    end
    if type(self.db.showLootLogTimestamps) ~= "boolean" then
        self.db.showLootLogTimestamps = self.DEFAULTS.showLootLogTimestamps
    end
    if type(self.db.mainLootStreamExpanded) ~= "boolean" then
        self.db.mainLootStreamExpanded = self.DEFAULTS.mainLootStreamExpanded
    end

    if type(self.db.minimapButtonAngle) ~= "number" then
        self.db.minimapButtonAngle = self.DEFAULTS.minimapButtonAngle
    end
    self.db.minimapButtonAngle = self.db.minimapButtonAngle % 360

    self.db.worldMapProjectionPinScale = self:NormalizeWorldMapProjectionPinScale(self.db.worldMapProjectionPinScale)

    if type(self.db.sessionHistory) ~= "table" then
        self.db.sessionHistory = {}
    end
    if type(self.db.marketHistory) ~= "table" then
        self.db.marketHistory = {
            items = {},
        }
    end
    if type(self.db.marketHistory.items) ~= "table" then
        self.db.marketHistory.items = {}
    end
    local marketHistoryRetentionDays = tonumber(self.db.marketHistoryRetentionDays)
    if not marketHistoryRetentionDays then
        marketHistoryRetentionDays = self.DEFAULTS.marketHistoryRetentionDays
    end
    self.db.marketHistoryRetentionDays = math.floor(math.max(14, math.min(365, marketHistoryRetentionDays)) + 0.5)
    local marketHistoryMaxItems = tonumber(self.db.marketHistoryMaxItems)
    if not marketHistoryMaxItems then
        marketHistoryMaxItems = self.DEFAULTS.marketHistoryMaxItems
    end
    self.db.marketHistoryMaxItems = math.floor(math.max(50, math.min(2000, marketHistoryMaxItems)) + 0.5)
    local marketHistoryMaxSnapshotsPerItem = tonumber(self.db.marketHistoryMaxSnapshotsPerItem)
    if not marketHistoryMaxSnapshotsPerItem then
        marketHistoryMaxSnapshotsPerItem = self.DEFAULTS.marketHistoryMaxSnapshotsPerItem
    end
    self.db.marketHistoryMaxSnapshotsPerItem =
        math.floor(math.max(24, math.min(1000, marketHistoryMaxSnapshotsPerItem)) + 0.5)

    local priceIncreaseAlertThresholdPercent = tonumber(self.db.priceIncreaseAlertThresholdPercent)
    if not priceIncreaseAlertThresholdPercent then
        priceIncreaseAlertThresholdPercent = self.DEFAULTS.priceIncreaseAlertThresholdPercent
    end
    self.db.priceIncreaseAlertThresholdPercent =
        math.floor(math.max(1, math.min(500, priceIncreaseAlertThresholdPercent)) + 0.5)

    local priceIncreaseAlertLookbackDays = tonumber(self.db.priceIncreaseAlertLookbackDays)
    if not priceIncreaseAlertLookbackDays then
        priceIncreaseAlertLookbackDays = self.DEFAULTS.priceIncreaseAlertLookbackDays
    end
    self.db.priceIncreaseAlertLookbackDays =
        math.floor(math.max(1, math.min(14, priceIncreaseAlertLookbackDays)) + 0.5)

    local priceIncreaseAlertMinimumSamples = tonumber(self.db.priceIncreaseAlertMinimumSamples)
    if not priceIncreaseAlertMinimumSamples then
        priceIncreaseAlertMinimumSamples = self.DEFAULTS.priceIncreaseAlertMinimumSamples
    end
    self.db.priceIncreaseAlertMinimumSamples =
        math.floor(math.max(2, math.min(24, priceIncreaseAlertMinimumSamples)) + 0.5)

    if type(self.db.pendingReloadSession) ~= "table" then
        self.db.pendingReloadSession = nil
    end

    if type(self.db.nextHistoryID) ~= "number" or self.db.nextHistoryID < 1 then
        self.db.nextHistoryID = 1
    end

    self.db.windowAlpha = nil
    self.db.mainWindowTransparent = self.db.mainWindowTransparent == true

    if type(self.db.windowWidth) ~= "number" then
        self.db.windowWidth = self.DEFAULTS.windowWidth
    else
        local roundedWindowWidth = math.floor(self.db.windowWidth + 0.5)
        if roundedWindowWidth == self.LEGACY_DEFAULT_WINDOW_WIDTH
            or roundedWindowWidth == self.PREVIOUS_DEFAULT_WINDOW_WIDTH
            or roundedWindowWidth == self.OLDER_DEFAULT_WINDOW_WIDTH then
            self.db.windowWidth = self.DEFAULTS.windowWidth
        end
    end
    self.db.windowWidth = math.floor(math.max(780, math.min(1200, self.db.windowWidth)) + 0.5)

    if type(self.db.collapsedWindowWidth) ~= "number" then
        self.db.collapsedWindowWidth = self.DEFAULTS.collapsedWindowWidth
    end
    self.db.collapsedWindowWidth = math.floor(math.max(356, math.min(388, self.db.collapsedWindowWidth)) + 0.5)

    if type(self.db.windowHeight) ~= "number" then
        self.db.windowHeight = self.DEFAULTS.windowHeight
    end
    self.db.windowHeight = math.floor(math.max(500, math.min(1000, self.db.windowHeight)) + 0.5)

    if not hadHighValueDropAlerts
        and type(self.db.highValueDropAlerts) == "table"
        and type(self.db.highValueDropAlerts[1]) == "table" then
        self.db.highValueDropAlerts[1].threshold = self.db.highlightThreshold
    end

    if type(self.NormalizeAlertSettings) == "function" then
        self:NormalizeAlertSettings()
    end
end

function GoldTracker:GetLowHighlightThreshold()
    return self:GetHighlightThreshold()
end

function GoldTracker:GetItemQualityColorHex(itemQuality)
    local normalizedQuality = tonumber(itemQuality)
    if normalizedQuality then
        normalizedQuality = math.floor(normalizedQuality + 0.5)
    end

    local colorData = ITEM_QUALITY_COLORS and ITEM_QUALITY_COLORS[normalizedQuality]
    if type(colorData) == "table" then
        local normalizedHex = NormalizeColorHex(colorData.hex)
        if normalizedHex then
            return normalizedHex
        end
    end

    return "ffffffff"
end

function GoldTracker:GetColoredItemQualityLabel(itemQuality, fallbackLabel)
    local normalizedQuality = tonumber(itemQuality)
    if normalizedQuality then
        normalizedQuality = math.floor(normalizedQuality + 0.5)
    end

    local option = self.TRACKED_ITEM_QUALITY_BY_ID[normalizedQuality]
    local label = fallbackLabel
    if type(label) ~= "string" or label == "" then
        if option and option.label then
            label = option.label
        else
            label = _G["ITEM_QUALITY" .. tostring(normalizedQuality) .. "_DESC"] or "Unknown"
        end
    end

    return string.format("|c%s%s|r", self:GetItemQualityColorHex(normalizedQuality), label)
end

function GoldTracker:GetConfiguredMinimumTrackedItemQuality()
    local configuredQuality = tonumber(self.db and self.db.minimumTrackedItemQuality)
    if configuredQuality then
        configuredQuality = math.floor(configuredQuality + 0.5)
    end
    if self.TRACKED_ITEM_QUALITY_BY_ID[configuredQuality] then
        return configuredQuality
    end
    return self.DEFAULTS.minimumTrackedItemQuality
end

function GoldTracker:NormalizeMinimumTrackedItemQuality()
    if not self.db then
        return
    end

    self.db.minimumTrackedItemQuality = self:GetConfiguredMinimumTrackedItemQuality()
end

function GoldTracker:GetItemQualityFromLink(itemLink)
    if type(itemLink) ~= "string" then
        return nil
    end

    local colorHex = string.match(itemLink, "^|c([%x][%x][%x][%x][%x][%x][%x][%x])")
    if colorHex then
        local qualityFromColor = self.ITEM_QUALITY_BY_LINK_COLOR[string.lower(colorHex)]
        if type(qualityFromColor) == "number" then
            return qualityFromColor
        end
    end

    local itemQuality
    if C_Item and C_Item.GetItemInfo then
        itemQuality = select(3, C_Item.GetItemInfo(itemLink))
    else
        itemQuality = select(3, GetItemInfo(itemLink))
    end

    if type(itemQuality) == "number" then
        return math.floor(itemQuality + 0.5)
    end

    return nil
end

function GoldTracker:IsCraftingReagentItem(itemLink)
    if type(itemLink) ~= "string" or itemLink == "" then
        return false
    end

    if C_Item and type(C_Item.IsCraftingReagentItem) == "function" then
        local ok, result = pcall(C_Item.IsCraftingReagentItem, itemLink)
        if ok and result ~= nil then
            return result == true
        end
    end

    local isCraftingReagent = select(17, GetItemInfo(itemLink))
    if type(isCraftingReagent) == "boolean" then
        return isCraftingReagent
    end

    local itemClassID = select(12, GetItemInfo(itemLink))
    local tradeGoodsClassID = (Enum and Enum.ItemClass and Enum.ItemClass.Tradegoods) or LE_ITEM_CLASS_TRADEGOODS or 7
    return tonumber(itemClassID) == tonumber(tradeGoodsClassID)
end

function GoldTracker:ShouldTrackItemForAH(itemQuality)
    local normalizedQuality = tonumber(itemQuality)
    if normalizedQuality then
        normalizedQuality = math.floor(normalizedQuality + 0.5)
    else
        -- Keep unknown-quality items rather than silently dropping tracked value.
        return true
    end

    return normalizedQuality >= self:GetConfiguredMinimumTrackedItemQuality()
end

function GoldTracker:GetHighHighlightThreshold()
    return self:GetHighlightThreshold()
end

function GoldTracker:GetHighlightThreshold()
    if type(self.GetAlertRules) == "function"
        and type(self.ALERT_RULE_LIST_KEYS) == "table"
        and type(self.ALERT_RULE_LIST_KEYS.HIGH_VALUE_DROPS) == "string" then
        local minimumEnabledRuleThreshold = nil
        local rules = self:GetAlertRules(self.ALERT_RULE_LIST_KEYS.HIGH_VALUE_DROPS)
        for _, rule in ipairs(rules or {}) do
            if rule and rule.enabled == true then
                local threshold = tonumber(rule.threshold)
                if threshold and threshold > 0 then
                    if not minimumEnabledRuleThreshold or threshold < minimumEnabledRuleThreshold then
                        minimumEnabledRuleThreshold = threshold
                    end
                end
            end
        end
        if minimumEnabledRuleThreshold then
            return math.max(0, math.floor(minimumEnabledRuleThreshold + 0.5))
        end
    end

    local value = tonumber(self.db and self.db.highlightThreshold) or self.DEFAULTS.highlightThreshold
    return math.max(0, math.floor(value + 0.5))
end

function GoldTracker:GetHistoryRowsPerPage()
    local value = tonumber(self.db and self.db.historyRowsPerPage) or self.DEFAULTS.historyRowsPerPage
    return math.max(5, math.min(30, math.floor(value + 0.5)))
end

function GoldTracker:GetHistoryDetailsFontSize()
    local value = tonumber(self.db and self.db.historyDetailsFontSize) or self.DEFAULTS.historyDetailsFontSize
    return math.max(8, math.min(24, math.floor(value + 0.5)))
end

function GoldTracker:NormalizeWorldMapProjectionPinScale(value)
    local scale = tonumber(value) or self.DEFAULTS.worldMapProjectionPinScale or 1
    local minimum = self.WORLD_MAP_PROJECTION_PIN_SCALE_MIN or 0.6
    local maximum = self.WORLD_MAP_PROJECTION_PIN_SCALE_MAX or 2.0
    local step = self.WORLD_MAP_PROJECTION_PIN_SCALE_STEP or 0.1
    scale = math.max(minimum, math.min(maximum, scale))
    return math.floor((scale / step) + 0.5) * step
end

function GoldTracker:GetWorldMapProjectionPinScale()
    return self:NormalizeWorldMapProjectionPinScale(self.db and self.db.worldMapProjectionPinScale)
end

function GoldTracker:IsResumeSessionAfterReloadEnabled()
    return self.db and self.db.resumeSessionAfterReload == true
end

function GoldTracker:IsLootSourceTrackingEnabled()
    if not self.db then
        return true
    end
    return self.db.enableLootSourceTracking == true
end

function GoldTracker:IsObservedWorldDropsEnabled()
    if not self.db then
        return false
    end
    return self.db.enableObservedWorldDrops == true
end

function GoldTracker:IsLootLogTimestampsEnabled()
    if not self.db then
        return self.DEFAULTS.showLootLogTimestamps == true
    end
    return self.db.showLootLogTimestamps == true
end

function GoldTracker:IsMainLootStreamExpanded()
    if not self.db then
        return self.DEFAULTS.mainLootStreamExpanded == true
    end
    return self.db.mainLootStreamExpanded == true
end

function GoldTracker:IsIgnoreMailboxLootWhenMailOpenEnabled()
    if not self.db then
        return self.DEFAULTS.ignoreMailboxLootWhenMailOpen == true
    end
    return self.db.ignoreMailboxLootWhenMailOpen == true
end

function GoldTracker:IsMainWindowGoldPerHourEnabled()
    if not self.db then
        return self.DEFAULTS.showMainWindowGoldPerHour == true
    end
    return self.db.showMainWindowGoldPerHour == true
end

function GoldTracker:GetMainWindowSlashOpenMode()
    local modeID = self.db and self.db.mainWindowSlashOpenMode
    return self.MAIN_WINDOW_SLASH_OPEN_MODE_BY_ID[modeID]
        or self.MAIN_WINDOW_SLASH_OPEN_MODE_BY_ID[self.DEFAULTS.mainWindowSlashOpenMode]
        or self.MAIN_WINDOW_SLASH_OPEN_MODES[1]
end

function GoldTracker:IsTotalWindowGoldPerHourEnabled()
    if not self:IsTotalWindowFeatureEnabled() then
        return false
    end
    if not self.db then
        return self.DEFAULTS.showTotalWindowGoldPerHour == true
    end
    return self.db.showTotalWindowGoldPerHour == true
end

function GoldTracker:IsChatLoggingEnabled()
    if not self.db then
        return self.DEFAULTS.enableChatLogging == true
    end
    return self.db.enableChatLogging == true
end

function GoldTracker:IsTotalWindowFeatureEnabled()
    return ENABLE_TOTAL_WINDOW_FEATURE == true
end

function GoldTracker:IsAutoStartSessionOnLocationChangeEnabled()
    if not self.db then
        return self.DEFAULTS.autoStartSessionOnLocationChange == true
    end
    return self.db.autoStartSessionOnLocationChange == true
end

function GoldTracker:IsActiveTimeForGoldPerHourEnabled()
    if not self.db then
        return self.DEFAULTS.useActiveTimeForGoldPerHour == true
    end
    return self.db.useActiveTimeForGoldPerHour == true
end

function GoldTracker:IsResumeHistorySessionEnabled()
    if not self.db then
        return self.DEFAULTS.allowResumeHistorySession == true
    end
    return self.db.allowResumeHistorySession == true
end

function GoldTracker:GetSessionActiveDurationSeconds()
    local session = self.session or {}
    local trackedActive = tonumber(session.activeDurationSeconds) or 0
    if trackedActive > 0 then
        if session.active == true then
            local lastLootAt = tonumber(session.lastLootAt)
            if lastLootAt and lastLootAt > 0 then
                local now = time()
                local delta = math.max(0, now - lastLootAt)
                local idleWindow = 90
                return trackedActive + math.min(delta, idleWindow)
            end
        end
        return trackedActive
    end

    return self:GetSessionElapsedSeconds()
end

function GoldTracker:GetSessionRateDurationSeconds()
    if self:IsActiveTimeForGoldPerHourEnabled() then
        return self:GetSessionActiveDurationSeconds()
    end
    return self:GetSessionElapsedSeconds()
end

function GoldTracker:IsDiagnosticsPanelEnabled()
    if not self.db then
        return false
    end
    return self.db.enableDiagnosticsPanel == true
end

function GoldTracker:NormalizeHighlightThresholds()
    if not self.db then
        return
    end

    local threshold = self:GetHighlightThreshold()
    self.db.highlightThreshold = threshold
    self.db.notificationThreshold = threshold
    self.db.lowHighlightThreshold = threshold
    self.db.highHighlightThreshold = threshold
end

function GoldTracker:GetCurrentValueSource()
    local configuredSource = self.db and self.VALUE_SOURCE_BY_ID[self.db.valueSource]
    if configuredSource then
        return configuredSource
    end

    local defaultSource = self.VALUE_SOURCE_BY_ID[self.DEFAULTS.valueSource]
    if defaultSource then
        return defaultSource
    end

    return self.VALUE_SOURCES[1]
end

function GoldTracker:GetAuctionableInventoryValueSource()
    local configuredSource = self.db and self.VALUE_SOURCE_BY_ID[self.db.auctionableInventoryValueSource]
    if configuredSource then
        return configuredSource
    end

    local defaultSource = self.VALUE_SOURCE_BY_ID[self.DEFAULTS.auctionableInventoryValueSource]
    if defaultSource then
        return defaultSource
    end

    return self:GetCurrentValueSource()
end

function GoldTracker:SetAuctionableInventoryValueSource(sourceID)
    local source = self.VALUE_SOURCE_BY_ID[sourceID] or self:GetAuctionableInventoryValueSource()
    if self.db and source then
        self.db.auctionableInventoryValueSource = source.id
    end
    if self.inventoryFrame and source then
        self.inventoryFrame.valueSourceID = source.id
    end
    self.tsmWarningShown = false
    return source
end

function GoldTracker:IsAutoOpenAuctionableInventoryOnAuctionHouseEnabled()
    if not self.db then
        return self.DEFAULTS.autoOpenAuctionableInventoryOnAuctionHouse == true
    end
    return self.db.autoOpenAuctionableInventoryOnAuctionHouse == true
end

function GoldTracker:GetFallbackValueSource()
    local fallbackID = self.db and self.db.fallbackValueSource
    if type(fallbackID) ~= "string" or fallbackID == "" then
        return nil
    end

    local fallbackSource = self.VALUE_SOURCE_BY_ID[fallbackID]
    if not fallbackSource then
        return nil
    end

    local primarySource = self:GetCurrentValueSource()
    if primarySource and primarySource.id == fallbackSource.id then
        return nil
    end

    return fallbackSource
end

function GoldTracker:GetSessionElapsedSeconds()
    local session = self.session
    if not session.startTime then
        return 0
    end
    if session.active then
        return math.max(0, time() - session.startTime)
    end
    if session.stopTime then
        return math.max(0, session.stopTime - session.startTime)
    end
    return 0
end

function GoldTracker:GetSessionTotalValue()
    return (self.session.goldLooted or 0) + (self.session.itemValue or 0)
end

function GoldTracker:IsSupportedClient()
    if WOW_PROJECT_ID ~= self.REQUIRED_PROJECT then
        return false, "Retail (Mainline) client required."
    end

    local interfaceVersion = tonumber((select(4, GetBuildInfo()))) or 0
    if interfaceVersion < self.MIN_INTERFACE then
        return false, string.format("Midnight-era API required (interface %d+).", self.MIN_INTERFACE)
    end

    return true, nil
end
