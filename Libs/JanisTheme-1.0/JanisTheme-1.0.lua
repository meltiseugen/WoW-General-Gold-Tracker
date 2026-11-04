local LIB_NAME = "GoldTrackerThemeLibrary"
local LIB_VERSION = 1

if type(_G.GoldTrackerThemeLibrary) == "table"
    and tonumber(_G.GoldTrackerThemeLibrary.version)
    and _G.GoldTrackerThemeLibrary.version >= LIB_VERSION then
    return
end

local JanisTheme = type(_G.GoldTrackerThemeLibrary) == "table" and _G.GoldTrackerThemeLibrary or {}
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
    chrome = { 0.03, 0.04, 0.06, 1 },
    popupChrome = { 0.03, 0.04, 0.06, 1 },
    header = { 0.06, 0.07, 0.10, 1 },
    panel = { 0.05, 0.06, 0.08, 1 },
    body = { 0.04, 0.05, 0.07, 1 },
    section = { 0.04, 0.05, 0.07, 1 },
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

local DEFAULT_ASSET_ROOT = "Interface\\AddOns\\JanisTheme-1.0\\Assets\\"
local DEFAULT_ASSETS = {
    sortAscending = "arrow_up.png",
    sortDescending = "arrow_down.png",
}

JanisTheme.defaultBackdrop = DEFAULT_BACKDROP
JanisTheme.defaultColors = DEFAULT_COLORS
JanisTheme.defaultButtonPalettes = DEFAULT_BUTTON_PALETTES
JanisTheme.defaultAssetRoot = DEFAULT_ASSET_ROOT
JanisTheme.defaultAssets = DEFAULT_ASSETS

local function CopyTable(source)
    local copied = {}
    for key, value in pairs(source or {}) do
        if type(value) == "table" then
            copied[key] = CopyTable(value)
        else
            copied[key] = value
        end
    end
    return copied
end

function JanisTheme:New(options)
    options = type(options) == "table" and options or {}

    local instance = {
        addon = options.addon,
        backdrop = options.backdrop or self.defaultBackdrop,
        backdrops = options.backdrops or {},
        buttonBackdrop = options.buttonBackdrop or options.backdrop or self.defaultBackdrop,
        art = options.art or {},
        key = options.key,
        displayName = options.displayName,
        colors = options.colors or self.defaultColors,
        buttonPalettes = options.buttonPalettes or self.defaultButtonPalettes,
        assetRoot = options.assetRoot or self.defaultAssetRoot,
        assets = CopyTable(self.defaultAssets),
    }

    for key, value in pairs(options.assets or {}) do
        instance.assets[key] = value
    end

    return setmetatable(instance, self)
end

function JanisTheme:RegisterAsset(assetKey, asset)
    if type(assetKey) ~= "string" or assetKey == "" then
        return false
    end
    self.assets = self.assets or {}
    self.assets[assetKey] = asset
    return true
end

function JanisTheme:GetAsset(assetKeyOrPath)
    if type(assetKeyOrPath) == "number" then
        return { path = assetKeyOrPath }
    end
    if type(assetKeyOrPath) ~= "string" or assetKeyOrPath == "" then
        return nil
    end

    local asset = self.assets and self.assets[assetKeyOrPath] or nil
    if asset == nil then
        asset = assetKeyOrPath
    end
    if type(asset) == "number" then
        return { path = asset }
    end
    if type(asset) == "string" then
        asset = { path = asset }
    elseif type(asset) ~= "table" then
        return nil
    end

    local path = asset.path or asset.texture or asset.file
    if type(path) == "string"
        and path ~= ""
        and not string.match(path, "^Interface\\")
        and not string.match(path, "^Interface/") then
        path = (self.assetRoot or "") .. path
    end

    return {
        path = path,
        texCoords = asset.texCoords,
        vertexColor = asset.vertexColor,
    }
end

function JanisTheme:GetAssetPath(assetKeyOrPath)
    local asset = self:GetAsset(assetKeyOrPath)
    return asset and asset.path or nil
end

function JanisTheme:SetTexture(texture, assetKeyOrPath)
    if not texture or type(texture.SetTexture) ~= "function" then
        return false
    end

    local asset = self:GetAsset(assetKeyOrPath)
    if not asset or asset.path == nil then
        texture:Hide()
        return false
    end

    texture:SetTexture(asset.path)
    if type(asset.texCoords) == "table" and type(texture.SetTexCoord) == "function" then
        texture:SetTexCoord(
            asset.texCoords[1] or 0,
            asset.texCoords[2] or 1,
            asset.texCoords[3] or 0,
            asset.texCoords[4] or 1
        )
    elseif type(texture.SetTexCoord) == "function" then
        texture:SetTexCoord(0, 1, 0, 1)
    end
    if type(asset.vertexColor) == "table" and type(texture.SetVertexColor) == "function" then
        texture:SetVertexColor(
            asset.vertexColor[1] or 1,
            asset.vertexColor[2] or 1,
            asset.vertexColor[3] or 1,
            asset.vertexColor[4] or 1
        )
    elseif type(texture.SetVertexColor) == "function" then
        texture:SetVertexColor(1, 1, 1, 1)
    end
    texture:Show()
    return true
end

function JanisTheme:CreateTexture(parent, layer, assetKeyOrPath, width, height)
    if not parent or type(parent.CreateTexture) ~= "function" then
        return nil
    end

    local texture = parent:CreateTexture(nil, layer or "ARTWORK")
    if width and height then
        texture:SetSize(width, height)
    end
    self:SetTexture(texture, assetKeyOrPath)
    return texture
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

function JanisTheme:ApplyFontTreatment(fontRegion, fontFile)
    if not fontRegion then
        return fontRegion
    end

    local resolvedFont = fontFile or self.art.bodyFont
    if resolvedFont and type(fontRegion.GetFont) == "function" and type(fontRegion.SetFont) == "function" then
        local _, fontSize = fontRegion:GetFont()
        fontRegion:SetFont(resolvedFont, tonumber(fontSize) or 12, "")
    end

    if self.art.disableFontShadow then
        if type(fontRegion.SetShadowColor) == "function" then
            fontRegion:SetShadowColor(0, 0, 0, 0)
        end
        if type(fontRegion.SetShadowOffset) == "function" then
            fontRegion:SetShadowOffset(0, 0)
        end
    end

    return fontRegion
end

function JanisTheme:ApplyBackdrop(frame, bg, border)
    if not frame or type(frame.SetBackdrop) ~= "function" then
        return
    end

    local resolvedBg = self:GetColor(bg)
    local resolvedBorder = self:GetColor(border)

    local backdrop = type(bg) == "string" and self.backdrops[bg] or nil
    frame:SetBackdrop(backdrop or self.backdrop)
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
    if type(bg) == "string"
        and self.art.panelFrame
        and type(self.art.panelFrameKeys) == "table"
        and self.art.panelFrameKeys[bg] then
        self:CreateArtBorder(panel, self.art.panelFrame, {
            width = self.art.panelFrameWidth or 16,
            height = self.art.panelFrameHeight or 16,
            overscan = self.art.panelFrameOverscan or 1,
            sliceX = self.art.panelFrameSliceX or 0.08,
            sliceY = self.art.panelFrameSliceY or 0.10,
        })
    end
    return panel
end

function JanisTheme:RefreshArtFrameLevel(frame)
    if not frame then
        return
    end
    local baseLevel = frame:GetFrameLevel() or 0
    if frame.artBorder and frame.artBorder.SetFrameLevel then
        frame.artBorder:SetFrameLevel(baseLevel + 15)
    end
    if frame.headerBar and frame.headerBar.SetFrameLevel then
        frame.headerBar:SetFrameLevel(baseLevel + 20)
    end
    if frame.closeButton and frame.closeButton.SetFrameLevel then
        frame.closeButton:SetFrameLevel(baseLevel + 21)
    end
end

function JanisTheme:CreateArtBorder(parent, textureFile, options)
    if not parent or type(textureFile) ~= "string" or textureFile == "" then
        return nil
    end
    if parent.artBorder then
        return parent.artBorder
    end

    options = type(options) == "table" and options or {}
    local sliceX = options.sliceX or options.slice or 0.18
    local sliceY = options.sliceY or options.slice or 0.18
    local width = options.width or options.size or 32
    local height = options.height or options.size or 32
    local overscan = options.overscan or 3
    local rightSlice = 1 - sliceX
    local bottomSlice = 1 - sliceY
    local overlay = CreateFrame("Frame", nil, parent)
    overlay:SetPoint("TOPLEFT", parent, "TOPLEFT", -overscan, overscan)
    overlay:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", overscan, -overscan)
    overlay:EnableMouse(false)
    parent.artBorder = overlay

    local function createSlice(coords)
        local texture = overlay:CreateTexture(nil, "OVERLAY", nil, 7)
        texture:SetTexture(textureFile)
        texture:SetTexCoord(coords[1], coords[2], coords[3], coords[4])
        return texture
    end

    local topLeft = createSlice({ 0, sliceX, 0, sliceY })
    topLeft:SetPoint("TOPLEFT")
    topLeft:SetSize(width, height)

    local topRight = createSlice({ rightSlice, 1, 0, sliceY })
    topRight:SetPoint("TOPRIGHT")
    topRight:SetSize(width, height)

    local bottomLeft = createSlice({ 0, sliceX, bottomSlice, 1 })
    bottomLeft:SetPoint("BOTTOMLEFT")
    bottomLeft:SetSize(width, height)

    local bottomRight = createSlice({ rightSlice, 1, bottomSlice, 1 })
    bottomRight:SetPoint("BOTTOMRIGHT")
    bottomRight:SetSize(width, height)

    local top = createSlice({ sliceX, rightSlice, 0, sliceY })
    top:SetPoint("TOPLEFT", topLeft, "TOPRIGHT")
    top:SetPoint("BOTTOMRIGHT", topRight, "BOTTOMLEFT")

    local bottom = createSlice({ sliceX, rightSlice, bottomSlice, 1 })
    bottom:SetPoint("TOPLEFT", bottomLeft, "TOPRIGHT")
    bottom:SetPoint("BOTTOMRIGHT", bottomRight, "BOTTOMLEFT")

    local left = createSlice({ 0, sliceX, sliceY, bottomSlice })
    left:SetPoint("TOPLEFT", topLeft, "BOTTOMLEFT")
    left:SetPoint("BOTTOMRIGHT", bottomLeft, "TOPRIGHT")

    local right = createSlice({ rightSlice, 1, sliceY, bottomSlice })
    right:SetPoint("TOPLEFT", topRight, "BOTTOMLEFT")
    right:SetPoint("BOTTOMRIGHT", bottomRight, "TOPRIGHT")

    overlay.slices = { topLeft, topRight, bottomLeft, bottomRight, top, bottom, left, right }
    self:RefreshArtFrameLevel(parent)
    return overlay
end

function JanisTheme:ApplySelectorArt(button, options)
    if not button or not self.art.selector then
        return button
    end

    options = type(options) == "table" and options or {}
    if not button.selectorArtSlices then
        local selectorSlice = self.art.selectorSlice or 0.14
        local selectorCapSize = self.art.selectorCapSize or 16
        local rightSlice = 1 - selectorSlice

        local left = button:CreateTexture(nil, "BACKGROUND", nil, 7)
        left:SetTexture(self.art.selector)
        left:SetTexCoord(0, selectorSlice, 0, 1)
        left:SetPoint("TOPLEFT", button, "TOPLEFT", -4, 3)
        left:SetPoint("BOTTOMLEFT", button, "BOTTOMLEFT", -4, -3)
        left:SetWidth(selectorCapSize)

        local right = button:CreateTexture(nil, "BACKGROUND", nil, 7)
        right:SetTexture(self.art.selector)
        right:SetTexCoord(rightSlice, 1, 0, 1)
        right:SetPoint("TOPRIGHT", button, "TOPRIGHT", 4, 3)
        right:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", 4, -3)
        right:SetWidth(selectorCapSize)

        local center = button:CreateTexture(nil, "BACKGROUND", nil, 7)
        center:SetTexture(self.art.selector)
        center:SetTexCoord(selectorSlice, rightSlice, 0, 1)
        center:SetPoint("TOPLEFT", left, "TOPRIGHT")
        center:SetPoint("BOTTOMRIGHT", right, "BOTTOMLEFT")

        button.selectorArt = center
        button.selectorArtSlices = { left, center, right }
    end

    if type(button.SetPalette) == "function" and self.buttonPalettes.selector then
        button:SetPalette("selector")
    end

    if button.label then
        button.label:ClearAllPoints()
        if options.centered then
            button.label:SetPoint("LEFT", button, "LEFT", 12, 0)
            button.label:SetPoint("RIGHT", button, "RIGHT", -12, 0)
            button.label:SetJustifyH("CENTER")
        else
            button.label:SetPoint("LEFT", button, "LEFT", 14, 0)
            button.label:SetPoint("RIGHT", button, "RIGHT", options.arrow == false and -14 or -30, 0)
            button.label:SetJustifyH("LEFT")
        end
    end

    if options.arrow ~= false and not button.selectorArrow then
        local arrow = CreateFrame("Frame", nil, button)
        arrow:SetSize(14, 12)
        arrow:SetPoint("RIGHT", button, "RIGHT", -8, 0)
        local color = self:GetColor("selectionText", { 1, 1, 1, 1 })
        local left = arrow:CreateTexture(nil, "OVERLAY")
        left:SetColorTexture(color[1] or 1, color[2] or 1, color[3] or 1, color[4] or 1)
        left:SetSize(8, 2)
        left:SetPoint("CENTER", arrow, "CENTER", -3, 0)
        left:SetRotation(math.rad(-42))
        local right = arrow:CreateTexture(nil, "OVERLAY")
        right:SetColorTexture(color[1] or 1, color[2] or 1, color[3] or 1, color[4] or 1)
        right:SetSize(8, 2)
        right:SetPoint("CENTER", arrow, "CENTER", 3, 0)
        right:SetRotation(math.rad(42))
        arrow.lines = { left, right }
        button.selectorArrow = arrow
    end

    self:UpdateButtonVisual(button)
    return button
end

function JanisTheme:ApplyPopupArt(frame)
    if self.art.frame then
        self:ApplyBackdrop(frame, "popupChrome", "transparent")
        return self:CreateArtBorder(frame, self.art.frame, {
            width = self.art.popupFrameWidth or 22,
            height = self.art.popupFrameHeight or 22,
            overscan = 3,
            sliceX = self.art.frameSliceX or self.art.frameSlice or 0.18,
            sliceY = self.art.frameSliceY or self.art.frameSlice or 0.18,
        })
    end
end

function JanisTheme:UpdateButtonVisual(button)
    if not button or type(button.SetBackdropColor) ~= "function" then
        return
    end

    local palette = button.palette or self:GetPalette("neutral")
    local bg = palette.bg
    local border = palette.border
    local text = palette.text
    if button.isSelected then
        bg = palette.selectedBg or bg
        border = palette.selectedBorder or border
        text = palette.selectedText or text
    elseif button.isPressed then
        bg = palette.pressedBg or bg
        border = palette.pressedBorder or border
        text = palette.pressedText or text
    elseif button.isHovered then
        bg = palette.hoverBg or bg
        border = palette.hoverBorder or border
        text = palette.hoverText or text
    end

    button:SetBackdropColor(bg[1] or 0, bg[2] or 0, bg[3] or 0, bg[4] or 1)
    button:SetBackdropBorderColor(border[1] or 1, border[2] or 1, border[3] or 1, border[4] or 1)
    if button.label then
        local textColor = text or { 1, 1, 1 }
        button.label:SetTextColor(textColor[1] or 1, textColor[2] or 1, textColor[3] or 1)
    end
    if button.selectorArtSlices then
        local red, green, blue, alpha
        if button.isPressed then
            red, green, blue, alpha = 0.72, 0.66, 0.58, 1
        elseif button.isHovered or button.isSelected then
            red, green, blue, alpha = 1, 1, 1, 1
        else
            red, green, blue, alpha = 0.90, 0.86, 0.80, 0.96
        end
        for _, selectorSlice in ipairs(button.selectorArtSlices) do
            selectorSlice:SetVertexColor(red, green, blue, alpha)
        end
    end
end

function JanisTheme:CreateButton(parent, width, height, text, paletteKey)
    local button = CreateFrame("Button", nil, parent, "BackdropTemplate")
    button:SetSize(width, height)
    button.theme = self
    button.palette = self:GetPalette(paletteKey)
    button:SetBackdrop(self.buttonBackdrop)

    local label = button:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    self:ApplyFontTreatment(label)
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
            GameTooltip:SetText(self.tooltipText, 1, 1, 1, 1, true)
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

function JanisTheme:ApplyHeaderDecoration(frame, headerBar)
    if self.art.headerDecoration then
        local decorationSize = self.art.headerDecorationSize or 96
        local decorationAlpha = self.art.headerDecorationAlpha or 0.55
        local leftDecoration = headerBar:CreateTexture(nil, "ARTWORK", nil, 1)
        leftDecoration:SetTexture(self.art.headerDecoration)
        leftDecoration:SetSize(decorationSize, decorationSize)
        leftDecoration:SetPoint("BOTTOMLEFT", headerBar, "BOTTOMLEFT", -4, -18)
        leftDecoration:SetAlpha(decorationAlpha)
        frame.headerDecoration = leftDecoration

        if self.art.headerDecorationMirror then
            local rightDecoration = headerBar:CreateTexture(nil, "ARTWORK", nil, 1)
            rightDecoration:SetTexture(self.art.headerDecoration)
            rightDecoration:SetTexCoord(1, 0, 1, 0)
            rightDecoration:SetSize(decorationSize, decorationSize)
            rightDecoration:SetPoint("TOPRIGHT", headerBar, "TOPRIGHT", 4, 18)
            rightDecoration:SetAlpha(self.art.headerDecorationMirrorAlpha or (decorationAlpha * 0.30))
            frame.headerDecorationMirror = rightDecoration
        end
    end

end

function JanisTheme:ApplyWindowChrome(frame, titleText, options)
    if not frame then
        return nil, nil
    end

    options = type(options) == "table" and options or {}
    self:HideNativeChrome(frame)

    local chromeBorder = options.chromeBorder
        or (self.art.frame and "transparent")
        or "chromeBorder"
    local chrome = self:CreatePanel(frame, options.chromeColor or "chrome", chromeBorder)
    chrome:SetPoint("TOPLEFT", frame, "TOPLEFT", 6, -6)
    chrome:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -6, 6)
    frame.chrome = chrome

    local headerBorder = options.headerBorder
        or (self.art.frame and "transparent")
        or "headerBorder"
    local headerBar = self:CreatePanel(frame, options.headerColor or "header", headerBorder)
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

    self:ApplyHeaderDecoration(frame, headerBar)

    local headerTitle = headerBar:CreateFontString(nil, "OVERLAY", options.titleFont or "GameFontNormalLarge")
    headerTitle:SetPoint("LEFT", headerBar, "LEFT", options.titleLeftOffset or self.art.titleLeftOffset or 14, 0)
    headerTitle:SetPoint("RIGHT", headerBar, "RIGHT", options.titleRightOffset or -52, 0)
    headerTitle:SetJustifyH("LEFT")
    headerTitle:SetText(titleText or "")
    local titleColor = self:GetColor("titleText")
    if type(titleColor) == "table" then
        headerTitle:SetTextColor(titleColor[1] or 1, titleColor[2] or 1, titleColor[3] or 1, titleColor[4] or 1)
    end
    frame.headerTitleText = headerTitle

    local closeButton = self:CreateButton(
        headerBar,
        options.closeWidth or 22,
        options.closeHeight or 22,
        options.closeText or "X",
        "close"
    )
    closeButton:SetPoint("RIGHT", headerBar, "RIGHT", options.closeRightOffset or -10, 0)
    closeButton:SetScript("OnClick", function()
        frame:Hide()
    end)
    frame.closeButton = closeButton
    if type(options.closeButtonKey) == "string" and options.closeButtonKey ~= "" then
        frame[options.closeButtonKey] = closeButton
    end

    if self.art.titleFont and headerTitle.SetFont then
        headerTitle:SetFont(self.art.titleFont, options.titleFontSize or 18, "")
    end
    self:ApplyFontTreatment(headerTitle, self.art.titleFont)
    if self.art.frame then
        self:CreateArtBorder(frame, self.art.frame, {
            width = self.art.frameWidth or self.art.frameSize or 32,
            height = self.art.frameHeight or self.art.frameSize or 32,
            overscan = self.art.frameOverscan or 4,
            sliceX = self.art.frameSliceX or self.art.frameSlice or 0.18,
            sliceY = self.art.frameSliceY or self.art.frameSlice or 0.18,
        })
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

_G.GoldTrackerThemeLibrary = JanisTheme
