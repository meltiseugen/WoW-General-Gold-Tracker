local _, NS = ...
local GoldTracker = NS.GoldTracker

local MINIMAP_BUTTON_MIN_RADIUS = 80
local MINIMAP_BUTTON_OUTSIDE_PADDING = 6

local MINIMAP_SHAPES = {
    ROUND = { true, true, true, true },
    SQUARE = { false, false, false, false },
    ["CORNER-TOPLEFT"] = { false, false, false, true },
    ["CORNER-TOPRIGHT"] = { false, false, true, false },
    ["CORNER-BOTTOMLEFT"] = { false, true, false, false },
    ["CORNER-BOTTOMRIGHT"] = { true, false, false, false },
    ["SIDE-LEFT"] = { false, true, false, true },
    ["SIDE-RIGHT"] = { true, false, true, false },
    ["SIDE-TOP"] = { false, false, true, true },
    ["SIDE-BOTTOM"] = { true, true, false, false },
    ["TRICORNER-TOPLEFT"] = { false, true, true, true },
    ["TRICORNER-TOPRIGHT"] = { true, false, true, true },
    ["TRICORNER-BOTTOMLEFT"] = { true, true, false, true },
    ["TRICORNER-BOTTOMRIGHT"] = { true, true, true, false },
}

local function GetAtan2(y, x)
    if math.atan2 then
        return math.atan2(y, x)
    end

    if x == 0 then
        if y < 0 then
            return -(math.pi / 2)
        end
        return math.pi / 2
    end

    local angle = math.atan(y / x)
    if x < 0 then
        angle = angle + math.pi
    end
    return angle
end

local function GetMinimapButtonRadius()
    if not Minimap or not Minimap.GetWidth or not Minimap.GetHeight then
        return MINIMAP_BUTTON_MIN_RADIUS
    end

    local width = tonumber(Minimap:GetWidth()) or 140
    local height = tonumber(Minimap:GetHeight()) or 140
    local dynamicRadius = (math.min(width, height) * 0.5) + MINIMAP_BUTTON_OUTSIDE_PADDING
    return math.max(MINIMAP_BUTTON_MIN_RADIUS, dynamicRadius)
end

local function NormalizeAngle(angle)
    if type(angle) ~= "number" then
        return 0
    end
    return angle % 360
end

function GoldTracker:GetMinimapButtonAngleFromCursor()
    local minimapCenterX, minimapCenterY = Minimap:GetCenter()
    if not minimapCenterX or not minimapCenterY then
        return self.db.minimapButtonAngle or self.DEFAULTS.minimapButtonAngle
    end

    local cursorX, cursorY = GetCursorPosition()
    local scale = UIParent:GetEffectiveScale()
    cursorX = cursorX / scale
    cursorY = cursorY / scale

    local deltaY = cursorY - minimapCenterY
    local deltaX = cursorX - minimapCenterX
    local angle = math.deg(GetAtan2(deltaY, deltaX))
    return NormalizeAngle(angle)
end

function GoldTracker:ApplyMinimapButtonPosition()
    if not self.minimapButton then
        return
    end

    local angle = NormalizeAngle(self.db and self.db.minimapButtonAngle or self.DEFAULTS.minimapButtonAngle)
    local radians = math.rad(angle)
    local radius = GetMinimapButtonRadius()
    local diagonalRadius = math.sqrt((radius * radius) * 2) - 10
    local xOffset = math.cos(radians)
    local yOffset = math.sin(radians)

    local quadrant = 1
    if xOffset < 0 then
        quadrant = quadrant + 1
    end
    if yOffset > 0 then
        quadrant = quadrant + 2
    end

    local minimapShape = GetMinimapShape and GetMinimapShape() or "ROUND"
    local quadrantMap = MINIMAP_SHAPES[minimapShape]
    if quadrantMap and quadrantMap[quadrant] then
        xOffset = xOffset * radius
        yOffset = yOffset * radius
    else
        xOffset = math.max(-radius, math.min(xOffset * diagonalRadius, radius))
        yOffset = math.max(-radius, math.min(yOffset * diagonalRadius, radius))
    end

    self.minimapButton:ClearAllPoints()
    self.minimapButton:SetPoint("CENTER", Minimap, "CENTER", xOffset, yOffset)
end

function GoldTracker:CreateMinimapButton()
    if self.minimapButton then
        return
    end
    if not Minimap then
        return
    end

    local addon = self
    local button = CreateFrame("Button", "GoldTrackerMinimapButton", Minimap)
    button:SetSize(31, 31)
    button:SetFrameStrata("MEDIUM")
    button:RegisterForClicks("anyUp")
    button:RegisterForDrag("LeftButton")
    button:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")
    button:SetMovable(false)
    button:EnableMouse(true)

    local icon = button:CreateTexture(nil, "BACKGROUND")
    icon:SetSize(20, 20)
    icon:SetPoint("CENTER", 0, 0)
    icon:SetTexture("Interface\\Icons\\INV_Misc_Coin_01")
    button.icon = icon

    local border = button:CreateTexture(nil, "OVERLAY")
    border:SetSize(53, 53)
    border:SetPoint("TOPLEFT")
    border:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")

    button:SetScript("OnClick", function(_, mouseButton)
        if mouseButton == "LeftButton" then
            addon:HandleSlashCommand("")
        elseif mouseButton == "RightButton" and addon:IsTotalWindowFeatureEnabled() then
            addon:ToggleTotalWindow()
        end
    end)

    button:SetScript("OnDragStart", function(self)
        self.isDragging = true
        self:SetScript("OnUpdate", function()
            addon.db.minimapButtonAngle = addon:GetMinimapButtonAngleFromCursor()
            addon:ApplyMinimapButtonPosition()
        end)
    end)

    button:SetScript("OnDragStop", function(self)
        if self.isDragging then
            self.isDragging = false
            self:SetScript("OnUpdate", nil)
            addon.db.minimapButtonAngle = addon:GetMinimapButtonAngleFromCursor()
            addon:ApplyMinimapButtonPosition()
        end
    end)

    button:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:AddLine("General Gold Tracker", 1, 0.82, 0)
        GameTooltip:AddLine("Left-click: Open tracker window", 0.9, 0.9, 0.9)
        if addon:IsTotalWindowFeatureEnabled() then
            GameTooltip:AddLine("Right-click: Toggle total window", 0.9, 0.9, 0.9)
        end
        GameTooltip:AddLine("Drag with left mouse button: Move button", 0.9, 0.9, 0.9)
        GameTooltip:Show()
    end)

    button:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)
    button:SetScript("OnHide", function(self)
        if self.isDragging then
            self.isDragging = false
            self:SetScript("OnUpdate", nil)
        end
    end)

    self.minimapButton = button
    self:ApplyMinimapButtonPosition()
end
