local _, NS = ...
local GoldTracker = NS.GoldTracker

-- Keep extended explanations out of the visible row text so help can be
-- thorough without making the settings pages unnecessarily tall.
local SETTING_HELP = {
    visualTheme = {
        details = "Changes the skin of all General Gold Tracker windows. Selecting a skin saves your preference and updates the sample; the rest of the UI changes after Reload UI.",
        example = "Choose Quiet Botanical, inspect the sample, then click Reload UI to apply it.",
    },
    mainWindowSlashOpenMode = {
        details = "Sets the initial tracker view when you open it with /gt: Maximized, Minimized, or Tiny. This does not change the Explorer or Options window size.",
        example = "Choose Tiny to open /gt as the compact tracker.",
    },
    showMainWindowGoldPerHour = {
        details = "Shows or hides the main tracker's gold-per-hour figure. Tracking continues either way. The active-loot-time option on Sessions & Loot controls which duration the calculation uses.",
        example = "Hide the rate when you only want to watch the session's accumulated value.",
    },
    showTotalWindowGoldPerHour = {
        details = "Shows or hides the gold-per-hour figure in the optional /gtt total window. This setting is available only in builds that enable that window.",
        example = "Turn it off to simplify the total window while keeping the main tracker rate visible.",
    },
    autoStartSessionOnFirstLoot = {
        details = "When no session is active, eligible item or money loot starts one automatically. The tracker window does not have to be open. Mailbox receipts are still subject to the mailbox filter.",
        example = "Log in without starting a session manually; your next eligible loot starts tracking.",
    },
    autoStartSessionOnEnterWorld = {
        details = "Starts a session on login, /reload, or instance entry when no session is already active. Restoring an active session after /reload takes priority over starting a new one.",
        example = "With resume enabled, /reload continues your current session; it does not create a second one.",
    },
    resumeSessionAfterReload = {
        details = "Saves the active session for a UI reload and restores its loot, totals, and elapsed progress afterward. Turning this off clears any pending reload snapshot; it does not delete session history.",
        example = "Use /reload during a farm and continue the same session afterward.",
    },
    autoStartSessionOnLocationChange = {
        details = "Allows an active session to split when the destination is an outdoor zone, including when leaving an instance. Entering a different instance already splits an active session independently of this option. The old session is saved when session history is enabled.",
        example = "Enable this to separate two outdoor farming zones into their own sessions.",
    },
    useActiveTimeForGoldPerHour = {
        details = "Uses time accumulated around tracked loot activity instead of the full elapsed session duration. Gaps between loot events contribute at most 90 seconds, reducing the effect of long breaks. This changes the rate calculation, not the amount earned.",
        example = "A long AFK break has less effect on gold/hour with active loot time enabled.",
    },
    minimumTrackedItemQuality = {
        details = "Sets the quality cutoff for ordinary items' AH valuation. Lower-quality items can still be recorded and shown in the loot log as Below min quality, using vendor value when available. Crafting reagents bypass the cutoff; unknown-quality items are retained rather than silently dropped. Recorded session loot is not deleted.",
        example = "Choose Rare: an ordinary Uncommon item uses vendor value in the log, while a crafting reagent can still receive AH valuation.",
    },
    ignoreMailboxLootWhenMailOpen = {
        details = "Ignores item and money receipts while the mailbox is open. This helps keep mail collections out of farming sessions. It is a mailbox-window filter rather than a test of each item's original source.",
        example = "Collect auction proceeds or mailed materials without counting them as new farm loot.",
    },
    showRawLootedGoldInLog = {
        details = "Controls whether directly looted money appears as individual loot-log entries. The money still contributes to the session's raw-gold total when these log entries are hidden.",
        example = "Turn this off to reduce repeated coin entries during a dungeon run.",
    },
    showLootLogTimestamps = {
        details = "Shows the recorded time next to loot entries. This controls presentation; it does not change when loot is tracked or saved.",
        example = "Use timestamps to compare a valuable drop with the point at which you changed farming areas.",
    },
    enableLootSourceTracking = {
        details = "Attempts to attach the unit, gathering node, or area-loot source to tracked loot. Some loot events do not provide an identifiable source. Turning this off stops source detection without stopping item or money tracking.",
        example = "A gathering entry can identify the node; area loot may be labelled as an AoE source.",
    },
    valueSource = {
        details = "Chooses the preferred item-price source for the active tracker. If it has no usable price, the shared fallback order is tried. Materials, Instances, Rares, Drops, and Bags have their own selectors. These are estimates, not guaranteed sale proceeds.",
        example = "Prefer Min Buyout for the tracker, then use Market Value as the first missing-price fallback.",
    },
    auctionableInventoryValueSource = {
        details = "Chooses the source used by Auctionable Inventory in Bags and updates an already-created Bags view. It also supplies that view's selected-value market snapshots. It does not change the tracker's preferred source.",
        example = "Use Market Value for Bags while keeping Min Buyout for your active farming session.",
    },
    valueSourceFallbackOrder = {
        details = "The first usable fallback price wins. Drag a source or use its arrows to change priority. A source already tried is skipped, so repeating the preferred source does not query it again. Reset order restores only this list.",
        example = "If Min Buyout is missing, try Market Value before Region Market Avg.",
    },
    autoOpenAuctionableInventoryOnAuctionHouse = {
        details = "Opens the Bags Auctionable Inventory view when you click an Auction House Sell tab. It helps review the items you could sell; it does not post auctions or set their prices.",
        example = "Click Sell at the AH to bring your auctionable bag contents into view.",
    },
    inventoryCategoryOrder = {
        details = "Changes the display order of the Bags categories. Drag a row or use the up/down arrows. This changes category presentation, not the physical order of items in your bags. Reset order restores the default category sequence.",
        example = "Move Consumables above Crafting Items if you usually check consumables first.",
    },
    altLowLevelThreshold = {
        details = "Characters below the cutoff appear in a collapsed low-level group and are omitted from farm character choices. A character exactly at the cutoff stays eligible. Use 0 to disable the cutoff. Recorded levels update when you log in to each character.",
        example = "At 20, a level-19 alt is grouped separately; a level-20 alt remains eligible for farms.",
    },
    worldMapProjectionPinScale = {
        details = "Scales farming pins projected onto the Blizzard world map. This does not change the map's zoom level, the farming route coordinates, or the scale of every map inside the addon.",
        example = "150% makes the projected pins one and a half times their normal size.",
    },
    mapPinIcon = {
        details = "Chooses a shared farming-pin symbol on supported Blizzard, minimap, and standalone farming-map displays. It changes the marker artwork, not the saved position or route.",
        example = "Choose Herb for a gathering route or Treasure chest for a loot farm.",
    },
    enableSessionHistory = {
        details = "Allows sessions to be saved and makes History available. Turning it off hides the History window and stops new history saves; it does not erase existing saved sessions. Market-price observations have separate storage controls below.",
        example = "Keep this enabled to compare the results of several completed farming runs.",
    },
    allowResumeHistorySession = {
        details = "Allows loading a saved history session into the active tracker. With no active session, its recorded loot and totals are restored; with an active session, loading can merge the saved loot into it.",
        example = "Load a completed run to continue tracking it. Check whether a session is already active before loading.",
        disabled = "Enable Save session history to use saved-session loading.",
    },
    historyRowsPerPage = {
        details = "Sets how many sessions appear on one History list page. Changing it returns the visible list to page one. It does not change the number of sessions stored.",
        example = "Use 20 rows to see twice as many sessions per page as the default 10.",
        disabled = "Enable Save session history to adjust its list display.",
    },
    historyDetailsFontSize = {
        details = "Sets the text size inside saved-session details. It does not change every font in the addon or the underlying session data.",
        example = "Increase to 18 px if saved loot details are difficult to read.",
        disabled = "Enable Save session history to adjust its details display.",
    },
    marketHistorySnapshotIntervalMinutes = {
        details = "Each item can gain a new price observation after this many minutes, when it is next displayed or discovered by a supported view. Repeated displays inside the interval do not create extra samples. This is not a scheduled scan of unseen items.",
        example = "With 60 minutes, displaying the same item after 10 minutes adds no sample; displaying it after an hour can add one.",
    },
    marketHistoryRetentionDays = {
        details = "Sets the age limit for local price observations. Older observations can be removed during maintenance, including when you change this limit. It affects price graphs, not saved farming sessions.",
        example = "120 days retains roughly four months of observations, subject to the per-item sample limit.",
    },
    marketHistoryUnlimitedItems = {
        details = "Removes the cap on how many different items have price histories. It does not remove the age or samples-per-item limits. When you turn this off, the last item cap used while this Options window has been open is restored, or 500 is used initially.",
        example = "Track 2,000 different items with this on while keeping at most 240 samples for each.",
    },
    marketHistoryMaxItems = {
        details = "Caps the number of different item histories retained when Unlimited items is off. If the cap is exceeded, the least recently seen item histories are removed first. Lowering this value can remove observations immediately.",
        example = "A limit of 1,000 keeps up to 1,000 item histories, not 1,000 samples in total.",
        disabled = "Turn off Unlimited items to edit and apply an item-count limit.",
    },
    marketHistoryMaxSnapshotsPerItem = {
        details = "Limits the observations retained for each individual item. When it fills, the oldest samples are removed first. Shorter observation intervals therefore use up this sample allowance sooner.",
        example = "240 hourly observations cover about 10 days for an item observed every hour, even with 120-day retention.",
    },
    notificationsEnabled = {
        details = "Master switch for session milestones, high-value loot, and no-loot alerts. Turning it off keeps the rules and their values for later. Explorer Market Watch is a separate price-comparison view.",
        example = "Disable alerts temporarily during a quiet session, then turn them back on without rebuilding your rules.",
    },
    sessionMilestoneAlerts = {
        details = "Each enabled rule fires once when an active session total crosses its gold threshold. Every rule has its own sound and display destination. Add up to 20 rules; Test previews an alert without advancing milestone progress.",
        example = "A 500 g milestone fires when the session rises from 490 g to 510 g.",
        disabled = "Turn on Enable alerts to edit or test milestone rules.",
    },
    highValueDropAlerts = {
        details = "Compares the total value of one tracked loot entry, including its quantity, against the enabled rules. If several rules match, the last matching rule in the list supplies the notification. Add up to 20 rules.",
        example = "A stack of 5 items worth 20 g each reaches a 100 g drop threshold.",
        disabled = "Turn on Enable alerts to edit or test drop rules.",
    },
    noLootAlertEnabled = {
        details = "During an active session, alerts after a period without tracked item or money loot. It fires once per quiet period and rearms when loot is tracked again. The master Enable alerts switch must also be on.",
        example = "After one no-loot warning, a new loot event allows the next quiet period to trigger another warning.",
        disabled = "Turn on Enable alerts to use no-loot notifications.",
    },
    noLootAlertMinutes = {
        details = "Sets the number of minutes without tracked loot before the no-loot warning. It only runs for an active session with both alert switches enabled.",
        example = "At 5 minutes, a session with no new tracked loot for five minutes can warn once.",
        disabled = "Turn on Enable alerts and Enable no-loot alert to set the quiet period.",
    },
    noLootAlertSoundID = {
        details = "Chooses the sound for the no-loot warning. None makes it silent while keeping the selected visual display. Use Test no-loot alert to preview the combination.",
        example = "Select Ready Check for a familiar sound, or None for a visual-only warning.",
        disabled = "Turn on Enable alerts and Enable no-loot alert to choose a sound.",
    },
    noLootAlertDisplayID = {
        details = "Chooses where the no-loot warning appears. No visual uses sound only; combined destinations show the same warning in several places. The chat part also requires Enable chat logging and Alerts in chat on the Logging page.",
        example = "Chat + Center text shows both; disabling Alerts in chat leaves the center text and sound active.",
        disabled = "Turn on Enable alerts and Enable no-loot alert to choose a display.",
    },
    testNoLoot = {
        details = "Immediately previews the configured no-loot sound and display. It does not wait for the quiet period, change session totals, or consume the next real no-loot warning.",
        example = "Choose a sound and display, then press Test alert to check that combination.",
        disabled = "Turn on Enable alerts and Enable no-loot alert before testing.",
    },
    enableDiagnosticsPanel = {
        details = "Enables runtime event counters and timing measurements and exposes the Diagnosis button in the tracker. It is useful for investigating missing loot or performance issues; it does not change pricing or the loot filters.",
        example = "Enable diagnostics before reproducing an issue, then inspect the Diagnosis window.",
    },
    enableExperimentalMaps = {
        details = "Off by default. Enables the unfinished seamless map renderer in Alts, continent-group maps, and every Global Map tab: stitched zone paintings, custom coast blending, and close-up minimap terrain. When off, these views keep ordinary Blizzard map paintings and recorded character pins. Pan, zoom, reset, destinations, roles, and other Alts features remain available. Switching applies immediately and resets each map to its starting view; it does not erase recorded locations or discoveries.",
        example = "Leave this off for regular maps. Enable it while testing the refined Northrend map, then turn it off to return to Blizzard's original paintings.",
    },
    enableChatLogging = {
        details = "Master switch for all GGT chat output, including warnings, command replies, TSM reports, and the chat part of alerts. Category choices stay saved when this is off. It does not change loot tracking, the tracker's loot log, alert sounds, or other alert displays. Messages appear in your default chat frame and are not saved as a separate log file.",
        example = "Turn this off for a quiet chat, then turn it back on to restore your selected categories.",
    },
    chatLogStartup = {
        details = "Shows the one-line Loaded message when GGT loads at login or after /reload. Off by default to avoid repeating the same welcome text. Automatic session starts are controlled separately by Session activity.",
        example = "Enable this to see the /gt reminder after each reload.",
    },
    chatLogSessions = {
        details = "Shows session starts, stops and total values, reload restoration, and automatic starts or location splits. Repeated Start or Stop requests also report whether a session is already active. This changes messages only, never session behavior.",
        example = "Keep this on to see the session total after pressing Stop.",
    },
    chatLogScans = {
        details = "Shows existing Rare Farming and Dungeon & Raid Farming scan completion messages and notices when an instance scan continues after closing its window. It does not add per-item output or extra scans. Rare Farming's separate center-screen completion notice is unchanged.",
        example = "Turn this off to finish a Rare Farming scan without its chat summary.",
    },
    chatLogNavigation = {
        details = "Shows successful waypoint placement, projected-pin creation or clearing, and next-stop confirmations. Off by default because route actions already provide map feedback. Missing coordinates and unavailable map APIs use Warnings & errors instead.",
        example = "Enable this to confirm the name of a newly selected farm stop in chat.",
    },
    chatLogFarms = {
        details = "Shows custom-farm target additions, duplicate-target notices, and successful custom-material additions. Failed farm actions use Warnings & errors so you can hide routine confirmations and still see problems.",
        example = "Turn this off while adding many targets to a custom farm.",
    },
    chatLogHistory = {
        details = "Shows saved-session load or merge confirmations and history split, merge, or deletion results. It affects feedback only; your history settings and saved records are unchanged. Failed or unavailable actions use Warnings & errors.",
        example = "Keep this on to see how many selected history sessions were deleted.",
    },
    chatLogAlerts = {
        details = "Allows the chat part of configured session milestone, high-value drop, and no-loot alerts, including their Test buttons. The alert must still be enabled and have a chat destination on the Alerts page. Sounds, center text, raid warnings, and tracker-log destinations work independently.",
        example = "Turn this off to keep an alert's sound and center text without its chat copy.",
    },
    chatLogWarnings = {
        details = "Shows actionable problems such as unavailable TSM pricing, missing map coordinates, unavailable windows, or failed farm/history actions. GGT's master chat switch can silence these too. The TSM-unavailable warning remains limited to once until pricing succeeds or a session resets it.",
        example = "Leave this on while hiding navigation confirmations to still see a missing-coordinate warning.",
    },
    chatLogCommands = {
        details = "Shows /gt help, usage and unknown-command responses, /gt market output, /gttsm diagnostic reports, and general action replies such as loading a bag item into the AH. Session, history, farm and navigation results follow their own categories.",
        example = "Leave this on if you use /gttsm item 123 or /gt market to inspect price data.",
    },
    chatLogTimestamps = {
        details = "Prefixes emitted GGT messages with local game time in HH:MM:SS format. Every message also shows its category. Off by default because the game's own chat timestamps may already provide the time; this does not change timestamps in the tracker's loot log.",
        example = "Enable this for a message beginning 14:32:08 when comparing events during troubleshooting.",
    },
    testChatLogging = {
        details = "Sends one message to the default chat frame to confirm logging works immediately. The test follows the master switch and timestamp preference but ignores the individual category switches. It does not start a session, play sounds, or change saved data.",
        example = "Enable chat logging, then click Test chat to see a message labeled Test.",
    },
}

-- Dropdown menu items support native tooltip fields. Keep these descriptions
-- factual and local; showing help must never query TSM or load a catalog.
NS.OptionsChoiceHelp = {
    TSM_DBMARKET = "TSM DBMarket: a local market-value estimate. Requires available TSM price data.",
    TSM_DBRECENT = "TSM DBRecent: the recent local price source. Requires available TSM price data.",
    TSM_DBREGIONMARKETAVG = "TSM DBRegionMarketAvg: a region-wide market average, which may differ from your realm's prices.",
    TSM_DBMINBUYOUT = "TSM DBMinBuyout: the minimum buyout from TSM's available auction data. It is not a fresh AH scan or a guaranteed sale price.",
    TSM_DBHISTORICAL = "TSM DBHistorical: the local historical-price source.",
    TSM_DBREGIONHISTORICAL = "TSM DBRegionHistorical: the region-wide historical-price source.",
    TSM_DBREGIONSALEAVG = "TSM DBRegionSaleAvg: a region-wide average sale-price source. Availability depends on TSM's data.",
    TSM_AUCTIONINGOPMIN = "TSM AuctioningOpMin: the minimum price from an applicable Auctioning operation. Requires configured TSM groups and operations.",
    TSM_AUCTIONINGOPNORMAL = "TSM AuctioningOpNormal: the normal price from an applicable Auctioning operation. Requires configured TSM groups and operations.",
    TSM_AUCTIONINGOPMAX = "TSM AuctioningOpMax: the maximum price from an applicable Auctioning operation. This can differ substantially from a practical sale price.",
    TSM_CRAFTING = "TSM Crafting: the item's crafting cost. This measures cost rather than guaranteed sale proceeds.",
    maximized = "Open /gt with the main tracker expanded.",
    minimized = "Open /gt with the main tracker minimized.",
    tiny = "Open /gt in its smallest tracker view.",
    NONE = "Disable this part of the alert. In Sound, None is silent; in Display, No visual leaves only the selected sound.",
    CHAT = "Show a chat message when Logging > Enable chat logging and Alerts in chat are on.",
    RAID_WARNING = "Use the raid-warning display. In the Sound menu this instead selects the Raid Warning sound.",
    CENTER = "Show the warning in the center-screen message area.",
    LOG = "Add the warning to the tracker log.",
    CHAT_RAID = "Show raid-warning text plus a chat copy when the Logging page allows alert chat messages.",
    CHAT_CENTER = "Show center-screen text plus a chat copy when the Logging page allows alert chat messages.",
    ALL = "Show chat, raid warning, center text, and tracker log. The Logging page controls only the chat copy.",
    EPICLOOT = "Play the Epic Loot Toast sound when the alert fires.",
    READY_CHECK = "Play the Ready Check sound when the alert fires.",
    CHECKBOX_ON = "Play the Checkbox On sound when the alert fires.",
}

-- These pages describe preferences only. Saved sessions, scans, farms, and other
-- recorded data never participate in a page reset.
function GoldTracker:GetOptionsPageDefinitions()
    local addon = self
    local lastMarketItemLimit = addon.db.marketHistoryMaxItems > 0 and addon.db.marketHistoryMaxItems or 500
    local function call(name, ...)
        if type(addon[name]) == "function" then return addon[name](addon, ...) end
    end
    local function visible(name, refresh, ...)
        local frame = addon[name]
        if frame and frame:IsShown() then call(refresh, ...) end
    end
    local function refreshHistory()
        local frame = addon.historyFrame
        if frame and frame:IsShown() then
            call(frame.view == "details" and "RefreshHistoryDetailsWindow" or "RefreshHistoryWindow")
        end
    end
    local function setting(key, label, help, kind, extra)
        local spec = { key = key, label = label, help = help, kind = kind or "check" }
        local extended = SETTING_HELP[key]
        if extended then
            spec.details, spec.example, spec.disabledReason = extended.details, extended.example, extended.disabled
        end
        for k, v in pairs(extra or {}) do spec[k] = v end
        return spec
    end
    local function section(title, items, help)
        return { title = title, items = items, help = help }
    end
    local function page(id, label, help, sections)
        return { id = id, label = label, help = help, sections = sections }
    end
    local function updateTracker() call("UpdateMainWindow") end
    local function historyEnabled() return addon.db.enableSessionHistory == true end
    local function alertsEnabled() return addon:IsAlertsEnabled() end
    local function noLootEnabled() return alertsEnabled() and addon.db.noLootAlertEnabled == true end
    local function chatEnabled() return addon.db.enableChatLogging == true end
    local function chatSetting(key, label, help)
        return setting(key, label, help, "check", {
            enabled = chatEnabled,
            disabledReason = "Turn on Enable chat logging. Your category choices are kept while chat is off.",
        })
    end
    local function sourceChoices() return addon.VALUE_SOURCES end
    local function marketNumber(key, label, help, min, max, unit)
        return setting(key, label, help, "number", {
            min = min, max = max, unit = unit,
            set = function(value)
                addon:SetMarketHistoryNumberOption(key, value, min, max, addon.DEFAULTS[key])
            end,
        })
    end
    return {
        page("appearance", "Appearance", "Choose your skin and how the tracker opens.", {
            section("UI skin", {
                setting("visualTheme", "Window skin", "Applies to all tracker windows after reloading the UI.", "theme", {
                    choices = function()
                        local choices = {}
                        for _, key in ipairs(NS.VISUAL_THEME_OPTIONS) do
                            choices[#choices + 1] = { id = key, label = NS.VISUAL_THEME_LABELS[key] }
                        end
                        return choices
                    end,
                    get = function() return addon:GetVisualThemeKey() end,
                    set = function(value) addon:SetVisualTheme(value) end,
                    keywords = "appearance color theme skin reload",
                }),
            }),
            section("Tracker window", {
                setting("mainWindowSlashOpenMode", "Default /gt view", "Choose the view used when opening the tracker with /gt.", "select", {
                    choices = function() return addon.MAIN_WINDOW_SLASH_OPEN_MODES end,
                }),
                setting("showMainWindowGoldPerHour", "Show gold per hour", "Display the gold/hour total in the main tracker.", "check", { set = function(v) addon.db.showMainWindowGoldPerHour = v; updateTracker() end }),
                setting("showTotalWindowGoldPerHour", "Show gold per hour in /gtt", "Display gold/hour in the total window.", "check", {
                    available = function() return addon:IsTotalWindowFeatureEnabled() end,
                    set = function(v) addon.db.showTotalWindowGoldPerHour = v; updateTracker() end,
                }),
            }),
        }),
        page("tracking", "Sessions & Loot", "Control session behavior, loot filtering, and the loot log.", {
            section("Start a session", {
                setting("autoStartSessionOnFirstLoot", "Start on first loot", "Start tracking when an eligible item or money loot is received."),
                setting("autoStartSessionOnEnterWorld", "Start on login or instance entry", "Also starts a new session after /reload when no active session was restored."),
            }),
            section("Continue or split a session", {
                setting("resumeSessionAfterReload", "Resume after /reload", "Restore the active session before considering automatic startup.", "check", {
                    set = function(v) addon.db.resumeSessionAfterReload = v; if not v then call("ClearPendingReloadSession") end end,
                }),
                setting("autoStartSessionOnLocationChange", "Split on location change", "Also split an active session when changing outdoor zones or leaving an instance."),
            }),
            section("Gold/hour calculation", {
                setting("useActiveTimeForGoldPerHour", "Use active loot time", "Ignore long idle gaps when calculating gold per hour.", "check", {
                    set = function(v) addon.db.useActiveTimeForGoldPerHour = v; updateTracker() end,
                }),
            }),
            section("Loot filtering", {
                setting("minimumTrackedItemQuality", "Minimum item quality", "AH-value cutoff for ordinary items. Lower-quality loot can still appear with vendor value; crafting reagents bypass the cutoff.", "select", {
                    choices = function()
                        local choices = {}
                        for _, option in ipairs(addon.TRACKED_ITEM_QUALITY_OPTIONS) do
                            choices[#choices + 1] = { id = option.id, label = addon:GetColoredItemQualityLabel(option.id, option.label) }
                        end
                        return choices
                    end,
                    set = function(v)
                        addon.db.minimumTrackedItemQuality = v
                        call("NormalizeMinimumTrackedItemQuality"); updateTracker()
                        refreshHistory()
                    end,
                }),
                setting("ignoreMailboxLootWhenMailOpen", "Ignore mailbox loot", "Exclude mailbox receipts while the mail window is open."),
            }),
            section("Loot log", {
                setting("showRawLootedGoldInLog", "Show raw gold entries", "Include directly looted money in the loot stream."),
                setting("showLootLogTimestamps", "Show timestamps", "Display the time beside loot entries.", "check", {
                    set = function(v) addon.db.showLootLogTimestamps = v; call("RefreshMainWindowLayout") end,
                }),
                setting("enableLootSourceTracking", "Track loot sources", "Record the unit, gathering node, or area-loot source.", "check", {
                    set = function(v) addon.db.enableLootSourceTracking = v; if not v then call("OnLootClosed") end end,
                }),
            }),
        }),
        page("pricing", "Pricing", "Each window uses its selected source, then the shared fallback order if no price is available.", {
            section("Price sources", {
                setting("valueSource", "Tracker price source", "Preferred item value source for the active session.", "select", {
                    choices = sourceChoices, keywords = "TSM auction value market",
                    set = function(v)
                        addon.db.valueSource = v
                        if addon.db.fallbackValueSource == v then addon.db.fallbackValueSource = "" end
                        addon.tsmWarningShown = false; updateTracker()
                    end,
                }),
                setting("auctionableInventoryValueSource", "Bags default price source", "Used for Auctionable Inventory totals and its market snapshots.", "select", {
                    choices = sourceChoices, keywords = "TSM auction inventory market",
                    set = function(v) addon:SetAuctionableInventoryValueSource(v); visible("inventoryFrame", "RefreshInventoryWindow", true) end,
                }),
            }, "Materials, Instances, Rares, and Drops keep their own source selectors in those windows."),
            section("Missing-price fallback order", {
                setting("valueSourceFallbackOrder", "Fallback sources", "Try these in order when a window's selected source has no price. Duplicate sources are skipped.", "order", {
                    choices = sourceChoices,
                    get = function() return addon:GetValueSourceFallbackOrder() end,
                    set = function(v) addon:SetValueSourceFallbackOrder(v); updateTracker() end,
                    keywords = "TSM missing price priority drag reorder",
                }),
            }),
        }),
        page("bags", "Bags", "Set Auctionable Inventory behavior and category order.", {
            section("Auction House", {
                setting("autoOpenAuctionableInventoryOnAuctionHouse", "Open Bags from the Sell tab", "Open Auctionable Inventory when you click the Auction House Sell tab."),
            }),
            section("Category display order", {
                setting("inventoryCategoryOrder", "Inventory categories", "Drag a category or use the arrows to change its position.", "order", {
                    choices = function() return addon.INVENTORY_CATEGORY_OPTIONS end,
                    get = function() return addon:GetInventoryCategoryOrder() end,
                    set = function(v) addon:SetInventoryCategoryOrder(v) end,
                    keywords = "inventory category sorting drag reorder",
                }),
            }),
        }),
        page("alts", "Alts", "Control how low-level characters appear in lists and farm assignments.", {
            section("Character grouping", {
                setting("altLowLevelThreshold", "Low-level cutoff", "Characters below this level go into a collapsed group and are excluded from farm character choices. Use 0 to disable. Levels update when you log in to each alt.", "number", {
                    min = 0, max = 1000, unit = "level", keywords = "character farm level",
                    get = function() return addon:GetAltLowLevelThreshold() end,
                    set = function(v) addon:SetAltLowLevelThreshold(v) end,
                }),
            }),
        }),
        page("maps", "Maps", "Customize farming pins and their size on the Blizzard world map.", {
            section("Map pins", {
                setting("worldMapProjectionPinScale", "Blizzard map pin size", "Scale pins projected onto the Blizzard world map.", "slider", {
                    min = 0.6, max = 2, step = 0.1, unit = "%", multiplier = 100,
                    get = function() return addon:GetWorldMapProjectionPinScale() end,
                    set = function(v) addon:SetWorldMapProjectionPinScaleOption(v) end,
                }),
                setting("mapPinIcon", "Farming pin icon", "Choose the icon used for farming pins on supported maps.", "select", {
                    choices = function() return addon.MAP_PIN_ICON_OPTIONS end,
                    set = function(v) addon:SetMapPinIconOption(v) end,
                }),
            }),
        }),
        page("history", "History & Storage", "Manage session records and item-price observations separately.", {
            section("Session history", {
                setting("enableSessionHistory", "Save session history", "Keep completed sessions available in History.", "check", {
                    set = function(v)
                        addon.db.enableSessionHistory = v; call("RefreshHistoryButtonVisibility")
                        if not v and addon.historyFrame then addon.historyFrame:Hide() end
                    end,
                }),
                setting("allowResumeHistorySession", "Load saved sessions", "Allow a saved history session to be loaded into the active tracker.", "check", {
                    enabled = historyEnabled,
                    set = function(v) addon.db.allowResumeHistorySession = v; refreshHistory() end,
                }),
            }),
            section("History display", {
                setting("historyRowsPerPage", "Rows per page", "Number of sessions shown on each history list page.", "slider", {
                    min = 5, max = 30, step = 1, unit = "rows", enabled = historyEnabled,
                    get = function() return addon:GetHistoryRowsPerPage() end,
                    set = function(v) addon:SetHistoryRowsPerPageOption(v) end,
                }),
                setting("historyDetailsFontSize", "Details text size", "Font size inside saved-session details.", "slider", {
                    min = 8, max = 24, step = 1, unit = "px", enabled = historyEnabled,
                    get = function() return addon:GetHistoryDetailsFontSize() end,
                    set = function(v) addon:SetHistoryDetailsFontSizeOption(v) end,
                }),
            }),
            section("Market-price storage", {
                marketNumber("marketHistorySnapshotIntervalMinutes", "Observation interval", "Keep one new price observation per item per interval when it is displayed or discovered.", 1, 1440, "minutes"),
                marketNumber("marketHistoryRetentionDays", "Keep observations for", "Older price observations are removed by the retention policy.", 14, 365, "days"),
                setting("marketHistoryUnlimitedItems", "Unlimited items", "Keep histories for every observed item. Retention and samples per item still apply.", "check", {
                    resetKey = "marketHistoryMaxItems",
                    get = function() return addon.db.marketHistoryMaxItems == 0 end,
                    set = function(v)
                        if addon.db.marketHistoryMaxItems > 0 then lastMarketItemLimit = addon.db.marketHistoryMaxItems end
                        addon:SetMarketHistoryNumberOption("marketHistoryMaxItems", v and 0 or lastMarketItemLimit, 0, 50000, 0)
                    end,
                    reset = function() addon.db.marketHistoryMaxItems = 0; lastMarketItemLimit = 500 end,
                }),
                setting("marketHistoryMaxItems", "Maximum items", "Used only when Unlimited items is off. Lowering storage limits can remove old observations.", "number", {
                    min = 1, max = 50000, unit = "items",
                    get = function() return addon.db.marketHistoryMaxItems > 0 and addon.db.marketHistoryMaxItems or lastMarketItemLimit end,
                    set = function(v)
                        lastMarketItemLimit = v
                        addon:SetMarketHistoryNumberOption("marketHistoryMaxItems", v, 1, 50000, 500)
                    end,
                }),
                marketNumber("marketHistoryMaxSnapshotsPerItem", "Samples per item", "Maximum saved observations for each item; the oldest samples are removed first.", 24, 1000, "samples"),
            }, "These observations power price graphs. Session history is stored separately."),
        }),
        page("alerts", "Alerts", "Configure session notifications, sounds, and display destinations.", {
            section("Alert system", {
                setting("notificationsEnabled", "Enable alerts", "Enable session milestones, high-value drops, and no-loot notifications."),
            }),
            section("Session milestones", {
                setting("sessionMilestoneAlerts", "Milestone rules", "Notify when the session total reaches a threshold. Amounts are in gold.", "rules", { enabled = alertsEnabled }),
            }),
            section("High-value drops", {
                setting("highValueDropAlerts", "Drop rules", "Notify when one loot entry reaches a threshold, including stack quantity. Amounts are in gold.", "rules", { enabled = alertsEnabled }),
            }),
            section("No loot", {
                setting("noLootAlertEnabled", "Enable no-loot alert", "Fire once after a quiet period, then rearm when another item or money loot is tracked.", "check", { enabled = alertsEnabled }),
                setting("noLootAlertMinutes", "Quiet period", "Minutes without tracked loot before the alert fires.", "number", {
                    min = 1, max = 180, unit = "minutes", enabled = noLootEnabled,
                    set = function(v) addon:SetNoLootAlertMinutes(v) end,
                }),
                setting("noLootAlertSoundID", "Sound", "Sound played by the no-loot alert.", "select", { choices = function() return addon.ALERT_SOUND_OPTIONS end, enabled = noLootEnabled }),
                setting("noLootAlertDisplayID", "Display", "Where the no-loot alert appears.", "select", { choices = function() return addon.ALERT_DISPLAY_OPTIONS end, enabled = noLootEnabled }),
                setting("testNoLoot", "Test no-loot alert", "Preview the selected sound and display without changing session progress.", "action", {
                    text = "Test alert", enabled = noLootEnabled,
                    action = function() addon:DispatchConfiguredAlert("Test: no loot alert", addon.db.noLootAlertDisplayID, addon.db.noLootAlertSoundID) end,
                }),
            }),
        }),
        page("logging", "Logging", "Choose which GGT messages appear in your default chat frame. Changes apply immediately.", {
            section("Chat output", {
                setting("enableChatLogging", "Enable chat logging", "Master switch for GGT messages, warnings, command replies, and alert chat copies."),
                chatSetting("chatLogTimestamps", "Show chat timestamps", "Prefix messages with local time (HH:MM:SS)."),
                setting("testChatLogging", "Test chat output", "Send one sample message using the master switch and timestamp preference.", "action", {
                    text = "Test chat", enabled = chatEnabled,
                    disabledReason = "Turn on Enable chat logging before sending a test message.",
                    action = function() addon:Print("Chat logging is working. Choose your message categories below.", "test") end,
                }),
            }, "Chat output is separate from the tracker's loot log and runtime diagnostics."),
            section("Message categories", {
                chatSetting("chatLogStartup", "Startup message", "Show the Loaded reminder at login and after /reload. Off by default."),
                chatSetting("chatLogSessions", "Session activity", "Starts, stops, reload restoration, and automatic session changes."),
                chatSetting("chatLogScans", "Farming scans", "Scan completion summaries and background-scan notices."),
                chatSetting("chatLogNavigation", "Maps & navigation", "Waypoint, projected-pin, and next-stop confirmations. Off by default."),
                chatSetting("chatLogFarms", "Farm edits", "Custom-farm target and custom-material confirmations."),
                chatSetting("chatLogHistory", "History actions", "Saved-session loading, splitting, merging, and deletion results."),
                chatSetting("chatLogAlerts", "Alerts in chat", "Allow chat copies of alerts whose display destination includes Chat."),
                chatSetting("chatLogWarnings", "Warnings & errors", "Missing pricing, unavailable features, and failed actions."),
                chatSetting("chatLogCommands", "Command & action replies", "Help, usage, market/TSM reports, and general action feedback."),
            }),
        }),
        page("advanced", "Advanced", "Runtime troubleshooting and diagnostics.", {
            section("Diagnostics", {
                setting("enableDiagnosticsPanel", "Runtime diagnostics", "Show the Diagnosis button and collect event counters and timing data.", "check", {
                    set = function(v)
                        addon.db.enableDiagnosticsPanel = v
                        if v and addon.session and addon.session.active then call("EnsureSessionDiagnosisSnapshot") end
                        call("RefreshDiagnosisButtonVisibility")
                        if not v and addon.diagnosisFrame and addon.diagnosisFrame.mode ~= "history" then addon.diagnosisFrame:Hide() end
                    end,
                }),
            }),
        }),
        page("experimental", "Experimental", "Opt in to features still being refined. These are off by default.", {
            section("Map rendering", {
                setting("enableExperimentalMaps", "Seamless maps", "Use stitched zone art and close-up minimap terrain in Alts and Global Map.", "check", {
                    set = function(v) addon:SetExperimentalMapsEnabled(v) end,
                    keywords = "experimental beta openmap free map terrain continent global map rendering",
                }),
            }),
        }),
    }
end
