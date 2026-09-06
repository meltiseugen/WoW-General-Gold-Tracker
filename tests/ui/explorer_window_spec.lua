local loader = require("tests.helpers.addon_loader")

local function frame()
    return {
        shown = false,
        hidden = false,
        points = {},
        SetParent = function(self, parent)
            self.parent = parent
        end,
        SetFrameStrata = function(self, strata)
            self.strata = strata
        end,
        GetFrameStrata = function(self)
            return self.strata or "DIALOG"
        end,
        GetParent = function(self)
            return self.parent
        end,
        SetFrameLevel = function(self, level)
            self.level = level
        end,
        GetFrameLevel = function(self)
            return self.level or 0
        end,
        SetToplevel = function(self, toplevel)
            self.toplevel = toplevel
        end,
        SetIgnoreParentAlpha = function(self, ignored)
            self.ignore_parent_alpha = ignored
        end,
        SetIgnoreParentScale = function(self, ignored)
            self.ignore_parent_scale = ignored
        end,
        SetMovable = function(self, movable)
            self.movable = movable
        end,
        SetResizable = function(self, resizable)
            self.resizable = resizable
        end,
        SetClampedToScreen = function(self, clamped)
            self.clamped = clamped
        end,
        ClearAllPoints = function(self)
            self.points = {}
        end,
        SetPoint = function(self, ...)
            self.points[#self.points + 1] = { ... }
        end,
        Show = function(self)
            self.shown = true
            self.hidden = false
        end,
        Hide = function(self)
            self.hidden = true
            self.shown = false
        end,
        Raise = function(self)
            self.raised = true
        end,
        IsShown = function(self)
            return self.shown == true
        end,
    }
end

local function button()
    return {
        selected = nil,
        shown = nil,
        hidden = false,
        SetSelected = function(self, selected)
            self.selected = selected
        end,
        SetShown = function(self, shown)
            self.shown = shown
            self.hidden = shown ~= true
        end,
        ClearAllPoints = function(self)
            self.points = {}
        end,
        SetPoint = function(self, ...)
            self.points = self.points or {}
            self.points[#self.points + 1] = { ... }
        end,
    }
end

local function tab_buttons()
    return {
        rares = button(),
        instances = button(),
        materials = button(),
        drops = button(),
        favorites = button(),
        inventory = button(),
        priceAlerts = button(),
    }
end

local function load_explorer(addon)
    return loader.load_module("UI/ExplorerWindow.lua", addon, {
        JanisTheme = {
            CreateButton = function() end,
            CreateResizeButton = function() end,
            ApplyWindowChrome = function() end,
            RegisterSpecialFrame = function() end,
        },
    })
end

describe("UI/ExplorerWindow", function()
    it("selects rare favorites through the shared rare farming library view", function()
        local rare_frame = frame()
        rare_frame.librarySavedTabButton = button()
        rare_frame.libraryFavoritesTabButton = button()
        rare_frame.libraryNewScanButton = button()
        local instance_frame = frame()
        local material_frame = frame()
        local selected_view = nil
        local refreshed_library = 0
        local addon = load_explorer({
            db = {},
            explorerFrame = {
                contentFrame = frame(),
                tabButtons = tab_buttons(),
            },
            instanceFarmingFrame = instance_frame,
            craftingFarmingFrame = material_frame,
            CreateRareFarmingWindow = function(self)
                self.rareFarmingFrame = rare_frame
            end,
            SetRareFarmingWindowView = function(_, view_id)
                selected_view = view_id
            end,
            RefreshRareFarmingLibraryWindow = function()
                refreshed_library = refreshed_library + 1
            end,
        })

        addon:SetExplorerTab("favorites")

        assert.equals("favorites", addon.db.explorerTab)
        assert.is_true(addon.explorerFrame.tabButtons.favorites.selected)
        assert.is_true(rare_frame.shown)
        assert.equals(addon.explorerFrame.contentFrame, rare_frame.parent)
        assert.equals("favorites", rare_frame.rareFarmingLibraryTab)
        assert.equals("favorites", rare_frame.rareFarmingNavigationTab)
        assert.equals("library", selected_view)
        assert.equals(1, refreshed_library)
        assert.is_false(rare_frame.librarySavedTabButton.shown)
        assert.is_false(rare_frame.libraryFavoritesTabButton.shown)
        assert.is_false(rare_frame.libraryNewScanButton.shown)
        assert.is_true(instance_frame.hidden)
        assert.is_true(material_frame.hidden)
    end)

    it("embeds child windows on the explorer content layer", function()
        local rare_frame = frame()
        local content_frame = frame()
        local explorer_frame = {
            contentFrame = content_frame,
            tabButtons = tab_buttons(),
        }
        content_frame.strata = "HIGH"
        content_frame.level = 42
        local addon = load_explorer({
            db = {},
            explorerFrame = explorer_frame,
            CreateRareFarmingWindow = function(self)
                self.rareFarmingFrame = rare_frame
            end,
            SetRareFarmingWindowView = function() end,
            RefreshRareFarmingLibraryWindow = function() end,
        })

        addon:SetExplorerTab("rares")

        assert.equals("HIGH", rare_frame.strata)
        assert.equals(43, rare_frame.level)
        assert.is_false(rare_frame.toplevel)
        assert.is_false(rare_frame.ignore_parent_alpha)
        assert.is_false(rare_frame.ignore_parent_scale)
        assert.equals(explorer_frame, rare_frame.goldTrackerManagedWindow)
    end)

    it("exposes master tabs in the requested order", function()
        local addon = load_explorer({})
        local labels = {}
        for _, tab in ipairs(addon:GetExplorerTabDefinitions()) do
            labels[#labels + 1] = tab.label
        end

        assert.same({ "Favorites", "Alerts", "Rares", "Instances", "Drops", "Materials", "Bags" }, labels)
    end)

    it("shows only saved scans and new scan sub-tabs on rare farming", function()
        local rare_frame = frame()
        rare_frame.librarySavedTabButton = button()
        rare_frame.libraryFavoritesTabButton = button()
        rare_frame.libraryNewScanButton = button()
        local selected_view = nil
        local addon = load_explorer({
            db = {},
            explorerFrame = {
                contentFrame = frame(),
                tabButtons = tab_buttons(),
            },
            CreateRareFarmingWindow = function(self)
                self.rareFarmingFrame = rare_frame
            end,
            SetRareFarmingWindowView = function(_, view_id)
                selected_view = view_id
            end,
        })

        addon:SetExplorerTab("rares")

        assert.equals("saved", rare_frame.rareFarmingLibraryTab)
        assert.equals("saved", rare_frame.rareFarmingNavigationTab)
        assert.equals("library", selected_view)
        assert.is_true(rare_frame.librarySavedTabButton.shown)
        assert.is_false(rare_frame.libraryFavoritesTabButton.shown)
        assert.is_true(rare_frame.libraryNewScanButton.shown)
    end)

    it("opens instance scans on the scan sub-tab when a scan is active", function()
        local instance_frame = frame()
        instance_frame.scanState = { active = true }
        instance_frame.savedTabButton = button()
        instance_frame.favoritesTabButton = button()
        instance_frame.newScanTabButton = button()
        local selected_view = nil
        local addon = load_explorer({
            db = {},
            explorerFrame = {
                contentFrame = frame(),
                tabButtons = tab_buttons(),
            },
            CreateInstanceFarmingWindow = function(self)
                self.instanceFarmingFrame = instance_frame
            end,
            SetInstanceFarmingWindowView = function(_, view_id)
                selected_view = view_id
            end,
        })

        addon:SetExplorerTab("instances")

        assert.equals("instances", addon.db.explorerTab)
        assert.is_true(addon.explorerFrame.tabButtons.instances.selected)
        assert.is_true(instance_frame.shown)
        assert.equals("scan", selected_view)
        assert.is_true(instance_frame.savedTabButton.shown)
        assert.is_false(instance_frame.favoritesTabButton.shown)
        assert.is_true(instance_frame.newScanTabButton.shown)
    end)

    it("opens materials and refreshes its layout data", function()
        local material_frame = frame()
        local refreshed = 0
        local addon = load_explorer({
            db = {},
            explorerFrame = {
                contentFrame = frame(),
                tabButtons = tab_buttons(),
            },
            CreateCraftingFarmingWindow = function(self)
                self.craftingFarmingFrame = material_frame
            end,
            RefreshCraftingFarmingWindow = function()
                refreshed = refreshed + 1
            end,
        })

        addon:SetExplorerTab("materials")

        assert.equals("materials", addon.db.explorerTab)
        assert.is_true(addon.explorerFrame.tabButtons.materials.selected)
        assert.is_true(material_frame.shown)
        assert.equals(1, refreshed)
    end)

    it("switches from bags to materials without leaving the previous list visible", function()
        local content_frame = frame()
        local inventory_frame = frame()
        local material_frame = frame()
        local material_on_show_refreshes = 0
        local material_refreshes = 0
        material_frame.Show = function(self)
            self.shown = true
            self.hidden = false
            if not self.suppressExplorerOnShow then
                material_on_show_refreshes = material_on_show_refreshes + 1
            end
        end

        local addon = load_explorer({
            db = {},
            explorerFrame = {
                contentFrame = content_frame,
                tabButtons = tab_buttons(),
            },
            CreateInventoryWindow = function(self)
                self.inventoryFrame = inventory_frame
            end,
            RefreshInventoryWindow = function() end,
            CreateCraftingFarmingWindow = function(self)
                self.craftingFarmingFrame = material_frame
            end,
            RefreshCraftingFarmingWindow = function()
                material_refreshes = material_refreshes + 1
            end,
        })

        addon:SetExplorerTab("inventory")
        assert.is_true(inventory_frame.shown)
        assert.equals(content_frame, inventory_frame.parent)
        assert.equals(2, #inventory_frame.points)

        addon:SetExplorerTab("materials")

        assert.is_true(inventory_frame.hidden)
        assert.equals(0, #inventory_frame.points)
        assert.is_true(material_frame.shown)
        assert.equals(content_frame, material_frame.parent)
        assert.equals(0, material_on_show_refreshes)
        assert.equals(1, material_refreshes)
    end)

    it("opens observed drops and refreshes its prices view", function()
        local drops_frame = frame()
        local refreshed = 0
        local addon = load_explorer({
            db = {},
            explorerFrame = {
                contentFrame = frame(),
                tabButtons = tab_buttons(),
            },
            CreateObservedDropsWindow = function(self)
                self.observedDropsFrame = drops_frame
            end,
            RefreshObservedDropsWindow = function()
                refreshed = refreshed + 1
            end,
        })

        addon:SetExplorerTab("drops")

        assert.equals("drops", addon.db.explorerTab)
        assert.is_true(addon.explorerFrame.tabButtons.drops.selected)
        assert.is_true(drops_frame.shown)
        assert.equals(1, refreshed)
    end)

    it("opens auctionable inventory as an explorer tab", function()
        local inventory_frame = frame()
        local refreshed = 0
        local addon = load_explorer({
            db = {},
            explorerFrame = {
                contentFrame = frame(),
                tabButtons = tab_buttons(),
            },
            CreateInventoryWindow = function(self)
                self.inventoryFrame = inventory_frame
            end,
            RefreshInventoryWindow = function()
                refreshed = refreshed + 1
            end,
        })

        addon:SetExplorerTab("inventory")

        assert.equals("inventory", addon.db.explorerTab)
        assert.is_true(addon.explorerFrame.tabButtons.inventory.selected)
        assert.is_true(inventory_frame.shown)
        assert.equals(addon.explorerFrame.contentFrame, inventory_frame.parent)
        assert.equals(1, refreshed)
    end)

    it("opens price increase alerts as an explorer tab", function()
        local alerts_frame = frame()
        local refreshed = 0
        local addon = load_explorer({
            db = {},
            explorerFrame = {
                contentFrame = frame(),
                tabButtons = tab_buttons(),
            },
            CreatePriceIncreaseAlertsWindow = function(self)
                self.priceIncreaseAlertsFrame = alerts_frame
            end,
            RefreshPriceIncreaseAlertsWindow = function()
                refreshed = refreshed + 1
            end,
        })

        addon:SetExplorerTab("priceAlerts")

        assert.equals("priceAlerts", addon.db.explorerTab)
        assert.is_true(addon.explorerFrame.tabButtons.priceAlerts.selected)
        assert.is_true(alerts_frame.shown)
        assert.equals(addon.explorerFrame.contentFrame, alerts_frame.parent)
        assert.equals(1, refreshed)
    end)
end)
