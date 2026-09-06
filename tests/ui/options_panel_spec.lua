local loader = require("tests.helpers.addon_loader")

local function edit_box(initial_text)
    return {
        text = initial_text,
        GetText = function(self)
            return self.text
        end,
        SetText = function(self, text)
            self.text = text
        end,
    }
end

local function load_options(addon)
    return loader.load_module("UI/OptionsPanel.lua", addon, {
        JanisTheme = {},
    })
end

describe("UI/OptionsPanel numeric inputs", function()
    it("saves highlight thresholds as copper and restores invalid input to the current value", function()
        local refresh_count = 0
        local update_count = 0
        local addon = load_options({
            COPPER_PER_GOLD = 10000,
            db = {
                highlightThreshold = 250000,
            },
        })
        addon.NormalizeHighlightThresholds = function() end
        addon.RefreshOptionsControls = function()
            refresh_count = refresh_count + 1
        end
        addon.UpdateMainWindow = function()
            update_count = update_count + 1
        end

        local input = edit_box("12.345")
        addon:SaveHighlightThresholdInput(input, "highlightThreshold")

        assert.equals(123450, addon.db.highlightThreshold)
        assert.equals(1, refresh_count)
        assert.equals(1, update_count)

        input:SetText("-1")
        addon:SaveHighlightThresholdInput(input, "highlightThreshold")

        assert.equals("12.35", input:GetText())
        assert.equals(123450, addon.db.highlightThreshold)
        assert.equals(1, refresh_count)
        assert.equals(1, update_count)
    end)

    it("clamps history rows per page and resets the list page when visible", function()
        local refreshed = false
        local addon = load_options({
            db = {
                historyRowsPerPage = 10,
            },
            GetHistoryRowsPerPage = function(self)
                return self.db.historyRowsPerPage
            end,
            historyFrame = {
                view = "list",
                currentPage = 4,
                IsShown = function()
                    return true
                end,
            },
            RefreshHistoryWindow = function()
                refreshed = true
            end,
        })

        local input = edit_box("99")
        addon:SaveHistoryRowsPerPageInput(input)

        assert.equals(30, addon.db.historyRowsPerPage)
        assert.equals("30", input:GetText())
        assert.equals(1, addon.historyFrame.currentPage)
        assert.is_true(refreshed)
    end)

    it("clamps history details font size and refreshes visible details", function()
        local applied = false
        local refreshed = false
        local addon = load_options({
            db = {
                historyDetailsFontSize = 14,
            },
            GetHistoryDetailsFontSize = function(self)
                return self.db.historyDetailsFontSize
            end,
            historyFrame = {
                view = "details",
                IsShown = function()
                    return true
                end,
            },
            ApplyHistoryDetailsFontSize = function()
                applied = true
            end,
            RefreshHistoryDetailsWindow = function()
                refreshed = true
            end,
        })

        local input = edit_box("5")
        addon:SaveHistoryDetailsFontSizeInput(input)

        assert.equals(8, addon.db.historyDetailsFontSize)
        assert.equals("8", input:GetText())
        assert.is_true(applied)
        assert.is_true(refreshed)
    end)

    it("clamps market history numeric settings and prunes cached history", function()
        local pruned = false
        local addon = load_options({
            db = {},
            PruneMarketHistory = function()
                pruned = true
            end,
        })

        local value = addon:SetMarketHistoryNumberOption("marketHistoryRetentionDays", "999", 7, 365, 120)

        assert.equals(365, value)
        assert.equals(365, addon.db.marketHistoryRetentionDays)
        assert.is_true(pruned)
    end)

    it("saves world map projection pin size and refreshes active map pins", function()
        local refresh_count = 0
        local displayed_text
        local addon = load_options({
            db = {},
            NormalizeWorldMapProjectionPinScale = function(_, value)
                return math.max(0.6, math.min(2.0, tonumber(value) or 1))
            end,
            optionsControls = {
                worldMapProjectionPinScaleValueText = {
                    SetText = function(_, text)
                        displayed_text = text
                    end,
                },
            },
            worldMapRouteDataProvider = {
                RefreshAllData = function()
                    refresh_count = refresh_count + 1
                end,
            },
        })

        addon:SetWorldMapProjectionPinScaleOption("1.5")

        assert.equals(1.5, addon.db.worldMapProjectionPinScale)
        assert.equals("150%", displayed_text)
        assert.equals(1, refresh_count)
    end)
end)
