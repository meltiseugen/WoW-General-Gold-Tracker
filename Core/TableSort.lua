local _, NS = ...
local GoldTracker = NS.GoldTracker

local function IsValidSortKey(validKeys, sortKey)
    return type(sortKey) == "string" and (validKeys == nil or validKeys[sortKey] == true)
end

function GoldTracker:GetTableSortCriteria(frame, sortKeyField, sortAscendingField, validKeys)
    local criteria = {}
    local seen = {}

    if frame and type(frame.sortCriteria) == "table" then
        for _, criterion in ipairs(frame.sortCriteria) do
            local sortKey = type(criterion) == "table" and criterion.key or nil
            if IsValidSortKey(validKeys, sortKey) and not seen[sortKey] then
                criteria[#criteria + 1] = {
                    key = sortKey,
                    ascending = criterion.ascending == true,
                }
                seen[sortKey] = true
            end
        end
    end

    if #criteria == 0 and frame then
        local sortKey = frame[sortKeyField]
        if IsValidSortKey(validKeys, sortKey) then
            criteria[1] = {
                key = sortKey,
                ascending = frame[sortAscendingField] == true,
            }
        end
    end

    return criteria
end

function GoldTracker:SetTableSortCriteria(frame, criteria, sortKeyField, sortAscendingField, validKeys)
    if not frame then
        return {}
    end

    local normalized = {}
    local seen = {}
    for _, criterion in ipairs(type(criteria) == "table" and criteria or {}) do
        local sortKey = type(criterion) == "table" and criterion.key or nil
        if IsValidSortKey(validKeys, sortKey) and not seen[sortKey] then
            normalized[#normalized + 1] = {
                key = sortKey,
                ascending = criterion.ascending == true,
            }
            seen[sortKey] = true
        end
    end

    frame.sortCriteria = normalized
    frame[sortKeyField] = normalized[1] and normalized[1].key or nil
    frame[sortAscendingField] = normalized[1] and normalized[1].ascending == true or false
    return normalized
end

function GoldTracker:ToggleTableSortCriterion(frame, sortKey, defaultAscending, options)
    options = options or {}
    local validKeys = options.validKeys
    if not frame or not IsValidSortKey(validKeys, sortKey) then
        return nil
    end

    local sortKeyField = options.sortKeyField or "sortKey"
    local sortAscendingField = options.sortAscendingField or "sortAscending"
    local criteria = self:GetTableSortCriteria(frame, sortKeyField, sortAscendingField, validKeys)
    local additive = options.additive
    if additive == nil then
        additive = type(IsShiftKeyDown) == "function" and IsShiftKeyDown() == true
    end

    if additive then
        local matched = false
        for _, criterion in ipairs(criteria) do
            if criterion.key == sortKey then
                criterion.ascending = criterion.ascending ~= true
                matched = true
                break
            end
        end
        if not matched then
            criteria[#criteria + 1] = {
                key = sortKey,
                ascending = defaultAscending == true,
            }
        end
    elseif #criteria == 1 and criteria[1].key == sortKey then
        if options.allowClear == true and criteria[1].ascending == true then
            criteria = {}
        else
            criteria[1].ascending = criteria[1].ascending ~= true
        end
    else
        criteria = {
            {
                key = sortKey,
                ascending = defaultAscending == true,
            },
        }
    end

    return self:SetTableSortCriteria(frame, criteria, sortKeyField, sortAscendingField, validKeys)
end

function GoldTracker:GetTableSortCriterion(criteria, sortKey)
    for index, criterion in ipairs(type(criteria) == "table" and criteria or {}) do
        if type(criterion) == "table" and criterion.key == sortKey then
            return criterion, index
        end
    end
    return nil, nil
end

function GoldTracker:AttachTableSortHeaderTooltip(button, label)
    if not button or button.goldTrackerSortTooltipAttached then
        return
    end

    local bindScript = type(button.HookScript) == "function" and button.HookScript or button.SetScript
    if type(bindScript) ~= "function" then
        return
    end

    button.goldTrackerSortTooltipAttached = true
    bindScript(button, "OnEnter", function(header)
        if not GameTooltip then
            return
        end
        GameTooltip:SetOwner(header, "ANCHOR_CURSOR")
        GameTooltip:AddLine("Sort by " .. tostring(label or "column"), 1, 1, 1)
        GameTooltip:AddLine("Click to sort by this column.", 0.82, 0.82, 0.82, true)
        GameTooltip:AddLine("Shift-click additional headers to add sorting levels.", 1.0, 0.82, 0.18, true)
        GameTooltip:AddLine("Shift-click an active header to reverse its direction.", 0.72, 0.76, 0.84, true)
        GameTooltip:Show()
    end)
    bindScript(button, "OnLeave", function()
        if GameTooltip then
            GameTooltip:Hide()
        end
    end)
end
