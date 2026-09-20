local loader = require("tests.helpers.addon_loader")

local function load_window(addon)
    addon = addon or {}
    loader.load_module("UI/MapAreaOverlay.lua", addon, {})
    return loader.load_module("UI/StandaloneMapWindow.lua", addon, {})
end

local function make_frame()
    local frame = {
        children = {},
        points = {},
        shown = false,
        width = 260,
    }

    function frame:SetSize(width, height)
        self.width = width
        self.height = height
    end

    function frame:SetWidth(width)
        self.width = width
    end

    function frame:GetWidth()
        return self.width
    end

    function frame:GetHeight()
        return self.height or self.width
    end

    function frame:SetHeight(height)
        self.height = height
    end

    function frame:ClearAllPoints()
        self.points = {}
    end

    function frame:SetPoint(...)
        self.points[#self.points + 1] = { ... }
    end

    function frame:SetJustifyH(value)
        self.justifyH = value
    end

    function frame:SetJustifyV(value)
        self.justifyV = value
    end

    function frame:SetWordWrap(value)
        self.wordWrap = value
    end

    function frame:SetNonSpaceWrap(value)
        self.nonSpaceWrap = value
    end

    function frame:SetMaxLines(value)
        self.maxLines = value
    end

    function frame:SetText(text)
        self.text = text
    end

    function frame:SetTextColor(r, g, b, a)
        self.textColor = { r, g, b, a }
    end

    function frame:SetFontObject(fontObject)
        self.fontObject = fontObject
    end

    frame.GetStringHeight = function(self)
        if self.wordWrap and self.maxLines == 0 and (self.width or 0) > 0 and #(self.text or "") > 30 then
            return 36
        end
        return 18
    end

    function frame:Show()
        self.shown = true
    end

    function frame:Hide()
        self.shown = false
    end

    function frame:SetScript(scriptName, handler)
        self.scripts = self.scripts or {}
        self.scripts[scriptName] = handler
    end

    function frame:CreateFontString()
        local text = make_frame()
        self.children[#self.children + 1] = text
        return text
    end

    function frame:CreateTexture(_, layer)
        local texture = make_frame()
        texture.layer = layer
        texture.SetTexture = function(_, value)
            texture.texture = value
        end
        texture.SetTexCoord = function(_, ...)
            texture.texCoord = { ... }
        end
        texture.SetHorizTile = function(_, value)
            texture.horizTile = value
        end
        texture.SetVertTile = function(_, value)
            texture.vertTile = value
        end
        texture.SetDrawLayer = function(_, drawLayer, subLevel)
            texture.drawLayer = drawLayer
            texture.drawSubLevel = subLevel
        end
        texture.SetColorTexture = function(_, r, g, b, a)
            texture.color = { r, g, b, a }
        end
        self.children[#self.children + 1] = texture
        return texture
    end

    function frame:CreateLine(_, layer, _, subLevel)
        local line = make_frame()
        line.layer = layer
        line.subLevel = subLevel
        line.SetParent = function(_, parent)
            line.parent = parent
        end
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
        line.SetVertexColor = function(_, r, g, b, a)
            line.vertexColor = { r, g, b, a }
        end
        self.children[#self.children + 1] = line
        return line
    end

    return frame
end

describe("UI/StandaloneMapWindow", function()
    it("builds readable farming details for the selected map", function()
        local addon = load_window()

        local lines = addon:BuildStandaloneMapDetailLines({
            {
                mapID = 107,
                x = 0.10,
                y = 0.20,
                label = "West ridge",
                itemName = "Old Ore",
                spotLocation = "Twilight Ridge",
                routeType = "mining-loop",
                density = "High",
                dropDifficulty = "Easy loop",
                tips = { "Stay on the ridge.", "Loop clockwise." },
                sourceUrls = {
                    "https://www.wowhead.com/item=12345/old-ore",
                    "https://www.wow-professions.com/farming/old-ore-farming",
                },
            },
            {
                mapID = 107,
                x = 0.14,
                y = 0.24,
                label = "Central ridge",
                itemName = "Old Ore",
                spotLocation = "Twilight Ridge",
                routeType = "mining-loop",
                density = "High",
                dropDifficulty = "Easy loop",
                tips = { "Stay on the ridge.", "Loop clockwise." },
                sourceUrls = {
                    "https://www.wowhead.com/item=12345/old-ore",
                    "https://www.wow-professions.com/farming/old-ore-farming",
                },
            },
            {
                mapID = 104,
                x = 0.45,
                y = 0.29,
                label = "Wrong map",
                itemName = "Wrong Ore",
            },
        }, 107, "Nagrand")

        local rendered = {}
        for _, line in ipairs(lines) do
            rendered[#rendered + 1] = line.text or line.siteName
        end
        local text = table.concat(rendered, "\n")

        assert.matches("Nagrand", text, 1, true)
        assert.is_nil(text:find("Farming Details", 1, true))
        assert.is_nil(text:find("Nagrand #107", 1, true))
        assert.is_nil(text:find("farming pins visible", 1, true))
        assert.matches("Old Ore", text, 1, true)
        assert.matches("Twilight Ridge", text, 1, true)
        assert.matches("Route: mining%-loop", text)
        assert.matches("Density: High", text, 1, true)
        assert.matches("Difficulty: Easy loop", text, 1, true)
        assert.matches("- Stay on the ridge.", text, 1, true)
        assert.matches("Sources", text, 1, true)
        assert.matches("Wowhead", text, 1, true)
        assert.matches("wow%-professions", text)
        assert.is_nil(text:find("Pins:", 1, true))
        assert.is_nil(text:find("West ridge (10.0, 20.0)", 1, true))
        assert.is_nil(text:find("Central ridge (14.0, 24.0)", 1, true))
        assert.is_nil(text:find("Wrong Ore", 1, true))

        local sourceRows = {}
        for _, line in ipairs(lines) do
            if line.type == "source" then
                sourceRows[#sourceRows + 1] = line
            end
        end
        assert.equals(2, #sourceRows)
        assert.equals("https://www.wowhead.com/item=12345/old-ore", sourceRows[1].url)
        assert.equals("https://www.wow-professions.com/farming/old-ore-farming", sourceRows[2].url)
    end)

    it("merges overlapping user discoveries into one aggregated details section", function()
        local addon = load_window()
        local lines = addon:BuildStandaloneMapDetailLines({
            {
                mapID = 100,
                x = 0.70,
                y = 0.20,
                itemName = "Mote of Fire",
                label = "Unit: Incandescent Fel Spark",
                spotLocation = "Unit: Incandescent Fel Spark",
                routeType = "user-discovered",
                sourceType = "user",
                sourceLabel = "User discoveries",
                seenCount = 1,
                totalQuantity = 2,
                tips = { "Recorded automatically while you were farming." },
            },
            {
                mapID = 100,
                x = 0.715,
                y = 0.21,
                itemName = "Mote of Fire",
                label = "AOE Unit: Incandescent Fel Spark",
                spotLocation = "AOE Unit: Incandescent Fel Spark",
                routeType = "user-discovered",
                sourceType = "user",
                sourceLabel = "User discoveries",
                seenCount = 2,
                totalQuantity = 3,
                tips = { "Recorded automatically while you were farming." },
            },
        }, 100, "Hellfire Peninsula (User)")

        local rendered = {}
        local moteTitleCount = 0
        local tipsCount = 0
        for _, line in ipairs(lines) do
            local text = line.text or line.siteName
            rendered[#rendered + 1] = text
            if text == "Mote of Fire" then
                moteTitleCount = moteTitleCount + 1
            elseif text == "Tips" then
                tipsCount = tipsCount + 1
            end
        end
        local text = table.concat(rendered, "\n")

        assert.equals(1, moteTitleCount)
        assert.equals(1, tipsCount)
        assert.matches("Kill: Incandescent Fel Spark", text, 1, true)
        assert.matches("Area: Near 70.8, 20.5", text, 1, true)
        assert.matches("Density: 2 nearby points, 3 seen, 5 looted", text, 1, true)
        assert.matches("- Recorded automatically while you were farming.", text, 1, true)
        assert.is_nil(text:find("AOE Unit:", 1, true))
    end)

    it("emphasizes exact kill targets ahead of the secondary area", function()
        local addon = load_window()
        local lines = addon:BuildStandaloneMapDetailLines({
            {
                mapID = 100,
                x = 0.60,
                y = 0.20,
                label = "Incandescent Fel Spark #1",
                itemName = "Mote of Fire",
                spotLocation = "Throne of Kil'jaeden, killing Incandescent Fel Sparks",
                targetName = "Incandescent Fel Spark",
                targetType = "kill",
                routeType = "elemental-grind",
            },
            {
                mapID = 100,
                x = 0.62,
                y = 0.21,
                label = "Incandescent Fel Spark #2",
                itemName = "Mote of Fire",
                spotLocation = "Throne of Kil'jaeden, killing Incandescent Fel Sparks",
                targetName = "Incandescent Fel Spark",
                targetType = "kill",
                routeType = "elemental-grind",
            },
        }, 100, "Hellfire Peninsula")

        local killLine
        local areaLine
        for _, line in ipairs(lines) do
            if line.text == "Kill: Incandescent Fel Spark" then
                killLine = line
            elseif line.text == "Area: Throne of Kil'jaeden" then
                areaLine = line
            end
        end

        assert.is_table(killLine)
        assert.equals("GameFontNormalLarge", killLine.fontObject)
        assert.same({ 1.0, 0.45, 0.20 }, { killLine.r, killLine.g, killLine.b })
        assert.is_table(areaLine)
        assert.equals("GameFontHighlight", areaLine.fontObject)
    end)

    it("clears stale source button data when the next map has no source links", function()
        local addon = load_window()
        local details_content = make_frame()
        local details_scroll_frame = make_frame()
        details_scroll_frame.width = 240
        details_scroll_frame.UpdateScrollChildRect = function(self)
            self.updated = true
        end

        addon.standaloneMapFrame = {
            mapID = 100,
            windowTitle = "Material",
            mapPins = {
                {
                    mapID = 100,
                    x = 0.20,
                    y = 0.30,
                    label = "Material pin",
                    itemName = "Material",
                    sourceUrls = { "https://www.wowhead.com/item=12345/material" },
                },
            },
            mapTitle = make_frame(),
            detailsContent = details_content,
            detailsScrollFrame = details_scroll_frame,
            detailTextLines = {},
            detailSourceRows = {},
            mapTileTextures = {},
            mapExploredTileTextures = {},
            mapContent = make_frame(),
            statusText = make_frame(),
        }

        loader.with_globals({
            CreateFrame = function(_, _, parent)
                local frame = make_frame()
                frame.parent = parent
                return frame
            end,
        }, function()
            addon:RefreshStandaloneMapWindow()

            local staleRow = addon.standaloneMapFrame.detailSourceRows[4]
            assert.is_table(staleRow)
            assert.equals("https://www.wowhead.com/item=12345/material", staleRow.button.sourceUrl)
            assert.is_true(staleRow.shown)

            addon.standaloneMapFrame.mapPins = {
                {
                    mapID = 100,
                    x = 0.40,
                    y = 0.50,
                    label = "Rare pin",
                    itemName = "Rare Drop",
                },
            }

            addon:RefreshStandaloneMapWindow()

            assert.equals("Material", addon.standaloneMapFrame.mapTitle.text)

            assert.is_false(staleRow.shown)
            assert.is_nil(staleRow.button.sourceUrl)
            assert.is_nil(staleRow.button.sourceSiteName)
            assert.is_nil(staleRow.button.tooltipText)
        end)
    end)

    it("wraps long farming detail text instead of leaving it line-capped", function()
        local addon = load_window()
        local details_content = make_frame()
        local details_scroll_frame = make_frame()
        details_scroll_frame.width = 180
        details_scroll_frame.UpdateScrollChildRect = function(self)
            self.updated = true
        end

        addon.standaloneMapFrame = {
            mapID = 107,
            windowTitle = "Eternium Ore",
            mapPins = {
                {
                    mapID = 107,
                    x = 0.20,
                    y = 0.30,
                    label = "Nagrand route",
                    itemName = "Eternium Ore",
                    spotLocation = "Adamantite-heavy Nagrand cave and ridge loop",
                },
            },
            mapTitle = make_frame(),
            detailsContent = details_content,
            detailsScrollFrame = details_scroll_frame,
            detailTextLines = {},
            detailSourceRows = {},
            mapTileTextures = {},
            mapExploredTileTextures = {},
            mapContent = make_frame(),
            statusText = make_frame(),
        }

        addon:RefreshStandaloneMapWindow()

        local locationLine = addon.standaloneMapFrame.detailTextLines[3]
        assert.equals("Area: Adamantite-heavy Nagrand cave and ridge loop", locationLine.text)
        assert.is_true(locationLine.wordWrap)
        assert.is_true(locationLine.nonSpaceWrap)
        assert.equals(0, locationLine.maxLines)
        assert.is_true(locationLine.height > 36)
        assert.is_true(details_scroll_frame.updated)
    end)

    it("draws standalone route lines between ordered material farming pins", function()
        local addon = load_window()
        local map_content = make_frame()
        local map_viewport = make_frame()
        map_viewport:SetSize(500, 500)

        addon.standaloneMapFrame = {
            mapID = 107,
            windowTitle = "Old Ore",
            mapPins = {
                { mapID = 107, x = 0.10, y = 0.20, label = "Start", itemName = "Old Ore", isRoute = true, routeID = "old-ore" },
                { mapID = 107, x = 0.30, y = 0.40, label = "Middle", itemName = "Old Ore", isRoute = true, routeID = "old-ore" },
                { mapID = 107, x = 0.50, y = 0.60, label = "End", itemName = "Old Ore", isRoute = true, routeID = "old-ore" },
                { mapID = 107, x = 0.60, y = 0.65, label = "Unordered pin", itemName = "Old Ore" },
                { mapID = 107, x = 0.70, y = 0.70, label = "Second start", itemName = "Old Ore", isRoute = true, routeID = "other-route" },
                { mapID = 107, x = 0.80, y = 0.75, label = "Second end", itemName = "Old Ore", isRoute = true, routeID = "other-route" },
                { mapID = 104, x = 0.70, y = 0.80, label = "Other map", itemName = "Old Ore", isRoute = true, routeID = "old-ore" },
            },
            mapTitle = make_frame(),
            detailsContent = make_frame(),
            detailsScrollFrame = make_frame(),
            detailTextLines = {},
            detailSourceRows = {},
            mapTileTextures = {},
            mapExploredTileTextures = {},
            mapRouteLines = {},
            mapPinFrames = {},
            mapViewport = map_viewport,
            mapContent = map_content,
            statusText = make_frame(),
        }

        loader.with_globals({
            C_Map = {
                GetMapArtLayers = function()
                    return {
                        {
                            layerWidth = 1000,
                            layerHeight = 1000,
                            tileWidth = 500,
                            tileHeight = 500,
                        },
                    }
                end,
                GetMapArtLayerTextures = function()
                    return { 1, 2, 3, 4 }
                end,
            },
            C_MapExplorationInfo = false,
            CreateFrame = function(_, _, parent)
                local frame = make_frame()
                frame.parent = parent
                return frame
            end,
        }, function()
            addon:RefreshStandaloneMapWindow()

            local lines = addon.standaloneMapFrame.mapRouteLines
            assert.equals(3, #lines)
            assert.same({ "TOPLEFT", map_content, 50, -100 }, lines[1].startPoint)
            assert.same({ "TOPLEFT", map_content, 150, -200 }, lines[1].endPoint)
            assert.same({ "TOPLEFT", map_content, 150, -200 }, lines[2].startPoint)
            assert.same({ "TOPLEFT", map_content, 250, -300 }, lines[2].endPoint)
            assert.same({ "TOPLEFT", map_content, 350, -350 }, lines[3].startPoint)
            assert.same({ "TOPLEFT", map_content, 400, -375 }, lines[3].endPoint)
            assert.equals(3, lines[1].thickness)
            assert.same({ 1.0, 0.82, 0.18, 0.62 }, lines[1].color)
            assert.is_true(lines[1].shown)
            assert.is_true(lines[2].shown)
            assert.is_true(lines[3].shown)

            local pins = addon.standaloneMapFrame.mapPinFrames
            assert.equals(0, #pins)
            assert.is_true(#addon.standaloneMapFrame.standaloneMapAreaFillLines > 0)
            assert.is_true(#addon.standaloneMapFrame.standaloneMapAreaGlowLines > 0)
            assert.is_true(#addon.standaloneMapFrame.standaloneMapAreaBorderLines > 0)
            assert.same(
                { 0.08, 0.42, 1.0, 0.20 },
                addon.standaloneMapFrame.standaloneMapAreaFillLines[1].color
            )
            assert.equals("OVERLAY", addon.standaloneMapFrame.standaloneMapAreaFillLines[1].layer)
            assert.equals(-3, addon.standaloneMapFrame.standaloneMapAreaFillLines[1].subLevel)
            assert.equals("OVERLAY", addon.standaloneMapFrame.standaloneMapAreaBorderLines[1].layer)
        end)
    end)

    it("switches the selected farm between its area overlay and coordinate icons", function()
        local addon = load_window()
        local map_content = make_frame()
        local map_viewport = make_frame()
        map_viewport:SetSize(500, 500)
        local display_mode_button = make_frame()

        addon.standaloneMapFrame = {
            mapID = 107,
            windowTitle = "Wind Scales",
            mapDisplayMode = "overlay",
            mapPins = {
                { mapID = 107, x = 0.20, y = 0.30, label = "West dragonhawk", itemName = "Wind Scales", routeID = "wind-scales" },
                { mapID = 107, x = 0.40, y = 0.50, label = "East dragonhawk", itemName = "Wind Scales", routeID = "wind-scales" },
            },
            mapTitle = make_frame(),
            detailsContent = make_frame(),
            detailsScrollFrame = make_frame(),
            detailTextLines = {},
            detailSourceRows = {},
            mapTileTextures = {},
            mapExploredTileTextures = {},
            mapRouteLines = {},
            mapPinFrames = {},
            mapViewport = map_viewport,
            mapContent = map_content,
            statusText = make_frame(),
            displayModeButton = display_mode_button,
        }

        loader.with_globals({
            C_Map = {
                GetMapArtLayers = function()
                    return {
                        {
                            layerWidth = 1000,
                            layerHeight = 1000,
                            tileWidth = 500,
                            tileHeight = 500,
                        },
                    }
                end,
                GetMapArtLayerTextures = function()
                    return { 1, 2, 3, 4 }
                end,
            },
            C_MapExplorationInfo = false,
            CreateFrame = function(_, _, parent)
                local frame = make_frame()
                frame.parent = parent
                return frame
            end,
            GameTooltip = false,
        }, function()
            addon:RefreshStandaloneMapWindow()

            assert.equals("Icons", display_mode_button.text)
            assert.is_true(#addon.standaloneMapFrame.standaloneMapAreaFillLines > 0)
            assert.is_true(addon.standaloneMapFrame.standaloneMapAreaFillLines[1].shown)
            assert.equals(0, #addon.standaloneMapFrame.mapPinFrames)

            assert.is_true(addon:ToggleStandaloneMapDisplayMode())
            assert.equals("icons", addon.standaloneMapFrame.mapDisplayMode)
            assert.equals("Overlay", display_mode_button.text)
            assert.equals("Switch to the farming area overlay.", display_mode_button.tooltipText)
            assert.equals(2, #addon.standaloneMapFrame.mapPinFrames)
            assert.is_true(addon.standaloneMapFrame.mapPinFrames[1].shown)
            assert.is_true(addon.standaloneMapFrame.mapPinFrames[2].shown)
            assert.equals("West dragonhawk", addon.standaloneMapFrame.mapPinFrames[1].pinData.label)
            assert.same({ "CENTER", map_content, "TOPLEFT", 100, -150 }, addon.standaloneMapFrame.mapPinFrames[1].points[1])
            assert.is_false(addon.standaloneMapFrame.standaloneMapAreaFillLines[1].shown)
            assert.matches("2 farming location icons visible", addon.standaloneMapFrame.statusText.text, 1, true)

            assert.is_true(addon:ToggleStandaloneMapDisplayMode())
            assert.equals("overlay", addon.standaloneMapFrame.mapDisplayMode)
            assert.equals("Icons", display_mode_button.text)
            assert.is_false(addon.standaloneMapFrame.mapPinFrames[1].shown)
            assert.is_true(addon.standaloneMapFrame.standaloneMapAreaFillLines[1].shown)
        end)
    end)

    it("clears only the projections owned by the open map", function()
        local capturedKey
        local addon = load_window({
            ClearWorldMapProjectionByKey = function(_, projectionKey)
                capturedKey = projectionKey
                return true
            end,
        })
        addon.standaloneMapFrame = {
            projectionKey = "material:123",
            statusText = make_frame(),
        }

        assert.is_true(addon:ClearStandaloneWorldMapProjection())
        assert.equals("material:123", capturedKey)
        assert.equals(
            "Cleared this map's projected pins from the Blizzard world map.",
            addon.standaloneMapFrame.statusText.text
        )
    end)
end)
