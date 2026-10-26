local _, NS = ...
local GoldTracker = NS.GoldTracker

-- Only actual catalog access loads a data addon. Startup price checks use the
-- small MaterialIndex instead, so they never walk the full Explorer catalogs.
local catalogModules = {
    RareDropsData = "Rares",
    InstanceDropsData = "Instances",
    ATTBoEDropsData = "Instances",
    InstanceLocationResearch = "Instances",
    CatalogDropsData = "Drops",
    RecipeDropsData = "Drops",
    CosmeticDropsData = "Drops",
    FarmCatalog = "Farms",
    MountFarmData = "Farms",
    PetFarmData = "Farms",
    ToyFarmData = "Farms",
    RecipeFarmData = "Farms",
    CosmeticFarmData = "Farms",
    MaterialFarmingSpots = "Materials",
    CatalogGatheringData = "Materials",
    ClassicHousing = "Materials",
}
local loading = {}

-- Data addons have separate private namespaces; their Namespace.lua forwards
-- reads and writes to this one. No Blizzard globals or frames are modified.
_G.GeneralGoldTrackerCatalogNamespace = NS

function GoldTracker:LoadCatalog(module)
    local addonName = "General-Gold-Tracker_" .. module
    if loading[module] then
        return false, "Circular catalog dependency: " .. module
    end
    local loadAddOn = C_AddOns and C_AddOns.LoadAddOn or LoadAddOn
    if type(loadAddOn) ~= "function" then
        return false, "The addon loader is unavailable"
    end
    loading[module] = true
    local ok, loaded, reason = pcall(loadAddOn, addonName)
    loading[module] = nil
    if not ok or not loaded then
        return false, tostring(reason or loaded or "unknown error")
    end
    return true
end

setmetatable(NS, {
    __index = function(namespace, key)
        local module = catalogModules[key]
        if not module then
            return nil
        end
        local loaded, reason = GoldTracker:LoadCatalog(module)
        if not loaded then
            error("General Gold Tracker could not load " .. module .. " data (" .. reason
                .. "). Install all GGT folders and restart WoW after adding data addons.")
        end
        return rawget(namespace, key)
    end,
})
