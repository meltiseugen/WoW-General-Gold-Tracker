local _, NS = ...
local GoldTracker = NS.GoldTracker

function GoldTracker:GetSessionLocationTransitionDecision(session, current, splitMode)
    if type(session) ~= "table" or session.active ~= true then
        return nil
    end

    local previousLocationKey = self.GetLocationGroupKey and self:GetLocationGroupKey(session) or session.locationKey
    if type(previousLocationKey) ~= "string" then
        return nil
    end

    if type(current) ~= "table"
        or type(current.locationKey) ~= "string"
        or (self.GetLocationGroupKey and self:GetLocationGroupKey(current) or current.locationKey) == previousLocationKey then
        return nil
    end

    local previousWasInstanced = session.isInstanced == true
    local isInstancedNow = current.isInstanced == true
    -- A location visit is independent of the session. Splitting is opt-in,
    -- symmetrical on instance entry/exit, and never driven by floor names.
    if splitMode == true then splitMode = "location" end
    if splitMode ~= "location" and not (splitMode == "instance" and (previousWasInstanced or isInstancedNow)) then
        return nil
    end

    local transitionLabel = (previousWasInstanced or isInstancedNow) and "instance" or "zone"
    return {
        transitionLabel = transitionLabel,
        saveReason = transitionLabel == "instance" and "instance-switch" or "location-switch",
        previousName = session.instanceName or session.zoneName or "Unknown",
        currentName = current.instanceName or current.zoneName or "Unknown",
    }
end
