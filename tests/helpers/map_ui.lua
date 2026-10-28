local function widget(_, _, parent)
    local frame = { parent = parent, scripts = {}, shown = true, points = {} }
    function frame:SetScript(event, callback) self.scripts[event] = callback end
    function frame:HookScript(event, callback)
        local previous = self.scripts[event]
        self.scripts[event] = function(...)
            if previous then previous(...) end
            callback(...)
        end
    end
    function frame:RegisterForDrag(...) self.dragButtons = { ... } end
    function frame:SetAllPoints(target) self.allPoints = target end
    function frame:SetParent(target) self.parent = target end
    function frame:SetFontObject(font) self.font = font end
    function frame:SetFont(path, size, flags) self.fontPath, self.fontSize, self.fontFlags = path, size, flags end
    function frame:SetPoint(...) self.points[#self.points + 1] = { ... } end
    function frame:ClearAllPoints() self.points = {} end
    function frame:SetSize(w, h) self.width, self.height = w, h end
    function frame:SetWidth(w) self.width = w end
    function frame:SetHeight(h) self.height = h end
    function frame:GetWidth() return self.width or 600 end
    function frame:GetHeight() return self.height or 500 end
    function frame:SetText(text)
        self.text = text
        if self.scripts.OnTextChanged then self.scripts.OnTextChanged(self) end
    end
    function frame:GetText() return self.text or "" end
    function frame:SetAutoFocus() end
    function frame:SetMaxLetters() end
    function frame:ClearFocus() self.focused = false end
    function frame:SetFocus() self.focused = true end
    function frame:EnableMouse() end
    function frame:SetFrameStrata(value) self.strata = value end
    function frame:SetClampedToScreen(value) self.clamped = value end
    function frame:SetMovable(value) self.movable = value end
    function frame:StartMoving() self.moving = true end
    function frame:StopMovingOrSizing() self.moving = false end
    function frame:Raise() self.raised = true end
    function frame:SetFrameLevel(level) self.frameLevel = level end
    function frame:GetFrameLevel() return self.frameLevel or 1 end
    function frame:GetEffectiveScale() return self.scale or 1 end
    function frame:GetLeft() return self.left or 0 end
    function frame:GetTop() return self.top or 500 end
    function frame:GetStringWidth() return #(self.text or "") * 6 end
    function frame:SetTexture(texture, wrap) self.texture, self.wrap = texture, wrap end
    function frame:SetColorTexture(...) self.colorTexture = { ... } end
    function frame:SetAtlas(atlas) self.atlas = atlas end
    function frame:SetDrawLayer(layer, subLevel) self.layer, self.subLevel = layer, subLevel end
    function frame:SetTexCoord(...) self.texCoord = { ... } end
    function frame:SetTextColor(...) self.color = { ... } end
    function frame:SetSelected(selected) self.selected = selected end
    function frame:SetEnabled(enabled) self.enabled = enabled end
    function frame:Show()
        local changed = not self.shown
        self.shown = true
        if changed and self.scripts.OnShow then self.scripts.OnShow(self) end
    end
    function frame:Hide()
        local changed = self.shown
        self.shown = false
        if changed and self.scripts.OnHide then self.scripts.OnHide(self) end
    end
    function frame:IsShown() return self.shown end
    function frame:IsVisible()
        return self.shown and (not self.parent or self.parent:IsVisible())
    end
    function frame:SetShown(shown) if shown then self:Show() else self:Hide() end end
    function frame:SetScrollChild(child) self.child = child end
    function frame:SetVerticalScroll(value) self.verticalScroll = value end
    function frame:GetVerticalScroll() return self.verticalScroll or 0 end
    function frame:SetJustifyH() end
    function frame:SetWordWrap() end
    function frame:CreateFontString() return widget(nil, nil, self) end
    function frame:CreateTexture(_, layer, _, subLevel)
        local texture = widget(nil, nil, self)
        texture.layer, texture.subLevel = layer, subLevel or 0
        return texture
    end
    function frame:EnableMouseWheel(enabled) self.mouseWheel = enabled end
    function frame:SetClipsChildren(enabled) self.clipsChildren = enabled end
    function frame:SetAlpha(alpha) self.alpha = alpha end
    function frame:SetDesaturation(value) self.desaturation = value end
    function frame:SetVertexColor(...) self.vertexColor = { ... } end
    function frame:CreateMaskTexture()
        local mask = widget(nil, nil, self)
        -- Do not let tests/preview pretend MaskTexture cropping works like Texture.
        function mask:SetTexCoord() error("Position the full mask image instead of cropping its UVs") end
        return mask
    end
    function frame:AddMaskTexture(mask) self.masks = self.masks or {}; self.masks[mask] = true end
    function frame:RemoveMaskTexture(mask) if self.masks then self.masks[mask] = nil end end
    return frame
end

return { widget = widget }
