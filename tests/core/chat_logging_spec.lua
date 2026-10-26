local loader = require("tests.helpers.addon_loader")

local function with_logging(saved, callback)
    local messages, fallback = {}, {}
    loader.with_globals({
        WoWGeneralGoldTrackerDB = saved,
        DEFAULT_CHAT_FRAME = { AddMessage = function(_, text) messages[#messages + 1] = text end },
        print = function(text) fallback[#fallback + 1] = text end,
        date = function() return "14:32:08" end,
    }, function()
        local addon = loader.load_module("Core/Namespace.lua", {})
        addon:InitializeDatabase()
        callback(addon, messages, fallback)
    end)
end

describe("categorized chat output", function()
    it("preserves saved switches and fills invalid or missing preferences without touching history", function()
        local saved = {
            enableChatLogging = false, chatLogSessions = false, chatLogNavigation = true,
            chatLogWarnings = "false", chatLogTimestamps = "true", history = { { name = "keep" } },
        }
        with_logging(saved, function(addon)
            assert.is_false(addon.db.enableChatLogging)
            assert.is_false(addon.db.chatLogSessions)
            assert.is_true(addon.db.chatLogNavigation)
            assert.is_true(addon.db.chatLogWarnings)
            assert.is_false(addon.db.chatLogTimestamps)
            assert.equals("keep", addon.db.history[1].name)
            addon.db.chatLogStartup = true
        end)
        with_logging(saved, function(addon)
            assert.is_false(addon.db.enableChatLogging)
            assert.is_false(addon.db.chatLogSessions)
            assert.is_true(addon.db.chatLogStartup)
        end)
    end)

    it("filters every category independently and lets the master silence all output", function()
        with_logging({}, function(addon, messages, fallback)
            for _, category in ipairs(addon.CHAT_LOG_CATEGORIES) do
                for _, other in ipairs(addon.CHAT_LOG_CATEGORIES) do addon.db[other.key] = false end
                addon.db[category.key] = true
                local before = #messages
                assert.is_true(addon:Print("allowed", category.id))
                assert.equals(before + 1, #messages)
                assert.is_truthy(messages[#messages]:find("[" .. category.label .. "]", 1, true))
                addon.db[category.key] = false
                assert.is_false(addon:Print("hidden", category.id))
                assert.equals(before + 1, #messages)
            end
            addon.db.enableChatLogging = false
            local before = #messages
            for _, category in ipairs(addon.CHAT_LOG_CATEGORIES) do
                addon.db[category.key] = true
                assert.is_false(addon:Print("hidden", category.id))
            end
            assert.is_false(addon:Print("hidden", "test"))
            assert.equals(before, #messages)
            assert.equals(0, #fallback)
        end)
    end)

    it("keeps legacy callers filtered and preserves item links with optional timestamps", function()
        with_logging({}, function(addon, messages)
            addon.db.chatLogCommands = false
            assert.is_false(addon:Print("legacy reply"))
            assert.is_false(addon:Print("unknown category", "unknown"))
            assert.is_true(addon:Print("test still works", "test"))
            assert.is_nil(messages[1]:find("14:32:08", 1, true))
            addon.db.chatLogTimestamps = true
            local link = "|cff0070dd|Hitem:123::::::::|h[Test Item]|h|r"
            addon:Print(link, "sessions")
            assert.matches("^14:32:08 ", messages[2])
            assert.is_truthy(messages[2]:find(link, 1, true))
        end)
    end)

    it("honors saved preferences before initialization and filters console fallback", function()
        with_logging({ enableChatLogging = false }, function(addon, messages, fallback)
            addon.db = nil
            assert.is_false(addon:Print("unsupported client", "warnings"))
            assert.equals(0, #messages)
            WoWGeneralGoldTrackerDB.enableChatLogging = true
            loader.with_globals({ DEFAULT_CHAT_FRAME = false }, function()
                assert.is_true(addon:Print("fallback", "warnings"))
                assert.equals(1, #fallback)
                WoWGeneralGoldTrackerDB.chatLogWarnings = false
                assert.is_false(addon:Print("hidden fallback", "warnings"))
                assert.equals(1, #fallback)
            end)
        end)
    end)

    it("silences only the chat copy of alerts while retaining sounds and other destinations", function()
        with_logging({}, function(addon, messages)
            loader.load_module("Core/Alerts.lua", addon)
            local sounds, center, raid, logs = 0, 0, 0, 0
            addon.PlayConfiguredAlertSound = function() sounds = sounds + 1 end
            addon.AddLogMessage = function() logs = logs + 1 end
            loader.with_globals({
                UIErrorsFrame = { AddMessage = function() center = center + 1 end },
                RaidWarningFrame = {},
                RaidNotice_AddMessage = function() raid = raid + 1 end,
            }, function()
                addon.db.chatLogAlerts = false
                addon:DispatchConfiguredAlert("milestone", "ALL", "NONE")
                assert.equals(0, #messages)
                assert.same({ 1, 1, 1, 1 }, { sounds, center, raid, logs })
                addon.db.chatLogAlerts = true
                addon.db.enableChatLogging = false
                addon:DispatchConfiguredAlert("drop", "ALL", "NONE")
                assert.equals(0, #messages)
                assert.same({ 2, 2, 2, 2 }, { sounds, center, raid, logs })
                addon.db.enableChatLogging = true
                addon:DispatchConfiguredAlert("test", "ALL", "NONE")
                assert.equals(1, #messages)
                assert.matches("%[Alerts%]", messages[1])
            end)
        end)
    end)
end)
