local loader = require("tests.helpers.addon_loader")

local function frame(name, strata, level, parent)
    local value = { name = name, strata = strata or "MEDIUM", level = level or 10,
        parent = parent, scripts = {}, events = {}, mutations = {}, shown = true }
    function value:GetName() return self.name end
    function value:GetParent() return self.parent end
    function value:GetFrameStrata() return self.strata end
    function value:GetFrameLevel() return self.level end
    function value:IsShown() return self.shown end
    function value:SetFrameStrata(strataValue)
        self.mutations[#self.mutations + 1] = "strata"
        self.strata = strataValue
    end
    function value:SetFrameLevel(levelValue)
        self.mutations[#self.mutations + 1] = "level"
        self.level = levelValue
    end
    function value:SetToplevel() self.mutations[#self.mutations + 1] = "toplevel" end
    function value:Raise() self.mutations[#self.mutations + 1] = "raise" end
    function value:SetScript(event, callback) self.scripts[event] = callback end
    function value:HookScript(event, callback) self.scripts[event] = callback end
    function value:RegisterEvent(event) self.events[event] = true end
    return value
end

local function with_theme(globals, callback)
    local focus, down
    globals.CreateFrame = function() return frame() end
    globals.GetMouseFoci = function() return { focus } end
    globals.IsMouseButtonDown = function() return down end
    loader.with_globals(globals, function()
        assert(loadfile("Libs/JanisTheme-1.0/JanisTheme-1.0.lua"))()
        local _, ns = loader.load_module("UI/Theme.lua", {})
        local theme = ns.JanisTheme
        theme:EnsureWindowFocusWatcher()
        local function click(target)
            focus = target
            local watcher = theme.windowFocusWatcher
            -- Exercise the previous polling path as well as the replacement event path.
            if watcher.scripts.OnEvent then
                watcher.scripts.OnEvent(watcher, "GLOBAL_MOUSE_DOWN", "LeftButton")
            else
                down = true
                watcher.scripts.OnUpdate(watcher)
                down = false
                watcher.scripts.OnUpdate(watcher)
            end
        end
        callback(theme, click)
    end)
end

local function assert_untouched(target)
    assert.same({}, target.mutations, target.name)
    assert.same({}, target.scripts, target.name)
    assert.is_nil(target.goldTrackerManagedWindow)
    assert.is_nil(target.goldTrackerWindowFocusRegistered)
end

describe("UI/Theme external window isolation", function()
    it("does not hook common Blizzard windows when the theme loads or GGT opens", function()
        local names = { "AuctionHouseFrame", "CharacterFrame", "CollectionsJournal", "EncounterJournal",
            "FriendsFrame", "GameMenuFrame", "GuildFrame", "PVEFrame", "PlayerSpellsFrame", "ProfessionsFrame",
            "QuestLogPopupDetailFrame", "SettingsPanel", "SpellBookFrame", "TradeSkillFrame" }
        local globals = { UIPanelWindows = {} }
        for _, name in ipairs(names) do globals[name] = frame(name) end
        with_theme(globals, function(theme, click)
            local own = frame("GoldTrackerMainFrame", "DIALOG")
            theme:RegisterWindowForFocus(own, "addon")
            theme:BringManagedWindowToFront(own)
            for _, name in ipairs(names) do
                local target = globals[name]
                if target.scripts.OnShow then target.scripts.OnShow(target) end
                click(target)
                assert_untouched(target)
            end
        end)
    end)

    it("keeps Talents below its separate Hero Talents dialog after repeated clicks", function()
        local talents = frame("PlayerSpellsFrame", "HIGH", 10)
        local hero = frame("HeroTalentsSelectionDialog", "DIALOG", 20)
        local talent_button = frame(nil, "HIGH", 11, talents)
        local hero_button = frame(nil, "DIALOG", 21, hero)
        with_theme({ PlayerSpellsFrame = talents, UIPanelWindows = {} }, function(_, click)
            if talents.scripts.OnShow then talents.scripts.OnShow(talents) end
            for _ = 1, 5 do
                click(talent_button)
                click(hero_button)
            end
            assert.equals("HIGH", talents.strata)
            assert.equals("DIALOG", hero.strata)
            assert_untouched(talents)
            assert_untouched(hero)
        end)
    end)

    it("leaves a late-loaded mission table and Baganator in their native strata with GGT hidden", function()
        local panels = {}
        with_theme({ UIPanelWindows = panels }, function(theme, click)
            local own = frame("GoldTrackerMainFrame", "DIALOG")
            own.shown = false
            theme:RegisterWindowForFocus(own, "addon")
            local mission = frame("GarrisonMissionFrame", "MEDIUM", 10)
            local bags = frame("BaganatorCategoryViewBackpackView", "MEDIUM", 15)
            panels.GarrisonMissionFrame = { area = "center" }
            for _ = 1, 5 do
                click(frame(nil, nil, nil, mission))
                click(frame(nil, nil, nil, bags))
            end
            assert.equals("MEDIUM", mission.strata)
            assert.equals("MEDIUM", bags.strata)
            assert.is_true(bags.level > mission.level)
            assert_untouched(mission)
            assert_untouched(bags)
        end)
    end)

    it("ignores unknown UI panels and external frames even through direct focus calls", function()
        local panels = {}
        with_theme({ UIPanelWindows = panels }, function(theme, click)
            local names = { "FutureBlizzardPanel", "OtherAddonWindow", "WorldMapFrame", "PerksProgramFrame" }
            for _, name in ipairs(names) do
                local target = frame(name)
                panels[name] = {}
                click(target)
                assert.is_nil(theme:FindFocusableWindow(target))
                assert.is_nil(theme:BringManagedWindowToFront(target))
                assert.is_nil(theme:RegisterWindowForFocus(target, "external"))
                assert_untouched(target)
            end
        end)
    end)

    it("requires a registered owner for aliases while preserving embedded GGT window focus", function()
        with_theme({ UIPanelWindows = {} }, function(theme, click)
            local explorer = frame("GoldTrackerExplorerFrame", "DIALOG")
            local embedded = frame("GoldTrackerInventoryFrame", "DIALOG", 11, explorer)
            theme:RegisterWindowForFocus(explorer, "addon")
            theme:RegisterWindowForFocus(embedded, "addon")
            embedded.goldTrackerManagedWindow = explorer
            click(frame(nil, nil, nil, embedded))
            assert.equals(explorer, theme:FindFocusableWindow(embedded))
            assert.equals("raise", explorer.mutations[#explorer.mutations])

            local foreign = frame("UnregisteredWindow")
            foreign.goldTrackerManagedWindow = foreign
            assert.is_nil(theme:BringManagedWindowToFront(foreign))
            embedded.goldTrackerManagedWindow = foreign
            assert.is_nil(theme:BringManagedWindowToFront(embedded))
            assert.same({}, foreign.mutations)
        end)
    end)

    it("does not inspect forbidden mouse-focus frames", function()
        with_theme({ UIPanelWindows = {} }, function(theme, click)
            theme:RegisterWindowForFocus(frame("GoldTrackerMainFrame"), "addon")
            local forbidden = {
                IsForbidden = function() return true end,
                GetParent = function() error("must not inspect a forbidden frame") end,
            }
            click(forbidden)
            assert.is_nil(theme:BringManagedWindowToFront(forbidden))
        end)
    end)

    it("yields only GGT windows on external clicks and restores GGT focus on return", function()
        with_theme({ UIPanelWindows = {} }, function(theme, click)
            local own = frame("GoldTrackerMainFrame", "DIALOG")
            local foreign = frame("OtherAddonWindow", "MEDIUM")
            theme:RegisterWindowForFocus(own, "addon")
            local watcher = theme.windowFocusWatcher
            assert.is_true(watcher.events.GLOBAL_MOUSE_DOWN)
            assert.is_nil(watcher.scripts.OnUpdate)

            click(own)
            assert.equals("DIALOG", own.strata)
            click(foreign)
            assert.equals("HIGH", own.strata)
            click(own)
            assert.equals("DIALOG", own.strata)
            assert_untouched(foreign)
        end)
    end)
end)
