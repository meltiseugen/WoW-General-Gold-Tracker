local _, NS = ...
local GoldTracker = NS.GoldTracker

function GoldTracker:GetSessionLocationTransitionDecision(session, current, allowZoneTransition)
    if type(session) ~= "table" or session.active ~= true then
        return nil
    end

    local previousLocationKey = session.locationKey
    if type(previousLocationKey) ~= "string" then
        return nil
    end

    if type(current) ~= "table"
        or type(current.locationKey) ~= "string"
        or current.locationKey == previousLocationKey then
        return nil
    end

    local previousWasInstanced = session.isInstanced == true
    local isInstancedNow = current.isInstanced == true
    if not isInstancedNow and allowZoneTransition ~= true then
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
