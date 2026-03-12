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
GoldTracker.OLDER_DEFAULT_WINDOW_WIDTH = 790

GoldTracker.DEFAULTS = {
    valueSource = "TSM_DBMARKET",
    fallbackValueSource = "",
    minimumTrackedItemQuality = 0,
    highlightThreshold = 100000,
    notificationsEnabled = true,
    autoStartSessionOnFirstLoot = true,
    autoStartSessionOnEnterWorld = false,
    resumeSessionAfterReload = false,
    enableSessionHistory = false,
    historyRowsPerPage = 10,
    historyDetailsFontSize = 12,
    showRawLootedGoldInLog = true,
    ignoreMailboxLootWhenMailOpen = true,
    showMainWindowGoldPerHour = true,
    showTotalWindowGoldPerHour = true,
    useActiveTimeForGoldPerHour = false,
    allowResumeHistorySession = true,
    enableLootSourceTracking = true,
    enableDiagnosticsPanel = false,
    minimapButtonAngle = 225,
    windowAlpha = 0.90,
    windowWidth = 720,
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

GoldTracker.MINIMUM_TRACKED_ITEM_QUALITIES = { 0, 2, 3, 4, 5 }
GoldTracker.TRACKED_ITEM_QUALITY_OPTIONS = {}
GoldTracker.TRACKED_ITEM_QUALITY_BY_ID = {}
GoldTracker.ITEM_QUALITY_BY_LINK_COLOR = {}

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
    highlightItemCount = 0,
    itemLoots = {},
    moneyLoots = {},
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

    for key, value in pairs(self.DEFAULTS) do
        if self.db[key] == nil then
            self.db[key] = CloneDefaultValue(value)
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

    if type(self.db.resumeSessionAfterReload) ~= "boolean" then
        self.db.resumeSessionAfterReload = self.DEFAULTS.resumeSessionAfterReload
    end

    if type(self.db.enableSessionHistory) ~= "boolean" then
        self.db.enableSessionHistory = self.DEFAULTS.enableSessionHistory
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
    if type(self.db.enableLootSourceTracking) ~= "boolean" then
        self.db.enableLootSourceTracking = self.DEFAULTS.enableLootSourceTracking
    end

    if type(self.db.minimapButtonAngle) ~= "number" then
        self.db.minimapButtonAngle = self.DEFAULTS.minimapButtonAngle
    end
    self.db.minimapButtonAngle = self.db.minimapButtonAngle % 360

    if type(self.db.sessionHistory) ~= "table" then
        self.db.sessionHistory = {}
    end
    if type(self.db.pendingReloadSession) ~= "table" then
        self.db.pendingReloadSession = nil
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
            or roundedWindowWidth == self.PREVIOUS_DEFAULT_WINDOW_WIDTH
            or roundedWindowWidth == self.OLDER_DEFAULT_WINDOW_WIDTH then
            self.db.windowWidth = self.DEFAULTS.windowWidth
        end
    end
    self.db.windowWidth = math.floor(math.max(480, math.min(1200, self.db.windowWidth)) + 0.5)

    if type(self.db.windowHeight) ~= "number" then
        self.db.windowHeight = self.DEFAULTS.windowHeight
    end
    self.db.windowHeight = math.floor(math.max(320, math.min(1000, self.db.windowHeight)) + 0.5)

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

function GoldTracker:IsResumeSessionAfterReloadEnabled()
    return self.db and self.db.resumeSessionAfterReload == true
end

function GoldTracker:IsLootSourceTrackingEnabled()
    if not self.db then
        return true
    end
    return self.db.enableLootSourceTracking == true
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

function GoldTracker:IsTotalWindowGoldPerHourEnabled()
    if not self.db then
        return self.DEFAULTS.showTotalWindowGoldPerHour == true
    end
    return self.db.showTotalWindowGoldPerHour == true
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
