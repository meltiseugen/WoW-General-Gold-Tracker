local loader = require("tests.helpers.addon_loader")
local options = require("tests.helpers.options_ui")
local M = {}

function M.with_ui(callback, skin)
    loader.with_globals({ date = os.date, time = function() return 2000 end }, function()
        options.with_ui(function(addon, ns, widgets)
            local create = CreateFrame
            local function widget(...)
                local result = create(...)
                function result:SetMultiLine(value) self.multiLine = value end
                function result:HighlightText() self.highlighted = true end
                if result.kind == "ScrollFrame" then
                    local setScroll = result.SetVerticalScroll
                    function result:SetVerticalScroll(value)
                        setScroll(self, value)
                        if self.scripts.OnVerticalScroll then self.scripts.OnVerticalScroll(self, value) end
                    end
                end
                return result
            end
            local theme = ns.JanisTheme
            local panel, chrome = theme.CreatePanel, theme.ApplyWindowChrome
            function theme:CreatePanel(parent, bg, border)
                local result = panel(self, parent)
                result.colorTexture, result.borderColor = self:GetColor(bg), self:GetColor(border)
                result.bgFile = self.backdrops[bg] and self.backdrops[bg].bgFile
                return result
            end
            function theme:ApplyWindowChrome(parent, title, spec)
                local result = chrome(self, parent)
                result.bgFile = self.backdrops.chrome and self.backdrops.chrome.bgFile
                parent.headerTitleText = result:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
                parent.headerTitleText:SetText(title)
                parent.headerTitleText:SetPoint("TOPLEFT", result, "TOPLEFT", 16, -12)
                parent.headerTitleText:SetWidth(300)
                local close = widget("Button", nil, result)
                close:SetText("X")
                close:SetSize(24, 24)
                close:SetPoint("TOPRIGHT", result, "TOPRIGHT", -8, -8)
                close:SetScript("OnClick", function() parent:Hide() end)
                parent[spec.closeButtonKey] = close
                return result
            end
            loader.with_globals({ CreateFrame = widget }, function()
                for _, path in ipairs({ "Core/Diagnostics.lua", "UI/DiagnosisWindow.lua" }) do loader.load_module(path, addon, ns) end
                addon.db.enableDiagnosticsPanel = true
                addon.session = {
                    active = true, name = "Test session", startTime = 1000, valueSourceLabel = "Market Value",
                    diagnosisSnapshot = addon:CreateDiagnosisSnapshot(1100, 1000),
                }
                addon.GetSessionElapsedSeconds = function() return 900 end
                addon.GetCurrentValueSource = function() return { label = "Market Value" } end
                addon.GetHistorySessionByID = function(self, id) return self.savedSessions and self.savedSessions[id] end
                addon.Print = function(self, value) self.lastMessage = value end
                addon:OpenDiagnosisWindow()
                callback(addon, ns, widgets)
            end)
        end, 1000, skin)
    end)
end

M.click = options.click
return M
