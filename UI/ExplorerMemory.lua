local _, NS = ...
local GoldTracker = NS.GoldTracker

local function IsVisible(frame)
    return frame and frame.IsShown and frame:IsShown()
end

function GoldTracker:ReleaseHiddenExplorerCaches()
    -- Keep reusable widgets, filter/selection state, saved scans and unsaved
    -- results. Only release derived caches that the existing refresh paths rebuild.
    local materials = self.craftingFarmingFrame
    if materials and not IsVisible(materials) and not IsVisible(self.craftingFarmingExpandedFrame) then
        materials.materialsRefreshGeneration = (tonumber(materials.materialsRefreshGeneration) or 0) + 1
        materials.materialsRealtimeLoading = false
        materials.itemCache = {}
        materials.materialsDemandCache = {}
        materials.searchItemDataRequested = {}
        materials.materialDisplayRows = nil
    end

    local instances = self.instanceFarmingFrame
    if instances and not IsVisible(instances) then
        self:StopInstanceTransmogPriceWorker()
        instances.transmogRows = nil
        instances.transmogRowsExpansionFilterID = nil
        instances.transmogPricesReadyRows = nil
        instances.transmogPricesReadySourceID = nil
    end

    local drops = self.observedDropsFrame
    if drops and not IsVisible(drops) and not (drops.scanState and drops.scanState.isScanning) then
        drops.itemCache = {}
        drops.priceCache = {}
    end

    if self.inventoryFrame and not IsVisible(self.inventoryFrame)
        and not IsVisible(self.inventoryItemDetailsFrame)
        and type(self.InvalidateAuctionableInventoryScanCache) == "function" then
        self:InvalidateAuctionableInventoryScanCache()
    end

    if type(self.ReleaseRareFarmingScanWorkingData) == "function" then
        self:ReleaseRareFarmingScanWorkingData()
    end
end
