local LIB_NAME = "JanisTheme-1.0"
local LIB_VERSION = 1

if type(_G.JanisTheme) == "table"
    and tonumber(_G.JanisTheme.version)
    and _G.JanisTheme.version >= LIB_VERSION then
    return
end

local JanisTheme = type(_G.JanisTheme) == "table" and _G.JanisTheme or {}
JanisTheme.__index = JanisTheme
JanisTheme.name = LIB_NAME
JanisTheme.version = LIB_VERSION

local DEFAULT_BACKDROP = {
    bgFile = "Interface\\Buttons\\WHITE8X8",
    edgeFile = "Interface\\Buttons\\WHITE8X8",
    edgeSize = 1,
    insets = {
        left = 1,
        right = 1,
        top = 1,
        bottom = 1,
    },
}

local DEFAULT_COLORS = {
    chrome = { 0.03, 0.04, 0.06, 0.94 },
    popupChrome = { 0.03, 0.04, 0.06, 0.96 },
    header = { 0.06, 0.07, 0.10, 0.98 },
    panel = { 0.05, 0.06, 0.08, 0.94 },
    body = { 0.04, 0.05, 0.07, 0.92 },
    section = { 0.04, 0.05, 0.07, 0.82 },
    rowOdd = { 0.07, 0.08, 0.11, 0.72 },
    rowEven = { 0.055, 0.065, 0.09, 0.60 },
    headerBorder = { 1.0, 1.0, 1.0, 0.03 },
    chromeBorder = { 1.0, 1.0, 1.0, 0.08 },
    goldBorder = { 1.0, 0.82, 0.18, 0.10 },
    goldBorderStrong = { 1.0, 0.82, 0.18, 0.12 },
    accentGold = { 1.0, 0.82, 0.18, 0.68 },
}

local DEFAULT_BUTTON_PALETTES = {
    primary = {
        bg = { 0.18, 0.14, 0.08, 0.96 },
        border = { 0.95, 0.74, 0.18, 0.26 },
        hoverBg = { 0.24, 0.18, 0.08, 0.98 },
        hoverBorder = { 1.0, 0.82, 0.24, 0.50 },
        pressedBg = { 0.12, 0.09, 0.04, 0.98 },
        pressedBorder = { 1.0, 0.82, 0.24, 0.32 },
        selectedBg = { 0.28, 0.21, 0.08, 0.98 },
        selectedBorder = { 1.0, 0.82, 0.24, 0.70 },
        text = { 1.0, 0.94, 0.72 },
    },
    neutral = {
        bg = { 0.09, 0.10, 0.14, 0.94 },
        border = { 1.0, 1.0, 1.0, 0.08 },
        hoverBg = { 0.12, 0.13, 0.18, 0.98 },
        hoverBorder = { 1.0, 1.0, 1.0, 0.16 },
        pressedBg = { 0.06, 0.07, 0.10, 0.98 },
        pressedBorder = { 1.0, 1.0, 1.0, 0.10 },
        selectedBg = { 0.18, 0.14, 0.08, 0.96 },
        selectedBorder = { 1.0, 0.82, 0.24, 0.48 },
        text = { 0.90, 0.92, 0.98 },
    },
    danger = {
        bg = { 0.19, 0.09, 0.10, 0.96 },
        border = { 1.0, 0.36, 0.38, 0.22 },
        hoverBg = { 0.25, 0.10, 0.11, 0.98 },
        hoverBorder = { 1.0, 0.44, 0.46, 0.40 },
        pressedBg = { 0.12, 0.06, 0.06, 0.98 },
        pressedBorder = { 1.0, 0.44, 0.46, 0.26 },
        text = { 1.0, 0.87, 0.87 },
    },
}

JanisTheme.defaultBackdrop = DEFAULT_BACKDROP
JanisTheme.defaultColors = DEFAULT_COLORS
JanisTheme.defaultButtonPalettes = DEFAULT_BUTTON_PALETTES

function JanisTheme:New(options)
    options = type(options) == "table" and options or {}

    local instance = {
        addon = options.addon,
        backdrop = options.backdrop or self.defaultBackdrop,
        colors = options.colors or self.defaultColors,
        buttonPalettes = options.buttonPalettes or self.defaultButtonPalettes,
    }

    return setmetatable(instance, self)
end

function JanisTheme:GetColor(colorOrKey, fallback)
    if type(colorOrKey) == "table" then
        return colorOrKey
    end
    if type(colorOrKey) == "string" and self.colors[colorOrKey] then
        return self.colors[colorOrKey]
    end
    if type(fallback) == "string" and self.colors[fallback] then
        return self.colors[fallback]
    end
    return fallback
end

function JanisTheme:GetPalette(paletteKey)
    return self.buttonPalettes[paletteKey] or self.buttonPalettes.neutral
end

function JanisTheme:ApplyBackdrop(frame, bg, border)
    if not frame or type(frame.SetBackdrop) ~= "function" then
        return
    end

    local resolvedBg = self:GetColor(bg)
    local resolvedBorder = self:GetColor(border)

    frame:SetBackdrop(self.backdrop)
    if type(resolvedBg) == "table" then
        frame:SetBackdropColor(resolvedBg[1] or 0, resolvedBg[2] or 0, resolvedBg[3] or 0, resolvedBg[4] or 1)
    end
    if type(resolvedBorder) == "table" then
        frame:SetBackdropBorderColor(
            resolvedBorder[1] or 1,
            resolvedBorder[2] or 1,
            resolvedBorder[3] or 1,
            resolvedBorder[4] or 1
        )
    end
end

function JanisTheme:CreatePanel(parent, bg, border)
    local panel = CreateFrame("Frame", nil, parent, "BackdropTemplate")
    self:ApplyBackdrop(panel, bg, border)
    return panel
end

function JanisTheme:UpdateButtonVisual(button)
    if not button or type(button.SetBackdropColor) ~= "function" then
        return
    end

    local palette = button.palette or self:GetPalette("neutral")
    local bg = palette.bg
    local border = palette.border
    if button.isSelected then
        bg = palette.selectedBg or bg
        border = palette.selectedBorder or border
    elseif button.isPressed then
        bg = palette.pressedBg or bg
        border = palette.pressedBorder or border
    elseif button.isHovered then
        bg = palette.hoverBg or bg
        border = palette.hoverBorder or border
    end

    button:SetBackdropColor(bg[1] or 0, bg[2] or 0, bg[3] or 0, bg[4] or 1)
    button:SetBackdropBorderColor(border[1] or 1, border[2] or 1, border[3] or 1, border[4] or 1)
    if button.label then
        local textColor = palette.text or { 1, 1, 1 }
        button.label:SetTextColor(textColor[1] or 1, textColor[2] or 1, textColor[3] or 1)
    end
end

function JanisTheme:CreateButton(parent, width, height, text, paletteKey)
    local button = CreateFrame("Button", nil, parent, "BackdropTemplate")
    button:SetSize(width, height)
    button.theme = self
    button.palette = self:GetPalette(paletteKey)
    button:SetBackdrop(self.backdrop)

    local label = button:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    label:SetPoint("CENTER", button, "CENTER", 0, 0)
    label:SetJustifyH("CENTER")
    button.label = label

    function button:SetText(value)
        self.label:SetText(type(value) == "string" and value or "")
    end

    function button:SetPalette(key)
        self.palette = self.theme:GetPalette(key)
        self.theme:UpdateButtonVisual(self)
    end

    function button:SetSelected(isSelected)
        self.isSelected = isSelected == true
        self.theme:UpdateButtonVisual(self)
    end

    button:SetText(text)
    button:SetScript("OnEnter", function(self)
        self.isHovered = true
        self.theme:UpdateButtonVisual(self)
        if type(self.tooltipText) == "string" and self.tooltipText ~= "" then
            GameTooltip:SetOwner(self, "ANCHOR_TOP")
            GameTooltip:SetText(self.tooltipText, 1, 1, 1, true)
            GameTooltip:Show()
        end
    end)
    button:SetScript("OnLeave", function(self)
        self.isHovered = false
        self.isPressed = false
        self.theme:UpdateButtonVisual(self)
        if type(self.tooltipText) == "string" and self.tooltipText ~= "" then
            GameTooltip:Hide()
        end
    end)
    button:SetScript("OnMouseDown", function(self, mouseButton)
        if mouseButton == "LeftButton" then
            self.isPressed = true
            self.theme:UpdateButtonVisual(self)
        end
    end)
    button:SetScript("OnMouseUp", function(self)
        self.isPressed = false
        self.theme:UpdateButtonVisual(self)
    end)
    self:UpdateButtonVisual(button)

    return button
end

function JanisTheme:HideNativeChrome(frame)
    if not frame then
        return
    end

    local regions = {
        "NineSlice",
        "Bg",
        "Inset",
        "TitleBg",
        "TopTileStreaks",
        "TitleText",
        "CloseButton",
    }
    for _, regionKey in ipairs(regions) do
        local region = frame[regionKey]
        if region and type(region.Hide) == "function" then
            region:Hide()
        end
    end
end

function JanisTheme:ApplyWindowChrome(frame, titleText, options)
    if not frame then
        return nil, nil
    end

    options = type(options) == "table" and options or {}
    self:HideNativeChrome(frame)

    local chrome = self:CreatePanel(frame, options.chromeColor or "chrome", options.chromeBorder or "chromeBorder")
    chrome:SetPoint("TOPLEFT", frame, "TOPLEFT", 6, -6)
    chrome:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -6, 6)
    frame.chrome = chrome

    local headerBar = self:CreatePanel(frame, options.headerColor or "header", options.headerBorder or "headerBorder")
    headerBar:SetPoint("TOPLEFT", chrome, "TOPLEFT", 0, 0)
    headerBar:SetPoint("TOPRIGHT", chrome, "TOPRIGHT", 0, 0)
    headerBar:SetHeight(options.headerHeight or 42)
    frame.headerBar = headerBar

    local accentColor = self:GetColor(options.accentColor or "accentGold")
    local headerAccent = headerBar:CreateTexture(nil, "ARTWORK")
    headerAccent:SetColorTexture(accentColor[1] or 1, accentColor[2] or 1, accentColor[3] or 1, accentColor[4] or 1)
    headerAccent:SetPoint("BOTTOMLEFT", headerBar, "BOTTOMLEFT", 1, 0)
    headerAccent:SetPoint("BOTTOMRIGHT", headerBar, "BOTTOMRIGHT", -1, 0)
    headerAccent:SetHeight(options.accentHeight or 2)
    frame.headerAccent = headerAccent

    local headerTitle = headerBar:CreateFontString(nil, "OVERLAY", options.titleFont or "GameFontNormalLarge")
    headerTitle:SetPoint("LEFT", headerBar, "LEFT", options.titleLeftOffset or 14, 0)
    headerTitle:SetPoint("RIGHT", headerBar, "RIGHT", options.titleRightOffset or -52, 0)
    headerTitle:SetJustifyH("LEFT")
    headerTitle:SetText(titleText or "")
    frame.headerTitleText = headerTitle

    local closeButton = self:CreateButton(
        headerBar,
        options.closeWidth or 22,
        options.closeHeight or 22,
        options.closeText or "X",
        "neutral"
    )
    closeButton:SetPoint("RIGHT", headerBar, "RIGHT", options.closeRightOffset or -10, 0)
    closeButton:SetScript("OnClick", function()
        frame:Hide()
    end)
    frame.closeButton = closeButton
    if type(options.closeButtonKey) == "string" and options.closeButtonKey ~= "" then
        frame[options.closeButtonKey] = closeButton
    end

    return chrome, headerBar
end

function JanisTheme:RegisterSpecialFrame(frameName)
    if type(frameName) ~= "string" or frameName == "" or type(UISpecialFrames) ~= "table" then
        return
    end

    for _, registeredName in ipairs(UISpecialFrames) do
        if registeredName == frameName then
            return
        end
    end

    table.insert(UISpecialFrames, frameName)
end

function JanisTheme:BringToFront(frame, relativeFrame)
    if not frame then
        return
    end

    frame:SetFrameStrata("FULLSCREEN_DIALOG")
    if frame.SetToplevel then
        frame:SetToplevel(true)
    end
    if frame.SetFrameLevel then
        local level = 100
        if relativeFrame and relativeFrame.GetFrameLevel then
            level = math.max(level, (tonumber(relativeFrame:GetFrameLevel()) or 0) + 100)
        end
        frame:SetFrameLevel(level)
    end
    if frame.Raise then
        frame:Raise()
    end
end

_G.JanisTheme = JanisTheme
