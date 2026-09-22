local loader = require("tests.helpers.addon_loader")

local function build_addon()
    return loader.load_module("Core/TableSort.lua", {})
end

describe("multi-column table sorting", function()
    local valid_keys = {
        name = true,
        value = true,
        quantity = true,
    }

    it("adds Shift-clicked columns without replacing the primary sort", function()
        local addon = build_addon()
        local frame = {
            sortKey = "value",
            sortAscending = false,
        }

        addon:ToggleTableSortCriterion(frame, "name", true, {
            validKeys = valid_keys,
            additive = true,
        })

        assert.same({
            { key = "value", ascending = false },
            { key = "name", ascending = true },
        }, frame.sortCriteria)
        assert.equals("value", frame.sortKey)
        assert.is_false(frame.sortAscending)
    end)

    it("toggles an existing secondary direction and replaces the chain on a normal click", function()
        local addon = build_addon()
        local frame = {
            sortKey = "value",
            sortAscending = false,
            sortCriteria = {
                { key = "value", ascending = false },
                { key = "name", ascending = true },
            },
        }

        addon:ToggleTableSortCriterion(frame, "name", true, {
            validKeys = valid_keys,
            additive = true,
        })
        assert.is_false(frame.sortCriteria[2].ascending)

        addon:ToggleTableSortCriterion(frame, "quantity", false, {
            validKeys = valid_keys,
            additive = false,
        })
        assert.same({
            { key = "quantity", ascending = false },
        }, frame.sortCriteria)
    end)

    it("normalizes duplicate and invalid saved criteria", function()
        local addon = build_addon()
        local frame = {
            sortCriteria = {
                { key = "value", ascending = false },
                { key = "invalid", ascending = true },
                { key = "value", ascending = true },
                { key = "name", ascending = true },
            },
        }

        assert.same({
            { key = "value", ascending = false },
            { key = "name", ascending = true },
        }, addon:GetTableSortCriteria(frame, "sortKey", "sortAscending", valid_keys))
    end)

    it("preserves the history header's descending, ascending, cleared cycle", function()
        local addon = build_addon()
        local frame = {}
        local options = {
            validKeys = valid_keys,
            additive = false,
            allowClear = true,
        }

        addon:ToggleTableSortCriterion(frame, "value", false, options)
        assert.same({ { key = "value", ascending = false } }, frame.sortCriteria)
        addon:ToggleTableSortCriterion(frame, "value", false, options)
        assert.same({ { key = "value", ascending = true } }, frame.sortCriteria)
        addon:ToggleTableSortCriterion(frame, "value", false, options)
        assert.same({}, frame.sortCriteria)
        assert.is_nil(frame.sortKey)
    end)

    it("adds multi-column instructions to sortable header tooltips", function()
        local addon = build_addon()
        local scripts = {}
        local lines = {}
        local button = {
            HookScript = function(_, event, callback)
                scripts[event] = callback
            end,
        }
        local tooltip = {
            SetOwner = function() end,
            AddLine = function(_, text)
                lines[#lines + 1] = text
            end,
            Show = function() end,
            Hide = function() end,
        }

        loader.with_globals({ GameTooltip = tooltip }, function()
            addon:AttachTableSortHeaderTooltip(button, "Value")
            scripts.OnEnter(button)
        end)

        assert.equals("Sort by Value", lines[1])
        assert.equals("Shift-click additional headers to add sorting levels.", lines[3])
    end)
end)
