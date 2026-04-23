local _, NS = ...
local GoldTracker = NS.GoldTracker
local Theme = NS.JanisTheme

local HELP_MIN_WIDTH = 560
local HELP_MIN_HEIGHT = 390
local HELP_MAX_WIDTH = 980
local HELP_MAX_HEIGHT = 820

local function CreateHelpPanel(parent, bg, border)
    return Theme:CreatePanel(parent, bg, border)
end

local function CreateHelpButton(parent, width, height, text, paletteKey)
    return Theme:CreateButton(parent, width, height, text, paletteKey)
end

local VALUE_SOURCE_HELP = {
    TSM_DBMARKET = {
        meaning = "TSM's market value for the item on your realm/faction economy.",
        bestFor = "General local market estimates that are less jumpy than the cheapest current auction.",
        watchFor = "Can lag behind sudden price changes.",
    },
    TSM_DBRECENT = {
        meaning = "TSM's more recent local market value.",
        bestFor = "Reacting faster to current market movement.",
        watchFor = "Usually more volatile than Market Value or historical sources.",
    },
    TSM_DBREGIONMARKETAVG = {
        meaning = "TSM's region-wide market average.",
        bestFor = "Rare or thinly traded items where your realm has few auctions.",
        watchFor = "May not match what buyers are actually paying on your realm.",
    },
    TSM_DBMINBUYOUT = {
        meaning = "TSM's current minimum buyout.",
        bestFor = "Mirroring the cheapest visible auction. This is the addon's default primary source.",
        watchFor = "Can swing sharply, can be manipulated by one very low auction, and can be missing when the item is not posted.",
    },
    TSM_DBHISTORICAL = {
        meaning = "TSM's historical local price.",
        bestFor = "Stable realm-based estimates that smooth short-term spikes.",
        watchFor = "Reacts slowly when an item's value genuinely changes.",
    },
    TSM_DBREGIONHISTORICAL = {
        meaning = "TSM's region-wide historical price.",
        bestFor = "Stable fallback pricing for slow-moving or rare items.",
        watchFor = "Less specific to your realm's actual auction house.",
    },
    TSM_DBREGIONSALEAVG = {
        meaning = "TSM's region-wide average sale price.",
        bestFor = "Sale-realistic pricing when sold-price history matters more than listing price.",
        watchFor = "May be unavailable or stale for items with low sale volume.",
    },
    TSM_AUCTIONINGOPMIN = {
        meaning = "The minimum price from the item's assigned TSM Auctioning operation.",
        bestFor = "Respecting the hard floor from your own TSM posting rules.",
        watchFor = "Depends on the item having a matching TSM group and Auctioning operation.",
    },
    TSM_AUCTIONINGOPNORMAL = {
        meaning = "The normal price from the item's assigned TSM Auctioning operation.",
        bestFor = "Using your own TSM pricing rules as the main estimate. This is the addon's default fallback source.",
        watchFor = "Only works well when your TSM groups and operations are configured.",
    },
    TSM_AUCTIONINGOPMAX = {
        meaning = "The maximum price from the item's assigned TSM Auctioning operation.",
        bestFor = "Using the optimistic ceiling from your TSM posting rules.",
        watchFor = "Can overstate practical session value if your max price is intentionally aggressive.",
    },
    TSM_CRAFTING = {
        meaning = "TSM's crafting cost/value for the item.",
        bestFor = "Crafted items where material cost is more useful than auction price.",
        watchFor = "Is not a buyer-facing sale price and depends on usable TSM crafting/material data.",
    },
}

local HELP_TABS = {
    { key = "overview", label = "Overview" },
    { key = "session", label = "Session" },
    { key = "loot", label = "Loot" },
    { key = "history", label = "History" },
    { key = "values", label = "Value Sources" },
}

local HELP_TAB_BY_KEY = {}
for _, tab in ipairs(HELP_TABS) do
    HELP_TAB_BY_KEY[tab.key] = tab
end

local function AddLines(lines, ...)
    for index = 1, select("#", ...) do
        lines[#lines + 1] = select(index, ...)
    end
end

local function AddSection(lines, title, bullets)
    lines[#lines + 1] = title
    for _, bullet in ipairs(bullets or {}) do
        lines[#lines + 1] = "- " .. bullet
    end
    lines[#lines + 1] = ""
end

local function BuildOverviewText(addon)
    local currentSource = addon:GetCurrentValueSource()
    local fallbackSource = addon:GetFallbackValueSource()
    local currentSourceLabel = currentSource and currentSource.label or "Unknown"
    local fallbackSourceLabel = fallbackSource and fallbackSource.label or "None"

    local lines = {}
    lines[#lines + 1] = "GENERAL GOLD TRACKER"
    lines[#lines + 1] = ""

    AddSection(lines, "What it tracks", {
        "Raw gold looted during the current session.",
        "Auction-house value for tracked item loot.",
        "Vendor value for tracked items when Blizzard provides one.",
        "Highlight count for loot entries that meet your configured threshold.",
    })

    AddSection(lines, "Main totals", {
        "Current Session: raw looted gold plus auction-house item value.",
        "Raw Total: direct money loot plus vendor value.",
        "AH Value: item value returned by your selected TSM source.",
        "Session / h, AH / h, and Raw / h: totals divided by elapsed session time.",
    })

    AddSection(lines, "Current configuration", {
        "Primary value source: " .. currentSourceLabel,
        "Fallback value source: " .. fallbackSourceLabel,
        "Options controls value sources, highlight threshold, item quality filtering, alerts, history behavior, and experimental tools.",
    })

    return table.concat(lines, "\n")
end

local function BuildSessionText()
    local lines = {}
    lines[#lines + 1] = "SESSION WINDOW"
    lines[#lines + 1] = ""

    AddSection(lines, "Session controls", {
        "Start Session begins tracking.",
        "Stop Session ends the active session without clearing saved history.",
        "X hides the window and does not stop the active session.",
    })

    AddSection(lines, "Header buttons", {
        "- minimizes the window into the compact session view.",
        "_ reduces the window to the tiny total-only view.",
        "+ restores the normal session window from compact or tiny mode.",
        "X hides the window.",
    })

    AddSection(lines, "Utility buttons", {
        "Options: addon settings.",
        "Bags: auctionable inventory view.",
        "History: saved session history when history is enabled.",
        "Diag: runtime diagnostics when diagnostics are enabled.",
        "?: this guide.",
    })

    AddSection(lines, "Window modes", {
        "Maximized: full session summary plus loot stream controls.",
        "Minimized: Session Total, Raw Total, Session / h, and the latest highlighted item when one exists.",
        "Tiny: current session total plus the window controls only.",
        "/gt: opens the tracker in the mode selected in Options.",
    })

    return table.concat(lines, "\n")
end

local function BuildLootText()
    local lines = {}
    lines[#lines + 1] = "LOOT, HIGHLIGHTS, AND SOURCES"
    lines[#lines + 1] = ""

    AddSection(lines, "Loot Stream", {
        "Lists recent tracked item and money events.",
        "Shows time, item, value, and source information.",
        "Can be collapsed when you only need the summary panel.",
    })

    AddSection(lines, "Highlights", {
        "A highlighted item is a loot entry whose total value meets or exceeds your configured threshold.",
        "The highlight counter is the number of highlighted loot entries in the current session.",
        "The Last Highlight area shows the most recent highlighted item when the window has room for it.",
        "Compact mode shows the item and stack value on one row, with per-unit value below.",
    })

    AddSection(lines, "Loot source tracking", {
        "Attempts to attach mobs, units, zones, or instance context to loot.",
        "Feeds the loot stream, history details, and source-aware saved sessions.",
        "Can be adjusted from Options when you need a simpler tracking setup.",
    })

    AddSection(lines, "Item filtering", {
        "Quality filtering can prevent lower-quality items from being valued as auctionable loot.",
        "Raw gold is still tracked separately even when item filtering excludes an item.",
    })

    return table.concat(lines, "\n")
end

local function BuildHistoryText()
    local lines = {}
    lines[#lines + 1] = "HISTORY, BAGS, AND DIAGNOSTICS"
    lines[#lines + 1] = ""

    AddSection(lines, "Session History", {
        "Stores completed sessions for later review.",
        "Shows totals, item breakdowns, loot sources, value sources, and saved diagnosis snapshots.",
        "Can resume a saved session back into the active tracker.",
    })

    AddSection(lines, "Resume Session", {
        "Restores saved totals into the active tracker.",
        "Keeps reconstructed highlighted loot available for the main and compact windows.",
        "Does not require the original session to still be running.",
    })

    AddSection(lines, "Auctionable Inventory", {
        "Scans bags for items the addon can value through TSM.",
        "Helps compare possible posting value without needing to loot the item during a session.",
    })

    AddSection(lines, "Diagnosis", {
        "Experimental troubleshooting view.",
        "Shows event counters, tracking pipeline counters, and timing data.",
        "Enable it in Options > Experimental when you need to inspect loot event processing.",
    })

    return table.concat(lines, "\n")
end

local function BuildValueSourcesText(addon)
    local lines = {}
    lines[#lines + 1] = "VALUE SOURCES"
    lines[#lines + 1] = ""

    AddSection(lines, "How values work", {
        "General Gold Tracker asks TradeSkillMaster for the selected custom price source.",
        "The addon stores the copper value TSM returns for each item.",
        "The addon does not calculate TSM market data itself.",
    })

    AddSection(lines, "Primary and fallback sources", {
        "Primary source is used first.",
        "Fallback source is used when the primary source returns no usable value.",
        "Fallback can be disabled in Options.",
    })

    for _, source in ipairs(addon.VALUE_SOURCES or {}) do
        local help = VALUE_SOURCE_HELP[source.id] or {}
        lines[#lines + 1] = source.label
        lines[#lines + 1] = "- Meaning: " .. (help.meaning or "TSM value source.")
        lines[#lines + 1] = "- Best for: " .. (help.bestFor or "When that TSM source matches how you want session loot valued.")
        lines[#lines + 1] = "- Watch for: " .. (help.watchFor or "Availability depends on TSM data for the item.")
        lines[#lines + 1] = ""
    end

    AddSection(lines, "Practical setup notes", {
        "Use Min Buyout when you want the tracker to follow today's cheapest listing.",
        "Use Market Value or Historical Price when you prefer smoother local market estimates.",
        "Use region sources when local auctions are sparse or easy to manipulate.",
        "Use Auctioning operation sources when your TSM groups already encode your preferred sell price rules.",
        "Use Region Sale Avg when sale history matters more than listing price.",
        "Use Crafting Cost when crafting cost is the relevant value for your workflow.",
    })

    return table.concat(lines, "\n")
end

local HELP_TEXT_BUILDERS = {
    overview = BuildOverviewText,
    session = BuildSessionText,
    loot = BuildLootText,
    history = BuildHistoryText,
    values = BuildValueSourcesText,
}

local function ApplyTabVisualState(button, isSelected)
    if not button then
        return
    end

    if type(button.SetSelected) == "function" then
        button:SetSelected(isSelected == true)
    else
        button:SetEnabled(isSelected ~= true)
    end
end

function GoldTracker:UpdateHelpWindow()
    local frame = self.helpFrame
    if not frame or not frame.bodyText then
        return
    end

    local selectedKey = frame.selectedTabKey or "overview"
    if not HELP_TAB_BY_KEY[selectedKey] then
        selectedKey = "overview"
        frame.selectedTabKey = selectedKey
    end

    for _, tab in ipairs(HELP_TABS) do
        ApplyTabVisualState(frame.tabButtons and frame.tabButtons[tab.key], tab.key == selectedKey)
    end

    local builder = HELP_TEXT_BUILDERS[selectedKey] or BuildOverviewText
    frame.bodyText:SetText(builder(self))

    if frame.scrollContent and frame.scrollFrame then
        local innerWidth = math.max(1, math.floor((frame.scrollFrame:GetWidth() or 1) - 8))
        local visibleHeight = math.max(1, math.floor(frame.scrollFrame:GetHeight() or 1))
        frame.scrollContent:SetWidth(innerWidth)
        frame.bodyText:SetWidth(innerWidth)
        local contentHeight = math.max(visibleHeight, math.floor((frame.bodyText:GetStringHeight() or 0) + 24))
        frame.scrollContent:SetHeight(contentHeight)
        if frame.scrollFrame.UpdateScrollChildRect then
            frame.scrollFrame:UpdateScrollChildRect()
        end
    end
end

function GoldTracker:SelectHelpTab(tabKey)
    local frame = self.helpFrame
    if not frame then
        return
    end

    frame.selectedTabKey = HELP_TAB_BY_KEY[tabKey] and tabKey or "overview"
    if frame.scrollFrame then
        frame.scrollFrame:SetVerticalScroll(0)
    end
    self:UpdateHelpWindow()
end

function GoldTracker:CreateHelpWindow()
    if self.helpFrame then
        return
    end

    local addon = self
    local frame = CreateFrame("Frame", "GoldTrackerHelpFrame", UIParent, "BasicFrameTemplateWithInset")
    frame:SetSize(660, 520)
    frame:SetPoint("CENTER", UIParent, "CENTER", 0, 40)
    frame:SetFrameStrata("DIALOG")
    if frame.SetToplevel then
        frame:SetToplevel(true)
    end
    frame:SetMovable(true)
    frame:SetResizable(true)
    if frame.SetResizeBounds then
        frame:SetResizeBounds(HELP_MIN_WIDTH, HELP_MIN_HEIGHT, HELP_MAX_WIDTH, HELP_MAX_HEIGHT)
    else
        if frame.SetMinResize then
            frame:SetMinResize(HELP_MIN_WIDTH, HELP_MIN_HEIGHT)
        end
        if frame.SetMaxResize then
            frame:SetMaxResize(HELP_MAX_WIDTH, HELP_MAX_HEIGHT)
        end
    end
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnMouseDown", function(self)
        self:Raise()
    end)
    frame:SetScript("OnDragStart", function(self)
        self:Raise()
        self:StartMoving()
    end)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
    frame:Hide()
    frame.selectedTabKey = "overview"
    frame.tabButtons = {}

    local chrome = Theme:ApplyWindowChrome(frame, "Guide", {
        closeButtonKey = "helpCloseButton",
    })
    Theme:RegisterSpecialFrame("GoldTrackerHelpFrame")

    local panel = CreateHelpPanel(frame, { 0.05, 0.06, 0.08, 0.94 }, { 1.0, 0.82, 0.18, 0.10 })
    panel:SetPoint("TOPLEFT", chrome, "TOPLEFT", 12, -54)
    panel:SetPoint("BOTTOMRIGHT", chrome, "BOTTOMRIGHT", -12, 12)
    frame.helpPanel = panel

    local tabRow = CreateFrame("Frame", nil, panel)
    tabRow:SetPoint("TOPLEFT", panel, "TOPLEFT", 14, -14)
    tabRow:SetPoint("TOPRIGHT", panel, "TOPRIGHT", -14, -14)
    tabRow:SetHeight(24)
    frame.tabRow = tabRow

    local previousButton
    for _, tab in ipairs(HELP_TABS) do
        local tabKey = tab.key
        local buttonWidth = tabKey == "values" and 112 or 84
        local button = CreateHelpButton(tabRow, buttonWidth, 24, tab.label, "neutral")
        button:SetText(tab.label)
        if previousButton then
            button:SetPoint("LEFT", previousButton, "RIGHT", 8, 0)
        else
            button:SetPoint("TOPLEFT", tabRow, "TOPLEFT", 0, 0)
        end
        button:SetScript("OnClick", function()
            addon:SelectHelpTab(tabKey)
        end)
        frame.tabButtons[tabKey] = button
        previousButton = button
    end

    local tabsUnderline = panel:CreateTexture(nil, "ARTWORK")
    tabsUnderline:SetColorTexture(1, 0.82, 0, 0.35)
    tabsUnderline:SetPoint("TOPLEFT", panel, "TOPLEFT", 14, -48)
    tabsUnderline:SetPoint("TOPRIGHT", panel, "TOPRIGHT", -14, -48)
    tabsUnderline:SetHeight(1)

    local bodyPanel = CreateHelpPanel(panel, { 0.04, 0.05, 0.07, 0.92 }, { 1.0, 0.82, 0.18, 0.08 })
    bodyPanel:SetPoint("TOPLEFT", panel, "TOPLEFT", 14, -60)
    bodyPanel:SetPoint("BOTTOMRIGHT", panel, "BOTTOMRIGHT", -14, 14)
    frame.bodyPanel = bodyPanel

    local scrollFrame = CreateFrame("ScrollFrame", nil, bodyPanel, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", bodyPanel, "TOPLEFT", 14, -12)
    scrollFrame:SetPoint("BOTTOMRIGHT", bodyPanel, "BOTTOMRIGHT", -26, 12)
    scrollFrame:EnableMouseWheel(true)
    scrollFrame:SetScript("OnMouseWheel", function(self, delta)
        local step = 40
        local nextScroll = self:GetVerticalScroll() - (delta * step)
        local maxScroll = self:GetVerticalScrollRange()
        if nextScroll < 0 then
            nextScroll = 0
        elseif nextScroll > maxScroll then
            nextScroll = maxScroll
        end
        self:SetVerticalScroll(nextScroll)
    end)
    frame.scrollFrame = scrollFrame

    local scrollContent = CreateFrame("Frame", nil, scrollFrame)
    scrollContent:SetSize(1, 1)
    scrollFrame:SetScrollChild(scrollContent)
    frame.scrollContent = scrollContent

    local bodyText = scrollContent:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    bodyText:SetPoint("TOPLEFT", scrollContent, "TOPLEFT", 0, 0)
    bodyText:SetJustifyH("LEFT")
    bodyText:SetJustifyV("TOP")
    bodyText:SetTextColor(0.88, 0.92, 1.0)
    if type(bodyText.SetSpacing) == "function" then
        bodyText:SetSpacing(4)
    end
    bodyText:SetText("")
    frame.bodyText = bodyText

    local function RefreshHelpAfterResize()
        addon:UpdateHelpWindow()
    end

    Theme:CreateResizeButton(frame, {
        minWidth = HELP_MIN_WIDTH,
        minHeight = HELP_MIN_HEIGHT,
        maxWidth = HELP_MAX_WIDTH,
        maxHeight = HELP_MAX_HEIGHT,
        onResizeStop = function()
            RefreshHelpAfterResize()
        end,
    })

    frame:SetScript("OnSizeChanged", function()
        if frame.isManualResizing then
            return
        end
        RefreshHelpAfterResize()
    end)

    frame:SetScript("OnShow", function()
        addon:UpdateHelpWindow()
    end)

    self.helpFrame = frame
end

function GoldTracker:OpenHelpWindow(tabKey)
    self:CreateHelpWindow()
    if not self.helpFrame then
        return
    end

    self.helpFrame.selectedTabKey = HELP_TAB_BY_KEY[tabKey] and tabKey or self.helpFrame.selectedTabKey or "overview"
    self.helpFrame:Show()
    self.helpFrame:Raise()
    self:UpdateHelpWindow()
end

function GoldTracker:ToggleHelpWindow(tabKey)
    self:CreateHelpWindow()
    if not self.helpFrame then
        return
    end

    if self.helpFrame:IsShown() then
        self.helpFrame:Hide()
    else
        self:OpenHelpWindow(tabKey)
    end
end
