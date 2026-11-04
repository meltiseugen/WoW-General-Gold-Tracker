local _, NS = ...
local Theme = NS.JanisTheme
local NativeCreateFrame = CreateFrame
local BaseCreatePanel = Theme.CreatePanel
local BaseCreateButton = Theme.CreateButton
local BaseApplyBackdrop = Theme.ApplyBackdrop
local BaseRegisterWindowForFocus = Theme.RegisterWindowForFocus

-- Only the legacy presentation palette is translated. Item quality, class,
-- status and map colors outside these entries keep their original values.
local function FindColor(colors, r, g, b)
    local red = colors[r]
    local green = red and red[g]
    return green and green[b]
end

local textColors, surfaceColors = {}, {}
local function AddColors(target, key, colors)
    for _, color in ipairs(colors) do
        local r, g, b = unpack(color)
        target[r] = target[r] or {}
        target[r][g] = target[r][g] or {}
        target[r][g][b] = key
    end
end

AddColors(textColors, "textMuted", {
    { 0.62, 0.66, 0.74 }, { 0.52, 0.56, 0.64 }, { 0.54, 0.58, 0.64 },
    { 0.56, 0.60, 0.68 }, { 0.60, 0.64, 0.70 }, { 0.68, 0.72, 0.80 },
})
AddColors(textColors, "textSoft", {
    { 0.72, 0.76, 0.84 }, { 0.78, 0.82, 0.90 }, { 0.82, 0.86, 0.94 },
    { 0.86, 0.88, 0.94 },
})
AddColors(textColors, "text", {
    { 0.92, 0.95, 1.0 }, { 0.90, 0.92, 0.98 }, { 0.88, 0.92, 1.0 },
    { 0.92, 0.96, 1.0 }, { 0.92, 0.94, 1.0 },
})
AddColors(textColors, "textStrong", {
    { 1.0, 0.82, 0.18 }, { 1.0, 0.82, 0 }, { 1.0, 0.93, 0.58 },
    { 1.0, 0.93, 0.62 }, { 1.0, 0.94, 0.72 }, { 0.96, 0.86, 0.42 },
    { 1.0, 0.82, 0.30 }, { 1.0, 0.82, 0.40 }, { 0.96, 0.86, 0.54 },
})
AddColors(textColors, "previewSuccess", {
    { 0.68, 0.96, 0.72 }, { 0.66, 0.96, 0.72 }, { 0.48, 0.92, 0.62 },
})
AddColors(textColors, "infoText", {
    { 0.68, 0.86, 1.0 }, { 0.72, 0.86, 1.0 }, { 0.66, 0.84, 1.0 },
})
AddColors(surfaceColors, "chrome", { { 0.03, 0.04, 0.06 } })
AddColors(surfaceColors, "header", { { 0.06, 0.07, 0.10 } })
AddColors(surfaceColors, "panel", {
    { 0.05, 0.06, 0.08 }, { 0.06, 0.07, 0.09 }, { 0.04, 0.07, 0.10 },
})
AddColors(surfaceColors, "body", {
    { 0.025, 0.03, 0.045 }, { 0.025, 0.03, 0.04 }, { 0.035, 0.055, 0.075 },
})
AddColors(surfaceColors, "section", { { 0.04, 0.05, 0.07 } })
AddColors(surfaceColors, "input", { { 0.018, 0.025, 0.04 } })
AddColors(surfaceColors, "rowOdd", { { 0.08, 0.09, 0.13 } })
AddColors(surfaceColors, "rowEven", {
    { 0.11, 0.12, 0.16 }, { 0.10, 0.11, 0.15 }, { 0.12, 0.13, 0.18 },
})
AddColors(surfaceColors, "rowSelected", { { 0.19, 0.15, 0.04 } })

local function HasSkin()
    return Theme.key and Theme.key ~= "midnight"
end

local function ResolveLegacyColor(colors, r, g, b, a)
    local key = FindColor(colors, r, g, b)
    local color = key and Theme.colors[key]
    if color then
        return color[1], color[2], color[3], a == nil and (color[4] or 1) or a
    end
    return r, g, b, a
end

local function SetTextColor(region, r, g, b, a)
    return region.ggtNativeTextColor(region, ResolveLegacyColor(textColors, r, g, b, a))
end

local function SkinFont(region, template)
    if not region or region.ggtNativeTextColor or type(region.SetTextColor) ~= "function" then return end
    region.ggtNativeTextColor = region.SetTextColor
    region.SetTextColor = SetTextColor
    Theme:ApplyFontTreatment(region)
    local key = "text"
    if type(template) == "string" then
        if template:find("Disable") then key = "textMuted"
        elseif template:find("Normal") then key = "textStrong" end
    end
    local color = Theme.colors[key]
    region.ggtNativeTextColor(region, unpack(color))
end

local function CreateFontString(frame, name, layer, template, ...)
    local region = frame.ggtNativeCreateFontString(frame, name, layer, template, ...)
    SkinFont(region, template)
    return region
end

local function SetBackdropColor(frame, r, g, b, a)
    return frame.ggtNativeBackdropColor(frame, ResolveLegacyColor(surfaceColors, r, g, b, a))
end

local function SetBackdropBorderColor(frame, r, g, b, a)
    if (r == 1 and g == 0.82) or (r == 1 and g == 1 and b == 1) then
        local color = Theme.colors.chromeBorder
        return frame.ggtNativeBorderColor(frame, color[1], color[2], color[3], a or color[4])
    end
    return frame.ggtNativeBorderColor(frame, r, g, b, a)
end

local function SetColorTexture(texture, r, g, b, a)
    if r == 1 and g == 0.82 and (b == 0.18 or b == 0) then
        local color = Theme.colors.accentGold
        return texture.ggtNativeColorTexture(texture, color[1], color[2], color[3], a or color[4])
    end
    if r == 1 and g == 1 and b == 1 and a and a <= 0.16 then
        local color = Theme.colors.text
        return texture.ggtNativeColorTexture(texture, color[1], color[2], color[3], a)
    end
    return texture.ggtNativeColorTexture(texture, r, g, b, a)
end

local function CreateTexture(frame, ...)
    local texture = frame.ggtNativeCreateTexture(frame, ...)
    if texture and type(texture.SetColorTexture) == "function" then
        texture.ggtNativeColorTexture = texture.SetColorTexture
        texture.SetColorTexture = SetColorTexture
    end
    return texture
end

function Theme:SkinFrame(frame, preservePalette)
    if not HasSkin() or not frame or frame.ggtSkinInstalled then return frame end
    frame.ggtSkinInstalled = true
    if type(frame.CreateFontString) == "function" then
        frame.ggtNativeCreateFontString = frame.CreateFontString
        frame.CreateFontString = CreateFontString
    end
    if type(frame.CreateTexture) == "function" then
        frame.ggtNativeCreateTexture = frame.CreateTexture
        frame.CreateTexture = CreateTexture
    end
    if not preservePalette then
        if type(frame.SetBackdropColor) == "function" then
            frame.ggtNativeBackdropColor = frame.SetBackdropColor
            frame.SetBackdropColor = SetBackdropColor
        end
        if type(frame.SetBackdropBorderColor) == "function" then
            frame.ggtNativeBorderColor = frame.SetBackdropBorderColor
            frame.SetBackdropBorderColor = SetBackdropBorderColor
        end
    end
    return frame
end

function Theme:ApplyBackdrop(frame, bg, border)
    if HasSkin() then
        if type(bg) == "table" then
            bg = FindColor(surfaceColors, unpack(bg)) or bg
        end
        if type(border) == "table" and border[1] == 1 then
            border = border[2] == 0.82 and "goldBorder" or "chromeBorder"
        end
    end
    return BaseApplyBackdrop(self, frame, bg, border)
end

function Theme:CreatePanel(parent, bg, border)
    return self:SkinFrame(BaseCreatePanel(self, parent, bg, border))
end

function Theme:CreateButton(parent, width, height, text, paletteKey)
    local button = BaseCreateButton(self, parent, width, height, text, paletteKey)
    -- Button colors already come from the selected skin's palette.
    return self:SkinFrame(button, true)
end

function NS.CreateThemedFrame(frameType, name, parent, template, ...)
    if not HasSkin() then return NativeCreateFrame(frameType, name, parent, template, ...) end
    if name == "GoldTrackerOptionsPanel" or (parent and parent.ggtNativeSettingsPage) then
        local frame = NativeCreateFrame(frameType, name, parent, template, ...)
        frame.ggtNativeSettingsPage = true
        return frame
    end
    local isInput = frameType == "EditBox"
    local isDropdown = (template or ""):find("UIDropDownMenuTemplate", 1, true)
    if (isInput or isDropdown) and not (template or ""):find("BackdropTemplate", 1, true) then
        template = template and (template .. ",BackdropTemplate") or "BackdropTemplate"
    end
    local frame = Theme:SkinFrame(NativeCreateFrame(frameType, name, parent, template, ...))
    if isInput or isDropdown then
        for _, key in ipairs({ "Left", "Middle", "Right" }) do
            if frame[key] and frame[key].Hide then frame[key]:Hide() end
        end
        if isInput then SkinFont(frame) end
        Theme:ApplyBackdrop(frame, "input", "inputBorder")
    end
    -- Labels supplied by native dropdown templates exist before our factory
    -- returns. Style those as well as labels subsequently created by GGT.
    if frame.Text then SkinFont(frame.Text) end
    return frame
end

function Theme:ApplyCustomWindowArt(frame)
    -- Main/Total have hand-built chrome. Other windows receive this treatment
    -- from ApplyWindowChrome; reuse their existing border when present.
    if frame.goldTrackerManagedWindow and frame.goldTrackerManagedWindow ~= frame then
        if frame.artBorder then frame.artBorder:Hide() end
        return
    end
    if self.art.frame and not frame.artBorder then
        self:CreateArtBorder(frame, self.art.frame, {
            width = self.art.frameWidth or self.art.frameSize or 32,
            height = self.art.frameHeight or self.art.frameSize or 32,
            overscan = self.art.frameOverscan or 4,
            sliceX = self.art.frameSliceX or self.art.frameSlice or 0.18,
            sliceY = self.art.frameSliceY or self.art.frameSlice or 0.18,
        })
    end
    if frame.artBorder then frame.artBorder:Show() end
    if frame.headerBar and not frame.headerDecoration then
        self:ApplyHeaderDecoration(frame, frame.headerBar)
        if frame.isTinyMode then
            if frame.headerDecoration then frame.headerDecoration:Hide() end
            if frame.headerDecorationMirror then frame.headerDecorationMirror:Hide() end
        end
    end
    if frame.headerTitleText then
        self:ApplyFontTreatment(frame.headerTitleText, self.art.titleFont)
    end
    self:RefreshArtFrameLevel(frame)
end

function Theme:RegisterWindowForFocus(frame, role, options)
    local result = BaseRegisterWindowForFocus(self, frame, role, options)
    if result and HasSkin() and not frame.ggtWindowArtHooked and type(frame.HookScript) == "function" then
        frame.ggtWindowArtHooked = true
        frame:HookScript("OnShow", function(shownFrame) self:ApplyCustomWindowArt(shownFrame) end)
    end
    return result
end
