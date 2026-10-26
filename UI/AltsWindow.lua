local _, NS = ...
local function CreateFrame(...)
    return (NS.CreateThemedFrame or _G.CreateFrame)(...)
end
local GoldTracker = NS.GoldTracker
local Theme = NS.JanisTheme
local CHARACTER_ROW_HEIGHT, CHARACTER_LINE_SPACING, CHARACTER_DETAILS_TOP = 90, 18, 48

local function Text(parent, font, color)
    local text = parent:CreateFontString(nil, "OVERLAY", font or "GameFontHighlightSmall")
    text:SetJustifyH("LEFT")
    if color then text:SetTextColor(unpack(color)) end
    return text
end

local function CharacterAssignmentKey(label)
    return label:gsub("%s+", ""):lower()
end

local function BuildAssignedFarms(addon)
    local assignments = {}
    for _, farm in ipairs(addon:GetCustomFarms()) do
        if farm.assignedCharacter then
            local key = CharacterAssignmentKey(farm.assignedCharacter)
            assignments[key] = assignments[key] or {}
            assignments[key][#assignments[key] + 1] = farm
        end
    end
    for _, farms in pairs(assignments) do
        table.sort(farms, function(a, b)
            if a.name ~= b.name then return a.name < b.name end
            return a.id < b.id
        end)
    end
    return assignments
end

function GoldTracker:OpenAltAssignedFarm(guid, farmID)
    local character = self:GetAltCharacters()[guid]
    local farm = self:GetCustomFarmByID(farmID)
    if not character or not farm or not farm.assignedCharacter then return false end
    local label = character.name .. (character.realm and ("-" .. character.realm) or "")
    if CharacterAssignmentKey(label) ~= CharacterAssignmentKey(farm.assignedCharacter) then return false end
    return self:OpenCustomFarmConfiguration(farm.id)
end

function GoldTracker:ShowAltAssignedFarms(row)
    local character = self:GetAltCharacters()[row.guid]
    if not character then return end
    local label = character.name .. (character.realm and ("-" .. character.realm) or "")
    local farms = BuildAssignedFarms(self)[CharacterAssignmentKey(label)] or {}
    if #farms == 1 then return self:OpenAltAssignedFarm(row.guid, farms[1].id) end
    if #farms == 0 then return end
    local frame = self.altsFrame
    if not frame.farmDropdown then
        frame.farmDropdown = CreateFrame("Frame", "GoldTrackerAltAssignedFarmDropdown", frame, "UIDropDownMenuTemplate")
        frame.farmDropdown:Hide()
        UIDropDownMenu_Initialize(frame.farmDropdown, function(_, level)
            local dropdown = frame.farmDropdown
            local guid = dropdown.guid
            for _, farm in ipairs(dropdown.farms or {}) do
                local info, farmID = UIDropDownMenu_CreateInfo(), farm.id
                info.text, info.notCheckable = farm.name, true
                info.func = function() self:OpenAltAssignedFarm(guid, farmID) end
                UIDropDownMenu_AddButton(info, level)
            end
        end, "MENU")
    end
    frame.farmDropdown.guid, frame.farmDropdown.farms = row.guid, farms
    ToggleDropDownMenu(1, nil, frame.farmDropdown, row.farmButton, 0, 0)
end

function GoldTracker:ShowAltCharacterRoles()
    local frame = self.altsFrame
    if not frame or frame.selectedContinentID or not self:GetAltCharacters()[frame.selectedGUID] then return end
    if not frame.roleDropdown then
        frame.roleDropdown = CreateFrame("Frame", "GoldTrackerAltRoleDropdown", frame, "UIDropDownMenuTemplate")
        frame.roleDropdown:Hide()
        UIDropDownMenu_Initialize(frame.roleDropdown, function(_, level)
            local guid = frame.roleDropdown.guid
            for _, option in ipairs(self:GetAltCharacterRoleOptions()) do
                local info, roleID = UIDropDownMenu_CreateInfo(), option.id
                info.text, info.isNotRadio, info.keepShownOnClick = option.label, true, true
                info.checked = function()
                    local character = self:GetAltCharacters()[guid]
                    return character and type(character.roles) == "table" and character.roles[roleID] == true or false
                end
                info.func = function() self:SetAltCharacterRole(guid, roleID, not info.checked()) end
                UIDropDownMenu_AddButton(info, level)
            end
            local clear = UIDropDownMenu_CreateInfo()
            clear.text, clear.notCheckable = "Clear roles", true
            clear.func = function() self:ClearAltCharacterRoles(guid) end
            UIDropDownMenu_AddButton(clear, level)
        end, "MENU")
    end
    frame.roleDropdown.guid = frame.selectedGUID
    ToggleDropDownMenu(1, nil, frame.roleDropdown, frame.roleButton, 0, 0)
end

local function RenderCharacterPins(card, width, height)
    local groups, byPosition, nameCounts = {}, {}, {}
    for _, data in ipairs(card.characterLocations) do
        if data.name then nameCounts[data.name] = (nameCounts[data.name] or 0) + 1 end
        local key = string.format("%.4f:%.4f", data.x, data.y)
        local group = byPosition[key]
        if not group then
            group = { x = data.x, y = data.y, characters = {} }
            groups[#groups + 1], byPosition[key] = group, group
        end
        group.characters[#group.characters + 1] = data
    end
    for index, group in ipairs(groups) do
        local marker = card.characterPins[index]
        if not marker then
            marker = CreateFrame("Frame", nil, card.canvas)
            marker:SetSize(28, 28)
            marker.icon = marker:CreateTexture(nil, "OVERLAY", nil, 7)
            marker.icon:SetAtlas("waypoint-mappin-minimap-tracked")
            marker.icon:SetAllPoints(marker)
            marker.caption = Theme:CreatePanel(marker, { 0.025, 0.03, 0.04, 0.7 }, { 1, 0.82, 0.18, 0.12 })
            marker.entries = {}
            card.characterPins[index] = marker
        end
        marker:ClearAllPoints()
        local px, py = group.x * width, group.y * height
        if card.ProjectPoint then px, py = card:ProjectPoint(group.x, group.y) end
        marker:SetPoint("CENTER", card.canvas, "TOPLEFT", px, -py)
        marker.caption:ClearAllPoints()
        if px > width * 0.65 then
            marker.caption:SetPoint("RIGHT", marker, "LEFT", -6, 0)
        else
            marker.caption:SetPoint("LEFT", marker, "RIGHT", 6, 0)
        end
        for _, entry in ipairs(marker.entries) do entry:Hide() end
        local captionWidth, offset = 0, 4
        for entryIndex, data in ipairs(group.characters) do
            local entry = marker.entries[entryIndex]
            if not entry then
                entry = CreateFrame("Frame", nil, marker.caption)
                entry.label = Text(entry, "GameFontHighlight")
                entry.label:SetFont(STANDARD_TEXT_FONT or "Fonts\\FRIZQT__.TTF", 13, "OUTLINE")
                entry.label:SetPoint("TOPLEFT")
                entry.professionIcons = {}
                for professionIndex = 1, 2 do
                    local icon = entry:CreateTexture(nil, "ARTWORK")
                    icon:SetSize(16, 16)
                    icon:SetPoint("TOPLEFT", 19 * (professionIndex - 1), -17)
                    entry.professionIcons[professionIndex] = icon
                end
                marker.entries[entryIndex] = entry
            end
            entry.label:SetText(data.name and nameCounts[data.name] == 1 and data.name or data.label)
            local professionCount = 0
            for professionIndex, icon in ipairs(entry.professionIcons) do
                local profession = data.professions and data.professions[professionIndex]
                if profession and profession.icon then
                    icon:SetTexture(profession.icon)
                    icon:Show()
                    professionCount = professionCount + 1
                else
                    icon:Hide()
                end
            end
            local entryHeight = professionCount > 0 and 33 or 16
            captionWidth = math.max(captionWidth, entry.label:GetStringWidth(), professionCount * 19)
            entry:ClearAllPoints()
            entry:SetPoint("TOPLEFT", marker.caption, "TOPLEFT", 4, -offset)
            entry:SetPoint("TOPRIGHT", marker.caption, "TOPRIGHT", -4, -offset)
            entry:SetHeight(entryHeight)
            entry:Show()
            offset = offset + entryHeight + 4
        end
        marker.caption:SetSize(captionWidth + 8, offset)
        marker:SetShown(px >= 0 and px <= width and py >= 0 and py <= height)
    end
end

function GoldTracker:RenderAltMapCharacterPins(card)
    RenderCharacterPins(card, card.view.width, card.view.height)
end

local function RenderExploredTiles(card, tileWidth, tileHeight, scale)
    local index = 0
    for _, overlay in ipairs(card.exploredTextures or {}) do
        local width, height = overlay.textureWidth or 0, overlay.textureHeight or 0
        if width > 0 and height > 0 and not overlay.isShownByMouseOver then
            local columns = math.ceil(width / tileWidth)
            for row = 0, math.ceil(height / tileHeight) - 1 do
                for col = 0, columns - 1 do
                    local fileID = overlay.fileDataIDs and overlay.fileDataIDs[row * columns + col + 1]
                    if fileID then
                        index = index + 1
                        local tile = card.exploredTiles[index]
                        if not tile then
                            tile = card.canvas:CreateTexture(nil, "ARTWORK", nil, 1)
                            card.exploredTiles[index] = tile
                        end
                        local pixelWidth = math.min(tileWidth, width - col * tileWidth)
                        local pixelHeight = math.min(tileHeight, height - row * tileHeight)
                        local fileWidth, fileHeight = 16, 16
                        while fileWidth < pixelWidth do fileWidth = fileWidth * 2 end
                        while fileHeight < pixelHeight do fileHeight = fileHeight * 2 end
                        tile:SetDrawLayer("ARTWORK", overlay.isDrawOnTopLayer and 2 or 1)
                        tile:SetTexture(fileID, nil, nil, "TRILINEAR")
                        tile:SetTexCoord(0, pixelWidth / fileWidth, 0, pixelHeight / fileHeight)
                        tile:ClearAllPoints()
                        tile:SetPoint("TOPLEFT", card.canvas, "TOPLEFT",
                            ((overlay.offsetX or 0) + col * tileWidth) * scale,
                            -((overlay.offsetY or 0) + row * tileHeight) * scale)
                        tile:SetSize(pixelWidth * scale, pixelHeight * scale)
                        tile:Show()
                    end
                end
            end
        end
    end
end

local function RenderMap(card)
    card.hasMapArt = false
    for _, tile in ipairs(card.tiles) do tile:Hide() end
    for _, tile in ipairs(card.exploredTiles) do tile:Hide() end
    for _, marker in ipairs(card.characterPins) do marker:Hide() end
    card.pin:Hide()
    card.message:SetText(card.mapID and "Map art unavailable" or card.emptyText)
    card.message:Show()
    if not card.mapID or not C_Map or not C_Map.GetMapArtLayers or not C_Map.GetMapArtLayerTextures then return end
    local layers = C_Map.GetMapArtLayers(card.mapID)
    local layer = layers and layers[1]
    local textures = layer and C_Map.GetMapArtLayerTextures(card.mapID, 1)
    if not layer or not textures or #textures == 0 then return end
    local width, height = layer.layerWidth, layer.layerHeight
    if not width or not height or width <= 0 or height <= 0 then return end
    local scale = math.min(math.max(1, card.viewport:GetWidth()) / width, math.max(1, card.viewport:GetHeight()) / height)
    card.canvas:SetSize(width * scale, height * scale)
    local tw, th = layer.tileWidth or 256, layer.tileHeight or 256
    local index = 0
    for row = 0, math.ceil(height / th) - 1 do
        for col = 0, math.ceil(width / tw) - 1 do
            index = index + 1
            if textures[index] then
                local tile = card.tiles[index]
                if not tile then
                    tile = card.canvas:CreateTexture(nil, "ARTWORK")
                    card.tiles[index] = tile
                end
                local tileWidth, tileHeight = math.min(tw, width - col * tw), math.min(th, height - row * th)
                tile:SetTexture(textures[index])
                tile:SetTexCoord(0, tileWidth / tw, 0, tileHeight / th)
                tile:ClearAllPoints()
                tile:SetPoint("TOPLEFT", card.canvas, "TOPLEFT", col * tw * scale, -row * th * scale)
                tile:SetSize(tileWidth * scale, tileHeight * scale)
                tile:Show()
            end
        end
    end
    RenderExploredTiles(card, tw, th, scale)
    card.hasMapArt = true
    card.message:Hide()
    if card.characterLocations then
        RenderCharacterPins(card, width * scale, height * scale)
        if #card.characterLocations == 0 then
            card.message:SetText("No recorded character positions on this map")
            card.message:Show()
        end
    elseif card.x and card.y then
        card.pin:ClearAllPoints()
        card.pin:SetPoint("CENTER", card.canvas, "TOPLEFT", card.x * width * scale, -card.y * height * scale)
        card.pin:Show()
    else
        card.message:SetText("Precise position unavailable on this map")
        card.message:Show()
    end
end

local function CreateMapCard(parent, heading)
    local card = Theme:CreatePanel(parent, "panel", "chromeBorder")
    card.tiles, card.exploredTiles, card.characterPins = {}, {}, {}
    card.heading = Text(card, "GameFontNormal")
    card.heading:SetPoint("TOPLEFT", 12, -10)
    card.heading:SetPoint("TOPRIGHT", -12, -10)
    card.heading:SetText(heading)
    card.viewport = CreateFrame("Frame", nil, card)
    card.viewport:SetPoint("TOPLEFT", 10, -32)
    card.viewport:SetPoint("BOTTOMRIGHT", -10, 28)
    card.canvas = CreateFrame("Frame", nil, card.viewport)
    card.canvas:SetPoint("CENTER")
    card.pin = card.canvas:CreateTexture(nil, "OVERLAY", nil, 7)
    card.pin:SetAtlas("waypoint-mappin-minimap-tracked")
    card.pin:SetSize(28, 28)
    card.message = Text(card, "GameFontHighlightSmall")
    card.message:SetPoint("CENTER", card.viewport, "CENTER")
    card.message:SetWidth(260)
    card.message:SetJustifyH("CENTER")
    card.coordinates = Text(card, "GameFontHighlightSmall", { 0.65, 0.68, 0.73 })
    card.coordinates:SetPoint("BOTTOMLEFT", 12, 10)
    card.viewport:SetScript("OnSizeChanged", function() RenderMap(card) end)
    return card
end

local function SetMap(card, heading, mapID, x, y, emptyText, exploredTextures, characterLocations)
    card.mapID, card.x, card.y, card.emptyText = mapID, x, y, emptyText
    card.exploredTextures = exploredTextures
    card.characterLocations = characterLocations
    card.heading:SetText(heading)
    card.coordinates:SetText(x and y and string.format("%.2f, %.2f", x * 100, y * 100) or "")
    RenderMap(card)
end

-- Shared with the destination picker; map art is loaded only when a card is used.
function GoldTracker:CreateAltMapCard(parent, heading)
    return CreateMapCard(parent, heading)
end

function GoldTracker:SetAltMapCard(card, heading, mapID, x, y, emptyText, exploredTextures)
    SetMap(card, heading, mapID, x, y, emptyText, exploredTextures)
end

local function LayoutAltMaps(frame, continentView)
    frame.localMap:ClearAllPoints()
    frame.localMap:SetPoint("TOPLEFT", 0, continentView and -100 or -216)
    frame.localMap:SetPoint("BOTTOMRIGHT", 0, 20)
    frame.destinationPanel:SetShown(not continentView)
end

local function ConfigureInteractiveAltMap(addon, frame, character, overview)
    local location = character and character.location
    local mapID = overview and overview.mapID or location and location.mapID
    local continentID = overview and overview.mapID or location and location.continentMapID
    local records, revisions = {}, {}
    if character then
        records[1] = character
    elseif overview then
        for guid, record in pairs(addon:GetAltCharacters()) do
            if record.location and record.location.continentMapID == continentID then
                records[#records + 1] = record
                revisions[#revisions + 1] = guid .. ":" .. (record.mapExplorationRevision or 0)
            end
        end
        table.sort(revisions)
    end
    local function savedArt(id)
        for _, record in ipairs(records) do
            if record.mapArtSnapshots and record.mapArtSnapshots[id] then return record.mapArtSnapshots[id] end
        end
    end
    frame.localMap:SetSubject({
        key = overview and ("continent:" .. mapID) or ("character:" .. tostring(frame.selectedGUID) .. ":" .. tostring(mapID)),
        revision = character and character.mapExplorationRevision or table.concat(revisions, ","),
        mapID = mapID, continentMapID = continentID,
        heading = overview and ("Continent · " .. overview.name) or ("Location · " .. (location and location.mapName or "Unknown")),
        x = location and location.x, y = location and location.y,
        pins = overview and overview.pins,
        coordinateText = overview and (#overview.pins .. " / " .. overview.characterCount .. " character locations recorded"),
        renderPins = function(card) RenderCharacterPins(card, card.view.width, card.view.height) end,
        getArt = savedArt, revealAll = true,
        emptyText = mapID and "Map art unavailable" or "No saved location yet",
    })
end

function GoldTracker:ShowAltContinentMap(continentMapID)
    local frame = self.altsFrame
    if not frame then return end
    if self.altDestinationPicker then self.altDestinationPicker:Hide() end
    if type(CloseDropDownMenus) == "function" then CloseDropDownMenus() end
    if not self.altTrackerLeavingWorld then self:CaptureCurrentAlt(true, nil, true) end
    frame.selectedContinentID = continentMapID
    self:RefreshAltsWindow()
    -- A group Map click opens the whole continent, including when it is already
    -- selected and the shared viewport was left zoomed into one of its zones.
    if frame.selectedContinentID == continentMapID then frame.localMap:Reset() end
end

function GoldTracker:RefreshAltsWindowLayout()
    local frame = self.altsFrame
    if not frame then return end
    frame.content:SetWidth(math.max(1, frame.scrollFrame:GetWidth()))
    frame.localMap:Resize()
end

local function RefreshDestinationPanel(addon, frame, character)
    local destination = character and character.destination
    local panel = frame.destinationPanel
    panel.destination:SetText(destination and string.format("Destination: %s  ·  %.2f, %.2f",
        destination.mapName or "Unknown map", destination.x * 100, destination.y * 100)
        or "Destination: Free roam")
    local text, r, g, b = addon:GetAltDestinationStatusText(frame.selectedGUID)
    panel.status:SetText(text)
    panel.status:SetTextColor(r, g, b)
    panel.setButton:SetEnabled(character ~= nil)
    panel.clearButton:SetShown(destination ~= nil)
    panel.clearButton:SetEnabled(destination ~= nil)
    local online = character ~= nil and frame.selectedGUID == addon.currentAltGUID
    panel.navigateButton:SetText(online and "Navigate" or "Show on map")
    panel.navigateButton:SetShown(destination ~= nil)
    panel.navigateButton:SetEnabled(destination ~= nil and (not online or not addon.altTrackerLeavingWorld))
    panel.refreshButton:ClearAllPoints()
    panel.refreshButton:SetPoint("LEFT", destination and panel.clearButton or panel.setButton, "RIGHT", 6, 0)
    panel.refreshButton:SetEnabled(online and not addon.altTrackerLeavingWorld)
end

local function CancelContinentDrag(frame)
    frame.draggingContinentID, frame.dropBeforeContinentID, frame.continentDropValid = nil, nil, nil
    frame:SetScript("OnUpdate", nil)
    frame.continentDragPreview:Hide()
    frame.continentDropIndicator:Hide()
end

local function UpdateContinentDrag(frame, elapsed)
    frame.continentDropValid = false
    frame.continentDropIndicator:Hide()
    if type(GetCursorPosition) ~= "function" then return end
    local scroll = frame.scrollFrame
    local cursorX, cursorY = GetCursorPosition()
    local left, top = scroll:GetLeft(), scroll:GetTop()
    if not cursorX or not cursorY or not left or not top then return end
    local scale = scroll:GetEffectiveScale()
    local x, y = cursorX / scale - left, top - cursorY / scale
    frame.continentDragPreview:ClearAllPoints()
    frame.continentDragPreview:SetPoint("TOPLEFT", scroll, "TOPLEFT", x + 12, -y - 12)
    local width, height = scroll:GetWidth(), scroll:GetHeight()
    local scrollY = scroll:GetVerticalScroll()
    if x >= 0 and x <= width and y >= -24 and y <= height + 24 then
        local direction = y < 24 and -1 or (y > height - 24 and 1 or 0)
        if direction ~= 0 and elapsed > 0 then
            local maximum = math.max(0, frame.content:GetHeight() - height)
            scrollY = math.max(0, math.min(maximum, scrollY + direction * elapsed * 260))
            scroll:SetVerticalScroll(scrollY)
        end
    end
    if x < 0 or x > width or y < 0 or y > height then return end
    local beforeID, lineY = nil, frame.content:GetHeight() - 24
    for _, header in ipairs(frame.continentHeaders) do
        if y + scrollY < header.groupOffset + header:GetHeight() / 2 then
            beforeID, lineY = header.continentGroupID, header.groupOffset - 2
            break
        end
    end
    frame.dropBeforeContinentID, frame.continentDropValid = beforeID, true
    local indicator = frame.continentDropIndicator
    indicator:ClearAllPoints()
    indicator:SetPoint("TOPLEFT", frame.content, "TOPLEFT", 0, -math.max(0, lineY))
    indicator:SetPoint("TOPRIGHT", frame.content, "TOPRIGHT", 0, -math.max(0, lineY))
    indicator:Show()
end

function GoldTracker:StartAltContinentDrag(row)
    local frame = self.altsFrame
    if not frame or not row.continentGroupID or #frame.continentHeaders < 2 then return end
    CancelContinentDrag(frame)
    if type(CloseDropDownMenus) == "function" then CloseDropDownMenus() end
    if GameTooltip then GameTooltip:Hide() end
    row.continentDragStarted = true
    frame.draggingContinentID = row.continentGroupID
    frame.continentDragPreview.text:SetText(row.continentGroupName)
    frame.continentDragPreview:SetWidth(frame.continentDragPreview.text:GetStringWidth() + 20)
    frame.continentDragPreview:Show()
    UpdateContinentDrag(frame, 0)
    frame:SetScript("OnUpdate", function(_, elapsed)
        if type(IsMouseButtonDown) == "function" and not IsMouseButtonDown("LeftButton") then
            self:FinishAltContinentDrag()
        else
            UpdateContinentDrag(frame, elapsed)
        end
    end)
end

function GoldTracker:FinishAltContinentDrag()
    local frame = self.altsFrame
    if not frame or not frame.draggingContinentID then return end
    UpdateContinentDrag(frame, 0)
    local groupID, beforeID, valid = frame.draggingContinentID, frame.dropBeforeContinentID, frame.continentDropValid
    CancelContinentDrag(frame)
    if valid and self:MoveAltContinentGroup(groupID, beforeID) then self:RefreshAltsWindow() end
end

function GoldTracker:RefreshAltsWindow(refreshCurrentLocation)
    local frame = self.altsFrame
    if not frame then return end
    CancelContinentDrag(frame)
    if refreshCurrentLocation and not self.altTrackerLeavingWorld
        and (not frame.selectedGUID or frame.selectedGUID == self.currentAltGUID) then
        self:CaptureCurrentAlt(true, nil, true)
    end
    local groups = self:BuildAltCharacterGroups()
    local characters = self:GetAltCharacters()
    local assignedFarms = BuildAssignedFarms(self)
    if not characters[frame.selectedGUID] then
        frame.selectedGUID = characters[self.currentAltGUID] and self.currentAltGUID
            or (groups[1] and groups[1].characters[1].guid)
    end
    for _, row in ipairs(frame.rows) do row:Hide() end
    frame.continentHeaders = {}
    local rowIndex, offset, count = 0, 0, 0
    local function NextRow()
        rowIndex = rowIndex + 1
        local row = frame.rows[rowIndex]
        if not row then
            row = Theme:CreateButton(frame.content, 190, 44, "", "neutral")
            row.label:Hide()
            row.name = Text(row, "GameFontHighlight")
            row.name:SetPoint("TOPLEFT", 10, -7)
            row.name:SetPoint("TOPRIGHT", -10, -7)
            row.realm = Text(row, "GameFontHighlightSmall", { 0.6, 0.64, 0.7 })
            row.realm:SetPoint("TOPLEFT", row, "TOPLEFT", 10, -30)
            row.realm:SetPoint("TOPRIGHT", row, "TOPRIGHT", -10, -30)
            row.realm:SetWordWrap(false)
            row.roles = Text(row, "GameFontHighlightSmall", { 1, 0.82, 0.3 })
            row.roles:SetPoint("TOPLEFT", row, "TOPLEFT", 10, -CHARACTER_DETAILS_TOP)
            row.roles:SetPoint("TOPRIGHT", row, "TOPRIGHT", -10, -CHARACTER_DETAILS_TOP)
            row.roles:SetWordWrap(false)
            row.farm = Text(row, "GameFontHighlightSmall")
            row.farm:SetWordWrap(false)
            row.farmButton = Theme:CreateButton(row, 42, 18, "Edit", "neutral")
            row.farmButton:SetScript("OnClick", function() self:ShowAltAssignedFarms(row) end)
            row.destination = Text(row, "GameFontHighlightSmall")
            row.destination:SetWordWrap(false)
            row.professionIcons = {}
            for index = 1, 2 do
                local icon = row:CreateTexture(nil, "ARTWORK")
                icon:SetSize(20, 20)
                icon:SetPoint("TOPRIGHT", row, "TOPRIGHT", -10 - (2 - index) * 26, -7)
                row.professionIcons[index] = icon
            end
            row.mapButton = Theme:CreateButton(row, 42, 22, "Map", "neutral")
            row.mapButton:SetPoint("RIGHT", row, "RIGHT", -5, 0)
            row.mapButton:SetScript("OnClick", function()
                if row.continentMapID then self:ShowAltContinentMap(row.continentMapID) end
            end)
            row.collapseButton = Theme:CreateButton(row, 22, 22, "-", "neutral")
            row.collapseButton:SetPoint("LEFT", row, "LEFT", 5, 0)
            local function ToggleGroup()
                local groupID = row.continentGroupID
                if groupID == nil then return end
                frame.collapsedContinents[groupID] = not frame.collapsedContinents[groupID]
                self:RefreshAltsWindow()
            end
            row.collapseButton:SetScript("OnClick", ToggleGroup)
            row:RegisterForDrag("LeftButton")
            row:HookScript("OnMouseDown", function() row.continentDragStarted = nil end)
            row:SetScript("OnDragStart", function() self:StartAltContinentDrag(row) end)
            row:SetScript("OnDragStop", function() self:FinishAltContinentDrag() end)
            row:SetScript("OnClick", function()
                if row.continentDragStarted then return end
                if row.continentGroupID ~= nil then
                    ToggleGroup()
                    return
                end
                if row.guid then
                    if self.altDestinationPicker then self.altDestinationPicker:Hide() end
                    if type(CloseDropDownMenus) == "function" then CloseDropDownMenus() end
                    frame.selectedContinentID = nil
                    frame.selectedGUID = row.guid
                    self:RefreshAltsWindow(true)
                end
            end)
            frame.rows[rowIndex] = row
        end
        row:ClearAllPoints()
        row:SetPoint("TOPLEFT", 0, -offset)
        row:SetPoint("TOPRIGHT", 0, -offset)
        row.name:ClearAllPoints()
        row.name:SetPoint("TOPLEFT", row, "TOPLEFT", 10, -7)
        row.name:SetPoint("TOPRIGHT", row, "TOPRIGHT", -10, -7)
        row.name:SetJustifyH("LEFT")
        row.name:SetWordWrap(false)
        row.name:SetFontObject("GameFontHighlight")
        for _, icon in ipairs(row.professionIcons) do icon:Hide() end
        row.continentMapID = nil
        row.continentGroupID = nil
        row.continentGroupName = nil
        row.tooltipText = nil
        row.roles:Hide()
        row.farm:Hide()
        row.farmButton:Hide()
        row.destination:Hide()
        row.mapButton:Hide()
        row.collapseButton:Hide()
        row:Show()
        return row
    end
    for _, group in ipairs(groups) do
        local header = NextRow()
        local collapsed = frame.collapsedContinents[group.id] == true
        count = count + #group.characters
        header.guid = nil
        header.continentGroupID = group.id
        header.continentGroupName, header.groupOffset = group.name, offset
        header.tooltipText = "Click to expand or collapse. Drag to reorder groups."
        frame.continentHeaders[#frame.continentHeaders + 1] = header
        header.collapseButton.label:SetText(collapsed and "+" or "-")
        header.collapseButton.tooltipText = (collapsed and "Expand " or "Collapse ") .. group.name
        header.collapseButton:Show()
        header:SetHeight(44)
        header:SetEnabled(true)
        header:SetSelected(group.id == frame.selectedContinentID)
        header.name:SetText(group.name .. "  (" .. #group.characters .. ")")
        header.name:SetFontObject("GameFontNormal")
        header.name:SetJustifyH("CENTER")
        header.name:SetWordWrap(true)
        header.name:ClearAllPoints()
        header.name:SetPoint("LEFT", header, "LEFT", 34, 0)
        header.name:SetPoint("RIGHT", header, "RIGHT", -10, 0)
        header.name:SetTextColor(1, 0.82, 0.3)
        if type(group.id) == "number" then
            header.continentMapID = group.id
            header.mapButton:Show()
            header.name:SetPoint("RIGHT", header, "RIGHT", -53, 0)
        end
        header.realm:Hide()
        offset = offset + 48
        for _, entry in ipairs(not collapsed and group.characters or {}) do
            local row, character = NextRow(), entry.character
            local roleLabels = self:GetAltCharacterRoles(entry.guid)
            local roleOffset = #roleLabels > 0 and CHARACTER_LINE_SPACING or 0
            local farmTop = CHARACTER_DETAILS_TOP + roleOffset
            local destinationTop = farmTop + CHARACTER_LINE_SPACING
            row.guid = entry.guid
            row:SetHeight(CHARACTER_ROW_HEIGHT + roleOffset)
            if roleOffset > 0 then
                row.roles:SetText(table.concat(roleLabels, " · "))
                row.roles:Show()
            end
            row.farm:ClearAllPoints()
            row.farm:SetPoint("TOPLEFT", row, "TOPLEFT", 10, -farmTop)
            row.farm:SetPoint("TOPRIGHT", row, "TOPRIGHT", -10, -farmTop)
            row.farmButton:ClearAllPoints()
            row.farmButton:SetPoint("TOPRIGHT", row, "TOPRIGHT", -5, 3 - farmTop)
            row.destination:ClearAllPoints()
            row.destination:SetPoint("TOPLEFT", row, "TOPLEFT", 10, -destinationTop)
            row.destination:SetPoint("TOPRIGHT", row, "TOPRIGHT", -10, -destinationTop)
            row:SetEnabled(true)
            row:SetSelected(not frame.selectedContinentID and entry.guid == frame.selectedGUID)
            row.name:SetText(character.name)
            local hasProfessions = false
            for index = 1, 2 do
                local profession = character.professions and character.professions[index]
                if profession and profession.icon then
                    row.professionIcons[index]:SetTexture(profession.icon)
                    row.professionIcons[index]:Show()
                    hasProfessions = true
                end
            end
            if hasProfessions then
                row.name:SetPoint("TOPRIGHT", row, "TOPRIGHT", -66, -7)
            end
            local color = RAID_CLASS_COLORS and RAID_CLASS_COLORS[character.classFile]
            row.name:SetTextColor(color and color.r or 0.9, color and color.g or 0.92, color and color.b or 0.98)
            local levelText = character.level and ("Level " .. character.level .. " · ") or ""
            row.realm:SetText(levelText .. (character.realm or "Unknown realm"))
            row.realm:Show()
            local label = (character.name or "") .. (character.realm and ("-" .. character.realm) or "")
            local farms = assignedFarms[CharacterAssignmentKey(label)] or {}
            local farmNames = {}
            for _, farm in ipairs(farms) do farmNames[#farmNames + 1] = farm.name end
            if #farmNames > 0 then
                row.farm:SetText(#farmNames == 1 and ("Farm: " .. farmNames[1])
                    or ("Farms: " .. #farmNames .. " assigned"))
                row.farm:SetTextColor(1, 0.82, 0.3)
                row.tooltipText = "Assigned farms\n" .. table.concat(farmNames, "\n")
                row.farm:SetPoint("TOPRIGHT", row, "TOPRIGHT", -53, -farmTop)
                row.farmButton.tooltipText = #farms == 1 and ("Edit farm: " .. farmNames[1])
                    or "Choose an assigned farm to edit."
                row.farmButton:Show()
            else
                row.farm:SetText("No farm assigned")
                row.farm:SetTextColor(0.6, 0.64, 0.7)
            end
            row.farm:Show()
            local statusText, r, g, b = self:GetAltDestinationStatusText(entry.guid)
            row.destination:SetText(statusText)
            row.destination:SetTextColor(r, g, b)
            row.destination:Show()
            if character.destination then
                local destination = character.destination
                local description = string.format("Destination: %s · %.2f, %.2f\n%s",
                    destination.mapName or "Unknown map", destination.x * 100, destination.y * 100, statusText)
                row.tooltipText = row.tooltipText and (row.tooltipText .. "\n\n" .. description) or description
            end
            offset = offset + 84 + roleOffset
        end
        offset = offset + 24
    end
    frame.content:SetHeight(math.max(1, offset))
    frame.listTitle:SetText("Characters  (" .. count .. ")")
    frame.roleButton:Hide()
    if frame.selectedContinentID then
        local overview = self:BuildAltContinentMap(frame.selectedContinentID)
        if overview then
            LayoutAltMaps(frame, true)
            frame.characterTitle:SetText(overview.name)
            frame.locationText:SetText(overview.characterCount .. " characters · Last recorded locations")
            for _, tag in ipairs(frame.professionTags) do tag:Hide() end
            frame.noProfessions:Hide()
            ConfigureInteractiveAltMap(self, frame, nil, overview)
            frame.localMap.coordinates:SetText(#overview.pins .. " / " .. overview.characterCount .. " character locations recorded")
            frame.hint:SetText(self.db.enableExperimentalMaps == true
                and "Explore this continent, or select a character to start at its recorded location."
                or "Select a character to view its recorded zone.")
            self:RefreshAltsWindowLayout()
            return
        end
        frame.selectedContinentID = nil
    end
    LayoutAltMaps(frame, false)
    local character = characters[frame.selectedGUID]
    if character then
        local roleLabels = self:GetAltCharacterRoles(frame.selectedGUID)
        frame.roleButton.label:SetText(#roleLabels > 0 and ("Roles (" .. #roleLabels .. ")") or "Roles")
        frame.roleButton.tooltipText = #roleLabels > 0 and ("Roles: " .. table.concat(roleLabels, ", "))
            or "Mark this character as Main, Bank, or Other. You can select several roles."
        frame.roleButton:Show()
    end
    RefreshDestinationPanel(self, frame, character)
    local location = character and character.location
    if character and frame.selectedGUID == self.currentAltGUID and not self.altTrackerLeavingWorld then
        self:CaptureAltMapExploration(character)
    end
    frame.hint:SetText("Locations are recorded at login and logout.")
    local levelText = character and character.level and ("Level " .. character.level .. "  ·  ") or ""
    frame.characterTitle:SetText(character and (character.name .. "  ·  " .. levelText .. (character.realm or "")) or "Your characters")
    if location then
        local stamp = location.savedAt and date("%d %b %Y, %H:%M", location.savedAt) or "Unknown"
        frame.locationText:SetText((location.mapName or "Unknown location") .. "  ·  Last recorded: " .. stamp
            .. (character.locationUnavailable and "  (last known location)" or ""))
    else
        frame.locationText:SetText(character and "Location unavailable. A position will be saved at logout."
            or "Log in to each character to add them here.")
    end
    local previous
    for index, tag in ipairs(frame.professionTags) do
        local profession = character and character.professions and character.professions[index]
        tag:ClearAllPoints()
        if previous then tag:SetPoint("LEFT", previous, "RIGHT", 8, 0)
        else tag:SetPoint("TOPLEFT", frame.detailsPanel, "TOPLEFT", 12, -60) end
        if profession then
            tag.text:SetText(profession.name)
            tag:SetWidth(tag.text:GetStringWidth() + 38)
            tag.icon:SetTexture(profession.icon)
            tag:Show()
            previous = tag
        else
            tag:Hide()
        end
    end
    frame.noProfessions:SetShown(character ~= nil and not previous)
    frame.noProfessions:SetText(character and character.professions and "No primary professions" or "Professions not recorded yet")
    ConfigureInteractiveAltMap(self, frame, character)
    self:RefreshAltsWindowLayout()
end

function GoldTracker:CreateAltsWindow()
    if self.altsFrame then return end
    local frame = CreateFrame("Frame", nil, self.explorerFrame.contentFrame)
    frame:Hide()
    self.altsFrame = frame
    frame:SetScript("OnHide", function()
        CancelContinentDrag(frame)
        if self.altDestinationPicker then self.altDestinationPicker:Hide() end
        if type(CloseDropDownMenus) == "function" then CloseDropDownMenus() end
    end)
    if type(self.db.altCollapsedGroups) ~= "table" then
        self.db.altCollapsedGroups = { lowLevel = true }
    end
    frame.rows, frame.professionTags, frame.continentHeaders = {}, {}, {}
    frame.collapsedContinents = self.db.altCollapsedGroups
    frame.globalMapButton = Theme:CreateButton(frame, 140, 28, "Global Map", "primary")
    frame.globalMapButton:SetPoint("TOPRIGHT", 0, 0)
    frame.globalMapButton.tooltipText = "Explore Azeroth, Outland, Draenor, and Shadowlands with your characters' recorded locations."
    frame.globalMapButton:SetScript("OnClick", function() self:OpenAltsGlobalMapWindow() end)
    frame.listPanel = Theme:CreatePanel(frame, "panel", "chromeBorder")
    frame.listPanel:SetPoint("TOPLEFT", 0, -38)
    frame.listPanel:SetPoint("BOTTOMLEFT")
    frame.listPanel:SetWidth(230)
    frame.listTitle = Text(frame.listPanel, "GameFontNormal")
    frame.listTitle:SetPoint("TOPLEFT", 12, -12)
    frame.scrollFrame = CreateFrame("ScrollFrame", nil, frame.listPanel, "UIPanelScrollFrameTemplate")
    frame.scrollFrame:SetPoint("TOPLEFT", 8, -38)
    frame.scrollFrame:SetPoint("BOTTOMRIGHT", -28, 12)
    frame.content = CreateFrame("Frame", nil, frame.scrollFrame)
    frame.content:SetSize(190, 1)
    frame.scrollFrame:SetScrollChild(frame.content)
    frame.scrollFrame:SetScript("OnSizeChanged", function(_, width) frame.content:SetWidth(math.max(1, width)) end)
    frame.continentDropIndicator = CreateFrame("Frame", nil, frame.content)
    frame.continentDropIndicator:SetHeight(3)
    frame.continentDropIndicator:SetFrameLevel(frame.scrollFrame:GetFrameLevel() + 10)
    frame.continentDropIndicator:EnableMouse(false)
    frame.continentDropIndicator.texture = frame.continentDropIndicator:CreateTexture(nil, "OVERLAY")
    frame.continentDropIndicator.texture:SetAllPoints()
    frame.continentDropIndicator.texture:SetColorTexture(1, 0.82, 0.3, 1)
    frame.continentDropIndicator:Hide()
    frame.continentDragPreview = Theme:CreatePanel(frame.listPanel, "header", "chromeBorder")
    frame.continentDragPreview:SetHeight(26)
    frame.continentDragPreview:SetFrameLevel(frame.scrollFrame:GetFrameLevel() + 20)
    frame.continentDragPreview:EnableMouse(false)
    frame.continentDragPreview.text = Text(frame.continentDragPreview, "GameFontNormal")
    frame.continentDragPreview.text:SetPoint("LEFT", 10, 0)
    frame.continentDragPreview.text:SetPoint("RIGHT", -10, 0)
    frame.continentDragPreview:Hide()
    frame.detailsPanel = CreateFrame("Frame", nil, frame)
    frame.detailsPanel:SetPoint("TOPLEFT", frame.listPanel, "TOPRIGHT", 12, 0)
    frame.detailsPanel:SetPoint("BOTTOMRIGHT")
    frame.characterTitle = Text(frame.detailsPanel, "GameFontNormalLarge")
    frame.characterTitle:SetPoint("TOPLEFT", 12, -10)
    frame.characterTitle:SetPoint("TOPRIGHT", -108, -10)
    frame.roleButton = Theme:CreateButton(frame.detailsPanel, 88, 22, "Roles", "neutral")
    frame.roleButton:SetPoint("TOPRIGHT", -12, -7)
    frame.roleButton:SetScript("OnClick", function() self:ShowAltCharacterRoles() end)
    frame.locationText = Text(frame.detailsPanel, "GameFontHighlightSmall", { 0.65, 0.68, 0.73 })
    frame.locationText:SetPoint("TOPLEFT", 12, -34)
    frame.locationText:SetPoint("TOPRIGHT", -12, -34)
    for index = 1, 2 do
        local tag = Theme:CreatePanel(frame.detailsPanel, "header", "chromeBorder")
        tag:SetHeight(26)
        tag.icon = tag:CreateTexture(nil, "ARTWORK")
        tag.icon:SetSize(18, 18)
        tag.icon:SetPoint("LEFT", 5, 0)
        tag.text = Text(tag, "GameFontHighlightSmall")
        tag.text:SetPoint("LEFT", tag.icon, "RIGHT", 5, 0)
        frame.professionTags[index] = tag
    end
    frame.noProfessions = Text(frame.detailsPanel, "GameFontHighlightSmall", { 0.65, 0.68, 0.73 })
    frame.noProfessions:SetPoint("TOPLEFT", 12, -66)
    frame.destinationPanel = Theme:CreatePanel(frame.detailsPanel, "panel", "chromeBorder")
    local panel = frame.destinationPanel
    panel:SetPoint("TOPLEFT", 0, -96)
    panel:SetPoint("TOPRIGHT", 0, -96)
    panel:SetHeight(108)
    panel.destination = Text(panel, "GameFontNormal")
    panel.destination:SetPoint("TOPLEFT", 12, -10)
    panel.destination:SetPoint("TOPRIGHT", -12, -10)
    panel.destination:SetWordWrap(false)
    panel.status = Text(panel, "GameFontHighlightSmall")
    panel.status:SetPoint("TOPLEFT", 12, -32)
    panel.status:SetPoint("TOPRIGHT", -12, -32)
    panel.setButton = Theme:CreateButton(panel, 120, 24, "Set destination", "neutral")
    panel.setButton:SetPoint("TOPLEFT", 12, -60)
    panel.setButton:SetScript("OnClick", function() self:ShowAltDestinationPicker(frame.selectedGUID) end)
    panel.navigateButton = Theme:CreateButton(panel, 108, 24, "Navigate", "neutral")
    panel.navigateButton:SetPoint("LEFT", panel.setButton, "RIGHT", 6, 0)
    panel.navigateButton:SetScript("OnClick", function()
        if frame.selectedGUID ~= self.currentAltGUID then
            self:ShowAltDestinationPicker(frame.selectedGUID)
        else
            local _, message = self:NavigateToAltDestination(frame.selectedGUID)
            frame.hint:SetText(message)
        end
    end)
    panel.clearButton = Theme:CreateButton(panel, 58, 24, "Clear", "neutral")
    panel.clearButton:SetPoint("LEFT", panel.navigateButton, "RIGHT", 6, 0)
    panel.clearButton:SetScript("OnClick", function() self:ClearAltDestination(frame.selectedGUID) end)
    panel.refreshButton = Theme:CreateButton(panel, 120, 24, "Refresh location", "neutral")
    panel.refreshButton:SetPoint("LEFT", panel.clearButton, "RIGHT", 6, 0)
    panel.refreshButton:SetScript("OnClick", function() self:RefreshAltsWindow(true) end)
    frame.localMap = self:CreateInteractiveMapCard(frame.detailsPanel, "Location")
    frame.localMap:SetPoint("TOPLEFT", 0, -100)
    frame.localMap:SetPoint("BOTTOMRIGHT", 0, 20)
    frame.hint = Text(frame.detailsPanel, "GameFontHighlightSmall", { 0.5, 0.54, 0.6 })
    frame.hint:SetPoint("BOTTOMLEFT", 2, 2)
    frame.hint:SetText("Locations are recorded at login and logout.")
    frame:SetScript("OnSizeChanged", function() self:RefreshAltsWindowLayout() end)
end
