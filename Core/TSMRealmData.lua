local _, NS = ...
local GoldTracker = NS.GoldTracker
local MODULE = "General-Gold-Tracker_TSMRealmData"

-- The optional module owns every captured payload, hook, decoder and profiler.
-- This bridge never lazy-loads it in response to a price query: that is too late.
function GoldTracker:InitializeTSMRealmData()
    local enabled = C_AddOns and C_AddOns.GetAddOnEnableState
    if type(enabled) == "function" then
        local ok, value = pcall(enabled, MODULE, type(UnitName) == "function" and UnitName("player") or nil)
        if not ok then
            self.tsmRealmDataLoadReason = "could not read optional module enable state: " .. tostring(value)
            return false
        elseif value == 0 then
            self.tsmRealmDataLoadReason = "disabled in the AddOns list (reload after changing it)"
            return false
        end
    end
    local load = C_AddOns and C_AddOns.LoadAddOn or LoadAddOn
    if type(load) ~= "function" then
        self.tsmRealmDataLoadReason = "addon loader unavailable"
        return false
    end
    -- At GGT's ADDON_LOADED event, its dependency is satisfied. Loading now
    -- preserves the early capture window without a circular TOC dependency.
    local ok, loaded, reason = pcall(load, MODULE)
    if not ok or not loaded then
        self.tsmRealmDataLoadReason = tostring(reason or loaded or "module not installed")
        return false
    end
    self.tsmRealmDataLoadReason = nil
    return true
end

-- Replaced by the module when it loads; existing current-realm pricing has no
-- dependency on these functions and keeps using the normal public TSM API.
function GoldTracker:GetCapturedTSMRealmItemValues()
    return nil
end

function GoldTracker:GetCapturedTSMRealms()
    return {}
end

function GoldTracker:GetCapturedTSMRealmRevision()
    return 0
end

function GoldTracker:BuildTSMRealmCaptureReport()
    return "GGT TSM Realm Prices: unavailable - " .. (self.tsmRealmDataLoadReason or "optional module not loaded")
end

SLASH_GGTTSMCAPTURE1 = "/gttsm"
SlashCmdList.GGTTSMCAPTURE = function()
    GoldTracker:Print(GoldTracker:BuildTSMRealmCaptureReport(), "commands")
end
