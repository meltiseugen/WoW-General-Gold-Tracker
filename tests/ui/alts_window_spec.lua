local loader = require("tests.helpers.addon_loader")

local widget = require("tests.helpers.map_ui").widget

local function with_window(callback, savedDB)
    local mapData = { revealedOverlays = { [500] = "300,270,10,20|0:0:901,1:0:902,0:1:903,1:1:904" }, tiles = {}, clearArt = {} }
    loader.with_globals({
        CreateFrame = widget,
        UIParent = widget(),
        date = function() return "21 Oct 2026, 12:00" end,
        UIDropDownMenu_SetWidth = function() end,
        UIDropDownMenu_SetText = function(dropdown, text) dropdown.text = text end,
        UIDropDownMenu_Initialize = function(dropdown, callback) dropdown.initialize = callback end,
        UIDropDownMenu_CreateInfo = function() return {} end,
        UIDropDownMenu_AddButton = function() end,
        C_Map = {
            GetMapInfo = function(id)
                if id == 200 then return { mapID = 200, name = "Kalimdor", mapType = 2, parentMapID = 946 } end
                if id == 300 then return { mapID = 300, name = "Other continent", mapType = 2, parentMapID = 946 } end
                if id == 100 then return { mapID = 100, name = "Zone", mapType = 3, parentMapID = 200 } end
                if id == 101 then return { mapID = 101, name = "Other zone", mapType = 3, parentMapID = 300 } end
            end,
            GetMapChildrenInfo = function(id, mapType)
                if id == 946 and mapType == 2 then return { C_Map.GetMapInfo(200), C_Map.GetMapInfo(300) } end
                return { C_Map.GetMapInfo(id == 200 and 100 or 101) }
            end,
            GetMapRectOnMap = function(id, root)
                if root == 200 and id == 100 then return 0.2, 0.7, 0.3, 0.8 end
                if root == 300 and id == 101 then return 0.1, 0.6, 0.2, 0.7 end
            end,
            GetMapArtLayers = function(mapID)
                if mapID == 999 then return end
                return { { layerWidth = 1000, layerHeight = 650, tileWidth = 256, tileHeight = 256 } }
            end,
            GetMapArtLayerTextures = function() return { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12 } end,
            GetMapArtID = function(id) return id + 400 end,
        },
    }, function()
        local theme = {
            CreatePanel = function(_, parent, bg)
                local panel = widget(nil, nil, parent)
                panel.bg = bg
                return panel
            end,
            CreateButton = function(_, parent, width, height, label)
                local button = widget(nil, nil, parent)
                button.label = button:CreateFontString()
                button:SetSize(width, height)
                button:SetText(label)
                return button
            end,
            ApplyWindowChrome = function(_, frame, title) frame.title = title; return frame end,
            RegisterSpecialFrame = function() end,
            CreateResizeButton = function(_, frame, options) frame.resizeOptions = options end,
        }
        local addon = { db = savedDB or { altCharacters = {} }, explorerFrame = { contentFrame = widget() } }
        if addon.db.enableExperimentalMaps == nil then addon.db.enableExperimentalMaps = true end
        loader.load_module("Core/AltTracker.lua", addon)
        loader.load_module("Core/AltMapOverview.lua", addon)
        loader.load_module("Core/AltDestinations.lua", addon)
        for _, name in ipairs({ "Geometry", "MapSource", "MapScene", "MapRenderer", "InteractiveMap" }) do
            loader.load_module("UI/Maps/" .. name .. ".lua", addon, { JanisTheme = theme,
                MapTerrainData = mapData })
        end
        loader.load_module("UI/AltsWindow.lua", addon, { JanisTheme = theme })
        loader.load_module("UI/AltsGlobalMapWindow.lua", addon, { JanisTheme = theme })
        loader.load_module("UI/AltDestinationPicker.lua", addon, { JanisTheme = theme })
        addon:CreateAltsWindow()
        callback(addon, addon.altsFrame, mapData)
    end)
end

describe("UI/AltsWindow", function()
    it("keeps character, continent and all Global Map tabs usable with seamless maps disabled", function()
        with_window(function(addon, frame)
            local oldInfo, oldRect, oldChildren = C_Map.GetMapInfo, C_Map.GetMapRectOnMap, C_Map.GetMapChildrenInfo
            local worlds = { [947] = "Azeroth", [101] = "Outland", [572] = "Draenor", [1550] = "Shadowlands" }
            C_Map.GetMapInfo = function(id)
                if worlds[id] then return { mapID = id, name = worlds[id], mapType = id == 947 and 1 or 2, parentMapID = 946 } end
                if id == 200 then return { mapID = id, name = "Kalimdor", mapType = 2, parentMapID = 947 } end
                return oldInfo(id)
            end
            C_Map.GetMapRectOnMap = function(id, root)
                if root == 947 then
                    if id == 200 then return 0.1, 0.9, 0.1, 0.9 end
                    if id == 100 then return 0.26, 0.66, 0.34, 0.74 end
                end
                return oldRect(id, root)
            end
            C_Map.GetMapChildrenInfo = function(id, ...)
                if id == 947 then return { C_Map.GetMapInfo(200), C_Map.GetMapInfo(100) } end
                return oldChildren(id, ...)
            end
            addon.altTrackerLeavingWorld = true
            addon.db.altCharacters = {
                a = { name = "Amy", roles = { bank = true }, level = 1, location = {
                    mapID = 100, mapName = "Zone", continentMapID = 200, continentName = "Kalimdor", x = 0.3, y = 0.4,
                    parentMapID = 200, parentX = 0.35, parentY = 0.5 },
                    destination = { mapID = 100, mapName = "Zone", x = 0.6, y = 0.7 } },
                b = { name = "Bo", level = 80, location = {
                    mapID = 100, continentMapID = 200, continentName = "Kalimdor", x = 0.7, y = 0.8,
                    parentMapID = 200, parentX = 0.55, parentY = 0.7 } },
            }
            frame.selectedGUID = "a"
            frame:Show()
            addon:RefreshAltsWindow()
            assert.is_true(frame.localMap.standard)
            assert.equals(100, frame.localMap.source.rootID)
            assert.is_true(frame.localMap.pin.shown)
            assert.is_true(frame.roleButton.shown)
            assert.is_true(frame.destinationPanel.shown)
            addon:ShowAltContinentMap(200)
            assert.equals(200, frame.localMap.source.rootID)
            assert.equals(1, #frame.localMap.characterLocations)
            assert.equals(0, frame.localMap.renderer.terrainCount)
            frame.globalMapButton.scripts.OnClick()
            local global = addon.altsGlobalMapFrame
            assert.equals(2, #global.map.characterLocations)
            for _, tab in ipairs(global.worldTabs) do
                tab.scripts.OnClick()
                assert.equals(tab.worldID, global.map.source.rootID)
                assert.is_true(global.map.standard)
                assert.equals(1, #global.map.source.nodes)
                assert.equals(0, global.map.renderer.terrainCount)
                assert.is_true(global.map.hasMapArt)
            end
            addon.db.enableExperimentalMaps = true
            addon:RefreshInteractiveMapStyles()
            assert.is_false(frame.localMap.standard)
            assert.is_false(global.map.standard)
            assert.is_not_nil(frame.localMap.source.byID[100])
            assert.is_not_nil(addon.db.altCharacters.a.destination)
            assert.is_true(addon.db.altCharacters.a.roles.bank)
        end, { enableExperimentalMaps = false, altCharacters = {} })
    end)

    it("opens a separate fully revealed Global Map with four world tabs and recorded alt markers", function()
        with_window(function(addon, frame)
            UIParent:SetSize(1920, 1080)
            addon.altTrackerLeavingWorld = true
            local roots = { [947] = "Azeroth", [101] = "Outland", [572] = "Draenor", [1550] = "Shadowlands" }
            local parents = { [200] = 947, [100] = 200, [110] = 101, [120] = 572, [130] = 1550 }
            C_Map.GetMapInfo = function(id)
                if roots[id] then return { mapID = id, name = roots[id], mapType = id == 947 and 1 or 2, parentMapID = 946 } end
                if parents[id] then return { mapID = id, name = "Zone " .. id, mapType = id == 200 and 2 or 3, parentMapID = parents[id] } end
            end
            C_Map.GetMapChildrenInfo = function(id)
                local out = {}
                for _, child in ipairs(id == 947 and { 200, 100 } or id == 101 and { 110 } or id == 572 and { 120 } or { 130 }) do
                    out[#out + 1] = C_Map.GetMapInfo(child)
                end
                return out
            end
            C_Map.GetMapRectOnMap = function(id, root)
                if id == 200 and root == 947 then return 0.1, 0.9, 0.1, 0.9 end
                if id == 100 and root == 200 then return 0.25, 0.5, 0.3, 0.7 end
                if id == 100 and root == 947 then return 0.3, 0.5, 0.34, 0.66 end
                if parents[id] == root then return 0.2, 0.8, 0.3, 0.7 end
            end
            addon.db.altCharacters = {
                low = { name = "Low", level = 1, roles = { main = true }, location = { mapID = 100, continentMapID = 200, x = 0.25, y = 0.75 } },
                bank = { name = "Bank", level = 80, roles = { bank = true }, location = { mapID = 100, continentMapID = 200, x = 0.75, y = 0.25 } },
                outland = { name = "Outland", location = { mapID = 110, continentMapID = 101, x = 0.5, y = 0.5 } },
                draenor = { name = "Draenor", location = { mapID = 120, continentMapID = 572, x = 0.5, y = 0.5 } },
                shadowlands = { name = "Shadowlands", location = { mapID = 130, continentMapID = 1550, x = 0.5, y = 0.5 } },
            }
            assert.equals("Global Map", frame.globalMapButton.text)
            assert.is_nil(addon.altsGlobalMapFrame)
            frame.globalMapButton.scripts.OnClick()
            local global = addon.altsGlobalMapFrame
            assert.is_true(global:IsShown())
            assert.equals(UIParent, global.parent)
            assert.equals("Global Map", global.title)
            assert.equals(1200, global.width)
            assert.equals(4, #global.worldTabs)
            assert.equals(947, global.map.source.rootID)
            assert.is_true(global.map.options.revealAll)
            assert.is_true(global.map.options.includeContinents)
            addon.MapGeometry.ZoomAt(global.map.view, 1.5, 300, 250)
            global.map:Render()
            assert.is_not_nil(global.map.source.byID[200].art)
            global.map:Reset()
            assert.equals(2, #global.map.characterLocations)
            assert.is_true(global.map.characterPins[1].shown)
            assert.equals(1, global.map.view.zoom)
            assert.is_true(global.worldTabs[1].selected)
            for i, world in ipairs(addon:GetAltGlobalMapWorlds()) do
                assert.equals(world.name, global.worldTabs[i].text)
                global.worldTabs[i].scripts.OnClick()
                assert.equals(world.id, global.selectedWorldID)
                assert.equals(world.id, global.map.source.rootID)
                assert.equals(i == 1 and 2 or 1, #global.map.characterLocations)
                assert.equals(1, global.map.view.zoom)
                assert.is_true(global.worldTabs[i].selected)
            end
            global.worldTabs[1].scripts.OnClick()
            addon.MapGeometry.ZoomAt(global.map.view, 4, 300, 250)
            global.map:Render()
            local pinData = global.map.characterLocations[1]
            local x, y = global.map:ProjectPoint(pinData.x, pinData.y)
            assert.near(x, global.map.characterPins[1].points[1][4], 0.000001)
            assert.near(-y, global.map.characterPins[1].points[1][5], 0.000001)
            global.map.resetButton.scripts.OnClick()
            assert.equals(1, global.map.view.zoom)
            global.map.viewport.scripts.OnMouseDown(nil, "LeftButton")
            global:Hide()
            assert.is_nil(global.map.viewport.scripts.OnUpdate)
            frame.globalMapButton.scripts.OnClick()
            assert.equals(global, addon.altsGlobalMapFrame)
            assert.is_true(global:IsShown())
            addon.db.altCharacters = {}
            global.worldTabs[2].scripts.OnClick()
            assert.equals(101, global.map.source.rootID)
            assert.equals(0, #global.map.characterLocations)
            assert.is_true(global.map.hasMapArt)
            assert.is_false(global.map.characterPins[1].shown)
        end)
    end)

    it("shows low-level alts in a collapsed group and moves them back when the cutoff changes", function()
        with_window(function(addon, frame)
            addon.currentAltGUID = "online-other"
            addon.db.altCharacters = {
                low = { name = "Amy", level = 19, roles = { main = true }, location = {
                    continentMapID = 200, continentName = "Kalimdor", mapID = 100, x = 0.3, y = 0.4 } },
                ready = { name = "Bo", level = 20, location = { continentMapID = 200, continentName = "Kalimdor" } },
            }
            frame:Show()
            addon:RefreshAltsWindow()
            assert.equals("ready", frame.rows[2].guid)
            assert.equals("lowLevel", frame.rows[3].continentGroupID)
            assert.equals("Low level (below 20)  (1)", frame.rows[3].name.text)
            assert.equals("+", frame.rows[3].collapseButton.label.text)
            assert.is_false(frame.rows[3].mapButton.shown)
            assert.equals("Characters  (2)", frame.listTitle.text)
            frame.rows[3].collapseButton.scripts.OnClick()
            assert.equals("low", frame.rows[4].guid)
            frame.rows[4].scripts.OnClick()
            assert.equals("low", frame.selectedGUID)
            assert.equals(100, frame.localMap.mapID)
            assert.equals("Main", frame.rows[4].roles.text)
            addon:SetAltLowLevelThreshold(0)
            assert.equals(1, #frame.continentHeaders)
            assert.equals("low", frame.selectedGUID)
            assert.equals("low", frame.rows[2].guid)
            assert.equals("ready", frame.rows[3].guid)
            assert.equals("Characters  (2)", frame.listTitle.text)
        end)
    end)

    it("restores collapsed and expanded groups from saved data after a reload", function()
        local savedDB
        with_window(function(addon, frame)
            addon.db.altCharacters = {
                continent = { name = "Continent", location = { continentMapID = 200, continentName = "Kalimdor" } },
                bank = { name = "Bank", roles = { bank = true } },
                other = { name = "Other", roles = { other = true } },
                low = { name = "Low", level = 1 },
                unknown = { name = "Unknown" },
            }
            frame:Show()
            addon:RefreshAltsWindow()
            for _, id in ipairs({ 200, "bank", "other", "lowLevel", "unknown" }) do
                for _, header in ipairs(frame.continentHeaders) do
                    if header.continentGroupID == id then
                        if id == "bank" then
                            header.scripts.OnClick()
                        else
                            header.collapseButton.scripts.OnClick()
                        end
                        break
                    end
                end
            end
            -- Copy the persisted booleans into a fresh database, without the old window.
            savedDB = { altCharacters = addon.db.altCharacters, altCollapsedGroups = {} }
            for id, collapsed in pairs(addon.db.altCollapsedGroups) do
                savedDB.altCollapsedGroups[id] = collapsed
            end
        end)
        with_window(function(addon, frame)
            frame:Show()
            addon:RefreshAltsWindow()
            assert.equals(5, #frame.continentHeaders)
            for _, header in ipairs(frame.continentHeaders) do
                local lowLevel = header.continentGroupID == "lowLevel"
                assert.equals(lowLevel and "-" or "+", header.collapseButton.label.text)
            end
            assert.is_false(frame.collapsedContinents.lowLevel)
            assert.equals("low", frame.rows[5].guid)
            frame.continentHeaders[1].collapseButton.scripts.OnClick()
            assert.is_false(addon.db.altCollapsedGroups[200])
            assert.equals("continent", frame.rows[2].guid)
        end, savedDB)
    end)

    it("drags continent headers with scaled cursor positions and preserves collapse and selection", function()
        with_window(function(addon, frame)
            addon.currentAltGUID = "online-other"
            addon.db.altCharacters = {
                one = { name = "Amy", roles = { main = true }, location = { continentMapID = 200, continentName = "Kalimdor" } },
                two = { name = "Bo", location = { continentMapID = 300, continentName = "Other continent" } },
                lost = { name = "Lost" },
            }
            frame.collapsedContinents = { [200] = true, [300] = true, unknown = true }
            frame.scrollFrame.left, frame.scrollFrame.top, frame.scrollFrame.scale = 10, 300, 2
            frame.scrollFrame:SetSize(190, 120)
            local x, y, down = 120, 420, true
            loader.with_globals({
                GetCursorPosition = function() return x, y end,
                IsMouseButtonDown = function() return down end,
            }, function()
                frame:Show()
                addon:RefreshAltsWindow()
                local selected, title = frame.selectedGUID, frame.characterTitle.text
                assert.same({ "LeftButton" }, frame.continentHeaders[2].dragButtons)
                frame.continentHeaders[2].scripts.OnDragStart()
                assert.equals(300, frame.draggingContinentID)
                assert.is_true(frame.continentDragPreview.shown)
                y = 580 -- Ten UI pixels below the top, at scale 2.
                frame.scripts.OnUpdate(frame, 0)
                assert.equals(200, frame.dropBeforeContinentID)
                assert.is_true(frame.continentDropIndicator.shown)
                frame.continentHeaders[2].scripts.OnDragStop()
                assert.same({ 300, 200, "unknown" }, addon.db.altContinentOrder)
                assert.equals(300, frame.continentHeaders[1].continentGroupID)
                assert.equals(selected, frame.selectedGUID)
                assert.equals(title, frame.characterTitle.text)
                assert.equals("Characters  (3)", frame.listTitle.text)
                assert.is_true(frame.collapsedContinents[200])
                assert.is_false(frame.continentDragPreview.shown)
                assert.is_false(frame.continentDropIndicator.shown)
                assert.is_nil(frame.scripts.OnUpdate)

                local savedOrder = addon.db.altContinentOrder
                frame.continentHeaders[1].scripts.OnDragStart()
                x = 1000 -- A release outside the list cancels the move.
                frame.continentHeaders[1].scripts.OnDragStop()
                assert.equals(savedOrder, addon.db.altContinentOrder)
                assert.is_nil(frame.draggingContinentID)
                x, y = 120, 380 -- Near the bottom edge: scroll to the last group.
                frame.continentHeaders[1].scripts.OnDragStart()
                frame.scripts.OnUpdate(frame, 1)
                assert.equals(96, frame.scrollFrame:GetVerticalScroll())
                assert.is_nil(frame.dropBeforeContinentID)
                down = false -- Cleanup also works if the release happens outside the source header.
                frame.scripts.OnUpdate(frame, 0)
                assert.same({ 200, "unknown", 300 }, addon.db.altContinentOrder)
                assert.is_nil(frame.scripts.OnUpdate)
                down = true
                frame.continentHeaders[1].scripts.OnDragStart()
                frame:Hide()
                assert.is_nil(frame.draggingContinentID)
                assert.is_nil(frame.scripts.OnUpdate)
                assert.is_false(frame.continentDragPreview.shown)
                frame:Show()
                frame.continentHeaders[1].scripts.OnDragStart()
                addon:RefreshAltsWindow()
                assert.is_nil(frame.draggingContinentID)
                assert.is_nil(frame.scripts.OnUpdate)
                frame.collapsedContinents[200] = nil
                addon:RefreshAltsWindow()
                local characterRow = frame.rows[2]
                assert.equals("one", characterRow.guid)
                characterRow.scripts.OnMouseDown(characterRow, "LeftButton")
                characterRow.scripts.OnDragStart()
                assert.is_nil(frame.draggingContinentID)
                characterRow.scripts.OnClick()
                assert.equals("one", frame.selectedGUID)
                assert.equals("Main", characterRow.roles.text)
            end)
        end)
    end)

    it("edits multiple roles for the selected offline alt and resets labels and spacing when cleared", function()
        with_window(function(addon, frame)
            addon.currentAltGUID = "online"
            addon.db.altCharacters = {
                one = { name = "Amy", realm = "Realm A" },
                two = { name = "Amy", realm = "Realm B" },
            }
            frame:Show()
            addon:RefreshAltsWindow()
            assert.is_true(frame.roleButton.shown)
            assert.equals("Roles", frame.roleButton.label.text)
            assert.is_false(frame.rows[2].roles.shown)
            assert.equals(90, frame.rows[2].height)
            local choices = {}
            loader.with_globals({
                UIDropDownMenu_AddButton = function(info) choices[info.text] = info end,
                ToggleDropDownMenu = function(_, _, dropdown, anchor)
                    assert.equals(frame.roleButton, anchor)
                    dropdown.initialize(dropdown, 1)
                end,
            }, function() frame.roleButton.scripts.OnClick() end)
            assert.is_false(choices.Main.checked())
            assert.is_true(choices.Main.isNotRadio)
            assert.is_true(choices.Main.keepShownOnClick)
            choices.Main.func()
            choices.Bank.func()
            choices.Other.func()
            assert.is_true(choices.Main.checked())
            assert.equals("Main · Bank · Other", frame.rows[2].roles.text)
            assert.is_true(frame.rows[2].roles.shown)
            assert.equals("Roles (3)", frame.roleButton.label.text)
            assert.equals(108, frame.rows[2].height)
            assert.equals(-66, frame.rows[2].farm.points[1][5])
            assert.equals(-84, frame.rows[2].destination.points[1][5])
            assert.is_nil(addon.db.altCharacters.two.roles)
            choices.Main.func()
            assert.equals("Bank · Other", frame.rows[2].roles.text)
            choices["Clear roles"].func()
            assert.is_false(frame.rows[2].roles.shown)
            assert.equals(90, frame.rows[2].height)
            assert.equals(-48, frame.rows[2].farm.points[1][5])
            assert.equals(-66, frame.rows[2].destination.points[1][5])
            assert.equals("Roles", frame.roleButton.label.text)

            -- A recycled marked row must not leave role labels on a continent header.
            addon:SetAltCharacterRole("two", "bank", true)
            assert.is_true(frame.rows[2].roles.shown)
            addon.db.altCharacters.one.location = { continentMapID = 200, continentName = "Kalimdor" }
            addon:RefreshAltsWindow()
            assert.is_false(frame.rows[3].roles.shown)
            addon:ShowAltContinentMap(200)
            assert.is_false(frame.roleButton.shown)
            addon.db.altCharacters = {}
            frame.selectedContinentID = nil
            addon:RefreshAltsWindow()
            assert.is_false(frame.roleButton.shown)
        end)
    end)

    it("opens the assigned farm by ID from Edit while keeping other realms separate", function()
        with_window(function(addon, frame)
            addon.db.altCharacters = {
                one = { name = "Amy", realm = "Realm A" },
                two = { name = "Amy", realm = "Realm B" },
            }
            local first = addon:CreateCustomFarm("Cloth", false)
            local second = addon:CreateCustomFarm("Cloth", false)
            addon:SetCustomFarmAssignedCharacter(first.id, "Amy-RealmA")
            addon:SetCustomFarmAssignedCharacter(second.id, "Amy-Realm B")
            local opened = {}
            addon.OpenCustomFarmConfiguration = function(_, farmID) opened[#opened + 1] = farmID; return true end
            addon:RefreshAltsWindow()
            assert.is_false(frame.rows[1].farmButton.shown)
            assert.is_true(frame.rows[2].farmButton.shown)
            frame.rows[2].farmButton.scripts.OnClick()
            assert.equals(first.id, opened[1])
            frame.rows[3].farmButton.scripts.OnClick()
            assert.equals(second.id, opened[2])
            assert.is_false(addon:OpenAltAssignedFarm("one", second.id))
            addon:SetCustomFarmAssignedCharacter(first.id, nil)
            addon:RefreshAltsWindow()
            assert.is_false(frame.rows[2].farmButton.shown)
            frame.rows[2].farmButton.scripts.OnClick()
            assert.equals(2, #opened)
        end)
    end)

    it("lets an alt with several farms choose which configuration to open and rejects stale assignments", function()
        with_window(function(addon, frame)
            addon.db.altCharacters.one = { name = "Amy", realm = "Realm A" }
            local silk = addon:CreateCustomFarm("Silk", false)
            local ore = addon:CreateCustomFarm("Ore", false)
            addon:SetCustomFarmAssignedCharacter(silk.id, "Amy-Realm A")
            addon:SetCustomFarmAssignedCharacter(ore.id, "Amy-Realm A")
            local opened, choices = {}, {}
            addon.OpenCustomFarmConfiguration = function(_, farmID) opened[#opened + 1] = farmID; return true end
            addon:RefreshAltsWindow()
            loader.with_globals({
                UIDropDownMenu_AddButton = function(info) choices[#choices + 1] = info end,
                ToggleDropDownMenu = function(_, _, dropdown, anchor)
                    assert.equals(frame.rows[2].farmButton, anchor)
                    dropdown.initialize(dropdown, 1)
                end,
            }, function() frame.rows[2].farmButton.scripts.OnClick() end)
            assert.equals(0, #opened)
            assert.equals("Ore", choices[1].text)
            assert.equals("Silk", choices[2].text)
            choices[2].func()
            assert.equals(silk.id, opened[1])
            choices[1].func()
            assert.equals(ore.id, opened[2])
            addon:SetCustomFarmAssignedCharacter(silk.id, "Other-Realm A")
            choices[2].func()
            assert.equals(2, #opened)
            addon:DeleteCustomFarm(ore.id)
            choices[1].func()
            assert.equals(2, #opened)
        end)
    end)

    it("renders the offline alt's saved discovered terrain in the destination picker above parchment and below its pin", function()
        with_window(function(addon)
            addon.db.altCharacters.one = { name = "Amy", location = { mapID = 100 }, exploredMaps = {
                [100] = { { textureWidth = 300, textureHeight = 270, offsetX = 10, offsetY = 20,
                    fileDataIDs = { 701, 702, 703, 704 } } },
            } }
            loader.with_globals({ C_MapExplorationInfo = { GetExploredMapTextures = function()
                error("Saved offline terrain must not be replaced with the current character's exploration")
            end } }, function()
                addon:ShowAltDestinationPicker("one")
                addon:ChooseAltDestinationPickerPoint(0.3, 0.4)
                local picker = addon.altDestinationPicker
                assert.equals(701, picker.map.exploredTiles[1].texture)
                assert.equals(704, picker.map.exploredTiles[4].texture)
                assert.same({ 0, 44 / 64, 0, 14 / 16 }, picker.map.exploredTiles[4].texCoord)
                assert.equals("ARTWORK", picker.map.exploredTiles[1].layer)
                assert.equals(1, picker.map.exploredTiles[1].subLevel)
                assert.equals("OVERLAY", picker.map.pin.layer)
                assert.is_true(picker.map.pin.shown)
                picker.map.viewport:SetSize(400, 200)
                picker.map.viewport.scripts.OnSizeChanged()
                assert.is_true(picker.map.exploredTiles[4].shown)
                local scale = picker.map.canvas.width / 1000
                assert.is_true(math.abs(picker.map.exploredTiles[1].points[1][4] - 10 * scale) < 0.000001)
            end)
        end)
    end)

    it("loads live discovered terrain for a newly chosen zone and clears old overlays when switching maps", function()
        with_window(function(addon)
            addon.db.altCharacters.one = { name = "Amy", location = { mapID = 100 } }
            local reads = 0
            loader.with_globals({ C_MapExplorationInfo = { GetExploredMapTextures = function(mapID)
                reads = reads + 1
                if mapID == 100 then return { { textureWidth = 64, textureHeight = 64,
                    offsetX = 0, offsetY = 0, fileDataIDs = { 801 } } } end
                return {}
            end } }, function()
                addon:ShowAltDestinationPicker("one")
                local picker = addon.altDestinationPicker
                assert.equals(801, picker.map.exploredTiles[1].texture)
                assert.equals(1, reads)
                picker.xInput:SetText("30")
                picker.yInput:SetText("40")
                assert.equals(1, reads)
                assert.is_true(picker.map.exploredTiles[1].shown)
                addon:SelectAltDestinationPickerMap(101)
                assert.equals(2, reads)
                assert.is_false(picker.map.exploredTiles[1].shown)
                assert.is_nil(addon.db.altCharacters.one.exploredMaps)
            end)
        end)
    end)

    it("retains saved terrain when live exploration is unavailable or temporarily empty", function()
        with_window(function(addon)
            addon.currentAltGUID = "one"
            addon.db.altCharacters.one = { name = "Amy", location = { mapID = 100 }, exploredMaps = {
                [100] = { { textureWidth = 64, textureHeight = 64, offsetX = 0, offsetY = 0, fileDataIDs = { 901 } } },
            } }
            for _, read in ipairs({ function() return {} end, function() error("Unavailable") end }) do
                loader.with_globals({ C_MapExplorationInfo = { GetExploredMapTextures = read } }, function()
                    addon:ShowAltDestinationPicker("one")
                    assert.equals(901, addon.altDestinationPicker.map.exploredTiles[1].texture)
                    assert.is_true(addon.altDestinationPicker.map.exploredTiles[1].shown)
                end)
            end
        end)
    end)

    it("discards unsaved picker changes and closes the picker when selecting another alt or leaving Alts", function()
        with_window(function(addon, frame)
            addon.db.altCharacters.one = { name = "Amy", location = { mapID = 100 } }
            addon.db.altCharacters.two = { name = "Zara", location = { continentMapID = 200 } }
            addon:SetAltDestination("one", 100, 0.1, 0.2)
            frame:Show()
            addon:RefreshAltsWindow()
            addon:ShowAltDestinationPicker("one")
            local picker = addon.altDestinationPicker
            addon:ChooseAltDestinationPickerPoint(0.7, 0.8)
            picker.cancelButton.scripts.OnClick()
            assert.equals(0.1, addon.db.altCharacters.one.destination.x)
            addon:ShowAltDestinationPicker("one")
            assert.equals("10.0000", picker.xInput.text)
            -- Unknown-location groups sort last, so Amy follows the second header.
            local zaraRow
            for _, row in ipairs(frame.rows) do if row.guid == "two" then zaraRow = row end end
            zaraRow.scripts.OnClick()
            assert.is_false(picker.shown)
            addon:ShowAltDestinationPicker("two")
            assert.is_nil(picker.mapID)
            assert.is_false(picker.saveButton.enabled)
            picker.xInput:SetFocus()
            frame:Hide()
            assert.is_false(picker.shown)
            assert.is_false(picker.xInput.focused)
        end)
    end)

    it("edits offline destinations through the map picker and returns to free roam on Clear", function()
        with_window(function(addon, frame)
            addon.db.altCharacters.one = { name = "Amy", realm = "Realm A",
                location = { mapID = 100, x = 0.1, y = 0.2 } }
            frame:Show()
            addon:RefreshAltsWindow()
            assert.equals("Free roam", frame.rows[2].destination.text)
            frame.destinationPanel.setButton.scripts.OnClick()
            local picker = addon.altDestinationPicker
            assert.equals("one", picker.guid)
            assert.equals(100, picker.mapID)
            assert.is_false(picker.currentButton.enabled)
            assert.is_nil(addon.db.altCharacters.one.destination)
            assert.is_true(addon:ChooseAltDestinationPickerPoint(0.3, 0.4))
            assert.equals("30.0000", picker.xInput.text)
            assert.is_true(addon:SaveAltDestinationPicker())
            assert.is_false(picker.shown)
            assert.equals(0.3, addon.db.altCharacters.one.destination.x)
            assert.equals("Show on map", frame.destinationPanel.navigateButton.text)
            frame.destinationPanel.navigateButton.scripts.OnClick()
            assert.is_true(picker.shown)
            assert.equals("30.0000", picker.xInput.text)
            picker:Hide()
            frame.destinationPanel.clearButton.scripts.OnClick()
            assert.equals("Free roam", frame.rows[2].destination.text)
            assert.is_false(frame.destinationPanel.navigateButton.enabled)
            assert.is_false(frame.destinationPanel.clearButton.enabled)
            assert.is_false(frame.rows[1].destination.shown)
        end)
    end)

    it("converts map clicks using the canvas scale and rejects clicks outside its art", function()
        with_window(function(addon)
            addon.db.altCharacters.one = { name = "Amy", location = { mapID = 100 } }
            addon:ShowAltDestinationPicker("one")
            local picker = addon.altDestinationPicker
            picker.map.canvas:SetSize(400, 200)
            picker.map.canvas.left, picker.map.canvas.top, picker.map.canvas.scale = 100, 300, 2
            loader.with_globals({ GetCursorPosition = function() return 400, 400 end }, function()
                picker.map.viewport.scripts.OnMouseUp(nil, "LeftButton")
            end)
            assert.equals("25.0000", picker.xInput.text)
            assert.equals("50.0000", picker.yInput.text)
            assert.is_false(addon:ChooseAltDestinationPickerPoint(-0.1, 0.5))
            assert.equals("25.0000", picker.xInput.text)
            picker.xInput:SetText("101")
            assert.is_false(addon:SaveAltDestinationPicker())
            assert.is_nil(addon.db.altCharacters.one.destination)
        end)
    end)

    it("searches zones on demand and clears old coordinates when selecting a different zone", function()
        with_window(function(addon)
            addon.db.altCharacters.one = { name = "Amy", location = { mapID = 100 } }
            assert.is_nil(addon.altDestinationPicker)
            addon:ShowAltDestinationPicker("one")
            local picker = addon.altDestinationPicker
            addon:ChooseAltDestinationPickerPoint(0.3, 0.4)
            picker.zoneButton.scripts.OnClick()
            assert.is_true(picker.zoneListPanel.shown)
            assert.equals(100, picker.zoneRows[1].mapID)
            picker.zoneSearch:SetText("missing")
            picker.zoneSearch.scripts.OnTextChanged()
            assert.is_true(picker.zoneEmpty.shown)
            picker.zoneSearch:SetText("Zone")
            picker.zoneSearch.scripts.OnTextChanged()
            assert.is_false(picker.zoneEmpty.shown)
            picker.zoneRows[1].scripts.OnClick()
            assert.is_false(picker.zoneListPanel.shown)
            assert.equals("", picker.xInput.text)
            assert.is_false(picker.saveButton.enabled)
            addon:SelectAltDestinationPickerMap(101)
            assert.equals(300, picker.continentID)
            assert.equals("Other zone", picker.zoneButton.text)
        end)
    end)

    it("uses the current position only for the logged-in alt and waits for Save", function()
        with_window(function(addon, frame)
            addon.currentAltGUID = "one"
            addon.db.altCharacters.one = { name = "Amy", location = { mapID = 100, x = 0.1, y = 0.2 } }
            addon.db.altCharacters.two = { name = "Zara" }
            local captures = 0
            addon.CaptureCurrentAlt = function(self)
                captures = captures + 1
                self.db.altCharacters.one.location = { mapID = 100, x = 0.7, y = 0.8 }
                return self.db.altCharacters.one
            end
            addon:ShowAltDestinationPicker("two")
            assert.is_false(addon:UseCurrentAltDestinationPosition())
            assert.equals(0, captures)
            addon:ShowAltDestinationPicker("one")
            assert.is_true(addon:UseCurrentAltDestinationPosition())
            assert.equals(1, captures)
            assert.equals("70.0000", addon.altDestinationPicker.xInput.text)
            assert.is_nil(addon.db.altCharacters.one.destination)
            assert.is_true(addon:SaveAltDestinationPicker())
            frame.selectedGUID = "one"
            addon:RefreshAltsWindow()
            assert.equals("At destination", frame.rows[2].destination.text)
            assert.equals("Navigate", frame.destinationPanel.navigateButton.text)
            assert.is_true(frame.destinationPanel.refreshButton.enabled)
            addon.db.altCharacters.one.locationUnavailable = true
            addon:ShowAltDestinationPicker("one")
            assert.is_false(addon:UseCurrentAltDestinationPosition())
        end)
    end)

    it("shows assigned farms per realm and updates after assignment, rename and deletion", function()
        with_window(function(addon, frame)
            addon.db.altCharacters = {
                one = { name = "Amy", realm = "Realm A" },
                two = { name = "Amy", realm = "Realm B" },
            }
            local first = addon:CreateCustomFarm("Silk", false)
            local second = addon:CreateCustomFarm("Ore", false)
            addon:SetCustomFarmAssignedCharacter(first.id, "Amy-RealmA")
            addon:SetCustomFarmAssignedCharacter(second.id, "Amy-Realm A")
            frame:Show()
            addon:RefreshAltsWindow()
            assert.equals("Farms: 2 assigned", frame.rows[2].farm.text)
            assert.equals("Assigned farms\nOre\nSilk", frame.rows[2].tooltipText)
            assert.equals("No farm assigned", frame.rows[3].farm.text)
            assert.is_nil(frame.rows[3].tooltipText)
            assert.is_false(frame.rows[1].farm.shown)
            assert.equals(90, frame.rows[2].height)

            addon:SetCustomFarmAssignedCharacter(first.id, "Amy-Realm B")
            assert.equals("Farm: Ore", frame.rows[2].farm.text)
            assert.equals("Farm: Silk", frame.rows[3].farm.text)
            addon:RenameCustomFarm(first.id, "Cloth")
            assert.equals("Farm: Cloth", frame.rows[3].farm.text)
            assert.equals("Assigned farms\nCloth", frame.rows[3].tooltipText)
            addon:SetCustomFarmAssignedCharacter(second.id, nil)
            assert.equals("No farm assigned", frame.rows[2].farm.text)
            assert.is_nil(frame.rows[2].tooltipText)
            addon:DeleteCustomFarm(first.id)
            assert.equals("No farm assigned", frame.rows[3].farm.text)
            assert.is_nil(frame.rows[3].tooltipText)

            -- Recycled character rows must not leave farm labels on continent headers.
            addon.db.altCharacters.one.location = { continentMapID = 200, continentName = "Kalimdor" }
            addon:RefreshAltsWindow()
            assert.is_false(frame.rows[3].farm.shown)
            assert.equals("Click to expand or collapse. Drag to reorder groups.", frame.rows[3].tooltipText)
        end)
    end)

    it("shows the empty state without leaving map pins visible", function()
        with_window(function(addon, frame)
            addon:RefreshAltsWindow()
            assert.equals("Characters  (0)", frame.listTitle.text)
            assert.equals("Log in to each character to add them here.", frame.locationText.text)
            assert.is_false(frame.localMap.pin.shown)
            assert.is_false(frame.professionTags[1].shown)
        end)
    end)

    it("selects characters with level and realm subtitles, primary profession tags and one interactive map", function()
        with_window(function(addon, frame)
            addon.db.altCharacters = {
                one = { name = "Amy", realm = "Realm A", level = 80, professions = {
                    { name = "Mining", icon = 100 }, { name = "Skinning", icon = 200 },
                },
                    location = { mapID = 100, mapName = "Zone", x = 0.123456, y = 0.654321,
                        parentMapID = 200, parentMapName = "Kalimdor", parentX = 0.4, parentY = 0.6,
                        continentMapID = 200, continentName = "Kalimdor", savedAt = 10 } },
                two = { name = "Zara", realm = "Realm B", professions = {},
                    location = { mapID = 999, mapName = "Other zone", x = 0.1, y = 0.2,
                        continentMapID = 200, continentName = "Kalimdor" } },
            }
            addon:RefreshAltsWindow()
            assert.equals("one", frame.selectedGUID)
            assert.equals("Locations are recorded at login and logout.", frame.hint.text)
            assert.equals("Kalimdor  (2)", frame.rows[1].name.text)
            assert.equals("Amy", frame.rows[2].name.text)
            assert.equals(100, frame.rows[2].professionIcons[1].texture)
            assert.equals(200, frame.rows[2].professionIcons[2].texture)
            assert.equals(20, frame.rows[2].professionIcons[1].width)
            assert.equals(20, frame.rows[2].professionIcons[1].height)
            assert.equals(-36, frame.rows[2].professionIcons[1].points[1][4])
            assert.equals(-10, frame.rows[2].professionIcons[2].points[1][4])
            assert.is_true(frame.rows[2].professionIcons[1].shown)
            assert.is_true(frame.rows[2].professionIcons[2].shown)
            assert.is_false(frame.rows[1].professionIcons[1].shown)
            assert.is_false(frame.rows[3].professionIcons[1].shown)
            assert.equals("Level 80 · Realm A", frame.rows[2].realm.text)
            assert.equals("Amy  ·  Level 80  ·  Realm A", frame.characterTitle.text)
            assert.equals("Mining", frame.professionTags[1].text.text)
            assert.is_true(frame.professionTags[1].shown)
            assert.is_true(frame.localMap.pin.shown)
            assert.is_nil(frame.parentMap)
            assert.equals("waypoint-mappin-minimap-tracked", frame.localMap.pin.atlas)
            assert.equals("OVERLAY", frame.localMap.pin.layer)
            assert.equals(28, frame.localMap.pin.width)
            assert.equals(200, frame.localMap.source.rootID)
            assert.equals("BOTTOMRIGHT", frame.localMap.points[2][1])
            assert.equals(0, frame.localMap.points[2][2])
            assert.equals(0.123456, frame.localMap.x)
            assert.equals("12.35, 65.43", frame.localMap.coordinates.text)
            for _, size in ipairs({ { 300, 300 }, { 600, 200 } }) do
                local card = frame.localMap
                card.viewport:SetSize(size[1], size[2])
                card.viewport.scripts.OnSizeChanged()
                card:Reset()
                local node = card.source.byID[100]
                local x, y = card:ProjectPoint(node.rect.l + card.x * (node.rect.r - node.rect.l),
                    node.rect.t + card.y * (node.rect.b - node.rect.t))
                local point = card.pin.points[1]
                assert.is_true(math.abs(point[4] - x) < 0.000001)
                assert.is_true(math.abs(point[5] + y) < 0.000001)
                assert.equals(28, card.pin.width)
            end
            frame.rows[3].scripts.OnClick()
            assert.equals("two", frame.selectedGUID)
            assert.equals("Zara", frame.rows[3].name.text)
            assert.equals("Realm B", frame.rows[3].realm.text)
            assert.equals("Zara  ·  Realm B", frame.characterTitle.text)
            assert.is_false(frame.professionTags[1].shown)
            assert.equals("No primary professions", frame.noProfessions.text)
            assert.is_false(frame.localMap.pin.shown)
            assert.equals(0, frame.localMap.renderer.used)
            assert.equals("Map art unavailable", frame.localMap.message.text)
            addon.db.altCharacters.one.professions = {}
            addon:RefreshAltsWindow()
            assert.is_false(frame.rows[2].professionIcons[1].shown)
            assert.is_false(frame.rows[2].professionIcons[2].shown)
            addon.db.altCharacters.one.level = nil
            addon:RefreshAltsWindow()
            assert.equals("Realm A", frame.rows[2].realm.text)
        end)
    end)

    it("renders the fully revealed map for offline characters regardless of their discoveries", function()
        with_window(function(addon, frame)
            local location = { mapID = 100, mapName = "Zone", x = 0.6, y = 0.2,
                parentMapID = 200, parentMapName = "Continent", parentX = 0.4, parentY = 0.5 }
            addon.currentAltGUID = "online-other"
            addon.db.altCharacters = {
                one = { name = "Amy", realm = "Realm A", location = location, exploredMaps = {
                    [100] = { { textureWidth = 300, textureHeight = 270, offsetX = 10, offsetY = 20,
                        fileDataIDs = { 101, 102, 103, 104 } } },
                    [200] = { { textureWidth = 64, textureHeight = 64, offsetX = 0, offsetY = 0,
                        fileDataIDs = { 201 } } },
                } },
                two = { name = "Zara", realm = "Realm B", location = location, exploredMaps = {
                    [100] = { { textureWidth = 64, textureHeight = 64, offsetX = 0, offsetY = 0,
                        fileDataIDs = { 301 } } },
                    [200] = {},
                } },
            }
            local liveReads = 0
            loader.with_globals({ C_MapExplorationInfo = { GetExploredMapTextures = function()
                liveReads = liveReads + 1
                return {}
            end } }, function()
                addon:RefreshAltsWindow()
                local source = frame.localMap.source
                local pieces = source:Exploration(source.byID[100])
                assert.is_true(frame.localMap.options.revealAll)
                assert.equals(901, pieces[1].fileID)
                assert.equals(904, pieces[4].fileID)
                assert.same({ 0, 44 / 64, 0, 14 / 16 }, pieces[4].uv)
                assert.equals("Locations are recorded at login and logout.", frame.hint.text)
                assert.equals("OVERLAY", frame.localMap.pin.layer)
                assert.is_true(frame.localMap.pin.shown)
                frame.rows[3].scripts.OnClick()
                source = frame.localMap.source
                pieces = source:Exploration(source.byID[100])
                assert.equals(901, pieces[1].fileID)
                assert.equals(4, #pieces)
                assert.equals(0, liveReads)
            end)
        end)
    end)

    it("refreshes the current character's zone on selection without polling or recursive refresh", function()
        with_window(function(addon, frame)
            addon.currentAltGUID, frame.selectedGUID = "one", "one"
            addon.db.altCharacters.one = { name = "Amy", realm = "Realm A", location = {
                mapID = 200, mapName = "Continent", x = 0.4, y = 0.5,
            } }
            local captures = 0
            addon.CaptureCurrentAlt = function(self, saveLocation, _, suppressRefresh)
                captures = captures + 1
                assert.is_true(saveLocation)
                assert.is_true(suppressRefresh)
                self.db.altCharacters.one.location = { mapID = 100, mapName = "Zone", x = 0.6, y = 0.2,
                    parentMapID = 200, parentMapName = "Continent", parentX = 0.4, parentY = 0.5 }
            end
            addon:RefreshAltsWindow()
            assert.equals(0, captures)
            assert.equals(200, frame.localMap.mapID)
            frame.rows[2].scripts.OnClick()
            assert.equals(1, captures)
            assert.equals(100, frame.localMap.mapID)
            assert.equals(0.6, frame.localMap.x)
            assert.is_nil(frame.scripts.OnUpdate)
        end)
    end)

    it("opens fully revealed interactive terrain from the continent Map button and resets to the continent", function()
        with_window(function(addon, frame, mapData)
            addon.currentAltGUID = "online-elsewhere"
            addon.db.altCharacters.one = { name = "Amy", level = 80, location = {
                mapID = 100, mapName = "Zone", x = 0.5, y = 0.5,
                parentMapID = 200, parentX = 0.45, parentY = 0.55,
                continentMapID = 200, continentName = "Kalimdor",
            } }
            local tiles = {}
            for col = 0, 3 do for row = 0, 3 do tiles[#tiles + 1] = (col * 64 + row) .. ":" .. (9000 + col * 64 + row) end end
            mapData.tiles[0] = table.concat(tiles, ",")
            local vector = function(x, y) return { GetXY = function() return x, y end } end
            C_Map.GetWorldPosFromMapPos = function(_, point)
                local x, y = point:GetXY()
                return 0, vector((32 - y * 4) * (1600 / 3), (32 - x * 4) * (1600 / 3))
            end
            loader.with_globals({ CreateVector2D = vector, GetCursorPosition = function() return 300, 250 end,
                C_MapExplorationInfo = { GetExploredMapTextures = function() error("Continent maps must not need player discoveries") end } }, function()
                addon:RefreshAltsWindow()
                local button = frame.rows[1].mapButton
                button.scripts.OnClick()
                local map = frame.localMap
                assert.equals(200, map.source.rootID)
                assert.is_true(map.options.revealAll)
                assert.equals(1, map.view.zoom)
                assert.equals(1, #map.characterLocations)
                assert.is_true(map.characterPins[1].shown)
                -- Exercise the actual wheel handler, including its animation lifecycle.
                map.viewport.scripts.OnMouseWheel(nil, 10)
                for _ = 1, 160 do if map.viewport.scripts.OnUpdate then map.viewport.scripts.OnUpdate(nil, 0.016) end end
                assert.is_true(map.view.zoom > 1)
                assert.is_true(map.renderer.terrainCount > 0)
                local x, y = map:ProjectPoint(0.45, 0.55)
                local pin = map.characterPins[1]
                assert.is_true(math.abs(pin.points[1][4] - x) < 0.000001)
                assert.is_true(math.abs(pin.points[1][5] + y) < 0.000001)
                assert.equals(28, pin.width)
                addon:RefreshAltsWindow()
                assert.is_true(map.view.zoom > 1)
                button.scripts.OnClick()
                assert.equals(1, map.view.zoom)
                assert.equals(0.5, map.view.x)
                assert.equals(0.5, map.view.y)
                assert.is_nil(map.viewport.scripts.OnUpdate)
                map.viewport.scripts.OnMouseWheel(nil, 10)
                map.viewport.scripts.OnUpdate(nil, 0.1)
                map.resetButton.scripts.OnClick()
                assert.equals(1, map.view.zoom)
                map.viewport.scripts.OnMouseWheel(nil, -100)
                map.viewport.scripts.OnUpdate(nil, 0.1)
                assert.equals(1, map.view.zoom)
                assert.equals(200, map.source.rootID)
            end)
        end)
    end)

    it("opens a continent map from its header and returns to a character's interactive zone view", function()
        with_window(function(addon, frame)
            local function character(name, continent, continentName, x, y)
                return { name = name, realm = "Realm A", location = { mapID = 100, mapName = "Zone",
                    x = 0.1, y = 0.2, parentMapID = continent, parentMapName = continentName,
                    parentX = x, parentY = y, continentMapID = continent, continentName = continentName } }
            end
            addon.db.altCharacters = {
                one = character("Amy", 200, "Kalimdor", 0.4, 0.6),
                two = character("Bo", 200, "Kalimdor", 0.7, 0.3),
                three = character("Cara", 200, "Kalimdor", 0.4, 0.6),
                four = character("Zara", 300, "Other continent", 0.5, 0.5),
                lost = { name = "Lost", realm = "Realm A" },
            }
            addon.db.altCharacters.one.professions = { { name = "Mining", icon = 101 }, { name = "Skinning", icon = 102 } }
            addon.db.altCharacters.three.professions = { { name = "Engineering", icon = 201 } }
            addon:RefreshAltsWindow()
            assert.is_true(frame.rows[1].mapButton.shown)
            assert.is_false(frame.rows[2].mapButton.shown)
            assert.is_false(frame.rows[7].mapButton.shown)
            frame.rows[1].mapButton.scripts.OnClick()
            assert.equals(200, frame.selectedContinentID)
            assert.equals(200, frame.localMap.mapID)
            assert.is_false(frame.destinationPanel.shown)
            assert.equals(3, #frame.localMap.characterLocations)
            assert.equals("Kalimdor", frame.characterTitle.text)
            assert.equals(200, frame.localMap.source.rootID)
            assert.is_false(frame.localMap.pin.shown)
            local first, second = frame.localMap.characterPins[1], frame.localMap.characterPins[2]
            assert.is_true(first.shown)
            assert.is_true(second.shown)
            assert.equals("Amy", first.entries[1].label.text)
            assert.equals("Cara", first.entries[2].label.text)
            assert.equals("Bo", second.entries[1].label.text)
            assert.equals(13, first.entries[1].label.fontSize)
            assert.equals("OUTLINE", first.entries[1].label.fontFlags)
            assert.equals(0.7, first.caption.bg[4])
            assert.equals(101, first.entries[1].professionIcons[1].texture)
            assert.equals(102, first.entries[1].professionIcons[2].texture)
            assert.equals(16, first.entries[1].professionIcons[1].width)
            assert.equals(-17, first.entries[1].professionIcons[1].points[1][3])
            assert.is_true(first.entries[1].professionIcons[1].shown)
            assert.equals(201, first.entries[2].professionIcons[1].texture)
            assert.is_false(first.entries[2].professionIcons[2].shown)
            assert.is_false(second.entries[1].professionIcons[1].shown)
            frame.localMap.viewport:SetSize(400, 200)
            frame.localMap.viewport.scripts.OnSizeChanged()
            local x, y = frame.localMap:ProjectPoint(0.4, 0.6)
            assert.is_true(math.abs(first.points[1][4] - x) < 0.000001)
            assert.is_true(math.abs(first.points[1][5] + y) < 0.000001)
            frame.rows[2].scripts.OnClick()
            assert.is_nil(frame.selectedContinentID)
            assert.equals("one", frame.selectedGUID)
            assert.equals(100, frame.localMap.mapID)
            assert.is_true(frame.destinationPanel.shown)
            assert.is_true(frame.localMap.pin.shown)
            assert.is_false(first.shown)
            assert.is_false(second.shown)
            assert.equals(0, frame.localMap.points[2][2])
            addon.db.altCharacters.one, addon.db.altCharacters.two, addon.db.altCharacters.three = nil, nil, nil
            addon:RefreshAltsWindow()
            assert.equals(300, frame.rows[1].continentMapID)
            assert.is_false(frame.rows[2].mapButton.shown)
            assert.is_false(frame.rows[3].mapButton.shown)
            frame.rows[1].mapButton.scripts.OnClick()
            assert.equals(300, frame.localMap.mapID)
            assert.equals(1, #frame.localMap.characterLocations)
            assert.equals("Zara", frame.localMap.characterPins[1].entries[1].label.text)
            assert.is_false(first.entries[1].professionIcons[1].shown)
            assert.is_false(first.entries[1].professionIcons[2].shown)
            assert.is_false(first.entries[2].shown)
            assert.is_false(second.shown)
        end)
    end)
end)
