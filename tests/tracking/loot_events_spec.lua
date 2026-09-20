local loader = require("tests.helpers.addon_loader")

local ITEM_LINK = "|cff1eff00|Hitem:123::::::::|h[Test Item]|h|r"

local function load_loot_events(addon, globals)
    local parser = {
        IsUsableChatMessageText = function(_, message)
            return type(message) == "string"
        end,
        ExtractLootItemFromMessage = function(_, message)
            if message == "item" then
                return ITEM_LINK, 1
            end
            return nil, nil
        end,
        ExtractMoneyFromMessage = function(_, message)
            return message == "money" and 123 or 0
        end,
    }
    local source_service = {
        lootSourceNameCache = {},
        pendingLootSourceEntries = {},
        New = function(self)
            return self
        end,
        ClearPendingLootSourceEntries = function() end,
        CleanupLootSourceNameCache = function() end,
        RememberLootSourceName = function() end,
        GetLootSourceNameFromGUID = function() end,
        GetRecentGatherAction = function() end,
        BuildLootSourceInfoForSlot = function() end,
        BuildPendingLootSourceEntries = function() end,
        ConsumePendingLootSourceForItem = function() end,
        CleanupLootSourceNameCacheIfDue = function() end,
        MarkPendingLootSourceEntriesClosed = function() end,
        CaptureLootSourceNameFromUnit = function() end,
        IsSecretValue = function()
            return false
        end,
        RecordGatherActionForSpell = function()
            return false
        end,
    }

    return loader.with_globals(globals or {}, function()
        return loader.load_module("Tracking/LootEvents.lua", addon, {
            LootChatParser = {
                New = function()
                    return parser
                end,
            },
            LootSourceService = source_service,
        })
    end)
end

local function build_addon()
    local addon = {
        db = {
            autoStartSessionOnFirstLoot = true,
            ignoreMailboxLootWhenMailOpen = true,
        },
        session = {
            active = true,
        },
        counters = {},
        tracked_items = 0,
        tracked_money = 0,
    }

    function addon:IsIgnoreMailboxLootWhenMailOpenEnabled()
        return self.db.ignoreMailboxLootWhenMailOpen == true
    end

    function addon:IsLootSourceTrackingEnabled()
        return false
    end

    function addon:IncrementDiagnosticCounter(key, amount)
        self.counters[key] = (self.counters[key] or 0) + (amount or 1)
    end

    function addon:BeginDiagnosticTimer()
        return 0
    end

    function addon:EndDiagnosticTimer() end
    function addon:HandleSessionLocationTransition() end

    function addon:StartSession()
        self.session.active = true
    end

    function addon:TrackLootItem()
        self.tracked_items = self.tracked_items + 1
    end

    function addon:TrackLootMoney()
        self.tracked_money = self.tracked_money + 1
    end

    return addon
end

describe("Tracking/LootEvents", function()
    it("ignores loot chat while the mailbox is open", function()
        local addon = build_addon()
        load_loot_events(addon)

        loader.with_globals({ GetTimePreciseSec = function() return 10 end }, function()
            addon:OnMailShow()
            addon:OnChatMsgLoot("item")
        end)

        assert.equals(0, addon.tracked_items)
        assert.equals(1, addon.counters.loot_chat_ignored)
    end)

    it("keeps ignoring delayed mailbox loot briefly after the mail frame closes", function()
        local now = 10
        local addon = build_addon()
        load_loot_events(addon)

        loader.with_globals({ GetTimePreciseSec = function() return now end }, function()
            addon:OnMailShow()
            addon:OnMailClosed()
            now = 11
            addon:OnChatMsgLoot("item")
            now = 13
            addon:OnChatMsgLoot("item")
        end)

        assert.equals(1, addon.tracked_items)
        assert.equals(1, addon.counters.loot_chat_ignored)
    end)

    it("does not suppress mailbox-looking loot when the option is disabled", function()
        local addon = build_addon()
        addon.db.ignoreMailboxLootWhenMailOpen = false
        load_loot_events(addon)

        loader.with_globals({ GetTimePreciseSec = function() return 10 end }, function()
            addon:OnMailShow()
            addon:OnChatMsgLoot("item")
            addon:OnChatMsgMoney("money")
        end)

        assert.equals(1, addon.tracked_items)
        assert.equals(1, addon.tracked_money)
    end)
end)
