local loader = require("tests.helpers.addon_loader")

local function load_bootstrap(addon)
    addon.Trim = addon.Trim or function(_, text)
        if type(text) ~= "string" then
            return ""
        end
        return text:gsub("^%s+", ""):gsub("%s+$", "")
    end
    addon.SetScript = addon.SetScript or function() end
    addon.RegisterEvent = addon.RegisterEvent or function() end
    addon.IsTotalWindowFeatureEnabled = addon.IsTotalWindowFeatureEnabled or function()
        return false
    end
    return loader.with_globals({
        SlashCmdList = {},
    }, function()
        return loader.load_module("Core/Bootstrap.lua", addon)
    end)
end

describe("Core/Bootstrap slash commands", function()
    it("routes common slash commands to the right addon actions", function()
        local calls = {}
        local addon = load_bootstrap({
            OpenMainWindowFromSlash = function()
                calls[#calls + 1] = "open-main"
            end,
            StartSession = function(_, force_new)
                calls[#calls + 1] = force_new and "new-session" or "start-session"
            end,
            StopSession = function()
                calls[#calls + 1] = "stop-session"
            end,
            OpenOptions = function()
                calls[#calls + 1] = "options"
            end,
            OpenExplorerWindow = function(_, tab_id)
                calls[#calls + 1] = tab_id and ("explorer:" .. tab_id) or "explorer"
            end,
            ClearWorldMapProjection = function()
                calls[#calls + 1] = "clear-map-pins"
            end,
            IsTotalWindowFeatureEnabled = function()
                return false
            end,
            Print = function(_, message)
                calls[#calls + 1] = "print:" .. message
            end,
        })

        addon:HandleSlashCommand("")
        addon:HandleSlashCommand("start")
        addon:HandleSlashCommand("new")
        addon:HandleSlashCommand("stop")
        addon:HandleSlashCommand("options")
        addon:HandleSlashCommand("explorer")
        addon:HandleSlashCommand("rares")
        addon:HandleSlashCommand("instances")
        addon:HandleSlashCommand("mats")
        addon:HandleSlashCommand("drops")
        addon:HandleSlashCommand("clearpins")

        assert.same({
            "open-main",
            "start-session",
            "new-session",
            "stop-session",
            "options",
            "explorer",
            "explorer:rares",
            "explorer:instances",
            "explorer:materials",
            "explorer:drops",
            "clear-map-pins",
        }, calls)
    end)

    it("adds custom materials from slash args and reports validation errors", function()
        local messages = {}
        local addon = load_bootstrap({
            AddCraftingFarmingCustomItem = function(_, item_id, expansion, profession, tag)
                return {
                    itemID = item_id,
                    expansion = expansion,
                    professions = { profession },
                    tag = tag,
                }
            end,
            IsTotalWindowFeatureEnabled = function()
                return false
            end,
            Print = function(_, message)
                messages[#messages + 1] = message
            end,
        })

        addon:HandleSlashCommand("addmat bad")
        addon:HandleSlashCommand("addmat 14256 classic tailoring Cloth")
        addon:HandleSlashCommand("unknown")

        assert.matches("Usage: /gt addmat", messages[1])
        assert.matches("Added custom material item 14256", messages[2])
        assert.equals("Unknown command. Use /gt help", messages[3])
    end)
end)

describe("Core/Bootstrap world-entry behavior", function()
    it("auto-starts on initial login, reload, or instance entry when enabled", function()
        local addon = load_bootstrap({
            db = {
                autoStartSessionOnEnterWorld = true,
            },
        })

        assert.is_true(addon:ShouldAutoStartOnWorldEntry(true, false))
        assert.is_true(addon:ShouldAutoStartOnWorldEntry(false, true))
        loader.with_globals({
            IsInInstance = function()
                return true, "party"
            end,
        }, function()
            assert.is_true(addon:ShouldAutoStartOnWorldEntry(false, false))
        end)
    end)

    it("opens auctionable inventory only for sell tab display modes", function()
        local opened = 0
        local addon = load_bootstrap({
            IsAutoOpenAuctionableInventoryOnAuctionHouseEnabled = function()
                return true
            end,
            OpenInventoryWindow = function()
                opened = opened + 1
            end,
        })

        loader.with_globals({
            AuctionHouseFrameDisplayMode = {
                Sell = "sell",
                CommoditiesSell = "commodity",
            },
            AuctionHouseFrame = {
                displayMode = "sell",
            },
        }, function()
            assert.is_true(addon:IsAuctionHouseSellTabSelected())
            addon:OpenAuctionableInventoryIfAuctionHouseSellTabSelected()
        end)

        assert.equals(1, opened)
    end)
end)
