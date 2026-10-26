local loader = require("tests.helpers.addon_loader")
local widgets = require("tests.helpers.map_ui")

local function widget(frameType, name, parent, template)
    local frame = widgets.widget(frameType, name, parent)
    frame.template = template
    function frame:SetBackdrop(backdrop) self.backdrop = backdrop end
    function frame:SetBackdropColor(...) self.background = { ... } end
    function frame:SetBackdropBorderColor(...) self.border = { ... } end
    function frame:GetFont() return self.fontPath or "font", self.fontSize or 12, "OUTLINE" end
    function frame:SetShadowColor(...) self.shadowColor = { ... } end
    function frame:SetShadowOffset(...) self.shadowOffset = { ... } end
    function frame:RegisterEvent() end
    function frame:GetFrameStrata() return "DIALOG" end
    function frame:CreateFontString(_, _, fontTemplate)
        local font = widget("FontString", nil, self)
        font.fontTemplate = fontTemplate
        return font
    end
    if template and template:find("UIDropDownMenuTemplate", 1, true) then
        frame.Text = widget("FontString", nil, frame)
        frame.Left = widget("Texture", nil, frame)
        frame.Middle = widget("Texture", nil, frame)
        frame.Right = widget("Texture", nil, frame)
    end
    return frame
end

local function with_theme(key, callback)
    loader.with_globals({ CreateFrame = widget, UISpecialFrames = {} }, function()
        assert(loadfile("Libs/JanisTheme-1.0/JanisTheme-1.0.lua"))()
        local ns = { GoldTracker = { db = { visualTheme = key, unrelated = "keep" } } }
        for _, path in ipairs({ "UI/Theme.lua", "UI/VisualThemes.lua", "UI/Skinning.lua" }) do
            assert(loadfile(path))("General-Gold-Tracker", ns)
        end
        ns.GoldTracker:InitializeVisualTheme()
        callback(ns.JanisTheme, ns.GoldTracker, ns)
    end)
end

describe("ported UI skins", function()
    it("keeps the shared JanisTheme and TODO-Planner libraries isolated", function()
        local shared, planner = {}, {}
        loader.with_globals({ JanisTheme = shared, TODOPlannerThemeLibrary = planner }, function()
            with_theme("parchment", function(theme)
                assert.equals(shared, _G.JanisTheme)
                assert.equals(planner, _G.TODOPlannerThemeLibrary)
                assert.equals("parchment", theme.key)
            end)
        end)
    end)

    it("defaults to Midnight Classic and normalizes invalid saved selections", function()
        for _, key in ipairs({ "invalid", false, 99 }) do
            with_theme(key, function(theme, addon)
                assert.equals("midnight", theme.key)
                assert.equals("Midnight Classic", theme.displayName)
                assert.equals("midnight", addon.db.visualTheme)
                assert.equals("keep", addon.db.unrelated)
            end)
        end
        with_theme(nil, function(theme) assert.equals("midnight", theme.key) end)
    end)

    it("preserves every valid saved skin and resolves all artwork inside GGT", function()
        for _, key in ipairs({ "midnight", "parchment", "quietBotanical", "quietArcane", "fieldLedger", "minimalVoidglass" }) do
            with_theme(key, function(theme, addon, ns)
                assert.equals(key, addon:GetVisualThemeKey())
                assert.equals(key, theme.key)
                assert.equals(ns.VISUAL_THEME_LABELS[key], theme.displayName)
                local function check_asset(path)
                    if type(path) ~= "string" or not path:find("%.png$") then return end
                    local prefix = "Interface\\AddOns\\General-Gold-Tracker\\"
                    assert.equals(prefix, path:sub(1, #prefix))
                    local file = io.open(path:sub(#prefix + 1):gsub("\\", "/"), "rb")
                    assert.is_truthy(file)
                    file:close()
                end
                for _, path in pairs(theme.art) do check_asset(path) end
                for _, backdrop in pairs(theme.backdrops) do check_asset(backdrop.bgFile) end
                assert.equals("keep", addon.db.unrelated)
            end)
        end
    end)

    it("saves a choice without applying it until reload and rejects unknown choices", function()
        with_theme("quietArcane", function(theme, addon)
            assert.is_true(addon:SetVisualTheme("parchment"))
            assert.equals("parchment", addon.db.visualTheme)
            assert.equals("quietArcane", theme.key)
            assert.is_false(addon:SetVisualTheme("unknown"))
            assert.equals("parchment", addon.db.visualTheme)
        end)
    end)

    it("keeps the Midnight factory and external frames unmodified", function()
        with_theme("midnight", function(theme, _, ns)
            local frame = ns.CreateThemedFrame("Frame")
            assert.is_nil(frame.ggtSkinInstalled)
            assert.is_nil(theme.art.frame)
        end)
        with_theme("quietBotanical", function(_, _, ns)
            local external = CreateFrame("Frame")
            external:CreateFontString():SetTextColor(0.92, 0.95, 1)
            assert.is_nil(external.ggtSkinInstalled)
            assert.is_nil(external.ggtNativeCreateFontString)
            assert.is_truthy(ns.CreateThemedFrame("Frame").ggtSkinInstalled)
        end)
    end)

    it("translates late-created and recycled neutral text while retaining item-quality colors", function()
        with_theme("quietBotanical", function(theme, _, ns)
            local row = ns.CreateThemedFrame("Frame")
            local text = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
            assert.same(theme.colors.text, text.color)
            text:SetTextColor(0.62, 0.66, 0.74)
            assert.same(theme.colors.textMuted, text.color)
            text:SetTextColor(0.64, 0.21, 0.93)
            assert.same({ 0.64, 0.21, 0.93 }, text.color)
            assert.equals("Fonts\\FRIZQT__.TTF", text.fontPath)
            assert.equals("", text.fontFlags)
            assert.same({ 0, 0, 0, 0 }, text.shadowColor)
        end)
    end)

    it("maps legacy surfaces and transparency updates to the selected skin", function()
        with_theme("parchment", function(theme)
            local panel = theme:CreatePanel(nil, { 0.05, 0.06, 0.08, 0.94 }, { 1, 0.82, 0.18, 0.10 })
            assert.equals(theme.backdrops.panel, panel.backdrop)
            assert.same(theme.colors.panel, panel.background)
            panel:SetBackdropColor(0.05, 0.06, 0.08, 0)
            assert.equals(0, panel.background[4])
            assert.equals(theme.colors.panel[1], panel.background[1])
        end)
    end)

    it("retains themed selected-button text on light skins", function()
        with_theme("quietBotanical", function(theme)
            local button = theme:CreateButton(nil, 120, 24, "Test", "neutral")
            button:SetSelected(true)
            assert.equals(theme.buttonPalettes.neutral.selectedBg[1], button.background[1])
            assert.equals(theme.buttonPalettes.neutral.selectedText[1], button.label.color[1])
            theme:ApplySelectorArt(button, { centered = true, arrow = false })
            assert.equals(3, #button.selectorArtSlices)
            assert.equals(theme.art.selector, button.selectorArt.texture)
        end)
    end)

    it("skins edit fields and native dropdown labels but preserves the Blizzard Settings landing page", function()
        with_theme("quietBotanical", function(theme, _, ns)
            local input = ns.CreateThemedFrame("EditBox", nil, nil, "InputBoxTemplate")
            assert.equals("InputBoxTemplate,BackdropTemplate", input.template)
            assert.same(theme.colors.input, input.background)
            assert.same(theme.colors.text, input.color)
            local dropdown = ns.CreateThemedFrame("Frame", nil, nil, "UIDropDownMenuTemplate")
            assert.same(theme.colors.text, dropdown.Text.color)
            assert.is_false(dropdown.Left:IsShown())
            local settings = ns.CreateThemedFrame("Frame", "GoldTrackerOptionsPanel")
            local label = ns.CreateThemedFrame("Button", nil, settings)
            assert.is_nil(settings.ggtSkinInstalled)
            assert.is_nil(label.ggtSkinInstalled)
        end)
    end)

    it("adds eight-slice custom window art once and hides it inside Explorer", function()
        with_theme("quietArcane", function(theme, _, ns)
            local frame = ns.CreateThemedFrame("Frame")
            frame:Hide()
            theme:RegisterWindowForFocus(frame, "addon")
            frame:Show()
            assert.equals(8, #frame.artBorder.slices)
            local border = frame.artBorder
            theme:ApplyCustomWindowArt(frame)
            assert.equals(border, frame.artBorder)
            frame.goldTrackerManagedWindow = {}
            theme:ApplyCustomWindowArt(frame)
            assert.is_false(border:IsShown())
            frame.goldTrackerManagedWindow = frame
            theme:ApplyCustomWindowArt(frame)
            assert.is_true(border:IsShown())
        end)
    end)
end)
