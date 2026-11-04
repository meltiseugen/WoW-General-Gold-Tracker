local loader = require("tests.helpers.addon_loader")

local function noop() end
local function widget()
    return setmetatable({
        SetShown = function(self, shown) self.shown = shown end,
        SetHeight = function(self, height) self.height = height end,
    }, { __index = function() return noop end })
end

local function with_window(path, callback)
    local addon = {
        db = {
            rareFarmingMinimumValue = 0, rareFarmingExpansionFilter = "all", rareFarmingScanMode = "background",
            observedWorldDropsValueSource = "test", observedSavedSessionDrops = {},
        },
        DEFAULTS = {},
        VALUE_SOURCE_BY_ID = { test = { id = "test", label = "Test" } },
    }
    local data = { expansions = { currentID = 1, options = { { id = 1, label = "Classic" } } } }
    loader.load_module(path, addon, {
        JanisTheme = { LayoutExplorerActionButtons = noop, SetProgressBarProgress = noop },
        RareDropsData = data, InstanceDropsData = data,
        ATTBoEDropsData = { zones = {}, world = { items = {} }, expansions = { options = {} } },
    })
    loader.with_globals({ UIDropDownMenu_SetSelectedValue = noop, UIDropDownMenu_SetText = noop }, function()
        callback(addon)
    end)
end

describe("Explorer scan progress visibility", function()
    it("hides the rare bar for saved scans, idle, cancelled and finished scans", function()
        with_window("UI/RareFarmingWindow.lua", function(addon)
            local frame = { valueSourceID = "test", progressBackdrop = widget(), loadedRareFarmingCache = {} }
            addon.rareFarmingFrame = frame
            addon:RefreshRareFarmingWindowControls()
            assert.is_false(frame.progressBackdrop.shown)
            frame.scanState = { rareIDs = { 1, 2 }, rareIndex = 1 }
            addon:RefreshRareFarmingWindowControls()
            assert.is_true(frame.progressBackdrop.shown)
            frame.scanState.cancelled = true
            addon:RefreshRareFarmingWindowControls()
            assert.is_false(frame.progressBackdrop.shown)
            frame.scanState = { rareIDs = { 1, 2 }, rareIndex = 3 }
            addon:RefreshRareFarmingWindowControls()
            assert.is_false(frame.progressBackdrop.shown)
        end)
    end)

    it("keeps instance progress visible while binding loads are pending and hides idle progress", function()
        with_window("UI/InstanceFarmingWindow.lua", function(addon)
            local frame = {
                valueSourceID = "test", progressBackdrop = widget(),
                scanButton = widget(), stopScanButton = widget(), saveButton = widget(),
                updatePricesButton = widget(), rescanButton = widget(),
            }
            addon.instanceFarmingFrame = frame
            addon:RefreshInstanceFarmingWindowControls()
            assert.is_false(frame.progressBackdrop.shown)
            frame.scanState = { index = 1, total = 1, pendingRows = { {} } }
            frame.progressComplete = false
            addon:RefreshInstanceFarmingWindowControls()
            assert.is_true(frame.progressBackdrop.shown)
            frame.scanState = nil
            addon:RefreshInstanceFarmingWindowControls()
            assert.is_false(frame.progressBackdrop.shown)
        end)
    end)

    it("only expands Drops controls for an active scan", function()
        with_window("UI/ObservedDropsWindow.lua", function(addon)
            local frame = {
                dropSourceID = "att-zones", expansionFilterID = "all",
                progressBackdrop = widget(), controlsPanel = widget(), loadedObservedDropsScanCache = {},
            }
            addon.observedDropsFrame = frame
            addon:RefreshObservedDropsWindowControls()
            assert.is_false(frame.progressBackdrop.shown)
            assert.equals(118, frame.controlsPanel.height)
            frame.scanState = { isScanning = true, totalDrops = 10, scannedDrops = 2 }
            addon:RefreshObservedDropsWindowControls()
            assert.is_true(frame.progressBackdrop.shown)
            assert.equals(150, frame.controlsPanel.height)
            frame.scanState.isScanning = false
            addon:RefreshObservedDropsWindowControls()
            assert.is_false(frame.progressBackdrop.shown)
            assert.equals(118, frame.controlsPanel.height)
        end)
    end)
end)
