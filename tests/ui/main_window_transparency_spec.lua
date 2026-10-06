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

local function visibility_region()
    return {
        shown = nil,
        SetShown = function(self, shown)
            self.shown = shown
        end,
    }
end

local function load_main_window(addon)
    return loader.load_module("UI/MainWindow.lua", addon or {}, {
        JanisTheme = {},
    })
end

describe("UI/MainWindow transparency", function()
    it("makes the main chrome transparent while leaving text readable", function()
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
                sessionStylePanel = panel(),
                sessionStylePopup = panel(),
                sessionStatusBadge = panel(),
                headerAccent = panel(),
                summaryAccent = panel(),
                logAccent = panel(),
                compactDivider = panel(),
                heroDivider = panel(),
                actionDivider = panel(),
                logHeaderUnderline = panel(),
                transparentInteractionHint = visibility_region(),
                resizeButton = panel(),
                logScrollFrame = {
                    ScrollBar = panel(),
                },
                logRows = {
                    {
                        background = panel(),
                        hover = panel(),
                        divider = panel(),
                    },
                },
                closeButton = panel(),
                opacityButton = {
                    SetSelected = function(_, value)
                        selected = value
                    end,
                    SetBackdropColor = function(self, ...)
                        self.bg = { ... }
                    end,
                    SetBackdropBorderColor = function(self, ...)
                        self.border = { ... }
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
        assert.equals(0, addon.mainFrame.sessionStylePanel.bg[4])
        assert.equals(0, addon.mainFrame.sessionStylePanel.border[4])
        assert.equals(0, addon.mainFrame.sessionStylePopup.bg[4])
        assert.equals(0, addon.mainFrame.sessionStylePopup.border[4])
        assert.equals(0, addon.mainFrame.sessionStatusBadge.bg[4])
        assert.equals(0, addon.mainFrame.headerAccent.alpha)
        assert.equals(0, addon.mainFrame.compactDivider.alpha)
        assert.equals(0, addon.mainFrame.heroDivider.alpha)
        assert.equals(0, addon.mainFrame.actionDivider.alpha)
        assert.equals(0, addon.mainFrame.logHeaderUnderline.alpha)
        assert.is_true(addon.mainFrame.transparentInteractionHint.shown)
        assert.equals(0, addon.mainFrame.resizeButton.alpha)
        assert.equals(0, addon.mainFrame.logScrollFrame.ScrollBar.alpha)
        assert.equals(0, addon.mainFrame.logRows[1].background.alpha)
        assert.equals(0, addon.mainFrame.logRows[1].hover.alpha)
        assert.equals(0, addon.mainFrame.logRows[1].divider.alpha)
        assert.equals(0, addon.mainFrame.closeButton.bg[4])
        assert.equals(0, addon.mainFrame.opacityButton.bg[4])
        assert.is_true(selected)

        addon.db.mainWindowTransparent = false
        addon:ApplyMainWindowAlpha()
        assert.is_false(addon.mainFrame.transparentInteractionHint.shown)
    end)

    it("toggles and persists the transparent state", function()
        local messages = {}
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

        loader.with_globals({
            UIErrorsFrame = {
                AddMessage = function(_, message)
                    messages[#messages + 1] = message
                end,
            },
        }, function()
            addon:ToggleMainWindowTransparency()
            assert.equals(1, #messages)
            assert.equals("Hold Ctrl to click or drag the transparent window.", messages[1])

            addon:ToggleMainWindowTransparency()
            assert.equals(1, #messages)

            addon:ToggleMainWindowTransparency()
        end)

        assert.is_true(addon.db.mainWindowTransparent)
        assert.equals(0, addon.mainFrame.chrome.bg[4])
    end)

    it("is click-through unless Control is held", function()
        local controlDown = false
        local function mouse_frame(enabled)
            return {
                mouseEnabled = enabled,
                EnableMouse = function(self, value)
                    self.mouseEnabled = value
                end,
                IsMouseEnabled = function(self)
                    return self.mouseEnabled
                end,
            }
        end

        local child = mouse_frame(true)
        local decorativeChild = mouse_frame(false)
        local mainFrame = mouse_frame(true)
        mainFrame.GetChildren = function()
            return child, decorativeChild
        end
        mainFrame.SetAlpha = function() end

        local addon = load_main_window({
            db = {
                mainWindowTransparent = true,
            },
            mainFrame = mainFrame,
        })

        loader.with_globals({
            IsControlKeyDown = function()
                return controlDown
            end,
        }, function()
            addon:ApplyMainWindowAlpha()
            assert.is_false(mainFrame.mouseEnabled)
            assert.is_false(child.mouseEnabled)
            assert.is_false(decorativeChild.mouseEnabled)

            controlDown = true
            addon:ApplyMainWindowAlpha()
            assert.is_true(mainFrame.mouseEnabled)
            assert.is_true(child.mouseEnabled)
            assert.is_false(decorativeChild.mouseEnabled)

            controlDown = false
            addon:ApplyMainWindowAlpha()
            assert.is_false(mainFrame.mouseEnabled)
            assert.is_false(child.mouseEnabled)

            addon.db.mainWindowTransparent = false
            addon:ApplyMainWindowAlpha()
            assert.is_true(mainFrame.mouseEnabled)
            assert.is_true(child.mouseEnabled)
            assert.is_false(decorativeChild.mouseEnabled)
        end)
    end)
end)
