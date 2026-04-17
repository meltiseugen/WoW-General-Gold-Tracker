local _, NS = ...
local GoldTracker = NS.GoldTracker
local Theme = NS.GoldTrackerTheme

local INVENTORY_ROW_HEIGHT = 24
local INVENTORY_ROW_SPACING = 2
local INVENTORY_ICON_SIZE = 18
local INVENTORY_QUANTITY_WIDTH = 56
local INVENTORY_UNIT_VALUE_WIDTH = 116
local INVENTORY_TOTAL_VALUE_WIDTH = 126

local BOUND_TOOLTIP_LINES = {
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
local BOUND_TOOLTIP_KEYWORDS = {
    "warband",
    "warbound",
}

local function CreateInventoryPanel(parent, bg, border)
    return Theme:CreatePanel(parent, bg, border)
end

local function CreateInventoryButton(parent, width, height, text, paletteKey)
    return Theme:CreateButton(parent, width, height, text, paletteKey)
end

local function IsBoundTooltipLine(text)
    if type(text) ~= "string" or text == "" then
        return false
    end

    for _, bindingText in pairs(BOUND_TOOLTIP_LINES) do
        if bindingText and text == bindingText then
            return true
        end
    end

    local normalizedText = string.lower(text)
    for _, keyword in ipairs(BOUND_TOOLTIP_KEYWORDS) do
        if string.find(normalizedText, keyword, 1, true) then
            return true
        end
    end

    return false
end

local function TooltipDataHasBoundLine(tooltipData)
    if type(tooltipData) ~= "table" then
        return false
    end

    if TooltipUtil and TooltipUtil.SurfaceArgs then
        TooltipUtil.SurfaceArgs(tooltipData)
    end

    if type(tooltipData.lines) ~= "table" then
        return false
    end

    for _, line in ipairs(tooltipData.lines) do
        if line
            and (IsBoundTooltipLine(line.leftText)
                or IsBoundTooltipLine(line.rightText)
                or IsBoundTooltipLine(line.text)) then
            return true
        end
    end

    return false
end

local function IsContainerItemBoundOrWarbound(bagID, slotIndex, itemLink, slotInfo)
    if type(slotInfo) == "table" and slotInfo.isBound == true then
        return true
    end

    if C_TooltipInfo and type(C_TooltipInfo.GetBagItem) == "function" then
        local ok, tooltipData = pcall(C_TooltipInfo.GetBagItem, bagID, slotIndex)
        if ok and TooltipDataHasBoundLine(tooltipData) then
            return true
        end
    end

    if C_TooltipInfo and type(C_TooltipInfo.GetHyperlink) == "function" and type(itemLink) == "string" then
        local ok, tooltipData = pcall(C_TooltipInfo.GetHyperlink, itemLink)
        if ok and TooltipDataHasBoundLine(tooltipData) then
            return true
        end
    end

    return false
end

local function AddBagID(bagIDs, seenBagIDs, bagID)
    local normalizedBagID = tonumber(bagID)
    if not normalizedBagID or seenBagIDs[normalizedBagID] then
        return
    end

    seenBagIDs[normalizedBagID] = true
    bagIDs[#bagIDs + 1] = normalizedBagID
end

local function BuildInventoryBagIDs()
    local bagIDs = {}
    local seenBagIDs = {}
    local firstBagID = BACKPACK_CONTAINER or 0
    local lastBagID = NUM_BAG_SLOTS or 4

    for bagID = firstBagID, lastBagID do
        AddBagID(bagIDs, seenBagIDs, bagID)
    end

    if Enum and Enum.BagIndex then
        AddBagID(bagIDs, seenBagIDs, Enum.BagIndex.ReagentBag)
    end
    AddBagID(bagIDs, seenBagIDs, REAGENTBAG_CONTAINER)

    table.sort(bagIDs)
    return bagIDs
end

local function GetContainerSlotCount(bagID)
    if C_Container and type(C_Container.GetContainerNumSlots) == "function" then
        return tonumber(C_Container.GetContainerNumSlots(bagID)) or 0
    end
    if type(GetContainerNumSlots) == "function" then
        return tonumber(GetContainerNumSlots(bagID)) or 0
    end
    return 0
end

local function GetContainerSlotInfo(bagID, slotIndex)
    if C_Container and type(C_Container.GetContainerItemInfo) == "function" then
        local info = C_Container.GetContainerItemInfo(bagID, slotIndex)
        if type(info) == "table" then
            return info
        end

        local iconFileID, stackCount, isLocked, quality, isReadable, hasLoot, hyperlink, isFiltered, hasNoValue, itemID, isBound =
            C_Container.GetContainerItemInfo(bagID, slotIndex)
        return {
            iconFileID = iconFileID,
            stackCount = stackCount,
            isLocked = isLocked,
            quality = quality,
            isReadable = isReadable,
            hasLoot = hasLoot,
            hyperlink = hyperlink,
            isFiltered = isFiltered,
            hasNoValue = hasNoValue,
            itemID = itemID,
            isBound = isBound,
        }
    end

    if type(GetContainerItemInfo) == "function" then
        local iconFileID, stackCount, isLocked, quality, isReadable, hasLoot, hyperlink, isFiltered, hasNoValue, itemID, isBound =
            GetContainerItemInfo(bagID, slotIndex)
        return {
            iconFileID = iconFileID,
            stackCount = stackCount,
            isLocked = isLocked,
            quality = quality,
            isReadable = isReadable,
            hasLoot = hasLoot,
            hyperlink = hyperlink,
            isFiltered = isFiltered,
            hasNoValue = hasNoValue,
            itemID = itemID,
            isBound = isBound,
        }
    end

    return nil
end

local function GetContainerSlotLink(bagID, slotIndex, slotInfo)
    if type(slotInfo) == "table" and type(slotInfo.hyperlink) == "string" and slotInfo.hyperlink ~= "" then
        return slotInfo.hyperlink
    end
    if C_Container and type(C_Container.GetContainerItemLink) == "function" then
        return C_Container.GetContainerItemLink(bagID, slotIndex)
    end
    if type(GetContainerItemLink) == "function" then
        return GetContainerItemLink(bagID, slotIndex)
    end
    return nil
end

local function GetItemDisplayData(itemLink, slotInfo)
    local itemName, itemQuality, itemIcon
    if C_Item and type(C_Item.GetItemInfo) == "function" then
        itemName, _, itemQuality, _, _, _, _, _, _, itemIcon = C_Item.GetItemInfo(itemLink)
    elseif type(GetItemInfo) == "function" then
        itemName, _, itemQuality, _, _, _, _, _, _, itemIcon = GetItemInfo(itemLink)
    end

    if not itemIcon and type(slotInfo) == "table" then
        itemIcon = slotInfo.iconFileID
    end

    if not itemIcon and type(GetItemInfoInstant) == "function" then
        itemIcon = select(5, GetItemInfoInstant(itemLink))
    end

    return itemName, itemQuality, itemIcon
end

local function NormalizeMinimumQuality(addon, minimumQuality)
    local normalizedQuality = tonumber(minimumQuality)
    if normalizedQuality then
        normalizedQuality = math.floor(normalizedQuality + 0.5)
    end
    if addon.TRACKED_ITEM_QUALITY_BY_ID[normalizedQuality] then
        return normalizedQuality
    end
    return addon:GetConfiguredMinimumTrackedItemQuality()
end

local function ItemPassesMinimumQuality(itemQuality, minimumQuality)
    local normalizedQuality = tonumber(itemQuality)
    if not normalizedQuality then
        return true
    end
    return math.floor(normalizedQuality + 0.5) >= minimumQuality
end

local function ReadMinimumValueCopper(addon, editBox)
    local rawText = editBox and editBox:GetText() or ""
    rawText = tostring(rawText or ""):gsub(",", ".")
    local goldValue = tonumber(rawText)
    if not goldValue or goldValue < 0 then
        goldValue = 0
    end
    return math.max(0, math.floor((goldValue * addon.COPPER_PER_GOLD) + 0.5))
end

local function FormatGoldInput(addon, copperValue)
    local normalizedCopper = math.max(0, math.floor(tonumber(copperValue) or 0))
    if normalizedCopper % addon.COPPER_PER_GOLD == 0 then
        return tostring(normalizedCopper / addon.COPPER_PER_GOLD)
    end
    return string.format("%.2f", normalizedCopper / addon.COPPER_PER_GOLD)
end

local function ResolveInventoryWindowSource(addon, frame)
    local source = addon.VALUE_SOURCE_BY_ID[frame and frame.valueSourceID]
    if source then
        return source
    end
    return addon:GetCurrentValueSource()
end

local function AddInventoryItem(itemsByLink, itemOrder, item)
    local existingItem = itemsByLink[item.itemLink]
    if existingItem then
        existingItem.quantity = existingItem.quantity + item.quantity
        existingItem.totalValue = existingItem.totalValue + item.totalValue
        existingItem.stackCount = existingItem.stackCount + 1
        return
    end

    itemsByLink[item.itemLink] = item
    itemOrder[#itemOrder + 1] = item
end

function GoldTracker:BuildInventoryAuctionItemList(valueSourceID, minimumQuality, minimumValueCopper)
    local source = self.VALUE_SOURCE_BY_ID[valueSourceID] or self:GetCurrentValueSource()
    local sourceID = source and source.id
    local normalizedMinimumQuality = NormalizeMinimumQuality(self, minimumQuality)
    local normalizedMinimumValue = math.max(0, math.floor(tonumber(minimumValueCopper) or 0))
    local itemsByLink = {}
    local candidateItems = {}
    local scannedStacks = 0
    local matchedStacks = 0
    local totalValue = 0
    local totalQuantity = 0

    for _, bagID in ipairs(BuildInventoryBagIDs()) do
        local slotCount = GetContainerSlotCount(bagID)
        for slotIndex = 1, slotCount do
            local slotInfo = GetContainerSlotInfo(bagID, slotIndex)
            local itemLink = GetContainerSlotLink(bagID, slotIndex, slotInfo)
            if type(itemLink) == "string" and itemLink ~= "" then
                scannedStacks = scannedStacks + 1

                if not IsContainerItemBoundOrWarbound(bagID, slotIndex, itemLink, slotInfo) then
                    local itemName, infoQuality, itemIcon = GetItemDisplayData(itemLink, slotInfo)
                    local itemQuality = tonumber(slotInfo and slotInfo.quality) or tonumber(infoQuality) or self:GetItemQualityFromLink(itemLink)
                    if ItemPassesMinimumQuality(itemQuality, normalizedMinimumQuality) then
                        local unitValue = self:GetItemUnitValueFromSource(sourceID, itemLink)
                        local quantity = math.max(1, math.floor(tonumber(slotInfo and slotInfo.stackCount) or 1))
                        local stackValue = math.max(0, math.floor((unitValue * quantity) + 0.5))
                        if unitValue > 0 then
                            AddInventoryItem(itemsByLink, candidateItems, {
                                itemLink = itemLink,
                                itemName = itemName or itemLink,
                                itemQuality = itemQuality,
                                icon = itemIcon,
                                quantity = quantity,
                                unitValue = unitValue,
                                totalValue = stackValue,
                                stackCount = 1,
                            })
                        end
                    end
                end
            end
        end
    end

    local items = {}
    for _, item in ipairs(candidateItems) do
        if item.totalValue > normalizedMinimumValue then
            matchedStacks = matchedStacks + item.stackCount
            totalValue = totalValue + item.totalValue
            totalQuantity = totalQuantity + item.quantity
            items[#items + 1] = item
        end
    end

    table.sort(items, function(left, right)
        if left.totalValue ~= right.totalValue then
            return left.totalValue > right.totalValue
        end
        return tostring(left.itemName or left.itemLink) < tostring(right.itemName or right.itemLink)
    end)

    return items, totalValue, totalQuantity, scannedStacks, matchedStacks
end

function GoldTracker:RefreshInventoryWindowControls()
    local frame = self.inventoryFrame
    if not frame then
        return
    end

    local source = ResolveInventoryWindowSource(self, frame)
    frame.valueSourceID = source.id
    UIDropDownMenu_SetSelectedValue(frame.valueSourceDropdown, source.id)
    UIDropDownMenu_SetText(frame.valueSourceDropdown, source.label)

    frame.minimumQuality = NormalizeMinimumQuality(self, frame.minimumQuality)
    local qualityOption = self.TRACKED_ITEM_QUALITY_BY_ID[frame.minimumQuality]
    UIDropDownMenu_SetSelectedValue(frame.qualityDropdown, frame.minimumQuality)
    UIDropDownMenu_SetText(
        frame.qualityDropdown,
        self:GetColoredItemQualityLabel(frame.minimumQuality, qualityOption and qualityOption.label)
    )

    local minimumValueCopper = tonumber(frame.minimumValueCopper) or 0
    if frame.minimumValueInput and not frame.minimumValueInput:HasFocus() then
        frame.minimumValueInput:SetText(FormatGoldInput(self, minimumValueCopper))
    end
end

function GoldTracker:GetInventoryWindowRow(index)
    local frame = self.inventoryFrame
    if not frame or not frame.inventoryContent then
        return nil
    end

    frame.inventoryRows = frame.inventoryRows or {}
    local row = frame.inventoryRows[index]
    if row then
        return row
    end

    row = CreateFrame("Button", nil, frame.inventoryContent)
    row:EnableMouse(true)
    row:SetHeight(INVENTORY_ROW_HEIGHT)

    local background = row:CreateTexture(nil, "BACKGROUND")
    background:SetAllPoints(row)
    row.background = background

    local hover = row:CreateTexture(nil, "HIGHLIGHT")
    hover:SetAllPoints(row)
    hover:SetColorTexture(1, 0.82, 0.18, 0.08)
    row.hover = hover

    local icon = row:CreateTexture(nil, "ARTWORK")
    icon:SetSize(INVENTORY_ICON_SIZE, INVENTORY_ICON_SIZE)
    icon:SetPoint("LEFT", row, "LEFT", 8, 0)
    row.icon = icon

    local totalValueText = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    totalValueText:SetPoint("RIGHT", row, "RIGHT", -6, 0)
    totalValueText:SetWidth(INVENTORY_TOTAL_VALUE_WIDTH)
    totalValueText:SetJustifyH("RIGHT")
    totalValueText:SetWordWrap(false)
    row.totalValueText = totalValueText

    local unitValueText = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    unitValueText:SetPoint("RIGHT", totalValueText, "LEFT", -12, 0)
    unitValueText:SetWidth(INVENTORY_UNIT_VALUE_WIDTH)
    unitValueText:SetJustifyH("RIGHT")
    unitValueText:SetWordWrap(false)
    row.unitValueText = unitValueText

    local quantityText = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    quantityText:SetPoint("RIGHT", unitValueText, "LEFT", -12, 0)
    quantityText:SetWidth(INVENTORY_QUANTITY_WIDTH)
    quantityText:SetJustifyH("RIGHT")
    quantityText:SetWordWrap(false)
    row.quantityText = quantityText

    local itemText = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    itemText:SetPoint("LEFT", icon, "RIGHT", 8, 0)
    itemText:SetPoint("RIGHT", quantityText, "LEFT", -12, 0)
    itemText:SetJustifyH("LEFT")
    itemText:SetWordWrap(false)
    row.itemText = itemText

    local divider = row:CreateTexture(nil, "ARTWORK")
    divider:SetColorTexture(1, 0.82, 0.18, 0.10)
    divider:SetPoint("BOTTOMLEFT", row, "BOTTOMLEFT", 6, 0)
    divider:SetPoint("BOTTOMRIGHT", row, "BOTTOMRIGHT", -6, 0)
    divider:SetHeight(1)
    row.divider = divider

    row:SetScript("OnEnter", function(self)
        if type(self.itemLink) ~= "string" or self.itemLink == "" then
            return
        end
        GameTooltip:SetOwner(self, "ANCHOR_CURSOR")
        GameTooltip:SetHyperlink(self.itemLink)
        GameTooltip:Show()
    end)
    row:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)
    row:SetScript("OnMouseUp", function(self, button)
        if button == "LeftButton" and type(self.itemLink) == "string" and self.itemLink ~= "" and HandleModifiedItemClick then
            HandleModifiedItemClick(self.itemLink)
        end
    end)

    frame.inventoryRows[index] = row
    return row
end

function GoldTracker:RefreshInventoryWindowLayout()
    local frame = self.inventoryFrame
    if not frame or not frame.inventoryScrollFrame or not frame.inventoryContent then
        return
    end

    local contentWidth = (frame.inventoryScrollFrame:GetWidth() or 0) - 6
    frame.inventoryContent:SetWidth(math.max(1, contentWidth))
    if frame.inventoryScrollFrame.UpdateScrollChildRect then
        frame.inventoryScrollFrame:UpdateScrollChildRect()
    end
end

function GoldTracker:RefreshInventoryWindow(scrollToTop)
    local frame = self.inventoryFrame
    if not frame or not frame.inventoryContent then
        return
    end

    local source = ResolveInventoryWindowSource(self, frame)
    local minimumQuality = NormalizeMinimumQuality(self, frame.minimumQuality)
    local minimumValueCopper = tonumber(frame.minimumValueCopper) or 0
    local items, totalValue, totalQuantity, scannedStacks, matchedStacks =
        self:BuildInventoryAuctionItemList(source.id, minimumQuality, minimumValueCopper)
    local rowHeight = INVENTORY_ROW_HEIGHT
    local yOffset = 0

    self:RefreshInventoryWindowControls()

    if frame.metaText then
        if #items > 0 then
            frame.metaText:SetText(string.format(
                "%d items, %d stacks, %d qty, %s",
                #items,
                matchedStacks,
                totalQuantity,
                self:FormatMoney(totalValue)
            ))
        else
            frame.metaText:SetText(string.format("%d stacks scanned", scannedStacks))
        end
    end

    if frame.emptyText then
        frame.emptyText:SetShown(#items == 0)
        frame.emptyText:SetText("No matching auctionable inventory items. Check the source, quality, and value filters.")
    end

    for index, item in ipairs(items) do
        local row = self:GetInventoryWindowRow(index)
        if row then
            row.itemLink = item.itemLink
            row.itemText:SetText(item.itemLink)
            row.quantityText:SetText(tostring(item.quantity or 0))
            row.unitValueText:SetText(self:FormatMoney(item.unitValue or 0))
            row.totalValueText:SetText(self:FormatMoney(item.totalValue or 0))
            row.totalValueText:SetTextColor(0.68, 0.96, 0.72)
            row.unitValueText:SetTextColor(0.72, 0.86, 1.0)
            row.quantityText:SetTextColor(0.92, 0.95, 1.0)

            if item.icon then
                row.icon:SetTexture(item.icon)
                row.icon:Show()
            else
                row.icon:Hide()
            end

            if row.background then
                local alpha = index % 2 == 0 and 0.045 or 0.022
                row.background:SetColorTexture(1, 1, 1, alpha)
            end
            if row.divider then
                row.divider:SetShown(index < #items)
            end

            row:ClearAllPoints()
            row:SetPoint("TOPLEFT", frame.inventoryContent, "TOPLEFT", 0, -yOffset)
            row:SetPoint("TOPRIGHT", frame.inventoryContent, "TOPRIGHT", 0, -yOffset)
            row:SetHeight(rowHeight)
            row:Show()

            yOffset = yOffset + rowHeight
            if index < #items then
                yOffset = yOffset + INVENTORY_ROW_SPACING
            end
        end
    end

    for index = (#items + 1), #(frame.inventoryRows or {}) do
        if frame.inventoryRows[index] then
            frame.inventoryRows[index]:Hide()
        end
    end

    if frame.emptyText and #items == 0 then
        yOffset = math.max(yOffset, 48)
    end

    frame.inventoryContent:SetHeight(math.max(1, yOffset))
    self:RefreshInventoryWindowLayout()
    if scrollToTop and frame.inventoryScrollFrame then
        frame.inventoryScrollFrame:SetVerticalScroll(0)
    end
end

function GoldTracker:SaveInventoryMinimumValueInput()
    local frame = self.inventoryFrame
    if not frame or not frame.minimumValueInput then
        return
    end

    frame.minimumValueCopper = ReadMinimumValueCopper(self, frame.minimumValueInput)
    frame.minimumValueInput:SetText(FormatGoldInput(self, frame.minimumValueCopper))
    self:RefreshInventoryWindow(true)
end

function GoldTracker:CreateInventoryWindow()
    if self.inventoryFrame then
        return
    end

    local addon = self
    local frame = CreateFrame("Frame", "GoldTrackerInventoryFrame", UIParent, "BasicFrameTemplateWithInset")
    frame:SetSize(760, 500)
    frame:SetPoint("CENTER", UIParent, "CENTER", 0, 40)
    frame:SetFrameStrata("DIALOG")
    if frame.SetToplevel then
        frame:SetToplevel(true)
    end
    frame:SetMovable(true)
    frame:SetResizable(true)
    if frame.SetResizeBounds then
        frame:SetResizeBounds(600, 380, 1100, 820)
    else
        if frame.SetMinResize then
            frame:SetMinResize(600, 380)
        end
        if frame.SetMaxResize then
            frame:SetMaxResize(1100, 820)
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
    frame:SetClampedToScreen(true)
    frame:Hide()

    local initialSource = self:GetCurrentValueSource()
    frame.valueSourceID = initialSource and initialSource.id
    frame.minimumQuality = self:GetConfiguredMinimumTrackedItemQuality()
    frame.minimumValueCopper = 0
    frame.inventoryRows = {}

    local chrome = Theme:ApplyWindowChrome(frame, "Auctionable Inventory")
    Theme:RegisterSpecialFrame("GoldTrackerInventoryFrame")

    local controlsPanel = CreateInventoryPanel(frame, { 0.05, 0.06, 0.08, 0.94 }, { 1.0, 0.82, 0.18, 0.12 })
    controlsPanel:SetPoint("TOPLEFT", chrome, "TOPLEFT", 12, -54)
    controlsPanel:SetPoint("TOPRIGHT", chrome, "TOPRIGHT", -12, -54)
    controlsPanel:SetHeight(74)
    frame.controlsPanel = controlsPanel

    local sourceLabel = controlsPanel:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    sourceLabel:SetPoint("TOPLEFT", controlsPanel, "TOPLEFT", 14, -10)
    sourceLabel:SetText("Value source")

    local valueSourceDropdown = CreateFrame("Frame", "GoldTrackerInventoryValueSourceDropdown", controlsPanel, "UIDropDownMenuTemplate")
    valueSourceDropdown:SetPoint("TOPLEFT", sourceLabel, "BOTTOMLEFT", -16, -5)
    UIDropDownMenu_SetWidth(valueSourceDropdown, 210)
    UIDropDownMenu_Initialize(valueSourceDropdown, function(_, level)
        for _, source in ipairs(addon.VALUE_SOURCES) do
            local info = UIDropDownMenu_CreateInfo()
            local sourceID = source.id
            info.text = source.label
            info.value = sourceID
            info.checked = frame.valueSourceID == sourceID
            info.func = function()
                frame.valueSourceID = sourceID
                addon.tsmWarningShown = false
                addon:RefreshInventoryWindow(true)
            end
            UIDropDownMenu_AddButton(info, level)
        end
    end)
    frame.valueSourceDropdown = valueSourceDropdown

    local qualityLabel = controlsPanel:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    qualityLabel:SetPoint("TOPLEFT", sourceLabel, "TOPLEFT", 250, 0)
    qualityLabel:SetText("Min quality")

    local qualityDropdown = CreateFrame("Frame", "GoldTrackerInventoryQualityDropdown", controlsPanel, "UIDropDownMenuTemplate")
    qualityDropdown:SetPoint("TOPLEFT", qualityLabel, "BOTTOMLEFT", -16, -5)
    UIDropDownMenu_SetWidth(qualityDropdown, 180)
    UIDropDownMenu_Initialize(qualityDropdown, function(_, level)
        for _, qualityOption in ipairs(addon.TRACKED_ITEM_QUALITY_OPTIONS) do
            local info = UIDropDownMenu_CreateInfo()
            local qualityID = qualityOption.id
            info.text = addon:GetColoredItemQualityLabel(qualityID, qualityOption.label)
            info.value = qualityID
            info.checked = frame.minimumQuality == qualityID
            info.func = function()
                frame.minimumQuality = qualityID
                addon:RefreshInventoryWindow(true)
            end
            UIDropDownMenu_AddButton(info, level)
        end
    end)
    frame.qualityDropdown = qualityDropdown

    local valueLabel = controlsPanel:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    valueLabel:SetPoint("TOPLEFT", qualityLabel, "TOPLEFT", 220, 0)
    valueLabel:SetText("Min stack value (g)")

    local minimumValueInput = CreateFrame("EditBox", nil, controlsPanel, "InputBoxTemplate")
    minimumValueInput:SetSize(92, 22)
    minimumValueInput:SetPoint("TOPLEFT", valueLabel, "BOTTOMLEFT", 0, -8)
    minimumValueInput:SetAutoFocus(false)
    minimumValueInput:SetNumeric(false)
    minimumValueInput:SetText("0")
    minimumValueInput:SetScript("OnEnterPressed", function(editBox)
        editBox:ClearFocus()
    end)
    minimumValueInput:SetScript("OnEscapePressed", function(editBox)
        frame.skipMinimumValueSave = true
        editBox:SetText(FormatGoldInput(addon, frame.minimumValueCopper))
        editBox:ClearFocus()
        frame.skipMinimumValueSave = false
    end)
    minimumValueInput:SetScript("OnEditFocusLost", function()
        if frame.skipMinimumValueSave then
            return
        end
        addon:SaveInventoryMinimumValueInput()
    end)
    frame.minimumValueInput = minimumValueInput

    local refreshButton = CreateInventoryButton(controlsPanel, 86, 22, "Refresh", "neutral")
    refreshButton:SetSize(86, 22)
    refreshButton:SetPoint("RIGHT", controlsPanel, "RIGHT", -14, -10)
    refreshButton:SetScript("OnClick", function()
        addon:SaveInventoryMinimumValueInput()
    end)
    frame.refreshButton = refreshButton

    local listPanel = CreateInventoryPanel(frame, { 0.04, 0.05, 0.07, 0.92 }, { 1.0, 0.82, 0.18, 0.10 })
    listPanel:SetPoint("TOPLEFT", controlsPanel, "BOTTOMLEFT", 0, -10)
    listPanel:SetPoint("BOTTOMRIGHT", chrome, "BOTTOMRIGHT", -12, 38)
    frame.listPanel = listPanel

    local itemHeader = listPanel:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    itemHeader:SetPoint("TOPLEFT", listPanel, "TOPLEFT", 34, -12)
    itemHeader:SetText("Item")

    local totalHeader = listPanel:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    totalHeader:SetPoint("TOPRIGHT", listPanel, "TOPRIGHT", -34, -12)
    totalHeader:SetWidth(INVENTORY_TOTAL_VALUE_WIDTH)
    totalHeader:SetJustifyH("RIGHT")
    totalHeader:SetText("Stack value")

    local unitHeader = listPanel:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    unitHeader:SetPoint("RIGHT", totalHeader, "LEFT", -12, 0)
    unitHeader:SetWidth(INVENTORY_UNIT_VALUE_WIDTH)
    unitHeader:SetJustifyH("RIGHT")
    unitHeader:SetText("Unit")

    local quantityHeader = listPanel:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    quantityHeader:SetPoint("RIGHT", unitHeader, "LEFT", -12, 0)
    quantityHeader:SetWidth(INVENTORY_QUANTITY_WIDTH)
    quantityHeader:SetJustifyH("RIGHT")
    quantityHeader:SetText("Qty")

    local headerUnderline = listPanel:CreateTexture(nil, "ARTWORK")
    headerUnderline:SetColorTexture(1, 0.82, 0.18, 0.18)
    headerUnderline:SetPoint("TOPLEFT", listPanel, "TOPLEFT", 12, -30)
    headerUnderline:SetPoint("TOPRIGHT", listPanel, "TOPRIGHT", -12, -30)
    headerUnderline:SetHeight(1)

    local scrollFrame = CreateFrame("ScrollFrame", nil, listPanel, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", listPanel, "TOPLEFT", 12, -36)
    scrollFrame:SetPoint("BOTTOMRIGHT", listPanel, "BOTTOMRIGHT", -26, 12)
    scrollFrame:EnableMouseWheel(true)
    scrollFrame:SetScript("OnMouseWheel", function(self, delta)
        local step = math.max(18, math.floor(self:GetHeight() * 0.12))
        local nextScroll = (tonumber(self:GetVerticalScroll()) or 0) - ((tonumber(delta) or 0) * step)
        local maxScroll = tonumber(self:GetVerticalScrollRange()) or 0
        if nextScroll < 0 then
            nextScroll = 0
        elseif nextScroll > maxScroll then
            nextScroll = maxScroll
        end
        self:SetVerticalScroll(nextScroll)
    end)
    frame.inventoryScrollFrame = scrollFrame

    local content = CreateFrame("Frame", nil, scrollFrame)
    content:SetSize(1, 1)
    scrollFrame:SetScrollChild(content)
    frame.inventoryContent = content

    local emptyText = content:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    emptyText:SetPoint("TOPLEFT", content, "TOPLEFT", 10, -12)
    emptyText:SetPoint("TOPRIGHT", content, "TOPRIGHT", -10, -12)
    emptyText:SetJustifyH("LEFT")
    emptyText:SetTextColor(0.62, 0.66, 0.74)
    emptyText:SetText("No matching auctionable inventory items.")
    frame.emptyText = emptyText

    local metaText = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    metaText:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 16, 14)
    metaText:SetPoint("RIGHT", frame, "RIGHT", -40, 14)
    metaText:SetJustifyH("LEFT")
    metaText:SetTextColor(0.72, 0.76, 0.84)
    metaText:SetText("")
    frame.metaText = metaText

    local resizeButton = CreateFrame("Button", nil, frame)
    resizeButton:SetSize(16, 16)
    resizeButton:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -8, 8)
    resizeButton:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")
    resizeButton:SetHighlightTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Highlight")
    resizeButton:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Down")
    resizeButton:SetAlpha(0.7)
    resizeButton:SetScript("OnMouseDown", function(_, button)
        if button == "LeftButton" then
            frame:StartSizing("BOTTOMRIGHT")
        end
    end)
    resizeButton:SetScript("OnMouseUp", function()
        frame:StopMovingOrSizing()
    end)
    resizeButton:SetScript("OnHide", function()
        frame:StopMovingOrSizing()
    end)
    frame.resizeButton = resizeButton

    frame:RegisterEvent("BAG_UPDATE_DELAYED")
    frame:RegisterEvent("GET_ITEM_INFO_RECEIVED")
    frame:RegisterEvent("ITEM_DATA_LOAD_RESULT")
    frame:SetScript("OnEvent", function(self)
        if self:IsShown() then
            addon:RefreshInventoryWindow(false)
        end
    end)
    frame:SetScript("OnSizeChanged", function()
        addon:RefreshInventoryWindowLayout()
    end)
    frame:SetScript("OnShow", function()
        addon:RefreshInventoryWindow(true)
    end)
    frame:SetScript("OnHide", function()
        GameTooltip:Hide()
    end)

    self.inventoryFrame = frame
    self:RefreshInventoryWindowControls()
end

function GoldTracker:OpenInventoryWindow()
    self:CreateInventoryWindow()
    if not self.inventoryFrame then
        return
    end

    self.inventoryFrame:Show()
    self.inventoryFrame:Raise()
    self:RefreshInventoryWindow(true)
end

function GoldTracker:ToggleInventoryWindow()
    self:CreateInventoryWindow()
    if not self.inventoryFrame then
        return
    end

    if self.inventoryFrame:IsShown() then
        self.inventoryFrame:Hide()
    else
        self:OpenInventoryWindow()
    end
end
