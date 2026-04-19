local _, NS = ...

local JanisTheme = _G.JanisTheme
if type(JanisTheme) ~= "table" or type(JanisTheme.New) ~= "function" then
    error("General Gold Tracker requires JanisTheme-1.0. Check General-Gold-Tracker.toc load order.")
end

NS.JanisThemeClass = JanisTheme
NS.JanisTheme = NS.JanisTheme or JanisTheme:New({
    addon = NS.GoldTracker,
    assetRoot = "Interface\\AddOns\\General-Gold-Tracker\\Libs\\JanisTheme-1.0\\Assets\\",
})

local Theme = NS.JanisTheme

local function GetCursorPointForFrame(frame)
    if type(GetCursorPosition) ~= "function" then
        return nil, nil
    end

    local cursorX, cursorY = GetCursorPosition()
    if not cursorX or not cursorY then
        return nil, nil
    end

    local parent = frame and frame:GetParent() or UIParent
    local scale = parent and parent.GetEffectiveScale and parent:GetEffectiveScale()
    if not scale or scale == 0 then
        scale = UIParent and UIParent.GetEffectiveScale and UIParent:GetEffectiveScale() or 1
    end

    return cursorX / scale, cursorY / scale
end

local function ResolveResizeBounds(options)
    if type(options.getBounds) == "function" then
        local minWidth, minHeight, maxWidth, maxHeight = options.getBounds()
        return tonumber(minWidth), tonumber(minHeight), tonumber(maxWidth), tonumber(maxHeight)
    end

    return tonumber(options.minWidth), tonumber(options.minHeight), tonumber(options.maxWidth), tonumber(options.maxHeight)
end

local function ClampResizeValue(value, minimum, maximum)
    value = tonumber(value) or 1
    if minimum then
        value = math.max(minimum, value)
    end
    if maximum then
        value = math.min(maximum, value)
    end
    return math.floor(value + 0.5)
end

local function AnchorFrameTopLeft(frame)
    if not frame or type(frame.GetLeft) ~= "function" or type(frame.GetTop) ~= "function" then
        return
    end

    local left = frame:GetLeft()
    local top = frame:GetTop()
    if not left or not top then
        return
    end

    local parent = frame:GetParent() or UIParent
    local parentLeft = parent and parent.GetLeft and parent:GetLeft() or 0
    local parentBottom = parent and parent.GetBottom and parent:GetBottom() or 0
    frame:ClearAllPoints()
    frame:SetPoint("TOPLEFT", parent, "BOTTOMLEFT", left - parentLeft, top - parentBottom)
end

function Theme:CreateResizeButton(frame, options)
    if not frame then
        return nil
    end

    options = type(options) == "table" and options or {}

    local resizeButton = CreateFrame("Button", nil, frame)
    resizeButton:SetSize(options.size or 16, options.size or 16)
    resizeButton:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", options.offsetX or -8, options.offsetY or 8)
    resizeButton:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")
    resizeButton:SetHighlightTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Highlight")
    resizeButton:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Down")
    resizeButton:SetAlpha(options.alpha or 0.7)

    local dragState = nil

    local function StopResize()
        if not dragState then
            return
        end

        dragState = nil
        frame.isManualResizing = false
        resizeButton:SetScript("OnUpdate", nil)
        if resizeButton.UnlockHighlight then
            resizeButton:UnlockHighlight()
        end
        if frame.StopMovingOrSizing then
            frame:StopMovingOrSizing()
        end
        if type(options.onResizeStop) == "function" then
            options.onResizeStop(frame)
        end
    end

    local function UpdateResize()
        if not dragState then
            return
        end
        if type(IsMouseButtonDown) == "function" and not IsMouseButtonDown("LeftButton") then
            StopResize()
            return
        end

        local cursorX, cursorY = GetCursorPointForFrame(frame)
        if not cursorX or not cursorY then
            return
        end

        local minWidth, minHeight, maxWidth, maxHeight = ResolveResizeBounds(options)
        local width = ClampResizeValue(dragState.width + (cursorX - dragState.cursorX), minWidth, maxWidth)
        local height = ClampResizeValue(dragState.height - (cursorY - dragState.cursorY), minHeight, maxHeight)

        if width ~= dragState.lastWidth or height ~= dragState.lastHeight then
            dragState.lastWidth = width
            dragState.lastHeight = height
            frame:SetSize(width, height)
        end
    end

    resizeButton:SetScript("OnMouseDown", function(_, button)
        if button ~= "LeftButton" then
            return
        end

        local cursorX, cursorY = GetCursorPointForFrame(frame)
        if not cursorX or not cursorY then
            return
        end

        if frame.Raise then
            frame:Raise()
        end
        if type(options.onResizeStart) == "function" then
            options.onResizeStart(frame)
        end

        local width, height = frame:GetSize()
        AnchorFrameTopLeft(frame)
        dragState = {
            cursorX = cursorX,
            cursorY = cursorY,
            width = tonumber(width) or 1,
            height = tonumber(height) or 1,
            lastWidth = tonumber(width) or 1,
            lastHeight = tonumber(height) or 1,
        }

        frame.isManualResizing = true
        if resizeButton.LockHighlight then
            resizeButton:LockHighlight()
        end
        resizeButton:SetScript("OnUpdate", UpdateResize)
    end)
    resizeButton:SetScript("OnMouseUp", StopResize)
    resizeButton:SetScript("OnHide", StopResize)

    frame.resizeButton = resizeButton
    return resizeButton
end
