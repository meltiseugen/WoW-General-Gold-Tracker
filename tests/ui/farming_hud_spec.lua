local loader = require("tests.helpers.addon_loader")

local function load_guidance()
    local addon = {}
    addon = loader.load_module("UI/MapAreaOverlay.lua", addon, {})
    return loader.load_module("UI/FarmingHud.lua", addon, {})
end

describe("UI/FarmingHud", function()
    it("detects whether the player is inside a farming area and finds the nearest return point", function()
        local addon = load_guidance()
        local pins = {
            { mapID = 1, x = 0.40, y = 0.40, areaID = "farm" },
            { mapID = 1, x = 0.50, y = 0.40, areaID = "farm" },
            { mapID = 1, x = 0.50, y = 0.50, areaID = "farm" },
            { mapID = 1, x = 0.40, y = 0.50, areaID = "farm" },
        }

        local inside = addon.FarmGuidance:Evaluate(pins, 1, 0.45, 0.45)
        assert.equals("area", inside.mode)
        assert.is_true(inside.inside)
        assert.equals(0, inside.normalizedDistance)

        local outside = addon.FarmGuidance:Evaluate(pins, 1, 0.80, 0.45)
        assert.equals("area", outside.mode)
        assert.is_false(outside.inside)
        assert.is_true(outside.targetX < 0.80)
        assert.is_true(outside.normalizedDistance > 0)
    end)

    it("measures deviation from the nearest point on an ordered route", function()
        local addon = load_guidance()
        local result = addon.FarmGuidance:Evaluate({
            { mapID = 1, x = 0.20, y = 0.50, isRoute = true, routeID = "ore" },
            { mapID = 1, x = 0.80, y = 0.50, isRoute = true, routeID = "ore" },
        }, 1, 0.50, 0.70)

        assert.equals("route", result.mode)
        assert.near(0.50, result.targetX, 0.0001)
        assert.near(0.50, result.targetY, 0.0001)
        assert.near(0.20, result.normalizedDistance, 0.0001)
    end)

    it("reuses precomputed farming-area geometry during tracking updates", function()
        local addon = load_guidance()
        local buildCount = 0
        addon.MapAreaOverlay.BuildPolygons = function()
            buildCount = buildCount + 1
            return {}
        end
        local polygons = {
            {
                points = {
                    { x = 0.40, y = 0.40 },
                    { x = 0.50, y = 0.40 },
                    { x = 0.50, y = 0.50 },
                    { x = 0.40, y = 0.50 },
                },
            },
        }

        local result = addon.FarmGuidance:Evaluate({}, 1, 0.45, 0.45, polygons)

        assert.equals("area", result.mode)
        assert.is_true(result.inside)
        assert.equals(0, buildCount)
    end)

    it("records a bounded-distance breadcrumb trail and projects new points", function()
        local addon = load_guidance()
        local refreshes = 0
        addon.farmingHudRuntime = {
            farmID = "farm-1",
            active = { farm = { name = "Ore loop" } },
            context = { mapName = "Durotar" },
            settings = { breadcrumbs = true },
            breadcrumbsByMap = {},
            breadcrumbProjectionKeys = {},
        }
        addon.ProjectMapRouteToWorldMap = function(_, payload)
            refreshes = refreshes + 1
            assert.is_true(payload.background)
            return true
        end

        assert.is_true(addon:RecordFarmingHudBreadcrumb(1, 0.10, 0.10))
        assert.is_false(addon:RecordFarmingHudBreadcrumb(1, 0.101, 0.101))
        assert.is_true(addon:RecordFarmingHudBreadcrumb(1, 0.20, 0.20))
        assert.equals(2, #addon.farmingHudRuntime.breadcrumbsByMap[1])
        assert.equals(2, refreshes)
    end)

    it("updates the live farming HUD breadcrumb button", function()
        local addon = load_guidance()
        local function button()
            return {
                SetText = function(self, text) self.text = text end,
                SetAlpha = function(self, alpha) self.alpha = alpha end,
                SetShown = function(self, shown) self.shown = shown end,
                SetEnabled = function(self, enabled) self.enabled = enabled end,
            }
        end
        addon.farmingHudFrame = {
            trailButton = button(),
            nextButton = button(),
            stopButton = button(),
        }
        addon.farmingHudRuntime = {
            active = { canGoNext = true },
            settings = { minimapOverlay = false, breadcrumbs = false },
        }

        assert.is_true(addon:RefreshFarmingHudOverlayButtons())
        assert.equals("Trail OFF", addon.farmingHudFrame.trailButton.text)
        assert.equals(0.55, addon.farmingHudFrame.trailButton.alpha)
        assert.is_true(addon.farmingHudFrame.nextButton.shown)
        assert.is_true(addon.farmingHudFrame.nextButton.enabled)
        assert.is_true(addon.farmingHudFrame.stopButton.enabled)

        addon.farmingHudRuntime.settings.breadcrumbs = true
        addon.farmingHudRuntime.active.canGoNext = false
        assert.is_true(addon:RefreshFarmingHudOverlayButtons())
        assert.equals("Trail ON", addon.farmingHudFrame.trailButton.text)
        assert.equals(1, addon.farmingHudFrame.trailButton.alpha)
        assert.is_false(addon.farmingHudFrame.nextButton.shown)
        assert.is_false(addon.farmingHudFrame.nextButton.enabled)
    end)

    it("keeps the farming HUD usable when every guidance option is off", function()
        local addon = load_guidance()
        addon.farmingHudRuntime = {
            active = { farm = { id = 1 } },
            settings = {
                areaIndicator = false,
                routeDeviation = false,
                recoveryArrow = false,
                breadcrumbs = false,
            },
        }
        addon.farmingHudFrame = {
            IsShown = function() return true end,
            statusText = {
                SetText = function(self, text) self.text = text end,
                SetTextColor = function() end,
            },
            detailText = {
                SetText = function(self, text) self.text = text end,
            },
            arrow = {
                SetShown = function(self, shown) self.shown = shown end,
            },
        }

        assert.is_true(addon:UpdateFarmingHudTracking(0, true))
        assert.equals("FARM GUIDANCE OFF", addon.farmingHudFrame.statusText.text)
        assert.is_false(addon.farmingHudFrame.arrow.shown)
    end)

    it("puts Trail, Next, and Stop actions on the floating HUD", function()
        local function widget()
            local value = { scripts = {} }
            local no_op = function() end
            value.SetSize = no_op
            value.SetPoint = no_op
            value.SetFrameStrata = no_op
            value.SetClampedToScreen = no_op
            value.SetMovable = no_op
            value.EnableMouse = no_op
            value.RegisterForDrag = no_op
            value.RegisterEvent = no_op
            value.SetJustifyH = no_op
            value.SetWordWrap = no_op
            value.SetTextColor = no_op
            value.Hide = no_op
            value.SetScript = function(self, event, callback) self.scripts[event] = callback end
            value.CreateFontString = function() return widget() end
            return value
        end

        loader.with_globals({
            UIParent = widget(),
            BackdropTemplateMixin = false,
            CreateFrame = function() return widget() end,
        }, function()
            local buttons = {}
            local theme = {
                CreateButton = function(_, _, _, _, text)
                    local control = widget()
                    buttons[text] = control
                    return control
                end,
            }
            local addon = {}
            addon = loader.load_module("UI/MapAreaOverlay.lua", addon, {})
            addon = loader.load_module("UI/FarmingHud.lua", addon, { JanisTheme = theme })
            local active = { farm = { id = "farm-1" }, canGoNext = true }
            local toggledSetting
            local navigationDirection
            local stoppedFarmID
            addon.GetActiveCustomFarmRoutePlan = function() return active end
            addon.ToggleActiveCustomFarmGuidanceSetting = function(_, key) toggledSetting = key end
            addon.NavigateActiveCustomFarmRoutePlanStep = function(_, direction) navigationDirection = direction end
            addon.StopCustomFarmRoutePlan = function(_, farmID) stoppedFarmID = farmID end

            local frame = addon:CreateFarmingHud()
            assert.equals(buttons["Trail OFF"], frame.trailButton)
            assert.equals(buttons.Next, frame.nextButton)
            assert.equals(buttons.Stop, frame.stopButton)

            frame.trailButton.scripts.OnClick()
            frame.nextButton.scripts.OnClick()
            frame.stopButton.scripts.OnClick()
            assert.equals("breadcrumbs", toggledSetting)
            assert.equals(1, navigationDirection)
            assert.equals("farm-1", stoppedFarmID)
        end)
    end)
end)
