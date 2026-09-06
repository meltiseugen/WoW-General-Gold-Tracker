local loader = require("tests.helpers.addon_loader")

local function panel()
    return {
        bg = nil,
        border = nil,
        alpha = nil,
        SetBackdropColor = function(self, ...)
            self.bg = { ... }
        end,
        SetBackdropBorderColor = function(self, ...)
            self.border = { ... }
        end,
        SetAlpha = function(self, alpha)
            self.alpha = alpha
        end,
    }
end

local function load_main_window(addon)
    return loader.load_module("UI/MainWindow.lua", addon or {}, {
        JanisTheme = {},
    })
end

describe("UI/MainWindow transparency", function()
    it("makes the main panels transparent while leaving the frame visible", function()
        local selected = nil
        local addon = load_main_window({
            db = {
                mainWindowTransparent = true,
            },
            session = {
                active = false,
            },
            mainFrame = {
                chrome = panel(),
                headerBar = panel(),
                summaryPanel = panel(),
                logPanel = panel(),
                compactPanel = panel(),
                sessionStatusBadge = panel(),
                headerAccent = panel(),
                summaryAccent = panel(),
                logAccent = panel(),
                compactDivider = panel(),
                opacityButton = {
                    SetSelected = function(_, value)
                        selected = value
                    end,
                },
                SetAlpha = function(self, alpha)
                    self.alpha = alpha
                end,
            },
        })

        addon:ApplyMainWindowAlpha()

        assert.equals(1, addon.mainFrame.alpha)
        assert.equals(0, addon.mainFrame.chrome.bg[4])
        assert.equals(0, addon.mainFrame.headerBar.bg[4])
        assert.equals(0, addon.mainFrame.summaryPanel.bg[4])
        assert.equals(0, addon.mainFrame.logPanel.bg[4])
        assert.equals(0, addon.mainFrame.compactPanel.bg[4])
        assert.equals(0, addon.mainFrame.sessionStatusBadge.bg[4])
        assert.equals(0, addon.mainFrame.headerAccent.alpha)
        assert.equals(0.18, addon.mainFrame.compactDivider.alpha)
        assert.is_true(selected)
    end)

    it("toggles and persists the transparent state", function()
        local addon = load_main_window({
            db = {
                mainWindowTransparent = false,
            },
            mainFrame = {
                chrome = panel(),
                headerBar = panel(),
                summaryPanel = panel(),
                logPanel = panel(),
                SetAlpha = function() end,
            },
        })

        addon:ToggleMainWindowTransparency()

        assert.is_true(addon.db.mainWindowTransparent)
        assert.equals(0, addon.mainFrame.chrome.bg[4])
    end)
end)
