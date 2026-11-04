local _, NS = ...
local function CreateFrame(...)
    return (NS.CreateThemedFrame or _G.CreateFrame)(...)
end
local GoldTracker = NS.GoldTracker
local Theme = NS.JanisTheme

local ALERTS_WINDOW_DEFAULT_WIDTH = 1160
local ALERTS_WINDOW_DEFAULT_HEIGHT = 620
local ALERTS_WINDOW_MIN_WIDTH = 900
local ALERTS_WINDOW_MIN_HEIGHT = 420
local ALERTS_WINDOW_MAX_WIDTH = 1320
local ALERTS_WINDOW_MAX_HEIGHT = 900
local ALERTS_ROW_HEIGHT = 26
local ALERTS_ROW_SPACING = 2
local ALERTS_ICON_SIZE = 18
local ALERTS_COLUMN_GAP = 8
local ALERTS_ROW_RIGHT_PADDING = 6
local ALERTS_EXPANSION_WIDTH = 130
local ALERTS_PROFESSION_WIDTH = 104
local ALERTS_BASIS_WIDTH = 90
local ALERTS_LOCAL_WIDTH = 60
local ALERTS_TSM_WIDTH = 60
local ALERTS_QTY_WIDTH = 42
local ALERTS_UNIT_WIDTH = 104
local ALERTS_TOTAL_WIDTH = 110
local ALERTS_ACTIONS_WIDTH = 102
local ALERTS_FARM_BUTTON_WIDTH = 48
local ALERTS_MAP_BUTTON_WIDTH = 48
local ALERTS_ADD_BUTTON_WIDTH = 48
local ALERTS_HORIZONTAL_SCROLL_HEIGHT = 14

local function CreateAlertsPanel(parent, bg, border)
    return Theme:CreatePanel(parent, bg, border)
end

local function CreateAlertsButton(parent, width, height, text, paletteKey)
    return Theme:CreateButton(parent, width, height, text, paletteKey)
end

local function FormatAlertPercent(value)
    local percent = tonumber(value)
    if not percent then
        return "--"
    end
    if percent > 999 then
        return "+999%"
    end
    if percent < -999 then
        return "-999%"
    end
    if percent > 0 then
        return string.format("+%d%%", math.floor(percent + 0.5))
    end
    return string.format("%d%%", math.ceil(percent - 0.5))
end

local function FormatAlertDecimal(value, precision)
    local numberValue = tonumber(value)
    if not numberValue then
        return "Unknown"
    end
    return string.format("%." .. tostring(precision or 2) .. "f", numberValue)
end

local function FormatAlertTimestamp(timestamp)
    local normalizedTimestamp = tonumber(timestamp)
    if not normalizedTimestamp or normalizedTimestamp <= 0 then
        return "Unknown"
    end
    return date("%m-%d %H:%M", normalizedTimestamp)
end

function GoldTracker:ShowPriceIncreaseAlertItemTooltip(row, target)
    if not GameTooltip or type(row) ~= "table" then
        return false
    end

    local itemID = tonumber(row.itemID)
    itemID = itemID and math.floor(itemID + 0.5) or nil
    local itemLink = type(row.itemLink) == "string" and row.itemLink ~= "" and row.itemLink or nil
    if not itemID and not itemLink then
        return false
    end

    GameTooltip:SetOwner(target or row, "ANCHOR_CURSOR")
    if type(GameTooltip.ClearLines) == "function" then
        GameTooltip:ClearLines()
    end
    if itemID and type(GameTooltip.SetItemByID) == "function" then
        GameTooltip:SetItemByID(itemID)
    else
        GameTooltip:SetHyperlink(itemLink)
    end
    GameTooltip:AddLine(" ")
    local isDecrease = row.alertDirection == "decrease"
    GameTooltip:AddLine(isDecrease and "Price decrease alert" or "Price increase alert", 1.0, 0.82, 0.18)
    GameTooltip:AddDoubleLine(
        "Expansion",
        tostring(row.materialExpansionLabel or row.materialExpansionID or "Unknown"),
        0.72,
        0.86,
        1.0,
        1,
        1,
        1
    )
    GameTooltip:AddDoubleLine(
        "Profession",
        tostring(row.materialProfessionLabel or "Unknown"),
        0.72,
        0.86,
        1.0,
        1,
        1,
        1
    )
    GameTooltip:AddDoubleLine("Triggered by", tostring(row.alertBasis or "Unknown"), 0.72, 0.86, 1.0, 1, 1, 1)
    GameTooltip:AddDoubleLine(
        "DBMarket change",
        FormatAlertPercent(row.dbMarketChangePercent),
        0.72,
        0.86,
        1.0,
        0.52,
        1.0,
        0.56
    )
    GameTooltip:AddDoubleLine(
        "Min Buyout change",
        FormatAlertPercent(row.dbMinBuyoutChangePercent),
        0.72,
        0.86,
        1.0,
        0.52,
        1.0,
        0.56
    )
    GameTooltip:AddDoubleLine(
        "Baseline",
        row.baselinePrice and self:FormatMoney(row.baselinePrice) or "Unknown",
        0.72,
        0.86,
        1.0,
        1,
        1,
        1
    )
    GameTooltip:AddDoubleLine(
        "Current",
        row.latestPrice and self:FormatMoney(row.latestPrice) or "Unknown",
        0.72,
        0.86,
        1.0,
        1,
        1,
        1
    )
    GameTooltip:AddDoubleLine("Quantity", tostring(row.quantity or 0), 0.72, 0.86, 1.0, 1, 1, 1)
    GameTooltip:AddDoubleLine("Stack value", self:FormatMoney(row.totalValue or 0), 0.72, 0.86, 1.0, 1, 1, 1)
    GameTooltip:AddDoubleLine(
        "Previous sample",
        FormatAlertTimestamp(row.baselineTimestamp),
        0.72,
        0.86,
        1.0,
        1,
        1,
        1
    )
    GameTooltip:AddDoubleLine(
        "Latest sample",
        FormatAlertTimestamp(row.latestTimestamp),
        0.72,
        0.86,
        1.0,
        1,
        1,
        1
    )
    GameTooltip:AddLine(" ")
    GameTooltip:AddDoubleLine(
        "Region sold/day",
        FormatAlertDecimal(row.regionSoldPerDay, 2),
        0.72,
        0.86,
        1.0,
        1,
        1,
        1
    )
    GameTooltip:AddDoubleLine(
        "Region sale rate",
        FormatAlertDecimal(row.regionSaleRate, 3),
        0.72,
        0.86,
        1.0,
        1,
        1,
        1
    )
    if type(self.AddFarmActionTooltip) == "function" then
        self:AddFarmActionTooltip(GameTooltip, row)
    end
    GameTooltip:Show()
    return true
end

local function ReadAlertsMinimumValueCopper(addon, editBox)
    local rawText = editBox and editBox:GetText() or ""
    rawText = tostring(rawText or ""):gsub(",", ".")
    local goldValue = tonumber(rawText)
    if not goldValue or goldValue < 0 then
        goldValue = 0
    end
    return math.max(0, math.floor((goldValue * addon.COPPER_PER_GOLD) + 0.5))
end

local function FormatAlertsGoldInput(addon, copperValue)
    local normalizedCopper = math.max(0, math.floor(tonumber(copperValue) or 0))
    if normalizedCopper % addon.COPPER_PER_GOLD == 0 then
        return tostring(normalizedCopper / addon.COPPER_PER_GOLD)
    end
    return string.format("%.2f", normalizedCopper / addon.COPPER_PER_GOLD)
end

local function SetAlertsRowColumn(fontString, row, leftOffset, width)
    if not fontString or not row then
        return
    end

    fontString:ClearAllPoints()
    fontString:SetPoint("LEFT", row, "LEFT", leftOffset, 0)
    fontString:SetWidth(math.max(1, width))
end

local function SetAlertsHeaderColumn(fontString, panel, leftOffset, width)
    if not fontString or not panel then
        return
    end

    fontString:ClearAllPoints()
    fontString:SetPoint("TOPLEFT", panel, "TOPLEFT", leftOffset, -12)
    fontString:SetWidth(math.max(1, width))
end

local function PriceIncreaseAlertsNeedsItemDataRefresh(frame, itemID)
    itemID = tonumber(itemID)
    if not itemID then
        return false
    end
    itemID = math.floor(itemID + 0.5)

    for _, row in ipairs(frame and frame.rows or {}) do
        if tonumber(row and row.itemID) == itemID
            and (type(row.IsShown) ~= "function" or row:IsShown())
        then
            local hasName = type(row.itemName) == "string" and row.itemName ~= ""
            local hasLink = type(row.itemLink) == "string" and row.itemLink ~= ""
            local hasIcon = row.iconTexture ~= nil
            return not (hasName and hasLink and hasIcon)
        end
    end
    return false
end

local function SetAlertsColumnShown(fontString, shown)
    if fontString and fontString.SetShown then
        fontString:SetShown(shown == true)
    end
end

local function GetAlertsTableAvailableWidth(frame)
    if not frame then
        return 0
    end

    local width = 0
    if frame.scrollFrame then
        width = tonumber(frame.scrollFrame:GetWidth()) or 0
    end
    if width <= 1 and frame.listPanel then
        width = (tonumber(frame.listPanel:GetWidth()) or 0) - 38
    end

    return math.max(1, width - 6)
end

local function UpdateAlertsHorizontalScroll(frame)
    if not frame then
        return 0
    end

    local contentWidth = frame.content and (tonumber(frame.content:GetWidth()) or 0) or 0
    local maxOffset = math.max(0, math.floor(contentWidth - GetAlertsTableAvailableWidth(frame)))
    local offset = math.min(math.max(0, math.floor(tonumber(frame.horizontalScrollOffset) or 0)), maxOffset)
    frame.horizontalScrollOffset = offset
    if frame.scrollFrame and frame.scrollFrame.UpdateScrollChildRect then
        frame.scrollFrame:UpdateScrollChildRect()
    end
    if frame.scrollFrame and frame.scrollFrame.SetHorizontalScroll then
        frame.scrollFrame:SetHorizontalScroll(offset)
    end
    if frame.horizontalScrollBar then
        frame.horizontalScrollBar:SetMinMaxValues(0, maxOffset)
        frame.horizontalScrollBar:SetValueStep(20)
        if frame.horizontalScrollBar.SetObeyStepOnDrag then
            frame.horizontalScrollBar:SetObeyStepOnDrag(false)
        end
        frame.horizontalScrollBar:SetShown(maxOffset > 0)
        frame.horizontalScrollBar.updating = true
        frame.horizontalScrollBar:SetValue(offset)
        frame.horizontalScrollBar.updating = false
    end
    return offset
end

local function ApplyAlertsTableColumnLayout(frame)
    if not frame then
        return
    end

    local availableWidth = GetAlertsTableAvailableWidth(frame)
    if frame.content then
        frame.content:SetWidth(availableWidth)
    end

    local actionsX = 8
    local iconX = actionsX + ALERTS_ACTIONS_WIDTH + ALERTS_COLUMN_GAP
    local itemX = iconX + ALERTS_ICON_SIZE + 8
    local requiredItemWidth = Theme:GetRequiredTextColumnWidth(frame.rows, "itemText", 1, { padding = 8 })
    local rightEdge = availableWidth - ALERTS_ROW_RIGHT_PADDING
    local showDetailedColumns = availableWidth >= 1000
    local expansionX = rightEdge - ALERTS_EXPANSION_WIDTH
    local professionX = expansionX - ALERTS_COLUMN_GAP - ALERTS_PROFESSION_WIDTH
    local totalX = showDetailedColumns and (professionX - ALERTS_COLUMN_GAP - ALERTS_TOTAL_WIDTH) or nil
    local qtyRightX = totalX or professionX
    local qtyX = showDetailedColumns and (qtyRightX - ALERTS_COLUMN_GAP - ALERTS_QTY_WIDTH) or nil
    local tsmRightX = qtyX or professionX
    local tsmX = showDetailedColumns and (tsmRightX - ALERTS_COLUMN_GAP - ALERTS_TSM_WIDTH) or nil
    local localRightX = tsmX or professionX
    local localX = localRightX - ALERTS_COLUMN_GAP - ALERTS_LOCAL_WIDTH
    local basisX = showDetailedColumns and (localX - ALERTS_COLUMN_GAP - ALERTS_BASIS_WIDTH) or nil
    local unitRightX = basisX or localX
    local unitX = unitRightX - ALERTS_COLUMN_GAP - ALERTS_UNIT_WIDTH
    local itemWidth = math.max(1, unitX - ALERTS_COLUMN_GAP - itemX)
    if showDetailedColumns and itemWidth < requiredItemWidth then
        showDetailedColumns = false
        totalX = nil
        qtyX = nil
        tsmX = nil
        localX = professionX - ALERTS_COLUMN_GAP - ALERTS_LOCAL_WIDTH
        basisX = nil
        unitX = localX - ALERTS_COLUMN_GAP - ALERTS_UNIT_WIDTH
        itemWidth = math.max(1, unitX - ALERTS_COLUMN_GAP - itemX)
    end
    local itemOverflow = math.max(0, requiredItemWidth - itemWidth)
    if itemOverflow > 0 then
        unitX = unitX + itemOverflow
        localX = localX + itemOverflow
        professionX = professionX + itemOverflow
        expansionX = expansionX + itemOverflow
        itemWidth = requiredItemWidth
        if frame.content then
            frame.content:SetWidth(availableWidth + itemOverflow)
        end
    end
    local horizontalOffset = UpdateAlertsHorizontalScroll(frame)

    if frame.listPanel then
        frame.basisHeaderText:SetText("Trigger")
        frame.localHeaderText:SetText(showDetailedColumns and "DBMarket" or "Change")
        frame.tsmHeaderText:SetText("Min Buyout")
        SetAlertsColumnShown(frame.basisHeaderText, showDetailedColumns)
        SetAlertsColumnShown(frame.tsmHeaderText, showDetailedColumns)
        SetAlertsColumnShown(frame.qtyHeaderText, showDetailedColumns)
        SetAlertsColumnShown(frame.totalHeaderText, showDetailedColumns)
        SetAlertsHeaderColumn(frame.actionsHeaderText, frame.listPanel, 20 + actionsX - horizontalOffset, ALERTS_ACTIONS_WIDTH)
        SetAlertsHeaderColumn(frame.itemHeaderText, frame.listPanel, 20 + itemX - horizontalOffset, itemWidth)
        SetAlertsHeaderColumn(frame.unitHeaderText, frame.listPanel, 20 + unitX - horizontalOffset, ALERTS_UNIT_WIDTH)
        if showDetailedColumns then
            SetAlertsHeaderColumn(frame.basisHeaderText, frame.listPanel, 20 + basisX - horizontalOffset, ALERTS_BASIS_WIDTH)
        end
        SetAlertsHeaderColumn(frame.localHeaderText, frame.listPanel, 20 + localX - horizontalOffset, ALERTS_LOCAL_WIDTH)
        if showDetailedColumns then
            SetAlertsHeaderColumn(frame.tsmHeaderText, frame.listPanel, 20 + tsmX - horizontalOffset, ALERTS_TSM_WIDTH)
            SetAlertsHeaderColumn(frame.qtyHeaderText, frame.listPanel, 20 + qtyX - horizontalOffset, ALERTS_QTY_WIDTH)
            SetAlertsHeaderColumn(frame.totalHeaderText, frame.listPanel, 20 + totalX - horizontalOffset, ALERTS_TOTAL_WIDTH)
        end
        SetAlertsHeaderColumn(frame.professionHeaderText, frame.listPanel, 20 + professionX - horizontalOffset, ALERTS_PROFESSION_WIDTH)
        SetAlertsHeaderColumn(frame.expansionHeaderText, frame.listPanel, 20 + expansionX - horizontalOffset, ALERTS_EXPANSION_WIDTH)
    end

    for _, row in ipairs(frame.rows or {}) do
        row.localText:SetText(FormatAlertPercent(
            showDetailedColumns and row.dbMarketChangePercent or row.changePercent
        ))
        row.tsmText:SetText(FormatAlertPercent(row.dbMinBuyoutChangePercent))
        SetAlertsColumnShown(row.basisText, showDetailedColumns)
        SetAlertsColumnShown(row.tsmText, showDetailedColumns)
        SetAlertsColumnShown(row.quantityText, showDetailedColumns)
        SetAlertsColumnShown(row.totalValueText, showDetailedColumns)
        if row.icon then
            row.icon:ClearAllPoints()
            row.icon:SetPoint("LEFT", row, "LEFT", iconX, 0)
        end
        SetAlertsRowColumn(row.itemText, row, itemX, itemWidth)
        SetAlertsRowColumn(row.unitValueText, row, unitX, ALERTS_UNIT_WIDTH)
        if showDetailedColumns then
            SetAlertsRowColumn(row.basisText, row, basisX, ALERTS_BASIS_WIDTH)
        end
        SetAlertsRowColumn(row.localText, row, localX, ALERTS_LOCAL_WIDTH)
        if showDetailedColumns then
            SetAlertsRowColumn(row.tsmText, row, tsmX, ALERTS_TSM_WIDTH)
            SetAlertsRowColumn(row.quantityText, row, qtyX, ALERTS_QTY_WIDTH)
            SetAlertsRowColumn(row.totalValueText, row, totalX, ALERTS_TOTAL_WIDTH)
        end
        if row.mapButton then
            row.mapButton:ClearAllPoints()
            row.mapButton:SetPoint("LEFT", row, "LEFT", actionsX, 0)
        end
        if row.addButton then
            row.addButton:ClearAllPoints()
            row.addButton:SetPoint("LEFT", row.mapButton or row, row.mapButton and "RIGHT" or "LEFT", row.mapButton and 6 or actionsX, 0)
        end
        SetAlertsRowColumn(row.professionText, row, professionX, ALERTS_PROFESSION_WIDTH)
        SetAlertsRowColumn(row.expansionText, row, expansionX, ALERTS_EXPANSION_WIDTH)
    end
end

local function CreateHeaderText(parent, label, justifyH)
    local text = parent:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    text:SetJustifyH(justifyH or "LEFT")
    text:SetWordWrap(false)
    text:SetText(label)
    text:SetTextColor(1.0, 0.82, 0.18)
    return text
end

function GoldTracker:GetPriceIncreaseAlertsWindowRow(index)
    local frame = self.priceIncreaseAlertsFrame
    if not frame or not frame.content then
        return nil
    end

    frame.rows = frame.rows or {}
    local row = frame.rows[index]
    if row then
        return row
    end

    row = CreateFrame("Button", nil, frame.content)
    row:EnableMouse(true)
    row:RegisterForClicks("LeftButtonUp")
    row:SetHeight(ALERTS_ROW_HEIGHT)

    local background = row:CreateTexture(nil, "BACKGROUND")
    background:SetAllPoints(row)
    row.background = background

    local hover = row:CreateTexture(nil, "HIGHLIGHT")
    hover:SetAllPoints(row)
    hover:SetColorTexture(1, 0.82, 0.18, 0.08)
    row.hover = hover

    local icon = row:CreateTexture(nil, "ARTWORK")
    icon:SetSize(ALERTS_ICON_SIZE, ALERTS_ICON_SIZE)
    icon:SetPoint("LEFT", row, "LEFT", 8, 0)
    row.icon = icon

    local itemText = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    itemText:SetJustifyH("LEFT")
    itemText:SetWordWrap(false)
    row.itemText = itemText

    local expansionText = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    expansionText:SetJustifyH("LEFT")
    expansionText:SetWordWrap(false)
    row.expansionText = expansionText

    local professionText = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    professionText:SetJustifyH("LEFT")
    professionText:SetWordWrap(false)
    row.professionText = professionText

    local basisText = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    basisText:SetJustifyH("LEFT")
    basisText:SetWordWrap(false)
    row.basisText = basisText

    local localText = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    localText:SetJustifyH("RIGHT")
    localText:SetWordWrap(false)
    row.localText = localText

    local tsmText = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    tsmText:SetJustifyH("RIGHT")
    tsmText:SetWordWrap(false)
    row.tsmText = tsmText

    local quantityText = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    quantityText:SetJustifyH("RIGHT")
    quantityText:SetWordWrap(false)
    row.quantityText = quantityText

    local unitValueText = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    unitValueText:SetJustifyH("RIGHT")
    unitValueText:SetWordWrap(false)
    row.unitValueText = unitValueText

    local totalValueText = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    totalValueText:SetJustifyH("RIGHT")
    totalValueText:SetWordWrap(false)
    row.totalValueText = totalValueText

    local mapButton = CreateAlertsButton(row, ALERTS_MAP_BUTTON_WIDTH, 20, "Map", "neutral")
    mapButton:SetScript("OnClick", function(self)
        local parentRow = self:GetParent()
        if type(GoldTracker.OpenMaterialFarmingMap) == "function" then
            GoldTracker:OpenMaterialFarmingMap(parentRow.itemID)
        end
    end)
    mapButton:SetScript("OnEnter", function(self)
        if not GameTooltip then
            return
        end
        local parentRow = self:GetParent()
        GameTooltip:SetOwner(self, "ANCHOR_TOP")
        if parentRow and (parentRow.hasFarmingMap or parentRow.hasFarm) then
            GameTooltip:SetText("Open farming map")
        else
            GameTooltip:SetText("No farming map data yet")
        end
        GameTooltip:Show()
    end)
    mapButton:SetScript("OnLeave", function()
        if GameTooltip then
            GameTooltip:Hide()
        end
    end)
    row.mapButton = mapButton

    local addButton = CreateAlertsButton(row, ALERTS_ADD_BUTTON_WIDTH, 20, "Add", "neutral")
    GoldTracker:ConfigureCustomFarmAddButton(addButton, "alerts")
    row.addButton = addButton

    local divider = row:CreateTexture(nil, "ARTWORK")
    divider:SetColorTexture(1, 0.82, 0.18, 0.10)
    divider:SetPoint("BOTTOMLEFT", row, "BOTTOMLEFT", 6, 0)
    divider:SetPoint("BOTTOMRIGHT", row, "BOTTOMRIGHT", -6, 0)
    divider:SetHeight(1)
    row.divider = divider

    self:CreateItemTooltipTarget(row, itemText, icon, function(tooltipRow, target)
        GoldTracker:ShowPriceIncreaseAlertItemTooltip(tooltipRow, target)
    end)
    row:SetScript("OnMouseUp", function(self, button)
        if button ~= "LeftButton" or type(self.itemLink) ~= "string" or self.itemLink == "" then
            return
        end
        if type(GoldTracker.HandleFarmActionClick) == "function" and GoldTracker:HandleFarmActionClick(self, button) then
            return
        end
        if GoldTracker:HandleModifiedItemClickIfModified(self) then
            return
        end
        if type(GoldTracker.OpenInventoryItemDetailsWindow) == "function" then
            GoldTracker:OpenInventoryItemDetailsWindow(self)
        end
    end)

    frame.rows[index] = row
    return row
end

function GoldTracker:RefreshPriceIncreaseAlertsWindowLayout()
    local frame = self.priceIncreaseAlertsFrame
    if not frame or not frame.scrollFrame or not frame.content then
        return
    end

    ApplyAlertsTableColumnLayout(frame)
    if frame.scrollFrame.UpdateScrollChildRect then
        frame.scrollFrame:UpdateScrollChildRect()
    end
end

function GoldTracker:SavePriceIncreaseAlertsMinimumValueInput(skipRefresh)
    local frame = self.priceIncreaseAlertsFrame
    if not frame or not frame.minimumValueInput then
        return
    end

    local minimumValue = ReadAlertsMinimumValueCopper(self, frame.minimumValueInput)
    self:SetPriceIncreaseAlertMinimumValue(minimumValue)
    frame.minimumValueInput:SetText(FormatAlertsGoldInput(self, minimumValue))
    frame.itemDataRefreshGeneration = (tonumber(frame.itemDataRefreshGeneration) or 0) + 1
    if skipRefresh ~= true then
        self:RefreshPriceIncreaseAlertsWindow(true)
    end
end

local function UpdateAlertsViewControls(frame)
    if not frame then
        return
    end
    local direction = frame.alertDirection == "decrease" and "decrease" or "increase"
    if frame.increaseViewButton and frame.increaseViewButton.SetPalette then
        frame.increaseViewButton:SetPalette(direction == "increase" and "primary" or "neutral")
    end
    if frame.decreaseViewButton and frame.decreaseViewButton.SetPalette then
        frame.decreaseViewButton:SetPalette(direction == "decrease" and "primary" or "neutral")
    end
end

local function UpdateKnownPriceScanControls(addon, frame, state)
    if not frame or not frame.scanPricesButton then
        return
    end
    state = type(state) == "table" and state or (addon.GetKnownPriceScanState and addon:GetKnownPriceScanState())
    local running = type(state) == "table" and state.running == true
    if frame.scanPricesButton.SetEnabled then
        frame.scanPricesButton:SetEnabled(not running)
    end
    if running then
        frame.scanPricesButton:SetText(string.format("Scanning %d/%d", state.processed or 0, state.total or 0))
        frame.scanProgressText = string.format(
            "Scanning known prices: %d/%d checked, %d priced.",
            state.processed or 0,
            state.total or 0,
            state.priced or 0
        )
    else
        frame.scanPricesButton:SetText("Scan known prices")
        if type(state) == "table" and state.completedAt then
            frame.scanProgressText = string.format(
                "Known-price scan complete: %d checked, %d priced.",
                state.total or 0,
                state.priced or 0
            )
        end
    end
end

function GoldTracker:RefreshPriceIncreaseAlertsWindow(scrollToTop)
    local frame = self.priceIncreaseAlertsFrame
    if not frame or not frame.content then
        return
    end

    local direction = frame.alertDirection == "decrease" and "decrease" or "increase"
    local rows, meta = self:BuildPriceAlertRows({ direction = direction })
    rows = type(rows) == "table" and rows or {}
    meta = type(meta) == "table" and meta or {}
    if type(self.RecordDisplayedItemMarketSnapshots) == "function" then
        self:RecordDisplayedItemMarketSnapshots(rows)
    end

    if frame.metaText then
        local summary = string.format(
            "%d price %s, %d known items, >= %d%% since the previous snapshot, unit value >= %s",
            #rows,
            direction == "decrease" and "decreases" or "increases",
            tonumber(meta.knownItemCount) or 0,
            tonumber(meta.thresholdPercent) or 30,
            self:FormatMoney(tonumber(meta.minimumValueCopper) or 0)
        )
        frame.metaText:SetText(frame.scanProgressText and (frame.scanProgressText .. "  " .. summary) or summary)
    end

    if frame.emptyText then
        if #rows == 0 then
            frame.emptyText:SetText(string.format(
                "No known non-poor items worth at least %s are %s by %d%% since the previous snapshot.",
                self:FormatMoney(tonumber(meta.minimumValueCopper) or 0),
                direction == "decrease" and "down" or "up",
                tonumber(meta.thresholdPercent) or 30
            ))
            frame.emptyText:Show()
        else
            frame.emptyText:SetText("")
            frame.emptyText:Hide()
        end
    end

    local yOffset = 0
    for index, result in ipairs(rows) do
        local row = self:GetPriceIncreaseAlertsWindowRow(index)
        if row then
            row.itemID = result.itemID
            row.itemLink = result.itemLink
            row.itemName = result.itemName
            row.itemQuality = result.itemQuality
            row.iconTexture = result.icon
            row.quantity = result.quantity
            row.unitValue = result.unitValue
            row.totalValue = result.totalValue
            row.baselinePrice = result.baselinePrice
            row.latestPrice = result.latestPrice
            row.changePercent = result.changePercent
            row.dbMarketChangePercent = result.dbMarketChangePercent
            row.dbMinBuyoutChangePercent = result.dbMinBuyoutChangePercent
            row.baselineTimestamp = result.baselineTimestamp
            row.latestTimestamp = result.latestTimestamp
            row.regionSoldPerDay = result.regionSoldPerDay
            row.regionSaleRate = result.regionSaleRate
            row.alertBasis = result.alertBasis
            row.alertDirection = result.alertDirection
            row.isIndexedMaterial = result.isIndexedMaterial == true
            row.hasFarmingMap = result.hasFarmingMap == true
            row.hasFarm = type(self.HasFarmForItem) == "function" and self:HasFarmForItem(result.itemID) or false
            row.materialExpansionID = result.materialExpansionID
            row.materialExpansionLabel = result.materialExpansionLabel
            row.materialProfessionIDs = result.materialProfessionIDs
            row.materialProfessionLabel = result.materialProfessionLabel

            local alertBasis = tostring(result.alertBasis or "Unknown")
            row.itemText:SetText(result.itemLink or result.itemName or ("Item " .. tostring(result.itemID or "?")))
            row.expansionText:SetText(tostring(result.materialExpansionLabel or result.materialExpansionID or "Unknown"))
            row.professionText:SetText(tostring(result.materialProfessionLabel or "Unknown"))
            row.basisText:SetText(alertBasis)
            row.localText:SetText(FormatAlertPercent(result.changePercent))
            row.tsmText:SetText(FormatAlertPercent(result.dbMinBuyoutChangePercent))
            row.quantityText:SetText(tostring(result.quantity or 0))
            row.unitValueText:SetText(self:FormatMoney(result.unitValue or 0))
            row.totalValueText:SetText(self:FormatMoney(result.totalValue or 0))

            row.basisText:SetTextColor(result.isMaterial and 0.72 or 1.0, result.isMaterial and 0.86 or 0.82, result.isMaterial and 1.0 or 0.18)
            row.expansionText:SetTextColor(0.76, 0.82, 0.94)
            row.professionText:SetTextColor(0.72, 0.86, 1.0)
            local changeR, changeG, changeB = direction == "decrease" and 1.0 or 0.52,
                direction == "decrease" and 0.48 or 1.0,
                direction == "decrease" and 0.42 or 0.56
            row.localText:SetTextColor(changeR, changeG, changeB)
            row.tsmText:SetTextColor(changeR, changeG, changeB)
            row.quantityText:SetTextColor(0.92, 0.95, 1.0)
            row.unitValueText:SetTextColor(0.72, 0.86, 1.0)
            row.totalValueText:SetTextColor(0.68, 0.96, 0.72)

            if result.icon then
                row.icon:SetTexture(result.icon)
                row.icon:Show()
            else
                row.icon:Hide()
            end

            if row.background then
                row.background:SetColorTexture(1, 1, 1, index % 2 == 0 and 0.045 or 0.022)
            end
            if row.divider then
                row.divider:SetShown(index < #rows)
            end
            if row.mapButton then
                if result.isIndexedMaterial == true then
                    if row.mapButton.SetEnabled then
                        row.mapButton:SetEnabled(result.hasFarmingMap == true or row.hasFarm == true)
                    end
                    if row.mapButton.SetAlpha then
                        row.mapButton:SetAlpha((result.hasFarmingMap == true or row.hasFarm == true) and 1 or 0.42)
                    end
                    row.mapButton:Show()
                else
                    row.mapButton:Hide()
                end
            end
            if row.addButton then
                row.addButton:Show()
            end

            row:ClearAllPoints()
            row:SetPoint("TOPLEFT", frame.content, "TOPLEFT", 0, -yOffset)
            row:SetPoint("TOPRIGHT", frame.content, "TOPRIGHT", 0, -yOffset)
            row:SetHeight(ALERTS_ROW_HEIGHT)
            row:Show()

            yOffset = yOffset + ALERTS_ROW_HEIGHT
            if index < #rows then
                yOffset = yOffset + ALERTS_ROW_SPACING
            end
        end
    end

    for index = (#rows + 1), #(frame.rows or {}) do
        if frame.rows[index] then
            frame.rows[index]:Hide()
        end
    end

    frame.content:SetHeight(math.max(1, yOffset))
    UpdateAlertsViewControls(frame)
    UpdateKnownPriceScanControls(self, frame)
    self:RefreshPriceIncreaseAlertsWindowLayout()
    if scrollToTop and frame.scrollFrame then
        frame.scrollFrame:SetVerticalScroll(0)
    end
end

function GoldTracker:CreatePriceIncreaseAlertsWindow()
    if self.priceIncreaseAlertsFrame then
        return
    end

    local addon = self
    local frame = CreateFrame("Frame", "GoldTrackerPriceIncreaseAlertsFrame", UIParent)
    frame:SetSize(ALERTS_WINDOW_DEFAULT_WIDTH, ALERTS_WINDOW_DEFAULT_HEIGHT)
    frame:SetPoint("CENTER", UIParent, "CENTER", 0, 40)
    frame:SetFrameStrata("DIALOG")
    if frame.SetToplevel then
        frame:SetToplevel(true)
    end
    frame:SetMovable(true)
    frame:SetResizable(true)
    if frame.SetResizeBounds then
        frame:SetResizeBounds(
            ALERTS_WINDOW_MIN_WIDTH,
            ALERTS_WINDOW_MIN_HEIGHT,
            ALERTS_WINDOW_MAX_WIDTH,
            ALERTS_WINDOW_MAX_HEIGHT
        )
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
    frame.rows = {}
    frame.alertDirection = "increase"

    local chrome = Theme:ApplyWindowChrome(frame, "Market Watch")
    Theme:RegisterSpecialFrame("GoldTrackerPriceIncreaseAlertsFrame")

    local controlsPanel = CreateAlertsPanel(frame, { 0.05, 0.06, 0.08, 0.94 }, { 1.0, 0.82, 0.18, 0.12 })
    controlsPanel:SetPoint("TOPLEFT", chrome, "TOPLEFT", 12, -54)
    controlsPanel:SetPoint("TOPRIGHT", chrome, "TOPRIGHT", -12, -54)
    controlsPanel:SetHeight(66)
    frame.controlsPanel = controlsPanel

    local valueLabel = controlsPanel:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    valueLabel:SetText("Min unit value (g)")
    frame.valueLabel = valueLabel

    local minimumValueInput = CreateFrame("EditBox", nil, controlsPanel, "InputBoxTemplate")
    minimumValueInput:SetSize(96, 22)
    minimumValueInput:SetAutoFocus(false)
    minimumValueInput:SetNumeric(false)
    minimumValueInput:SetText(FormatAlertsGoldInput(self, self:GetPriceIncreaseAlertConfig().minimumValueCopper))
    minimumValueInput:SetScript("OnEnterPressed", function(editBox)
        editBox:ClearFocus()
    end)
    minimumValueInput:SetScript("OnEscapePressed", function(editBox)
        editBox:SetText(FormatAlertsGoldInput(addon, addon:GetPriceIncreaseAlertConfig().minimumValueCopper))
        editBox:ClearFocus()
    end)
    minimumValueInput:SetScript("OnEditFocusLost", function()
        addon:SavePriceIncreaseAlertsMinimumValueInput()
    end)
    frame.minimumValueInput = minimumValueInput

    local viewLabel = controlsPanel:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    viewLabel:SetText("View")
    frame.viewLabel = viewLabel

    local viewControl = CreateFrame("Frame", nil, controlsPanel)
    viewControl:SetSize(208, 24)
    frame.viewControl = viewControl
    local increaseViewButton = CreateAlertsButton(viewControl, 96, 24, "Increases", "primary")
    increaseViewButton:SetPoint("LEFT", viewControl, "LEFT", 0, 0)
    increaseViewButton:SetScript("OnClick", function()
        frame.alertDirection = "increase"
        addon:RefreshPriceIncreaseAlertsWindow(true)
    end)
    frame.increaseViewButton = increaseViewButton
    local decreaseViewButton = CreateAlertsButton(viewControl, 104, 24, "Decreases", "neutral")
    decreaseViewButton:SetPoint("LEFT", increaseViewButton, "RIGHT", 8, 0)
    decreaseViewButton:SetScript("OnClick", function()
        frame.alertDirection = "decrease"
        addon:RefreshPriceIncreaseAlertsWindow(true)
    end)
    frame.decreaseViewButton = decreaseViewButton

    local refreshButton = CreateAlertsButton(controlsPanel, 96, 24, "Refresh", "neutral")
    refreshButton:SetScript("OnClick", function()
        frame.itemDataRefreshGeneration = (tonumber(frame.itemDataRefreshGeneration) or 0) + 1
        addon:RefreshPriceIncreaseAlertsWindow(true)
    end)
    frame.refreshButton = refreshButton

    local scanPricesButton = CreateAlertsButton(controlsPanel, 154, 24, "Scan known prices", "neutral")
    scanPricesButton:SetScript("OnClick", function()
        if type(addon.StartKnownPriceScan) ~= "function" then
            return
        end
        local _, state = addon:StartKnownPriceScan({
            onProgress = function(scanState)
                UpdateKnownPriceScanControls(addon, frame, scanState)
                if frame.metaText and frame.scanProgressText then
                    frame.metaText:SetText(frame.scanProgressText)
                end
            end,
            onComplete = function(scanState)
                UpdateKnownPriceScanControls(addon, frame, scanState)
                addon:RefreshPriceIncreaseAlertsWindow(true)
            end,
        })
        UpdateKnownPriceScanControls(addon, frame, state)
    end)
    frame.scanPricesButton = scanPricesButton

    Theme:LayoutExplorerFilterFields(controlsPanel, {
        { label = valueLabel, control = minimumValueInput, widthKey = "valueInput" },
        { label = viewLabel, control = viewControl, width = 208 },
    })
    Theme:LayoutExplorerActionButtons(controlsPanel, { refreshButton, scanPricesButton })

    local listPanel = CreateAlertsPanel(frame, { 0.04, 0.05, 0.07, 0.92 }, { 1.0, 0.82, 0.18, 0.10 })
    listPanel:SetPoint("TOPLEFT", controlsPanel, "BOTTOMLEFT", 0, -10)
    listPanel:SetPoint("BOTTOMRIGHT", chrome, "BOTTOMRIGHT", -12, 38)
    frame.listPanel = listPanel

    frame.itemHeaderText = CreateHeaderText(listPanel, "Item", "LEFT")
    frame.expansionHeaderText = CreateHeaderText(listPanel, "Expansion", "LEFT")
    frame.professionHeaderText = CreateHeaderText(listPanel, "Profession", "LEFT")
    frame.basisHeaderText = CreateHeaderText(listPanel, "Trigger", "LEFT")
    frame.localHeaderText = CreateHeaderText(listPanel, "DBMarket", "RIGHT")
    frame.tsmHeaderText = CreateHeaderText(listPanel, "Min Buyout", "RIGHT")
    frame.qtyHeaderText = CreateHeaderText(listPanel, "Qty", "RIGHT")
    frame.unitHeaderText = CreateHeaderText(listPanel, "Unit value", "RIGHT")
    frame.totalHeaderText = CreateHeaderText(listPanel, "Stack value", "RIGHT")
    frame.actionsHeaderText = CreateHeaderText(listPanel, "Actions", "LEFT")

    local headerUnderline = listPanel:CreateTexture(nil, "ARTWORK")
    headerUnderline:SetColorTexture(1, 0.82, 0.18, 0.18)
    headerUnderline:SetPoint("TOPLEFT", listPanel, "TOPLEFT", 12, -30)
    headerUnderline:SetPoint("TOPRIGHT", listPanel, "TOPRIGHT", -12, -30)
    headerUnderline:SetHeight(1)

    local scrollFrame = CreateFrame("ScrollFrame", nil, listPanel, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", listPanel, "TOPLEFT", 12, -36)
    scrollFrame:SetPoint("BOTTOMRIGHT", listPanel, "BOTTOMRIGHT", -26, 12 + ALERTS_HORIZONTAL_SCROLL_HEIGHT)
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
    frame.scrollFrame = scrollFrame

    local content = CreateFrame("Frame", nil, scrollFrame)
    content:SetSize(1, 1)
    scrollFrame:SetScrollChild(content)
    frame.content = content

    local horizontalScrollBar = CreateFrame("Slider", "GoldTrackerAlertsHorizontalScrollBar", listPanel, "OptionsSliderTemplate")
    horizontalScrollBar:SetOrientation("HORIZONTAL")
    horizontalScrollBar:SetPoint("BOTTOMLEFT", listPanel, "BOTTOMLEFT", 14, 9)
    horizontalScrollBar:SetPoint("BOTTOMRIGHT", listPanel, "BOTTOMRIGHT", -32, 9)
    horizontalScrollBar:SetHeight(12)
    horizontalScrollBar:SetMinMaxValues(0, 0)
    horizontalScrollBar:SetValue(0)
    horizontalScrollBar:SetScript("OnValueChanged", function(self, value)
        if self.updating then
            return
        end
        frame.horizontalScrollOffset = math.max(0, math.floor((tonumber(value) or 0) + 0.5))
        addon:RefreshPriceIncreaseAlertsWindowLayout()
    end)
    local sliderName = horizontalScrollBar:GetName()
    if sliderName then
        _G[sliderName .. "Low"]:Hide()
        _G[sliderName .. "High"]:Hide()
        _G[sliderName .. "Text"]:Hide()
    end
    horizontalScrollBar:Hide()
    frame.horizontalScrollBar = horizontalScrollBar

    local emptyText = content:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    emptyText:SetPoint("TOPLEFT", content, "TOPLEFT", 10, -12)
    emptyText:SetPoint("TOPRIGHT", content, "TOPRIGHT", -10, -12)
    emptyText:SetJustifyH("LEFT")
    emptyText:SetTextColor(0.62, 0.66, 0.74)
    emptyText:SetText("")
    emptyText:Hide()
    frame.emptyText = emptyText

    local metaText = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    metaText:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 16, 14)
    metaText:SetPoint("RIGHT", frame, "RIGHT", -40, 14)
    metaText:SetJustifyH("LEFT")
    metaText:SetTextColor(0.72, 0.76, 0.84)
    metaText:SetText("")
    frame.metaText = metaText

    Theme:CreateResizeButton(frame, {
        maximize = true,
        minWidth = ALERTS_WINDOW_MIN_WIDTH,
        minHeight = ALERTS_WINDOW_MIN_HEIGHT,
        maxWidth = ALERTS_WINDOW_MAX_WIDTH,
        maxHeight = ALERTS_WINDOW_MAX_HEIGHT,
        onResizeStop = function()
            addon:RefreshPriceIncreaseAlertsWindowLayout()
        end,
    })

    frame:RegisterEvent("BAG_UPDATE_DELAYED")
    frame:RegisterEvent("GET_ITEM_INFO_RECEIVED")
    frame:RegisterEvent("ITEM_DATA_LOAD_RESULT")
    frame:RegisterEvent("PLAYER_LOGOUT")
    frame:SetScript("OnEvent", function(self, event, itemID)
        if event == "PLAYER_LOGOUT" then
            addon:SavePriceIncreaseAlertsMinimumValueInput(true)
            return
        end

        if not self:IsShown() then
            return
        end

        if event == "BAG_UPDATE_DELAYED" then
            self.itemDataRefreshGeneration = (tonumber(self.itemDataRefreshGeneration) or 0) + 1
            addon:RefreshPriceIncreaseAlertsWindow(false)
            return
        end

        if type(addon.IsFarmItemDataRequest) == "function" and addon:IsFarmItemDataRequest(itemID) then
            return
        end
        if not PriceIncreaseAlertsNeedsItemDataRefresh(self, itemID) then
            return
        end

        self.itemDataRefreshGeneration = (tonumber(self.itemDataRefreshGeneration) or 0) + 1
        local refreshGeneration = self.itemDataRefreshGeneration
        local function RefreshAfterItemDataSettles()
            if self.itemDataRefreshGeneration == refreshGeneration and self:IsShown() then
                addon:RefreshPriceIncreaseAlertsWindow(false)
            end
        end
        if C_Timer and type(C_Timer.After) == "function" then
            C_Timer.After(0.25, RefreshAfterItemDataSettles)
        else
            RefreshAfterItemDataSettles()
        end
    end)
    frame:SetScript("OnSizeChanged", function()
        if frame.isManualResizing then
            return
        end
        addon:RefreshPriceIncreaseAlertsWindowLayout()
    end)
    frame:SetScript("OnUpdate", function(self, elapsed)
        if not self:IsShown() then
            return
        end
        self.scanUpdateElapsed = (tonumber(self.scanUpdateElapsed) or 0) + (tonumber(elapsed) or 0)
        if self.scanUpdateElapsed < 0.25 then
            return
        end
        self.scanUpdateElapsed = 0
        local state = addon.GetKnownPriceScanState and addon:GetKnownPriceScanState() or nil
        local running = type(state) == "table" and state.running == true
        UpdateKnownPriceScanControls(addon, self, state)
        if self.lastKnownPriceScanRunning == true and not running then
            addon:RefreshPriceIncreaseAlertsWindow(true)
        elseif running and self.metaText and self.scanProgressText then
            self.metaText:SetText(self.scanProgressText)
        end
        self.lastKnownPriceScanRunning = running
    end)
    frame:SetScript("OnShow", function()
        if frame.suppressExplorerOnShow then
            return
        end
        addon:RefreshPriceIncreaseAlertsWindow(true)
    end)
    frame:SetScript("OnHide", function()
        frame.itemDataRefreshGeneration = (tonumber(frame.itemDataRefreshGeneration) or 0) + 1
        if GameTooltip then
            GameTooltip:Hide()
        end
    end)

    self.priceIncreaseAlertsFrame = frame
    self:RefreshPriceIncreaseAlertsWindowLayout()
end

function GoldTracker:OpenPriceIncreaseAlertsWindow()
    if type(self.OpenExplorerWindow) == "function" then
        self:OpenExplorerWindow("priceAlerts")
        return
    end

    self:CreatePriceIncreaseAlertsWindow()
    if not self.priceIncreaseAlertsFrame then
        return
    end

    self.priceIncreaseAlertsFrame:Show()
    self.priceIncreaseAlertsFrame:Raise()
    self:RefreshPriceIncreaseAlertsWindow(true)
end

function GoldTracker:TogglePriceIncreaseAlertsWindow()
    if type(self.ToggleExplorerWindow) == "function" then
        self:ToggleExplorerWindow("priceAlerts")
        return
    end

    self:CreatePriceIncreaseAlertsWindow()
    if not self.priceIncreaseAlertsFrame then
        return
    end

    if self.priceIncreaseAlertsFrame:IsShown() then
        self.priceIncreaseAlertsFrame:Hide()
    else
        self:OpenPriceIncreaseAlertsWindow()
    end
end
