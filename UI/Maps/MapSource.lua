local _, NS = ...
local addon = NS.GoldTracker
local G = addon.MapGeometry
local Source = {}
addon.MapDataSource = Source
local TILE_YARDS = 1600 / 3
Source.TILE_YARDS = TILE_YARDS

function Source.Number(value)
    return not (issecretvalue and issecretvalue(value)) and type(value) == "number"
        and value == value and math.abs(value) < 1e12
end

function Source.Call(fn, ...)
    if type(fn) ~= "function" then return end
    local ok, a, b, c, d = pcall(fn, ...)
    if ok then return a, b, c, d end
end

function Source.ReadArt(mapID)
    local layers = Source.Call(C_Map and C_Map.GetMapArtLayers, mapID)
    local layer = layers and layers[1]
    if not layer or not Source.Number(layer.layerWidth) or not Source.Number(layer.layerHeight)
        or layer.layerWidth <= 0 or layer.layerHeight <= 0 then return end
    local textures = Source.Call(C_Map.GetMapArtLayerTextures, mapID, 1)
    if type(textures) ~= "table" or #textures == 0 then return end
    local copy = { width = layer.layerWidth, height = layer.layerHeight,
        tileWidth = layer.tileWidth or 256, tileHeight = layer.tileHeight or 256,
        artID = Source.Call(C_Map.GetMapArtID, mapID), textures = {} }
    for i, fid in ipairs(textures) do copy.textures[i] = fid end
    return copy
end

function Source.ReadWorld(mapID)
    if not C_Map or not CreateVector2D then return end
    local function point(x, y)
        local id, pos = C_Map.GetWorldPosFromMapPos(mapID, CreateVector2D(x, y))
        if not pos then return end
        local north, west = pos:GetXY()
        if Source.Number(id) and Source.Number(north) and Source.Number(west) then return id, north, west end
    end
    local ok, id, n0, w0 = pcall(point, 0, 0)
    local ok1, other, n1, w1 = pcall(point, 1, 1)
    if ok and ok1 and id and id == other and n0 ~= n1 and w0 ~= w1 then
        return { id = id, n0 = n0, n1 = n1, w0 = w0, w1 = w1 }
    end
end

-- Some outdoor paintings (notably Ahn'Qiraj: The Fallen Kingdom) are tagged
-- Orphan instead of Zone. Only accept those physically on their continent;
-- scenario copies, battlegrounds and dungeon interiors stay separate.
function Source.IsOutdoorOrphan(info)
    if not info or info.mapType ~= 6 or not addon.MapOutdoorZones or not addon.MapOutdoorZones[info.mapID] then return false end
    local parent = Source.Call(C_Map and C_Map.GetMapInfo, info.parentMapID)
    if not parent or parent.mapType ~= 2 then return false end
    local world, continent = Source.ReadWorld(info.mapID), Source.ReadWorld(info.parentMapID)
    return world ~= nil and continent ~= nil and world.id == continent.id
end

function Source.Rect(mapID, rootID)
    if mapID == rootID then return { l = 0, t = 0, r = 1, b = 1 } end
    local l, r, t, b = Source.Call(C_Map and C_Map.GetMapRectOnMap, mapID, rootID)
    if Source.Number(l) and Source.Number(r) and Source.Number(t) and Source.Number(b) and r > l and b > t then
        return { l = l, t = t, r = r, b = b }
    end
end

function Source.Continent(mapID)
    local seen = {}
    while mapID and not seen[mapID] do
        seen[mapID] = true
        local info = Source.Call(C_Map and C_Map.GetMapInfo, mapID)
        if not info then return end
        if info.mapType == 2 then return mapID end
        mapID = info.parentMapID
    end
end

local function powerOfTwo(pixels)
    local size = 16
    while size < pixels do size = size * 2 end
    return size
end

-- Pieces retain their original alpha. These same shapes mask the terrain later.
function Source.OverlayPieces(art, overlays)
    local pieces = {}
    for _, overlay in ipairs(overlays or {}) do
        local width, height = overlay.textureWidth or 0, overlay.textureHeight or 0
        if width > 0 and height > 0 and not overlay.isShownByMouseOver then
            local cols = math.ceil(width / art.tileWidth)
            for row = 0, math.ceil(height / art.tileHeight) - 1 do
                for col = 0, cols - 1 do
                    local fid = overlay.fileDataIDs and overlay.fileDataIDs[row * cols + col + 1]
                    if fid then
                        local w, h = math.min(art.tileWidth, width - col * art.tileWidth), math.min(art.tileHeight, height - row * art.tileHeight)
                        local x, y = (overlay.offsetX or 0) + col * art.tileWidth, (overlay.offsetY or 0) + row * art.tileHeight
                        pieces[#pieces + 1] = { fileID = fid, rect = { l = x / art.width, t = y / art.height,
                            r = (x + w) / art.width, b = (y + h) / art.height },
                            uv = { 0, w / powerOfTwo(w), 0, h / powerOfTwo(h) }, top = overlay.isDrawOnTopLayer }
                    end
                end
            end
        end
    end
    return pieces
end

function Source.New(options, standard)
    local self = setmetatable({ options = options, standard = standard == true,
        nodes = {}, decoded = {}, decodedOrder = {} }, { __index = Source })
    if self.standard then self.rootID = options.mapID
    else self.rootID = options.continentMapID or Source.Continent(options.mapID) or options.mapID end
    if not self.rootID then return self end
    -- Standalone floors / pocket maps that cannot be placed on a continent remain navigable on their own.
    if not Source.Rect(options.mapID or self.rootID, self.rootID) then self.rootID = options.mapID end
    self:AddNode(self.rootID)
    if self.standard then
        self.root = self.byID and self.byID[self.rootID]
        return self
    end
    local children = Source.Call(C_Map and C_Map.GetMapChildrenInfo, self.rootID, nil, true) or {}
    -- Orphan paintings may also be omitted from normal child enumeration.
    -- The reviewed registry supplies candidates; native placement/world checks
    -- still decide whether they belong to this viewport.
    local listed = {}
    for _, info in ipairs(children) do listed[info.mapID] = true end
    for mapID in pairs(addon.MapOutdoorZones or {}) do
        if not listed[mapID] and Source.Rect(mapID, self.rootID) then
            local info = Source.Call(C_Map and C_Map.GetMapInfo, mapID)
            if Source.IsOutdoorOrphan(info) then children[#children + 1] = info end
        end
    end
    table.sort(children, function(a, b) return a.mapID < b.mapID end)
    for _, info in ipairs(children) do
        if info.mapType == 3 or Source.IsOutdoorOrphan(info)
            or (options.includeContinents and info.mapType == 2) or info.mapID == options.mapID then
            self:AddNode(info.mapID, info)
        end
    end
    self:AddNode(options.mapID)
    self.root = self.byID and self.byID[self.rootID]
    -- Alternate phase maps can have the same footprint. Keep one painting there,
    -- preferring the selected map and then the client's positional map choice.
    local footprints = {}
    for _, node in ipairs(self.nodes) do
        if node ~= self.root then
            local r = node.rect
            local key = string.format("%.6f:%.6f:%.6f:%.6f", r.l, r.t, r.r, r.b)
            local previous = footprints[key]
            if previous then
                local preferred = Source.Call(C_Map and C_Map.GetMapInfoAtPosition, self.rootID, (r.l + r.r) / 2, (r.t + r.b) / 2, true)
                local useNew = node.mapID == options.mapID or (previous.mapID ~= options.mapID and preferred and preferred.mapID == node.mapID)
                if useNew then previous.hiddenPhase = true; footprints[key] = node else node.hiddenPhase = true end
            else
                footprints[key] = node
            end
        end
    end
    return self
end

function Source:AddNode(mapID, info)
    if not mapID then return end
    self.byID = self.byID or {}
    if self.byID[mapID] then return self.byID[mapID] end
    local rect = Source.Rect(mapID, self.rootID)
    if not rect then return end
    info = info or Source.Call(C_Map and C_Map.GetMapInfo, mapID) or {}
    local node = { mapID = mapID, name = info.name or "Unknown map",
        mapType = Source.IsOutdoorOrphan(info) and 3 or info.mapType, apiMapType = info.mapType,
        parentMapID = info.parentMapID, rect = rect }
    self.nodes[#self.nodes + 1], self.byID[mapID] = node, node
    return node
end

function Source:Context(node)
    if node.context then return node.context end
    self.contexts = self.contexts or {}
    local id = Source.Continent(node.mapID) or self.rootID
    local context = self.contexts[id]
    if not context then
        context = { mapID = id, rect = Source.Rect(id, self.rootID) or self.root.rect }
        self.contexts[id] = context
    end
    node.context = context
    return context
end

function Source:Art(node)
    if node.art == nil then
        local saved = self.options.getArt and self.options.getArt(node.mapID)
        node.artRecorded = saved ~= nil
        node.art = saved or Source.ReadArt(node.mapID) or false
        node.world = not self.standard and (saved and saved.world or Source.ReadWorld(node.mapID)) or false
    end
    return node.art or nil
end

function Source:Exploration(node)
    if not node.explorationRead then
        node.explorationRead = true
        local art = self:Art(node)
        local overlays
        -- Classic Blizzard paintings always include every discovered-art overlay,
        -- independently of the caller's policy or any character's exploration.
        if self.standard or self.options.revealAll then
            overlays = art and self:RevealedOverlays(art)
        else
            overlays = self.options.getExploration and self.options.getExploration(node.mapID)
        end
        node.explorationKnown = overlays ~= nil
        node.pieces = art and Source.OverlayPieces(art, overlays) or {}
    end
    return node.pieces or {}
end

function Source:RevealedOverlays(art)
    if addon.MapArtBaseOnly and addon.MapArtBaseOnly[art.artID] then return {} end
    local data = self:TerrainData()
    local packed = data and data.revealedOverlays and data.revealedOverlays[art.artID]
    if not packed then return {} end
    local overlays = {}
    for record in packed:gmatch("[^;]+") do
        local w, h, x, y, parts = record:match("^(%d+),(%d+),(%-?%d+),(%-?%d+)|(.+)$")
        if parts then
            local overlay = { textureWidth = tonumber(w), textureHeight = tonumber(h),
                offsetX = tonumber(x), offsetY = tonumber(y), fileDataIDs = {} }
            local cols = math.ceil(overlay.textureWidth / art.tileWidth)
            for col, row, fid in parts:gmatch("(%d+):(%d+):(%d+)") do
                overlay.fileDataIDs[tonumber(row) * cols + tonumber(col) + 1] = tonumber(fid)
            end
            overlays[#overlays + 1] = overlay
        end
    end
    return overlays
end

function Source:TerrainData()
    if not self.dataAttempted then
        self.dataAttempted = true
        if not rawget(NS, "MapTerrainData") and addon.LoadCatalog then addon:LoadCatalog("MapData") end
        self.data = rawget(NS, "MapTerrainData")
    end
    return self.data
end

function Source:ArtMask(node)
    local art = self:Art(node)
    if art and addon.MapArtMasks and addon.MapArtMasks[art.artID] then
        return "Interface\\AddOns\\General-Gold-Tracker\\UI\\Maps\\Media\\ArtMasks\\" .. art.artID .. ".blp"
    end
end

function Source:HasArtTerritory(node)
    local art = self:Art(node)
    return art and addon.MapArtTerritories and addon.MapArtTerritories[art.artID] or false
end

function Source:ArtLabels(node)
    local art = self:Art(node)
    if art and addon.MapArtLabels and addon.MapArtLabels[art.artID] then
        return "Interface\\AddOns\\General-Gold-Tracker\\UI\\Maps\\Media\\ArtLabels\\" .. art.artID .. ".blp"
    end
end

function Source:Tiles(worldID)
    if self.decoded[worldID] then return self.decoded[worldID] end
    local data = self:TerrainData()
    local packed = data and data.tiles[worldID]
    if not packed then return end
    -- Bound expanded tables, even after visiting many continents with one component.
    if #self.decodedOrder >= 4 then self.decoded[table.remove(self.decodedOrder, 1)] = nil end
    local result = {}
    for key, fid in packed:gmatch("(%d+):(%d+)") do result[tonumber(key)] = tonumber(fid) end
    self.decoded[worldID] = result
    self.decodedOrder[#self.decodedOrder + 1] = worldID
    return result
end

-- Texture files are indexed east/south; the game's world axes run north/west.
function Source.TileRect(world, col, row)
    local x0, x1 = ((32 - col) * TILE_YARDS - world.w0) / (world.w1 - world.w0),
        ((31 - col) * TILE_YARDS - world.w0) / (world.w1 - world.w0)
    local y0, y1 = ((32 - row) * TILE_YARDS - world.n0) / (world.n1 - world.n0),
        ((31 - row) * TILE_YARDS - world.n0) / (world.n1 - world.n0)
    return { l = math.min(x0, x1), r = math.max(x0, x1), t = math.min(y0, y1), b = math.max(y0, y1) },
        { x0 < x1 and 0 or 1, x0 < x1 and 1 or 0, y0 < y1 and 0 or 1, y0 < y1 and 1 or 0 }
end

function Source.TileRange(world, rect)
    local a, b = world.w0 + rect.l * (world.w1 - world.w0), world.w0 + rect.r * (world.w1 - world.w0)
    local c, d = world.n0 + rect.t * (world.n1 - world.n0), world.n0 + rect.b * (world.n1 - world.n0)
    return G.Clamp(math.floor(32 - math.max(a, b) / TILE_YARDS), 0, 63),
        G.Clamp(math.floor(32 - math.min(a, b) / TILE_YARDS), 0, 63),
        G.Clamp(math.floor(32 - math.max(c, d) / TILE_YARDS), 0, 63),
        G.Clamp(math.floor(32 - math.min(c, d) / TILE_YARDS), 0, 63)
end
