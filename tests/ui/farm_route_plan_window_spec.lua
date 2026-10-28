local loader = require("tests.helpers.addon_loader")

describe("UI/FarmRoutePlanWindow", function()
    it("enables Overview Map and opens the numbered stops for a route spanning maps", function()
        local widget = require("tests.helpers.map_ui").widget
        local theme = {
            CreatePanel = function(_, parent) return widget(nil, nil, parent) end,
            CreateButton = function(_, parent) return widget(nil, nil, parent) end,
            ApplyWindowChrome = function(_, frame) return frame end,
            RegisterSpecialFrame = function() end,
        }
        local addon = loader.load_module("Core/FarmRoutePlanner.lua", {})
        loader.load_module("UI/FarmRoutePlanWindow.lua", addon, { JanisTheme = theme })
        addon.GetCustomFarmByID = function() return { id = 1, name = "World tour" } end
        addon.BuildCustomFarmRoutePlan = function()
            return {
                { key = "a", mapID = 104, mapName = "Shadowmoon Valley", x = 0.5, y = 0.7,
                    confidence = "exact", confidenceLabel = "Exact", candidates = {}, entries = {} },
                { key = "b", mapID = 122, mapName = "Isle of Quel'Danas", x = 0.6, y = 0.3,
                    confidence = "exact", confidenceLabel = "Exact", candidates = {}, entries = {} },
                { key = "c", name = "Old catalog entry", confidence = "unknown",
                    confidenceLabel = "Location unavailable", candidates = {}, entries = {} },
            }
        end
        addon.GetCustomFarmRoutePlanRun = function() return { completed = {} }, "Goldie" end
        local opened
        addon.OpenStandaloneMapWindow = function(_, options) opened = options end
        loader.with_globals({ CreateFrame = widget, C_Map = false }, function()
            assert.is_true(addon:OpenFarmRoutePlanWindow(1))
            local button = addon.farmRoutePlanFrame.overviewButton
            assert.is_true(button.enabled)
            button.scripts.OnClick()
            assert.equals(2, #opened.mapOptions)
            assert.equals(104, opened.mapOptions[1].mapID)
            assert.equals(122, opened.mapOptions[2].mapID)
            assert.equals(2, opened.mapOptions[2].pins[1].routeOrder)
            assert.matches("1 stop has no map data", opened.detailLinesBuilder()[2].text)
        end)
    end)

    it("uses the supported GameTooltip SetText signature for overview help", function()
        local file = assert(io.open("UI/FarmRoutePlanWindow.lua", "r"))
        local source = file:read("*a")
        file:close()

        assert.matches("GameTooltip:SetText%(self%.tooltipText, 1%.0, 0%.82, 0%.18%)", source)
        assert.is_nil(source:find("GameTooltip:SetText(self.tooltipText, 1.0, 0.82, 0.18, true)", 1, true))
    end)

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
