local loader = require("tests.helpers.addon_loader")
local ui = require("tests.helpers.options_ui")

local function with_welcome(callback, skin)
    ui.with_ui(function(addon, ns, widgets)
        assert(loadfile("UI/WelcomeWindow.lua"))("General-Gold-Tracker", ns)
        local opened = 0
        addon.OpenMainWindowFromSlash = function() opened = opened + 1 end
        addon.RegisterEvent = function() end
        loader.with_globals({ SlashCmdList = {} }, function()
            assert(loadfile("Core/Bootstrap.lua"))("General-Gold-Tracker", ns)
            callback(addon, function() return opened end, widgets)
        end)
    end, 1000, skin)
end

describe("Welcome setup and module preferences", function()
    it("waits for bare /gt and keeps an unfinished selection when /gt is repeated", function()
        with_welcome(function(addon, opened)
            addon:HandleSlashCommand("options")
            assert.is_nil(addon.welcomeFrame)
            addon:HandleSlashCommand("")
            local frame = addon.welcomeFrame
            assert.is_true(frame:IsShown())
            assert.equals(0, opened())
            for _, module in ipairs(addon:GetExplorerModuleDefinitions()) do
                assert.is_true(frame.moduleChecks[module.id]:GetChecked())
            end
            frame.moduleChecks.alts:SetChecked(false)
            addon:HandleSlashCommand(" ")
            assert.equals(frame, addon.welcomeFrame)
            assert.is_false(frame.moduleChecks.alts:GetChecked())
            assert.is_true(addon.db.module_alts)
        end)
    end)

    it("applies selected modules once and preserves saved choices through database initialization", function()
        with_welcome(function(addon, opened)
            local history, farms = { { name = "Saved run" } }, { keep = true }
            addon.db.history, addon.db.customFarms = history, farms
            addon:HandleSlashCommand("")
            addon.welcomeFrame.moduleChecks.favorites:SetChecked(false)
            addon.welcomeFrame.moduleChecks.alts:SetChecked(false)
            ui.click(addon.welcomeFrame.applyButton)
            assert.is_true(addon.db.welcomeCompleted)
            assert.is_false(addon.db.module_favorites)
            assert.is_false(addon.db.module_alts)
            assert.is_true(addon.db.module_rares)
            assert.is_false(addon.welcomeFrame:IsShown())
            assert.equals(1, opened())
            local saved = addon.db
            loader.with_globals({ WoWGeneralGoldTrackerDB = saved }, function()
                addon:InitializeDatabase()
            end)
            assert.is_false(addon:NeedsWelcomeSetup())
            assert.is_false(addon:IsModuleEnabled("alts"))
            assert.equals(history, addon.db.history)
            assert.equals(farms, addon.db.customFarms)
            addon:HandleSlashCommand("")
            assert.equals(2, opened())
            assert.is_false(addon.welcomeFrame:IsShown())
        end)
    end)

    for _, dismissal in ipairs({ "skip", "close" }) do
        it(dismissal .. " enables everything even after unchecking modules", function()
            with_welcome(function(addon, opened)
                addon.db.module_rares = false
                addon:HandleSlashCommand("")
                for _, check in pairs(addon.welcomeFrame.moduleChecks) do check:SetChecked(false) end
                if dismissal == "skip" then ui.click(addon.welcomeFrame.skipButton)
                else addon.welcomeFrame:Hide() end -- Close and native Escape both hide this special frame.
                assert.is_true(addon.db.welcomeCompleted)
                for _, module in ipairs(addon:GetExplorerModuleDefinitions()) do
                    assert.is_true(addon:IsModuleEnabled(module.id))
                end
                assert.equals(1, opened())
                addon.welcomeFrame:Hide()
                assert.equals(1, opened())
            end)
        end)
    end

    it("allows an empty selection and restores every module with the page reset", function()
        with_welcome(function(addon)
            addon:HandleSlashCommand("")
            for _, check in pairs(addon.welcomeFrame.moduleChecks) do check:SetChecked(false) end
            ui.click(addon.welcomeFrame.applyButton)
            assert.is_nil(addon:ResolveEnabledExplorerTab("favorites"))
            addon:OpenOptions("modules")
            assert.equals("modules", addon.optionsWindow.selectedPage)
            for _, module in ipairs(addon:GetExplorerModuleDefinitions()) do
                assert.is_false(addon.optionsControls[module.key]:GetChecked())
            end
            addon:ResetOptionsPage("modules")
            for _, module in ipairs(addon:GetExplorerModuleDefinitions()) do
                assert.is_true(addon:IsModuleEnabled(module.id))
            end
            assert.is_true(addon.db.welcomeCompleted)
        end)
    end)

    it("toggles Bags immediately without changing the separate Auction House preference", function()
        with_welcome(function(addon)
            addon:OpenOptions("modules")
            local bags = addon.optionsControls.module_inventory
            bags:SetChecked(false); ui.click(bags)
            assert.is_false(addon.optionsControls.autoOpenAuctionableInventoryOnAuctionHouse.enabled)
            assert.is_false(addon:IsAutoOpenAuctionableInventoryOnAuctionHouseEnabled())
            assert.is_true(addon.db.autoOpenAuctionableInventoryOnAuctionHouse)
            addon.StartAuctionHouseSellPaneWatcher = function() error("Disabled Bags started an AH watcher") end
            addon:OnAuctionHouseShow()
            bags:SetChecked(true); ui.click(bags)
            assert.is_true(addon.optionsControls.autoOpenAuctionableInventoryOnAuctionHouse.enabled)
            assert.is_true(addon:IsAutoOpenAuctionableInventoryOnAuctionHouseEnabled())
        end)
    end)

    it("defaults existing installations and newly introduced modules to enabled", function()
        with_welcome(function(addon)
            addon.db = { history = { { name = "Existing run" } } }
            assert.is_true(addon:NeedsWelcomeSetup())
            for _, module in ipairs(addon:GetExplorerModuleDefinitions()) do
                assert.is_true(addon:IsModuleEnabled(module.id))
            end
            addon.db.welcomeCompleted = true
            assert.is_false(addon:NeedsWelcomeSetup())
        end)
    end)

    it("builds the scrollable setup in every skin without polling", function()
        for _, skin in ipairs({ "midnight", "parchment", "quietBotanical", "quietArcane", "fieldLedger", "minimalVoidglass" }) do
            with_welcome(function(addon, _, widgets)
                addon:OpenWelcomeWindow()
                for _, widget in ipairs(widgets) do assert.is_nil(widget.scripts.OnUpdate) end
                for _, check in pairs(addon.welcomeFrame.moduleChecks) do
                    assert.is_true(check:GetChecked())
                end
                local scroll = addon.welcomeFrame.scrollFrame
                assert.is_true(scroll:GetVerticalScrollRange() > 0)
                scroll.scripts.OnMouseWheel(scroll, -100)
                assert.equals(scroll:GetVerticalScrollRange(), scroll:GetVerticalScroll())
                scroll.scripts.OnMouseWheel(scroll, 100)
                assert.equals(0, scroll:GetVerticalScroll())
            end, skin)
        end
    end)
end)
