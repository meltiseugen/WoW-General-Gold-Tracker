local loader = require("tests.helpers.addon_loader")

local function load_alerts(addon, globals)
    addon.COPPER_PER_GOLD = addon.COPPER_PER_GOLD or 10000
    addon.DEFAULTS = addon.DEFAULTS or {
        notificationsEnabled = true,
        highlightThreshold = 100000,
    }
    return loader.with_globals(globals or {}, function()
        return loader.load_module("Core/Alerts.lua", addon)
    end)
end

describe("Core/Alerts rule management", function()
    it("normalizes alert settings by sorting rules and replacing invalid options", function()
        local addon = load_alerts({
            db = {
                notificationsEnabled = "yes",
                sessionMilestoneAlerts = {
                    { enabled = true, threshold = 50000, soundID = "NOPE", displayID = "BAD" },
                    { enabled = false, threshold = 10000, soundID = "READY_CHECK", displayID = "CENTER" },
                },
                highValueDropAlerts = "bad",
                noLootAlertMinutes = 999,
                noLootAlertSoundID = "BAD",
                noLootAlertDisplayID = "BAD",
            },
        })

        addon:NormalizeAlertSettings()

        assert.is_true(addon.db.notificationsEnabled)
        assert.equals(10000, addon.db.sessionMilestoneAlerts[1].threshold)
        assert.equals("READY_CHECK", addon.db.sessionMilestoneAlerts[1].soundID)
        assert.equals("EPICLOOT", addon.db.sessionMilestoneAlerts[2].soundID)
        assert.equals("CHAT_RAID", addon.db.sessionMilestoneAlerts[2].displayID)
        assert.equals(1, #addon.db.highValueDropAlerts)
        assert.equals(180, addon.db.noLootAlertMinutes)
        assert.equals("READY_CHECK", addon.db.noLootAlertSoundID)
        assert.equals("CHAT_CENTER", addon.db.noLootAlertDisplayID)
    end)

    it("adds, edits, and removes alert rules with gold-to-copper conversion", function()
        local addon = load_alerts({
            db = {
                notificationsEnabled = true,
                sessionMilestoneAlerts = {},
                highValueDropAlerts = {},
            },
        })

        assert.is_true(addon:AddAlertRule(addon.ALERT_RULE_LIST_KEYS.HIGH_VALUE_DROPS))
        assert.equals(500000, addon.db.highValueDropAlerts[1].threshold)
        assert.is_true(addon:SetAlertRuleThresholdGold(addon.ALERT_RULE_LIST_KEYS.HIGH_VALUE_DROPS, 1, "12.34"))
        assert.equals(123400, addon.db.highValueDropAlerts[1].threshold)
        assert.is_true(addon:SetAlertRuleSoundID(addon.ALERT_RULE_LIST_KEYS.HIGH_VALUE_DROPS, 1, "READY_CHECK"))
        assert.is_false(addon:SetAlertRuleDisplayID(addon.ALERT_RULE_LIST_KEYS.HIGH_VALUE_DROPS, 1, "INVALID"))
        assert.is_true(addon:RemoveAlertRule(addon.ALERT_RULE_LIST_KEYS.HIGH_VALUE_DROPS, 1))
        assert.equals(0, #addon.db.highValueDropAlerts)
    end)
end)

describe("Core/Alerts runtime behavior", function()
    it("fires each session milestone rule only once per session", function()
        local messages = {}
        local addon = load_alerts({
            db = {
                notificationsEnabled = true,
                sessionMilestoneAlerts = {
                    { enabled = true, threshold = 10000, soundID = "NONE", displayID = "CHAT" },
                },
            },
            session = {
                active = true,
                startTime = 100,
            },
            FormatMoney = function(_, value)
                return tostring(value)
            end,
        }, {
            time = function()
                return 200
            end,
        })
        addon.DispatchConfiguredAlert = function(_, message)
            messages[#messages + 1] = message
        end
        addon.Print = function() end

        loader.with_globals({
            time = function()
                return 200
            end,
        }, function()
            addon:ProcessSessionMilestoneAlerts(0, 10000)
            addon:ProcessSessionMilestoneAlerts(10000, 20000)
        end)

        assert.equals(1, #messages)
        assert.matches("Session milestone reached", messages[1])
    end)

    it("uses the highest matching high-value-drop rule", function()
        local dispatched
        local addon = load_alerts({
            db = {
                notificationsEnabled = true,
                highValueDropAlerts = {
                    { enabled = true, threshold = 10000, soundID = "NONE", displayID = "CHAT" },
                    { enabled = true, threshold = 50000, soundID = "NONE", displayID = "CENTER" },
                },
            },
            FormatMoney = function(_, value)
                return tostring(value)
            end,
        })
        addon.DispatchConfiguredAlert = function(_, message, display_id)
            dispatched = { message = message, displayID = display_id }
        end

        addon:ProcessHighValueDropAlerts("|Hitem:1::::::::|h[Test]|h", 2, 60000)

        assert.equals("CENTER", dispatched.displayID)
        assert.matches("x2", dispatched.message)
        assert.matches("60000", dispatched.message)
    end)

    it("tracks active duration in capped windows when loot activity is marked", function()
        local addon = load_alerts({
            db = {
                notificationsEnabled = true,
            },
            session = {
                active = true,
                startTime = 100,
                lastLootAt = 100,
                activeDurationSeconds = 0,
            },
        }, {
            time = function()
                return 300
            end,
        })

        addon:MarkSessionLootActivity(250)

        assert.equals(90, addon.session.activeDurationSeconds)
        assert.equals(250, addon.session.lastLootAt)
        assert.is_false(addon.alertRuntime.noLootTriggered)
    end)
end)
