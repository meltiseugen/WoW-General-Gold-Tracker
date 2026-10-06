local loader = require("tests.helpers.addon_loader")
local unpack_values = table.unpack or unpack

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

    it("never manages the Blizzard world map as an external focus window", function()
        local world_map = frame("WorldMapFrame", "HIGH", 10)
        local theme = nil

        loader.with_globals({
            WorldMapFrame = world_map,
            UIPanelWindows = {
                WorldMapFrame = {},
            },
            CreateFrame = function()
                return {
                    SetScript = function() end,
                }
            end,
        }, function()
            theme = load_theme()

            assert.is_false(theme:IsKnownExternalWindow(world_map))
            assert.is_nil(theme:RegisterExternalWindowForFocus(world_map))
            theme:RegisterExternalFocusFrames({ "WorldMapFrame" })
        end)

        assert.is_nil(world_map.goldTrackerWindowFocusRegistered)
        assert.is_nil(world_map.goldTrackerWindowFocusHooked)
        assert.is_nil(world_map.raised)
        assert.equals("HIGH", world_map.strata)
        assert.equals(10, world_map.level)
    end)
end)

describe("UI/Theme text column measurement", function()
    it("uses unbounded rendered widths and ignores hidden rows", function()
        local theme = nil
        loader.with_globals({
            CreateFrame = function()
                return {
                    SetScript = function() end,
                }
            end,
        }, function()
            theme = load_theme()
        end)

        local rows = {
            {
                IsShown = function()
                    return true
                end,
                itemText = {
                    GetUnboundedStringWidth = function()
                        return 247.2
                    end,
                },
            },
            {
                IsShown = function()
                    return false
                end,
                itemText = {
                    GetUnboundedStringWidth = function()
                        return 900
                    end,
                },
            },
        }

        assert.equals(266, theme:GetRequiredTextColumnWidth(rows, "itemText", 160, {
            padding = 8,
            leadingWidth = 10,
        }))
    end)

    it("temporarily removes the width constraint for legacy font strings", function()
        local theme = nil
        loader.with_globals({
            CreateFrame = function()
                return {
                    SetScript = function() end,
                }
            end,
        }, function()
            theme = load_theme()
        end)

        local text = {
            width = 120,
            GetWidth = function(self)
                return self.width
            end,
            SetWidth = function(self, width)
                self.width = width
            end,
            GetStringWidth = function(self)
                return self.width == 10000 and 312 or self.width
            end,
        }

        assert.equals(320, theme:GetRequiredTextColumnWidth({ { itemText = text } }, "itemText", 150, {
            padding = 8,
        }))
        assert.equals(120, text.width)
    end)
end)

describe("UI/Theme Explorer list layout", function()
    it("uses the shared field, action, and tab spacing contract", function()
        local theme = nil
        loader.with_globals({
            CreateFrame = function()
                return {
                    SetScript = function() end,
                }
            end,
        }, function()
            theme = load_theme()
        end)

        local function control()
            return {
                points = {},
                ClearAllPoints = function(self)
                    self.points = {}
                end,
                SetPoint = function(self, ...)
                    self.points[#self.points + 1] = { ... }
                end,
                SetWidth = function(self, width)
                    self.width = width
                end,
                SetHeight = function(self, height)
                    self.height = height
                end,
            }
        end

        local panel = {}
        local firstLabel = control()
        local firstInput = control()
        local secondLabel = control()
        local secondInput = control()
        local primaryAction = control()
        local secondaryAction = control()
        local firstTab = control()
        local secondTab = control()

        theme:LayoutExplorerFilterFields(panel, {
            { label = firstLabel, control = firstInput, width = 210 },
            { label = secondLabel, control = secondInput, width = 96 },
        })
        theme:LayoutExplorerActionButtons(panel, { primaryAction, secondaryAction })
        theme:LayoutExplorerTabs(panel, { firstTab, secondTab })

        assert.same({ "TOPLEFT", panel, "TOPLEFT", 14, -10 }, firstLabel.points[1])
        assert.same({ "TOPLEFT", panel, "TOPLEFT", 14, -27 }, firstInput.points[1])
        assert.same({ "TOPLEFT", panel, "TOPLEFT", 248, -10 }, secondLabel.points[1])
        assert.same({ "BOTTOMRIGHT", panel, "BOTTOMRIGHT", -14, 12 }, primaryAction.points[1])
        assert.same({ "RIGHT", primaryAction, "LEFT", -8, 0 }, secondaryAction.points[1])
        assert.same({ "TOPLEFT", panel, "TOPLEFT", 14, -54 }, firstTab.points[1])
        assert.same({ "LEFT", firstTab, "RIGHT", 8, 0 }, secondTab.points[1])
        assert.equals(24, firstTab.height)
    end)
end)

describe("UI/Theme list window maximization", function()
    it("maximizes to the parent and restores the previous size and anchor", function()
        local theme = nil
        loader.with_globals({
            CreateFrame = function()
                return {
                    SetScript = function() end,
                }
            end,
        }, function()
            theme = load_theme()
        end)

        local parent = {}
        local points = {
            { "CENTER", parent, "CENTER", 24, -18 },
        }
        local target = {
            width = 1040,
            height = 640,
            movable = true,
            resizable = true,
            resizeButton = {
                Hide = function(self) self.hidden = true end,
                Show = function(self) self.hidden = false end,
            },
            GetSize = function(self) return self.width, self.height end,
            SetSize = function(self, width, height)
                self.width = width
                self.height = height
            end,
            GetNumPoints = function() return #points end,
            GetPoint = function(_, index)
                return unpack_values(points[index])
            end,
            ClearAllPoints = function()
                points = {}
            end,
            SetPoint = function(_, ...)
                points[#points + 1] = { ... }
            end,
            IsMovable = function(self) return self.movable end,
            SetMovable = function(self, value) self.movable = value end,
            IsResizable = function(self) return self.resizable end,
            SetResizable = function(self, value) self.resizable = value end,
        }
        local toggles = {}
        target.goldTrackerMaximizeOptions = {
            parent = parent,
            padding = 20,
            onToggle = function(_, maximized)
                toggles[#toggles + 1] = maximized
            end,
        }

        assert.is_true(theme:SetWindowMaximized(target, true))
        assert.is_true(target.goldTrackerIsMaximized)
        assert.is_false(target.movable)
        assert.is_false(target.resizable)
        assert.is_true(target.resizeButton.hidden)
        assert.same({ "TOPLEFT", parent, "TOPLEFT", 20, -20 }, points[1])
        assert.same({ "BOTTOMRIGHT", parent, "BOTTOMRIGHT", -20, 20 }, points[2])

        assert.is_false(theme:SetWindowMaximized(target, false))
        assert.is_false(target.goldTrackerIsMaximized)
        assert.equals(1040, target.width)
        assert.equals(640, target.height)
        assert.is_true(target.movable)
        assert.is_true(target.resizable)
        assert.is_false(target.resizeButton.hidden)
        assert.same({ "CENTER", parent, "CENTER", 24, -18 }, points[1])
        assert.same({ true, false }, toggles)
    end)
end)

describe("UI/Theme progress bars", function()
    it("shows incomplete progress and hides the completed bar container", function()
        local theme = nil
        loader.with_globals({
            CreateFrame = function()
                return {
                    SetScript = function() end,
                }
            end,
        }, function()
            theme = load_theme()
        end)

        local owner = {
            progressBar = {
                SetMinMaxValues = function(self, minimum, maximum)
                    self.minimum = minimum
                    self.maximum = maximum
                end,
                SetValue = function(self, value)
                    self.value = value
                end,
            },
            progressBackdrop = {
                SetShown = function(self, shown)
                    self.shown = shown
                end,
            },
        }

        assert.is_false(theme:SetProgressBarProgress(owner, 3, 10))
        assert.is_true(owner.progressBackdrop.shown)
        assert.is_false(owner.progressComplete)
        assert.equals(3, owner.progressBar.value)

        assert.is_true(theme:SetProgressBarProgress(owner, 10, 10))
        assert.is_false(owner.progressBackdrop.shown)
        assert.is_true(owner.progressComplete)
        assert.equals(10, owner.progressBar.value)

        assert.is_false(theme:SetProgressBarProgress(owner, 10, 10, false))
        assert.is_true(owner.progressBackdrop.shown)
        assert.is_false(owner.progressComplete)
    end)
end)
