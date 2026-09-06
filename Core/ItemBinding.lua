local _, NS = ...
local GoldTracker = NS.GoldTracker

local BIND_ON_ACQUIRE = LE_ITEM_BIND_ON_ACQUIRE or (Enum and Enum.ItemBind and Enum.ItemBind.OnAcquire)
local BIND_QUEST = LE_ITEM_BIND_QUEST or (Enum and Enum.ItemBind and Enum.ItemBind.Quest)
local RESTRICTED_BINDING_TOOLTIP_LINES = {
    ITEM_SOULBOUND,
    ITEM_BIND_ON_PICKUP,
    ITEM_BIND_QUEST,
    ITEM_BIND_TO_BNETACCOUNT,
    ITEM_BNETACCOUNTBOUND,
    ITEM_BIND_TO_ACCOUNT,
    ITEM_ACCOUNTBOUND,
    ITEM_ACCOUNTBOUND_UNTIL_EQUIP,
    ITEM_BIND_TO_ACCOUNT_UNTIL_EQUIP,
}
local RESTRICTED_BINDING_KEYWORDS = {
    "consume on pick-up",
    "consume on pickup",
    "warbound",
}

local function SurfaceTooltipData(tooltipData)
    if type(tooltipData) ~= "table" then
        return nil
    end

    if TooltipUtil and TooltipUtil.SurfaceArgs then
        TooltipUtil.SurfaceArgs(tooltipData)
    end

    return tooltipData
end

function GoldTracker:IsRestrictedBindingTooltipLine(text)
    if type(text) ~= "string" or text == "" then
        return false
    end

    for _, bindingText in ipairs(RESTRICTED_BINDING_TOOLTIP_LINES) do
        if bindingText and text == bindingText then
            return true
        end
    end

    local normalizedText = string.lower(text)
    for _, keyword in ipairs(RESTRICTED_BINDING_KEYWORDS) do
        if string.find(normalizedText, keyword, 1, true) then
            return true
        end
    end

    if string.find(normalizedText, "warband", 1, true)
        and (
            string.find(normalizedText, "bind", 1, true)
            or string.find(normalizedText, "bound", 1, true)
        ) then
        return true
    end

    return false
end

function GoldTracker:GetTooltipBindingState(tooltipData)
    local surfaced = SurfaceTooltipData(tooltipData)
    if type(surfaced) ~= "table" or type(surfaced.lines) ~= "table" then
        return false, false
    end

    local sawTooltipTextLine = false
    for _, line in ipairs(surfaced.lines) do
        local leftText = line and line.leftText or nil
        local rightText = line and line.rightText or nil
        local lineText = line and line.text or nil

        if (type(leftText) == "string" and leftText ~= "")
            or (type(rightText) == "string" and rightText ~= "")
            or (type(lineText) == "string" and lineText ~= "") then
            sawTooltipTextLine = true
        end

        if self:IsRestrictedBindingTooltipLine(leftText)
            or self:IsRestrictedBindingTooltipLine(rightText)
            or self:IsRestrictedBindingTooltipLine(lineText) then
            return true, true
        end
    end

    return sawTooltipTextLine, false
end

function GoldTracker:IsLootItemBindingRestricted(itemLink)
    if type(itemLink) ~= "string" or itemLink == "" then
        return false
    end

    local cacheKey = self:GetItemIDFromLink(itemLink) or itemLink
    if type(self.lootItemBindingRestrictionCache) ~= "table" then
        self.lootItemBindingRestrictionCache = {}
    else
        local cachedValue = self.lootItemBindingRestrictionCache[cacheKey]
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

    if type(bindType) == "number" then
        local isRestricted =
            ((BIND_ON_ACQUIRE and bindType == BIND_ON_ACQUIRE) or (BIND_QUEST and bindType == BIND_QUEST))
        if isRestricted then
            self.lootItemBindingRestrictionCache[cacheKey] = true
            return true
        end
    end

    if C_TooltipInfo and C_TooltipInfo.GetHyperlink then
        local sawTextLine, isRestricted = self:GetTooltipBindingState(C_TooltipInfo.GetHyperlink(itemLink))
        if isRestricted then
            self.lootItemBindingRestrictionCache[cacheKey] = true
            return true
        end
        if sawTextLine then
            self.lootItemBindingRestrictionCache[cacheKey] = false
        end
    end

    return false
end

function GoldTracker:IsBagItemBindingRestricted(bagID, slotIndex, itemLink, slotInfo)
    if type(slotInfo) == "table" and slotInfo.isBound == true then
        return true
    end

    if C_TooltipInfo and type(C_TooltipInfo.GetBagItem) == "function" then
        local ok, tooltipData = pcall(C_TooltipInfo.GetBagItem, bagID, slotIndex)
        if ok then
            local _, isRestricted = self:GetTooltipBindingState(tooltipData)
            if isRestricted then
                return true
            end
        end
    end

    return self:IsLootItemBindingRestricted(itemLink)
end

function GoldTracker:IsSoulboundLootItem(itemLink)
    return self:IsLootItemBindingRestricted(itemLink)
end
