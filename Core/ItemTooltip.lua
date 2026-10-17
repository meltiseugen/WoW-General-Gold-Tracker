local _, NS = ...
local GoldTracker = NS.GoldTracker

function GoldTracker:CreateItemTooltipTarget(row, itemText, itemIcon, onEnter, onLeave)
    if not row or not itemText or type(onEnter) ~= "function" then
        return nil
    end

    local target = CreateFrame("Frame", nil, row)
    target.goldTrackerItemTooltipRow = row

    local leftRegion = itemIcon or itemText
    target:SetPoint("TOPLEFT", leftRegion, "TOPLEFT", 0, 0)
    target:SetPoint("BOTTOMRIGHT", itemText, "BOTTOMRIGHT", 0, 0)
    target:SetScript("OnEnter", function(self)
        onEnter(self.goldTrackerItemTooltipRow, self)
    end)
    target:SetScript("OnLeave", function(self)
        if type(onLeave) == "function" then
            onLeave(self.goldTrackerItemTooltipRow, self)
        elseif GameTooltip then
            GameTooltip:Hide()
        end
    end)

    -- This overlay only needs hover events. Leave clicks with the row instead of
    -- capturing and propagating them: propagation setters are restricted in combat.
    target:SetMouseClickEnabled(false)
    target:SetMouseMotionEnabled(true)

    row.itemTooltipTarget = target
    return target
end
