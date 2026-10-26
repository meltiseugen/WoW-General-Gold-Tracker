local loader = require("tests.helpers.addon_loader")

local function load_session(addon, globals)
    return loader.with_globals(globals or {}, function()
        loader.load_module("Core/SessionFlow.lua", addon)
        return loader.load_module("Core/Session.lua", addon)
    end)
end

describe("Core/Session reload persistence", function()
    it("stores active sessions as sanitized pending reload snapshots", function()
        local addon = load_session({
            db = {},
            session = {
                active = true,
                startTime = 100,
                goldLooted = "50",
                itemValue = 200,
                sessionStyleFilter = "crafting",
                lowHighlightItemCount = 1,
                highHighlightItemCount = 2,
                itemLoots = {
                    {
                        itemLink = "|Hitem:1::::::::|h[Test]|h",
                        quantity = "2",
                        totalValue = "400",
                        valueSourceID = "TSM_DBMARKET",
                        mapID = "100",
                        mapX = "0.57",
                        mapY = "0.23",
                        coordinateSource = "retry",
                        coordinateCapturedAt = "1710000000",
                        coordinateRetryCount = "2",
                        ahTracked = nil,
                    },
                },
                moneyLoots = {
                    { amount = "25", timestamp = "110" },
                },
            },
            GetValueSourceLabel = function()
                return "Market Value"
            end,
        }, {
            time = function()
                return 999
            end,
        })

        loader.with_globals({
            time = function()
                return 999
            end,
        }, function()
            assert.is_true(addon:StorePendingReloadSession())
        end)

        local snapshot = addon.db.pendingReloadSession
        assert.equals(3, snapshot.highlightItemCount)
        assert.equals("crafting", snapshot.sessionStyleFilter)
        assert.equals(2, snapshot.itemLoots[1].quantity)
        assert.equals(400, snapshot.itemLoots[1].totalValue)
        assert.equals("Market Value", snapshot.itemLoots[1].valueSourceLabel)
        assert.is_true(snapshot.itemLoots[1].ahTracked)
        assert.equals(100, snapshot.itemLoots[1].mapID)
        assert.equals(0.57, snapshot.itemLoots[1].mapX)
        assert.equals(0.23, snapshot.itemLoots[1].mapY)
        assert.equals("retry", snapshot.itemLoots[1].coordinateSource)
        assert.equals(1710000000, snapshot.itemLoots[1].coordinateCapturedAt)
        assert.equals(2, snapshot.itemLoots[1].coordinateRetryCount)
        assert.equals(25, snapshot.moneyLoots[1].amount)
        assert.equals(999, snapshot.savedAt)
    end)

    it("restores pending reload sessions and clears the pending snapshot", function()
        local log_messages = {}
        local chat_messages = {}
        local addon = load_session({
            db = {
                pendingReloadSession = {
                    active = true,
                    startTime = 100,
                    goldLooted = 50,
                    itemValue = 200,
                    sessionStyleFilter = "armorWeapons",
                    highlightItemCount = 2,
                    itemLoots = { { itemLink = "|Hitem:1::::::::|h[Test]|h", timestamp = 150 } },
                    moneyLoots = { { amount = 10, timestamp = 175 } },
                    activeDurationSeconds = 33,
                },
            },
            session = {},
            IsResumeSessionAfterReloadEnabled = function()
                return true
            end,
            GetValueSourceLabel = function(_, _, label)
                return label or "Unknown"
            end,
            GetMostRecentSessionLootTimestamp = function()
                return 175
            end,
            EnsureAlertRuntimeState = function(self)
                self.alertRuntime = self.alertRuntime or {}
                return self.alertRuntime
            end,
            UpdateSessionLocationContext = function() end,
            AddLogMessage = function(_, message)
                log_messages[#log_messages + 1] = message
            end,
            Print = function(_, message, category)
                chat_messages[#chat_messages + 1] = { message, category }
            end,
            UpdateMainWindow = function() end,
        }, {
            time = function()
                return 200
            end,
            date = function()
                return "12:00:00"
            end,
        })

        loader.with_globals({
            time = function()
                return 200
            end,
            date = function()
                return "12:00:00"
            end,
        }, function()
            assert.is_true(addon:TryRestorePendingReloadSession())
            assert.same({ { "Session restored after reload.", "sessions" } }, chat_messages)
        end)

        assert.is_nil(addon.db.pendingReloadSession)
        assert.is_true(addon.session.active)
        assert.equals(100, addon.session.startTime)
        assert.equals(2, addon.session.highlightItemCount)
        assert.equals("armorWeapons", addon.session.sessionStyleFilter)
        assert.equals(175, addon.session.lastLootAt)
        assert.equals(33, addon.session.activeDurationSeconds)
        assert.equals(100, addon.alertRuntime.sessionStartTime)
        assert.equals(1, #log_messages)
    end)

    it("clears invalid or disabled pending reload sessions", function()
        local addon = load_session({
            db = {
                pendingReloadSession = { active = true, startTime = 100 },
            },
            IsResumeSessionAfterReloadEnabled = function()
                return false
            end,
        })

        assert.is_false(addon:TryRestorePendingReloadSession())
        assert.is_nil(addon.db.pendingReloadSession)
    end)
end)

describe("Core/Session logout farm cleanup", function()
    it("closes the active farm and clears all projections on logout", function()
        local stoppedFarmID
        local closeReason
        local projectionClearCount = 0
        local addon = load_session({
            db = {},
            session = { active = false },
            IsResumeSessionAfterReloadEnabled = function() return true end,
            GetActiveCustomFarmRoutePlan = function()
                return { farm = { id = 42 } }
            end,
            StopCustomFarmRoutePlan = function(_, farmID, reason)
                stoppedFarmID = farmID
                closeReason = reason
            end,
            ClearWorldMapProjection = function()
                projectionClearCount = projectionClearCount + 1
            end,
        }, {
            IsReloadingUI = function() return false end,
        })

        loader.with_globals({ IsReloadingUI = function() return false end }, function()
            addon:HandlePlayerLogout()
        end)

        assert.equals(42, stoppedFarmID)
        assert.equals("logout", closeReason)
        assert.equals(1, projectionClearCount)
    end)
end)
