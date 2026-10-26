local loader = require("tests.helpers.addon_loader")

local function button()
    return {
        SetShown = function(self, shown) self.shown = shown end,
        SetText = function(self, text) self.text = text end,
        SetSelected = function(self, selected) self.selected = selected end,
    }
end

local function load_my_farms(addon)
    return loader.load_module("UI/MyFarmsWindow.lua", addon or {}, {
        JanisTheme = {},
    })
end

describe("UI/MyFarmsWindow route run button", function()
    it("hides low-level farm choices while allowing an excluded existing assignment to be cleared", function()
        local addon = load_my_farms({ db = { altCharacters = {
            low = { name = "Amy", realm = "Realm A", level = 10 },
        } } })
        loader.load_module("Core/AltTracker.lua", addon)
        local farm = addon:CreateCustomFarm("Farm", false)
        farm.assignedCharacter = "Amy-Realm A"
        local frame = { characterDropdown = {}, noCharactersText = button(), selectedFarmID = farm.id,
            IsShown = function() return true end }
        addon.myFarmsFrame = frame
        addon.RefreshMyFarmsWindow = function(self) self:RefreshMyFarmsCharacterDropdown(farm) end
        local entries = {}
        loader.with_globals({
            UIDropDownMenu_CreateInfo = function() return {} end,
            UIDropDownMenu_AddButton = function(info) entries[#entries + 1] = info end,
            UIDropDownMenu_SetText = function(dropdown, text) dropdown.text = text end,
            UIDropDownMenu_EnableDropDown = function(dropdown) dropdown.enabled = true end,
            UIDropDownMenu_DisableDropDown = function(dropdown) dropdown.enabled = false end,
        }, function()
            addon:RefreshMyFarmsCharacterDropdown(farm)
            addon:PopulateMyFarmsCharacterDropdown(farm.id, 1)
            assert.equals("Select a character", frame.characterDropdown.text)
            assert.is_true(frame.characterDropdown.enabled)
            assert.equals(1, #entries)
            assert.equals("None", entries[1].text)
            entries[1].func()
            assert.is_nil(farm.assignedCharacter)
            assert.is_false(frame.characterDropdown.enabled)
            addon:SetAltLowLevelThreshold(0)
            entries = {}
            addon:PopulateMyFarmsCharacterDropdown(farm.id, 1)
            assert.equals("Amy-Realm A", entries[3].value)
            assert.is_true(frame.characterDropdown.enabled)
        end)
    end)

    it("opens the requested configuration in My Farms even when the catalog was previously selected", function()
        for _, alreadyCreated in ipairs({ false, true }) do
            local addon = load_my_farms({ db = {} })
            local other = addon:CreateCustomFarm("Farm", false)
            local target = addon:CreateCustomFarm("Farm", false)
            local frame = {
                selectedFarmID = other.id, farmsWorkspaceView = "catalog",
                myFarmsViewWidgets = {}, catalogPanel = button(), catalogMetaText = button(),
                myFarmsTabButton = button(), farmsTabButton = button(),
            }
            if alreadyCreated then addon.myFarmsFrame = frame end
            local openedTab, refreshedID, creates = nil, nil, 0
            addon.CreateMyFarmsWindow = function(self)
                creates = creates + 1
                self.myFarmsFrame = frame
                return frame
            end
            addon.RefreshMyFarmsWindow = function(self) refreshedID = self.myFarmsFrame.selectedFarmID end
            addon.RefreshFarmCatalogWindow = function() error("Opening an assigned farm must show its configuration") end
            addon.OpenExplorerWindow = function(_, tabID) openedTab = tabID end
            assert.is_true(addon:OpenCustomFarmConfiguration(target.id))
            assert.equals(target.id, frame.selectedFarmID)
            assert.equals(target.id, refreshedID)
            assert.equals("my", frame.farmsWorkspaceView)
            assert.equals("farms", openedTab)
            assert.is_false(frame.catalogPanel.shown)
            assert.is_false(addon:OpenCustomFarmConfiguration(999999))
            assert.equals(1, creates)
        end
    end)

    it("shows Start for a planned farm that is not active", function()
        local farm = { id = "farm-1" }
        local addon = load_my_farms({
            IsCustomFarmRoutePlanActive = function(_, farmID)
                assert.equals(farm.id, farmID)
                return false
            end,
            myFarmsFrame = { routeRunButton = button() },
        })

        assert.is_false(addon:RefreshMyFarmsRouteRunButton(farm, true))
        assert.is_true(addon.myFarmsFrame.routeRunButton.shown)
        assert.equals("Start", addon.myFarmsFrame.routeRunButton.text)
        assert.is_false(addon.myFarmsFrame.routeRunButton.selected)
    end)

    it("changes to Stop while the selected farm is active", function()
        local farm = { id = "farm-1" }
        local addon = load_my_farms({
            IsCustomFarmRoutePlanActive = function() return true end,
            myFarmsFrame = { routeRunButton = button() },
        })

        assert.is_true(addon:RefreshMyFarmsRouteRunButton(farm, true))
        assert.is_true(addon.myFarmsFrame.routeRunButton.shown)
        assert.equals("Stop", addon.myFarmsFrame.routeRunButton.text)
        assert.is_true(addon.myFarmsFrame.routeRunButton.selected)
    end)

    it("hides the control until the farm has a route plan", function()
        local addon = load_my_farms({
            IsCustomFarmRoutePlanActive = function()
                error("inactive farms without plans must not query route state")
            end,
            myFarmsFrame = { routeRunButton = button() },
        })

        assert.is_false(addon:RefreshMyFarmsRouteRunButton({ id = "farm-1" }, false))
        assert.is_false(addon.myFarmsFrame.routeRunButton.shown)
        assert.equals("Start", addon.myFarmsFrame.routeRunButton.text)
    end)
end)

describe("UI/MyFarmsWindow character suggestions", function()
    it("shows profession reasons under Suggestions and rejects a choice newly marked as Bank", function()
        local addon = load_my_farms({ db = {
            altCharacters = {
                skinner = { name = "Skinner", realm = "Realm", level = 80,
                    professions = { { name = "Skinning", skillLineID = 393 } },
                    location = { continentMapID = 200, continentName = "Outland" } },
                near = { name = "Near", realm = "Realm", level = 80,
                    location = { continentMapID = 100, continentName = "Kalimdor" } },
                bank = { name = "Bank", realm = "Realm", roles = { bank = true }, level = 80 },
            },
            customFarms = { knownCharacters = { ["Legacy-Realm"] = true }, farms = {
                { id = 1, name = "Skins", entries = { { itemID = 2318, catalogActivity = "skinning", mapID = 10 } } },
            } },
        } })
        addon.GetAltMapHierarchy = function(_, mapID) return { continentMapID = mapID == 10 and 100 or nil } end
        local entries = {}
        loader.with_globals({
            UIDropDownMenu_CreateInfo = function() return {} end,
            UIDropDownMenu_AddButton = function(info) entries[#entries + 1] = info end,
        }, function() addon:PopulateMyFarmsCharacterDropdown(1, 1) end)
        assert.equals(4, #entries)
        assert.equals("Suggestions", entries[2].text)
        assert.equals("Skinner - Outland", entries[3].text)
        assert.equals("Profession match: Skinning.", entries[3].tooltipText)
        assert.equals("Near - Kalimdor", entries[4].text)
        addon.db.altCharacters.skinner.roles = { bank = true }
        entries[3].func()
        assert.is_nil(addon:GetCustomFarmByID(1).assignedCharacter)
        addon.db.altCharacters.skinner.roles = nil
        entries[3].func()
        assert.equals("Skinner-Realm", addon:GetCustomFarmByID(1).assignedCharacter)
    end)

    it("shows grouped continent labels, preserves full identities, and refreshes assignment choices", function()
        local addon = load_my_farms({ db = {
            altCharacters = {
                near = { name = "Near", realm = "Realm One", location = { continentMapID = 100, continentName = "Kalimdor" } },
                far = { name = "Far", realm = "Realm Two", location = { continentMapID = 200, continentName = "Outland" } },
                busy = { name = "Busy", realm = "Realm One", location = { continentMapID = 100, continentName = "Kalimdor" } },
            },
            customFarms = {
                knownCharacters = { ["Near - RealmOne"] = true, ["Legacy-Realm Three"] = true },
                farms = {
                    { id = 1, name = "Target", assignedCharacter = "Busy - RealmOne", entries = { { itemID = 2770, mapID = 10 } } },
                    { id = 2, name = "Other", assignedCharacter = "Busy-RealmOne", entries = {} },
                },
            },
        } })
        addon.GetAltMapHierarchy = function(_, mapID) return { continentMapID = mapID == 10 and 100 or nil } end
        local farm = addon:GetCustomFarmByID(1)
        local frame = { characterDropdown = {}, noCharactersText = button(), selectedFarmID = farm.id }
        addon.myFarmsFrame = frame
        addon.RefreshMyFarmsWindow = function(self) self:RefreshMyFarmsCharacterDropdown(farm) end
        local entries = {}
        loader.with_globals({
            UIDropDownMenu_CreateInfo = function() return {} end,
            UIDropDownMenu_AddButton = function(info, level)
                assert.equals(1, level)
                entries[#entries + 1] = info
            end,
            UIDropDownMenu_SetText = function(dropdown, text) dropdown.text = text end,
            UIDropDownMenu_EnableDropDown = function(dropdown) dropdown.enabled = true end,
        }, function()
            addon:RefreshMyFarmsCharacterDropdown(farm)
            assert.equals("Busy - Kalimdor", frame.characterDropdown.text)
            assert.is_true(frame.characterDropdown.enabled)
            assert.is_false(frame.noCharactersText.shown)
            addon:PopulateMyFarmsCharacterDropdown(farm.id, 1)
            local labels = {}
            for _, entry in ipairs(entries) do labels[#labels + 1] = entry.text end
            assert.same({
                "None", "Suggestions", "Near - Kalimdor", "Unassigned", "Far - Outland",
                "Assigned", "Busy - Kalimdor",
            }, labels)
            assert.is_true(entries[2].disabled)
            assert.is_true(entries[2].notCheckable)
            assert.equals("Near-Realm One", entries[3].value)
            assert.equals("Near-Realm One", entries[3].tooltipTitle)
            assert.is_true(entries[7].checked)
            assert.is_false(entries[1].checked)
            entries[3].func()
            assert.equals("Near-Realm One", farm.assignedCharacter)
            assert.equals("Near - Kalimdor", frame.characterDropdown.text)

            entries = {}
            addon:PopulateMyFarmsCharacterDropdown(farm.id, 1)
            local checked = 0
            for _, entry in ipairs(entries) do
                assert.is_false(entry.text == "Suggestions")
                if entry.checked then checked = checked + 1; assert.equals("Near-Realm One", entry.value) end
            end
            assert.equals(1, checked)
            entries[1].func()
            assert.is_nil(farm.assignedCharacter)
            assert.equals("Select a character", frame.characterDropdown.text)
            entries = {}
            addon:PopulateMyFarmsCharacterDropdown(farm.id, 1)
            assert.is_true(entries[1].checked)
            assert.equals("Suggestions", entries[2].text)
        end)
    end)

    it("keeps same-name characters distinct through values and hover details", function()
        local addon = load_my_farms({ db = { altCharacters = {
            first = { name = "Janis", realm = "First Realm", location = { continentMapID = 100, continentName = "Kalimdor" } },
            second = { name = "Janis", realm = "Second Realm", location = { continentMapID = 100, continentName = "Kalimdor" } },
        } } })
        local farm = addon:CreateCustomFarm("Farm", false)
        addon:SetCustomFarmAssignedCharacter(farm.id, "Janis - SecondRealm")
        local choices = {}
        loader.with_globals({
            UIDropDownMenu_CreateInfo = function() return {} end,
            UIDropDownMenu_AddButton = function(info)
                if info.value and info.value ~= "__NONE__" then choices[#choices + 1] = info end
            end,
        }, function() addon:PopulateMyFarmsCharacterDropdown(farm.id, 1) end)
        assert.equals(2, #choices)
        assert.equals("Janis - Kalimdor", choices[1].text)
        assert.equals(choices[1].text, choices[2].text)
        assert.equals("Janis-First Realm", choices[1].tooltipTitle)
        assert.equals("Janis-Second Realm", choices[2].tooltipTitle)
        assert.is_false(choices[1].checked)
        assert.is_true(choices[2].checked)
        choices[1].func()
        assert.equals("Janis-First Realm", farm.assignedCharacter)
    end)
end)
