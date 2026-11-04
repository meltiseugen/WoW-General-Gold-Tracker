local _, NS = ...
local addon, Theme = NS.GoldTracker, NS.JanisTheme
local function CreateFrame(...)
    return (NS.CreateThemedFrame or _G.CreateFrame)(...)
end

function addon:RefreshAltsGlobalMapWindow()
    local frame = self.altsGlobalMapFrame
    if not frame then return end
    local overview = self:BuildAltGlobalMap(frame.selectedWorldID)
    if not overview then return end
    for _, button in ipairs(frame.worldTabs) do button:SetSelected(button.worldID == overview.mapID) end
    local countText = string.format("%d / %d character locations recorded", #overview.pins, overview.characterCount)
    if overview.missingPositionCount > 0 then countText = countText .. " · Some recorded positions are unavailable" end
    frame.map:SetSubject({ key = "global:" .. overview.mapID, mapID = overview.mapID, continentMapID = overview.mapID,
        includeContinents = true, revealAll = true, heading = overview.name, pins = overview.pins,
        coordinateText = countText, emptyText = "Map art unavailable",
        renderPins = function(card) self:RenderAltMapCharacterPins(card) end,
    })
end

function addon:SelectAltsGlobalMapWorld(worldID)
    local frame = self.altsGlobalMapFrame
    if not frame then return end
    local valid = false
    for _, world in ipairs(self:GetAltGlobalMapWorlds()) do if world.id == worldID then valid = true; break end end
    if not valid then return end
    frame.selectedWorldID = worldID
    self:RefreshAltsGlobalMapWindow()
    frame.map:Reset()
end

function addon:CreateAltsGlobalMapWindow()
    if self.altsGlobalMapFrame then return end
    local frame = CreateFrame("Frame", "GoldTrackerAltsGlobalMapFrame", UIParent)
    self.altsGlobalMapFrame = frame
    local width, height = math.min(1200, UIParent:GetWidth() * 0.92), math.min(820, UIParent:GetHeight() * 0.92)
    frame:SetSize(width, height)
    frame:SetPoint("CENTER", UIParent, "CENTER")
    frame:SetFrameStrata("DIALOG")
    frame:SetClampedToScreen(true)
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
    frame:Hide()
    local chrome = Theme:ApplyWindowChrome(frame, "Global Map")
    Theme:RegisterSpecialFrame("GoldTrackerAltsGlobalMapFrame")
    Theme:CreateResizeButton(frame, { minWidth = math.min(800, width), minHeight = math.min(560, height) })
    frame.selectedWorldID, frame.worldTabs = 947, {}
    for index, world in ipairs(self:GetAltGlobalMapWorlds()) do
        local button = Theme:CreateButton(frame, 200, 60, world.name, "neutral")
        button.worldID = world.id
        button.label:SetFontObject("GameFontNormalLarge")
        button:SetScript("OnClick", function() self:SelectAltsGlobalMapWorld(button.worldID) end)
        frame.worldTabs[index] = button
    end
    frame.map = self:CreateInteractiveMapCard(frame, "Azeroth")
    frame.map:SetPoint("TOPLEFT", chrome, "TOPLEFT", 12, -132)
    frame.map:SetPoint("BOTTOMRIGHT", chrome, "BOTTOMRIGHT", -12, 24)
    local function layout()
        local tabWidth = math.max(1, (chrome:GetWidth() - 24 - 30) / 4)
        for index, button in ipairs(frame.worldTabs) do
            button:ClearAllPoints()
            button:SetPoint("TOPLEFT", chrome, "TOPLEFT", 12 + (index - 1) * (tabWidth + 10), -58)
            button:SetWidth(tabWidth)
        end
        frame.map:Resize()
    end
    frame:SetScript("OnSizeChanged", layout)
    frame:HookScript("OnHide", function() frame.map:Stop() end)
    layout()
end

function addon:OpenAltsGlobalMapWindow()
    -- This reads a position only in response to the explicit map-opening action.
    if not self.altTrackerLeavingWorld then self:CaptureCurrentAlt(true, nil, true) end
    self:CreateAltsGlobalMapWindow()
    local frame = self.altsGlobalMapFrame
    frame:Show()
    frame:Raise()
    self:RefreshAltsGlobalMapWindow()
end
