local loader = require("tests.helpers.addon_loader")

local function load_theme()
    local lib_chunk, lib_err = loadfile("Libs/JanisTheme-1.0/JanisTheme-1.0.lua")
    assert(lib_chunk, lib_err)
    lib_chunk()

    local addon = {}
    local _, ns = loader.load_module("UI/Theme.lua", addon)
    return ns.JanisTheme
end

local function frame(name, strata, level)
    local scripts = {}
    return {
        name = name,
        strata = strata or "DIALOG",
        level = level or 0,
        shown = true,
        scripts = scripts,
        GetName = function(self)
            return self.name
        end,
        GetParent = function(self)
            return self.parent
        end,
        SetParent = function(self, parent)
            self.parent = parent
        end,
        IsShown = function(self)
            return self.shown
        end,
        GetFrameStrata = function(self)
            return self.strata
        end,
        SetFrameStrata = function(self, value)
            self.strata = value
        end,
        GetFrameLevel = function(self)
            return self.level
        end,
        SetFrameLevel = function(self, value)
            self.level = value
        end,
        SetToplevel = function(self, value)
            self.toplevel = value
        end,
        Raise = function(self)
            self.raised = true
        end,
        HookScript = function(_, event, callback)
            scripts[event] = callback
        end,
    }
end

describe("UI/Theme focus management", function()
    it("demotes the main frame when another addon window is brought forward", function()
        local watcher_script = nil
        local main = frame("GoldTrackerMainFrame", "DIALOG", 500)
        local history = frame("GoldTrackerHistoryFrame", "DIALOG", 510)

        local theme = nil
        loader.with_globals({
            CreateFrame = function()
                return {
                    SetScript = function(_, event, callback)
                        if event == "OnUpdate" then
                            watcher_script = callback
                        end
                    end,
                }
            end,
        }, function()
            theme = load_theme()
            theme.windowFocusFrames = nil
            theme.addonFocusFrames = nil
            theme.windowFocusWatcher = nil
            theme.windowFocusLevel = nil
            theme:RegisterWindowForFocus(main, "addon")
            theme:RegisterWindowForFocus(history, "addon")
        end)

        theme:BringManagedWindowToFront(main)
        theme:BringManagedWindowToFront(history)

        assert.is_function(watcher_script)
        assert.equals("HIGH", main.strata)
        assert.equals("DIALOG", history.strata)
        assert.is_true(history.toplevel)
        assert.is_true(history.raised)
        assert.is_true(history.level > main.level)
    end)

    it("uses GetMouseFoci list results to focus a managed parent window", function()
        local watcher_script = nil
        local parent = frame("GoldTrackerMainFrame", "DIALOG", 10)
        local child = frame("GoldTrackerMainButton", nil, 0)
        child:SetParent(parent)

        local theme = nil
        loader.with_globals({
            CreateFrame = function()
                return {
                    SetScript = function(_, event, callback)
                        if event == "OnUpdate" then
                            watcher_script = callback
                        end
                    end,
                }
            end,
        }, function()
            theme = load_theme()
            theme.windowFocusFrames = nil
            theme.addonFocusFrames = nil
            theme.windowFocusWatcher = nil
            theme.windowFocusLevel = nil
            theme:RegisterWindowForFocus(parent, "addon")
        end)

        assert.is_function(watcher_script)

        loader.with_globals({
            IsMouseButtonDown = function(button)
                return button == "LeftButton"
            end,
            GetMouseFoci = function()
                return { child }
            end,
        }, function()
            watcher_script({})
        end)

        assert.is_true(parent.raised)
        assert.is_true(parent.level > 10)
    end)
end)
