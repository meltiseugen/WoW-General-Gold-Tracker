local loader = require("tests.helpers.addon_loader")
local options = require("tests.helpers.options_ui")
local M = {}
local function noop() end

function M.with_ui(callback, width, skin)
    loader.with_globals({
        date = os.date, time = os.time, ACCEPT = "Accept", CANCEL = "Cancel",
        GetMoneyString = function(value) return string.format("%dg %ds %dc", math.floor(value / 10000), math.floor(value / 100) % 100, value % 100) end,
        StaticPopupDialogs = {}, CloseDropDownMenus = noop,
        StaticPopup_Show = function(key, _, _, data) M.popup = { key = key, data = data } end,
        ToggleDropDownMenu = function(_, _, menu) M.menu = {}; menu.initialize(menu, 1) end,
        UIDropDownMenu_AddButton = function(info) M.menu[#M.menu + 1] = info end,
    }, function()
        options.with_ui(function(addon, ns, widgets)
            local create = CreateFrame
            local function widget(...)
                local w = create(...)
                function w:RegisterForClicks() end
                function w:SetMultiLine() end
                function w:GetSize() return self:GetWidth(), self:GetHeight() end
                local makeFont = w.CreateFontString
                local makeTexture = w.CreateTexture
                function w:CreateTexture(name, layer, ...)
                    local texture = makeTexture(self, name, layer, ...)
                    texture.drawLayer = layer
                    return texture
                end
                function w:CreateFontString(...)
                    local text = makeFont(self, ...)
                    local measure = text.GetStringHeight
                    function text:SetWordWrap(value) self.wrap = value end
                    function text:GetStringHeight()
                        if self.wrap == false then
                            local _, lines = (self.text or ""):gsub("\n", "")
                            return (lines + 1) * ((self.fontSize or 12) + 2)
                        end
                        return measure(self)
                    end
                    local width = text.GetStringWidth
                    function text:GetStringWidth()
                        if _G.HISTORY_MEASURE_WIDTH then return _G.HISTORY_MEASURE_WIDTH(self.text or "",self.fontSize or 12) end
                        return width(self)
                    end
                    return text
                end
                return w
            end
            local theme = ns.JanisTheme
            local panel = theme.CreatePanel
            function theme:CreatePanel(parent, bg, border)
                local result = panel(self, parent, bg, border)
                result.backdropKey = type(bg) == "string" and bg or "panel"
                return result
            end
            local chrome = theme.ApplyWindowChrome
            function theme:ApplyWindowChrome(parent, title, spec)
                local panel = chrome(self, parent)
                panel.backdropKey = "chrome"
                local bar = widget("Frame", nil, panel)
                bar:SetPoint("TOPLEFT", panel, "TOPLEFT", 0, 0)
                bar:SetPoint("TOPRIGHT", panel, "TOPRIGHT", 0, 0)
                bar:SetHeight(36)
                parent.headerTitleText = bar:CreateFontString()
                parent.headerTitleText:SetText(title)
                parent.headerTitleText:SetPoint("TOPLEFT",bar,"TOPLEFT",12,-12)
                parent.headerTitleText:SetWidth(300)
                parent[spec.closeButtonKey] = widget("Button", nil, bar)
                parent[spec.closeButtonKey]:SetPoint("TOPRIGHT", bar, "TOPRIGHT", -8, -8)
                parent[spec.closeButtonKey]:SetSize(24,24)
                return panel, bar
            end
            theme.BringToFront = noop
            loader.with_globals({
                CreateFrame = widget,
                UIDropDownMenu_AddButton = function(info) M.menu=M.menu or {}; M.menu[#M.menu+1]=info end,
            }, function()
                for _, path in ipairs({ "Core/TableSort.lua", "Core/SessionData.lua", "Core/History.lua" }) do
                    assert(loadfile(path))("General-Gold-Tracker", ns)
                end
                addon.GetValueSourceLabel = function(_, _, fallback) return fallback or "Market Value" end
                addon.GetItemQualityFromLink = function() return 2 end
                addon.IsCraftingReagentItem = function() return false end
                for _, name in ipairs({ "HistoryConstants", "HistoryDateFilter", "HistorySessionModel", "HistoryFormatter", "HistoryDataService" }) do
                    assert(loadfile("UI/History/" .. name .. ".lua"))("General-Gold-Tracker", ns)
                end
                assert(loadfile("UI/HistoryWindow.lua"))("General-Gold-Tracker", ns)
                addon:CreateHistoryWindow()
                addon.historyFrame:SetSize(width or 1080,720)
                callback(addon, ns, widgets)
            end)
        end, width, skin)
    end)
end

return M
