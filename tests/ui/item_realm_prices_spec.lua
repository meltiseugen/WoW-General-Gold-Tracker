local loader = require("tests.helpers.addon_loader")
local ui = require("tests.helpers.explorer_ui")

local function with_details(callback)
    local addon = {
        VALUE_SOURCE_BY_ID = {},
        HasInventoryMaterialFarmingMap = function() return false end,
        FormatMoney = function(_, value) return tostring(value) end,
        GetCraftingFarmingProfessionOptions = function() return {} end,
    }
    local _, ns = loader.load_module("UI/ItemRealmPrices.lua", addon, { JanisTheme = {} })
    loader.load_module("UI/InventoryWindow.lua", addon, { JanisTheme = ns.JanisTheme })
    ui.with_ui(ns, function()
        local originalCreate = CreateFrame
        loader.with_globals({
            CreateFrame = function(...)
                local widget = originalCreate(...)
                widget.SetThumbTexture = function() end
                widget.ClearFocus = function() end
                widget.SetCursorPosition = function() end
                widget.SetHorizontalScroll = function(self, value) self.horizontalScroll = value end
                widget.GetValue = function(self) return self.value or 0 end
                widget.SetValue = function(self, value)
                    self.value = value
                    local fn = self:GetScript("OnValueChanged")
                    if fn then fn(self, value) end
                end
                widget.SetMinMaxValues = function(self, low, high) self.minimum, self.maximum = low, high end
                widget.ClearAllPoints = function(self) self.points = {} end
                widget.SetPoint = function(self, ...) self.points = self.points or {}; self.points[#self.points + 1] = { ... } end
                return widget
            end,
            GetRealmName = function() return "Current Realm" end,
            C_Item = {},
            C_ToyBox = {},
            GetDetailedItemLevelInfo = false,
            GetItemInfoInstant = false,
            TSM_API = false,
        }, function()
            local calls = {}
            addon.GetCapturedTSMRealms = function() return { "Other Realm", "Current Realm" } end
            addon.GetCapturedTSMRealmRevision = function() return 12 end
            addon.GetCapturedTSMRealmItemValues = function(_, realm, query)
                calls[#calls + 1] = { realm, query }
                return {
                    minBuyout = realm == "Current Realm" and 10000 or 20000,
                    marketValue = 30000, marketValueRecent = 40000, historical = 50000,
                    timestamps = { current = 100, market = 90, historical = 80 },
                }
            end
            callback(addon, ns, calls)
        end)
    end)
end

describe("Item details realm prices", function()
    it("recognizes equipment and catalog collectibles/recipes while excluding ordinary materials", function()
        with_details(function(addon)
            for _, item in ipairs({
                { itemClassID = 2 }, { itemClassID = 4 }, { itemClassID = 15, itemSubclassID = 5 },
                { petID = 59 }, { farmingSourceType = "catalog-mounts" },
                { farmingSourceType = "catalog-pets" }, { farmingSourceType = "catalog-toys" },
                { farmingSourceType = "catalog-recipes" },
                { farmingSourceType = "catalog-cosmetics" },
            }) do assert.is_true(addon:IsItemRealmPriceType(item)) end
            C_ToyBox.GetToyInfo = function(id) if id == 444 then return id end end
            assert.is_true(addon:IsItemRealmPriceType({ itemID = 444 }))
            assert.is_false(addon:IsItemRealmPriceType({ itemID = 2770, itemClassID = 7 }))
        end)
    end)

    it("uses pet species rather than the generic cage item and tries level prices first", function()
        with_details(function(addon, _, calls)
            local get = addon.GetCapturedTSMRealmItemValues
            addon.GetCapturedTSMRealmItemValues = function(self, realm, query)
                local value = get(self, realm, query)
                if query == "p:59:i25" then value.marketValue = nil end
                return value
            end
            local rows = addon:BuildItemRealmPriceRows({ itemID = 82800, petID = 59,
                itemLink = "|Hbattlepet:59:25:3:100:10:10:0|h[Pet]|h" })
            assert.equals("p:59:i25", calls[1][2])
            assert.equals("p:59", calls[2][2])
            assert.equals("Current Realm", rows[1].realm)
            assert.equals("p:59:i25", rows[1].queryKeys.minBuyout)
            assert.equals(100, rows[1].timestamps.minBuyout)
        end)
    end)

    it("preserves equipment level prices and records base fallback per source", function()
        with_details(function(addon)
            addon.GetCapturedTSMRealmItemValues = function(_, _, query)
                if query == "i:123::i100" then return { minBuyout = 90000 } end
                return { minBuyout = 10000, marketValue = 30000, historical = 40000 }
            end
            local rows = addon:BuildItemRealmPriceRows({ itemID = 123, itemClassID = 4, itemLevel = 100 })
            assert.equals(90000, rows[1].values.minBuyout)
            assert.equals("i:123::i100", rows[1].queryKeys.minBuyout)
            assert.equals(30000, rows[1].values.marketValue)
            assert.equals("i:123", rows[1].queryKeys.marketValue)
        end)
    end)

    it("shows one regional percentage across rows and reuses it while resizing", function()
        with_details(function(addon, _, calls)
            local queries, tooltip = {}, {}
            TSM_API = { GetCustomPriceValue = function(source, query)
                assert.equals("DBRegionSaleRate", source)
                queries[#queries + 1] = query
                return 0.123
            end }
            GameTooltip.AddLine = function(_, text) tooltip[#tooltip + 1] = text end
            addon:OpenInventoryItemDetailsWindow({ itemID = 6331, itemClassID = 4 })
            local panel = addon.inventoryItemDetailsFrame.realmPricesPanel
            assert.equals("Region sell rate", panel.headers[6].text:GetText())
            assert.equals("12.3%", panel.rows[1].cells[6].text:GetText())
            assert.equals("12.3%", panel.rows[2].cells[6].text:GetText())
            panel.rows[1].cells[6]:GetScript("OnEnter")(panel.rows[1].cells[6])
            assert.matches("shared across rows", table.concat(tooltip, "\n"))
            panel.scroll:SetWidth(520)
            addon:RefreshInventoryItemDetailsWindow()
            assert.same({ "i:6331" }, queries)
            assert.equals(2, #calls) -- Adding the column must not trigger base-price fallback queries.
        end)
    end)

    it("uses species and variant fallback for regional sale rates without querying the cage", function()
        with_details(function(addon)
            local queries = {}
            TSM_API = { GetCustomPriceValue = function(_, query)
                queries[#queries + 1] = query
                if query == "p:59" then return 0.001 end
            end }
            addon:OpenInventoryItemDetailsWindow({ itemID = 82800, petID = 59,
                itemLink = "|Hbattlepet:59:25:3:100:10:10:0|h[Pet]|h" })
            local panel = addon.inventoryItemDetailsFrame.realmPricesPanel
            assert.same({ "p:59:i25", "p:59" }, queries)
            assert.equals("0.1%", panel.rows[1].cells[6].text:GetText())
            assert.equals("p:59", panel.rows[1].data.queryKeys.regionSaleRate)
        end)
    end)

    it("keeps missing or invalid sale rates unavailable and formats actual zero as zero", function()
        with_details(function(addon)
            addon:OpenInventoryItemDetailsWindow({ itemID = 6331, itemClassID = 4 })
            local panel = addon.inventoryItemDetailsFrame.realmPricesPanel
            assert.equals("--", panel.rows[1].cells[6].text:GetText())
            for _, get in ipairs({ function() return nil end, function() error("TSM unavailable") end,
                function() return -1 end, function() return 2 end, function() return 0/0 end }) do
                TSM_API = { GetCustomPriceValue = get }
                addon:OpenInventoryItemDetailsWindow({ itemID = 6331, itemClassID = 4 })
                assert.equals("--", panel.rows[1].cells[6].text:GetText())
            end
            TSM_API.GetCustomPriceValue = function() return 0 end
            addon:OpenInventoryItemDetailsWindow({ itemID = 6331, itemClassID = 4 })
            assert.equals("0.0%", panel.rows[1].cells[6].text:GetText())
            local disabledQueries = 0
            TSM_API.GetCustomPriceValue = function() disabledQueries = disabledQueries + 1 end
            addon.GetCapturedTSMRealms = function() return {} end
            addon:OpenInventoryItemDetailsWindow({ itemID = 6331, itemClassID = 4 })
            assert.equals(0, #panel.data)
            assert.equals(0, disabledQueries)
        end)
    end)

    it("opens the realm table by default through the real shared item-details window", function()
        with_details(function(addon, _, calls)
            addon:OpenInventoryItemDetailsWindow({ itemID = 6331, itemName = "Item", itemClassID = 4 })
            local frame = addon.inventoryItemDetailsFrame
            assert.equals("realms", frame.detailsView)
            assert.is_true(frame.realmPricesPanel:IsShown())
            assert.is_false(frame.graphPanel:IsShown())
            assert.is_false(frame.statsPanel:IsShown())
            assert.equals("Current Realm", frame.realmPricesPanel.rows[1].cells[1].text:GetText())
            assert.equals("10000", frame.realmPricesPanel.rows[1].cells[2].text:GetText())
            assert.equals(2, #calls) -- OnShow + explicit refresh reuse the same decoded rows.
            frame.detailsViewButtons.history:GetScript("OnClick")()
            assert.is_false(frame.realmPricesPanel:IsShown())
            assert.is_true(frame.graphPanel:IsShown())
            frame.detailsViewButtons.realms:GetScript("OnClick")()
            assert.is_true(frame.realmPricesPanel:IsShown())
            assert.equals(2, #calls)
        end)
    end)

    it("retains pet and catalog context when opening details from result rows", function()
        with_details(function(addon)
            addon:OpenInventoryItemDetailsWindow({ itemID = 82800, petID = 59, farmingSourceType = "catalog-pets" })
            assert.equals(59, addon.inventoryItemDetailsFrame.itemData.petID)
            assert.equals("realms", addon.inventoryItemDetailsFrame.detailsView)
            addon:OpenInventoryItemDetailsWindow({ itemID = 456, farmingSourceType = "catalog-toys" })
            assert.equals("realms", addon.inventoryItemDetailsFrame.detailsView)
        end)
    end)

    it("shows missing prices without inventing zeros and replaces stale rows on item changes", function()
        with_details(function(addon)
            addon:OpenInventoryItemDetailsWindow({ itemID = 123, itemClassID = 2 })
            addon.GetCapturedTSMRealmItemValues = function() return nil end
            addon:OpenInventoryItemDetailsWindow({ itemID = 456, itemClassID = 4 })
            local panel = addon.inventoryItemDetailsFrame.realmPricesPanel
            assert.equals("--", panel.rows[1].cells[2].text:GetText())
            assert.equals(2, #panel.data)
            addon:OpenInventoryItemDetailsWindow({ itemID = 2770, itemClassID = 7 })
            assert.is_false(panel:IsShown())
            assert.is_false(addon.inventoryItemDetailsFrame.detailsViewTabs:IsShown())
            assert.is_true(addon.inventoryItemDetailsFrame.graphPanel:IsShown())
            assert.is_nil(panel.data)
        end)
    end)

    it("keeps details usable with the optional module disabled", function()
        with_details(function(addon)
            addon.GetCapturedTSMRealms = function() return {} end
            addon:OpenInventoryItemDetailsWindow({ itemID = 6331, itemClassID = 4 })
            local frame = addon.inventoryItemDetailsFrame
            assert.is_true(frame.realmPricesPanel:IsShown())
            assert.matches("Enable TSM Realm Prices", frame.realmPricesPanel.status:GetText())
            assert.equals(0, #frame.realmPricesPanel.data)
            assert.equals("0 realms available", frame.realmPricesPanel.realmCount:GetText())
            assert.is_true(frame.realmPricesPanel.setupButton:IsShown())
            assert.is_false(frame.realmPricesPanel.scroll:IsShown())
            frame.detailsViewButtons.history:GetScript("OnClick")()
            assert.is_true(frame.graphPanel:IsShown())
        end)
    end)

    it("invites additional realms for one realm and reports multiple available realms", function()
        with_details(function(addon, _, calls)
            addon.GetCapturedTSMRealms = function() return { "Current Realm" } end
            addon:OpenInventoryItemDetailsWindow({ itemID = 6331, itemClassID = 4 })
            local panel = addon.inventoryItemDetailsFrame.realmPricesPanel
            assert.equals("1 realm available", panel.realmCount:GetText())
            assert.matches("Compare more realms", panel.footer:GetText())
            addon.GetCapturedTSMRealms = function() return { "Current Realm", "Other Realm" } end
            addon.GetCapturedTSMRealmRevision = function() return 15 end
            addon:RefreshInventoryItemDetailsWindow()
            assert.equals("2 realms available", panel.realmCount:GetText())
            assert.matches("snapshot time", panel.footer:GetText())
            assert.equals(3, #calls)
        end)
    end)

    it("distinguishes an enabled module awaiting downloads from a disabled module", function()
        with_details(function(addon, _, calls)
            addon.tsmRealmCapture = {}
            addon.GetCapturedTSMRealms = function() return {} end
            addon:OpenInventoryItemDetailsWindow({ itemID = 6331, itemClassID = 4 })
            local panel = addon.inventoryItemDetailsFrame.realmPricesPanel
            assert.matches("No realm prices captured yet", panel.status:GetText())
            assert.matches("TSM Desktop Application", panel.status:GetText())
            assert.is_true(panel.setupButton:IsShown())
            assert.equals(0, #calls)
        end)
    end)

    it("links to the shared setup guide even when the module is disabled", function()
        with_details(function(addon, _, calls)
            -- Real guide rendering and top-of-page behavior live in help_window_spec.lua.
            local opened
            addon.OpenTSMRealmSetupHelp = function() opened = true end
            addon.GetCapturedTSMRealms = function() return {} end
            addon:OpenInventoryItemDetailsWindow({ itemID = 6331, itemClassID = 4 })
            addon.inventoryItemDetailsFrame.realmPricesPanel.setupButton:GetScript("OnClick")()
            assert.is_true(opened)
            assert.equals(0, #calls)
        end)
    end)

    it("uses horizontal overflow at narrow widths and avoids decoding again during resize", function()
        with_details(function(addon, _, calls)
            addon:OpenInventoryItemDetailsWindow({ itemID = 6331, itemClassID = 4 })
            local frame = addon.inventoryItemDetailsFrame
            for _, width in ipairs({ 520, 650, 900 }) do
                frame.realmPricesPanel.scroll:SetWidth(width)
                addon:RefreshInventoryItemDetailsWindow()
                local panel = frame.realmPricesPanel
                assert.is_true(panel.content:GetWidth() >= width)
                assert.equals(panel.content:GetWidth() > width, panel.horizontal:IsShown())
                local right = 0
                for _, cell in ipairs(panel.rows[1].cells) do right = right + cell:GetWidth() end
                assert.equals(panel.content:GetWidth(), right)
                assert.equals(2, #calls)
            end
        end)
    end)

    it("rebuilds on capture revision changes and releases decoded rows when closed", function()
        with_details(function(addon, _, calls)
            addon:OpenInventoryItemDetailsWindow({ itemID = 6331, itemClassID = 4 })
            local frame = addon.inventoryItemDetailsFrame
            addon.GetCapturedTSMRealmRevision = function() return 15 end
            addon:RefreshInventoryItemDetailsWindow()
            assert.equals(4, #calls)
            frame:Hide()
            assert.is_nil(frame.realmPricesPanel.data)
            assert.is_nil(frame.realmPricesPanel.rows[1].cells[1].rowData)
        end)
    end)

    it("grows long columns rather than clipping high prices or realm names", function()
        with_details(function(addon, ns)
            ns.JanisTheme.GetRequiredTextColumnWidth = function(_, rows, key, minimum, options)
                local width = minimum
                for _, row in ipairs(rows) do width = math.max(width, row[key]:GetStringWidth() + options.padding) end
                return width
            end
            addon.GetCapturedTSMRealms = function() return { string.rep("Long Realm ", 8) } end
            addon.GetCapturedTSMRealmItemValues = function() return { minBuyout = 999999999999999 } end
            addon:OpenInventoryItemDetailsWindow({ itemID = 6331, itemClassID = 4 })
            local panel = addon.inventoryItemDetailsFrame.realmPricesPanel
            panel.scroll:SetWidth(520)
            addon:RefreshInventoryItemDetailsWindow()
            for _, cell in ipairs(panel.rows[1].cells) do
                assert.is_true(cell:GetWidth() >= cell.text:GetStringWidth() + 16)
            end
            assert.is_true(panel.horizontal:IsShown())
        end)
    end)
end)
