local _, NS = ...
local GoldTracker = NS.GoldTracker
local Theme = NS.JanisTheme
local function CreateFrame(...)
    return (NS.CreateThemedFrame or _G.CreateFrame)(...)
end

local MIN_WIDTH, MIN_HEIGHT = 760, 480
local MAX_WIDTH, MAX_HEIGHT = 1320, 960
local SIDEBAR_WIDTH = 202

local function Text(parent, font, color)
    local text = parent:CreateFontString(nil, "OVERLAY", font or "GameFontHighlight")
    text:SetJustifyH("LEFT")
    text:SetWordWrap(true)
    text:SetTextColor(unpack(Theme:GetColor(color or "text")))
    if text.SetSpacing then text:SetSpacing(2) end
    return text
end

local function Scroll(parent)
    local scroll = CreateFrame("ScrollFrame", nil, parent, "UIPanelScrollFrameTemplate")
    scroll:EnableMouseWheel(true)
    scroll:SetScript("OnMouseWheel", function(self, delta)
        self:SetVerticalScroll(math.max(0, math.min(self:GetVerticalScrollRange(), self:GetVerticalScroll() - delta * 44)))
    end)
    local content = CreateFrame("Frame", nil, scroll)
    content:SetSize(1, 1)
    scroll:SetScrollChild(content)
    return scroll, content
end

local function SaveReadingPosition(frame)
    if frame.renderedTopicKey then
        frame.scrollPositions[frame.renderedTopicKey] = frame.scrollFrame:GetVerticalScroll()
    end
end

function GoldTracker:UpdateHelpWindow()
    local frame = self.helpFrame
    if not frame then return end

    local matches = self:SearchHelpTopics(frame.searchInput:GetText(), frame.topics)
    frame.matchingTopics = matches
    local visible, selected = {}, nil
    for _, topic in ipairs(matches) do
        visible[topic.key] = true
        if topic.key == frame.selectedTabKey then selected = topic end
    end
    if not selected and matches[1] then
        selected = matches[1]
        frame.selectedTabKey = selected.key
    end

    local navY, lastGroup = 0, nil
    local navWidth = math.max(1, frame.topicScroll:GetWidth() - 2)
    frame.topicContent:SetWidth(navWidth)
    for _, group in pairs(frame.groupLabels) do group:Hide() end
    for _, topic in ipairs(frame.topics) do
        local button = frame.tabButtons[topic.key]
        if visible[topic.key] then
            if lastGroup ~= topic.group then
                local group = frame.groupLabels[topic.group]
                group:ClearAllPoints()
                group:SetPoint("TOPLEFT", frame.topicContent, "TOPLEFT", 4, -navY - 6)
                group:SetWidth(navWidth - 8)
                group:Show()
                navY = navY + group:GetStringHeight() + 16
                lastGroup = topic.group
            end
            button:ClearAllPoints()
            button:SetPoint("TOPLEFT", frame.topicContent, "TOPLEFT", 0, -navY)
            button:SetWidth(navWidth)
            button.helpOffset = navY
            if button.SetSelected then button:SetSelected(selected == topic) end
            button:Show()
            navY = navY + 30
        else
            button:Hide()
        end
    end
    frame.topicContent:SetHeight(math.max(1, navY))
    frame.topicScroll:UpdateScrollChildRect()
    frame.topicScroll:SetVerticalScroll(math.min(frame.topicScroll:GetVerticalScroll(), frame.topicScroll:GetVerticalScrollRange()))
    frame.resultCount:SetText(string.format("%d / %d topics", #matches, #frame.topics))

    if frame.renderedTopicKey ~= (selected and selected.key) then SaveReadingPosition(frame) end
    local width = math.max(1, frame.scrollFrame:GetWidth() - 4)
    frame.scrollContent:SetWidth(width)
    local y = 0
    for _, card in ipairs(frame.sectionCards) do card:Hide() end
    if selected then
        frame.heading:SetText(selected.label)
        frame.summary:SetText(selected.summary)
        for index, section in ipairs(selected.sections) do
            local card = frame.sectionCards[index]
            if not card then
                card = Theme:CreatePanel(frame.scrollContent, "section", "chromeBorder")
                card.title = Text(card, "GameFontNormal", "titleText")
                card.body = Text(card)
                frame.sectionCards[index] = card
            end
            card:ClearAllPoints()
            card:SetPoint("TOPLEFT", frame.scrollContent, "TOPLEFT", 0, -y)
            card:SetWidth(width)
            card.title:ClearAllPoints()
            card.title:SetPoint("TOPLEFT", card, "TOPLEFT", 14, -12)
            card.title:SetWidth(width - 28)
            card.title:SetText(section.title)
            card.body:ClearAllPoints()
            card.body:SetPoint("TOPLEFT", card.title, "BOTTOMLEFT", 0, -9)
            card.body:SetWidth(width - 28)
            card.body:SetText(table.concat(section.bullets, "\n\n"))
            local height = math.ceil(card.title:GetStringHeight() + card.body:GetStringHeight() + 35)
            card:SetHeight(height)
            card:Show()
            y = y + height + 12
        end
    else
        frame.heading:SetText("No matching topics")
        frame.summary:SetText("Try fewer words, a feature name, or a task such as bank, resume, or fallback. Clear search to see the full guide.")
    end

    -- Anchor the article below the measured summary so narrow windows can wrap.
    frame.scrollFrame:ClearAllPoints()
    frame.scrollFrame:SetPoint("TOPLEFT", frame.summary, "BOTTOMLEFT", 0, -14)
    frame.scrollFrame:SetPoint("BOTTOMRIGHT", frame.bodyPanel, "BOTTOMRIGHT", -28, 14)
    frame.scrollContent:SetHeight(math.max(1, y))
    frame.scrollFrame:UpdateScrollChildRect()
    local nextKey = selected and selected.key
    local position = nextKey == frame.renderedTopicKey and frame.scrollFrame:GetVerticalScroll()
        or (nextKey and frame.scrollPositions[nextKey]) or 0
    frame.scrollFrame:SetVerticalScroll(math.max(0, math.min(position, frame.scrollFrame:GetVerticalScrollRange())))
    frame.renderedTopicKey = nextKey
end

function GoldTracker:SelectHelpTab(tabKey, resetScroll)
    local frame = self.helpFrame
    if not frame then return end
    SaveReadingPosition(frame)
    frame.selectedTabKey = frame.topicByKey[tabKey] and tabKey or "overview"
    if resetScroll then
        frame.scrollPositions[frame.selectedTabKey] = 0
        frame.renderedTopicKey = nil
    end
    self:UpdateHelpWindow()
end

function GoldTracker:CreateHelpWindow()
    if self.helpFrame then return end
    local addon = self
    local frame = CreateFrame("Frame", "GoldTrackerHelpFrame", UIParent)
    frame:SetSize(math.min(960, UIParent:GetWidth() - 32), math.min(700, UIParent:GetHeight() - 32))
    frame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    frame:SetFrameStrata("DIALOG")
    frame:SetToplevel(true)
    frame:SetClampedToScreen(true)
    frame:SetMovable(true)
    frame:SetResizable(true)
    frame:SetResizeBounds(MIN_WIDTH, MIN_HEIGHT, MAX_WIDTH, MAX_HEIGHT)
    frame:EnableMouse(true)
    frame:Hide()
    frame.selectedTabKey, frame.scrollPositions = "overview", {}
    frame.tabButtons, frame.groupLabels, frame.sectionCards = {}, {}, {}
    frame.topicByKey = {}
    local chrome = Theme:ApplyWindowChrome(frame, "Help & gold guide", { closeButtonKey = "helpCloseButton" })
    Theme:RegisterSpecialFrame("GoldTrackerHelpFrame")

    local drag = CreateFrame("Frame", nil, frame)
    drag:SetPoint("TOPLEFT", chrome, "TOPLEFT", 8, -4)
    drag:SetPoint("TOPRIGHT", chrome, "TOPRIGHT", -44, -4)
    drag:SetHeight(36)
    drag:EnableMouse(true)
    drag:RegisterForDrag("LeftButton")
    drag:SetScript("OnDragStart", function() frame:Raise(); frame:StartMoving() end)
    drag:SetScript("OnDragStop", function() frame:StopMovingOrSizing() end)
    frame:SetScript("OnMouseDown", function() frame:Raise() end)

    local searchLabel = Text(chrome, "GameFontNormal", "titleText")
    searchLabel:SetPoint("TOPLEFT", chrome, "TOPLEFT", 18, -54)
    searchLabel:SetText("Search the guide")
    local search = CreateFrame("EditBox", nil, chrome, "InputBoxTemplate")
    search:SetPoint("TOPLEFT", chrome, "TOPLEFT", 166, -48)
    search:SetPoint("TOPRIGHT", chrome, "TOPRIGHT", -180, -48)
    search:SetHeight(26)
    search:SetAutoFocus(false)
    search:SetMaxLetters(100)
    frame.searchInput = search
    local clear = Theme:CreateButton(chrome, 52, 26, "Clear", "neutral")
    clear:SetPoint("LEFT", search, "RIGHT", 8, 0)
    clear:SetScript("OnClick", function() search:SetText(""); search:ClearFocus() end)
    frame.clearSearchButton = clear
    frame.resultCount = Text(chrome, "GameFontHighlightSmall", "textMuted")
    frame.resultCount:SetPoint("LEFT", clear, "RIGHT", 12, 0)
    frame.resultCount:SetWidth(100)

    local sidebar = Theme:CreatePanel(frame, "panel", "chromeBorder")
    sidebar:SetPoint("TOPLEFT", chrome, "TOPLEFT", 12, -84)
    sidebar:SetPoint("BOTTOMLEFT", chrome, "BOTTOMLEFT", 12, 42)
    sidebar:SetWidth(SIDEBAR_WIDTH)
    frame.topicScroll, frame.topicContent = Scroll(sidebar)
    frame.topicScroll:SetPoint("TOPLEFT", sidebar, "TOPLEFT", 8, -8)
    frame.topicScroll:SetPoint("BOTTOMRIGHT", sidebar, "BOTTOMRIGHT", -25, 8)

    local body = Theme:CreatePanel(frame, "body", "chromeBorder")
    body:SetPoint("TOPLEFT", sidebar, "TOPRIGHT", 10, 0)
    body:SetPoint("BOTTOMRIGHT", chrome, "BOTTOMRIGHT", -12, 42)
    frame.bodyPanel = body
    frame.heading = Text(body, "GameFontNormalLarge", "titleText")
    frame.heading:SetPoint("TOPLEFT", body, "TOPLEFT", 16, -14)
    frame.heading:SetPoint("TOPRIGHT", body, "TOPRIGHT", -16, -14)
    frame.summary = Text(body, "GameFontHighlight", "textSoft")
    frame.summary:SetPoint("TOPLEFT", frame.heading, "BOTTOMLEFT", 0, -8)
    frame.summary:SetPoint("TOPRIGHT", frame.heading, "BOTTOMRIGHT", 0, -8)
    frame.scrollFrame, frame.scrollContent = Scroll(body)
    frame.scrollFrame:SetPoint("TOPLEFT", frame.summary, "BOTTOMLEFT", 0, -14)
    frame.scrollFrame:SetPoint("BOTTOMRIGHT", body, "BOTTOMRIGHT", -28, 14)

    local footer = Text(chrome, "GameFontHighlightSmall", "textMuted")
    footer:SetPoint("BOTTOMLEFT", chrome, "BOTTOMLEFT", 18, 17)
    footer:SetPoint("BOTTOMRIGHT", chrome, "BOTTOMRIGHT", -32, 17)
    footer:SetText("Search names and full topic text. Scroll each pane independently. Hover ? in Options for individual setting help.")

    frame.topics = self:GetHelpTopicDefinitions()
    for _, topic in ipairs(frame.topics) do
        frame.topicByKey[topic.key] = topic
        local topicKey = topic.key
        if not frame.groupLabels[topic.group] then
            local label = Text(frame.topicContent, "GameFontNormalSmall", "textMuted")
            label:SetText(topic.group)
            frame.groupLabels[topic.group] = label
        end
        local button = Theme:CreateButton(frame.topicContent, 160, 28, topic.label, "neutral")
        button:SetScript("OnClick", function() search:ClearFocus(); addon:SelectHelpTab(topicKey) end)
        frame.tabButtons[topic.key] = button
    end
    search:SetScript("OnTextChanged", function()
        local query = search:GetText()
        if not frame.searching and query:find("%S") then
            frame.preSearchKey = frame.selectedTabKey
            frame.searching = true
        elseif frame.searching and not query:find("%S") then
            frame.searching = false
            SaveReadingPosition(frame)
            frame.selectedTabKey = frame.preSearchKey or "overview"
        end
        frame.topicScroll:SetVerticalScroll(0)
        addon:UpdateHelpWindow()
    end)
    search:SetScript("OnEscapePressed", function() search:SetText(""); search:ClearFocus() end)
    search:SetScript("OnEnterPressed", function() search:ClearFocus() end)
    Theme:CreateResizeButton(frame, {
        minWidth = MIN_WIDTH, minHeight = MIN_HEIGHT, maxWidth = MAX_WIDTH, maxHeight = MAX_HEIGHT,
        onResizeStop = function() addon:UpdateHelpWindow() end,
    })
    frame:SetScript("OnSizeChanged", function()
        if not frame.isManualResizing then addon:UpdateHelpWindow() end
    end)
    frame:SetScript("OnShow", function() addon:UpdateHelpWindow() end)
    frame:SetScript("OnHide", function()
        SaveReadingPosition(frame)
        search:ClearFocus()
        frame:StopMovingOrSizing()
    end)
    self.helpFrame = frame
end

function GoldTracker:OpenHelpWindow(tabKey)
    self:CreateHelpWindow()
    local frame = self.helpFrame
    -- Refresh small text definitions so the current-pricing note follows settings.
    frame.topics = self:GetHelpTopicDefinitions()
    for _, topic in ipairs(frame.topics) do frame.topicByKey[topic.key] = topic end
    if tabKey then
        frame.searchInput:SetText("")
        self:SelectHelpTab(tabKey, true)
        local button = frame.tabButtons[frame.selectedTabKey]
        if button then
            frame.topicScroll:SetVerticalScroll(math.max(0, math.min(button.helpOffset or 0, frame.topicScroll:GetVerticalScrollRange())))
        end
    end
    frame:Show()
    frame:Raise()
    self:UpdateHelpWindow()
end

function GoldTracker:ToggleHelpWindow(tabKey)
    self:CreateHelpWindow()
    if self.helpFrame:IsShown() then self.helpFrame:Hide() else self:OpenHelpWindow(tabKey) end
end

function GoldTracker:OpenTSMRealmSetupHelp()
    -- Explicit entry points clear search and reveal the setup steps at the top.
    self:OpenHelpWindow("values")
end
