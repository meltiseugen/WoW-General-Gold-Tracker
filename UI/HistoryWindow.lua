local _, NS = ...
local GoldTracker = NS.GoldTracker
local HistoryConstants = NS.HistoryConstants
local HistoryDateFilter = NS.HistoryDateFilter
local HistorySessionModel = NS.HistorySessionModel
local HistoryFormatter = NS.HistoryFormatter
local HistoryDataService = NS.HistoryDataService

local RENAME_DIALOG_KEY = "GOLDTRACKER_RENAME_HISTORY_SESSION"
local SPLIT_DIALOG_KEY = "GOLDTRACKER_SPLIT_HISTORY_SESSION"
local ROW_HEIGHT = HistoryConstants.ROW_HEIGHT
local ROW_SPACING = HistoryConstants.ROW_SPACING
local DETAILS_LOCATION_FILTER_ALL = HistoryConstants.DETAILS_LOCATION_FILTER_ALL
local HISTORY_DATE_FILTER_ALL = HistoryConstants.DATE_FILTER_ALL
local HISTORY_DATE_FILTER_OPTIONS = HistoryConstants.DATE_FILTER_OPTIONS
local HISTORY_WINDOW_DEFAULT_HEIGHT = 500
local HISTORY_WINDOW_DETAILS_DEFAULT_HEIGHT = 620
local LOCATION_TABLE_MAX_VISIBLE_ROWS = 3
local DETAILS_GAP_LOCATION_TABLE_TO_FILTER = 10
local DETAILS_GAP_FILTER_TO_SUMMARY = 12
local DETAILS_GAP_SUMMARY_TO_ITEMS = 6
local DETAILS_ITEMS_ROW_SPACING = 2
local DETAILS_ITEMS_VALUE_WIDTH = 110
local DETAILS_ITEMS_SOURCE_WIDTH = 220

local historyDateFilter = HistoryDateFilter:New()
local historyFormatter = HistoryFormatter:New(GoldTracker)
local historyDataService = HistoryDataService:New(GoldTracker, DETAILS_LOCATION_FILTER_ALL)

local function NewHistorySessionModel(session)
    return HistorySessionModel:New(GoldTracker, session, DETAILS_LOCATION_FILTER_ALL)
end

local function SessionMatchesDateFilter(session, filterKey)
    return historyDateFilter:MatchesTimestamp(NewHistorySessionModel(session):GetReferenceTimestamp(), filterKey)
end

local function GetDialogEditBox(dialog)
    if not dialog then
        return nil
    end
    if dialog.GetEditBox and type(dialog.GetEditBox) == "function" then
        return dialog:GetEditBox()
    end
    return dialog.editBox or dialog.EditBox
end

local function EnsureRenameDialogRegistered()
    if StaticPopupDialogs[RENAME_DIALOG_KEY] then
        return
    end

    StaticPopupDialogs[RENAME_DIALOG_KEY] = {
        text = "Rename session",
        button1 = ACCEPT,
        button2 = CANCEL,
        hasEditBox = true,
        maxLetters = 120,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
        preferredIndex = 3,
        OnShow = function(dialog)
            local editBox = GetDialogEditBox(dialog)
            if not editBox then
                return
            end
            local session = GoldTracker:GetHistorySessionByID(dialog.data)
            if session then
                editBox:SetText(session.name or "")
                editBox:HighlightText()
            else
                editBox:SetText("")
            end
        end,
        OnAccept = function(dialog)
            local editBox = GetDialogEditBox(dialog)
            if not editBox then
                return
            end
            GoldTracker:RenameHistorySession(dialog.data, editBox:GetText())
        end,
        EditBoxOnEnterPressed = function(editBox)
            local dialog = editBox:GetParent()
            if dialog and dialog.button1 then
                dialog.button1:Click()
            end
        end,
        EditBoxOnEscapePressed = function(editBox)
            editBox:GetParent():Hide()
        end,
    }
end

local function FormatSessionSummary(addon, session)
    return historyFormatter:FormatSessionSummary(session)
end

local function FormatSessionTotal(addon, session)
    return historyFormatter:FormatSessionTotal(session)
end

local function FormatSessionTotalRaw(addon, session)
    return historyFormatter:FormatSessionTotalRaw(session)
end

local function FormatSessionDuration(session)
    local model = NewHistorySessionModel(session)
    return model:FormatDurationMinutesLabel(model:GetDurationSeconds(session))
end

local function TruncateSessionNameKeepingDate(addon, fullName, nameFontString)
    return historyFormatter:TruncateSessionNameKeepingDate(fullName, nameFontString)
end

local function EnsureSplitDialogRegistered()
    if StaticPopupDialogs[SPLIT_DIALOG_KEY] then
        return
    end

    StaticPopupDialogs[SPLIT_DIALOG_KEY] = {
        text = "Split this session into separate rows per location?\nThis action cannot be undone.",
        button1 = ACCEPT,
        button2 = CANCEL,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
        preferredIndex = 3,
        OnAccept = function(dialog)
            local splitEntries, reason = GoldTracker:SplitHistorySessionByLocation(dialog.data)
            if splitEntries and #splitEntries > 0 then
                GoldTracker:Print(string.format("Split session into %d location rows.", #splitEntries))
            elseif reason == "single-location" then
                GoldTracker:Print("Session has only one location; nothing to split.")
            else
                GoldTracker:Print("Unable to split this session.")
            end
        end,
    }
end

local function BuildHistoryLocationOptions(session)
    return NewHistorySessionModel(session):BuildHistoryLocationOptions(session)
end

local function BuildLocationDetailsRowsForSelection(session, selectedLocationKey)
    return NewHistorySessionModel(session):BuildLocationDetailsRowsForSelection(selectedLocationKey, session)
end

local function BuildHistoryRowTitleAndSubtitle(session)
    return NewHistorySessionModel(session):BuildRowTitleAndSubtitle(session)
end

local function BuildHistoryDetailsSummary(session, selectedLocationKey)
    return historyDataService:BuildHistoryDetailsSummary(session, selectedLocationKey)
end

local function BuildVisibleHistoryItems(session, selectedLocationKey)
    return historyDataService:BuildVisibleHistoryItems(session, selectedLocationKey)
end

local function EscapeCSVValue(value)
    local text = tostring(value or "")
    text = text:gsub("\r", " "):gsub("\n", " ")
    if text:find('[",]') then
        text = '"' .. text:gsub('"', '""') .. '"'
    end
    return text
end

local function CompareHistorySessionsByRecency(a, b)
    return historyDataService:CompareHistorySessionsByRecency(a, b)
end

local function GetHistorySortValue(session, sortKey)
    return historyDataService:GetHistorySortValue(session, sortKey)
end

function GoldTracker:PromptRenameHistorySession(sessionID)
    EnsureRenameDialogRegistered()
    StaticPopup_Show(RENAME_DIALOG_KEY, nil, nil, sessionID)
end

function GoldTracker:PromptSplitHistorySession(sessionID)
    local session = self:GetHistorySessionByID(sessionID)
    if not session then
        return
    end

    local locationOptions = BuildHistoryLocationOptions(session)
    if #locationOptions <= 2 then
        self:Print("Session has only one location; nothing to split.")
        return
    end

    EnsureSplitDialogRegistered()
    StaticPopup_Show(SPLIT_DIALOG_KEY, nil, nil, sessionID)
end

function GoldTracker:HandleHistoryPageMouseWheel(delta)
    if not self.historyFrame or self.historyFrame.view ~= "list" then
        return
    end

    local scrollFrame = self.historyFrame.scrollFrame
    if not scrollFrame then
        return
    end

    local maxScroll = tonumber(scrollFrame:GetVerticalScrollRange()) or 0
    if maxScroll <= 0 then
        return
    end

    local currentScroll = tonumber(scrollFrame:GetVerticalScroll()) or 0
    local step = math.max(24, math.floor((ROW_HEIGHT or 40) * 0.8))
    local nextScroll = currentScroll - ((tonumber(delta) or 0) * step)
    if nextScroll < 0 then
        nextScroll = 0
    elseif nextScroll > maxScroll then
        nextScroll = maxScroll
    end
    scrollFrame:SetVerticalScroll(nextScroll)
end

function GoldTracker:CreateHistoryWindow()
    if self.historyFrame then
        return
    end

    local addon = self
    local frame = CreateFrame("Frame", "GoldTrackerHistoryFrame", UIParent, "BasicFrameTemplateWithInset")
    frame:SetSize(900, HISTORY_WINDOW_DEFAULT_HEIGHT)
    frame:SetPoint("CENTER")
    frame:SetFrameStrata("DIALOG")
    if frame.SetToplevel then
        frame:SetToplevel(true)
    end
    frame:SetMovable(true)
    frame:SetClampedToScreen(true)
    frame:EnableMouse(true)
    frame:EnableMouseWheel(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnMouseDown", function(self)
        self:Raise()
    end)
    frame:SetScript("OnDragStart", function(self)
        self:Raise()
        self:StartMoving()
    end)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
    frame:SetScript("OnMouseWheel", function(_, delta)
        if frame.view == "list" then
            addon:HandleHistoryPageMouseWheel(delta)
        end
    end)
    frame:Hide()

    if frame.TitleText then
        frame.TitleText:SetText("General Gold Tracker - Session History")
    end
    if frame.CloseButton then
        frame.CloseButton:SetFrameLevel(frame:GetFrameLevel() + 20)
        frame.CloseButton:SetScript("OnClick", function()
            frame:Hide()
        end)
    end
    if type(UISpecialFrames) == "table" then
        local alreadyRegistered = false
        for _, frameName in ipairs(UISpecialFrames) do
            if frameName == "GoldTrackerHistoryFrame" then
                alreadyRegistered = true
                break
            end
        end
        if not alreadyRegistered then
            table.insert(UISpecialFrames, "GoldTrackerHistoryFrame")
        end
    end

    local backButton = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    backButton:SetSize(80, 22)
    backButton:SetPoint("TOPLEFT", frame, "TOPLEFT", 18, -34)
    backButton:SetText("Back")
    backButton:SetScript("OnClick", function()
        addon:ShowHistoryListView()
    end)
    backButton:Hide()
    frame.backButton = backButton

    local listContainer = CreateFrame("Frame", nil, frame)
    listContainer:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, -24)
    listContainer:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 0, 0)
    listContainer:EnableMouseWheel(true)
    listContainer:SetScript("OnMouseWheel", function(_, delta)
        addon:HandleHistoryPageMouseWheel(delta)
    end)
    frame.listContainer = listContainer
    frame.selectedSessionIDs = {}
    frame.currentPage = 1
    frame.sortKey = frame.sortKey or nil
    frame.sortAscending = frame.sortAscending == true
    frame.historyDateFilterKey = frame.historyDateFilterKey or HISTORY_DATE_FILTER_ALL

    local mergeButton = CreateFrame("Button", nil, listContainer, "UIPanelButtonTemplate")
    mergeButton:SetSize(120, 22)
    mergeButton:SetPoint("TOPRIGHT", listContainer, "TOPRIGHT", -154, -8)
    mergeButton:SetText("Merge")
    mergeButton:SetScript("OnClick", function()
        local selectedIDs = addon:GetSelectedHistorySessionIDsInOrder()
        if #selectedIDs < 2 then
            return
        end

        local merged = addon:MergeHistorySessions(selectedIDs)
        if merged then
            addon:ClearHistorySelection()
            addon:RefreshHistoryWindow()
            addon:Print(string.format("Merged %d sessions into \"%s\".", #selectedIDs, merged.name or "Session"))
        end
    end)
    mergeButton:Hide()
    frame.mergeButton = mergeButton

    local bulkDeleteButton = CreateFrame("Button", nil, listContainer, "UIPanelButtonTemplate")
    bulkDeleteButton:SetSize(120, 22)
    bulkDeleteButton:SetPoint("LEFT", mergeButton, "RIGHT", 8, 0)
    bulkDeleteButton:SetText("Bulk Delete")
    bulkDeleteButton:SetScript("OnClick", function()
        local selectedIDs = addon:GetSelectedHistorySessionIDsInOrder()
        if #selectedIDs == 0 then
            return
        end

        local removedCount = addon:DeleteHistorySessions(selectedIDs)
        if removedCount > 0 then
            addon:ClearHistorySelection()
            addon:RefreshHistoryWindow()
            addon:Print(string.format("Deleted %d history sessions.", removedCount))
        end
    end)
    bulkDeleteButton:Hide()
    frame.bulkDeleteButton = bulkDeleteButton

    local historyDateFilterLabel = listContainer:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    historyDateFilterLabel:SetPoint("TOPLEFT", listContainer, "TOPLEFT", 24, -14)
    historyDateFilterLabel:SetText("Filter")
    frame.historyDateFilterLabelText = historyDateFilterLabel

    local historyDateFilterDropdown = CreateFrame("Frame", "GoldTrackerHistoryDateFilterDropdown", listContainer, "UIDropDownMenuTemplate")
    historyDateFilterDropdown:SetPoint("LEFT", historyDateFilterLabel, "RIGHT", -6, -2)
    UIDropDownMenu_SetWidth(historyDateFilterDropdown, 150)
    UIDropDownMenu_Initialize(historyDateFilterDropdown, function(_, level)
        for _, option in ipairs(HISTORY_DATE_FILTER_OPTIONS) do
            local info = UIDropDownMenu_CreateInfo()
            local optionKey = option.key
            info.text = option.label
            info.value = optionKey
            info.checked = (frame.historyDateFilterKey or HISTORY_DATE_FILTER_ALL) == optionKey
            info.func = function()
                frame.historyDateFilterKey = optionKey
                frame.currentPage = 1
                addon:ClearHistorySelection()
                addon:RefreshHistoryWindow()
            end
            UIDropDownMenu_AddButton(info, level)
        end
    end)
    frame.historyDateFilterDropdown = historyDateFilterDropdown

    local hint = listContainer:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    hint:SetPoint("TOPLEFT", listContainer, "TOPLEFT", 20, -40)
    hint:SetText("Click a row for details. Use row checkboxes (or the header checkbox) for Merge/Bulk Delete, Pin to keep sessions on top, and Filter to limit by date.")
    frame.listHintText = hint

    local header = listContainer:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    header:SetPoint("TOPLEFT", listContainer, "TOPLEFT", 36, -56)
    header:SetText("Session name")
    frame.listHeaderText = header

    local selectPageCheckbox = CreateFrame("CheckButton", nil, listContainer, "UICheckButtonTemplate")
    selectPageCheckbox:SetSize(22, 22)
    selectPageCheckbox:SetPoint("TOPLEFT", listContainer, "TOPLEFT", 8, -53)
    selectPageCheckbox:SetChecked(false)
    selectPageCheckbox:SetScript("OnClick", function(button)
        addon:SetHistoryCurrentPageSelection(button:GetChecked() == true)
    end)
    frame.selectPageCheckbox = selectPageCheckbox

    local summaryHeader = listContainer:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    summaryHeader:SetPoint("TOPLEFT", listContainer, "TOPLEFT", 302, -56)
    summaryHeader:SetText("Highlights")
    frame.listSummaryHeaderText = summaryHeader

    local totalHeaderButton = CreateFrame("Button", nil, listContainer)
    totalHeaderButton:SetSize(104, 18)
    totalHeaderButton:SetPoint("TOPLEFT", listContainer, "TOPLEFT", 370, -56)
    totalHeaderButton:SetScript("OnClick", function()
        addon:ToggleHistorySort("sessionTotal")
    end)
    local totalHeaderText = totalHeaderButton:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    totalHeaderText:SetPoint("TOPLEFT", totalHeaderButton, "TOPLEFT", 0, 0)
    totalHeaderText:SetWidth(104)
    totalHeaderText:SetJustifyH("LEFT")
    totalHeaderText:SetText("Session Total")
    totalHeaderButton.text = totalHeaderText
    frame.totalHeaderButton = totalHeaderButton

    local totalRawHeaderButton = CreateFrame("Button", nil, listContainer)
    totalRawHeaderButton:SetSize(106, 18)
    totalRawHeaderButton:SetPoint("TOPLEFT", listContainer, "TOPLEFT", 482, -56)
    totalRawHeaderButton:SetScript("OnClick", function()
        addon:ToggleHistorySort("sessionTotalRaw")
    end)
    local totalRawHeaderText = totalRawHeaderButton:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    totalRawHeaderText:SetPoint("TOPLEFT", totalRawHeaderButton, "TOPLEFT", 0, 0)
    totalRawHeaderText:SetWidth(106)
    totalRawHeaderText:SetJustifyH("LEFT")
    totalRawHeaderText:SetText("Raw Total")
    totalRawHeaderButton.text = totalRawHeaderText
    frame.totalRawHeaderButton = totalRawHeaderButton

    local durationHeaderButton = CreateFrame("Button", nil, listContainer)
    durationHeaderButton:SetSize(64, 18)
    durationHeaderButton:SetPoint("TOPLEFT", listContainer, "TOPLEFT", 596, -56)
    durationHeaderButton:SetScript("OnClick", function()
        addon:ToggleHistorySort("duration")
    end)
    local durationHeaderText = durationHeaderButton:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    durationHeaderText:SetPoint("TOPLEFT", durationHeaderButton, "TOPLEFT", 0, 0)
    durationHeaderText:SetWidth(64)
    durationHeaderText:SetJustifyH("LEFT")
    durationHeaderText:SetText("Duration")
    durationHeaderButton.text = durationHeaderText
    frame.durationHeaderButton = durationHeaderButton

    local dividerColorR, dividerColorG, dividerColorB, dividerColorA = 1, 0.82, 0, 0.60
    local function CreateHeaderDivider(x)
        local divider = listContainer:CreateTexture(nil, "ARTWORK")
        divider:SetColorTexture(dividerColorR, dividerColorG, dividerColorB, dividerColorA)
        divider:SetSize(1, 18)
        divider:SetPoint("TOPLEFT", listContainer, "TOPLEFT", x, -55)
        return divider
    end

    frame.headerDividerNameSummary = CreateHeaderDivider(294)
    frame.headerDividerSummaryTotal = CreateHeaderDivider(364)
    frame.headerDividerTotalRaw = CreateHeaderDivider(476)
    frame.headerDividerRawDuration = CreateHeaderDivider(590)

    local headerUnderline = listContainer:CreateTexture(nil, "ARTWORK")
    headerUnderline:SetColorTexture(1, 0.82, 0, 0.35)
    headerUnderline:SetPoint("TOPLEFT", listContainer, "TOPLEFT", 24, -72)
    headerUnderline:SetPoint("TOPRIGHT", listContainer, "TOPRIGHT", -42, -72)
    headerUnderline:SetHeight(1)
    frame.headerUnderline = headerUnderline

    local scrollFrame = CreateFrame("ScrollFrame", "GoldTrackerHistoryScrollFrame", listContainer, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", listContainer, "TOPLEFT", 0, -72)
    scrollFrame:SetPoint("BOTTOMRIGHT", listContainer, "BOTTOMRIGHT", -30, 50)
    scrollFrame:EnableMouseWheel(true)
    scrollFrame:SetScript("OnMouseWheel", function(_, delta)
        addon:HandleHistoryPageMouseWheel(delta)
    end)
    frame.scrollFrame = scrollFrame

    local content = CreateFrame("Frame", nil, scrollFrame)
    content:SetSize(1, 1)
    scrollFrame:SetScrollChild(content)
    content:EnableMouseWheel(true)
    content:SetScript("OnMouseWheel", function(_, delta)
        addon:HandleHistoryPageMouseWheel(delta)
    end)
    frame.content = content
    frame.rows = {}
    frame.visibleSessionIDs = {}

    local emptyText = content:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    emptyText:SetPoint("TOPLEFT", content, "TOPLEFT", 8, -8)
    emptyText:SetText("No saved sessions.")
    frame.emptyText = emptyText

    local pinnedDivider = content:CreateTexture(nil, "ARTWORK")
    pinnedDivider:SetColorTexture(1, 0.82, 0, 0.35)
    pinnedDivider:SetHeight(1)
    pinnedDivider:Hide()
    frame.pinnedDivider = pinnedDivider

    local prevPageButton = CreateFrame("Button", nil, listContainer, "UIPanelButtonTemplate")
    prevPageButton:SetSize(34, 20)
    prevPageButton:SetPoint("BOTTOMLEFT", listContainer, "BOTTOMLEFT", 20, 20)
    prevPageButton:SetText("<")
    prevPageButton:SetScript("OnClick", function()
        addon:SetHistoryPage((frame.currentPage or 1) - 1)
    end)
    frame.prevPageButton = prevPageButton

    local nextPageButton = CreateFrame("Button", nil, listContainer, "UIPanelButtonTemplate")
    nextPageButton:SetSize(34, 20)
    nextPageButton:SetPoint("LEFT", prevPageButton, "RIGHT", 6, 0)
    nextPageButton:SetText(">")
    nextPageButton:SetScript("OnClick", function()
        addon:SetHistoryPage((frame.currentPage or 1) + 1)
    end)
    frame.nextPageButton = nextPageButton

    local pageText = listContainer:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    pageText:SetPoint("LEFT", nextPageButton, "RIGHT", 10, 0)
    pageText:SetJustifyH("LEFT")
    pageText:SetText("Page 1 / 1")
    frame.pageText = pageText

    local detailsContainer = CreateFrame("Frame", nil, frame)
    detailsContainer:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, -24)
    detailsContainer:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 0, 0)
    detailsContainer:Hide()
    frame.detailsContainer = detailsContainer

    local sessionName = detailsContainer:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    sessionName:SetPoint("TOPLEFT", detailsContainer, "TOPLEFT", 20, -62)
    sessionName:SetWidth(850)
    sessionName:SetJustifyH("LEFT")
    frame.sessionNameText = sessionName

    local locationTableFrame = CreateFrame("Frame", nil, detailsContainer)
    locationTableFrame:SetPoint("TOPLEFT", sessionName, "BOTTOMLEFT", 0, -6)
    locationTableFrame:SetPoint("RIGHT", detailsContainer, "RIGHT", -20, 0)
    locationTableFrame:SetHeight(20)
    locationTableFrame:Hide()
    frame.locationTableFrame = locationTableFrame

    local locationColumnHeader = locationTableFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    locationColumnHeader:SetPoint("TOPLEFT", locationTableFrame, "TOPLEFT", 0, 0)
    locationColumnHeader:SetWidth(470)
    locationColumnHeader:SetJustifyH("LEFT")
    if locationColumnHeader.SetWordWrap then
        locationColumnHeader:SetWordWrap(false)
    end
    locationColumnHeader:SetText("Location")
    frame.locationHeaderText = locationColumnHeader

    local timeFrameColumnHeader = locationTableFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    timeFrameColumnHeader:SetPoint("TOPLEFT", locationTableFrame, "TOPLEFT", 476, 0)
    timeFrameColumnHeader:SetWidth(210)
    timeFrameColumnHeader:SetJustifyH("LEFT")
    if timeFrameColumnHeader.SetWordWrap then
        timeFrameColumnHeader:SetWordWrap(false)
    end
    timeFrameColumnHeader:SetText("Time frame")
    frame.timeFrameHeaderText = timeFrameColumnHeader

    local highlightsColumnHeader = locationTableFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    highlightsColumnHeader:SetPoint("TOPLEFT", locationTableFrame, "TOPLEFT", 692, 0)
    highlightsColumnHeader:SetWidth(80)
    highlightsColumnHeader:SetJustifyH("LEFT")
    if highlightsColumnHeader.SetWordWrap then
        highlightsColumnHeader:SetWordWrap(false)
    end
    highlightsColumnHeader:SetText("Highlights")
    frame.highlightsHeaderText = highlightsColumnHeader

    local durationColumnHeader = locationTableFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    durationColumnHeader:SetPoint("TOPLEFT", locationTableFrame, "TOPLEFT", 776, 0)
    durationColumnHeader:SetWidth(56)
    durationColumnHeader:SetJustifyH("LEFT")
    if durationColumnHeader.SetWordWrap then
        durationColumnHeader:SetWordWrap(false)
    end
    durationColumnHeader:SetText("Duration")
    frame.durationHeaderText = durationColumnHeader

    local tableUnderline = locationTableFrame:CreateTexture(nil, "ARTWORK")
    tableUnderline:SetColorTexture(1, 0.82, 0, 0.28)
    tableUnderline:SetPoint("TOPLEFT", locationTableFrame, "TOPLEFT", 0, -16)
    tableUnderline:SetPoint("TOPRIGHT", locationTableFrame, "TOPRIGHT", 0, -16)
    tableUnderline:SetHeight(1)
    frame.locationTableUnderline = tableUnderline

    local locationTableScrollFrame = CreateFrame("ScrollFrame", nil, locationTableFrame, "UIPanelScrollFrameTemplate")
    locationTableScrollFrame:SetPoint("TOPLEFT", locationTableFrame, "TOPLEFT", 0, -19)
    locationTableScrollFrame:SetPoint("TOPRIGHT", locationTableFrame, "TOPRIGHT", -27, -19)
    locationTableScrollFrame:SetHeight(1)
    locationTableScrollFrame:EnableMouseWheel(true)
    locationTableScrollFrame:SetScript("OnMouseWheel", function(self, delta)
        local step = 24
        local nextScroll = self:GetVerticalScroll() - (delta * step)
        local maxScroll = self:GetVerticalScrollRange()
        if nextScroll < 0 then
            nextScroll = 0
        elseif nextScroll > maxScroll then
            nextScroll = maxScroll
        end
        self:SetVerticalScroll(nextScroll)
    end)
    frame.locationTableScrollFrame = locationTableScrollFrame

    local locationTableContent = CreateFrame("Frame", nil, locationTableScrollFrame)
    locationTableContent:SetSize(1, 1)
    locationTableContent:SetPoint("TOPLEFT", locationTableScrollFrame, "TOPLEFT", 0, 0)
    locationTableScrollFrame:SetScrollChild(locationTableContent)
    frame.locationTableContent = locationTableContent

    frame.locationTableRows = {}
    frame.locationText = nil
    frame.timeFrameText = nil
    frame.locationDurationText = nil

    local summaryTableFrame = CreateFrame("Frame", nil, detailsContainer)
    summaryTableFrame:SetPoint("TOPLEFT", locationTableFrame, "BOTTOMLEFT", 0, -(DETAILS_GAP_LOCATION_TABLE_TO_FILTER + DETAILS_GAP_FILTER_TO_SUMMARY))
    summaryTableFrame:SetPoint("RIGHT", detailsContainer, "RIGHT", -20, 0)
    summaryTableFrame:SetHeight(16)
    summaryTableFrame:Hide()
    frame.summaryTableFrame = summaryTableFrame
    frame.summaryRows = {}
    frame.summaryText = nil
    frame.sourceText = nil

    local locationFilterLabel = detailsContainer:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    locationFilterLabel:SetPoint("TOPLEFT", locationTableFrame, "BOTTOMLEFT", 0, -DETAILS_GAP_LOCATION_TABLE_TO_FILTER)
    locationFilterLabel:SetText("Location")
    frame.locationFilterLabelText = locationFilterLabel

    local locationFilterDropdown = CreateFrame("Frame", "GoldTrackerHistoryLocationFilterDropdown", detailsContainer, "UIDropDownMenuTemplate")
    locationFilterDropdown:SetPoint("LEFT", locationFilterLabel, "RIGHT", -6, -1)
    UIDropDownMenu_SetWidth(locationFilterDropdown, 280)
    UIDropDownMenu_Initialize(locationFilterDropdown, function(_, level)
        for _, option in ipairs(frame.detailsLocationOptions or {}) do
            local info = UIDropDownMenu_CreateInfo()
            local optionKey = option.key
            info.text = option.label
            info.value = optionKey
            info.checked = (frame.detailsLocationFilterKey or DETAILS_LOCATION_FILTER_ALL) == optionKey
            info.func = function()
                frame.detailsLocationFilterKey = optionKey
                addon:RefreshHistoryDetailsWindow()
            end
            UIDropDownMenu_AddButton(info, level)
        end
    end)
    frame.locationFilterDropdown = locationFilterDropdown
    frame.detailsLocationOptions = {
        { key = DETAILS_LOCATION_FILTER_ALL, label = "All" },
    }
    frame.detailsLocationFilterKey = DETAILS_LOCATION_FILTER_ALL

    local splitButton = CreateFrame("Button", nil, detailsContainer, "UIPanelButtonTemplate")
    splitButton:SetSize(130, 22)
    splitButton:SetPoint("LEFT", locationFilterDropdown, "RIGHT", 12, 2)
    splitButton:SetText("Split by Location")
    splitButton:SetScript("OnClick", function()
        if frame.selectedSessionID then
            addon:PromptSplitHistorySession(frame.selectedSessionID)
        end
    end)
    splitButton:Hide()
    frame.splitButton = splitButton

    local exportButton = CreateFrame("Button", nil, detailsContainer, "UIPanelButtonTemplate")
    exportButton:SetSize(96, 22)
    exportButton:SetPoint("LEFT", splitButton, "RIGHT", 8, 0)
    exportButton:SetText("Export CSV")
    exportButton:SetScript("OnClick", function()
        if frame.selectedSessionID then
            addon:OpenHistorySessionExport(frame.selectedSessionID)
        end
    end)
    frame.exportButton = exportButton

    local breakdownButton = CreateFrame("Button", nil, detailsContainer, "UIPanelButtonTemplate")
    breakdownButton:SetSize(122, 22)
    breakdownButton:SetPoint("LEFT", exportButton, "RIGHT", 8, 0)
    breakdownButton:SetText("Loot Breakdown")
    breakdownButton:SetScript("OnClick", function()
        if frame.selectedSessionID then
            addon:OpenHistoryLootBreakdownWindow(frame.selectedSessionID)
        end
    end)
    frame.breakdownButton = breakdownButton

    local resumeSessionButton = CreateFrame("Button", nil, detailsContainer, "UIPanelButtonTemplate")
    resumeSessionButton:SetSize(132, 22)
    resumeSessionButton:SetPoint("LEFT", breakdownButton, "RIGHT", 8, 0)
    resumeSessionButton:SetText("Resume Session")
    resumeSessionButton:SetScript("OnClick", function()
        if frame.selectedSessionID then
            addon:ResumeHistorySession(frame.selectedSessionID)
        end
    end)
    frame.resumeSessionButton = resumeSessionButton

    local itemsHeader = detailsContainer:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    itemsHeader:SetPoint("TOPLEFT", summaryTableFrame, "BOTTOMLEFT", 0, -DETAILS_GAP_SUMMARY_TO_ITEMS)
    itemsHeader:SetText("Items")
    frame.itemsHeaderText = itemsHeader

    local itemsItemHeader = detailsContainer:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    itemsItemHeader:SetPoint("TOPLEFT", itemsHeader, "BOTTOMLEFT", 0, -4)
    itemsItemHeader:SetText("Item")
    frame.itemsItemHeaderText = itemsItemHeader

    local itemsSourceHeader = detailsContainer:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    itemsSourceHeader:SetPoint("TOP", itemsItemHeader, "TOP", 0, 0)
    itemsSourceHeader:SetPoint("RIGHT", detailsContainer, "RIGHT", -20, 0)
    itemsSourceHeader:SetWidth(DETAILS_ITEMS_SOURCE_WIDTH)
    itemsSourceHeader:SetJustifyH("LEFT")
    itemsSourceHeader:SetText("From")
    frame.itemsSourceHeaderText = itemsSourceHeader

    local itemsValueHeader = detailsContainer:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    itemsValueHeader:SetPoint("RIGHT", itemsSourceHeader, "LEFT", -12, 0)
    itemsValueHeader:SetWidth(DETAILS_ITEMS_VALUE_WIDTH)
    itemsValueHeader:SetJustifyH("RIGHT")
    itemsValueHeader:SetText("Value")
    frame.itemsValueHeaderText = itemsValueHeader

    local itemsUnderline = detailsContainer:CreateTexture(nil, "ARTWORK")
    itemsUnderline:SetColorTexture(1, 0.82, 0, 0.35)
    itemsUnderline:SetPoint("TOPLEFT", itemsItemHeader, "BOTTOMLEFT", 0, -4)
    itemsUnderline:SetPoint("TOPRIGHT", itemsSourceHeader, "BOTTOMRIGHT", 0, -4)
    itemsUnderline:SetHeight(1)
    frame.itemsHeaderUnderline = itemsUnderline

    local itemsScrollFrame = CreateFrame("ScrollFrame", nil, detailsContainer, "UIPanelScrollFrameTemplate")
    itemsScrollFrame:SetPoint("TOPLEFT", itemsItemHeader, "BOTTOMLEFT", 0, -8)
    itemsScrollFrame:SetPoint("BOTTOMRIGHT", detailsContainer, "BOTTOMRIGHT", -30, 20)
    itemsScrollFrame:EnableMouseWheel(true)
    itemsScrollFrame:SetScript("OnMouseWheel", function(self, delta)
        local step = math.max(18, math.floor(self:GetHeight() * 0.12))
        local nextScroll = (tonumber(self:GetVerticalScroll()) or 0) - ((tonumber(delta) or 0) * step)
        local maxScroll = tonumber(self:GetVerticalScrollRange()) or 0
        if nextScroll < 0 then
            nextScroll = 0
        elseif nextScroll > maxScroll then
            nextScroll = maxScroll
        end
        self:SetVerticalScroll(nextScroll)
    end)
    frame.detailsItemsScrollFrame = itemsScrollFrame

    local itemsContent = CreateFrame("Frame", nil, itemsScrollFrame)
    itemsContent:SetSize(1, 1)
    itemsScrollFrame:SetScrollChild(itemsContent)
    frame.detailsItemsContent = itemsContent
    frame.detailsItemRows = {}

    local itemsEmptyText = itemsContent:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    itemsEmptyText:SetPoint("TOPLEFT", itemsContent, "TOPLEFT", 4, -4)
    itemsEmptyText:SetPoint("TOPRIGHT", itemsContent, "TOPRIGHT", -4, -4)
    itemsEmptyText:SetJustifyH("LEFT")
    itemsEmptyText:SetText("No tradable items matched the current quality filter.")
    itemsEmptyText:Hide()
    frame.detailsItemsEmptyText = itemsEmptyText

    frame:SetScript("OnShow", function()
        if frame.view == "details" then
            addon:RefreshHistoryDetailsWindow()
        else
            addon:RefreshHistoryWindow()
        end
    end)

    self.historyFrame = frame
    self:ApplyHistoryDetailsFontSize()
    self:ShowHistoryListView()
end

function GoldTracker:GetHistoryRow(index)
    local frame = self.historyFrame
    local row = frame.rows[index]
    if row then
        return row
    end

    row = CreateFrame("Button", nil, frame.content)
    row:SetHeight(ROW_HEIGHT)
    row:SetPoint("TOPLEFT", frame.content, "TOPLEFT", 0, -((index - 1) * ROW_SPACING))
    row:SetNormalFontObject(GameFontHighlight)
    row:EnableMouseWheel(true)
    row:SetScript("OnMouseWheel", function(_, delta)
        self:HandleHistoryPageMouseWheel(delta)
    end)

    local bg = row:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints(true)
    bg:SetColorTexture(0, 0, 0, 0.18)
    row.bg = bg

    local hl = row:CreateTexture(nil, "HIGHLIGHT")
    hl:SetAllPoints(true)
    hl:SetColorTexture(1, 1, 1, 0.08)

    local selectCheckbox = CreateFrame("CheckButton", nil, row, "UICheckButtonTemplate")
    selectCheckbox:SetSize(22, 22)
    selectCheckbox:SetPoint("LEFT", row, "LEFT", 10, 0)
    row.selectCheckbox = selectCheckbox

    local nameText = row:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    nameText:SetPoint("TOPLEFT", selectCheckbox, "TOPRIGHT", 0, -2)
    nameText:SetWidth(260)
    nameText:SetJustifyH("LEFT")
    row.nameText = nameText

    local subtitleText = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    subtitleText:SetPoint("TOPLEFT", nameText, "BOTTOMLEFT", 0, -2)
    subtitleText:SetWidth(260)
    subtitleText:SetJustifyH("LEFT")
    subtitleText:SetTextColor(0.78, 0.78, 0.78)
    subtitleText:SetText("")
    subtitleText:Hide()
    row.subtitleText = subtitleText

    local pinButton = CreateFrame("Button", nil, row, "UIPanelButtonTemplate")
    pinButton:SetSize(52, 20)
    pinButton:SetPoint("RIGHT", row, "RIGHT", -126, 0)
    pinButton:SetText("Pin")
    row.pinButton = pinButton

    local renameButton = CreateFrame("Button", nil, row, "UIPanelButtonTemplate")
    renameButton:SetSize(62, 20)
    renameButton:SetPoint("RIGHT", row, "RIGHT", -64, 0)
    renameButton:SetText("Rename")
    row.renameButton = renameButton

    local deleteButton = CreateFrame("Button", nil, row, "UIPanelButtonTemplate")
    deleteButton:SetSize(56, 20)
    deleteButton:SetPoint("RIGHT", row, "RIGHT", -4, 0)
    deleteButton:SetText("Delete")
    row.deleteButton = deleteButton

    local summaryText = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    summaryText:SetPoint("LEFT", row, "LEFT", 302, 0)
    summaryText:SetWidth(60)
    summaryText:SetJustifyH("LEFT")
    row.summaryText = summaryText

    local totalText = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    totalText:SetPoint("LEFT", row, "LEFT", 370, 0)
    totalText:SetPoint("RIGHT", row, "LEFT", 474, 0)
    totalText:SetJustifyH("LEFT")
    row.totalText = totalText

    local totalRawText = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    totalRawText:SetPoint("LEFT", row, "LEFT", 482, 0)
    totalRawText:SetPoint("RIGHT", row, "LEFT", 588, 0)
    totalRawText:SetJustifyH("LEFT")
    row.totalRawText = totalRawText

    local durationText = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    durationText:SetPoint("LEFT", row, "LEFT", 596, 0)
    durationText:SetPoint("RIGHT", pinButton, "LEFT", -8, 0)
    durationText:SetJustifyH("LEFT")
    row.durationText = durationText

    frame.rows[index] = row
    return row
end

function GoldTracker:GetHistoryTotalsRow()
    local frame = self.historyFrame
    if not frame then
        return nil
    end

    local row = frame.totalsRow
    if row then
        return row
    end

    row = CreateFrame("Frame", nil, frame.content)
    row:SetHeight(ROW_HEIGHT)
    row:EnableMouse(false)

    local bg = row:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints(true)
    bg:SetColorTexture(0.25, 0.20, 0.02, 0.38)
    row.bg = bg

    local label = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    label:SetPoint("LEFT", row, "LEFT", 36, 0)
    label:SetPoint("RIGHT", row, "RIGHT", -10, 0)
    label:SetJustifyH("LEFT")
    label:SetTextColor(1, 0.90, 0.30)
    label:SetText("")
    row.text = label

    row:Hide()
    frame.totalsRow = row
    return row
end

function GoldTracker:GetHistoryLocationDetailsRow(index)
    local frame = self.historyFrame
    if not frame or not frame.locationTableFrame then
        return nil
    end

    frame.locationTableRows = frame.locationTableRows or {}
    local row = frame.locationTableRows[index]
    if row then
        return row
    end

    row = CreateFrame("Frame", nil, frame.locationTableContent or frame.locationTableFrame)
    row:SetHeight(16)

    local locationText = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    locationText:SetPoint("TOPLEFT", row, "TOPLEFT", 0, 0)
    locationText:SetWidth(470)
    locationText:SetJustifyH("LEFT")
    if locationText.SetJustifyV then
        locationText:SetJustifyV("TOP")
    end
    if locationText.SetWordWrap then
        locationText:SetWordWrap(true)
    end
    row.locationText = locationText

    local timeFrameText = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    timeFrameText:SetPoint("TOPLEFT", row, "TOPLEFT", 476, 0)
    timeFrameText:SetWidth(210)
    timeFrameText:SetJustifyH("LEFT")
    if timeFrameText.SetJustifyV then
        timeFrameText:SetJustifyV("TOP")
    end
    if timeFrameText.SetWordWrap then
        timeFrameText:SetWordWrap(true)
    end
    row.timeFrameText = timeFrameText

    local highlightsText = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    highlightsText:SetPoint("TOPLEFT", row, "TOPLEFT", 692, 0)
    highlightsText:SetWidth(80)
    highlightsText:SetJustifyH("LEFT")
    if highlightsText.SetJustifyV then
        highlightsText:SetJustifyV("TOP")
    end
    if highlightsText.SetWordWrap then
        highlightsText:SetWordWrap(false)
    end
    row.highlightsText = highlightsText

    local durationText = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    durationText:SetPoint("TOPLEFT", row, "TOPLEFT", 776, 0)
    durationText:SetWidth(56)
    durationText:SetJustifyH("LEFT")
    if durationText.SetJustifyV then
        durationText:SetJustifyV("TOP")
    end
    if durationText.SetWordWrap then
        durationText:SetWordWrap(false)
    end
    row.durationText = durationText

    local rowDivider = row:CreateTexture(nil, "ARTWORK")
    rowDivider:SetColorTexture(1, 0.82, 0, 0.22)
    rowDivider:SetPoint("BOTTOMLEFT", row, "BOTTOMLEFT", 0, 0)
    rowDivider:SetPoint("BOTTOMRIGHT", row, "BOTTOMRIGHT", 0, 0)
    rowDivider:SetHeight(1)
    rowDivider:Hide()
    row.divider = rowDivider

    frame.locationTableRows[index] = row
    return row
end

function GoldTracker:GetHistoryDetailsSummaryRow(index)
    local frame = self.historyFrame
    if not frame or not frame.summaryTableFrame then
        return nil
    end

    frame.summaryRows = frame.summaryRows or {}
    local row = frame.summaryRows[index]
    if row then
        return row
    end

    row = CreateFrame("Frame", nil, frame.summaryTableFrame)
    row:SetHeight(16)

    local labelText = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    labelText:SetPoint("TOPLEFT", row, "TOPLEFT", 0, 0)
    labelText:SetWidth(230)
    labelText:SetJustifyH("LEFT")
    if labelText.SetJustifyV then
        labelText:SetJustifyV("TOP")
    end
    if labelText.SetWordWrap then
        labelText:SetWordWrap(false)
    end
    row.labelText = labelText

    local valueText = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    valueText:SetPoint("TOPLEFT", row, "TOPLEFT", 236, 0)
    valueText:SetPoint("TOPRIGHT", row, "TOPRIGHT", 0, 0)
    valueText:SetJustifyH("LEFT")
    if valueText.SetJustifyV then
        valueText:SetJustifyV("TOP")
    end
    if valueText.SetWordWrap then
        valueText:SetWordWrap(false)
    end
    row.valueText = valueText

    frame.summaryRows[index] = row
    return row
end

function GoldTracker:GetHistoryDetailsItemRow(index)
    local frame = self.historyFrame
    if not frame or not frame.detailsItemsContent then
        return nil
    end

    frame.detailsItemRows = frame.detailsItemRows or {}
    local row = frame.detailsItemRows[index]
    if row then
        return row
    end

    row = CreateFrame("Button", nil, frame.detailsItemsContent)
    row:SetHeight(18)
    row:EnableMouse(true)

    local itemText = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    itemText:SetPoint("LEFT", row, "LEFT", 4, 0)
    itemText:SetJustifyH("LEFT")
    itemText:SetWordWrap(false)
    row.itemText = itemText

    local sourceText = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    sourceText:SetPoint("RIGHT", row, "RIGHT", -4, 0)
    sourceText:SetWidth(DETAILS_ITEMS_SOURCE_WIDTH)
    sourceText:SetJustifyH("LEFT")
    sourceText:SetWordWrap(false)
    row.sourceText = sourceText

    local valueText = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    valueText:SetPoint("RIGHT", sourceText, "LEFT", -12, 0)
    valueText:SetWidth(DETAILS_ITEMS_VALUE_WIDTH)
    valueText:SetJustifyH("RIGHT")
    valueText:SetWordWrap(false)
    row.valueText = valueText

    itemText:SetPoint("RIGHT", valueText, "LEFT", -12, 0)

    local divider = row:CreateTexture(nil, "ARTWORK")
    divider:SetColorTexture(1, 0.82, 0, 0.18)
    divider:SetPoint("BOTTOMLEFT", row, "BOTTOMLEFT", 0, 0)
    divider:SetPoint("BOTTOMRIGHT", row, "BOTTOMRIGHT", 0, 0)
    divider:SetHeight(1)
    divider:Hide()
    row.divider = divider

    row:SetScript("OnEnter", function(self)
        if type(self.itemLink) ~= "string" or self.itemLink == "" then
            return
        end
        GameTooltip:SetOwner(self, "ANCHOR_CURSOR")
        GameTooltip:SetHyperlink(self.itemLink)
        GameTooltip:Show()
    end)
    row:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)
    row:SetScript("OnMouseUp", function(self, button)
        if button == "LeftButton" and type(self.itemLink) == "string" and self.itemLink ~= "" and HandleModifiedItemClick then
            HandleModifiedItemClick(self.itemLink)
        end
    end)

    frame.detailsItemRows[index] = row
    return row
end

function GoldTracker:RefreshHistoryDetailsItemsTable(items, includeSourceLabel)
    local frame = self.historyFrame
    if not frame or not frame.detailsItemsContent then
        return
    end

    local baseSize = self.GetHistoryDetailsFontSize and self:GetHistoryDetailsFontSize() or 12
    baseSize = math.max(8, math.min(24, math.floor((tonumber(baseSize) or 12) + 0.5)))
    local rowHeight = math.max(18, baseSize + 8)
    local yOffset = 0

    if frame.detailsItemsEmptyText then
        frame.detailsItemsEmptyText:SetShown(type(items) ~= "table" or #items == 0)
    end

    if type(items) ~= "table" or #items == 0 then
        for _, row in ipairs(frame.detailsItemRows or {}) do
            row:Hide()
        end
        frame.detailsItemsContent:SetHeight(1)
        if frame.detailsItemsScrollFrame then
            frame.detailsItemsContent:SetWidth(math.max(1, (frame.detailsItemsScrollFrame:GetWidth() or 0) - 6))
            if frame.detailsItemsScrollFrame.UpdateScrollChildRect then
                frame.detailsItemsScrollFrame:UpdateScrollChildRect()
            end
            frame.detailsItemsScrollFrame:SetVerticalScroll(0)
        end
        return
    end

    for index, item in ipairs(items) do
        local row = self:GetHistoryDetailsItemRow(index)
        if row then
            local quantity = math.max(0, math.floor((tonumber(item and item.quantity) or 0) + 0.5))
            local itemText = string.format("%s x%d", item and item.itemLink or "Unknown item", quantity)
            if includeSourceLabel then
                itemText = string.format("%s  [%s]", itemText, item.valueSourceLabel or "Unknown")
            end

            row.itemLink = item and item.itemLink or nil
            row.itemText:SetText(itemText)
            row.valueText:SetText(self:FormatMoney(tonumber(item and item.totalValue) or 0))
            row.sourceText:SetText((type(item and item.lootSourceText) == "string" and item.lootSourceText ~= "") and item.lootSourceText or "")
            row.itemText:SetTextColor(0.9, 0.9, 1)
            row.valueText:SetTextColor(0.9, 0.9, 1)
            row.sourceText:SetTextColor(0.9, 0.9, 1)

            row:ClearAllPoints()
            row:SetPoint("TOPLEFT", frame.detailsItemsContent, "TOPLEFT", 0, -yOffset)
            row:SetPoint("TOPRIGHT", frame.detailsItemsContent, "TOPRIGHT", 0, -yOffset)
            row:SetHeight(rowHeight)
            row.divider:SetShown(index < #items)
            row:Show()

            yOffset = yOffset + rowHeight
            if index < #items then
                yOffset = yOffset + DETAILS_ITEMS_ROW_SPACING
            end
        end
    end

    for index = (#items + 1), #(frame.detailsItemRows or {}) do
        if frame.detailsItemRows[index] then
            frame.detailsItemRows[index]:Hide()
        end
    end

    frame.detailsItemsContent:SetHeight(math.max(1, yOffset))
    if frame.detailsItemsScrollFrame then
        frame.detailsItemsContent:SetWidth(math.max(1, (frame.detailsItemsScrollFrame:GetWidth() or 0) - 6))
        if frame.detailsItemsScrollFrame.UpdateScrollChildRect then
            frame.detailsItemsScrollFrame:UpdateScrollChildRect()
        end
        frame.detailsItemsScrollFrame:SetVerticalScroll(0)
    end
end

function GoldTracker:GetSelectedHistorySessionIDsInOrder()
    local frame = self.historyFrame
    if not frame then
        return {}
    end

    local selectedMap = frame.selectedSessionIDs or {}
    local orderedSessions = self:GetDisplaySortedSessionHistory()
    local selectedIDs = {}
    for _, session in ipairs(orderedSessions) do
        if selectedMap[session.id] then
            selectedIDs[#selectedIDs + 1] = session.id
        end
    end
    return selectedIDs
end

function GoldTracker:ClearHistorySelection()
    if not self.historyFrame then
        return
    end

    self.historyFrame.selectedSessionIDs = {}
    self.historyFrame.visibleSessionIDs = self.historyFrame.visibleSessionIDs or {}
    if self.UpdateHistoryActionButtons then
        self:UpdateHistoryActionButtons()
    end
end

function GoldTracker:UpdateHistoryPageSelectAllState()
    local frame = self.historyFrame
    if not frame or not frame.selectPageCheckbox then
        return
    end

    local isListView = frame.view == "list"
    frame.selectPageCheckbox:SetShown(isListView)
    if not isListView then
        frame.selectPageCheckbox:SetChecked(false)
        return
    end

    local visibleSessionIDs = frame.visibleSessionIDs or {}
    if #visibleSessionIDs == 0 then
        frame.selectPageCheckbox:SetChecked(false)
        frame.selectPageCheckbox:SetEnabled(false)
        return
    end

    frame.selectPageCheckbox:SetEnabled(true)
    local selectedMap = frame.selectedSessionIDs or {}
    local allVisibleSelected = true
    for _, sessionID in ipairs(visibleSessionIDs) do
        if selectedMap[sessionID] ~= true then
            allVisibleSelected = false
            break
        end
    end
    frame.selectPageCheckbox:SetChecked(allVisibleSelected)
end

function GoldTracker:SetHistoryCurrentPageSelection(shouldSelect)
    local frame = self.historyFrame
    if not frame then
        return
    end

    local visibleSessionIDs = frame.visibleSessionIDs or {}
    if #visibleSessionIDs == 0 then
        self:UpdateHistoryPageSelectAllState()
        return
    end

    local selectedMap = frame.selectedSessionIDs or {}
    for _, sessionID in ipairs(visibleSessionIDs) do
        if shouldSelect then
            selectedMap[sessionID] = true
        else
            selectedMap[sessionID] = nil
        end
    end
    frame.selectedSessionIDs = selectedMap
    self:RefreshHistoryWindow()
end

function GoldTracker:UpdateHistoryActionButtons()
    local frame = self.historyFrame
    if not frame then
        return
    end

    local selectedCount = 0
    for _ in pairs(frame.selectedSessionIDs or {}) do
        selectedCount = selectedCount + 1
    end

    local isListView = frame.view == "list"

    if frame.bulkDeleteButton then
        if isListView and selectedCount > 0 then
            frame.bulkDeleteButton:SetText(selectedCount > 1 and string.format("Bulk Delete (%d)", selectedCount) or "Bulk Delete")
            frame.bulkDeleteButton:Show()
        else
            frame.bulkDeleteButton:Hide()
        end
    end

    if frame.mergeButton then
        if isListView and selectedCount > 1 then
            frame.mergeButton:SetText(string.format("Merge (%d)", selectedCount))
            frame.mergeButton:Show()
        else
            frame.mergeButton:Hide()
        end
    end

    self:UpdateHistoryPageSelectAllState()
end

function GoldTracker:GetDisplaySortedSessionHistory()
    local ordered = {}

    local frame = self.historyFrame
    local filterKey = frame and frame.historyDateFilterKey or HISTORY_DATE_FILTER_ALL
    for _, session in ipairs(self:GetSessionHistory()) do
        if SessionMatchesDateFilter(session, filterKey) then
            ordered[#ordered + 1] = session
        end
    end

    local sortKey = frame and frame.sortKey or nil
    local sortAscending = frame and frame.sortAscending == true

    table.sort(ordered, function(a, b)
        local aPinned = a and a.pinned == true
        local bPinned = b and b.pinned == true
        if aPinned ~= bPinned then
            return aPinned and not bPinned
        end

        if sortKey == "sessionTotal" or sortKey == "sessionTotalRaw" or sortKey == "duration" then
            local aValue = GetHistorySortValue(a, sortKey)
            local bValue = GetHistorySortValue(b, sortKey)
            if aValue ~= bValue then
                if sortAscending then
                    return aValue < bValue
                end
                return aValue > bValue
            end
        end

        return CompareHistorySessionsByRecency(a, b)
    end)

    return ordered
end

function GoldTracker:UpdateHistorySortHeaderState()
    if not self.historyFrame then
        return
    end

    local frame = self.historyFrame
    local sortKey = frame.sortKey
    local totalLabel = "Session Total"
    local totalRawLabel = "Raw Total"
    local durationLabel = "Duration"

    if sortKey == "sessionTotal" then
        totalLabel = frame.sortAscending and "Session Total \226\150\178" or "Session Total \226\150\188"
    elseif sortKey == "sessionTotalRaw" then
        totalRawLabel = frame.sortAscending and "Raw Total \226\150\178" or "Raw Total \226\150\188"
    elseif sortKey == "duration" then
        durationLabel = frame.sortAscending and "Duration \226\150\178" or "Duration \226\150\188"
    end

    if frame.totalHeaderButton and frame.totalHeaderButton.text then
        frame.totalHeaderButton.text:SetText(totalLabel)
        if sortKey == "sessionTotal" then
            frame.totalHeaderButton.text:SetTextColor(1, 1, 1)
        else
            frame.totalHeaderButton.text:SetTextColor(1, 0.82, 0)
        end
    end
    if frame.totalRawHeaderButton and frame.totalRawHeaderButton.text then
        frame.totalRawHeaderButton.text:SetText(totalRawLabel)
        if sortKey == "sessionTotalRaw" then
            frame.totalRawHeaderButton.text:SetTextColor(1, 1, 1)
        else
            frame.totalRawHeaderButton.text:SetTextColor(1, 0.82, 0)
        end
    end
    if frame.durationHeaderButton and frame.durationHeaderButton.text then
        frame.durationHeaderButton.text:SetText(durationLabel)
        if sortKey == "duration" then
            frame.durationHeaderButton.text:SetTextColor(1, 1, 1)
        else
            frame.durationHeaderButton.text:SetTextColor(1, 0.82, 0)
        end
    end
end

function GoldTracker:ToggleHistorySort(sortKey)
    if not self.historyFrame then
        return
    end

    local frame = self.historyFrame
    if sortKey ~= "sessionTotal" and sortKey ~= "sessionTotalRaw" and sortKey ~= "duration" then
        return
    end

    if frame.sortKey ~= sortKey then
        frame.sortKey = sortKey
        frame.sortAscending = false
    elseif frame.sortAscending ~= true then
        frame.sortAscending = true
    else
        frame.sortKey = nil
        frame.sortAscending = false
    end

    frame.currentPage = 1
    self:RefreshHistoryWindow()
end

function GoldTracker:GetHistoryPageCount(sessionCount)
    local rowsPerPage = self:GetHistoryRowsPerPage()
    local totalSessions = math.max(0, tonumber(sessionCount) or 0)
    return math.max(1, math.ceil(totalSessions / rowsPerPage))
end

function GoldTracker:SetHistoryPage(page)
    if not self.historyFrame then
        return
    end

    local frame = self.historyFrame
    local totalPages = self:GetHistoryPageCount(#self:GetDisplaySortedSessionHistory())
    local clampedPage = math.max(1, math.min(totalPages, math.floor(tonumber(page) or 1)))
    if frame.currentPage == clampedPage then
        return
    end

    frame.currentPage = clampedPage
    self:RefreshHistoryWindow()
end

function GoldTracker:ShowHistoryListView()
    if not self.historyFrame then
        return
    end

    local frame = self.historyFrame
    frame.view = "list"
    frame.selectedSessionID = nil
    frame.selectedSessionIDs = {}
    if not frame.currentPage then
        frame.currentPage = 1
    end

    if frame.TitleText then
        frame.TitleText:SetText("General Gold Tracker - Session History")
    end

    if frame.listContainer then
        frame.listContainer:Show()
    end
    if frame.detailsContainer then
        frame.detailsContainer:Hide()
    end
    if frame.splitButton then
        frame.splitButton:Hide()
    end
    if frame.backButton then
        frame.backButton:Hide()
    end

    self:UpdateHistoryActionButtons()

    self:RefreshHistoryWindow()
end

function GoldTracker:ShowHistoryDetailsView(sessionID)
    if not self.historyFrame then
        return
    end

    local frame = self.historyFrame
    frame.view = "details"
    frame.selectedSessionID = sessionID
    frame.detailsLocationFilterKey = DETAILS_LOCATION_FILTER_ALL
    local _, currentHeight = frame:GetSize()
    if (tonumber(currentHeight) or 0) <= HISTORY_WINDOW_DEFAULT_HEIGHT then
        frame:SetHeight(HISTORY_WINDOW_DETAILS_DEFAULT_HEIGHT)
    end

    if frame.TitleText then
        frame.TitleText:SetText("General Gold Tracker - Session Details")
    end

    if frame.listContainer then
        frame.listContainer:Hide()
    end
    if frame.detailsContainer then
        frame.detailsContainer:Show()
    end
    if frame.backButton then
        frame.backButton:Show()
    end

    self:UpdateHistoryActionButtons()

    self:RefreshHistoryDetailsWindow()
end

function GoldTracker:RefreshHistoryWindow()
    if not self.historyFrame then
        return
    end

    local frame = self.historyFrame
    local selectedFilterKey = frame.historyDateFilterKey or HISTORY_DATE_FILTER_ALL
    local selectedFilterLabel = nil
    for _, option in ipairs(HISTORY_DATE_FILTER_OPTIONS) do
        if option.key == selectedFilterKey then
            selectedFilterLabel = option.label
            break
        end
    end
    if not selectedFilterLabel then
        selectedFilterKey = HISTORY_DATE_FILTER_ALL
        selectedFilterLabel = "All time"
        frame.historyDateFilterKey = selectedFilterKey
    end
    if frame.historyDateFilterDropdown then
        UIDropDownMenu_SetSelectedValue(frame.historyDateFilterDropdown, selectedFilterKey)
        UIDropDownMenu_SetText(frame.historyDateFilterDropdown, selectedFilterLabel)
    end

    local history = self:GetDisplaySortedSessionHistory()
    local rowsPerPage = self:GetHistoryRowsPerPage()
    local totalPages = self:GetHistoryPageCount(#history)
    frame.currentPage = math.max(1, math.min(frame.currentPage or 1, totalPages))
    local startIndex = ((frame.currentPage - 1) * rowsPerPage) + 1
    local endIndex = math.min(#history, startIndex + rowsPerPage - 1)
    local width = math.max(760, (frame.scrollFrame:GetWidth() or 650) - 24)
    frame.content:SetWidth(width)

    local selectedMap = frame.selectedSessionIDs or {}
    local validIDs = {}
    for _, session in ipairs(history) do
        validIDs[session.id] = true
    end
    for selectedID in pairs(selectedMap) do
        if not validIDs[selectedID] then
            selectedMap[selectedID] = nil
        end
    end
    frame.selectedSessionIDs = selectedMap

    local renderedRows = 0
    local visibleSessionIDs = {}
    local dividerAfterRow = nil
    local previousWasPinned = nil
    for historyIndex = startIndex, endIndex do
        local session = history[historyIndex]
        renderedRows = renderedRows + 1
        local currentIsPinned = session.pinned == true
        if dividerAfterRow == nil and renderedRows > 1 and previousWasPinned and not currentIsPinned then
            dividerAfterRow = renderedRows - 1
        end
        previousWasPinned = currentIsPinned
        local sessionID = session.id
        visibleSessionIDs[#visibleSessionIDs + 1] = sessionID
        local row = self:GetHistoryRow(renderedRows)
        row:SetWidth(width)
        if row.bg then
            if selectedMap[sessionID] then
                row.bg:SetColorTexture(0.22, 0.22, 0, 0.25)
            else
                row.bg:SetColorTexture(0, 0, 0, 0.18)
            end
        end
        local rowTitleText, rowSubtitleText = BuildHistoryRowTitleAndSubtitle(session)
        row.nameText:SetText(TruncateSessionNameKeepingDate(self, rowTitleText, row.nameText))
        if row.subtitleText then
            if type(rowSubtitleText) == "string" and rowSubtitleText ~= "" then
                row.subtitleText:SetText(rowSubtitleText)
                row.subtitleText:Show()
            else
                row.subtitleText:SetText("")
                row.subtitleText:Hide()
            end
        end
        row.summaryText:SetText(FormatSessionSummary(self, session))
        row.totalText:SetText(FormatSessionTotal(self, session))
        row.totalRawText:SetText(FormatSessionTotalRaw(self, session))
        if row.durationText then
            row.durationText:SetText(FormatSessionDuration(session))
        end

        row.selectCheckbox:SetChecked(selectedMap[sessionID] == true)
        row.selectCheckbox:SetScript("OnClick", function(button)
            if button:GetChecked() then
                selectedMap[sessionID] = true
            else
                selectedMap[sessionID] = nil
            end
            if row.bg then
                if selectedMap[sessionID] then
                    row.bg:SetColorTexture(0.22, 0.22, 0, 0.25)
                else
                    row.bg:SetColorTexture(0, 0, 0, 0.18)
                end
            end
            self:UpdateHistoryActionButtons()
        end)

        row.pinButton:SetText(session.pinned and "Unpin" or "Pin")
        row.pinButton:SetScript("OnClick", function()
            self:ToggleHistorySessionPinned(sessionID)
        end)

        row:SetScript("OnClick", function()
            self:OpenHistorySessionDetails(sessionID)
        end)
        row.renameButton:SetScript("OnClick", function()
            self:PromptRenameHistorySession(sessionID)
        end)
        row.deleteButton:SetScript("OnClick", function()
            self:DeleteHistorySession(sessionID)
        end)
        row:Show()
    end

    frame.visibleSessionIDs = visibleSessionIDs

    for i = renderedRows + 1, #frame.rows do
        frame.rows[i]:Hide()
    end

    local showTotalsRow = selectedFilterKey ~= HISTORY_DATE_FILTER_ALL
    local renderedRowsWithTotals = renderedRows
    if showTotalsRow then
        local totalRawGold = 0
        local totalItemsValue = 0
        local totalValue = 0
        local totalHighlights = 0
        for _, session in ipairs(history) do
            totalRawGold = totalRawGold + (tonumber(session and session.rawGold) or 0)
            totalItemsValue = totalItemsValue + (tonumber(session and session.itemsValue) or 0)
            totalValue = totalValue + (tonumber(session and session.totalValue) or 0)
            totalHighlights = totalHighlights + (tonumber(session and session.highlightItemCount) or 0)
        end

        local totalsRow = self:GetHistoryTotalsRow()
        if totalsRow then
            totalsRow:SetWidth(width)
            totalsRow:ClearAllPoints()
            totalsRow:SetPoint("TOPLEFT", frame.content, "TOPLEFT", 0, -(renderedRows * ROW_SPACING))
            totalsRow.text:SetText(string.format(
                "Totals (%s): Sessions %d   Highlights %d   Raw %s   Items %s   Total %s",
                selectedFilterLabel,
                #history,
                totalHighlights,
                self:FormatMoney(totalRawGold),
                self:FormatMoney(totalItemsValue),
                self:FormatMoney(totalValue)
            ))
            totalsRow:Show()
            renderedRowsWithTotals = renderedRows + 1
        end
    elseif frame.totalsRow then
        frame.totalsRow:Hide()
    end

    local contentHeight = math.max(1, renderedRowsWithTotals * ROW_SPACING)
    frame.content:SetHeight(contentHeight)
    if frame.pinnedDivider then
        if dividerAfterRow and dividerAfterRow > 0 then
            local dividerY = -((dividerAfterRow * ROW_SPACING) - 2)
            frame.pinnedDivider:ClearAllPoints()
            frame.pinnedDivider:SetPoint("TOPLEFT", frame.content, "TOPLEFT", 24, dividerY)
            frame.pinnedDivider:SetPoint("TOPRIGHT", frame.content, "TOPRIGHT", -42, dividerY)
            frame.pinnedDivider:Show()
        else
            frame.pinnedDivider:Hide()
        end
    end
    frame.scrollFrame:SetVerticalScroll(0)
    if frame.emptyText then
        if #history == 0 and selectedFilterKey ~= HISTORY_DATE_FILTER_ALL then
            frame.emptyText:SetText("")
        else
            frame.emptyText:SetText("No saved sessions.")
        end
        frame.emptyText:SetShown(#history == 0 and not showTotalsRow)
    end
    if frame.prevPageButton then
        frame.prevPageButton:SetEnabled(frame.currentPage > 1)
    end
    if frame.nextPageButton then
        frame.nextPageButton:SetEnabled(frame.currentPage < totalPages)
    end
    if frame.pageText then
        local shownFrom = #history == 0 and 0 or startIndex
        local shownTo = #history == 0 and 0 or endIndex
        local pageLine = string.format("Page %d / %d   Showing %d-%d of %d", frame.currentPage, totalPages, shownFrom, shownTo, #history)
        if selectedFilterKey ~= HISTORY_DATE_FILTER_ALL then
            pageLine = string.format("%s   Filter: %s", pageLine, selectedFilterLabel)
        end
        frame.pageText:SetText(pageLine)
    end
    self:UpdateHistorySortHeaderState()
    self:UpdateHistoryActionButtons()
end

function GoldTracker:ApplyHistoryDetailsFontSize()
    local frame = self.historyFrame
    if not frame then
        return
    end

    local baseSize = 12
    if type(self.GetHistoryDetailsFontSize) == "function" then
        baseSize = self:GetHistoryDetailsFontSize()
    end
    baseSize = math.max(8, math.min(24, math.floor((tonumber(baseSize) or 12) + 0.5)))

    local function ApplyFontSize(region, size, fallbackFontObject)
        if not region or type(region.GetFont) ~= "function" or type(region.SetFont) ~= "function" then
            return
        end

        local fontPath, _, fontFlags = region:GetFont()
        if not fontPath and fallbackFontObject and type(fallbackFontObject.GetFont) == "function" then
            fontPath, _, fontFlags = fallbackFontObject:GetFont()
        end
        if not fontPath then
            fontPath = "Fonts\\FRIZQT__.TTF"
        end

        region:SetFont(fontPath, size, fontFlags)
    end

    ApplyFontSize(frame.sessionNameText, baseSize + 2, GameFontHighlight)
    ApplyFontSize(frame.locationHeaderText, math.max(8, baseSize - 1), GameFontNormalSmall)
    ApplyFontSize(frame.timeFrameHeaderText, math.max(8, baseSize - 1), GameFontNormalSmall)
    ApplyFontSize(frame.highlightsHeaderText, math.max(8, baseSize - 1), GameFontNormalSmall)
    ApplyFontSize(frame.durationHeaderText, math.max(8, baseSize - 1), GameFontNormalSmall)
    for _, row in ipairs(frame.locationTableRows or {}) do
        ApplyFontSize(row.locationText, baseSize, GameFontHighlightSmall)
        ApplyFontSize(row.timeFrameText, baseSize, GameFontHighlightSmall)
        ApplyFontSize(row.highlightsText, baseSize, GameFontHighlightSmall)
        ApplyFontSize(row.durationText, baseSize, GameFontHighlightSmall)
    end
    for _, row in ipairs(frame.summaryRows or {}) do
        ApplyFontSize(row.labelText, baseSize, GameFontHighlightSmall)
        ApplyFontSize(row.valueText, baseSize, GameFontHighlightSmall)
    end
    ApplyFontSize(frame.itemsHeaderText, baseSize, GameFontNormal)
    ApplyFontSize(frame.itemsItemHeaderText, math.max(8, baseSize - 1), GameFontNormalSmall)
    ApplyFontSize(frame.itemsValueHeaderText, math.max(8, baseSize - 1), GameFontNormalSmall)
    ApplyFontSize(frame.itemsSourceHeaderText, math.max(8, baseSize - 1), GameFontNormalSmall)
    if frame.detailsItemsEmptyText then
        ApplyFontSize(frame.detailsItemsEmptyText, baseSize, GameFontHighlightSmall)
    end
    for _, row in ipairs(frame.detailsItemRows or {}) do
        ApplyFontSize(row.itemText, baseSize, GameFontHighlightSmall)
        ApplyFontSize(row.valueText, baseSize, GameFontHighlightSmall)
        ApplyFontSize(row.sourceText, baseSize, GameFontHighlightSmall)
    end
end

function GoldTracker:OpenHistoryWindow()
    if not self:IsSessionHistoryEnabled() then
        self:Print("Session history is disabled. Enable it in options first.")
        return
    end

    self:CreateHistoryWindow()
    self:ShowHistoryListView()
    self.historyFrame:Show()
    self.historyFrame:Raise()
end

function GoldTracker:RefreshHistoryDetailsWindow()
    local frame = self.historyFrame
    if not frame or frame.view ~= "details" then
        return
    end

    self:ApplyHistoryDetailsFontSize()

    local session = self:GetHistorySessionByID(frame.selectedSessionID)
    if not session then
        self:ShowHistoryListView()
        return
    end

    local locationOptions = BuildHistoryLocationOptions(session)
    frame.detailsLocationOptions = locationOptions
    local selectedLocationKey = frame.detailsLocationFilterKey or DETAILS_LOCATION_FILTER_ALL
    local selectedLocationLabel = "All"
    local selectedLocationIsValid = false
    for _, option in ipairs(locationOptions) do
        if option.key == selectedLocationKey then
            selectedLocationLabel = option.label
            selectedLocationIsValid = true
            break
        end
    end
    if not selectedLocationIsValid then
        selectedLocationKey = DETAILS_LOCATION_FILTER_ALL
        frame.detailsLocationFilterKey = selectedLocationKey
        selectedLocationLabel = "All"
    end
    if frame.locationFilterDropdown then
        UIDropDownMenu_SetSelectedValue(frame.locationFilterDropdown, selectedLocationKey)
        UIDropDownMenu_SetText(frame.locationFilterDropdown, selectedLocationLabel)
    end
    if frame.splitButton then
        frame.splitButton:SetShown(#locationOptions > 2)
    end
    if frame.resumeSessionButton then
        local enabled = self:IsResumeHistorySessionEnabled()
        frame.resumeSessionButton:SetEnabled(enabled)
        frame.resumeSessionButton:SetAlpha(enabled and 1 or 0.45)
    end

    local filteredSummary = BuildHistoryDetailsSummary(session, selectedLocationKey)

    frame.sessionNameText:SetText(session.name or "Session")

    local summaryDurationSeconds = tonumber(filteredSummary.duration) or 0
    local summaryRawTotal = (tonumber(filteredSummary.rawGold) or 0) + (tonumber(filteredSummary.itemsRawGold) or 0)

    local summaryRowsData = {
        { label = "Duration", value = self:FormatDuration(filteredSummary.duration or 0) },
        { label = "Value source", value = session.valueSourceLabel or "Unknown" },
        { label = "Raw gold", value = self:FormatMoney(filteredSummary.rawGold or 0) },
        { label = "Vendor items gold", value = self:FormatMoney(filteredSummary.itemsRawGold or 0) },
        { label = "AH value", value = self:FormatMoney(filteredSummary.itemsValue or 0) },
        { label = "Raw session total", value = self:FormatMoney(summaryRawTotal) },
        { label = "Session Total", value = self:FormatMoney(filteredSummary.totalValue or 0) },
        { label = "Session / hour", value = self:FormatMoneyPerHour(filteredSummary.totalValue or 0, summaryDurationSeconds) },
        { label = "AH / hour", value = self:FormatMoneyPerHour(filteredSummary.itemsValue or 0, summaryDurationSeconds) },
        { label = "Raw / hour", value = self:FormatMoneyPerHour(summaryRawTotal, summaryDurationSeconds) },
    }

    -- Always show the complete per-location table; dropdown still filters summary and item list.
    local locationRows = BuildLocationDetailsRowsForSelection(session, DETAILS_LOCATION_FILTER_ALL)
    local hasLocationRows = type(locationRows) == "table" and #locationRows > 0

    if hasLocationRows and frame.locationTableFrame then
        for index = 1, #locationRows do
            self:GetHistoryLocationDetailsRow(index)
        end
        self:ApplyHistoryDetailsFontSize()

        local baseSize = self.GetHistoryDetailsFontSize and self:GetHistoryDetailsFontSize() or 12
        baseSize = math.max(8, math.min(24, math.floor((tonumber(baseSize) or 12) + 0.5)))
        local rowSpacing = 4
        local minRowHeight = math.max(12, baseSize + 3)
        local yOffset = 0
        local bodyHeight = 0
        local visibleBodyHeight = 0

        for index, rowData in ipairs(locationRows) do
            local row = self:GetHistoryLocationDetailsRow(index)
            if row then
                local startText = rowData.timeFrameStart or "Unknown"
                local endText = rowData.timeFrameEnd or ""
                local timeFrameCellText = startText
                if type(endText) == "string" and endText ~= "" then
                    timeFrameCellText = string.format("%s\n%s", startText, endText)
                end

                row.locationText:SetText(rowData.location or "Unknown")
                row.timeFrameText:SetText(timeFrameCellText)
                row.highlightsText:SetText(tostring(math.max(0, math.floor((tonumber(rowData.highlights) or 0) + 0.5))))
                row.durationText:SetText(rowData.duration or "<1m")

                local rowHeight = math.max(
                    minRowHeight,
                    tonumber(row.locationText:GetStringHeight()) or minRowHeight,
                    tonumber(row.timeFrameText:GetStringHeight()) or minRowHeight,
                    tonumber(row.highlightsText:GetStringHeight()) or minRowHeight,
                    tonumber(row.durationText:GetStringHeight()) or minRowHeight
                ) + 2

                row:ClearAllPoints()
                row:SetPoint("TOPLEFT", frame.locationTableContent, "TOPLEFT", 0, -yOffset)
                row:SetPoint("TOPRIGHT", frame.locationTableContent, "TOPRIGHT", 0, -yOffset)
                row:SetHeight(rowHeight)
                row:Show()
                if row.divider then
                    row.divider:SetShown(index < #locationRows)
                end

                bodyHeight = bodyHeight + rowHeight
                if index <= LOCATION_TABLE_MAX_VISIBLE_ROWS then
                    visibleBodyHeight = visibleBodyHeight + rowHeight
                end
                if index < #locationRows then
                    bodyHeight = bodyHeight + rowSpacing
                    yOffset = yOffset + rowHeight + rowSpacing
                    if index < LOCATION_TABLE_MAX_VISIBLE_ROWS then
                        visibleBodyHeight = visibleBodyHeight + rowSpacing
                    end
                else
                    yOffset = yOffset + rowHeight
                end
            end
        end

        for index = (#locationRows + 1), #(frame.locationTableRows or {}) do
            if frame.locationTableRows[index] then
                if frame.locationTableRows[index].divider then
                    frame.locationTableRows[index].divider:Hide()
                end
                frame.locationTableRows[index]:Hide()
            end
        end

        local scrollBodyHeight = bodyHeight
        local maxVisibleBodyHeight = (visibleBodyHeight > 0) and visibleBodyHeight or bodyHeight
        if #locationRows <= LOCATION_TABLE_MAX_VISIBLE_ROWS then
            maxVisibleBodyHeight = bodyHeight
        end

        if frame.locationTableContent then
            frame.locationTableContent:SetHeight(math.max(1, scrollBodyHeight))
            if frame.locationTableScrollFrame then
                local scrollWidth = (frame.locationTableScrollFrame:GetWidth() or 0) - 6
                if scrollWidth <= 1 and frame.locationTableFrame then
                    scrollWidth = (frame.locationTableFrame:GetWidth() or 0) - 33
                end
                frame.locationTableContent:SetWidth(math.max(1, scrollWidth))
            end
        end
        if frame.locationTableScrollFrame then
            frame.locationTableScrollFrame:SetHeight(math.max(1, maxVisibleBodyHeight))
            if frame.locationTableScrollFrame.UpdateScrollChildRect then
                frame.locationTableScrollFrame:UpdateScrollChildRect()
            end
            frame.locationTableScrollFrame:SetVerticalScroll(0)
        end

        frame.locationTableFrame:SetHeight(20 + math.max(1, maxVisibleBodyHeight) + 6)
        frame.locationTableFrame:Show()
    else
        for _, row in ipairs(frame.locationTableRows or {}) do
            if row.divider then
                row.divider:Hide()
            end
            row:Hide()
        end
        if frame.locationTableFrame then
            frame.locationTableFrame:Hide()
        end
        if frame.locationTableContent then
            frame.locationTableContent:SetHeight(1)
        end
        if frame.locationTableScrollFrame then
            frame.locationTableScrollFrame:SetHeight(1)
            frame.locationTableScrollFrame:SetVerticalScroll(0)
        end
    end

    if frame.locationFilterLabelText then
        frame.locationFilterLabelText:ClearAllPoints()
        if hasLocationRows and frame.locationTableFrame then
            frame.locationFilterLabelText:SetPoint("TOPLEFT", frame.locationTableFrame, "BOTTOMLEFT", 0, -DETAILS_GAP_LOCATION_TABLE_TO_FILTER)
        else
            frame.locationFilterLabelText:SetPoint("TOPLEFT", frame.sessionNameText, "BOTTOMLEFT", 0, -DETAILS_GAP_LOCATION_TABLE_TO_FILTER)
        end
    end

    if frame.summaryTableFrame then
        frame.summaryTableFrame:ClearAllPoints()
        if frame.locationFilterLabelText then
            frame.summaryTableFrame:SetPoint("TOPLEFT", frame.locationFilterLabelText, "BOTTOMLEFT", 0, -DETAILS_GAP_FILTER_TO_SUMMARY)
        else
            frame.summaryTableFrame:SetPoint("TOPLEFT", frame.sessionNameText, "BOTTOMLEFT", 0, -8)
        end
        frame.summaryTableFrame:SetPoint("RIGHT", frame.detailsContainer, "RIGHT", -20, 0)

        for index = 1, #summaryRowsData do
            self:GetHistoryDetailsSummaryRow(index)
        end
        self:ApplyHistoryDetailsFontSize()

        local baseSize = self.GetHistoryDetailsFontSize and self:GetHistoryDetailsFontSize() or 12
        baseSize = math.max(8, math.min(24, math.floor((tonumber(baseSize) or 12) + 0.5)))
        local rowSpacing = 1
        local minRowHeight = math.max(12, baseSize + 2)
        local yOffset = 0
        local bodyHeight = 0

        for index, rowData in ipairs(summaryRowsData) do
            local row = self:GetHistoryDetailsSummaryRow(index)
            if row then
                row.labelText:SetText(string.format("%s:", rowData.label or ""))
                row.valueText:SetText(rowData.value or "")

                local rowHeight = math.max(
                    minRowHeight,
                    tonumber(row.labelText:GetStringHeight()) or minRowHeight,
                    tonumber(row.valueText:GetStringHeight()) or minRowHeight
                ) + 1

                row:ClearAllPoints()
                row:SetPoint("TOPLEFT", frame.summaryTableFrame, "TOPLEFT", 0, -yOffset)
                row:SetPoint("TOPRIGHT", frame.summaryTableFrame, "TOPRIGHT", 0, -yOffset)
                row:SetHeight(rowHeight)
                row:Show()

                bodyHeight = bodyHeight + rowHeight
                if index < #summaryRowsData then
                    bodyHeight = bodyHeight + rowSpacing
                    yOffset = yOffset + rowHeight + rowSpacing
                else
                    yOffset = yOffset + rowHeight
                end
            end
        end

        for index = (#summaryRowsData + 1), #(frame.summaryRows or {}) do
            if frame.summaryRows[index] then
                frame.summaryRows[index]:Hide()
            end
        end

        frame.summaryTableFrame:SetHeight(math.max(1, bodyHeight))
        frame.summaryTableFrame:Show()
    end

    local items, includeSourceLabel = BuildVisibleHistoryItems(session, selectedLocationKey)
    self:RefreshHistoryDetailsItemsTable(items, includeSourceLabel)
end

function GoldTracker:BuildHistorySessionCSV(sessionID)
    local frame = self.historyFrame
    local session = self:GetHistorySessionByID(sessionID)
    if not session then
        return nil
    end

    local selectedLocationKey = DETAILS_LOCATION_FILTER_ALL
    if frame and frame.view == "details" and frame.selectedSessionID == sessionID then
        selectedLocationKey = frame.detailsLocationFilterKey or DETAILS_LOCATION_FILTER_ALL
    end

    local summary = BuildHistoryDetailsSummary(session, selectedLocationKey)
    local items = BuildVisibleHistoryItems(session, selectedLocationKey)
    local rows = {
        "section,key,value",
        string.format("session,id,%s", EscapeCSVValue(session.id)),
        string.format("session,name,%s", EscapeCSVValue(session.name or "Session")),
        string.format("session,start_time,%s", EscapeCSVValue(date("%Y-%m-%d %H:%M:%S", tonumber(summary.startTime) or time()))),
        string.format("session,stop_time,%s", EscapeCSVValue(date("%Y-%m-%d %H:%M:%S", tonumber(summary.stopTime) or time()))),
        string.format("session,duration_seconds,%s", EscapeCSVValue(math.floor(tonumber(summary.duration) or 0))),
        string.format("session,raw_gold_copper,%s", EscapeCSVValue(math.floor(tonumber(summary.rawGold) or 0))),
        string.format("session,vendor_items_copper,%s", EscapeCSVValue(math.floor(tonumber(summary.itemsRawGold) or 0))),
        string.format("session,ah_value_copper,%s", EscapeCSVValue(math.floor(tonumber(summary.itemsValue) or 0))),
        string.format("session,total_value_copper,%s", EscapeCSVValue(math.floor(tonumber(summary.totalValue) or 0))),
        "",
        "items,item_link,quantity,total_value_copper,value_source,loot_source",
    }

    for _, item in ipairs(items or {}) do
        rows[#rows + 1] = string.format(
            "items,%s,%s,%s,%s,%s",
            EscapeCSVValue(item.itemLink or ""),
            EscapeCSVValue(math.floor(tonumber(item.quantity) or 0)),
            EscapeCSVValue(math.floor(tonumber(item.totalValue) or 0)),
            EscapeCSVValue(item.valueSourceLabel or ""),
            EscapeCSVValue(item.lootSourceText or "")
        )
    end

    return table.concat(rows, "\n")
end

function GoldTracker:CreateHistoryExportWindow()
    if self.historyExportFrame then
        return
    end

    local frame = CreateFrame("Frame", "GoldTrackerHistoryExportFrame", UIParent, "BasicFrameTemplateWithInset")
    frame:SetSize(760, 480)
    frame:SetPoint("CENTER")
    frame:SetFrameStrata("DIALOG")
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
    frame:Hide()

    if frame.TitleText then
        frame.TitleText:SetText("General Gold Tracker - History CSV Export")
    end

    local hint = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    hint:SetPoint("TOPLEFT", frame, "TOPLEFT", 16, -32)
    hint:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -16, -32)
    hint:SetJustifyH("LEFT")
    hint:SetText("Select all (Ctrl+A) and copy (Ctrl+C).")

    local scroll = CreateFrame("ScrollFrame", nil, frame, "UIPanelScrollFrameTemplate")
    scroll:SetPoint("TOPLEFT", frame, "TOPLEFT", 14, -52)
    scroll:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -34, 14)

    local editBox = CreateFrame("EditBox", nil, scroll)
    editBox:SetMultiLine(true)
    editBox:SetAutoFocus(false)
    editBox:SetFontObject(GameFontHighlightSmall)
    editBox:SetWidth(680)
    editBox:SetScript("OnEscapePressed", function() frame:Hide() end)
    scroll:SetScrollChild(editBox)

    frame.exportEditBox = editBox
    self.historyExportFrame = frame
end

function GoldTracker:OpenHistorySessionExport(sessionID)
    local csvText = self:BuildHistorySessionCSV(sessionID)
    if not csvText then
        return
    end

    self:CreateHistoryExportWindow()
    local frame = self.historyExportFrame
    frame.exportEditBox:SetText(csvText)
    frame.exportEditBox:HighlightText()
    frame:Show()
    frame:Raise()
    frame.exportEditBox:SetFocus()
end

function GoldTracker:CreateHistoryLootBreakdownWindow()
    if self.historyBreakdownFrame then
        return
    end

    local frame = CreateFrame("Frame", "GoldTrackerHistoryBreakdownFrame", UIParent, "BasicFrameTemplateWithInset")
    frame:SetSize(460, 380)
    frame:SetPoint("CENTER", UIParent, "CENTER", 220, 40)
    frame:SetFrameStrata("DIALOG")
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
    frame:Hide()

    if frame.TitleText then
        frame.TitleText:SetText("General Gold Tracker - Loot Breakdown")
    end

    local text = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    text:SetPoint("TOPLEFT", frame, "TOPLEFT", 16, -38)
    text:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -16, 16)
    text:SetJustifyH("LEFT")
    text:SetJustifyV("TOP")
    frame.breakdownText = text

    self.historyBreakdownFrame = frame
end

function GoldTracker:OpenHistoryLootBreakdownWindow(sessionID)
    local session = self:GetHistorySessionByID(sessionID)
    if not session then
        return
    end

    self:CreateHistoryLootBreakdownWindow()
    local frame = self.historyBreakdownFrame
    frame.selectedSessionID = sessionID

    local selectedLocationKey = DETAILS_LOCATION_FILTER_ALL
    if self.historyFrame and self.historyFrame.view == "details" and self.historyFrame.selectedSessionID == sessionID then
        selectedLocationKey = self.historyFrame.detailsLocationFilterKey or DETAILS_LOCATION_FILTER_ALL
    end

    local model = NewHistorySessionModel(session)
    local summary = BuildHistoryDetailsSummary(session, selectedLocationKey)
    local data = {
        ahTracked = 0,
        soulbound = 0,
        vendorOnly = 0,
        craftingReagent = 0,
        totalItems = 0,
    }

    for _, loot in ipairs(session.itemLoots or {}) do
        if model:EntryMatchesLocation(loot, selectedLocationKey, session) then
            local quantity = math.max(0, math.floor((tonumber(loot and loot.quantity) or 0) + 0.5))
            data.totalItems = data.totalItems + quantity
            if loot.isCraftingReagent == true then
                data.craftingReagent = data.craftingReagent + quantity
            end
            if loot.isSoulbound == true then
                data.soulbound = data.soulbound + quantity
            elseif loot.ahTracked == true then
                data.ahTracked = data.ahTracked + quantity
            else
                data.vendorOnly = data.vendorOnly + quantity
            end
        end
    end

    local locationLabel = "All"
    if selectedLocationKey ~= DETAILS_LOCATION_FILTER_ALL and self.historyFrame and self.historyFrame.detailsLocationOptions then
        for _, option in ipairs(self.historyFrame.detailsLocationOptions) do
            if option.key == selectedLocationKey then
                locationLabel = option.label
                break
            end
        end
    end

    frame.breakdownText:SetText(string.format(
        "Session: %s\nLocation: %s\n\nTotal value: %s\nRaw gold: %s\nAH value: %s\nVendor item value: %s\n\nTotal item quantity: %d\nAH-tracked item quantity: %d\nVendor-only item quantity: %d\nBound item quantity: %d\nCrafting reagent quantity: %d",
        session.name or "Session",
        locationLabel,
        self:FormatMoney(tonumber(summary.totalValue) or 0),
        self:FormatMoney(tonumber(summary.rawGold) or 0),
        self:FormatMoney(tonumber(summary.itemsValue) or 0),
        self:FormatMoney(tonumber(summary.itemsRawGold) or 0),
        data.totalItems,
        data.ahTracked,
        data.vendorOnly,
        data.soulbound,
        data.craftingReagent
    ))

    frame:Show()
    frame:Raise()
end

function GoldTracker:OpenHistorySessionDetails(sessionID)
    local session = self:GetHistorySessionByID(sessionID)
    if not session then
        return
    end

    self:CreateHistoryWindow()
    self:ShowHistoryDetailsView(sessionID)
    self.historyFrame:Show()
end
