local _, NS = ...
local GoldTracker = NS.GoldTracker

local BIND_ON_ACQUIRE = LE_ITEM_BIND_ON_ACQUIRE or (Enum and Enum.ItemBind and Enum.ItemBind.OnAcquire)
local BIND_QUEST = LE_ITEM_BIND_QUEST or (Enum and Enum.ItemBind and Enum.ItemBind.Quest)

local function IsSoulboundTooltipLine(text)
    if type(text) ~= "string" then
        return false
    end

    if ITEM_SOULBOUND and text == ITEM_SOULBOUND then
        return true
    end
    if ITEM_BIND_ON_PICKUP and text == ITEM_BIND_ON_PICKUP then
        return true
    end
    if ITEM_BIND_QUEST and text == ITEM_BIND_QUEST then
        return true
    end

    return false
end

local function BuildLocationLabel(session)
    if type(session) ~= "table" then
        return "Unknown"
    end

    local baseName
    if session.isInstanced == true then
        baseName = session.instanceName or session.zoneName or session.mapName
    else
        baseName = session.zoneName or session.mapName
    end
    if type(baseName) ~= "string" or baseName == "" then
        baseName = "Unknown"
    end

    local expansionName = session.expansionName
    if type(expansionName) == "string" and expansionName ~= "" then
        return string.format("%s (%s)", baseName, expansionName)
    end

    return baseName
end

local function ShouldDisplayLootSourceHint(addon, itemLink, itemQuality)
    local quality = tonumber(itemQuality)
    if quality then
        quality = math.floor(quality + 0.5)
    else
        quality = addon:GetItemQualityFromLink(itemLink)
    end

    if type(quality) == "number" and quality >= 2 then
        return true
    end

    return addon:IsCraftingReagentItem(itemLink)
end

function GoldTracker:GetCurrentSessionLootLocationData()
    local session = self.session or {}
    return {
        locationKey = session.locationKey,
        locationLabel = BuildLocationLabel(session),
        isInstanced = session.isInstanced == true,
        instanceName = session.instanceName,
        zoneName = session.zoneName,
        mapID = session.mapID,
        mapName = session.mapName,
        mapPath = session.mapPath,
        continentName = session.continentName,
        expansionID = session.expansionID,
        expansionName = session.expansionName,
    }
end

function GoldTracker:IsSoulboundLootItem(itemLink)
    if type(itemLink) ~= "string" then
        return false
    end

    local cacheKey = self:GetItemIDFromLink(itemLink) or itemLink
    if type(self.soulboundLootTypeCache) ~= "table" then
        self.soulboundLootTypeCache = {}
    else
        local cachedValue = self.soulboundLootTypeCache[cacheKey]
        if cachedValue ~= nil then
            return cachedValue == true
        end
    end

    local bindType
    if C_Item and C_Item.GetItemInfo then
        bindType = select(14, C_Item.GetItemInfo(itemLink))
    else
        bindType = select(14, GetItemInfo(itemLink))
    end

    if type(bindType) == "number" and ((BIND_ON_ACQUIRE and bindType == BIND_ON_ACQUIRE) or (BIND_QUEST and bindType == BIND_QUEST)) then
        self.soulboundLootTypeCache[cacheKey] = true
        return true
    end

    if C_TooltipInfo and C_TooltipInfo.GetHyperlink then
        local tooltipData = C_TooltipInfo.GetHyperlink(itemLink)
        if tooltipData then
            if TooltipUtil and TooltipUtil.SurfaceArgs then
                TooltipUtil.SurfaceArgs(tooltipData)
            end

            if type(tooltipData.lines) == "table" then
                for _, line in ipairs(tooltipData.lines) do
                    if IsSoulboundTooltipLine(line and (line.leftText or line.text)) then
                        self.soulboundLootTypeCache[cacheKey] = true
                        return true
                    end
                end
            end
        end
    end

    self.soulboundLootTypeCache[cacheKey] = false
    return false
end

function GoldTracker:GetVendorItemValue(itemLink)
    local vendorPrice = select(11, GetItemInfo(itemLink))
    if type(vendorPrice) == "number" and vendorPrice > 0 then
        return vendorPrice
    end
    return 0
end

function GoldTracker:GetTSMItemValue(priceSource, itemLink)
    if type(TSM_API) ~= "table" or type(TSM_API.GetCustomPriceValue) ~= "function" then
        if not self.tsmWarningShown then
            self.tsmWarningShown = true
            self:Print("TSM source selected but TradeSkillMaster API is unavailable. Returning 0 for item values.")
        end
        return 0
    end

    local itemString = self:GetTSMItemStringFromLink(itemLink)
    if not itemString then
        return 0
    end

    local ok, value = pcall(TSM_API.GetCustomPriceValue, priceSource, itemString)
    if ok and type(value) == "number" and value > 0 then
        self.tsmWarningShown = false
        return math.floor(value + 0.5)
    end

    return 0
end

function GoldTracker:GetItemUnitValue(itemLink)
    local function ResolveFromSource(source)
        if not source then
            return 0
        end
        if source.id == "VENDOR" then
            return self:GetVendorItemValue(itemLink)
        end
        if source.tsmKey then
            return self:GetTSMItemValue(source.tsmKey, itemLink)
        end
        return 0
    end

    local primarySource = self:GetCurrentValueSource()
    local primaryValue = ResolveFromSource(primarySource)
    if primaryValue > 0 then
        return primaryValue, primarySource.id, primarySource.label
    end

    local fallbackSource = self:GetFallbackValueSource()
    if fallbackSource then
        local fallbackValue = ResolveFromSource(fallbackSource)
        if fallbackValue > 0 then
            return fallbackValue, fallbackSource.id, fallbackSource.label
        end
    end

    return 0, primarySource.id, primarySource.label
end

function GoldTracker:NotifyHighValueItem(itemLink, quantity, totalValue)
    if not self.db.notificationsEnabled then
        return
    end

    local threshold = self:GetHighHighlightThreshold()
    if threshold <= 0 or totalValue <= threshold then
        return
    end

    local message = string.format("High value loot: %s x%d (%s)", itemLink, quantity, self:FormatMoney(totalValue))
    local raidWarningColor = ChatTypeInfo and ChatTypeInfo["RAID_WARNING"]
    if raidWarningColor then
        RaidNotice_AddMessage(RaidWarningFrame, message, raidWarningColor)
    else
        RaidNotice_AddMessage(RaidWarningFrame, message, { r = 1, g = 0.2, b = 0.2 })
    end

    if PlaySound and SOUNDKIT and SOUNDKIT.UI_EPICLOOT_TOAST then
        PlaySound(SOUNDKIT.UI_EPICLOOT_TOAST)
    end

    self:Print(message)
end

function GoldTracker:TrackLootMoney(amount)
    if amount <= 0 then
        return
    end

    self:UpdateSessionLocationContext()
    if type(self.session.moneyLoots) ~= "table" then
        self.session.moneyLoots = {}
    end
    local locationData = self:GetCurrentSessionLootLocationData()
    self.session.moneyLoots[#self.session.moneyLoots + 1] = {
        amount = amount,
        timestamp = time(),
        locationKey = locationData.locationKey,
        locationLabel = locationData.locationLabel,
        isInstanced = locationData.isInstanced,
        instanceName = locationData.instanceName,
        zoneName = locationData.zoneName,
        mapID = locationData.mapID,
        mapName = locationData.mapName,
        mapPath = locationData.mapPath,
        continentName = locationData.continentName,
        expansionID = locationData.expansionID,
        expansionName = locationData.expansionName,
    }
    self.session.goldLooted = self.session.goldLooted + amount
    if self.db and self.db.showRawLootedGoldInLog then
        self:AddLogMessage(string.format("%s  |cffffd100Raw looted gold|r +%s", date("%H:%M:%S"), self:FormatMoney(amount)), 1, 0.85, 0)
    end
    self:UpdateMainWindow()
end

function GoldTracker:TrackLootItem(itemLink, quantity, lootSourceInfo)
    if not itemLink then
        return
    end

    quantity = math.max(1, math.floor(tonumber(quantity) or 1))

    local selectedUnitValue, selectedValueSourceID, selectedValueSourceLabel = self:GetItemUnitValue(itemLink)
    local vendorUnitValue = self:GetVendorItemValue(itemLink)
    local itemQuality = self:GetItemQualityFromLink(itemLink)
    local shouldTrackForAH = self:ShouldTrackItemForAH(itemQuality)
    local isSoulboundLoot = false
    if shouldTrackForAH and selectedUnitValue > 0 then
        isSoulboundLoot = self:IsSoulboundLootItem(itemLink)
    end
    local lootSourceKind = lootSourceInfo and lootSourceInfo.kind or nil
    local lootSourceName = lootSourceInfo and lootSourceInfo.name or nil
    local lootSourceIsAoe = lootSourceInfo and lootSourceInfo.isAoe == true
    local lootSourceText = lootSourceInfo and lootSourceInfo.text or nil
    if (type(lootSourceText) ~= "string" or lootSourceText == "") and (lootSourceIsAoe or lootSourceKind == "AOE") then
        lootSourceText = "AOE loot"
    end
    if isSoulboundLoot or not shouldTrackForAH then
        selectedUnitValue = 0
    end
    local selectedTotalValue = math.max(0, math.floor((selectedUnitValue * quantity) + 0.5))
    local vendorTotalValue = math.max(0, math.floor((vendorUnitValue * quantity) + 0.5))
    local highlightThreshold = self:GetHighlightThreshold()

    self:UpdateSessionLocationContext()
    local locationData = self:GetCurrentSessionLootLocationData()
    self.session.itemValue = (self.session.itemValue or 0) + selectedTotalValue
    self.session.itemVendorValue = (self.session.itemVendorValue or 0) + vendorTotalValue
    if selectedTotalValue > 0 and selectedTotalValue >= highlightThreshold then
        self.session.highlightItemCount = (self.session.highlightItemCount or 0) + 1
    end
    -- Keep legacy counters synchronized for compatibility with previously saved sessions.
    self.session.lowHighlightItemCount = 0
    self.session.highHighlightItemCount = self.session.highlightItemCount or 0

    if type(self.session.itemLoots) ~= "table" then
        self.session.itemLoots = {}
    end
    self.session.itemLoots[#self.session.itemLoots + 1] = {
        itemLink = itemLink,
        quantity = quantity,
        unitValue = selectedUnitValue,
        totalValue = selectedTotalValue,
        vendorUnitValue = vendorUnitValue,
        vendorTotalValue = vendorTotalValue,
        itemQuality = itemQuality,
        isSoulbound = isSoulboundLoot,
        timestamp = time(),
        valueSourceID = selectedValueSourceID,
        valueSourceLabel = selectedValueSourceLabel,
        locationKey = locationData.locationKey,
        locationLabel = locationData.locationLabel,
        isInstanced = locationData.isInstanced,
        instanceName = locationData.instanceName,
        zoneName = locationData.zoneName,
        mapID = locationData.mapID,
        mapName = locationData.mapName,
        mapPath = locationData.mapPath,
        continentName = locationData.continentName,
        expansionID = locationData.expansionID,
        expansionName = locationData.expansionName,
        ahTracked = shouldTrackForAH == true,
        lootSourceType = lootSourceKind,
        lootSourceName = lootSourceName,
        lootSourceIsAoe = lootSourceIsAoe,
        lootSourceText = lootSourceText,
    }

    if shouldTrackForAH and not isSoulboundLoot then
        local sourceSuffix = ""
        if type(lootSourceText) == "string"
            and lootSourceText ~= ""
            and (lootSourceIsAoe or lootSourceKind == "AOE" or ShouldDisplayLootSourceHint(self, itemLink, itemQuality)) then
            sourceSuffix = string.format("  [From: %s]", lootSourceText)
        elseif lootSourceIsAoe then
            sourceSuffix = "  [From: AOE loot]"
        end

        self:AddLogMessage(
            string.format("%s  %s x%d  (%s)%s", date("%H:%M:%S"), itemLink, quantity, self:FormatMoney(selectedTotalValue), sourceSuffix),
            0.9,
            0.9,
            1
        )
    end

    self:NotifyHighValueItem(itemLink, quantity, selectedTotalValue)
    self:UpdateMainWindow()
end
