local loader = require("tests.helpers.addon_loader")

local function make_frame(parent)
    local frame = { parent = parent, scripts = {}, shown = true }
    for _, method in ipairs({ "SetPoint", "SetFrameStrata", "SetClampedToScreen", "EnableMouse", "RegisterEvent",
        "SetJustifyH", "SetJustifyV", "SetWordWrap", "Raise" }) do
        frame[method] = function() end
    end
    function frame:SetSize(width, height) self.width, self.height = width, height end
    function frame:SetText(text) self.text = text end
    function frame:SetScript(event, callback) self.scripts[event] = callback end
    function frame:SetShown(shown) self.shown = shown end
    function frame:Show() self.shown = true end
    function frame:Hide() self.shown = false end
    function frame:IsShown() return self.shown end
    function frame:SetEnabled(enabled) self.enabled = enabled end
    function frame:SetSelected(selected) self.selected = selected end
    function frame:CreateFontString() return make_frame(self) end
    return frame
end

local function with_dialog(callback)
    local menu, buttons = {}, {}
    local theme = {
        ApplyWindowChrome = function(_, frame) return frame end,
        RegisterSpecialFrame = function() end,
        CreatePanel = function(_, parent) return make_frame(parent) end,
        CreateButton = function(_, parent, _, _, text)
            local button = make_frame(parent)
            button.text = text
            buttons[text] = button
            return button
        end,
    }
    local addon = { db = {}, Print = function() end }
    loader.with_globals({
        UIParent = make_frame(),
        CreateFrame = function(_, _, parent) return make_frame(parent) end,
        UIDropDownMenu_Initialize = function(frame, initializer) frame.initialize = initializer end,
        UIDropDownMenu_SetWidth = function(frame, width) frame.width = width end,
        UIDropDownMenu_SetSelectedValue = function(frame, value) frame.selectedValue = value end,
        UIDropDownMenu_SetText = function(frame, text) frame.text = text end,
        UIDropDownMenu_CreateInfo = function() return {} end,
        UIDropDownMenu_AddButton = function(info) menu[#menu + 1] = info end,
    }, function()
        loader.load_module("UI/MyFarmsWindow.lua", addon, { JanisTheme = theme })
        addon.CreateFarmingMapPreview = function(_, parent) return make_frame(parent) end
        addon.RefreshFarmingMapPreview = function(_, frame, option)
            frame.option = option
            frame.refreshes = (frame.refreshes or 0) + 1
        end
        local options = {
            { id = "throne", mapID = 100, label = "Throne", sourceType = "static", pins = { { mapID = 100, x = 0.4, y = 0.6 } } },
            { id = "pits", mapID = 104, label = "Fel Pits", sourceType = "static", pins = { { mapID = 104, x = 0.5, y = 0.7 } } },
            { mapID = 100, label = "Hellfire (User)", sourceType = "user", pins = { { mapID = 100, x = 0.6, y = 0.8 } } },
        }
        addon.BuildMaterialFarmingMapOptions = function() return options end
        addon.BuildFarmDetailsMapOptions = function(_, farms)
            return farms[1] and farms[1].mapOptions or {}
        end
        local farm = addon:CreateCustomFarm("Fire", true)
        local entry = addon:BuildCustomFarmEntry({ itemID = 22574, itemName = "Mote of Fire" }, "materials")
        callback(addon, farm, entry, options, buttons, menu)
    end)
end

describe("UI/CustomFarmMethodDialog", function()
    it("switches sources, previews only the selected overlay and commits the user map", function()
        with_dialog(function(addon, farm, entry, options, _, menu)
            assert.is_true(addon:ShowCustomFarmMethodDialog({ farmID = farm.id, entry = entry,
                farms = { { id = "catalog:fire", name = "Fire", mapNames = { "Hellfire" }, targets = {},
                    mapOptions = { options[1] } } } }))
            local frame = addon.customFarmMethodDialog
            assert.equals("map", frame.selectedDataType)
            assert.equals("catalog", frame.selectedMethodKind)
            assert.is_true(frame.mapPreview.shown)
            assert.equals(options[1], frame.mapPreview.option)
            frame.methodDropdown.initialize(nil, 1)
            assert.equals(4, #menu)
            menu[3].func()
            assert.equals(options[2], frame.mapPreview.option)
            menu[4].func()
            assert.equals(options[3], frame.mapPreview.option)
            local renders = frame.mapPreview.refreshes
            frame.scripts.OnEvent(frame)
            assert.equals(renders, frame.mapPreview.refreshes)
            assert.equals(0, #farm.entries)
            frame.acceptButton.scripts.OnClick()
            assert.equals("user", farm.entries[1].mapSource.sourceType)
            assert.is_nil(farm.entries[1].catalogFarmID)
            assert.is_false(frame.shown)
        end)
    end)

    it("cancels without creating a farm and supports items that only have maps", function()
        with_dialog(function(addon, _, entry, options, buttons)
            local before = #addon:GetCustomFarms()
            assert.is_true(addon:ShowCustomFarmMethodDialog({ entry = entry, farms = {}, mapOptions = options }))
            local frame = addon.customFarmMethodDialog
            assert.equals("map", frame.selectedDataType)
            assert.is_true(frame.dataTypeButtons.map.enabled)
            assert.is_nil(frame.dataTypeButtons.farm)
            buttons.Cancel.scripts.OnClick()
            assert.equals(before, #addon:GetCustomFarms())
            assert.is_false(frame.shown)
        end)
    end)

    it("preserves a saved source selection and can detach map data", function()
        with_dialog(function(addon, farm, entry, options)
            assert.is_true(addon:CommitCustomFarmEntry({ farmID = farm.id, entry = entry }, nil, options[2]))
            local saved = farm.entries[1]
            assert.is_true(addon:ShowCustomFarmMethodDialog({ farmID = farm.id, entryID = saved.id,
                entry = saved, farms = {}, mapOptions = {} }))
            local frame = addon.customFarmMethodDialog
            assert.equals("map", frame.selectedDataType)
            assert.equals(104, frame.mapPreview.option.mapID)
            frame.dataTypeButtons.item.scripts.OnClick()
            frame.acceptButton.scripts.OnClick()
            assert.equals(1, #farm.entries)
            assert.is_nil(farm.entries[1].mapSource)
            assert.equals(entry.entryKey, farm.entries[1].entryKey)
        end)
    end)
end)
