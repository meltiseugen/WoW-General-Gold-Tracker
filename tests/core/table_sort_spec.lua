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

    it("removes individual sorting levels while preserving the remaining order and directions", function()
        local addon = build_addon()
        local frame = {}
        local options = { validKeys = valid_keys, additive = true, mouseButton = "RightButton" }
        addon:SetTableSortCriteria(frame, {
            { key = "value", ascending = false },
            { key = "name", ascending = true },
            { key = "quantity", ascending = false },
        }, "sortKey", "sortAscending", valid_keys)

        addon:ToggleTableSortCriterion(frame, "name", true, options)
        assert.same({
            { key = "value", ascending = false },
            { key = "quantity", ascending = false },
        }, frame.sortCriteria)
        local _, priority = addon:GetTableSortCriterion(frame.sortCriteria, "quantity")
        assert.equals(2, priority)

        addon:ToggleTableSortCriterion(frame, "value", false, options)
        assert.same({ { key = "quantity", ascending = false } }, frame.sortCriteria)
        assert.equals("quantity", frame.sortKey)
        assert.is_false(frame.sortAscending)

        addon:ToggleTableSortCriterion(frame, "quantity", false, options)
        assert.same({}, frame.sortCriteria)
        assert.is_nil(frame.sortKey)
        assert.same({}, addon:GetTableSortCriteria(frame, "sortKey", "sortAscending", valid_keys))
    end)

    it("clears legacy inventory sort fields and ignores inactive columns", function()
        local addon = build_addon()
        local frame = { inventorySortKey = "value", inventorySortAscending = true }
        local options = {
            validKeys = valid_keys, additive = true, mouseButton = "RightButton",
            sortKeyField = "inventorySortKey", sortAscendingField = "inventorySortAscending",
        }
        addon:ToggleTableSortCriterion(frame, "name", true, options)
        assert.same({ { key = "value", ascending = true } }, frame.sortCriteria)
        addon:ToggleTableSortCriterion(frame, "value", false, options)
        assert.same({}, frame.sortCriteria)
        assert.is_nil(frame.inventorySortKey)
        assert.is_false(frame.inventorySortAscending)
    end)

    it("accepts Shift-right-clicks while preserving normal and Shift-left-click behavior", function()
        local addon = build_addon()
        local frame = { sortKey = "value", sortAscending = false }
        local scripts, registered = {}, {}
        local button = {
            RegisterForClicks = function(_, ...) registered = { ... } end,
            SetScript = function(_, event, callback) scripts[event] = callback end,
        }
        local shift = false
        local calls = 0
        local function sort(self, key, mouseButton)
            calls = calls + 1
            self:ToggleTableSortCriterion(frame, key, true, { mouseButton = mouseButton, validKeys = valid_keys })
        end
        addon:BindTableSortHeaderClick(button, sort, "name")
        assert.same({ "LeftButtonUp", "RightButtonUp" }, registered)
        loader.with_globals({ IsShiftKeyDown = function() return shift end }, function()
            scripts.OnClick(button, "RightButton")
            assert.equals(0, calls)
            shift = true
            scripts.OnClick(button, "MiddleButton")
            assert.equals(0, calls)
            scripts.OnClick(button, "LeftButton")
            assert.same({ { key = "value", ascending = false }, { key = "name", ascending = true } }, frame.sortCriteria)
            scripts.OnClick(button, "LeftButton")
            assert.is_false(frame.sortCriteria[2].ascending)
            scripts.OnClick(button, "RightButton")
            assert.same({ { key = "value", ascending = false } }, frame.sortCriteria)
            shift = false
            scripts.OnClick(button, "LeftButton")
            assert.same({ { key = "name", ascending = true } }, frame.sortCriteria)
        end)
    end)

    it("does not remove criteria on a right-click without Shift", function()
        local addon = build_addon()
        local frame = { sortKey = "value", sortAscending = false }
        loader.with_globals({ IsShiftKeyDown = function() return false end }, function()
            addon:ToggleTableSortCriterion(frame, "value", false, { mouseButton = "RightButton" })
        end)
        assert.equals("value", frame.sortKey)
        assert.is_false(frame.sortAscending)
        assert.is_nil(frame.sortCriteria)
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

    it("keeps a required grouping column first while retaining secondary sorting", function()
        local addon = build_addon()
        local frame = {
            sortKey = "value",
            sortAscending = false,
            sortCriteria = {
                { key = "value", ascending = false },
                { key = "name", ascending = true },
            },
        }

        addon:EnsureTableSortLeadingCriterion(frame, "name", true, {
            validKeys = valid_keys,
        })

        assert.same({
            { key = "name", ascending = true },
            { key = "value", ascending = false },
        }, frame.sortCriteria)
        assert.equals("name", frame.sortKey)
        assert.is_true(frame.sortAscending)
    end)

    it("builds collapsed location headers and expands selected groups", function()
        local addon = build_addon()
        local rows = {
            { id = 1, location = "Ashenvale" },
            { id = 2, location = "Ashenvale" },
            { id = 3, location = "Feralas" },
        }

        local collapsed = addon:BuildLocationGroupedDisplayRows(rows, function(row)
            return row.location
        end, {}, true)
        assert.equals(2, #collapsed)
        assert.same({
            isLocationGroupHeader = true,
            locationGroupKey = "ashenvale",
            locationGroupLabel = "Ashenvale",
            itemCount = 2,
            collapsed = true,
        }, collapsed[1])

        local expanded = addon:BuildLocationGroupedDisplayRows(rows, function(row)
            return row.location
        end, { ashenvale = false }, true)
        assert.equals(4, #expanded)
        assert.equals(1, expanded[2].id)
        assert.equals(2, expanded[3].id)
        assert.equals("feralas", expanded[4].locationGroupKey)
    end)

    it("toggles location groups between collapsed and expanded", function()
        local addon = build_addon()
        local groups = {}

        assert.is_false(addon:ToggleLocationGroupCollapsed(groups, "ashenvale", true))
        assert.is_false(groups.ashenvale)
        assert.is_true(addon:ToggleLocationGroupCollapsed(groups, "ashenvale", false))
        assert.is_true(groups.ashenvale)
    end)

    it("returns the original flat grouped rows when location headers are disabled", function()
        local addon = build_addon()
        local rows = {
            { id = 1, location = "Ashenvale" },
            { id = 2, location = "Feralas" },
        }

        local display_rows = addon:BuildLocationGroupedDisplayRows(rows, function(row)
            return row.location
        end, {}, false)

        assert.equals(rows, display_rows)
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
        assert.equals("Shift-right-click a header to remove its sorting level.", lines[5])
    end)
end)
