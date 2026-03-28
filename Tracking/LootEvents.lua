local _, NS = ...
local GoldTracker = NS.GoldTracker
local LootChatParser = NS.LootChatParser
local LootSourceService = NS.LootSourceService

local lootChatParser = LootChatParser:New(GoldTracker)
local lootSourceService = LootSourceService:New(GoldTracker)

local function SyncLegacyLootState(addon)
    addon.lootSourceNameCache = lootSourceService.lootSourceNameCache
    addon.lootSourceNameCacheNextCleanupAt = lootSourceService.lootSourceNameCacheNextCleanupAt
    addon.pendingLootSourceEntries = lootSourceService.pendingLootSourceEntries
    addon.pendingLootFallbackSourceInfo = lootSourceService.pendingLootFallbackSourceInfo
    addon.lastGatherAction = lootSourceService.lastGatherAction
end

SyncLegacyLootState(GoldTracker)

function GoldTracker:CleanupLootSourceNameCache()
    if not self:IsLootSourceTrackingEnabled() then
        lootSourceService:ClearPendingLootSourceEntries()
        SyncLegacyLootState(self)
        return
    end
    lootSourceService:CleanupLootSourceNameCache()
    SyncLegacyLootState(self)
end

function GoldTracker:RememberLootSourceName(guid, name)
    if not self:IsLootSourceTrackingEnabled() then
        return
    end
    lootSourceService:RememberLootSourceName(guid, name)
    SyncLegacyLootState(self)
end

function GoldTracker:GetLootSourceNameFromGUID(guid, allowUnitTokenScan)
    if not self:IsLootSourceTrackingEnabled() then
        return nil
    end
    return lootSourceService:GetLootSourceNameFromGUID(guid, allowUnitTokenScan)
end

function GoldTracker:GetRecentGatherAction()
    if not self:IsLootSourceTrackingEnabled() then
        return nil
    end
    return lootSourceService:GetRecentGatherAction()
end

function GoldTracker:BuildLootSourceInfoForSlot(slotIndex, sourceArgsOverride)
    if not self:IsLootSourceTrackingEnabled() then
        return nil
    end
    return lootSourceService:BuildLootSourceInfoForSlot(slotIndex, sourceArgsOverride)
end

function GoldTracker:BuildPendingLootSourceEntries()
    if not self:IsLootSourceTrackingEnabled() then
        lootSourceService:ClearPendingLootSourceEntries()
        SyncLegacyLootState(self)
        return
    end
    lootSourceService:BuildPendingLootSourceEntries()
    SyncLegacyLootState(self)
end

function GoldTracker:ConsumePendingLootSourceForItem(itemLink, quantity)
    if not self:IsLootSourceTrackingEnabled() then
        return nil
    end
    local sourceInfo = lootSourceService:ConsumePendingLootSourceForItem(itemLink, quantity)
    SyncLegacyLootState(self)
    return sourceInfo
end

function GoldTracker:IsUsableChatMessageText(message)
    return lootChatParser:IsUsableChatMessageText(message)
end

function GoldTracker:ExtractLootItemFromMessage(message)
    return lootChatParser:ExtractLootItemFromMessage(message)
end

function GoldTracker:ShouldAutoStartSessionOnLoot()
    if not self.db or not self.db.autoStartSessionOnFirstLoot then
        return false
    end
    if not self.mainFrame or not self.mainFrame:IsShown() then
        return false
    end
    return true
end

function GoldTracker:IsMailWindowOpen()
    return MailFrame and MailFrame.IsShown and MailFrame:IsShown()
end

function GoldTracker:ShouldIgnoreMailboxLoot()
    if not self:IsIgnoreMailboxLootWhenMailOpenEnabled() then
        return false
    end
    return self:IsMailWindowOpen()
end

function GoldTracker:EnsureSessionForTrackedLoot()
    if self.session.active then
        return true
    end

    if not self:ShouldAutoStartSessionOnLoot() then
        self:IncrementDiagnosticCounter("session_ensure_failed")
        return false
    end

    self:StartSession()
    return self.session.active
end

function GoldTracker:OnChatMsgLoot(message, playerName, _, _, _, _, _, _, _, _, _, playerGUID)
    self:IncrementDiagnosticCounter("loot_chat_seen")
    local hasActiveSession = self.session and self.session.active
    if not hasActiveSession and not self:ShouldAutoStartSessionOnLoot() then
        self:IncrementDiagnosticCounter("loot_chat_ignored")
        return
    end

    if self:ShouldIgnoreMailboxLoot() then
        self:IncrementDiagnosticCounter("loot_chat_ignored")
        return
    end

    if not self:IsUsableChatMessageText(message) then
        self:IncrementDiagnosticCounter("loot_chat_ignored")
        return
    end

    if self.session and self.session.active then
        self:HandleSessionLocationTransition()
    end

    local parseStart = self:BeginDiagnosticTimer()
    local itemLink, quantity = self:ExtractLootItemFromMessage(message)
    self:EndDiagnosticTimer("parse_loot_chat", parseStart)
    if itemLink then
        if not string.find(itemLink, "|Hitem:", 1, true) and not string.find(itemLink, "|Hbattlepet:", 1, true) then
            self:IncrementDiagnosticCounter("loot_chat_ignored")
            return
        end

        if not self:EnsureSessionForTrackedLoot() then
            return
        end

        self:IncrementDiagnosticCounter("loot_chat_item_matches")
        local lootSourceInfo = self:ConsumePendingLootSourceForItem(itemLink, quantity)
        self:TrackLootItem(itemLink, quantity, lootSourceInfo)
        return
    end

    local amount = self:ExtractMoneyFromMessage(message)
    if not amount or amount <= 0 then
        self:IncrementDiagnosticCounter("loot_chat_ignored")
        return
    end

    if not self:EnsureSessionForTrackedLoot() then
        return
    end

    self:IncrementDiagnosticCounter("loot_chat_money_matches")
    self:TryTrackMoneyAmount(amount)
end

function GoldTracker:ExtractMoneyFromMessage(message)
    return lootChatParser:ExtractMoneyFromMessage(message)
end

function GoldTracker:TryTrackMoneyAmount(amount)
    if not amount or amount <= 0 then
        return false
    end

    local now = (GetTimePreciseSec and GetTimePreciseSec()) or GetTime()
    if self.lastTrackedMoneyAmount == amount
        and self.lastTrackedMoneyAt
        and (now - self.lastTrackedMoneyAt) <= 0.05 then
        return true
    end

    self.lastTrackedMoneyAmount = amount
    self.lastTrackedMoneyAt = now
    self:TrackLootMoney(amount)
    return true
end

function GoldTracker:OnChatMsgMoney(message)
    self:IncrementDiagnosticCounter("money_chat_seen")
    local hasActiveSession = self.session and self.session.active
    if not hasActiveSession and not self:ShouldAutoStartSessionOnLoot() then
        self:IncrementDiagnosticCounter("money_chat_ignored")
        return
    end

    if self:ShouldIgnoreMailboxLoot() then
        self:IncrementDiagnosticCounter("money_chat_ignored")
        return
    end

    if not self:IsUsableChatMessageText(message) then
        self:IncrementDiagnosticCounter("money_chat_ignored")
        return
    end

    if self.session and self.session.active then
        self:HandleSessionLocationTransition()
    end

    local parseStart = self:BeginDiagnosticTimer()
    local amount = self:ExtractMoneyFromMessage(message)
    self:EndDiagnosticTimer("parse_money_chat", parseStart)
    if not amount or amount <= 0 then
        self:IncrementDiagnosticCounter("money_chat_ignored")
        return
    end

    if not self:EnsureSessionForTrackedLoot() then
        return
    end

    self:IncrementDiagnosticCounter("money_chat_amount_matches")
    self:TryTrackMoneyAmount(amount)
end

function GoldTracker:OnUnitSpellcastSucceeded(unitTarget, _, spellID)
    if not self:IsLootSourceTrackingEnabled() then
        return
    end
    if lootSourceService:IsSecretValue(unitTarget) then
        return
    end
    if unitTarget ~= "player" then
        return
    end

    local captured = lootSourceService:RecordGatherActionForSpell(spellID)
    if captured then
        SyncLegacyLootState(self)
    end
end

function GoldTracker:OnLootOpened()
    if not self:IsLootSourceTrackingEnabled() then
        lootSourceService:ClearPendingLootSourceEntries()
        SyncLegacyLootState(self)
        return
    end
    local buildStart = self:BeginDiagnosticTimer()
    lootSourceService:BuildPendingLootSourceEntries()
    self:EndDiagnosticTimer("loot_source_build_pending", buildStart)
    lootSourceService:CleanupLootSourceNameCacheIfDue(60)
    SyncLegacyLootState(self)
end

function GoldTracker:OnLootClosed()
    lootSourceService:MarkPendingLootSourceEntriesClosed()
    SyncLegacyLootState(self)
end

function GoldTracker:CaptureLootSourceNameFromUnit(unitToken)
    if not self:IsLootSourceTrackingEnabled() then
        return
    end
    lootSourceService:CaptureLootSourceNameFromUnit(unitToken)
    SyncLegacyLootState(self)
end

function GoldTracker:OnPlayerTargetChanged()
    self:CaptureLootSourceNameFromUnit("target")
end

function GoldTracker:OnUpdateMouseoverUnit()
    self:CaptureLootSourceNameFromUnit("mouseover")
end

function GoldTracker:OnNamePlateUnitAdded(unitToken)
    self:CaptureLootSourceNameFromUnit(unitToken)
end

function GoldTracker:OnPlayerFocusChanged()
    self:CaptureLootSourceNameFromUnit("focus")
end

function GoldTracker:OnCombatLogEventUnfiltered()
    -- No longer registered. Kept as a no-op for compatibility with existing references.
    if not self:IsLootSourceTrackingEnabled() then
        return
    end
    lootSourceService:CleanupLootSourceNameCacheIfDue(60)
    SyncLegacyLootState(self)
end
