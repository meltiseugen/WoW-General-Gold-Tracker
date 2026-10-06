local loader = require("tests.helpers.addon_loader")

local function new_target(parent)
    local target = {
        parent = parent,
        points = {},
        scripts = {},
    }

    function target:EnableMouse(enabled)
        self.mouseEnabled = enabled
    end

    function target:SetPropagateMouseClicks(enabled)
        self.propagateMouseClicks = enabled
    end

    function target:SetPropagateMouseMotion(enabled)
        self.propagateMouseMotion = enabled
    end

    function target:SetPoint(...)
        self.points[#self.points + 1] = { ... }
    end

    function target:SetScript(event, callback)
        self.scripts[event] = callback
    end

    return target
end

describe("item tooltip targets", function()
    it("limits tooltip hover to the icon and item-name cell while preserving row input", function()
        local row = { id = "row" }
        local itemText = { id = "text" }
        local itemIcon = { id = "icon" }
        local createdTarget
        local enteredRow
        local enteredTarget

        loader.with_globals({
            CreateFrame = function(_, _, parent)
                createdTarget = new_target(parent)
                return createdTarget
            end,
        }, function()
            local addon = loader.load_module("Core/ItemTooltip.lua", {})
            local target = addon:CreateItemTooltipTarget(row, itemText, itemIcon, function(callbackRow, callbackTarget)
                enteredRow = callbackRow
                enteredTarget = callbackTarget
            end)

            assert.equals(row, target.parent)
            assert.is_true(target.mouseEnabled)
            assert.is_true(target.propagateMouseClicks)
            assert.is_true(target.propagateMouseMotion)
            assert.same({ "TOPLEFT", itemIcon, "TOPLEFT", 0, 0 }, target.points[1])
            assert.same({ "BOTTOMRIGHT", itemText, "BOTTOMRIGHT", 0, 0 }, target.points[2])

            target.scripts.OnEnter(target)
            assert.equals(row, enteredRow)
            assert.equals(target, enteredTarget)
        end)
    end)

    it("hides the tooltip on leave by default", function()
        local hidden = false
        local tooltip = {
            Hide = function()
                hidden = true
            end,
        }

        loader.with_globals({
            CreateFrame = function(_, _, parent)
                return new_target(parent)
            end,
            GameTooltip = tooltip,
        }, function()
            local addon = loader.load_module("Core/ItemTooltip.lua", {})
            local target = addon:CreateItemTooltipTarget({}, {}, nil, function() end)
            target.scripts.OnLeave(target)
        end)

        assert.is_true(hidden)
    end)
end)
