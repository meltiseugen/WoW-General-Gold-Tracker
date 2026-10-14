local loader = require("tests.helpers.addon_loader")

local function frame(shown, fields)
    fields = fields or {}
    fields.IsShown = function() return shown end
    return fields
end

describe("Explorer cache lifecycle", function()
    it("releases hidden derived data while preserving unsaved results and filters", function()
        local results = { { itemID = 123 } }
        local addon = loader.load_module("UI/ExplorerMemory.lua", {
            craftingFarmingFrame = frame(false, { itemCache = { heavy = {} }, materialDisplayRows = {}, expansionID = "classic" }),
            instanceFarmingFrame = frame(false, { transmogRows = {}, transmogPricesReadyRows = {}, lastResults = results }),
            observedDropsFrame = frame(false, { itemCache = { heavy = {} }, priceCache = {}, scannedObservedDropsRows = results }),
            inventoryFrame = frame(false),
            StopInstanceTransmogPriceWorker = function() end,
            InvalidateAuctionableInventoryScanCache = function(self) self.inventoryBuildCache = nil end,
            inventoryBuildCache = { heavy = {} },
        })
        addon:ReleaseHiddenExplorerCaches()
        assert.same({}, addon.craftingFarmingFrame.itemCache)
        assert.is_nil(addon.craftingFarmingFrame.materialDisplayRows)
        assert.equals("classic", addon.craftingFarmingFrame.expansionID)
        assert.is_nil(addon.instanceFarmingFrame.transmogRows)
        assert.is_nil(addon.instanceFarmingFrame.transmogPricesReadyRows)
        assert.equals(results, addon.instanceFarmingFrame.lastResults)
        assert.equals(results, addon.observedDropsFrame.scannedObservedDropsRows)
        assert.same({}, addon.observedDropsFrame.itemCache)
        assert.is_nil(addon.inventoryBuildCache)
    end)

    it("keeps data needed by active scans and visible expanded material windows", function()
        local cache = { active = true }
        local scan = { isScanning = true }
        local addon = loader.load_module("UI/ExplorerMemory.lua", {
            craftingFarmingFrame = frame(false, { itemCache = cache }),
            craftingFarmingExpandedFrame = frame(true),
            observedDropsFrame = frame(false, { itemCache = cache, priceCache = cache, scanState = scan }),
        })
        addon:ReleaseHiddenExplorerCaches()
        assert.equals(cache, addon.craftingFarmingFrame.itemCache)
        assert.equals(cache, addon.observedDropsFrame.itemCache)
        assert.equals(cache, addon.observedDropsFrame.priceCache)
        assert.equals(scan, addon.observedDropsFrame.scanState)
    end)

    it("releases rare scan working tables only after completion or cancellation", function()
        local addon = loader.load_module("UI/RareFarmingWindow.lua", {})
        local results = { { itemID = 123 } }
        local state = { rareIDs = { 1 }, rareIndex = 1, rares = {}, itemCache = {}, resultsByKey = {}, results = results }
        addon.rareFarmingFrame = { scanState = state }
        addon:ReleaseRareFarmingScanWorkingData()
        assert.is_table(state.itemCache)
        state.rareIndex = 2
        addon:ReleaseRareFarmingScanWorkingData()
        assert.is_nil(state.itemCache)
        assert.is_nil(state.rares)
        assert.is_nil(state.rareIDs)
        assert.is_nil(state.resultsByKey)
        assert.equals(results, state.results)
        assert.equals(state, addon.rareFarmingFrame.scanState)
    end)

    it("does not rebuild the closed tracker on loot updates", function()
        local addon = loader.load_module("UI/MainWindow.lua", {
            mainFrame = frame(false),
            GetCurrentValueSource = function() error("Hidden UI must not rebuild") end,
        })
        addon:UpdateMainWindow()
    end)

    it("constructs the tracker on first open and preserves slash opening modes", function()
        local created, modes = 0, {}
        local addon = loader.load_module("UI/MainWindow.lua", {})
        addon.CreateMainWindow = function(self)
            created = created + 1
            self.mainFrame = {}
        end
        addon.GetMainWindowSlashOpenMode = function() return { id = "tiny" } end
        addon.SetMainWindowTiny = function(_, enabled) modes[#modes + 1] = enabled and "tiny" end
        addon.SetMainWindowCompact = function(_, enabled) modes[#modes + 1] = enabled and "minimized" or "maximized" end
        addon:OpenMainWindowFromSlash()
        addon:OpenMainWindow()
        assert.equals(1, created)
        assert.same({ "tiny", "maximized" }, modes)
    end)
end)
