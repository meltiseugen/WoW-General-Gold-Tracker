local loader = require("tests.helpers.addon_loader")
local widget = require("tests.helpers.map_ui").widget

local function with_map(callback, experimental)
    local cursorX, cursorY = 400, 250
    local calls = { data = 0, art = {}, children = 0 }
    local info = {
        [1] = { mapID = 1, name = "Continent", mapType = 2, parentMapID = 946 },
        [2] = { mapID = 2, name = "West", mapType = 3, parentMapID = 1 },
        [3] = { mapID = 3, name = "East", mapType = 3, parentMapID = 1 },
        [4] = { mapID = 4, name = "City", mapType = 3, parentMapID = 2 },
        [9] = { mapID = 9, name = "Other continent", mapType = 2, parentMapID = 946 },
    }
    local rects = { [2] = { 0.1, 0.5, 0.2, 0.8 }, [3] = { 0.5, 0.9, 0.2, 0.8 }, [4] = { 0.2, 0.3, 0.4, 0.5 } }
    local sourceNS
    loader.with_globals({
        CreateFrame = widget,
        CreateVector2D = function(x, y) return { GetXY = function() return x, y end } end,
        GetCursorPosition = function() return cursorX, cursorY end,
        C_Map = {
            GetMapInfo = function(id) return info[id] end,
            GetMapChildrenInfo = function()
                calls.children = calls.children + 1
                return { info[2], info[3], info[4] }
            end,
            GetMapRectOnMap = function(id) if rects[id] then return unpack(rects[id]) end end,
            GetMapArtID = function(id) return id == 1 and 100 or 200 end,
            GetMapArtLayers = function(id)
                calls.art[id] = (calls.art[id] or 0) + 1
                return { { layerWidth = 1024, layerHeight = 768, tileWidth = 256, tileHeight = 256 } }
            end,
            GetMapArtLayerTextures = function(id)
                local out = {}; for i = 1, 12 do out[i] = id * 100 + i end; return out
            end,
            GetWorldPosFromMapPos = function(id, point)
                local x, y = point:GetXY()
                local r = rects[id]
                if r then x, y = r[1] + x * (r[2] - r[1]), r[3] + y * (r[4] - r[3]) end
                return 0, { GetXY = function() return (32 - y * 16) * (1600 / 3), (32 - x * 16) * (1600 / 3) end }
            end,
        },
    }, function()
        -- Existing renderer regressions explicitly exercise the experimental path.
        local addon = { db = { enableExperimentalMaps = experimental ~= false } }
        local theme = {
            CreatePanel = function(_, parent) return widget(nil, nil, parent) end,
            CreateButton = function(_, parent, _, _, label)
                local b = widget(nil, nil, parent); b.label = b:CreateFontString(); b:SetText(label); return b
            end,
        }
        loader.load_module("UI/Maps/Geometry.lua", addon)
        _, sourceNS = loader.load_module("UI/Maps/MapSource.lua", addon)
        loader.load_module("UI/Maps/MapScene.lua", addon)
        loader.load_module("UI/Maps/MapRenderer.lua", addon)
        loader.load_module("UI/Maps/InteractiveMap.lua", addon, { JanisTheme = theme })
        addon.LoadCatalog = function()
            calls.data = calls.data + 1
            local tiles = {}
            for col = 0, 15 do for row = 0, 15 do tiles[#tiles + 1] = (col * 64 + row) .. ":" .. (9000 + col * 64 + row) end end
            sourceNS.MapTerrainData = { fogArt = { [200] = true }, clearArt = { [300] = true },
                revealedOverlays = { [200] = "512,256,0,0|0:0:7002,1:0:7003" },
                tiles = { [0] = table.concat(tiles, ",") } }
            return true
        end
        local map = addon:CreateInteractiveMapCard(widget(), "Map")
        map.viewport:SetSize(800, 500)
        map.viewport.top = 500
        local overlays = { { offsetX = 0, offsetY = 0, textureWidth = 256, textureHeight = 256, fileDataIDs = { 7001 } } }
        local options = { key = "one", revision = 1, mapID = 2, continentMapID = 1, x = 0.5, y = 0.5,
            getExploration = function(id) return id == 2 and overlays or {} end }
        map:SetSubject(options)
        callback(addon, map, options, calls, function(x, y) cursorX, cursorY = x, y end, sourceNS)
    end)
end

local function close(a, b) assert.is_true(math.abs(a - b) < 0.00001) end
local function terrain(map)
    local out = {}
    for _, group in pairs(map.renderer.groups) do
        for i = 1, group.used do
            local tex = group.pool[i].texture
            if tex.shown and type(tex.texture) == "number" and tex.texture >= 9000 then out[#out + 1] = tex end
        end
    end
    return out
end

describe("Interactive map", function()
    it("uses one native painting without a stitched scene or terrain when the flag is off", function()
        with_map(function(addon, map, options, calls)
            assert.is_true(map.standard)
            assert.equals(2, map.source.rootID)
            assert.equals(1, #map.source.nodes)
            assert.equals(0, calls.children)
            assert.is_nil(calls.art[1])
            addon.MapScene.Build = function() error("Standard maps must not build a stitched scene") end
            map.source.Tiles = function() error("Standard maps must not decode terrain") end
            addon.MapArtMasks = { [200] = true }
            addon.MapGeometry.ZoomAt(map.view, 64, 400, 250)
            map:Render()
            assert.equals(0, map.renderer.terrainCount)
            assert.equals(0, calls.data)
            for _, group in pairs(map.renderer.groups) do
                if group.used > 0 then
                    assert.equals("standard", group.kind)
                    for i = 1, group.used do assert.equals(0, #group.pool[i].masks) end
                end
            end
            -- Unset preferences also choose the ordinary painting.
            addon.db.enableExperimentalMaps = nil
            map:SetSubject(options)
            assert.is_true(map.standard)
            assert.is_true(map.pin.shown)
        end, false)
    end)

    it("reveals the full native painting and retains recorded phase art in standard mode", function()
        with_map(function(_, map, options, calls)
            options.revealAll = true
            options.getExploration = function() error("Alts visibility must not depend on discoveries") end
            options.getArt = function(id)
                if id == 2 then return { artID = 200, width = 1024, height = 768,
                    tileWidth = 256, tileHeight = 256, textures = { 501, 502, 503 } } end
            end
            options.revision = 2
            map:SetSubject(options)
            local found = {}
            for _, group in pairs(map.renderer.groups) do
                for i = 1, group.used do found[group.pool[i].texture.texture] = true end
            end
            assert.is_true(found[501])
            assert.is_true(found[7002])
            assert.is_true(found[7003])
            assert.equals(1, calls.data)
            assert.equals(0, map.renderer.terrainCount)
            assert.equals(0, #map.source.decodedOrder)
        end, false)
    end)

    it("switches existing cards in both directions and releases the previous rendering", function()
        with_map(function(addon, map, options)
            options.revealAll = true
            map:SetSubject(options)
            addon.MapGeometry.ZoomAt(map.view, 20, 400, 250)
            map:Render()
            assert.is_true(map.renderer.terrainCount > 0)
            addon.db.enableExperimentalMaps = false
            addon:RefreshInteractiveMapStyles()
            assert.is_true(map.standard)
            assert.equals(2, map.source.rootID)
            assert.equals(1, map.view.zoom)
            assert.equals(0, map.renderer.terrainCount)
            assert.is_true(map.pin.shown)
            for _, group in pairs(map.renderer.groups) do
                if group.used > 0 then assert.equals("standard", group.kind) end
                for i = group.used + 1, #group.pool do
                    assert.is_nil(group.pool[i].texture.texture)
                    for _, mask in ipairs(group.pool[i].masks) do assert.is_nil(mask.texture) end
                end
            end
            addon.db.enableExperimentalMaps = true
            addon:RefreshInteractiveMapStyles()
            assert.is_false(map.standard)
            assert.equals(1, map.source.rootID)
            assert.is_not_nil(map.source.byID[3])
            assert.is_true(options.revealAll)
            assert.equals(0.5, map.x)
            assert.equals(0.5, map.y)
        end)
    end)

    it("defers rebuilding hidden cards until they are shown after a style change", function()
        with_map(function(addon, map, _, calls)
            map.viewport:Hide()
            local artCalls, childCalls = calls.art[2], calls.children
            addon.db.enableExperimentalMaps = false
            addon:RefreshInteractiveMapStyles()
            assert.is_nil(map.source)
            assert.equals(0, map.renderer.used)
            assert.is_nil(map.viewport.scripts.OnUpdate)
            assert.equals(artCalls, calls.art[2])
            assert.equals(childCalls, calls.children)
            map.viewport:Show()
            assert.is_true(map.standard)
            assert.equals(2, map.source.rootID)
        end)
    end)

    it("uses artwork-specific painting masks without clipping continuous terrain to them", function()
        with_map(function(addon, map, options, _, _, sourceNS)
            options.revealAll = true
            map:SetSubject(options)
            addon.MapArtMasks = { [100] = true, [200] = true }
            addon.MapGeometry.ZoomAt(map.view, 2, 400, 250)
            map:Render()
            local paintings = 0
            for _, group in pairs(map.renderer.groups) do
                if group.kind == "base" and group.mapID == 2 then assert.equals(0, group.used) end
                if group.used > 0 and group.kind ~= "paper" then
                    for i = 1, group.used do
                        local mask = group.pool[i].masks[1]
                        assert.is_truthy(mask)
                        assert.is_truthy(mask.texture:find(group.mapID == 1 and "FrameCutout" or "ArtMasks", 1, true))
                        if group.kind == "base" then
                            assert.is_truthy(group.pool[i].masks[2].texture:find("FrameCutout", 1, true))
                        elseif group.kind == "detail" then
                            assert.is_truthy(group.pool[i].masks[2].texture:find("FrameCutout", 1, true))
                        end
                        paintings = paintings + 1
                    end
                end
            end
            assert.is_true(paintings > 0)
            addon.MapGeometry.ZoomAt(map.view, 40, 400, 250)
            map:Render()
            for _, group in pairs(map.renderer.groups) do
                if group.kind == "terrain" then
                    for i = 1, group.used do
                        for mask, attached in pairs(group.pool[i].texture.masks or {}) do
                            if attached then assert.is_falsy(mask.texture:find("ArtMasks", 1, true)) end
                        end
                    end
                end
            end
        end)
    end)

    it("does not reuse another phase's mask for unknown artwork", function()
        with_map(function(addon, map)
            addon.MapArtMasks = { [201] = true }
            assert.is_nil(map.source:ArtMask(map.source.byID[2]))
        end)
    end)

    it("uses the same territory for the base and revealed detail without a second corner crop", function()
        with_map(function(addon, map, options)
            addon.MapArtMasks, addon.MapArtTerritories = { [200] = true }, { [200] = true }
            options.revealAll = true
            map:SetSubject(options)
            addon.MapGeometry.ZoomAt(map.view, 2, 400, 250)
            map:Render()
            local passes = {}
            for _, group in pairs(map.renderer.groups) do
                if group.mapID == 2 and group.used > 0 then
                    passes[group.kind] = true
                    for i = 1, group.used do
                        local cell = group.pool[i]
                        assert.is_truthy(cell.masks[1].texture:find("ArtMasks", 1, true))
                        assert.is_falsy(cell.masks[2] and cell.masks[2].attached)
                    end
                end
            end
            assert.is_true(passes.base)
            assert.is_true(passes.detail)
        end)
    end)

    it("replaces coarse labels below zone detail only for fully revealed callers", function()
        with_map(function(addon, map, options)
            addon.MapArtMasks, addon.MapOceanBackdrops = { [100] = true }, { [100] = true }
            options.revealAll = true
            map:SetSubject(options)
            addon.MapGeometry.ZoomAt(map.view, 2, 400, 250)
            map:Render()
            local backdrop, detail
            for index, group in pairs(map.renderer.groups) do
                if group.kind == "backdrop" and group.used > 0 then
                    backdrop = index
                    assert.equals(1, group.used)
                    assert.equals(1, group.pool[1].texture.alpha)
                    assert.is_falsy(group.pool[1].masks[2] and group.pool[1].masks[2].attached)
                elseif group.kind == "background" and group.mapID == 1 then
                    -- No coarse border remains underneath the feathered replacement.
                    assert.equals(0, group.used)
                elseif group.kind == "detail" and group.used > 0 then detail = math.min(detail or index, index) end
            end
            assert.is_true(backdrop < detail)
            options.revealAll = false
            map:SetSubject(options)
            for _, group in pairs(map.renderer.groups) do
                if group.kind == "backdrop" then assert.equals(0, group.used) end
            end
        end)
    end)

    it("fills only standalone continent corners beneath native art and culls them while panning", function()
        with_map(function(addon, map, options)
            addon.MapArtMasks = { [100] = true }
            addon.MapCornerFills = { [100] = {
                { file = "100-top-left", rect = { 0, 0, .31, .31 }, uv = { 0, .8, 0, .6 } },
                { file = "100-bottom-right", rect = { .69, .69, 1, 1 }, uv = { 0, .8, 0, .6 } },
            } }
            map:SetSubject(options)
            addon.MapGeometry.ZoomAt(map.view, 1, 400, 250)
            map:Render()
            local cornerIndex, backgroundIndex
            for index, group in pairs(map.renderer.groups) do
                if group.kind == "corners" and group.used > 0 then
                    cornerIndex = index
                    assert.equals(2, group.used)
                    for i = 1, group.used do
                        assert.equals(1, group.pool[i].texture.alpha)
                        assert.equals("CLAMP", group.pool[i].texture.wrap)
                    end
                elseif group.kind == "background" and group.used > 0 then backgroundIndex = index end
            end
            assert.is_true(cornerIndex ~= nil and cornerIndex < backgroundIndex)
            addon.MapGeometry.ZoomAt(map.view, 4, 0, 0)
            map.view.x, map.view.y = 0, 0
            addon.MapGeometry.Constrain(map.view)
            map:Render()
            local checked
            for _, group in pairs(map.renderer.groups) do
                if group.kind == "corners" and group.used > 0 then
                    checked = true
                    assert.equals(1, group.used)
                    assert.is_truthy(group.pool[1].texture.texture:find("top-left", 1, true))
                end
            end
            assert.is_true(checked)
            map.source.root.mapType = 0
            map:Render()
            for _, group in pairs(map.renderer.groups) do
                if group.kind == "corners" then assert.equals(0, group.used) end
            end
        end)
    end)

    it("keeps coastal water hatching in map space above zone art and below terrain", function()
        with_map(function(addon, map, options)
            addon.MapArtMasks = { [100] = true, [200] = true }
            addon.MapWaterHatching = { [100] = {
                { file = "water-west", rect = { .2, .25, .3, .35 }, uv = { 0, 1, 0, 1 } },
                { file = "water-east", rect = { .8, .25, .9, .35 }, uv = { 0, 1, 0, 1 } },
            } }
            options.revealAll = true
            map:SetSubject(options)
            addon.MapGeometry.ZoomAt(map.view, 1, 400, 250)
            map:Render()
            for _, group in pairs(map.renderer.groups) do
                if group.kind == "water" then assert.equals(0, group.used) end
            end
            addon.MapGeometry.ZoomAt(map.view, 1.5, 400, 250)
            map.view.x, map.view.y = .5, .5
            map:Render()
            for _, group in pairs(map.renderer.groups) do
                if group.kind == "water" then
                    for i = 1, group.used do close(.5, group.pool[i].texture.alpha) end
                end
            end
            addon.MapGeometry.ZoomAt(map.view, 1.6, 400, 250)
            map.view.x, map.view.y = .5, .5
            map:Render()
            local checked
            for _, group in pairs(map.renderer.groups) do
                if group.kind == "water" and group.used > 0 then
                    checked = true
                    assert.equals(2, group.used)
                    for i = 1, group.used do assert.equals(1, group.pool[i].texture.alpha) end
                end
            end
            assert.is_true(checked)
            addon.MapGeometry.ZoomAt(map.view, 8, 400, 250)
            map.view.x, map.view.y = .25, .3
            map:Render()
            local detailIndex, waterIndex, terrainIndex
            for index, group in pairs(map.renderer.groups) do
                if group.used > 0 then
                    if group.kind == "detail" then detailIndex = index end
                    if group.kind == "terrain" then terrainIndex = index end
                    if group.kind == "water" then
                        waterIndex = index
                        assert.equals(1, group.used)
                        local texture = group.pool[1].texture
                        assert.is_truthy(texture.texture:find("water-west", 1, true))
                        assert.equals("CLAMP", texture.wrap)
                    end
                end
            end
            assert(detailIndex, "missing detail pass")
            assert(waterIndex, "missing water pass")
            assert(terrainIndex, "missing terrain pass")
            assert.is_true(detailIndex < waterIndex and waterIndex < terrainIndex)
            addon.MapWaterHatching = nil
            map:Render()
            for _, group in pairs(map.renderer.groups) do
                if group.kind == "water" then assert.equals(0, group.used) end
            end
        end)
    end)

    it("retains the original continent ocean through its complete detail transition", function()
        with_map(function(addon, map, options)
            addon.MapArtMasks = { [100] = true }
            addon.MapOceanBackdrops, addon.MapNativeBackdrops = { [100] = true }, { [100] = true }
            options.revealAll = true
            map:SetSubject(options)
            for _, zoom in ipairs({ 1, 1.5, 2, 4 }) do
                addon.MapGeometry.ZoomAt(map.view, zoom, 400, 250)
                map:Render()
                local native
                for _, group in pairs(map.renderer.groups) do
                    if group.kind == "backdrop" then assert.equals(0, group.used) end
                    if group.kind == "background" and group.mapID == 1 and group.used > 0 then
                        native = true
                        for i = 1, group.used do assert.equals(1, group.pool[i].texture.alpha) end
                    end
                end
                assert.is_true(native)
            end
        end)
    end)

    it("draws the local ridge repair without replacing any continent ocean artwork", function()
        with_map(function(addon, map, options)
            addon.MapArtMasks = { [100] = true }
            addon.MapOceanBackdrops, addon.MapNativeBackdrops = { [100] = true }, { [100] = true }
            addon.MapBackgroundRepairs = { [100] = { { file = "100-repair-0", rect = { .4, .4, .45, .45 }, uv = { 0, 1, 0, 1 } } } }
            options.revealAll = true
            map:SetSubject(options)
            addon.MapGeometry.ZoomAt(map.view, 2, 400, 250)
            map:Render()
            local nativeIndex, ridgeIndex, zoneIndex
            for index, group in pairs(map.renderer.groups) do
                if group.kind == "backdrop" then assert.equals(0, group.used) end
                if group.used > 0 then
                    if group.kind == "background" then
                        nativeIndex = index
                        for i = 1, group.used do
                            local texture = group.pool[i].texture
                            assert.is_true(type(texture.texture) == "number")
                            assert.equals(1, texture.alpha)
                        end
                    elseif group.kind == "ridge" then
                        ridgeIndex = index
                        assert.equals(1, group.used)
                        assert.is_truthy(group.pool[1].texture.texture:find("100-repair-0.blp",1,true))
                    elseif group.kind == "base" then zoneIndex = zoneIndex or index end
                end
            end
            assert.is_true(nativeIndex < ridgeIndex and ridgeIndex < zoneIndex)
            options.revealAll = false
            map:SetSubject(options)
            for _, group in pairs(map.renderer.groups) do
                if group.kind == "ridge" then assert.equals(0,group.used) end
            end
        end)
    end)

    it("renders already-revealed base art when its declared exploration records are invisible", function()
        with_map(function(addon, map, options)
            addon.MapArtBaseOnly, addon.MapArtTerritories, addon.MapArtMasks =
                { [200] = true }, { [200] = true }, { [200] = true }
            options.revealAll, options.revision = true, options.revision + 1
            map:SetSubject(options)
            addon.MapGeometry.ZoomAt(map.view, 2, 400, 250)
            map:Render()
            assert.equals(0, #map.source:Exploration(map.source.byID[2]))
            local base
            for _, group in pairs(map.renderer.groups) do
                if group.kind == "base" and group.mapID == 2 and group.used > 0 then base = true end
            end
            assert.is_true(base)
        end)
    end)

    it("draws complete protected labels above neighbouring paintings and fades them before terrain", function()
        with_map(function(addon, map, options)
            addon.MapArtLabels = { [200] = true }
            addon.MapCaptionRepairs = { [200] = { { file="200-0",rect={.2,.2,.3,.3},uv={0,1,0,1} } } }
            options.revealAll = true
            map:SetSubject(options)
            addon.MapGeometry.ZoomAt(map.view, 2, 400, 250)
            map:Render()
            local labelIndex, detailIndex, captionIndex
            for index, group in pairs(map.renderer.groups) do
                if group.kind == "detail" and group.used > 0 then detailIndex = math.max(detailIndex or 0, index) end
                if group.kind == "caption" and group.used > 0 then captionIndex = index end
                if group.kind == "labels" and group.used > 0 then
                    labelIndex = index
                    for i = 1, group.used do
                        assert.is_truthy(group.pool[i].masks[1].texture:find("ArtLabels", 1, true))
                        assert.is_falsy(group.pool[i].masks[2] and group.pool[i].masks[2].attached)
                    end
                end
            end
            assert.is_true(labelIndex > captionIndex and captionIndex > detailIndex)
            addon.MapGeometry.ZoomAt(map.view, 40, 400, 250)
            map:Render()
            for _, group in pairs(map.renderer.groups) do
                if group.kind == "labels" then assert.equals(0, group.used) end
                if group.kind == "caption" then
                    for i = 1, group.used do assert.equals(1, group.pool[i].texture.alpha) end
                end
            end
        end)
    end)

    it("keeps a duplicate-caption repair opaque beneath partially blended terrain", function()
        with_map(function(addon, map, options)
            addon.MapCaptionRepairs = { [200] = { { file = "200-0", rect = { .2, .2, .3, .3 }, uv = { 0, 1, 0, 1 } } } }
            options.revealAll = true
            map:SetSubject(options)
            local G, node = addon.MapGeometry, map.source.byID[2]
            map.view.zoom = 1
            local width = G.Size(map.view)
            local density = width * (node.rect.r - node.rect.l) * addon.MapDataSource.TILE_YARDS / math.abs(node.world.w1 - node.world.w0)
            map.view.zoom = 115 / density
            map.view.x = node.rect.l + .25 * (node.rect.r - node.rect.l)
            map.view.y = node.rect.t + .25 * (node.rect.b - node.rect.t)
            G.Constrain(map.view)
            map:Render()
            local captionIndex, terrainIndex
            for index, group in pairs(map.renderer.groups) do
                if group.used > 0 and group.kind == "caption" then
                    captionIndex = index
                    for i = 1, group.used do assert.equals(1, group.pool[i].texture.alpha) end
                elseif group.used > 0 and group.kind == "terrain" then
                    terrainIndex = index
                    assert.is_true(group.pool[1].texture.alpha > 0 and group.pool[1].texture.alpha < 1)
                end
            end
            assert.is_true(captionIndex ~= nil and terrainIndex > captionIndex)
        end)
    end)

    it("softens nested city rectangles without adding a mask to terrain", function()
        with_map(function(addon, map)
            addon.MapGeometry.ZoomAt(map.view, 6, 400, 250)
            map.view.x, map.view.y = .25, .45
            map:Render()
            local city
            for _, group in pairs(map.renderer.groups) do
                if group.kind == "locality" and group.mapID == 4 and group.used > 0 then
                    city = true
                    for i = 1, group.used do
                        local masks = group.pool[i].masks
                        assert.is_truthy(masks[#masks].texture:find("LocalityFade", 1, true))
                        assert.is_true(#masks <= 3)
                    end
                end
            end
            assert.is_true(city)
        end)
    end)

    it("renders modern painting demand above the old 1400-region cutoff", function()
        with_map(function(addon, map)
            local renderer = addon.MapRenderer.New(map.viewport)
            local group = renderer:Group(1)
            local rect = { l = 0.2, r = 0.3, t = 0.3, b = 0.4 }
            renderer.visible = { l = 0, r = 1, t = 0, b = 1 }
            for i = 1, 1500 do assert.is_true(renderer:Draw(group, map.view, i, rect, nil, 1)) end
            assert.equals(1500, renderer.used)
            assert.is_falsy(renderer.regionBudgetReached)
            renderer:Release()
            assert.equals(0, renderer.used)
            for _, cell in ipairs(group.pool) do assert.is_nil(cell.texture.texture) end
        end)
    end)

    it("releases hidden map textures and restores the same viewport when shown again", function()
        with_map(function(addon, map, options)
            options.revealAll = true
            map:SetSubject(options)
            addon.MapGeometry.ZoomAt(map.view, 40, 400, 250)
            map:Render()
            local x, y, zoom = map.view.x, map.view.y, map.view.zoom
            assert.is_true(map.renderer.used > 0)
            map.viewport.scripts.OnHide()
            assert.equals(0, map.renderer.used)
            for _, group in pairs(map.renderer.groups) do
                for _, cell in ipairs(group.pool) do
                    assert.is_nil(cell.texture.texture)
                    for _, mask in ipairs(cell.masks) do
                        assert.is_falsy(mask.attached)
                        assert.is_nil(mask.texture)
                    end
                end
            end
            map.viewport.scripts.OnShow()
            assert.is_true(map.renderer.used > 0)
            close(x, map.view.x); close(y, map.view.y); close(zoom, map.view.zoom)
            local released = 0
            for _, group in pairs(map.renderer.groups) do
                for i = group.used + 1, #group.pool do
                    assert.is_nil(group.pool[i].texture.texture)
                    released = released + 1
                end
            end
            assert.is_true(released > 0)
        end)
    end)

    it("uses the same monotonic detail transition for differently sized neighboring zones", function()
        with_map(function(addon, map)
            local G, previous = addon.MapGeometry, 0
            map.source.byID[3].rect = { l = 0.50, r = 0.80, t = 0.35, b = 0.65 }
            for step = 0, 24 do
                G.ZoomAt(map.view, 1 + step * 0.05, 400, 250)
                map.view.x, map.view.y = 0.5, 0.5
                local plan = addon.MapScene.Build(map.view, map.source, G.Visible(map.view))
                assert.equals(2, #plan.zones)
                close(plan.zones[1].alpha, plan.zones[2].alpha)
                assert.is_true(plan.zones[1].alpha >= previous)
                previous = plan.zones[1].alpha
            end
            assert.equals(1, previous)
        end)
    end)

    it("draws all zone backgrounds below every zone detail and renders shared terrain only once", function()
        with_map(function(addon, map, options)
            options.revealAll = true
            map:SetSubject(options)
            addon.MapGeometry.ZoomAt(map.view, 8, 400, 250)
            map.view.x, map.view.y = 0.5, 0.3
            map:Render()
            local lastBase, firstDetail, lastDetail, firstTerrain, terrainGroups = 0, math.huge, 0, math.huge, 0
            local ids = {}
            for _, group in pairs(map.renderer.groups) do
                if group.used > 0 then
                    local level = group.frame:GetFrameLevel()
                    if group.kind == "base" then lastBase = math.max(lastBase, level) end
                    if group.kind == "detail" then firstDetail = math.min(firstDetail, level); lastDetail = math.max(lastDetail, level) end
                    if group.kind == "terrain" then
                        firstTerrain, terrainGroups = math.min(firstTerrain, level), terrainGroups + 1
                        for i = 1, group.used do
                            local fid = group.pool[i].texture.texture
                            assert.is_nil(ids[fid])
                            ids[fid] = true
                        end
                    end
                end
            end
            assert.is_true(lastBase > 0 and firstDetail < math.huge and firstTerrain < math.huge)
            assert.is_true(lastBase < firstDetail and lastDetail < firstTerrain)
            assert.equals(1, terrainGroups)
        end)
    end)

    it("retains underground city art above the outdoor terrain pass", function()
        with_map(function(addon, map, options)
            options.revealAll = true
            map:SetSubject(options)
            map.source.byID[4].mapID = 87
            addon.MapGeometry.ZoomAt(map.view, 40, 400, 250)
            map.view.x, map.view.y = 0.25, 0.45
            map:Render()
            local terrainLevel, interiorLevel = 0, 0
            for _, group in pairs(map.renderer.groups) do
                if group.used > 0 and group.kind == "terrain" then terrainLevel = math.max(terrainLevel, group.frame:GetFrameLevel()) end
                if group.used > 0 and group.kind == "interior" then interiorLevel = group.frame:GetFrameLevel() end
            end
            assert.is_true(terrainLevel > 0 and interiorLevel > terrainLevel)
        end)
    end)

    it("shares terrain only when the continent and zone geographic projections agree", function()
        with_map(function(addon, map)
            local node = map.source.byID[2]
            map.source:Art(node)
            local state = { context = map.source:Context(node), detail = 1 }
            local projection = addon.MapScene.TerrainProjection(map.source, node, state)
            assert.equals(1, projection.mapID)
            assert.same(map.source.root.rect, projection.rect)
            node.rect = { l = node.rect.l + 0.1, r = node.rect.r + 0.1, t = node.rect.t, b = node.rect.b }
            assert.equals(node, addon.MapScene.TerrainProjection(map.source, node, state))
            node.world.id = 999
            assert.equals(node, addon.MapScene.TerrainProjection(map.source, node, state))
        end)
    end)

    it("does not delay tiny outdoor zones as if they were city paintings", function()
        with_map(function(addon, map)
            -- Smaller than the old 0.004 area cutoff, like Redridge/Swamp of Sorrows.
            map.source.byID[3].rect = { l = 0.55, r = 0.60, t = 0.35, b = 0.40 }
            addon.MapGeometry.ZoomAt(map.view, 1.65, 400, 250)
            local plan = addon.MapScene.Build(map.view, map.source, addon.MapGeometry.Visible(map.view))
            assert.equals(2, #plan.zones)
            for _, entry in ipairs(plan.zones) do assert.equals(1, entry.alpha) end
            -- A city nested under a zone still gets its close-up transition.
            assert.equals(1, #plan.localities)
            assert.equals(4, plan.localities[1].node.mapID)
            assert.is_true(plan.localities[1].alpha < 1)
        end)
    end)

    it("keeps small no-fog city paintings above zone detail without delaying a small ordinary zone", function()
        with_map(function(addon, map, options)
            map.source.byID[3].rect = { l = 0.55, r = 0.65, t = 0.35, b = 0.43 }
            addon.MapGeometry.ZoomAt(map.view, 3, 400, 250)
            map.view.x, map.view.y = 0.5, 0.5
            local G = addon.MapGeometry
            local plan = addon.MapScene.Build(map.view, map.source, G.Visible(map.view))
            assert.equals(2, #plan.zones)
            local art = addon.MapDataSource.ReadArt(3)
            art.artID = 300
            options.getArt = function(id) if id == 3 then return art end end
            options.revision = options.revision + 1
            map:SetSubject(options)
            plan = addon.MapScene.Build(map.view, map.source, G.Visible(map.view))
            assert.equals(1, #plan.zones)
            local city
            for _, entry in ipairs(plan.localities) do if entry.node.mapID == 3 then city = entry end end
            assert.is_not_nil(city)
            assert.is_true(city.alpha < plan.zones[1].alpha)
        end)
    end)

    it("refreshes cached continent terrain coordinates when the subject art phase changes", function()
        with_map(function(addon, map, options)
            options.revealAll = true
            map:SetSubject(options)
            addon.MapGeometry.ZoomAt(map.view, 40, 400, 250)
            map.view.x, map.view.y = 0.35, 0.55
            map:Render()
            local context = map.source:Context(map.source.byID[2])
            local north = context.world.n0
            local native = C_Map.GetWorldPosFromMapPos
            C_Map.GetWorldPosFromMapPos = function(id, point)
                local world, position = native(id, point)
                local n, w = position:GetXY()
                return world, CreateVector2D(n + 100, w + 100)
            end
            options.revision = options.revision + 1
            map:SetSubject(options)
            close(north + 100, context.world.n0)
            assert.equals(40, map.view.zoom)
        end)
    end)

    it("finishes the zone painting transition before a zone fills the viewport", function()
        with_map(function(addon, map)
            addon.MapGeometry.ZoomAt(map.view, 1.65, 400, 250)
            map:Render()
            local found = false
            for _, group in pairs(map.renderer.groups) do
                for i = 1, group.used do
                    local tex = group.pool[i].texture
                    if tex.texture >= 201 and tex.texture <= 212 then
                        assert.equals(1, tex.alpha)
                        found = true
                    end
                end
            end
            assert.is_true(found)
        end)
    end)

    it("replaces the painting completely with terrain at close zoom", function()
        with_map(function(addon, map, options)
            options.revealAll = true
            map:SetSubject(options)
            addon.MapGeometry.ZoomAt(map.view, 40, 400, 250)
            map.view.x, map.view.y = 0.35, 0.55
            map:Render()
            local textures = terrain(map)
            assert.is_true(#textures > 0)
            for _, texture in ipairs(textures) do assert.equals(1, texture.alpha) end
        end)
    end)

    it("reveals terrain earlier and finishes the crossfade within one wheel step", function()
        with_map(function(addon, map, options)
            options.revealAll = true
            map:SetSubject(options)
            local baseWidth = addon.MapGeometry.Size(map.view) / map.view.zoom
            addon.MapGeometry.ZoomAt(map.view, 90 * 16 / baseWidth, 400, 250)
            map.view.x, map.view.y = 0.5, 0.3
            map:Render()
            assert.equals(0, #terrain(map))
            -- Terrain is already blending before the former 160-pixel onset.
            addon.MapGeometry.ZoomAt(map.view, map.view.zoom * 1.28, 400, 250)
            map:Render()
            local middle = terrain(map)
            assert.is_true(#middle > 0 and middle[1].alpha > 0 and middle[1].alpha < 1)
            addon.MapGeometry.ZoomAt(map.view, map.view.zoom * 1.28, 400, 250)
            map:Render()
            local complete = terrain(map)
            assert.is_true(#complete > 0)
            for _, texture in ipairs(complete) do assert.equals(1, texture.alpha) end
        end)
    end)

    it("keeps zone and terrain masks fixed to the whole map while tile quads are clipped", function()
        with_map(function(addon, map, options)
            options.revealAll = true
            map:SetSubject(options)
            addon.MapGeometry.ZoomAt(map.view, 40, 400, 250)
            map.view.x, map.view.y = 0.35, 0.55
            map:Render()
            local checked = 0
            for _, group in pairs(map.renderer.groups) do
                for i = 1, group.used do
                    local tex = group.pool[i].texture
                    for mask, attached in pairs(tex.masks or {}) do
                        if attached and type(mask.texture) == "string" then
                            local node = group.kind == "terrain" and map.source.root or map.source.byID[2]
                            local left, top = addon.MapGeometry.ToScreen(map.view, node.rect.l, node.rect.t)
                            local right, bottom = addon.MapGeometry.ToScreen(map.view, node.rect.r, node.rect.b)
                            -- A tiny visible piece must not shrink the entire zone mask to that piece.
                            close(left, mask.points[1][4]); close(-top, mask.points[1][5])
                            close(right - left, mask.width); close(bottom - top, mask.height)
                            assert.is_true(mask.width > tex.width)
                            checked = checked + 1
                        end
                    end
                end
            end
            assert.is_true(checked > 0)
        end)
    end)

    it("positions the complete padded discovery mask independently of clipped terrain", function()
        with_map(function(addon, map)
            local renderer, view = map.renderer, map.view
            local G = addon.MapGeometry
            local imageRect = { l = 0.1, t = 0.2, r = 0.5, b = 0.8 }
            local painted = { l = 0.1, t = 0.2, r = 0.4, b = 0.5 }
            local spec = { fileID = 7001, rect = painted, uv = { 0, 0.75, 0, 0.5 } }
            local group = renderer:Group(1)
            for _, zoom in ipairs({ 3, 40 }) do
                G.ZoomAt(view, zoom, 400, 250)
                view.x, view.y = 0.25, 0.35
                renderer.visible = G.Visible(view)
                group.used, renderer.used = 0, 0
                assert.is_true(renderer:Draw(group, view, 9000, painted, { 0, 1, 0, 1 }, 1, { spec }, true))
                local mask = group.pool[1].masks[1]
                local left, top = G.ToScreen(view, imageRect.l, imageRect.t)
                local right, bottom = G.ToScreen(view, imageRect.r, imageRect.b)
                close(left, mask.points[1][4]); close(-top, mask.points[1][5])
                close(right - left, mask.width); close(bottom - top, mask.height)
            end
        end)
    end)

    it("finds the containing continent through a city and rejects hierarchy cycles", function()
        with_map(function(addon)
            assert.equals(1, addon.MapDataSource.Continent(4))
            C_Map.GetMapInfo = function(id) return { parentMapID = id } end
            assert.is_nil(addon.MapDataSource.Continent(100))
        end)
    end)

    it("keeps the point under the cursor fixed while zooming and clamps panning to the continent", function()
        with_map(function(addon, map)
            local G, v = addon.MapGeometry, map.view
            local x, y = G.ToMap(v, 350, 230)
            G.ZoomAt(v, v.zoom * 2, 350, 230)
            local xx, yy = G.ToMap(v, 350, 230)
            close(x, xx); close(y, yy)
            G.Pan(v, 100000, -100000)
            local visible = G.Visible(v)
            assert.is_true(visible.l >= -0.00001 and visible.b <= 1.00001)
            G.ZoomAt(v, 0.01, 300, 200)
            assert.equals(1, v.zoom); assert.equals(0.5, v.x); assert.equals(0.5, v.y)
        end)
    end)

    it("restores the original zone view and preserves navigation through ordinary refreshes", function()
        with_map(function(addon, map, options)
            local x, y, z = map.view.x, map.view.y, map.view.zoom
            addon.MapGeometry.ZoomAt(map.view, 20, 400, 250)
            map:SetSubject(options)
            assert.equals(20, map.view.zoom)
            map.resetButton.scripts.OnClick()
            close(x, map.view.x); close(y, map.view.y); close(z, map.view.zoom)
            assert.is_nil(map.viewport.scripts.OnUpdate)
            options.key, options.mapID = "east", 3
            map:SetSubject(options)
            assert.equals(3, map.mapID)
            close(0.5, map.initialRect.l)
            assert.is_true(map.view.x > 0.5)
        end)
    end)

    it("loads terrain only at detail zoom and masks every terrain piece with the saved discovered shape", function()
        with_map(function(addon, map, _, calls)
            assert.equals(0, calls.data)
            addon.MapGeometry.ZoomAt(map.view, 8, 300, 200)
            map.view.x, map.view.y = 0.16, 0.3
            addon.MapGeometry.Constrain(map.view)
            map:Render()
            assert.equals(1, calls.data)
            local textures = terrain(map)
            assert.is_true(#textures > 0)
            for _, tex in ipairs(textures) do
                local discovered = false
                for mask in pairs(tex.masks) do if mask.texture == 7001 then discovered = true end end
                assert.is_true(discovered)
                assert.is_true(tex.width > 0 and tex.height > 0)
            end
            map:Render()
            assert.equals(1, calls.data)
        end)
    end)

    it("never substitutes another character's exploration or reveals empty fogged snapshots", function()
        with_map(function(addon, map, options)
            options.getExploration = function() return {} end
            options.revision = 2
            map:SetSubject(options)
            addon.MapGeometry.ZoomAt(map.view, 8, 400, 250)
            map:Render()
            assert.equals(0, #terrain(map))
            options.getExploration = function() return nil end
            options.revision = 3
            map:SetSubject(options)
            assert.equals(0, #terrain(map))
            assert.is_true(map.renderer.explorationUnknown)
        end)
    end)

    it("renders a neighboring zone after panning and zooming without changing the continent root", function()
        with_map(function(addon, map)
            addon.MapGeometry.Fit(map.view, map.source.byID[3].rect)
            addon.MapGeometry.ZoomAt(map.view, 8, 400, 250)
            map.view.x = 0.7
            map:Render()
            assert.equals(1, map.source.rootID)
            assert.is_true(map.source.byID[3].art ~= nil)
            assert.is_false(map.pin.shown)
        end)
    end)

    it("animates only during an interaction and stops all movement when hidden", function()
        with_map(function(_, map, _, _, cursor)
            cursor(400, 250)
            map.viewport.scripts.OnMouseWheel(nil, 1)
            assert.is_function(map.viewport.scripts.OnUpdate)
            for _ = 1, 160 do if map.viewport.scripts.OnUpdate then map.viewport.scripts.OnUpdate(nil, 0.016) end end
            assert.is_nil(map.viewport.scripts.OnUpdate)
            map.viewport.scripts.OnMouseDown(nil, "LeftButton")
            cursor(420, 260)
            map.viewport.scripts.OnUpdate(nil, 0.016)
            map.viewport.scripts.OnHide()
            assert.is_nil(map.viewport.scripts.OnUpdate)
            assert.is_nil(map.dragging)
        end)
    end)

    it("crops UVs without stretching and handles reversed world axes", function()
        with_map(function(addon)
            local G, S = addon.MapGeometry, addon.MapDataSource
            assert.same({ 0.25, 0.5, 0, 1 }, G.CropUV({ l = 0, t = 0, r = 1, b = 1 }, { l = 0.25, r = 0.5, t = 0, b = 1 }))
            local rect, uv = S.TileRect({ n0 = 0, n1 = 533.3333333333, w0 = 0, w1 = 533.3333333333 }, 31, 31)
            close(0, rect.l); close(1, rect.r)
            assert.same({ 1, 0, 1, 0 }, uv)
        end)
    end)

    it("uses saved phase art and allows terrain on known maps that have no native fog", function()
        with_map(function(addon, map, options, _, _, sourceNS)
            local art = addon.MapDataSource.ReadArt(2)
            art.artID, art.textures[1] = 300, 5555
            options.getArt = function(id) if id == 2 then return art end end
            options.getExploration = function() return {} end
            options.revision = 2
            map:SetSubject(options)
            assert.equals(5555, map.source:Art(map.source.byID[2]).textures[1])
            addon.MapGeometry.ZoomAt(map.view, 8, 400, 250)
            map:Render()
            assert.is_true(#terrain(map) > 0)
            assert.is_nil(sourceNS.MapTerrainData.fogArt[300])
        end)
    end)

    it("keeps painted maps usable when the optional terrain module is unavailable", function()
        with_map(function(addon, map)
            addon.LoadCatalog = function() return false, "missing" end
            addon.MapGeometry.ZoomAt(map.view, 8, 400, 250)
            map:Render()
            assert.is_true(map.hasMapArt)
            assert.is_true(map.renderer.terrainUnavailable)
            assert.equals(0, #terrain(map))
        end)
    end)

    it("retains the continent painting when a projected zone has no usable art", function()
        with_map(function(addon, map, options)
            local native = C_Map.GetMapArtLayers
            C_Map.GetMapArtLayers = function(id) if id ~= 3 then return native(id) end end
            options.revealAll, options.revision = true, options.revision + 1
            map:SetSubject(options)
            addon.MapGeometry.ZoomAt(map.view, 40, 400, 250)
            map.view.x, map.view.y = 0.7, 0.3
            map:Render()
            assert.is_true(map.hasMapArt)
            assert.is_false(map.source.byID[3].art)
            assert.equals(0, map.renderer.terrainCount)
        end)
    end)

    it("does not stack alternate phase paintings on the same geographic footprint", function()
        with_map(function(addon)
            local native = C_Map.GetMapRectOnMap
            C_Map.GetMapRectOnMap = function(id, root) return native(id == 3 and 2 or id, root) end
            local source = addon.MapDataSource.New({ mapID = 3, continentMapID = 1 })
            assert.is_true(source.byID[2].hiddenPhase)
            assert.is_nil(source.byID[3].hiddenPhase)
        end)
    end)

    it("treats unfamiliar future art as fogged, while recorded no-fog city art needs no overlays", function()
        with_map(function(addon, map, options)
            local art = addon.MapDataSource.ReadArt(2)
            options.getArt = function(id) if id == 2 then return art end end
            options.getExploration = function() return nil end
            art.artID, options.revision = 300, 2
            map:SetSubject(options)
            addon.MapGeometry.ZoomAt(map.view, 8, 400, 250)
            map:Render()
            assert.is_true(#terrain(map) > 0)
            art.artID, options.revision = 999999, 3
            map:SetSubject(options)
            assert.equals(0, #terrain(map))
            assert.is_true(map.renderer.explorationUnknown)
        end)
    end)

    it("fully reveals painted maps and terrain independently of any character's discoveries", function()
        with_map(function(addon, map, options)
            options.revealAll = true
            options.getExploration = function() error("Revealed maps must not read character discoveries") end
            -- Switching policies invalidates cached shapes even without a revision change.
            map:SetSubject(options)
            local node = map.source.byID[2]
            local pieces = map.source:Exploration(node)
            assert.equals(2, #pieces)
            assert.equals(7002, pieces[1].fileID)
            assert.equals(7003, pieces[2].fileID)
            addon.MapGeometry.ZoomAt(map.view, 8, 400, 250)
            map:Render()
            local textures = terrain(map)
            assert.is_true(#textures > 0)
            for _, tex in ipairs(textures) do
                for mask in pairs(tex.masks or {}) do assert.equals("string", type(mask.texture)) end
            end
            assert.is_false(map.renderer.explorationUnknown)
            assert.equals("Terrain detail", map.status.text)
            options.key = "unexplored-offline-alt"
            map:SetSubject(options)
            assert.equals(7002, map.source:Exploration(map.source.byID[2])[1].fileID)
        end)
    end)
end)
