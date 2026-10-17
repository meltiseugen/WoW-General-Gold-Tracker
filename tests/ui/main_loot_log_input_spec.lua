local loader = require("tests.helpers.addon_loader")
local unpack_values = table.unpack or unpack
local ITEM_LINK = "|cnIQ3:|Hitem:263462::::::::90:254:::::::::|h[Thalassian Herbalist's Notes]|h|r"

-- Model input flags independently: EnableMouse changes both, while a tooltip
-- overlay must keep clicks disabled even after transparent mode restores input.
local function new_region(parent)
    local region = { parent = parent, children = {}, scripts = {}, clicks = false, motion = false }
    if parent then
        parent.children[#parent.children + 1] = region
    end
    function region:EnableMouse(enabled) self.clicks, self.motion = enabled, enabled end
    function region:SetMouseClickEnabled(enabled) self.clicks = enabled end
    function region:SetMouseMotionEnabled(enabled) self.motion = enabled end
    function region:IsMouseClickEnabled() return self.clicks end
    function region:IsMouseMotionEnabled() return self.motion end
    function region:IsMouseEnabled() return self.clicks or self.motion end
    function region:GetChildren() return unpack_values(self.children) end
    function region:SetScript(event, callback) self.scripts[event] = callback end
    function region:CreateTexture() return new_region() end
    function region:CreateFontString() return new_region() end
    function region:SetText(text) self.text = text end
    function region:SetHeight(height) self.height = height end
    function region:SetWidth(width) self.width = width end
    function region:GetWidth() return self.width or 600 end
    function region:SetPropagateMouseClicks() error("ADDON_ACTION_BLOCKED: SetPropagateMouseClicks") end
    function region:SetPropagateMouseMotion() error("ADDON_ACTION_BLOCKED: SetPropagateMouseMotion") end
    for _, method in ipairs({
        "SetHitRectInsets", "SetAllPoints", "SetColorTexture", "SetPoint", "SetSize",
        "SetJustifyH", "SetTextColor", "SetWordWrap", "SetAlpha", "ClearAllPoints",
        "SetShown", "Show", "Hide", "SetTexture",
    }) do
        region[method] = function() end
    end
    return region
end

local function with_loot_window(transparent, callback)
    local controlDown = false
    local tooltip = {
        SetOwner = function(self, owner) self.owner = owner end,
        SetHyperlink = function(self, link) self.link = link end,
        Show = function(self) self.shown = true end,
        Hide = function(self) self.shown = false end,
    }
    loader.with_globals({
        CreateFrame = function(_, _, parent) return new_region(parent) end,
        InCombatLockdown = function() return true end,
        IsControlKeyDown = function() return controlDown end,
        date = function() return "12:34:56" end,
        GameTooltip = tooltip,
    }, function()
        local frame = new_region()
        frame:EnableMouse(true)
        frame.logContent = new_region(frame)
        local addon = loader.load_module("UI/MainWindow.lua", {
            mainFrame = frame,
            db = { mainWindowTransparent = transparent },
            FormatMoney = function(_, value) return tostring(value) end,
        }, { JanisTheme = {} })
        addon.AddFarmActionTooltip = function() end
        addon.HandleFarmActionClick = function() return false end
        addon:ApplyMainWindowAlpha()
        callback(addon, tooltip, function(value)
            controlDown = value
            addon:ApplyMainWindowAlpha()
        end)
    end)
end

describe("main loot log input during combat", function()
    it("creates and reuses loot rows with working tooltips and row clicks", function()
        with_loot_window(false, function(addon, tooltip)
            addon:AddLootItemLogEntry(ITEM_LINK, 2, 250, "", { forceVisible = true })
            local row = addon.mainFrame.logRows[1]
            local target = row.itemTooltipTarget
            assert.equals(1, #addon.mainLootLogEntries)
            assert.equals(ITEM_LINK, row.itemLink)
            assert.is_true(row.clicks)
            assert.is_false(target.clicks)
            assert.is_true(target.motion)
            assert.equals(row, addon:GetMainLootLogRow(1))

            target.scripts.OnEnter(target)
            assert.equals(target, tooltip.owner)
            assert.equals(ITEM_LINK, tooltip.link)
            assert.is_true(tooltip.shown)
            target.scripts.OnLeave(target)
            assert.is_false(tooltip.shown)

            local clickedRow
            addon.HandleModifiedItemClickIfModified = function(_, clicked) clickedRow = clicked end
            row.scripts.OnMouseUp(row, "LeftButton")
            assert.equals(row, clickedRow)
        end)
    end)

    it("preserves hover-only targets through Ctrl and transparent-mode changes", function()
        with_loot_window(true, function(addon, _, set_control)
            addon:AddLootItemLogEntry(ITEM_LINK, 1, 125, "", { forceVisible = true })
            local row = addon.mainFrame.logRows[1]
            local target = row.itemTooltipTarget
            assert.is_false(row.clicks)
            assert.is_false(target.clicks)
            assert.is_false(target.motion)

            for _ = 1, 2 do
                set_control(true)
                assert.is_true(row.clicks)
                assert.is_true(row.motion)
                assert.is_false(target.clicks)
                assert.is_true(target.motion)
                set_control(false)
                assert.is_false(row.clicks)
                assert.is_false(target.clicks)
                assert.is_false(target.motion)
            end

            addon.db.mainWindowTransparent = false
            addon:ApplyMainWindowAlpha()
            assert.is_true(row.clicks)
            assert.is_false(target.clicks)
            assert.is_true(target.motion)
            assert.is_nil(target.goldTrackerMouseEnabledBeforeClickThrough)
        end)
    end)
end)
