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

    function frame:SetVertexColor(r, g, b, a)
        self.vertexColor = { r, g, b, a }
    end

    function frame:SetAlpha(alpha)
        self.alpha = alpha
    end

    function frame:SetFrameLevel(level)
        self.frameLevel = level
    end

    function frame:SetDrawLayer(layer, subLevel)
        self.drawLayer = layer
        self.drawSubLevel = subLevel
    end

    function frame:GetFrameLevel()
        return self.frameLevel or 0
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

    function frame:CreateFontString(_, layer, _, subLevel)
        if subLevel ~= nil then
            assert.is_true(subLevel >= -8 and subLevel <= 7, "font-string sublevel must be between -8 and 7")
        end
        local text = make_frame()
        text.layer = layer
        text.subLevel = subLevel
        self.children[#self.children + 1] = text
        return text
    end

    function frame:CreateTexture(_, layer, _, subLevel)
        if subLevel ~= nil then
            assert.is_true(subLevel >= -8 and subLevel <= 7, "texture sublevel must be between -8 and 7")
        end
        local texture = make_frame()
        texture.layer = layer
        texture.subLevel = subLevel
        texture.SetTexture = function(_, value)
            texture.texture = value
        end
        texture.SetAtlas = function(_, value)
            texture.atlas = value
        end
        texture.GetAtlas = function()
            return texture.atlas
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
    it("renders a source preview overlay independently and clears old art on a missing map", function()
        local addon = load_window()
        local standalone = { mapID = 999 }
        addon.standaloneMapFrame = standalone
        local frame = { mapContent = make_frame(), mapViewport = make_frame(), statusText = make_frame() }
        local rendered
        addon.MapAreaOverlay.Render = function(_, owner, _, key, polygons)
            if key == "standaloneMapArea" then
                rendered = { owner = owner, polygons = polygons }
            end
            return #polygons
        end
        loader.with_globals({ C_Map = {
            GetMapArtLayers = function(mapID)
                if mapID == 100 then
                    return { { layerWidth = 512, layerHeight = 512, tileWidth = 512, tileHeight = 512 } }
                end
            end,
            GetMapArtLayerTextures = function() return { 123 } end,
        } }, function()
            addon:RefreshFarmingMapPreview(frame, { mapID = 100, pins = {
                { mapID = 100, x = 0.4, y = 0.6, sourceType = "user", label = "Fire" },
            } })
            assert.is_true(frame.mapContent.shown)
            assert.equals(frame, rendered.owner)
            assert.equals(1, #rendered.polygons)
            assert.is_nil(frame.detailsContent)
            assert.equals(999, standalone.mapID)
            addon:RefreshFarmingMapPreview(frame, { mapID = 104, pins = {} })
            assert.is_false(frame.mapContent.shown)
            assert.is_true(frame.statusText.shown)
            assert.matches("No map art layer", frame.statusText.text)
        end)
    end)

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
        assert.matches("Mine: Gather ore nodes while following the marked route.", text, 1, true)
        assert.matches("Method: Mining loop", text, 1, true)
        assert.matches("Density: High", text, 1, true)
        assert.matches("Notes: Easy loop", text, 1, true)
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

    it("uses the right action verb and supports explicit farm instructions", function()
        local addon = load_window()
        local fishingLines = addon:BuildStandaloneMapDetailLines({
            {
                mapID = 114,
                itemName = "Borean Man O' War",
                spotLocation = "Borean Tundra coastal waters",
                targetName = "Borean Man O' War Schools and coastal open water",
                targetType = "fish",
                routeType = "coastal-fishing-pool-loop",
            },
        }, 114, "Borean Tundra")
        local herbLines = addon:BuildStandaloneMapDetailLines({
            {
                mapID = 119,
                itemName = "Crystallized Life",
                spotLocation = "Sholazar Basin herb circuit",
                routeType = "herbalism-loop",
                farmAction = "Gather: Harvest Adder's Tongue nodes; Crystallized Life is a possible bonus gather.",
            },
        }, 119, "Sholazar Basin")

        local fishingText = {}
        for _, line in ipairs(fishingLines) do
            fishingText[#fishingText + 1] = line.text or line.siteName
        end
        local herbText = {}
        for _, line in ipairs(herbLines) do
            herbText[#herbText + 1] = line.text or line.siteName
        end

        assert.matches(
            "Fish: Borean Man O' War Schools and coastal open water",
            table.concat(fishingText, "\n"),
            1,
            true
        )
        assert.matches(
            "Gather: Harvest Adder's Tongue nodes; Crystallized Life is a possible bonus gather.",
            table.concat(herbText, "\n"),
            1,
            true
        )
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

            local staleRow
            for _, row in pairs(addon.standaloneMapFrame.detailSourceRows) do
                if row.button and row.button.sourceUrl == "https://www.wowhead.com/item=12345/material" then
                    staleRow = row
                    break
                end
            end
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

        local locationLine
        for _, line in pairs(addon.standaloneMapFrame.detailTextLines) do
            if line.text == "Area: Adamantite-heavy Nagrand cave and ridge loop" then
                locationLine = line
                break
            end
        end
        assert.is_table(locationLine)
        assert.equals("Area: Adamantite-heavy Nagrand cave and ridge loop", locationLine.text)
        assert.is_true(locationLine.wordWrap)
        assert.is_true(locationLine.nonSpaceWrap)
        assert.equals(0, locationLine.maxLines)
        assert.is_true(locationLine.height > 36)
        assert.is_true(details_scroll_frame.updated)
    end)

    it("uses selected-option titles and custom detail lines for map-first views", function()
        local addon = load_window()
        local details_content = make_frame()
        local details_scroll_frame = make_frame()
        details_scroll_frame.width = 240
        details_scroll_frame.UpdateScrollChildRect = function(self)
            self.updated = true
        end
        local selectedOption = {
            mapID = 107,
            mapLabel = "Nagrand",
            label = "Old Ore Route - Nagrand Loop",
            windowTitle = "Old Ore Route",
            mapOnly = true,
            pins = {},
        }
        local builderOption
        local toggleClicked = false
        local buttonClicked = false
        local selectedFilter
        local selectedSort
        local dropdownInitializer
        local dropdownEntries = {}
        local tooltip = {
            SetOwner = function(self, owner, anchor)
                self.owner = owner
                self.anchor = anchor
            end,
            SetHyperlink = function(self, link)
                self.link = link
            end,
            Show = function(self)
                self.shown = true
            end,
            Hide = function(self)
                self.shown = false
            end,
        }

        addon.standaloneMapFrame = {
            mapID = 107,
            windowTitle = "Fallback title",
            mapOptions = { selectedOption },
            selectedMapOptionIndex = 1,
            mapPins = {},
            mapTitle = make_frame(),
            mapDropdown = make_frame(),
            detailsContent = details_content,
            detailsScrollFrame = details_scroll_frame,
            detailTextLines = {},
            detailSourceRows = {},
            detailTableRows = {},
            detailLinesBuilder = function(option, mapID, mapLabel)
                builderOption = option
                assert.equals(107, mapID)
                assert.equals("Nagrand", mapLabel)
                return {
                    { type = "text", text = "Farm estimate", fontObject = "GameFontNormal" },
                    { type = "text", text = "12,345g/hour", fontObject = "GameFontNormalLarge" },
                    {
                        type = "farmTargetFilter",
                        selectedFilter = "all",
                        filterOptions = {
                            { id = "all", label = "All" },
                            { id = "reagents", label = "Reagents" },
                            { id = "equipment", label = "Armor and Weapons" },
                            { id = "other", label = "Other" },
                        },
                        onSelect = function(filterID) selectedFilter = filterID end,
                    },
                    {
                        type = "farmTargetHeader",
                        sortKey = "itemName",
                        sortAscending = true,
                        onSort = function(sortKey) selectedSort = sortKey end,
                    },
                    {
                        type = "farmTarget",
                        itemID = 3002,
                        itemLink = "item:3002",
                        itemName = "New Herb",
                        itemType = "Herb",
                        quantityText = "x2",
                        totalValueText = "5g",
                        selected = true,
                    },
                    {
                        type = "detailToggle",
                        text = "+ 7 more recorded items",
                        onClick = function()
                            toggleClicked = true
                        end,
                    },
                    { type = "divider", gap = 6 },
                    {
                        type = "detailButton",
                        text = "View all recorded items (8)",
                        onClick = function()
                            buttonClicked = true
                        end,
                    },
                }
            end,
            mapTileTextures = {},
            mapExploredTileTextures = {},
            mapContent = make_frame(),
            statusText = make_frame(),
        }

        loader.with_globals({
            CreateFrame = function(_, _, parent)
                local created = make_frame()
                created.parent = parent
                return created
            end,
            UIDropDownMenu_SetWidth = function(dropdown, width) dropdown.width = width end,
            UIDropDownMenu_Initialize = function(_, initializer) dropdownInitializer = initializer end,
            UIDropDownMenu_CreateInfo = function() return {} end,
            UIDropDownMenu_AddButton = function(info) dropdownEntries[#dropdownEntries + 1] = info end,
            UIDropDownMenu_SetSelectedValue = function(dropdown, value) dropdown.selectedValue = value end,
            UIDropDownMenu_SetText = function(dropdown, value) dropdown.text = value end,
            GameTooltip = tooltip,
            C_Map = {
                GetMapArtLayers = function()
                    return { { layerWidth = 512, layerHeight = 512, tileWidth = 512, tileHeight = 512 } }
                end,
                GetMapArtLayerTextures = function() return { 123 } end,
            },
        }, function()
            addon:RefreshStandaloneMapWindow()

            dropdownInitializer(nil, 1)
            dropdownEntries[3].func()
            addon.standaloneMapFrame.detailTableHeaderRows[4].buttons.quantity.scripts.OnClick(
                addon.standaloneMapFrame.detailTableHeaderRows[4].buttons.quantity
            )

            local itemRow = addon.standaloneMapFrame.detailTableRows[5]
            itemRow.scripts.OnEnter(itemRow)
            assert.equals(itemRow, tooltip.owner)
            assert.equals("ANCHOR_CURSOR", tooltip.anchor)
            assert.equals("item:3002", tooltip.link)
            assert.is_true(tooltip.shown)
            itemRow.scripts.OnLeave(itemRow)
            assert.is_false(tooltip.shown)

            local toggleRow = addon.standaloneMapFrame.detailToggleRows[6]
            toggleRow.scripts.OnClick(toggleRow)
            addon.standaloneMapFrame.detailButtonRows[8].button.scripts.OnClick()
        end)

        assert.equals(selectedOption, builderOption)
        assert.equals("Old Ore Route", addon.standaloneMapFrame.mapTitle.text)
        assert.equals("Farm estimate", addon.standaloneMapFrame.detailTextLines[1].text)
        assert.equals("12,345g/hour", addon.standaloneMapFrame.detailTextLines[2].text)
        assert.equals("All", addon.standaloneMapFrame.detailTableFilterRows[3].dropdown.text)
        assert.equals("equipment", selectedFilter)
        assert.equals("Item ^", addon.standaloneMapFrame.detailTableHeaderRows[4].buttons.itemName.label.text)
        assert.equals("quantity", selectedSort)
        assert.equals("New Herb", addon.standaloneMapFrame.detailTableRows[5].itemText.text)
        assert.equals("Herb", addon.standaloneMapFrame.detailTableRows[5].typeText.text)
        assert.equals("x2", addon.standaloneMapFrame.detailTableRows[5].quantityText.text)
        assert.equals("5g", addon.standaloneMapFrame.detailTableRows[5].valueText.text)
        assert.equals(3002, addon.standaloneMapFrame.detailTableRows[5].itemID)
        assert.equals("item:3002", addon.standaloneMapFrame.detailTableRows[5].itemLink)
        assert.same({ 0.45, 0.92, 1.0, 1 }, addon.standaloneMapFrame.detailTableRows[5].itemText.textColor)
        assert.equals("+ 7 more recorded items", addon.standaloneMapFrame.detailToggleRows[6].label.text)
        assert.is_true(addon.standaloneMapFrame.detailDividerLines[7].shown)
        assert.equals(2, addon.standaloneMapFrame.detailDividerLines[7].thickness)
        assert.same({ 1.0, 0.82, 0.18, 0.85 }, addon.standaloneMapFrame.detailDividerLines[7].color)
        assert.equals("TOPLEFT", addon.standaloneMapFrame.detailDividerLines[7].startPoint[1])
        assert.equals("TOPRIGHT", addon.standaloneMapFrame.detailDividerLines[7].endPoint[1])
        assert.is_true(toggleClicked)
        assert.equals("View all recorded items (8)", addon.standaloneMapFrame.detailButtonRows[8].button.text)
        assert.is_true(buttonClicked)
        assert.equals(
            "Instance map shown; no route coordinates are available. Zoom 1.00x",
            addon.standaloneMapFrame.statusText.text
        )
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

    it("renders numbered route-plan pins together with their connecting line", function()
        local addon = load_window()
        local map_content = make_frame()
        local map_viewport = make_frame()
        map_viewport:SetSize(500, 500)
        addon.standaloneMapFrame = {
            mapID = 12,
            windowTitle = "Route Overview",
            mapDisplayMode = "icons",
            showRouteLinesWithIcons = true,
            mapPins = {
                {
                    mapID = 12, x = 0.20, y = 0.30, label = "1. West Farm",
                    isRoute = true, routeID = "farm-plan:1", routeOrder = 1, routeTotal = 2,
                },
                {
                    mapID = 12, x = 0.70, y = 0.60, label = "2. East Farm",
                    isRoute = true, routeID = "farm-plan:1", routeOrder = 2, routeTotal = 2,
                    mapIconType = "dungeon", mapIconAtlas = "Dungeon",
                },
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
                    return { { layerWidth = 1000, layerHeight = 1000, tileWidth = 500, tileHeight = 500 } }
                end,
                GetMapArtLayerTextures = function() return { 1, 2, 3, 4 } end,
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

            assert.equals(1, #addon.standaloneMapFrame.mapRouteLines)
            assert.is_true(addon.standaloneMapFrame.mapRouteLines[1].shown)
            assert.equals(2, #addon.standaloneMapFrame.mapPinFrames)
            assert.equals("1", addon.standaloneMapFrame.mapPinFrames[1].orderText.text)
            assert.equals("2", addon.standaloneMapFrame.mapPinFrames[2].orderText.text)
            assert.is_true(addon.standaloneMapFrame.mapPinFrames[1].orderText.shown)
            assert.is_true(addon.standaloneMapFrame.mapPinFrames[1].orderBackground.shown)
            assert.is_false(addon.standaloneMapFrame.mapPinFrames[1].icon.shown)
            assert.equals(7, addon.standaloneMapFrame.mapPinFrames[1].orderText.drawSubLevel)
            assert.is_true(addon.standaloneMapFrame.mapPinFrames[2].icon.shown)
            assert.equals("Dungeon", addon.standaloneMapFrame.mapPinFrames[2].icon.atlas)
            assert.same(
                { "TOPRIGHT", addon.standaloneMapFrame.mapPinFrames[2], "TOPRIGHT", 4, 4 },
                addon.standaloneMapFrame.mapPinFrames[2].orderBackground.points[1]
            )
            assert.matches("2 numbered route stops visible", addon.standaloneMapFrame.statusText.text, 1, true)
        end)
    end)

    it("switches the selected farm between its area overlay and coordinate icons", function()
        local addon = load_window({
            GetMapPinIconOption = function()
                return {
                    id = "ore",
                    atlas = "VignetteLoot",
                    texture = "Interface\\Icons\\INV_Ore_Copper_01",
                }
            end,
        })
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
            assert.is_true(addon.standaloneMapFrame.mapPinFrames[1].ring.shown)
            assert.equals("West dragonhawk", addon.standaloneMapFrame.mapPinFrames[1].pinData.label)
            assert.equals(
                "Interface\\Icons\\INV_Ore_Copper_01",
                addon.standaloneMapFrame.mapPinFrames[1].icon.texture
            )
            assert.equals(40, addon.standaloneMapFrame.mapPinFrames[1].frameLevel)
            assert.same({ 1, 1, 1, 1 }, addon.standaloneMapFrame.mapPinFrames[1].icon.vertexColor)
            assert.equals(1, addon.standaloneMapFrame.mapPinFrames[1].icon.alpha)
            assert.same({ "CENTER", map_content, "TOPLEFT", 100, -150 }, addon.standaloneMapFrame.mapPinFrames[1].points[1])
            assert.is_false(addon.standaloneMapFrame.standaloneMapAreaFillLines[1].shown)
            assert.matches("Select one of the 2 farming overlays", addon.standaloneMapFrame.statusText.text, 1, true)

            assert.is_true(addon:ToggleStandaloneMapDisplayMode())
            assert.equals("overlay", addon.standaloneMapFrame.mapDisplayMode)
            assert.equals("Icons", display_mode_button.text)
            assert.is_false(addon.standaloneMapFrame.mapPinFrames[1].shown)
            assert.is_true(addon.standaloneMapFrame.standaloneMapAreaFillLines[1].shown)
        end)
    end)

    it("shows ordinary gathering-route coordinates as icons when the route overlay is toggled off", function()
        local addon = load_window({
            GetMapPinIconOption = function()
                return { texture = "Interface\\Icons\\INV_Misc_Herb_10" }
            end,
        })
        local map_content = make_frame()
        local map_viewport = make_frame()
        map_viewport:SetSize(500, 500)
        addon.standaloneMapFrame = {
            mapID = 109,
            windowTitle = "Mana Thistle",
            mapDisplayMode = "overlay",
            mapPins = {
                { mapID = 109, x = 0.20, y = 0.30, label = "Mana Thistle", isRoute = true, routeID = "mana-thistle" },
                { mapID = 109, x = 0.40, y = 0.50, label = "Mana Thistle", isRoute = true, routeID = "mana-thistle" },
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
            displayModeButton = make_frame(),
        }

        loader.with_globals({
            C_Map = {
                GetMapArtLayers = function()
                    return { { layerWidth = 1000, layerHeight = 1000, tileWidth = 500, tileHeight = 500 } }
                end,
                GetMapArtLayerTextures = function() return { 1, 2, 3, 4 } end,
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
            assert.equals(1, #addon.standaloneMapFrame.mapRouteLines)
            assert.is_true(addon.standaloneMapFrame.mapRouteLines[1].shown)

            assert.is_true(addon:ToggleStandaloneMapDisplayMode())
            assert.equals("icons", addon.standaloneMapFrame.mapDisplayMode)
            assert.is_false(addon.standaloneMapFrame.mapRouteLines[1].shown)
            assert.equals(2, #addon.standaloneMapFrame.mapPinFrames)
            assert.is_true(addon.standaloneMapFrame.mapPinFrames[1].shown)
            assert.is_true(addon.standaloneMapFrame.mapPinFrames[1].icon.shown)
            assert.equals("Interface\\Icons\\INV_Misc_Herb_10", addon.standaloneMapFrame.mapPinFrames[1].icon.texture)
            assert.matches("2 farming location icons visible", addon.standaloneMapFrame.statusText.text, 1, true)
        end)
    end)

    it("sets route waypoints at the first ordered route point", function()
        local addon = load_window()
        local waypoint
        local superTracked
        addon.standaloneMapFrame = {
            mapID = 107,
            mapPins = {
                { mapID = 107, x = 0.22, y = 0.31, label = "Route start", isRoute = true, routeID = "ore-route" },
                { mapID = 107, x = 0.48, y = 0.57, label = "Route middle", isRoute = true, routeID = "ore-route" },
            },
            statusText = make_frame(),
        }

        loader.with_globals({
            UiMapPoint = {
                CreateFromCoordinates = function(mapID, x, y)
                    return { mapID = mapID, x = x, y = y }
                end,
            },
            C_Map = {
                SetUserWaypoint = function(point)
                    waypoint = point
                end,
            },
            C_SuperTrack = {
                SetSuperTrackedUserWaypoint = function(value)
                    superTracked = value
                end,
            },
        }, function()
            assert.is_true(addon:SetStandaloneMapWaypoint())
        end)

        assert.same({ mapID = 107, x = 0.22, y = 0.31 }, waypoint)
        assert.is_true(superTracked)
        assert.matches("Route start %(route start%)", addon.standaloneMapFrame.statusText.text)
    end)

    it("waypoints the selected overlay even when a route is present", function()
        local addon = load_window()
        local waypoint
        addon.standaloneMapFrame = {
            mapID = 100,
            mapPins = {
                { mapID = 100, x = 0.1, y = 0.1, isRoute = true, routeID = "route" },
                { mapID = 100, x = 0.8, y = 0.8, label = "Selected camp", routeID = "camp" },
            },
            statusText = make_frame(),
        }
        addon.RefreshStandaloneMapWindow = function() end
        assert.is_true(addon:SelectStandaloneMapAreaAt(0.8, 0.8))
        loader.with_globals({
            UiMapPoint = { CreateFromCoordinates = function(mapID, x, y)
                return { mapID = mapID, x = x, y = y }
            end },
            C_Map = { SetUserWaypoint = function(point) waypoint = point end },
            C_SuperTrack = false,
        }, function()
            assert.is_true(addon:SetStandaloneMapWaypoint())
        end)
        assert.same({ mapID = 100, x = 0.8, y = 0.8 }, waypoint)
        assert.is_false(addon:SelectStandaloneMapAreaAt(0.5, 0.5))
        assert.equals("route", addon:GetStandaloneMapWaypointDestination().waypointKind)
    end)

    it("adds only the selected overlay through the existing farm dialog", function()
        local payload
        local addon = load_window({
            db = {},
            Print = function() end,
            ShowCustomFarmMethodDialog = function(_, value) payload = value; return true end,
        })
        local source = { itemID = 2770, itemName = "Copper Ore", farmingSourceType = "materials" }
        addon.standaloneMapFrame = {
            mapID = 100,
            customFarmRow = source,
            mapOptions = { { id = "ore-spots", mapID = 100, sourceType = "static" } },
            mapPins = {
                { mapID = 100, x = 0.2, y = 0.2, routeID = "ore", spotLocation = "West camp" },
                { mapID = 100, x = 0.8, y = 0.8, routeID = "ore", spotLocation = "East camp" },
            },
            statusText = make_frame(),
        }
        addon.RefreshStandaloneMapWindow = function() end
        assert.is_false(addon:AddStandaloneMapToCustomFarm())
        assert.is_nil(payload)
        assert.is_true(addon:SelectStandaloneMapAreaAt(0.8, 0.8))
        assert.is_true(addon:AddStandaloneMapToCustomFarm())
        assert.equals(2770, payload.entry.itemID)
        assert.equals("materials", payload.entry.sourceType)
        assert.equals("East camp", payload.entry.locationLabel)
        assert.near(0.8, payload.entry.x, 0.0001)
        assert.equals(1, #payload.entry.mapSource.pins)
        assert.near(0.8, payload.entry.mapSource.pins[1].x, 0.0001)
        assert.is_nil(source.x)
        assert.equals(0, #addon:GetCustomFarms())

        assert.is_true(addon:CommitCustomFarmEntry(payload, nil, payload.entry.mapSource))
        local saved = addon:GetCustomFarms()[1].entries[1]
        assert.equals(payload.entry.mapSource.key, saved.mapSource.key)
        assert.equals(1, #saved.mapSource.pins)

        addon.standaloneMapFrame.mapOptions = { saved.mapSource }
        addon.standaloneMapFrame.mapPins = saved.mapSource.pins
        addon.standaloneMapFrame.selectedMapAreaKey = nil
        assert.is_true(addon:AddStandaloneMapToCustomFarm())
        assert.equals(saved.entryKey, payload.entry.entryKey)
    end)

    it("creates an Add to farm button that submits the current map selection", function()
        local captured
        local projected
        local addon = load_window()
        addon.RequestAddToCustomFarm = function(_, row, sourceType, mapSource)
            captured = { row = row, sourceType = sourceType, mapSource = mapSource }
            return true
        end
        addon.ProjectMapRouteToWorldMap = function(_, options)
            projected = options
            return true
        end
        local function create_frame()
            local frame = make_frame()
            for _, method in ipairs({
                "SetBackdrop", "SetBackdropColor", "SetBackdropBorderColor", "SetFrameStrata",
                "SetToplevel", "SetClampedToScreen", "SetMovable", "EnableMouse", "RegisterForDrag",
                "RegisterEvent", "EnableMouseWheel", "SetClipsChildren", "SetScrollChild",
                "SetVerticalScroll", "Raise", "SetAlpha",
            }) do
                frame[method] = function() end
            end
            return frame
        end
        loader.with_globals({
            CreateFrame = create_frame,
            UIDropDownMenu_SetWidth = function() end,
            UIDropDownMenu_Initialize = function() end,
            C_Map = false,
        }, function()
            addon:OpenStandaloneMapWindow({
                mapID = 100,
                customFarmRow = { itemID = 2770, itemName = "Copper Ore" },
                customFarmSourceType = "materials",
                pins = { { mapID = 100, x = 0.2, y = 0.3 } },
            })
            local button = addon.standaloneMapFrame.addToFarmButton
            assert.equals("Add to farm", button.text)
            assert.equals("Project on BLizzard map", addon.standaloneMapFrame.projectButton.text)
            assert.equals(160, addon.standaloneMapFrame.projectButton.width)
            addon.standaloneMapFrame.projectButton.scripts.OnClick()
            assert.equals(100, projected.mapID)
            assert.equals(1, #projected.pins)
            assert.equals("overlay", projected.displayMode)
            assert.is_false(projected.showRouteLinesWithIcons)
            assert.near(0.2, projected.pins[1].x, 0.0001)
            assert.near(0.3, projected.pins[1].y, 0.0001)
            button.scripts.OnClick(button)
            assert.equals(2770, captured.row.itemID)
            assert.equals("materials", captured.sourceType)
            assert.equals(1, #captured.mapSource.pins)
            assert.near(0.2, captured.row.x, 0.0001)
        end)
    end)

    it("opens a dedicated scrollable window for all recorded yields", function()
        local addon = load_window()
        local dropdownInitializer
        local mapInfoCalls = 0
        local function create_frame()
            local frame = make_frame()
            for _, method in ipairs({
                "SetBackdrop", "SetBackdropColor", "SetBackdropBorderColor", "SetFrameStrata",
                "SetToplevel", "SetClampedToScreen", "SetMovable", "EnableMouse", "RegisterForDrag",
                "RegisterEvent", "EnableMouseWheel", "SetScrollChild", "SetVerticalScroll", "Raise",
            }) do
                frame[method] = function() end
            end
            return frame
        end

        loader.with_globals({
            CreateFrame = create_frame,
            UIDropDownMenu_SetWidth = function() end,
            UIDropDownMenu_Initialize = function(_, initializer) dropdownInitializer = initializer end,
            UIDropDownMenu_SetSelectedValue = function() end,
            UIDropDownMenu_SetText = function(dropdown, text) dropdown.text = text end,
            C_Map = {
                GetMapInfo = function(mapID)
                    mapInfoCalls = mapInfoCalls + 1
                    if mapID == nil then
                        error("bad argument #1 to 'GetMapInfo'")
                    end
                end,
            },
        }, function()
            addon:OpenRecordedYieldsWindow({
                title = "Mana Thistle",
                detailLinesBuilder = function()
                    return {
                        {
                            type = "farmTargetFilter",
                            selectedFilter = "reagents",
                            filterOptions = { { id = "reagents", label = "Reagents" } },
                        },
                        { type = "farmTargetHeader", sortKey = "quantity", sortAscending = false },
                        {
                            type = "farmTarget",
                            itemID = 22793,
                            itemLink = "item:22793",
                            itemName = "Mana Thistle",
                            itemType = "Herb",
                            quantityText = "x12",
                            totalValueText = "120g",
                        },
                    }
                end,
            })
        end)

        local frame = addon.recordedYieldsFrame
        assert.is_true(frame.shown)
        assert.equals("Mana Thistle - all recorded items", frame.farmTitle.text)
        assert.equals("Reagents", frame.detailTableFilterRows[1].dropdown.text)
        assert.equals("Qty v", frame.detailTableHeaderRows[2].buttons.quantity.label.text)
        assert.equals("Mana Thistle", frame.detailTableRows[3].itemText.text)
        assert.equals("x12", frame.detailTableRows[3].quantityText.text)
        assert.is_function(dropdownInitializer)
        assert.equals(0, mapInfoCalls)
    end)

    it("renders grouped map options with non-selectable dropdown section headers", function()
        local dropdownInitializer
        local dropdownEntries = {}
        local addon = load_window()
        local function create_frame()
            local frame = make_frame()
            for _, method in ipairs({
                "SetBackdrop", "SetBackdropColor", "SetBackdropBorderColor", "SetFrameStrata",
                "SetToplevel", "SetClampedToScreen", "SetMovable", "EnableMouse", "RegisterForDrag",
                "RegisterEvent", "EnableMouseWheel", "SetClipsChildren", "SetScrollChild",
                "SetVerticalScroll", "Raise", "SetAlpha",
            }) do
                frame[method] = function() end
            end
            return frame
        end
        loader.with_globals({
            CreateFrame = create_frame,
            UIDropDownMenu_SetWidth = function() end,
            UIDropDownMenu_Initialize = function(_, initializer) dropdownInitializer = initializer end,
            UIDropDownMenu_CreateInfo = function() return {} end,
            UIDropDownMenu_AddButton = function(info) dropdownEntries[#dropdownEntries + 1] = info end,
            UIDropDownMenu_SetSelectedValue = function() end,
            UIDropDownMenu_SetText = function() end,
            C_Map = false,
        }, function()
            addon:OpenStandaloneMapWindow({
                mapOptions = {
                    { mapID = 100, label = "User option", dropdownGroup = "user", dropdownGroupLabel = "User map data", pins = {} },
                    { mapID = 100, label = "Addon option", dropdownGroup = "map", dropdownGroupLabel = "Map data", pins = {} },
                    { mapID = 100, label = "Farm option", dropdownGroup = "farm", dropdownGroupLabel = "Farm data", pins = {} },
                },
            })
            dropdownInitializer(nil, 1)
        end)

        assert.equals(6, #dropdownEntries)
        assert.same({ "User map data", "User option", "Map data", "Addon option", "Farm data", "Farm option" }, {
            dropdownEntries[1].text,
            dropdownEntries[2].text,
            dropdownEntries[3].text,
            dropdownEntries[4].text,
            dropdownEntries[5].text,
            dropdownEntries[6].text,
        })
        assert.is_true(dropdownEntries[1].isTitle)
        assert.is_true(dropdownEntries[1].disabled)
        assert.is_nil(dropdownEntries[1].func)
        assert.is_function(dropdownEntries[2].func)
    end)

    it("adds an ordered route while preserving its route pins", function()
        local addon = load_window()
        addon.standaloneMapFrame = {
            mapID = 100,
            customFarmRow = { itemID = 2770 },
            mapPins = {
                { mapID = 100, x = 0.2, y = 0.3, isRoute = true, routeID = "ore" },
                { mapID = 100, x = 0.4, y = 0.5, isRoute = true, routeID = "ore" },
                { mapID = 100, x = 0.8, y = 0.8, routeID = "camp" },
            },
        }
        local row, reason, source = addon:GetStandaloneMapCustomFarmRow()
        assert.is_nil(reason)
        assert.equals(0.2, row.x)
        assert.equals(2, #source.pins)
        assert.equals(0.4, source.pins[2].x)
    end)

    it("uses the selected farm item without naming it after the farm", function()
        local addon = load_window()
        addon.standaloneMapFrame = {
            mapID = 100,
            mapOptions = { { mapID = 100, selectedItemID = 2770 } },
            mapPins = { { mapID = 100, x = 0.2, y = 0.3, itemName = "Mining farm" } },
        }
        loader.with_globals({ GetItemInfo = function() return "Copper Ore" end }, function()
            local row = addon:GetStandaloneMapCustomFarmRow()
            local entry = addon:BuildCustomFarmEntry(row)
            assert.equals(2770, entry.itemID)
            assert.equals("Copper Ore", entry.itemName)
        end)
        addon.standaloneMapFrame.mapOptions = nil
        assert.is_nil(addon:GetStandaloneMapCustomFarmRow())
    end)

    it("snapshots map item context and clears it when another map opens", function()
        local addon = load_window()
        local frame = make_frame()
        frame.Raise = function() end
        addon.standaloneMapFrame = frame
        addon.RefreshStandaloneMapWindow = function() end
        local source = { itemID = 2770, itemName = "Copper Ore", x = 0.9, y = 0.9, coordX = 90, coordY = 90 }
        addon:OpenStandaloneMapWindow({
            customFarmRow = source, customFarmSourceType = "materials",
            mapOptions = { { mapID = 100, pins = {}, mapOnly = true } },
        })
        source.itemID = 999
        local row = addon:GetStandaloneMapCustomFarmRow()
        local entry = addon:BuildCustomFarmEntry(row)
        assert.equals(2770, entry.itemID)
        assert.equals(100, entry.mapID)
        assert.is_nil(entry.x)
        assert.is_nil(entry.y)
        addon:OpenStandaloneMapWindow({ mapID = 101, pins = {} })
        assert.is_nil(addon:GetStandaloneMapCustomFarmRow())
    end)

    it("uses the center of a single farming overlay as its waypoint", function()
        local addon = load_window()
        addon.standaloneMapFrame = {
            mapID = 100,
            mapPins = {
                { mapID = 100, x = 0.20, y = 0.30, label = "West camp", routeID = "single-camp" },
                { mapID = 100, x = 0.24, y = 0.34, label = "East camp", routeID = "single-camp" },
            },
            statusText = make_frame(),
        }

        local destination, reason, groupCount = addon:GetStandaloneMapWaypointDestination()

        assert.is_nil(reason)
        assert.equals(1, groupCount)
        assert.equals("area", destination.waypointKind)
        assert.equals(100, destination.mapID)
        assert.near(0.22, destination.x, 0.0001)
        assert.near(0.32, destination.y, 0.0001)
    end)

    it("requires selecting one of multiple overlays before setting its waypoint", function()
        local addon = load_window()
        local refreshed = false
        addon.standaloneMapFrame = {
            mapID = 100,
            mapPins = {
                { mapID = 100, x = 0.20, y = 0.20, label = "West camp", routeID = "split-camp" },
                { mapID = 100, x = 0.80, y = 0.80, label = "East camp", routeID = "split-camp" },
            },
            statusText = make_frame(),
        }
        addon.RefreshStandaloneMapWindow = function()
            refreshed = true
        end

        local destination, reason, groupCount = addon:GetStandaloneMapWaypointDestination()
        assert.is_nil(destination)
        assert.equals("select-area", reason)
        assert.equals(2, groupCount)
        assert.is_false(addon:SetStandaloneMapWaypoint())
        assert.matches("Select one of the 2 farming overlays", addon.standaloneMapFrame.statusText.text, 1, true)

        assert.is_true(addon:SelectStandaloneMapAreaAt(0.80, 0.80))
        assert.is_true(refreshed)
        destination, reason, groupCount = addon:GetStandaloneMapWaypointDestination()
        assert.is_nil(reason)
        assert.equals(2, groupCount)
        assert.equals("area", destination.waypointKind)
        assert.near(0.80, destination.x, 0.0001)
        assert.near(0.80, destination.y, 0.0001)
    end)

    it("explains the multi-overlay selection requirement in the waypoint tooltip", function()
        local addon = load_window()
        local details_scroll_frame = make_frame()
        details_scroll_frame.width = 240
        details_scroll_frame.UpdateScrollChildRect = function() end
        local waypoint_button = make_frame()
        addon.standaloneMapFrame = {
            mapID = 100,
            mapPins = {
                { mapID = 100, x = 0.20, y = 0.20, label = "West camp", routeID = "split-camp" },
                { mapID = 100, x = 0.80, y = 0.80, label = "East camp", routeID = "split-camp" },
            },
            mapTitle = make_frame(),
            detailsContent = make_frame(),
            detailsScrollFrame = details_scroll_frame,
            detailTextLines = {},
            detailSourceRows = {},
            mapTileTextures = {},
            mapExploredTileTextures = {},
            mapRouteLines = {},
            mapPinFrames = {},
            mapContent = make_frame(),
            statusText = make_frame(),
            waypointButton = waypoint_button,
        }

        loader.with_globals({ C_Map = false }, function()
            addon:RefreshStandaloneMapWindow()
        end)

        assert.equals(
            "This map has 2 separate farming areas. Click the requested overlay first, then click Set Waypoint.",
            waypoint_button.tooltipText
        )
    end)

    it("navigates to the current map's parent and resets the view", function()
        local addon = load_window()
        local refreshCount = 0
        local details_scroll_frame = make_frame()
        details_scroll_frame.verticalScroll = 80
        details_scroll_frame.SetVerticalScroll = function(self, value)
            self.verticalScroll = value
        end
        local originalPins = { { mapID = 107, x = 0.2, y = 0.3 } }
        addon.standaloneMapFrame = {
            mapID = 107,
            mapPins = originalPins,
            mapOptions = { { mapID = 107, label = "Original map", pins = originalPins } },
            selectedMapOptionIndex = 1,
            mapZoom = 2,
            mapPanX = 120,
            mapPanY = -45,
            mapDragging = true,
            detailsScrollFrame = details_scroll_frame,
            statusText = make_frame(),
        }
        addon.RefreshStandaloneMapWindow = function()
            refreshCount = refreshCount + 1
        end

        loader.with_globals({
            C_Map = {
                GetMapInfo = function(mapID)
                    assert.equals(107, mapID)
                    return { parentMapID = 101 }
                end,
            },
        }, function()
            assert.is_true(addon:NavigateStandaloneMapToParent())
        end)

        assert.equals(101, addon.standaloneMapFrame.mapID)
        assert.equals(1, addon.standaloneMapFrame.mapZoom)
        assert.equals(0, addon.standaloneMapFrame.mapPanX)
        assert.equals(0, addon.standaloneMapFrame.mapPanY)
        assert.is_false(addon.standaloneMapFrame.mapDragging)
        assert.equals(0, details_scroll_frame.verticalScroll)
        assert.equals(1, refreshCount)

        addon.standaloneMapFrame.mapZoom = 2
        addon.standaloneMapFrame.mapPanX = 50
        addon.standaloneMapFrame.mapPanY = 25
        addon.standaloneMapFrame.mapDragging = true
        assert.is_true(addon:ResetStandaloneMapView())
        assert.equals(107, addon.standaloneMapFrame.mapID)
        assert.equals(originalPins, addon.standaloneMapFrame.mapPins)
        assert.equals(1, addon.standaloneMapFrame.mapZoom)
        assert.equals(0, addon.standaloneMapFrame.mapPanX)
        assert.equals(0, addon.standaloneMapFrame.mapPanY)
        assert.is_false(addon.standaloneMapFrame.mapDragging)
        assert.equals(0, details_scroll_frame.verticalScroll)
        assert.equals(2, refreshCount)
    end)

    it("resets a standalone map without dropdown options to its opening map", function()
        local addon = load_window()
        local originalPins = { { mapID = 100, x = 0.4, y = 0.5 } }
        addon.standaloneMapFrame = {
            mapID = 101,
            mapPins = originalPins,
            originalMapID = 100,
            originalMapPins = originalPins,
            mapZoom = 2,
            mapPanX = 30,
            mapPanY = -20,
            detailsScrollFrame = { SetVerticalScroll = function(self, value) self.verticalScroll = value end },
        }
        addon.RefreshStandaloneMapWindow = function() end

        assert.is_true(addon:ResetStandaloneMapView())
        assert.equals(100, addon.standaloneMapFrame.mapID)
        assert.equals(originalPins, addon.standaloneMapFrame.mapPins)
        assert.equals(1, addon.standaloneMapFrame.mapZoom)
        assert.equals(0, addon.standaloneMapFrame.mapPanX)
        assert.equals(0, addon.standaloneMapFrame.mapPanY)
        assert.equals(0, addon.standaloneMapFrame.detailsScrollFrame.verticalScroll)
    end)

    it("keeps the current standalone map when it has no parent", function()
        local addon = load_window()
        addon.standaloneMapFrame = {
            mapID = 101,
            statusText = make_frame(),
        }

        loader.with_globals({
            C_Map = {
                GetMapInfo = function()
                    return { parentMapID = 0 }
                end,
            },
        }, function()
            assert.is_false(addon:NavigateStandaloneMapToParent())
        end)

        assert.equals(101, addon.standaloneMapFrame.mapID)
        assert.equals("This map has no parent map.", addon.standaloneMapFrame.statusText.text)
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
