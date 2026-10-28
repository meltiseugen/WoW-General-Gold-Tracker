local loader = require("tests.helpers.addon_loader")
local ui = require("tests.helpers.options_ui")

local function with_help(callback, skin)
    ui.with_ui(function(addon, ns, widgets)
        for _, path in ipairs({ "UI/HelpContent.lua", "UI/HelpWindow.lua" }) do
            loader.load_module(path, addon, ns)
        end
        addon:OpenHelpWindow()
        callback(addon, ns, widgets)
    end, 1000, skin)
end

describe("Searchable addon guide", function()
    it("searches full text with all words, literal punctuation, and mixed case", function()
        with_help(function(addon)
            local frame = addon.helpFrame
            ui.input(frame.searchInput, "REGION commodity")
            assert.equals(1, #frame.matchingTopics)
            assert.equals("gold", frame.selectedTabKey)
            assert.is_true(frame.tabButtons.gold:IsShown())
            assert.is_false(frame.tabButtons.history:IsShown())
            ui.input(frame.searchInput, "Ctrl+A")
            assert.equals("farms", frame.selectedTabKey)
            ui.input(frame.searchInput, "[nonexistent%")
            assert.equals(0, #frame.matchingTopics)
            assert.equals("No matching topics", frame.heading:GetText())
            assert.is_false(frame.sectionCards[1]:IsShown())
            ui.click(frame.clearSearchButton)
            assert.equals(#frame.topics, #frame.matchingTopics)
            assert.equals("overview", frame.selectedTabKey)
        end)
    end)

    it("restores independent reading positions and clamps them after resize", function()
        with_help(function(addon)
            local frame = addon.helpFrame
            frame:SetSize(760, 480)
            addon:UpdateHelpWindow()
            addon:SelectHelpTab("gold")
            frame.scrollFrame:SetVerticalScroll(100)
            addon:SelectHelpTab("bank")
            frame.scrollFrame:SetVerticalScroll(60)
            addon:SelectHelpTab("gold")
            assert.equals(100, frame.scrollFrame:GetVerticalScroll())
            frame:Hide()
            addon:OpenHelpWindow()
            assert.equals(100, frame.scrollFrame:GetVerticalScroll())
            frame:SetSize(1320, 960)
            addon:UpdateHelpWindow()
            assert.is_true(frame.scrollFrame:GetVerticalScroll() <= frame.scrollFrame:GetVerticalScrollRange())
            addon:SelectHelpTab("bank")
            assert.is_true(frame.scrollFrame:GetVerticalScroll() <= frame.scrollFrame:GetVerticalScrollRange())
        end)
    end)

    it("clears search and opens realm setup at the top from the item-details entry point", function()
        with_help(function(addon)
            local frame = addon.helpFrame
            ui.input(frame.searchInput, "bank")
            addon:OpenTSMRealmSetupHelp()
            assert.equals("", frame.searchInput:GetText())
            assert.equals("values", frame.selectedTabKey)
            assert.equals(0, frame.scrollFrame:GetVerticalScroll())
            assert.equals("Realm setup: compare prices across realms", frame.sectionCards[1].title:GetText())
            local text = frame.sectionCards[1].body:GetText()
            assert.matches("Settings > General", text)
            assert.matches("/reload", text)
            assert.matches("automatically lists the realms", text)
            assert.is_true(frame.topicScroll:GetVerticalScroll() > 0)
        end)
    end)

    it("reflows every topic at the smallest and largest sizes in all six skins", function()
        for _, skin in ipairs({ "midnight", "parchment", "quietBotanical", "quietArcane", "fieldLedger", "minimalVoidglass" }) do
            with_help(function(addon, ns)
                local frame = addon.helpFrame
                for _, size in ipairs({ {760, 480}, {960, 700}, {1320, 960} }) do
                    frame:SetSize(unpack(size))
                    for _, topic in ipairs(frame.topics) do
                        addon:SelectHelpTab(topic.key)
                        assert.is_true(frame.scrollFrame:GetHeight() > 140)
                        assert.is_true(frame.scrollContent:GetWidth() > 400)
                        local previousBottom
                        for index = 1, #topic.sections do
                            local card = frame.sectionCards[index]
                            local y, h = card:Bounds("y")
                            local by, bh = card.body:Bounds("y")
                            assert.is_true(by + bh <= y + h - 10)
                            if previousBottom then assert.is_true(y >= previousBottom + 10) end
                            previousBottom = y + h
                            assert.same(ns.JanisTheme:GetColor("text"), card.body.color)
                        end
                    end
                end
            end, skin)
        end
    end)

    it("keeps guides available when all modules are disabled and refreshes current pricing on reopen", function()
        with_help(function(addon)
            for _, module in ipairs(addon:GetExplorerModuleDefinitions()) do addon.db[module.key] = false end
            addon.GetCurrentValueSource = function() return { label = "Updated pricing" } end
            addon.helpFrame:Hide()
            addon:OpenHelpWindow("overview")
            assert.equals(19, #addon.helpFrame.topics)
            assert.matches("Updated pricing", addon.helpFrame.sectionCards[4].body:GetText())
            for _, key in ipairs({ "session", "loot", "history", "values", "bank", "maps", "farms" }) do
                addon:SelectHelpTab(key)
                assert.equals(key, addon.helpFrame.selectedTabKey)
            end
        end)
    end)
end)
