local loader = require("tests.helpers.addon_loader")

local function button()
    return {
        SetShown = function(self, shown) self.shown = shown end,
        SetText = function(self, text) self.text = text end,
        SetSelected = function(self, selected) self.selected = selected end,
    }
end

local function load_my_farms(addon)
    return loader.load_module("UI/MyFarmsWindow.lua", addon or {}, {
        JanisTheme = {},
    })
end

describe("UI/MyFarmsWindow route run button", function()
    it("shows Start for a planned farm that is not active", function()
        local farm = { id = "farm-1" }
        local addon = load_my_farms({
            IsCustomFarmRoutePlanActive = function(_, farmID)
                assert.equals(farm.id, farmID)
                return false
            end,
            myFarmsFrame = { routeRunButton = button() },
        })

        assert.is_false(addon:RefreshMyFarmsRouteRunButton(farm, true))
        assert.is_true(addon.myFarmsFrame.routeRunButton.shown)
        assert.equals("Start", addon.myFarmsFrame.routeRunButton.text)
        assert.is_false(addon.myFarmsFrame.routeRunButton.selected)
    end)

    it("changes to Stop while the selected farm is active", function()
        local farm = { id = "farm-1" }
        local addon = load_my_farms({
            IsCustomFarmRoutePlanActive = function() return true end,
            myFarmsFrame = { routeRunButton = button() },
        })

        assert.is_true(addon:RefreshMyFarmsRouteRunButton(farm, true))
        assert.is_true(addon.myFarmsFrame.routeRunButton.shown)
        assert.equals("Stop", addon.myFarmsFrame.routeRunButton.text)
        assert.is_true(addon.myFarmsFrame.routeRunButton.selected)
    end)

    it("hides the control until the farm has a route plan", function()
        local addon = load_my_farms({
            IsCustomFarmRoutePlanActive = function()
                error("inactive farms without plans must not query route state")
            end,
            myFarmsFrame = { routeRunButton = button() },
        })

        assert.is_false(addon:RefreshMyFarmsRouteRunButton({ id = "farm-1" }, false))
        assert.is_false(addon.myFarmsFrame.routeRunButton.shown)
        assert.equals("Start", addon.myFarmsFrame.routeRunButton.text)
    end)
end)
