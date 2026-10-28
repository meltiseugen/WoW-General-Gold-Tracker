local _, NS = ...
local addon = NS.GoldTracker
local G, Source, Scene = addon.MapGeometry, addon.MapDataSource, addon.MapScene
local Renderer = {}
addon.MapRenderer = Renderer
local FEATHER = "Interface\\AddOns\\General-Gold-Tracker\\UI\\Maps\\Media\\EdgeFade.tga"
local PAPER = "Interface\\AddOns\\General-Gold-Tracker\\UI\\Maps\\Media\\MapPaper.tga"
local FRAME = "Interface\\AddOns\\General-Gold-Tracker\\UI\\Maps\\Media\\FrameCutout.blp"
local BOUNDS = "Interface\\AddOns\\General-Gold-Tracker\\UI\\Maps\\Media\\BoundsFade.blp"
local LOCALITY = "Interface\\AddOns\\General-Gold-Tracker\\UI\\Maps\\Media\\LocalityFade.tga"
local UNIT = { l = 0, t = 0, r = 1, b = 1 }
-- Outdoor minimap textures cannot describe these underground city interiors.
local INTERIOR_MAPS = { [87] = true, [90] = true }
-- Modern 4K paintings need more quads than the original Classic-zone preview.
-- The cross-continent audit peaks above 2,000 during the brief detail transition.
local MAX_TERRAIN_TILES, MAX_REGIONS = 256, 4096
Renderer.MAX_REGIONS = MAX_REGIONS

local function terrainBlend(view, node)
    if not node.world or node.mapType ~= 3 or INTERIOR_MAPS[node.mapID] then return 0 end
    local canvasW = G.Size(view)
    local pixels = canvasW * (node.rect.r - node.rect.l) * Source.TILE_YARDS / math.abs(node.world.w1 - node.world.w0)
    -- Screen-space density keeps every map's terrain transition consistent.
    -- Start about two wheel steps earlier while retaining a short crossfade.
    return G.Smooth(100, 130, pixels)
end

function Renderer.New(viewport)
    return setmetatable({ viewport = viewport, groups = {}, used = 0 }, { __index = Renderer })
end

function Renderer:Group(index)
    local group = self.groups[index]
    if not group then
        group = { frame = CreateFrame("Frame", nil, self.viewport), pool = {}, used = 0 }
        group.frame:SetAllPoints(self.viewport)
        group.frame:SetFrameLevel(self.viewport:GetFrameLevel() + index)
        group.frame:EnableMouse(false)
        self.groups[index] = group
    end
    return group
end

local function position(region, viewport, view, rect)
    local x, y = G.ToScreen(view, rect.l, rect.t)
    local r, b = G.ToScreen(view, rect.r, rect.b)
    region:ClearAllPoints()
    region:SetPoint("TOPLEFT", viewport, "TOPLEFT", x, -y)
    region:SetSize(math.max(0.01, r - x), math.max(0.01, b - y))
end

-- A mask is a separate image in map space, not a crop of the texture it masks.
-- MaskTexture UV cropping is unreliable in the client. Place its complete image
-- instead; for a padded overlay, extend the geometry to include the unused pixels.
local function maskImageRect(spec)
    local r, uv = spec.rect, spec.uv or { 0, 1, 0, 1 }
    local w, h = (r.r - r.l) / (uv[2] - uv[1]), (r.b - r.t) / (uv[4] - uv[3])
    local l, t = r.l - uv[1] * w, r.t - uv[3] * h
    return { l = l, t = t, r = l + w, b = t + h }
end

function Renderer:Draw(group, view, fileID, rect, uv, alpha, masks, terrain, wrap, subLevel)
    if alpha < 0.005 then return end
    local clipped = G.Intersection(rect, self.visible)
    if not clipped then return end
    if self.used >= MAX_REGIONS then self.regionBudgetReached = true; return end
    group.used, self.used = group.used + 1, self.used + 1
    local cell = group.pool[group.used]
    if not cell then
        cell = { texture = group.frame:CreateTexture(nil, "ARTWORK"), masks = {} }
        group.pool[group.used] = cell
    end
    local texture = cell.texture
    cell.active = true
    -- The client may batch textures sharing a draw depth. Keep revealed art
    -- above the covered painting, and reset the depth on every pooled reuse.
    texture:SetDrawLayer("ARTWORK", subLevel or 0)
    texture:SetTexture(fileID, wrap or "CLAMP", wrap or "CLAMP", "TRILINEAR")
    texture:SetTexCoord(unpack(G.CropUV(rect, clipped, uv)))
    texture:SetAlpha(alpha)
    texture:SetDesaturation(terrain and 0.12 or 0)
    texture:SetVertexColor(1, terrain and 0.97 or 1, terrain and 0.92 or 1)
    position(texture, self.viewport, view, clipped)
    for i = 1, math.max(#cell.masks, #(masks or {})) do
        local spec, mask = masks and masks[i], cell.masks[i]
        if spec then
            if not mask then
                mask = group.frame:CreateMaskTexture()
                cell.masks[i] = mask
            end
            mask:SetTexture(spec.fileID, "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE", "TRILINEAR")
            position(mask, self.viewport, view, maskImageRect(spec))
            mask:Show()
            if not mask.attached then texture:AddMaskTexture(mask); mask.attached = true end
        elseif mask then
            if mask.attached then texture:RemoveMaskTexture(mask); mask.attached = false end
            mask:Hide()
        end
    end
    texture:Show()
    return true
end

local function release(cell)
    if not cell.active then return end
    cell.active = nil
    cell.texture:Hide()
    cell.texture:SetTexture(nil)
    for _, mask in ipairs(cell.masks) do
        if mask.attached then cell.texture:RemoveMaskTexture(mask); mask.attached = nil end
        mask:Hide()
        mask:SetTexture(nil)
    end
end

function Renderer:Release()
    for _, group in pairs(self.groups) do
        for _, cell in ipairs(group.pool) do release(cell) end
        group.used = 0
    end
    self.used = 0
end

function Renderer:Base(group, view, node, art, alpha, feather)
    local cols = math.ceil(art.width / art.tileWidth)
    local clip = G.Intersection(node.rect, self.visible)
    if not clip then return end
    local w, h = node.rect.r - node.rect.l, node.rect.b - node.rect.t
    local firstCol = math.max(0, math.floor((clip.l - node.rect.l) / w * art.width / art.tileWidth))
    local lastCol = math.min(cols - 1, math.floor((clip.r - node.rect.l) / w * art.width / art.tileWidth))
    local firstRow = math.max(0, math.floor((clip.t - node.rect.t) / h * art.height / art.tileHeight))
    local lastRow = math.min(math.ceil(art.height / art.tileHeight) - 1, math.floor((clip.b - node.rect.t) / h * art.height / art.tileHeight))
    for row = firstRow, lastRow do
        for col = firstCol, lastCol do
            local fid = art.textures[row * cols + col + 1]
            if fid then
                local w, h = math.min(art.tileWidth, art.width - col * art.tileWidth), math.min(art.tileHeight, art.height - row * art.tileHeight)
                local rect = G.SubRect(node.rect, col * art.tileWidth / art.width, row * art.tileHeight / art.height,
                    (col * art.tileWidth + w) / art.width, (row * art.tileHeight + h) / art.height)
                self:Draw(group, view, fid, rect, { 0, w / art.tileWidth, 0, h / art.tileHeight }, alpha, feather)
            end
        end
    end
end

function Renderer:Overlays(group, view, source, node, alpha, feather)
    for _, piece in ipairs(source:Exploration(node)) do
        local p = piece.rect
        local rect = G.SubRect(node.rect, p.l, p.t, p.r, p.b)
        self:Draw(group, view, piece.fileID, rect, piece.uv, alpha, feather, nil, nil, piece.top and 2 or 1)
    end
end

function Renderer:Terrain(group, view, source, node, alpha, feather)
    local world = node.world
    if not world or node.mapType ~= 3 or INTERIOR_MAPS[node.mapID] then return 0 end
    -- A narrow spatial band gives roughly one wheel step of blending. A long
    -- crossfade makes painted labels and terrain look like two competing maps.
    local blend = terrainBlend(view, node) * alpha
    if blend < 0.005 then return 0 end
    local data = source:TerrainData()
    if not data then self.terrainUnavailable = true return 0 end
    -- Discovery-gated callers remain supported; Alts explicitly requests revealAll.
    local clear = node.art.artID and data.clearArt and data.clearArt[node.art.artID]
    local fog = not source.options.revealAll and not clear
    if not source.options.revealAll and (not node.art.artID or (not node.explorationKnown and (fog or not node.artRecorded))) then
        self.explorationUnknown = true
        return 0
    end
    local tiles = source:Tiles(world.id)
    if not tiles then self.terrainUnavailable = true return 0 end
    local localVisible = { l = (self.visible.l - node.rect.l) / (node.rect.r - node.rect.l),
        r = (self.visible.r - node.rect.l) / (node.rect.r - node.rect.l),
        t = (self.visible.t - node.rect.t) / (node.rect.b - node.rect.t),
        b = (self.visible.b - node.rect.t) / (node.rect.b - node.rect.t) }
    localVisible = G.Intersection(localVisible, UNIT)
    if not localVisible then return 0 end
    local c0, c1, r0, r1 = Source.TileRange(world, localVisible)
    if (c1 - c0 + 1) * (r1 - r0 + 1) > MAX_TERRAIN_TILES then return 0 end
    local count = 0
    for col = c0, c1 do
        for row = r0, r1 do
            local fid = tiles[col * 64 + row]
            if fid then
                local tile, uv = Source.TileRect(world, col, row)
                local tileRoot = G.SubRect(node.rect, tile.l, tile.t, tile.r, tile.b)
                local clip = G.Intersection(tileRoot, node.rect)
                if clip then
                    if fog then
                        -- One intersection per discovered overlay piece preserves its exact alpha silhouette.
                        for _, piece in ipairs(node.pieces) do
                            local p = piece.rect
                            local maskRect = G.SubRect(node.rect, p.l, p.t, p.r, p.b)
                            local visible = G.Intersection(clip, maskRect)
                            if visible then
                                local masks = { { fileID = piece.fileID, rect = maskRect, uv = piece.uv } }
                                if feather then masks[2] = feather[1] end
                                if self:Draw(group, view, fid, visible, G.CropUV(tileRoot, visible, uv), blend, masks, true) then count = count + 1 end
                            end
                        end
                    else
                        if self:Draw(group, view, fid, clip, G.CropUV(tileRoot, clip, uv), blend, feather, true) then count = count + 1 end
                    end
                end
            end
        end
    end
    return count
end

function Renderer:PaintingRepairs(group, view, node, repairs, opacity, directory)
    for _, repair in ipairs(repairs) do
        local r = repair.rect
        local path = "Interface\\AddOns\\General-Gold-Tracker\\UI\\Maps\\Media\\" .. directory .. "\\" .. repair.file .. ".blp"
        self:Draw(group, view, path, G.SubRect(node.rect, r[1], r[2], r[3], r[4]), repair.uv, opacity)
    end
end

function Renderer:Render(view, source)
    self.visible, self.used = G.Intersection(G.Visible(view), UNIT), 0
    self.regionBudgetReached = false
    self.terrainUnavailable, self.explorationUnknown, self.terrainCount = false, false, 0
    for _, group in pairs(self.groups) do group.used = 0 end
    if self.visible and source.root and source.standard then
        -- Ordinary Blizzard painting, with revealed overlays but no stitching,
        -- generated masks/backgrounds, local repairs, or minimap terrain.
        local node, group = source.root, self:Group(1)
        group.mapID, group.kind = node.mapID, "standard"
        local art = source:Art(node)
        if art then
            self:Base(group, view, node, art, 1)
            self:Overlays(group, view, source, node, 1)
        end
    elseif self.visible and source.root then
        local plan, index = Scene.Build(view, source, self.visible), 0
        local terrainEntries, interiors = {}, {}
        local function groupFor(node, kind)
            index = index + 1
            local group = self:Group(index)
            group.mapID, group.kind = node.mapID, kind
            return group
        end
        local function feather(node, painting, base, locality)
            local mask = painting and source:ArtMask(node)
            local masks
            if mask then
                -- A standalone continent owns its ocean too. A land-only cutout
                -- leaves chopped sea labels and empty paper around its coasts.
                if node == source.root and node.mapType <= 2 then mask = FRAME end
                masks = { { fileID = mask, rect = node.rect } }
                if node.mapType == 3 then
                    if not source:HasArtTerritory(node) then masks[2] = { fileID = FRAME, rect = node.rect } end
                elseif base then masks[2] = { fileID = BOUNDS, rect = node.rect } end
            elseif node ~= source.root then
                masks = { { fileID = FEATHER, rect = node.rect } }
            end
            if locality and node ~= source.root then
                masks = masks or {}
                masks[#masks + 1] = { fileID = LOCALITY, rect = node.rect }
            end
            return masks
        end
        local function paint(entry, kind, opacity)
            local node, alpha = entry.node, entry.alpha * (opacity or 1)
            if alpha <= 0.005 then return end
            local art = source:Art(node)
            if not art then return end
            local group = groupFor(node, kind)
            if kind == "labels" then
                local label = source:ArtLabels(node)
                if not label then return end
                local masks = { { fileID = label, rect = node.rect } }
                alpha = alpha * (1 - terrainBlend(view, node))
                if alpha <= 0.005 then return end
                self:Base(group, view, node, art, alpha, masks)
                self:Overlays(group, view, source, node, alpha, masks)
                return
            end
            -- Shared territories keep each painting's base and revealed pieces
            -- together. A raw exploration-alpha mask cannot safely include the
            -- base: its unchanged frame and neighbour labels would bleed out.
            local revealed = source.options.revealAll and node.mapType == 3
                and source:ArtMask(node) and #source:Exploration(node) > 0
            if source:HasArtTerritory(node) then revealed = false end
            if kind ~= "detail" and not revealed then self:Base(group, view, node, art, alpha, feather(node, true, true, kind == "locality")) end
            if kind ~= "base" then self:Overlays(group, view, source, node, alpha, feather(node, true, false, kind == "locality")) end
        end
        if source:ArtMask(source.root) then
            -- Keep the fill at viewport scale instead of magnifying paper grain
            -- with the continent. Paintings and their coordinates remain intact.
            local art = source.root.art
            local native = addon.MapArtPaper and addon.MapArtPaper[art.artID]
            local paper = native and ("Interface\\AddOns\\General-Gold-Tracker\\UI\\Maps\\Media\\MapPaper\\" .. art.artID .. ".blp") or PAPER
            self:Draw(groupFor(source.root, "paper"), view, paper, self.visible,
                { 0, view.width / 128, 0, view.height / 128 }, 1, nil, nil, "REPEAT")
        end
        -- A standalone continent's frame mask hides its corner ornaments.
        -- Continue its own ocean underneath those holes, fixed to map space.
        local root = source.root
        local corners = root.mapType == 2 and root.art and addon.MapCornerFills and addon.MapCornerFills[root.art.artID]
        if corners and source:ArtMask(root) then
            local group = groupFor(root, "corners")
            for _, corner in ipairs(corners) do
                local r = corner.rect
                local path = "Interface\\AddOns\\General-Gold-Tracker\\UI\\Maps\\Media\\CornerFills\\" .. corner.file .. ".blp"
                self:Draw(group, view, path, G.SubRect(root.rect, r[1], r[2], r[3], r[4]), corner.uv, 1)
            end
        end
        -- Complete backgrounds first, then every zone's revealed detail. A later
        -- zone's parchment/corner decorations can no longer erase its neighbor.
        for _, entry in ipairs(plan.backgrounds) do
            local node = entry.node
            local state, art = plan.contexts[node.mapID], source:Art(node)
            local replacement = source.options.revealAll and state and art
                and addon.MapOceanBackdrops and addon.MapOceanBackdrops[art.artID]
                and not (addon.MapNativeBackdrops and addon.MapNativeBackdrops[art.artID])
            -- Retire the old painting as a whole. Covering it with another masked
            -- quad leaves its frame/labels visible through the new quad's feather.
            paint(entry, "background", replacement and (1 - state.detail) or 1)
            if replacement and state.detail > 0.005 then
                -- Replace the coarse continent labels along with its land. A
                -- clean, matched paper field continues beneath the zone coasts.
                -- Keep this below child-continent paintings (e.g. Argus inset).
                local file = "Interface\\AddOns\\General-Gold-Tracker\\UI\\Maps\\Media\\DetailBackdrop\\" .. art.artID .. ".blp"
                self:Draw(groupFor(node, "backdrop"), view, file, node.rect,
                    { 0, art.width / 512, 0, art.height / 512 }, state.detail * entry.alpha,
                    feather(node, true, false), nil, "REPEAT")
            end
        end
        -- Local repairs sit beneath zone art, restricted to the marked defects.
        for _, entry in ipairs(plan.backgrounds) do
            local node = entry.node
            local state = plan.contexts[node.mapID]
            local repairs = node.art and addon.MapBackgroundRepairs and addon.MapBackgroundRepairs[node.art.artID]
            if source.options.revealAll and repairs and state and state.detail > 0.005 then
                local group = groupFor(node, "ridge")
                for _, repair in ipairs(repairs) do
                    local r = repair.rect
                    local path = "Interface\\AddOns\\General-Gold-Tracker\\UI\\Maps\\Media\\NativeBackgrounds\\" .. repair.file .. ".blp"
                    self:Draw(group, view, path, G.SubRect(node.rect, r[1], r[2], r[3], r[4]), repair.uv,
                        state.detail * entry.alpha)
                end
            end
        end
        for _, entry in ipairs(plan.zones) do paint(entry, "base") end
        for _, entry in ipairs(plan.zones) do paint(entry, "detail"); terrainEntries[#terrainEntries + 1] = entry end
        -- Fine coastal hatch ink is authored offline inside its Y..X water band.
        -- Its mask protects both continent ink and the zones' revealed land.
        if source.options.revealAll then
            for _, entry in ipairs(plan.backgrounds) do
                local node = entry.node
                local state = plan.contexts[node.mapID]
                local patches = node.art and addon.MapWaterHatching and addon.MapWaterHatching[node.art.artID]
                if patches and state and state.detail > 0.005 then
                    local group = groupFor(node, "water")
                    local masks
                    if node ~= source.root then masks = feather(node, true, false) end
                    for _, patch in ipairs(patches) do
                        local r = patch.rect
                        local path = "Interface\\AddOns\\General-Gold-Tracker\\UI\\Maps\\Media\\WaterHatching\\" .. patch.file .. ".blp"
                        self:Draw(group, view, path, G.SubRect(node.rect, r[1], r[2], r[3], r[4]),
                            patch.uv, entry.alpha * state.detail, masks)
                    end
                end
            end
        end
        for _, entry in ipairs(plan.localities) do
            if INTERIOR_MAPS[entry.node.mapID] then interiors[#interiors + 1] = entry
            else paint(entry, "locality"); terrainEntries[#terrainEntries + 1] = entry end
        end
        if source.root.mapType == 3 then
            terrainEntries[#terrainEntries + 1] = { node = source.root, alpha = 1,
                state = plan.contexts[source:Context(source.root).mapID] }
        end
        if source.options.revealAll then
            for _, entry in ipairs(terrainEntries) do
                local repairs = entry.node.art and addon.MapCaptionRepairs and addon.MapCaptionRepairs[entry.node.art.artID]
                if repairs then
                    -- Terrain already fades over this repair. Fading it here
                    -- exposes the duplicate caption again during that blend.
                    local opacity = entry.alpha
                    local group = groupFor(entry.node, "caption")
                    self:PaintingRepairs(group, view, entry.node, repairs, opacity, "CaptionRepairs")
                end
                local roads = entry.node.art and addon.MapRoadLinks and addon.MapRoadLinks[entry.node.art.artID]
                if roads then
                    self:PaintingRepairs(groupFor(entry.node, "roads"), view, entry.node, roads, entry.alpha, "RoadLinks")
                end
            end
            for _, entry in ipairs(terrainEntries) do
                if source:ArtLabels(entry.node) then paint(entry, "labels") end
                local moves = entry.node.art and addon.MapLabelMoves and addon.MapLabelMoves[entry.node.art.artID]
                if moves then
                    self:PaintingRepairs(groupFor(entry.node, "moved-labels"), view, entry.node, moves,
                        entry.alpha * (1 - terrainBlend(view, entry.node)), "LabelMoves")
                end
            end
        end
        -- Terrain is the final outdoor pass. Fully revealed callers render each
        -- physical continent once, continuously across painted zone rectangles.
        local seen = {}
        for _, entry in ipairs(terrainEntries) do
            local node = entry.node
            if entry.alpha > 0.005 and node.art and node.world and not INTERIOR_MAPS[node.mapID] then
                local projection, alpha = node, entry.alpha
                if source.options.revealAll then
                    projection = Scene.TerrainProjection(source, node, entry.state)
                    alpha = entry.state.detail
                    if node == source.root then alpha = 1 end
                end
                local key = source.options.revealAll and (projection.mapID .. ":" .. node.world.id) or node.mapID
                if not seen[key] then
                    seen[key] = true
                    local group = groupFor(projection, "terrain")
                    self.terrainCount = self.terrainCount + self:Terrain(group, view, source, projection, alpha, feather(projection))
                end
            end
        end
        -- Outdoor terrain must never replace underground city interiors.
        for _, entry in ipairs(interiors) do paint(entry, "interior") end
    end
    for _, group in pairs(self.groups) do
        for i = group.used + 1, #group.pool do release(group.pool[i]) end
    end
end
