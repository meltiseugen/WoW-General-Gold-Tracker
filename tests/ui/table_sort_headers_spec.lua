local loader = require("tests.helpers.addon_loader")

local function noop() end

local function header()
    local button = { scripts = {} }
    button.text = {
        SetText = function(self, value) self.value = value end,
        SetTextColor = noop,
    }
    button.sortIcon = {
        SetTexture = noop,
        SetTexCoord = noop,
        Show = function(self) self.shown = true end,
        Hide = function(self) self.shown = false end,
        SetShown = function(self, shown) self.shown = shown end,
    }
    function button:SetScript(event, callback) self.scripts[event] = callback end
    function button:HookScript(event, callback) self.scripts[event] = callback end
    function button:RegisterForClicks(...) self.clicks = { ... } end
    return button
end

describe("sortable table header removal", function()
    local cases = {
        { name = "ObservedDrops", frame = "observedDropsFrame", primary = "itemName", secondary = "value",
            primaryHeader = "itemHeaderButton", secondaryHeader = "valueHeaderButton" },
        { name = "CraftingFarming", frame = "craftingFarmingFrame", primary = "itemName", secondary = "value",
            primaryHeader = "itemHeaderButton", secondaryHeader = "valueHeaderButton" },
        { name = "Inventory", frame = "inventoryFrame", primary = "itemName", secondary = "totalValue",
            primaryHeader = "itemHeaderButton", secondaryHeader = "totalHeaderButton",
            keyField = "inventorySortKey", ascendingField = "inventorySortAscending" },
        { name = "RareFarming", frame = "rareFarmingFrame", primary = "location", secondary = "value",
            primaryHeader = "locationHeaderButton", secondaryHeader = "valueHeaderButton" },
        { name = "InstanceFarming", frame = "instanceFarmingFrame", primary = "instanceName", secondary = "value",
            primaryHeader = "instanceHeaderButton", secondaryHeader = "valueHeaderButton" },
        { name = "History", frame = "historyFrame", primary = "duration", secondary = "sessionTotal",
            primaryHeader = "durationHeaderButton", secondaryHeader = "totalHeaderButton" },
    }

    for _, case in ipairs(cases) do
        it("removes a level and updates " .. case.name .. " header indicators", function()
            local addon = {}
            local ns = { JanisTheme = { SetTexture = noop } }
            if case.name == "History" then
                for _, name in ipairs({ "HistoryConstants", "HistoryDateFilter", "HistorySessionModel", "HistoryFormatter", "HistoryDataService" }) do
                    local _, loaded = loader.load_module("UI/History/" .. name .. ".lua", addon, ns)
                    ns[name] = loaded[name]
                end
            end
            loader.load_module("UI/" .. case.name .. "Window.lua", addon, ns)
            local primary, secondary = header(), header()
            primary.sortLabel, secondary.sortLabel = "Primary", "Secondary"
            local frame = {
                currentPage = 3,
                sortHeaders = { [case.primary] = primary, [case.secondary] = secondary },
            }
            frame[case.primaryHeader], frame[case.secondaryHeader] = primary, secondary
            addon[case.frame] = frame
            local keyField = case.keyField or "sortKey"
            local ascendingField = case.ascendingField or "sortAscending"
            addon:SetTableSortCriteria(frame, {
                { key = case.primary, ascending = true },
                { key = case.secondary, ascending = false },
            }, keyField, ascendingField)
            local update = addon["Update" .. case.name .. "SortHeaderState"]
            local refreshes = 0
            addon["Refresh" .. case.name .. "Window"] = function(self)
                refreshes = refreshes + 1
                update(self)
            end
            update(addon)
            assert.is_true(secondary.sortIcon.shown)
            assert.is_truthy(primary.text.value:find(" 1", 1, true))
            addon:BindTableSortHeaderClick(secondary, addon["Toggle" .. case.name .. "Sort"], case.secondary)
            loader.with_globals({ IsShiftKeyDown = function() return true end }, function()
                secondary.scripts.OnClick(secondary, "RightButton")
            end)
            assert.same({ { key = case.primary, ascending = true } }, frame.sortCriteria)
            assert.equals(case.primary, frame[keyField])
            assert.is_true(frame[ascendingField])
            assert.equals(1, refreshes)
            assert.is_true(primary.sortIcon.shown)
            assert.is_false(secondary.sortIcon.shown)
            assert.is_nil(primary.text.value:find(" 1", 1, true))
        end)
    end
end)
