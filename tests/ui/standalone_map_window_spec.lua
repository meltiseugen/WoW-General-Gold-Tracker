local loader = require("tests.helpers.addon_loader")

local function load_window(addon)
    return loader.load_module("UI/StandaloneMapWindow.lua", addon or {}, {})
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
        assert.equals("Adamantite-heavy Nagrand cave and ridge loop", locationLine.text)
        assert.is_true(locationLine.wordWrap)
        assert.is_true(locationLine.nonSpaceWrap)
        assert.equals(0, locationLine.maxLines)
        assert.is_true(locationLine.height > 36)
        assert.is_true(details_scroll_frame.updated)
    end)
end)
