local _, NS = ...
local G = {}
NS.GoldTracker.MapGeometry = G

function G.Clamp(value, low, high)
    return math.max(low, math.min(high, value))
end

function G.Smooth(low, high, value)
    local t = G.Clamp((value - low) / (high - low), 0, 1)
    return t * t * (3 - 2 * t)
end

function G.Intersection(a, b)
    local l, t, r, bottom = math.max(a.l, b.l), math.max(a.t, b.t), math.min(a.r, b.r), math.min(a.b, b.b)
    if r > l and bottom > t then return { l = l, t = t, r = r, b = bottom } end
end

function G.Contains(rect, x, y)
    return x >= rect.l and x <= rect.r and y >= rect.t and y <= rect.b
end

function G.SubRect(parent, l, t, r, b)
    local w, h = parent.r - parent.l, parent.b - parent.t
    return { l = parent.l + l * w, t = parent.t + t * h, r = parent.l + r * w, b = parent.t + b * h }
end

function G.Size(view)
    local fit = math.min(view.width / view.artWidth, view.height / view.artHeight)
    return view.artWidth * fit * view.zoom, view.artHeight * fit * view.zoom
end

function G.Constrain(view)
    view.zoom = G.Clamp(view.zoom, 1, view.maxZoom)
    local w, h = G.Size(view)
    view.x = w <= view.width and 0.5 or G.Clamp(view.x, view.width / (2 * w), 1 - view.width / (2 * w))
    view.y = h <= view.height and 0.5 or G.Clamp(view.y, view.height / (2 * h), 1 - view.height / (2 * h))
end

function G.ToMap(view, x, y)
    local w, h = G.Size(view)
    return view.x + (x - view.width / 2) / w, view.y + (y - view.height / 2) / h
end

function G.ToScreen(view, x, y)
    local w, h = G.Size(view)
    return view.width / 2 + (x - view.x) * w, view.height / 2 + (y - view.y) * h
end

function G.Visible(view)
    local l, t = G.ToMap(view, 0, 0)
    local r, b = G.ToMap(view, view.width, view.height)
    return { l = l, t = t, r = r, b = b }
end

function G.ZoomAt(view, zoom, x, y)
    local u, v = G.ToMap(view, x, y)
    view.zoom = G.Clamp(zoom, 1, view.maxZoom)
    local w, h = G.Size(view)
    view.x, view.y = u - (x - view.width / 2) / w, v - (y - view.height / 2) / h
    G.Constrain(view)
end

function G.Pan(view, dx, dy)
    local w, h = G.Size(view)
    view.x, view.y = view.x - dx / w, view.y - dy / h
    G.Constrain(view)
end

function G.Fit(view, rect)
    view.zoom = 1
    local w, h = G.Size(view)
    view.zoom = G.Clamp(math.min(view.width / ((rect.r - rect.l) * w), view.height / ((rect.b - rect.t) * h)), 1, view.maxZoom)
    view.x, view.y = (rect.l + rect.r) / 2, (rect.t + rect.b) / 2
    G.Constrain(view)
end

-- Crop texture coordinates along with geometry; never stretch a clipped edge.
function G.CropUV(source, clipped, uv)
    uv = uv or { 0, 1, 0, 1 }
    local w, h = source.r - source.l, source.b - source.t
    local du, dv = uv[2] - uv[1], uv[4] - uv[3]
    return { uv[1] + (clipped.l - source.l) / w * du, uv[1] + (clipped.r - source.l) / w * du,
        uv[3] + (clipped.t - source.t) / h * dv, uv[3] + (clipped.b - source.t) / h * dv }
end
