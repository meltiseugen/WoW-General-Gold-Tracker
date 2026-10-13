local _, NS = ...
local GoldTracker = NS.GoldTracker

local MinimapAreaFill = {}
local ANCHOR_OFFSET = 0.001
local FILL_STEP = 2
local FILL_INSET = 1
local FILL_ALPHA = 0.20
local FILL_REFRESH_SECONDS = 1 / 60

local function RemoveAnchor(owner, anchor)
    if anchor.minimapPinLibrary then
        anchor.minimapPinLibrary:RemoveMinimapIcon(owner, anchor)
        anchor.minimapPinLibrary = nil
    end
    anchor:Hide()
end

local function GetAnchorPosition(anchor, minimap)
    if not anchor:IsShown() then
        return nil
    end
    local x, y = anchor:GetCenter()
    local centerX, centerY = minimap:GetCenter()
    if not x or not y or not centerX or not centerY then
        return nil
    end
    local scale = anchor:GetEffectiveScale() / minimap:GetEffectiveScale()
    return (x * scale) - centerX, (y * scale) - centerY
end

local function GetAnchorOffsets(mapID, context)
    local offsetX, offsetY = ANCHOR_OFFSET, ANCHOR_OFFSET
    local dragons = LibStub and LibStub:GetLibrary("HereBeDragons-2.0", true)
    if dragons and dragons.GetZoneDistance and context.viewRadius then
        local x, y = context.playerX, context.playerY
        local distanceX = dragons:GetZoneDistance(mapID, x, y, mapID, x + ANCHOR_OFFSET, y)
        local distanceY = dragons:GetZoneDistance(mapID, x, y, mapID, x, y + ANCHOR_OFFSET)
        -- Keep reference pins roughly ten screen pixels apart on a normal
        -- minimap: close enough to stay visible, far enough for precise geometry.
        local distance = context.viewRadius * 0.10
        if distanceX and distanceX > 0 then
            offsetX = math.min(0.05, ANCHOR_OFFSET * distance / distanceX)
        end
        if distanceY and distanceY > 0 then
            offsetY = math.min(0.05, ANCHOR_OFFSET * distance / distanceY)
        end
    end
    return offsetX, offsetY
end

local function GetHorizontalBounds(points, y)
    local left, right
    for index, first in ipairs(points) do
        local second = points[(index % #points) + 1]
        if (first.y <= y and second.y > y) or (second.y <= y and first.y > y) then
            local fraction = (y - first.y) / (second.y - first.y)
            local x = first.x + ((second.x - first.x) * fraction)
            left = math.min(left or x, x)
            right = math.max(right or x, x)
        end
    end
    return left, right
end

local function GetBandBounds(points, top, bottom)
    local left, right = GetHorizontalBounds(points, top)
    if not left then
        return nil
    end
    local function IntersectAt(y)
        local bandLeft, bandRight = GetHorizontalBounds(points, y)
        if not bandLeft then
            left, right = nil, nil
            return false
        end
        left = math.max(left, bandLeft)
        right = math.min(right, bandRight)
        return left < right
    end
    if not IntersectAt(bottom) then
        return nil
    end
    for _, point in ipairs(points) do
        if point.y > top and point.y < bottom and not IntersectAt(point.y) then
            return nil
        end
    end
    return left + FILL_INSET, right - FILL_INSET
end

local function GetFillTexture(fill, index)
    local texture = fill.textures[index]
    if not texture then
        texture = fill.frame:CreateTexture(nil, "ARTWORK")
        texture:SetColorTexture(0.08, 0.42, 1.0, 1.0)
        texture:SetAlpha(FILL_ALPHA)
        texture.goldTrackerFillGeometry = {}
        fill.textures[index] = texture
    end
    return texture
end

local function HideUnusedTextures(fill, used)
    for index = used + 1, #fill.textures do
        local texture = fill.textures[index]
        local geometry = texture.goldTrackerFillGeometry
        if geometry.shown then
            texture:Hide()
            geometry.shown = false
        end
    end
end

local function PositionFillTexture(fill, index, left, top, width)
    local texture = GetFillTexture(fill, index)
    local geometry = texture.goldTrackerFillGeometry
    if geometry.left ~= left or geometry.top ~= top then
        -- Replacing the same anchor does not require clearing it first.
        texture:SetPoint("TOPLEFT", fill.frame, "TOPLEFT", left, -top)
        geometry.left, geometry.top = left, top
    end
    if geometry.width ~= width then
        texture:SetSize(width, FILL_STEP)
        geometry.width = width
    end
    if not geometry.shown then
        texture:Show()
        geometry.shown = true
    end
end

function MinimapAreaFill:Render(owner)
    local fill = owner.minimapAreaFill
    if not fill or not fill.active or not fill.origin then
        return
    end
    local minimap = fill.minimap
    local ax, ay = GetAnchorPosition(fill.anchors[1], minimap)
    local bx, by = GetAnchorPosition(fill.anchors[2], minimap)
    local cx, cy = GetAnchorPosition(fill.anchors[3], minimap)
    if not ax or not bx or not cx then
        fill.dirty = true
        HideUnusedTextures(fill, 0)
        return
    end
    local width, height = minimap:GetWidth(), minimap:GetHeight()
    local shape = type(GetMinimapShape) == "function" and GetMinimapShape() or "ROUND"
    local previous = fill.lastTransform
    if not fill.dirty and previous and previous.width == width and previous.height == height
        and previous.shape == shape
        and math.abs(previous.ax - ax) < 0.01 and math.abs(previous.ay - ay) < 0.01
        and math.abs(previous.bx - bx) < 0.01 and math.abs(previous.by - by) < 0.01
        and math.abs(previous.cx - cx) < 0.01 and math.abs(previous.cy - cy) < 0.01 then
        return
    end
    fill.lastTransform = { ax = ax, ay = ay, bx = bx, by = by, cx = cx, cy = cy,
        width = width, height = height, shape = shape }
    fill.dirty = false

    -- Recover the map-to-screen transform from actual pin positions. No player
    -- facing, camera angle or independent world-coordinate transform is used.
    local xx, xy = (bx - ax) / fill.origin.offsetX, (by - ay) / fill.origin.offsetX
    local yx, yy = (cx - ax) / fill.origin.offsetY, (cy - ay) / fill.origin.offsetY
    if math.abs((xx * yy) - (xy * yx)) < 0.000001 then
        fill.dirty = true
        HideUnusedTextures(fill, 0)
        return
    end
    local polygons = {}
    for _, polygon in ipairs(fill.polygons) do
        local points = {}
        for _, point in ipairs(polygon.points or {}) do
            local dx, dy = point.x - fill.origin.x, point.y - fill.origin.y
            points[#points + 1] = {
                x = (width * 0.5) + ax + (dx * xx) + (dy * yx),
                y = (height * 0.5) - ay - (dx * xy) - (dy * yy),
            }
        end
        polygons[#polygons + 1] = points
    end

    local radiusX, radiusY = (width * 0.5) - FILL_INSET, (height * 0.5) - FILL_INSET
    local used = 0
    for top = FILL_INSET, height - FILL_INSET - FILL_STEP, FILL_STEP do
        local bottom = top + FILL_STEP
        local clipLeft, clipRight = FILL_INSET, width - FILL_INSET
        if shape ~= "SQUARE" then
            local distanceY = math.max(math.abs(top - height * 0.5), math.abs(bottom - height * 0.5))
            local halfWidth = radiusX * math.sqrt(math.max(0, 1 - (distanceY / radiusY) ^ 2))
            clipLeft, clipRight = (width * 0.5) - halfWidth, (width * 0.5) + halfWidth
        end
        local spans = {}
        for _, points in ipairs(polygons) do
            local left, right = GetBandBounds(points, top, bottom)
            if left and right then
                left, right = math.max(left, clipLeft), math.min(right, clipRight)
                if left < right then
                    spans[#spans + 1] = { left = left, right = right }
                end
            end
        end
        table.sort(spans, function(left, right) return left.left < right.left end)
        -- Union overlapping farm areas so translucent fills never stack darker.
        local index = 1
        while index <= #spans do
            local left, right = spans[index].left, spans[index].right
            index = index + 1
            while index <= #spans and spans[index].left <= right do
                right = math.max(right, spans[index].right)
                index = index + 1
            end
            used = used + 1
            PositionFillTexture(fill, used, left, top, right - left)
        end
    end
    HideUnusedTextures(fill, used)
end

function MinimapAreaFill:Hide(owner)
    local fill = owner.minimapAreaFill
    if not fill or not fill.active then
        return
    end
    fill.active = false
    fill.origin = nil
    fill.lastTransform = nil
    fill.frame.elapsed = 0
    HideUnusedTextures(fill, 0)
    for _, anchor in ipairs(fill.anchors) do
        RemoveAnchor(owner, anchor)
    end
    fill.frame:Hide()
end

function MinimapAreaFill:Refresh(owner, mapID, polygons, context, library, positionFallback)
    if #polygons == 0 or (not library and not context) then
        self:Hide(owner)
        return
    end
    local fill = owner.minimapAreaFill
    if not fill then
        fill = { minimap = Minimap, textures = {}, anchors = {}, polygons = {} }
        fill.frame = CreateFrame("Frame", nil, Minimap)
        fill.frame:SetAllPoints(Minimap)
        fill.frame:SetFrameStrata("HIGH")
        fill.frame:SetFrameLevel((Minimap:GetFrameLevel() or 0) + 19)
        fill.frame:EnableMouse(false)
        fill.frame:SetClipsChildren(true)
        for index = 1, 3 do
            local anchor = CreateFrame("Frame", nil, Minimap)
            anchor:SetSize(1, 1)
            anchor:SetAlpha(0)
            anchor:EnableMouse(false)
            fill.anchors[index] = anchor
        end
        -- Follow the existing pin positions at up to 60 Hz without speeding up
        -- the shared pin updater or the slower farm-state/registration checks.
        fill.frame:SetScript("OnUpdate", function(frame, elapsed)
            frame.elapsed = (frame.elapsed or 0) + elapsed
            if frame.elapsed < FILL_REFRESH_SECONDS then
                return
            end
            -- Preserve fractional time so frame-rate rounding does not turn a
            -- 60 Hz cap into noticeably slower, uneven redraws. No catch-up loop.
            frame.elapsed = frame.elapsed % FILL_REFRESH_SECONDS
            self:Render(owner)
        end)
        owner.minimapAreaFill = fill
    end
    if #fill.polygons ~= #polygons then
        fill.dirty = true
    else
        for index, polygon in ipairs(polygons) do
            if fill.polygons[index] ~= polygon then
                fill.dirty = true
                break
            end
        end
    end
    fill.polygons = polygons
    fill.active = true
    fill.frame:Show()
    local ax, ay = GetAnchorPosition(fill.anchors[1], Minimap)
    local radius = math.min(Minimap:GetWidth(), Minimap:GetHeight()) * 0.15
    local needsOrigin = not fill.origin or fill.mapID ~= mapID or fill.library ~= library
        or not ax or ((ax * ax) + (ay * ay)) > (radius * radius)
    if needsOrigin and context and context.playerX and context.playerY then
        local offsetX, offsetY = GetAnchorOffsets(mapID, context)
        fill.origin = { x = context.playerX, y = context.playerY, offsetX = offsetX, offsetY = offsetY }
        fill.mapID, fill.library = mapID, library
        fill.dirty = true
        fill.frame.elapsed = FILL_REFRESH_SECONDS
        for index, anchor in ipairs(fill.anchors) do
            RemoveAnchor(owner, anchor)
            anchor.pinData = {
                x = fill.origin.x + (index == 2 and fill.origin.offsetX or 0),
                y = fill.origin.y + (index == 3 and fill.origin.offsetY or 0),
            }
            if library then
                library:AddMinimapIconMap(owner, anchor, mapID, anchor.pinData.x, anchor.pinData.y, false, false)
                anchor.minimapPinLibrary = library
            end
        end
        -- Do not use stale screen coordinates while the three new pins are queued.
        HideUnusedTextures(fill, 0)
    elseif needsOrigin then
        self:Hide(owner)
        return
    end
    if not library then
        for _, anchor in ipairs(fill.anchors) do
            local x, y = positionFallback(anchor.pinData)
            if x and y then
                anchor:ClearAllPoints()
                anchor:SetPoint("CENTER", Minimap, "CENTER", x, y)
            end
            anchor:SetShown(x ~= nil and y ~= nil)
        end
    end
end

GoldTracker.MinimapAreaFill = MinimapAreaFill
