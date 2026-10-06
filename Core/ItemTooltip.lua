local _, NS = ...
local GoldTracker = NS.GoldTracker

function GoldTracker:CreateItemTooltipTarget(row, itemText, itemIcon, onEnter, onLeave)
    if not row or not itemText or type(onEnter) ~= "function" then
        return nil
    end

    local target = CreateFrame("Frame", nil, row)
    target.goldTrackerItemTooltipRow = row
    target:EnableMouse(true)
    if type(target.SetPropagateMouseClicks) == "function" then
        target:SetPropagateMouseClicks(true)
    end
    if type(target.SetPropagateMouseMotion) == "function" then
        target:SetPropagateMouseMotion(true)
    end

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

    row.itemTooltipTarget = target
    return target
end
