local _, NS = ...
local addon, Theme = NS.GoldTracker, NS.JanisTheme
local G, Source = addon.MapGeometry, addon.MapDataSource
local Map = {}
local cards = setmetatable({}, { __mode = "k" })

function addon:RefreshInteractiveMapStyles()
    for card in pairs(cards) do
        if card.options then
            card:Stop()
            card.renderer:Release()
            card.source = nil
            -- Hidden hosts release their old scene now and rebuild on next use.
            if card.viewport:IsVisible() then card:SetSubject(card.options) end
        end
    end
end

local function text(parent, font)
    return parent:CreateFontString(nil, "OVERLAY", font or "GameFontHighlightSmall")
end

function Map:Cursor()
    if not GetCursorPosition then return self.view.width / 2, self.view.height / 2 end
    local x, y = GetCursorPosition()
    local scale = self.viewport:GetEffectiveScale()
    return x / scale - self.viewport:GetLeft(), self.viewport:GetTop() - y / scale
end

function Map:Stop()
    self.dragging, self.animation = nil, nil
    self.viewport:SetScript("OnUpdate", nil)
end

function Map:Animate(elapsed)
    local x, y = self:Cursor()
    if self.dragging then
        if IsMouseButtonDown and not IsMouseButtonDown("LeftButton") then
            self.dragging = nil
        else
            G.Pan(self.view, x - self.dragX, y - self.dragY)
            self.dragX, self.dragY = x, y
        end
    end
    local animation = self.animation
    if animation then
        local target = animation.target
        local zoom = math.exp(math.log(self.view.zoom) + math.log(target / self.view.zoom) * (1 - math.exp(-16 * math.min(elapsed, 0.1))))
        local done = math.abs(math.log(target / zoom)) < 0.001
        if done then zoom = target end
        G.ZoomAt(self.view, zoom, self.dragging and x or animation.x, self.dragging and y or animation.y)
        if done then self.animation = nil end
    end
    self:Render()
    if not self.dragging and not self.animation then self.viewport:SetScript("OnUpdate", nil) end
end

function Map:StartUpdates()
    self.viewport:SetScript("OnUpdate", function(_, elapsed) self:Animate(elapsed) end)
end

function Map:Reset()
    self:Stop()
    self.viewAdjusted = false
    if not self.initialRect then return end
    G.Fit(self.view, self.initialRect)
    self:Render()
end

function Map:CenterOnSubject()
    local options, source = self.options, self.source
    local node = source and source.byID and options and source.byID[options.mapID]
    if not node or not options.x or not options.y then return end
    self:Stop()
    self.viewAdjusted = true
    self.view.x = node.rect.l + options.x * (node.rect.r - node.rect.l)
    self.view.y = node.rect.t + options.y * (node.rect.b - node.rect.t)
    G.Constrain(self.view)
    self:Render()
end

function Map:SetCompactFooter(compact)
    self.compactFooter = compact == true
    self.viewport:ClearAllPoints()
    self.viewport:SetPoint("TOPLEFT", 10, -36)
    self.viewport:SetPoint("BOTTOMRIGHT", -10, self.compactFooter and 28 or 48)
    self.coordinates:ClearAllPoints()
    self.coordinates:SetPoint("BOTTOMLEFT", 12, self.compactFooter and 10 or 28)
end

function Map:Resize()
    local width, height = math.max(1, self.viewport:GetWidth()), math.max(1, self.viewport:GetHeight())
    if self.view.width == width and self.view.height == height then return end
    self.view.width, self.view.height = width, height
    if self.source then
        if not self.viewAdjusted and self.initialRect then G.Fit(self.view, self.initialRect)
        else G.Constrain(self.view) end
        self:Render()
    end
end

function Map:SetSubject(options)
    local standard = not (addon.db and addon.db.enableExperimentalMaps == true)
    local styleChanged = self.standard ~= standard
    local changed = self.subjectKey ~= options.key or styleChanged
    local refresh = changed or self.revision ~= options.revision or self.revealAll ~= (options.revealAll == true)
    self.revealAll = options.revealAll == true
    self.standard = standard
    self.subjectKey, self.revision, self.options = options.key, options.revision, options
    self.mapID, self.x, self.y, self.characterLocations = options.mapID, options.x, options.y, options.pins
    if changed then self:Stop(); self.viewAdjusted = false end
    if styleChanged then self.renderer:Release() end
    if changed or not self.source then
        self.source = Source.New(options, standard)
    else
        self.source.options = options
        if refresh then
            for _, node in ipairs(self.source.nodes) do node.art, node.explorationRead = nil, nil end
            for _, context in pairs(self.source.contexts or {}) do context.world = nil end
        end
    end
    local source, view = self.source, self.view
    local art = source.root and source:Art(source.root)
    self.heading:SetText(options.heading or "Map")
    self.resetButton:SetEnabled(art ~= nil)
    if not art then
        self.initialRect = nil
        self:Render()
        return
    end
    view.artWidth, view.artHeight = art.width, art.height
    view.width, view.height = math.max(1, self.viewport:GetWidth()), math.max(1, self.viewport:GetHeight())
    local node = source.byID[options.mapID] or source.root
    self.initialRect = node.rect
    if changed then G.Fit(view, self.initialRect) else G.Constrain(view) end
    self:Render()
end

function Map:RenderPins()
    local source, view = self.source, self.view
    self.pin:Hide()
    for _, pin in ipairs(self.characterPins) do pin:Hide() end
    if not self.hasMapArt then return end
    if self.options.pins and self.options.renderPins then
        self.options.renderPins(self)
    elseif self.options.x and self.options.y then
        local node = source.byID[self.options.mapID]
        if node then
            local u = node.rect.l + self.options.x * (node.rect.r - node.rect.l)
            local v = node.rect.t + self.options.y * (node.rect.b - node.rect.t)
            local x, y = G.ToScreen(view, u, v)
            if x >= 0 and x <= view.width and y >= 0 and y <= view.height then
                self.pin:ClearAllPoints()
                self.pin:SetPoint("CENTER", self.pinLayer, "TOPLEFT", x, -y)
                self.pin:Show()
            end
        end
    end
end

function Map:ProjectPoint(x, y)
    return G.ToScreen(self.view, x, y)
end

function Map:Render()
    if not self.options then return end
    local standard = not (addon.db and addon.db.enableExperimentalMaps == true)
    if not self.source or self.standard ~= standard then self:SetSubject(self.options); return end
    local source = self.source
    self.hasMapArt = source.root and source:Art(source.root) ~= nil or false
    self.renderer:Render(self.view, source)
    self:RenderPins()
    self.message:SetShown(not self.hasMapArt)
    if not self.hasMapArt then self.message:SetText(self.options.emptyText or "Map art unavailable") end
    local detail = "Drag to pan  ·  Scroll to zoom"
    if self.renderer.explorationUnknown then detail = "Exploration not recorded here for this character"
    elseif self.renderer.terrainUnavailable then detail = "Terrain detail unavailable here"
    elseif self.renderer.terrainCount > 0 then detail = self.options.revealAll and "Terrain detail" or "Discovered terrain" end
    self.status:SetText(detail)
    self.coordinates:SetText(self.options.coordinateText or (self.options.x and self.options.y
        and string.format("%.2f, %.2f", self.options.x * 100, self.options.y * 100) or ""))
    if self.compactFooter then
        self.status:ClearAllPoints()
        self.status:SetPoint("BOTTOMRIGHT", -12, 10)
        self.status:SetJustifyH("RIGHT")
        local available = self.view.width - self.coordinates:GetStringWidth() - 24
        self.status:SetShown(available >= self.status:GetStringWidth())
    end
end

function addon:CreateInteractiveMapCard(parent, heading)
    local card = Theme:CreatePanel(parent, "panel", "chromeBorder")
    cards[card] = true
    for name, method in pairs(Map) do card[name] = method end
    card.view = { width = 1, height = 1, artWidth = 1, artHeight = 1, x = 0.5, y = 0.5, zoom = 1, maxZoom = 128 }
    card.heading = text(card, "GameFontNormal")
    card.heading:SetPoint("TOPLEFT", 12, -12)
    card.heading:SetPoint("TOPRIGHT", -112, -12)
    card.heading:SetWordWrap(false)
    card.heading:SetText(heading)
    card.resetButton = Theme:CreateButton(card, 92, 24, "Reset view", "neutral")
    card.resetButton:SetPoint("TOPRIGHT", -10, -6)
    card.resetButton.tooltipText = "Restore the original map, zoom, and position."
    card.resetButton:SetScript("OnClick", function() card:Reset() end)
    card.viewport = CreateFrame("Frame", nil, card)
    card.viewport:SetPoint("TOPLEFT", 10, -36)
    card.viewport:SetPoint("BOTTOMRIGHT", -10, 48)
    card.viewport:SetClipsChildren(true)
    card.viewport:EnableMouse(true)
    card.viewport:EnableMouseWheel(true)
    card.background = card.viewport:CreateTexture(nil, "BACKGROUND")
    card.background:SetAllPoints(card.viewport)
    card.background:SetColorTexture(0.20, 0.16, 0.10, 1)
    card.pinLayer = CreateFrame("Frame", nil, card.viewport)
    card.pinLayer:SetAllPoints(card.viewport)
    card.pinLayer:SetFrameLevel(card.viewport:GetFrameLevel() + 500)
    card.pinLayer:EnableMouse(false)
    card.canvas = card.pinLayer
    card.characterPins = {}
    card.pin = card.pinLayer:CreateTexture(nil, "OVERLAY", nil, 7)
    card.pin:SetAtlas("waypoint-mappin-minimap-tracked")
    card.pin:SetSize(28, 28)
    card.pin:Hide()
    card.message = text(card.pinLayer)
    card.message:SetPoint("CENTER", card.viewport, "CENTER")
    card.message:SetWidth(300)
    card.message:SetJustifyH("CENTER")
    card.coordinates = text(card)
    card.coordinates:SetPoint("BOTTOMLEFT", 12, 28)
    card.status = text(card)
    card.status:SetPoint("BOTTOMLEFT", 12, 10)
    card.status:SetPoint("BOTTOMRIGHT", -12, 10)
    card.status:SetWordWrap(false)
    card.renderer = addon.MapRenderer.New(card.viewport)
    card.viewport:SetScript("OnSizeChanged", function() card:Resize() end)
    card.viewport:SetScript("OnMouseWheel", function(_, delta)
        if not card.hasMapArt or delta == 0 then return end
        card.viewAdjusted = true
        local x, y = card:Cursor()
        local target = G.Clamp((card.animation and card.animation.target or card.view.zoom) * 1.28 ^ delta, 1, card.view.maxZoom)
        card.animation = { x = x, y = y, target = target }
        card:StartUpdates()
    end)
    card.viewport:SetScript("OnMouseDown", function(_, button)
        if button ~= "LeftButton" or not card.hasMapArt then return end
        card.viewAdjusted = true
        card.dragging, card.animation = true, nil
        card.dragX, card.dragY = card:Cursor()
        card:StartUpdates()
    end)
    card.viewport:SetScript("OnMouseUp", function(_, button)
        if button == "LeftButton" then
            card.dragging = nil
            if not card.animation then card.viewport:SetScript("OnUpdate", nil) end
        end
    end)
    card.viewport:SetScript("OnHide", function() card:Stop(); card.renderer:Release() end)
    card.viewport:SetScript("OnShow", function() card:Render() end)
    return card
end
