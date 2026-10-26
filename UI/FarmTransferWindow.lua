local _, NS = ...
local function CreateFrame(...)
    return (NS.CreateThemedFrame or _G.CreateFrame)(...)
end
local GoldTracker, Theme = NS.GoldTracker, NS.JanisTheme

function GoldTracker:CreateFarmTransferWindow()
    if self.farmTransferFrame then return end
    local frame = CreateFrame("Frame", "GoldTrackerFarmTransferFrame", UIParent)
    self.farmTransferFrame = frame
    frame:SetSize(780, 520)
    frame:SetPoint("CENTER")
    frame:SetFrameStrata("FULLSCREEN_DIALOG")
    frame:SetMovable(true)
    frame:SetClampedToScreen(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
    frame:Hide()
    local chrome = Theme:ApplyWindowChrome(frame, "Farm export / import")
    Theme:RegisterSpecialFrame("GoldTrackerFarmTransferFrame")

    local status = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    status:SetPoint("TOPLEFT", chrome, "TOPLEFT", 14, -88)
    status:SetPoint("TOPRIGHT", chrome, "TOPRIGHT", -14, -88)
    status:SetJustifyH("LEFT")
    status:SetWordWrap(true)
    frame.status = status
    local panel = Theme:CreatePanel(frame, "panel", "chromeBorder")
    panel:SetPoint("TOPLEFT", chrome, "TOPLEFT", 14, -128)
    panel:SetPoint("BOTTOMRIGHT", chrome, "BOTTOMRIGHT", -14, 52)
    local scroll = CreateFrame("ScrollFrame", nil, panel, "UIPanelScrollFrameTemplate")
    scroll:SetPoint("TOPLEFT", 12, -10)
    scroll:SetPoint("BOTTOMRIGHT", -28, 10)
    frame.scroll = scroll
    local content = CreateFrame("Frame", nil, scroll)
    content:SetSize(1, 1)
    scroll:SetScrollChild(content)
    local edit = CreateFrame("EditBox", nil, content)
    edit:SetMultiLine(true)
    edit:SetAutoFocus(false)
    edit:SetMaxLetters(0)
    edit:SetFontObject("GameFontHighlightSmall")
    edit:SetPoint("TOPLEFT")
    edit:SetPoint("TOPRIGHT")
    frame.editBox = edit
    local function ResizeText()
        local width = math.max(1, scroll:GetWidth() - 4)
        content:SetWidth(width)
        edit:SetWidth(width)
        local _, fontHeight = edit:GetFont()
        local height = math.max(scroll:GetHeight(), edit:GetNumLines() * (fontHeight + edit:GetSpacing()) + 24)
        edit:SetHeight(height)
        content:SetHeight(height)
    end
    scroll:SetScript("OnSizeChanged", ResizeText)
    edit:SetScript("OnTextChanged", function()
        ResizeText()
        if frame.importMode then frame.importButton:SetEnabled(edit:GetText():find("%S") ~= nil) end
    end)
    edit:SetScript("OnEscapePressed", function() frame:Hide() end)
    frame:SetScript("OnHide", function() edit:ClearFocus() end)

    frame.exportFarmButton = Theme:CreateButton(frame, 120, 24, "Export farm", "neutral")
    frame.exportFarmButton:SetPoint("TOPLEFT", chrome, "TOPLEFT", 14, -54)
    frame.exportFarmButton:SetScript("OnClick", function() self:ShowCustomFarmExport(frame.selectedFarmID) end)
    frame.exportAllButton = Theme:CreateButton(frame, 120, 24, "Export all", "neutral")
    frame.exportAllButton:SetPoint("LEFT", frame.exportFarmButton, "RIGHT", 8, 0)
    frame.exportAllButton:SetScript("OnClick", function() self:ShowCustomFarmExport(nil) end)
    frame.importModeButton = Theme:CreateButton(frame, 120, 24, "Import string", "neutral")
    frame.importModeButton:SetPoint("LEFT", frame.exportAllButton, "RIGHT", 8, 0)
    frame.importModeButton:SetScript("OnClick", function()
        frame.importMode = true
        edit:SetText("")
        frame.importButton:Show()
        frame.importButton:SetEnabled(false)
        status:SetText("Paste a farm string, then click Import farms. Farms are added as new copies; existing farms are kept.")
        edit:SetFocus()
        scroll:SetVerticalScroll(0)
    end)
    frame.importButton = Theme:CreateButton(frame, 130, 24, "Import farms", "primary")
    frame.importButton:SetPoint("BOTTOMRIGHT", chrome, "BOTTOMRIGHT", -14, 14)
    frame.importButton:SetScript("OnClick", function()
        local result, message = self:ImportCustomFarmString(edit:GetText())
        if result then
            status:SetText(string.format("Imported %d farm%s as new copies.", result.count, result.count == 1 and "" or "s"))
            frame.importButton:SetEnabled(false)
            frame.selectedFarmID = result.farms[1].id
            frame.exportFarmButton:SetEnabled(true)
            frame.exportAllButton:SetEnabled(true)
        else
            status:SetText(message)
        end
    end)
    local close = Theme:CreateButton(frame, 90, 24, "Close", "neutral")
    close:SetPoint("BOTTOMLEFT", chrome, "BOTTOMLEFT", 14, 14)
    close:SetScript("OnClick", function() frame:Hide() end)
    frame.ResizeText = ResizeText
end

function GoldTracker:ShowCustomFarmExport(farmID)
    local frame = self.farmTransferFrame
    frame.importMode = false
    frame.importButton:Hide()
    local text, message = self:BuildCustomFarmExport(farmID)
    frame.editBox:SetText(text or "")
    frame.status:SetText(text and "Complete farm data, maps, routes, and route plans. Copy the entire string with Ctrl+A, Ctrl+C."
        or message)
    frame.scroll:SetVerticalScroll(0)
    if text then frame.editBox:SetFocus(); frame.editBox:HighlightText() end
end

function GoldTracker:OpenFarmTransferWindow(farmID)
    self:CreateFarmTransferWindow()
    local frame = self.farmTransferFrame
    frame.selectedFarmID = farmID
    frame.exportFarmButton:SetEnabled(self:GetCustomFarmByID(farmID) ~= nil)
    frame.exportAllButton:SetEnabled(#self:GetCustomFarms() > 0)
    frame:Show()
    frame:Raise()
    if farmID and self:GetCustomFarmByID(farmID) then self:ShowCustomFarmExport(farmID)
    else frame.importModeButton:GetScript("OnClick")() end
    frame.ResizeText()
end
