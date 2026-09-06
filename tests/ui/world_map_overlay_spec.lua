local loader = require("tests.helpers.addon_loader")

local function load_overlay(addon)
    return loader.load_module("UI/WorldMapOverlay.lua", addon or {}, {})
end

local function make_frame()
    local frame = {
        children = {},
        points = {},
        shown = false,
        frameLevel = 10,
    }

    function frame:SetSize(width, height)
        self.width = width
        self.height = height
    end

    function frame:SetPoint(...)
        self.points[#self.points + 1] = { ... }
    end

    function frame:ClearAllPoints()
        self.points = {}
    end

    function frame:SetParent(parent)
        self.parent = parent
    end

    function frame:GetParent()
        return self.parent
    end

    function frame:EnableMouse(enabled)
        self.mouseEnabled = enabled
    end

    function frame:SetToplevel(enabled)
        self.toplevel = enabled
    end

    function frame:SetFrameLevel(level)
        self.frameLevel = level
    end

    function frame:GetFrameLevel()
        return self.frameLevel
    end

    function frame:Hide()
        self.shown = false
    end

    function frame:Show()
        self.shown = true
    end

    function frame:SetShown(shown)
        self.shown = shown == true
    end

    function frame:SetScript(scriptName, handler)
        self.scripts = self.scripts or {}
        self.scripts[scriptName] = handler
    end

    function frame:SetText(text)
        self.text = text
    end

    function frame:SetTextColor(r, g, b, a)
        self.textColor = { r, g, b, a }
    end

    function frame:CreateTexture(_, layer)
        local texture = make_frame()
        texture.layer = layer
        texture.SetDrawLayer = function(_, drawLayer, subLevel)
            texture.drawLayer = drawLayer
            texture.drawSubLevel = subLevel
        end
        texture.SetColorTexture = function(_, r, g, b, a)
            texture.color = { r, g, b, a }
        end
        texture.SetTexture = function(_, path)
            texture.texture = path
        end
        texture.SetTexCoord = function(_, ...)
            texture.texCoord = { ... }
        end
        texture.SetVertexColor = function(_, r, g, b, a)
            texture.vertexColor = { r, g, b, a }
        end
        texture.SetAlpha = function(_, alpha)
            texture.alpha = alpha
        end
        self.children[#self.children + 1] = texture
        return texture
    end

    return frame
end

describe("UI/WorldMapOverlay", function()
    it("builds a normalized projection payload for the selected map", function()
        local addon = load_overlay()

        local payload = addon:BuildWorldMapProjectionPayload({
            title = "Old Ore Farming Map",
            mapID = 107,
            mapLabel = "Nagrand",
            selectedMapOptionIndex = 2,
            pins = {
                { mapID = 107, x = 14, y = 24, label = "Central ridge", tips = { "Stay moving." } },
                { mapID = 104, x = 0.45, y = 0.29, label = "Wrong map" },
                { mapID = 107, x = 0.25, y = 125, label = "Invalid" },
            },
        })

        assert.equals("Old Ore Farming Map", payload.title)
        assert.equals(107, payload.mapID)
        assert.equals("Nagrand", payload.mapName)
        assert.equals(2, payload.selectedMapOptionIndex)
        assert.equals(1, #payload.pins)
        assert.equals(0.14, payload.pins[1].x)
        assert.equals(0.24, payload.pins[1].y)
        assert.equals("Central ridge", payload.pins[1].label)
        assert.equals("Stay moving.", payload.pins[1].tips[1])
    end)

    it("reopens the standalone map from the stored world-map projection", function()
        local capturedOptions
        local addon = load_overlay({
            OpenStandaloneMapWindow = function(_, options)
                capturedOptions = options
            end,
        })
        addon.worldMapProjection = addon:BuildWorldMapProjectionPayload({
            title = "New Herb Farming Map",
            mapID = 100,
            mapLabel = "Hellfire Peninsula",
            pins = {
                { mapID = 100, x = 0.20, y = 0.30, label = "Route point" },
            },
            mapOptions = {
                {
                    mapID = 100,
                    label = "Hellfire Peninsula",
                    pins = {
                        { mapID = 100, x = 0.20, y = 0.30, label = "Route point" },
                    },
                },
            },
        })

        assert.is_true(addon:OpenWorldMapProjectionDetails())
        assert.equals("New Herb Farming Map", capturedOptions.title)
        assert.equals(100, capturedOptions.mapID)
        assert.equals(1, #capturedOptions.mapOptions)
        assert.equals("Route point", capturedOptions.pins[1].label)
    end)

    it("anchors projection controls to the map canvas viewport", function()
        local scroll_container = make_frame()
        local border_frame = make_frame()
        local created_frames = {}

        loader.with_globals({
            WorldMapFrame = {
                ScrollContainer = scroll_container,
                BorderFrame = border_frame,
            },
            CreateFrame = function(_, name, parent)
                local frame = make_frame()
                frame.name = name
                frame.parent = parent
                created_frames[#created_frames + 1] = frame
                return frame
            end,
        }, function()
            local addon = load_overlay({})
            local controls = addon:EnsureWorldMapProjectionControls()

            assert.equals(scroll_container, controls.parent)
            assert.equals("BOTTOMLEFT", controls.points[1][1])
            assert.equals(scroll_container, controls.points[1][2])
            assert.equals("BOTTOMLEFT", controls.points[1][3])
            assert.equals(16, controls.points[1][4])
            assert.equals(16, controls.points[1][5])
            assert.equals("Details", controls.detailsButton.text)
            assert.equals("Clear Pins", controls.clearButton.text)
            assert.equals(3, #created_frames)
        end)
    end)

    it("creates visible overlay textures for world map route pins", function()
        loader.with_globals({
            GoldTrackerWorldMapRoutePinMixin = false,
            GoldTrackerWorldMapRouteDataProviderMixin = false,
            CreateFromMixins = function(base)
                local copied = {}
                for key, value in pairs(base or {}) do
                    copied[key] = value
                end
                return copied
            end,
            MapCanvasPinMixin = {
                OnReleased = function() end,
            },
            MapCanvasDataProviderMixin = {},
        }, function()
            local addon = load_overlay({})
            local pin = make_frame()
            pin.Number = make_frame()
            pin.SetScale = function(self, scale)
                self.scale = scale
            end
            pin.RegisterForClicks = function(self, clicks)
                self.clicks = clicks
            end
            pin.SetMouseClickEnabled = function(self, enabled)
                self.mouseClickEnabled = enabled
            end
            pin.SetMouseMotionEnabled = function(self, enabled)
                self.mouseMotionEnabled = enabled
            end
            pin.SetIgnoreGlobalPinScale = function(self, enabled)
                self.ignoreGlobalPinScale = enabled
            end
            pin.UseFrameLevelType = function(self, frameLevelType)
                self.frameLevelType = frameLevelType
            end
            pin.SetScalingLimits = function(self, minimum, preferred, maximum)
                self.scalingLimits = { minimum, preferred, maximum }
            end
            for key, value in pairs(_G.GoldTrackerWorldMapRoutePinMixin) do
                if pin[key] == nil then
                    pin[key] = value
                end
            end

            _G.GoldTrackerWorldMapRoutePinMixin.OnAcquired(
                pin,
                { addon = addon },
                { mapID = 100, x = 0.2, y = 0.3 },
                1,
                1
            )

            assert.equals("PIN_FRAME_LEVEL_TOPMOST", pin.frameLevelType)
            assert.equals("LeftButtonUp", pin.clicks)
            assert.is_true(pin.mouseClickEnabled)
            assert.is_true(pin.mouseMotionEnabled)
            assert.is_table(pin.Ring)
            assert.is_table(pin.Icon)
            assert.equals("OVERLAY", pin.Ring.drawLayer)
            assert.equals(6, pin.Ring.drawSubLevel)
            assert.equals("OVERLAY", pin.Icon.drawLayer)
            assert.equals(7, pin.Icon.drawSubLevel)
            assert.equals("Interface\\Icons\\INV_Misc_Map02", pin.Icon.texture)
            assert.is_true(pin.Ring.shown)
            assert.is_true(pin.Icon.shown)
            assert.is_true(pin.shown)
        end)
    end)
end)
