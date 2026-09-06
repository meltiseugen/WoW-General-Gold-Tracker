local _, NS = ...
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
local ALERTS_COLUMN_GAP = 12
local ALERTS_ROW_RIGHT_PADDING = 6
local ALERTS_BASIS_WIDTH = 104
local ALERTS_LOCAL_WIDTH = 70
local ALERTS_TSM_WIDTH = 70
local ALERTS_QTY_WIDTH = 52
local ALERTS_UNIT_WIDTH = 118
local ALERTS_TOTAL_WIDTH = 128

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

local function ApplyAlertsTableColumnLayout(frame)
    if not frame then
        return
    end

    local availableWidth = GetAlertsTableAvailableWidth(frame)
    if frame.content then
        frame.content:SetWidth(availableWidth)
    end

    local iconX = 8
    local itemX = iconX + ALERTS_ICON_SIZE + 8
    local rightEdge = availableWidth - ALERTS_ROW_RIGHT_PADDING
    local totalX = rightEdge - ALERTS_TOTAL_WIDTH
    local unitX = totalX - ALERTS_COLUMN_GAP - ALERTS_UNIT_WIDTH
    local qtyX = unitX - ALERTS_COLUMN_GAP - ALERTS_QTY_WIDTH
    local tsmX = qtyX - ALERTS_COLUMN_GAP - ALERTS_TSM_WIDTH
    local localX = tsmX - ALERTS_COLUMN_GAP - ALERTS_LOCAL_WIDTH
    local basisX = localX - ALERTS_COLUMN_GAP - ALERTS_BASIS_WIDTH
    local itemWidth = math.max(1, basisX - ALERTS_COLUMN_GAP - itemX)

    if frame.listPanel then
        SetAlertsHeaderColumn(frame.itemHeaderText, frame.listPanel, 20 + itemX, itemWidth)
        SetAlertsHeaderColumn(frame.basisHeaderText, frame.listPanel, 20 + basisX, ALERTS_BASIS_WIDTH)
        SetAlertsHeaderColumn(frame.localHeaderText, frame.listPanel, 20 + localX, ALERTS_LOCAL_WIDTH)
        SetAlertsHeaderColumn(frame.tsmHeaderText, frame.listPanel, 20 + tsmX, ALERTS_TSM_WIDTH)
        SetAlertsHeaderColumn(frame.qtyHeaderText, frame.listPanel, 20 + qtyX, ALERTS_QTY_WIDTH)
        SetAlertsHeaderColumn(frame.unitHeaderText, frame.listPanel, 20 + unitX, ALERTS_UNIT_WIDTH)
        SetAlertsHeaderColumn(frame.totalHeaderText, frame.listPanel, 20 + totalX, ALERTS_TOTAL_WIDTH)
    end

    for _, row in ipairs(frame.rows or {}) do
        SetAlertsRowColumn(row.itemText, row, itemX, itemWidth)
        SetAlertsRowColumn(row.basisText, row, basisX, ALERTS_BASIS_WIDTH)
        SetAlertsRowColumn(row.localText, row, localX, ALERTS_LOCAL_WIDTH)
        SetAlertsRowColumn(row.tsmText, row, tsmX, ALERTS_TSM_WIDTH)
        SetAlertsRowColumn(row.quantityText, row, qtyX, ALERTS_QTY_WIDTH)
        SetAlertsRowColumn(row.unitValueText, row, unitX, ALERTS_UNIT_WIDTH)
        SetAlertsRowColumn(row.totalValueText, row, totalX, ALERTS_TOTAL_WIDTH)
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

    local divider = row:CreateTexture(nil, "ARTWORK")
    divider:SetColorTexture(1, 0.82, 0.18, 0.10)
    divider:SetPoint("BOTTOMLEFT", row, "BOTTOMLEFT", 6, 0)
    divider:SetPoint("BOTTOMRIGHT", row, "BOTTOMRIGHT", -6, 0)
    divider:SetHeight(1)
    row.divider = divider

    row:SetScript("OnEnter", function(self)
        if type(self.itemLink) ~= "string" or self.itemLink == "" or not GameTooltip then
            return
        end
        GameTooltip:SetOwner(self, "ANCHOR_CURSOR")
        GameTooltip:SetHyperlink(self.itemLink)
        GameTooltip:AddLine(" ")
        GameTooltip:AddLine("Price increase alert", 1.0, 0.82, 0.18)
        GameTooltip:AddDoubleLine("Alert basis", tostring(self.alertBasis or "Unknown"), 0.72, 0.86, 1.0, 1, 1, 1)
        GameTooltip:AddDoubleLine("Local change", FormatAlertPercent(self.localChangePercent), 0.72, 0.86, 1.0, 0.52, 1.0, 0.56)
        GameTooltip:AddDoubleLine("TSM change", FormatAlertPercent(self.tsmChangePercent), 0.72, 0.86, 1.0, 0.52, 1.0, 0.56)
        GameTooltip:AddDoubleLine("Baseline", self.baselinePrice and GoldTracker:FormatMoney(self.baselinePrice) or "Unknown", 0.72, 0.86, 1.0, 1, 1, 1)
        GameTooltip:AddDoubleLine("Current", self.latestPrice and GoldTracker:FormatMoney(self.latestPrice) or "Unknown", 0.72, 0.86, 1.0, 1, 1, 1)
        GameTooltip:AddDoubleLine("Local samples", tostring(self.localSampleCount or 0), 0.72, 0.86, 1.0, 1, 1, 1)
        GameTooltip:AddDoubleLine("First sample", FormatAlertTimestamp(self.baselineTimestamp), 0.72, 0.86, 1.0, 1, 1, 1)
        GameTooltip:AddDoubleLine("Latest sample", FormatAlertTimestamp(self.latestTimestamp), 0.72, 0.86, 1.0, 1, 1, 1)
        GameTooltip:AddLine(" ")
        GameTooltip:AddDoubleLine("Region sold/day", FormatAlertDecimal(self.regionSoldPerDay, 2), 0.72, 0.86, 1.0, 1, 1, 1)
        GameTooltip:AddDoubleLine("Region sale rate", FormatAlertDecimal(self.regionSaleRate, 3), 0.72, 0.86, 1.0, 1, 1, 1)
        GameTooltip:Show()
    end)
    row:SetScript("OnLeave", function()
        if GameTooltip then
            GameTooltip:Hide()
        end
    end)
    row:SetScript("OnMouseUp", function(self, button)
        if button ~= "LeftButton" or type(self.itemLink) ~= "string" or self.itemLink == "" then
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

function GoldTracker:RefreshPriceIncreaseAlertsWindow(scrollToTop)
    local frame = self.priceIncreaseAlertsFrame
    if not frame or not frame.content then
        return
    end

    local rows, meta = self:BuildPriceIncreaseAlertRows()
    rows = type(rows) == "table" and rows or {}
    meta = type(meta) == "table" and meta or {}

    if frame.metaText then
        frame.metaText:SetText(string.format(
            "%d alerts, %d bag items, %d stacks scanned, >= %d%% over %d days",
            #rows,
            tonumber(meta.inventoryItemCount) or 0,
            tonumber(meta.scannedStacks) or 0,
            tonumber(meta.thresholdPercent) or 30,
            tonumber(meta.lookbackDays) or 3
        ))
    end

    if frame.emptyText then
        if #rows == 0 then
            frame.emptyText:SetText(string.format(
                "No bag items or materials are up by at least %d%% yet.",
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
            row.localChangePercent = result.localChangePercent
            row.tsmChangePercent = result.tsmChangePercent
            row.localSampleCount = result.localSampleCount
            row.baselineTimestamp = result.baselineTimestamp
            row.latestTimestamp = result.latestTimestamp
            row.regionSoldPerDay = result.regionSoldPerDay
            row.regionSaleRate = result.regionSaleRate
            row.alertBasis = result.alertBasis

            local alertBasis = tostring(result.alertBasis or "Unknown")
            row.itemText:SetText(result.itemLink or result.itemName or ("Item " .. tostring(result.itemID or "?")))
            row.basisText:SetText(result.isMaterial and (alertBasis .. " material") or alertBasis)
            row.localText:SetText(FormatAlertPercent(result.localChangePercent))
            row.tsmText:SetText(FormatAlertPercent(result.tsmChangePercent))
            row.quantityText:SetText(tostring(result.quantity or 0))
            row.unitValueText:SetText(self:FormatMoney(result.unitValue or 0))
            row.totalValueText:SetText(self:FormatMoney(result.totalValue or 0))

            row.basisText:SetTextColor(result.isMaterial and 0.72 or 1.0, result.isMaterial and 0.86 or 0.82, result.isMaterial and 1.0 or 0.18)
            row.localText:SetTextColor(0.52, 1.00, 0.56)
            row.tsmText:SetTextColor(0.68, 0.96, 0.72)
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
    local frame = CreateFrame("Frame", "GoldTrackerPriceIncreaseAlertsFrame", UIParent, "BasicFrameTemplateWithInset")
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

    local chrome = Theme:ApplyWindowChrome(frame, "Price Alerts")
    Theme:RegisterSpecialFrame("GoldTrackerPriceIncreaseAlertsFrame")

    local controlsPanel = CreateAlertsPanel(frame, { 0.05, 0.06, 0.08, 0.94 }, { 1.0, 0.82, 0.18, 0.12 })
    controlsPanel:SetPoint("TOPLEFT", chrome, "TOPLEFT", 12, -54)
    controlsPanel:SetPoint("TOPRIGHT", chrome, "TOPRIGHT", -12, -54)
    controlsPanel:SetHeight(48)
    frame.controlsPanel = controlsPanel

    local titleText = controlsPanel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    titleText:SetPoint("LEFT", controlsPanel, "LEFT", 14, 0)
    titleText:SetText("Recent price increases")
    titleText:SetTextColor(1.0, 0.82, 0.18)
    frame.titleText = titleText

    local refreshButton = CreateAlertsButton(controlsPanel, 86, 22, "Refresh", "neutral")
    refreshButton:SetPoint("RIGHT", controlsPanel, "RIGHT", -14, 0)
    refreshButton:SetScript("OnClick", function()
        addon:RefreshPriceIncreaseAlertsWindow(true)
    end)
    frame.refreshButton = refreshButton

    local listPanel = CreateAlertsPanel(frame, { 0.04, 0.05, 0.07, 0.92 }, { 1.0, 0.82, 0.18, 0.10 })
    listPanel:SetPoint("TOPLEFT", controlsPanel, "BOTTOMLEFT", 0, -10)
    listPanel:SetPoint("BOTTOMRIGHT", chrome, "BOTTOMRIGHT", -12, 38)
    frame.listPanel = listPanel

    frame.itemHeaderText = CreateHeaderText(listPanel, "Item", "LEFT")
    frame.basisHeaderText = CreateHeaderText(listPanel, "Basis", "LEFT")
    frame.localHeaderText = CreateHeaderText(listPanel, "Local", "RIGHT")
    frame.tsmHeaderText = CreateHeaderText(listPanel, "TSM", "RIGHT")
    frame.qtyHeaderText = CreateHeaderText(listPanel, "Qty", "RIGHT")
    frame.unitHeaderText = CreateHeaderText(listPanel, "Unit value", "RIGHT")
    frame.totalHeaderText = CreateHeaderText(listPanel, "Stack value", "RIGHT")

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
    frame.scrollFrame = scrollFrame

    local content = CreateFrame("Frame", nil, scrollFrame)
    content:SetSize(1, 1)
    scrollFrame:SetScrollChild(content)
    frame.content = content

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
    frame:SetScript("OnEvent", function(self)
        if self:IsShown() then
            addon:RefreshPriceIncreaseAlertsWindow(false)
        end
    end)
    frame:SetScript("OnSizeChanged", function()
        if frame.isManualResizing then
            return
        end
        addon:RefreshPriceIncreaseAlertsWindowLayout()
    end)
    frame:SetScript("OnShow", function()
        if frame.suppressExplorerOnShow then
            return
        end
        addon:RefreshPriceIncreaseAlertsWindow(true)
    end)
    frame:SetScript("OnHide", function()
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
