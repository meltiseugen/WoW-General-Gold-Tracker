local loader = require("tests.helpers.addon_loader")

local function region()
    return {
        SetShown = function(self, shown) self.shown = shown end,
    }
end

local function load_main_window(addon)
    return loader.load_module("UI/MainWindow.lua", addon or {}, {
        JanisTheme = {},
    })
end

describe("UI/MainWindow active farm route controls", function()
    it("leaves the highlight area visible while a farm is active", function()
        local active = {
            farm = { name = "Old World Tour" },
        }
        local addon = load_main_window({
            db = { mainLootStreamExpanded = false },
            GetActiveCustomFarmRoutePlan = function() return active end,
            IsMainLootStreamExpanded = function() return false end,
            mainFrame = {
                mainLastHighlightContainer = region(),
            },
        })

        assert.equals(active, addon:RefreshMainFarmRouteControls())
        assert.is_true(addon.mainFrame.mainLastHighlightContainer.shown)
    end)

    it("still returns the active farm when the main tracker has no route card", function()
        local active = { farm = { name = "Single stop" } }
        local addon = load_main_window({
            db = { mainLootStreamExpanded = false },
            GetActiveCustomFarmRoutePlan = function() return active end,
            mainFrame = {},
        })

        assert.equals(active, addon:RefreshMainFarmRouteControls())
    end)

    it("hides the highlight area only while the loot stream is expanded", function()
        local addon = load_main_window({
            db = { mainLootStreamExpanded = true },
            GetActiveCustomFarmRoutePlan = function() return nil end,
            IsMainLootStreamExpanded = function() return true end,
            mainFrame = {
                mainLastHighlightContainer = region(),
            },
        })

        addon:RefreshMainFarmRouteControls()

        assert.is_false(addon.mainFrame.mainLastHighlightContainer.shown)
    end)
end)
