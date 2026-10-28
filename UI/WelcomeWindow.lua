local _, NS = ...
local GoldTracker = NS.GoldTracker
local Theme = NS.JanisTheme
local function CreateFrame(...)
    return (NS.CreateThemedFrame or _G.CreateFrame)(...)
end

local function Text(parent, value, font, color)
    local text = parent:CreateFontString(nil, "OVERLAY", font or "GameFontHighlight")
    text:SetText(value)
    text:SetJustifyH("LEFT")
    text:SetWordWrap(true)
    text:SetTextColor(unpack(Theme:GetColor(color or "text")))
    return text
end

function GoldTracker:OpenWelcomeWindow()
    if self.welcomeFrame then
        self.welcomeFrame:Show()
        self.welcomeFrame:Raise()
        return
    end

    local addon = self
    local frame = CreateFrame("Frame", "GoldTrackerWelcomeFrame", UIParent)
    frame:SetSize(math.min(700, UIParent:GetWidth() - 40), math.min(650, UIParent:GetHeight() - 40))
    frame:SetPoint("CENTER", UIParent, "CENTER", 0, 20)
    frame:SetFrameStrata("DIALOG")
    frame:SetToplevel(true)
    frame:SetClampedToScreen(true)
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:Hide()
    local chrome = Theme:ApplyWindowChrome(frame, "Welcome to General Gold Tracker")
    Theme:RegisterSpecialFrame("GoldTrackerWelcomeFrame")
    local drag = CreateFrame("Frame", nil, frame)
    drag:SetPoint("TOPLEFT", chrome, "TOPLEFT", 8, -4)
    drag:SetPoint("TOPRIGHT", chrome, "TOPRIGHT", -44, -4)
    drag:SetHeight(36)
    drag:EnableMouse(true)
    drag:RegisterForDrag("LeftButton")
    drag:SetScript("OnDragStart", function() frame:Raise(); frame:StartMoving() end)
    drag:SetScript("OnDragStop", function() frame:StopMovingOrSizing() end)

    local title = Text(chrome, "Choose your Explorer modules", "GameFontNormalLarge", "titleText")
    title:SetPoint("TOPLEFT", chrome, "TOPLEFT", 20, -54)
    title:SetPoint("TOPRIGHT", chrome, "TOPRIGHT", -20, -54)
    local intro = Text(chrome, "Each module adds an Explorer tab. The gold tracker is always available. Change your choices anytime in Options > Modules.", "GameFontHighlightSmall", "textMuted")
    intro:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -10)
    intro:SetPoint("TOPRIGHT", title, "BOTTOMRIGHT", 0, -10)

    local scroll = CreateFrame("ScrollFrame", nil, chrome, "UIPanelScrollFrameTemplate")
    scroll:SetPoint("TOPLEFT", intro, "BOTTOMLEFT", 0, -16)
    scroll:SetPoint("BOTTOMRIGHT", chrome, "BOTTOMRIGHT", -38, 108)
    scroll:EnableMouseWheel(true)
    scroll:SetScript("OnMouseWheel", function(self, delta)
        self:SetVerticalScroll(math.max(0, math.min(self:GetVerticalScrollRange(), self:GetVerticalScroll() - delta * 40)))
    end)
    frame.scrollFrame = scroll
    local content = CreateFrame("Frame", nil, scroll)
    scroll:SetScrollChild(content)
    frame.moduleChecks = {}
    for index, module in ipairs(self:GetExplorerModuleDefinitions()) do
        local row = CreateFrame("Frame", nil, content)
        row:SetPoint("TOPLEFT", content, "TOPLEFT", 0, -(index - 1) * 62)
        row:SetPoint("TOPRIGHT", content, "TOPRIGHT", 0, -(index - 1) * 62)
        row:SetHeight(62)
        local check = CreateFrame("CheckButton", nil, row, "UICheckButtonTemplate")
        check:SetSize(28, 28)
        check:SetPoint("TOPLEFT", 0, 0)
        check:SetChecked(true)
        local label = Text(row, module.label, "GameFontNormal", "titleText")
        label:SetPoint("TOPLEFT", 36, -3)
        label:SetPoint("TOPRIGHT", -8, -3)
        local description = Text(row, module.description, "GameFontHighlightSmall", "textMuted")
        description:SetPoint("TOPLEFT", label, "BOTTOMLEFT", 0, -5)
        description:SetPoint("TOPRIGHT", label, "BOTTOMRIGHT", 0, -5)
        frame.moduleChecks[module.id] = check
    end
    content:SetHeight(#self:GetExplorerModuleDefinitions() * 62)
    local function layout() content:SetWidth(math.max(1, scroll:GetWidth())) end
    scroll:SetScript("OnSizeChanged", layout)
    layout()

    local hint = Text(chrome, "Skip or close this window to enable every module. Your saved data is kept when a module is disabled.", "GameFontHighlightSmall", "textMuted")
    hint:SetPoint("BOTTOMLEFT", chrome, "BOTTOMLEFT", 20, 66)
    hint:SetPoint("BOTTOMRIGHT", chrome, "BOTTOMRIGHT", -20, 66)
    local apply = Theme:CreateButton(chrome, 190, 28, "Use selected modules", "primary")
    apply:SetPoint("BOTTOMRIGHT", chrome, "BOTTOMRIGHT", -20, 22)
    apply:SetScript("OnClick", function()
        local selection = {}
        for id, check in pairs(frame.moduleChecks) do selection[id] = check:GetChecked() == true end
        addon:CompleteWelcomeSetup(selection)
    end)
    local skip = Theme:CreateButton(chrome, 190, 28, "Skip - enable everything", "neutral")
    skip:SetPoint("RIGHT", apply, "LEFT", -10, 0)
    skip:SetScript("OnClick", function() addon:CompleteWelcomeSetup() end)
    frame.applyButton, frame.skipButton = apply, skip
    frame:SetScript("OnHide", function()
        frame:StopMovingOrSizing()
        if addon:NeedsWelcomeSetup() then addon:CompleteWelcomeSetup() end
    end)
    self.welcomeFrame = frame
    frame:Show()
    frame:Raise()
end
