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

    function frame:SetScale(scale)
        self.scale = scale
    end

    function frame:SetScalingLimits(scaleFactor, startScale, endScale)
        self.scaleFactor = scaleFactor
        self.startScale = startScale
        self.endScale = endScale
    end

    function frame:SetRotation(rotation)
        self.rotation = rotation
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
        assert.equals("overlay", payload.displayMode)
        assert.is_false(payload.showRouteLinesWithIcons)
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
            customFarmRow = { itemID = 2770, farmingSourceType = "materials" },
            mapID = 100,
            mapLabel = "Hellfire Peninsula",
            displayMode = "icons",
            showRouteLinesWithIcons = true,
            pins = {
                { mapID = 100, x = 0.20, y = 0.30, label = "Route point" },
            },
            mapOptions = {
                {
                    id = "hellfire-main",
                    selectedItemID = 2770,
                    mapID = 100,
                    mapLabel = "Hellfire Peninsula",
                    label = "Hellfire Peninsula: Citadel perimeter",
                    location = "Citadel perimeter",
                    showRouteLinesWithIcons = true,
                    pins = {
                        { mapID = 100, x = 0.20, y = 0.30, label = "Route point" },
                    },
                },
            },
        })

        assert.is_true(addon:OpenWorldMapProjectionDetails())
        assert.equals("New Herb Farming Map", capturedOptions.title)
        assert.equals(2770, capturedOptions.customFarmRow.itemID)
        assert.equals("materials", capturedOptions.customFarmRow.farmingSourceType)
        assert.equals(2770, capturedOptions.mapOptions[1].selectedItemID)
        assert.equals(100, capturedOptions.mapID)
        assert.equals(1, #capturedOptions.mapOptions)
        assert.equals("hellfire-main", capturedOptions.mapOptions[1].id)
        assert.equals("Hellfire Peninsula", capturedOptions.mapOptions[1].mapLabel)
        assert.equals("Hellfire Peninsula: Citadel perimeter", capturedOptions.mapOptions[1].label)
        assert.equals("Citadel perimeter", capturedOptions.mapOptions[1].location)
        assert.is_true(capturedOptions.mapOptions[1].showRouteLinesWithIcons)
        assert.equals("Route point", capturedOptions.pins[1].label)
        assert.equals("icons", capturedOptions.displayMode)
        assert.is_true(capturedOptions.showRouteLinesWithIcons)
    end)

    it("keeps breadcrumb projections in the background of map details", function()
        local capturedOptions
        local addon = load_overlay({
            OpenStandaloneMapWindow = function(_, options)
                capturedOptions = options
            end,
        })
        local farmProjection = addon:BuildWorldMapProjectionPayload({
            title = "Active farm",
            projectionKey = "active-farm-route:1",
            mapID = 100,
            pins = { { mapID = 100, x = 0.20, y = 0.30 } },
        })
        local breadcrumbs = addon:BuildWorldMapProjectionPayload({
            title = "Breadcrumb trail",
            projectionKey = "active-farm-breadcrumb:1:100",
            mapID = 100,
            pins = {
                { mapID = 100, x = 0.21, y = 0.31, isRoute = true, routeType = "farm-breadcrumb" },
            },
            background = true,
        })
        addon.worldMapProjections = { farmProjection, breadcrumbs }
        addon.worldMapProjection = nil

        assert.is_true(addon:OpenWorldMapProjectionDetails())
        assert.equals("Active farm", capturedOptions.title)
        assert.is_true(breadcrumbs.background)
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

    it("renders projections without changing Blizzard map window layering", function()
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
            CreateFrame = function()
                return make_frame()
            end,
            Minimap = false,
        }, function()
            local canvas = make_frame()
            canvas:SetSize(500, 500)
            local map = {
                ScrollContainer = { Child = canvas },
                GetMapID = function()
                    return 100
                end,
                GetCanvas = function()
                    return canvas
                end,
                RemoveAllPinsByTemplate = function(self, template)
                    self.removedTemplate = template
                end,
                AcquirePin = function(self, template, provider, pinData, pinIndex, pinCount)
                    local pin = make_frame()
                    for key, value in pairs(GoldTrackerWorldMapRoutePinMixin or {}) do
                        pin[key] = value
                    end
                    pin.template = template
                    pin.provider = provider
                    pin.pinData = pinData
                    pin.pinIndex = pinIndex
                    pin.pinCount = pinCount
                    pin.SetPosition = function(_, x, y)
                        pin.position = { x, y }
                    end
                    pin:OnAcquired(provider, pinData, pinIndex, pinCount)
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
                DemoteInactiveAddonWindows = function()
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
                displayMode = "icons",
                showRouteLinesWithIcons = true,
                pins = {
                    { mapID = 100, x = 0.40, y = 0.50, itemName = "Herb", isRoute = true, routeID = "herb" },
                    { mapID = 100, x = 0.50, y = 0.60, itemName = "Herb", isRoute = true, routeID = "herb" },
                },
            }))

            assert.equals(2, #addon.worldMapProjections)
            assert.is_nil(worldMapFrame.frameStrataSetCount)
            assert.is_nil(worldMapFrame.toplevelSetCount)
            assert.is_nil(worldMapFrame.raiseCount)
            assert.equals(0, demotionCount)

            worldMapFrame.provider:RefreshAllData()

            local segmentPins = {}
            local iconPins = {}
            local routeSegmentCount = 0
            for _, pin in ipairs(worldMapFrame.provider.acquiredPins) do
                if pin.pinData.visualType == "projection-segment" then
                    segmentPins[#segmentPins + 1] = pin
                    if pin.pinData.segmentRole == "route" then
                        routeSegmentCount = routeSegmentCount + 1
                    end
                else
                    iconPins[#iconPins + 1] = pin
                end
            end
            assert.is_true(#segmentPins > 0)
            assert.equals("fill", segmentPins[1].pinData.segmentRole)
            assert.same({ 0.08, 0.42, 1.0, 0.20 }, segmentPins[1].pinData.color)
            assert.equals("Interface\\Buttons\\WHITE8X8", segmentPins[1].Segment.texture)
            assert.same({ 0.08, 0.42, 1.0, 1 }, segmentPins[1].Segment.vertexColor)
            assert.equals(0.20, segmentPins[1].Segment.alpha)
            assert.is_true(segmentPins[1].Segment.shown)
            assert.is_true(segmentPins[1].width > 1)
            assert.is_not_nil(segmentPins[1].Segment.rotation)
            assert.is_nil(segmentPins[1].startScale)
            assert.is_nil(segmentPins[1].endScale)
            assert.equals(1, segmentPins[1].scale)
            assert.equals(2, routeSegmentCount)
            assert.equals(2, #iconPins)
            assert.equals(1.0, iconPins[1].startScale)
            assert.equals(1.2, iconPins[1].endScale)
            assert.same({ 0.40, 0.50 }, iconPins[1].position)
            assert.same({ 0.50, 0.60 }, iconPins[2].position)
            assert.equals("Herb", iconPins[1].pinData.projectionTitle)
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
                displayMode = "icons",
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

    it("renders projected overlay mode as a minimap area without location icons", function()
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
                    return { x = 0.50, y = 0.50 }
                end,
            },
            C_Minimap = false,
        }, function()
            minimap:SetSize(140, 140)
            local addon = load_overlay({})
            addon.worldMapProjection = addon:BuildWorldMapProjectionPayload({
                title = "Mote of Fire",
                mapID = 100,
                displayMode = "overlay",
                pins = {
                    { mapID = 100, x = 0.49, y = 0.49, label = "Fire elemental" },
                    { mapID = 100, x = 0.51, y = 0.49, label = "Fire elemental" },
                    { mapID = 100, x = 0.50, y = 0.51, label = "Fire elemental" },
                },
            })

            assert.is_true(addon:RefreshMinimapProjectionPins(true))
            local overlay = addon.minimapProjectionOverlay
            assert.is_true(overlay.shown)
            assert.equals(0, #overlay.pins)
            assert.is_true(#overlay.minimapAreaFillLines > 0)
            assert.is_true(#overlay.minimapAreaGlowLines > 0)
            assert.is_true(#overlay.minimapAreaBorderLines > 0)
            assert.same({ 0.08, 0.42, 1.0, 0.20 }, overlay.minimapAreaFillLines[1].color)

            addon:ClearWorldMapProjection()

            assert.is_false(overlay.shown)
            assert.is_false(overlay.minimapAreaBorderLines[1].shown)
        end)
    end)

    it("moves the rendered minimap area opposite player movement so it stays on terrain", function()
        local minimap = make_frame()
        local playerX = 0.50
        loader.with_globals({
            CreateFrame = function(_, _, parent)
                local frame = make_frame()
                frame.parent = parent
                return frame
            end,
            Minimap = minimap,
            UiMapPoint = {
                CreateFromCoordinates = function(_, x, y)
                    return { x = x, y = y }
                end,
            },
            C_Map = {
                GetBestMapForUnit = function()
                    return 100
                end,
                GetPlayerMapPosition = function()
                    return { x = playerX, y = 0.50 }
                end,
                GetWorldPosFromMapPos = function(_, point)
                    return 1, {
                        GetXY = function()
                            return (1 - point.y) * 1000, (1 - point.x) * 1000
                        end,
                    }
                end,
            },
            C_Minimap = {
                GetViewRadius = function()
                    return 100
                end,
            },
            GetCVar = function()
                return "0"
            end,
            GetPlayerFacing = false,
        }, function()
            minimap:SetSize(140, 140)
            local addon = load_overlay({})
            addon.worldMapProjection = addon:BuildWorldMapProjectionPayload({
                mapID = 100,
                displayMode = "overlay",
                pins = {
                    { mapID = 100, x = 0.515, y = 0.495, areaID = "farm" },
                    { mapID = 100, x = 0.525, y = 0.500, areaID = "farm" },
                    { mapID = 100, x = 0.515, y = 0.510, areaID = "farm" },
                },
            })

            assert.is_true(addon:RefreshMinimapProjectionPins(true))
            local overlay = addon.minimapProjectionOverlay
            local border = overlay.minimapAreaBorderLines[1]
            local initialStartX = border.startPoint[3]
            local initialEndX = border.endPoint[3]

            playerX = 0.51
            assert.is_true(addon:RefreshMinimapProjectionPins(false))
            assert.equals(border, overlay.minimapAreaBorderLines[1])
            assert.is_true(border.startPoint[3] < initialStartX)
            assert.is_true(border.endPoint[3] < initialEndX)
        end)
    end)

    it("keeps the blue minimap area north-up while the minimap rotates", function()
        local minimap = make_frame()
        local facing = 0
        loader.with_globals({
            CreateFrame = function(_, _, parent)
                local frame = make_frame()
                frame.parent = parent
                return frame
            end,
            Minimap = minimap,
            UiMapPoint = {
                CreateFromCoordinates = function(_, x, y)
                    return { x = x, y = y }
                end,
            },
            C_Map = {
                GetBestMapForUnit = function()
                    return 100
                end,
                GetPlayerMapPosition = function()
                    return { x = 0.50, y = 0.50 }
                end,
                GetWorldPosFromMapPos = function(_, point)
                    return 1, {
                        GetXY = function()
                            return (1 - point.y) * 1000, (1 - point.x) * 1000
                        end,
                    }
                end,
            },
            C_Minimap = {
                GetViewRadius = function()
                    return 100
                end,
            },
            GetCVar = function(name)
                return name == "rotateMinimap" and "1" or "0"
            end,
            GetPlayerFacing = function()
                return facing
            end,
        }, function()
            minimap:SetSize(140, 140)
            local addon = load_overlay({})
            addon.worldMapProjection = addon:BuildWorldMapProjectionPayload({
                mapID = 100,
                displayMode = "overlay",
                pins = {
                    { mapID = 100, x = 0.515, y = 0.495, areaID = "farm" },
                    { mapID = 100, x = 0.525, y = 0.500, areaID = "farm" },
                    { mapID = 100, x = 0.515, y = 0.510, areaID = "farm" },
                },
            })

            assert.is_true(addon:RefreshMinimapProjectionPins(true))
            local border = addon.minimapProjectionOverlay.minimapAreaBorderLines[1]
            local initialStart = { border.startPoint[3], border.startPoint[4] }
            local initialEnd = { border.endPoint[3], border.endPoint[4] }

            facing = math.pi * 0.5
            assert.is_true(addon:RefreshMinimapProjectionPins(false))
            assert.near(initialStart[1], border.startPoint[3], 0.0001)
            assert.near(initialStart[2], border.startPoint[4], 0.0001)
            assert.near(initialEnd[1], border.endPoint[3], 0.0001)
            assert.near(initialEnd[2], border.endPoint[4], 0.0001)
        end)
    end)

    it("keeps farm-location pins visible while the breadcrumb trail is toggled", function()
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
                    return { x = 0.50, y = 0.50 }
                end,
            },
            C_Minimap = false,
        }, function()
            minimap:SetSize(140, 140)
            local showBreadcrumbs = false
            local addon = load_overlay({
                IsActiveCustomFarmBreadcrumbsEnabled = function()
                    return showBreadcrumbs
                end,
            })
            addon.worldMapProjections = {
                addon:BuildWorldMapProjectionPayload({
                    mapID = 100,
                    displayMode = "icons",
                    pins = { { mapID = 100, x = 0.52, y = 0.50, label = "Farm location" } },
                }),
                addon:BuildWorldMapProjectionPayload({
                    mapID = 100,
                    displayMode = "icons",
                    pins = { {
                        mapID = 100,
                        x = 0.51,
                        y = 0.50,
                        label = "Breadcrumb",
                        routeType = "farm-breadcrumb",
                    } },
                }),
            }

            assert.is_true(addon:RefreshMinimapProjectionPins(true))
            local overlay = addon.minimapProjectionOverlay
            assert.is_true(overlay.shown)
            assert.equals("Farm location", overlay.pins[1].pinData.label)

            showBreadcrumbs = true
            assert.is_true(addon:RefreshMinimapProjectionPins(true))
            assert.is_true(overlay.shown)
            assert.equals("Farm location", overlay.pins[1].pinData.label)
            assert.equals("Breadcrumb", overlay.pins[2].pinData.label)
            assert.is_true(overlay.pins[2].shown)

            showBreadcrumbs = false
            assert.is_true(addon:RefreshMinimapProjectionPins(true))
            assert.is_true(overlay.shown)
            assert.equals("Farm location", overlay.pins[1].pinData.label)
            assert.is_false(overlay.pins[2].shown)
        end)
    end)

    it("batches player map work and caches static pin world positions", function()
        local minimap = make_frame()
        local playerPositionCalls = 0
        local worldPositionCalls = 0
        local viewRadiusCalls = 0
        loader.with_globals({
            CreateFrame = function(_, _, parent)
                local frame = make_frame()
                frame.parent = parent
                return frame
            end,
            Minimap = minimap,
            UiMapPoint = {
                CreateFromCoordinates = function(_, x, y)
                    return { x = x, y = y }
                end,
            },
            C_Map = {
                GetBestMapForUnit = function()
                    return 100
                end,
                GetPlayerMapPosition = function()
                    playerPositionCalls = playerPositionCalls + 1
                    return { x = 0.50, y = 0.50 }
                end,
                GetWorldPosFromMapPos = function(_, point)
                    worldPositionCalls = worldPositionCalls + 1
                    return 1, {
                        GetXY = function()
                            return (1 - point.y) * 1000, (1 - point.x) * 1000
                        end,
                    }
                end,
            },
            C_Minimap = {
                GetViewRadius = function()
                    viewRadiusCalls = viewRadiusCalls + 1
                    return 100
                end,
            },
            GetCVar = false,
            GetPlayerFacing = false,
        }, function()
            minimap:SetSize(140, 140)
            local addon = load_overlay({})
            addon.worldMapProjection = addon:BuildWorldMapProjectionPayload({
                mapID = 100,
                displayMode = "icons",
                pins = {
                    { mapID = 100, x = 0.51, y = 0.50 },
                    { mapID = 100, x = 0.52, y = 0.50 },
                    { mapID = 100, x = 0.53, y = 0.50 },
                },
            })

            assert.is_true(addon:RefreshMinimapProjectionPins(true))
            assert.is_true(addon:RefreshMinimapProjectionPins(false))

            assert.equals(2, playerPositionCalls)
            assert.equals(2, viewRadiusCalls)
            assert.equals(5, worldPositionCalls)
            assert.is_true(addon.minimapProjectionOverlay.pins[1].points[1][4] > 0)
            assert.near(0, addon.minimapProjectionOverlay.pins[1].points[1][5], 0.0001)
        end)
    end)

    it("keeps minimap projections fixed while the player moves across Blizzard world axes", function()
        local minimap = make_frame()
        local playerX = 0.50
        local playerY = 0.50
        loader.with_globals({
            CreateFrame = function(_, _, parent)
                local frame = make_frame()
                frame.parent = parent
                return frame
            end,
            Minimap = minimap,
            UiMapPoint = {
                CreateFromCoordinates = function(_, x, y)
                    return { x = x, y = y }
                end,
            },
            C_Map = {
                GetBestMapForUnit = function()
                    return 100
                end,
                GetPlayerMapPosition = function()
                    return { x = playerX, y = playerY }
                end,
                GetWorldPosFromMapPos = function(_, point)
                    return 1, {
                        GetXY = function()
                            return (1 - point.y) * 1000, (1 - point.x) * 1000
                        end,
                    }
                end,
            },
            C_Minimap = {
                GetViewRadius = function()
                    return 100
                end,
            },
            GetCVar = function()
                return "0"
            end,
            GetPlayerFacing = false,
        }, function()
            minimap:SetSize(140, 140)
            local addon = load_overlay({})
            addon.worldMapProjection = addon:BuildWorldMapProjectionPayload({
                mapID = 100,
                displayMode = "icons",
                pins = { { mapID = 100, x = 0.52, y = 0.50 } },
            })

            assert.is_true(addon:RefreshMinimapProjectionPins(true))
            local pin = addon.minimapProjectionOverlay.pins[1]
            local initialX = pin.points[1][4]
            local initialY = pin.points[1][5]
            assert.is_true(initialX > 0)
            assert.near(0, initialY, 0.0001)

            playerX = 0.51
            assert.is_true(addon:RefreshMinimapProjectionPins(false))
            local afterEastMovementX = pin.points[1][4]
            assert.is_true(afterEastMovementX < initialX)
            assert.is_true(afterEastMovementX > 0)

            playerX = 0.50
            playerY = 0.51
            assert.is_true(addon:RefreshMinimapProjectionPins(false))
            assert.near(initialX, pin.points[1][4], 0.0001)
            assert.is_true(pin.points[1][5] > initialY)
        end)
    end)

    it("rotates fixed-world minimap projections with a rotating minimap", function()
        local minimap = make_frame()
        loader.with_globals({
            CreateFrame = function(_, _, parent)
                local frame = make_frame()
                frame.parent = parent
                return frame
            end,
            Minimap = minimap,
            UiMapPoint = {
                CreateFromCoordinates = function(_, x, y)
                    return { x = x, y = y }
                end,
            },
            C_Map = {
                GetBestMapForUnit = function()
                    return 100
                end,
                GetPlayerMapPosition = function()
                    return { x = 0.50, y = 0.50 }
                end,
                GetWorldPosFromMapPos = function(_, point)
                    return 1, {
                        GetXY = function()
                            return (1 - point.y) * 1000, (1 - point.x) * 1000
                        end,
                    }
                end,
            },
            C_Minimap = {
                GetViewRadius = function()
                    return 100
                end,
            },
            GetCVar = function(name)
                return name == "rotateMinimap" and "1" or "0"
            end,
            GetPlayerFacing = function()
                return math.pi * 0.5
            end,
        }, function()
            minimap:SetSize(140, 140)
            local addon = load_overlay({})
            addon.worldMapProjection = addon:BuildWorldMapProjectionPayload({
                mapID = 100,
                displayMode = "icons",
                pins = { { mapID = 100, x = 0.52, y = 0.50 } },
            })

            assert.is_true(addon:RefreshMinimapProjectionPins(true))
            local point = addon.minimapProjectionOverlay.pins[1].points[1]
            assert.near(0, point[4], 0.0001)
            assert.is_true(point[5] < 0)
        end)
    end)
end)
