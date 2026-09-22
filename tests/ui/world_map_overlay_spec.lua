local loader = require("tests.helpers.addon_loader")

local function load_overlay(addon)
    addon = addon or {}
    loader.load_module("UI/MapAreaOverlay.lua", addon, {})
    return loader.load_module("UI/WorldMapOverlay.lua", addon, {})
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

    function frame:GetWidth()
        return self.width or 140
    end

    function frame:GetHeight()
        return self.height or 140
    end

    function frame:SetPoint(...)
        self.points[#self.points + 1] = { ... }
    end

    function frame:SetAllPoints(parent)
        self.allPointsParent = parent
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

    function frame:SetFrameStrata(strata)
        self.frameStrata = strata
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

    function frame:RegisterEvent(eventName)
        self.events = self.events or {}
        self.events[#self.events + 1] = eventName
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

    function frame:CreateLine(_, layer, _, subLevel)
        local line = make_frame()
        line.layer = layer
        line.subLevel = subLevel
        line.SetStartPoint = function(_, ...)
            line.startPoint = { ... }
        end
        line.SetEndPoint = function(_, ...)
            line.endPoint = { ... }
        end
        line.SetThickness = function(_, thickness)
            line.thickness = thickness
        end
        line.SetColorTexture = function(_, r, g, b, a)
            line.color = { r, g, b, a }
        end
        self.children[#self.children + 1] = line
        return line
    end

    return frame
end

describe("UI/WorldMapOverlay", function()
    it("does not eagerly load Blizzard map addons during addon startup", function()
        local loaded_addons = {}

        loader.with_globals({
            C_AddOns = {
                LoadAddOn = function(addon_name)
                    loaded_addons[#loaded_addons + 1] = addon_name
                end,
            },
        }, function()
            load_overlay({})
        end)

        assert.same({}, loaded_addons)
    end)

    it("keeps world map pin hover handlers on the mixin instead of inherited XML scripts", function()
        local file = assert(io.open("UI/WorldMapOverlay.xml", "r"))
        local xml = file:read("*a")
        file:close()

        assert.is_nil(xml:find("<OnEnter", 1, true))
        assert.is_nil(xml:find("<OnLeave", 1, true))
    end)

    it("builds a normalized projection payload for the selected map", function()
        local addon = load_overlay()

        local payload = addon:BuildWorldMapProjectionPayload({
            title = "Old Ore Farming Map",
            mapID = 107,
            mapLabel = "Nagrand",
            selectedMapOptionIndex = 2,
            pins = {
                {
                    mapID = 107,
                    x = 14,
                    y = 24,
                    label = "Central ridge",
                    farmAction = "Mine: Gather ore nodes along the ridge.",
                    tips = { "Stay moving." },
                },
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
        assert.equals("Mine: Gather ore nodes along the ridge.", payload.pins[1].farmAction)
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
                    id = "hellfire-main",
                    mapID = 100,
                    mapLabel = "Hellfire Peninsula",
                    label = "Hellfire Peninsula: Citadel perimeter",
                    location = "Citadel perimeter",
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
        assert.equals("hellfire-main", capturedOptions.mapOptions[1].id)
        assert.equals("Hellfire Peninsula", capturedOptions.mapOptions[1].mapLabel)
        assert.equals("Hellfire Peninsula: Citadel perimeter", capturedOptions.mapOptions[1].label)
        assert.equals("Citadel perimeter", capturedOptions.mapOptions[1].location)
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

            addon.worldMapProjections = { { title = "Ore" }, { title = "Herb" } }
            addon.worldMapProjection = addon.worldMapProjections[2]
            controls.clearButton.scripts.OnClick()
            assert.same({}, addon.worldMapProjections)
            assert.is_nil(addon.worldMapProjection)
        end)
    end)

    it("keeps route lines while showing filled areas for non-route locations", function()
        local deferredCallbacks = {}
        local worldMapFrame = {
            AddDataProvider = function(self, provider)
                self.provider = provider
                provider.GetMap = function()
                    return self.map
                end
            end,
            IsShown = function()
                return true
            end,
            SetMapID = function() end,
            SetFrameStrata = function(self, strata)
                self.frameStrata = strata
                self.frameStrataSetCount = (self.frameStrataSetCount or 0) + 1
            end,
            SetToplevel = function(self, enabled)
                self.toplevel = enabled
                self.toplevelSetCount = (self.toplevelSetCount or 0) + 1
            end,
            Raise = function(self)
                self.raised = true
                self.raiseCount = (self.raiseCount or 0) + 1
            end,
        }
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
            WorldMapFrame = worldMapFrame,
            C_Timer = {
                After = function(delay, callback)
                    assert.equals(0, delay)
                    deferredCallbacks[#deferredCallbacks + 1] = callback
                end,
            },
            CreateFrame = function()
                return make_frame()
            end,
            Minimap = false,
        }, function()
            local map = {
                GetMapID = function()
                    return 100
                end,
                GetCanvas = function()
                    local canvas = make_frame()
                    canvas:SetSize(500, 500)
                    return canvas
                end,
                RemoveAllPinsByTemplate = function(self, template)
                    self.removedTemplate = template
                end,
                AcquirePin = function(self, template, provider, pinData, pinIndex, pinCount)
                    local pin = make_frame()
                    pin.template = template
                    pin.provider = provider
                    pin.pinData = pinData
                    pin.pinIndex = pinIndex
                    pin.pinCount = pinCount
                    pin.SetPosition = function(_, x, y)
                        pin.position = { x, y }
                    end
                    return pin
                end,
            }
            worldMapFrame.map = map

            local messages = {}
            local addon, ns = load_overlay({
                Print = function(_, message)
                    messages[#messages + 1] = message
                end,
            })
            local demotionCount = 0
            ns.JanisTheme = {
                DemoteInactiveAddonWindows = function(_, activeFrame, strataOverride)
                    assert.equals(worldMapFrame, activeFrame)
                    assert.equals("LOW", strataOverride)
                    demotionCount = demotionCount + 1
                end,
            }

            assert.is_true(addon:ProjectMapRouteToWorldMap({
                title = "Ore",
                mapID = 100,
                pins = {
                    { mapID = 100, x = 0.20, y = 0.30, itemName = "Ore", isRoute = true, routeID = "ore" },
                    { mapID = 100, x = 0.30, y = 0.40, itemName = "Ore", isRoute = true, routeID = "ore" },
                    { mapID = 100, x = 0.35, y = 0.45, itemName = "Ore sample" },
                },
            }))
            assert.is_true(addon:ProjectMapRouteToWorldMap({
                title = "Herb",
                mapID = 100,
                pins = {
                    { mapID = 100, x = 0.40, y = 0.50, itemName = "Herb", isRoute = true, routeID = "herb" },
                    { mapID = 100, x = 0.50, y = 0.60, itemName = "Herb", isRoute = true, routeID = "herb" },
                },
            }))

            assert.equals(2, #addon.worldMapProjections)
            assert.is_nil(worldMapFrame.frameStrataSetCount)
            assert.is_nil(worldMapFrame.toplevelSetCount)
            assert.is_nil(worldMapFrame.raiseCount)
            assert.equals(2, demotionCount)
            assert.equals(2, #deferredCallbacks)

            deferredCallbacks[#deferredCallbacks]()
            assert.is_nil(worldMapFrame.frameStrataSetCount)
            assert.is_nil(worldMapFrame.toplevelSetCount)
            assert.is_nil(worldMapFrame.raiseCount)
            assert.equals(3, demotionCount)

            worldMapFrame.provider:RefreshAllData()

            assert.equals(0, #worldMapFrame.provider.acquiredPins)
            assert.is_true(#worldMapFrame.provider.worldMapAreaFillLines > 0)
            assert.is_true(#worldMapFrame.provider.worldMapAreaGlowLines > 0)
            assert.is_true(#worldMapFrame.provider.worldMapAreaBorderLines > 0)
            assert.same({ 0.08, 0.42, 1.0, 0.20 }, worldMapFrame.provider.worldMapAreaFillLines[1].color)
            assert.is_true(worldMapFrame.provider.worldMapAreaFillLines[1].shown)
            assert.equals(2, #worldMapFrame.provider.routeLines)
            local firstLine = worldMapFrame.provider.routeLines[1]
            local secondLine = worldMapFrame.provider.routeLines[2]
            local routeOverlay = worldMapFrame.provider.routeOverlay
            assert.equals(firstLine.parent, routeOverlay)
            assert.equals(secondLine.parent, routeOverlay)
            assert.equals(firstLine.startPoint[2], routeOverlay)
            assert.equals(routeOverlay.parent, routeOverlay.allPointsParent)
            assert.equals(110, routeOverlay.frameLevel)
            assert.is_false(routeOverlay.mouseEnabled)
            assert.same({ "TOPLEFT", firstLine.parent, 100, -150 }, firstLine.startPoint)
            assert.same({ "TOPLEFT", firstLine.parent, 150, -200 }, firstLine.endPoint)
            assert.same({ "TOPLEFT", secondLine.parent, 200, -250 }, secondLine.startPoint)
            assert.same({ "TOPLEFT", secondLine.parent, 250, -300 }, secondLine.endPoint)
            assert.is_true(worldMapFrame.provider.routeLines[1].shown)
            assert.is_true(worldMapFrame.provider.routeLines[2].shown)
        end)
    end)

    it("clears only projections owned by the requested standalone map", function()
        local addon = load_overlay({})
        local materialOnFirstMap = addon:BuildWorldMapProjectionPayload({
            title = "Ore",
            projectionKey = "material:123",
            mapID = 100,
            pins = { { mapID = 100, x = 0.20, y = 0.30 } },
        })
        local materialOnSecondMap = addon:BuildWorldMapProjectionPayload({
            title = "Ore",
            projectionKey = "material:123",
            mapID = 101,
            pins = { { mapID = 101, x = 0.40, y = 0.50 } },
        })
        local rareProjection = addon:BuildWorldMapProjectionPayload({
            title = "Rare",
            projectionKey = "rare:456",
            mapID = 100,
            pins = { { mapID = 100, x = 0.60, y = 0.70 } },
        })
        local refreshCount = 0
        addon.worldMapProjections = { materialOnFirstMap, rareProjection, materialOnSecondMap }
        addon.worldMapProjection = materialOnSecondMap
        addon.worldMapRouteDataProvider = {
            RefreshAllData = function()
                refreshCount = refreshCount + 1
            end,
        }

        local cleared, removedCount = addon:ClearWorldMapProjectionByKey("material:123")

        assert.is_true(cleared)
        assert.equals(2, removedCount)
        assert.equals(1, #addon.worldMapProjections)
        assert.equals(rareProjection, addon.worldMapProjections[1])
        assert.equals(rareProjection, addon.worldMapProjection)
        assert.equals(1, refreshCount)
    end)

    it("refreshes minimap projection pins and hides them when projections are cleared", function()
        local minimap = make_frame()
        loader.with_globals({
            CreateFrame = function(_, _, parent)
                local frame = make_frame()
                frame.parent = parent
                return frame
            end,
            Minimap = minimap,
            C_Map = {
                GetBestMapForUnit = function()
                    return 100
                end,
                GetPlayerMapPosition = function()
                    return {
                        GetXY = function()
                            return 0.50, 0.50
                        end,
                    }
                end,
            },
            C_Minimap = false,
        }, function()
            minimap:SetSize(140, 140)

            local addon = load_overlay({
                GetMapPinIconOption = function()
                    return { id = "herb", texture = "Interface\\Icons\\INV_Misc_Herb_07" }
                end,
            })
            addon.worldMapProjection = addon:BuildWorldMapProjectionPayload({
                title = "Ore",
                mapID = 100,
                pins = {
                    { mapID = 100, x = 0.52, y = 0.50, label = "Near ore" },
                    { mapID = 101, x = 0.52, y = 0.50, label = "Wrong map" },
                },
            })

            assert.is_true(addon:RefreshMinimapProjectionPins(true))
            local overlay = addon.minimapProjectionOverlay
            assert.is_table(overlay)
            assert.is_true(overlay.shown)
            assert.equals(1, #overlay.pins)
            assert.is_true(overlay.pins[1].shown)
            assert.equals("Near ore", overlay.pins[1].pinData.label)
            assert.equals("Interface\\Icons\\INV_Misc_Herb_07", overlay.pins[1].icon.texture)

            addon:ClearWorldMapProjection()

            assert.is_false(overlay.shown)
            assert.is_false(overlay.pins[1].shown)
            assert.same({}, addon.worldMapProjections)
            assert.is_nil(addon.worldMapProjection)
        end)
    end)
end)
