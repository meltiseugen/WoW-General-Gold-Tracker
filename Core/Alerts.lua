local _, NS = ...
local GoldTracker = NS.GoldTracker

local MAX_ALERT_RULES = 20
local ALERT_RULE_LIST_SESSION_MILESTONES = "sessionMilestoneAlerts"
local ALERT_RULE_LIST_HIGH_VALUE_DROPS = "highValueDropAlerts"

local DEFAULT_SOUND_ID = "EPICLOOT"
local DEFAULT_DISPLAY_ID = "CHAT_RAID"
local DEFAULT_NO_LOOT_SOUND_ID = "READY_CHECK"
local DEFAULT_NO_LOOT_DISPLAY_ID = "CHAT_CENTER"

local DEFAULT_MILESTONE_RULES = {
    { enabled = true, threshold = 100 * GoldTracker.COPPER_PER_GOLD, soundID = "EPICLOOT", displayID = "CHAT_RAID" },
    { enabled = true, threshold = 500 * GoldTracker.COPPER_PER_GOLD, soundID = "READY_CHECK", displayID = "RAID_WARNING" },
}

local DEFAULT_DROP_RULE_TEMPLATE = {
    enabled = true,
    threshold = GoldTracker.DEFAULTS.highlightThreshold,
    soundID = "EPICLOOT",
    displayID = "RAID_WARNING",
}

local DEFAULT_NO_LOOT_MINUTES = 5

local function ShallowCopyRule(rule)
    return {
        enabled = rule and rule.enabled == true,
        threshold = tonumber(rule and rule.threshold) or 0,
        soundID = rule and rule.soundID,
        displayID = rule and rule.displayID,
    }
end

local function CloneRules(rules)
    local cloned = {}
    if type(rules) ~= "table" then
        return cloned
    end
    for _, rule in ipairs(rules) do
        cloned[#cloned + 1] = ShallowCopyRule(rule)
    end
    return cloned
end

GoldTracker.ALERT_RULE_LIST_KEYS = {
    SESSION_MILESTONES = ALERT_RULE_LIST_SESSION_MILESTONES,
    HIGH_VALUE_DROPS = ALERT_RULE_LIST_HIGH_VALUE_DROPS,
}

GoldTracker.ALERT_SOUND_OPTIONS = {
    { id = "NONE", label = "None", soundKitKey = nil },
    { id = "EPICLOOT", label = "Epic Loot Toast", soundKitKey = "UI_EPICLOOT_TOAST" },
    { id = "RAID_WARNING", label = "Raid Warning", soundKitKey = "RAID_WARNING" },
    { id = "READY_CHECK", label = "Ready Check", soundKitKey = "READY_CHECK" },
    { id = "CHECKBOX_ON", label = "Checkbox On", soundKitKey = "IG_MAINMENU_OPTION_CHECKBOX_ON" },
}

GoldTracker.ALERT_SOUND_BY_ID = {}
for _, soundOption in ipairs(GoldTracker.ALERT_SOUND_OPTIONS) do
    GoldTracker.ALERT_SOUND_BY_ID[soundOption.id] = soundOption
end

GoldTracker.ALERT_DISPLAY_OPTIONS = {
    { id = "NONE", label = "No visual (sound only)" },
    { id = "CHAT", label = "Chat message" },
    { id = "RAID_WARNING", label = "Raid warning" },
    { id = "CENTER", label = "Center screen text" },
    { id = "LOG", label = "Tracker log" },
    { id = "CHAT_RAID", label = "Chat + Raid warning" },
    { id = "CHAT_CENTER", label = "Chat + Center text" },
    { id = "ALL", label = "All methods" },
}

GoldTracker.ALERT_DISPLAY_BY_ID = {}
for _, displayOption in ipairs(GoldTracker.ALERT_DISPLAY_OPTIONS) do
    GoldTracker.ALERT_DISPLAY_BY_ID[displayOption.id] = displayOption
end

GoldTracker.DEFAULTS.sessionMilestoneAlerts = CloneRules(DEFAULT_MILESTONE_RULES)
GoldTracker.DEFAULTS.highValueDropAlerts = CloneRules({ DEFAULT_DROP_RULE_TEMPLATE })
GoldTracker.DEFAULTS.noLootAlertEnabled = false
GoldTracker.DEFAULTS.noLootAlertMinutes = DEFAULT_NO_LOOT_MINUTES
GoldTracker.DEFAULTS.noLootAlertSoundID = DEFAULT_NO_LOOT_SOUND_ID
GoldTracker.DEFAULTS.noLootAlertDisplayID = DEFAULT_NO_LOOT_DISPLAY_ID

local function IsValidRuleListKey(listKey)
    return listKey == ALERT_RULE_LIST_SESSION_MILESTONES or listKey == ALERT_RULE_LIST_HIGH_VALUE_DROPS
end

local function NormalizeRuleThreshold(threshold, fallbackThreshold)
    local resolved = tonumber(threshold)
    if not resolved or resolved <= 0 then
        resolved = tonumber(fallbackThreshold) or GoldTracker.COPPER_PER_GOLD
    end
    return math.max(1, math.floor(resolved + 0.5))
end

local function NormalizeRule(addon, rule, fallbackRule)
    local fallback = fallbackRule or {}
    local normalized = {
        enabled = (rule and rule.enabled == true) or (fallback.enabled == true),
        threshold = NormalizeRuleThreshold(rule and rule.threshold, fallback.threshold),
        soundID = (rule and rule.soundID) or fallback.soundID or DEFAULT_SOUND_ID,
        displayID = (rule and rule.displayID) or fallback.displayID or DEFAULT_DISPLAY_ID,
    }

    if not addon.ALERT_SOUND_BY_ID[normalized.soundID] then
        normalized.soundID = DEFAULT_SOUND_ID
    end
    if not addon.ALERT_DISPLAY_BY_ID[normalized.displayID] then
        normalized.displayID = DEFAULT_DISPLAY_ID
    end

    return normalized
end

local function NormalizeRuleList(addon, rules, fallbackRules)
    local normalized = {}
    local fallback = type(fallbackRules) == "table" and fallbackRules or {}
    if type(rules) ~= "table" then
        rules = {}
    end

    for index, rule in ipairs(rules) do
        if #normalized >= MAX_ALERT_RULES then
            break
        end
        local fallbackRule = fallback[index] or fallback[1]
        normalized[#normalized + 1] = NormalizeRule(addon, rule, fallbackRule)
    end

    table.sort(normalized, function(a, b)
        if (a.threshold or 0) ~= (b.threshold or 0) then
            return (a.threshold or 0) < (b.threshold or 0)
        end
        if (a.enabled == true) ~= (b.enabled == true) then
            return a.enabled == true
        end
        return tostring(a.soundID or "") < tostring(b.soundID or "")
    end)

    return normalized
end

local function FormatThresholdAsGold(addon, threshold)
    local thresholdCopper = math.max(0, math.floor((tonumber(threshold) or 0) + 0.5))
    return string.format("%.2fg", thresholdCopper / addon.COPPER_PER_GOLD)
end

function GoldTracker:IsAlertsEnabled()
    return self.db and self.db.notificationsEnabled == true
end

function GoldTracker:NormalizeAlertSettings()
    if not self.db then
        return
    end

    if type(self.db.notificationsEnabled) ~= "boolean" then
        self.db.notificationsEnabled = self.DEFAULTS.notificationsEnabled
    end

    self.db.sessionMilestoneAlerts = NormalizeRuleList(
        self,
        self.db.sessionMilestoneAlerts,
        self.DEFAULTS.sessionMilestoneAlerts
    )

    if type(self.db.highValueDropAlerts) ~= "table" then
        self.db.highValueDropAlerts = CloneRules(self.DEFAULTS.highValueDropAlerts)
    end
    self.db.highValueDropAlerts = NormalizeRuleList(
        self,
        self.db.highValueDropAlerts,
        self.DEFAULTS.highValueDropAlerts
    )

    if type(self.db.noLootAlertEnabled) ~= "boolean" then
        self.db.noLootAlertEnabled = self.DEFAULTS.noLootAlertEnabled
    end

    local noLootMinutes = tonumber(self.db.noLootAlertMinutes)
    if not noLootMinutes then
        noLootMinutes = self.DEFAULTS.noLootAlertMinutes
    end
    self.db.noLootAlertMinutes = math.floor(math.max(1, math.min(180, noLootMinutes)) + 0.5)

    local noLootSoundID = tostring(self.db.noLootAlertSoundID or self.DEFAULTS.noLootAlertSoundID)
    if not self.ALERT_SOUND_BY_ID[noLootSoundID] then
        noLootSoundID = self.DEFAULTS.noLootAlertSoundID
    end
    self.db.noLootAlertSoundID = noLootSoundID

    local noLootDisplayID = tostring(self.db.noLootAlertDisplayID or self.DEFAULTS.noLootAlertDisplayID)
    if not self.ALERT_DISPLAY_BY_ID[noLootDisplayID] then
        noLootDisplayID = self.DEFAULTS.noLootAlertDisplayID
    end
    self.db.noLootAlertDisplayID = noLootDisplayID
end

function GoldTracker:GetAlertRules(listKey)
    if not self.db or not IsValidRuleListKey(listKey) then
        return {}
    end
    if type(self.db[listKey]) ~= "table" then
        self.db[listKey] = {}
    end
    return self.db[listKey]
end

function GoldTracker:AddAlertRule(listKey)
    if not IsValidRuleListKey(listKey) then
        return false
    end

    local rules = self:GetAlertRules(listKey)
    if #rules >= MAX_ALERT_RULES then
        return false
    end

    local step = 100 * self.COPPER_PER_GOLD
    if listKey == ALERT_RULE_LIST_HIGH_VALUE_DROPS then
        step = 50 * self.COPPER_PER_GOLD
    end
    local threshold = step
    if #rules > 0 then
        threshold = math.max(1, math.floor((tonumber(rules[#rules].threshold) or step) + step + 0.5))
    end

    rules[#rules + 1] = NormalizeRule(self, {
        enabled = true,
        threshold = threshold,
        soundID = DEFAULT_SOUND_ID,
        displayID = DEFAULT_DISPLAY_ID,
    })
    self:NormalizeAlertSettings()
    return true
end

function GoldTracker:RemoveAlertRule(listKey, index)
    if not IsValidRuleListKey(listKey) then
        return false
    end
    index = math.floor(tonumber(index) or 0)
    local rules = self:GetAlertRules(listKey)
    if index < 1 or index > #rules then
        return false
    end
    table.remove(rules, index)
    self:NormalizeAlertSettings()
    return true
end

function GoldTracker:SetAlertRuleEnabled(listKey, index, enabled)
    local rules = self:GetAlertRules(listKey)
    index = math.floor(tonumber(index) or 0)
    if index < 1 or index > #rules then
        return false
    end
    rules[index].enabled = enabled == true
    return true
end

function GoldTracker:SetAlertRuleThresholdGold(listKey, index, thresholdGold)
    local rules = self:GetAlertRules(listKey)
    index = math.floor(tonumber(index) or 0)
    if index < 1 or index > #rules then
        return false
    end

    local parsedGold = tonumber(thresholdGold)
    if not parsedGold or parsedGold <= 0 then
        return false
    end

    local thresholdCopper = math.floor((parsedGold * self.COPPER_PER_GOLD) + 0.5)
    rules[index].threshold = math.max(1, thresholdCopper)
    self:NormalizeAlertSettings()
    return true
end

function GoldTracker:SetAlertRuleSoundID(listKey, index, soundID)
    local rules = self:GetAlertRules(listKey)
    index = math.floor(tonumber(index) or 0)
    if index < 1 or index > #rules then
        return false
    end
    if not self.ALERT_SOUND_BY_ID[soundID] then
        return false
    end
    rules[index].soundID = soundID
    return true
end

function GoldTracker:SetAlertRuleDisplayID(listKey, index, displayID)
    local rules = self:GetAlertRules(listKey)
    index = math.floor(tonumber(index) or 0)
    if index < 1 or index > #rules then
        return false
    end
    if not self.ALERT_DISPLAY_BY_ID[displayID] then
        return false
    end
    rules[index].displayID = displayID
    return true
end

function GoldTracker:SetNoLootAlertMinutes(minutes)
    if not self.db then
        return false
    end
    local parsed = tonumber(minutes)
    if not parsed then
        return false
    end
    self.db.noLootAlertMinutes = math.floor(math.max(1, math.min(180, parsed)) + 0.5)
    return true
end

function GoldTracker:EnsureAlertRuntimeState()
    if type(self.alertRuntime) ~= "table" then
        self.alertRuntime = {}
    end
    if type(self.alertRuntime.milestoneTriggeredByRule) ~= "table" then
        self.alertRuntime.milestoneTriggeredByRule = {}
    end
    return self.alertRuntime
end

function GoldTracker:GetMostRecentSessionLootTimestamp(session)
    local resolvedSession = session or self.session or {}
    local latest = tonumber(resolvedSession.lastLootAt) or 0
    local function ConsiderTimestamp(value)
        local timestamp = tonumber(value) or 0
        if timestamp > latest then
            latest = timestamp
        end
    end

    for _, entry in ipairs(resolvedSession.itemLoots or {}) do
        ConsiderTimestamp(entry and entry.timestamp)
    end
    for _, entry in ipairs(resolvedSession.moneyLoots or {}) do
        ConsiderTimestamp(entry and entry.timestamp)
    end
    ConsiderTimestamp(resolvedSession.startTime)

    if latest <= 0 then
        latest = time()
    end
    return latest
end

function GoldTracker:EnsureAlertRuntimeForCurrentSession()
    local runtime = self:EnsureAlertRuntimeState()
    local session = self.session or {}

    if session.active ~= true then
        runtime.sessionStartTime = nil
        runtime.milestoneTriggeredByRule = {}
        runtime.noLootTriggered = false
        return runtime
    end

    local currentStart = tonumber(session.startTime) or 0
    if currentStart <= 0 then
        currentStart = time()
        session.startTime = currentStart
    end

    if tonumber(runtime.sessionStartTime) ~= currentStart then
        runtime.sessionStartTime = currentStart
        runtime.milestoneTriggeredByRule = {}
        runtime.noLootTriggered = false
    end

    if type(session.lastLootAt) ~= "number" or session.lastLootAt <= 0 then
        session.lastLootAt = self:GetMostRecentSessionLootTimestamp(session)
    end

    return runtime
end

function GoldTracker:MarkSessionLootActivity(timestamp)
    local session = self.session
    if type(session) ~= "table" then
        return
    end

    local now = tonumber(timestamp) or time()
    if now <= 0 then
        now = time()
    end
    session.lastLootAt = now

    local runtime = self:EnsureAlertRuntimeForCurrentSession()
    runtime.noLootTriggered = false
end

function GoldTracker:PlayConfiguredAlertSound(soundID)
    local option = self.ALERT_SOUND_BY_ID[soundID] or self.ALERT_SOUND_BY_ID[DEFAULT_SOUND_ID]
    if not option or option.id == "NONE" then
        return
    end

    local soundKitID = nil
    if SOUNDKIT and type(option.soundKitKey) == "string" and option.soundKitKey ~= "" then
        soundKitID = SOUNDKIT[option.soundKitKey]
    end
    if not soundKitID and SOUNDKIT and SOUNDKIT.UI_EPICLOOT_TOAST then
        soundKitID = SOUNDKIT.UI_EPICLOOT_TOAST
    end

    if PlaySound and soundKitID then
        PlaySound(soundKitID)
    end
end

function GoldTracker:DispatchConfiguredAlert(message, displayID, soundID, color)
    if not self:IsAlertsEnabled() then
        return
    end
    if type(message) ~= "string" or message == "" then
        return
    end

    local mode = self.ALERT_DISPLAY_BY_ID[displayID] and displayID or DEFAULT_DISPLAY_ID
    local resolvedColor = color or { r = 1, g = 0.82, b = 0.2 }
    local showChat = mode == "CHAT" or mode == "CHAT_RAID" or mode == "CHAT_CENTER" or mode == "ALL"
    local showRaid = mode == "RAID_WARNING" or mode == "CHAT_RAID" or mode == "ALL"
    local showCenter = mode == "CENTER" or mode == "CHAT_CENTER" or mode == "ALL"
    local showLog = mode == "LOG" or mode == "ALL"

    self:PlayConfiguredAlertSound(soundID)

    if showRaid and RaidNotice_AddMessage and RaidWarningFrame then
        local raidWarningColor = ChatTypeInfo and ChatTypeInfo["RAID_WARNING"]
        RaidNotice_AddMessage(RaidWarningFrame, message, raidWarningColor or resolvedColor)
    end

    if showCenter and UIErrorsFrame and UIErrorsFrame.AddMessage then
        UIErrorsFrame:AddMessage(message, resolvedColor.r or 1, resolvedColor.g or 0.82, resolvedColor.b or 0.2, 1.0, 3.0)
    end

    if showLog then
        self:AddLogMessage(string.format("%s  |cffffd100[Alert]|r %s", date("%H:%M:%S"), message), resolvedColor.r, resolvedColor.g, resolvedColor.b)
    end

    if showChat then
        self:Print(message)
    end
end

function GoldTracker:ProcessSessionMilestoneAlerts(previousTotal, newTotal)
    if not self:IsAlertsEnabled() then
        return
    end
    if not (self.session and self.session.active) then
        return
    end

    local previousValue = math.max(0, math.floor((tonumber(previousTotal) or 0) + 0.5))
    local currentValue = math.max(0, math.floor((tonumber(newTotal) or 0) + 0.5))
    if currentValue <= previousValue then
        return
    end

    local runtime = self:EnsureAlertRuntimeForCurrentSession()
    local triggeredMap = runtime.milestoneTriggeredByRule
    for index, rule in ipairs(self:GetAlertRules(ALERT_RULE_LIST_SESSION_MILESTONES)) do
        if rule.enabled == true and triggeredMap[index] ~= true then
            local threshold = tonumber(rule.threshold) or 0
            if threshold > 0 and previousValue < threshold and currentValue >= threshold then
                local message = string.format(
                    "Session milestone reached: %s (Current: %s)",
                    FormatThresholdAsGold(self, threshold),
                    self:FormatMoney(currentValue)
                )
                self:DispatchConfiguredAlert(message, rule.displayID, rule.soundID, { r = 1, g = 0.82, b = 0.2 })
                triggeredMap[index] = true
            end
        end
    end
end

function GoldTracker:ProcessHighValueDropAlerts(itemLink, quantity, totalValue)
    if not self:IsAlertsEnabled() then
        return
    end

    local value = math.max(0, math.floor((tonumber(totalValue) or 0) + 0.5))
    if value <= 0 then
        return
    end

    local matchedRule = nil
    for _, rule in ipairs(self:GetAlertRules(ALERT_RULE_LIST_HIGH_VALUE_DROPS)) do
        if rule.enabled == true and value >= (tonumber(rule.threshold) or 0) then
            matchedRule = rule
        end
    end
    if not matchedRule then
        return
    end

    local message = string.format(
        "High value loot: %s x%d (%s) [>= %s]",
        tostring(itemLink or "Unknown item"),
        math.max(1, math.floor((tonumber(quantity) or 1) + 0.5)),
        self:FormatMoney(value),
        FormatThresholdAsGold(self, matchedRule.threshold)
    )
    self:DispatchConfiguredAlert(message, matchedRule.displayID, matchedRule.soundID, { r = 1, g = 0.25, b = 0.25 })
end

function GoldTracker:ProcessNoLootAlertTick()
    local session = self.session
    if not (session and session.active) then
        return
    end

    local runtime = self:EnsureAlertRuntimeForCurrentSession()
    if not self:IsAlertsEnabled() then
        runtime.noLootTriggered = false
        return
    end
    if not (self.db and self.db.noLootAlertEnabled == true) then
        runtime.noLootTriggered = false
        return
    end

    local thresholdMinutes = math.max(1, math.floor((tonumber(self.db.noLootAlertMinutes) or DEFAULT_NO_LOOT_MINUTES) + 0.5))
    local thresholdSeconds = thresholdMinutes * 60
    local now = time()
    local lastLootAt = tonumber(session.lastLootAt) or self:GetMostRecentSessionLootTimestamp(session)
    local elapsed = math.max(0, now - lastLootAt)

    if elapsed < thresholdSeconds then
        runtime.noLootTriggered = false
        return
    end

    if runtime.noLootTriggered == true then
        return
    end

    local elapsedMinutes = math.max(1, math.floor((elapsed / 60) + 0.5))
    local message = string.format("No loot for %dm (configured: %dm).", elapsedMinutes, thresholdMinutes)
    self:DispatchConfiguredAlert(
        message,
        self.db.noLootAlertDisplayID,
        self.db.noLootAlertSoundID,
        { r = 1, g = 0.55, b = 0.15 }
    )
    runtime.noLootTriggered = true
end

function GoldTracker:StartAlertTicker()
    if self.alertTicker or not C_Timer or type(C_Timer.NewTicker) ~= "function" then
        return
    end

    self.alertTicker = C_Timer.NewTicker(1, function()
        GoldTracker:ProcessNoLootAlertTick()
    end)
end

function GoldTracker:StopAlertTicker()
    if self.alertTicker and type(self.alertTicker.Cancel) == "function" then
        self.alertTicker:Cancel()
    end
    self.alertTicker = nil
end
