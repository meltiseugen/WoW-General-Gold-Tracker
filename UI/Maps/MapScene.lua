local _, NS = ...
local addon = NS.GoldTracker
local G = addon.MapGeometry
local Scene = {}
addon.MapScene = Scene

local function coverage(view, rect)
    local w, h = G.Size(view)
    return math.max((rect.r - rect.l) * w / view.width, (rect.b - rect.t) * h / view.height)
end

local function area(rect)
    return (rect.r - rect.l) * (rect.b - rect.t)
end

local function paintingOrder(a, b)
    local aa, ba = area(a.node.rect), area(b.node.rect)
    if aa == ba then return a.node.mapID < b.node.mapID end
    return aa > ba
end

-- Build one hierarchy-wide plan. Geographic size must not give neighboring zones
-- different transition clocks, or a later background can hide earlier detail.
function Scene.Build(view, source, visible)
    local plan = { backgrounds = {}, zones = {}, localities = {}, contexts = {} }
    if not source.root or not visible then return plan end
    local root = source.root
    plan.backgrounds[1] = { node = root, alpha = 1 }
    local continents = G.Smooth(1.10, 1.30, view.zoom)
    for _, node in ipairs(source.nodes) do
        if not node.hiddenPhase and G.Intersection(node.rect, visible) then
            local context = source:Context(node)
            local state = plan.contexts[context.mapID]
            if not state then
                -- A short, shared band at roughly one and a half continent views.
                state = { context = context, detail = G.Smooth(1.40, 1.60, coverage(view, context.rect)) }
                plan.contexts[context.mapID] = state
            end
            if node ~= root then
                if node.mapType == 2 then
                    plan.backgrounds[#plan.backgrounds + 1] = { node = node, alpha = continents }
                else
                    local parent = source.byID[node.parentMapID]
                    local relativeArea = area(node.rect) / area(context.rect)
                    -- Small outdoor zones (Redridge, Swamp of Sorrows, etc.)
                    -- still share the continent transition. Size alone cannot
                    -- distinguish them from city paintings.
                    local locality = parent and parent.mapType == 3
                    if not locality and relativeArea < 0.01 and state.detail > 0 then
                        -- Larger city paintings (such as Shattrath) have no fog
                        -- overlays. Keep them above surrounding zone detail too.
                        local art = source:Art(node)
                        local data = art and source:TerrainData()
                        locality = data and data.clearArt and data.clearArt[art.artID] or false
                    end
                    local alpha = state.detail
                    if locality then alpha = alpha * G.Smooth(0.30, 0.42, coverage(view, node.rect)) end
                    local entry = { node = node, alpha = alpha, state = state }
                    local list = locality and plan.localities or plan.zones
                    list[#list + 1] = entry
                end
            end
        end
    end
    table.sort(plan.zones, paintingOrder)
    table.sort(plan.localities, paintingOrder)
    return plan
end

function Scene.TerrainProjection(source, node, state)
    local context = state.context
    if context.world == nil then context.world = addon.MapDataSource.ReadWorld(context.mapID) or false end
    if context.world and context.world.id == node.world.id then
        local world, n = context.world, node.world
        local projected = G.SubRect(context.rect, (n.w0 - world.w0) / (world.w1 - world.w0),
            (n.n0 - world.n0) / (world.n1 - world.n0), (n.w1 - world.w0) / (world.w1 - world.w0),
            (n.n1 - world.n0) / (world.n1 - world.n0))
        local tolerance = math.max(context.rect.r - context.rect.l, context.rect.b - context.rect.t) * 0.00001
        local compatible = true
        for _, edge in ipairs({ "l", "r", "t", "b" }) do
            if math.abs(projected[edge] - node.rect[edge]) > tolerance then compatible = false; break end
        end
        if compatible then
            -- One physical world projection spans zone borders and gaps in painted art.
            return { mapID = context.mapID, mapType = 3, rect = context.rect, world = context.world, art = node.art }
        end
    end
    -- Separate floors and non-geographic map layouts retain their own placement.
    return node
end
