local ADDON_NAME, NS = ...

local GoldTracker = NS.GoldTracker or CreateFrame("Frame")
NS.GoldTracker = GoldTracker

GoldTracker.ADDON_NAME = ADDON_NAME
GoldTracker.PREFIX = "|cffffd200[Gold Tracker]|r"
GoldTracker.COPPER_PER_GOLD = 10000
GoldTracker.MIN_INTERFACE = 120000
GoldTracker.REQUIRED_PROJECT = WOW_PROJECT_MAINLINE
GoldTracker.LEGACY_DEFAULT_WINDOW_WIDTH = 680
GoldTracker.PREVIOUS_DEFAULT_WINDOW_WIDTH = 760

GoldTracker.DEFAULTS = {
    valueSource = "TSM_DBMARKET",
    fallbackValueSource = "",
    highlightThreshold = 100000,
    notificationsEnabled = true,
    autoStartSessionOnFirstLoot = true,
    autoStartSessionOnEnterWorld = false,
    enableSessionHistory = false,
    historyRowsPerPage = 10,
    showRawLootedGoldInLog = true,
    minimapButtonAngle = 225,
    windowAlpha = 0.90,
    windowWidth = 790,
    windowHeight = 460,
}

GoldTracker.VALUE_SOURCES = {
    { id = "TSM_DBMARKET", label = "TSM dbmarket", tsmKey = "dbmarket" },
    { id = "TSM_DBREGIONMARKETAVG", label = "TSM dbregionmarketavg", tsmKey = "dbregionmarketavg" },
    { id = "TSM_DBMINBUYOUT", label = "TSM dbminbuyout", tsmKey = "dbminbuyout" },
    { id = "TSM_DBHISTORICAL", label = "TSM dbhistorical", tsmKey = "dbhistorical" },
    { id = "TSM_DBREGIONHISTORICAL", label = "TSM dbregionhistorical", tsmKey = "dbregionhistorical" },
    { id = "TSM_DBREGIONSALEAVG", label = "TSM dbregionsaleavg", tsmKey = "dbregionsaleavg" },
    { id = "TSM_CRAFTING", label = "TSM crafting", tsmKey = "crafting" },
}

GoldTracker.VALUE_SOURCE_BY_ID = {}
for _, source in ipairs(GoldTracker.VALUE_SOURCES) do
    GoldTracker.VALUE_SOURCE_BY_ID[source.id] = source
end

GoldTracker.session = GoldTracker.session or {
    active = false,
    startTime = nil,
    stopTime = nil,
    goldLooted = 0,
    itemValue = 0,
    itemVendorValue = 0,
    highlightItemCount = 0,
    itemLoots = {},
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
}

GoldTracker.tsmWarningShown = false

function GoldTracker:Trim(text)
    if not text then
        return ""
    end
    return (text:gsub("^%s+", ""):gsub("%s+$", ""))
end

function GoldTracker:FormatMoney(copper)
    local clamped = math.max(0, math.floor(copper or 0))
    return GetMoneyString(clamped, true)
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

function GoldTracker:Print(message)
    local text = string.format("%s %s", self.PREFIX, tostring(message))
    if DEFAULT_CHAT_FRAME and DEFAULT_CHAT_FRAME.AddMessage then
        DEFAULT_CHAT_FRAME:AddMessage(text)
    else
        print(text)
    end
end

function GoldTracker:InitializeDatabase()
    if type(WoWGeneralGoldTrackerDB) ~= "table" then
        WoWGeneralGoldTrackerDB = {}
    end

    self.db = WoWGeneralGoldTrackerDB
    local legacyLowThreshold = tonumber(self.db.lowHighlightThreshold)
    local legacyHighThreshold = tonumber(self.db.highHighlightThreshold)
    local legacyNotificationThreshold = tonumber(self.db.notificationThreshold)

    for key, value in pairs(self.DEFAULTS) do
        if self.db[key] == nil then
            self.db[key] = value
        end
    end

    if not self.VALUE_SOURCE_BY_ID[self.db.valueSource] then
        self.db.valueSource = self.DEFAULTS.valueSource
    end

    if type(self.db.fallbackValueSource) ~= "string" then
        self.db.fallbackValueSource = self.DEFAULTS.fallbackValueSource
    end
    if self.db.fallbackValueSource ~= "" and not self.VALUE_SOURCE_BY_ID[self.db.fallbackValueSource] then
        self.db.fallbackValueSource = self.DEFAULTS.fallbackValueSource
    end
    if self.db.fallbackValueSource == self.db.valueSource then
        self.db.fallbackValueSource = self.DEFAULTS.fallbackValueSource
    end

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

    if type(self.db.enableSessionHistory) ~= "boolean" then
        self.db.enableSessionHistory = self.DEFAULTS.enableSessionHistory
    end

    local historyRowsPerPage = tonumber(self.db.historyRowsPerPage)
    if not historyRowsPerPage then
        historyRowsPerPage = self.DEFAULTS.historyRowsPerPage
    end
    self.db.historyRowsPerPage = math.floor(math.max(5, math.min(30, historyRowsPerPage)) + 0.5)

    if type(self.db.showRawLootedGoldInLog) ~= "boolean" then
        self.db.showRawLootedGoldInLog = self.DEFAULTS.showRawLootedGoldInLog
    end

    if type(self.db.minimapButtonAngle) ~= "number" then
        self.db.minimapButtonAngle = self.DEFAULTS.minimapButtonAngle
    end
    self.db.minimapButtonAngle = self.db.minimapButtonAngle % 360

    if type(self.db.sessionHistory) ~= "table" then
        self.db.sessionHistory = {}
    end

    if type(self.db.nextHistoryID) ~= "number" or self.db.nextHistoryID < 1 then
        self.db.nextHistoryID = 1
    end

    if type(self.db.windowAlpha) ~= "number" then
        self.db.windowAlpha = self.DEFAULTS.windowAlpha
    end
    self.db.windowAlpha = math.max(0.20, math.min(1.00, self.db.windowAlpha))

    if type(self.db.windowWidth) ~= "number" then
        self.db.windowWidth = self.DEFAULTS.windowWidth
    else
        local roundedWindowWidth = math.floor(self.db.windowWidth + 0.5)
        if roundedWindowWidth == self.LEGACY_DEFAULT_WINDOW_WIDTH
            or roundedWindowWidth == self.PREVIOUS_DEFAULT_WINDOW_WIDTH then
            self.db.windowWidth = self.DEFAULTS.windowWidth
        end
    end
    self.db.windowWidth = math.floor(math.max(480, math.min(1200, self.db.windowWidth)) + 0.5)

    if type(self.db.windowHeight) ~= "number" then
        self.db.windowHeight = self.DEFAULTS.windowHeight
    end
    self.db.windowHeight = math.floor(math.max(320, math.min(1000, self.db.windowHeight)) + 0.5)
end

function GoldTracker:GetLowHighlightThreshold()
    return self:GetHighlightThreshold()
end

function GoldTracker:GetHighHighlightThreshold()
    return self:GetHighlightThreshold()
end

function GoldTracker:GetHighlightThreshold()
    local value = tonumber(self.db and self.db.highlightThreshold) or self.DEFAULTS.highlightThreshold
    return math.max(0, math.floor(value + 0.5))
end

function GoldTracker:GetHistoryRowsPerPage()
    local value = tonumber(self.db and self.db.historyRowsPerPage) or self.DEFAULTS.historyRowsPerPage
    return math.max(5, math.min(30, math.floor(value + 0.5)))
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
