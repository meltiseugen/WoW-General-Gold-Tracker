local _, NS = ...

-- Skin definitions and artwork ported from the sibling TODO-Planner addon.
local ThemeManager = {}

local ThemeLibrary = NS.JanisThemeClass
local THEME_ASSET_PATH = "Interface\\AddOns\\General-Gold-Tracker\\Assets\\Theme\\"
local PARCHMENT_BACKDROP = {
    bgFile = THEME_ASSET_PATH .. "ParchmentSurface.png",
    edgeFile = "Interface\\Buttons\\WHITE8X8",
    tile = true,
    tileSize = 256,
    edgeSize = 1,
    insets = {
        left = 1,
        right = 1,
        top = 1,
        bottom = 1,
    },
}

local function BuildTiledBackdrop(textureFile)
    return {
        bgFile = textureFile,
        edgeFile = "Interface\\Buttons\\WHITE8X8",
        tile = true,
        tileSize = 256,
        edgeSize = 1,
        insets = {
            left = 1,
            right = 1,
            top = 1,
            bottom = 1,
        },
    }
end

local function WithAlpha(color, alpha)
    return { color[1] or 0, color[2] or 0, color[3] or 0, alpha }
end

function ThemeManager:CloneThemeTable(source)
    local copy = {}
    if type(source) ~= "table" then
        return copy
    end

    for key, value in pairs(source) do
        if type(value) == "table" then
            copy[key] = self:CloneThemeTable(value)
        else
            copy[key] = value
        end
    end

    return copy
end

function ThemeManager:BuildMidnightSpec()
    local colors = self:CloneThemeTable(ThemeLibrary.defaultColors)
    colors.input = { 0.03, 0.04, 0.06, 0.94 }
    colors.inputFocus = { 0.05, 0.06, 0.08, 0.96 }
    colors.inputBorder = { 1.0, 1.0, 1.0, 0.08 }
    colors.inputBorderFocus = { 1.0, 0.82, 0.18, 0.26 }
    colors.titleText = { 1.0, 0.82, 0.18, 1.0 }
    colors.textStrong = { 1.0, 0.82, 0.18, 1.0 }
    colors.text = { 0.92, 0.94, 1.0, 1.0 }
    colors.textSoft = { 0.86, 0.88, 0.94, 1.0 }
    colors.textMuted = { 0.56, 0.60, 0.68, 1.0 }
    colors.previewHeading = { 1.0, 0.82, 0.36, 1.0 }
    colors.previewBody = { 0.88, 0.90, 0.94, 1.0 }
    colors.previewMuted = { 0.60, 0.64, 0.71, 1.0 }
    colors.previewSuccess = { 0.39, 0.84, 0.54, 1.0 }
    colors.rowSelected = { 0.12, 0.11, 0.08, 0.92 }
    colors.selectionText = { 1.0, 0.82, 0.18, 1.0 }
    colors.selectionTextSoft = { 0.92, 0.94, 1.0, 1.0 }

    local buttonPalettes = self:CloneThemeTable(ThemeLibrary.defaultButtonPalettes)
    buttonPalettes.subtle = {
        bg = { 0.09, 0.10, 0.14, 0.94 },
        border = { 1.0, 1.0, 1.0, 0.08 },
        hoverBg = { 0.12, 0.13, 0.18, 0.98 },
        hoverBorder = { 1.0, 0.82, 0.18, 0.22 },
        pressedBg = { 0.06, 0.07, 0.10, 0.98 },
        pressedBorder = { 1.0, 1.0, 1.0, 0.10 },
        selectedBg = { 0.18, 0.14, 0.08, 0.96 },
        selectedBorder = { 1.0, 0.82, 0.24, 0.48 },
        text = { 0.92, 0.94, 1.00 },
    }

    return {
        key = "midnight",
        displayName = "Midnight Classic",
        colors = colors,
        buttonPalettes = buttonPalettes,
        backdrop = ThemeLibrary.defaultBackdrop,
        backdrops = {},
        buttonBackdrop = ThemeLibrary.defaultBackdrop,
        art = {},
    }
end

function ThemeManager:BuildParchmentSpec()
    local colors = {
        chrome = { 1.0, 0.98, 0.90, 1.0 },
        popupChrome = { 1.0, 0.96, 0.84, 1.0 },
        header = { 0.72, 0.45, 0.24, 0.16 },
        panel = { 1.0, 0.96, 0.84, 0.96 },
        body = { 1.0, 0.98, 0.90, 0.96 },
        section = { 0.92, 0.74, 0.49, 0.18 },
        rowOdd = { 0.87, 0.64, 0.38, 0.34 },
        rowEven = { 0.96, 0.82, 0.58, 0.24 },
        input = { 1.0, 0.91, 0.72, 0.58 },
        inputFocus = { 1.0, 0.95, 0.82, 0.82 },
        headerBorder = { 0.20, 0.075, 0.035, 0.48 },
        chromeBorder = { 0.22, 0.09, 0.04, 0.66 },
        transparent = { 0, 0, 0, 0 },
        goldBorder = { 0.31, 0.12, 0.055, 0.20 },
        goldBorderStrong = { 0.31, 0.12, 0.055, 0.44 },
        inputBorder = { 0.31, 0.12, 0.055, 0.42 },
        inputBorderFocus = { 0.45, 0.15, 0.06, 0.78 },
        accentGold = { 0.42, 0.14, 0.055, 0.74 },
        titleText = { 0.24, 0.075, 0.03, 1.0 },
        textStrong = { 0.31, 0.105, 0.045, 1.0 },
        text = { 0.16, 0.085, 0.04, 1.0 },
        textSoft = { 0.25, 0.14, 0.075, 1.0 },
        textMuted = { 0.43, 0.28, 0.17, 1.0 },
        previewHeading = { 0.40, 0.12, 0.045, 1.0 },
        previewBody = { 0.16, 0.085, 0.04, 1.0 },
        previewMuted = { 0.43, 0.28, 0.17, 1.0 },
        previewSuccess = { 0.17, 0.36, 0.13, 1.0 },
        rowSelected = { 0.35, 0.115, 0.05, 0.96 },
        selectionText = { 1.0, 0.91, 0.70, 1.0 },
        selectionTextSoft = { 0.94, 0.80, 0.58, 1.0 },
    }

    local ink = { 0.16, 0.085, 0.04, 1.0 }
    local cream = { 1.0, 0.91, 0.70, 1.0 }
    local buttonPalettes = {
        primary = {
            bg = { 0.34, 0.115, 0.055, 0.96 },
            border = { 0.20, 0.065, 0.025, 0.72 },
            hoverBg = { 0.43, 0.15, 0.065, 0.98 },
            hoverBorder = { 0.62, 0.27, 0.10, 0.88 },
            pressedBg = { 0.25, 0.075, 0.03, 0.98 },
            pressedBorder = { 0.15, 0.04, 0.015, 0.82 },
            selectedBg = { 0.40, 0.13, 0.05, 0.98 },
            selectedBorder = { 0.17, 0.045, 0.015, 0.92 },
            text = cream,
        },
        neutral = {
            bg = { 0.46, 0.20, 0.08, 0.07 },
            border = { 0.31, 0.12, 0.055, 0.20 },
            hoverBg = { 0.46, 0.20, 0.08, 0.16 },
            hoverBorder = { 0.42, 0.14, 0.055, 0.44 },
            pressedBg = { 0.46, 0.20, 0.08, 0.24 },
            pressedBorder = { 0.31, 0.10, 0.035, 0.58 },
            selectedBg = { 0.35, 0.115, 0.05, 0.96 },
            selectedBorder = { 0.20, 0.055, 0.02, 0.88 },
            text = ink,
            selectedText = cream,
        },
        subtle = {
            bg = { 0.46, 0.20, 0.08, 0.04 },
            border = { 0.31, 0.12, 0.055, 0.12 },
            hoverBg = { 0.46, 0.20, 0.08, 0.12 },
            hoverBorder = { 0.42, 0.14, 0.055, 0.34 },
            pressedBg = { 0.46, 0.20, 0.08, 0.20 },
            pressedBorder = { 0.31, 0.10, 0.035, 0.48 },
            selectedBg = { 0.35, 0.115, 0.05, 0.94 },
            selectedBorder = { 0.20, 0.055, 0.02, 0.82 },
            text = ink,
            selectedText = cream,
        },
        danger = {
            bg = { 0.38, 0.08, 0.055, 0.94 },
            border = { 0.22, 0.035, 0.025, 0.78 },
            hoverBg = { 0.50, 0.10, 0.07, 0.98 },
            hoverBorder = { 0.68, 0.22, 0.13, 0.90 },
            pressedBg = { 0.28, 0.045, 0.035, 0.98 },
            pressedBorder = { 0.16, 0.02, 0.015, 0.86 },
            selectedBg = { 0.44, 0.08, 0.055, 0.98 },
            selectedBorder = { 0.20, 0.025, 0.02, 0.92 },
            text = cream,
        },
        selector = {
            bg = { 0, 0, 0, 0 },
            border = { 0, 0, 0, 0 },
            hoverBg = { 0, 0, 0, 0 },
            hoverBorder = { 0, 0, 0, 0 },
            pressedBg = { 0, 0, 0, 0 },
            pressedBorder = { 0, 0, 0, 0 },
            selectedBg = { 0, 0, 0, 0 },
            selectedBorder = { 0, 0, 0, 0 },
            text = cream,
            selectedText = cream,
        },
        menu = {
            bg = { 0, 0, 0, 0 },
            border = { 0, 0, 0, 0 },
            hoverBg = { 0.46, 0.20, 0.08, 0.20 },
            hoverBorder = { 0, 0, 0, 0 },
            pressedBg = { 0.46, 0.20, 0.08, 0.30 },
            pressedBorder = { 0, 0, 0, 0 },
            selectedBg = { 0.46, 0.20, 0.08, 0.14 },
            selectedBorder = { 0, 0, 0, 0 },
            text = ink,
            selectedText = ink,
        },
        close = {
            bg = { 0, 0, 0, 0 },
            border = { 0, 0, 0, 0 },
            hoverBg = { 0.40, 0.12, 0.05, 0.18 },
            hoverBorder = { 0.40, 0.12, 0.05, 0.32 },
            pressedBg = { 0.40, 0.12, 0.05, 0.28 },
            pressedBorder = { 0.40, 0.12, 0.05, 0.44 },
            selectedBg = { 0, 0, 0, 0 },
            selectedBorder = { 0, 0, 0, 0 },
            text = ink,
        },
    }

    return {
        key = "parchment",
        displayName = "Ember Parchment",
        colors = colors,
        buttonPalettes = buttonPalettes,
        backdrop = ThemeLibrary.defaultBackdrop,
        backdrops = {
            chrome = PARCHMENT_BACKDROP,
            popupChrome = PARCHMENT_BACKDROP,
            panel = PARCHMENT_BACKDROP,
            body = PARCHMENT_BACKDROP,
        },
        buttonBackdrop = ThemeLibrary.defaultBackdrop,
        art = {
            frame = THEME_ASSET_PATH .. "ParchmentFrame.png",
            selector = THEME_ASSET_PATH .. "SelectorPlate.png",
            frameSlice = 0.18,
            frameSize = 32,
            frameOverscan = 4,
            titleFont = "Fonts\\MORPHEUS.TTF",
        },
    }
end

function ThemeManager:BuildTexturedSpec(config)
    local surfaceBackdrop = BuildTiledBackdrop(THEME_ASSET_PATH .. config.assetFolder .. "\\Surface.png")
    local clear = { 0, 0, 0, 0 }
    local colors = config.colors
    local buttonPalettes = {
        primary = {
            bg = WithAlpha(config.primary, 0.96),
            border = WithAlpha(config.accent, 0.62),
            hoverBg = WithAlpha(config.primaryHover, 0.98),
            hoverBorder = WithAlpha(config.accent, 0.88),
            pressedBg = WithAlpha(config.primaryPressed, 0.98),
            pressedBorder = WithAlpha(config.accent, 0.72),
            selectedBg = WithAlpha(config.primaryHover, 0.98),
            selectedBorder = WithAlpha(config.accent, 0.94),
            text = config.selectionText,
            selectedText = config.selectionText,
        },
        neutral = {
            bg = WithAlpha(config.neutral, 0.34),
            border = WithAlpha(config.border, 0.34),
            hoverBg = WithAlpha(config.neutralHover, 0.56),
            hoverBorder = WithAlpha(config.accent, 0.54),
            pressedBg = WithAlpha(config.neutralPressed, 0.72),
            pressedBorder = WithAlpha(config.accent, 0.68),
            selectedBg = colors.rowSelected,
            selectedBorder = WithAlpha(config.accent, 0.86),
            text = config.buttonText,
            selectedText = config.selectionText,
        },
        subtle = {
            bg = WithAlpha(config.neutral, 0.16),
            border = WithAlpha(config.border, 0.18),
            hoverBg = WithAlpha(config.neutralHover, 0.34),
            hoverBorder = WithAlpha(config.accent, 0.42),
            pressedBg = WithAlpha(config.neutralPressed, 0.50),
            pressedBorder = WithAlpha(config.accent, 0.54),
            selectedBg = colors.rowSelected,
            selectedBorder = WithAlpha(config.accent, 0.72),
            text = config.buttonText,
            selectedText = config.selectionText,
        },
        danger = {
            bg = { 0.34, 0.06, 0.055, 0.92 },
            border = { 0.62, 0.16, 0.12, 0.58 },
            hoverBg = { 0.46, 0.075, 0.06, 0.98 },
            hoverBorder = { 0.78, 0.22, 0.16, 0.78 },
            pressedBg = { 0.24, 0.035, 0.03, 0.98 },
            pressedBorder = { 0.52, 0.10, 0.08, 0.72 },
            selectedBg = { 0.42, 0.06, 0.05, 0.98 },
            selectedBorder = { 0.72, 0.16, 0.12, 0.82 },
            text = { 1.0, 0.90, 0.84 },
        },
        selector = {
            bg = clear,
            border = clear,
            hoverBg = clear,
            hoverBorder = clear,
            pressedBg = clear,
            pressedBorder = clear,
            selectedBg = clear,
            selectedBorder = clear,
            text = config.selectionText,
            selectedText = config.selectionText,
        },
        menu = {
            bg = clear,
            border = clear,
            hoverBg = WithAlpha(config.neutralHover, 0.30),
            hoverBorder = clear,
            pressedBg = WithAlpha(config.neutralPressed, 0.42),
            pressedBorder = clear,
            selectedBg = WithAlpha(config.neutralHover, 0.22),
            selectedBorder = clear,
            text = colors.text,
            selectedText = colors.textStrong,
        },
        close = {
            bg = clear,
            border = clear,
            hoverBg = WithAlpha(config.neutralHover, 0.30),
            hoverBorder = WithAlpha(config.accent, 0.34),
            pressedBg = WithAlpha(config.neutralPressed, 0.48),
            pressedBorder = WithAlpha(config.accent, 0.48),
            selectedBg = clear,
            selectedBorder = clear,
            text = colors.textStrong,
        },
    }

    return {
        key = config.key,
        displayName = config.displayName,
        colors = colors,
        buttonPalettes = buttonPalettes,
        backdrop = ThemeLibrary.defaultBackdrop,
        backdrops = {
            chrome = surfaceBackdrop,
            popupChrome = surfaceBackdrop,
            panel = surfaceBackdrop,
            body = surfaceBackdrop,
        },
        buttonBackdrop = ThemeLibrary.defaultBackdrop,
        art = {
            frame = THEME_ASSET_PATH .. config.assetFolder .. "\\Frame.png",
            selector = THEME_ASSET_PATH .. config.assetFolder .. "\\Selector.png",
            panelFrame = config.panelFrame and (THEME_ASSET_PATH .. config.assetFolder .. "\\" .. config.panelFrame) or nil,
            panelFrameKeys = config.panelFrameKeys,
            panelFrameSliceX = config.panelFrameSliceX,
            panelFrameSliceY = config.panelFrameSliceY,
            panelFrameWidth = config.panelFrameWidth,
            panelFrameHeight = config.panelFrameHeight,
            panelFrameOverscan = config.panelFrameOverscan,
            headerDecoration = config.headerDecoration and (THEME_ASSET_PATH .. config.assetFolder .. "\\" .. config.headerDecoration) or nil,
            headerDecorationSize = config.headerDecorationSize,
            headerDecorationAlpha = config.headerDecorationAlpha,
            headerDecorationMirror = config.headerDecorationMirror,
            headerDecorationMirrorAlpha = config.headerDecorationMirrorAlpha,
            titleLeftOffset = config.titleLeftOffset,
            bodyFont = config.bodyFont,
            disableFontShadow = config.disableFontShadow,
            frameSliceX = config.frameSliceX,
            frameSliceY = config.frameSliceY,
            frameWidth = config.frameWidth or 26,
            frameHeight = config.frameHeight or 26,
            frameOverscan = config.frameOverscan or 3,
            popupFrameWidth = config.popupFrameWidth or 18,
            popupFrameHeight = config.popupFrameHeight or 18,
            selectorSlice = config.selectorSlice or 0.10,
            selectorCapSize = config.selectorCapSize or 16,
            titleFont = config.titleFont or "Fonts\\FRIZQT__.TTF",
        },
    }
end

function ThemeManager:BuildQuietBotanicalSpec()
    return self:BuildTexturedSpec({
        key = "quietBotanical",
        displayName = "Quiet Botanical",
        assetFolder = "QuietBotanical",
        frameSliceX = 0.14,
        frameSliceY = 0.14,
        frameWidth = 30,
        frameHeight = 30,
        selectorSlice = 0.055,
        selectorCapSize = 13,
        panelFrame = "Frame.png",
        panelFrameKeys = { body = true, panel = true, section = true },
        panelFrameSliceX = 0.14,
        panelFrameSliceY = 0.14,
        panelFrameWidth = 18,
        panelFrameHeight = 18,
        panelFrameOverscan = 1,
        headerDecoration = "LeafCorner.png",
        headerDecorationSize = 96,
        headerDecorationAlpha = 0.54,
        headerDecorationMirror = true,
        headerDecorationMirrorAlpha = 0.14,
        titleLeftOffset = 92,
        bodyFont = "Fonts\\FRIZQT__.TTF",
        disableFontShadow = true,
        accent = { 0.18, 0.55, 0.30 },
        border = { 0.45, 0.34, 0.14 },
        primary = { 0.035, 0.25, 0.15 },
        primaryHover = { 0.045, 0.34, 0.20 },
        primaryPressed = { 0.025, 0.19, 0.11 },
        neutral = { 0.74, 0.73, 0.62 },
        neutralHover = { 0.60, 0.70, 0.55 },
        neutralPressed = { 0.48, 0.59, 0.43 },
        buttonText = { 0.10, 0.17, 0.12 },
        selectionText = { 1.0, 0.95, 0.78 },
        colors = {
            chrome = { 1.0, 1.0, 0.98, 1.0 }, popupChrome = { 1.0, 1.0, 0.98, 1.0 },
            header = { 0.82, 0.86, 0.72, 0.26 }, panel = { 1.0, 1.0, 0.98, 0.96 },
            body = { 1.0, 1.0, 0.98, 0.97 }, section = { 0.72, 0.78, 0.64, 0.22 },
            rowOdd = { 0.72, 0.77, 0.65, 0.30 }, rowEven = { 0.93, 0.93, 0.84, 0.42 },
            input = { 0.96, 0.95, 0.84, 0.72 }, inputFocus = { 1.0, 0.99, 0.90, 0.92 },
            headerBorder = { 0.40, 0.31, 0.13, 0.34 }, chromeBorder = { 0.40, 0.31, 0.13, 0.42 },
            transparent = { 0, 0, 0, 0 }, goldBorder = { 0.42, 0.33, 0.15, 0.26 },
            goldBorderStrong = { 0.42, 0.33, 0.15, 0.56 }, inputBorder = { 0.32, 0.38, 0.24, 0.42 },
            inputBorderFocus = { 0.18, 0.55, 0.30, 0.78 }, accentGold = { 0.18, 0.55, 0.30, 0.72 },
            titleText = { 0.055, 0.16, 0.10, 1.0 }, textStrong = { 0.055, 0.16, 0.10, 1.0 },
            text = { 0.09, 0.13, 0.10, 1.0 }, textSoft = { 0.18, 0.25, 0.18, 1.0 },
            textMuted = { 0.37, 0.43, 0.34, 1.0 }, previewHeading = { 0.10, 0.34, 0.18, 1.0 },
            previewBody = { 0.09, 0.13, 0.10, 1.0 }, previewMuted = { 0.37, 0.43, 0.34, 1.0 },
            previewSuccess = { 0.14, 0.48, 0.24, 1.0 }, rowSelected = { 0.035, 0.27, 0.16, 0.94 },
            selectionText = { 1.0, 0.95, 0.78, 1.0 }, selectionTextSoft = { 0.88, 0.94, 0.82, 1.0 },
        },
    })
end

function ThemeManager:BuildQuietArcaneSpec()
    return self:BuildTexturedSpec({
        key = "quietArcane", displayName = "Quiet Arcane", assetFolder = "QuietArcane",
        frameSliceX = 0.14, frameSliceY = 0.14, frameWidth = 25, frameHeight = 25,
        selectorSlice = 0.07, selectorCapSize = 14,
        accent = { 0.12, 0.66, 0.96 }, border = { 0.62, 0.47, 0.22 },
        primary = { 0.025, 0.18, 0.32 }, primaryHover = { 0.03, 0.26, 0.44 }, primaryPressed = { 0.015, 0.12, 0.23 },
        neutral = { 0.07, 0.12, 0.20 }, neutralHover = { 0.09, 0.19, 0.30 }, neutralPressed = { 0.035, 0.09, 0.16 },
        buttonText = { 0.88, 0.91, 0.96 }, selectionText = { 1.0, 0.91, 0.68 },
        colors = {
            chrome = { 1, 1, 1, 1 }, popupChrome = { 1, 1, 1, 1 }, header = { 0.04, 0.10, 0.18, 0.68 },
            panel = { 0.70, 0.78, 0.90, 0.90 }, body = { 0.82, 0.88, 0.96, 0.90 }, section = { 0.05, 0.12, 0.21, 0.84 },
            rowOdd = { 0.035, 0.12, 0.21, 0.82 }, rowEven = { 0.025, 0.085, 0.15, 0.70 },
            input = { 0.018, 0.07, 0.13, 0.90 }, inputFocus = { 0.025, 0.11, 0.19, 0.96 },
            headerBorder = { 0.62, 0.47, 0.22, 0.32 }, chromeBorder = { 0.62, 0.47, 0.22, 0.40 }, transparent = { 0, 0, 0, 0 },
            goldBorder = { 0.62, 0.47, 0.22, 0.24 }, goldBorderStrong = { 0.62, 0.47, 0.22, 0.52 },
            inputBorder = { 0.22, 0.36, 0.50, 0.48 }, inputBorderFocus = { 0.12, 0.66, 0.96, 0.82 }, accentGold = { 0.12, 0.66, 0.96, 0.72 },
            titleText = { 1.0, 0.86, 0.58, 1.0 }, textStrong = { 1.0, 0.86, 0.58, 1.0 }, text = { 0.87, 0.91, 0.97, 1.0 },
            textSoft = { 0.70, 0.78, 0.89, 1.0 }, textMuted = { 0.46, 0.57, 0.69, 1.0 },
            previewHeading = { 0.98, 0.79, 0.42, 1.0 }, previewBody = { 0.87, 0.91, 0.97, 1.0 }, previewMuted = { 0.46, 0.57, 0.69, 1.0 },
            previewSuccess = { 0.29, 0.78, 0.63, 1.0 }, rowSelected = { 0.025, 0.23, 0.40, 0.94 },
            selectionText = { 1.0, 0.91, 0.68, 1.0 }, selectionTextSoft = { 0.78, 0.91, 1.0, 1.0 },
        },
    })
end

function ThemeManager:BuildFieldLedgerSpec()
    return self:BuildTexturedSpec({
        key = "fieldLedger", displayName = "Field Ledger", assetFolder = "FieldLedger",
        frameSliceX = 0.085, frameSliceY = 0.14, frameWidth = 26, frameHeight = 26,
        selectorSlice = 0.09, selectorCapSize = 16,
        accent = { 0.75, 0.43, 0.16 }, border = { 0.46, 0.28, 0.13 },
        primary = { 0.31, 0.17, 0.075 }, primaryHover = { 0.42, 0.24, 0.10 }, primaryPressed = { 0.22, 0.115, 0.05 },
        neutral = { 0.11, 0.10, 0.09 }, neutralHover = { 0.18, 0.14, 0.10 }, neutralPressed = { 0.07, 0.065, 0.06 },
        buttonText = { 0.90, 0.86, 0.78 }, selectionText = { 1.0, 0.83, 0.50 },
        colors = {
            chrome = { 1, 1, 1, 1 }, popupChrome = { 1, 1, 1, 1 }, header = { 0.15, 0.10, 0.065, 0.74 },
            panel = { 0.82, 0.78, 0.70, 0.86 }, body = { 0.90, 0.87, 0.80, 0.86 }, section = { 0.15, 0.12, 0.09, 0.88 },
            rowOdd = { 0.14, 0.12, 0.10, 0.84 }, rowEven = { 0.095, 0.085, 0.075, 0.74 },
            input = { 0.07, 0.065, 0.06, 0.92 }, inputFocus = { 0.11, 0.09, 0.07, 0.97 },
            headerBorder = { 0.48, 0.29, 0.13, 0.44 }, chromeBorder = { 0.48, 0.29, 0.13, 0.52 }, transparent = { 0, 0, 0, 0 },
            goldBorder = { 0.55, 0.34, 0.15, 0.28 }, goldBorderStrong = { 0.66, 0.39, 0.16, 0.58 },
            inputBorder = { 0.46, 0.31, 0.18, 0.42 }, inputBorderFocus = { 0.75, 0.43, 0.16, 0.78 }, accentGold = { 0.75, 0.43, 0.16, 0.68 },
            titleText = { 1.0, 0.79, 0.45, 1.0 }, textStrong = { 1.0, 0.79, 0.45, 1.0 }, text = { 0.90, 0.87, 0.80, 1.0 },
            textSoft = { 0.75, 0.71, 0.64, 1.0 }, textMuted = { 0.49, 0.46, 0.41, 1.0 },
            previewHeading = { 0.94, 0.66, 0.30, 1.0 }, previewBody = { 0.90, 0.87, 0.80, 1.0 }, previewMuted = { 0.49, 0.46, 0.41, 1.0 },
            previewSuccess = { 0.48, 0.70, 0.36, 1.0 }, rowSelected = { 0.36, 0.22, 0.10, 0.92 },
            selectionText = { 1.0, 0.83, 0.50, 1.0 }, selectionTextSoft = { 0.91, 0.80, 0.64, 1.0 },
        },
    })
end

function ThemeManager:BuildMinimalVoidglassSpec()
    return self:BuildTexturedSpec({
        key = "minimalVoidglass", displayName = "Minimal Voidglass", assetFolder = "MinimalVoidglass",
        frameSliceX = 0.085, frameSliceY = 0.12, frameWidth = 24, frameHeight = 24,
        selectorSlice = 0.10, selectorCapSize = 17,
        accent = { 0.56, 0.31, 1.0 }, border = { 0.32, 0.35, 0.48 },
        primary = { 0.15, 0.07, 0.34 }, primaryHover = { 0.23, 0.10, 0.48 }, primaryPressed = { 0.09, 0.04, 0.22 },
        neutral = { 0.055, 0.06, 0.11 }, neutralHover = { 0.105, 0.08, 0.20 }, neutralPressed = { 0.035, 0.035, 0.075 },
        buttonText = { 0.84, 0.84, 0.94 }, selectionText = { 0.83, 0.70, 1.0 },
        colors = {
            chrome = { 1, 1, 1, 1 }, popupChrome = { 1, 1, 1, 1 }, header = { 0.07, 0.05, 0.14, 0.76 },
            panel = { 0.72, 0.72, 0.86, 0.86 }, body = { 0.82, 0.82, 0.94, 0.86 }, section = { 0.07, 0.055, 0.13, 0.88 },
            rowOdd = { 0.085, 0.055, 0.17, 0.82 }, rowEven = { 0.045, 0.045, 0.095, 0.74 },
            input = { 0.035, 0.035, 0.075, 0.92 }, inputFocus = { 0.065, 0.045, 0.13, 0.97 },
            headerBorder = { 0.34, 0.36, 0.50, 0.38 }, chromeBorder = { 0.34, 0.36, 0.50, 0.46 }, transparent = { 0, 0, 0, 0 },
            goldBorder = { 0.39, 0.32, 0.58, 0.26 }, goldBorderStrong = { 0.49, 0.38, 0.76, 0.54 },
            inputBorder = { 0.34, 0.36, 0.50, 0.46 }, inputBorderFocus = { 0.56, 0.31, 1.0, 0.84 }, accentGold = { 0.56, 0.31, 1.0, 0.72 },
            titleText = { 0.77, 0.62, 1.0, 1.0 }, textStrong = { 0.77, 0.62, 1.0, 1.0 }, text = { 0.86, 0.86, 0.95, 1.0 },
            textSoft = { 0.69, 0.68, 0.84, 1.0 }, textMuted = { 0.43, 0.43, 0.58, 1.0 },
            previewHeading = { 0.72, 0.49, 1.0, 1.0 }, previewBody = { 0.86, 0.86, 0.95, 1.0 }, previewMuted = { 0.43, 0.43, 0.58, 1.0 },
            previewSuccess = { 0.39, 0.78, 0.68, 1.0 }, rowSelected = { 0.20, 0.08, 0.42, 0.92 },
            selectionText = { 0.83, 0.70, 1.0, 1.0 }, selectionTextSoft = { 0.72, 0.76, 1.0, 1.0 },
        },
    })
end

local builders = {
    midnight = ThemeManager.BuildMidnightSpec,
    parchment = ThemeManager.BuildParchmentSpec,
    quietBotanical = ThemeManager.BuildQuietBotanicalSpec,
    quietArcane = ThemeManager.BuildQuietArcaneSpec,
    fieldLedger = ThemeManager.BuildFieldLedgerSpec,
    minimalVoidglass = ThemeManager.BuildMinimalVoidglassSpec,
}

NS.VISUAL_THEME_OPTIONS = {
    "midnight", "parchment", "quietBotanical", "quietArcane", "fieldLedger", "minimalVoidglass",
}
NS.VISUAL_THEME_LABELS = {
    midnight = "Midnight Classic", parchment = "Ember Parchment",
    quietBotanical = "Quiet Botanical", quietArcane = "Quiet Arcane",
    fieldLedger = "Field Ledger", minimalVoidglass = "Minimal Voidglass",
}

function NS.GoldTracker:GetVisualThemeKey()
    local key = self.db and self.db.visualTheme
    return builders[key] and key or "midnight"
end

-- A fresh specification for the options swatch; it never changes the active skin.
function NS.GetVisualThemePreviewSpec(key)
    return (builders[key] or builders.midnight)(ThemeManager)
end

function NS.GoldTracker:SetVisualTheme(key)
    if not builders[key] or not self.db then return false end
    self.db.visualTheme = key
    return true
end

function NS.GoldTracker:InitializeVisualTheme()
    local theme = NS.JanisTheme
    local key = self:GetVisualThemeKey()
    self.db.visualTheme = key
    local spec = builders[key](ThemeManager)
    spec.colors.infoText = (key == "parchment" or key == "quietBotanical")
        and { 0.10, 0.30, 0.43, 1 } or { 0.68, 0.86, 1.0, 1 }
    theme.key, theme.displayName = spec.key, spec.displayName
    theme.colors, theme.buttonPalettes = spec.colors, spec.buttonPalettes
    theme.backdrop, theme.backdrops = spec.backdrop, spec.backdrops
    theme.buttonBackdrop, theme.art = spec.buttonBackdrop, spec.art
end
