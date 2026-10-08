local loader = require("tests.helpers.addon_loader")

describe("UI/FarmRoutePlanWindow", function()
    it("brings an already-open route plan in front through managed focus", function()
        local focusedFrame
        local refreshed = false
        local frame = {
            Show = function(self)
                self.shown = true
            end,
            Raise = function(self)
                self.raised = true
            end,
        }
        local addon = {}

        addon = loader.load_module("UI/FarmRoutePlanWindow.lua", addon, {
            JanisTheme = {
                BringManagedWindowToFront = function(_, target)
                    focusedFrame = target
                end,
            },
        })
        addon.farmRoutePlanFrame = frame
        addon.GetCustomFarmByID = function(_, farmID)
            return farmID == "farm-1" and { id = farmID } or nil
        end
        addon.RefreshFarmRoutePlanWindow = function()
            refreshed = true
        end

        assert.is_true(addon:OpenFarmRoutePlanWindow("farm-1"))
        assert.is_true(frame.shown)
        assert.equals("farm-1", frame.selectedFarmID)
        assert.equals(frame, focusedFrame)
        assert.is_true(refreshed)
        assert.is_nil(frame.raised)
    end)
end)
