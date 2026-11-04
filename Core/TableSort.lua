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

    if options.mouseButton == "RightButton" then
        if not additive then
            return nil
        end
        for index, criterion in ipairs(criteria) do
            if criterion.key == sortKey then
                table.remove(criteria, index)
                break
            end
        end
    elseif additive then
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

function GoldTracker:EnsureTableSortLeadingCriterion(frame, sortKey, ascending, options)
    options = options or {}
    local validKeys = options.validKeys
    if not frame or not IsValidSortKey(validKeys, sortKey) then
        return {}
    end

    local sortKeyField = options.sortKeyField or "sortKey"
    local sortAscendingField = options.sortAscendingField or "sortAscending"
    local criteria = self:GetTableSortCriteria(frame, sortKeyField, sortAscendingField, validKeys)
    local normalized = {
        {
            key = sortKey,
            ascending = ascending == true,
        },
    }

    for _, criterion in ipairs(criteria) do
        if criterion.key ~= sortKey then
            normalized[#normalized + 1] = criterion
        elseif criterion.ascending ~= nil then
            normalized[1].ascending = criterion.ascending == true
        end
    end

    return self:SetTableSortCriteria(frame, normalized, sortKeyField, sortAscendingField, validKeys)
end

local function NormalizeLocationGroupLabel(label)
    local normalized = tostring(label or "")
    normalized = string.match(normalized, "^%s*(.-)%s*$") or ""
    return normalized ~= "" and normalized or "Unknown location"
end

function GoldTracker:BuildLocationGroupedDisplayRows(rows, getGroupLabel, collapsedGroups, showHeaders)
    if showHeaders ~= true or type(getGroupLabel) ~= "function" then
        return rows or {}
    end

    local sourceRows = rows or {}
    local displayRows = {}
    local index = 1
    while index <= #sourceRows do
        local label = NormalizeLocationGroupLabel(getGroupLabel(sourceRows[index]))
        local key = string.lower(label)
        local lastIndex = index
        while lastIndex < #sourceRows do
            local nextLabel = NormalizeLocationGroupLabel(getGroupLabel(sourceRows[lastIndex + 1]))
            if string.lower(nextLabel) ~= key then
                break
            end
            lastIndex = lastIndex + 1
        end

        local isCollapsed = type(collapsedGroups) ~= "table" or collapsedGroups[key] ~= false
        displayRows[#displayRows + 1] = {
            isLocationGroupHeader = true,
            locationGroupKey = key,
            locationGroupLabel = label,
            itemCount = lastIndex - index + 1,
            collapsed = isCollapsed,
        }
        if not isCollapsed then
            for rowIndex = index, lastIndex do
                displayRows[#displayRows + 1] = sourceRows[rowIndex]
            end
        end
        index = lastIndex + 1
    end

    return displayRows
end

function GoldTracker:ToggleLocationGroupCollapsed(collapsedGroups, groupKey, currentlyCollapsed)
    if type(collapsedGroups) ~= "table" or groupKey == nil then
        return nil
    end

    local nextCollapsed = currentlyCollapsed ~= true
    collapsedGroups[groupKey] = nextCollapsed
    return nextCollapsed
end

function GoldTracker:IsCollapsedLocationHeadersEnabled()
    return type(self.db) ~= "table" or self.db.collapsedLocationHeaders ~= false
end

function GoldTracker:SetCollapsedLocationHeadersEnabled(enabled)
    if type(self.db) == "table" then
        self.db.collapsedLocationHeaders = enabled == true
    end
    return enabled == true
end

function GoldTracker:BindTableSortHeaderClick(button, onSort, sortKey)
    if type(button.RegisterForClicks) == "function" then
        button:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    end
    button:SetScript("OnClick", function(_, mouseButton)
        if mouseButton == "RightButton" then
            if type(IsShiftKeyDown) ~= "function" or IsShiftKeyDown() ~= true then
                return
            end
        elseif mouseButton ~= nil and mouseButton ~= "LeftButton" then
            return
        end
        onSort(self, sortKey, mouseButton)
    end)
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
        GameTooltip:AddLine("Shift-right-click a header to remove its sorting level.", 1.0, 0.82, 0.18, true)
        GameTooltip:Show()
    end)
    bindScript(button, "OnLeave", function()
        if GameTooltip then
            GameTooltip:Hide()
        end
    end)
end
