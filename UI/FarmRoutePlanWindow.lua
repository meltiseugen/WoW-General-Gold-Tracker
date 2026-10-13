local _, NS = ...
local GoldTracker = NS.GoldTracker
local Theme = NS.JanisTheme

local WINDOW_WIDTH = 1040
local WINDOW_HEIGHT = 650
local ROW_HEIGHT = 68
local ROW_GAP = 4

local function CreateButton(parent, width, height, text, paletteKey)
    return Theme:CreateButton(parent, width, height, text, paletteKey)
end

local function CreatePanel(parent, bg, border)
    return Theme:CreatePanel(parent, bg, border)
end

local function GetTargetSummary(entries)
    local names = {}
    for _, entry in ipairs(entries or {}) do
        names[#names + 1] = entry.itemName or ("Item " .. tostring(entry.itemID))
        if #names == 3 then
            break
        end
    end
    local remaining = math.max(0, #(entries or {}) - #names)
    return table.concat(names, ", ") .. (remaining > 0 and (" +" .. tostring(remaining) .. " more") or "")
end

local function GetInstruction(node)
    if node.confidence == "exact" then
        return "Navigate to the route entry, then complete this farm step."
    elseif node.confidence == "approximate" then
        return "Travel to this map. Exact arrival coordinates are unavailable."
    end
    return "Location unresolved. Open the farm details or position this step manually."
end

local function SetRowVisual(row, index, isCurrent, isComplete)
    if isComplete then
        row.background:SetColorTexture(0.20, 0.45, 0.32, 0.15)
    elseif isCurrent then
        row.background:SetColorTexture(0.24, 0.78, 0.48, 0.18)
    else
        row.background:SetColorTexture(1, 1, 1, index % 2 == 0 and 0.05 or 0.028)
    end
end

local function GetOrCreatePlanRow(frame, index)
    frame.rows = frame.rows or {}
    local row = frame.rows[index]
    if row then
        return row
    end
    row = CreateFrame("Frame", nil, frame.content)
    row:SetHeight(ROW_HEIGHT)
    row.background = row:CreateTexture(nil, "BACKGROUND")
    row.background:SetAllPoints(row)

    row.numberText = row:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    row.numberText:SetPoint("LEFT", row, "LEFT", 10, 0)
    row.numberText:SetWidth(28)
    row.numberText:SetJustifyH("CENTER")

    row.nameText = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    row.nameText:SetPoint("TOPLEFT", row, "TOPLEFT", 44, -8)
    row.nameText:SetPoint("RIGHT", row, "RIGHT", -490, 0)
    row.nameText:SetJustifyH("LEFT")
    row.nameText:SetWordWrap(false)

    row.locationText = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    row.locationText:SetPoint("TOPLEFT", row.nameText, "BOTTOMLEFT", 0, -4)
    row.locationText:SetPoint("RIGHT", row.nameText, "RIGHT", 0, 0)
    row.locationText:SetJustifyH("LEFT")
    row.locationText:SetWordWrap(false)

    row.targetText = row:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    row.targetText:SetPoint("TOPLEFT", row.locationText, "BOTTOMLEFT", 0, -3)
    row.targetText:SetPoint("RIGHT", row.nameText, "RIGHT", 0, 0)
    row.targetText:SetJustifyH("LEFT")
    row.targetText:SetWordWrap(false)

    row.completeButton = CreateButton(row, 70, 22, "Complete", "primary")
    row.completeButton:SetPoint("RIGHT", row, "RIGHT", -8, 0)
    row.completeButton:SetScript("OnClick", function(self)
        local parent = self:GetParent()
        GoldTracker:SetCustomFarmRoutePlanStepComplete(frame.selectedFarmID, parent.stepKey, not parent.isComplete)
    end)

    row.navigateButton = CreateButton(row, 72, 22, "Navigate", "primary")
    row.navigateButton:SetPoint("RIGHT", row.completeButton, "LEFT", -6, 0)
    row.navigateButton:SetScript("OnClick", function(self)
        local parent = self:GetParent()
        if GoldTracker:SetCustomFarmRoutePlanCurrentStep(frame.selectedFarmID, parent.stepKey) then
            GoldTracker:ActivateCustomFarmRoutePlanStep(frame.selectedFarmID, parent.stepKey)
        end
    end)

    row.mapDataButton = CreateButton(row, 74, 22, "Map data", "primary")
    row.mapDataButton:SetPoint("RIGHT", row.navigateButton, "LEFT", -6, 0)
    row.mapDataButton:SetScript("OnClick", function(self)
        local parent = self:GetParent()
        GoldTracker:OpenCustomFarmRoutePlanStepMap(frame.selectedFarmID, parent.stepKey)
    end)

    row.locationButton = CreateButton(row, 66, 22, "Location", "neutral")
    row.locationButton:SetPoint("RIGHT", row.mapDataButton, "LEFT", -6, 0)
    row.locationButton:SetScript("OnClick", function(self)
        GoldTracker:CycleCustomFarmRoutePlanLocation(frame.selectedFarmID, self:GetParent().stepKey)
    end)

    row.lockButton = CreateButton(row, 58, 22, "Lock", "neutral")
    row.lockButton:SetPoint("RIGHT", row.locationButton, "LEFT", -6, 0)
    row.lockButton:SetScript("OnClick", function(self)
        local parent = self:GetParent()
        GoldTracker:SetCustomFarmRoutePlanStepLocked(frame.selectedFarmID, parent.stepKey, not parent.isLocked)
    end)

    row.downButton = CreateButton(row, 48, 22, "Down", "neutral")
    row.downButton:SetPoint("RIGHT", row.lockButton, "LEFT", -6, 0)
    row.downButton:SetScript("OnClick", function(self)
        GoldTracker:MoveCustomFarmRoutePlanStep(frame.selectedFarmID, self:GetParent().stepKey, 1)
    end)

    row.upButton = CreateButton(row, 40, 22, "Up", "neutral")
    row.upButton:SetPoint("RIGHT", row.downButton, "LEFT", -6, 0)
    row.upButton:SetScript("OnClick", function(self)
        GoldTracker:MoveCustomFarmRoutePlanStep(frame.selectedFarmID, self:GetParent().stepKey, -1)
    end)

    frame.rows[index] = row
    return row
end

function GoldTracker:RefreshFarmRoutePlanWindow(recalculate)
    local frame = self.farmRoutePlanFrame
    if not frame or not frame.selectedFarmID then
        return
    end
    local farm = self:GetCustomFarmByID(frame.selectedFarmID)
    if not farm then
        frame:Hide()
        return
    end
    local plan = self:BuildCustomFarmRoutePlan(farm.id, recalculate == true)
    local run, character = self:GetCustomFarmRoutePlanRun(farm.id)
    run = run or { completed = {} }
    local completedCount = 0
    for _, node in ipairs(plan) do
        if run.completed[node.key] then
            completedCount = completedCount + 1
        end
    end

    frame.titleText:SetText("Route Plan — " .. farm.name)
    local runStatus = run.currentStepKey and "Active route"
        or (completedCount == #plan and #plan > 0 and "Plan complete")
        or (run.startedAt and "Stopped")
        or "Not started"
    frame.statusText:SetText(string.format(
        "%s | %d/%d complete%s",
        character or "Current character",
        completedCount,
        #plan,
        " | " .. runStatus
    ))
    frame.emptyText:SetShown(#plan == 0)
    local hasRemainingSteps = completedCount < #plan
    frame.navigateNextButton:SetEnabled(#plan > 0 and hasRemainingSteps)
    frame.navigateNextButton:SetText(hasRemainingSteps and "Navigate Next" or "Plan Complete")
    frame.skipButton:SetEnabled(run.currentStepKey ~= nil)
    frame.stopButton:SetEnabled(run.currentStepKey ~= nil)
    frame.resetButton:SetEnabled(completedCount > 0 or run.currentStepKey ~= nil)
    frame.startButton:SetText((run.currentStepKey or completedCount > 0) and "Restart" or "Start")
    if frame.overviewButton then
        local overview, overviewReason = self:BuildCustomFarmRoutePlanOverview(farm.id)
        frame.overviewButton:SetEnabled(overview ~= nil)
        frame.overviewButton.tooltipText = overview and "Show every planned stop on one numbered route map."
            or overviewReason
    end
    local contentWidth = frame.scrollFrame and (frame.scrollFrame:GetWidth() or 0) or 0
    frame.content:SetWidth(math.max(1, contentWidth - 2))
    local yOffset = 0
    for index, node in ipairs(plan) do
        local row = GetOrCreatePlanRow(frame, index)
        local isComplete = run.completed[node.key] == true
        local isCurrent = run.currentStepKey == node.key
        row.stepKey = node.key
        row.isComplete = isComplete
        row.isLocked = node.locked
        row.numberText:SetText(tostring(index))
        row.nameText:SetText((isCurrent and "|cff6ee7a8NEXT:|r " or "") .. (node.name or "Farm step"))
        row.locationText:SetText(string.format(
            "%s | %s%s",
            node.mapName or "Unknown location",
            node.confidenceLabel,
            #node.candidates > 1 and (" | " .. tostring(#node.candidates) .. " location choices") or ""
        ))
        if node.confidence == "exact" then
            row.locationText:SetTextColor(0.48, 0.92, 0.62)
        elseif node.confidence == "approximate" then
            row.locationText:SetTextColor(1.0, 0.78, 0.30)
        else
            row.locationText:SetTextColor(1.0, 0.42, 0.36)
        end
        row.targetText:SetText(GetTargetSummary(node.entries) .. " | " .. GetInstruction(node))
        row.completeButton:SetText(isComplete and "Undo" or "Complete")
        row.navigateButton:SetText(node.confidence == "exact" and "Navigate" or "Map")
        row.navigateButton:SetEnabled(node.mapID ~= nil or node.catalogFarmID ~= nil)
        row.mapDataButton:SetEnabled(node.mapID ~= nil or node.catalogFarmID ~= nil)
        row.locationButton:SetShown(#node.candidates > 1)
        row.lockButton:SetText(node.locked and "Unlock" or "Lock")
        if row.lockButton.SetSelected then
            row.lockButton:SetSelected(node.locked)
        end
        row.upButton:SetEnabled(index > 1)
        row.downButton:SetEnabled(index < #plan)
        SetRowVisual(row, index, isCurrent, isComplete)
        row:ClearAllPoints()
        row:SetPoint("TOPLEFT", frame.content, "TOPLEFT", 0, -yOffset)
        row:SetPoint("TOPRIGHT", frame.content, "TOPRIGHT", 0, -yOffset)
        row:Show()
        yOffset = yOffset + ROW_HEIGHT + ROW_GAP
    end
    for index = #plan + 1, #(frame.rows or {}) do
        frame.rows[index]:Hide()
    end
    frame.content:SetHeight(math.max(1, yOffset))
end

function GoldTracker:CreateFarmRoutePlanWindow()
    if self.farmRoutePlanFrame then
        return self.farmRoutePlanFrame
    end
    local addon = self
    local frame = CreateFrame("Frame", "GoldTrackerFarmRoutePlanFrame", UIParent, "BasicFrameTemplateWithInset")
    frame:SetSize(WINDOW_WIDTH, WINDOW_HEIGHT)
    frame:SetPoint("CENTER", UIParent, "CENTER", 0, 30)
    frame:SetFrameStrata("DIALOG")
    frame:SetClampedToScreen(true)
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
    frame:Hide()
    local chrome = Theme:ApplyWindowChrome(frame, "Route Plan")
    Theme:RegisterSpecialFrame("GoldTrackerFarmRoutePlanFrame")
    if type(Theme.CreateMaximizeButton) == "function" then
        Theme:CreateMaximizeButton(frame, {
            onToggle = function()
                addon:RefreshFarmRoutePlanWindow(false)
            end,
        })
    end

    local titleText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    titleText:SetPoint("TOPLEFT", chrome, "TOPLEFT", 18, -54)
    titleText:SetPoint("RIGHT", chrome, "RIGHT", -500, 0)
    titleText:SetJustifyH("LEFT")
    titleText:SetWordWrap(false)
    frame.titleText = titleText

    local recalculateButton = CreateButton(frame, 92, 24, "Recalculate", "neutral")
    recalculateButton:SetPoint("TOPRIGHT", chrome, "TOPRIGHT", -18, -50)
    recalculateButton:SetScript("OnClick", function()
        addon:RefreshFarmRoutePlanWindow(true)
    end)
    frame.recalculateButton = recalculateButton

    local resetButton = CreateButton(frame, 62, 24, "Reset", "neutral")
    resetButton:SetPoint("RIGHT", recalculateButton, "LEFT", -8, 0)
    resetButton:SetScript("OnClick", function()
        addon:ResetCustomFarmRoutePlanRun(frame.selectedFarmID)
    end)
    frame.resetButton = resetButton

    local startButton = CreateButton(frame, 70, 24, "Start", "primary")
    startButton:SetPoint("RIGHT", resetButton, "LEFT", -8, 0)
    startButton:SetScript("OnClick", function()
        addon:StartCustomFarmRoutePlan(frame.selectedFarmID)
    end)
    frame.startButton = startButton

    local stopButton = CreateButton(frame, 62, 24, "Stop", "neutral")
    stopButton:SetPoint("RIGHT", startButton, "LEFT", -8, 0)
    stopButton:SetScript("OnClick", function()
        addon:StopCustomFarmRoutePlan(frame.selectedFarmID)
    end)
    frame.stopButton = stopButton

    local statusText = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    statusText:SetPoint("TOPLEFT", titleText, "BOTTOMLEFT", 0, -6)
    statusText:SetPoint("RIGHT", stopButton, "LEFT", -10, 0)
    statusText:SetJustifyH("LEFT")
    statusText:SetTextColor(0.72, 0.86, 1.0)
    frame.statusText = statusText

    local hintText = frame:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    hintText:SetPoint("TOPLEFT", statusText, "BOTTOMLEFT", 0, -7)
    hintText:SetPoint("RIGHT", chrome, "RIGHT", -18, 0)
    hintText:SetJustifyH("LEFT")
    hintText:SetText("Suggested order groups locations conservatively. Lock important positions, use Up/Down for manual edits, and recalculate from your current location.")

    local listPanel = CreatePanel(frame, { 0.025, 0.03, 0.045, 0.94 }, { 1, 1, 1, 0.08 })
    listPanel:SetPoint("TOPLEFT", hintText, "BOTTOMLEFT", 0, -9)
    listPanel:SetPoint("BOTTOMRIGHT", chrome, "BOTTOMRIGHT", -18, 58)
    frame.listPanel = listPanel
    local scrollFrame = CreateFrame("ScrollFrame", nil, listPanel, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", listPanel, "TOPLEFT", 6, -6)
    scrollFrame:SetPoint("BOTTOMRIGHT", listPanel, "BOTTOMRIGHT", -28, 6)
    local content = CreateFrame("Frame", nil, scrollFrame)
    content:SetSize(1, 1)
    scrollFrame:SetScrollChild(content)
    frame.scrollFrame = scrollFrame
    frame.content = content
    local emptyText = content:CreateFontString(nil, "OVERLAY", "GameFontDisable")
    emptyText:SetPoint("TOPLEFT", content, "TOPLEFT", 10, -10)
    emptyText:SetText("This farm has no steps to plan yet.")
    frame.emptyText = emptyText

    local overviewButton = CreateButton(frame, 112, 24, "Overview Map", "primary")
    overviewButton:SetPoint("BOTTOMLEFT", chrome, "BOTTOMLEFT", 18, 20)
    overviewButton:SetScript("OnClick", function()
        addon:OpenCustomFarmRoutePlanOverview(frame.selectedFarmID)
    end)
    overviewButton:SetScript("OnEnter", function(self)
        if GameTooltip and self.tooltipText then
            GameTooltip:SetOwner(self, "ANCHOR_TOP")
            GameTooltip:SetText(self.tooltipText, 1.0, 0.82, 0.18)
            GameTooltip:Show()
        end
    end)
    overviewButton:SetScript("OnLeave", function()
        if GameTooltip then
            GameTooltip:Hide()
        end
    end)
    frame.overviewButton = overviewButton

    local skipButton = CreateButton(frame, 70, 24, "Skip", "neutral")
    skipButton:SetPoint("BOTTOMRIGHT", chrome, "BOTTOMRIGHT", -18, 20)
    skipButton:SetScript("OnClick", function()
        addon:SkipCustomFarmRoutePlanStep(frame.selectedFarmID)
    end)
    frame.skipButton = skipButton

    local navigateNextButton = CreateButton(frame, 108, 24, "Navigate Next", "primary")
    navigateNextButton:SetPoint("RIGHT", skipButton, "LEFT", -8, 0)
    navigateNextButton:SetScript("OnClick", function()
        local plan = addon:BuildCustomFarmRoutePlan(frame.selectedFarmID, false)
        local run = addon:GetCustomFarmRoutePlanRun(frame.selectedFarmID)
        if not run or not run.currentStepKey then
            addon:StartCustomFarmRoutePlan(frame.selectedFarmID)
            return
        end
        local stepKey = run and run.currentStepKey or (plan[1] and plan[1].key)
        if stepKey then
            addon:ActivateCustomFarmRoutePlanStep(frame.selectedFarmID, stepKey)
        end
    end)
    frame.navigateNextButton = navigateNextButton

    frame:SetScript("OnShow", function()
        addon:RefreshFarmRoutePlanWindow(false)
    end)
    self.farmRoutePlanFrame = frame
    return frame
end

function GoldTracker:OpenFarmRoutePlanWindow(farmID)
    local farm = self:GetCustomFarmByID(farmID)
    if not farm then
        return false
    end
    local frame = self:CreateFarmRoutePlanWindow()
    frame.selectedFarmID = farm.id
    frame:Show()
    if Theme and type(Theme.BringManagedWindowToFront) == "function" then
        Theme:BringManagedWindowToFront(frame)
    else
        frame:Raise()
    end
    self:RefreshFarmRoutePlanWindow(false)
    return true
end
