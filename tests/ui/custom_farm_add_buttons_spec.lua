local ui = require("tests.helpers.explorer_ui")

describe("custom farm Add controls", function()
    it("collapses columns outside build mode and updates existing views on start, Done, and deletion", function()
        local addon = { db = {} }
        local ns = { GoldTracker = addon, JanisTheme = {} }
        ui.with_ui(ns, function()
            for _, path in ipairs({ "Core/CustomFarms.lua", "UI/InventoryWindow.lua",
                "UI/CraftingFarmingWindow.lua", "UI/RareFarmingWindow.lua",
                "UI/InstanceFarmingWindow.lua", "UI/ObservedDropsWindow.lua", "UI/StandaloneMapWindow.lua" }) do
                assert(loadfile(path))("General-Gold-Tracker", ns)
            end
            local function widget()
                local w = CreateFrame("Frame")
                function w:ClearAllPoints() self.points = {} end
                function w:SetPoint(...) self.points = self.points or {}; self.points[#self.points + 1] = { ... } end
                return w
            end
            local views = {}
            for _, field in ipairs({ "inventoryFrame", "craftingFarmingFrame", "craftingFarmingExpandedFrame",
                "rareFarmingFrame", "instanceFarmingFrame", "observedDropsFrame" }) do
                local f = widget()
                f.listPanel, f.content, f.scrollFrame = widget(), widget(), widget()
                f.inventoryScrollFrame, f.inventoryContent = f.scrollFrame, f.content
                f.addHeaderButton, f.itemHeaderButton = widget(), widget()
                for _, key in ipairs({ "trackHeaderButton", "mapHeaderButton", "typeHeaderButton", "valueHeaderButton",
                    "instanceHeaderButton", "bossHeaderButton", "marketHeaderButton", "regionHeaderButton",
                    "averageHeaderButton", "detailsHeaderButton", "expansionHeaderButton" }) do
                    f[key] = widget()
                end
                f.instanceFarmingViewID, f.dropSourceID = "scan", "observed"
                local row = { addButton = widget(), icon = widget(), itemText = widget(), itemID = 2770 }
                local group = { addButton = widget(), icon = widget(), itemText = widget(),
                    isCategoryDivider = true, isLocationGroupHeader = true, rowType = "divider" }
                for _, target in ipairs({ row, group }) do
                    for _, key in ipairs({ "mapButton", "typeText", "valueText", "instanceText", "bossText",
                        "marketText", "regionText", "averageText", "detailsButton", "expansionText" }) do
                        target[key] = widget()
                    end
                end
                f.rows, f.rowPool, f.inventoryRows = { row, group }, { row, group }, { row, group }
                addon[field] = f
                views[#views + 1] = { frame = f, row = row, group = group }
            end
            addon.standaloneMapFrame = { addToFarmButton = widget(), statusText = widget(), body = widget() }
            addon.GetStandaloneMapCustomFarmRow = function() return { itemID = 2770 } end
            local function check(shown)
                for _, view in ipairs(views) do
                    assert.equals(shown, view.frame.addHeaderButton:IsShown())
                    assert.equals(shown, view.row.addButton:IsShown())
                    assert.is_false(view.group.addButton:IsShown())
                end
                assert.equals(shown, addon.standaloneMapFrame.addToFarmButton:IsShown())
            end
            addon:NotifyCustomFarmsChanged()
            check(false)
            for _, view in ipairs(views) do
                view.itemX = view.frame.itemHeaderButton.points[1][4]
            end
            local farm = addon:CreateCustomFarm("Copper", true)
            check(true)
            for _, view in ipairs(views) do
                assert.is_true(view.frame.itemHeaderButton.points[1][4] > view.itemX)
            end
            addon:FinishCustomFarmBuild(farm.id)
            check(false)
            assert.equals(farm, addon:GetCustomFarmByID(farm.id))
            for _, view in ipairs(views) do
                assert.equals(view.itemX, view.frame.itemHeaderButton.points[1][4])
            end
            addon:SetActiveCustomFarm(farm.id)
            check(true)
            addon:DeleteCustomFarm(farm.id)
            check(false)
        end)
    end)
end)
