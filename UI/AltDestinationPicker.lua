local _, NS = ...
local function CreateFrame(...)
    return (NS.CreateThemedFrame or _G.CreateFrame)(...)
end
local GoldTracker = NS.GoldTracker
local Theme = NS.JanisTheme
local COSMIC_MAP_ID = 946

local function Text(parent, font)
    return parent:CreateFontString(nil, "OVERLAY", font or "GameFontHighlightSmall")
end

local function Children(mapID, mapType)
    if not C_Map or not C_Map.GetMapChildrenInfo then return {} end
    local ok, children = pcall(C_Map.GetMapChildrenInfo, mapID, mapType, true)
    if not ok or type(children) ~= "table" then return {} end
    table.sort(children, function(a, b)
        if a.name ~= b.name then return a.name < b.name end
        return a.mapID < b.mapID
    end)
    return children
end

local function MapLabel(info)
    if not info then return "Choose a zone" end
    local parent = C_Map and C_Map.GetMapInfo and C_Map.GetMapInfo(info.parentMapID)
    return parent and parent.mapType >= 3 and (info.name .. " · " .. parent.name) or info.name
end

local function PointFromFields(frame)
    local x, y = tonumber(frame.xInput:GetText()), tonumber(frame.yInput:GetText())
    if not x or not y or x ~= x or y ~= y or x < 0 or x > 100 or y < 0 or y > 100 then return end
    return x / 100, y / 100
end

local function GetPickerExploration(addon, guid, mapID)
    local character = addon:GetAltCharacters()[guid]
    local saved = character and character.exploredMaps and character.exploredMaps[mapID]
    if guid ~= addon.currentAltGUID and type(saved) == "table" and #saved > 0 then return saved end
    if not addon.altTrackerLeavingWorld and C_MapExplorationInfo and C_MapExplorationInfo.GetExploredMapTextures then
        local ok, textures = pcall(C_MapExplorationInfo.GetExploredMapTextures, mapID)
        if ok and type(textures) == "table" and #textures > 0 then return textures end
    end
    return saved or {}
end

function GoldTracker:RefreshAltDestinationPickerPoint()
    local frame = self.altDestinationPicker
    if not frame or frame.updatingFields then return end
    local x, y = PointFromFields(frame)
    frame.saveButton:SetEnabled(frame.mapID ~= nil and x ~= nil)
    if frame.explorationMapID ~= frame.mapID then
        frame.explorationMapID = frame.mapID
        frame.exploredTextures = frame.mapID and GetPickerExploration(self, frame.guid, frame.mapID) or nil
    end
    self:SetAltMapCard(frame.map, frame.mapName or "Destination map", frame.mapID, x, y,
        "Choose a zone to view its map.", frame.exploredTextures)
end

function GoldTracker:SelectAltDestinationPickerMap(mapID, x, y)
    local frame = self.altDestinationPicker
    if type(mapID) ~= "number" or mapID <= 0 then return false end
    local info = C_Map and C_Map.GetMapInfo and C_Map.GetMapInfo(mapID)
    if not frame or not info or not info.mapType or info.mapType < 3 then return false end
    frame.mapID, frame.mapName = mapID, info.name
    local hierarchy = self:GetAltMapHierarchy(mapID)
    frame.continentID = hierarchy.continentMapID
    local continent = frame.continentID and C_Map.GetMapInfo(frame.continentID)
    UIDropDownMenu_SetText(frame.continentDropdown, continent and continent.name or "Other maps")
    frame.zoneButton:SetText(MapLabel(info))
    frame.zoneButton.tooltipText = MapLabel(info)
    if frame.zoneListPanel then frame.zoneListPanel:Hide() end
    frame.updatingFields = true
    frame.xInput:SetText(x and string.format("%.4f", x * 100) or "")
    frame.yInput:SetText(y and string.format("%.4f", y * 100) or "")
    frame.updatingFields = nil
    frame.status:SetText("Click the map or enter coordinates, then save.")
    self:RefreshAltDestinationPickerPoint()
    return true
end

function GoldTracker:ChooseAltDestinationPickerPoint(x, y)
    local frame = self.altDestinationPicker
    if not frame or not frame.mapID or x < 0 or x > 1 or y < 0 or y > 1 then return false end
    return self:SelectAltDestinationPickerMap(frame.mapID, x, y)
end

function GoldTracker:UseCurrentAltDestinationPosition()
    local frame = self.altDestinationPicker
    if not frame or frame.guid ~= self.currentAltGUID or self.altTrackerLeavingWorld then return false end
    local character = self:CaptureCurrentAlt(true, nil, true)
    local position = character and not character.locationUnavailable and character.location
    if not position then
        frame.status:SetText("Your current position is unavailable. Try again after leaving this area.")
        return false
    end
    local selected = self:SelectAltDestinationPickerMap(position.mapID, position.x, position.y)
    if not selected then frame.status:SetText("Your current zone map is unavailable. Choose a zone manually.") end
    return selected
end

function GoldTracker:SaveAltDestinationPicker()
    local frame = self.altDestinationPicker
    if not frame then return false end
    local x, y = PointFromFields(frame)
    local saved, message = self:SetAltDestination(frame.guid, frame.mapID, x, y)
    if saved then frame:Hide() else frame.status:SetText(message) end
    return saved
end

function GoldTracker:RefreshAltDestinationZones()
    local frame = self.altDestinationPicker
    if not frame or not frame.zoneListPanel then return end
    local query = frame.zoneSearch:GetText():lower()
    local index = 0
    for _, row in ipairs(frame.zoneRows) do row:Hide() end
    for _, zone in ipairs(frame.zoneOptions or {}) do
        local label = MapLabel(zone)
        if (zone.mapType == 3 or zone.mapType == 5) and label:lower():find(query, 1, true) then
            index = index + 1
            local row = frame.zoneRows[index]
            if not row then
                row = Theme:CreateButton(frame.zoneContent, 240, 26, "", "neutral")
                row:SetScript("OnClick", function() self:SelectAltDestinationPickerMap(row.mapID) end)
                frame.zoneRows[index] = row
            end
            row.mapID, row.tooltipText = zone.mapID, label
            row:SetText(label)
            row:ClearAllPoints()
            row:SetPoint("TOPLEFT", 0, -(index - 1) * 30)
            row:SetPoint("TOPRIGHT", 0, -(index - 1) * 30)
            row:Show()
        end
    end
    frame.zoneEmpty:SetShown(index == 0)
    frame.zoneContent:SetHeight(math.max(1, index * 30))
    frame.zoneScroll:SetVerticalScroll(0)
end

function GoldTracker:CreateAltDestinationPicker()
    if self.altDestinationPicker then return end
    local parent = self.altsFrame.detailsPanel
    local frame = Theme:CreatePanel(parent, "panel", "chromeBorder")
    self.altDestinationPicker = frame
    frame:SetAllPoints(parent)
    frame:SetFrameLevel(parent:GetFrameLevel() + 20)
    frame:EnableMouse(true)
    frame:Hide()
    frame.title = Text(frame, "GameFontNormalLarge")
    frame.title:SetPoint("TOPLEFT", 12, -12)
    frame.title:SetPoint("TOPRIGHT", -90, -12)
    frame.title:SetJustifyH("LEFT")
    local cancel = Theme:CreateButton(frame, 68, 24, "Cancel", "neutral")
    frame.cancelButton = cancel
    cancel:SetPoint("TOPRIGHT", -12, -10)
    cancel:SetScript("OnClick", function() frame:Hide() end)
    frame:SetScript("OnHide", function()
        frame.xInput:ClearFocus()
        frame.yInput:ClearFocus()
        if type(CloseDropDownMenus) == "function" then CloseDropDownMenus() end
    end)

    frame.continentDropdown = CreateFrame("Frame", "GoldTrackerAltDestinationContinentDropdown", frame, "UIDropDownMenuTemplate")
    frame.continentDropdown:SetPoint("TOPLEFT", -4, -44)
    UIDropDownMenu_SetWidth(frame.continentDropdown, 174)
    UIDropDownMenu_Initialize(frame.continentDropdown, function(_, level)
        for _, continent in ipairs(frame.continents or {}) do
            local info = UIDropDownMenu_CreateInfo()
            local id = continent.mapID
            info.text, info.checked = continent.name, frame.continentID == id
            info.func = function()
                frame.continentID, frame.mapID, frame.mapName = id, nil, nil
                UIDropDownMenu_SetText(frame.continentDropdown, continent.name)
                frame.zoneButton:SetText("Choose a zone")
                frame.zoneButton.tooltipText = nil
                frame.zoneListPanel:Hide()
                frame.zoneOptions = nil
                frame.updatingFields = true
                frame.xInput:SetText("")
                frame.yInput:SetText("")
                frame.updatingFields = nil
                self:RefreshAltDestinationPickerPoint()
            end
            UIDropDownMenu_AddButton(info, level)
        end
    end)
    frame.zoneButton = Theme:CreateButton(frame, 250, 24, "Choose a zone", "neutral")
    frame.zoneButton:SetPoint("TOPLEFT", 212, -46)
    frame.zoneButton:SetPoint("TOPRIGHT", -12, -46)
    frame.zoneButton:SetScript("OnClick", function()
        frame.zoneOptions = Children(frame.continentID or COSMIC_MAP_ID)
        frame.zoneSearch:SetText("")
        self:RefreshAltDestinationZones()
        frame.zoneListPanel:Show()
        frame.zoneSearch:SetFocus()
    end)
    local hint = Text(frame)
    hint:SetPoint("TOPLEFT", 12, -82)
    hint:SetPoint("TOPRIGHT", -12, -82)
    hint:SetJustifyH("LEFT")
    hint:SetText("Choose a continent and zone, then click the destination on the map.")
    frame.map = self:CreateAltMapCard(frame, "Destination map")
    frame.map:SetPoint("TOPLEFT", 12, -108)
    frame.map:SetPoint("BOTTOMRIGHT", -12, 106)
    frame.zoneListPanel = Theme:CreatePanel(frame, "panel", "chromeBorder")
    frame.zoneListPanel:SetAllPoints(frame.map)
    frame.zoneListPanel:SetFrameLevel(frame:GetFrameLevel() + 10)
    frame.zoneListPanel:EnableMouse(true)
    frame.zoneListPanel:Hide()
    local searchLabel = Text(frame.zoneListPanel)
    searchLabel:SetPoint("TOPLEFT", 12, -14)
    searchLabel:SetText("Search zones:")
    frame.zoneSearch = CreateFrame("EditBox", nil, frame.zoneListPanel, "InputBoxTemplate")
    frame.zoneSearch:SetPoint("TOPLEFT", 112, -8)
    frame.zoneSearch:SetPoint("TOPRIGHT", -12, -8)
    frame.zoneSearch:SetHeight(24)
    frame.zoneSearch:SetAutoFocus(false)
    frame.zoneSearch:SetScript("OnTextChanged", function() self:RefreshAltDestinationZones() end)
    frame.zoneSearch:SetScript("OnEscapePressed", function() frame.zoneListPanel:Hide() end)
    frame.zoneListPanel:SetScript("OnHide", function() frame.zoneSearch:ClearFocus() end)
    frame.zoneScroll = CreateFrame("ScrollFrame", nil, frame.zoneListPanel, "UIPanelScrollFrameTemplate")
    frame.zoneScroll:SetPoint("TOPLEFT", 12, -42)
    frame.zoneScroll:SetPoint("BOTTOMRIGHT", -28, 12)
    frame.zoneContent = CreateFrame("Frame", nil, frame.zoneScroll)
    frame.zoneContent:SetSize(240, 1)
    frame.zoneScroll:SetScrollChild(frame.zoneContent)
    frame.zoneScroll:SetScript("OnSizeChanged", function(_, width) frame.zoneContent:SetWidth(math.max(1, width)) end)
    frame.zoneRows = {}
    frame.zoneEmpty = Text(frame.zoneListPanel)
    frame.zoneEmpty:SetPoint("CENTER")
    frame.zoneEmpty:SetText("No matching zones")
    frame.map.viewport:EnableMouse(true)
    frame.map.viewport:SetScript("OnMouseUp", function(_, button)
        if button ~= "LeftButton" or not frame.map.hasMapArt then return end
        local canvas = frame.map.canvas
        local cursorX, cursorY = GetCursorPosition()
        local scale, left, top = canvas:GetEffectiveScale(), canvas:GetLeft(), canvas:GetTop()
        if not left or not top or not scale or scale <= 0 then return end
        self:ChooseAltDestinationPickerPoint((cursorX / scale - left) / canvas:GetWidth(),
            (top - cursorY / scale) / canvas:GetHeight())
    end)
    for index, axis in ipairs({ "x", "y" }) do
        local label = Text(frame)
        label:SetPoint("BOTTOMLEFT", 12 + (index - 1) * 124, 80)
        label:SetText(axis:upper() .. ":")
        local input = CreateFrame("EditBox", nil, frame, "InputBoxTemplate")
        input:SetSize(82, 24)
        input:SetPoint("BOTTOMLEFT", 36 + (index - 1) * 124, 72)
        input:SetAutoFocus(false)
        input:SetMaxLetters(10)
        input:SetScript("OnTextChanged", function() self:RefreshAltDestinationPickerPoint() end)
        input:SetScript("OnEscapePressed", function() frame:Hide() end)
        input:SetScript("OnEnterPressed", function() self:SaveAltDestinationPicker() end)
        frame[axis .. "Input"] = input
    end
    frame.xInput:SetScript("OnTabPressed", function() frame.yInput:SetFocus() end)
    frame.yInput:SetScript("OnTabPressed", function() frame.xInput:SetFocus() end)
    frame.status = Text(frame)
    frame.status:SetPoint("BOTTOMLEFT", 12, 46)
    frame.status:SetPoint("BOTTOMRIGHT", -12, 46)
    frame.status:SetJustifyH("LEFT")
    frame.currentButton = Theme:CreateButton(frame, 160, 24, "Use current position", "neutral")
    frame.currentButton:SetPoint("BOTTOMLEFT", 12, 12)
    frame.currentButton:SetScript("OnClick", function() self:UseCurrentAltDestinationPosition() end)
    frame.saveButton = Theme:CreateButton(frame, 142, 24, "Save destination", "neutral")
    frame.saveButton:SetPoint("BOTTOMRIGHT", -12, 12)
    frame.saveButton:SetScript("OnClick", function() self:SaveAltDestinationPicker() end)
end

function GoldTracker:ShowAltDestinationPicker(guid)
    local character = self:GetAltCharacters()[guid]
    if not character or not self.altsFrame then return false end
    self:CreateAltDestinationPicker()
    local frame = self.altDestinationPicker
    frame.guid, frame.mapID, frame.mapName, frame.continentID = guid, nil, nil, nil
    frame.explorationMapID, frame.exploredTextures = nil, nil
    frame.zoneOptions = nil
    frame.zoneListPanel:Hide()
    -- Enumerate maps only on demand; this does not access any farming catalogs.
    frame.continents = Children(COSMIC_MAP_ID, 2)
    frame.title:SetText("Destination · " .. character.name)
    frame.currentButton:SetEnabled(guid == self.currentAltGUID and not self.altTrackerLeavingWorld)
    local initial = character.destination or character.location
    local initialized = initial and self:SelectAltDestinationPickerMap(initial.mapID,
        character.destination and initial.x or nil, character.destination and initial.y or nil)
    if not initialized then
        UIDropDownMenu_SetText(frame.continentDropdown, "Choose a continent")
        frame.zoneButton:SetText("Choose a zone")
        frame.zoneButton.tooltipText = nil
        frame.updatingFields = true
        frame.xInput:SetText("")
        frame.yInput:SetText("")
        frame.updatingFields = nil
        frame.status:SetText("Choose a zone, then select a destination.")
        self:RefreshAltDestinationPickerPoint()
    end
    frame:Show()
    -- The viewport has its final dimensions only after showing the overlay.
    self:RefreshAltDestinationPickerPoint()
    return true
end
