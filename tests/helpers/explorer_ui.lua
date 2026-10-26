-- Native widgets are stubbed; Explorer and its data access paths remain real.
local loader = require("tests.helpers.addon_loader")
local M = {}
local function noop() end
local methods = {}
for name in ("SetPoint ClearAllPoints SetAllPoints SetFrameStrata SetFrameLevel SetToplevel "
    .. "SetMovable SetResizable SetResizeBounds EnableMouse RegisterForDrag SetClampedToScreen "
    .. "RegisterForClicks SetColorTexture SetTextColor SetJustifyH SetWordWrap EnableMouseWheel "
    .. "SetScrollChild SetAutoFocus SetNumeric SetClipsChildren SetOrientation SetMinMaxValues "
    .. "SetValue SetValueStep SetObeyStepOnDrag SetStatusBarTexture SetStatusBarColor RegisterEvent "
    .. "Raise StopMovingOrSizing SetSelected SetPalette SetEnabled SetAlpha SetChecked SetIgnoreParentAlpha "
    .. "SetIgnoreParentScale SetMouseClickEnabled SetMouseMotionEnabled UpdateScrollChildRect"):gmatch("%S+") do
    methods[name] = noop
end
for name in ("SetMultiLine SetMaxLetters SetFontObject ClearFocus SetFocus HighlightText"):gmatch("%S+") do
    methods[name] = noop
end
function methods:GetStringHeight() return 24 end
function methods:GetFont() return "font", 12, "" end
function methods:GetNumLines() return 2 end
function methods:GetSpacing() return 0 end
function methods:SetEnabled(enabled) self.enabled = enabled end
function methods:SetScript(name, callback) self.scripts[name] = callback end
function methods:GetScript(name) return self.scripts[name] end
function methods:GetParent() return self.parent end
function methods:SetParent(parent) self.parent = parent end
function methods:GetName() return self.name end
function methods:GetFrameLevel() return 1 end
function methods:GetFrameStrata() return "DIALOG" end
function methods:SetSize(width, height) self.width, self.height = width, height end
function methods:SetWidth(width) self.width = width end
function methods:SetHeight(height) self.height = height end
function methods:GetWidth() return self.width or 1100 end
function methods:GetHeight() return self.height or 500 end
function methods:SetText(text) self.textValue = text end
function methods:GetText() return self.textValue or "" end
function methods:GetStringWidth() return #(self.textValue or "") * 6 end
function methods:HasFocus() return false end
function methods:GetVerticalScroll() return 0 end
function methods:GetVerticalScrollRange() return 0 end
function methods:SetVerticalScroll() end
function methods:IsShown() return self.shown end
function methods:Show()
    local wasShown = self.shown
    self.shown = true
    if not wasShown and self.scripts.OnShow then self.scripts.OnShow(self) end
end
function methods:Hide()
    local wasShown = self.shown
    self.shown = false
    if wasShown and self.scripts.OnHide then self.scripts.OnHide(self) end
end
function methods:SetShown(shown) if shown then self:Show() else self:Hide() end end
local function widget(_, name, parent)
    return setmetatable({ name = name, parent = parent, shown = true, scripts = {} }, { __index = methods })
end
function methods:CreateTexture() return widget(nil, nil, self) end
function methods:CreateFontString() return widget(nil, nil, self) end

function M.with_ui(ns, callback)
    local theme = ns.JanisTheme
    local overrides = {
        CreatePanel = function(_, parent) return widget(nil, nil, parent) end,
        CreateButton = function(_, parent)
            local result = widget(nil, nil, parent)
            result.label = result:CreateFontString()
            return result
        end,
        ApplyWindowChrome = function(_, frame)
            frame.chrome = widget(nil, nil, frame)
            return frame.chrome
        end,
        CreateResizeButton = noop,
        RegisterSpecialFrame = noop,
        LayoutExplorerTabs = noop,
        LayoutExplorerActionButtons = noop,
        GetRequiredTextColumnWidth = function(_, _, _, minimum) return minimum end,
        SetProgressBarProgress = noop,
    }
    local previous = {}
    for key, value in pairs(overrides) do previous[key], theme[key] = theme[key], value end
    local ok, err = pcall(function()
        loader.with_globals({
            CreateFrame = widget,
            UIParent = widget(),
            GameTooltip = {
                Hide = noop, Show = noop, SetOwner = noop, ClearLines = noop,
                SetHyperlink = noop, AddLine = noop, AddDoubleLine = noop,
                NumLines = function() return 1 end,
            },
            GetMoneyString = tostring,
            UIDropDownMenu_SetWidth = noop,
            UIDropDownMenu_SetText = noop,
            UIDropDownMenu_SetSelectedValue = noop,
            UIDropDownMenu_Initialize = function(frame, initialize)
                frame.initialize = initialize
                initialize(frame, 1)
            end,
            UIDropDownMenu_CreateInfo = function() return {} end,
            UIDropDownMenu_AddButton = noop,
        }, callback)
    end)
    for key in pairs(overrides) do theme[key] = previous[key] end
    if not ok then error(err, 0) end
end
return M
