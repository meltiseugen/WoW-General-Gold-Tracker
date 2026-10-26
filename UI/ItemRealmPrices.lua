local _, NS = ...
local function CreateFrame(...)
    return (NS.CreateThemedFrame or _G.CreateFrame)(...)
end
local GoldTracker = NS.GoldTracker
local Theme = NS.JanisTheme
local ROW_HEIGHT, HEADER_HEIGHT = 26, 26
local COLUMNS = {
    { key = "realm", label = "Realm", width = 146 },
    { key = "minBuyout", label = "Min Buyout", source = "DBMinBuyout", dataset = "current", width = 124 },
    { key = "marketValue", label = "Market Value", source = "DBMarket", dataset = "market", width = 124 },
    { key = "marketValueRecent", label = "Recent Value", source = "DBRecent", dataset = "current", width = 124 },
    { key = "historical", label = "Historical Price", source = "DBHistorical", dataset = "historical", width = 132 },
    { key = "regionSaleRate", label = "Region sell rate", source = "DBRegionSaleRate", regional = true, width = 134 },
}
local CATALOG_TYPES = { ["catalog-mounts"] = true, ["catalog-pets"] = true, ["catalog-toys"] = true,
    ["catalog-recipes"] = true, ["catalog-cosmetics"] = true }

local function GetClass(item)
    if item.itemClassID then return tonumber(item.itemClassID), tonumber(item.itemSubclassID) end
    local get = C_Item and C_Item.GetItemInfoInstant or GetItemInfoInstant
    if type(get) == "function" then
        local ok, _, _, _, _, _, classID, subclassID = pcall(get, item.itemLink or item.itemID)
        if ok then return tonumber(classID), tonumber(subclassID) end
    end
end

function GoldTracker:IsItemRealmPriceType(item)
    if type(item) ~= "table" then return false end
    if CATALOG_TYPES[item.farmingSourceType] or item.petID or item.petSpeciesID
        or (type(item.itemLink) == "string" and item.itemLink:find("battlepet:", 1, true)) then return true end
    local classID, subclassID = GetClass(item)
    if classID == 2 or classID == 4 or classID == 17 or (classID == 15 and (subclassID == 2 or subclassID == 5)) then return true end
    if item.itemType == "Armor" or item.itemType == "Weapon" then return true end
    if C_ToyBox and type(C_ToyBox.GetToyInfo) == "function" and item.itemID then
        local ok, toyID = pcall(C_ToyBox.GetToyInfo, item.itemID)
        if ok and tonumber(toyID) and tonumber(toyID) > 0 then return true end
    end
    return false
end

-- Use level-specific equipment/pet keys where possible. Fallbacks are recorded
-- per cell so a base-item price is never presented as an exact variant price.
function GoldTracker:GetItemRealmPriceQueries(item)
    local link = type(item.itemLink) == "string" and item.itemLink or ""
    local species = tonumber(link:match("battlepet:(%d+)")) or tonumber(item.petID or item.petSpeciesID)
    if species then
        local base = "p:" .. math.floor(species)
        local level = tonumber(link:match("battlepet:%d+:(%d+)"))
        return level and level > 0 and { base .. ":i" .. level, base } or { base }
    end
    local id = tonumber(item.itemID) or tonumber(link:match("item:(%d+)"))
    if not id then return {} end
    local base = "i:" .. math.floor(id)
    if type(item.tsmItemString) == "string" and item.tsmItemString ~= base then
        return { item.tsmItemString, base }
    end
    local classID = GetClass(item)
    local level = tonumber(item.itemLevel)
    if not level and (classID == 2 or classID == 4) and link:find("|Hitem:", 1, true) then
        local get = C_Item and C_Item.GetDetailedItemLevelInfo or GetDetailedItemLevelInfo
        if type(get) == "function" then
            local ok, value = pcall(get, link)
            if ok then level = tonumber(value) end
        end
    end
    if (classID == 2 or classID == 4) and level and level > 0 then
        return { base .. "::i" .. math.floor(level), base }
    end
    return { base }
end

local function GetRegionSaleRate(queries)
    if type(TSM_API) ~= "table" or type(TSM_API.GetCustomPriceValue) ~= "function" then return nil end
    for _, query in ipairs(queries) do
        local ok, value = pcall(TSM_API.GetCustomPriceValue, "DBRegionSaleRate", query)
        if ok and type(value) == "number" and value >= 0 and value <= 1 then return value, query end
    end
end

function GoldTracker:BuildItemRealmPriceRows(item)
    local realms = type(self.GetCapturedTSMRealms) == "function" and self:GetCapturedTSMRealms() or {}
    local queries = self:GetItemRealmPriceQueries(item)
    local rows = {}
    -- This source is already available through TSM's public API. Read it once
    -- for the item; it is shared across rows, not a separate realm statistic.
    local saleRate, saleRateKey
    if #realms > 0 then saleRate, saleRateKey = GetRegionSaleRate(queries) end
    local currentRealm = type(GetRealmName) == "function" and GetRealmName() or nil
    for _, realm in ipairs(realms) do
        local row = { realm = realm, isCurrent = realm == currentRealm, values = {}, queryKeys = {}, timestamps = {}, requestedKey = queries[1] }
        for _, query in ipairs(queries) do
            local data = self:GetCapturedTSMRealmItemValues(realm, query)
            if data then
                for index = 2, #COLUMNS do
                    local column = COLUMNS[index]
                    local value = tonumber(data[column.key])
                    if not column.regional and not row.values[column.key] and value and value > 0 then
                        row.values[column.key] = value
                        row.queryKeys[column.key] = query
                        row.timestamps[column.key] = data.timestamps and data.timestamps[column.dataset]
                    end
                end
            end
            local complete = true
            for index = 2, #COLUMNS do
                if not COLUMNS[index].regional and not row.values[COLUMNS[index].key] then complete = false; break end
            end
            if complete then break end
        end
        row.values.regionSaleRate, row.queryKeys.regionSaleRate = saleRate, saleRateKey
        rows[#rows + 1] = row
    end
    table.sort(rows, function(a, b)
        if a.isCurrent ~= b.isCurrent then return a.isCurrent end
        return a.realm < b.realm
    end)
    return rows
end

local function Money(value)
    if not value or value <= 0 then return "--" end
    if type(GetMoneyString) == "function" then return GetMoneyString(value, true) end
    return string.format("%dg %ds %dc", math.floor(value / 10000), math.floor(value / 100) % 100, value % 100)
end

local function FormatValue(column, value)
    if column.regional then return value ~= nil and string.format("%.1f%%", value * 100) or "--" end
    return Money(value)
end

local function HideTooltip()
    if GameTooltip then GameTooltip:Hide() end
end

local function NewCell(parent, column)
    local cell = CreateFrame("Frame", nil, parent)
    cell:SetHeight(ROW_HEIGHT)
    local text = cell:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    text:SetPoint("LEFT", cell, "LEFT", 8, 0)
    text:SetPoint("RIGHT", cell, "RIGHT", -8, 0)
    text:SetJustifyH(column.key == "realm" and "LEFT" or "RIGHT")
    text:SetWordWrap(false)
    cell.text = text
    cell:EnableMouse(true)
    cell:SetScript("OnEnter", function(self)
        local row = self.rowData
        if not row or not GameTooltip then return end
        GameTooltip:SetOwner(self, "ANCHOR_TOP")
        GameTooltip:ClearLines()
        GameTooltip:AddLine(row.realm .. (row.isCurrent and " (current realm)" or ""), 1, 0.82, 0.18)
        if column.source then
            GameTooltip:AddDoubleLine(column.label, column.source, 0.72, 0.86, 1, 1, 1, 1)
            local value, stamp = row.values[column.key], row.timestamps[column.key]
            GameTooltip:AddLine(value ~= nil and FormatValue(column, value) or "No data available for this item.", 0.88, 0.92, 1)
            if column.regional then
                GameTooltip:AddLine("TSM average for your region, shared across rows. Realm-specific sale rates are not provided.", 0.72, 0.86, 1, true)
            end
            if row.queryKeys[column.key] then GameTooltip:AddLine("Item key: " .. row.queryKeys[column.key], 0.72, 0.86, 1) end
            if row.queryKeys[column.key] and row.queryKeys[column.key] ~= row.requestedKey then
                GameTooltip:AddLine("Base item/species price (variant unavailable).", 0.72, 0.86, 1)
            end
            if stamp and type(date) == "function" then GameTooltip:AddLine("Snapshot: " .. date("%Y-%m-%d %H:%M", stamp), 0.72, 0.86, 1) end
        end
        GameTooltip:Show()
    end)
    cell:SetScript("OnLeave", HideTooltip)
    return cell
end

function GoldTracker:CreateItemRealmPriceControls(frame)
    if frame.realmPricesPanel then return end
    local body = frame.bodyPanel
    local tabs = CreateFrame("Frame", nil, body)
    tabs:SetHeight(24)
    frame.detailsViewTabs = tabs
    frame.detailsViewButtons = {}
    for index, option in ipairs({ { "realms", "Realm prices" }, { "history", "Price history" } }) do
        local viewID = option[1]
        local button = Theme:CreateButton(tabs, 116, 24, option[2], "neutral")
        button:SetPoint("LEFT", tabs, "LEFT", (index - 1) * 122, 0)
        button:SetScript("OnClick", function()
            frame.detailsView = viewID
            GoldTracker:RefreshInventoryItemDetailsWindow()
        end)
        frame.detailsViewButtons[option[1]] = button
    end
    local panel = Theme:CreatePanel(body, { 0.03, 0.04, 0.06, 0.82 }, { 1, 0.82, 0.18, 0.10 })
    frame.realmPricesPanel = panel
    local title = panel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    title:SetPoint("TOPLEFT", 10, -10)
    title:SetText("TSM realm valuations")
    local setup = Theme:CreateButton(panel, 106, 22, "Realm setup", "neutral")
    setup:SetPoint("TOPRIGHT", panel, "TOPRIGHT", -10, -5)
    setup:SetScript("OnClick", function() GoldTracker:OpenTSMRealmSetupHelp() end)
    panel.setupButton = setup
    local realmCount = panel:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    realmCount:SetPoint("LEFT", title, "RIGHT", 12, 0)
    realmCount:SetPoint("RIGHT", setup, "LEFT", -10, 0)
    realmCount:SetJustifyH("RIGHT")
    realmCount:SetWordWrap(false)
    panel.realmCount = realmCount
    local status = panel:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    status:SetPoint("TOPLEFT", 10, -44)
    status:SetPoint("TOPRIGHT", -26, -44)
    status:SetJustifyH("LEFT")
    status:SetWordWrap(true)
    panel.status = status
    local footer = panel:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    footer:SetPoint("BOTTOMLEFT", 10, 6)
    footer:SetPoint("BOTTOMRIGHT", -10, 6)
    footer:SetHeight(32)
    footer:SetJustifyH("LEFT")
    footer:SetWordWrap(true)
    footer:SetTextColor(0.62, 0.66, 0.74)
    footer:SetText("Downloaded prices; -- means unavailable. Hover a value for its item key and snapshot time.")
    panel.footer = footer
    local scroll = CreateFrame("ScrollFrame", nil, panel, "UIPanelScrollFrameTemplate")
    scroll:SetPoint("TOPLEFT", 8, -32)
    scroll:SetPoint("BOTTOMRIGHT", -28, 58)
    panel.scroll = scroll
    local content = CreateFrame("Frame", nil, scroll)
    content:SetSize(1, 1)
    scroll:SetScrollChild(content)
    panel.content = content
    panel.headers, panel.rows = {}, {}
    for index, column in ipairs(COLUMNS) do
        local header = NewCell(content, column)
        header.text:SetText(column.label)
        header.text:SetTextColor(1, 0.82, 0.18)
        panel.headers[index] = header
    end
    local horizontal = CreateFrame("Slider", nil, panel)
    horizontal:SetPoint("BOTTOMLEFT", 10, 42)
    horizontal:SetPoint("BOTTOMRIGHT", -28, 42)
    horizontal:SetHeight(12)
    horizontal:SetOrientation("HORIZONTAL")
    horizontal:SetValueStep(1)
    horizontal:SetObeyStepOnDrag(true)
    horizontal:SetThumbTexture("Interface\\Buttons\\UI-ScrollBar-Knob")
    local track = horizontal:CreateTexture(nil, "BACKGROUND")
    track:SetAllPoints(horizontal)
    track:SetColorTexture(1, 1, 1, 0.08)
    horizontal:SetScript("OnValueChanged", function(_, value) scroll:SetHorizontalScroll(value) end)
    panel.horizontal = horizontal
    panel:Hide()
    tabs:Hide()
end

function GoldTracker:RefreshItemRealmPriceTable(frame)
    local panel, item = frame.realmPricesPanel, frame.itemData
    if not panel or not item then return end
    local revision = type(self.GetCapturedTSMRealmRevision) == "function" and self:GetCapturedTSMRealmRevision() or 0
    if panel.cachedItem ~= item or panel.cachedRevision ~= revision then
        panel.data = self:BuildItemRealmPriceRows(item)
        panel.cachedItem, panel.cachedRevision = item, revision
        panel.horizontal:SetValue(0)
        panel.scroll:SetVerticalScroll(0)
    end
    local data = panel.data
    panel.realmCount:SetText(#data == 1 and "1 realm available" or string.format("%d realms available", #data))
    panel.footer:SetText(#data == 1
        and "Compare more realms: add them in the TSM Desktop Application. Select Realm setup for instructions."
        or "Downloaded prices; -- means unavailable. Hover a value for its item key and snapshot time.")
    panel.status:SetShown(#data == 0)
    panel.scroll:SetShown(#data > 0)
    if #data == 0 then
        if self.tsmRealmCapture then
            panel.status:SetText("No realm prices captured yet. Add realms in the TSM Desktop Application, wait for their downloads, then reload. Select Realm setup for instructions.")
        else
            panel.status:SetText("Enable TSM Realm Prices (General Gold Tracker - TSM Realm Prices) in WoW's AddOns list, then reload. Select Realm setup for the TSM download steps.")
        end
    end
    for index, rowData in ipairs(data) do
        local row = panel.rows[index]
        if not row then
            row = CreateFrame("Frame", nil, panel.content)
            row:SetHeight(ROW_HEIGHT)
            row.cells = {}
            local background = row:CreateTexture(nil, "BACKGROUND")
            background:SetAllPoints(row)
            background:SetColorTexture(1, 1, 1, index % 2 == 0 and 0.045 or 0.022)
            for columnIndex, column in ipairs(COLUMNS) do row.cells[columnIndex] = NewCell(row, column) end
            panel.rows[index] = row
        end
        row.data = rowData
        row:Show()
        for columnIndex, column in ipairs(COLUMNS) do
            local cell = row.cells[columnIndex]
            cell.rowData = rowData
            cell.text:SetText(columnIndex == 1 and rowData.realm or FormatValue(column, rowData.values[column.key]))
            cell.text:SetTextColor(rowData.isCurrent and 1 or 0.88, rowData.isCurrent and 0.82 or 0.92, rowData.isCurrent and 0.18 or 1)
        end
    end
    for index = #data + 1, #panel.rows do panel.rows[index].data = nil; panel.rows[index]:Hide() end
    local widths, required = {}, 0
    for columnIndex, column in ipairs(COLUMNS) do
        local measured = { { text = panel.headers[columnIndex].text } }
        for index = 1, #data do measured[#measured + 1] = { text = panel.rows[index].cells[columnIndex].text } end
        widths[columnIndex] = Theme:GetRequiredTextColumnWidth(measured, "text", column.width, { padding = 16 })
        required = required + widths[columnIndex]
    end
    local viewport = math.max(1, panel.scroll:GetWidth())
    if required < viewport then widths[1] = widths[1] + viewport - required; required = viewport end
    panel.content:SetWidth(required)
    panel.content:SetHeight(HEADER_HEIGHT + #data * ROW_HEIGHT)
    local x = 0
    for columnIndex, width in ipairs(widths) do
        local header = panel.headers[columnIndex]
        header:ClearAllPoints()
        header:SetPoint("TOPLEFT", panel.content, "TOPLEFT", x, 0)
        header:SetWidth(width)
        for index = 1, #data do
            local row, cell = panel.rows[index], panel.rows[index].cells[columnIndex]
            row:ClearAllPoints()
            row:SetPoint("TOPLEFT", panel.content, "TOPLEFT", 0, -HEADER_HEIGHT - (index - 1) * ROW_HEIGHT)
            row:SetWidth(required)
            cell:ClearAllPoints()
            cell:SetPoint("LEFT", row, "LEFT", x, 0)
            cell:SetWidth(width)
        end
        x = x + width
    end
    local range = math.max(0, required - viewport)
    panel.horizontal:SetMinMaxValues(0, range)
    panel.horizontal:SetShown(#data > 0 and range > 0)
    local value = math.min(range, panel.horizontal:GetValue() or 0)
    panel.horizontal:SetValue(value)
    panel.scroll:SetHorizontalScroll(value)
    panel.scroll:UpdateScrollChildRect()
end

function GoldTracker:ClearItemRealmPriceTable(frame)
    local panel = frame.realmPricesPanel
    if not panel then return end
    panel.data, panel.cachedItem, panel.cachedRevision = nil, nil, nil
    for _, row in ipairs(panel.rows) do
        row.data = nil
        for _, cell in ipairs(row.cells) do cell.rowData = nil; cell.text:SetText("") end
        row:Hide()
    end
end

function GoldTracker:RefreshItemRealmPriceView(frame, topOffset)
    if not frame.realmPricesPanel then return topOffset end
    local eligible = self:IsItemRealmPriceType(frame.itemData)
    local realms = eligible and frame.detailsView ~= "history"
    frame.detailsViewTabs:SetShown(eligible)
    frame.detailsViewTabs:ClearAllPoints()
    frame.detailsViewTabs:SetPoint("TOPLEFT", frame.bodyPanel, "TOPLEFT", 14, topOffset)
    frame.detailsViewTabs:SetPoint("TOPRIGHT", frame.bodyPanel, "TOPRIGHT", -14, topOffset)
    for key, button in pairs(frame.detailsViewButtons) do button:SetPalette(key == (realms and "realms" or "history") and "primary" or "neutral") end
    frame.realmPricesPanel:SetShown(realms)
    frame.graphPanel:SetShown(not realms)
    frame.statsPanel:SetShown(not realms)
    frame.sourceLabel:SetShown(not realms)
    frame.sourceDropdown:SetShown(not realms)
    local contentTop = topOffset - (eligible and 30 or 0)
    -- History needs room for its graph and bottom statistics even when a rare
    -- source list is present. The realm view can instead scroll at small sizes.
    local minimumHeight = eligible and not realms and math.max(460, 66 - contentTop + 144 + 160) or 460
    if frame.SetResizeBounds then frame:SetResizeBounds(640, minimumHeight, 1040, 820) end
    if frame.GetHeight and frame.SetHeight and frame:GetHeight() < minimumHeight then frame:SetHeight(minimumHeight) end
    frame.realmPricesPanel:ClearAllPoints()
    frame.realmPricesPanel:SetPoint("TOPLEFT", frame.bodyPanel, "TOPLEFT", 14, contentTop)
    frame.realmPricesPanel:SetPoint("BOTTOMRIGHT", frame.bodyPanel, "BOTTOMRIGHT", -14, 14)
    if realms then
        self:RefreshItemRealmPriceTable(frame)
    elseif not eligible then
        self:ClearItemRealmPriceTable(frame)
    end
    return contentTop
end
