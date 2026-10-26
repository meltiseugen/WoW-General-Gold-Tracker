-- Headless native-widget substitute. Real page definitions, setters, search,
-- layout, alerts, and namespace defaults run unchanged. Geometry is also used
-- by the offline preview; this does not model the WoW renderer or input stack.
local loader = require("tests.helpers.addon_loader")
local base = require("tests.helpers.map_ui")
local M = {}
local function clone(value)
    if type(value) ~= "table" then return value end
    local result = {}
    for k, v in pairs(value) do result[k] = clone(v) end
    return result
end

function M.with_ui(callback, width, skin)
    local widgets, ns = {}, {}
    local root
    local function widget(kind, name, parent, template)
        local frame = base.widget(kind, name, parent)
        widgets[#widgets + 1] = frame
        frame.kind, frame.name, frame.template = kind, name, template
        frame.width = kind == "Button" and 100 or nil
        frame.height = kind == "Button" and 24 or nil
        if template == "UIDropDownMenuTemplate" then frame.width, frame.height = 240, 32 end
        function frame:GetName() return self.name end
        function frame:GetParent() return self.parent end
        function frame:SetToplevel() end
        function frame:SetResizable() end
        function frame:SetResizeBounds() end
        function frame:SetNumeric() end
        function frame:SetMinMaxValues(low, high) self.min, self.max = low, high end
        function frame:SetValueStep() end
        function frame:SetObeyStepOnDrag() end
        function frame:SetValue(value)
            self.value = value
            if self.scripts.OnValueChanged then self.scripts.OnValueChanged(self, value) end
        end
        function frame:SetChecked(v) self.checked = v end
        function frame:GetChecked() return self.checked end
        function frame:HasFocus() return self.focused == true end
        function frame:ClearFocus()
            local hadFocus = self.focused
            self.focused = false
            if hadFocus and self.scripts.OnEditFocusLost then self.scripts.OnEditFocusLost(self) end
        end
        function frame:SetBackdrop(v) self.backdrop = v end
        function frame:SetBackdropColor(...) self.colorTexture = { ... } end
        function frame:SetBackdropBorderColor(...) self.borderColor = { ... } end
        function frame:SetPoint(point, relative, relativePoint, x, y)
            if type(relative) == "number" then
                x, y, relative, relativePoint = relative, relativePoint, self.parent, point
            elseif relative == nil then
                relative, relativePoint, x, y = self.parent, point, 0, 0
            end
            for i, p in ipairs(self.points) do if p[1] == point then table.remove(self.points, i); break end end
            self.points[#self.points + 1] = { point, relative or self.parent, relativePoint or point, x or 0, y or 0 }
        end
        local function factor(point, axis)
            if axis == "x" then return point:find("LEFT") and 0 or point:find("RIGHT") and 1 or 0.5 end
            return point:find("TOP") and 0 or point:find("BOTTOM") and 1 or 0.5
        end
        function frame:Bounds(axis)
            if self == root then return 0, axis == "x" and 1600 or 1000 end
            if self.allPoints then return self.allPoints:Bounds(axis) end
            local size = axis == "x" and self.width or self.height
            if axis == "y" and self.kind == "FontString" then size = self:GetStringHeight() end
            local first, second
            for _, p in ipairs(self.points) do
                local r = p[2]
                if r then
                    local pos, extent = r:Bounds(axis)
                    local v = pos + factor(p[3], axis) * extent + (axis == "x" and p[4] or -p[5])
                    local candidate = { factor(p[1], axis), v }
                    if not first then first = candidate elseif candidate[1] ~= first[1] then second = candidate end
                end
            end
            if second then size = (second[2] - first[2]) / (second[1] - first[1]) end
            size = size or (axis == "x" and 100 or 24)
            return first and first[2] - first[1] * size or 0, size
        end
        function frame:GetWidth() local _, w = self:Bounds("x"); return w end
        function frame:GetHeight() local _, h = self:Bounds("y"); return h end
        function frame:GetStringHeight()
            local w = math.max(1, self:GetWidth())
            if _G.OPTIONS_MEASURE then return _G.OPTIONS_MEASURE(self.text or "", w, self.fontSize or 12) end
            return math.max(1, math.ceil(#(self.text or "") * 6 / w)) * 14
        end
        function frame:UpdateScrollChildRect() end
        function frame:SetScrollChild(child)
            self.child = child
            child:SetPoint("TOPLEFT", self, "TOPLEFT", 0, 0)
        end
        function frame:GetVerticalScrollRange() return math.max(0, self.child:GetHeight() - self:GetHeight()) end
        function frame:CreateFontString(_, _, font)
            local result = widget("FontString", nil, self)
            result.fontSize = font == "GameFontNormalLarge" and 16 or font == "GameFontHighlightSmall" and 11 or 12
            result.color = ns.JanisTheme and (font and font:find("Normal") and ns.JanisTheme.colors.titleText or ns.JanisTheme.colors.text)
            return result
        end
        function frame:CreateTexture() return widget("Texture", nil, self) end
        return frame
    end
    root = widget("Root")
    local function noop() end
    local tooltip = { lines = {}, shown = false }
    function tooltip:SetOwner(owner) self.owner = owner end
    function tooltip:IsOwned(owner) return self.owner == owner end
    function tooltip:SetText(text) self.lines = { text } end
    function tooltip:AddLine(text) self.lines[#self.lines + 1] = text end
    function tooltip:Show() self.shown = true end
    function tooltip:Hide() self.shown = false end
    loader.with_globals({
        CreateFrame = widget, UIParent = root, UISpecialFrames = {},
        GameTooltip = tooltip,
        Settings = { RegisterCanvasLayoutCategory = function() return {} end, RegisterAddOnCategory = noop },
        UIDropDownMenu_SetWidth = function(frame, w) frame.width = w + 32 end,
        UIDropDownMenu_Initialize = function(frame, initialize) frame.initialize = initialize end,
        UIDropDownMenu_SetSelectedValue = function(frame, value) frame.selectedValue = value end,
        UIDropDownMenu_SetText = function(frame, text) frame.dropdownText = text end,
        UIDropDownMenu_EnableDropDown = function(frame) frame.enabled = true end,
        UIDropDownMenu_DisableDropDown = function(frame) frame.enabled = false end,
        UIDropDownMenu_CreateInfo = function() return {} end,
        UIDropDownMenu_AddButton = function(info) M.menu[#M.menu + 1] = info end,
        ReloadUI = noop,
    }, function()
        assert(loadfile("Libs/JanisTheme-1.0/JanisTheme-1.0.lua"))()
        assert(loadfile("Core/Namespace.lua"))("General-Gold-Tracker", ns)
        local addon = ns.GoldTracker
        assert(loadfile("Core/Alerts.lua"))("General-Gold-Tracker", ns)
        addon.db = clone(addon.DEFAULTS)
        addon.db.visualTheme = skin or "midnight"
        for _, path in ipairs({ "UI/Theme.lua", "UI/VisualThemes.lua" }) do
            assert(loadfile(path))("General-Gold-Tracker", ns)
        end
        addon:InitializeVisualTheme()
        local theme = ns.JanisTheme
        function theme:CreatePanel(parent)
            local panel = widget("Panel", nil, parent)
            panel.colorTexture = self.colors.panel
            return panel
        end
        function theme:CreateButton(parent, w, h, text, palette)
            local button = widget("Button", nil, parent)
            button:SetSize(w, h); button:SetText(text); button.palette = palette
            return button
        end
        function theme:ApplyWindowChrome(parent)
            local chrome = widget("Panel", nil, parent)
            chrome:SetPoint("TOPLEFT", parent, "TOPLEFT", 6, -6)
            chrome:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", -6, 6)
            chrome.colorTexture = self.colors.chrome
            return chrome
        end
        function theme:CreateResizeButton() end
        function theme:RegisterSpecialFrame() end
        function theme:ApplySelectorArt() end
        for _, path in ipairs({ "Core/AltTracker.lua", "UI/OptionsPages.lua", "UI/OptionsLayout.lua", "UI/OptionsPanel.lua" }) do
            assert(loadfile(path))("General-Gold-Tracker", ns)
        end
        addon.UpdateMainWindow, addon.RefreshMainWindowLayout = noop, noop
        addon.RefreshHistoryButtonVisibility, addon.RefreshDiagnosisButtonVisibility = noop, noop
        addon.ClearPendingReloadSession, addon.OnLootClosed = noop, noop
        setmetatable(ns, { __index = function(_, key)
            if key == "RareDropsData" or key == "FarmCatalog" or key == "MaterialFarmingSpots" then
                error("Options accessed a large catalog: " .. key)
            end
        end })
        addon:CreateOptionsPanel()
        addon.optionsWindow:SetSize(width or 1000, 720)
        addon.optionsWindow:Show()
        addon.optionsWindow.reflow()
        callback(addon, ns, widgets)
    end)
end

function M.click(frame)
    assert(frame.enabled ~= false, "control is disabled")
    if frame.scripts.OnClick then frame.scripts.OnClick(frame) end
end

function M.input(frame, text)
    frame:SetFocus(); frame:SetText(text); frame:ClearFocus()
end

function M.choose(frame, id)
    M.menu = {}
    frame.initialize(frame, 1)
    for _, item in ipairs(M.menu) do if item.value == id then item.func(); return end end
    error("missing dropdown choice " .. tostring(id))
end

function M.row(addon, key)
    for _, page in ipairs(addon.optionsPages) do
        for _, section in ipairs(page.sections) do
            for _, row in ipairs(section.rows) do if row.spec.key == key then return row, page end end
        end
    end
    error("missing setting " .. tostring(key))
end

return M
